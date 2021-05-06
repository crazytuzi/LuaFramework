module(..., package.seeall)

--GS2C--

function GS2CGetRankInfo(pbdata)
	local idx = pbdata.idx --排行榜索引
	local page = pbdata.page --排行榜页数
	local first_stub = pbdata.first_stub --第一次生成的排行榜, 1表示第一次
	local key = pbdata.key --伙伴榜对应伙伴id,其他-0
	local grade_rank = pbdata.grade_rank --等级排行榜
	local warpower_rank = pbdata.warpower_rank --战力排行
	local arena_rank = pbdata.arena_rank --比武场排行
	local pata_rank = pbdata.pata_rank --爬塔排行
	local equal_rank = pbdata.equal_rank --公平比武,内容暂时和排行榜一致
	local yj_rank = pbdata.yj_rank --月见行者排行信息
	local terrawars_org_rank = pbdata.terrawars_org_rank --据点攻防战公会排行榜信息
	local terrawars_server_rank = pbdata.terrawars_server_rank --据点战全服排行榜信息
	local org_prestige_rank = pbdata.org_prestige_rank --公会声望排行
	local parpower = pbdata.parpower --伙伴排行榜
	local subtype = pbdata.subtype --0-普通榜,1-冲榜
	local consume_rank = pbdata.consume_rank --消费榜
	--todo
	if idx == define.Rank.RankId.Grade then
		g_RankCtrl:ReceiveData(idx, page, first_stub, grade_rank, subtype)
	elseif idx == define.Rank.RankId.Power then
		g_RankCtrl:ReceiveData(idx, page, first_stub, warpower_rank, subtype)
	elseif idx == define.Rank.RankId.Arena then
		g_RankCtrl:ReceiveData(idx, page, first_stub, arena_rank, subtype)
	elseif idx == define.Rank.RankId.EqualArena then
		g_RankCtrl:ReceiveData(idx, page, first_stub, equal_rank, subtype)
	elseif idx == define.Rank.RankId.Pata then
		g_RankCtrl:ReceiveData(idx, page, first_stub, pata_rank, subtype)
	elseif idx == define.Rank.RankId.RJFb then
		g_RankCtrl:ReceiveData(idx, page, first_stub, yj_rank, subtype)
	elseif idx == define.Rank.RankId.TerrawarOrg then
		g_RankCtrl:ReceiveData(idx, page, first_stub, terrawars_org_rank, subtype)
	elseif idx == define.Rank.RankId.TerrawarServer then
		g_RankCtrl:ReceiveData(idx, page, first_stub, terrawars_server_rank, subtype)
	elseif idx == define.Rank.RankId.OrgPrestige then
		g_RankCtrl:ReceiveData(idx, page, first_stub, org_prestige_rank, subtype)
	elseif idx == define.Rank.RankId.Partner then
		g_RankCtrl:ReceiveData(idx, page, first_stub, parpower, subtype)
	elseif idx == define.Rank.RankId.Consume then
		g_RankCtrl:ReceiveData(idx, page, first_stub, consume_rank, subtype)
	end
end

function GS2CMyRank(pbdata)
	local idx = pbdata.idx --排行榜索引
	local end_time = pbdata.end_time --刷新时间
	local rank_count = pbdata.rank_count --排行榜条总数
	local key = pbdata.key --伙伴榜对应伙伴id,其他-0
	local grade_rank = pbdata.grade_rank --玩家等级排名信息
	local warpower_rank = pbdata.warpower_rank --战力排行玩家信息
	local arena_rank = pbdata.arena_rank --玩家比武场排行信息
	local pata_rank = pbdata.pata_rank --爬塔排行信息
	local equal_rank = pbdata.equal_rank --玩家公平比武排行信息
	local yj_rank = pbdata.yj_rank --月见行者排行信息
	local terrawars_org_rank = pbdata.terrawars_org_rank --据点攻防战公会排行榜信息
	local terrawars_server_rank = pbdata.terrawars_server_rank
	local org_prestige_rank = pbdata.org_prestige_rank --公会声望信息
	local parpower_rank = pbdata.parpower_rank --伙伴战力
	local subtype = pbdata.subtype --0-普通榜,1-冲榜
	local consume_rank = pbdata.consume_rank --消费榜
	--todo
	if idx == define.Rank.RankId.Grade then
		g_RankCtrl:ReceiveMyRank(idx, end_time, rank_count, grade_rank, subtype)
	elseif idx == define.Rank.RankId.Power then
		g_RankCtrl:ReceiveMyRank(idx, end_time, rank_count, warpower_rank, subtype)
	elseif idx == define.Rank.RankId.Arena then
		g_RankCtrl:ReceiveMyRank(idx, end_time, rank_count, arena_rank, subtype)
	elseif idx == define.Rank.RankId.EqualArena then
		g_RankCtrl:ReceiveMyRank(idx, end_time, rank_count, equal_rank, subtype)
	elseif idx == define.Rank.RankId.Pata then
		g_RankCtrl:ReceiveMyRank(idx, end_time, rank_count, pata_rank, subtype)
	elseif idx == define.Rank.RankId.RJFb then
		g_RankCtrl:ReceiveMyRank(idx, end_time, rank_count, yj_rank, subtype)
	elseif idx == define.Rank.RankId.TerrawarOrg then
		g_RankCtrl:ReceiveMyRank(idx, end_time, rank_count, terrawars_org_rank, subtype)
	elseif idx == define.Rank.RankId.TerrawarServer then
		g_RankCtrl:ReceiveMyRank(idx, end_time, rank_count, terrawars_server_rank, subtype)
	elseif idx == define.Rank.RankId.OrgPrestige then
		g_RankCtrl:ReceiveMyRank(idx, end_time, rank_count, org_prestige_rank, subtype)
	elseif idx == define.Rank.RankId.Partner then
		g_RankCtrl:ReceiveMyRank(idx, end_time, rank_count, parpower_rank, subtype)
	elseif idx == define.Rank.RankId.Consume then
		g_RankCtrl:ReceiveMyRank(idx, end_time, rank_count, consume_rank, subtype)
	else
		g_RankCtrl:ReceiveMyRank(idx, end_time, rank_count, nil, subtype)
	end
end

function GS2CGetRankTop3(pbdata)
	local idx = pbdata.idx --排行榜索引
	local my_rank = pbdata.my_rank
	local role_info = pbdata.role_info --玩家基本信息
	--todo

end

function GS2CRankUpvoteInfo(pbdata)
	local idx = pbdata.idx --排行榜索引
	local page = pbdata.page --当前分页
	local upvote_info = pbdata.upvote_info --点赞列表信息
	--todo
	g_RankCtrl:ReceiveExtraData(idx, page, upvote_info)
end

function GS2CClearAllRankData(pbdata)
	local idx = pbdata.idx --排行榜索引
	--todo
	g_RankCtrl:OnReceiveClearAll(idx)
end

function GS2CRankPartnerInfo(pbdata)
	local idx = pbdata.idx --排行榜索引
	local parinfo = pbdata.parinfo
	--todo
	g_RankCtrl:ShowPartnerDetail(parinfo)
end

function GS2CMsattackMyInfo(pbdata)
	local info = pbdata.info
	--todo
	g_MonsterAtkCityCtrl:OnReceiveMsattackMyInfo(info)
end

function GS2CRankMsattackInfo(pbdata)
	local type = pbdata.type
	local list = pbdata.list
	--todo
	g_MonsterAtkCityCtrl:OnReceiveMsattackInfo(type, list)
end

function GS2CRankFirstInfoList(pbdata)
	local idx = pbdata.idx --排行榜索引
	local first_list = pbdata.first_list --第一列表
	--todo
end

function GS2CPartnerRank(pbdata)
	local subtype = pbdata.subtype --0-普通，1-限时
	local ranks = pbdata.ranks
	--todo
	if ranks and #ranks > 0 then
		CPartnerDetailPowerView:ShowView(function (oView)
			oView:SetData(subtype, ranks)
		end)
	else
		g_NotifyCtrl:FloatMsg("暂无上榜伙伴")
	end
end


--C2GS--

function C2GSGetRankInfo(idx, page, key, subtype)
	local t = {
		idx = idx,
		page = page,
		key = key,
		subtype = subtype,
	}
	g_NetCtrl:Send("rank", "C2GSGetRankInfo", t)
end

function C2GSGetOrgRankInfo(idx, page, orgid)
	local t = {
		idx = idx,
		page = page,
		orgid = orgid,
	}
	g_NetCtrl:Send("rank", "C2GSGetOrgRankInfo", t)
end

function C2GSGetRankTop3(idx)
	local t = {
		idx = idx,
	}
	g_NetCtrl:Send("rank", "C2GSGetRankTop3", t)
end

function C2GSMyRank(idx, key, subtype)
	local t = {
		idx = idx,
		key = key,
		subtype = subtype,
	}
	g_NetCtrl:Send("rank", "C2GSMyRank", t)
end

function C2GSMyOrgRank(idx, orgid)
	local t = {
		idx = idx,
		orgid = orgid,
	}
	g_NetCtrl:Send("rank", "C2GSMyOrgRank", t)
end

function C2GSRankUpvoteInfo(idx, page)
	local t = {
		idx = idx,
		page = page,
	}
	g_NetCtrl:Send("rank", "C2GSRankUpvoteInfo", t)
end

function C2GSOpenRankUI(idx, page, query, key, subtype)
	local t = {
		idx = idx,
		page = page,
		query = query,
		key = key,
		subtype = subtype,
	}
	g_NetCtrl:Send("rank", "C2GSOpenRankUI", t)
end

function C2GSGetRankParInfo(idx, partype, owner)
	local t = {
		idx = idx,
		partype = partype,
		owner = owner,
	}
	g_NetCtrl:Send("rank", "C2GSGetRankParInfo", t)
end

function C2GSGetRankMsattack(type, istart, iend)
	local t = {
		type = type,
		istart = istart,
		iend = iend,
	}
	g_NetCtrl:Send("rank", "C2GSGetRankMsattack", t)
end

function C2GSGetRankFirstInfo(idx)
	local t = {
		idx = idx,
	}
	g_NetCtrl:Send("rank", "C2GSGetRankFirstInfo", t)
end

function C2GSPartnerRank(subtype)
	local t = {
		subtype = subtype,
	}
	g_NetCtrl:Send("rank", "C2GSPartnerRank", t)
end

