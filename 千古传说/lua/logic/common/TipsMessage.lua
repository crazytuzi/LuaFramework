--[[
******操作确定层*******

    -- by king
    -- 2015/8/25
]]

local TipsMessage = class("TipsMessage", BaseLayer)

-- --CREATE_SCENE_FUN(TipsMessage)
CREATE_PANEL_FUN(TipsMessage)

function TipsMessage:ctor(data)
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.common.TxtTipLayer")
end



function TipsMessage:initUI(ui)
  self.super.initUI(self,ui)

  self.txt_title         = TFDirector:getChildByPath(ui, 'txt_title')
  self.Text             = TFDirector:getChildByPath(ui, 'Text')
  self.txt_time             = TFDirector:getChildByPath(ui, 'txt_time')

end

function TipsMessage:setText(title, content,end_time)
    self.txt_title:setText(title)
    self.Text:setText(content)
    if self.timer then
        TFDirector:removeTimer(self.timer)
        self.timer = nil
    end
    if end_time == nil then
        self.txt_time:setVisible(false)
    else
        self.txt_time:setVisible(true)
        self:showTime(end_time)
        local time = end_time
        self.timer = TFDirector:addTimer(1000,-1,nil,function ()
            time = time - 1
            if time <= 0 then
                time = 0
                TFDirector:removeTimer(self.timer)
                self.timer = nil
            end
            self:showTime(time)
        end)
    end
end

function TipsMessage:showTime(time )
    local days = math.floor(time/86400)
    local last = time - days*86400
    local hours = math.floor(last/3600)
    last = last - hours*3600
    local min = math.floor(last/60)
    last = last - min*60
    local sec = last
    local str = ""
    if days == 0 then
        --str = string.format("倒计时： %d时%d分%d秒",hours,min,sec)
        str = stringUtils.format(localizable.tipsMessage_lefttime1,hours,min,sec)
    else
        --str = string.format("倒计时： %d天%d时%d分%d秒",days,hours,min,sec)
        str = stringUtils.format(localizable.tipsMessage_lefttime2,days,hours,min,sec)
    end
    self.txt_time:setText(str)
end

function TipsMessage:removeUI()
  self.super.removeUI(self)
end


function TipsMessage.onOkClickHandle(sender)
  AlertManager:clearAllCache()
  CommonManager:closeConnection()
  MainPlayer:restart()
  AlertManager:changeSceneForce(SceneType.LOGIN)
end


function TipsMessage:registerEvents()
    self.super.registerEvents(self)

end
function TipsMessage:removeEvents()
    self.super.removeEvents(self)
    if self.timer then
        TFDirector:removeTimer(self.timer)
        self.timer = nil
    end
end


return TipsMessage
