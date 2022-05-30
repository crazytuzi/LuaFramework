local LimitHeroModel = {}

LimitHeroModel.rawData = nil

LimitHeroModel.isFreeAllowFreeDraw = false

function LimitHeroModel.sendInitRes(param)
	RequestHelper.getLimitInitData({
	callback = function(data)
		LimitHeroModel.rawData = data
		LimitHeroModel.init()
		param.callback()
	end
	})
end

function LimitHeroModel.init()
	local rawData = LimitHeroModel.rawData
	
	function LimitHeroModel.actEndTime()
		return rawData.act_end_time
	end
	
	function LimitHeroModel.actStartTime()
		return rawData.act_start_time
	end
	
	function LimitHeroModel.scoreLimit()
		return rawData.lcb.scoreLimit
	end
	
	function LimitHeroModel.scoreLimitNum()
		local limitNum = {}
		for i, v in ipairs(rawData.lcb.scoreLimit) do
			limitNum[i] = v / 10
		end
		return limitNum
	end
	
	function LimitHeroModel.actEndTime_inMS()
		return rawData.actEndTime_inMS
	end
	
	function LimitHeroModel.actRestTime()
		return rawData.act_rest_time
	end
	
	function LimitHeroModel.freeRestTime()
		return rawData.free_rest_time
	end
	
	function LimitHeroModel.getProbItems()
		return rawData.lcb.probItems
	end
	function LimitHeroModel.costGold()
		return rawData.gold_cost
	end
	function LimitHeroModel.costVip()
		return rawData.lcb.vip or 0
	end
	
	function LimitHeroModel.player_score()
		return rawData.player_score
	end
	
	function LimitHeroModel.packgeState()
		return rawData.packgeState
	end
	
	LimitHeroModel.heroList = {}
	for i = 1, 3 do
		if rawData.lcb["card" .. i] ~= 0 then
			LimitHeroModel.heroList[#LimitHeroModel.heroList + 1] = rawData.lcb["card" .. i]
		end
	end
	LimitHeroModel.rewardList = {}
	for i = 1, 4 do
		LimitHeroModel.rewardList[#LimitHeroModel.rewardList + 1] = rawData.lcb["reward" .. i]
	end
	
	function LimitHeroModel.luckNum()
		return rawData.luck_num
	end
	
	function LimitHeroModel.maxLuckNum()
		return rawData.max_luck_num
	end
	
	function LimitHeroModel.playerRank()
		return rawData.player_rank
	end
	
	function LimitHeroModel.getModifiedPlayerRank()
		local rankText = common:getLanguageString("@Over1000Persons")
		local fontSize = 16
		if LimitHeroModel.playerRank() < 1000 then
			rankText = LimitHeroModel.playerRank()
			fontSize = 20
		end
		return rankText, fontSize
	end
	
	function LimitHeroModel.playerScore()
		return rawData.player_score
	end
	
	function LimitHeroModel.restLuckNum()
		return rawData.rest_luck_num
	end
	
	function LimitHeroModel.rankList()
		return rawData.rlblist
	end
	
	LimitHeroModel.rawData.oldLuck = rawData.luck_num
end

function LimitHeroModel.getScore()
	return LimitHeroModel.rawData.get_score
end

function LimitHeroModel.setPackgeState(index, state)
	LimitHeroModel.rawData.packgeState[index] = 1
end

function LimitHeroModel.sendFreeDraw(param)
	RequestHelper.drawLimitHero({
	isFree = 1,
	callback = function(data)
		dump("fffffrrrreeeedraw")
		dump(data)
		LimitHeroModel.updateData(data)
		param.callback(data)
	end
	})
end

function LimitHeroModel.updateData(data)
	local cbData = data
	LimitHeroModel.rawData.oldLuck = LimitHeroModel.luckNum()
	for k, v in pairs(cbData) do
		LimitHeroModel.rawData[k] = v
	end
end

function LimitHeroModel.getLuckNumThisTime()
	return LimitHeroModel.luckNum() - LimitHeroModel.rawData.oldLuck
end

function LimitHeroModel.getHeroList()
	return LimitHeroModel.heroList
end

function LimitHeroModel.sendGoldDraw(param)
	RequestHelper.drawLimitHero({
	isFree = 0,
	callback = function(data)
		dump("goldddddeeeedraw")
		dump(data)
		game.player.m_gold = game.player.m_gold - LimitHeroModel.costGold()
		LimitHeroModel.updateData(data)
		param.callback()
	end
	})
end

function LimitHeroModel.drawedHero()
	return LimitHeroModel.rawData.probItem
end

function LimitHeroModel.getIsAllowFreeDraw()
	return LimitHeroModel.isFreeAllowFreeDraw
end

function LimitHeroModel.isAllowGoldDraw()
	if game.player.m_gold < LimitHeroModel.costGold() or game.player.m_vip < LimitHeroModel.costVip() then
		return false
	else
		return true
	end
end

return LimitHeroModel