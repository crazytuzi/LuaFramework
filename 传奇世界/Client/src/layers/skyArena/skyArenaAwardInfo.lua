local skyArenaAwardInfo = class("skyArenaAwardInfo",function() return cc.Layer:create() end)

function skyArenaAwardInfo:ctor()
    local bg = createSprite(self,"res/common/bg/bg27.png", g_scrCenter)
	local contentBg = createScale9Sprite( bg , "res/common/scalable/panel_inside_scale9.png", getCenterPos(bg, 0, -20), cc.size( 376 , 449 ) , cc.p(0.5 , 0.5 ) )
	createLabel(bg, game.getStrByKey("sky_arena_winAward"), cc.p(201,503), nil, 24, true)
	local closeFunc = function()
		removeFromParent(self)
	end
	createTouchItem(bg,"res/component/button/x2.png",cc.p(bg:getContentSize().width - 35, bg:getContentSize().height - 25), closeFunc)
    self:addContent(contentBg)
    SwallowTouches(bg)
end

function skyArenaAwardInfo:addContent(contentBg)
    local rReward = require("src/config/P3V3DB").rankReward
    local saCommFunc = require("src/layers/skyArena/skyArenaCommFunc")
    rReward = saCommFunc.reOrderTableByKey(rReward)
    
    local node = cc.Node:create()
    local tmpHeight = 140 + 5
    local totalDataNum = #rReward
    for k,v in pairs(rReward) do
        local dataBg = createSprite(node, "res/common/table/cell26.png", cc.p(2, (totalDataNum-k)*tmpHeight), cc.p(0, 0))    -- k from 1 to n continuely
        local textContent = string.format(game.getStrByKey("sky_arena_leisheng"),k)
        createLabel(dataBg,textContent,cc.p(0,0),cc.p(0,0))
    end
    node:setContentSize(cc.size(360,tmpHeight*(#rReward)))

    local scrollView = cc.ScrollView:create()
    scrollView:setViewSize(cc.size( 360,430 ))
    scrollView:setPosition( cc.p( 5 , 20 ) )
    scrollView:ignoreAnchorPointForPosition(true)

    scrollView:setContainer(node)
    scrollView:updateInset()

    scrollView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL )
    scrollView:setClippingToBounds(true)
    scrollView:setBounceable(true)
    contentBg:addChild(scrollView)
    scrollView:setContentOffset( cc.p(0, -node:getContentSize().height+scrollView:getViewSize().height ))
        
end

return skyArenaAwardInfo