local QAssist = class("QAssist")
local QAssistOutPanel = import(".compose.QAssistOutPanel")
local QAssistInputPanel = import(".compose.QAssistInputPanel")
local QAssistButtonPanel = import(".compose.QAssistButtonPanel")

QAssist.commands = {}
QAssist.commands["default"] = {"QEnterAssist","QHelpAssist"}
QAssist.commands["exit"] = {"QExitAssist"}
QAssist.commands["help"] = {"QHelpAssist"}
QAssist.commands["clear"] = {"QClearAssist"}
QAssist.commands["info"] = {"QInfoAssist"}

function QAssist:getInstance()
	if app._assist == nil then
        app._assist = QAssist.new()
        GlobalVal["assist"] = app._assist
    end
    return app._assist
end

function QAssist:ctor()
	self._isRuning = false
	self:createUI()
end

function QAssist:createUI()
	self._root = CCNode:create()
	self._backLayer = CCLayerColor:create(ccc4(0, 0, 0, 128), display.width, display.height)
    self._backLayer:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    self._backLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QAssist._onTouchLayer))
    self._backLayer:setTouchEnabled(true)
    self._backLayer:setPosition(0,0)
    self._root:addChild(self._backLayer)

    self._infoLayer = CCNode:create()
    self._root:addChild(self._infoLayer)

    self._outPanel = QAssistOutPanel.new()
    self._outPanel:setPosition(ccp(0,display.height))
    self._infoLayer:addChild(self._outPanel)

    self._buttonPanel = QAssistButtonPanel.new()
    self._buttonPanel:setPosition(ccp(display.width *0.7 + 1, display.height))
    self._infoLayer:addChild(self._buttonPanel)

    self._inputPanel = QAssistInputPanel.new()
    self._inputPanel:setPosition(ccp(0,0))
    self._infoLayer:addChild(self._inputPanel)

	self:checkRoot()
	self._root:setVisible(false)
end

function QAssist:_onTouchLayer(event)
	if event.name == "began" then
		return true
    elseif event.name == "moved" then
        
    elseif event.name == "ended" then
    	if self._isRuning == false then
    		self:exit()
    	end
    elseif event.name == "cancelled" then
        
	end
end

--标示完成
function QAssist:complete()
	self._isRuning = false
	self:logger("click anywhere to exit assist panle")
end

--退出控制台
function QAssist:exit()
	self._root:setVisible(false)
	if self._inputPanel ~= nil then
		self._inputPanel:setInputHide(false)
	end
    if app.funny:getIsActivite() then
        app.funny:activite()
    end
end

--进入控制台
function QAssist:enter()
	self._isRuning = true
	self._root:setVisible(true)
	if self._inputPanel ~= nil then
		self._inputPanel:setInputHide(true)
	end
end

function QAssist:checkRoot()
	local scene = display:getRunningScene()
	if self._root:getParent() ~= scene then
		if self._root:getParent() ~= nil then
			self._root:retain()
			self._root:removeFromParent()
			scene:addChild(self._root)
			self._root:release()
		else
			scene:addChild(self._root)
		end
	end
end

function QAssist:logger(str)
	self:checkRoot()
	self._outPanel:setString(str)
end

function QAssist:clearLog()
	self._outPanel:clearLog()
end

function QAssist:run(command)
	self:enter()
	if command == nil then
		command = "default"
	elseif QAssist.commands[command] == nil then
		self:logger("command: "..command.." is not defined")
		return
	end
	-- self:logger("run plane with "..command)
	self._executeOrders = QAssist.commands[command]
	if self._executeOrders == nil then
		self._executeOrders = {}
	else
		self._executeOrders = clone(self._executeOrders)
	end
	self:_runHandler()
end

function QAssist:_runHandler()
	if #self._executeOrders > 0 then
		local cls = table.remove(self._executeOrders, 1)
		local runTarget = import(app.packageRoot .. ".modules.assist."..cls)
		local target = runTarget.new()
		target:run(handler(self, self._runHandler))
	end
end

return QAssist