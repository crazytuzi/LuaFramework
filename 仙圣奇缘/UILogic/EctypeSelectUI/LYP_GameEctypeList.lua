--------------------------------------------------------------------------------------
-- 文件名:	Game_EctypeList.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	yupingli
-- 日  期:	2015-3-7 18:37
-- 版  本:	1.0
-- 描  述:	界面
-- 应  用:   
---------------------------------------------------------------------------------------
Game_EctypeList = class("Game_EctypeList")
Game_EctypeList.__index = Game_EctypeList

local ProgressBar_CollectProgress = nil 			--星星宝箱进度条
local Button_Chest_L		= nil 			--星级宝箱左
local Button_Chest_M		= nil 			--星级宝箱中
local Button_Chest_R		= nil 			--星级宝箱右
local Label_NeedStarRecord_L		= nil
local Label_NeedStarRecord_M 	= nil
local Label_NeedStarRecord_R 	= nil
local Label_StarCollectNum	= nil 			--星星总数 
local Label_StarCollectNumMax	= nil 			--...
local bBattle 		= 0				--判断当前关卡能否战斗

local nDelTag		= 0xffffffff 	--删除标记

--做滚动效果用的
local CSize			= nil 			--整个list view控件的size
local CPoint 		= nil 			--单个modle的size

local nOffsetAbs 	= nil 
local nOffsetx 		= nil
local nItemWidth  	= 256

--可调节	
local iMin 			= 0.7			--两端最小缩放比例 	中间为 1.0
local offsetY		= 20			--两端y轴的最大偏移量 	中间为0
local aphla			= 0.3			--两端的极限透明度		中间为1.0

--以前的数据层
local bSendBattleFlag = nil
local tbEctypeID = nil
local nCurIndexEctype  = nil
local widgetClick  = nil
local nHardLev = nil
local nMaxShowIDMap = nil

-------------------------------------------全局函数beg

function Game_EctypeList:onScrolling_LuaListView_EctypeList(pSender)
	local Button_EctypeListItem = pSender:getChildByName("Button_EctypeListItem")
	if not Button_EctypeListItem then
		return false
	end

	local nPosX = pSender:getPositionX()
	local nTag = pSender:getTag()
	local ccSize = pSender:getSize()
	
	local nCenterPosX = nPosX + ccSize.width/2
	local nOffsetX = nCenterPosX - 128
	local nOffsetAbs = math.abs(nOffsetX)
	Button_EctypeListItem:setScale(1 - 0.25*nOffsetAbs/1280)
	Button_EctypeListItem:setPositionY(300 - 100*nOffsetAbs/1280)
	Button_EctypeListItem:setPositionX(128 + 80*nOffsetX/1280)

	return true
end

function Game_EctypeList:onUpdate_LuaListView_EctypeList(Image_EctypeListItemPNL, nIndex)
	if not Image_EctypeListItemPNL then return end
	if not Image_EctypeListItemPNL:isExsit() then return end
	
	Image_EctypeListItemPNL:setTag(nIndex)
	local Obj_EctypeSub = g_EctypeListSystem:GetEctypeSubByIndex(self.nCurrentMapBaseCsvID, nIndex)
	if not Obj_EctypeSub then
		return 
	end
	
	local Button_EctypeListItem = tolua.cast(Image_EctypeListItemPNL:getChildByName("Button_EctypeListItem"), "Button")
	local Label_EctypeName = tolua.cast(Button_EctypeListItem:getChildByName("Label_EctypeName"), "Label")
	Label_EctypeName:setText(Obj_EctypeSub:GetEctypeName())

	--模型父节点
	local Panel_Card = Button_EctypeListItem:getChildByName("Panel_Card")
	local Image_Cursor = tolua.cast(Button_EctypeListItem:getChildByName("Image_Cursor"), "ImageView")
	Image_Cursor:setVisible(Obj_EctypeSub:getEctypeCsvID() == self.nCurrentEctypeCsvID)

	if Obj_EctypeSub:GetIsBossSub() == 1 then
		Button_EctypeListItem:loadTextures(getEctypeImg("ListItem_EctypeBoss"),getEctypeImg("ListItem_EctypeBoss"),getEctypeImg("ListItem_EctypeBoss"))
		Panel_Card:setPositionY(70)
		Image_Cursor:loadTexture(getEctypeImg("ListItem_EctypeBoss_Cursor"))
		g_SetBlendFuncWidget(Image_Cursor, 4)
	else
		Button_EctypeListItem:loadTextures(getEctypeImg("ListItem_EctypeNormal"),getEctypeImg("ListItem_EctypeNormal"),getEctypeImg("ListItem_EctypeNormal"))
		Panel_Card:setPositionY(62)
		Image_Cursor:loadTexture(getEctypeImg("ListItem_EctypeNormal_Cursor"))
		g_SetBlendFuncWidget(Image_Cursor, 4)
	end

	Button_EctypeListItem:setTouchEnabled(true)
	Button_EctypeListItem:setTag(nIndex)
	Button_EctypeListItem:addTouchEventListener(handler(self, self.onClick_Image_Card))

	local AtlasLabel_StarRecord = tolua.cast(Button_EctypeListItem:getChildByName("AtlasLabel_StarRecord"), "LabelAtlas")
	AtlasLabel_StarRecord:setStringValue(Obj_EctypeSub:GetStarStringValue())

	if Obj_EctypeSub:GetActivation() == EctypeActivation._Activation then --副本已解锁
		local Image_Locker = Button_EctypeListItem:getChildByName("Image_Locker")
		Image_Locker:setVisible(false)
		
		local strSpineFile = Obj_EctypeSub:GetSpineFile()
		if strSpineFile and strSpineFile ~= "" then
			Panel_Card:setVisible(true)
			
			local Panel_Card = tolua.cast(Button_EctypeListItem:getChildByName("Panel_Card"), "Layout") 
			local CCNode_Skeleton = g_CocosSpineAnimation(strSpineFile, 1)
			local Image_Card = tolua.cast(Panel_Card:getChildByName("Image_Card"), "ImageView") 
			Image_Card:removeAllNodes()
			Image_Card:loadTexture(getUIImg("Blank"))
			Image_Card:setPositionXY(Obj_EctypeSub:GetSpinFilePosX()*Panel_Card:getScale()/0.6, Obj_EctypeSub:GetSpinFilePosY()*Panel_Card:getScale()/0.6)
			Image_Card:setSize(CCSize(Obj_EctypeSub:GetSpinFileWidth(), Obj_EctypeSub:GetSpinFileHeight()))
			Image_Card:addNode(CCNode_Skeleton)
			Image_Card:setTouchEnabled(true)
			Image_Card:setTag(nIndex)
			Image_Card:addTouchEventListener(handler(self, self.onClick_Image_Card))
			g_runSpineAnimation(CCNode_Skeleton, "idle", true)
		end
	else
		local Image_Locker = Button_EctypeListItem:getChildByName("Image_Locker")
		Image_Locker:setVisible(true)
		Panel_Card:setVisible(false)
	end
end


function Game_EctypeList:onAdjust_LuaListView_EctypeList(Image_EctypeListItemPNL, nIndex, ListView_EctypeList)
	local Obj_EctypeSub = g_EctypeListSystem:GetEctypeSubByIndex(self.nCurrentMapBaseCsvID, nIndex)
	if not Obj_EctypeSub then return end
	
	if self.Image_Cursor and self.Image_Cursor:isExsit() then
		self.Image_Cursor:setVisible(false)
	end
	
	local Button_EctypeListItem = tolua.cast(Image_EctypeListItemPNL:getChildByName("Button_EctypeListItem"), "Button")
	local Image_Cursor = tolua.cast(Button_EctypeListItem:getChildByName("Image_Cursor"), "ImageView")
	Image_Cursor:setVisible(true)
	self.Image_Cursor = Image_Cursor

	--刷新进入战斗按钮
	self.Button_SelectGameLevel:setTouchEnabled(Obj_EctypeSub:GetActivation() == EctypeActivation._Activation)
	g_SetBtnBright(self.Button_SelectGameLevel, Obj_EctypeSub:GetActivation() == EctypeActivation._Activation)
end

function Game_EctypeList:onAdjustOver_LuaListView_EctypeList(Image_EctypeListItemPNL, nIndex)
	if self.nLastAdjustListOverIndex and self.nLastAdjustListOverIndex == nIndex then	--最终校准的时候会触发多次回调，所以要判断
		return
	end
	
	local Obj_EctypeSub = g_EctypeListSystem:GetEctypeSubByIndex(self.nCurrentMapBaseCsvID, nIndex)
	if not Obj_EctypeSub then return end

	self.nCurrentCursorIndex = nIndex
	self.nCurrentEctypeCsvID = Obj_EctypeSub:getEctypeCsvID()
	self.LuaListView_DropItem:updateItems(Obj_EctypeSub:GetRewardCountAll())
	self.nLastAdjustListOverIndex = nIndex
end

function Game_EctypeList:onClick_Image_Card(pSender, eventType)
	if eventType == ccs.TouchEventType.ended then
		local nIndex = pSender:getTag()
		local Obj_EctypeSub = g_EctypeListSystem:GetEctypeSubByIndex(self.nCurrentMapBaseCsvID, nIndex)
		if not Obj_EctypeSub then return end

		self.nCurrentCursorIndex = nIndex
		self.nCurrentEctypeCsvID = Obj_EctypeSub:getEctypeCsvID()
		self.LuaListView_EctypeList:scrollToTop()
	end
end

local function onClick_DropItemModel(pSender, nIndex)
	local wndInstance = g_WndMgr:getWnd("Game_EctypeList")
	if wndInstance then
		local Obj_EctypeSub = g_EctypeListSystem:GetEctypeSuyBySubID(wndInstance.nCurrentMapBaseCsvID, wndInstance.nCurrentEctypeCsvID)
		if Obj_EctypeSub == nil then
			return
		end
		local CSV_DropItem = Obj_EctypeSub:GetRewardItemByIndex(nIndex)
		if CSV_DropItem == nil then
			return
		end
		g_ShowDropItemTip(CSV_DropItem)
	end
end

function Game_EctypeList:onUpdate_LuaListView_DropItem(Panel_DropItem, nIndex)
	local Obj_EctypeSub = g_EctypeListSystem:GetEctypeSuyBySubID(self.nCurrentMapBaseCsvID, self.nCurrentEctypeCsvID)
	if Obj_EctypeSub == nil then
		return
	end
	
	local CSV_DropItem = Obj_EctypeSub:GetRewardItemByIndex(nIndex)
	if CSV_DropItem == nil then
		return
	end
	
	Panel_DropItem:removeAllChildren()
	local itemModel = g_CloneDropItemModel(CSV_DropItem)
	if itemModel then
		itemModel:setPositionXY(58,65)
		itemModel:setScale(0.9)
		Panel_DropItem:addChild(itemModel)
		g_SetBtnWithEvent(itemModel, nIndex, onClick_DropItemModel, true)
	end
end

local function showGame_SelectGameLevel(pSender, nTag)
	-- 第一个地图处于引导中，跳过选择关卡难度界面
	local wndInstance = g_WndMgr:getWnd("Game_EctypeList")
	if wndInstance then
		if wndInstance.nCurrentMapBaseCsvID == 1 and g_PlayerGuide:checkIsInGuide() then
			local CSV_MapEctype = g_DataMgr:getMapEctypeCsv(wndInstance.nCurrentEctypeCsvID)
			if(CSV_MapEctype.NeedEnergy > g_Hero:getEnergy() )then
				g_ClientMsgTips:showMsgConfirm(_T("您的体力不足, 请稍后再试。"))
				return
			end
			
			if (CSV_MapEctype.OpenLevel > g_Hero:getMasterCardLevel()) then
				g_ClientMsgTips:showMsgConfirm(string.format(_T("您需要%d级才能挑战该副本"), CSV_MapEctype.OpenLevel))
				return
			end

			local tbStar = g_Hero:getEctypePassStar(CSV_MapEctype.EctypeID)
			
			g_VIPBase:setCommonEncryptid(wndInstance.nCurrentEctypeCsvID)
			local VIPNum = g_VIPBase:getAddTableByNum(VipType.VIP_TYPE_COMMON_ENCRYPT)
			local maxFightNum = CSV_MapEctype.MaxFightNums + VIPNum
			
			if tbStar and maxFightNum <= tbStar.attack_num then
				g_ClientMsgTips:showMsgConfirm(string.format(_T("您挑战次数已满")))
				return
			end
			
--			if(bSendBattleFlag)then
--				return
--			end
			
			local nSubEctypeID = CSV_MapEctype.SubEctype1
			local CSV_MapEctypeSub = g_DataMgr:getMapEctypeSubCsv(nSubEctypeID)
			
			if( g_Hero:getDialogTalkID() < nSubEctypeID)then --说明未对话
				g_Hero:setDialogTalkID(CSV_MapEctypeSub.DialogueID )
			else
				g_Hero:setDialogTalkID(nil)
			end
			
			
			g_MsgMgr:requestBattleInfo(nSubEctypeID)

			bSendBattleFlag = true
			local function resetBattleFlag()
				bSendBattleFlag = nil
			end
			g_Timer:pushTimer(1, resetBattleFlag)
		else
			local tbParam = {
				nMapCsvID = wndInstance.nCurrentMapBaseCsvID,
				nEctypeCsvID = wndInstance.nCurrentEctypeCsvID,
			}
			local mapId = wndInstance.nCurrentMapBaseCsvID
			
			if mapId >= 3 then 
				g_WndMgr:showWnd("Game_SelectGameLevel3", tbParam)
			elseif mapId == 1 then 
				local strClassName = "Game_SelectGameLevel"..mapId
				g_WndMgr:showWnd(strClassName, tbParam)
			elseif mapId == 2 then 
				local strClassName = "Game_SelectGameLevel"..mapId
				g_WndMgr:showWnd(strClassName, tbParam)
			end
			widgetClick = Image_EctypeListItemPNL
		end
	end
end

function Game_EctypeList:refreshRewordBox()
	local Obj_EctypeSub = g_EctypeListSystem:GetEctypeSuyBySubID(self.nCurrentMapBaseCsvID, self.nCurrentEctypeCsvID)
	if Obj_EctypeSub ~= nil then
		local Image_CollectBasePNL = tolua.cast(self.rootWidget:getChildByName("Image_CollectBasePNL"), "ImageView")
		ProgressBar_CollectProgress = tolua.cast(Image_CollectBasePNL:getChildByName("ProgressBar_CollectProgress"), "LoadingBar")
		
		local nPercent = (g_EctypeListSystem:GetCurEctypeStarNum(self.nCurrentMapBaseCsvID)/g_EctypeListSystem:GetEctypMaxStarNum(self.nCurrentMapBaseCsvID))*100
		ProgressBar_CollectProgress:setPercent(nPercent)

		--设置每个宝箱需要的星星数
		Label_NeedStarRecord_L:setText(g_EctypeListSystem:GetNeedStarRecord(self.nCurrentMapBaseCsvID, Label_NeedStarRecord_L:getTag()))
		Label_NeedStarRecord_M:setText(g_EctypeListSystem:GetNeedStarRecord(self.nCurrentMapBaseCsvID, Label_NeedStarRecord_M:getTag()))
		Label_NeedStarRecord_R:setText(g_EctypeListSystem:GetNeedStarRecord(self.nCurrentMapBaseCsvID, Label_NeedStarRecord_R:getTag()))
	
		
		Label_StarCollectNum:setText(g_EctypeListSystem:GetCurEctypeStarNum(self.nCurrentMapBaseCsvID))
		Label_StarCollectNumMax:setText(string.format("/%d", g_EctypeListSystem:GetEctypMaxStarNum(self.nCurrentMapBaseCsvID)))
		
		local nBoxRewardState1 = g_EctypeListSystem:GetBoxRewardStatusByIndex(self.nCurrentMapBaseCsvID, EctypeBoxReward._Left)
		self:SetBtnEnable(Button_Chest_L, nBoxRewardState1 == RewardBoxStatus._CanObtainHasObtain)
		local widgetParentBox_L = Button_Chest_L:getParent()
		widgetParentBox_L:removeAllNodes()
		if nBoxRewardState1 == RewardBoxStatus._CanObtainNotObtain then	
			local armature, userAnimation = g_CreateCoCosAnimationWithCallBacks("FunctionStarEffect", nil, nil, 2, nil, true)
			armature:setPositionXY(0, 0)
			armature:setScale(1.2)
			widgetParentBox_L:addNode(armature, 100)
			userAnimation:playWithIndex(0)
		end
		
		local nBoxRewardState2 = g_EctypeListSystem:GetBoxRewardStatusByIndex(self.nCurrentMapBaseCsvID, EctypeBoxReward._Middle)
		self:SetBtnEnable(Button_Chest_M, nBoxRewardState2 == RewardBoxStatus._CanObtainHasObtain)
		local widgetParentBox_M = Button_Chest_M:getParent()
		widgetParentBox_M:removeAllNodes()
		if nBoxRewardState2 == RewardBoxStatus._CanObtainNotObtain then
			local armature, userAnimation = g_CreateCoCosAnimationWithCallBacks("FunctionStarEffect", nil, nil, 2, nil, true)
			armature:setPositionXY(0, 0)
			armature:setScale(1.2)
			widgetParentBox_M:addNode(armature, 100)
			userAnimation:playWithIndex(0)
		end
		
		local nBoxRewardState3 = g_EctypeListSystem:GetBoxRewardStatusByIndex(self.nCurrentMapBaseCsvID, EctypeBoxReward._Right)
		self:SetBtnEnable(Button_Chest_R, nBoxRewardState3 == RewardBoxStatus._CanObtainHasObtain)
		local widgetParentBox_R = Button_Chest_R:getParent()
		widgetParentBox_R:removeAllNodes()
		if nBoxRewardState3 == RewardBoxStatus._CanObtainNotObtain then	
			local armature, userAnimation = g_CreateCoCosAnimationWithCallBacks("FunctionStarEffect", nil, nil, 2, nil, true)
			armature:setPositionXY(0, 0)
			armature:setScale(1.2)
			widgetParentBox_R:addNode(armature, 100)
			userAnimation:playWithIndex(0)
		end
	end
end

function Game_EctypeList:SetBtnEnable(btn, bHasGetReward)
	local child = tolua.cast(btn:getChildByName("Image_Check"), "ImageView")
	if bHasGetReward then
		btn:loadTextureNormal(getEctypeImg("Btn_ChestOpen"..btn:getTag()))
		btn:loadTexturePressed(getEctypeImg("Btn_ChestOpen"..btn:getTag()))
		btn:loadTextureDisabled(getEctypeImg("Btn_ChestOpen"..btn:getTag()))
		child:loadTexture(getEctypeImg("Btn_ChestOpen"..btn:getTag()))
	else
		btn:loadTextureNormal(getEctypeImg("Btn_ChestLock"..btn:getTag()))
		btn:loadTexturePressed(getEctypeImg("Btn_ChestLock"..btn:getTag()))
		btn:loadTextureDisabled(getEctypeImg("Btn_ChestLock"..btn:getTag()))
		child:loadTexture(getEctypeImg("Btn_ChestLock"..btn:getTag()))
	end
end

local function onClick_Button_Chest(pSender, nTag)
	local wndInstance = g_WndMgr:getWnd("Game_EctypeList")
	if wndInstance then
		local nBoxRewardState = g_EctypeListSystem:GetBoxRewardStatusByIndex(wndInstance.nCurrentMapBaseCsvID, nTag)
		if nBoxRewardState == RewardBoxStatus._CanObtainNotObtain then
			--预加载窗口缓存防止卡顿
			g_WndMgr:getFormtbRootWidget("Game_RewardBox")
			g_EctypeListSystem:RequestGetStarRewardBox(wndInstance.nCurrentMapBaseCsvID, nTag)
		elseif nBoxRewardState == RewardBoxStatus._CanObtainHasObtain then
			local tbData = {
				nRewardStatus = Game_RewardBox_Status._HasObtain,
				tbParamentList = g_EctypeListSystem:GetBoxRewardBoxDropListByIndex(wndInstance.nCurrentMapBaseCsvID, nTag),
				updateHeroResourceInfo = nil,
			}
			g_WndMgr:showWnd("Game_RewardBox", tbData)
		elseif nBoxRewardState == RewardBoxStatus._CanNotObtain then
			local tbData = {
				nRewardStatus = Game_RewardBox_Status._CanNotObtain,
				tbParamentList = g_EctypeListSystem:GetBoxRewardBoxDropListByIndex(wndInstance.nCurrentMapBaseCsvID, nTag),
				updateHeroResourceInfo = nil,
			}
			g_WndMgr:showWnd("Game_RewardBox", tbData)
		end
	end
end

function Game_EctypeList:refreshWndFromBattle()
	--防止报错
	if not self.nCurrentEctypeCsvID or
	   not self.nCurrentCursorIndex or 
	   not self.nCurrentMapBaseCsvID then
		return 
	end

	-- cclog("===============refreshWndFromBattle===================")
	self.Image_Cursor = nil
	
	local nFinalClearEctypeID = g_Hero:getFinalClearEctypeID()
	-- cclog("===============nFinalClearEctypeID==================="..tostring(nFinalClearEctypeID))
	-- cclog("===============self.nCurrentEctypeCsvID==================="..tostring(self.nCurrentEctypeCsvID))
	-- cclog("===============self.nCurrentCursorIndex==================="..tostring(self.nCurrentCursorIndex))

	if tostring(self.nCurrentEctypeCsvID) == tostring(nFinalClearEctypeID) then -- 说明上一次打的是最新开放的副本	
		local nNewCursorIndex = g_EctypeListSystem:GetEctypeCursorIndex(self.nCurrentMapBaseCsvID)
		local Obj_EctypeSub = g_EctypeListSystem:GetEctypeSubByIndex(self.nCurrentMapBaseCsvID, nNewCursorIndex)
		if not Obj_EctypeSub then return end

		self.nCurrentEctypeCsvID = Obj_EctypeSub:getEctypeCsvID()
		self.nCurrentCursorIndex = nNewCursorIndex
		
		self.LuaListView_EctypeList:updateItems(g_EctypeListSystem:GetEctypeNum(self.nCurrentMapBaseCsvID), nNewCursorIndex)
		self:onAdjustOver_LuaListView_EctypeList(nil, nNewCursorIndex)
	else
		self.LuaListView_EctypeList:updateItems(g_EctypeListSystem:GetEctypeNum(self.nCurrentMapBaseCsvID), self.nCurrentCursorIndex)
		self:onAdjustOver_LuaListView_EctypeList(nil, self.nCurrentCursorIndex)
	end
	
	self:refreshRewordBox()

	if g_Hero.nPlayerGuideId and g_Hero.nPlayerGuideId > g_nForceGuideMaxID then
		if not g_PlayerGuide:checkIsInGuide() then
			local nGuideID, nGuideIndex = g_PlayerGuide:showNextEctypeGuide2(self.nCurrentMapBaseCsvID)
			if nGuideID > 0 and nGuideIndex > 0 then
				if g_PlayerGuide:setCurrentGuideSequence(nGuideID, nGuideIndex) then
					g_PlayerGuide:showCurrentGuideSequenceNode()
				end
			end
		end
	end
end

--选择游戏副本列表
--初始化普通副本界面	
function Game_EctypeList:initWnd()
	self.Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	
	local Image_EctypeListPNL = tolua.cast(self.rootWidget:getChildByName("Image_EctypeListPNL"), "ImageView")
	
	-- 风险代码
    local ListView_EctypeList = tolua.cast(Image_EctypeListPNL:getChildByName("ListView_EctypeList"), "ListViewEx")
	-- 风险代码
	
	self.LuaListView_EctypeList = Class_LuaListView:new()
	
	-- 风险代码
	self.LuaListView_EctypeList:setListView(ListView_EctypeList)
	-- 风险代码
	
    local Image_EctypeListItemPNL = ListView_EctypeList:getChildByName("Image_EctypeListItemPNL")
	
	-- 风险代码
	self.LuaListView_EctypeList:setModel(Image_EctypeListItemPNL)
	-- 风险代码
	
    self.LuaListView_EctypeList:setScrollingFunc(handler(self, self.onScrolling_LuaListView_EctypeList))
	self.LuaListView_EctypeList:setUpdateFunc(handler(self, self.onUpdate_LuaListView_EctypeList))
	self.LuaListView_EctypeList:setAdjustFunc(handler(self, self.onAdjust_LuaListView_EctypeList))
	self.LuaListView_EctypeList:setAdjustOverFunc(handler(self, self.onAdjustOver_LuaListView_EctypeList))
	
    self.LuaListView_DropItem = Class_LuaListView:new()
    local ListView_DropItem = tolua.cast(self.rootWidget:getChildByName("ListView_DropItem"), "ListViewEx")
	
	-- 风险代码
    self.LuaListView_DropItem:setListView(ListView_DropItem)
	-- 风险代码
	
    local Panel_DropItem = ListView_DropItem:getChildByName("Panel_DropItem")
	
	-- 风险代码
	self.LuaListView_DropItem:setModel(Panel_DropItem)
	-- 风险代码
	
	self.LuaListView_DropItem:setUpdateFunc(handler(self, self.onUpdate_LuaListView_DropItem))

	self.Button_SelectGameLevel = tolua.cast(self.rootWidget:getChildByName("Button_SelectGameLevel"), "Button")
	g_SetBtnWithGuideCheck(self.Button_SelectGameLevel, nil, showGame_SelectGameLevel, true, nil, nil, true)
	
	local Image_CollectBasePNL = tolua.cast(self.rootWidget:getChildByName("Image_CollectBasePNL"), "ImageView")
	ProgressBar_CollectProgress = tolua.cast(Image_CollectBasePNL:getChildByName("ProgressBar_CollectProgress"), "LoadingBar")
	
	local Image_Chest1 = Image_CollectBasePNL:getChildByName("Image_Chest1")
	Button_Chest_L = tolua.cast(Image_Chest1:getChildByName("Button_Chest"), "Button")
	g_SetBtnWithPressImage(Button_Chest_L, EctypeBoxReward._Left, onClick_Button_Chest, true, 1)

	local Image_Chest2 = Image_CollectBasePNL:getChildByName("Image_Chest2")
	Button_Chest_M = tolua.cast(Image_Chest2:getChildByName("Button_Chest"), "Button")
	g_SetBtnWithPressImage(Button_Chest_M, EctypeBoxReward._Middle, onClick_Button_Chest, true, 1)

	local Image_Chest3 = Image_CollectBasePNL:getChildByName("Image_Chest3")		
	Button_Chest_R = tolua.cast(Image_Chest3:getChildByName("Button_Chest"), "Button")
	g_SetBtnWithPressImage(Button_Chest_R, EctypeBoxReward._Right, onClick_Button_Chest, true, 1)


	Label_NeedStarRecord_L = tolua.cast(Button_Chest_L:getChildByName("Label_NeedStarRecord"), "Label")
	Label_NeedStarRecord_L:setTag(EctypeBoxReward._Left)

	Label_NeedStarRecord_M = tolua.cast(Button_Chest_M:getChildByName("Label_NeedStarRecord"), "Label")
	Label_NeedStarRecord_M:setTag(EctypeBoxReward._Middle)

	Label_NeedStarRecord_R = tolua.cast(Button_Chest_R:getChildByName("Label_NeedStarRecord"), "Label")
	Label_NeedStarRecord_R:setTag(EctypeBoxReward._Right)

	Label_StarCollectNum = tolua.cast(Image_CollectBasePNL:getChildByName("Label_StarCollectNum"), "Label") 			

	Label_StarCollectNumMax = tolua.cast(Label_StarCollectNum:getChildByName("Label_StarCollectNumMax"), "Label") 

	local ImageArrow = tolua.cast(self.rootWidget:getChildByName("Image_Arrow"), "ImageView")
	g_CreateUpAndDownAnimation(ImageArrow)

	--注册界面消息
 	g_FormMsgSystem:RegisterFormMsg(FormMsg_EctypeForm_GetStarRewardBox_SUC, handler(self, self.refreshRewordBox))--成功领取星级礼包
 	g_FormMsgSystem:RegisterFormMsg(FormMsg_EctypeForm_UpdateEctypeStarNum, handler(self, self.refreshRewordBox))--星星有变动 要更新
end

function Game_EctypeList:openWnd(nMapBaseCsvID)
	if self.nCurrentMapBaseCsvID then 
		--更新最新星星数 
		g_MapInfo:setMapIdStarNum(self.nCurrentMapBaseCsvID, g_EctypeListSystem:GetCurEctypeStarNum(self.nCurrentMapBaseCsvID))
	end
	
	if g_bReturn then
		return
	end
	
	if nMapBaseCsvID then 
		self.nCurrentMapBaseCsvID = nMapBaseCsvID or 0
	end
	
	bSendBattleFlag = nil
	
	--构造地图数据
	g_EctypeListSystem:InitEctypeInfo(nMapBaseCsvID)
	
	self.Image_Cursor = nil
	
	local nCursorIndex = g_EctypeListSystem:GetEctypeCursorIndex(self.nCurrentMapBaseCsvID)
	local Obj_EctypeSub = g_EctypeListSystem:GetEctypeSubByIndex(self.nCurrentMapBaseCsvID, nCursorIndex)
	if not Obj_EctypeSub then return end
	
	self.nCurrentCursorIndex = nCursorIndex
	self.nCurrentEctypeCsvID = Obj_EctypeSub:getEctypeCsvID()
	
	self.Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	self.Image_Background:loadTexture(getBackgroundJpgImg("Bamboo1"))
	
	local wndInstance = g_WndMgr:getWnd("Game_Ectype")
	if wndInstance then
		wndInstance.Image_World1:loadTexture(getUIImg("Blank"))
		wndInstance.Image_World2:loadTexture(getUIImg("Blank"))
		wndInstance.Image_World3:loadTexture(getUIImg("Blank"))
		wndInstance.Image_World4:loadTexture(getUIImg("Blank"))
		wndInstance.Image_World5:loadTexture(getUIImg("Blank"))
	end
	
	-- 风险代码
	self:refresh_LuaListView_EctypeList()
    self:onAdjustOver_LuaListView_EctypeList(nil, nCursorIndex)
	-- 风险代码

	self:refreshRewordBox()
end

function Game_EctypeList:closeWnd()
	self.Image_Cursor = nil
	 --注册界面消息
 	g_FormMsgSystem:UnRegistFormMsg(FormMsg_EctypeForm_GetStarRewardBox_SUC)--成功领取星级礼包
 	g_FormMsgSystem:UnRegistFormMsg(FormMsg_EctypeForm_UpdateEctypeStarNum)--星星有变动 要更新

	self.Image_Background:loadTexture(getUIImg("Blank"))
end

--通过 以前的战斗副本协议来获取数据 所以是在接受数据完成后才通过PostMsg来处理事件的。
function Game_EctypeList:refresh_LuaListView_EctypeList()
	cclog("---------------副本数据准备好了-----refresh_LuaListView_EctypeList--------------")
	-- 风险代码
	self.LuaListView_EctypeList:updateItems(g_EctypeListSystem:GetEctypeNum(self.nCurrentMapBaseCsvID), g_EctypeListSystem:GetEctypeCursorIndex(self.nCurrentMapBaseCsvID))
	-- 风险代码
end

function Game_EctypeList:getCurChallengeMapID()
	return self.nCurrentMapBaseCsvID
end