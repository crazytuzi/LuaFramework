--
-- Kumo.Wang
-- 時裝衣櫃属性展示Cell
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetFashionPropInfo = class("QUIWidgetFashionPropInfo", QUIWidget)
local QRichText = import("...utils.QRichText") 
local QActorProp = import("...models.QActorProp")
local QColorLabel = import("...utils.QColorLabel")

function QUIWidgetFashionPropInfo:ctor(options)
	local ccbFile = "ccb/Widget_Fashion_PropView.ccbi"
	local callBacks = {
		}
	QUIWidgetFashionPropInfo.super.ctor(self,ccbFile,callBacks,options)

	self._ccbOwner.node_size:setContentSize(520, 0)
end

function QUIWidgetFashionPropInfo:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetFashionPropInfo:setInfo(info)
	if not info then return end    

    local fontColor = COLORS.n
    local titleFontColor = COLORS.n
    local curConfig = remote.fashion:getCurActivedWardrobeConfigByQuality(info.quality)
    if curConfig and tonumber(info.condition) <= tonumber(curConfig.condition) then
        -- 未激活
        fontColor = COLORS.j
        titleFontColor = COLORS.k
    end

    -- self._ccbOwner.tf_title:setString("收集"..info.condition.."个")
    self._ccbOwner.tf_title:setString(info.name)
    self._ccbOwner.tf_title:setColor(titleFontColor)

    self._ccbOwner.node_rtf_prop:removeAllChildren()
    local rtf = QRichText.new(nil, 500, {autoCenter = true})
    rtf:setAnchorPoint(ccp(0.5, 1))
    self._ccbOwner.node_rtf_prop:addChild(rtf)

    local strText = info.desc or ""
    local tbl = string.split(strText, "\n")
    local textTbl = {}
    for _, v in ipairs(tbl) do
        if #textTbl ~= 0 then
            table.insert(textTbl, {oType = "wrap"})
        end
        table.insert(textTbl, {oType = "font", content = v, size = 20, color = fontColor})
    end

    if #textTbl ~= 0 then
        table.insert(textTbl, {oType = "wrap"})
        table.insert(textTbl, {oType = "font", content = "（收集"..info.condition.."个"..remote.fashion:getQualityCNameByQuality(info.quality).."皮肤后可激活）", size = 20, color = fontColor})
    end
    rtf:setString(textTbl)

    local totalHeight = math.abs(self._ccbOwner.node_rtf_prop:getPositionY()) + rtf:getContentSize().height + 25

    self._ccbOwner.node_size:setContentSize(520, totalHeight)
end

return QUIWidgetFashionPropInfo