require("game/city_combat/city_combat_view")
require("game/city_combat/city_combat_fb_view")
require("game/city_combat/city_combat_data")
require("game/city_combat/city_combat_victory_view")
require("game/city_combat/city_reward_view")

CityCombatCtrl = CityCombatCtrl or BaseClass(BaseController)

function CityCombatCtrl:__init()
	if CityCombatCtrl.Instance then
		print_error("[CityCombatCtrl] Attemp to create a singleton twice !")
	end
	CityCombatCtrl.Instance = self
	self.data = CityCombatData.New()
	self.view = CityCombatView.New(ViewName.CityCombatView)
	self.fb_view = CityCombatFBView.New(ViewName.CityCombatFBView)
	self.reward_view = CityRewardView.New(ViewName.CityReward)
	-- self.victory_view = CityCombatVictoryView.New(ViewName.CityCombatVictoryView)
	self:RegisterAllProtocols()
end

function CityCombatCtrl:__delete()
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.fb_view then
		self.fb_view:DeleteMe()
		self.fb_view = nil
	end

	if self.reward_view then
		self.reward_view:DeleteMe()
		self.reward_view = nil
	end

	if self.delay_timer then
		GlobalTimerQuest:CancelQuest(self.delay_timer)
		self.delay_timer = nil
	end

	CityCombatCtrl.Instance = nil
	
end

function CityCombatCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCGongChengZhanOwnerInfo, "SetCityOwnerInfo")
	self:RegisterProtocol(SCGCZRoleInfo, "SetSelfInfo")
	self:RegisterProtocol(SCGCZGlobalInfo, "SetGlobalInfo")
	self:RegisterProtocol(SCGCZRewardInfo, "ShowFinalReward")
	--self:RegisterProtocol(SCZhanchangLuckyInfo, "OnZhanchangLuckyInfo")
	--self:RegisterProtocol(SCTwLuckyRewardInfo, "OnTwLuckyRewardInfo")
	self:RegisterProtocol(SCGBLuckyRewardInfo, "OnGBLuckyRewardInfo")
	self:RegisterProtocol(SCQxdldLuckyRewardInfo, "OnQxdldLuckyRewardInfo")
	self:RegisterProtocol(SCGCZWorshipInfo, "OnGCZWorshipInfo")
	--膜拜活动开启结束
	self:RegisterProtocol(SCGCZWorshipActivityInfo, "OnGCZWorshipActivityInfo")
end

function CityCombatCtrl:OnZhanchangLuckyInfo(protocol)
	self.data:SetZhanChangLuckInfo(protocol)
	if FuBenCtrl.Instance:GetFuBenIconView() then
		FuBenCtrl.Instance:GetFuBenIconView():Flush("zhanchan_info")
	end
	self:FlushRewradView()

end


function CityCombatCtrl:OnGBLuckyRewardInfo(protocol)
	self.data:SetGBLuckInfo(protocol)
	if FuBenCtrl.Instance:GetFuBenIconView() then
		FuBenCtrl.Instance:GetFuBenIconView():Flush("gb_info")
	end
	self:FlushRewradView()

end

function CityCombatCtrl:OnQxdldLuckyRewardInfo(protocol)
	self.data:SetQXLDLuckInfo(protocol)
	if FuBenCtrl.Instance:GetFuBenIconView() then
		FuBenCtrl.Instance:GetFuBenIconView():Flush("qxld_info")
	end
	self:FlushRewradView()

end
--城主信息
function CityCombatCtrl:SetCityOwnerInfo(protocol)
	self.data:SetCityOwnerInfo(protocol)
end

--个人信息
function CityCombatCtrl:SetSelfInfo(protocol)
	self.data:SetSelfInfo(protocol)
	self.fb_view:Flush()
	self:FlushSceneRoleInfo()
end

--复位5秒倒计时
function CityCombatCtrl:PoChengReset()
	self.fb_view:PoChengReset()
end

--攻城战全局信息
function CityCombatCtrl:SetGlobalInfo(protocol)
	local scene_logic = Scene.Instance:GetSceneLogic()
	if scene_logic then
		if scene_logic:GetSceneType() == SceneType.GongChengZhan then
			if protocol.is_poqiang == 1 then
				if self.delay_timer then
					GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
					self.delay_timer = nil
				end
				self.delay_timer = GlobalTimerQuest:AddDelayTimer(function ()
					scene_logic:SetBlock(false)
				end, 3)
			else
				scene_logic:SetBlock(true)
			end
		end
	end
	self.data:SetGlobalInfo(protocol)
	self.fb_view:Flush()
	self.fb_view:FlushDefGuildTime()
	self:FlushSceneRoleInfo()
end

function CityCombatCtrl:FlushSceneRoleInfo()
	local main_role = Scene.Instance:GetMainRole()
	local role_list = Scene.Instance:GetRoleList()
	main_role:ReloadSpecialImage()
	main_role:ReloadUIName()
	for k,v in pairs(role_list) do
		v:ReloadSpecialImage()
		v:ReloadUIName()
	end
end

--攻城战结算
function CityCombatCtrl:ShowFinalReward(protocol)
	local data = {}
	data.reward_list = protocol.reward_list
	if protocol.shengwang_reward > 0 then
		local shengwang_data = {}
		shengwang_data.item_id = ResPath.CurrencyToIconId["honor"]
		shengwang_data.num = protocol.shengwang_reward
		table.insert(data.reward_list, shengwang_data)
	end

	if protocol.gold_reward > 0 then
		local gold_data = {}
		gold_data.item_id = ResPath.CurrencyToIconId["diamond"]
		gold_data.num = protocol.gold_reward
		table.insert(data.reward_list, gold_data)
	end

	if protocol.gongxun > 0 then
		local gongxun_data = {}
		gongxun_data.item_id = ResPath.CurrencyToIconId["gongxun"]
		gongxun_data.num = protocol.gongxun
		table.insert(data.reward_list, gongxun_data)
	end
	local chestshop_score_data = {}
	if protocol.daily_chestshop_score > 0 then
		chestshop_score_data.item_id = ResPath.CurrencyToIconId["jifen"]
		chestshop_score_data.num = protocol.daily_chestshop_score
		-- table.insert(data.reward_list, chestshop_score_data)
	end
	TipsCtrl.Instance:OpenActivityRewardTip(data, chestshop_score_data)
end

--传送到拆旗/资源区
function CityCombatCtrl:QuickChangePlace(type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGCZChangePlace)
	protocol.place_type = type
	protocol:EncodeAndSend()
end

function CityCombatCtrl:CloseRewardView()
	if self.reward_view:IsOpen() then
		self.reward_view:Close()
	end
end

function CityCombatCtrl:OpenRewardView()
	if self.reward_view:IsOpen() then
		self.reward_view:Flush()
		return
	end
	ViewManager.Instance:Open(ViewName.CityReward)
end
function CityCombatCtrl:FlushRewradView()
	if self.reward_view:IsOpen() then
		self.reward_view:Flush()
	end
end

--攻城战接收膜拜,在该场景中才发送协议
function CityCombatCtrl:OnGCZWorshipInfo(protocol)
	self.data:SetGCZWorshipInfo(protocol)
	MainUICtrl.Instance.view:Flush("city_combat_worship")
	local city_worship_is_open = CityCombatData.Instance:GetWorshipIsOpen()
	local worship_cfg = CityCombatData.Instance:GetOtherConfig()
	local present_scene_id = Scene.Instance:GetSceneId()

	local rest_time = protocol.next_worship_timestamp - TimeCtrl.Instance:GetServerTime()
	if MainUICtrl.Instance.view and MainUICtrl.Instance.view.reminding_view then
		local count_down = MainUICtrl.Instance.view.reminding_view:GetWorshipCountDown()
		if CountDown.Instance:GetRemainTime(count_down) <= 0 and rest_time > 0 then
			MainUICtrl.Instance.view:SetWorshipCountDown(10)  --rest_time
		end
		MainUICtrl.Instance.view:ShowWorshipCdmask(rest_time > 0)
		if worship_cfg and worship_cfg.worship_click_time then 
			MainUICtrl.Instance.view:ShowCCWorshipBtn(protocol.worship_time < worship_cfg.worship_click_time)
		end
	end

	
	if city_worship_is_open == 1 and present_scene_id == worship_cfg.worship_scene_id then 
		if self.main_role_pos_change_callback == nil then
			self.main_role_pos_change_callback = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_POS_CHANGE, BindTool.Bind(self.OnCCWorshipPosChange, self))
		end
	end

	--活动开启中时，不在该场景则关闭侦听
	if present_scene_id ~= worship_cfg.worship_scene_id then
		if self.main_role_pos_change_callback then
			GlobalEventSystem:UnBind(self.main_role_pos_change_callback)
			self.main_role_pos_change_callback = nil
		end
	end
end

--膜拜-确定是否发送了这个协议
function CityCombatCtrl:SendGCZWorshipReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGCZWorshipReq)
	protocol:EncodeAndSend()
end

--通知活动开启结束
function CityCombatCtrl:OnGCZWorshipActivityInfo(protocol)
	self.data:SetGCZWorshipActivityInfo(protocol)

	MainUICtrl.Instance:FlushView("show_city_combat_worship", {self.data:GetWorshipIsOpen() == 1})
	local main_role = Scene.Instance:GetMainRole()
	if not main_role then return end
	local role_pos_x, role_pos_y = main_role:GetLogicPos()
	self:OnCCWorshipPosChange(role_pos_x, role_pos_y)

	if self.data:GetWorshipIsOpen() > 0 then
		ActivityData.Instance:SetActivityStatus(ACTIVITY_TYPE.GONGCHENGZHAN_WORSHIP, ACTIVITY_STATUS.OPEN, protocol.worship_end_timestamp, 0, 0, 0)
	else
		ActivityData.Instance:SetActivityStatus(ACTIVITY_TYPE.GONGCHENGZHAN_WORSHIP, ACTIVITY_STATUS.CLOSE, protocol.worship_end_timestamp, 0, 0, 0)
	end

	--活动接收取消侦听
	if self.main_role_pos_change_callback then
		GlobalEventSystem:UnBind(self.main_role_pos_change_callback)
		self.main_role_pos_change_callback = nil
	end
end

--主角膜拜范围显示膜拜按钮--攻城战
function CityCombatCtrl:OnCCWorshipPosChange(x, y)
	local worship_cfg = CityCombatData.Instance:GetOtherConfig()
	local worship_is_open = CityCombatData.Instance:GetWorshipIsOpen()
	local present_scene_id = Scene.Instance:GetSceneId() 
	local worship_click_num = CityCombatData.Instance:GetWorshipClickNum()


	if worship_click_num < worship_cfg.worship_click_time and present_scene_id == worship_cfg.worship_scene_id and worship_is_open == 1 then		
		MainUICtrl.Instance.view:ShowCCWorshipBtn(CityCombatData.Instance:ConfineToWorshipRange(x, y))
	end
	if present_scene_id ~= worship_cfg.worship_scene_id or worship_is_open ~= 1 then
		MainUICtrl.Instance.view:ShowCCWorshipBtn(false)
	end
end