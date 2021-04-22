
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetMagicHerbAdvance = class("QUIWidgetMagicHerbAdvance", QUIWidget)

local QUIWidgetMagicHerbBox = import("..widgets.QUIWidgetMagicHerbBox")
local QUIWidgetMagicHerbEffectBox = import("..widgets.QUIWidgetMagicHerbEffectBox")
local QListView = import("...views.QListView")
local QActorProp = import("...models.QActorProp")
local QUIViewController = import("..QUIViewController")
local QUIWidgetQlistviewItem = import("..widgets.QUIWidgetQlistviewItem")
local QQuickWay = import("...utils.QQuickWay")

function QUIWidgetMagicHerbAdvance:ctor( options )
    local ccbFile = "ccb/Widget_MagicHerb_Advance.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
        {ccbCallbackName = "onTriggerAutoSelect", callback = handler(self, self._onTriggerAutoSelect)},
    }
    QUIWidgetMagicHerbAdvance.super.ctor(self, ccbFile, callBacks, options)

    cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

    q.setButtonEnableShadow(self._ccbOwner.btn_ok)
    q.setButtonEnableShadow(self._ccbOwner.btn_auto_select)
end

function QUIWidgetMagicHerbAdvance:onEnter()
	self:_init()
end

function QUIWidgetMagicHerbAdvance:onExit()
end

function QUIWidgetMagicHerbAdvance:_reset()
	self._ccbOwner.node_client:setVisible(false)
	self._ccbOwner.node_max:setVisible(false)

	self._ccbOwner.node_client_old:setVisible(true)
	self._ccbOwner.node_icon_old:setVisible(true)
	self._ccbOwner.tf_title_old_1:setVisible(true)
	self._ccbOwner.tf_value_old_1:setVisible(true)
	self._ccbOwner.tf_title_old_2:setVisible(true)
	self._ccbOwner.tf_value_old_2:setVisible(true)
	self._ccbOwner.node_client_new:setVisible(true)
	self._ccbOwner.node_icon_new:setVisible(true)
	self._ccbOwner.tf_title_new_1:setVisible(true)
	self._ccbOwner.tf_value_new_1:setVisible(true)
	self._ccbOwner.tf_title_new_2:setVisible(true)
	self._ccbOwner.tf_value_new_2:setVisible(true)
	self._ccbOwner.node_icon_list:setVisible(true)
	self._ccbOwner.node_btn:setVisible(true)
	self._ccbOwner.btn_ok:setVisible(true)
	self._ccbOwner.btn_ok:setEnabled(true)
	self._ccbOwner.node_icon:setVisible(true)
	self._ccbOwner.tf_title_1:setVisible(true)
	self._ccbOwner.tf_value_1:setVisible(true)
	self._ccbOwner.tf_title_2:setVisible(true)
	self._ccbOwner.tf_value_2:setVisible(true)

	self._ccbOwner.tf_curSelectedInfo:setString("点击选择仙品")
	self._ccbOwner.tf_select_desc:setVisible(false)
end

function QUIWidgetMagicHerbAdvance:_init()
	self:_reset()

    self._data = {}
	self._selectedItemInfoDic = {}

	if self._actorId and self._pos then
		self:setInfo(self._actorId, self._pos)
	end
end

function QUIWidgetMagicHerbAdvance:setInfo(actorId, pos)
	self._selectedItemInfoDic = {}
	
	self._actorId = actorId
	self._pos = pos
	self._uiHeroModel = remote.herosUtil:getUIHeroByID(self._actorId)
	local wearedInfo = self._uiHeroModel:getMagicHerbWearedInfoByPos(self._pos)
	if not wearedInfo then return end
	self._sid = wearedInfo.sid
	


	local maigcHerb = remote.magicHerb:getMaigcHerbItemBySid(self._sid)
	local magicHerbConfig = remote.magicHerb:getMagicHerbConfigByid(maigcHerb.itemId)
	local maigcHerbItemConfig = db:getItemByID(maigcHerb.itemId)

	if not maigcHerb or not magicHerbConfig or not maigcHerbItemConfig then return end

	local name = magicHerbConfig.name
	local fontColor = UNITY_COLOR_LIGHT[EQUIPMENT_QUALITY[maigcHerbItemConfig.colour]]

	local nowGrade = maigcHerb.grade
	local magicHerbId = magicHerbConfig.id
	local curGradConfig = remote.magicHerb:getMagicHerbGradeConfigByIdAndGrade(magicHerbId, nowGrade)
	local nextGradConfig = remote.magicHerb:getMagicHerbGradeConfigByIdAndGrade(magicHerbId, nowGrade + 1)

	local  breedLevel = maigcHerb.breedLevel or 0
	local aptitude = remote.magicHerb:getAptitudeByIdAndBreedLv(maigcHerb.itemId,maigcHerb.breedLevel)
    if breedLevel == remote.magicHerb.BREED_LV_MAX then
    	fontColor = UNITY_COLOR_LIGHT[EQUIPMENT_QUALITY[maigcHerbItemConfig.colour + 1]]
	elseif breedLevel > 0 then
		name = name.."+"..breedLevel
    end

	if nextGradConfig and curGradConfig and not q.isEmpty(curGradConfig) and next(nextGradConfig) then
		self._nextGradConfig = nextGradConfig
		self._ccbOwner.node_client:setVisible(true)
		self._ccbOwner.node_max:setVisible(false)

	    local selectedCount = 0
		for sid, value in pairs(self._selectedItemInfoDic) do
			selectedCount = selectedCount + value.count
		end
		self._ccbOwner.tf_select_desc:setString(string.format("当前升星需要同品质一星一级仙品%s个（%s/%s）", nextGradConfig.consum_num, selectedCount, nextGradConfig.consum_num))
		self._ccbOwner.tf_select_desc:setVisible(true)

		local iconOld = QUIWidgetMagicHerbEffectBox.new()
		iconOld:setInfo(self._sid)
		iconOld:hideName()
		-- iconOld:setPositionY(-10)
		self._ccbOwner.node_icon_old:removeAllChildren()
		self._ccbOwner.node_icon_old:addChild(iconOld)

		self._ccbOwner.tf_name_old:setString(name)
		self._ccbOwner.tf_name_old:setColor(fontColor)
		self._ccbOwner.tf_name_old = setShadowByFontColor(self._ccbOwner.tf_name_old, fontColor)

		local tblOld = self:_getPropListByGradeConfig(curGradConfig)
		self._oldPropList = tblOld
		for index, prop in ipairs(tblOld) do
			local tfTitle = self._ccbOwner["tf_title_old_"..index]
			if tfTitle then
				tfTitle:setString(prop.name..":")
			end
			local tfValue = self._ccbOwner["tf_value_old_"..index]
			if tfValue then
				tfValue:setString("+"..prop.value)
			end
		end

		local iconNew = QUIWidgetMagicHerbEffectBox.new()
		iconNew:setInfo(self._sid)
		iconNew:hideName()
		iconNew:setStarNum(nowGrade + 1)
		-- iconNew:setPositionY(-10)
		self._ccbOwner.node_icon_new:removeAllChildren()
		self._ccbOwner.node_icon_new:addChild(iconNew)

		self._ccbOwner.tf_name_new:setString(name)
		self._ccbOwner.tf_name_new:setColor(fontColor)
		self._ccbOwner.tf_name_new = setShadowByFontColor(self._ccbOwner.tf_name_new, fontColor)

		local tblNew = self:_getPropListByGradeConfig(nextGradConfig)
		self._newPropList = tblNew
		for index, prop in ipairs(tblNew) do
			local tfTitle = self._ccbOwner["tf_title_new_"..index]
			if tfTitle then
				tfTitle:setString(prop.name..":")
			end
			local tfValue = self._ccbOwner["tf_value_new_"..index]
			if tfValue then
				tfValue:setString("+"..prop.value)
			end
		end

		self._data = self:_getFoodData()
		-- QPrintTable(self._data)
		self:_initListView()
	else
		-- 已最大
		self._ccbOwner.node_client:setVisible(false)
		self._ccbOwner.node_max:setVisible(true)
		self._ccbOwner.node_icon:removeAllChildren()

		local icon = QUIWidgetMagicHerbEffectBox.new()
		icon:setInfo(self._sid)
		icon:hideName()
		self._ccbOwner.node_icon:addChild(icon)

		self._ccbOwner.tf_name:setString(name)
		self._ccbOwner.tf_name:setColor(fontColor)
		self._ccbOwner.tf_name = setShadowByFontColor(self._ccbOwner.tf_name, fontColor)

		local tbl = self:_getPropListByGradeConfig(curGradConfig)
		for index, prop in ipairs(tbl) do
			local tfTitle = self._ccbOwner["tf_title_"..index]
			if tfTitle then
				tfTitle:setString(prop.name..":")
			end
			local tfValue = self._ccbOwner["tf_value_"..index]
			if tfValue then
				tfValue:setString(prop.value)
			end
		end
	end
end

function QUIWidgetMagicHerbAdvance:_initListView()
    if not self._listView then
        local cfg = {
            renderItemCallBack = function( list, index, info )
                local isCacheNode = true
                local itemData = self._data[index]
                -- QPrintTable(itemData)
                local item = list:getItemFromCache()
                if not item then
                	item = QUIWidgetQlistviewItem.new()
                    isCacheNode = false
                end

	           	self:setItemInfo(item, itemData)

                info.item = item
	            info.size = CCSizeMake(80,90)

                list:registerBtnHandler(index, "btn_click", handler(self, self._onTriggerClick))
                
                return isCacheNode
            end,
            isVertical = false,
            multiItems = 1,
            enableShadow = false,
            curOffset = 0,
            ignoreCanDrag = false,
            autoCenter = true,
            totalNumber = #self._data,
        }
        self._listView = QListView.new(self._ccbOwner.sheet_layout, cfg)
    else
        self._listView:reload({totalNumber = #self._data})
    end
end

function QUIWidgetMagicHerbAdvance:setItemInfo( item, itemData )
	if not item._itemNode then
		item._itemNode = QUIWidgetMagicHerbBox.new()
		item._itemNode:setPosition(ccp(100/2,86/2))
        item._itemNode:setScale(0.7)

		item._ccbOwner.parentNode:addChild(item._itemNode)
		item._ccbOwner.parentNode:setContentSize(CCSizeMake(80,90))
	end
    item._itemNode:setHeroId(self._actorId)
    local key = nil

    if not itemData.sid then
    	item._itemNode:setItemByItemId(itemData.id, nil, 0)
    	key = itemData.id
    	
    else
    	item._itemNode:setInfo(itemData.sid)
    	key = itemData.sid
    end
	item._itemNode:hideName()
	item._itemNode:setSelectedForFood(false)

	if self._selectedItemInfoDic[key] then
		item._itemNode:setSelectedForFood(true)
		if tonumber(key) then
			item._itemNode:setItemSelectedCount(self._selectedItemInfoDic[key].count)
		end
	end
end

function QUIWidgetMagicHerbAdvance:_onTriggerClick( x, y, touchNode, listView )
	app.sound:playSound("common_others")
    local touchIndex = listView:getCurTouchIndex()
    local selectData = self._data[touchIndex]
    local item = listView:getItemByIndex(touchIndex)

    local isSelected = item._itemNode:getIsSelectedForFood()
    local selectedCount = 0
	for sid, value in pairs(self._selectedItemInfoDic) do
		selectedCount = selectedCount + value.count
	end
    if not isSelected and selectedCount >= self._nextGradConfig.consum_num then
		app.tip:floatTip("当前选择已经满足升星条件")
		return
	end

    local changeSelected = item._itemNode:onSelectChangeForFood()

    local key = selectData.id
    if selectData.sid then
    	key = selectData.sid
    end
    if changeSelected then
    	if tonumber(key) then
	    	local needCount = self._nextGradConfig.consum_num - selectedCount
	    	if needCount > 0 then
				local wildItemCount = nil
				local wildItemId = key
				local itemCount = remote.items:getItemsNumByID(wildItemId)
				if itemCount <= needCount then
					wildItemCount = itemCount
				else
					wildItemCount = needCount
				end
				self._selectedItemInfoDic[key] = {touchIndex = touchIndex, count = wildItemCount}
				item._itemNode:setItemSelectedCount(wildItemCount)
			end
		else
    		self._selectedItemInfoDic[key] = {touchIndex = touchIndex, count = 1}
    	end
    else
    	self._selectedItemInfoDic[key] = nil

    	if tonumber(key) then
    		item._itemNode:setItemSelectedCount(0)
    	end
    end
    selectedCount = 0
	for sid, value in pairs(self._selectedItemInfoDic) do
		selectedCount = selectedCount + value.count
	end
	if selectedCount > self._nextGradConfig.consum_num then
		selectedCount = self._nextGradConfig.consum_num
	end
	self._ccbOwner.tf_select_desc:setString(string.format("当前升星需要同品质一星一级仙品%s个（%s/%s）", self._nextGradConfig.consum_num, selectedCount, self._nextGradConfig.consum_num))
end

function QUIWidgetMagicHerbAdvance:_onTriggerOK(event)
	app.sound:playSound("common_small")
	local selectedCount = 0
	local sidList = {}
	local wildItemId = nil
	local wildItemCount = nil
	for sid, value in pairs(self._selectedItemInfoDic) do
		if tonumber(sid) then
			wildItemId = sid
			wildItemCount = value.count
		else
			table.insert(sidList, sid)
		end
		selectedCount = selectedCount + value.count
	end
	if selectedCount == self._nextGradConfig.consum_num then
		local oldPropList = clone(self._oldPropList)
		local newPropList = clone(self._newPropList)
		remote.magicHerb:magicHerbUpGradeRequest(self._sid, sidList, wildItemId, wildItemCount, function()
				if self._ccbView then
					app:getNavigationManager():pushViewController(app.topLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMagicHerbSuccess", 
						options = {sid = self._sid, oldPropList = oldPropList, nowPropList = newPropList, type = 1}})
					self:_init()
				end
			end)
	else
		if #self._data >= self._nextGradConfig.consum_num then
			app.tip:floatTip("升星道具数量不足")

		else
			local magicHerbItemInfo = remote.magicHerb:getMaigcHerbItemBySid(self._sid)
			QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, magicHerbItemInfo.itemId)
		end
	end
end

function QUIWidgetMagicHerbAdvance:_onTriggerAutoSelect(event)

	app.sound:playSound("common_small")
	local selectedCount = 0
	local touchIndexDic = {} -- 已经选择的物品，跳过自动选择
	for sid, value in pairs(self._selectedItemInfoDic) do
		if tonumber(sid) then
			local wildItemId = sid
			local itemCount = remote.items:getItemsNumByID(wildItemId)
			-- 破碎仙草如果當前沒有全部被選擇，則不加入跳过列表
			if value.count >= itemCount then
				touchIndexDic[value.touchIndex] = true
			end
		else
			touchIndexDic[value.touchIndex] = true
		end
		selectedCount = selectedCount + value.count
	end

	if selectedCount < self._nextGradConfig.consum_num then
		local needCount = self._nextGradConfig.consum_num - selectedCount
		local index = 1
		while needCount > 0 do
			if touchIndexDic[index] then
				index = index + 1
			else
				local item = self._listView:getItemByIndex(index)
				local wildItemCount = 0
				local selectData = self._data[index]
				if selectData == nil then break end 

				if not selectData.sid then
					if self._selectedItemInfoDic[selectData.id] then
						-- 之前已經選擇的破碎仙草數量
						wildItemCount = self._selectedItemInfoDic[selectData.id].count
					end
					local itemCount = remote.items:getItemsNumByID(selectData.id) - wildItemCount
					if itemCount > 0 then
						if itemCount <= needCount then
							wildItemCount = wildItemCount + itemCount
						else
							wildItemCount = wildItemCount + needCount
						end
					end
					self._selectedItemInfoDic[selectData.id] = {touchIndex = index, count = wildItemCount}
					needCount = needCount - wildItemCount
				else
    				self._selectedItemInfoDic[selectData.sid] = {touchIndex = index, count = 1}
    				needCount = needCount - 1
				end
    			index = index + 1
    			if needCount < 0 then needCount = 0 end
				self._ccbOwner.tf_select_desc:setString(string.format("当前升星需要同品质一星一级仙品%s个（%s/%s）", self._nextGradConfig.consum_num, self._nextGradConfig.consum_num - needCount, self._nextGradConfig.consum_num))

				if item and item._itemNode and item._itemNode.setSelectedForFood and item._itemNode.setItemSelectedCount then
	    			item._itemNode:setSelectedForFood(true)
					item._itemNode:setItemSelectedCount(wildItemCount)
	    		end
	    	end
		end
	end
end

function QUIWidgetMagicHerbAdvance:_getFoodData()
	local magicHerbItemInfo = remote.magicHerb:getMaigcHerbItemBySid(self._sid)
	if not magicHerbItemInfo then return end
	local magicHerbConfig = remote.magicHerb:getMagicHerbConfigByid(magicHerbItemInfo.itemId)
	local magicHerbItemList = remote.magicHerb:getMagicHerbItemList()
	local noWearList = {}
	local wildConfig = remote.magicHerb:getWildMagicHerbByAptitude(magicHerbConfig.aptitude)
	if remote.items:getItemsNumByID(wildConfig.id) > 0 then
		noWearList[#noWearList+1] = wildConfig
	end

	for _, value in ipairs(magicHerbItemList) do
		local curMagicHerbConfig = remote.magicHerb:getMagicHerbConfigByid(value.itemId)
		if  (not value.actorId or value.actorId == 0)
			and curMagicHerbConfig.aptitude == magicHerbConfig.aptitude
			and value.grade == 1
			and value.level == 1 
			and value.breedLevel == 0 
			and value.isLock == false then
			noWearList[#noWearList+1] = value
		end
	end

	return noWearList
end

function QUIWidgetMagicHerbAdvance:_getPropListByGradeConfig( config )
	local tbl = {}
	if config then
		local tmpTbl1 = {}
		local tmpTbl2 = {}
		for key, value in pairs(config) do
			if QActorProp._field[key] then
				local name = QActorProp._field[key].uiName or QActorProp._field[key].name
				value = q.getFilteredNumberToString(value, QActorProp._field[key].isPercent, 2)		
				if key == "armor_physical" or key == "armor_magic" then
					table.insert(tmpTbl1, {name = name, value = value})
				elseif key == "armor_physical_percent" or key == "armor_magic_percent" then
					table.insert(tmpTbl2, {name = name, value = value})
				else
					table.insert(tbl, {name = name, value = value})
				end
			end
		end

		if #tmpTbl1 == 2 then
			table.insert(tbl, {name = "双防", value = tmpTbl1[1].value})
		elseif #tmpTbl1 == 1 then
			table.insert(tbl, {name = tmpTbl1[1].name, value = tmpTbl1[1].value})
		end
		if #tmpTbl2 == 2 then
			table.insert(tbl, {name = "双防", value = tmpTbl2[1].value})
		elseif #tmpTbl2 == 1 then
			table.insert(tbl, {name = tmpTbl2[1].name, value = tmpTbl2[1].value})
		end
	end

	return tbl
end

return QUIWidgetMagicHerbAdvance