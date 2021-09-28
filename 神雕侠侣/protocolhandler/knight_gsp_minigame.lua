
knight_gsp_minigame = {}

function knight_gsp_minigame.SRspMoneyTree_Lua_Process(p)
	print("SRefreshMoneyTree handler enter")
	require "ui.yaoqianshudlg"
	local proto = KnightClient.toSRspMoneyTree(p)
		
	YaoQianShuDlg.HandleSRspMoneyTree(proto.cd_time, proto.unpayremaintimes, proto.payremaintimes, proto.yuanbao)
	return false
end

return knight_gsp_minigame
