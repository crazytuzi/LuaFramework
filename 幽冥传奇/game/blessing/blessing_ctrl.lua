require("scripts/game/blessing/blessing_data")
require("scripts/game/blessing/blessing_view")
require("scripts/game/blessing/share_list_view")

BlessingCtrl = BlessingCtrl or BaseClass(BaseController)

function BlessingCtrl:__init()
	if	BlessingCtrl.Instance then
		ErrorLog("[BlessingCtrl]:Attempt to create singleton twice!")
	end
    BlessingCtrl.Instance = self
    
	self.data = BlessingData.New()
	self.view = BlessingView.New(ViewDef.BlessingView)
	self.share_view = SharelistView.New()
	self:RegisterAllProtocols()
end

function BlessingCtrl:__delete()
    BlessingCtrl.Instance = nil

    if self.share_alert then
		self.share_alert:DeleteMe()
		self.share_alert = nil
	end
end

function BlessingCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCIssuePrayData, "OnIssuePrayData")
	self:RegisterProtocol(SCFortuneData, "OnFortuneData")
	self:RegisterProtocol(SCFortuneShareData, "OnShareData")
	
	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.RecvMainRoleInfo, self))

	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.CanBlessing)

	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleDataChangeCallback, self))
end

function BlessingCtrl:RecvMainRoleInfo()
	
end

function BlessingCtrl:RoleDataChangeCallback(vo)
	local key = vo.key
	if key == OBJ_ATTR.ACTOR_GOLD then
		RemindManager.Instance:DoRemind(RemindName.CanBlessing)
	end
end

-- 祈福请求
function BlessingCtrl:SendBlessData(index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSJLAndFLSReq)
	protocol.msg_id = index
	protocol:EncodeAndSend()
end

-- 运势请求
function BlessingCtrl:SendFortune(type, role_id, index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSFortuneReq)
	protocol.fortune_type = type
	if type == 2 then
		protocol.role_id = role_id
	elseif type == 3 then
		protocol.fx_index = index
	end
	protocol:EncodeAndSend()
end

-- 祈福次数下发
function BlessingCtrl:OnIssuePrayData(protocol)
	self.data:SetMakeVowData(protocol)

	RemindManager.Instance:DoRemind(RemindName.CanBlessing)
end

-- 运势下发
function BlessingCtrl:OnFortuneData(protocol)
	-- if protocol.sc_type == 0 then
		self.data:SetFortuneData(protocol)
	-- elseif protocol.sc_type == 1 then
	
	-- end
end

function BlessingCtrl:OnShareData(protocol)
	self.data:SetShareData(protocol)
	local tip = 10
	MainuiCtrl.Instance:InvateTip(tip, 1, function(icon)
		icon:RemoveIconEffect()
		self.share_view:Open()
	end)
end

function BlessingCtrl:GetRemindNum(remind_name)
	if remind_name == RemindName.CanBlessing then
		return self.data:RemindBlessing()
	end
	
end