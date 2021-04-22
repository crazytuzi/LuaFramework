--
-- Author: Kumo.Wang
-- 魂靈選擇升級食物界面
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSoulSpiritChooseFood = class("QUIDialogSoulSpiritChooseFood", QUIDialog)

local QListView = import("...views.QListView")
local QUIWidgetSoulSpiritChooseLevelFoodCell = import("..widgets.QUIWidgetSoulSpiritChooseLevelFoodCell")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QRichText = import("...utils.QRichText") 

function QUIDialogSoulSpiritChooseFood:ctor(options) 
 	local ccbFile = "ccb/Dialog_SoulSpirit_Choose_LevelFood.ccbi"
	local callBacks = {
	    {ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogSoulSpiritChooseFood._onTriggerClose)},
	    {ccbCallbackName = "onTriggerOK", callback = handler(self, QUIDialogSoulSpiritChooseFood._onTriggerOK)},
	}
	QUIDialogSoulSpiritChooseFood.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = true
	self._ccbOwner.frame_tf_title:setString("选择材料")
	if options then
		self._id = options.id
		self._maxLevel = options.maxLevel
		self._callback = options.callback
	end

	self._data = {}
	self:_init()
	self:_initListView()
end

function QUIDialogSoulSpiritChooseFood:viewDidAppear()
	QUIDialogSoulSpiritChooseFood.super.viewDidAppear(self)
end

function QUIDialogSoulSpiritChooseFood:viewWillDisappear()
	QUIDialogSoulSpiritChooseFood.super.viewWillDisappear(self)
end

function QUIDialogSoulSpiritChooseFood:_init()
    self._characterConfig = QStaticDatabase.sharedDatabase():getCharacterByID(self._id)
    self._data = {}
 --    QPrintTable(itemConfigList)
	-- local itemInfoList = remote.items:getItemsByCategory(ITEM_CONFIG_CATEGORY.SOULSPIRIT_CONSUM)
	-- -- QPrintTable(itemInfoList)
	-- local tbl = {}
	-- for _, itemInfo in ipairs(itemInfoList) do
	-- 	if tbl[itemInfo.type] then
	-- 		tbl[itemInfo.type] = tbl[itemInfo.type] + itemInfo.count
	-- 	else
	-- 		tbl[itemInfo.type] = itemInfo.count
	-- 	end
	-- end

	-- for id, _ in pairs(tbl) do
	-- 	table.insert(self._data, id)
	-- end
    local itemConfigList = QStaticDatabase.sharedDatabase():getItemsByCategory(ITEM_CONFIG_CATEGORY.SOULSPIRIT_CONSUM)

	for _, itemConfig in ipairs(itemConfigList) do
		if itemConfig.type ~= ITEM_CONFIG_TYPE.SOULSPIRITOCCULT_PIECE then
			table.insert(self._data, itemConfig.id)
		end
	end
	table.sort(self._data, function(a, b)
			local aItemConfig = QStaticDatabase.sharedDatabase():getItemByID(a)
    		local bItemConfig = QStaticDatabase.sharedDatabase():getItemByID(b)
    		local aNum = remote.items:getItemsNumByID(a)
    		local bNum = remote.items:getItemsNumByID(b)
    		if aNum ~= bNum and (aNum == 0 or bNum == 0) then
    			return aNum ~= 0
    		elseif aItemConfig.colour ~= bItemConfig.colour then
				return aItemConfig.colour > bItemConfig.colour
			elseif aItemConfig.exp ~= bItemConfig.exp then
				return aItemConfig.exp > bItemConfig.exp
			elseif aItemConfig.crit ~= bItemConfig.crit then
				return aItemConfig.crit > bItemConfig.crit
			else
				return a < b
			end
		end)

	self:_updateInfo()
end

function QUIDialogSoulSpiritChooseFood:_updateInfo()
	local selectedCount = remote.soulSpirit.maxFoodCount - remote.soulSpirit:getNumForUnSelectedFood()
	self._ccbOwner.tf_choose_result:setString(selectedCount.."/"..remote.soulSpirit.maxFoodCount)
	local addExp, addCrit = remote.soulSpirit:getAddExpAndAddCrit()
	print("addExp, addCrit ", addExp, addCrit)
	local soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(self._id)
	self:updateExpProgress(soulSpiritInfo.exp, addExp, soulSpiritInfo.level, addCrit)
	self:updateDoubleProgress(addCrit)
end

function QUIDialogSoulSpiritChooseFood:updateExpProgress(exp, addExp, level, addCrit)		
	exp = exp or 0
	local text = ""
	local nextLevelConfig = remote.soulSpirit:getLevelConfigByAptitudeAndLevel(self._characterConfig.aptitude, level+1)
	if nextLevelConfig then
		if addExp > 0 then
			if addCrit >= 100 then
				text = "##n经验值:##g+"..(addExp*2)
				self._ccbOwner.tf_expBar:setString((exp+addExp*2).."/"..nextLevelConfig.strengthen_chongwu)
			else
				text = "##n经验值:##g+"..addExp
				self._ccbOwner.tf_expBar:setString((exp+addExp).."/"..nextLevelConfig.strengthen_chongwu)
			end
		else
			text = "##n经验值:##g+0"
			self._ccbOwner.tf_expBar:setString(exp.."/"..nextLevelConfig.strengthen_chongwu)
		end
		local scaleValue = exp / nextLevelConfig.strengthen_chongwu
		scaleValue = math.min(scaleValue, 1)
		self._ccbOwner.sp_cur_expBar:setScaleX(scaleValue)
		if addExp then
			local addLevelNum = 0
			if addCrit >= 100 then
				addLevelNum = remote.soulSpirit:getAddLevelNumByIdAndAddExp(self._id, addExp*2, self._maxLevel)
			else
				addLevelNum = remote.soulSpirit:getAddLevelNumByIdAndAddExp(self._id, addExp, self._maxLevel)
			end
			if addLevelNum > 0 then
				-- 升级
				if level + addLevelNum >= self._maxLevel then
					text = text.." ##x满级"
				else
					text = text.." ##n等级:##g+"..addLevelNum
				end
				self._ccbOwner.sp_preview_expBar:setScaleX(1)
			else
				local previewExp = exp + addExp
				self._ccbOwner.sp_preview_expBar:setScaleX(previewExp / nextLevelConfig.strengthen_chongwu)
			end
		else
			self._ccbOwner.sp_preview_expBar:setScaleX(0)
		end
	else
		self._ccbOwner.tf_expBar:setString("--/--")
		self._ccbOwner.sp_cur_expBar:setScaleX(0)
		self._ccbOwner.sp_preview_expBar:setScaleX(0)
	end

	local richText = QRichText.new(text, 500, {stringType = 1, defaultSize = 16})
	richText:setAnchorPoint(ccp(0, 0.5))
	self._ccbOwner.node_exp_preview:removeAllChildren()
	self._ccbOwner.node_exp_preview:addChild(richText)
end

function QUIDialogSoulSpiritChooseFood:updateDoubleProgress(addCrit)		
	addCrit = addCrit or 0
	self._ccbOwner.tf_doubleBar:setString(addCrit.."%")
	local scaleValue = addCrit / 100
	scaleValue = math.min(scaleValue, 1)
	self._ccbOwner.sp_cur_doubleBar:setScaleX(scaleValue)
	local text = ""
	if addCrit == 100 then
		text = "##n暴击率:##g必定暴击"
	elseif addCrit > 100 then
		text = "##n暴击率:##x暴击溢出"
	else
		text = "##n暴击率:##g"..addCrit.."%"
	end
	local richText = QRichText.new(text, 500, {stringType = 1, defaultSize = 16})
	richText:setAnchorPoint(ccp(0, 0.5))
	self._ccbOwner.node_double_preview:removeAllChildren()
	self._ccbOwner.node_double_preview:addChild(richText)
end

function QUIDialogSoulSpiritChooseFood:_initListView()
	local totalNumber = #self._data
    if not self._listView then
	    local cfg = {
	        renderItemCallBack = handler(self, self.renderFunHandler),
	        isVertical = true,
	        ignoreCanDrag = false,
	        autoCenter = true,
	        enableShadow = false,
	        multiItems = 2,
	        spaceX = 0,
	        spaceY = 0,
	        totalNumber = totalNumber,
	    }  
	    self._listView = QListView.new(self._ccbOwner.sheet_layout, cfg)
	else
		self._listView:reload({totalNumber = totalNumber})
	end
end

function QUIDialogSoulSpiritChooseFood:renderFunHandler(list, index, info)
    local isCacheNode = true
    local data = self._data[index]
    local item = list:getItemFromCache()
    if not item then
    	item = QUIWidgetSoulSpiritChooseLevelFoodCell.new()
    	item:addEventListener(QUIWidgetSoulSpiritChooseLevelFoodCell.ITEM_ADD, handler(self, self._onCellEvent))
    	item:addEventListener(QUIWidgetSoulSpiritChooseLevelFoodCell.ITEM_SUB, handler(self, self._onCellEvent))
        isCacheNode = false
    end
    info.item = item
	item:setInfo(data)
    info.size = item:getContentSize()

    list:registerBtnHandler(index, "btn_add1", "_onTriggerAdd")
    list:registerBtnHandler(index, "btn_add2", "_onTriggerAdd")
    list:registerBtnHandler(index, "btn_add3", "_onTriggerAdd")

    list:registerBtnHandler(index, "btn_sub", "_onTriggerSub")

	return isCacheNode
end

function QUIDialogSoulSpiritChooseFood:_onCellEvent(event)
	self:_updateInfo()
end

function QUIDialogSoulSpiritChooseFood:_onTriggerClose(e)
	if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end
	remote.soulSpirit.selectedFoodDic = {}
	self:close()
end

function QUIDialogSoulSpiritChooseFood:_onTriggerOK(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_ok) == false then return end
	self:close()
end

function QUIDialogSoulSpiritChooseFood:_backClickHandler()
	self:close()
end

function QUIDialogSoulSpiritChooseFood:close()
	if app.sound ~= nil then
		app.sound:playSound("common_confirm")
	end
	self:playEffectOut()
end

function QUIDialogSoulSpiritChooseFood:viewAnimationOutHandler()
	self:popSelf()
	if self._callback then
		self._callback()
	end
end

return QUIDialogSoulSpiritChooseFood