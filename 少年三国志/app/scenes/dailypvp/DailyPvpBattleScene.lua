local DailyPvpBattleScene = class("DailyPvpBattleScene",UFCCSBaseScene)

function DailyPvpBattleScene:ctor(...)
    self.super.ctor(self, ...)
end

function DailyPvpBattleScene:onSceneLoad( report,data )   
    self._isReplay = data.isReplay
    self._mainBody = require("app.scenes.dailypvp.DailyPvpBattleLayer").create(report,data)
    self:addUILayerComponent("DailyPvpLayer", self._mainBody, true)
end

function DailyPvpBattleScene:onSceneUnload()
	
end

function DailyPvpBattleScene:onSceneEnter(  )
    self:adapterLayerHeight(self._mainBody, nil, nil, 0, 0)
    self._mainBody:adapterLayer()
    if G_topLayer and not self._isReplay then 
        G_topLayer:showTemplate()
        G_topLayer:resetChatDefaultChannel(4)
    end
    G_Me.dailyPvpData:goBattle(true)
    G_SoundManager:playBackgroundMusic(require("app.const.SoundConst").BackGroundMusic.PVP)
end
 
function DailyPvpBattleScene:onSceneExit( ... )
    if G_topLayer and not self._isReplay then 
        G_topLayer:resumeStatus()
        G_topLayer:resetChatDefaultChannel()
    end
    G_Me.dailyPvpData:goBattle(false)
end


return DailyPvpBattleScene