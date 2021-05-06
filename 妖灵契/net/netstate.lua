module(..., package.seeall)

--GS2C--

function GS2CLoginState(pbdata)
	local state_info = pbdata.state_info
	--todo
	g_StateCtrl:InitState(state_info)
end

function GS2CAddState(pbdata)
	local state_info = pbdata.state_info
	--todo
	g_StateCtrl:AddState(state_info)
end

function GS2CRemoveState(pbdata)
	local state_id = pbdata.state_id
	--todo
	g_StateCtrl:RemoveState(state_id)
end

function GS2CRefreshState(pbdata)
	local state_info = pbdata.state_info
	--todo
	g_StateCtrl:RefreshState(state_info)
end


--C2GS--

function C2GSClickState(state_id)
	local t = {
		state_id = state_id,
	}
	g_NetCtrl:Send("state", "C2GSClickState", t)
end

