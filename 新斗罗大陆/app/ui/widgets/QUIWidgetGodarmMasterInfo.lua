-- @Author: liaoxianbo
-- @Date:   2019-12-28 15:39:15
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-01-07 17:11:07
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetGodarmMasterInfo = class("QUIWidgetGodarmMasterInfo", QUIWidget)
local QRichText = import("...utils.QRichText") 
local QActorProp = import("...models.QActorProp")
local QColorLabel = import("...utils.QColorLabel")

function QUIWidgetGodarmMasterInfo:ctor(options)
	local ccbFile = "ccb/Widget_Godarm_skill.ccbi"
	local callBacks = {
		}
	QUIWidgetGodarmMasterInfo.super.ctor(self,ccbFile,callBacks,options)

	self._ccbOwner.node_size:setContentSize(0, 0)
	self._ccbOwner.node_skill:setVisible(false)
    self._ccbOwner.node_talent:setVisible(false)
    self._ccbOwner.tf_soul_talent_desc:setVisible(false)
end

function QUIWidgetGodarmMasterInfo:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetGodarmMasterInfo:setMasterInfo(id, masterConfig)
    if not id or not masterConfig or next(masterConfig) == nil then return end
    if masterConfig.level == 0 then return end
    self._ccbOwner.node_talent:setVisible(true)

    local godarmInfo = remote.godarm:getGodarmById(id)
    local isActivate = false
    if godarmInfo and godarmInfo.level >= masterConfig.condition then
        isActivate = true
    end

    local descColor = isActivate and COLORS.j or COLORS.n
    local titleColor = isActivate and COLORS.k or COLORS.n
    local limitColor = isActivate and COLORS.J or COLORS.n

    self._ccbOwner.tf_talent_title:setString("【"..masterConfig.master_name.."】")
    self._ccbOwner.tf_talent_title:setColor(titleColor)

    local propDic  = remote.godarm:getPropDicByConfig(masterConfig)

    for key, value in pairs(propDic) do
        if value > 0 then
            local name = QActorProp._field[key].uiName or QActorProp._field[key].name
            local isPercent = QActorProp._field[key].isPercent
            local str = q.getFilteredNumberToString(tonumber(value), isPercent, 2)  
            self._ccbOwner.tf_talent_desc:setString(name.."+"..str)
            self._ccbOwner.tf_talent_desc:setColor(descColor)
            self._ccbOwner.tf_talent_limit:setString("（等级提升至"..masterConfig.condition.."级激活）")
            self._ccbOwner.tf_talent_limit:setColor(limitColor)
            break
        end
    end

    local posY = self._ccbOwner.tf_talent_desc:getPositionY() - self._ccbOwner.tf_talent_desc:getContentSize().height - 20

    self._ccbOwner.node_size:setContentSize(516, -posY + 20)
end

return QUIWidgetGodarmMasterInfo
