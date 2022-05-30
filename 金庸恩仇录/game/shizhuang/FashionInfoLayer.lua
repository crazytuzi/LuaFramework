local data_talent_talent = require("data.data_talent_talent")
local data_jiban_jiban = require("data.data_jiban_jiban")
local data_battleskill_battleskill = require("data.data_battleskill_battleskill")
local data_shentong_shentong = require("data.data_shentong_shentong")
local data_fashion_fashion = require("data.data_fashion_fashion")
local data_item_item = require("data.data_item_item")

require("utility.richtext.richText")
require("data.data_langinfo")

local ST_COLOR = {
cc.c3b(255, 38, 0),
cc.c3b(43, 164, 45),
cc.c3b(28, 94, 171),
cc.c3b(218, 129, 29)
}

local ResShenTongCost = 50

local FashionInfoLayer = class("FashionInfoLayer", function()
	return require("utility.ShadeLayer").new(cc.c4b(100, 100, 100, 0))
end)

local DesignSize = {
ST = cc.size(display.width, 80),
JN = cc.size(display.width, 55),
JJ = cc.size(display.width, 150)
}

local STItem = class("STItem", function(t, btnEnable)
	local height = 0
	local nodes = {}
	local rootnode = {}
	local proxy = CCBProxy:create()
	for k, v in ipairs(t) do
		rootnode = {}
		local infoSize
		if string.utf8len(v.info.type) > 38 then
			infoSize = cc.size(display.width, 125)
		elseif string.utf8len(v.info.type) > 18 then
			infoSize = cc.size(display.width, 96)
		else
			infoSize = cc.size(display.width, 80)
		end
		local infoNode = CCBuilderReaderLoad("hero/hero_shentong_info.ccbi", proxy, rootnode, display.newNode(), infoSize)
		rootnode.nameItemName:setString(string.format("%s(%d/%d)", v.info.name, v.lv, #v.map.arr_talent))
		rootnode.descLabel:setDimensions(cc.size(infoNode:getContentSize().width * 0.95, rootnode.descLabel:getDimensions().height))
		rootnode.descLabel:setString(v.info.type)
		if v.lockLevel then
			local text = "(" .. v.lockLevel .. common:getLanguageString("@jiesuo")
			local title_color = cc.c3b(119, 119, 119)
			local lockLable = ui.newTTFLabel({
			text = text,
			size = 22,
			font = FONTS_NAME.font_fzcy,
			align = ui.TEXT_ALIGN_LEFT,
			color = title_color
			})
			
			local labelSize = rootnode.nameItemName:getContentSize()
			ResMgr.replaceKeyLable(lockLable, rootnode.nameItemName, labelSize.width + 4, 0)
			lockLable:align(display.LEFT_CENTER)
			
			if not btnEnable then
				title_color = cc.c3b(86, 59, 32)
			else
				rootnode.nameItemName:setColor(title_color)
			end
			rootnode.descLabel:setColor(title_color)
		else
			rootnode.descLabel:setColor(cc.c3b(86, 59, 32))
		end
		rootnode.xiaohaoNode:setVisible(false)
		height = height + infoNode:getContentSize().height
		if k == #t then
			rootnode.lineSprite:setVisible(false)
		end
		table.insert(nodes, infoNode)
	end
	rootnode = {}
	local node = CCBuilderReaderLoad("hero/hero_shentong_item.ccbi", proxy, rootnode, display.newNode(), cc.size(DesignSize.ST.width, DesignSize.ST.height + height + 10))
	rootnode.item_board_icon:setVisible(false)
	height = 0
	for i = #nodes, 1, -1 do
		height = nodes[i]:getContentSize().height + height + 5
		nodes[i]:setPosition(node:getContentSize().width / 2, height)
		node:addChild(nodes[i])
	end
	return node
end)

local JNItem = class("JNItem", function(t, btnEnable)
	local height = 0
	local nodes = {}
	for k, v in ipairs(t) do
		local htmlText = "<font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#ac07bb\">%s  </font><font size=\"22\" color=\"%s</font>"
		local lockText = "#563b20\">" .. v.info.desc
		if v.lockLevel then
			if not btnEnable then
				lockText = "#777777\">(" .. v.lockLevel .. common:getLanguageString("@jiesuo") .. "</font><font size=\"22\" color=\"#563b20\">" .. v.info.desc
			else
				lockText = "#777777\">(" .. v.lockLevel .. common:getLanguageString("@jiesuo") .. " " .. v.info.desc
			end
		end
		local infoNode = getRichText(string.format(htmlText, v.info.name, lockText), display.width * 0.9 - 30)
		table.insert(nodes, infoNode)
		infoNode.type = v.t
		height = height + infoNode:getContentSize().height + 10
	end
	local proxy = CCBProxy:create()
	local rootnode = {}
	local node = CCBuilderReaderLoad("hero/hero_skill_item.ccbi", proxy, rootnode, display.newNode(), cc.size(DesignSize.JN.width, DesignSize.JN.height + height))
	height = 0
	for i = #nodes, 1, -1 do
		local icon = display.newSprite(string.format("#heroinfo_skill_%d.png", nodes[i].type or 1))
		icon:setPosition(30 + icon:getContentSize().width / 2, nodes[i]:getContentSize().height + height - 10 + icon:getContentSize().height / 2)
		node:addChild(icon)
		nodes[i]:setPosition(30 + icon:getContentSize().width, nodes[i]:getContentSize().height + height - 8)
		node:addChild(nodes[i])
		height = nodes[i]:getContentSize().height + height + 5
	end
	return node
end)

local JJItem = class("JJItem", function(str)
	local proxy = CCBProxy:create()
	local rootnode = {}
	local sz = DesignSize.JJ
	if string.utf8len(str) / 28 > 3 then
		sz = cc.size(DesignSize.JJ.width, DesignSize.JJ.height + 15)
	elseif string.utf8len(str) / 28 < 2 then
		sz = cc.size(DesignSize.JJ.width, DesignSize.JJ.height - 20)
	end
	local node = CCBuilderReaderLoad("hero/hero_intr_item.ccbi", proxy, rootnode, display.newNode(), sz)
	rootnode.descLabel:setString(str)
	return node
end)

function FashionInfoLayer:ctor(param, infoType)
	dump(param)
	self:setNodeEventEnabled(true)
	self.removeListener = param.removeListener
	self.changeListener = param.changeListener
	self._proxy = CCBProxy:create()
	self._rootnode = {}
	self._mCurNum = param.curNum
	self._mLimitNum = param.limitNum
	local bgHeight = display.height
	local bgNode = CCBuilderReaderLoad("equip/equip_comon_info.ccbi", self._proxy, self._rootnode, self, cc.size(display.width, bgHeight - 30))
	self:addChild(bgNode, 1)
	bgNode:setPosition(display.cx, (bgHeight - bgNode:getContentSize().height) / 2)
	local infoNode = CCBuilderReaderLoad("hero/hero_info_detail.ccbi", self._proxy, self._rootnode, self, cc.size(display.width, bgHeight - 32 - 85 - 68))
	infoNode:setPosition(cc.p(0, 85))
	bgNode:addChild(infoNode)
	self._rootnode.baseProp_3:setVisible(false)
	self._rootnode.baseProp_4:setVisible(false)
	self._rootnode.shizhuang_node:setVisible(true)
	local fashionNameLabel = ui.newTTFLabelWithShadow({
	text = "",
	size = 28,
	font = FONTS_NAME.font_haibao,
	align = ui.TEXT_ALIGN_CENTER,
	color = FONT_COLOR.WHITE,
	shadowColor = FONT_COLOR.BLACK,
	})
	
	ResMgr.replaceKeyLableEx(fashionNameLabel, self._rootnode, "itemNameLabel", 0, 0)
	fashionNameLabel:align(display.CENTER)
	
	self.hasQH = false
	self.timeNode = CCNode:create()
	self:addChild(self.timeNode)
	local _index = param.index
	display.addSpriteFramesWithFile("ui_zhenrong.plist", "ui_zhenrong.png")
	local pt = self._rootnode.scrollView:convertToWorldSpace(cc.p(0, 0))
	self.infoType = infoType
	self._rootnode.xiLianBtn:setVisible(false)
	if infoType == 1 then
		self._rootnode.changeBtn:setVisible(true)
		self._rootnode.takeOffBtn:setVisible(true)
		self._rootnode.qiangHuBtn:setVisible(true)
	elseif infoType == 2 then
		self._rootnode.changeBtn:setVisible(false)
		self._rootnode.takeOffBtn:setVisible(false)
		self._rootnode.qiangHuBtn:setVisible(true)
	else
		self._rootnode.changeBtn:setVisible(false)
		self._rootnode.takeOffBtn:setVisible(false)
		self._rootnode.qiangHuBtn:setVisible(false)
	end
	self._rootnode.titleLabel:setString(common:getLanguageString("@shizhuang") .. common:getLanguageString("@xinxi"))
	resetbtn(self._rootnode.closeBtn, bgNode, 1)
	
	local function close()
		dump("close")
		if self.hasQH and self.changeListener then
			self.changeListener(true)
		elseif self.removeListener then
			self.removeListener()
		end
		self:removeSelf()
	end
	self._rootnode.closeBtn:addHandleOfControlEvent(close, CCControlEventTouchUpInside)
	
	--更换时装
	local function change()
		push_scene(require("game.form.FormChooseFashionScene").new({
		callback = function(data)
			self:removeSelf()
		end
		}))
	end
	self._rootnode.changeBtn:addHandleOfControlEvent(change, CCControlEventTouchUpInside)
	
	--卸下时装
	local function takeOff()
		dump("takeOff")
		FashionModel.fashionInstall(1, 0, 0, function(data)
			if self.changeListener then
				self.changeListener(true)
			end
			self:removeSelf()
		end)
	end
	self._rootnode.takeOffBtn:addHandleOfControlEvent(takeOff, CCControlEventTouchUpInside)
	
	local function qiangHua()
		if self._info.maxLevel <= self._info.level then
			show_tip_label(common:getLanguageString("@sz_yijingdingji"))
			return
		end
		local function callback(idx, fashionInfo, sliver, cyls_num)
			for k, v in pairs(fashionInfo) do
				self._info[k] = v
			end
			FashionModel.setCylsNum(cyls_num)
			self.hasQH = true
		end
		local qianghuaLayer = require("game.shizhuang.SZQiangHuaLayer").new({
		idx = 0,
		data = self._info,
		cyls_num = FashionModel.getCylsNum(),
		cb = callback,
		closeFunc = function(hasQH)
			if hasQH then
				self:refreshFashionInfo()
			end
		end
		})
		game.runningScene:addChild(qianghuaLayer, 1000)
	end
	self._rootnode.qiangHuBtn:addHandleOfControlEvent(qiangHua, CCControlEventTouchUpInside)
	self._info = param.info
	dump(self._info)
	self:refreshFashionInfo()
end

function FashionInfoLayer:updateExternLabel()
	self.timeNode:stopAllActions()
	local function update(dt)
		self._info.endTime = self._info.endTime - 1
		if self._info.endTime <= 0 then
			self._rootnode.fashion_extern_level:setString(common:getLanguageString("@sz_timeout"))
			self.timeNode:stopAllActions()
		else
			dump(self._info.endTime, "endTime is: ")
			local times = format_time(self._info.endTime)
			self._rootnode.fashion_extern_level:setString(times)
		end
	end
	local fashionData = ResMgr.getFashionData(self._info.resId)
	if self._info.lastOverTime == nil or self._info.lastOverTime == -1 then
		self._rootnode.fashion_extern_text:setString(common:getLanguageString("@fashionJianghuStar"))
		self._rootnode.fashion_extern_level:setString(fashionData.star)
	else
		self._rootnode.fashion_extern_text:setString(common:getLanguageString("@LeftTime") .. ":")
		self._info.endTime = GameModel.getRestTimeInSec(self._info.lastOverTime)
		local times = format_time(self._info.endTime)
		self._rootnode.fashion_extern_level:setString(times)
		self.timeNode:schedule(update, 1)
	end
end

function FashionInfoLayer:refreshFashionInfo()
	self._rootnode.contentViewNode:removeAllChildrenWithCleanup(true)
	local fashionData = data_item_item[self._info.resId]
	self._rootnode.itemNameLabel:setString(fashionData.name)
	self._rootnode.itemNameLabel:setColor(NAME_COLOR[fashionData.quality])
	if self._mCurNum and self._mLimitNum then
		self._rootnode.curNum:setString(tostring(self._mCurNum))
		self._rootnode.maxNum:setString("/" .. tostring(self._mLimitNum))
		self._rootnode.progressNode:setVisible(true)
		self._rootnode.progressNode:setPositionX(self._rootnode.itemNameLabel:getPositionX())
	else
		self._rootnode.progressNode:setVisible(false)
	end
	
	local maxLevel = game.player.getLevel()
	if self._info.lastOverTime and self._info.lastOverTime ~= -1 then
		maxLevel = self._info.level
		self._rootnode.qiangHuBtn:setVisible(false)
	end
	
	self._info.maxLevel = maxLevel
	self._rootnode.curLevalLabel:setString(tostring(self._info.level))
	self._rootnode.maxLevalLabel:setString(tostring(maxLevel))
	
	for i = 1, 3 do
		self._rootnode["nbPropLabel_" .. i]:setString(fashionData.arr_value[i])
	end
	
	self._rootnode.basePropLabel_1:setString(fashionData.arr_value[4] + fashionData.arr_addition[4] * self._info.level)
	self._rootnode.basePropLabel_2:setString(fashionData.arr_value[5] + fashionData.arr_addition[5] * self._info.level)
	self:updateExternLabel()
	self._rootnode.tag_card_bg:setDisplayFrame(display.newSprite("#card_ui_bg_" .. fashionData.quality .. ".png"):getDisplayFrame())
	for i = 1, fashionData.quality do
		self._rootnode["star" .. i]:setVisible(true)
	end
	local heroFrame = ResMgr.getHeroFrame(game.player.getGender(), 0, self._info.resId)
	self._rootnode.heroImage:setDisplayFrame(heroFrame)
	local height = 0
	local function addSTItem()
		local item
		local st = {}
		for k, v in ipairs(fashionData.talent) do
			local stData = data_shentong_shentong[v]
			local t = {
			info = data_talent_talent[stData.arr_talent[5]],
			map = stData,
			lv = 5
			}
			if self._info.level < fashionData.unlocktalent[k] then
				t.lockLevel = fashionData.unlocktalent[k]
			end
			table.insert(st, t)
		end
		st.cls = fashionData.quality
		st.point = 0
		if self.infoType == 3 then
			item = STItem.new(st, false)
		else
			item = STItem.new(st, true)
		end
		height = height + item:getContentSize().height + 2
		item:setPosition(self._rootnode.contentView:getContentSize().width / 2, 40)
		self._rootnode.contentViewNode:addChild(item)
		function self.getUpgradeBtn1()
			return item:getUpgradeBtn1()
		end
		function self.getNumLabel()
			return item:getNumLabel()
		end
	end
	local function addJNItem()
		local t = {}
		local skillTbl = {}
		if fashionData.skill > 0 then
			local lockLevel
			if self._info.level < fashionData.unlockskill then
				lockLevel = fashionData.unlockskill
			end
			table.insert(t, {
			info = data_battleskill_battleskill[fashionData.skill],
			t = 1,
			lockLevel = lockLevel
			})
		end
		if 0 < fashionData.angerSkill then
			local lockLevel
			if self._info.level < fashionData.unlockanger then
				lockLevel = fashionData.unlockanger
			end
			table.insert(t, {
			info = data_battleskill_battleskill[fashionData.angerSkill],
			t = 2,
			lockLevel = lockLevel
			})
		end
		if self.infoType == 3 then
			item = JNItem.new(t, false)
		else
			item = JNItem.new(t, true)
		end
		item:setPosition(self._rootnode.contentView:getContentSize().width / 2, -height + 40)
		self._rootnode.contentViewNode:addChild(item)
		height = height + item:getContentSize().height + 2
	end
	local function addJJItem(str)
		local item = JJItem.new(str)
		item:setPosition(self._rootnode.contentView:getContentSize().width / 2, -height + 40)
		self._rootnode.contentViewNode:addChild(item)
		height = height + item:getContentSize().height + 2
	end
	local function resizeContent()
		local sz = cc.size(self._rootnode.contentView:getContentSize().width, self._rootnode.contentView:getContentSize().height + height - 40)
		self._rootnode.descView:setContentSize(sz)
		self._rootnode.contentView:setPosition(cc.p(sz.width / 2, sz.height))
		self._rootnode.scrollView:updateInset()
		self._rootnode.scrollView:setContentOffset(cc.p(0, -sz.height + self._rootnode.scrollView:getViewSize().height), false)
	end
	addSTItem()
	addJNItem()
	addJJItem(fashionData.describe)
	resizeContent()
end

function FashionInfoLayer:onEnter()
	TutoMgr.active()
end

function FashionInfoLayer:onExit()
end

return FashionInfoLayer