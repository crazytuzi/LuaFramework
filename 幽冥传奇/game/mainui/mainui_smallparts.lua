----------------------------------------------------
-- 主ui小部件
----------------------------------------------------

MainuiSmallParts = MainuiSmallParts or BaseClass()

--任务导航栏
require("scripts/game/mainui/task_guide/task_guide_view")

function MainuiSmallParts:__init(main_view)
	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()					-- 增加事件组件

	self.main_view = main_view

	self.btn_auto_fight = nil
	self.layout_transmit = nil

	self.func_bar_items = {}
	self.cond_list = {}
	self.remind_icon_list = {}

	self.bisha_preview_icon = nil	-- 必杀技预告

	self.time_limit_task_icon = nil	-- 限时任务
	self.tl_task_left_time_cd = nil
	self.turnview = nil
	-- self.img = nil
	self.turn_item = nil
	self.zhanwen_img = nil
	self.turn_rich_content = nil
	self.cur_index = 1
	-- self.rich_content = nil
	-- self.times = 0
	-- self.zhuanpan_right = nil
	self.prestige_task_vis = nil -- 威望任务兑换次数

	GlobalEventSystem:Bind(OtherEventType.FINISH_FUBEN, BindTool.Bind(self.OnFinishFuben, self))
	GlobalEventSystem:Bind(OtherEventType.GUAJI_TYPE_CHANGE, BindTool.Bind(self.OnGuajiTypeChange, self))
	GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_ENTER, BindTool.Bind(self.OnEnterFuben, self))
	GlobalEventSystem:Bind(OtherEventType.REMINDGROUP_CAHANGE, BindTool.Bind(self.RemindGroupChange, self))
	GlobalEventSystem:Bind(OtherEventType.GAME_COND_CHANGE, BindTool.Bind(self.OnGameCondChange, self))
	-- GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_LEARN_BISHA, BindTool.Bind(self.OnMainRoleLearnBiSha, self))
	GlobalEventSystem:Bind(SceneEventType.SCENE_CHANGE_COMPLETE, BindTool.Bind(self.OnSceneChangeComplete, self))
	GlobalEventSystem:Bind(OtherEventType.EXCAVATE_BOSS, BindTool.Bind(self.FlushExcavateBossIconVis, self))
	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, function ()
		GlobalTimerQuest:AddDelayTimer(function ()
			-- self:FlushFuncGuide()
		end, 3)

		if self.bag_point then

			self.bag_point:setVisible(BagData.Instance:GetBagRemind() or BagData.Instance:GetAllPoint())
		end
	end)

	-- BagData.Instance:AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnItemChange, self))
	-- EventProxy.New(BattleFuwenData.Instance, self):AddEventListener(BattleFuwenData.BATTLE_FUWEN_ONE_INFO_CHANGE, BindTool.Bind(self.FlushZhanWenRemind, self))
	-- EventProxy.New(ZhengtuShilianData.Instance, self):AddEventListener(ZhengtuShilianData.ROTARY_TABLE_DATA_CHANGE, BindTool.Bind(self.FlushTurnFuTatyRemind, self))
	-- EventProxy.New(FindBossData.Instance, self):AddEventListener(FindBossData.FINDBOSS_DATA_CHANGE, BindTool.Bind(self.UpdateFindBossIcon, self))
	
	EventProxy.New(PrestigeTaskData.Instance, self):AddEventListener(PrestigeTaskData.TASK_DATA_CHANGE, BindTool.Bind(self.OnTaskDataChange, self))
	EventProxy.New(UnknownDarkHouseData.Instance, self):AddEventListener(UnknownDarkHouseData.UNKNOWN_DARK_HOUSE_EXP_CHANGE, BindTool.Bind(self.OnUnknownDarkHouseExpChange, self))
	EventProxy.New(UnknownDarkHouseData.Instance, self):AddEventListener(UnknownDarkHouseData.UNKNOWN_DARK_HOUSE_DATA_CHANGE, BindTool.Bind(self.OnUnknownDarkHouseDataChange, self))

	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleDataChangeCallback, self))

	self.data_event = GlobalEventSystem:Bind(BABEL_EVENET.DATA_CHANGE,BindTool.Bind1(self.ShilianPoint, self))

end

function MainuiSmallParts:ShilianPoint()
	local vis = false 

	if BabelData.Instance:GetCanSweep() or BabelData.Instance:GetRemianChoujiangNum() > 0 then
		vis = true
	end
	self.img_shilian_red:setVisible(vis)
end

function MainuiSmallParts:__delete()
	self.func_bar_items = {}
	self.cond_list = {}
	self.remind_icon_list = {}

	CountDown.Instance:RemoveCountDown(self.tl_task_left_time_cd)
	self.tl_task_left_time_cd = nil
	self.time_limit_task_icon = nil
	self.turnview = nil
	-- self.img = nil
	self.turn_item = nil
	self.zhanwen_img = nil
	self.turn_rich_content = nil
	-- self.times = 0
	-- self.zhuanpan_right = nil

	if nil ~= self.alert then
		self.alert:DeleteMe()
		self.alert = nil
	end

	-- if self.diamond_pet_icon then
	-- 	self.diamond_pet_icon:DeleteMe()
	-- 	self.diamond_pet_icon = nil
	-- end

	if self.common_cell then
		self.common_cell:DeleteMe()
		self.common_cell = nil
	end
	if self.select_cell1 then
		self.select_cell1:DeleteMe()
		self.select_cell1 = nil
	end

	if self.select_cell2 then
		self.select_cell2:DeleteMe()
		self.select_cell2 = nil
	end

	if self.data_event then
		GlobalEventSystem:UnBind(self.data_event)
		self.data_event = nil
	end

	self:DeleteFuncBarList()

	self.arrow_root = nil
end

function MainuiSmallParts:RoleDataChangeCallback(vo)
	if vo.key == OBJ_ATTR.ACTOR_COIN or vo.key == OBJ_ATTR.CREATURE_LEVEL or vo.key == OBJ_ATTR.ACTOR_CIRCLE then
		self.bag_point:setVisible(BagData.Instance:GetBagRemind() or BagData.Instance:GetAllPoint())
	elseif vo.key == OBJ_ATTR.ACTOR_SWING_LEVEL and vo.value == 1 then
		self:CheckFuncGuideShow()
	end
end

function MainuiSmallParts:Init()
	self:InitAutoFight()
	self:InitAimBtn()
	-- self:InitCMenu()
	self:InitPick()
	self:InitBag()
	self:InitExc()
	self:InitTask()
	--self:InitTransmitPart()
	self:InitFuncBarList()
	-- self:InitPractice()
	self:InitFubenBar()
	self:InitTimeLimitTask()
	-- self:InitBiShaPreviewIcon()
	-- self:InitFindBoss()
	self:InitExcavateBossIcon()
	self:InitTransmitPartAndHuiChengShow()
end


function MainuiSmallParts:InitTransmitPartAndHuiChengShow()
--local right_top = self.main_view:GetPartLayout(MainuiView.LAYOUT_PART.RIGHT_TOP)
	local right_top =  MainuiCtrl.Instance:GetView():GetPartLayout(MainuiView.LAYOUT_PART.RIGHT_TOP)
	local right_top_size = right_top:getContentSize()

	if self.common_cell == nil then
		self.common_cell = MainUiIcon:CreateMainuiIcon1(right_top, ResPath.GetMainui("icon_random"), right_top_size.width - 191 - 15, 420)
		self.common_cell:AddClickEventListener(BindTool.Bind1(self.OnClickCell, self))
	end
	if self.arrow_img == nil then
		self.arrow_img = XUI.CreateImageView(right_top_size.width - 241 - 15, 420, ResPath.GetMainui("img_arrow2"), true)	-- 箭头
		right_top:TextureLayout():addChild(self.arrow_img, 99) 
		XUI.AddClickEventListener(self.arrow_img, BindTool.Bind1(self.Extend, self)) 
	end
	self.is_extend = false
	if self.select_cell1 == nil then
		self.select_cell1 = MainUiIcon:CreateMainuiIcon1(right_top, ResPath.GetMainui("icon_random"), right_top_size.width - 261 - 15, 420)
		self.select_cell1:AddClickEventListener(BindTool.Bind1(self.OnSelectCell, self))

		self.select_cell1:SetButtomPath(ResPath.GetMap("img_txt_2"))
		--self.select_cell1:SetVisible(false)
	end

	if self.select_cell2 == nil then
		self.select_cell2 = MainUiIcon:CreateMainuiIcon1(right_top, ResPath.GetMainui("icon_back_city"), right_top_size.width - 331 - 15, 420)
		self.select_cell2:AddClickEventListener(BindTool.Bind1(self.OnSelectCell2, self))
		self.select_cell2:SetButtomPath(ResPath.GetMap("img_txt_1"))
		--self.select_cell2:SetVisible(false)
	end
	self:FlushShowNum()
	self:FlushCellShow()
end

function MainuiSmallParts:Extend()
	self.is_extend = not self.is_extend
	self:FlushCellShow()
end

function MainuiSmallParts:FlushCellShow()
	self.select_cell1:SetVisible(self.is_extend)
	self.select_cell2:SetVisible(self.is_extend)
	local right_top =  MainuiCtrl.Instance:GetView():GetPartLayout(MainuiView.LAYOUT_PART.RIGHT_TOP)
	local right_top_size = right_top:getContentSize()
	local x = self.is_extend and right_top_size.width - 381 - 15 or right_top_size.width - 241 - 15
	self.arrow_img:setPositionX(x)
	local scalex = self.is_extend and 1 or -1
	self.arrow_img:setScaleX(scalex)
end

function MainuiSmallParts:OnSelectCell( ... )
	self.cur_index = 2
	self.is_extend = false
	self:FlushShowNum()
	self:FlushCellShow()
end

function MainuiSmallParts:OnSelectCell2( ... )
	self.cur_index = 1
	self.is_extend = false
	self:FlushShowNum()
	self:FlushCellShow()
end

function MainuiSmallParts:OnClickCell()
	self:OnClickUseStone(CLIENT_GAME_GLOBAL_CFG.mainui_stone[self.cur_index])
end

function MainuiSmallParts:FlushShowNum( ... )
	local item_id = CLIENT_GAME_GLOBAL_CFG.mainui_stone[self.cur_index]
	local num = BagData.Instance:GetItemNumInBagById(item_id, nil)
	local vis = num > 0 and true or false
	self.common_cell:SetGrey(not vis)
	local color = vis and COLOR3B.GREEN or COLOR3B.RED
	self.common_cell:SetRingthContent(num, color)

	local path = self.cur_index == 2 and ResPath.GetMainui("icon_random") or ResPath.GetMainui("icon_back_city")

	self.common_cell:SetIconImg(path)

	local path1 = self.cur_index == 2 and ResPath.GetMap("img_txt_2") or ResPath.GetMap("img_txt_1")
	self.common_cell:SetButtomPath(path1)
end


function MainuiSmallParts:SetIsShow(is_show)
	self.common_cell:SetVisible(is_show)
	self.arrow_img:setVisible(is_show)
	self.is_extend = false
	self:FlushCellShow()
end
------------------------------------------------------------------------
-- 通用
------------------------------------------------------------------------
function MainuiSmallParts:OnBagItemChange(event)
	if self.prestige_task_tip then
		self.prestige_task_tip:Flush()
	end

	self:FlushShowNum()
	if IS_ON_CROSSSERVER then return end
	if RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) <= RemindLimitAll then return end
	-- if event.GetChangeDataList()[1] and event.GetChangeDataList()[1].change_type == ITEM_CHANGE_TYPE.LIST then
	--	self.bag_point:setVisible(BagData.Instance:GetCanRecycleReimdNum() > 0 or BagData.Instance:GetBagRemind())
	-- else
	-- 	event.CheckAllItemDataByFunc(function (vo)
	-- 		if ItemData.GetIsEquip(vo.data.item_id) then
	-- 			self.bag_point:setVisible(BagData.Instance:GetCanRecycleReimdNum() > 0)
	-- 		else
	-- 			self.bag_point:setVisible(BagData.Instance:GetBagRemind())
	-- 		end
	-- 	end)
	-- end	
	--BagData.Instance:GetCanRecycleReimdNum() > 0 
	self.bag_point:setVisible(BagData.Instance:GetBagRemind() or BagData.Instance:GetAllPoint())
	-- self.bag_point:setVisible(true)	
end

function MainuiSmallParts:RemindGroupChange(group_name, num)
	-- if group_name == RemindGroupName.ShiLianView then
	-- 	self:FlushZhanWenRemind()
	-- end
	if self.remind_icon_list[group_name] then
		self.remind_icon_list[group_name]:SetRemindNum(num)
	end

	if group_name == TimeLimitTaskIcon.remind_group then
		self.time_limit_task_icon:SetRemindNum(num)
	end

	if self.treasure_icon then
		if group_name == RemindGroupName.TreasureAtticView then
			self.treasure_icon:UpdateReimd()
		end
	end
	
	-- if self.diamond_pet_icon then
	-- 	if group_name == DiamondPetIcon.remind_group then
	-- 		self.diamond_pet_icon:SetRemindNum(num)
	-- 	end
	-- end

	if group_name == ViewDef.GodFurnace.TheDragon.remind_group_name or
		group_name == ViewDef.GodFurnace.Shield.remind_group_name or
		group_name == ViewDef.GodFurnace.DragonSpirit.remind_group_name or
		group_name == ViewDef.GodFurnace.GemStone.remind_group_name or
		group_name == ViewDef.QieGeView.remind_group_name or
		group_name == ViewDef.Role.remind_group_name or
		group_name == ViewDef.Wing.remind_group_name then
		self:FlushFuncGuide() 
	end
end


function MainuiSmallParts:OnGameCondChange(cond_name, is_all_ok)
	self:FlushTaskGuide(cond_name)

	if self.cond_list[cond_name] then
		self:FlushFuncBarPos()
		-- self:FlushFuncGuide() 
	end

	if cond_name == TimeLimitTaskIcon.vis_cond then
		-- 开启时自动打开限时任务提醒面板
		-- if is_all_ok then
		-- 	ViewManager.Instance:OpenViewByDef(ViewDef.TimeLimitTaskRemind)
		-- end
		self:UpdateTimeLimitTaskIcon()
	-- elseif cond_name == BiShaPreviewIcon.vis_cond then
		-- self:FlushBiShaPreviewIcon()
	-- elseif cond_name == FindBossIcon.vis_cond then
		-- self:UpdateFindBossIcon()
	-- elseif cond_name == DiamondPetIcon.vis_cond then
	-- 	-- self:UpdateDiamondPetIcon()
	end

	if cond_name == "CondId140" then
		self.btn_exc:setVisible(GameCondMgr.Instance:GetValue("CondId140"))
	end

	if cond_name == "CondId160" then
		self.btn_task:setVisible(GameCondMgr.Instance:GetValue("CondId160"))
	end
end

function MainuiSmallParts:OnItemChange(vo)
	-- self:UpdateStoneNum()
end

function MainuiSmallParts:OnGetUiNode(node_name)
	local view_node = ViewManager.Instance:GetViewByStr(node_name)
	if nil == view_node then
		return nil, false
	end

	if view_node == ViewDef.BiShaPreview then
		return self.bisha_preview_icon:GetView(), true
	end
end

function MainuiSmallParts:OnSceneChangeComplete()
	-- self:UpdateFindBossIcon()
	-- self:UpdateSecondKill()

	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local scene_id = main_role_vo.scene_id
	if scene_id == PrestigeSysConfig.nSceneId then
		self:InitPrestigeTaskTipView()
	else
		if self.prestige_task_tip then
			self.prestige_task_tip:Release()
			self.prestige_task_tip = nil
		end
	end
	if scene_id == WeiZhiAnDianCfg.SceneId then
		self:InituUnknownDarkHouseTip()
		self:InituUnknownDarkHouseExp()
	else
		if self.unknown_dark_house_tip then
			self.unknown_dark_house_tip:Release()
			self.unknown_dark_house_tip = nil
		end
		if self.unknown_dark_house_exp then
			self.unknown_dark_house_exp:Release()
			self.unknown_dark_house_exp = nil
		end
	end

	if ActivityData.IsInEscortActivityScene() then
		self:InitEscortBar()
		-- 自动押镖处理
		if ActivityData.Instance:IsAutoYabiao() then
			MoveCache.end_type = MoveEndType.Normal
			ActivityData.Instance:SetAutoYabiao(true)
		end
	else
		if self.layout_escort_bar then
			self.layout_escort_bar:removeFromParent()
			self.layout_escort_bar = nil
		end
	end

end

function MainuiSmallParts:OnTaskDataChange()
	if self.prestige_task_tip then
		self.prestige_task_tip:Flush()
	end
end

function MainuiSmallParts:OnUnknownDarkHouseExpChange()
	if self.unknown_dark_house_tip then
		self.unknown_dark_house_tip:Flush()
	end
end

function MainuiSmallParts:OnUnknownDarkHouseDataChange()
	if self.unknown_dark_house_exp then
		self.unknown_dark_house_exp:Flush()
	end
	if self.unknown_dark_house_tip then
		self.unknown_dark_house_tip:Flush()
	end
end

-- 主界面"退出"按钮点击回调
function MainuiSmallParts:OnClickExitFuben()
	self.alert = self.alert or Alert.New()

	-----请求退出的方法-----

	-- 退出副本
	local function ExitFuben()
		-- 正在挑战vip_boss时,结束挑战
		local vip_boss_timer = VipCtrl.Instance:GetVipBossTimer()
		if vip_boss_timer then
			GlobalTimerQuest:EndQuest(vip_boss_timer)
		else
			local fuben_id = FubenData.Instance:GetFubenId()
			FubenCtrl.OutFubenReq(fuben_id)
		end
		if self.arrow_root then
			self.arrow_root:setVisible(false)
		end
	end

	-- 退出活动场景
	local function ExitActivityScene()
		-- 世界BOSS被击杀时,禁止主动退出活动
		if ActivityData.Instance:GetActivityID() == DAILY_ACTIVITY_TYPE.SHI_JIE_BOSS then
			local ranking_data = ActivityData.Instance:GetRankingData()
			if ranking_data.world_boss_die == 1 then
				local cfg = StdActivityCfg[DAILY_ACTIVITY_TYPE.SHI_JIE_BOSS] or {}
				SysMsgCtrl.Instance:FloatingTopRightText(string.format(cfg.bossDieNotice or "", cfg.bossDieKickTimes or 8))
				return
			end
		end

		-- 行会BOSS被击杀时,禁止主动退出活动
		if ActivityData.Instance:GetActivityID() == DAILY_ACTIVITY_TYPE.HANG_HUI_BOSS then
			local ranking_data = ActivityData.Instance:GetRankingData()
			if ranking_data.guild_boss_die == 1 then
				local cfg = StdActivityCfg[DAILY_ACTIVITY_TYPE.HANG_HUI_BOSS] or {}
				SysMsgCtrl.Instance:FloatingTopRightText(string.format("请大家%d秒内不要退出活动,等候发奖励!", cfg.endTimeCD or 8))
				return
			end
		end

		ActivityCtrl.Instance.ExitActivityScene()
	end

	-- 退出跨服副本
	local function ExitCrossServerCopy()
		CrossServerCtrl.Instance.SentQuitCrossServerReq()
	end
	-----end-----

	-- 据场景设置提示中的"确定"按钮点击回调
	local func
	local text
	if IS_ON_CROSSSERVER then
		func = ExitCrossServerCopy
		text = Language.Boss.ExitFubenAlert
	elseif ActivityData:IsInActivityScene() then
		func = ExitActivityScene
		text = Language.Activity.LeaveActAlertContent
	else
		func = ExitFuben
		text = Language.Boss.ExitFubenAlert
	end

	self.alert:SetLableString(text)
	self.alert:SetOkString(Language.Common.Confirm)
	self.alert:SetCancelString(Language.Common.Cancel)
	self.alert:SetOkFunc(func)
	self.alert:Open()
end

-- 主界面"押镖"按钮点击回调
function MainuiSmallParts:OnClickEscortBar(index)
	if index == 1 then -- 放弃护送
		self.alert = self.alert or Alert.New()
		self.alert:SetLableString(Language.Activity.GiveUpCarAlert)
		self.alert:SetOkString(Language.Common.Confirm)
		self.alert:SetCancelString(Language.Common.Cancel)
		self.alert:SetOkFunc(function()
			ActivityCtrl.SentQuitEscortReq()
		end)
		self.alert:Open()
	elseif index == 2 then -- 传送镖车
		self.alert = self.alert or Alert.New()
		self.alert:SetLableString(Language.Activity.CSAlert)
		self.alert:SetOkString(Language.Common.Confirm)
		self.alert:SetCancelString(Language.Common.Cancel)
		self.alert:SetOkFunc(function ()
			ActivityCtrl.SentTransmitToCarReq()
			end)
		self.alert:Open()
	elseif index == 3 then -- 继续镖车
		if ActivityData.Instance:GetActivityID() == DAILY_ACTIVITY_TYPE.YA_SONG then
			MoveCache.end_type = MoveEndType.Normal
			Scene.Instance:GetMainRole():StopMove()
			ActivityCtrl.Instance:MoveToBiaoche()
			ActivityCtrl.Instance:StartAutoEscort()
		else
			SysMsgCtrl.Instance:FloatingTopRightText(Language.Activity.GoOnCarAlert)
		end
	end
end

-- 打开奖励预览
function MainuiSmallParts:OnClickPreview()
    ViewManager.Instance:OpenViewByDef(ViewDef.RewardPreview)
end

-- 行会禁地开启按钮
function MainuiSmallParts:OnClickStartFuben()
	UiInstanceMgr.DelRectEffect(self.layout_fuben_bar:getChildByTag(20))
	-- 是否是第二层
	local is_second_scene = FubenData.Instance:HhjdIsSecond()
	-- 是否是已开启（二层一定是开启）
	local is_open = is_second_scene and true or (FubenData.Instance:GetHhjdFbAreaState() ~= HHJD_AREA_STATE.WAIT)
	local team_id = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_TEAM_ID)
	local is_leader = FubenTeamData.Instance:IsLeaderForMe(FubenMutilType.Hhjd, FubenMutilLayer.Hhjd1, team_id)
	if not is_leader then
		self.layout_fuben_bar:getChildByTag(20):getChildByTag(10):loadTexture(ResPath.GetMainui("bar_22_word"))
	end
	if is_open or not is_leader then
		-- 自动寻路打怪
		GlobalTimerQuest:AddDelayTimer(function()
			if Scene.Instance:GetMainRole():IsMove() then
				return
			end
			local scene_logic = Scene.Instance:GetSceneLogic()
			if scene_logic.AutoMoveFight then scene_logic:AutoMoveFight() end
		end, 1)
	else
		if FubenData.Instance:GetHhjdTeamMemberCount() <= 1 then
			self.alert = self.alert or Alert.New()
			self.alert:SetLableString(Language.Fuben.HhjdMemberTip)
			self.alert:SetOkFunc(function()
				FubenCtrl.StartHhjdReq()
				self.layout_fuben_bar:getChildByTag(20):getChildByTag(10):loadTexture(ResPath.GetMainui("bar_22_word"))
			end)
			self.alert:SetShowCheckBox(false)
			self.alert:SetOkString(Language.Fuben.OnePeopleChallenge)
			self.alert:SetCancelString(Language.Fuben.ContinueWait)
			self.alert:Open()
		else
			FubenCtrl.StartHhjdReq()
			self.layout_fuben_bar:getChildByTag(20):getChildByTag(10):loadTexture(ResPath.GetMainui("bar_22_word"))
		end
	end

end

local icon_sort_func = function(a, b)
	return a.order and a.order < b.order or false
end
function MainuiSmallParts:FlushFuncBarPos()
	for k, v in pairs(self.func_bar_items) do
		v:setVisible((nil == v.bar_data.vis_cond) or GameCondMgr.Instance:GetValue(v.bar_data.vis_cond))
	end
	table.sort(self.func_bar_items, icon_sort_func)

	local x = -5
	local y = 0
	local count = 0
	for i, v in ipairs(self.func_bar_items) do
		if v:isVisible() then
			count = count + 1
			y = - (count - 1) * (60 - 3)
			v:setPosition(x, y)
		end
	end
end

function MainuiSmallParts:CreateFuncBarItem(data)
	local item_size = cc.size(150, 60)
	local item = XUI.CreateLayout(0, 0, item_size.width, item_size.height)
	item:setAnchorPoint(0, 0.5)
	local img = XUI.CreateImageView(item_size.width / 2, item_size.height / 2, ResPath.GetMainui("bar_" .. data.res .. "_img"), true)
	local word = XUI.CreateImageView(50, item_size.height / 2, ResPath.GetMainui("bar_" .. data.res .. "_word"), true)
	item:addChild(img)
	item:addChild(word)
	item.bar_data = data
	self.func_bar_items[#self.func_bar_items + 1] = item
	XUI.AddClickEventListener(item, BindTool.Bind(self.OnClickFuncBarItem, self, item), true)

	function item:SetRemindNum(num, x, y)
		if nil == self.remind_bg_img then
			local size = self:getContentSize()
			self.remind_bg_img = XUI.CreateImageView(x or (size.width - 15), y or (size.height - 10), ResPath.GetMainui("remind_flag"), true)
			-- CommonAction.ShowRemindBlinkAction(self.remind_bg_img)
			self:addChild(self.remind_bg_img, 300, 300)
		end
		self.remind_bg_img:setVisible(num > 0)
	end

	self.layout_func_bar:addChild(item)

	return item
end

function MainuiSmallParts:RightMenuChange(is_show)
	self.btn_pick:setVisible(is_show)
	self:SetIsShow(is_show)
	-- self.btn_bag:setVisible(is_show)
	-- self.bag_point:setVisible(is_show)
	self.btn_auto_fight:setVisible(is_show)
	self.btn_auto_fight.eff:setVisible(self.btn_auto_fight:isVisible() and GuajiCache.guaji_type == GuajiType.Auto)
	self.btn_aim:setVisible(is_show)
end

function MainuiSmallParts:OnMapChange()

end

function MainuiSmallParts:OnClickPractice()
	local cur_bless = PracticeCtrl.Instance.cur_bless
	local need_bless = PracticeCtrl.Instance.need_bless
	if cur_bless >= need_bless then
		PracticeCtrl.SendEnterPractice(2)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.NoEnoughBless)	
	end
end


function MainuiSmallParts:OnGetUiNode(node_name)
	if nil ~= self.layout_func_bar then
		if node_name == "MainuiTaskGuide" then
			if nil == self.task_listview:GetItemAt(1) then return end
			self.task_listview:JumpToTop()
			return self.task_listview:GetItemAt(1):GetView()
		end

		local view_node = ViewManager.Instance:GetViewByStr(node_name)
		local func_bar = nil
		for k, v in pairs(self.func_bar_items) do
			if v.bar_data.node_name and v.bar_data.node_name == node_name then
				func_bar = v
				break
			end
		end
		if nil ~= func_bar then
			if self.layout_func_bar.is_right then
				return func_bar, true
			else
				local x, y = self.layout_func_bar:getChildByTag(99):getPosition()
				return self.layout_func_bar:getChildByTag(99), false
			end
		end
	end
end

function MainuiSmallParts:InitFubenBar()
	local left_top = self.main_view:GetPartLayout(MainuiView.LAYOUT_PART.LEFT_TOP)

	-- 可以左右移动的布局
	self.layout_fuben_bar = XUI.CreateLayout(0, 590, 150, 0)
	self.layout_fuben_bar.right_pos = cc.p(75, 590)	-- 右边的坐标
	self.layout_fuben_bar.left_pos = cc.p(-145 + 75, 590)	-- 左边的坐标
	self.layout_fuben_bar.is_right = true	-- 当前坐标是否在右边
	left_top:TextureLayout():addChild(self.layout_fuben_bar, 1, 88)

	local item_size = cc.size(150, 60)
	local item = XUI.CreateLayout(70, -80, item_size.width, item_size.height)
	item:setAnchorPoint(0, 0.5)
	local img = XUI.CreateImageView(item_size.width / 2, item_size.height / 2, ResPath.GetMainui("bar_10_img"), true)
	local word = XUI.CreateImageView(50, item_size.height / 2, ResPath.GetMainui("bar_10_word"), true)
	item:addChild(img)
	item:addChild(word)
	XUI.AddClickEventListener(item, BindTool.Bind(self.OnClickExitFuben, self), true)


	local item1 = XUI.CreateLayout(70, -160, item_size.width, item_size.height)
	item1:setAnchorPoint(0, 0.5)
	local img1 = XUI.CreateImageView(item_size.width / 2, item_size.height / 2, ResPath.GetMainui("bar_02_img"), true)
	local word1 = XUI.CreateImageView(50, item_size.height / 2, ResPath.GetMainui("bar_12_word"), true)
	item1:addChild(img1)
	item1:addChild(word1, 10, 10)
	item1:setVisible(false)
	XUI.AddClickEventListener(item1, BindTool.Bind(self.OnClickStartFuben, self), true)

	self.layout_fuben_bar:addChild(item)
	self.layout_fuben_bar:addChild(item1, 10, 20)
	self.layout_fuben_bar:setVisible(false)


end

--积分奖励预览
function MainuiSmallParts:InitRewardPreviewBar()
	local left_top = self.main_view:GetPartLayout(MainuiView.LAYOUT_PART.LEFT_TOP)

	-- 可以左右移动的布局
	self.layout_reward_preview_bar = XUI.CreateLayout(0, 590, 150, 0)
	self.layout_reward_preview_bar.right_pos = cc.p(75, 590)	-- 右边的坐标
	self.layout_reward_preview_bar.left_pos = cc.p(-145 + 75, 590)	-- 左边的坐标
	self.layout_reward_preview_bar.is_right = true	-- 当前坐标是否在右边
	left_top:TextureLayout():addChild(self.layout_reward_preview_bar, 1)

    
    --奖励预览
    local preview_size = cc.size(68, 72)
	local reward_preview = XUI.CreateLayout(85, -160, preview_size.width, preview_size.height)
	reward_preview:setAnchorPoint(0, 0.5)
	
	local reward_bg = XUI.CreateImageView(preview_size.width / 2, preview_size.height / 2, ResPath.GetMainui("icon_bg"), true)
	local reward_img = XUI.CreateImageView(preview_size.width / 2, preview_size.height / 2, ResPath.GetMainui("icon_204_img"), true)
	local reward_word = XUI.CreateImageView(preview_size.width / 2, 0, ResPath.GetMainui("icon_204_word"), true)
	reward_preview:addChild(reward_bg)
	reward_preview:addChild(reward_img)
	reward_preview:addChild(reward_word)
	XUI.AddClickEventListener(reward_preview, BindTool.Bind(self.OnClickPreview, self), true)
    
    self.layout_reward_preview_bar:addChild(reward_preview)
end

-- 押镖按钮显示
function MainuiSmallParts:InitEscortBar()
	if self.layout_escort_bar then return end
	local left_top = self.main_view:GetPartLayout(MainuiView.LAYOUT_PART.LEFT_TOP)

	-- 可以左右移动的布局
	self.layout_escort_bar = XUI.CreateLayout(0, 483, 142, 0)
	self.layout_escort_bar.right_pos = cc.p(75, 590)	-- 右边的坐标
	self.layout_escort_bar.left_pos = cc.p(-142 + 75, 590)	-- 左边的坐标
	self.layout_escort_bar.is_right = true	-- 当前坐标是否在右边
	left_top:TextureLayout():addChild(self.layout_escort_bar, 1)

	
	--面板刷新奖励预览
	local bar_size = cc.size(142, 180)
	local escort_bar = XUI.CreateLayout(71, 0, bar_size.width, bar_size.height)
	escort_bar:setAnchorPoint(0, 0.5)
	
	local escort_bar_1 = XUI.CreateImageView(0, 60, ResPath.GetMainui("escort_bar_1"), true)
	escort_bar_1:setAnchorPoint(0, 0.5)
	local escort_bar_2 = XUI.CreateImageView(0, 3, ResPath.GetMainui("escort_bar_2"), true)
	escort_bar_2:setAnchorPoint(0, 0.5)
	local escort_bar_3 = XUI.CreateImageView(0, -54, ResPath.GetMainui("escort_bar_3"), true)
	escort_bar_3:setAnchorPoint(0, 0.5)
	escort_bar:addChild(escort_bar_1)
	escort_bar:addChild(escort_bar_2)
	escort_bar:addChild(escort_bar_3)
	XUI.AddClickEventListener(escort_bar_1, BindTool.Bind(self.OnClickEscortBar, self, 1), true)
	XUI.AddClickEventListener(escort_bar_2, BindTool.Bind(self.OnClickEscortBar, self, 2), true)
	XUI.AddClickEventListener(escort_bar_3, BindTool.Bind(self.OnClickEscortBar, self, 3), true)

	self.layout_escort_bar:addChild(escort_bar)
end

---------------------------------------------------
-- 副本界面
---------------------------------------------------
function MainuiSmallParts:OnEnterFuben(scene_id, scene_type, fuben_id)
	if nil == self.layout_fuben_bar then 
		self:InitFubenBar()
	end
	if nil == self.task_ui_node_list.layout_task then 
		self:InitFuncBarList()
	end
	if nil == self.layout_transmit then 
		--self:InitTransmitPart()
	end
    if nil == self.layout_reward_preview_bar then 
		self:InitRewardPreviewBar()
	end
    local sign = ActivityData.IsInZhenyingActivityScene()
    self.layout_reward_preview_bar:setVisible(sign) -- 设置"奖励预览"按钮显示
  
	local state = ActivityData.IsInActivityScene() -- 是否在活动场景
	self.layout_fuben_bar:setVisible(fuben_id > 0 or state) -- 设置"退出"按钮显示

	if self.layout_fuben_bar:getChildByTag(20):isVisible() then
		self.layout_fuben_bar:getChildByTag(20):setVisible(false)
		UiInstanceMgr.DelRectEffect(self.layout_fuben_bar:getChildByTag(20))
	end

	local trial_cfg = TrialConfig and TrialConfig.chapters and TrialConfig.chapters[1]
	local trial_sceneid = trial_cfg.sceneid or 0
	if FubenData.FubenCfg[FubenType.Hhjd][1].fubenId == fuben_id or FubenData.FubenCfg[FubenType.Hhjd2][1].FbId == fuben_id then
		self.layout_fuben_bar:getChildByTag(20):setVisible(true)
		if FubenData.FubenCfg[FubenType.Hhjd][1].fubenId == fuben_id then
			UiInstanceMgr.AddRectEffect({node = self.layout_fuben_bar:getChildByTag(20)})
		end
	elseif scene_id == trial_sceneid or scene_id ==  BabelTowerFubenConfig.layerlist[1].sceneid then -- 试练场景调整坐标
		local center_left = MainuiCtrl.Instance:GetView():GetPartLayout(MainuiView.LAYOUT_PART.CENTER_LEFT)
		local size = center_left:getContentSize()
		self.layout_fuben_bar:setPosition(305, size.height / 2 - 60)
		self.layout_fuben_bar:setBackGroundColor(COLOR3B.GREEN)
	elseif IS_ON_CROSSSERVER or FubenMutilLayer[scene_id] then
		self.layout_fuben_bar:setPosition(0, 380)
	-- elseif FubenMutilLayer[scene_id] then
	-- 	self.layout_fuben_bar:setPosition(303, 438)
	else
		self.layout_fuben_bar:setPosition(0, 590)
	end

	if scene_id == expFubenConfig.senceid or scene_id == PurgatoryFubenConfig.senceid then --经验副本不适用这个
		self.layout_fuben_bar:setVisible(false)
	end

	if self.arrow_root then
		self.arrow_root:setVisible(false)
	end
end

-- 引导-用于引导点击"退出"按钮
function MainuiSmallParts:CreateExitFuBenGuide()
	self.arrow_root = cc.Node:create()
	self.layout_fuben_bar:addChild(self.arrow_root, 1)
	self.arrow_root:setPosition(220, -80)
	self.arrow_node = cc.Node:create()
	self.arrow_root:addChild(self.arrow_node)
	local arrow_frame = XButton:create(ResPath.GetGuide("arrow_frame"), "", "")
	arrow_frame:setTitleFontSize(25)
	arrow_frame:setTitleText("退出副本")
	arrow_frame:setTouchEnabled(false)
	self.arrow_node:addChild(arrow_frame)
	arrow_frame:setTitleFontName(COMMON_CONSTS.FONT)
	local label = arrow_frame:getTitleLabel()
	if label then
		label:setColor(COLOR3B.G_Y)
		label:enableOutline(cc.c4b(0, 0, 0, 100), 1.5)
	end
	local arrow_point = XUI.CreateImageView(0, 0, ResPath.GetGuide("arrow_point"))
	arrow_point:setAnchorPoint(1, 0.5)
	self.arrow_node:addChild(arrow_point)

	self.arrow_root:setColor(COLOR3B.GREEN)

	local arrow = "left"
	local offset_x = 35
	local rotation, anc_x, anc_y, x, y = -90, 0.5, 1, 0, -offset_x
	local move1, move2 = nil, nil
	if arrow == "up" then
		rotation, anc_x, anc_y, x, y = -90, 0.5, 1, 0, -offset_x
		move1 = cc.MoveTo:create(0.5, cc.p(0, -10))
		move2 = cc.MoveTo:create(0.5, cc.p(0, 0))
	elseif arrow == "down" then
		rotation, anc_x, anc_y, x, y = 90, 0.5, 0, 0, offset_x
		move1 = cc.MoveTo:create(0.5, cc.p(0, 10))
		move2 = cc.MoveTo:create(0.5, cc.p(0, 0))
	elseif arrow == "left" then
		rotation, anc_x, anc_y, x, y = 180, 0, 0.5, offset_x, 0
		move1 = cc.MoveTo:create(0.5, cc.p(10, 0))
		move2 = cc.MoveTo:create(0.5, cc.p(0, 0))
	else
		rotation, anc_x, anc_y, x, y = 0, 1, 0.5, -offset_x, 0
		move1 = cc.MoveTo:create(0.5, cc.p(-10, 0))
		move2 = cc.MoveTo:create(0.5, cc.p(0, 0))
	end

	arrow_point:setRotation(rotation)
	arrow_frame:setAnchorPoint(anc_x, anc_y)
	arrow_frame:setPosition(x, y)
	local action = cc.RepeatForever:create(cc.Sequence:create(move1, move2))
	self.arrow_node:stopAllActions()
	self.arrow_node:runAction(action)
end

---------------------------------------------------
-- 回城石
---------------------------------------------------
function MainuiSmallParts:InitTransmitPart()
	if nil ~= self.layout_transmit then
		return
	end
	local bottom_left = self.main_view:GetPartLayout(MainuiView.LAYOUT_PART.BOTTOM_LEFT)
	self.layout_transmit = MainuiMultiLayout.CreateMultiLayout(bottom_left:getContentSize().width, 255, cc.p(1, 0.5), cc.size(10, 100), bottom_left, 1)

	self.layout_transmit.begin_pos = cc.p(150, 300)
	self.layout_transmit.normal_size = cc.size(0, 100)
	self.layout_transmit.content_num = 0
	self.layout_transmit.is_extend = false
	self.layout_transmit.is_acting = false
	self.layout_transmit.content_size = cc.size(70, 70)

	self.layout_transmit.arrow_node = XUI.CreateImageView(0, 0, ResPath.GetMainui("img_arrow"))	-- 箭头
	self.layout_transmit:TextureLayout():addChild(self.layout_transmit.arrow_node)

	-- 添加图标
	self.layout_transmit.AddContent = function(res_path, click_func)
		self.layout_transmit.content_num = self.layout_transmit.content_num + 1
		local content_size = self.layout_transmit.content_size
		local content_num = self.layout_transmit.content_num
		local item_interval = 10
		local new_width = content_size.width * content_num + (content_num - 1) * item_interval
		self.layout_transmit:setContentSize(cc.size(new_width, self.layout_transmit.normal_size.height))
		self.layout_transmit.arrow_node:setPosition(new_width+25, self.layout_transmit:getContentSize().height / 2)
		local x = content_size.width / 2 + (content_num - 1) * (content_size.width + item_interval)
		local icon = MainuiMultiLayout.CreateMultiLayout(x, self.layout_transmit:getContentSize().height / 2, cc.p(0.5, 0.5), content_size, self.layout_transmit, 1)
		icon:TextureLayout():addChild(XUI.CreateImageView(content_size.width / 2, content_size.height / 2, res_path, true), 2, 2)
		if click_func then
			icon:AddClickEventListener(click_func)
		end
		return icon
	end

	-- 刷新扩展显示
	self.layout_transmit.FlushExtend = function()
		self.layout_transmit:stopAllActions()
		self.layout_transmit.is_acting = false
		if self.layout_transmit.is_extend then
			self.layout_transmit:setPositionX(self.layout_transmit.begin_pos.x)
			self.layout_transmit.arrow_node:setRotation(-90)
		else
			self.layout_transmit:setPositionX(self.layout_transmit.begin_pos.x - self.layout_transmit.content_size.width)
			self.layout_transmit.arrow_node:setRotation(90)
		end
	end

	-- 扩展点击事件
	XUI.AddClickEventListener(self.layout_transmit.arrow_node, function()
		if self.layout_transmit.is_acting then
			return
		end
		self.layout_transmit.is_extend = not self.layout_transmit.is_extend
		self.layout_transmit.is_acting = true
		local x, y = self.layout_transmit:getPosition()
		if self.layout_transmit.is_extend then
			x = self.layout_transmit.begin_pos.x
		else
			x = self.layout_transmit.begin_pos.x  - self.layout_transmit.content_size.width
		end
		
		self.layout_transmit:runAction(cc.Sequence:create(cc.MoveTo:create(0.1, cc.p(x, y))))
		GlobalTimerQuest:AddDelayTimer(function()
			self.layout_transmit.FlushExtend()
		end, 0.12)
	end)

	self.stone_list = {
		{item_id = CLIENT_GAME_GLOBAL_CFG.mainui_stone[2], click_func = function() self:OnClickUseStone(CLIENT_GAME_GLOBAL_CFG.mainui_stone[2]) end, res_path = ResPath.GetMainui("icon_random")},
		{item_id = CLIENT_GAME_GLOBAL_CFG.mainui_stone[1], click_func = function() self:OnClickUseStone(CLIENT_GAME_GLOBAL_CFG.mainui_stone[1]) end, res_path = ResPath.GetMainui("icon_back_city")},
	}
	for k, v in pairs(self.stone_list) do
		v.icon = self.layout_transmit.AddContent(v.res_path, v.click_func)
	end

	self.layout_transmit.FlushExtend()
	-- self:UpdateStoneNum()
end

function MainuiSmallParts:OnClickUseStone(item_id)
	local stone_item = BagData.Instance:GetItem(item_id)
	if stone_item ~= nil then
		BagCtrl.Instance:SendUseItem(stone_item.series, 1)
	else
		TipCtrl.Instance:OpenQuickBuyItem({item_id})
	end
end

function MainuiSmallParts:UpdateStoneNum(event)
	if nil == event then
			for k, v in pairs(self.stone_list) do
			local num = BagData.Instance:GetItemDurabilityInBagById(v.item_id) / 1000
			local icon = v.icon
			if nil == icon.lbl_num then
				local lbl_num = XUI.CreateText(50, 47, 200, 20, nil, "", nil, 20, COLOR3B.GREEN)
				icon:TextLayout():addChild(lbl_num)
				icon.lbl_num = lbl_num
			end
			icon.lbl_num:setString(tostring(num))
			icon.lbl_num:setVisible(num > 0)
			icon:TextureLayout():getChildByTag(2):setGrey(num < 1)
		end
	else
		event.CheckAllItemDataByFunc(function (vo)
			if nil ~= vo and vo.change_type ~= ITEM_CHANGE_TYPE.LIST then
				local is_stone = false
				for k, v in pairs(self.stone_list) do
					if v.item_id == vo.data.item_id then
						is_stone = true
					end
				end
				if not is_stone then
					return
				end
			end

			for k, v in pairs(self.stone_list) do
				local num = BagData.Instance:GetItemDurabilityInBagById(v.item_id) / 1000
				local icon = v.icon
				if nil == icon.lbl_num then
					local lbl_num = XUI.CreateText(50, 47, 200, 20, nil, "", nil, 20, COLOR3B.GREEN)
					icon:TextLayout():addChild(lbl_num)
					icon.lbl_num = lbl_num
				end
				icon.lbl_num:setString(tostring(num))
				icon.lbl_num:setVisible(num > 0)
				icon:TextureLayout():getChildByTag(2):setGrey(num < 1)
			end
		end)
	end
end

---------------------------------------------------
-- 自动战斗 begin
---------------------------------------------------
function MainuiSmallParts:InitAutoFight()
	local right_top = self.main_view:GetPartLayout(MainuiView.LAYOUT_PART.RIGHT_TOP)
	local right_top_size = right_top:getContentSize()

	self.btn_auto_fight = XUI.CreateImageView(right_top_size.width - 36 - 15, 420, ResPath.GetMainui("auto_fight"))
	right_top:TextureLayout():addChild(self.btn_auto_fight, 1)
	XUI.AddClickEventListener(self.btn_auto_fight, BindTool.Bind(self.OnClickAutoFight, self))

	self.btn_auto_fight.eff = RenderUnit.CreateEffect(1175, right_top:EffectLayout(), 2, FrameTime.Effect, COMMON_CONSTS.MAX_LOOPS, right_top_size.width - 36 - 15, 420)
	self.btn_auto_fight.eff:setVisible(false)
end

function MainuiSmallParts:OnGuajiTypeChange(guaji_type)
	if guaji_type == GuajiType.Auto then
		self.btn_auto_fight:loadTexture(ResPath.GetMainui("auto_fight_cancel"))
	else
		self.btn_auto_fight:loadTexture(ResPath.GetMainui("auto_fight"))
	end
	self.btn_auto_fight.eff:setVisible(self.btn_auto_fight:isVisible() and guaji_type == GuajiType.Auto)
end

function MainuiSmallParts:OnClickAutoFight()
	if GuajiCache.guaji_type ~= GuajiType.Auto then
		Scene.Instance:GetMainRole():StopMove()
		GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
	else
		Scene.Instance:GetMainRole():StopMove()
	end
end
---------------------------------------------------
-- 自动战斗 end
---------------------------------------------------


---------------------------------------------------
-- 选定目标
---------------------------------------------------
function MainuiSmallParts:InitAimBtn()
	local right_top = self.main_view:GetPartLayout(MainuiView.LAYOUT_PART.RIGHT_TOP)
	local right_top_size = right_top:getContentSize()

	self.btn_aim = XUI.CreateImageView(right_top_size.width - 115 - 15, 420, ResPath.GetMainui("img_tag"))
	right_top:TextureLayout():addChild(self.btn_aim, 1)
	XUI.AddClickEventListener(self.btn_aim, function ()
		ViewManager.Instance:GetView(ViewDef.MainUi):OpenNearTarget()
	end)
end

---------------------------------------------------
-- 右下菜单
---------------------------------------------------
function MainuiSmallParts:InitCMenu()
	local right_top = self.main_view:GetPartLayout(MainuiView.LAYOUT_PART.RIGHT_TOP)
	local right_top_size = right_top:getContentSize()

	self.btn_c_menu = XUI.CreateImageView(right_top_size.width - 36, 490, ResPath.GetMainui("img_menu"))
	right_top:TextureLayout():addChild(self.btn_c_menu, 1)
	XUI.AddClickEventListener(self.btn_c_menu, function ()
		-- ViewManager.Instance:GetView(ViewDef.MainUi):OpenNearTarget()
	end)
end

---------------------------------------------------
-- 拾取
---------------------------------------------------
function MainuiSmallParts:GetPickIcon()
	return self.btn_pick
end

function MainuiSmallParts:InitPick()
	local right_top = self.main_view:GetPartLayout(MainuiView.LAYOUT_PART.RIGHT_TOP)
	local right_top_size = right_top:getContentSize()

	self.btn_pick = XUI.CreateImageView(right_top_size.width - 315, 149, ResPath.GetMainui("img_pick"))
	right_top:TextureLayout():addChild(self.btn_pick, 1)
	XUI.AddClickEventListener(self.btn_pick, function ()
		local fallitem_obj = Scene.Instance:SelectMinRemindFallItem(nil, true)
		if nil ~= fallitem_obj then
			GuajiCtrl.Instance:OnSelectObj(fallitem_obj)
		else
			SysMsgCtrl.Instance:FloatingTopRightText(Language.Mainui.NoFallItemPick)
		end
	end)
end

---------------------------------------------------
-- 背包
---------------------------------------------------
function MainuiSmallParts:GetBagIcon()
	return self.btn_bag
end

function MainuiSmallParts:InitBag()
	local right_top = self.main_view:GetPartLayout(MainuiView.LAYOUT_PART.RIGHT_TOP)
	local right_top_size = right_top:getContentSize()


	-- self.bag_point = XUI.CreateImageView(right_top_size.width - 20, 460, ResPath.GetRemindImg(), true)
	-- right_top:TextLayout():addChild(self.bag_point, 200)
	-- self.bag_point:setVisible(false)
	-- CommonAction.ShowRemindBlinkAction(self.bag_point)

	self.btn_bag = XUI.CreateImageView(right_top_size.width - 115 - 15, 500, ResPath.GetMainui("img_bag"))
	right_top:TextureLayout():addChild(self.btn_bag, 1)

	self.bag_point = XUI.CreateImageView(60, 60, ResPath.GetMainui("remind_flag"), true)
	self.btn_bag:addChild(self.bag_point, 100)
	self.bag_point:setVisible(false)
	XUI.AddClickEventListener(self.btn_bag, function ()
		ViewManager.Instance:OpenViewByDef(ViewDef.MainBagView)
	end)
end

---------------------------------------------------
-- 钻石萌宠-挖掘BOSS 挖掘按钮
---------------------------------------------------
function MainuiSmallParts:InitExcavateBossIcon()

 	local right_top = self.main_view:GetPartLayout(MainuiView.LAYOUT_PART.RIGHT_TOP)
	local right_top_size = right_top:getContentSize()
	local icon = MainUiIcon.New(MainUiIconbar.ICON_SIZE.width, MainUiIconbar.ICON_SIZE.height)
	icon:Create(right_top)
	icon:SetIconPath(ResPath.GetMainui("icon_excavate_boss"))
	icon:SetPosition(right_top_size.width - 325, 405)
	self.excavate_boss_icon = icon

	local eff = 1186
	local path, name = ResPath.GetEffectUiAnimPath(eff)
	local parent = self.excavate_boss_icon:GetView():EffectLayout()
	eff = AnimateSprite:create(path, name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Stand, false)
	eff:setPosition(47, 46)
	parent:addChild(eff, 999)

	self.excavate_boss_icon:AddClickEventListener(function()
		if GuajiCache.guaji_type ~= GuajiType.None then
			local guaji_type = GuajiType.None
			GuajiCtrl.Instance:SetGuajiType(guaji_type)
		end

		-- 玩家正在挖掘
		if DiamondPetCtrl.Instance:IsExcavating() then
			SysMsgCtrl.Instance:FloatingTopRightText("正在挖掘中,请稍等...")
			return
		else
			local excavate_boss_list = DiamondPetCtrl.Instance:GetExcavateBossList()
			local mainrole = Scene.Instance:GetMainRole()
			local role_pos_x, role_pos_y = mainrole:GetLogicPos()
			local dis, next_obj_id = 9999999999, 0
			local next_obj = nil
			for obj_id, excavate_boss_view in pairs(excavate_boss_list) do
				if excavate_boss_view.parent then
					local obj = Scene.Instance:GetObjectByObjId(obj_id)
					local obj_pos_x, obj_pos_y = obj:GetLogicPos()
					-- 斜走和直走的移动速度相同,取pos_x和pos_y的差值最大值为最远
					local _dis = math.max(math.abs(role_pos_x - obj_pos_x), math.abs(role_pos_y - obj_pos_y))
					if _dis < dis then
						next_obj_id = obj_id
						next_obj = obj
						dis = _dis
					end
				end
			end
			if next_obj and next_obj_id ~= 0 then
				MoveCache.end_type = MoveEndType.ExcavateBoss
				GuajiCtrl.Instance:MoveToObj(next_obj, 0, 0)
				DiamondPetCtrl.Instance:SetObjId(next_obj_id)
			end
		end
	end)
	self.excavate_boss_icon:SetVisible(false)
	self.excavate_boss_list = {}
end

function MainuiSmallParts:GetExcavateBossIcon()
	return self.excavate_boss_icon
end

function MainuiSmallParts:FlushExcavateBossIconVis(obj_id, _type)
	if _type == "add" then
		self.excavate_boss_list[obj_id] = true
	elseif _type == "delete" then
		self.excavate_boss_list[obj_id] = nil
	end

	local vis = next(self.excavate_boss_list) ~= nil
	self.excavate_boss_icon:SetVisible(vis)
	self:SettingGuide(vis)
end

function MainuiSmallParts:OnFinishFuben(fuben_id)
	if self.layout_fuben_bar then
		if nil == self.arrow_root then
			self:CreateExitFuBenGuide()
		else
			self.arrow_root:setVisible(true)
		end
	end
end

function MainuiSmallParts:SettingGuide(vis) -- 引导
	local parent = self.excavate_boss_icon and self.excavate_boss_icon:GetView():TextLayout()
	if vis and Scene.Instance:GetSceneId() == 111 and parent and nil == self.arrow_root2 then
		self.arrow_root2 = cc.Node:create()
		parent:addChild(self.arrow_root2, 1)
		self.arrow_root2:setPosition(0, 45)
		local arrow_node = cc.Node:create()
		self.arrow_root2:addChild(arrow_node)
		local arrow_frame = XButton:create(ResPath.GetGuide("arrow_frame"), "", "")
		arrow_frame:setTitleFontSize(25)
		arrow_frame:setTitleText("挖掘怪物")
		arrow_frame:setTouchEnabled(false)
		arrow_node:addChild(arrow_frame)
		arrow_frame:setTitleFontName(COMMON_CONSTS.FONT)
		local label = arrow_frame:getTitleLabel()
		if label then
			label:setColor(COLOR3B.G_Y)
			label:enableOutline(cc.c4b(0, 0, 0, 100), 1.5)
		end
		local arrow_point = XUI.CreateImageView(0, 0, ResPath.GetGuide("arrow_point"))
		arrow_point:setAnchorPoint(1, 0.5)
		arrow_node:addChild(arrow_point)

		local offset_x = 35
		local rotation, anc_x, anc_y, x, y = 0, 1, 0.5, -offset_x, 0
		local move1 = cc.MoveTo:create(0.5, cc.p(-10, 0))
		local move2 = cc.MoveTo:create(0.5, cc.p(0, 0))

		arrow_point:setRotation(rotation)
		arrow_frame:setAnchorPoint(anc_x, anc_y)
		arrow_frame:setPosition(x, y)
		local action = cc.RepeatForever:create(cc.Sequence:create(move1, move2))
		arrow_node:stopAllActions()
		arrow_node:runAction(action)
	else
		if self.arrow_root2 then
			self.arrow_root2:removeFromParent()
			self.arrow_root2 = nil
		end
	end
end

---------------------------------------------------
-- 限时任务 begin
---------------------------------------------------
function MainuiSmallParts:InitTimeLimitTask()
	local right_top = self.main_view:GetPartLayout(MainuiView.LAYOUT_PART.RIGHT_TOP)
	local right_top_size = right_top:getContentSize()

	local icon_data = TimeLimitTaskIcon
	local res = icon_data.res
	local icon = MainUiIcon.New(MainUiIconbar.ICON_SIZE.width, MainUiIconbar.ICON_SIZE.height)
	icon:Create(right_top)
	icon:SetData(icon_data)
	icon:SetBgFramePath(ResPath.GetMainui("icon_bg"))
	icon:SetIconPath(ResPath.GetMainui(string.format("icon_%s_img", res)))
	icon:SetBottomPath(ResPath.GetMainui(string.format("icon_%s_word", res)), 12)
	icon:SetPosition(right_top_size.width - 57, right_top_size.height - 200)
	icon:AddClickEventListener(function()
		ViewManager.Instance:OpenViewByDef(icon_data.view_pos)
	end)

	self.time_limit_task_icon = icon
	self:UpdateTimeLimitTaskIcon()
end

function MainuiSmallParts:FlushTimeLimitTaskIconTime(elapse_time, total_time)
	local left_time = total_time - elapse_time
	local ok_task_count = TimeLimitTaskData.Instance:GetOkTaskCount()
	if ok_task_count == 8 or left_time <= 0 then
		CountDown.Instance:RemoveCountDown(self.tl_task_left_time_cd)
		self.time_limit_task_icon:SetVisible(false)
		self.tl_task_left_time_cd = nil
	end
	self.time_limit_task_icon:SetBottomContent(string.format("{color;1eff00;%s}", TimeUtil.FormatSecond(left_time)))
end

function MainuiSmallParts:UpdateTimeLimitTaskIcon()
	local val = GameCondMgr.Instance:GetValue(TimeLimitTaskIcon.vis_cond)
	self.time_limit_task_icon:SetVisible(val)
	-- local b = PracticeCtrl.IsInPracticeMap()
	-- local a = PracticeCtrl.IsInPracticeGate()
	-- if b or a then
	-- 	self.time_limit_task_icon:SetVisible(false)
	-- end

	if val then
		local left_time = TimeLimitTaskData.Instance:TaskLeftTime()
		if left_time > 0 and nil == self.tl_task_left_time_cd then
			self.tl_task_left_time_cd = CountDown.Instance:AddCountDown(left_time, 1, BindTool.Bind(self.FlushTimeLimitTaskIconTime, self))
		end
		self:FlushTimeLimitTaskIconTime(0, left_time)
	else
		CountDown.Instance:RemoveCountDown(self.tl_task_left_time_cd)
		self.tl_task_left_time_cd = nil
	end
end
---------------------------------------------------
-- 限时任务 end
---------------------------------------------------

---------------------------------------------------
-- 必杀技预告
---------------------------------------------------
function MainuiSmallParts:InitBiShaPreviewIcon()
	local right_top = self.main_view:GetPartLayout(MainuiView.LAYOUT_PART.RIGHT_TOP)
	local right_top_size = right_top:getContentSize()

	local icon_data = BiShaPreviewIcon
	local res = icon_data.res
	local icon = MainUiIcon.New(MainUiIconbar.ICON_SIZE.width, MainUiIconbar.ICON_SIZE.height)
	icon:Create(right_top)
	icon:SetData(icon_data)
	icon:SetBgFramePath(ResPath.GetMainui("icon_bg"))
	icon:SetIconPath(ResPath.GetMainui(string.format("icon_%s_img", res)))
	icon:SetBottomPath(ResPath.GetMainui(string.format("icon_%s_word", res)), 12)
	icon:SetPosition(right_top_size.width - 57, right_top_size.height - 200)
	icon:SetBottomContent(GameCondMgr.Instance:GetTip(icon_data.vis_cond))
	local black_bg = XUI.CreateImageView(icon.width / 2, -6, ResPath.GetMainui("bg_131"))
	black_bg:setScaleX(0.40)
	black_bg:setScaleY(0.55)
	icon:GetView():TextureLayout():addChild(black_bg, 99)
	icon:AddClickEventListener(function()
		ViewManager.Instance:OpenViewByDef(icon_data.view_pos)
	end)

	self.bisha_preview_icon = icon

	self:FlushBiShaPreviewIcon()
end

function MainuiSmallParts:FlushBiShaPreviewIcon()
	self.bisha_preview_icon:SetVisible(GameCondMgr.Instance:GetValue(BiShaPreviewIcon.vis_cond))
	-- local b = PracticeCtrl.IsInPracticeMap()
	-- local a = PracticeCtrl.IsInPracticeGate()
	-- if b or a then
	-- 	self.bisha_preview_icon:SetVisible(false)
	-- end
end

function MainuiSmallParts:OnMainRoleLearnBiSha()
	local new_icon = XUI.CreateLayout(0, 0, MainUiIconbar.ICON_SIZE.width, MainUiIconbar.ICON_SIZE.height)
	local res = BiShaPreviewIcon.res
	new_icon:addChild(XUI.CreateImageView(MainUiIconbar.ICON_SIZE.width / 2, MainUiIconbar.ICON_SIZE.height / 2, ResPath.GetMainui(string.format("icon_%s_img", res))), 1, 1)
	new_icon:addChild(XUI.CreateImageView(MainUiIconbar.ICON_SIZE.width / 2, 20, ResPath.GetMainui(string.format("icon_%s_word", res))), 2, 2)

	local ui_size = HandleRenderUnit:GetSize()
	HandleRenderUnit:AddUi(new_icon, COMMON_CONSTS.ZORDER_SYSTEM_EFFECT)
	local i_pos = self.bisha_preview_icon:GetView():convertToWorldSpace(cc.p(MainUiIconbar.ICON_SIZE.width / 2, MainUiIconbar.ICON_SIZE.height / 2))
	new_icon:setPosition(i_pos.x, i_pos.y)

	local act_time = 4
	local target_pos = cc.p(ui_size.width / 2, ui_size.height / 2 + 100)
	local act_seq = cc.Spawn:create(cc.MoveTo:create(act_time, target_pos), cc.ScaleTo:create(act_time, 1.3))
	new_icon:runAction(act_seq)

	GlobalTimerQuest:AddDelayTimer(function()
		ViewManager.Instance:OpenViewByDef(ViewDef.BiShaRecView)
		ViewManager.Instance:FlushViewByDef(ViewDef.BiShaRecView, 0, "icon_data", {icon = new_icon})
	end, act_time)
end
---------------------------------------------------
-- 必杀技预告 end
---------------------------------------------------

---------------------------------------------------
-- 发现boss
---------------------------------------------------

function MainuiSmallParts:InitFindBoss()
	local right_top = self.main_view:GetPartLayout(MainuiView.LAYOUT_PART.RIGHT_TOP)
	local right_top_size = right_top:getContentSize()
	local icon_data = FindBossIcon
	-- 创建秒杀BOSS图标
	self:CreateFindBossSecondKill()
	
	self.layout_find_boss_bar = XUI.CreateLayout(right_top_size.width - 57, right_top_size.height - 327, 120, 120)
	right_top:TextLayout():addChild(self.layout_find_boss_bar, 1, 88)

	XUI.AddClickEventListener(self.layout_find_boss_bar, function()
		ViewManager.Instance:OpenViewByDef(icon_data.view_pos)
		end, true)

	local prog_bg = XUI.CreateImageView(60, 60, ResPath.GetFindBoss("find_boss_9"))
	self.layout_find_boss_bar:addChild(prog_bg, 100)

	local sprite = XUI.CreateSprite(ResPath.GetFindBoss("find_boss_7"))
	self.prog_bar = cc.ProgressTimer:create(sprite)
	self.prog_bar:setScale(1) 
	self.prog_bar:setType(0)
	self.prog_bar:setPercentage(0)
	self.prog_bar:setPosition(60, 60)
	-- self.prog_bar:setVisible(false)
	self.layout_find_boss_bar:addChild(self.prog_bar, 200)

	local prog_fg = XUI.CreateImageView(60, 60, ResPath.GetFindBoss("find_boss_6"))
	self.layout_find_boss_bar:addChild(prog_fg, 300)

	local prog_frame = XUI.CreateImageView(60, 60, ResPath.GetFindBoss("find_boss_8"))
	self.layout_find_boss_bar:addChild(prog_frame, 300)

	local prog_word = XUI.CreateImageView(60, 5, ResPath.GetFindBoss("find_boss_5"))
	self.layout_find_boss_bar:addChild(prog_word, 300)
	prog_word:setScale(1.3)
	self.layout_find_boss_bar:setScale(0.7)

	local path, name = ResPath.GetEffectUiAnimPath(356)
	self.boss_eff = AnimateSprite:create(path, name, COMMON_CONSTS.MAX_LOOPS, 0.12, false)
	self.boss_eff:setVisible(false)
	self.boss_eff:setPosition(55, 72)
	self.boss_eff:setAnchorPoint(cc.p(0.5, 0.5))
	self.layout_find_boss_bar:addChild(self.boss_eff, 999)
end

function MainuiSmallParts:UpdateFindBossIcon()
    if IS_AUDIT_VERSION then 
        self.layout_find_boss_bar:setVisible(false)
        return
    end
	local find_data = FindBossData.Instance:GetData()
	if find_data.times == 0 then self.layout_find_boss_bar:setVisible(false) return end

	local val = GameCondMgr.Instance:GetValue(FindBossIcon.vis_cond)
	local can_show = Scene.Instance:GetSceneLogic():CanShowFindBossIcon()
	self.layout_find_boss_bar:setVisible(val and can_show)
	self.draw_left_time = FindBossData.Instance:GetExtractTime()
	if val and find_data.times > 0 then
		if self.draw_left_time > 0 then
			if self.find_boss_countdown then
				GlobalTimerQuest:CancelQuest(self.find_boss_countdown)
			end
			self.find_boss_countdown = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.SetFindBossProg, self), 1)
			self.boss_eff:setVisible(false)
		else
			if self.find_boss_countdown then
				GlobalTimerQuest:CancelQuest(self.find_boss_countdown)
			end
			self.prog_bar:setPercentage(100)
			self.boss_eff:setVisible(true)
		end
	else
		if self.find_boss_countdown then
			GlobalTimerQuest:CancelQuest(self.find_boss_countdown)
		end
		self.prog_bar:setPercentage(0)
		self.boss_eff:setVisible(false)
	end
	self.layout_find_boss_bar:setVisible(false)
end

function MainuiSmallParts:SetFindBossProg()
	self.draw_left_time = FindBossData.Instance:GetExtractTime()
	local total_time = RandomBossCfg and RandomBossCfg.timesCd
	if nil == total_time then return end
	if self.draw_left_time and self.draw_left_time >= 0 then
		self.prog_bar:setPercentage((total_time - self.draw_left_time) / (total_time / 100))
		self.draw_left_time = self.draw_left_time - 1
	end
	if self.draw_left_time == 0 and self.find_boss_countdown then
		self:UpdateFindBossIcon()
	end
end

function MainuiSmallParts:CreateFindBossSecondKill()
	local bottom_center = self.main_view:GetPartLayout(MainuiView.LAYOUT_PART.BOTTOM_CENTER)
	local layout_size = cc.size(117, 117)
	local bottom_center_size = bottom_center:getContentSize()
	self.second_kill_layout = XUI.CreateLayout(bottom_center_size.width / 2, 170, layout_size.width, layout_size.height)
	bottom_center:TextLayout():addChild(self.second_kill_layout, 1, 999)
	local second_kill_bg = XUI.CreateImageView(layout_size.width / 2, layout_size.height / 2, ResPath.GetFindBoss("second_kill_bg"))
	self.second_kill_layout:addChild(second_kill_bg, 100)
	self.second_kill_text = XUI.CreateText(layout_size.width / 2, layout_size.height / 2 - 50, layout_size.width, 0, cc.TEXT_ALIGNMENT_CENTER, "", nil, 19, COLOR3B.G_Y, cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
	self.second_kill_layout:addChild(self.second_kill_text, 100)
	EventProxy.New(FindBossData.Instance, self):AddEventListener(FindBossData.FINDBOSS_SECOND_KILL_CHANGE, BindTool.Bind(self.UpdateSecondKill, self))
	XUI.AddClickEventListener(self.second_kill_layout, function()
		local yuanbao = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD)				--元宝
		local need_yuanbao = FindBossData.Instance:GetSecondKillConsume()
		if need_yuanbao > yuanbao then
			self.alert = self.alert or Alert.New()
			self.alert:SetLableString(Language.FindBoss.SecondKillAlert)
			self.alert:SetOkFunc(function()
				ViewManager.Instance:OpenViewByDef(ViewDef.ZsVip.Recharge)
			end)
			self.alert:SetOkString(Language.FindBoss.Charge)
			self.alert:Open()
		else
			FindBossCtrl.Instance:SendDiamondsCreateReq(4)
			-- FindBossData.Instance:SetCanCastSecondKill(false)
			-- self:UpdateSecondKill()
		end
		end, true)
	local path, name = ResPath.GetEffectUiAnimPath(368)
	local eff = AnimateSprite:create(path, name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
	eff:setAnchorPoint(cc.p(0.5, 0.5))
	eff:setPosition(60, 65)
	self.second_kill_layout:addChild(eff, 999)
end

function MainuiSmallParts:UpdateSecondKill()
	local need_yuanbao = FindBossData.Instance:GetSecondKillConsume()
	local btn_state = FindBossData.Instance:GetSecondKillBtnState()
	self.second_kill_text:setString("-" .. need_yuanbao .. "元宝")
	self.second_kill_layout:setVisible(btn_state == 1 or btn_state == 2)
	XUI.SetLayoutImgsGrey(self.second_kill_layout, btn_state == 2, true)
end

---------------------------------------------------
-- 发现boss end
---------------------------------------------------

---------------------------------------------------
-- 威望任务
---------------------------------------------------
function MainuiSmallParts:InitPrestigeTaskTipView()
	-- 设置面板数据
	if nil == self.prestige_task_tip then
		local left_top = MainuiCtrl.Instance:GetView():GetPartLayout(MainuiView.LAYOUT_PART.LEFT_TOP)

		-- 创建布局
		local layout_practice = XUI.CreateLayout(80, 520, 150, 0)
		left_top:TextureLayout():addChild(layout_practice, -20)

		GlobalEventSystem:Fire(OtherEventType.TARGET_HEAD_CHANGE, true, true)

		self.prestige_task_tip = self.CreatePrestigeTaskTip(layout_practice)
	else
		self.prestige_task_tip:SetVisible(true)
	end
	self.prestige_task_tip:Flush()
end

-- 创建视图
function MainuiSmallParts.CreatePrestigeTaskTip(parent)
	local view = {}
	local LeftTime = {}
	local ph_item = ConfigManager.Instance:GetUiConfig("prestige_task_ui_cfg")[2]
	--顶部面板
	local node_tree = {}
	local node = XUI.CreateLayout(520, 100, 150, 0)
	XUI.Parse(ph_item, node, nil, node_tree)
	parent:addChild(node)

	-----面板刷新-----	
	local day_max_count = PrestigeSysConfig.dayMaxCount
	local item = PrestigeSysConfig.changecfg[1][1].consume[1] -- 获取配置
	local data = PrestigeTaskData.Instance:GetData()
	function view:Flush()
		local item_num = BagData.Instance:GetItemNumInBagById(item.id, nil) --获取背包的物品数量
		local text = "当前屠魔令：" .. item_num
		node_tree.lbl_count.node:setString(text)
		if data.times ~= day_max_count then
			local cfg_count = PrestigeSysConfig.changecfg[(data.times + 1)][1].consume[1].count
			node_tree.lbl_consume_count.node:setString("兑换消耗屠魔令：" .. cfg_count)
			if item_num >= cfg_count then
				if self.prestige_task_vis and self.prestige_task_times ~= data.times then
					ViewManager.Instance:OpenViewByDef(ViewDef.PrestigeTaskTip)
					self.prestige_task_times = data.times
					self.prestige_task_vis = false
				end
			else
				self.prestige_task_vis = true
			end
		else
			node_tree.lbl_consume_count.node:setVisible(false)
		end
	end
	function view:SetVisible(vis) -- 设置面板显示状态
		if nil ~= node then
			node:setVisible(vis)
		end
	end
	function view:Release()
		if parent then
			parent:removeFromParent()
		end
	end
	return view
end

---------------------------------------------------
-- 威望任务 end
---------------------------------------------------

---------------------------------------------------
-- 未知暗殿
---------------------------------------------------
function MainuiSmallParts:InituUnknownDarkHouseTip()
	-- 设置面板数据
	if nil == self.unknown_dark_house_tip then
		local left_top = MainuiCtrl.Instance:GetView():GetPartLayout(MainuiView.LAYOUT_PART.LEFT_TOP)

		-- 创建布局
		local layout_practice = XUI.CreateLayout(80, 520, 150, 0)
		left_top:TextLayout():addChild(layout_practice, -20)

		GlobalEventSystem:Fire(OtherEventType.TARGET_HEAD_CHANGE, true, true)

		self.unknown_dark_house_tip = self.CreateUnknownDarkHouseTip(layout_practice)
	else
		self.unknown_dark_house_tip:SetVisible(true)
	end
	self.unknown_dark_house_tip:Flush()
end

-- 创建视图
function MainuiSmallParts.CreateUnknownDarkHouseTip(parent)
	local view = {}
	local LeftTime = {}
	local ph_item = ConfigManager.Instance:GetUiConfig("unknown_dark_house_ui_cfg")[2]
	--顶部面板
	local node_tree = {}
	local node = XUI.CreateLayout(520, 100, 150, 0)
	XUI.Parse(ph_item, node, nil, node_tree)
	parent:addChild(node)

	-----面板刷新-----	

	function view:Flush()
		self.exp_info = UnknownDarkHouseData.Instance:GetExpInfo()
		self.eff_info = UnknownDarkHouseData.Instance:GetDonfireInfo()
		if next(self.exp_info) then
			local text = self.exp_info.exp_mul > 0 and "/秒(双倍)" or "/秒"
			local left_time = UnknownDarkHouseData.Instance:GetDonfireLeftTime()
			node_tree.lbl_benefits.node:setString(self.exp_info.exp_num .. text)
			node:setVisible(left_time > 0 and self.eff_info.state == 1)
			self:CheckTimer()
			if self.eff_info.max_ppl_qty > 0 then
				local bool = self.eff_info.ppl_qty ~= self.eff_info.max_peo_num
				local ppl_qty = bool and "{color;1eff00;" .. self.eff_info.ppl_qty .. "/" .. self.eff_info.max_ppl_qty .. "}" or "{color;ff2828;" .. self.eff_info.ppl_qty .. "/" .. self.eff_info.max_ppl_qty .. "}"
				local text = "(泡点人数:" .. ppl_qty .. ")"
				RichTextUtil.ParseRichText(node_tree.rich_ppl_qty.node, text, 18, COLOR3B.GOLD)
				node_tree.rich_ppl_qty.node:setVisible(true)
			else
				node_tree.rich_ppl_qty.node:setVisible(false)
			end
		else
			node:setVisible(false)
		end
	end
	function view:CheckTimer() --检查计时器任务
		local left_time = UnknownDarkHouseData.Instance:GetDonfireLeftTime()
		if nil == left_time or self.eff_info.state == nil then return end

		if left_time > 0 and self.eff_info.state == 1 then
			node_tree.lbl_time.node:setString(TimeUtil.FormatSecond2Str(left_time)) -- 刷新剩余时间
			if nil == self.timer then
				self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.SecTime, self), 1)
			end
		else
			GlobalTimerQuest:CancelQuest(self.timer) -- 取消计时器任务
			self.timer = nil
		end
	end
	function view:SecTime() --倒计时每秒回调
		local left_time = UnknownDarkHouseData.Instance:GetDonfireLeftTime()
		if nil == left_time then return end
		node_tree.lbl_time.node:setString(TimeUtil.FormatSecond2Str(left_time)) -- 刷新剩余时间
		if left_time == 0 then
			UnknownDarkHouseCtrl.Instance:SendUnknownDarkHouseReq(1)
			self:CheckTimer()
		end
	end
	function view:SetVisible(vis) -- 设置面板显示状态
		if nil ~= node then
			node:setVisible(vis)
		end
	end
	function view:Release()
		GlobalTimerQuest:CancelQuest(self.timer) -- 取消计时器任务
		self.timer = nil
		if parent then
			parent:removeFromParent()
		end
	end
	return view
end

function MainuiSmallParts:InituUnknownDarkHouseExp()
	-- 设置面板数据
	if nil == self.unknown_dark_house_exp then
		local bottom_center = MainuiCtrl.Instance:GetView():GetPartLayout(MainuiView.LAYOUT_PART.BOTTOM_CENTER)
		-- 创建布局
		local layout_practice = XUI.CreateLayout(117, 8, 150, 0)
		bottom_center:TextureLayout():addChild(layout_practice, -20)

		GlobalEventSystem:Fire(OtherEventType.TARGET_HEAD_CHANGE, true, true)

		self.unknown_dark_house_exp = self.CreateUnknownDarkHouseExp(layout_practice)
	else
		self.unknown_dark_house_exp:SetVisible(true)

	end
	self.unknown_dark_house_exp:Flush()
end

-- 创建视图
function MainuiSmallParts.CreateUnknownDarkHouseExp(parent)
	local view = {}
	local LeftTime = {}
	local ph_item = ConfigManager.Instance:GetUiConfig("unknown_dark_house_ui_cfg")[3]
	--顶部面板
	local node_tree = {}
	local node = XUI.CreateLayout(520, 100, 150, 0)
	XUI.Parse(ph_item, node, nil, node_tree)
	parent:addChild(node)

	local function OnBuy(index)
		UnknownDarkHouseCtrl.Instance:SendUnknownDarkHouseReq(4, index)
	end
	XUI.AddClickEventListener(node_tree.layout_buy_double.btn_buy_double_1.node, BindTool.Bind(OnBuy, 1))
	XUI.AddClickEventListener(node_tree.layout_buy_double.btn_buy_double_2.node, BindTool.Bind(OnBuy, 2))

	-----面板刷新-----	

	function view:Flush()
		local left_time = UnknownDarkHouseData.Instance:GetDoubleLeftTime()
		node_tree.layout_double_lef_time.node:setVisible(left_time ~= 0)
		node_tree.layout_buy_double.node:setVisible(left_time == 0)
		GlobalEventSystem:FireNextFrame(MainUIEventType.BONFIRE_BAR_VIS, (left_time == 0 and 1 or 0))

		self:CheckTimer()
	end
	function view:CheckTimer() --检查计时器任务
		local left_time = UnknownDarkHouseData.Instance:GetDoubleLeftTime()
		if left_time > 0 then
			node_tree.layout_double_lef_time.lbl_left_time.node:setString("双倍篝火剩于时间：" .. TimeUtil.FormatSecond2Str(left_time)) -- 刷新剩余时间
			if nil == self.timer then
				self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.SecTime, self), 1)
			end
		else
			GlobalTimerQuest:CancelQuest(self.timer) -- 取消计时器任务
			self.timer = nil
		end
	end
	function view:SecTime() --倒计时每秒回调
		local left_time = UnknownDarkHouseData.Instance:GetDoubleLeftTime()
		node_tree.layout_double_lef_time.lbl_left_time.node:setString("双倍篝火剩于时间：" .. TimeUtil.FormatSecond2Str(left_time)) -- 刷新剩余时间
		if left_time == 0 then
			UnknownDarkHouseCtrl.Instance:SendUnknownDarkHouseReq(1)
			self:CheckTimer()
		end
	end
	function view:SetVisible(vis) -- 设置面板显示状态
		if nil ~= node then
			node:setVisible(vis)
		end
	end
	function view:Release()
		GlobalTimerQuest:CancelQuest(self.timer) -- 取消计时器任务
		self.timer = nil
		if parent then
			parent:removeFromParent()
		end
	end
	return view
end

---------------------------------------------------
-- 未知暗殿 end
---------------------------------------------------

---------------------------------------------------
-- 试炼-图标
---------------------------------------------------
function MainuiSmallParts:GetExcIcon()
	return self.btn_exc
end

function MainuiSmallParts:InitExc()
	local right_top = self.main_view:GetPartLayout(MainuiView.LAYOUT_PART.RIGHT_TOP)
	local right_top_size = right_top:getContentSize()

	self.btn_exc = XUI.CreateImageView(right_top_size.width - 36 - 15, 580, ResPath.GetMainui("icon_exc"))
	right_top:TextureLayout():addChild(self.btn_exc, 1)
	self.img_shilian_red = XUI.CreateImageView(50, 50, ResPath.GetMainui("remind_flag"), true)
	self.btn_exc:addChild(self.img_shilian_red)
	XUI.AddClickEventListener(self.btn_exc, function ()
		ViewManager.Instance:OpenViewByDef(ViewDef.Experiment)
	end)
	self.btn_exc:setVisible(false)
end
---------------------------------------------------
-- 试炼-图标 end
---------------------------------------------------


---------------------------------------------------
-- 自动做任务-图标
---------------------------------------------------
function MainuiSmallParts:GetTaskIcon()
	return self.btn_task
end

local is_auto_task = true

function MainuiSmallParts:InitTask()
	local right_top = self.main_view:GetPartLayout(MainuiView.LAYOUT_PART.RIGHT_TOP)
	local right_top_size = right_top:getContentSize()

	self.btn_task = XUI.CreateImageView(right_top_size.width - 190 - 15, 493, ResPath.GetMainui(is_auto_task and "icon_unauto_task" or "icon_auto_task"))
	right_top:TextureLayout():addChild(self.btn_task, 1)
	XUI.AddClickEventListener(self.btn_task, function ()
		is_auto_task = not is_auto_task
		self.btn_task:loadTexture(ResPath.GetMainui(is_auto_task and "icon_unauto_task" or "icon_auto_task"))
		GuideCtrl.Instance:SetForceStopTask(not is_auto_task)
	end)
	self.btn_task:setVisible(false)
end

function MainuiSmallParts:OnStopAutoTask()
	if not GameCondMgr.Instance:GetValue("CondId160") then return end
	is_auto_task = false
	self.btn_task:loadTexture(ResPath.GetMainui(is_auto_task and "icon_unauto_task" or "icon_auto_task"))
	GuideCtrl.Instance:SetForceStopTask(not is_auto_task)
end
---------------------------------------------------
-- 自动做任务-图标 end
---------------------------------------------------


---------------------------------------------------
-- 功能引导-图标
---------------------------------------------------
-- 只在上线时刷新
function MainuiSmallParts:GetFuncGuideList()
	local list = {}
	local check_list = {
		{viewdef = ViewDef.GodFurnace.TheDragon, check_func = function ()
			return GameCondMgr.Instance:GetValue(ViewDef.GodFurnace.TheDragon.v_open_cond) and not GodFurnaceData.Instance:IsActSlot(GodFurnaceData.Slot.TheDragonPos) and RemindManager.Instance:GetRemindGroup(ViewDef.GodFurnace.TheDragon.remind_group_name) > 0 
		end},
		{viewdef = ViewDef.GodFurnace.Shield, check_func = function ()
			return GameCondMgr.Instance:GetValue(ViewDef.GodFurnace.Shield.v_open_cond) and not GodFurnaceData.Instance:IsActSlot(GodFurnaceData.Slot.ShieldPos) and RemindManager.Instance:GetRemindGroup(ViewDef.GodFurnace.Shield.remind_group_name) > 0 
		end},
		{viewdef = ViewDef.GodFurnace.GemStone, check_func = function ()
			return GameCondMgr.Instance:GetValue(ViewDef.GodFurnace.GemStone.v_open_cond) and not GodFurnaceData.Instance:IsActSlot(GodFurnaceData.Slot.GemStonePos) and RemindManager.Instance:GetRemindGroup(ViewDef.GodFurnace.GemStone.remind_group_name) > 0 
		end},
		{viewdef = ViewDef.GodFurnace.DragonSpirit, check_func = function ()
			return GameCondMgr.Instance:GetValue(ViewDef.GodFurnace.DragonSpirit.v_open_cond) and not GodFurnaceData.Instance:IsActSlot(GodFurnaceData.Slot.DragonSpiritPos) and RemindManager.Instance:GetRemindGroup(ViewDef.GodFurnace.DragonSpirit.remind_group_name) > 0 
		end},
		{viewdef = ViewDef.Wing, check_func = function ()
			return GameCondMgr.Instance:GetValue(ViewDef.Wing.v_open_cond) and RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SWING_LEVEL) == 0
		end},
		{viewdef = ViewDef.QieGeView.QieGe, check_func = function ()
			return GameCondMgr.Instance:GetValue(ViewDef.QieGeView.v_open_cond) and QieGeData.Instance:GetCanActiveQieGe()
		end},
		{viewdef = ViewDef.Role.Deify, check_func = function ()
			return GameCondMgr.Instance:GetValue(ViewDef.Role.Deify.v_open_cond) and DeifyData.Instance:GetLevel() == 0
		end},
	}
	for i,v in ipairs(check_list) do
		if v.check_func() then
			table.insert(list, v.viewdef)
		end
	end
	return list
end

local is_check = false
function MainuiSmallParts:CheckFuncGuideShow()
	if self.func_guide_view then
		self:FlushFuncGuide()
	end
end

function MainuiSmallParts:FlushFuncGuide()
	if IS_ON_CROSSSERVER then return end
	if not is_check and nil == self.func_guide_view then
		local list = self:GetFuncGuideList()
		local right_top = self.main_view:GetPartLayout(MainuiView.LAYOUT_PART.RIGHT_TOP)
		local right_top_size = right_top:getContentSize()
		local x, y = right_top_size.width - 180, 500

		self.func_guide_view = XUI.CreateLayout(x, y, 200, 50)
		self.func_guide_view:setBackGroundColor(COLOR3B.BLACK)
		self.func_guide_view:setBackGroundColorOpacity(150)
		right_top:TextureLayout():addChild(self.func_guide_view, 1)
		XUI.AddClickEventListener(self.func_guide_view, function ()
			self.func_guide_view.OnClickCallFunc()
		end, true)


		local btn_close = XUI.CreateImageView(192, 50, ResPath.GetMainui("btn_close"))
		btn_close:setScale(0.5)
		self.func_guide_view:addChild(btn_close, 2)
		XUI.AddClickEventListener(btn_close, function ()
			self.func_guide_view.OnClickCallFunc()
		end, true)

		local content = XUI.CreateText(100, 22, 200, 25)
		content:setColor(COLOR3B.G_Y)
		self.func_guide_view:addChild(content, 1)

		self.func_guide_view.SetData = function ()
			list = self:GetFuncGuideList()
			self.func_guide_view:setVisible(nil ~= next(list))
			if nil ~= next(list) then
				content:setString(string.format(Language.Common.ActivateGuide, self:GetFuncGuideList()[1].name))
				UiInstanceMgr.AddRectEffect({node = self.func_guide_view, init_size_scale = 1.0, act_size_scale = 1.2, offset_w = 0, offset_h = 3, color = COLOR3B.GREEN})
			else
				UiInstanceMgr.DelRectEffect(self.func_guide_view)
			end
		end

		self.func_guide_view.OnClickCallFunc = function ()
			ViewManager.Instance:OpenViewByDef(list[1])
			if 	list[1] == ViewDef.Wing then 
				ViewManager.Instance:GetView(list[1]).door:FlushArrowGuide(0, -200)
			elseif ViewManager.Instance:GetView(ViewManager.Instance:GetRootDef(list[1])).door then 
				ViewManager.Instance:GetView(ViewManager.Instance:GetRootDef(list[1])).door:FlushArrowGuide()
			elseif ViewManager.Instance:GetView(list[1]).door then
				ViewManager.Instance:GetView(list[1]).door:FlushArrowGuide()
			end
			table.remove(list, 1)
			if nil == next(list) then
				NodeCleaner.Instance:AddNode(self.func_guide_view)
				self.func_guide_view = nil
				is_check = true
			else
				content:setString(string.format(Language.Common.ActivateGuide, list[1].name))
			end
		end

		self.func_guide_view:setVisible(false)
	end

	if not is_check then
		self.func_guide_view:SetData()
	end
end
---------------------------------------------------
-- 功能引导-图标 end
---------------------------------------------------