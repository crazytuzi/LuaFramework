require"Lang"
UIWingAdvance={}
local _obj = nil
local _tableFieldId = nil
local _dictId = nil
local function actionCallBack()
    local childs = UIManager.uiLayer:getChildren()
      for key, obj in pairs(childs) do
            if not tolua.isnull(obj) then
                obj:setEnabled(true)
            end
      end
end
local function netErroCallBack(data)
    if _obj.int["5"] >= 3 then
        
    else
        local dictData = DictThing[tostring(_tableFieldId)]
        utils.storyDropOutDialog(dictData , 1 )
    end
end
local function netCallBack( data )   
    UIManager.flushWidget( UIWingAdvance )
    if UIBagWing.Widget and UIBagWing.Widget:getParent() then
        UIBagWing.freshViewItem( _obj )
    end
    UIManager.flushWidget( UIWingInfo )
    UIManager.flushWidget( UILineup )
    utils.playArmature(  1 , "ui_anim1_2" , UIManager.gameLayer , 0 , 150 , actionCallBack )
end
local _selectedId = nil
local function sendData()
    local sendData = {
        header = StaticMsgRule.wingAdvance ,
        msgdata = {
            int = {
                instPlayerWingId = _obj.int["1"]
            }
        }
    }
    netSendPackage( sendData , netCallBack , netErroCallBack )
end
local function propThing( obj )
    local image_name = ccui.Helper:seekNodeByName( UIWingAdvance.Widget , "image_name" )
    image_name:getChildByName("text_name"):setString(DictWing[ tostring( obj.int["3"] ) ].name)
    local image_quality = ccui.Helper:seekNodeByName( UIWingAdvance.Widget , "image_quality" )
    --image_quality:setString("羽毛属性")
    if obj.int["3"] >= 5 then
        image_quality:loadTexture( "ui/wing_all.png" )
    else
        image_quality:loadTexture( "ui/wing_"..DictWing[ tostring( obj.int["3"] ) ].sname..".png" )
    end
    local image_di_lv = ccui.Helper:seekNodeByName( UIWingAdvance.Widget , "image_di_lv" )
    local text_lv_wing = image_di_lv:getChildByName("text_lv_wing")
    text_lv_wing:setString("LV." .. obj.int["4"])
    text_lv_wing:setVisible(true)
    local str = Lang.ui_wing_advance1
    if obj.int["5"] == 1 then
        str = Lang.ui_wing_advance2
    elseif obj.int["5"] == 2 then
        str = Lang.ui_wing_advance3
    elseif obj.int["5"] == 3 then
        str = Lang.ui_wing_advance4
        text_lv_wing:setVisible(false)
    end
    image_di_lv:getChildByName( "text_lv" ):setString(str)
    

    local image_wing_di = ccui.Helper:seekNodeByName( UIWingAdvance.Widget , "image_wing_di" )
    local strengthenData , advanceData , proShow = utils.getWingInfo( obj.int["3"] , obj.int["4"] , obj.int["5"] , image_wing_di , false , true )
    if obj.int["5"] < 3  then
        local thingData = utils.getItemProp( advanceData.nextStarNumConds )
        _tableFieldId = thingData.tableFieldId
        local image_stone = ccui.Helper:seekNodeByName( UIWingAdvance.Widget , "image_stone" )
        image_stone:loadTexture( thingData.smallIcon )
        local text_title = image_stone:getChildByName( "text_title" )
        text_title:setString( thingData.name )
        local text_hint = image_stone:getChildByName( "text_hint" )
        local num = utils.getThingCount(thingData.tableFieldId) 
        text_hint:setString( num.."/"..thingData.count )
    else
        local image_stone = ccui.Helper:seekNodeByName( UIWingAdvance.Widget , "image_stone" )
        image_stone:setVisible( false )
    end
    for i = 1 , 8 do
        local text_add = image_wing_di:getChildByName("text_add"..i)
        text_add:setVisible( false )
    end
end
function UIWingAdvance.init()
    local btn_close = ccui.Helper:seekNodeByName( UIWingAdvance.Widget , "btn_close" )
    local btn_lineup = ccui.Helper:seekNodeByName( UIWingAdvance.Widget , "btn_lineup" )
    local image_stone = ccui.Helper:seekNodeByName( UIWingAdvance.Widget , "image_stone" )
    local function onEvent(sender , eventType )
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_close then
                UIManager.popScene()
            elseif sender == btn_lineup then
                sendData()
            elseif sender == image_stone then
                local dictData = DictThing[tostring(_tableFieldId)]
                utils.storyDropOutDialog(dictData , 1 )
            end
        end
    end
    btn_close:setPressedActionEnabled( true )
    btn_close:addTouchEventListener( onEvent )
    btn_lineup:setPressedActionEnabled( true )
    btn_lineup:addTouchEventListener( onEvent )
    image_stone:addTouchEventListener( onEvent )
end
function UIWingAdvance.setup()
    propThing( _obj )
    local image_wing = ccui.Helper:seekNodeByName( UIWingAdvance.Widget , "image_wing")
    image_wing:setVisible( false )
    local lvl = _obj.int["5"] >= 3 and 3 or ( _obj.int["5"] + 1 )
    local actionName = DictWing[tostring(_obj.int["3"])].actionName
    if actionName and actionName ~= "" then
        utils.addArmature( image_wing:getParent() , 54 + lvl , actionName , image_wing:getPositionX() , image_wing:getPositionY() , image_wing:getLocalZOrder() , image_wing:getScale() )
    else
        utils.addArmature( image_wing:getParent() , 54 + lvl , "0"..lvl..DictWing[tostring(_obj.int["3"])].sname , image_wing:getPositionX() , image_wing:getPositionY() , image_wing:getLocalZOrder() , image_wing:getScale() )
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
function UIWingAdvance.setData( obj , dictId )
    _obj = obj
    _dictId = dictId
end
function UIWingAdvance.free()
    _obj = nil
    _tableFieldId = nil
    _dictId = nil
end
