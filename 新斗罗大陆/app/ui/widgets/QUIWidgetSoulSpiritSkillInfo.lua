--
-- Kumo.Wang
-- 魂灵出战技能展示Cell
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSoulSpiritSkillInfo = class("QUIWidgetSoulSpiritSkillInfo", QUIWidget)
local QRichText = import("...utils.QRichText") 
local QActorProp = import("...models.QActorProp")
local QColorLabel = import("...utils.QColorLabel")

function QUIWidgetSoulSpiritSkillInfo:ctor(options)
	local ccbFile = "ccb/Widget_SoulSpirit_SkillInfo.ccbi"
	local callBacks = {
		}
	QUIWidgetSoulSpiritSkillInfo.super.ctor(self,ccbFile,callBacks,options)

	self._ccbOwner.node_size:setContentSize(0, 0)
	self._ccbOwner.node_skill:setVisible(false)
    self._ccbOwner.node_master:setVisible(false)
end

function QUIWidgetSoulSpiritSkillInfo:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetSoulSpiritSkillInfo:setGradeInfo(id, gradeConfig , showGrade)
	if not id or not gradeConfig or next(gradeConfig) == nil then return end
	self._ccbOwner.node_skill:setVisible(true)
	local isActivate = false
	local soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(id)
	if soulSpiritInfo then
		isActivate = gradeConfig.grade_level <= soulSpiritInfo.grade
	end
    if showGrade and showGrade > 0 then
        isActivate = gradeConfig.grade_level <= showGrade
    end

	local descColor = isActivate and COLORS.j or COLORS.n
	local titleColor = isActivate and COLORS.k or COLORS.n

    local characterConfig = db:getCharacterByID(id)
    local showLv = gradeConfig.grade_level

    if characterConfig.aptitude ~= APTITUDE.SS then
        showLv = showLv + 1
    end

	self._ccbOwner.tf_skill_title:setString("【"..(showLv).."星效果】")
	self._ccbOwner.tf_skill_title:setColor(titleColor)

    local skillId1 = string.split(gradeConfig.soulspirit_pg, ":")
    local skillConfig1 = db:getSkillByID(tonumber(skillId1[1]))
    local skillDataConfig1 = db:getSkillDataByIdAndLevel(tonumber(skillId1[1]), tonumber(skillId1[2]))
    local height1, height2 , height3 = 0, 0, 0
    if skillConfig1 ~= nil and skillDataConfig1 ~= nil then
    	self._ccbOwner.node_icon1:setTexture(CCTextureCache:sharedTextureCache():addImage(skillConfig1.icon))
    	self._ccbOwner.sp_mask1:setVisible(not isActivate)

        local describe = skillConfig1.name.."："..skillDataConfig1.description_1
        if not isActivate then
            describe = QColorLabel.removeColorSign(describe)
        else
            describe = QColorLabel.replaceColorSign(describe or "", false)
        end
        local richText = QRichText.new(describe, 413, {stringType = 1, defaultColor = descColor, defaultSize = 20})
        richText:setAnchorPoint(ccp(0, 1))
        self._ccbOwner.node_desc1:removeAllChildren()
        self._ccbOwner.node_desc1:addChild(richText)
        height1 = math.max(richText:getContentSize().height, self._ccbOwner.node_icon1:getContentSize().height)
        self._ccbOwner.node_skill1:setVisible(true)
    end

    local skillId2 = string.split(gradeConfig.soulspirit_dz, ":")
    local skillConfig2 = db:getSkillByID(tonumber(skillId2[1]))
    local skillDataConfig2 = db:getSkillDataByIdAndLevel(tonumber(skillId2[1]), tonumber(skillId2[2]))
    if skillConfig2 ~= nil and skillDataConfig2 ~= nil then
    	self._ccbOwner.node_icon2:setTexture(CCTextureCache:sharedTextureCache():addImage(skillConfig2.icon))
    	self._ccbOwner.sp_mask2:setVisible(not isActivate)

        local describe = skillConfig2.name.."："..skillDataConfig2.description_1
        if not isActivate then
            describe = QColorLabel.removeColorSign(describe)
        else
            describe = QColorLabel.replaceColorSign(describe or "", false)
        end
        local richText = QRichText.new(describe, 413, {stringType = 1, defaultColor = descColor, defaultSize = 20})
        richText:setAnchorPoint(ccp(0, 1))
        self._ccbOwner.node_desc2:removeAllChildren()
        self._ccbOwner.node_desc2:addChild(richText)
        height2 = math.max(richText:getContentSize().height, self._ccbOwner.node_icon2:getContentSize().height)
        local posY = self._ccbOwner.node_skill1:getPositionY()-height1-20
        self._ccbOwner.node_skill2:setPositionY(posY)
        self._ccbOwner.node_skill2:setVisible(true)
    end
    local posTotalY = self._ccbOwner.node_skill2:getPositionY()-height2-20
    QPrintTable(gradeConfig)

    if gradeConfig.soul_combat_succession and gradeConfig.soul_combat_succession > 0  then

        local addCoefficientGrade = gradeConfig.soul_combat_succession
        local _,addCoefficientAptitude = remote.soulSpirit:getFightCoefficientByAptitude(characterConfig.aptitude)

        self._ccbOwner.node_icon3:setTexture(CCTextureCache:sharedTextureCache():addImage(QResPath("soul_spirit_awaken_skill")))
        self._ccbOwner.sp_mask3:setVisible(not isActivate)
        local describe = "\n##n觉醒-魂力同化：出战属性+"..q.PropPercentHanderFun(addCoefficientAptitude + addCoefficientGrade ).."(初始出战属性为上阵魂师的"..q.PropPercentHanderFun(addCoefficientAptitude)..")"
        if not isActivate then
            describe = QColorLabel.removeColorSign(describe)
        else
            describe = QColorLabel.replaceColorSign(describe or "", false)
        end
        local richText = QRichText.new(describe, 413, {stringType = 1, defaultColor = descColor, defaultSize = 20})
        richText:setAnchorPoint(ccp(0, 1))
        self._ccbOwner.node_desc3:removeAllChildren()
        self._ccbOwner.node_desc3:addChild(richText)
        height3 = math.max(richText:getContentSize().height, self._ccbOwner.node_icon3:getContentSize().height)
        local posY = self._ccbOwner.node_skill2:getPositionY()-height2-20
        self._ccbOwner.node_skill3:setPositionY(posY)
        self._ccbOwner.node_skill3:setVisible(true)

        posTotalY = self._ccbOwner.node_skill3:getPositionY()-height3-20
    end



    self._ccbOwner.node_line:setPositionY(posTotalY)

	self._ccbOwner.node_size:setContentSize(516, -posTotalY + 20)
end

function QUIWidgetSoulSpiritSkillInfo:setMasterInfo(id, masterConfig)
    if not id or not masterConfig or next(masterConfig) == nil then return end
    if masterConfig.level == 0 then return end
    
    self._ccbOwner.node_master:setVisible(true)

    local isActivate = false
    local soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(id)
    if soulSpiritInfo then
        isActivate = masterConfig.condition <= soulSpiritInfo.level
    end
    local descColor = isActivate and COLORS.j or COLORS.n
    local titleColor = isActivate and COLORS.k or COLORS.n

    self._ccbOwner.tf_master_title:setString("【"..masterConfig.master_name.."】")
    self._ccbOwner.tf_master_title:setColor(titleColor)

    local propDic  = remote.soulSpirit:getPropDicByConfig(masterConfig)
    for key, value in pairs(propDic) do
        if value > 0 then
            local name = QActorProp._field[key].uiName or QActorProp._field[key].name
            local isPercent = QActorProp._field[key].isPercent
            local str = q.getFilteredNumberToString(tonumber(value), isPercent, 2)  
            -- self._ccbOwner.tf_master_desc:setString("【"..masterConfig.master_name.."】被护佑魂师"..name.."+"..str.."（魂灵"..masterConfig.condition.."级激活）")
            self._ccbOwner.tf_master_desc:setString(name.."+"..str.."（魂灵"..masterConfig.condition.."级激活）")
            self._ccbOwner.tf_master_desc:setColor(descColor)
            break
        end
    end
   
    local posY = self._ccbOwner.tf_master_desc:getPositionY() - self._ccbOwner.tf_master_desc:getContentSize().height - 20
    self._ccbOwner.node_line:setPositionY(posY)

    self._ccbOwner.node_size:setContentSize(516, -posY + 20)
end

function QUIWidgetSoulSpiritSkillInfo:setInheritInfo(id, inheritConfig , showLv)
    if not id or not inheritConfig or next(inheritConfig) == nil then return end
    self._ccbOwner.node_skill:setVisible(true)
    local isActivate = false
    local soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(id)
    if soulSpiritInfo then
        isActivate = inheritConfig.level <= soulSpiritInfo.devour_level
    end
    if showLv and showLv > 0 then
        isActivate = inheritConfig.level <= showLv
    end

    local descColor = isActivate and COLORS.j or COLORS.n
    local titleColor = isActivate and COLORS.k or COLORS.n
    local NUMBERS = {"一","二","三","四","五","六"}
    self._ccbOwner.tf_skill_title:setString("【"..NUMBERS[inheritConfig.level].."重传承】")
    self._ccbOwner.tf_skill_title:setColor(titleColor)

    local skillId1 = string.split(inheritConfig.skill, ":")
    local skillConfig1 = db:getSkillByID(tonumber(skillId1[1]))
    local skillDataConfig1 = db:getSkillDataByIdAndLevel(tonumber(skillId1[1]), tonumber(skillId1[2]))
    local height1, height2 = 0, 0
    if skillConfig1 ~= nil and skillDataConfig1 ~= nil then
        self._ccbOwner.node_icon1:setTexture(CCTextureCache:sharedTextureCache():addImage(skillConfig1.icon))
        self._ccbOwner.sp_mask1:setVisible(not isActivate)
        local describe =skillConfig1.name .."："..skillConfig1.description
        -- local describe =skillConfig1.name .."："..skillDataConfig1.description

        if not isActivate then
            describe = QColorLabel.removeColorSign(describe)
        else
            describe = QColorLabel.replaceColorSign(describe or "", false)
        end
        local richText = QRichText.new(describe, 413, {stringType = 1, defaultColor = descColor, defaultSize = 20})
        richText:setAnchorPoint(ccp(0, 1))
        self._ccbOwner.node_desc1:removeAllChildren()
        self._ccbOwner.node_desc1:addChild(richText)
        height1 = math.max(richText:getContentSize().height, self._ccbOwner.node_icon1:getContentSize().height)
        self._ccbOwner.node_skill1:setVisible(true)
    end
    self._ccbOwner.node_skill2:setVisible(false)
    local posY = self._ccbOwner.node_skill1:getPositionY()- height1-10
    self._ccbOwner.node_line:setPositionY(posY)
    self._ccbOwner.node_size:setContentSize(516, -posY + 10)
end


function QUIWidgetSoulSpiritSkillInfo:setAwakenInfo(id, awakenConfig , showLv)
    if not id or not awakenConfig or next(awakenConfig) == nil then return end
    self._ccbOwner.node_skill:setVisible(false)
    local isActivate = false
    local soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(id)
    if soulSpiritInfo then
        isActivate = awakenConfig.level <= soulSpiritInfo.awaken_level
    end
    if showLv and showLv > 0 then
        isActivate = awakenConfig.level <= showLv
    end

    local descColor = isActivate and COLORS.j or COLORS.n
    local titleColor = isActivate and COLORS.k or COLORS.n
    self._ccbOwner.node_master:setVisible(true)
    self._ccbOwner.tf_master_title:setString("【觉醒 ·"..(awakenConfig.level).."】")
    self._ccbOwner.tf_master_title:setColor(titleColor)

    local describe = "出战属性 +"..q.PropPercentHanderFun(awakenConfig.conmbat_succession)
    self._ccbOwner.tf_master_desc:setString(describe)
    self._ccbOwner.tf_master_desc:setColor(descColor)
   
    local posY = self._ccbOwner.tf_master_desc:getPositionY() - self._ccbOwner.tf_master_desc:getContentSize().height - 20
    self._ccbOwner.node_line:setPositionY(posY)

    self._ccbOwner.node_size:setContentSize(516, -posY + 20)

end



return QUIWidgetSoulSpiritSkillInfo