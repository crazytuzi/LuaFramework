local QTutorialPhase = import("..QTutorialPhase")
local QTutorialPhaseInFirstBattle = class("QTutorialPhaseInFirstBattle", QTutorialPhase)
local prologue_config = import("..config.prologue_config")["xuzhang"]

function QTutorialPhaseInFirstBattle:start()
	self._event_idx = 0
    self.key_list = {}
    self:registerFunctions()
    self:registerKeys()
    self._stage:setClickCallBack(handler(self, self.playNextEvent))
    self._stage:setSkipCallback(handler(self, self.skipNext))
    self:playNextEvent()
end

function QTutorialPhaseInFirstBattle:registerKeys()
    self.key_list = {}
    for idx,cfg in ipairs(prologue_config) do
        if cfg.key then
            self.key_list[cfg.key] = idx
        end
    end
end

function QTutorialPhaseInFirstBattle:registerFunctions()
    self.functions = 
    {
        speak = QTutorialPhaseInFirstBattle.playString,
        changeBg = QTutorialPhaseInFirstBattle.changeBackground,
        hideDialog = QTutorialPhaseInFirstBattle.hideTypewriter,
        showDialog = QTutorialPhaseInFirstBattle.showTypewriter,
        finish = QTutorialPhaseInFirstBattle.playFinish,
        jump = QTutorialPhaseInFirstBattle.jumpToKey,
        sound = QTutorialPhaseInFirstBattle.playSound,
        music = QTutorialPhaseInFirstBattle.playMusic,
        stopMusic = QTutorialPhaseInFirstBattle.stopMusic,
        changeBgFadeIn = QTutorialPhaseInFirstBattle.fadeInChangeBackground,
        playMp4 = QTutorialPhaseInFirstBattle.playMp4,
        playCCBText = QTutorialPhaseInFirstBattle.playCCBText,
        delay = QTutorialPhaseInFirstBattle.delay,
        playCCB = QTutorialPhaseInFirstBattle.playCCB,
        fadeInPlayCCB = QTutorialPhaseInFirstBattle.fadeInPlayCCB,
    }
end

function QTutorialPhaseInFirstBattle:playCCB(cfg)
    self._stage:playCCB(cfg)
end

function QTutorialPhaseInFirstBattle:delay(cfg)
    self._stage:delay(cfg)
end

function QTutorialPhaseInFirstBattle:playCCBText(cfg)
    self._stage:playCCBText(cfg)
end

function QTutorialPhaseInFirstBattle:skipNext()
    local jumpIdx = #prologue_config
    local skipBuriedPoint
    for i = self._event_idx + 1,#prologue_config, 1 do
        local cfg = self:loadConfig(i)
        if cfg.skipKey then
            jumpIdx = i
            if cfg.skipBuriedPoint then
                skipBuriedPoint = cfg.skipBuriedPoint
            end
            break
        end
    end
    if skipBuriedPoint then
        app:triggerBuriedPoint(skipBuriedPoint)
    end
    self._event_idx = math.min(jumpIdx, #prologue_config)
    self:playEvent()
end

function QTutorialPhaseInFirstBattle:playMp4(cfg)
    self._stage:playMp4(cfg)
end

function QTutorialPhaseInFirstBattle:fadeInChangeBackground(cfg)
	self._stage:fadeInChangeBackground(cfg)
end

function QTutorialPhaseInFirstBattle:playString(cfg)
	self._stage:playString(cfg)
end

function QTutorialPhaseInFirstBattle:hideTypewriter()
    self._stage:hideTypewriter()
end

function QTutorialPhaseInFirstBattle:showTypewriter()
    self._stage:showTypewriter()
end

function QTutorialPhaseInFirstBattle:changeBackground(cfg)
	self._stage:changeBackground(cfg)
end

function QTutorialPhaseInFirstBattle:playMusic(cfg)
	self._stage:playMusic(cfg)
end

function QTutorialPhaseInFirstBattle:playSound(cfg)
    self._stage:playSound(cfg)
end

function QTutorialPhaseInFirstBattle:stopMusic()
    self._stage:stopMusic()
end

function QTutorialPhaseInFirstBattle:fadeInPlayCCB(cfg)
    self._stage:fadeInPlayCCB(cfg)
end


function QTutorialPhaseInFirstBattle:playNextEvent()
    self._event_idx = self._event_idx + 1
    self:playEvent()
end

function QTutorialPhaseInFirstBattle:jumpToKey(cfg)
    self._event_idx = self.key_list[cfg.to]
    self:playEvent()
end

function QTutorialPhaseInFirstBattle:playEvent()
    local cfg = self:loadConfig(self._event_idx)
    if not cfg then 
        return
    end
    if cfg.startBuriedPoint then
        app:triggerBuriedPoint(cfg.startBuriedPoint)
    end
    self.functions[cfg.func](self,cfg)
    if cfg.donext then
        self:playNextEvent()
    end
end

function QTutorialPhaseInFirstBattle:loadConfig(idx)
    return prologue_config[idx]
end

function QTutorialPhaseInFirstBattle:playFinish(cfg)
    self._stage:pause()
	self._stage:fadeOutScene(1.5,0.25, function()
       self:finished()
    end)
end

return QTutorialPhaseInFirstBattle