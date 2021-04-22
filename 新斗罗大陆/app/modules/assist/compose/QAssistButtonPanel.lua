-- @Author: Kai Wang
-- @Date:   2019-08-08 12:27:32
-- @Last Modified by:   Kai Wang
-- @Last Modified time: 2019-08-08 15:04:07
local QAssistButtonPanel = class("QAssistButtonPanel", function()
        return CCNode:create()
    end)
local QAssist = import("....modules.assist.QAssist")

local buttonList = {}

function QAssistButtonPanel:ctor(options)
    self._height = display.height - 50
    self._width = display.width*0.3
    local node = CCNode:create()
    local layer = CCLayerColor:create(ccc4(0, 0, 0, 64), self._width, self._height)
    layer:setAnchorPoint(0.5, 0.5)
    layer:setPosition(ccp(0, -self._height))
    node:addChild(layer)
    self:addChild(node)

    table.insert(buttonList, {"退出", 80, handler(self, self._onExit)})
    table.insert(buttonList, {"清除日志", 100, handler(self, self._onClearLog)})
    table.insert(buttonList, {"信息", 80, handler(self, self._onInfoLog)})

    self._currentHieght = -55
    self._currentWidth = 0
    for i,v in ipairs(buttonList) do
        self:_addButton(v[1], v[2], v[3])
    end
end

function QAssistButtonPanel:_addButton(name, btnWidth, callBack)
    local button = CCControlButton:create(name, global.font_zhcn, 24)
    button:setPreferredSize(CCSize(btnWidth, 50))
    button:addHandleOfControlEvent(callBack, 32)
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
    if self._currentWidth + btnWidth > self._width then
        self._currentWidth = 0
        self._currentHieght = self._currentHieght - 55
    end
    button:setPosition(ccp(self._currentWidth, self._currentHieght))
    self._currentWidth = self._currentWidth + btnWidth + 10
    self:addChild(button)
end

function QAssistButtonPanel:_onExit( ... )
    QAssist:getInstance():exit()
end

function QAssistButtonPanel:_onClearLog( ... )
    QAssist:getInstance():clearLog()
end

function QAssistButtonPanel:_onInfoLog( ... )
    QAssist:getInstance():run("info")
end

return QAssistButtonPanel