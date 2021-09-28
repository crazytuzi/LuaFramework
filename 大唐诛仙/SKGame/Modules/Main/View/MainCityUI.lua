MainCityUI =BaseClass(LuaUI) -- BaseView

-- Automatic code generation, don't change this function (Constructor) use .New(...)
function MainCityUI:__init( ... )
	self.URL = "ui://0042gniteg11aj";
	self.ui = UIPackage.CreateObject("Main","MainCityUI")
	local ui = self.ui
	
	self.switchMorF =ui:GetController("SwitchMorF")
	self.miniMap =ui:GetChild("MiniMap")
	self.playerInfo =ui:GetChild("PlayerInfo")
	self.playerInfoRight =ui:GetChild("PlayerInfoRight")
	self.fightControllerUI =ui:GetChild("FightController")
	self.switchBtn =ui:GetChild("SwitchBtn")
	self.functionConn =ui:GetChild("Function")
	self.monInfo =ui:GetChild("MonInfo")
	self.chatMain =ui:GetChild("chatMain")
	self.playerExpBar =ui:GetChild("PlayerExpBar")
	self.taskTeam =ui:GetChild("TaskTeam")
	self.bagBtn =ui:GetChild("BagBtn")
	self.equipStoreBtn =ui:GetChild("equipStoreBtn")
	self.decompositionBtn =ui:GetChild("decompositionBtn")

	self.activites =ui:GetChild("Activites")
	self.furnaceBtn =ui:GetChild("furnaceBtn")
	self.gangBtn =ui:GetChild("gangBtn")
	self.furnaceBtn.visible = false
	self.gangBtn.visible = false
	self.returnBtn =ui:GetChild("returnBtn")
	self.transBtn =ui:GetChild("transBtn")
	self.transBtn.visible=false

	self.pkModel =ui:GetChild("pkModel")
	self.modelSelect =ui:GetChild("modelSelect")
	self.FBFlag =ui:GetChild("FBFlag")
	self.buffContainer =ui:GetChild("buffContainer")
	self.switchBtnEffect =ui:GetTransition("SwitchBtnEffect")
	self.switchBtnEffect2 =ui:GetTransition("SwitchBtnEffect2")
	self.fightControllerEffectIn =ui:GetTransition("fightcontrollerEffectIn")
	self.functionConnIn =ui:GetTransition("functionIn")
	self.btnVipIcon =ui:GetChild("btnVipIcon")     --添加vip头像显示++++
	self.buffDescPanel =ui:GetChild("buffDescPanel")
	self.txtCutdown =ui:GetChild("txtCutdown")

	self.model = MainUIModel:GetInstance()
	VipController:GetInstance():C_GetPlayerVip()       --发送获取玩家vip信息请求
	VipController:GetInstance():C_GetDailyRewardState()--获取vip每日领取状态-----------------------------------------------------
	VipController:GetInstance():C_GetVipWelfareState()         --发送获取vip每日福利状态
	self.bagBtn.icon = "Icon/Activity/fun_1" --背包
	self.equipStoreBtn.icon = "Icon/Activity/fun_24" --装备行
	self.decompositionBtn.icon = "Icon/Activity/fun_26" --提升按钮

	StrongModel:GetInstance():GetKindLevel()
	StrongModel:GetInstance():IsRedStrong()

	self.furnaceBtn.icon = "Icon/Activity/fun_17" --熔炉按钮
	self.gangBtn.icon = "Icon/Activity/fun_27" -- 帮会

	self.autoRunTips = nil
	self.autoFightTips = nil
	self:Config()
	self:AddEvents()
	self:InitMainCitytUI()
	if not ToLuaIsNull(self.taskTeam.ui) then
		self.taskTeam.ui.sortingOrder = 10
	end
	if not ToLuaIsNull(self.chatMain.ui) then
		self.chatMain.ui.sortingOrder = 11
	end
	if not ToLuaIsNull(self.modelSelect.ui) then
		self.modelSelect.ui.sortingOrder = 12
	end
	if not ToLuaIsNull(self.buffDescPanel) then
		self.buffDescPanel.sortingOrder = 13
	end

	self:InitUIByState()
	self:InitRedTipsByCache()
	FriendController:GetInstance():C_ApplyMsgList()
	ChatNewController:GetInstance():C_GetOfflineInfo()
	WelfareController:GetInstance():StartModel()
	WingController:GetInstance():C_GetWingList()
	StyleController:GetInstance():C_GetFashionList()

	OpenGiftCtrl:GetInstance():C_BuyArtifactData()
	FirstRechargeCtrl:GetInstance():C_GetFristPayData()
	SevenLoginController:GetInstance():C_GetOpenServerData()

	self:AddEquipStoreTimer()
	ui.fairyBatching = true
end

-- Logic Starting
function MainCityUI:Config()
	self.fightControllerUI = FightControllerUI.Create(self.fightControllerUI)
	self.functionConn = FunctionConn.Create(self.functionConn)
	self.playerInfo = PlayerInfo.Create(self.playerInfo)
	self.playerInfoRight = PlayerInfoRight.Create(self.playerInfoRight)
	self.monInfo = MonsterHeadComponent.Create(self.monInfo)
	self.FBFlag = FBFlag.Create(self.FBFlag)
	self.chatMain = ChatMain.Create(self.chatMain)
	self.activites = Activites.Create(self.activites)
	self.modelSelect = PkSelect.Create(self.modelSelect)
	self.pkModel = PkModel.Create(self.pkModel)
	self.miniMap = MiniMap.Create(self.miniMap)
	self.taskTeam = TaskTeam.Create(self.taskTeam)
	
	self.monInfo.ui.visible = false


	self:CreateSkillJoystick()
	self:CreateFightUIJoystick()
	--创建自动寻路tips
	self:CreateAutoRunTips()
	self:CreateAutoFightTips()
	self:HideModelSelect()
	self.quickCellList = {}
	self.quickGoodsCellList = {}

	self:CreateHideBtn()

	--特效列表
	self.effectList = {}
	self.effectRootList = {}
	self.redTipsEffectName = "tips"
end

--创建自动寻路tips
function MainCityUI:CreateAutoRunTips()
	if not self.autoRunTips then
		self.autoRunTips = AutoRunTips.New()
	end 
	self.autoRunTips.ui.visible= false
	self.autoRunTips:AddTo(self.ui)
	self.autoRunTips:SetXY(546,500)
end

--创建自动战斗tips
function MainCityUI:CreateAutoFightTips()
	if not self.autoFightTips then 
		self.autoFightTips = AutoFightTips.New()
	end
	self.autoFightTips.ui.visible= false
	self.autoFightTips:AddTo(self.ui)
	self.autoFightTips:SetXY(546,500)
end

function MainCityUI:CreateSkillJoystick()
	local joystick = CustomJoystick.New(layerMgr.WIDTH*0.5, layerMgr.HEIGHT*0.5+150, false, true)
	joystick:SetTouchSize(280, 300)
	joystick:AddTo(self.ui)
	joystick.ui.sortingOrder=0
	self.bagBtn.sortingOrder=10
	joystick:SetVisible(false)
	
	CustomJoystick.skillJoystick = joystick
end
function MainCityUI:CreateFightUIJoystick()
	local joystick = CustomJoystick.New(106, layerMgr.HEIGHT-106, false, false)
	joystick:SetTouchSize(400, 310)
	joystick:AddTo(self.ui)
	joystick:SetVisible(true)
	CustomJoystick.mainJoystick = joystick
end

function MainCityUI:AddEvents()
	self.pkModel.smallBtn.onClick:Add(self.ShowModelSelect,self)
	self.switchBtn.onClick:Add(self.BtnSwitchHandler,self)
	self.playerInfo:GetChild("HeadIcon").onClick:Add(self.OpenPlayerInfoPanel,self)
	self.bagBtn.onClick:Add(self.OpenBag,self)
	self.equipStoreBtn.onClick:Add(self.OnEquipStoreBtnClick , self)
	self.decompositionBtn.onClick:Add(self.OnDecompositionBtnClick , self)
	self.furnaceBtn.onClick:Add(self.OnOpenFurnace , self)
	self.gangBtn.onClick:Add(self.OnOpenGang , self)

	self.returnBtn.onClick:Add(self.OnClickReturnBtn,self)
	self.transBtn.onClick:Add(self.OnTrans,self)
	self.miniMap.ui.onClick:Add(self.OnClickMiniMap,self)
	self.btnVipIcon.onClick:Add(function () --vip按钮点击_+++++++++++++++++++++
		MallController:GetInstance():OpenMallPanel(1,1)
	end,self)
	local js = CustomJoystick.mainJoystick
	js.onMove:Add(function ( e )
		GlobalDispatcher:DispatchEvent(EventName.JOYSTICK_MOVE, e.data)
	end)
	js.onEnd:Add(function ( e )
		self.ui:InvalidateBatchingState()
		GlobalDispatcher:DispatchEvent(EventName.JOYSTICK_END)
	end)

	--监听Vip等级改变
	self.vipChangeHandle = GlobalDispatcher:AddEventListener(EventName.VIPLV_CHANGE, function (lv,time,jhState,playerVipId)
		if playerVipId > 0 then
			self.btnVipIcon.icon = "Icon/Vip/vip"..playerVipId
			self.btnVipIcon.grayed = false
		else
			self.btnVipIcon.icon = "Icon/Vip/vip1"
			self.btnVipIcon.grayed = true
		end 
	end)
	self.vipLoginHandle = GlobalDispatcher:AddEventListener(EventName.GETVIPINFO_CHANGE, function (lv)
		if lv > 0 then
			self.btnVipIcon.icon = "Icon/Vip/vip"..lv
			self.btnVipIcon.grayed = false
		else
			self.btnVipIcon.icon = "Icon/Vip/vip1"
			self.btnVipIcon.grayed = true
		end 
	end)

	--监听自动寻路跑动事件
	self.handler1=GlobalDispatcher:AddEventListener(EventName.Player_AutoRun,function ()
		self:ShowAutoRunTips()
	end)
	self.handler2=GlobalDispatcher:AddEventListener(EventName.Player_AutoRunEnd,function ()
		self:HideAutoRunTips()
	end)
	self.handler4=GlobalDispatcher:AddEventListener(EventName.PkModelChange, function ()
		self:HideModelSelect()
	end)
	--监听自动寻路跑动事件
	self.handler5=GlobalDispatcher:AddEventListener(EventName.AutoFightStart, function ()
		self:ShowAutoFight()
	end)
	self.handler6=GlobalDispatcher:AddEventListener(EventName.AutoFightEnd, function ()
		self:HideAutoFight()
	end)
	self.handler7=GlobalDispatcher:AddEventListener(EventName.NEWMAIL_NOTICE, function (v)
		if self.chatMain then
			if v > 0 then
				self.chatMain:SetMailTips(true)
			else
				self.chatMain:SetMailTips(false)
			end
		end
	end)

	self.hanlder8 = self.model:AddEventListener(MainUIConst.UIStateChange, function(data)
		self:HandleUIStateChange(data)
	end)

	self.handler9 = GlobalDispatcher:AddEventListener(EventName.MAINUI_RED_TIPS, function(data)
		self:HandleRedTips(data)
	end)

	self.handler10 = self.model:AddEventListener(MainUIConst.E_QuickEquipChange, function(data)
		self:RefreshQuickList(data)
	end)

	self.handler11 = GlobalDispatcher:AddEventListener(EventName.SCENE_LOAD_FINISH, function()
		GlobalDispatcher:RemoveEventListener(self.handler11)
		self.btnVipIcon.icon = "Icon/Vip/vip1"
		self.btnVipIcon.grayed = true
		VipController:GetInstance():C_GetPlayerVip()
	end)

	self.handler12 = GlobalDispatcher:AddEventListener(EventName.RELOGIN_ROLE, function()
		self.handler11 = GlobalDispatcher:AddEventListener(EventName.SCENE_LOAD_FINISH, function()
			GlobalDispatcher:RemoveEventListener(self.handler11)
			self.btnVipIcon.icon = "Icon/Vip/vip1"
			self.btnVipIcon.grayed = true
			VipController:GetInstance():C_GetPlayerVip()
		end)
		--self:AddEquipStoreTimer()
	end)

	self.handler13 = self.model:AddEventListener(MainUIConst.E_QuickGoodsChange, function(data)
		self:RefreshQuickGoodsList(data)
	end)
	self.handler14 = GlobalDispatcher:AddEventListener(EventName.MAINROLE_DIE, function(data)
		self:HandleMainPlayerDie(data)
	end)
	self.handler15 = self.model:AddEventListener(MainUIConst.E_ShowPopStateChange, function(data)
		self:HandlePopStateChange(data)
	end)
	self.handler16 = GlobalDispatcher:AddEventListener(EventName.ENTER_DATA_INITED , function()
		WelfareController:GetInstance():StartModel()
	end)
	self.handler17 = GlobalDispatcher:AddEventListener(EventName.MAINPLAYER_UPDATE, function (key, value, pre) 
		if key == "level" then
			StrongModel:GetInstance():GetKindLevel()
			StrongModel:GetInstance():IsRedStrong()
			self:SetStrongState() --主界面提升按钮 特效状态 LLLL
		end
	end)

	self.tmpTransMsg=nil
	self.transHandler = GlobalDispatcher:AddEventListener(EventName.TRANSFERNOTICE , function(msg)
		if self.transBtn then
			self.tmpTransMsg = msg
			--iconId物品图标用于显示,toMapId传送目标地图,toPosition传送位置
			self.transBtn.visible = true
			self.transBtn.icon = "Icon/Goods/"..msg.iconId
		end
	end)
end

function MainCityUI:RemoveEvents()
	self.pkModel.smallBtn.onClick:Remove(self.ShowModelSelect,self)
	self.switchBtn.onClick:Remove(self.BtnSwitchHandler,self)
	self.playerInfo:GetChild("HeadIcon").onClick:Remove(self.OpenPlayerInfoPanel,self)-------
	self.bagBtn.onClick:Remove(self.OpenBag,self)
	self.equipStoreBtn.onClick:Remove(self.OnEquipStoreBtnClick , self)
	self.decompositionBtn.onClick:Remove(self.OnDecompositionBtnClick , self)
	self.furnaceBtn.onClick:Remove(self.OnOpenFurnace , self)
	self.gangBtn.onClick:Remove(self.OnOpenGang,self)

	self.returnBtn.onClick:Remove(self.OnClickReturnBtn,self)

	self.transBtn.onClick:Remove(self.OnTrans,self)

	GlobalDispatcher:RemoveEventListener(self.vipChangeHandle)  --清除vip全局监听事件
	--监听自动寻路跑动事件
	GlobalDispatcher:RemoveEventListener(self.handler1)
	GlobalDispatcher:RemoveEventListener(self.handler2)
	GlobalDispatcher:RemoveEventListener(self.handler4)
	--监听自动寻路跑动事件
	GlobalDispatcher:RemoveEventListener(self.handler5)
	GlobalDispatcher:RemoveEventListener(self.handler6)
	GlobalDispatcher:RemoveEventListener(self.handler7)
	self.model:RemoveEventListener(self.hanlder8)
	GlobalDispatcher:RemoveEventListener(self.handler9)
	self.model:RemoveEventListener(self.hanlder10)
	GlobalDispatcher:RemoveEventListener(self.handler11)
	GlobalDispatcher:RemoveEventListener(self.handler12)
	self.model:RemoveEventListener(self.handler13)
	GlobalDispatcher:RemoveEventListener(self.handler14)
	self.model:RemoveEventListener(self.handler15)
	GlobalDispatcher:RemoveEventListener(self.handler16)
	GlobalDispatcher:RemoveEventListener(self.handler17)
end

--激活玩家的战斗面板（沿用老的机制，后续要改掉）
function MainCityUI:InitBtnSkillView()
	self.fightControllerUI:InitBtnSkillView()
end

function MainCityUI:InitMainCitytUI()  --初始化ui
	self.switchMorF.selectedIndex = 0
end

function MainCityUI:ShowModelSelect()
	self.modelSelect:ToggleShow()
	GlobalDispatcher:DispatchEvent(EventName.FinishNewbieGuideStep)
end

function MainCityUI:HideModelSelect()
	self.modelSelect:Hide()
end

---------------------------------------------------------------------------
--怪物信息操作区域
function MainCityUI:InitMonInfo( monVo )
	self.monInfo:InitMonInfo(monVo)
	self.monInfo.ui.visible = true
 	self.monInfo.ui.alpha = 0
	TweenUtils.TweenFloat(0, 1, 0.3, function(data)
		self.monInfo.ui.alpha = data
	end)
end

function MainCityUI:RefreshMonInfo(monVo)
	self.monInfo:RefreshMonInfo(monVo)
end

function MainCityUI:HideMonInfo(monVo)
	if monVo.guid == self.monInfo.guid then
		
		self.monInfo.ui.visible = true
	 	self.monInfo.ui.alpha = 1

		TweenUtils.TweenFloat(1, 0, 0.3, function(data)
			self.monInfo.ui.alpha = data
			if self.monInfo.ui.alpha < 0.09 then
				self.monInfo.ui.visible = false
			end
		end)
	 end
end

function MainCityUI:HideMonInfoWithNotTween()
	self.monInfo.ui.visible = false
 	self.monInfo.ui.alpha = 0
end
---------------------------------------------------------------------------
---------------------------------------------------------------------------
--角色信息操作区域
function MainCityUI:InitPlayerInfo( playerVo )
	if self.playerInfo then
		self.playerInfo:InitPlayerInfo()
	end
	self:InitPlayerExp(playerVo) --初始化经验
	self:InitPkModel(playerVo) --初始化pk模式
	self:InitBuffUI(playerVo) --初始化BuffUI
	if playerVo and playerVo.level >= 10 and self.furnaceBtn then
		self.furnaceBtn.visible = self.activites.ui.visible
	end
	if playerVo and playerVo.level >= GetCfgData("constant"):Get(59).value and self.gangBtn then
		self.gangBtn.visible = self.activites.ui.visible
	end
end

function MainCityUI:RefreshPlayerInfo(key, value)
	if self.playerInfo then
		self.playerInfo:RefreshPlayerInfo(key, value)
	end
end

function MainCityUI:InitPlayerInfoRight( playerVo )
	if self.playerInfoRight then
		self.playerInfoRight:InitPlayerInfo(playerVo)
	end
end

function MainCityUI:RefreshPlayerInfoRight(key, value)
	if self.playerInfoRight then
		self.playerInfoRight:RefreshPlayerInfo(key, value)
	end
end

--初始化玩家经验
function MainCityUI:InitPlayerExp(playerVo)
	--玩家升级到下一级需要的经验
	local nextNeedExp = playerVo:GetLevelExp()
	local curExp = playerVo.exp
	self.playerExpBar.max = nextNeedExp
	self.playerExpBar.value = curExp
end

--PK模式 1:和平 2:善恶 3:组队 4:氏族 5:全体
function MainCityUI:InitPkModel(playerVo)
	if self.pkModel then
		self.pkModel:ShowByType(playerVo.pkModel)
	end
end

function MainCityUI:InitBuffUI(playerVo)
	if not self.playerBuffUIManager then
		local buffData = nil
		local scene = SceneController:GetInstance():GetScene()
		if scene then
			local mainPlayer = scene:GetMainPlayer()
			if mainPlayer and mainPlayer.buffManager then
				buffData = {}
				buffData.guid = playerVo.guid
				buffData.buffAry = mainPlayer.buffManager.buffAry
				self.playerBuffUIManager = BuffUIManager.New(self.buffContainer, playerVo.guid, self.buffDescPanel, true, buffData)
			end
		end
	end
end

--更新玩家经验
function MainCityUI:RefreshPlayerExp()
	local roleVo = SceneModel:GetInstance():GetMainPlayer()
	local nextNeedExp = roleVo:GetLevelExp()
	local curExp = roleVo.exp
	self.playerExpBar.max = nextNeedExp
	self.playerExpBar.value = curExp
end
---------------------------------------------------------------------------
function MainCityUI:UIMapping()
	local sceneModel = SceneModel:GetInstance()
	if sceneModel:IsMain() then
		self:MainUIView()
	elseif sceneModel:IsTianti() then
		self:TiantiUIView()
	else
		self:FightUIView()
	end
end

function MainCityUI:SetActivitesUIState()
	local sceneModel = SceneModel:GetInstance()
	local isCopy = sceneModel:IsCopy()  --如果是副本
	local isTianti = sceneModel:IsTianti()
	if self.hideBtn then self.hideBtn.visible = (not isCopy) and (not isTianti) end
	--玩家进入到野外场景时，左侧两列图标自动隐藏
	-- if SceneModel:GetInstance():IsOutdoor1() or SceneModel:GetInstance():IsOutdoor2() then
	-- 	self:HideActivityUI()
	-- end
end

function MainCityUI:MainUIView()
	self:SetViewState(true, false, 0, 0, false)
end

function MainCityUI:FightUIView()
	self:SetViewState(false, true, 1, 1, false)
end

function MainCityUI:TiantiUIView()
	if self and self.ui then
		self:SetViewState(false, true, 2, 1, true)
	end
end

function MainCityUI:SetViewState(grayed, touchable, idx, viewType, isTianti)
	if self.switchBtn then
		self.switchBtn.grayed = grayed
		self.switchBtn.touchable = touchable
	end
	if self.switchMorF then
		self.switchMorF.selectedIndex = idx
	end
	if self.chatMain then
		self.chatMain:SetIsTianti(isTianti)
	end
	if self.fightControllerUI then
		self.fightControllerUI:SetIsTianti(isTianti)
	end
	DelayCall(function() GameConst.ViewType = viewType end, 0.5)
	if isTianti then
		self:StartTiantiCutDown()
	else
		self:RemoveTiantiCutDown()
	end
end

--切换面板状态
function MainCityUI:BtnSwitchHandler()
	if self.switchMorF.selectedIndex == 0 then
		self.switchMorF.selectedIndex = 1
		self.fightControllerEffectIn:Play()
		self.switchBtnEffect:Play()
		
		DelayCall(function() GameConst.ViewType = 1 end, 0.5)
	else
		self.switchMorF.selectedIndex = 0
		self.switchBtnEffect2:Play()
		self.functionConnIn:Play()
		DelayCall(function() GameConst.ViewType = 0 end, 0.5)
		GlobalDispatcher:DispatchEvent(EventName.FinishNewbieGuideStep)
	end
end

--切换到CityUI状态
function MainCityUI:SwitchToCityUI()
	if self.switchMorF.selectedIndex ~= 0 then
		self.switchMorF.selectedIndex = 0
		self.switchBtnEffect2:Play()
		self.functionConnIn:Play()
		DelayCall(function() GameConst.ViewType = 0 end, 0.5)
	end
end

--是否处于CityUI状态
function MainCityUI:IsInCityUIState()
	return (self.switchMorF.selectedIndex == 0)
end

function MainCityUI:ChangeFBState()
	local sceneModel = SceneModel:GetInstance()
	local mapType = sceneModel:IsCopy()  --如果是副本
	if mapType then 
		-- 如果是副本就打开副本倒计时和隐藏相应的需要隐藏的功能
		self.activites.ui.visible = false
		self.miniMap.ui.visible = false	
		self.FBFlag.ui.visible = true
		self.returnBtn.visible = false -- 不显示回城按钮
		self.transBtn.visible=false
		self.FBFlag:OnEnable()

		self.equipStoreBtn.visible = false
		self.decompositionBtn.visible = false

	else
		if sceneModel:IsHasBoss() then
			self.monInfo.ui.visible = true
		else
			self.monInfo.ui.visible = false
		end
		self.miniMap.ui.visible = true
		self.miniMap:Init()
		self.FBFlag.ui.visible = false
		self.returnBtn.visible = true -- 不显示回城按钮
		self.FBFlag:OnDisable()

		self:SetActivitesUIStateByOperation()

		local equipStoreVo =  MainUIModel:GetInstance():GetMainUIVoListById(FunctionConst.FunEnum.EquipStore)
		if not TableIsEmpty(equipStoreVo) and equipStoreVo.state == MainUIConst.MainUIItemState.Open and EquipmentStoreTipsModel:GetInstance():IsClose() == false then
			self.equipStoreBtn.visible = true
		end
		self.decompositionBtn.visible = true
	end
end


--打开角色属性面板
function MainCityUI:OpenPlayerInfoPanel()
	PlayerInfoController:GetInstance():Open(0)
	GlobalDispatcher:DispatchEvent(EventName.FinishNewbieGuideStep)
end

--打开角色属性面板
function MainCityUI:OpenBag()
	PkgCtrl:GetInstance():Open()
	GlobalDispatcher:DispatchEvent(EventName.FinishNewbieGuideStep)
end

--打开装备行
function MainCityUI:OnEquipStoreBtnClick()
	MallController:GetInstance():OpenMallPanel(nil, 0 , 7)
end


--打开提升界面
function MainCityUI:OnDecompositionBtnClick()
	StrongModel:GetInstance():GetKindLevel()
	StrongModel:GetInstance():IsRedStrong()
	StrongCtr:GetInstance():Open()
end


function MainCityUI:OnOpenFurnace()
	FurnaceCtrl:GetInstance():Open()
end

function MainCityUI:OnOpenGang()
	-- UIMgr.Win_FloatTip("功能暂未开放，敬请期待！")
	ClanCtrl:GetInstance():Open()
end

--显示自动寻路标识
function MainCityUI:ShowAutoRunTips()
	self:HideStateLabel()
	if self.autoRunTips then
		self.autoRunTips:SetVisible(true)
	end
end

--隐藏自动寻路标识
function MainCityUI:HideAutoRunTips()
	if self.autoRunTips then
		self.autoRunTips:SetVisible(false)
	end
end

--显示自动战斗标识
function MainCityUI:ShowAutoFight()
	self:HideStateLabel()
	if self.autoFightTips then
		self.autoFightTips:SetVisible(true)
	end
end

--隐藏自动战斗标识
function MainCityUI:HideAutoFight()
	if self.autoFightTips then
		self.autoFightTips:SetVisible(false)
	end
end

function MainCityUI:HideStateLabel()
	self:HideAutoRunTips()
	self:HideAutoFight()
end

--直接回主城
function MainCityUI:OnClickReturnBtn()
	self:HideStateLabel()
	local scene = SceneController:GetInstance():GetScene()
	if scene and scene:GetMainPlayer() and scene:GetMainPlayer():GetAnimator() and scene:GetMainPlayer():GetAnimator().curAction ~= "idle" then
		scene:GetMainPlayer():StopMove()
	end
	if SceneModel:GetInstance().sceneId == 1001 then return end 
	if SceneModel:GetInstance():IsInNewBeeScene() == true then
		UIMgr.Win_FloatTip("通关彼岸村后可使用")
	else
		ZDCtrl:GetInstance():EndFollowLeader()
		GlobalDispatcher:DispatchEvent(EventName.StopCollect)
		GlobalDispatcher:DispatchEvent(EventName.StartReturnMainCity)
	end
end


local transMsg = {"[color=#348a37]{0}[/color] 正在召集本队伍全体成员前往 [color=#ffc228]{1}[/color] 帮助",
 					"[color=#348a37]{0}[/color] 正在召集本家族全体成员前往 [color=#ffc228]{1}[/color] 帮助",
  					"[color=#348a37]{0}[/color] 正在召集本都护府全体成员前往 [color=#ffc228]{1}[/color] 帮助",}
function MainCityUI:OnTrans()
	if self.transBtn and self.tmpTransMsg then
		self.transBtn.visible=false
		local msg = self.tmpTransMsg
		self.tmpTransMsg=nil
		local content = StringFormat(transMsg[msg.type], msg.playerName, GetCfgData("mapManger"):Get(msg.toMapId).map_name)
		UIMgr.Win_Confirm("提示", content, "确定", "取消", function ()
			SceneController:GetInstance():C_Transfer(msg.toMapId ,msg.toPosition)
		end, nil)
	end
end

function MainCityUI:OnClickMiniMap()
	if SceneModel:GetInstance():IsInNewBeeScene() == true then
		UIMgr.Win_FloatTip("通关彼岸村后可打开世界地图")
	else
		WorldMapController:GetInstance():Open(0) -- 世界地图 1   二级地图 0
	end
end

-- Dispose use MainCityUI obj:Destroy()
function MainCityUI:__delete()
	self:RemoveEvents()
	self.pkModel:Destroy()
	self.modelSelect:Destroy()

	self.fightControllerUI:Destroy()
	self.functionConn:Destroy()
	self.playerInfo:Destroy()
	self.monInfo:Destroy()
	self.FBFlag:Destroy()
	self.chatMain:Destroy()
	self.activites:Destroy()
	self.miniMap:Destroy()
	self.taskTeam:Destroy()

	self.miniMap = nil
	self.playerInfo = nil
	self.fightControllerUI = nil
	self.switchBtn = nil
	self.functionConn = nil
	if CustomJoystick.skillJoystick then
		CustomJoystick.skillJoystick:Destroy()
	end
	CustomJoystick.skillJoystick = nil
	if CustomJoystick.mainJoystick then
		CustomJoystick.mainJoystick:Destroy()
	end
	CustomJoystick.mainJoystick = nil

	self.playerExpBar = nil
	self.monInfo = nil
	self.switchBtnEffect = nil
	self.switchBtnEffect2 =  nil
	self.fightControllerEffectIn =  nil
	self.taskTeam = nil
	self.ChatMain = nil
	self.functionConnIn = nil
	if self.autoRunTips then 
		self.autoRunTips:Destroy()
	end
	self.autoRunTips = nil
	if self.autoFightTips then 
		self.autoFightTips:Destroy()
	end
	self.autoFightTips = nil
	self.bagBtn = nil
	self.activites =nil
	self.returnBtn = nil
	self.transBtn = nil
	self.pkModel = nil
	self.modelSelect = nil
	self.FBFlag = nil

	if self.playerBuffUIManager then
		self.playerBuffUIManager:Destroy()
	end
	self.playerBuffUIManager = nil
	self:ClearQuickUIList()
	self:ClearQuickGoodsUIList()
	self.hideBtn = nil
	self:RemoveTiantiCutDown()

	self:CleanEffect()
	self:CleanEffectRoot()

	self:RemoveEquipStoreTimer()
end

function MainCityUI:Open()
	self.ui.visible = true
	self:ChangeFBState()
	self:UIMapping()
end

function MainCityUI:Close()
	self.ui.visible = false
end

--初始化各个UI功能
function MainCityUI:InitUIByState()
	local mainUIVoList = self.model:GetMainUIVoList()
	for index = 1 , #mainUIVoList do
		local curMainUIVo = mainUIVoList[index]
		local isOpen = false
		if not TableIsEmpty(curMainUIVo) then
			if curMainUIVo.state == MainUIConst.MainUIItemState.Open then
				isOpen = true
			elseif curMainUIVo.state == MainUIConst.MainUIItemState.Close then
				isOpen = false
			end
		end

		local ui = self:GetUIByType(curMainUIVo:GetModuleId())
		if ui then
			self:SetUIByState(ui , isOpen , false , curMainUIVo:GetModuleId())
		end
	end
end

--根据主界面各个UI的功能开启状态改变对应的表现
function MainCityUI:HandleUIStateChange(data)
	if data then
		local oldState = data.oldState or -1
		local newMainUIVo = data.newMainUIVo or {}
		local funUI = self:GetUIByType(newMainUIVo:GetModuleId())
		if oldState ~= nil and newMainUIVo  and  funUI then
			local newState = newMainUIVo:GetState()
			if oldState ~= newState then
				if oldState == MainUIConst.MainUIItemState.None or oldState == MainUIConst.MainUIItemState.Close then
					if newState == MainUIConst.MainUIItemState.Open then
						self:SetUIByState(funUI , true , true , newMainUIVo:GetModuleId())
					end
				end

				if oldState == MainUIConst.MainUIItemState.None or oldState == MainUIConst.MainUIItemState.Open then
					if newState == MainUIConst.MainUIItemState.Close then
						self:SetUIByState(funUI , false , false , newMainUIVo:GetModuleId())
					end
				end

				-- 活动功能开启时抛个全局,要弹签到...
				local mdId = newMainUIVo:GetModuleId()
				if mdId and mdId == FunctionConst.FunEnum.activity and newMainUIVo:GetState() ==  MainUIConst.MainUIItemState.Open then
					if oldState == MainUIConst.MainUIItemState.None or oldState == MainUIConst.MainUIItemState.Close then
						if newState == MainUIConst.MainUIItemState.Open then
							GlobalDispatcher:DispatchEvent(EventName.ActivityFirstOpen)
						end
					end
				end
			end
			--审核版本，关掉部分功能
			if SHENHE and self.model:IsNotShenHeModule(newMainUIVo:GetModuleId()) then
				self:SetUIByState(funUI , false , false , newMainUIVo:GetModuleId())
			end
		end
	end
end



--根据id获取对应的主界面UI某个部件
function MainCityUI:GetUIByType(td)
	local FunEnum = FunctionConst.FunEnum
	if td then
		if td == FunEnum.playerInfo or td == FunEnum.skill or td == FunEnum.godFightRune or td == FunEnum.social or td == FunEnum.setting then
			return self.functionConn:GetUIByType(td)
		elseif td == FunEnum.activity or td == FunEnum.welfare or td == FunEnum.rank or td == FunEnum.deal or
				td == FunEnum.store or td == FunEnum.ladder or td == FunEnum.copy or td == FunEnum.shenjing or
				td == FunEnum.carnival or td == FunEnum.firstRecharge or td == FunEnum.SevenLogin or td == FunEnum.OpenGift then
			return self.activites:GetUIByType(td)
		elseif td == FunEnum.map then
			return self.miniMap
		elseif td == FunEnum.taskTeam then
			return self.taskTeam
		elseif td == FunEnum.expBar then
			return self.PlayerExpBar
		elseif td == FunEnum.skillBtns then
			return self.fightControllerUI
		elseif td == FunEnum.chat then
			return self.chatMain
		elseif td == FunEnum.pkSelect then
			return self.pkModel
		elseif td == FunEnum.switchBtn then
			return self.switchBtn
		elseif td == FunEnum.buffContainer then
			return self.buffContainer
		elseif td == FunEnum.vip then
			return self.btnVipIcon
		elseif td == FunEnum.backToCity then
			return self.returnBtn
		elseif td == FunEnum.bag then
			return self.bagBtn
		elseif td == FunEnum.notice then
			return self.transBtn
		elseif td == FunEnum.EquipStore then
			return self.equipStoreBtn
		elseif td == FunEnum.Decomposition then
			return self.decompositionBtn
		end
	end
end

--根据状态设置某个功能ui的表现
--未解锁的的图标隐藏（透明，不可点击）
--图标解锁时，由透明渐变到可见(过程1.3秒)
function MainCityUI:SetUIByState(fui , isOpen , isFirst , moduleId)
	if fui then
		fui.visible = isOpen
		if isFirst then 
			-- local ui = fui.ui or nil
			-- if ui then print("透明到可见") ui:TweenFade(0 , 1.3) end
		end

		if  self.model:IsNeedEffect(moduleId) then
			if isOpen == true then
				if self.effectList[moduleId] == nil then
					local posX = fui.width *0.5
					local posY = fui.height *0.5
					self:LoadEffect(self.redTipsEffectName , moduleId , posX , -1 * posY , fui)
				end
			elseif isOpen == false then
				if self.effectList[moduleId] ~= nil then
					self:UnloadEffect(moduleId)
					self:UnloadEffectRoot(moduleId)
				end
			end
		end
	end
end

function MainCityUI:SetStrongState()
	local ui = self:GetUIByType(FunctionConst.FunEnum.Strong)
	if not ui then return end
	if StrongModel:GetInstance():MainStrongIsEffect() then
			local posX = ui.width / 2
			local posY = ui.height / 2
			self:LoadEffect(self.redTipsEffectName , FunctionConst.FunEnum.Strong , posX , -1 * posY , ui)
	else
		self:UnloadEffect(FunctionConst.FunEnum.Strong)
	end
end

--设置缓存的红点提示（当MainCityUI没有实例化出来，但红点数据已经产生）
function MainCityUI:InitRedTipsByCache()
	local redTipsCache = self.model:GetRedTipsDataCache()
	for i , v in pairs(redTipsCache) do
		self:HandleRedTips(v)
	end
end
--设置主UI某个功能UI的红点提示开关表现
--data 格式例子： {moduleId = FunctionConst.FunEnum.mingwenStore , state = true}
function MainCityUI:HandleRedTips(data)
	if data then
		local funUI = self:GetUIByType(data.moduleId)
		if funUI then
			redTipsUI = funUI:GetChild("red_tips")
			if redTipsUI then
				redTipsUI.visible = data.state
			else
				local posX , posY = self:GetRedTipsPos(data)
				CreateRedPoint(funUI , posX , posY  , data.state)
			end
		end
	end
end

function MainCityUI:IsCanLoadRedTipsEffect(moduleId)
	local rtnIsCan = false
	if moduleId then
		if moduleId == FunctionConst.FunEnum.carnival or 
			moduleId == FunctionConst.FunEnum.firstRecharge then
			rtnIsCan = true
		end
	end
	return rtnIsCan
end

function MainCityUI:LoadEffect(res, moduleId , posX , posY ,parentUI)
	if res == nil or parentUI == nil then return end
	local function LoadCallBack(effect)
		if effect then
			if self.effectList[moduleId] ~= nil then
				destroyImmediate(self.effectList[moduleId])
				self.effectList[moduleId] = nil
			end
			local effectObj = GameObject.Instantiate(effect)
			local tf = effectObj.transform
			tf.localPosition = Vector3.New(posX , posY , 0)
			tf.localScale = Vector3.New(1, 1, 1)
	 		tf.localRotation = Quaternion.Euler(0, 0, 0)
	 		local eff = self.effectRootList[moduleId]
	 		if eff == nil then
	 			eff = self:CreateGraph()
	 			 self.effectRootList[moduleId]=eff
	 		end
	 		
	 		if eff then
	 			eff:SetNativeObject(GoWrapper.New(effectObj))
	 			parentUI:AddChild(eff)
	 			self.effectList[moduleId] = effectObj
	 		end
		end
	end
	LoadEffect(res , LoadCallBack)
end

function MainCityUI:CreateGraph()
	local rtnGraph = nil
	rtnGraph = GGraph.New()
	rtnGraph:SetXY(0 , 0)
	rtnGraph:SetSize(1 , 1)
	return rtnGraph
end

function MainCityUI:UnloadEffect(moduleId)
	if self.effectList[moduleId] then
		destroyImmediate(self.effectList[moduleId])
		self.effectList[moduleId] = nil
	end
end

function MainCityUI:UnloadEffectRoot(moduleId)
	if self.effectRootList[moduleId] then
		self.effectRootList[moduleId]:Destroy()
		self.effectRootList[moduleId] = nil
	end
end

function MainCityUI:CleanEffect()
	for k , v in pairs(self.effectList) do
		if self.effectList[k] then
			destroyImmediate(self.effectList[k])
			self.effectList[k] = nil
		end
	end
end

function MainCityUI:CleanEffectRoot()
	for k , v in pairs(self.effectRootList) do
		if self.effectRootList[k] then
			self.effectRootList[k]:Destroy()
			self.effectRootList[k] = nil
		end
	end
end

--获取红点的位置
function MainCityUI:GetRedTipsPos(data)
	if data then
		return 40 , 0
	end
end

function MainCityUI:ClearQuickUIList()
	if self.quickCellList then
		for _, v in pairs(self.quickCellList) do
			v:Destroy()
			v = nil
		end
		self.quickCellList = nil
	end
end

function MainCityUI:ClearQuickGoodsUIList()
	if self.quickGoodsCellList then
		for _, v in pairs(self.quickGoodsCellList) do
			if v then
				for i = #v, 1, -1 do
					v[i]:Destroy()
					v[i] = nil
				end
			end
		end
		self.quickGoodsCellList = nil
	end
end

-- 刷新快捷穿戴ui
function MainCityUI:RefreshQuickList(data)
	-- 先清空当前cells
	self:ClearQuickUIList()
	self.quickCellList = {}
	local quickVoList = self.model:GetQuickList()
	local sortedList = {}
	-- 按照vo产生的顺序排个序
	for _, v in pairs(quickVoList) do
		table.insert(sortedList, v)
	end
	table.sort(sortedList, function(v1, v2)
		return v1:GetCreateIndex() < v2:GetCreateIndex()
	end)
	self:RefreshQuickBySortedList(sortedList)
end

function MainCityUI:RefreshQuickBySortedList(sortedList)
	for k, v in ipairs(sortedList) do
		local cellUI = self:CreateOneQuickCell(v)
		self.quickCellList[k] = cellUI
		cellUI:AddTo(self.ui)
		cellUI:SetXY(900, 300)
	end
end
-- 创建单个cell by vo
function MainCityUI:CreateOneQuickCell(vo, isGoods)
	local cell = QuickEquipCell.New()
	cell:SetData(vo, isGoods)
	return cell
end

--创建隐藏按钮
function MainCityUI:CreateHideBtn()
	if not self.hideBtn then
		self.hideBtn = UIPackage.CreateObject("Main" , "BtnHide")
		self.hideBtn:SetXY(1100 ,50)
		self.ui:AddChild(self.hideBtn)
		self.hideBtn.onClick:Add(self.OnBtnHideClick ,self)
		self.hideBtn:GetTransition("arrowToRight"):Play()
		self.model:SetActivitesUIState(MainUIConst.ActivitesUIState.Show)
	end
end

--点击隐藏按钮
function MainCityUI:OnBtnHideClick()
	if self.activites then
		local ui = self.activites.ui
		ui.visible = not ui.visible
		if ui.visible then
			self.hideBtn:GetTransition("arrowToRight"):Play()
			self.model:SetActivitesUIState(MainUIConst.ActivitesUIState.Show)
		else
			self.hideBtn:GetTransition("arrowToLeft"):Play()
			self.model:SetActivitesUIState(MainUIConst.ActivitesUIState.Hiden)
		end
		self.furnaceBtn.visible = ui.visible
		self.gangBtn.visible = ui.visible
	end
end

--玩家进入到野外场景时，左侧两列图标自动隐藏
function MainCityUI:HideActivityUI()
	self.activites.ui.visible = false
	self.hideBtn:GetTransition("arrowToLeft"):Play()
	self.furnaceBtn.visible = false
	self.gangBtn.visible = false
end

--TaskTeam是否处于被隐藏方式
function MainCityUI:IsTaskTeamStateOut()
	return self.taskTeam:IsTaskTeamStateOut()
end

--TaskTeam手动显示
function MainCityUI:SwitchTaskTeamStateIn()
	self.taskTeam:OnExtendBtnClick()
end

--TaskTeam组件的controller是否处于MainUIConst.TaskTeamCtrl.Team
function MainCityUI:IsInTeamCtrl()
	return self.taskTeam:IsInTeamCtrl()
end

--Activites组件是的显示隐藏状态
function MainCityUI:GetActivitesVisible()
	return self.activites.ui.visible
end

function MainCityUI:SetActivitesUIStateByOperation()
	local stateVal = self.model:GetActivitesUIState()
	if stateVal == MainUIConst.ActivitesUIState.Show then
		self.activites.ui.visible = true
	elseif stateVal == MainUIConst.ActivitesUIState.Hiden then
		self.activites.ui.visible = false
	end
end

function MainCityUI:Reset()
	if self.playerBuffUIManager then
		self.playerBuffUIManager:Destroy()
		self.playerBuffUIManager = nil
	end
	self:HandleMainPlayerDie()

end

function MainCityUI:RefreshQuickGoodsList(data)
	if not data then return end
	local vo = data.vo
	local itemId = nil
	if vo.cfg then
		itemId = vo.cfg.id
	else
		itemId = vo.bid
	end
	local cfg = GetCfgData("item"):Get(itemId)
	if (not cfg) or cfg.automatic ~= 1 then return end
	local num = data.num or 0
	self.quickGoodsCellList[itemId] = self.quickGoodsCellList[itemId] or {}
	if num > 0 then
		local voNew = clone(vo)
		voNew.num = 1
		for i = 1, num do
			local cellUI = self:CreateOneQuickCell(voNew, true)
			table.insert(self.quickGoodsCellList[itemId], cellUI)
			cellUI:AddTo(self.ui)
			cellUI:SetXY(900, 300)
		end
	else
		num = math.abs(num)
		for i = 1, num do
			self:RemoveQuickGoodsCell(self.quickGoodsCellList[itemId], vo)
		end
	end
end

function MainCityUI:RemoveQuickGoodsCell(list, vo)
	for i = #list, 1, -1 do
		local data = list[i]:GetData()
		if data and data.bid == vo.bid then
			local cell = table.remove(list, i)
			if cell then
				cell:Destroy()
			end
			return
		end
	end
end

function MainCityUI:HandleMainPlayerDie(data)
	self:ClearQuickUIList()
	self:ClearQuickGoodsUIList()
	self.quickCellList = {}
	self.quickGoodsCellList = {}
end

function MainCityUI:HandlePopStateChange(data)
	if data.show then
		self:StartShowPops(data.index)
	else
		self:EndShowPops()
	end
end

function MainCityUI:StartShowPops(index)
	local list = self.model:GetPopCheckList()
	for i = index, MainUIConst.PopModule.Max - 1 do
		local data = list[i].data
		if data and data.show then
			local func = data.openCb
			local args = data.args
			local autoExecTaskId = TaskModel:GetInstance():GetAutoExecTaskId()
			if func and args and autoExecTaskId == 0 then
				func(args[1])
			end
			return
		end
	end
	self:EndShowPops()
end

function MainCityUI:EndShowPops()
	self.model:SetPopCheckState(MainUIConst.PopCheckState.ShowOver)
	EmailController:GetInstance():ShowTooMuchTips()
end

function MainCityUI:StartTiantiCutDown()
	self:RemoveTiantiCutDown()
	local function timerUpdate()
		self.deltaTiantiTime = math.max(0, self.endTiantiTime - TimeTool.GetCurTime())
		--print("vvv ==>> ", self.deltaTiantiTime)
		self.txtCutdown.text = StringFormat("剩余时间  : {0}", TimeTool.GetTimeMS(math.floor(self.deltaTiantiTime/1000), true))
		if self.deltaTiantiTime <= 0 then
			self:RemoveTiantiCutDown()
		end
	end
	self.endTiantiTime = SceneModel:GetInstance().endSceneTime
	self.txtCutdown.visible = true
	timerUpdate()
	RenderMgr.AddInterval(timerUpdate, "tiantiCutdown_timer1", 1)
end

function MainCityUI:RemoveTiantiCutDown()
	self.txtCutdown.visible = false
	RenderMgr.Realse("tiantiCutdown_timer1")
end

function MainCityUI:CheckEquipStoreState()
	local createTime , closeTime , formatTime0 , formatTime1 = EquipmentStoreTipsModel:GetInstance():GetStartEndTime()
	local formatCreateTime = TimeTool.getYMD3(createTime)
	local formatEndTime = TimeTool.getYMD3(closeTime)
	local startTime = TimeTool.GetTimeByYYMMDD_HHMMSS(formatCreateTime)
	local endTime = TimeTool.GetTimeByYYMMDD_HHMMSS(formatEndTime)
	local curTime = TimeTool.GetCurTime()*0.001 --服务器时间
	local curMainUIVo = self.model:GetMainUIVoListById(FunctionConst.FunEnum.EquipStore)
	if startTime == nil or endTime == nil or createTime == 0 or closeTime == 0 or formatTime0 == 0 or formatTime1 == 0 then return end

	if not TableIsEmpty(curMainUIVo) then
		oldState = curMainUIVo:GetState()
		if curTime > startTime and curTime < endTime then
			if oldState ~= MainUIConst.MainUIItemState.Open then
				curMainUIVo:SetState(MainUIConst.MainUIItemState.Open)
				self.model:DispatchEvent(MainUIConst.UIStateChange , {oldState = oldState , newMainUIVo = curMainUIVo})
				if MallModel:GetInstance():GetTab67State() ~= true then
					MallModel:GetInstance():SetTab67State(true)
				end
			end
		else
			if oldState ~= MainUIConst.MainUIItemState.Close then
				curMainUIVo:SetState(MainUIConst.MainUIItemState.Close)
				self.model:DispatchEvent(MainUIConst.UIStateChange , {oldState = oldState , newMainUIVo = curMainUIVo})
			end
			if MallModel:GetInstance():GetTab67State() ~= false then
				MallModel:GetInstance():SetTab67State(false)
			end

			--self:RemoveEquipStoreTimer()
		end
	end
end

function MainCityUI:AddEquipStoreTimer()
	local function updateFun()
		self:CheckEquipStoreState()
	end
	RenderMgr.AddInterval(updateFun, "MainCityUI.EquipStoreTimer" , 1)
end

function MainCityUI:RemoveEquipStoreTimer()
	RenderMgr.Realse("MainCityUI.EquipStoreTimer")
end