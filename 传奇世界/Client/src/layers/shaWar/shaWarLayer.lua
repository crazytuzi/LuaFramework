local shaWarLayer = class( "shaWarLayer", function() return cc.Layer:create() end)

function shaWarLayer:ctor()
	local lab = createLabel(self, "倒计时结束占领皇宫", cc.p(g_scrSize.width/2, 550/640 * g_scrSize.height), cc.p(0.5,0.5), 26, true)
	lab:enableOutline(cc.c4b(0,0,0,255),1)
end

function shaWarLayer:update(endTime)
	if endTime == 0 then
		self:CloseCall()
	else
		if not self.timeNode or not tolua.cast(self.timeNode, "cc.Node") then
			self.timeNode = cc.Node:create()
			self:addChild(self.timeNode)
		end

		self.begainTime = endTime
		self.time = startTimerActionEx(self, 1, true, function(delTime) self:showTimeSpr(delTime) end)
		self:showTimeSpr(0)
	end
end

function shaWarLayer:showTimeSpr(delTime)
	delTime = delTime or 1
	self.begainTime = self.begainTime - delTime
	if self.begainTime >= 0 then
		if self.timeNode.timeToStartPic then
			removeFromParent(self.timeNode.timeToStartPic)
		end
		
		local pos = g_scrSize.width / 2
		if self.begainTime >= 10 then
			pos = pos - 15
		end
		
		local timeToStartPic = MakeNumbers:create("res/component/number/3.png", self.begainTime, -2)
		timeToStartPic:setPosition(cc.p(pos, 500 / 640 * g_scrSize.height))
		timeToStartPic:setAnchorPoint(cc.p(0.5, 0.5))

		self.timeNode:addChild(timeToStartPic)		
		self.timeNode.timeToStartPic = timeToStartPic
	else
		self:CloseCall()
	end
end

function shaWarLayer:CloseCall()
	if self.time then
		self.time:stopAllActions()
	end
	G_SHAWAR_DATA.timeCoutLayer = nil
	removeFromParent(self)
end

return shaWarLayer