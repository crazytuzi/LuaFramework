require("scripts/game/role/level/level_data")

LevelCtrl = LevelCtrl or BaseClass(BaseController)

function LevelCtrl:__init()
	if LevelCtrl.Instance then
		ErrorLog("[LevelCtrl] attempt to create singleton twice!")
		return
	end
	LevelCtrl.Instance = self

	self.data = LevelData.New()

	self:RegisterAllProtocols()
	self:BindGlobalEvent(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind1(self.OnRecvMainRoleInfo))
end

function LevelCtrl:__delete()
	LevelCtrl.Instance = nil
	
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end
end

function LevelCtrl:RegisterAllProtocols()

end

function LevelCtrl:OnRecvMainRoleInfo()

end

