require("game/festivalactivity/festival_activity_bianshen/festival_activity_bianshen_data")
require("game/festivalactivity/festival_activity_bianshen/festival_activity_bianshen_rank")
require("game/festivalactivity/festival_activity_bianshen/festival_activity_beibianshen_rank")

FestivalActivityBianShenCtrl = FestivalActivityBianShenCtrl or BaseClass(BaseController)
function FestivalActivityBianShenCtrl:__init()
	if nil ~= FestivalActivityBianShenCtrl.Instance then
		return
	end

	FestivalActivityBianShenCtrl.Instance = self

	self.data = FestivalActivityBianShenData.New()
	-- self.bianshen_view = BianShenRank.New(ViewName.BianShenRank)
	-- self.beibianshen_view = BeiBianShenRank.New(ViewName.BeiBianShenRank)

	self:RegisterAllProtocols()
end

function FestivalActivityBianShenCtrl:__delete()
	FestivalActivityBianShenCtrl.Instance = nil

	-- if self.bianshen_view then
	-- 	self.bianshen_view:DeleteMe()
	-- end

	-- if self.beibianshen_view then
	-- 	self.beibianshen_view:DeleteMe()
	-- end

	if self.data then
		self.data:DeleteMe()
	end

end

function FestivalActivityBianShenCtrl:RegisterAllProtocols()
	-- 变身排行榜
	self:RegisterProtocol(SCRASpecialAppearanceInfo, "OnRASpecialAppearanceInfo")
	-- 被动变身榜
	self:RegisterProtocol(SCRASpecialAppearancePassiveInfo, "OnRASpecialAppearancePassiveInfo")
end

-------------------------------变身榜/被变身榜协议---------------------------
function FestivalActivityBianShenCtrl:SendBianShenSeq()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_BIANSHENBANG, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
end

function FestivalActivityBianShenCtrl:SendBeiBianShenSeq()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_BEIBIANSHENBANG, RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
end
function FestivalActivityBianShenCtrl:OnRASpecialAppearanceInfo(protocol)
	self.data:SetSpecialAppearanceInfo(protocol)
	FestivalActivityCtrl.Instance:FlushView("bianshen")
end

function FestivalActivityBianShenCtrl:OnRASpecialAppearancePassiveInfo(protocol)
	self.data:SetSpecialAppearancePassiveInfo(protocol)
	FestivalActivityCtrl.Instance:FlushView("beibianshen")
end