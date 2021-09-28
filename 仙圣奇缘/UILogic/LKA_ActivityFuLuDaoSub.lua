--------------------------------------------------------------------------------------
-- 文件名:	LKA_ActivityFuLuDaoSub.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:  陆奎安
-- 日  期:	2014-12-10 10:24
-- 版  本:	1.0
-- 描  述:	活动界面
-- 应  用:  本例子使用一般方法的实现Scene
---------------------------------------------------------------------------------------

Game_ActivityFuLuDaoSub = class("Game_ActivityFuLuDaoSub")
Game_ActivityFuLuDaoSub.__index = Game_ActivityFuLuDaoSub

function Game_ActivityFuLuDaoSub:setListViewRewardItem(widget, nIndex)
	local CSV_DropItem = self.CSV_DropSubPackClient[nIndex]
	if not CSV_DropItem then return end 
	local itemModel = g_CloneDropItemModel(CSV_DropItem)
	if itemModel then
		widget:removeAllChildren()
		widget:addChild(itemModel)
		itemModel:setPosition(ccp(60,60))
		itemModel:setScale(0.9)
		
		local function onClick(pSender, eventType)
		if eventType == ccs.TouchEventType.ended then
			g_ShowDropItemTip(CSV_DropItem)
			end
		end
		itemModel:setTouchEnabled(true)
		itemModel:addTouchEventListener(onClick)
	end
end

function Game_ActivityFuLuDaoSub:onUpdateListView(Panel_ActivityLevelItem, nIndex)
	local CSV_ActivityBase = self.CSV_ActivityBaseItem[nIndex]
	if not CSV_ActivityBase  then  return  end
	
	local Button_ActivityLevelItem = tolua.cast(Panel_ActivityLevelItem:getChildByName("Button_ActivityLevelItem"), "Button")

	local Image_NameLabel = tolua.cast(Button_ActivityLevelItem:getChildByName("Image_NameLabel"), "ImageView")
	local BitmapLabel_OpenLevel = tolua.cast(Image_NameLabel:getChildByName("BitmapLabel_OpenLevel"), "LabelBMFont")
	
	local Image_ActivityIcon = tolua.cast(Button_ActivityLevelItem:getChildByName("Image_ActivityIcon"), "ImageView")
	Image_ActivityIcon:loadTexture(getActivityShiLianImg(self.CSV_ActivityBase.EctypeIcon))
	local Image_Locker = tolua.cast(Button_ActivityLevelItem:getChildByName("Image_Locker"), "ImageView")
	local ccSprite = tolua.cast(Image_Locker:getVirtualRenderer(),"CCSprite")
	g_SetBlendFuncSprite(ccSprite,1)
	local nMasterLevel = g_Hero:getMasterCardLevel()
	BitmapLabel_OpenLevel:setText(CSV_ActivityBase.OpenLevel)
	local Image_CheckCover = tolua.cast(Button_ActivityLevelItem:getChildByName("Image_CheckCover"), "ImageView")
	Image_CheckCover:setVisible(false)
	
	local function onClickActivity(pSender, eventType) 
		self.LuaListView_ActivityLevel:scrollToTop()
	end
	if nMasterLevel < CSV_ActivityBase.OpenLevel then
		Button_ActivityLevelItem:setTouchEnabled(false)
		Image_Locker:setVisible(true)
		Image_ActivityIcon:setColor(ccc3(100, 100, 100))
	else
		g_SetBtnWithGuideCheck(Button_ActivityLevelItem, nIndex, onClickActivity, true)
		Image_Locker:setVisible(false)
		Image_ActivityIcon:setColor(ccc3(255, 255, 255))
	end
	
	local Image_SymbolBlueLight = tolua.cast(Button_ActivityLevelItem:getChildByName("Image_SymbolBlueLight"), "ImageView")
	local ccSprite = tolua.cast(Image_SymbolBlueLight:getVirtualRenderer(),"CCSprite")
	g_SetBlendFuncSprite(ccSprite,4)
end

function Game_ActivityFuLuDaoSub:onAdjustListView(Panel_ActivityLevelItem, nIndex)
	self.nCurrentIndex = nIndex
	
	local CSV_ActivityBase = self.CSV_ActivityBaseItem[nIndex]
	if CSV_ActivityBase  then
		self.ectypeID = CSV_ActivityBase.EctypeID
    end
	
	local Button_ActivityLevelItem = tolua.cast(Panel_ActivityLevelItem:getChildByName("Button_ActivityLevelItem"), "Button")
	local Image_CheckCover = tolua.cast(Button_ActivityLevelItem:getChildByName("Image_CheckCover"), "ImageView")
	if self.Image_CheckCover then
		self.Image_CheckCover:setVisible(false)
	end
	self.Image_CheckCover = Image_CheckCover
	self.Image_CheckCover:setVisible(true)
	
	if  self.nCurrentIndex == 1 then
		self.Button_ForwardPage:setVisible(false)
	else
		self.Button_ForwardPage:setVisible(true)
	end
		
	if self.nCurrentIndex == #self.CSV_ActivityBaseItem then
		self.Button_NextPage:setVisible(false)
	else
		self.Button_NextPage:setVisible(true)	
	end
	
	-- add by zgj
	local nMasterLevel = g_Hero:getMasterCardLevel()
	if nMasterLevel < CSV_ActivityBase.OpenLevel then
		g_SetBtnEnable(self.Button_StartBattle, false)
	else
		g_SetBtnEnable(self.Button_StartBattle, true and self.status)
	end
end

function Game_ActivityFuLuDaoSub:onAdjustListViewOver(Panel_ActivityLevelItem, nIndex)
	if self.nLastAdjustOverIndex and self.nLastAdjustOverIndex == nIndex then	--最终校准的时候会触发多次回调，所以要判断
		return
	end
	
	local CSV_ActivityBase = self.CSV_ActivityBaseItem[nIndex]
	self.CSV_DropSubPackClient = g_DataMgr:getCsvConfig_SecondKeyTableData("DropSubPackClient", CSV_ActivityBase.DropClientID)--g_DataMgr:getCsvConfigByOneKey("DropSubPackClient", CSV_ActivityBase.DropClientID)
	self.ListView_RewardList:updateItems(GetTableLen(self.CSV_DropSubPackClient))
	
	self.nLastAdjustOverIndex = nIndex

end

function Game_ActivityFuLuDaoSub:closeWnd()
	self.Image_CheckCover = nil
	self.ListView_RewardList:updateItems(0)
end

function Game_ActivityFuLuDaoSub:initWnd(widget)
	local Image_ActivityFuLuDaoSubPNL = tolua.cast(self.rootWidget:getChildByName("Image_ActivityFuLuDaoSubPNL"), "ImageView")
	local Image_ContentPNL = tolua.cast(Image_ActivityFuLuDaoSubPNL:getChildByName("Image_ContentPNL"), "ImageView")
	
	self.Button_ForwardPage = tolua.cast(Image_ContentPNL:getChildByName("Button_ForwardPage"), "Button")
	self.Button_NextPage = tolua.cast(Image_ContentPNL:getChildByName("Button_NextPage"), "Button")
	g_CreateFadeInOutAction(self.Button_ForwardPage)
	g_CreateFadeInOutAction(self.Button_NextPage)

	local ListView_ActivityLevel = tolua.cast(Image_ContentPNL:getChildByName("ListView_ActivityLevel"), "ListViewEx")
	local Panel_ActivityLevelItem = tolua.cast(ListView_ActivityLevel:getChildByName("Panel_ActivityLevelItem"), "Layout")
	self.LuaListView_ActivityLevel = Class_LuaListView:new()
	self.LuaListView_ActivityLevel:setListView(ListView_ActivityLevel)
	self.LuaListView_ActivityLevel:setModel(Panel_ActivityLevelItem)
	self.LuaListView_ActivityLevel:setUpdateFunc(handler(self, self.onUpdateListView))
	self.LuaListView_ActivityLevel:setAdjustFunc(handler(self, self.onAdjustListView))
    self.LuaListView_ActivityLevel:setAdjustOverFunc(handler(self, self.onAdjustListViewOver))
	
	local imgScrollSlider = self.LuaListView_ActivityLevel:getScrollSlider()
	if not g_tbScrollSliderXY.LuaListView_ActivityLevel_Y then
		g_tbScrollSliderXY.LuaListView_ActivityLevel_Y = imgScrollSlider:getPositionY()
	end
	imgScrollSlider = imgScrollSlider:setPositionY(g_tbScrollSliderXY.LuaListView_ActivityLevel_Y - 6)
	
	local ListView_RewardList = tolua.cast(Image_ContentPNL:getChildByName("ListView_RewardList"), "ListViewEx")
	local Panel_RewardItem = tolua.cast(ListView_RewardList:getChildByName("Panel_RewardItem"), "Layout")
	local function updataRewardList(widget,nIndex)
		self:setListViewRewardItem(widget,nIndex)
	end
	self.ListView_RewardList = registerListViewEvent(ListView_RewardList, Panel_RewardItem, updataRewardList)
	
	local imgScrollSlider = ListView_RewardList:getScrollSlider()
	if not g_tbScrollSliderXY.ListView_RewardList_Activity_Y then
		g_tbScrollSliderXY.ListView_RewardList_Activity_Y = imgScrollSlider:getPositionY()
	end
	imgScrollSlider = imgScrollSlider:setPositionY(g_tbScrollSliderXY.ListView_RewardList_Activity_Y - 4)
	
	self.Label_Desc1 = tolua.cast(Image_ContentPNL:getChildByName("Label_Desc1"), "Label")
	self.Label_NeedEnergy = tolua.cast(Image_ContentPNL:getChildByName("Label_NeedEnergy"), "Label")
	self.Label_RemainTimes = tolua.cast(Image_ContentPNL:getChildByName("Label_RemainTimes"), "Label")
	self.Button_StartBattle = tolua.cast(Image_ContentPNL:getChildByName("Button_StartBattle"), "Button")
	self.Button_AddTimes = tolua.cast(Image_ContentPNL:getChildByName("Button_AddTimes"), "Button")

	local function onClickStartBattle(pSender, nTag)
		if nTag == 1 then
			if self.status == true then
				g_MsgNetWorkWarning:showWarningText()
				g_MsgMgr:requestActivity(self.nActivityID, self.nCurrentIndex -1)
			end
		elseif nTag == 2 and self.nCurrentIndex > 1 then
			self.LuaListView_ActivityLevel:scrollToLeft(self.nCurrentIndex - 2)
		elseif nTag == 3 and self.nCurrentIndex < #self.CSV_ActivityBaseItem then
			self.LuaListView_ActivityLevel:scrollToLeft(self.nCurrentIndex)
		end
	end

	g_SetBtnWithGuideCheck(self.Button_StartBattle, 1, onClickStartBattle, true)
	g_SetBtnWithEvent(self.Button_ForwardPage, 2, onClickStartBattle, true, true)
	g_SetBtnWithEvent(self.Button_NextPage, 3, onClickStartBattle, true, true)
	
	local function addTimes(pSender, nTag)
		local types,ectypeName = self:vipTypeKey()
		
		local allNum = g_VIPBase:getVipLevelCntNum(types) 
		local addNum = g_VIPBase:getAddTableByNum(types)
		if addNum >= allNum then 
			g_ShowSysTips({text=_T("您今日[")..ectypeName.._T("]副本的购买次数已用完\n下一VIP等级可以增加购买次数上限")})
			return 
		end
		local gold = g_VIPBase:getVipLevelCntGold(types)
		if not g_CheckYuanBaoConfirm(gold,_T("购买[")..ectypeName.._T("]副本需要花费")..gold.._T("元宝，您的元宝不够是否前往充值？")) then
			return
		end
		local str = _T("是否花费")..gold.._T("元宝购买1次[")..ectypeName.._T("]副本？")
		g_ClientMsgTips:showConfirm(str, function() 
			local function sellEctypeNumFunc(times)
				local nUseNum = g_Hero:getDailyNoticeByType(g_ActivityType[self.nActivityID])
				self:setShiLianLabel(nUseNum)
				g_ShowSysTips({text=_T("成功购买1次[")..ectypeName.._T("]副本\n您还可购买")..allNum-times.._T("次。")})
							
				gTalkingData:onPurchase(TDPurchase_Type.TDP_ACTIVITY_FU_LU_NUM,1,gold)
			end
			g_VIPBase:responseFunc(sellEctypeNumFunc)
			g_VIPBase:requestVipBuyTimesRequest(types)	
		end)
	end
	g_SetBtnWithEvent(self.Button_AddTimes, 4, addTimes, true)
end

function Game_ActivityFuLuDaoSub:updateMasterEnergy()
	local nEnergy = g_Hero:getEnergy() 
	nEnergy = nEnergy - self.NeedEnergy 
	g_Hero:setEnergy(nEnergy)
	g_HeadBar:refreshHeadBar()
end

function Game_ActivityFuLuDaoSub:setShiLianLabel(nUseNum)
	self.status = true
	local types = self:vipTypeKey()
	local addNum = g_VIPBase:getAddTableByNum(types)
	local nRemainNum = self.MaxTimes + addNum - nUseNum
	
	if not nRemainNum or nRemainNum <= 0 then
		nRemainNum = 0
		self.Label_RemainTimes:setColor(ccc3(255, 0, 0))
		self.status  = false
	else
		self.Label_RemainTimes:setColor(ccc3(0, 255, 0))
	end
	self.Label_RemainTimes:setText(nRemainNum)
	
	if g_Hero:getEnergy() < self.NeedEnergy  then
		self.Label_NeedEnergy:setColor(ccc3(255, 0, 0))
		self.status  = false
	else
		self.Label_NeedEnergy:setColor(ccc3(0, 255, 0))
	end	
	self.Label_NeedEnergy:setText(self.NeedEnergy)
	g_SetBtnEnable(self.Button_StartBattle, self.status)
	
	g_AdjustWidgetsPosition({self.Label_RemainTimes, self.Button_AddTimes}, -20)
end

function Game_ActivityFuLuDaoSub:openWnd(nActivityID)
	if g_bReturn then return end
	self.Image_CheckCover = nil
	self.nActivityID = nActivityID
	self.CSV_ActivityBase = g_DataMgr:getCsvConfig_FirstKeyData("ActivityBase", self.nActivityID)
	self.CSV_ActivityBaseItem = g_DataMgr:getCsvConfig_SecondKeyTableData("ActivityBase", self.nActivityID)
	self.Label_Desc1:setText(self.CSV_ActivityBase.Desc1)
	
	self.MaxTimes = self.CSV_ActivityBase.MaxTimes 
	self.NeedEnergy = self.CSV_ActivityBase.NeedEnergy
	
	local Image_ActivityFuLuDaoSubPNL = tolua.cast(self.rootWidget:getChildByName("Image_ActivityFuLuDaoSubPNL"), "ImageView")
	local Image_FunctionIconBack = tolua.cast(Image_ActivityFuLuDaoSubPNL:getChildByName("Image_FunctionIconBack"), "ImageView")
	local Image_WndName = tolua.cast(Image_FunctionIconBack:getChildByName("Image_WndName"), "ImageView")
	Image_WndName:loadTexture(getActivityShiLianImg(g_ActivityTitlePng[nActivityID]))

	local nUseNum = g_Hero:getDailyNoticeByType(g_ActivityType[self.nActivityID])
	self:setShiLianLabel(nUseNum)

	local nMasterLevel = g_Hero:getMasterCardLevel()
	local nCurOpenIndex = 0
	for nIndex = 1, #self.CSV_ActivityBaseItem do
		if nMasterLevel < self.CSV_ActivityBaseItem[nIndex].OpenLevel then
			nCurOpenIndex = nIndex - 1
			break
		else
			nCurOpenIndex = nIndex
		end
	end

	self.LuaListView_ActivityLevel:updateItems(#self.CSV_ActivityBaseItem, nCurOpenIndex)
	self:onAdjustListViewOver(nil, nCurOpenIndex)
end

function Game_ActivityFuLuDaoSub:vipTypeKey()
	local types = nil
	local ectypeName = ""
	if self.nActivityID == 1 then 
		types = VipType.VipBuyOpType_ActivityExpTimes --活动 卧龙潭 购买次数
		ectypeName = _T("卧龙潭")
	elseif self.nActivityID == 2 then 
		types = VipType.VipBuyOpType_ActivityMoneyTimes -- 活动 财神岛 购买次数
		ectypeName = _T("财神洞")
	elseif self.nActivityID == 3 then 
		types = VipType.VipBuyOpType_ActivityKnowledgeTimes -- 活动 藏经阁 购买次数
		ectypeName = _T("藏经阁")
	end
	return types,ectypeName
end

function Game_ActivityFuLuDaoSub:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_ActivityFuLuDaoSubPNL = tolua.cast(self.rootWidget:getChildByName("Image_ActivityFuLuDaoSubPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_ActivityFuLuDaoSubPNL, funcWndOpenAniCall, 1.05, 0.2)
end

function Game_ActivityFuLuDaoSub:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_ActivityFuLuDaoSubPNL = tolua.cast(self.rootWidget:getChildByName("Image_ActivityFuLuDaoSubPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_ActivityFuLuDaoSubPNL, funcWndCloseAniCall, 1.05, 0.2)
end

function Game_ActivityFuLuDaoSub:ModifyWnd_viet_VIET()
    local Label_NeedEnergyLB = self.rootWidget:getChildAllByName("Label_NeedEnergyLB")
	local Label_NeedEnergy = self.rootWidget:getChildAllByName("Label_NeedEnergy")

    local Label_RemainTimesLB = self.rootWidget:getChildAllByName("Label_RemainTimesLB")
	local Label_RemainTimes = self.rootWidget:getChildAllByName("Label_RemainTimes")
	local Button_AddTimes = self.rootWidget:getChildAllByName("Button_AddTimes")
    g_AdjustWidgetsPosition({Label_NeedEnergyLB, Label_NeedEnergy, Label_RemainTimesLB, Label_RemainTimes, Button_AddTimes},10)
end