local bagLastOrganizeTime=0
return { new = function()
------------------------------------------------------------------------------------
local Mbaseboard = require "src/functional/baseboard"
local MPackView = require "src/layers/bag/PackView"
local Mcurrency = require "src/functional/currency"
local MMenuButton = require "src/component/button/MenuButton"
------------------------------------------------------------------------------------
local res = "res/layers/bag/"
------------------------------------------------------------------------------------
local bag = MPackManager:getPack(MPackStruct.eBag)
------------------------------------------------------------------------------------
local root = Mnode.createNode({ cSize = cc.size(960, 640) })
local rootSize = root:getContentSize()
------------------------------------------------------------------------------------
local left_bg = createScale9Frame(
        root,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(30, 90),
        cc.size(110, 450),
        4
    )
-- cc.Sprite:create("res/common/bg/buttonBg3.png")
-- local left_bg_size = left_bg:getContentSize()

-- Mnode.addChild(
-- {hong
-- 	parent = root,
-- 	child = left_bg,
-- 	anchor = cc.p(1, 0.5),
-- 	pos = cc.p(140, 288),
-- })

-- local right_bg = cc.Sprite:create("res/common/bg/bg12.png")
-- local right_bg_size = right_bg:getContentSize()

-- Mnode.addChild(
-- {
-- 	parent = root,
-- 	child = right_bg,
-- 	anchor = cc.p(0, 0.5),
-- 	pos = cc.p(136, 288),
-- })


local bg = cc.Sprite:create("res/common/bg/bg6.png")
local bg_size = bg:getContentSize()

Mnode.addChild(
{
	parent = root,
	child = bg,
	anchor = cc.p(0, 0.5),
	pos = cc.p(148, 315),
})
------------------------------------------------------------------------------------
local refSize = TextureCache:addImage("res/common/21.png"):getContentSize()
local girdView = MPackView.new(
{
	--bg = "res/common/68.png",
	packId = MPackStruct.eBag,
	girdSize = cc.size(refSize.width, refSize.height-8),
	layout = { row = 4.2, col = 8, },
	marginLR = 0,
	marginUD = 5,
})

girdView.onCellTouched = function(gv, cell, grid)
	local protoId = MPackStruct.protoIdFromGird(grid)
	local MpropOp = require "src/config/propOp"
	AudioEnginer.playEffect(MpropOp.soundEffect(protoId), false)
	local Mtips = require "src/layers/bag/tips"
	Mtips.new(
	{
		packId = MPackStruct.eBag,
		grid = grid,
		--pos = cell:getParent():convertToWorldSpace( cc.p(cell:getPosition()) ),
		--contrast = true,
	})
end
------------------------------------------------------------------------------------
-- 货币显示

local bottom_bg = createScale9Frame(
        root,
        "res/common/scalable/panel_outer_base.png",
        "res/common/scalable/panel_outer_frame_scale9.png",
        cc.p(32, 39),
        cc.size(894, 41),
        4
    )

local bottom_bg_size = bottom_bg:getContentSize()


local buildCurrencyArea = function()
	local Mcurrency = require "src/functional/currency"
	return Mnode.combineNode(
			{
				nodes = {
					[1] = Mcurrency.new(
					{
						cate = PLAYER_INGOT,
						--bg = "res/common/19.png",
						--color = MColor.yellow,
					}),
					[2] = Mcurrency.new(
					{
						cate = PLAYER_BINDINGOT,
						--bg = "res/common/19.png",
						--color = MColor.yellow,
					}),
					
					[3] = Mcurrency.new(
					{
						cate = PLAYER_MONEY,
						--bg = "res/common/19.png",
						--color = MColor.yellow,
					})
				},
				
				margins = 0,
			})
end

Mnode.addChild(
{
	parent = bottom_bg,
	child = buildCurrencyArea(),
	anchor = cc.p(0, 0.5),
	pos = cc.p(12, bottom_bg_size.height/2),
})
-- ------------------------------------------------------------------------------------
-- 背包空间
local capacity = Mnode.createKVP(
{
	k = Mnode.createLabel{
		src = game.getStrByKey("bag")..game.getStrByKey("space").."：",
		size = 22,
		color = MColor.lable_yellow,
	},
	
	v = {
		src = "100/100",
		size = 22,
		--color = MColor.lable_yellow,
	},
	
	--ori = "|",
	
	margin = 5,
})

capacity:setValue( bag:numOfGirdUsed() .. "/" .. bag:numOfGirdOpened() )

Mnode.addChild(
{
	parent = bottom_bg,
	child = capacity,
	anchor = cc.p(1.0, 0.5),
	pos = cc.p(bottom_bg_size.width, bottom_bg_size.height/2),
})

girdView.onDataChanged = function(gv)
	capacity:setValue( bag:numOfGirdUsed() .. "/" .. bag:numOfGirdOpened() )
end

girdView:refreshWithTab(
{
	ori = "|",
	origin = "lto",
	offset = { x = -22, y = 6, },
})

Mnode.addChild(
{
	parent = bg,
	child = girdView:getRootNode(),
	anchor = cc.p(0.5, 1),
	pos = cc.p(bg_size.width/2, bg_size.height-5),
})
------------------------------------------------------------------------------------
-- 功能区域
local overlay = function(node, parent, child)
	getRunScene():addChild(child,200)
	-- local Manimation = require "src/young/animation"
	-- Manimation:transit(
	-- {
	-- 	node = child,
	-- 	sp = node:getParent():convertToWorldSpace(cc.p(node:getPosition())),
	-- 	ep = g_scrCenter,
	-- 	--trend = "-",
	-- 	zOrder = 200,
	-- 	curve = "-",
	-- 	swallow = true,
	-- })
end
local organizeCountDown=function ( node ,count)
	--root.organizeBtn
	local actTag = 1
	node:setEnabled(false)
	local delayCount =count or 10
	node.delayCount = delayCount
	node:setLabel(
	{
		src = game.getStrByKey("organize").."(" .. delayCount .. ")",
		size = 25,
		color = MColor.gray,
	})
	
	local DelayTime = cc.DelayTime:create(1)
	local CallFunc = cc.CallFunc:create(function(node)
		local delayCount = node.delayCount - 1
		--dump(delayCount, "delayCount")
		node.delayCount = delayCount
		if delayCount > 0 then
			node:setLabel(
			{
				src = game.getStrByKey("organize").."(" .. delayCount .. ")",
				size = 25,
				color = MColor.gray,
			})
		else
			node:setLabel(
			{
				src = game.getStrByKey("organize"),
				size = 25,
				color = MColor.lable_yellow,
			})
			
			node:stopActionByTag(actTag)
			node:setEnabled(true)
		end
	end)
	
	local Sequence = cc.Sequence:create(DelayTime, CallFunc)
	local action = cc.RepeatForever:create(Sequence)
	action:setTag(actTag)
	node:runAction(action)
end
-- 整理
local organizeOpt = function(node)
	AudioEnginer.playEffect("sounds/uiMusic/ui_bag.mp3",false)
	MPackManager:organize(MPackStruct.eBag)
	bagLastOrganizeTime=os.time()
	organizeCountDown(node)
end

-- 出售
local sellOpt = function(node)
	AudioEnginer.playEffect("sounds/uiMusic/ui_coin.mp3",false)
	overlay( node, root, require("src/layers/bag/SellView").new() )
end

-- 熔炼
local smelterOpt = function(node)
	AudioEnginer.playEffect("sounds/uiMusic/ui_click.mp3", false)
	overlay( node, root, require("src/layers/bag/SmelterView").new() )
end
local menu=nil
local organizeBtn=nil
if G_NFTRIGGER_NODE:isFuncOn(NF_FURNACE) then
    MMenuButton.new(
	{
        parent = root,
	    pos = cc.p(237, 131),
		src = {"res/component/button/49.png", "res/component/button/49_sel.png", "res/component/button/49_gray.png"},
		label = {
			src = game.getStrByKey("sell"),
			size = 25,
			color = MColor.lable_yellow,
		},
		tab = 1,
		nodefaultMus = true,
		cb = function(tag, node)
			sellOpt(node)
		end,
	})

    --用来做新手引导的按钮
    local tutoMenu
	tutoMenu = MMenuButton.new(
	{
        parent = root,
	    pos = cc.p(386, 131),
		src = {"res/component/button/49.png", "res/component/button/49_sel.png", "res/component/button/49_gray.png"},
		label = {
			src = game.getStrByKey("melting"),
			size = 25,
			color = MColor.lable_yellow,
		},
		tab = 2,
		nodefaultMus = true,
		cb = function(tag, node)
			smelterOpt(node)
		end,
	})
    G_TUTO_NODE:setTouchNode(tutoMenu,TOUCH_BAG_FURNACE)
    menu,organizeBtn= MMenuButton.new(
	{
        parent = root,
	    pos = cc.p(843, 131),
		src = {"res/component/button/49.png", "res/component/button/49_sel.png", "res/component/button/49_gray.png"},
		label = {
			src = game.getStrByKey("organize"),
			size = 25,
			color = MColor.lable_yellow,
		},
		tab = 3,
		nodefaultMus = true,
		cb = function(tag, node)
			organizeOpt(node)
		end,
	})
else
    MMenuButton.new(
	{
        parent = root,
	    pos = cc.p(237, 131),
		src = {"res/component/button/49.png", "res/component/button/49_sel.png", "res/component/button/49_gray.png"},
		label = {
			src = game.getStrByKey("sell"),
			size = 25,
			color = MColor.lable_yellow,
		},
		tab = 1,
		nodefaultMus = true,
		cb = function(tag, node)
			sellOpt(node)
		end,
	})
    menu,organizeBtn= MMenuButton.new(
	{
        parent = root,
	    pos = cc.p(386, 131),
		src = {"res/component/button/49.png", "res/component/button/49_sel.png", "res/component/button/49_gray.png"},
		label = {
			src = game.getStrByKey("organize"),
			size = 25,
			color = MColor.lable_yellow,
		},
		tab = 2,
		nodefaultMus = true,
		cb = function(tag, node)
			organizeOpt(node)
		end,
	})
end
--判断整理的CD过了没有
if os.time()-bagLastOrganizeTime>=0 and os.time()-bagLastOrganizeTime<10 and organizeBtn then
	organizeCountDown(organizeBtn,10-(os.time()-bagLastOrganizeTime))
end
------------------------------------------------------------------------------------
Mnode.addChild(
{
	parent = root,
	child = baseboard,
	anchor = cc.p(0, 0),
	pos = cc.p(17, 15),
})

G_TUTO_NODE:setTouchNode(function() return girdView:locateItem(20025) end,TOUCH_BAG_HPMP_STONE)
G_TUTO_NODE:setTouchNode(function() return girdView:locateItem(9007) end,TOUCH_BAG_AGAINST_REEL)
G_TUTO_NODE:setTouchNode(function() return girdView:locateItem(1129) end,TOUCH_BAG_HOE)
G_TUTO_NODE:setTouchNode(function() return girdView:locateItem(5020802) end,TOUCH_BAG_USE1)
G_TUTO_NODE:setTouchNode(function() return girdView:locateItem(5030802) end,TOUCH_BAG_USE2)
G_TUTO_NODE:setTouchNode(function() return girdView:locateItem(5010802) end,TOUCH_BAG_USE3)


-- print("node======",girdView:locateItem(2020501))
local firstClothesId = 2000501 + MRoleStruct:getAttr(ROLE_SCHOOL) *10000 + (MRoleStruct:getAttr(PLAYER_SEX) - 1) *1000
print("wwwwwwwwwwwwwwwwwwwwwwwid ==",firstClothesId)
G_TUTO_NODE:setTouchNode(function() return girdView:locateItem(firstClothesId) end,TOUCH_BAG_CLOTHES)
G_TUTO_NODE:setTouchNode(function() return girdView:locateItem(1511) or girdView:locateItem(1514) or girdView:locateItem(1519) end,TOUCH_BAG_BOOK)

-- G_TUTO_NODE:setTouchNode(function() return girdView:locateItem(2031501) end,TOUCH_BAG_CLOTHES2)
-- G_TUTO_NODE:setTouchNode(function() return girdView:locateItem(2020501) end,TOUCH_BAG_CLOTHES3)
-- G_TUTO_NODE:setTouchNode(function() return girdView:locateItem(2021501) end,TOUCH_BAG_CLOTHES4)
-- G_TUTO_NODE:setTouchNode(function() return girdView:locateItem(2010501) end,TOUCH_BAG_CLOTHES5)
-- G_TUTO_NODE:setTouchNode(function() return girdView:locateItem(2011501) end,TOUCH_BAG_CLOTHES6)

G_TUTO_NODE:setTouchNode(function() return girdView:locateItem(4010403) end,TOUCH_BAG_WASH_1)
G_TUTO_NODE:setTouchNode(function() return girdView:locateItem(4020403) end,TOUCH_BAG_WASH_2)
G_TUTO_NODE:setTouchNode(function() return girdView:locateItem(4030403) end,TOUCH_BAG_WASH_3)
G_TUTO_NODE:setTouchNode(function() return girdView:locateFirstLockItem() end,TOUCH_BAG_LOCK)
G_TUTO_NODE:setTouchNode(function() return girdView:locateItem(6200026) end,TOUCH_BAG_GIFT)
------------------------------------------------------------------------------------
root:registerScriptHandler(function(event)
	if event == "enter" then
		G_isBagLayer=true
		G_TUTO_NODE:setShowNode(root, SHOW_BAG)
		if G_MAINSCENE.tipLayer then
			G_MAINSCENE.tipLayer:removeAllChildren()
			require("src/layers/tuto/AutoConfigNode").showList = {}
			G_SETPOSTEMPE = {}
		end
	elseif event == "exit" then
		G_isBagLayer=false
		--G_TUTO_NODE:setShowNode(root, SHOW_MAIN)
		-- if G_MAINSCENE.tipLayer then
		-- 	G_MAINSCENE.tipLayer:removeAllChildren()
		-- 	require("src/layers/tuto/AutoConfigNode").showList = {}
		-- end
	end
end)
------------------------------------------------------------------------------------
--createReloadBtn("src/layers/consign/sell")
--createReloadBtn("src/layers/role/reloading")
--createReloadBtn("src/layers/bag/itemCompound")
--createReloadBtn("src/layers/random_versus/versus_end")
-- createReloadBtn("src/layers/equipment/equipMakeSelectTypeLayer")
return root
end }