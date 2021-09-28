local RidingSacrificeNode = class("RidingSacrificeNode", function() return cc.Node:create() end)

local MPackStruct = require "src/layers/bag/PackStruct"
local MpropOp = require "src/config/propOp"

function RidingSacrificeNode:ctor()
	local msgids = {EMOUNT_SC_SACRIFICE_INFO, ITEM_SC_SACRIFACE}
	require("src/MsgHandler").new(self,msgids)

	local t = {}
	dump(EMOUNT_CS_SACRIFICE_INFO)
	g_msgHandlerInst:sendNetDataByTable(EMOUNT_CS_SACRIFICE_INFO, "MountSacrificeBaseInfoProtocol", t)
	addNetLoading(EMOUNT_CS_SACRIFICE_INFO, EMOUNT_SC_SACRIFICE_INFO)

	self.data = {}
	self.selectItem = nil

	local bg = createSprite(self, "res/common/bg/bg27.png", cc.p(display.cx, display.cy), cc.p(0.5, 0.5))

	local closeFunc = function() 
		removeFromParent(self)
	end
	local closeBtn = createTouchItem(bg, "res/component/button/X.png", cc.p(bg:getContentSize().width-30, bg:getContentSize().height-30), closeFunc)

	createLabel(bg, game.getStrByKey("wr_sacrifice"), cc.p(bg:getContentSize().width/2, bg:getContentSize().height-25), cc.p(0.5, 0.5), 22, nil, nil, nil, MColor.lable_yellow)
	local showBg = createSprite(bg, "res/common/bg/bg44-5.png", cc.p(bg:getContentSize().width/2, 17), cc.p(0.5, 0))

	self.nameLabel = createLabel(showBg, "", cc.p(showBg:getContentSize().width/2, 425), cc.p(0.5, 0.5), 20, nil, nil, nil, MColor.lable_yellow)

	local helpBtn = __createHelp({parent = showBg, str=game.getStrByKey("wr_sacrifice_help"), pos=cc.p(30, showBg:getContentSize().height-30)})
	local function choseFunc()
		log("choseFunc")
		local Mreloading = require "src/layers/equipment/equip_select"
		local Manimation = require "src/young/animation"
		Manimation:transit(
		{
			node = Mreloading.new(
			{
				now = {},
				filtrate = function(packId, grid, now)
					local MequipOp = require "src/config/equipOp"
					local Mconvertor = require "src/config/convertor"
					
					local protoId = MPackStruct.protoIdFromGird(grid)
					-- -- 是否是勋章
					-- local isMedal = protoId >= 30004 and protoId <= 30006
					-- if MPackStruct.categoryFromGird(grid) ~= MPackStruct.eEquipment or isMedal then
					-- 	return false
					-- end
					
					-- local gridId = MPackStruct.girdIdFromGird(grid)
					-- local now_gridId = MPackStruct.girdIdFromGird(now.grid)
					-- if packId == now.packId and gridId == now_gridId then return false end
					
					-- local strengthLv = MPackStruct.attrFromGird(grid, MPackStruct.eAttrStrengthLevel)
					-- if strengthLv < 1 then return false end

					-- local quality = MpropOp.quality(protoId)
					-- if quality < 3 then return false end -- 蓝色品质以上才可传承

					dump(grid)
					dump(self.data)

					if MpropOp.category(protoId)==21 then
						--local result = true
						for i,v in ipairs(self.data.sacrificeTab) do
							local id = v[1]
							local value = v[2]
							if not (grid.mEachOfSpecialAttr[1] and grid.mEachOfSpecialAttr[1][id] 
								 and grid.mEachOfSpecialAttr[1][id] and grid.mEachOfSpecialAttr[1][id][1] 
								 and grid.mEachOfSpecialAttr[1][id][1].value and grid.mEachOfSpecialAttr[1][id][1].value >= value) then
								return false
							end

						end
						return true
					end
					return false
				end,
				handler = function(item)
					dump(item)
					self.selectItem = item
					self:updateData()
				end,
				
				act_src = "放入",
				leftBtns={"all", "ride"},
			}),
			sp = g_scrCenter,
			ep = g_scrCenter,
			--trend = "-",
			zOrder = 200,
			curve = "-",
			swallow = true,
		})
	end
	local choseBtn = createTouchItem(showBg, "res/component/button/48.png", cc.p(315, showBg:getContentSize().height-30), choseFunc)
	createLabel(choseBtn, game.getStrByKey("wr_sacrifice_change"), getCenterPos(choseBtn), cc.p(0.5, 0.5), 20, nil, nil, nil, MColor.lable_yellow)

	local function sacrificeFunc()
		log("SacrificeFunc")

		local t = {}
		t.dwBagId = self.selectItem.packId
		t.dwBagSlot = MPackStruct.girdIdFromGird(self.selectItem.grid)
		dump(t)
		g_msgHandlerInst:sendNetDataByTable(ITEM_CS_SACRIFICE, "ItemMountSacrificeProtocol", t)
	end
	local sacrificeBtn = createTouchItem(showBg, "res/component/button/2.png", cc.p(showBg:getContentSize().width/2, 40), sacrificeFunc)
	createLabel(sacrificeBtn, game.getStrByKey("wr_sacrifice_btn"), getCenterPos(sacrificeBtn), cc.p(0.5, 0.5), 22, nil, nil, nil, MColor.lable_yellow)

	self.attNode = cc.Node:create()
	showBg:addChild(self.attNode)
	self.attNode:setPosition(cc.p(0, 0))

	self.selectNode = cc.Node:create()
	showBg:addChild(self.selectNode)
	self.selectNode:setPosition(cc.p(0, 0))

	registerOutsideCloseFunc(bg, function() removeFromParent(self) end, true)
end

function RidingSacrificeNode:createRandomAttNode(randomAttr)
	-- "randomAttr" = {
	--      6 = {
	--          1 = {
	--              "id"    = 6
	--              "order" = 1
	--              "value" = 0
	--          }
	--      }
	--  }
	local nodes = {}

	local randomAttrsOrder = {}
	local randAttr = randomAttr or {}
	local randPropNum = #randAttr

	-- 解析随机属性
	local randPropSet = {}
	for i = 1, randPropNum do
		local cur = randAttr[i]
		local randPropID = cur[1]
		dump(randPropID, "randPropID")
		
		local randPropValue = cur[2]
		dump(randPropValue, "randPropValue")
		
		local set = randPropSet[randPropID]
		if not set then
			set = {}
			randPropSet[randPropID] = set
		end
		
		local item = {}
		item.id = randPropID
		item.value = randPropValue
		item.order = i
		
		set[#set+1] = item
		randomAttrsOrder[i] = item
	end

	randomAttr = randPropSet

	dump(randomAttr)

	if randomAttr then
		for k,v in pairs(randomAttr) do
			for k1,v1 in pairs(v) do
				--dump(v1)
				if v1.value > 0 then
					bHasRandom = true
					break
				end
			end
		end
	end

	if randomAttr and bHasRandom then
		-- 构建随机属性节点
		local buildRandomAttrNode = function(nLevel, key, value1, value2)
			--dump({value1=value1, value2=value2})
			local isRange = value2 ~= nil
			if value1 and ((isRange and value2 > 0) or (not isRange and value1 > 0)) then

				local text = "^c(lable_yellow)"..key.."^"..value1
				if value2 then
					text = text.."-"..value2
				end

				local richText = require("src/RichText").new(nil, cc.p(0, 0), cc.size(240, 30), cc.p(0.5, 0), 30, 20, MColor.white)
			    richText:addText(text)
			    richText:setAutoWidth()
			    richText:format()

			    return richText
			end
		end
	
		local addRandomAttrNode = function(title, attr_name, isRange)
			if isRange then
				local sum_l, sum_r, list, ids = MPackStruct.randomAttr(randomAttr, attr_name)
				-- print("ids")
				-- dump(ids)
				-- print("list")
				-- dump(list)
				for i = 1, #list do
					local nLevel = MPackStruct.getRandomAttrLevel(protoId, ids[i]["["], list[i]["["], list[i]["]"])
					local n_tmp = buildRandomAttrNode(nLevel,title, list[i]["["], list[i]["]"])
					if n_tmp ~= nil then table.insert(nodes, 1, n_tmp) end
				end
			else
				local sum, list, ids = MPackStruct.randomAttr(randomAttr, attr_name)
				-- print("ids")
				-- dump(ids)
				-- print("list")
				-- dump(list)
				for i = 1, #list do
					local nLevel = MPackStruct.getRandomAttrLevel(protoId, ids[i]["["], list[i])
					local n_tmp = buildRandomAttrNode(nLevel, title, list[i])
					if n_tmp ~= nil then table.insert(nodes, 1, n_tmp) end
				end
			end
		end
		
		addRandomAttrNode(game.getStrByKey("physical_attack_s")..": ", MPackStruct.eAttrPAttack, true)
		addRandomAttrNode(game.getStrByKey("magic_attack_s")..": ", MPackStruct.eAttrMAttack, true)
		addRandomAttrNode(game.getStrByKey("taoism_attack_s")..": ", MPackStruct.eAttrTAttack, true)
		addRandomAttrNode(game.getStrByKey("physical_defense_s")..": ", MPackStruct.eAttrPDefense, true)
		addRandomAttrNode(game.getStrByKey("magic_defense_s")..": ", MPackStruct.eAttrMDefense, true)
		addRandomAttrNode(game.getStrByKey("hp")..": ", MPackStruct.eAttrHP, false)
		addRandomAttrNode(game.getStrByKey("mp")..": ", MPackStruct.eAttrMP, false)
		addRandomAttrNode(game.getStrByKey("luck")..": ", MPackStruct.eAttrLuck, false)
		addRandomAttrNode(game.getStrByKey("my_hit")..": ", MPackStruct.eAttrHit, false)
		addRandomAttrNode(game.getStrByKey("dodge")..": ", MPackStruct.eAttrDodge, false)
		addRandomAttrNode(game.getStrByKey("strike")..": ", MPackStruct.eAttrStrike, false)
		addRandomAttrNode(game.getStrByKey("my_tenacity")..": ", MPackStruct.eAttrTenacity, false)
		addRandomAttrNode(game.getStrByKey("hu_shen_rift")..": ", MPackStruct.eAttrHuShenRift, false)
		addRandomAttrNode(game.getStrByKey("hu_shen")..": ", MPackStruct.eAttrHuShen, false)
		addRandomAttrNode(game.getStrByKey("freeze")..": ", MPackStruct.eAttrFreeze, false)
		addRandomAttrNode(game.getStrByKey("freeze_oppose")..": ", MPackStruct.eAttrFreezeOppose, false)
	end
	dump(#nodes)
	-- return nodes

	local richText = require("src/RichText").new(node, cc.p(0, 0), cc.size(240, 30), cc.p(0.5, 0), 30, 20, MColor.lable_yellow)
    richText:addText(game.getStrByKey("wr_sacrifice_condition"))
    richText:setAutoWidth()
    richText:format()
    table.insert(nodes, 1, richText)

	local node = cc.Node:create()
	node:setContentSize(cc.size(260, #nodes*30+75))
	node:setAnchorPoint(cc.p(0, 0))
	for i,v in ipairs(nodes) do
		node:addChild(v)
	    v:setPosition(cc.p(182, (#nodes*30+75)-i*30))

	 --    if i == 1 then
		--     local richText = require("src/RichText").new(node, cc.p(0, 0), cc.size(240, 30), cc.p(0, 0), 30, 20, MColor.lable_yellow)
		--     richText:addText(game.getStrByKey("wr_sacrifice_condition"))
		--     richText:format()
		--     richText:setPosition(cc.p(40, (#nodes*30+75)-i*30))
		-- end
	end

	return node
end

function RidingSacrificeNode:updateData()
	self:updateUI()
end

function RidingSacrificeNode:updateUI()
	self.attNode:removeAllChildren()

	local attNode = self:createRandomAttNode(self.data.sacrificeTab)
	self.attNode:addChild(attNode)

	if self.selectItem then
		local Mprop = require "src/layers/bag/prop"
		local srcIcon = Mprop.new(
		{
			grid = self.selectItem.grid,
			strengthLv = MPackStruct.attrFromGird(self.selectItem.grid, MPackStruct.eAttrStrengthLevel),
		})
		self.selectNode:removeAllChildren()
		self.selectNode:addChild(srcIcon)
		srcIcon:setPosition(cc.p(180, 250))

		self.nameLabel:setString(MpropOp.name(self.selectItem.mPropProtoId))
	end
end

function RidingSacrificeNode:networkHander(buff, msgid)
	local switch = {
		[EMOUNT_SC_SACRIFICE_INFO] = function()    
			local t = g_msgHandlerInst:convertBufferToTable("MountSacrificeBaseInfoRetProtocol", buff)
			self.data.isCanSacrifice = t.dwFlag
			dump(t.vecProperty)
			self.data.sacrificeTab = {}
			

			for i,v in ipairs(t.vecProperty) do
				table.insert(self.data.sacrificeTab, {v.nId, v.nCount})
			end
			--self.data.sacrificeTab = {{13, 5}, {14, 6}}
			dump(self.data)
			self:updateData()
		end
		,
		[ITEM_SC_SACRIFACE] = function()    
			log("ITEM_SC_SACRIFACE 1111111111111111111111111")
			local t = g_msgHandlerInst:convertBufferToTable("ItemMountSacrificeRetProtocol", buff)
			-- self.data.reward = {}
			-- for i,v in ipairs(t.vecRetItem) do
			--  	table.insert(self.data.reward, {v.propId, v.value})
			-- end 
			removeFromParent(self)
			dump(self.data)
		end
		,
	}

 	if switch[msgid] then 
 		switch[msgid]()
 	end
end

return RidingSacrificeNode