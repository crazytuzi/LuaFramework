require("scripts/game/rankinglist/rankinglist_data")
require("scripts/game/rankinglist/rankinglist_view")
RankingListCtrl = RankingListCtrl or BaseClass(BaseController)
function RankingListCtrl:__init()
	if	RankingListCtrl.Instance then
		ErrorLog("[RankingListCtrl]:Attempt to create singleton twice!")
	end
	RankingListCtrl.Instance = self
	
	self.data = RankingListData.New()
	self.view = RankingListView.New(ViewDef.RankingList)

	ViewManager.Instance:RegisterView(self.view, ViewDef.RankingList.FightingCapacity)
	ViewManager.Instance:RegisterView(self.view, ViewDef.RankingList.Rank)
	ViewManager.Instance:RegisterView(self.view, ViewDef.RankingList.GodWing)
	ViewManager.Instance:RegisterView(self.view, ViewDef.RankingList.Trial)
	ViewManager.Instance:RegisterView(self.view, ViewDef.RankingList.Prestige)

	self.rank_req_time_t = {}
	
	self:RegisterAllProtocals()
end

function RankingListCtrl:__delete()
	self.view:DeleteMe()
	self.view = nil
	
	self.data:DeleteMe()
	self.data = nil
	
	RankingListCtrl.Instance = nil
end

function RankingListCtrl:RegisterAllProtocals()
	self:RegisterProtocol(SCReturnMyRankinglistData, "OnReturnMyRankinglistData")
	self:RegisterProtocol(SCReturnRankinglistData, "OnReturnRankingListData")
end

-- 接收我的排行榜数据 返回(26, 71)
function RankingListCtrl:OnReturnMyRankinglistData(protocol)
	self.data:SetMyData(protocol)
	self.view:Flush()
end

-- 接收排行榜数据 请救(26, 72)
function RankingListCtrl:OnReturnRankingListData(protocol)
	self.data:SetRankingList(protocol)
	self.view:Flush()
end

function RankingListCtrl:SendRankingListReq(rankinglist_type)
	if nil ~= self.rank_req_time_t[rankinglist_type] and Status.NowTime - self.rank_req_time_t[rankinglist_type] < 5 then
		return
	end
	self:SendRankingListDataReq(rankinglist_type)
end

--请求排行榜数据 返回(26, 82)
function RankingListCtrl:SendRankingListDataReq(rankinglist_type) --类型从0开始
	self.rank_req_time_t[rankinglist_type] = Status.NowTime
	local protocol = ProtocolPool.Instance:GetProtocol(CSRankingListDataReq)
	protocol.rankinglist_type = rankinglist_type
	protocol:EncodeAndSend()
end

--请求我的排行榜数据 返回(26, 81)
function RankingListCtrl:SendMyRankingListDataReq(rankinglist_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSMyselfRankingListDataReq)
	protocol.rankinglist_type = rankinglist_type
	protocol:EncodeAndSend()
end
