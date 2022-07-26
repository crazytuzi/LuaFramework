require"Lang"
UISoulGet = {}

local scrollView = nil
local _item = nil
local _length = 0
local _scrollViewHeight = nil
local HEIGHT_SPACE = 20
local image_card_select = nil
local _tempSoulId = nil
local _tempIndex = nil
local _soulData = nil


function showNoEnoughDialog( buyNum )
   
    local ui_middle = ccui.Layout:create()
    ui_middle:setContentSize(display.size)
    ui_middle:setTouchEnabled(true)
    ui_middle:retain()

    local bg_image = cc.Scale9Sprite:create("ui/dialog_bg.png")
    ui_middle:addChild(bg_image)
    bg_image:setAnchorPoint(cc.p(0.5, 0.5))
    bg_image:setPreferredSize(cc.size(500, 500))
    bg_image:setPosition(display.size.width / 2, display.size.height / 2)
    local bgSize = bg_image:getPreferredSize()

    local title = ccui.Text:create()
    title:setString(Lang.ui_soul_get1)
    title:setFontName(dp.FONT)
    title:setFontSize(35)
    title:setTextColor(cc.c4b(255, 255, 0, 255))
    title:setPosition(cc.p(bgSize.width / 2, bgSize.height - title:getContentSize().height - 15))
    bg_image:addChild(title, 3)

    local msgLabel = ccui.Text:create()
    msgLabel:setString(Lang.ui_soul_get2)
    msgLabel:setTextAreaSize(cc.size(425, 500))
    msgLabel:setFontName(dp.FONT)
    msgLabel:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    msgLabel:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    msgLabel:setFontSize(26)
    msgLabel:setPosition(cc.p(bgSize.width / 2, bgSize.height - title:getContentSize().height * 3.5))
    bg_image:addChild(msgLabel, 3)

    local node = cc.Node:create()
    local image_di = ccui.ImageView:create("ui/quality_small_blue.png")
    local image = ccui.ImageView:create("image/poster_item_small_yinpiao.png")
    local description = ccui.Text:create()
    description:setFontSize(20)
    description:setFontName(dp.FONT)
    description:setAnchorPoint(cc.p(0.5, 1))
    description:setTextColor(cc.c3b(255, 255, 0))
    image:setPosition(cc.p(image_di:getContentSize().width / 2, image_di:getContentSize().height / 2))
    image_di:addChild(image)
    image_di:setPosition(cc.p(0, 0))
    description:setPosition(cc.p(0, - image_di:getContentSize().height / 2 - 5))
    node:addChild(image_di)
    node:addChild(description)
    description:setString(Lang.ui_soul_get3 .. DictSysConfig[tostring(StaticSysConfig.silverNoteToCopper)].value)
    node:setPosition(cc.p(bgSize.width / 2, msgLabel:getPositionY() -95))
    bg_image:addChild(node, 3)

    local closeBtn = ccui.Button:create("ui/btn_x.png", "ui/btn_x.png")
    closeBtn:setPressedActionEnabled(true)
    closeBtn:setPosition(cc.p(bgSize.width - closeBtn:getContentSize().width / 2, bgSize.height - closeBtn:getContentSize().height / 2))
    bg_image:addChild(closeBtn, 3)

    local sureBtn = ccui.Button:create("ui/yh_sq_btn01.png", "ui/yh_sq_btn01.png")
    sureBtn:setName("sureBtn")
    sureBtn:setTitleText(Lang.ui_soul_get4)
    sureBtn:setTitleFontName(dp.FONT)
    sureBtn:setTitleFontSize(25)
    sureBtn:setPressedActionEnabled(true)
    sureBtn:setPosition(cc.p(bgSize.width / 4, bgSize.height * 0.2))
    bg_image:addChild(sureBtn, 3)


    local useBtn = ccui.Button:create("ui/tk_btn01.png", "ui/tk_btn01.png")
    useBtn:setName("useBtn")
    useBtn:setTitleText(Lang.ui_soul_get5)
    useBtn:setTitleFontName(dp.FONT)
    useBtn:setTitleFontSize(25)
    useBtn:setPressedActionEnabled(true)
    useBtn:setPosition(cc.p(bgSize.width / 4 * 3, bgSize.height * 0.2))
    bg_image:addChild(useBtn, 3)

    local count , thingId = 0 , 0
    if net.InstPlayerThing then 
        for key, obj in pairs(net.InstPlayerThing) do
            if obj.int and obj.int["7"] == StaticBag_Type.item and obj.int["3"] == StaticThing.silverNote10000 then
                count = obj.int["5"]
                thingId = obj.int["1"]
                break
            end
        end 
    end


    local rightHint = ccui.RichText:create()
    rightHint:setName("rightHint")
    rightHint:pushBackElement(ccui.RichElementText:create(1, display.COLOR_WHITE, 255, Lang.ui_soul_get6, dp.FONT, 20))
    rightHint:pushBackElement(ccui.RichElementText:create(2, cc.c3b(255, 255, 0), 255, tostring( count ), dp.FONT, 20))
    rightHint:pushBackElement(ccui.RichElementText:create(3, display.COLOR_WHITE, 255, Lang.ui_soul_get7, dp.FONT, 20))
    rightHint:setPosition(cc.p(bgSize.width / 4 * 3, bgSize.height * 0.1))
    bg_image:addChild(rightHint, 3)


    local leftHint = ccui.RichText:create()
    leftHint:setName("rightHint")
    leftHint:pushBackElement(ccui.RichElementText:create(1, display.COLOR_WHITE, 255, Lang.ui_soul_get8, dp.FONT, 20))
    leftHint:pushBackElement(ccui.RichElementText:create(2, cc.c3b(255, 255, 0), 255, tostring( buyNum ), dp.FONT, 20))
    leftHint:pushBackElement(ccui.RichElementText:create(3, display.COLOR_WHITE, 255, Lang.ui_soul_get9, dp.FONT, 20))
    leftHint:setPosition(cc.p(bgSize.width / 4 , bgSize.height * 0.1))
    bg_image:addChild(leftHint, 3)

    local function btnEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            AudioEngine.playEffect("sound/button.mp3")
            UIManager.uiLayer:removeChild(ui_middle, true)
            cc.release(ui_middle)
            if sender == sureBtn then
                if buyNum > 0 then
                    UISellProp.setData({type = 1,num = buyNum},UISoulGet)
                    UIManager.pushScene("ui_sell_prop")
                else
                    UIManager.showToast(Lang.ui_soul_get10)
                end
            elseif sender == useBtn then
                if count > 0 then
                    UISellProp.setData({type = 2,num=count,thingsId = thingId },UISoulGet)
                    UIManager.pushScene("ui_sell_prop")
                else
                    UIManager.showToast(Lang.ui_soul_get11)
                end
            elseif sender == closeBtn then
                
            end
        end
    end
    sureBtn:addTouchEventListener(btnEvent)
    useBtn:addTouchEventListener(btnEvent)
    closeBtn:addTouchEventListener(btnEvent)
    bg_image:setScale(0.1)
    UIManager.uiLayer:addChild(ui_middle, 10000)
    bg_image:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1.1), cc.ScaleTo:create(0.06, 1)))
end
local function getNumCallBack( data )
    showNoEnoughDialog( data.msgdata.int["canBuyNum"] )
end

local function netSendDataGetNum()
    local sendData = {
        header = StaticMsgRule.getFightSoulBuySilverTimes,
			msgdata = {
				int = {
					
				}
			}
    }
    netSendPackage( sendData , getNumCallBack )
end

local function addItem( _data )
    local count = _length + #_data 
    local function onEvent( sender , eventType )
        if eventType == ccui.TouchEventType.ended then
            UISoulInfo.setInfo( 0 , nil )
            UIManager.pushScene( "ui_soul_info" )
        end
    end
    if scrollView:getContentSize().height < math.floor( ( count - 1 ) / 5 + 1 ) * ( _item:getContentSize().height + HEIGHT_SPACE ) then
       -- scrollView:setPosition( cc.p( scrollView:getPositionX() , scrollView:getPositionY() + ( math.floor( count / 5 + 1 ) * _item:getContentSize().height - scrollView:getContentSize().height ) ) )
        scrollView:setInnerContainerSize( cc.size( scrollView:getContentSize().width , math.floor( ( count - 1 ) / 5 + 1 ) * ( _item:getContentSize().height + HEIGHT_SPACE) ) )
    end
   -- cclog( " scrollView:getContentSize().height : "..scrollView:getInnerContainerSize().height )
    local childs = scrollView:getChildren()
    for i = 1 , #childs do
    --    cclog( "    " .. childs[ i ]:getTag() )
        childs[ i ]:setPosition( cc.p( childs[ i ]:getPositionX() , scrollView:getInnerContainerSize().height - 5 - math.floor( childs[ i ]:getTag() / 5 ) * ( _item:getContentSize().height + HEIGHT_SPACE ) ) )
    end
    for key , value in pairs( _data ) do
        local item = _item:clone()
        item:setAnchorPoint( cc.p( 0 , 1 ) )
        item:setPosition( cc.p( ( _length % 5 ) * ( _item:getContentSize().width + HEIGHT_SPACE ) + 15 , scrollView:getInnerContainerSize().height - 5 - math.floor( ( _length ) / 5 ) * ( _item:getContentSize().height + HEIGHT_SPACE ) ) )
        scrollView:addChild( item , 0 , _length )
        item:addTouchEventListener( onEvent )
        _length = _length + 1
     end

    scrollView:scrollToBottom( 0.01 , false )


end

local function setScrollViewItem(_Item, _obj)
    --cclog( "---------------------------->" )
    local image_lock = ccui.Helper:seekNodeByName( _Item , "image_lock" )
    if _obj.int[ "6" ] == 0 then
        image_lock:setVisible( false )
    else
        image_lock:setVisible( true )
    end
    local text_lv = ccui.Helper:seekNodeByName( _Item , "text_lv" )
    text_lv:setString( _obj.int[ "5" ] )
    local text_fire_name = ccui.Helper:seekNodeByName( _Item , "text_fire_name" )
    text_fire_name:setString( DictFightSoul[ tostring( _obj.int[ "3" ] ) ].name )
    local function onEvent( sender , eventType )
        if eventType == ccui.TouchEventType.ended then
            UISoulInfo.setInfo( 0 , _obj )
            UIManager.pushScene( "ui_soul_info" )
         --   cclog("id : ".._obj.int["1"])
        end
    end
    _Item:addTouchEventListener( onEvent )
    local image_frame_fire = ccui.Helper:seekNodeByName( _Item , "image_frame_fire" )
    utils.ShowFightSoulQuality( image_frame_fire , _obj.int[ "4" ] , 0 )
    utils.changeNameColor( text_fire_name , _obj.int[ "4" ] , dp.Quality.fightSoul , true )
    ActionManager.setSoulEffectAction( _obj.int[ "3" ] , image_frame_fire:getParent() )
    utils.addSoulParticle( image_frame_fire:getParent() , DictFightSoul[ tostring( _obj.int[ "3" ] )].effects , DictFightSoul[ tostring( _obj.int[ "3" ] )].fightSoulQualityId )
end

local function updateSrollItem( thingData , isFresh )
    local listItem = _item
    local listItemSize = listItem:getContentSize()
    local scrollViewSize = scrollView:getContentSize()
    local space = HEIGHT_SPACE
    local children = scrollView:getChildren()
    if #thingData <= 15 then
        for key , value in pairs( thingData ) do
            local child = children[ key ]
            child:setVisible( true )
            child:setAnchorPoint( cc.p( 0 , 1 ) )
            child:setPosition( cc.p( ( ( key - 1 ) % 5 ) * ( _item:getContentSize().width + HEIGHT_SPACE ) + 15 , scrollView:getInnerContainerSize().height - 5 - math.floor( ( key - 1 ) / 5 ) * ( _item:getContentSize().height + HEIGHT_SPACE ) ) )
           -- scrollView:addChild( child )
        end
        if #thingData > 0 then
            for i = #thingData , 25 do
                children[ i ]:setVisible( false )
            end
        else
            for i = 1 , 25 do
                children[ i ]:setVisible( false )
            end
        end
    else
        scrollView:setInnerContainerSize( cc.size( scrollView:getContentSize().width , math.floor( ( #thingData - 1 ) / 5 + 1 ) * ( _item:getContentSize().height + HEIGHT_SPACE) ) )
        local count = #thingData > 25 and 25 or #thingData
        for i = 1 , count do
            local child = children[ i ]
            child:setVisible( true )
            child:setAnchorPoint( cc.p( 0 , 1 ) )
            child:setPosition( cc.p( ( ( i - 1 ) % 5 ) * ( _item:getContentSize().width + HEIGHT_SPACE ) + 15 , scrollView:getInnerContainerSize().height - 5 - math.floor( ( i - 1 ) / 5 ) * ( _item:getContentSize().height + HEIGHT_SPACE ) ) )
         --   scrollView:addChild( child )
        end
        for i = count , 25 do
            children[ i ]:setVisible( false )
        end
    end

   -- scrollView:scrollToBottom( 0.01 , false )

    
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
        --cclog(" showTop : "..showTop .. " showBottom.."..showBottom)
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
                local child = children[i]
                if tag == #thingData and _tempSoulId and thingData[ tag ].int[ "3" ] == _tempSoulId then  
                    _tempSoulId = nil             
                       
                    local tempChild = _item:clone()      
                    tempChild:setAnchorPoint( cc.p( 0 , 1 ) )          
                    local text_lv = ccui.Helper:seekNodeByName( tempChild , "text_lv" )
                    text_lv:setString( thingData[tag].int[ "5" ] )
                    local text_fire_name = ccui.Helper:seekNodeByName( tempChild , "text_fire_name" )
                    text_fire_name:setString( DictFightSoul[ tostring( thingData[tag].int[ "3" ] ) ].name )
                    local image_frame_fire = ccui.Helper:seekNodeByName( tempChild , "image_frame_fire" )
                    utils.ShowFightSoulQuality( image_frame_fire , thingData[tag].int[ "4" ] , 0 )
                    utils.changeNameColor( text_fire_name , thingData[tag].int[ "4" ] , dp.Quality.fightSoul , true )
                    ActionManager.setSoulEffectAction( thingData[tag].int[ "3" ] , image_frame_fire:getParent() )
                    utils.addSoulParticle( image_frame_fire:getParent() , DictFightSoul[ tostring( thingData[tag].int[ "3" ] )].effects , DictFightSoul[ tostring( thingData[tag].int[ "3" ] )].fightSoulQualityId )

                    child:setVisible( false )
                    child:setPosition(child:getPositionX() , getPositionY( tag ))
                    child:setLocalZOrder(tag)
                    setScrollViewItem(child, thingData[tag])
                 
                    local di = ccui.Helper:seekNodeByName( UISoulGet.Widget , "image_base_di" )
                    local image_card = ccui.Helper:seekNodeByName( UISoulGet.Widget , "image_card".._tempIndex )
                    tempChild:setPosition( cc.p( image_card:getPositionX() - tempChild:getContentSize().width / 2 , image_card:getPositionY() + tempChild:getContentSize().height / 2 + image_card:getContentSize().height / 2 ) )
                    di:addChild( tempChild , 9998 )
                    tempChild:setVisible( false )
                    local function runMoveAction()
                        tempChild:setVisible( true )
                        tempChild:runAction( cc.Sequence:create( cc.MoveTo:create( 0.2 , cc.p( scrollView:getPositionX() + child:getPositionX() , scrollView:getPositionY() + child:getPositionY() ) ) , cc.CallFunc:create( function() tempChild:removeFromParent() child:setVisible( true ) _tempSoulId = nil local childs = UIManager.uiLayer:getChildren() for key, obj in pairs(childs) do obj:setEnabled(true) end end ) ) )
                    end
                    if DictFightSoul[ tostring( thingData[ tag ].int[ "3" ] ) ].fightSoulQualityId <= 2 then
                        utils.playArmature( 51 , "ui_anim51_2" , di , tempChild:getPositionX() + tempChild:getContentSize().width / 2 - UIManager.screenSize.width / 2 , tempChild:getPositionY() - tempChild:getContentSize().height / 2 - UIManager.screenSize.height / 2 , runMoveAction , nil , nil , nil , true )
                    else
                        utils.playArmature( 51 , "ui_anim51_1" , di , tempChild:getPositionX() + tempChild:getContentSize().width / 2 - UIManager.screenSize.width / 2 , tempChild:getPositionY() - tempChild:getContentSize().height / 2 - UIManager.screenSize.height / 2 , runMoveAction , nil , nil , nil , true )
                    end
                   
                elseif tag > #thingData then
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

    scrollView:addEventListener( function(sender, eventType)
        if eventType == ccui.ScrollviewEventType.scrolling then
            scrollingEvent()
        end
    end )
   -- scrollView:scrollToBottom( 0.01 , false )
    scrollView:jumpToBottom()
--    UISoulGet.Widget:runAction( cc.Sequence:create(cc.DelayTime:create(0.015),
--        cc.CallFunc:create( function() scrollingEvent( true ) end)) )
    scrollingEvent( true )
end

local function setImageCardInfo( index )
     local image = ccui.Helper:seekNodeByName( UISoulGet.Widget , "image_card"..index )
     utils.GrayWidget( image , false ) 
     utils.GrayWidget( image:getChildByName( "image_frame_card"..index ) , false ) 
     image_card_select[ index ] = 1
     
     if index == 4 then
         
        local btn_lighten = ccui.Helper:seekNodeByName( UISoulGet.Widget , "btn_lighten" )
        btn_lighten:setVisible( false )
     end
     local max = 1
     for i = 2 , 5 do
         if image_card_select[ i ] == 1 and max < i then
            max = i
         end
     end
     for i = 1 , 5 do
        local image1 = ccui.Helper:seekNodeByName( UISoulGet.Widget , "image_card"..i )
        if max == i then
            utils.addFrameParticle( image1 , true , 1.2 )
        else
            utils.addFrameParticle( image1 , false )
        end
     end
end

local function sendData1()
    local sendData = {
			header = StaticMsgRule.fightSoulOneKeyUpgrade,
			msgdata = {
				int = {
					
				}
			}
		}
    UIManager.showLoading()
    netSendPackage( sendData )
end

function showInfo(msg)
    local dialog = ccui.Layout:create()
    dialog:setContentSize(UIManager.screenSize)
    dialog:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
    dialog:setBackGroundColor(cc.c3b(0, 0, 0))
    dialog:setBackGroundColorOpacity(130)
    dialog:setTouchEnabled(true)
   -- dialog:retain()
    local bg_image = cc.Scale9Sprite:create("ui/dialog_bg.png")
    bg_image:setAnchorPoint(cc.p(0.5, 0.5))
    bg_image:setPreferredSize(cc.size(450, 420))
    bg_image:setPosition(cc.p(UIManager.screenSize.width / 2, UIManager.screenSize.height / 2))
    dialog:addChild(bg_image)
    local bgSize = bg_image:getPreferredSize()

    local title = ccui.Text:create()
    title:setString(Lang.ui_soul_get12)
    title:setFontName(dp.FONT)
    title:setFontSize(30)
    title:setTextColor(cc.c4b(255, 255, 0, 255))
    title:setPosition(cc.p(bgSize.width / 2, bgSize.height * 0.9))
    bg_image:addChild(title)

    for i = 1 , 10 do
        local msgLabel = ccui.Text:create()
        if i <= #msg then
            msgLabel:setString(DictFightSoul[ tostring( msg[i] ) ].name )
            utils.changeNameColor( msgLabel , DictFightSoul[ tostring( msg[i] ) ].fightSoulQualityId , dp.Quality.fightSoul , true )
        else
            msgLabel:setString(Lang.ui_soul_get13)
            msgLabel:setTextColor(cc.c4b(255, 255, 255, 255))
        end
        msgLabel:setFontName(dp.FONT)
        msgLabel:setTextAreaSize(cc.size(325, 200))
        msgLabel:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
        msgLabel:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
        msgLabel:setFontSize(23)
        msgLabel:setPosition(cc.p(bgSize.width / 2, bgSize.height * 0.85 - i * 32 ))
        bg_image:addChild(msgLabel)
        msgLabel:runAction(cc.Sequence:create( cc.DelayTime:create( 1.26 ) , cc.FadeOut:create( 0.5 ) ) )
    end
    bg_image:setScale(0.1)
    UIManager.uiLayer:addChild(dialog, 10000)
    bg_image:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1.1), cc.ScaleTo:create(0.06, 1) , cc.DelayTime:create( 1.0 ) , cc.FadeOut:create( 0.5 ) , cc.CallFunc:create( function ()
         dialog:removeFromParent()
    end) ))
end

local function netCallbackFunc(data)
  --  cclog( "header :"..data.header )
    if data.header == StaticMsgRule.huntFightSoul then
        _tempSoulId = data.msgdata.int[ "1" ]
        UISoulGet.setup()
    elseif data.header == StaticMsgRule.huntTenTimes then
        local count = data.msgdata.int[ "1" ]
--        if count < 10 then
--            UIManager.showToast( "由于银币不足，本次共猎魂"..count.."次" )
--        end
        local msgId = utils.stringSplit( data.msgdata.string[ "2" ] , ";" )
        showInfo( msgId )
    elseif data.header == StaticMsgRule.upgradeFightSoulId then
        local id = data.msgdata.int.id
        local isHaveDiFightSoul = data.msgdata.int.isHaveDiFightSoul
        if isHaveDiFightSoul == 1 then
            utils.showDialog( DictFightSoul[ tostring( id ) ].name..Lang.ui_soul_get14 , sendData1 )
        else
            sendData1()
        end
    end
end

local function netErrorCallbackFunc(data)
  --  cclog( "headerE :"..data.header )
    if data.header == StaticMsgRule.huntFightSoul then
    --    showNoEnoughDialog()
    elseif data.header == StaticMsgRule.huntTenTimes then
        local count = 0
        if net.InstPlayerFightSoul then
            for key ,value in pairs(net.InstPlayerFightSoul) do
                count = count + 1
            end
        end
        if count >= 200 then
        else
            --showNoEnoughDialog()
            --netSendDataGetNum()  zy 猎魂银币不足弹框
            UIManager.pushScene("ui_buy_slive")

        end
    end
end

local function sendData( type , index  )
    local sendData = nil
    if type == 0 then --猎魂
        local step = 0
--        if UIGuidePeople.guideStep then
--            cclog( "UIGuidePeople.guideStep : "..UIGuidePeople.guideStep )
--        end
        if UIGuidePeople.guideStep and UIGuidePeople.guideStep == guideInfo["45B2"].step then
            step = 1
        elseif UIGuidePeople.guideStep and UIGuidePeople.guideStep == guideInfo["45B3"].step then
            step = 2
        end
        sendData = {
			header = StaticMsgRule.huntFightSoul,
			msgdata = {
				int = {
					fightSouleHuntRuleId = index ,
                    guideStep = step
				}
			}
		}
        local childs = UIManager.uiLayer:getChildren() 
        for key, obj in pairs(childs) do 
            obj:setEnabled(true) 
        end
        _tempSoulId = -1
    elseif type == 1 then --猎10次
        sendData = {
			header = StaticMsgRule.huntTenTimes,
			msgdata = {
				int = {
					
				}
			}
		}
        _tempSoulId = nil
    elseif type == 2 then --出售银魂
        sendData = {
			header = StaticMsgRule.oneKeySell,
			msgdata = {
				int = {
					
				}
			}
		}
        _tempSoulId = nil
    elseif type == 3 then --一键吞噬
        sendData = {
			header = StaticMsgRule.fightSoulOneKeyUpgrade,
			msgdata = {
				int = {
					
				}
			}
		}
        _tempSoulId = nil
    elseif type == 4 then--获取吞噬升级的id
        sendData = {
			header = StaticMsgRule.upgradeFightSoulId,
			msgdata = {
				int = {
					
				}
			}
		}
        _tempSoulId = nil
    elseif type == 5 then--点亮第四个
        sendData = {
			header = StaticMsgRule.fightSoulLight,
			msgdata = {
				int = {
					fightSouleHuntRuleId = 4
				}
			}
		}
        _tempSoulId = nil
    end
    UIManager.showLoading()
	netSendPackage(sendData, netCallbackFunc,netErrorCallbackFunc,true)
end

function UISoulGet.init()
    scrollView = ccui.Helper:seekNodeByName( UISoulGet.Widget , "view_fire" )
    local image_base_title = ccui.Helper:seekNodeByName( UISoulGet.Widget , "image_base_title" )
    local btn_bag = image_base_title:getChildByName( "btn_bag" )
    local btn_sell = image_base_title:getChildByName( "btn_sell" )
    local image_base_tab = ccui.Helper:seekNodeByName( UISoulGet.Widget , "image_base_tab" )
    local _btn_get_ten = image_base_tab:getChildByName( "btn_get_ten" )
    local _btn_sell = image_base_tab:getChildByName( "btn_sell" )
    local _btn_onekey = image_base_tab:getChildByName( "btn_onekey" )
    local btn_expansion = ccui.Helper:seekNodeByName( UISoulGet.Widget , "btn_expansion" )
    local btn_help = ccui.Helper:seekNodeByName( UISoulGet.Widget , "btn_help")

    local btn_lighten = ccui.Helper:seekNodeByName( UISoulGet.Widget , "btn_lighten" )
    local text_gold_number = ccui.Helper:seekNodeByName( UISoulGet.Widget , "text_gold_number" )
    local image_card = {}
    image_card_select = { 1 , 0 , 0 , 0 , 0 }
    for i = 1 , 5 do
        local image = ccui.Helper:seekNodeByName( UISoulGet.Widget , "image_card"..i )
        image:setLocalZOrder( 9999 )
        table.insert( image_card , image )
    end

    local function onEndEvent( sender , eventType )
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_bag then
                UIManager.showWidget( "ui_soul_bag" )
            elseif sender == btn_sell then
                UISoulList.setType( UISoulList.type.SELL ) 
                UIManager.pushScene( "ui_soul_list" )
            elseif sender == _btn_get_ten then
--                local data = { 1 , 2 , 3 , 4 , 5 , 6 , 7 }
--                addItem( data )
                if net.InstPlayer.int["4"] < 32 then
                    UIManager.showToast( Lang.ui_soul_get15 )
                else
                    btn_lighten:setVisible( true )
                    sendData( 1 )
                end
                
            elseif sender == _btn_sell then--出售银魂
                sendData( 2 )
            elseif sender == _btn_onekey then--一键吞噬
                sendData( 4 )
            elseif sender == btn_expansion then
                UISoulInstall.setType( UISoulInstall.type.LINEUP, 0 )
                UIManager.pushScene( "ui_soul_install" )
            elseif sender == btn_help then
                UIAllianceHelp.show({titleName=Lang.ui_soul_get16,type=8})
            elseif sender == btn_lighten then --点亮第四个
                if image_card_select[ 4 ] == 1 then
                    UIManager.showToast( Lang.ui_soul_get17 )
                else
                   -- setImageCardInfo( 4 ) 
                   sendData( 5 )
                end
            end
            for i = 1 , 5 do
                if sender == image_card[ i ] then
                    if image_card_select[ i ] == 1 then
                       -- cclog( "猎魂了" )
                        if  not UIGuidePeople.guideStep and tonumber( net.InstPlayer.string["6"] ) < tonumber( DictFightSoulHuntRule[ tostring( i ) ].needSilver ) then
                            --UIManager.showToast( "银币不足" )
                            --showNoEnoughDialog()
                            --netSendDataGetNum()  zy 猎魂银币不足弹框
                            UIManager.pushScene("ui_buy_slive")
                        else
--                            if i ~= 1 then
--                                image_card_select[ i ] = 0
--                                utils.GrayWidget( image_card[ i ] , true ) 
--                                utils.GrayWidget( image_card[ i ]:getChildByName( "image_frame_card"..i ) , true ) 
--                            end
                            _tempIndex = i
                            if i == 4 then
                                btn_lighten:setVisible( true )
                              
                            end
                            sendData( 0 , i )
                        end
--                        local data = { 1 }
--                        addItem( data )
                    else
                        UIManager.showToast( Lang.ui_soul_get18 )
                    end
                end
            end
        end
    end
    btn_bag:setPressedActionEnabled( true )
	btn_bag:addTouchEventListener( onEndEvent )
    btn_sell:setPressedActionEnabled( true )
    btn_sell:addTouchEventListener( onEndEvent )
    _btn_get_ten:setPressedActionEnabled( true )
    _btn_get_ten:addTouchEventListener( onEndEvent )
    _btn_sell:setPressedActionEnabled( true )
    _btn_sell:addTouchEventListener( onEndEvent )
    _btn_onekey:setPressedActionEnabled( true )
    _btn_onekey:addTouchEventListener( onEndEvent )
    btn_expansion:setPressedActionEnabled( true )
    btn_expansion:addTouchEventListener( onEndEvent )
    btn_help:setPressedActionEnabled( true )
    btn_help:addTouchEventListener( onEndEvent )

    _item = scrollView:getChildByName( "panel_all" )
    ccui.Helper:seekNodeByName( _item , "image_lock" ):setVisible( false )
    _item:retain()
    scrollView:removeAllChildren()
    for i = 1 , 25 do
        local child = _item:clone()
        child:setAnchorPoint( cc.p( 0 , 1 ) )
        child:setPosition( cc.p( ( ( i - 1 ) % 5 ) * ( _item:getContentSize().width + HEIGHT_SPACE ) + 15 , scrollView:getInnerContainerSize().height - 5 - math.floor( ( i - 1 ) / 5 ) * ( _item:getContentSize().height + HEIGHT_SPACE ) ) )
        scrollView:addChild( child )
    end
    _scrollViewHeight = scrollView:getInnerContainerSize().height


    
    btn_lighten:setLocalZOrder( 10001 )

    btn_lighten:setPressedActionEnabled( true )
    btn_lighten:addTouchEventListener( onEndEvent )
    utils.addFrameParticle( image_card[ 1 ] , true , 1.2 )
    for i = 2 , 5 do
       utils.GrayWidget( image_card[ i ] , true ) 
       utils.GrayWidget( image_card[ i ]:getChildByName( "image_frame_card"..i ) , true ) 
       utils.addFrameParticle( image_card[ i ] , false )
    end
    for i= 1 , 5 do
        image_card[ i ]:addTouchEventListener( onEndEvent )
        local text_silver_cost = ccui.Helper:seekNodeByName( image_card[ i ] , "text_silver_cost" )
        text_silver_cost:setString( DictFightSoulHuntRule[ tostring( i ) ].needSilver )
    end
    local text_gold_cost = ccui.Helper:seekNodeByName( btn_lighten , "text_gold_cost" )
    text_gold_cost:setString( DictFightSoulHuntRule[ tostring( 4 ) ].needGold )
end

function UISoulGet.setup()
    if _tempSoulId and _tempSoulId == -1 then
        return 
    end
    image_card_select = { 1 , 0 , 0 , 0 , 0 }
    local label_fight = ccui.Helper:seekNodeByName( UISoulGet.Widget , "label_fight" )
    label_fight:setString( tostring(utils.getFightValue()) )
    local text_gold_number = ccui.Helper:seekNodeByName( UISoulGet.Widget , "text_gold_number" )
    text_gold_number:setString( tostring(net.InstPlayer.int["5"]) )
    local text_silver_number = ccui.Helper:seekNodeByName( UISoulGet.Widget , "text_silver_number" )
    text_silver_number:setString( net.InstPlayer.string["6"] )

    
    _length = 0
   -- scrollView:removeAllChildren()
    scrollView:setInnerContainerSize( cc.size( scrollView:getInnerContainerSize().width , _scrollViewHeight ) )

    _soulData = {}
    if net.InstPlayerFightSoul then
        for key , value in pairs ( net.InstPlayerFightSoul ) do
            if value.int[ "7" ] == 0 then
                table.insert( _soulData , value )
            end 
        end
    end
    utils.quickSort( _soulData , function ( obj1 , obj2 )
        if obj1.int[ "1" ] > obj2.int[ "1" ] then
            return true
        else
            return false
        end
    end)
  --  addItem( _soulData )
   updateSrollItem( _soulData )

    if net.InstPlayerFightSoulHuntRule then
        for key , value in pairs ( net.InstPlayerFightSoulHuntRule ) do
            setImageCardInfo( value.int[ "3" ] )
        end
    end
    UIGuidePeople.isGuide(nil,UISoulGet)
end

function UISoulGet.freshImageCare()
    for i = 2 , 5 do
         local image = ccui.Helper:seekNodeByName( UISoulGet.Widget , "image_card"..i )
         utils.GrayWidget( image , true ) 
         utils.GrayWidget( image:getChildByName( "image_frame_card"..i ) , true ) 
         image_card_select[ i ] = 0
         utils.addFrameParticle( image , false )
    end
    if net.InstPlayerFightSoulHuntRule then
       
            local image = ccui.Helper:seekNodeByName( UISoulGet.Widget , "image_card"..1 )
            utils.addFrameParticle( image , true , 1.2 )

            for key , value in pairs ( net.InstPlayerFightSoulHuntRule ) do
                setImageCardInfo( value.int[ "3" ] )
            end

    else
        local image = ccui.Helper:seekNodeByName( UISoulGet.Widget , "image_card"..1 )
        utils.addFrameParticle( image , true , 1.2 )
    end
end

function UISoulGet.free()
    _length = 0
    image_card_select = nil
    _tempSoulId = nil
    _tempIndex = nil
    _soulData = nil
end
