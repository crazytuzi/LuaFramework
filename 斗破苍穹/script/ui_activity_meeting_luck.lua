require"Lang"
UIActivityMeetingLuck = {}
local _tag = nil
local _thing = nil
local _number = nil
local function refreshInfo()
    local image_di_soul = ccui.Helper:seekNodeByName( UIActivityMeetingLuck.Widget , "image_di_soul" )
    local obj = utils.stringSplit( _thing[ _tag ] , ";" )
    for i = 1 , 4 do
        local image_frame_good = image_di_soul:getChildByName( "image_frame_good"..i ) 
        if i <= #obj then
            image_frame_good:setVisible( true )            
            local objThing = utils.getItemProp( obj[ i ] )
            image_frame_good:loadTexture( objThing.frameIcon )
            local image_good = image_frame_good:getChildByName( "image_good" )
            image_good:loadTexture( objThing.smallIcon )
            image_good:getChildByName( "text_name" ):setString( objThing.name )
            image_good:getChildByName( "text_number" ):setString( "×"..objThing.count )
            if not objThing.flagIcon then
                image_good:getChildByName( "image_sui" ):setVisible( false )
            else
                image_good:getChildByName( "image_sui" ):setVisible( true )
            end
            utils.showThingsInfo( image_good , objThing.tableTypeId , objThing.tableFieldId )
        else
            image_frame_good:setVisible( false )
        end
    end
    local text_hint = ccui.Helper:seekNodeByName( image_di_soul , "text_hint" )
    if _number and _number[ 1 + ( _tag - 1 ) * 2 ] then
        if tonumber( _number[ 1 + ( _tag - 1 ) * 2 ] ) > 0 then
            text_hint:setString(Lang.ui_activity_meeting_luck1.._number[ 1 + ( _tag - 1 ) * 2 ])
        else
            text_hint:setString( Lang.ui_activity_meeting_luck2 )
        end
    else
        text_hint:setString( Lang.ui_activity_meeting_luck3 )
    end
    local image_di_treasure = ccui.Helper:seekNodeByName( UIActivityMeetingLuck.Widget , "image_di_treasure" )
    local obj1 = utils.stringSplit( _thing[ 2 + _tag ] , ";" )
    for i = 1 , 4 do
        local image_frame_good = image_di_treasure:getChildByName( "image_frame_good"..i ) 
        if i <= #obj1 then
            image_frame_good:setVisible( true )
            local objThing = utils.getItemProp( obj1[ i ] )
            image_frame_good:loadTexture( objThing.frameIcon )
            local image_good = image_frame_good:getChildByName( "image_good" )
            image_good:loadTexture( objThing.smallIcon )
            image_good:getChildByName( "text_name" ):setString( objThing.name )
            image_good:getChildByName( "text_number" ):setString( "×"..objThing.count )
            if not objThing.flagIcon then
                image_good:getChildByName( "image_sui" ):setVisible( false )
            else
                image_good:getChildByName( "image_sui" ):setVisible( true )
            end
            utils.showThingsInfo( image_good , objThing.tableTypeId , objThing.tableFieldId )
        else
            image_frame_good:setVisible( false )
        end
    end
    local text_hint1 = ccui.Helper:seekNodeByName( image_di_treasure , "text_hint" )
    if _number and _number[ 2 + ( _tag - 1 ) * 2 ] then
        if tonumber( _number[ 2 + ( _tag - 1 ) * 2 ] ) > 0 then
            text_hint1:setString(Lang.ui_activity_meeting_luck4.._number[ 2 + ( _tag - 1 ) * 2 ])
        else
            text_hint1:setString( Lang.ui_activity_meeting_luck5 )
        end
    else
        text_hint1:setString( Lang.ui_activity_meeting_luck6 )
    end
end
local function refreshTag()
    local btn_soul = ccui.Helper:seekNodeByName( UIActivityMeetingLuck.Widget , "btn_soul" )--第一天
    local btn_treasure = ccui.Helper:seekNodeByName( UIActivityMeetingLuck.Widget , "btn_treasure" )--第二天
    if _tag == 1 then
        btn_treasure:loadTextureNormal("ui/yh_btn01.png")
        btn_treasure:getChildByName("text_treasure"):setTextColor(cc.c4b(255, 255, 255, 255))
        btn_soul:loadTextureNormal("ui/yh_btn02.png")
        btn_soul:getChildByName("text_soul"):setTextColor(cc.c4b(51, 25, 4, 255))
    elseif _tag == 2 then
        btn_soul:loadTextureNormal("ui/yh_btn01.png")
        btn_soul:getChildByName("text_soul"):setTextColor(cc.c4b(255, 255, 255, 255))
        btn_treasure:loadTextureNormal("ui/yh_btn02.png")
        btn_treasure:getChildByName("text_treasure"):setTextColor(cc.c4b(51, 25, 4, 255))
    end
end
function UIActivityMeetingLuck.init()
    local btn_close = ccui.Helper:seekNodeByName( UIActivityMeetingLuck.Widget , "btn_close" )
    local btn_sure = ccui.Helper:seekNodeByName( UIActivityMeetingLuck.Widget , "btn_sure" )
    local btn_soul = ccui.Helper:seekNodeByName( UIActivityMeetingLuck.Widget , "btn_soul" )--第一天
    local btn_treasure = ccui.Helper:seekNodeByName( UIActivityMeetingLuck.Widget , "btn_treasure" )--第二天
    local function onEvent( sender , eventType )
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_close then
                UIManager.popScene()
            elseif sender == btn_sure then
                UIManager.popScene()
            elseif sender == btn_soul then
                if _tag == 1 then
                    return
                end
                _tag = 1
                refreshTag()
                refreshInfo()
            elseif sender == btn_treasure then
                if _tag == 2 then
                    return
                end
                _tag = 2
                refreshTag()
                refreshInfo()
            end
        end
    end
    btn_close:setPressedActionEnabled( true )
    btn_close:addTouchEventListener( onEvent )
    btn_sure:setPressedActionEnabled( true )
    btn_sure:addTouchEventListener( onEvent )
    btn_soul:setPressedActionEnabled( true )
    btn_soul:addTouchEventListener( onEvent )
    btn_treasure:setPressedActionEnabled( true )
    btn_treasure:addTouchEventListener( onEvent )
end

function UIActivityMeetingLuck.setup()
    if not _tag then
        _tag = 1
    end
    refreshTag()
    
    local function callBack( pack )
       -- String.day1 = 【第一日的】(炼魂的playerid|中奖号码|奖励列表|炼宝的playerid|中奖号码|奖励列表)
       -- String.day2 = 【第二日的】(炼魂的playerid|中奖号码|奖励列表|炼宝的playerid|中奖号码|奖励列表)
        local day1List = pack.msgdata.string.day1
        _number = {}
        if day1List and day1List ~= "" then
            local data = utils.stringSplit( day1List , "|" )
            _number[ 1 ] = data[ 2 ]
            _number[ 2 ] = data[ 5 ]
            if data[ 3 ] and data[ 3 ] ~= ""then
                _thing[ 1 ] = data[ 3 ]
            end
            if data[ 6 ] and data[ 6 ] ~= ""then
                _thing[ 3 ] = data[ 6 ]
            end
        end
        local day2List = pack.msgdata.string.day2
        if day2List and day2List ~= "" then
            local data = utils.stringSplit( day2List , "|" )
            _number[ 3 ] = data[ 2 ]
            _number[ 4 ] = data[ 5 ]
            if data[ 3 ] and data[ 3 ] ~= ""then
                _thing[ 2 ] = data[ 3 ]
            end
            if data[ 6 ] and data[ 6 ] ~= ""then
                _thing[ 4 ] = data[ 6 ]
            end
        end
 --       _thing = { "2_1011_1;2_2_10;3_2_1000;9_88_5" , "9_99_5;3_1_100;2_83_20;2_89_10" , "9_99_5;2_83_100;3_1_100;2_87_1000" , "9_99_10;2_1002_1;2_2_1000;2_9_100" }
        refreshInfo()
    end
    UIManager.showLoading()
    netSendPackage( { header = StaticMsgRule.showLucky , msgdata = {} } , callBack )
end

function UIActivityMeetingLuck.free()
    _tag = nil
    _thing = nil
    _number = nil
end

function UIActivityMeetingLuck.setData( data , day )
    _thing = data
    _tag = day
end
