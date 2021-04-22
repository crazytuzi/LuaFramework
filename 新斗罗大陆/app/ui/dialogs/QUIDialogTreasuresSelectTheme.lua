--
-- Kumo.Wang
-- 资源夺宝选择主题
--

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogTreasuresSelectTheme = class("QUIDialogTreasuresSelectTheme", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QQuickWay = import("...utils.QQuickWay")
local QListView = import("...views.QListView")

local QUIWidgetTreasuresSelectThemeCell = import("..widgets.QUIWidgetTreasuresSelectThemeCell")

function QUIDialogTreasuresSelectTheme:ctor(options)
	local ccbFile = "ccb/Dialog_Treasures_Choose_Theme.ccbi"
	local callBack = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
        {ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
	}
	QUIDialogTreasuresSelectTheme.super.ctor(self, ccbFile, callBack, options)

	self._ccbOwner.frame_tf_title:setString("选择主题")

    q.setButtonEnableShadow(self._ccbOwner.btn_OK)

    if options then
    	self._themeType = options.themeType
	end

	self.isAnimation = true --是否动画显示

    self._resourceTreasuresModule = remote.activityRounds:getRoundInfoByType(remote.activityRounds.LuckyType.RESOURCE_TREASURES)

    self:_init()
end

function QUIDialogTreasuresSelectTheme:viewDidAppear()
	QUIDialogTreasuresSelectTheme.super.viewDidAppear(self)
end

function QUIDialogTreasuresSelectTheme:viewWillDisappear()
	QUIDialogTreasuresSelectTheme.super.viewWillDisappear(self)
end

function QUIDialogTreasuresSelectTheme:_init()
	local themeConfigs = db:getStaticByName("treasure_theme")
	local turnsConfigs = db:getStaticByName("treasure_turns")
	local curTurnsThemeDic = {}
	if self._resourceTreasuresModule.rowNum and not q.isEmpty(turnsConfigs) and turnsConfigs[tostring(self._resourceTreasuresModule.rowNum)] then
		local curTurnsConfigs = turnsConfigs[tostring(self._resourceTreasuresModule.rowNum)]
		local key = ""
		if self._themeType == self._resourceTreasuresModule.SENIOR_THEME then
			key = "senior_theme"
		elseif self._themeType == self._resourceTreasuresModule.PRIMARY_THEME then
			key = "primary_theme"
		end
		if key ~= "" then
			local themeStr = curTurnsConfigs[key]
			local tbl = string.split(themeStr, ",")
			if not q.isEmpty(tbl) then
				for _, id in ipairs(tbl) do
					curTurnsThemeDic[tostring(id)] = true
				end
			end
		end
	end
	self._configs = {}
    if not q.isEmpty(themeConfigs) then
    	for _, config in pairs(themeConfigs) do
    		if config.type == self._themeType and curTurnsThemeDic[tostring(config.id)] then
    			table.insert(self._configs, config)
    		end
    	end

    	table.sort(self._configs, function(a, b)
    		return a.id < b.id
    	end)
	end

	self:_initListView()
end

function QUIDialogTreasuresSelectTheme:_initListView()
    if not self._listView then
	    local cfg = {
	        renderItemCallBack = handler(self, self.reandFunHandler),
	        isVertical = false,
	        curOffset = 6,
	        totalNumber = #self._configs,
	        enableShadow = false,
	    }  
	    self._listView = QListView.new(self._ccbOwner.sheet_layout, cfg)
	else
		self._listView:reload({totalNumber = #self._configs})
	end
end

function QUIDialogTreasuresSelectTheme:reandFunHandler( list, index, info )
    local isCacheNode = true
    local config = self._configs[index]
    local item = list:getItemFromCache()

    if not item then
        item = QUIWidgetTreasuresSelectThemeCell.new()
        isCacheNode = false
    end

    item:setInfo(config)
    info.item = item
    info.size = item:getContentSize()
    item:addEventListener(QUIWidgetTreasuresSelectThemeCell.SELECTED, handler(self, self._onSelectedHandler))
    list:registerBtnHandler(index, "btn_select", "_onTriggerSelect")
    -- list:registerBtnHandler(index, "btn_detail", "_onTriggerDetail", nil, true)
    
    return isCacheNode
end

function QUIDialogTreasuresSelectTheme:_onSelectedHandler(event)
	if self._selectedThemeId and self._selectedThemeId == event.id then return end
	
	event.target:setSelectState(true)
	self._selectedThemeId = event.id
	if self._lastSelectItem then
		self._lastSelectItem:setSelectState(false)
	end
	self._lastSelectItem = event.target
end

function QUIDialogTreasuresSelectTheme:_onTriggerOK()
	app.sound:playSound("common_small")
	if self._selectedThemeId then
		if self._resourceTreasuresModule then
			self._resourceTreasuresModule:treasureChooseThemeRequest(self._themeType, self._selectedThemeId, function()
				if self:safeCheck() then
					self:playEffectOut()
				end
			end)
		end
	else
		app.tip:floatTip("尚未选择")
	end
end

function QUIDialogTreasuresSelectTheme:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogTreasuresSelectTheme:_onTriggerClose(e)
	if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end
	if e then
		app.sound:playSound("common_small")
	end
	self:playEffectOut()
end

function QUIDialogTreasuresSelectTheme:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_SPECIFIC_CONTROLLER, nil, self)
end

return QUIDialogTreasuresSelectTheme