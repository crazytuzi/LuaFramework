require"Lang"
UIWarRank = { }

local ui = UIWarRank

local scrollViewItem = nil

local function setScrollViewItem(item, data)
    data = utils.stringSplit(data, "|")
    local rank = tonumber(data[1] or 0)
    local playerId = tonumber(data[2] or 0)
    local playerName = data[3] or ""
    local cardId = data[4] or ""
    local level = data[5] or 1
    local isMVP = tonumber(data[6] or 0) ~= 0
    local kill = data[7] or 0
    local contribution = data[8] or 0

    local image_frame_player = item:getChildByName("image_frame_player")
    local image_mvp = item:getChildByName("image_mvp")
    local image_player = image_frame_player:getChildByName("image_player")
    local text_lv = image_frame_player:getChildByName("text_lv")
    local text_name = image_frame_player:getChildByName("text_name")
    local text_ranking = image_frame_player:getChildByName("text_ranking")
    local text_kill = image_frame_player:getChildByName("text_alliance")
    local text_contribution = image_frame_player:getChildByName("text_alliance_0")

    text_name:setString(playerName)
    text_lv:setString(string.format("LV.%d", level))
    text_kill:setString(string.format(Lang.ui_war_rank1, kill))
    text_contribution:setString(string.format(Lang.ui_war_rank2, contribution))

    if rank <= 3 then
        item:loadTexture(string.format("ui/ph0%d.png", rank))
        text_ranking:hide()
    else
        item:loadTexture("ui/ph04.png")
        text_ranking:show():setString(rank)
    end

    image_mvp:setVisible(isMVP)

    local dictCard = DictCard[cardId]
    if dictCard then
        image_player:loadTexture("image/" .. DictUI[tostring(dictCard.smallUiId)].fileName)
    end

    image_frame_player:setTouchEnabled(true)
    image_frame_player:addTouchEventListener( function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            audio.playSound("sound/button.mp3")
            UIManager.showLoading()
            netSendPackage( { header = StaticMsgRule.enemyPlayerInfo, msgdata = { int = { playerId = playerId } } }, function(pack)
                if pack.msgdata.message then
                    pvp.loadGameData(pack)
                    UIManager.pushScene("ui_arena_check")
                end
            end )
        end
    end )

    utils.addParticleEffect(item, playerId == net.InstPlayer.int["1"], { anchorSize = 9, offset = 4, t = 0.4 })
end

function ui.init()
    local btn_close = ccui.Helper:seekNodeByName(ui.Widget, "btn_close")
    local btn_closed = ccui.Helper:seekNodeByName(ui.Widget, "btn_closed")
    local btn_help = ccui.Helper:seekNodeByName(ui.Widget, "btn_help")

    local function onButtonEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            audio.playSound("sound/button.mp3")
            if sender == btn_close or sender == btn_closed then
                UIManager.popScene()
            elseif sender == btn_help then
                UIAllianceHelp.show( { titleName = Lang.ui_war_rank3, type = 17 })
            end
        end
    end

    btn_close:addTouchEventListener(onButtonEvent)
    btn_closed:addTouchEventListener(onButtonEvent)
    btn_help:addTouchEventListener(onButtonEvent)

    scrollViewItem = ccui.Helper:seekNodeByName(ui.Widget, "image_di_ranking")
    scrollViewItem:retain()
end

local function netCallbackfunc(pack)
    local ranklist =(pack.msgdata.string and pack.msgdata.string.ranklist) or ""
    ranklist = utils.stringSplit(ranklist, "/")
    local view_rank = ccui.Helper:seekNodeByName(ui.Widget, "view_rank")
    view_rank:removeAllChildren()
    utils.updateScrollView(ui, view_rank, scrollViewItem, ranklist, setScrollViewItem)
end

function ui.setup()
    UIManager.showLoading()
    netSendPackage( { header = StaticMsgRule.unionContribution, msgdata = { } }, netCallbackfunc, netCallbackfunc)
end

function ui.free()
    if scrollViewItem and scrollViewItem:getReferenceCount() >= 1 then
        scrollViewItem:release()
        scrollViewItem = nil
    end
end
