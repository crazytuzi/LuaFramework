local HuoDongFuBenModel  = {}

--[[设置剩余次数]]
function HuoDongFuBenModel.setRestNum(id, num)
	local fubenData = HuoDongFuBenModel.getFubenData(id)
	fubenData.surplusCnt = num
end

--[[剩余次数]]
function HuoDongFuBenModel.getRestNum(id)
	local fubenData = HuoDongFuBenModel.getFubenData(id)
	return fubenData.surplusCnt
end

function HuoDongFuBenModel.getFubenData(id)
	return HuoDongFuBenModel.rawData["1"][tostring(id)]
end

function HuoDongFuBenModel.getItemID(id)
	local fubenData = HuoDongFuBenModel.getFubenData(id)
	return fubenData.itemId
end

function HuoDongFuBenModel.getItemNum(id)
	local fubenData = HuoDongFuBenModel.getFubenData(id)
	return fubenData.num
end

function HuoDongFuBenModel.initData(data)
	HuoDongFuBenModel.rawData = data
	if data.gold ~= nil then
		game.player.m_gold = data.gold
	end
end

function HuoDongFuBenModel.getBuyCnt()
	return HuoDongFuBenModel.rawData["2"].buyCnt
end

function HuoDongFuBenModel.getLimit()
	return HuoDongFuBenModel.rawData["2"].limit
end

function  HuoDongFuBenModel.getFubenList()
	return HuoDongFuBenModel.rawData["1"]
end

return HuoDongFuBenModel