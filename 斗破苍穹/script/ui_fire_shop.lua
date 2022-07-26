require"Lang"
UIFireShop = {}
local _dataThings = nil
local _scrollView = nil
local _item = nil
local DEBUG = false 
local _currFireScore = nil
local _curFloor = nil
local function getInstPlayerYFire(_fireId)
    local curC = 0 
    local maxC = 0
    if net.InstPlayerYFire then
        for key, obj in pairs(net.InstPlayerYFire) do
            if obj.int["3"] == _fireId then
                curC = obj.int[ "9" ]
                break
            end
        end
    end
    for key ,obj in pairs( DictYFire ) do
        if obj.id == _fireId then
            maxC = obj.chipMax
            break
        end
    end
    return curC , maxC
end
local function setViewItem( item , data )
    local things = utils.stringSplit( data , "|" )
    local btn_lineup = item:getChildByName( "btn_lineup" )
    local function onEvent( sender , eventType )
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_lineup then
                UIManager.showLoading()
                netSendPackage( { header = StaticMsgRule.fireFamStoreExchange , msgdata = { int  = { fireFamStoreId = tonumber( things[ 1 ] ) } } } , function ( pack )
                    UIFireShop.setup()
                    --things[ 2 ]
                    utils.showGetThings( things[ 2 ] )
                end)
            end
        end
    end
    btn_lineup:setPressedActionEnabled( true )
    btn_lineup:addTouchEventListener( onEvent )
    
    local dictData = utils.getItemProp( things[ 2 ] )
    local image_frame_chip = item:getChildByName( "image_frame_chip" )
    utils.showThingsInfo( image_frame_chip , dictData.tableTypeId , dictData.tableFieldId )
    utils.addBorderImage( dictData.tableTypeId , dictData.tableFieldId , image_frame_chip )
    image_frame_chip:getChildByName( "image_chip" ):loadTexture( dictData.smallIcon )
    image_frame_chip:getChildByName( "text_number" ):setString( dictData.count )
    image_frame_chip:getChildByName( "image_sui" ):setVisible( false )
    item:getChildByName( "text_chip_name" ):setString( dictData.name )
    item:getChildByName( "text_hint" ):setString( Lang.ui_fire_shop1 .. things[ 5 ] .. Lang.ui_fire_shop2 )
    item:getChildByName( "text_hint_0" ):setString( Lang.ui_fire_shop3 .. things[ 6 ] .. Lang.ui_fire_shop4 )
    local image_fire = item:getChildByName( "image_fire" )
    image_fire:getChildByName( "text_number" ):setString( things[ 4 ] ) 
    local mType = tonumber( things[ 3 ] )
    if mType == 1 then
        image_fire:loadTexture( "ui/fire_points.png" )
        image_fire:getChildByName( "text_name" ):setString( Lang.ui_fire_shop5 ) 

    elseif mType == 2 then
        image_fire:loadTexture( "ui/fire_stone.png" )
        image_fire:getChildByName( "text_name" ):setString( Lang.ui_fire_shop6 ) 
    end
    local text_number = item:getChildByName( "text_number" )
    if dictData.tableTypeId == StaticTableType.DictYFireChip then
        text_number:setVisible( true )
        local cur , all = getInstPlayerYFire( dictData.tableFieldId )
        text_number:setString( "(" .. cur .. "/" .. all .. ")" )
    else
        text_number:setVisible( false )
    end
    if tonumber( things[ 6 ] ) == 0 then
        btn_lineup:setBright( false )
        btn_lineup:setTouchEnabled( false )
    elseif _curFloor and _curFloor < tonumber( things[ 5 ] ) then
        btn_lineup:setBright( false )
        btn_lineup:setTouchEnabled( false )
    else
        btn_lineup:setBright( true )
        btn_lineup:setTouchEnabled( true )
    end
end
local function callBack( pack )
    _currFireScore = pack.msgdata.int[ "1" ]
    _curFloor = pack.msgdata.int[ "3" ]
    local thing = pack.msgdata.string[ "2" ]
    _dataThings = utils.stringSplit( thing , "/" )
    utils.updateScrollView( UIFireShop , _scrollView , _item , _dataThings , setViewItem )
    local image_fire_points = ccui.Helper:seekNodeByName( UIFireShop.Widget , "image_fire_points" )
    image_fire_points:getChildByName( "text_number" ):setString( _currFireScore )
    local stoneCount = utils.getThingCount( StaticThing.fireStone )
    local image_fire_stone = ccui.Helper:seekNodeByName( UIFireShop.Widget , "image_fire_stone" )
    image_fire_stone:getChildByName( "text_number" ):setString( stoneCount )
end
local function netSendData()
    if DEBUG then
        callBack()
        return
    end
    UIManager.showLoading()
    local sendData = {}
    sendData = {
        header = StaticMsgRule.clickFireFamStore ,
        msgdata = {}
    }
    netSendPackage( sendData , callBack )
end
function UIFireShop.init()
    local btn_close = ccui.Helper:seekNodeByName( UIFireShop.Widget , "btn_close" )
    local function onEvent( sender , eventType )
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_close then
                UIManager.popScene()
            end
        end
    end
    btn_close:setPressedActionEnabled( true )
    btn_close:addTouchEventListener( onEvent )
    _scrollView = ccui.Helper:seekNodeByName( UIFireShop.Widget , "view_award_lv" )
    _item = _scrollView:getChildByName( "image_base_good" )
    _item:retain()
end
function UIFireShop.setup()
    netSendData()
end
function UIFireShop.free()
    _dataThings = nil
    _currFireScore = nil
    _curFloor = nil
end
