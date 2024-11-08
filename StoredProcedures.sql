USE [BusBooking]
GO
/****** Object:  StoredProcedure [dbo].[AddOrUpdateBusRoute]    Script Date: 09-11-2024 00:08:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AddOrUpdateBusRoute]
    @routeId varchar(100),
    @routeName VARCHAR(100),
    @fromLocation VARCHAR(100),
    @toLocation VARCHAR(100),
    @duration VARCHAR(100)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Routes WHERE RouteId = @routeId)
    BEGIN
        -- Update the existing bus route
        UPDATE Routes
        SET RouteName = @routeName,
            StartLocation = @fromLocation,
            EndLocation = @toLocation,
            TotalTime = @duration
        WHERE RouteId = @routeId;

        PRINT 'Bus route updated successfully';
    END
    ELSE
    BEGIN
        INSERT INTO Routes (RouteId, RouteName, StartLocation, EndLocation, TotalTime)
        VALUES (@routeId, @routeName, @fromLocation, @toLocation, @duration);

        PRINT 'Bus route added successfully';
    END
END;
GO
/****** Object:  StoredProcedure [dbo].[AddOrUpdateBusWithSeats]    Script Date: 09-11-2024 00:08:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[AddOrUpdateBusWithSeats]
    @busId VARCHAR(100),
    @busName VARCHAR(100),
    @busNumber VARCHAR(100),
    @busType VARCHAR(100),
    @totalSeats INT,
    @departureTime VARCHAR(100) ,
    @arrivalTime VARCHAR(100),
    @fare INT,
    @routeId VARCHAR(100),
    @travelDays VARCHAR(100),
    @complementory VARCHAR(100)
AS
BEGIN
    DECLARE @seatNum INT;

    IF EXISTS (SELECT 1 FROM BusInfo WHERE busId = @busId)
    BEGIN
        UPDATE BusInfo
        SET 
            BusName = @busName,
            BusNumber = @busNumber,
            BusType = @busType,
            TotalSeats = @totalSeats,
            AvailableSeats = @totalSeats,
            DepartureTime = @departureTime,
            ArrivalTime = @arrivalTime,
            Fare = @fare,
            RouteId = @routeId,
            TravelDays = @travelDays,
            Complementory = @complementory
        WHERE BusId = @busId;

		DELETE FROM BusSeats WHERE BusID = @busId;

        SET @seatNum = 1;
        WHILE @seatNum <= @totalSeats
        BEGIN
            INSERT INTO BusSeats (SeatID, BusID, SeatNumber)
            VALUES (NEWID(), @busId, 'S' + CAST(@seatNum AS VARCHAR));

            SET @seatNum = @seatNum + 1;
        END;
    END
    ELSE
    BEGIN
        INSERT INTO BusInfo (BusId, BusName, BusNumber, BusType, TotalSeats, DepartureTime, ArrivalTime, Fare, RouteId, TravelDays, Complementory)
        VALUES (@busId, @busName, @busNumber, @busType, @totalSeats, @departureTime, @arrivalTime, @fare, @routeId, @travelDays, @complementory);
        
        SET @seatNum = 1;
        WHILE @seatNum <= @totalSeats
        BEGIN
            INSERT INTO BusSeats (SeatID, BusID, SeatNumber)
            VALUES (NEWID(), @busId, 'S' + CAST(@seatNum AS VARCHAR));

            SET @seatNum = @seatNum + 1;
        END;
    END;
END;
GO
/****** Object:  StoredProcedure [dbo].[AdimnGetBookingDetails]    Script Date: 09-11-2024 00:08:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AdimnGetBookingDetails]
    @bookingId VARCHAR(100)
AS
BEGIN
    
    SELECT 
        bi.Fare,  
        bi.BusName, 
	bd.MonthOfDate,       
        r.StartLocation ,
        r.EndLocation ,
        bd.PassengerDetails ,  
        bd.SeatNumbers ,
	bd.NoOfSeats
    FROM 
        dbo.BookingDetails bd
    JOIN 
        dbo.BusInfo bi ON bd.BusId = bi.BusId
    JOIN 
        dbo.Routes r ON bi.RouteId = r.RouteId
    WHERE 
        bd.UserId = @bookingId  
        AND bd.BookingDate >= DATEADD(DAY, -10, GETDATE()) 
END
GO
/****** Object:  StoredProcedure [dbo].[AdminGetBuses]    Script Date: 09-11-2024 00:08:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[AdminGetBuses]
AS
BEGIN
    SET NOCOUNT ON; -- Prevents extra result sets from interfering with SELECT statements.

    SELECT 
        B.BusId, 
        B.BusName, 
        B.BusNumber, 
        B.BusType, 
        B.AvailableSeats,  
        B.DepartureTime, 
        B.ArrivalTime, 
        B.Fare,
        B.Complementory,
        R.RouteName,              
        R.StartLocation,    
        R.EndLocation,
        R.TotalTime 
    FROM  
        BusInfo B
    INNER JOIN 
        Routes R ON B.RouteID = R.RouteId;
END;
GO
/****** Object:  StoredProcedure [dbo].[BlockOrUnblock]    Script Date: 09-11-2024 00:08:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[BlockOrUnblock]
    @busID VARCHAR(100),
    @seatNumber VARCHAR(MAX) -- This can accept a comma-separated list of seat numbers
AS
BEGIN
    -- Split the comma-separated seat numbers and update their block status
    UPDATE BusSeats
    SET IsBlocked = CASE
        WHEN IsBlocked = 1 THEN 0  -- If blocked, unblock it
        ELSE 1                     -- If unblocked, block it
    END
    WHERE BusID = @busID 
      AND SeatNumber IN (SELECT value FROM STRING_SPLIT(@seatNumber, ','));
END;
GO
/****** Object:  StoredProcedure [dbo].[BookingDetailsSp]    Script Date: 09-11-2024 00:08:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[BookingDetailsSp]
    @userId VARCHAR(100),
    @noOfSeats INT,
    @bookingId VARCHAR(100),
    @busId VARCHAR(100),
    @month VARCHAR(100),
    @seatNumbers VARCHAR(100), 
    @passengerDetails NVARCHAR(200) 
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO BookingDetails (UserId, NoOfSeats, BookingId, BusId, MonthOfDate, SeatNumbers, PassengerDetails)
    VALUES (@userId, @noOfSeats, @bookingId, @busId, @month, @seatNumbers, @passengerDetails);

    DECLARE @Seats TABLE (SeatNumber VARCHAR(100));

    INSERT INTO @Seats (SeatNumber)
    SELECT TRIM(value)
    FROM STRING_SPLIT(@SeatNumbers, ',');

    UPDATE BusSeats
    SET IsAvailable = 0 
    WHERE BusId = @busId
    AND SeatNumber IN (SELECT SeatNumber FROM @Seats); 
END;
GO
/****** Object:  StoredProcedure [dbo].[CheckAuth]    Script Date: 09-11-2024 00:08:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CheckAuth]
    @userId VARCHAR(100),
    @password VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        A.Userid,
        R.RoleType
    FROM 
        UserTable AS A
    INNER JOIN 
        Roles AS R ON A.RoleId = R.Id
    WHERE 
        A.userid = @userId
        AND A.UserPassword = @password;
END;
GO
/****** Object:  StoredProcedure [dbo].[CreateOrUpdate]    Script Date: 09-11-2024 00:08:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CreateOrUpdate] @id nvarchar(255) , @fName nvarchar (255) , @lName nvarchar (255) , @age int ,
@gender nvarchar(255), @roleType nvarchar(255) 

AS 

declare @roleId nvarchar(255) 
select @roleId = Id from roles where roletype =  @roleType;

IF NOT EXISTS (select Id from Users where Id = @Id)
begin
Insert into Users values (@id , @fName , @lName , @age , @gender , @roleId )
end 

else begin 
update Users set FName = @fName , LName = @lName , Age = @age , gender = @gender , roleid = @roleId
where Id = @Id
end

GO
/****** Object:  StoredProcedure [dbo].[DeleteRouteById]    Script Date: 09-11-2024 00:08:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DeleteRouteById]
    @routeId varchar(100) 
AS
BEGIN
    IF EXISTS (SELECT 1 FROM routes WHERE RouteId = @routeId)
    BEGIN
        DELETE FROM Routes
        WHERE RouteId = @routeId;

        PRINT 'Bus deleted successfully.';
    END
    ELSE
    BEGIN
        PRINT 'Bus with the specified ID does not exist.';
    END
END;
GO
/****** Object:  StoredProcedure [dbo].[DeleteUser]    Script Date: 09-11-2024 00:08:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[DeleteUser] @id nvarchar(255)
AS 
BEGIN 
delete from Users where Id = @id;
end 
GO
/****** Object:  StoredProcedure [dbo].[GetAllRoutes]    Script Date: 09-11-2024 00:08:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetAllRoutes]
AS
BEGIN
    SELECT *
    FROM Routes
    ORDER BY StartLocation; 
END;
GO
/****** Object:  StoredProcedure [dbo].[GetAllUsers]    Script Date: 09-11-2024 00:08:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetAllUsers]
AS
BEGIN 
SELECT u.Id, u.FName,u.LName,u.Age,u.Gender,r.RoleType FROM Users As u INNER JOIN roles AS r on u.roleid = r.id;
END
GO
/****** Object:  StoredProcedure [dbo].[GetSeats]    Script Date: 09-11-2024 00:08:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GetSeats]
    @busID VARCHAR(100) 
AS
BEGIN
    SET NOCOUNT ON;  

    SELECT 
        SeatNumber,
        IsAvailable,
        IsBlocked
    FROM 
        BusSeats
    WHERE 
        BusID = @busID
		ORDER BY 
		seatNumber;

END;
GO
/****** Object:  StoredProcedure [dbo].[InsertAuthenticationRecord]    Script Date: 09-11-2024 00:08:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[InsertAuthenticationRecord]
    @userId VARCHAR(100),   
    @password VARCHAR(100)
    
AS
BEGIN
    SET NOCOUNT ON;

	 IF EXISTS (SELECT 1 FROM UserTable WHERE Userid = @userId)
    BEGIN
        THROW 50000 , 'User ID already exists', 1;
    END
    ELSE

	BEGIN


    INSERT INTO UserTable (Userid,UserPassword, RoleId)
    VALUES (@UserId,@Password,'E99E16C9-44AF-460D-87FB-A0782FFD4D71');
	END;
END;
GO
/****** Object:  StoredProcedure [dbo].[SearchBuses]    Script Date: 09-11-2024 00:08:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE PROCEDURE [dbo].[SearchBuses]
    @fromLocation VARCHAR(100),
    @toLocation VARCHAR(100),
    @travelDays VARCHAR(100),  
    @busType VARCHAR(100),
	@departureTimeSlots varchar(100),
	@arrivalTimeSlots varchar(100)
AS
BEGIN
    SELECT 
        B.BusId, 
        B.BusName, 
        B.BusNumber, 
        B.BusType, 
        B.AvailableSeats,  
        B.DepartureTime, 
        B.ArrivalTime, 
        B.Fare,
		B.Complementory,
        R.RouteName,              
        R.StartLocation,    
        R.EndLocation,
		R.TotalTime 
    FROM  
        BusInfo B
    INNER JOIN 
        Routes R ON B.RouteID = R.RouteId  
    WHERE 
        R.StartLocation = @fromLocation 
        AND R.EndLocation = @toLocation 
        AND B.TravelDays LIKE '%' + @travelDays + '%'   
AND (
        @busType IS NULL 
        OR EXISTS (
            SELECT 1
            FROM STRING_SPLIT(@busType, ',') AS SplitBusTypes
            WHERE B.BusType = SplitBusTypes.value
        )
    )
	
	AND (
            @departureTimeSlots IS NULL OR  
            (
                (CHARINDEX('Before6AM', @departureTimeSlots) > 0 AND  B.DepartureTime < '06:00 AM') OR
                (CHARINDEX('From6AMTo12PM', @departureTimeSlots) > 0 AND  B.DepartureTime >= '06:00 AM' AND  B.DepartureTime < '12:00 PM') OR
                (CHARINDEX('From12PMTo6PM', @departureTimeSlots) > 0 AND  B.DepartureTime >= '12:00 PM' AND  B.DepartureTime < '18:00 PM') OR
				(CHARINDEX('After6PM', @departureTimeSlots) > 0 AND B.DepartureTime >= '06:00 PM')
            )
        )
        AND (
            @arrivalTimeSlots IS NULL OR  
            (
                (CHARINDEX('ArrivalBefore6AM', @arrivalTimeSlots) > 0 AND B.ArrivalTime < '06:00 AM') OR
                (CHARINDEX('ArrivalFrom6AMTo12PM', @arrivalTimeSlots) > 0 AND B.ArrivalTime >= '06:00 AM' AND B.ArrivalTime < '12:00 PM') OR
                (CHARINDEX('ArrivalFrom12PMTo6PM', @arrivalTimeSlots) > 0 AND B.ArrivalTime >= '12:00 AM' AND B.ArrivalTime < '18:00 PM') OR
				(CHARINDEX('ArrivalAfter6PM', @arrivalTimeSlots) > 0 AND B.ArrivalTime >= '06:00 PM')
            )
        )
ORDER BY 
        B.DepartureTime ASC;  
END;

GO
/****** Object:  StoredProcedure [dbo].[UserGetBookingDetails]    Script Date: 09-11-2024 00:08:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UserGetBookingDetails]
    @UserId VARCHAR(100)
AS
BEGIN
    
    SELECT 
        bi.Fare,  
        bi.BusName, 
	bd.MonthOfDate,       
        r.StartLocation ,
        r.EndLocation ,
        bd.PassengerDetails ,  
        bd.SeatNumbers ,
	bd.NoOfSeats
    FROM 
        dbo.BookingDetails bd
    JOIN 
        dbo.BusInfo bi ON bd.BusId = bi.BusId
    JOIN 
        dbo.Routes r ON bi.RouteId = r.RouteId
    WHERE 
        bd.UserId = @UserId  
        AND bd.BookingDate >= DATEADD(DAY, -10, GETDATE()) 
END
GO
