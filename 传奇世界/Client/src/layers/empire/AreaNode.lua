local AreaNode = class("AreaNode", function() return cc.Layer:create() end)
local path = "res/empire/area/"

function AreaNode:ctor(bgSize)
	local msgids = {MANORWAR_SC_GETALLREWARDINFO_RET,
					MANORWAR_SC_PICKREWARD_RET
					}
	require("src/MsgHandler").new(self,msgids)

	self:initData()

	local bg_node = cc.Node:create()
	bg_node:setPosition(cc.p(0, 0))
	self:addChild(bg_node)
	self.base_Node = bg_node

    local bottomBg = createScale9Frame(
        bg_node,
        "res/common/scalable/panel_outer_base.png",
        "res/common/scalable/panel_outer_frame_scale9.png",
        cc.p(176 - 88, 640 - 115 - 454),
        cc.size(790, 454),
        5,
        cc.p(0, 0)
    )
    self.bottomBg = bottomBg
    self.bottomBaseNode = cc.Node:create()
    self.bottomBg:addChild(self.bottomBaseNode)
    self.bottomBaseNode:setPositionX(9)

	local leftBg = createScale9Sprite(
        bg_node,
        "res/common/scalable/panel_inside_scale9.png",
        --"res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(185 - 88, 640 - 424),
        cc.size(396, 300),
        cc.p(0, 0)
    )
    self.leftBg = leftBg
    self.leftBaseNode = cc.Node:create()
    self.leftBg:addChild(self.leftBaseNode)

    local rightBg = createScale9Sprite(
        bg_node,
        "res/common/scalable/panel_inside_scale9.png",
        --"res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(185 + 396 + 9 - 88, 640 - 424),
        cc.size(368, 300),
        cc.p(0, 0)
    )
    self.rightBg = rightBg
    self.rightBaseNode = cc.Node:create()
    self.rightBg:addChild(self.rightBaseNode)

	local function ruleBtnFunc()
		self:showRule()
	end
	local ruleBtn = createMenuItem(bg_node, "res/component/button/small_help2.png", cc.p(50 + 69, 435 + 59), ruleBtnFunc)
end

function AreaNode:initData()
	self.data = {}

	for k,v in pairs(getConfigItemByKey("AreaFlag")) do
		if v.manorID and v.manorID ~= 1 then
			g_msgHandlerInst:sendNetDataByTableExEx(MANORWAR_CS_GETALLREWARDINFO, "GetAllRewardInfoProtocol",{manorID = v.manorID})
    		--addNetLoading(MANORWAR_CS_GETALLREWARDINFO, MANORWAR_SC_GETALLREWARDINFO_RET)

			self.data[v.manorID] = {}
			self.data[v.manorID].cfgData = v
			self.data[v.manorID].dailyReward = {}
			local dropId = unserialize(v.dailyReward)[1]
			if dropId then
				local DropOp = require("src/config/DropAwardOp")
	  			self.data[v.manorID].dailyReward = DropOp:dropItem(dropId)
	  		end
		end
	end
	--dump(self.data)
end

function AreaNode:updateData()
	self:updateUI()
end

function AreaNode:updateUI()
	local index = 1
	local count = 1
	for k,v in pairs(self.data) do
		if v.isTime then
			index = count
			break
		end
		count = count + 1
	end

	self:updateLeft(index)
	self:updateRiht(index)
	self:updateBottom(index)
end

function AreaNode:updateLeft(index)
	self.leftBaseNode:removeAllChildren()

	local record = self:getData(index or 1)
	local roleLv = MRoleStruct:getAttr(ROLE_LEVEL)

	local mapInfo = {
		{id=6005, lev = 20, pos2 = cc.p(321, 96)},
		{id=6010, lev = 20, pos2 = cc.p(356, 236)},
		{id=6011, lev = 30, pos2 = cc.p(556, 97)},
		{id=6012, lev = 40, pos2 = cc.p(709, 154)},
		{id=6013, lev = 50, pos2 = cc.p(501, 301)},
		{id=6014, lev = 50, pos2 = cc.p(730 - 35, 500 - 57)},
		{id=6015, lev = 50, pos2 = cc.p(490 - 22, 430 - 28)},
		{id=6016, lev = 50, pos2 = cc.p(360 - 10, 510 - 47)},
	}
	self.mapInfo = mapInfo
	
	local map = createSprite(self.leftBaseNode, path.."map.jpg", cc.p(self.leftBg:getContentSize().width/2, 186), cc.p(0.5, 0.5), nil, 0.429)
	for i,v in ipairs(mapInfo) do
		if i ~= 1 then
			local tempMapInfo = mapInfo[i]
			local itemData = getConfigItemByKey("AreaFlag", "mapID", tempMapInfo.id)
			local needLv = itemData and itemData.level or tempMapInfo.lev
			local areaSpr = createSprite(map, path .. "show_" .. i ..".png", mapInfo[i].pos2, nil, 600-mapInfo[i].pos2.y, 1)

			if needLv <= roleLv then
				areaSpr:setOpacity(255)
			else
				areaSpr:setOpacity(0)
			end
			
			if mapInfo[i].id == record.cfgData.mapID then
				createSprite(areaSpr, "res/group/arrows/21.png", getCenterPos(areaSpr, 0, 30), cc.p(0.5, 0.5), nil, 2.38)
			end
		end	
	end

	createLabel(self.leftBaseNode, game.getStrByKey("empire_area_name"), cc.p(10, 55), cc.p(0, 0.5), 22, true)
	createLabel(self.leftBaseNode, game.getStrByKey("empire_area_info_faction"), cc.p(198, 55), cc.p(0, 0.5), 22, true)
	createLabel(self.leftBaseNode, game.getStrByKey("empire_can_biqi"), cc.p(198, 25), cc.p(0.5, 0.5), 22, true)

	local record = self:getData(index or 1)
	if record then
		createLabel(self.leftBaseNode, record.cfgData.name, cc.p(70, 55), cc.p(0, 0.5), 22, true, nil, nil, MColor.yellow)
		createLabel(self.leftBaseNode, record.factionName, cc.p(258, 55), cc.p(0, 0.5), 22, true, nil, nil, MColor.yellow)
	end
end

function AreaNode:updateRiht(index)
	self.rightBaseNode:removeAllChildren()
	local title = {}

	local menuFunc = function(tag, sender)
		self:updateLeft(tag)
		self:updateBottom(tag)
		self.rightBaseNode.selFrame:setPosition(title[tag].pos)
	end
	self.menuFunc = menuFunc

	local y = 255
	local addY = -70
	local addX = 90
	for i=1,self:getDataCount() do
		local record = self:getData(i)
		if record then
			--log("i = "..i.." y = "..y)
			local x
			if i % 2 == 1 then
				x = self.rightBg:getContentSize().width/2 - addX
			else
				x = self.rightBg:getContentSize().width/2 + addX
			end
			--log("i = "..i.." y = "..y)
			table.insert(title, {text=record.cfgData.name, pos=cc.p(x, y)})

			if i % 2 == 0 then
				y = y + addY
			end
		end
		--y = y + addY
	end

	local tab_control = {}
	self.tab_control = tab_control
	for i=1,#title do 
		local record = self:getData(i)
		local roleLv = MRoleStruct:getAttr(ROLE_LEVEL)
		local needLv = record.cfgData.level		
		tab_control[i] = {}
		-- if record.isTime and record.isTime == true then
		-- 	tab_control[i].menu_item = cc.MenuItemImage:create("res/component/button/40.png", "res/component/button/40_sel.png")
		-- else
		-- 	tab_control[i].menu_item = cc.MenuItemImage:create("res/component/button/40_lock.png", "res/component/button/40_sel.png")
		-- end
		if roleLv >= needLv then
			tab_control[i].menu_item = cc.MenuItemImage:create("res/empire/levOk.png", "res/empire/levOk.png")
			tab_control[i].label = createLabel(tab_control[i].menu_item, title[i].text, getCenterPos(tab_control[i].menu_item), cc.p(0.5, 0.5), 22, true, 3, nil, MColor.lable_black)
		else
			tab_control[i].menu_item = cc.MenuItemImage:create("res/empire/LevNotOk.png", "res/empire/LevNotOk.png")
			tab_control[i].label = createLabel(tab_control[i].menu_item, "", getCenterPos(tab_control[i].menu_item), cc.p(0.5, 0.5), 22, true, 3, nil, MColor.lable_black)
			local lab1 = createLabel(tab_control[i].menu_item, title[i].text, getCenterPos(tab_control[i].menu_item), cc.p(0.5, 0.5), 22, true, 3, nil, MColor.lable_black)
			local lab2 = createLabel(tab_control[i].menu_item, "Lv." .. needLv, getCenterPos(tab_control[i].menu_item), cc.p(0.5, 0.5), 22, true, 3, nil, MColor.red)
			local allWidth = lab1:getContentSize().width + lab2:getContentSize().width
			lab1:setPositionX(lab1:getPositionX() - allWidth/2 + lab1:getContentSize().width/2)
			lab2:setPositionX(lab1:getPositionX() + allWidth/2 )
		end
		tab_control[i].menu_item:setPosition(title[i].pos)
		tab_control[i].callback = menuFunc

		--dump(record)
		if record.isTime == true then
			createSprite(tab_control[i].menu_item, "res/component/flag/19.png", cc.p(tab_control[i].menu_item:getContentSize().width - 2, tab_control[i].menu_item:getContentSize().height+ 1), cc.p(1, 1), 3)
		end

		local roleLv = MRoleStruct:getAttr(ROLE_LEVEL)
		local needLv = record.cfgData.level
		if needLv > roleLv then
			--tab_control[i].menu_item:setEnabled(false)
		end
	end
	local defaultIndex = index or 1
	creatTabControlMenu(self.rightBaseNode, tab_control, defaultIndex)
	self.rightBaseNode.selFrame = createSprite(self.rightBaseNode, "res/empire/selFrame.png", title[defaultIndex].pos, nil , 6)
	--menuFunc(defaultIndex)
end

function AreaNode:updateBottom(index)
	self.bottomBaseNode:removeAllChildren()

	local record = self:getData(index or 1)
	--dump(record.dailyReward)
	self.curBottomIndex = index or 1
	createLabel(self.bottomBaseNode, game.getStrByKey("empire_area_info_daily"), cc.p(10, 115), cc.p(0, 0.5), 22, true)
	createLabel(self.bottomBaseNode, game.getStrByKey("empire_award"), cc.p(198 + 20, 115), cc.p(0, 0.5), 22, true)
	createLabel(self.bottomBaseNode, game.getStrByKey("empire_rule_5_title").."：", cc.p(425, 115), cc.p(0, 0.5), 22, true)

	local tempStr = ""
	if not record.isTime then
		if record.starttime then
			tempStr = os.date("%Y-%m-%d ", tonumber(record.starttime * 24 * 3600) + record.currTime)
		end
	end

	local strTime = ""
	if record.cfgData.openTime then
		strTime = getStrTimeByValue(record.cfgData.openTime, false)
	end
	
	createLabel(self.bottomBaseNode, tempStr .. strTime, cc.p(536, 115), cc.p(0, 0.5), 22, true, nil, nil, MColor.white)
	
	local x = 10 + 45
	local addX = 90
	local y = 55
	local count = 1
	for k,v in pairs(record.dailyReward) do
		--createPropIcon(self.bottomBaseNode, v, true, false, nil)
		if count > 2 then return end
		local Mprop = require "src/layers/bag/prop"
		local icon = Mprop.new(
		{
			protoId = tonumber(k),
			num = tonumber(v.q_count),
			swallow = true,
			cb = "tips",
            showBind = true,
            isBind = tonumber(v.bdlx or 0) == 1,     				
		})
		icon:setScale(0.98)
		icon:setPosition(cc.p(x, y))
		self.bottomBaseNode:addChild(icon)
		x = x + addX
		count = count + 1
	end

	local Mprop = require "src/layers/bag/prop"
	local icon = Mprop.new(
	{
		protoId = tonumber(6200052),
		num = tonumber(1),
		swallow = true,
		cb = "tips",
        -- showBind = true,
        -- isBind = tonumber(v.bdlx or 0) == 1,     				
	})
	icon:setScale(0.98)
	icon:setPosition(cc.p(198 + 45 + 20, y))
	self.bottomBaseNode:addChild(icon)	


	--获得奖励
	local function getBtnFunc()
		g_msgHandlerInst:sendNetDataByTableExEx(MANORWAR_CS_PICKREWARD, "PickManorRewardProtocol", {manorID = record.cfgData.manorID})
    	addNetLoading(MANORWAR_CS_PICKREWARD, MANORWAR_SC_PICKREWARD_RET)
	end
	local getBtn = createMenuItem(self.bottomBaseNode, "res/component/button/50.png", cc.p(425 + 70, 55), getBtnFunc)
	self.getBtn = getBtn
	getBtn:setEnabled(record.rewardAvailable == true)
	createLabel(getBtn, game.getStrByKey("biqi_get"), getCenterPos(getBtn), cc.p(0.5, 0.5), 22, true)

	--进入战场
	local function goBtnFunc()
		g_msgHandlerInst:sendNetDataByTableExEx(MANORWAR_CS_ENTERMANORWAR, "EnterManorWarProtocol", {manorID = record.cfgData.manorID})
	    __removeAllLayers()
	end
	local goBtn = createMenuItem(self.bottomBaseNode, "res/component/button/50.png", cc.p(680, 55), goBtnFunc)
	createLabel(goBtn, game.getStrByKey("biqi_enter"), getCenterPos(goBtn), cc.p(0.5, 0.5), 22, true)
	goBtn:setEnabled(record.isTime)
end

function AreaNode:showRule()
    local ruleBg = createSprite(self.base_Node, "res/common/helpBg.png",cc.p(480, 320), nil, 100)
    local root_size = ruleBg:getContentSize()
    createSprite(ruleBg, "res/common/helpBg_title.png", cc.p(261, 290))
    createLabel(ruleBg, "信息", cc.p(261, 290), nil, 20):setColor(MColor.brown)
   
  	registerOutsideCloseFunc(ruleBg, function() removeFromParent(ruleBg) end, true)

    local Node = cc.Node:create()
	local function createRichTextContent(parent, content, pos, size, anchor, lineHeight, fontSize, fontColor)
		local richText = require("src/RichText").new(parent, pos, size, anchor, lineHeight, fontSize, fontColor)
	    richText:addText(content)
	    richText:format()
	    return richText
	end

	local height = 0
	local offSetX = 40
	local data = require("src/config/PromptOp")
	local strCfg = {41, 42, 43, 59,}
	local num = 4
	
	for i=1, num do
		local lab = createRichTextContent(Node, data:content(strCfg[num-i+1]), cc.p(offSetX, height), cc.size(root_size.width - 80, 30), cc.p(0, 0), 25, 20, MColor.brown_gray)
		height = height + lab:getContentSize().height
		lab = createLabel(Node, game.getStrByKey("empire_rule_"..(num-i+1) .. "_title_1") .. ":", cc.p(offSetX, height + 5 ), cc.p(0, 0), 22, true)
		lab:setColor(MColor.brown_gray)
		height = height + lab:getContentSize().height + 22
	end

	height = height - 10
	Node:setAnchorPoint(0,0)
	Node:setContentSize(cc.size(root_size.width, height))
    local scrollView = cc.ScrollView:create()
    scrollView:setViewSize(cc.size( root_size.width - 20, root_size.height - 60 ) )
    scrollView:setPosition( cc.p( 0 , 15 ) ) --250 , 65
    scrollView:ignoreAnchorPointForPosition(true)

    scrollView:setContainer(Node)
    scrollView:updateInset()

    scrollView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL )
    scrollView:setClippingToBounds(true)
    scrollView:setBounceable(true)
    ruleBg:addChild(scrollView)

    scrollView:setContentOffset( cc.p(0, - Node:getContentSize().height + root_size.height - 60))		
end

function AreaNode:getDataCount()
	local count = 0
	for k,v in pairs(self.data) do
		count = count + 1
	end
	--dump(count)
	return count
end

function AreaNode:getData(index)
	local count = 0
	for k,v in pairs(self.data) do
		count = count + 1
		if count == index then
			return v
		end
	end
end

function AreaNode:networkHander(buff,msgid)
	local switch = {
		[MANORWAR_SC_GETALLREWARDINFO_RET] = function()
			local retTab = g_msgHandlerInst:convertBufferToTable("GetAllRewardInfoRetProtocol", buff)
			local id = retTab.manorID
			local isTime = retTab.isOpen
			local starttime = retTab.remainDay
			local currTime = retTab.curTime
			local factionName = ""
			local factionKingName = ""
			local flg = retTab.hasFaction
			if flg then
				factionName = retTab.facName
				factionKingName = retTab.leaderName
			end
			
			local rewardAvailable = retTab.canReward
			--print("id = "..id)
			if self.data[id] then
				self.data[id].isTime = isTime
				self.data[id].starttime = starttime
				self.data[id].currTime = currTime
				self.data[id].factionName = factionName
				if self.data[id].factionName == "" then
					self.data[id].factionName = game.getStrByKey("biqi_str9")
				end
				self.data[id].factionKingName = factionKingName
				if self.data[id].factionKingName == "" then
					self.data[id].factionKingName = game.getStrByKey("biqi_str9")
				end
				self.data[id].rewardAvailable = rewardAvailable
			end
			--dump(self.data)
			self:updateData()
		end,
		[MANORWAR_SC_PICKREWARD_RET] = function()    
			local retTab = g_msgHandlerInst:convertBufferToTable("PickManorRewardRetProtocol", buff)
			local id = retTab.manorID
			if self.data[id] then
				self.data[id].rewardAvailable = false
				--TIPS( { type = 1 , str = game.getStrByKey("empire_area_get_reward_tip") } )
			end

			local index = 1
			for k,v in pairs(self.data) do
				if k == id then
					break
				end
				index = index + 1
			end

			if self.curBottomIndex and self.curBottomIndex == index then 
				if self.getBtn then
					performWithDelay(self, function() self.getBtn:setEnabled(self.data[id].rewardAvailable) end ,0.25 )
				end
			end
		end,
	}

 	if switch[msgid] then 
 		switch[msgid]()
 	end
end

return AreaNode