require"Lang"
UIField = {}
local image_card = {}
local _scrollView1 = nil --结界滚动层
local _item1 = nil
local _scrollView2 = nil --小伙伴滚动层
local _moveScrollView = nil
local _item2 = nil
local _itemIndex = nil
local _friendData = nil --小伙伴
local _enchantmentData = nil--结界
local _isRuning = nil
local isActive = nil
local POSITION = {
    { 1 , 6 , 4 , 9 } ,
    { 1 , 6 , 4 , 9 } ,
    { 1 , 6 , 4 , 9 } ,
    { 1 , 6 , 4 , 9 } ,
}
local _curPositionX = nil --记录触摸拖动前的 滚动条坐标
local _preX = nil --记录触摸拖动前的 触摸点坐标
local _preY = nil --记录触摸拖动前的 触摸点坐标
local _curIcon = nil --临时用作移动
local _preIcon = nil --要移动的图标
local _preKey = nil --要移动的以前的key
local _isMove = nil
local _curEnchantInfo = nil
local _isChangeIcon = nil --移动了结界里的
local function scrollAssociatedView( disX )
    local container = _scrollView2:getInnerContainer()
    local width = ( container:getContentSize().width - _scrollView2:getContentSize().width ) 
   -- local x = container:getPositionX() - dis
    if width <= 0 then
        return 
    end
    --print( "x1 :" , container:getPositionX() , " x :" , x , " width :" , container:getContentSize().width , " width1 : " , _scrollView2:getContentSize().width ) 
    local percent = math.abs( disX ) * 100 / width
  --  print( "percent : " , percent )
    _scrollView2:scrollToPercentHorizontal( percent , 0.1 , false )
end
local function changeIcon( icon , instCard )
    print( "instCard:" , instCard )
    if instCard <= 0 then
        icon:setTag( 0 )
        icon:loadTexture( "ui/card_small_purple.png" )
        icon:getChildByName("image_card"):loadTexture( "ui/frame_tianjia.png" )   
        icon:getChildByName( "image_lv" ):setVisible( false )
    else
        icon:setTag( instCard )
        local instPlayerCardData = net.InstPlayerCard[ tostring( instCard ) ] 
        local dictCardData = DictCard[ tostring( instPlayerCardData.int[ "3" ] ) ]
        icon:loadTexture( utils.getQualityImage( dp.Quality.card , instPlayerCardData.int[ "4" ] , dp.QualityImageType.small ) )
        local instCardData = net.InstPlayerCard[tostring(instCard)]
        local isAwake = instCardData.int["18"] --是否已觉醒 0-未觉醒 1-觉醒
        icon:getChildByName("image_card"):loadTexture("image/" .. DictUI[tostring( isAwake == 1 and dictCardData.awakeSmallUiId or dictCardData.smallUiId)].fileName)        
        icon:getChildByName( "image_lv" ):setVisible( true )  
        icon:getChildByName( "image_lv" ):getChildByName( "label_lv" ):setString( ( instPlayerCardData.int["5"] - 1 ) )
    end            
end
local function onTouchBegan(touch, event)   
	if _isRuning then
		return false
	end
    local touchPoint = _moveScrollView:convertTouchToNodeSpace(touch)
    if touchPoint.x >= 0 and touchPoint.x <= _moveScrollView:getContentSize().width and touchPoint.y > 0 and touchPoint.y <= _moveScrollView:getContentSize().height then
   --     cclog( "began" )
        _curPositionX = _scrollView2:getInnerContainer():getPositionX()
        _preX = touchPoint.x
        _preY = touchPoint.y
     --   print( " x : " , touchPoint.x , " y : " , touchPoint.y )
        local childs = _scrollView2:getChildren()
        for key, obj in pairs( childs ) do
            if obj:isVisible() then
		        local objX , objY = obj:getPositionX() + _curPositionX , obj:getPositionY()
  --              print( " objX : " , objX , " objY : " , objY )
		        if touchPoint.x > objX - obj:getContentSize().width / 2 and touchPoint.x < objX + obj:getContentSize().width / 2 and
		            touchPoint.y > objY - obj:getContentSize().height / 2 and touchPoint.y < objY + obj:getContentSize().height / 2 then
                  --  _curIcon = obj
                    _isChangeIcon = false
                    _preIcon = obj
                    local instCard = obj:getTag()
                    changeIcon( _curIcon , instCard )
                    _curIcon:setPosition( cc.p( objX + _scrollView2:getPositionX() , objY + _scrollView2:getPositionY() ) )
			        break
		        end
            end
	    end
    else
        local view_page = ccui.Helper:seekNodeByName( UIField.Widget , "view_page" )
        local touchPoint = view_page:convertTouchToNodeSpace(touch)
        for key ,obj in pairs( image_card ) do
            if obj:isVisible() then
                local objX , objY = obj:getPositionX() , obj:getPositionY()
		        if touchPoint.x > objX - obj:getContentSize().width / 2 and touchPoint.x < objX + obj:getContentSize().width / 2 and
		            touchPoint.y > objY - obj:getContentSize().height / 2 and touchPoint.y < objY + obj:getContentSize().height / 2 then
                    if _curEnchantInfo[ key ] and _curEnchantInfo[ key ] > 0 then
                        _preKey = key
                        _isChangeIcon = true
                        _preIcon = obj
                        local instCard = obj:getTag()
                        changeIcon( _curIcon , instCard )
                        _curIcon:setVisible( true )
                        changeIcon( _preIcon , -1 )
                        _curIcon:setPosition( cc.p( objX + view_page:getPositionX() , objY + view_page:getPositionY() ) )
                   -- cclog( "点击了 里面有的" )
                   end
                   break
                end 
            end
        end
        if not _preIcon then
            return false
        end
    end 
	_isRuning = true
	return true
end

local function onTouchMoved(touch, event)
	-- cclog( "move" )   
    local touchPoint1 = _moveScrollView:getParent():convertTouchToNodeSpace(touch)
    if _isChangeIcon then
        _curIcon:setPosition( cc.p( touchPoint1.x , touchPoint1.y ) )
    else
        local touchPoint = _moveScrollView:convertTouchToNodeSpace(touch)
     --   print( "dis : " , touchPoint.x - _preX , " _curPositionX :" , _curPositionX )
        local touchDisX = ( touchPoint.x - _preX )
        local touchDisY = ( touchPoint.y - _preY )
       -- print( "touchDisY :" , touchDisY )
        
        if _isMove then
            _curIcon:setPosition( cc.p( touchPoint1.x , touchPoint1.y ) )
        elseif touchDisY > 10 and touchDisY > math.abs( touchDisX ) and _preIcon then
          --  print( "要求拖动图标移动了" )
            _curIcon:setVisible( true )
            _preIcon:setVisible( false )
            _isMove = true
            _curIcon:setPosition( cc.p( touchPoint1.x , touchPoint1.y ) )
        else
            local disX = _curPositionX + touchDisX
            local container = _scrollView2:getInnerContainer()
            local width = ( container:getContentSize().width - _scrollView2:getContentSize().width ) 
            if disX > 0 then
                disX = 0
            elseif disX < -width then
                disX = -width
            end
            scrollAssociatedView( disX )
        end
    end
end
--小伙伴
local function setScrollViewItem2( item , data )
    --print( data.int[ "3" ] )
    item:setTag( data.int["3"] )
    local instPlayerCardData = net.InstPlayerCard[ tostring( data.int[ "3" ] ) ] 
    cclog(instPlayerCardData.int["1"])

    
    local dictCardData = DictCard[ tostring( instPlayerCardData.int[ "3" ] ) ]
    item:loadTexture( utils.getQualityImage( dp.Quality.card , instPlayerCardData.int[ "4" ] , dp.QualityImageType.small ) )  
    local instCardData = net.InstPlayerCard[tostring(instPlayerCardData.int["1"])]
    local isAwake = instCardData.int["18"] --是否已觉醒 0-未觉醒 1-觉醒
    item:getChildByName( "image_card" ):loadTexture("image/" .. DictUI[tostring( isAwake == 1 and dictCardData.awakeSmallUiId or dictCardData.smallUiId)].fileName)  
    item:getChildByName( "image_lv" ):getChildByName( "label_lv" ):setString( ( instPlayerCardData.int["5"] - 1 ) )
end
local function refreshScrollView2()
    _friendData = {}
    local function inCurEnchatment( instId )
            for key , value in pairs( _curEnchantInfo ) do
                if tonumber( value ) == tonumber( instId ) then
                    return true
                end
            end
            return false
        end

        if net.InstPlayerFormation then
            for key ,value in pairs( net.InstPlayerFormation ) do
                if value.int[ "4" ] == 3 and not inCurEnchatment( value.int["3"] ) and value.int["10"] > 0  then
                    table.insert( _friendData , value )
                end
            end
        end
        _scrollView2:removeAllChildren()
        utils.updateHorzontalScrollView( UIField , _scrollView2 , _item2 , _friendData , setScrollViewItem2 )
end
local function onTouchEnded(touch, event)
	_isRuning = false
    _curIcon:setVisible( false )
    local view_page = ccui.Helper:seekNodeByName( UIField.Widget , "view_page" )
    local touchPoint = view_page:convertTouchToNodeSpace(touch)
    if _preIcon then
        local isUp = false
        for key ,obj in pairs( image_card ) do
            if obj:isVisible() then
                local objX , objY = obj:getPositionX() , obj:getPositionY()
		        if touchPoint.x > objX - obj:getContentSize().width / 2 and touchPoint.x < objX + obj:getContentSize().width / 2 and
		            touchPoint.y > objY - obj:getContentSize().height / 2 and touchPoint.y < objY + obj:getContentSize().height / 2 then
                    instCard = _curIcon:getTag()
                    if _isChangeIcon then
                        if _preKey == key then
                            changeIcon( _preIcon , instCard )
                        elseif obj:getTag() > 0 then
                            changeIcon( _preIcon , obj:getTag() )
                            changeIcon( obj , instCard )
                            local temp = _curEnchantInfo[ key ]
                            _curEnchantInfo[ key ] = instCard
                            _curEnchantInfo[ _preKey ] = temp
                        else
                            changeIcon( obj , instCard )
                            _curEnchantInfo[ key ] = instCard
                            _curEnchantInfo[ _preKey ] = 0
                        end
                    elseif obj:getTag() > 0 then
                        changeIcon( _preIcon , obj:getTag() )
                        changeIcon( obj , instCard )
                        _curEnchantInfo[ key ] = instCard
                        _preIcon:setVisible( true )
                    else
                        changeIcon( obj , instCard )
                        _curEnchantInfo[ key ] = instCard
                    end
                    isUp = true
                    refreshScrollView2()
                    break
                end 
            end
        end
        if not isUp then
            if _isChangeIcon then
                local touchPoint = _moveScrollView:convertTouchToNodeSpace(touch)
                if touchPoint.x >= 0 and touchPoint.x <= _moveScrollView:getContentSize().width and touchPoint.y > 0 and touchPoint.y <= _moveScrollView:getContentSize().height then
                    _curPositionX = _scrollView2:getInnerContainer():getPositionX()
                    local childs = _scrollView2:getChildren()
                    local inRect = nil
                    for key, obj in pairs( childs ) do
                        if obj:isVisible() then
		                    local objX , objY = obj:getPositionX() + _curPositionX , obj:getPositionY()
		                    if touchPoint.x > objX - obj:getContentSize().width / 2 and touchPoint.x < objX + obj:getContentSize().width / 2 and
		                        touchPoint.y > objY - obj:getContentSize().height / 2 and touchPoint.y < objY + obj:getContentSize().height / 2 then
                                instCard = _curIcon:getTag()
                                if obj:getTag() > 0 then
                                    changeIcon( _preIcon , obj:getTag() )
                                    _curEnchantInfo[ _preKey ] = obj:getTag()  
                                    changeIcon( obj , instCard )
                                    inRect = true
                                end
			                    break
		                    end
                        end
	                end
                    if not inRect then
                        _curEnchantInfo[ _preKey ] = 0
                        refreshScrollView2()
                    end
                else
                    _preIcon:setVisible( true )
                    if _isChangeIcon then
                        changeIcon( _preIcon , _curIcon:getTag() )
                    end
                end
            else
                _preIcon:setVisible( true )
                if _isChangeIcon then
                    changeIcon( _preIcon , _curIcon:getTag() )
                end
            end
        end
    end
    _isChangeIcon = nil
    _preIcon = nil
    if _isMove then
        _isMove = nil
    end
   --  cclog( "ended" )
end
function UIField.init()
    local btn_close = ccui.Helper:seekNodeByName( UIField.Widget , "btn_close" )
    local btn_help = ccui.Helper:seekNodeByName( UIField.Widget , "btn_help" )
    local btn_door = ccui.Helper:seekNodeByName( UIField.Widget , "btn_door" )
    local btn_activation = ccui.Helper:seekNodeByName( UIField.Widget , "btn_activation" )--激活
    local function onEvent( sender , eventType )
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_close then               
  --              print( "_itemIndex :" , _itemIndex )
                if net.InstPlayerEnchantment then
                    local curSlots = ""
--                    local function getFormationIdByInstId( instId )
--                        for key , value in pairs( net.InstPlayerFormation ) do
--                            if value.int[ "4" ] == 3 and tonumber( value.int[ "3" ] ) == tonumber( instId ) then
--                                return value.int[ "1" ]
--                            end
--                        end
--                        return 0
--                    end
                    for i = 1 , #POSITION[ _itemIndex ] do
                        local temp = POSITION[ _itemIndex ][ i ]
                        if _curEnchantInfo[ temp ] then
                            curSlots = curSlots .. _curEnchantInfo[ temp ]
                        else
                            curSlots = curSlots .. "0"
                        end        
                        if i ~= #POSITION[ _itemIndex ] then
                            curSlots = curSlots .. ";"
                        end 
                    end  
                    if net.InstPlayerEnchantment.string[ "4" ] ~= curSlots then
                        cclog( "位置变动了:" .. curSlots )
                        UIManager.showLoading()
				        netSendPackage( { header = StaticMsgRule.configEnchantment , msgdata = { int = { enchantmentId = tonumber(_itemIndex) } , string = { slots = curSlots } } } , function ( pack ) UIManager.flushWidget( UILineup ) UIManager.popScene() end )               
                    else
                        cclog( "没任何变化" )
                        UIManager.popScene()
                    end
                else
                    UIManager.popScene()
                end
            elseif sender == btn_door then
                local curSlots = ""
                for i = 1 , #POSITION[ _itemIndex ] do
                    local temp = POSITION[ _itemIndex ][ i ]
                    if _curEnchantInfo[ temp ] then
                        curSlots = curSlots .. _curEnchantInfo[ temp ]
                    else
                        curSlots = curSlots .. "0"
                    end        
                    if i ~= #POSITION[ _itemIndex ] then
                        curSlots = curSlots .. ";"
                    end 
                end  
                if isActive then
                    UIFieldHint.setData( { index = _itemIndex , data = curSlots } )
                else
                    UIFieldHint.setData( { index = _itemIndex , data = "0" } )
                end
                UIManager.pushScene( "ui_field_hint" )
            elseif sender == btn_activation then
                UIManager.showLoading()
  --              print( "_itemIndex :" , _itemIndex )
				netSendPackage( { header = StaticMsgRule.configEnchantment , msgdata = { int = { enchantmentId = tonumber(_itemIndex) } , string = { slots = "" } } } , function ( pack ) UIField.setup() end )
            elseif sender == btn_help then
                UIAllianceHelp.show( { type = 35 , titleName = Lang.ui_field1 } )
            end
        end
    end
    btn_close:setPressedActionEnabled( true )
    btn_close:addTouchEventListener( onEvent )
    btn_door:setPressedActionEnabled( true )
    btn_door:addTouchEventListener( onEvent )
    btn_activation:setPressedActionEnabled( true )
    btn_activation:addTouchEventListener( onEvent )
    btn_help:setPressedActionEnabled( true )
    btn_help:addTouchEventListener( onEvent )

    local view_page = ccui.Helper:seekNodeByName( UIField.Widget , "view_page" )
    local panel_page = view_page:getChildByName( "panel_page" )
    for i = 1 , 9 do
        image_card[ i ] = panel_page:getChildByName( "image_frame_card" .. i )
        image_card[ i ]:setTag( -1 )
    end

    _scrollView1 = ccui.Helper:seekNodeByName( UIField.Widget , "view_field" )
    _item1 = _scrollView1:getChildByName( "image_field" )
    _item1:getChildByName("image_wfg"):setVisible( false )
    _item1:retain()
    _scrollView2 = ccui.Helper:seekNodeByName( UIField.Widget , "view_warrior" )
    _item2 = _scrollView2:getChildByName( "image_frame_card" )
    _item2:retain()

  --  view_page:setLocalZOrder( _scrollView2:getLocalZOrder() + 1 )
    _scrollView1:setLocalZOrder( _scrollView2:getLocalZOrder() + 2 )
    btn_close:setLocalZOrder( _scrollView2:getLocalZOrder() + 2 )
    btn_help:setLocalZOrder( _scrollView2:getLocalZOrder() + 2 )

     local btn_activation = ccui.Helper:seekNodeByName( UIField.Widget , "btn_activation" )--激活
     btn_activation:setLocalZOrder( _scrollView2:getLocalZOrder() + 4 )
    
    _moveScrollView = _scrollView2:clone()
    _moveScrollView:removeAllChildren()
    _scrollView2:getParent():addChild( _moveScrollView , _scrollView2:getLocalZOrder() + 1 )

    _curIcon = _item2:clone()
    _curIcon:setVisible( false )
    _curIcon:setAnchorPoint( cc.p( 0.5 , 0.5 ) )
    _scrollView2:getParent():addChild( _curIcon , _scrollView2:getLocalZOrder() + 3 )

    _moveScrollView:setTouchEnabled( false )
   
end

local function refreshInfo()
    isActive = false
    local btn_activation = ccui.Helper:seekNodeByName( UIField.Widget , "btn_activation" )--激活
    if net.InstPlayerEnchantment and _itemIndex == tonumber( net.InstPlayerEnchantment.int["3"] )  then
        btn_activation:setVisible( false )

        _scrollView2:setVisible( true )
        _moveScrollView:setVisible( true )

        local listener = cc.EventListenerTouchOneByOne:create()
	    listener:setSwallowTouches(true)
	    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	    listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
	    listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
	    local eventDispatcher = _moveScrollView:getEventDispatcher()
		if eventDispatcher then
			eventDispatcher:removeEventListenersForTarget(_moveScrollView)
        end
	    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, _moveScrollView)
        isActive = true
    else
        btn_activation:setVisible( true )

        _scrollView2:setVisible( false )
        _moveScrollView:setVisible( false )
        local eventDispatcher = _moveScrollView:getEventDispatcher()
		if eventDispatcher then
			eventDispatcher:removeEventListenersForTarget(_moveScrollView)
        end
    end

    for i = 1 , #image_card do
        image_card[ i ]:setVisible( false )
        image_card[ i ]:setTag( -1 )
 --       _curEnchantInfo[ i ] = nil
        image_card[ i ]:getChildByName( "image_card" ):loadTexture( "ui/frame_tianjia.png" )
        image_card[ i ]:loadTexture( "ui/card_small_purple.png" )
        image_card[ i ]:getChildByName( "image_lv" ):setVisible( false )
    end
    local data = _enchantmentData[ _itemIndex ]
    local pro = utils.stringSplit( data.slots , ";" )
    for i = 1 , #POSITION[ _itemIndex ] do
        local temp = POSITION[ _itemIndex ][ i ]
        image_card[ temp ]:setVisible( true )
        local proData = utils.stringSplit( pro[ i ] , "_" )
        ccui.Helper:seekNodeByName( image_card[ temp ] , "text_number" ):setString( DictFightProp[ tostring( proData[ 1 ] ) ].name .."+" .. ( proData[ 2 ] * 100 ) .. "%"  )--生命+2%
        
        if isActive then
  --          cclog( "激活" )
            if _curEnchantInfo[ temp ] then
     --           cclog( "有物品" )
                changeIcon( image_card[ temp ] , _curEnchantInfo[ temp ] )
            end
        end
    end  
end
local function refreshBtn()
    local children = _scrollView1:getChildren()
    for key ,value in pairs ( children ) do
  --      print( "tag:" , value:getTag() )
        if value:getTag() == _itemIndex then
            value:getChildByName("image_wfg"):setVisible( true )
        else
            value:getChildByName("image_wfg"):setVisible( false )
        end
    end
    refreshInfo()
end
--结界
local function setScrollViewItem1( item , data )   
    item:setTag( data.id )
    local function onEvent( sender , eventType )
        if eventType == ccui.TouchEventType.ended then
            local needLevel = tonumber( data.needLevel )
            if tonumber( net.InstPlayer.int[ "4" ] ) < needLevel then
                UIManager.showToast( needLevel .. Lang.ui_field2 )
            else
                _itemIndex = data.id
                refreshBtn()
            end
        end
    end
    item:setTouchEnabled( true )
    item:addTouchEventListener( onEvent )
    item:getChildByName( "text_name" ):setScale( 0.8 )
    item:getChildByName( "text_name" ):setString( " " .. data.name )

end

function UIField.setup()   
    _friendData = {}
    _curEnchantInfo = {}
    
    _enchantmentData = {}
    for key ,value in pairs( DictEnchantment) do
        _enchantmentData[ #_enchantmentData + 1 ] = value 
    end
    utils.quickSort( _enchantmentData , function ( obj1 , obj2 )
        if obj1.id > obj2.id then
            return true
        else
            return false
        end
    end)
    _scrollView1:removeAllChildren()
    utils.updateHorzontalScrollView( UIField , _scrollView1 , _item1 , _enchantmentData , setScrollViewItem1 , { leftSpace = 10 , space = 20 } )

        
    local btn_activation = ccui.Helper:seekNodeByName( UIField.Widget , "btn_activation" )--激活

    if net.InstPlayerEnchantment then
        btn_activation:setVisible( false )

        _scrollView2:setVisible( true )
        _moveScrollView:setVisible( true )

        local listener = cc.EventListenerTouchOneByOne:create()
	    listener:setSwallowTouches(true)
	    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	    listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
	    listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
	    local eventDispatcher = _moveScrollView:getEventDispatcher()
        if eventDispatcher then
			eventDispatcher:removeEventListenersForTarget(_moveScrollView)
        end
	    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, _moveScrollView)

        _itemIndex = tonumber( net.InstPlayerEnchantment.int["3"] )
        local slots = net.InstPlayerEnchantment.string[ "4" ]
--        local function getInstIdByFormationId( formationId )
--            for key , value in pairs( net.InstPlayerFormation ) do
--                if value.int[ "4" ] == 3 and tonumber( value.int[ "1" ] ) == tonumber( formationId ) then
--                    return value.int[ "3" ]
--                end
--            end
--            return 0
--        end
        if slots then
            local slotsData = utils.stringSplit( slots , ";" )
            for key ,value in pairs( slotsData ) do
                if tonumber( value ) ~= 0 then
                    _curEnchantInfo[ POSITION[ _itemIndex ][ key ] ] = tonumber( value )
                end
            end
        end

        local function inCurEnchatment( instId )
            for key , value in pairs( _curEnchantInfo ) do
                if tonumber( value ) == tonumber( instId ) then
                    return true
                end
            end
            return false
        end

        if net.InstPlayerFormation then
            for key ,value in pairs( net.InstPlayerFormation ) do
                print( "-----" , value.int[ "4" ] , "  " , value.int[ "10" ] )
                if value.int[ "4" ] == 3 and not inCurEnchatment( value.int["3"] ) and value.int["10"] > 0 then
                    table.insert( _friendData , value )
                end
            end
        end
        _scrollView2:removeAllChildren()
        utils.updateHorzontalScrollView( UIField , _scrollView2 , _item2 , _friendData , setScrollViewItem2 )

        refreshBtn()
    else
        btn_activation:setVisible( true )
        _scrollView2:setVisible( false )
        _moveScrollView:setVisible( false )
        _itemIndex = 1
        refreshBtn()
    end
end
function UIField.free()
    _friendData = nil --小伙伴
    _curPositionX = nil
    _enchantmentData = nil--结界
    _isRuning = nil
    _preX = nil
    _preY = nil
    _isMove = nil
    _preIcon = nil
    _curEnchantInfo = nil
    _isChangeIcon = nil
    isActive = nil
end
