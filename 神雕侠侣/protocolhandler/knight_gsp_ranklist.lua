knight_gsp_ranklist = {}

function knight_gsp_ranklist.SRequestRankList_Lua_Process(p)
	require "protocoldef.rpcgen.knight.gsp.ranklist.ranktype"
	require "ui.rank.rankinglist" 
	LogInfo("srequestranklist lua process")
	local typeEnum = RankType:new()
	local proto = KnightClient.toSRequestRankList(p)
	if ((proto.ranktype >= typeEnum.SINGLE_COPY_RANK1) and (proto.ranktype <= typeEnum.SINGLE_COPY_RANK4)) or ((proto.ranktype >= typeEnum.TEAM_COPY_RANK1) and (proto.ranktype <= typeEnum.TEAM_COPY_RANK2)) then
		return true
	end
	
	if proto.ranktype == typeEnum.YZDD_RANK then
		local YiZhanDaoDiListDlg = require "ui.yizhandaodi.yizhandaodilist"
		YiZhanDaoDiListDlg.getInstanceAndShow():Refresh(proto.list, proto.myrank)
	else
		RankingList.processList(proto.ranktype, proto.myrank, proto.list, proto.page, proto.hasmore, proto.mytitle, proto.takeawardflag)
	end

	return false 
end

return knight_gsp_ranklist
