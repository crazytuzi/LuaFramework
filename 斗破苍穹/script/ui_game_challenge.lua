require"Lang"
UIGameChallenge = {}
local panel_team = nil
local POSITION_Y = {}
local _curTouchCard = nil
local _isRuning = nil
local _countTime = nil
local _schedulerId = nil
local text_time = nil
local _enemies = nil
local _formations = nil
local _playerId = nil --挑战的人id
local _playerInfo = nil --要挑战的人的信息
local _isWin = nil --挑战胜利失败
local _haveCount = nil --还有挑战次数
local _haveBuyCount = nil -- 还能购买的挑战次数
local _preScore = nil
local function onTouchBegan(touch, event)
	if _isRuning then
		return false
	end
	_isRuning = true
    local image_basemap = ccui.Helper:seekNodeByName( UIGameChallenge.Widget , "image_basemap" )
	local touchPoint = panel_team:convertTouchToNodeSpace(touch)
    local childs = panel_team:getChildren()
	for key, obj in pairs( childs ) do
		local objX, objY = obj:getPosition()
		if touchPoint.x > objX - obj:getContentSize().width / 2 and touchPoint.x < objX + obj:getContentSize().width / 2 and
		touchPoint.y > objY - obj:getContentSize().height / 2 and touchPoint.y < objY + obj:getContentSize().height / 2 then
            _curTouchCard = obj
            _curTouchCard:setLocalZOrder( 1 )
			break
		end
	end
	return true
end

local function onTouchMoved(touch, event)
    if _curTouchCard then
	    local image_basemap = ccui.Helper:seekNodeByName( UIGameChallenge.Widget , "image_basemap" )
	    local touchPoint = panel_team:convertTouchToNodeSpace(touch)
	        
		_curTouchCard:setPositionY(touchPoint.y)
	end
end
--得到主力阵容
local function getZhuIds( team )
    local aa = {}
    for i = 1 , 6 do
        if tonumber( team[ i ] ) > 0 then
            aa[ #aa + 1 ] = tonumber( team[ i ] )
        end
    end
    return aa
end
--得到替补阵容
local function getBuIds( team )
    local aa = {}
    for i = 7 , 8 do
        if tonumber( team[ i ] ) > 0 then
            aa[ #aa + 1 ] = tonumber( team[ i ] )
        end
    end
    return aa
end
--得到整队的阵容
local function getAllIds( team )
    local aa = {}
    for i = 1 , 8 do
        if tonumber( team[ i ] ) > 0 then
            aa[ #aa + 1 ] = tonumber( team[ i ] )
        end
    end
    return aa
end
--得到整队的instId阵容
local function getAllInstIds( team )
    local aa = {}
    for i = 1 , 8 do
        if tonumber( team[ i ] ) > 0 then
            aa[ #aa + 1 ] = tonumber( net.InstPlayerFormation[ tostring( team[ i ] ) ].int[ "3" ] )
        end
    end
    return aa
end
--- 获取玩家战力值
local function getFightValue( team )
    local fightValue = 0
    if team then
        local isNull = true
        for key, obj in pairs( team ) do
            if obj then
                isNull = false
                local instCardId = obj
                -- 卡牌实例ID
                local attribute, fightSoulValue = utils.getCardAttribute(instCardId, 0 ,team)
                for _fightPropId, _fightPropValue in pairs(attribute) do
                    if utils.FightValueFactor[_fightPropId] then
                        fightValue = fightValue +(_fightPropValue / utils.FightValueFactor[_fightPropId])
                    end
                end
                fightValue = fightValue + fightSoulValue
            end
        end

        --------------联盟修炼技能的战力数据--------------
        if net.InstUnionPractice and not isNull then
            -- 修炼Id_当前等级_当前经验;
            local practice = utils.stringSplit(net.InstUnionPractice.string["3"], ";")
            for key, obj in pairs(practice) do
                local _tempObj = utils.stringSplit(obj, "_")
                local _id = tonumber(_tempObj[1])
                local _level = tonumber(_tempObj[2])
                local _dictUnionPracticeData = DictUnionPractice[tostring(_id)]
                if _dictUnionPracticeData then
                    local _tempData = utils.stringSplit(_dictUnionPracticeData.propEffect, "_")
                    local _tableTypeId = tonumber(_tempData[1])
                    local _fightPropId = tonumber(_tempData[2])
                    if _tableTypeId == StaticTableType.DictFightProp and _fightPropId >= StaticFightProp.cutCrit then
                        for _k, _o in pairs(DictUnionPracticeUpgrade) do
                            if _o.unionPracticeId == _dictUnionPracticeData.id and _o.level == _level then
                                fightValue = fightValue + _o.fightValueAdd
                                break
                            end
                        end
                    end
                    _tempData = nil
                end
                _tempObj = nil
            end
            practice = nil
        end
    end
    return math.floor(fightValue)
end
--队伍信息
local function refreshTeamInfo()
    local layerFormations = utils.stringSplit( _formations , ";" )
    for i = 1 , 3 do
        local team = utils.stringSplit( layerFormations[ i ] , "_" )
        local image_di_team = panel_team:getChildByName( "image_di_team" .. i )
        local text_fight = image_di_team:getChildByName( "text_fight" ) -- 战力 12345678
        text_fight:setString( Lang.ui_game_challenge1 .. getFightValue( getAllInstIds( team ) ) )
        local teamData = getAllIds( team )
        for j = 1 , 5 do --3主力2替补
            local image_frame_card = image_di_team:getChildByName( "image_frame_card" .. j )
            local image_card = image_frame_card:getChildByName( "image_card" ) --卡牌
            local label_lv = image_frame_card:getChildByName( "image_lv" ):getChildByName( "label_lv") --星级
            if j <= #teamData then
                image_frame_card:setVisible( true )
                local instId = net.InstPlayerFormation[ tostring( teamData[ j ] ) ].int[ "3" ]
                local instCardData = net.InstPlayerCard[ tostring( instId ) ]
                local dictCard = DictCard[ tostring( instCardData.int[ "3" ] ) ]
                local isAwake = instCardData.int["18"] --是否已觉醒 0-未觉醒 1-觉醒 --isAwake == 1 and dictCardData.awakeSmallUiId or dictCardData.smallUiId
                image_card:loadTexture("image/" .. DictUI[tostring( isAwake == 1 and dictCard.awakeSmallUiId or dictCard.smallUiId)].fileName)
                label_lv:setString( instCardData.int[ "5" ] - 1 )
                local qualityImg = utils.getQualityImage(dp.Quality.card, instCardData.int["4"], dp.QualityImageType.small)
                image_frame_card:loadTexture( qualityImg )
            else
                image_frame_card:setVisible( false )
            end
        end
    end
end

local function onTouchEnded(touch, event)
    if _curTouchCard then
        local image_basemap = ccui.Helper:seekNodeByName( UIGameChallenge.Widget , "image_basemap" )
	    local touchPoint = panel_team:convertTouchToNodeSpace(touch)

        local childs = panel_team:getChildren()
	    for key, obj in pairs( childs ) do
		    local objX, objY = obj:getPosition()
		    if touchPoint.x > objX - obj:getContentSize().width / 2 and touchPoint.x < objX + obj:getContentSize().width / 2 and
		    touchPoint.y > objY - obj:getContentSize().height / 2 and touchPoint.y < objY + obj:getContentSize().height / 2 then
                if obj:getTag() ~= _curTouchCard:getTag() then
                    UIManager.showToast( Lang.ui_game_challenge2 )
                    local srcTag = _curTouchCard:getTag()
                    local resTag = obj:getTag()
                    local layerFormations = utils.stringSplit( _formations , ";" )
                    layerFormations[ srcTag ] , layerFormations[ resTag ] = layerFormations[ resTag ] , layerFormations[ srcTag ]
                    _formations = layerFormations[ 1 ] .. ";" .. layerFormations[ 2 ] .. ";" .. layerFormations[ 3 ]
                    UIManager.showLoading()
                    netSendPackage( { header = StaticMsgRule.challengeFormation , msgdata = { string = { formations = _formations } } } , function ( pack )
                        refreshTeamInfo()
                    end )
                end
			    break
		    end
	    end
        
        _curTouchCard:setPositionY( POSITION_Y[ _curTouchCard:getTag() ] )
        _curTouchCard:setLocalZOrder( 0 )
        _curTouchCard = nil
    end
    _isRuning = false
end
local function getTimeFormat( count )
    local time = {}
    time[ 1 ] = string.format( "%02d" , math.floor( count / 3600 / 24 ) )   --天
    time[ 2 ] = string.format( "%02d" , math.floor( count / 3600 % 24 ) ) --时
    time[ 3 ] = string.format( "%02d" , math.floor( count / 60 % 60 ) ) --分
    time[ 4 ] = string.format( "%02d" , math.floor( count % 60 ) ) --秒
    return time
end
--换一批倒计时
local function updateTime()
    if _countTime then
        if _countTime > 0 then
            _countTime = _countTime - 1
            local timeData = getTimeFormat( _countTime )         
            text_time:setString( Lang.ui_game_challenge3..timeData[2]..":"..timeData[3]..":"..timeData[4] )
        else
            text_time:setString( "" )
        end
        if _countTime == 0 and _schedulerId then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry( _schedulerId )
            _schedulerId = nil
        end
    end  
end
--刷新挑战次数
local function refreshChallegeCount()
    local image_challenge = ccui.Helper:seekNodeByName( UIGameChallenge.Widget , "image_challenge" )
    local text_number = image_challenge:getChildByName( "text_number" )
    text_number:setString( Lang.ui_game_challenge4 .. _haveCount .. "/5" )
end
--当前挑战的三个信息
local function refreshOpponentInfo()
    local opps = utils.stringSplit( _enemies , "|" )
    for i = 1 , 3 do
        local oppInfo = utils.stringSplit( opps[ i ] , "/" ) --id_head_name_vip_unionName_score
        local image_di_card = ccui.Helper:seekNodeByName( UIGameChallenge.Widget , "image_di_card" .. i )
        local panel_card = image_di_card:getChildByName( "panel_card" )
        local image_card = panel_card:getChildByName( "image_card" ) --头像
        image_card:loadTexture("image/" .. DictUI[tostring(DictCard[tostring(oppInfo[2])].bigUiId)].fileName)
        local image_title = image_card:getChildByName( "image_title" )
        local image_level = image_title:getChildByName( "image_level" ) --段位
        local ji , duan = UIGame.getDuanWei( oppInfo[ 6 ] )
        image_level:loadTexture( "ui/game_" .. ji .. ".png" )
        local label_number = image_title:getChildByName( "label_number" ) --级
        label_number:setString( duan )
        local text_name = image_title:getChildByName( "image_name" ):getChildByName( "text_name" ) --名字
        text_name:setString( oppInfo[ 3 ] )
        local text_alliance = image_title:getChildByName( "text_alliance" ) --联盟
        text_alliance:setString( oppInfo[ 5 ] )
        local text_points = image_title:getChildByName( "text_points" ) -- 积分:123456
        text_points:setString( Lang.ui_game_challenge5 .. oppInfo[ 6 ] )
        local text_fight = image_title:getChildByName( "text_fight" ) -- 战力:1234567
        text_fight:setVisible( false )
    end
end
local _fightTimes = 1
local _fightWin = 0
local _fightFail = 0
local _pvpTeam = ""
local _myTeam = ""
local _fightInfo = { 0 , 0 , 0 }
local function netCallbackFunc(data)
    local code = tonumber(data.header)
    if code == StaticMsgRule.challengeGetEnemy then
        local function callBackFunc(isWin)
            cclog( "isWin :" .. isWin .. "  " .._playerId )
            _isWin = isWin
            
            if _isWin == 1 then
                _fightWin = _fightWin + 1
                _fightInfo[ _fightTimes ] = 1
            else
                _fightFail = _fightFail + 1
                _fightInfo[ _fightTimes ] = 0
            end
            _fightTimes = _fightTimes + 1
            if _fightTimes > 3 or _fightWin >= 2 or _fightFail >= 2  then
                UIManager.showLoading()
                local result = 1
                if _fightWin >= 2 then
                    result = 1
                elseif _fightFail >= 2 then
                    result = 0
                end
                netSendPackage( { header = StaticMsgRule.challengeChallenge, msgdata = { int = { playerId = _playerId, isWin = result } } }, netCallbackFunc)
            else
                local animationId = _isWin == 1 and 11 or 12
                local animation = ActionManager.getUIAnimation(animationId, function(armature)
                UIManager.gameLayer:runAction(cc.Sequence:create(cc.DelayTime:create(0.02), cc.CallFunc:create( function()
                    if armature and armature:getParent() then armature:removeFromParent() end     
                        utils.sendFightData({ myTeam = _myTeam[ _fightTimes ] , pvpTeam = _pvpTeam[ _fightTimes ]  }, dp.FightType.FIGHT_3V3, callBackFunc )
                        UIFightMain.loading()
                    end )))
                end )
                animation:setPosition(cc.p(UIManager.screenSize.width / 2, UIManager.screenSize.height * 0.75))
                UIManager.gameLayer:addChild(animation, 1000000)
            end
        end
        pvp.loadGameData(data)
        _pvpTeam = utils.stringSplit( data.msgdata.string.formations , ";" )
        _myTeam = utils.stringSplit( _formations , ";" )
        _fightTimes = 1
        _fightWin = 0
        _fightFail = 0
        cclog( "team:" .. _myTeam[ _fightTimes ] .. " " .._pvpTeam[ _fightTimes ] )
        utils.sendFightData({ myTeam = _myTeam[ _fightTimes ] , pvpTeam = _pvpTeam[ _fightTimes ] }, dp.FightType.FIGHT_3V3, callBackFunc )
        UIFightMain.loading()
    elseif code == StaticMsgRule.challengeChallenge then
        local animationId = _isWin == 1 and 11 or 12
        _enemies = data.msgdata.string.enemies
        local animation = ActionManager.getUIAnimation(animationId, function(armature)
            UIManager.gameLayer:runAction(cc.Sequence:create(cc.DelayTime:create(0.02), cc.CallFunc:create( function()
                if armature and armature:getParent() then armature:removeFromParent() end     
                _fightTimes = 0          
                _haveCount = tonumber( data.msgdata.int.cTimes )          
--                UIGameEmbattle.setData( { formations = _formations , enemies = _enemies } )
--                UIManager.showWidget( "ui_notice" )
--                UIManager.showWidget( "ui_game_challenge" )
                UIGameWin.setData( { winCount = _fightWin , failCount = _fightFail , myTeam = _myTeam , pvpTeam = _pvpTeam , playerInfo = _playerInfo , fightInfo = _fightInfo , myScore = _preScore , addMy = data.msgdata.int.iScoreDelta , addEnemy = data.msgdata.int.oScoreDelta } , function ()                   
                    _preScore = data.msgdata.int.score
                    UIManager.showWidget( "ui_notice" )
                    UIManager.showWidget( "ui_game" )
                end , function ()
                    _preScore = data.msgdata.int.score
                    UIGameEmbattle.setData( { formations = _formations , enemies = _enemies } )
                    UIManager.showWidget( "ui_notice" )
                    UIManager.showWidget( "ui_game_challenge" )
                    refreshChallegeCount()
                end )
                UIManager.pushScene( "ui_game_win" )
            end )))
        end )
        animation:setPosition(cc.p(UIManager.screenSize.width / 2, UIManager.screenSize.height * 0.75))
        UIManager.gameLayer:addChild(animation, 1000000)
    end
end

local function isCanChallenge()
    if _haveCount > 0 then
        return true
    elseif _haveBuyCount > 0 then
        UISellProp.setData({ name = Lang.ui_game_challenge6 , price = DictChallengeBuyPrice[ tostring( 10 - _haveBuyCount + 1 ) ].price , haveNum = _haveBuyCount }, UIGameChallenge, function( data )
            _haveCount = tonumber( data.msgdata.int.cTimes )
            _haveBuyCount = tonumber( data.msgdata.int.bTimes )
            refreshChallegeCount()
            local image_bian = ccui.Helper:seekNodeByName( UIGameChallenge.Widget , "image_bian" )          
            image_bian:getChildByName( "image_gold" ):getChildByName( "text_gold_number" ):setString( net.InstPlayer.int[ "5" ] ) --金币
        end )
        UIManager.pushScene("ui_sell_prop")
        return false
    end
    UIManager.showToast(Lang.ui_game_challenge7)
    return false
end
function UIGameChallenge.init()
    local btn_back = ccui.Helper:seekNodeByName( UIGameChallenge.Widget , "btn_back" )
    local btn_embattle = ccui.Helper:seekNodeByName( UIGameChallenge.Widget , "btn_embattle" )
    local image_di_card1 = ccui.Helper:seekNodeByName( UIGameChallenge.Widget , "image_di_card1" )
    local btn_challenge1 = ccui.Helper:seekNodeByName( image_di_card1 , "btn_challenge" )
    local image_di_card2 = ccui.Helper:seekNodeByName( UIGameChallenge.Widget , "image_di_card2" )
    local btn_challenge2 = ccui.Helper:seekNodeByName( image_di_card2 , "btn_challenge" )
    local image_di_card3 = ccui.Helper:seekNodeByName( UIGameChallenge.Widget , "image_di_card3" )
    local btn_challenge3 = ccui.Helper:seekNodeByName( image_di_card3 , "btn_challenge" )
    local btn_change = ccui.Helper:seekNodeByName( UIGameChallenge.Widget , "btn_change" ) --换一批
    text_time = btn_change:getChildByName( "text_time" )
    local image_challenge = ccui.Helper:seekNodeByName( UIGameChallenge.Widget , "image_challenge" )
    local btn_add = ccui.Helper:seekNodeByName( image_challenge , "btn_add" )
    local function onEvent( sender , eventType )
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_back then
                UIManager.showWidget( "ui_game" )
            elseif sender == btn_embattle then
                UIGameEmbattle.setData( { formations = _formations , enemies = _enemies } )
                UIManager.showWidget( "ui_game_embattle" )
            elseif sender == btn_challenge1 then
                if not isCanChallenge() then
                    return 
                end
                local opps = utils.stringSplit( _enemies , "|" )
                local oppInfo = utils.stringSplit( opps[ 1 ] , "/" ) --id_head_name_vip_unionName_score
                _playerInfo = oppInfo
                _playerId = tonumber( oppInfo[ 1 ] )
                UIManager.showLoading()
                netSendPackage( { header = StaticMsgRule.challengeGetEnemy , msgdata = { int = { playerId = _playerId }} } , netCallbackFunc )
            elseif sender == btn_challenge2 then
                if not isCanChallenge() then
                    return 
                end
                local opps = utils.stringSplit( _enemies , "|" )
                local oppInfo = utils.stringSplit( opps[ 2 ] , "/" ) --id_head_name_vip_unionName_score
                _playerInfo = oppInfo
                _playerId = tonumber( oppInfo[ 1 ] )
                UIManager.showLoading()
                netSendPackage( { header = StaticMsgRule.challengeGetEnemy , msgdata = { int = { playerId = _playerId }} } , netCallbackFunc )
            elseif sender == btn_challenge3 then
                if not isCanChallenge() then
                    return 
                end
                local opps = utils.stringSplit( _enemies , "|" )
                local oppInfo = utils.stringSplit( opps[ 3 ] , "/" ) --id_head_name_vip_unionName_score
                _playerInfo = oppInfo
                _playerId = tonumber( oppInfo[ 1 ] )
                UIManager.showLoading()
                netSendPackage( { header = StaticMsgRule.challengeGetEnemy , msgdata = { int = { playerId = _playerId }} } , netCallbackFunc )
            elseif sender == btn_change then
                if _schedulerId then
                    UIManager.showToast( Lang.ui_game_challenge8 )
                else                
                    netSendPackage( { header = StaticMsgRule.challengeRefresh , msgdata = {} } , function ( pack )
                        _enemies = pack.msgdata.string.enemies
                        refreshOpponentInfo()
                        _countTime = pack.msgdata.int.refresh
                        if _countTime < 0 then
                            _countTime = 0
                        end
                        if _countTime > 0 then
                            updateTime()
                            _schedulerId = cc.Director:getInstance():getScheduler():scheduleScriptFunc( updateTime , 1 , false )
                        end
                    end)
                end
            elseif sender == btn_add then
                if _haveBuyCount <= 0 then
                    UIManager.showToast(Lang.ui_game_challenge9)
                else
                    UISellProp.setData({ name = Lang.ui_game_challenge10 , price = DictChallengeBuyPrice[ tostring( 10 - _haveBuyCount + 1 ) ].price , haveNum = _haveBuyCount }, UIGameChallenge, function( data )
                        _haveCount = tonumber( data.msgdata.int.cTimes )
                        _haveBuyCount = tonumber( data.msgdata.int.bTimes )
                        refreshChallegeCount()
                        local image_bian = ccui.Helper:seekNodeByName( UIGameChallenge.Widget , "image_bian" )          
                        image_bian:getChildByName( "image_gold" ):getChildByName( "text_gold_number" ):setString( net.InstPlayer.int[ "5" ] ) --金币
                    end )
                    UIManager.pushScene("ui_sell_prop")
                end
            end
        end
    end
    btn_back:setPressedActionEnabled( true )
    btn_back:addTouchEventListener( onEvent )
    btn_embattle:setPressedActionEnabled( true )
    btn_embattle:addTouchEventListener( onEvent )
    btn_challenge1:setPressedActionEnabled( true )
    btn_challenge1:addTouchEventListener( onEvent )
    btn_challenge2:setPressedActionEnabled( true )
    btn_challenge2:addTouchEventListener( onEvent )
    btn_challenge3:setPressedActionEnabled( true )
    btn_challenge3:addTouchEventListener( onEvent )
    btn_change:setPressedActionEnabled( true )
    btn_change:addTouchEventListener( onEvent )
    btn_add:setPressedActionEnabled( true )
    btn_add:addTouchEventListener( onEvent )

    panel_team = ccui.Helper:seekNodeByName( UIGameChallenge.Widget , "panel_team" )
    for i = 1 , 3 do
        local image_di_team = panel_team:getChildByName( "image_di_team"..i )
        image_di_team:setLocalZOrder( 0 )
        image_di_team:setTag( i )
        image_di_team:setTouchEnabled( false )
        POSITION_Y[ i ] =  image_di_team:getPositionY()       
    end
    local listener = cc.EventListenerTouchOneByOne:create()
	listener:setSwallowTouches(true)
	listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
	listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
	local eventDispatcher = panel_team:getEventDispatcher()
    eventDispatcher:removeEventListenersForTarget(panel_team)
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, panel_team)

    image_di_card1:setLocalZOrder( panel_team:getLocalZOrder() + 1 )
    image_di_card2:setLocalZOrder( panel_team:getLocalZOrder() + 1 )
    image_di_card3:setLocalZOrder( panel_team:getLocalZOrder() + 1 )
    btn_back:setLocalZOrder( panel_team:getLocalZOrder() + 2 )
    image_challenge:setLocalZOrder( panel_team:getLocalZOrder() + 2 )
end
function UIGameChallenge.setup()
    refreshChallegeCount()
    updateTime()
    if _countTime > 0 then
        _schedulerId = cc.Director:getInstance():getScheduler():scheduleScriptFunc( updateTime , 1 , false )
    end
    local image_bian = ccui.Helper:seekNodeByName( UIGameChallenge.Widget , "image_bian" )
    image_bian:getChildByName( "image_fight" ):getChildByName( "label_fight" ):setString( utils.getFightValue() ) --战斗力
    image_bian:getChildByName( "image_gold" ):getChildByName( "text_gold_number" ):setString( net.InstPlayer.int[ "5" ] ) --金币
    image_bian:getChildByName( "image_silver" ):getChildByName( "text_silver_number" ):setString( net.InstPlayer.string[ "6" ] ) --银币

    refreshOpponentInfo()
    refreshTeamInfo()
end
function UIGameChallenge.free()
    _curTouchCard = nil
--    _formations = nil
    _isRuning = nil
    if _schedulerId then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry( _schedulerId )
        _schedulerId = nil
    end
--    _enemies = nil
--    _playerId = nil
    _isWin = nil
end
function UIGameChallenge.setData( data )
    _formations = data.formations
    _enemies = data.enemies
    _haveCount = tonumber( data.haveNum )
    _haveBuyCount = tonumber( data.haveBuyCount )
    _preScore = data.score
    _countTime = tonumber( data.timeCount )
    if _countTime < 0 then
        _countTime = 0
    end
end
