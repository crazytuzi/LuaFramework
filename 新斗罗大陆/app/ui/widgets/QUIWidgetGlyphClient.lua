--
-- Author: Kumo.Wang
-- Date: Wed Apr 27 18:37:27 2016
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetGlyphClient = class("QUIWidgetGlyphClient", QUIWidget)

local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIWidgetGlyphClientCell = import("..widgets.QUIWidgetGlyphClientCell")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QActorProp = import("...models.QActorProp")
local QRichText = import("...utils.QRichText")

QUIWidgetGlyphClient.UPDATE_HEIGHT = "QUIWIDGETGLYPGCLIENT.UPDATE_HEIGHT"

function QUIWidgetGlyphClient:ctor(options)
	local ccbFile = "ccb/Widget_DiaoWen_client.ccbi"
	local callBacks = {}
	QUIWidgetGlyphClient.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._gradeSkillIds = {}
	self._gradeSkills = {}
	self._aniPlayers = {}
	self._activedHeight = 0
	self._tf_explain_shadows = {}

	self._tf_explain = {}

	local i = 1
	while true do
		if self._ccbOwner["node_text_"..i] then
			local node = self._ccbOwner["node_text_"..i]
			-- node:removeAllChildren()
			local tf = QRichText.new()
			if i%2 == 0 then
				tf:setAnchorPoint(0, 0.5)
				tf:setPositionX(50)
			else
				tf:setAnchorPoint(0, 0.5)
				tf:setPositionX(50)
			end
			node:addChild(tf)
			self._tf_explain[i] = tf
		else
			break
		end
		i = i + 1
	end
end

function QUIWidgetGlyphClient:onEnter()
	self.userProxy = cc.EventProxy.new(remote.user)
    self.userProxy:addEventListener(remote.user.EVENT_GLYPH_LEVEL_UP, handler(self, self._onUserProxyEvent))
    self.userProxy:addEventListener(remote.user.EVENT_NEW_GLYPH, handler(self, self._onUserProxyEvent))
end

function QUIWidgetGlyphClient:_onUserProxyEvent( event )
	print("QUIWidgetGlyphClient:_onUserProxyEvent()", event.name, event.actorId, event.skillId, event.skillLevel)
	if event.name == remote.user.EVENT_GLYPH_LEVEL_UP then
		if event.actorId then
			self:setHero(event.actorId)
		end
	elseif event.name == remote.user.EVENT_NEW_GLYPH then
		if event.actorId then
			self:setHero(event.actorId, true)
		end
	end
end

function QUIWidgetGlyphClient:onExit()
	if self._performWithDelayGlobal then
		scheduler.unscheduleGlobal(self._performWithDelayGlobal)
		self._performWithDelayGlobal = nil
	end
	self.userProxy:removeAllEventListeners()
end

function QUIWidgetGlyphClient:getHeight()
	local max = self._ccbOwner.sp_bg_1:getContentSize().height + self._ccbOwner.sp_bg_2:getContentSize().height - 100
	if self._activedHeight > max then
		self._activedHeight = max
	end

	return self._activedHeight
end

function QUIWidgetGlyphClient:setHero( actorId, isInit )
	-- print("[Kumo] QUIWidgetGlyphClient:setHero() ", actorId, isInit)

	if not self._actorId or self._actorId ~= actorId or isInit then
		-- print("[Kumo] QUIWidgetGlyphClient:setHero() 1", actorId, isInit)
		self._actorId = actorId
		self:_initAllSkillByActorId()
	else
		-- print("[Kumo] QUIWidgetGlyphClient:setHero() 2", actorId, isInit)
		if self._gradeSkillIds and #self._gradeSkillIds > 0 and self._gradeSkills and #self._gradeSkills > 0 then
			-- print("[Kumo] QUIWidgetGlyphClient:setHero() 3")
    		self:_updateActivedSkillByActorId()
	    else
	    	-- print("[Kumo] QUIWidgetGlyphClient:setHero() 4")
	    	self:_initAllSkillByActorId()
	    end
	end
end

function QUIWidgetGlyphClient:_initAllSkillByActorId()
	local config = QStaticDatabase.sharedDatabase():getGradeByHeroId(self._actorId)
	-- 1星:  grade_level = 0
	local heroInfo = remote.herosUtil:getHeroByID(self._actorId)
	-- QPrintTable(heroInfo)
	if self._gradeSkills and table.nums(self._gradeSkills) > 0 then
		for _, skill in pairs(self._gradeSkills) do
			skill:removeFromParent()
		end
	end

	self._gradeSkillIds = {}
	self._gradeSkills = {}
	for _, value in pairs(config) do
		if value.glyph_id then
			local level = 1
			local isUnlock = false
			if heroInfo.glyphs then
				for _, glyph in pairs(heroInfo.glyphs) do
					if glyph.glyphId == value.glyph_id then
						if not glyph.level or glyph.level == 0 then
							level = 1
						else
							level = glyph.level
						end
						isUnlock = true
					end
				end
			end
			table.insert(self._gradeSkillIds, {["glyphId"] = value.glyph_id, ["glyphLevel"] = level, ["gradeLevel"] = value.grade_level, ["isActived"] = isUnlock})
		end
	end

	table.sort(self._gradeSkillIds, function(a,b) return a.gradeLevel < b.gradeLevel end )
	-- QPrintTable(self._gradeSkillIds)

	if #self._gradeSkillIds == 0 then return end

	local index = 1
	local isFirstLockSkill = true
	for _, value in pairs(self._gradeSkillIds) do
		local skillConfig = QStaticDatabase.sharedDatabase():getGlyphSkillByIdAndLevel(value.glyphId, value.glyphLevel or 1)
		local node = self._ccbOwner["node_skill_"..index]
		if node then
			local skill = QUIWidgetGlyphClientCell.new()
			if value.isActived or value.gradeLevel <= heroInfo.grade then
				--已解锁
				value.isActived = true
				skill:setSkill(value.glyphId, value.glyphLevel or 1)
				local str, tbl = self:_getExplainBySkillConfig(skillConfig, true)
				if self._tf_explain[index] then
					self._tf_explain[index]:setString(tbl)
				end
			else
				--未解锁
				value.isActived = false
				if isFirstLockSkill then
					if index <= 4 then
						self._activedHeight = math.abs(self._ccbOwner["node_skill_4"]:getPositionY()) + 80
					else
						self._activedHeight = math.abs(node:getPositionY()) + 80
					end
					self:dispatchEvent({name = QUIWidgetGlyphClient.UPDATE_HEIGHT})
				end
				skill:setSkill(value.glyphId, nil, value.gradeLevel, isFirstLockSkill)
				isFirstLockSkill = false
				local str, tbl = self:_getExplainBySkillConfig(skillConfig, false)
				if self._tf_explain[index] then
					self._tf_explain[index]:setString(tbl)
				end
			end
			skill:addEventListener(QUIWidgetGlyphClientCell.EVENT_CLICK, handler(self, self._onEvent))
			node:addChild(skill)
			table.insert(self._gradeSkills, skill)

			if value.isActived then
				if index == 1 then
					self:_showEffect(true)
				end
				if self._ccbOwner["line"..index] then
					self._ccbOwner["line"..index]:setVisible(true)
				end
				-- skill:showEffect()
				makeNodeFromGrayToNormal(node)
				skill:makeNameFromGrayToNormal()
			else
				if self._ccbOwner["line"..index] then
					self._ccbOwner["line"..index]:setVisible(false)
				end
				makeNodeFromNormalToGray(node)
				skill:makeNameFromNormalToGray()
			end
		end
		
		index = index + 1
	end

	if isFirstLockSkill then
		self._activedHeight = 9999999999999
		self:dispatchEvent({name = QUIWidgetGlyphClient.UPDATE_HEIGHT})
	end
end

function QUIWidgetGlyphClient:_updateActivedSkillByActorId()
	local heroInfo = remote.herosUtil:getHeroByID(self._actorId)
	-- QPrintTable(heroInfo)
	if not heroInfo or not heroInfo.glyphs or #heroInfo.glyphs == 0 then
		self:_initAllSkillByActorId()
		return
	end

	-- local config = QStaticDatabase.sharedDatabase():getGradeByHeroId(self._actorId)
	-- 1星:  grade_level = 0
	local index = 1
	for _, skill in pairs(self._gradeSkills) do
		for _, glyph in pairs(heroInfo.glyphs) do
			if glyph.glyphId == skill:getSkillId() then
				local level = 0
				if not glyph.level or glyph.level == 0 then
					level = 1
				else
					level = glyph.level
				end
				skill:updateSkillLevel( level )
				-- print("[Kumo] ", self._actorId, glyph.glyphId, index)
				if self._ccbOwner["line"..index] then
					self._ccbOwner["line"..index]:setVisible(true)
				end
				-- skill:showEffect()
				makeNodeFromGrayToNormal( skill:getParent() )
				skill:makeNameFromGrayToNormal()

				local skillConfig = QStaticDatabase.sharedDatabase():getGlyphSkillByIdAndLevel(glyph.glyphId, level)
				local str, tbl = self:_getExplainBySkillConfig(skillConfig,true)
				if self._tf_explain[index] then
					self._tf_explain[index]:setString(tbl)
				end
			end
		end
		index = index + 1
	end
end

function QUIWidgetGlyphClient:_showEffect( isNew )
	if isNew then
		self:_clearAniPlayer()
		self._curEffectIndex = 1
	end
	
	if not self._curEffectIndex then return end

	self._curEffectIndex = self._curEffectIndex + 1

	local tbl = nil
	if self._curEffectIndex < table.nums(self._gradeSkillIds) then
		tbl = self._gradeSkillIds[ self._curEffectIndex ]
	end

	if tbl and tbl.isActived then
		local ccbFile = ""
		local _, num = math.modf( self._curEffectIndex / 2 )
		if num == 0 then
			ccbFile = "ccb/effects/diaowen_effect_shanguang2.ccbi"
		else
			ccbFile = "ccb/effects/diaowen_effect_shanguang.ccbi"
		end
	    local aniPlayer = QUIWidgetAnimationPlayer.new()
	    -- aniPlayer:setParent(self._ccbOwner["node_skill_"..self._curEffectIndex])
	    self._ccbOwner["node_skill_"..self._curEffectIndex]:addChild(aniPlayer)
	    aniPlayer:playAnimation(ccbFile, nil, function ()
	    	self:_showEffect()
	    end)
	    table.insert(self._aniPlayers, aniPlayer)
	else
		self._curEffectIndex = 0
		self._performWithDelayGlobal = scheduler.performWithDelayGlobal(function ()
			self:_clearAniPlayer()
			self:_showEffect()
		end, 1)
		return
	end
end

function QUIWidgetGlyphClient:_clearAniPlayer()
	if self._performWithDelayGlobal then
		scheduler.unscheduleGlobal(self._performWithDelayGlobal)
		self._performWithDelayGlobal = nil
	end
	if not self._aniPlayers or table.nums(self._aniPlayers) == 0 then return end

	for _, player in pairs(self._aniPlayers) do
		player:removeFromParent()
		player:onExit()
	end

	self._aniPlayers = {}
end

function QUIWidgetGlyphClient:_getExplainBySkillConfig(skillLevelConfig, isActived)
	local tbl = {}
	local str = ""
	local tblStr = {}
	local colorName = isActived and COLORS.j or COLORS.n
	local colorValue = isActived and COLORS.l or COLORS.n
	-- local findMagicKey = 0
	-- local findPhysicsKey = 0
	for name, filed in pairs(QActorProp._field) do
		if skillLevelConfig[name] then
			-- print("[Kumo] QUIWidgetGlyphClient:_getExplainBySkillConfig() ", name, skillLevelConfig[name], skillLevelConfig.glyph_level, skillLevelConfig.glyph_name)
			local strName = filed.name
			-- print(strName)
			-- if string.find(strName, "魔法") then
				-- findMagicKey = findMagicKey + 1
			strName = string.gsub(strName, "法术", "")
			strName = string.gsub(strName, "法防", "防御")
			strName = string.gsub(strName, "全队PVP", "PVP")
			-- end
			-- if string.find(strName, "物理") then
				-- findPhysicsKey = findPhysicsKey + 1
			strName = string.gsub(strName, "物理", "")
			strName = string.gsub(strName, "物防", "防御")
			-- end
			strName = string.gsub(strName, "百分比", "")
			-- print(strName)
			local strNum = tostring(skillLevelConfig[name])
			-- print(string.find(strNum, "%."))
			if string.find(strNum, "%.") then
				-- 数据是百分比
				strNum = (skillLevelConfig[name] * 100).."%"
			end

			-- 防止重复，同时，让类似魔法防御和物理防御这样的成对属性合并成防御属性
			local isNew = true
			for _, value in pairs(tbl) do
				-- print("[Kumo] QUIWidgetGlyphClient:_getExplainBySkillConfig() ", value, strName, strNum, string.len(strName))
				if string.len(strName) < 12 then
					-- 不换行
					if value == strName.." + "..strNum then
						-- print("==================> isNew = false")
						isNew = false
					end
				else
					-- 换行
					if value == strName.."\n + "..strNum then
						-- print("==================> isNew = false")
						isNew = false
					end
				end
			end

			if isNew then
				table.insert(tblStr, {oType = "font", content = strName, size = 20, color = colorName})
				table.insert(tblStr, {oType = "font", content = " + "..strNum, size = 20, color = colorValue})
				table.insert(tblStr, {oType = "wrap"})
				if string.len(strName) < 12 then
					-- 不换行
					table.insert(tbl, strName.." + "..strNum)
				else
					-- 换行
					table.insert(tbl, strName.."\n + "..strNum)
				end
			end
		end
	end

	for index, value in pairs(tbl) do
		if index == #tbl then
			str = str..value
			break
		end
		str = str..value.."\n"
	end

	-- return tbl
	return str, tblStr
end

function QUIWidgetGlyphClient:_onEvent( event )
	self:dispatchEvent( {name = event.name, skillId = event.skillId, skillLevel = event.skillLevel, actorId = self._actorId} )
end

return QUIWidgetGlyphClient