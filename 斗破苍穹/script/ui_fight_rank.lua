require"Lang"
UIFightRank = { }

local ui = UIFightRank

local ui_svItem = nil
local _levelData = nil
local _selfRank = nil
local _selfPoint = nil

local PAGE_ITEM_SIZE = 10 -- 每页显示的个数
local MAX_ITEM_SIZE = 50 -- 最大显示条数

function ui.init()
    local btn_close = ccui.Helper:seekNodeByName(ui.Widget, "btn_close")
    local btn_help = ccui.Helper:seekNodeByName(ui.Widget, "btn_help")
    local view_list = ccui.Helper:seekNodeByName(ui.Widget, "view_list")
    ui_svItem = view_list:getChildByName("image_di_ranking"):clone()
    ui_svItem:retain()

    btn_close:setPressedActionEnabled(true)
    btn_help:setPressedActionEnabled(true)
    local function TouchEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            audio.playSound("sound/button.mp3")
            if sender == btn_close then
                UIManager.popScene()
            elseif sender == btn_help then
                UIAllianceHelp.show( { titleName = Lang.ui_fight_rank1, name = "barrierRank" })
            end
        end
    end
    btn_close:addTouchEventListener(TouchEvent)
    btn_help:addTouchEventListener(TouchEvent)
end

local function netCallbackFunc(data)
    local code = tonumber(data.header)
    if code == StaticMsgRule.ranking then
        local msgData = data.msgdata.string["1"]
        _selfPoint = data.msgdata.int and data.msgdata.int["2"] or 0
        if msgData and #msgData > 0 then
            ui.isFlush = _levelData ~= nil
            _levelData = _levelData or { }
            local _index = math.floor(#_levelData / PAGE_ITEM_SIZE) * PAGE_ITEM_SIZE + 1
            local msgLists = utils.stringSplit(msgData, "/")
            for i, obj in ipairs(msgLists) do
                local _objData = utils.stringSplit(obj, " ")
                -- 序号_玩家id_头像id(卡牌字典表id)_玩家名_等级_联盟
                local t = {
                    rank = tonumber(_objData[1]),
                    playerId = tonumber(_objData[2]),
                    iconId = tonumber(_objData[3]),
                    playerName = _objData[4],
                    level = tonumber(_objData[5]),
                    isShowXunzhang = tonumber(_objData[6]),
                    allianceName = _objData[7] or "",
                    accountId = _objData[8] or "",
                    serverId = _objData[9] or "",
                    point = tonumber(_objData[10] or 0)
                }
                if t.playerId == net.InstPlayer.int["1"] then
                    _selfRank = t.rank
                end
                _levelData[_index] = t
                _index = _index + 1
            end

            ui.setup()
        else
            UIManager.showToast(Lang.ui_fight_rank2)
            ui.setup()
        end
    elseif code == StaticMsgRule.enemyPlayerInfo then
        if data.msgdata.message then
            pvp.loadGameData(data)
            UIManager.pushScene("ui_arena_check")
        end
    end
end

local function sendPackage(_page)
    UIManager.showLoading()
    netSendPackage( { header = StaticMsgRule.ranking, msgdata = { int = { type = 4, pageNum = _page } } }, netCallbackFunc)
end

local function checkPlayerInfo(_data)
    UIManager.showLoading()
    netSendPackage( { header = StaticMsgRule.openPlayerRank, msgdata = { int = { pId = _data.playerId } } },
    function(_msgData)
        local _userData = {
            playerId = _data.playerId,
            userName = _data.playerName,
            userLvl = _data.level,
            userFight = _msgData.msgdata.int["2"],
            userUnio = _data.allianceName,
            headId = _data.iconId,
            vip = _msgData.msgdata.int["1"],
            accountId = _data.accountId,
            serverId = _data.serverId
        }
        UIAllianceTalk.show(_userData)
    end )
end

local function setScrollViewItem(item, data)
    if data then
        local item_iconFrame = item:getChildByName("image_frame_player"):show()
        local item_ranking = item_iconFrame:getChildByName("text_ranking")
        local item_icon = item_iconFrame:getChildByName("image_player")
        local item_playerName = item_iconFrame:getChildByName("text_name")
        local item_playerLevel = item_iconFrame:getChildByName("text_lv")
        local text_alliance = item_iconFrame:getChildByName("text_alliance")
        item:getChildByName("text_hint"):hide()

        item:setTouchEnabled(false)

        if data.rank <= 3 then
            item_ranking:setVisible(false)
            item:loadTexture(string.format("ui/ph0%d.png", data.rank))
        else
            item_ranking:show():setString(data.rank)
            item:loadTexture(string.format("ui/ph04.png", data.rank))
        end

        local dictCard = DictCard[tostring(data.iconId)]
        if dictCard then
            item_icon:loadTexture("image/" .. DictUI[tostring(dictCard.smallUiId)].fileName)
        end

        item_playerName:setString(data.playerName)
        item_playerLevel:setString(Lang.ui_fight_rank3 .. data.point)
        item_iconFrame:setTouchEnabled(true)
        item_iconFrame:addTouchEventListener( function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                checkPlayerInfo(data)
            end
        end )

        if #data.allianceName > 0 then
            text_alliance:show():setString(Lang.ui_fight_rank4 .. data.allianceName)
        else
            text_alliance:hide()
        end
    else
        item:setPositionY(item:getContentSize().height / 2)
        item:getChildByName("image_frame_player"):hide()
        item:loadTexture("ui/btn_l.png")
        item:getChildByName("text_hint"):show():setPositionY(item:getContentSize().height / 2)
        item:setTouchEnabled(true)
        item:addTouchEventListener( function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                sendPackage(math.floor(#_levelData / PAGE_ITEM_SIZE) + 1)
            end
        end )
    end
end

function ui.setup()
    local view_list = ccui.Helper:seekNodeByName(ui.Widget, "view_list")
    view_list:removeAllChildren()

    if not _levelData then
        sendPackage(1)
    end

    local image_basemap = ccui.Helper:seekNodeByName(ui.Widget, "image_basemap")
    image_basemap:getChildByName("text_name"):setString(net.InstPlayer.string["3"])
    local text_lv = image_basemap:getChildByName("text_lv")
    local text_rank = image_basemap:getChildByName("text_rank")

    if _selfPoint then
        text_lv:show():setString(Lang.ui_fight_rank5 .. _selfPoint)
    else
        text_lv:hide()
    end
    text_rank:setString(_selfRank and(Lang.ui_fight_rank6 .. _selfRank) or Lang.ui_fight_rank7)
    _selfRank = nil
    if _levelData then
        utils.updateScrollView(ui, view_list, ui_svItem, _levelData, setScrollViewItem, { space = 10, bottomSpace = #_levelData >= MAX_ITEM_SIZE and 0 or ui_svItem:getContentSize().height })
    end
end

function ui.free()
    if ui_svItem and ui_svItem:getReferenceCount() >= 1 then
        ui_svItem:release()
        ui_svItem = nil
    end
    _selfPoint = nil
    _selfRank = nil
    _levelData = nil
end
