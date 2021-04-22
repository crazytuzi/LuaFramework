--
-- 武魂真身大师
-- zxs
--
local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetArtifactTalent = class("QUIWidgetArtifactTalent", QUIWidget)
local QActorProp = import("....models.QActorProp")
local QRichText = import("....utils.QRichText") 
local QColorLabel = import("....utils.QColorLabel")

function QUIWidgetArtifactTalent:ctor(options)
	local ccbFile = "ccb/Widget_mount_talent.ccbi"
	local callBacks = {
		}
	QUIWidgetArtifactTalent.super.ctor(self,ccbFile,callBacks,options)

	self._size = self._ccbOwner.node_size:getContentSize()
	self._ccbOwner.node_title_bg:setVisible(false)
	self._ccbOwner.node_skill:setVisible(false)
	self._ccbOwner.node_talent:setVisible(false)
	self._ccbOwner.tf_soul_talent_desc:setVisible(false)
end

function QUIWidgetArtifactTalent:getContentSize()
	return self._size
end

function QUIWidgetArtifactTalent:setTalentInfo(talent, isHave)
	local size = self._ccbOwner.node_size:getContentSize()
	size.height = 140
	self._ccbOwner.node_size:setContentSize(size.width, size.height)
	self._ccbOwner.node_talent:setVisible(true)
	self._ccbOwner.node_title_bg:setVisible(true)

	if talent ~= nil then
		self._ccbOwner.tf_talent_title:setString("【"..talent.master_name.."】")
		local name,value  = self:_findMasterProp(talent)
		self._ccbOwner.tf_talent_desc:setString(name.."+"..value.."（等级提升至"..talent.condition.."级）")

		if isHave == true then
			self._ccbOwner.tf_talent_title:setColor(GAME_COLOR_LIGHT.stress)
			self._ccbOwner.tf_talent_desc:setColor(GAME_COLOR_LIGHT.normal)
		else
			self._ccbOwner.tf_talent_title:setColor(GAME_COLOR_LIGHT.notactive)
			self._ccbOwner.tf_talent_desc:setColor(GAME_COLOR_LIGHT.notactive)
		end
	end
end

function QUIWidgetArtifactTalent:_findMasterProp(masterInfo)
    for name,filed in pairs(QActorProp._field) do
    	if masterInfo[name] ~= nil and masterInfo[name] > 0 then
    		local value = masterInfo[name]
    		if filed.isPercent == true then
    			value = string.format("%.1f%%",value*100)
    		end
    		return (filed.uiName or filed.name), value
    	end
    end
    return "",""
end

return QUIWidgetArtifactTalent