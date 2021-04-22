
local QEditorController = class("QEditorController")

require("pack")
local socket = require("socket")

local QEHelper = import(".utils.QEHelper")
local QEArenaDatabaser = import(".utils.QEArenaDatabaser")

local QELoginScene = import(".scenes.QELoginScene")
local QESkeletonViewer = import(".scenes.QESkeletonViewer")
local QEBattleViewer = import(".scenes.QEBattleViewer")
local QEArenaViewerNew = import(".scenes.QEArenaViewerNew")
local QEArenaViewer = import(".scenes.QEArenaViewer")
local QEEffectBrower = import(".scenes.QEEffectBrower")
local QEAnimationBrower = import(".scenes.QEAnimationBrower")
local QEPrologueViewer = import(".scenes.QEPrologueViewer")

local ReadPackageSize = 1
local ReadPackageData = 2

local PackageTitleSize = 2

function QEditorController:ctor( option )
	self.helper = QEHelper.new()

	self._tcp = socket.tcp()
	self._tcp:settimeout(0)

	self._binary = ""
	self._binaryTitle = ""
	self._binarySize = -1
	self._readPackageState = ReadPackageSize

	self._current = nil
end

function QEditorController:start()
	if ARENA_DATABASE_GENERATE == true then
		self._arenaDatabase = QEArenaDatabaser.new()
		self._arenaDatabase:start()
	else
		self._scene = QELoginScene.new()
		display.replaceScene(self._scene)
	end
end

function QEditorController:connect(host, callback)
	if host == nil then
		return
	end
	self._host = host
	self._port = 1209
	self._callback = callback
	self._checkConnectDuration = 0
	self._connectScheduler = scheduler.scheduleGlobal(handler(self, self._onCheckConnectUpdate), 0.1)
end

function QEditorController:_onCheckConnectUpdate(dt)
	self._checkConnectDuration = self._checkConnectDuration + dt
	if self._checkConnectDuration > 3.0 then
		printInfo("connect faild!")
		self._checkConnectDuration = 0
		scheduler.unscheduleGlobal(self._connectScheduler)
		self._connectScheduler = nil
		if self._callback then
			self._callback(false)
		end
	else
		local isSuccess, errorCode = self._tcp:connect(self._host, self._port)
		if isSuccess == 1 or errorCode == "already connected" then
			printInfo("connect success!")
			self._checkConnectDuration = 0
			scheduler.unscheduleGlobal(self._connectScheduler)
			self._connectScheduler = nil
			if self._callback then
				self._callback(true)
			end
		end
	end
end

function QEditorController:onConnect()
	local scene = display.newScene("no name")
	local layer = CCLayerColor:create(ccc4(128, 128, 128, 255), display.width, display.height)
	scene:addChild(layer)
	display.replaceScene(scene)

	self._updateScheduler = scheduler.scheduleGlobal(handler(self, self._onUpdate), 1.0)
end

function QEditorController:onDisconnect()
	scheduler.unscheduleGlobal(self._updateScheduler)
	self._updateScheduler = nil
end

function QEditorController:_onUpdate()
	while true do
		local success = false
		if self._readPackageState == ReadPackageSize then
			success = self:_readPackageSize()
		elseif self._readPackageState == ReadPackageData then
			success = self:_readPackageData(self._binarySize - string.len(self._binary))
		else
			assert(false, "QEditorController:_onUpdate invalid receive state:" .. tostring(self._readPackageState))
		end

		if self._binarySize == string.len(self._binary) then
			self:onReceiveData(self._binary)
			self._binary = ""
			self._binaryTitle = ""
			self._binarySize = -1
		end

		if success == false then
			break
		end

	end
end

function QEditorController:_readPackageSize()
	if self._readPackageState ~= ReadPackageSize then
		assert(false, "QEditorController:_readPackageSize last package is not receive completed")
		return false
	end

	local data, errorCode, partial = self._tcp:receive(PackageTitleSize)

	local receiveData = data
	if errorCode ~= nil then
		receiveData = partial
		assert(data == nil, "receive with error:" .. errorCode .. ", but receive data is still have value")
	end

	if receiveData ~= nil and string.len(receiveData) > 0 then
		if self._binaryTitle == nil then
			self._binaryTitle = receiveData
		else
			self._binaryTitle = self._binaryTitle .. receiveData
		end

		if string.len(self._binaryTitle) == PackageTitleSize then
			local n, value = string.unpack(self._binaryTitle, "H")
			self._binarySize = value
			self._readPackageState = ReadPackageData
			if DEBUG > 0 then
				printInfo("QEditorController:_readPackageSize received binary size:" .. tostring(self._binarySize))
			end
		elseif string.len(self._binaryTitle) >= PackageTitleSize then
			assert(false, "QEditorController:_readPackageSize title size is:" .. tostring(string.len(self._binaryTitle)) .. " large then " .. tostring(PackageTitleSize))
		end
	end

	if errorCode ~= nil then
		return false
	end	

	return true
end

function QEditorController:_readPackageData(size)
	if size <= 0 then
		return false
	end

	if self._readPackageState ~= ReadPackageData then
		assert(false, "QEditorController:_readPackageData package title is not receive completed")
		return false
	end

	local data, errorCode, partial = self._tcp:receive(size)

	local receiveData = data
	if errorCode ~= nil then
		receiveData = partial
		assert(data == nil, "receive with error:" .. errorCode .. ", but receive data is still have value")
	end

	if receiveData ~= nil and string.len(receiveData) > 0 then
		if self._binary == nil then
			self._binary = receiveData
		else
			self._binary = self._binary .. receiveData
		end

		if string.len(self._binary) == self._binarySize then
			self._readPackageState = ReadPackageSize
		elseif string.len(self._binary) >= ReadPackageSize then
			assert(false, "QEditorController:_readPackageData data size is:" .. tostring(string.len(self._binary)) .. " large then " .. tostring(self._binarySize))
		end
	end

	if errorCode ~= nil then
		return false
	end

	return true
end

function QEditorController:onReceiveData(jsonString)
	if jsonString == nil then
		return
	end

	local message = json.decode(jsonString)

	if message == nil then
		return
	end

	if self._current ~= nil then
		self._current:cleanup()
		self._current = nil
	end

	if message.message == "display_actor" then
		self._current = QESkeletonViewer.new()
	elseif message.message == "display_effect" then
		self._current = QESkeletonViewer.new()
	elseif message.message == "edit_effect" then
		self._current = QESkeletonViewer.new()
	elseif message.message == "reset_battle" then
		self._current = QEBattleViewer.new()
	elseif message.message == "battle_arena" then
		self._current = QEArenaViewer.new({type = 1})
	elseif message.message == "battle_arena_new" then
		self._current = QEArenaViewer.new({type = 2})
	elseif message.message == "new_battle_editor" then
		self._current = QEArenaViewerNew.new({type = 2})
	end

	if self._current ~= nil then
		display.replaceScene(self._current)
		self._current:onReceiveData(message)
	end

end

function QEditorController:onDisplayBrowerScene(sceneName)
	if sceneName == nil then
		return
	end

	if sceneName == "effect" then
		self._current = QEEffectBrower.new()
	end

	if sceneName == "animation" then
		self._current = QEAnimationBrower.new()
	end

	if sceneName == "prologue" then
		self._current = QEPrologueViewer.new()
	end

	if sceneName == "easy_effect_editor" then
		self._current = QESkeletonViewer.new()
	end

	if self._current ~= nil then
		display.replaceScene(self._current)
	end
end

return QEditorController