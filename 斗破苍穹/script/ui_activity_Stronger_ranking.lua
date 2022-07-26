require"Lang"
UIActivityStrongerRanking = { }

local _scrollView
local _listData
local scrollViewItem

local _levelData = nil
local _dantaRank = nil
local _selfRank = nil
local _selfPoint = nil
local _time

function UIActivityStrongerRanking.init()
    local btn_closed = ccui.Helper:seekNodeByName(UIActivityStrongerRanking.Widget, "btn_closed")
    local btn_award =ccui.Helper:seekNodeByName(UIActivityStrongerRanking.Widget, "btn_award")
    text_myrank = ccui.Helper:seekNodeByName(UIActivityStrongerRanking.Widget,"text_myrank")
    local function btnEvent( sender , eventType)
        if eventType == ccui.TouchEventType.ended then
             if sender == btn_closed then
                local openLv = DictFunctionOpen[tostring(StaticFunctionOpen.area)].level
                if net.InstPlayer.int["4"] < openLv then
                    UIManager.showToast(Lang.ui_activity_Stronger_ranking1 .. openLv .. Lang.ui_activity_Stronger_ranking2)
                    return
                end
                UIManager.hideWidget("ui_team_info")
                UIManager.showWidget("ui_arena")
                UIManager.hideWidget("ui_activity_time")
                UIArena.isFromMain = true
            elseif sender == btn_award then
                UIManager.pushScene("ui_activity_Stronger_preview")
            end
        end
    end
    btn_closed:setPressedActionEnabled( true )
    btn_award:setPressedActionEnabled( true )
    btn_closed:addTouchEventListener( btnEvent )
    btn_award:addTouchEventListener( btnEvent )
    _scrollView = ccui.Helper:seekNodeByName(UIActivityStrongerRanking.Widget, "view_list_gem")
    scrollViewItem = _scrollView:getChildByName("image_di_ranking")
    scrollViewItem:retain()
end

local function checkPlayerInfo(_data)
    UIManager.showLoading()
    netSendPackage( { header = StaticMsgRule.openPlayerRank, msgdata = { int = { pId = tonumber(_data[2]) } } },
    function(_msgData)
        local _userData = {
            playerId = tonumber(_data[2]),
            userName = _data[4],
            userLvl = tonumber(_data[5]),
            userFight = _msgData.msgdata.int["2"],
            userUnio = _data[7] or "",
            headId = _data[3],
            vip = _msgData.msgdata.int["1"],
            accountId =_data[8] or  "",
            isAwake = tonumber(utils.stringSplit(_data[3], "_")[2]),
            serverId =_data[9] or ""
        }
        UIAllianceTalk.show(_userData)
    end )
end
local function setScrollViewItem(item, data)
    local _objData = utils.stringSplit(data, " ")
    local _item = item:getChildByName("image_frame_player")
    local image_rank = _item:getChildByName("image_di_ranking")
    if tonumber(_objData[1]) <= 3 then
         item:loadTexture(string.format("ui/ph0%d.png",tonumber( _objData[1])))
         _item:getChildByName("text_ranking"):setString("")
    else
         item:loadTexture("ui/ph04.png")
         _item:getChildByName("text_ranking"):setString(_objData[1])
    end
    _item:getChildByName("text_name"):setString(_objData[4])
    _item:getChildByName( "text_lv"):setString(Lang.ui_activity_Stronger_ranking3.._objData[5])
    _item:getChildByName("text_alliance"):setString(_objData[7] or "")
    item_icon = _item:getChildByName("image_player")
    local iconId = tonumber(utils.stringSplit(_objData[3], "_")[1])
    local isAwake = tonumber(utils.stringSplit(_objData[3], "_")[2])
    local dictCard = DictCard[tostring(iconId)]
    if dictCard then
        if isAwake == 1 then
            item_icon:loadTexture("image/" .. DictUI[tostring(dictCard.awakeSmallUiId)].fileName)
        else
            item_icon:loadTexture("image/" .. DictUI[tostring(dictCard.smallUiId)].fileName)
        end
        utils.addBorderImage( StaticTableType.DictCard , dictCard.id , _item )
    end
    item_icon:setTouchEnabled(true)
            item_icon:addTouchEventListener( function(sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    checkPlayerInfo(_objData)
                end
            end )
end
local function netCallbackFunc(data)   
     _listData = utils.stringSplit( data.msgdata.string["1"], "/")
     utils.updateScrollView(UIActivityStrongerRanking, _scrollView, scrollViewItem, _listData, setScrollViewItem, { space = 8 })
end

function UIActivityStrongerRanking.setup()
     _scrollView:removeAllChildren()
     UIManager.showLoading()
     netSendPackage( { header = StaticMsgRule.ranking, msgdata = { int = { type = 2, pageNum = 1 } } }, netCallbackFunc)
     if net.InstPlayerArena then
         local text_myrank = ccui.Helper:seekNodeByName(UIActivityStrongerRanking.Widget, "text_myrank"):setString(Lang.ui_activity_Stronger_ranking4..net.InstPlayerArena.int["3"])
     else
         local text_myrank = ccui.Helper:seekNodeByName(UIActivityStrongerRanking.Widget, "text_myrank"):setString(Lang.ui_activity_Stronger_ranking5..Lang.ui_activity_Stronger_ranking6)
     end
     local timeData = utils.stringSplit(_time , "-")
     timeData[3] = tonumber(timeData[3]) + 6
     local md = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
     if tonumber(timeData[3]) > md[tonumber(timeData[2])] then
	    timeData[3] = timeData[3] - md[tonumber(timeData[2])]
	    timeData[2] = tonumber(timeData[2]) + 1
	    if tonumber(timeData[2]) > 12 then
		    timeData[2] = tonumber(timeData[2]) - 12
		    timeData[1] = tonumber(timeData[1]) + 1
	    end
     end
     ccui.Helper:seekNodeByName( UIActivityStrongerRanking.Widget , "text_time"):setString(Lang.ui_activity_Stronger_ranking7 ..timeData[1]..Lang.ui_activity_Stronger_ranking8..timeData[2]..Lang.ui_activity_Stronger_ranking9..timeData[3]..Lang.ui_activity_Stronger_ranking10.."24:00")

end

function UIActivityStrongerRanking.setTime(time)
    _time = time
end


function UIActivityStrongerRanking.free()


end
