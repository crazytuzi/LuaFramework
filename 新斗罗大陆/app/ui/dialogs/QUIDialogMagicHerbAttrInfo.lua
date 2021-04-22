-- 外骨属性详情界面
-- Author: Qinsiyang
-- 
--
local QUIDialog = import(".QUIDialog")
local QUIDialogMagicHerbAttrInfo = class("QUIDialogMagicHerbAttrInfo", QUIDialog)
local QActorProp = import("...models.QActorProp")

function QUIDialogMagicHerbAttrInfo:ctor(options)
	local ccbFile = "ccb/Dialog_MagicHerb_AttrInfo.ccbi"
	local callBacks = {
		-- {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogMagicHerbAttrInfo.super.ctor(self, ccbFile, callBacks, options)
    self._popCurrentDialog = options.popCurrentDialog or true
    self._info = options.magicHerbInfo
	self._subtitle = options.subtitle or "属性详情" 
end

function QUIDialogMagicHerbAttrInfo:viewDidAppear()
	QUIDialogMagicHerbAttrInfo.super.viewDidAppear(self)
	self:setInfo()
end

function QUIDialogMagicHerbAttrInfo:viewWillDisappear()
	QUIDialogMagicHerbAttrInfo.super.viewWillDisappear(self)

end

function QUIDialogMagicHerbAttrInfo:setInfo()
    self:basePropHandler()
    self:refinePropHandler()
    self:breedPropHandler()
end

function QUIDialogMagicHerbAttrInfo:basePropHandler()
    local gradeConfig = remote.magicHerb:getMagicHerbGradeConfigByIdAndGrade(self._info.itemId, self._info.grade)
    local uplevelConfig = remote.magicHerb:getMagicHerbUpLevelConfigByIdAndLevel(self._info.itemId, self._info.level)
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

    local index_ = self:setMagicHerbPropInfo("level",propConfig,2)

end

function QUIDialogMagicHerbAttrInfo:refinePropHandler()
    local tfConfig = {}
    local propConfig = {}
    local colorTbl = {}
    local additional_attributes = remote.magicHerb:getMagicHerbAdditionalAttributes(self._info)
    for _,v in ipairs(self._info.attributes) do
        local key = v.attribute

        if not colorTbl[key] then
            local colorStr = remote.magicHerb:getRefineValueColorAndMax(key, v.refineValue, additional_attributes)
            local color = COLORS[colorStr]
            colorTbl[key] = color
        end

        if propConfig[key] then
            propConfig[key] = propConfig[key] + v.refineValue
        else
            propConfig[key] = v.refineValue
        end
    end

    local index_ = self:setMagicHerbPropInfo("refine",propConfig , 3 , colorTbl)
end

function QUIDialogMagicHerbAttrInfo:breedPropHandler()
    local breedConfig = db:getMagicHerbBreedConfigByBreedLvAndId(self._info.itemId, self._info.breedLevel or 0)
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
    local index_ = self:setMagicHerbPropInfo("breed",propConfig , 2)

end

function QUIDialogMagicHerbAttrInfo:setMagicHerbPropInfo(typeStr , config , max , colorTbl)
    local propDesc = remote.magicHerb:setPropInfo(config ,true,true,false)
    --  "tf_state_"..typeStr
    --  "node_richText_"..typeStr
    local index = 0
    for i,prop in ipairs(propDesc or {}) do
        --prop.name
        --prop.value
        local tfNode = self._ccbOwner["tf_"..typeStr.."_attr_num_"..i]
        if tfNode then
            tfNode:setString(prop.name.."+"..prop.value)
            tfNode:setVisible(true)
            if colorTbl and colorTbl[prop.key] then
                tfNode:setColor(colorTbl[prop.key])
                tfNode = setShadowByFontColor(tfNode, colorTbl[prop.key])
            end
        end
        index = i
    end
    for i = index + 1 , max do
        local tfNode = self._ccbOwner["tf_"..typeStr.."_attr_num_"..i]
        if tfNode then
            tfNode:setVisible(false)
        end
    end
    return index
end

function QUIDialogMagicHerbAttrInfo:_backClickHandler()
    app.sound:playSound("common_cancel")
    if self._backCallback then
        self._backCallback()
    end    
    self:playEffectOut()
end

function QUIDialogMagicHerbAttrInfo:onTriggerBackHandler()
    self:playEffectOut()
    if self._backCallback then
    	self._backCallback()
    end
end

return QUIDialogMagicHerbAttrInfo