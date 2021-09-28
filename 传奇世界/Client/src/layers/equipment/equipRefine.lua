require("src/layers/newEquipment/NewEquipmentHandler")
-----------------------------------------------------------------------
-- 消耗道具
local costPtotoId = 1074 -- 洗练符
-----------------------------------------------------------------------
---------------------------------------------------------------------
-- 锁定的随机属性条数对应消耗的物品数量
local tCost = 
{
	[0] = 2,
	[1] = 4,
	[2] = 8,
	[3] = 15,
}
---------------------------------------------------------------------
local MColor = require "src/config/FontColor"

-- 随机属性表
local tRandomAttrCfg =  getConfigItemByKey("EquipRandPropDB", "q_id")
local RandomAttrItem = function(id)
	--local MpropOp = require "src/config/propOp"
	--local MequipOp = require "src/config/equipOp"
	--local job = MpropOp.schoolLimits(id)
	--local kind = MequipOp.kind(id)
	--local level, real = MpropOp.levelLimits(id)
	--level = real or level
	return tRandomAttrCfg[id]
end
--------------------------------------------------------
local tRandomAttrs = 
{
	[ROLE_MIN_AT] = { name = "物理攻击", max = "q_attack" },
	[ROLE_MAX_AT] = { name = "物理攻击", max = "q_attack" },
	[ROLE_MIN_DF] = { name = "物理防御", max = "q_defence" },
	[ROLE_MAX_DF] = { name = "物理防御", max = "q_defence" },
	[ROLE_MIN_MT] = { name = "魔法攻击", max = "q_magic_attack" },
	[ROLE_MAX_MT] = { name = "魔法攻击", max = "q_magic_attack" },
	[ROLE_MIN_MF] = { name = "魔法防御", max = "q_magic_defence" },
	[ROLE_MAX_MF] = { name = "魔法防御", max = "q_magic_defence" },
	[ROLE_MIN_DT] = { name = "道术攻击", max = "q_sc_attack" },
	[ROLE_MAX_DT] = { name = "道术攻击", max = "q_sc_attack" },
	--------------------
	[ROLE_MAX_HP] = { name = "生命", max = "q_max_hp" },
	[ROLE_MAX_MP] = { name = "法力", },
	[PLAYER_LUCK] = { name = "幸运", max = "q_luck" },
	[ROLE_HIT] = { name = "命中", max = "q_hit" },
	[ROLE_DODGE] = { name = "闪避", max = "q_dodge" },
	[ROLE_CRIT] = { name = "暴击", max = "q_crit" },
	[ROLE_TENACITY] = { name = "韧性", max = "q_tenacity" },
	[PLAYER_PROJECT_DEF] = { name = "护身穿透", max = "q_projectDef" },
	[PLAYER_PROJECT] = { name = "护身", max = "q_project" },
	[PLAYER_BENUMB] = { name = "冰冻", max = "q_benumb" },
	[PLAYER_BENUMB_DEF] = { name = "冰冻抵抗", max = "q_benumbDef" },
}

local tRandomAttrPairLeft = {
	[ROLE_MIN_AT] = true,
	[ROLE_MIN_DF] = true,
	[ROLE_MIN_MT] = true,
	[ROLE_MIN_MF] = true,
	[ROLE_MIN_DT] = true,
}

local tRandomAttrPairRight = {
	[ROLE_MAX_AT] = true,
	[ROLE_MAX_DF] = true,
	[ROLE_MAX_MT] = true,
	[ROLE_MAX_MF] = true,
	[ROLE_MAX_DT] = true,
}

local tRandomAttrLevelColor = {
	[1] = MColor.white,
	[2] = MColor.white,
	[3] = MColor.green,
	[4] = MColor.green,
	[5] = MColor.blue,
	[6] = MColor.blue,
	[7] = MColor.purple,
	[8] = MColor.purple,
}

local build_randomAttr = function(grid)
	-- 随机属性
	local randomAttrSet = MPackStruct.orderedRandomAttrFromGird(grid)
	dump(randomAttrSet, "randomAttrSet")
	
	local protoId = MPackStruct.protoIdFromGird(grid)
	local max_cfg = RandomAttrItem(protoId)
	--dump(protoId, "protoId")
	local source = {}
	for i, v in ipairs(randomAttrSet) do -- i = { order = order, value = value, id = id }
		local id = v.id
		if tRandomAttrPairLeft[id] then
			local item = {}
			item.name = tRandomAttrs[id].name
			item.order = v.order
			item.value = { ["["] = v.value }
			item.max_value = tonumber(max_cfg[tRandomAttrs[id].max]) or 0
			item.min_value = math.ceil(item.max_value/(tonumber(max_cfg.q_maxFloor) or 1))
			source[#source+1] = item
		elseif tRandomAttrPairRight[id] then
			local item = source[#source]
			if item == nil then
				dump({i = i, v=v, randomAttrSet=randomAttrSet}, "数据出错")
			end
			item.value["]"] = v.value
			item.isMax = item.max_value == v.value
			item.isMin = item.min_value == v.value
			
			local level = math.max(math.floor(v.value/(item.max_value/(tonumber(max_cfg.q_maxFloor) or 1))), 1)
			item.level = level
			item.levelColor = tRandomAttrLevelColor[level] or MColor.red
			
			local text = item.name .. "\n"
			text = text .. item.value["["] .. "-" .. item.value["]"]
			if item.isMax then
				text = text .. "(最大)"
			elseif item.isMin then
				--text = text .. "(最小)"
			end
			item.text = text
		elseif tRandomAttrs[id] then
			--dump(tRandomAttrs[id], "tRandomAttrs[id]")
			local item = {}
			item.name = tRandomAttrs[id].name
			item.order = v.order
			item.value = v.value
			item.max_value = tonumber(max_cfg[tRandomAttrs[id].max]) or 0
			item.min_value = math.ceil(item.max_value/(tonumber(max_cfg.q_maxFloor) or 1))
			item.isMax = item.max_value == v.value
			item.isMin = item.min_value == v.value
			
			local level = math.max(math.floor(v.value/(item.max_value/(tonumber(max_cfg.q_maxFloor) or 1))), 1)
			item.level = level
			
			if id == PLAYER_LUCK then
				item.levelColor = MColor.orange
			else
				item.levelColor = tRandomAttrLevelColor[level] or MColor.red
			end
			
			local text = item.name .. "\n"
			text = text .. item.value
			if item.isMax then
				text = text .. "(最大)"
			elseif item.isMin then
				--text = text .. "(最小)"
			end
			item.text = text
			source[#source+1] = item
		end
	end
	dump(source, "source")
	--------------------------------------------------------
	return source
end



local onRefineRet = function(root, new_grid, packId, gridId)
	local MMenuButton = require "src/component/button/MenuButton"
	--------------------------------------------------------
	local layer = root.layer
	removeFromParent(layer.n_click_menu)
	--------------------------------------------------------
	-- 原属性
	local new_source = build_randomAttr(new_grid)
	local nodes = layer.nodes
	local total = #nodes
	for i, v in ipairs(new_source) do
		local bg = nodes[total-i+1]
		if bg ~= nil then
			local bg_size = bg:getContentSize()
			Mnode.createLabel(
			{
				parent = bg,
				src = v.text,
				size = 18,
				color = v.levelColor,
				anchor = cc.p(0, 0.5),
				pos = cc.p(275, bg_size.height/2),
			})
		end
	end

	---------------------------------------------
	local saveBtn, cancelBtn = nil, nil
	local act_func = function(isSave)
		local t = {}
		t.bagIndex = packId
		t.itemIndex = gridId
		t.dealType = isSave and 1 or 2
		--dump(t, "t")
		g_msgHandlerInst:sendNetDataByTable(ITEM_CS_SUREBAPTIZE, "ItemSureBaptizeProtocol", t)
		
		saveBtn:setEnabled(false)
		cancelBtn:setEnabled(false)
	end
	
	-- 保存按钮
	saveBtn = MMenuButton.new(
	{
		parent = layer,
		src = {"res/component/button/2.png", "res/component/button/2_sel.png", "res/component/button/1_gray.png"},
		label = {
			src = game.getStrByKey("save"),
			size = 25,
			color = MColor.lable_yellow,
		},
		
		pos = cc.p(700, 62),
		
		cb = function(tag, node)
			act_func(true)
		end,
		
		--noInsane = 0.5,
	})
	G_TUTO_NODE:setTouchNode(saveBtn, TOUCH_WASH_SAVE)
	
	-- 取消按钮
	cancelBtn = MMenuButton.new(
	{
		parent = layer,
		src = {"res/component/button/1.png", "res/component/button/1_sel.png", "res/component/button/1_gray.png"},
		label = {
			src = game.getStrByKey("cancel"),
			size = 25,
			color = MColor.lable_yellow,
		},
		
		pos = cc.p(550, 62),
		
		cb = function(tag, node)
			act_func(false)
			node:setEnabled(false)
		end,
		
		--noInsane = 0.5,
	})
	G_TUTO_NODE:setTouchNode(cancelBtn, TOUCH_WASH_CANCEL)
end

local reloadView = nil

reloadView = function(root, params)
	local MMenuButton = require "src/component/button/MenuButton"
	local Mbaseboard = require "src/functional/baseboard"
	local MpropOp = require "src/config/propOp"
	local Mprop = require "src/layers/bag/prop"
	local MequipOp = require "src/config/equipOp"
	local Mconvertor = require "src/config/convertor"
	local Mcheckbox = require "src/component/checkbox/view"
	-----------------------------------------------------------------------
	local res = "res/layers/equipment/refine/"
	local bag = MPackManager:getPack(MPackStruct.eBag)
	local dress = MPackManager:getPack(MPackStruct.eDress)
	local bank = MPackManager:getPack(MPackStruct.eBank)
	-- 数据
	local packId = nil
	local grid = nil
	local protoId = nil
	local gridId = nil
	local strengthLv = nil
	local attr_locked = params.attr_locked

	local reloadData = function(params)
		--table.clear(attr_locked)
		packId = params.packId
		if packId then
			root.m_bubble:setVisible(false)
		else
			root.m_bubble:setVisible(true)
		end
		grid = params.grid
		protoId = MPackStruct.protoIdFromGird(grid)
		gridId = MPackStruct.girdIdFromGird(grid)
		strengthLv = MPackStruct.attrFromGird(grid, MPackStruct.eAttrStrengthLevel)
		--dump({grid=grid}, "grid")
	end

	reloadData(params)
	---------------------------------------------------------------------
	local layer = root.layer
    layer.attr_locked = attr_locked
	layer:removeAllChildren()
	local layer_size = layer:getContentSize()
	--------------------------------------------------------
	-- 物品图标
	local icon = Mprop.new(
	{
		grid = grid,
		strengthLv = strengthLv,
	})

	Mnode.addChild(
	{
		parent = layer,
		child = icon,
		pos = cc.p(626, 258),
	})

	MpropOp.createColorName(grid, layer, cc.p(626, 200), cc.p(0.5,0.5), 22)
	-- 道具消耗
	local n_cost = Mnode.createLabel(
	{
		src = "x" .. tCost[table.size(attr_locked)],
		size = 20,
		color = bag:countByProtoId(costPtotoId) >= tCost[table.size(attr_locked)] and MColor.green or MColor.red,
		parent = layer,
		anchor = cc.p(0, 0.5),
		pos = cc.p(130, 120),
	})
	
	n_cost_refresh = function()
		n_cost:setString("x" .. tCost[table.size(attr_locked)] .. game.getStrByKey("entry"))
        n_cost:setColor(bag:countByProtoId(costPtotoId) >= tCost[table.size(attr_locked)] and MColor.green or MColor.red)
	end
	
	layer.n_cost = n_cost
	--------------------------------------------------------
	-- 原属性
	local source = build_randomAttr(grid)
	local nodes = {}
	for i, v in ipairs(source) do
		local lock = cc.Sprite:create("res/component/checkbox/4.png")
		local bg = cc.Sprite:create("res/common/bg/titleLine3.png")
		local bg_size = bg:getContentSize()
		local status = attr_locked[i]
		local idx = i
		
		if status then lock:setTexture("res/component/checkbox/4-1.png") end
		
		Mnode.createLabel(
		{
			parent = bg,
			src = v.text,
			size = 18,
			color = v.levelColor,
			anchor = cc.p(0, 0.5),
			pos = cc.p(46, bg_size.height/2),
		})
		
		-- 箭头
		local arrows = Mnode.createSprite(
		{
			parent = bg,
			src = "res/group/arrows/17.png",
			scale = 0.55,
			pos = cc.p(bg_size.width/2, bg_size.height/2),
		})
		
		Mnode.addChild(
		{
			parent = bg,
			child = lock,
			anchor = cc.p(0, 0.5),
			pos = cc.p(5, bg_size.height/2),
		})
		
		-- 监听触摸事件
		Mnode.listenTouchEvent(
		{
			swallow = false,
			node = bg,
			begin = function(touch, event)
				local node = event:getCurrentTarget()
				if node.catch then return false end
			
				local inside = Mnode.isTouchInNodeAABB(node, touch)
				if inside then
					return true
				end
				
				return false
			end,
			
			ended = function(touch, event)
				local node = event:getCurrentTarget()
				node.catch = false
				
				if Mnode.isTouchInNodeAABB(node, touch) then
					AudioEnginer.playTouchPointEffect()
					status = not status
					--dump(status, "status")
					if status then
						--dump({lock=table.size(attr_locked), all=#source})
						if table.size(attr_locked) < #source-1 then
							attr_locked[idx] = true
							n_cost_refresh()
						else
							status = false
							TIPS({ type = 1  , str = "不能锁定全部属性" })
						end
					else
						if table.size(attr_locked) > 0 then
							attr_locked[idx] = nil
							n_cost_refresh()
						else
							dump("发生了什么？")
						end
					end
					
					lock:setTexture("res/component/checkbox/" .. (status and "4-1" or "4") .. ".png")
				end
			end,
		})
		
		table.insert(nodes, 1, bg)
	end
	
	layer.nodes = nodes

	local randomAttrNode = Mnode.combineNode(
	{
		nodes = nodes,
		ori = "|",
		align = "l",
		margins = 7,
	})

	Mnode.addChild(
	{
		parent = layer,
		child = randomAttrNode,
		anchor = cc.p(0, 1),
		pos = cc.p(30, 420),
	})
	--------------------------------------------------------
	-- 洗练按钮
	local n_click_menu, n_click_btn = MMenuButton.new(
	{
		parent = layer,
		src = {"res/component/button/2.png", "res/component/button/2_sel.png", "res/component/button/1_gray.png"},
		label = {
			src = game.getStrByKey("refine"),
			size = 25,
			color = MColor.lable_yellow,
		},
		
		pos = cc.p(626, 62),
		
		cb = function(tag, node)
			local t = {}
			t.bagIndex = packId
			t.itemIndex = gridId
			t.bindPropNum = table.size(attr_locked)
			local x = {}
			for i, v in ipairs(source) do
				if attr_locked[i] == nil then
					x[#x+1] = v.order
				end
			end
			t.indexData = x
			--dump(t, "t")
			g_msgHandlerInst:sendNetDataByTable(ITEM_CS_BAPTIZE, "ItemBaptizeProtocol", t)
			log("send msg".. ITEM_CS_BAPTIZE)
			node:setEnabled(false)
		end,
		
		--noInsane = 0.5,
	})
	G_TUTO_NODE:setTouchNode(n_click_menu, TOUCH_WASH_WASH)
	
	layer.n_click_menu = n_click_menu
	--------------------------------------------------------
	
	local onSuccess = function(root)
		AudioEnginer.playEffect("sounds/upSuccess.mp3",false)
		local animateSpr = Effects:create(false)
		performWithDelay(animateSpr,function() removeFromParent(animateSpr) animateSpr = nil end,1.9)
		animateSpr:playActionData("equipRefine", 27, 1.9, 1)
		Mnode.addChild(
		{
			parent = root,
			child = animateSpr,
			pos = cc.p(626, 258),
			zOrder = 1000,
		})
	end

	local tmp_node = cc.Node:create()
	local onPackChanged = function(pack, event, id)
		if (pack:packId() == packId) and (id == gridId) and (event == "=" or event == "+") then
			local new_grid = pack:getGirdByGirdId(id)
			grid = new_grid
			reloadView(root, {packId=packId, grid=new_grid, attr_locked=attr_locked})
			onSuccess(root)
		end
	end
	tmp_node:registerScriptHandler(function(event)
		local pack = MPackManager:getPack(packId)
		if event == "enter" then
			
			pack:register(onPackChanged)
			g_msgHandlerInst:registerMsgHandler(ITEM_SC_BAPTIZE_RET, function(buff)
				dump("装备洗练返回")
				
				local t = g_msgHandlerInst:convertBufferToTable("ItemBaptizeRetProtocol", buff)
				--dump(t, "装备洗练返回")
				local attrs = t.attrs
				
				local copy = {}
				for k, v in pairs(grid) do
					copy[k] = v
				end
				
				local eachOfSpecialAttr = {}
				for k, v in pairs(grid.mEachOfSpecialAttr) do
					eachOfSpecialAttr[k] = v
				end
				
				copy.mEachOfSpecialAttr = eachOfSpecialAttr
				
				local randomAttrsOrder = {}
				copy.mRandomAttrsOrder = randomAttrsOrder

				
				local randPropSet = {}
				local randPropNum = #attrs
				--dump(randPropNum, "randPropNum")
				for i = 1, randPropNum do
					local cur = attrs[i]
					local randPropID = cur.propId
					--dump(randPropID, "randPropID")
					
					local randPropValue = cur.value
					--dump(randPropValue, "randPropValue")
					
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
				
				eachOfSpecialAttr[1] = randPropSet
				
				onRefineRet(root, copy, packId, gridId)
			end)

			g_msgHandlerInst:registerMsgHandler(ITEM_SC_SUREBAPTIZE_RET, function(buff)
				dump("保存或者取消洗炼装备的返回")
				
				local t = g_msgHandlerInst:convertBufferToTable("ItemSureBaptizeRetProtocol", buff)
				--dump(t, "保存或者取消洗炼装备的返回")
				
				local cate = t.dealType
				dump({cate=cate}, "cate")
				local pid = t.bagIndex
				local gid = t.itemIndex
				local theSame = t.isSame
				
				if pid ~= packId or gid ~= gridId then
					--dump({pid=pid, gid=gid, packId=packId, gridId=gridId})
					return 
				end
				if cate == 2 then reloadView(root, {packId=packId, grid=grid, attr_locked=attr_locked}) end -- 取消
				if cate == 1 and theSame then reloadView(root, {packId=packId, grid=grid, attr_locked=attr_locked}) end --保存
			end)
		elseif event == "exit" then
			pack:unregister(onPackChanged)
			g_msgHandlerInst:registerMsgHandler(ITEM_SC_BAPTIZE_RET, nil)
			g_msgHandlerInst:registerMsgHandler(ITEM_SC_SUREBAPTIZE_RET, nil)
		end
	end)
	layer:addChild(tmp_node)
	--------------------------------------------------------
end

return { new = function(params)
-----------------------------------------------------------------------
local MMenuButton = require "src/component/button/MenuButton"
local Mbaseboard = require "src/functional/baseboard"
local MpropOp = require "src/config/propOp"
local Mprop = require "src/layers/bag/prop"
local MequipOp = require "src/config/equipOp"
local Mconvertor = require "src/config/convertor"
local Mcheckbox = require "src/component/checkbox/view"
-----------------------------------------------------------------------
local res = "res/layers/equipment/refine/"
local bag = MPackManager:getPack(MPackStruct.eBag)
local dress = MPackManager:getPack(MPackStruct.eDress)
local bank = MPackManager:getPack(MPackStruct.eBank)
-----------------------------------------------------------------------
local now_item = {packId=params.packId, grid=params.grid, attr_locked = {}}
local rootBg = Mbaseboard.new(
{
	src = "res/common/bg/bg18.png",
	close = {
		src = {"res/component/button/x2.png", "res/component/button/x2_sel.png"},
		offset = { x = -8, y = 4 },
	},
	title = {
		src = game.getStrByKey("refine"),
		size = 25,
		color = MColor.lable_yellow,
		offset = { y = -25 },
	},
})

rootBg:registerScriptHandler(function(event)
	if event == "enter" then
		clearDirect()
		setEquipRedirect(true)
	elseif event == "exit" then
		trigEquipRedirect()
	end
end)

G_TUTO_NODE:setTouchNode(rootBg.closeBtn, TOUCH_WASH_CLOSE)

local rootSize = rootBg:getContentSize()


local center = cc.p(rootSize.width/2+2, rootSize.height/2-20)
-- 背景图
-- Mnode.createScale9Sprite(
-- {
-- 	parent = rootBg,
-- 	src = "res/common/scalable/panel_outer_base.png",
-- 	cSize = cc.size(rootSize.width-60, rootSize.height-74),
-- 	pos = center,
-- })
 createScale9Frame(
        rootBg,
        "res/common/scalable/panel_outer_base.png",
        "res/common/scalable/panel_outer_frame_scale9.png",
        cc.p(33, 17),
       	cc.size(rootSize.width-60, rootSize.height-74),
        5
    )
local root=cc.Node:create()
root:setPosition(cc.p(18,0))
rootBg:addChild(root)

-----------------------------------------------------------------------
local left_bg = createScale9Sprite(
        root,
        "res/common/scalable/panel_inside_scale9.png",
        cc.p(25, 24),
        cc.size(422, 436),
        cc.p(0, 0)
    )

local right_bg = Mnode.createSprite(
{
	parent = root,
	src = "res/common/bg/bg44-4.png",
	pos = cc.p(626, 242),
})

local title = Mnode.createSprite(
{
	parent = root,
	src = "res/common/bg/bg44-3-2.png",
	pos = cc.p(236, 155),
})

-- 当前信息标题
Mnode.createLabel(
{
	parent = root,
	src = "消耗",
	size = 22,
	color = MColor.lable_yellow,
	pos = cc.p(236, 155),
})

local separator = createTitleLine(root, cc.p(236, 88), 396, cc.p(0.5,0.5))


-- 原极品属性
Mnode.createLabel(
{
	parent = root,
	src = "原洗炼属性",
	size = 22,
	color = MColor.lable_yellow,
	pos = cc.p(90, 440),
})

-- 新极品属性
Mnode.createLabel(
{
	parent = root,
	src = "新洗炼属性",
	size = 22,
	color = MColor.lable_yellow,
	pos = cc.p(330, 440),
})
--------------------------------------------------------
-- 道具消耗
local own_num = bag:countByProtoId(costPtotoId)

local n_material = Mnode.createLabel(
{
	parent = root,
	src = MpropOp.name(costPtotoId),
	size = 20,
	color = MpropOp.nameColor(costPtotoId),
	anchor = cc.p(0, 0.5),
	pos = cc.p(56, 120),
})

--加入超链接下方的横线
drawUnderLine(n_material, MpropOp.nameColor(costPtotoId))
-- local label = cc.Label:createWithTTF("_", g_font_path, 20)
-- label:setAnchorPoint(cc.p(0, 0))
-- label:setPosition(cc.p(n_material:getPositionX(), n_material:getPositionY() - 15))
-- local scale = n_material:getContentSize().width / label:getContentSize().width
-- label:setScaleX(scale)
-- label:setColor(MpropOp.nameColor(costPtotoId))
-- n_material:getParent():addChild(label)

-- 监听触摸事件
Mnode.listenTouchEvent(
{
	swallow = false,
	node = n_material,
	begin = function(touch, event)
		local node = event:getCurrentTarget()
		if node.catch then return false end
	
		local inside = Mnode.isTouchInNodeAABB(node, touch)
		if inside then
			return true
		end
		
		return false
	end,
	
	ended = function(touch, event)
		local node = event:getCurrentTarget()
		node.catch = false
		
		if Mnode.isTouchInNodeAABB(node, touch) then
			AudioEnginer.playTouchPointEffect()
			local Mtips = require "src/layers/bag/tips"
			Mtips.new(
			{
				protoId = costPtotoId,
			})
		end
	end,
})

-- 拥有材料数目
local own_material = Mnode.createKVP(
{
	k = Mnode.createLabel(
	{
		src = game.getStrByKey("own").."：",
		size = 19,
		color = MColor.white,
	}),
	
	v = {
		src = own_num,
		size = 19,
		color = MColor.lable_yellow,
	},
})

local tmp_func = function(observable, event, pos, pos1, new_grid)
	if event == "-" or event == "+" or event == "=" then
		own_num = bag:countByProtoId(costPtotoId)
		own_material:setValue(
		{
			text = own_num,
			color = MColor.lable_yellow,
		})
        --点击洗炼以后，洗炼符减少，立即导致的刷新，与点击保存才触发reloadView导致的刷新不同
        if root.layer and root.layer.n_cost and root.layer.attr_locked then
            root.layer.n_cost:setColor(bag:countByProtoId(costPtotoId) >= tCost[table.size(root.layer.attr_locked)] and MColor.green or MColor.red)
        end
	end
end

own_material:registerScriptHandler(function(event)
	if event == "enter" then
		bag:register(tmp_func)
	elseif event == "exit" then
		bag:unregister(tmp_func)
	end
end)

Mnode.addChild(
{
	parent = root,
	child = own_material,
	anchor = cc.p(0, 0.5),
	pos = cc.p(234, 120),
})
--------------------------------------------------------
-- 加号
Mnode.createSprite(
{
	parent = root,
	src = "res/layers/equipment/jia.png",
	pos = cc.p(626, 258),
})
root.m_bubble = GetUIHelper():createBubble(root, cc.p(626, 330), cc.p(0.5, 0.5), nil, "请添加要洗炼的装备", 20, false, nil, MColor.lable_yellow, true)
local placeholder = Mnode.createNode(
{
	parent = root,
	cSize = cc.size(80, 80),
	pos = cc.p(626, 258),
})

G_TUTO_NODE:setTouchNode(placeholder,TOUCH_WASH_ADDWEAPON)

-- 提示信息
local n_jia_tips = Mnode.createLabel(
{
	parent = root,
	src = "选择需要洗炼的装备",
	pos = cc.p(625, 115),
	size = 20,
	color = MColor.lable_yellow,
})

n_jia_tips:setVisible(now_item.packId == nil)

-- 监听触摸事件
Mnode.listenTouchEvent(
{
	swallow = false,
	node = placeholder,
	begin = function(touch, event)
		local node = event:getCurrentTarget()
		if node.catch then return false end
	
		local inside = Mnode.isTouchInNodeAABB(node, touch)
		if inside then
			return true
		end
		
		return false
	end,
	
	ended = function(touch, event)
		local node = event:getCurrentTarget()
		node.catch = false
		
		if Mnode.isTouchInNodeAABB(node, touch) then
			AudioEnginer.playTouchPointEffect()
			
			local Mreloading = require "src/layers/equipment/equip_select"
			local Manimation = require "src/young/animation"
			Manimation:transit(
			{
				node = Mreloading.new(
				{
					now = now_item,
					filtrate = function(packId, grid, now)
						local MequipOp = require "src/config/equipOp"
						local MpropOp = require "src/config/propOp"
						local Mconvertor = require "src/config/convertor"
						
						local protoId = MPackStruct.protoIdFromGird(grid)
						-- 是否是勋章
						local isMedal = protoId >= 30004 and protoId <= 30006
						if MPackStruct.categoryFromGird(grid) ~= MPackStruct.eEquipment or isMedal then
							return false
						end
						
						local gridId = MPackStruct.girdIdFromGird(grid)
						local now_gridId = MPackStruct.girdIdFromGird(now.grid)
						if packId == now.packId and gridId == now_gridId then return false end
						
						local randomAttrSet = MPackStruct.attrFromGird(grid, MPackStruct.eAttrRandom)
						return randomAttrSet ~= nil
					end,
					handler = function(item)
						now_item = item
						now_item.attr_locked = {}
						n_jia_tips:setVisible(false)
						reloadView(root, item)
					end,
					
					act_src = "放入",
				}),
				sp = g_scrCenter,
				ep = g_scrCenter,
				--trend = "-",
				zOrder = 200,
				curve = "-",
				swallow = true,
			})
		end
	end,
})
-----------------------------------------------------------------------
-- 变化层
local layer = Mnode.createNode({ cSize = rootSize })
Mnode.addChild(
{
	parent = root,
	child = layer,
	pos = cc.p(rootSize.width/2, rootSize.height/2),
})
root.layer = layer

if now_item.packId ~= nil then
	reloadView(root, now_item)
else
	-- local nodes = {}
	-- for i = 1,4 do
	-- 	local bg = cc.Sprite:create("res/common/bg/titleLine3.png")
	-- 	local bg_size = bg:getContentSize()
		
	-- 	-- 箭头
	-- 	Mnode.createSprite(
	-- 	{
	-- 		parent = bg,
	-- 		src = "res/group/arrows/17.png",
	-- 		scale = 0.55,
	-- 		pos = cc.p(bg_size.width/2, bg_size.height/2),
	-- 	})
		
	-- 	nodes[#nodes+1] = bg
	-- end
	
	-- local randomAttrNode = Mnode.combineNode(
	-- {
	-- 	nodes = nodes,
	-- 	ori = "|",
	-- 	align = "l",
	-- 	margins = 7,
	-- })

	-- Mnode.addChild(
	-- {
	-- 	parent = layer,
	-- 	child = randomAttrNode,
	-- 	anchor = cc.p(0, 1),
	-- 	pos = cc.p(30, 420),
	-- })
end

__createHelp({
    parent = root,
	str = require("src/config/PromptOp"):content(70),
	pos = cc.p(750, 420)
})
-----------------------------------------------------------------------
G_TUTO_NODE:setShowNode(root, SHOW_WASH)
-----------------------------------------------------------------------
return rootBg
end }