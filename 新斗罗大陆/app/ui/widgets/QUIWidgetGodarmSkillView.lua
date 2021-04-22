-- @Author: liaoxianbo
-- @Date:   2019-12-24 15:02:51
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-01-13 14:19:50
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetGodarmSkillView = class("QUIWidgetGodarmSkillView", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QActorProp = import("...models.QActorProp")
local QRichText = import("...utils.QRichText") 
local QColorLabel = import("...utils.QColorLabel")

function QUIWidgetGodarmSkillView:ctor(options)
	local ccbFile = "ccb/Widget_Godarm_skill.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIWidgetGodarmSkillView.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._size = self._ccbOwner.node_size:getContentSize()
	self._ccbOwner.node_title_bg:setVisible(false)
	self._ccbOwner.node_skill:setVisible(false)
	self._ccbOwner.node_talent:setVisible(false)
	self._ccbOwner.tf_soul_talent_desc:setVisible(false)
end

function QUIWidgetGodarmSkillView:onEnter()
end

function QUIWidgetGodarmSkillView:onExit()
end

function QUIWidgetGodarmSkillView:getContentSize()
	return self._size
end

function QUIWidgetGodarmSkillView:setGradeInfo(info, isHave)
	self._size.height = 234
	self._ccbOwner.node_skill:setVisible(true)
	self._ccbOwner.node_skill1:setVisible(false)
	self._ccbOwner.node_skill2:setVisible(false)
	self._ccbOwner.node_title_bg:setVisible(true)

	local totalHeight = 30
	if info.god_arm_skill_sz ~= nil then
		local skillIds = string.split(info.god_arm_skill_sz, ":")
		local skillConfig = db:getSkillByID(tonumber(skillIds[1]))   
		if skillConfig then
			self._ccbOwner.node_icon1:setTexture(CCTextureCache:sharedTextureCache():addImage(skillConfig.icon))
			local color = GAME_COLOR_LIGHT.normal
			local desc = ""
			if isHave == true then
				color = GAME_COLOR_LIGHT.normal
				self._ccbOwner.sp_mask1:setVisible(false)
				desc = QColorLabel.replaceColorSign(skillConfig.description or "", false)
			else
				color = GAME_COLOR_LIGHT.notactive
				self._ccbOwner.sp_mask1:setVisible(true)
				desc = QColorLabel.replaceColorNotActive(skillConfig.description or "")
			end		
			self._ccbOwner.node_desc1:removeAllChildren()	
        	local strArray = {} 
        	table.insert(strArray,{oType = "img", fileName = "ui/update_godarm/sp_shenqijineng.png"})
        	table.insert(strArray,{oType = "font", content = skillConfig.name,size = 20,color = isHave and COLORS.k or GAME_COLOR_LIGHT.notactive})  
            local describe = "：##n"..desc
            if not isHave then
            	describe = QColorLabel.removeColorSign(describe)
            end
        	local strArr  = string.split(describe,"\n") or {}        		
			for i, v in pairs(strArr) do
            	table.insert(strArray,{oType = "font", content = v,size = 20,color = isHave and COLORS.j or GAME_COLOR_LIGHT.notactive })
            end   
            local height = 0  
            local richText = QRichText.new(strArray, 410, {stringType = 1, defaultColor = color, defaultSize = 20,lineSpacing=4 , fontParse = true})
            richText:setAnchorPoint(ccp(0, 1))
            richText:setPositionY(-height)
            self._ccbOwner.node_desc1:addChild(richText)
            height = height + richText:getContentSize().height	              			
		  --   local strArr  = string.split(desc,"\n") or {}
		  --   local height = 0
		  --   for _, v in pairs(strArr) do
		  --       local richText = QRichText.new(v, 410, {stringType = 1, defaultColor = color, defaultSize = 22})
		  --       richText:setAnchorPoint(ccp(0, 1))
		  --       richText:setPositionY(-height)
				-- self._ccbOwner.node_desc1:addChild(richText)
		  --       height = height + richText:getContentSize().height
		  --   end
			self._ccbOwner.node_skill1:setPositionY(-totalHeight)
			self._ccbOwner.node_skill1:setVisible(true)

			if height < 80 then
				height = 80
			end
			totalHeight = totalHeight + height + 10			
		end
	end
	
	if info.god_arm_skill_yz ~= nil then
		local skillIds = string.split(info.god_arm_skill_yz, ":")
		local skillConfig = db:getSkillByID(tonumber(skillIds[1]))   
		if skillConfig then
			self._ccbOwner.node_icon2:setTexture(CCTextureCache:sharedTextureCache():addImage(skillConfig.icon))
			local color = GAME_COLOR_LIGHT.normal
			local desc = ""
			if isHave == true then
				color = GAME_COLOR_LIGHT.normal
				self._ccbOwner.sp_mask2:setVisible(false)
				desc = QColorLabel.replaceColorSign(skillConfig.description or "", false)
			else
				color = GAME_COLOR_LIGHT.notactive
				self._ccbOwner.sp_mask2:setVisible(true)
				desc = QColorLabel.replaceColorNotActive(skillConfig.description or "")
			end		
			self._ccbOwner.node_desc2:removeAllChildren()	
		  --   local strArr  = string.split(desc,"\n") or {}
		  --   local height = 0
		  --   for _, v in pairs(strArr) do
		  --       local richText = QRichText.new(v, 410, {stringType = 1, defaultColor = color, defaultSize = 22})
		  --       richText:setAnchorPoint(ccp(0, 1))
		  --       richText:setPositionY(-height)
				-- self._ccbOwner.node_desc2:addChild(richText)
		  --       height = height + richText:getContentSize().height
		  --   end
		    local height = 0 
        	local strArray = {}
        	table.insert(strArray,{oType = "img", fileName = "ui/update_godarm/sp_yuanzhujineng.png"})
        	table.insert(strArray,{oType = "font", content = skillConfig.name,size = 20,color = isHave and COLORS.k or GAME_COLOR_LIGHT.notactive})
            local describe = ":"..desc
            if not isHave then
	            describe = QColorLabel.removeColorSign(describe)
            end
            local strArr  = string.split(describe,"\n") or {}
            for i, v in pairs(strArr) do
            	table.insert(strArray,{oType = "font", content = v,size = 20,color = isHave and COLORS.j or GAME_COLOR_LIGHT.notactive})
            end
            local richText = QRichText.new(strArray, 410, {stringType = 1, defaultColor = color, defaultSize = 20,lineSpacing=4, fontParse = true})
            richText:setAnchorPoint(ccp(0, 1))
            richText:setPositionY(-height)
            self._ccbOwner.node_desc2:addChild(richText)
            height = height + richText:getContentSize().height

			self._ccbOwner.node_skill2:setPositionY(-totalHeight)
			self._ccbOwner.node_skill2:setVisible(true)

			if height < 80 then
				height = 80
			end
			totalHeight = totalHeight + height + 10			
		end
	end

	self._ccbOwner.node_line:setPositionY(-totalHeight)
	self._ccbOwner.node_line:setVisible(false)

	if isHave == true then
		self._ccbOwner.tf_skill_title:setColor(GAME_COLOR_LIGHT.stress)
	else
		self._ccbOwner.tf_skill_title:setColor(GAME_COLOR_LIGHT.notactive)
	end
	self._size.height = totalHeight
	self._ccbOwner.tf_skill_title:setString((info.grade_level+1).."星效果")
			
end

function QUIWidgetGodarmSkillView:setTalentInfo(talent, isHave)
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

function QUIWidgetGodarmSkillView:setSoulGuideTalentInfo(talent, isHave)
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
    			value = string.format("%d%%", value*100)
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

return QUIWidgetGodarmSkillView
