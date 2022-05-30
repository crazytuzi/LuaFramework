local data_item_nature = require("data.data_item_nature")
local data_talent_talent = require("data.data_talent_talent")
local data_jiban_jiban = require("data.data_jiban_jiban")
local data_battleskill_battleskill = require("data.data_battleskill_battleskill")
local data_shentong_shentong = require("data.data_shentong_shentong")
local data_fashion_fashion = require("data.data_fashion_fashion")
local data_cheats_cheats = require("data.data_miji_miji")
local data_item_item = require("data.data_item_item")
local data_card_card = require("data.data_card_card")

require("utility.richtext.richText")
require("data.data_langinfo")

local ST_COLOR = {
cc.c3b(255, 38, 0),  --攻击
cc.c3b(43, 164, 45), --辅助
cc.c3b(28, 94, 171), --蓝色
cc.c3b(218, 129, 29) --橘色
}

local DesignSize = {
ST = cc.size(display.width, 80),
JN = cc.size(display.width, 55),
JB = cc.size(display.width, 55),
JJ = cc.size(display.width, 150),
LY = cc.size(display.width, 100)
}

local HeroInfoOtherLayer = class("HeroInfoOtherLayer", function()
	return require("utility.ShadeLayer").new(cc.c4b(100, 100, 100, 0))
end)

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
			infoSize = cc.size(display.width, 80)
		end
		local infoNode = CCBuilderReaderLoad("hero/hero_shentong_info.ccbi", proxy, rootnode, display.newNode(), infoSize)
		local tmpLv = v.lv
		if k == #t then
			rootnode.lineSprite:setVisible(false)
		end
		
		rootnode.upgradeBtn:setVisible(false)
		rootnode.upgradeBtn:setEnabled(false)
		rootnode.refreshBtn:setVisible(false)
		rootnode.refreshBtn:setEnabled(false)
		rootnode.costLabel:setVisible(false)
		rootnode.xiaohao_lbl_1:setVisible(false)
		rootnode.xiaohao_lbl_2:setVisible(false)
		
		table.insert(nodes, infoNode)
		
		height = height + infoNode:getContentSize().height
		if t.cls <= 0 then
			rootnode.nameItemName:setColor(cc.c3b(119, 119, 119))
			rootnode.descLabel:setColor(cc.c3b(119, 119, 119))
		elseif v.map then
			rootnode.nameItemName:setColor(ST_COLOR[v.map.type])
			rootnode.descLabel:setColor(cc.c3b(86, 59, 32))
		end
		rootnode.descLabel:setString(v.info.type)
		rootnode.nameItemName:setString(string.format("%s(%d/%d)", v.info.name, v.lv, #v.map.arr_cond))
	end
	
	rootnode = {}
	local node = CCBuilderReaderLoad("hero/hero_shentong_item.ccbi", proxy, rootnode, display.newNode(), cc.size(DesignSize.ST.width, DesignSize.ST.height + height + 10))
	rootnode.stPointLabel:setString(tostring(t.point))
	--rootnode.stPointLabel:setVisible(false)
	rootnode.resetBtn:setVisible(false)
	rootnode.resetBtn:setEnabled(false)
	
	height = 0
	for i = #nodes, 1, -1 do
		height = nodes[i]:getContentSize().height + height + 5
		nodes[i]:setPosition(node:getContentSize().width / 2, height)
		node:addChild(nodes[i])
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
		
		if v.lv <= 0 then
			rootnode.nameItemName:setColor(cc.c3b(119, 119, 119))
			rootnode.descLabel:setColor(cc.c3b(119, 119, 119))
		elseif v.map then
			rootnode.nameItemName:setColor(ST_COLOR[v.map.type])
			rootnode.descLabel:setColor(cc.c3b(86, 59, 32))
		end
		rootnode.nameItemName:setString(string.format("%s(%d/%d)", v.info.name, v.lv, #v.map.arr_cond))
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
		local bFlag = 0
		for i = 1, 3 do
			if v[string.format("nature%d", i)] ~= 0 then
				local nature = data_item_nature[v[string.format("nature%d", i)]]
				if nature.id == 33 or nature.id == 34 then
					bFlag = bFlag + 1
				end
			end
		end
		local tmpStr = ""
		local bSkip = false
		for i = 1, 3 do
			if v[string.format("nature%d", i)] ~= 0 then
				local nature = data_item_nature[v[string.format("nature%d", i)]]
				local val = ""
				if nature.type == 1 then
					val = tostring(v[string.format("value%d", i)])
				else
					val = tostring(v[string.format("value%d", i)] / 100) .. "%"
				end
				if (nature.id == 33 or nature.id == 34) and bFlag == 2 then
					if bSkip == false then
						tmpStr = tmpStr .. string.format("，%s+%s", common:getLanguageString("@Defence"), val)
						bSkip = true
					end
				else
					tmpStr = tmpStr .. string.format("，%s+%s", nature.nature, val)
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
	local node = CCBuilderReaderLoad("hero/hero_jiban_item.ccbi", proxy, rootnode, display.newNode(), cc.size(DesignSize.JB.width, DesignSize.JB.height + height))
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

local LYItem = class("LYItem", function(str)
	local proxy = CCBProxy:create()
	local rootnode = {}
	local node = CCBuilderReaderLoad("hero/hero_intr_item.ccbi", proxy, rootnode, display.newNode(), DesignSize.LY)
	rootnode.intr_title:setString(common:getLanguageString("@AchieveAcess"))
	rootnode.descLabel:setString(str)
	return node
end)

local SXItem = class("SXItem", function(atts)
	local natureTable = {61,62,63,64,65,66,75,76}
	local proxy = CCBProxy:create()
	local rootnode = {}
	local height = math.floor(#natureTable / 3)
	if (#natureTable % 3) ~= 0 then
		height = height + 1
	end
	local fontSize = 22
	local lineHeight = fontSize + 5
	height = height * lineHeight + 66
	local node = CCBuilderReaderLoad("hero/hero_intr_item.ccbi", proxy, rootnode, display.newNode(), cc.size(display.width, height))
	rootnode.descLabel:setVisible(false)
	rootnode.intr_title:setString(common:getLanguageString("@AttrPlus"))
	local x ,y = rootnode.descLabel:getPosition()
	x = x + 10
	local width =  math.floor((node:getContentSize().width - 20) / 3)
	for i = 1, #natureTable do
		local nature = data_item_nature[natureTable[i]]
		local vaule = atts[4 + i]
		local v = ""
		if vaule then
			if nature.type == 1 then
				v = "+" ..tostring(vaule)
			else
				v = "+" ..tostring(vaule/100) .."%"
			end
		end
		local att_lable = ResMgr.createOutlineMsgTTF({
		text = nature.nature ..":" ..v,
		color = cc.c3b(86, 59, 32),
		outlineColor = FONT_COLOR.BLACK,
		size = fontSize
		})
		att_lable:align(display.TOP_LEFT, x + ((i - 1) % 3) * width, y - math.floor((i - 1) / 3) * lineHeight)
		node:addChild(att_lable)
	end
	return node
end)

function HeroInfoOtherLayer:ctor(param)
	self:setNodeEventEnabled(true)
	self._proxy = CCBProxy:create()
	self._rootnode = {}
	local bgHeight = display.height
	local bgNode = CCBuilderReaderLoad("hero/hero_info.ccbi", self._proxy, self._rootnode, self, cc.size(display.width, bgHeight - 30))
	self:addChild(bgNode, 1)
	bgNode:setPosition(display.cx, display.cy - bgHeight / 2)
	local infoNode = CCBuilderReaderLoad("hero/hero_info_detail.ccbi", self._proxy, self._rootnode, self, cc.size(display.width, bgHeight - 32 - 85 - 68))
	infoNode:setPosition(cc.p(0, 85))
	bgNode:addChild(infoNode)
	self._rootnode.bottomMenuNode:setZOrder(1)
	
	local heroNameLabel = ui.newTTFLabelWithShadow({
	text = "",
	font = FONTS_NAME.font_haibao,
	align = ui.TEXT_ALIGN_CENTER,
	size = 28,
	shadowColor = display.COLOR_BLACK,
	})
	
	ResMgr.replaceKeyLable(heroNameLabel, self._rootnode.itemNameLabel, 0, 0)
	heroNameLabel:align(display.RIGHT_CENTER)
	
	local clsLabel = ui.newTTFLabelWithShadow({
	text = "",
	font = FONTS_NAME.font_haibao,
	color = cc.c3b(46, 194, 49),
	shadowColor = display.COLOR_BLACK,
	size = 28
	})
	
	ResMgr.replaceKeyLable(clsLabel, self._rootnode.itemNameLabel, 0, 0)
	clsLabel:align(display.LEFT_CENTER)
	self._rootnode.itemNameLabel:removeSelf()
	
	display.addSpriteFramesWithFile("ui_zhenrong.plist", "ui_zhenrong.png")
	local pt = self._rootnode.scrollView:convertToWorldSpace(cc.p(0, 0))
	local hasInfo = false
	local _info = param.info
	if param.info["1"] then
		_info = param.info["1"]
		_info.objId = _info._id
		hasInfo = true
	end
	
	self._roleId = _info.roleId
	self._objId = _info.objId
	local _baseInfo = ResMgr.getCardData(_info.resId)
	
	self._rootnode.titleLabel:setString(common:getLanguageString("@HeroInfo"))
	
	function self.refresh(_, cheatsInfo)
		self._rootnode.contentViewNode:removeAllChildrenWithCleanup(true)
		local nameText = _baseInfo.name
		heroNameLabel:setString(nameText)
		heroNameLabel:setColor(NAME_COLOR[self._detailInfo.star])
		if self._detailInfo.cls > 0 then
			clsLabel:setString(string.format("+%d", self._detailInfo.cls))
		end
		self._rootnode.curLevalLabel:setString(tostring(self._detailInfo.level))
		self._rootnode.maxLevalLabel:setString(tostring(self._detailInfo.levelLimit or common:getLanguageString("@NoMClevel")))
		self._rootnode.cardName:setString(_baseInfo.name)
		self._rootnode.tag_card_bg:setDisplayFrame(display.newSprite("#card_ui_bg_" .. self._detailInfo.star .. ".png"):getDisplayFrame())
		self._rootnode.jobImage:setDisplayFrame(display.newSpriteFrame(string.format("zhenrong_job_%d.png", _baseInfo.job)))
		for i = 1, self._detailInfo.star do
			self._rootnode["star" .. i]:setVisible(true)
		end
		for i = 1, 3 do
			self._rootnode[string.format("nbPropLabel_%d", i)]:setString(tostring(self._detailInfo.lead[i]))
			alignNodesOneByOne(self._rootnode[string.format("nbPropLabel_Tag_%d", i)], self._rootnode[string.format("nbPropLabel_%d", i)], 5)
		end
		for i = 1, 4 do
			self._rootnode[string.format("basePropLabel_%d", i)]:setString(tostring(self._detailInfo.base[i]))
			alignNodesOneByOne(self._rootnode[string.format("basePropLabel_Tag_%d", i)], self._rootnode[string.format("basePropLabel_%d", i)], 5)
		end
		local heroFrame = ResMgr.getHeroFrame(self._detailInfo.resId, self._detailInfo.cls, self._detailInfo.fashionId)
		self._rootnode.heroImage:setDisplayFrame(heroFrame)
		local height = 0
		local startY = 80
		local function addSTItem()
			local item
			local st = {}
			
			for k, v in ipairs(self._detailInfo.shenIDAry) do
				local stData = data_shentong_shentong[data_talent_talent[v].shentong]
				local t = {
				info = data_talent_talent[v],
				map = stData,
				lv = self._detailInfo.shenLvAry[k] or 1
				}
				table.insert(st, t)
			end
			st.cls = self._detailInfo.cls
			st.point = self._detailInfo.shenPt or 0
			item = STItem.new(st)
			item:setPosition(self._rootnode.contentView:getContentSize().width / 2, -height + startY)
			self._rootnode.contentViewNode:addChild(item)
			height = height + item:getContentSize().height + 2
		end
		
		local function addJNItem()
			local t = {}
			local skillTbl = {}
			skillTbl[1] = _baseInfo.skill[self._detailInfo.cls + 1]
			skillTbl[2] = _baseInfo.angerSkill[self._detailInfo.cls + 1]
			if _baseInfo.groupSkill ~= nil and _baseInfo.groupSkill[self._detailInfo.cls + 1] > 0 then
				skillTbl[3] = _baseInfo.groupSkill[self._detailInfo.cls + 1]
			end
			if self._detailInfo.fashionId ~= 0 then
				local fashionData = data_item_item[self._detailInfo.fashionId]
				if fashionData.skill > 0 and self._detailInfo.level >= fashionData.unlockskill then
					skillTbl[1] = fashionData.skill
				end
				if fashionData.angerSkill > 0 and self._detailInfo.level >= fashionData.unlockanger then
					skillTbl[2] = fashionData.angerSkill
				end
			end
			local cheats_t = {}
			local skillTblState = {}
			if cheatsInfo ~= nil and #cheatsInfo > 0 then
				for i, v in ipairs(cheatsInfo) do
					if v.subpos == 18 then
						skillTblState[2] = 0
						table.insert(cheats_t, {
						ceng = v.floor,
						data = data_battleskill_battleskill[data_cheats_cheats[v.resId].skill[v.floor]]
						})
						break
					end
				end
			end
			
			for k, v in pairs(skillTbl) do
				local skillinfo = {
				info = data_battleskill_battleskill[v],
				t = k,
				state = skillTblState[k] or 1
				}
				if k == 3 then
					skillinfo.groupNeed = _baseInfo.groupNeed[1]
				end
				table.insert(t, skillinfo)
			end
			
			local item = JNItem.new(t)
			item:setPosition(self._rootnode.contentView:getContentSize().width / 2, -height + startY)
			self._rootnode.contentViewNode:addChild(item)
			height = height + item:getContentSize().height + 2
			if #cheats_t > 0 then
				local cheatsJNItem = CheatsJNItem.new(cheats_t)
				cheatsJNItem:setPosition(self._rootnode.contentView:getContentSize().width / 2, -height + startY)
				self._rootnode.contentViewNode:addChild(cheatsJNItem)
				height = height + cheatsJNItem:getContentSize().height + 2
			end
		end
		
		local function addCheatsSTItem(info)
			if #info > 0 then
				local st = {}
				for k, v in ipairs(info) do
					local stData = data_shentong_shentong[data_talent_talent[v.stId].shentong]
					local t = {
					info = data_talent_talent[v.stId],
					map = stData,
					lv = v.lv or 1
					}
					table.insert(st, t)
				end
				st.cls = self._detailInfo.cls
				st.point = self._detailInfo.shenPt or 0
				local item = CheatsSTItem.new(st)
				item:setPosition(self._rootnode.contentView:getContentSize().width / 2, -height + startY)
				self._rootnode.contentViewNode:addChild(item)
				height = height + item:getContentSize().height + 2
			end
		end
		
		local function addJBItem()
			local t = {}
			if _baseInfo.fate1 then
				for k, v in ipairs(_baseInfo.fate1) do
					table.insert(t, data_jiban_jiban[v])
				end
			end
			local item = JBItem.new(t, self._detailInfo.relation)
			item:setPosition(self._rootnode.contentView:getContentSize().width / 2, -height + startY)
			self._rootnode.contentViewNode:addChild(item)
			height = height + item:getContentSize().height + 2
		end
		
		local function addJJItem(str)
			local item = JJItem.new(str)
			item:setPosition(self._rootnode.contentView:getContentSize().width / 2, -height + startY)
			self._rootnode.contentViewNode:addChild(item)
			height = height + item:getContentSize().height + 2
		end
		
		local function addLYItem(str)
			if not str then
				return
			end
			local item = LYItem.new(str)
			item:setPosition(self._rootnode.contentView:getContentSize().width / 2, -height + startY)
			self._rootnode.contentView:addChild(item)
			height = height + item:getContentSize().height + 2
		end
		
		local function addSXItem(atts)
			if #atts > 4 then
				local item = SXItem.new(atts)
				self._rootnode.contentView:addChild(item)
				local h = item:getContentSize().height
				item:setPosition(self._rootnode.contentView:getContentSize().width / 2, -height +  startY)
				height = height + item:getContentSize().height + 15
			end
		end
		
		local function resizeContent()
			local sz = cc.size(self._rootnode.contentView:getContentSize().width, self._rootnode.contentView:getContentSize().height + height - 40)
			self._rootnode.descView:setContentSize(sz)
			self._rootnode.contentView:setPosition(ccp(sz.width / 2, sz.height))
			self._rootnode.scrollView:updateInset()
			self._rootnode.scrollView:setContentOffset(CCPointMake(0, -sz.height + self._rootnode.scrollView:getViewSize().height), false)
		end
		
		addSXItem(self._detailInfo.base)
		
		if #self._detailInfo.shenIDAry  > 0 then
			addSTItem()
		end
		
		if cheatsInfo ~= nil and #cheatsInfo > 0 then
			local info = {}
			for i, v in ipairs(cheatsInfo) do
				if v.subpos == 16 then
					local stId = data_shentong_shentong[data_cheats_cheats[v.resId].skill[1]].arr_talent[v.floor]
					local item = {}
					item.stId = stId
					item.lv = v.floor
					table.insert(info, item)
					break
				end
			end
			addCheatsSTItem(info)
		end
		
		addJNItem()
		
		if _baseInfo.fate1 then
			addJBItem()
		end
		
		if _baseInfo.describe then
			addJJItem(_baseInfo.describe)
		end
		
		addLYItem(_baseInfo.dropway)
		
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
		self:removeSelf()
	end
	
	resetbtn(self._rootnode.closeBtn, bgNode, 1)
	self._rootnode.closeBtn:setVisible(true)
	self._rootnode.closeBtn:addHandleOfControlEvent(close, CCControlEventTouchUpInside)
	
	self._rootnode.qiangHuBtn:setVisible(false)
	self._rootnode.qiangHuBtn:setEnabled(false)
	self._rootnode.jinJieBtn:setVisible(false)
	self._rootnode.jinJieBtn:setEnabled(false)
	self._rootnode.gilgulBtn:setVisible(false)
	self._rootnode.gilgulBtn:setEnabled(false)
	self._rootnode.changeBtn:setVisible(false)
	self._rootnode.changeBtn:setEnabled(false)
	self._rootnode.lock_node:setVisible(false)
	--self._rootnode.lock_node:setEnabled(false)
	self._rootnode.unlock_btn:setVisible(false)
	--self._rootnode.unlock_btn:setEnabled(false)
	
	if not hasInfo then
		self:requestHeroInfo()
	else
		self:refreshHeroInfo(param.info)
	end
end

function HeroInfoOtherLayer:refreshHeroInfo(data)
	self._detailInfo = data["1"]
	self._detailInfo.levelLimit = data["2"]
	self:refresh(data["3"] or nil)
end

function HeroInfoOtherLayer:requestHeroInfo(listener)
	RequestHelper.hero.infoOther({
	rid = self._roleId,
	cid = self._objId,
	callback = function(data)
		self:refreshHeroInfo(data)
	end
	})
end

return HeroInfoOtherLayer