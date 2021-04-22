

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetTeamSoulSpiritInfo = class("QUIWidgetTeamSoulSpiritInfo", QUIWidget)
local QUIWidgetTeamSoulSpiritSkillInfo = import("..widgets.QUIWidgetTeamSoulSpiritSkillInfo")
local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QColorLabel = import("...utils.QColorLabel")
local QRichText = import("...utils.QRichText")

function QUIWidgetTeamSoulSpiritInfo:ctor(options)
	local ccbFile = "ccb/Widget_SoulSpirit_add_buff.ccbi"
    local callBacks = {
    }
    QUIWidgetTeamSoulSpiritInfo.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	self._totalHeight = 0
end

function QUIWidgetTeamSoulSpiritInfo:setInfo(index,soulSpiritId, allProp , isCollegeTeam , chapterId , isMockBattle)
    local soulSpirit = nil
    if isCollegeTeam then
        soulSpirit = remote.collegetrain:getSpritInfoById(chapterId,soulSpiritId)
    elseif isMockBattle then
        soulSpirit = remote.mockbattle:getCardUiInfoById(soulSpiritId)
    else
        soulSpirit = remote.soulSpirit:getMySoulSpiritInfoById(soulSpiritId)           
    end

    local characterConfig = db:getCharacterByID(soulSpiritId)

	local mainRate = remote.soulSpirit:getFightAddCoefficientByData(soulSpirit)
	local rateStr = q.getFilteredNumberToString(tonumber(mainRate), true, 2)
    
    self._ccbOwner.sp_line:setVisible(index > 1)
    self._ccbOwner.tf_title_prop:setString(characterConfig.name.."：")


	self._ccbOwner.tf_name_1:setString("生命")
    -- self._ccbOwner.tf_value_1:setString("+"..math.floor(prop.hp*mainRate))
	self._ccbOwner.tf_value_1:setString("无敌")
	self._ccbOwner.tf_name_2:setString("攻击")
	self._ccbOwner.tf_value_2:setString("+"..math.floor(allProp.attack*mainRate))
	self._ccbOwner.tf_name_3:setString("命中")
	self._ccbOwner.tf_value_3:setString("+"..math.floor(allProp.hit*mainRate))
	self._ccbOwner.tf_name_4:setString("闪避")
	self._ccbOwner.tf_value_4:setString("+"..math.floor(allProp.dodge*mainRate))
    self._ccbOwner.tf_name_5:setString("物理防御")
    self._ccbOwner.tf_value_5:setString("+"..math.floor(allProp.physical_armor*mainRate))
    self._ccbOwner.tf_name_6:setString("法术防御")
    self._ccbOwner.tf_value_6:setString("+"..math.floor(allProp.magic_armor*mainRate))
    self._ccbOwner.tf_name_7:setString("物理穿透")
    self._ccbOwner.tf_value_7:setString("+"..math.floor(allProp.physical_penetration*mainRate))
    self._ccbOwner.tf_name_8:setString("法术穿透")
    self._ccbOwner.tf_value_8:setString("+"..math.floor(allProp.magic_penetration*mainRate))
	self._ccbOwner.tf_name_9:setString("格挡")
	self._ccbOwner.tf_value_9:setString("+"..math.floor(allProp.block*mainRate))
	self._ccbOwner.tf_name_10:setString("暴击")
	self._ccbOwner.tf_value_10:setString("+"..math.floor(allProp.crit*mainRate))
	self._ccbOwner.tf_name_11:setString("攻速")
	self._ccbOwner.tf_value_11:setString("+"..math.floor(allProp.haste*mainRate))
    self._ccbOwner.tf_name_12:setString("抗暴")
    self._ccbOwner.tf_value_12:setString("+"..math.floor(allProp.crit_reduce_rating*mainRate))
    self._ccbOwner.tf_name_13:setString("物理加伤")
    self._ccbOwner.tf_value_13:setString("+"..string.format("%.1f%%", allProp.physical_damage_percent_attack*mainRate*100))
    self._ccbOwner.tf_name_14:setString("物理减伤")
    self._ccbOwner.tf_value_14:setString("+"..string.format("%.1f%%", allProp.physical_damage_percent_beattack_reduce*mainRate*100))
    self._ccbOwner.tf_name_15:setString("法术加伤")
    self._ccbOwner.tf_value_15:setString("+"..string.format("%.1f%%", allProp.magic_damage_percent_attack*mainRate*100))
    self._ccbOwner.tf_name_16:setString("法术减伤")
    self._ccbOwner.tf_value_16:setString("+"..string.format("%.1f%%", allProp.magic_damage_percent_beattack_reduce*mainRate*100))	
	local tipDesc1 = "魂灵战斗属性=上阵主力英雄属性x"..rateStr
	local tipDesc2 = "魂灵战斗属性影响魂灵的普攻和魂技，魂灵技能只有上阵时有效"
	self._ccbOwner.tf_rule_1:setString(tipDesc1)
	self._ccbOwner.tf_rule_2:setString(tipDesc2)

	self._ccbOwner.node_skill_1:removeAllChildren()

    self._totalHeight = self._totalHeight + 300
	local skillDesc = QUIWidgetTeamSoulSpiritSkillInfo.new()
	skillDesc:initSkillInfo(index,soulSpiritId,isCollegeTeam,chapterId ,isMockBattle)
	self._ccbOwner.node_skill_1:addChild(skillDesc)
    self._totalHeight = self._totalHeight + skillDesc:getContentSize().height

end


function QUIWidgetTeamSoulSpiritInfo:onEnter()
end

function QUIWidgetTeamSoulSpiritInfo:onExit()
end

function QUIWidgetTeamSoulSpiritInfo:getContentSize()
	return CCSize(800,self._totalHeight)
end


return QUIWidgetTeamSoulSpiritInfo