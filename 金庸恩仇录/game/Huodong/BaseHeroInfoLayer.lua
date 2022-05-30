local data_talent_talent = require("data.data_talent_talent")
local data_jiban_jiban = require("data.data_jiban_jiban")
local data_battleskill_battleskill = require("data.data_battleskill_battleskill")
local data_shentong_shentong = require("data.data_shentong_shentong")
local data_item_nature = require("data.data_item_nature")
local data_card_card = require("data.data_card_card")

require("utility.richtext.richText")

local BaseHeroInfoLayer = class("BaseHeroInfoLayer", function()
	return require("utility.ShadeLayer").new(ccc4(0, 0, 0, 0))
end)

local DesignSize = {
ST = cc.size(display.width, 65),
JN = cc.size(display.width, 55),
JB = cc.size(display.width, 55),
JJ = cc.size(display.width, 150),
LY = cc.size(display.width, 100)
}

local STItem = class("STItem", function(t)
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
			infoSize = cc.size(display.width, 70)
		end
		local infoNode = CCBuilderReaderLoad("hero/hero_shentong_info.ccbi", proxy, rootnode, display.newNode(), infoSize)
		rootnode.nameItemName:setString(string.format("%s(%d/%d)", v.info.name, v.lv, #v.map.arr_talent))
		rootnode.descLabel:setDimensions(cc.size(infoNode:getContentSize().width * 0.95, rootnode.descLabel:getDimensions().height))
		rootnode.descLabel:setString(v.info.type)
		rootnode.descLabel:setColor(ccc3(86, 59, 32))
		rootnode.xiaohaoNode:setVisible(false)
		height = height + infoNode:getContentSize().height
		if k == #t then
			rootnode.lineSprite:setVisible(false)
		end
		table.insert(nodes, infoNode)
	end
	rootnode = {}
	local node = CCBuilderReaderLoad("hero/hero_shentong_item.ccbi", proxy, rootnode, display.newNode(), CCSizeMake(DesignSize.ST.width, DesignSize.ST.height + height + 10))
	rootnode.item_board_icon:setVisible(false)
	height = 0
	for i = #nodes, 1, -1 do
		height = nodes[i]:getContentSize().height + height + 5
		nodes[i]:setPosition(node:getContentSize().width / 2, height)
		node:addChild(nodes[i])
	end
	return node
end)

local JNItem = class("JNItem", function(t)
	local height = 0
	local nodes = {}
	for k, v in ipairs(t) do
		local skillInfo = string.format("<font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#ac07bb\">%s  </font><font size=\"22\" color=\"#563b20\">%s</font>", v.info.name, v.info.desc)
		if v.t == 3 and v.groupNeed then
			skillInfo = skillInfo .. "<font size=\"22\" color=\"#2aa42d\">(与" ..data_card_card[v.groupNeed].name .."一同出战)</font>"
		end
		local infoNode = getRichText(skillInfo, display.width * 0.9 - 30)
		table.insert(nodes, infoNode)
		infoNode.type = v.t
		height = height + infoNode:getContentSize().height + 10
	end
	
	local proxy = CCBProxy:create()
	local rootnode = {}
	local node = CCBuilderReaderLoad("hero/hero_skill_item.ccbi", proxy, rootnode, display.newNode(), CCSizeMake(DesignSize.JN.width, DesignSize.JN.height + height))
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

local JBItem = class("JBItem", function(t, relation)
	local height = 0
	local nodes = {}
	for k, v in ipairs(t) do
		if k > 6 then
			return
		end
		local color1 = "777777"
		local color2 = "777777"
		for i, j in ipairs(relation) do
			if v.id == j then
				color1 = "ff6c00"
				color2 = "dd0000"
			end
		end
		local tmpStr = ""
		for i = 1, 3 do
			if v[string.format("nature%d", i)] ~= 0 then
				local nature = data_item_nature[v[string.format("nature%d", i)]]
				if i > 1 and nature.id == 34 then
				else
					local val = ""
					if nature.type == 1 then
						val = tostring(v[string.format("value%d", i)])
					else
						val = tostring(v[string.format("value%d", i)] / 100) .. "%"
					end
					if nature.id == 33 or nature.id == 34 then
						tmpStr = tmpStr .. string.format("，%s+%s", common:getLanguageString("@Defence"), val)
					else
						tmpStr = tmpStr .. string.format("，%s+%s", nature.nature, val)
					end
				end
			end
		end
		local htmlText = "<font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"#%s\">%s    </font><font size=\"22\" color=\"#%s\">%s%s</font>"
		local infoNode = getRichText(string.format(htmlText, color1, v.name, color2, v.describe, tmpStr), display.width * 0.88)
		table.insert(nodes, infoNode)
		height = height + infoNode:getContentSize().height + 10
	end
	height = height - 15
	local proxy = CCBProxy:create()
	local rootnode = {}
	local node = CCBuilderReaderLoad("hero/hero_jiban_item.ccbi", proxy, rootnode, display.newNode(), CCSizeMake(DesignSize.JB.width, DesignSize.JB.height + height))
	height = 0
	for i = #nodes, 1, -1 do
		nodes[i]:setPosition(30, nodes[i]:getContentSize().height + height - 4)
		node:addChild(nodes[i])
		height = nodes[i]:getContentSize().height + height + 5
	end
	return node
end)

local JJItem = class("JJItem", function(str)
	local proxy = CCBProxy:create()
	local rootnode = {}
	local node = CCBuilderReaderLoad("hero/hero_intr_item.ccbi", proxy, rootnode, display.newNode(), DesignSize.JJ)
	rootnode.descLabel:setString(str)
	return node
end)

local LYItem = class("LYItem", function(str)
	local proxy = CCBProxy:create()
	local rootnode = {}
	local node = CCBuilderReaderLoad("hero/hero_intr_item.ccbi", proxy, rootnode, display.newNode(), DesignSize.LY)
	rootnode.intr_title:setString(common:getLanguageString("@AchieveAcess"))
	rootnode.descLabel:setString(str)
	return node
end)

function BaseHeroInfoLayer:ctor(param, infoType)
	local _confirmFunc = param.confirmFunc
	local _id = param.id
	local _baseInfo = ResMgr.getCardData(_id)
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local bgHeight = display.height
	local node = CCBuilderReaderLoad("hero/hero_info.ccbi", proxy, self._rootnode, self, CCSizeMake(640, bgHeight - 30))
	node:setAnchorPoint(cc.p(0.5, 0.5))
	node:setPosition(display.cx, node:getContentSize().height / 2)
	self:addChild(node)
	local infoNode = CCBuilderReaderLoad("hero/hero_info_detail.ccbi", proxy, self._rootnode, self, CCSizeMake(display.width, bgHeight - 55 - 68))
	infoNode:setPosition(cc.p(0, 25))
	node:addChild(infoNode)
	
	--关闭
	self._rootnode.closeBtn:setVisible(true)
	self._rootnode.closeBtn:addHandleOfControlEvent(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		self:removeSelf()
		if _confirmFunc ~= nil then
			_confirmFunc()
		end
	end,
	CCControlEventTouchUpInside)
	self._rootnode.bottomMenuNode:setVisible(false)
	local pt = self._rootnode.scrollView:convertToWorldSpace(cc.p(0, 0))
	local layer = require("utility.TouchMaskLayer").new({
	contents = {
	cc.rect(pt.x, pt.y, display.width, self._rootnode.scrollView:getViewSize().height)
	},
	btns = {
	self._rootnode.closeBtn
	}
	})
	self:addChild(layer, 100)
	self._rootnode.scrollView:setContentOffset(cc.p(0, -self._rootnode.contentView:getContentSize().height + self._rootnode.scrollView:getViewSize().height), false)
	self._rootnode.titleLabel:setString(common:getLanguageString("@HeroInfo"))
	local function refresh()
		self._rootnode.clsLabel:setVisible(false)
		local heroNameLabel = ui.newTTFLabelWithShadow({
		text = _baseInfo.name,
		font = FONTS_NAME.font_haibao,
		color = NAME_COLOR[_baseInfo.star[1]],
		align = ui.TEXT_ALIGN_CENTER,
		size = 28,
		shadowColor = FONT_COLOR.BLACK
		})
		
		ResMgr.replaceKeyLableEx(heroNameLabel, self._rootnode, "itemNameLabel", 0, 0)
		heroNameLabel:align(display.CENTER)
		
		local progressNode = self._rootnode.progressNode
		if param.curNum and param.limitNum and progressNode then
			local curNumLabel = self._rootnode.curNum
			local maxNumLabel = self._rootnode.maxNum
			curNumLabel:setString(tostring(param.curNum))
			maxNumLabel:setString("/" .. tostring(param.limitNum))
			progressNode:setVisible(true)
			progressNode:setPositionX(progressNode:getPositionX() + heroNameLabel:getContentSize().width / 2 + (curNumLabel:getContentSize().width + maxNumLabel:getContentSize().width) / 2)
		else
			progressNode:setVisible(false)
		end
		self._rootnode.curLevalLabel:setString("1")
		self._rootnode.maxLevalLabel:setString(tostring(game.player:getLevel()))
		self._rootnode.cardName:setString(_baseInfo.name)
		ResMgr.refreshCardBg({
		sprite = self._rootnode.tag_card_bg,
		star = _baseInfo.star[1] or 1,
		resType = ResMgr.HERO_BG_UI
		})
		for i = 1, _baseInfo.star[1] do
			self._rootnode["star" .. i]:setVisible(true)
		end
		for i = 1, 3 do
			self._rootnode[string.format("nbPropLabel_%d", i)]:setString(tostring(_baseInfo.lead[i] or 0))
			alignNodesOneByOne(self._rootnode[string.format("nbPropLabel_Tag_%d", i)], self._rootnode[string.format("nbPropLabel_%d", i)], 5)
		end
		for i = 1, 4 do
			self._rootnode[string.format("basePropLabel_%d", i)]:setString(tostring(_baseInfo.base[i] or 0))
			alignNodesOneByOne(self._rootnode[string.format("basePropLabel_Tag_%d", i)], self._rootnode[string.format("basePropLabel_%d", i)], 5)
		end
		local heroImg = _baseInfo.arr_body[1]
		local heroPath = CCFileUtils:sharedFileUtils():fullPathForFilename(ResMgr.getLargeImage(heroImg, ResMgr.HERO))
		self._rootnode.heroImage:setDisplayFrame(display.newSprite(heroPath):getDisplayFrame())
		local height = 0
		
		local function addSTItem()
			local item
			local st = {}
			for k, v in ipairs(_baseInfo.talent) do
				local stData = data_shentong_shentong[v]
				local t = {
				info = data_talent_talent[stData.arr_talent[5]],
				map = stData,
				lv = 5
				}
				table.insert(st, t)
			end
			item = STItem.new(st)
			height = height + item:getContentSize().height + 2
			item:setPosition(self._rootnode.contentView:getContentSize().width / 2, 40)
			self._rootnode.contentView:addChild(item)
		end
		
		local function addJNItem()
			local t = {}
			--普攻
			if _baseInfo.skill[1] then
				table.insert(t, {
				info = data_battleskill_battleskill[_baseInfo.skill[1]],
				t = 1
				})
			end
			--怒气
			if _baseInfo.angerSkill[1] then
				table.insert(t, {
				info = data_battleskill_battleskill[_baseInfo.angerSkill[1]],
				t = 2
				})
			end
			--合击
			if _baseInfo.groupSkill and _baseInfo.groupSkill[1] > 0 then
				table.insert(t, {
				info = data_battleskill_battleskill[_baseInfo.groupSkill[1]],
				t = 3,
				groupNeed = _baseInfo.groupNeed[1]
				})
			end
			
			local item = JNItem.new(t)
			item:setPosition(self._rootnode.contentView:getContentSize().width / 2, -height + 40)
			self._rootnode.contentView:addChild(item)
			height = height + item:getContentSize().height + 2
		end
		
		local function addJBItem()
			local t = {}
			if _baseInfo.fate1 then
				for k, v in ipairs(_baseInfo.fate1) do
					table.insert(t, data_jiban_jiban[v])
				end
			end
			local item = JBItem.new(t, {})
			item:setPosition(self._rootnode.contentView:getContentSize().width / 2, -height + 40)
			self._rootnode.contentView:addChild(item)
			height = height + item:getContentSize().height + 2
		end
		
		local function addJJItem(str)
			local item = JJItem.new(str)
			item:setPosition(self._rootnode.contentView:getContentSize().width / 2, -height + 40)
			self._rootnode.contentView:addChild(item)
			height = height + item:getContentSize().height + 2
		end
		
		local function addLYItem(str)
			if not str then
				return
			end
			local item = LYItem.new(str)
			item:setPosition(self._rootnode.contentView:getContentSize().width / 2, -height + 40)
			self._rootnode.contentView:addChild(item)
			height = height + item:getContentSize().height + 2
		end
		
		local function resizeContent()
			local sz = cc.size(self._rootnode.contentView:getContentSize().width, self._rootnode.contentView:getContentSize().height + height - 40)
			self._rootnode.descView:setContentSize(sz)
			self._rootnode.contentView:setPosition(ccp(sz.width / 2, sz.height))
			self._rootnode.scrollView:updateInset()
			self._rootnode.scrollView:setContentOffset(CCPointMake(0, -sz.height + self._rootnode.scrollView:getViewSize().height), false)
		end
		
		if _baseInfo.talent then
			addSTItem()
		end
		addJNItem()
		if _baseInfo.fate1 then
			addJBItem()
		end
		addJJItem(_baseInfo.describe)
		addLYItem(_baseInfo.dropway)
		resizeContent()
	end
	refresh()
end

return BaseHeroInfoLayer