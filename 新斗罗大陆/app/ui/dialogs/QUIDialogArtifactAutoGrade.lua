
-- 武魂真身一键升级面板

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogArtifactAutoGrade = class("QUIDialogArtifactAutoGrade", QUIDialog)
local QUIWidgetEquipmentAvatar = import("...widgets.QUIWidgetEquipmentAvatar")
local QUIWidgetItemsBox = import("...widgets.QUIWidgetItemsBox")

local QUIViewController = import("...QUIViewController")
local QNavigationController = import("..controllers.QNavigationController")

-- 进入此页面给的options参数必定是合法的 所以此页面不做值判断
function QUIDialogArtifactAutoGrade:ctor(options)
	local ccbFile = "ccb/Dialog_Artifact_Auto_Grade.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerAutoAdd", callback = handler(self, self._onTriggerAutoAdd)},
	}
	QUIDialogArtifactAutoGrade.super.ctor(self,ccbFile,callBacks,options)

	q.setButtonEnableShadow(self._ccbOwner.btn_auto_add)
	q.setButtonEnableShadow(self._ccbOwner.btn_close)

	self.isAnimation = true
	self._ccbOwner.frame_tf_title:setString("一键升星")

	self._actorId = options.actorId
	self._artifactId = options.artifactId
	self._callback = options.callback
	self._isCombine = options.isCombine or false

	self._grade = options.curGrade or 0
	self._nextGrade = self._grade + options.autoAddInfo.addGrade or 0

	self._needMoney = options.autoAddInfo.needMoney or 0
	self._needItems = {}

	for itemId, needCount in pairs(options.autoAddInfo.needItems) do
		table.insert(self._needItems, { itemId = itemId, needCount = needCount })
	end
	table.sort(self._needItems, function(a, b)
		return tonumber(a.itemId) < tonumber(b.itemId)
	end)

	if self._nextGrade > self._grade then
		self:_init()
	end
end



----------------------------------------
---私有部分

-- 设置图标和属性
function QUIDialogArtifactAutoGrade:_setAvatar(index, grade)
	local itemAvatar = self["_itemAvatar" .. index]
	if not itemAvatar then
		self["_itemAvatar" .. index] = QUIWidgetEquipmentAvatar.new()
		itemAvatar = self["_itemAvatar" .. index]
		self._ccbOwner["node_artifact" .. index]:addChild(itemAvatar)
	end
	itemAvatar:setArtifactInfo(self._actorId, grade, true)
	local gradeConfig = remote.artifact:getGradeByArtifactLevel(self._artifactId, grade)
	local props = remote.artifact:getUIPropInfo(gradeConfig)
	local propIndex = 1
	if q.isEmpty(props) then
		local nextGradeConfig = remote.artifact:getGradeByArtifactLevel(self._artifactId, grade + 1)
		local nextProps = remote.artifact:getUIPropInfo(nextGradeConfig)
		for i, prop in ipairs(nextProps) do
			if self._ccbOwner["tf_" .. index .. "_name"..propIndex] then
				self._ccbOwner["tf_" .. index .. "_name"..propIndex]:setString(prop.name)
				self._ccbOwner["tf_" .. index .. "_value"..propIndex]:setString("+0")
			end
			propIndex = propIndex + 1
		end
	else
		for i, prop in ipairs(props) do
			if self._ccbOwner["tf_" .. index .. "_name"..propIndex] then
				self._ccbOwner["tf_" .. index .. "_name"..propIndex]:setString(prop.name)
				self._ccbOwner["tf_" .. index .. "_value"..propIndex]:setString("+"..prop.value)
			end
			propIndex = propIndex + 1
		end
	end
end

-- 设置所需道具
function QUIDialogArtifactAutoGrade:_setItemBox(index, itemId, needCount)
	local itemBox = self["_itemBox" .. index]
	if not itemBox then
		self["_itemBox" .. index] = QUIWidgetItemsBox.new()
		itemBox = self["_itemBox" .. index]
		self._ccbOwner["node_item_" .. index]:addChild(itemBox)
		itemBox:hideSabc()
	end

	local isShow = (needCount > 0)
	itemBox:setVisible(isShow)
	if not isShow then
		return
	end

	local itemCount = remote.items:getItemsNumByID(itemId)
	itemBox:setGoodsInfo(itemId, ITEM_TYPE.ITEM, itemCount)
	itemBox:setItemCount(string.format("%d/%d", itemCount, needCount))
end

-- 初始化
function QUIDialogArtifactAutoGrade:_init()
	self:_setAvatar(1, self._grade)
	self:_setAvatar(2, self._nextGrade)
	
	for index, needInfo in ipairs(self._needItems) do
		self:_setItemBox(index, needInfo.itemId, needInfo.needCount)
	end

	self._ccbOwner.tf_skill_point:setString(string.format("累计天赋点数：%d→%d", self._grade, self._nextGrade))
	self._ccbOwner.tf_gold_price:setString(self._needMoney)
end



----------------------------------------
---交互回调部分

-- 关闭按钮
function QUIDialogArtifactAutoGrade:_onTriggerClose(event)
	app.sound:playSound("common_close")
	self:playEffectOut()
end

-- 一键升星被点击
function QUIDialogArtifactAutoGrade:_onTriggerAutoAdd(event)
	app.sound:playSound("common_close")

	if self._isCombine then
		remote.artifact:artifactCombineRequest(self._actorId, true, function ()
			if self._callback then
				self._callback()
			end

			local skillConfig = db:getConfigurationValue("artifact_skill_auto")
			skillConfig = string.split(skillConfig, ",")
			local learnSkill = 0
			for _, val in ipairs(skillConfig) do
				local valNum = tonumber(val)
				if valNum <= self._nextGrade then
					learnSkill = valNum
				end
			end

			app:getNavigationManager():pushViewController(app.middleLayer, {
				uiType = QUIViewController.TYPE_DIALOG, 
				uiClass = "QUIDialogArtifactGradeUpSuccess",
				options = { 
					actorId = self._actorId, 
					oldGradeLevel = 1, -- 因为是在未觉醒的情况下直接升星，所以初始为1
					curGradeLevel = self._nextGrade,
					learnSkill = learnSkill,
					callback = function ()
						remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_REFESH_BATTLE_FORCE})
						self:playEffectOut()
					end}
				},{
					isPopCurrentDialog = false
				}
			)
		end)
	else
		remote.artifact:artifactGradeRequest(self._actorId, true, function ()
			if self._callback then
				self._callback()
			end

			local skillConfig = db:getConfigurationValue("artifact_skill_auto")
			skillConfig = string.split(skillConfig, ",")
			local learnSkill = 0
			for _, val in ipairs(skillConfig) do
				local valNum = tonumber(val)
				if valNum <= self._nextGrade then
					learnSkill = valNum
				end
			end

			app:getNavigationManager():pushViewController(app.middleLayer, {
				uiType = QUIViewController.TYPE_DIALOG, 
				uiClass = "QUIDialogArtifactGradeUpSuccess",
				options = { 
					actorId = self._actorId, 
					oldGradeLevel = self._grade,
					curGradeLevel = self._nextGrade,
					learnSkill = learnSkill,
					callback = function ()
						remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_REFESH_BATTLE_FORCE})
						self:playEffectOut()
					end}
				},{
					isPopCurrentDialog = false
				}
			)
		end)
	end
	
end

-- 背景被点击
function QUIDialogArtifactAutoGrade:_backClickHandler()
	self:playEffectOut()
end

return QUIDialogArtifactAutoGrade