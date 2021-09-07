require("agent/agent_adapter_base")

AgentAdapter = AgentAdapter or BaseClass(AgentAdapterBase)

function AgentAdapter:__init()
	if AgentAdapter.Instance ~= nil then
		print_error("[AgentAdapter] attempt to create singleton twice!")
		return
	end
	AgentAdapter.Instance = self
end

function AgentAdapter:__delete()
	AgentAdapter.Instance = nil
end
