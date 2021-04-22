--
-- Kumo.Wang
-- 時裝衣櫃属性总览界面Cell
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetAllFashionPropInfo = class("QUIWidgetAllFashionPropInfo", QUIWidget)

local QRichText = import("...utils.QRichText") 
local QActorProp = import("...models.QActorProp")

QUIWidgetAllFashionPropInfo.NO_TITLE_POS_Y = -48
QUIWidgetAllFashionPropInfo.HAVE_TITLE_POS_Y = -100

function QUIWidgetAllFashionPropInfo:ctor(options)
	local ccbFile = "ccb/Widget_Fashion_All_Prop_Info.ccbi"
	local callBacks = {
		}
	QUIWidgetAllFashionPropInfo.super.ctor(self,ccbFile,callBacks,options)

	self._ccbOwner.node_size:setContentSize(520, 100)
end

function QUIWidgetAllFashionPropInfo:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

-- self._data = {
--         {index = 1, typeName = "皮肤属性", isSecondTitle = true, isShowAllProp = true},
--         {index = 2, typeName = "宝录属性", isSecondTitle = false, isShowAllProp = true},
--         {index = 3, typeName = "绘卷属性", isSecondTitle = false, isShowAllProp = true},
--     }

-- {name = name, value = v, isPercent = propFields[k].isPercent}
function QUIWidgetAllFashionPropInfo:setInfo(info)
	if not info then return end    

    self._info = info

    self._ccbOwner.tf_no_porp:setVisible(true)
    self._ccbOwner.node_rtf_prop_left:removeAllChildren()
    self._ccbOwner.node_rtf_prop_right:removeAllChildren()
    self._ccbOwner.node_rtf_prop_left:setPositionY(info.isSecondTitle and self.HAVE_TITLE_POS_Y or self.NO_TITLE_POS_Y)
    self._ccbOwner.node_rtf_prop_right:setPositionY(info.isSecondTitle and self.HAVE_TITLE_POS_Y or self.NO_TITLE_POS_Y)
    self._ccbOwner.tf_no_porp:setPositionY(info.isSecondTitle and self.HAVE_TITLE_POS_Y or self.NO_TITLE_POS_Y)
    self._ccbOwner.tf_title:setString(info.typeName or "")

    self._ccbOwner.node_second_title:setVisible(info.isSecondTitle)
    
    local prop, num
    if info.index == 1 then
        -- 皮肤属性
        prop, num = self:_getAllSkinProp()
    elseif info.index == 2 then
        -- 宝录属性
        prop, num = self:_getAllFashionProp()
    elseif info.index == 3 then
        -- 绘卷属性
        prop, num = self:_getAllFashionCombinationProp()
    end
    self._ccbOwner.tf_second_title_num:setString(num or "0")

    local totalHeight = math.abs(self._ccbOwner.tf_no_porp:getPositionY()) + self._ccbOwner.tf_no_porp:getContentSize().height
    self._ccbOwner.node_size:setContentSize(520, totalHeight + 20)

    if q.isEmpty(prop) then return end
    self._ccbOwner.tf_no_porp:setVisible(false)

    local propList = {}
    for _, value in pairs(prop) do
        table.insert(propList, value)
    end

    table.sort(propList, function(a, b)
        if a.value == 0 and b.value ~= 0 then
            return false
        elseif a.value ~= 0 and b.value == 0 then
            return true
        else
            return a.index < b.index
        end
    end)

    local textTblLeft = {}
    local textTblRight = {}
    local isLeft = true
    for i, p in ipairs(propList) do
        local tbl = isLeft and textTblLeft or textTblRight
        if #tbl ~= 0 then
            table.insert(tbl, {oType = "wrap"})
        end
        local fontNameColor = p.value == 0 and COLORS.n or COLORS.k
        local fontNumColor = p.value == 0 and COLORS.n or COLORS.l

        table.insert(tbl, {oType = "font", content = p.name..":", size = 20, color = fontNameColor})
        table.insert(tbl, {oType = "font", content = "+"..(p.isPercent and ((p.value * 100).."%") or p.value), size = 20, color = fontNumColor})
        isLeft = not isLeft
    end

    -- 左
    local rtfLeft = QRichText.new(nil, 240, {autoCenter = false})
    rtfLeft:setAnchorPoint(ccp(0, 1))
    self._ccbOwner.node_rtf_prop_left:addChild(rtfLeft)
    rtfLeft:setString(textTblLeft)
    -- 右
    local rtfRight = QRichText.new(nil, 240, {autoCenter = false})
    rtfRight:setAnchorPoint(ccp(0, 1))
    self._ccbOwner.node_rtf_prop_right:addChild(rtfRight)
    rtfRight:setString(textTblRight)

    local leftHeight = math.abs(self._ccbOwner.node_rtf_prop_left:getPositionY()) + rtfLeft:getContentSize().height
    local rightHeight = math.abs(self._ccbOwner.node_rtf_prop_right:getPositionY()) + rtfRight:getContentSize().height
    local totalHeight = math.max(leftHeight, rightHeight) + 20
    self._ccbOwner.node_size:setContentSize(520, totalHeight)
end

function QUIWidgetAllFashionPropInfo:_addProp(prop, index, key, name, value, isPercent)
    if not prop[key] then
        prop[key] = {index = index, name = name, value = tonumber(value), isPercent = isPercent}
    else
        prop[key].value = prop[key].value + value
    end
end

function QUIWidgetAllFashionPropInfo:_getAllSkinProp()
    local _propFields = QActorProp:getPropFields()

    local prop = {}
    local activedCount = 0
    for _, quality in ipairs(remote.fashion.allQuality) do
        local skinConfigList = remote.fashion:getSkinConfigDataListByQuality(quality)
        for _, config in ipairs(skinConfigList) do
            if remote.fashion:checkSkinActivityBySkinId(config.skins_id) then
                activedCount = activedCount + 1
                for key, value in pairs(config) do
                    if _propFields[key] then
                        self:_addProp(prop, _propFields[key].index, key, _propFields[key].uiName or _propFields[key].name, value, _propFields[key].isPercent)
                    end
                end
            elseif self._info.isShowAllProp then
                for key, value in pairs(config) do
                    if _propFields[key] then
                        self:_addProp(prop, _propFields[key].index, key, _propFields[key].uiName or _propFields[key].name, 0, _propFields[key].isPercent)
                    end
                end
            end
        end
    end

    return prop, activedCount
end

function QUIWidgetAllFashionPropInfo:_getAllFashionProp()
    local _propFields = QActorProp:getPropFields()

    local prop = {}
    local activedCount = 0
    for _, quality in ipairs(remote.fashion.allQuality) do
        local curConfig, nextConfig = remote.fashion:getActivedWardrobeConfigAndNextConfigByQuality(quality)
        if curConfig then
            activedCount = activedCount + 1
            for key, value in pairs(curConfig) do
                if _propFields[key] then
                    self:_addProp(prop, _propFields[key].index, key, _propFields[key].archaeologyName or _propFields[key].uiName or _propFields[key].name, value, _propFields[key].isPercent)
                end
            end
        elseif self._info.isShowAllProp then
            for key, value in pairs(nextConfig) do
                if _propFields[key] then
                    self:_addProp(prop, _propFields[key].index, key, _propFields[key].archaeologyName or _propFields[key].uiName or _propFields[key].name, 0, _propFields[key].isPercent)
                end
            end
        end
    end

    return prop, activedCount
end

function QUIWidgetAllFashionPropInfo:_getAllFashionCombinationProp()
    local _propFields = QActorProp:getPropFields()

    local prop = {}
    local activedCount = 0
    local combinationList = remote.fashion:getCombinationDataList()
    for _, config in ipairs(combinationList) do
        local characterTbl = string.split(config.character_skins, ";")
        local allCharacterNameStr = ""
        if characterTbl and #characterTbl > 0 then
            for _, id in pairs(characterTbl) do
                local skinConfig = remote.fashion:getSkinConfigDataBySkinId(id)
                if skinConfig then
                    local characterConfig = db:getCharacterByID(skinConfig.character_id)
                    if characterConfig then
                        if characterConfig.name then
                            if allCharacterNameStr ~= "" then
                                allCharacterNameStr = allCharacterNameStr.."和"
                            end
                            allCharacterNameStr = allCharacterNameStr..characterConfig.name
                        end
                    end
                end
            end
        end

        if remote.fashion:checkActivedPictureId(config.id) then
            activedCount = activedCount + 1
            for key, value in pairs(config) do
                if _propFields[key] then
                    if key == "enter_rage" and allCharacterNameStr and allCharacterNameStr ~= "" then
                        self:_addProp(prop, _propFields[key].index, key, allCharacterNameStr..(_propFields[key].uiName or _propFields[key].name), value, _propFields[key].isPercent)
                    else
                        self:_addProp(prop, _propFields[key].index, key, "全队"..(_propFields[key].uiName or _propFields[key].name), value, _propFields[key].isPercent)
                    end
                end
            end
        elseif self._info.isShowAllProp then
            for key, value in pairs(config) do
                if _propFields[key] then
                    if key == "enter_rage" and allCharacterNameStr and allCharacterNameStr ~= "" then
                        self:_addProp(prop, _propFields[key].index, key, allCharacterNameStr..(_propFields[key].uiName or _propFields[key].name), 0, _propFields[key].isPercent)
                    else
                        self:_addProp(prop, _propFields[key].index, key, "全队"..(_propFields[key].uiName or _propFields[key].name), 0, _propFields[key].isPercent)
                    end
                end
            end
        end
    end

    return prop, activedCount
end

return QUIWidgetAllFashionPropInfo