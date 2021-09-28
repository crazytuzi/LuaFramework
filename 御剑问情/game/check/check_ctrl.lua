require("game/check/check_data")
require("game/check/check_view")
CheckCtrl = CheckCtrl or BaseClass(BaseController)

function CheckCtrl:__init()
	if CheckCtrl.Instance then
		print_error("[CheckCtrl] Attemp to create a singleton twice !")
	end
	CheckCtrl.Instance = self

	self.data = CheckData.New()
	self.view = CheckView.New(ViewName.CheckEquip)
	self:RegisterAllProtocols()

	self.info_call_back_list = {}
end

function CheckCtrl:__delete()
	self.view:DeleteMe()
	self.view = nil

	self.data:DeleteMe()
	self.data = nil

	CheckCtrl.Instance = nil
end

function CheckCtrl:GetCheckView()
	return self.view
end

function CheckCtrl:SetCurIndex(tab_index, is_set_jump)
	if nil ~= self.view then
		self.view:SetCurIndex(tab_index, is_set_jump)
	end
end

function CheckCtrl:GetCheckData()
	return self.data
end

function CheckCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCGetRoleBaseInfoAck, "OnGetRoleBaseInfoAck")
	self:RegisterProtocol(SCAllCharmChange, "OnAllCharmChange")
end

-- 角色信息返回
function CheckCtrl:OnGetRoleBaseInfoAck(protocol)
	if self.data:GetCurrentUserId() == protocol.role_id then
		self.data:SetCurrentUserId(-1)
		self.data:RoleInfoChange(protocol)
		if self.view:IsLoaded() then
			self.view:InitListView()
			self.view:ListJumpToIndex()
			self.view:Flush()
		end
	end
	GlobalEventSystem:Fire(OtherEventType.RoleInfo, protocol.role_id, protocol)
	-- 开服活动战场争霸人物信息
	KaifuActivityCtrl.Instance:SetBattleRoleInfo(protocol.role_id, protocol)

	-- 查询信息回调
	if nil ~= self.info_call_back_list[tonumber(protocol.role_id)] then
		self.info_call_back_list[protocol.role_id](protocol.role_id)
		self.info_call_back_list[protocol.role_id] = nil
	end
end

-- 魅力值改变
function CheckCtrl:OnAllCharmChange(protocol)
	self.data:SetAllCharm(protocol.all_charm)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if vo.role_id == protocol.uid then
		PlayerData.Instance:SetAttr("all_charm", protocol.all_charm)
		PlayerData.Instance:SetAttr("day_charm", protocol.day_charm)
	end
end

-- 给赞
function CheckCtrl:SendEvaluateRoleReq(target_uid)
	local protocol = ProtocolPool.Instance:GetProtocol(CSEvaluateRole)
	protocol.uid = target_uid
	protocol.rank_type = 0
	protocol:EncodeAndSend()
end

function CheckCtrl:SetInfoCallBack(target_uid, call_back)
	self.info_call_back_list = {}
	self.info_call_back_list[tonumber(target_uid)] = call_back
end

-- 请求角色信息
function CheckCtrl:SendQueryRoleInfoReq(target_uid)
	local protocol = ProtocolPool.Instance:GetProtocol(CSQueryRoleInfo)
	protocol.target_uid = target_uid
	protocol:EncodeAndSend()
end

-- 请求跨服角色信息
function CheckCtrl:SendCrossQueryRoleInfo(plat_type, target_uid)
	print("请求跨服角色信息===", plat_type, target_uid)
	local protocol = ProtocolPool.Instance:GetProtocol(CSCrossQueryRoleInfo)
	protocol.plat_type = plat_type
	protocol.target_uid = target_uid
	protocol:EncodeAndSend()
end
