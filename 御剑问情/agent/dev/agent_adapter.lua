require("agent/agent_adapter_base")
require("agent/dev/agent_view")

AgentAdapter = AgentAdapter or BaseClass(AgentAdapterBase)

function AgentAdapter:__init()
	if AgentAdapter.Instance ~= nil then
		print_error("[AgentAdapter] attempt to create singleton twice!")
		return
	end
	AgentAdapter.Instance = self

	self.view = AgentView.New(ViewName.Agent)
end

function AgentAdapter:__delete()
	AgentAdapter.Instance = nil

	if self.view ~= nil then
		self.view:DeleteMe()
	end
end

function AgentAdapter:ShowLogin(callback)
	self.view:SetClickLoginCallback(function(account_name)
		local uservo = GameVoManager.Instance:GetUserVo()
		uservo.plat_name = account_name
		GameRoot.Instance:SetBuglyUserID(account_name)

		callback(true)
	end)

	ViewManager.Instance:Open(ViewName.Agent)
end
