local CTravelCtrl = class("CTravelCtrl", CCtrlBase)

define.Travel = {
	Event = {
		Base = 1,			--游历基本信息
		MinePos = 2,		--游历位置
		MineItem = 3,		--游历道具
		MineContent = 4,	--游历内容
		MineInvite = 5,		--游历好友邀请
		Mine2Frd = 6,		--寄存好友的伙伴
		Frd2Mine = 7,		--好友寄存的伙伴
		CardInfo = 8,		--翻牌基本信息
		CardGrid = 9, 		--翻牌格子信息
		TravelGame = 10,    --奇遇商人
		TravelGameRedDot = 11,    --奇遇商人红点
	},
	Type = {
		Mine = 1,
		Friend = 2,
	}
}

function CTravelCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self:ResetCtrl()
end

function CTravelCtrl.ResetCtrl(self)
	self.m_MineTravelInfo =  {}  	    --伙伴游历信息
	self.m_MinePosInfo = {}				--位置信息
	self.m_MineItemInfo = {}			--加成道具
	self.m_MineContentInfo = {}			--游历内容
	self.m_Frd2MineInviteInfo = {}		--好友邀请我信息
	self.m_Mine2FrdInviteInfo = {}      --我邀请好友信息
	self.m_MineGameInfo = nil        	--是否有奇遇商人
	self.m_Mine2FrdParInfo = nil		--自己寄存好友
	self.m_Frd2MineParInfo = nil			--好友寄存自己
	g_MainMenuCtrl:ShowMenuRBSwitchTips(false, "travelgame")
	self.m_DefaultSelectTraveShopSid = nil
end

function CTravelCtrl.LoginMineTravel(self, travel_partner, pos_info, item_info, travel_content, mine_invites)
	self:SetMineTravelInfo(travel_partner)
	self:SetMinePosInfo(pos_info)
	self:SetMineItemInfo(item_info)
	self:SetMineContentInfo(travel_content)
	self:SetMine2FrdInviteInfo(mine_invites)
end

function CTravelCtrl.SetMineTravelInfo(self, travel_partner)
	self.m_MineTravelInfo =  travel_partner
	if self:IsVibrate() then
		--手机震动
		C_api.Utils.Vibrate()
	end
	self:OnEvent(define.Travel.Event.Base)
end

function CTravelCtrl.GetMineTravelInfo(self, travel_partner)
	return self.m_MineTravelInfo
end

function CTravelCtrl.SetMinePosInfo(self, pos_info)
	self.m_MinePosInfo = pos_info
	self:OnEvent(define.Travel.Event.MinePos)
end

function CTravelCtrl.GetMinePosInfo(self, pos_info)
	return self.m_MinePosInfo 
end

function CTravelCtrl.GetPartnerByPos(self, iPos)
	local pos_info = self:GetMinePosInfo()
	for k,v in pairs(pos_info) do
		if v.pos == iPos then
			return g_PartnerCtrl:GetPartner(v.parid)
		end
	end
end

function CTravelCtrl.GetParinfoByPos(self, iPos)
	local pos_info = self:GetMinePosInfo()
	for k,v in pairs(pos_info) do
		if v.pos == iPos then
			return v
		end
	end
end

function CTravelCtrl.SetMineItemInfo(self, item_info)
	self.m_MineItemInfo = item_info
	self:OnEvent(define.Travel.Event.MineItem)
end

function CTravelCtrl.DelMineItemInfo(self)
	self.m_MineItemInfo = nil
	self:OnEvent(define.Travel.Event.MineItem)
end

function CTravelCtrl.GetMineItemInfo(self, item_info)
	return self.m_MineItemInfo
end

function CTravelCtrl.SetMineContentInfo(self, travel_content)
	self.m_MineContentInfo = travel_content
	self:OnEvent(define.Travel.Event.MineContent)
end

function CTravelCtrl.AddMineContentInfo(self, travel_content)
	if not self.m_MineContentInfo then
		self.m_MineContentInfo = {}
	end
	for i,content in ipairs(travel_content) do
		table.insert(self.m_MineContentInfo, content)
	end
	self:OnEvent(define.Travel.Event.MineContent)
end

function CTravelCtrl.DelMineContentInfoAll(self)
	self.m_MineContentInfo = nil
	self:OnEvent(define.Travel.Event.MineContent)
end

function CTravelCtrl.GetMineContentInfo(self, travel_content)
	return self.m_MineContentInfo
end

function CTravelCtrl.SetFrd2MineInviteInfo(self, travel_invite)
	self.m_Frd2MineInviteInfo = travel_invite
	self:OnEvent(define.Travel.Event.MineInvite)
end

function CTravelCtrl.AddFrd2MineInviteInfo(self, travel_invite)
	if not self.m_Frd2MineInviteInfo then
		self.m_Frd2MineInviteInfo = {}
	end
	local isFind = false
	for i,v in ipairs(self.m_Frd2MineInviteInfo) do
		if v.frd_pid == travel_invite.frd_pid then
			isFind = true
			break
		end
	end
	if not isFind then
		table.insert(self.m_Frd2MineInviteInfo, travel_invite)
	end
	IOTools.SetClientData("travelmineinvite", true)
	self:OnEvent(define.Travel.Event.MineInvite)
end

function CTravelCtrl.DelFrd2MineInviteInfo(self, frd_pid)
	if self.m_Frd2MineInviteInfo then
		for i=#self.m_Frd2MineInviteInfo, 1, -1 do
			if self.m_Frd2MineInviteInfo[i].frd_pid == frd_pid then
				table.remove(self.m_Frd2MineInviteInfo, i)
			end
		end
	end
	self:OnEvent(define.Travel.Event.MineInvite)
end

function CTravelCtrl.DelFrd2MineInviteInfoAll(self)
	self.m_Frd2MineInviteInfo = nil
	IOTools.SetClientData("travelmineinvite", false)
	self:OnEvent(define.Travel.Event.MineInvite)
end

function CTravelCtrl.GetFrd2MineInviteInfo(self)
	return self.m_Frd2MineInviteInfo
end

function CTravelCtrl.SetFrd2MineParInfo(self, frd_partner)
	self.m_Frd2MineParInfo = frd_partner
	self:OnEvent(define.Travel.Event.Frd2Mine)
end

function CTravelCtrl.DelFrdTravel(self)
	self.m_Frd2MineParInfo = nil
	self:OnEvent(define.Travel.Event.Frd2Mine)
end

function CTravelCtrl.GetFrd2MineParInfo(self)
	return self.m_Frd2MineParInfo
end

function CTravelCtrl.GetFrd2MineParinfo(self)
	return self.m_Frd2MineParInfo and self.m_Frd2MineParInfo.parinfo
end

function CTravelCtrl.SetMine2FrdParInfo(self, pbdata)
	self.m_Mine2FrdParInfo = pbdata
	self:OnEvent(define.Travel.Event.Mine2Frd)
end

function CTravelCtrl.DelMine2FrdParInfo(self)
	self.m_Mine2FrdParInfo = nil
	self:OnEvent(define.Travel.Event.Mine2Frd)
end

function CTravelCtrl.GetMine2FrdParInfo(self)
	return self.m_Mine2FrdParInfo
end

function CTravelCtrl.GetMine2FrdParinfo(self)
	return self.m_Mine2FrdParInfo and self.m_Mine2FrdParInfo.parinfo
end

function CTravelCtrl.SetMine2FrdInviteInfo(self, mine_invites)
	self.m_Mine2FrdInviteInfo = mine_invites
end

function CTravelCtrl.GetMine2FrdInviteInfo(self)
	return self.m_Mine2FrdInviteInfo
end

function CTravelCtrl.IsMainTraveling(self)
	local travel_partner = self:GetMineTravelInfo()
	return travel_partner and travel_partner.status == 1
end

function CTravelCtrl.HasTravelReward(self)
	local travel_partner = self:GetMineTravelInfo()
	return travel_partner and travel_partner.reward == 1
end

function CTravelCtrl.HasMainInvite(self)
	local travel_invite = self:GetFrd2MineInviteInfo()
	return travel_invite and #travel_invite > 0
end

-----------------------------好友游历部分-------------------------------------
function CTravelCtrl.OpenTravelFriendPosPage(self, pbdata)
	self.m_FrdTravelInfo = pbdata
	local oView = CTravelView:GetView()
	if oView then
		oView:RefreshAll(define.Travel.Type.Friend)
	end
end

function CTravelCtrl.GetFrdTravelInfo(self)
	return self.m_FrdTravelInfo
end

function CTravelCtrl.GetFrdTravelItem(self)
	local dData = g_TravelCtrl:GetFrdTravelInfo()
	return dData and dData.item_info
end

function CTravelCtrl.GetFrdTravelPos(self, iPos)
	local dData = g_TravelCtrl:GetFrdTravelInfo()
	local pos_partner = dData.pos_partner
	if pos_partner then
		for k,v in pairs(pos_partner) do
			if v.pos == iPos then
				return v
			end
		end
	end
end

function CTravelCtrl.GetFrdPid(self)
	local dData = g_TravelCtrl:GetFrdTravelInfo()
	return dData.frd_pid
end

function CTravelCtrl.GetFrdName(self)
	local pid = self:GetFrdPid()
	local name = "好友"
	if pid then
		local frdobj = g_FriendCtrl:GetFriend(pid)
		name = frdobj and frdobj.name
	end
	return name
end

function CTravelCtrl.CloseTravelFriendPosPage(self)
	self.m_FrdTravelInfo = nil
end

-----------------------------好友游历部分-------------------------------------

function CTravelCtrl.UpdateTravelPartner(self, parinfo)
	if parinfo.pos <= 4 then
		local pos_info = self:GetMinePosInfo()
		for k,v in pairs(pos_info) do
			if v.pos == parinfo.pos then
				v = parinfo
				self:OnEvent(define.Travel.Event.MinePos)
				return
			end
		end
	elseif parinfo == 5 then
		if self.m_Mine2FrdParInfo and self.m_Mine2FrdParInfo.parinfo then
			self.m_Mine2FrdParInfo.parinfo = parinfo
			self:OnEvent(define.Travel.Event.Mine2Frd)
		end
	elseif parinfo == 6 then
		if self.m_Frd2MineParInfo and self.m_Frd2MineParInfo.parinfo then
			self.m_Frd2MineParInfo.parinfo = parinfo
			self:OnEvent(define.Travel.Event.Frd2Mine)
		end
	end
end

-----------------------------奇遇玩法：翻牌开始--------------------------------------

function CTravelCtrl.SetShowCardGrid(self, card_grids)
	if not card_grids or #card_grids == 0 then
		card_grids = {} --客户端自己补足16个格子
		for i=1,16 do
			card_grids[i] = {
				pos = i,
				shape = 301,
				status = 0,
			}
		end
	end
	self.m_CardGrid = card_grids
	self:OnEvent(define.Travel.Event.CardGrid)
end

function CTravelCtrl.RefreshShowCardGrid(self, card_grids)
	local oldCardGrid = self:GetShowCardGrid()
	if oldCardGrid and #card_grids > 0 then
		for i,new in ipairs(card_grids) do
			for j,old in ipairs(oldCardGrid) do
				if new.pos == old.pos then
					oldCardGrid[j] = new
				end
			end
		end
		self:SetShowCardGrid(oldCardGrid)
	else
		self:SetShowCardGrid(card_grids)
	end
end

function CTravelCtrl.GetShowCardGrid(self)
	return self.m_CardGrid
end

function CTravelCtrl.SetShowCardInfo(self, show_card)
	self.m_CardInfo = show_card
	self:SetTravelGameInfo(true)
	self:OnEvent(define.Travel.Event.CardInfo)
end

function CTravelCtrl.GetShowCardInfo(self)
	return self.m_CardInfo
end

function CTravelCtrl.RemoveTravelGameInfo(self)
	self:SetTravelGameInfo(false)
end

function CTravelCtrl.SetTravelGameInfo(self, b)
	self.m_MineGameInfo = b
	self:OnEvent(define.Travel.Event.TravelGame)
end

function CTravelCtrl.GetTravelGameInfo(self)
	return self.m_MineGameInfo
end

function CTravelCtrl.OpenTravelExchangeView(self, shop_id, goodslist, refresh_time, refresh_cost, refresh_coin_type, refresh_count, refresh_rule)
	local defaultSelectSid = self.m_DefaultSelectTraveShopSid
	CTravelExchangeView:ShowView(function (oView)
		oView:RefreshView(goodslist, defaultSelectSid)
	end)
	self.m_DefaultSelectTraveShopSid = nil
end

function CTravelCtrl.SetTravelGameResult(self, bResult)
	local oView = CTravelGameView:GetView()
	if oView then
		oView:SetTravelGameResult(bResult)
	end
end

function CTravelCtrl.HasRedDot(self)
	if g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.travel.open_grade then
		return (self:HasTravelReward() and not self:IsMainTraveling()) 
			or self:NotTravel() 
			or IOTools.GetClientData("travelmineinvite") == true
			or IOTools.GetClientData("travelgame") == true
	else
		return false
	end
end

function CTravelCtrl.IsVibrate(self)
	return self:HasTravelReward() and not self:IsMainTraveling()
end

function CTravelCtrl.NotTravel(self)
	local travel_partner = self:GetMineTravelInfo()
	travel_partner = table.copy(travel_partner)
	return (not travel_partner or travel_partner.status == nil) and not self:HasTravelReward()
end

function CTravelCtrl.FirstOpenTraderUI(self, is_first)
	if is_first then
		g_MainMenuCtrl:ShowMenuRBSwitchTips(true, "travelgame", "游历触发奇遇商人")
		self:SetTravelGameRedDot(true)
		local oView = CTravelGameView:GetView()
		if oView then
			--通知服务器打开游历界面
			nettravel.C2GSFirstOpenTraderUI()
		end
	else
		g_MainMenuCtrl:ShowMenuRBSwitchTips(false, "travelgame")
	end
end

function CTravelCtrl.SetTravelGameRedDot(self, b)
	IOTools.SetClientData("travelgame", b)
	self:DelayEvent(define.Travel.Event.TravelGameRedDot)
end

-----------------------------奇遇玩法：翻牌结束--------------------------------------
return CTravelCtrl