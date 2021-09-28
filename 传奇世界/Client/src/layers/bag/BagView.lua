return { new = function(params)
------------------------------------------------------------------------------------
local secondaryPass = require("src/layers/setting/SecondaryPassword")
if not secondaryPass.isSecPassChecked() then
	secondaryPass.inputPassword()
	return nil
end
------------------------------------------------------------------------------------
local Mbaseboard = require "src/functional/baseboard"
local Mcurrency = require "src/functional/currency"
------------------------------------------------------------------------------------
local res = "res/layers/bag/"
------------------------------------------------------------------------------------
local bag = MPackManager:getPack(MPackStruct.eBag)
------------------------------------------------------------------------------------
local params = params or {}
local target = params.target or game.getStrByKey("bag")
------------------------------------------------------------------------------------
local root = Mbaseboard.new(
{
	src = "res/common/2.jpg",
	quick = true,
})
local rootSize = root:getContentSize()
------------------------------------------------------------------------------------
-- 货币显示
-- local buildCurrencyArea = function()
-- 	local Mcurrency = require "src/functional/currency"
-- 	return Mnode.combineNode(
-- 	{
-- 		nodes = {
-- 			[1] = Mnode.combineNode(
-- 			{
-- 				nodes = {
-- 					[1] = Mcurrency.new(
-- 					{
-- 						cate = PLAYER_INGOT,
-- 						--bg = "res/common/19.png",
-- 						color = MColor.yellow,
-- 					}),
					
-- 					[2] = Mcurrency.new(
-- 					{
-- 						cate = PLAYER_BINDINGOT,
-- 						--bg = "res/common/19.png",
-- 						color = MColor.yellow,
-- 					})
-- 				},
				
-- 				margins = 5,
-- 			}),
			
-- 			[2] = Mnode.combineNode(
-- 			{
-- 				nodes = {
-- 					[1] = Mcurrency.new(
-- 					{
-- 						cate = PLAYER_MONEY,
-- 						--bg = "res/common/19.png",
-- 						color = MColor.yellow,
-- 					}),
-- 				},
				
-- 				margins = 5,
-- 			}),
-- 		},
		
-- 		ori = "|",
-- 		margins = 0,
-- 		align = "l",
-- 	})
-- end

-- Mnode.addChild(
-- {
-- 	parent = root,
-- 	child = buildCurrencyArea(),
-- 	anchor = cc.p(0, 0.5),
-- 	pos = cc.p(20, 605),
-- })
-- ------------------------------------------------------------------------------------
local overlay = function(node)
	local layer = root:getChildByTag(1)
	if layer then removeFromParent(layer) end
	
	if node then
		Mnode.addChild(
		{
			parent = root,
			child = node,
			pos = cc.p(rootSize.width/2, rootSize.height/2),
			tag = 1,
		})
	end
end

local tab_bag = game.getStrByKey("bag")
local tab_bank = game.getStrByKey("bank")

local config = {
	[tab_bag] = {
		action = function(node)
			overlay(require("src/layers/bag/BagLayer").new())
		end,
	},
	
	[tab_bank] = {
		action = function(node)
			overlay(require("src/layers/bag/BankLayer").new())
		end,
	},
}

local tabs = {}
tabs[#tabs+1] = tab_bag
tabs[#tabs+1] = bankOpenStatus() and tab_bank or nil

local TabControl = Mnode.createTabControl(
{
	src = {"res/common/TabControl/1.png", "res/common/TabControl/2.png"},
	size = 22,
	titles = tabs,
	margins = 2,
	ori = "|",
	align = "r",
	side_title = true,
	cb = function(node, tag)
		G_isBagLayer=tabs[tag] ==tab_bag
		config[tabs[tag]].action(node)
		local title_label = root:getChildByTag(12580)
		if title_label then title_label:setString(tabs[tag]) end
	end,
	selected = target,
})

Mnode.addChild(
{
	parent = root,
	child = TabControl,
	anchor = cc.p(0, 0.0),
	pos = cc.p(931, 460),
	zOrder = 100,
})
------------------------------------------------------------------------------------
G_TUTO_NODE:setTouchNode(root.closeBtn, TOUCH_BAG_CLOSE)
return root
end }