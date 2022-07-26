require"Lang"
UIGame = {}
local _haveNum = nil
local _haveBuyNum = nil
local _formations = nil
local _enemies = nil
local _score = nil
local _freshTimeCount = nil
function UIGame.init()
    local btn_back = ccui.Helper:seekNodeByName( UIGame.Widget , "btn_back" )
    local btn_challenge = ccui.Helper:seekNodeByName( UIGame.Widget , "btn_challenge" )
    local btn_embattle = ccui.Helper:seekNodeByName( UIGame.Widget , "btn_embattle" )
    local btn_add = ccui.Helper:seekNodeByName( UIGame.Widget , "btn_add" )
    local btn_help = ccui.Helper:seekNodeByName( UIGame.Widget , "btn_help" )
    local image_di_rank = ccui.Helper:seekNodeByName( UIGame.Widget , "image_di_rank" )
    local btn_rank = image_di_rank:getChildByName( "btn_rank" )
    --local btn_record = image_di_rank:getChildByName( "btn_record" )
    local btn_reward_day = image_di_rank:getChildByName( "btn_reward_day" )
    local btn_reward_week = image_di_rank:getChildByName( "btn_reward_week" )
    local function onEvent( sender , eventType )
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_back then
                --UIManager.showLoading()
                netSendPackage(  { header = StaticMsgRule.challengeExit , msgdata = {} } , function ( pack )                     
                end )  
                -- UIMenu.onActivity()
                UIMenu.onHomepage()
            elseif sender == btn_challenge then
                UIGameChallenge.setData( { formations = _formations , enemies = _enemies , haveNum = _haveNum , haveBuyCount = _haveBuyNum , score = _score , timeCount = _freshTimeCount } )
                UIManager.showWidget( "ui_game_challenge" )
            elseif sender == btn_embattle then
                UIGameEmbattle.setData( { formations = _formations , enemies = _enemies } )
                UIManager.showWidget( "ui_game_embattle" )
            elseif sender == btn_add then
                if _haveBuyNum <= 0 then
                    UIManager.showToast( Lang.ui_game1 )
                    return
                end
                UISellProp.setData({ name = Lang.ui_game2 , price = DictChallengeBuyPrice[ tostring( 10 - _haveBuyNum + 1 ) ].price , haveNum = _haveBuyNum }, UIGame, function()
                    UIManager.flushWidget( UIGame )
                end )
                UIManager.pushScene("ui_sell_prop")
            elseif sender == btn_help then
                UIAllianceHelp.show( { type = 34 , titleName = Lang.ui_game3 } )
            elseif sender == btn_rank then -- 排行榜
                UIGameRank.setData( { score = _score } )
                UIManager.pushScene("ui_game_rank")
          --  elseif sender == btn_record then -- 
            elseif sender == btn_reward_day then -- 比赛记录
                UIManager.pushScene("ui_game_record")
            elseif sender == btn_reward_week then -- 奖励预览
                UIManager.pushScene("ui_game_preview")
            end
        end
    end
    btn_back:setPressedActionEnabled( true )
    btn_back:addTouchEventListener( onEvent )
    btn_challenge:setPressedActionEnabled( true )
    btn_challenge:addTouchEventListener( onEvent )
    btn_embattle:setPressedActionEnabled( true )
    btn_embattle:addTouchEventListener( onEvent )
    btn_add:setPressedActionEnabled( true )
    btn_add:addTouchEventListener( onEvent )
    btn_help:setPressedActionEnabled( true )
    btn_help:addTouchEventListener( onEvent )
    btn_rank:setPressedActionEnabled( true )
    btn_rank:addTouchEventListener( onEvent )
   -- btn_record:setPressedActionEnabled( true )
   -- btn_record:addTouchEventListener( onEvent )
    btn_reward_day:setPressedActionEnabled( true )
    btn_reward_day:addTouchEventListener( onEvent )
    btn_reward_week:setPressedActionEnabled( true )
    btn_reward_week:addTouchEventListener( onEvent )
end
function UIGame.getDuanWei( score1 )
    local score = tonumber( score1 )
    if score < 0 then
        score = 0
    end
    local ji = { "d" , "c" , "b" , "a" , "s" , "ss"  }
    local duan = { "1" , "2" , "3" , "4" , "5" , "6" , "7" , "8" , "9" }
    
    local jiIndex = 1   
    local duanIndex = 1
    for i = 10 , 63 do
        local value = DictChallengeLevelDanNickname[tostring(i)]
        if tonumber( value.lowerScore ) <= score then
            jiIndex = value.level
            duanIndex = value.dan
            break
        end
    end
    return ji[ jiIndex ] , duan[ duanIndex ]
end
function UIGame.setup()
    local image_bian = ccui.Helper:seekNodeByName( UIGame.Widget , "image_bian" )
    image_bian:getChildByName( "image_fight" ):getChildByName( "label_fight" ):setString( utils.getFightValue() ) --战斗力
    image_bian:getChildByName( "image_gold" ):getChildByName( "text_gold_number" ):setString( net.InstPlayer.int[ "5" ] ) --金币
    image_bian:getChildByName( "image_silver" ):getChildByName( "text_silver_number" ):setString( net.InstPlayer.string[ "6" ] ) --银币

    UIManager.showLoading()
    netSendPackage(  { header = StaticMsgRule.challengeEnter , msgdata = {} } , function ( pack )
        _haveNum = pack.msgdata.int.cTimes
        _haveBuyNum = pack.msgdata.int.bTimes
        _enemies = pack.msgdata.string.enemies
        _formations = pack.msgdata.string.formations
        _freshTimeCount = pack.msgdata.int.refresh
        local image_di_player = ccui.Helper:seekNodeByName( UIGame.Widget , "image_di_player" ) --个人信息
        local image_frame_player = image_di_player:getChildByName( "image_frame_player" )
        local dictCard = DictCard[tostring(net.InstPlayer.int["32"])]
	    if dictCard then
		    image_frame_player:getChildByName( "image_player" ):loadTexture("image/" .. DictUI[tostring(dictCard.smallUiId)].fileName)
	    end
        _score = pack.msgdata.int.score
        local text_points = image_di_player:getChildByName( "text_points" ) --当前积分：123456
        text_points:setString( Lang.ui_game4 .. _score )
        local text_level = image_di_player:getChildByName( "text_level" ) --当前段位：1234567
        local playerJi , playerDuan = UIGame.getDuanWei( _score )
        text_level:setString( Lang.ui_game5 .. string.upper( playerJi ) .. Lang.ui_game6 .. playerDuan .. Lang.ui_game7 )

        local rank123 = pack.msgdata.string.rank123
        local rank = utils.stringSplit( rank123 , "|" )
        local image_di_info = ccui.Helper:seekNodeByName( UIGame.Widget , "image_di_info" ) --前三名
        for i = 1 , 3 do
            local rankInfo = utils.stringSplit( rank[ i ] , "/" )--head_name_vip_score
            local image_card = image_di_info:getChildByName( "image_card" .. i )
            image_card:loadTexture("image/" .. DictUI[tostring(DictCard[tostring(rankInfo[1])].bigUiId)].fileName)
            local image_title = image_card:getChildByName( "image_title" )
            local ji , duan = UIGame.getDuanWei( rankInfo[ 4 ])
            local image_level = image_title:getChildByName( "image_level" ) -- SABCD
            image_level:loadTexture( "ui/game_" .. ji .. ".png" )
            local label_number = image_title:getChildByName( "label_number" ) -- 1-9段
            label_number:setString( duan )
            local text_name = image_title:getChildByName( "text_name" ) --name
            text_name:setString( rankInfo[ 2 ] )
            image_title:getChildByName( "image_vip" ):getChildByName( "label_vip_number" ):setString( rankInfo[ 3 ] ) --vip等级
            local text_points = image_title:getChildByName( "text_points" ) --积分：123456
            text_points:setString( Lang.ui_game8 .. rankInfo[ 4 ] )
            local text_fight = image_title:getChildByName( "text_fight" ) --战力：1234567
            text_fight:setVisible( false )
        end
        local text_time = ccui.Helper:seekNodeByName( UIGame.Widget , "text_time" ) --本赛季时间：2015/10/10——2015/10/10
        text_time:setString( Lang.ui_game9 .. pack.msgdata.string.cycle )

        local image_challenge = ccui.Helper:seekNodeByName( UIGame.Widget , "image_challenge" ) --挑战次数
        local text_number = image_challenge:getChildByName( "text_number" ) --挑战次数：6/10
      --  local cTimes = pack.msgdata.int.cTimes
        text_number:setString( Lang.ui_game10 .. _haveNum .. "/5" )
    end ) 
end
function UIGame.free()
    _haveNum = nil
    _haveBuyNum = nil
    _formations = nil
    _enemies = nil
    _score = nil
    _freshTimeCount = nil
end
