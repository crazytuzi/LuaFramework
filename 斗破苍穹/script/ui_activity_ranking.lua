require"Lang"
UIActivityRanking = { }

local TYPE_LEVEL = 1 -- 等级榜
local TYPE_ARENA = 2 -- 竞技榜
local TYPE_PILLTOWER = 3 -- 丹塔榜
local TYPE_FIGHT = 4 -- 副本排行
local PAGE_ITEM_SIZE = 10 -- 每页显示的个数
local MAX_ITEM_SIZE = 50 -- 最大显示条数

local ui_scrollView = nil
local ui_svItem = nil
local ui_svItem2 = nil

local _scrollViewItemSpace = 10

local _levelData = nil
local _dantaRank = nil
local _selfRank = nil
local _selfPoint = nil
local _curListType = TYPE_LEVEL

local initScrollViewItem = nil

local function cleanScrollView()
    if ui_svItem:getReferenceCount() == 1 then
        ui_svItem:retain()
    end
    if ui_svItem2:getReferenceCount() == 1 then
        ui_svItem2:retain()
    end
    ui_scrollView:removeAllChildren()
end

local function addMoreItemToScrollView()
    local scrollViewItem = ui_svItem:clone()
    scrollViewItem:setTag(-100)
    initScrollViewItem(nil, scrollViewItem)
    ui_scrollView:addChild(scrollViewItem)
    return scrollViewItem:getContentSize().height
end

local function netCallbackFunc(data)
    local code = tonumber(data.header)
    if code == StaticMsgRule.ranking then
        local msgData = data.msgdata.string["1"]
        _selfPoint = data.msgdata.int and data.msgdata.int["2"] or 0
        if msgData and #msgData > 0 then
            UIActivityRanking.isFlush = _levelData ~= nil
            _levelData = _levelData or { }
            local _index = math.floor(#_levelData / PAGE_ITEM_SIZE) * PAGE_ITEM_SIZE + 1
            local msgLists = utils.stringSplit(msgData, "/")
            for i, obj in ipairs(msgLists) do
                local _objData = utils.stringSplit(obj, " ")
                -- 序号_玩家id_头像id(卡牌字典表id)_玩家名_等级_联盟
                local t = {
                    rank = tonumber(_objData[1]),
                    playerId = tonumber(_objData[2]),
                    -- iconId = tonumber(_objData[3]),
                    iconId = tonumber(utils.stringSplit(_objData[3], "_")[1]),
                    isAwake = tonumber(utils.stringSplit(_objData[3], "_")[2]),
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

            UIActivityRanking.setup()
        else
            UIManager.showToast(Lang.ui_activity_ranking1)
        end
    elseif code == StaticMsgRule.dantaHandler then
        _dantaRank = data.msgdata.int.r2
        local msgData = data.msgdata.string.r1
        if msgData and #msgData > 0 then
            UIActivityRanking.isFlush = _levelData ~= nil
            _levelData = _levelData or { }
            local _index = math.floor(#_levelData / PAGE_ITEM_SIZE) * PAGE_ITEM_SIZE + 1
            local msgLists = utils.stringSplit(msgData, "/")
            for i, obj in ipairs(msgLists) do
                local _objData = utils.stringSplit(obj, "|")
                -- 名次_玩家id_玩家名_最高层数_等级_勋章数_联盟名称_头像id(卡牌字典表id)
                _levelData[_index] = {
                    rank = tonumber(_objData[1]),
                    playerId = tonumber(_objData[2]),
                    playerName = _objData[3],
                    maxPoint = tonumber(_objData[4]),
                    level = tonumber(_objData[5]),
                    medalCount = tonumber(_objData[6]),
                    allianceName = _objData[7],
                    iconId = tonumber(utils.stringSplit(_objData[8], "_")[1]),
                    isAwake = tonumber(utils.stringSplit(_objData[8], "_")[2]),
                    accountId = _objData[9] or 0,
                    serverId = _objData[10] or 0
                }
                _index = _index + 1
            end

            UIActivityRanking.setup()
        else
            UIManager.showToast(Lang.ui_activity_ranking2)
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
    if _curListType == TYPE_PILLTOWER then
        netSendPackage( { header = StaticMsgRule.dantaHandler, msgdata = { int = { p2 = UIPilltowerRank.TYPE_HISTORY, p3 = _page } } }, netCallbackFunc)
    else
        netSendPackage( { header = StaticMsgRule.ranking, msgdata = { int = { type = _curListType, pageNum = _page } } }, netCallbackFunc)
    end
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
            headId = _data.iconId.."_".._data.isAwake,
            vip = _msgData.msgdata.int["1"],
            accountId = _data.accountId,
            isAwake = _data.isAwake,
            serverId = _data.serverId
        }
        UIAllianceTalk.show(_userData)
    end )
end

initScrollViewItem = function(flag, item, data)
    if data then
        if flag == TYPE_PILLTOWER then
            local item_iconFrame = item:getChildByName("image_frame_player")
            local item_ranking = item_iconFrame:getChildByName("text_ranking")
            local item_icon = item_iconFrame:getChildByName("image_player")
            local item_playerName = item_iconFrame:getChildByName("text_name")
            local item_playerLevel = item_iconFrame:getChildByName("text_lv")
            local item_allianceName = item_iconFrame:getChildByName("text_alliance")
            local item_maxPoint = item_iconFrame:getChildByName("text_notice")
            local item_medalNum = item_iconFrame:getChildByName("image_flag"):getChildByName("text_number")
            if data.rank <= 3 then
                item_ranking:setVisible(false)
                item:loadTexture(string.format("ui/ph0%d.png", data.rank))
            else
                item_ranking:show():setString(data.rank)
                item:loadTexture("ui/ph04.png")
            end
            local dictCard = DictCard[tostring(data.iconId)]
            if dictCard then
                if data.isAwake == 1 then
                    item_icon:loadTexture("image/" .. DictUI[tostring(dictCard.awakeSmallUiId)].fileName)
                else
                    item_icon:loadTexture("image/" .. DictUI[tostring(dictCard.smallUiId)].fileName)
                end
                
            end
            item_playerName:setString(data.playerName)
            item_playerLevel:setString(Lang.ui_activity_ranking3 .. data.level)
            if data.allianceName and data.allianceName ~= "" then
                item_allianceName:show():setString(Lang.ui_activity_ranking4 .. data.allianceName)
            else
                item_allianceName:hide()
            end
            item_maxPoint:setString(string.format(Lang.ui_activity_ranking5, data.maxPoint))
            item_medalNum:setString("×" .. data.medalCount)
            item_iconFrame:setTouchEnabled(true)
            item_iconFrame:addTouchEventListener( function(sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    checkPlayerInfo(data)
                end
            end )
        else
            local item_iconFrame = item:getChildByName("image_frame_player"):show()
            local item_ranking = item_iconFrame:getChildByName("text_ranking")
            local item_icon = item_iconFrame:getChildByName("image_player")
            local item_playerName = item_iconFrame:getChildByName("text_name")
            local item_playerLevel = item_iconFrame:getChildByName("text_lv")
            local text_alliance = item_iconFrame:getChildByName("text_alliance")

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
                if data.isAwake == 1 then
                    item_icon:loadTexture("image/" .. DictUI[tostring(dictCard.awakeSmallUiId)].fileName)
                else
                    item_icon:loadTexture("image/" .. DictUI[tostring(dictCard.smallUiId)].fileName)
                end
                --item_icon:loadTexture("image/" .. DictUI[tostring(dictCard.smallUiId)].fileName)
            end

            item:getChildByName("image_xz"):setVisible(data.isShowXunzhang == 1)
            item_playerName:setString(data.playerName)
            if flag == TYPE_FIGHT then
                item_playerLevel:setString(Lang.ui_activity_ranking6 .. data.point)
            else
                item_playerLevel:setString(Lang.ui_activity_ranking7 .. data.level)
            end
            item_iconFrame:setTouchEnabled(true)
            item_iconFrame:addTouchEventListener( function(sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    checkPlayerInfo(data)
                end
            end )

            if #data.allianceName > 0 then
                text_alliance:show():setString(Lang.ui_activity_ranking8 .. data.allianceName)
                item_playerName:setPositionY(81)
                item_playerLevel:setPositionY(51)
                text_alliance:setPositionY(21)
            else
                text_alliance:hide()
                item_playerName:setPositionY(68)
                item_playerLevel:setPositionY(35)
            end
        end
    else
        item:setPositionY(item:getContentSize().height / 2)
        item:getChildByName("image_frame_player"):hide()
        item:loadTexture("ui/btn_l.png")
        item:getChildByName("image_xz"):hide()
        item:getChildByName("text_hint"):show():setPositionY(item:getContentSize().height / 2)
        item:setTouchEnabled(true)
        item:addTouchEventListener( function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                sendPackage(math.floor(#_levelData / PAGE_ITEM_SIZE) + 1)
            end
        end )
    end
end

local function setCurListType(sender, listType)
    local children = ccui.Helper:seekNodeByName(UIActivityRanking.Widget, "image_base_title"):getChildren()
    for i = 1, #children - 1 do
        local child = children[i]
        if child == sender then
            child:loadTextureNormal("ui/yh_btn02.png")
            child:getChildren()[1]:setTextColor(cc.c4b(51, 25, 4, 255))
            child:setTouchEnabled(false)
            _curListType = listType
            _levelData = nil
        else
            child:loadTextureNormal("ui/yh_btn01.png")
            child:getChildren()[1]:setTextColor(display.COLOR_WHITE)
            child:setTouchEnabled(true)
        end
    end
end

function UIActivityRanking.init()
    ui_scrollView = ccui.Helper:seekNodeByName(UIActivityRanking.Widget, "view_list_gem")
    local children = ui_scrollView:getChildren()
    ui_svItem = children[1]:clone()
    ui_svItem2 = children[2]:clone()

    local image_base_tab = ccui.Helper:seekNodeByName(UIActivityRanking.Widget, "image_base_tab")
    local btn_enter = image_base_tab:getChildByName("btn_enter")
    local image_base_title = ccui.Helper:seekNodeByName(UIActivityRanking.Widget, "image_base_title")
    local arena = image_base_title:getChildByName("btn_gem")
    local level = image_base_title:getChildByName("btn_prop")
    local pilltower = image_base_title:getChildByName("btn_pilltower")
    local fight = image_base_title:getChildByName("btn_fight")

    local function onBtnEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == arena then
                local openLv = DictFunctionOpen[tostring(StaticFunctionOpen.area)].level
                if net.InstPlayer.int["4"] < openLv then
                    UIManager.showToast(Lang.ui_activity_ranking9 .. openLv .. Lang.ui_activity_ranking10)
                else
                    setCurListType(sender, TYPE_ARENA)
                    sendPackage(1)
                end
            elseif sender == level then
                setCurListType(sender, TYPE_LEVEL)
                sendPackage(1)
            elseif sender == fight then
                setCurListType(sender, TYPE_FIGHT)
                sendPackage(1)
            elseif sender == pilltower then
                local openLv = DictFunctionOpen[tostring(StaticFunctionOpen.danta)].level
                if net.InstPlayer.int["4"] < openLv then
                    UIManager.showToast(Lang.ui_activity_ranking11 .. openLv .. Lang.ui_activity_ranking12)
                else
                    setCurListType(sender, TYPE_PILLTOWER)
                    sendPackage(1)
                end
            elseif sender == btn_enter then
                if _curListType == TYPE_LEVEL or _curListType == TYPE_FIGHT then
                    UIMenu.onFight(2)
                elseif _curListType == TYPE_ARENA then
                    local openLv = DictFunctionOpen[tostring(StaticFunctionOpen.area)].level
                    if net.InstPlayer.int["4"] < openLv then
                        UIManager.showToast(Lang.ui_activity_ranking13 .. openLv .. Lang.ui_activity_ranking14)
                    else
                        UIManager.hideWidget("ui_activity_panel")
                        UIManager.showWidget("ui_arena")
                    end
                elseif _curListType == TYPE_PILLTOWER then
                    local openLv = DictFunctionOpen[tostring(StaticFunctionOpen.danta)].level
                    if net.InstPlayer.int["4"] < openLv then
                        UIManager.showToast(Lang.ui_activity_ranking15 .. openLv .. Lang.ui_activity_ranking16)
                    else
                        UIManager.hideWidget("ui_activity_panel")
                        UIManager.showWidget("ui_pilltower")
                    end
                end
            end
        end
    end
    arena:addTouchEventListener(onBtnEvent)
    level:addTouchEventListener(onBtnEvent)
    pilltower:addTouchEventListener(onBtnEvent)
    fight:addTouchEventListener(onBtnEvent)
    btn_enter:setPressedActionEnabled(true)
    btn_enter:addTouchEventListener(onBtnEvent)
end

function UIActivityRanking.setup()
    cleanScrollView()

    if not _levelData then
        sendPackage(1)
    end

    local image_base_tab = ccui.Helper:seekNodeByName(UIActivityRanking.Widget, "image_base_tab")
    image_base_tab:getChildByName("text_name"):setString(net.InstPlayer.string["3"])
    if _curListType == TYPE_LEVEL then
        image_base_tab:getChildByName("text_lv"):setString(Lang.ui_activity_ranking17 .. net.InstPlayer.int["4"])
    elseif _curListType == TYPE_ARENA and net.InstPlayerArena then
        image_base_tab:getChildByName("text_lv"):setString(Lang.ui_activity_ranking18 .. net.InstPlayerArena.int["3"])
    elseif _curListType == TYPE_PILLTOWER and _dantaRank then
        image_base_tab:getChildByName("text_lv"):setString(Lang.ui_activity_ranking19 .. _dantaRank)
        _dantaRank = nil
    elseif _curListType == TYPE_FIGHT then
        image_base_tab:getChildByName("text_lv"):setString(_selfRank and(Lang.ui_activity_ranking20 .. _selfRank) or Lang.ui_activity_ranking21)
    end
    _selfRank = nil

    if _levelData then
        utils.updateScrollView(UIActivityRanking, ui_scrollView, _curListType == TYPE_PILLTOWER and ui_svItem2 or ui_svItem, _levelData, initScrollViewItem, { space = 10, flag = _curListType, bottomSpace = #_levelData >= MAX_ITEM_SIZE and 0 or ui_svItem:getContentSize().height })
        if _curListType ~= TYPE_FIGHT and #_levelData < MAX_ITEM_SIZE then
            addMoreItemToScrollView()
        end
    end
end

function UIActivityRanking.free()
    cleanScrollView()
    setCurListType(ccui.Helper:seekNodeByName(UIActivityRanking.Widget, "btn_prop"), TYPE_LEVEL)
end
