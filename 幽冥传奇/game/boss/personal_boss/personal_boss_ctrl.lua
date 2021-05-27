require("scripts/game/boss/personal_boss/personal_boss_data")

PersonalBossCtrl = PersonalBossCtrl or BaseClass(BaseController)

function PersonalBossCtrl:__init()
	if	PersonalBossCtrl.Instance then
		ErrorLog("[PersonalBossCtrl]:Attempt to create singleton twice!")
	end
    PersonalBossCtrl.Instance = self
    
	self.data = PersonalBossData.New()
	self:RegisterAllProtocols()
end

function PersonalBossCtrl:__delete()
    PersonalBossCtrl.Instance = nil
end

function PersonalBossCtrl:RegisterAllProtocols()
	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.RecvMainRoleInfo, self))
end

function PersonalBossCtrl:RecvMainRoleInfo()
	self.data:SetListenerEvent()
end