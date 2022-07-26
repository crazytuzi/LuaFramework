require"Lang"
UIAllianceRun = {}
local userData = nil
local scrollView = nil
local _item = nil
local DEBUG = false --测试流程
local _schedulerId = nil
local _schedulerId1 = nil
local _startTime = nil
local text_time = nil
local chooseIndex = nil -- 选择的乌龟
local state = nil --状态
local dialogCount = nil
local eventData = nil
local _itemChooseIndex = nil --选择使用的道具
local _itemCount = nil --道具数量
local _distance = nil --距离
local _speed = nil --次数
local _winCount = nil--胜利次数
local _failCount = nil--失败次数
local _itemGoods = nil
local _times = nil--场次
local _preWin = nil --上次的胜利者
local _suppurtInfo = nil--支持的乌龟信息
local _positionCount = nil --支持的最大数量
local aniResult = nil --胜利动画
local resultP = nil --胜利的例子效果
local sendType = {
    ENTER = 1 ,
    SIGN = 2 ,
    START = 3 ,
    QUIT = 4
}
local allState = {
    SIGN = 1 ,
    SIGNED = 2 ,
    START =3 ,
    END = 4 ,
    OTHER = 5
}
local name = {
    Lang.ui_alliance_run1 ,
    Lang.ui_alliance_run2 ,
    Lang.ui_alliance_run3 ,
    Lang.ui_alliance_run4
}
local _dialog = nil
--获取小龟特效动画
local function getEffectAnimation( index )
    local animPath = "ani/fm_xiaogui_shijian/"
    ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animPath .. "fm_xiaogui_shijian.ExportJson")
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(animPath .. "fm_xiaogui_shijian.ExportJson")
    local animation = ccs.Armature:create("fm_xiaogui_shijian")
    animation:getAnimation():playWithIndex( index )
    local function onMovementEvent(armature, movementType, movementID)
        if movementType == ccs.MovementEventType.complete or movementType == ccs.MovementEventType.loopComplete then
            armature:getAnimation():stop()
            armature:removeFromParent()
        end
    end
    if index == 0 then --加速特效
        animation:setPosition( cc.p( 15 , 45 ) )
    elseif index == 1 then --黑线
        animation:setPosition( cc.p( 90 , 90 ) )
    elseif index == 2 then --火箭加速器
        animation:setPosition( cc.p( 50 , 45 ) )
    elseif index == 3 then --闪电
        animation:setPosition( cc.p( 60 , 60 ) )
    elseif index == 4 then --警车
        animation:setPosition( cc.p( 160 , 45 ) )
    elseif index == 5 then --兽夹
        animation:setPosition( cc.p( 35 , 40 ) )
    elseif index == 6 then --风火轮
        animation:setPosition( cc.p( 40 , 40 ) )
    elseif index == 7 then --粑粑
        animation:setPosition( cc.p( 45 , 55 ) )
    end
    animation:getAnimation():setMovementEventCallFunc(onMovementEvent)
    return animation
end
--获取小龟胜利动画
local function getResultAnimation()
    local animPath = "ani/ui_anim/fm_xiaogui_shengli/"
    ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animPath .. "fm_xiaogui_shengli.ExportJson")
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(animPath .. "fm_xiaogui_shengli.ExportJson")
    local animation = ccs.Armature:create("fm_xiaogui_shengli")
    animation:getAnimation():playWithIndex( 0 )
    return animation
end
local function getShowP()
    local emitter = cc.ParticleSnow:createWithTotalParticles(100)
      --  emitter:setTag(weather)
        emitter:setPosition( display.width / 2, display.height / 2 )
        emitter:setLife(6)
        emitter:setLifeVar(2)

      --  emitter:setRotatePerSecond( 360 )
      --  emitter:setRotatePerSecondVar( 10 )
        -- gravity
        emitter:setGravity(cc.p(0, -8))

        emitter:setStartSize(20)

        -- speed of particles
        emitter:setSpeed(130)
        emitter:setSpeedVar(30)

        local startColor = emitter:getStartColor()
        startColor.r = 0.9
        startColor.g = 0.9
        startColor.b = 0.9
        emitter:setStartColor(startColor)

        local startColorVar = emitter:getStartColorVar()
        startColorVar.b = 0.1
        emitter:setStartColorVar(startColorVar)

        emitter:setEmissionRate(emitter:getTotalParticles() / emitter:getLife())
        emitter:setTexture(cc.Director:getInstance():getTextureCache():addImage("ani/ui_anim/fm_xiaogui_shengli/fm_xiaogui_xx.png"))
        return emitter
end
local function playEffectAction( index , actionIndex )
    local image_basemap = ccui.Helper:seekNodeByName( UIAllianceRun.Widget , "image_basemap" )
    local ani = image_basemap:getChildByName( "an"..index )
    local action = 0
    if actionIndex == 1 then
        action = 6
    elseif actionIndex == 2 then
        action = 4
    elseif actionIndex == 3 then
        action = 2
    elseif actionIndex == 4 then
        action = 3
    elseif actionIndex == 5 then
        action = 7
    elseif actionIndex == 6 then
        action = 5
    end
    local aaa = ani:getChildByName( "effect" )
    if aaa then
        aaa:removeFromParent()
    end
    local anni = getEffectAnimation( action )
    anni:setName( "effect" )
    ani:addChild( anni , 1 )
end
--获取动画
local function getAnimation( uiAnimId , index )
    local animPath = "ani/ui_anim/ui_anim"..uiAnimId.."/"
    ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(animPath .. "ui_anim" .. uiAnimId .. ".ExportJson")
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(animPath .. "ui_anim" .. uiAnimId .. ".ExportJson")
    local animation = ccs.Armature:create("ui_anim" .. uiAnimId)
    animation:getAnimation():playWithIndex( index )
    return animation
end
local function getTimeFormat( count )
    local time = {}
    time[ 1 ] = string.format( "%02d" , math.floor( count / 3600 / 24 ) )   --天
    time[ 2 ] = string.format( "%02d" , math.floor( count / 3600 % 24 ) ) --时
    time[ 3 ] = string.format( "%02d" , math.floor( count / 60 % 60 ) ) --分
    time[ 4 ] = string.format( "%02d" , math.floor( count % 60 ) ) --秒
    return time
end
--小龟跑动
local function updateTime1()
    local image_basemap = ccui.Helper:seekNodeByName( UIAllianceRun.Widget , "image_basemap" )
    for i = 1 , 4 do
        local an = image_basemap:getChildByName( "an"..i )
--        an:setPositionX( 150 + _distance[ i ] )
--                cclog( "_distance :" .. _distance[ i ] )  
        _distance[ i ] = _distance[ i ] + _speed[ i ] * 500 / 5000  
        if _distance[ i ] >= 500 then
            _distance[ i ] = 495
        end       
        an:stopAllActions()      
        an:runAction( cc.MoveTo:create( 1 , cc.p( 100 + _distance[ i ] , an:getPositionY() ) ) )
        an:getChildByName("animation"):getAnimation():setSpeedScale( _speed[ i ] * _speed[ i ] / 120 / 120 )
    end
end
local function resetPosition()
    local image_basemap = ccui.Helper:seekNodeByName( UIAllianceRun.Widget , "image_basemap" )
    for i = 1 , 4 do
        local an = image_basemap:getChildByName( "an"..i )
        an:stopAllActions()
        an:setPositionX( 100 + _distance[ i ] ) 
        an:getChildByName("animation"):getAnimation():setSpeedScale( 0 )
    end

    local text_hint = image_basemap:getChildByName( "text_hint" )
    if _result == 1 then
        text_hint:setVisible( true )
        text_hint:setString( Lang.ui_alliance_run5.. name[ _preWin ]..Lang.ui_alliance_run6 )
        aniResult:setVisible( true )
        local ann = image_basemap:getChildByName( "an".._preWin )
        aniResult:setPosition( cc.p( ann:getPositionX() - 70 , ann:getPositionY() + 20 ) )
        text_hint:setPositionY( ann:getPositionY() )
    else
        text_hint:setVisible( false )
        aniResult:setVisible( false )
    end
end
--开始
local function updateTime()
    if _startTime then
        local timeCount = _startTime - utils.getCurrentTime()
        if timeCount > 0 then
            local timeData = getTimeFormat( timeCount )         
            text_time:setString( Lang.ui_alliance_run7..timeData[2]..":"..timeData[3]..":"..timeData[4] )
        else
            text_time:setString( Lang.ui_alliance_run8 )
        end
        if timeCount == 0 and _schedulerId then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry( _schedulerId )
            _schedulerId = nil
        end
    end  
end
--刷新乌龟位置
local function refreshPosition( p1 , p2 , p3 )

end
--刷新胜利失败
local function refreshResultInfo()
    local image_scale = ccui.Helper:seekNodeByName( UIAllianceRun.Widget , "image_scale" )
    for i = 1 , 3 do--run_hui.png
        local failIcon = image_scale:getChildByName( "image_fail_heart"..i )--run_green.png
        if _failCount and i <= _failCount then
            failIcon:loadTexture( "ui/run_green.png" )
        else
            failIcon:loadTexture( "ui/run_hui.png" )
        end
        local winIcon = image_scale:getChildByName( "image_win_heart"..i ) --run_red.png
        if _winCount and i <= _winCount then
            winIcon:loadTexture( "ui/run_red.png" )
        else
            winIcon:loadTexture( "ui/run_hui.png" )
        end
    end
    local image_box_fail = image_scale:getChildByName( "image_box_fail" )
   -- local dictData = utils.getItemProp( _itemGoods[ 3 ] )
  --  utils.showThingsInfo( image_box_fail , dictData.tableTypeId , dictData.tableFieldId )
    local image_box_win = image_scale:getChildByName( "image_box_win" )
  --  local dictData1 = utils.getItemProp( _itemGoods[ 4 ] )
 --   utils.showThingsInfo( image_box_win , dictData1.tableTypeId , dictData1.tableFieldId )
    local function onEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == image_box_win then
                UIAwardGet.setOperateType(UIAwardGet.operateType.dailyTaskBox, {
                    btnTitleText = "",
                    enabled = true,
                    things = _itemGoods[ 4 ]
                }, UIAllianceRun)
                UIManager.pushScene("ui_award_get")
            elseif sender == image_box_fail then
                UIAwardGet.setOperateType(UIAwardGet.operateType.dailyTaskBox, {
                    btnTitleText = "",
                    enabled = true,
                    things = _itemGoods[ 3 ]
                }, UIAllianceRun)
                UIManager.pushScene("ui_award_get")
            end
         end
    end
    image_box_fail:setTouchEnabled( true )
    image_box_fail:addTouchEventListener( onEvent )
    image_box_win:setTouchEnabled( true )
    image_box_win:addTouchEventListener( onEvent )
end
--走动还是停止 1:停止 2：走动
local function runActionType( type )
   
end

local function setViewItem( item , data )
    --动作类型 1-风火轮 2-香蕉皮 3-雷劈 4-掉坑 5-看到兔子
    local thing = utils.stringSplit( data , "_" )
    local str = ""
    local actionType = tonumber( thing[2] )
    if actionType == 1 then
        str = name[ tonumber(thing[ 1 ]) ].. Lang.ui_alliance_run9
    elseif actionType == 2 then
        str = name[ tonumber(thing[ 1 ]) ].. Lang.ui_alliance_run10
    elseif actionType == 3 then
        str = name[ tonumber(thing[ 1 ]) ].. Lang.ui_alliance_run11
    elseif actionType == 4 then
        str = name[ tonumber(thing[ 1 ]) ].. Lang.ui_alliance_run12
    elseif actionType == 5 then
        str = name[ tonumber(thing[ 1 ]) ].. Lang.ui_alliance_run13
    elseif actionType == 6 then
        str = name[ tonumber(thing[ 1 ]) ].. Lang.ui_alliance_run14
    end

    item:setString( "·"..str )
end
--刷新内容
local function refreshScrollView( data )
    scrollView:removeAllChildren()   
    utils.updateScrollView( UIAllianceRun , scrollView , _item , data , setViewItem , { noAction = 1 , jumpTo = 0 , bottomSpace = 50 })
   -- scrollView:scrollToBottom( 0.1 , false )
end
--刷新上期排名
local function refreshBank( top )
    
end
--刷新道具信息 --道具index
local function refreshItemInfo( index )   
    local image_basemap = ccui.Helper:seekNodeByName( UIAllianceRun.Widget , "image_basemap" )
    local image_di = image_basemap:getChildByName( "image_di" )
    local image_base_number = image_di:getChildByName( "image_base_number" )
    local text_number = image_base_number:getChildByName( "text_number" )
    text_number:setString(tostring(_itemCount))
    if not index then
    else
        local image_frame_good1 = image_di:getChildByName( "image_frame_good1" )--
        local checkBox1 = image_frame_good1:getChildByName( "checkbox_practice" )
        local image_frame_good2 = image_di:getChildByName( "image_frame_good2" )--
        local checkBox2 = image_frame_good2:getChildByName( "checkbox_practice" )
        _itemChooseIndex = index
        if _itemChooseIndex == 1 then
            checkBox1:setSelected( true )
            checkBox2:setSelected( false )
        elseif _itemChooseIndex == 2 then
            checkBox1:setSelected( false )
            checkBox2:setSelected( true )
        end
    end
end
--刷新切换各情况下的控件信息
local function refreshInfo( type )
    local image_basemap = ccui.Helper:seekNodeByName( UIAllianceRun.Widget , "image_basemap" )
    local image_di = image_basemap:getChildByName( "image_di" )
    local text_title = image_di:getChildByName( "text_title" ) --上届冠军：一二三四五六七八
    local image_frame_good1 = image_di:getChildByName( "image_frame_good1" )--
    local image_frame_good2 = image_di:getChildByName( "image_frame_good2" )--
    local text_use = image_di:getChildByName( "text_use" ) --请在上方选择支持的小龟，并在下方选择支持的数量
    local btn_enroll = image_di:getChildByName( "btn_enroll" )
    local text_hint = image_di:getChildByName( "text_hint" )--您已经支持3号小龟米开朗基罗
    local text_good = image_di:getChildByName( "text_good" )--当前投注：20000慕骨老人碎片
    local image_di_info = image_di:getChildByName( "image_di_info" ) 
    
    if _preWin and _preWin > 0 then
        text_title:setString( Lang.ui_alliance_run15 .. name[ _preWin ] )
    else
        text_title:setString( Lang.ui_alliance_run16 )
    end
    --选择数量
    local image_base_number = image_di:getChildByName( "image_base_number" )
    local text_number = image_base_number:getChildByName( "text_number" )
    if type == sendType.ENTER then
        local dictData = utils.getItemProp( _itemGoods[ 1 ] )
        image_frame_good1:getChildByName("image_good"):loadTexture( dictData.smallIcon )
        image_frame_good1:getChildByName("text_number"):setString( dictData.count )
        utils.addBorderImage( dictData.tableTypeId , dictData.tableFieldId , image_frame_good1 )
        utils.showThingsInfo( image_frame_good1 , dictData.tableTypeId , dictData.tableFieldId )
        local dictData1 = utils.getItemProp( _itemGoods[ 2 ] )
        image_frame_good2:getChildByName("image_good"):loadTexture( dictData1.smallIcon )
        image_frame_good2:getChildByName("text_number"):setString( dictData1.count )
        utils.addBorderImage( dictData1.tableTypeId , dictData1.tableFieldId , image_frame_good2 )
        utils.showThingsInfo( image_frame_good2 , dictData1.tableTypeId , dictData1.tableFieldId )
        text_title:setVisible( true )               
        image_di_info:setVisible( false )       
        refreshItemInfo( 1 )
        btn_enroll:setTitleText( Lang.ui_alliance_run17 )
        if state == allState.OTHER or state == allState.SIGN then
            if state == allState.OTHER then
                btn_enroll:setTitleText( Lang.ui_alliance_run18 )
            end
            text_time:setVisible( false )
            btn_enroll:setVisible( true )
            image_base_number:setVisible( true )
            image_frame_good1:setVisible( true )
            image_frame_good2:setVisible( true )
            
            text_hint:setVisible( false )
            text_good:setVisible( false )
            text_use:setVisible( true )
        elseif state == allState.SIGNED then       
            text_time:setVisible( true )
            btn_enroll:setVisible( false )
            image_base_number:setVisible( false )
            image_frame_good1:setVisible( false )
            image_frame_good2:setVisible( false )
            text_hint:setVisible( true )
            if _suppurtInfo and _suppurtInfo[ 1 ] then
                text_hint:setString( Lang.ui_alliance_run19..name[ _suppurtInfo[ 1 ] ] )
                text_good:setVisible( true )
                local dictData = utils.getItemProp( _suppurtInfo[ 2 ] )
                text_good:setString( Lang.ui_alliance_run20.. dictData.name.."".. dictData.count .. "x" .. _suppurtInfo[ 3 ] .."" )
            else
                text_hint:setString( Lang.ui_alliance_run21 )
                text_good:setVisible( false )
            end           
            text_use:setVisible( false )
            _schedulerId = cc.Director:getInstance():getScheduler():scheduleScriptFunc( updateTime , 1 , false )
        end       
        resetPosition()
    elseif type == sendType.START then     
        image_frame_good1:setVisible( false )
        image_frame_good2:setVisible( false )
        text_use:setVisible( false )
        text_time:setVisible( false )
        text_hint:setVisible( false )
        text_good:setVisible( false )
        image_di_info:setVisible( true )
        image_base_number:setVisible( false )
        btn_enroll:setVisible( false )
        refreshScrollView( eventData )
        if _schedulerId then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry( _schedulerId )
            _schedulerId = nil
        end        
        if _result == 1 then
            if _schedulerId1 then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry( _schedulerId1 )
                _schedulerId1 = nil
            end
            resetPosition()
        elseif not _schedulerId1 then
            _schedulerId1 = cc.Director:getInstance():getScheduler():scheduleScriptFunc(updateTime1, 1, false)
        end
    elseif type == sendType.END then
     
    end
end

--获取要说的话 item:道具
local function getDialogStr( index , item )
    local str = ""    
    if dialogCount and dialogCount[ index ] >= 5 then
        str = _dialog[ 3 ][ utils.random( 1 , #_dialog[ 3 ] ) ].description
    else
        dialogCount[ index ] = dialogCount[ index ] + 1
        if chooseIndex and chooseIndex == index then
            str = _dialog[ 1 ][ utils.random( 1 , #_dialog[ 1 ] ) ].description
        else
            str = _dialog[ 2 ][ utils.random( 1 , #_dialog[ 2 ] ) ].description
        end
    end
    return str
end
--气泡字 en：是否隐藏 item:使用道具id
local function showDialog( index , en , item )
    if DEBUG then
        UIAllianceRun.pushData( { tor1 = math.random( 1 , 3) , tor2 = math.random( 1 , 3) , tor3 = math.random( 1 , 3) , records = "a;b;c;d" } )
    end
    chooseIndex = index
    local image_basemap = ccui.Helper:seekNodeByName( UIAllianceRun.Widget , "image_basemap" )
    for i = 1 , 4 do
        local jianTou = image_basemap:getChildByName( "an"..i ):getChildByName( "jianTou" )
        if chooseIndex == i then
            jianTou:setVisible( true )
        else
            jianTou:setVisible( false )
        end
    end
    if index == 0 then
        return
    end
    local ani = image_basemap:getChildByName( "an"..chooseIndex )
 --   if item then
 --       local anni = getEffectAnimation( 7 )
 --       ani:addChild( anni , 1 )
 --   end
    local textNode = ani:getChildByName( "t" )
    if en then
        textNode:setVisible( false )
        return
    end
--    if not textNode:isVisible() then
        textNode:setVisible( true )
        textNode:setScale( 0.1 )
        local text = textNode:getChildByTag( 1 )
        text:removeElement( 0 )
        local str = getDialogStr( chooseIndex , item )
        text:pushBackElement(ccui.RichElementText:create(1, cc.c3b(61, 19, 10), 255, str , dp.FONT, 24))
        local bg = textNode:getChildByTag( 2 ) 
        local lable = cc.Label:createWithSystemFont( str , dp.FONT , 24 )
       -- cclog( "str length : "..lable:getContentSize().width )     
        bg:setContentSize( cc.size( lable:getContentSize().width + 20 , bg:getContentSize().height ) )
        text:setPosition( cc.p( lable:getContentSize().width / 2 + 15 , text:getPositionY() ) )
        textNode:stopAllActions()
        textNode:runAction( cc.Sequence:create( cc.ScaleTo:create( 0.2 , 1 ) , cc.DelayTime:create( 2.0 ) , cc.ScaleTo:create( 0.2 , 0.1 ) , cc.Hide:create()
--        cc.CallFunc:create(
--            function( )
--                textNode:setVisible( false )
--            end 
--        ) 
            )
         )
--    else

--    end       
end
local function getTimer(curTime, hour, minute)
    local _date = os.date("*t", curTime)
    _date.hour = hour
    if minute then
        _date.min = minute
    else
        _date.min = 0
    end
    _date.sec = 0
    return os.time(_date)
end
local function callBack( pack )
    if DEBUG then
        if pack.header == sendType.ENTER then
            state = allState.SIGN
        elseif pack.header == sendType.SIGN then
            if state ~= allState.START then
                state = allState.SIGNED
            end
        end
        refreshInfo( sendType.START )
        refreshResultInfo()
        return
    end
    if pack.header == StaticMsgRule.openTurtlePanel then
        _itemGoods[ 3 ] = pack.msgdata.message.alldaoju.string["4"]
        _itemGoods[ 4 ] = pack.msgdata.message.alldaoju.string["3"]
        _itemGoods[ 1 ] = pack.msgdata.message.alldaoju.string["1"]
        _itemGoods[ 2 ] = pack.msgdata.message.alldaoju.string["2"]
        _failCount = pack.msgdata.int.failcount
        _winCount = pack.msgdata.int.successcount
        _times = pack.msgdata.int.changci
        local _curTime = utils.getCurrentTime()
        if _times == 1 then
            _startTime = getTimer(_curTime, 11 , 30 ) 
        elseif _times == 2 then
            _startTime = getTimer(_curTime, 18 , 30 )
        elseif _times == 3 then
            _startTime = getTimer(_curTime, 21 , 30 )
        end
        _preWin = pack.msgdata.int.successTurtleId
        _suppurtInfo = {}
        _suppurtInfo[ 1 ] = pack.msgdata.int.betturtleId
        _suppurtInfo[ 2 ] = pack.msgdata.string.betdaoju
        _suppurtInfo[ 3 ] = pack.msgdata.int.betdaojuCount
        _positionCount = {}
        _positionCount[ 1 ] = pack.msgdata.int.position1
        _positionCount[ 2 ] = pack.msgdata.int.position2
        if pack.msgdata.int.openState == 0 then
            state = allState.OTHER
        else
            if pack.msgdata.int.applyTimeState == 0 then
                state = allState.OTHER
            else
                if pack.msgdata.int.applyState == 0 then
                    state = allState.SIGN
                else
                    state = allState.SIGNED
                end
            end
        end
        if pack.msgdata.int.matching == 1 then
            state = allState.START
        end
        if state == allState.START then
            _result = pack.msgdata.message.matchinfo.int.matchResult

            _distance[ 1 ] = pack.msgdata.message.matchinfo.int.turtleCount1 * 500 / 5000
            _distance[ 2 ] = pack.msgdata.message.matchinfo.int.turtleCount2 * 500 / 5000
            _distance[ 3 ] = pack.msgdata.message.matchinfo.int.turtleCount3 * 500 / 5000
            _distance[ 4 ] = pack.msgdata.message.matchinfo.int.turtleCount4 * 500 / 5000
            if _result == 1 then
                _speed[ 1 ] = 0
                _speed[ 2 ] = 0
                _speed[ 3 ] = 0
                _speed[ 4 ] = 0
                aniResult:getAnimation():playWithIndex( 1 )
              --  aniResult:getAnimation():setMovementEventCallFunc(nil)
                for i = 1 , 4 do
                    if i == _preWin then
                    elseif _distance[ i ] >= 500 then
                        _distance[ i ] = 495
                    end
                end
            else
                _speed[ 1 ] = pack.msgdata.message.matchinfo.int.fiveSpeed1 + pack.msgdata.message.matchinfo.int.sevenSpeed1
                _speed[ 2 ] = pack.msgdata.message.matchinfo.int.fiveSpeed2 + pack.msgdata.message.matchinfo.int.sevenSpeed2
                _speed[ 3 ] = pack.msgdata.message.matchinfo.int.fiveSpeed3 + pack.msgdata.message.matchinfo.int.sevenSpeed3
                _speed[ 4 ] = pack.msgdata.message.matchinfo.int.fiveSpeed4 + pack.msgdata.message.matchinfo.int.sevenSpeed4
            end

            local eventDataThings = pack.msgdata.string.matchrecord
            if eventDataThings then
                local event = utils.stringSplit( eventDataThings , ";" )
                for key , value in pairs ( event ) do
                    local data = utils.stringSplit( value , ":" )
                    if tonumber( data[ 2 ] ) == 1 then
                        table.insert( eventData , 1 , data[ 1 ].."_"..( 3 + tonumber( data[ 3 ] ) ) )
                    else
                        table.insert( eventData , 1 , data[ 1 ].."_"..data[ 3 ] )
                    end
                end
            end
            refreshInfo( sendType.START )
        else
            refreshInfo( sendType.ENTER )
        end        
        refreshResultInfo()
    elseif pack.header == StaticMsgRule.supportTrutleBet then
        UIAllianceRun.setup()
    elseif pack.header == StaticMsgRule.closeTrutlePanel then
        if not userData then
            UIManager.showWidget("ui_activity_time")
            UIManager.showWidget("ui_menu")
            UIActivityTime.jumpName("run")                    
        else
            UIAllianceActivity.show(userData)
        end        
    end

end
local function netSendData( type , data )
    if DEBUG then        
        callBack( { header = type } )
        return 
    end
    local sendData = nil
    if type == sendType.ENTER then
        sendData = {
            header = StaticMsgRule.openTurtlePanel ,
            msgdata = {}
        }
    elseif type == sendType.SIGN then
        sendData = {
            header = StaticMsgRule.supportTrutleBet ,
            msgdata = {
                int = {                   
                    betcount = _itemCount ,
                    betposition = _itemChooseIndex ,
                    turtleId = chooseIndex
                } ,
                string = {
                    betthings = _itemGoods[ _itemChooseIndex ] 
                }
            }
        }
    elseif type == sendType.QUIT then
        sendData = {
            header = StaticMsgRule.closeTrutlePanel ,
            msgdata = {}
        }
    end
    UIManager.showLoading()
    netSendPackage( sendData , callBack )
end
function UIAllianceRun.init()
    local btn_back = ccui.Helper:seekNodeByName( UIAllianceRun.Widget , "btn_back" )
    local btn_help = ccui.Helper:seekNodeByName( UIAllianceRun.Widget , "btn_help" )
    local btn_enroll = ccui.Helper:seekNodeByName( UIAllianceRun.Widget , "btn_enroll" )
    local btn_rank = ccui.Helper:seekNodeByName( UIAllianceRun.Widget , "btn_rank" )
    local animation = {}
    local aniImage = {}
    for i = 1 , 4 do
        aniImage[ i ] = ccui.ImageView:create( "ui/run_win.png")
        animation[ i ] = getAnimation( 69 , 0 )
        animation[ i ]:getBone("tou"):addDisplay(ccs.Skin:create("ani/ui_anim/ui_anim69/tou"..i..".png"), 0)
    end
    local image_basemap = ccui.Helper:seekNodeByName( UIAllianceRun.Widget , "image_basemap" )

    local image_di = image_basemap:getChildByName( "image_di" )
    local image_frame_good1 = image_di:getChildByName( "image_frame_good1" )--道具1
    local checkBox1 = image_frame_good1:getChildByName( "checkbox_practice" )
    local image_frame_good2 = image_di:getChildByName( "image_frame_good2" )--道具2
    local checkBox2 = image_frame_good2:getChildByName( "checkbox_practice" )
    --选择数量
    local image_base_number = image_di:getChildByName( "image_base_number" )
    local btn_cut_ten = image_base_number:getChildByName( "btn_cut_ten" )--min
    local btn_cut = image_base_number:getChildByName( "btn_cut" )-- -1
    local btn_add_ten = image_base_number:getChildByName( "btn_add_ten" ) -- max
    local btn_add = image_base_number:getChildByName( "btn_add" ) -- +1
    local function onEvent( sender , eventType )
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_back then
                netSendData( sendType.QUIT )                                         
            elseif sender == btn_help then
                UIAllianceHelp.show( { type = 25 , titleName = Lang.ui_alliance_run22 } )
            elseif sender == btn_enroll then
                if state and state == allState.OTHER then
                    UIManager.showToast( Lang.ui_alliance_run23 )
                elseif not chooseIndex or ( chooseIndex and chooseIndex <= 0 )then
                    UIManager.showToast( Lang.ui_alliance_run24 )
                elseif not _itemChooseIndex then
                    UIManager.showToast( Lang.ui_alliance_run25 )
                elseif _itemCount <= 0 then
                    UIManager.showToast( Lang.ui_alliance_run26 )
                else
                    netSendData( sendType.SIGN )
                end
            elseif sender == aniImage[ 1 ] then
               -- cclog( "第一只乌龟" )
                showDialog( 1 )
            elseif sender == aniImage[ 2 ] then
               -- cclog( "第二只乌龟" )
                showDialog( 2 )
            elseif sender == aniImage[ 3 ] then
                --cclog( "第三只乌龟" )
                showDialog( 3 )  
            elseif sender == aniImage[ 4 ] then  
                showDialog( 4 )     
            elseif sender == btn_cut_ten then
                _itemCount = _itemCount - 1000
                if _itemCount <= 0 then
                    _itemCount = 0
                end
                refreshItemInfo()
            elseif sender == btn_cut then
                _itemCount = _itemCount - 1
                if _itemCount <= 0 then
                    _itemCount = 0
                end
                refreshItemInfo()
            elseif sender == btn_add_ten then
                --_itemCount = _itemCount + 10
                local dictData = utils.getItemProp( _itemGoods[ _itemChooseIndex ] , false , true )
                --cclog( " count :"..dictData.playerCount )
                _itemCount = dictData.playerCount
--                local dictTableType = DictTableType[tostring(dictData.tableTypeId)]
--                if dictTableType.id == StaticTableType.DictPlayerBaseProp and ( dictData.tableFieldId == StaticPlayerBaseProp.gold or dictData.tableFieldId == StaticPlayerBaseProp.copper ) then
--                    if _itemCount > 10 then
--                        UIManager.showToast( "此物品最多押10注" )
--                        _itemCount = 10
--                    end                  
--                end
                if _itemCount > _positionCount[ _itemChooseIndex ] then
                    _itemCount = _positionCount[ _itemChooseIndex ]
                    UIManager.showToast( Lang.ui_alliance_run27.._itemCount.."" )
                end
                refreshItemInfo()
            elseif sender == btn_add then  
                _itemCount = _itemCount + 1  
                local dictData = utils.getItemProp( _itemGoods[ _itemChooseIndex ] , false , true )
                --cclog( " count :"..dictData.playerCount )
                if _itemCount > dictData.playerCount then                    
                    _itemCount = dictData.playerCount
                    UIManager.showToast( Lang.ui_alliance_run28 )
                end
--                local dictTableType = DictTableType[tostring(dictData.tableTypeId)]
--                if dictTableType.id == StaticTableType.DictPlayerBaseProp and ( dictData.tableFieldId == StaticPlayerBaseProp.gold or dictData.tableFieldId == StaticPlayerBaseProp.copper ) then
--                    if _itemCount > 10 then
--                        UIManager.showToast( "此物品最多押10注" )
--                        _itemCount = 10
--                    end                  
--                end
                if _itemCount > _positionCount[ _itemChooseIndex ] then                   
                    _itemCount = _positionCount[ _itemChooseIndex ]
                    UIManager.showToast( Lang.ui_alliance_run29.._itemCount.."" )
                end
                refreshItemInfo()  
            elseif sender == btn_rank then
                UIManager.pushScene( "ui_alliance_run_rank" )
            end
        end
    end
    btn_back:setPressedActionEnabled( true )
    btn_back:addTouchEventListener( onEvent )
    btn_help:setPressedActionEnabled( true )
    btn_help:addTouchEventListener( onEvent )
    btn_enroll:setPressedActionEnabled( true )
    btn_enroll:addTouchEventListener( onEvent )
    btn_cut_ten:setPressedActionEnabled( true )
    btn_cut_ten:addTouchEventListener( onEvent )
    btn_cut:setPressedActionEnabled( true )
    btn_cut:addTouchEventListener( onEvent )
    btn_add_ten:setPressedActionEnabled( true )
    btn_add_ten:addTouchEventListener( onEvent )
    btn_add:setPressedActionEnabled( true )
    btn_add:addTouchEventListener( onEvent )
    btn_rank:setPressedActionEnabled( true )
    btn_rank:addTouchEventListener( onEvent )
    
    local function onSelect( sender , eventType )
        if eventType == ccui.CheckBoxEventType.selected then
            if sender == checkBox1 then
                refreshItemInfo( 1 )
            elseif sender == checkBox2 then
                refreshItemInfo( 2 )
            end          
        elseif eventType == ccui.CheckBoxEventType.unselected then     
            if sender == checkBox1 then
                refreshItemInfo( 1 )
            elseif sender == checkBox2 then
                refreshItemInfo( 2 )
            end
        end
    end
    checkBox1:addEventListener( onSelect )
    checkBox2:addEventListener( onSelect )

    scrollView = ccui.Helper:seekNodeByName( UIAllianceRun.Widget , "view_info" )
    _item = scrollView:getChildByName( "text_info" ):clone()
    _item:retain()

    --it_k_l.png
    --it_jian_l.png
    --气泡字
    local textNode = {}
    for i = 1 , 4 do
        textNode[ i ] = ccui.ImageView:create() 
        local bg = ccui.Scale9Sprite:create( "ui/it_k_l.png" )
        bg:setAnchorPoint( cc.p( 0 , 0.5 ) )
        bg:setPosition( cc.p( 0 , 0 ) )
        bg:setContentSize( cc.size( 100 , bg:getContentSize().height ) )
        local ar = ccui.ImageView:create( "ui/it_jian_l.png" )
        ar:setPosition( cc.p( 0  , 0 ) )
        local text = ccui.RichText:create()
        text:setPositionX( 10 )
        text:pushBackElement(ccui.RichElementText:create(1, cc.c3b(61, 19, 10), 255, Lang.ui_alliance_run30, dp.FONT, 24))
        textNode[ i ]:addChild( bg , 1 , 2 )
        textNode[ i ]:addChild( ar , 1 )
        textNode[ i ]:addChild( text , 1 , 1 )
    end
      
    for i = 1 , 4 do
        local road = image_basemap:getChildByName( "image_road"..i )
        road:getChildByName( "image_support" ):setVisible( false )
        aniImage[ i ]:setPosition( cc.p( 100 , road:getPositionY() ) )
        aniImage[ i ]:setName( "an"..i )
        aniImage[ i ]:setOpacity( 0 )
        animation[ i ]:setPosition( cc.p( aniImage[ i ]:getContentSize().width / 2 , aniImage[ i ]:getContentSize().height / 2 ) )

        local jianTou = ccui.ImageView:create( "ui/tk_j_jiantou02.png" )
        jianTou:setRotation( 90 )
        jianTou:setName( "jianTou" )
        jianTou:setPosition( cc.p( 80 , 120 ) )
        local action = cc.MoveBy:create( 0.5 , cc.p( 0 , 10 ) )
        jianTou:runAction( cc.RepeatForever:create( cc.Sequence:create( action , action:reverse() ) ) )
        jianTou:setVisible( false )
        aniImage[ i ]:addChild( jianTou , 1000 )
     
        animation[ i ]:setName("animation")
        aniImage[ i ]:addChild( animation[ i ] )
        textNode[ i ]:setPosition( cc.p( aniImage[ i ]:getContentSize().width , aniImage[ i ]:getContentSize().height ) )
        textNode[ i ]:setName( "t" )
        textNode[ i ]:setVisible( false )
        aniImage[ i ]:addChild( textNode[ i ] )

        local textName = ccui.Text:create()
       -- textName:setString( name[ i ] )
        textName:setString( "" )
        textName:setFontName(dp.FONT)
        textName:setFontSize(23)
        textName:setTextColor(cc.c4b(255, 0, 0, 255))
        textName:setPosition(cc.p( 50 , 0 ) )
        aniImage[ i ]:addChild( textName , 1001 )

        local textName11 = ccui.Helper:seekNodeByName( UIAllianceRun.Widget , "text_name"..i )
        textName11:setString( name[ i ] )
        textName11:setLocalZOrder( 1001 )

        image_basemap:addChild( aniImage[ i ] , 1000 )
    end
    
    for i = 1 , 4 do
        aniImage[ i ]:setTouchEnabled( true )
        aniImage[ i ]:addTouchEventListener( onEvent )
    end

    local image_meadow = image_basemap:getChildByName( "image_meadow" )
    image_meadow:setLocalZOrder( 101 )

    text_time = image_di:getChildByName( "text_time" ) --比赛开始倒计时： 06:22:22

    local text_hint = image_basemap:getChildByName( "text_hint" )
    text_hint:setLocalZOrder( 1001 )

    aniResult = getResultAnimation()
    aniResult:setName( "result" )
    aniResult:setVisible( false )
    image_basemap:addChild( aniResult , 1001 )

end
function UIAllianceRun.setup()
    dialogCount = { 0 , 0 , 0 , 0 }
    _distance = { 0 , 0 , 0 , 0 }
    _speed = { 120 , 110 , 100 , 110 }
    eventData = {}
    _winCount = 0
    _failCount = 0
    _itemGoods = { "3_2_20000" , "3_1_200" }
    _dialog = {}
    showDialog( 0 )
    local image_basemap = ccui.Helper:seekNodeByName( UIAllianceRun.Widget , "image_basemap" )
    image_basemap:getChildByName( "text_hint" ):setVisible( false )
    for key ,value in pairs ( DictRunShow ) do
        if value.type1 == 1 then
            if _dialog[ 1 ] then
            else
                _dialog[ 1 ] = {}
            end
            table.insert( _dialog[ 1 ] , value )
        elseif value.type1 == 2 then
            if _dialog[ 2 ] then
            else
                _dialog[ 2 ] = {}
            end
            table.insert( _dialog[ 2 ] , value )
        elseif value.type1 == 3 then
            if _dialog[ 3 ] then
            else
                _dialog[ 3 ] = {}
            end
            table.insert( _dialog[ 3 ] , value )
        end
    end
  --  _itemChooseIndex = 1 
    _itemCount = 0
    local _curTime = utils.getCurrentTime()
    -- (开始时间)每晚20:00开启
    _startTime = getTimer(_curTime, 20)
    -- (结束时间)每晚20:50结束
    netSendData( sendType.ENTER )
end
function UIAllianceRun.free()
    showDialog( 1 , true )
    showDialog( 2 , true )
    showDialog( 3 , true )
    showDialog( 4 , true )
    runActionType( 1 )
    userData = nil
    if _schedulerId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry( _schedulerId )
    end
    if _schedulerId1 then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry( _schedulerId1 )
    end
    _schedulerId = nil
    _startTime = nil
    _schedulerId1 = nil
    chooseIndex = nil
    state = nil
    dialogCount = nil
    eventData = nil
    _itemChooseIndex = nil
    _itemCount = nil
    _distance = nil
    _speed = nil
    _winCount = nil
    _failCount = nil
    _itemGoods = nil
    _dialog = nil
    _times = nil
    _preWin = nil
    _suppurtInfo = nil
    _positionCount = nil
    if resultP then
        resultP:removeFromParent()
        resultP = nil
    end
end
function UIAllianceRun.setData( userData1 )
    userData = userData1
end
--push信息
function UIAllianceRun.pushData( pack )
    if DEBUG then
--        refreshPosition( pack.tor1 , pack.tor2 , pack.tor3 )
--        --actorType|actorname|value1|value2|value3;actorType|...
--        local data = utils.stringSplit( pack.records , ";" )
--        refreshScrollView( data )
        return
    end
    local pin = pack.msgdata.int
--    if pin.state then
--        state = pin.state
--        if state == allState.START then
--            refreshInfo( sendType.START )
--        elseif state == allState.END then
--            UIAllianceRun.setup()
--        end
--    else
--        refreshPosition( pin.tor1 , pin.tor2 , pin.tor3 )
--        --actorType|actorname|value1|value2|value3;actorType|...
--        --local data = {}
--        if not pack.msgdata.string.record or pack.msgdata.string.record == "" then
--        else
--          --  data = utils.stringSplit( pack.msgdata.string.record , ";" )
--            table.insert( eventData , pack.msgdata.string.record )
--        end
--        refreshScrollView( eventData )
--    end
    _result = pin.matchResult
    local matching = pin.matching    
    if matching and matching == 2 then--重新开始
        UIAllianceRun.setup()
    elseif _result == 1 then--结束
        _speed[ 1 ] = 0
        _speed[ 2 ] = 0
        _speed[ 3 ] = 0
        _speed[ 4 ] = 0
        _preWin = pin.successTurtleId
        for i = 1 , 4 do
            if i == _preWin then            
                _distance[ i ] = _distance[ i ] + 10
            end
        end
        refreshInfo( sendType.START )
        local function onMovementEvent(armature, movementType, movementID)
            if movementType == ccs.MovementEventType.complete or movementType == ccs.MovementEventType.loopComplete then
                aniResult:getAnimation():playWithIndex( 1 )
                if resultP then
                    resultP:removeFromParent()
                    resultP = nil
                end
            end
        end
        resultP = getShowP()
        local image_basemap = ccui.Helper:seekNodeByName( UIAllianceRun.Widget , "image_basemap" )
        image_basemap:addChild( resultP , 1002 )
        aniResult:getAnimation():stop()
        aniResult:getAnimation():playWithIndex( 0 )
        aniResult:getAnimation():setMovementEventCallFunc(onMovementEvent)
    else
        aniResult:setVisible( false )
        _distance[ 1 ] = pin.turtleCount1 * 500 / 5000
        _distance[ 2 ] = pin.turtleCount2 * 500 / 5000
        _distance[ 3 ] = pin.turtleCount3 * 500 / 5000
        _distance[ 4 ] = pin.turtleCount4 * 500 / 5000

        _speed[ 1 ] = pin.fiveSpeed1 + pin.sevenSpeed1
        _speed[ 2 ] = pin.fiveSpeed2 + pin.sevenSpeed2
        _speed[ 3 ] = pin.fiveSpeed3 + pin.sevenSpeed3
        _speed[ 4 ] = pin.fiveSpeed4 + pin.sevenSpeed4

        local teshuevent  = pin.teshuevent  

        refreshInfo( sendType.START )    
            
        local type1 = pin.speedEventType1
        if teshuevent and teshuevent == 1 then
            if type1 > 0 then
                local eventId = 0
                if pin.sevenSpeed1 < 0 then
                    eventId = 3
                end
                table.insert( eventData , 1 , "1_"..(type1 + eventId) )
                playEffectAction( 1 , (type1 + eventId) )
            end
            local type2 = pin.speedEventType2
            if type2 > 0 then
                local eventId = 0
                if pin.sevenSpeed2 < 0 then
                    eventId = 3
                end
                table.insert( eventData , 1 , "2_"..(type2 + eventId) )
                playEffectAction( 2 , (type2 + eventId) )
            end
            local type3 = pin.speedEventType3
            if type3 > 0 then
                local eventId = 0
                if pin.sevenSpeed3 < 0 then
                    eventId = 3
                end
                table.insert( eventData , 1 , "3_"..(type3 + eventId) )
                playEffectAction( 3 , (type3 + eventId) )
            end
            local type4 = pin.speedEventType4
            if type4 > 0 then
                local eventId = 0
                if pin.sevenSpeed4 < 0 then
                    eventId = 3
                end
                table.insert( eventData , 1 , "4_"..(type4 + eventId) )
                playEffectAction( 4 , (type4 + eventId) )
            end
        end
        refreshScrollView( eventData )
    end
end
