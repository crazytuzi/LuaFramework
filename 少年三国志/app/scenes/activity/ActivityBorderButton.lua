--GM后台可配置活动按钮（带边框）

local ActivityBorderButton = class("ActivityBorderButton",function ()
    return CCSItemCellBase:create("ui_layout/activity_ActivityBorderButton.json")
end)

function ActivityBorderButton:ctor(activity)
    if activity == nil then
        return
    end
    self._clickFunc = nil
    self._activity = activity

    self._panelButton = self:getPanelByName("Panel_button")

    self._bgButton = self:getButtonByName("Button_item")
    local iconImage = self:getImageViewByName("Image_icon")
    
    if self._activity and self._activity.imageUrl then
        iconImage:loadTexture(self._activity.imageUrl)
    end

    local title = self:getLabelByName("Label_title")
    title:createStroke(Colors.strokeBrown,2)

    --这样做是因为按钮背景框和icon分离，为了让他们都有效果
    --self:registerBtnClickEvent("Button_item",function()
    --    self:_onBgButtonClick()
    --    end)
    self._bgButton:setEnabled(false)

    self:registerWidgetTouchEvent("Panel_button",handler(self, self._onClickPanel))

    
    
    title:setText(self._activity.titleUrl)

    --默认不显示
    self:showWidgetByName("Image_jijiangkaiqi",false)
    self:showWidgetByName("Image_tip",false)
    self:showWidgetByName("Image_new",false)


    self:registerWidgetClickEvent("Panel_button", handler(self, self._onBgButtonClick))
end

function ActivityBorderButton:_onClickPanel(widget, event)
    if event == TOUCH_EVENT_BEGAN then
        self._bgButton:setScale(1.05)
    elseif event == TOUCH_EVENT_ENDED or event == TOUCH_EVENT_CANCELED then
        self._bgButton:setScale(1)
    end

    --self:_onBgButtonClick()
end


function ActivityBorderButton:_onBgButtonClick( from )
    
   if self._clickFunc then
        self:_clickFunc()
    end

end

function ActivityBorderButton:setOnClickEvent(func)
    self._clickFunc = func
end

function ActivityBorderButton:getButtonName()
    return self._name
end 

--是否显示选中背景框图片
function ActivityBorderButton:showBackgroundImage(isShow)
    self:showWidgetByName("ImageView_bg",isShow)
end

--是否显示红点
function ActivityBorderButton:showTip(isShow)
    self:showWidgetByName("Image_tip",isShow)
end

--是否显示new字样
function ActivityBorderButton:showNew(isShow)
    self:showWidgetByName("Image_new",isShow)

    --如果显示了new字样 红点就不显示了
    if self:getWidgetByName("Image_new"):isVisible() then
        self:showWidgetByName("Image_tip",false)
    end

end

--是否显示开启文字
function ActivityBorderButton:showKaiqi(isShow)
    self:showWidgetByName("Image_jijiangkaiqi",isShow)
end

function ActivityBorderButton:getWidth()
    local width = self:getContentSize().width
    return width
end

return ActivityBorderButton
