local MColor = require "src/config/FontColor"
local Mprop = require("src/layers/bag/prop")
--[[
1.如果点击翻牌，发送了接收礼品,设置客户端状态gitfGot为true,下一次点击小鬼游戏，提示已经领取奖励
2.如果重新登录,等房间消息，如果房间消息为激活状态,则隐藏掉npc，就不会再显示点击，进入房间与收到房间消息中间的延时状态，设置宝箱npc为不可见
]]
return { new = function(showRewardDelegate)
    local Mbaseboard = require "src/functional/baseboard"
    local root = Mbaseboard.new(
    {
	    src = "res/common/bg/bg27.png",
	    close = {
		    src = {"res/component/button/x2.png", "res/component/button/x2_sel.png"},
		    offset = { x = 0, y = 3 },
	    },
	    title = {
		    src = game.getStrByKey("mysteriousArea_goblin_game_title"),
		    size = 25,
		    color = MColor.lable_yellow,
		    offset = { y = -25 },
	    },
    })
    root:registerScriptHandler(function(event)
	    if event == "enter" then
            
	    elseif event == "exit" then
            g_msgHandlerInst:registerMsgHandler(MAZENODE_SC_REWARD_NOTIFY, nil)
	    end
    end)
    root:setPosition(cc.p(display.cx, display.cy))
    function xy_to_position(x, y)
        local basePosX, basePosY = - 55 + 12, 55 - 12
        return cc.p(basePosX + x * 122, basePosY + y * 122)
    end
    local tag_card_icon = 123
    ------------------------------------------------- 奖励 -------------------------------------------------
    local awards = {}
    local DropOp = require("src/config/DropAwardOp")
    local table_dropIdInfo = nil
    for k, v in pairs(require("src/config/fanxianfront")) do
        if v.q_map_id == 2307 then--小鬼地图
            table_dropIdInfo = require("json").decode("[" .. v.q_reward .. "]")
            break
        end
    end
    local dropId = nil
    for k, v in pairs(table_dropIdInfo) do
        if v[1] <= MRoleStruct:getAttr(ROLE_LEVEL) and MRoleStruct:getAttr(ROLE_LEVEL) <= v[2] then
            dropId = v[3]
            break
        end
    end
    local awardsConfig = DropOp:dropItem_ex(dropId)
    --------------------------------------------------------------------------------------------------
    for x = 1, 3, 1 do
        for y = 1, 3, 1 do
            local reward = awardsConfig[(x - 1) * 3 + y]
            local spr_card = cc.Sprite:create("res/layers/mysteriousArea/card_front.png")
            spr_card:setPosition(xy_to_position(x, y))
            spr_card:setTag(x * 10 + y)
            root:addChild(spr_card)
            local node_icon = Mprop.new(
	        {
                protoId = reward.q_item,
		        num = reward.q_count,
                isBind = tonumber(reward.bdlx or 0) == 1,
                strengthLv = reward.q_strength,
                showBind = true,
                cb = "tips",
	        })
            node_icon:setTag(tag_card_icon)
            node_icon:setPosition(getCenterPos(spr_card))
            spr_card:addChild(node_icon)
        end
    end
    local menu, btn
    menu, btn = require("src/component/button/MenuButton").new(
    {
	    parent = root,
	    pos = cc.p(root:getContentSize().width / 2, 34 + 42 - 19),
        src = {"res/component/button/50.png", "res/component/button/50_sel.png", "res/component/button/50_gray.png"},
	    label = {
		    src = game.getStrByKey("mysteriousArea_goblin_game_btn_title"),
		    size = 22,
		    color = MColor.lable_yellow,
	    },
	    cb = function(tag, node)
		    --全体翻过去
            local action_sequence = {}
            local action_spawn = {}
            for x = 1, 3, 1 do
                for y = 1, 3, 1 do
                    local action_card_flip_sequence = {}
                    local spr_card = root:getChildByTag(x * 10 + y)
                    table.insert(action_card_flip_sequence, cc.TargetedAction:create(
                        spr_card
                        , cc.RotateBy:create(0.2, cc.vec3(0, 90, 0))
                    ))
                    table.insert(action_card_flip_sequence, cc.CallFunc:create(function()
                        spr_card:setTexture("res/layers/mysteriousArea/card_back.png")
                        spr_card:removeChildByTag(tag_card_icon)
                    end))
                    table.insert(action_card_flip_sequence, cc.TargetedAction:create(
                        spr_card
                        , cc.RotateBy:create(0.2, cc.vec3(0, 90, 0))
                    ))
                    table.insert(action_spawn, cc.Sequence:create(action_card_flip_sequence))
                end
            end
            table.insert(action_sequence, cc.Spawn:create(action_spawn))
            --移动
            for round = 1, 2, 1 do
                for x = 1, 3, 1 do
                    for y = 1, 3, 1 do
                        local table_possibleX = (x == 1 and {2} or (x == 2 and {1, 3} or {2}))
                        local table_possibleY = (y == 1 and {2} or (y == 2 and {1, 3} or {2}))
                        local tag_target
                        if math.random(0, 1) == 0 then
                            tag_target = table_possibleX[math.random(1, table.size(table_possibleX))] * 10 + y
                        else
                            tag_target = x * 10 + table_possibleY[math.random(1, table.size(table_possibleY))]
                        end
                        local duration_swap = 0.1
                        local spr_card_target = root:getChildByTag(tag_target)
                        local spr_card_now = root:getChildByTag(x * 10 + y)
                        table.insert(action_sequence, cc.Spawn:create(
                            cc.TargetedAction:create(
                                spr_card_now
                                , cc.MoveTo:create(duration_swap, xy_to_position(math.floor(tag_target / 10), tag_target % 10))
                            )
                            , cc.TargetedAction:create(
                                spr_card_target
                                , cc.MoveTo:create(duration_swap, xy_to_position(x, y))
                            )
                        ))
                        spr_card_target:setTag(x * 10 + y)
                        spr_card_now:setTag(tag_target)
                    end
                end
            end
            table.insert(action_sequence, cc.CallFunc:create(function()
                createLabel(root, game.getStrByKey("mysteriousArea_goblin_game_desc"), cc.p(200, 62), nil, 22, nil, nil, nil, MColor.lable_black)
            end))
            --加入翻牌点击事件
            local bool_card_selected = false
            table.insert(action_sequence, cc.CallFunc:create(function()
                for x = 1, 3, 1 do
                    for y = 1, 3, 1 do
                        local spr_card = root:getChildByTag(x * 10 + y)
                        GetUIHelper():AddTouchEventListener(true, spr_card, nil, function()
                            if bool_card_selected then
                                return
                            end
                            g_msgHandlerInst:registerMsgHandler(MAZENODE_SC_REWARD_NOTIFY, function(buff)
                                local t = g_msgHandlerInst:convertBufferToTable("MazeNodeRewardNotify", buff)
                                local rewardInfo
                                for k, v in ipairs(t.info) do
                                    while true do
                                        if v.rewardId == 444444 then
                                            break
                                        end
                                        rewardInfo = v
                                        break
                                    end
                                end
                                local action_card_flip_sequence = {}
                                table.insert(action_card_flip_sequence, cc.TargetedAction:create(
                                    spr_card
                                    , cc.RotateBy:create(0.2, cc.vec3(0, 90, 0))
                                ))
                                table.insert(action_card_flip_sequence, cc.CallFunc:create(function()
                                    spr_card:setTexture("res/layers/mysteriousArea/card_front.png")
                                    local node_icon = Mprop.new(
	                                {
                                        protoId = rewardInfo.rewardId,
		                                num = rewardInfo.rewardCount,
                                        isBind = rewardInfo.bind,
                                        strengthLv = rewardInfo.strength,
                                        showBind = true,
                                        cb = "tips",
	                                })
                                    node_icon:setPosition(getCenterPos(spr_card))
                                    spr_card:addChild(node_icon)
                                end))
                                table.insert(action_card_flip_sequence, cc.TargetedAction:create(
                                    spr_card
                                    , cc.RotateBy:create(0.2, cc.vec3(0, 90, 0))
                                ))
                                table.insert(action_card_flip_sequence, cc.CallFunc:create(function()
                                    --显示领取界面
                                    showRewardDelegate:showReward(buff)
                                    root:removeFromParent()
                                end))
                                spr_card:runAction(cc.Sequence:create(action_card_flip_sequence))
                            end)
                            g_msgHandlerInst:sendNetDataByTable(MAZENODE_CS_GAMEPRIZE_REQ, "MazeNodeGamePrizeReq", {})
                            G_MYSTERIOUS_GOBLINGAME_STATE.giftGot = true
                            bool_card_selected = true
                        end)
                    end
                end
            end))
            root:runAction(cc.Sequence:create(action_sequence))
            node:removeFromParent()
	    end,
    })
    SwallowTouches(root)
    return root
end}