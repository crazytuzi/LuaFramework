local baseScene = class("baseScene", function ()
	return display.newScene()
end)

table.merge(slot0, {})

baseScene.onEnter = function (self)
	print("baseScene:onEnter")

	local lastNetState = network.getInternetConnectionStatus()
	local listener = cc.EventListenerCustom:create("CONNECTIVITY_ACTION", function ()
		local currentState = network.getInternetConnectionStatus()

		print("CONNECTIVITY_ACTION", lastNetState, currentState)

		if lastNetState ~= currentState then
			if currentState == cc.kCCNetworkStatusNotReachable then
				lastNetState = 0

				self:onLoseConnect()
			else
				lastNetState = currentState

				self:onNetworkStateChange(currentState)
			end
		end

		return 
	end)

	self.getEventDispatcher(slot0):addEventListenerWithSceneGraphPriority(listener, self)

	self.networkStatuListener = listener

	self.setKeypadEnabled(self, true)
	self.addNodeEventListener(self, cc.KEYPAD_EVENT, function (event)
		if event.key == "back" then
			MirSDKAgent:exitGame(function ()
				an.newMsgbox("确定要退出游戏吗?", function (idx)
					if idx == 1 then
						os.exit(1)
					end

					return 
				end, {
					center = true,
					hasCancel = true
				})

				return 
			end)
		end

		return 
	end)

	return 
end
baseScene.onExit = function (self)
	self.getEventDispatcher(self):removeEventListener(self.networkStatuListener)

	return 
end
baseScene.onLoseConnect = function (self)
	print("baseScene:onLoseConnect")
	assert(false, "should override me")

	return 
end
baseScene.onNetworkStateChange = function (self)
	print("baseScene:onNetworkStateChange")
	assert(false, "should override me")

	return 
end

return baseScene
