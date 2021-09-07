require("game/kuafu_flower_rank/kuafu_flower_rank_data")
require("game/kuafu_flower_rank/kuafu_flower_rank_view")
require("game/kuafu_flower_rank/kuafu_flower_reward_view")

KuaFuFlowerRankCtrl = KuaFuFlowerRankCtrl or BaseClass(BaseController)

function KuaFuFlowerRankCtrl:__init()
	if KuaFuFlowerRankCtrl.Instance ~= nil then
		print_error("[KuaFuFlowerRankCtrl] Attemp to create a singleton twice !")
	end
	KuaFuFlowerRankCtrl.Instance = self
	self.view = KuaFuFlowerRankView.New(ViewName.KuaFuFlowerRankView)
	self.reward_view = KuaFuFlowerRewardView.New(ViewName.KuaFuFlowerRewardView)
	self.data = KuaFuFlowerRankData.New()
	self.rank_change_event = GlobalEventSystem:Bind(OtherEventType.RANK_CHANGE, BindTool.Bind(self.OnRankChange, self))

	self:RegisterAllProtocols()
end

function KuaFuFlowerRankCtrl:__delete()
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.reward_view then
		self.reward_view:DeleteMe()
		self.reward_view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.rank_change_event then
		GlobalEventSystem:UnBind(self.rank_change_event)
		self.rank_change_event = nil
	end

	KuaFuFlowerRankCtrl.Instance = nil
end

function KuaFuFlowerRankCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCCrossRARankGetRankACK, "OnCrossRARankGetRankACK")
end

function KuaFuFlowerRankCtrl:OnCrossRARankGetRankACK(protocol)
	self.data:SetCrossRARankGetRankACK(protocol)
	if self.view then
		self.view:Flush()
	end
end

function KuaFuFlowerRankCtrl:OnRankChange(rank_type)
	if rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_FLOWER_MALE or  rank_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_FLOWER_FEMALE then
		if self.view then
			self.view:Flush()
		end
	end
end