-- 魂师属性详情界面
-- Author: Qinsiyang
-- 
--
local QUIDialog = import(".QUIDialog")
local QUIDialogHeroAttrDetailInfo = class("QUIDialogHeroAttrDetailInfo", QUIDialog)

function QUIDialogHeroAttrDetailInfo:ctor(options)
	local ccbFile = "ccb/Dialog_Hero_AttrDetailInfo.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogHeroAttrDetailInfo.super.ctor(self, ccbFile, callBacks, options)
    self._popCurrentDialog = options.popCurrentDialog or true
	self._actor_prop = options.actor_prop
end

function QUIDialogHeroAttrDetailInfo:viewDidAppear()
	QUIDialogHeroAttrDetailInfo.super.viewDidAppear(self)
	self:setInfo()
end

function QUIDialogHeroAttrDetailInfo:viewWillDisappear()
	QUIDialogHeroAttrDetailInfo.super.viewWillDisappear(self)

end

function QUIDialogHeroAttrDetailInfo:setInfo()
    local prop = {hp_value = 1, 
    attack_value = 2, 
    hit_rating = 3, 
    dodge_rating = 4, 
    armor_physical = 5, 
    armor_magic = 6, 
    physical_penetration_value = 7, 
    magic_penetration_value = 8, 
    block_rating = 9, 
    wreck_rating = 10, 
    critical_rating = 11, 
    haste_rating = 12, 
    cri_reduce_rating = 13, 
    physical_damage_percent_attack = 14, 
    physical_damage_percent_beattack_reduce = 15, 
    magic_damage_percent_attack = 16, 
    magic_damage_percent_beattack_reduce = 17 ,
    magic_treat_percent_beattack = 18,
    magic_treat_percent_attack = 19}

    self._ccbOwner.frame_tf_title:setString("属性详情" or "")
    local map = remote.herosUtil:getUiPropMapByActorProp(prop,self._actor_prop)
    --QPrintTable(map)
    for i=1,20 do
        self._ccbOwner["tf_attr_name_"..i]:setVisible(false)
        self._ccbOwner["tf_attr_num_"..i]:setVisible(false)
    end

    for type_,prop_mod in pairs(map) do
        local index_ = prop[type_] 
		self._ccbOwner["tf_attr_name_"..index_]:setVisible(true)
        self._ccbOwner["tf_attr_num_"..index_]:setVisible(true)       
        self._ccbOwner["tf_attr_name_"..index_]:setString(prop_mod.name)
        self._ccbOwner["tf_attr_num_"..index_]:setString(prop_mod.value_str)
    end

end


function QUIDialogHeroAttrDetailInfo:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
	if event ~= nil then 
		app.sound:playSound("common_cancel")
	end
    self:popSelf()
    if self._backCallback then
    	self._backCallback()
    end
end



function QUIDialogHeroAttrDetailInfo:onTriggerBackHandler()
    self:playEffectOut()
    if self._backCallback then
    	self._backCallback()
    end
end

return QUIDialogHeroAttrDetailInfo