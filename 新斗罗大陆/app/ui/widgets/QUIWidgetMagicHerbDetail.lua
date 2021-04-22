
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetMagicHerbDetail = class("QUIWidgetMagicHerbDetail", QUIWidget)

local QRichText = import("...utils.QRichText")
local QActorProp = import("...models.QActorProp")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QScrollContain = import("...ui.QScrollContain")

local QUIWidgetMagicHerbDetailSuitClient = import("..widgets.QUIWidgetMagicHerbDetailSuitClient")
local QUIWidgetMagicHerbEffectBox = import("..widgets.QUIWidgetMagicHerbEffectBox")

QUIWidgetMagicHerbDetail.EVENT_UNWEAR = "EVENT_UNWEAR"
QUIWidgetMagicHerbDetail.EVENT_WEAR = "EVENT_WEAR"

function QUIWidgetMagicHerbDetail:ctor( options )
    local ccbFile = "ccb/Widget_MagicHerb_Detail.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerUnwear", callback = handler(self, self._onTriggerUnwear)},
        {ccbCallbackName = "onTriggerWear", callback = handler(self, self._onTriggerWear)},
        {ccbCallbackName = "onTriggerLock", callback = handler(self, self._onTriggerLock)},
    }
    QUIWidgetMagicHerbDetail.super.ctor(self, ccbFile, callBacks, options)
    cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

    q.setButtonEnableShadow(self._ccbOwner.btn_unwear)
    q.setButtonEnableShadow(self._ccbOwner.btn_wear)
    q.setButtonEnableShadow(self._ccbOwner.btn_lock)
end

function QUIWidgetMagicHerbDetail:onEnter()
    QUIWidgetMagicHerbDetail.super.onEnter(self)
    self:initScrollView()
end

function QUIWidgetMagicHerbDetail:onExit()
    QUIWidgetMagicHerbDetail.super.onExit(self)
    if self._scrollContain ~= nil then
        self._scrollContain:disappear()
        self._scrollContain = nil
    end
end

function QUIWidgetMagicHerbDetail:initScrollView()
    self._scrollContain = QScrollContain.new({sheet = self._ccbOwner.sheet, sheet_layout = self._ccbOwner.sheet_layout, direction = QScrollContain.directionY , endRate = 0.1})
    self._ccbOwner.node_content:retain()
    self._ccbOwner.node_content:removeFromParent()
    self._scrollContain:addChild(self._ccbOwner.node_content)
    self._ccbOwner.node_content:release()
    -- local size = self._scrollContain:getContentSize()
    local size = self._ccbOwner.node_content:getContentSize()
    self._scrollContain:setContentSize(size.width, size.height)
end

function QUIWidgetMagicHerbDetail:setInfo(actorId, pos)
    self._actorId = actorId
    self._pos = pos
    if self._actorId then
        self._uiHeroModel = remote.herosUtil:getUIHeroByID(self._actorId)
    end
    if self._uiHeroModel then
        self._info = self._uiHeroModel:getMagicHerbWearedInfoByPos(self._pos)
    end


    if self._info then
        self._ccbOwner.node_icon:removeAllChildren()
        self._icon = QUIWidgetMagicHerbEffectBox.new()
        self._ccbOwner.node_icon:addChild(self._icon)
        self._icon:setInfo(self._info.sid)
        self._icon:hideName()


        local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(self._info.itemId)
        self._herbConfig = remote.magicHerb:getMagicHerbConfigByItemnId(self._info.itemId)

        local fontColor = UNITY_COLOR_LIGHT[EQUIPMENT_QUALITY[itemInfo.colour]]
        local name = itemInfo.name
        local magicHerbItemInfo = remote.magicHerb:getMaigcHerbItemBySid(self._info.sid)
        local  breedLevel = magicHerbItemInfo.breedLevel or 0
        if breedLevel == remote.magicHerb.BREED_LV_MAX then
            fontColor = UNITY_COLOR_LIGHT[EQUIPMENT_QUALITY[itemInfo.colour + 1]]
        elseif breedLevel > 0 then
            name = name.."+"..breedLevel
        end
         if self._herbConfig ~= nil then
            self._ccbOwner.tf_magicHerb_info:setString("LV."..self._info.level.." "..name.." 【"..self._herbConfig.type_name.."类】")
        end       
        self._ccbOwner.tf_magicHerb_info:setColor(fontColor)
        self._ccbOwner.tf_magicHerb_info = setShadowByFontColor(self._ccbOwner.tf_magicHerb_info, fontColor)
        self._startY = 55
        self:basePropHandler()
        self:refinePropHandler()
        self:breedPropHandler()
        if self._startY < 205 then
            self._startY = 205
        end

        self:_initSuitInfo()
        if self._scrollContain then
            local size = self._scrollContain:getContentSize()
            size.height = math.abs(self._startY)
            self._scrollContain:setContentSize(size.width, size.height)
        end

        self:checkRedTips()
        self:_updateLock()
    end
end

function QUIWidgetMagicHerbDetail:_updateLock()
    if self._uiHeroModel then
        self._info = self._uiHeroModel:getMagicHerbWearedInfoByPos(self._pos)
    end
    self._ccbOwner.btn_lock:setHighlighted(self._info.isLock)
    self._ccbOwner.btn_lock:setVisible(true)
end

function QUIWidgetMagicHerbDetail:checkRedTips()
    local magicHerbConfig = remote.magicHerb:getMagicHerbConfigByid(self._info.itemId)
    if q.isEmpty(magicHerbConfig) == false then
        local changeTips = self._uiHeroModel:checkHeroMagicHerbRedTipsByPos(self._pos)
        self._ccbOwner.sp_change_tips:setVisible(changeTips)
    end
end

function QUIWidgetMagicHerbDetail:basePropHandler()
    local gradeConfig = remote.magicHerb:getMagicHerbGradeConfigByIdAndGrade(self._herbConfig.id, self._info.grade)
    local uplevelConfig = remote.magicHerb:getMagicHerbUpLevelConfigByIdAndLevel(self._herbConfig.id, self._info.level)
    local upLevelExtraConfig = db:getMagicHerbEnhanceExtraConfigByBreedLvAndId(self._info.level, self._info.breedLevel)

    local propConfig = {}
    for key, value in pairs(gradeConfig) do
        key = tostring(key)
        if QActorProp._field[key] then
            if propConfig[key] then
                propConfig[key] = propConfig[key] + value
            else
                propConfig[key] = value
            end
        end
    end
    for key, value in pairs(uplevelConfig) do
        key = tostring(key)
        if QActorProp._field[key] then
            if propConfig[key] then
                propConfig[key] = propConfig[key] + value
            else
                propConfig[key] = value
            end
            if upLevelExtraConfig and upLevelExtraConfig[key] then
                propConfig[key] = propConfig[key] + upLevelExtraConfig[key] or 0
            end            
        end
    end

    local index_ = self:setMagicHerbPropInfo("attr",propConfig,2 , true)
    self._ccbOwner.node_attr:setPositionY(- self._startY )
    self._ccbOwner.node_attr:setVisible(index_ > 0 )

    self._startY =  self._startY + 30 * index_

end

function QUIWidgetMagicHerbDetail:refinePropHandler()
    local tfConfig = {}
    local propConfig = {}
    for _,v in ipairs(self._info.attributes) do
        local key = v.attribute
        if propConfig[key] then
            propConfig[key] = propConfig[key] + v.refineValue
        else
            propConfig[key] = v.refineValue
        end
    end

    local index_ = self:setMagicHerbPropInfo("refine",propConfig , 3 ,false)
    self._ccbOwner.node_refine:setPositionY(- self._startY )
    self._ccbOwner.node_refine:setVisible(index_ > 0 )

    self._startY =  self._startY + 30 * index_
end

function QUIWidgetMagicHerbDetail:breedPropHandler()
    local breedConfig = db:getMagicHerbBreedConfigByBreedLvAndId(self._herbConfig.id, self._info.breedLevel or 0)
    local propConfig = {}
    if breedConfig then
        for key, value in pairs(breedConfig or {}) do
            key = tostring(key)
            if QActorProp._field[key] then
                if propConfig[key] then
                    propConfig[key] = propConfig[key] + value
                else
                    propConfig[key] = value
                end
            end
        end
    end
    local index_ = self:setMagicHerbPropInfo("breed",propConfig , 2 , true)

    self._ccbOwner.node_breed:setPositionY(- self._startY )
    self._ccbOwner.node_breed:setVisible(index_ > 0 )

    self._startY =  self._startY + 30 * index_
end



function QUIWidgetMagicHerbDetail:setMagicHerbPropInfo(typeStr , config , max , ismerge)
    local propDesc = remote.magicHerb:setPropInfo(config ,true,true,ismerge)
    --  "tf_state_"..typeStr
    --  "node_richText_"..typeStr
    local index = 0
    for i,prop in ipairs(propDesc or {}) do
        --prop.name
        --prop.value
        self._ccbOwner["tf_"..typeStr.."_prop"..i]:setString(prop.name.."+"..prop.value)
        self._ccbOwner["tf_"..typeStr.."_prop"..i]:setVisible(true)
        index = i
    end
    for i = index + 1 , max do
        self._ccbOwner["tf_"..typeStr.."_prop"..i]:setVisible(false)
    end

    return index
end


function QUIWidgetMagicHerbDetail:_initSuitInfo()
    if self._suitClient == nil then
        self._suitClient = QUIWidgetMagicHerbDetailSuitClient.new()
        self._ccbOwner.node_suit_info:addChild(self._suitClient)
    end
    local magicHerbItemInfo = remote.magicHerb:getMaigcHerbItemBySid(self._info.sid)
    local totalHeight = self._suitClient:setInfo(self._info, magicHerbItemInfo, self._actorId)
    self._suitClient:setPositionY(- self._startY )
    self._startY = self._startY - totalHeight
end

function QUIWidgetMagicHerbDetail:_onTriggerUnwear()
    app.sound:playSound("common_small")
    self:dispatchEvent({name = QUIWidgetMagicHerbDetail.EVENT_UNWEAR})
end

function QUIWidgetMagicHerbDetail:_onTriggerWear()
    app.sound:playSound("common_small")
    self:dispatchEvent({name = QUIWidgetMagicHerbDetail.EVENT_WEAR})
end

function QUIWidgetMagicHerbDetail:_onTriggerLock()
    app.sound:playSound("common_small")
    remote.magicHerb:magicHerbLockRequest(self._info.sid, not self._info.isLock, function()
            if self._ccbView then
                self:_updateLock()
            end
        end)
end

return QUIWidgetMagicHerbDetail