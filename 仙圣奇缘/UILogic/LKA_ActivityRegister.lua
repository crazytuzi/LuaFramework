--------------------------------------------------------------------------------------
-- 文件名: LKA_ActivityRegister.lua
-- 版  权:    (C)深圳美天互动科技有限公司
-- 创建人: 		陆奎安
-- 日  期:    2014-4-5 9:37
-- 版  本:    1.0
-- 描  述:    签到界面
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------

Game_Registration1 = class("Game_Registration1")
Game_Registration1.__index = Game_Registration1
local HNumber = 5
local curItem = nil
function Game_Registration1:ShowQianDaoAnimation(widgetParent)
	local function HideQianDaoMask()
		local Image_Check = tolua.cast(widgetParent:getChildByName("Image_Check"), "ImageView")
		local actionFadeTo_Check = CCFadeTo:create(0.5, 0)
		Image_Check:runAction(actionFadeTo_Check)
		
		local Image_Mask = tolua.cast(widgetParent:getChildByName("Image_Mask"), "ImageView")
		local actionFadeTo_Mask = CCFadeTo:create(0.5, 255)
		Image_Mask:runAction(actionFadeTo_Mask)
		
		local Image_RewardIconBase = tolua.cast(widgetParent:getChildByName("Image_RewardIconBase"), "ImageView")
		Image_RewardIconBase:setCascadeOpacityEnabled(true)
		local actionFadeTo_IconBase = CCFadeTo:create(0.5, 0)
		Image_RewardIconBase:runAction(actionFadeTo_IconBase)
	end
	local function ShowQianDaoSymbol()
		local Image_StatusSymbol = tolua.cast(widgetParent:getChildByName("Image_StatusSymbol"), "ImageView")
		Image_StatusSymbol:setVisible(true)
		g_SetBtnEnable(widgetParent, false)
		local Image_Mask = tolua.cast(widgetParent:getChildByName("Image_Mask"), "ImageView")
		Image_Mask:setVisible(false)
	end
	local tbQianDaoFrameCall = {
		HideQianDaoMask = HideQianDaoMask
	}
	local armature, animation = g_CreateCoCosAnimationWithCallBacks("QianDao", tbQianDaoFrameCall, ShowQianDaoSymbol, 2)
	armature:setPositionXY(0,0)
	widgetParent:addNode(armature,100)
	animation:playWithIndex(0)
end

function Game_Registration1:SignInResponse()
	Game_Registration1:ShowQianDaoAnimation(curItem)
    self:setLabelCount(g_Hero:getSignUpTimes())
	local TimesFul = g_Hero:getSignDateStatus()
	if TimesFul == 0 then
		local Image_RegistrationPNL = tolua.cast(self.rootWidget:getChildByName("Image_RegistrationPNL"), "ImageView")
		local Image_ContentPNL = tolua.cast(Image_RegistrationPNL:getChildByName("Image_ContentPNL"), "ImageView")
		local Button_QianDao = tolua.cast(Image_ContentPNL:getChildByName("Button_QianDao"), "Button")
		Button_QianDao:setTouchEnabled(true)
		Button_QianDao:setBright(false)
	end
	if g_PlayerGuide:checkCurrentGuideSequenceNode("ServerResponse", "Game_Registration1") then
		g_PlayerGuide:showCurrentGuideSequenceNode()
	end
end

function Game_Registration1:QianDaoClick()
	local TimesFul = g_Hero:getSignDateStatus()
	if TimesFul == 0 then
		g_ClientMsgTips:showMsgConfirm("您今天已经签过了")
		return
	end
	--预加载窗口缓存防止卡顿
	g_WndMgr:getFormtbRootWidget("Game_RewardMsgConfirm")
	g_MsgMgr:requestSignIn()
end

function Game_Registration1:setListViewItem(Panel_DailyReward, nIndex)
	local startIndex =  (nIndex-1)*HNumber
    local sys_monthDay = self:getSysMonthDayNum()
	--签到
	--弹出tip
	local function onClickTipItem(pSender,nTag)
        local drop_config = "DropPackClientID"..sys_monthDay.month
		local DropPackClientID = g_DataMgr:getActivityRegisterCsv(nTag)[drop_config]
		local CSV_DropItem = g_GetDropSubPackClientItemDataByID(DropPackClientID)
		g_ShowDropItemTip(CSV_DropItem)
	end
	for i = 1,HNumber do
		local dayNums = 30 --固定每月为30天
		local nIndex= startIndex + i
		
		if nIndex <= dayNums then 
			local Button_DailyRewardsItem = Panel_DailyReward:getChildByName("Button_DailyRewardsItem"..i)
			if Button_DailyRewardsItem then
				Button_DailyRewardsItem:setVisible(true)
			else
				Button_DailyRewardsItem = g_WidgetModel.Button_DailyRewardsItem:clone()
				Button_DailyRewardsItem:setName("Button_DailyRewardsItem"..i)
				Panel_DailyReward:addChild(Button_DailyRewardsItem)
			end
			Button_DailyRewardsItem:setTag(nIndex)
			Button_DailyRewardsItem:setVisible(true)
			Button_DailyRewardsItem:setPosition(ccp(-78 + 152*i,76))
			
			local Image_Check = tolua.cast(Button_DailyRewardsItem:getChildByName("Image_Check"), "ImageView")
			Image_Check:setOpacity(255)
			Image_Check:setVisible(false)
			local Image_Mask = tolua.cast(Button_DailyRewardsItem:getChildByName("Image_Mask"), "ImageView")
			Image_Mask:setVisible(false)
			Image_Mask:setOpacity(0)
			local Image_StatusSymbol = tolua.cast(Button_DailyRewardsItem:getChildByName("Image_StatusSymbol"), "ImageView")
			local Image_RewardIconBase = tolua.cast(Button_DailyRewardsItem:getChildByName("Image_RewardIconBase"), "ImageView")
			local times = g_Hero:getSignUpTimes()
			
			Button_DailyRewardsItem:removeAllNodes()
			local CSV_ActivityRegister = g_DataMgr:getActivityRegisterCsv(nIndex)
			if CSV_ActivityRegister.IsShowAnimation == 1 then
				local armature, userAnimation = g_CreateCoCosAnimationWithCallBacks("FunctionStarEffect", nil, nil, 2)
				armature:setPositionXY(0, 0)
				armature:setScale(1.2)
				Button_DailyRewardsItem:addNode(armature, 100)
				userAnimation:playWithIndex(0)
			end
			
			if nIndex <= times then	
				Image_StatusSymbol:setVisible(true)
				Image_RewardIconBase:setVisible(false)
				Image_Mask:setVisible(false)
				Image_Check:setVisible(false)
				g_SetBtnEnable(Button_DailyRewardsItem, false)
			else
				Image_StatusSymbol:setVisible(false)
				Image_RewardIconBase:setVisible(true)
                local drop_config = "DropPackClientID"..sys_monthDay.month
				local DropPackClientID = CSV_ActivityRegister[drop_config]
				local CSV_DropItem = g_GetDropSubPackClientItemDataByID(DropPackClientID)
			
				if not CSV_DropItem then return end
				local itemModel = g_CloneDropItemModel(CSV_DropItem)
				if itemModel then
					local ItemIcon = Image_RewardIconBase:getChildByName("ItemIcon")
					if ItemIcon then
						ItemIcon:removeFromParentAndCleanup(true)
					end
					Image_RewardIconBase:addChild(itemModel,10)
					itemModel:setName("ItemIcon")
					itemModel:setVisible(true)
					itemModel:setPosition(ccp(0,0))
				end
				if nIndex == (times + 1) then
					local TimesFul = g_Hero:getSignDateStatus()
					if TimesFul == 0 then
						Image_Check:setVisible(false)
						Image_Mask:setVisible(false)
					else
						Image_Check:setVisible(true)
						Image_Mask:setVisible(true)
						local ccSprite = tolua.cast(Image_Check:getVirtualRenderer(),"CCSprite")
						g_SetBlendFuncSprite(ccSprite, 4)
					end
					curItem = Button_DailyRewardsItem
				else
					Image_Check:setVisible(false)
					Image_Mask:setVisible(false)
				end
				g_SetBtnWithEvent(Button_DailyRewardsItem, nIndex, onClickTipItem, true)
			end 
		else --这个月没有这天 隐藏
			local Button_DailyRewardsItem = Panel_DailyReward:getChildByName("Button_DailyRewardsItem"..i)
			if Button_DailyRewardsItem then
				Button_DailyRewardsItem:setVisible(false)
			end
		end
	end
end

function Game_Registration1:getSysMonthDayNum()
    --获取今天是系统当前月的第几天
    local sys_totaldays = g_Hero:getTotalSysDays()
    self.sysTotalTime.day = (sys_totaldays-1) % 30 + 1
    self.sysTotalTime.month = math.floor((sys_totaldays - 1) / 30) % 12 + 1
    return self.sysTotalTime 
end

------------initListViewListEx---------
function Game_Registration1:registerListViewEvent(ListView_DailyRewards, Panel_DailyReward)
    local LuaListView_DailyRewards = Class_LuaListView:new()
    LuaListView_DailyRewards:setListView(ListView_DailyRewards)
    local function updateFunction(Panel_DailyReward, nIndex)
		Panel_DailyReward:setName("Panel_DailyReward"..nIndex)
		self:setListViewItem(Panel_DailyReward, nIndex)
    end
    LuaListView_DailyRewards:setUpdateFunc(updateFunction)
    LuaListView_DailyRewards:setModel(Panel_DailyReward)
    self.LuaListView_DailyRewards = LuaListView_DailyRewards
end

function Game_Registration1:initARegisterWnd()
	local Image_RegistrationPNL = tolua.cast(self.rootWidget:getChildByName("Image_RegistrationPNL"), "ImageView")
	local Image_ContentPNL = tolua.cast(Image_RegistrationPNL:getChildByName("Image_ContentPNL"), "ImageView")
	local ListView_DailyRewards = tolua.cast(Image_ContentPNL:getChildByName("ListView_DailyRewards"), "ListViewEx")
	local Panel_DailyReward = Layout:create()
	Panel_DailyReward:setSize(CCSizeMake(760,152))
	self:registerListViewEvent(ListView_DailyRewards, Panel_DailyReward)
	
	local imgScrollSlider = ListView_DailyRewards:getScrollSlider()
	if not g_tbScrollSliderXY.ListView_DailyRewards_X then
		g_tbScrollSliderXY.ListView_DailyRewards_X = imgScrollSlider:getPositionX()
	end
	imgScrollSlider = imgScrollSlider:setPositionX(g_tbScrollSliderXY.ListView_DailyRewards_X + 7)
end

function Game_Registration1:setLabelCount(signUptimes)
    --设置签到次数
    local strTip = string.format(_T("本轮已累计签到%d次, %d天后进入下一轮"), signUptimes, 31 - self:getSysMonthDayNum().day)
    self.Label_Count:setText(strTip)
end

function Game_Registration1:updateItems(nNum)
	local times = g_Hero:getSignUpTimes()
	local heightIndex = math.ceil(times/5)
	local maxheightIndex = math.ceil(self.dayNums/5)
	if heightIndex  >= maxheightIndex -2 then
		heightIndex = maxheightIndex -2
	end
	self.LuaListView_DailyRewards:updateItems(nNum,heightIndex)
end

function Game_Registration1:initWnd()
	self:initARegisterWnd()
	local function onClickQianDao(pSender, nTag)
		self:QianDaoClick()
	end
	local Image_RegistrationPNL = tolua.cast(self.rootWidget:getChildByName("Image_RegistrationPNL"), "ImageView")
	local Image_ContentPNL = tolua.cast(Image_RegistrationPNL:getChildByName("Image_ContentPNL"), "ImageView")
	local Button_QianDao = tolua.cast(Image_ContentPNL:getChildByName("Button_QianDao"), "Button")
	g_SetBtnWithGuideCheck(Button_QianDao, nil, onClickQianDao, true)

    local Image_LabelPNL = tolua.cast(Image_ContentPNL:getChildByName("Image_LabelPNL"), "ImageView")
	local Label_Count = tolua.cast(Image_LabelPNL:getChildByName("Label_Count"), "Label")
	self.Label_Count = Label_Count
    self.sysTotalTime = {}
end

function Game_Registration1:checkData()
	if not g_Hero.tabSignInInfo then
		g_MsgMgr:requestSignInRefresh()
		return false 
	end
	return true
end

--打开界面调用
function Game_Registration1:openWnd()
    if g_bReturn  then  return  end
	local dayNums = 30 --每个月固定30天
	self.dayNums = dayNums
    local nNum =	math.ceil(dayNums/HNumber)
	local TimesFul = g_Hero:getSignDateStatus()
	if TimesFul == 0 then
		local Image_RegistrationPNL = tolua.cast(self.rootWidget:getChildByName("Image_RegistrationPNL"), "ImageView")
		local Image_ContentPNL = tolua.cast(Image_RegistrationPNL:getChildByName("Image_ContentPNL"), "ImageView")
		local Button_QianDao = tolua.cast(Image_ContentPNL:getChildByName("Button_QianDao"), "Button")
		Button_QianDao:setTouchEnabled(true)
		Button_QianDao:setBright(false)
	end
	self:updateItems(nNum)
	self:setLabelCount(g_Hero:getSignUpTimes())
	-- if g_Hero:GetFirstOpState(macro_pb.FirstOpType_SignIn) and g_Hero:getTotalSysDays() < 20 then --是否第一次签到
		-- if g_PlayerGuide:setCurrentGuideSequence(205, 1) then
			-- g_PlayerGuide:showCurrentGuideSequenceNode()
		-- end
	-- end
end

function Game_Registration1:closeWnd()

end

function Game_Registration1:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_RegistrationPNL = tolua.cast(self.rootWidget:getChildByName("Image_RegistrationPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_RegistrationPNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
	mainWnd:showMainHomeZoomInAnimation()
end

function Game_Registration1:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_RegistrationPNL = tolua.cast(self.rootWidget:getChildByName("Image_RegistrationPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	local function actionEndCall()
		if funcWndCloseAniCall then
			funcWndCloseAniCall()
		end
		mainWnd:showMainHomeZoomOutAnimation()
	end
	g_CreateUIDisappearAnimation_Scale(Image_RegistrationPNL, actionEndCall, 1.05, 0.15, Image_Background)
end

function Game_Registration1:ModifyWnd_viet_VIET()
    
end