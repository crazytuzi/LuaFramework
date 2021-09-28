-- Filename：	MakeUpFormationLayer.lua
-- Author：		zhang zihang
-- Date：		2014-5-9
-- Purpose：		布阵界面

module ("MakeUpFormationLayer", package.seeall)

require "script/ui/main/MainScene"
require "script/model/DataCache"

local _priority				--触摸优先级
local _zorder				--z轴
local _bgLayer				--主界面
local _inFormationInfo 		--上阵武将信息
							--一个数组，内容为0表示位置开启但无上阵将领 内容为-1表示位置未开启 其余为武将id
local _heroCardsTable		--存放卡牌图片
local _touchBeganPoint		--触摸位置
local _began_pos			--初始卡牌编号
local _began_heroSprite		--初始开牌
local _began_hero_position	--初始卡牌位置
local _began_hero_ZOrder	--初始卡牌z轴
local _end_pos				--卡牌结束位置
local _h_AnimatedDuration	--动画时长
local _max_zOrder			--最高z轴
local _block				--防穿透用
local heroXScale
local heroYScale
local original_pos
local _requestFunc 			= nil


local function init()
	_priority 				= nil
	_zorder 				= nil
	_bgLayer				= nil
	_touchBeganPoint		= nil
	_began_pos				= nil
	_began_heroSprite 		= nil
	_began_hero_position	= nil
	_began_hero_ZOrder		= nil
	_end_pos				= nil
	original_pos 			= nil
	_block					= false
	_inFormationInfo 		= {}
	_heroCardsTable			= {}
	heroXScale				= {}
	heroYScale				= {}
	_max_zOrder 			= 9999
	_h_AnimatedDuration		= 0.2
	_requestFunc 			= nil
end

-- 修改阵容 回调
function changeFormationCallback(cbFlag, dictData, bRet)

	local tempFormationInfo = {}
	local real_formation = DataCache.getFormationInfo()
	if (_requestFunc) then
		real_formation = GodWeaponCopyData.getFormationInfo()
	end
	for f_pos, f_hid in pairs(real_formation) do
		if (tonumber(f_pos) ==  _began_pos-1) then
			tempFormationInfo[f_pos] = real_formation["" .. _end_pos-1]

		elseif (tonumber(f_pos) == _end_pos-1) then
			tempFormationInfo[f_pos] = real_formation["" .. _began_pos-1]
		else
			tempFormationInfo[f_pos] = f_hid
		end
	end

	-- 更新缓存数据

	if (_requestFunc) then
		GodWeaponCopyData.setFormationInfo(tempFormationInfo)
	else
		DataCache.setFormationInfo(tempFormationInfo)
	end
	-- formationInfo = tempFormationInfo

	-- added by zhz
	if(_bgLayer== nil) then
		return
	end

	local t_heroIcon = _heroCardsTable[_end_pos]
	local t_x, t_y = t_heroIcon:getPosition()
	local t_position = ccp(t_x, t_y)
	-- 开始动画
	_began_heroSprite:runAction(CCMoveTo:create(_h_AnimatedDuration, t_position))
	t_heroIcon:runAction(CCMoveTo:create(_h_AnimatedDuration, _began_hero_position))

	-- 交换 英雄 卡牌
	local tempHeroCards = {}
	for n_pos, n_herpCard in pairs(_heroCardsTable) do
		if (n_pos ==  _began_pos) then
			tempHeroCards[n_pos] = _heroCardsTable[_end_pos]

		elseif (n_pos == _end_pos) then
			tempHeroCards[n_pos] = _heroCardsTable[_began_pos]
		else
			tempHeroCards[n_pos] = _heroCardsTable[n_pos]
		end
	end
	_heroCardsTable = tempHeroCards

	dealWithData()
end

local function changeFormationAction(s_pos, e_pos)
	_began_pos = s_pos
	_end_pos = e_pos
	local tempFormationInfo = {}

	local real_formation = DataCache.getFormationInfo()
	if(_requestFunc)then
		real_formation = GodWeaponCopyData.getFormationInfo()
	end

	for f_pos, f_hid in pairs(real_formation) do
		if (tonumber(f_pos) ==  _began_pos-1) then
			tempFormationInfo[f_pos] = real_formation["" .. _end_pos-1]

		elseif (tonumber(f_pos) == _end_pos-1) then
			tempFormationInfo[f_pos] = real_formation["" .. _began_pos-1]
		else
			tempFormationInfo[f_pos] = f_hid
		end
	end

	local ff = CCDictionary:create()
	for i=0, 5 do
		if (tempFormationInfo[ "" .. i] > 0) then
			ff:setObject(CCInteger:create(tempFormationInfo["" .. i]), "" .. i)
		end
	end

	require "script/network/RequestCenter"

	local args = CCArray:create()
	args:addObject(ff)
	if(_requestFunc)then
		_requestFunc(changeFormationCallback, args)
	else
		RequestCenter.setFormationInfo(changeFormationCallback, args)
	end
end

local function onTouchesHandler(eventType, x, y)
	if eventType == "began" then
		_touchBeganPoint = ccp(x, y)
		_began_pos = nil
		_began_heroSprite = nil
		_began_hero_position = nil
		_began_hero_ZOrder = nil
		_block = false
		original_pos = nil

        --local isTouch = false
		-- 更换阵型
    	for pos, heroCard in pairs(_heroCardsTable) do
    		local bPosition = heroCard:convertToNodeSpace(_touchBeganPoint)
    		if ( bPosition.x >0 and bPosition.x <  heroCard:getContentSize().width and bPosition.y > 0 and bPosition.y < heroCard:getContentSize().height ) then
	        	if (_inFormationInfo[pos-1]>0) then
	        		local tempX, tempY  = heroCard:getPosition()
	        		print("now",tempX,tempY)
	        		print("啦啦",620*heroXScale[pos],590*heroYScale[pos])
	        		--if (tempX == 620*heroXScale[pos]) and (tempY == 590*heroYScale[pos]) then
		        		--isTouch = true
	        		_block = true
		        	_began_pos = pos
		        	_began_heroSprite = heroCard

		        	print("点击位置,",tempX,tempY)
		        	_began_hero_position = ccp(tempX, tempY)
		        	original_pos = ccp(620*heroXScale[pos],590*heroYScale[pos])
		        	-- 修改 Z轴
		        	_began_hero_ZOrder = heroCard:getZOrder()
		        	local parent_node = _began_heroSprite:getParent()
		        	parent_node:reorderChild(_began_heroSprite, _max_zOrder)
			        --end
		        else
		        	--isTouch = false
		        	_block = false
		        end

	        	break

	        else
	        	--isTouch = false
	        	_block = false
	        end
    	end
    	return true
	elseif eventType == "moved" then
		if _block == true  and _bgLayer~= nil then
			_began_heroSprite:setPosition(ccp( (x - _touchBeganPoint.x)/MainScene.elementScale + _began_hero_position.x , (y - _touchBeganPoint.y)/MainScene.elementScale + _began_hero_position.y))
		end
	else
		if _block == true and _bgLayer~= nil  then
			local isChanged = false
	    	local changedHero = nil

	    	local temp = ccp(_began_heroSprite:getContentSize().width/2,_began_heroSprite:getContentSize().height/2 )
			local e_position = _began_heroSprite:convertToWorldSpace(ccp(temp.x,temp.y))
	    	for pos, card_hero in pairs(_heroCardsTable) do
	    		if(pos ~= _began_pos) then
	    			local bPosition = card_hero:convertToNodeSpace(e_position)
	    			if ( bPosition.x >0 and bPosition.x <  card_hero:getContentSize().width and bPosition.y > 0 and bPosition.y < card_hero:getContentSize().height ) then
	    				isChanged = true
	    				changedHero = card_hero
	    				_end_pos =  pos

	    				-- if tonumber(pos) >= 4 then
	    				-- 	card_hero:getParent():reorderChild(card_hero, 10)
	    				-- else
	    				-- 	card_hero:getParent():reorderChild(card_hero, 20)
	    				-- end
	    				break
	    			end
	    		end
	    	end
	    	if (isChanged == false and  _bgLayer~= nil) then
		    	_began_heroSprite:runAction(CCMoveTo:create(_h_AnimatedDuration, original_pos))
		    	-- 修改 Z轴
		    	local parent_node = _began_heroSprite:getParent()
		    	if tonumber(_began_pos) >= 4 then
			    	parent_node:reorderChild(_began_heroSprite, 10)
			    else
			    	parent_node:reorderChild(_began_heroSprite, 20)
			    end
			else
				changeFormationAction(_began_pos, _end_pos)
				local parent_node = _began_heroSprite:getParent()
				if tonumber(_end_pos) >= 4 then
					if tonumber(_began_pos) < 4 then
						parent_node:reorderChild(changedHero,20)
					else
						parent_node:reorderChild(changedHero,10)
					end
			    	parent_node:reorderChild(_began_heroSprite, 10)
			    else
			    	if tonumber(_began_pos) < 4 then
			    		parent_node:reorderChild(changedHero,20)
			    	else
			    		parent_node:reorderChild(changedHero,10)
			    	end
			    	parent_node:reorderChild(_began_heroSprite, 20)
			    end
			end
		end
	end
end

local function onNodeEvent(event)
	if event == "enter" then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, _priority, true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
		_bgLayer =nil
	end
end

function closeAction()
	if(_bgLayer~= nil) then
		AudioUtil.playEffect("audio/effect/guanbi.mp3")
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
end

function dealWithData()
	require "script/ui/formation/FormationUtil"
	local real_formation = DataCache.getFormationInfo()
	if(_requestFunc)then
		real_formation = GodWeaponCopyData.getFormationInfo()
	end

	_inFormationInfo = {}
	for k,h_id in pairs(real_formation) do
		if(h_id>0)then
			_inFormationInfo[tonumber(k)] = h_id
		elseif(FormationUtil.isOpenedByPosition(k))then
			_inFormationInfo[tonumber(k)] = 0
		else
			_inFormationInfo[tonumber(k)] = -1
		end
	end
end

local function createUI()
	local fullRect = CCRectMake(0,0,213,171)
	local insetRect = CCRectMake(50,50,113,71)
	local changeFormationSprite = CCScale9Sprite:create("images/formation/changeformation/bg.png", fullRect, insetRect)
	changeFormationSprite:setPreferredSize(CCSizeMake(620, 590))
	changeFormationSprite:setAnchorPoint(ccp(0.5, 0.5))
	changeFormationSprite:setPosition(ccp(_bgLayer:getContentSize().width/2, _bgLayer:getContentSize().height/2))
	changeFormationSprite:setScale(MainScene.elementScale)
	_bgLayer:addChild(changeFormationSprite)

	local titleSp = CCSprite:create("images/formation/changeformation/titlebg.png")
	titleSp:setAnchorPoint(ccp(0.5,0.5))
	titleSp:setPosition(ccp(changeFormationSprite:getContentSize().width/2, changeFormationSprite:getContentSize().height))
	changeFormationSprite:addChild(titleSp)
	local titleLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2896") , g_sFontName, 35, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
    titleLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    titleLabel:setPosition(ccp(titleSp:getContentSize().width/2, titleSp:getContentSize().height/2))
    titleSp:addChild(titleLabel)

    local backToFormationBar = CCMenu:create()
	backToFormationBar:setPosition(ccp(0, 0))
	backToFormationBar:setTouchPriority(_priority)
	changeFormationSprite:addChild(backToFormationBar)

	local backToFormationBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("key_2661"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	backToFormationBtn:setAnchorPoint(ccp(0.5, 0.5))
	backToFormationBtn:setPosition(ccp(changeFormationSprite:getContentSize().width/2,70))
	backToFormationBtn:registerScriptTapHandler(closeAction)
	backToFormationBar:addChild(backToFormationBtn)

	require "script/ui/formation/HeroSprite"
	heroXScale = { 0.2, 0.5, 0.8, 0.2, 0.5, 0.8 }
	heroYScale = { 0.75, 0.75, 0.75, 0.38, 0.38, 0.38 }

	local underZorder = 10
	local upZorder = 20

	_heroCardsTable = {}
	for k, xScale in pairs(heroXScale) do
		print("撒的积分大书法家")
		print(k)
		local hid = _inFormationInfo[(k-1)]
		local heroSp = HeroSprite.createHeroSprite(hid, (k-1))
		heroSp:setAnchorPoint(ccp(0.5, 0.5))
		heroSp:setPosition(ccp(changeFormationSprite:getContentSize().width*xScale,changeFormationSprite:getContentSize().height*heroYScale[k]))
		print("初始位置",changeFormationSprite:getContentSize().width*xScale,changeFormationSprite:getContentSize().height*heroYScale[k])
		if tonumber(k) >= 4 then
			changeFormationSprite:addChild(heroSp, underZorder, k)
		else
			changeFormationSprite:addChild(heroSp,upZorder,k)
		end
		if(hid>=0)then
			_heroCardsTable[k] = heroSp
		end

		local heroBg = CCSprite:create("images/formation/changeformation/herobg.png")
		heroBg:setAnchorPoint(ccp(0.5,0.5))
		heroBg:setPosition(ccp(changeFormationSprite:getContentSize().width*xScale,changeFormationSprite:getContentSize().height*heroYScale[k]))
		changeFormationSprite:addChild(heroBg)
	end
end

function showLayer(touch_priority,zorder, requestFunc)
	init()
	_requestFunc = requestFunc
	_priority = touch_priority or (-550)
	_zorder	= zorder or 999


	_bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bgLayer:registerScriptHandler(onNodeEvent)
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,_zorder)

    dealWithData()

    createUI()
end
