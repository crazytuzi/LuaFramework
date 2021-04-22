-- @Author: liaoxianbo
-- @Date:   2020-01-10 18:35:06
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-01-13 20:18:34
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetGodarmTeamDetail = class("QUIWidgetGodarmTeamDetail", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QActorProp = import("...models.QActorProp")
local QRichText = import("...utils.QRichText") 
local QColorLabel = import("...utils.QColorLabel")

function QUIWidgetGodarmTeamDetail:ctor(options)
	local ccbFile = "ccb/Widget_Godarm_Teamskill.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIWidgetGodarmTeamDetail.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

end

function QUIWidgetGodarmTeamDetail:onEnter()
end

function QUIWidgetGodarmTeamDetail:onExit()
end

function QUIWidgetGodarmTeamDetail:setSkillInfo(godarmInfo)
	if next(godarmInfo) == nil or not godarmInfo then return end
	local gradeInfo = db:getGradeByHeroActorLevel(godarmInfo.id,godarmInfo.grade) or {}
	local godarmConfig = db:getCharacterByID(godarmInfo.id)

	self:showSabc(godarmInfo.id)
	
	if godarmConfig then
	    local aptitudeInfo = db:getActorSABC(godarmInfo.id)
	    self._ccbOwner.tf_skill_title:setString(godarmConfig.name or "") 

	    local fontColor = UNITY_COLOR_LIGHT[aptitudeInfo.color]
		self._ccbOwner.tf_skill_title:setColor(fontColor)
	    self._ccbOwner.tf_skill_title = setShadowByFontColor(self._ccbOwner.tf_skill_title, fontColor)


		local jobIconPath = remote.godarm:getGodarmJobPath(godarmConfig.label)
		if jobIconPath then
			QSetDisplaySpriteByPath(self._ccbOwner.sp_godarm_label,jobIconPath)
		end
	end	



	local skillIds = nil
	local skillConfig = nil
	local path = "ui/update_godarm/sp_shenqijineng.png"
	local isShangzheng = false
	print("上阵的位置---godarmInfo.pos",godarmInfo.pos)
	if godarmInfo.pos and godarmInfo.pos <5 and godarmInfo.pos > 0 then
		skillIds = string.split(gradeInfo.god_arm_skill_sz, ":")
		path = "ui/update_godarm/sp_shenqijineng.png"
		isShangzheng = true
	else
		skillIds = string.split(gradeInfo.god_arm_skill_yz, ":")
		path = "ui/update_godarm/sp_yuanzhujineng.png"
	end
	if skillIds then
		skillConfig = db:getSkillByID(tonumber(skillIds[1]))   
	end
	self._ccbOwner.node_desc1:removeAllChildren()
	if skillConfig then
		self._ccbOwner.node_icon1:setTexture(CCTextureCache:sharedTextureCache():addImage(skillConfig.icon))

    	local strArray = {} 
    	table.insert(strArray,{oType = "img", fileName = path})
    	table.insert(strArray,{oType = "font", content = skillConfig.name,size = 20,color = COLORS.k})  	
        local describe = "：##n"..(skillConfig.description or "")
        if isShangzheng then
        	describe = "：##n"..(skillConfig.description_2 or "")
        end
        describe = QColorLabel.removeColorSign(describe)
        local strArr  = string.split(describe,"\n") or {}
        for i, v in pairs(strArr) do
        	table.insert(strArray,{oType = "font", content = v,size = 20,color = COLORS.j})
        end
        local richText = QRichText.new(strArray, 580, {stringType = 1, defaultColor = GAME_COLOR_LIGHT.normal, defaultSize = 20,lineSpacing=4})
        richText:setAnchorPoint(ccp(0, 1))
        self._ccbOwner.node_desc1:addChild(richText)

	end
end

function QUIWidgetGodarmTeamDetail:showSabc(godarmId)
	if not godarmId then return end

	local aptitudeInfo = db:getActorSABC(godarmId)
	if aptitudeInfo then
	    q.setAptitudeShow(self._ccbOwner, aptitudeInfo.lower)

		if aptitudeInfo.lower == "a" or aptitudeInfo.lower == "a+" then
			self._ccbOwner["star_a"]:setVisible(true)
		elseif aptitudeInfo.lower == "s" then
			self._ccbOwner["star_s"]:setVisible(true)
		end

		self._ccbOwner.node_pingzhi:setVisible(true)
	end
end

function QUIWidgetGodarmTeamDetail:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

return QUIWidgetGodarmTeamDetail
