local ChatRealOpenNoticeNode = class("ChatRealOpenNoticeNode", function() return cc.Node:create() end)

local tipsRecord = {}


function ChatRealOpenNoticeNode:ctor(mapId)
    --点击后打开语聊设置界面
	local cb = function() 
        --弹出聊天界面及语聊设置界面
        G_MAINSCENE.base_node:removeChildByTag(305)
        G_MAINSCENE.chatLayer = require("src/layers/chat/Chat").new()
        G_MAINSCENE.base_node:addChild(G_MAINSCENE.chatLayer)
        G_MAINSCENE.chatLayer:setLocalZOrder(200)
        G_MAINSCENE.chatLayer:setTag(305)

        local layer = require("src/layers/chat/ChatVoiceSetLayer").new(param)
		getRunScene():addChild(layer, 200)
		layer:setPosition(G_MAINSCENE.chatLayer.voiceSetBtn:convertToWorldSpace(getCenterPos(G_MAINSCENE.chatLayer.voiceSetBtn)))
        layer:showRealOpenEff()
        
        removeFromParent(self)
    end
    
    local iconSpr = createMenuItem(self, "res/mainui/realvoice.png", cc.p(0, 0), cb)
    performWithNoticeAction(iconSpr)

    --十秒不点击关闭
    local dt = 0
    local update = function() 
        dt = dt + 1
        if not G_FACTION_INFO.facname or getGameSetById(GAME_SET_VOICE_REALVOICE_OPEN) > 0 then
            removeFromParent(self)
            return
        end

        if dt > 10 then
            removeFromParent(self)
        end
    end

    startTimerAction(self, 1, true, update)

    --添加记录
    table.insert(tipsRecord, mapId)

    self:registerScriptHandler(function(event)
        if event == "enter" then   
        elseif event == "exit" then
            if G_MAINSCENE then
                G_MAINSCENE.realVoiceOpenNtfNode = nil
            end
        end
    end)
end

function ChatRealOpenNoticeNode:isHaveTips(mapId)
    for i = 1, #tipsRecord do
        if tipsRecord[i] == mapId then
            return true
        end
    end

    return false
end

function ChatRealOpenNoticeNode:resetRecord()
    tipsRecord = {}
end

return ChatRealOpenNoticeNode