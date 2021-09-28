--------------------------------------------------------------------------------------
-- 文件名:	WJQ_JuXianGe.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:  陆奎安
-- 日  期:	2014-12-10 10:24
-- 版  本:	1.0
-- 描  述:	活动界面
-- 应  用:  本例子使用一般方法的实现Scene
---------------------------------------------------------------------------------------

Game_ActivityJuXianGe = class("Game_ActivityJuXianGe")
Game_ActivityJuXianGe.__index = Game_ActivityJuXianGe

local tbWndNameCH =
{
	Button_ActivityJuXianGePNL1 = _T("神灵感悟"),
	Button_ActivityJuXianGePNL2 = _T("神龙上供"),
}

local function setImage_Locker(Button_ActivityShiLianShanPNL, bIsLock)
	local Image_LockerPNL = tolua.cast(Button_ActivityShiLianShanPNL:getChildByName("Image_LockerPNL"), "ImageView")
	local Image_ActivityIcon = tolua.cast(Button_ActivityShiLianShanPNL:getChildByName("Image_ActivityIcon"), "ImageView")
	Image_ActivityIcon:setVisible(true)
	
	local Label_OpenCondition = tolua.cast(Button_ActivityShiLianShanPNL:getChildByName("Label_OpenCondition"), "Label")
	
	if bIsLock then
		Button_ActivityShiLianShanPNL:setTouchEnabled(false)
		Image_LockerPNL:setVisible(true)
		Image_ActivityIcon:setColor(ccc3(100, 100, 100))
		
		local strBtnName = Button_ActivityShiLianShanPNL:getName()
		local nOpenLevel = getFunctionOpenLevelCsvByStr(strBtnName).OpenLevel
		Label_OpenCondition:setVisible(true)
		if eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer() then
			Label_OpenCondition:setText(tbWndNameCH[strBtnName].." ".._T("将在").." "..nOpenLevel.." ".._T("级开放"))
		else
			Label_OpenCondition:setText(tbWndNameCH[strBtnName].._T("将在")..nOpenLevel.._T("级开放"))
		end
	else
		Button_ActivityShiLianShanPNL:setTouchEnabled(true)
		Image_LockerPNL:setVisible(false)
		Image_ActivityIcon:setColor(ccc3(255, 255, 255))
		Label_OpenCondition:setVisible(false)
	end
end

function Game_ActivityJuXianGe:setBubble()
	local Image_Name = self.Image_NameLabel:getChildByName("Image_Name")
	g_SetBubbleNotify(self.Image_NameLabel, g_GetNoticeNum_GanWu(), Image_Name:getSize().width / 2 + 20, -4)
	local Image_Name = self.Image_NameLabe2:getChildByName("Image_Name")
	g_SetBubbleNotify(self.Image_NameLabe2, g_GetNoticeNum_DragonPray(), Image_Name:getSize().width / 2 + 20, -4)
end

function Game_ActivityJuXianGe:initWnd(widget)
	local Image_ActivityJuXianGePNL = tolua.cast(self.rootWidget:getChildByName("Image_ActivityJuXianGePNL"), "ImageView")
	local Image_ContentPNL = tolua.cast(Image_ActivityJuXianGePNL:getChildByName("Image_ContentPNL"), "ImageView")
	local Button_ActivityJuXianGePNL1 = tolua.cast(Image_ContentPNL:getChildByName("Button_ActivityJuXianGePNL1"), "Button")
	local Button_ActivityJuXianGePNL2 = tolua.cast(Image_ContentPNL:getChildByName("Button_ActivityJuXianGePNL2"), "Button")

	local function onClick_Button_ShopPNL(pSender, eventType) 
		if eventType == ccs.TouchEventType.ended then 
			local strBtnName = pSender:getName()
			if strBtnName == "Button_ActivityJuXianGePNL1" then	--感悟
				g_EliminateSystem:RequestInspireCheckData()
			elseif strBtnName == "Button_ActivityJuXianGePNL2" then --神龙上供
				g_DragonPray:requestInitInfo()
			end
		end
	end
	Button_ActivityJuXianGePNL1:addTouchEventListener(onClick_Button_ShopPNL)
	Button_ActivityJuXianGePNL2:addTouchEventListener(onClick_Button_ShopPNL)
	
	local Image_SymbolBlueLight = tolua.cast(Button_ActivityJuXianGePNL1:getChildByName("Image_SymbolBlueLight"), "ImageView")
	local ccSprite = tolua.cast(Image_SymbolBlueLight:getVirtualRenderer(),"CCSprite")
	g_SetBlendFuncSprite(ccSprite,4)
	local Image_SymbolBlueLight = tolua.cast(Button_ActivityJuXianGePNL2:getChildByName("Image_SymbolBlueLight"), "ImageView")
	local ccSprite = tolua.cast(Image_SymbolBlueLight:getVirtualRenderer(),"CCSprite")
	g_SetBlendFuncSprite(ccSprite,4)
	
	self.Image_NameLabel = tolua.cast(Button_ActivityJuXianGePNL1:getChildByName("Image_NameLabel"), "ImageView")
	self.Image_NameLabe2 = tolua.cast(Button_ActivityJuXianGePNL2:getChildByName("Image_NameLabel"), "ImageView")
end

function Game_ActivityJuXianGe:openWnd()
	if g_bReturn then self:setBubble() return end
	
	local Image_ActivityJuXianGePNL = tolua.cast(self.rootWidget:getChildByName("Image_ActivityJuXianGePNL"), "ImageView")
	local Image_ContentPNL = tolua.cast(Image_ActivityJuXianGePNL:getChildByName("Image_ContentPNL"), "ImageView")
	local Button_ActivityJuXianGePNL1 = tolua.cast(Image_ContentPNL:getChildByName("Button_ActivityJuXianGePNL1"), "Button")
	local Button_ActivityJuXianGePNL2 = tolua.cast(Image_ContentPNL:getChildByName("Button_ActivityJuXianGePNL2"), "Button")
	
	if g_CheckFuncCanOpenByWidgetName("Button_ActivityJuXianGePNL1") then
		setImage_Locker(Button_ActivityJuXianGePNL1, false)
	else
		setImage_Locker(Button_ActivityJuXianGePNL1, true)
	end

	if g_CheckFuncCanOpenByWidgetName("Button_ActivityJuXianGePNL2") then
		setImage_Locker(Button_ActivityJuXianGePNL2, false)
	else
		setImage_Locker(Button_ActivityJuXianGePNL2, true)
	end
	
	self:setBubble()
end

function Game_ActivityJuXianGe:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_ActivityJuXianGePNL = tolua.cast(self.rootWidget:getChildByName("Image_ActivityJuXianGePNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_ActivityJuXianGePNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
	mainWnd:showMainHomeZoomInAnimation()
end

function Game_ActivityJuXianGe:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_ActivityJuXianGePNL = tolua.cast(self.rootWidget:getChildByName("Image_ActivityJuXianGePNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	local function actionEndCall()
		if funcWndCloseAniCall then
			funcWndCloseAniCall()
		end
		mainWnd:showMainHomeZoomOutAnimation()
	end
	g_CreateUIDisappearAnimation_Scale(Image_ActivityJuXianGePNL, actionEndCall, 1.05, 0.15, Image_Background)
end