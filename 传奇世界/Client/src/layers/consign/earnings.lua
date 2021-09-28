local Myoung = require "src/young/young"; local M = Myoung.beginModule(...)

new = function(params)
	local MConsignOp = require "src/layers/consign/ConsignOp"
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
			text = game.getStrByKey("selling_price"),
		},
		
		{
			x = 694,
			text = game.getStrByKey("state"),
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
		src = "当前没有等待领取的物品",
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
		local source = MConsignOp:getEarningsSource()
		for k, v in pairs(source) do
			local idx = #result+1
			result[idx] = { id = k, grid = v }
			map_list[k] = idx
		end
		
		local sSource = MConsignOp:getSellSource()
		list_count = #result + table.size(sSource)
		list = result
	end
	
	local already = game.getStrByKey("already")
	local state_cfg = {
		[1] = { text = "res/component/flag/8.png", }, -- 已退回
		[2] = { text = "res/component/flag/9.png", }, -- 已购买
		[3] = { text = "res/component/flag/11.png", }, -- 已卖出
		[4] = { text = "res/component/flag/8.png", }, -- 已下架
	}
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
		
		-- 价格
		local price = Mnode.createKVP(
		{
			k = Mnode.createSprite(
			{
				src =  "res/group/currency/3.png",
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
			pos = cc.p(title_cfg[3].x, bgSize.height/2),
		})
        if not cur.invalid then
            -- 领取按钮
	        MMenuButton.new(
	        {
		        src = {"res/component/button/50.png", "res/component/button/50_sel.png"},
		        label = {
			        src = game.getStrByKey("get_lq"),
			        size = 25,
			        color = MColor.lable_yellow,
		        },
		
		        cb = function(tag, node)
				    local cur = list[idx+1]
				    if cur == nil then return end
				
				    if not cur.invalid then
					    local grid = cur.grid
					    if MPackStruct.girdIdFromGird(grid)==3 then

						    local price=MPackStruct.attrFromGird(grid, MPackStruct.eAttrStallPrice) or "-1"
						    local truePrice=math.ceil(price/0.97)
						    if price>=200/0.03-200 then
							    truePrice=price+200
						    end
						    local revenue = math.min(math.ceil(truePrice * 0.03), 200)
						    local format_str = "该装备以%d元宝出售成功，扣除手续费%d元宝，剩余%d元宝，是否领取？"
						    local str = string.format(format_str,truePrice,revenue,price)

						    MessageBoxYesNo(nil,str,
						    function() 
							    MConsignOp:get(cur.id)
						    end,
						    function() 
						    end,
						    game.getStrByKey("sure"),game.getStrByKey("cancel") )	


					    else
						    MConsignOp:get(cur.id)
					    end		
				    else
					    TIPS({ type = 1  , str = game.getStrByKey("already")..game.getStrByKey("get_lq") })
				    end
		        end,
		
		        parent = bg,
		        anchor = cc.p(1, 0.5),
		        pos = cc.p(title_cfg[4].x+200, bgSize.height/2),
	        })
        end

		-- 状态
		local state = state_cfg[MPackStruct.girdIdFromGird(grid)]
		if state then
			Mnode.createSprite(
			{
				src = cur.invalid and "res/component/flag/18.png" or state.text,
				parent = bg,
				pos = cc.p(title_cfg[4].x, bgSize.height/2),
			})
		else
			dump("状态错误", "++++++++++++++++")
             -- lingqu btn
           
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
	
    --[[
	-- 帮助按钮
	local pk_prompt = __createHelp(
	{
		parent = bg,
		str = require("src/config/PromptOp"):content(61),
		pos = cc.p(720, 35),
	})

	pk_prompt:setScale(0.8)
	]]
    --[[
	-- 领取按钮
	MMenuButton.new(
	{
		src = {"res/component/button/50.png", "res/component/button/50_sel.png"},
		label = {
			src = game.getStrByKey("get_lq"),
			size = 25,
			color = MColor.lable_yellow,
		},
		
		cb = function(tag, node)
			if focused then
				local cur = list[focused+1]
				if cur == nil then return end
				
				if not cur.invalid then
					local grid = cur.grid
					if MPackStruct.girdIdFromGird(grid)==3 then
						-- local MConfirmBox = require "src/functional/ConfirmBox"
						-- local box = MConfirmBox.new(
						-- {
						-- 	handler = function(box)
						-- 		MConsignOp:get(cur.id)
						-- 		if box then removeFromParent(box) box = nil end
						-- 	end,
							
						-- 	builder = function(box)
						-- 		local box_size = box:getContentSize()
								
						-- 		local price=MPackStruct.attrFromGird(grid, MPackStruct.eAttrStallPrice) or "-1"
						-- 		local truePrice=math.ceil(price/0.97)
						-- 		if price>=200/0.03-200 then
						-- 			truePrice=price+200
						-- 		end
						-- 		local revenue = math.min(math.ceil(truePrice * 0.03), 200)
						-- 		local format_str = "该装备已%d元宝出售成功，扣除%d元\n宝的手续费，剩余%d元宝，是否领取？"
						-- 		local str = string.format(format_str,truePrice,revenue,price)
						-- 		Mnode.createLabel(
						-- 		{
						-- 			parent = box,
						-- 			src = str,
						-- 			color = MColor.lable_yellow,
						-- 			size = 19,
						-- 			pos = cc.p(box_size.width/2, 175),
						-- 		})
						-- 	end,
						-- })


						local price=MPackStruct.attrFromGird(grid, MPackStruct.eAttrStallPrice) or "-1"
						local truePrice=math.ceil(price/0.97)
						if price>=200/0.03-200 then
							truePrice=price+200
						end
						local revenue = math.min(math.ceil(truePrice * 0.03), 200)
						local format_str = "该装备以%d元宝出售成功，扣除手续费%d元宝，剩余%d元宝，是否领取？"
						local str = string.format(format_str,truePrice,revenue,price)

						MessageBoxYesNo(nil,str,
						function() 
							MConsignOp:get(cur.id)
						end,
						function() 
						end,
						game.getStrByKey("sure"),game.getStrByKey("cancel") )	


					else
						MConsignOp:get(cur.id)
					end		
				else
					TIPS({ type = 1  , str = game.getStrByKey("already")..game.getStrByKey("get_lq") })
				end
			else
				TIPS({ type = 1  , str = game.getStrByKey("my_earnings_select_tips") })
			end
		end,
		
		parent = bg,
		anchor = cc.p(1, 0.5),
		pos = cc.p(bg_size.width-8, 35),
	})
    ]]
	---------------------------------------------------------------
	local dataSourceChanged = function(observable, event, data)
		if event == "MyEarningsInit" then
			reloadData()
			countitem:setValue(tostring(list_count) .. "/20")
		elseif event == "getEarnings" then
			local idx = map_list[data.id]
			dump(idx, "idx")
			if idx == nil then return end
			list[idx].invalid = true
			--table.remove(list, idx)
			list_count = list_count - 1
			
			countitem:setValue(tostring(list_count) .. "/20")
			if focused == idx-1 then
				focused = nil
			end
			tableView:updateCellAtIndex(idx-1)
			--tableView:removeCellAtIndex(idx-1)
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