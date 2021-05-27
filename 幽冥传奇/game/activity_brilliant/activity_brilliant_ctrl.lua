require("scripts/game/activity_brilliant/require_activity_list")
require("scripts/game/activity_brilliant/activity_define")
require("scripts/game/activity_brilliant/activity_brilliant_view")
require("scripts/game/activity_brilliant/cross_server_operate_act_view")
require("scripts/game/activity_brilliant/activity_brilliant_items")
require("scripts/game/activity_brilliant/activity_brilliant_data")
require("scripts/game/activity_brilliant/act_lingqu_alert")
require("scripts/game/activity_brilliant/first_charge_view")
require("scripts/game/activity_brilliant/treasure_award_view")

ActivityBrilliantCtrl = ActivityBrilliantCtrl or BaseClass(BaseController)

function ActivityBrilliantCtrl:__init()
	if	ActivityBrilliantCtrl.Instance then
		ErrorLog("[ActivityBrilliantCtrl]:Attempt to create singleton twice!")
	end
	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

	ActivityBrilliantCtrl.Instance = self

	self.view = {}
	local view_index = 1
	while(ViewDef["ActivityBrilliant" .. view_index])
	do
		self.view[view_index] = OperationActivityView.New(ViewDef["ActivityBrilliant" .. view_index], view_index)
		view_index = view_index + 1
	end

	-- self.cs_op_act_view = CrossServerOperateActView.New(ViewName.CrossServerOperateAct)
	-- self.first_charge_view = FirstChargeView.New(ViewName.FirstCharge)
	self.data = ActivityBrilliantData.New()

	self:RegisterAllProtocols()
	self:RegisterAllRemind()
	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleDataChangeCallback, self))
	GlobalEventSystem:Bind(OtherEventType.PASS_DAY, BindTool.Bind1(self.PassDayCallBack, self))
end

function ActivityBrilliantCtrl:__delete()
	if self.view then
		for i,v in ipairs(self.view) do
			v:DeleteMe()
		end
		self.view = nil
	end

	-- self.cs_op_act_view:DeleteMe()
	-- self.cs_op_act_view = nil

	if self.effect then
		self.effect:setStop()
		self.effect = nil
	end
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end

	ActivityBrilliantCtrl.Instance = nil
end

function ActivityBrilliantCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCActivityBrilliant, "OnActivityBrilliant")
	self:RegisterProtocol(SCOtherPower, "OnOtherPower")

	-- self:RegisterProtocol(SCTodayChargeGoldCount, "OnTodayChargeGoldCount")
	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.SendActivityCfgReq))
end

-- 统一的运营活动面板关闭接口
function ActivityBrilliantCtrl:CloseView(act_id)
	if act_id then
		local view_index = ActivityBrilliantData.Instance:GetOperActViewIndex(act_id)
		local view_def = ViewDef["ActivityBrilliant" .. view_index]
		ViewManager.Instance:CloseViewByDef(view_def)
	else
		for i,v in ipairs(self.view) do
			for i,v in ipairs(self.view) do
				v:Close()
			end
		end
	end
end

function ActivityBrilliantCtrl:OpenView(act_id)
	if act_id then
		local view_index = ActivityBrilliantData.Instance:GetOperActViewIndex(act_id)
		local view_def = ViewDef["ActivityBrilliant" .. view_index]
		ViewManager.Instance:OpenViewByDef(view_def)
	end
end

function ActivityBrilliantCtrl:FlusView(act_id, index, key, value)
	if act_id then
		local view_index = ActivityBrilliantData.Instance:GetOperActViewIndex(act_id)
		self.view[view_index]:Flush(index, key, value)
	end
end

function ActivityBrilliantCtrl:RegisterAllRemind()
	for k,v in pairs(REMIND_ACT_LIST) do
		RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), v)
	end
end

function ActivityBrilliantCtrl:DoRemind(act_id)
	local remind_name = REMIND_ACT_LIST[act_id]
	if remind_name then
		if nil == RemindOneToGroup[remind_name] then
			local view_index = ActivityBrilliantData.Instance:GetOperActViewIndex(act_id)
			local group_name = "ActivityBrilliant" .. view_index
			if type(RemindGroup[group_name]) == "table" then
				RemindOneToGroup[remind_name] = {group_name}
			else
				ErrorLog("初始化提醒组失败 RemindGroup[group_name] 不是 table")
			end
		end

		RemindManager.Instance:DoRemind(remind_name)
	end
end

function ActivityBrilliantCtrl:PassDayCallBack()

	-- ActivityBrilliantCtrl.Instance:OpenActDataReq() 
end

--请求活动配置
function ActivityBrilliantCtrl:SendActivityCfgReq()
	ActivityBrilliantCtrl.Instance.ActivityListReq()
end

-- function ActivityBrilliantCtrl:OnTodayChargeGoldCount(protocol)
-- 	self.data:SetTodayRecharge(protocol.today_charge_gold_count)
-- 	-- GlobalEventSystem:Fire(OtherEventType.TODAY_CHARGE_CHANGE, protocol.today_charge_gold_count)
-- end

function ActivityBrilliantCtrl:DoReqCfg()
	local time = PLATFORM == cc.PLATFORM_OS_WINDOWS and 0 or 1
	if nil == self.cache_can_list then
		self.cache_can_list = {}
	end
	local req = table.remove(self.cache_can_list)
	if nil ~= req then
		ActivityBrilliantCtrl.ActivityReq(2, req.act_id)
		if nil ~= next(self.cache_can_list) then
			GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.DoReqCfg, self), time)
		end
	end
end

function ActivityBrilliantCtrl:IsReqActCfg()
	return self.cache_can_list and nil ~= next(self.cache_can_list)
end

function ActivityBrilliantCtrl:TableCopyAndReq(table_list)
	local list = {}
	for k,v in pairs(table_list) do
		if v.act_id == 49 or v.act_id == 50 then
			ActivityBrilliantCtrl.ActivityReq(2, v.act_id)
		else 
			table.insert(list, v)
		end
	end
	return list
end

function ActivityBrilliantCtrl:OnOtherPower(protocol)
	self.data:SetOtherPower(protocol)
end

function ActivityBrilliantCtrl:OnActivityBrilliant(protocol)
	if protocol.type == 1 then

		self:CloseView()

		ViewManager.Instance:CloseViewByDef(ViewDef.ActCanbaoge)
		ViewManager.Instance:CloseViewByDef(ViewDef.ActBabelTower)
		-- ViewManager.Instance:Close(ViewDef.LimitCharge)
		-- ViewManager.Instance:Close(ViewDef.ActChargeFanli)
		
		self.data:SetTabbarList(protocol)
		self.cache_can_list = self:TableCopyAndReq(protocol.can_list) 
		self:DoReqCfg() -- 自动请求活动配置

		GameCondMgr.Instance:CheckCondType(GameCondType.IsActBrilliantOpen)
	elseif protocol.type == 2 then
		self.data:SetActivityCfg(protocol)
		ActivityBrilliantCtrl.ActivityReq(3, protocol.act_id) -- 自动请求活动数据,返回接口类型3
	elseif protocol.type == 3 then
		if protocol.is_go == 0 then
			self.data:SetActivityData(protocol)
			if protocol.cooling_time > 0 then
				TipCtrl.Instance:FlushRedPacketTip()
			end
		end
		self:DoRemind(protocol.act_id) -- 刷新红点

		if protocol.act_id == ACT_ID.FHB then
			self:CheckRobRedBagReqTip((protocol.surplus_times >= 1 and protocol.cooling_time <=0) and 1 or 0)
			self.can_rob = protocol.surplus_times
			if self.can_rob > 0 then
				self:FlushCutDownTimer()
			end
		end
		-- 面板刷新 注意:独立面板的活动,不再检测精彩活动的图标开放和刷新面板,请自行加入和移除
		if protocol.act_id == ACT_ID.CBG then
			ViewManager.Instance:FlushViewByDef(ViewDef.ActCanbaoge)
			ViewManager.Instance:FlushViewByDef(ViewDef.ActCanbaogeDuiHuan)
			GameCondMgr.Instance:CheckCondType(GameCondType.IsActCanbaogeOpen)
		elseif protocol.act_id == ACT_ID.TTT then
			ViewManager.Instance:FlushViewByDef(ViewDef.ActBabelTower)
			GameCondMgr.Instance:CheckCondType(GameCondType.IsActBabelTowerOpen)
		elseif protocol.act_id == ACT_ID.XSCZ then
			ViewManager.Instance:FlushViewByDef(ViewDef.LimitCharge)
			GameCondMgr.Instance:CheckCondType(GameCondType.IsLimitChargeOpen)
			-- self:SetRedEffct(protocol.cooling_time, protocol.surplus_times)
		elseif protocol.act_id == ACT_ID.CZFL then
			ViewManager.Instance:FlushViewByDef(ViewDef.ActChargeFanli)
			GameCondMgr.Instance:CheckCondType(GameCondType.IsChargeFLOpen)
		elseif protocol.act_id == ACT_ID.LZMB then
			self.data:SetDragonTreasureResults(protocol)
			-- ViewManager.Instance:FlushView(ViewName.TreasureJackpot, 0, "flush_left_times")
		else
			self:FlusView(protocol.act_id, 0, "tabbar")
			self:FlusView(protocol.act_id, 0, "flush_view", {act_id = protocol.act_id}, true)
		end

		if nil == next(self.cache_can_list) then
			GameCondMgr.Instance:CheckCondType(GameCondType.IsActBrilliantOpen)
			-- ViewManager.Instance:FlushViewByDef(ViewDef.MainUi, 0, "icon_pos")
		end
	elseif protocol.type == 4 then
		if protocol.result == 0 then
			ActivityBrilliantCtrl.Instance.ActivityReq(3, protocol.act_id) --自动请求活动数据,返回接口类型3

			if protocol.act_id == ACT_ID.XYFP then
				if protocol.opt_type == 3 then
					self.data:SetTurnRecordList(protocol.record_type, protocol.record_str)
				elseif protocol.opt_type == 1 then
					self.data:SetBrandInfo(protocol.cards)
				end
			elseif protocol.act_id == ACT_ID.FHB then
				if protocol.red_packet_type == 1 then
					self:CheckRobRedBagReqTip(0)
					TipCtrl.Instance:ShowRedPacketTip(protocol.rob_red_packet_info)
				elseif protocol.red_packet_type == 2 then 
					self:CheckRobRedBagReqTip(1)
				end
			elseif protocol.act_id == ACT_ID.SLLB then
				if protocol.treasure_index == 2 then
					local index = 1
					local item_kind_list = TableCopy(protocol.treasure_item_list)
					local fly_func = function ()	
						local item_id = ActivityBrilliantData.Instance:GetItemIdByIndex(item_kind_list[index])
						if nil ~= item_id then
							self:StartFlyItem(item_id)
						end
						index = index + 1
					end
					GlobalTimerQuest:AddTimesTimer(fly_func, 0.12, #item_kind_list)
					self.data:SetHuntTreasure(protocol.treasure_item_num,protocol.treasure_item_list)
				end
			end

			-- 统一在自动请求的 3 类型中刷新,特别需求则加入下列判断
			if protocol.act_id == ACT_ID.XYFP 
				or protocol.act_id == ACT_ID.CZZP 
				or protocol.act_id == ACT_ID.SLLB
				or protocol.act_id == ACT_ID.LKGIFT
				or protocol.act_id == ACT_ID.LKDRAW -- 45 幸运抽奖
				or protocol.act_id == ACT_ID.DRAWFL -- 46 消费返利
				or protocol.act_id == ACT_ID.GZP
				or protocol.act_id == ACT_ID.SVZP
				or protocol.act_id == ACT_ID.TSMB
				or protocol.act_id == ACT_ID.ZPHL
			then
				self:FlusView(protocol.act_id, 0, "flush_view", {act_id = protocol.act_id,  result = protocol.activity_index}, true)
			elseif protocol.act_id == ACT_ID.GOLDZP then
				self:FlusView(protocol.act_id, 0, "flush_view", {act_id = protocol.act_id, result = protocol.activity_index, award_list = protocol.award_list}, true)
			end

			if protocol.act_id == ACT_ID.LZMB then
				self.data:SetDragonTreasureResults(protocol)
				local type = protocol.dragon_treasure_results.type
				if type == 3 then
					local index = protocol.dragon_treasure_results.box_index
					-- ViewManager.Instance:FlushView(ViewName.TreasureJackpot, 0, "cell_run_action", {index = index})
				end
			end
		end
	elseif protocol.type == 5 then
		self.data:SetTabbarList(protocol)
		ActivityBrilliantCtrl.Instance.ActivityReq(2, protocol.act_id)

		if protocol.act_id == ACT_ID.XSCZ then
			GameCondMgr.Instance:CheckCondType(GameCondType.IsLimitChargeOpen)
		else
			GlobalEventSystem:Fire(MainUIEventType.UPDATE_BRILLIANT_ICON)
			GameCondMgr.Instance:CheckCondType(GameCondType.IsActBrilliantOpen)
		end

		if #self.data.can_list < 1 then
			self:CloseView()
		end
	elseif protocol.type == 6 then 
		self.data:SetTabbarList(protocol)

		if protocol.act_id == ACT_ID.FHB then
			self.can_rob = 0
			self:CheckRobRedBagReqTip(0)
			-- self:SetRedEffct(self.cooling_time, self.can_rob)
		elseif protocol.act_id == ACT_ID.XSCZ then
			GameCondMgr.Instance:CheckCondType(GameCondType.IsLimitChargeOpen)
			ViewManager.Instance:CloseViewByDef(ViewDef.LimitCharge)
		else
			GlobalEventSystem:Fire(MainUIEventType.UPDATE_BRILLIANT_ICON)
			GameCondMgr.Instance:CheckCondType(GameCondType.IsActBrilliantOpen)
		end

		self:FlusView(protocol.act_id, 0, "tabbar")

		if #self.data.can_list < 1 then
			self:CloseView()
		end
	end
end

function ActivityBrilliantCtrl:GetCutDownTime()		
	return ActivityBrilliantData.Instance.cooling_endtime - TimeCtrl.Instance:GetServerTime()
end

function ActivityBrilliantCtrl:CutDownTimerFunc()		
	local time = self:GetCutDownTime()
	if time <= 0 then
		self:CheckRobRedBagReqTip(1)
		self:DeleteCutDownTimer()
	else
	end
end

function ActivityBrilliantCtrl:FlushCutDownTimer()
	if nil == self.cutdown_timer and self:GetCutDownTime() > 0 then
		self.cutdown_timer = GlobalTimerQuest:AddRunQuest(function ()
			self:CutDownTimerFunc()
		end, 1)
	end
	self:CutDownTimerFunc()
end

function ActivityBrilliantCtrl:DeleteCutDownTimer()
	if self.cutdown_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.cutdown_timer)
		self.cutdown_timer = nil
	end
end

function ActivityBrilliantCtrl:RoleDataChangeReq(act_id)
	if self.data:CheckActOpen(act_id) then
		self.ActivityReq(3, act_id)
	end
end

-- 启用龙族秘宝Play按钮
function ActivityBrilliantCtrl:SetDragonTreasurePlayBtnEnabled()
	self:FlusView(ACT_ID.LZMB, 0, "flush_view", {act_id = ACT_ID.LZMB, result = 3}, true)	
end

function ActivityBrilliantCtrl:RoleDataChangeCallback(key, value, old_value)
	if key.key == OBJ_ATTR.ACTOR_GEM_CRYSTAL then
		self:RoleDataChangeReq(ACT_ID.BS)
		self:RoleDataChangeReq(ACT_ID.BSGIFT)
		self:RoleDataChangeReq(ACT_ID.BSHK)
	elseif key.key == OBJ_ATTR.ACTOR_GOLD then
		self:RoleDataChangeReq(ACT_ID.XF)
		self:RoleDataChangeReq(ACT_ID.XB)
		self:RoleDataChangeReq(ACT_ID.LKGIFT)
		self:RoleDataChangeReq(ACT_ID.XFZP)
		self:RoleDataChangeReq(ACT_ID.QMXF)
		self:RoleDataChangeReq(ACT_ID.XFHK)
		self:RoleDataChangeReq(ACT_ID.ZP)
		self:RoleDataChangeReq(ACT_ID.LKDRAW)
		self:RoleDataChangeReq(ACT_ID.XFGIFTFT)
		self:RoleDataChangeReq(ACT_ID.DRAWFL)
		self:RoleDataChangeReq(ACT_ID.QMQG)
		self:RoleDataChangeReq(ACT_ID.HHDL)
		self:RoleDataChangeReq(ACT_ID.CZRANK)
		self:RoleDataChangeReq(ACT_ID.CZLC)
		self:RoleDataChangeReq(ACT_ID.LCFD)
		self:RoleDataChangeReq(ACT_ID.CSFS)
		self:RoleDataChangeReq(ACT_ID.XSCZ)
		self:RoleDataChangeReq(ACT_ID.FHB)
		self:RoleDataChangeReq(ACT_ID.GZP)
		self:RoleDataChangeReq(ACT_ID.CZFL)
		self:RoleDataChangeReq(ACT_ID.SVZP)
		self:RoleDataChangeReq(ACT_ID.LXFL)
		self:RoleDataChangeReq(ACT_ID.LCFL)
		self:RoleDataChangeReq(ACT_ID.DHHL)
		self:RoleDataChangeReq(ACT_ID.CZZF)
		self:RoleDataChangeReq(ACT_ID.XFJL)
		--RemindName.ActivityBrillianCZLC
	elseif  key.key == OBJ_ATTR.ACTOR_KILL_DEVIL_TOKEN then
		self:RoleDataChangeReq(ACT_ID.SZ)
		self:RoleDataChangeReq(ACT_ID.SZGIFT)
		self:RoleDataChangeReq(ACT_ID.SZHK)
	elseif  key.key == OBJ_ATTR.ACTOR_RING_CRYSTAL then
		self:RoleDataChangeReq(ACT_ID.TJ)
		self:RoleDataChangeReq(ACT_ID.TJGIFT)
		self:RoleDataChangeReq(ACT_ID.TJHK)
	-- elseif  key.key == OBJ_ATTR.ACTOR_FEATHER then
	-- 	self:RoleDataChangeReq(ACT_ID.WING)
	-- 	self:RoleDataChangeReq(ACT_ID.WINGHK)
	-- 	self:RoleDataChangeReq(ACT_ID.WINGGIFT)
	elseif  key.key == OBJ_ATTR.ACTOR_ENERGY then
		self:RoleDataChangeReq(ACT_ID.BOSS)
	elseif  key.key == OBJ_ATTR.ACTOR_DRAW_GOLD_COUNT then
		self:RoleDataChangeReq(ACT_ID.CZGIFT)
		self:RoleDataChangeReq(ACT_ID.LXCZ)
		self:RoleDataChangeReq(ACT_ID.DBCZ)
		self:RoleDataChangeReq(ACT_ID.CZZP)
	elseif  key.key == OBJ_ATTR.CREATURE_LEVEL then
		self:RoleDataChangeReq(ACT_ID.DJJJ)
	elseif  key.key == OBJ_ATTR.ACTOR_CIRCLE then
		self:RoleDataChangeReq(ACT_ID.DJJJ)
	elseif  key.key == OBJ_ATTR.ACTOR_SWING_LEVEL then
		self:RoleDataChangeReq(ACT_ID.CBJJ)
	elseif  key.key == OBJ_ATTR.ACTOR_BATTLE_POWER then
		self:RoleDataChangeReq(ACT_ID.ZLJJ)
	end
end

function ActivityBrilliantCtrl:GetRemindNum(remind_name)
	return self.data:GetRemindNumByType(remind_name)
end

function ActivityBrilliantCtrl.ActivityReq(mes_type, act_id, activity_index, act_tag)
	if not ActivityBrilliantData.Instance:CheckActOpen(act_id) then
		return
	end
	if ActivityBrilliantData.Instance:IsNonuse(act_id) then return end
	local cmd_id = ActivityBrilliantData.Instance:GetCmdIdByActId(act_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSSendActivityBrillantReq)
	protocol.type = mes_type or 0
	protocol.cmd_id = cmd_id or 0
	protocol.act_id = act_id or 0
	protocol.act_tag = act_tag or 0
	protocol.activity_index = activity_index or 0
	protocol:EncodeAndSend()
end

function ActivityBrilliantCtrl:OpenActDataReq()
	for k,v in pairs(self.data.can_list) do
		ActivityBrilliantCtrl.ActivityReq(3, v.act_id)
	end
end

function ActivityBrilliantCtrl:GetIsOpenActByActId(act_id)
	for k,v in pairs(self.data.can_list) do
		if v.act_id == act_id then
			return true
		end
	end
	return false
end

function ActivityBrilliantCtrl.ActivityListReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSSendActivityBrillantReq)
	protocol.type = 1
	protocol:EncodeAndSend()
end

function ActivityBrilliantCtrl.SendBuyLiquanShangcheng(item_index)
	ActivityBrilliantCtrl.ActivityReq(4, ACT_ID.LQSC, item_index)
end

function ActivityBrilliantCtrl.EndCurBrand()
	local protocol = ProtocolPool.Instance:GetProtocol(CSSendActivityBrillantReq)
	protocol.type = 4
	protocol.cmd_id = ActivityBrilliantData.Instance:GetCmdIdByActId(ACT_ID.XYFP) or 0
	protocol.act_id = ACT_ID.XYFP
	protocol.op_type = 2
	protocol:EncodeAndSend()
	ActivityBrilliantData.Instance:SetBrandInfo({})
end

function ActivityBrilliantCtrl.SentTurnBrandReq(index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSSendActivityBrillantReq)
	protocol.type = 4
	protocol.cmd_id = ActivityBrilliantData.Instance:GetCmdIdByActId(ACT_ID.XYFP) or 0
	protocol.act_id = ACT_ID.XYFP
	protocol.op_type = 1
	protocol.activity_index = index
	protocol:EncodeAndSend()
end

function ActivityBrilliantCtrl.SendTurnRecordReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSSendActivityBrillantReq)
	protocol.type = 4
	protocol.cmd_id = ActivityBrilliantData.Instance:GetCmdIdByActId(ACT_ID.XYFP) or 0
	protocol.act_id = ACT_ID.XYFP
	protocol.op_type = 3
	protocol:EncodeAndSend()
end

function ActivityBrilliantCtrl:CheckRobRedBagReqTip(index)
	self.data:SetCanRobNum(index)
	MainuiCtrl.Instance:InvateTip(MAINUI_TIP_TYPE.ROB_RED_PACKAGE, index, function ()
		ActivityBrilliantCtrl.ActivityReq(4, ACT_ID.FHB, 1)
		-- self.can_rob = self.can_rob - 1
		-- self:CheckRobRedBagReqTip(self.can_rob)
		-- self:CheckRobRedBagReqTip(0)
	end)
end

function ActivityBrilliantCtrl:SetRedEffct(is_cool_time, had_num)
	-- if self.timer_quest then
	-- 	GlobalTimerQuest:CancelQuest(self.timer_quest)
	-- 	self.timer_quest = nil
	-- end
	-- if self.layout == nil then
	-- 	self.layout = XUI.CreateLayout(430, 280, 100, 100)
	-- 	local view = MainuiCtrl.Instance:GetView()
	-- 	view.root_node:addChild(self.layout, 999)	
	-- end
	-- if self.effect == nil then
	-- 	self.effect = AnimateSprite:create()
	-- 	self.effect:setPosition(50, 50)
	-- 	self.layout:addChild(self.effect,1)
	-- 	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(1)
	-- 	self.effect:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
	-- end
	-- XUI.AddClickEventListener(self.layout, BindTool.Bind1(self.GetRedReward, self),false)
	-- self.layout:setVisible(false)
	-- if had_num > 0 and is_cool_time <= 0 then
	-- 	self.layout:setVisible(true)
	-- 	self.data:SetCanRobNum(1)
	-- else
	-- 	self.layout:setVisible(false)
	-- 	self.data:SetCanRobNum(0)
	-- 	if  had_num > 0 and is_cool_time > 0 then
	-- 		self.timer_quest = GlobalTimerQuest:AddRunQuest(function()
	-- 			if self.effect then
	-- 				self.layout:setVisible(true)
	-- 				self.data:SetCanRobNum(1)
	-- 			end
	-- 		 end, is_cool_time)
	-- 	else
	-- 		self.data:SetCanRobNum(0)
	-- 		if self.effect then
	-- 			self.effect:setStop()
	-- 			self.effect = nil
	-- 		end
	-- 		if self.timer_quest then
	-- 			GlobalTimerQuest:CancelQuest(self.timer_quest)
	-- 			self.timer_quest = nil
	-- 		end
	-- 	end
	-- end
end

function ActivityBrilliantCtrl:GetRedReward()
	ActivityBrilliantCtrl.ActivityReq(4, ACT_ID.FHB, 1)
end

function ActivityBrilliantCtrl:StartFlyItem(item_id)
	local path = ""
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if nil ~= item_cfg and item_cfg.icon and item_cfg.icon > 0 then
		path = ResPath.GetItem(item_cfg.icon)
	end
	
	if "" == path  then return end

	local screen_w = HandleRenderUnit:GetWidth()
	local screen_h = HandleRenderUnit:GetHeight()
	local fly_icon = XUI.CreateImageView(0, 0, path, false)
	fly_icon:setAnchorPoint(0, 0)
	HandleRenderUnit:AddUi(fly_icon, COMMON_CONSTS.ZORDER_SYSTEM_EFFECT, COMMON_CONSTS.ZORDER_SYSTEM_EFFECT)
	local world_pos = fly_icon:convertToWorldSpace(cc.p(0,0))
	fly_icon:setPosition(screen_w / 2, screen_h / 2)

	local fly_to_pos = cc.p(1042,569)
	local move_to =cc.MoveTo:create(0.8, cc.p(fly_to_pos.x, fly_to_pos.y))
	local spawn = cc.Spawn:create(move_to)
	local callback = cc.CallFunc:create(BindTool.Bind2(self.ItemFlyEnd, self, fly_icon))
	local action = cc.Sequence:create(spawn, callback)
	fly_icon:runAction(action)
end

function ActivityBrilliantCtrl:ItemFlyEnd(fly_icon)
	if fly_icon then
		fly_icon:removeFromParent()
	end
end