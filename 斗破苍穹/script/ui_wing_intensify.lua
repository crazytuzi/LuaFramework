require"Lang"
UIWingIntensify={}
local _obj = nil
local _tableFieldId = nil
local _dictId = nil
local function netErroCallBack(data)
    if _obj.int["4"] >= 40 then
        
    else
        local dictData = DictThing[tostring(_tableFieldId)]
        utils.storyDropOutDialog(dictData , 2)
    end
end
local function netCallBack( data )
    utils.playArmature(  59 , "ui_anim59" , UIWingIntensify.Widget , 0 , 150 )
    UIManager.flushWidget( UIWingIntensify )
    if UIBagWing.Widget and UIBagWing.Widget:getParent() then
        UIBagWing.freshViewItem( _obj )
    end
    UIManager.flushWidget( UIWingInfo )
    UIManager.flushWidget( UILineup )
end
local function sendData( type )
    local sendData = {}
    if type == 1 then
        sendData = {
            header = StaticMsgRule.wingStronger ,
            msgdata = {
                int = {
                    instPlayerWingId = _obj.int["1"]
                }
            }
        }
    elseif type == 2 then
        sendData = {
            header = StaticMsgRule.wingOneKeyStronger ,
            msgdata = {
                int = {
                    instPlayerWingId = _obj.int["1"]
                }
            }
        }
    end
    cclog(" _obj.int ".. _obj.int["1"])
    netSendPackage( sendData , netCallBack , netErroCallBack )
end
local function propThing( obj )
    local image_name = ccui.Helper:seekNodeByName( UIWingIntensify.Widget , "image_name" )
    image_name:getChildByName("text_name"):setString(DictWing[ tostring( obj.int["3"] ) ].name)
    local image_quality = ccui.Helper:seekNodeByName( UIWingIntensify.Widget , "image_quality" )
    --image_quality:setString("羽毛属性")
    if obj.int["3"] >= 5 then
        image_quality:loadTexture( "ui/wing_all.png" )
    else
        image_quality:loadTexture( "ui/wing_"..DictWing[ tostring( obj.int["3"] ) ].sname..".png" )
    end
    local image_di_lv = ccui.Helper:seekNodeByName( UIWingIntensify.Widget , "image_di_lv" )
    local str = Lang.ui_wing_intensify1
    if obj.int["5"] == 1 then
    elseif obj.int["5"] == 2 then
        str = Lang.ui_wing_intensify2
    elseif obj.int["5"] == 3 then
        str = Lang.ui_wing_intensify3
    end
    image_di_lv:getChildByName( "text_lv" ):setString(str)

    local image_wing_di = ccui.Helper:seekNodeByName( UIWingIntensify.Widget , "image_wing_di" )
    local strengthenData , advanceData , proShow = utils.getWingInfo( obj.int["3"] , obj.int["4"] , obj.int["5"] , image_wing_di , true )

    local thingData = utils.getItemProp( strengthenData.nextLevelConds ) --utils.stringSplit( strengthenData.nextLevelConds , "_" )
    _tableFieldId = thingData.tableFieldId
    local image_stone = ccui.Helper:seekNodeByName( UIWingIntensify.Widget , "image_stone" )
    image_stone:loadTexture( thingData.smallIcon )
    local text_title = image_stone:getChildByName( "text_title" )
    text_title:setString( thingData.name )
    local text_hint = image_stone:getChildByName( "text_hint" )

    local num = utils.getThingCount(StaticThing.thing305) 
    text_hint:setString( num.."/"..thingData.count )

    local text_number = ccui.Helper:seekNodeByName( UIWingIntensify.Widget , "text_number" )
    text_number:setString( "LV."..obj.int["4"] )
    local text_number_up = ccui.Helper:seekNodeByName(UIWingIntensify.Widget , "text_number_up")
    if obj.int["4"] >= 40 then
        text_number_up:setVisible( false )
    else
        text_number_up:setVisible( true )
        text_number_up:setString( "→"..(obj.int["4"] + 1 ))
    end
end
function UIWingIntensify.init()
    local btn_close = ccui.Helper:seekNodeByName( UIWingIntensify.Widget , "btn_close" )
    local btn_lineup = ccui.Helper:seekNodeByName( UIWingIntensify.Widget , "btn_lineup" )
    local btn_onekey = ccui.Helper:seekNodeByName( UIWingIntensify.Widget , "btn_onekey" )
    local image_stone = ccui.Helper:seekNodeByName( UIWingIntensify.Widget , "image_stone" )
    local function onEvent(sender , eventType )
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_close then
                UIManager.popScene()
            elseif sender == btn_lineup then
                sendData( 1 )
            elseif sender == btn_onekey then
                sendData( 2 )
            elseif sender == image_stone then
                local dictData = DictThing[tostring(_tableFieldId)]
                utils.storyDropOutDialog(dictData , 2)
            end
        end
    end
    btn_close:setPressedActionEnabled( true )
    btn_close:addTouchEventListener( onEvent )
    btn_lineup:setPressedActionEnabled( true )
    btn_lineup:addTouchEventListener( onEvent )
    btn_onekey:setPressedActionEnabled( true )
    btn_onekey:addTouchEventListener( onEvent )
    image_stone:addTouchEventListener( onEvent )
end
function UIWingIntensify.setup()
    propThing( _obj )
    local image_wing = ccui.Helper:seekNodeByName( UIWingIntensify.Widget , "image_wing")
    image_wing:setVisible( false )
    local actionName = DictWing[tostring(_obj.int["3"])].actionName
    if actionName and actionName ~= "" then
        utils.addArmature( image_wing:getParent() , 54 + _obj.int["5"] , actionName , image_wing:getPositionX() , image_wing:getPositionY() , image_wing:getLocalZOrder() , image_wing:getScale() )
    else
        utils.addArmature( image_wing:getParent() , 54 + _obj.int["5"] , "0".._obj.int["5"]..DictWing[tostring(_obj.int["3"])].sname , image_wing:getPositionX() , image_wing:getPositionY() , image_wing:getLocalZOrder() , image_wing:getScale() )
    end
    if _dictId then
        local dictCardData = DictCard[tostring(_dictId)]
		if dictCardData then			
            local isAwake = net.InstPlayerCard[tostring(_obj.int["6"])].int["18"]
			local cardAnim, cardAnimName
            if dictCardData.animationFiles and string.len(dictCardData.animationFiles) > 0 then
                cardAnim, cardAnimName = ActionManager.getCardAnimation(isAwake == 1 and dictCardData.awakeAnima or dictCardData.animationFiles)
            else
                cardAnim, cardAnimName = ActionManager.getCardBreatheAnimation("image/" .. DictUI[tostring(isAwake == 1 and dictCardData.awakeBigUiId or dictCardData.bigUiId)].fileName)
            end
			cardAnim:setScale(image_wing:getScale())
			cardAnim:setPosition(cc.p(image_wing:getPositionX() , image_wing:getPositionY()))
			image_wing:getParent():addChild(cardAnim, image_wing:getLocalZOrder())
		end
    end
end
function UIWingIntensify.setData( obj , dictId )
    _obj = obj
    _dictId = dictId
end
function UIWingIntensify.free()
    _obj = nil
    _tableFieldId = nil
    _dictId = nil
end
