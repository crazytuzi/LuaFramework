-- 倒计时
local format_time = function(remain_time) -- 剩余时间
	---------------
	local day = math.floor(remain_time/(24*60*60))
	local remain = remain_time%(24*60*60)
	
	local hours = math.floor(remain/(60*60))
	local remain = remain%(60*60)
	
	local minute = math.floor(remain/60)
	local second = remain%60
	
	if day > 0 then
		local ret = string.format("%02d天%02d:%02d:%02d", day, hours, minute, second)
		return ret
	else
		local ret = string.format("%02d:%02d:%02d", hours, minute, second)
		return ret
	end
	---------------
end

local sellStateIcon = function(state)
	if state == nil then return end
	if state <= 0 then return nil end
	
	local bg = nil
	local dir = "res/layers/shop/label/"
	if state <= 3 then
		bg = "1"
	elseif state <= 6 then
		bg = "2"
	elseif state <= 9 then
		bg = "3"
	else
		bg = "4"
	end
	
	bg = cc.Sprite:create(dir .. bg .. ".png")
	local size = bg:getContentSize()
	
	local content = cc.Sprite:create("res/layers/shop/discount/" .. state .. ".png")
    if content then
	    content:setPosition( cc.p(size.width/2, size.height/2 + 10) )
	    bg:addChild(content)
    else
        print("Error: res/layers/shop/discount/" .. state .. ".png");
    end
	return bg
end

local storeCurrency = 
{
	-- 元宝商城
	[0] = 2,
	
	-- 绑定元宝商城
	[1] = 4,
	
	-- 金币商城
	[2] = 1,
	
	-- VIP商城
	[3] = 2,
	
	-- 药品商城
	[14] = 1,
	
	-- 书店商城
	[19] = 1,
}

local currencyIcon = 
{
	-- 金币
	[1] = 1,
	-- 元宝
	[2] = 3,
	-- 绑定金币
	[3] = 2,
	-- 绑定元宝
	[4] = 4,
}

local mystery_cfg = 
{
	[1] = {path = "3", name = game.getStrByKey("ingot")},
	[2] = {path = "4", name = game.getStrByKey("bind_ingot")},
	[3] = {path = "1", name = game.getStrByKey("gold_coin")},
	[4] = {path = "6", name = game.getStrByKey("melting_value")},
}

local buildIcon = function(tv, bg, protoId, num)
	local Mprop = require "src/layers/bag/prop"
	local icon = Mprop.new(
	{
		protoId = protoId,
		num = num ~= nil and num or nil,
		--cb = "tips",
		--bg = false,
	})
	
	Mnode.addChild(
	{
		parent = bg,
		child = icon,
		pos = cc.p(50, 50),
	})
	
	return icon
end

local buildName = function(bg, protoId)
	local MpropOp = require "src/config/propOp"
	-- Mnode.createLabel(
	-- {
	-- 	parent = bg,
	-- 	src = MpropOp.name(protoId),
	-- 	--color = MpropOp.nameColor(protoId),
	-- 	color = MColor.lable_yellow,
	-- 	size = 20,
	-- 	pos = cc.p(145, 71),
	-- 	anchor=cc.p(0,0.5),
	-- 	outline = false,
	-- })
	createLabel(bg, MpropOp.name(protoId),cc.p(105, 71), cc.p(0,0.5), 20, true, 0, nil,MColor.lable_yellow)
end

local buildSellState = function(bg, state)
	local stateIcon = sellStateIcon(state)
	if stateIcon ~= nil then
		Mnode.addChild(
		{
			parent = bg,
			child = stateIcon,
			pos = cc.p(268, 54),
		})
	end
end

local buildPropCorner = function(bg, state)
    if state == nil then return end
    if bg == nil then return end

    if state <= 0 or state > 5 then
        return
    end

    local dir = "res/layers/shop/corner/";
    local bgSize = bg:getContentSize();

    local cornerSpr = cc.Sprite:create(dir .. state .. ".png")
    if cornerSpr then
        cornerSpr:setPosition(0, bgSize.height-cornerSpr:getContentSize().height);
        cornerSpr:setAnchorPoint(cc.p(0, 0));
        bg:addChild(cornerSpr);
    end
end

local buildPrice = function(storeId, bg, price)
	-- local n_price = Mnode.combineNode(
	-- {
	-- 	nodes = {
	-- 		-- Mnode.createLabel(
	-- 		-- {
	-- 		-- 	src = game.getStrByKey("selling_price") .. " ",
	-- 		-- 	color = MColor.lable_yellow,
	-- 		-- 	size = 20,
	-- 		-- 	outline = false,
	-- 		-- }),
			
			
	-- 	},
	-- 	margins=10
	-- })
		
	-- Mnode.addChild(
	-- {
	-- 	parent = bg,
	-- 	child = n_price,
	-- 	pos = cc.p(145, 26),
	-- })

	-- Mnode.createSprite(
	-- {
	-- 	src = "res/group/currency/" .. currencyIcon[storeCurrency[storeId]] .. ".png",
	-- 	scale = 0.65,
	-- 	parent = bg,
	-- 	pos = cc.p(bgSize.width/2, bgSize.height/2),
	-- }),
	
	-- Mnode.createLabel(
	-- {
	-- 	src = price,
	-- 	size = 20,
	-- 	color = MColor.white,
	-- 	outline = false,
	-- }),
	local icon=createSprite( bg , "res/group/currency/" .. currencyIcon[storeCurrency[storeId]] .. ".png" , cc.p( 105 , 26 ) , cc.p( 0 , 0.5 ) )
	icon:setScale(0.65)
	createLabel(bg, price,cc.p(145,26), cc.p(0,0.5), 20, true, 0, nil,MColor.white)
end

local build_func = function(list, storeId, tv, item_idx, cell, bg)
	local item = list[item_idx]
	local protoId = item.mProtoID
	
	-- 物品图标
	buildIcon(tv, bg, protoId)
	
	-- 物品名字
	buildName(bg, protoId)
	
	-- 物品价格
	buildPrice(storeId, bg, item.mSellingPrice)
	
	-- 销售状态
	buildSellState(bg, item.mSellState)

    -- 道具角标
    buildPropCorner(bg, item.label);
end

local build_mystery_store = function(list, storeId, tv, item_idx, cell, bg)
	local MpropOp = require "src/config/propOp"
	
	local item = list[item_idx]
	local protoId = item.itemID
	
	local bg_size = bg:getContentSize()
	
	-- 物品图标
	local icon = buildIcon(tv, bg, protoId)
	
	-- 物品名字
	-- Mnode.createLabel(
	-- {
	-- 	parent = bg,
	-- 	src = MpropOp.name(protoId).."x"..item.sourceCount,
	-- 	--color = MpropOp.nameColor(protoId),
	-- 	color = MColor.lable_yellow,
	-- 	size = 20,
	-- 	pos = cc.p(169, 71),
	-- 	outline = false,
	-- })
	createLabel(bg, MpropOp.name(protoId).."x"..item.sourceCount,cc.p(105, 71), cc.p(0,0.5), 20, true, 0, nil,MColor.lable_yellow)
	-- 物品价格
	-- local n_price = Mnode.combineNode(
	-- {
	-- 	nodes = {
	-- 		Mnode.createLabel(
	-- 		{
	-- 			src = game.getStrByKey("selling_price") .. " ",
	-- 			color = MColor.yellow,
	-- 			size = 20,
	-- 			outline = false,
	-- 		}),
			
	-- 		Mnode.createSprite(
	-- 		{
	-- 			src = "res/group/currency/" .. mystery_cfg[item.Type].path .. ".png",
	-- 			scale = 0.65,
	-- 		}),
			
	-- 		Mnode.createLabel(
	-- 		{
	-- 			src = numToFatString(item.Price),
	-- 			size = 20,
	-- 			outline = false,
	-- 		}),
	-- 	},
	-- })
	
	-- Mnode.addChild(
	-- {
	-- 	parent = bg,
	-- 	child = n_price,
	-- 	pos = cc.p(169, 26),
	-- })
	local icon=createSprite( bg , "res/group/currency/" .. mystery_cfg[item.Type].path .. ".png", cc.p( 105 , 26 ) , cc.p( 0 , 0.5 ) )
	icon:setScale(0.65)
	createLabel(bg, numToFatString(item.Price),cc.p(140,26), cc.p(0,0.5), 20, true, 0, nil,MColor.white)
	-- 售罄
	if item.Count == 0 then
		local n_mask = Mnode.createSprite(
		{
			parent = bg,
			src = "res/common/scalable/8.png",
			pos = cc.p(bg_size.width/2, bg_size.height/2),
			--opacity = 255*0.7,
			zOrder = 2,
		})
		
		local n_mask_size = n_mask:getContentSize()
		
		Mnode.createSprite(
		{
			parent = n_mask,
			src = "res/component/flag/13.png",
			pos = cc.p(n_mask_size.width/2, n_mask_size.height/2),
			--opacity = 255*0.7,
			zOrder = 2,
		})
	end
end

local mystery_buy_func = function(cfg, list, storeId, tv, item_idx, cell, bg)
	local item = list[item_idx]
	
	if item.Count < 1 then
		TIPS({ type = 1  , str = game.getStrByKey("buy_rul_tips") })
		return
	end
	
	local MConfirmBox = require "src/functional/ConfirmBox"
	local box = MConfirmBox.new(
	{
		parent = tv:getParent():getParent(),
		handler = function(box)
			local MShopOp = require "src/layers/shop/ShopOp"
			MShopOp:buyHunZhiStore(storeId, item.Type, item.Index, item.itemID, item.sourceCount)
			local userData = tv.userData
			if userData ~= nil then userData.item_idx = item_idx end
			if box then removeFromParent(box) box = nil end
		end,
		
		builder = function(box)
			local MpropOp = require "src/config/propOp"
			local protoId = item.itemID
			local name = MpropOp.name(protoId)
	
			local box_size = box:getContentSize()
			local isEquip = MPackStruct:getCategoryByPropId(protoId) == MPackStruct.eEquipment
			
			-- 物品图标
			local Mprop = require "src/layers/bag/prop"
			local icon = Mprop.new(
			{
				protoId = protoId,
				cb = "tips",
				isBind = item.Type ~= 1 and not isEquip,
			})
			
			Mnode.addChild(
			{
				parent = box,
				child = icon,
				pos = cc.p(80, 175),
			})
			
			local str = string.format(game.getStrByKey("shop_buy_sure_tips"), item.Price, mystery_cfg[item.Type].name, item.sourceCount, name)
			Mnode.createLabel(
			{
				parent = box,
				src = str,
				color = MColor.lable_yellow,
				size = 20,
				anchor = cc.p(0, 0.5),
				pos = cc.p(140, 175),
				outline = false,
			})
		end,
	})
end

local buy_func = function(cfg, list, storeId, tv, item_idx, cell, bg)
	local MpropOp = require "src/config/propOp"
	local Mprop = require "src/layers/bag/prop"
	local MShopOp = require "src/layers/shop/ShopOp"
	
	local item = list[item_idx]
	
	local show_buy_view = function()
		---------------------------------
		local protoId = item.mProtoID
		local whole = item.mWholeRemaining ~= -1
		local single = item.mSingleBuyLimits ~= -1
		local singleBuyLimits = item.mSingleBuyLimits
		local wholeBuyLimits = item.mWholeBuyLimits
		local price = item.mSellingPrice
		---------------------------------
		--dump({whole=whole, single=single})
		local maxNum = 0
		if whole then -- 全服限购
			if single then -- 全服限购 && 个人限购
				maxNum = math.min(singleBuyLimits - item.mSingleBuyNums, item.mWholeRemaining)
			else -- 全服限购 && 个人不限购
				maxNum = item.mWholeRemaining
			end
		else -- 全服不限购
			if single then -- 全服不限购 && 个人限购
				maxNum = singleBuyLimits - item.mSingleBuyNums
			else -- 全服不限购 && 个人不限购
				maxNum = MpropOp.maxOverlay(protoId)
			end
		end
		
		--dump(maxNum, "maxNum")
		---------------------------------
        local attrKind = nil
        local itemType = nil
        local realMaxNum = nil
        if storeId ~= 5 then
            if storeCurrency[storeId] then
                itemType = storeCurrency[storeId]
            end
            if itemType == 1 then
                -- jinbi
                attrKind = PLAYER_MONEY
            elseif itemType ==2 then
                -- yuanbao
                attrKind = PLAYER_INGOT
            elseif itemType == 3 then
                -- bangding jinbi
                attrKind = PLAYER_BINDMONEY
            elseif itemType == 4 then
                -- bangding yuanbao
                attrKind = PLAYER_BINDINGOT
            end 
            if attrKind then
                realMaxNum = math.floor(MRoleStruct:getAttr(attrKind) / price) 
            end
        else
            -- hanghui gongxian value
            local totalGXValue = require("src/layers/shop/CommData").hanghuiGongXianValue
            realMaxNum = math.floor(totalGXValue / price)
        end

        if realMaxNum then
            if realMaxNum == 0 then
                realMaxNum = 1
            end
            if realMaxNum < maxNum then
                maxNum = realMaxNum
            end
            --maxNum = 20
        end

		local MChoose = require("src/functional/ChooseQuantity")
		local box = MChoose.new(
		{
			title = game.getStrByKey("buy_prop"),
			parent = tv:getParent():getParent(),
			config = { sp = maxNum == 0 and 0 or 1, ep = maxNum, cur = maxNum == 0 and 0 or 1 },
			builder = function(box, parent)
				local cSize = parent:getContentSize()
				
				box:buildPropName(MPackStruct:buildGirdFromProtoId(protoId), storeId ~= 0)
				
				-- 物品图标
				local icon = Mprop.new(
				{
					protoId = protoId,
					cb = "tips",
					isBind = storeId ~= 0,
				})
				
				Mnode.addChild(
				{
					parent = parent,
					child = icon,
					pos = cc.p(70, 264),
				})
				
				box.icon = icon
				
				local nodes = {}
				local singleLimitsStr=item.mSingleBuyNums.."/" .. singleBuyLimits
			    
                if single or storeId == 20 then
                    if not single then
                        singleLimitsStr=""
                        local singleLimitsLabel= Mnode.createLabel(
				        {
					        parent = parent,
					        src = "∞",
					        size = 35,
					        color = MColor.lable_yellow,
					        pos = cc.p(270, 234),
				        })
                    end
					nodes[#nodes+1] = Mnode.createLabel(
					{
						src = (protoId == 1076 and "限购" or game.getStrByKey("single_buy_limits")) .. ": " .. singleLimitsStr,
						color = MColor.lable_yellow,
						size = 20,
						outline = false,
					})
				end
                local wholeLimitsStr=(wholeBuyLimits-item.mWholeRemaining) .. "/" .. wholeBuyLimits
			    if whole or storeId == 20 then
                    if not whole then
                        wholeLimitsStr=""
                        local wholeLimitsLabel= Mnode.createLabel(
				        {
					        parent = parent,
					        src = "∞",
					        size = 35,
					        color = MColor.lable_yellow,
					        pos = cc.p(270, 265),
				        })
                    end
					nodes[#nodes+1] = Mnode.createLabel(
					{
						src = game.getStrByKey("whole_buy_limits") .. ": " .. wholeLimitsStr,
						color = MColor.lable_yellow,
						size = 20,
						outline = false,
					})
				end
				
				local TotalPrice = Mnode.createKVP(
				{
					k = Mnode.createLabel(
					{
						src = game.getStrByKey("buy_totle_price").." ",
						color = MColor.lable_yellow,
						size = 20,
						outline = false,
					}),
					
					v = {
						src = "",
						color = MColor.lable_yellow,
						size = 20,
					},
				})
				
				nodes[#nodes+1] = TotalPrice
				
				Mnode.addChild(
				{
					parent = parent,
					child = Mnode.combineNode(
					{
						nodes = nodes,
						ori = "|",
						align = "l",
						margins = 5,
					}),
					
					anchor = cc.p(0, 0.5),
					--pos = cc.p(153, 243),
					pos = cc.p(130, 264),
				})
				
				box.TotalPrice = TotalPrice
			end,
			
			handler = function(box, value)
				if maxNum < 1 then
					TIPS({ type = 1  , str = game.getStrByKey("buy_rul_tips") })
					return
				end
				
				local MShopOp = require "src/layers/shop/ShopOp"
				MShopOp:buy(storeId, item.mGoodsID, value)
				
				local userData = tv.userData
				if userData ~= nil then userData.item_idx = item_idx end
				
				if box then removeFromParent(box) box = nil end
			end,
			
			onValueChanged = function(box, value)
				box.icon:setOverlay(value)
				box.TotalPrice:setValue(price * value .. " " .. tostring(cfg[storeId].currency_name))
			end,
		})
	end
	--dump(item, "item")
	if item.mWholeRemaining ~= -1 and item.mWholeRemaining < item.mWholeBuyLimits then
		local MShopOp = require "src/layers/shop/ShopOp"
		MShopOp:LimitsBuyQuery(item.mGoodsID, function(data)
			item.mWholeRemaining = data.wholeRemaining
			show_buy_view()
		end)
	else
		show_buy_view()
	end
end

local build_faction_store = function(list, storeId, tv, item_idx, cell, bg)
	local item = list[item_idx]
	local protoId = item.mProtoID
	
	-- 物品图标
	buildIcon(tv, bg, protoId)
	
	-- 物品名字
	buildName(bg, protoId)
	
	-- 物品价格
	local n_price = Mnode.combineNode(
	{
		nodes = {
			Mnode.createLabel(
			{
				src = game.getStrByKey("consume")..game.getStrByKey("bang_gong").." ",
				color = MColor.lable_yellow,
				size = 20,
				outline = false,
			}),
			
			Mnode.createLabel(
			{
				src = item.mSellingPrice,
				size = 20,
				color = MColor.lable_yellow,
				outline = false,
			}),
		},
	})
		
	Mnode.addChild(
	{
		parent = bg,
		child = n_price,
		pos = cc.p(169, 26),
	})

    --售罄
    if item.mSingleBuyNums >= item.mSingleBuyLimits then
		Mnode.createSprite(
		{
			parent = bg,
			src = "res/layers/shop/sell_over2.png",
			anchor = cc.p(0.5, 0.5),
			pos = cc.p(bg:getContentSize().width/2, bg:getContentSize().height/2),
			--opacity = 255*0.7,
			zOrder = 2,
		})
	end
    
end
local haveRequestShopList=false
local tBuildAct = 
{
	-- 元宝商城
	[0] = {
		currency_name = "元宝",
	},
	
	-- 绑定元宝商城
	[1] = {
		currency_name = "绑定元宝",
	},
	
	-- 1级帮派商城
	[5] = 
	{
		build_act = build_faction_store,
		buy_act = buy_func,
		currency_name = "贡献值",
	},
	
	-- 2级帮派商城
	[6] = 
	{
		build_act = build_faction_store,
		buy_act = buy_func,
		currency_name = "贡献值",
	},
	
	-- 3级帮派商城
	[7] = 
	{
		build_act = build_faction_store,
		buy_act = buy_func,
		currency_name = "贡献值",
	},
	
	-- 4级帮派商城
	[8] = 
	{
		build_act = build_faction_store,
		buy_act = buy_func,
		currency_name = "贡献值",
	},
	
	-- 5级帮派商城
	[9] = 
	{
		build_act = build_faction_store,
		buy_act = buy_func,
		currency_name = "贡献值",
	},
	
	-- 6级帮派商城
	[15] = 
	{
		build_act = build_faction_store,
		buy_act = buy_func,
		currency_name = "贡献值",
	},
	
	-- 7级帮派商城
	[16] = 
	{
		build_act = build_faction_store,
		buy_act = buy_func,
		currency_name = "贡献值",
	},
	
	-- 8级帮派商城
	[17] = 
	{
		build_act = build_faction_store,
		buy_act = buy_func,
		currency_name = "贡献值",
	},
	
	-- 9级帮派商城
	[18] = 
	{
		build_act = build_faction_store,
		buy_act = buy_func,
		currency_name = "贡献值",
	},
	
	-- 积分商城
	[12] = 
	{
		build_act = function(list, storeId, tv, item_idx, cell, bg)
			local item = list[item_idx]
			local protoId = item.mProtoID
			
			-- 物品图标
			buildIcon(tv, bg, protoId, num)
			
			-- 物品名字
			buildName(bg, protoId)
			
			-- 物品价格
			local n_price = Mnode.combineNode(
			{
				nodes = {
					Mnode.createLabel(
					{
						src = game.getStrByKey("consume")..game.getStrByKey("integral").." ",
						color = MColor.lable_yellow,
						size = 20,
						outline = false,
					}),
					
					Mnode.createLabel(
					{
						src = item.mSellingPrice,
						size = 20,
						color = MColor.lable_yellow,
						outline = false,
					}),
				},
			})
				
			Mnode.addChild(
			{
				parent = bg,
				child = n_price,
				pos = cc.p(169, 26),
			})
			
			
			-- 销售状态
			buildSellState(bg, item.mSellState)
		end,
		
		currency_name = "积分",
	},
	
	-- 魂值商城
	[-2] = 
	{
		build_act = build_mystery_store,
		buy_act = mystery_buy_func,
	},
	
	-- 神秘商城
	[-3] = 
	{
		build_act = build_mystery_store,
		buy_act = mystery_buy_func,
	},
	
	-- 本服竞技场商城
	[11] = 
	{
		build_act = function(list, storeId, tv, item_idx, cell, bg)
			local item = list[item_idx]
			local protoId = item.mProtoID
			
			-- 物品图标
			buildIcon(tv, bg, protoId)
			
			-- 物品名字
			buildName(bg, protoId)
			
			-- 物品价格
			local n_price = Mnode.combineNode(
			{
				nodes = {
					Mnode.createLabel(
					{
						src = game.getStrByKey("consume")..game.getStrByKey("honor_s").." ",
						color = MColor.lable_yellow,
						size = 20,
						outline = false,
					}),
					
					Mnode.createLabel(
					{
						src = item.mSellingPrice,
						size = 20,
						color = MColor.lable_yellow,
						outline = false,
					}),
				},
			})
				
			Mnode.addChild(
			{
				parent = bg,
				child = n_price,
				pos = cc.p(169, 26),
			})
		end,
		buy_act = buy_func,
		currency_name = "功勋",
	},
	
	-- 跨服竞技场商城
	[13] = 
	{
		build_act = function(list, storeId, tv, item_idx, cell, bg)
			local item = list[item_idx]
			local protoId = item.mProtoID
			
			-- 物品图标
			buildIcon(tv, bg, protoId)
			
			-- 物品名字
			buildName(bg, protoId)
			
			-- 物品价格
			local n_price = Mnode.combineNode(
			{
				nodes = {
					Mnode.createLabel(
					{
						src = game.getStrByKey("consume")..game.getStrByKey("feats").." ",
						color = MColor.lable_yellow,
						size = 20,
						outline = false,
					}),
					
					Mnode.createLabel(
					{
						src = item.mSellingPrice,
						size = 20,
						color = MColor.lable_yellow,
						outline = false,
					}),
				},
			})
				
			Mnode.addChild(
			{
				parent = bg,
				child = n_price,
				pos = cc.p(169, 26),
			})
		end,
		buy_act = buy_func,
		currency_name = "功勋",
	},
	
	-- 药品商城
	[14] = 
	{
		build_act = build_func,
		buy_act = buy_func,
		currency_name = "金币",
	},
	
	-- 书店商城
	[19] = 
	{
		build_act = build_func,
		buy_act = buy_func,
		currency_name = "金币",
	},
	
	-- 限时商城
	[20] = 
	{
		build_act = function(list, storeId, tv, item_idx, cell, bg)
			local item = list[item_idx]
			local protoId = item.mProtoID
			local goods_id = item.mGoodsID
			-- 物品图标
			local Mprop = require "src/layers/bag/prop"
			local icon = Mprop.new(
			{
				protoId = protoId,
			})
			
			Mnode.addChild(
			{
				parent = bg,
				child = icon,
				pos = cc.p(50, 105),
			})
			
			-- 物品名字
			local MpropOp = require "src/config/propOp"
			Mnode.createLabel(
			{
				parent = bg,
				src = MpropOp.name(protoId),
				color = MColor.lable_yellow,
				size = 20,
				anchor = cc.p(0, 0.5),
				pos = cc.p(100, 135),
				outline = false,
			})
			
			-- 原价
			-- 商城表
			local tShopCfg =  getConfigItemByKey("MallDB")
			local record = tShopCfg[goods_id]
			if (not record) or (record.q_shop_type ~= 20) then
				return
			end
			local yuanbao = Mnode.createSprite(
			{
				src = "res/group/currency/3.png",
				scale = 0.65,
			})
			
			yuanbao:setColor(MColor.gray)

			local n_yuanjia = Mnode.combineNode(
			{
				nodes = {
					Mnode.createLabel(
					{
						src = "原价",
						color = MColor.lable_black,
						size = 20,
						outline = false,
					}),
					
					yuanbao,
					
					Mnode.createLabel(
					{
						src = tostring(record.q_show_gold),
						size = 20,
						color = MColor.lable_black,
						outline = false,
					}),
				},
				
				margins = 5,
			})
				
			Mnode.addChild(
			{
				parent = bg,
				child = n_yuanjia,
				anchor = cc.p(0, 0.5),
				pos = cc.p(100, 108),
			})
			
			local n_yuanjia_size = n_yuanjia:getContentSize()
			
			Mnode.createColorLayer(
			{
				parent = n_yuanjia,
				src = cc.c4b(244 ,164 ,96, 255*0.5),
				--src = cc.c4b(244 ,164 ,96, 255*0),
				cSize = cc.size(n_yuanjia_size.width, 2),
				anchor = cc.p(0, 0.5),
				pos = cc.p(0, n_yuanjia_size.height/2),
			})
			
			-- 现价
			local n_xianjia = Mnode.combineNode(
			{
				nodes = {
					Mnode.createLabel(
					{
						src = "现价",
						color = MColor.lable_yellow,
						size = 20,
						outline = false,
					}),
					
					Mnode.createSprite(
					{
						src = "res/group/currency/3.png",
						scale = 0.65,
					}),
					
					Mnode.createLabel(
					{
						src = tostring(item.mSellingPrice),
						size = 20,
						color = MColor.lable_yellow,
						outline = false,
					}),
				},
				
				margins = 5,
			})
				
			Mnode.addChild(
			{
				parent = bg,
				child = n_xianjia,
				anchor = cc.p(0, 0.5),
				pos = cc.p(100, 78),
			})
			
			-- 全服限购
            local remainStr=tostring(item.mWholeRemaining)
			if item.mWholeRemaining == -1 then
				remainStr=""
                 Mnode.createLabel(
			    {
				    parent = bg,
				    src = "∞",
				    size = 30,
				    color = MColor.lable_yellow,
				    pos = cc.p(60, 41),
			    })
			end
            local n_whole = Mnode.createKVP(
			{
				k = Mnode.createLabel(
				{
					src = "剩余: ",
					color = MColor.lable_yellow,
					size = 18,
					outline = false,
				}),
					
				v = {
					src = remainStr,
					color = MColor.white,
					size = 18,
					outline = false,
				},
			})
				
			Mnode.addChild(
			{
				parent = bg,
				child = n_whole,
				anchor = cc.p(0, 0.5),
				pos = cc.p(10, 42),
			})
			-- 个人限购
            local singleBuyLimitStr=tostring(item.mSingleBuyLimits - item.mSingleBuyNums)
			if item.mSingleBuyLimits == -1 then
				singleBuyLimitStr=""
                 Mnode.createLabel(
			    {
				    parent = bg,
				    src = "∞",
				    size = 30,
				    color = MColor.lable_yellow,
				    pos = cc.p(60, 18),
			    })
			end
			local n_whole = Mnode.createKVP(
			{
				k = Mnode.createLabel(
				{
					src = "限购: ",
					color = MColor.lable_yellow,
					size = 18,
					outline = false,
				}),
					
				v = {
					src =singleBuyLimitStr ,
					color = MColor.white,
					size = 18,
					outline = false,
				},
			})
				
			Mnode.addChild(
			{
				parent = bg,
				child = n_whole,
				anchor = cc.p(0, 0.5),
				pos = cc.p(10, 18),
			})
			-- 倒计时
			Mnode.createLabel(
			{
				parent = bg,
				src = "倒计时",
				size = 18,
				color = MColor.lable_yellow,
				outline = false,
				anchor = cc.p(0, 0.5),
				pos = cc.p(150, 42),
			})
			
			--dump(item.effectTime, "item.effectTime")
			local n_count_down = Mnode.createLabel(
			{
				parent = bg,
				src = format_time(item.effectTime),
				size = 18,
				color = MColor.white,
				outline = false,
				anchor = cc.p(0, 0.5),
				pos = cc.p(150, 18),
			})
			
			---[[
			local count_down = function(node, cb)
				local action = nil
				local DelayTime = cc.DelayTime:create(1)
				local CallFunc = cc.CallFunc:create(function(node)
					local MShopOp = require "src/layers/shop/ShopOp"
					item.effectTime = item.effectTime - 1
					if item.effectTime < 1 then
						if action ~= nil then node:stopAction(action) end
						if not haveRequestShopList then
							haveRequestShopList=true--防止同时请求多个
							MShopOp:requestGoodsList(20)
						end
					end
					if (item.effectTime==10 or item.effectTime==60) and haveRequestShopList==false then
						haveRequestShopList=true
						MShopOp:requestGoodsList(20)
					end
					if type(cb) == "function" then cb(node, item.effectTime) end
				end)
				local Sequence = cc.Sequence:create(DelayTime, CallFunc)
				action = cc.RepeatForever:create(Sequence)
				node:runAction(action)
			end
			--]]
			
			count_down(n_count_down, function(node, value)
				node:setString(format_time(value))
			end)
		end,
		buy_act = buy_func,
		currency_name = "元宝",
	},
}

return { new = function(params)
--------------------------------------------------------------
local MMenuButton = require "src/component/button/MenuButton"
package.loaded["src/layers/shop/ShopOp"] = nil
local MShopOp = require "src/layers/shop/ShopOp"
------------------------------------------------------------------------------------
local res = "res/layers/shop/"
------------------------------------------------------------------------------------
local params = params or {}
local storeId = params.storeId or 0
------------------------------------------------------------------------------------
-- 数据
local userData = { id = storeId }
local list = {}
local ingotNeed = 0

local reloadData = function(data)
	list = data.list
	if storeId == -3 then
		userData.info = data
		ingotNeed = data.refresh_ingot
	end
end

MShopOp:requestGoodsList(storeId)
------------------------------------------------------------------------------------
-- TableView
local item_bg = res..(storeId == 20 and "cell_bg1.png" or "cell_bg.png")
local item_bg_texture = TextureCache:addImage(item_bg)
local item_bg_texture_size = item_bg_texture:getContentSize()
local w = item_bg_texture_size.width * 2 + 10+14
local h = item_bg_texture_size.height + 4
local iSize = cc.size(w, h)
local vSize = cc.size(w, params.vSizeH or 440)
local tv = cc.TableView:create(vSize)
tv:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
tv:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
tv:setDelegate()
tv:addSlider("res/common/slider.png")

tv.userData = userData

local reloadView = function()
	tv:reloadData()
end

tv:registerScriptHandler(function(tv)
	return math.ceil(#list/2)
end, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)

tv:registerScriptHandler(function(tv, idx)
	return iSize.height, iSize.width
end, cc.TABLECELL_SIZE_FOR_INDEX)

local buildCellContent = nil
tv:registerScriptHandler(function(tv, idx)
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

tv:registerScriptHandler(function(tv, cell)
	cell:removeAllChildren()
end, cc.TABLECELL_WILL_RECYCLE)

--dump(ROLE_MAX_MP, "ROLE_MAX_MP")

local buildGoodsItem = function(tv, item_idx, cell, bg)
	local cfg = tBuildAct[storeId]
	if type(cfg) ~= "table" then return end
	
	local build_act = cfg.build_act or build_func
	build_act(list, storeId, tv, item_idx, cell, bg)
	
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
					local buy_act = cfg.buy_act or buy_func
					buy_act(tBuildAct, list, storeId, tv, item_idx, cell, bg)
				end
			end
		end,
	})
end

buildCellContent = function(tv, idx, cell)
	--[[
	1 -- 1, 2 -> 1*2
	2 -- 3, 4 -> 2*2
	3 -- 5, 6 -> 3*2
	--]]
	local group = idx+1
	local new_idx = group*2
	local item_left = list[new_idx-1]
	local item_right = list[new_idx]
	
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
end
------------------------------------------------------------------------------------
local dataSourceChanged = function(observable, event, data)
	dump(event, "event")
	if data.storeId ~= storeId then return end
	
	if event == "store_list" then
		haveRequestShopList=false
		reloadData(data)
		reloadView()
	elseif event == "buy_goods_ret" then
		--ud.saved_pos = tv:getContentOffset()
		
		-- 更新数据
		local item_idx = userData.item_idx
		local item = list[item_idx]
		if item == nil then return end
		
		if storeId == -3 then
			if data.result then
				item.Count = 0
			else
				return
			end
		else
			if item.mWholeRemaining ~= -1 or item.mSingleBuyLimits ~= -1 then
				if item.mWholeRemaining ~= -1 then item.mWholeRemaining = data.wholeRemaining end
				if item.mSingleBuyLimits ~= -1 then item.mSingleBuyNums = data.singleBuyNums end
			else
				return
			end
		end
		
		--dump(item_idx, "item_idx")
		local cell_idx = math.ceil(item_idx/2)-1
		--dump(cell_idx, "cell_idx")
		-- 更新界面
		local cell = tv:cellAtIndex(cell_idx)
		if cell ~= nil then
			tv:updateCellAtIndex(cell_idx)
		end
	end
end
	
tv:getContainer():registerScriptHandler(function(event)
	if event == "enter" then
		MShopOp:register(dataSourceChanged)
	elseif event == "exit" then
		MShopOp:unregister(dataSourceChanged)
	end
end)
------------------------------------------------------------------------------------
tv.getStoreId = function(self)
	return storeId
end
------------------------------------------------------------------------------------
return tv
------------------------------------------------------------------------------------
end }