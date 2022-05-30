local CONFIG_SIZE = cc.size(display.width, 700)

FormCtrl = {}

local fmtRequest = function (param)
	RequestHelper.formation.list(param)
end

local setHero = function (pos, id, listener)
	RequestHelper.formation.set({
	callback = function (data)
		dump(data)
		if #data["0"] > 0 then
			show_tip_label(data["0"])
		else
			game.player.m_formation["1"] = data["1"]
			if listener then
				listener(data)
			end
		end
	end,
	pos = pos,
	id = id
	})
end

local function createFormSettingLayer(param)
	local _bTouchEnabled = param.touchEnabled or false
	local _sz = param.sz or CONFIG_SIZE
	local _parentNode = param.parentNode
	local _pos = param.pos or ccp(0, 0)
	local _list = param.list
	local _bTmpPos = param.bTmpPos
	local _callback = param.callback
	local _closeListener = param.closeListener
	local _zdlNum = param.zdlNum
	dump(_list)
	local bHasChange = false
	local function getHeroByPos(pos)
		for k, v in ipairs(_list) do
			if v.pos == pos then
				return v
			end
		end
	end
	local function getHeroById(id)
		for k, v in ipairs(_list) do
			if v.objId == id then
				return v
			end
		end
	end
	local function exchangeFunc(pos, id)
		printf("pos = %s, id = %s", tostring(pos), tostring(id))
		bHasChange = true
		if _bTmpPos then
			local hero = getHeroByPos(checkint(pos))
			if hero then
				hero.pos = getHeroById(id).pos
			else
			end
			getHeroById(id).pos = checkint(pos)
		else
			setHero(pos, id, _callback)
		end
	end
	local layer = require("game.form.FormSettingLayer").new({
	bTouchEnabled = _bTouchEnabled,
	list = _list,
	sz = _sz,
	zdlNum = _zdlNum,
	closeListener = function ()
		if _closeListener then
			_closeListener(bHasChange)
		end
	end,
	exchangeFunc = exchangeFunc
	})
	layer:setPosition(_pos)
	_parentNode:addChild(layer, 1000)
	return layer
end

function FormCtrl.createFormSettingLayer(param)
	if param.list then
		return createFormSettingLayer(param)
	else
		fmtRequest({
		callback = function (data)
			if #data["0"] > 0 then
				show_tip_label(data["0"])
			else
				dump(data)
				param.list = data["1"]
				createFormSettingLayer(param)
			end
		end
		})
	end
end
return FormCtrl