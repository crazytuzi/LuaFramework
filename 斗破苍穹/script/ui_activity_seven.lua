require"Lang"
UIActivitySeven = {}
local _scrollView = nil
local _item = nil
local DAY_COUNT = 10
local _schedulerId = nil
local _registerTime = nil
local _text_time = nil
local function getTaskDay()   
    local _curTime = utils.getCurrentTime()
    local _countdownTime =  ( _registerTime - _curTime )
    local day = math.floor(_countdownTime /(24 * 3600))
    local hour = math.floor(_countdownTime / 3600 % 24)
    local minute = math.floor(_countdownTime / 60 % 60)
    local second = math.floor(_countdownTime % 60)
    return { day , hour , minute , second }
end
local function updateTime( dt )
    local timeTable = getTaskDay()
    _text_time:setString( Lang.ui_activity_seven1 .. timeTable[ 1 ] .. Lang.ui_activity_seven2 .. timeTable[ 2 ] .. Lang.ui_activity_seven3 .. timeTable[ 3 ] .. Lang.ui_activity_seven4 )
end
local function setViewItem( item , data )
    local data = utils.stringSplit( data , "|" )
    local btnState = tonumber( data[ 3 ] )
    local btn_exchange = item:getChildByName( "btn_exchange" )
    local function onEvent( sender , eventType )
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_exchange then
                if btnState == 1 then
                    UIManager.showLoading()
                    netSendPackage( { header = StaticMsgRule.getSevenRecharge , msgdata = { int = { sevenRechargeId = tonumber( data[ 1 ] ) } } } , function ( pack )
                        UIActivitySeven.setup()
                    end)
                elseif btnState == 3 then
                    utils.checkGOLD(1)
                end
            end
        end
    end
    btn_exchange:setPressedActionEnabled( true )
    btn_exchange:addTouchEventListener( onEvent )
    if btnState == 1 then --tk_btn_red.png
        btn_exchange:setTouchEnabled( true )
        btn_exchange:setBright( true )
        btn_exchange:loadTextureNormal( "ui/tk_btn_red.png" )
        btn_exchange:loadTexturePressed( "ui/tk_btn_red.png" )
        btn_exchange:setTitleText( Lang.ui_activity_seven5 )
    elseif btnState == 2 then
        btn_exchange:setTouchEnabled( false )
        btn_exchange:setBright( false )
        btn_exchange:setTitleText( Lang.ui_activity_seven6 )
    elseif btnState == 3 then
        btn_exchange:setTouchEnabled( true )
        btn_exchange:setBright( true )
        btn_exchange:loadTextureNormal( "ui/tk_btn01.png" )
        btn_exchange:loadTexturePressed( "ui/tk_btn01.png" )
        btn_exchange:setTitleText( Lang.ui_activity_seven7 )
    elseif btnState == 4 then
        btn_exchange:setTouchEnabled( false )
        btn_exchange:setBright( false )
        btn_exchange:setTitleText( Lang.ui_activity_seven8 )
    end
    local text_info = item:getChildByName( "text_info" ) --第2天充值礼包
    text_info:setString( Lang.ui_activity_seven9 .. data[ 1 ] .. Lang.ui_activity_seven10 )
    local image_di = item:getChildByName( "image_di" )--物品
    local objThings = utils.stringSplit( data[ 2 ] , ";" )
    for i = 1 , 3 do
        local image_frame_good = image_di:getChildByName( "image_frame_good" .. i )
        if i <= #objThings then
            image_frame_good:setVisible( true )
            local obj = utils.getItemProp( objThings[ i ] )
            utils.addBorderImage( obj.tableTypeId , obj.tableFieldId , image_frame_good )
            local image_good = image_frame_good:getChildByName( "image_good" )
            image_good:loadTexture( obj.smallIcon )
            local text_price = image_frame_good:getChildByName( "text_price" )
            text_price:setString( obj.count )
        else
            image_frame_good:setVisible( false )
        end
    end
end
function UIActivitySeven.init()
    local image_basemap = ccui.Helper:seekNodeByName( UIActivitySeven.Widget , "image_basemap" )
    local panel_knife = image_basemap:getChildByName( "panel_knife" ) --3天
    local panel_gem = image_basemap:getChildByName( "panel_gem" )--5天
    utils.showThingsInfo( panel_gem , StaticTableType.DictThing , StaticThing.thing44  )
    local panel_card = image_basemap:getChildByName( "panel_card" )--7天
    utils.showThingsInfo( panel_card , StaticTableType.DictCard , 139  )
    local function onEvent( sender , eventType )
        if eventType == ccui.TouchEventType.ended then
            if sender == panel_knife then
                UIEquipmentNew.setDictEquipId(8)
                UIManager.pushScene("ui_equipment_new")
            end
        end
    end
    panel_knife:setTouchEnabled( true )
    panel_knife:addTouchEventListener( onEvent )
    _scrollView = ccui.Helper:seekNodeByName( UIActivitySeven.Widget , "view_info" )
    _item = _scrollView:getChildByName( "image_base_good" )
    _item:retain()
end
function UIActivitySeven.setup()
    UIManager.showLoading()
    netSendPackage( { header = StaticMsgRule.intoSevenRecharge , msgdata = {} } , function ( pack )
        local step = utils.stringSplit( pack.msgdata.string[ "1" ] , "|" )
        local image_basemap = ccui.Helper:seekNodeByName( UIActivitySeven.Widget , "image_basemap" )
        local text_schedule = image_basemap:getChildByName( "text_schedule" )--当前进度：5/7
        text_schedule:setString( Lang.ui_activity_seven11 .. step[ 1 ] .. "/" .. step[ 2 ] )

        _registerTime = pack.msgdata.int[ "2" ] / 1000 + utils.getCurrentTime()
        _text_time = image_basemap:getChildByName( "text_time" ) --活动结束倒计时：7天5小时30分
        updateTime()
        _schedulerId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(updateTime, 60 , false)

        local obj = pack.msgdata.string[ "3" ]
        local things = utils.stringSplit( obj , "/" )
        utils.quickSort( things , function ( obj1 , obj2 )
            local data1 = utils.stringSplit( obj1 , "|" )
            local btnState1 = tonumber( data1[ 3 ] )
            local data2 = utils.stringSplit( obj2 , "|" )
            local btnState2 = tonumber( data2[ 3 ] )
            if btnState1 == 1 and btnState2 ~= 1 then
                return false
            elseif btnState1 ~= 1 and btnState2 == 1 then
                return true
            elseif btnState1 == 3 and btnState2 ~= 3 then
                return false
            elseif btnState1 ~= 3 and btnState2 == 3 then
                return true
            elseif btnState1 == 4 and btnState2 ~= 4 then
                return false
            elseif btnState1 ~= 4 and btnState2 == 4 then
                return true
            elseif tonumber( data1[ 1 ] ) > tonumber( data2[ 1 ] ) then
                return true
            elseif tonumber( data1[ 1 ] ) < tonumber( data2[ 1 ] ) then
                return false
            else
                return false
            end
        end )
        utils.updateScrollView( UIActivitySeven , _scrollView , _item , things , setViewItem )
    end)
end
function UIActivitySeven.free()
    if _schedulerId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_schedulerId)
        _schedulerId = nil
    end
    _registerTime = nil
    _text_time = nil
end
function UIActivitySeven.isShowTip()
    local time = utils.GetTimeByDate( net.InstPlayer.registerTime )
    local startTime = utils.GetTimeByDate( DictSysConfigStr[tostring(StaticSysConfigStr.sevenRechargeOpenTime)].value )
    if time >= startTime and utils.getCurrentTime() <= time + tonumber( DictSysConfig[ tostring( StaticSysConfig.sevenRechargeDay ) ].value ) * 24 * 3600 then
        return true
    end
    return false
end
