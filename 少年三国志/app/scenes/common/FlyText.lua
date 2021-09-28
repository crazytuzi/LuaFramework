local FlyText = class("FlyText", function ( ... )
	return CCNodeExtend.extend(CCNode:create())
end)


function FlyText:ctor(finishCallback, aniTime, nMoveDisY)
	self._labelList = {}
	self._tFinishCallback = finishCallback
	self._aniTime = aniTime or 0.6
	self._nMoveDisY = nMoveDisY or 150
end

function FlyText:addNormalText( desc, clr, destCtrl, offset, startPos, fontSize)
	startPos = startPos or ccp(display.width/2, display.height/2)
	clr = clr or ccc3(0xfe, 0xf6, 0xd8)
	fontSize = fontSize or 30
	local label = GlobalFunc.createGameLabel(desc, fontSize, clr, Colors.strokeBrown)
	self:addChild(label)
	self:setPosition(startPos)
	table.insert(self._labelList, #self._labelList+1, label)

	label._destCtrl = destCtrl
	label._offset = offset or 0
	label._startPos = startPos
end


function FlyText:addRichtext( text, fontSize, clr, strokeClr, destCtrl, offsetValue, startPos)
	startPos = startPos or ccp(display.width/2, display.height/2)
	clr = clr or ccc3(0xfe, 0xf6, 0xd8)
	fontSize = fontSize or 30
	strokeClr = strokeClr or Colors.strokeBrown
	local label = GlobalFunc.createGameRichtext(text, fontSize, clr, strokeClr)
	self:addChild(label)
	label:setPosition(startPos)
	table.insert(self._labelList, #self._labelList+1, label)

	label._destCtrl = destCtrl
	label._offset = offsetValue or 0
	label._startPos = startPos
end


function FlyText:play(speed, flag)
	local function callback()
		if self._tFinishCallback then
			self._tFinishCallback()
		end
	end

	if not self:_doPlayLable(speed, flag) then
		return callback()
	end
end

function FlyText:_doPlayLable()
	speed = speed or 1
	flag = flag or 0

	if table.nums(self._labelList) < 1 then
		return false
	end

	for key, val in pairs(self._labelList) do
		local label = val
		local destCtrl = label._destCtrl
		local offset = label._offset
		local time = self._aniTime
		local delay = 0 

		local count = table.nums(self._labelList)
		local labelHeight = 40
		local function finishCallback()
			if key == count then
				if self._tFinishCallback then
					self._tFinishCallback()
				end
				self:removeFromParentAndCleanup(true)
			end
		end

		local posX, posY = label:getPosition()
		label:setPosition(ccp(posX, posY + labelHeight*((count - key) + (count + 1)/2)))

		if flag == 0 then
			self:showAndPlay(label, destCtrl, offset, time, delay, speed, finishCallback)
		else
			self:showAndPlay1(label, destCtrl, offset, time, delay, speed, finishCallback)
		end
	end

	return true
end


function FlyText:numberGrowup( label, offset, time, func_i)
	local callback_i = function ( ... )
		if func_i then 
			func_i()
		end
	end

	offset = offset or 0
	if not label or not label.getDescription or label:getDescription() ~= "Label" then 
		return callback_i()
	end

	local text = label and label:getStringValue()
	if text == nil or text == "" then
		text = "0"
	end
	
	--有2种数字模式,     数字/数字 和  AAAA数字(含小数)BBBBB
	local num, pre, after
	num, after = string.match(text,"^(%d+)(/%d+)$")
	if num == nil then
		pre, num, after = string.match(text,"([^0-9]*)([%.0-9]+)([^0-9]*)")
	end
	
	pre = pre or ""
	after = after or ""
	local action1 = CCSequence:createWithTwoActions(CCScaleTo:create(time/2, 2), CCScaleTo:create(time/2, 1))
	if num and offset ~= 0 then 
		local soundConst = require("app.const.SoundConst")
		G_SoundManager:playSound(soundConst.GameSound.SCROLL_NUMBER_SHORT)
		local growupNumber = CCNumberGrowupAction:create(num, num + offset, time, function ( number )
			label:setText(pre..number .. after)
		end)
		local strOffset = ""..offset
		local ptPos, count = string.find(strOffset, "%.")
		local floatCount = 0
		if ptPos and strOffset[ptPos] == "." then 
			floatCount = #strOffset - ptPos - 1
		end

		if growupNumber.setFloatStep then
			growupNumber:setFloatStep(floatCount > 0, floatCount)
		end
		action1 = CCSpawn:createWithTwoActions(growupNumber, action1)
	end

	if not action1 then
		__LogError("error:numberGrowup: action1 is nil")
		return callback_i()
	end

	label:runAction(CCSequence:createWithTwoActions(action1, CCCallFunc:create(function ( ... )
		callback_i()
	end)))
end

function FlyText:showAndPlay( label, destCtrl, offset, time, delay, speed, func_i )
	if not label then 
		if func_i then 
			func_i()
		end
	end

	delay = delay or 0
	if delay < 0 then 
		delay = 0
	end
	delay = delay/speed
	time = time or 0
	if time < 0 then 
		time = 0.6
	end
	time = time/speed

	label:setScale(0.1)
	--label:setOpacity(0)
	local arr = CCArray:create()
	arr:addObject(CCEaseIn:create(CCScaleTo:create(0.3/speed, 1.3), 0.3/speed))
	arr:addObject(CCEaseIn:create(CCScaleTo:create(0.15/speed, 1), 0.15/speed))
	--arr:addObject(CCFadeIn:create(0.4/speed))
	arr:addObject(CCDelayTime:create(1.5/speed + delay))

	local moveAction = nil
	if destCtrl then 
		local localPosx, localPosy = destCtrl:convertToWorldSpaceXY(0, 0)
		localPosx, localPosy = self:convertToNodeSpaceXY(localPosx, localPosy)
	--	__Log("--localPosx = %d, localPosy = %d", localPosx, localPosy)
		moveAction = CCSpawn:createWithTwoActions(CCMoveTo:create(time, ccp(localPosx, localPosy)), CCScaleTo:create(time, 0))
	else
		moveAction = CCSpawn:createWithTwoActions(CCMoveBy:create(time, ccp(0, self._nMoveDisY)), CCFadeOut:create(time))
	end
	moveAction = CCEaseIn:create(moveAction, time)
	arr:addObject(moveAction)
	arr:addObject(CCCallFunc:create(function (  )
		self:numberGrowup(destCtrl, offset, 0.5/speed, func_i)
	end))
	if not destCtrl then 
		arr:addObject(CCRemove:create())
	end
	label:runAction(CCSequence:create(arr))
end

function FlyText:showAndPlay1( label, destCtrl, offset, time, delay, speed, func_i )
	if not label then 
		if func_i then 
			func_i()
		end
	end

	delay = delay or 0
	if delay < 0 then 
		delay = 0
	end
	delay = delay/speed
	time = time or 0
	if time < 0 then 
		time = 0.6
	end
	time = time/speed

	local moveOffset = 120
	local posx, posy = label:getPosition()
	label:setPosition(ccp(posx, posy - moveOffset/2))
	local arr = CCArray:create()
	arr:addObject(CCEaseIn:create(CCMoveBy:create(time, ccp(0, moveOffset)), 0.5/speed))
	arr:addObject(CCDelayTime:create(1.5/speed + delay))

	local moveAction = nil
	if destCtrl then 
		local localPosx, localPosy = destCtrl:convertToWorldSpaceXY(0, 0)
		localPosx, localPosy = uf_notifyLayer:getTipNode():convertToNodeSpaceXY(localPosx, localPosy)
		moveAction = CCSpawn:createWithTwoActions(CCMoveTo:create(time, ccp(localPosx, localPosy)), CCScaleTo:create(time, 0))
	else
		moveAction = CCSpawn:createWithTwoActions(CCMoveBy:create(time, ccp(0, self._nMoveDisY)), CCFadeOut:create(time))
	end
	moveAction = CCEaseIn:create(moveAction, time)
	arr:addObject(moveAction)
	arr:addObject(CCCallFunc:create(function (  )
		numberGrowup(destCtrl, offset, 0.5/speed, func_i)
	end))
	if not destCtrl then 
		arr:addObject(CCRemove:create())
	end
	label:runAction(CCSequence:create(arr))
end


return FlyText