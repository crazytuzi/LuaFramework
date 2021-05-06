module(..., package.seeall)

--GS2C--

function GS2CLoginTravelPartner(pbdata)
	local travel_partner = pbdata.travel_partner --伙伴游历信息
	local pos_info = pbdata.pos_info --位置信息
	local item_info = pbdata.item_info --加成道具
	local travel_content = pbdata.travel_content --前端根据时间排序
	local mine_invite = pbdata.mine_invite --发出邀请
	--todo
	g_TravelCtrl:LoginMineTravel(travel_partner, pos_info, item_info, travel_content, mine_invite)
end

function GS2CTravelPartnerInfo(pbdata)
	local travel_partner = pbdata.travel_partner
	--todo
	g_TravelCtrl:SetMineTravelInfo(travel_partner)
end

function GS2CTravelPartnerPos(pbdata)
	local pos_info = pbdata.pos_info --上阵信息
	--todo
	g_TravelCtrl:SetMinePosInfo(pos_info)
end

function GS2CTravelItemInfo(pbdata)
	local item_info = pbdata.item_info
	--todo
	g_TravelCtrl:SetMineItemInfo(item_info)
end

function GS2CDelTravelItem(pbdata)
	--todo
	g_TravelCtrl:DelMineItemInfo()
end

function GS2CAddTravelContent(pbdata)
	local travel_content = pbdata.travel_content --游记内容
	--todo
	g_TravelCtrl:AddMineContentInfo(travel_content)
end

function GS2CClearTravelContent(pbdata)
	--todo
	g_TravelCtrl:DelMineContentInfoAll()
end

function GS2CAddTravelInvite(pbdata)
	local travel_invite = pbdata.travel_invite
	--todo
	g_TravelCtrl:AddFrd2MineInviteInfo(travel_invite)
end

function GS2CDelTravelInvite(pbdata)
	local frd_pid = pbdata.frd_pid
	--todo
	g_TravelCtrl:DelFrd2MineInviteInfo(frd_pid)
end

function GS2CClearTravelInvite(pbdata)
	--todo
	g_TravelCtrl:DelFrd2MineInviteInfoAll()
end

function GS2CFrdTravelPartnerInfo(pbdata)
	local frd_partner = pbdata.frd_partner
	--todo
	g_TravelCtrl:SetFrd2MineParInfo(frd_partner)
end

function GS2CDelFrdTravel(pbdata)
	--todo
	g_TravelCtrl:DelFrdTravel()
end

function GS2CMineTravelPartnerInfo(pbdata)
	local frd_pid = pbdata.frd_pid --寄存好友的pid
	local parinfo = pbdata.parinfo --伙伴信息
	local start_time = pbdata.start_time
	local end_time = pbdata.end_time
	local recieve_status = pbdata.recieve_status --0-正在游历,1-可领取
	local server_time = pbdata.server_time --服务器当前时间
	--todo
	g_TravelCtrl:SetMine2FrdParInfo(pbdata)
end

function GS2CDelMineTravel(pbdata)
	--todo
	g_TravelCtrl:DelMine2FrdParInfo()
end

function GS2CFrdTravelList(pbdata)
	local travel_partner = pbdata.travel_partner --伙伴游历信息
	local pos_partner = pbdata.pos_partner --位置信息
	local item_info = pbdata.item_info --加成道具
	local frd_pid = pbdata.frd_pid --好友pid
	local frd_partner = pbdata.frd_partner --好友寄存的伙伴和4没什么关系
	--todo
	g_TravelCtrl:OpenTravelFriendPosPage(pbdata)
end

function GS2CRefreshMineInvite(pbdata)
	local mine_invites = pbdata.mine_invites
	--todo
	g_TravelCtrl:SetMine2FrdInviteInfo(mine_invites)
end

function GS2CInviteInfoList(pbdata)
	local invites = pbdata.invites --邀请信息列表
	--todo
	local pbdata = table.copy(pbdata)
	local invites = pbdata.invites
	g_TravelCtrl:SetFrd2MineInviteInfo(invites)
end

function GS2CUpdateTravelPartner(pbdata)
	local parinfo = pbdata.parinfo --1~4普通伙伴，5-寄存于好友，6-好友寄存于我
	--todo
	g_TravelCtrl:UpdateTravelPartner(parinfo)
end

function GS2CRefreshTravelCardGrid(pbdata)
	local card_grids = pbdata.card_grids
	--todo
	g_TravelCtrl:RefreshShowCardGrid(card_grids)
end

function GS2CTravelShowCardInfo(pbdata)
	local show_card = pbdata.show_card
	--todo
	g_TravelCtrl:SetShowCardInfo(show_card)
end

function GS2CRemoveTravelGame(pbdata)
	--todo
	g_TravelCtrl:RemoveTravelGameInfo()
end

function GS2CTravelGameResult(pbdata)
	local result = pbdata.result --true-成功,false-失败
	--todo
	g_TravelCtrl:SetTravelGameResult(result)
end

function GS2CFirstOpenTraderUI(pbdata)
	local is_first = pbdata.is_first --true-未打开过,false-已打开
	--todo
	g_TravelCtrl:FirstOpenTraderUI(is_first)
end


--C2GS--

function C2GSSetPartnerTravelPos(pos_info)
	local t = {
		pos_info = pos_info,
	}
	g_NetCtrl:Send("travel", "C2GSSetPartnerTravelPos", t)
end

function C2GSSetFrdPartnerTravel(parid, frd_pid)
	local t = {
		parid = parid,
		frd_pid = frd_pid,
	}
	g_NetCtrl:Send("travel", "C2GSSetFrdPartnerTravel", t)
end

function C2GSAcceptTravelRwd()
	local t = {
	}
	g_NetCtrl:Send("travel", "C2GSAcceptTravelRwd", t)
end

function C2GSAcceptFrdTravelRwd()
	local t = {
	}
	g_NetCtrl:Send("travel", "C2GSAcceptFrdTravelRwd", t)
end

function C2GSGetFrdTravelInfo(frd_pid)
	local t = {
		frd_pid = frd_pid,
	}
	g_NetCtrl:Send("travel", "C2GSGetFrdTravelInfo", t)
end

function C2GSInviteTravel(frd_pids)
	local t = {
		frd_pids = frd_pids,
	}
	g_NetCtrl:Send("travel", "C2GSInviteTravel", t)
end

function C2GSCancelSpeedTravel()
	local t = {
	}
	g_NetCtrl:Send("travel", "C2GSCancelSpeedTravel", t)
end

function C2GSStartTravel(travel_type)
	local t = {
		travel_type = travel_type,
	}
	g_NetCtrl:Send("travel", "C2GSStartTravel", t)
end

function C2GSStopTravel()
	local t = {
	}
	g_NetCtrl:Send("travel", "C2GSStopTravel", t)
end

function C2GSClearTravelInvite()
	local t = {
	}
	g_NetCtrl:Send("travel", "C2GSClearTravelInvite", t)
end

function C2GSDelTravelInvite(frd_pid)
	local t = {
		frd_pid = frd_pid,
	}
	g_NetCtrl:Send("travel", "C2GSDelTravelInvite", t)
end

function C2GSQueryTravelInvite()
	local t = {
	}
	g_NetCtrl:Send("travel", "C2GSQueryTravelInvite", t)
end

function C2GSStartTravelCard()
	local t = {
	}
	g_NetCtrl:Send("travel", "C2GSStartTravelCard", t)
end

function C2GSStopTravelCard()
	local t = {
	}
	g_NetCtrl:Send("travel", "C2GSStopTravelCard", t)
end

function C2GSShowTravelCard(pos)
	local t = {
		pos = pos,
	}
	g_NetCtrl:Send("travel", "C2GSShowTravelCard", t)
end

function C2GSFirstOpenTraderUI()
	local t = {
	}
	g_NetCtrl:Send("travel", "C2GSFirstOpenTraderUI", t)
end

