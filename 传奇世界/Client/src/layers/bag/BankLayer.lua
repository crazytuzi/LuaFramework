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
local bank = MPackManager:getPack(MPackStruct.eBank)
------------------------------------------------------------------------------------
local root = Mnode.createNode({ cSize = cc.size(960, 640) })
------------------------------------------------------------------------------------
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
	pos = cc.p(544, 288),
})
--------------
local right_bg =  createScale9Frame(
        root,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(550,38),
        cc.size(375, 500),
        4
    )
--cc.Sprite:create("res/common/bg/bg13.png")
local right_bg_size = right_bg:getContentSize()

-- Mnode.addChild(
-- {
-- 	parent = root,
-- 	child = right_bg,
-- 	anchor = cc.p(0, 0.5),
-- 	pos = cc.p(540, 288),
-- })

-- local right_bg = cc.Sprite:create("res/common/bg/bg7.png")
-- local right_bg_size = right_bg:getContentSize()

-- Mnode.addChild(
-- {
-- 	parent = right_bg,
-- 	child = right_bg,
-- 	pos = cc.p(right_bg_size.width/2, right_bg_size.height/2+2),
-- })
------------------------------------------------------------------------------------
-- 背包
local girdViewBag = MPackView.new(
{
	--bg = "res/common/68.png",
	packId = MPackStruct.eBag,
	layout = { row = 5, col = 5, },
	marginLR = 5,
	marginUD = 5,
	--mode = "access",
})

girdViewBag.onCellTouched = function(gv, cell, grid, icon)
	local idx = cell:getIdx()
	local grid = bag:getGirdByGirdId(idx+1)
	if not grid then return end
	
	local Mtips = require "src/layers/bag/tips"
	local actions = {}
	actions[#actions+1] = {
		label = "放入",
		cb = function(act_params)
			local MpropOp = require "src/config/propOp"
			local grid = act_params.grid
			local griId = MPackStruct.girdIdFromGird(grid)
			local protoId = MPackStruct.protoIdFromGird(grid)
			if MpropOp.accessible(protoId) then
				MPackManager:swapBetweenGird(MPackStruct.eBag, griId, MPackStruct.eBank)
			else
				TIPS({ type = 1  , str = game.getStrByKey("put_warehouse_tips") })
				dump("物品不能放入仓库")
			end
		end,
	}
	
	Mtips.new({ grid = grid, actions = actions })
	
end

girdViewBag:refresh()


Mnode.addChild(
{
	parent = left_bd,
	child = girdViewBag:getRootNode(),
	pos = cc.p(left_bd_size.width/2, left_bd_size.height/2),
})
------------------------------------------------------------------------------------
-- 仓库
local girdView = MPackView.new(
{
	--bg = "res/common/68.png",
	packId = MPackStruct.eBank,
	layout = { row = 4.3, col = 4, },
	marginLR = 5,
	marginUD = 5,
	--mode = "access",
})

girdView.onCellTouched = function(gv, cell, grid, icon)
	local idx = cell:getIdx()
	local grid = bank:getGirdByGirdId(idx+1)
	if not grid then return end
	
	local Mtips = require "src/layers/bag/tips"
	local actions = {}
	actions[#actions+1] = {
		label = "取出",
		cb = function(act_params)
			local grid = act_params.grid
			local griId = MPackStruct.girdIdFromGird(grid)
			MPackManager:swapBetweenGird(MPackStruct.eBank, griId, MPackStruct.eBag)
		end,
	}
	
	Mtips.new({ grid = grid, actions = actions })
end
-------------------------------------------
-- 仓库空间
local capacity = Mnode.createKVP(
{
	k = Mnode.createLabel{
		src = game.getStrByKey("bank")..game.getStrByKey("space").."：",
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

capacity:setValue( bank:numOfGirdUsed() .. "/" .. bank:numOfGirdOpened() )

Mnode.addChild(
{
	parent = right_bg,
	child = capacity,
	anchor = cc.p(0.5, 1.0),
	pos = cc.p(right_bg_size.width/2, right_bg_size.height-2),
})

girdView.onDataChanged = function(gv)
	capacity:setValue( bank:numOfGirdUsed() .. "/" .. bank:numOfGirdOpened() )
end

girdView:refresh()

Mnode.addChild(
{
	parent = right_bg,
	child = girdView:getRootNode(),
	anchor = cc.p(0.5, 1),
	pos = cc.p(right_bg_size.width/2, right_bg_size.height-25),
})


local botton_bg = Mnode.createSprite(
{
	src = "res/common/bg/bg1-2.png",
	parent = right_bg,
	anchor = cc.p(0.5, 0.0),
	pos = cc.p(right_bg_size.width/2, 2),
})
local botton_bg_size = botton_bg:getContentSize()
-- 仓库功能区域
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
	MPackManager:organize(MPackStruct.eBank)
	bagLastOrganizeTime=os.time()
	organizeCountDown(node)
end

local buildOperationArea = function()
	local opts = 
	{
		[1] = {
			name = game.getStrByKey("organize"),
			action = organizeOpt,
		},
	}
	
	local nodes = {}
	local organizeBtn=nil
	for i = 1, #opts do
		nodes[#nodes + 1],organizeBtn = MMenuButton.new(
		{
			src = {"res/component/button/50.png", "res/component/button/50_sel.png", "res/component/button/50_gray.png"},
			label = {
				src = opts[i].name,
				size = 25,
				color = MColor.lable_yellow,
			},
			nodefaultMus = true,
			tab = i,
			
			--effect = "b2s",
			
			cb = function(tag, node)
				opts[tag].action(node)
			end,
		})
	end
	--判断整理的CD过了没有
	if   os.time()-bagLastOrganizeTime>=0 and os.time()-bagLastOrganizeTime<10 and organizeBtn then
		organizeCountDown(organizeBtn,10-(os.time()-bagLastOrganizeTime))
	end
	return Mnode.combineNode(
	{
		nodes = nodes,
		margins = 30,
	})
	
end

Mnode.addChild(
{
	parent = botton_bg,
	child = buildOperationArea(),
	anchor = cc.p(0.5, 0.5),
	pos = cc.p(botton_bg_size.width/2, botton_bg_size.height/2-2),
})
------------------------------------------------------------------------------------
return root
end }