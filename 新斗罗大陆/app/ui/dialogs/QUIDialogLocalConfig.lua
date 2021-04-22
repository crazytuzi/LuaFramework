local QUIDialog = import(".QUIDialog")
local QUIDIalogLocalConfig = class("QUIDIalogLocalConfig", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetSelectBtn = import("..widgets.QUIWidgetSelectBtn")
local QListView = import("...views.QListView")

-- 左侧按钮配置，切换按钮使用按钮名  如：self:selectTab("本地龙战")
-- options为构造类时传入，infoConfig为update时传入，若子类重写update需要调用父类update
QUIDIalogLocalConfig.BTN_CONFIG_LIST = {
	{ id = 1, btnName = "本地龙战", className = "QUIWidgetLocalConfigDragonWar", options = {}, infoConfig = {} },
}



function QUIDIalogLocalConfig:ctor(options)
	local ccbFile = "ccb/Dialog_local_config.ccbi";
	local callBacks = {
	}
	QUIDIalogLocalConfig.super.ctor(self,ccbFile,callBacks,options)
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:setAllUIVisible(false)
	page.topBar:showWithHeroOverView()
	self._ccbOwner.frame_tf_title:setString("本地调试配置")
	

	self._currentBtnInfo = nil	-- 当前按钮信息 
	self._currentPanel = nil	-- 当前面板

	self._PanelMap = {}			-- 面板映射
	self._btnListView = nil		-- 按钮的listView
end

function QUIDIalogLocalConfig:viewDidAppear()
	QUIDIalogLocalConfig.super.viewDidAppear(self)
	self:addBackEvent(true)

	self:initBtnListView()
	self:selectTab("本地龙战")
end 

function QUIDIalogLocalConfig:viewWillDisappear()
	QUIDIalogLocalConfig.super.viewWillDisappear(self)
	self:removeBackEvent()
end

function QUIDIalogLocalConfig:initBtnListView()
	if not self._btnListView then
		local cfg = {
			renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local itemData = QUIDIalogLocalConfig.BTN_CONFIG_LIST[index]
	            local item = list:getItemFromCache()
	            if not item then
            		item = QUIWidgetSelectBtn.new()
            		item:addEventListener(QUIWidgetSelectBtn.EVENT_CLICK, handler(self, self.btnItemClickHandler))
	            	isCacheNode = false
	            end
	            item:setInfo(itemData)
	            info.item = item
	            info.size = item:getContentSize()
                list:registerBtnHandler(index, "btn_click", "_onTriggerClick")
	            return isCacheNode
	        end,
	        curOriginOffset = 5,
	        curOffset = 10,
	        enableShadow = false,
	      	ignoreCanDrag = true,
	      	spaceY = 5,
	        totalNumber = #(QUIDIalogLocalConfig.BTN_CONFIG_LIST),
		}
		self._btnListView = QListView.new(self._ccbOwner.sheet_menu,cfg)
	else
		self._btnListView:reload({totalNumber = #(QUIDIalogLocalConfig.BTN_CONFIG_LIST)})
	end
end

function QUIDIalogLocalConfig:btnItemClickHandler(event)
	self._currentBtnInfo = event.info or {}
	if q.isEmpty(self._currentBtnInfo) then
		return
	end

	self:_selectTabImpl()
end

-- 根据按钮名字选择Tab
function QUIDIalogLocalConfig:selectTab(btnName)
	for _, btnInfo in ipairs(QUIDIalogLocalConfig.BTN_CONFIG_LIST) do
		if btnInfo.btnName == btnName then
			self._currentBtnInfo = btnInfo
			self:_selectTabImpl()
			break
		end
	end
end

-- 选中按钮
function QUIDIalogLocalConfig:_selectTabImpl()
	if self._currentBtnInfo == nil then
		return
	end

	if self._currentPanel then
		self._currentPanel:setVisible(false)
	end

	local btnName = self._currentBtnInfo.btnName
	if not self._PanelMap[btnName] then
		local classPath = app.packageRoot .. ".ui.widgets." .. self._currentBtnInfo.className
		local isFailed = false
		xpcall(function()
			local classDef = import(classPath)
			if classDef then
				self._PanelMap[btnName] = classDef.new(self._currentBtnInfo.options)
			end
		end, function(err)
			print(err)
			isFailed = true
		end)
		if isFailed then
			print("类导入失败："..classPath)
			return
		end

		self._ccbOwner.node_panel:addChild(self._PanelMap[btnName])
	end
	self._currentPanel = self._PanelMap[btnName]

	if self._currentPanel.update and self._currentBtnInfo.infoConfig then
		self._currentPanel:update(self._currentBtnInfo.infoConfig)
	end
	self._currentPanel:setVisible(true)

	local btnWidget = self._btnListView:getItemByIndex(self._currentBtnInfo.id)
	if btnWidget then
		if self._lastBtnWidget then
			self._lastBtnWidget:setSelect(false)
			self._lastBtnWidget = btnWidget
		end
		btnWidget:setSelect(true)
	end
end

function QUIDIalogLocalConfig:onTriggerBackHandler()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDIalogLocalConfig:onTriggerHomeHandler()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

return QUIDIalogLocalConfig