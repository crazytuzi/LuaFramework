-- 
-- @Author: LaoY
-- @Date:   2018-08-28 14:12:09
-- 
Config = Config or {}
Config.ignore_error = {
	1201004,
	1200007,
	1201006,
	1201013,
	1201024,
	1201025,
	1201005,
	1000008,
	1400001,
	-- 1200004,
}


if AppConfig.Debug then
	Config.ignore_error = {}
end