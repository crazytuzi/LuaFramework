local data_config_config = require("data.data_config_config")
local data_item_item = require("data.data_item_item")
local data_collect_collect = require("data.data_collect_collect")
require("data.data_error_error")
local RequestInfo = require("network.RequestInfo")
SpiritCtrl = {}
local _spiritInfo = {
size = {num = 0, max = 0},
level = 1,
item = 0,
currConvertExp = 0,
spiritList = {},
showList = {}
}

local _bRequest = true

local function _requestState(callback)
	local reqs = {}
	if _bRequest then
		table.insert(reqs, RequestInfo.new({
		modulename = "spirit",
		funcname = "list",
		param = {},
		oklistener = function (data)
			SpiritCtrl.set("size", {
			num = data["2"],
			max = data["3"]
			})
			game.player:setSpirit(data["1"])
			SpiritCtrl.insert(data["1"])
			_spiritInfo.currConvertExp = tonumber(data["7"])
		end
		}))
		table.insert(reqs, RequestInfo.new({
		modulename = "spirit",
		funcname = "start",
		param = {},
		oklistener = function (data)
			SpiritCtrl.set("level", data["2"])
			SpiritCtrl.set("item", data["4"])
			game.player:setSilver(data["3"])
			game.player:setGold(data["5"])
		end,
		errlistener = function (data)
			show_tip_label(data)
		end
		}))
		RequestHelperV2.request2(reqs, function ()
			_bRequest = false
			if callback then
				callback()
			end
		end)
	elseif callback then
		callback()
	end
end

local function _getIndexByID(id)
	for k, v in ipairs(_spiritInfo.spiritList) do
		if v.data._id == id then
			return k
		end
	end
end

local function _removeSpiritByID(id)
	for k, v in ipairs(_spiritInfo.spiritList) do
		if v.data._id == id then
			printf("rm  %s", id)
			table.remove(_spiritInfo.spiritList, k)
			break
		end
	end
end

function SpiritCtrl.clear()
	_spiritInfo.size.num = 0
	_spiritInfo.size.max = 0
	_spiritInfo.level = 1
	_spiritInfo.item = 0
	for i = 1, #_spiritInfo.spiritList do
		table.remove(_spiritInfo.spiritList, 1)
	end
	for i = 1, #_spiritInfo.showList do
		table.remove(_spiritInfo.showList, 1)
	end
	_bRequest = true
end

function SpiritCtrl.setSpiritListSyn()
	printf("setSpiritListSyn")
	_bRequest = true
end

function SpiritCtrl.insert(data)
	for k, v in ipairs(data) do
		table.insert(_spiritInfo.spiritList, {
		baseData = data_item_item[v.resId],
		data = v
		})
	end
	SpiritCtrl.groupSpirit(data)
	_spiritInfo.size.num = #_spiritInfo.spiritList
end

function SpiritCtrl.getSpirit()
	local ret = {}
	for k, v in ipairs(_spiritInfo.spiritList) do
		table.insert(ret, v.data)
	end
	return ret
end

function SpiritCtrl.getIndexByID(id)
	local ret = 0
	for k, v in ipairs(_spiritInfo.spiritList) do
		if v.data._id == id then
			ret = k
			break
		end
	end
	return ret
end

function SpiritCtrl.groupUpgradeSpirit(item, t)
	for i = 1, #t do
		for j = 1, #t[1] do
			table.remove(t[1], 1)
		end
		table.remove(t, 1)
	end
	local i = 1
	for k, v in ipairs(_spiritInfo.spiritList) do
		if item.baseData.pos == 51 or item.data._id ~= v.data._id and v.data.pos == 0 and item.baseData.quality >= v.data.quality then
			if i % 5 == 1 then
				table.insert(t, {})
			end
			i = i + 1
			table.insert(t[#t], v)
		end
	end
end

function SpiritCtrl.countUpgradeSpirit(t)
	local i = 0
	for k, v in ipairs(t) do
		i = i + #v
	end
	return i
end

function SpiritCtrl.removeSpiritByID(id)
	if type(id) == "table" then
		for _, v in ipairs(id) do
			_removeSpiritByID(v)
		end
	elseif type(id) == "number" then
		_removeSpiritByID(id)
	end
	SpiritCtrl.refresh()
end

function SpiritCtrl.groupSpirit(data)
	local i = 1
	if data then
		if _spiritInfo.showList[#_spiritInfo.showList] then
			i = #_spiritInfo.showList[#_spiritInfo.showList] + 1
		end
		for k, v in ipairs(data) do
			if v.pos == 0 then
				if i % 5 == 1 then
					table.insert(_spiritInfo.showList, {})
				end
				i = i + 1
				table.insert(_spiritInfo.showList[#_spiritInfo.showList], _spiritInfo.spiritList[_getIndexByID(v._id)])
			end
		end
	else
		for k, v in ipairs(_spiritInfo.spiritList) do
			if v.data.pos == 0 then
				if i % 5 == 1 then
					table.insert(_spiritInfo.showList, {})
				end
				i = i + 1
				table.insert(_spiritInfo.showList[#_spiritInfo.showList], v)
			end
		end
	end
end

function SpiritCtrl.refresh()
	for i = 1, #_spiritInfo.showList do
		for j = 1, #_spiritInfo.showList[1] do
			table.remove(_spiritInfo.showList[1], 1)
		end
		table.remove(_spiritInfo.showList, 1)
	end
	SpiritCtrl.groupSpirit()
end

function SpiritCtrl.onStart(tag, callback)
	if tag == 1 or tag == 3 then
		if tag == 1 then
			if _spiritInfo.size.num >= _spiritInfo.size.max then
				show_tip_label(common:getLanguageString("@zhenqislzd"))
				return
			end
			if game.player:getSilver() < data_collect_collect[_spiritInfo.level].price then
				show_tip_label(data_error_error[1407].prompt)
				return
			end
		else
			if _spiritInfo.size.num + 10 > _spiritInfo.size.max then
				show_tip_label(data_error_error[2300011].prompt)
				return
			end
			if game.player:getSilver() < data_config_config[1].collTenSilver then
				show_tip_label(data_error_error[1407].prompt)
				return
			end
		end
		RequestHelper.spirit.start({
		callback = function (data)
			SpiritCtrl.insert(data["1"])
			SpiritCtrl.set("level", data["2"])
			SpiritCtrl.set("item", data["4"])
			game.player:setSilver(data["3"])
			game.player:setGold(data["5"])
			callback(data["1"])
		end,
		t = tag
		})
	elseif tag == 2 then
		RequestHelper.spirit.nbstart({
		callback = function (data)
			SpiritCtrl.set("level", data["1"])
			SpiritCtrl.set("item", data["3"])
			game.player:setGold(data["2"])
			callback()
		end
		})
	end
	GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
end

function SpiritCtrl.upgrade(id, ids, callback)
	RequestHelper.spirit.upgrade({
	callback = function (data)
		SpiritCtrl.removeSpiritByID(ids)
		callback(data)
	end,
	id = id,
	ids = ids
	})
end

function SpiritCtrl.pushUpgradeScene(index)
	_requestState(function ()
		push_scene(require("game.Spirit.SpiritUpgradeScene").new(index))
	end)
end

function SpiritCtrl.set(name, param)
	assert(_spiritInfo[name], string.format("Please check key: %s", name))
	if name == "size" then
		_spiritInfo[name].num = param.num
		_spiritInfo[name].max = param.max
	elseif name == "level" then
		_spiritInfo[name] = param
	else
		_spiritInfo[name] = param
	end
end

function SpiritCtrl.get(name)
	assert(_spiritInfo[name], string.format("Please check key: %s", name))
	return _spiritInfo[name]
end

function SpiritCtrl.setSize(num, max)
	_spiritInfo.size.num = num or 0
	_spiritInfo.size.max = max or 0
end

function SpiritCtrl.request(callback)
	_requestState(callback)
end

function SpiritCtrl.enterSpiritScene(msg)
	_requestState(function ()
		local _scene = require("game.Spirit.SpiritScene2").new({tag = msg, ctrl = SpiritCtrl})
		display.replaceScene(_scene)
	end)
end

function SpiritCtrl.getGrade1And4()
	local tab = {}
	for k, v in ipairs(_spiritInfo.spiritList) do
		if v.data.quality <= 4 and v.data.pos == 0 and v.data.resId ~= 6006 then
			if tab[v.data.quality] == nil then
				tab[v.data.quality] = {}
			end
			table.insert(tab[v.data.quality], v)
		end
	end
	return tab
end

function SpiritCtrl.getConvertExp()
	return _spiritInfo.currConvertExp
end

function SpiritCtrl.setConvertExp(exp)
	_spiritInfo.currConvertExp = exp
end

function SpiritCtrl.converts(str, layercallback, callback, errorCallBack)
	local param = {}
	param.ids = str
	function param.callback(data)
		--dump(data)
		if data.err and data.err ~= "" then		
			show_tip_label(data_error_error[data.errCode].prompt)			
			if errorCallBack then
				errorCallBack()
			end
			return
		end
		SpiritCtrl.setConvertExp(tonumber(data["0"]))
		local gets = data["1"].need
		if gets then
			SpiritCtrl.insert(gets)
		end
		local cdata = {}
		for k, v in ipairs(gets) do
			table.insert(cdata, v)
		end
		for k, v in ipairs(data["1"].consume) do
			table.insert(cdata, v)
		end
		SpiritCtrl.set("level", data["2"])
		game.player:setSilver(data["3"])
		if layercallback then
			layercallback(cdata)
		end
		if callback then
			callback()
		end
	end
	GameRequest.spirit.converts(param)
end

function SpiritCtrl.resolves(num, layercallback, callback)
	local params = {}
	params.count = num
	function params.callback(data)
		dump(data)
		if data.err and data.err ~= "" then
			show_tip_label(data_error_error[data.errCode].prompt)
			return
		end
		if data["1"] then
			SpiritCtrl.insert(data["1"])
		end
		SpiritCtrl.setConvertExp(tonumber(data["0"]))
		if layercallback then
			layercallback(data["1"])
		end
		if callback then
			callback()
		end
	end
	GameRequest.spirit.resolves(params)
end

return SpiritCtrl