local Myoung = require "src/young/young"; local M = Myoung.beginModule(...)

local tConsignCfg = require("src/config/ConsignCfg")

local tConsign = 
{
	code = -1,
	name = game.getStrByKey("classification"),
	list = {}
}

local rTree = tConsign.list

for i, v in ipairs(tConsignCfg) do
	local coordinate = string.mysplit(v.pos .. "" , ",")
	
	local p1, p2, p3 = tonumber(coordinate[1]), tonumber(coordinate[2]), tonumber(coordinate[3])
	--dump({p1=p1, p2=p2, p3=p3}, "coordinate")
	local target = nil
	if p1 then
		target = rTree[p1] -- { [p1] = {} }
		if not target then
			target = {}
			rTree[p1] = target
		end
		
		if p2 then
			local list = target.list
			if not list then
				list = {}
				target.list = list
			end  -- { [p1] = { list = {} } }
			
			target = list[p2] -- { [p1] = { list = { [p2] = {} } } }
			if not target then
				target = {}
				list[p2] = target
			end
			
			if p3 then
				local list = target.list
				if not list then
					list = {}
					target.list = list
				end
				
				target = list[p3]
				if not target then
					target = {}
					list[p3] = target
				end
			end
		end
	end
	
	if target then
		target.name = v.name
		target.code = v.code
	end
end

--dump(tConsign, "tConsign")

--[[
local tConsign = 
{
	code = -1,
	name = "分类搜索",
	list = 
	{
		[1] = 
		{
			code = -2,
			name = "全部",
		},
		
		[2] = 
		{
			code = 100,
			name = "装备",
			list = 
			{
				[1] = 
				{
					code = 110,
					name = "战士",
					list = 
					{
						[1] = 
						{
							code = 111,
							name = "武器",
						},
						
						[2] = 
						{
							code = 112,
							name = "戒指",
						},
						
						[3] = 
						{
							code = 113,
							name = "项链",
						},
						
						[4] = 
						{
							code = 114,
							name = "鞋子",
						},
						
						[5] = 
						{
							code = 115,
							name = "衣服",
						},
						
						[6] = 
						{
							code = 116,
							name = "手镯",
						},
						
						[7] = 
						{
							code = 117,
							name = "头盔",
						},
						
						[8] = 
						{
							code = 118,
							name = "腰带",
						},
					},
				},
				
				[2] = 
				{
					code = 120,
					name = "法师",
					list = 
					{
						[1] = 
						{
							code = 121,
							name = "武器",
						},
						
						[2] = 
						{
							code = 122,
							name = "戒指",
						},
						
						[3] = 
						{
							code = 123,
							name = "项链",
						},
						
						[4] = 
						{
							code = 124,
							name = "鞋子",
						},
						
						[5] = 
						{
							code = 125,
							name = "衣服",
						},
						
						[6] = 
						{
							code = 126,
							name = "手镯",
						},
						
						[7] = 
						{
							code = 127,
							name = "头盔",
						},
						
						[8] = 
						{
							code = 128,
							name = "腰带",
						},
					},
				},
				
				[3] = 
				{
					code = 130,
					name = "道士",
					list = 
					{
						[1] = 
						{
							code = 131,
							name = "武器",
						},
						
						[2] = 
						{
							code = 132,
							name = "戒指",
						},
						
						[3] = 
						{
							code = 133,
							name = "项链",
						},
						
						[4] = 
						{
							code = 134,
							name = "鞋子",
						},
						
						[5] = 
						{
							code = 135,
							name = "衣服",
						},
						
						[6] = 
						{
							code = 136,
							name = "手镯",
						},
						
						[7] = 
						{
							code = 137,
							name = "头盔",
						},
						
						[8] = 
						{
							code = 138,
							name = "腰带",
						},
					},
				},
			},
		},
		
		[3] = 
		{
			code = 20,
			name = "货币",
			list = 
			{
				[1] = 
				{
					code = 21,
					name = "元宝",
				},
				
				[2] = 
				{
					code = 22,
					name = "金币",
				},
			},
		},
		
		[4] = 
		{
			code = 30,
			name = "秘籍",
			list = 
			{
				[1] = 
				{
					code = 31,
					name = "全部职业",
				},
				
				[2] = 
				{
					code = 32,
					name = "战士",
				},
				
				[3] = 
				{
					code = 33,
					name = "法师",
				},
				
				[4] = 
				{
					code = 34,
					name = "道士",
				},
				
				[5] = 
				{
					code = 35,
					name = "光翼",
				},
				
				[6] = 
				{
					code = 36,
					name = "坐骑",
				},
				
				[7] = 
				{
					code = 37,
					name = "元神战甲",
				},
				
				[8] = 
				{
					code = 38,
					name = "元神战刃",
				},
			},
		},
		
		[5] = 
		{
			code = 40,
			name = "材料",
			list = 
			{
				[1] = 
				{
					code = 41,
					name = "进阶材料",
				},
				
				[2] = 
				{
					code = 42,
					name = "潜能丹",
				},
				
				[3] = 
				{
					code = 43,
					name = "真气",
				},
				
				[4] = 
				{
					code = 44,
					name = "经验",
				},
				
				[5] = 
				{
					code = 45,
					name = "装备",
				},
				
				[6] = 
				{
					code = 46,
					name = "翡翠",
				},
				
				[7] = 
				{
					code = 47,
					name = "药品",
				},
				
				[8] = 
				{
					code = 48,
					name = "其他",
				},
			},
		},
	}
}
--]]


new = function(params)
	local res = "res/layers/consign/"
	local Mbaseboard = require "src/functional/baseboard"
	local MMenuButton = require "src/component/button/MenuButton"
	local MConsignOp = require "src/layers/consign/ConsignOp"
	---------------------------------------------------------------
	local root = Mnode.createNode({ cSize = cc.size(960, 640) })
	
	local rootSize = root:getContentSize()
	
	---------------------------------------------------------------
	local left_bg_size = cc.size(110, 515)
	local left_bg = createScale9Frame(
        root,
        "res/common/scalable/panel_outer_base.png",
        "res/common/scalable/panel_outer_frame_scale9.png",
        cc.p(28, 30),
        left_bg_size,
        5
    )
	-- cc.Sprite:create("res/common/bg/buttonBg3.png") -- 122x536
	

	-- Mnode.addChild(
	-- {
	-- 	parent = root,
	-- 	child = left_bg,
	-- 	anchor = cc.p(1, 0.5),
	-- 	pos = cc.p(138, 288),
	-- })
	local right_bg_size = cc.size(795, 515)
	local right_bg = createScale9Frame(
        root,
        "res/common/scalable/panel_outer_base.png",
        "res/common/scalable/panel_outer_frame_scale9.png",
        cc.p(142, 30),
        right_bg_size,
        5
    )
	-- cc.Sprite:create("res/common/bg/bg12.png")
	-- local right_bg_size = right_bg:getContentSize()

	-- Mnode.addChild(
	-- {
	-- 	parent = root,
	-- 	child = right_bg,
	-- 	anchor = cc.p(0, 0.5),
	-- 	pos = cc.p(134, 288),
	-- })
	
	-- 空列表提示
	local n_empty_list_tips = Mnode.createLabel(
	{
		src = "您要找的商品暂无上架",
		parent = right_bg,
		pos = cc.p(right_bg_size.width/2, right_bg_size.height/2),
		size = 21,
		color = MColor.white,
	})
	---------------------------------------------------------------
	-- 构建left view
	---------------------------------------------------------------
	-- 前置声明与定义
	local inputEditbox = nil
	---------------------------------------------------------------
	local title_bg = cc.Sprite:create("res/component/TabControl/9.png")
	local title_bg_size = title_bg:getContentSize()
	Mnode.addChild(
	{
		parent = left_bg,
		child = title_bg,
		anchor = cc.p(0.5, 1),
		pos = cc.p(left_bg_size.width/2, left_bg_size.height-5),
	})
	
	local title = Mnode.createLabel(
	{
		src = tConsign.name,
		size = 25,
		color = MColor.lable_yellow,
	})
	
	Mnode.addChild(
	{
		parent = title_bg,
		child = title,
		--anchor = cc.p(0, 0.5),
		pos = cc.p(title_bg_size.width/2, title_bg_size.height/2),
	})
    title_bg:setVisible(false)
	-- 数据
	---------------------------------------------------------------
	local search_mode = false -- 分类搜索模式 | 关键字搜索模式
	local search_mode_key = ""
	local search_list = {}
	---
	local tab_switched = false
	local isAscendingOrder = true
    local subIndex = -1
	local stack = require("src/young/util/stack"):new()
	stack:push({ branch = tConsign, leaf = 0, })
	
	local getDataAtIdx = function(idx)
		local branch = stack:top().branch
		return branch.list[idx+1]
	end
	
	local getCurItem = function()
		local value = stack:top()
		local leaf = value.leaf
		local branch = value.branch
		
		local ret = nil
		if leaf ~= nil then
			ret = branch.list[leaf+1]
		else
			ret = branch
		end
		
		--dump(ret, "ret")
		return ret
	end

	local setRidoBoxVisible
    local switchTabNew
	local switchTab = function(retainOrder)
		--if not retainOrder then isAscendingOrder = true end
		
		if not search_mode then
			local item = getCurItem()
			print("item.code = ........................",item.code,isAscendingOrder)
            -- check whether should call switchTabNew 
            if item.code == 100 then
                switchTabNew(110)
                return
            elseif item.code == 30 then
                switchTabNew(37)
                return
            elseif item.code == 40 then
                switchTabNew(45)
                return
            end
            -- check end
            MConsignOp:query(item.code, 0, isAscendingOrder)
            subIndex = -1
            local qType = 0
            --[[
            if item.code == 100 or item.code == 110 or item.code == 120 or item.code == 130 then    -- 110 120 130
                qType = 1
            elseif item.code == 30 or item.code == 37 or item.code == 38 then       -- 37 38
                qType = 2               
            elseif item.code == 40 or item.code == 45 or item.code == 46 or item.code == 47 or item.code == 48 then     -- 45 46 47 48
                qType = 3               
            end
            ]]
            setRidoBoxVisible(qType)
		else
			MConsignOp:search(search_mode_key, 0, isAscendingOrder, search_list)
		end
		
		tab_switched = true
	end
	---------------------------------------------------------------
    ---------------------------------------------------------------
    -- radio click
    switchTabNew = function(sType)
		if not search_mode then
            print("ttttttttttttttttttttttttttttttttttttttttttttt")
            print("sType =====================",sType)
            MConsignOp:query(sType, 0, isAscendingOrder)
            subIndex = sType
            if setRidoBoxVisible then
                local qType = 0
                if sType == 100 or sType == 110 or sType == 120 or sType == 130 then    -- 110 120 130
                    qType = 1
                elseif sType == 30 or sType == 37 or sType == 38 then       -- 37 38
                    qType = 2               
                elseif sType == 40 or sType == 45 or sType == 46 or sType == 47 or sType == 48 then     -- 45 46 47 48
                    qType = 3               
                end
                setRidoBoxVisible(qType)
            end
            
		else
			MConsignOp:search(search_mode_key, 0, isAscendingOrder, search_list)
		end
		
		tab_switched = true
	end
    ---------------------------------------------------------------
	
	-- 前向声明
	local reloadListData = nil
	--local backBtn = nil
	---------------------------------------------------------------
	-- TableView 分类菜单
	local iSize = cc.size(104, 68)
	local vSize = cc.size(104, 370)
	local tableView = cc.TableView:create(vSize)
	tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
	tableView:setDelegate()
	
	
	local SCROLLVIEW_SCRIPT_SCROLL = function(tv)
		local value = stack:top()
		value.pos = tv:getContentOffset()
	end
	
	local reloadData = function()
		tableView:registerScriptHandler(function(tv) end, cc.SCROLLVIEW_SCRIPT_SCROLL)
		tableView:reloadData()
		local pos = stack:top().pos
		if pos then tableView:setContentOffset(pos) end
		tableView:registerScriptHandler(SCROLLVIEW_SCRIPT_SCROLL, cc.SCROLLVIEW_SCRIPT_SCROLL)
	end
	
	tableView:registerScriptHandler(function(tv)
		local branch = stack:top().branch
		return #branch.list
	end, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	
	tableView:registerScriptHandler(function(tv, idx)
		return iSize.height, iSize.width
	end, cc.TABLECELL_SIZE_FOR_INDEX)
	
	local buildCellContent = nil
	tableView:registerScriptHandler(function(tv, idx)
		local cell = tv:dequeueCell()
		if not cell then
			cell = cc.TableViewCell:new()
			cell:setContentSize(iSize)
			buildCellContent(tv, idx, cell)
		else
			buildCellContent(tv, idx, cell)
		end
		return cell
	end, cc.TABLECELL_SIZE_AT_INDEX)
	
	tableView:registerScriptHandler(function(tv, cell)
		cell:removeAllChildren()
	end, cc.TABLECELL_WILL_RECYCLE)
	
	tableView:registerScriptHandler(function(tv, cell)
		local idx = cell:getIdx()
		local leaf = stack:top().leaf
		
		local content = cell:getChildByTag(1)
		if idx ~= leaf and content then
			content:setTexture("res/component/TabControl/10.png")
		end
		--dump("TABLECELL_HIGH_LIGHT")
	end, cc.TABLECELL_HIGH_LIGHT)
	
	tableView:registerScriptHandler(function(tv, cell)
		local idx = cell:getIdx()
		local leaf = stack:top().leaf
		
		local content = cell:getChildByTag(1)
		if idx ~= leaf and content then
			content:setTexture("res/component/TabControl/9.png")
		end
		--dump("TABLECELL_UNHIGH_LIGHT")
	end, cc.TABLECELL_UNHIGH_LIGHT)
	
	buildCellContent = function(tv, idx, cell)
		local cur = getDataAtIdx(idx)
		local top = stack:top()
		
        if not cur then
            return
        end

		local isLeaf = cur.list == nil
		
		local size = cell:getContentSize()
		local bg = Mnode.createSprite(
		{
			src = "res/component/TabControl/" .. (idx == top.leaf and "10" or "9") .. ".png",
			parent = cell,
			pos = cc.p(size.width/2, size.height/2),
			scale = 1.0,
			tag = 1,
		})
		
		--local bgSize = bg:getContentSize()
		--bg:setScaleX(size.width/bgSize.width)
		--bg:setScaleY(size.height/bgSize.height)
		
		Mnode.createLabel(
		{
			parent = cell,
			src = cur.name,
			size = 22,
			pos = cc.p(size.width/2, size.height/2),
			color = MColor.yellow,
		})
	end
	
    local resetRadioBoxToFirstFocus
	tableView:registerScriptHandler(function(tv, cell)
		AudioEnginer.playTouchPointEffect()
		
		local idx = cell:getIdx()
		--dump("idx="..idx, "---------")
		
		local value = stack:top()
		local leaf = value.leaf
		if leaf == idx then return end
        --[[
		local branch = getDataAtIdx(idx)
		if branch.list ~= nil then -- 枝
			stack:push({ branch = branch })
			title:setString(branch.name)
			--backBtn:setVisible(true)
			reloadData()
		else -- 叶
			
            local content = cell:getChildByTag(1)
			if content then content:setTexture("res/component/TabControl/10.png") end
			
			local last = leaf and tv:cellAtIndex(leaf)
			if last then
				content = last:getChildByTag(1)
				content:setTexture("res/component/TabControl/9.png")
			end
			cell:runAction(cc.Sequence:create(cc.ScaleTo:create(0.15,1.05),cc.ScaleTo:create(0.1,1.0)))
			value.leaf = idx      -- ????
            
		end
        ]]
        
        local content = cell:getChildByTag(1)
		if content then content:setTexture("res/component/TabControl/10.png") end
			
		local last = leaf and tv:cellAtIndex(leaf)
		if last then
			content = last:getChildByTag(1)
			content:setTexture("res/component/TabControl/9.png")
		end
		cell:runAction(cc.Sequence:create(cc.ScaleTo:create(0.15,1.05),cc.ScaleTo:create(0.1,1.0)))
		value.leaf = idx
        
		------------------------------------------
		search_mode = false
		switchTab()
		------------------------------------------
		inputEditbox:setText("")

        -- reset all radio btns
        resetRadioBoxToFirstFocus()
		
	end, cc.TABLECELL_TOUCHED)
	
	
	-- 返回上一级菜单按钮
    --[[
	backBtn = MMenuButton.new(
	{
		parent = left_bg,
		src = {"res/component/TabControl/9.png", "res/component/TabControl/10.png"},
		--scale = 0.7,
		
		label = {
			src = "返回",
			size = 25,
			color = MColor.lable_yellow,
		},
		
		cb = function(tag, node)
			if stack:size() > 1 then
				stack:pop()
				local branch = stack:top().branch
				title:setString(branch.name)
				inputEditbox:setText("")
				if stack:size() == 1 then backBtn:setVisible(false) end
				reloadData()
				
				------------------------------------------
				search_mode = false
				switchTab()
				------------------------------------------
			end
		end,
		--effect = "b2s",
		anchor = cc.p(0.5, 0),
		pos = cc.p(left_bg_size.width/2, 10),
		hide = true,
	})
	]]
	reloadData()
	Mnode.addChild(
	{
		parent = left_bg,
		child = tableView,
		anchor = cc.p(0.5, 0),
		pos = cc.p(left_bg_size.width/2, 140),
	})
	---------------------------------------------------------------
	-- 构建right view
	-- 搜索输入框
	local textureSize = cc.size(642,48)
	inputEditbox = Mnode.createEditBox(
	{
		hint = game.getStrByKey("hint"),
		cSize = cc.size(textureSize.width-10, textureSize.height-14),
	})

	inputEditbox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
	inputEditbox:registerScriptEditBoxHandler(function(strEventName, pSender)
		local edit = tolua.cast(pSender,"ccui.EditBox")

		--dump(strEventName, "editbox event")
		
		if strEventName == "began" then --编辑框开始编辑时调用
			
		elseif strEventName == "ended" then --编辑框完成时调用

		elseif strEventName == "return" then --编辑框return时调用
			local cur = edit:getText()
			--dump(cur, "cur")
			if cur == "" then
				--TIPS({ type = 1, str = game.getStrByKey("invalid_input_tips") })
			else
				
			end
		
		elseif strEventName == "changed" then --编辑框内容改变时调用
			
		end
	end)

	local inputBg = createScale9Sprite(baseNode, "res/common/scalable/input_1.png", cc.p(5, 475), cc.size(615,48), cc.p(0, 0.5))

	Mnode.addChild(
	{
		parent = inputBg,
		child = inputEditbox,
		pos = cc.p(textureSize.width/2+30, textureSize.height/2),
	})

    createSprite(inputBg,"res/teamup/s1.png",cc.p(5, textureSize.height/2),cc.p(0.0,0.5))
	
	Mnode.addChild(
	{
		parent = right_bg,
		child = inputBg,
		anchor = cc.p(0, 0.5),
		pos = cc.p(20, 475),
	})
	
	-- 搜索函数
	local search_key = function(key)
		local result = {}
		local tPropIdAsKey = getConfigItemByKey("propCfg", "q_id")
		for k, v in pairs(tPropIdAsKey) do
			local name = v.q_name
			if type(name) == "string" then
				local sp, ep = string.find(name, key, 1, true)
				if sp ~= nil and ep >= sp then
					--result[#result+1] = { id = v.q_id, name = name, sub = sub }
					result[#result+1] = v.q_id
				end
			end
		end
		dump({key=key, list=result}, "result")
		return result
	end
	
	-- 搜索按钮
	MMenuButton.new(
	{
		src = {"res/component/button/49.png", "res/component/button/49_sel.png"},
		parent = right_bg,
		anchor = cc.p(1, 0.5),
		pos = cc.p(right_bg_size.width-20, 475),
		label = {
			src = game.getStrByKey("search"),
			size = 25,
			color = MColor.lable_yellow,
		},
		
		cb = function(tag, node)
			local key = inputEditbox:getText()
			if key == "" then
				TIPS({ type = 1  , str = "输入内容有误，请重新输入" })
				return
			end
			
			local l = search_key(key)
			if #l == 0 then
				TIPS({ type = 1  , str = "没有相关的物品" })
				return
			end
			
			search_mode = true
			search_mode_key = key
			search_list = l
			switchTab()
		end,
	})
	
	-- 标题
    --[[
	local title = Mnode.createSprite(
	{
		src = "res/common/table/top6.png",
		parent = right_bg,
		anchor = cc.p(0.5, 1),
		pos = cc.p(right_bg_size.width/2, right_bg_size.height-55),
	})
	
	local title_size = title:getContentSize()
	
	local title_cfg = {
		{
			x = 180,
			text = game.getStrByKey("goods")..game.getStrByKey("name"),
		},
		
		{
			x = 327,
			text = game.getStrByKey("level"),
		},
		
		{
			x = 490,
			text = game.getStrByKey("remain")..game.getStrByKey("time"),
		},
		
		{
			x = 654,
			text = game.getStrByKey("price"),
		},
	}
	
	for i = 1, #title_cfg do
		local cur = title_cfg[i]
		Mnode.createLabel(
		{
			src = cur.text,
			parent = title,
			pos = cc.p(cur.x, title_size.height/2),
			size = 21,
			color = MColor.lable_yellow,
		})
	end
	]]
	-- 搜索顺序
    createLabel(right_bg,game.getStrByKey("price"),cc.p(720,30),cc.p(0,0.5),24,nil,nil,nil,MColor.lable_yellow)
	local orderBtn = Mnode.createSprite(
	{
		src = "res/group/arrows/14-1.png",
		parent = right_bg,
		pos = cc.p(700, 30)
	})
	
	-- 默认从小到大排列
	Mnode.listenTouchEvent(
	{
		node = orderBtn,
		swallow = true,
		begin = function(touch, event)
				local node = event:getCurrentTarget()
				
				if node.catch then return false end
				
				local inside = Mnode.isTouchInNodeAABB(node, touch)
				if inside then 
					node.catch = true
				end
				
				return inside
			end,
			
			ended = function(touch, event)
				local node = event:getCurrentTarget()
				node.catch = false
				
				if Mnode.isTouchInNodeAABB(node, touch) then
					AudioEnginer.playTouchPointEffect()
					isAscendingOrder = not isAscendingOrder
					node:setTexture("res/group/arrows/" .. (isAscendingOrder and "14-1" or "14") .. ".png")
					if subIndex and subIndex ~= -1 then
					    switchTabNew(subIndex)
                    else
                        switchTab(true)
					end
                    
				end
			end,
	})
	-- 数据
	---------------------------------------------------------------
	local list = {}
	local map_list = {}
	local list_count = 0
	local total_count = 0
	local focused = nil
	local next_start_idx = 0
	local all_loaded = false
	
	local item = getCurItem()
    if item then
        MConsignOp:query(item.code, next_start_idx, true)
    end
	
	---------------------------------------------------------------
	-- TableView
	local iSize = cc.size(790, 100+2)
	local vSize = cc.size(790, 360)
	local tableView = cc.TableView:create(vSize)
	tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
	tableView:setDelegate()

	local reloadListView = function(numOfAdded)
		local now_pos = tableView:getContentOffset()
		--dump(now_pos, "now_pos")
		tableView:reloadData()
		if numOfAdded then
            local newNumOfAdded = math.ceil(numOfAdded/2)
			local new_pos = cc.p(now_pos.x, now_pos.y-newNumOfAdded*iSize.height)
			tableView:setContentOffset( new_pos )
		end
		
		n_empty_list_tips:setVisible(#list == 0)
	end
	
	reloadListData = function()
		list = {}
		map_list = {}
		list_count = 0
		focused = nil
		next_start_idx = 0
		all_loaded = false
	end
	
	tableView:registerScriptHandler(function(tv)
		--return #list
        return math.ceil(#list/2)
	end, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
	
	tableView:registerScriptHandler(function(tv, idx)
		return iSize.height, iSize.width
	end, cc.TABLECELL_SIZE_FOR_INDEX)
	
	local buildCellContent = nil
	tableView:registerScriptHandler(function(tv, idx)
		local cell = tv:dequeueCell()
		if not cell then
			cell = cc.TableViewCell:new()
			cell:setContentSize(iSize)
			buildCellContent(tv, idx, cell)
		else
			buildCellContent(tv, idx, cell)
		end
		return cell
	end, cc.TABLECELL_SIZE_AT_INDEX)
	
	tableView:registerScriptHandler(function(tv, cell)
		cell:removeAllChildren()
	end, cc.TABLECELL_WILL_RECYCLE)
	
	tableView:registerScriptHandler(function(tv, cell)
		
		--dump("TABLECELL_HIGH_LIGHT")
	end, cc.TABLECELL_HIGH_LIGHT)
	
	tableView:registerScriptHandler(function(tv, cell)
		
		--dump("TABLECELL_UNHIGH_LIGHT")
	end, cc.TABLECELL_UNHIGH_LIGHT)
	
    local function onTableCellItemTouched(idx)
        local cur = list[idx]
		if not cur.invalid then
			local MConfirmBox = require "src/functional/ConfirmBox"
			local box = MConfirmBox.new(
			{
				handler = function(box)
                    print("qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq")
					MConsignOp:buy(cur.id)
					if box then removeFromParent(box) box = nil end
				end,
						
				builder = function(box)
					local MpropOp = require "src/config/propOp"
					local grid = cur.grid
					local protoId = MPackStruct.protoIdFromGird(grid)
					local name = MpropOp.name(protoId)
					local price = MPackStruct.attrFromGird(grid, MPackStruct.eAttrStallPrice) or "-1"
					local num = MPackStruct.overlayFromGird(grid)
					
					local box_size = box:getContentSize()
					local revenue = math.min(math.ceil(price * 0.03), 200)
					local format_str = "确认花费%s元宝(含税%d元宝)\n购买%d个%s吗?"
					local str = string.format(format_str, price+revenue, revenue, num, name)
					Mnode.createLabel(
					{
						parent = box,
						src = str,
						color = MColor.lable_yellow,
						size = 20,
						pos = cc.p(box_size.width/2, 175),
					})
				end,
			})
		else
			TIPS({ type = 1  , str = game.getStrByKey("already")..game.getStrByKey("buy") })
		end
    end

    local function genCellItem(tv,cell,index,isLeft)
                        local size = cell:getContentSize()
		                --[[
                        local bg = Mnode.createSprite(
		                {
			                src = "res/common/table/" .. (idx == focused and "cell13_sel.png" or "cell13.png"),
			                parent = cell,
			                pos = cc.p(size.width/2, size.height/2),
			                tag = 1,
		                })
                        ]]
                        local tmpDis = -191
                        if isLeft == 1 then
                            tmpDis = 191
                        end
                        local bg = cc.Scale9Sprite:create("res/common/scalable/" .. (idx == focused and "item.png" or "item.png"))
                        bg:setContentSize(cc.size(378,99))
                        --bg:setCapInsets(cc.rect(100,20,160,80))
                        bg:setPosition(cc.p(size.width/2+tmpDis, size.height/2))
                        bg:setTag(1)
                        cell:addChild(bg)
		                
                        ---------------------------------------------------------------------------------------
                        -- touch event
                        Mnode.listenTouchEvent(
	                    {
		                    swallow = false,
		                    node = bg,
		                    begin = function(touch, event)
			                    local node = event:getCurrentTarget()
			                    if node.catch then return false end
		
			                    local inside = Mnode.isTouchInNodeAABB(node, touch)
			                    if inside then
				                    local point = tv:convertTouchToNodeSpace(touch)
				                    if not Mnode.isPointInNodeAABB(tv, point, tv:getViewSize()) then return false end
			
				                    node.catch = true
				                    return true
			                    end
			
			                    return false
		                    end,
		
		                    ended = function(touch, event)
			                    local node = event:getCurrentTarget()
			                    node.catch = false
			
			                    if Mnode.isTouchInNodeAABB(node, touch) then
				                    local startPos = touch:getStartLocation()
				                    local currPos  = touch:getLocation()
				                    if cc.pGetDistance(startPos,currPos) < 30 then
					                    AudioEnginer.playTouchPointEffect()
					                    onTableCellItemTouched(index)
				                    end
			                    end
		                    end,
	                    })
                        ---------------------------------------------------------------------------------------

		                local bgSize = bg:getContentSize()
		
		                local Mprop = require "src/layers/bag/prop"
		                local MpropOp = require "src/config/propOp"
		
		                local cur = list[index]     -- index + 1
		
		                local grid = cur.grid
		                local protoId = MPackStruct.protoIdFromGird(grid)
		
		
		                -- 物品图标
		                local icon = Mprop.new(
		                {
			                grid = grid,
			                num = MPackStruct.overlayFromGird(grid),
			                cb = "tips",
		                })
		
		                Mnode.addChild(
		                {
			                parent = bg,
			                child = icon,
			                pos = cc.p(50, bgSize.height/2),
		                })
		
		                -- 物品名称
		                Mnode.createLabel(
		                {
			                src = MpropOp.name(protoId),
			                parent = bg,
			                pos = cc.p(95, bgSize.height/2+20),
			                size = 21,
			                color = MColor.lable_yellow,
                            anchor = cc.p(0,0.5)
		                })
		
		                -- 等级
		                Mnode.createLabel(
		                {
			                src = MpropOp.levelLimits(protoId) .. game.getStrByKey("ji"),
			                parent = bg,
			                pos = cc.p(370, bgSize.height/2+20),
			                size = 21,
			                --color = MColor.lable_black,
                            anchor = cc.p(1,0.5)
		                })
		
                        -- text
                        Mnode.createLabel(
		                {
			                src = game.getStrByKey("remain_"),
			                parent = bg,
			                pos = cc.p(250, bgSize.height/2-20),
			                size = 21,
			                color = MColor.lable_yellow,
		                })

		                -- 剩余时间
		                local expiration = MPackStruct.attrFromGird(grid, MPackStruct.eAttrStallTime) or 0
		                local now = GetTime()
		                local hours = math.floor((expiration-now)/3600)
		                local remain = (expiration-now)%3600
		                local minute = math.floor(remain/60)
		                --local second = remain%60
		
		                local format = ""
		                if hours > 0 then format = format .. hours.. game.getStrByKey("hours_") end
		                if hours == 0 and minute < 1 then minute = 1 end
		                if minute > 0 then format = format .. minute .. game.getStrByKey("minute_") end
	
		                Mnode.createLabel(
		                {
			                src = format,
			                parent = bg,
			                pos = cc.p(370, bgSize.height/2-20),       -- 295
			                size = 21,
			                --color = MColor.lable_black,
                            anchor = cc.p(1,0.5)
		                })
		
		                -- 价格
		                local price = Mnode.createSpriteAndLabel(
		                {
			                k = Mnode.createSprite(
			                {
				                src =  "res/group/currency/"..(protoId==222222 and "1" or "3")..".png",
				                scale = 0.7,
			                }),
			
			                v = {
				                src = MPackStruct.attrFromGird(grid, MPackStruct.eAttrStallPrice) or "-1",
				                size = 21,
				                color = MColor.yellow,
			                },
			
			                margin = 5,
		                })
		
		                Mnode.addChild(
		                {
			                parent = bg,
			                child = price,
			                pos = cc.p(115, bgSize.height/2-20),
		                })
		
		                -- 预先加载后续数据
		                if index == #list-1 then
			                if not all_loaded and next_start_idx > 0 then
				                if not search_mode then
					                local item = getCurItem()
					                MConsignOp:query(item.code, next_start_idx, isAscendingOrder)
				                else
					                MConsignOp:search(search_mode_key, next_start_idx, isAscendingOrder, search_list)
				                end
			                end
		                end
		
		                if cur.invalid then
			                Mnode.createSprite(
			                {
				                src = "res/component/flag/14.png",
				                parent = bg,
				                pos = cc.p(320, bgSize.height/2),
			                })
		                end
    end

	buildCellContent = function(tv, idx, cell)
        --[[
	    1 -- 1, 2 -> 1*2
	    2 -- 3, 4 -> 2*2
	    3 -- 5, 6 -> 3*2
	    --]]
        --------------------------------------------
        local group = idx+1
	    local new_idx = group*2
	    local item_left = list[new_idx-1]
	    local item_right = list[new_idx]
	    --[[
	    local cSize = cell:getContentSize()
	
	    local bg_left = Mnode.createSprite(
	    {
		    parent = cell,
		    src = item_bg,
		    anchor = cc.p(0, 0.5),
		    pos = cc.p(9, cSize.height/2),
	    })
	
	    buildGoodsItem(tv, new_idx-1, cell, bg_left)
	
	    if item_right == nil then return end
	
	    local bg_right = Mnode.createSprite(
	    {
		    parent = cell,
		    src = item_bg,
		    anchor = cc.p(1, 0.5),
		    pos = cc.p(cSize.width-9, cSize.height/2),
	    })
	
	    buildGoodsItem(tv, new_idx, cell, bg_right)
        ]]
        --------------------------------------------
        if item_left then
            genCellItem(tv,cell,new_idx-1,0)
        end
        if item_right then
            genCellItem(tv,cell,new_idx,1)
        end
		
	end
	
	tableView:registerScriptHandler(function(tv, cell)
		local idx = cell:getIdx()
		dump("idx="..idx, "---------")
		
		if idx ~= focused then
			local content = cell:getChildByTag(1)
			--if content then content:setTexture("res/common/table/cell11_sel.png") end
			
			if focused then
				local last = tv:cellAtIndex(focused)
				if last then
					content = last:getChildByTag(1)
					--content:setTexture("res/common/table/cell11.png")
				end
			end
			
			focused = idx
		end
	end, cc.TABLECELL_TOUCHED)
	
	
	--reloadListView()
	
    --------------------------------------------------
    -- add scale9 bg
    createScale9Sprite(
	    right_bg,
	    "res/common/scalable/panel_inside_scale9.png",
	    cc.p(right_bg_size.width/2, right_bg_size.height-450),
	    cc.size(775, 375),
	    cc.p(0.5, 0)
	)
    --------------------------------------------------

	Mnode.addChild(
	{
		parent = right_bg,
		child = tableView,
		anchor = cc.p(0.5, 1),
		pos = cc.p(right_bg_size.width/2, right_bg_size.height-80),
	})
	
	-- 分隔线
    --[[
	Mnode.createSprite(
	{
		src = "res/common/bg/bg12-1.png",
		parent = right_bg,
		anchor = cc.p(0.5, 1),
		pos = cc.p(right_bg_size.width/2, tableView:getPositionY()-vSize.height-5),
	})
	]]
	--[[
	-- 物品数量
	local countitem = Mnode.createKVP(
	{
		k = Mnode.createLabel(
		{
			src = game.getStrByKey("goods")..game.getStrByKey("quantity").."：",
			size = 20,
			color = MColor.lable_yellow,
		}),
		
		v = {
			src = tostring(list_count) .. "/" .. tostring(total_count),
			size = 20,
			color = MColor.lable_yellow,
		},
	})
	
	Mnode.addChild(
	{
		parent = right_bg,
		child = countitem,
		anchor = cc.p(0, 0.5),
		pos = cc.p(28, 46),
	})
	]]
	
	-- 提示信息
    --[[
	Mnode.createLabel(
	{
		parent = right_bg,
		src = "寄售的商品，会在下个整点上架",
		size = 20,
		color = MColor.lable_yellow,
		anchor = cc.p(0, 0.5),
		pos = cc.p(250, 30),
	})
	]]
	-- 帮助按钮
	local pk_prompt = __createHelp(
	{
		parent = right_bg,
		str = require("src/config/PromptOp"):content(61),
		pos = cc.p(35, 30),
	})

    -- shaixuan
    local sx = createLabel(right_bg,game.getStrByKey("shaixuan"),cc.p(70,30),cc.p(0,0.5),24,nil,nil,nil,MColor.lable_yellow)
    -----------------------------------------------------------------------------------------------------------
    -- radio zhuangbei
    local RadioBoxZB = Mnode.createRadioBox(
	{
		config = 
		{
			titles = 
			{
				{
					title = game.getStrByKey("zhanshi"),
					id = 1,
					cost = "1",
				},
				
				{
					title = game.getStrByKey("fashi"),
					id = 2,
					cost = "2",
				},
				
				{
					title = game.getStrByKey("daoshi"),
					id = 3,
					cost = "5",
				},
			},
			ori = "-",
			margin = 8,
			size = 22,
			color = MColor.lable_yellow,
		},
		
		margins = 25,
		
		cb = function(node, ud, choice)
            if choice == 1 then
                switchTabNew(110)
            elseif choice == 2 then
                switchTabNew(120)
            elseif choice == 3 then
                switchTabNew(130)
            end
            
		end,
		
		choice = 1,
	},true)

	Mnode.addChild(
	{
		parent = right_bg,
		child = RadioBoxZB,
		pos = cc.p(305, 28),
	})
    -----------------------------------------------------------------------------------------------------------
    -----------------------------------------------------------------------------------------------------------
    -- radio medicine
    local RadioBoxYP = Mnode.createRadioBox(
	{
		config = 
		{
			titles = 
			{
				{
					title = game.getStrByKey("yaoshui"),
					id = 1,
					cost = "1",
				},
				
				{
					title = game.getStrByKey("blessing"),
					id = 2,
					cost = "2",
				},
			},
			ori = "-",
			margin = 8,
			size = 22,
			color = MColor.lable_yellow,
		},
		
		margins = 25,
		
		cb = function(node, ud, choice)
            if choice == 1 then
                switchTabNew(37)
            elseif choice == 2 then
                switchTabNew(38)
            end
            
		end,
		
		choice = 1,
	},true)

	Mnode.addChild(
	{
		parent = right_bg,
		child = RadioBoxYP,
		pos = cc.p(249, 28),
	})
    -----------------------------------------------------------------------------------------------------------
    -----------------------------------------------------------------------------------------------------------
    -- radio cailiao
    local RadioBoxCL = Mnode.createRadioBox(
	{
		config = 
		{
			titles = 
			{
				{
					title = game.getStrByKey("kuangshi_text"),
					id = 1,
					cost = "1",
				},
				
				{
					title = game.getStrByKey("equipment_text"),
					id = 2,
					cost = "2",
				},
				
				{
					title = game.getStrByKey("shengwang_text"),
					id = 3,
					cost = "5",
				},

                {
					title = game.getStrByKey("shuji_text"),
					id = 4,
					cost = "5",
				},
			},
			ori = "-",
			margin = 8,
			size = 22,
			color = MColor.lable_yellow,
		},
		
		margins = 25,
		
		cb = function(node, ud, choice)
            if choice == 1 then
                switchTabNew(45)
            elseif choice == 2 then
                switchTabNew(46)
            elseif choice == 3 then
                switchTabNew(47)
            elseif choice == 4 then
                switchTabNew(48)
            end
		end,
		
		choice = 1,
	},true)

	Mnode.addChild(
	{
		parent = right_bg,
		child = RadioBoxCL,
		pos = cc.p(361, 28),
	})
    -----------------------------------------------------------------------------------------------------------
    -----------------------------------------------------------------------------------------------------------
    setRidoBoxVisible = function (idx)
        RadioBoxZB:setVisible(false)
        RadioBoxYP:setVisible(false)
        RadioBoxCL:setVisible(false)
        sx:setVisible(false)
        if idx == 1 then
            RadioBoxZB:setVisible(true)
            sx:setVisible(true)
        elseif idx == 2 then
            RadioBoxYP:setVisible(true)
            sx:setVisible(true)
        elseif idx == 3 then
            RadioBoxCL:setVisible(true)    
            sx:setVisible(true)
        end
    end
    setRidoBoxVisible(0)

    resetRadioBoxToFirstFocus = function ()
        RadioBoxZB.setChoice(1)
        RadioBoxYP.setChoice(1)
        RadioBoxCL.setChoice(1)
    end
    -----------------------------------------------------------------------------------------------------------
	--pk_prompt:setScale(0.8)
	
	-- 购买按钮
    --[[
	MMenuButton.new(
	{
		src = {"res/component/button/50.png", "res/component/button/50_sel.png"},
		label = {
			src = game.getStrByKey("buy"),
			size = 25,
			color = MColor.lable_yellow,
		},
		
		cb = function(tag, node)
			if focused then
				local cur = list[focused+1]
				if not cur.invalid then
					local MConfirmBox = require "src/functional/ConfirmBox"
					local box = MConfirmBox.new(
					{
						handler = function(box)
							MConsignOp:buy(cur.id)
							if box then removeFromParent(box) box = nil end
						end,
						
						builder = function(box)
							local MpropOp = require "src/config/propOp"
							local grid = cur.grid
							local protoId = MPackStruct.protoIdFromGird(grid)
							local name = MpropOp.name(protoId)
							local price = MPackStruct.attrFromGird(grid, MPackStruct.eAttrStallPrice) or "-1"
							local num = MPackStruct.overlayFromGird(grid)
					
							local box_size = box:getContentSize()
							local revenue = math.min(math.ceil(price * 0.03), 200)
							local format_str = "确认花费%s元宝(含税%d元宝)\n购买%d个%s吗?"
							local str = string.format(format_str, price+revenue, revenue, num, name)
							Mnode.createLabel(
							{
								parent = box,
								src = str,
								color = MColor.lable_yellow,
								size = 20,
								pos = cc.p(box_size.width/2, 175),
							})
						end,
					})
				else
					TIPS({ type = 1  , str = game.getStrByKey("already")..game.getStrByKey("buy") })
				end
			else
				TIPS({ type = 1  , str = game.getStrByKey("buy_select_tips") })
			end
		end,
		
		parent = right_bg,
		anchor = cc.p(1, 0.5),
		pos = cc.p(right_bg_size.width, 30),
	})
    ]]
	
	---------------------------------------------------------------
	local dataSourceChanged = function(observable, event, data)
		if event == "PullSaleList" then
			total_count = data.total_count
			
			local save = tab_switched
			if tab_switched then
				tab_switched = false
				reloadListData()
			end
			------------------------------
			local added = data.cur_list
			if #added > 0 then
				all_loaded = false
				
				for i, v in ipairs(added) do
					local idx = #list+1
					list[idx] = v
					map_list[v.id] = idx
					list_count = list_count + 1
				end
			
				next_start_idx = data.next_start_idx
				--countitem:setValue(tostring(list_count) .. "/" .. tostring(total_count))
			else
				all_loaded = true
			end
			------------------------------
			if #added > 0 or save then reloadListView(not save and #added or nil) end
		elseif event == "iBuyIt" then
			local idx = map_list[data.key]
			if idx == nil then return end
			list[idx].invalid = true
			list_count = list_count - 1
			
			--countitem:setValue(tostring(list_count) .. "/" .. tostring(total_count))
			if focused == idx-1 then
				focused = nil
			end
            
			tableView:updateCellAtIndex((idx-1)/2)
		end
	end
	
	root:registerScriptHandler(function(event)
		if event == "enter" then
			MConsignOp:register(dataSourceChanged)
		elseif event == "exit" then
			MConsignOp:unregister(dataSourceChanged)
		end
	end)
	---------------------------------------------------------------
	return root
end


