local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetEnchantInfo = class("QUIWidgetEnchantInfo",QUIWidget)
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetHeroSkillBox = import("..widgets.QUIWidgetHeroSkillBox")
local QRichText = import("...utils.QRichText")
local QColorLabel = import("...utils.QColorLabel")

function QUIWidgetEnchantInfo:ctor(options)
	local ccbFile = "ccb/Widget_fumo_star.ccbi"
  	local callBacks = {  
  	}
	QUIWidgetEnchantInfo.super.ctor(self,ccbFile,callBacks,options)

	self._linePosY = self._ccbOwner.node_line:getPositionY()
	self._height = 0
end

function QUIWidgetEnchantInfo:setInfo(enchant, level, index)
	self._ccbOwner.tf_title:setString("【"..enchant.enchant_level.." 星效果】")
	self.skillItemBox = nil
	if enchant.skill_show ~= nil then
		self.skillItemBox = QUIWidgetHeroSkillBox.new()
		if index%2 == 1 then
			self.skillItemBox:setColor("orange")
		else
			self.skillItemBox:setColor("purple")
		end
		self.skillItemBox:setSkillID(enchant.skill_show)
		self.skillItemBox:setLock(false)
		self._ccbOwner.node_icon:addChild(self.skillItemBox)
	end
  	local skillInfo = QStaticDatabase:sharedDatabase():getSkillByID(enchant.skill_show)
	local skillStr = skillInfo.description or ""
	-- self._ccbOwner.tf_content:setString(skillStr)
	self._ccbOwner.tf_content:setString("")

	local defaultColor = GAME_COLOR_LIGHT.normal
	if enchant.enchant_level > level then
		self._ccbOwner.node_mask:setVisible(true)
		-- self._ccbOwner.tf_content:setColor(GAME_COLOR_LIGHT.normal)
		self._ccbOwner.tf_title:setColor(COLORS.n)

		skillStr = QColorLabel.replaceColorNotActive(skillInfo.description or "")  --string.gsub(skillInfo.description or "", "%a+", "c")

		defaultColor = GAME_COLOR_LIGHT.notactive
	else
		self._ccbOwner.node_mask:setVisible(false)
		-- self._ccbOwner.tf_content:setColor(GAME_COLOR_LIGHT.property)
		self._ccbOwner.tf_title:setColor(COLORS.k)

		skillStr = QColorLabel.replaceColorSign(skillInfo.description or "", false)

		defaultColor = GAME_COLOR_LIGHT.normal
	end
	
	self._ccbOwner.node_des:removeAllChildren()

    local strArr  = string.split(skillStr,"\n") or {}
    local height = 0
    for _, v in pairs(strArr) do
        local richText = QRichText.new(v, 400, {stringType = 1, defaultColor = defaultColor, defaultSize = 24})
        richText:setAnchorPoint(ccp(0, 1))
        richText:setPositionY(-height)
		self._ccbOwner.node_des:addChild(richText)
        height = height + richText:getContentSize().height
    end

	local skillLength = q.wordLen(skillStr, 24, 24)
	local count = math.ceil(skillLength/400)
	local newline = string.find(skillStr, "\n")
	if newline then count = count + 1 end
	
	self._height = 0
	self._ccbOwner.node_line:setPositionY(self._linePosY)
	if count > 3 then
		self._height = (count-3)*26
		self._ccbOwner.node_line:setPositionY(self._linePosY-self._height)
	end
end

function QUIWidgetEnchantInfo:getContentSize()
	local size = self._ccbOwner.node_size:getContentSize()
	size.height = size.height + self._height
	return size
end

return QUIWidgetEnchantInfo