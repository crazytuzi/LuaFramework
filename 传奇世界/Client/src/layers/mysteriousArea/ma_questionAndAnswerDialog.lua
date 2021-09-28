local MColor = require "src/config/FontColor"
local centerPosX = 201
return { new = function()
    local Mbaseboard = require "src/functional/baseboard"
    local root = Mbaseboard.new(
    {
	    src = "res/common/bg/bg27.png",
	    close = {
		    src = {"res/component/button/x2.png", "res/component/button/x2_sel.png"},
		    offset = { x = 0, y = 3 },
	    },
	    title = {
		    src = game.getStrByKey("mysteriousArea_questionAndAnswer_title"),
		    size = 25,
		    color = MColor.lable_yellow,
		    offset = { y = -25 },
	    },
    })
    root:setPosition(cc.p(display.cx, display.cy))
    createScale9Frame(
        root,
        "res/common/scalable/panel_outer_base.png",
        "res/common/scalable/panel_outer_frame_scale9.png",
        cc.p(16, 17),
        cc.size(370, 452),
        5
    )
    createSprite(root, "res/layers/mysteriousArea/questionBg.jpg", cc.p(centerPosX, 394))
    function refreshState()
        local tag_uiRefresh = 456
        while root:getChildByTag(tag_uiRefresh) do
            root:removeChildByTag(tag_uiRefresh)
        end
        --当问题index增加到6，代表已经成功答完5道题
        if G_MYSTERIOUS_QUESTION_STATE.currentQuestionIndex == 6 then
            createLabel(root, game.getStrByKey("mysteriousArea_questionAndAnswer_tip_finish"), cc.p(centerPosX, 400), cc.p(0.5, 0.5), 20, nil, nil, nil, MColor.black)
            createSprite(root, "res/layers/mysteriousArea/questionSucceedBg.jpg", cc.p(centerPosX, 300 - 133 + 1))
            local menu_box, btn_box
            menu_box, btn_box = require("src/component/button/MenuButton").new(
            {
	            parent = root,
	            pos = cc.p(centerPosX - 20, 210),
	            src = "res/fb/defense/boxCan1.png",
	            cb = function(tag, node)
                    --不能重复发送领奖
                    if G_MYSTERIOUS_QUESTION_STATE.questionRewardGot then
                        return
                    end
                    g_msgHandlerInst:sendNetDataByTable(MAZENODE_CS_GAMEPRIZE_REQ, "MazeNodeGamePrizeReq", {})
                    G_MYSTERIOUS_QUESTION_STATE.questionRewardGot = true
                    root:removeFromParent()
	            end,
            })
            btn_box:setScale(1.5)
            return
        end
        local table_currentQuestion = G_MYSTERIOUS_QUESTION_STATE.questionPool[G_MYSTERIOUS_QUESTION_STATE.currentQuestionIndex]
        local label_font_size = 20
        local line_height = 24
        local richTextSize_width = 300
        local richTextSize_height = 200
        local label_question = require("src/RichText").new(root, cc.p(centerPosX - 150, 400), cc.size(richTextSize_width, richTextSize_height), cc.p(0, 0.5), line_height, label_font_size, MColor.black)
        label_question:setAutoWidth()
        label_question:addText(table_currentQuestion.q_question)
        label_question:format()
        label_question:setTag(tag_uiRefresh)
        for k, v in ipairs(table_currentQuestion.answers) do
            local spr_btn = createScale9Sprite(root, "res/common/scalable/item.png", cc.p(centerPosX, 100 + 257 - 6 - 72 * k), cc.size(360, 70), cc.p(0.5, 0.5))
            spr_btn:setTag(tag_uiRefresh)
            local label_answer = createLabel(spr_btn, v, getCenterPos(spr_btn), cc.p(0.5, 0.5), 20, nil, nil, nil, MColor.lable_black)
            label_answer:setZOrder(2)
            GetUIHelper():AddTouchEventListener(true, spr_btn, nil, function()
                local tag_tip = 123
                if root:getChildByTag(tag_tip) then
                    return
                end
                createScale9Sprite(spr_btn, "res/common/scalable/item_sel.png", getCenterPos(spr_btn), cc.size(360, 70), cc.p(0.5, 0.5))
                --回答正确
                local duration_delayToRemoveTip = 1
                if k == table_currentQuestion.index_rightAnswer then
                    G_MYSTERIOUS_QUESTION_STATE.currentQuestionIndex = G_MYSTERIOUS_QUESTION_STATE.currentQuestionIndex + 1
                    local label_tip = createLabel(root, game.getStrByKey("mysteriousArea_questionAndAnswer_tip_right"), cc.p(centerPosX, 440), cc.p(0.5, 0.5), 20, nil, nil, nil, MColor.green)
                    label_tip:setTag(tag_tip)
                    label_tip:runAction(cc.Sequence:create(
                        cc.DelayTime:create(duration_delayToRemoveTip)
                        , cc.CallFunc:create(function()
                            root:removeChildByTag(tag_tip)
                            refreshState()
                        end)
                    ))
                    return
                end
                --回答错误
                local label_tip = createLabel(root, game.getStrByKey("mysteriousArea_questionAndAnswer_tip_wrong"), cc.p(centerPosX, 440), cc.p(0.5, 0.5), 20, nil, nil, nil, MColor.alarm_red)
                label_tip:setTag(tag_tip)
                label_tip:runAction(cc.Sequence:create(
                    cc.DelayTime:create(duration_delayToRemoveTip)
                    , cc.CallFunc:create(function()
                        root:removeChildByTag(tag_tip)
                        refreshState()
                    end)
                ))
            end)
        end
        local spr_bottomTip = createSprite(root, "res/layers/mysteriousArea/questionCountBg.png", cc.p(centerPosX, 200 - 164 + 2))
        spr_bottomTip:setTag(tag_uiRefresh)
        createLabel(spr_bottomTip, string.format(game.getStrByKey("mysteriousArea_questionAndAnswer_tip_questionCount"), G_MYSTERIOUS_QUESTION_STATE.currentQuestionIndex), getCenterPos(spr_bottomTip), cc.p(0.5, 0.5), 20, nil, nil, nil, MColor.lable_yellow)
    end
    refreshState()
    SwallowTouches(root)
    return root
end}