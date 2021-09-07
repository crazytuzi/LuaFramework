RareTreasureData = RareTreasureData or BaseClass()

function RareTreasureData:__init()
	if RareTreasureData.Instance ~= nil then
		ErrorLog("[RareTreasureData] Attemp to create a singleton twice !")
	end
	RareTreasureData.Instance = self

	self.total_chongzhi = 0
	self.my_words = {}
	self.guess_counts = {}
	self.lottery_cost = 0
	self.change_count = 0

	self.true_words = {}
	self.cur_pool = -1

	self.cost_config = nil
	self.word_config = nil
	self.word_seq_config = nil
	self.pool_config = nil
	self.pool_seq_config = nil
end

function RareTreasureData:__delete()
	self.cost_config = nil
	self.word_config = nil
	self.word_seq_config = nil
	self.pool_config = nil
	self.pool_seq_config = nil
	RareTreasureData.Instance = nil
end

-- self.guess_counts[奖池][字] = 人数
function RareTreasureData:SetSCCrossRAZhenYanMiBaoInfo(protocol)
	self.total_chongzhi = protocol.total_chongzhi
	self.my_words = protocol.my_words
	self.guess_counts = protocol.guess_counts
	self.lottery_cost = protocol.lottery_cost
	self.change_count = protocol.change_count
end

function RareTreasureData:SetPoolRewardWoedInfo(protocol)
	self.true_words = protocol.true_words
	self.cur_pool = protocol.cur_pool
end

function RareTreasureData:GetMyWordBySeq(seq)
	if self.my_words[seq] then
		return self.my_words[seq]
	end
	return -1
end

function RareTreasureData:GetGuessCountBySeq(pool_seq, word_seq)
	if self.guess_counts[pool_seq] and self.guess_counts[pool_seq][word_seq] then
		return self.guess_counts[pool_seq][word_seq]
	end
	return 0
end

function RareTreasureData:GetTotleChongZhi()
	return self.total_chongzhi
end

function RareTreasureData:GetLotteryCost()
	return self.lottery_cost
end

function RareTreasureData:GetConfigByPoolSeq(pool_seq)
	local pool_seq_config = self:GetPoolConfig()
	if pool_seq_config[pool_seq] then
		return pool_seq_config[pool_seq]
	end
end

function RareTreasureData:GetAllConfig()
	if not self.pool_config then
		self.pool_config = ServerActivityData.Instance:GetCrossRandActivityConfig().zymb_lottery_pool_config
	end
	return self.pool_config
end

function RareTreasureData:GetWordAllConfig()
	if not self.word_config then
		self.word_config = ServerActivityData.Instance:GetCrossRandActivityConfig().zymb_word_config
	end
	return self.word_config
end

function RareTreasureData:GetWordSeqConfig()
	if not self.word_seq_config then
		local word_config = self:GetWordAllConfig()
		self.word_seq_config = ListToMap(word_config, "word_seq")
	end
	return self.word_seq_config
end

function RareTreasureData:GetWordConfigBySeq(word_seq)
	local word_seq_config = self:GetWordSeqConfig()
	if word_seq_config[word_seq] then
		return word_seq_config[word_seq]
	end
end

function RareTreasureData:GetTrueWordBySeq(pool_seq)
	if self.true_words[pool_seq] then
		return self.true_words[pool_seq]
	end
	return -1
end

function RareTreasureData:GetCurRewardWord()
	if self.true_words[self.cur_pool] then
		return self.true_words[self.cur_pool]
	end
	return -1
end

function RareTreasureData:GetCurChangeNum()
	return self.change_count
end

function RareTreasureData:GetChangeWordNeedGold(cur_change)
	cur_change = cur_change or 0
	local next_cost = 0
	local cost_config = self:GetCostConfig()
	for k,v in pairs(cost_config) do
		if cur_change < v.max_change_count then
			next_cost = v.change_cost
			break
		end
	end
	return next_cost
end

function RareTreasureData:GetPoolConfig()
	if not self.pool_seq_config then
		local pool_config = self:GetAllConfig()
		self.pool_seq_config = ListToMap(pool_config, "pool_seq")
	end
	return self.pool_seq_config
end

function RareTreasureData:GetCostConfig()
	if not self.cost_config then
		self.cost_config = ServerActivityData.Instance:GetCrossRandActivityConfig().zymb_word_change_config
	end
	return self.cost_config
end