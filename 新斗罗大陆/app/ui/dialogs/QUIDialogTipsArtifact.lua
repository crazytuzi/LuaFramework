local QUIDialog = import("..Dialogs.QUIDialog")
local QUIDialogTipsArtifact = class("QUIDialogTipsArtifact", QUIDialog)

local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QActorProp = import("...models.QActorProp")
local QColorLabel = import("...utils.QColorLabel")

function QUIDialogTipsArtifact:ctor(options)
  	local ccbFile = "ccb/Dialog_artifact_tips2.ccbi"
  	local callbacks = {}
  	QUIDialogTipsArtifact.super.ctor(self, ccbFile, callbacks, options)

  	self._itemId = tonumber(options.artifactId)
	local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(self._itemId)
	if itemConfig.type == ITEM_CONFIG_TYPE.ARTIFACT then
		self._artifactId = self._itemId
		self._ccbOwner.tf_type:setString(remote.items:getItemsNumByID(self._itemId))
	elseif itemConfig.type == ITEM_CONFIG_TYPE.ARTIFACT_PIECE then
		local targetItems = remote.items:getItemsByMaterialId(self._itemId)
		if targetItems ~= nil and #targetItems == 1 then
			self._artifactId = targetItems[1].item_id
			local itemCraftConfig = QStaticDatabase:sharedDatabase():getItemCraftByItemId(self._artifactId)
			self._ccbOwner.tf_type:setString(remote.items:getItemsNumByID(self._itemId).."/"..itemCraftConfig.component_num_1)
		end
	end

	self._ccbOwner.tf_content_name:setString("数量：")

	if self._icon == nil then
		self._ccbOwner.node_icon:removeAllChildren()
		self._icon = QUIWidgetItemsBox.new()
		self._ccbOwner.node_icon:addChild(self._icon)
	end
    self._icon:resetAll()
	self._icon:setGoodsInfo(self._itemId, ITEM_TYPE.ITEM, 0)

	if not self._itemNameTTF then
		self._itemNameTTF = setShadow5(self._ccbOwner.tf_name)
	end
	self._itemNameTTF:setString(itemConfig.name)
	if EQUIPMENT_COLOR[itemConfig.colour] then
		self._itemNameTTF:setColor(EQUIPMENT_COLOR[itemConfig.colour])
	end

	for i=1,4 do
		self._ccbOwner["tf_prop_"..i]:setString("")
		self._ccbOwner["tf_skill_name"..i]:setString("")
		self._ccbOwner["tf_skill_content"..i]:setString("")
	end
	-- if itemConfig.type == ITEM_CONFIG_TYPE.ARTIFACT then
	-- 	self:showItemProp(self._itemId)
	-- elseif itemConfig.type == ITEM_CONFIG_TYPE.ARTIFACT_PIECE then
	-- 	local targetItems = remote.items:getItemsByMaterialId(self._itemId)
	-- 	if targetItems ~= nil and #targetItems == 1 then
	-- 		self:showItemProp(targetItems[1].item_id)
	-- 	end
	-- end
	if self._artifactId ~= nil then
		self:showItemProp(self._artifactId)

		local skillInfo = remote.artifact:getSkillByArtifactId(self._artifactId)
		local skillConfig = db:getSkillByID(skillInfo.skill_id)
		self._ccbOwner["tf_skill_name"..index]:setString(skillConfig.name)
	    local desc = QColorLabel.removeColorSign(skillConfig.description or "")
		self._ccbOwner["tf_skill_content"..index]:setString(desc)
	end
end

function QUIDialogTipsArtifact:showItemProp(itemId)
	local breakConfig = remote.artifact:getBreakConfigById(itemId, 1)
	local index = 1
	for _,v in ipairs(QActorProp._uiFields) do
		if breakConfig[v.fieldName] ~= nil and breakConfig[v.fieldName] > 0 then
			local value = breakConfig[v.fieldName]
			if v.handlerFun ~= nil then 
				value = v.handlerFun(value)
			end
			if self._ccbOwner["tf_prop_"..index] ~= nil then
				self._ccbOwner["tf_prop_"..index]:setString(v.name.."＋"..value)
			end
			index = index + 1
		end
	end
end

function QUIDialogTipsArtifact:viewDidAppear()
	QUIDialogTipsArtifact.super.viewDidAppear(self)
end

function QUIDialogTipsArtifact:viewWillDisappear()
	QUIDialogTipsArtifact.super.viewWillDisappear(self)
end

function QUIDialogTipsArtifact:_backClickHandler()
	self:popSelf()
end

return QUIDialogTipsArtifact