require("game/serveractivity/raretreasure/rare_treasure_data")
require("game/serveractivity/raretreasure/rare_treasure_view")
require("game/serveractivity/raretreasure/rare_treasure_reward_view")
require("game/serveractivity/raretreasure/rare_treasure_select_view")

RareTreasureCtrl = RareTreasureCtrl or BaseClass(BaseController)

function RareTreasureCtrl:__init()
	if RareTreasureCtrl.Instance then
		print_error("[RareTreasureCtrl]:Attempt to create singleton twice!")
	end
	RareTreasureCtrl.Instance = self

	self:RegisterAllProtocols()

	self.data = RareTreasureData.New()
	self.view = RareTreasureView.New(ViewName.RareTreasureView)
	self.select_view = RareTreasureSelectView.New()
	self.reward_view = RareTreasureRewardView.New()
	RemindManager.Instance:Register(RemindName.RareTreasure, BindTool.Bind(self.CheckRareTreasureRed, self))
end

function RareTreasureCtrl:__delete()
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	RemindManager.Instance:UnRegister(RemindName.RareTreasure)
	RareTreasureCtrl.Instance = nil
end

function RareTreasureCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCCrossRAZhenYanMiBaoInfo, "OnSCCrossRAZhenYanMiBaoInfo")
	self:RegisterProtocol(SCCrossRAZhenYanMiBaoLotteryInfo, "SCCrossRAZhenYanMiBaoLotteryInfo")
end

function RareTreasureCtrl:OpenSelectView(select_seq)
	local pool_seq = self.view:GetSelectIndex()
	self.select_view:SetSelectSeq(select_seq)
	self.select_view:SetRewardPoolSeq(pool_seq)
	self.select_view:Open()
end

function RareTreasureCtrl:OpenRewardView()
	self.reward_view:Open()
end

function RareTreasureCtrl:OnSCCrossRAZhenYanMiBaoInfo(protocol)
	self.data:SetSCCrossRAZhenYanMiBaoInfo(protocol)
	self.view:Flush()
	self.select_view:Flush()
	RemindManager.Instance:Fire(RemindName.RareTreasure)
end

function RareTreasureCtrl:SCCrossRAZhenYanMiBaoLotteryInfo(protocol)
	self.data:SetPoolRewardWoedInfo(protocol)
	-- 不是0的时候表示开奖
	if protocol.is_open ~= 0 then
		self:OpenRewardView()
	end
	self.view:Flush("flush_btn")
end

function RareTreasureCtrl:CheckRareTreasureRed()
	local num = 0
	local charge_num = self.data:GetTotleChongZhi()
	local pool_config = self.data:GetAllConfig()
	for k,v in pairs(pool_config) do
		local true_wrod = self.data:GetTrueWordBySeq(v.pool_seq)
		local select_word = self.data:GetMyWordBySeq(v.pool_seq)
		if true_wrod == -1 and charge_num >= v.unlock_cost and select_word == -1 then
			num = 1
			break
		end
	end
	return num
end