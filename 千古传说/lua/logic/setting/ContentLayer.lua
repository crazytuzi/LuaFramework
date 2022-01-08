--[[
]]
local ContentLayer = class("content", BaseLayer);


function ContentLayer:ctor(data)
    self.super.ctor(self,data);
    self:init("lua.uiconfig_mango_new.setting.content");
end

function ContentLayer:initUI(ui)
    self.super.initUI(self,ui);

    self.words      = TFDirector:getChildByPath(ui, 'words');
    self.button_switch      = TFDirector:getChildByPath(ui, 'Button');
end

function ContentLayer:loadDataById( id )
    self.pushInfo = SettingManager:getPushList(id);
    
    local config = SettingManager:getConfigPushById( id )

    self.words:setText(self.pushInfo.name)

    if config then
        self.button_switch:setTextureNormal("ui_new/setting/kai.png")
    else
        self.button_switch:setTextureNormal("ui_new/setting/guan.png")
    end
end

function ContentLayer:onShow()
    self.super.onShow(self)
end


function ContentLayer:removeUI()
    self.super.removeUI(self);
    self.words    = nil
    self.button_switch   = nil
    self.pushInfo   = nil
end


function ContentLayer.onBtnSwitchClick(sender)
    local self = sender.logic;
    local config = SettingManager:getConfigPushById( self.pushInfo.id )
    --changed by wuqi
    if self.pushInfo.id ~= SettingManager:getTequanId() then
        SettingManager:saveConfigPushById(self.pushInfo.id , not config)
    end

    if not config then
        self.button_switch:setTextureNormal("ui_new/setting/kai.png")
        if self.pushInfo.id ~= SettingManager:getTequanId() then
            self:startDailyNotification(""..self.pushInfo.id, self.pushInfo.desc, self.pushInfo.date,true)
        else
            SettingManager:sendVipTequanChange()
        end
    else
        self.button_switch:setTextureNormal("ui_new/setting/guan.png")
        if self.pushInfo.id ~= SettingManager:getTequanId() then
            self:startDailyNotification(""..self.pushInfo.id, self.pushInfo.desc, self.pushInfo.date,false)
        else
            SettingManager:sendVipTequanChange()
        end
    end
end

function ContentLayer:startDailyNotification(key, desc, eventdate , open)
    local nowTime   = os.time()
    local date    = os.date("*t", os.time())
    local nextDate  = getDateByString(eventdate)

    -- 把当前的事件置为每天的目标时间
    date.hour = nextDate.hour
    date.min  = nextDate.min
    date.sec  = nextDate.sec

    -- date.
    local nextTime  = os.time(date)
    -- 到达今日目的时间
    if nowTime >= nextTime then
        nextTime = 24 * 3600 + nextTime
    end
    if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID then
        if TFPushServer then
          if open then
              TFPushServer.setLocalTimer(nextTime, desc,key)
          else
              TFPushServer.cancelLocalTimer(nextTime, desc,key)
          end
        end
    end

end
--注册事件
function ContentLayer:registerEvents()
   self.super.registerEvents(self);
 
   self.button_switch.logic=self;
   self.button_switch:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onBtnSwitchClick),1);

end

function ContentLayer:removeEvents()

end

return ContentLayer;
