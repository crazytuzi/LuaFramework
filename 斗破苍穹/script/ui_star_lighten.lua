require"Lang"
UIStarLighten = {}
local image_star = {}
local image_star_light = {}
local _star = nil
local _star_light = nil
local _star_lighten = nil
local _offsetX = nil
local _offsetY = nil
local _baseY = nil
local text = nil
local curStarCount = nil
UIStarLighten.curChooseGrade = 0
UIStarLighten.objData = nil
local function startEffect( _pos , _toPos )
    local childs = UIManager.uiLayer:getChildren()
    for key, obj in pairs(childs) do
		obj:setEnabled(false)
	end
    local effect = cc.ParticleSystemQuad:create("particle/star/ui_anim60_lizi02.plist")
    local function effectCallback(args)
       
        if effect:getParent() then
            effect:removeFromParent()
        end
        text:setVisible( true )
        local addValue = UIStarLighten.objData.int["5"] - curStarCount
        if addValue > 1 then
            text:setFontSize( 40 )
        else
            text:setFontSize( 20 )
        end
        text:setScale( 1.0 )
       -- local image_star = ccui.Helper:seekNodeByName( UIStarLighten.Widget , "image_star" )
        --local bar_star = image_star:getChildByName("bar_star")
        text:setString( "+"..( addValue ))
        --text:setPosition( cc.p( image_star:getPositionX() - image_star:getContentSize().width / 2  + bar_star:getPositionX() - bar_star:getContentSize().width / 2 + bar_star:getContentSize().width * bar_star:getPercent() / 100  , _baseY + image_star:getPositionY() - image_star:getContentSize().height / 2 + bar_star:getPositionY() - 20 ) )
        local function textCallBack(args)
            for key, obj in pairs(childs) do
		        obj:setEnabled(true)
	        end
            text:setVisible( false )
            UIStarLighten.setup()
        end
        text:runAction( cc.Sequence:create(cc.ScaleTo:create(0.3, 1.2 ) , cc.CallFunc:create( textCallBack ) ) )
    end
    effect:setName("effect")
	effect:setPosition(cc.p(_pos.x, _pos.y))
	UIStarLighten.Widget:addChild(effect, 1000)
	effect:runAction(cc.Sequence:create(cc.MoveTo:create(0.5, _toPos) , cc.CallFunc:create(effectCallback) ))
end
local function netCallBack( pack )
    UIStar.curChooseG = pack.msgdata.int.openGradeId
    if pack.header == StaticMsgRule.holdStar then
        local toIndex = tonumber( pack.msgdata.int.lightPos )
        cclog("toIndex "..toIndex)
        if toIndex == 0 then
            local image_star = ccui.Helper:seekNodeByName( UIStarLighten.Widget , "image_star" )
            local bar_star = image_star:getChildByName("bar_star")
            startEffect( cc.p( _offsetX , _offsetY ), cc.p( image_star:getPositionX() - image_star:getContentSize().width / 2  + bar_star:getPositionX() - bar_star:getContentSize().width / 2 + bar_star:getContentSize().width * bar_star:getPercent() / 100  , _baseY + image_star:getPositionY() - image_star:getContentSize().height / 2 + bar_star:getPositionY() ) )       
        else
            startEffect( cc.p( _offsetX , _offsetY ), cc.p( image_star_light[toIndex]:getPositionX() , _baseY + image_star_light[toIndex]:getPositionY() ) )
        end
    elseif pack.header == StaticMsgRule.refreshStarZodiac then
        UIStarLighten.setup()
    end
end
local function netSend( type , position )
    local sendData = {}
    if type == 1 then --占星
        sendData = {
            header = StaticMsgRule.holdStar ,
            msgdata = {
                int = {
                    gradeId = UIStarLighten.curChooseGrade ,
                    pos = position
                }
            }
        }
    elseif type == 2 then -- 刷新
        sendData = {
            header = StaticMsgRule.refreshStarZodiac ,
            msgdata = {
                int = {
                    gradeId = UIStarLighten.curChooseGrade
                }
            }
        }
    end
    netSendPackage( sendData , netCallBack )
end
function UIStarLighten.init()
    text = ccui.Text:create("+40","Arial",50)
    text:setVisible( false )
    text:setTextColor( cc.c3b( 0 , 250 , 0) )
    text:setPosition( cc.p( UIManager.screenSize.width / 2 + 80 , 545 ) )
    UIStarLighten.Widget:addChild( text , 100001 )
    local btn_back = ccui.Helper:seekNodeByName( UIStarLighten.Widget , "btn_back" )
    local btn_reward = ccui.Helper:seekNodeByName( UIStarLighten.Widget , "btn_reward" )
    local btn_help = ccui.Helper:seekNodeByName( UIStarLighten.Widget , "btn_help" )
    local btn_refresh = ccui.Helper:seekNodeByName( UIStarLighten.Widget , "btn_refresh" )
    local image_basemap = ccui.Helper:seekNodeByName( UIStarLighten.Widget , "image_basemap" )
    for i = 1 , 4 do
        local star = image_basemap:getChildByName( "image_star"..i )
        table.insert( image_star_light , star )
    end
    local image_di_star = ccui.Helper:seekNodeByName( UIStarLighten.Widget , "image_di_star" )   
    for i = 1 , 5 do
        local star = image_di_star:getChildByName( "image_star"..i )
        table.insert( image_star , star )
    end
    local function onEvent( sender , eventType )
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_back then
                UIManager.showWidget("ui_star")
            elseif sender == btn_reward then
                UIManager.pushScene("ui_star_reward")
            elseif sender == btn_help then
                UIAllianceHelp.show( { type = 12 , titleName = Lang.ui_star_lighten1 } )
            elseif sender == btn_refresh then
                netSend( 2 )
            end
            for key , obj in pairs( image_star ) do
                if sender == obj then
                    netSend( 1 , key )
                    _baseY = image_basemap:getPositionY() - image_basemap:getContentSize().height / 2
                    _offsetX = obj:getPositionX()
                    _offsetY = image_basemap:getPositionY() - image_basemap:getContentSize().height / 2 + image_di_star:getPositionY() - image_di_star:getContentSize().height / 2 + obj:getPositionY()
                   -- startEffect( cc.p( obj:getPositionX() , image_basemap:getPositionY() - image_basemap:getContentSize().height / 2 + image_di_star:getPositionY() - image_di_star:getContentSize().height / 2 + obj:getPositionY() ), cc.p( image_star_light[1]:getPositionX() , image_basemap:getPositionY() - image_basemap:getContentSize().height / 2 + image_star_light[1]:getPositionY() ) )
                    break
                end
            end
        end
    end
    btn_back:setPressedActionEnabled( true )
    btn_back:addTouchEventListener( onEvent )
    btn_reward:setPressedActionEnabled( true )
    btn_reward:addTouchEventListener( onEvent )
    btn_help:setPressedActionEnabled( true )
    btn_help:addTouchEventListener( onEvent )
    btn_refresh:setPressedActionEnabled( true )
    btn_refresh:addTouchEventListener( onEvent )
    for key , obj in pairs( image_star ) do
        obj:setTouchEnabled( true )
        obj:addTouchEventListener( onEvent )
    end
end
function UIStarLighten.setup()
    local image_fight = ccui.Helper:seekNodeByName( UIStarLighten.Widget , "image_fight")
    local image_gold = ccui.Helper:seekNodeByName( UIStarLighten.Widget , "image_gold" )
    local image_silver = ccui.Helper:seekNodeByName( UIStarLighten.Widget , "image_silver" )
    if net.InstPlayer then
        image_fight:getChildByName("label_fight"):setString(tostring(utils.getFightValue()))
        image_gold:getChildByName("text_gold_number"):setString(tostring(net.InstPlayer.int["5"]))
        image_silver:getChildByName("text_silver_number"):setString(net.InstPlayer.string["6"])
    end
    _star = {}
    _star_light = {}
    _star_lighten = {}
    local curHoldCount , curFreeCount , step = 0 , 0 , 1
    local function callBack(pack)
         if UIStarLighten.objData then
            local upStars = utils.stringSplit( UIStarLighten.objData.string["13"] , ";")
            for key , value in pairs( upStars ) do
                local tempObj = utils.stringSplit( value , "_")
                _star_light[ tonumber(tempObj[1]) ] = tonumber( tempObj[2] )
                _star_lighten[ tonumber(tempObj[1]) ] = tonumber( tempObj[3] )
                if tonumber(tempObj[3]) == 1 then
                    utils.GrayWidget( image_star_light[ tonumber(tempObj[1]) ] , false )
                   -- utils.addFrameParticle( image_star_light[ tonumber(tempObj[1]) ] , true , false , true )
                else
                    utils.GrayWidget( image_star_light[ tonumber(tempObj[1]) ] , true )
                   -- utils.addFrameParticle( image_star_light[ tonumber(tempObj[1]) ] , false , false , true )
                end
            end
            local downStars = utils.stringSplit( UIStarLighten.objData.string["14"] , ";")
            for key , value in pairs( downStars ) do
                local tempObj = utils.stringSplit( value , "_")
                _star[ tonumber(tempObj[1]) ] = tonumber( tempObj[2] )
            end
            curStarCount = UIStarLighten.objData.int["5"]
            curHoldCount = UIStarLighten.objData.int["6"]
            step = UIStarLighten.objData.int["4"]
            curFreeCount = UIStarLighten.objData.int["8"]
        else
        end
        local function isIn( id )
            for key ,value in pairs( _star_light ) do
                if value == id and _star_lighten[ key ] == 0 then
                    return true
                end
            end
            return false
        end
        for key , value in pairs( _star_light ) do
            image_star_light[ key ]:loadTexture( "image/"..DictUI[ tostring( DictHoldStarZodiac[ tostring(value )].uiId ) ].fileName )
        end
        for key ,value in pairs( _star ) do
            image_star[ key ]:loadTexture("image/"..DictUI[ tostring( DictHoldStarZodiac[ tostring(value ) ].uiId ) ].fileName )
            if isIn( value ) then
                utils.addFrameParticle( image_star[ key ] , true , false , true )
            else
                utils.addFrameParticle( image_star[ key ] , false , false , true )
            end
        end
        local bar_star = ccui.Helper:seekNodeByName( UIStarLighten.Widget , "bar_star" )
        bar_star:setPercent( curStarCount * 100 / DictHoldStarRewardPos["10"].starNum )
        bar_star:getChildByName("text_star_number"):setString( Lang.ui_star_lighten2..curStarCount )
        local text_get_number = ccui.Helper:seekNodeByName( UIStarLighten.Widget , "text_get_number" )
        text_get_number:setString(Lang.ui_star_lighten3..tostring(curHoldCount).."/"..DictSysConfig[ tostring(StaticSysConfig.holdStarCanHoldTimes )].value)
        local text_refresh_number = ccui.Helper:seekNodeByName( UIStarLighten.Widget , "text_refresh_number" )
        text_refresh_number:setString(Lang.ui_star_lighten4..( DictSysConfig[ tostring(StaticSysConfig.holdStarFreeRefreshTimes )].value - curFreeCount))
        local image_ke_have = ccui.Helper:seekNodeByName( UIStarLighten.Widget , "image_ke_have" )
        image_ke_have:loadTexture("ui/star_ke.png")
        local thingNum = 0
        if net.InstPlayerThing then
            for key, obj in pairs(net.InstPlayerThing) do
                if StaticThing.holdStarThing == obj.int["3"] then
                    thingNum = obj.int["5"]
                    break
                end
            end
        end
        image_ke_have:getChildByName("text_ke_number"):setString("x"..thingNum)
        local text_hint_get = ccui.Helper:seekNodeByName( UIStarLighten.Widget , "text_hint_get")
        text_hint_get:setString(DictHoldStarStep[tostring(step)].rewardStarNum)
        local image_ke = ccui.Helper:seekNodeByName( UIStarLighten.Widget , "image_ke" )
        image_ke:getChildByName( "text_ke_number"):setString( DictSysConfig[ tostring(StaticSysConfig.holdStarRefreshThingNum )].value..Lang.ui_star_lighten5)
        local image_gold = ccui.Helper:seekNodeByName( UIStarLighten.Widget , "image_di" ):getChildByName("image_gold")
        image_gold:getChildByName( "text_gold_number"):setString( Lang.ui_star_lighten6..DictSysConfig[ tostring(StaticSysConfig.holdStarRefreshGoldNum )].value..Lang.ui_star_lighten7)
    end
    callBack()
    local btn_reward = ccui.Helper:seekNodeByName( UIStarLighten.Widget , "btn_reward" )
    if UIStarReward.checkHint() then
        utils.addFrameParticle( btn_reward , true  , false , false , 20 , 10 )
    else
        utils.addFrameParticle( btn_reward )
    end
end
function UIStarLighten.free()
    _star = nil
    _star_light = nil
    _star_lighten = nil
    _offsetX = nil
    _offsetY = nil
    _baseY = nil
    curStarCount = nil
    UIStarLighten.objData = nil
end
function UIStarLighten.setGradeId( id )
   UIStarLighten.curChooseGrade = id
end
function UIStarLighten.setObj( data )
   UIStarLighten.objData = data
end
