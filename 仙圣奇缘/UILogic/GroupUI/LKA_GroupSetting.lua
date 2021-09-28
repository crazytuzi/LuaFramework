--------------------------------------------------------------------------------------
-- 文件名:	Game_GroupSetting.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:  陆奎安
-- 日  期:	2015-3-18 10:24
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  

---------------------------------------------------------------------------------------
Game_GroupSetting = class("Game_GroupSetting")
Game_GroupSetting.__index = Game_GroupSetting

local NeedLevel 
local curCondition 
local tbCondition = nil

function Game_GroupSetting:setBtnEnable()
	local maxLevel = g_DataMgr:getGlobalCfgCsv("max_card_lev")
	local minLevel = g_DataMgr:getGlobalCfgCsv("min_request_group_level")
	
	local Image_GroupSettingPNL = tolua.cast(self.rootWidget:getChildByName("Image_GroupSettingPNL"), "ImageView")
	local Image_Condition = tolua.cast(Image_GroupSettingPNL:getChildByName("Image_Condition"), "ImageView")
	local Image_NeedLevel = tolua.cast(Image_GroupSettingPNL:getChildByName("Image_NeedLevel"), "ImageView")
	
	local Button_Next1 = tolua.cast(Image_Condition:getChildByName("Button_Next"), "Button")
	local Button_Forward1 = tolua.cast(Image_Condition:getChildByName("Button_Forward"), "Button")
	
	local Button_Next2 = tolua.cast(Image_NeedLevel:getChildByName("Button_Next"), "Button")
	local Button_Forward2 = tolua.cast(Image_NeedLevel:getChildByName("Button_Forward"), "Button")
	
	if NeedLevel == minLevel then
		g_SetBtnEnable(Button_Next2, true)
		g_SetBtnEnable(Button_Forward2, false)
	elseif  NeedLevel == maxLevel then
		g_SetBtnEnable(Button_Next2, false)
		g_SetBtnEnable(Button_Forward2, true)
	else
		g_SetBtnEnable(Button_Next2, true)
		g_SetBtnEnable(Button_Forward2, true)
	end
	if curCondition == 1 then
		g_SetBtnEnable(Button_Next1, true)
		g_SetBtnEnable(Button_Forward1, false)
	elseif  curCondition == #tbCondition then
		g_SetBtnEnable(Button_Next1, false)
		g_SetBtnEnable(Button_Forward1, true)
	else
		g_SetBtnEnable(Button_Next1, true)
		g_SetBtnEnable(Button_Forward1, true)
	end
	
end

function Game_GroupSetting:setCondition(Widget,nIndex)
	local Image_GroupSettingPNL = tolua.cast(self.rootWidget:getChildByName("Image_GroupSettingPNL"), "ImageView")
	local Image_Condition = tolua.cast(Image_GroupSettingPNL:getChildByName("Image_Condition"), "ImageView")
	local Image_NeedLevel = tolua.cast(Image_GroupSettingPNL:getChildByName("Image_NeedLevel"), "ImageView")
	
	local text = "" 
	local tag = Widget:getTag()
	if tag == 1 then
		text = tbCondition[nIndex]
		local Label_Condition = tolua.cast(Image_Condition:getChildByName("Label_Condition"), "Label")
		if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET  then --越南版
			Label_Condition:setFontSize(18)
		end
		Label_Condition:setText(text)
		
		
		if nIndex == 1 then
			local minLevel = g_DataMgr:getGlobalCfgCsv("min_request_group_level")
			text = string.format(_T("限制等级%d级"), minLevel)
			local Label_NeedLevel = tolua.cast(Image_NeedLevel:getChildByName("Label_NeedLevel"), "Label")
			if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET  then --越南版
				Label_NeedLevel:setFontSize(18)
			end
			Label_NeedLevel:setText(text)
		end
	else
		text = string.format(_T("限制等级%d级"), nIndex)
		local Label_NeedLevel = tolua.cast(Image_NeedLevel:getChildByName("Label_NeedLevel"), "Label")
		if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET  then --越南版
			Label_NeedLevel:setFontSize(18)
		end
		Label_NeedLevel:setText(text)
	end
	
	self:setBtnEnable()
end

function Game_GroupSetting:setButton(Widget)
	local tag = Widget:getTag()
	local maxLevel = g_DataMgr:getGlobalCfgCsv("max_card_lev")
	local minLevel = g_DataMgr:getGlobalCfgCsv("min_request_group_level")
	local function onClickButtonNext()
		if tag ==	1 and  curCondition < #tbCondition  then
			curCondition = curCondition + 1
			self:setCondition(Widget,curCondition)
		else
			if NeedLevel < maxLevel  then
				NeedLevel = NeedLevel + 5
				self:setCondition(Widget,NeedLevel)
			end
		end
	end
	local function onClickButtonForward()
		if tag == 1 and curCondition > 1  then
			curCondition = curCondition -1
			self:setCondition(Widget,curCondition)
		else
			if NeedLevel > minLevel  then
				NeedLevel = NeedLevel - 5
				self:setCondition(Widget,NeedLevel)
			end
		end	
	end
	g_SetBtn(Widget, "Button_Next", onClickButtonNext, true,true,1)
	g_SetBtn(Widget, "Button_Forward", onClickButtonForward, true,true,2)
end

function Game_GroupSetting:initWnd()
	local Image_GroupSettingPNL = tolua.cast(self.rootWidget:getChildByName("Image_GroupSettingPNL"), "ImageView")
	local Image_Condition = tolua.cast(Image_GroupSettingPNL:getChildByName("Image_Condition"), "ImageView")
	local Image_NeedLevel = tolua.cast(Image_GroupSettingPNL:getChildByName("Image_NeedLevel"), "ImageView")
	tbCondition = g_Guild:getGuildConditionText()
	Image_Condition:setTag(1)
	Image_NeedLevel:setTag(2)

	local function onClickButtonConfirm()
		local tbMsg = {req_type = curCondition ,req_lev = NeedLevel }
		g_Guild:GuildSetReqContiRequest(tbMsg)
	end
	g_SetBtn(self.rootWidget, "Button_Confirm", onClickButtonConfirm, true,true)

	
end

function Game_GroupSetting:setWnd()
	local Image_GroupSettingPNL = tolua.cast(self.rootWidget:getChildByName("Image_GroupSettingPNL"), "ImageView")
	local Image_Condition = tolua.cast(Image_GroupSettingPNL:getChildByName("Image_Condition"), "ImageView")
	local Image_NeedLevel = tolua.cast(Image_GroupSettingPNL:getChildByName("Image_NeedLevel"), "ImageView")
	self:setButton(Image_Condition)
	self:setButton(Image_NeedLevel)
	self:setCondition(Image_Condition,curCondition)
	self:setCondition(Image_NeedLevel,NeedLevel)
end

function Game_GroupSetting:openWnd()
	if g_bReturn  then return end 
	NeedLevel = g_Guild:getReqLevel()
	curCondition =  g_Guild:getReqType()
	self:setWnd()
end

function Game_GroupSetting:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_GroupSettingPNL = tolua.cast(self.rootWidget:getChildByName("Image_GroupSettingPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_GroupSettingPNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
end

function Game_GroupSetting:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_GroupSettingPNL = tolua.cast(self.rootWidget:getChildByName("Image_GroupSettingPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_GroupSettingPNL, funcWndCloseAniCall, 1.05, 0.2, Image_Background)
end