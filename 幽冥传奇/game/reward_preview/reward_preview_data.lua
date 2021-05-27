--------------------------------------------------------
-- 物品预览数据
--------------------------------------------------------
RewardPreviewData = RewardPreviewData or BaseClass()

----------end----------

function RewardPreviewData:__init()
	if RewardPreviewData.Instance then
		ErrorLog("[RewardPreviewData]:Attempt to create singleton twice!")
	end
	RewardPreviewData.Instance = self

	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

	self.index = 1 -- 物品预览索引
end

function RewardPreviewData:__delete()
	RewardPreviewData.Instance = nil
end

----------设置----------

-- 设置物品预览显示索引
function RewardPreviewData:SetPreviewIndex(index)
	self.index = index
end

-- 获取奖励预览列表
function RewardPreviewData.GetPreViewList(act_id)
	local cfg = {}
	local act_cfg = StdActivityCfg[act_id]
	if act_id == DAILY_ACTIVITY_TYPE.ZHEN_YING then
		cfg = BLZConfig.zyzReward or {}
	elseif act_id == DAILY_ACTIVITY_TYPE.HANG_HUI_BOSS then
		local awards = act_cfg.Awards
		cfg[#cfg + 1] = awards.bigAward.mgrAward
		cfg[#cfg + 1] = awards.bigAward.memberAward
		cfg[#cfg + 1] = awards.jionAward
		cfg[#cfg + 1] = awards.killAward
	elseif act_id == DAILY_ACTIVITY_TYPE.SHI_JIE_BOSS then
		local awards = act_cfg.Awards
		for i,v in ipairs(awards.rankAward.award) do
			cfg[#cfg + 1] = v
		end
		cfg[#cfg + 1] = awards.jionAward.award
		cfg[#cfg + 1] = awards.killAward.award
	end

	return cfg
end
--------------------
