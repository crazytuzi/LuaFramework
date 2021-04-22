-- @Author: liaoxianbo
-- @Date:   2019-08-09 10:09:25
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-10-20 10:27:38
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSoulSpritePrompt = class("QUIWidgetSoulSpritePrompt", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")

local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QColorLabel = import("...utils.QColorLabel")
local QActorProp = import("...models.QActorProp")
-- local QMountProp = import("...models.QMountProp")

function QUIWidgetSoulSpritePrompt:ctor(options)
	local ccbFile = "ccb/Dialog_soulprite_tips.ccbi"
    local callBacks = {
		-- {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIWidgetSoulSpritePrompt.super.ctor(self, ccbFile, callBacks, options)
  
  	if options then
  		self._itemId = options.itemId
  		self._itemType = options.itemType
  	end
  	-- self:setPositionY(50)
  	self._width = 350
  	self._lineHeight = 22
  	self._size = self._ccbOwner.node_bg:getContentSize()

  	-- self._soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(self._itemId)

  	self._soulpriteId = remote.soulSpirit:getSoulSpiritIdByFragmentId(self._itemId)
  	self._soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(self._soulpriteId)

  	self:setItemInfo()
  	self:setPropInfo()
  	self:setSkillInfo()
  	self:masterInfo()
end


function QUIWidgetSoulSpritePrompt:setItemInfo()
  	local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(self._itemId)
  	local itemType = ITEM_TYPE.ITEM
	local contentName = "拥有："
	local content = ""
  	if self._itemType == ITEM_TYPE.ITEM then
	    -- local soulId = QStaticDatabase:sharedDatabase():getActorIdBySoulId(self._itemId, 0) or 0
    	-- self._soulpriteId = tonumber(soulId)

    	local gradeLevel = 0
    	-- local soulSpriteInfo = remote.soulSpirit:getMySoulSpiritInfoById(soulId)
    	if self._soulSpiritInfo ~= nil then
			gradeLevel = self._soulSpiritInfo.grade+1 or 0
		end

	    local info = QStaticDatabase:sharedDatabase():getGradeByHeroActorLevel(self._soulpriteId, gradeLevel) or {}
	  	local needNum = info.soul_gem_count or 0
	  	local currentNum = remote.items:getItemsNumByID(self._itemId) or 0
	  	if needNum > 0 then
			content = currentNum.."/"..needNum
		else
			content = currentNum
		end
  	end

	local icon = QUIWidgetItemsBox.new()
	self._ccbOwner.node_icon:addChild(icon)
	icon:setGoodsInfo(self._itemId, itemType)
	local aptitudeInfo = db:getActorSABC(self._soulpriteId)
    if aptitudeInfo then
	   icon:showSabc(aptitudeInfo.lower)
    end

	self._ccbOwner.tf_name:setString(itemConfig.name)
    local fontColor = QIDEA_QUALITY_COLOR[remote.soulSpirit:getColorByCharacherId(self._soulpriteId)] or COLORS.b
    self._ccbOwner.tf_name:setColor(fontColor)
    self._ccbOwner.tf_name = setShadowByFontColor(self._ccbOwner.tf_name, fontColor)


	self._ccbOwner.tf_content_name:setString(contentName or "")
	self._ccbOwner.tf_type:setString(content or "")
end

function QUIWidgetSoulSpritePrompt:setPropInfo()
	if not self._soulpriteId then return end
	local propList = nil
	if not self._soulSpiritInfo then
    	propList = remote.soulSpirit:getPropListById(self._soulpriteId,0,0)
    else
    	propList = remote.soulSpirit:getPropListById(self._soulpriteId)
    end
    for i = 1, 8 do
        if propList[i] ~= nil then
            self._ccbOwner["tf_prop_name"..i]:setString((propList[i].name or "").."：")
            self._ccbOwner["tf_prop_value"..i]:setString("+"..(propList[i].value or "0"))
        else
            self._ccbOwner["tf_prop_name"..i]:setString("")
            self._ccbOwner["tf_prop_value"..i]:setString("")
        end
    end
end

function QUIWidgetSoulSpritePrompt:setSkillInfo()
	local grade = 0
	self._height1 = 0 
	self._height2 = 0 
	if self._soulSpiritInfo then
		grade = self._soulSpiritInfo.grade
	end
    local gradeConfig = QStaticDatabase.sharedDatabase():getGradeByHeroActorLevel(self._soulpriteId, grade )
    -- 由于配表原因，这里用星级来显示技能等级
    local rnumSkillLevel = q.getRomanNumberalsByInt(grade + 1)
    if gradeConfig then
        local skillId1 = string.split(gradeConfig.soulspirit_pg, ":")
        local skillConfig1 = QStaticDatabase.sharedDatabase():getSkillByID(tonumber(skillId1[1]))
        local height1, height2 = 0, 0
        if skillConfig1 ~= nil then
            local skillDesc1 = QColorLabel.removeColorSign(skillConfig1.description or "")
            self._ccbOwner.tf_skill_name1:setString(skillConfig1.name or "")
            self._ccbOwner.tf_skill_content1:setString(skillDesc1 or "")

        	local posY = self._ccbOwner.node_content1:getPositionY()
			local skillLength1 = q.wordLen(skillDesc1, 20, 20)
		    local count = math.ceil(skillLength1/self._width)
		    self._height1 = count*self._lineHeight
		    self._ccbOwner.node_content2:setPositionY(posY-40-self._height1)

        end

        local skillId2 = string.split(gradeConfig.soulspirit_dz, ":")
        local skillConfig2 = QStaticDatabase.sharedDatabase():getSkillByID(tonumber(skillId2[1]))

        if skillConfig2 ~= nil then
            local skillDesc = QColorLabel.removeColorSign(skillConfig2.description or "")
            local skillDesc2 = string.sub(skillDesc, 0, 320).."..."  --防止提示框超出边界，这里的技能描述限制在160的汉字内，多余部分用省略号代替
            self._ccbOwner.tf_skill_name2:setString(skillConfig2.name or "")
            self._ccbOwner.tf_skill_content2:setString(skillDesc2 or "")

        	local posY = self._ccbOwner.node_content2:getPositionY()
			local skillLength2 = q.wordLen(skillDesc2, 20, 20)
		    local count = math.ceil(skillLength2/self._width)
		    self._height2 = count*self._lineHeight
		    self._ccbOwner.node_content3:setPositionY(posY-40-self._height2-self._lineHeight/2)
        end
    end


    -- local height = (height1 or 0) + (height2 or 0 ) - 6*self._lineHeight+10
    -- if height < 0 then
    -- 	height = 0
    -- end

    -- self._ccbOwner.node_bg:setContentSize(CCSize(self._size.width, self._size.height+height))
end
function QUIWidgetSoulSpritePrompt:masterInfo()

	self._characterConfig = QStaticDatabase.sharedDatabase():getCharacterByID(self._soulpriteId)
	local level = 0 
	if self._soulSpiritInfo then
		level = self._soulSpiritInfo.level
	end
    local curMasterConfig = remote.soulSpirit:getMasterConfigByAptitudeAndSoulSpiritLevel(self._characterConfig.aptitude, (level or 0))
    local masterLevel = curMasterConfig and curMasterConfig.level or 0
    local isHaveMaster = true
    if masterLevel == 0 then 
        isHaveMaster = false
    end
    local height = 0
    if curMasterConfig then
    	self._ccbOwner.tf_skill_name3:setString("魂灵天赋")
        local propDic  = remote.soulSpirit:getPropDicByConfig(curMasterConfig)
        if isHaveMaster == true then
            for key, value in pairs(propDic) do
                if value > 0 then
                    local name = QActorProp._field[key].uiName or QActorProp._field[key].name
                    local isPercent = QActorProp._field[key].isPercent
                    local str = q.getFilteredNumberToString(tonumber(value), isPercent, 2)  
                    local showString = "【"..curMasterConfig.master_name.."】被护佑魂师"..name.."+"..str.."（魂灵"..curMasterConfig.condition.."级激活）"

		            local skillDesc3 = QColorLabel.removeColorSign(showString or "")

		            self._ccbOwner.tf_skill_content3:setString(skillDesc3 or "")
		            -- self._ccbOwner.tf_skill_content3:setColor(GAME_COLOR_LIGHT.stress)
		            local skillLength3 = q.wordLen(skillDesc3, 20, 20)
				    local count = math.ceil(skillLength3/self._width)
				    height = count*self._lineHeight
                    break
                end
            end
        else  --10级前显示下一条
		    local nextMasterConfig = remote.soulSpirit:getMasterConfigByAptitudeAndMasterLevel(self._characterConfig.aptitude, masterLevel + 1)
		    if nextMasterConfig then
		        local propDic  = remote.soulSpirit:getPropDicByConfig(nextMasterConfig)
		        for key, value in pairs(propDic) do
		            if value > 0 then
		                local name = QActorProp._field[key].uiName or QActorProp._field[key].name
		                local isPercent = QActorProp._field[key].isPercent
		                local str = q.getFilteredNumberToString(tonumber(value), isPercent, 2) 
		                local showString = "【"..nextMasterConfig.master_name.."】被护佑魂师"..name.."+"..str.."（魂灵"..nextMasterConfig.condition.."级激活）"
			            local skillDesc3 = QColorLabel.removeColorSign(showString or "")

			            self._ccbOwner.tf_skill_content3:setString(skillDesc3 or "")
			            -- self._ccbOwner.tf_skill_content3:setColor(GAME_COLOR_LIGHT.stress)
			            local skillLength3 = q.wordLen(skillDesc3, 20, 20)
					    local count = math.ceil(skillLength3/self._width)
					    height = count*self._lineHeight
		                break
		            end
		        end
		    else
		        self._ccbOwner.node_content3:setVisible(false)
		    end
        end
    else
        self._ccbOwner.node_content3:setVisible(false)
    end

    -- local oldsize = self._ccbOwner.node_bg:getContentSize()
    local offsetHeight = (self._height1 or 0) + (self._height2 or 0 ) + (height or 0) - 6*self._lineHeight+10
    if offsetHeight < 0 then
    	offsetHeight = 0
    end
    self._ccbOwner.node_bg:setContentSize(CCSize(self._size.width, self._size.height + offsetHeight - 50))
    self:setPositionY(offsetHeight-50)

end


function QUIWidgetSoulSpritePrompt:onEnter()
end

function QUIWidgetSoulSpritePrompt:onExit()
end

function QUIWidgetSoulSpritePrompt:getContentSize()
end

return QUIWidgetSoulSpritePrompt
