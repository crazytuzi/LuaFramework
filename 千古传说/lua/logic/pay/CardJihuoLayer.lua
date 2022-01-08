--[[
******大小月卡*******

    -- by quanhuan
    -- 2015-10-15 15:19:43
    --月卡激活成功
]]
local CardJihuoLayer = class("CardJihuoLayer", BaseLayer);

function CardJihuoLayer:ctor(data)
    self.super.ctor(self,data);
    self:init("lua.uiconfig_mango_new.pay.CardJihuo");
end

function CardJihuoLayer:initUI(ui)
    self.super.initUI(self,ui)

    self.btn_ok = TFDirector:getChildByPath(ui, 'btn_ok')
    self.txt_panel = TFDirector:getChildByPath(ui, 'txt_panel')


    local richText = TFRichText:create(self.txt_panel:getSize())
    richText:setPosition(ccp(0,0))
    richText:setAnchorPoint(ccp(0.5, 0.5))
    self.txt_panel:removeAllChildren()
    self.txt_panel:addChild(richText)
    self.richText = richText
end

function CardJihuoLayer:onShow()
    self.super.onShow(self)
    self:refreshUI();
end

function CardJihuoLayer:refreshUI()

end

--注册事件
function CardJihuoLayer:registerEvents()
    self.super.registerEvents(self)

    self.btn_ok:addMEListener(TFWIDGET_CLICK,audioClickfun(function()
            AlertManager:close(AlertManager.TWEEN_NONE)
        end),1)
end

function CardJihuoLayer:removeEvents()
    self.super.removeEvents(self)

    self.btn_ok:removeMEListener(TFWIDGET_CLICK)
end

function CardJihuoLayer:removeUI()
   self.super.removeUI(self)
end

function CardJihuoLayer:setTextMsg(text)
    if self.richText and text then
        self.richText:setText(text)
    end
end

return CardJihuoLayer;
