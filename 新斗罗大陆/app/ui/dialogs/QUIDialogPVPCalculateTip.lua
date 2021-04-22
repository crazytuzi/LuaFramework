-- @Author: xurui
-- @Date:   2020-03-03 16:10:10
-- @Last Modified by:   xurui
-- @Last Modified time: 2020-04-14 19:49:16
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogPVPCalculateTip = class("QUIDialogPVPCalculateTip", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QActorProp = import("...models.QActorProp")


function QUIDialogPVPCalculateTip:ctor(options)
	local ccbFile = "ccb/Dialog_pvp_calculate_tip.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogPVPCalculateTip.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options then
    	self._callBack = options.callBack
    end
    
    q.setButtonEnableShadow(self._ccbOwner.btn_close)
    self._ccbOwner.frame_tf_title:setString("帮  助")
end

function QUIDialogPVPCalculateTip:viewDidAppear()
	QUIDialogPVPCalculateTip.super.viewDidAppear(self)

	self:setProp()

	self:addBackEvent(true)
end

function QUIDialogPVPCalculateTip:viewWillDisappear()
  	QUIDialogPVPCalculateTip.super.viewWillDisappear(self)

	self:removeBackEvent()
end

function QUIDialogPVPCalculateTip:setProp()

    local calculateTotalPropFunc = function(heros)
        local heroList = {}
        local prop = {}
        prop.pvp_physical_damage_percent_attack = 0
        prop.pvp_physical_damage_percent_beattack_reduce = 0
        prop.pvp_magic_damage_percent_attack = 0
        prop.pvp_magic_damage_percent_beattack_reduce = 0
        if heros[1] and heros[1].id then
        	local heroInfo = clone(remote.herosUtil:getHeroByID(heros[1].id))
            heroInfo.glyphs = {}
            local actorProp = QActorProp.new(heroInfo)
            prop.pvp_physical_damage_percent_attack = prop.pvp_physical_damage_percent_attack  + actorProp:getPVPPhysicalAttackPercent() - actorProp:getArchaeologyPVPPhysicalAttackPercent()
            prop.pvp_physical_damage_percent_beattack_reduce = prop.pvp_physical_damage_percent_beattack_reduce + actorProp:getPVPPhysicalReducePercent() - actorProp:getArchaeologyPVPPhysicalReducePercent()
            prop.pvp_magic_damage_percent_attack = prop.pvp_magic_damage_percent_attack + actorProp:getPVPMagicAttackPercent() - actorProp:getArchaeologyPVPMagicAttackPercent()
            prop.pvp_magic_damage_percent_beattack_reduce = prop.pvp_magic_damage_percent_beattack_reduce + actorProp:getPVPMagicReducePercent() - actorProp:getArchaeologyPVPMagicReducePercent()
        end

        return prop
    end 

    local setStringFunc = function(prop, index, title)
        local value = prop.pvp_physical_damage_percent_attack or 0
        self._ccbOwner["tf_prop_"..index.."_1"]:setString(string.format("%sPVP物理加伤+%0.1f%%", title, value*100))
        value = prop.pvp_physical_damage_percent_beattack_reduce or 0
        self._ccbOwner["tf_prop_"..index.."_2"]:setString(string.format("%sPVP物理减伤+%0.1f%%", title, value*100))
        value = prop.pvp_magic_damage_percent_attack or 0
        self._ccbOwner["tf_prop_"..index.."_3"]:setString(string.format("%sPVP法术加伤+%0.1f%%", title, value*100))
        value = prop.pvp_magic_damage_percent_beattack_reduce or 0
        self._ccbOwner["tf_prop_"..index.."_4"]:setString(string.format("%sPVP法术减伤+%0.1f%%", title, value*100))
    end


	local heros, teamCount = remote.herosUtil:getMaxForceHeros()
    if heros then
        self._ccbOwner.tf_hero_count:setString(string.format("%s名", (teamCount or 0)))
    	local prop = calculateTotalPropFunc(heros)

        setStringFunc(prop, 1, "所有全队")

        local addHelpProp = {}
        for key, value in pairs(prop) do
            addHelpProp[key] = value + (value/4 * (teamCount - 4))
        end

        setStringFunc(addHelpProp, 2, "主力")
    end

    self._ccbOwner.tf_tip4_2:setPositionX(self._ccbOwner.tf_tip4_1:getPositionX() + self._ccbOwner.tf_tip4_1:getContentSize().width)
    self._ccbOwner.tf_tip4_3:setPositionX(self._ccbOwner.tf_tip4_1:getPositionX() + self._ccbOwner.tf_tip4_1:getContentSize().width+ self._ccbOwner.tf_tip4_2:getContentSize().width)


end

function QUIDialogPVPCalculateTip:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogPVPCalculateTip:_onTriggerClose(heros)
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogPVPCalculateTip:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogPVPCalculateTip