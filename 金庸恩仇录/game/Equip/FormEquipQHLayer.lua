local data_equipen_equipen = require("data.data_equipen_equipen")
local data_item_nature = require("data.data_item_nature")
local data_item_item = require("data.data_item_item")

local FormEquipQHLayer = class("FormEquipQHLayer", function()
	return require("utility.ShadeLayer").new()
end)

local RequestInfo = require("network.RequestInfo")
local ccs = ccs or {}
ccs.MovementEventType = {
START = 0,
COMPLETE = 1,
LOOP_COMPLETE = 2
}

function FormEquipQHLayer:ctor(param)
	self._proxy = CCBProxy:create()
	self._rootnode = {}
	local bgNode = CCBuilderReaderLoad("equip/equip_qianghua_scene.ccbi", self._proxy, self._rootnode)
	bgNode:setPosition(display.cx, display.cy - bgNode:getContentSize().height / 2)
	self:addChild(bgNode, 1)
	local _info = param.info
	local _baseInfo = data_item_item[_info.resId]
	local _cost = 0
	local _listener = param.listener
	--dump(_info)
	self._rootnode.titleLabel:setString(common:getLanguageString("@EquitQH"))
	self._rootnode.cardName:setString(_baseInfo.name)
	self.cardBg = self._rootnode.card_bg	
	self.quality = _info.star
	
	if _info.star > 5 then
		_info.star = 5
	end
	
	for i = 1, _info.star do
		self._rootnode[string.format("star%d", i)]:setVisible(true)
	end
	local path = ResMgr.getLargeImage(_baseInfo.bicon, ResMgr.EQUIP)
	self._rootnode.bigImageSpirit:setDisplayFrame(display.newSprite(path):getDisplayFrame())
	local nameLabel = ui.newTTFLabelWithShadow({
	text = _baseInfo.name,
	font = FONTS_NAME.font_haibao,
	size = 30,
	align = ui.TEXT_ALIGN_CENTER,
	color = NAME_COLOR[_baseInfo.quality],
	shadowColor = display.COLOR_BLACK,
	})
	
	ResMgr.replaceKeyLableEx(nameLabel, self._rootnode, "itemNameLabel", 0, 0)
	nameLabel:align(display.CENTER)
	
	local function refresh(tmpLv)
		local _level = tmpLv or _info.level
		self._rootnode.card_bg:setDisplayFrame(display.newSprite("#item_card_bg_" .. _baseInfo.quality .. ".png"):getDisplayFrame())
		self._rootnode.bigLvLabel:setString(tostring(_level))
		self._rootnode.maxLvLabel:setString(string.format("/%d", game.player:getLevel() * 2))
		self._rootnode.curLvLabel:setString("LV." .. tostring(_level))
		self._rootnode.nextLvLabel:setString("LV." .. tostring(_level + 1))
		for k, v in ipairs(_baseInfo.arr_nature) do
			self._rootnode["propNode_" .. tostring(k)]:setVisible(true)
			local nature = data_item_nature[v]
			local value = _baseInfo.arr_value[k] + _baseInfo.arr_addition[k] * _level
			local nextValue = _baseInfo.arr_value[k] + _baseInfo.arr_addition[k] * (_level + 1)
			printf("value = %d, nextValue = %d", value, nextValue)
			local valStr = ""
			local nextValStr = ""
			if nature.type == 1 then
				valStr = string.format("%d", value)
				nextValStr = string.format("%d", nextValue)
			else
				valStr = string.format("%d%%", value)
				nextValStr = string.format("%d%%", nextValue)
			end
			self._rootnode["propLableName_" .. tostring(k)]:setString(nature.nature .. "：")
			self._rootnode["propLabel_" .. tostring(k)]:setString(valStr)
			self._rootnode["propLabel_n_" .. tostring(k)]:setString(nextValStr)
		end
		local ratio = _baseInfo.ratio / 10000
		_cost = math.round(data_equipen_equipen[_level + 1].coin[_info.star] * ratio)
		self._rootnode.costLabel:setString(tostring(_cost))
	end
	local function addProp(lv)
		for k, v in ipairs(_baseInfo.arr_nature) do
			local value = _baseInfo.arr_value[k] + _baseInfo.arr_addition[k] * (_info.level + lv)
			for i, natureIdx in ipairs(EQUIP_BASE_PROP_MAPPPING) do
				if v == natureIdx then
					_info.base[i] = value
				end
			end
		end
	end
	refresh()
	local function close()
		dump(_info)
		local equipData = game.player:getEquipments()
		for k, v in ipairs(equipData) do
			if v._id == _info._id then
				equipData[k] = clone(_info)
				break
			end
		end
		if _listener then
			_listener(self.isQianghua)
		end
		PostNotice(NoticeKey.REMOVE_TUTOLAYER)
		self:removeSelf()
	end
	local function playAnim(level)
		local sprite
		if level >= 2 then
			sprite = display.newSprite("#equip_qianghua_baoji.png")
		else
			sprite = display.newSprite("#equip_qianghua_success.png")
		end
		sprite:setPosition(display.cx, display.cy + 80)
		sprite:runAction(transition.sequence({
		CCCallFunc:create(function()
			local tisheng = display.newSprite("#equip_tisheng.png")
			tisheng:setPosition(display.cx, display.cy - 30)
			local lvLabel = display.newSprite(string.format("#equip_xl_baoji_%d.png", level))
			lvLabel:setPosition(tisheng:getContentSize().width * 0.6, tisheng:getContentSize().height / 2)
			tisheng:addChild(lvLabel)
			tisheng:runAction(transition.sequence({
			CCScaleTo:create(0.1, 1.2),
			CCDelayTime:create(0.7),
			CCSpawn:createWithTwoActions(CCScaleTo:create(0.5, 0), CCFadeOut:create(0.5)),
			CCRemoveSelf:create(true)
			}))
			self:addChild(tisheng, 101)
		end),
		CCScaleTo:create(0.1, 1.5),
		CCDelayTime:create(0.7),
		CCSpawn:createWithTwoActions(CCScaleTo:create(0.5, 0), CCFadeOut:create(0.5)),
		CCRemoveSelf:create(true),
		CCCallFunc:create(function()
			for k, v in ipairs(_baseInfo.arr_nature) do
				local nature = data_item_nature[v]
				local value = _baseInfo.arr_addition[k] * level
				local stateTTF = ui.newBMFontLabel({
				text = nature.nature .. "+" .. tostring(value),
				font = "fonts/font_equip_enhance.fnt"
				})
				stateTTF:setPosition(display.cx, display.cy)
				stateTTF:setVisible(false)
				stateTTF:runAction(transition.sequence({
				CCDelayTime:create(k - 1),
				CCShow:create(),
				CCSpawn:createWithTwoActions(CCMoveBy:create(1.5, cc.p(0, 40)), CCFadeOut:create(1.5)),
				CCRemoveSelf:create(true)
				}))
				self:addChild(stateTTF, 100)
			end
		end)
		}))
		self:addChild(sprite, 100)
	end
	local function qiangHua(tag)
		if _info.level >= game.player:getLevel() * 2 then
			show_tip_label(common:getLanguageString("@UpperLimit"))
			return
		end
		if _cost > game.player:getSilver() then
			show_tip_label(common:getLanguageString("@SilverCoinEnough"))
			return
		end
		local req = RequestInfo.new({
		modulename = "equip",
		funcname = "qianghua",
		param = {
		auto = tag,
		id = _info._id
		},
		oklistener = function(data)
			dump(data)
			self._rootnode.autoBtn:setEnabled(false)
			self._rootnode.qianghuaBtn:setEnabled(false)
			PostNotice(NoticeKey.REMOVE_TUTOLAYER)
			local i = 1
			local offsetLV = data["2"] - _info.level
			local tmpLV = _info.level
			local sss
			local _Data = data["1"][i]
			if _Data == nil then
				return
			end
			function sss()
				playAnim(data["1"][i].lv)
				tmpLV = tmpLV + data["1"][i].lv
				refresh(tmpLV)
				i = i + 1
				if data["1"][i] then
					self:qiangHuaAnim(sss)
				else
					self._rootnode.autoBtn:setEnabled(true)
					self._rootnode.qianghuaBtn:setEnabled(true)
				end
			end
			self.isQianghua = true
			addProp(offsetLV)
			game.player:setSilver(data["3"])
			PostNotice(NoticeKey.CommonUpdate_Label_Silver)
			self:qiangHuaAnim(sss)
			_info.level = data["2"]
			_info.silver = data["4"]
		end
		})
		RequestHelperV2.request(req)
	end
	
	self._rootnode.closeBtn:addHandleOfControlEvent(close, CCControlEventTouchUpInside)
	self._rootnode.backBtn:addHandleOfControlEvent(close, CCControlEventTouchUpInside)
	self._rootnode.autoBtn:addHandleOfControlEvent(function()
		qiangHua(1)
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.qianghuaBtn:addHandleOfControlEvent(function()
		qiangHua(0)
	end,
	CCControlEventTouchUpInside)
end

function FormEquipQHLayer:qiangHuaAnim(finishFunc)
	local EFFECT_ZORDER = 100000
	CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("ccs/effect/chuizi/chuizi.ExportJson")
	local chuiziAnim = CCArmature:create("chuizi")
	chuiziAnim:setAnchorPoint(cc.p(0, 0.5))
	chuiziAnim:getAnimation():setFrameEventCallFunc(function(bone, evt, originFrameIndex, currentFrameIndex)
		if evt == "effect" then
			self:shake(1)
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_qianghua))
			local effect = ResMgr.createArma({
			resType = ResMgr.UI_EFFECT,
			armaName = "zhuangbeiqianghua",
			isRetain = false,
			finishFunc = function()
				GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_qianghuachenggong))
				if finishFunc then
					finishFunc()
				end
			end
			})
			effect:setPosition(self._rootnode.card_bg:getContentSize().width / 2, self._rootnode.card_bg:getContentSize().height / 2)
			self.cardBg:addChild(effect)
		end
	end)
	chuiziAnim:getAnimation():setMovementEventCallFunc(function(armatureBack, movementType, movementID)
		if movementType == ccs.MovementEventType.COMPLETE then
			chuiziAnim:getAnimation():playWithIndex(0)
			chuiziAnim:removeSelf()
			CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo("ccs/effect/chuizi/chuizi.ExportJson")
		end
	end)
	chuiziAnim:setPosition(self.cardBg:getPositionX() + self.cardBg:getContentSize().width * 0.4, self.cardBg:getPositionY())
	self.cardBg:addChild(chuiziAnim, EFFECT_ZORDER)
	chuiziAnim:getAnimation():playWithIndex(0)
end
function FormEquipQHLayer:shake(direction)
	if direction ~= 0 then
		do
			local rate = 0.01
			local delayTime = 0.08
			local cPosX = self.cardBg:getPositionX()
			local cPosY = self.cardBg:getPositionY()
			local xDirection = 1
			local yDirection = -1
			if direction == 1 then
				xDirection = 1
				yDirection = -1
			elseif direction == 2 then
				xDirection = 1
				yDirection = -1
			end
			local delayAct = CCDelayTime:create(delayTime)
			local offSetWidth = display.width * rate
			local offSetcHeight = display.height * rate
			local moveAct1 = CCCallFunc:create(function()
				self.cardBg:setPosition(cc.p(cPosX + offSetWidth * xDirection, cPosY + offSetcHeight * yDirection))
			end)
			local moveAct2 = CCCallFunc:create(function()
				self.cardBg:setPosition(cc.p(cPosX, cPosY))
			end)
			local sequence = transition.sequence({
			moveAct1,
			delayAct,
			moveAct2
			})
			self.cardBg:runAction(sequence)
		end
	end
end

function FormEquipQHLayer:onEnter()
	local tuBtn = self._rootnode.qianghuaBtn
	TutoMgr.addBtn("equip_qianghua_once_btn", tuBtn)
	TutoMgr.addBtn("equip_qianghua_close_btn", self._rootnode.closeBtn)
	TutoMgr.active()
end

function FormEquipQHLayer:onExit()
	TutoMgr.removeBtn("equip_auto_qianghua_btn")
	TutoMgr.removeBtn("equip_qianghua_close_btn")
end

return FormEquipQHLayer