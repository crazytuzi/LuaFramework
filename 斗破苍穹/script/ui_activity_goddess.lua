require"Lang"
UIActivityGoddess = {}
local _panel = nil
local _page_beauty = nil
local _data = nil
local _curPageViewIndex = nil
local _scrollView = nil
local _item = nil
local _rankData = nil
local _score = nil
local _reward = nil
local _params = nil
local _sendCount = nil
local function getAnimation( index )
    local animation = nil
    if index == 0 then
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("ani/ui_anim/fm_anim_wodenvshen/fm_anim_wodenvshen.ExportJson")
        animation = ccs.Armature:create("fm_anim_wodenvshen")
    elseif index == 1 then
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("ani/ui_anim/fm_anim_wodenvshen1/fm_anim_wodenvshen1.ExportJson")
        animation = ccs.Armature:create("fm_anim_wodenvshen1")
    end
    return animation
end
local function refreshView()
    _scrollView:removeAllChildren()
    utils.updateScrollView( UIActivityGoddess , _scrollView , _item , _rankData , function ( item , data )
        local obj = utils.stringSplit( data , "|" )
        --1.施主你踩着我袈裟了  撩妹指数：200000
        item:setString( obj[ 1 ] .. "." .. obj[ 2 ] .. Lang.ui_activity_goddess1 .. obj[ 3 ] )
    end)
end
local function setData( pageIndex )
    _curPageViewIndex = pageIndex
--    cclog( "pageIndex:"..pageIndex )
--    local btn_r = ccui.Helper:seekNodeByName( UIActivityGoddess.Widget , "btn_r" )
--    local btn_l = ccui.Helper:seekNodeByName( UIActivityGoddess.Widget , "btn_l" )
--    if _curPageViewIndex == 0 then
--        btn_l:setVisible( false )
--    else
--        btn_l:setVisible( true )
--    end
--    if _curPageViewIndex == #_data - 1 then
--        btn_r:setVisible( false )
--    else
--        btn_r:setVisible( true )
--    end
--撩妹配置信息：   id|cardId|档次Id_撩妹指数_送出花朵_获得魂魄;.../
    local obj = utils.stringSplit( _data[ _curPageViewIndex + 1 ] , "|" )
    local objThings = utils.stringSplit( obj[ 3 ] , ";" )
    local image_get1 = ccui.Helper:seekNodeByName( UIActivityGoddess.Widget , "image_get1" )
    local btn_send1 = image_get1:getChildByName( "btn_send" )
    local image_get2 = ccui.Helper:seekNodeByName( UIActivityGoddess.Widget , "image_get2" )
    local btn_send2 = image_get2:getChildByName( "btn_send" )
    local image_get3 = ccui.Helper:seekNodeByName( UIActivityGoddess.Widget , "image_get3" )
    local btn_send3 = image_get3:getChildByName( "btn_send" )
    _sendCount = {}
    for i = 1 , 3 do
        local thingData = utils.stringSplit( objThings[ i ] , "_" )
        local image = image_get1
        if i == 1 then
            image = image_get1
        elseif i == 2 then
            image = image_get2
        elseif i == 3 then
            image = image_get3
        end
        _sendCount[ i ] = thingData[ 3 ]
        image:getChildByName( "text_number" ):setString( Lang.ui_activity_goddess2..thingData[ 2 ] )
        image:getChildByName( "text_get" ):setString( Lang.ui_activity_goddess3 .. thingData[ 4 ] .. Lang.ui_activity_goddess4 )
        image:getChildByName( "btn_send" ):setTitleText( Lang.ui_activity_goddess5 .. thingData[ 3 ] .. Lang.ui_activity_goddess6 )
    end 
end
local function refreshLoadingGoods()
    --//撩妹节点奖励信息 id|节点|节点箱子奖励|箱子状态(0-未打开 1-打开)/
    local curState = { 0 , 0 , 0 }
    local things = {}
    for i = 1 , 3 do
        things[ i ] = utils.stringSplit( _reward[ i ] , "|" )
        if tonumber( things[ i ][ 4 ] ) == 0 then
            curState[ i ] = 1
            if _score < tonumber( things[ i ][ 2 ] ) then
                curState[ i ] = 3
            end
        elseif tonumber( things[ i ][ 4 ] ) == 1 then
            curState[ i ] = 2
        end
    end
    local image_base_loading = ccui.Helper:seekNodeByName( UIActivityGoddess.Widget , "image_base_loading" )--进度条信息
    local bar_loading = image_base_loading:getChildByName( "bar_loading" )
    local x = bar_loading:getPositionX()
    local width = bar_loading:getContentSize().width
    local x1 = x - width / 2 + width * things[ 1 ][ 2 ] / things[ 3 ][ 2 ]
    local x2 = x - width / 2  + width * things[ 2 ][ 2 ] / things[ 3 ][ 2 ]
    local x3 = x - width / 2  + width * things[ 3 ][ 2 ] / things[ 3 ][ 2 ]
    local image_box_first = image_base_loading:getChildByName( "image_box_first" )
    image_box_first:setPositionX( x1 )
    image_box_first:removeChildByName( "effect" )
    --fb_bx.png
    if curState[ 1 ] == 1 then
        image_box_first:loadTexture( "ui/fb_bx_full.png" )
        local particle = cc.ParticleSystemQuad:create("particle/ui_anim_effect27.plist")
        particle:setPosition(cc.p(image_box_first:getContentSize().width / 2, image_box_first:getContentSize().height / 2))
        particle:setScale(1.5)
        particle:setName("effect")
        image_box_first:addChild( particle )
    elseif curState[ 1 ] == 2 then
        image_box_first:loadTexture( "ui/fb_bx_empty.png" )
    elseif curState[ 1 ] == 3 then
        image_box_first:loadTexture( "ui/fb_bx.png" )
    end
    local image_box_secend = image_base_loading:getChildByName( "image_box_secend" )
    image_box_secend:setPositionX( x2 )
    image_box_secend:removeChildByName( "effect" )
    if curState[ 2 ] == 1 then
        image_box_secend:loadTexture( "ui/fb_bx01_full.png" )
        local particle = cc.ParticleSystemQuad:create("particle/ui_anim_effect27.plist")
        particle:setPosition(cc.p(image_box_secend:getContentSize().width / 2, image_box_secend:getContentSize().height / 2))
        particle:setScale(1.5)
        particle:setName("effect")
        image_box_secend:addChild( particle )
    elseif curState[ 2 ] == 2 then
        image_box_secend:loadTexture( "ui/fb_bx01_empty.png" )
    elseif curState[ 2 ] == 3 then
        image_box_secend:loadTexture( "ui/fb_bx01.png" )
    end
    local image_box_three = image_base_loading:getChildByName( "image_box_three" ) 
    image_box_three:setPositionX( x3 )
    image_box_three:removeChildByName( "effect" )
    if curState[ 3 ] == 1 then
        image_box_three:loadTexture( "ui/fb_bx02_full.png" )
        local particle = cc.ParticleSystemQuad:create("particle/ui_anim_effect27.plist")
        particle:setPosition(cc.p(image_box_three:getContentSize().width / 2, image_box_three:getContentSize().height / 2))
        particle:setScale(1.5)
        particle:setName("effect")
        image_box_three:addChild( particle )
    elseif curState[ 3 ] == 2 then
        image_box_three:loadTexture( "ui/fb_bx02_empty.png" )
    elseif curState[ 3 ] == 3 then
        image_box_three:loadTexture( "ui/fb_bx02.png" )
    end

    local function onEvent( sender , eventType )
        if eventType == ccui.TouchEventType.ended then
            local curThings = nil
            local curEnabled = nil
            local curBtnTitleText = nil
            local state = 0
            local btnIndex = 0
            if sender == image_box_first then
                btnIndex = 1
            elseif sender == image_box_secend then
                btnIndex = 2
            elseif sender == image_box_three then
                btnIndex = 3
            end
            curThings = things[ btnIndex ][ 3 ]
            state = curState[ btnIndex ]
            if curThings then
                if state == 1 then
                    curEnabled = true
                    curBtnTitleText = Lang.ui_activity_goddess7
                elseif state == 2 then
                    curEnabled = true
                    curBtnTitleText = Lang.ui_activity_goddess8
                elseif state == 3 then
                    curEnabled = true
                    curBtnTitleText = Lang.ui_activity_goddess9
                end
                UIAwardGet.setOperateType(UIAwardGet.operateType.goddess, {
                            btnTitleText = curBtnTitleText,
                            enabled = curEnabled,
                            things = curThings ,
                            callbackFunc = function() 
                                if state == 1 then
                                    cclog("发协议领取")
                                    netSendPackage( { header = StaticMsgRule.teaseGirlReward , msgdata = { int = { id = btnIndex } } } , function ( pack )
                                         utils.showGetThings( curThings )
                                         UIActivityGoddess.setup()
                                    end)
                                else
                                    
                                end
                            end
                        } )
                UIManager.pushScene("ui_award_get")
            end
        end
    end
    image_box_first:setTouchEnabled( true )
    image_box_first:addTouchEventListener( onEvent )
    image_box_secend:setTouchEnabled( true )
    image_box_secend:addTouchEventListener( onEvent )
    image_box_three:setTouchEnabled( true )
    image_box_three:addTouchEventListener( onEvent )
    
    local image_first = image_base_loading:getChildByName( "image_first" )
    image_first:setPositionX( x1 )
    image_first:getChildByName( "text_number" ):setString( things[ 1 ][ 2 ] )
    local image_secend = image_base_loading:getChildByName( "image_secend" )
    image_secend:setPositionX( x2 )
    image_secend:getChildByName( "text_number" ):setString( things[ 2 ][ 2 ] )
    local image_three = image_base_loading:getChildByName( "image_three" )
    image_three:setPositionX( x3 )
    image_three:getChildByName( "text_number" ):setString( things[ 3 ][ 2 ] )

    local text_loading_now = image_base_loading:getChildByName( "text_loading_now" )
    text_loading_now:setString( Lang.ui_activity_goddess10.._score )
    image_base_loading:getChildByName( "bar_loading" ):setPercent( _score * 100 / things[ 3 ][ 2 ] )
end
local function refreshLoading( endNum , all )
    if _score >= endNum then
        UIActivityGoddess.setup()
        return
    end
    _score = _score + 1
    local image_base_loading = ccui.Helper:seekNodeByName( UIActivityGoddess.Widget , "image_base_loading" )--进度条信息
    local text_loading_now = image_base_loading:getChildByName( "text_loading_now" )
    local s = tonumber( _score )
    local function callF()      
        if s >= tonumber( endNum ) then
            text_loading_now:setScale( 1 )
            UIActivityGoddess.setup()
            return
        end
        text_loading_now:setScale( 1.5 )
        image_base_loading:getChildByName( "bar_loading" ):setPercent( s * 100 / all )
        text_loading_now:setString( Lang.ui_activity_goddess11..s )
        s = s + 1
        text_loading_now:runAction( cc.Sequence:create( cc.DelayTime:create( 0.02 ) , cc.CallFunc:create(
            callF
        ) ) )
    end
    callF()
end
local function showDialog()
    local dialog = ccui.Layout:create()
    dialog:setContentSize(UIManager.screenSize)
    dialog:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
    dialog:setBackGroundColor(cc.c3b(0, 0, 0))
    dialog:setBackGroundColorOpacity(130)
    dialog:setTouchEnabled(true)
    dialog:retain()
    local bg_image = cc.Scale9Sprite:create("ui/dialog_bg.png")
    bg_image:setAnchorPoint(cc.p(0.5, 0.5))
    bg_image:setPreferredSize(cc.size(450, 300))
    bg_image:setPosition(cc.p(UIManager.screenSize.width / 2, UIManager.screenSize.height / 2))
    dialog:addChild(bg_image)
    local bgSize = bg_image:getPreferredSize()

    local _fontSize, _fontColor = 25, cc.c3b(255, 255, 255)
    local title = ccui.Text:create()
    title:setString(Lang.ui_activity_goddess12)
    title:setFontName(dp.FONT)
    title:setFontSize(30)
    title:setTextColor(cc.c3b(255, 255, 0))
    title:setPosition(cc.p(bgSize.width / 2, bgSize.height * 0.85))
    bg_image:addChild(title)

    local dictData = DictThing[ tostring( StaticThing.flower ) ]
    local msgLabel = ccui.Text:create()
    msgLabel:setString(Lang.ui_activity_goddess13 .. utils.getThingCount( dictData.id ) )
    msgLabel:setFontName(dp.FONT)
    msgLabel:setTextAreaSize(cc.size(325, 200))
    msgLabel:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    msgLabel:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    msgLabel:setFontSize(_fontSize)
    msgLabel:setTextColor(_fontColor)
    msgLabel:setPosition(cc.p(bgSize.width / 2 + 40 , bgSize.height * 0.56))
    bg_image:addChild(msgLabel)

    local icon = ccui.ImageView:create( "image/" .. DictUI[ tostring( dictData.smallUiId ) ].fileName )
    icon:setPosition(cc.p(bgSize.width / 2 + 40 , bgSize.height * 0.56))
    bg_image:addChild(icon)

    local closeBtn = ccui.Button:create("ui/btn_x.png", "ui/btn_x.png")
    closeBtn:setPressedActionEnabled(true)
    closeBtn:setTouchEnabled(true)
    closeBtn:setPosition(cc.p(bgSize.width - closeBtn:getContentSize().width * 0.5, bgSize.height - closeBtn:getContentSize().height * 0.5))
    bg_image:addChild(closeBtn, 2)

    local sureBtn = ccui.Button:create("ui/tk_btn_red.png", "ui/tk_btn_red.png")
    sureBtn:setTitleText(Lang.ui_activity_goddess14)
    sureBtn:setTitleFontName(dp.FONT)
    sureBtn:setTitleColor(cc.c3b(255, 255, 255))
    sureBtn:setTitleFontSize(35)
    sureBtn:setPressedActionEnabled(true)
    sureBtn:setTouchEnabled(true)
    sureBtn:setPosition(cc.p(bgSize.width * 0.75, bgSize.height * 0.2))
    bg_image:addChild(sureBtn)
    local cancelBtn = ccui.Button:create("ui/tk_btn01.png", "ui/tk_btn01.png")
    cancelBtn:setTitleText(Lang.ui_activity_goddess15)
    cancelBtn:setTitleFontName(dp.FONT)
    cancelBtn:setTitleColor(cc.c3b(255, 255, 255))
    cancelBtn:setTitleFontSize(35)
    cancelBtn:setPressedActionEnabled(true)
    cancelBtn:setTouchEnabled(true)
    cancelBtn:setPosition(cc.p(bgSize.width * 0.25, bgSize.height * 0.2))
    bg_image:addChild(cancelBtn)
    local function btnEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            AudioEngine.playEffect("sound/button.mp3")
            UIManager.uiLayer:removeChild(dialog, true)
            cc.release(dialog)
            if sender == sureBtn then
               
               UISellProp.setData({ name = dictData.name , price = dictData.buyGold , thingId = StaticThing.flower }, UIActivityGoddess, function()
                        
               end )
               UIManager.pushScene("ui_sell_prop")
            elseif sender == cancelBtn then
                local openLv = DictFunctionOpen[tostring(StaticFunctionOpen.area)].level
                if net.InstPlayer.int["4"] < openLv then
                    UIManager.showToast(Lang.ui_activity_goddess16 .. openLv .. Lang.ui_activity_goddess17)
                    return
                end
                UIManager.hideWidget("ui_activity_time")
                UIManager.hideWidget("ui_team_info")
                UIManager.showWidget("ui_arena")
            elseif sender == closeBtn then
            end
        end
    end
    sureBtn:addTouchEventListener(btnEvent)
    cancelBtn:addTouchEventListener(btnEvent)
    closeBtn:addTouchEventListener(btnEvent)
    bg_image:setScale(0.1)
    UIManager.uiLayer:addChild(dialog, 10000)
    bg_image:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1.1), cc.ScaleTo:create(0.06, 1)))
end
local function sendFlower( index )
    local sendCount = _sendCount[ index ]
    local dictData = DictThing[ tostring( StaticThing.flower ) ]
    if tonumber( sendCount ) <= tonumber( utils.getThingCount( dictData.id ) ) then--送花
        netSendPackage( { header = StaticMsgRule.teaseGirl , msgdata = { int  = { id = _curPageViewIndex + 1 , gradeId = index } } } , function ( pack )
            local tempScore = _score + pack.msgdata.int[ "1" ]
            local things = utils.stringSplit( _reward[ 3 ] , "|" )
            refreshLoading( tempScore , tonumber( things[ 2 ] ) )
            utils.showGetThings( pack.msgdata.string[ "2" ] )
        end )
    else
        showDialog()
    end
end
function UIActivityGoddess.init()
    _page_beauty = ccui.Helper:seekNodeByName( UIActivityGoddess.Widget , "page_beauty" )
    _panel = _page_beauty:getChildByName( "panel" )
    _panel:retain()
    _scrollView = ccui.Helper:seekNodeByName( UIActivityGoddess.Widget , "view_info" )
    _item = _scrollView:getChildByName( "text_info" )
    _item:retain()
    local btn_r = ccui.Helper:seekNodeByName( UIActivityGoddess.Widget , "btn_r" )
    local btn_l = ccui.Helper:seekNodeByName( UIActivityGoddess.Widget , "btn_l" )
    local btn_help = ccui.Helper:seekNodeByName( UIActivityGoddess.Widget , "btn_help" )
    local image_get1 = ccui.Helper:seekNodeByName( UIActivityGoddess.Widget , "image_get1" )
    local btn_send1 = image_get1:getChildByName( "btn_send" )
    local image_get2 = ccui.Helper:seekNodeByName( UIActivityGoddess.Widget , "image_get2" )
    local btn_send2 = image_get2:getChildByName( "btn_send" )
    local image_get3 = ccui.Helper:seekNodeByName( UIActivityGoddess.Widget , "image_get3" )
    local btn_send3 = image_get3:getChildByName( "btn_send" )
    local function onEvent( sender , eventType )
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_r then
                local curIndex = _page_beauty:getCurPageIndex()
                if curIndex >= #_data then
                    --"不动了"
                else                
                    _page_beauty:scrollToPage( _page_beauty:getCurPageIndex() + 1 )
                end
            elseif sender == btn_l then
                local curIndex = _page_beauty:getCurPageIndex()
                if curIndex <= 0 then
                    --"不动了"
                else
                    _page_beauty:scrollToPage( _page_beauty:getCurPageIndex() - 1 )
                 end
            elseif sender == btn_help then
                UIAllianceHelp.show({titleName=Lang.ui_activity_goddess18,type=29})
            elseif sender == btn_send1 then--99
                sendFlower( 1 )
            elseif sender == btn_send2 then--520
                sendFlower( 2 )
            elseif sender == btn_send3 then--1314
                sendFlower( 3 )
            end
        end
    end
    btn_r:setPressedActionEnabled( true )
    btn_r:addTouchEventListener( onEvent )
    btn_l:setPressedActionEnabled( true )
    btn_l:addTouchEventListener( onEvent )
    btn_help:setPressedActionEnabled( true )
    btn_help:addTouchEventListener( onEvent )
    btn_send1:setPressedActionEnabled( true )
    btn_send1:addTouchEventListener( onEvent )
    btn_send2:setPressedActionEnabled( true )
    btn_send2:addTouchEventListener( onEvent )
    btn_send3:setPressedActionEnabled( true )
    btn_send3:addTouchEventListener( onEvent )

    local function pageViewEvent(sender, eventType)
	    if eventType == ccui.PageViewEventType.turning and _curPageViewIndex ~= sender:getCurPageIndex() then
            setData( sender:getCurPageIndex() )
        end
    end
    _page_beauty:addEventListener( pageViewEvent )

    --飘花
    local function createFlowerParticle()
        local node = cc.Node:create()
        local flower = cc.ParticleSystemQuad:create("particle/flower/sy_huaban_1.plist")
        node:addChild(flower)
        node:setName("flower")
        node:setPosition(cc.p(UIManager.screenSize.width / 2 , UIManager.screenSize.height - 50 ))
        UIActivityGoddess.Widget:addChild(node, 100000 )
        node:setVisible( false )
    end
    createFlowerParticle()
end
function UIActivityGoddess.setup()
    local startTime , endTime = _params.string["4"] , _params.string["5"]   
    local timeData = utils.changeTimeFormat( startTime )
    local timeData1 = utils.changeTimeFormat( endTime )
    local text_refresh_time = ccui.Helper:seekNodeByName( UIActivityGoddess.Widget , "image_title" )
    text_refresh_time:getChildByName("text_countdown"):setString( Lang.ui_activity_goddess19..timeData[2]..Lang.ui_activity_goddess20..timeData[3]..Lang.ui_activity_goddess21..timeData[4]..Lang.ui_activity_goddess22..timeData1[2]..Lang.ui_activity_goddess23..timeData1[3]..Lang.ui_activity_goddess24..timeData1[4]..Lang.ui_activity_goddess25 )  

    UIManager.showLoading()
    netSendPackage( { header = StaticMsgRule.intoTeaseGirl , msgdata = {} } , function ( pack )
        _data = utils.stringSplit( pack.msgdata.string["1"] , "/" )
        _score = pack.msgdata.int["3"]
   --     _page_beauty:scrollToPage( 1 )
        _page_beauty:removeAllPages()
        _curPageViewIndex = -1
        setData( _page_beauty:getCurPageIndex() )
        local girlState = utils.stringSplit( pack.msgdata.string["5"] , ";" )
        local function inState( i )
            for key ,value in pairs ( girlState ) do
                if tonumber( value ) == i then
                    return true
                end
            end
            return false
        end
        for key ,value in pairs( _data ) do
            local pageView = _panel:clone()
            local things = utils.stringSplit( value , "|" )
            pageView:getChildByName( "image_beauty" ):loadTexture( "image/" .. DictUI[ tostring( DictCard[ tostring( things[ 2 ] ) ].bigUiId ) ].fileName )
            ccui.Helper:seekNodeByName( pageView , "text_name" ):setString( DictCard[ tostring( things[ 2 ] ) ].name )
            local anim = nil
            if inState( tonumber( things[ 2 ] ) ) then
                anim = getAnimation( 1 )
                anim:setPositionX( pageView:getContentSize().width / 2 - 70 )
            else 
                anim = getAnimation( 0 )
                anim:setPositionX( pageView:getContentSize().width / 2 )
            end
            anim:getAnimation():playWithIndex( 0 )
            anim:setName("effect")
            
            pageView:addChild( anim )
            _page_beauty:addPage( pageView )
        end
        _rankData = utils.stringSplit( pack.msgdata.string["4"] , "/" )
        refreshView()
        _reward = utils.stringSplit( pack.msgdata.string["2"] , "/" )
        refreshLoadingGoods()
    end)
end
function UIActivityGoddess.free()
    _data = nil
    _rankData = nil
    _score = nil
    _curPageViewIndex = nil
    _reward = nil
    _params = nil
    _sendCount = nil
end
function UIActivityGoddess.onActivity(params) 
    _params = params
end
function UIActivityGoddess.showFlower()
    if UIActivityGoddess.Widget and UIActivityGoddess.Widget:getParent() then
        local effect = UIActivityGoddess.Widget:getChildByName( "flower" )
        if effect:isVisible() then
            effect:stopAllActions()
            effect:runAction( cc.Sequence:create( cc.DelayTime:create( 5 ) , cc.Hide:create() ) )
        else
            effect:setVisible( true )
            effect:runAction( cc.Sequence:create( cc.DelayTime:create( 5 ) , cc.Hide:create() ) )
        end
    end
end
