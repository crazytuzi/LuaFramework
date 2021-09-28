local Myoung = require "src/young/young"; local M = Myoung.beginModule(...)

new = function(params)
	local MConsignOp = require "src/layers/consign/ConsignOp"
	--MConsignOp:openConsign()
	
	local res = "res/layers/consign/"
	local Mbaseboard = require "src/functional/baseboard"
	local MMenuButton = require "src/component/button/MenuButton"
	---------------------------------------------------------------
	local root = Mnode.createNode({ cSize = cc.size(960, 640) })
	local rootSize = root:getContentSize()
	
	local bg_size = cc.size(910,518)
	local bg = createScale9Frame(
        root,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(25, 28),
        bg_size,
        5
    )
	-- cc.Sprite:create("res/common/bg/bg.png")
	-- local bg_size = bg:getContentSize()
	-- Mnode.addChild(
	-- {
	-- 	parent = root,
	-- 	child = bg,
	-- 	anchor = cc.p(0.5, 0),
	-- 	pos = cc.p(rootSize.width/2, 24),
	-- })
	
	-- 标题
	local title = CreateListTitle(bg, cc.p(bg_size.width/2, bg_size.height), 910, 46, cc.p(0.5, 1))
	
	local title_size = title:getContentSize()
	
	local title_cfg = {
		{
			x = 220,
			text = game.getStrByKey("goods")..game.getStrByKey("name"),
		},
		
		{
			x = 367,
			text = game.getStrByKey("level"),
		},
		
		{
			x = 530,
			text = game.getStrByKey("remain")..game.getStrByKey("time"),
		},
		
		{
			x = 694,
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
	
	-- 空列表提示
	local n_empty_list_tips = Mnode.createLabel(
	{
		src = "当前没有正在寄售的物品",
		parent = bg,
		pos = cc.p(bg_size.width/2, bg_size.height/2),
		size = 21,
		color = MColor.white,
		hide = true,
	})
	-- 数据
	---------------------------------------------------------------
	local list = nil
	local map_list = nil
	local list_count = 0
	local focused = nil
	
	local reloadSource = function()
		focused = nil
		local result = {}
		map_list = {}
		list_count = 0
		local source = MConsignOp:getSellSource()
		for k, v in pairs(source) do
			local idx = #result+1
			result[idx] = { id = k, grid = v, uid = idx }
			map_list[k] = idx
		end
		local eSource = MConsignOp:getEarningsSource()
		list_count = #result + table.size(eSource)
		list = result





		local function funcSortByTime(a, b)
			local oGridA = a.grid
			local oGridB = b.grid
			local waitTimeA = MPackStruct.attrFromGird(oGridA, MPackStruct.eAttrStallWaitTime)
			local waitTimeB = MPackStruct.attrFromGird(oGridB, MPackStruct.eAttrStallWaitTime)
			local now = GetTime()

			local nPriA = 1
			local nPriB = 1

			if waitTimeA == waitTimeB then
				return a.uid < b.uid
			end
			if waitTimeA == nil or waitTimeA < now then
				nPriA = 2
			end
			if waitTimeB == nil or waitTimeB < now then
				nPriB = 2
			end
			if nPriA == nPriB then
				return a.uid < b.uid
			end
			return nPriA < nPriB
		end

		table.sort(list, funcSortByTime)

	end
	
	---------------------------------------------------------------
	-- TableView
	local iSize = cc.size(912, 100+2)
	local vSize = cc.size(912, 385)
	local tableView = cc.TableView:create(vSize)
	tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
	tableView:setDelegate()
	
	local reloadData = function()
		reloadSource()
		tableView:reloadData()
		n_empty_list_tips:setVisible(#list == 0)
	end
	
	tableView:registerScriptHandler(function(tv)
		return #list
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
	
	buildCellContent = function(tv, idx, cell)
		local size = cell:getContentSize()
		local bg = Mnode.createSprite(
		{
			src = "res/common/table/" .. (idx == focused and "cell5.png" or "cell5.png"),
			parent = cell,
			pos = cc.p(size.width/2, size.height/2),
			tag = 1,
		})
		
		local bgSize = bg:getContentSize()
		
		local Mprop = require "src/layers/bag/prop"
		local MpropOp = require "src/config/propOp"
		
		local cur = list[idx+1]
		
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
			pos = cc.p(60, bgSize.height/2),
		})
		
		-- 物品名称
		Mnode.createLabel(
		{
			src = MpropOp.name(protoId),
			parent = bg,
			pos = cc.p(title_cfg[1].x, bgSize.height/2),
			size = 21,
			color = MColor.lable_black,
		})
		
		-- 等级
		Mnode.createLabel(
		{
			src = MpropOp.levelLimits(protoId),
			parent = bg,
			pos = cc.p(title_cfg[2].x, bgSize.height/2),
			size = 21,
			color = MColor.lable_black,
		})
		
		-- 剩余时间
		local expiration = MPackStruct.attrFromGird(grid, MPackStruct.eAttrStallTime) or 0
		local waitTime = MPackStruct.attrFromGird(grid, MPackStruct.eAttrStallWaitTime)
		local now = GetTime()
		
		--dump(waitTime, "waitTime")
		local format = ""
		
		if waitTime == nil or waitTime < now then
			local hours = math.floor((expiration-now)/3600)
			local remain = (expiration-now)%3600
			local minute = math.floor(remain/60)
			--local second = remain%60
			
			
			if hours > 0 then format = format .. hours.. game.getStrByKey("hours") end
			if hours == 0 and minute < 1 then minute = 1 end
			if minute > 0 then format = format .. minute .. game.getStrByKey("minute") end
		else
			format = "等待上架中"
		end
	
		Mnode.createLabel(
		{
			src = format,
			parent = bg,
			pos = cc.p(title_cfg[3].x, bgSize.height/2),
			size = 21,
			color = MColor.lable_black,
		})
		
		-- 价格
		local price = Mnode.createKVP(
		{
			k = Mnode.createSprite(
			{
				src =  "res/group/currency/"..(protoId==222222 and "1" or "3")..".png",
				scale = 0.7,
			}),
			
			v = {
				src = MPackStruct.attrFromGird(grid, MPackStruct.eAttrStallPrice) or "-1",
				size = 21,
				color = MColor.lable_black,
			},
			
			margin = 5,
		})
		
		Mnode.addChild(
		{
			parent = bg,
			child = price,
			pos = cc.p(title_cfg[4].x, bgSize.height/2),
		})
		
		
		if cur.invalid then
			Mnode.createSprite(
			{
				src = "res/component/flag/8.png",
				parent = bg,
				pos = cc.p(title_cfg[4].x+150, bgSize.height/2),
			})
        else
		    -- add xiajia btn
            MMenuButton.new(
	        {
		        src = {"res/component/button/50.png", "res/component/button/50_sel.png"},
		        label = {
			        src = game.getStrByKey("sold_out"),
			        size = 25,
			        color = MColor.lable_yellow,
		        },
		
		        cb = function(tag, node)
				    local cur = list[idx+1]
				    if not cur.invalid then
					    MConsignOp:soldOut(cur.id)
				    else
					    TIPS({ type = 1  , str = game.getStrByKey("already")..game.getStrByKey("sold_out") })
				    end
		        end,
		
		        parent = bg,
		        anchor = cc.p(1, 0.5),
		        --pos = cc.p(bg_size.width-8, 35),
                pos = cc.p(title_cfg[4].x+200, bgSize.height/2),
	        })
        end

	end
	
	tableView:registerScriptHandler(function(tv, cell)
		local idx = cell:getIdx()
		dump("idx="..idx, "---------")
		
		if idx ~= focused then
			local content = cell:getChildByTag(1)
			--if content then content:setTexture("res/common/table/cell5_sel.png") end
			
			if focused then
				local last = tv:cellAtIndex(focused)
				if last then
					content = last:getChildByTag(1)
					content:setTexture("res/common/table/cell5.png")
				end
			end
			
			focused = idx
		end
	end, cc.TABLECELL_TOUCHED)
	
	
	reloadData()
	
	Mnode.addChild(
	{
		parent = bg,
		child = tableView,
		anchor = cc.p(0.5, 1),
		pos = cc.p(bg_size.width/2, title:getPositionY()-title_size.height-5),
	})
	---------------------------------------------------------------
	-- 分隔线
	Mnode.createSprite(
	{
		src = "res/common/bg/bg-3.png",
		parent = bg,
		anchor = cc.p(0.5, 1),
		pos = cc.p(bg_size.width/2, tableView:getPositionY()-vSize.height-5),
	})
	
    -- 帮助按钮
    local pk_prompt = __createHelp(
	{
		parent = bg,
		str = require("src/config/PromptOp"):content(61),
		pos = cc.p(40, 35),
	})

	-- 物品数量
	local countitem = Mnode.createKVP(
	{
		k = Mnode.createLabel(
		{
			src = game.getStrByKey("goods")..game.getStrByKey("quantity").."：",
			size = 22,
			color = MColor.lable_yellow,
		}),
		
		v = {
			src = tostring(list_count) .. "/20",
			size = 22,
			color = MColor.lable_yellow,
		},
	})
	
	Mnode.addChild(
	{
		parent = bg,
		child = countitem,
		anchor = cc.p(0, 0.5),
		pos = cc.p(80, 35),
	})
	
	-- 提示信息
	Mnode.createLabel(
	{
		parent = bg,
		src = "物品数量为寄售中商品+待领取商品",
		size = 22,
		color = MColor.lable_yellow,
		anchor = cc.p(0, 0.5),
		pos = cc.p(550, 35),
	})
	
	-- 帮助按钮
	--[[
    local pk_prompt = __createHelp(
	{
		parent = bg,
		str = require("src/config/PromptOp"):content(61),
		pos = cc.p(720, 35),
	})

	pk_prompt:setScale(0.8)
	]]
	-- 下架按钮
    --[[
	MMenuButton.new(
	{
		src = {"res/component/button/50.png", "res/component/button/50_sel.png"},
		label = {
			src = game.getStrByKey("sold_out"),
			size = 25,
			color = MColor.lable_yellow,
		},
		
		cb = function(tag, node)
			if focused then
				local cur = list[focused+1]
				if not cur.invalid then
					MConsignOp:soldOut(cur.id)
				else
					TIPS({ type = 1  , str = game.getStrByKey("already")..game.getStrByKey("sold_out") })
				end
			else
				TIPS({ type = 1  , str = game.getStrByKey("sold_out_select_tips") })
			end
		end,
		
		parent = bg,
		anchor = cc.p(1, 0.5),
		pos = cc.p(bg_size.width-8, 35),
	})
    ]]
	---------------------------------------------------------------
	local dataSourceChanged = function(observable, event, data)
		if event == "IwillSellInit" then
			reloadData()
			countitem:setValue(tostring(list_count) .. "/20")
		elseif event == "soldOut" or event == "someoneBuyIt" then
			local idx = map_list[data.key]
			if idx == nil then return end
			list[idx].invalid = true
			
			if focused == idx-1 then
				focused = nil
			end
			tableView:updateCellAtIndex(idx-1)
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