local PetRealEntry = class("PetRealEntry", require("app.scenes.battle.entry.SpEntry"))

function PetRealEntry:ctor(spJson, objects, battleField, eventHandler, jumpToEvent, isRepeat)
	local spId = spJson.spId
	local spFilePath = "battle/pet/" .. spId .. "/" .. spId
	local spTexPath = "battle/pet/"

	self._spJsonName = spFilePath .. ".json"
	self._spJsonContent = self:getJson(self._spJsonName) or decodeJsonFile(self._spJsonName)

	-- create the base node
	self._node = display.newNode()
	self._node:setCascadeOpacityEnabled(true)
	self._node:setCascadeColorEnabled(true)
	self._node:retain()

	-- load resource
	local png = self._spJsonContent.png
	if png and png ~= "" then
		spTexFile = spTexPath .. png
		spPlistFile = string.gsub(spTexFile, ".png", ".plist")
		local texFullPath = CCFileUtils:sharedFileUtils():fullPathForFilename(spTexFile)
		if CCFileUtils:sharedFileUtils():isFileExist(texFullPath) then
			display.addSpriteFramesWithFile(spPlistFile, spTexFile)
		end
	end

	-- call Entry's constructor
	PetRealEntry.super.super.ctor(self, spJson, objects, battleField, eventHandler)

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
end

return PetRealEntry