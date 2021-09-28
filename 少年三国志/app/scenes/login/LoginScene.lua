local LoginScene = class("LoginScene", UFCCSBaseScene)


function LoginScene:ctor()
    self.super.ctor(self)

    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ENTER_GAME, handler(self,self._onEnter), self)


end


function LoginScene:onSceneLoad( ... )

    self._mainLayer = require("app.scenes.login.LoginMainLayer").create()
    self:addUILayerComponent("mainLayer", self._mainLayer, true)

    
end


function LoginScene:onSceneUnload()
	uf_eventManager:removeListenerWithTarget(self)
end



function LoginScene:onSceneEnter( ... )
    
 G_SoundManager:playBackgroundMusic(require("app.const.SoundConst").BackGroundMusic.MAIN)
end

function LoginScene:onSceneExit( ... )
	uf_funcCallHelper:callAfterFrameCount(15, function ( ... )
        TextureManger:getInstance():releaseUnusedTexture(false)
        CCSLayerBase:releaseTextureAtClose(true)
    end)
end


function LoginScene:_onEnter(data)
    uf_sceneManager:replaceScene(require("app.scenes.mainscene.MainScene").new())
end

return LoginScene
