TallPriceLotteryData = TallPriceLotteryData or BaseClass(BaseView)

function TallPriceLotteryData:__init()
	if TallPriceLotteryData.Instance then
		print_error("[TallPriceLotteryData] 尝试创建第二个单例模式")
		return
	end
	TallPriceLotteryData.Instance = self

	self.total_chip_num = 0 				--筹码数
	self.reward_seq = {}					--对应物品索引	
	self.reward_bet_num = {} 				--物品投注数
	self.lottery_config = ConfigManager.Instance:GetAutoConfig("randactivityconfig_1_auto")
	self.lottery_reward_pool_cfg = ListToMap(self.lottery_config.lottery_reward_pool, "seq")

	self.rank_role_id = {}					--排行榜角色ID
	self.rank_bet_num = {} 					--排行榜角色投注数
	self.my_rank = 0 						--自身排名数	
	self.my_bet_num = 0 					--自身投注数
end

-- protocol设置投注的数据
function TallPriceLotteryData:GetLotteryInfo(protocol)
	self.total_chip_num = protocol.total_chip_num
	self.reward_seq = protocol.reward_seq
	self.reward_bet_num = protocol.reward_bet_num
end

-- 筹码数
function TallPriceLotteryData:GetBetNum()
	return self.total_chip_num or 0
end

-- 物品投注数
function TallPriceLotteryData:GetRewardBetNum()
	return self.reward_bet_num or {}
end

--对应物品索引
function TallPriceLotteryData:GetRewardSeq()
	return self.reward_seq or {}
end

--通过索引读取奖励Item
function TallPriceLotteryData:GetLotteryRewardLotteryCfg(seq)
	if seq ~= nil then		
		return self.lottery_reward_pool_cfg[seq]
	end
	return nil
end

--protocol排行榜数据
function TallPriceLotteryData:GetLotteryRank(protocol)
	self.rank_role_id = protocol.rank_role_id
	self.rank_bet_num = protocol.rank_bet_num
	self.my_rank = protocol.my_rank
	self.my_bet_num = protocol.my_bet_num
	self.draw_timestamp = protocol.draw_timestamp
end

function TallPriceLotteryData:GetRankRoleId()
	return self.rank_role_id or {}
end

function TallPriceLotteryData:GetRankBetNum()
	return self.rank_bet_num or {}
end

function TallPriceLotteryData:GetRankMyRank()
	return self.my_rank or 0
end

function TallPriceLotteryData:GetRankMyBetNum()
	return self.my_bet_num or 0
end

function TallPriceLotteryData:GetResidueOpenTime()
	return self.draw_timestamp or 0
end

function TallPriceLotteryData:GetReturnNoZeroBetNum()
	local num = 0
	for i,v in ipairs(self.rank_bet_num) do
		if v > 0 then
			num = num + 1
		end
	end
	return num
end