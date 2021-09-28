
local ActivityDailyCell = class("ActivityDailyCell",function ()
    return CCSItemCellBase:create("ui_layout/activity_ActivityDailyCell.json")
end)

local ActivityDailyCellItem = require("app.scenes.activity.ActivityDailyCellItem")
require("app.cfg.login_reward_info_1")
require("app.cfg.login_reward_info_vip")
local EffectNode = require "app.common.effects.EffectNode"

function ActivityDailyCell:ctor( ... )
    self._scrollView = self:getScrollViewByName("ScrollView_award")
    self._dayLabelBM = self:getLabelBMFontByName("BitmapLabel_day")
    self._space = 20
    self._func = nil
    self._roundEffect = nil
    self:registerBtnClickEvent("Button_qiandao",function()
        if self._func then
            self._func()
        end
        end)
end


function ActivityDailyCell:_addRoundEffect()
    self:_removeEffect()
    if self._roundEffect == nil then
        self._roundEffect = EffectNode.new("effect_around2", function(event, frameIndex)
                end)     
        self._roundEffect:setScale(1.3)
        self._roundEffect:play()
        local pt = self._roundEffect:getPositionInCCPoint()
        self._roundEffect:setPosition(ccp(pt.x, pt.y))
        self:getButtonByName("Button_qiandao"):addNode(self._roundEffect)
    end 
end

function ActivityDailyCell:_removeEffect()
    if self._roundEffect ~= nil then
        self._roundEffect:removeFromParentAndCleanup(true)
        self._roundEffect = nil
    end
end

function ActivityDailyCell:setSignFunc(func)
    self._func = func
end

function ActivityDailyCell:_getScrollViewHeight()
    if not self._scrollView then
        return 0
    end
    return self._scrollView:getContentSize().height
end

--[[
    --普通签到
    day_id :天数
]]
function ActivityDailyCell:updateNormal(loginReward)
    if not loginReward then
        return
    end
    if self._dayLabelBM then
        self._dayLabelBM:setText(tostring(loginReward.day))
    end
    if self._scrollView ~= nil then
        self._scrollView:removeAllChildrenWithCleanup(true)
    end
    local good = G_Goods.convert(loginReward.type_1,loginReward.value_1,loginReward.size_1)
    if not good then
        return
    end
    local widget = ActivityDailyCellItem.new(good,loginReward.vip_level)
    local width = widget:getContentSize().width
    local height = widget:getContentSize().height
    widget:setPosition(ccp(self._space,(self:_getScrollViewHeight()-height)/2))
    self._scrollView:addChild(widget)


    if loginReward.day <= G_Me.activityData.daily:getNormalDailyDay() then  --已领取
        self:showWidgetByName("Image_yilingqu",true)
        self:showWidgetByName("Button_qiandao",false)
        self:showWidgetByName("Image_weidacheng",false)
        self:getImageViewByName("Image_bg"):loadTexture("board_normal.png",UI_TEX_TYPE_PLIST)
        self:_removeEffect()
    elseif loginReward.day == (G_Me.activityData.daily:getNormalDailyDay() + 1) and G_Me.activityData.daily:isActivate() then   --可领取
        self:showWidgetByName("Image_yilingqu",false)
        self:showWidgetByName("Button_qiandao",true)
        self:showWidgetByName("Image_weidacheng",false)
        self:getImageViewByName("Image_bg"):loadTexture("board_red.png",UI_TEX_TYPE_PLIST)
        self:_addRoundEffect()
    else   --未达成或今日已领取
        self:showWidgetByName("Image_yilingqu",false)
        self:showWidgetByName("Button_qiandao",false)
        self:showWidgetByName("Image_weidacheng",true)
        self:getImageViewByName("Image_bg"):loadTexture("board_normal.png",UI_TEX_TYPE_PLIST)
        self:_removeEffect()
    end

end

--[[
    --豪华签到
    day_id :天数
]]
function ActivityDailyCell:updateVIP(loginReward)
    if not loginReward then
        return
    end
    if self._dayLabelBM then
        self._dayLabelBM:setText(tostring(loginReward.day))
    end
    if self._scrollView ~= nil then
        self._scrollView:removeAllChildrenWithCleanup(true)
    end
    
    for i=1,2 do
        local good = G_Goods.convert(loginReward["type_".. i],loginReward["value_"..i],loginReward["size_"..i])
        if good then
            local widget = ActivityDailyCellItem.new(good)
            local width = widget:getContentSize().width
            local height = widget:getContentSize().height
            widget:setPosition(ccp(self._space*i + (i-1)*width,(self:_getScrollViewHeight()-height)/2))
            self._scrollView:addChild(widget)
        else
        end
    end
    if loginReward.day <= G_Me.activityData.daily.total2 then  --已领取
            self:showWidgetByName("Image_yilingqu",true)
            self:showWidgetByName("Button_qiandao",false)
            self:showWidgetByName("Image_weidacheng",false)
            self:getImageViewByName("Image_bg"):loadTexture("board_normal.png",UI_TEX_TYPE_PLIST)
            self:_removeEffect()
    elseif loginReward.day == (G_Me.activityData.daily.total2+1) and G_Me.activityData.daily:isVipActivate() then   --可领取
        self:showWidgetByName("Image_yilingqu",false)
        self:showWidgetByName("Button_qiandao",true)
        self:showWidgetByName("Image_weidacheng",false)
        self:getImageViewByName("Image_bg"):loadTexture("board_red.png",UI_TEX_TYPE_PLIST)
        --判断今日是否已充值
        if G_Me.activityData.daily.cost then
            self:getButtonByName("Button_qiandao"):loadTextureNormal("btn-small-blue.png",UI_TEX_TYPE_PLIST)
            self:getImageViewByName("Image_25"):loadTexture(G_Path.getSmallBtnTxt("qiandao.png"))
            self:_addRoundEffect()
        else
            self:getButtonByName("Button_qiandao"):loadTextureNormal("btn-small-red.png",UI_TEX_TYPE_PLIST)
            self:getImageViewByName("Image_25"):loadTexture(G_Path.getSmallBtnTxt("chongzhi.png"))
            self:_removeEffect()
        end

    else   --未达成或今日已领取
        self:showWidgetByName("Image_yilingqu",false)
        self:showWidgetByName("Button_qiandao",false)
        self:showWidgetByName("Image_weidacheng",true)
        self:getImageViewByName("Image_bg"):loadTexture("board_normal.png",UI_TEX_TYPE_PLIST)
        self:_removeEffect()
    end
end


return ActivityDailyCell

