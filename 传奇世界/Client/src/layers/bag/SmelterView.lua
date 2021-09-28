return { new = function()
------------------------------------------------------------------------------------
local Mbaseboard = require "src/functional/baseboard"
local Mcurrency = require "src/functional/currency"
------------------------------------------------------------------------------------
local res = "res/layers/bag/"
------------------------------------------------------------------------------------
local bag = MPackManager:getPack(MPackStruct.eBag)
------------------------------------------------------------------------------------
local root = Mbaseboard.new(
{
    src = "res/common/bg/bg18.png",
	close = {
		src = {"res/component/button/x2.png", "res/component/button/x2_sel.png"},
		offset = { x = -8, y = 4 },
	},
	title = {
		src = game.getStrByKey("smelter_title"),
		size = 25,
		color = MColor.lable_yellow,
		offset = { y = -25 },
	}
})
root:setPosition(g_scrCenter)
local rootSize = root:getContentSize()
G_TUTO_NODE:setTouchNode(root.closeBtn, TOUCH_FURNACE_CLOSE)
local smelter = require("src/layers/bag/smelter").new()
smelter:setTag(require("src/config/CommDef").TAG_SMELTER_NODE)
root:addChild(smelter)
local bool_bankOpened = false
G_TUTO_NODE:setTouchNode(smelter:getChildByTag(require("src/config/CommDef").TAG_SMELTER_RONGLIAN_SHOP_MENU):getChildByTag(require("src/config/CommDef").TAG_SMELTER_RONGLIAN_SHOP_BTN), TOUCH_FURNACE_SHOP)
root:registerScriptHandler(function(event)
	--熔炼商城tab
    if
        event == "enter"
        and G_RED_DOT_DATA.bool_shallShowSmelterRedDot
        and G_MAINSCENE
        and G_MAINSCENE.base_node:getChildByTag(100 + require("src/config/CommDef").PARTIAL_TAG_SMELTER_DIALOG_TEMP)
        and not G_MAINSCENE.base_node:getChildByTag(100 + require("src/config/CommDef").PARTIAL_TAG_SMELTER_DIALOG_TEMP):getChildByTag(require("src/config/CommDef").TAG_SMELTER_NODE):getChildByTag(require("src/config/CommDef").TAG_SMELTER_RONGLIAN_SHOP_MENU):getChildByTag(require("src/config/CommDef").TAG_SMELTER_RONGLIAN_SHOP_BTN):getChildByTag(require("src/config/CommDef").TAG_RED_DOT)
    then
        local node_rongLianTab = G_MAINSCENE.base_node:getChildByTag(100 + require("src/config/CommDef").PARTIAL_TAG_SMELTER_DIALOG_TEMP):getChildByTag(require("src/config/CommDef").TAG_SMELTER_NODE):getChildByTag(require("src/config/CommDef").TAG_SMELTER_RONGLIAN_SHOP_MENU):getChildByTag(require("src/config/CommDef").TAG_SMELTER_RONGLIAN_SHOP_BTN)
        local spr_redDot = createSprite(
            node_rongLianTab
            , "res/component/flag/red.png"
            , cc.p(node_rongLianTab:getContentSize().width - 5, node_rongLianTab:getContentSize().height - 15)
        )
        spr_redDot:setTag(require("src/config/CommDef").TAG_RED_DOT)
    end
end)
------------------------------------------------------------------------------------
SwallowTouches(root)
return root
end}