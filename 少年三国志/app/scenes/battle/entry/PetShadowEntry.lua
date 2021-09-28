local PetShadowEntry = class("PetShadowEntry", require("app.scenes.battle.entry.SkeletonEntry"))

function PetShadowEntry:ctor(spJson, objects, battleField, eventHandler, jumpToEvent, isRepeat)
	--PetShadowEntry.super.super.ctor(self, spJson, objects, battleField, eventHandler)

	local spId = spJson.spId
	local spFilePath = "battle/sp/" .. spId .. "/" .. spId

	self._spJsonName = spFilePath .. ".json"
	self._spJsonContent = self:getJson(self._spJsonName) or decodeJsonFile(self._spJsonName)

	-- create the base node
	self._node = display.newNode()
	self._node:setCascadeOpacityEnabled(true)
	self._node:setCascadeColorEnabled(true)
	self._node:retain()

	-- load resource
	if self._spJsonContent.png and self._spJsonContent.png ~= "" then
		local texFullPath = CCFileUtils:sharedFileUtils():fullPathForFilename(spFilePath..".png")
		if CCFileUtils:sharedFileUtils():isFileExist(texFullPath) then
			display.addSpriteFramesWithFile(spFilePath..".plist", spFilePath..".png")
		end
	end

	-- call Entry's constructor
	PetShadowEntry.super.super.super.ctor(self, spJson, objects, battleField, eventHandler)

	self:initWithSpJson(spJson)

	-- array to store the sub-sp referenced by this entry and step function
	self._spArr 	= {}
	self._spStepArr = {}

	-- default color offset
	self._colorOffset = {0, 0, 0, 0}
    setmetatable(self._colorOffset, {__index = function(t, k)
        if k == "r" then return t[1]
        elseif k == "g" then return t[2]
        elseif k == "b" then return t[3]
        elseif k == "a" then return t[4]
        end
    end})
    
    self._colorOffset.set = function(r, g, b, a)
        self._colorOffset[1] = r
        self._colorOffset[2] = g
        self._colorOffset[3] = b
        self._colorOffset[4] = a
    end

    self:jumpToDefaultEvent("ready")
    self.isSkeleton = true
end

function PetShadowEntry:initEntry()
    PetShadowEntry.super.super.super.initEntry(self)

    if self._spArr then
        for k, sp in pairs(self._spArr) do
            if sp.isEntry then
                if sp:getObject():getParent() then
                    sp:getObject():removeFromParent()
                end
            elseif sp.clipNode and sp.clipNode:getParent() then
                sp.clipNode:removeFromParent()
            elseif sp:getParent() then
                sp:removeFromParent()
            end
        end
    end
    
    -- 清理sp的step函数
    self._spStepArr = {}
    
    -- 这里添加需要增加的序列
    self:addEntryToQueue(self, self.update)
end

function PetShadowEntry:pause()
    self._pausePlay = true
end

function PetShadowEntry:resume()
    self._pausePlay = false
end

function PetShadowEntry:update(frameIndex)
    if not self._pausePlay then
        return self.super.update(self, frameIndex)
    end

    return false
end

function PetShadowEntry:jumpToOut(isRepeat)
	return self:jumpTo("out", isRepeat)
end

return PetShadowEntry