local QEPrologueViewer = class("QEPrologueViewer", function()
    return display.newScene("QEPrologueViewer")
end)

local QRichTypewriter = import"...utils.QRichTypewriter"
local prologue_config = import"...tutorial.config.prologue_config"

function QEPrologueViewer:ctor()
    local owner = {}
    local proxy = CCBProxy:create()

    owner.click_screen = handler(self, self.onClick)

	self._ccbNode = CCBuilderReaderLoad("Dialog_Newopening.ccbi", proxy, owner)
    self._ccbOwner = owner
    self._ccbProxy = proxy
    self:addChild(self._ccbNode)
    self._ccbNode:setPosition(ccp(display.cx,display.cy))
    self._context_dialog = owner.context_dialog
    self._tf_name = QRichTypewriter.new(nil,540,{defaultColor = ccc3(255,255,255), defaultSize = 22, stringType = 1})
    self._tf_name:setAnchorPoint(0,0.5)
    owner.name:addChild(self._tf_name)
    self._tf_word = QRichTypewriter.new(nil,540,{defaultColor = ccc3(255,255,255), defaultSize = 22, stringType = 1})
    owner.word:addChild(self._tf_word)
    self._tf_word:setAnchorPoint(ccp(0,1)) --设置锚点为0,1保证打字机换行是向下

    self._background = owner.background_img
    self._pause = false

    self._event_idx = 0

    self.key_list = {}
    self:registerFunctions()
    self:registerKeys()
    self:playNextEvent()
end

function QEPrologueViewer:registerKeys()
    self.key_list = {}
    for idx,cfg in ipairs(prologue_config) do
        if cfg.key then
            self.key_list[cfg.key] = idx
        end
    end
end

function QEPrologueViewer:registerFunctions()

    self.functions = 
    {
        speak = QEPrologueViewer.playString,
        changeBg = QEPrologueViewer.changeBackground,
        hideDialog = QEPrologueViewer.hideTypewriter,
        showDialog = QEPrologueViewer.showTypewriter,
        finish = QEPrologueViewer.playFinish,
        jump = QEPrologueViewer.jumpToKey,
        sound = QEPrologueViewer.playSound,
        music = QEPrologueViewer.playMusic,
        stopMusic = QEPrologueViewer.stopMusic,
    }
end

function QEPrologueViewer:onEnter()
    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self._onFrame))
    self:scheduleUpdate_()
end

function QEPrologueViewer:playNextEvent()
    self._event_idx = self._event_idx + 1
    self:playEvent()
end

function QEPrologueViewer:jumpToKey(cfg)
    self._event_idx = self.key_list[cfg.to]
    self:playEvent()
end

function QEPrologueViewer:playEvent()
    local cfg = self:loadConfig(self._event_idx)
    if not cfg then 
        return
    end
    self.functions[cfg.func](self,cfg)
    if cfg.donext then
        self:playNextEvent()
    end
end

function QEPrologueViewer:loadConfig(idx)
    return prologue_config[idx]
end

function QEPrologueViewer:onExit()
    self:unscheduleUpdate()
end

function QEPrologueViewer:_onFrame(dt)
    if self._pause then
        return
    end
    self._tf_word:visit(dt)
end

-- 播放文本
function QEPrologueViewer:playString(cfg)
    local name = cfg.name
    local str = cfg.word
    local speed = cfg.speed
    self._tf_name:setString(name)
    self._tf_word:setString(str,speed)
end

-- 把打字机内容全部显示
function QEPrologueViewer:showAll()
    self._tf_word:showAll()
end

-- 暂停
function QEPrologueViewer:pause()
    self._pause = true
end

-- 继续
function QEPrologueViewer:resume()
    self._pause = false
end

-- 暂停打字机
function QEPrologueViewer:pauseTypewriter()
    self._tf_word:pause()
end

-- 继续播放打字机
function QEPrologueViewer:resumeTypewriter()
    self._tf_word:resume()
end

function QEPrologueViewer:hideTypewriter()
    self._context_dialog:setVisible(false)
end

function QEPrologueViewer:showTypewriter()
    self._context_dialog:setVisible(true)
end

function QEPrologueViewer:changeBackground(cfg)
    local name = cfg.name
    local src = "res/ui/new_opening/" .. name
    local texture = CCTextureCache:sharedTextureCache():addImage(src)
    if texture then
        self._background:setTexture(texture)
    end
end

function QEPrologueViewer:onClick()
    if self._tf_word:isPlaying() then
        self._tf_word:showAll()
        return
    end

    self:playNextEvent()
end

function QEPrologueViewer:playMusic(cfg)
    app.sound:playMusic(cfg.src)
end

function QEPrologueViewer:playSound(cfg)
    app.sound:playSound(cfg.src)
end

function QEPrologueViewer:stopMusic()
    app.sound:stopMusic()
end

--完成后会走到这一步
function QEPrologueViewer:playFinish(cfg)

end

return QEPrologueViewer