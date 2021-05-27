require("scripts/game/browse/browse_main_view")
require("scripts/game/browse/browse_data")

OUT_LINE_SHOW_TYPE = {
	GONG_CHENG = 1,		-- 攻城战
}

-- 查看角色信息
BrowseCtrl = BrowseCtrl or BaseClass(BaseController)

function BrowseCtrl:__init()
	if BrowseCtrl.Instance ~= nil then
		ErrorLog("[BrowseCtrl] Attemp to create a singleton twice !")
	end
	BrowseCtrl.Instance = self

	self.browse_data = BrowseData.New()
	self.browse_view = BrowseMainView.New(ViewDef.Browse)

	self:RegisterAllProtocols()
	self.request_callback_list = {}
end

function BrowseCtrl:__delete()
	self.browse_view:DeleteMe()
	self.browse_view = nil

	self.browse_data:DeleteMe()
	self.browse_data = nil

	BrowseCtrl.Instance = nil
end

function BrowseCtrl:RegisterAllProtocols()
	-- self:RegisterProtocol(SCOtherRoleEquipList, "OnOtherRoleEquipList")
	self:RegisterProtocol(SCOutlineRoleEquipList, "OnOutlineRoleEquipList")
end

-- 查看离线玩家的消息
function BrowseCtrl.SendGetOtherOneEquipInfo(role_name)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetOtherOneEquipInfo)
	protocol.role_name = role_name or ""
	protocol:EncodeAndSend()
end

function BrowseCtrl:BrowRoleInfo(role_name, role_id, callback)
	BrowseCtrl.SendGetOutLinePlayerInfo(role_name, role_id)
	if nil == callback then return end
	for k, v in pairs(self.request_callback_list) do
		if v.callback == callback then
			return
		end
	end

	table.insert(self.request_callback_list, {role_name = role_name, callback = callback,})
end


-- 查找其他玩家的信息
function BrowseCtrl:OnOtherRoleEquipList(protocol)
	self:RoleInfoReqCallBack(protocol)
	self.browse_data:SetRoleInfo(protocol.vo)
	self.browse_view:Flush()
end

-- 查找离线玩家的信息
function BrowseCtrl:RoleInfoReqCallBack(protocol)
	local count = #self.request_callback_list
	if count > 0 then
		local info = nil
		for i = count, 1, -1 do
			info = self.request_callback_list[i]
			if info.role_name == protocol.vo.name then

				info.callback(protocol)
				table.remove(self.request_callback_list, i)
			end
		end
	end
end

-- 查看离线玩家的消息
function BrowseCtrl.SendGetOutLinePlayerInfo(role_name, role_id, show_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetOutLinePlayerInfo)
	protocol.role_name = role_name or ""
	protocol.role_id = role_id or 0
	protocol.show_type = show_type or 0
	protocol:EncodeAndSend()
end

function BrowseCtrl:OnOutlineRoleEquipList(protocol)
	if not protocol or not protocol.vo then return end
	self:RoleInfoReqCallBack(protocol)
	self.browse_data:SetRoleInfo(protocol.vo)
	self.browse_view:Flush()
	if protocol.vo.show_type == OUT_LINE_SHOW_TYPE.GONG_CHENG then
		WangChengZhengBaCtrl.Instance:OnSbkRoleVo(protocol.vo)
	else
		self.browse_data:SetOutLinePlayerInfo(protocol.vo)
	end
end
