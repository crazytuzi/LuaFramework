local data_item_nature = require("data.data_item_nature")
local data_refine_refine = require("data.data_refine_refine")
local data_jiban_jiban = require("data.data_jiban_jiban")
local data_shangxiansheding_shangxiansheding = require("data.data_shangxiansheding_shangxiansheding")
local data_item_item = require("data.data_item_item")
local RequestInfo = require("network.RequestInfo")

local DuobaoItemInfoLayer = class("DuobaoItemInfoLayer", function()
	return require("utility.ShadeLayer").new(cc.c4b(0, 0, 0, 155))
end)

local Item = class("Item", function(heroid, data)
	local proxy = CCBProxy:create()
	local rootnode = {}
	local node = CCBuilderReaderLoad("skill/skill_jiban.ccbi", proxy, rootnode)
	rootnode.skillName:setString(data.name)
	local color, cls
	if heroid == 1 or heroid == 2 then
		heroid = game.player.m_gender
		color = NAME_COLOR[game.player:getStar()]
		cls = game.player:getClass()
	end
	local cardData = ResMgr.getCardData(heroid)
	color = color or NAME_COLOR[cardData.star[1]]
	if cardData then
		local name = cardData.name
		if heroid == 1 or heroid == 2 then
			name = game.player:getPlayerName()
		end
		local nameLabel = ui.newTTFLabelWithShadow({
		text = name,
		font = FONTS_NAME.font_fzcy,
		size = 20,
		color = color,
		shadowColor = display.COLOR_BLACK,
		align = ui.TEXT_ALIGN_CENTER
		})
		ResMgr.replaceKeyLableEx(nameLabel, rootnode, "heroName", 0, 0)
		nameLabel:align(display.CENTER)
	else
		rootnode.heroName:setString(common:getLanguageString("@NoCardID", tostring(heroid)))
	end
	ResMgr.refreshIcon({
	itemBg = rootnode.headIcon,
	id = heroid,
	resType = ResMgr.HERO
	})
	local nature = data_item_nature[data.nature1]
	local str = nature.nature
	if nature.type == 1 then
		str = str .. ": +" .. tostring(data.value1)
	else
		str = str .. string.format(": +%d%%", data.value1 / 100)
	end
	rootnode.jibanDes:setString(string.format("%s%s", data.describe, str))
	return node
end)

function DuobaoItemInfoLayer:ctor(param)
	local _id = param.id
	local _confirmListen = param.confirmListen
	local refineInfo = data_refine_refine[_id]
	local _baseInfo = data_item_item[_id]
	local _level = 0
	self:setNodeEventEnabled(true)
	self._proxy = CCBProxy:create()
	self._rootnode = {}
	local winSize, nodePos, bScroll
	if refineInfo and refineInfo.arr_jiban then
		winSize = cc.size(display.width, display.height - 30)
		nodePos = cc.p(display.cx, 0)
		bScroll = true
	else
		winSize = cc.size(display.width, 760)
		nodePos = ccp(display.cx, display.cy - winSize.height / 2)
		bScroll = false
	end
	local bgNode = CCBuilderReaderLoad("skill/skill_info.ccbi", self._proxy, self._rootnode, self, winSize)
	self:addChild(bgNode, 1)
	bgNode:setPosition(nodePos)
	self._rootnode.changeBtn:setVisible(false)
	self._rootnode.takeOffBtn:setVisible(false)
	self._rootnode.xiLianBtn:setVisible(false)
	self._rootnode.qiangHuBtn:setVisible(false)
	self._rootnode.confirmBtn:setVisible(true)
	
	local function closeFunc()
		PostNotice(NoticeKey.REMOVE_TUTOLAYER)
		self:removeSelf()
		if _confirmListen ~= nil then
			_confirmListen()
		else
			self:removeSelf()
		end
	end
	
	--关闭
	self._rootnode.closeBtn:setVisible(true)
	self._rootnode.closeBtn:addHandleOfControlEvent(function(eventName, sender)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		closeFunc()
	end,
	CCControlEventTouchUpInside)
	
	--确认
	self._rootnode.confirmBtn:addHandleOfControlEvent(function(eventName, sender)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		closeFunc()
	end,
	CCControlEventTouchUpInside)
	
	local infoNode = CCBuilderReaderLoad("skill/skill_detail.ccbi", self._proxy, self._rootnode, self, CCSizeMake(winSize.width, winSize.height - 2 - 85 - 68))
	infoNode:setPosition(cc.p(0, 85))
	bgNode:addChild(infoNode)
	self._rootnode.scrollView:setTouchEnabled(bScroll)
	self._rootnode.titleLabel:setString(common:getLanguageString("@KungfuInfo"))
	self._rootnode.itemNameLabel:setString(_baseInfo.name)
	self._rootnode.itemNameLabel:setColor(NAME_COLOR[_baseInfo.quality])
	self._rootnode.descLabel:setString(_baseInfo.describe)
	self._rootnode.cardName:setString(_baseInfo.name)
	for i = 1, _baseInfo.quality do
		self._rootnode[string.format("star%d", i)]:setVisible(true)
	end
	self._rootnode.cardImageBg:setDisplayFrame(display.newSpriteFrame(string.format("item_card_bg_%d.png", _baseInfo.quality)))
	local path = ResMgr.getLargeImage(_baseInfo.bicon, ResMgr.EQUIP)
	self._rootnode.skillImage:setDisplayFrame(display.newSprite(path):getDisplayFrame())
	local function refresh()
		self._rootnode.curLvLabel:setString(_level)
		alignNodesOneByOne(self._rootnode.levellabel, self._rootnode.curLvLabel)
		if _baseInfo.arr_nature ~= nil then
			for k, v in ipairs(_baseInfo.arr_nature) do
				local nature = data_item_nature[v]
				local str = nature.nature
				if nature.type == 1 then
					str = string.format("+%.2f", _baseInfo.arr_value[k])
				else
					str = string.format("+%.2f%%", _baseInfo.arr_value[k] / 100)
				end
				self._rootnode["basePropLabel_" .. tostring(k)]:setString(str)
				self._rootnode["stateName" .. tostring(k)]:setString(nature.nature .. tostring("："))
				alignNodesOneByOne(self._rootnode["stateName" .. tostring(k)], self._rootnode["basePropLabel_" .. tostring(k)])
			end
		end
		if refineInfo and refineInfo.arr_nature1 then
			for k, v in ipairs(refineInfo.arr_nature1) do
				local proName = string.format("lockPropLabel_%d", k)
				if _level >= refineInfo.arr_level[k] then
					self._rootnode[proName]:setColor(FONT_COLOR.PURPLE)
				end
			end
		else
			self._rootnode.lockPropLabel_1:setVisible(true)
		end
	end
	if refineInfo and refineInfo.arr_nature1 then
		for k, v in ipairs(refineInfo.arr_nature1) do
			local nature = data_item_nature[v]
			local str = nature.nature
			if nature.type == 1 then
				str = str .. ": +" .. tostring(refineInfo.arr_value1[k])
			else
				str = str .. string.format(": +%d%%", refineInfo.arr_value1[k] / 100)
			end
			str = str .. "(" .. refineInfo.arr_level[k] .. common:getLanguageString("@jiesuo")
			if refineInfo.arr_level[k] <= data_shangxiansheding_shangxiansheding[8].level then
				local proName = string.format("lockPropLabel_%d", k)
				self._rootnode[proName]:setString(str)
				self._rootnode[proName]:setVisible(true)
				if _level >= refineInfo.arr_level[k] then
					self._rootnode[proName]:setColor(FONT_COLOR.PURPLE)
				end
			end
		end
	else
		self._rootnode.lockPropLabel_1:setVisible(true)
	end
	local height = self._rootnode.jiBanNode:getContentSize().height + 50
	if refineInfo and refineInfo.arr_jiban ~= nil then
		for k, v in ipairs(refineInfo.arr_jiban) do
			if refineInfo.arr_card[k] then
				local item = Item.new(refineInfo.arr_card[k], data_jiban_jiban[v])
				height = height + item:getContentSize().height
				item:setPosition(self._rootnode.contentView:getContentSize().width / 2, -(k - 1) * item:getContentSize().height - self._rootnode.jiBanNode:getContentSize().height - 30)
				self._rootnode.contentView:addChild(item, 1)
			else
				__G__TRACKBACK__(string.format("please check arr_jiban and arr_card: sikllid = %d", _id))
			end
		end
		local jbNode = CCBuilderReaderLoad("skill/skill_jiban_bg.ccbi", self._proxy, self._rootnode, self, CCSizeMake(winSize.width, height - self._rootnode.jiBanNode:getContentSize().height + 10))
		jbNode:setPosition(cc.p(display.cx, -self._rootnode.jiBanNode:getContentSize().height + 15))
		self._rootnode.contentView:addChild(jbNode, 0)
	else
		self._rootnode.jiBanNode:setVisible(false)
	end
	local sz = cc.size(self._rootnode.contentView:getContentSize().width, self._rootnode.contentView:getContentSize().height + height)
	self._rootnode.descView:setContentSize(sz)
	self._rootnode.contentView:setPosition(cc.p(sz.width / 2, sz.height))
	self._rootnode.scrollView:updateInset()
	self._rootnode.scrollView:setContentOffset(cc.p(0, -sz.height + self._rootnode.scrollView:getViewSize().height), false)
	refresh()
end

function DuobaoItemInfoLayer:onEnter()
	TutoMgr.addBtn("hecheng_congfirm_btn", self._rootnode.confirmBtn)
	TutoMgr.active()
end

function DuobaoItemInfoLayer:onExit()
	TutoMgr.removeBtn("hecheng_congfirm_btn")
end

return DuobaoItemInfoLayer