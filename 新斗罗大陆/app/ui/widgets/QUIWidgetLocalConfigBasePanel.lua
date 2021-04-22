
-- 本地调试配置基础面板

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetLocalConfigBasePanel = class("QUIWidgetLocalConfigBasePanel", QUIWidget)

local QUIViewController = import("..QUIViewController")
local QScrollContain = import("..QScrollContain")

local QUIWidgetLocalConfigSelect = import("..widgets.QUIWidgetLocalConfigSelect")
local QUIWidgetLocalConfigInput = import("..widgets.QUIWidgetLocalConfigInput")


--- 重写makeConfigs，在函数里内调用以下函数来添加配置项
---	
---	self:beginGroup("环境设置", "env")	开始一个组，参1：显示文本，参2：键名	注意：组目前不能嵌套
--- self:endGroup()	结束一个组
---
--- self:addSingle("天气A", "weather", "A") 单选框，要在一个组内才是单选  参1：显示文本，参2：键名，参3：若选中时的键值
--- self:addMultiple("其他", "otherA", "F") 多选，值为true/false  	  参1：显示文本，参2：键名
--- self:addInput("测试输入", "test3")		 输入 					   参1：显示文本，参2：键名，参3：输入类型，查看QUIWidgetLocalConfigInput
--- self:toNextLine()						切换到下一行
---
--- 添加完成后可调用setConfigTable()设置默认配置
---
---
--- 重写onTriggerDo(config) 当点击确定后会调用这个函数，参数为选择好的参数


-- 配置类型
QUIWidgetLocalConfigBasePanel.TYPE = {
	Single = 1,		-- 单选
	Multiple = 2,	-- 多选
	Input = 3,		-- 输入
	Text = 4,		-- 描述
}

-- 对齐的允许差值
QUIWidgetLocalConfigBasePanel.ALIGN_VALUE_X = 50
QUIWidgetLocalConfigBasePanel.ALIGN_VALUE_Y = 10

function QUIWidgetLocalConfigBasePanel:ctor(options)
	local ccbFile = "ccb/Widget_local_config_panel.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerOk", callback = handler(self, self._onTriggerOk)},
	}
	QUIWidgetLocalConfigBasePanel.super.ctor(self, ccbFile, callBacks, options)

	q.setButtonEnableShadow(self._ccbOwner.btn_ok)

	self._widgetSpace = 0
	self._offsetY = 20

	self._lastPosX = 0
	self._lastPosY = -self._offsetY
	self._nextPosX = 0
	self._nextPosY = -self._offsetY
	self._scrollWidth = 0
	self._toNextLine = true

	self._widgets = {}

end

function QUIWidgetLocalConfigBasePanel:onEnter()
	self:update()
end

function QUIWidgetLocalConfigBasePanel:onExit()
	self:reset()

	if self._scrollContain then
		self._scrollContain:disappear()
		self._scrollContain = nil
	end
end

function QUIWidgetLocalConfigBasePanel:reset()
	if self._scrollContain then
		self._scrollContain:removeAllChildren()
	end
	self._widgets = {}

	self._lastPosX = 0
	self._lastPosY = -self._offsetY
	self._nextPosX = 0
	self._nextPosY = -self._offsetY
	self._scrollWidth = 0
	self._toNextLine = true
end

function QUIWidgetLocalConfigBasePanel:update(config)
	self:reset()

	if not self._scrollContain then
		self._scrollContain = QScrollContain.new({
			sheet = self._ccbOwner.node_sheet, 
			sheet_layout = self._ccbOwner.sheet_layout, 
			direction = QScrollContain.directionY , 
			endRate = 0.1,
			renderFun = handler(self, self._updateInputBox)
		})
	end
	local config = self:makeConfigs() or {}
	config = self:loadFromLocal(config)
	self:setConfigTable(config)

	self._scrollContain:moveTo(0, 0, false)
end

-- 实例，子类重写
function QUIWidgetLocalConfigBasePanel:makeConfigs()
	----------------------开始添加控件----------------------
	self:beginGroup("环境设置", "env")
	self:addSingle("天气A", "weather", "A")
	self:addSingle("天气B", "weather", "B")
	self:toNextLine()
	self:addSingle("天气D", "weather", "D")
	self:endGroup()

	self:beginGroup("选择设置", "other")
	self:addMultiple("其他1", "otherA", "A")
	self:addMultiple("其他2", "otherB", "B")
	self:addMultiple("其他3", "otherC", "C")
	self:toNextLine()
	self:addInput("输入框", "input")
	self:endGroup()
	----------------------结束添加控件----------------------

	-- 返回默认配置
	return {
		env = {
			weather = "C"
		},
		other = {
			otherC = "C",
			otherB = "B",
			otherE = "E",
			input = "abc"
		}
	}
end

-- 子类重写，点击确定后调用，配置传入此函数
function QUIWidgetLocalConfigBasePanel:onTriggerDo(config)
	printTable(config)
end

-- 将配置保存到本地
function QUIWidgetLocalConfigBasePanel:saveToLocal(config)
	config = config or {}
	app:getUserData():setUserValueForKey("LocalConfig_" .. self.__cname, json.encode(config))
	return config
end

-- 从本地读取配置
function QUIWidgetLocalConfigBasePanel:loadFromLocal(config)
	local valueStr = app:getUserData():getUserValueForKey("LocalConfig_" .. self.__cname) or ""
	local localConfig = json.decode(valueStr) or {}
	
	for key, value in pairs(localConfig) do
		if type(value) == "table" then
			config[key] = config[key] or {}
			table.merge(config[key], value)
		else
			config[key] = value
		end
	end

	return config
end

-- 设置配置表
function QUIWidgetLocalConfigBasePanel:setConfigTable(config)
	config = config or {}
	if q.isEmpty(config) then
		return
	end

	for _, widget in ipairs(self._widgets) do
		local key = widget:getKey(true)
		local group = widget:getGroup()
		local value = nil

		if group and config[group] then
			if key then
				value = config[group][key]
			end
		elseif key then
			value = config[key]
		end

		if value then
			widget:setValue(value)
		end
	end
	return config
end

-- 获取配置表
function QUIWidgetLocalConfigBasePanel:getConfigTable()
	local config = {}
	for _, widget in ipairs(self._widgets) do
		local key = widget:getKey()
		local value = widget:getValue()
		local group = widget:getGroup()
		if group then
			config[group] = config[group] or {}
			if key then
				config[group][key] = value
			end
		else
			if key then
				config[key] = value
			end
		end
	end
	return config
end

-- 开始一个组
function QUIWidgetLocalConfigBasePanel:beginGroup(text, groupKey)
	self:addLine()
	self:addItem(text, QUIWidgetLocalConfigBasePanel.TYPE.Text)
	self:toNextLine()
	self._tempGroupKey = groupKey
end

-- 结束一个组
function QUIWidgetLocalConfigBasePanel:endGroup()
	self._tempGroupKey = nil
	self:addLine()
	self:toNextLine()
end

-- 添加分割线
function QUIWidgetLocalConfigBasePanel:addLine()
	if self._scrollContain then
		local width = self._ccbOwner.sheet_layout:getContentSize().width
		local colorLayer = CCLayerColor:create(ccc4(255, 216, 173, 150), width, 3)
		colorLayer:setPositionY(self._nextPosY)
		self._scrollContain:addChild(colorLayer)
	end
end

-- 添加单选
function QUIWidgetLocalConfigBasePanel:addSingle(showName, key, value)
	self:addItem(showName, QUIWidgetLocalConfigBasePanel.TYPE.Single, key, value)
end

-- 添加多选
function QUIWidgetLocalConfigBasePanel:addMultiple(showName, key)
	self:addItem(showName, QUIWidgetLocalConfigBasePanel.TYPE.Multiple, key)
end

-- 添加输入框
function QUIWidgetLocalConfigBasePanel:addInput(showName, key, inputMod)
	self:addItem(showName, QUIWidgetLocalConfigBasePanel.TYPE.Input, key, inputMod)
end

-- 换行
function QUIWidgetLocalConfigBasePanel:toNextLine()
	self._toNextLine = true
end

-- 取整 对齐用
function QUIWidgetLocalConfigBasePanel:_rounding(value, isDown, alignValue)
	local tNum = value / alignValue
	if isDown then
		return math.floor(tNum) * alignValue
	end
	return math.ceil(tNum) * alignValue
end

-- 添加一个配置项
function QUIWidgetLocalConfigBasePanel:addItem(showName, itemType, key, values)
	self._itemIndex = self._itemIndex or 1
	local config = {
		id = self._itemIndex,
		showName = showName,
		itemType = itemType,
		key = key,
		values = values,
		type = itemType
	}

	if self._tempGroupKey then
		config.group = self._tempGroupKey
	end
	
	local widget = nil
	local addToTabel = true
	if itemType == QUIWidgetLocalConfigBasePanel.TYPE.Single then
		widget = self:_createSingleWidget(config)
	elseif itemType == QUIWidgetLocalConfigBasePanel.TYPE.Multiple then
		widget = self:_createMultipleWidget(config)
	elseif itemType == QUIWidgetLocalConfigBasePanel.TYPE.Input then
		widget = self:_createInputWidget(config)
	elseif itemType == QUIWidgetLocalConfigBasePanel.TYPE.Text then
		widget = self:_createText(showName)
		addToTabel = false
	end

	if not widget then
		print("无此类型")
		return
	end

	self._scrollContain:addChild(widget)
	if addToTabel then
		table.insert(self._widgets, widget)
	end

	local widgetSize = widget:getContentSize()
	local widgetWidth = self:_rounding(widgetSize.width, false, QUIWidgetLocalConfigBasePanel.ALIGN_VALUE_X)
	local widgetHeight = self:_rounding(widgetSize.height, false, QUIWidgetLocalConfigBasePanel.ALIGN_VALUE_Y)

	if self._toNextLine then
		self._lastPosX = 0
		self._lastPosY = self._nextPosY
		self._nextPosX = widgetWidth
		self._nextPosY = self._nextPosY - widgetHeight
		self._toNextLine = false
	else
		self._lastPosX = self._nextPosX
		self._nextPosX = self._nextPosX + widgetWidth + self._widgetSpace
	end

	widget:setPositionX(self._lastPosX)
	widget:setPositionY(self._lastPosY)

	if self._scrollWidth < self._nextPosX then
		self._scrollWidth = self._nextPosX
	end
	self._scrollContain:setContentSize(self._scrollWidth, math.abs(self._nextPosY) + widgetHeight)
	self._itemIndex = self._itemIndex + 1
end

-- 创建单选框
function QUIWidgetLocalConfigBasePanel:_createSingleWidget(config)
	local widget = QUIWidgetLocalConfigSelect.new({ isSingle = true })
	widget:addEventListener(QUIWidgetLocalConfigSelect.EVENT_SELECT_CHANGED, handler(self, self._onSelect))
	widget:setInfo(config)
	return widget
end

-- 创建多选框
function QUIWidgetLocalConfigBasePanel:_createMultipleWidget(config)
	local widget = QUIWidgetLocalConfigSelect.new({ isSingle = false })
	widget:addEventListener(QUIWidgetLocalConfigSelect.EVENT_SELECT_CHANGED, handler(self, self._onSelect))
	widget:setInfo(config)
	return widget
end

-- 创建输入框
function QUIWidgetLocalConfigBasePanel:_createInputWidget(config)
	local widget = QUIWidgetLocalConfigInput.new()
	widget:setInfo(config)
	return widget
end

-- 添加文本
function QUIWidgetLocalConfigBasePanel:_createText(text)
	local label = CCLabelTTF:create(text, global.font_default, 22)
	label:setAnchorPoint(ccp(0, 0.5))
	label:setColor(COLORS.j)
	return label
end

-- 选择框的处理函数
function QUIWidgetLocalConfigBasePanel:_onSelect(event)
	if event.isSingle then
		local group = event.configs.group
		local source = event.source
		if group then
			for _, widget in ipairs(self._widgets) do
				if widget.setSelected then
					if widget:getId() ~= source:getId() and widget:getGroup() == source:getGroup() then
						widget:setSelected(false)
					end
				end
			end
		end
	end
end

-- 输入框更新
function QUIWidgetLocalConfigBasePanel:_updateInputBox(isForce)
	if self._scrollContain:getMoveState() or isForce then
		for _, widget in ipairs(self._widgets) do
			if widget.updateInputBox then
				widget:updateInputBox()
			end
		end
	end
end

-- 点击确认
function QUIWidgetLocalConfigBasePanel:_onTriggerOk(event)
	self:_updateInputBox(true)

	local config = self:getConfigTable()
	if q.isEmpty(config) then
		app.tip:floatTip("未获取到有效配置表")
	end
	config = self:saveToLocal(config)
	self:onTriggerDo(config)
end



return QUIWidgetLocalConfigBasePanel