--------------------------------------------------------------------------------------
-- 文件名:	WJQ_JuBaoGe.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:  陆奎安
-- 日  期:	2014-12-10 10:24
-- 版  本:	1.0
-- 描  述:	活动界面
-- 应  用:  本例子使用一般方法的实现Scene
---------------------------------------------------------------------------------------

Game_JuBaoGe = class("Game_JuBaoGe")
Game_JuBaoGe.__index = Game_JuBaoGe

local tbWndNameCH =
{
	Button_JuBaoGePNL1 = _T("声望商店"),
	Button_JuBaoGePNL2 = _T("将魂商店"),
}

local function setImage_Locker(Button_ShopPNL, bIsLock)
	local Image_Locker = tolua.cast(Button_ShopPNL:getChildByName("Image_Locker"), "ImageView")
	local Image_ShopIcon = tolua.cast(Button_ShopPNL:getChildByName("Image_ShopIcon"), "ImageView")
	Image_ShopIcon:setVisible(true)
	
	local Label_OpenCondition = tolua.cast(Button_ShopPNL:getChildByName("Label_OpenCondition"), "Label")
	
	if bIsLock then
		Button_ShopPNL:setTouchEnabled(false)
		Image_Locker:setVisible(true)
		Image_ShopIcon:setColor(ccc3(100, 100, 100))
		
		local strBtnName = Button_ShopPNL:getName()
		local nOpenLevel = getFunctionOpenLevelCsvByStr(strBtnName).OpenLevel
		Label_OpenCondition:setVisible(true)
		if eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer() then
			Label_OpenCondition:setText(tbWndNameCH[strBtnName].." ".._T("将在").." "..nOpenLevel.." ".._T("级开放"))
		else
			Label_OpenCondition:setText(tbWndNameCH[strBtnName].._T("将在")..nOpenLevel.._T("级开放"))
		end
	else
		Button_ShopPNL:setTouchEnabled(true)
		Image_Locker:setVisible(false)
		Image_ShopIcon:setColor(ccc3(255, 255, 255))
		Label_OpenCondition:setVisible(false)
	end
end

function Game_JuBaoGe:initWnd(widget)
	local Image_JuBaoGePNL = tolua.cast(self.rootWidget:getChildByName("Image_JuBaoGePNL"), "ImageView")
	local Image_ContentPNL = tolua.cast(Image_JuBaoGePNL:getChildByName("Image_ContentPNL"), "ImageView")
	local Button_JuBaoGePNL1 = tolua.cast(Image_ContentPNL:getChildByName("Button_JuBaoGePNL1"), "Button")
	local Button_JuBaoGePNL2 = tolua.cast(Image_ContentPNL:getChildByName("Button_JuBaoGePNL2"), "Button")

	local function onClick_Button_ShopPNL(pSender, eventType) 
		if eventType == ccs.TouchEventType.ended then 
			local strBtnName = pSender:getName()
			if strBtnName == "Button_JuBaoGePNL1" then
				g_WndMgr:openWnd("Game_ShopPrestige")
			elseif strBtnName == "Button_JuBaoGePNL2" then
				g_shopSecret:requestNewItem()
			end
		end
	end
	Button_JuBaoGePNL1:addTouchEventListener(onClick_Button_ShopPNL)
	Button_JuBaoGePNL2:addTouchEventListener(onClick_Button_ShopPNL)  
	
	local Image_SymbolBlueLight = tolua.cast(Button_JuBaoGePNL1:getChildByName("Image_SymbolBlueLight"), "ImageView")
	local ccSprite = tolua.cast(Image_SymbolBlueLight:getVirtualRenderer(),"CCSprite")
	g_SetBlendFuncSprite(ccSprite,4)
	local Image_SymbolBlueLight = tolua.cast(Button_JuBaoGePNL2:getChildByName("Image_SymbolBlueLight"), "ImageView")
	local ccSprite = tolua.cast(Image_SymbolBlueLight:getVirtualRenderer(),"CCSprite")
	g_SetBlendFuncSprite(ccSprite,4)
end

function Game_JuBaoGe:openWnd()
	local Image_JuBaoGePNL = tolua.cast(self.rootWidget:getChildByName("Image_JuBaoGePNL"), "ImageView")
	local Image_ContentPNL = tolua.cast(Image_JuBaoGePNL:getChildByName("Image_ContentPNL"), "ImageView")
	local Button_JuBaoGePNL1 = tolua.cast(Image_ContentPNL:getChildByName("Button_JuBaoGePNL1"), "Button")
	local Button_JuBaoGePNL2 = tolua.cast(Image_ContentPNL:getChildByName("Button_JuBaoGePNL2"), "Button")
	
	if g_CheckFuncCanOpenByWidgetName("Button_JuBaoGePNL1") then
		setImage_Locker(Button_JuBaoGePNL1, false)
	else
		setImage_Locker(Button_JuBaoGePNL1, true)
	end

	if g_CheckFuncCanOpenByWidgetName("Button_JuBaoGePNL2") then
		setImage_Locker(Button_JuBaoGePNL2, false)
	else
		setImage_Locker(Button_JuBaoGePNL2, true)
	end

	local Image_NameLabe2 = tolua.cast(Button_JuBaoGePNL2:getChildByName("Image_NameLabel"), "ImageView")
	local Image_Name = Image_NameLabe2:getChildByName("Image_Name")
	g_SetBubbleNotify(Image_NameLabe2, g_GetNoticeNum_ShenMiShop(), Image_Name:getSize().width / 2 + 20, -4)
end

function Game_JuBaoGe:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_JuBaoGePNL = tolua.cast(self.rootWidget:getChildByName("Image_JuBaoGePNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_JuBaoGePNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
	mainWnd:showMainHomeZoomInAnimation()
end

function Game_JuBaoGe:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_JuBaoGePNL = tolua.cast(self.rootWidget:getChildByName("Image_JuBaoGePNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	local function actionEndCall()
		if funcWndCloseAniCall then
			funcWndCloseAniCall()
		end
		mainWnd:showMainHomeZoomOutAnimation()
	end
	g_CreateUIDisappearAnimation_Scale(Image_JuBaoGePNL, actionEndCall, 1.05, 0.15, Image_Background)
end