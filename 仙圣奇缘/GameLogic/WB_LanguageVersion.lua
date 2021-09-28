--region *.lua
--Date
--此文件由[BabeLua]插件自动生成


eLanguageVer = {
    LANGUAGE_zh_CN = 1,         --简体中文
	LANGUAGE_viet_VIET = 2,         --越南文
	LANGUAGE_cht_Taiwan =3,			--繁体中文台湾
	LANGUAGE_zh_AUDIT =4,			--广电总局审批
	LANGUAGE_ex_3 =5,
}

local CLanguageVer = class("CLanguageVer")
CLanguageVer.__index = CLanguageVer

function CLanguageVer:ctor()
    self.LanguageVer = eLanguageVer.LANGUAGE_zh_CN          
end

function CLanguageVer:getLanguageVer()
    return self.LanguageVer
end

function CLanguageVer:ModifyWnd(classWnd)
    if self.LanguageVer ==  eLanguageVer.LANGUAGE_zh_CN then
         
    elseif self.LanguageVer ==  eLanguageVer.LANGUAGE_viet_VIET and classWnd ~= nil and classWnd.ModifyWnd_viet_VIET ~= nil then
        classWnd:ModifyWnd_viet_VIET() 
    elseif self.LanguageVer ==  eLanguageVer.LANGUAGE_ex_1 and classWnd ~= nil and classWnd.ModifyWnd_ex_1 ~= nil  then
         
    elseif self.LanguageVer ==  eLanguageVer.LANGUAGE_ex_2 and classWnd ~= nil and classWnd.ModifyWnd_ex_2 ~= nil  then
         
    elseif self.LanguageVer ==  eLanguageVer.LANGUAGE_ex_3 and classWnd ~= nil and classWnd.ModifyWnd_ex_3 ~= nil  then
         
    end
end 

g_LggV = CLanguageVer.new()
g_LggV.LanguageVer = eLanguageVer.LANGUAGE_zh_CN
--endregion
