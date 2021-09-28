-- Filename：	ChangeFormationLayer.lua
-- Author：		bzx
-- Date：		2015-06-29
-- Purpose：		调整阵型

module ("ChangeFormationLayer", package.seeall)

local _layer = nil
local _backCallback = nil
local _heroCardsTable = {}
local ck_formationInfo = {}
local h_AnimatedDuration = 0.2

function create(p_backCallback, p_contentSize)
	_backCallback = p_backCallback
	handleFormation()

	_layer = CCLayer:create()
	if p_contentSize ~= nil then
		_layer:setContentSize(p_contentSize)
	end
	_layer:registerScriptHandler(onNodeEvent)
	local fullRect = CCRectMake(0,0,213,171)
	local insetRect = CCRectMake(50,50,113,71)
	changeFormationSprite = CCScale9Sprite:create("images/formation/changeformation/bg.png", fullRect, insetRect)
	changeFormationSprite:setPreferredSize(CCSizeMake(620, 510))
	changeFormationSprite:setAnchorPoint(ccp(0.5, 0.5))
	changeFormationSprite:setPosition(ccp(_layer:getContentSize().width*0.5, _layer:getContentSize().height*0.55))
	_layer:addChild(changeFormationSprite)	
	changeFormationSprite:setScale(MainScene.elementScale)

	local CFSSize = changeFormationSprite:getContentSize()
	-- 标题
	local titleSp = CCSprite:create("images/formation/changeformation/titlebg.png")
	titleSp:setAnchorPoint(ccp(0.5,0.5))
	titleSp:setPosition(ccp(changeFormationSprite:getContentSize().width/2, changeFormationSprite:getContentSize().height*0.986))
	changeFormationSprite:addChild(titleSp)
	local titleLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2896") , g_sFontName, 35, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    -- titleLabel:setSourceAndTargetColor(ccc3( 0xff, 0xf0, 0x49), ccc3( 0xff, 0xa2, 0x00));
    titleLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    titleLabel:setPosition(ccp( (titleSp:getContentSize().width-titleLabel:getContentSize().width)/2, titleSp:getContentSize().height*0.85))
    titleSp:addChild(titleLabel, 10000, 10000)

	-- 返回阵容Bar
	backToFormationBar = CCMenu:create()
	backToFormationBar:setPosition(ccp(0, 0))
	_layer:addChild(backToFormationBar)
	-- 返回阵容Button
	local backToFormationBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_2661"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	backToFormationBtn:setAnchorPoint(ccp(0.5, 0.5))
	backToFormationBtn:setPosition(_layer:getContentSize().width*0.5, _layer:getContentSize().height*0.1)
	backToFormationBtn:registerScriptTapHandler(backCallback)
	backToFormationBar:addChild(backToFormationBtn)
	backToFormationBtn:setScale(MainScene.elementScale)


-- 6 个位置UI
	heroXScale = { 0.2, 0.5, 0.8, 0.2, 0.5, 0.8 }
	heroYScale = { 0.7, 0.7, 0.7, 0.28, 0.28, 0.28 }
	local underZorder = 10
	local upZorder = 20
	_heroCardsTable = {}
	for k, xScale in pairs(heroXScale) do
		local hid = ck_formationInfo[(k-1)]
		local heroSp = HeroSprite.createHeroSprite(hid, (k-1))
		heroSp:setAnchorPoint(ccp(0.5, 0.5))
		heroSp:setPosition(ccp(CFSSize.width*xScale,CFSSize.height*heroYScale[k]))
		if tonumber(k) >= 4 then
			changeFormationSprite:addChild(heroSp, underZorder, k)
		else
			changeFormationSprite:addChild(heroSp, upZorder, k)
		end
		if(hid>=0)then
			_heroCardsTable[k] = heroSp
		end

		local heroBg = CCSprite:create("images/formation/changeformation/herobg.png")
		heroBg:setAnchorPoint(ccp(0.5,0.5))
		heroBg:setPosition(ccp(CFSSize.width*xScale,CFSSize.height*heroYScale[k]))
		changeFormationSprite:addChild(heroBg)
	end
	return _layer
end

function backCallback( ... )
	_layer:removeFromParentAndCleanup(true)
	if _backCallback ~= nil then
		_backCallback()
	end
end

-- 处理成需要的阵型信息
function handleFormation()
	local real_formation = DataCache.getFormationInfo()
	ck_formationInfo = {}
	for k,h_id in pairs(real_formation) do
		if(h_id>0)then
			ck_formationInfo[tonumber(k)] = h_id
		elseif(FormationUtil.isOpenedByPosition(k))then
			ck_formationInfo[tonumber(k)] = 0
		else
			ck_formationInfo[tonumber(k)] = -1
		end
	end
end

-- 修改阵容 回调
function changeFormationCallback( cbFlag, dictData, bRet )
	
	local tempFormationInfo = {}
	local real_formation = DataCache.getFormationInfo()
	for f_pos, f_hid in pairs(real_formation) do
		if (tonumber(f_pos) ==  began_pos-1) then
			tempFormationInfo[f_pos] = real_formation[tostring(end_pos-1)]

		elseif (tonumber(f_pos) == end_pos-1) then
			tempFormationInfo[f_pos] = real_formation[tostring(began_pos-1)]
		else
			tempFormationInfo[f_pos] = f_hid
		end
	end

	-- 更新缓存数据
	DataCache.setFormationInfo(tempFormationInfo)
	-- formationInfo = tempFormationInfo

	local t_heroIcon = _heroCardsTable[end_pos]
	local t_x, t_y = t_heroIcon:getPosition()
	t_position = ccp(t_x, t_y)
	-- 开始动画
	began_heroSprite:runAction(CCMoveTo:create(h_AnimatedDuration, t_position))
	t_heroIcon:runAction(CCMoveTo:create(h_AnimatedDuration, began_hero_position))

	-- 交换 英雄 卡牌
	local tempHeroCards = {}
	for n_pos, n_herpCard in pairs(_heroCardsTable) do
		if (n_pos ==  began_pos) then
			tempHeroCards[n_pos] = _heroCardsTable[end_pos]

		elseif (n_pos == end_pos) then
			tempHeroCards[n_pos] = _heroCardsTable[began_pos]
		else
			tempHeroCards[n_pos] = _heroCardsTable[n_pos]
		end
	end
	_heroCardsTable = tempHeroCards


	handleFormation()

	if(_isInSecondFriend == false)then 
		-- 换阵容 刷新小伙伴界面
		LittleFriendLayer.refreshLittleFriendUI()
	end
end

--[[
 @desc	 处理和发送修改阵容的请求
 @para 	 s_pos/e_pos 需要交换的两个hero的位置 从 1 开始
 @return void
--]]
function changeFormationAction( s_pos, e_pos )
	began_pos = s_pos
	end_pos = e_pos
	local tempFormationInfo = {}
	local real_formation = DataCache.getFormationInfo()
	for f_pos, f_hid in pairs(real_formation) do
		if (tonumber(f_pos) ==  began_pos-1) then
			tempFormationInfo[f_pos] = real_formation[tostring(end_pos-1)]

		elseif (tonumber(f_pos) == end_pos-1) then
			tempFormationInfo[f_pos] = real_formation[tostring(began_pos-1)]
		else
			tempFormationInfo[f_pos] = f_hid
		end
	end
	
	local ff = CCDictionary:create()
	for i=0, 5 do
		if (tempFormationInfo[tostring(i)] > 0) then
			ff:setObject(CCInteger:create(tempFormationInfo[tostring(i)]), tostring(i))
		end
	end
	local args = CCArray:create()
	args:addObject(ff)
	RequestCenter.setFormationInfo(changeFormationCallback, args)
end

function onNodeEvent( event )
	if (event == "enter") then
		_layer:registerScriptTouchHandler(onTouchesHandler, false, -127, true)
		_layer:setTouchEnabled(true)
	elseif (event == "exit") then
		_layer:unregisterScriptTouchHandler()
	end
end

function onTouchesHandler( eventType, x, y )
	
	if (eventType == "began") then

		if(_isOnAnimating == true)then
			return false
		end
		print("began")
		began_pos = nil
		began_heroSprite = nil
		began_hero_position = nil
		began_hero_ZOrder = nil
		original_pos = nil

        touchBeganPoint = ccp(x, y)
        local isTouch = false
	    	for pos, heroCard in pairs(_heroCardsTable) do
	    		local bPosition = heroCard:convertToNodeSpace(touchBeganPoint)
	    		if ( bPosition.x >0 and bPosition.x <  heroCard:getContentSize().width and bPosition.y > 0 and bPosition.y < heroCard:getContentSize().height ) then
		        	
		        	if (ck_formationInfo[pos-1]>0) then
		        		local tempX, tempY  = heroCard:getPosition()
		        		--if (tempX == 620*heroXScale[pos]) and (tempY == 490*heroYScale[pos]) then
		        		isTouch = true
			        	began_pos = pos
			        	began_heroSprite = heroCard
			        	
			        	began_hero_position = ccp(tempX, tempY)
			        	original_pos = ccp(620*heroXScale[pos],510*heroYScale[pos])
			        	-- 修改 Z轴
			        	began_hero_ZOrder = heroCard:getZOrder()
			        	local parent_node = began_heroSprite:getParent() 
			        	parent_node:reorderChild(began_heroSprite, 9999)
				        --end
			        else
			        	isTouch = false
			        end
		        	break
		        else
		        	isTouch = false
		        end
	    	end
	    return isTouch
    elseif (eventType == "moved") then
    	print("moved")
    	if (BTUtil:getGuideState() == true) then
        	return
    	end
	    began_heroSprite:setPosition(ccp( (x - touchBeganPoint.x)/MainScene.elementScale + began_hero_position.x , (y - touchBeganPoint.y)/MainScene.elementScale + began_hero_position.y))
    else
        local xOffset = x - touchBeganPoint.x
        if (BTUtil:getGuideState() == true) then
        	xOffset = 0
    	end
    	-- 移动修改阵容界面的 hero
    	local isChanged = false
    	local changedHero = nil

    	local temp = ccp(began_heroSprite:getContentSize().width/2,began_heroSprite:getContentSize().height/2 )
		local e_position = began_heroSprite:convertToWorldSpace(ccp(temp.x,temp.y))
    	for pos, card_hero in pairs(_heroCardsTable) do
    		if(pos ~= began_pos) then
    			local bPosition = card_hero:convertToNodeSpace(e_position)
    			if ( bPosition.x >0 and bPosition.x <  card_hero:getContentSize().width and bPosition.y > 0 and bPosition.y < card_hero:getContentSize().height ) then
    				isChanged = true
    				changedHero = card_hero
    				end_pos =  pos
    				break
    			end
    		end
    	end
    	if (isChanged == false) then
	    	began_heroSprite:runAction(CCMoveTo:create(h_AnimatedDuration, original_pos))
	    	-- 修改 Z轴
	    	local parent_node = began_heroSprite:getParent() 
	    	if tonumber(began_pos) >= 4 then
		    	parent_node:reorderChild(began_heroSprite, 10)
		    else
		    	parent_node:reorderChild(began_heroSprite, 20)
		    end
		else
			changeFormationAction(began_pos, end_pos)
			local parent_node = began_heroSprite:getParent() 
			if tonumber(end_pos) >= 4 then
				if tonumber(began_pos) < 4 then
					parent_node:reorderChild(changedHero,20)
				else
					parent_node:reorderChild(changedHero,10)
				end
		    	parent_node:reorderChild(began_heroSprite, 10)
		    else
		    	if tonumber(began_pos) < 4 then
		    		parent_node:reorderChild(changedHero,20)
		    	else
		    		parent_node:reorderChild(changedHero,10)
		    	end
		    	parent_node:reorderChild(began_heroSprite, 20)
		    end
		end
        print("end")
	end
end

