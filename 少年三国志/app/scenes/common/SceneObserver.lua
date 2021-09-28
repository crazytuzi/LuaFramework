
local SceneObserver =  class("SceneObserver")



function SceneObserver:ctor()
    self._currentSceneName = ""



    UFCCSUIHooker.hookerScene(function (se, sceneName, flag, scene, ... )
        if flag == "enter" then
             self._currentSceneName = sceneName

            if G_Report then
                G_Report:addHistory("enter", self._currentSceneName)
            end
            --保证主场景肯定有网络连接
            if sceneName == "MainScene" or sceneName == "BagScene" or sceneName == "ShopScene" 
                or sceneName == "PlayingScene"   or sceneName == "DungeonMainScene" or sceneName == "HeroScene"  then
                G_NetworkManager:checkConnection()
            end

            if patchMe and patchMe("enter", sceneName) then return end  

             uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_SPEEDBAR, nil, false,sceneName)
             uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_SCENE_CHANGED, nil, false, self._currentSceneName)
        elseif flag == "exit" then
            self._currentSceneName = ""

            if patchMe and patchMe("leave") then return end 
        end
        
        

    end, self)
end

function SceneObserver:getSceneName()
    return self._currentSceneName
end



function SceneObserver:clear()
    UFCCSUIHooker.unHookerWithTarget(self)
end



return SceneObserver
