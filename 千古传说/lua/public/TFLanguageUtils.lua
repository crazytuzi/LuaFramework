--[[--
	--By:zhudongping
]]
local TFLanguageManager = {}
local LanguagePack = require("language.Chinese")

local curLanguage  =  me.Application:getCurrentLanguage()
local path = "language.Chinese"
    if kLanguageEglish == curLanguage then
		-- LanguangePack = require("language.English")
		path = "language.English"
		print( 'curSystemLanage is '..curLanguage..'->[English]');
	elseif kLanguageChinese == curLanguage then
		-- LanguagePack  = require("language.Chinese")
		path = "language.Chinese"
		print( 'curSystemLanage is '..curLanguage..'->[Chinese]');
	elseif kLanguageFrench  == curLanguage then
		-- LanguagePack  = require("language.French")
		path = "language.French"
		print( 'curSystemLanage is '..curLanguage..'->[French]');
	elseif kLanguageGerman  == curLanguage then
		-- LanguagePack  = require("language.German")
		path = "language.German"
		print( 'curSystemLanage is '..curLanguage..'->[German]');
	elseif kLanguageItalian == curLanguage then
		-- LanguagePack  = require("language.Italian")
		path = "language.Italian"
		print( 'curSystemLanage is '..curLanguage..'->[Italian]');
	elseif kLanguageRussian == curLanguage then
		-- LanguagePack  = require("language.Russian")
		path = "language.Russian"
		print( 'curSystemLanage is '..curLanguage..'->[Russian]');
	elseif kLanguageSpanish == curLanguage then
		-- LanguagePack  = require("language.Spanish")
		path = "language.Spanish"
		print( 'curSystemLanage is '..curLanguage..'->[Spanish]');
	elseif kLanguageKorean  == curLanguage then
		-- LanguagePack  = require("language.Korean")
		path = "language.Korean"
		print( 'curSystemLanage is '..curLanguage..'->[Korean]');
	elseif kLanguageJapanese == curLanguage then
		-- LanguagePack  = require("language.Japanese")
		path = "language.Japanese"
		print( 'curSystemLanage is '..curLanguage..'->[Japanese]');
	elseif kLanguageHungarian == curLanguage then
		-- LanguagePack  = require("language.Spanish")
		path = "language.Spanish"
		print( 'curSystemLanage is '..curLanguage..'->[Spanish]');
	elseif kLanguagePortuguese == curLanguage then
		-- LanguagePack  = require("language.Portuguese")
		path = "language.Portuguese"
		print( 'curSystemLanage is '..curLanguage..'->[Portuguese]');
	elseif kLanguageArabic == curLanguage then
		-- LanguagePack  = require("language.Arabic")
		path = "language.Arabic"
		print( 'curSystemLanage is '..curLanguage..'->[Arabic]');
 end

-- 判断当前的语音包在否 ， 不存在用默认的语言包
local pathArrary = string.split(path, ".")
if pathArrary and #pathArrary >= 2 then
	local newPath = pathArrary[1].."/"..pathArrary[2]..".lua"
	if TFFileUtil:existFile(newPath) then
		print("language = ", newPath)
		LanguagePack  = require(path)
	else
		print("没有"..path.."语音包")
	end
end


function TFLanguageManager:getString( index )
	return getString(index)
end

function getString( index )
	return LanguagePack[index] or ""
end

return TFLanguageManager




