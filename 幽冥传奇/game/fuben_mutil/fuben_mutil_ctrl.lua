require("scripts/game/fuben_mutil/fuben_mutil_view")
require("scripts/game/fuben_mutil/menber_list_alert")
require("scripts/game/fuben_mutil/fuben_mutil_data")
require("scripts/game/fuben_mutil/fuben_team_data")
require("scripts/game/fuben_mutil/fuben_active_alert")

FubenMutilCtrl = FubenMutilCtrl or BaseClass(BaseController)

function FubenMutilCtrl:__init()
	if FubenMutilCtrl.Instance then
		ErrorLog("[FubenMutilCtrl]:Attempt to create singleton twice!")
	end
	FubenMutilCtrl.Instance = self
	
	self.total_find_num = 0
	self.curr_find_num = 1
	self.view = FubenMutilView.New(ViewDef.FubenMulti)
	self.data = FubenMutilData.New()
    self.team_data = FubenTeamData.New()
	
	self:RegisterAllProtocols()
	self:BindGlobalEvent(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.RecvMainInfoCallBack, self))
end

function FubenMutilCtrl:__delete()
	FubenMutilCtrl.Instance = nil
	
	self.view:DeleteMe()
	self.view = nil
	
	self.data:DeleteMe()
	self.data = nil

    self.team_data:DeleteMe()
    self.team_data = nil
	
	if self.menber_list_alert then
		self.menber_list_alert:DeleteMe()
		self.menber_list_alert = nil
	end
	
	if self.exit_alert then
		self.exit_alert:DeleteMe()
		self.exit_alert = nil
	end

    if self.active_alert then
        self.active_alert:DeleteMe()
        self.active_alert = nil
    end
	
end
function FubenMutilCtrl:RecvMainInfoCallBack()
	if GameCondMgr.Instance:GetValue("CondId102") then
		FubenMutilCtrl.SendGetFubenEnterTimes(FubenMutilType.Team)
	end
end

function FubenMutilCtrl:OpenMenListAlert(fuben_type, fuben_id, fuben_layer, team_id, open_type)
	self.menber_list_alert = self.menber_list_alert or MenberListAlert.New()
	self.menber_list_alert:SetTeamInfo(fuben_type, fuben_id, fuben_layer, team_id)
	self.menber_list_alert:SetOpenType(open_type)
	self.menber_list_alert:Open()
	self.menber_list_alert:Flush()
end

function FubenMutilCtrl:CloseMenListAlert()
	if self.menber_list_alert and self.menber_list_alert:IsOpen() then
		self.menber_list_alert:Close()
	end
end

function FubenMutilCtrl:OpenFubenActiveAlert(cur_kill_num, max_kill_num, secs)
    self.active_alert = self.active_alert or FubenActiveAlert.New()
	if not self.active_alert:IsOpen() then
		self.active_alert:SetProgress(cur_kill_num, max_kill_num)
		self.active_alert:SetCutdownSecs(secs)
		self.active_alert:Open()
		self.active_alert:Flush()
	end
end

function FubenMutilCtrl:CloseActivedAlert()
	if self.active_alert and self.active_alert:IsOpen() then
		self.active_alert:Close()
	end
end

function FubenMutilCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCEnterFubenTimes,    "OnEnterFubenTimes")
    self:RegisterProtocol(SCFubenMutilTeamInfo, "OnFubenMutilTeamInfo")
    self:RegisterProtocol(SCTeamDetailInfo,	    "OnTeamDetailInfo")
    self:RegisterProtocol(SCMenberDecrease,	    "OnMenberDecrease")
    self:RegisterProtocol(SCMenberDecInFuben,   "OnMenberDecInFuben") 
    self:RegisterProtocol(SCTeamDissolve,		"OnTeamDissolve")
    self:RegisterProtocol(SCMenberIncrease,	    "OnMenberIncrease")
    self:RegisterProtocol(SCTeamLeaderChanged,  "OnTeamLeaderChanged") 
    self:RegisterProtocol(SCTeamStateChanged,   "OnTeamStateChanged") 
    self:RegisterProtocol(SCTeamCreated,		"OnTeamCreated")
    self:RegisterProtocol(SCPreEnterFuben,	    "OnPreEnterFuben")
    self:RegisterProtocol(SCMonsterKilledCount, "OnMonsterKilledCount") 
    self:RegisterProtocol(SCFirstFloorResult,   "OnFirstFloorResult")
end

function FubenMutilCtrl.SendOpenFubenMutilView(is_open)
	local protocol = ProtocolPool.Instance:GetProtocol(CSOpenFubenMutilView)
	protocol.is_open = is_open
	protocol:EncodeAndSend()
end

function FubenMutilCtrl.SendInvateFuben(fuben_type, msg_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSInvateFuben)
	protocol.fuben_type = fuben_type
	protocol.msg_id = msg_id
	protocol:EncodeAndSend()
end

-- 请求进入副本次数
function FubenMutilCtrl.SendGetFubenEnterTimes(fuben_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetFubenEnterTimes)
	protocol.fuben_type = fuben_type
	protocol:EncodeAndSend()
end

function FubenMutilCtrl:OnFubenMutilUsedTimes(protocol)
	-- self.data:SetFubenUsedTimes(protocol.fuben_used_times_info)
	-- self.view:Flush(0, "left_times")
end

function FubenMutilCtrl:OnEnterFubenTimes(protocol)
	self.data:SetFubenUsedTimes(protocol.fuben_type, protocol.enter_times)
end

-- 请求所有队伍信息
function FubenMutilCtrl.SendGetFubenTeamInfo(fuben_type, fuben_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetTeamInfo)
	protocol.fuben_type = fuben_type
	protocol.fuben_id = fuben_id
	protocol:EncodeAndSend()
end

function FubenMutilCtrl:OnFubenMutilTeamInfo(protocol)
	self.team_data:SetTeamInfos(protocol.fuben_type, protocol.team_info)
end

-- 请求创建队伍
function FubenMutilCtrl.SendCreateTeam(fuben_type, fuben_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSCreateTeam)
	protocol.fuben_type = fuben_type
	protocol.fuben_id = fuben_id
	protocol:EncodeAndSend()
end

-- 请求某个队伍详细信息
function FubenMutilCtrl.SendGetTeamDetailInfo(fuben_type, fuben_id, team_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetTeamDetailInfo)
	protocol.fuben_type = fuben_type
	protocol.fuben_id = fuben_id
	protocol.team_id = team_id
	protocol:EncodeAndSend()
end

function FubenMutilCtrl:OnTeamDetailInfo(protocol)
	self.team_data:SetTeamDetailInfo(protocol.fuben_type, protocol.fuben_id, protocol.fuben_layer, protocol.team_id, protocol.menber_info_list)
end

-- 加入队伍
function FubenMutilCtrl.SendJoinTeamRequest(fuben_type, fuben_id, team_id, fuben_layer)
	local protocol = ProtocolPool.Instance:GetProtocol(CSJoinTeamRequest)
	protocol.fuben_type = fuben_type
	protocol.fuben_id = fuben_id
	protocol.team_id = team_id
	protocol.fuben_layer = fuben_layer
	protocol:EncodeAndSend()
end

-- 退出队伍
function FubenMutilCtrl.SendExitTeamRequest(fuben_type, fuben_id, team_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSExitTeamRequest)
	protocol.team_id = team_id
	protocol.fuben_type = fuben_type
	protocol.fuben_id = fuben_id
	protocol:EncodeAndSend()
end


-- 踢出队伍
function FubenMutilCtrl.SendOutMenberRequest(fuben_type, fuben_id, menber_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSOutMenberRequest)
	protocol.menber_id = menber_id
	protocol.fuben_type = fuben_type
	protocol.fuben_id = fuben_id
	protocol:EncodeAndSend()
end

-- 解散队伍
function FubenMutilCtrl.SendDissolveTeam(fuben_type, fuben_id, team_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSDissolveTeam)
	protocol.team_id = team_id
	protocol.fuben_type = fuben_type
	protocol.fuben_id = fuben_id
	protocol:EncodeAndSend()
	
end

-- 队伍成员减少
function FubenMutilCtrl:OnMenberDecrease(protocol)
	-- local in_my_team = self.team_data:IsInMyTeam(protocol.fuben_type, protocol.fuben_id, protocol.fuben_layer, protocol.menber_id)
	-- local menber_info = self.team_data:GetMenberById(protocol.fuben_type, protocol.fuben_id, protocol.menber_id)
	self.team_data:DeleteMenber(protocol.fuben_type, protocol.fuben_id, protocol.fuben_layer, protocol.menber_id)
end

function FubenMutilCtrl:OnMenberDecInFuben(protocol)
	self.team_data:DeleteMenber(protocol.fuben_type, protocol.fuben_id, protocol.fuben_layer, protocol.menber_id)

	if protocol.fuben_type == FubenMutilType.Hhjd then
    	FubenCtrl.Instance:SetTaskFollow()
    	ViewManager.Instance:FlushView(ViewName.HhjdTeam)
    end
end

-- 队伍成员增加
function FubenMutilCtrl:OnMenberIncrease(protocol)
	local info = DeepCopy(protocol.info)
	info.is_leader = 0
	self.team_data:AddMenber(protocol.fuben_type, protocol.fuben_id, protocol.fuben_layer, protocol.team_id, info)
end

-- 队伍解散
function FubenMutilCtrl:OnTeamDissolve(protocol)
	self.team_data:DissolveTeam(protocol.fuben_type, protocol.fuben_id, protocol.fuben_layer, protocol.team_id)
end

-- 创建了队伍
function FubenMutilCtrl:OnTeamCreated(protocol)
	self.team_data:AddTeamInfo(protocol.fuben_type, protocol.fuben_id, protocol.fuben_layer, {
		team_id	= protocol.team_id,
		menber_count = protocol.menber_count,
		max_men_count = protocol.max_men_count,
		leader_name = protocol.leader_name,
		state = protocol.fuben_type == FubenMutilType.Hhjd and 0 or 1,
	})
end

-- 队伍变更
function FubenMutilCtrl:OnTeamLeaderChanged(protocol)
	self.team_data:ChangeLeader(protocol.fuben_type, protocol.fuben_id, protocol.fuben_layer, protocol.team_id, protocol.menber_id)
end

-- 队伍状态变更
function FubenMutilCtrl:OnTeamStateChanged(protocol)
	local scene_id = Scene.Instance:GetSceneId()
	if MenberListAlert.OpenType.ENTER_FUBEN == protocol.state
	and self.team_data:IsContainMe(protocol.fuben_type, fuben_id, protocol.fuben_layer, protocol.team_id) then 
			local awards = FubenMutilData.GetFubenShowAwards(FubenMutilType.Team, FubenMutilLayer[scene_id])
            local bossNum = FubenMutilData.GetNeedKilledNum(FubenMutilType.Team, FubenMutilLayer[scene_id])
            local time = FubenMutilData.GetTurnsRefreshTimes(FubenMutilType.Team, FubenMutilLayer[scene_id])
			TipCtrl.Instance:ShowFubenTip(awards, bossNum, 1, time)
	end
	self.team_data:ChangeTeamState(protocol.fuben_type, protocol.fuben_layer, protocol.team_id, protocol.state)
end


-- 准备进入副本
function FubenMutilCtrl.SendPreEnterFuben(fuben_type, fuben_id, team_id, fuben_layer)
	local protocol = ProtocolPool.Instance:GetProtocol(CSPreEnterFuben)
	protocol.fuben_type = fuben_type
	protocol.fuben_id = fuben_id
	protocol.team_id = team_id
	protocol.fuben_layer = fuben_layer
	protocol:EncodeAndSend()
end

function FubenMutilCtrl:OnPreEnterFuben(protocol)
	local fuben_type = protocol.fuben_type
	local fuben_id = protocol.fuben_id
	local fuben_layer = protocol.fuben_layer
	local team_id = protocol.team_id
	local menber_id = protocol.menber_id
	local is_ready = protocol.is_ready
	self.team_data:ChangeReadyState(fuben_type, fuben_id, fuben_layer, team_id, menber_id, is_ready)

    if fuben_type == FubenMutilType.Team then
        if self.team_data:IsContainMe(fuben_type, fuben_id, fuben_layer, team_id) then
            -- if self.menber_list_alert and self.menber_list_alert:IsOpen() and self.menber_list_alert:GetOpenType() == MenberListAlert.OpenType.ENTER_FUBEN then
            --     self.menber_list_alert:Flush(0, "ready", {enable = (menber_id ~= RoleData.Instance:GetAttr(OBJ_ATTR.ENTITY_ID))})
            -- else
                self:OpenMenListAlert(fuben_type, fuben_id, fuben_layer, team_id, MenberListAlert.OpenType.ENTER_FUBEN)
            -- end
        end
    end
end

-- 进入副本
function FubenMutilCtrl.SendEnterFuben(fuben_type, fuben_layer)
	local protocol = ProtocolPool.Instance:GetProtocol(CSEnterFuben)
	protocol.fuben_type = fuben_type
	protocol.fuben_layer = fuben_layer
	protocol:EncodeAndSend()
end


-- boss击杀个数
function FubenMutilCtrl:OnMonsterKilledCount(protocol)
	self.data:SetCurKilledNum(protocol.killed_count)
	GlobalEventSystem:Fire(OtherEventType.FIRST_FLOOR_KILL_COUNT, protocol.killed_count)
end

-- 第一层结果
function FubenMutilCtrl:OnFirstFloorResult(protocol)
    GlobalEventSystem:Fire(OtherEventType.FIRST_FLOOR_RESULT, protocol.result)
end

-- 退出副本
function FubenMutilCtrl.SendExitFubenRequest(fuben_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSExitFubenReq)
	protocol.fuben_id = fuben_id
	protocol:EncodeAndSend()
end

-- 领取奖励，进入下一层
function FubenMutilCtrl.SendGetFubenAwardReq(fuben_type, current_layer, next_layer)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetFubenAward)
	protocol.fuben_type = fuben_type
	protocol.current_layer = current_layer
	protocol.next_layer = next_layer or 0
	protocol:EncodeAndSend()
end
