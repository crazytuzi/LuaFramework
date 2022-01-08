
local ZhenbashaiCell = class("ZhenbashaiCell", BaseLayer)

function ZhenbashaiCell:ctor()
    self.super.ctor(self)
    self:init("lua.uiconfig_mango_new.zhenbashai.ZhenbashaiCell3")
end

function ZhenbashaiCell:initUI(ui)
    self.super.initUI(self,ui)
    self.txt_message       = TFDirector:getChildByPath(ui, 'txt_message')
    self.txt_score       = TFDirector:getChildByPath(ui, 'txt_score')
end
function ZhenbashaiCell:setData(message)
    self.txt_message:setText(message.message)
    if message.score then
        self.txt_score:setVisible(true)
        self.txt_score:setText(message.score)
        self.txt_score:setPositionX(self.txt_message:getContentSize().width)
    else
        self.txt_score:setVisible(false)
    end
    -- self.txt_score
end

function ZhenbashaiCell:registerEvents(ui)
    self.super.registerEvents(self)
end

function ZhenbashaiCell:removeEvents()
    self.super.removeEvents(self)

end


return ZhenbashaiCell