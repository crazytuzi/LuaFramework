require("game/festivalactivity/festival_activity_qiqiu/festival_activity_qiqiu_data")
FestivalActivityQiQiuCtrl = FestivalActivityQiQiuCtrl or BaseClass(BaseController)
function FestivalActivityQiQiuCtrl:__init()
	if nil ~= FestivalActivityQiQiuCtrl.Instance then
		return
	end

	FestivalActivityQiQiuCtrl.Instance = self

	self.data = FestivalActivityQiQiuData.New()

	self:RegisterAllProtocols()
end

function FestivalActivityQiQiuCtrl:__delete()
	FestivalActivityQiQiuCtrl.Instance = nil

	if self.data then
		self.data:DeleteMe()
	end
end

function FestivalActivityQiQiuCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCPlantingTreeRankInfo, "OnSCPlantingTreeRankInfo")
	self:RegisterProtocol(SCPlantingTreeTreeInfo, "OnSCPlantingTreeTreeInfo")
	self:RegisterProtocol(SCPlantingTreeMiniMapInfo, "OnSCPlantingTreeMiniMapInfo")
end

function FestivalActivityQiQiuCtrl:OnSCPlantingTreeRankInfo(protocol)
	self.data:SetPlantingTreeRankInfo(protocol)
	if RA_PLANTING_TREE_RANK_TYPE.PERSON_RANK_TYPE_PLANTING_TREE_PLANTING == protocol.rank_type then
		FestivalActivityCtrl.Instance:FlushView("chuiqiqiu")
	elseif RA_PLANTING_TREE_RANK_TYPE.PERSON_RANK_TYPE_PLANTING_TREE_WATERING == protocol.rank_type then
		FestivalActivityCtrl.Instance:FlushView("fangfeiqiqiu")
	end
end

function FestivalActivityQiQiuCtrl:OnSCPlantingTreeTreeInfo(protocol)
	self.data:SetPlantingTreeInfo(protocol)
end

function FestivalActivityQiQiuCtrl:OnSCPlantingTreeMiniMapInfo(protocol)
	self.data:SetPlantingTreeMiniMapInfo(protocol)
end

function FestivalActivityQiQiuCtrl:SendActivitySeq(opera_type, param_1, param_2, param_3)
    local protocol = ProtocolPool.Instance:GetProtocol(CSRandActivityOperaReq)
    protocol.rand_activity_type = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_PRINT_TREE or 0
    protocol.opera_type = opera_type or 0
    protocol.param_1 = param_1 or 0
    protocol.param_2 = param_2 or 0
    protocol:EncodeAndSend()
end

