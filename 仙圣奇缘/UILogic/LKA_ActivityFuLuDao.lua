--------------------------------------------------------------------------------------
-- 文件名:	LKA_ActivityFuLuDao.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:  陆奎安
-- 日  期:	2014-12-10 10:24
-- 版  本:	1.0
-- 描  述:	活动界面
-- 应  用:  本例子使用一般方法的实现Scene
---------------------------------------------------------------------------------------

Game_ActivityFuLuDao = class("Game_ActivityFuLuDao")
Game_ActivityFuLuDao.__index = Game_ActivityFuLuDao

g_ActivityCfgID = {
	WoLongTan = 1,
	CaiShenDong = 2,
	CangJingGe = 3,
	LingRuoSi = 4,
	XianCaoLin = 5,
}

g_ActivityTitlePng = {
	[g_ActivityCfgID.WoLongTan] = "Char_WoLongTan",
	[g_ActivityCfgID.CaiShenDong] = "Char_CaiShenDong",
	[g_ActivityCfgID.CangJingGe] = "Char_CangJingGe",
	[g_ActivityCfgID.LingRuoSi] = "Char_LingRuoSi",
	[g_ActivityCfgID.XianCaoLin] = "Char_XianCaoLin",
	
}

g_ActivityType =
{
	[g_ActivityCfgID.WoLongTan] = macro_pb.Activity_Exp,	--//Exp
	[g_ActivityCfgID.CaiShenDong] = macro_pb.Activity_Money,	--//搞钱活动
	[g_ActivityCfgID.CangJingGe] = macro_pb.Activity_Knowledge,	--//阅历
	[g_ActivityCfgID.LingRuoSi] = macro_pb.Activity_Tribute ,	--//贡品
	[g_ActivityCfgID.XianCaoLin] = macro_pb.Activity_Aura,	--//搞灵力活动
}

local function setLockerPNL(Button_FuLuDaoActivityPNL, strErrorCode, CSV_ActivityBaseItem)
	local Image_LockerPNL = tolua.cast(Button_FuLuDaoActivityPNL:getChildByName("Image_LockerPNL"), "ImageView")
	local ccSprite = tolua.cast(Image_LockerPNL:getVirtualRenderer(),"CCSprite")
	g_SetBlendFuncSprite(ccSprite, 1)
	local Image_ActivityIcon = tolua.cast(Button_FuLuDaoActivityPNL:getChildByName("Image_ActivityIcon"), "ImageView")
	local Label_OpenCondition = tolua.cast(Button_FuLuDaoActivityPNL:getChildByName("Label_OpenCondition"), "Label")

	if strErrorCode == "LevelNotEngough" then
		Button_FuLuDaoActivityPNL:setTouchEnabled(false)
		Image_LockerPNL:setVisible(true)
		Label_OpenCondition:setVisible(true)
		if eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer() then
			Label_OpenCondition:setText(CSV_ActivityBaseItem.Name.._T("将在")..CSV_ActivityBaseItem[1].OpenLevel.._T("级开放"))
		else
			Label_OpenCondition:setText(CSV_ActivityBaseItem.Name.." ".._T("将在").." "..CSV_ActivityBaseItem[1].OpenLevel.." ".._T("级开放"))
		end
		Image_ActivityIcon:setColor(ccc3(100, 100, 100))
	elseif strErrorCode == "DayUnQualified" then
		Button_FuLuDaoActivityPNL:setTouchEnabled(false)
		Image_LockerPNL:setVisible(true)
		Label_OpenCondition:setVisible(true)
		Label_OpenCondition:setText(CSV_ActivityBaseItem.OpenDayString)
		Image_ActivityIcon:setColor(ccc3(100, 100, 100))
	else
		Button_FuLuDaoActivityPNL:setTouchEnabled(true)
		Image_LockerPNL:setVisible(false)
		Label_OpenCondition:setVisible(false)
		Label_OpenCondition:setText("")
		Image_ActivityIcon:setColor(ccc3(255, 255, 255))
	end
end

function Game_ActivityFuLuDao:setActivityPNL()
	local Image_ActivityFuLuDaoPNL = tolua.cast(self.rootWidget:getChildByName("Image_ActivityFuLuDaoPNL"), "ImageView")
	local Image_ContentPNL = tolua.cast(Image_ActivityFuLuDaoPNL:getChildByName("Image_ContentPNL"), "ImageView")
	local Button_FuLuDaoActivityPNL1 = tolua.cast(Image_ContentPNL:getChildByName("Button_FuLuDaoActivityPNL1"), "Button")
	local Button_FuLuDaoActivityPNL2 = tolua.cast(Image_ContentPNL:getChildByName("Button_FuLuDaoActivityPNL2"), "Button")
	local Button_FuLuDaoActivityPNL3 = tolua.cast(Image_ContentPNL:getChildByName("Button_FuLuDaoActivityPNL3"), "Button")
	Button_FuLuDaoActivityPNL1:setTag(g_ActivityCfgID.WoLongTan)
	Button_FuLuDaoActivityPNL2:setTag(g_ActivityCfgID.CaiShenDong)
	Button_FuLuDaoActivityPNL3:setTag(g_ActivityCfgID.CangJingGe)
	local function onClickPNL(pSender, eventType)
		if eventType == ccs.TouchEventType.ended then
			local nActivityID = pSender:getTag()
			g_WndMgr:openWnd("Game_ActivityFuLuDaoSub", nActivityID)
		end
	end

	Button_FuLuDaoActivityPNL1:addTouchEventListener(onClickPNL)
	Button_FuLuDaoActivityPNL2:addTouchEventListener(onClickPNL)
	Button_FuLuDaoActivityPNL3:addTouchEventListener(onClickPNL)

	local Image_SymbolBlueLight = tolua.cast(Button_FuLuDaoActivityPNL1:getChildByName("Image_SymbolBlueLight"), "ImageView")
	local ccSprite = tolua.cast(Image_SymbolBlueLight:getVirtualRenderer(),"CCSprite")
	g_SetBlendFuncSprite(ccSprite,4)
	local Image_SymbolBlueLight = tolua.cast(Button_FuLuDaoActivityPNL2:getChildByName("Image_SymbolBlueLight"), "ImageView")
	local ccSprite = tolua.cast(Image_SymbolBlueLight:getVirtualRenderer(),"CCSprite")
	g_SetBlendFuncSprite(ccSprite,4)
	local Image_SymbolBlueLight = tolua.cast(Button_FuLuDaoActivityPNL3:getChildByName("Image_SymbolBlueLight"), "ImageView")
	local ccSprite = tolua.cast(Image_SymbolBlueLight:getVirtualRenderer(),"CCSprite")
	g_SetBlendFuncSprite(ccSprite,4)
	self:setBubble()
end

function Game_ActivityFuLuDao:initWnd(widget)
	local Image_ActivityFuLuDaoPNL = tolua.cast(self.rootWidget:getChildByName("Image_ActivityFuLuDaoPNL"), "ImageView")
	local Image_ContentPNL = tolua.cast(Image_ActivityFuLuDaoPNL:getChildByName("Image_ContentPNL"), "ImageView")
	local Button_FuLuDaoActivityPNL1 = tolua.cast(Image_ContentPNL:getChildByName("Button_FuLuDaoActivityPNL1"), "Button")
	local Button_FuLuDaoActivityPNL2 = tolua.cast(Image_ContentPNL:getChildByName("Button_FuLuDaoActivityPNL2"), "Button")
	local Button_FuLuDaoActivityPNL3 = tolua.cast(Image_ContentPNL:getChildByName("Button_FuLuDaoActivityPNL3"), "Button")
	
	self.Image_NameLabel = tolua.cast(Button_FuLuDaoActivityPNL1:getChildByName("Image_NameLabel"), "ImageView")
	self.Image_NameLabe2 = tolua.cast(Button_FuLuDaoActivityPNL2:getChildByName("Image_NameLabel"), "ImageView")
	self.Image_NameLabe3 = tolua.cast(Button_FuLuDaoActivityPNL3:getChildByName("Image_NameLabel"), "ImageView")
	
	self:setActivityPNL()
end

function Game_ActivityFuLuDao:setBubble()
	local Image_Name = self.Image_NameLabel:getChildByName("Image_Name")
	g_SetBubbleNotify(self.Image_NameLabel, g_GetActivityNoticeNumByID(g_ActivityCfgID.WoLongTan), Image_Name:getSize().width / 2 + 20, -4)
	local Image_Name = self.Image_NameLabe2:getChildByName("Image_Name")
	g_SetBubbleNotify(self.Image_NameLabe2, g_GetActivityNoticeNumByID(g_ActivityCfgID.CaiShenDong), Image_Name:getSize().width / 2 + 20, -4)
	local Image_Name = self.Image_NameLabe3:getChildByName("Image_Name")
	g_SetBubbleNotify(self.Image_NameLabe3, g_GetActivityNoticeNumByID(g_ActivityCfgID.CangJingGe), Image_Name:getSize().width / 2 + 20, -4)
end

function Game_ActivityFuLuDao:setLocker()
	local nTime = g_GetServerTime()
	nTime = os.date("%w", nTime)
	if tonumber(nTime) == 0 then
		nTime = 7
	end
	
	local function checkTodayIsOpen(tbOpenDay)
		for k, v in ipairs(tbOpenDay)do	
			if tonumber(nTime) == tonumber(v) then
				return true
			end
		end
		return false
	end
	
	local nMasterLevel = g_Hero:getMasterCardLevel()
	
	local Image_ActivityFuLuDaoPNL = tolua.cast(self.rootWidget:getChildByName("Image_ActivityFuLuDaoPNL"), "ImageView")
	local Image_ContentPNL = tolua.cast(Image_ActivityFuLuDaoPNL:getChildByName("Image_ContentPNL"), "ImageView")
	
	local Button_FuLuDaoActivityPNL1 = tolua.cast(Image_ContentPNL:getChildByName("Button_FuLuDaoActivityPNL1"), "Button")
	local CSV_ActivityBaseItem =  g_DataMgr:getActivityBaseCsvByType(g_ActivityCfgID.WoLongTan)
	local tbOpenDay = string.split(CSV_ActivityBaseItem.OpenDay, "|")
	if nMasterLevel < CSV_ActivityBaseItem[1].OpenLevel then
		setLockerPNL(Button_FuLuDaoActivityPNL1, "LevelNotEngough", CSV_ActivityBaseItem)
	else
		if not checkTodayIsOpen(tbOpenDay) then
			setLockerPNL(Button_FuLuDaoActivityPNL1, "DayUnQualified", CSV_ActivityBaseItem)
		else
			setLockerPNL(Button_FuLuDaoActivityPNL1, "Qualify", CSV_ActivityBaseItem)
		end
	end
	
	local Button_FuLuDaoActivityPNL2 = tolua.cast(Image_ContentPNL:getChildByName("Button_FuLuDaoActivityPNL2"), "Button")
	local CSV_ActivityBaseItem =  g_DataMgr:getActivityBaseCsvByType(g_ActivityCfgID.CaiShenDong)	
	local tbOpenDay = string.split(CSV_ActivityBaseItem.OpenDay, "|")
	if nMasterLevel < CSV_ActivityBaseItem[1].OpenLevel then
		setLockerPNL(Button_FuLuDaoActivityPNL2, "LevelNotEngough", CSV_ActivityBaseItem)
	else
		if not checkTodayIsOpen(tbOpenDay) then
			setLockerPNL(Button_FuLuDaoActivityPNL2, "DayUnQualified", CSV_ActivityBaseItem)
		else
			setLockerPNL(Button_FuLuDaoActivityPNL2, "Qualify", CSV_ActivityBaseItem)
		end
	end
	
	local Button_FuLuDaoActivityPNL3 = tolua.cast(Image_ContentPNL:getChildByName("Button_FuLuDaoActivityPNL3"), "Button")
	local CSV_ActivityBaseItem =  g_DataMgr:getActivityBaseCsvByType(g_ActivityCfgID.CangJingGe)	
	local tbOpenDay = string.split(CSV_ActivityBaseItem.OpenDay, "|")
	if nMasterLevel < CSV_ActivityBaseItem[1].OpenLevel then
		setLockerPNL(Button_FuLuDaoActivityPNL3, "LevelNotEngough", CSV_ActivityBaseItem)
	else
		if not checkTodayIsOpen(tbOpenDay) then
			setLockerPNL(Button_FuLuDaoActivityPNL3, "DayUnQualified", CSV_ActivityBaseItem)
		else
			setLockerPNL(Button_FuLuDaoActivityPNL3, "Qualify", CSV_ActivityBaseItem)
		end
	end
end

function Game_ActivityFuLuDao:openWnd(tbData)
	if g_bReturn then self:setBubble() return end
	self:setActivityPNL()
	self:setLocker()
end

function Game_ActivityFuLuDao:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_ActivityFuLuDaoPNL = tolua.cast(self.rootWidget:getChildByName("Image_ActivityFuLuDaoPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	
	g_CreateUIAppearAnimation_Scale(Image_ActivityFuLuDaoPNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
	mainWnd:showMainHomeZoomInAnimation()
end

function Game_ActivityFuLuDao:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_ActivityFuLuDaoPNL = tolua.cast(self.rootWidget:getChildByName("Image_ActivityFuLuDaoPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	local function actionEndCall()
		if funcWndCloseAniCall then
			funcWndCloseAniCall()
		end
		mainWnd:showMainHomeZoomOutAnimation()
	end
	g_CreateUIDisappearAnimation_Scale(Image_ActivityFuLuDaoPNL, actionEndCall, 1.05, 0.15, Image_Background)
	
end