------------ Put your Merge settings values here ------------
-- Check Scripts/Structs/10_MergeSettings.lua for detailed information

-- Log File Name
-- Note: if you add subdirectory into File Name, you have to create it first
--Merge.Settings.Logging.LogFile = "Logs/MMMergeLog.txt"
Merge.Settings.Logging.LogFile = "MMMergeLog.txt"

-- Number of old Log Files to preserve [default: 2]
Merge.Settings.Logging.OldLogsCount = 2

-- Force immediate flush into log file
--   0 - [default] don't force
--   1 - force
Merge.Settings.Logging.ForceFlush = 0

-- Print times before log messages
--   0 - [default] disabled
--   1 - enabled
Merge.Settings.Logging.PrintTimes = 0

-- Print CPU times before log messages also, requires Logging.PrintTimes to be enabled
--   0 - [default] disabled
--   1 - enabled
Merge.Settings.Logging.PrintOsClock = 0

-- Print message source file before log messages
--   0 - [default] disabled
--   1 - enabled
Merge.Settings.Logging.PrintSources = 0

-- Print traceback of invalid log message formatting
--   0 - [default] disable
--   1 - enable
Merge.Settings.Logging.PrintFormatTraceback = 0

-- Log Level
--    0 - disabled
--    1 - fatal errors
--    2 - [default] errors
--    3 - warnings
--    4 - informational
--    5 - debug
Merge.Settings.Logging.LogLevel = 2

Merge.Settings.Character.EnhancedAutobiographies = 1

--Merge.Settings.Conversions.PreserveRaceOnLichPromotion = 2

