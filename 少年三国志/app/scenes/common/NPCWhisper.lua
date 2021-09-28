local NPCWhisper = class("NPCWhisper", UFCCSNormalLayer)

local SPEAK_DIR = {
	LEFT = 1,
	RIGHT = 2,
}
NPCWhisper.SPEAK_DIR = SPEAK_DIR

local BUBBLE_STATE = {
	OPEN = 1,
	CLOSE = 2,
}

-- 副本类型
NPCWhisper.TYPE_DUNGEON = 1
NPCWhisper.TYPE_STORYDUNGEON = 2

local FINIAL_SCALE_SIZE = 0.9
local SHOW_DURATION = 5
local SCALE_DURATION = 0.5

function NPCWhisper.create(nDir, szText, nDungetonType, ...)
	local nType = nDungetonType or NPCWhisper.TYPE_DUNGEON
	if nDir == SPEAK_DIR.LEFT then
		if nType == NPCWhisper.TYPE_DUNGEON then
			return NPCWhisper.new("ui_layout/dungeon_DungeonNPCWhisper1.json", nil, nDir, szText, ...)
		elseif nType == NPCWhisper.TYPE_STORYDUNGEON then
			return NPCWhisper.new("ui_layout/storydungeon_StoryDungeonNPCWhisper1.json", nil, nDir, szText, ...)
		end
	else
		if nType == NPCWhisper.TYPE_DUNGEON then
			return NPCWhisper.new("ui_layout/dungeon_DungeonNPCWhisper2.json", nil, nDir, szText, ...)
		elseif nType == NPCWhisper.TYPE_STORYDUNGEON then
			return NPCWhisper.new("ui_layout/storydungeon_StoryDungeonNPCWhisper2.json", nil, nDir, szText, ...)
		end 
	end
end

function NPCWhisper:ctor(json, func, nDir, szText, ...)
	self.super.ctor(self, json, func, ...)

	self._nDir = nDir
	self._tTimer = nil
	self._nBubbleState = BUBBLE_STATE.OPEN
	self:_initWidgets(szText)
	self:_start()
end

function NPCWhisper:onLayerEnter()

end

function NPCWhisper:onLayerExit()
	if self._tTimer then
		G_GlobalFunc.removeTimer(self._tTimer)
		self._tTimer = nil
	end
end

function NPCWhisper:_initWidgets(szText)
	local labelWhisper = self:getLabelByName("Label_Desc")
	labelWhisper:setText(szText)
	local imgBubble = self:getImageViewByName("Image_Bg")
	imgBubble:setScale(FINIAL_SCALE_SIZE)
end

function NPCWhisper:_start()
	local imgBubble = self:getImageViewByName("Image_Bg")
	--[[
	imgBubble:setScale(0)
	local actScaleTo = CCScaleTo:create(SCALE_DURATION, FINIAL_SCALE_SIZE)
	local actCallFunc = CCCallFunc:create(function()
		if not self._tTimer then
			self._nBubbleState = BUBBLE_STATE.OPEN
			self._tTimer = G_GlobalFunc.addTimer(SHOW_DURATION, handler(self, self._animationToShow))
		end
	end)
	local array = CCArray:create()
	array:addObject(actScaleTo)
	array:addObject(actCallFunc)
	local actSeq = CCSequence:create(array)
	imgBubble:runAction(actSeq)
	]]
--GlobalFunc.sayAction(widget,hide,callback,move,hideTime)

	local function funcAgain()
		G_GlobalFunc.sayAction(imgBubble, true, funcAgain, false, 5, 0.8)
	end
	G_GlobalFunc.sayAction(imgBubble, true, funcAgain, false, 5, 0.8)
end

function NPCWhisper:_animationToShow( ... )
	local imgBubble = self:getImageViewByName("Image_Bg")

	if self._nBubbleState == BUBBLE_STATE.OPEN then
		local actScaleTo = CCScaleTo:create(SCALE_DURATION, 0)
		imgBubble:runAction(actScaleTo)
		self._nBubbleState = BUBBLE_STATE.CLOSE
	else
		local actScaleTo = CCScaleTo:create(SCALE_DURATION, FINIAL_SCALE_SIZE)
		imgBubble:runAction(actScaleTo)
		self._nBubbleState = BUBBLE_STATE.OPEN
	end
end

return NPCWhisper