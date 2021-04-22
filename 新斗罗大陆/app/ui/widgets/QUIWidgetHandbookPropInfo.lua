--
-- Kumo.Wang
-- 新版魂师图鉴属性展示界面Cell
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetHandbookPropInfo = class("QUIWidgetHandbookPropInfo", QUIWidget)

local QRichText = import("...utils.QRichText") 
local QActorProp = import("...models.QActorProp")
local QColorLabel = import("...utils.QColorLabel")

function QUIWidgetHandbookPropInfo:ctor(options)
	local ccbFile = "ccb/Widget_Handbook_Prop.ccbi"
	local callBacks = {
		}
	QUIWidgetHandbookPropInfo.super.ctor(self,ccbFile,callBacks,options)

    self._ccbOwner.node_size:setContentSize(516, 100)
end

function QUIWidgetHandbookPropInfo:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetHandbookPropInfo:setInfo(info, showType, actorId, maxWidth)
	if not info or not showType then return end
    self._info = info
    self._showType = showType
    self._actorId = actorId
    self._maxWidth = maxWidth
    
    self._color = COLORS.j
    if self._showType == remote.handBook.TYPE_EPIC_PROP then
        self._ccbOwner.tf_title:setString("图鉴等级属性"..info.epic_level.."级")
        self._ccbOwner.tf_desc:setString("（累计图鉴点"..info.handbook_score_num.."解锁）")
        self._ccbOwner.tf_desc:setVisible(true)

        local curConfig = remote.handBook:getCurAndOldEpicPropConfig()
        local curLevel = curConfig.epic_level
        if curLevel >= info.epic_level then
            self._color = COLORS.j
            self._ccbOwner.tf_desc:setColor(COLORS.l)
        else
            self._color = COLORS.n
            self._ccbOwner.tf_desc:setColor(COLORS.m)
        end

        self:_showProp()
    elseif self._showType == remote.handBook.TYPE_ALL_PROP then
        if info.epic_level then
            self._ccbOwner.tf_title:setString("图鉴等级属性")
        else
            self._ccbOwner.tf_title:setString("图鉴"..(info.title or "").."属性")
        end
        self._ccbOwner.tf_desc:setVisible(false)

        self:_showProp()
    elseif self._showType == remote.handBook.TYPE_BT_PROP then
        self._ccbOwner.tf_title:setString("界限突破"..info.level.."级")
        self._ccbOwner.tf_desc:setVisible(false)

        local curHandbookBreakthroughLevel = remote.handBook:getHandbookBreakthroughLevelByActorID(self._actorId)
        if curHandbookBreakthroughLevel >= info.level then
            self._color = COLORS.j
        else
            self._color = COLORS.n
        end

        self:_showProp()
    end 

    if self._ccbOwner.tf_desc:isVisible() then
        self._ccbOwner.node_rtf_prop:setPositionY(-66)
    else
        self._ccbOwner.node_rtf_prop:setPositionY(self._ccbOwner.tf_desc:getPositionY() - 10)
    end
end

function QUIWidgetHandbookPropInfo:_showProp()
    self._ccbOwner.node_rtf_prop:removeAllChildren()
    local richTextTbl1 = {}
    local richTextTbl2 = {}
    local richTextEmptyTbl = {}
    local propFields = QActorProp:getPropFields()
    local index = 0
    local fontSize = 20
    for key, value in pairs(self._info) do
        if propFields[key] and value > 0 then
            index = index + 1
            local nameStr = propFields[key].handbookName or propFields[key].uiName or propFields[key].name
            if self._showType == remote.handBook.TYPE_EPIC_PROP or (self._showType == remote.handBook.TYPE_ALL_PROP and self._info.epic_level) then
                if remote.handBook.battlePropKey[key] then
                    nameStr = remote.handBook.battlePropKey[key].preName..nameStr
                end
            end
            local valueStr = q.getFilteredNumberToString(value, propFields[key].isPercent, 1)
            if index % 2 == 0 then
                if not q.isEmpty(richTextTbl2) then
                    table.insert(richTextTbl2, {oType = "wrap"})
                end
                table.insert(richTextTbl2, {oType = "font", content = nameStr.."+"..valueStr, size = fontSize, color = self._color})
            else
                if not q.isEmpty(richTextTbl1) then
                    table.insert(richTextTbl1, {oType = "wrap"})
                end
                table.insert(richTextTbl1, {oType = "font", content = nameStr.."+"..valueStr, size = fontSize, color = self._color})
            end
        end
    end

    if q.isEmpty(richTextTbl1) and q.isEmpty(richTextTbl2) then
        table.insert(richTextEmptyTbl, {oType = "font", content = "暂未激活属性", size = fontSize, color = COLORS.m})
    end
    
    if q.isEmpty(richTextEmptyTbl) then
        local maxHeight = 0
        local richTextNode1 = QRichText.new(nil, self._maxWidth, {autoCenter = false})
        richTextNode1:setString(richTextTbl1)
        richTextNode1:setAnchorPoint(ccp(0, 1))
        self._ccbOwner.node_rtf_prop:addChild(richTextNode1)
        if maxHeight < richTextNode1:getContentSize().height then
            maxHeight = richTextNode1:getContentSize().height
        end

        local richTextNode2 = QRichText.new(nil, nil, {autoCenter = false})
        richTextNode2:setString(richTextTbl2)
        richTextNode2:setAnchorPoint(ccp(0, 1))
        self._ccbOwner.node_rtf_prop:addChild(richTextNode2)
        if maxHeight < richTextNode2:getContentSize().height then
            maxHeight = richTextNode2:getContentSize().height
        end

        if richTextNode2:getContentSize().width < self._maxWidth then
            local offsetX = self._maxWidth - richTextNode2:getContentSize().width
            richTextNode1:setPositionX(-self._maxWidth + offsetX/2)
            richTextNode2:setPositionX(offsetX/2)
        end

        local totalHeight = math.abs(self._ccbOwner.node_rtf_prop:getPositionY()) + maxHeight
        self._ccbOwner.node_size:setContentSize(516, totalHeight + 10)
    else
        local richTextNode = QRichText.new(nil, nil, {autoCenter = true})
        richTextNode:setString(richTextEmptyTbl)
        richTextNode:setAnchorPoint(ccp(0.5, 1))
        self._ccbOwner.node_rtf_prop:addChild(richTextNode)

        local totalHeight = math.abs(self._ccbOwner.node_rtf_prop:getPositionY()) + richTextNode:getContentSize().height
        self._ccbOwner.node_size:setContentSize(516, totalHeight + 10)
    end
end

return QUIWidgetHandbookPropInfo