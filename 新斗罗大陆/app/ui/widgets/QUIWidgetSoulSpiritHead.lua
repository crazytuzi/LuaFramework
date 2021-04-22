--
-- Kumo.Wang
-- 魂灵头像
--

local QUIWidget = import(".QUIWidget")
local QUIWidgetSoulSpiritHead = class("QUIWidgetSoulSpiritHead", QUIWidget)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetHeroHeadStar = import(".QUIWidgetHeroHeadStar")

QUIWidgetSoulSpiritHead.EVENT_SOULSPIRIT_HEAD_CLICK = "QUIWIDGETSOULSPIRITHEAD.EVENT_SOULSPIRIT_HEAD_CLICK"

function QUIWidgetSoulSpiritHead:ctor(options)
	local ccbFile = "ccb/Widget_SoulSpirit_HeadBox.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClick", callback = handler(self, QUIWidgetSoulSpiritHead._onTriggerClick)},
	}
	QUIWidgetSoulSpiritHead.super.ctor(self,ccbFile,callBacks,options)
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()


    self._initIconSize = self._ccbOwner.sp_head:getContentSize()

    self:resetAll()
end

function QUIWidgetSoulSpiritHead:initGLLayer(glLayerIndex)
	self._glLayerIndex = glLayerIndex or 1
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_bg, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_head, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_level_bg, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_level, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_inherit_bg, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_inherit, self._glLayerIndex)	
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_frame, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_star, self._glLayerIndex)
	if self._star then
		self._glLayerIndex = self._star:initGLLayer(self._glLayerIndex)
	end
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_select, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_team6, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_team5, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_team4, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_team3, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_team2, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_team1, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._spriteIcon, self._glLayerIndex)
	--_tempOwner
	if self._tempOwner then
		self._glLayerIndex = q.nodeAddGLLayer(self._tempOwner.unknow, self._glLayerIndex)
		self._glLayerIndex = q.nodeAddGLLayer(self._tempOwner.tf_name1, self._glLayerIndex)
		self._glLayerIndex = q.nodeAddGLLayer(self._tempOwner.tf_name2, self._glLayerIndex)
		self._glLayerIndex = q.nodeAddGLLayer(self._tempOwner.tf_name3, self._glLayerIndex)
		self._glLayerIndex = q.nodeAddGLLayer(self._tempOwner.tf_name4, self._glLayerIndex)
		self._glLayerIndex = q.nodeAddGLLayer(self._tempOwner.st_team1, self._glLayerIndex)
		self._glLayerIndex = q.nodeAddGLLayer(self._tempOwner.st_team2, self._glLayerIndex)
		self._glLayerIndex = q.nodeAddGLLayer(self._tempOwner.st_team3, self._glLayerIndex)
	end
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_aid4, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_aid3, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_aid2, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_aid1, self._glLayerIndex)

	--pingzhi
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_a, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.star_a, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_light_a1, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_light_a2, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.pingzhi_b, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.pingzhi_c, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner["pingzhi_a+"], self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_s, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.star_s, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_ss, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.star_ss, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_light_s1, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_light_s2, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_light_s3, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_light_s4, self._glLayerIndex)

	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_plus, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_plus, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_noWear, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_redTips, self._glLayerIndex)

	return self._glLayerIndex
end

function QUIWidgetSoulSpiritHead:setHeadScale(v)
	self:getView():setScale(v)
end

function QUIWidgetSoulSpiritHead:getSoulSpiritId()
	return self._id
end

function QUIWidgetSoulSpiritHead:resetAll()
	self._ccbOwner.sp_head:setVisible(false)
	self._ccbOwner.node_star:setVisible(false)
	self._ccbOwner.node_inherit:setVisible(false)
	self._ccbOwner.tf_level:setString("")
  	self._ccbOwner.sp_frame:setVisible(false)
  	self._ccbOwner.node_plus:setVisible(false)
  	self._ccbOwner.tf_noWear:setVisible(false)
  	self._ccbOwner.sp_redTips:setVisible(false)
	self:setLevelVisible(false)
	self:setHighlightedSelectState(false)
	self:setTeam(0)
	self:hideSabc()
	self._id = nil
end

function QUIWidgetSoulSpiritHead:setInfo(soulSpiritInfo)
	self:resetAll()
	self._soulSpiritInfo = soulSpiritInfo
	if self._soulSpiritInfo then
		self._id = self._soulSpiritInfo.id
		self._characterConfig = QStaticDatabase:sharedDatabase():getCharacterByID(self._id)
		
		-- 设置头像
		local soulSpiritIcon = self:_getSoulSpiritIcon()
		if soulSpiritIcon then
			local iconTexture = CCTextureCache:sharedTextureCache():addImage(soulSpiritIcon)
			self._ccbOwner.sp_head:setTexture(iconTexture)
		    self._size = iconTexture:getContentSize()
		   	local rect = CCRectMake(0, 0, self._size.width, self._size.height)
		   	self._ccbOwner.sp_head:setTextureRect(rect)
			self._ccbOwner.sp_head:setVisible(true)
		end

		self:setLevel(self._soulSpiritInfo.level or 0)
		self:setInherit(self._soulSpiritInfo.devour_level or 0)

		-- 設置邊框
	    local color = remote.soulSpirit:getColorByCharacherId(self._id)
	    local aptitudeColor = string.lower(color)
	    -- print(self._id, color, aptitudeColor)
		self:setFrame(aptitudeColor)
		
		self:setStar(soulSpiritInfo.grade or 0)
		self:showSabcWithoutStar()
	else
		-- 設置邊框
		self:setFrame("yellow")
		self._ccbOwner.node_plus:setVisible(true)
	end
end

function QUIWidgetSoulSpiritHead:checkRedTips()
	if self._soulSpiritInfo then
		local heroId = self._soulSpiritInfo.heroId 
		if heroId > 0 then
			local uiHeroModel = remote.herosUtil:getUIHeroByID(heroId)
  			self._ccbOwner.sp_redTips:setVisible(uiHeroModel:checkSoulSpiritRedTips())
		end
	end
  	self._ccbOwner.sp_redTips:setVisible(false)
end

function QUIWidgetSoulSpiritHead:setRedTips(boo, scale)
	self._ccbOwner.sp_redTips:setVisible(boo)
	self._ccbOwner.sp_redTips:setScale(scale or 1)
end

function QUIWidgetSoulSpiritHead:addLockedIcon(visible)
	if visible then
		self._locked = true
		if self._lockIcon then
			self._lockIcon:setVisible(true)
		else
			CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ui/Fighting.plist")
			self._lockIcon = CCSprite:createWithSpriteFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("lock.png"))
			self._lockIcon:setScale(0.4)
			self._lockIcon:setPosition(ccp(-40, 30))
			self:addChild(self._lockIcon)
		end
	else
		self._locked = false
		if self._lockIcon then
			self._lockIcon:setVisible(false)
		end
	end
end

--[[
	设置等级显示
]]
function QUIWidgetSoulSpiritHead:setLevel(level)
	if level ~= nil and tonumber(level) > 0 then
    	self:setLevelVisible(true)
		self._ccbOwner.tf_level:setString(tostring(level))
	else
		self:setLevelVisible(false)
	end
end

--[[
	设置进阶显示
]]
function QUIWidgetSoulSpiritHead:setStar(grade, isShowEffect)
 

    if self._star == nil then
    	self._star = QUIWidgetHeroHeadStar.new({})
    	self._ccbOwner.node_star:addChild(self._star:getView())
    end
    self._star:setStar((grade or 0) + 1, isShowEffect)
	if self._characterConfig.aptitude == APTITUDE.SS  then
		if grade == 0 then
    		self._star:setEmptyStar()
    	else
    		self._star:setStar((grade or 1) , isShowEffect)
    	end
    else
    	self._star:setStar((grade or 0) + 1, isShowEffect)
	end

	self._ccbOwner.node_star:setVisible(true)
end

function QUIWidgetSoulSpiritHead:setFrame(color)
    local pathList = QResPath("soulSpirit_frame_"..color)
    if pathList then
        local frame = QSpriteFrameByPath(pathList[1])
        if frame then
        	self._ccbOwner.sp_frame:setVisible(true)
            self._ccbOwner.sp_frame:setSpriteFrame(frame)
        end
    end
end

function QUIWidgetSoulSpiritHead:setInherit(inherit)
	if inherit <= 0 then
		self._ccbOwner.node_inherit:setVisible(false)
		return
	end
	self._ccbOwner.node_inherit:setVisible(true)
   
    local frame =QSpriteFrameByPath(QResPath("soul_spirit_chuan_sp")[tonumber(inherit)])
    if frame then
    	self._ccbOwner.sp_inherit:setVisible(true)
        self._ccbOwner.sp_inherit:setDisplayFrame(frame)
    end
end

function QUIWidgetSoulSpiritHead:boundingBox( )
	local scalex = self:getScaleX() or 1
	local scaley = self:getScaleY() or 1
	local size = self._ccbOwner.sp_bg:getContentSize()
	return { origin={x = 0, y = 0}, size = {width = size.width * scalex, height = size.height * scaley}}
end

function QUIWidgetSoulSpiritHead:setContentVisible(v)
	self._ccbOwner.sp_bg:setVisible(v)
end

function QUIWidgetSoulSpiritHead:setContentScale(v)
	self._ccbOwner.sp_bg:setScale(v)
end

function QUIWidgetSoulSpiritHead:setStarVisible(v)
	self._ccbOwner.node_star:setVisible(v)
end

--设置等级是否显示
function QUIWidgetSoulSpiritHead:setLevelVisible(b)
	self._ccbOwner.node_level:setVisible(b)
end 

function QUIWidgetSoulSpiritHead:setTouchEnabled(b)
	self._ccbOwner.btn_touch:setTouchEnabled(b)
end

function QUIWidgetSoulSpiritHead:setNoWearTips()
	self:setInfo()
	self._ccbOwner.tf_noWear:setVisible(true)
	self._ccbOwner.node_plus:setVisible(false)
end

-- index: 0 - no sign, 1 - main, 2 - helper, 3 - helper1, 4 - helper2, 5 - helper3
function QUIWidgetSoulSpiritHead:setTeam(index, isSoul)
	self._ccbOwner.node_team:setVisible(true)
	self._ccbOwner.node_aid:setVisible(false)
	self._ccbOwner.sp_team_soul:setVisible(false)
	for i = 1, 5 do
		self._ccbOwner["sp_team"..i]:setVisible(false)
	end
	-- 魂灵
	if isSoul then
		self._ccbOwner.sp_team_soul:setVisible(true)
	elseif index == 0 then
		self._ccbOwner.node_team:setVisible(false)
	else
		self._ccbOwner["sp_team"..index]:setVisible(true)
	end
end

-- index: 0 - no sign, 1 - skill1, 2 - skill2, 3 - skill3, 4 - skill4
function QUIWidgetSoulSpiritHead:setSkillTeam(index)
	self._ccbOwner.node_team:setVisible(false)
	self._ccbOwner.node_aid:setVisible(true)
	for i = 1, 4 do
		self._ccbOwner["sp_aid"..i]:setVisible(false)
	end
	if index == 0 then
		self._ccbOwner.node_aid:setVisible(false)
	else
		self._ccbOwner["sp_aid"..index]:setVisible(true)
	end
end

function QUIWidgetSoulSpiritHead:moveDownTeam(offsetY)
	if offsetY == nil then 
		offsetY = -15
	end
    local node = self._ccbOwner.node_team
    node:setPositionY(node:getPositionY() + offsetY)
    local node = self._ccbOwner.node_aid
    node:setPositionY(node:getPositionY() + offsetY)
end

function QUIWidgetSoulSpiritHead:_onTriggerClick()
	self:dispatchEvent({name = QUIWidgetSoulSpiritHead.EVENT_SOULSPIRIT_HEAD_CLICK, target = self})
end

function QUIWidgetSoulSpiritHead:getHeadSize()
	return self._size
end

function QUIWidgetSoulSpiritHead:getHeadSprite()
	return self._ccbOwner.sp_head
end

function QUIWidgetSoulSpiritHead:getNode()
	return self._ccbOwner.node_soulSpirit_headBox
end
function QUIWidgetSoulSpiritHead:showSabc()
	if not self._id then return end

	local aptitudeInfo = db:getActorSABC(self._id)
    q.setAptitudeShow(self._ccbOwner, aptitudeInfo.lower)

	-- if aptitudeInfo.lower == "a" or aptitudeInfo.lower == "a+" then
	-- 	self._ccbOwner["star_a"]:setVisible(true)
	-- elseif aptitudeInfo.lower == "s" then
	-- 	self._ccbOwner["star_s"]:setVisible(true)
	-- end

	self._ccbOwner.node_pingzhi:setVisible(true)
end

function QUIWidgetSoulSpiritHead:hideSabc()
	self._ccbOwner.node_pingzhi:setVisible(false)
end

function QUIWidgetSoulSpiritHead:showSabcWithoutStar()
	self:showSabc()
	self._ccbOwner["star_a"]:setVisible(false)
	self._ccbOwner["star_s"]:setVisible(false)
end

function QUIWidgetSoulSpiritHead:setHighlightedSelectState(state)
	if state == nil then state = false end
	self._ccbOwner.node_select:setVisible(state)
end

function QUIWidgetSoulSpiritHead:getContentSize()	
	return self._ccbOwner.sp_head:getContentSize()
end

function QUIWidgetSoulSpiritHead:_getSoulSpiritIcon()
	local soulSpiritIcon
	if self._characterConfig then
		soulSpiritIcon = self._characterConfig.icon
	end
	return soulSpiritIcon
end

return QUIWidgetSoulSpiritHead
