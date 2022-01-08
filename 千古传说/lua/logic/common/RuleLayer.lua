--[[
/*code is far away from bug with the animal protecting
    *  ┏┓　　　┏┓
    *┏┛┻━━━┛┻┓
    *┃　　　　　　　┃ 　
    *┃　　　━　　　┃
    *┃　┳┛　┗┳　┃
    *┃　　　　　　　┃
    *┃　　　┻　　　┃
    *┃　　　　　　　┃
    *┗━┓　　　┏━┛
    *　　┃　　　┃神兽保佑
    *　　┃　　　┃代码无BUG！
    *　　┃　　　┗━━━┓
    *　　┃　　　　　　　┣┓
    *　　┃　　　　　　　┏┛
    *　　┗┓┓┏━┳┓┏┛
    *　　　┃┫┫　┃┫┫
    *　　　┗┻┛　┗┻┛ 
    *　　　
    */
]]
local RuleLayer = class("RuleLayer", BaseLayer)

function RuleLayer:ctor()
    self.super.ctor(self)
    self:init("lua.uiconfig_mango_new.common.RuleLayer")
end

function RuleLayer:initUI(ui)
    self.super.initUI(self,ui)
    self.closeBtn       = TFDirector:getChildByPath(ui, 'btn_close')
    self.scrollview     = TFDirector:getChildByPath(ui, 'scrollview')
    self.infoLayer     = TFDirector:getChildByPath(ui, 'infoLayer')
    self.scrollview:setBounceEnabled(false)
end


function RuleLayer:loadRuleId(ruleId)
    self.infoLayer:removeAllChildrenWithCleanup(true);
    local rule = GameRuleData:objectByID(ruleId)
    if rule == nil then
        print("没有该规则信息,ruleId = ",ruleId)
        return
    end
    local ruleInfoList = stringToNumberTable(rule.ruleInfo,"_")
    local length = #ruleInfoList
    local size = self.scrollview:getContentSize()
    local imgWidth = nil
    local high = 0
    for i=length,1,-1 do
        local ruleInfoId = ruleInfoList[i]
        if ruleInfoId ~= nil then
            local ruleInfo = RuleInfoData:objectByID(ruleInfoId)
            local img = TFImage:create(rule.tip_icon);
            img:setAnchorPoint(ccp(0, 1))
            self.infoLayer:addChild(img)
            imgWidth = imgWidth or img:getSize().width
            local label_width = size.width - imgWidth

            local textLabel = TFTextArea:create()
            textLabel:setFontSize(rule.fontSize)

            if ruleInfo.color and ruleInfo.color ~= '#FFFFFF' then
                textLabel:setColor(getColorByString(ruleInfo.color))
            end
            -- textLabel:setColor(ccc3(0,0,0))
            textLabel:setFontName(rule.fontName)
            textLabel:setAnchorPoint(ccp(0, 1))
            self.infoLayer:addChild(textLabel)

            textLabel:setText(ruleInfo.describe)
            textLabel:setTextAreaSize(CCSizeMake(label_width,0))

            local height = textLabel:getContentSize().height

            high = high + height + rule.line_height
            img:setPosition(ccp(0,high-rule.icon_offsetY))
            textLabel:setPosition(ccp(imgWidth,high))
        end
    end

    local temp = size.height - high
    self.infoLayer:setSize(CCSizeMake(size.width, high))
    high = math.max(size.height,high)
    if high > size.height then
        -- self.scrollview:setBounceEnabled(false)
        self.infoLayer:setPositionY(0)
    else
        self.infoLayer:setPositionY(temp)
        -- self.scrollview:setBounceEnabled(false)
    end
    self.scrollview:setInnerContainerSize(CCSizeMake(size.width, high))
end

function RuleLayer:registerEvents(ui)
    self.super.registerEvents(self)

    ADD_ALERT_CLOSE_LISTENER(self, self.closeBtn);
end

function RuleLayer:removeEvents()
    self.super.removeEvents(self)

end

function RuleLayer.closeBtnClickHandle(sender)
    AlertManager:close(AlertManager.TWEEN_1);
end




return RuleLayer