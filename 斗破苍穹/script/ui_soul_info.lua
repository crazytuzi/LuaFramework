require"Lang"
UISoulInfo = {}

local _type = nil
local _obj = nil
local _cardId = nil
local function netCallBack( data )
    if _type and _type == 1 then
      --  UIManager.flushWidget( UISoulInstall )
        UISoulInstall.refreshPageView()
        UIManager.flushWidget( UILineup )
    end
    UIManager.popScene()
end

local function sendData( type )
    local sendData = {} ;
    if type == 0 then--锁定
        sendData = {
            header = StaticMsgRule.lockFightSoul ,
            msgdata  = {
                int = {
                    instPlayerFightSoulId = _obj.int[ "1" ]
                }
            }
        }
    elseif type == 1 then
        sendData = {
            header = StaticMsgRule.unLockFightSoul ,
            msgdata  = {
                int = {
                    instPlayerFightSoulId = _obj.int[ "1" ]
                }
            }
       }
    elseif type == 2 then
        sendData = {
            header = StaticMsgRule.dropFightSoul ,
            msgdata  = {
                int = {
                    instPlayerCardId = _obj.int[ "7" ] ,
                    position = _obj.int[ "8" ]
                }
            }
       }
    end
    UIManager.showLoading()
    netSendPackage( sendData , netCallBack )
end

function UISoulInfo.init()
	local btn_close = ccui.Helper:seekNodeByName( UISoulInfo.Widget , "btn_close" )
    local btn_update = ccui.Helper:seekNodeByName( UISoulInfo.Widget , "btn_update" )
    local btn_change = ccui.Helper:seekNodeByName( UISoulInfo.Widget , "btn_change" )
    local btn_lock = ccui.Helper:seekNodeByName( UISoulInfo.Widget , "btn_lock" )
    local function onEvent( sender , eventType )
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_close then
                UIManager.popScene()
            elseif sender == btn_update then
                UIManager.popScene()
                UISoulUpgrade.setInfo( _obj )
                UIManager.pushScene( "ui_soul_upgrade" )
            elseif sender == btn_change then
                if _cardId then
                    UIManager.popScene()
                    UISoulList.setType( UISoulList.type.EQUIP , _cardId )
                    UIManager.pushScene( "ui_soul_list" )
                end
            elseif sender == btn_lock then
                if _type == 0 then
                    if _obj.int[ "6" ] == 0 then
                        sendData( 0 )
                    else
                        sendData( 1 )
                    end
                elseif _type == 1 then
                    sendData( 2 )
                end
            end
        end
    end
    btn_close:setPressedActionEnabled( true )
    btn_close:addTouchEventListener( onEvent )
    btn_update:setPressedActionEnabled( true )
    btn_update:addTouchEventListener( onEvent )
    btn_change:setPressedActionEnabled( true )
    btn_change:addTouchEventListener( onEvent )
    btn_lock:setPressedActionEnabled( true )
    btn_lock:addTouchEventListener( onEvent )
end

function UISoulInfo.setInfo( type , obj , cardData )
    _obj = obj 
    _type = type
    _cardId = cardData
end

function UISoulInfo.setup()
    local btn_lock = ccui.Helper:seekNodeByName( UISoulInfo.Widget , "btn_lock" )
    local btn_update = ccui.Helper:seekNodeByName( UISoulInfo.Widget , "btn_update" )
    if _type and _type == 0 then
         local btn_change = ccui.Helper:seekNodeByName( UISoulInfo.Widget , "btn_change" ) 
         btn_change:setVisible( false )
         btn_lock:setPosition( btn_change:getPosition() )
         if _obj.int[ "6" ] == 0 then
            btn_lock:setTitleText(Lang.ui_soul_info1)
        else
            btn_lock:setTitleText(Lang.ui_soul_info2)
        end
    end
    
    if _type and _type == 1 then
        btn_lock:setTitleText( Lang.ui_soul_info3 )
    end
    local text_chip_name = ccui.Helper:seekNodeByName( UISoulInfo.Widget , "text_chip_name" )
    text_chip_name:setString( DictFightSoul[ tostring( _obj.int[ "3" ] ) ].name )
    local text_number = ccui.Helper:seekNodeByName( UISoulInfo.Widget , "text_number" )
    text_number:setString( "LV.".._obj.int[ "5" ] )
    local text_quality = ccui.Helper:seekNodeByName( UISoulInfo.Widget , "text_quality" )
    text_quality:setString( DictFightSoulQuality[ tostring( _obj.int[ "4" ] ) ].name )
    local text_describe = ccui.Helper:seekNodeByName( UISoulInfo.Widget , "text_describe" )
    local proType , proValue , sellSilver = utils.getSoulPro( _obj.int[ "3" ] , _obj.int[ "5" ] )
    if _obj.int[ "4" ] == 5 then
        text_describe:setString( Lang.ui_soul_info4..sellSilver..Lang.ui_soul_info5 )
        btn_lock:setVisible( false )
        btn_update:setVisible( false )
    elseif _obj.int[ "4" ] == 4 and DictFightSoul[ tostring( _obj.int[ "3" ] ) ].isExpFightSoul == 1 then
        text_describe:setString( Lang.ui_soul_info6..DictFightSoul[ tostring( _obj.int[ "3" ] ) ].initExp..Lang.ui_soul_info7)
        btn_lock:setVisible( false )
        btn_update:setVisible( false )
    else
        btn_lock:setVisible( true )
        btn_update:setVisible( true )
        if proValue < 1 then
            text_describe:setString( DictFightProp[tostring( proType )].name.."+"..( proValue * 100 ).."%" )
        else
            text_describe:setString( DictFightProp[tostring( proType )].name.."+"..proValue )
        end
    end
    local image_frame_soul = ccui.Helper:seekNodeByName( UISoulInfo.Widget , "image_frame_soul" )
    utils.ShowFightSoulQuality( image_frame_soul , _obj.int[ "4" ] , 1 )
    utils.changeNameColor( text_chip_name , _obj.int[ "4" ] , dp.Quality.fightSoul )
    ActionManager.setSoulEffectAction( _obj.int[ "3" ] , image_frame_soul:getChildByName( "image_soul" ) )
    utils.addSoulParticle( image_frame_soul:getChildByName( "image_soul" ) , DictFightSoul[ tostring( _obj.int[ "3" ] )].effects , DictFightSoul[ tostring( _obj.int[ "3" ] )].fightSoulQualityId )
end

function UISoulInfo.free()
    _type = nil
    _obj = nil
    _cardId = nil
end
