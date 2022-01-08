-- return {szActionName = string, FPS = int, duration = int}
function EditLua:addUIAction(szId, tParams)
	print("addUIAction")
	if targets[szId].animationModel__ == nil then
		TFUIBase:initAction(targets[szId], {})
	end
	targets[szId].animationModel__ = targets[szId].animationModel__ or {}
	local model = targets[szId].animationModel__
	model.actions = model.actions or {}
	if model.actions[tParams.szActionName] then TFLOGINFO("the action is exsit!!!!!!!!!!!!!!!!!!!!") end
	model.actions[tParams.szActionName] = {}
	model.actions[tParams.szActionName].actionModel = {}
	model.actions[tParams.szActionName].fps = tParams.FPS
	model.actions[tParams.szActionName].duration = tParams.duration

	print("addUIAction success")
end

--return {szActionName = string}
function EditLua:removeUIAction(szId, tParams)
	print("removeUIAction")
	for i, v in pairs(targets[szId].animationModel__.actions[tParams.szActionName].actionModel) do
		-- local target = targets[v]
		local target = v
		target.animationFrames__[tParams.szActionName] = nil
	end
	targets[szId].animationModel__.actions[tParams.szActionName] = nil
	print("removeUIAction success")
end

-- return {szActionName = string, szControlID = string}
function EditLua:addActionControl(szId, tParams)
	print("addActionControl")
	local model = targets[szId].animationModel__
	local actionModel = model.actions[tParams.szActionName].actionModel

	local t = {}
	local target = targets[tParams.szControlID]
	if target == nil then
		print("=========================== didn't have this control================")
		return
	end
	target.animationFrames__ = target.animationFrames__ or {}
	target.animationFrames__[tParams.szActionName] = target.animationFrames__[tParams.szActionName] or {}

	if tParams.nScaleX and tParams.nScaleY then
		targets[tParams.szControlID]._actionBaseAttribute = targets[tParams.szControlID]._actionBaseAttribute or {}
		targets[tParams.szControlID]._actionBaseAttribute.scaleX = tParams.nScaleX
		targets[tParams.szControlID]._actionBaseAttribute.scaleY = tParams.nScaleY
	end

	table.insert(actionModel, targets[tParams.szControlID])
	print("addActionControl success")
end
--return {szActionName = string, szControlID = string}
function EditLua:removeActionControl(szId, tParams)
	print("removeActionControl")
	local target = targets[tParams.szControlID]
	target.animationFrames__[tParams.szActionName] = nil

	local model = targets[szId].animationModel__
	local actionModel = model.actions[tParams.szActionName].actionModel
	for i, v in ipairs(actionModel) do
		if v == targets[szControlID] then
			table.remove(actionModel, i)
			break
		end
	end
	-- table.remove(actionModel, szControlID)

	print("removeActionControl success")
end

-- return { szActionName = string, szControlID = string, frames = {frame = int, position = {x = int, y = int}, .....}}
function EditLua:addControlKeyFrame(szId, tParams)
	print("addControlKeyFrame")
	local model = targets[szId].animationModel__
	local action = model.actions[tParams.szActionName]
	local nFPSInterval = 1.0 / action.fps
	local target = targets[tParams.szControlID]

	tParams.frames.enterTime = tParams.frames.frame * nFPSInterval
	local targetFrames = target.animationFrames__[tParams.szActionName]
	table.insert(targetFrames, tParams.frames)	--insert the first frame
	print("addControlKeyFrame success")
end

local function getTargetKeyMsg(szID)
	local target = targets[szID]
	local pos = target:getPosition()
	local posPerEnabled = (target:getPositionType() == 1)
	local posPer = target:getPositionPercent()
	local scaleX, scaleY = target:getScaleX(), target:getScaleY()
	local rotate = target:getRotation()
	local visible = target:isVisible()
	if target._actionBaseAttribute then 
		print("baseScale:", target._actionBaseAttribute.scaleX, target._actionBaseAttribute.scaleY)
		scaleX = scaleX / target._actionBaseAttribute.scaleX
		scaleY = scaleY / target._actionBaseAttribute.scaleY
	end
	target._animation_tween_ = target._animation_tween_ or true
	szGlobleResult = string.format("x=%d,y=%d,scaleX=%.2f,scaleY=%.2f,rotate=%d,tweenToNext=%s,visible=%s, posPerEnabled = %s, xPer=%.2f, yPer = %.2f,", 
		pos.x, pos.y, scaleX, scaleY, rotate, tostring(target._animation_tween_), tostring(visible), tostring(posPerEnabled), posPer.x*100, posPer.y*100)
	if target:getDescription() == "TFParticle" then
		target._animation_play_ = target._animation_play_ or false
		szGlobleResult = szGlobleResult .. getParticleAttributeMsg(target)
		szGlobleResult = szGlobleResult .. string.format("IsPlaying = %s", tostring(target._animation_play_))
	else
		local color = target:getColor()
		local alpha = target:getOpacity()
		szGlobleResult = szGlobleResult .. string.format("r=%d,g=%d,b=%d,alpha=%d,", color.r, color.g, color.b, alpha)

		if target:getDescription() == "TFImage" then
			local mixColor = target:getMixColor()
			szGlobleResult = szGlobleResult .. string.format("mixR=%d,mixG=%d,mixB=%d,mixA=%d", mixColor.r, mixColor.g, mixColor.b, mixColor.a)
		end
	end
	setGlobleString(szGlobleResult)
end

-- return {szActionName = string, szControlID = string, nKeyFrame = int, frames = {frame = int, position = {x = int, y = int}, .....}}
function EditLua:updateControlKeyFrame(szId, tParams)
	print("updateControlKeyFrame")
	local target = targets[tParams.szControlID]
	local targetFrames = target.animationFrames__[tParams.szActionName]
	for i, v in ipairs(targetFrames) do
		if v.frame == tParams.nKeyFrame then
			local newFrame = tParams.frames
			for j, m in pairs(newFrame) do
				print("update frame;", j)
				v[j] = m
			end
			if newFrame.percentenable ~= nil then
				v.percentenable = newFrame.percentenable
				if v.percentenable then
					target:setPositionType(1)
				else
					target:setPositionType(0)
				end
			end
		end
	end
	print("updateControlKeyFrame success")
end
-- return {szActionName = string, nFrame = int, szID = string}
function EditLua:updateToFrame(szId, tParams)
	print("updateToFrame")
	if tParams.szID and tParams.szID ~= "" then
		getTargetKeyMsg(tParams.szID)
	else
		targets[szId]:updateToFrame(tParams.szActionName, tParams.nFrame)
	end
	print("updateToFrame success", szGlobleResult)
end
--return {szActionName = string, nRound = int} //nRound == -1 表示无限循环
function EditLua:runUIAction(szId, tParams)
	print("runUIAction")
	targets[szId]:runAnimation(tParams.szActionName, tParams.nRound)
	print("runUIAction success")
end
-- return {tData = table}
function EditLua:updateUIActionData(szId, tParams)
	print("updateUIActionData")
	EditLua:cleanUIAction(szId, nil)
	TFUIBase:initAction(targets[szId], tParams.tData.actions)
	print("updateUIActionData success")
end

function EditLua:cleanUIAction(szId, tParams)
	print("cleanUIAction")
	if targets[szId].animationModel__ then 
		for actionName, v in pairs(targets[szId].animationModel__.actions) do
			for _, comp in pairs(targets[szId].animationModel__.actions[actionName].actionModel) do
				-- local target = targets[id]
				comp.animationFrames__[actionName] = nil
			end
		end
	end
	targets[szId].animationModel__ = nil
	print("cleanUIAction success")
end