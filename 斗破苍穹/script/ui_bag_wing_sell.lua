require"Lang"
UIBagWingSell={}
local _item = nil
local _item1 = nil
local _item2 = nil
local scrollView = nil
local _objThing = nil
local _type = nil
local _cardData = nil
UIBagWingSell.type = {
    SELL = 1 ,
    SELL_PIECE = 2 ,
    EQUIP = 3 ,
    CHANGE = 4
}
local _selectedIndex = nil
local _sellPrice = nil
local function netCallBack( data )
    if data.header == StaticMsgRule.wingSell then
        UIManager.showToast( Lang.ui_bag_wing_sell1.._sellPrice )
        UIManager.flushWidget( UIBagWing )
    elseif data.header == StaticMsgRule.wingPutOnOrExchanger then
        UIManager.flushWidget( UIWingInfo )
        UIManager.popScene()
        utils.playArmature(  41 , "ui_anim41_2" , UIManager.gameLayer , 0 , 150 , false , false , false , 1.2  )  
        UIManager.flushWidget( UILineup )
    end
    UIManager.flushWidget( UIBagWingSell )   
end
local _selectedId = nil
local function sendData( type , obj )
    local sendData = {}
    if type == 1 then
        sendData = {
            header = StaticMsgRule.wingSell ,
            msgdata = {
                string = {
                    instPlayerWingIdList = table.concat( _selectedIndex , ";" )
                }
            }
        }
    elseif type == 2 then
    --    cclog("instId :".._cardData.instId)
        sendData = {
            header = StaticMsgRule.wingPutOnOrExchanger ,
            msgdata = {
                int = {
                    instPlayerWingId = obj.int["1"] ,
                    instPlayerCardId = _cardData.instId
                }
            }
        }
    end
    netSendPackage( sendData , netCallBack )
end
local function setScrollViewItem( item , obj )
    if _type == UIBagWingSell.type.SELL then       
        local text_choose_number = ccui.Helper:seekNodeByName( UIBagWingSell.Widget , "text_choose_number" )
        local text_sell_number = ccui.Helper:seekNodeByName( UIBagWingSell.Widget , "text_sell_number" )
        local image_di = ccui.Helper:seekNodeByName( item , "image_di" )
        local strengthenData , advanceData , proShow = utils.getWingInfo( obj.int["3"] , obj.int["4"] , obj.int["5"] , image_di )
        local function onSelectEvent( sender , eventType )
            if eventType == ccui.CheckBoxEventType.selected then
                table.insert( _selectedIndex , obj.int["1"] )
                _sellPrice = _sellPrice + advanceData.sellSilver --加入价格
            elseif eventType == ccui.CheckBoxEventType.unselected then
                for key , value in pairs( _selectedIndex ) do
                    if value == obj.int["1"] then--此处比较id
                        table.remove( _selectedIndex , key )
                        _sellPrice = _sellPrice - advanceData.sellSilver --加入价格
                        break
                    end
                end
            end
            text_choose_number:setString( Lang.ui_bag_wing_sell2..#_selectedIndex )
            text_sell_number:setString( Lang.ui_bag_wing_sell3.._sellPrice )
        end     
        local box_sell = ccui.Helper:seekNodeByName( item , "box_sell" )
        box_sell:setSelected( false )
        box_sell:addEventListener( onSelectEvent )
        if _selectedIndex then
            for key ,value in pairs( _selectedIndex ) do
                if value == obj.int["1"] then
                    box_sell:setSelected( true )
                end
            end
        end
        local image_frame_wing = ccui.Helper:seekNodeByName( item , "image_frame_wing" )
        local image_wing = image_frame_wing:getChildByName( "image_wing" )
        local text_name_wing = ccui.Helper:seekNodeByName( item , "text_name_wing" )
        local text_lv_wing = image_frame_wing:getChildByName("text_lv_wing")
        text_name_wing:setString( DictWing[ tostring( obj.int["3"] ) ].name )
        text_lv_wing:setString("LV." .. obj.int["4"])

        local text_lv = ccui.Helper:seekNodeByName( item , "text_lv" )
        if obj.int["5"] == 1 then
            text_lv:setString( Lang.ui_bag_wing_sell4 )
        elseif obj.int["5"] == 2 then
            text_lv:setString( Lang.ui_bag_wing_sell5 )
        elseif obj.int["5"] == 3 then
            text_lv:setString( Lang.ui_bag_wing_sell6 )
        end

        local text_price = ccui.Helper:seekNodeByName( item , "text_price" )

        local smallImage= DictUI[tostring(advanceData.smallUiId)].fileName
        image_wing:loadTexture( "image/"..smallImage )

        text_price:setString( advanceData.sellSilver )

    elseif _type == UIBagWingSell.type.SELL_PIECE then
        local tableFieldId = obj.int["3"]
        local name_text=DictThing[tostring(tableFieldId)].name
        local smallUiId = DictThing[tostring(tableFieldId)].smallUiId
        local smallImage= DictUI[tostring(smallUiId)].fileName
        local description_text =DictThing[tostring(tableFieldId)].description

        local btn_lineup = ccui.Helper:seekNodeByName( item , "btn_lineup" )
        local function onEventPiece( sender , eventType )
            if eventType == ccui.TouchEventType.ended then
                if sender == btn_lineup then
                    UISellProp.setData(obj,UIBagWingSell)
                    UIManager.pushScene( "ui_sell_prop" )
                end
            end
        end
        btn_lineup:setPressedActionEnabled( true )
        btn_lineup:addTouchEventListener( onEventPiece )

        local image_frame_chip = ccui.Helper:seekNodeByName( item , "image_frame_chip" )
        utils.addBorderImage( obj.int["6"] , obj.int["3"] , image_frame_chip )
        local image_chip = image_frame_chip:getChildByName( "image_chip" )
        image_chip:loadTexture( "image/"..smallImage )
        local text_chip_name = ccui.Helper:seekNodeByName( item , "text_chip_name" )
        text_chip_name:setString( name_text )
        local text_number = ccui.Helper:seekNodeByName( item , "text_number" )
        text_number:setString( obj.int["5"] )
        local text_describe = ccui.Helper:seekNodeByName( item , "text_describe" )
        text_describe:setString(description_text)
        local text_price = ccui.Helper:seekNodeByName( item , "text_price" )
        text_price:setString( DictThing[tostring(tableFieldId)].sellCopper )
    elseif _type == UIBagWingSell.type.EQUIP or _type == UIBagWingSell.type.CHANGE then
        local image_di = ccui.Helper:seekNodeByName( item , "image_di" )
        local strengthenData , advanceData , proShow = utils.getWingInfo( obj.int["3"] , obj.int["4"] , obj.int["5"] , image_di )
        local btn_change = ccui.Helper:seekNodeByName( item , "btn_change" )
        local function onEventEquip( sender , eventType )
            if eventType == ccui.TouchEventType.ended then
                if sender == btn_change then
                    sendData( 2 , obj )
                end
            end
        end
        btn_change:setPressedActionEnabled( true )
        btn_change:addTouchEventListener( onEventEquip )

        local image_frame_wing = ccui.Helper:seekNodeByName( item , "image_frame_wing" )
        local image_wing = image_frame_wing:getChildByName( "image_wing" )
        local text_name_wing = ccui.Helper:seekNodeByName( item , "text_name_wing" )
        local text_lv_wing = image_frame_wing:getChildByName("text_lv_wing")
        text_name_wing:setString( DictWing[ tostring( obj.int["3"] ) ].name )
        text_lv_wing:setString("LV." .. obj.int["4"])
        local text_lv = ccui.Helper:seekNodeByName( item , "text_lv" )
        if obj.int["5"] == 1 then
            text_lv:setString( Lang.ui_bag_wing_sell7 )
        elseif obj.int["5"] == 2 then
            text_lv:setString( Lang.ui_bag_wing_sell8 )
        elseif obj.int["5"] == 3 then
            text_lv:setString( Lang.ui_bag_wing_sell9 )
        end
        local smallImage= DictUI[tostring(advanceData.smallUiId)].fileName
        image_wing:loadTexture( "image/"..smallImage )
    end
end
function UIBagWingSell.init()
    local btn_close = ccui.Helper:seekNodeByName( UIBagWingSell.Widget , "btn_close" )
    local btn_sell = ccui.Helper:seekNodeByName( UIBagWingSell.Widget , "btn_sell" )
    local function onEvent( sender , eventType )
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_close then
                UIManager.popScene()
            elseif sender == btn_sell then
                if #_selectedIndex > 0 then
                    sendData( 1 )
                else
                    UIManager.showToast( Lang.ui_bag_wing_sell10 )
                end
            end
        end
    end
    btn_close:setPressedActionEnabled( true )
    btn_close:addTouchEventListener( onEvent )
    btn_sell:setPressedActionEnabled( true )
    btn_sell:addTouchEventListener( onEvent )

    scrollView = ccui.Helper:seekNodeByName( UIBagWingSell.Widget , "view_wing" )
    _item = scrollView:getChildByName("image_base_wing")
    _item:retain() 
    _item1 = scrollView:getChildByName("image_base_choose")
    _item1:retain() 
    _item2 = scrollView:getChildByName("image_base_chip")
    _item2:retain() 
end
function UIBagWingSell.setup()
    local text_choose_number = ccui.Helper:seekNodeByName( UIBagWingSell.Widget , "text_choose_number" )
    local text_sell_number = ccui.Helper:seekNodeByName( UIBagWingSell.Widget , "text_sell_number" )
    local btn_sell = ccui.Helper:seekNodeByName( UIBagWingSell.Widget , "btn_sell" )
    local text_title = ccui.Helper:seekNodeByName( UIBagWingSell.Widget , "text_title" )
    _objThing = {}
    local item = nil
    if _type == UIBagWingSell.type.SELL then
        if net.InstPlayerWing then
            for key ,value in pairs ( net.InstPlayerWing ) do
                if value.int["6"] == 0 then
                    table.insert( _objThing , value )
                end
            end
        end
        utils.quickSort( _objThing , function ( obj1 , obj2 )
            if obj1.int["5"] < obj2.int["5"] then
                return false
            elseif obj1.int["5"] > obj2.int["5"] then
                return true
            elseif obj1.int["4"] > obj2.int["4"] then
                return true
            else
                return false
            end
        end)
        item = _item
        _selectedIndex = {}
        _sellPrice = 0
        text_choose_number:setString( Lang.ui_bag_wing_sell11..#_selectedIndex )
        text_sell_number:setString( Lang.ui_bag_wing_sell12.._sellPrice )
    elseif _type == UIBagWingSell.type.SELL_PIECE then
        for key, obj in pairs(net.InstPlayerThing) do
            if obj.int["7"] == StaticBag_Type.wing then 
                 table.insert(_objThing,obj)
            end
        end
        utils.quickSort( _objThing , function ( obj1 , obj2 )
            if obj1.int["3"] > obj2.int["3"] then
                return true
            else
                return false
            end
        end)
        item = _item2
        text_choose_number:setVisible( false )
        text_sell_number:setVisible( false )
        btn_sell:setVisible( false )
    elseif _type == UIBagWingSell.type.EQUIP or _type == UIBagWingSell.type.CHANGE then
        if net.InstPlayerWing then
            for key ,value in pairs ( net.InstPlayerWing ) do
                if value.int["6"] == 0 then
                    table.insert( _objThing , value )
                end
            end
        end
        utils.quickSort( _objThing , function ( obj1 , obj2 )
            if obj1.int["5"] < obj2.int["5"] then
                return true
            elseif obj1.int["5"] > obj2.int["5"] then
                return false
            elseif obj1.int["4"] < obj2.int["4"] then
                return true
            else
                return false
            end
        end)
        item = _item1
        text_choose_number:setVisible( false )
        text_sell_number:setVisible( false )
        btn_sell:setVisible( false )
        text_title:setString(Lang.ui_bag_wing_sell13)
    end
    scrollView:removeAllChildren()
    utils.updateScrollView( UIBagWingSell , scrollView , item , _objThing , setScrollViewItem )
end
function UIBagWingSell.free()
    _objThing = nil
    _type = nil
    _selectedIndex = nil
    _sellPrice = nil
    _cardData = nil
end
function UIBagWingSell.setType( typeD , data )
    _type = typeD
    _cardData = data
end
