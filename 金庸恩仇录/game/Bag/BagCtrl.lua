BagCtrl = {}
local VIEW_TYPE = {
BAG_ITEM = 1,
BAG_SKILL = 2,
BAG_GIFT = 3
}
local _bagInfo = {
[VIEW_TYPE.BAG_ITEM] = {
size = {num = 0, max = 0},
cost = {sz = 0, cost = 0},
list = {}
},
[VIEW_TYPE.BAG_SKILL] = {
size = {num = 0, max = 0},
cost = {sz = 0, cost = 0},
list = {}
},
[VIEW_TYPE.BAG_GIFT] = {
size = {num = 0, max = 0},
cost = {sz = 0, cost = 0},
list = {}
}
}
local _bRequest = false
local RequestInfo = require("network.RequestInfo")
local data_item_item = require("data.data_item_item")
function BagCtrl.request(callback)
	if _bRequest then
		if callback then
			callback()
		end
	else
		printf("============================= BagCtrl.request")
		_bRequest = true
		local reqs = {}
		local function listSortFunc(lh, rh)
			if lh.cid > 0 and rh.cid == 0 then
				return true
			elseif data_item_item[lh.resId].pos ~= 101 and data_item_item[lh.resId].pos ~= 102 and (data_item_item[rh.resId].pos == 101 or data_item_item[rh.resId].pos == 102) then
				return true
			else
				return false
			end
		end
		table.insert(reqs, RequestInfo.new({
		modulename = "skill",
		funcname = "list",
		param = {},
		oklistener = function(data)
			game.player:setSkills(data["1"])
			BagCtrl.set(VIEW_TYPE.BAG_SKILL, "list", data["1"])
			BagCtrl.set(VIEW_TYPE.BAG_SKILL, "size", {
			num = data["2"],
			max = data["3"]
			})
			BagCtrl.set(VIEW_TYPE.BAG_SKILL, "cost", {
			sz = data["4"],
			cost = data["5"]
			})
		end
		}))
		table.insert(reqs, RequestInfo.new({
		modulename = "packet",
		funcname = "list",
		param = {},
		oklistener = function(data)
			BagCtrl.set(VIEW_TYPE.BAG_ITEM, "list", data["1"])
			BagCtrl.set(VIEW_TYPE.BAG_ITEM, "size", {
			num = data["2"],
			max = data["3"]
			})
			BagCtrl.set(VIEW_TYPE.BAG_ITEM, "cost", {
			sz = data["4"],
			cost = data["5"]
			})
		end
		}))
		table.insert(reqs, RequestInfo.new({
		modulename = "packet",
		funcname = "list",
		param = {},
		oklistener = function(data)
			BagCtrl.set(VIEW_TYPE.BAG_GIFT, "list", data["1"])
			BagCtrl.set(VIEW_TYPE.BAG_GIFT, "size", {
			num = data["2"],
			max = data["3"]
			})
			BagCtrl.set(VIEW_TYPE.BAG_GIFT, "cost", {
			sz = data["4"],
			cost = data["5"]
			})
		end
		}))
		RequestHelperV2.request2(reqs, function()
			if callback then
				callback()
			end
		end)
	end
end

local clear = function(t)
	local len = #t
	if len > 0 then
		for i = 1, len do
			table.remove(t, 1)
		end
	end
end

function BagCtrl.setRequest(b)
	_bRequest = b
end

function BagCtrl.set(viewType, name, param)
	assert(_bagInfo[viewType] and _bagInfo[viewType][name], string.format("Please check key: %s", name))
	if name == "size" then
		_bagInfo[viewType].size.num = param.num
		_bagInfo[viewType].size.max = param.max
	elseif name == "cost" then
		_bagInfo[viewType].cost.sz = param.sz
		_bagInfo[viewType].cost.cost = param.cost
	elseif name == "list" then
		clear(_bagInfo[viewType].list)
		for k, v in ipairs(param) do
			_bagInfo[viewType].list[k] = v
		end
	end
end

function BagCtrl.get(viewType, name)
	assert(_bagInfo[viewType] and _bagInfo[viewType][name], string.format("Please check key: %s", name))
	return _bagInfo[viewType][name]
end

return BagCtrl