UIGamePreview = {}
local _tagIndex = nil
local tab_one = nil
local tab_two = nil
local tab_three = nil
local _scrollView = nil
local _item = nil
local function setViewItem( item , data )
    item:getChildByName( "image_base_hint" ):getChildByName( "text_lv" ):setString( DictChallengeLevelDanNickname[ tostring( data.id ) ].nickname )
    local things = utils.stringSplit( data.reward , ";" )
    for i = 1 , 4 do
        local image_frame_good = item:getChildByName( "image_frame_good" .. i )
        if i <= #things then
            image_frame_good:setVisible( true )
            local thing = utils.getItemProp( things[ i ] )
            image_frame_good:loadTexture( thing.frameIcon )
            image_frame_good:getChildByName( "image_good" ):loadTexture( thing.smallIcon )
            image_frame_good:getChildByName( "text_name" ):setString( thing.name )
            image_frame_good:getChildByName( "text_number" ):setString( "×" .. thing.count )
        else
            image_frame_good:setVisible( false )
        end
    end
end
local function refreshInfo()
    _scrollView:removeAllChildren()
    local data = {}
    if _tagIndex == 1 then
        for key ,value in pairs( DictChallengeRewardDaily ) do
            data[ #data + 1 ] = value
        end
    elseif _tagIndex == 2 then
        for key ,value in pairs( DictChallengeRewardWeekly ) do
            data[ #data + 1 ] = value
        end
    elseif _tagIndex == 3 then
        for key ,value in pairs( DictChallengeRewardMonthly ) do
            data[ #data + 1 ] = value
        end
    end
    utils.quickSort( data , function( obj1 , obj2 )
        if obj1.id > obj2.id then
            return true
        else
            return false
        end
    end )
    utils.updateScrollView( UIGamePreview , _scrollView , _item , data , setViewItem , { topSpace = 30 } )
end
local function refreshTag()
    if _tagIndex == 1 then
        tab_one:loadTextureNormal("ui/yh_btn02.png")
        tab_one:getChildByName( "text_one" ):setTextColor( cc.c4b(51, 25, 4, 255) )
        tab_two:loadTextureNormal("ui/yh_btn01.png")
        tab_two:getChildByName( "text_two" ):setTextColor( cc.c4b(255, 255, 255, 255) )
        tab_three:loadTextureNormal("ui/yh_btn01.png")
        tab_three:getChildByName( "text_three" ):setTextColor( cc.c4b(255, 255, 255, 255) )
    elseif _tagIndex == 2 then
        tab_one:loadTextureNormal("ui/yh_btn01.png")
        tab_one:getChildByName( "text_one" ):setTextColor( cc.c4b(255, 255, 255, 255) )
        tab_two:loadTextureNormal("ui/yh_btn02.png")
        tab_two:getChildByName( "text_two" ):setTextColor( cc.c4b(51, 25, 4, 255) )
        tab_three:loadTextureNormal("ui/yh_btn01.png")
        tab_three:getChildByName( "text_three" ):setTextColor( cc.c4b(255, 255, 255, 255) )
    elseif _tagIndex == 3 then
        tab_one:loadTextureNormal("ui/yh_btn01.png")
        tab_one:getChildByName( "text_one" ):setTextColor( cc.c4b(255, 255, 255, 255) )
        tab_two:loadTextureNormal("ui/yh_btn01.png")
        tab_two:getChildByName( "text_two" ):setTextColor( cc.c4b(255, 255, 255, 255) )
        tab_three:loadTextureNormal("ui/yh_btn02.png")
        tab_three:getChildByName( "text_three" ):setTextColor( cc.c4b(51, 25, 4, 255) )
    end
    refreshInfo()
end
function UIGamePreview.init()
    local btn_close = ccui.Helper:seekNodeByName( UIGamePreview.Widget , "btn_close" )
    local btn_closed = ccui.Helper:seekNodeByName( UIGamePreview.Widget , "btn_closed" )
    tab_one = ccui.Helper:seekNodeByName( UIGamePreview.Widget , "tab_one" )
    tab_two = ccui.Helper:seekNodeByName( UIGamePreview.Widget , "tab_two" )
    tab_three = ccui.Helper:seekNodeByName( UIGamePreview.Widget , "tab_three" )
    local function onEvent( sender , eventType )
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_close or sender == btn_closed then
                UIManager.popScene()
            elseif sender == tab_one then
                if _tagIndex == 1 then
                    return
                end
                _tagIndex = 1
                refreshTag()
            elseif sender == tab_two then
                if _tagIndex == 2 then
                    return
                end
                _tagIndex = 2
                refreshTag()
            elseif sender == tab_three then
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
    btn_closed:setPressedActionEnabled( true )
    btn_closed:addTouchEventListener( onEvent )
    tab_one:setPressedActionEnabled( true )
    tab_one:addTouchEventListener( onEvent )
    tab_two:setPressedActionEnabled( true )
    tab_two:addTouchEventListener( onEvent )
    tab_three:setPressedActionEnabled( true )
    tab_three:addTouchEventListener( onEvent )

    _scrollView = ccui.Helper:seekNodeByName( UIGamePreview.Widget , "view_award_lv" )
    _item = _scrollView:getChildByName( "image_base_gift" )
    _item:setAnchorPoint( cc.p( 0.5 , 0.5 ) )
    _item:retain()
end
function UIGamePreview.setup()
    _tagIndex = 1
    refreshTag()
end
function UIGamePreview.free()
    _tagIndex = nil
end