-- FileName: RivalFriendLayer.lua 
-- Author: zhz
-- Date: 14-5-14
-- Purpose: 查看对手阵容的小伙伴信息


require "script/model/user/UserModel"
require "script/model/hero/HeroModel"
require "script/ui/formation/LittleFriendData"
require "script/ui/formation/LittleFriendService"
require "script/ui/formation/FormationUtil"
require "script/model/utils/HeroUtil"
require "script/ui/active/RivalInfoData"
require "db/DB_Heroes"

module ("RivalFriendLayer", package.seeall)


local _bgLayer 							= nil     -- 主layer
local _layerSize 						= nil	  -- 主layer宽高
local _bgLayerData 						= nil	  -- 主界面信息数据
local _mainBg 							= nil	  -- 主界面背景 黑背景
local _positionBgArr 					= {}	  -- 位置背景图片
local _itemIconArr						= {}	  -- 位置上按钮图标
local _positionMenu 					= nil	  -- 位置按钮
local _flagSprite 						= nil	  -- 旗子
local cellHight 						= 0       -- cell高度
local _limitSize

-- 顺序 
--[[
	1   2
	3   4
	5   6
	7   8
--]]
local btnXPositions = {-0.03, 1.03, -0.03, 1.03, -0.03, 1.03, -0.03, 1.03}
local btnYPositions = {0.85, 0.85, 0.62, 0.62, 0.39, 0.39, 0.16, 0.16}

local _touchBeganPoint 					= nil	  -- 触摸过程的 第一个触摸点 


--posTable
local _posTable = { {1,3,5,7,9} , {2,4,6,8,10} }
local tagUp = 998
local tagDown = 999
local _scrollOffset = nil
-- 初始化数据
function init( ... )
	_bgLayer 							= nil     -- 主layer
	_layerSize 							= nil	  -- 主layer宽高
	_bgLayerData 						= nil	  -- 主界面信息数据
	_mainBg 							= nil	  -- 主界面背景 黑背景
	_touchBeganPoint 					= nil	  -- 触摸过程的 第一个触摸点 
	_positionBgArr 						= {}	  -- 位置背景图片
	_itemIconArr						= {}	  -- 位置上按钮图标
	_positionMenu 						= nil	  -- 位置按钮
	_flagSprite 						= nil	  -- 旗子
	cellHight 							= 0 	  -- cell高度
	_limitSize							= 60
end




local function createContainerLayer( ... )
	
	-- 	-- 得到阵上武将数据
	local heroInfo = RivalInfoData.getFormationHeroInfo()
	local heroCount = table.count(heroInfo)

	local containerLayer = CCLayer:create()
	containerLayer:setContentSize(CCSizeMake(359,0))
	-- 	-- 创建列表
	local cellHeight = 10
	local nodeHeight = 0
	for i=heroCount,1,-1  do
		-- 该武将名字
		local curHeroData = DB_Heroes.getDataById(tonumber(heroInfo[i].htid) )
		-- 名字
		local hero_name = nil
		if( HeroModel.isNecessaryHero(tonumber(heroInfo[i].htid ) ) )then
			hero_name = RivalInfoLayer.getTname() --UserModel.getUserName()
		else
			hero_name = curHeroData.name
		end
		--print("武将名字",hero_name)
		-- 羁绊
		local link_group = curHeroData.link_group1
		-- 得到羁绊信息
		local link_group_Data = RivalInfoData.parseHeroUnionProfit( heroInfo[i].htid , link_group ,i)
		-- print("武将link_group")
		-- print_t(link_group)
  --       print("武将link_group_Data")
  --       print_t(link_group_Data)
		if( table.count(link_group_Data) == 0)then
			-- 羁绊数据为空
			local link_des = CCLabelTTF:create(GetLocalizeStringBy("key_1341"),g_sFontName,23)
			link_des:setColor(ccc3(0x2f,0x2f,0x2f))
			link_des:setAnchorPoint(ccp(0.5,0))
			link_des:setPosition(ccp(containerLayer:getContentSize().width*0.5,cellHeight))
			containerLayer:addChild(link_des)
			-- 累积高度
			cellHeight = cellHeight+link_des:getContentSize().height+15
		else
			-- 遍历所有的羁绊数据
			local link_num = table.count(link_group_Data)
			for k = link_num,1,-1 do
				local name_color = nil
				local des_color = nil
				if( link_group_Data[k].isActive )then
					name_color = ccc3(0x00,0x6d,0x2f)
					des_color = ccc3(0x78,0x25,0x00)
				else
					name_color = ccc3(0x2f,0x2f,0x2f)
					des_color = ccc3(0x2f,0x2f,0x2f)
				end
				-- 羁绊名字
				local name_font = link_group_Data[k].dbInfo.union_arribute_name or " "
				local link_name = CCLabelTTF:create(name_font .. ":",g_sFontName,23)
				-- 羁绊描述
				local des_font = link_group_Data[k].dbInfo.union_arribute_desc or " "
				local link_des = CCLabelTTF:create(des_font,g_sFontName,23,CCSizeMake(210,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)

				link_des:setColor(des_color)
				link_des:setAnchorPoint(ccp(0,0))
				link_des:setPosition(ccp(123,cellHeight))
				containerLayer:addChild(link_des)
				cellHeight = cellHeight+link_des:getContentSize().height+15

				link_name:setColor(name_color)
				link_name:setAnchorPoint(ccp(1,1))
				link_name:setPosition(ccp(120,link_des:getPositionY() + link_des:getContentSize().height))
				containerLayer:addChild(link_name)
			end
		end

		-- 创建武将名字
		local name_bg = CCSprite:create("images/formation/littlef_line.png")
		name_bg:setAnchorPoint(ccp(0.5,0))
		name_bg:setPosition(containerLayer:getContentSize().width*0.5,cellHeight)
		containerLayer:addChild(name_bg,1,i)
		
		local name_font = CCRenderLabel:create( hero_name, g_sFontPangWa, 28, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
		name_font:setColor(ccc3(0xff, 0xf6, 0x00))
		name_font:setAnchorPoint(ccp(0.5,0.5))
		name_font:setPosition(ccp(name_bg:getContentSize().width*0.5,name_bg:getContentSize().height*0.5))
		name_bg:addChild(name_font)
		-- 累积高度
		cellHeight = cellHeight+name_font:getContentSize().height+5
	end
	-- 设置containerLayer的size
	containerLayer:setContentSize(CCSizeMake(359,cellHeight))

	
	return containerLayer

end




--[[
	@des 	:得到位置上的icon
	@param 	:position:位置
	@retrun :
--]]
function getPositionIcon( position )
	local itemIcon = nil
	-- 开启得到该位置上的hid
	local heroInfo = RivalInfoData.getHeroInfoFromPosition(position)
	print("getPositionIcon")
	print_t(heroInfo)
	if(tonumber(heroInfo.hid) > 0)then
		-- 在阵上的英雄
		-- local heroRemoteInfo = nil
		-- local allHeros = HeroModel.getAllHeroes()
		-- for t_hid, t_hero in pairs(allHeros) do
		-- 	if( tonumber(t_hid) ==  hid) then
		-- 		heroRemoteInfo = t_hero
		-- 		break
		-- 	end
		-- end
		require "script/ui/hero/HeroPublicCC"
		require "db/DB_Heroes"
		-- itemIcon = HeroPublicCC.getCMISHeadIconByHtid(heroInfo.htid)
		-- 新增幻化id, add by lgx 20160928
		local icon1 = HeroUtil.getHeroIconByHTID( heroInfo.htid, nil , nil,nil, heroInfo.turned_id)
		local icon2 = HeroUtil.getHeroIconByHTID( heroInfo.htid, nil , nil,nil, heroInfo.turned_id)
		itemIcon = CCMenuItemSprite:create(icon1, icon2)
		local name_t = heroInfo.localInfo.name

		local nameColor = HeroPublicLua.getCCColorByStarLevel(heroInfo.potential)
		heroNameLabel = CCRenderLabel:create(name_t, g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		heroNameLabel:setColor(nameColor)
		heroNameLabel:setAnchorPoint(ccp(0.5, 1))
		heroNameLabel:setPosition(ccp(itemIcon:getContentSize().width*0.5,-itemIcon:getContentSize().height*0.04))
		itemIcon:addChild(heroNameLabel)
		-- -- 进阶次数
		-- local evolveLevelLabel = CCRenderLabel:create("+" .. curHeroData.evolve_level, g_sFontPangWa, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		-- evolveLevelLabel:setColor(ccc3(0x00, 0xff, 0x18))
		-- evolveLevelLabel:setAnchorPoint(ccp(0.5, 0))
		-- evolveLevelLabel:setPosition(ccp(itemIcon:getContentSize().width*0.5,itemIcon:getContentSize().height*0.0))
		-- itemIcon:addChild(evolveLevelLabel)
		-- 注册回调
		--itemIcon:registerScriptTapHandler(itemIconAction)
	else
		local isOpen = RivalInfoData.getIsOpenThisPosition(position)
		if(isOpen)then
			-- 阵上没有英雄
			-- local openLv = LittleFriendData.getOpenLv(position)
			local iconBg = CCSprite:create("images/common/border.png")
			-- local icon = CCSprite:create("images/formation/potential/add.png")
			-- icon:setAnchorPoint(ccp(0.5,0.5))
			-- icon:setPosition(ccp(iconBg:getContentSize().width*0.5,iconBg:getContentSize().height*0.5))
			-- iconBg:addChild(icon)
			require "script/ui/item/ItemSprite"
			-- local iconBg = ItemSprite.createAddSprite()
			itemIcon = CCMenuItemSprite:create(iconBg,iconBg)
			-- 注册回调
			--itemIcon:registerScriptTapHandler(itemIconAction)
		else
			-- 没开启 返回锁
			local openLv = RivalInfoData.getOpenLv(position)
			local iconBg = CCSprite:create("images/formation/potential/officer_11.png")
			local icon = CCSprite:create("images/formation/potential/newlock.png")
			icon:setAnchorPoint(ccp(0.5,0.5))
			icon:setPosition(ccp(iconBg:getContentSize().width*0.5,iconBg:getContentSize().height*0.5))
			iconBg:addChild(icon)
			itemIcon = CCMenuItemSprite:create(iconBg,iconBg)
			--当openLv＝-1时表示配置中未配置该位置信息,因此不添加开放等级提示
			if openLv ~= -1 then
				local tishi = CCRenderLabel:create( openLv , g_sFontPangWa, 28, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
				tishi:setColor(ccc3(0x45, 0xe7, 0xf1))
				tishi:setAnchorPoint(ccp(0.5,0.5))
				tishi:setPosition(ccp(itemIcon:getContentSize().width*0.5,itemIcon:getContentSize().height*0.5+5))
				local tishiSprite = CCSprite:create("images/formation/potential/jikaifang.png")
				tishiSprite:setAnchorPoint(ccp(0.5,0))
				tishiSprite:setPosition(ccp(itemIcon:getContentSize().width*0.5,6))
				itemIcon:addChild(tishiSprite,3)
				itemIcon:addChild(tishi,3)
			end
		end
	end
	return itemIcon
end


--[[
	@des 	:创建阵容羁绊列表
	@param 	:
	@retrun :
--]]
function createSkillScrollView( ... )
	-- 创建scrollView
	local listScrollView = CCScrollView:create()
	listScrollView:setTouchPriority(-1000)
	listScrollView:setViewSize(CCSizeMake(359,416))
    listScrollView:setBounceable(true)
    listScrollView:setDirection(kCCScrollViewDirectionVertical)
    listScrollView:setPosition(ccp(50,85))
	_flagSprite:addChild(listScrollView,3)

	local containerLayer = createContainerLayer()
	listScrollView:setContainer(containerLayer)
	listScrollView:setContentOffset(ccp(0,listScrollView:getViewSize().height-containerLayer:getContentSize().height))
end


-- 初始化小伙伴界面
function initLittleFriendLayer( ... )

	-- 大旗帜
	_flagSprite = CCSprite:create("images/formation/littlef_flag.png")
	_flagSprite:setAnchorPoint(ccp(0.5,0.5))
	_flagSprite:setPosition(ccp(_layerSize.width*0.5,_layerSize.height*0.55))
	_bgLayer:addChild(_flagSprite)

	-- 标题描述
	local titleSprite = CCSprite:create("images/formation/littlef_font.png")
	titleSprite:setAnchorPoint(ccp(0.5,1))
	titleSprite:setPosition(ccp(_flagSprite:getContentSize().width*0.5,14))
	_flagSprite:addChild(titleSprite)

	-- -- 创建8个位置
	-- for i=1,8 do
	-- 	local sprite = CCSprite:create("images/formation/littlef_head_bg.png")
	-- 	sprite:setAnchorPoint(ccp(0.5, 0.5))
	-- 	sprite:setPosition(ccp(_flagSprite:getContentSize().width*btnXPositions[i],_flagSprite:getContentSize().height*btnYPositions[i]))
	-- 	_flagSprite:addChild(sprite,2,1000+i)
	-- 	_positionBgArr[i] = sprite
	-- end

	-- 创建按钮
	-- _positionMenu = CCMenu:create()
	-- _positionMenu:setTouchPriority(-130)
	-- _positionMenu:setPosition(ccp(0,0))
	-- _flagSprite:addChild(_positionMenu,3)
	-- 六个itemIcon
	-- for i=1,8 do
	-- 	local item = getPositionIcon(i)
	-- 	item:setAnchorPoint(ccp(0.5,0.5))
	-- 	item:setPosition(ccp(_flagSprite:getContentSize().width*btnXPositions[i],_flagSprite:getContentSize().height*btnYPositions[i]))
	-- 	_positionMenu:addChild(item,1,i)
	-- end
    
    -- -- 创建6个位置
	-- for i=1,8 do
	-- 	local sprite = CCSprite:create("images/formation/littlef_head_bg.png")
	-- 	sprite:setAnchorPoint(ccp(0.5, 0.5))
	-- 	sprite:setPosition(ccp(_flagSprite:getContentSize().width*btnXPositions[i],_flagSprite:getContentSize().height*btnYPositions[i]))
	-- 	_flagSprite:addChild(sprite,2,1000+i)
	-- end

	--创建两个tableView
	local viewPosX = {-0.08,1.08}
	for i = 1,2 do
		local tableBgSprite = CCScale9Sprite:create(CCRectMake(8,37,12,12),"images/develop/scroll_bg.png")
		tableBgSprite:setContentSize(CCSizeMake(110,580))
		tableBgSprite:setAnchorPoint(ccp(0.5,0.5))
		tableBgSprite:setPosition(ccp(_flagSprite:getContentSize().width*viewPosX[i],_flagSprite:getContentSize().height*0.5))
		_flagSprite:addChild(tableBgSprite,1,i)

		local innerView = createInnerView(i)
		innerView:setPosition(ccp(0,40))
		innerView:setBounceable(true)
		innerView:setTouchPriority(-1001)
		tableBgSprite:addChild(innerView,1,1)

		createShiningArrow(i,tagUp)
		createShiningArrow(i,tagDown)

		arrowVisible(i,tagUp,false)
	end

	schedule(_flagSprite,updateArrow,1)
	
	-- 创建旗子上的标题
	local str = GetLocalizeStringBy("key_3019") --"阵上武将羁绊效果"
	local title_font = CCRenderLabel:create( str, g_sFontPangWa, 30, 1, ccc3(0xff, 0xff, 0xff), type_stroke)
	title_font:setAnchorPoint(ccp(0.5,1))
	title_font:setColor(ccc3(0x78, 0x25, 0x00))
	title_font:setPosition(ccp(_flagSprite:getContentSize().width*0.5,_flagSprite:getContentSize().height-48))
	_flagSprite:addChild(title_font)

	-- 创建羁绊显示列表ScrollView
	createSkillScrollView()
end



--[[
	@des 	:创建小伙伴界面
	@param 	:width:layer宽, height:layer高
	@retrun :
--]]
function createLittleFriendLayer( width, height)
	-- 初始化数据
	init()
	_bgLayer = CCLayer:create()

	if( width == nil) then
		width = 640
		height = 588
	end

	_bgLayer:setContentSize(CCSizeMake(width,height))
	_layerSize = _bgLayer:getContentSize()

	-- 主界面信息
	_bgLayerData = LittleFriendData.getLittleFriendeData()
	-- if( _bgLayerData ~= nil )then
	-- 	-- 初始化小伙伴界面
	initLittleFriendLayer()

	_bgLayer:registerScriptHandler(onNodeEvent)
	return _bgLayer
end



-- 判断是如何滑动
local function scrollFormationAndFriendLayer(xOffset)
	-- if(FormationLayer.isOnAnimatingFunc() == true)then
	-- 	return false
	-- end
	print("xOffset is :", xOffset , "  and >_bgLayer:getContentSize().width/8 is ", _bgLayer:getContentSize().width/8)
	if(xOffset>0) then
		if(xOffset> _limitSize )then
			RivalInfoLayer.moveFormationOrLittleFriendAnimated( false, true )
		else
			RivalInfoLayer.moveFormationOrLittleFriendAnimated( true, true )
		end
	elseif(xOffset<0 and RivalInfoData.hasPet() ) then
		if( math.abs(xOffset) >_limitSize) then
			RivalInfoLayer.moveFriendOrPetAnimated( true, true )
		else
			RivalInfoLayer.moveFriendOrPetAnimated( false, true )
		end
	end	
end 



-- touch事件处理
local function cardLayerTouch(eventType, x, y)
   
    if (eventType == "began") then
    	_touchBeganPoint = ccp(x, y)
    	-- if( FormationLayer.isInLittleFriendFunc() == true )then
			local tPosition = _bgLayer:convertToNodeSpace(_touchBeganPoint)
			if( _bgLayer:isVisible() == true and tPosition.x>0 and tPosition.y>0 and tPosition.x<_bgLayer:getContentSize().width and tPosition.y<_bgLayer:getContentSize().height)then
				return true
			else
				return false
			end
		-- else
		-- 	return false
		-- end
    elseif (eventType == "moved") then
    	print("cardLayerTouch moved moved ")
    	
		if(x-_touchBeganPoint.x>0)then
			-- 跟着手指滑动
			-- RivalInfoLayer.moveFormationOrLittleFriend( x-_touchBeganPoint.x - _bgLayer:getContentSize().width )
		else
				
		end
    else
    	print(" cardLayerTouch ended ")
    	print("x-_touchBeganPoint.x is", x-_touchBeganPoint.x)
    	-- 切换layer
    	if(math.abs(x-_touchBeganPoint.x) > _limitSize )then

    		local k = (y-_touchBeganPoint.y)/(x-_touchBeganPoint.x)
    		print(" ")
    		print("k is ", k)
    		-- 斜率
    		if(k<0.5 and k>-0.5)then
	    		scrollFormationAndFriendLayer( x-_touchBeganPoint.x)
	    	end
	    end
	end
end




--[[
 @desc	 回调onEnter和onExit时间
 @para 	 string event
 @return void
 --]]
function onNodeEvent( event )
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(cardLayerTouch, false, -999, true)
		_bgLayer:setTouchEnabled(false)

	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
	end
end
--新增的小伙伴tableview箭头监听函数
function updateArrow()
	for i = 1,2 do
		local nineSprite = tolua.cast(_flagSprite:getChildByTag(i),"CCScale9Sprite")
		local innerTableView = tolua.cast(nineSprite:getChildByTag(1),TOLUA_CAST_TABLEVIEW)

		if innerTableView ~= nil then
			local contentOffset = innerTableView:getContentOffset()
			if tonumber(innerTableView:getContentOffset().y) <= _scrollOffset[i] then
				arrowVisible(i,tagUp,false)
				arrowVisible(i,tagDown,true)
			elseif tonumber(innerTableView:getContentOffset().y) >= 0 then
				arrowVisible(i,tagDown,false)
				arrowVisible(i,tagUp,true)
			else
				arrowVisible(i,tagUp,true)
				arrowVisible(i,tagDown,true)
			end
		end
	end
end

--创建tableView
function createInnerView(p_index)
	local friendNum = table.count(_posTable[p_index])
	local cellHeightY = 140

	local h = LuaEventHandler:create(function(fn,table,a1,a2)
		local r
		if fn == "cellSize" then
			r = CCSizeMake(110,cellHeightY)
		elseif fn == "cellAtIndex" then
			a2 = createInnerCell(p_index,friendNum - a1)
			r = a2
		elseif fn == "numberOfCells" then
			r = friendNum
		else
			print("other function")
		end

		return r
	end)

	_scrollOffset = {500 - cellHeightY*friendNum,500 - cellHeightY*friendNum}

	return LuaTableView:createWithHandler(h, CCSizeMake(115,500))
end

function createInnerCell(p_index,p_pos)
	local innerCell = CCTableViewCell:create()

	local bgSprite = CCSprite:create("images/formation/littlef_head_bg.png")
	bgSprite:setAnchorPoint(ccp(0,0))
	bgSprite:setPosition(ccp(0,20))
	innerCell:addChild(bgSprite)

	local innerMenu = BTSensitiveMenu:create()
	if(innerMenu:retainCount()>1)then
		innerMenu:release()
		innerMenu:autorelease()
	end
	innerMenu:setPosition(ccp(0,0))
	innerMenu:setTouchPriority(-1000)
	bgSprite:addChild(innerMenu)

	local item = getPositionIcon(_posTable[p_index][p_pos])
	item:setAnchorPoint(ccp(0.5,0.5))
	item:setPosition(ccp(bgSprite:getContentSize().width/2,bgSprite:getContentSize().height/2))
	innerMenu:addChild(item,1,_posTable[p_index][p_pos])

	return innerCell
end

function createShiningArrow(p_index,p_direction)
	local nineSprite = tolua.cast(_flagSprite:getChildByTag(p_index),"CCScale9Sprite")

	local imagesPath
	local posY
	local gapLenth = -10
	if p_direction == tagUp then
		imagesPath = "images/common/arrow_up_h.png"
		posY = nineSprite:getContentSize().height - gapLenth
	else
		imagesPath = "images/common/arrow_down_h.png"
		posY = 50 + gapLenth
	end

	local arrowSp = CCSprite:create(imagesPath)
	arrowSp:setPosition(nineSprite:getContentSize().width/2,posY)
	arrowSp:setAnchorPoint(ccp(0.5,1))
	nineSprite:addChild(arrowSp,10,p_direction)

	--动画
	local arrActions = CCArray:create()
	arrActions:addObject(CCFadeOut:create(1))
	arrActions:addObject(CCFadeIn:create(1))
	local sequence = CCSequence:create(arrActions)
	local action = CCRepeatForever:create(sequence)
	arrowSp:runAction(action)
end

function arrowVisible(p_index,p_direction,p_visible)
	local nineSprite = tolua.cast(_flagSprite:getChildByTag(p_index),"CCScale9Sprite")
	tolua.cast(nineSprite:getChildByTag(p_direction),"CCSprite"):setVisible(p_visible)
end


