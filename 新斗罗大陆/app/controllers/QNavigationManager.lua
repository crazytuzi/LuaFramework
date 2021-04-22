
--[[
	key word:
	layer: An instance of QUIViewController or inherit from QUIViewController
	controller: An instance of QUINavigationController
--]]
local QNavigationManager = class("QNavigationManager")

local QUIPageEmpty = import("..ui.pages.QUIPageEmpty")
local QNavigationController = import(".QNavigationController")
local QUIViewController = import("..ui.QUIViewController")

--[[
	root: root node is a CCNode or any inherit from CCNode
	layerCount: how many sublayer will created and attach to root node. 
				if layerCount is nil or 0 or negative, it will be ignored.
	layerNames: name of each layer, type: array
--]]
function QNavigationManager:ctor(root, layerCount, layerNames, options)
	assert(root, "QNavigationManager:ctor root node is nil!")

	self._root = root

	-- { {layer, controller}, {layer, controller}, ... }
	self._layersAndControllers = {}
	self._layerCount = 0

	if layerCount ~= nil and layerCount > 0 then
		for i = 1, layerCount do
			self:createAndPushALayer(layerNames[i])
		end
	end

	-- { {layerIndex, tag}, {layerIndex, tag}, ... }
	self._controllerOrder = {}
end

-- name: the layer name
-- ignoreOrder: boolean value if it is true the new navigation controller will not manage in order list
function QNavigationManager:createAndPushALayer(name, ignoreOrder)
	if ignoreOrder == nil then 
		ignoreOrder = false
	end
	local layer = QUIPageEmpty.new()
    self._root:addChild(layer:getView())
    local controller = QNavigationController.new(layer, name)
    local eventListener = cc.EventProxy.new(controller)
    eventListener:addEventListener(QNavigationController.PUSH_EMPTY_PAGE_AUTOMATICALLY, handler(self, self._onEvent))
    eventListener:addEventListener(QNavigationController.POP_CONTROLLER_WITH_LOCK_TAG, handler(self, self._onEvent))
    eventListener:addEventListener(QNavigationController.POP_CONTROLLER_WITH_DUPLICATE_TAG, handler(self, self._onEvent))    

    table.insert(self._layersAndControllers, {layer, controller, eventListener, ignoreOrder})
    self._layerCount = self._layerCount + 1

    controller._nlayer = self._layerCount
    return layer
end

function QNavigationManager:purge()
	self._controllerOrder = {}

	for _, v in ipairs(self._layersAndControllers) do
		local listener = v[3]
		if listener ~= nil then
			listener:removeAllEventListeners()
			v[3] = nil
		end
	end

	for _, v in ipairs(self._layersAndControllers) do
		local controller = v[2]
		while controller:getCurrentIndex() > 0 do
			controller:popViewController(QNavigationController.POP_CURRENT_PAGE, false)
		end	
	end
	
	for _, v in ipairs(self._layersAndControllers) do
		local layer = v[1]
		layer:getView():removeFromParent()
		v[2] = nil
		v[1] = nil
	end


	self._layersAndControllers = {}
	self._layerCount = 0
end

function QNavigationManager:getController(layerIndex)
	if layerIndex > self._layerCount then
		return nil
	end

	return self._layersAndControllers[layerIndex][2]
end

function QNavigationManager:getLayer(layerIndex)
	if layerIndex > self._layerCount then
		return nil
	end

	return self._layersAndControllers[layerIndex][1]
end

function QNavigationManager:isIgnoreOrder(layerIndex)
	if layerIndex > self._layerCount then
		return false
	end

	return self._layersAndControllers[layerIndex][4]
end

function QNavigationManager:getLayerIndex(controller)
	if controller == nil then
		return 
	end

	local index = nil
	for i, v in ipairs(self._layersAndControllers) do
		if v[2] == controller then
			index = i
			break
		end
	end

	return index
end

-- push a view controller to the corresponding navigation controller
-- if layerIndex is large than or equal to top layerIndex, push it anyway then
-- if layerIndex is small than top layerIndex, push an emptyPage to the controller that belong to the top layerIndex 
-- and give a tag called "mask" then push a viewController to the corresponding controller
function QNavigationManager:pushViewController(layerIndex, controllerParams, transitionParams, hide)
	local navigationController = self:getController(layerIndex)
	if navigationController == nil then
		return nil
	end

	if controllerParams.options == nil then controllerParams.options = {} end
	controllerParams.options.layerIndex = layerIndex
	--继承上一个dialog的isQuickWay
	if #self._controllerOrder > 0 and controllerParams.options.isQuickWay == nil then
		local topLayerIndex = self._controllerOrder[#self._controllerOrder][1]
		local topNavigationController = self:getController(topLayerIndex)
		if topNavigationController ~= nil then
			local options = topNavigationController:getDialogOptions()
			if options ~= nil then
				controllerParams.options.isQuickWay = options.isQuickWay
			end
		end
	end

	if self:isIgnoreOrder(layerIndex) == true then
		local viewController, success = navigationController:pushViewController(controllerParams, transitionParams, hide)
		return viewController

	else
		-- if DEBUG > 0 then
		-- 	printInfo("QNavigationManager:pushViewController")
		-- 	printInfo("From:")
		-- 	printTable(self._controllerOrder)
		-- end

		local count = #self._controllerOrder
		if count > 0 then
			local topLayerIndex = self._controllerOrder[count][1]
			if topLayerIndex > layerIndex then
				local topNavigationController = self:getController(topLayerIndex)
				table.insert(self._controllerOrder, {topLayerIndex, "mask"})
				local viewController, success = topNavigationController:pushViewController({uiType = QUIViewController.TYPE_PAGE, uiClass = "QUIPageEmpty"})
				if success == false then
					table.remove(self._controllerOrder, #self._controllerOrder)
				end
			end
		end

		table.insert(self._controllerOrder, {layerIndex, ""})
		local viewController, success = navigationController:pushViewController(controllerParams, transitionParams, hide)
		if success == false then
			table.remove(self._controllerOrder, #self._controllerOrder)
		end

		-- if DEBUG > 0 then
		-- 	printInfo("To:")
		-- 	printTable(self._controllerOrder)
		-- end

		return viewController
	end
end

function QNavigationManager:pushDialogInOrder(layerIndex, dialogSequence)
	local navigationController = self:getController(layerIndex)
	if navigationController == nil then
		return nil
	end

	if self:isIgnoreOrder(layerIndex) == true then
		local viewController = navigationController:pushDialogInOrder(dialogSequence)
		return viewController

	else
		-- if DEBUG > 0 then
		-- 	printInfo("QNavigationManager:pushDialogInOrder")
		-- 	printInfo("From:")
		-- 	printTable(self._controllerOrder)
		-- end

		local count = #self._controllerOrder
		if count > 0 then
			local topLayerIndex = self._controllerOrder[count][1]
			if topLayerIndex > layerIndex then
				local topNavigationController = self:getController(topLayerIndex)
				table.insert(self._controllerOrder, {topLayerIndex, "mask"})
				local viewController, success = topNavigationController:pushViewController({uiType = QUIViewController.TYPE_PAGE, uiClass = "QUIPageEmpty"})
				if success == false then
					table.remove(self._controllerOrder, #self._controllerOrder)
				end
			end
		end

		local viewController, success = navigationController:pushDialogInOrder(layerIndex, dialogSequence)
		if success then
			local count = #dialogSequence
			for i = 1, count do
				table.insert(self._controllerOrder, {layerIndex, ""})
			end
		end

		-- if DEBUG > 0 then
		-- 	printInfo("To:")
		-- 	printTable(self._controllerOrder)
		-- end

		return viewController
	end
end

function QNavigationManager:popViewController(layerIndex, popType, isCreat, controller)
	if layerIndex > self._layerCount then
		return
	end

	if self:isIgnoreOrder(layerIndex) == true then
		local navigationController = self:getController(layerIndex)
		if navigationController ~= nil then
			navigationController:popViewController(popType, isCreat, controller)
		end
	else
		local popIndex = self:_findPopIndex(layerIndex, popType, controller)
		if DEBUG_USER == 1 then
			trace("popIndex: "..popIndex)
			printTable(self._controllerOrder)
		end
		if popIndex == nil then
			return
		end

		if popIndex > 1 then
			local index = popIndex - 1
			local orderInfo = self._controllerOrder[index]
			if orderInfo[2] == "mask" then
				popIndex = index
			end
		end
		if DEBUG_USER == 1 then
			trace("popIndex: "..popIndex)
		end

		-- if DEBUG > 0 then
		-- 	printInfo("QNavigationManager:popViewController")
		-- 	printInfo("From:")
		-- 	printTable(self._controllerOrder)
		-- end

		local createIndex = {}
		if (popIndex + 1) <= #self._controllerOrder then
			createIndex[self._controllerOrder[popIndex][1]] = popIndex
			for i = popIndex + 1, #self._controllerOrder do
				if createIndex[self._controllerOrder[i][1]] == nil then
					createIndex[self._controllerOrder[i][1]] = i
				end
			end
			createIndex[self._controllerOrder[popIndex][1]] = nil
		end
		if DEBUG_USER == 1 then
			printTable(createIndex)
		end

		for i = #self._controllerOrder, popIndex, -1 do
			if self._controllerOrder[i] and self._controllerOrder[i][1] then
				local navigationController = self:getController(self._controllerOrder[i][1])
				if i ~= popIndex then
					if createIndex[self._controllerOrder[i][1]] == i then
						navigationController:popViewController(QNavigationController.POP_TOP_CONTROLLER)
					else
						navigationController:popViewController(QNavigationController.POP_TOP_CONTROLLER, false)
					end
				else
					navigationController:popViewController(QNavigationController.POP_TOP_CONTROLLER, isCreat)
				end

				table.remove(self._controllerOrder, i)
			end
		end

		-- if DEBUG > 0 then
		-- 	printInfo("To:")
		-- 	printTable(self._controllerOrder)
		-- end
	end

end

function QNavigationManager:_findPopIndex(layerIndex, popType, controller)
	local index = nil
	if popType == QNavigationController.POP_TOP_CONTROLLER then
		for i = #self._controllerOrder, 1, -1 do
			if self._controllerOrder[i][1] == layerIndex then
				index = i
				break
			end
		end

	elseif popType == QNavigationController.POP_SPECIFIC_CONTROLLER then
		if	controller ~= nil then
			local navigationController = self:getController(layerIndex)
			local controllerIndex = navigationController:getControllerIndex(controller)
			if controllerIndex ~= nil then
				local orderIndex = 0
				for i = 1, #self._controllerOrder do
					if self._controllerOrder[i][1] == layerIndex then
						orderIndex = orderIndex + 1
					end
					if orderIndex == controllerIndex then
						index = i
						break
					end
				end
			end
		end

	elseif popType == QNavigationController.POP_TO_CURRENT_PAGE then
		local navigationController = self:getController(layerIndex)
		local controllerIndex = navigationController:getTopPageIndex()
		if controllerIndex ~= nil then
			local orderIndex = 0
			for i = 1, #self._controllerOrder do
				if self._controllerOrder[i][1] == layerIndex then
					orderIndex = orderIndex + 1
				end
				if orderIndex == controllerIndex then
					index = i + 1
					break
				end
			end
		end

	elseif popType == QNavigationController.POP_CURRENT_PAGE then
		local navigationController = self:getController(layerIndex)
		local controllerIndex = navigationController:getTopPageIndex()
		if controllerIndex ~= nil then
			local orderIndex = 0
			for i = 1, #self._controllerOrder do
				if self._controllerOrder[i][1] == layerIndex then
					orderIndex = orderIndex + 1
				end
				if orderIndex == controllerIndex then
					index = i
					break
				end
			end
		end

	end

	return index
end

function QNavigationManager:_onEvent(event)
	if event.name == QNavigationController.POP_CONTROLLER_WITH_LOCK_TAG then
		local layerIndex = self:getLayerIndex(event.navigationController)
		if layerIndex ~= nil then
			local index = 0
			for i = #self._controllerOrder, 1, -1 do
				local orderInfo = self._controllerOrder[i]
				if orderInfo[1] == layerIndex then
					index = index + 1
				end
				if index == 2 then
					-- if DEBUG > 0 then
					-- 	printInfo("POP_CONTROLLER_WITH_LOCK_TAG")
					-- 	printInfo("From:")
					-- 	printTable(self._controllerOrder)
					-- end
					table.remove(self._controllerOrder, i)
					-- if DEBUG > 0 then
					-- 	printInfo("To:")
					-- 	printTable(self._controllerOrder)
					-- end
					break
				end

				if index == 1 and orderInfo[1] > layerIndex and orderInfo[2] == "mask" then
					assert(false, "unsupport replace view controller under mask layer!")
				end
			end
		end

	elseif event.name == QNavigationController.PUSH_EMPTY_PAGE_AUTOMATICALLY then
		local layerIndex = self:getLayerIndex(event.navigationController)
		if layerIndex ~= nil then
			local index = 0
			for i = #self._controllerOrder, 1, -1 do
				local orderInfo = self._controllerOrder[i]
				if orderInfo[1] == layerIndex then
					-- if DEBUG > 0 then
					-- 	printInfo("PUSH_EMPTY_PAGE_AUTOMATICALLY")
					-- 	printInfo("From:")
					-- 	printTable(self._controllerOrder)
					-- end
					table.insert(self._controllerOrder, i, {layerIndex, ""})
					-- if DEBUG > 0 then
					-- 	printInfo("To:")
					-- 	printTable(self._controllerOrder)
					-- end
					break
				end
			end
		end
	elseif event.name == QNavigationController.POP_CONTROLLER_WITH_DUPLICATE_TAG then
		local layerIndex = self:getLayerIndex(event.navigationController)
		if layerIndex ~= nil then
			-- if DEBUG > 0 then
			-- 	printInfo("PUSH_EMPTY_PAGE_AUTOMATICALLY")
			-- 	printInfo("From:")
			-- 	printTable(self._controllerOrder)
			-- end
			self:popViewController(layerIndex, QNavigationController.POP_TOP_CONTROLLER)
			-- if DEBUG > 0 then
			-- 	printInfo("To:")
			-- 	printTable(self._controllerOrder)
			-- end
		end
	end
end

return QNavigationManager
