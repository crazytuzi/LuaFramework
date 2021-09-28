local Myoung = require "src/young/young"; local M = Myoung.beginModule(...)


local show_putaway_view = function(parent, grid, num, shared,params)

    --grid = nil
    --num = 0
    --shared = nil

	local MpropOp = require "src/config/propOp"
	
	local old = parent:getChildByTag(1)
	if old then removeFromParent(old) end
	--if grid == nil then return end
	
	local parent_size = parent:getContentSize()
	local cSize = cc.size(390,500)
	local bg = createScale9Frame(
        parent,
        "res/common/scalable/panel_outer_base.png",
        "res/common/scalable/panel_outer_frame_scale9.png",
        cc.p(0, 0),
        cSize,
        5
    )
    bg:setTag(1)

	local protoId = nil
    if grid then
	    protoId = MPackStruct.protoIdFromGird(grid)
	end
	
	local isCurrency = protoId == 222222 or protoId == 999998
	local isEquip = MPackStruct:getCategoryByPropId(protoId) == MPackStruct.eEquipment
	local strengthLv = MPackStruct.attrFromGird(grid, MPackStruct.eAttrStrengthLevel)
	
	-- 单价限制区间
	local price_lower, price_upper = MpropOp.consignPrice(protoId)
	dump({price_lower=price_lower, price_upper=price_upper}, "consignPrice")
	
	if isEquip and protoId then
		local MequipOp = require "src/config/equipOp"
		local lower, upper = MequipOp.upStrengthConsignPrice(protoId, strengthLv)
		dump({lower=lower, upper=upper}, "consignPrice")
		price_lower = price_lower + lower
		price_upper = price_upper + upper
	end
	
	-- 标题
    --[[
	local titleBg = Mnode.createSprite(
	{
		src = "res/common/bg/titleBg.png",
		parent = bg,
		pos = cc.p(cSize.width/2, 477),
	})
	
	local titleBgSize = titleBg:getContentSize()
	Mnode.createLabel(
	{
		parent = titleBg,
		src = game.getStrByKey("sell")..game.getStrByKey("info"),
		pos = cc.p(titleBgSize.width/2, titleBgSize.height/2),
		color = MColor.lable_yellow,
		size = 22,
	})
	]]
    -- 分隔线
	Mnode.createSprite(
	{
		src = "res/common/bg/bg27-2.png",
		parent = bg,
		pos = cc.p(cSize.width/2, 490),
	})
	-- 物品图标
	local icon = nil
    if protoId then
        local Mprop = require "src/layers/bag/prop"
	    icon = Mprop.new(
	    {
		    grid = grid,
		    num = num,
		    strengthLv = strengthLv,
		    cb = "tips",
	    })
    else
        icon = cc.Sprite:create("res/common/bg/itemBg.png")     
    end

	Mnode.addChild(
	{
		parent = bg,
		child = icon,
		pos = cc.p(58, 443),
	})
	
	-- 物品名字
    local nameStr = "--"
    local nameColor = MColor.name_blue
    if protoId then
        nameStr = MpropOp.name(protoId)
        nameColor = MpropOp.nameColor(protoId)
    end
	local name = Mnode.createLabel(
	{
		parent = bg,
		src = nameStr,
		size = 20,
		color = nameColor,
		anchor = cc.p(0, 0.5),
		pos = cc.p(110, 474),
	})
	
	-- 价格区间
    local priceNum = "--" .. game.getStrByKey("ingot")
    if protoId then
        priceNum = tostring(price_lower) .. "-" .. tostring(price_upper) .. game.getStrByKey("ingot")
    end
	local price_area = Mnode.createLabel(
	{
		parent = bg,
		src = "单价区间: " .. priceNum ,
		size = 18,
		color = MColor.lable_yellow,
		anchor = cc.p(0, 0.5),
		pos = cc.p(110, 444),
	})
	
	-- 寄售费用
	local cost = Mnode.createKVP(
	{
		k = Mnode.createLabel(
		{
			src = game.getStrByKey("consign")..game.getStrByKey("costing")..":  ",
			size = 18,
			color = MColor.lable_yellow,
		}),
		
		v = {
			src = "",
			size = 18,
			color = MColor.lable_yellow,
		},
	})
	
	Mnode.addChild(
	{
		parent = bg,
		child = cost,
		anchor = cc.p(0, 0.5),
		pos = cc.p(110, 414),
	})

	-- 分隔线
	Mnode.createSprite(
	{
		src = "res/common/bg/bg27-2.png",
		parent = bg,
		pos = cc.p(cSize.width/2, 393),
	})
	
	-- 出售总价
    local itemSinglePrice = 1
    local totalPrice = "--"
    if protoId then
        totalPrice = (tonumber(price_lower) or 0) * num
        itemSinglePrice = (tonumber(price_lower) or 0)
    end
	local total_price = Mnode.createKVP(
	{
		k = Mnode.createLabel(
		{
			src = isCurrency and "" or (game.getStrByKey("total_price") .. "："),
			color = MColor.lable_yellow,
			size = 22,
		}),
		
		v = {
			src = totalPrice,
			color = MColor.lable_yellow,
			size = 22,
		},
	}) or nil
	
	Mnode.addChild(
	{
		parent = bg,
		child = total_price,
		anchor = cc.p(0, 0.5),
		pos = cc.p(20, 370),
	})

    -- 元宝图标
	Mnode.createSprite(
	{
		src = "res/group/currency/3.png",
		parent = bg,
		pos = cc.p(326, 370),
		scale = 0.8,
		zOrder = 1,
	})
	
	-- 出售单价
    --[[
	local single_price = tonumber(price_lower) or ""
	Mnode.createLabel(
	{
		parent = bg,
		src = game.getStrByKey("sell")..game.getStrByKey(isCurrency and "total_price" or "single_price") .. "：",
		color = MColor.lable_yellow,
		size = 22,
		anchor = cc.p(0, 0.5),
		pos = cc.p(20, 330),
	})
	]]
    local single_price = tonumber(price_lower) or ""
	-- 输入框
    local s9 = cc.Scale9Sprite:create("res/common/scalable/input_1.png")
    s9:setContentSize(cc.size(340,47))
    s9:setAnchorPoint(cc.p(0,0))
    s9:setCapInsets(cc.rect(10,10,12,12))
    local inputBg = s9

	--local texture = TextureCache:addImage("res/common/bg/inputBg9.png")
    --local inputBg = cc.Sprite:createWithTexture(texture)
	local textureSize = s9:getContentSize()
	local inputEditbox = Mnode.createEditBox(
	{
		hint = game.getStrByKey("hint"),
		cSize = cc.size(textureSize.width-210, textureSize.height-14),
	})
        
    inputEditbox:setText(tostring(single_price))
	
    --inputEditbox:setFontColor(MColor.lable_yellow)
    inputEditbox:setFontSize(22)
	inputEditbox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
	inputEditbox:registerScriptEditBoxHandler(function(strEventName, pSender)
		local edit = tolua.cast(pSender,"ccui.EditBox")

		--dump(strEventName, "editbox event")
		
		if strEventName == "began" then --编辑框开始编辑时调用
			
		elseif strEventName == "ended" then --编辑框完成时调用

		elseif strEventName == "return" then --编辑框return时调用
			local cur = edit:getText()
			--dump(cur, "cur")
			local number = tonumber(cur)
			if number ~= nil and number > 0 then
				local save = number
				number = math.ceil(number)
				
				-- 上限值20亿
				if isCurrency then
					if number > 2000000000 then number = 2000000000 end
				else
					if number < price_lower then
						number = price_lower
						TIPS({ type = 1, str = "定价不能低于最低价" })
					end
					if number > price_upper then
						number = price_upper
						TIPS({ type = 1, str = "定价不能高于最高价" })
					end
				end
				
				if number ~= save then edit:setText(tostring(number)) end
				if number == single_price then return end
				
				single_price = number
				edit:setText(tostring(number))
				if not isCurrency then 
                    total_price:setValue(number*num) 
                    itemSinglePrice = number
                end
			else
				if cur == "" then
					single_price = ""
				else
					TIPS({ type = 1, str = game.getStrByKey("invalid_input_tips") })
					edit:setText(tostring(single_price))
				end
			end
		elseif strEventName == "changed" then --编辑框内容改变时调用
			
		end
	end)

	Mnode.addChild(
	{
		parent = inputBg,
		child = inputEditbox,
		pos = cc.p(textureSize.width/2, textureSize.height/2),
	})
	
	Mnode.createSprite(
	{
		src = "res/group/currency/3.png",
		parent = bg,
		pos = cc.p(326, 320),
		scale = 0.8,
		zOrder = 1,
	})
	
	Mnode.addChild(
	{
		parent = bg,
		child = inputBg,
		anchor = cc.p(0.5, 0.5),
		pos = cc.p(cSize.width/2-10, 320),
	})
	
    local single_price_title = game.getStrByKey("single_price") .. " :"
    createLabel(bg,single_price_title,cc.p(cc.p(20, 320)),cc.p(0.0,0.5),22,nil,nil,nil,MColor.lable_yellow)

	-- 分隔线
    --[[
	Mnode.createSprite(
	{
		src = "res/common/bg/bg27-2.png",
		parent = bg,
		pos = cc.p(cSize.width/2, 210),
	})
	]]
    ----------------------------------------------------------------------------------------------------
    local tmpConfig = params and params.config or { sp = 0, ep = 1, cur = 0 }
     -- 滑动部分
     local selector = Mnode.createSelector(
     {
 	    config = tmpConfig,
 	    onValueChanged = function(selector, value)
            if params then
                params.onValueChanged(value)
                num = value
                icon:setOverlay(num)
                total_price:setValue(itemSinglePrice*num)
            end
 	    end,
        unit = 1,
     })

     selector:setScale(1)
     selector:setPosition(cc.p(cSize.width/2-5, 230));
--     local inputEdit = selector:GetInputEditbox();
--     if inputEdit ~= nil then
--         inputEdit:setInputMode(cc.EDITBOX_INPUT_MODE_DECIMAL);
--     end
     bg:addChild(selector);
    ----------------------------------------------------------------------------------------------------


	-- 出售时间
    createSprite(bg,"res/common/sell_title.png",cc.p(cSize.width/2, 145))
	Mnode.createLabel(
	{
		parent = bg,
		src = game.getStrByKey("sell")..game.getStrByKey("time"),
		color = MColor.lable_yellow,
		size = 22,
		pos = cc.p(cSize.width/2, 145),
	})
	
	local RadioBox = Mnode.createRadioBox(
	{
		config = 
		{
			titles = 
			{
				{
					title = "16"..game.getStrByKey("hours"),
					id = 1,
					cost = "1",
				},
				
				{
					title = "24"..game.getStrByKey("hours"),
					id = 2,
					cost = "2",
				},
				
				{
					title = "48"..game.getStrByKey("hours"),
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
            if not params then
                cost:setValue("--" .. game.getStrByKey("gold_text"))
            else
                cost:setValue(ud[choice].cost .. game.getStrByKey("ten_thousand")..game.getStrByKey("gold_coin"))
            end
		end,
		
		choice = 1,
	})

	Mnode.addChild(
	{
		parent = bg,
		child = RadioBox,
		pos = cc.p(195, 105),
	})
	
	-- 分隔线
    --[[
	Mnode.createSprite(
	{
		src = "res/common/bg/bg27-2.png",
		parent = bg,
		pos = cc.p(cSize.width/2, 88),
	})
	]]
    local s9bg = cc.Scale9Sprite:create("res/common/bg/bg1-2.png")
    s9bg:setContentSize(cc.size(385,68))
    s9bg:setAnchorPoint(cc.p(0.5,0.5))
    s9bg:setCapInsets(cc.rect(100,10,171,48))
    s9bg:setPosition(cc.p(cSize.width/2, 36))
    bg:addChild(s9bg)

	-- 上架按钮
    if not params then
        createLabel(bg,game.getStrByKey("jishouShangJia"),cc.p(cSize.width/2, 34),cc.p(0.5,0.5),22,nil,nil,nil,MColor.lable_yellow)
        do return end
    end
	local MMenuButton = require "src/component/button/MenuButton"
	MMenuButton.new(
	{
		src = {"res/component/button/50.png", "res/component/button/50_sel.png"},
		parent = bg,
		pos = cc.p(cSize.width/2, 34),
		
		label = {
			src = game.getStrByKey("putaway"),
			size = 22,
			color = MColor.lable_yellow,
		},
		
		cb = function()
			local sPrice = tonumber(single_price)
			if sPrice == nil then
				TIPS({ type = 1, str = game.getStrByKey("invalid_input_tips") })
				return
			end
			
			local MConfirmBox = require "src/functional/ConfirmBox"
			local box = MConfirmBox.new(
			{
				handler = function(box)
					local MConsignOp = require "src/layers/consign/ConsignOp"
					local protoId = MPackStruct.protoIdFromGird(grid)
					local griId = MPackStruct.girdIdFromGird(grid)
					local ud, choice = RadioBox:value()
					MConsignOp:putInStorage(griId, num, isCurrency and sPrice or sPrice*num, ud[choice].id)
					if box then removeFromParent(box) box = nil end
				end,
				
				builder = function(box)
					local box_size = box:getContentSize()
					local revenue = math.min(math.ceil(sPrice * num * 0.03), 200)
					local format_str = "出售成功后将收取%d元宝的手续费\n，是否确认上架？"
					local str = string.format(format_str,revenue)
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


			
		end,
	})
	-- -----------------------
	-- Mnode.addChild(
	-- {
	-- 	parent = parent,
	-- 	child = bg,
	-- 	pos = cc.p(parent_size.width/2, parent_size.height/2),
	-- 	tag = 1,
	-- })
end

new = function(params)
	local MConsignOp = require "src/layers/consign/ConsignOp"
	local res = "res/layers/consign/"
	local Mbaseboard = require "src/functional/baseboard"
	local MMenuButton = require "src/component/button/MenuButton"
	local MCustomView = require "src/layers/bag/CustomView"
	local MpropOp = require "src/config/propOp"
	---------------------------------------------------------------
	local root = Mnode.createNode({ cSize = cc.size(960, 640) })
	local rootSize = root:getContentSize()
	---------------------------------------------------------------
	-- local left_bg = cc.Sprite:create("res/common/bg/bg11.png")
	-- local left_bg_size = left_bg:getContentSize()

	-- Mnode.addChild(
	-- {
	-- 	parent = root,
	-- 	child = left_bg,
	-- 	anchor = cc.p(1, 0.5),
	-- 	pos = cc.p(544, 288),
	-- })

	local left_bd = cc.Sprite:create("res/common/bg/bg1.png")
	local left_bd_size = left_bd:getContentSize()

	Mnode.addChild(
	{
		parent = root,
		child = left_bd,
		anchor = cc.p(1, 0.5),
		pos = cc.p(544, 287),
	})
	--------------
	local right_bg_size = cc.size(390,500)
	local right_bg = createScale9Frame(
        root,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(545, 37),
        right_bg_size,
        5
    )
	-- cc.Sprite:create("res/common/bg/bg13.png")
	-- local right_bg_size = right_bg:getContentSize()

	-- Mnode.addChild(
	-- {
	-- 	parent = root,
	-- 	child = right_bg,
	-- 	anchor = cc.p(0, 0.5),
	-- 	pos = cc.p(540, 287),
	-- })
	
	-- 提示信息
    --[[
	Mnode.createLabel(
	{
		src = "请点击左侧列表中\n您需要出售的商品",
		parent = right_bg,
		pos = cc.p(right_bg_size.width/2, right_bg_size.height/2),
		size = 21,
		color = MColor.white,
	})
    ]]
    show_putaway_view(right_bg, nil)
	---------------------------------------------
	-- 数据
	---------------------------------------------------------------
	local bag = MPackManager:getPack(MPackStruct.eBag)
	local list = bag:filtrate(function(grid)
		local protoId = MPackStruct.protoIdFromGird(grid)
		local consignCate = MpropOp.consignCate(protoId)
		local isBind = MPackStruct.attrFromGird(grid, MPackStruct.eAttrBind)
		--dump({protoId=protoId, consignCate=consignCate, isBind=isBind}, "上架条件")
		return consignCate > 0 and not isBind
	end, MPackStruct.eAll)
	
	--[[
	local coin_grid = MPackStruct:buildGrid(
	{
		protoId = 999998,
		gridId = 999998,
		num = MRoleStruct:getAttr(PLAYER_MONEY),
	})
	table.insert(list, 1, coin_grid)
	
	local ingot_grid = MPackStruct:buildGrid(
	{
		protoId = 222222,
		gridId = 222222,
		num = MRoleStruct:getAttr(PLAYER_INGOT),
	})
	table.insert(list, 1, ingot_grid)
	--]]
	
	local map = {}
	for i, v in ipairs(list) do
		local griId = MPackStruct.girdIdFromGird(v)
		map[griId] = i
	end
	
	local space = bag:maxNumOfGirdCanOpen()
	local shared = { list = list, map = map, now_focusd = nil, griId = nil }
	---------------------------------------------------------------
	-- gridView
	local layout = { row = 5, col = 5, }
	local gv = MCustomView.new(
	{
		--bg = "res/common/68.png",
		layout = layout,
	})
	
	gv.numsInGrid = function(gv)
		return space
	end
	
	gv.onCreateCell = function(gv, idx, cell)
		local grid = shared.list[idx+1]
		if idx >= #shared.list or type(grid) ~= "table" then return end
		
		local cellSize = cell:getContentSize()
		local cellCenter = cc.p(cellSize.width/2, cellSize.height/2)
		
		------------------------------------------------------------
		local protoId = MPackStruct.protoIdFromGird(grid)
		local isEquip = MPackStruct:getCategoryByPropId(protoId) == MPackStruct.eEquipment
		local strengthLv = MPackStruct.attrFromGird(grid, MPackStruct.eAttrStrengthLevel)
		local griId = MPackStruct.girdIdFromGird(grid)
		local num = MPackStruct.overlayFromGird(grid)
		local isBind = MPackStruct.attrFromGird(grid, MPackStruct.eAttrBind)
		------------------------------------------------------------
		local Mprop = require "src/layers/bag/prop"
		
		local icon = Mprop.new(
		{
			grid = grid,
			num = not isEquip and num or nil,
			strengthLv = strengthLv,
			showBind = true,
			isBind = isBind,
			red_mask = true,
			powerHint = isEquip and true or nil,
		})
		
		if shared.now_focusd == idx then
			icon:setOverlay(shared.remain or 0)
			icon:setMask(true)
		end
			
		Mnode.addChild(
		{
			parent = cell,
			child = icon,
			pos = cellCenter,
		})
		
		cell.icon = icon
	end
	
	gv.onCellTouched = function(gv, idx, cell)
		local grid = shared.list[idx+1]
		if idx >= #shared.list or type(grid) ~= "table" then return end
		
				------------------------------------------------------------
		local protoId = MPackStruct.protoIdFromGird(grid)
		local isEquip = MPackStruct:getCategoryByPropId(protoId) == MPackStruct.eEquipment
		local strengthLv = MPackStruct.attrFromGird(grid, MPackStruct.eAttrStrengthLevel)
		local griId = MPackStruct.girdIdFromGird(grid)
		local num = MPackStruct.overlayFromGird(grid)
		local MpropOp = require "src/config/propOp"
		AudioEnginer.playEffect(MpropOp.soundEffect(protoId), false)
		------------------------------------------------------------
		local handler = function(value,params,showShownRight)
			if shared.now_focusd ~= nil and shared.now_focusd ~= idx then
				local cell = gv:cellAtIndex(shared.now_focusd)
				if cell ~= nil then
					local icon = cell.icon
					dump(tolua.type(icon), "icon")
					local grid = shared.list[shared.now_focusd+1]
					local num = MPackStruct.overlayFromGird(grid)
					icon:setOverlay(num)
					icon:setMask(false)
				end
			end
			---------------------------------------------
			local icon = cell.icon
			dump(tolua.type(icon), "icon")
			local remain = num - value
			shared.remain = remain
			icon.setOverlay(icon, remain) -- 用这个调用icon:setOverlay(remain)有时候会报错说setOverlay是一个nil值，原因未知
			icon:setMask(true)
			---------------------------------------------
			shared.now_focusd = idx
			shared.griId = griId
			
			show_putaway_view(right_bg, grid, value, shared,params)
            print("show_putaway_view(right_bg, grid, value, shared) ..............................................")
			removeFromParent(box)
		end
		
		local actions = {}
		actions[#actions+1] = num > 0 and
		{
			label = game.getStrByKey("put"),
			cb = function(act_params)
				local maxInputNum=num
				local numLimit=getConfigItemByKey("TransactionLimit", "q_ItemId",protoId,"q_MaxNum2")
				if numLimit and numLimit>0 then
					maxInputNum=math.min(num,numLimit)
				end
				--[[
                if maxInputNum > 1 then
                    local MChoose = require("src/functional/ChooseQuantity")
					MChoose.new(
					{
						title = game.getStrByKey("put"),
						config = { sp = 1, ep = maxInputNum, cur = 1 },
						builder = function(box, parent)
							local cSize = parent:getContentSize()
							
							box:buildPropName(grid)
							
							local Mprop = require "src/layers/bag/prop"
							local icon = Mprop.new(
							{
								grid = grid,
								strengthLv = strengthLv,
							})
							
							-- 物品图标
							Mnode.addChild(
							{
								parent = parent,
								child = icon,
								pos = cc.p(70, 264),
							})
							
							box.icon = icon
						end,
						
						handler = function(box, value)
							handler(value)
							removeFromParent(box)
						end,
						
						onValueChanged = function(box, value)
							box.icon:setOverlay(value)
						end,
					})
				elseif maxInputNum > 0 then
					handler(1)
				end
                ]]
                local params = {
                    config = { sp = 1, ep = maxInputNum, cur = 1 },
				    onValueChanged = function(value)
					    if shared.now_focusd ~= nil and shared.now_focusd ~= idx then
				            local cell = gv:cellAtIndex(shared.now_focusd)
				            if cell ~= nil then
					            local icon = cell.icon
					            dump(tolua.type(icon), "icon")
					            local grid = shared.list[shared.now_focusd+1]
					            local num = MPackStruct.overlayFromGird(grid)
					            icon:setOverlay(num)
					            icon:setMask(false)
				            end
			            end
			            ---------------------------------------------
			            local icon = cell.icon
			            dump(tolua.type(icon), "icon")
			            local remain = num - value
			            shared.remain = remain
			            icon.setOverlay(icon, remain) -- 用这个调用icon:setOverlay(remain)有时候会报错说setOverlay是一个nil值，原因未知
			            icon:setMask(true)
			            ---------------------------------------------
			            shared.now_focusd = idx
			            shared.griId = griId
				    end
                }
                handler(1,params)
			end,
		} or nil
		
		actions[#actions+1] = 
		{
			label = game.getStrByKey("cancel"),
			cb = function(act_params) end,
		}
		
		local Mtips = require "src/layers/bag/tips"
		Mtips.new(
		{
			grid = grid,
			actions = actions,
		})
	end
	
	gv:refresh()
	
	Mnode.addChild(
	{
		parent = left_bd,
		child = gv:getBgNode(),
		pos = cc.p(left_bd_size.width/2, left_bd_size.height/2),
	})
	-----------------------------------------------------------------------
	local updateData = function(griId, gz)
		local idx = shared.map[griId]
		dump({["shared.griId"]=shared.griId, griId=griId, idx=idx}, "updateData")
		if idx then
			if gz == nil then
				shared.list[idx] = true
			else
				shared.list[idx] = gz
			end
			
			shared.idx = nil
			shared.now_focusd = nil
			gv:updateCellAtIndex(idx-1)
		end
		
		if shared.griId == griId then
            print("show_putaway_view(right_bg, nil) ..............................................")
			show_putaway_view(right_bg, nil)
		end
	end
	
	local bagDataChanged = function(observable, event, pos, pos1, gz)
		--dump({ event = event, pos = pos, pos1 = pos1 })
		if event == "=" or event == "-" then
			updateData(pos, gz)
		end
	end
	
	local dataSourceChanged = function(observable, event, data)
		--dump(event, "event")
		if event == "putInStorage" then
			TIPS({ type = 1, str = "物品上架成功!" })
			--[[
			local grid = data.grid
			local protoId = MPackStruct.protoIdFromGird(grid)
			if protoId == 222222 then -- 元宝上架
				local gz = shared.list[1]
				updateData(222222, gz)
			elseif protoId == 999998 then -- 金币上架
				local gz = shared.list[2]
				updateData(999998, gz)
			end
			--]]
			
		end
	end
	
	-- 货币数值发生了变化
	local onCurrencyChanged = function(observable, attrId, objId, isMe, attrValue)
		if not isMe then return end
		
		local idx = nil
		if attrId == PLAYER_INGOT then -- 元宝
			idx = 0
		elseif attrId == PLAYER_MONEY then -- 金币
			idx = 1
		end
		if idx == nil then return end
		
		-- 更新数据
		local grid = shared.list[idx+1]
		MPackStruct.gridSetOverlay(grid, attrValue)
		
		-- 更新界面
		local cell = gv:cellAtIndex(idx)
		if cell ~= nil then
			local icon = cell.icon
			icon.setOverlay(icon, attrValue)
		end
	end

	root:registerScriptHandler(function(event)
		local MConsignOp = require "src/layers/consign/ConsignOp"
		local MRoleStruct = require "src/layers/role/RoleStruct"
		local bag = MPackManager:getPack(MPackStruct.eBag)
		if event == "enter" then
			bag:register(bagDataChanged)
			--MRoleStruct:register(onCurrencyChanged)
			MConsignOp:register(dataSourceChanged)
		elseif event == "exit" then
			bag:unregister(bagDataChanged)
			--MRoleStruct:unregister(onCurrencyChanged)
			MConsignOp:unregister(dataSourceChanged)
		end
	end)
	-----------------------------------------------------------------------
	return root
end