local data_jingmai_jingmai = require("data.data_jingmai_jingmai")
local data_item_nature = require("data.data_item_nature")

local BaseScene = require("game.BaseSceneExt")
local JingmaiScene = class("JingmaiScene", BaseScene)

local function getChannel(tp, pos)
	for _, v in ipairs(data_jingmai_jingmai) do
		if v.type == tp and v.order == pos then
			return v
		end
	end
end

local getValue = function(t, l)
	local ret = 0
	for k, v in ipairs(t.arr_value) do
		if k <= l then
			ret = ret + v
		else
			break
		end
	end
	return ret
end

local NAME_MAPPING = {
common:getLanguageString("@HardControl"),
common:getLanguageString("@HardDefence"),
common:getLanguageString("@HardAttack")
}

function JingmaiScene:ctor()
	game.runningScene = self
	JingmaiScene.super.ctor(self, {
	contentFile = "jingmai/jingmai_scene.ccbi"
	})
	--ResMgr.createBefTutoMask(self)
	local proxy = CCBProxy:create()
	self._animNode = CCBuilderReaderLoad("jingmai/jingmai_open_anim.ccbi", proxy, self._rootnode)
	self._animNode:retain()
	self.top = require("game.scenes.TopLayer").new()
	self:addChild(self.top, 1)
	if display.widthInPixels / display.heightInPixels == 0.75 then
		self._rootnode.tag_hero_pos:setScale(0.9)
	elseif display.widthInPixels / display.heightInPixels > 0.66 then
	else
		self._rootnode.tag_hero_pos:setScale(1.2)
		self._rootnode.tag_hero_pos:setPositionY(self._rootnode.tag_hero_pos:getPositionY() + 70)
	end
	if game.player.m_gender == 2 then
		self._rootnode.jingmai_bg_male:setVisible(false)
		self._rootnode.jingmai_bg_female:setVisible(true)
	end
	
	--返回
	self._rootnode.backBtn:addHandleOfControlEvent(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		GameStateManager:ChangeState(GAME_STATE.STATE_MAIN_MENU)
	end,
	CCControlEventTouchUpInside)
	
	--升级 九- 零 -一-起 玩-w-w-w-.9-0 -1- 7-5-.-com
	self._rootnode.upgradeBgn:addHandleOfControlEvent(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if self._info.level == 0 and self._info.order == 0 then
			show_tip_label(common:getLanguageString("@LevelMax"))
			return
		end
		if self._info.type ~= 0 and self._index ~= self._info.type then
			show_tip_label(common:getLanguageString("@PageSwitch", NAME_MAPPING[self._info.type]))
			return
		end
		if checknumber(self._rootnode.needStarLabel:getString()) > self._starNum then
			show_tip_label(data_error_error[2200005].prompt)
			return
		end
		if checknumber(self._rootnode.needSilverLabel:getString()) > game.player:getSilver() then
			show_tip_label(common:getLanguageString("@SiverCoinNotEnough"))
			return
		end
		local t
		if self._info.type == 0 then
			t = self._index
		else
			t = nil
		end
		RequestHelper.channel.upgrade({
		callback = function(data)
			dump(data)
			if #data["0"] > 0 then
				show_tip_label(data["0"])
			else
				self:runAnim(self._info.order - 1, self._info.order)
				self._starNum = data["1"]
				game.player:setSilver(data["2"])
				self._info.type = self._index
				self._info.order = data["4"]
				self._info.level = data["3"]
				self:refresh()
			end
		end,
		t = t
		})
	end,
	CCControlEventTouchUpInside)
	
	local function reset()
		RequestHelper.channel.reset({
		callback = function(data)
			if #data["0"]> 0 then
				CCMessageBox(data["0"], "Tip")
			else
				dump(data)
				self._rootnode.previewSprite:setVisible(true)
				self._rootnode.upgradeBgn:setVisible(true)
				self._starNum = data["1"]
				game.player:setGold(data["2"])
				self._itemNum = data["3"]
				self._info = {
				type = 0,
				order = 1,
				level = 1
				}
				self:refresh()
			end
		end
		})
	end
	
	--重置
	self._rootnode.resetBtn:addHandleOfControlEvent(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if 50 > game.player:getGold() then
			show_tip_label(common:getLanguageString("@PriceEnough"))
			return
		end
		if self._info.type == 0 then
			show_tip_label(common:getLanguageString("@NoResetableJingMai"))
			return
		end
		local layer = require("utility.MsgBox").new({
		size = cc.size(500, 200),
		leftBtnName = common:getLanguageString("@DI"),
		rightBtnName = common:getLanguageString("@Confirm"),
		content = common:getLanguageString("@ResetJingMai"),
		leftBtnFunc = function()
		end,
		rightBtnFunc = function()
			reset()
		end
		})
		self:addChild(layer, 100)
	end,
	CCControlEventTouchUpInside)
	
	local function onChangeView(_, sender)
		self._index = sender:getTag()
		self:refreshBg()
		self:refresh()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
	end
	
	for i = 1, 3 do
		self._rootnode["jingmaiBtn_" .. tostring(i)]:addHandleOfControlEvent(onChangeView, CCControlEventTouchUpInside)
	end
	
	--dump(self._rootnode)
	self._index = 1
	self:refreshBg()
	self:request()
end

function JingmaiScene:refreshBg()
	for i = 1, 3 do
		self._rootnode[string.format("type_%d", i)]:setVisible(self._index == i)
		if display.widthInPixels / display.heightInPixels > 0.67 then
			self._rootnode[string.format("type_%d", i)]:setScale(0.9)
		end
	end
	if self._bg then
		self._bg:removeSelf()
	end
	self._bg = display.newScale9Sprite(string.format("#jingmai_hero_bg_%d.png", self._index), 0, 0, cc.size(display.width, self:getContentHeight()), cc.rect(10, 10, 20, 20))
	self._bg:setPosition(display.width / 2, self:getBottomHeight() + self:getContentHeight() / 2)
	self:addChild(self._bg)
end

function JingmaiScene:runAnim(pos1, pos2)
	local anim = {}
	for i = pos1, pos2 do
		if i > 0 and i < pos2 then
			printf("============ %d", i)
			local angle = self._rootnode[string.format("line_%d_%d", self._index, i)]:getTag()
			local pos = self._rootnode[string.format("board_%d_%d", self._index, i + 1)]:convertToWorldSpace(ccp(42.5, 42.5))
			table.insert(anim, CCRotateTo:create(0, angle))
			table.insert(anim, CCMoveTo:create(0.1, pos))
		end
	end
	table.insert(anim, CCCallFunc:create(function()
		local proxy = CCBProxy:create()
		local node = CCBuilderReaderLoad("jingmai/jingmai_upgrade_anim.ccbi", proxy, {})
		node:runAction(transition.sequence({
		CCDelayTime:create(0.5),
		CCRemoveSelf:create()
		}))
		node:setPosition(self._rootnode[string.format("board_%d_%d", self._index, pos2)]:convertToWorldSpace(ccp(42.5, 42.5)))
		self:addChild(node, 101)
	end))
	table.insert(anim, CCFadeOut:create(0))
	table.insert(anim, CCDelayTime:create(0.1))
	table.insert(anim, CCRemoveSelf:create())
	local sprite = display.newSprite("#jingmai_anim_1.png")
	if pos1 < 1 then
		pos1 = 1
	end
	sprite:setPosition(self._rootnode[string.format("board_%d_%d", self._index, pos1)]:convertToWorldSpace(ccp(42.5, 42.5)))
	self:addChild(sprite, 100)
	sprite:runAction(transition.sequence(anim))
end

function JingmaiScene:onFullLevel()
	self._rootnode.previewSprite:setVisible(false)
	self._rootnode.upgradeBgn:setVisible(false)
	show_tip_label(common:getLanguageString("@JingMaiMax"))
	for i = 1, 8 do
		if i < 8 then
			local key1 = string.format("line_%d_%d", self._index, i)
			self._rootnode[key1]:setDisplayFrame(display.newSpriteFrame(string.format("jingmai_line_%d.png", self._index)))
		end
		local key2 = string.format("board_%d_%d", self._index, i)
		self._rootnode[string.format("lvLabel_%d_%d", self._index, i)]:setString(string.format("Lv%d", #data_jingmai_jingmai[1].arr_value))
		self._rootnode[key2]:setDisplayFrame(display.newSpriteFrame("jingmai_icon_board_1.png"))
		self._rootnode[key2]:getChildByTag(1):setDisplayFrame(display.newSpriteFrame("jingmai_xuedao_3.png"))
	end
	self._animNode:removeFromParentAndCleanup(false)
	self:setPropValue(10, 9)
end

local getValueStr = function(t, value)
	local str, pre
	if value > 0 then
		pre = "+"
	else
		pre = ""
	end
	if t == 2 then
		if value > 0 then
			str = string.format("%s%.1f%%", pre, value / 100)
		else
			str = "0"
		end
	else
		str = string.format("%s%d", pre, value)
	end
	return str
end

function JingmaiScene:setPropValue(lv, _order)
	for _, v in ipairs(data_jingmai_jingmai) do
		if v.type == self._index then
			local nat = data_item_nature[v.nature]
			self._rootnode[string.format("propNameLabel_%d", v.order)]:setString(string.format("%s：", nat.nature))
			local str
			if _order > v.order then
				str = getValueStr(nat.type, getValue(v, lv))
			else
				str = getValueStr(nat.type, getValue(v, lv - 1))
			end
			self._rootnode[string.format("propValueLabel_%d", v.order)]:setString(str)
			alignNodesOneByOne(self._rootnode[string.format("propNameLabel_%d", v.order)], self._rootnode[string.format("propValueLabel_%d", v.order)])
		end
	end
end

function JingmaiScene:refresh()
	local _level = 1
	local _order = 1
	local item
	if self._info.type == self._index then
		_level = self._info.level
		_order = self._info.order
		if _level == 0 and _order == 0 then
			self:onFullLevel()
			return
		end
	end
	item = getChannel(self._index, _order)
	local nature = data_item_nature[item.nature]
	self.top:setGodNum(game.player:getGold())
	self.top:setSilver(game.player:getSilver())
	local str
	if nature.type == 2 then
		str = string.format("%s +%.1f%%", item.describe, item.arr_value[_level] / 100)
	else
		str = string.format("%s +%d", item.describe, item.arr_value[_level])
	end
	self._rootnode.effectValueLabel:setString(str)
	self._rootnode.needStarLabel:setString(tostring(item.arr_star[_level]))
	self._rootnode.needSilverLabel:setString(tostring(item.arr_coin[_level]))
	local showNum = 0 <= self._starNum and self._starNum or 0
	self._rootnode.starCountLabel:setString("x" .. tostring(showNum))
	self._rootnode.totalItemLabel:setString(tostring(self._itemNum))
	self:setPropValue(_level, _order)
	for i = 1, 8 do
		local key = string.format("board_%d_%d", self._index, i)
		if _order > i or _level > 1 and _order == 1 then
			self._rootnode[key]:setDisplayFrame(display.newSpriteFrame("jingmai_icon_board_1.png"))
			self._rootnode[key]:getChildByTag(1):setDisplayFrame(display.newSpriteFrame("jingmai_xuedao_2.png"))
			if _level > 1 and _order == 1 then
				self._rootnode[string.format("lvLabel_%d_%d", self._index, i)]:setString(string.format("Lv%d", _level - 1))
				if i == 1 then
					self._animNode:setPosition(self._rootnode[key]:getContentSize().width / 2, self._rootnode[key]:getContentSize().height / 2)
					self._animNode:removeFromParentAndCleanup(false)
					self._rootnode[key]:addChild(self._animNode)
				end
			else
				self._rootnode[string.format("lvLabel_%d_%d", self._index, i)]:setString(string.format("Lv%d", _level))
				printf("3")
			end
		elseif i == _order then
			self._rootnode[key]:setDisplayFrame(display.newSpriteFrame("jingmai_icon_board_2.png"))
			self._rootnode[key]:getChildByTag(1):setDisplayFrame(display.newSpriteFrame("jingmai_xuedao_1.png"))
			self._rootnode[string.format("lvLabel_%d_%d", self._index, i)]:setString(string.format("Lv%d", _level - 1))
			self._animNode:setPosition(self._rootnode[key]:getContentSize().width / 2, self._rootnode[key]:getContentSize().height / 2)
			self._animNode:removeFromParentAndCleanup(false)
			self._rootnode[key]:addChild(self._animNode)
		else
			self._rootnode[key]:setDisplayFrame(display.newSpriteFrame("jingmai_icon_board_2.png"))
			self._rootnode[key]:getChildByTag(1):setDisplayFrame(display.newSpriteFrame("jingmai_xuedao_0.png"))
			self._rootnode[string.format("lvLabel_%d_%d", self._index, i)]:setString(string.format("Lv%d", _level - 1))
		end
		if _level > 1 then
			self._rootnode[key]:setDisplayFrame(display.newSpriteFrame("jingmai_icon_board_1.png"))
			if _level == 10 and _order > i then
				self._rootnode[key]:getChildByTag(1):setDisplayFrame(display.newSpriteFrame("jingmai_xuedao_3.png"))
			else
				self._rootnode[key]:getChildByTag(1):setDisplayFrame(display.newSpriteFrame("jingmai_xuedao_2.png"))
			end
		end
	end
	for i = 1, 7 do
		local key = string.format("line_%d_%d", self._index, i)
		if i < _order - 1 then
			self._rootnode[key]:setDisplayFrame(display.newSpriteFrame(string.format("jingmai_line_%d.png", self._index)))
		else
			self._rootnode[key]:setDisplayFrame(display.newSpriteFrame("jingmai_line_hui.png"))
		end
		if _level > 1 then
			self._rootnode[key]:setDisplayFrame(display.newSpriteFrame(string.format("jingmai_line_%d.png", self._index)))
		end
	end
	if self._info.type == 0 then
		self._rootnode.resetBtn:setEnabled(false)
	else
		self._rootnode.resetBtn:setEnabled(true)
	end
	if self._info.type == 0 or self._info.type == self._index then
		self._rootnode.infoNode:setVisible(true)
	else
		self._rootnode.infoNode:setVisible(false)
	end
end

function JingmaiScene:request()
	RequestHelper.channel.info({
	callback = function(data)
		dump(data)
		if #data["0"] > 0 then
			show_tip_label(data["0"])
		else
			self._starNum = data["1"]
			game.player:setGold(data["3"])
			game.player:setSilver(data["4"])
			self._itemNum = data["7"]
			self._info = {
			type = data["6"],
			order = data["2"],
			level = data["5"]
			}
			
			
			--self._index = 3
			--self._info.type = 3
			--self._info.level = 2
			--self._info.order = 2
			
			self:refreshBg()
			self:refresh()
		end
	end
	})
end

function JingmaiScene:onEnter()
	JingmaiScene.super.onEnter(self)
	local tisheng_btn = self._rootnode.upgradeBgn
	TutoMgr.addBtn("tisheng_btn", tisheng_btn)
	TutoMgr.active()
end

function JingmaiScene:onExit()
	JingmaiScene.super.onExit(self)
	TutoMgr.removeBtn("tisheng_btn")
	self._animNode:release()
end

return JingmaiScene