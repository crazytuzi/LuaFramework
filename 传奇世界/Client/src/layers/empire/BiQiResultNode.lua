local BiQiResultNode = class("BiQiResultNode", function() return cc.Node:create() end)

local path = "res/empire/"

function BiQiResultNode:ctor(data)
	local bg = createSprite(self, "res/common/bg/bg35.png", cc.p(0, 0), cc.p(0.5, 0.5))
	self.bg = bg

    createLabel(bg, game.getStrByKey("empire_biqi_result_title"), cc.p(bg:getContentSize().width/2, bg:getContentSize().height - 15), cc.p(0.5, 1), 22, true, nil, nil, MColor.lable_yellow)
    if data.isWin then
        createLabel(bg, game.getStrByKey("empire_biqi_result_win"), cc.p(30, 210), cc.p(0, 0), 20, true, nil, nil, MColor.lable_black, 1, 340)
    else
        createLabel(bg, game.getStrByKey("empire_biqi_result_lose"), cc.p(30, 210), cc.p(0, 0), 20, true, nil, nil, MColor.lable_black, 1, 340)
    end
	
    createLabel(bg, game.getStrByKey("empire_biqi_result_get"), cc.p(30, 170), cc.p(0, 0), 20, true, nil, nil, MColor.lable_yellow)

    local function closeFunc()
        removeFromParent(self)
    end
    local closeBtn = createMenuItem(bg, "res/component/button/50.png", cc.p(bg:getContentSize().width/2, 50), closeFunc)
    createLabel(closeBtn, game.getStrByKey("biqi_str11"), getCenterPos(closeBtn), cc.p(0.5, 0.5), 24, true)
    registerOutsideCloseFunc(bg, closeFunc, true, true)
    
    local drop = getConfigItemByKey("AreaFlag", "mapID", 6005)["winDrop"]
    if not data.isWin then
        drop = getConfigItemByKey("AreaFlag", "mapID", 6005)["loseDrop"]
    end

    local DropOp = require("src/config/DropAwardOp")
    local gdItem = DropOp:dropItem(tonumber(drop))

    for m,n in pairs(gdItem) do
        if tonumber(n.q_item) == 444444 then
            data.xp = tonumber(n.q_count)
        elseif tonumber(n.q_item) == 111111 then
            data.factionMoney = tonumber(n.q_count)
        end
    end

    if data.xp and data.xp > 0 then
        createLabel(bg, game.getStrByKey("biqi_str12")..numToFatString(data.xp), cc.p(35, 140), cc.p(0, 0), 20, true, nil, nil, MColor.green)
    end

    if data.factionMoney and data.factionMoney > 0 then
        createLabel(bg, game.getStrByKey("biqi_str13")..numToFatString(data.factionMoney), cc.p(230, 140), cc.p(0, 0), 20, true, nil, nil, MColor.green)
    end

    if data.xpPlus then
        createLabel(bg, game.getStrByKey("biqi_str14")..data.xpPlus .. "%", cc.p(35, 110), cc.p(0, 0), 20, true, nil, nil, MColor.green)
    end
    
    if data.minePlus then
        createLabel(bg, game.getStrByKey("biqi_str15")..data.minePlus .. "%", cc.p(230, 110), cc.p(0, 0), 20, true, nil, nil, MColor.green)
    end
end

return BiQiResultNode