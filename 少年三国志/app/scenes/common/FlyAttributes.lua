--FlyAttributes.lua

local FlyAttributes = {}

FlyAttributes._attributes = {}
FlyAttributes._backupAttributes = {}

function FlyAttributes._doAddText( text, fontSize, clr, strokeClr, destCtrl, offsetValue, startPos )
	clr = clr or ccc3(0xfe, 0xf6, 0xd8)
	local label = GlobalFunc.createGameLabel(text, fontSize, clr, strokeClr)
	label:retain()
	table.insert(FlyAttributes._attributes, #FlyAttributes._attributes + 1, {text = label, dest = destCtrl, offset=offsetValue, start=startPos})
end

function FlyAttributes.doAddRichtext( text, fontSize, clr, strokeClr, destCtrl, offsetValue )
	clr = clr or ccc3(0xfe, 0xf6, 0xd8)
	fontSize = fontSize or 30
	strokeClr = strokeClr or Colors.strokeBrown
	local label = GlobalFunc.createGameRichtext(text, fontSize, clr, strokeClr)
	label:retain()
	local size = label:getSize()
	table.insert(FlyAttributes._attributes, #FlyAttributes._attributes + 1, {text = label, dest = destCtrl, offset=offsetValue})
end

function FlyAttributes.addAssocitionChange( assocition )
	if type(assocition) ~= "table" then 
		return 
	end

	for key, value in pairs(assocition) do 
		if type(value) == "table" then 
			local attributeItem = {}
			local knightInfo = knight_info.get(value[1])
			local associationInfo = association_info.get(value[2])
			if knightInfo and associationInfo then
				local text = G_lang:get("LANG_KNIGHT_ACTIVE_ASSOCIATION", {knightName=knightInfo.name, associationName=associationInfo.name})
				FlyAttributes.doAddRichtext(text, 30, nil, Colors.strokeBrown, value[3], value[4])
			end
		end
	end
end

function FlyAttributes.addNormalText( desc, clr, destCtrl, offset, startPos, fontSize)
	if type(desc) ~= "string" then 
		return 
	end

	FlyAttributes._doAddText(desc, fontSize or 30, clr, Colors.strokeBrown, destCtrl, offset, startPos)
end

function FlyAttributes.addKnightAttri1Change( attri1, attri2, destCtrls )
	if not attri2 then 
		return
	end

	destCtrls = destCtrls or {}
	local attriArr = {}
	local attri1Value = 0
	local attri2Value = 0

	attri1Value = attri1 and attri1.attack or 0
	attri2Value = attri2 and attri2.attack or 0
	if attri2Value ~= attri1Value then
		table.insert(attriArr, #attriArr + 1, {G_lang:get("LANG_GROWUP_ATTRIBUTE_GONGJI"), attri2Value - attri1Value, destCtrls[1]})
	end

	attri1Value = attri1 and attri1.hp or 0
	local attri2Value = attri2 and attri2.hp or 0
	if attri2Value ~= attri1Value then
		table.insert(attriArr, #attriArr + 1, {G_lang:get("LANG_GROWUP_ATTRIBUTE_SHENGMING"), attri2Value - attri1Value, destCtrls[2]})
	end

	attri1Value = attri1 and attri1.phyDefense or 0
	attri2Value = attri2 and attri2.phyDefense or 0
	if attri2Value ~= attri1Value then
		table.insert(attriArr, #attriArr + 1, {G_lang:get("LANG_GROWUP_ATTRIBUTE_WUFANG"), attri2Value - attri1Value, destCtrls[3]})
	end

	attri1Value = attri1 and attri1.magicDefense or 0
	attri2Value = attri2 and attri2.magicDefense or 0
	if attri2Value ~= attri1Value then
		table.insert(attriArr, #attriArr + 1, {G_lang:get("LANG_GROWUP_ATTRIBUTE_MOFANG"), attri2Value - attri1Value, destCtrls[4]})
	end
-- dump(attri1)
-- dump(attri2)
-- dump(attriArr)

	--local sortFunc = function ( value1, value2 )
	--	return value1[2] > value2[2]
	--end
	--table.sort(attriArr, sortFunc)

	local generateAttriLabel = function ( attriItem )
		if type(attriItem) ~= "table" or #attriItem < 2 then 
			return 
		end

		local number = attriItem[2] or 0
		if number == 0 then 
			return 
		end

		local text = ""
		local clr = Colors.titleGreen
		if number > 0 then 
			text = attriItem[1].." + "..number
		else
			clr = Colors.titleRed
			text = attriItem[1].." - "..math.abs(number)
		end

		FlyAttributes._doAddText(text, 30, clr, Colors.strokeBrown, attriItem[3], number)
	end

	for key, value in pairs(attriArr) do 
		generateAttriLabel(value)
	end
end

function FlyAttributes.addKnightChangeWithOldKnight( oldKnight, newKnight, destCtrls )
	if not newKnight or newKnight < 0 then 
		return 
	end

	local knightAttri1 = G_Me.bagData.knightsData:getKnightAttr1(oldKnight or 0)
	local knightAttri2 = G_Me.bagData.knightsData:getKnightAttr1(newKnight or 0)

	FlyAttributes.addKnightAttri1Change(knightAttri1, knightAttri2, destCtrls)
end

function FlyAttributes.addKnightAttributeWithLevelOffset( baseId, offsetLevel, destCtrls )
	local offsetLevel = offsetLevel or 0
	if offsetLevel == 0 then
		return 0
	end

	destCtrls = destCtrls or {}
	require("app.cfg.knight_info")
	local knightBaseInfo = knight_info.get(baseId)
	if not knightBaseInfo then
		return 0
	end

	local hpValue = offsetLevel*knightBaseInfo.develop_hp
	local physicDefValue = offsetLevel*knightBaseInfo.develop_physical_defence
	local magicDefValue = offsetLevel*knightBaseInfo.develop_magical_defence
	local attackValue = 0
	if knightBaseInfo.damage_type == 1 then
		attackValue	= offsetLevel*knightBaseInfo.develop_physical_attack
	else
		attackValue	= offsetLevel*knightBaseInfo.develop_magical_attack
	end
	
	FlyAttributes.addAttriChange(G_lang:get("LANG_GROWUP_ATTRIBUTE_GONGJI"), attackValue, destCtrls[1])
	FlyAttributes.addAttriChange(G_lang:get("LANG_GROWUP_ATTRIBUTE_SHENGMING"), hpValue, destCtrls[2])
	FlyAttributes.addAttriChange(G_lang:get("LANG_GROWUP_ATTRIBUTE_WUFANG"), physicDefValue, destCtrls[3])
	FlyAttributes.addAttriChange(G_lang:get("LANG_GROWUP_ATTRIBUTE_MOFANG"), magicDefValue, destCtrls[4])
end

function FlyAttributes.addAttriChange( typeString, delta, destCtrl, startPos )
	local text = typeString or ""
	delta = delta or 0
	local deltaValue = string.gsub(delta, "%%", "")

	if deltaValue == 0 then 
		return 
	end

	text = text.." + "..delta
	FlyAttributes._doAddText(text, 30, Colors.titleGreen, Colors.strokeBrown, destCtrl, deltaValue, startPos)
end


function FlyAttributes.play( func, speed, flag )
	local callback = function ( ... )
		if func then 
			func()
		end
	end

	if not FlyAttributes._doPlayLabel(func, speed, flag) then 
		return callback()
	end 
end

function FlyAttributes._doPlayLabel( func, speed, flag )
	flag = flag or 0

	speed = speed or 1
	if speed <= 0 then 
		speed = 1
	end
	local callback = function ( ... )
		if func then 
			func()
		end
	end

	if #FlyAttributes._attributes < 1 then 
		return false
	end

	--__Log("[FlyAttributes] attribute count=%d", #FlyAttributes._attributes)
	local numberGrowup = function ( label, offset, time, func_i)
		local callback_i = function (  )
			if func_i then 
				func_i()
			end
		end

		offset = offset or 0
		if not label or not label.getDescription or label:getDescription() ~= "Label" then 
			return callback_i()
		end

		local text = (label and label.getStringValue) and label:getStringValue() or nil
		if text == nil or text == "" then
			text = "0"
		end
		
		--�?种数字模�?     数字/数字 �? AAAA数字(含小�?BBBBB
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

	local showAndPlay = function ( label, destCtrl, offset, time, delay, speed, func_i, key )
		local endCall = function ( ... )
			if func_i then 
				func_i(label, key)
			end
		end
		if not label then 
			endCall()
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
			localPosx, localPosy = uf_notifyLayer:getTipNode():convertToNodeSpaceXY(localPosx, localPosy)
			moveAction = CCSpawn:createWithTwoActions(CCMoveTo:create(time, ccp(localPosx, localPosy)), CCScaleTo:create(time, 0))
		else
			moveAction = CCSpawn:createWithTwoActions(CCMoveBy:create(time, ccp(0, 150)), CCFadeOut:create(time))
		end
		moveAction = CCEaseIn:create(moveAction, time)
		arr:addObject(moveAction)
		arr:addObject(CCCallFunc:create(function (  )
			numberGrowup(destCtrl, offset, 0.5/speed, endCall)
		end))
		if not destCtrl then 
			arr:addObject(CCRemove:create())
		end
		label:runAction(CCSequence:create(arr))
	end

	local showAndPlay1 = function ( label, destCtrl, offset, time, delay, speed, func_i, key )
		local endCall = function ( ... )
			if func_i then 
				func_i(label, key)
			end
		end
		if not label then 
			endCall()
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
			moveAction = CCSpawn:createWithTwoActions(CCMoveBy:create(time, ccp(0, 150)), CCFadeOut:create(time))
		end
		moveAction = CCEaseIn:create(moveAction, time)
		arr:addObject(moveAction)
		arr:addObject(CCCallFunc:create(function (  )
			numberGrowup(destCtrl, offset, 0.5/speed, endCall)
		end))
		if not destCtrl then 
			arr:addObject(CCRemove:create())
		end
		label:runAction(CCSequence:create(arr))
	end

	local onFlyEnd = function ( ... )
		callback()
		FlyAttributes._clearFlyAttributes()
	end

	local labelHeight = 40
	local winSize = CCDirector:sharedDirector():getWinSize()
	local count = #FlyAttributes._attributes
	for key, value in pairs(FlyAttributes._attributes) do 
		if value.text then 
			if labelHeight <= 0 then 
				local size = value.text:getSize()
				labelHeight = size.height
			end

			if value.start then
				value.text:setPosition(ccp(value.start.x, value.start.y - labelHeight*(key - (count + 1)/2)))
			else
				local ypos = winSize.height/2 - labelHeight*(key - (count + 1)/2)
				value.text:setPosition(ccp(winSize.width/2, ypos))
			end
			uf_notifyLayer:getTipNode():addChild(value.text, 0, 100)
			value.text:release()

			local _fun_ = function ( param, key1 )
				if param then
					param:removeFromParentAndCleanup(true)
					FlyAttributes._backupAttributes[key1] = nil
				end
				
				if key == count then
					onFlyEnd()
				end
			end
			if flag == 0 then
				showAndPlay(value.text, value.dest, value.offset, 0.6, 0, speed, _fun_, key)
			else
				showAndPlay1(value.text, value.dest, value.offset, 0.6, 0, speed, _fun_, key)
			end
		end
	end

	FlyAttributes._backupAttributes = FlyAttributes._attributes
	FlyAttributes._attributes = {}

	return true
end

function FlyAttributes.cancelFlyAttributes( ... )
	FlyAttributes._attributes = {}
end

function FlyAttributes._clearFlyAttributes(  )
	if not FlyAttributes._backupAttributes then 
		return 
	end

	for key, value in pairs(FlyAttributes._backupAttributes) do 
		if value.text then 
			value.text:removeFromParentAndCleanup(true)
			--value.text:setVisible(false)
			--value.text:stopAllActions()
		end
		if value.dest then 
			if value.dest.getDescription and value.dest:getDescription() == "Label" then 
				value.dest:stopAllActions()
				value.dest:setScale(1)
			end
		end
	end

	FlyAttributes._backupAttributes = {}
end


return FlyAttributes
