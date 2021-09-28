-- FileName: FightScene.lua 
-- Author: lichenyang 
-- Date: 13-9-29 
-- Purpose: 战斗buffer动作

module("FightBufferAction", package.seeall)

--[[
	@des:播放buffer
	@parm:pBlockInfo 描述
	@ret:ret 描述
--]]
function playBufferEffect( pBlockInfo, pAddTime, pCallback )
	-- print("playBufferEffect")
	--enbuffer 添加buffer
	playEnbuffer(pBlockInfo, pAddTime, function ( ... )
		--buffer 生效buffer
		playBuffer(pBlockInfo, pAddTime, function ( ... )
			--imbuffer 免疫buffer
			playImBuffer(pBlockInfo, pAddTime, function ( ... )
				--debuffer buffer 删除特效
				playDebuffer(pBlockInfo, pAddTime, function ( ... )
					pCallback()
				end)
			end)
		end)
	end)
end

--[[
	@des:buffers添加
	@parm:pBlockInfo 描述
	@ret:ret 描述
--]]
function playEnbuffer(pBlockInfo, pAddTime, pCallback)
	-- print("playEnbuffer")
	--是否跳过
    if FightMainLoop.getIsSkip() == true then
        return
    end
	local attackHid = pBlockInfo.attacker
	local atkCard = FightScene.getCardByHid(attackHid)
	local bufferCount = getBlockBufferCount(pBlockInfo, BufferShowType.ENBUFFER, pAddTime)
	if bufferCount == 0 then
		if pCallback then
			pCallback()
			return
		end
	end

	--播放完毕回调
	local playTime = 0
	local playCallbackFunc = function ()
		playTime = playTime + 1
		if playTime == bufferCount then
			if pCallback then
				pCallback()
				return
			end
		end
	end
	local bufferMap = {}
   	--攻击者buffer
   	if pBlockInfo.enBuffer then
   		for k,v in pairs(pBlockInfo.enBuffer) do
   			local bufferId = v  
	   		local bufferAddType = getBufferPlayTime(bufferId, BufferShowType.ENBUFFER)
	   		--检查buffer执行时间
	   		if tonumber(bufferAddType) == tonumber(pAddTime) then
	   			local buffObj = {}
	   			buffObj.targetHid = attackHid
	   			buffObj.bufferId  = v
	   			table.insert(bufferMap, buffObj)
	   		end
   		end
   	end
   	--被攻击者buffer
   	if pBlockInfo.arrReaction then
		for k,v in pairs(pBlockInfo.arrReaction) do
			if v.enBuffer then
				for key,valude in pairs(v.enBuffer) do
					local bufferId = valude  
	   				local bufferAddType = getBufferPlayTime(bufferId, BufferShowType.ENBUFFER)
	   				-- print("bufferId", bufferId)
	   				-- print("bufferAddType", bufferAddType)
	   				--检查buffer执行时间
			   		if tonumber(bufferAddType) == tonumber(pAddTime) then
			   			local buffObj = {}
			   			buffObj.targetHid = v.defender
			   			buffObj.bufferId  = valude
			   			table.insert(bufferMap, buffObj)
			   		end
				end
			end
		end
	end
	--如果没有需要播放的buffer 则返回
	if table.count(bufferMap) == 0 then
		if pCallback then
			pCallback()
			return
		end
	end
	-- printTable("enbuffer Map", bufferMap)
	--添加特效
	for k,v in pairs(bufferMap) do
		--是否跳过
	    if FightMainLoop.getIsSkip() == true then
	        return
	    end
		--buffer添加特效
		local bufferId = v.bufferId
		local card = FightScene.getCardByHid(v.targetHid)
		local bufferName = getBufferEffectName(bufferId, BufferShowType.ENBUFFER)
		if bufferName then
			local bufferEffPath = FightUtil.getEffectPath(bufferName)
			local bufferPos = getBufferEffectPos(bufferId, BufferShowType.ENBUFFER, card)
			local bufferEff = XMLSprite:create(bufferEffPath)
			bufferEff:setPosition(bufferPos)
			bufferEff:setReplayTimes(1, true)
			card:addChild(bufferEff, 200)
			bufferEff:registerEndCallback(function ( ... )
				--显示buffer 图标
				card:addBufferIcon(bufferId)
				playCallbackFunc()
			end)
		else
			--显示buffer 图标
			card:addBufferIcon(bufferId)
			playCallbackFunc()
		end
	end
end

--[[
	@des:buffers生效
	@parm:pBlockInfo 描述
	@ret:ret 描述
--]]
function playBuffer(pBlockInfo, pAddTime, pCallback )
	--是否跳过
    if FightMainLoop.getIsSkip() == true then
        return
    end
	-- print("playBuffer")
    local attackHid = pBlockInfo.attacker
	local atkCard = FightScene.getCardByHid(attackHid)
	local bufferCount = getBlockBufferCount(pBlockInfo, BufferShowType.BUFFER, pAddTime)
	if bufferCount == 0 then
		if pCallback then
			pCallback()
			return
		end
	end
	--播放完毕回调
	local playTime = 0
	local playCallbackFunc = function ()
		playTime = playTime + 1
		-- print("bufferCount", bufferCount)
		-- print("playTime", playTime)
		if playTime == bufferCount then
			if pCallback then
				pCallback()
				return
			end
		end
	end
	local bufferMap = {}
   	--攻击者buffer
   	if pBlockInfo.buffer then
   		for k,v in pairs(pBlockInfo.buffer) do
   			local bufferId = v.bufferId  
	   		local bufferAddType = getBufferPlayTime(bufferId, BufferShowType.BUFFER)
	   		--检查buffer执行时间
	   		if tonumber(bufferAddType) == tonumber(pAddTime) then
	   			local buffObj = v
	   			buffObj.targetHid = attackHid
	   			table.insert(bufferMap, buffObj)
	   		end
   		end
   	end
   	--被攻击者buffer
   	if pBlockInfo.arrReaction then
		for k,v in pairs(pBlockInfo.arrReaction) do
			if v.buffer then
				for key,valude in pairs(v.buffer) do
					local bufferId = valude.bufferId 
	   				local bufferAddType = getBufferPlayTime(bufferId, BufferShowType.BUFFER)
	   				--检查buffer执行时间
	   				-- print("bufferId", bufferId)
	   				-- print("bufferAddType", bufferAddType)
	   				-- print("pAddTime", pAddTime)
			   		if tonumber(bufferAddType) == tonumber(pAddTime) then
			   			local buffObj = valude
			   			buffObj.targetHid = v.defender
			   			table.insert(bufferMap, buffObj)
			   		end
				end
			end
		end
	end
	--如果没有需要播放的buffer 则返回
	if table.count(bufferMap) == 0 then
		if pCallback then
			pCallback()
			return
		end
	end
	-- printTable("bufferMap", bufferMap)
	--buffer生效特效
	for k,v in pairs(bufferMap) do
		--是否跳过
	    if FightMainLoop.getIsSkip() == true then
	        return
	    end
		--buffer生效特效
		local bufferId = v.bufferId
		local card = FightScene.getCardByHid(v.targetHid)
		local bufferName = getBufferEffectName(bufferId, BufferShowType.BUFFER)
		if bufferName then
			local bufferEffPath = FightUtil.getEffectPath(bufferName)
			local bufferPos = getBufferEffectPos(bufferId, BufferShowType.BUFFER, card)
			local bufferEff = XMLSprite:create(bufferEffPath)
			bufferEff:setPosition(bufferPos)
			bufferEff:setReplayTimes(1, true)
			card:addChild(bufferEff, 200)
			bufferEff:registerEndCallback(playCallbackFunc)
			local bufferInfo = DB_Buffer.getDataById(bufferId)
			local musicName = bufferInfo.damageEff or bufferName
			AudioUtil.playEffect("audio/effect/"..musicName..".mp3")
		else
			playCallbackFunc()
		end
		--显示buffer 伤害或者加成
		if v.type == BufferType.HP then
			card:showAddHpEffect(v.data, 1, false,bufferId)
		elseif v.type == BufferType.RAGE then
			card:showAddRageEffect(v.data)
			card:addRage(v.data)
		end
	end
end

--[[
	@des:buffers消失
	@parm:pBlockInfo 描述
	@ret:ret 描述
--]]
function playDebuffer(pBlockInfo, pAddTime, pCallback )
	--是否跳过
    if FightMainLoop.getIsSkip() == true then
        return
    end
	print("playDebuffer")
    local attackHid = pBlockInfo.attacker
	local atkCard = FightScene.getCardByHid(attackHid)
	local bufferCount = getBlockBufferCount(pBlockInfo, BufferShowType.DEBUFFER, pAddTime)
	if bufferCount == 0 then
		if pCallback then
			pCallback()
			return
		end
	end
	--播放完毕回调
	local playTime = 0
	local playCallbackFunc = function ()
		playTime = playTime + 1
		if playTime == bufferCount then
			if pCallback then
				pCallback()
				return
			end
		end
	end
	local bufferMap = {}
   	--攻击者buffer
   	if pBlockInfo.deBuffer then
   		for k,v in pairs(pBlockInfo.deBuffer) do
   			local bufferId = v  
	   		local bufferAddType = getBufferPlayTime(bufferId, BufferShowType.DEBUFFER)
	   		--检查buffer执行时间
	   		if tonumber(bufferAddType) == tonumber(pAddTime) then
	   			local buffObj = {}
	   			buffObj.targetHid = attackHid
	   			buffObj.bufferId  = v
	   			table.insert(bufferMap, buffObj)
	   		end
   		end
   	end
   	--被攻击者buffer
   	if pBlockInfo.arrReaction then
		for k,v in pairs(pBlockInfo.arrReaction) do
			if v.deBuffer then
				for key,valude in pairs(v.deBuffer) do
					local bufferId = valude  
	   				local bufferAddType = getBufferPlayTime(bufferId, BufferShowType.DEBUFFER)
	   				--检查buffer执行时间
			   		if tonumber(bufferAddType) == tonumber(pAddTime) then
			   			local buffObj = {}
			   			buffObj.targetHid = v.defender
			   			buffObj.bufferId  = valude
			   			table.insert(bufferMap, buffObj)
			   		end
				end
			end
		end
	end
	--如果没有需要播放的buffer 则返回
	if table.count(bufferMap) == 0 then
		if pCallback then
			pCallback()
			return
		end
	end
	printTable("deBuffer map", bufferMap)
	--debuffer删除特效
	for k,v in pairs(bufferMap) do
		--是否跳过
	    if FightMainLoop.getIsSkip() == true then
	        return
	    end
		local bufferId = v.bufferId
		local card = FightScene.getCardByHid(v.targetHid)
		--删除状态特效
		card:removeBufferIcon(bufferId)
		--debuffer删除特效
		local bufferName = getBufferEffectName(bufferId, BufferShowType.DEBUFFER)
		if bufferName then
			local bufferEffPath = FightUtil.getEffectPath(bufferName)
			local bufferPos = getBufferEffectPos(bufferId, BufferShowType.DEBUFFER, card)
			local bufferEff = XMLSprite:create(bufferEffPath)
			bufferEff:setPosition(bufferPos)
			bufferEff:setReplayTimes(1, true)
			card:addChild(bufferEff, 200)
			bufferEff:registerEndCallback(playCallbackFunc)
		else
			playCallbackFunc()
		end
	end
end

--[[
	@des:buffers免疫
	@parm:pBlockInfo 描述
	@ret: 描述
--]]
function playImBuffer( pBlockInfo, pAddTime, pCallback )
	printTable("playImBuffer pBlockInfo", pBlockInfo)
	--是否跳过
    if FightMainLoop.getIsSkip() == true then
        return
    end
	local attackHid = pBlockInfo.attacker
	local atkCard = FightScene.getCardByHid(attackHid)
	local bufferCount = getBlockBufferCount(pBlockInfo, BufferShowType.IMBUFFER, pAddTime)
	print("playImBuffer bufferCount", bufferCount)
	if bufferCount == 0 then
		print("bufferCount == 0")
		if pCallback then
			print("bufferCount == 0 pCallback")
			pCallback()
			return
		end
	end
	local bufferMap = {}
   	--攻击者buffer
   	if pBlockInfo.imBuffer then
   		for k,v in pairs(pBlockInfo.imBuffer) do
   			local bufferId = v  
	   		local bufferAddType = getBufferPlayTime(bufferId, BufferShowType.IMBUFFER)
	   		--检查buffer执行时间
	   		print("pAddTime=",pAddTime)
	   		print("bufferAddType=",bufferAddType)
	   		if tonumber(bufferAddType) == tonumber(pAddTime) then
	   			local buffObj = {}
	   			buffObj.targetHid = attackHid
	   			buffObj.bufferId  = v
	   			table.insert(bufferMap, buffObj)
	   		end
   		end
   	end
   	--被攻击者buffer,
   	if pBlockInfo.arrReaction then
		for k,v in pairs(pBlockInfo.arrReaction) do
			if v.imBuffer then
				for key,valude in pairs(v.imBuffer) do
					local bufferId = valude  
	   				local bufferAddType = getBufferPlayTime(bufferId, BufferShowType.IMBUFFER)
	   				--检查buffer执行时间
	   				print("pAddTime=",pAddTime)
	   				print("bufferAddType=",bufferAddType)
			   		if tonumber(bufferAddType) == tonumber(pAddTime) then
			   			local buffObj = {}
			   			buffObj.targetHid = v.defender
			   			buffObj.bufferId  = valude
			   			table.insert(bufferMap, buffObj)
			   		end
				end
			end
		end
	end
	printTable(GetLocalizeStringBy("key_10279"), bufferMap)
	--如果没有需要播放的buffer 则返回
	if table.count(bufferMap) == 0 then
		if pCallback then
			pCallback()
			return
		end
	end
	--播放完毕回调
	local playTime = 0
	local playCallbackFunc = function ()
		playTime = playTime + 1
		if playTime == bufferCount then
			if pCallback then
				pCallback()
				return
			end
		end
	end
	
	--imbuffer免疫特效
	for k,v in pairs(bufferMap) do
		--imbuffer免疫特效
		local bufferId = v.bufferId
		local card = FightScene.getCardByHid(v.targetHid)
		local tipSpriet = CCSprite:create("images/battle/number/immunity.png")
		tipSpriet:setAnchorPoint(ccp(0.5, 0.5))
		tipSpriet:setPosition(ccpsprite(0.5,0.75, card))
		card:addChild(tipSpriet)

		local actionArray = CCArray:create()
		actionArray:addObject(CCScaleTo:create(0.1,2))
		actionArray:addObject(CCScaleTo:create(0.05,1))
		actionArray:addObject(CCDelayTime:create(1))
		actionArray:addObject(CCScaleTo:create(0.08,0.01))
		actionArray:addObject(CCCallFuncN:create(function ( pNode )
	    	pNode:removeFromParentAndCleanup(true)
	    	playCallbackFunc()
	    end))
	    tipSpriet:runAction(CCSequence:create(actionArray))
	end
end

--[[
	@des:得到buffer 播放时间
	@pram:bufferId
	@int:播放时间
--]]
function getBufferPlayTime( pBufferId, pBufferShowType )
	local bufferDBInfo = DB_Buffer.getDataById(pBufferId)
	local playTimeType = 0
	if pBufferShowType == BufferShowType.ENBUFFER then
		--添加
		playTimeType = bufferDBInfo.addTimeType
	elseif pBufferShowType == BufferShowType.BUFFER then
		--生效
		playTimeType = bufferDBInfo.damageTimeType

	elseif pBufferShowType == BufferShowType.DEBUFFER then
		--移除
		playTimeType = bufferDBInfo.removeTimeType
	elseif pBufferShowType == BufferShowType.IMBUFFER then
		--免疫
		playTimeType = BufferTimeType.LATER
	else
		error("buffer show type error:", pBufferShowType)
	end
	return playTimeType
end


--[[
	@des:得到buffer的特效名称
	@parm:bufferId
	@ret: string buffer特效名称
--]]
function getBufferEffectName( pBufferId, pBufferShowType )
	local bufferDBInfo = DB_Buffer.getDataById(pBufferId)
	local playEffectName = nil
	if pBufferShowType == BufferShowType.ENBUFFER then
		--添加
		playEffectName = bufferDBInfo.addEff
	elseif pBufferShowType == BufferShowType.BUFFER then
		--生效
		playEffectName = bufferDBInfo.damageEff

	elseif pBufferShowType == BufferShowType.DEBUFFER then
		--生效
		playEffectName = bufferDBInfo.disappearEff
	else
		error("buffer show type error:", pBufferShowType)
	end
	return playEffectName
end


--[[
    @des:得到打击特效播放位置
    @parm:pPos 特效挂点
    @parm:pCard 播放特效的卡片
    @ret: postion
--]]
function getBufferEffectPos( pBufferId, pBufferShowType, pCard)
	local bufferDBInfo = DB_Buffer.getDataById(pBufferId)
	local pos = CardEffectPos.HERT
	if pBufferShowType == BufferShowType.ENBUFFER then
		--添加
		pos = tonumber(bufferDBInfo.addPosition)
	elseif pBufferShowType == BufferShowType.BUFFER then
		--生效
		pos = tonumber(bufferDBInfo.damagePosition)
	else
		error("buffer show type error:", pBufferShowType)
	end
    local posMap = {
        [CardEffectPos.HEAD] = ccpsprite(0.5, 0.9, pCard),
        [CardEffectPos.HERT] = ccpsprite(0.5, 0.5, pCard),
        [CardEffectPos.FOOT] = ccpsprite(0.5, 0.1, pCard),
    }
    -- print("getBufferEffectPos pos:",pos)
    local bufferPos = posMap[pos]
    return bufferPos
end


--[[
	@des:得到数据块中指定buffer 的数量
    @parm:pBufferShowType buffer类型
    @parm:buffer 添加时间
    @ret: int buffer数量
--]]
function getBlockBufferCount( pBlockInfo, pBufferShowType, pAddTime )
	
	local bufferKeys = {
		[BufferShowType.ENBUFFER] 	= "enBuffer",
		[BufferShowType.BUFFER]		= "buffer",
		[BufferShowType.DEBUFFER]	= "deBuffer",
		[BufferShowType.IMBUFFER]	= "imBuffer",
	}

	local bufferTypeKeys = {
		[BufferShowType.ENBUFFER] 	= "addTimeType",
		[BufferShowType.BUFFER]		= "damageTimeType",
		[BufferShowType.DEBUFFER]	= "removeTimeType",
		[BufferShowType.IMBUFFER]	= "imBufferTimeType",
	}
	local key = bufferKeys[pBufferShowType]
	local typeKey = bufferTypeKeys[pBufferShowType]
	--1.找到所有buffer
	local bufferMap = {}
	if pBlockInfo[key] then
		for k,v in pairs(pBlockInfo[key]) do
			if pBufferShowType ==  BufferShowType.BUFFER then
				table.insert(bufferMap, v)
			else
				local bufferObj = {}
				bufferObj.bufferId = v
				table.insert(bufferMap, bufferObj)
			end
		end
	end
	if pBlockInfo.arrReaction then
		for k1,v1 in pairs(pBlockInfo.arrReaction) do
			if v1[key] then
				for k2,v2 in pairs(v1[key]) do
					if pBufferShowType == BufferShowType.BUFFER then
						table.insert(bufferMap, v2)
					else
						local bufferObj = {}
						bufferObj.bufferId = v2
						table.insert(bufferMap, bufferObj)
					end
				end
			end
		end
	end
	-- printTable("getBlockBufferCount bufferMap" .. "[" ..key.. "]", bufferMap)
	--2.过滤当前时间的buffer
	local count = 0
	for k,v in pairs(bufferMap) do
		local bufferDBInfo = DB_Buffer.getDataById(v.bufferId)
		-- print("bufferDBInfo[typeKey]",bufferDBInfo[typeKey])
		-- print("pAddTime", pAddTime)
		bufferDBInfo.imBufferTimeType = BufferTimeType.LATER
		if tonumber(bufferDBInfo[typeKey]) == tonumber(pAddTime) then
			count = count + 1
		end
	end
	-- print("count:", count)
	return count
end

--[[
	@des:得到buffer持续特效
--]]
function getBufferIconName( pBufferId )
	local bufferDBInfo = DB_Buffer.getDataById(pBufferId)
	return  bufferDBInfo.icon
end

--[[
	@des:得到buffer 持续特效挂点
--]]
function getBufferIconPos( pBufferId , pCard)
	local bufferDBInfo = DB_Buffer.getDataById(pBufferId)
	local pos = bufferDBInfo.positon
	local posMap = {
        [CardEffectPos.HEAD] = ccpsprite(0.5, 0.9, pCard),
        [CardEffectPos.HERT] = ccpsprite(0.5, 0.5, pCard),
        [CardEffectPos.FOOT] = ccpsprite(0.5, 0.1, pCard),
    }
    local bufferPos = posMap[pos]
    return bufferPos
end
