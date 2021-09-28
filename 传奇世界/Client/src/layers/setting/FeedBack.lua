
local FeedBackDialog = class("FeedBackDialog")

function FeedBackDialog.showDialog()

    local rScene = getRunScene()

    local bg = createSprite(rScene, "res/common/bg/bg31.png", cc.p(display.cx,display.cy),cc.p(0.5,0.5),299)
    createScale9Sprite(bg , "res/common/bg/inputBg9.png", cc.p(bg:getContentSize().width/2 - 1, 165), cc.size(362, 152) , cc.p( 0.5 , 0.5 ) )
 
    createLabel(bg, game.getStrByKey("feedback_title"), cc.p(bg:getContentSize().width/2, 260), cc.p(0.5, 0.5), 22, true)

    local editBox = createEditBox(bg, nil, cc.p(bg:getContentSize().width/2 - 1, 165), cc.size(358, 146), MColor.lable_yellow, 20)
    editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    editBox:setPlaceholderFontSize(20)
    editBox:setMaxLength(60)
    
    local function closeFunc()
        removeFromParent(bg)
    end

    local cancelBtn = createMenuItem(bg, "res/component/button/50.png", cc.p(bg:getContentSize().width/2-100, 45), closeFunc)
    createLabel(cancelBtn, game.getStrByKey("cancel"), getCenterPos(cancelBtn), cc.p(0.5, 0.5), 22, true)
    local function sureFunc()
        local str = editBox:getText()
        if str and #str > 0 then
            sdkFeedBack(game.getStrByKey("game_name"), editBox:getText())
            TIPS({type=1, str=game.getStrByKey("feedback_success")})
        end
        removeFromParent(bg)
    end

    local sureBtn = createMenuItem(bg, "res/component/button/50.png", cc.p(bg:getContentSize().width/2+100, 45), sureFunc)
    createLabel(sureBtn, game.getStrByKey("sure"), getCenterPos(sureBtn), cc.p(0.5, 0.5), 22, true)

    registerOutsideCloseFunc(bg, closeFunc, true)
end

return FeedBackDialog
