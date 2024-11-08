USE [BusBooking]
GO
/****** Object:  Table [dbo].[BookingDetails]    Script Date: 09-11-2024 00:05:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BookingDetails](
	[BookingId] [varchar](100) NOT NULL,
	[UserId] [varchar](100) NULL,
	[NoOfSeats] [int] NULL,
	[BusId] [varchar](100) NULL,
	[MonthOfDate] [varchar](20) NULL,
	[SeatNumbers] [varchar](100) NULL,
	[PassengerDetails] [nvarchar](200) NULL,
	[BookingDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[BookingId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BusInfo]    Script Date: 09-11-2024 00:05:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BusInfo](
	[BusId] [varchar](100) NOT NULL,
	[BusName] [varchar](100) NOT NULL,
	[BusNumber] [varchar](100) NOT NULL,
	[BusType] [varchar](100) NOT NULL,
	[TotalSeats] [int] NOT NULL,
	[AvailableSeats] [int] NULL,
	[ReservedSeats] [int] NULL,
	[DepartureTime] [varchar](100) NOT NULL,
	[ArrivalTime] [varchar](100) NOT NULL,
	[Fare] [int] NOT NULL,
	[RouteId] [varchar](100) NOT NULL,
	[Complementory] [varchar](100) NULL,
	[TravelDays] [varchar](100) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[BusId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BusSeats]    Script Date: 09-11-2024 00:05:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BusSeats](
	[SeatID] [varchar](100) NOT NULL,
	[BusID] [varchar](100) NULL,
	[SeatNumber] [varchar](100) NULL,
	[IsAvailable] [bit] NULL,
	[IsBlocked] [bit] NULL,
	[ReservedUntil] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[SeatID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Roles]    Script Date: 09-11-2024 00:05:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Roles](
	[Id] [nvarchar](255) NOT NULL,
	[RoleType] [varchar](255) NOT NULL,
 CONSTRAINT [PK_Roles] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Routes]    Script Date: 09-11-2024 00:05:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Routes](
	[RouteId] [varchar](100) NOT NULL,
	[RouteName] [varchar](100) NULL,
	[StartLocation] [varchar](100) NOT NULL,
	[EndLocation] [varchar](100) NOT NULL,
	[TotalTime] [varchar](100) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[RouteId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserTable]    Script Date: 09-11-2024 00:05:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserTable](
	[Userid] [varchar](100) NOT NULL,
	[UserPassword] [varchar](100) NULL,
	[RoleId] [nvarchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[Userid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BookingDetails] ADD  DEFAULT (getdate()) FOR [BookingDate]
GO
ALTER TABLE [dbo].[BusSeats] ADD  DEFAULT ((1)) FOR [IsAvailable]
GO
ALTER TABLE [dbo].[BusSeats] ADD  DEFAULT ((0)) FOR [IsBlocked]
GO
ALTER TABLE [dbo].[BusInfo]  WITH CHECK ADD  CONSTRAINT [FK_BusInfo_RouteId] FOREIGN KEY([RouteId])
REFERENCES [dbo].[Routes] ([RouteId])
GO
ALTER TABLE [dbo].[BusInfo] CHECK CONSTRAINT [FK_BusInfo_RouteId]
GO
ALTER TABLE [dbo].[BusSeats]  WITH CHECK ADD  CONSTRAINT [FK_BusSeatsBusID] FOREIGN KEY([BusID])
REFERENCES [dbo].[BusInfo] ([BusId])
GO
ALTER TABLE [dbo].[BusSeats] CHECK CONSTRAINT [FK_BusSeatsBusID]
GO
