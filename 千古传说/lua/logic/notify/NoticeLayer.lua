
local NoticeLayer = class("NoticeLayer", BaseLayer)

function NoticeLayer:ctor(content)
    self.super.ctor(self)
    self.content = content

    if content == nil then
        self.content = ""
    end

    self:init("lua.uiconfig_mango_new.notify.NoticeLayer")
end

function NoticeLayer:initUI(ui)
    self.super.initUI(self,ui)

    self.list_help   = TFDirector:getChildByPath(ui, 'list_help');
    self.list_help:setBounceEnabled(true);

    Public:bindScrollFun(self.list_help);


    self.btn_close        = TFDirector:getChildByPath(ui, 'btn_close');
    self.txt_content      = TFDirector:getChildByPath(ui, 'txt_content');


    self:draw()
end

function NoticeLayer:registerEvents(ui)
    self.super.registerEvents(self)
    ADD_ALERT_CLOSE_LISTENER(self,self.btn_close);
end

function NoticeLayer:removeUI()
    self.super.removeUI(self)
end

function NoticeLayer:draw()
    self.txt_content:setText(self.content)
    local contentSize = self.txt_content:getContentSize()
    local scorSize    = self.list_help:getInnerContainerSize()
    --如果显示内容超出了 则调整位置
    if contentSize.height > scorSize.height then
        self.txt_content:setPositionY(contentSize.height)
        self.list_help:setInnerContainerSize(contentSize)
    end
end


return NoticeLayer