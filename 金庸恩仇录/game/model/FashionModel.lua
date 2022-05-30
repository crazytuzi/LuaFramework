local data_fashion_fashion = require("data.data_fashion_fashion")
local data_item_item = require("data.data_item_item")

local fashionMsg = {

fashionList = function(param)
	local msg = {
	m = "fashion",
	a = "listFashion"
	}
	RequestHelper.request(msg, param.callback, param.errback)
end,

fashionInstall = function(params)
	local msg = {
	m = "fashion",
	a = "installFashion",
	pos = 1,
	id = params.id,
	}
	RequestHelper.request(msg, params.callback, params.errback)
end
}

local FashionModel = {}

function FashionModel.fashionInstall(_pos, _id, _fashionId, _callback)
	fashionMsg.fashionInstall({
	pos = _pos,
	id = _id,
	fashionId = _fashionId,
	callback = function(data)
		if _id > 0 then
			for k, v in pairs(FashionModel.fashionList) do
				if v._id == _id then
					v.pos = 1
					FashionModel.equipFashion = v
					game.player:setFashionId(v.resId)
				end
			end
		elseif FashionModel.equipFashion then
			FashionModel.equipFashion.pos = 0
			game.player:setFashionId(0)
			FashionModel.equipFashion = nil
		end
		_callback(true)
	end
	})
end

function FashionModel.fashionListSort()
	local function sortFunc(a, b)
		if a.subpos > 0 then
			return true
		end
		if data_item_item[a.resId].order < data_item_item[b.resId].order then
			return true
		else
			return false
		end
	end
	
	if #FashionModel.fashionList > 0 then
		table.sort(FashionModel.fashionList, sortFunc)
		dump(FashionModel.fashionList)
	end
	return FashionModel.fashionList
end

function FashionModel.getListReq(_callback)
	fashionMsg.fashionList({
	callback = function(data)	
		--FashionModel.fashionList = data[1]
		--if FashionModel.fashionList then
		--	FashionModel.fashionListSort()
		--end
		FashionModel.cylsNum = data[2]
		_callback(FashionModel.fashionList, FashionModel.cylsNum)
	end
	})
end

function FashionModel.getCylsNum()
	return FashionModel.cylsNum
end

function FashionModel.setCylsNum(num)
	FashionModel.cylsNum = num
end

function FashionModel.getFashionList()
	return FashionModel.fashionList
end

function FashionModel.getInitData(fashionId)
	local fashionData = data_item_item[fashionId]
	local data = {
	isWare = 0,
	lastOverTime = -1,
	fashionId = fashionId,
	resId = fashionId,
	level = 0
	}
	data.pros = {}
	for k, v in pairs(fashionData.arr_value) do
		data.pros[#data.pros + 1] = v
	end
	return data
end

function FashionModel.initFashionList(fashionList, equipFashion)
	FashionModel.fashionList = fashionList
	FashionModel.equipFashion = equipFashion
end

return FashionModel