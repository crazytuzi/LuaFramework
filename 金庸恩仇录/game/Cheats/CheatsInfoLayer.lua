local data_item_nature = require("data.data_item_nature")
local data_talent_talent = require("data.data_talent_talent")
local data_jiban_jiban = require("data.data_jiban_jiban")
local data_battleskill_battleskill = require("data.data_battleskill_battleskill")
local data_shentong_shentong = require("data.data_shentong_shentong")
local data_cheats_cheats = require("data.data_miji_miji")
require("utility.richtext.richText")
require("data.data_langinfo")

local ST_COLOR = {
cc.c3b(255, 38, 0),
cc.c3b(43, 164, 45),
cc.c3b(28, 94, 171),
cc.c3b(218, 129, 29)
}

local ResShenTongCost = 50

local CheatsInfoLayer = class("CheatsInfoLayer", function()
	return require("utility.ShadeLayer").new(cc.c4b(100, 100, 100, 0))
end)

local DesignSize = {
ST = cc.size(display.width, 80),
JN = cc.size(display.width, 55),
JB = cc.size(display.width, 55),
JJ = cc.size(display.width, 200),
LY = cc.size(display.width, 100)
}

local CheatsJNItem = class("CheatsJNItem", function(t)
	local height = 5
	local nodes = {}
	for k, v in ipairs(t) do
		local htmlText = "<font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#ac07bb\">       %s(%s5)</font></br><font size=\"22\" color=\"#563b20\">%s</font>"
		local infoNode = getRichText(string.format(htmlText, v.data.name, tostring(v.ceng) .. "#8260;", v.data.desc), display.width * 0.9, nil, 5)
		table.insert(nodes, infoNode)
		infoNode.type = nil
		height = height + infoNode:getContentSize().height + 10
	end
	local proxy = CCBProxy:create()
	local rootnode = {}
	local node = CCBuilderReaderLoad("hero/cheats_skill_item.ccbi", proxy, rootnode, display.newNode(), cc.size(DesignSize.JN.width, DesignSize.JN.height + height))
	height = 0
	for i = #nodes, 1, -1 do
		local icon = display.newSprite(string.format("#heroinfo_cheats_%d.png", nodes[i].type or 2))
		icon:setPosition(30 + icon:getContentSize().width / 2, nodes[i]:getContentSize().height + height - 10 + icon:getContentSize().height / 2)
		node:addChild(icon)
		nodes[i]:setPosition(30, nodes[i]:getContentSize().height + height - 8)
		node:addChild(nodes[i])
		height = nodes[i]:getContentSize().height + height + 5
	end
	return node
end)

local CheatsSTItem = class("CheatsSTItem", function(t)
	local height = 0
	local nodes = {}
	local rootnode = {}
	local proxy = CCBProxy:create()
	for k, v in ipairs(t) do
		rootnode = {}
		local infoSize
		if string.utf8len(v.info.type) > 38 then
			infoSize = cc.size(display.width, 105)
		elseif string.utf8len(v.info.type) > 18 then
			infoSize = cc.size(display.width, 76)
		else
			infoSize = cc.size(display.width, 60)
		end
		local infoNode = CCBuilderReaderLoad("hero/hero_shentong_info.ccbi", proxy, rootnode, display.newNode(), infoSize)
		local tmpLv = v.lv
		if k == #t then
			rootnode.lineSprite:setVisible(false)
		end
		rootnode.descLabel:setDimensions(cc.size(infoNode:getContentSize().width * 0.95, rootnode.descLabel:getDimensions().height))
		rootnode.descLabel:setString(v.info.type)
		rootnode.xiaohaoNode:setVisible(false)
		table.insert(nodes, infoNode)
		height = height + infoNode:getContentSize().height
		if t.cls == 0 or v.lv <= #v.map.arr_point and v.map.arr_cond[v.lv] > t.cls then
			if t.cls == 0 then
				rootnode.nameItemName:setColor(cc.c3b(119, 119, 119))
				rootnode.descLabel:setColor(cc.c3b(119, 119, 119))
			else
				if v.map then
					rootnode.nameItemName:setColor(ST_COLOR[v.map.type])
				end
				rootnode.descLabel:setColor(cc.c3b(86, 59, 32))
			end
			rootnode.nameItemName:setString(string.format("%s(%d/%d)", v.info.name, v.lv, #v.map.arr_cond))
		else
			if tmpLv == 0 then
				tmpLv = 1
			end
			rootnode.nameItemName:setString(string.format("%s(%d/%d)", v.info.name, tmpLv, #v.map.arr_cond))
			if v.map then
				rootnode.nameItemName:setColor(ST_COLOR[v.map.type])
			end
			rootnode.descLabel:setColor(cc.c3b(86, 59, 32))
		end
	end
	local node = CCBuilderReaderLoad("hero/cheats_shentong_item.ccbi", proxy, rootnode, display.newNode(), cc.size(DesignSize.ST.width, DesignSize.ST.height + height))
	height = 0
	for i = #nodes, 1, -1 do
		height = nodes[i]:getContentSize().height + height + 5
		nodes[i]:setPosition(node:getContentSize().width / 2, height)
		node:addChild(nodes[i])
	end
	return node
end)

local JJItem = class("JJItem", function(str)
	local proxy = CCBProxy:create()
	local rootnode = {}
	local num = math.ceil(string.utf8len(str) / 26)
	local sz = cc.size(DesignSize.LY.width, num * 30 + 60)
	local node = CCBuilderReaderLoad("hero/hero_intr_item.ccbi", proxy, rootnode, display.newNode(), sz)
	rootnode.descLabel:setDimensions(cc.size(node:getContentSize().width * 0.9, 100))
	rootnode.descLabel:setString(str)
	return node
end)

local LYItem = class("LYItem", function(str)
	local proxy = CCBProxy:create()
	local rootnode = {}
	local num = math.ceil(string.utf8len(str) / 26)
	local sz = cc.size(DesignSize.LY.width, num * 30 + 60)
	local node = CCBuilderReaderLoad("hero/hero_intr_item.ccbi", proxy, rootnode, display.newNode(), sz)
	rootnode.intr_title:setString(common:getLanguageString("@AchieveAcess"))
	rootnode.descLabel:setString(str)
	return node
end)

function CheatsInfoLayer:ctor(param, infoType)
	self._onData = param.onData or nil
	self:setNodeEventEnabled(true)
	self.listener = param.listener
	self.closeListener = param.closeListener
	self.info = param.info
	self._bak_info = param.info and param.info.data
	self.enemy = param.enemy or nil
	local cheatsData
	if param.enemy ~= nil and param.enemy == true then
		cheatsData = param.info.data
	elseif param.id then
		self.objID = param.id
		cheatsData = CheatsModel.getCheatsByObjId(param.id)
		--cheatsData.props = CheatsModel.getCheatsProps(cheatsData.resId, cheatsData.floor, cheatsData.level)
	else
		cheatsData = CheatsModel.getInitCheatsDataById(param.resId)
	end
	self.resId = cheatsData.resId
	self._detailInfo = cheatsData
	local _baseInfo = ResMgr.getCheatsData(cheatsData.resId)
	self._proxy = CCBProxy:create()
	self._rootnode = {}
	local bgHeight = display.height
	self.needUpdate = false
	local bgNode = CCBuilderReaderLoad("cheats/cheats_info.ccbi", self._proxy, self._rootnode, self, cc.size(display.width, bgHeight - 30))
	self:addChild(bgNode, 1)
	local infoNode = CCBuilderReaderLoad("cheats/cheats_info_detail.ccbi", self._proxy, self._rootnode, self, cc.size(display.width, bgHeight - 30 - 85 - 68))
	infoNode:setPosition(cc.p(0, 85))
	bgNode:addChild(infoNode)
	self.cheatsSize = self._rootnode.tag_card_bg:getContentSize()
	self.cheatsSize.width = self.cheatsSize.width * self._rootnode.tag_card_bg:getScaleX()
	self.cheatsSize.height = self.cheatsSize.height * self._rootnode.tag_card_bg:getScaleY()
	self._rootnode.bottomMenuNode:setZOrder(1)
	
	local heroNameLabel = ui.newTTFLabelWithShadow({
	text = "",
	font = FONTS_NAME.font_haibao,
	align = ui.TEXT_ALIGN_CENTER,
	size = 28,
	shadowColor = display.COLOR_BLACK,
	})
	
	ResMgr.replaceKeyLable(heroNameLabel, self._rootnode.itemNameLabel, 0, 0)
	heroNameLabel:align(display.CENTER)
	
	local clsLabel = ui.newTTFLabelWithShadow({
	text = "",
	font = FONTS_NAME.font_haibao,
	color = cc.c3b(46, 194, 49),
	shadowColor = display.COLOR_BLACK,
	size = 28
	})
	
	ResMgr.replaceKeyLable(clsLabel, self._rootnode.itemNameLabel, 0, 0)
	clsLabel:align(display.LEFT_CENTER)
	
	local _index = param.index
	display.addSpriteFramesWithFile("ui_zhenrong.plist", "ui_zhenrong.png")
	local pt = self._rootnode.scrollView:convertToWorldSpace(cc.p(0, 0))
	local _changeHeroListener = param.changeHero
	local _refreshHeroListener = param.refreshHero
	self.infoType = infoType
	--1:换装
	--2:进阶
	--3:普通查看界面	
	if infoType == 2 then
		self._rootnode.changeBtn:setVisible(false)
		self._rootnode.takeOffBtn:setVisible(false)
		self.removeListener = param.removeListener
	elseif infoType == 3 then
		self._rootnode.changeBtn:setVisible(false)
		self._rootnode.takeOffBtn:setVisible(false)
		self._rootnode.jinJieBtn:setVisible(false)
	else
		self._rootnode.changeBtn:setVisible(true)
		self._rootnode.takeOffBtn:setVisible(true)
	end
	
	self._rootnode.titleLabel:setString(common:getLanguageString("@CheatsInfo"))
	
	function self.refresh(_)
		self._rootnode.contentViewNode:removeAllChildrenWithCleanup(true)
		if self.infoType ~= 3 and (self.enemy == nil or self.enemy == false) then
			local cheatsData = CheatsModel.getCheatsByObjId(self.objID)
			--cheatsData.props = CheatsModel.getCheatsProps(cheatsData.resId, cheatsData.floor, cheatsData.level)
			self._detailInfo = cheatsData
		end
		local nameText = _baseInfo.name
		heroNameLabel:setString(nameText)
		heroNameLabel:setColor(NAME_COLOR[_baseInfo.quality])
		if self._detailInfo.floor > 0 then
			clsLabel:setString(string.format("+%d", self._detailInfo.floor))
			clsLabel:setPositionX(heroNameLabel:getPositionX() + heroNameLabel:getContentSize().width/2)
		end
		self._rootnode.tag_card_bg:setDisplayFrame(display.newSprite("#card_ui_bg_" .. _baseInfo.quality .. ".png"):getDisplayFrame())
		local a = _baseInfo.quality
		for i = 1, _baseInfo.quality do
			self._rootnode["star" .. i]:setVisible(true)
		end
		
		self._rootnode.curFloorLabel:setString(tostring(self._detailInfo.floor))
		self._rootnode.maxFloorLabel:setString(tostring(_baseInfo.height))
		self._rootnode.curProLabel:setString(tostring(self._detailInfo.level))
		self._rootnode.maxProLabel:setString(tostring(_baseInfo.number))
		local index = 0
		
		if self._detailInfo.props ~= nil and 0 < #self._detailInfo.props then
			for i, v in ipairs(self._detailInfo.props) do
				index = index + 1
				self._rootnode["pro_name_" .. index]:setString(data_item_nature[v.idx].nature .. "：")
				local value = "+ " .. v.val
				if data_item_nature[v.idx].type == 2 then
					value = string.format("+ %.0f%%", v.val / 100)
				end
				self._rootnode["pro_value_" .. index]:setString(value)
				self._rootnode["pro_name_" .. index]:setVisible(true)
				self._rootnode["pro_value_" .. index]:setVisible(true)
			end
		end
		
		for i = index + 1, 8 do
			self._rootnode["pro_name_" .. i]:setVisible(false)
			self._rootnode["pro_value_" .. i]:setVisible(false)
		end
		local heroImg = _baseInfo.body
		local heroPath = CCFileUtils:sharedFileUtils():fullPathForFilename(ResMgr.getLargeImage(heroImg, ResMgr.CHEATS))
		self._rootnode.heroImage:setDisplayFrame(display.newSprite(heroPath):getDisplayFrame())
		local imageSize = self._rootnode.heroImage:getContentSize()
		local scale = 1
		if imageSize.width > self.cheatsSize.width or imageSize.height > self.cheatsSize.height then
			scale = math.min(self.cheatsSize.width / imageSize.width, self.cheatsSize.height / imageSize.height)
		end
		self._rootnode.heroImage:setScale(scale)
		local height = 0
		
		--技能
		
		local function addCheatsJNItem(cheatsInfo)
			local cheats_t = {}
			local floor = self._detailInfo.floor
			if cheatsInfo ~= nil then
				table.insert(cheats_t, {
				ceng = floor,
				data = data_battleskill_battleskill[data_cheats_cheats[cheatsInfo.resId].skill[floor]]
				})
			end
			if #cheats_t > 0 then
				local cheatsJNItem = CheatsJNItem.new(cheats_t)
				cheatsJNItem:setPosition(self._rootnode.contentView:getContentSize().width / 2, -height + 40)
				self._rootnode.contentViewNode:addChild(cheatsJNItem)
				height = height + cheatsJNItem:getContentSize().height + 2
			end
		end
		
		--神通
		
		local function addCheatsSTItem(info)
			local st = {}
			local floor = self._detailInfo.floor
			local stId = data_shentong_shentong[data_cheats_cheats[info.resId].skill[1]].arr_talent[floor]
			local stData = data_shentong_shentong[data_talent_talent[stId].shentong]
			local t = {
			info = data_talent_talent[stId],
			map = stData,
			lv = floor
			}
			table.insert(st, t)
			st.cls = self._detailInfo.cls or floor
			local item = CheatsSTItem.new(st)
			item:setPosition(self._rootnode.contentView:getContentSize().width / 2, -height + 40)
			self._rootnode.contentViewNode:addChild(item)
			height = height + item:getContentSize().height + 2
		end
		
		--简介
		
		local function addJJItem(str)
			local item = JJItem.new(str)
			item:setPosition(self._rootnode.contentView:getContentSize().width / 2, -height + 40)
			self._rootnode.contentViewNode:addChild(item)
			height = height + item:getContentSize().height + 2
		end
		
		--获取途径
		local function addLYItem(str)
			if not str then
				return
			end
			local item = LYItem.new(str)
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
		
		if _baseInfo.type == 1 then
			addCheatsSTItem(_baseInfo)
		else
			addCheatsJNItem(_baseInfo)
		end
		
		addJJItem(_baseInfo.attribute)
		addLYItem(_baseInfo.dropText)
		resizeContent()
	end
	
	local getIndexById = function(id)
		for k, v in ipairs(game.player:getSkills()) do
			if v._id == id then
				return k
			end
		end
	end
	
	local function close()
		if self.closeListener ~= nil then
			self.closeListener()
		end
		if self.removeListener ~= nil then
			self.removeListener()
		end
		if self.listener then
			self.listener(nil)
		end
		self:removeSelf()
	end
	
	local function jinJie()
		if self._detailInfo.floor == data_cheats_cheats[self.resId].height and data_cheats_cheats[self.resId].number == self._detailInfo.level then
			ResMgr.showErr(2200003)
			return
		end
		local jinJieLayer = require("game.Cheats.CheatsJinJie").new({
		id = self.objID,
		removeListener = function()
			self:refresh()
		end
		})
		game.runningScene:addChild(jinJieLayer, 1000)
	end
	
	local function change()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		CCDirector:sharedDirector():popToRootScene()
		push_scene(require("game.form.CheatsChooseScene").new({
		index = self.info.index,
		onData = self._onData,
		subIndex = self.info.subIndex,
		resId = self.info.resId,
		cid = self.info.cid,
		callback = function(data)
			if self.listener then
				self.listener(data)
			end
			self:removeSelf()
		end
		}))
	end
	
	local function takeOff()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		RequestHelper.formation.putOnCheats({
		pos = self.info.index,
		subpos = self.info.subIndex,
		callback = function(data)
			if string.len(data["0"]) > 0 then
				show_tip_label(data["0"])
			else
				self._bak_info.pos = 0
				self._bak_info.cid = 0
				if self.listener then
					self.listener(data)
				end
				self:removeSelf()
			end
		end
		})
	end
	
	resetbtn(self._rootnode.closeBtn, bgNode, 1)
	self._rootnode.closeBtn:setVisible(true)
	self._rootnode.closeBtn:addHandleOfControlEvent(close, CCControlEventTouchUpInside)
	self._rootnode.changeBtn:addHandleOfControlEvent(change, CCControlEventTouchUpInside)
	self._rootnode.takeOffBtn:addHandleOfControlEvent(takeOff, CCControlEventTouchUpInside)
	self._rootnode.jinJieBtn:addHandleOfControlEvent(jinJie, CCControlEventTouchUpInside)
	self._info = _info
	self:refresh()
	local touchMaskLayer = require("utility.TouchMaskLayer").new({
	btns = {
	self._rootnode.jinJieBtn,
	self._rootnode.changeBtn,
	self._rootnode.takeOffBtn,
	self._rootnode.closeBtn
	},
	contents = {
	cc.rect(0, 81, self._rootnode.descView:getContentSize().width, self._rootnode.descView:getContentSize().height)
	}
	})
	self:addChild(touchMaskLayer, 100)
end

function CheatsInfoLayer:onExit()
end

return CheatsInfoLayer