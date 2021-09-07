require("game/activity/activity_view")
require("game/activity/activity_detail_view")
require("game/activity/activity_qixi_view")
require("game/activity/activity_data")
require("game/military_hall_activity/military_hall_view")
require("game/activity/activity_midautumn_view")

ActivityCtrl = ActivityCtrl or  BaseClass(BaseController)

function ActivityCtrl:__init()
	if ActivityCtrl.Instance ~= nil then
		print_error("[ActivityCtrl] attempt to create singleton twice!")
		return
	end
	ActivityCtrl.Instance = self

	self:RegisterAllProtocols()

	self.view = ActivityView.New(ViewName.Activity)
	self.detail_view = ActivityDetailView.New(ViewName.ActivityDetail)
	self.military_hall_view = MilitaryHallView.New(ViewName.MilitaryHallView)

	self.qixi_view = ActivityQiXiView.New(ViewName.ActivityQiXiView)
	self.mid_autumn_view = ActivityMidAutumnView.New(ViewName.ActivityMidAutumnView)
	self.data = ActivityData.New()
end

function ActivityCtrl:__delete()
	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.military_hall_view ~= nil then
		self.military_hall_view:DeleteMe()
		self.military_hall_view = nil
	end
	
	if self.detail_view ~= nil then
		self.detail_view:DeleteMe()
		self.detail_view = nil
	end

	if self.qixi_view ~= nil then
		self.qixi_view:DeleteMe()
		self.qixi_view = nil
	end

	if self.mid_autumn_view ~= nil then
		self.mid_autumn_view:DeleteMe()
		self.mid_autumn_view = nil
	end

	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end

	ActivityCtrl.Instance = nil
end

function ActivityCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCActivityStatus, "OnActivityStatus")
	self:RegisterProtocol(SCCrossRandActivityStatus, "OnCrossRandActivityStatus")
	self:RegisterProtocol(CSGetRankInfo)
end

function ActivityCtrl:SendGetRankInfo(protocol)
	local protocol_send = ProtocolPool.Instance:GetProtocol(CSGetRankInfo)
	protocol_send:EncodeAndSend()
end

-- 活动信息
function ActivityCtrl:OnActivityStatus(protocol)
	--print_log("##########OnActivityStatus:", protocol.activity_type, protocol.status)
	-- 设置开服活动战场争霸信息
	for k, v in pairs(BattleActivityId) do
		if v == protocol.activity_type then
			KaifuActivityData.Instance:SetActivityStatus(protocol.activity_type, protocol.status, protocol.next_status_switch_time, protocol.param_1, protocol.param_2, protocol.open_type)
		end
	end

	local act_statu = self.data:GetActivityStatuByType(protocol.activity_type)

	if (act_statu and act_statu.status == protocol.status) or
		(nil == act_statu and protocol.status == ACTIVITY_STATUS.CLOSE) then
		if ACTIVITY_STATUS.OPEN == protocol.status then
			if protocol.activity_type < ACTIVITY_TYPE.OPEN_SERVER or CrossServerData.CheckIsKfType(protocol.activity_type) then
				if protocol.activity_type == ACTIVITY_TYPE.KF_BOSS then
					return
				else
				self:OpenPopView(protocol.activity_type)
				end
			end
		end
		return
	end

	self.data:SetActivityStatus(protocol.activity_type, protocol.status, protocol.next_status_switch_time, protocol.param_1, protocol.param_2, protocol.open_type)
	self:FlushQiXiView(protocol.activity_type)

	local content = ""
	local activity_cfg = self.data:GetActivityConfig(protocol.activity_type)
	if activity_cfg ~= nil then
		local level_limit = activity_cfg.min_level
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		if main_role_vo.level < level_limit then
			return
		end

		local name = activity_cfg.act_name

		if activity_cfg.act_id == 1026 then
			name = Language.Common.CloseBeta
		end

		if ACTIVITY_STATUS.CLOSE == protocol.status then
			if protocol.activity_type == ACTIVITY_TYPE.SHUIJING then
				content = Language.Activity["HuoDongYiGuanBi" .. protocol.activity_type]
			else
				content = name .. Language.Activity.HuoDongYiGuanBi
			end
			if CrossServerData.LAST_CROSS_TYPE == protocol.activity_type then
				CrossServerCtrl.Instance:GoBack()
			end

			if protocol.activity_type == ACTIVITY_TYPE.KF_ONEVONE and KuaFu1v1Data.Instance:GetIsOutFrom1v1Scene() then
				TipsCtrl.Instance:ShowReminding(Language.Kuafu1V1.MatchFailTxt2)
				KuaFu1v1Data.Instance:SetIsOutFrom1v1Scene(false)
			end
		elseif ACTIVITY_STATUS.STANDY == protocol.status then
			if protocol.activity_type == ACTIVITY_TYPE.SHUIJING then
				content = Language.Activity["NaiXinDengDai" .. protocol.activity_type]
			else
				content = name .. Language.Activity.NaiXinDengDai
			end
			SysMsgCtrl.Instance:RollingEffect(content, GUNDONGYOUXIAN.ACTIVITY_TYPE)
		elseif ACTIVITY_STATUS.OPEN == protocol.status then
			if protocol.activity_type == ACTIVITY_TYPE.SHUIJING then
				content = Language.Activity["ActivityStart" .. protocol.activity_type]
			else
				content = name .. Language.Activity.ActivityStart
			end
			SysMsgCtrl.Instance:RollingEffect(content, GUNDONGYOUXIAN.ACTIVITY_TYPE)
			if protocol.activity_type < ACTIVITY_TYPE.OPEN_SERVER or CrossServerData.CheckIsKfType(protocol.activity_type) then
				self:OpenPopView(protocol.activity_type)
			end

			if protocol.activity_type == ACTIVITY_TYPE.KF_ONEVONE and not IS_ON_CROSSSERVER and not KuaFu1v1Data.Instance:GetIsOutFrom1v1Scene() then
				ViewManager.Instance:Open(ViewName.KuaFu1v1)
			end
		end
	end
	if "" ~= content and (protocol.activity_type < ACTIVITY_TYPE.OPEN_SERVER
	or protocol.activity_type >= ACTIVITY_TYPE.Act_Roller) then
		ChatCtrl.Instance:AddSystemMsg(content)
		if protocol.activity_type == ACTIVITY_TYPE.SHUIJING then
			local shuijing_data = CrossCrystalData.Instance
			if protocol.status == 0 then
				shuijing_data:SetNextTime(0)
			elseif protocol.status == 1 then
				shuijing_data:SetNextTime(0)
			elseif protocol.status == 2 then
				shuijing_data:SetNextTime(protocol.next_status_switch_time)
			end
		end
	end
	--天降鸿福（大富豪）
	if protocol.activity_type == DaFuHaoDataActivityId.ID and protocol.status == ACTIVITY_STATUS.OPEN then
		DaFuHaoCtrl.Instance:SendGetGatherInfoReq()
		if not ViewManager.Instance:IsOpen(ViewName.DaFuHao) and DaFuHaoData.Instance:IsDaFuHaoScene() then
			MainUICtrl.Instance:ClickSwitch()
		end
	elseif protocol.activity_type == DaFuHaoDataActivityId.ID and protocol.status ~= ACTIVITY_STATUS.OPEN then
		if protocol.status == ACTIVITY_STATUS.CLOSE then

			if ViewManager.Instance:IsOpen(ViewName.DaFuHao) then
				ViewManager.Instance:Close(ViewName.DaFuHao)
				MainUICtrl.Instance:SetViewState(true)
			end

			for k, v in pairs(Scene.Instance:GetObjList()) do
				v:SetAttr("millionare_type", 0)
			end

			if ViewManager.Instance:IsOpen(ViewName.DaFuHaoRoll) then
				ViewManager.Instance:Close(ViewName.DaFuHaoRoll)
			end

			DaFuHaoCtrl.Instance:CloseDaFuHao()
			MainUICtrl.Instance:FlushView("dafuhao")
		end
		DaFuHaoCtrl.Instance:FlushDaFuHaoView()

		if DaFuHaoData.Instance then
			DaFuHaoData.Instance:ClearInfo()
		end
	end

	RemindManager.Instance:Fire(RemindName.ShengXiao_Uplevel)
	RemindManager.Instance:Fire(RemindName.CrossFlowerRank)
	MainUICtrl.Instance:FlushView("shen_ge_effect")

	if protocol.activity_type == ACTIVITY_TYPE.ACTIVITY_TYPE_XINGZUOYIJI
		and protocol.status == ACTIVITY_STATUS.OPEN
		and OpenFunData.Instance:CheckIsHide("shengxiao_uplevel") then

		local ok_callback = function()
			ActivityCtrl.Instance:SendActivityEnterReq(ACTIVITY_TYPE.ACTIVITY_TYPE_XINGZUOYIJI, 0)
			ViewManager.Instance:CloseAll()
		end
		TipsCtrl.Instance:OpenFocusBossTip(nil, ok_callback, false, true)
	end

	if protocol.activity_type == ACTIVITY_TYPE.GONGCHENGZHAN and protocol.status == ACTIVITY_STATUS.CLOSE then
		MainUICtrl.Instance:FlushView("show_city_combat_worship", {true})
		MainUICtrl.Instance:ShowWorshipEntrance(true)
	end

	if protocol.activity_type == ACTIVITY_TYPE.KF_GUILDBATTLE then
		InKuaFuLiuJieActivity = protocol.status
		KuafuGuildBattleCtrl.Instance:ActivityChange()
		KuafuGuildBattleCtrl.Instance:SendCrossGuildBattleOperateReq(CROSS_GUILDBATTLE_OPERATE.CROSS_GUILDBATTLE_OPERATE_REQ_INFO)
		KuafuGuildBattleCtrl.Instance:SendCrossGuildBattleOperateReq(CROSS_GUILDBATTLE_OPERATE.CROSS_GUILDBATTLE_OPERATE_REQ_TASK_INFO)
		-- if protocol.status == ACTIVITY_STATUS.OPEN and KuafuGuildBattleData.Instance:CheckOpen() and KuafuGuildBattleData.Instance:IsKuafuScene() then
		-- 	KuafuGuildBattleCtrl.Instance:Open()
		-- end
	end

	if protocol.activity_type == ACTIVITY_TYPE.KF_ONEVONE and protocol.status == ACTIVITY_STATUS.CLOSE then
		KuaFu1v1Ctrl.Instance:CloseByActClose()
	end
end


function ActivityCtrl:OnCrossRandActivityStatus(protocol)
	print_log("ActivityCtrl:OnCrossRandActivityStatus-->>", ActivityData.GetActivityName(protocol.activity_type), ActivityData.GetActivityStatusName(protocol.status))

	self.data:SetActivityStatus(protocol.activity_type, protocol.status, 0, protocol.begin_time, protocol.end_time)
end

function ActivityCtrl:OpenPopView(activity_type)
	if IS_ON_CROSSSERVER then
		return
	end
	if activity_type == ACTIVITY_TYPE.QUESTION then		--答题面板
		AnswerCtrl.Instance:OpenView()
		return
	end
end

function ActivityCtrl:SendActivityEnterReq(activity_type, room_index)
	if not activity_type then return end
	local protocol = ProtocolPool.Instance:GetProtocol(CSActivityEnterReq)
	protocol.activity_type = activity_type
	protocol.room_index = room_index or 0
	protocol:EncodeAndSend()
end

function ActivityCtrl:GetDetailView()
	return self.detail_view
end

function ActivityCtrl:CloseDetailView()
	if self.detail_view and self.detail_view:IsOpen() then
		self.detail_view:Close()
	end
end

function ActivityCtrl:CloseView()
	if self.view then
		self.view:Close()
	end
end

function ActivityCtrl:ShowDetailView(act_id)
	if not act_id then return end
	if act_id == ACTIVITY_TYPE.KF_ONEVONE then
		ViewManager.Instance:Open(ViewName.KuaFu1v1)
		return
	elseif act_id == ACTIVITY_TYPE.CLASH_TERRITORY then
		ViewManager.Instance:Open(ViewName.ClashTerritory)
		return
	elseif act_id == ACTIVITY_TYPE.GONGCHENGZHAN then
		ViewManager.Instance:Open(ViewName.CityCombatView)
		return
	end
	self.detail_view:SetActivityId(act_id)
	self.detail_view:Open()
	self.detail_view:Flush()
end

function ActivityCtrl:GuildBattleViewIsOpen()
	if self.detail_view:IsOpen() then
		local act_id = self.detail_view:GetActivityId()
		if act_id == ACTIVITY_TYPE.GUILDBATTLE then
			self.detail_view:Flush("guild_fight_king")
		end
	end
end

function ActivityCtrl:QiXiOpenView(view_str, act_id)
	if self.qixi_view ~= nil and self.qixi_view:IsOpen() and view_str ~= nil and act_id ~= nil then
		self.qixi_view:SetOpenView(view_str, act_id)
	end
end

function ActivityCtrl:MidAutumnOpenView(view_str, act_id)
	if self.mid_autumn_view ~= nil and self.mid_autumn_view:IsOpen() and view_str ~= nil and act_id ~= nil then
		self.mid_autumn_view:SetOpenView(view_str, act_id)
	end
end

function ActivityCtrl:FlushQiXiView(act_id)
	local is_flush = false
	if act_id == nil then
		return
	end

	if self.qixi_view == nil then
		return
	end

	if not self.qixi_view:IsOpen() then
		return
	end

	if ACTIVITY_ACT_QIXI_DATA ~= nil then
		for k,v in pairs(ACTIVITY_ACT_QIXI_DATA) do
			if v.act_id ~= nil and v.act_id == act_id then
				is_flush = true
				break
			end
		end
	end

	if is_flush then
		self.qixi_view:Flush()
	end
end