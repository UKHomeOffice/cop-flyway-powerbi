CREATE TABLE [dbo].[OAR](
	[businesskey] [nvarchar](25) NULL,
	[capturedate] [datetime2](7) NULL,
	[shiftdatetime] [datetimeoffset](7) NULL,
	[totalhoursdisplay] [smallint] NULL,
	[totalnumberofstaffondutycount] [smallint] NULL,
	[totalnumberofstaffondutyminutes] [int] NULL,
	[totalnumberofstaffondutytotalhrsworked] [smallint] NULL,
	[staffgrade] [nvarchar](80) NULL,
	[customsactivitiesminutes] [int] NULL,
	[customsactivitieshours] [smallint] NULL,
	[customsactivitiesname] [nvarchar](80) NULL,
	[cyclamenminutes] [int] NULL,
	[cyclamenhours] [smallint] NULL,
	[cyclamenactivityname] [nvarchar](80) NULL,
	[detectionsearchactivitiesminutes] [int] NULL,
	[detectionsearchactivitieshours] [smallint] NULL,
	[detectionsearchactivitiespositivecount] [smallint] NULL,
	[detectionsearchactivitiesnegativecount] [smallint] NULL,
	[detectionsearchactivitiesname] [nvarchar](80) NULL,
	[detectiontargetcategory] [nvarchar](80) NULL,
	[otheractivitiesminutes] [int] NULL,
	[otheractivitieshours] [smallint] NULL,
	[otheractivitiesname] [nvarchar](80) NULL,
	[pcpactivitiesminutes] [int] NULL,
	[pcpactivitieshours] [smallint] NULL,
	[pcpactivitiesname] [nvarchar](80) NULL,
	[locationname] [nvarchar](80) NULL,
	[teamname] [nvarchar](80) NULL,
	[teamcode] [nvarchar](100) NULL,
	[commandid] [smallint] NULL,
	[commandname] [nvarchar](80) NULL,
	[commandcode] [nvarchar](25) NULL,
	[divisionid] [smallint] NULL,
	[divisioncode] [nvarchar](25) NULL,
	[divisionname] [nvarchar](80) NULL,
	[branchid] [smallint] NULL,
	[branchcode] [nvarchar](25) NULL,
	[branchname] [nvarchar](80) NULL,
	[directorateid] [smallint] NULL,
	[directoratecode] [nvarchar](25) NULL,
	[directoratename] [nvarchar](80) NULL,
	[departmentid] [smallint] NULL,
	[departmentcode] [nvarchar](25) NULL,
	[departmentname] [nvarchar](80) NULL,
	[ministryid] [smallint] NULL,
	[ministrycode] [nvarchar](25) NULL,
	[ministryname] [nvarchar](80) NULL
)