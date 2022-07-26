require"Lang"
UITowerStrong = {}
local _thingId = nil
local _things = nil
local _needGold = nil
local _donateThings = nil
function refresh()
    if _things then
        for key ,value in pairs ( _things ) do
            local image = ccui.Helper:seekNodeByName( UITowerStrong.Widget , "image_frame_good"..key )
            local _thingData = utils.getItemProp( value )
            image:loadTexture( _thingData.frameIcon )
            image:getChildByName( "image_good" ):loadTexture( _thingData.smallIcon )
            image:getChildByName( "text_name" ):setString( _thingData.name )
            utils.addFrameParticle( image:getChildByName( "image_good" ) , true )
           -- utils.showThingsInfo( image , _thingData.tableTypeId , _thingData.tableFieldId )
            local function showInfo()
                local dictEquipData = DictEquipment[tostring(_thingData.tableFieldId)]
                local suitEquipData = utils.getEquipSuit(tostring( _thingData.tableFieldId ) )
                if dictEquipData.equipQualityId >= 3 and suitEquipData then
                    UIEquipmentNew.setDictEquipId(_thingData.tableFieldId)
                    UIManager.pushScene("ui_equipment_new")
                else
                    UIEquipmentInfo.setDictEquipId(_thingData.tableFieldId)
	                UIManager.pushScene("ui_equipment_info")
                end
            end
            local function btnTouchEvent(sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    showInfo()
                end
            end
            image:setTouchEnabled(true)
            image:addTouchEventListener(btnTouchEvent)
        end
        ccui.Helper:seekNodeByName( UITowerStrong.Widget , "label_price" ):setString( tostring( _needGold ) )
        local btn_challenge = ccui.Helper:seekNodeByName( UITowerStrong.Widget , "btn_challenge" )
        if net.InstPlayer.int[ "5" ] >= _needGold then
            btn_challenge:setTitleText( Lang.ui_tower_strong1 )
        else
            btn_challenge:setTitleText( Lang.ui_tower_strong2 )
        end
    --    cclog( "_donateThings:" .. _donateThings )
        local _thingData1 = utils.getItemProp( _donateThings )
        local image_send = ccui.Helper:seekNodeByName( UITowerStrong.Widget , "image_send" )
        image_send:getChildByName( "image_good" ):loadTexture( _thingData1.smallIcon )
        image_send:getChildByName( "text_name" ):setString( _thingData1.name )

    end
end
local function netCallBack( data )
    if data.header == StaticMsgRule.sendStrongEquip then
        _thingId = data.msgdata.int.id 
        _things = utils.stringSplit( data.msgdata.string.things , ";")
        _needGold = data.msgdata.int.needGold
        _donateThings = data.msgdata.string.donateThings
        refresh()
    elseif data.header == StaticMsgRule.buyStrongEquip then
        UIManager.popScene()
        UIManager.flushWidget( UITowerTest )
    end
end
local function sendData( type )
    local sendData = {}
    if type == 0 then
        sendData = {
            header = StaticMsgRule.sendStrongEquip
        }
    elseif type == 1 then
        sendData = {
            header = StaticMsgRule.buyStrongEquip ,
            msgdata = {
                int = {
                    strongerEquipId = _thingId
                }
            }

        }
    end
    netSendPackage( sendData , netCallBack )
end
local function goldCallBack( pack )
   -- UIManager.flushWidget( UITowerTest )
end
function UITowerStrong.init()
    local btn_close = ccui.Helper:seekNodeByName( UITowerStrong.Widget , "btn_close" )
    local btn_challenge = ccui.Helper:seekNodeByName( UITowerStrong.Widget , "btn_challenge" )
    local btn_no = ccui.Helper:seekNodeByName( UITowerStrong.Widget , "btn_no")
    local function onEvent( sender , eventType )
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_close or sender == btn_no then
                UIManager.popScene()
                UITowerTest._isStrong = 2
                cc.UserDefault:getInstance():setIntegerForKey( "isStrong", UITowerTest._isStrong )
            elseif sender == btn_challenge then
                if net.InstPlayer.int[ "5" ] >= _needGold then
                    sendData( 1 )
                else
                    utils.checkGOLD( 1 )
                end
            end
        end
    end
    btn_close:setPressedActionEnabled( true )
    btn_close:addTouchEventListener( onEvent )
    btn_challenge:setPressedActionEnabled( true )
    btn_challenge:addTouchEventListener( onEvent )
    btn_no:setPressedActionEnabled( true )
    btn_no:addTouchEventListener( onEvent )
end
function UITowerStrong.setup()
    sendData( 0 )
end
function UITowerStrong.free()
    _thingId = nil
    _things = nil
    _needGold = nil
    _donateThings = nil
end
