require"Lang"
UIGameEmbattle = {}
local _scrollView = nil
local _item = nil
local _cardData = nil
local _curTouchCard = nil
local _curTouchItem = nil
local _isRuning = nil
local image_base_team = {}
local team_card = nil --阵容
local panel_team = nil
local _formations = nil

local _curTeamIndex = nil --当前拖动的那一队的
local _curTouchCardIndex = nil -- 当前卡牌是阵容中的哪一个
local _curCardPosition = nil --记录当前拖动的卡牌的坐标

local _curPositionX = nil --记录触摸拖动前的 滚动条坐标
local _preX = nil --记录触摸拖动前的 触摸点坐标
local _preY = nil --记录触摸拖动前的 触摸点坐标
local _preIcon = nil
local _isMove = nil

local _moveScrollView = nil
local function scrollAssociatedView( disX )
    local container = _scrollView:getInnerContainer()
    local width = ( container:getContentSize().width - _scrollView:getContentSize().width ) 
    if width <= 0 then
        return 
    end
   local percent = math.abs( disX ) * 100 / width
    _scrollView:scrollToPercentHorizontal( percent , 0.1 , false )
end
local function setViewItem( item , data )
    --image_card
    item:setTag( data.int[ "3" ] )
    local instData = net.InstPlayerCard[ tostring( data.int[ "3" ] ) ]
    item:loadTexture( utils.getQualityImage( dp.Quality.card , instData.int[ "4" ] , dp.QualityImageType.small ) )
    local isAwake = instData.int["18"] --是否已觉醒 0-未觉醒 1-觉醒 --isAwake == 1 and dictCardData.awakeSmallUiId or dictCardData.smallUiId
    item:getChildByName( "image_card" ):loadTexture( "image/" .. DictUI[ tostring( isAwake == 1 and DictCard[ tostring( instData.int[ "3" ] ) ].awakeSmallUiId or DictCard[ tostring( instData.int[ "3" ] ) ].smallUiId ) ].fileName ) 
    item:getChildByName( "image_lv" ):getChildByName( "label_lv" ):setString( instData.int[ "5" ] - 1 )    
--    if isInTeam( data.int[ "3" ] ) then
--        item:getChildByName( "image_choose" ):setVisible( true )
--    else
    item:getChildByName( "image_choose" ):setVisible( false )
--    end
    local function onEvent( sender , eventType )
        if eventType == ccui.TouchEventType.ended then
            if sender == item then
               -- UIManager.showToast( "点击图标了" )
               if item:getChildByName( "image_choose" ):isVisible() then
                    changeTeamInfo( 2 , data.int[ "3" ] )
                    refreshInfo()
                    item:getChildByName( "image_choose" ):setVisible( false )
               else
                   if changeTeamInfo( 1 , data.int[ "3" ] ) then
                        refreshInfo()
                        item:getChildByName( "image_choose" ):setVisible( true )
                   else
                        UIManager.showToast( Lang.ui_game_embattle1 )
                   end
               end
            end
        end
    end
    item:setTouchEnabled( true )
    item:addTouchEventListener( onEvent )
end
local function refreshScrollViewItem()
    local function noTeam( instId )
        for i = 1 , 3 do
            if team_card[ i ] then
                for key ,value in pairs( team_card[ i ] ) do
                    if value and tonumber( value ) == instId then
                        return false
                    end
                end
            end
        end
        return true
    end
    _cardData = {}
    if net.InstPlayerFormation then
        for key ,value in pairs( net.InstPlayerFormation ) do
          --  print( value.int["4"] , value.int["10"] )
            if( value.int["4"] == 1 or value.int["4"] == 2 or ( value.int["4"] == 3 and value.int["10"] > 0 ) ) and noTeam( value.int["3"] ) then
                _cardData[ #_cardData + 1 ] =  value
            end
        end
    end
    _scrollView:removeAllChildren()
    utils.updateHorzontalScrollView( UIGameEmbattle , _scrollView , _item , _cardData , setViewItem )
end
--得到点击的那个obj
local function getBeganCard( touchPoint )
    local curCardList = nil
    curCardList = team_card[ _curTeamIndex ]
    if curCardList then
        local image_base_card = image_base_team[ _curTeamIndex ]:getChildByName( "image_base_card" )
        local image_base_card_bu = image_base_team[ _curTeamIndex ]:getChildByName( "image_base_card_bu" )
        local children = {}
        for i = 1 , 6 do
            children[ #children + 1 ] = image_base_card:getChildByName( "image_frame_card"..i )
        end
        
        for i = 1 , 1 do
            children[ #children + 1 ] = image_base_card_bu:getChildByName( "image_frame_card"..i )
        end
   --     cclog( "touchPoint: " .. touchPoint.x .. "  " .. touchPoint.y )
        local parentPX1 = image_base_card:getPositionX() - image_base_card:getContentSize().width / 2
        local parentPY1 = image_base_card:getPositionY() - image_base_card:getContentSize().height / 2
        local parentPX2 = image_base_card_bu:getPositionX() - image_base_card_bu:getContentSize().width / 2
        local parentPY2 = image_base_card_bu:getPositionY() - image_base_card_bu:getContentSize().height / 2
        for key, obj in pairs( children ) do
            local parentPX , parentPY = 0 , 0
            if tonumber( key ) <= 6 then
                parentPX , parentPY = parentPX1 , parentPY1
            else
                parentPX , parentPY = parentPX2 , parentPY2
            end
   --         cclog( "parentPX : " .. parentPX .. " parentPY:" .. parentPY )
		    local objX, objY = parentPX + obj:getPositionX() , parentPY + obj:getPositionY()
		    if touchPoint.x > objX - obj:getContentSize().width / 2 and touchPoint.x < objX + obj:getContentSize().width / 2 and
		    touchPoint.y > objY - obj:getContentSize().height / 2 and touchPoint.y < objY + obj:getContentSize().height / 2 then
             --   UIManager.showToast( "点击" .. key )
                if curCardList[ key ] then
                    image_base_team[ _curTeamIndex ]:setLocalZOrder( 1 )
			        _curCardPosition = cc.p( obj:getPositionX() , obj:getPositionY() )
                    _curTouchCard = obj
                    _moveScrollView:setLocalZOrder( 1 )
                    panel_team:setLocalZOrder( 2 )
                    _curTouchCard:setLocalZOrder( 1 )
                    _curTouchCardIndex = tonumber( key )
              --      cclog( "anchor :" , _curTouchCard:getAnchorPoint().x .. " " .. _curTouchCard:getAnchorPoint().y )
                    if _curTouchCardIndex <= 6 then
                        image_base_card:setLocalZOrder( 1 )
                        image_base_card_bu:setLocalZOrder( 0 )
                    else
                        image_base_card:setLocalZOrder( 0 )
                        image_base_card_bu:setLocalZOrder( 1 )
                    end
                end
			    break
		    end
	    end 
    end
end
local function changeIcon( icon , instCard )
    if instCard <= 0 then
        icon:setTag( -1 )
        icon:loadTexture( "ui/card_small_purple.png" )
        icon:getChildByName("image_card"):loadTexture( "ui/frame_tianjia.png" )   
        icon:getChildByName( "image_lv" ):setVisible( false )
    else
        icon:setTag( instCard )
        local instPlayerCardData = net.InstPlayerCard[ tostring( instCard ) ] 
        local dictCardData = DictCard[ tostring( instPlayerCardData.int[ "3" ] ) ]
        icon:loadTexture( utils.getQualityImage( dp.Quality.card , instPlayerCardData.int[ "4" ] , dp.QualityImageType.small ) )
        local isAwake = instPlayerCardData.int["18"] --是否已觉醒 0-未觉醒 1-觉醒 --isAwake == 1 and dictCardData.awakeSmallUiId or dictCardData.smallUiId
        icon:getChildByName("image_card"):loadTexture( "image/" .. DictUI[ tostring( isAwake == 1 and dictCardData.awakeSmallUiId or dictCardData.smallUiId ) ].fileName ) 
        icon:getChildByName( "image_lv" ):setVisible( true )   
        icon:getChildByName( "image_lv" ):getChildByName( "label_lv" ):setString( ( instPlayerCardData.int["5"] - 1 ) )
    end            
end
local function onTouchBegan(touch, event)
	if _isRuning then
		return false
	end
	_isRuning = true
    local touchPoint = panel_team:convertTouchToNodeSpace(touch)
	for key, obj in pairs( image_base_team ) do
		local objX, objY = obj:getPosition()
		if touchPoint.x > objX - obj:getContentSize().width / 2 and touchPoint.x < objX + obj:getContentSize().width / 2 and
		touchPoint.y > objY - obj:getContentSize().height / 2 and touchPoint.y < objY + obj:getContentSize().height / 2 then
            _curTeamIndex = tonumber( key )
			local position = image_base_team[ key ]:convertTouchToNodeSpace(touch)
            getBeganCard( position )
			break
		end
	end
    if not _curTouchCard then
        local touchPoint = _moveScrollView:convertTouchToNodeSpace(touch)
        if touchPoint.x >= 0 and touchPoint.x <= _moveScrollView:getContentSize().width and touchPoint.y > 0 and touchPoint.y <= _moveScrollView:getContentSize().height then
         --   cclog( "began" )
            _curPositionX = _scrollView:getInnerContainer():getPositionX()
            _preX = touchPoint.x
            _preY = touchPoint.y
--         --   print( " x : " , touchPoint.x , " y : " , touchPoint.y )
            local childs = _scrollView:getChildren()
            for key, obj in pairs( childs ) do
                if obj:isVisible() then
		            local objX , objY = obj:getPositionX() + _curPositionX , obj:getPositionY()
             --       print( " objX : " , objX , " objY : " , objY )
		            if touchPoint.x > objX - obj:getContentSize().width / 2 and touchPoint.x < objX + obj:getContentSize().width / 2 and
		                touchPoint.y > objY - obj:getContentSize().height / 2 and touchPoint.y < objY + obj:getContentSize().height / 2 then
                        _preIcon = obj
                        local instCard = obj:getTag()
                        changeIcon( _curTouchItem , instCard )
                        _moveScrollView:setLocalZOrder( 2 )
                        panel_team:setLocalZOrder( 1 )
			            break
		            end
                end
	        end
        end
    end
	return true
end

local function onTouchMoved(touch, event)
 --   cclog( "move" )
    if _curTouchCard then
	    local position = image_base_team[ _curTeamIndex ]:convertTouchToNodeSpace(touch)
        local parentObj1 = image_base_team[ _curTeamIndex ]:getChildByName( "image_base_card" )
        local parentPX1 = parentObj1:getPositionX() - parentObj1:getContentSize().width / 2
        local parentPY1 = parentObj1:getPositionY() - parentObj1:getContentSize().height / 2
        local parentObj2 = image_base_team[ _curTeamIndex ]:getChildByName( "image_base_card_bu" )
        local parentPX2 = parentObj2:getPositionX() - parentObj2:getContentSize().width / 2
        local parentPY2 = parentObj2:getPositionY() - parentObj2:getContentSize().height / 2
        local parentPX , parentPY = 0 , 0
        if _curTouchCardIndex <= 6 then
            parentPX , parentPY = parentPX1 , parentPY1
        else
            parentPX , parentPY = parentPX2 , parentPY2
        end
        _curTouchCard:setPosition( cc.p( position.x - parentPX , position.y - parentPY ) )
    elseif _curTouchItem:getTag() > 0 then
        local touchPoint = _moveScrollView:convertTouchToNodeSpace(touch)
        local touchDisX = ( touchPoint.x - _preX )
        local touchDisY = ( touchPoint.y - _preY )
      --  print( "touchDisY :" , touchDisY )     
        if _isMove then
          --  print( "要求移动" )
            _curTouchItem:setPosition( cc.p( touchPoint.x , touchPoint.y ) )
        elseif touchDisY > 10 and touchDisY > math.abs( touchDisX ) then
           -- print( "要求拖动图标移动了" )
            _preIcon:setVisible( false )
            _curTouchItem:setVisible( true )
            _isMove = true
            _curTouchItem:setPosition( cc.p( touchPoint.x , touchPoint.y ) )
        elseif math.abs( touchDisX ) > 5 then
           -- print( "要求滚动条滚动" )
            local disX = _curPositionX + touchDisX
            local container = _scrollView:getInnerContainer()
            local width = ( container:getContentSize().width - _scrollView:getContentSize().width ) 
            if disX > 0 then
                disX = 0
            elseif disX < -width then
                disX = -width
            end
            scrollAssociatedView( disX )
        end
	end
end
--要交换的obj
local function getEndedCard( touchPoint , teamIndex )
    local curCardList = nil
    curCardList = team_card[ teamIndex ]
    if curCardList then
        local image_base_card = image_base_team[ teamIndex ]:getChildByName( "image_base_card" )
        local image_base_card_bu = image_base_team[ teamIndex ]:getChildByName( "image_base_card_bu" )
        local children = {}
        for i = 1 , 6 do
            children[ #children + 1 ] = image_base_card:getChildByName( "image_frame_card"..i )
        end
        
        for i = 1 , 1 do
            children[ #children + 1 ] = image_base_card_bu:getChildByName( "image_frame_card"..i )
        end
   --     cclog( "touchPoint: " .. touchPoint.x .. "  " .. touchPoint.y )
        local parentPX1 = image_base_card:getPositionX() - image_base_card:getContentSize().width / 2
        local parentPY1 = image_base_card:getPositionY() - image_base_card:getContentSize().height / 2
        local parentPX2 = image_base_card_bu:getPositionX() - image_base_card_bu:getContentSize().width / 2
        local parentPY2 = image_base_card_bu:getPositionY() - image_base_card_bu:getContentSize().height / 2
        for key, obj in pairs( children ) do
            local parentPX , parentPY = 0 , 0
            if tonumber( key ) <= 6 then
                parentPX , parentPY = parentPX1 , parentPY1
            else
                parentPX , parentPY = parentPX2 , parentPY2
            end
     --       cclog( "key :" .. key .. "parentPX : " .. parentPX .. " parentPY:" .. parentPY )
		    local objX, objY = parentPX + obj:getPositionX() , parentPY + obj:getPositionY()
		    if touchPoint.x > objX - obj:getContentSize().width / 2 and touchPoint.x < objX + obj:getContentSize().width / 2 and
		    touchPoint.y > objY - obj:getContentSize().height / 2 and touchPoint.y < objY + obj:getContentSize().height / 2 then
                
                if _curTeamIndex == teamIndex and key == _curTouchCardIndex then
                    
--                elseif curCardList[ key ] then
--                    return curCardList[ key ]
                else 
                  --  UIManager.showToast( "取消" .. key )
                    return key
                end
		    end
	    end 
    end
    return nil
end
--- 获取玩家战力值
local function getFightValue( teamIndex )
    local fightValue = 0
    if team_card[ teamIndex ] then
        local isNull = true
        for key, obj in pairs( team_card[ teamIndex ] ) do
            if obj then
                isNull = false
                local instCardId = obj
                -- 卡牌实例ID
                local attribute, fightSoulValue = utils.getCardAttribute(instCardId, 0 ,team_card[ teamIndex ])
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
local function refreshInfo()
    local cardList = nil
    for i = 1 , 3 do
        cardList = team_card[ i ]
        local image_lv = image_base_team[ i ]:getChildByName( "image_lv" )
        image_lv:getChildByName( "image_team" ):loadTexture( "ui/game_team" .. i .. ".png" )
        image_lv:getChildByName( "text_fight" ):setString( Lang.ui_game_embattle2 .. getFightValue( i ) )
        local image_base_card = image_base_team[ i ]:getChildByName( "image_base_card" )
        for j = 1 , 6 do
            local image_frame_card1 = image_base_card:getChildByName( "image_frame_card" .. j )
            image_frame_card1:setLocalZOrder( 0 )
            image_frame_card1:getChildByName( "image_lv" ):setVisible( false )
            image_frame_card1:getChildByName( "image_lv" ):getChildByName( "label_lv" ):setString( 0 )
            image_frame_card1:loadTexture( "ui/card_small_blue.png" )
            image_frame_card1:getChildByName( "image_card" ):loadTexture( "ui/game_" .. j .. ".png" )
            if cardList then
                if cardList[ j ] then
                    local instData = net.InstPlayerCard[ tostring( cardList[ j ] ) ]
                    image_frame_card1:loadTexture( utils.getQualityImage( dp.Quality.card , instData.int[ "4" ] , dp.QualityImageType.small ) )
                    local isAwake = instData.int["18"] --是否已觉醒 0-未觉醒 1-觉醒 --isAwake == 1 and dictCardData.awakeSmallUiId or dictCardData.smallUiId
                    image_frame_card1:getChildByName( "image_card" ):loadTexture( "image/" .. DictUI[ tostring( isAwake == 1 and DictCard[ tostring( instData.int[ "3" ] ) ].awakeSmallUiId or DictCard[ tostring( instData.int[ "3" ] ) ].smallUiId ) ].fileName ) 
                    image_frame_card1:getChildByName( "image_lv" ):setVisible( true )
                    image_frame_card1:getChildByName( "image_lv" ):getChildByName( "label_lv" ):setString( instData.int[ "5" ] - 1 )
                end
            end
        end
        local image_base_card_bu = image_base_team[ i ]:getChildByName( "image_base_card_bu" )
        for j = 1 , 1 do
            local image_frame_card1 = image_base_card_bu:getChildByName( "image_frame_card" .. j )
            image_frame_card1:setLocalZOrder( 0 )
            image_frame_card1:getChildByName( "image_lv" ):setVisible( false )
            image_frame_card1:getChildByName( "image_lv" ):getChildByName( "label_lv" ):setString( 0 )
            image_frame_card1:loadTexture( "ui/card_small_blue.png" )
            image_frame_card1:getChildByName( "image_card" ):loadTexture( "ui/frame_tianjia.png" )
            if cardList then
                if cardList[ 6 + j ] then
                    local instData = net.InstPlayerCard[ tostring( cardList[ 6 + j ] ) ]
                    image_frame_card1:loadTexture( utils.getQualityImage( dp.Quality.card , instData.int[ "4" ] , dp.QualityImageType.small ) )
                    local isAwake = instData.int["18"] --是否已觉醒 0-未觉醒 1-觉醒 --isAwake == 1 and dictCardData.awakeSmallUiId or dictCardData.smallUiId
                    image_frame_card1:getChildByName( "image_card" ):loadTexture( "image/" .. DictUI[ tostring( isAwake == 1 and DictCard[ tostring( instData.int[ "3" ] ) ].awakeSmallUiId or DictCard[ tostring( instData.int[ "3" ] ) ].smallUiId ) ].fileName ) 
                    image_frame_card1:getChildByName( "image_lv" ):setVisible( true )
                    image_frame_card1:getChildByName( "image_lv" ):getChildByName( "label_lv" ):setString( instData.int[ "5" ] - 1 )
                end
            end
        end
    end
end
--主力是否满了
local function isFullTeam( teamIndex )
    local count = 0
    if team_card[ teamIndex ] then
        for i = 1 , 6 do
            if team_card[ teamIndex ][ i ] then
                count = count + 1
            end
        end
    end
    if count >= 3 then
        return true
    end
    return false
end
local function onTouchEnded(touch, event)
  --  cclog( "ended" )
    if _curTouchCard then
        local objj = nil
        local touchPoint = panel_team:convertTouchToNodeSpace(touch)
	    for key, obj in pairs( image_base_team ) do
		    local objX, objY = obj:getPosition()
		    if touchPoint.x > objX - obj:getContentSize().width / 2 and touchPoint.x < objX + obj:getContentSize().width / 2 and
		    touchPoint.y > objY - obj:getContentSize().height / 2 and touchPoint.y < objY + obj:getContentSize().height / 2 then
			    local position = image_base_team[ key ]:convertTouchToNodeSpace(touch)
                objj = getEndedCard( position , key )
                if objj then
                    if _curTouchCardIndex > 6 and key == _curTeamIndex and tonumber( objj ) <= 6 and not team_card[ key ][ objj ] and isFullTeam( key ) then --主力已经3个了，不能再添加
                        UIManager.showToast( Lang.ui_game_embattle3 )
                    elseif key ~= _curTeamIndex and tonumber( objj ) <= 6 and not team_card[ key ][ objj ] and isFullTeam( key ) then --主力已经3个了，不能再添加
                        UIManager.showToast( Lang.ui_game_embattle4 )
                    else
                        team_card[ _curTeamIndex ][ _curTouchCardIndex ] , team_card[ key ][ objj ] = team_card[ key ][ objj ] , team_card[ _curTeamIndex ][ _curTouchCardIndex ]
                    end
                end
			    break
		    end
	    end

        if not objj then
            local touchPoint = _moveScrollView:convertTouchToNodeSpace(touch)
            local touchInstId = nil
            local inRect = nil
            if touchPoint.x >= 0 and touchPoint.x <= _moveScrollView:getContentSize().width and touchPoint.y > 0 and touchPoint.y <= _moveScrollView:getContentSize().height then
                _curPositionX = _scrollView:getInnerContainer():getPositionX()
                local childs = _scrollView:getChildren()
                for key, obj in pairs( childs ) do
                    if obj:isVisible() then
		                local objX , objY = obj:getPositionX() + _curPositionX , obj:getPositionY()
		                if touchPoint.x > objX - obj:getContentSize().width / 2 and touchPoint.x < objX + obj:getContentSize().width / 2 and
		                    touchPoint.y > objY - obj:getContentSize().height / 2 and touchPoint.y < objY + obj:getContentSize().height / 2 then
                            touchInstId = obj:getTag()
			                break
		                end
                    end
	            end
                inRect = true
            end
            if not inRect then
            elseif not touchInstId then
                team_card[ _curTeamIndex ][ _curTouchCardIndex ] = nil
            else
                team_card[ _curTeamIndex ][ _curTouchCardIndex ] = touchInstId
            end
        end

        _curTouchCard:setLocalZOrder( 0 )
        _curTouchCard:setPosition( _curCardPosition )
        image_base_team[ _curTeamIndex ]:setLocalZOrder( 0 )
        _curTouchCard = nil
        _curTouchCardIndex = nil
        _curCardPosition = nil
        refreshInfo()
        refreshScrollViewItem()
    elseif _curTouchItem:getTag() > 0 then
        local objj = nil
        local teamIndex = nil
        local touchPoint = panel_team:convertTouchToNodeSpace(touch)
        for key, obj in pairs( image_base_team ) do
		    local objX, objY = obj:getPosition()
		    if touchPoint.x > objX - obj:getContentSize().width / 2 and touchPoint.x < objX + obj:getContentSize().width / 2 and
		    touchPoint.y > objY - obj:getContentSize().height / 2 and touchPoint.y < objY + obj:getContentSize().height / 2 then
			    local position = image_base_team[ key ]:convertTouchToNodeSpace(touch)
                objj = getEndedCard( position , key )
                teamIndex = key
			    break
		    end
	    end
        if objj then
            if objj <= 6 and not team_card[ teamIndex ][ objj ] and isFullTeam( teamIndex ) then --主力已经3个了，不能再添加
                UIManager.showToast( Lang.ui_game_embattle5 )
            elseif team_card[ teamIndex ][ objj ] then 
                team_card[ teamIndex ][ objj ] = _curTouchItem:getTag()
                cclog( "队伍换人" )
            else
                team_card[ teamIndex ][ objj ] = _curTouchItem:getTag()
                cclog( "队伍加人" )
            end
            refreshInfo()
            refreshScrollViewItem()
        else
            if _preIcon then
                _preIcon:setVisible( true )
            end
        end
        _curTouchItem:setVisible( false )
        _curTouchItem:setTag( -1 )
        _preIcon = nil
    end
    _isMove = nil
    _curTeamIndex = nil
    _isRuning = false
    _moveScrollView:setLocalZOrder( 1 )
    panel_team:setLocalZOrder( 2 )
end
--是否已经在阵中了
local function isInTeam( instId )
    local isFull = false
    if team_card then
        for i = 1 , 7 do
            if team_card[ 1 ][ i ] and team_card[ 1 ][ i ] == instId then    
                isFull = true               
                break
            end
        end
    end
    if not isFull and team_card[ 2 ] then
        for i = 1 , 7 do
            if team_card[ 2 ][ i ] and team_card[ 2 ][ i ] == instId then    
                isFull = true               
                break
            end
        end
    end
    if not isFull and team_card[ 3 ] then
        for i = 1 , 7 do
            if team_card[ 3 ][ i ] and team_card[ 3 ][ i ] == instId  then    
                isFull = true               
                break
            end
        end
    end
    return isFull
end

local function refreshScrollView()
--    local children = _scrollView:getChildren()
--    for key ,item in pairs( children ) do
--        local instData = net.InstPlayerCard[ tostring( item:getTag() ) ]
--        item:loadTexture( utils.getQualityImage( dp.Quality.card , instData.int[ "4" ] , dp.QualityImageType.small ) )
--        item:getChildByName( "image_card" ):loadTexture( "image/" .. DictUI[ tostring( DictCard[ tostring( instData.int[ "3" ] ) ].smallUiId ) ].fileName ) 
--        item:getChildByName( "image_lv" ):getChildByName( "label_lv" ):setString( instData.int[ "5" ] - 1 )    
--        if isInTeam( item:getTag() ) then
--            item:getChildByName( "image_choose" ):setVisible( true )
--        else
--            item:getChildByName( "image_choose" ):setVisible( false )
--        end
--    end
end
local function sendEmbattle( callBack )
    local function getFormationId( id )
        for key ,value in pairs( net.InstPlayerFormation ) do
            if value.int[ "3" ] == tonumber( id ) then
                return value.int[ "1" ]
            end
        end
        return 0
    end
    local aa = ""
    local bb = ""
    local cc = ""
    for i = 1 , 8 do
        if team_card[ 1 ][ i ] and team_card[ 1 ][ i ] > 0 then
            aa = aa .. getFormationId( team_card[ 1 ][ i ] )
        else
            aa = aa .. "0"
        end
        if team_card[ 2 ][ i ] and team_card[ 2 ][ i ] > 0 then
            bb = bb .. getFormationId( team_card[ 2 ][ i ] )
        else
            bb = bb .. "0"
        end
        if team_card[ 3 ][ i ] and team_card[ 3 ][ i ] > 0 then
            cc = cc .. getFormationId( team_card[ 3 ][ i ] )
        else
            cc = cc .. "0"
        end
        if i ~= 8 then
            aa = aa .. "_"
            bb = bb .. "_"
            cc = cc .. "_"
        end
    end
    cclog( " aa :" .. aa .. " bb :" .. bb .. " cc :" .. cc )
    UIManager.showLoading()
    netSendPackage( { header = StaticMsgRule.challengeFormation , msgdata = { string = { formations = aa .. ";" .. bb .. ";" .. cc } } } , callBack )
end
function UIGameEmbattle.init()
    local btn_back = ccui.Helper:seekNodeByName( UIGameEmbattle.Widget , "btn_back" )
    panel_team = ccui.Helper:seekNodeByName( UIGameEmbattle.Widget , "panel_team" )
    panel_team:setClippingEnabled( false )
    ccui.Helper:seekNodeByName( UIGameEmbattle.Widget , "image_di" ):setVisible( false )
    for i = 1 , 3 do
        image_base_team[ i ] = panel_team:getChildByName( "image_base_team" .. i )
        image_base_team[ i ]:setLocalZOrder( 0 )
        image_base_team[ i ]:setTouchEnabled( false )

        local base_card_bu = image_base_team[ i ]:getChildByName( "image_base_card_bu" )
        local di1 = base_card_bu:getChildByName( "image_frame_card1_di" )
        local di2 = base_card_bu:getChildByName( "image_frame_card2_di" )
        local bu1 = base_card_bu:getChildByName( "image_frame_card1" )
        local bu2 = base_card_bu:getChildByName( "image_frame_card2" )
        di1:setPositionX( di1:getPositionX() + 40 )
        bu1:setPositionX( bu1:getPositionX() + 40 )
        di1:setPositionY( di1:getPositionY() + 5 )
        bu1:setPositionY( bu1:getPositionY() + 5 )
        di2:setVisible( false )
        bu2:setVisible( false )
    end

    local btn_out1 = image_base_team[ 1 ]:getChildByName( "btn_out" )
    local btn_out2 = image_base_team[ 2 ]:getChildByName( "btn_out" )
    local btn_out3 = image_base_team[ 3 ]:getChildByName( "btn_out" )
    local btn_luck1 = image_base_team[ 1 ]:getChildByName( "btn_luck" )
    local btn_luck2 = image_base_team[ 2 ]:getChildByName( "btn_luck" )
    local btn_luck3 = image_base_team[ 3 ]:getChildByName( "btn_luck" )
    local function onEvent( sender , eventType )
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_back then
                local isBack = true
                for i = 1 , 3 do
                    if team_card[ i ] then
                        for j = 1 , 6 do
                            if team_card[ i ][ j ] then
                                break
                            elseif j == 6 then
                                isBack = false
                            end
                        end
                    end
                end
                if isBack then
                    sendEmbattle( function ()
                        UIManager.showWidget( "ui_game" )
                    end)
                else
                    UIManager.showToast( Lang.ui_game_embattle6 )
                end
            elseif sender == btn_out1 then
                team_card[ 1 ] = {}
                refreshInfo()
                refreshScrollViewItem()
            elseif sender == btn_out2 then
                team_card[ 2 ] = {}
                refreshInfo()
                refreshScrollViewItem()
            elseif sender == btn_out3 then
                team_card[ 3 ] = {}
                refreshInfo()
                refreshScrollViewItem()
            elseif sender == btn_luck1 then
                UIGameLuck.setData( team_card[ 1 ] )
                UIManager.pushScene( "ui_game_luck" )
            elseif sender == btn_luck2 then
                UIGameLuck.setData( team_card[ 2 ] )
                UIManager.pushScene( "ui_game_luck" )
            elseif sender == btn_luck3 then
                UIGameLuck.setData( team_card[ 3 ] )
                UIManager.pushScene( "ui_game_luck" )
            end
        end
    end
    btn_back:setPressedActionEnabled( true )
    btn_back:addTouchEventListener( onEvent )
    btn_out1:setPressedActionEnabled( true )
    btn_out1:addTouchEventListener( onEvent )
    btn_out2:setPressedActionEnabled( true )
    btn_out2:addTouchEventListener( onEvent )
    btn_out3:setPressedActionEnabled( true )
    btn_out3:addTouchEventListener( onEvent )
    btn_luck1:setPressedActionEnabled( true )
    btn_luck1:addTouchEventListener( onEvent )
    btn_luck2:setPressedActionEnabled( true )
    btn_luck2:addTouchEventListener( onEvent )
    btn_luck3:setPressedActionEnabled( true )
    btn_luck3:addTouchEventListener( onEvent )

    _scrollView = ccui.Helper:seekNodeByName( UIGameEmbattle.Widget , "view_warrior" )
    _item = _scrollView:getChildByName( "image_frame_card" )
    _item:retain()

    local listener = cc.EventListenerTouchOneByOne:create()
	listener:setSwallowTouches(true)
	listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
	listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
	local eventDispatcher = panel_team:getEventDispatcher()
    eventDispatcher:removeEventListenersForTarget(panel_team)
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, panel_team)

    _moveScrollView = _scrollView:clone()
    _moveScrollView:removeAllChildren()
    _scrollView:setLocalZOrder( 0 )
    _scrollView:getParent():addChild( _moveScrollView , _scrollView:getLocalZOrder() + 1 )
    local listener1 = cc.EventListenerTouchOneByOne:create()
	listener1:setSwallowTouches(true)
	listener1:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	listener1:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
	listener1:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
	local eventDispatcher1 = _moveScrollView:getEventDispatcher()
	eventDispatcher1:addEventListenerWithSceneGraphPriority(listener1, _moveScrollView)
    _moveScrollView:setClippingEnabled( false )
    _moveScrollView:setTouchEnabled( false )

    btn_back:setLocalZOrder( 100 )


    _curTouchItem = _item:clone()
    _curTouchItem:setTag( -1 )
    _curTouchItem:getChildByName( "image_choose" ):setVisible( false )
    _curTouchItem:setVisible( false )
    _moveScrollView:addChild( _curTouchItem )

    _moveScrollView:setLocalZOrder( 1 )
    panel_team:setLocalZOrder( 2 )
end

--changeType 1 ， 上阵容 2 ，下阵容 返回：true , false ：满了 上不去了 
local function changeTeamInfo( changeType , instId )
    local isFull = false
    if changeType == 1 then
        if team_card[ 1 ] then
            for i = 1 , 7 do
                if ( ( i <= 6 and not isFullTeam( 1 ) ) or i > 6 ) and not team_card[ 1 ][ i ] then    
                    isFull = true               
                    team_card[ 1 ][ i ] = instId
                    break
                end              
            end
        end
        if not isFull and team_card[ 2 ] then
            for i = 1 , 7 do
                if ( ( i <= 6 and not isFullTeam( 2 ) ) or i > 6 ) and not team_card[ 2 ][ i ] then    
                    isFull = true               
                    team_card[ 2 ][ i ] = instId
                    break
                end
            end
        end
        if not isFull and team_card[ 3 ] then
            for i = 1 , 7 do
                if ( ( i <= 6 and not isFullTeam( 3 ) ) or i > 6 ) and not team_card[ 3 ][ i ] then    
                    isFull = true               
                    team_card[ 3 ][ i ] = instId
                    break
                end
            end
        end
    elseif changeType == 2 then
        for i = 1 , 7 do
            if team_card[ 1 ][ i ] and team_card[ 1 ][ i ] == instId then    
                isFull = true               
                team_card[ 1 ][ i ] = nil
                break
            end
        end
        if not isFull then
            for i = 1 , 7 do
                if team_card[ 2 ][ i ] and team_card[ 2 ][ i ] == instId then    
                    isFull = true               
                    team_card[ 2 ][ i ] = nil
                    break
                end
            end
        end
        if not isFull then
            for i = 1 , 7 do
                if team_card[ 3 ][ i ] and team_card[ 3 ][ i ] == instId  then    
                    isFull = true               
                    team_card[ 3 ][ i ] = nil
                    break
                end
            end
        end
    end
    return isFull
end


--得到实力id
local function getInstPlayerCardId( formationId )
    if tonumber( formationId ) == 0 then
        return nil
    end
    return net.InstPlayerFormation[ tostring( formationId) ].int[ "3" ]
end
function UIGameEmbattle.setup()
    team_card = {}
    team_card[ 1 ] = {}
    team_card[ 2 ] = {}
    team_card[ 3 ] = {}
    local formations = utils.stringSplit( _formations , ";" )
    for i = 1 , 3 do
        local aa = utils.stringSplit( formations[ i ] , "_" )
        for j = 1 , #aa do
            team_card[ i ][ j ] = getInstPlayerCardId( aa[ j ] )
        end
    end

    local image_bian = ccui.Helper:seekNodeByName( UIGameEmbattle.Widget , "image_bian" )
    image_bian:getChildByName( "image_fight" ):getChildByName( "label_fight" ):setString( utils.getFightValue() ) --战斗力
    image_bian:getChildByName( "image_gold" ):getChildByName( "text_gold_number" ):setString( net.InstPlayer.int[ "5" ] ) --金币
    image_bian:getChildByName( "image_silver" ):getChildByName( "text_silver_number" ):setString( net.InstPlayer.string[ "6" ] ) --银币

    refreshScrollViewItem()

    refreshInfo()
end
function UIGameEmbattle.free()
    _cardData = nil
    _curTouchCard = nil
    _curTeamIndex = nil
    _curTouchCardIndex = nil
    _curCardPosition = nil
    _isRuning = nil
    team_card = nil
    _formations = nil
    _curPositionX = nil
    _preX = nil
    _preY = nil
    _preIcon = nil
end
function UIGameEmbattle.setData( data )
    _formations = data.formations
end
