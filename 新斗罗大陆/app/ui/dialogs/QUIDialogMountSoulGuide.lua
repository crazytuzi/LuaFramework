-- @Author: zhouxiaoshu
-- @Date:   2019-10-23 12:04:22
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-10-28 14:49:01
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMountSoulGuide = class("QUIDialogMountSoulGuide", QUIDialog)
local QUIWidgetMountSkillAndTalent = import("..widgets.mount.QUIWidgetMountSkillAndTalent")
local QUIWidgetActorDisplay = import("..widgets.actorDisplay.QUIWidgetActorDisplay")
local QUIWidgetFcaAnimation = import("..widgets.actorDisplay.QUIWidgetFcaAnimation")
local QUIViewController = import("..QUIViewController")
local QActorProp = import("...models.QActorProp")
local QListView = import("...views.QListView")
local QQuickWay = import("...utils.QQuickWay")

-- 暗器装备魂师
function QUIDialogMountSoulGuide:ctor(options)
	local ccbFile = "ccb/Dialog_Weapon_soul_guide.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerGrade", callback = handler(self, self._onTriggerGrade)},
		{ccbCallbackName = "onTriggerSkillInfo", callback = handler(self, self._onTriggerSkillInfo)},
	}
	QUIDialogMountSoulGuide.super.ctor(self, ccbFile, callBacks, options)
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:setManyUIVisible()
    page.topBar:showWithMount()
	CalculateUIBgSize(self._ccbOwner.sp_bg)


    self._talentConfig = {}
	local configs = db:getStaticByName("soul_arms_science_tianfu")
	for i, v in pairs(configs) do
		if v.condition > 0 then
			table.insert(self._talentConfig, v)
		end
	end
    table.sort(self._talentConfig, function(a, b)
        return a.condition < b.condition
    end)

    self._superMountIds = remote.mount:getSuperMountIds()
	self._ccbOwner.tf_desc:setString("SS暗器和S暗器首次合成或者升星到每个星级时会获得科技点，S暗器每次1点，SS,SS+暗器每次2点。")
end

function QUIDialogMountSoulGuide:viewDidAppear()
	QUIDialogMountSoulGuide.super.viewDidAppear(self)
	self:addBackEvent(false)

	self:updateInfo()
end

function QUIDialogMountSoulGuide:viewWillDisappear()
	QUIDialogMountSoulGuide.super.viewWillDisappear(self)

	self:removeBackEvent()
end

function QUIDialogMountSoulGuide:updateInfo()
	self:updatePropInfo()
	self:updateAvatar()
	--self:initListView()
end

function QUIDialogMountSoulGuide:updatePropInfo()
	local gradeConfig = db:getSoulGuideConfigByLevel(1)
	local soulCount = remote.items:getItemsNumByID(gradeConfig.item_id)
	self._ccbOwner.tf_cur_count:setString("科技点："..soulCount)
	self._ccbOwner.sp_grade_tips:setVisible(false)

	self._soulGuideLevel = remote.user:getPropForKey("soulGuideLevel") or 0
	local oldConfig = db:getSoulGuideConfigByLevel(self._soulGuideLevel) or {}
	self._ccbOwner.tf_cur_title:setString(self._soulGuideLevel.."级属性")
	local index = 1
	index = self:setPropTF(index, "tf_cur_", "全队生命", oldConfig.team_hp_value or 0)
	index = self:setPropTF(index, "tf_cur_", "全队攻击", oldConfig.team_attack_value or 0)
	index = self:setPropTF(index, "tf_cur_", "全队物防", oldConfig.team_armor_physical or 0)
	index = self:setPropTF(index, "tf_cur_", "全队法防", oldConfig.team_armor_magic or 0)

	local newConfig = db:getSoulGuideConfigByLevel(self._soulGuideLevel+1)
	if newConfig ~= nil then
		self._ccbOwner.node_max_prop:setVisible(false)
		self._ccbOwner.node_max:setVisible(false)
		self._ccbOwner.node_normal:setVisible(true)
		self._ccbOwner.node_btn:setVisible(true)
		self._ccbOwner.tf_next_title:setString((self._soulGuideLevel+1).."级属性")
		self._ccbOwner.sp_grade_tips:setVisible(soulCount >= newConfig.num)
		self._ccbOwner.tf_cost:setString(newConfig.num)
		index = 1
		index = self:setPropTF(index, "tf_next_", "全队生命", newConfig.team_hp_value or 0, GAME_COLOR_SHADOW.property)
		index = self:setPropTF(index, "tf_next_", "全队攻击", newConfig.team_attack_value or 0, GAME_COLOR_SHADOW.property)
		index = self:setPropTF(index, "tf_next_", "全队物防", newConfig.team_armor_physical or 0, GAME_COLOR_SHADOW.property)
		index = self:setPropTF(index, "tf_next_", "全队法防", newConfig.team_armor_magic or 0, GAME_COLOR_SHADOW.property)
	else
		self._ccbOwner.node_max_prop:setVisible(true)
		self._ccbOwner.node_max:setVisible(true)
		self._ccbOwner.node_normal:setVisible(false)
		self._ccbOwner.node_btn:setVisible(false)
		index = 1
		index = self:setPropTF(index, "tf_max_", "全队生命", oldConfig.team_hp_value or 0)
		index = self:setPropTF(index, "tf_max_", "全队攻击", oldConfig.team_attack_value or 0)
		index = self:setPropTF(index, "tf_max_", "全队物防", oldConfig.team_armor_physical or 0)
		index = self:setPropTF(index, "tf_max_", "全队法防", oldConfig.team_armor_magic or 0)
	end

	self._ccbOwner.tf_cur_prop:setVisible(false)
	self._ccbOwner.tf_next_prop:setVisible(false)
	self._ccbOwner.tf_next_name:setVisible(false)

	local curTalentConfig = {}
	local nextTalentConfig = {}
	for i, value in pairs(self._talentConfig) do
        if value.condition > self._soulGuideLevel then
        	nextTalentConfig = value
            break
        end
        curTalentConfig = value
    end

    local propTbl = QActorProp:getPropUIByConfig(curTalentConfig)
	for key, prop in pairs(propTbl) do
		local value = prop.value
		if prop.isPercent then
			value = q.getFilteredNumberToString(value, true, 0)
		end
		if prop.value > 0 then
			self._ccbOwner.tf_cur_prop:setString("【"..curTalentConfig.master_name.."】".."全队攻击、双防、生命".."+"..value.."（科技升至"..curTalentConfig.condition.."级）")
			self._ccbOwner.tf_cur_prop:setVisible(true)
			break
		end
	end
    local propTbl = QActorProp:getPropUIByConfig(nextTalentConfig)
	for key, prop in pairs(propTbl) do
		local value = prop.value
		if prop.isPercent then
			value = q.getFilteredNumberToString(value, true, 0)
		end
		if prop.value > 0 then
			self._ccbOwner.tf_next_prop:setString("【"..nextTalentConfig.master_name.."】".."全队攻击、双防、生命".."+"..value.."（科技升至"..nextTalentConfig.condition.."级）")
			self._ccbOwner.tf_next_prop:setVisible(true)
			self._ccbOwner.tf_next_name:setVisible(true)
			break
		end
	end
end

function QUIDialogMountSoulGuide:setPropTF(index, tfNode, name, value, color)
	if index > 4 then return index end
	if value ~= nil then
		self._ccbOwner[tfNode.."name"..index]:setString(name)
		self._ccbOwner[tfNode.."value"..index]:setString(" +"..value)
		if color then
			self._ccbOwner["tf_next_value"..index]:setColor(color)
		end
	end
	return index + 1
end

function QUIDialogMountSoulGuide:setNodeCascadeOpacityEnabled( node )
    -- body
    if node then
        node:setCascadeOpacityEnabled(true)
        local children = node:getChildren()
        if children then
            for index = 0, children:count()-1, 1 do
                local tempNode = children:objectAtIndex(index)
                local tempNode = tolua.cast(tempNode, "CCNode")
                if tempNode then
                    self:setNodeCascadeOpacityEnabled(tempNode)
                end
            end
        end
    end
end

function QUIDialogMountSoulGuide:updateAvatar()
	if q.isEmpty(self._superMountIds) then
		self._ccbOwner.node_avatar:removeAllChildren()
		return
	end
    local index = math.random(#self._superMountIds)
    local mountId = self._superMountIds[index]
	self._avatar = QUIWidgetActorDisplay.new(mountId)
	self._avatar:setScale(1.8)
	self._ccbOwner.node_avatar:removeAllChildren()
	self._ccbOwner.node_avatar:addChild(self._avatar)
	self._ccbOwner.node_avatar:setOpacity(0)
	self._ccbOwner.node_avatar:setScaleX(-1)
	
	self:setNodeCascadeOpacityEnabled( self._ccbOwner.node_avatar )
	local arr = CCArray:create()
    arr:addObject(CCFadeIn:create(0.3))
    self._ccbOwner.node_avatar:runAction(CCSequence:create(arr))

    local soulGuidAni = QResPath("soul_guide_ani")
	local fcaAnimation = QUIWidgetFcaAnimation.new(soulGuidAni, "res")
	self._ccbOwner.node_fca_ani:removeAllChildren()
    self._ccbOwner.node_fca_ani:addChild(fcaAnimation)
    fcaAnimation:playAnimation("animation", false)
    fcaAnimation:setEndCallback(function( )
		local arr = CCArray:create()
    	arr:addObject(CCFadeOut:create(0.3))
	    arr:addObject(CCCallFunc:create(function()
        	self:updateAvatar()
		end))
	    self._ccbOwner.node_avatar:runAction(CCSequence:create(arr))
    end)
end

function QUIDialogMountSoulGuide:initListView()
	local talentIndex = 1
	for i, v in pairs(self._talentConfig) do
		if v.condition > self._soulGuideLevel then
			break
		end
		talentIndex = i
	end
    if not self._contentListView then
	    local cfg = {
	        renderItemCallBack = handler(self,self.renderFunHandler),
	        ignoreCanDrag = true,
	        totalNumber = #self._talentConfig,
	        enableShadow = false,
	        headIndex = talentIndex,
	    }  
	    self._contentListView = QListView.new(self._ccbOwner.sheet_layout, cfg)
	else
		self._contentListView:reload({totalNumber = #self._talentConfig, headIndex = talentIndex})
	end
end

function QUIDialogMountSoulGuide:renderFunHandler(list, index, info)
    local isCacheNode = true
    local preTalent = self._talentConfig[index-1]
    local talent = self._talentConfig[index]
    local item = list:getItemFromCache()

    if not item then
    	item = QUIWidgetMountSkillAndTalent.new()
        isCacheNode = false
    end

    info.item = item
	item:setSoulGuideTalentInfo(talent, talent.condition <= self._soulGuideLevel, preTalent)
    info.size = item:getContentSize()

	return isCacheNode
end

function QUIDialogMountSoulGuide:_onTriggerGrade(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_grade) == false then return end

	local nextGradeConfig = db:getSoulGuideConfigByLevel(self._soulGuideLevel+1)
	if nextGradeConfig == nil then
		app.tip:floatTip("已经到顶级")
		return
	end

	local soulCount = remote.items:getItemsNumByID(nextGradeConfig.item_id)
	if soulCount >= nextGradeConfig.num then
		remote.mount:mountSoulGuideLevelUpRequest(function()
			local callback = function()
				if self:safeCheck() then
					self:updateInfo()
				end
			end
			remote.mount:dispatchEvent({name = remote.mount.EVENT_REFRESH_FORCE})
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMountSoulGuideGradeSuccess",
				options = { callback = callback}}, {isPopCurrentDialog = false})
		end)
	else
		QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, nextGradeConfig.item_id)
	end
end

function QUIDialogMountSoulGuide:_onTriggerSkillInfo(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_skill_info) == false then return end
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMountSoulGuideTalent",
		options = {}}, {isPopCurrentDialog = false})
end

return QUIDialogMountSoulGuide