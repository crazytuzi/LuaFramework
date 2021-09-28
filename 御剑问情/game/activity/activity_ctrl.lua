require("game/activity/activity_view")
require("game/activity/activity_detail_view")
require("game/activity/activity_data")
require("game/activity/activity_shushan_fight_view")
require("game/activity/activity_luckylog_view")

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
	self.data = ActivityData.New()
	self.lucky_log_view = LuckyLogView.New(ViewName.LuckyLogView)
	self.shushanfight = ActivityShuShanFightView.New()
	self.level_change_event = GlobalEventSystem:Bind(ObjectEventType.LEVEL_CHANGE,BindTool.Bind(self.OnLevelChange, self))
end

function ActivityCtrl:__delete()
	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.detail_view ~= nil then
		self.detail_view:DeleteMe()
		self.detail_view = nil
	end

	if self.shushanfight ~= nil then
		self.shushanfight:DeleteMe()
		self.shushanfight = nil
	end

	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.level_change_event ~= nil then
		GlobalEventSystem:UnBind(self.level_change_event)
		self.level_change_event = nil
	end

	ActivityCtrl.Instance = nil
end

function ActivityCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCActivityStatus, "OnActivityStatus")
	self:RegisterProtocol(SCHuangChengHuiZhanInfo,"OnHuangChengHuiZhanInfo")
	self:RegisterProtocol(SCCrossRandActivityStatus, "OnCrossRandActivityStatus")
	self:RegisterProtocol(SCQunxianLuandouFirstRankInfo, "OnQunxianLuandouFirstRankInfo")
	self:RegisterProtocol(SCHuangChengHuiZhanRoleInfo, "OnHuangChengHuiZhanRoleInfo")
	self:RegisterProtocol(SCLuckyLogRet, "SCLuckyLogRet")
end

-- 活动信息
function ActivityCtrl:OnActivityStatus(protocol)
	-- TestPrint(protocol)
	--print_log("##########OnActivityStatus:", protocol.activity_type, protocol.status)
	self.data:AddActivityInfo(protocol)
	if not self.data:CanShowActivity(protocol.activity_type) then
		protocol.status = ACTIVITY_STATUS.CLOSE
	end
	--判断是否是版本活动
	local content = ""
	for k,v in pairs(FESTIVAL_ACTIVITY_ID) do
		if v == protocol.activity_type then
			FestivalActivityCtrl.Instance:SetActivityStatus(protocol)
			local cfg = FestivalActivityData.Instance:GetActivityOpenCfgById(protocol.activity_type)
			if nil ~= cfg then
				if ACTIVITY_STATUS.CLOSE == protocol.status then
					content = cfg.name .. Language.Activity.HuoDongYiGuanBi
				elseif ACTIVITY_STATUS.OPEN == protocol.status then
					content = cfg.name .. Language.Activity.ActivityStart
				end
				SysMsgCtrl.Instance:RollingEffect(content, GUNDONGYOUXIAN.ACTIVITY_TYPE)
			end
		end
	end

	--线上活动
	for k,v in pairs(ONLINE_ACTIVITY_ID) do
		if v == protocol.activity_type then
			ActivityOnLineCtrl.Instance:SetActivityStatus(protocol)
			local cfg = ActivityOnLineData.Instance:GetActivityOpenCfgById(protocol.activity_type)
			if nil ~= cfg then
				if ACTIVITY_STATUS.CLOSE == protocol.status then
					content = cfg.name .. Language.Activity.HuoDongYiGuanBi
				elseif ACTIVITY_STATUS.OPEN == protocol.status then
					content = cfg.name .. Language.Activity.ActivityStart
				end
				SysMsgCtrl.Instance:RollingEffect(content, GUNDONGYOUXIAN.ACTIVITY_TYPE)
			end
		end
	end

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
			content = name .. Language.Activity.HuoDongYiGuanBi
			if CrossServerData.LAST_CROSS_TYPE == protocol.activity_type then
				CrossServerCtrl.Instance:GoBack()
			end
		elseif ACTIVITY_STATUS.STANDY == protocol.status then
			content = name .. Language.Activity.NaiXinDengDai
			SysMsgCtrl.Instance:RollingEffect(content, GUNDONGYOUXIAN.ACTIVITY_TYPE)
		elseif ACTIVITY_STATUS.OPEN == protocol.status then
			content = name .. Language.Activity.ActivityStart
			SysMsgCtrl.Instance:RollingEffect(content, GUNDONGYOUXIAN.ACTIVITY_TYPE)
			if protocol.activity_type < ACTIVITY_TYPE.OPEN_SERVER or CrossServerData.CheckIsKfType(protocol.activity_type) then
				self:OpenPopView(protocol.activity_type)
			end
		end
	end
	if "" ~= content and (protocol.activity_type < ACTIVITY_TYPE.OPEN_SERVER
	or protocol.activity_type >= ACTIVITY_TYPE.Act_Roller) then
		if self.data:CanShowActivity(protocol.activity_type) then
			ChatCtrl.Instance:AddSystemMsg(content, nil, nil, true)
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
	end
	if protocol.activity_type == DaFuHaoDataActivityId.ID and protocol.status == ACTIVITY_STATUS.OPEN then
		DaFuHaoCtrl.Instance:SendGetGatherInfoReq()
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
		-- DaFuHaoCtrl.Instance:FlushDaFuHaoView()

		if DaFuHaoData.Instance then
			DaFuHaoData.Instance:ClearInfo()
		end
	end

	RemindManager.Instance:Fire(RemindName.ShengXiao_Uplevel)
	MainUICtrl.Instance:FlushView("shen_ge_effect")

	if protocol.activity_type == ACTIVITY_TYPE.RAND_ACTIVITY_SUPER_LUCKY_STAR and protocol.status == ACTIVITY_STATUS.OPEN then
		RareDialCtrl.Instance:SendInfo()
	end
	if protocol.activity_type == ACTIVITY_TYPE.ACTIVITY_TYPE_XINGZUOYIJI
		and protocol.status == ACTIVITY_STATUS.OPEN
		and OpenFunData.Instance:CheckIsHide("shengxiao_uplevel") then

		local ok_callback = function()
			ActivityCtrl.Instance:SendActivityEnterReq(ACTIVITY_TYPE.ACTIVITY_TYPE_XINGZUOYIJI, 0)
			ViewManager.Instance:CloseAll()
		end
		--TipsCtrl.Instance:OpenFocusBossTip(nil, ok_callback, false, true)
		TipsCtrl.Instance:OpenFocusXingZuoYiJiTip(ok_callback)
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

	--婚宴剩余时间
	if protocol.activity_type == ACTIVITY_TYPE.ACTIVITY_TYPE_WEDDING and protocol.status == ACTIVITY_STATUS.OPEN then
		MarriageData.Instance:SetHunYanTime(protocol.next_status_switch_time)
	end
end

function ActivityCtrl:OnCrossRandActivityStatus(protocol)
	self.data:AddCrossActivityInfo(protocol)
	if not self.data:CanShowActivityByLevelFloor(protocol.activity_type) then
		protocol.status = ACTIVITY_STATUS.CLOSE
	end
	self.data:SetCrossRandActivityStatus(protocol.activity_type, protocol.status, protocol.begin_time, protocol.end_time)
end

function ActivityCtrl:OnQunxianLuandouFirstRankInfo(protocol)
	self.data:SetQunxianLuandouFirstRankInfo(protocol)
	self.detail_view:Flush()
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

function ActivityCtrl:SendQunxianLuandouFirstRankInfo()
    local protocol = ProtocolPool.Instance:GetProtocol(CSQunxianLuandouFirstRankReq)
    protocol:EncodeAndSend()
end

function ActivityCtrl:SendActivityLogSeq(activity_type)
	self.data:SendActivityLogType(activity_type)
    local protocol = ProtocolPool.Instance:GetProtocol(CSGetLuckyLog)
    protocol.activity_type = activity_type or 0
    protocol:EncodeAndSend()
end

function ActivityCtrl:SCLuckyLogRet(protocol)
	self.data:SetActivityLogInfo(protocol)
	ViewManager.Instance:Open(ViewName.LuckyLogView)
end

function ActivityCtrl:OnKFtowerBuff()
	local protocol = ProtocolPool.Instance:GetProtocol(CSCrossXiuluoTowerBuyBuffReq)
	protocol:EncodeAndSend()
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
		-- ViewManager.Instance:Open(ViewName.ClashTerritory)
		return
	elseif act_id == ACTIVITY_TYPE.GONGCHENGZHAN then
		ViewManager.Instance:Open(ViewName.CityCombatView)
		return
	elseif act_id == ACTIVITY_TYPE.GUILDBATTLE then
		local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
		if guild_id > 0 then
			ViewManager.Instance:Open(ViewName.Guild, TabIndex.guild_war)
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.PleaseJoinGuild)
			ViewManager.Instance:Open(ViewName.Guild, TabIndex.guild_info)
		end
		return

	elseif act_id == ACTIVITY_TYPE.ACTIVITY_TYPE_TRIPLE_GUAJI then
		ViewManager.Instance:Open(ViewName.YewaiGuajiView)
		return
	elseif act_id == ACTIVITY_TYPE.GONGCHENG_WORSHIP then
		local city_owner_info = CityCombatData.Instance:GetCityOwnerInfo()
		if city_owner_info and city_owner_info.owner_id ~= 0 then
			ViewManager.Instance:Open(ViewName.CityCombatView)
		end
		return
	elseif act_id == ACTIVITY_TYPE.WEEKBOSS then
		ViewManager.Instance:Open(ViewName.TianshenhutiView, TabIndex.tianshenhuti_bigboss)
		return
	end

	if self.data:CanShowActivity(act_id) then
		self.detail_view:SetActivityId(act_id)
		self.detail_view:Open()
		self.detail_view:Flush()
	end
end

--蜀山混战
function ActivityCtrl:OnHuangChengHuiZhanInfo(protocol)
	self.data:SetShuShanData(protocol)
	self:OpenShuShanFightView()
end


--蜀山混战
function ActivityCtrl:OnHuangChengHuiZhanRoleInfo(protocol)
	self.data:SetShuShanRoleInfo(protocol)
	self.shushanfight:Flush()
end

function ActivityCtrl:OpenShuShanFightView()
	if not self.data:IsInHuangChengAcitvity() then
		self:CloseShuShanFightView()
		return false
	end
	MainUICtrl.Instance:SetViewState(false)
	if not self.shushanfight:IsOpen() then
		self.shushanfight:Open()
		MapCtrl.Instance:FlushLocalMap()
	end
	self.shushanfight:Flush()
	return true
end

function ActivityCtrl:CloseShuShanFightView()
	if self.shushanfight:IsOpen() then
		self.shushanfight:Close()
		self.data:ClearShuShanRoleData()
		MapCtrl.Instance:FlushLocalMap()
		if Scene.Instance:GetSceneType() == 0 then
			MainUICtrl.Instance:SetViewState(true)
		end
	end
end

--皇城无法传送
function ActivityCtrl:CanNotFly()
	if ActivityData.Instance:IsInHuangChengAcitvity() then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.CannotFindPath)
		return false
	end
	return true
end

-- 玩家等级更变
function ActivityCtrl:OnLevelChange(obj, new_level, old_level)
	local activity_info_list = self.data:GetActivityInfoList()
	for k,v in pairs(activity_info_list) do
		local new_status = self.data:CanShowActivity(v.activity_type, new_level)
		local old_status = self.data:CanShowActivity(v.activity_type, old_level)
		if new_status ~= old_status then
			self:OnActivityStatus(v)
		end
	end

	local cross_activity_info_list = self.data:GetCrossActivityInfoList()
	for k,v in pairs(cross_activity_info_list) do
		local new_status = self.data:CanShowActivityByLevelFloor(v.activity_type, new_level)
		local old_status = self.data:CanShowActivityByLevelFloor(v.activity_type, old_level)
		if new_status ~= old_status then
			self:OnCrossRandActivityStatus(v)
		end
	end
end