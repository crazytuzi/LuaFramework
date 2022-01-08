--[[
******资源管理*******

	-- by jin
	-- 2017/3/06
]]

local ModelManager = class("ModelManager")

function ModelManager:ctor(data)
	self.dirs = {[1] = {"skeleton/", "armature/"}, [2] = {"eft/", "effect/"}}
	-- self.events = {ANIMATION_COMPLETE={[1]=TFSKELETON_COMPLETE, [2]=TFARMATURE_COMPLETE}, ANIMATION_UPDATE={[1]=TFSKELETON_UPDATE, [2]=TFARMATURE_UPDATE}}}
	self.events = {ANIMATION_COMPLETE={[1]=TFSKELETON_COMPLETE, [2]=TFARMATURE_COMPLETE}}
end

-- resType {1:model 2:effect}
function ModelManager:addResourceFromFile(resType, resName, scale)
	-- scale = 0.55
	local dir = self.dirs[resType][1]
	if TFFileUtil:existFile(dir..resName..".json") then
		TFResourceHelper:instance():addSkeletonFromFile(dir..resName, scale)
		return
	end

	dir = self.dirs[resType][2]
	if TFFileUtil:existFile(dir..resName..".xml") then
		TFResourceHelper:instance():addArmatureFromJsonFile(dir..resName..".xml")
	end
end

function ModelManager:existResourceFile(resType, resName)
	local dir = self.dirs[resType][1]
	if TFFileUtil:existFile(dir..resName..".json") then
		return true
	end

	dir = self.dirs[resType][2]
	if TFFileUtil:existFile(dir..resName..".xml") then
		return true
	end

	return false
end

-- 1:skeleton 2:armature
function ModelManager:createResource(resType, resName)
	local dir = self.dirs[resType][1]
	local skeleton = TFSkeleton:create(dir..resName)
	if skeleton then
		skeleton.type = 1
		return skeleton
	end

	local armature = TFArmature:create(resName.."_anim")
	if armature then
		armature.type = 2
		return armature
	end
	
	return nil
end

-- res.type == 1 先检查index，为-1时看name
function ModelManager:playWithNameAndIndex(res, name, index, loop, durationTo, durationTween)
	if res.type == 1 then
		if index and index >= 0 then
			local allAnimName = res:getMovementNameStrings()
			name = string.split(allAnimName, ";")[index + 1]
		end
		res:play(name, loop)
	elseif res.type == 2 then
		if index and index >= 0 then
			res:playByIndex(index, durationTo, durationTween, loop)
		else
			res:play(name, durationTo, durationTween, loop)
		end
	end
end

function ModelManager:addListener(res, event, fun)
	local e = self.events[event][res.type]
	if not e then return end
	res:addMEListener(e, fun)
end

function ModelManager:removeListener(res, event)
	local e = self.events[event][res.type]
	if not e then return end
	res:removeMEListener(e)
end

function ModelManager:setAnimationFps(res, nAnimationFps)
	if res.type == 1 then
		res:setAnimationFps(nAnimationFps)
	else
		res:setAnimationFps(nAnimationFps / GameConfig.FPS * GameConfig.ANIM_FPS)
	end
end

return ModelManager:new()