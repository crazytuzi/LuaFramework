local CreateRoleScene = class("CreateRoleScene", UFCCSBaseScene)

local EffectNode = require "app.common.effects.EffectNode"
function CreateRoleScene:ctor()
    self.super.ctor(self)


    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ENTER_GAME, handler(self,self._onEnter), self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CREATED_ROLE, handler(self, self._onCreatedRole), self)
end

function CreateRoleScene:onSceneLoad( ... )

    GlobalFunc.uploadLog({{event_id="PlayDonghua"}})

	local effect  = EffectNode.new("effect_kaichang", function ( event )
		if event == "finish" then
			self:_onMediaPlayFinish()
            GlobalFunc.uploadLog({{event_id="FinishDonghua"}})

        elseif string.find(event, "k") == 1 then
            --kaichang sound
            -- print("play sound " .. event)
            G_SoundManager:playSound("audio/" .. event .. ".mp3")
		end
	end)
    effect:play()
    self:addChild(effect)

    local winSize = CCDirector:sharedDirector():getWinSize()
    effect:setPosition(ccp(winSize.width/2, winSize.height/2))

    self._skipLayer = self:addUILayerComponent("SkipLayer", "ui_layout/createrole_skipLayer.json", false, true)
    self._skipLayer:registerBtnClickEvent("Button_skip", function ( ... )
    	self:removeComponent(SCENE_COMPONENT_GUI, "SkipLayer")
    	self:_onMediaPlayFinish()
        GlobalFunc.uploadLog({{event_id="FinishDonghua"}})
    	if effect then 
    		effect:removeFromParentAndCleanup(true)
    	end
    end)
    
	--local sharedApplication = CCApplication:sharedApplication()
	--local target = sharedApplication:getTargetPlatform()

	-- local flag = CCUserDefault:sharedUserDefault():getIntegerForKey("play_animation_flag", 0)
	-- if flag == 0 then 
	-- 	if target == kTargetIphone or target == kTargetIpad  then 
	-- 		CCUserDefault:sharedUserDefault():setIntegerForKey("play_animation_flag", 1)
	-- 		CCUserDefault:sharedUserDefault():flush()
	-- 		G_NativeProxy.playMedia("res/audio/start", "mp4")
	-- 		uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_MEDIA_PLAY_FINISH, handler(self,self._onMediaPlayFinish), self)
	-- 	elseif target == kTargetAndroid then 
	-- 		CCUserDefault:sharedUserDefault():setIntegerForKey("play_animation_flag", 1)
	-- 		CCUserDefault:sharedUserDefault():flush()
	-- 		G_NativeProxy.playMedia("res/audio/start.mp4", "mp4")
	-- 		uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_MEDIA_PLAY_FINISH, handler(self,self._onMediaPlayFinish), self)
	-- 	else
	-- 		self:_onMediaPlayFinish()
	-- 	end
	-- else
	-- 	self:_onMediaPlayFinish()
	-- end
end

function CreateRoleScene:_showCreaetRoleLayer( ... )
	self._mainLayer = require("app.scenes.createrole.CreateRoleLayer").create()
    self:addUILayerComponent("mainLayer", self._mainLayer, true)
end

function CreateRoleScene:_onMediaPlayFinish( ... )
	self:_showCreaetRoleLayer()
end

function CreateRoleScene:onSceneUnload()
	uf_eventManager:removeListenerWithTarget(self)
end

function CreateRoleScene:_onEnter(data)
    --uf_sceneManager:replaceScene(require("app.scenes.mainscene.MainScene").new())
    G_SoundManager:playBackgroundMusic(require("app.const.SoundConst").BackGroundMusic.MAIN)
end

function CreateRoleScene:_onCreatedRole(  )

end


return CreateRoleScene
