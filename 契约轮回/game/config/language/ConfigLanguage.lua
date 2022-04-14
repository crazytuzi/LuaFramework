-- 
-- @Author: LaoY
-- @Date:   2018-07-17 14:15:56
-- 
ConfigLanguage = {}
if true then
	ConfigLanguage = require('game.config.language.CnLanguage')
end

local cur_platform
function GetLanguageByKey(key)
	return ConfigLanguage[key]
end