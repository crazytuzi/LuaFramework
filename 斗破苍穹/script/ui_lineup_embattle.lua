require"Lang"
UILineupEmbattle = {}

local FLAG_MAIN = 1 --主力标识位
local FLAG_BENCH = 2 --替补标识位
local POINTS = {{x=-205,y=199},{x=0,y=199},{x=205,y=199},{x=-205,y=27},{x=0,y=27},{x=205,y=27},{x=-205,y=-199},{x=0,y=-199},{x=205,y=-199}}

local uiPanel = nil
local uiCardItem = nil
local ui_mainFlag = nil
local ui_benchFlag = nil

local _curPositionList = nil
local _curTouchCard = nil

local _isRefreshLineup = nil
local _isRuning = false

local _InstPlayerPartner = nil

local ui_friends = nil

local _friendCardItem = nil

local ui_friendPanel = nil

local _item = nil

local _isTouchFriend = nil

local _curFriendPositionList = nil

local _isOpenFriend = nil

local _friendPreId = nil --原来的

local _friendCurId = nil --后来的

local _teamPreId = nil

local _teamCurId = nil

local _friendPosX = nil

local _friendPosY = nil

local aaa = nil

local function netCallbackFunc(data)
	if data and _isRefreshLineup then
		UIManager.flushWidget(UILineup)
	end
	UIManager.popScene()
	_isRefreshLineup = nil
end
local function getRealKey(key1)
    for key2 ,value in pairs( aaa ) do
        if tonumber( value ) == tonumber( key1 ) then
            key = key2
            return key
        end
    end
    return nil
end
local function refreshFriendCardItem( key1 )
    local key = getRealKey( key1 )
    
    ui_friends[ key ]:getChildByName( "image_friend" ):setVisible( false )
    ui_friends[ key ]:loadTexture( "ui/card_small_purple.png" )
    local instPartner = _InstPlayerPartner[ aaa[ key ] ]
  --  print( "instPartner :" , instPartner.int[ "4" ] )
    local instCardData = net.InstPlayerCard[tostring(instPartner.int[ "3" ])] --卡牌实例数据
    local dictCardData = DictCard[ tostring( instPartner.int[ "6" ] ) ]
    local _isAwake = instCardData.int["18"]
    ccui.Helper:seekNodeByName( _friendCardItem , "image_card" ):loadTexture( "image/"..DictUI[ tostring(_isAwake == 1 and dictCardData.awakeBigUiId or dictCardData.bigUiId ) ].fileName )
    ccui.Helper:seekNodeByName( _friendCardItem , "text_name" ):setString((_isAwake == 1 and Lang.ui_lineup_embattle1 or "") .. dictCardData.name ) 
   -- print( "" , utils.getQualityImage( dp.Quality.card , DictCard[ tostring( instPartner.int[ "6" ] ) ].qualityId , dp.QualityImageType.middle ) )
    ccui.Helper:seekNodeByName( _friendCardItem , "image_frame_card" ):loadTexture( utils.getQualityImage( dp.Quality.card , instCardData.int["4"] , dp.QualityImageType.middle ) )
end
local function onTouchBegan1(touch, event)
	local touchPoint = ui_friendPanel:convertTouchToNodeSpace(touch)
    for key, obj in pairs(ui_friends) do
		local objX, objY = obj:getPosition()
		if touchPoint.x > objX - obj:getContentSize().width / 2 and touchPoint.x < objX + obj:getContentSize().width / 2 and
		touchPoint.y > objY - obj:getContentSize().height / 2 and touchPoint.y < objY + obj:getContentSize().height / 2 then
            if _InstPlayerPartner[ aaa[ key ] ] then
                _isTouchFriend = true
                _friendCardItem:setTag(aaa[key])
                refreshFriendCardItem( aaa[key] )
			    _curTouchCard = _friendCardItem
                _friendCardItem:setPosition( cc.p( _friendPosX + touchPoint.x , _friendPosY + touchPoint.y ) )
                _friendCardItem:setVisible( true )
            end
			break
		end
	end
	return true
end

local function onTouchBegan(touch, event)
	if _isRuning then
		return false
	end
	_isRuning = true
	local touchPoint = uiPanel:convertTouchToNodeSpace(touch)
	local childs = uiPanel:getChildren()
	for key, obj in pairs(childs) do
		local objX, objY = obj:getPosition()
		if touchPoint.x > objX - obj:getContentSize().width / 2 and touchPoint.x < objX + obj:getContentSize().width / 2 and
		touchPoint.y > objY - obj:getContentSize().height / 2 and touchPoint.y < objY + obj:getContentSize().height / 2 then
            _isTouchFriend = false
			_curTouchCard = obj
			_curTouchCard:setLocalZOrder(1)
			break
		end
	end
    if not _curTouchCard then
        onTouchBegan1( touch , event)
    end
	return true
end

local function onTouchMoved(touch, event)
	local touchPoint = nil
    if _curTouchCard then
        if _isTouchFriend then
            touchPoint = ui_friendPanel:convertTouchToNodeSpace(touch)
            _curTouchCard:setPosition( cc.p( _friendPosX + touchPoint.x , _friendPosY + touchPoint.y ) )
        else
            touchPoint = uiPanel:convertTouchToNodeSpace(touch)
            _curTouchCard:setPosition(touchPoint)
        end
	end
end
local function refreshFriendItem( key1 )
    local key = getRealKey(key1)
    local friendObj = ui_friends[ key ]
    if _InstPlayerPartner[ aaa[ key ] ] then
        local instCardData = net.InstPlayerCard[tostring(_InstPlayerPartner[ aaa[ key ] ].int[ "3" ])] --卡牌实例数据
        local dictCardData = DictCard[ tostring( _InstPlayerPartner[ aaa[ key ] ].int[ "6" ] ) ]
        local _isAwake = instCardData.int["18"]
        ccui.Helper:seekNodeByName( friendObj , "image_friend" ):setVisible( true )       
        ccui.Helper:seekNodeByName( friendObj , "image_base_friend_name" ):setVisible( true )
        ccui.Helper:seekNodeByName( friendObj , "image_friend" ):loadTexture( "image/"..DictUI[ tostring(_isAwake == 1 and dictCardData.awakeSmallUiId or dictCardData.smallUiId ) ].fileName )       
        ccui.Helper:seekNodeByName( friendObj , "text_friend_name" ):setString((_isAwake == 1 and Lang.ui_lineup_embattle2 or "") .. dictCardData.name )
        friendObj:loadTexture( utils.getQualityImage( dp.Quality.card , instCardData.int[ "4" ] , dp.QualityImageType.small ) )
    else
        ccui.Helper:seekNodeByName( friendObj , "image_friend" ):setVisible( false )       
        ccui.Helper:seekNodeByName( friendObj , "image_base_friend_name" ):setVisible( false ) 
        friendObj:loadTexture( "ui/card_small_purple.png" )
    end
end
local function changeFriendTeam( teamId , friendId )
    local isIn = false
    for key , value in pairs( _friendCurId ) do
        if tonumber( value ) == tonumber( friendId ) then
            _friendCurId[ key ] = teamId
            isIn = true
            break
        end
    end
    if not isIn then
        for key , value in pairs( _friendPreId ) do
            if tonumber( value ) == tonumber( friendId ) then
                _friendCurId[ key ] = teamId
                isIn = true
                break
            end
        end
    end
    isIn = false
    for key , value in pairs( _teamCurId ) do
        if tonumber( value ) == tonumber( teamId ) then
            _teamCurId[ key ] = friendId
            isIn = true
            break
        end
    end
    if not isIn then
        for key , value in pairs( _teamPreId ) do
            if tonumber( value ) == tonumber( teamId ) then
                _teamCurId[ key ] = friendId
                isIn = true
                break
            end
        end
    end
--    print("----------------------")
--    for i = 1 , #_friendCurId do
--    print( _friendPreId[ i ] , "   " , _friendCurId[ i ] )
--    end
--    print("----------------------")
--    for i = 1 , #_teamCurId do
--    print( _teamPreId[ i ] , "   " , _teamCurId[ i ] )
--    end
--    print("----------------------")
--    print( teamId , "  " , friendId )
end
local function onTouchEnded(touch, event)
    if _isTouchFriend then
        
        if _curTouchCard then
            _friendCardItem:setVisible( false )
            
            local key = getRealKey( _friendCardItem:getTag() )

            ui_friends[ key ]:getChildByName( "image_friend" ):setVisible( true )
            local instPartner = _InstPlayerPartner[ aaa[ key ] ]
            local instCardData = net.InstPlayerCard[tostring(instPartner.int[ "3" ])] --卡牌实例数据 
            ui_friends[ key ]:loadTexture(utils.getQualityImage(dp.Quality.card, instCardData.int[ "4" ], dp.QualityImageType.small))

            local touchPoint = uiPanel:convertTouchToNodeSpace(touch)
            local tempObj = nil
		    local childs = uiPanel:getChildren()
		    for key, obj in pairs(childs) do
			    if obj ~= _curTouchCard then
				    local objX, objY = obj:getPosition()
				    if touchPoint.x > objX - obj:getContentSize().width / 2 and touchPoint.x < objX + obj:getContentSize().width / 2 and
				    touchPoint.y > objY - obj:getContentSize().height / 2 and touchPoint.y < objY + obj:getContentSize().height / 2 then
					    tempObj = obj
                       -- print( "tag :" , obj:getTag() )                       
					    break
				    end
			    end
		    end
            if tempObj then
                local instCardData = net.InstPlayerCard[tostring(_InstPlayerPartner[ _curTouchCard:getTag() ].int[ "3" ])] --卡牌实例数据
                local dictCardData = DictCard[ tostring( _InstPlayerPartner[ _curTouchCard:getTag() ].int[ "6" ] ) ] 
                local isAwake = instCardData.int["18"]
                local cardFrame = tempObj:getChildByName("image_frame_card")
                local tempInstCardId = cardFrame:getTag()
                cardFrame:setTag( _InstPlayerPartner[ _curTouchCard:getTag() ].int[ "3" ] )
                print( "inst:" , tempInstCardId , "   " , _InstPlayerPartner[ _curTouchCard:getTag() ].int[ "3" ] )
                changeFriendTeam( tempInstCardId , _InstPlayerPartner[ _curTouchCard:getTag() ].int[ "3" ] )

                cardFrame:getChildByName( "image_card" ):loadTexture( "image/"..DictUI[ tostring(isAwake == 1 and dictCardData.awakeBigUiId or dictCardData.bigUiId ) ].fileName )
                
                cardFrame:loadTexture( utils.getQualityImage( dp.Quality.card , instCardData.int[ "4" ] , dp.QualityImageType.middle ) )
                ccui.Helper:seekNodeByName(cardFrame, "text_name"):setString((isAwake == 1 and Lang.ui_lineup_embattle3 or "") .. dictCardData.name )             
                _InstPlayerPartner[ _curTouchCard:getTag() ].int[ "3" ] = tempInstCardId
                _InstPlayerPartner[ _curTouchCard:getTag() ].int[ "6" ] = net.InstPlayerCard[tostring(tempInstCardId)].int["3"]   
                refreshFriendItem( _curTouchCard:getTag() )
            else
                touchPoint = ui_friendPanel:convertTouchToNodeSpace(touch)
                tempObj = nil
                local tempKey = nil
		        local childs = uiPanel:getChildren()
		        for key, obj in pairs( ui_friends ) do
			        if key ~= _curTouchCard:getTag() then
				        local objX, objY = obj:getPosition()
				        if touchPoint.x > objX - obj:getContentSize().width / 2 and touchPoint.x < objX + obj:getContentSize().width / 2 and
				        touchPoint.y > objY - obj:getContentSize().height / 2 and touchPoint.y < objY + obj:getContentSize().height / 2 then
                            if _isOpenFriend and _isOpenFriend[ aaa [ key ] ] == 1 then
                            else
					            tempObj = obj
                                tempKey = aaa[ key ]
                            end
					        break
				        end
			        end
		        end
                if tempObj then
                    local tempPartner = _InstPlayerPartner[ tempKey ]
                    _InstPlayerPartner[ tempKey ] = _InstPlayerPartner[ _curTouchCard:getTag() ]
                    _InstPlayerPartner[ _curTouchCard:getTag() ] = tempPartner
                    refreshFriendItem( _curTouchCard:getTag() )
                    refreshFriendItem( tempKey )
                end

            end
            _curTouchCard = nil
        end
    else
	    if _curTouchCard then
		    local tempObj = nil
		    local childs = uiPanel:getChildren()
		    for key, obj in pairs(childs) do
			    if obj ~= _curTouchCard then
				    local objX, objY = obj:getPosition()
				    if _curTouchCard:getPositionX() > objX - obj:getContentSize().width / 2 and _curTouchCard:getPositionX() < objX + obj:getContentSize().width / 2 and
				    _curTouchCard:getPositionY() > objY - obj:getContentSize().height / 2 and _curTouchCard:getPositionY() < objY + obj:getContentSize().height / 2 then
					    local tempTag = _curTouchCard:getTag()
					    _curTouchCard:setTag(obj:getTag())
					    obj:setTag(tempTag)
					    tempObj = obj
					    break
				    end
			    end
		    end
		    if tempObj then
             --   print("这")
			    tempObj:setPosition(cc.p(POINTS[tempObj:getTag()].x + uiPanel:getContentSize().width / 2, POINTS[tempObj:getTag()].y + uiPanel:getContentSize().height / 2))
		        _curTouchCard:setPosition(cc.p(POINTS[_curTouchCard:getTag()].x + uiPanel:getContentSize().width / 2, POINTS[_curTouchCard:getTag()].y + uiPanel:getContentSize().height / 2))
            else
                
                local touchPoint = ui_friendPanel:convertTouchToNodeSpace(touch)
                local tempKey = nil
                for key, obj in pairs(ui_friends) do
				    local objX, objY = obj:getPosition()
				    if touchPoint.x > objX - obj:getContentSize().width / 2 and touchPoint.x < objX + obj:getContentSize().width / 2 and
				    touchPoint.y > objY - obj:getContentSize().height / 2 and touchPoint.y < objY + obj:getContentSize().height / 2 then
					    if _InstPlayerPartner[ aaa[ key ] ] then
					        tempObj = obj
                            tempKey = aaa[ key ]
                        end
					    break
				    end
		        end
                if tempObj then                   

                    local cardFrame = _curTouchCard:getChildByName("image_frame_card")
                    local tempInstCardId = cardFrame:getTag()
                    local tempKeyInstCardId = _InstPlayerPartner[ tempKey ].int[ "3" ]
                    cardFrame:setTag( tempKeyInstCardId )

                    changeFriendTeam( tempInstCardId , tempKeyInstCardId )
                    
                    local instPlayerCardData = net.InstPlayerCard[tostring(tempKeyInstCardId)]
                    local dictCardData = DictCard[ tostring( instPlayerCardData.int["3"] ) ]
                    local isAwake = instPlayerCardData.int["18"]
                    cardFrame:getChildByName( "image_card" ):loadTexture( "image/"..DictUI[ tostring(isAwake == 1 and dictCardData.awakeBigUiId or dictCardData.bigUiId ) ].fileName )
                    cardFrame:loadTexture( utils.getQualityImage( dp.Quality.card , net.InstPlayerCard[tostring(tempKeyInstCardId)].int["4"] , dp.QualityImageType.middle ) )
                    ccui.Helper:seekNodeByName(cardFrame, "text_name"):setString((isAwake == 1 and Lang.ui_lineup_embattle4 or "") .. dictCardData.name )             
                    
                    _InstPlayerPartner[ tempKey ].int[ "3" ] = tempInstCardId
                    _InstPlayerPartner[ tempKey ].int[ "6" ] = net.InstPlayerCard[tostring(tempInstCardId)].int["3"]               
                    _curTouchCard:setPosition(cc.p(POINTS[_curTouchCard:getTag()].x + uiPanel:getContentSize().width / 2, POINTS[_curTouchCard:getTag()].y + uiPanel:getContentSize().height / 2))
                    refreshFriendItem( tempKey )
                else
                --    print("那")
			        local itemSize = _curTouchCard:getContentSize()
			        if _curTouchCard:getTag() <= 6 then
				        for i = 1, 6 do
					        if i ~= _curTouchCard:getTag() then
						        local pX, pY = POINTS[i].x + uiPanel:getContentSize().width / 2, POINTS[i].y + uiPanel:getContentSize().height / 2
				 		        if _curTouchCard:getPositionX() > pX - itemSize.width / 2 and _curTouchCard:getPositionX() < pX + itemSize.width / 2 and
				 		        _curTouchCard:getPositionY() > pY - itemSize.height / 2 and _curTouchCard:getPositionY() < pY + itemSize.height / 2 then
				 			        _curTouchCard:setTag(i)
				 			        break
				 		        end
					        end
				        end
			        else
				        for i = 7, #POINTS do
					        if i ~= _curTouchCard:getTag() then
						        local pX, pY = POINTS[i].x + uiPanel:getContentSize().width / 2, POINTS[i].y + uiPanel:getContentSize().height / 2
						        if _curTouchCard:getPositionX() > pX - itemSize.width / 2 and _curTouchCard:getPositionX() < pX + itemSize.width / 2 and
				 		        _curTouchCard:getPositionY() > pY - itemSize.height / 2 and _curTouchCard:getPositionY() < pY + itemSize.height / 2 then
				 			        _curTouchCard:setTag(i)
				 			        break
				 		        end
					        end
				        end
			        end
                    _curTouchCard:setPosition(cc.p(POINTS[_curTouchCard:getTag()].x + uiPanel:getContentSize().width / 2, POINTS[_curTouchCard:getTag()].y + uiPanel:getContentSize().height / 2))
		        end
            end
		    _curTouchCard:setLocalZOrder(0)
		    _curTouchCard = nil
	    end
    end
	_isRuning = false
end


function UILineupEmbattle.init()
	local image_base_name_up = ccui.Helper:seekNodeByName(UILineupEmbattle.Widget, "image_base_name_up")
	ui_mainFlag = ccui.Helper:seekNodeByName(image_base_name_up, "text_hint")
	local image_base_name_bench = ccui.Helper:seekNodeByName(UILineupEmbattle.Widget, "image_base_name_bench")
	ui_benchFlag = ccui.Helper:seekNodeByName(image_base_name_bench, "text_hint")

	local btn_close = ccui.Helper:seekNodeByName(UILineupEmbattle.Widget, "btn_close")
	local btn_back = ccui.Helper:seekNodeByName(UILineupEmbattle.Widget, "btn_back")
	btn_close:setPressedActionEnabled(true)
	btn_back:setPressedActionEnabled(true)
	local function btnEvent(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			AudioEngine.playEffect("sound/button.mp3")
			local positionList = ""
			local childs = uiPanel:getChildren()
			local isIdentical = true
			for key, obj in pairs(childs) do
				local instCardId = obj:getChildByName("image_frame_card"):getTag()
				local type = FLAG_MAIN
				local position = obj:getTag()
				if position > 6 then
					position = position - 6
					type = FLAG_BENCH
				end
                print( "instCardId " , instCardId , "type " , type , "position " , position )
				positionList = positionList .. instCardId .. "_" .. type .."_" .. position .. "_0" .. ";"
				if _curPositionList[obj:getTag()] ~= instCardId .. "_" .. type .. "_" .. position .. "_0" then
                    print("111111111111111")
					isIdentical = false
				end
			end
            --加小伙伴
            for key ,obj in pairs( _InstPlayerPartner ) do
                print("partner key : " , obj.int["3"] , "type " , 3 , "position " , key )
                positionList = positionList .. obj.int["3"] .. "_" .. 3 .. "_" .. key .. "_" .. obj.int["10"] .. ";"
                if _curFriendPositionList[ key ] ~= obj.int["3"] .. "_" .. 3 .. "_" .. key .. "_" .. obj.int["10"] then
                    print("22222222222")
                    isIdentical = false
                end
            end

			positionList = string.sub(positionList, 1, string.len(positionList) - 1)
            
            local friendList = ""
            for key , value in pairs( _friendPreId ) do
                friendList = friendList .. value .. "_" .. _friendCurId[ key ]
                if tonumber( value ) ~= tonumber( _friendCurId[ key ] ) then
                    print("3333333333333")
                    isIdentical = false
                end
                if tonumber( key ) ~= #_friendPreId then
                    friendList = friendList .. ";"
                end
            end
            local teamList = ""
            for key , value in pairs( _teamPreId ) do
                teamList = teamList .. value .. "_" .. _teamCurId[ key ]
                if tonumber( value ) ~= tonumber( _teamCurId[ key ] ) then
                    print("4444444444444444")
                    isIdentical = false
                end
                if tonumber( key ) ~= #_teamPreId then
                    teamList = teamList .. ";"
                end
            end

			if not isIdentical then
				cclog("---------->>>  " .. positionList)
                print( "yFireList :" , teamList )
                print( "enchantmentList :" , friendList )
				local sendData = {
					header = StaticMsgRule.convertPosition,
					msgdata = {
						string = {
							positionList = positionList , 
                            yFireList = teamList ,
                            enchantmentList = friendList 
						}
					}
				}
				UIManager.showLoading()
				netSendPackage(sendData, netCallbackFunc)
			else
				netCallbackFunc()
			end
			
		end
	end
	btn_close:addTouchEventListener(btnEvent)
	btn_back:addTouchEventListener(btnEvent)
	
	uiPanel = ccui.Helper:seekNodeByName(UILineupEmbattle.Widget, "image_base_card_up")
	local listener = cc.EventListenerTouchOneByOne:create()
	listener:setSwallowTouches(true)
	listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
	listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
	local eventDispatcher = uiPanel:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, uiPanel)
	
	uiCardItem = uiPanel:getChildByName("image_base_card"):clone()
	if uiCardItem:getReferenceCount() == 1 then
		uiCardItem:retain()
	end
    
    ui_friendPanel = ccui.Helper:seekNodeByName(UILineupEmbattle.Widget,"view_friend")
    _item = ui_friendPanel:getChildByName("image_frame_friend")
    _item:retain()

    local listener1 = cc.EventListenerTouchOneByOne:create()
	listener1:setSwallowTouches(true)
	listener1:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	listener1:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
	listener1:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher1 = ui_friendPanel:getEventDispatcher()
	eventDispatcher1:addEventListenerWithSceneGraphPriority(listener1, ui_friendPanel)	

    _friendCardItem = ui_friendPanel:getChildByName("image_base_card"):clone() -- ccui.Helper:seekNodeByName(UILineupEmbattle.Widget,"image_basemap"):getChildByName("image_base_card")
    _friendCardItem:setAnchorPoint( cc.p( 0.5 , 0.2 ) )
    _friendCardItem:setVisible( false )

    local p = ui_friendPanel:getParent()
    _friendPosX = p:getPositionX() - p:getContentSize().width / 2 + ui_friendPanel:getPositionX()
    _friendPosY = p:getPositionY() - p:getContentSize().height / 2 + ui_friendPanel:getPositionY()

    UILineupEmbattle.Widget:addChild( _friendCardItem , 10000 )

    btn_close:setZOrder( ui_friendPanel:getZOrder() + 4 )
    btn_back:setZOrder( ui_friendPanel:getZOrder() + 4 )
    uiPanel:setZOrder( ui_friendPanel:getZOrder() + 1 )
   -- _friendCardItem:setZOrder( ui_friendPanel:getZOrder() + 3 )
    image_base_name_bench:setZOrder( ui_friendPanel:getZOrder() + 2 )
    image_base_name_up:setZOrder( ui_friendPanel:getZOrder() + 2 )
end

function UILineupEmbattle.setup()
	uiPanel:removeAllChildren()
	_friendCurId = {}
    _friendPreId = {}
    _teamCurId = {}
    _teamPreId = {}
    ui_friends = {}
    aaa = {}
    
	local _teamCount, _benchCount = 0, 0
	local panelSize = uiPanel:getContentSize()
	if net.InstPlayerFormation then
		_curPositionList = {}
		for key, obj in pairs(net.InstPlayerFormation) do
            if obj.int["4"] == 1 or obj.int["4"] == 2 then
			    local instCardId = obj.int["3"] --卡牌实例ID
			    local type = obj.int["4"] --1:主力,2:替补
			    local position = obj.int["5"] --站位
                local isAwake = net.InstPlayerCard[tostring(instCardId)].int["18"] --是否已觉醒 0-未觉醒 1-觉醒
			    local dictCardId = net.InstPlayerCard[tostring(instCardId)].int["3"] --卡牌字典ID
			    local instCardData = net.InstPlayerCard[tostring(instCardId)] --卡牌实例数据
			    local dictCardData = DictCard[tostring(dictCardId)] --卡牌字典数据
			    local cardItem = uiCardItem:clone()
			    local cardName = ccui.Helper:seekNodeByName(cardItem, "text_name")
			    local cardFrame = cardItem:getChildByName("image_frame_card")
			    local cardIcon = cardFrame:getChildByName("image_card")
			    cardFrame:setTag(instCardId)
			    cardName:setString((isAwake == 1 and Lang.ui_lineup_embattle5 or "") .. dictCardData.name)
			    cardFrame:loadTexture(utils.getQualityImage(dp.Quality.card, instCardData.int["4"], dp.QualityImageType.middle))
			    cardIcon:loadTexture("image/" .. DictUI[tostring(isAwake == 1 and dictCardData.awakeBigUiId or dictCardData.bigUiId)].fileName)
			    local _cruPosition = instCardId .. "_" .. type .. "_" .. position.."_0"
			    if type == FLAG_BENCH then
				    position = position + 6
				    _benchCount = _benchCount + 1
			    else
				    _teamCount = _teamCount + 1
			    end
			    cardItem:setPosition(cc.p(POINTS[position].x + panelSize.width / 2, POINTS[position].y + panelSize.height / 2))
			    uiPanel:addChild(cardItem, 0, position)
			    _curPositionList[position] = _cruPosition

                _teamPreId[ #_teamPreId + 1 ] = instCardId
                _teamCurId[ #_teamCurId + 1 ] = instCardId
            end
		end
		ui_mainFlag:setString(string.format(Lang.ui_lineup_embattle6, _teamCount))
		ui_benchFlag:setString(string.format(Lang.ui_lineup_embattle7, _benchCount))
	end
    _InstPlayerPartner = {}
    _curFriendPositionList = {}
    _isOpenFriend = {}
	if net.InstPlayerFormation then
		for key, obj in pairs(net.InstPlayerFormation) do
            if obj.int["4"] == 3 and obj.int["10"] > 0 then
                _InstPlayerPartner[obj.int["5"]] = { int = {} }
			    _InstPlayerPartner[obj.int["5"]].int["3"] = obj.int["3"]
                _InstPlayerPartner[obj.int["5"]].int["6"] = obj.int["6"]
                _InstPlayerPartner[obj.int["5"]].int["10"] = obj.int["10"]
                
                _curFriendPositionList[obj.int["5"]] = obj.int["3"].."_"..3 .."_"..obj.int["5"] .. "_" .. obj.int[ "10" ]

                _friendPreId[ #_friendPreId + 1 ] = obj.int[ "3" ]
                _friendCurId[ #_friendCurId + 1 ] = obj.int[ "3" ]
            end
		end
	end
    local _DictPartnerLuck = {}
    for key, obj in pairs(DictPartnerLuckPos) do
        _DictPartnerLuck[#_DictPartnerLuck + 1] = obj
    end
    utils.quickSort(_DictPartnerLuck, function(obj1, obj2) if obj1.id > obj2.id then return true end return false end)
    local playerLevel = net.InstPlayer.int["4"] --玩家等级
    local practiceValue = UIAllianceSkill.getPracticeValue() --联盟修炼值

    aaa = {}
    for key , value in pairs( _InstPlayerPartner ) do
        table.insert( aaa , key )
    end

    ui_friendPanel:removeAllChildren()
    utils.updateHorzontalScrollView( UILineupEmbattle , ui_friendPanel , _item , aaa , function ( item , data )
        i = #ui_friends + 1
        ui_friends[i] = item
        ui_friends[i]:loadTexture("ui/card_small_white.png")

        local ui_cardIcon = item:getChildByName("image_friend")
		local ui_openLevel = item:getChildByName("image_level")
        local ui_cardName = ccui.Helper:seekNodeByName(ui_cardIcon, "text_friend_name")
        local ui_openDesc = item:getChildByName("text_hint")
        --default
        ui_cardIcon:setVisible(false)
        item:loadTexture("ui/card_small_purple.png")
        ui_cardName:setString("")
        ui_openLevel:setVisible(false)
        ui_openDesc:setVisible(false)
        item:setTouchEnabled(false)

        i = tonumber( data )

        local _dictPartnerLuckData = _DictPartnerLuck[i]
        if _dictPartnerLuckData then
            local _isOpen = false
            if _dictPartnerLuckData.isAuto == 0 then --非自动
                if net.InstPlayerPartnerLuckPos then
                    for _k, _o in pairs(net.InstPlayerPartnerLuckPos) do
                        if _dictPartnerLuckData.id == _o.int["3"] then
                            _isOpen = true
                            break
                        end
                    end
                end
            else
                if _dictPartnerLuckData.type == 1 then
                    if playerLevel >= _dictPartnerLuckData.value then
                        _isOpen = true
                    end
                elseif _dictPartnerLuckData.type == 2 then
                    if practiceValue >= _dictPartnerLuckData.value then
                        _isOpen = true
                    end
                end
            end
            if _isOpen then
                if _InstPlayerPartner[i] then
                    local instCardId = _InstPlayerPartner[i].int["3"] --卡牌实例ID
				    local dictCardId = _InstPlayerPartner[i].int["6"] --卡牌字典ID
				    local instCardData = net.InstPlayerCard[tostring(instCardId)] --卡牌实例数据
				    local dictCardData = DictCard[tostring(dictCardId)] --卡牌字典数据
                    local isAwake = instCardData.int["18"]
                  --  print( " friend2 : " , dictCardData.name , "  " , DictUI[tostring(dictCardData.smallUiId)].fileName , "  ", i )
				    item:loadTexture(utils.getQualityImage(dp.Quality.card, instCardData.int["4"], dp.QualityImageType.small))
				    ui_cardIcon:loadTexture("image/" .. DictUI[tostring(isAwake == 1 and dictCardData.awakeSmallUiId or dictCardData.smallUiId)].fileName)
				    ui_cardName:setString((isAwake == 1 and Lang.ui_lineup_embattle8 or "") .. dictCardData.name)
				    ui_cardIcon:setVisible(true)
                else
                    ui_cardIcon:loadTexture("ui/frame_tianjia.png")
                    ui_cardIcon:setVisible(false)
                end
            else
                if _dictPartnerLuckData.type == 1 then
                    ui_openLevel:getChildByName("label_level"):setString(tostring(_dictPartnerLuckData.value))
                    ui_openLevel:setVisible(true)
                elseif _dictPartnerLuckData.type == 2 then
                    ui_openDesc:setString(string.format(Lang.ui_lineup_embattle9, _dictPartnerLuckData.value))
                    ui_openDesc:setVisible(true)
                    _isOpenFriend[ i ] = 1
                elseif _dictPartnerLuckData.type == 3 then
                    local _thingName = DictThing[tostring(StaticThing.luckLock)].name
                    local _thingCount = utils.getThingCount(StaticThing.luckLock)
                    ui_openDesc:setString(string.format(Lang.ui_lineup_embattle10, _dictPartnerLuckData.value, _thingName))
                    ui_openDesc:setVisible(true)
                    _isOpenFriend[ i ] = 1
                end
            end
        else
            
        end
    end )   
end

function UILineupEmbattle.free()
	_isRuning = false
	if uiCardItem and uiCardItem:getReferenceCount() >= 1 then
		uiCardItem:release()
		uiCardItem = nil
	end
	uiPanel:removeAllChildren()
    _InstPlayerPartner = nil
    _curFriendPositionList = nil
    _isOpenFriend = nil
    _friendPosX = nil
    _friendPosY = nil
end

function UILineupEmbattle.setUIParam(param)
	_isRefreshLineup = param
end
