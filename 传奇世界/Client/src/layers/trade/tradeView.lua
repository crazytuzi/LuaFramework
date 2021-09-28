return { new = function(params)
------------------------------------------------------------------------------------
local MpropOp = require "src/config/propOp"
local MtradeOp = require "src/layers/trade/tradeOp"
local MMenuButton = require "src/component/button/MenuButton"
------------------------------------------------------------------------------------
local res = "res/layers/trade/"
local lastMoney=0
------------------------------------------------------------------------------------
local params = type(params) ~= "table" and {} or params
------------------------------------------------------------------------------------
local root = Mnode.createNode({ cSize = cc.size(419, 536) })
local rootSize = root:getContentSize()
local M = Mnode.beginNode(root)
------------------------------------------------------------------------------------
-- 数据
mOneself = {}; mOther = {}
------------------------------------------------------------------------------------
local texture = TextureCache:addImage("res/common/bg/inputBg2.png")
local textureSize = texture:getContentSize()


-- 对方交易给自己的元宝
local ingotLabel = Mnode.createLabel(
{
	src = "0",
})

-- 自己交易给对方的元宝
local ingotEditbox = Mnode.createEditBox(
{
	hint = game.getStrByKey("hint"),
	cSize = cc.size(textureSize.width-5, textureSize.height),
})

ingotEditbox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)

ingotEditbox:registerScriptEditBoxHandler(function(strEventName, pSender)
	local edit = tolua.cast(pSender,"ccui.EditBox") 

	dump(strEventName, "editbox event")
	
	if strEventName == "began" then --编辑框开始编辑时调用
		
	elseif strEventName == "ended" then --编辑框完成时调用

	elseif strEventName == "return" then --编辑框return时调用
		local ingot = edit:getText()
		--dump(ingot, "ingot")
		local number = tonumber(ingot)
		number=number or 0
		MtradeOp:preparingItems(-1, number, 0)
		-- if ingot == "" then
			
		-- else
			
			
		-- 	local number = tonumber(ingot)
		-- 	-- if number and number>1000 then
		-- 	-- 	TIPS({ type = 1, str = game.getStrByKey("trade_ingot_limit_tips") })
		-- 	-- 	if lastMoney>0 then
		-- 	-- 		edit:setText(lastMoney)
		-- 	-- 	else
		-- 	-- 		edit:setText("")
		-- 	-- 	end
		-- 	-- else
		-- 	if number  then
		-- 		--if G_VIP_INFO.vipLevel <= 0 then
		-- 			--TIPS({ type = 1, str = "只有VIP才能交易给对方元宝" })
		-- 		--else
		-- 			local MRoleStruct = require "src/layers/role/RoleStruct"
		-- 			local own = MRoleStruct:getAttr(PLAYER_INGOT)
		-- 			if own >= number then
		-- 				--if number <= 1000 then
		-- 					MtradeOp:preparingItems(-1, number, 0)
		-- 					return
		-- 				--else
		-- 					--TIPS({ type = 1, str = game.getStrByKey("trade_ingot_limit_tips") })
		-- 				--end
		-- 			else
		-- 				TIPS({ type = 1, str = game.getStrByKey("noGold1") })
		-- 				if lastMoney>0 then
		-- 					edit:setText(lastMoney)
		-- 				else
		-- 					edit:setText("")
		-- 				end
		-- 			end
		-- 		--end
		-- 	else
		-- 		TIPS({ type = 1, str = game.getStrByKey("invalid_input_tips") })
		-- 		if lastMoney>0 then
		-- 			edit:setText(lastMoney)
		-- 		else
		-- 			edit:setText("")
		-- 		end
		-- 	end
		-- end
	
	elseif strEventName == "changed" then --编辑框内容改变时调用
		
	end
end)

-- 对方元宝扣税
local otherIngotRevenue = Mnode.createLabel(
{
	src = "0",
})

otherIngotRevenue:setVisible(false)

-- 自己元宝扣税
local myIngotRevenue = Mnode.createLabel(
{
	src = "0",
})

otherIngotRevenue:setVisible(false)

-- 计算扣税
local calculate_revenue = function(isMyself)
	local source = isMyself and root.mOneself or root.mOther
	local ingot = isMyself and (tonumber(ingotEditbox:getText()) or 0) or (tonumber(ingotLabel:getString()) or 0)
	local goods_num = 0
	for i, v in ipairs(source) do
		if v.goods ~= nil then
			goods_num = goods_num + 1
		end
	end
	return math.min(math.ceil(ingot*4/100) + 10*goods_num, 200)
end

-- 锁定按钮
local lockMenu, lockBtn
lockMenu, lockBtn = MMenuButton.new(
{
	src = {"res/component/button/50.png", "res/component/button/50_sel.png", "res/component/button/50_gray.png"},
	label = {
		src = game.getStrByKey("lock") .. game.getStrByKey("goods"),
		size = 20,
		color = MColor.lable_yellow,
	},
	--effect = "b2s",
	cb = function()
		if lockBtn.oneselfLocked then
			dump("已锁定")
		else
			local own_ingot = MRoleStruct:getAttr(PLAYER_INGOT)
			local trade_ingot = tonumber(ingotEditbox:getText()) or 0
			local revenue = calculate_revenue(true)
			
			-- 暂时屏蔽
			--[[
			if own_ingot < trade_ingot+revenue then
				TIPS({ type = 1, str = game.getStrByKey("noGold1") })
				return
			end
			--]]
			
			MtradeOp:lock(true)
		end
	end,
})

-- 确定按钮
local submitMenu, submitBtn
submitMenu, submitBtn = MMenuButton.new(
{
	src = {"res/component/button/50.png", "res/component/button/50_sel.png", "res/component/button/50_gray.png"},
	label = {
		src = game.getStrByKey("confirm") .. game.getStrByKey("trade"),
		size = 20,
		color = MColor.lable_yellow,
	},
	--effect = "b2s",
	cb = function()
		if submitBtn.submitted then
			dump("已提交")
			return
		end
		MtradeOp:submit(true)
	end,
})
------------------------------------------------------------------------------------
-- local up_bg = cc.Sprite:create("res/common/bg/bg33.png")
-- local up_bg_size = up_bg:getContentSize()
local up_bg_size = cc.size(408, 230)
local up_bg = createScale9Frame(
        root,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(4,307),
        up_bg_size,
        5
    )
-- Mnode.addChild(
-- {
-- 	parent = root,
-- 	child = up_bg,
-- 	anchor = cc.p(0.5, 1),
-- 	pos = cc.p(rootSize.width/2, rootSize.height),
-- })

local down_bg = cc.Sprite:create("res/common/bg/bg34.png")
local down_bg_size = down_bg:getContentSize()

Mnode.addChild(
{
	parent = root,
	child = down_bg,
	anchor = cc.p(0.5, 0),
	pos = cc.p(rootSize.width/2, 7),
})
------------------------------------------------------------------------------------
local buildSingleGoodsContainer = function(t, clickable)
	local iconBg = cc.Sprite:create("res/common/bg/itemBg.png")
	t.iconBg = iconBg
	
	if clickable then
		Mnode.listenTouchEvent(
		{
			node = iconBg,
			swallow = false,
			begin = function(touch, event)
				local node = event:getCurrentTarget()
				return Mnode.isTouchInNodeAABB(node, touch) --and not lockBtn.oneselfLocked
			end,
			
			ended = function(touch, event)
				local node = event:getCurrentTarget()
				if not Mnode.isTouchInNodeAABB(node, touch) then return end
				
				if not t.goods then
					dump("交易栏没有物品")
					return
				end
				assert(t.idx == t.goods.tradingBarPos)
				
				local num = t.goods.tradingBarNum
				if num > 1 then
					local MpropOp = require "src/config/propOp"
					local Mprop = require "src/layers/bag/prop"
					local protoId = t.goods.protoId
					local grid = t.goods.grid
					--------------
					local MChoose = require("src/functional/ChooseQuantity")
					MChoose.new(
					{
						title = game.getStrByKey("put"),
						config = { sp = 1, ep = num, cur = num },
						builder = function(box, parent)
							local cSize = parent:getContentSize()
							
							box:buildPropName(grid)
							
							local icon = Mprop.new(
							{
								grid = grid,
								cb = "tips",
								red_mask = true,
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
							MtradeOp:preparingItems(0, value, t.idx)
							removeFromParent(box)
						end,
						
						onValueChanged = function(box, value)
							box.icon:setOverlay(value)
						end,
					})
				else
					MtradeOp:preparingItems(0, 1, t.idx)
				end
			end
		})
	end
	
	return iconBg
end

local buildGoodsContainer = function(t, clickable)
	local nodes = {}
	
	for i = 1, 4 do
		local item = {}
		item.idx = i
		t[i] = item
		
		nodes[i] = buildSingleGoodsContainer(item, clickable)
	end
	
	return Mnode.combineNode(
	{
		nodes = nodes,
		margins = 15,
	})
end

local buildIngotTradePart = function(label, child)
	local parent = cc.Sprite:create("res/common/bg/inputBg2.png")
	local textureSize = parent:getContentSize()
	Mnode.addChild(
	{
		parent = parent,
		child = child,
		anchor = cc.p(0, 0.5),
		pos = cc.p(5, textureSize.height/2),
	})

	return Mnode.combineNode(
	{
		nodes = {
			Mnode.createLabel(
			{
				src = label,
				color = MColor.lable_black,
				size = 18,
			}),
			
			cc.Sprite:create("res/group/currency/5.png"),
			
			parent,
		},
		
		margins = 0,
	})
end

local tradingBarGoodsChanged = function(where, goods, isMyself)
	dump(goods, "goods")
	local item = where[goods.tradingBarPos]
	
	local icon = item.iconBg:getChildByTag(1)
	if icon then icon:removeFromParent() end
	
	if goods.tradingBarNum == 0 then
		item.goods = nil
		return
	end
	
	item.goods = goods
	local Mprop = require "src/layers/bag/prop"
	icon = Mprop.new(
	{
		grid = goods.grid,
		cb = not isMyself and "tips" or nil,
		red_mask = true,
		isOther = not isMyself,
		num = goods.tradingBarNum,
	})
	
	local iconSize = icon:getContentSize()
	
	Mnode.addChild(
	{
		parent = item.iconBg,
		child = icon,
		pos = cc.p(iconSize.width/2, iconSize.height/2),
		tag = 1,
	})
end
------------------------------------------------------------------------------------
-- 上面
-- 对方名字
Mnode.createLabel(
{
	src = params.roleName,
	parent = up_bg,
	size = 20,
	color = MColor.lable_yellow,
	anchor = cc.p(0, 0.5),
	pos = cc.p(20, 210),
})

-- 对方等级
Mnode.createLabel(
{
	src = game.getStrByKey("level") .. "：" .. (params.level or ""),
	parent = up_bg,
	size = 20,
	color = MColor.lable_yellow,
	anchor = cc.p(1, 0.5),
	pos = cc.p(up_bg_size.width-20, 210),
})

-- 对方元宝扣税
local n_oyk = buildIngotTradePart(game.getStrByKey("trade_ingot_revenue") .. ":", otherIngotRevenue)
n_oyk:setVisible(false)

local otherArea = Mnode.combineNode(
{
	nodes = {
		n_oyk,
		-- 对方交易元宝
		buildIngotTradePart(game.getStrByKey("trade_ingot") .. ":", ingotLabel),
		-- 对方物品栏
		buildGoodsContainer(root.mOther),
	},
	
	ori = "|",
	align = "l",
	margins = 10,
})

Mnode.addChild(
{
	parent = up_bg,
	child = otherArea,
	anchor = cc.p(0, 1),
	pos = cc.p(20, 177),
})
------------------------------------------------------------------------------------
-- 下面
-- 我的物品
Mnode.createLabel(
{
	src = game.getStrByKey("my") .. game.getStrByKey("goods"),
	parent = down_bg,
	size = 20,
	color = MColor.lable_yellow,
	anchor = cc.p(0, 0.5),
	pos = cc.p(20, 258),
})

-- 提示按钮
local rule_prompt = __createHelp(
{
	parent = down_bg,
	str = require("src/config/PromptOp"):content(10),
	pos = cc.p(360, 258),
})

rule_prompt:setScale(0.65)

--  我的元宝扣税
local n_myk = buildIngotTradePart(game.getStrByKey("trade_ingot_revenue") .. ":", myIngotRevenue)
n_myk:setVisible(false)

local oneselfArea = Mnode.combineNode(
{
	nodes = {
		
		n_myk,
		-- 我交易元宝
		buildIngotTradePart(game.getStrByKey("trade_ingot") .. ":", ingotEditbox),
		-- 我的物品栏
		buildGoodsContainer(root.mOneself, true),
	},
	
	ori = "|",
	align = "l",
	margins = 10,
})

Mnode.addChild(
{
	parent = down_bg,
	child = oneselfArea,
	anchor = cc.p(0, 1),
	pos = cc.p(20, 236),
})

-- 锁定按钮
Mnode.addChild(
{
	parent = down_bg,
	child = lockMenu,
	pos = cc.p(111, 45),
})

-- 提交按钮
Mnode.addChild(
{
	parent = down_bg,
	child = submitMenu,
	pos = cc.p(300, 45),
})
------------------------------------------------------------------------------------
-- 数据变化
oneselfCompleted = function(self)
	submitBtn.submitted = true
	submitBtn:setLabel(
	{
		src = game.getStrByKey("already") .. game.getStrByKey("confirm"),
		size = 20,
		color = MColor.gray,
	})
	submitBtn:setEnabled(false)
end

oneselfGoodsChanged = function(self, goods)
	if goods.tradingBarPos == -1 then
		dump(goods, "自己元宝变化")
		ingotEditbox:setText( tostring(goods.tradingBarNum) )
		lastMoney=goods.tradingBarNum
	else
		tradingBarGoodsChanged(self.mOneself, goods, true)
	end
	
	myIngotRevenue:setString(calculate_revenue(true))
end

otherGoodsChanged = function(self, goods)
	if goods.tradingBarPos == -1 then
		dump(goods, "对方元宝变化")
		ingotLabel:setString( tostring(goods.tradingBarNum) )
	else
		tradingBarGoodsChanged(self.mOther, goods)
	end
	
	otherIngotRevenue:setString(calculate_revenue(false))
end

local buildLockMask = function(area, isOneself)
	local areaSize = area:getContentSize()
	local margin = cc.size(10, 10)
	local maskSize = cc.size(areaSize.width + margin.width, areaSize.height + margin.height)
	
	local mask = Mnode.createNode(
	{
		cSize = maskSize,
	})
	
	Mnode.overlayNode(
	{
		parent = area,
		{
			node = mask,
		}
	})
	
	-- 锁定之后不可再拿出物品
	if isOneself then
		Mnode.listenTouchEvent(
		{
			node = mask,
			swallow = true,
			begin = function(touch, event)
				local node = event:getCurrentTarget()
				return Mnode.isTouchInNodeAABB(node, touch)
			end,
		})
	else
		Mnode.createSprite(
		{
			parent = mask,
			src = "res/component/flag/12.png",
			--anchor = cc.p(1, 0),
			pos = cc.p(350, 60),
		})
	end
	
	return mask
end

oneselfLocked = function(self)
	lockBtn.oneselfLocked = true
	lockBtn:setLabel(
	{
		src = game.getStrByKey("already") .. game.getStrByKey("lock"),
		size = 20,
		color = MColor.gray,
	})
	
	lockBtn:setEnabled(false)
	buildLockMask(oneselfArea, true)
end

otherLocked = function(self)
	buildLockMask(up_bg)
end
------------------------------------------------------------------------------------
return root
------------------------------------------------------------------------------------
end }