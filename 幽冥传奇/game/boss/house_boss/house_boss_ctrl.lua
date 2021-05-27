require("scripts/game/boss/house_boss/house_boss_data")

HouseBossCtrl = HouseBossCtrl or BaseClass(BaseController)

function HouseBossCtrl:__init()
	if	HouseBossCtrl.Instance then
		ErrorLog("[HouseBossCtrl]:Attempt to create singleton twice!")
	end
    HouseBossCtrl.Instance = self
    
	self.data = HouseBossData.New()
	self:RegisterAllProtocols()
end

function HouseBossCtrl:__delete()
    HouseBossCtrl.Instance = nil
end

function HouseBossCtrl:RegisterAllProtocols()
	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.RecvMainRoleInfo, self))
end

function HouseBossCtrl:RecvMainRoleInfo()
	self.data:SetListenerEvent()
end