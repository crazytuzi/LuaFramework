require"Lang"
UISoulList = {}

UISoulList.type = {
    SELL = 0 ,
    EQUIP = 1
}

local _type = nil

local _cardId = nil

local scrollView = nil

local _item = nil

local SCROLLVIEW_ITEM_SPACE = 0

local SELL_MAX = 50

local _sellTable = nil

local _soulData = nil

local _listTable = nil

local function isInTable( id )
   -- cclog(" length :".. #_chooseTable )
    for key ,value in pairs ( _sellTable ) do
        if value == id then
            table.remove( _sellTable , key )
            return true
        end
    end
    return false
end

local function netCallBack( data )
    
    if _type == UISoulList.type.EQUIP then
        UIManager.popScene()
    else
        UISoulList.setup()
    end
    UIManager.flushWidget( UISoulBag )
   
    
    UIManager.flushWidget( UILineup )
    UISoulInstall.refreshPageView()
   -- UIManager.flushWidget( UISoulInstall )
end

local function sendData( _soulId )
    local sendData = {}
    if _type == UISoulList.type.SELL then
        sendData = {
            header = StaticMsgRule.sellFightSoul , 
            msgdata = {
                string = {
                    fightSouleList = table.concat( _sellTable , ";")
                }
            }
        }
    elseif _type == UISoulList.type.EQUIP then
        cclog( "附魂 " .._soulId.." ".._cardId.instPlayerCardId.."  ".._cardId.position )
        sendData = {
            header = StaticMsgRule.stickFightSoul , 
            msgdata = {
                int = {
                    instPlayerFightSoulId = _soulId ,
                    instPlayerCardId = _cardId.instPlayerCardId ,
                    position = _cardId.position
                }
            }
        }
    end
    netSendPackage( sendData , netCallBack )
end

local function setScrollViewItem(_Item, _obj)
    local text_name = ccui.Helper:seekNodeByName( _Item , "text_name" )
    text_name:setString( DictFightSoul[ tostring( _obj.int[ "3" ] ) ].name )
    local text_quality = ccui.Helper:seekNodeByName( _Item , "text_quality" )
    text_quality:setString( DictFightSoulQuality[ tostring( _obj.int[ "4" ] ) ].name )
    local text_describe = ccui.Helper:seekNodeByName( _Item , "text_describe" )
    local proType , proValue , sellSilver = utils.getSoulPro( _obj.int[ "3" ] , _obj.int[ "5" ] )
    if _obj.int[ "4" ] == 5 then
        text_describe:setString( Lang.ui_soul_list1..sellSilver..Lang.ui_soul_list2 )
    elseif _obj.int[ "4" ] == 4 and DictFightSoul[ tostring( _obj.int[ "3" ] ) ].isExpFightSoul == 1 then
        text_describe:setString( Lang.ui_soul_list3..DictFightSoul[ tostring( _obj.int[ "3" ] ) ].initExp..Lang.ui_soul_list4)
    else
        if proValue < 1 then
            text_describe:setString( DictFightProp[tostring( proType )].name.."+"..( proValue * 100 ).."%" )
        else
            text_describe:setString( DictFightProp[tostring( proType )].name.."+"..proValue )
        end
    end
    --text_describe:setString( DictFightProp[tostring( DictFightSoulUpgradeProp[ tostring( _obj.int[ "3" ] ) ].fightPropId )].name.."+"..DictFightSoulUpgradeProp[ tostring( _obj.int[ "3" ] ) ].fightPropValue )
   
    local text_lv = ccui.Helper:seekNodeByName( _Item , "text_lv" )
    text_lv:setString( "LV.".._obj.int[ "5" ] )
    local image_silver = ccui.Helper:seekNodeByName( _Item , "image_silver" )
    local text_silver =image_silver:getChildByName( "text_silver" )
    text_silver:setString( "x"..sellSilver )
    local function onSelect( sender , eventType )
        if eventType == ccui.CheckBoxEventType.selected then
            if #_sellTable >= SELL_MAX then
                UIManager.showToast( Lang.ui_soul_list5 )
                sender:setSelected( false )
            else
                table.insert( _sellTable , _obj.int[ "1" ] )
            end
        elseif eventType == ccui.CheckBoxEventType.unselected then
            for key , value in pairs ( _sellTable ) do
                if value == _obj.int[ "1" ] then
                    table.remove( _sellTable , key )
                    break
                end
            end
        end
    end
    local btn_expansion = ccui.Helper:seekNodeByName( _Item , "btn_expansion" )
    local function onEvent( sender , eventType )
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_expansion then
                sendData( _obj.int[ "1" ] )
            end
        end
    end
    btn_expansion:setPressedActionEnabled( true )
    btn_expansion:addTouchEventListener( onEvent )
    local box_choose = ccui.Helper:seekNodeByName( _Item , "box_choose" )
    box_choose:setSelected( false )
    if _type == UISoulList.type.EQUIP then
        btn_expansion:setVisible( true )
        box_choose:setVisible( false )
        text_silver:setVisible( false )
        image_silver:setVisible( false )
        if _obj == _soulData[ 1 ] then
            UIGuidePeople.isGuide( btn_expansion , UISoulList )
        end
    elseif _type == UISoulList.type.SELL then
        btn_expansion:setVisible( false )
        box_choose:setVisible( true )
        text_silver:setVisible( true )
        image_silver:setVisible( true )
        box_choose:addEventListener( onSelect )
        for key ,value in pairs ( _sellTable ) do
            if value == _obj.int[ "1" ] then
                box_choose:setSelected( true )
                break
            end
        end
    end
    local text_for = ccui.Helper:seekNodeByName( _Item , "text_for" )
    if _obj.int[ "7" ] == 0 then
        text_for:setVisible( false )
    else
        text_for:setVisible( true )
        local cardName = DictCard[tostring(net.InstPlayerCard[tostring( _obj.int[ "7" ])].int["3"])].name
        text_for:setString(Lang.ui_soul_list6..cardName )
    end
    local image_frame_soul = ccui.Helper:seekNodeByName( _Item , "image_frame_soul" )
    utils.ShowFightSoulQuality( image_frame_soul , _obj.int[ "4" ] , 1 )
    utils.changeNameColor( text_name , _obj.int[ "4" ] , dp.Quality.fightSoul )
    ActionManager.setSoulEffectAction( _obj.int[ "3" ] , image_frame_soul:getChildByName( "image_soul" ) )
    utils.addSoulParticle( image_frame_soul:getChildByName( "image_soul" ) , DictFightSoul[ tostring( _obj.int[ "3" ] )].effects , DictFightSoul[ tostring( _obj.int[ "3" ] )].fightSoulQualityId)
end

local function layoutScrollView(_listData, _initItemFunc)
    scrollView:removeAllChildren()
    scrollView:jumpToTop()
    local _innerHeight = 0
    for key, obj in pairs(_listData) do
        local scrollViewItem = _item:clone()
        _initItemFunc(scrollViewItem, obj)
       -- cclog("aa .. "..obj)
        scrollView:addChild(scrollViewItem)
        _innerHeight = _innerHeight + scrollViewItem:getContentSize().height + SCROLLVIEW_ITEM_SPACE
    end
    _innerHeight = _innerHeight + SCROLLVIEW_ITEM_SPACE
    if _innerHeight < scrollView:getContentSize().height then
        _innerHeight = scrollView:getContentSize().height
    end
    scrollView:setInnerContainerSize(cc.size(scrollView:getContentSize().width, _innerHeight))
    local childs = scrollView:getChildren()
    local prevChild = nil
    for i = 1, #childs do
        if i == 1 then
            childs[i]:setPosition(scrollView:getContentSize().width / 2, scrollView:getInnerContainerSize().height - childs[i]:getContentSize().height / 2 - SCROLLVIEW_ITEM_SPACE)
        else
            childs[i]:setPosition(scrollView:getContentSize().width / 2, prevChild:getBottomBoundary() - childs[i]:getContentSize().height / 2 - SCROLLVIEW_ITEM_SPACE)
        end
        prevChild = childs[i]
    end
    ActionManager.ScrollView_SplashAction(scrollView)
end

function UISoulList.init()
	local btn_close = ccui.Helper:seekNodeByName( UISoulList.Widget , "btn_close" )
    local btn_choose = ccui.Helper:seekNodeByName( UISoulList.Widget , "btn_choose" )
    local btn_sell = ccui.Helper:seekNodeByName( UISoulList.Widget , "btn_sell" )
    local function onEvent( sender , eventType )
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_close then
                UIManager.popScene()
            elseif sender == btn_choose then
                UISoulChoose.setType( UISoulChoose.type.SELL )
                UIManager.pushScene( "ui_soul_choose" )
            elseif sender == btn_sell then
                if #_sellTable <= 0 then
                    UIManager.showToast( Lang.ui_soul_list7 ) 
                else
                    sendData()
                end
            end
        end
    end
    btn_close:setPressedActionEnabled( true )
    btn_close:addTouchEventListener( onEvent )
    btn_choose:setPressedActionEnabled( true )
    btn_choose:addTouchEventListener( onEvent )
    btn_sell:setPressedActionEnabled( true )
    btn_sell:addTouchEventListener( onEvent )

    scrollView = ccui.Helper:seekNodeByName( UISoulList.Widget , "view_list" )
    _item = scrollView:getChildByName( "image_base_soul" )
    _item:retain()
end
local function isInListTable( _obj )
    local proId , proValue , sell = utils.getSoulPro( _obj.int[ "3" ] , _obj.int[ "5" ] )
    for key ,value in pairs( _listTable ) do       
        local proId1 , proValue1 , sell1 = utils.getSoulPro( value.int[ "3" ] , value.int[ "5" ] )
        if proId1 == proId and proValue >= 1 and proValue1 >= 1 then
            return true
        elseif proId1 == proId and proValue < 1 and proValue1 <= 1 then
            return true
        end
    end
    return false
end
function UISoulList.setup()
--	local a = { 1 , 2 , 3 }
--    layoutScrollView( a , setScrollViewItem )
    _sellTable = {}
    _soulData = {}
    if net.InstPlayerFightSoul then
        for key , value in pairs ( net.InstPlayerFightSoul ) do
            if _type == UISoulList.type.SELL then
                if value.int[ "6" ] == 0 and value.int[ "7" ] == 0 then
                    table.insert( _soulData , value )
                end
            else
                if value.int[ "4" ] < 5 and DictFightSoul[ tostring( value.int[ "3" ] ) ].isExpFightSoul == 0 and not isInListTable( value ) and value.int[ "6" ] == 0 and value.int[ "7" ] == 0 then
                    table.insert( _soulData , value )
                end
            end
        end
    end
    if _type == UISoulList.type.SELL then
        utils.quickSort( _soulData , function ( obj1 , obj2 )
            if DictFightSoul[ tostring( obj1.int[ "3" ] ) ].fightSoulQualityId > DictFightSoul[ tostring( obj2.int[ "3" ] ) ].fightSoulQualityId then
                return false
            elseif DictFightSoul[ tostring( obj1.int[ "3" ] ) ].fightSoulQualityId < DictFightSoul[ tostring( obj2.int[ "3" ] ) ].fightSoulQualityId then
                return true
            elseif obj1.int[ "5" ] > obj2.int[ "5" ] then
                return true
            else
                return false
            end 
        end)
    elseif _type == UISoulList.type.EQUIP then
        utils.quickSort( _soulData , function ( obj1 , obj2 )
            if obj1.int[ "7" ] == 0 and obj2.int[ "7" ] ~= 0 then
                return true
            elseif obj1.int[ "7" ] ~= 0 and obj2.int[ "7" ] == 0 then
                return false
            elseif obj1.int[ "5" ] > obj2.int[ "5" ] then
                return false
            elseif obj1.int[ "5" ] < obj2.int[ "5" ] then
                return true
            elseif DictFightSoul[ tostring( obj1.int[ "3" ] ) ].fightSoulQualityId > DictFightSoul[ tostring( obj2.int[ "3" ] ) ].fightSoulQualityId then
                return true
            elseif DictFightSoul[ tostring( obj1.int[ "3" ] ) ].fightSoulQualityId < DictFightSoul[ tostring( obj2.int[ "3" ] ) ].fightSoulQualityId then
                return false
            else
                return false
            end 
        end)
    end
 --   layoutScrollView( _soulData , setScrollViewItem )
    scrollView:removeAllChildren()
    utils.updateScrollView( UISoulList , scrollView , _item , _soulData , setScrollViewItem )
--    utils.quickSort( _soulData , function ( obj1 , obj2 )
--        if obj1.id > obj2.id then
--            return true
--        else
--            return false
--        end
--    end)
    local btn_choose = ccui.Helper:seekNodeByName( UISoulList.Widget , "btn_choose" )
    local btn_sell = ccui.Helper:seekNodeByName( UISoulList.Widget , "btn_sell" )
    local text_title = ccui.Helper:seekNodeByName( UISoulList.Widget , "text_title" ) 
    if _type == UISoulList.type.EQUIP then
        btn_choose:setVisible( false )
        btn_sell:setVisible( false )
        text_title:setString( Lang.ui_soul_list8 )
    elseif _type == UISoulList.type.SELL then
        btn_choose:setVisible( true )
        btn_sell:setVisible( true )
        text_title:setString( Lang.ui_soul_list9 )
    end
end

function UISoulList.setType( type1 , cardId )
    _type = type1
    _listTable = {}
    if cardId then
        _cardId = {
            instPlayerCardId = cardId.instPlayerCardId ,
            position =  cardId.position
        }
        if net.InstPlayerFightSoul then
            for key , value in pairs ( net.InstPlayerFightSoul ) do
                if value.int[ "7" ] == cardId.instPlayerCardId and value.int[ "8" ] ~= cardId.position then
                    table.insert( _listTable , value )
                end
            end
        end
    end
end

function UISoulList.setChooseTable( _choose )
   if #_choose > 0 then
        local index = 1
        while #_sellTable < 50 and index <= #_choose do
            for key , value in pairs ( _soulData ) do
                if value.int[ "4" ] == _choose[ index ] then
                    isInTable( value.int[ "1" ] )
                    table.insert( _sellTable , value.int[ "1" ] )
                end
                if #_sellTable >= 50 then
                    UIManager.showToast(Lang.ui_soul_list10)
                    break
                end
            end
            index = index + 1
        end
    end
    local function isInSTable( id )
       -- cclog(" length :".. #_chooseTable )
        for key ,value in pairs ( _sellTable ) do
            if value == id then
                return true
            end
        end
        return false
    end
    utils.quickSort( _soulData , function ( obj1 , obj2 )
        if not isInSTable(obj1.int["1"]) and isInSTable(obj2.int["1"]) then
            return true
        elseif not isInSTable(obj2.int["1"]) and isInSTable(obj1.int["1"]) then
            return false
        end
end)
    scrollView:removeAllChildren()
    utils.updateScrollView( UISoulList , scrollView , _item , _soulData , setScrollViewItem )
    cclog( "list chooseLength : "..#_sellTable )
end

function UISoulList.free()
    _type = nil
    _sellTable = nil
    _cardId = nil
    _soulData = nil
    _listTable = nil
end
