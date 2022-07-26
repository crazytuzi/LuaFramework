UIActivityFundReward = {}
local _tagIndex = nil
local _data = nil
local _srollView = nil
local _item = nil
local _day = nil
local _isBuy = nil
local _isA = nil
local function setScrollViewItem( item , thing )
    local image_big = item:getChildByName( "image_big" )
    local image_day = item:getChildByName( "image_day" )
    image_day:getChildByName("label_day"):setString( thing.id )
    if tonumber(thing.id) == 0 then
        image_big:setVisible( true )
        image_day:setVisible( false )
    else 
        image_big:setVisible( false )
        image_day:setVisible( true )
    end
    local dictData = utils.getItemProp( thing.thing )
    local image_frame_good = item:getChildByName( "image_frame_good" )
    image_frame_good:getChildByName( "image_good" ):loadTexture( dictData.smallIcon )
    image_frame_good:getChildByName( "text_name" ):setString( dictData.name.."×"..dictData.count )
    utils.addBorderImage( dictData.tableTypeId , dictData.tableFieldId , image_frame_good )
    utils.showThingsInfo( image_frame_good , dictData.tableTypeId , dictData.tableFieldId )
    local image_get = item:getChildByName( "image_get" )
    if _isBuy[ _tagIndex ] == 0 then
        image_get:setVisible( false )
    elseif tonumber( thing.id ) == 0 then
        if tonumber( _day ) == 6 then
            image_get:setVisible( true )
        else
            image_get:setVisible( false )
        end
    elseif tonumber( thing.id ) <= tonumber( _day ) then
        image_get:setVisible( true )
    else
        image_get:setVisible( false )
    end
end
local function refreshTag()
    local btn_fund1 = ccui.Helper:seekNodeByName( UIActivityFundReward.Widget , "btn_fund1" )
    local btn_fund2 = ccui.Helper:seekNodeByName( UIActivityFundReward.Widget , "btn_fund2" )
    local btn_fund3 = ccui.Helper:seekNodeByName( UIActivityFundReward.Widget , "btn_fund3" )
    local obj = nil 
    if _tagIndex == 1 then
        btn_fund1:loadTextureNormal("ui/tk_j_btn01.png")
        btn_fund1:getChildByName("text_name"):setTextColor(cc.c4b(0, 0, 0, 255))
        obj = _data.one
    else
        btn_fund1:loadTextureNormal("ui/tk_j_btn02.png")
        btn_fund1:getChildByName("text_name"):setTextColor(cc.c4b(255, 255, 255, 255))
    end
    if _tagIndex == 2 then
        btn_fund2:loadTextureNormal("ui/tk_j_btn01.png")
        btn_fund2:getChildByName("text_name"):setTextColor(cc.c4b(0, 0, 0, 255))
        obj = _data.two
    else
        btn_fund2:loadTextureNormal("ui/tk_j_btn02.png")
        btn_fund2:getChildByName("text_name"):setTextColor(cc.c4b(255, 255, 255, 255))
    end
    if _tagIndex == 3 then
        btn_fund3:loadTextureNormal("ui/tk_j_btn01.png")
        btn_fund3:getChildByName("text_name"):setTextColor(cc.c4b(0, 0, 0, 255))
        obj = _data.three
    else
        btn_fund3:loadTextureNormal("ui/tk_j_btn02.png")
        btn_fund3:getChildByName("text_name"):setTextColor(cc.c4b(255, 255, 255, 255))
    end
    _scrollView:removeAllChildren()
    utils.updateScrollView( UIActivityFund , _scrollView , _item , obj , setScrollViewItem )
end
function UIActivityFundReward.init()
    local btn_close = ccui.Helper:seekNodeByName( UIActivityFundReward.Widget , "btn_close" )
    local btn_closed = ccui.Helper:seekNodeByName( UIActivityFundReward.Widget , "btn_closed" )
    local btn_fund1 = ccui.Helper:seekNodeByName( UIActivityFundReward.Widget , "btn_fund1" )
    local btn_fund2 = ccui.Helper:seekNodeByName( UIActivityFundReward.Widget , "btn_fund2" )
    local btn_fund3 = ccui.Helper:seekNodeByName( UIActivityFundReward.Widget , "btn_fund3" )
    local function onEvent( sender , eventType )
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_close or sender == btn_closed then
                UIManager.popScene()
            elseif sender == btn_fund1 then
                if _tagIndex == 1 then
                    return
                end
                _tagIndex = 1
                refreshTag()
            elseif sender == btn_fund2 then
                if _tagIndex == 2 then
                    return
                end
                _tagIndex = 2
                refreshTag()
            elseif sender == btn_fund3 then
                if _tagIndex == 3 then
                    return
                end
                _tagIndex = 3
                refreshTag()
            end
        end
    end
    btn_close:setPressedActionEnabled( true )
    btn_close:addTouchEventListener( onEvent )
    btn_fund1:setPressedActionEnabled( true )
    btn_fund1:addTouchEventListener( onEvent )
    btn_fund2:setPressedActionEnabled( true )
    btn_fund2:addTouchEventListener( onEvent )
    btn_fund3:setPressedActionEnabled( true )
    btn_fund3:addTouchEventListener( onEvent )
    btn_closed:setPressedActionEnabled( true )
    btn_closed:addTouchEventListener( onEvent )

    _scrollView = ccui.Helper:seekNodeByName( UIActivityFundReward.Widget , "view_info" )
    _item = _scrollView:getChildByName( "image_base_reward" )
    _item:retain()
end
function UIActivityFundReward.setup()
    _tagIndex = 1
    _day = 0
    _data = { one = {} , two = {} , three = {} }
    _isBuy = { 0 , 0 , 0 }
    _scrollView:removeAllChildren()
    local btn_closed = ccui.Helper:seekNodeByName( UIActivityFundReward.Widget , "btn_closed" )
    if _isA then
        btn_closed:setVisible( false )
    else
        btn_closed:setVisible( true )
    end
    UIManager.showLoading()
    netSendPackage( { header = StaticMsgRule.fundInvokerReward , msgdata = {} } , function ( pack )
        _day = pack.msgdata.int.day
        local thingData = pack.msgdata.message.allfundreward.message
        local things = thingData[ "1" ].string
        _data.one = {}
        for i = 1 , 7 do
            _data.one[ i ] = { id = i - 1 , thing = things[ tostring( i - 1 ) ] }
        end

        things = thingData[ "2" ].string
        _data.two = {}
        for i = 1 , 7 do
            _data.two[ i ] = { id = i - 1 , thing = things[ tostring( i - 1 ) ] }
        end

        things = thingData[ "3" ].string
        _data.three = {}
        for i = 1 , 7 do
            _data.three[ i ] = { id = i - 1 , thing = things[ tostring( i - 1 ) ] }
        end
        _isBuy[ 1 ] = pack.msgdata.int.fund1
        _isBuy[ 2 ] = pack.msgdata.int.fund2
        _isBuy[ 3 ] = pack.msgdata.int.fund3
--        _data = {
--            one = { { id = 0 , thing = "3_1_50" } , { id = 1 , thing = "3_1_50" } , { id = 2 , thing = "3_1_50" } } , 
--            two = { { id = 0 , thing = "3_1_50" } , { id = 1 , thing = "3_1_50" } } ,
--            three = { { id = 0 , thing = "3_1_50" } , { id = 1 , thing = "3_1_50" } , { id = 2 , thing = "3_1_50" } , { id = 3 , thing = "3_1_50" }  }
--        }
        refreshTag()
    end)
    
end
function UIActivityFundReward.free()
    _tagIndex = nil
    _data = nil
    _day = nil
    _isBuy = nil
    _isA = nil
end
function UIActivityFundReward.onActivity(_params)
    _isA = true
end