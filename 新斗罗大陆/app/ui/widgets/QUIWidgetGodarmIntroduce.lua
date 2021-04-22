-- @Author: liaoxianbo
-- @Date:   2019-12-24 17:45:35
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-05-20 14:32:19
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetGodarmIntroduce = class("QUIWidgetGodarmIntroduce", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QColorLabel = import("...utils.QColorLabel")
local QRichText = import("...utils.QRichText")
local QActorProp = import("...models.QActorProp")

local TEXT_ZHUSHI = "注：布阵界面，神器上阵后上阵技能对队伍生效。未上阵的神器庇护技能生效。"

function QUIWidgetGodarmIntroduce:ctor(options)
	local ccbFile = "ccb/Widget_Godarm_Intreduce.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerGenre", callback = handler(self, self._onTriggerGenre)},
        {ccbCallbackName = "onTriggerTalent", callback = handler(self, self._onTriggerTalent)},
    }
    QUIWidgetGodarmIntroduce.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self._pageWidth = self._ccbOwner.node_mask:getContentSize().width
    self._pageHeight = self._ccbOwner.node_mask:getContentSize().height

    self._pageContent = self._ccbOwner.node_info
    self._orginalPosition = ccp(self._pageContent:getPosition())

    self._haveDecimalNum = 1

    local layerColor = CCLayerColor:create(ccc4(0,0,0,150),self._pageWidth,self._pageHeight)
    local ccclippingNode = CCClippingNode:create()
    layerColor:setPositionX(self._ccbOwner.node_mask:getPositionX())
    layerColor:setPositionY(self._ccbOwner.node_mask:getPositionY())
    ccclippingNode:setStencil(layerColor)
    self._pageContent:removeFromParent()
    ccclippingNode:addChild(self._pageContent)

    self._ccbOwner.node_mask:getParent():addChild(ccclippingNode)

    self._ccbOwner.node_scroll:setVisible(false)
    self._ccbOwner.node_shadow_bottom:setVisible(true)
    self._ccbOwner.node_shadow_top:setVisible(false)

    self._totalHeight = 530

end

function QUIWidgetGodarmIntroduce:onEnter()
    self._touchLayer = QUIGestureRecognizer.new()
    self._touchLayer:attachToNode(self._ccbOwner.node_mask:getParent(),self._pageWidth, self._pageHeight, -self._pageWidth/2, 
    -self._pageHeight/2, handler(self, self.onTouchEvent))
    self._touchLayer:enable()
    self._touchLayer:addEventListener(QUIGestureRecognizer.EVENT_SLIDE_GESTURE, handler(self, self.onTouchEvent))	

    self._godarmProxy = cc.EventProxy.new(remote.godarm)
    self._godarmProxy:addEventListener(remote.godarm.GODARM_EVENT_UPDATE, handler(self, self.setGodarmInfo))

end

function QUIWidgetGodarmIntroduce:onExit()
    self._touchLayer:removeAllEventListeners()
    self._touchLayer:disable()
    self._touchLayer:detach()	
    self._godarmProxy:removeAllEventListeners()
end

-- 处理各种touch event
function QUIWidgetGodarmIntroduce:onTouchEvent(event)
    if event == nil or event.name == nil then
        return
    end
    if event.name == QUIGestureRecognizer.EVENT_SLIDE_GESTURE then
        -- self._page:endMove(event.distance.y)
    elseif event.name == "began" then
        self._startY = event.y
        self._pageY = self._pageContent:getPositionY()
    elseif event.name == "moved" then
        local offsetY = self._pageY + event.y - self._startY
        if offsetY < self._orginalPosition.y then
            self._ccbOwner.node_shadow_bottom:setVisible(true)
            self._ccbOwner.node_shadow_top:setVisible(false)
            offsetY = self._orginalPosition.y
        elseif offsetY > (self._totalHeight - self._pageHeight + self._orginalPosition.y) then
            offsetY = (self._totalHeight - self._pageHeight + self._orginalPosition.y)
            self._ccbOwner.node_shadow_bottom:setVisible(false)
            self._ccbOwner.node_shadow_top:setVisible(true)
        else
	        self._ccbOwner.node_shadow_bottom:setVisible(true)
	        self._ccbOwner.node_shadow_top:setVisible(true)
        end
        self._pageContent:setPositionY(offsetY)
    elseif event.name == "ended" then
    end
end

function QUIWidgetGodarmIntroduce:setGodarmId( godarmId )
	if godarmId == nil or godarmId == "" then return end
	self._godarmId = godarmId
	self:setGodarmInfo()
end

function QUIWidgetGodarmIntroduce:setGodarmInfo()
    self._totalHeight = 530
    self._pageContent:setPositionY(0)   
    self._godarmConfig = db:getCharacterByID(self._godarmId)
    self._godarmInfo = remote.godarm:getGodarmById(self._godarmId)

    -- if self._godarmConfig.aptitude == APTITUDE.AA or  self._godarmConfig.aptitude == APTITUDE.A then
    --     self._haveDecimalNum = 1
    -- else
    --     self._haveDecimalNum = 0
    -- end
	-- 默认显示5星
	self._grade = 0
	if self._godarmInfo then
		self._grade = self._godarmInfo.grade
	end
	self:setTalentInfo()
	self:setSkillInfo()
    local desc = self._godarmConfig.brief or ""
	-- local text = QColorLabel:create(desc, 330, nil, nil, 20, GAME_COLOR_LIGHT.normal)
	self._ccbOwner.tf_hero_introduce:setString(desc)


    local jobIconPath = remote.godarm:getGodarmJobPath(self._godarmConfig.label)
    if jobIconPath then
        QSetDisplaySpriteByPath(self._ccbOwner.sp_jobType,jobIconPath)
    end

    local jobIconBgPath = remote.godarm:getGodarmJobBgPath(self._godarmConfig.label)
    if jobIconBgPath then
        QSetDisplaySpriteByPath(self._ccbOwner.sp_jobType_bg,jobIconBgPath)
    end
    self._ccbOwner.tf_jobType:setString(self._godarmConfig.label.."神器")

	self._totalHeight = self._totalHeight + self._ccbOwner.tf_hero_introduce:getContentSize().height
    self._ccbOwner.sp_zi_jobTips:setPositionY(-(45 + self._ccbOwner.tf_hero_introduce:getContentSize().height))
    self._totalHeight = self._totalHeight + 24

	if self._totalHeight <  self._pageHeight then
		self._totalHeight = self._pageHeight
	end
end

function QUIWidgetGodarmIntroduce:setTalentInfo()
	self._ccbOwner.tf_talent_jihuo:setString("")
	self._ccbOwner.tf_talent_xyj:setString("")
	local curTalentInfo = db:getGodarmMasterByAptitudeAndLevel(self._godarmInfo.aptitude,self._godarmInfo.level)
    local propDic  = remote.godarm:getPropDicByConfig(curTalentInfo)

    for key, value in pairs(propDic) do
        if value > 0 then
            local name = QActorProp._field[key].uiName or QActorProp._field[key].name
            local isPercent = QActorProp._field[key].isPercent
            local str = q.getFilteredNumberToString(tonumber(value), isPercent, self._haveDecimalNum)  
            self._ccbOwner.tf_talent_jihuo:setString(name.."+"..str.."（神器"..curTalentInfo.condition.."级激活）")
            break
        end
    end	
    if (curTalentInfo.level or 0) < 24 then
    	local nextTalentInfo = db:getGodarmMasterByAptitudeAndLevel(self._godarmInfo.aptitude,self._godarmInfo.level + 10 )
        local propDic  = remote.godarm:getPropDicByConfig(nextTalentInfo)
        for key, value in pairs(propDic) do
            if value > 0 then
                local name = QActorProp._field[key].uiName or QActorProp._field[key].name
                local isPercent = QActorProp._field[key].isPercent
                local str = q.getFilteredNumberToString(tonumber(value), isPercent, self._haveDecimalNum)  
                self._ccbOwner.tf_talent_xyj:setString(name.."+"..str.."（神器"..nextTalentInfo.condition.."级激活）")
                self._ccbOwner.tf_nextTalent:setVisible(true)
                self._ccbOwner.tf_talent_xyj:setVisible(true)
                break
            end
        end	
    else
        self._ccbOwner.tf_nextTalent:setVisible(false)
        self._ccbOwner.tf_talent_xyj:setVisible(false)
    end

end
function QUIWidgetGodarmIntroduce:setSkillInfo()
	self._ccbOwner.node_godDesc:removeAllChildren()
    local height = 0
    local gradeConfig = db:getGradeByHeroActorLevel(self._godarmId, self._grade)
    if gradeConfig then
        if gradeConfig.god_arm_skill_sz then
	        local skillIds = string.split(gradeConfig.god_arm_skill_sz, ":")
	        local skillConfig1 = db:getSkillByID(tonumber(skillIds[1]))
	        if skillConfig1 then  
	        	local strArray = {} 
            	table.insert(strArray,{oType = "img", fileName = "ui/update_godarm/sp_shenqijineng.png"})
            	table.insert(strArray,{oType = "font", content = skillConfig1.name,size = 20,color = COLORS.k})  	
                local desc = QColorLabel.replaceColorSign(skillConfig1.description or "", false)
	            local describe = "：##n"..(desc or "")
	            --describe = QColorLabel.removeColorSign(describe)
	            local strArr  = string.split(describe,"\n") or {}
                -- for i, v in pairs(strArr) do
                --     local richText = QRichText.new(v, 320, {stringType = 1, defaultColor = GAME_COLOR_LIGHT.normal, defaultSize = 20})
                --     local config_table = richText:parseString(v)
                --     for ii, vv in pairs(config_table) do
                --         table.insert(strArray,vv)
                --     end
                -- end                       
	            for i, v in pairs(strArr) do
	            	table.insert(strArray,{oType = "font", content = v,size = 20,color = COLORS.j})
	            end
                local richText = QRichText.new(strArray, 320, {stringType = 1, defaultColor = GAME_COLOR_LIGHT.normal, defaultSize = 20,lineSpacing=4, fontParse = true})
                richText:setAnchorPoint(ccp(0, 1))
                richText:setPositionY(-height)
                self._ccbOwner.node_godDesc:addChild(richText)
                height = height + richText:getContentSize().height	            
	        end
        end


        if gradeConfig.god_arm_skill_yz then
            local skillIds = string.split(gradeConfig.god_arm_skill_yz, ":")
            local skillConfig1 = db:getSkillByID(tonumber(skillIds[1]))          
            local height1 = 0
            if skillConfig1 ~= nil then
            	local strArray = {}
            	table.insert(strArray,{oType = "img", fileName = "ui/update_godarm/sp_yuanzhujineng.png"})
            	table.insert(strArray,{oType = "font", content = skillConfig1.name,size = 20,color = COLORS.k})
                local desc = QColorLabel.replaceColorSign(skillConfig1.description or "", false)
                local describe = ":"..desc or ""
                --describe = QColorLabel.removeColorSign(describe)
                local strArr  = string.split(describe,"\n") or {}
                -- for i, v in pairs(strArr) do
                --     local richText = QRichText.new(v, 320, {stringType = 1, defaultColor = GAME_COLOR_LIGHT.normal, defaultSize = 20})
                --     local config_table = richText:parseString(v)
                --     for ii, vv in pairs(config_table) do
                --         table.insert(strArray,vv)
                --     end
                -- end                
                for i, v in pairs(strArr) do
                	table.insert(strArray,{oType = "font", content = v,size = 20,color = COLORS.j})
                end
                local richText = QRichText.new(strArray, 320, {stringType = 1, defaultColor = GAME_COLOR_LIGHT.normal, defaultSize = 20,lineSpacing=4, fontParse = true})
                richText:setAnchorPoint(ccp(0, 1))
                richText:setPositionY(-height)
                self._ccbOwner.node_godDesc:addChild(richText)
                height = height + richText:getContentSize().height
            end
        end

        local zhushi = {{oType = "font", content = TEXT_ZHUSHI,size = 18,color = COLORS.g}}
		local richText = QRichText.new(zhushi, 320, {stringType = 1, defaultColor = GAME_COLOR_LIGHT.normal, defaultSize = 20})
        richText:setAnchorPoint(ccp(0, 1))
        richText:setPositionY(-height)
        self._ccbOwner.node_godDesc:addChild(richText)
        height = height + richText:getContentSize().height        
    end
    height = height + 15
    self._totalHeight = self._totalHeight + height

    self._ccbOwner.node_down:setPositionY(-100-height)

    self:setPropertyInfo(gradeConfig)
end

function QUIWidgetGodarmIntroduce:setPropertyInfo( gradeConfig )
	if not gradeConfig or next(gradeConfig) == nil then
		return
	end

	local godarmReformProp = {}
	-- 强化属性
	local refromProp = db:getGodarmLevelConfigBylevel(self._godarmConfig.aptitude, self._godarmInfo.level) or {}
	QActorProp:getPropByConfig(refromProp, godarmReformProp)
	--星级属性
	local gradeProp = db:getGradeByHeroActorLevel(self._godarmInfo.id, self._godarmInfo.grade)
	QActorProp:getPropByConfig(gradeProp, godarmReformProp)

    for key, value in pairs(godarmReformProp) do
        local name = QActorProp._field[key].uiName or QActorProp._field[key].name
        local isPercent = QActorProp._field[key].isPercent
        local str = q.getFilteredNumberToString(tonumber(value or 0), isPercent, self._haveDecimalNum)  
        self:setText("tf_"..key,str)
    end	

end

function QUIWidgetGodarmIntroduce:setText(name, text)
	if self._ccbOwner[name] then
		self._ccbOwner[name]:setString(text)
	end
end

function QUIWidgetGodarmIntroduce:_onTriggerGenre( event )
	if q.buttonEventShadow(event, self._ccbOwner.btn_genre) == false then return end
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogGodarmSkillView", 
        options = {godarmId = self._godarmId}})
end

function QUIWidgetGodarmIntroduce:_onTriggerTalent( event )
    if q.buttonEventShadow(event, self._ccbOwner.btn_genre1) == false then return end
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogGodarmMasterInfo", 
        options={godarmId = self._godarmId}}, {isPopCurrentDialog = false})    
end

function QUIWidgetGodarmIntroduce:getContentSize()
end

return QUIWidgetGodarmIntroduce
