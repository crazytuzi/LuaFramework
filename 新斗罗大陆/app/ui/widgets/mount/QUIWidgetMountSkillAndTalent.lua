local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetMountSkillAndTalent = class("QUIWidgetMountSkillAndTalent", QUIWidget)
local QActorProp = import("....models.QActorProp")
local QRichText = import("....utils.QRichText") 
local QColorLabel = import("....utils.QColorLabel")

function QUIWidgetMountSkillAndTalent:ctor(options)
	local ccbFile = "ccb/Widget_mount_talent.ccbi"
	local callBacks = {
		}
	QUIWidgetMountSkillAndTalent.super.ctor(self,ccbFile,callBacks,options)

	self._size = self._ccbOwner.node_size:getContentSize()
	self._ccbOwner.node_title_bg:setVisible(false)
	self._ccbOwner.node_skill:setVisible(false)
	self._ccbOwner.node_talent:setVisible(false)
	self._ccbOwner.tf_soul_talent_desc:setVisible(false)
end

function QUIWidgetMountSkillAndTalent:getContentSize()
	return self._size
end

function QUIWidgetMountSkillAndTalent:setGradeInfo(info, isHave, isDress)
	if q.isEmpty(info) then
		return
	end
	self._size.height = 234
	self._ccbOwner.node_skill:setVisible(true)
	self._ccbOwner.node_skill1:setVisible(false)
	self._ccbOwner.node_skill2:setVisible(false)
	self._ccbOwner.node_title_bg:setVisible(true)

	local mountConfig = db:getCharacterByID(info.id)

	if isDress and info.zuoqi_skill_xs then
		local skillConfigs = string.split(info.zuoqi_skill_xs, ";")
		local totalHeight = 30
		for i = 1, #skillConfigs do
			local skillIds = string.split(skillConfigs[i],":")
			local skillId = tonumber(skillIds[1])
			local skillConfig = db:getSkillByID(skillId)
			self._ccbOwner["node_icon"..i]:setTexture(CCTextureCache:sharedTextureCache():addImage(skillConfig.icon))
			
			local color = GAME_COLOR_LIGHT.normal
			local desc = ""
			if isHave == true then
				color = GAME_COLOR_LIGHT.normal
				self._ccbOwner["sp_mask"..i]:setVisible(false)
				desc = QColorLabel.replaceColorSign(skillConfig.description or "", false)
			else
				color = GAME_COLOR_LIGHT.notactive
				self._ccbOwner["sp_mask"..i]:setVisible(true)
				desc = QColorLabel.replaceColorNotActive(skillConfig.description or "")
			end
			desc = desc.."（配件S级暗器星级达到"..(info.grade_level+1).."星时激活）"

			self._ccbOwner["node_desc"..i]:removeAllChildren()
		    local strArr  = string.split(desc,"\n") or {}
		    local height = 0
		    for _, v in pairs(strArr) do
		        local richText = QRichText.new(v, 410, {stringType = 1, defaultColor = color, defaultSize = 22})
		        richText:setAnchorPoint(ccp(0, 1))
		        richText:setPositionY(-height)
				self._ccbOwner["node_desc"..i]:addChild(richText)
		        height = height + richText:getContentSize().height
		    end
			self._ccbOwner["node_skill"..i]:setPositionY(-totalHeight)
			self._ccbOwner["node_skill"..i]:setVisible(true)

			if height < 80 then
				height = 80
			end
			totalHeight = totalHeight + height + 20
		end
		self._ccbOwner.node_line:setPositionY(-totalHeight)
		self._ccbOwner.node_line:setVisible(false)

		if isHave == true then
			self._ccbOwner.tf_skill_title:setColor(GAME_COLOR_LIGHT.stress)
		else
			self._ccbOwner.tf_skill_title:setColor(GAME_COLOR_LIGHT.notactive)
		end
		self._size.height = totalHeight
		local titleStr = "【"..(info.grade_level+1).."星效果】"
		self._ccbOwner.tf_skill_title:setString(titleStr)
		
	elseif info.zuoqi_skill_ms ~= nil then
		local skillIds = string.split(info.zuoqi_skill_ms, ";")
		local totalHeight = 30
		for i = 1, #skillIds do
			local skillId = tonumber(skillIds[i])
			local skillConfig = db:getSkillByID(skillId)
			self._ccbOwner["node_icon"..i]:setTexture(CCTextureCache:sharedTextureCache():addImage(skillConfig.icon))
			
			local color = GAME_COLOR_LIGHT.normal
			local desc = ""
			if isHave == true then
				color = GAME_COLOR_LIGHT.normal
				self._ccbOwner["sp_mask"..i]:setVisible(false)
				desc = QColorLabel.replaceColorSign(skillConfig.description or "", false)
			else
				color = GAME_COLOR_LIGHT.notactive
				self._ccbOwner["sp_mask"..i]:setVisible(true)
				desc = QColorLabel.replaceColorNotActive(skillConfig.description or "")
			end

			self._ccbOwner["node_desc"..i]:removeAllChildren()
		    local strArr  = string.split(desc,"\n") or {}
		    local height = 0
		    for _, v in pairs(strArr) do
		        local richText = QRichText.new(v, 410, {stringType = 1, defaultColor = color, defaultSize = 22})
		        richText:setAnchorPoint(ccp(0, 1))
		        richText:setPositionY(-height)
				self._ccbOwner["node_desc"..i]:addChild(richText)
		        height = height + richText:getContentSize().height
		    end
			self._ccbOwner["node_skill"..i]:setPositionY(-totalHeight)
			self._ccbOwner["node_skill"..i]:setVisible(true)

			if height < 80 then
				height = 80
			end
			totalHeight = totalHeight + height + 10
		end
		self._ccbOwner.node_line:setPositionY(-totalHeight)
		self._ccbOwner.node_line:setVisible(false)

		if isHave == true then
			self._ccbOwner.tf_skill_title:setColor(GAME_COLOR_LIGHT.stress)
		else
			self._ccbOwner.tf_skill_title:setColor(GAME_COLOR_LIGHT.notactive)
		end
		self._size.height = totalHeight
		
		local titleStr = "【"..(info.grade_level+1).."星效果】"
		if mountConfig and mountConfig.aptitude == APTITUDE.SSR then
			titleStr = "【"..(info.grade_level).."星效果】"
		end
		self._ccbOwner.tf_skill_title:setString(titleStr)
	end
end

function QUIWidgetMountSkillAndTalent:setTalentInfo(talent, isHave)
	self._size.height = 140
	self._ccbOwner.node_talent:setVisible(true)
	self._ccbOwner.node_title_bg:setVisible(true)

	if talent ~= nil then
		self._ccbOwner.tf_talent_title:setString("【"..talent.master_name.."】")
		local props = QActorProp:getPropUIByConfig(talent)
		for i, prop in pairs(props) do
			local value = prop.value
			if prop.isPercent then
    			value = string.format("%.1f%%", value*100)
    		end
    		if prop.value > 0 then
				self._ccbOwner.tf_talent_desc:setString(prop.name.."+"..value.."（等级提升至"..talent.condition.."级）")
				break
			end
		end
		if isHave == true then
			self._ccbOwner.tf_talent_title:setColor(GAME_COLOR_LIGHT.stress)
			self._ccbOwner.tf_talent_desc:setColor(GAME_COLOR_LIGHT.normal)
		else
			self._ccbOwner.tf_talent_title:setColor(GAME_COLOR_LIGHT.notactive)
			self._ccbOwner.tf_talent_desc:setColor(GAME_COLOR_LIGHT.notactive)
		end
	end
end

function QUIWidgetMountSkillAndTalent:setSoulGuideTalentInfo(talent, isHave)
	self._size.height = 130
	self._ccbOwner.node_talent:setVisible(true)
	self._ccbOwner.node_title_bg:setVisible(true)

	if talent ~= nil then
		self._ccbOwner.tf_talent_title:setString("【"..talent.master_name.."】")
		local props = QActorProp:getPropUIByConfig(talent)
		local skillDesc = ""
		local index = 1
		for key, prop in pairs(props) do
			local value = prop.value
			if prop.isPercent then
    			value = string.format("%s%%", value*100)
    		end
    		if prop.value > 0 then
    			local str = prop.name.."+"..value
    			if index%2 == 1 then
    				skillDesc = skillDesc..str.." "
    			else
    				skillDesc = skillDesc..str.."\n"
    			end
    			index = index + 1
			end
		end
		self._ccbOwner.tf_talent_desc:setString(skillDesc.."（科技提升至"..talent.condition.."级）")

		if isHave == true then
			self._ccbOwner.tf_talent_title:setColor(GAME_COLOR_LIGHT.stress)
			self._ccbOwner.tf_talent_desc:setColor(GAME_COLOR_LIGHT.normal)
		else
			self._ccbOwner.tf_talent_title:setColor(GAME_COLOR_LIGHT.notactive)
			self._ccbOwner.tf_talent_desc:setColor(GAME_COLOR_LIGHT.notactive)
		end
	end
end

function QUIWidgetMountSkillAndTalent:_findMasterProp(masterInfo)
    for name,filed in pairs(QActorProp._field) do
    	if masterInfo[name] ~= nil and masterInfo[name] > 0 then
    		local value = masterInfo[name]
    		if filed.isPercent == true then
    			value = string.format("%.1f%%",value*100)
    		end
    		return (filed.uiName or filed.name), value, va
    	end
    end
    return "", 0
end

return QUIWidgetMountSkillAndTalent