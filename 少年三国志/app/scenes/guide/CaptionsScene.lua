--CaptionsScene.lua


local CaptionsScene = class("CaptionsScene", UFCCSBaseScene)


function CaptionsScene:ctor( ... )
	
	self.super.ctor(self, ...)
end

function CaptionsScene:onSceneLoad( jsonFile, asyncFunc, textId, callbackFunc )
	self._mainLayer = require("app.scenes.guide.CaptionLayer").new("ui_layout/guide_CaptionLayer.json")
	self:addChild(self._mainLayer)
	self._mainLayer:initCallback(textId, callbackFunc)
end


return CaptionsScene
