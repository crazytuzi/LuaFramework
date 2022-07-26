require"Lang"
UIWingChange={}
local _obj = nil
local _wingId = nil
local _dictId = nil
local _animation = nil
local _selectedId = nil
local function netCallBack( data )
    utils.playArmature(  41 , "ui_anim41_3" , UIWingChange.Widget , 0 , 150 , false , false , false , 1.2 )
    _wingId = {}
    for i = 1 , 4 do
       if i ~= _obj.int["3"] then
           table.insert( _wingId , i )
       end
    end
    local panel_change = ccui.Helper:seekNodeByName( UIWingChange.Widget , "panel_change" )
    local checkbox_practice1 = ccui.Helper:seekNodeByName( panel_change , "checkbox_practice1" )
    local checkbox_practice2 = ccui.Helper:seekNodeByName( panel_change , "checkbox_practice2" )
    local checkbox_practice3 = ccui.Helper:seekNodeByName( panel_change , "checkbox_practice3" )
    checkbox_practice1:setSelected( false )
    checkbox_practice2:setSelected( false )
    checkbox_practice3:setSelected( false )
    _selectedId= nil
    UIManager.flushWidget( UIWingChange )
    if UIBagWing.Widget and UIBagWing.Widget:getParent() then
        UIBagWing.freshViewItem( _obj )
    end
    UIManager.flushWidget( UIWingInfo )
    UIManager.flushWidget( UILineup )
end
local function sendData()
    local sendData = {
        header = StaticMsgRule.wingConvert ,
        msgdata = {
            int = {
                wingId  = _wingId[ _selectedId ] ,
                instPlayerWingId = _obj.int["1"]
            }
        }
    }
    netSendPackage( sendData , netCallBack )
end
local function comparePro()
    local image_wing_di = ccui.Helper:seekNodeByName( UIWingChange.Widget , "image_wing_di" )
    if _selectedId then
        local strengthenData1 , advanceData1 , proShow1 = utils.getWingInfo( _wingId[ _selectedId ] , _obj.int["4"] , _obj.int["5"] , image_wing_di )  
        local image_quality = ccui.Helper:seekNodeByName( UIWingChange.Widget , "image_quality" )
        image_quality:loadTexture( "ui/wing_"..DictWing[ tostring( _wingId[ _selectedId ] ) ].sname..".png" )
        if _animation then
            _animation:getAnimation():play( "ui_anim" .. ( 54 + _obj.int["5"] ) .. "_0".._obj.int["5"]..DictWing[ tostring( _wingId[ _selectedId ] ) ].sname )
        end
    else
        local strengthenData1 , advanceData1 , proShow1 = utils.getWingInfo( _obj.int["3"] , _obj.int["4"] , _obj.int["5"] , image_wing_di )  
        local image_quality = ccui.Helper:seekNodeByName( UIWingChange.Widget , "image_quality" )
        image_quality:loadTexture( "ui/wing_"..DictWing[ tostring( _obj.int["3"] ) ].sname..".png" )
        if _animation then
            _animation:getAnimation():play( "ui_anim" .. ( 54 + _obj.int["5"] ) .. "_0".._obj.int["5"]..DictWing[ tostring( _obj.int["3"] ) ].sname )
        end
    end
end
local function propThing( obj )
    local image_name = ccui.Helper:seekNodeByName( UIWingChange.Widget , "image_name" )
    image_name:getChildByName("text_name"):setString(DictWing[ tostring( obj.int["3"] ) ].name)
    local image_quality = ccui.Helper:seekNodeByName( UIWingChange.Widget , "image_quality" )
    --image_quality:setString("羽毛属性")
    if obj.int["3"] >= 5 then
        image_quality:loadTexture( "ui/wing_all.png" )
    else
        image_quality:loadTexture( "ui/wing_"..DictWing[ tostring( obj.int["3"] ) ].sname..".png" )
    end
    local panel_card = ccui.Helper:seekNodeByName( UIWingChange.Widget , "panel_card" )
    local str = Lang.ui_wing_change1
    if obj.int["5"] == 1 then
    elseif obj.int["5"] == 2 then
        str = Lang.ui_wing_change2
    elseif obj.int["5"] == 3 then
        str = Lang.ui_wing_change3
    end
    ccui.Helper:seekNodeByName( panel_card , "text_name" ):setString(str)
    ccui.Helper:seekNodeByName( panel_card , "text_lv_wing" ):setString("LV." .. obj.int["4"])
    
    local image_wing_di = ccui.Helper:seekNodeByName( UIWingChange.Widget , "image_wing_di" )
    local strengthenData , advanceData , proShow = utils.getWingInfo( obj.int["3"] , obj.int["4"] , obj.int["5"] , image_wing_di )

    local panel_change = ccui.Helper:seekNodeByName( UIWingChange.Widget , "panel_change" )
    ccui.Helper:seekNodeByName( UIWingChange.Widget , "text_gold" ):setString(advanceData.convertGold)

    
    local checkbox_practice1 = ccui.Helper:seekNodeByName( panel_change , "checkbox_practice1" )
    local checkbox_practice2 = ccui.Helper:seekNodeByName( panel_change , "checkbox_practice2" )
    local checkbox_practice3 = ccui.Helper:seekNodeByName( panel_change , "checkbox_practice3" )
    local checkbox = { checkbox_practice1 , checkbox_practice2 , checkbox_practice3 }
    local function onCheckBoxEvent( sender , eventType )
        if eventType == ccui.CheckBoxEventType.selected then
            if sender == checkbox_practice1 then
                _selectedId = 1
            elseif sender == checkbox_practice2 then
                _selectedId = 2
            elseif sender == checkbox_practice3 then
                _selectedId = 3
            end
            for key , value in pairs ( checkbox ) do
                if key ~= _selectedId then
                    value:setSelected( false )
                end
            end
            comparePro()
        elseif eventType == ccui.CheckBoxEventType.unselected then
            _selectedId = nil
            comparePro()
        end
    end
    checkbox_practice1:addEventListener( onCheckBoxEvent )
    checkbox_practice2:addEventListener( onCheckBoxEvent )
    checkbox_practice3:addEventListener( onCheckBoxEvent )

    for key ,value in pairs( checkbox ) do
        local text_practice = value:getChildByName( "text_practice" )
        text_practice:setString( DictWing[ tostring(_wingId[key]) ].description )
    end

end
function UIWingChange.init()
    local btn_close = ccui.Helper:seekNodeByName( UIWingChange.Widget , "btn_close" )
    local btn_change = ccui.Helper:seekNodeByName( UIWingChange.Widget , "btn_change" )
    local function onEvent(sender , eventType )
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_close then
                UIManager.popScene()
            elseif sender == btn_change then
                if _selectedId then
                    sendData()
                else
                    UIManager.showToast(Lang.ui_wing_change4)
                end
            end
        end
    end
    btn_close:setPressedActionEnabled( true )
    btn_close:addTouchEventListener( onEvent )
    btn_change:setPressedActionEnabled( true )
    btn_change:addTouchEventListener( onEvent )

    local image_wing_di = ccui.Helper:seekNodeByName( UIWingChange.Widget , "image_wing_di" )
    for i = 1 , 8 do
        local text_add = image_wing_di:getChildByName( "text_add"..i )
        text_add:setVisible( false )
    end
end
function UIWingChange.setup()
    propThing( _obj )
    comparePro()
    local image_wing = ccui.Helper:seekNodeByName( UIWingChange.Widget , "image_card")
    image_wing:setVisible( false )
    local lvl = _obj.int["5"]
    local actionName = DictWing[tostring(_obj.int["3"])].actionName
    if actionName and actionName ~= "" then
        _animation = utils.addArmature( image_wing:getParent() , 54 + lvl , actionName , image_wing:getPositionX() , image_wing:getPositionY() , image_wing:getLocalZOrder() - 1 , image_wing:getScale() )
    else
        _animation = utils.addArmature( image_wing:getParent() , 54 + lvl , "0"..lvl..DictWing[tostring(_obj.int["3"])].sname , image_wing:getPositionX() , image_wing:getPositionY() , image_wing:getLocalZOrder() - 1 , image_wing:getScale() )
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
			image_wing:getParent():addChild(cardAnim, image_wing:getLocalZOrder()-1)
		end
    end
end
function UIWingChange.setData( obj , dictId )
    _obj = obj
    _wingId = {}
    for i = 1 , 4 do
       if i ~= _obj.int["3"] then
           table.insert( _wingId , i )
       end
    end
    _dictId = dictId
end
function UIWingChange.free()
    _obj = nil
    _selectedId = nil
    _wingId = nil
    _dictId = nil
    _animation = nil
end
