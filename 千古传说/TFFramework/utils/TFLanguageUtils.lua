--[[--
	--By:zhudongping
]]
local TFLanguageManager = {}
local LanguagePack

local curLanguage  =  me.Application:getCurrentLanguage()
    if kLanguageEglish == curLanguage then
		LanguangePack = require("TFFramework.language.English")
		print( 'curSystemLanage is '..curLanguage..'->[English]');
	elseif kLanguageChinese == curLanguage then
		LanguagePack  = require("TFFramework.language.Chinese")
		print( 'curSystemLanage is '..curLanguage..'->[Chinese]');
	elseif kLanguageFrench  == curLanguage then
		LanguagePack  = require("TFFramework.language.French")
		print( 'curSystemLanage is '..curLanguage..'->[French]');
	elseif kLanguageGerman  == curLanguage then
		LanguagePack  = require("TFFramework.language.German")
		print( 'curSystemLanage is '..curLanguage..'->[German]');
	elseif kLanguageItalian == curLanguage then
		LanguagePack  = require("TFFramework.language.Italian")
		print( 'curSystemLanage is '..curLanguage..'->[Italian]');
	elseif kLanguageRussian == curLanguage then
		LanguagePack  = require("TFFramework.language.Russian")
		print( 'curSystemLanage is '..curLanguage..'->[Russian]');
	elseif kLanguageSpanish == curLanguage then
		LanguagePack  = require("TFFramework.language.Spanish")
		print( 'curSystemLanage is '..curLanguage..'->[Spanish]');
	elseif kLanguageKorean  == curLanguage then
		LanguagePack  = require("TFFramework.language.Korean")
		print( 'curSystemLanage is '..curLanguage..'->[Korean]');
	elseif kLanguageJapanese == curLanguage then
		LanguagePack  = require("TFFramework.language.Japanese")
		print( 'curSystemLanage is '..curLanguage..'->[Japanese]');
	elseif kLanguageHungarian == curLanguage then
		LanguagePack  = require("TFFramework.language.Spanish")
		print( 'curSystemLanage is '..curLanguage..'->[Spanish]');
	elseif kLanguagePortuguese == curLanguage then
		LanguagePack  = require("TFFramework.language.Portuguese")
		print( 'curSystemLanage is '..curLanguage..'->[Portuguese]');
	elseif kLanguageArabic == curLanguage then
		LanguagePack  = require("TFFramework.language.Arabic")
		print( 'curSystemLanage is '..curLanguage..'->[Arabic]');
 end

function TFLanguageManager:getString( index )
	return getString(index)
end

function getString( index )
	return LanguagePack[index] or ""
end

return TFLanguageManager




