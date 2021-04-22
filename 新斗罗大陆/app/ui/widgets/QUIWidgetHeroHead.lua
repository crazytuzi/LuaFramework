
local QUIWidget = import(".QUIWidget")
local QUIWidgetHeroHead = class("QUIWidgetHeroHead", QUIWidget)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetHeroHeadStar = import(".QUIWidgetHeroHeadStar")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QCircleUiMask = import("..battle.QCircleUiMask")
local QUIWidgetHeroProfessionalIcon = import("..widgets.QUIWidgetHeroProfessionalIcon")

QUIWidgetHeroHead.EVENT_HERO_HEAD_CLICK = "EVENT_HERO_HEAD_CLICK"

function QUIWidgetHeroHead:ctor(options)
	local ccbFile = "ccb/Widget_HeroHeadBox.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerTouch", callback = handler(self, QUIWidgetHeroHead._onTriggerTouch)},
	}
	QUIWidgetHeroHead.super.ctor(self,ccbFile,callBacks,options)
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._ccbOwner.node_hp:setVisible(false)
    self._ccbOwner.node_mp:setVisible(false)

    self._initTotalHpScaleX = self._ccbOwner.hp:getScaleX()
    self._initTotalMpScaleX = self._ccbOwner.mp:getScaleX()
    self._initIconSize = self._ccbOwner.node_hero_image:getContentSize()

    self:resetAll()
end
 
function QUIWidgetHeroHead:initGLLayer(glLayerIndex)
	self._glLayerIndex = glLayerIndex or 1
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sprite_back, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_hero_image, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_level_bg, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_hero_level, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_god_bg, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_god_skill, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_inherit_bg, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_inherit, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_break, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_soul_frame, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_hero_star, self._glLayerIndex)
	if self._star then
		self._glLayerIndex = self._star:initGLLayer(self._glLayerIndex)
	end
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sprite_buleplus, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.can_breakthrough, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.breakthrough_tips, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_use_bg1, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_use_bg2, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_use, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.high_light, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_select, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_team6, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_team5, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_team4, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_team3, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_team2, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_team1, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_alternate3, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_alternate2, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_alternate1, self._glLayerIndex) 
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_godarm_team4, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_godarm_team3, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_godarm_team2, self._glLayerIndex) 	
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_godarm_team1, self._glLayerIndex) 		
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_boss, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.professionalNode, self._glLayerIndex)
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
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner["pingzhi_ss+"], self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner["star_ss+"], self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_light_s1, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_light_s2, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_light_s3, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_light_s4, self._glLayerIndex)

	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_godarm_label, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_hp_bg, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.hp, self._glLayerIndex)--
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.mp_hp_bg, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.mp, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_dead_mask, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_dead, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_setting_select, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_setting_use, self._glLayerIndex)
	self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_state, self._glLayerIndex)

	return self._glLayerIndex
end

function QUIWidgetHeroHead:setHeadScale(v)
	self:getView():setScale(v)
end

function QUIWidgetHeroHead:getHeroId()
	return self._actorId
end

function QUIWidgetHeroHead:resetAll()
	self._ccbOwner.otherParentNode:removeAllChildren()
	self._ccbOwner.professionalNode:setVisible(false)
	self._ccbOwner.node_hero_image:setVisible(false)
	self._ccbOwner.node_hero_star:setVisible(false)
	self._ccbOwner.tf_hero_level:setString("")
  	self._ccbOwner.blue_plus:setVisible(false)
  	self._ccbOwner.node_dead:setVisible(false)
  	self._ccbOwner.sp_break:setVisible(false)
	self._ccbOwner.sp_soul_frame:setVisible(false)
	self._ccbOwner.node_god_skill:setVisible(false)
	self._ccbOwner.node_inherit:setVisible(false)
	self._ccbOwner.node_godarm_label:setVisible(false)

	self:setLevelVisible(false)
	self:setCanBreakthrough(false)
	self:setHighlightedSelectState(false)
	self:setTeam(0)
	self:hideSabc()
	self:setBreakthrough()
	self._actorId = nil
	self._isSoulSpirit = false
	self._isMount = false
	self._param = nil
	self._isGodarm = false
end

function QUIWidgetHeroHead:setUnKnowHero( unknowType, team )
	-- body
	self:resetAll()
	self._tempOwner = {}
	local node = CCBuilderReaderLoad("ccb/Widget_ArenaPrompt.ccbi", CCBProxy:create(), self._tempOwner)

	self._unknowType = unknowType
	self._team = team
	self._ccbOwner.otherParentNode:addChild(node)
	if unknowType == 0 then
		self._tempOwner.emptyHero:setVisible(false)
		self._tempOwner.unknow:setVisible(true)
		self._ccbOwner.sp_break:setVisible(true)
	elseif unknowType == 1 then
		self._tempOwner.emptyHero:setVisible(true)
		self._tempOwner.unknow:setVisible(false)
		self._ccbOwner.sp_break:setVisible(true)
	else
		self._tempOwner.emptyHero:setVisible(false)
		self._tempOwner.unknow:setVisible(false)	
	end

	for i = 1,3 do
		if team == i then
			self._tempOwner["st_team"..i]:setVisible(true)
		else
			self._tempOwner["st_team"..i]:setVisible(false)
		end
	end
end

function QUIWidgetHeroHead:getHeroType()
	return self._unknowType
end


function QUIWidgetHeroHead:setParam(param)
	self._param = param
end

function QUIWidgetHeroHead:getParam()
	return self._param
end

function QUIWidgetHeroHead:setHeroInfo(heroInfo)
	self._heroInfo = heroInfo
	self._actorId = heroInfo.actorId or heroInfo.id

	if heroInfo.skinId then
		self:setHeroSkinId(heroInfo.skinId)
	end
	-- 设置魂师头像
	local heroIcon = self:getHeroIcon()
	if heroIcon then
		local headImageTexture = CCTextureCache:sharedTextureCache():addImage(heroIcon)
		self._ccbOwner.node_hero_image:setTexture(headImageTexture)
	    self._size = headImageTexture:getContentSize()
	   	local rect = CCRectMake(0, 0, self._size.width, self._size.height)
	   	self._ccbOwner.node_hero_image:setTextureRect(rect)
		self._ccbOwner.node_hero_image:setVisible(true)
		self._ccbOwner.node_hero_image:setScaleX(self._initIconSize.width/self._size.width)
		self._ccbOwner.node_hero_image:setScaleY(self._initIconSize.height/self._size.height)
	end

	self:setLevel(heroInfo.level or 0)
	self:setStar(heroInfo.grade or 0)
	self:showSabcWithoutStar()

	self._isSoulSpirit = false
	self._isGodarm = false
	self._isMount = false
	local characher = db:getCharacterByID(self._actorId)
	if characher.npc_type == 1 then
		local breakthrough = (heroInfo and heroInfo.breakthrough) or 0
		local godSkillGrade = (heroInfo and heroInfo.godSkillGrade) or 0
		self:setBreakthrough(breakthrough)		
		self:setGodSkillShowLevel(godSkillGrade)
	    local profession = characher.func or "dps"
	    self:setProfession(profession)
	elseif characher.npc_type == 3 then
		self._isMount = true
	elseif characher.npc_type == 4 then
		self._isSoulSpirit = true
		self:setSoulSpiritFrame()
		local inheritLv = (heroInfo and heroInfo.devour_level) or 0
		self:setInherit(inheritLv)
	elseif characher.npc_type == 5 then
		self._isGodarm = true
	end
end

function QUIWidgetHeroHead:setHero(actorId, level, index, upcoming)
	self._actorId = actorId
	self._index = index

	if upcoming then
		self:setHeroByFile(1, "icon/head/sp_shenmihunshi.jpg", 1)
		return 
	end

	-- print("actorId=",actorId)
	-- print("level=",level)
	local heroIcon = self:getHeroIcon()
	if heroIcon ~= nil then
		local headImageTexture =CCTextureCache:sharedTextureCache():addImage(heroIcon)
		if headImageTexture then
			self._ccbOwner.node_hero_image:setTexture(headImageTexture)
			self._size = headImageTexture:getContentSize()
			local rect = CCRectMake(0, 0, self._size.width, self._size.height)
			self._ccbOwner.node_hero_image:setTextureRect(rect)
			self._ccbOwner.node_hero_image:setVisible(true)
			self._ccbOwner.node_hero_image:setScaleX(self._initIconSize.width/self._size.width)
			self._ccbOwner.node_hero_image:setScaleY(self._initIconSize.height/self._size.height)
		end
	end
	 
	self:setLevel(level)

	self._isSoulSpirit = false
	self._isMount = false
	local characher = db:getCharacterByID(self._actorId)
	if characher.npc_type == 1 then
		local heroInfo = remote.herosUtil:getHeroByID(self._actorId)
		local breakthrough = (heroInfo and heroInfo.breakthrough) or 0
		local godSkillGrade = (heroInfo and heroInfo.godSkillGrade) or 0
		self:setBreakthrough(breakthrough)	
		self:setGodSkillShowLevel(godSkillGrade)
	elseif characher.npc_type == 3 then
		self._isMount = true
	elseif characher.npc_type == 4 then
		self._isSoulSpirit = true
		self:setSoulSpiritFrame()
		local soulSpirit = remote.soulSpirit:getMySoulSpiritInfoById(self._actorId)           
		local inheritLv = (soulSpirit and soulSpirit.devour_level) or 0
		self:setInherit(inheritLv)	
				
	elseif characher.npc_type == 5 then
		self._isGodarm = true	
		self:showGodarmLable(self._actorId)	
	else
		self:setGodSkillShowLevel(0)
	end
end

function QUIWidgetHeroHead:getIsSoulSpirit()
	return self._isSoulSpirit
end

function QUIWidgetHeroHead:getIsMount()
	return self._isMount
end

function QUIWidgetHeroHead:getIsGodarm()
	return self._isGodarm
end

function QUIWidgetHeroHead:showGodarmLable(id )
	self._ccbOwner.node_godarm_label:setVisible(true)
	local godarmConfig = db:getCharacterByID(id)
	if godarmConfig then
		local jobIconPath = remote.godarm:getGodarmJobPath(godarmConfig.label)
		if jobIconPath then
			QSetDisplaySpriteByPath(self._ccbOwner.sp_godarm_label,jobIconPath)
		end
	end
end
function QUIWidgetHeroHead:setDead(dead)
	self._ccbOwner.node_dead:setVisible(dead and true or false)
end

function QUIWidgetHeroHead:setInherit(inherit)
	if inherit <= 0 then
		return
	end
	self._ccbOwner.node_inherit:setVisible(true)
   
    local frame =QSpriteFrameByPath(QResPath("soul_spirit_chuan_sp")[tonumber(inherit)])
    if frame then
    	self._ccbOwner.sp_inherit:setVisible(true)
        self._ccbOwner.sp_inherit:setDisplayFrame(frame)
    end
end

-- Set hero avatar by file name @qinyuanji
function QUIWidgetHeroHead:setHeroByFile(index, avatarFile, scale)
	-- 设置魂师头像
	if avatarFile ~= nil and index ~= nil then
		self._index = index
		self._avatarFile = avatarFile
		local headImageTexture =CCTextureCache:sharedTextureCache():addImage(avatarFile)
		if headImageTexture then
			self._ccbOwner.node_hero_image:setTexture(headImageTexture)
			self._ccbOwner.node_hero_image:setScale(scale or 1)
		    self._size = headImageTexture:getContentSize()
		    local rect = CCRectMake(0, 0, self._size.width, self._size.height)
		    self._ccbOwner.node_hero_image:setTextureRect(rect)
			self._ccbOwner.node_hero_image:setVisible(true)
		end
	end
end


-- Add lock icon @qinyuanji
function QUIWidgetHeroHead:addLockedIcon(visible)
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

-- Add profession @qinyuanji
function QUIWidgetHeroHead:setProfession(profession, iconScale)
	self._ccbOwner.professionalNode:setVisible(profession ~= nil)

    if self._professionalIcon == nil then 
	    self._professionalIcon = QUIWidgetHeroProfessionalIcon.new()
	    self._ccbOwner.professionalNode:addChild(self._professionalIcon)
	end
    self._professionalIcon:setHero(self._actorId, nil, iconScale)
end

function QUIWidgetHeroHead:setProfessionByType(type_, iconScale)
	self._ccbOwner.professionalNode:setVisible(type_ ~= nil)

    if self._professionalIcon == nil then 
	    self._professionalIcon = QUIWidgetHeroProfessionalIcon.new()
	    self._ccbOwner.professionalNode:addChild(self._professionalIcon)
	end
    self._professionalIcon:setType(type_, nil, iconScale)
end


--[[
	设置等级显示
]]
function QUIWidgetHeroHead:setLevel(level)
	if level ~= nil and tonumber(level) > 0 then
    	self:setLevelVisible(true)
		self._ccbOwner.tf_hero_level:setString(tostring(level))
	else
		self:setLevelVisible(false)
	end
end

--[[
	设置进阶显示
]]
function QUIWidgetHeroHead:setStar(grade, isShowEffect)
    if self._star == nil then
    	self._star = QUIWidgetHeroHeadStar.new({})
    	self._ccbOwner.node_hero_star:addChild(self._star:getView())
    end
    local characher = db:getCharacterByID(self._actorId)
   	if  characher.npc_type == 4 and  characher.aptitude == APTITUDE.SS then
		if grade == 0 then
			print("setEmptyStar")
    		self._star:setEmptyStar()
    	else
    		self._star:setStar((grade or 1) , isShowEffect)
    	end
    else
    	self._star:setStar((grade or 0) + 1, isShowEffect)
   	end
	self._ccbOwner.node_hero_star:setVisible(true)
end

--[[
	设置突破显示
]]
function QUIWidgetHeroHead:setBreakthrough(breakLevel)
	self._ccbOwner.sp_soul_frame:setVisible(false)
	self:setContentVisible(true)
	local iconPath
	if breakLevel then
		iconPath = QResPath("head_rect_frame")[breakLevel+1]
	end
	if not iconPath then
		iconPath = QResPath("head_rect_frame_normal")
	end
	local texture = CCTextureCache:sharedTextureCache():addImage(iconPath)
	if texture then
		self._ccbOwner.sp_break:setVisible(true)
		self._ccbOwner.sp_break:setTexture(texture)
	else
		self._ccbOwner.sp_break:setVisible(false)
	end
end

-- 魂灵框
function QUIWidgetHeroHead:setSoulSpiritFrame()
	self._ccbOwner.sp_break:setVisible(false)
	self:setContentVisible(false)
	local color = remote.soulSpirit:getColorByCharacherId(self._actorId)
    local color = string.lower(color)
    local pathList = QResPath("soulSpirit_frame_"..color)
    if pathList then
        local texture = CCTextureCache:sharedTextureCache():addImage(pathList[1])
		if texture then
			self._ccbOwner.sp_soul_frame:setVisible(true)
			self._ccbOwner.sp_soul_frame:setTexture(texture)
		else
			self._ccbOwner.sp_soul_frame:setVisible(false)
		end
    end
end

function QUIWidgetHeroHead:boundingBox( )
	local scalex = self:getScaleX() or 1
	local scaley = self:getScaleY() or 1
	local size = self._ccbOwner.sprite_back:getContentSize()
	return { origin={x = 0, y = 0}, size = {width = size.width * scalex, height = size.height * scaley}}
end

function QUIWidgetHeroHead:setContentVisible(v)
	self._ccbOwner.sprite_back:setVisible(v)
end

function QUIWidgetHeroHead:setContentScale(v)
	self._ccbOwner.sprite_back:setScale(v)
end

function QUIWidgetHeroHead:setStarVisible(v)
	self._ccbOwner.node_hero_star:setVisible(v)
end

--设置等级是否显示
function QUIWidgetHeroHead:setLevelVisible(b)
	self._ccbOwner.node_level:setVisible(b)
end 

function QUIWidgetHeroHead:setTouchEnabled(b)
	self._ccbOwner.btn_touch:setTouchEnabled(b)
end

function QUIWidgetHeroHead:setPlus(state)
  	self._ccbOwner.blue_plus:setVisible(state)
end

-- index: 0 - no sign, 1 - main, 2 - helper, 3 - helper1, 4 - helper2, 5 - helper3
-- isSoul 是否魂灵
-- isAlternate 是否替补
function QUIWidgetHeroHead:setTeam(index, isSoul, isAlternate,isGodarm)
	self._ccbOwner.node_team:setVisible(true)
	self._ccbOwner.node_aid:setVisible(false)
	self._ccbOwner.sp_team_soul:setVisible(false)
	for i = 1, 5 do
		if self._ccbOwner["sp_alternate"..i] then
			self._ccbOwner["sp_alternate"..i]:setVisible(false)
		end
		self._ccbOwner["sp_team"..i]:setVisible(false)
	end
	-- 魂灵
	if isSoul then
		self._ccbOwner.sp_team_soul:setVisible(true)
	elseif isAlternate then
		if self._ccbOwner["sp_alternate"..index] then
			self._ccbOwner["sp_alternate"..index]:setVisible(true)
		end
	elseif isGodarm then
		if self._ccbOwner["sp_godarm_team"..index] then
			self._ccbOwner["sp_godarm_team"..index]:setVisible(true)
		end		
	elseif index == 0 then
		self._ccbOwner.node_team:setVisible(false)
	else
		if self._ccbOwner["sp_team"..index] then
			self._ccbOwner["sp_team"..index]:setVisible(true)
		end
	end
end

-- index: 0 - no sign, 1 - skill1, 2 - skill2, 3 - skill3, 4 - skill4
function QUIWidgetHeroHead:setSkillTeam(index)
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

function QUIWidgetHeroHead:moveDownTeam(offsetY)
	if offsetY == nil then 
		offsetY = -15
	end
    local node = self._ccbOwner.node_team
    node:setPositionY(node:getPositionY() + offsetY)
    local node = self._ccbOwner.node_aid
    node:setPositionY(node:getPositionY() + offsetY)
end

--设置魂师可以突破
function QUIWidgetHeroHead:setCanBreakthrough(state)
	self._ccbOwner.can_breakthrough:setVisible(state)
	if self._breakthrough == nil and state == true then
		self._breakthrough = QUIWidget.new("ccb/effects/kejinhua.ccbi")
		self._ccbOwner.breakthrough_tips:addChild(self._breakthrough)
		self._canBreakthrough = QUIWidget.new("ccb/effects/fumo.ccbi")
		self._ccbOwner.can_breakthrough:addChild(self._canBreakthrough)
	elseif self._breakthrough ~= nil and state == false then
		self._breakthrough:removeFromParent()
		self._breakthrough = nil
		self._canBreakthrough:removeFromParent()
		self._canBreakthrough = nil
	end
end

function QUIWidgetHeroHead:showBattleForce()
	-- self._ccbOwner.node_hero_battleForce:setVisible(true)
end

function QUIWidgetHeroHead:getHeroActorID()
	return self._actorId
end

function QUIWidgetHeroHead:_onTriggerTouch()
	self:dispatchEvent({name = QUIWidgetHeroHead.EVENT_HERO_HEAD_CLICK, target = self})
end

function QUIWidgetHeroHead:setEnabled(b)
	-- self._ccbOwner.btn_touch:setEnabled(b)
end

--@qinyuanji
function QUIWidgetHeroHead:getHeroHeadSize()
	return self._size
end

function QUIWidgetHeroHead:getHeroSprite()
	return self._ccbOwner.node_hero_image
end

function QUIWidgetHeroHead:getNode()
	return self._ccbOwner.node_heroHead
end
function QUIWidgetHeroHead:showSabc()
	if not self._actorId then return end

	local aptitudeInfo = db:getActorSABC(self._actorId)
	if aptitudeInfo then
	    q.setAptitudeShow(self._ccbOwner, aptitudeInfo.lower)

		-- if aptitudeInfo.lower == "a" or aptitudeInfo.lower == "a+" then
		-- 	self._ccbOwner["star_a"]:setVisible(true)
		-- elseif aptitudeInfo.lower == "s" then
		-- 	self._ccbOwner["star_s"]:setVisible(true)
		-- end

		self._ccbOwner.node_pingzhi:setVisible(true)
	end
end

function QUIWidgetHeroHead:hideSabc()
	self._ccbOwner.node_pingzhi:setVisible(false)
end

function QUIWidgetHeroHead:showHeroFramByAptitude()
	if not self._actorId then return end
	self._ccbOwner.sp_break:setVisible(false)
end

function QUIWidgetHeroHead:showSabcWithoutStar()
	self:showSabc()
	self._ccbOwner["star_a"]:setVisible(false)
	self._ccbOwner["star_s"]:setVisible(false)
end

function QUIWidgetHeroHead:setHp( curHp, maxHp )
	self._ccbOwner.node_hp:setVisible(true)
    
	if not curHp then
		self._ccbOwner.hp:setScaleX( self._initTotalHpScaleX )
		return
	end
	if maxHp <= 0 then
		maxHp = 1
	end

	if curHp == 0 then
		self._ccbOwner.hp:setScaleX(0)
	else
		local sx = math.min(1, curHp / maxHp) * self._initTotalHpScaleX
		self._ccbOwner.hp:setScaleX( sx )
	end
end

function QUIWidgetHeroHead:setMp( curMp, maxMp )
	self._ccbOwner.node_mp:setVisible(true)
	
	if not curMp then
		self._ccbOwner.mp:setScaleX( self._initTotalMpScaleX )
		return
	end

	if curMp == 0 then
		self._ccbOwner.mp:setScaleX(0)
	else
		local sx = curMp / maxMp * self._initTotalMpScaleX
		self._ccbOwner.mp:setScaleX( sx )
	end
end

function QUIWidgetHeroHead:setHighlightedSelectState(state)
	if state == nil then state = false end
	self._ccbOwner.head_effect:setVisible(state)
end

function QUIWidgetHeroHead:setUseState(state)	
	if state == nil then state = false end
--	self._ccbOwner.is_use:setVisible(state)
end

function QUIWidgetHeroHead:getContentSize()	
	return self._ccbOwner.sprite_back:getContentSize()
end

function QUIWidgetHeroHead:setHeroSkinId(skinId)	
	self._skinId = skinId
end

function QUIWidgetHeroHead:getHeroSkinId()	
	return self._skinId
end

function QUIWidgetHeroHead:getHeroIcon()
	local heroIcon
	local skinId = self._skinId
	if skinId == nil and q.isEmpty(self._heroInfo) == false then
		skinId = self._heroInfo.skinId
	end

	if skinId and skinId ~= 0 then
		local skinInfo = remote.heroSkin:getHeroSkinBySkinId(self._actorId, skinId)
		if skinInfo then
			heroIcon = skinInfo.skins_head_icon
		else
			local characher = db:getCharacterByID(self._actorId)
			heroIcon = characher.icon
		end
	else
		local characher = db:getCharacterByID(self._actorId)
		heroIcon = characher.icon
	end

	return heroIcon
end

function QUIWidgetHeroHead:setGodSkillShowLevel(realLevel)	
	self._ccbOwner.node_god_skill:setVisible(false)
	local showLevel = remote.herosUtil:getGodSkillLevelByActorId(self._actorId, realLevel)
	if showLevel == -1 then
		return
	end
	local path = nil
	if showLevel == 0 then
		path = QResPath("god_skill_0")
	else
		path = QResPath("god_skill")[showLevel]
	end
	
	local texture = CCTextureCache:sharedTextureCache():addImage(path)
	if texture then
		self._ccbOwner.node_god_skill:setVisible(true)
		self._ccbOwner.sp_god_skill:setTexture(texture)
	end
end

return QUIWidgetHeroHead
