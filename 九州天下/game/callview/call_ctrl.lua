require("game/callview/call_data")
require("game/callview/call_view")

CallCtrl = CallCtrl or BaseClass(BaseController)

function CallCtrl:__init()
	if CallCtrl.Instance then
		print_error("[CallCtrl] Attemp to create a singleton twice !")
	end
	CallCtrl.Instance = self
	self.view = CallView.New(ViewName.CallView)
	self.data = CallData.New()
	self:RegisterAllProtocols()
end

function CallCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCTeamTransferInfo,"OnTeamCallReqSucc")
	self:RegisterProtocol(SCFamilyCallTransferInfo,"OnFamilyCallReqSucc")
	self:RegisterProtocol(SCCampCall, "OnCampCall")
	self:RegisterProtocol(SCMusterFlyAck, "OnTransferSucc")
	self:RegisterProtocol(SCCrossCall, "OnSCCrossCall")
	self:RegisterProtocol(CSCrossCallStartCross)

	--国家发送协议已注册
	self:RegisterProtocol(CSFamilyCallReq)
	self:RegisterProtocol(CSTeamCallReq)
	self:RegisterProtocol(CSMusterFlyReq)
end

function CallCtrl:__delete()
	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end

	CallCtrl.Instance = nil
end

--国家、家族、组队召集请求
function CallCtrl:SendCallReq(button_index,cost_type)
	if button_index == 1 then
		self:SendCampCommonOpera(CAMP_OPERA_TYPE.OPERA_TYPE_NEIZHENG_CALL, cost_type)
	else
		self:SendCallManReq(button_index)
	end
end

--家族召集请求成功
function CallCtrl:OnFamilyCallReqSucc(protocol)
	if protocol ~= nil then
		self.data:SetCampCall(protocol,2)
		--抱美人、运镖、在副本不显示
		if not self:CheckCanCall() then
			return 
		end
		if SettingData.Instance:GetSettingData(SETTING_TYPE.AUTO_ACCPECT_FAMILY_CALL) then
			MainUICtrl.Instance:DoTransfer(2)
		else
			MainUICtrl.Instance:SetTransferBtnVIsible(2)
		end
	end
end

--组队召集成功
function CallCtrl:OnTeamCallReqSucc(protocol)
	if protocol ~= nil then
		self.data:SetCampCall(protocol,3)
		--抱美人、运镖、在副本不显示
		if not self:CheckCanCall() then
			return 
		end
		if SettingData.Instance:GetSettingData(SETTING_TYPE.AUTO_ACCPECT_TEAM_CALL) then
			MainUICtrl.Instance:DoTransfer(3)
		else
			MainUICtrl.Instance:SetTransferBtnVIsible(3)
		end
	end		
end

-- 国家召集成功
function CallCtrl:OnCampCall(protocol)
	if protocol ~= nil then
		self.data:SetCampCall(protocol,1)
		--抱美人、运镖、在副本不显示
		if not self:CheckCanCall() then
			return 
		end
		if SettingData.Instance:GetSettingData(SETTING_TYPE.AUTO_ACCPECT_COUNTRY_CALL) then
			MainUICtrl.Instance:DoTransfer(1)
		else		
			MainUICtrl.Instance:SetTransferBtnVIsible(1)
		end
	end
end

function CallCtrl:CheckCanCall()
	local can_call = true
	local hold_beauty_npcid = PlayerData.Instance.role_vo.hold_beauty_npcid or 0
	if hold_beauty_npcid > 0 or YunbiaoData.Instance:GetIsHuShong() or Scene.Instance:GetSceneType() ~= SceneType.Common then
		can_call = false
	end
	return can_call
end

function CallCtrl:OnSCCrossCall(protocol)
	local data = protocol.call_info
	data.uid = protocol.call_info.origin_server_role_id
	data.call_info = TableCopy(protocol.call_info)
	self.data:SetCampCall(data,  3 - protocol.call_info.call_type)

	local setting_type = nil
	local view_type = nil
	if data.call_type == CALL_TYPE.CALL_TYPE_INVALID then
		setting_type = SETTING_TYPE.AUTO_ACCPECT_TEAM_CALL
		view_type = 3
	elseif data.call_type == CALL_TYPE.CALL_TYPE_GUILD then
		setting_type = SETTING_TYPE.AUTO_ACCPECT_FAMILY_CALL
		view_type = 2
	elseif data.call_type == CALL_TYPE.CALL_TYPE_CAMP then	
		setting_type = SETTING_TYPE.AUTO_ACCPECT_COUNTRY_CALL
		view_type = 1
	end

	if setting_type and view_type then
		if SettingData.Instance:GetSettingData(setting_type) then
			MainUICtrl.Instance:DoTransfer(view_type)
		else
			MainUICtrl.Instance:SetTransferBtnVIsible(view_type)
		end		
	end

	local enter_midao_func = function()
		self:SendCrossCallStartCross(protocol.call_info)
	end

	local cfg = LianFuDailyData.Instance:GetCrossXYJDCfg()
	local moveto_judian_func = function(x, y)
		self:SendCrossCallStartCross(protocol.call_info)	
		MoveCache.scene_id = cfg.other[1].scene_id
		MoveCache.x = x
		MoveCache.y = y
		GuajiCtrl.Instance:MoveToScenePos(cfg.other[1].scene_id, x, y)
	end

	if data.call_type == CALL_TYPE.CALL_TYPE_XYJD_DEFFENDER or data.call_type == CALL_TYPE.CALL_TYPE_XYJD_ATTACKER then 	-- 咸阳据点占领发通知
		local vo = GameVoManager.Instance:GetMainRoleVo()
		local server_group = vo.server_group or 0
		local group = 0
		if data.call_type == CALL_TYPE.CALL_TYPE_XYJD_DEFFENDER then
			group = server_group + 1
		elseif data.call_type == CALL_TYPE.CALL_TYPE_XYJD_ATTACKER then
			group = server_group == 1 and 1 or 2
		end
		local center_pos = Split(cfg.other[1]["group" .. group .. "_flag_monster_born_pos"], ",")
		local cfg = LianFuDailyData.Instance:GetJuDianIdCfg(data.param)
		TipsCtrl.Instance:ShowCommonTip(BindTool.Bind(moveto_judian_func, center_pos[1], center_pos[2]), nil, string.format(Language.Convene.CallFromDesc[data.call_type], center_pos[1], center_pos[2]))
	elseif data.call_type == CALL_TYPE.CALL_TYPE_XYCITY_MIDAO_DEFENDER then 		-- 密道开启通知防御方
		local vo = GameVoManager.Instance:GetMainRoleVo()
		local enemy_group = server_group == 0 and 1 or 0
		TipsCtrl.Instance:ShowCommonTip(enter_midao_func, nil, string.format(Language.Convene.CallFromDesc[data.call_type], Language.Convene.ServerGroup[enemy_group]))
	elseif data.call_type == CALL_TYPE.CALL_TYPE_XYCITY_MIDAO_ATTACKER then 	-- 密道开启通知进攻方
		TipsCtrl.Instance:ShowCommonTip(enter_midao_func, nil, string.format(Language.Convene.CallFromDesc[data.call_type], data.name))
	elseif data.call_type == CALL_TYPE.CALL_TYPE_XYJD_PRGRESS_HALF then 		-- 据点占领一半发通知
		local vo = GameVoManager.Instance:GetMainRoleVo()
		local cfg = LianFuDailyData.Instance:GetJuDianIdCfg(data.param)
		if cfg.group ~= server_group and cfg.level == 3 then
			local center_pos = Split(cfg.center_pos, ",")
			TipsCtrl.Instance:ShowCommonTip(BindTool.Bind(moveto_judian_func, center_pos[1], center_pos[2]), nil, string.format(Language.Convene.CallFromDesc[data.call_type], cfg.name, center_pos[1], center_pos[2]))
		end
	end
end

function CallCtrl:SendCallManReq(protocol_type)
	local send_protocol = nil
	if protocol_type == 2 then
		send_protocol = ProtocolPool.Instance:GetProtocol(CSFamilyCallReq)
	elseif protocol_type == 3 then
		send_protocol = ProtocolPool.Instance:GetProtocol(CSTeamCallReq)
	else
		return
	end
	send_protocol:EncodeAndSend()
end

-- 通用请求
function CallCtrl:SendCampCommonOpera(order_type, param1, param2, param3, param4_name, param5)
	local protocol_send = ProtocolPool.Instance:GetProtocol(CSCampCommonOpera)
	protocol_send.order_type = order_type or 0
	protocol_send.param1 = param1 or 0
	protocol_send.param2 = param2 or 0
	protocol_send.param3 = param3 or 0
	protocol_send.param4_name = param4_name or ""
	protocol_send.param5 = param5 or 0
	protocol_send:EncodeAndSend()
end

function CallCtrl:OnTransferSucc(protocol)
	if protocol then
		if protocol.is_success ~= 0 then
			MainUICtrl.Instance:OnResetPosCallBack()
		end
	end
end

-- 飞行到某地
function CallCtrl:TransferByCall(scene_id, pos_x, pos_y, scene_key, is_force)
	if not BossData.Instance:CheckIsCanEnterFuLi(scene_id) then
		SysMsgCtrl.Instance:ErrorRemind(Language.FuBen.NeedLeaveScene)
		return
	end

	local protocol = ProtocolPool.Instance:GetProtocol(CSMusterFlyReq)
	protocol.scene_id = scene_id
	protocol.scene_key = scene_key or -1
	protocol.pos_x = pos_x
	protocol.pos_y = pos_y
	protocol.is_force = is_force and 1 or 0		--无视条件直接传送
	protocol:EncodeAndSend()
end

-- 通用请求
function CallCtrl:SendCrossCallStartCross(call_info)
	local protocol_send = ProtocolPool.Instance:GetProtocol(CSCrossCallStartCross)
	protocol_send.call_type = call_info.call_type or 0
	protocol_send.origin_server_role_id = call_info.origin_server_role_id or 0
	protocol_send.name = call_info.name or 0
	protocol_send.post = call_info.post or 0
	protocol_send.camp = call_info.camp or 0
	protocol_send.guild_id = call_info.guild_id or 0
	protocol_send.activity_type = call_info.activity_type or 0
	protocol_send.scene_id = call_info.scene_id or 0
	protocol_send.scene_key = call_info.scene_key or 0
	protocol_send.x = call_info.x or 0
	protocol_send.y = call_info.y or 0
	protocol_send.param = call_info.param or 0
	protocol_send:EncodeAndSend()
end