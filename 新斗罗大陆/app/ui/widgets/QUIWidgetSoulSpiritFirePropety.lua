-- @Author: liaoxianbo
-- @Date:   2020-03-01 15:53:22
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-03-07 19:26:10
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSoulSpiritFirePropety = class("QUIWidgetSoulSpiritFirePropety", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QActorProp = import("...models.QActorProp")
local QColorLabel = import("...utils.QColorLabel")

function QUIWidgetSoulSpiritFirePropety:ctor(options)
	local ccbFile = "ccb/Widget_SoulSpirit_SkillInfo.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIWidgetSoulSpiritFirePropety.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._ccbOwner.node_size:setContentSize(0, 0)
	self._ccbOwner.node_skill:setVisible(false)
    self._ccbOwner.node_master:setVisible(false)
end

function QUIWidgetSoulSpiritFirePropety:onEnter()
end

function QUIWidgetSoulSpiritFirePropety:onExit()
end

function QUIWidgetSoulSpiritFirePropety:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetSoulSpiritFirePropety:setSoulFireInfo(childPoint, masterConfig)
    if q.isEmpty(masterConfig) then return end
    
    self._ccbOwner.node_master:setVisible(true)

    local isActivate = false 

    if masterConfig.cell_id then
        isActivate = childPoint >= masterConfig.cell_id 
    end

    local descColor = isActivate and COLORS.j or COLORS.n
    local titleColor = isActivate and COLORS.k or COLORS.n

    self._ccbOwner.tf_master_title:setString("【"..masterConfig.cell_name.."】")
    self._ccbOwner.tf_master_title:setColor(titleColor)

    self._ccbOwner.tf_master_desc:setString(masterConfig.cell_desc or "")
    self._ccbOwner.tf_master_desc:setColor(descColor)

    -- local propDic  = remote.soulSpirit:getPropDicByConfig(masterConfig)
    -- for key, value in pairs(propDic) do
    --     if value > 0 then
    --         local name = QActorProp._field[key].uiName or QActorProp._field[key].name
    --         local isPercent = QActorProp._field[key].isPercent
    --         local str = q.getFilteredNumberToString(tonumber(value), isPercent, 2)  
    --         self._ccbOwner.tf_master_desc:setString("全队魂灵护佑"..name.."+"..str)
    --         self._ccbOwner.tf_master_desc:setColor(descColor)
    --         break
    --     end
    -- end
   
    local posY = self._ccbOwner.tf_master_desc:getPositionY() - self._ccbOwner.tf_master_desc:getContentSize().height - 20
    self._ccbOwner.node_line:setPositionY(posY)

    self._ccbOwner.node_size:setContentSize(516, -posY + 20)
end


return QUIWidgetSoulSpiritFirePropety
