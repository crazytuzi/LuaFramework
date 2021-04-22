-- @Author: zhouxiaoshu
-- @Date:   2019-10-23 10:38:40
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-10-27 14:51:55

local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetMountInfoChange = class("QUIWidgetMountInfoChange", QUIWidget)
local QUIWidgetItemsBox = import("...widgets.QUIWidgetItemsBox")
local QUIViewController = import("...QUIViewController")
local QRichText = import("....utils.QRichText")
local QColorLabel = import("....utils.QColorLabel")
local QUIWidgetActorDisplay = import("..actorDisplay.QUIWidgetActorDisplay")
local QUIWidgetEquipmentAvatar = import("...widgets.QUIWidgetEquipmentAvatar")
local QQuickWay = import("....utils.QQuickWay")
local QActorProp = import("....models.QActorProp")

function QUIWidgetMountInfoChange:ctor(options)
	local ccbFile = "ccb/Widget_Weapon_change.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerChange", callback = handler(self, self._onTriggerChange)},
		{ccbCallbackName = "onTriggerReset", callback = handler(self, self._onTriggerReset)},
	}
	QUIWidgetMountInfoChange.super.ctor(self,ccbFile,callBacks,options)

	q.setButtonEnableShadow(self._ccbOwner.btn_reset)
end

function QUIWidgetMountInfoChange:setInfo(actorId)
	self._actorId = actorId
	local mountInfo = remote.herosUtil:getHeroByID(self._actorId).zuoqi
	self:setMountId(mountInfo.zuoqiId)
end

function QUIWidgetMountInfoChange:setMountId(mountId)
	self._mountId = mountId
	self._mountConfig = db:getCharacterByID(self._mountId)
	self._mountInfo = remote.mount:getMountById(self._mountId)

	local reformLevel = self._mountInfo.reformLevel or 0
	local color = remote.mount:getColorByMountId(self._mountId)
	color = QIDEA_QUALITY_COLOR[color]
	if color ~= nil then
		self._ccbOwner.tf_name:setColor(color)
		self._ccbOwner.tf_name1:setColor(color)
		self._ccbOwner.tf_name2:setColor(color)
	else
		self._ccbOwner.tf_name:setColor(QIDEA_QUALITY_COLOR.WHITE)
		self._ccbOwner.tf_name1:setColor(QIDEA_QUALITY_COLOR.WHITE)
		self._ccbOwner.tf_name2:setColor(QIDEA_QUALITY_COLOR.WHITE)
	end
	local nameStr1 = self._mountConfig.name
	local nameStr2 = self._mountConfig.name
	if self._mountConfig.aptitude == APTITUDE.SS or self._mountConfig.aptitude == APTITUDE.SSR then
		if reformLevel > 0 then
			nameStr1 = nameStr1.."+"..reformLevel
		end
		nameStr2 = nameStr2.."+"..(reformLevel+1)
	end
	self._ccbOwner.tf_name:setString(nameStr1)
	self._ccbOwner.tf_name1:setString(nameStr1)
	self._ccbOwner.tf_name2:setString(nameStr2)

	local newGradeConfig = db:getReformConfigByAptitudeAndLevel(self._mountConfig.aptitude, reformLevel + 1)
	if newGradeConfig ~= nil then
		self._ccbOwner.node_mount1:removeAllChildren()
		self._ccbOwner.node_mount2:removeAllChildren()
		self._ccbOwner.node_item:removeAllChildren()

		local itemAvatar = QUIWidgetEquipmentAvatar.new()
		self._ccbOwner.node_mount1:addChild(itemAvatar)
		itemAvatar:setMountInfo(self._mountInfo, nil, reformLevel)

		local oldGradeConfig = db:getReformConfigByAptitudeAndLevel(self._mountConfig.aptitude, reformLevel)
		local props = QActorProp:getPropUIByConfig(oldGradeConfig)
		local index = 1
		for i, prop in pairs(props) do
			if self._ccbOwner["tf_cur_name"..index] then
				self._ccbOwner["tf_cur_name"..index]:setString(prop.name.."：")
				self._ccbOwner["tf_cur_value"..index]:setString("+"..prop.value)
			end
			index = index + 1
		end

		local itemAvatar = QUIWidgetEquipmentAvatar.new()
		self._ccbOwner.node_mount2:addChild(itemAvatar)
		itemAvatar:setMountInfo(self._mountInfo, nil, reformLevel + 1)

		local props = QActorProp:getPropUIByConfig(newGradeConfig)
		local index = 1
		for i, prop in pairs(props) do
			if self._ccbOwner["tf_next_name"..index] then
				self._ccbOwner["tf_next_name"..index]:setString(prop.name.."：")
				self._ccbOwner["tf_next_value"..index]:setString("+"..prop.value)
			end
			index = index + 1
		end
		-- 消耗
		local itemTbl1 = string.split(newGradeConfig.consume_1, "^")
		local itemTbl2 = string.split(newGradeConfig.consume_2, "^")
		local count1 = remote.items:getItemsNumByID(itemTbl1[1])
		self._ccbOwner.tf_item_count:setString(count1.."/"..itemTbl1[2])
		self._ccbOwner.tf_money:setString(itemTbl2[2])

		if tonumber(itemTbl1[2]) > count1 then
			self._ccbOwner.tf_item_count:setColor(GAME_COLOR_LIGHT.warning)
		else
			self._ccbOwner.tf_item_count:setColor(GAME_COLOR_LIGHT.property)
		end
		local itemBox = QUIWidgetItemsBox.new()
		self._ccbOwner.node_item:addChild(itemBox)
		itemBox:setGoodsInfo(itemTbl1[1], ITEM_TYPE.ITEM)
		--itemBox:setItemCount(itemTbl1[2].."/"..count1)
		itemBox:hideSabc()

		self._ccbOwner.node_normal:setVisible(true)
		self._ccbOwner.node_max:setVisible(false)
	else
		self._ccbOwner.node_mount:removeAllChildren()
		local itemAvatar = QUIWidgetEquipmentAvatar.new()
		self._ccbOwner.node_mount:addChild(itemAvatar)
		itemAvatar:setMountInfo(self._mountInfo, self._mountInfo.grade)

		local gradeConfig = db:getReformConfigByAptitudeAndLevel(self._mountConfig.aptitude, reformLevel)
		local props = QActorProp:getPropUIByConfig(gradeConfig)
		local index = 1
		for i, prop in pairs(props) do
			if self._ccbOwner["tf_prop_name"..index] then
				self._ccbOwner["tf_prop_name"..index]:setString(prop.name.."：")
				self._ccbOwner["tf_prop_value"..index]:setString("+"..prop.value)
			end
			index = index + 1
		end
		self._ccbOwner.node_normal:setVisible(false)
		self._ccbOwner.node_max:setVisible(true)
	end

	self:checkRedTips()
end

function QUIWidgetMountInfoChange:checkRedTips()
	if self._mountInfo.actorId > 0 then
		local UIHeroModel = remote.herosUtil:getUIHeroByID(self._mountInfo.actorId)
		self._ccbOwner.node_change_tips:setVisible(UIHeroModel:getMountReformTip())
		if UIHeroModel:getMountReformTip() and app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.MOUNT_REFORM) then
			app:getUserOperateRecord():recordeCurrentTime(DAILY_TIME_TYPE.MOUNT_REFORM)
	    end
	else
		self._ccbOwner.node_change_tips:setVisible(false)
	end
end

function QUIWidgetMountInfoChange:_onTriggerChange(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_change) == false then return end
	local reformLevel = self._mountInfo.reformLevel or 0
	local newGradeConfig = db:getReformConfigByAptitudeAndLevel(self._mountConfig.aptitude, reformLevel + 1)
	if newGradeConfig == nil then
		app.tip:floatTip("已经到顶级")
		return
	end

	local itemTbl1 = string.split(newGradeConfig.consume_1, "^")
	local itemTbl2 = string.split(newGradeConfig.consume_2, "^")
	local count1 = remote.items:getItemsNumByID(itemTbl1[1])
	if tonumber(itemTbl2[2]) > remote.user.money then
		QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, ITEM_TYPE.MONEY)
	elseif tonumber(itemTbl1[2]) > count1 then
		QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, itemTbl1[1])
	else
		local mountId = self._mountId
		remote.mount:mountChangeRequest(mountId, function ()
			remote.mount:dispatchEvent({name = remote.mount.EVENT_REFRESH_FORCE})
			if self._ccbView then
				self:setMountId(mountId)
			end
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMountChangeSuccess",
				options = { mountId = mountId, callback = function ()
					remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_REFESH_BATTLE_FORCE})
				end}},{isPopCurrentDialog = false})
		end)
	end
end

function QUIWidgetMountInfoChange:_onTriggerReset(event)
	if not self._mountId then return end

	local mountId = self._mountId
	local mountInfo = remote.mount:getMountById(mountId)
	local reformLevel = mountInfo.reformLevel or 0
	if reformLevel == 0 then 
		app.tip:floatTip("尚未改造过，无需摘除～")
		return
	end

	local mountConfig = db:getCharacterByID(mountId)

	local content = string.format("##n摘除##l%s##n的暗器改造？摘除后，返还全部养成材料。", mountConfig.name ) 
    local sucessCallback = function()
        remote.mount:zuoqiReformResetRequest(mountId, function(data)
                -- 展示奖励页面
                local awards = {}
                local tbl = string.split(data.recoverItemAndCount or "", ";")
                for _, awardStr in pairs(tbl or {}) do
                    if awardStr ~= "" then
                        local id, typeName, count = remote.rewardRecover:getItemBoxParaMetet(awardStr)
                        table.insert(awards, {id = id, count = count, typeName = typeName})
                    end
                end
                if next(awards) then
                    local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogEnchantResetAwardsAlert",
                        options = {awards = awards}},{isPopCurrentDialog = false} )
                    dialog:setTitle("暗器改造摘除返还以下道具")
                end
            end)
    end

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRemoveAlert", 
	    options = {title = "摘除改造", contentStr = content, 
	    	callback = function (isRemove)
	    		if isRemove then
	            	sucessCallback()
	            end
	    	end}})
end

return QUIWidgetMountInfoChange