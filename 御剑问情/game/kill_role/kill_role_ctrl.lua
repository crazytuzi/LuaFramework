require("game/kill_role/kill_role_view")

KillRoleCtrl = KillRoleCtrl or BaseClass(BaseController)

function KillRoleCtrl:__init()
	if nil ~= KillRoleCtrl.Instance then
		return
	end
	KillRoleCtrl.Instance = self

	self.view = KillRoleView.New(ViewName.KillRoleView)
end

function KillRoleCtrl:__delete()
	self.view:DeleteMe()
	self.view = nil

	KillRoleCtrl.Instance = nil
end

function KillRoleCtrl:ShowKillView(be_kill_role_vo)
	if nil == be_kill_role_vo or nil == next(be_kill_role_vo) then
		return
	end

	self.view:SetBeKillRoleVo(be_kill_role_vo)

	if self.view:IsOpen() then
		self.view:Flush()
		return
	end
	self.view:Open()
end