--
-- Kumo.Wang
-- 彩蛋
--

local QUIWidgetInstanceEgg = class("QUIWidgetInstanceEgg")


QUIWidgetInstanceEgg.normal_egg = {1, 2} -- 一個ccb地圖裡只有兩個普通的彩蛋，從左至右依次命名為egg1、egg2，
QUIWidgetInstanceEgg.special_egg = {3} -- 一個ccb地圖裡只有一個特殊的彩蛋，命名為egg3
-- 以上備註為和策劃約定，當時和策劃討論要不要配表，策劃堅持寫死。

--[[
	特殊彩蛋fca文件的動作命名。
	NONE無彩蛋；STANDBY彩蛋待機；CLICK彩蛋點擊一次；REWARD獲得彩蛋獎勵。
]]
QUIWidgetInstanceEgg.NONE = "animation"
QUIWidgetInstanceEgg.STANDBY = "animation1"
QUIWidgetInstanceEgg.CLICK = "animation2"
QUIWidgetInstanceEgg.REWARD = "animation3"

--特殊彩蛋的點擊獲取獎勵的次數
QUIWidgetInstanceEgg.special_egg_click_count = 3

function QUIWidgetInstanceEgg:ctor(options)
	self._instanceType = options.instanceType
	self._intMapId = options.intMapId
	self._instanceWidget = options.instanceWidget

	self._isRewarding = false -- 是否正在領獎
end

function QUIWidgetInstanceEgg:onEnter()
	self:_initEggs()
end

function QUIWidgetInstanceEgg:onExit()
	self:_removeEggs()
end

function QUIWidgetInstanceEgg:_initEggs()
	self._isRewarding = false
	if self._instanceType == DUNGEON_TYPE.NORMAL and self._intMapId <= remote.instance.MAP_EGG_MAX_ID then
		-- 目前只有普通副本才有彩蛋
		if not self._isEggDic then
			self._isEggDic = {}
		end
		--獲取彩蛋的獲獎情況
		remote.instance:getDropBoxInfoById(self._intMapId, function(data)
				if data.easterEggs then
					for _, id in ipairs(data.easterEggs) do
						self._isEggDic[id] = true
					end
				end
			end)
	end

	-- 初始化普通彩蛋
	for _, index in ipairs(self.normal_egg) do
		local egg = self._instanceWidget._ccbOwner["egg_"..index]
		if egg then
			local isNormalEgg = self._isEggDic and not self._isEggDic[index] or false
			if isNormalEgg then
				egg:setVisible(true)
				egg:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
		        egg:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self["_onTouchNormalEgg"..index]))
		        egg:setTouchEnabled(true)
		    else
		    	egg:setVisible(false)
	       	end
		end
	end

	-- 初始化特殊彩蛋
	if self._instanceWidget._ccbOwner.btn_egg_3 then
		self._instanceWidget._ccbOwner.egg_3:setVisible(true)
		if not self._spEggfca then
			self._spEggfca = tolua.cast(self._instanceWidget._ccbOwner.egg_3, "QFcaSkeletonView_cpp")
		end
		self._spEggfca:disconnectAnimationEventSignal()

		local isSpecialEgg = self._isEggDic and not self._isEggDic[3] or false
		if isSpecialEgg then
			self._instanceWidget._ccbOwner.btn_egg_3:setVisible(true)
			self._spEggfca:playAnimation(self.STANDBY, true)
		else
			self._instanceWidget._ccbOwner.btn_egg_3:setVisible(false)
			self._spEggfca:playAnimation(self.NONE, true)
		end
	end
	self:_endSpecialEggTouchSchedule()
end

function QUIWidgetInstanceEgg:_removeEggs()
	self._isRewarding = false
	for _, index in ipairs(self.normal_egg) do
		local egg = self._instanceWidget._ccbOwner["egg_"..index]
		if egg then
			egg:removeNodeEventListenersByEvent(cc.NODE_TOUCH_EVENT)
        	egg:setTouchEnabled(false)
		end
	end

	self:_endSpecialEggTouchSchedule()
end



----------- 以下是普通彩蛋的點擊處理 -----------
function QUIWidgetInstanceEgg:_onTouchNormalEggByIndex( event, index )
	if event.name == "ended" then
		if self._isRewarding then
			return
		end
		self._isRewarding = true
		app:getClient():dungeonGetEasterEggRewardRequest(self._intMapId, index, function(data)
				app:alertAwards({awards = data.prizes, title = "恭喜获得地图隐藏奖励", callback = function()
					remote.instance:sentEvent(remote.instance.UPDATE_EGG_INFO)
					if self._instanceWidget._ccbView then
						self._isRewarding = false
						self._instanceWidget._ccbOwner["egg_"..index]:setVisible(false)
						self._instanceWidget._ccbOwner["egg_"..index]:removeNodeEventListenersByEvent(cc.NODE_TOUCH_EVENT)
						self._instanceWidget._ccbOwner["egg_"..index]:setTouchEnabled(false)
					end
				end})
			end, function()
				if self._instanceWidget._ccbView then
					self._isRewarding = false
				end
			end)
	end
end

function QUIWidgetInstanceEgg:_onTouchNormalEgg1(e)
	self:_onTouchNormalEggByIndex(e, 1)
end

function QUIWidgetInstanceEgg:_onTouchNormalEgg2(e)
	self:_onTouchNormalEggByIndex(e, 2)
end



----------- 以下是特殊彩蛋的點擊處理 -----------
function QUIWidgetInstanceEgg:onTriggerSpecialEgg(e, target)
	if self._instanceWidget._ccbOwner.egg_3 then
		if not self._spEggTouchCount or self._spEggTouchCount == 0 then
			self:_startSpecialEggTouchSchedule()
		end
		if self._isRewarding then
			return
		end

		self._spEggTouchCount = self._spEggTouchCount + 1
		-- print("self._spEggTouchCount = ", self._spEggTouchCount)
		if not self._spEggfca then
			self._spEggfca = tolua.cast(self._instanceWidget._ccbOwner.egg_3, "QFcaSkeletonView_cpp")
		end

	    if self._spEggTouchCount < self.special_egg_click_count then
			self._spEggfca:playAnimation(self.CLICK, false)
			self._spEggfca:appendAnimation(self.STANDBY, true)
		elseif self._spEggTouchCount >= self.special_egg_click_count then
			self._isRewarding = true
			self._instanceWidget._ccbOwner.btn_egg_3:setVisible(false)
	    	self._spEggfca:connectAnimationEventSignal(handler(self, self._fcaHandler))
			self._spEggfca:playAnimation(self.REWARD, false)
		end
	end
end

function QUIWidgetInstanceEgg:_fcaHandler(eventType, trackIndex, animationName, loopCount)
	-- print(eventType, trackIndex, animationName, loopCount)
	if eventType == SP_ANIMATION_END or eventType == SP_ANIMATION_COMPLETE then
		if self._instanceWidget._ccbOwner.egg_3 or self._spEggfca then
			if not self._spEggfca then
				self._spEggfca = tolua.cast(self._instanceWidget._ccbOwner.egg_3, "QFcaSkeletonView_cpp")
			end
			self._spEggfca:disconnectAnimationEventSignal()
			app:getClient():dungeonGetEasterEggRewardRequest(self._intMapId, 3, function(data)
					app:alertAwards({awards = data.prizes, title = "恭喜获得地图隐藏奖励", callback = function()
							remote.instance:sentEvent(remote.instance.UPDATE_EGG_INFO)
							if self._instanceWidget._ccbView then
								self._isRewarding = false
								self._instanceWidget._ccbOwner.btn_egg_3:setVisible(false)
								if self._instanceWidget._ccbOwner.egg_3 then
									if not self._spEggfca then
										self._spEggfca = tolua.cast(self._instanceWidget._ccbOwner.egg_3, "QFcaSkeletonView_cpp")
									end
									self._spEggfca:playAnimation(self.NONE, true)
								end
							end
						end})
				end, function()
					if self._instanceWidget._ccbView then
						self._isRewarding = false
					end
				end)
		end
	end
end

function QUIWidgetInstanceEgg:_startSpecialEggTouchSchedule()
	self:_endSpecialEggTouchSchedule()
	self._specialEggTouchSchedule = scheduler.performWithDelayGlobal(function()
		if self._instanceWidget._ccbView then
			self:_endSpecialEggTouchSchedule()
		end
	end, 5)
end

function QUIWidgetInstanceEgg:_endSpecialEggTouchSchedule()
	if self._specialEggTouchSchedule then
		scheduler.unscheduleGlobal(self._specialEggTouchSchedule)
		self._specialEggTouchSchedule = nil
	end
	self._spEggTouchCount = 0
end


return QUIWidgetInstanceEgg