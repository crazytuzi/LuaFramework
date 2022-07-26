require"Lang"
UISoulUpgrade = {}

local _objThing = nil

local scrollView = nil

local HEIGHT_SPACE = 15

local _item = nil

local _scrollViewHeight = nil

local _chooseTable = nil

local _soulData = nil

local bar_exp_new = nil

local text_lv_0 = nil

local text_info_0 = nil

local function getExp( soulId )
    local thing = net.InstPlayerFightSoul[ tostring( soulId ) ]
    local exp = thing.int[ "9" ] + DictFightSoul[ tostring( thing.int["3"] ) ].initExp
    if DictFightSoul[ tostring( thing.int["3"] )].isExpFightSoul == 1 then
    else
        for i = 1 , thing.int[ "5" ] - 1 do
            --cclog( "exp : "..exp .. "  "..(thing.int[ "5" ] - 1).."  "..DictFightSoulUpgradeExp[ tostring( ( thing.int[ "4" ] - 1 ) * 10 + thing.int[ "5" ] ) ].exp )
            exp = exp + DictFightSoulUpgradeExp[ tostring( ( thing.int[ "4" ] == 0 and 4 or thing.int[ "4" ] - 1 ) * 10 + i ) ].exp
        end 
    end
    return exp  
end

local function addExp()
    if _chooseTable and #_chooseTable > 0 and bar_exp_new then
        local exp = 0
        for key , value in pairs ( _chooseTable ) do
           -- cclog("key "..key .. " value "..value )
            exp = exp + getExp( value )
        end
        bar_exp_new:setPercent( ( exp + _objThing.int[ "9" ] ) * 100 / DictFightSoulUpgradeExp[ tostring( ( _objThing.int[ "4" ] == 0 and 4 or _objThing.int[ "4" ] - 1 ) * 10 + _objThing.int[ "5" ] ) ].exp )
        bar_exp_new:runAction( cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.5, 100), cc.FadeTo:create(0.5, 255))) )        
       -- _objThing.int[ "9" ] * 100 / DictFightSoulUpgradeExp[ tostring( ( _objThing.int[ "4" ] - 1 ) * 10 + _objThing.int[ "5" ] ) ].exp
        local lv = 0 
        local curExp = exp + _objThing.int[ "9" ]
        cclog( "curExp : "..curExp )
        while( curExp > 0 ) do
            curExp = curExp - DictFightSoulUpgradeExp[ tostring( ( _objThing.int[ "4" ] == 0 and 4 or _objThing.int[ "4" ] - 1 ) * 10 + _objThing.int[ "5" ] + lv ) ].exp 
         --   cclog("-------------->lv :"..( _objThing.int[ "4" ] == "0" and 4 or _objThing.int[ "4" ] - 1 ) * 10 + _objThing.int[ "5" ] + lv .. "    " ..DictFightSoulUpgradeExp[ tostring( ( _objThing.int[ "4" ] == "0" and 4 or _objThing.int[ "4" ] - 1 ) * 10 + _objThing.int[ "5" ] + lv ) ].exp )
            if curExp >= 0 then
                lv = lv + 1
                if _objThing.int[ "5" ] + lv > 10 then
                    lv = 10 - _objThing.int[ "5" ]
                    break
                end
            end
        end
        
        if lv > 0 then
            text_lv_0:setVisible( true )
            text_lv_0:setString( "+"..lv )
            text_info_0:setVisible( true )
            local proId , proValue , sell = utils.getSoulPro( _objThing.int[ "3" ] , _objThing.int[ "5" ] )
            local proId1 , proValue1 , sell1 = utils.getSoulPro( _objThing.int[ "3" ] , _objThing.int[ "5" ] + lv )
            if proValue1 - proValue < 1 then
                text_info_0:setString( "+"..( proValue1 - proValue )*100 .."%" )
            else
                text_info_0:setString( "+"..( proValue1 - proValue ) )
            end
            text_lv_0:runAction( cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.5, 100), cc.FadeTo:create(0.5, 255))) ) 
            text_info_0:runAction( cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.5, 100), cc.FadeTo:create(0.5, 255))) )        
        end
    else
        text_lv_0:setVisible( false )
        text_info_0:setVisible( false )
        bar_exp_new:stopAllActions()
        bar_exp_new:setPercent( ( _objThing.int[ "9" ] ) * 100 / DictFightSoulUpgradeExp[ tostring( ( _objThing.int[ "4" ] == 0 and 4 or _objThing.int[ "4" ] - 1 ) * 10 + _objThing.int[ "5" ] ) ].exp )
    end
end

local function netCallBack( data )
    UIManager.flushWidget( UISoulUpgrade )
    UIManager.flushWidget( UISoulBag )
   -- UIManager.flushWidget( UISoulInstall )
    UISoulInstall.refreshPageView()
end

local function sendData( )
    local sendData = {} ;  
    sendData = {
        header = StaticMsgRule.fightSoulUpgrade ,
        msgdata  = {
            int = {
                instPlayerFightSoulId = _objThing.int[ "1" ]
            },
            string = {
                 instPlayerFightSoulIdList = table.concat( _chooseTable , ";" )
            }
        }
    }
    UIManager.showLoading()
    netSendPackage( sendData , netCallBack )
end

local function isInTable( id )
   -- cclog(" length :".. #_chooseTable )
    for key ,value in pairs ( _chooseTable ) do
        if value == id then
            table.remove( _chooseTable , key )
            addExp()
            return true
        end
    end
    return false
end

local function freshTable( _Item , _obj )
    for key , value in pairs ( _chooseTable ) do
        if value == _obj.int[ "1" ] then
            local image_sure = ccui.Helper:seekNodeByName( _Item , "image_sure" )
            image_sure:setVisible( true )
            break
        end
    end
end

local function setScrollViewItem(_Item, _obj)
    local text_lv = ccui.Helper:seekNodeByName( _Item , "text_lv" )
    text_lv:setString( _obj.int[ "5" ] )
    local text_fire_name = ccui.Helper:seekNodeByName( _Item , "text_fire_name" )
    text_fire_name:setString( DictFightSoul[ tostring( _obj.int[ "3" ] ) ].name )
    local image_sure = ccui.Helper:seekNodeByName( _Item , "image_sure" )   
    local function onEvent( sender , eventType )
        if eventType == ccui.TouchEventType.ended then
--            UISoulInfo.setInfo( 0 , _obj )
--            UIManager.pushScene( "ui_soul_info" )
            if isInTable( _obj.int[ "1" ] ) then
                image_sure:setVisible( false )
                cclog(" false ")
            else
                table.insert( _chooseTable , _obj.int[ "1" ] )
                addExp()
                image_sure:setVisible( true )
                cclog(" true ")
            end
        --    cclog("id : ".._obj.int["1"])
        end
    end
    _Item:addTouchEventListener( onEvent )
    image_sure:setVisible( false )
    freshTable( _Item , _obj )
    local image_frame_fire = ccui.Helper:seekNodeByName( _Item , "image_frame_fire" )
    utils.ShowFightSoulQuality( image_frame_fire , _obj.int[ "4" ] , 0 )
    utils.changeNameColor( text_fire_name , _obj.int[ "4" ] , dp.Quality.fightSoul , true )
    ActionManager.setSoulEffectAction( _obj.int[ "3" ] , image_frame_fire:getParent() )
    utils.addSoulParticle( image_frame_fire:getParent() , DictFightSoul[ tostring( _obj.int[ "3" ] )].effects, DictFightSoul[ tostring( _obj.int[ "3" ] )].fightSoulQualityId )
end

local function updateSrollItem( thingData , isFresh )
    local listItem = _item
    local listItemSize = listItem:getContentSize()
    local scrollViewSize = scrollView:getContentSize()
    local space = HEIGHT_SPACE
    if not isFresh then
        if #thingData <= 15 then
            for key , value in pairs( thingData ) do
                local child = _item:clone()
                child:setAnchorPoint( cc.p( 0 , 1 ) )
                child:setPosition( cc.p( ( ( key - 1 ) % 5 ) * ( _item:getContentSize().width + HEIGHT_SPACE ) + 15 , scrollView:getInnerContainerSize().height - 5 - math.floor( ( key - 1 ) / 5 ) * ( _item:getContentSize().height + HEIGHT_SPACE ) ) )
                scrollView:addChild( child )
            end
        else
            scrollView:setInnerContainerSize( cc.size( scrollView:getContentSize().width , math.floor( ( #thingData - 1 ) / 5 + 1 ) * ( _item:getContentSize().height + HEIGHT_SPACE) ) )
            local count = #thingData > 25 and 25 or #thingData
            for i = 1 , count do
                local child = _item:clone()
                child:setAnchorPoint( cc.p( 0 , 1 ) )
                child:setPosition( cc.p( ( ( i - 1 ) % 5 ) * ( _item:getContentSize().width + HEIGHT_SPACE ) + 15 , scrollView:getInnerContainerSize().height - 5 - math.floor( ( i - 1 ) / 5 ) * ( _item:getContentSize().height + HEIGHT_SPACE ) ) )
                scrollView:addChild( child )
            end
        end
    end
   -- scrollView:scrollToBottom( 0.01 , false )

    local children = scrollView:getChildren()
    local innerHeight = scrollView:getInnerContainerSize().height
    local top = 1
    local bottom = math.min( 25 , #thingData)
    local function scrollingEvent(scrollUpdate)
        if scrollView:getChildrenCount() <= 0 then return end
        
        local containerY = scrollView:getInnerContainer():getPositionY()
        
        local showTop = math.floor((containerY + innerHeight - scrollViewSize.height - space ) /(listItemSize.height + space))
        local showBottom = math.floor((containerY + innerHeight ) /(listItemSize.height + space)) + 1
        
        showTop = math.max(1, math.min(#thingData, showTop * 5 ))
        showBottom = math.max(1, math.min(#thingData, showBottom * 5 ))
      --  cclog(" showTop : "..showTop .. " showBottom.."..showBottom)
        scrollUpdate = scrollUpdate or(showBottom < top or showTop > bottom)

        local function getPositionY(i)
            return scrollView:getInnerContainerSize().height - 5 - math.floor( ( i - 1 ) / 5 ) * ( _item:getContentSize().height + HEIGHT_SPACE )
        end
        
        local bufferCount = 25 
        if scrollUpdate then
            if showTop + bottom - top > #thingData then
                top = top - bottom + showBottom
                bottom = showBottom
            else
                bottom = showTop + bottom - top
                top = showTop
            end

            for tag = top, bottom do
                local i = ( ( tag - 1 ) % ( bufferCount ) ) + 1
               -- cclog("i.."..i)
                local child = children[i]
                if tag > #thingData then
                    child:setVisible( false )
                else
                    child:setVisible( true )
                    child:setPosition(child:getPositionX() , getPositionY( tag ))
                    child:setLocalZOrder(tag)
                    setScrollViewItem(child, thingData[tag])
                end
            end
            
        else
            while showTop < top do
                top = top - 1
                local i = ( ( top - 1 ) % ( bufferCount ) )  + 1 
               -- cclog( "top i "..i )
                local child = children[ i ]
                child:setPosition(child:getPositionX() , getPositionY( top ))
                child:setLocalZOrder(top)
                setScrollViewItem(child, thingData[top])
                bottom = bottom - 1
            end

            while showBottom > bottom do
                bottom = bottom + 1
                local i = ( ( bottom - 1 ) % ( bufferCount ) ) + 1
               -- cclog( "bottom i "..i )
                local child = children[ i ]
                child:setPosition( child:getPositionX() , getPositionY( bottom ))
                child:setLocalZOrder(bottom)
                setScrollViewItem(child, thingData[bottom])
                top = top + 1
            end
        end
    end
    if not isFresh then
        scrollView:addEventListener( function(sender, eventType)
            if eventType == ccui.ScrollviewEventType.scrolling then
                scrollingEvent()
            end
        end )
    end
    scrollingEvent( true )
end

function UISoulUpgrade.init()
	local btn_close = ccui.Helper:seekNodeByName( UISoulUpgrade.Widget , "btn_close" )
    local btn_sure = ccui.Helper:seekNodeByName( UISoulUpgrade.Widget , "btn_sure" )
    local btn_cancel = ccui.Helper:seekNodeByName( UISoulUpgrade.Widget , "btn_cancel" )
    local btn_auto = ccui.Helper:seekNodeByName( UISoulUpgrade.Widget , "btn_auto" )
    bar_exp_new = ccui.Helper:seekNodeByName( UISoulUpgrade.Widget , "bar_exp_new" )
    text_lv_0 = ccui.Helper:seekNodeByName( UISoulUpgrade.Widget , "text_lv_0" )
    text_info_0 = ccui.Helper:seekNodeByName( UISoulUpgrade.Widget , "text_info_0" )
    local function onEvent( sender , eventType )
         if eventType == ccui.TouchEventType.ended then
            if sender == btn_close then
                UIManager.popScene()
            elseif sender == btn_sure then
--                if _objThing.int[ "5" ] >= _objThing.int[ "4" ] * 10 then
--                    UIManager.showToast( "已达到最高级别" )
--                else
                 if #_chooseTable <= 0 then
                     UIManager.showToast( Lang.ui_soul_upgrade1 )
                 else
                     sendData()
                 end
--                end
            elseif sender == btn_cancel then
                if #_chooseTable > 0 then
                    UIManager.flushWidget( UISoulUpgrade )
                end
            elseif sender == btn_auto then
                UISoulChoose.setType( UISoulChoose.type.UPDATE )
                UIManager.pushScene( "ui_soul_choose" )
            end
         end
    end
    btn_close:setPressedActionEnabled( true )
    btn_close:addTouchEventListener( onEvent )
    btn_sure:setPressedActionEnabled( true )
    btn_sure:addTouchEventListener( onEvent )
    btn_cancel:setPressedActionEnabled( true )
    btn_cancel:addTouchEventListener( onEvent )
    btn_auto:setPressedActionEnabled( true )
    btn_auto:addTouchEventListener( onEvent )

    scrollView = ccui.Helper:seekNodeByName( UISoulUpgrade.Widget , "view_list" )
    _item = ccui.Helper:seekNodeByName( UISoulUpgrade.Widget , "panel_all" )
    _item:retain()
    _scrollViewHeight = scrollView:getInnerContainerSize().height
end

function UISoulUpgrade.setInfo( obj )
    _objThing = obj
end

function UISoulUpgrade.setup()
    _chooseTable = {}
    bar_exp_new:stopAllActions()
    text_lv_0:setVisible( false )
    text_info_0:setVisible( false )
    if _objThing then
        local text_name = ccui.Helper:seekNodeByName( UISoulUpgrade.Widget , "text_name" )
        text_name:setString( DictFightSoul[ tostring( _objThing.int[ "3" ] ) ].name )
        local text_quality = ccui.Helper:seekNodeByName( UISoulUpgrade.Widget , "text_quality" )
        text_quality:setString( Lang.ui_soul_upgrade2..DictFightSoulQuality[ tostring( _objThing.int[ "4" ] ) ].name )
        utils.changeNameColor( text_name , _objThing.int[ "4" ] , dp.Quality.fightSoul )
        local image_base_di = ccui.Helper:seekNodeByName( UISoulUpgrade.Widget , "image_base_di" )
        local text_lv = image_base_di:getChildByName( "text_lv" )
        if _objThing.int[ "5" ] == 10 then
            text_lv:setString( Lang.ui_soul_upgrade3 )
        else
            text_lv:setString( Lang.ui_soul_upgrade4.._objThing.int[ "5" ] )
        end
        local text_info = ccui.Helper:seekNodeByName( UISoulUpgrade.Widget , "text_info" )
        local proType , proValue , sellSilver = utils.getSoulPro( _objThing.int[ "3" ] , _objThing.int[ "5" ] )
        if proValue < 1 then
            text_info:setString( Lang.ui_soul_upgrade5.."+"..( proValue * 100 ).."%".. DictFightProp[tostring( proType )].name )
        else
            text_info:setString( Lang.ui_soul_upgrade6.."+"..proValue..DictFightProp[tostring( proType )].name )
        end
	    local bar_exp = ccui.Helper:seekNodeByName( UISoulUpgrade.Widget , "bar_exp" ) 
        
       -- cclog( " " .. _objThing.int[ "5" ] .. "   ".._objThing.int[ "4" ] )
        if _objThing.int[ "5" ] >= 10 then
            bar_exp:setPercent( 100 )
            bar_exp_new:setPercent( 100 )
        else
--        cclog( " " .. _objThing.int[ "5" ] .. "   ".._objThing.int[ "4" ] )
            bar_exp:setPercent( _objThing.int[ "9" ] * 100 / DictFightSoulUpgradeExp[ tostring( ( _objThing.int[ "4" ] == 0 and 4 or _objThing.int[ "4" ] - 1 ) * 10 + _objThing.int[ "5" ] ) ].exp )
            bar_exp_new:setPercent( _objThing.int[ "9" ] * 100 / DictFightSoulUpgradeExp[ tostring( ( _objThing.int[ "4" ] == 0 and 4 or _objThing.int[ "4" ] - 1 ) * 10 + _objThing.int[ "5" ] ) ].exp )
        end
        local image_black = ccui.Helper:seekNodeByName( UISoulUpgrade.Widget , "image_black" )
        ActionManager.setSoulEffectAction( _objThing.int[ "3" ] , image_black:getChildByName("panel") )
        utils.addSoulParticle( image_black:getChildByName("panel") , DictFightSoul[ tostring( _objThing.int[ "3" ] )].effects , DictFightSoul[ tostring( _objThing.int[ "3" ] )].fightSoulQualityId)
    end
    _soulData = {}
    if net.InstPlayerFightSoul then
        for key , value in pairs ( net.InstPlayerFightSoul ) do
            if value.int[ "6" ] == 0 and value.int[ "7" ] == 0 and DictFightSoul[ tostring( value.int[ "3" ] ) ].fightSoulQualityId ~= 5 and value.int[ "1" ] ~= _objThing.int[ "1" ] then
                table.insert( _soulData , value )
            end
        end
    end
    utils.quickSort( _soulData , function ( obj1 , obj2 )
        if DictFightSoul[ tostring( obj1.int[ "3" ] ) ].isExpFightSoul == 1 and DictFightSoul[ tostring( obj2.int[ "3" ] ) ].isExpFightSoul ~= 1 then
            return false
        elseif DictFightSoul[ tostring( obj1.int[ "3" ] ) ].isExpFightSoul ~= 1 and DictFightSoul[ tostring( obj2.int[ "3" ] ) ].isExpFightSoul == 1 then
            return true
        elseif DictFightSoul[ tostring( obj1.int[ "3" ] ) ].fightSoulQualityId > DictFightSoul[ tostring( obj2.int[ "3" ] ) ].fightSoulQualityId then
            return false
        elseif DictFightSoul[ tostring( obj1.int[ "3" ] ) ].fightSoulQualityId < DictFightSoul[ tostring( obj2.int[ "3" ] ) ].fightSoulQualityId then
            return true
        elseif  obj1.int[ "5" ] > obj2.int[ "5" ] then
            return true
        else
            return false
        end 
    end)
    scrollView:removeAllChildren()
    scrollView:setInnerContainerSize( cc.size( scrollView:getInnerContainerSize().width , _scrollViewHeight ) )
    updateSrollItem( _soulData )
end

function UISoulUpgrade.setChooseTable( _choose )
    if #_choose > 0 then
        local index = 1
        while #_chooseTable < 50 and index <= #_choose do
            for key , value in pairs ( _soulData ) do
                if value.int[ "4" ] == _choose[ index ] then
                    isInTable( value.int[ "1" ] )
                    table.insert( _chooseTable , value.int[ "1" ] )
                end
                if #_chooseTable >= 50 then
                    UIManager.showToast(Lang.ui_soul_upgrade7)
                    break
                end
            end
            index = index + 1
        end
        scrollView:removeAllChildren()
        scrollView:setInnerContainerSize( cc.size( scrollView:getInnerContainerSize().width , _scrollViewHeight ) )
        updateSrollItem( _soulData )
    end
    addExp()
  --  updateSrollItem( _soulData , true )
  --  cclog( "chooseLength : "..#_chooseTable )
end

function UISoulUpgrade.free()
    _objThing = nil
    _chooseTable = nil
    _soulData = nil
end
