local QAssistInputPanel = class("QAssistInputPanel", function()
		return CCNode:create()
	end)
local QScrollContain = import("....ui.QScrollContain")
local QAssist = import("..QAssist")

QAssistInputPanel.EVENT_OPEN_IME = "EVENT_OPEN_IME"
QAssistInputPanel.EVENT_CLOSE_IME = "EVENT_CLOSE_IME"

function QAssistInputPanel:ctor(options)
    cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
    local btnWidth = 100
    self._width = display.width - btnWidth
    local height = 48

    local layer = CCLayerColor:create(ccc4(255, 105, 180, 255), display.width, height)
    layer:setAnchorPoint(0, 1)
    layer:setPosition(ccp(0, 0))
    self:addChild(layer)

    self._inputTF = ui.newEditBox({image = "ui/none.png", listener = handler(self, self.onEdit), size = CCSize(self._width, height)})
    self._inputTF:setPosition(ccp(self._width/2, height/2))
    self:addChild(self._inputTF)
    self._inputTF:setFont(global.font_default, 16)
    self._inputTF:setPlaceHolder("点此输入信息")
    self._inputTF:setColor(ccc3(0,0,0))

    local button = CCControlButton:create("发送", global.font_zhcn, 24)
    button:setPreferredSize(CCSize(btnWidth, height))
    button:addHandleOfControlEvent(function (eventType)
        self:onTriggerEvent(eventType)
    end, 32)
    local normal = QSpriteFrameByPath(QResPath("assist_input_normal"))
    local highlight = QSpriteFrameByPath(QResPath("assist_input_highlight"))
    button:setBackgroundSpriteFrameForState(normal, 1)
    button:setBackgroundSpriteFrameForState(highlight, 2)
    button:setBackgroundSpriteFrameForState(highlight, 4)
    button:setBackgroundSpriteFrameForState(highlight, 8)
    button:setTitleColorForState(ccc3(253, 239, 205), 1)
    button:setTitleColorForState(ccc3(254, 251, 0), 2)
    button:setTitleColorForState(ccc3(254, 251, 0), 4)
    button:setTitleColorForState(ccc3(254, 251, 0), 8)
    button:setZoomOnTouchDown(false)
    button:setAnchorPoint(ccp(0, 0))
    button:setPosition(ccp(display.width - btnWidth, 0))
    self:addChild(button)
end

function QAssistInputPanel:setInputHide(b)
    if b == false then
        self._inputTF:setPositionX(10000)
    else
        self._inputTF:setPositionX(self._width/2)
    end
end

function QAssistInputPanel.onEdit( ... )
    -- body
end

function QAssistInputPanel:onTriggerEvent(event)
    local code = self._inputTF:getText()
    self._inputTF:setText("")
    QAssist:getInstance():logger(code)
    local basePrint = print
    print = function ( ... )
        local data = {...}
        for _, value in pairs(data) do
            QAssist:getInstance():logger(tostring(value))
        end
    end
    local msg = app.funny:run(code)
    print = basePrint
    if msg ~= "" then
        QAssist:getInstance():logger("can not runing "..msg)
    end
end

return QAssistInputPanel