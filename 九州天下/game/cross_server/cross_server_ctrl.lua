require("game/cross_server/cross_server_data")

IS_ON_CROSSSERVER = false     				-- 是否在跨服中

CrossServerCtrl = CrossServerCtrl or BaseClass(BaseController)
function CrossServerCtrl:__init()
	if CrossServerCtrl.Instance then
		error("[CrossServerCtrl]:Attempt to create singleton twice!")
	end
	CrossServerCtrl.Instance = self

	self.data = CrossServerData.New()
	self:RegisterAllProtocals()
end

function CrossServerCtrl:__delete()
	self.data:DeleteMe()
	self.data = nil

	CrossServerCtrl.Instance = nil
end

function CrossServerCtrl:RegisterAllProtocals()
	self:RegisterProtocol(SCCrossEnterServer, "OnCrossEnterServer")
	self:RegisterProtocol(SCReturnOriginalServer, "OnReturnOriginalServer")
	self:RegisterProtocol(CSCrossCommonOperaReq)
end

-- 通知客户端进入隐藏服
function CrossServerCtrl:OnCrossEnterServer(protocol)
	--记录进入跨服的唯一id
	-- CrossServerData.Instance:SetRoleUUId(protocol.uuid)

	print("OnCrossEnterServer",protocol.login_server_ip, protocol.login_server_port)
	self.data:SetCrossInfo(protocol)
	self.data:SetDisconnectGameServer()

	UserVo.Instance.old_plat_id = UserVo.Instance.plat_server_id
	UserVo.Instance.old_plat_name = UserVo.Instance.plat_name
	UserVo.Instance.plat_server_id = protocol.server
	UserVo.Instance.plat_name = protocol.pname

	GameNet.Instance:ResetCrossServer()
	GameNet.Instance:DisconnectGameServer()
	GameNet.Instance:SetCrossServerInfo(protocol.login_server_ip, protocol.login_server_port)
	GameNet.Instance:AsyncConnectCrossServer(5)

	ViewManager.Instance:CloseAll()
end

-- 通知返回原服
function CrossServerCtrl:OnReturnOriginalServer(protocol)
	print_log("通知返回原服")
	self:GoBack()

	-- 下面干嘛延迟10秒？不懂。
	-- GlobalTimerQuest:AddDelayTimer(function() self:GoBack() end, 10)
end

-- 请求开始跨服
function CrossServerCtrl:SendCrossStartReq(cross_activity_type, param)
	if IS_ON_CROSSSERVER then return end
	local have_team = ScoietyData.Instance:GetTeamState()
	if have_team then
		ScoietyCtrl.Instance:ExitTeamReq()
	end

	CampData.Instance:KeepCampInfoNotice()

	local main_role = Scene.Instance:GetMainRole()
	GlobalEventSystem:Fire(ObjectEventType.STOP_GATHER, main_role:GetObjId())
	CrossServerData.LAST_CROSS_TYPE = cross_activity_type
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSCrossStartReq)
	send_protocol.cross_activity_type = cross_activity_type
	send_protocol.param = param or 0
	send_protocol:EncodeAndSend()
	ChatCtrl.Instance:SetCrossServerFlag(true)
end

-- 返回原服
function CrossServerCtrl:GoBack()
	if not IS_ON_CROSSSERVER then return end
	self.data:SetIsGoBack(true)
	UserVo.Instance.plat_server_id = UserVo.Instance.old_plat_id
	UserVo.Instance.plat_name = UserVo.Instance.old_plat_name
	LoginCtrl.SendUserLogout()
	self.data:SetDisconnectGameServer()
	GameNet.Instance:DisconnectGameServer()
	GameNet.Instance:AsyncConnectLoginServer(5)
	ChatCtrl.Instance:SetCrossServerFlag(true)
end

-- 跨服信息
function CrossServerCtrl:SendCSCrossCommonOperaReq(req_type, param_1, param_2, param_3)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSCrossCommonOperaReq)
	send_protocol.req_type = req_type or 0
	send_protocol.param_1 = param_1 or 0
	send_protocol.param_2 = param_2 or 0
	send_protocol.param_3 = param_3 or 0
	send_protocol:EncodeAndSend()
end

