local EverydayNotice = class("EverydayNotice", BaseLayer);

CREATE_SCENE_FUN(EverydayNotice);
CREATE_PANEL_FUN(EverydayNotice);

function EverydayNotice:ctor(data)
    self.infos ={}
    self.infos = EverydayNoticeManager:getInfo()
    self.currNumber = 1
    self.count = #self.infos
    self.super.ctor(self,data);
    self:init("lua.uiconfig_mango_new.main.showFirstpay");
    self:InitData()
end

function EverydayNotice:initUI(ui)  
    self.super.initUI(self,ui);
    self.ui  = ui

    self.btn_close   = TFDirector:getChildByPath(ui, 'btn_close');
    self.img   = TFDirector:getChildByPath(ui, 'img');
    --img:setTexture("ui_new/guide/img2.png")
    self.button_close   = TFDirector:getChildByPath(ui, 'btn_close_1');
    -- self.button_close:setVisible(false
end

function EverydayNotice:InitData()
    local texture = string.format("ui_new/tips/img%d.png", self.infos[self.currNumber])
    local texture_jpg = string.format("ui_new/tips/img%d.jpg", self.infos[self.currNumber])
    if TFFileUtil:existFile(texture) then
        print("self.currNumber = ",self.currNumber," , index = ",self.infos[self.currNumber])
        self.img:setTexture(texture)
    elseif TFFileUtil:existFile(texture_jpg) then
        self.img:setTexture(texture_jpg)
    else

        if self.currNumber ~= self.count then        
            local blink = CCBlink:create(0.5,1)
            self.ui:runAction(blink)
            self.currNumber = self.currNumber+1;
            self:InitData()
        else
            AlertManager:close();
            SevenDaysManager:enterSevenDaysLayer()       
        end
        return
    end
end


function EverydayNotice:onShow()
    self.super.onShow(self)
end


function EverydayNotice:removeUI()
   self.super.removeUI(self);
end

function EverydayNotice.onCloseClickHandle(sender)
    local self = sender.logic
    if self.currNumber ~= self.count then        
        local blink = CCBlink:create(0.5,1)
        self.ui:runAction(blink)
        self.currNumber = self.currNumber+1;
        self:InitData()
    else               
        AlertManager:close();
        SevenDaysManager:enterSevenDaysLayer()       
     end
end

--注册事件
function EverydayNotice:registerEvents()
    self.super.registerEvents(self);
    --ADD_ALERT_CLOSE_LISTENER(self,self.button_close);
    self.btn_close:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onCloseClickHandle))
    self.button_close:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onCloseClickHandle))
    self.btn_close.logic = self
    self.button_close.logic = self
end

function EverydayNotice:removeEvents()

end
return EverydayNotice;