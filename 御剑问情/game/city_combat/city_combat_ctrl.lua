require("game/city_combat/city_combat_view")
require("game/city_combat/city_combat_fb_view")
require("game/city_combat/city_combat_data")
require("game/city_combat/city_combat_victory_view")
require("game/city_combat/city_reward_view")
require("game/city_combat/city_combat_first_view")
require("game/city_combat/guild_first_view")
require("game/city_combat/worship_view")
require("game/city_combat/xianmengwar_view")
require("game/city_combat/hefu_city_combat_first_view")
require("game/city_combat/hefu_city_combat_tip")

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
	self.first_view = CityCombatFirstView.New(ViewName.CityCombatFirstView)
	self.hefu_first_view = HeFuCombatFirstView.New(ViewName.HeFuCombatFirstView)
	self.tequan_tips_view = HeFuCityCombatTip.New()
	self.guild_first_view = GuildFirstView.New(ViewName.GuildFirstView)
	self.xian_meng_war_view = XianMengWarView.New(ViewName.XianMengWarView)
	self.worship = WorshipView.New(ViewName.WorshipView)
	-- self.victory_view = CityCombatVictoryView.New(ViewName.CityCombatVictoryView)
	self:RegisterAllProtocols()
	self:BindGlobalEvent(OtherEventType.RoleInfo, BindTool.Bind(self.SetCityOwnerAndLoverInfo, self))

	self.is_first_rec_worshipinfo = true
end

function CityCombatCtrl:__delete()
	self.data:DeleteMe()
	self.view:DeleteMe()
	self.fb_view:DeleteMe()
	self.reward_view:DeleteMe()
	self.guild_first_view:DeleteMe()
	self.first_view:DeleteMe()
	self.hefu_first_view:DeleteMe()

	if nil ~= self.gather_delay then
		GlobalTimerQuest:CancelQuest(self.gather_delay)
		self.gather_delay = nil
	end

	CityCombatCtrl.Instance = nil
end

function CityCombatCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCGongChengZhanOwnerInfo, "SetCityOwnerInfo")
	self:RegisterProtocol(SCGCZRoleInfo, "SetSelfInfo")
	self:RegisterProtocol(SCGCZGlobalInfo, "SetGlobalInfo")
	self:RegisterProtocol(SCGCZRewardInfo, "ShowFinalReward")
	self:RegisterProtocol(SCZhanchangLuckyInfo, "OnZhanchangLuckyInfo")
	self:RegisterProtocol(SCTwLuckyRewardInfo, "OnTwLuckyRewardInfo")
	self:RegisterProtocol(SCGBLuckyRewardInfo, "OnGBLuckyRewardInfo")
	self:RegisterProtocol(SCQxdldLuckyRewardInfo, "OnQxdldLuckyRewardInfo")
	self:RegisterProtocol(SCGCZWorshipInfo, "OnGCZWorshipInfo")
	self:RegisterProtocol(SCCSAGONGCHENGZHANInfo, "OnSCCSAGONGCHENGZHANInfo")


	self:RegisterProtocol(CSGCZWorshipReq)
end

function CityCombatCtrl:OnZhanchangLuckyInfo(protocol)
	self.data:SetZhanChangLuckInfo(protocol)
	if FuBenCtrl.Instance:GetFuBenIconView() then
		FuBenCtrl.Instance:GetFuBenIconView():Flush("zhanchan_info")
	end
	self:FlushRewradView()

end

function CityCombatCtrl:OnTwLuckyRewardInfo(protocol)
	self.data:SetTWLuckInfo(protocol)
	if FuBenCtrl.Instance:GetFuBenIconView() then
		FuBenCtrl.Instance:GetFuBenIconView():Flush("tw_info")
	end
	self:FlushRewradView()

end

function CityCombatCtrl:OnSCCSAGONGCHENGZHANInfo(protocol)
	self.data:SetHefuFirstInfo(protocol)
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

function CityCombatCtrl:OnGCZWorshipInfo(protocol)
	if not ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.GONGCHENG_WORSHIP) then
		self.is_first_rec_worshipinfo = false
		return
	end

	self.data:SetGCZWorshipInfo(protocol)
	self.worship:Flush()
	
	if self.is_first_rec_worshipinfo then
		self.is_first_rec_worshipinfo = false
		return
	end

	self:DoWorship()
end

function CityCombatCtrl:DoWorship()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local mount_appeid = main_role_vo.mount_appeid
	local fight_mount_appeid = main_role_vo.fight_mount_appeid
	if fight_mount_appeid > 0 then
		FightMountCtrl.Instance:SendGoonFightMountReq(0)
	end
	if mount_appeid > 0 then
		MountCtrl.Instance:SendGoonMountReq(0)
	end

	local mainrole = Scene.Instance:GetMainRole()
	local statue = Scene.Instance:GetCityStatue()
	local statue_pos_x, statue_pos_y = CityCombatData.Instance:GetWorshipStatuePosParam()
	if nil ~= mainrole and nil ~= statue and statue_pos_x > 0 and statue_pos_y > 0 then
		local part = mainrole.draw_obj:GetPart(SceneObjPart.Main)
		part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Gather)
		
		local mainrole_root = mainrole:GetRoot()
		if nil == mainrole_root then
			return
		end

		local statue_root = statue:GetRoot()
		if nil == statue_root then
			return
		end

		towards = u3d.vec3(statue_root.transform.position.x, statue_root.transform.position.y, statue_root.transform.position.z)
		mainrole_root.transform:DOLookAt(towards, 0)
		
		if nil ~= self.gather_delay then
			GlobalTimerQuest:EndQuest(self.gather_delay)
			self.gather_delay = nil
		end
		local gather_time = CityCombatData.Instance:GetWorshipGatherTime() or 3
		self.gather_delay = GlobalTimerQuest:AddDelayTimer(function ()
			local mainrole = Scene.Instance:GetMainRole()
			local part = mainrole.draw_obj:GetPart(SceneObjPart.Main)
			part:SetInteger(ANIMATOR_PARAM.STATUS, ActionStatus.Idle)	
		end, gather_time)
	end
end

function CityCombatCtrl:SendWorshipReq()
	send_protocol = ProtocolPool.Instance:GetProtocol(CSGCZWorshipReq)
	send_protocol:EncodeAndSend()
end

--城主信息
function CityCombatCtrl:SetCityOwnerInfo(protocol)
	self.data:SetCityOwnerInfo(protocol)
	self.data:ClearCityOwnerInfo()

	if 0 ~= protocol.owner_id and protocol.guild_id > 0 then
		CheckCtrl.Instance:SendQueryRoleInfoReq(protocol.owner_id)
	end
end

function CityCombatCtrl:SetCityOwnerAndLoverInfo(role_id, role_info)
	local owner_info = self.data:GetCityOwnerInfo()
	local owner_role_info = self.data:GetCityOwnerRoleInfo()
	if nil ~= owner_info and owner_info.owner_id == role_id and nil ~= role_info then
		self.data:SetCityOwnerRoleInfo(role_info)
		self.view:Flush()

		if 0 ~= role_info.lover_uid then
			CheckCtrl.Instance:SendQueryRoleInfoReq(role_info.lover_uid)
		end

		local city_statue = Scene.Instance:GetCityStatue()
		if nil ~= city_statue then
			city_statue:RefreshCityOwnerStatue()
		end
	end
	
	local lover_uid = self.data:GetCityOwnerLoverRoleId()
	if nil ~= owner_info and nil ~= owner_role_info and lover_uid == role_id then
		self.data:SetLoverRoleInfo(role_info)
		self.view:Flush()
		
		local city_statue = Scene.Instance:GetCityStatue()
		if nil ~= city_statue then
			city_statue:RefreshCityOwnerStatue()
		end
	end
end

--个人信息
function CityCombatCtrl:SetSelfInfo(protocol)
	self.data:SetSelfInfo(protocol)
	self.fb_view:Flush()
	self:FlushSceneRoleInfo()
	ViewManager.Instance:FlushView(ViewName.FbIconView, "guild_call")
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
				scene_logic:SetBlock(false)
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
	TipsCtrl.Instance:OpenActivityRewardTip(data.reward_list)
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

function CityCombatCtrl:SetCityCombatFBTimeValue(value)
	self.fb_view:SetCityCombatFBTimeValue(value)
end

function CityCombatCtrl:ShowTequanTips(skill_name, skill_level, now_des, next_des, asset, bunble)
	self.tequan_tips_view:SetSkillName(skill_name)
	self.tequan_tips_view:SetSkillLevel(skill_level)
	self.tequan_tips_view:SetNowDes(now_des)
	self.tequan_tips_view:SetNextDes(next_des)
	self.tequan_tips_view:SetSkillRes(asset, bunble)
	self.tequan_tips_view:Open()
end

--前往膜拜
function CityCombatCtrl:GoWorship()
	if not ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.GONGCHENG_WORSHIP) then
		SysMsgCtrl.Instance:ErrorRemind(Language.CityCombat.ActivityNotOpen)
		return
	end

	local scene_id, x, y, range = self.data:GetWorshipScenIdAndPosXYAndRang()
	if scene_id < 0 or x < 0 or y < 0 or range < 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.CityCombat.SceneError)
		return
	end

	ViewManager.Instance:Close(ViewName.CityCombatView)

	x = x + math.random(-5, 5)
	y = y + math.random(-5, 5)
	GuajiCtrl.Instance:FlyToScenePos(scene_id, x, y)
end