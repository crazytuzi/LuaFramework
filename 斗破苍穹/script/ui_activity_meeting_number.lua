UIActivityMeetingNumber = {}
local _tag = nil
local _scrollView = nil
local _item = nil
local _data1 = nil
local _data2 = nil
local function refreshTag()
    local btn_soul = ccui.Helper:seekNodeByName( UIActivityMeetingNumber.Widget , "btn_soul" )--炼魂
    local btn_treasure = ccui.Helper:seekNodeByName( UIActivityMeetingNumber.Widget , "btn_treasure" )--炼宝
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
local function setScrollViewItem( sender , obj )
    local text_good = sender:getChildByName( "text_good" )
    local text_number = sender:getChildByName( "text_number" )
    local thing = utils.stringSplit( obj , "|" )
   -- cclog( ""..thing[ 1 ].."  "..thing[ 2 ] )
    text_number:setString( thing[1] )
    local data = utils.getItemProp( thing[2] )
   -- cclog( ""..data.name.."  "..data.count )
    text_good:setString( data.name .. "×" .. data.count )
end
local function refreshScrollView()
    local data = nil
    if _tag == 1 then
        data = _data1
    elseif _tag == 2 then
        data = _data2
    end
     _scrollView:removeAllChildren()
     _item:setAnchorPoint( cc.p( 0.5 , 0.5 ) )
     utils.updateScrollView( UIActivityMeetingNumber , _scrollView , _item , data , setScrollViewItem , { topSpace = 40 } )
end
function UIActivityMeetingNumber.init()
    local btn_close = ccui.Helper:seekNodeByName( UIActivityMeetingNumber.Widget , "btn_close" )
    local btn_sure = ccui.Helper:seekNodeByName( UIActivityMeetingNumber.Widget , "btn_sure" )
    local btn_soul = ccui.Helper:seekNodeByName( UIActivityMeetingNumber.Widget , "btn_soul" )--炼魂
    local btn_treasure = ccui.Helper:seekNodeByName( UIActivityMeetingNumber.Widget , "btn_treasure" )--炼宝
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
                refreshScrollView()
            elseif sender == btn_treasure then
                if _tag == 2 then
                    return
                end
                _tag = 2
                refreshTag()
                refreshScrollView()
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

    _scrollView = ccui.Helper:seekNodeByName( UIActivityMeetingNumber.Widget , "view_list" )
    _item = _scrollView:getChildByName( "panel_info" )
    _item:retain()
end

function UIActivityMeetingNumber.setup()
    _tag = 1
    refreshTag()
    local function callBack( pack )
        
        local list1 = pack.msgdata.string.list1
        local list2 = pack.msgdata.string.list2

        _data1 = utils.stringSplit( list1 , "/" )
        _data2 = utils.stringSplit( list2 , "/" )

        refreshScrollView()
    end
    UIManager.showLoading()
    netSendPackage( { header = StaticMsgRule.showMyNumber , msgdata = {} } , callBack )
end

function UIActivityMeetingNumber.free()
    _tag = nil
    _data1 = nil
    _data2 = nil
end
