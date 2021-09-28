local RidingChangeNode = class("RidingChangeNode", require("src/TabViewLayer"))

local pathCommon = "res/wingAndRiding/common/"

local MPackStruct = require "src/layers/bag/PackStruct"
local MpropOp = require "src/config/propOp"

function RidingChangeNode:ctor(parent, index)
	local msgids = {EMOUNT_SC_MOUNT_SKIN_LIST, ITEM_SC_CHANGE_SKIN}
	require("src/MsgHandler").new(self, msgids)

	g_msgHandlerInst:sendNetDataByTable(EMOUNT_CS_MOUNT_SKIN_LIST, "MountSkinlistProtocol", {})
	addNetLoading(EMOUNT_CS_MOUNT_SKIN_LIST, EMOUNT_SC_MOUNT_SKIN_LIST)

	self.parent = parent
	self.data = {}
	self.attData = {}
	self.select = nil
	self.index = index

	local bg = createSprite(self, "res/common/bg/bg18.png", cc.p(display.cx, display.cy), cc.p(0.5, 0.5))
	self.bg = bg
	createLabel(bg, game.getStrByKey("wr_pic"), cc.p(bg:getContentSize().width/2, bg:getContentSize().height-30), cc.p(0.5, 0.5), 24, true)

	local contentBg = createScale9Frame(
        bg,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(32, 15),
        cc.size(792,455),
        5
    )

	local closeFunc = function() 
	   	self.bg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 0), cc.CallFunc:create(function() self:removeFromParent() end)))	
	end
	local closeBtn = createTouchItem(bg, "res/component/button/x2.png", cc.p(bg:getContentSize().width-48, bg:getContentSize().height-28), closeFunc)

	local rightBg = createScale9Sprite(contentBg, "res/common/scalable/setbg.png", cc.p(525, 5), cc.size(255, 440), cc.p(0, 0))
	self.rightBg = rightBg
	local leftBg = createSprite(contentBg, "res/wingAndRiding/1.png", cc.p(95, 5), cc.p(0, 0))
	self.leftBg = leftBg

	self:createTableView(contentBg, cc.size(95, 437), cc.p(5, 5), true)

	self:updateData()

	registerOutsideCloseFunc(bg , closeFunc, true)
end


function RidingChangeNode:updateData()
	self:updateUI()
end

function RidingChangeNode:updateUI()
	self:updateLeft()
	self:updateRight()
end

function RidingChangeNode:updateLeft()
	self.leftBg:removeAllChildren()

	dump(self.selectId)
	if self.selectId == nil then
		return
	end

	local rideSpr = createSprite(self.leftBg, "res/showplist/ride/"..MpropOp.avatar(self.selectId)..".png", cc.p(self.leftBg:getContentSize().width/2+20, 210), cc.p(0.5, 0.5))
	--wingSpr:setScale(1.2)

	local nameBg = createSprite(self.leftBg, "res/layers/role/24.png", cc.p(self.leftBg:getContentSize().width/2, 370), cc.p(0.5, 0)) 
	createLabel(nameBg, MpropOp.name(self.selectId), getCenterPos(nameBg, 0, -9), cc.p(0.5, 0.5), 20, true)

	local attBtnFunc = function()
		
	end
	local attBtn = createMenuItem(self.leftBg, "res/component/button/2.png", cc.p(self.leftBg:getContentSize().width/2-100, 40), attBtnFunc)
	createLabel(attBtn, game.getStrByKey("wr_pic_att"), getCenterPos(attBtn), cc.p(0.5, 0.5), 22, true)

	local changeBtnFunc = function()
		local t = {}
		t.dwBagSlot = self.index
		t.dwSkinId = self.selectId
		dump(t)
		g_msgHandlerInst:sendNetDataByTable(ITEM_CS_CHANGE_SKIN, "ItemMountChnageSkinProtocol", t)
	end
	local changeBtn = createMenuItem(self.leftBg, "res/component/button/2.png", cc.p(self.leftBg:getContentSize().width/2+100, 40), changeBtnFunc)
	createLabel(changeBtn, game.getStrByKey("wr_skin"), getCenterPos(changeBtn), cc.p(0.5, 0.5), 22, true)
end

function RidingChangeNode:updateAttData()
	for i,v in ipairs(self.data) do
		local record = getConfigItemByKey("RidePockdex", "mountId", v)
		for k,v in pairs(record) do
			if self.attData[k] then
				self.attData[k] = self.attData[k] + v
			else
				self.attData[k] = v
			end
		end
	end
	dump(self.attData)
end

function RidingChangeNode:updateRight()
	self.rightBg:removeAllChildren()

	local scrollView = cc.ScrollView:create()
    if nil ~= scrollView then
        scrollView:setViewSize(cc.size(250, 425))
        scrollView:setPosition(cc.p(0, 10))
        scrollView:ignoreAnchorPointForPosition(true)
        local node = cc.Node:create()
        scrollView:setContainer(node)
        --scrollView:setContentSize(cc.size(320,500))

        scrollView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
        scrollView:setClippingToBounds(true)
        scrollView:setBounceable(true)
        self.rightBg:addChild(scrollView)

         dump(scrollView)
	    dump(node)
	    self:updateScrollView(scrollView, node) 
    end
end 

function RidingChangeNode:updateScrollView(scrollView, baseNode)
	--图鉴属性
    local picAttBg = createSprite(nil, "res/common/bg/infoBg11-2.png", cc.p(0, 0), cc.p(0, 0))
    createLabel(picAttBg, game.getStrByKey("wr_title_pic_all_att"), getCenterPos(picAttBg), cc.p(0.5, 0.5), 22, false, nil, nil, MColor.lable_yellow)

	local atttNode = self:createAttNode(self.attData)

    local nodes = 
	{
		atttNode,
		picAttBg,
	}

	dump(#nodes)

    local node = Mnode.combineNode(
	{
		nodes = nodes,
		ori = "|",
		--align = "l",
		margins = 5,
	})
	baseNode:addChild(node)
	--dump(node:getContentSize())
	scrollView:setContentSize(cc.size(250, node:getContentSize().height))
	scrollView:setContentOffset(cc.p(0, -(node:getContentSize().height-425)), false)
end

function RidingChangeNode:createAttNode(record)
	if record == nil then
		return nil
	end

	local attStrs = {}

	local formatStr2 = function(str1, str2)
		return "^c(lable_yellow)"..str1.."^".." ".."^c(white)"..str2.."^"
	end

	local formatStr3 = function(str1, str2, str3)
		return "^c(lable_yellow)"..str1.."^".." ".."^c(white)"..str2.."-"..str3.."^"
	end

	if record.q_max_hp then
		local str = formatStr2(game.getStrByKey("prop_hp"), record.q_max_hp)
		table.insert(attStrs, str)
	end

	if record.q_max_mp then
		local str = formatStr2(game.getStrByKey("prop_mp"), record.q_max_mp)
		table.insert(attStrs, str)
	end

	if record.q_attack_min and record.q_attack_max then
		local str = formatStr3(game.getStrByKey("prop_attack"), record.q_attack_min, record.q_attack_max)
		table.insert(attStrs, str)
	end

	if record.q_magic_attack_min and record.q_magic_attack_max then
		local str = formatStr3(game.getStrByKey("prop_magicAttack"), record.q_magic_attack_min, record.q_magic_attack_max)
		table.insert(attStrs, str)
	end

	if record.q_sc_attack_min and record.q_sc_attack_max then
		local str = formatStr3(game.getStrByKey("prop_scAttack"), record.q_sc_attack_min, record.q_sc_attack_max)
		table.insert(attStrs, str)
	end

	if record.q_defence_min and record.q_defence_max then
		local str = formatStr3(game.getStrByKey("prop_defence"), record.q_defence_min, record.q_defence_max)
		table.insert(attStrs, str)
	end

	if record.q_magic_defence_min and record.q_magic_defence_max then
		local str = formatStr3(game.getStrByKey("prop_magicDefence"), record.q_magic_defence_min, record.q_magic_defence_max)
		table.insert(attStrs, str)
	end

	if record.q_att_dodge then
		local str = formatStr2(game.getStrByKey("prop_attackDodge"), record.q_att_dodge)
		table.insert(attStrs, str)
	end

	if record.q_mac_dodge then
		local str = formatStr2(game.getStrByKey("prop_magicDodge"), record.q_mac_dodge)
		table.insert(attStrs, str)
	end

	if record.q_crit then
		local str = formatStr2(game.getStrByKey("prop_cirt"), record.q_crit)
		table.insert(attStrs, str)
	end

	if record.q_hit then
		local str = formatStr2(game.getStrByKey("prop_hit"), record.q_hit)
		table.insert(attStrs, str)
	end

	if record.q_dodge then
		local str = formatStr2(game.getStrByKey("prop_dodge"), record.q_dodge)
		table.insert(attStrs, str)
	end

	if record.q_attack_speed then
		local str = formatStr2(game.getStrByKey("prop_attackSpeed"), record.q_attack_speed)
		table.insert(attStrs, str)
	end

	if record.q_luck then
		local str = formatStr2(game.getStrByKey("prop_luck"), record.q_luck)
		table.insert(attStrs, str)
	end

	if record.q_addSpeed then
		local str = formatStr2(game.getStrByKey("prop_speed"), record.q_addSpeed.."%")
		table.insert(attStrs, str)
	end

	if record.q_subAt then
		local str = formatStr2(game.getStrByKey("prop_subAt"), record.q_subAt)
		table.insert(attStrs, str)
	end

	if record.q_subMt then
		local str = formatStr2(game.getStrByKey("prop_subMt"), record.q_subMt)
		table.insert(attStrs, str)
	end

	if record.q_subDt then
		local str = formatStr2(game.getStrByKey("prop_subDt"), record.q_subDt)
		table.insert(attStrs, str)
	end

	if record.q_addAt then
		local str = formatStr2(game.getStrByKey("prop_addAt"), record.q_addAt)
		table.insert(attStrs, str)
	end

	if record.q_addMt then
		local str = formatStr2(game.getStrByKey("prop_addMt"), record.q_addMt)
		table.insert(attStrs, str)
	end

	if record.q_addDt then
		local str = formatStr2(game.getStrByKey("prop_addDt"), record.q_addDt)
		table.insert(attStrs, str)
	end

	local reverseTab = function(tab)
		local retTab = {}

		for i=#tab,1,-1 do
			retTab[#tab-i+1] = tab[i]
		end

		return retTab
	end

	--attStrs = reverseTab(attStrs)

	local pos = {cc.p(10, 130),
				 cc.p(10, 100), 
				 cc.p(10, 70),
				 cc.p(10, 40),
				 cc.p(10, 10),
				}
	local node = cc.Node:create()
	node:setContentSize(cc.size(260, #attStrs*30+10))
	node:setAnchorPoint(cc.p(0, 0))
	for i,v in ipairs(attStrs) do
		local richText = require("src/RichText").new(node, cc.p(10, (#attStrs*30+10)-i*30), cc.size(240, 30), cc.p(0, 0), 30, 20, MColor.white)
	    richText:addText(v, MColor.white, false)
	    richText:format()
	end

	return node
end

function RidingChangeNode:tableCellTouched(table, cell)
	-- local index = cell:getIdx()
	-- local record = self.data[index+1]

	-- if self.mainLayer and self.mainLayer.change then
	-- 	self.mainLayer:change(record)
	-- end
	log("111111111111111111111111")
	self.select = cell:getIdx()+1
	self.selectId = self.data[self.select]

	self:updateData()
end

function RidingChangeNode:cellSizeForTable(table, idx) 
    return 85, 90
end

function RidingChangeNode:tableCellAtIndex(table, idx)
	local id = self.data[idx+1]

	local cell = table:dequeueCell()

	local function createCellContent(cell)
		local icon = createPropIcon(cell, id, false, false, nil, false)
		icon:setAnchorPoint(cc.p(0, 0))
		icon:setPosition(cc.p(5, 0))
    end

    if nil == cell then
        cell = cc.TableViewCell:new()  
    else
    	cell:removeAllChildren()
    end
    createCellContent(cell)

    return cell
end

function RidingChangeNode:numberOfCellsInTableView(table)
   	return #self.data
end

function RidingChangeNode:networkHander(buff,msgid)
	local switch = {
		[EMOUNT_SC_MOUNT_SKIN_LIST] = function()
			log("get EMOUNT_SC_MOUNT_SKIN_LIST")
			local t = g_msgHandlerInst:convertBufferToTable("MountSkinlistRetProtocol", buff)
			self.data = {}
			dump(t.vecSkinId)
			for i,v in ipairs(t.vecSkinId) do
				table.insert(self.data, v)
			end
			dump(self.data)

			self:updateAttData()

			self:getTableView():reloadData()
			startTimerAction(self, 0.1, false, function() self:tableCellTouched(self:getTableView(), self:getTableView():cellAtIndex(0)) end) 
		end
		,
		[ITEM_SC_CHANGE_SKIN] = function()
			log("get ITEM_SC_CHANGE_SKIN")
			if G_RIDE_RIGHT_NODE and G_RIDE_RIGHT_NODE.refresh then
				G_RIDE_RIGHT_NODE:refresh(self.index)
			end

			if G_RIDE_LEFT_NODE and G_RIDE_LEFT_NODE.refresh then
				G_RIDE_LEFT_NODE:refresh(self.index)
			end

			removeFromParent(self)
		end
	}
	

 	if switch[msgid] then 
 		switch[msgid]()
 	end
end

return RidingChangeNode