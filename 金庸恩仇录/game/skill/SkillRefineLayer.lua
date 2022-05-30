local data_item_nature = require("data.data_item_nature")
local data_card_card = require("data.data_card_card")
local data_item_item = require("data.data_item_item")
local data_refine_refine = require("data.data_refine_refine")

local COLOR_GREEN = cc.c3b(0, 255, 0)

local SkillRefineLayer = class("SkillRefineLayer", function(param)
	return require("utility.ShadeLayer").new(cc.c4b(0, 0, 0, 155))
end)

local Item = class("Item", function()
	return CCTableViewCell:new()
end)

function Item:getContentSize()
	return cc.size(100, 91)
end

function Item:create(param)
	local _viewSize = param.viewSize
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("skill/skill_refine_icon.ccbi", proxy, self._rootnode)
	node:setPosition(node:getContentSize().width / 2, _viewSize.height / 2)
	self:addChild(node, 0)
	
	--需要道具数量	
	self.needNum = ui.newTTFLabelWithOutline({
	text = "/0",
	size = 20,
	font = FONTS_NAME.font_fzcy,
	color = FONT_COLOR.GREEN_1,
	outlineColor = FONT_COLOR.BLACK,
	})
	
	ResMgr.replaceKeyLable(self.needNum , self._rootnode.numLabel, 0, 0, 10)
	self.needNum:align(display.RIGHT_CENTER)
	
	--已有道具数量
	self.hasNum = ui.newTTFLabelWithOutline({
	text = "0",
	size = 20,
	font = FONTS_NAME.font_fzcy,
	color = FONT_COLOR.GREEN_1,
	outlineColor = FONT_COLOR.BLACK,
	})
	
	ResMgr.replaceKeyLable(self.hasNum , self._rootnode.numLabel, 0, 0, 10)
	self.hasNum:align(display.RIGHT_CENTER)
	
	self._rootnode.numLabel:setVisible(false)
	
	self:refresh(param)
	return self
end

function Item:refresh(param)
	local _itemData = param.itemData
	self.needNum:setString(string.format("/%d", _itemData.n2))
	self.hasNum:setString(tostring(_itemData.n1))
	if _itemData.n1 >= _itemData.n2 then
		self.needNum:setColor(cc.c3b(0, 255, 0))
		self.hasNum:setColor(cc.c3b(0, 255, 0))
	else
		self.needNum:setColor(cc.c3b(255, 0, 0))
		self.hasNum:setColor(cc.c3b(255, 0, 0))
	end
	local x = self._rootnode.numLabel:getPositionX()
	self.needNum:setPositionX(x)
	self.hasNum:setPositionX(x - self.needNum:getContentSize().width)
	ResMgr.refreshIcon({
	id = _itemData.id,
	itemBg = self._rootnode.iconSprite,
	resType = ResMgr.getResType(_itemData.t)
	})
end

local RequestInfo = require("network.RequestInfo")

function SkillRefineLayer:ctor(param)
	local _callback = param.callback
	self._info = param.baseInfo
	self._refineInfo = param.refineInfo
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("skill/skill_refine_scene.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node, 1)
	if display.widthInPixels / display.heightInPixels > 0.67 then
		self._rootnode.infoNode:setScale(0.8)
		local posX, posY = self._rootnode.infoNode:getPosition()
		self._rootnode.infoNode:setPosition(posX + self._rootnode.infoNode:getContentSize().width * 0.1, posY)
	end
	self._rootnode.titleLabel:setString(common:getLanguageString("@wuxuejl"))
	self._bRequest = false
	
	local function onClose()
		BagCtrl.request(function()
			if _callback then
				_callback(self._bRequest, self._refineInfo.cnt)
			end
			self:removeSelf()
		end)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
	end
	
	self._rootnode.returnBtn:addHandleOfControlEvent(function(eventName, sender)
		onClose()
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.closeBtn:addHandleOfControlEvent(function(eventName, sender)
		onClose()
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.jinglianBtn:addHandleOfControlEvent(function(eventName, sender)
		local refineInfo = data_refine_refine[self._info.resId]
		local propCount = #refineInfo.arr_nature2
		if self._refineInfo.cnt == propCount * 10 then
			show_tip_label(data_error_error[1000011].prompt)
			return
		end
		self._rootnode.jinglianBtn:setEnabled(false)
		if self._refineInfo.allow == 1 then
			local req = RequestInfo.new({
			modulename = "skill",
			funcname = "refine",
			param = {
			op = 2,
			id = self._info._id
			},
			oklistener = function(data)
				if data.errCode and data.errCode ~= 0 then
					if data.errmsg ~= nil then
						show_tip_label(data.errmsg)
					else
						data_error_error = require("data.data_error_error")
						if data_error_error[data.errCode] then
							show_tip_label(data_error_error[data.errCode].prompt)
						end
					end
				else
					self:performWithDelay(function()
						self._rootnode.jinglianBtn:setEnabled(true)
					end,
					1)
					self._refineInfo = data
					game.player:setSilver(data.update.silver)
					PostNotice(NoticeKey.CommonUpdate_Label_Silver)
					self:refresh(true)
					self._bRequest = true
					dump(self._refineInfo)
					self:palyAnim()
				end
			end
			})
			RequestHelperV2.request(req)
		else
			show_tip_label(common:getLanguageString("@suoxuwpbz"))
		end
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
	end,
	CCControlEventTouchUpInside)
	
	self:refreshBaseInfo()
	self:refresh()
end

function SkillRefineLayer:refreshBaseInfo()
	local baseInfo = data_item_item[self._info.resId]
	self._rootnode.cardName:setString(baseInfo.name)
	self._rootnode.card_bg:setDisplayFrame(display.newSprite("#item_card_bg_" .. baseInfo.quality .. ".png"):getDisplayFrame())
	local path = ResMgr.getLargeImage(baseInfo.bicon, ResMgr.EQUIP)
	self._rootnode.skillImage:setDisplayFrame(display.newSprite(path):getDisplayFrame())
	
	self.heroName = ui.newTTFLabelWithShadow({
	text = baseInfo.name,
	font = FONTS_NAME.font_haibao,
	size = 30,
	align = ui.TEXT_ALIGN_CENTER,
	color = NAME_COLOR[baseInfo.quality],
	shadowColor = FONT_COLOR.BLACK,
	})
	
	ResMgr.replaceKeyLable(self.heroName, self._rootnode.itemNameLabel, 0, 0)
	self.heroName:align(display.CENTER)
	
	self.jlLabel = ui.newTTFLabelWithShadow({
	text = "",
	font = FONTS_NAME.font_haibao,
	size = 30,
	align = ui.TEXT_ALIGN_CENTER,
	color = FONT_COLOR.GREEN_1,
	shadowColor = FONT_COLOR.BLACK,
	})
	
	ResMgr.replaceKeyLable(self.jlLabel, self._rootnode.itemNameLabel, self.heroName:getContentSize().width / 2, 0)
	self.jlLabel:align(display.LEFT_CENTER)
	
	for i = 1, baseInfo.quality do
		self._rootnode[string.format("star%d", i)]:setVisible(true)
	end
	
end
function SkillRefineLayer:createFloatNum(name, num)
	local stateTTF = ui.newBMFontLabel({
	text = name .. "" .. tostring(num),
	font = "fonts/font_equip_enhance.fnt"
	})
	local setVis = CCCallFunc:create(function()
		stateTTF:setVisible(true)
	end)
	local moveUp = CCMoveBy:create(1, cc.p(0, 30))
	local fadeOut = CCFadeOut:create(1)
	local spawn = CCSpawn:createWithTwoActions(moveUp, fadeOut)
	local rev = CCRemoveSelf:create(true)
	local seq = transition.sequence({
	setVis,
	spawn,
	rev
	})
	stateTTF:runAction(seq)
	stateTTF:setPosition(display.cx, display.cy)
	self:addChild(stateTTF, 10)
end
function SkillRefineLayer:palyAnim()
	local effect = ResMgr.createArma({
	resType = ResMgr.UI_EFFECT,
	armaName = "zhuangbeiqianghua",
	isRetain = false,
	finishFunc = function()
	end
	})
	effect:setPosition(self._rootnode.skillImage:getContentSize().width / 2, self._rootnode.skillImage:getContentSize().height / 2)
	self._rootnode.skillImage:addChild(effect)
end
function SkillRefineLayer:getNatureStr(nature, value)
	local val = ""
	if nature.type == 2 then
		val = value * 0.01
		if val == math.ceil(val) then
			val = string.format("+%d%%", val)
		else
			val = string.format("+%.1f%%", value * 0.01)
		end
	else
		val = string.format("+%d", value)
	end
	return val
end

function SkillRefineLayer:refresh(bRefine)
	local refineInfo = data_refine_refine[self._info.resId]
	local propCount = #refineInfo.arr_nature2
	local num = math.floor(self._refineInfo.cnt / propCount) + 1
	local index = self._refineInfo.cnt % propCount
	if index == 0 and self._refineInfo.cnt > 0 then
		index = propCount
		num = num - 1
	end
	printf(common:getLanguageString("@jingliancs"), self._refineInfo.cnt, propCount, num, index)
	for k, v in ipairs(refineInfo.arr_nature2) do
		local tmpNode = self._rootnode["propNode_" .. k]
		tmpNode:setVisible(true)
		tmpNode:removeChildByTag(100)
		tmpNode:removeChildByTag(200)
		tmpNode:removeChildByTag(300)
		local nature = data_item_nature[v]
		local value = refineInfo.arr_value2[k]
		self._rootnode[string.format("propLabel_%d", k)]:setString(nature.nature .. "：")
		self._rootnode[string.format("prevewValueLabel_%d", k)]:setString("")
		local val = 0
		local valStr = ""
		if nature.type == 2 then
			if index >= k then
				val = num * value * 0.01
				if val == math.ceil(val) then
					valStr = string.format("%d%%", val)
					self._rootnode[string.format("propValueLabel_%d", k)]:setString(valStr)
				else
					valStr = string.format("%.1f%%", val)
					self._rootnode[string.format("propValueLabel_%d", k)]:setString(valStr)
				end
			elseif num == 1 then
				self._rootnode[string.format("propValueLabel_%d", k)]:setString("0")
			else
				val = (num - 1) * value * 0.01
				if val == math.ceil(val) then
					valStr = string.format("%d%%", val)
					self._rootnode[string.format("propValueLabel_%d", k)]:setString(valStr)
				else
					valStr = string.format("%.1f%%", val)
					self._rootnode[string.format("propValueLabel_%d", k)]:setString(valStr)
				end
			end
		elseif index >= k then
			val = num * value
			valStr = string.format("%d", val)
			self._rootnode[string.format("propValueLabel_%d", k)]:setString(valStr)
		else
			val = (num - 1) * value
			if num == 1 then
				valStr = "0"
				self._rootnode[string.format("propValueLabel_%d", k)]:setString("0")
			else
				valStr = string.format("%d", val)
				self._rootnode[string.format("propValueLabel_%d", k)]:setString(valStr)
			end
		end
		if propCount < index + 1 or index == 0 then
		elseif index >= k then
			local diamond = display.newSprite("#kongfu_diamond.png")
			diamond:setPosition(tmpNode:getContentSize().width / 2, tmpNode:getContentSize().height / 2)
			diamond:setTag(200)
			self._rootnode["propNode_" .. k]:addChild(diamond, 1)
		end
	end
	if propCount > 0 and self._refineInfo.cnt < propCount * 10 then
		do
			local tmpNode, tmpIndex
			if propCount < index + 1 then
				tmpNode = self._rootnode[string.format("propNode_%d", 1)]
				tmpIndex = 1
			else
				tmpNode = self._rootnode[string.format("propNode_%d", index + 1)]
				tmpIndex = index + 1
			end
			local nature = data_item_nature[refineInfo.arr_nature2[tmpIndex]]
			local value = refineInfo.arr_value2[tmpIndex]
			self._rootnode[string.format("prevewValueLabel_%d", tmpIndex)]:setString(self:getNatureStr(nature, value))
			if bRefine then
				local tmpNature = data_item_nature[refineInfo.arr_nature2[index]]
				self:createFloatNum(tmpNature.nature, self:getNatureStr(tmpNature, refineInfo.arr_value2[index]))
			end
			local diamond = display.newSprite("#kongfu_diamond.png")
			diamond:setPosition(tmpNode:getContentSize().width / 2, tmpNode:getContentSize().height / 2)
			diamond:setTag(300)
			tmpNode:addChild(diamond, 2)
			local diamondEmpty = display.newSprite("#kongfu_diamond_empty.png")
			diamondEmpty:setPosition(tmpNode:getContentSize().width / 2, tmpNode:getContentSize().height / 2)
			diamondEmpty:setTag(200)
			tmpNode:addChild(diamondEmpty, 1)
			local opacity = 255
			local opt = 1
			diamond:schedule(function()
				diamond:setOpacity(opacity)
				self._rootnode[string.format("prevewValueLabel_%d", tmpIndex)]:setOpacity(opacity)
				if opacity == 255 then
					opt = 1
				elseif opacity <= 0 then
					opt = 0
				end
				if opt == 1 then
					opacity = opacity - 5
				else
					opacity = opacity + 5
				end
			end,
			0.01)
			
			local effect = ResMgr.createArma({
			resType = ResMgr.UI_EFFECT,
			armaName = "wuxuejinglian",
			isRetain = false,
			finishFunc = function()
			end
			})
			effect:setTag(100)
			effect:setPosition(tmpNode:getContentSize().width / 2, tmpNode:getContentSize().height / 2)
			tmpNode:addChild(effect, 0)
		end
	elseif self._refineInfo.cnt == propCount * 10 then
		for k, v in ipairs(refineInfo.arr_nature2) do
			local tmpNode = self._rootnode["propNode_" .. k]
			local diamond = display.newSprite("#kongfu_diamond.png")
			diamond:setPosition(tmpNode:getContentSize().width / 2, tmpNode:getContentSize().height / 2)
			diamond:setTag(200)
			tmpNode:addChild(diamond, 1)
		end
	end
	if num >= 1 and index == propCount then
		self.jlLabel:setString(string.format("+%d", num))
	elseif num > 1 then
		self.jlLabel:setString(string.format("+%d", num - 1))
	end
	--dump(self._refineInfo.items)
	if self._refineInfo.cnt < propCount * 10 then
		if self._iconList then
			self._iconList:resetListByNumChange(#self._refineInfo.items)
		else
			self._iconList = require("utility.TableViewExt").new({
			size = self._rootnode.listView:getContentSize(),
			createFunc = function(idx)
				idx = idx + 1
				return Item.new():create({
				viewSize = self._rootnode.listView:getContentSize(),
				itemData = self._refineInfo.items[idx]
				})
			end,
			refreshFunc = function(cell, idx)
				idx = idx + 1
				cell:refresh({
				itemData = self._refineInfo.items[idx]
				})
			end,
			cellNum = #self._refineInfo.items,
			cellSize = Item.new():getContentSize(),
			touchFunc = function(cell)
				local idx = cell:getIdx() + 1
				local item = data_item_item[self._refineInfo.items[idx].id]
				local infoLayer = require("game.Huodong.ItemInformation").new({
				id = self._refineInfo.items[idx].id,
				type = item.type,
				name = item.name,
				describe = item.describe,
				endFunc = function()
				end
				})
				self:addChild(infoLayer, 10)
			end
			})
			self._iconList:setPosition(0, 0)
			self._rootnode.listView:addChild(self._iconList)
		end
	elseif self._iconList then
		self._iconList:resetListByNumChange(0)
	end
	self._rootnode.costSilverLabel:setString(tostring(self._refineInfo.silver))
end

return SkillRefineLayer