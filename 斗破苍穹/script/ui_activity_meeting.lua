require"Lang"
UIActivityMeeting = {}
local particle = nil
local _schedulerId = nil
local _endTime = nil
local _percent = nil
local _lianhunUse = nil
local _lianbaoUse = nil
local _thing = nil
local _jifen = nil
local _day = nil
local _animation = nil
local _tag = nil
local gold = nil
local max = nil
local state = nil
local _time = nil
local _timeSchedulerId = nil
local _toastLayer = nil
local function showToast( number , thing )
    inTime = inTime or 0.1
    stillTime = stillTime or 0.2
    outTime = outTime or 0.1
    local function Toast()
        local toast_bg = cc.Scale9Sprite:create("ui/quality_middle.png")
        toast_bg:setAnchorPoint(cc.p(0.5, 0.5))
        toast_bg:setPreferredSize(cc.size(474, 105))
        toast_bg:setPosition(cc.p(UIManager.screenSize.width / 2, UIManager.screenSize.height / 2))
        local node = cc.Node:create()
        
        local description = ccui.Text:create()
        description:setFontSize(25)
        description:setFontName(dp.FONT)
        description:setAnchorPoint(cc.p(0.5, 0.5))
        description:setString(Lang.ui_activity_meeting1 .. number)
      --  description:setPosition(cc.p(cc.p(toast_bg:getPosition()).x + toast_bg:getContentSize().width / 2, 0))
        node:addChild(description)
        node:setPosition(cc.p(toast_bg:getContentSize().width / 2, toast_bg:getContentSize().height / 2))
        toast_bg:addChild(node, 10)
        UIManager.gameLayer:addChild(toast_bg, 100)
        toast_bg:retain()
        local function hideToast()
            if toast_bg then
                UIManager.gameLayer:removeChild(toast_bg, true)
                cc.release(toast_bg)
                utils.showGetThings( thing , 0.1 , 0.2 , 0.1 )
            end
        end
        toast_bg:runAction(cc.Sequence:create(cc.MoveBy:create(inTime, cc.p(0, 80)), cc.DelayTime:create(stillTime), cc.MoveBy:create(outTime, cc.p(0, 120)), cc.CallFunc:create(hideToast)))
    end
    Toast()
end
local function startEffect( number , thing , gold )
    local childs = UIManager.uiLayer:getChildren()
    for key, obj in pairs(childs) do
        if not tolua.isnull(obj) then
            obj:setEnabled(false)
        end
    end
    local effect = cc.ParticleSystemQuad:create("particle/star/ui_anim60_lizi02.plist")
    local function effectCallback(args) 
        if effect:getParent() then
            effect:removeFromParent()        
            if gold > 0 then
                utils.showSureDialog( Lang.ui_activity_meeting2.."x"..gold , function ()
                    showToast( number , thing )
                end)
            else
                showToast( number , thing )
            end
        end
    end
    effect:setName("effect")
    if _tag == 1 then
        effect:setPosition(cc.p( 150 , 220 ))
    elseif _tag == 2 then
        effect:setPosition(cc.p( 450 , 220 ))
    end 
	UIActivityMeeting.Widget:addChild(effect, 1000)
    local bar_ding = ccui.Helper:seekNodeByName( UIActivityMeeting.Widget , "bar_ding" )
    
	effect:runAction(cc.Sequence:create(cc.MoveTo:create(0.5, cc.p( UIManager.screenSize.width / 2 , 600 + bar_ding:getContentSize().width * _percent / 100 ) ) , cc.CallFunc:create(effectCallback) ))
end
local function getTimeFormat( count )
    local time = {}
    time[ 1 ] = string.format( "%02d" , math.floor( count / 3600 / 24 ) )   --天
    time[ 2 ] = string.format( "%02d" , math.floor( count / 3600 % 24 ) ) --时
    time[ 3 ] = string.format( "%02d" , math.floor( count / 60 % 60 ) ) --分
    time[ 4 ] = string.format( "%02d" , math.floor( count % 60 ) ) --秒
    return time
end
local function updateFireTime()   
    if _time then
        local timeCount = 1 * 60 * 60 - ( utils.getCurrentTime() - _time / 1000 )
        local text_time = ccui.Helper:seekNodeByName( UIActivityMeeting.Widget , "text_time_fire" )
        if timeCount > 0 then
            local timeData = getTimeFormat( timeCount )           
            text_time:setString( Lang.ui_activity_meeting3..timeData[2]..":"..timeData[3]..":"..timeData[4] )
        else
            text_time:setString( Lang.ui_activity_meeting4 )
        end
        if timeCount == 0 and _timeSchedulerId then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry( _timeSchedulerId )
            _timeSchedulerId = nil
        end
    end
end
local function refreshInfo()
    local image_di_soul = ccui.Helper:seekNodeByName( UIActivityMeeting.Widget , "image_di_soul" )--炼魂
    local text_free = image_di_soul:getChildByName("btn_refining"):getChildByName("text_free")
    if _lianhunUse <= 0 then
        text_free:setString(Lang.ui_activity_meeting5)
    else
        text_free:setString(Lang.ui_activity_meeting6.._lianhunUse )
    end
 
    local image_di_treasure = ccui.Helper:seekNodeByName( UIActivityMeeting.Widget , "image_di_treasure" )--炼宝
    local text_free1 = image_di_treasure:getChildByName("btn_refining"):getChildByName("text_free")
    if _lianbaoUse <= 0 then
        text_free1:setString(Lang.ui_activity_meeting7)
    else
        text_free1:setString(Lang.ui_activity_meeting8.._lianbaoUse )
    end

    local text_integral = ccui.Helper:seekNodeByName( UIActivityMeeting.Widget , "text_integral" )--积分
    text_integral:setString( Lang.ui_activity_meeting9 .. _jifen )

    local text_reserves = ccui.Helper:seekNodeByName( UIActivityMeeting.Widget , "text_reserves" )--钻石量
    text_reserves:setString( Lang.ui_activity_meeting10 .. gold .. "/" .. max )

    _percent = gold * 100 / max
    local bar_ding = ccui.Helper:seekNodeByName( UIActivityMeeting.Widget , "bar_ding" )
    bar_ding:setPercent( _percent )
    particle:setPosition( cc.p( bar_ding:getPositionX() , bar_ding:getPositionY() - 90 + bar_ding:getContentSize().width * _percent / 100 ) )

    local text_title = ccui.Helper:seekNodeByName( UIActivityMeeting.Widget , "text_title" )--存储状态
    local text_time_fire = ccui.Helper:seekNodeByName( UIActivityMeeting.Widget , "text_time_fire" )--fire倒计时
    if state == 0 then
        _animation:setVisible( false )
        text_title:setVisible( true )
        text_time_fire:setVisible( false )
    elseif state == 1 then
        _animation:setVisible( true )
        text_title:setVisible( false )
        text_time_fire:setVisible( true )
        updateFireTime()
        _timeSchedulerId = cc.Director:getInstance():getScheduler():scheduleScriptFunc( updateFireTime , 1 , false )
    end
end

local function netCallBack( pack )
 --   UIActivityMeeting.setup()
    local number = pack.msgdata.int.number
    local thing = pack.msgdata.string.thing
    local gold1 = pack.msgdata.int.gold
    startEffect( number , thing , gold1 )
   -- UIActivityMeeting.setup()

    _lianhunUse = pack.msgdata.int.lianhun -- 炼魂消耗元宝
    _lianbaoUse = pack.msgdata.int.lianbao -- 炼宝消耗元宝
    _jifen = pack.msgdata.int.jifen --拥有积分
    gold = pack.msgdata.int.total --当前元宝数
    state = pack.msgdata.int.state --状态
    _time = pack.msgdata.long.time
    refreshInfo()
    UIActivityTime.refreshMoney()
end
--tag : 1 炼魂 2 炼宝
local function netSendData( tag )
    _tag = tag
    local sendData = {
        header = StaticMsgRule.makeRefDrug ,
        msgdata = {
            int = { type = tag }
        }
    }
    UIManager.showLoading()
    netSendPackage( sendData , netCallBack )
end
function showToastMsg(msg)
    _toastLayer = cc.Scale9Sprite:create("image/toast_bg.png")
   -- toast_bg:loadTexture("image/toast_bg.png")
    _toastLayer:setPreferredSize(cc.size(474, 105))
    local text = ccui.Text:create()
    text:setFontName(dp.FONT)
    text:setString(msg)
    text:setFontSize(20)
    text:setTextColor(cc.c4b(255, 255, 255, 255))
    _toastLayer:addChild(text)
    text:setPosition(cc.p(_toastLayer:getContentSize().width / 2, _toastLayer:getContentSize().height / 2 ))
    _toastLayer:setPosition(cc.p(UIManager.screenSize.width / 2, UIManager.screenSize.height / 2 + 100 ))
    _toastLayer:setName( "meetingToast" )
    UIManager.gameLayer:addChild(_toastLayer, 100)
end
function UIActivityMeeting.init()
    local btn_number = ccui.Helper:seekNodeByName( UIActivityMeeting.Widget , "btn_number" )
    local btn_luck = ccui.Helper:seekNodeByName( UIActivityMeeting.Widget , "btn_luck" )
    local btn_reward = ccui.Helper:seekNodeByName( UIActivityMeeting.Widget , "btn_reward" )
    local btn_help = ccui.Helper:seekNodeByName( UIActivityMeeting.Widget , "btn_help" )
    local image_di_soul = ccui.Helper:seekNodeByName( UIActivityMeeting.Widget , "image_di_soul" )--炼魂
    local btn_soul = image_di_soul:getChildByName("btn_refining")
    local image_di_treasure = ccui.Helper:seekNodeByName( UIActivityMeeting.Widget , "image_di_treasure" )--炼宝
    local btn_treasure = image_di_treasure:getChildByName("btn_refining")
    local image_ding = ccui.Helper:seekNodeByName( UIActivityMeeting.Widget , "image_ding" ) --yaoding
    local function onEvent( sender , eventType )
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_number then
                UIManager.pushScene( "ui_activity_meeting_number" )
            elseif sender == btn_luck then
                UIActivityMeetingLuck.setData( _thing , _day )
                UIManager.pushScene( "ui_activity_meeting_luck" )
            elseif sender == btn_reward then
                UIActivityMeetingPreview.show( { integral = _jifen } )
            elseif sender == btn_help then
                UIAllianceHelp.show( { type = 22 , titleName = Lang.ui_activity_meeting11 } )
            elseif sender == btn_soul then
                netSendData( 1 )
            elseif sender == btn_treasure then
                netSendData( 2 )
            elseif sender == image_ding then
                if _toastLayer then
                    _toastLayer:removeFromParent()
                    _toastLayer = nil
                end              
            end
        elseif eventType == ccui.TouchEventType.began then
            if sender == image_ding then
                if _toastLayer then
                    _toastLayer:removeFromParent()
                    _toastLayer = nil
                end 
                showToastMsg( Lang.ui_activity_meeting12 )
            end
        elseif eventType == ccui.TouchEventType.canceled then
            if sender == image_ding then
                if _toastLayer then
                    _toastLayer:removeFromParent()
                    _toastLayer = nil
                end              
            end
        end
    end
    btn_number:setPressedActionEnabled( true )
    btn_number:addTouchEventListener( onEvent )
    btn_luck:setPressedActionEnabled( true )
    btn_luck:addTouchEventListener( onEvent )
    btn_reward:setPressedActionEnabled( true )
    btn_reward:addTouchEventListener( onEvent )
    btn_help:setPressedActionEnabled( true )
    btn_help:addTouchEventListener( onEvent )
    btn_soul:setPressedActionEnabled( true )
    btn_soul:addTouchEventListener( onEvent )
    btn_treasure:setPressedActionEnabled( true )
    btn_treasure:addTouchEventListener( onEvent )
    image_ding:setTouchEnabled( true )
    image_ding:addTouchEventListener( onEvent )

    local bar_ding = ccui.Helper:seekNodeByName( UIActivityMeeting.Widget , "bar_ding" )
    bar_ding:setLocalZOrder( 99 )
    local animPath = "ani/ui_anim/ui_anim68/"
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(animPath .. "ui_anim68.ExportJson")
    _animation = ccs.Armature:create("ui_anim68")
    _animation:getAnimation():playWithIndex( 0 )
    _animation:setPosition( cc.p( bar_ding:getPositionX() , bar_ding:getPositionY() - 20 ) )
    bar_ding:getParent():addChild(_animation, 100)

    particle = cc.ParticleSystemQuad:create("particle/make/ui_anim68_1.plist")
    particle:setPositionType(cc.POSITION_TYPE_RELATIVE)
    particle:setPosition( cc.p( bar_ding:getPositionX() , bar_ding:getPositionY() - 90 + bar_ding:getContentSize().width * 5 / 100 ) )
    bar_ding:getParent():addChild(particle, 98)

end

local function updateTime()   
    if _endTime then
        local timeCount = _endTime - utils.getCurrentTime()
        local text_time = ccui.Helper:seekNodeByName( UIActivityMeeting.Widget , "text_time" )
        if timeCount > 0 then
            local timeData = getTimeFormat( timeCount )         
            text_time:setString( Lang.ui_activity_meeting13..timeData[1] ..Lang.ui_activity_meeting14..timeData[2]..":"..timeData[3]..":"..timeData[4] )
        else
            text_time:setString( Lang.ui_activity_meeting15 )
        end
        if timeCount == 0 and _schedulerId then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry( _schedulerId )
            _schedulerId = nil
        end
    end
end
function UIActivityMeeting.setup()
    local bar_ding = ccui.Helper:seekNodeByName( UIActivityMeeting.Widget , "bar_ding" )
  --  _percent = 100
    
    updateTime()
    _schedulerId = cc.Director:getInstance():getScheduler():scheduleScriptFunc( updateTime , 1 , false )

    local function callBack( pack )
        _lianhunUse = pack.msgdata.int.lianhun -- 炼魂消耗元宝
        _lianbaoUse = pack.msgdata.int.lianbao -- 炼宝消耗元宝
        _jifen = pack.msgdata.int.jifen --拥有积分
        _day = pack.msgdata.int.day --活动的第几天
        gold = pack.msgdata.int.total --当前元宝数
        max = pack.msgdata.int.max --活跃峰值
        state = pack.msgdata.int.state --状态
        _time = pack.msgdata.long.time --狂暴倒计时
        local dictActivityMeetingTeShu = {}
        _thing = {}
        for key ,value in pairs( pack.msgdata.message.meetteshu.message ) do
            table.insert( dictActivityMeetingTeShu , value )
        end
        utils.quickSort( dictActivityMeetingTeShu , function(obj1 , obj2 ) if obj1.int["1"] > obj2.int["1"] then return true end end )
        for key , value in pairs( dictActivityMeetingTeShu ) do
            table.insert( _thing , value.string["4"] )
        end
        -- local _thing = { "2_1011_1;2_2_10;3_2_1000;9_88_5" , "9_99_5;3_1_100;2_83_20;2_89_10" , "9_99_5;2_83_100;3_1_100;2_87_1000" , "9_99_10;2_1002_1;2_2_1000;2_9_100" }
        --cclog( "_day : ".._day )
        local obj = utils.stringSplit( _thing[ _day ] , ";" )
        local objThing = utils.getItemProp( obj[ 1 ] )
        local image_di_soul = ccui.Helper:seekNodeByName( UIActivityMeeting.Widget , "image_di_soul" )--炼魂
        local image_frame_good = image_di_soul:getChildByName( "image_frame_good" )
        image_frame_good:loadTexture( objThing.frameIcon )
        local image_good = image_frame_good:getChildByName( "image_good" )
        image_good:loadTexture( objThing.smallIcon )
        image_good:getChildByName( "text_name" ):setString( objThing.name )
        utils.showThingsInfo( image_good , objThing.tableTypeId , objThing.tableFieldId )
      

        local obj1 = utils.stringSplit( _thing[ 2 + _day ] , ";" )
        local objThing1 = utils.getItemProp( obj1[ 1 ] )
        local image_di_treasure = ccui.Helper:seekNodeByName( UIActivityMeeting.Widget , "image_di_treasure" )--炼宝
        local image_frame_good1 = image_di_treasure:getChildByName( "image_frame_good" )
        image_frame_good1:loadTexture( objThing1.frameIcon )
        local image_good1 = image_frame_good1:getChildByName( "image_good" )
        image_good1:loadTexture( objThing1.smallIcon )
        image_good1:getChildByName( "text_name" ):setString( objThing1.name )
        utils.showThingsInfo( image_good1 , objThing1.tableTypeId , objThing1.tableFieldId )

        refreshInfo()
    end
    UIManager.showLoading()
    netSendPackage( { header = StaticMsgRule.enterRefDrug , msgdata = { } } , callBack )
end
function UIActivityMeeting.free()
    if _schedulerId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_schedulerId)
        _schedulerId = nil
    end
    if _timeSchedulerId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_timeSchedulerId)
        _timeSchedulerId = nil
    end
    _endTime = nil
    _percent = nil
    _lianhunUse = nil
    _lianbaoUse = nil
    _thing = nil
    _jifen = nil
    _day = nil
    _tag = nil
    gold = nil
    max = nil
    state = nil
    _time = nil
    if _toastLayer then
        _toastLayer:removeFromParent()
        _toastLayer = nil
    end 
end
function UIActivityMeeting.onActivity(_params)
    local data = _params  
    _endTime = utils.GetTimeByDate( data.string["5"] )
end
