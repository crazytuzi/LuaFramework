local JingYingModel  = {}
JingYingModel.rawData = nil

--[[设置剩余次数]]
function JingYingModel.setRestNum(num)
	JingYingModel.rawData["2"].surplusCnt = num
end

--[[剩余次数]]
function JingYingModel.getRestNum()
	return JingYingModel.rawData["2"].surplusCnt
end

function JingYingModel.getCost()
	return JingYingModel.rawData["2"].spend
end

function JingYingModel.initData(data)
	JingYingModel.rawData = data
	JingYingModel.refreshGold(data.gold)
end

function JingYingModel.refreshGold(num)
	if num ~= nil and game.player.m_gold ~= num then
		game.player.m_gold = num
		PostNotice(NoticeKey.CommonUpdate_Label_Gold)
	end
end

function JingYingModel.getGold()
	return game.player.m_gold
end

function JingYingModel.buySuccess(data)
	print("buySuccess")
	dump(data)
	JingYingModel.rawData["2"].surplusCnt = data.surplusCnt
	JingYingModel.rawData["2"].buyCnt = data.buyCnt
	JingYingModel.refreshGold(data.gold)
	JingYingModel.rawData["2"].spend = data.spend
end

function JingYingModel.getBuyCnt()
	return JingYingModel.rawData["2"].buyCnt
end

function JingYingModel.getMaxLv()
	return JingYingModel.rawData["1"]
end

function JingYingModel.getLimit()
	return JingYingModel.rawData["2"].limit
end

return JingYingModel