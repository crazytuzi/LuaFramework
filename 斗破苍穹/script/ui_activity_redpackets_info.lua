require"Lang"
UIActivityRedpacketsInfo = {}
local _name = nil
local _number = nil
local _animation = nil
local _gold = nil
local _isOpenning = nil
 local function onMovementEvent(armature, movementType, movementID)
    if movementType == ccs.MovementEventType.complete or movementType == ccs.MovementEventType.loopComplete then
        armature:getAnimation():stop()
        armature:setVisible( false )
        local image_red = ccui.Helper:seekNodeByName( UIActivityRedpacketsInfo.Widget , "image_red" )
        image_red:setOpacity( 255 )
        image_red:loadTexture( "ui/red_open.png" ) --red_big.png
        local image_frame_good = ccui.Helper:seekNodeByName( UIActivityRedpacketsInfo.Widget , "image_frame_good" )
        local image_good = image_frame_good:getChildByName( "image_good" )
        local goodsData = utils.getItemProp( "3_1_".._gold )
        image_good:loadTexture( goodsData.smallIcon )
        local text_name = image_frame_good:getChildByName( "text_name" )
        text_name:setString( goodsData.name .."×".. goodsData.count )
        image_frame_good:setVisible( true )
        
        local text_number = ccui.Helper:seekNodeByName( UIActivityRedpacketsInfo.Widget , "text_number" ) -- 未开启红包数量
        text_number:setString( Lang.ui_activity_redpackets_info1.. _number ..Lang.ui_activity_redpackets_info2)
        local text_form = ccui.Helper:seekNodeByName( UIActivityRedpacketsInfo.Widget , "text_form" )--来自：
        if _number > 0 then      
            text_form:setVisible( true )    
            local btn_next = ccui.Helper:seekNodeByName( UIActivityRedpacketsInfo.Widget , "btn_next" )
            btn_next:setVisible( true )
        else
            text_form:setVisible( false )
        end      
        UIActivityTime.refreshMoney()
    end
end
function UIActivityRedpacketsInfo.init()
    local btn_next = ccui.Helper:seekNodeByName( UIActivityRedpacketsInfo.Widget , "btn_next" )
    local image_red = ccui.Helper:seekNodeByName( UIActivityRedpacketsInfo.Widget , "image_red" )
    local function onEvent( sender , eventType )
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_next then
                _isOpenning = false
                UIActivityRedpacketsInfo.setup()
            elseif sender == image_red then
                if not _isOpenning then
                    _isOpenning = true 
                    local function netCallbackFunc( pack )                 
                        _number = pack.msgdata.int.redCount
                        _name = pack.msgdata.string.from
                        _gold = pack.msgdata.int.gold
                        _animation:setVisible( true )
                        _animation:getAnimation():stop()
                        _animation:getAnimation():playWithIndex( 0 )
                        _animation:getAnimation():setMovementEventCallFunc(onMovementEvent)
                        image_red:setOpacity( 0 )
                    end
                    netSendPackage( {
                        header = StaticMsgRule.openRed,
                        msgdata = { }
                    } , netCallbackFunc )      
                end                  
            else
                UIManager.flushWidget( UIActivityRedpackets )
                UIManager.popScene()
            end
        end
    end
    btn_next:setPressedActionEnabled( true )
    btn_next:addTouchEventListener( onEvent )
    image_red:setTouchEnabled( true )
    image_red:addTouchEventListener( onEvent )

    UIActivityRedpacketsInfo.Widget:setTouchEnabled( true )
    UIActivityRedpacketsInfo.Widget:addTouchEventListener( onEvent )

    local animPath = "ani/ui_anim/ui_anim" .. 67 .. "/"
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(animPath .. "ui_anim" .. 67 .. ".ExportJson")
    _animation = ccs.Armature:create("ui_anim" .. 67)
    _animation:getAnimation():playWithIndex( 0 )
    _animation:setPosition( cc.p( image_red:getPositionX() , image_red:getPositionY() ) )
    image_red:getParent():addChild(_animation, 100)

    _animation:setVisible( false )
end
function UIActivityRedpacketsInfo.setup()
    local text_number = ccui.Helper:seekNodeByName( UIActivityRedpacketsInfo.Widget , "text_number" ) -- 未开启红包数量
    text_number:setString( Lang.ui_activity_redpackets_info3.. _number ..Lang.ui_activity_redpackets_info4)
    local text_form = ccui.Helper:seekNodeByName( UIActivityRedpacketsInfo.Widget , "text_form" )--来自：
    text_form:setString( Lang.ui_activity_redpackets_info5.._name )
    text_form:setVisible( true )
    local image_frame_good = ccui.Helper:seekNodeByName( UIActivityRedpacketsInfo.Widget , "image_frame_good" )
    image_frame_good:setVisible( false )

    local btn_next = ccui.Helper:seekNodeByName( UIActivityRedpacketsInfo.Widget , "btn_next" )
    btn_next:setVisible( false )

    local image_red = ccui.Helper:seekNodeByName( UIActivityRedpacketsInfo.Widget , "image_red" )
    image_red:loadTexture( "ui/red_big.png" ) --red_big.png
end
function UIActivityRedpacketsInfo.free()
    _name = nil
    _number = nil
    _gold = nil
    _isOpenning = nil
end
function UIActivityRedpacketsInfo.setName( name , count )
    _name = name
    _number = count
end
