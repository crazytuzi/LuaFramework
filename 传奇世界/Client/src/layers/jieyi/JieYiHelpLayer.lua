local JieYiHelpLayer = class("JieYiHelpLayer",function () return cc.Layer:create() end)

function JieYiHelpLayer:ctor()
    local bg = createSprite(self,"res/common/helpBg.png",cc.p(display.cx,display.cy), cc.p(0.5,0.5))
    local data = require("src/config/PromptOp")
    local title = data:record(64).q_Promptobject
    local titleLabel = createLabel(bg,title,cc.p(bg:getContentSize().width/2,bg:getContentSize().height-30),cc.p(0.5,0.5))
    titleLabel:setColor(MColor.brown)
	local str = data:content(64)
	local richText = require("src/RichText").new(bg, cc.p(15, 260), cc.size(500, 30), cc.p(0, 1), 22, 20, MColor.brown)
	richText:addText(str)
    richText:format()

    local scrollView = cc.ScrollView:create()
    scrollView:setViewSize(cc.size( bg:getContentSize().width,bg:getContentSize().height - 85 ))
    scrollView:setPosition( cc.p( 15 , 30 ) )
    scrollView:ignoreAnchorPointForPosition(true)

    richText:removeFromParent()
    scrollView:setContainer(richText)
    scrollView:updateInset()

    scrollView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL )
    scrollView:setClippingToBounds(true)
    scrollView:setBounceable(true)
    bg:addChild(scrollView)

    scrollView:setContentOffset( cc.p(0, -richText:getContentSize().height+scrollView:getViewSize().height ))

    local function closeFunc()
        self:removeFromParent()
    end
    registerOutsideCloseFunc(bg,closeFunc,true)
end

return JieYiHelpLayer