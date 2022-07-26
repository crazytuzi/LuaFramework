UIWingCommon={}
local _obj = nil
local function actionCallBack()
    UIManager.popScene()
end
local function netCallBack( data )
    utils.playArmature(  41 , "ui_anim41_5" , UIManager.gameLayer , 0 , 150 , actionCallBack , false , false , 1.2 )
    UIManager.flushWidget( UIBagWing )
end
local _selectedId = nil
local function sendData()
    local sendData = {
        header = StaticMsgRule.wingActivity ,
        msgdata = {
            int = {
                wingId = _selectedId
            }
        }
    }
    netSendPackage( sendData , netCallBack )
end
local function propThing( _id )
    local image_name = ccui.Helper:seekNodeByName( UIWingCommon.Widget , "image_name" )
    image_name:getChildByName("text_name"):setString(DictWing[ tostring( _id ) ].name)
    local image_quality = ccui.Helper:seekNodeByName( UIWingCommon.Widget , "image_quality" )
    --image_quality:setString("ÓðÃ«ÊôÐÔ")
    if _id >= 5 then
        image_quality:loadTexture( "ui/wing_all.png" )
    else
        image_quality:loadTexture( "ui/wing_"..DictWing[ tostring( _id ) ].sname..".png" )
    end
    
    local image_wing_di = ccui.Helper:seekNodeByName( UIWingCommon.Widget , "image_wing_di" )
    local strengthenData , advanceData , proShow = utils.getWingInfo( _id , 0 , 1 , image_wing_di )

    local image_wing = ccui.Helper:seekNodeByName( UIWingCommon.Widget , "image_wing")
    image_wing:setVisible( false )
    local lvl = 1
    local actionName = DictWing[tostring(_id)].actionName
    if actionName and actionName ~= "" then
        utils.addArmature( image_wing:getParent() , 54 + lvl , actionName , image_wing:getPositionX() , image_wing:getPositionY() , image_wing:getLocalZOrder() , image_wing:getScale() )
    else
        utils.addArmature( image_wing:getParent() , 54 + lvl , "0"..lvl..DictWing[tostring(_id)].sname , image_wing:getPositionX() , image_wing:getPositionY() , image_wing:getLocalZOrder() , image_wing:getScale() )
    end
end
function UIWingCommon.init()
    local btn_close = ccui.Helper:seekNodeByName( UIWingCommon.Widget , "btn_close" )
    local btn_common = ccui.Helper:seekNodeByName( UIWingCommon.Widget , "btn_common" )
    local function onEvent(sender , eventType )
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_close then
                UIManager.popScene()
            elseif sender == btn_common then
                sendData()               
            end
        end
    end
    btn_close:setPressedActionEnabled( true )
    btn_close:addTouchEventListener( onEvent )
    btn_common:setPressedActionEnabled( true )
    btn_common:addTouchEventListener( onEvent )

    local checkbox = {}
    local function onCheckBoxEvent(sender , eventType)
        if eventType == ccui.CheckBoxEventType.selected then
            for key , value in pairs( checkbox ) do
                if sender == value then
                    _selectedId = key
                else
                    value:setSelected( false )
                end
                propThing( _selectedId )
            end
        elseif eventType == ccui.CheckBoxEventType.unselected then
           -- _selectedId = nil
           sender:setSelected( true )
        end
    end
    for i = 1 , 4 do
        local checkbox_practice = ccui.Helper:seekNodeByName( UIWingCommon.Widget , "checkbox_practice"..i )
        table.insert( checkbox , checkbox_practice )
        checkbox_practice:addEventListener( onCheckBoxEvent )

        local text_practice = checkbox_practice:getChildByName( "text_practice" )
        text_practice:setString( DictWing[ tostring( i ) ].description )
    end
    local image_wing_di = ccui.Helper:seekNodeByName( UIWingCommon.Widget , "image_wing_di" )
    for i = 1 , 8 do
        local text_add = image_wing_di:getChildByName( "text_add"..i )
        text_add:setVisible( false )
    end
end
function UIWingCommon.setData( obj )
   _obj = obj
end
function UIWingCommon.setup()
    _selectedId = 1
    propThing( _selectedId )
end
function UIWingCommon.free()
    _selectedId = nil
    _obj = nil
end