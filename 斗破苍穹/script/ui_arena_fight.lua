require"Lang"
UIArenaFight = {}
local _player = nil
local _scrollView = nil
local _item = nil
local _itemF = nil
local _addTimes = nil
local _isWin = nil
local _flag = nil
local _data = nil
local _posY = nil
local _width = nil
local function showToast()
	local _rank = _data[5] --排名
    local _weiwang = net.InstPlayer.int["39"] - _data[6] --获得威望
	local _selfRank = _data[7] --自己的排名
  --  cclog("sdfsfs : ".._flag .."  ".._isWin .. "  ".._weiwang .. "  " .._rank .. "  ".._selfRank)
	if _flag == 1 then
		UIArena.updateRanking()
	elseif _isWin == 1 then
		UIArena.free() ------######为了测试调用
		UIArena.setup()
		if _rank >= _selfRank then
			UIArena.showToast(Lang.ui_arena_fight1.._weiwang..Lang.ui_arena_fight2)
		else
			-- UIArena.showToast("您的排名上升至".._rank.."名！\n获得".._weiwang.."威望。")
			UIArena.showToast({_rank,_weiwang})
		end
	elseif _isWin == 0 then
		UIArena.showToast(Lang.ui_arena_fight3.._weiwang..Lang.ui_arena_fight4)
	end
	UIArena.onEnter()
end
function UIArenaFight.reset()
    _addTimes = 10000
end
function UIArenaFight.init()
    local btn_sure = ccui.Helper:seekNodeByName( UIArenaFight.Widget , "btn_sure" )
    local function onEvent( sender , touchType )
        if touchType == ccui.TouchEventType.ended then
            if sender == btn_sure then
                if _addTimes >= _player.allTimes then
                    UIManager.popScene() 
                    showToast()
                end
            end
        end
    end
    btn_sure:setPressedActionEnabled( true )
    btn_sure:addTouchEventListener( onEvent )
    _scrollView = ccui.Helper:seekNodeByName( UIArenaFight.Widget , "view_get" )
    _item = ccui.Helper:seekNodeByName( UIArenaFight.Widget , "panel_win" ):clone()
    _item:retain()
    _itemF = ccui.Helper:seekNodeByName( UIArenaFight.Widget , "panel_fail" ):clone()
    _itemF:retain()
end
function UIArenaFight.setup()
    local image_fight = ccui.Helper:seekNodeByName( UIArenaFight.Widget , "image_fight" )
    local image_frame_player_rival = image_fight:getChildByName("image_frame_player_rival")
    local playerFight = ccui.Helper:seekNodeByName( image_frame_player_rival , "label_fight" )
    local playerIcon = image_frame_player_rival:getChildByName( "image_player" )
	local playerName = ccui.Helper:seekNodeByName( image_frame_player_rival , "text_name_rival" )
	local cardId = _player.cardId
	if cardId then 
		local dictCard = DictCard[tostring(cardId)]
		if dictCard then
			playerIcon:loadTexture("image/" .. DictUI[tostring(dictCard.smallUiId)].fileName)
		end
	end
	playerFight:setString(pvp.getFightValue())
	playerName:setString( _player.name )

    local image_frame_player = image_fight:getChildByName("image_frame_player")
    local fight = ccui.Helper:seekNodeByName( image_frame_player , "label_fight" )
    local name = ccui.Helper:seekNodeByName( image_frame_player , "text_name" )
    local icon = image_frame_player:getChildByName("image_player")
    local dictCard = DictCard[tostring(net.InstPlayer.int["32"])]
	if dictCard then
		icon:loadTexture("image/" .. DictUI[tostring(dictCard.smallUiId)].fileName)
	end
    fight:setString(utils.getFightValue())
    name:setString(net.InstPlayer.string["3"])

    _scrollView:removeAllChildren()
    _addTimes = 0
    _isWin = 0
    _flag = 0
    _posY = _scrollView:getPositionY()
    _width = _scrollView:getInnerContainerSize().height
end
function UIArenaFight.free()
    _player = nil
    _scrollView = nil
    _addTimes = nil
    _isWin = nil
    _flag = nil
    _data = nil
    _posY = nil
    _width = nil
end
function UIArenaFight.setData( player )
    _player = player
end
function UIArenaFight.addItem( data )
    if data[ 3 ] == 1 then
        _flag = 1
    else
    end
    local childs = _scrollView:getChildren()
    local height = 0
    for i = 1 , #childs do
       -- local positionX , positionY = childs[ i ]:getPosition()
       -- childs[ i ]:setPosition( cc.p( positionX , positionY - _item:getContentSize().height ) )
        height = height + childs[ i ]:getContentSize().height
    end

    local item = nill 
    local item_result = nil
    if data[1] == 1 then
        item = _item:clone()
        item_result = item:getChildByName("image_win")
    else
        item = _itemF:clone()
        item_result = item:getChildByName("image_fail")
    end
--    item_result:setVisible( false )
    item:setPosition( cc.p( -500 , height ) )
    item:runAction( cc.Sequence:create( cc.MoveTo:create( 0.1 , cc.p( -0 , height ) ) ,  cc.CallFunc:create( function()
--        item_result:setVisible(true)
--        item_result:setScale( 5 )
--        item_result:setOpacity( 100 )
--        item_result:runAction( cc.Spawn:create( cc.ScaleTo:create( 0.2 , 1 ) , cc.FadeIn:create( 0.2 ) ) )
    end ) ) )
    height = height + item:getContentSize().height    
    if height > _scrollView:getInnerContainerSize().height then
        _scrollView:setInnerContainerSize(cc.size(_scrollView:getInnerContainerSize().width , height ))
        local positionX , positionY = _scrollView:getPositionX() , _posY
        _scrollView:setPosition(cc.p( positionX , positionY + item:getContentSize().height ))
        _scrollView:runAction( cc.MoveTo:create( 0.05 , cc.p(positionX , positionY)) )
    else 
        local positionX , positionY = _scrollView:getPositionX() , _posY
        _width = _width - item:getContentSize().height
        _scrollView:setPosition(cc.p(positionX , positionY + _width))
        if _addTimes > 0 then
            _scrollView:runAction( cc.MoveTo:create( 0.05 , cc.p(positionX , positionY + _width ) ) )
        end
    end    
    _addTimes = _addTimes + 1
    if _addTimes >= _player.allTimes then
        if not UIGuidePeople.guideStep and not UIGuidePeople.levelStep and UITalkFly.layer then
            UITalkFly.fShow()
        end
    end
    local text_ceng = ccui.Helper:seekNodeByName( item , "text_ceng" ) --第几次奖励
    text_ceng:setString(Lang.ui_arena_fight5.._addTimes..Lang.ui_arena_fight6)
    local text_weiwang_number = ccui.Helper:seekNodeByName( item , "text_weiwang_number" ) --威望
    local _weiwangValue = 0
    if not _data then
        _data = data
    end
	if data[1] == 1 then
        _isWin = 1
        _weiwangValue = net.InstPlayer.int["39"] - data[6]
	else
        _weiwangValue = net.InstPlayer.int["39"] - data[6]
	end
    text_weiwang_number:setString( "×".._weiwangValue )
    local text_silver_number = ccui.Helper:seekNodeByName( item , "text_silver_number" ) --银币
    local _dlpData = DictLevelProp[tostring(net.InstPlayer.int["4"])]
    text_silver_number:setString( "×".._dlpData.duelFleetCopper )

    local thingArray = data[4]
   -- cclog( " "..data[4] )
    if thingArray then
	    local things = utils.stringSplit(thingArray, ";")
        local dropThings = {}
	    for _key,_obj in pairs(things) do
		    dropThings[_key] = utils.stringSplit(_obj, "_")
	    end
        local _tableTypeId, _tableFieldId = dropThings[1][1], dropThings[1][2]
        local thingName, thingIcon= utils.getDropThing(_tableTypeId, _tableFieldId)
        local image_frame_good = ccui.Helper:seekNodeByName( item , "image_frame_good" )
	    image_frame_good:getChildByName("image_good"):loadTexture(thingIcon)
	    image_frame_good:getChildByName("image_good"):getChildByName("text_name"):setString(thingName)
        image_frame_good:getChildByName("image_base_number"):getChildByName("text_number"):setString( dropThings[1][3] )
	    utils.addBorderImage(_tableTypeId,_tableFieldId,image_frame_good)
    end
    _scrollView:addChild(item)
    
  --  _scrollView:scrollToTop(0.1,false)
end
