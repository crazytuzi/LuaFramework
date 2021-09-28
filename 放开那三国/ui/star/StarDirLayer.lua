-- Filename：	StarDirLayer.lua
-- Author：		Cheng Liang
-- Date：		2013-8-12
-- Purpose：		名将录入口

module ("StarDirLayer", package.seeall)

require "script/network/RequestCenter"
require "script/model/DataCache"
require "script/utils/LuaUtil"
require "script/ui/main/MainScene"

require "script/ui/star/StarUtil"
require "script/libs/LuaCCLabel"
require "script/libs/LuaCCMenuItem"

require "script/utils/LuaUtil"

require "script/ui/star/StarSprite"
require "script/model/utils/HeroUtil"
require "script/ui/hero/HeroPublicLua"
require "script/ui/item/ItemSprite"

local Img_Path = "images/star/intimate/"


local _bgLayer 			= nil
local _tableViewSprite 	= nil
local _starTableView 	= nil		-- 
local _curStarList 		= {}		-- 当前的名将列表
local _curTotalLevel 	= nil		-- 当前的总星数
local _newStarInfos		= nil		-- 新的star
local _curCountry 		= 1 		-- 当前国家

local _curCountyItem 	= nil		-- 当前国家按钮

-- 好感互换
kExchangeType 			= 10000 	-- 好感互换标签

local _isShowExchange 	= false 	-- 是否显示好感互换
local _curSrcStarData 	= nil   	-- 当前默认的名将数据
local _curDisStarId 	= nil 		-- 当前选择的名将id
local _curStarBtn 		= nil 		-- 当前选择的名将按钮
local _curHighLight 	= nil 		-- 当前选择高亮框
local _bottomNode 		= nil 		-- 好感互换底部ui Node

local bgSprite 			= nil
local topSprite 		= nil
local totalLevelTitle   = nil

-----------------------

local function init()
	_bgLayer 			= nil
	_tableViewSprite 	= nil
	_starTableView 		= nil
	_curStarList 		= {}
	_curCountyItem 		= nil
	_newStarInfos		= nil		-- 新的star
	_curCountry 		= 1 		-- 当前国家
	_curSrcStarData 	= nil
	_curDisStarId 		= nil 
	_isShowExchange 	= false 
	_curHighLight 		= nil
	_curStarBtn 		= nil
	_bottomNode 		= nil
	bgSprite 			= nil
	topSprite 			= nil
end

--[[
 @desc	 处理touches事件
 @para 	 string event
 @return 
--]]
local function onTouchesHandler( eventType, x, y )
	local rect = getSpriteScreenRect(_bottomNode)
	if(rect:containsPoint(ccp(x,y))) then
		return true
	else
		return false
	end
end

--[[
 @desc	 回调onEnter和onExit时间
 @para 	 string event
 @return void
 --]]
local function bottomNodeEvent( event )
	if (event == "enter") then
		print("enter")
		_bottomNode:registerScriptTouchHandler(onTouchesHandler, false, -300, true)
		_bottomNode:setTouchEnabled(true)
	elseif (event == "exit") then
		print("exit")
		_bottomNode:unregisterScriptTouchHandler()
		_bottomNode = nil
	end
end

-- 刷新好感互换ui
function refreshStarExchangeUI( ... )
	-- 刷新列表
	_curStarList = StarUtil.getExchangeListByCountry(_curCountry,_curSrcStarData)
	_starTableView:reloadData()

	-- 清空选择的信息
	_curStarBtn = nil
	_curDisStarId = nil
	if(_curHighLight)then
		_curHighLight:removeFromParentAndCleanup(true)
		_curHighLight = nil
	end

	-- 清空下部分选择的名将信息
	createStarExchangeNode()
end

-- 互换好感按钮回调
function exchangeMenuItemAction( tag, itemBtn )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- 判断 是否选择目标武将
	if(_curDisStarId == nil)then
		require "script/ui/tip/AnimationTip"
        AnimationTip.showTip(GetLocalizeStringBy("lic_1145"))
		return
	end
	require "script/ui/tip/AlertTip"
	local str = GetLocalizeStringBy("lic_1159")
	AlertTip.showAlert(str,yesForExchangeFun,true)
end

-- 确认互换好感度 发送请求
function yesForExchangeFun( isConfirm )
	if(isConfirm == false)then
		return 
	end
	local price = StarUtil.getCostForStarExchange(_curSrcStarData.star_id)
	if( UserModel.getGoldNumber() < price )then
        -- 金币不足提示
        require "script/ui/tip/LackGoldTip"
        LackGoldTip.showTip()
        return
    end
    local exchangeServiceCallFun = function ( cbFlag, dictData, bRet )
    	if( dictData.err == "ok") then
    		if(dictData.ret == "ok")then
    			-- 扣除金币
    			UserModel.addGoldNumber(tonumber(-price))
    			-- 修改缓存名将数据
    			local newSrcData = table.hcopy(StarUtil.getStarInfoBySid(_curDisStarId), {})
    			local newDisData = table.hcopy(_curSrcStarData, {})
    			-- print("newSrcData",_curSrcStarData.star_id)
    			-- print_t(newSrcData)
    			-- print("newDisData",_curDisStarId)
    			-- print_t(newDisData)
    			DataCache.changeStarData(_curSrcStarData.star_id, newSrcData)
    			DataCache.changeStarData(_curDisStarId, newDisData)
    			-- 弹出提示框
	    		require "script/ui/star/ShowStarExchangeTip"
				ShowStarExchangeTip.showTip(_curSrcStarData.star_id, _curDisStarId)
    			-- 刷新ui
    			refreshStarExchangeUI()

    			StarUtil.getStarAddNumBy( newSrcData.star_tid, true)
    			StarUtil.getStarAddNumBy( newDisData.star_tid, true)
    
			end
    	end
    end
    -- 好感互换请求
	local args = Network.argsHandler(tonumber(_curSrcStarData.star_id), tonumber(_curDisStarId))
	Network.rpc(exchangeServiceCallFun, "star.swap","star.swap", args, true)
end

--[[
	@desc:	  创建好感等级ui
	@para:   p_selfLv:自己的等级
	@para:   p_disLv:目标的等级
	@return: sprite
 --]]
function createStarLoveLevel( p_selfLv, p_disLv )
	-- 背景
	local fullRect = CCRectMake(0,0,209, 49)
	local insetRect = CCRectMake(86,14,45,20)
	local bgSp = CCScale9Sprite:create("images/star/lovelv_bg.png", fullRect, insetRect)

	-- 自己的等级
	local selfLevel = CCRenderLabel:create(p_selfLv, g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    selfLevel:setAnchorPoint(ccp(0,0.5))
    selfLevel:setColor(ccc3(0xff, 0xff, 0xff))
    bgSp:addChild(selfLevel)
    -- 心
    local selfHeartSp = CCSprite:create("images/star/intimate/heart_s.png")
    selfHeartSp:setAnchorPoint(ccp(0, 0.5))
    bgSp:addChild(selfHeartSp)

    if(p_disLv)then
    	-- 箭头
    	local jianSp = CCSprite:create("images/star/jian.png")
    	jianSp:setAnchorPoint(ccp(0,0.5))
    	bgSp:addChild(jianSp)

    	-- 目标等级
    	local fontColor = nil
    	if( p_selfLv < p_disLv )then
    		-- 绿色
			fontColor = ccc3(0x00, 0xff, 0x18)
    	else
    		-- 红色
    		fontColor = ccc3(0xff, 0x00, 0x00)
    	end
		local disLevel = CCRenderLabel:create(p_disLv, g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    disLevel:setAnchorPoint(ccp(0,0.5))
	    disLevel:setColor(fontColor)
	    bgSp:addChild(disLevel)
	    -- 心
	    local disHeartSp = CCSprite:create("images/star/intimate/heart_s.png")
	    disHeartSp:setAnchorPoint(ccp(0, 0.5))
	    bgSp:addChild(disHeartSp)

	    -- 坐标居中
	    local posX = (bgSp:getContentSize().width-selfLevel:getContentSize().width-selfHeartSp:getContentSize().width
	    			 	-jianSp:getContentSize().width-disLevel:getContentSize().width-disHeartSp:getContentSize().width-30)/2
	    selfLevel:setPosition(ccp(posX, bgSp:getContentSize().height*0.4))
	    selfHeartSp:setPosition(ccp(selfLevel:getPositionX()+selfLevel:getContentSize().width+5, selfLevel:getPositionY()))
	    jianSp:setPosition(ccp(selfHeartSp:getPositionX()+selfHeartSp:getContentSize().width+10, selfLevel:getPositionY()))
	    disLevel:setPosition(ccp(jianSp:getPositionX()+jianSp:getContentSize().width+10, selfLevel:getPositionY()))
	    disHeartSp:setPosition(ccp(disLevel:getPositionX()+disLevel:getContentSize().width+5, selfLevel:getPositionY()))
    else
    	-- 坐标居中
	    local posX = (bgSp:getContentSize().width-selfLevel:getContentSize().width-selfHeartSp:getContentSize().width-5)/2
	    selfLevel:setPosition(ccp(posX, bgSp:getContentSize().height*0.4))
	    selfHeartSp:setPosition(ccp(selfLevel:getPositionX()+selfLevel:getContentSize().width+5, selfLevel:getPositionY()))
    end
	return bgSp
end

-- 创建好感度交换node 下部ui
-- p_curDisStarId:选择的star_id
function createStarExchangeNode( p_curDisStarId )
	if(_bottomNode)then
		_bottomNode:removeFromParentAndCleanup(true)
		_bottomNode = nil
	end
	_bottomNode = CCLayerColor:create(ccc4(0,0,0,0))
	_bottomNode:ignoreAnchorPointForPosition(false)
	_bottomNode:registerScriptHandler(bottomNodeEvent)
	_bottomNode:setContentSize(CCSizeMake(640,190))
	_bottomNode:setAnchorPoint(ccp(0.5,0))
	_bottomNode:setPosition(ccp(bgSprite:getContentSize().width*0.5,20*MainScene.elementScale))
	bgSprite:addChild(_bottomNode)
	_bottomNode:setScale(MainScene.elementScale)

	-- 默认选择的icon
	local iconBgSprite1  = CCSprite:create("images/everyday/headBg1.png")
	iconBgSprite1:setAnchorPoint(ccp(0.5, 1))
	iconBgSprite1:setPosition(ccp(100, _bottomNode:getContentSize().height-5))
	_bottomNode:addChild(iconBgSprite1)
	-- 头像icon
	local onceHtid = HeroUtil.getOnceOrangeHtid(_curSrcStarData.star_tid)
	local iconSprite1 = HeroUtil.getHeroIconByHTID(onceHtid)
	iconSprite1:setAnchorPoint(ccp(0.5, 0.5))
	iconSprite1:setPosition(ccp(iconBgSprite1:getContentSize().width*0.5, iconBgSprite1:getContentSize().height*0.5))
	iconBgSprite1:addChild(iconSprite1)
	-- 名将名字
	--local heroData = HeroUtil.getHeroLocalInfoByHtid(_curSrcStarData.star_tid)
	local heroData = HeroUtil.getHeroLocalInfoByHtid(onceHtid)
    local nameColor = HeroPublicLua.getCCColorByStarLevel(heroData.star_lv)
	local scrHeroName = CCRenderLabel:create(heroData.name, g_sFontPangWa,18,1,ccc3(0x00,0x00,0x00),type_stroke)
	scrHeroName:setColor(nameColor)
	scrHeroName:setAnchorPoint(ccp(0.5,1))
	scrHeroName:setPosition(ccp(iconBgSprite1:getContentSize().width*0.5 ,-2))
	iconBgSprite1:addChild(scrHeroName)

	-- 提示
	local tipFont = CCRenderLabel:create(GetLocalizeStringBy("lic_1142") , g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    tipFont:setColor(ccc3(0x00, 0xff, 0x18))
    tipFont:setAnchorPoint(ccp(0.5,1))
    tipFont:setPosition(_bottomNode:getContentSize().width*0.5,_bottomNode:getContentSize().height-5)
    _bottomNode:addChild(tipFont)

    -- 互换好感按钮
    local menu = CCMenu:create()
    menu:setAnchorPoint(ccp(0,0))
    menu:setPosition(ccp(0,0))
    _bottomNode:addChild(menu)
    menu:setTouchPriority(-340)
    local normalSprite  = CCScale9Sprite:create("images/common/btn/btn1_d.png")
    normalSprite:setContentSize(CCSizeMake(260,73))
    local selectSprite  = CCScale9Sprite:create("images/common/btn/btn1_n.png")
    selectSprite:setContentSize(CCSizeMake(260,73))
    local exchangeMenuItem = CCMenuItemSprite:create(normalSprite,selectSprite)
    exchangeMenuItem:setAnchorPoint(ccp(0.5,0.5))
    exchangeMenuItem:setPosition(ccp(_bottomNode:getContentSize().width*0.5, _bottomNode:getContentSize().height-70))
    exchangeMenuItem:registerScriptTapHandler(exchangeMenuItemAction)
    menu:addChild(exchangeMenuItem)
    local  itemfont1 = CCRenderLabel:create( GetLocalizeStringBy("lic_1143"), g_sFontPangWa, 35, 1, ccc3(0x00,0x00,0x00), type_stroke)
    itemfont1:setAnchorPoint(ccp(0,0.5))
    itemfont1:setColor(ccc3(0xfe,0xdb,0x1c))
    itemfont1:setPosition(ccp(27,exchangeMenuItem:getContentSize().height*0.5))
    exchangeMenuItem:addChild(itemfont1)
    local goldSp = CCSprite:create("images/common/gold.png")
    goldSp:setAnchorPoint(ccp(0,0.5))
    goldSp:setPosition(ccp(itemfont1:getPositionX()+itemfont1:getContentSize().width+5,exchangeMenuItem:getContentSize().height*0.5))
    exchangeMenuItem:addChild(goldSp)
    -- 价格
    local costNum = StarUtil.getCostForStarExchange(_curSrcStarData.star_id)
    local priceFont = CCLabelTTF:create(costNum,g_sFontPangWa, 21)
    priceFont:setAnchorPoint(ccp(0,0.5))
    priceFont:setColor(ccc3(0xfe,0xdb,0x1c))
    priceFont:setPosition(ccp(goldSp:getPositionX()+goldSp:getContentSize().width+3,exchangeMenuItem:getContentSize().height*0.5))
    exchangeMenuItem:addChild(priceFont)

    -- 互相箭头
    local arrowSp = CCSprite:create("images/star/arrow.png")
    arrowSp:setAnchorPoint(ccp(0.5,1))
    arrowSp:setPosition(ccp(_bottomNode:getContentSize().width*0.5,exchangeMenuItem:getPositionY()-exchangeMenuItem:getContentSize().height*0.5-5))
    _bottomNode:addChild(arrowSp)

	-- 目标名将
	local iconBgSprite2  = CCSprite:create("images/everyday/headBg1.png")
	iconBgSprite2:setAnchorPoint(ccp(0.5, 1))
	iconBgSprite2:setPosition(ccp(_bottomNode:getContentSize().width-100, _bottomNode:getContentSize().height-5))
	_bottomNode:addChild(iconBgSprite2)
	-- 问号icon
	local iconSprite2 = ItemSprite.getWenHaoIconSprite()
	iconSprite2:setAnchorPoint(ccp(0.5, 0.5))
	iconSprite2:setPosition(ccp(iconBgSprite2:getContentSize().width*0.5, iconBgSprite2:getContentSize().height*0.5))
	iconBgSprite2:addChild(iconSprite2)

	if( p_curDisStarId )then
		iconSprite2:setVisible(false)
		-- 选择了交换名将
		local disStarData = StarUtil.getStarInfoBySid(p_curDisStarId)
		-- 头像icon
		local onceHtid = HeroUtil.getOnceOrangeHtid(disStarData.star_tid)
		local heroIconSprite = HeroUtil.getHeroIconByHTID(onceHtid)
		heroIconSprite:setAnchorPoint(ccp(0.5, 0.5))
		heroIconSprite:setPosition(ccp(iconBgSprite2:getContentSize().width*0.5, iconBgSprite2:getContentSize().height*0.5))
		iconBgSprite2:addChild(heroIconSprite)
		-- 名将名字
		--local heroData = HeroUtil.getHeroLocalInfoByHtid(disStarData.star_tid)
		local heroData = HeroUtil.getHeroLocalInfoByHtid(onceHtid)
	    local nameColor = HeroPublicLua.getCCColorByStarLevel(heroData.star_lv)
		local disHeroName = CCRenderLabel:create(heroData.name, g_sFontPangWa,18,1,ccc3(0x00,0x00,0x00),type_stroke)
		disHeroName:setColor(nameColor)
		disHeroName:setAnchorPoint(ccp(0.5,1))
		disHeroName:setPosition(ccp(iconBgSprite2:getContentSize().width*0.5 ,-2))
		iconBgSprite2:addChild(disHeroName)

		-- 左边 自己等级
		local selfLevelSp = createStarLoveLevel( tonumber(_curSrcStarData.level), tonumber(disStarData.level) )
		selfLevelSp:setAnchorPoint(ccp(0.5,1))
		selfLevelSp:setPosition(ccp(iconBgSprite1:getContentSize().width*0.5 , -scrHeroName:getContentSize().height))
		iconBgSprite1:addChild(selfLevelSp)

		-- 右边 目标等级
		local disLevelSp = createStarLoveLevel( tonumber(disStarData.level), tonumber(_curSrcStarData.level) )
		disLevelSp:setAnchorPoint(ccp(0.5,1))
		disLevelSp:setPosition(ccp(iconBgSprite2:getContentSize().width*0.5 , -disHeroName:getContentSize().height))
		iconBgSprite2:addChild(disLevelSp)

	else
		-- 没选择交换的名将
		-- 左边 自己等级
		local selfLevelSp = createStarLoveLevel( tonumber(_curSrcStarData.level) )
		selfLevelSp:setAnchorPoint(ccp(0.5,1))
		selfLevelSp:setPosition(ccp(iconBgSprite1:getContentSize().width*0.5 , -scrHeroName:getContentSize().height))
		iconBgSprite1:addChild(selfLevelSp)
		
	end
end


-- 点击名将回调
local function clickBtnAction( tag, itemBtn )
	-- 音效
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	if(_isShowExchange)then
		itemBtn:selected()
		if(itemBtn ~= _curStarBtn) then
			if(tolua.cast(_curStarBtn,"CCMenuItem") ~= nil)then
				_curStarBtn:unselected()
			end
			_curStarBtn = itemBtn
			_curDisStarId = tag
			if(tolua.cast(_curHighLight,"CCSprite"))then
				_curHighLight:removeFromParentAndCleanup(true)
				_curHighLight = nil
			end
			_curHighLight 	= CCSprite:create("images/hero/quality/highlighted.png")
	    	_curHighLight:setAnchorPoint(ccp(0.5, 0.5))
	    	_curHighLight:setPosition(ccpsprite(0.5, 0.5, _curStarBtn))
	    	_curStarBtn:addChild(_curHighLight,2,10001)

	    	-- 刷新底部ui
	    	createStarExchangeNode(_curDisStarId)
		end
	else
		local starLayer = StarLayer.createLayer(tag)
		MainScene.changeLayer(starLayer, "starLayer")
	end
end


function countryAction( tag, itemBtn )
	itemBtn:selected()
	if(itemBtn ~= _curCountyItem) then
		require "script/audio/AudioUtil"
		AudioUtil.playEffect("audio/effect/changtiaoxing.mp3")
		_curCountyItem:unselected()
		_curCountyItem = itemBtn
		_curCountyItem:selected()
		_curCountry = (tag - 9000)

		local t_node = tolua.cast(itemBtn:getChildByTag(99), "CCNode")
		if(t_node) then
			t_node:removeFromParentAndCleanup(true)
			t_node=nil
		end
		if(_isShowExchange)then
			if(tolua.cast(_curHighLight,"CCSprite"))then
				_curHighLight:removeFromParentAndCleanup(true)
				_curHighLight = nil
			end
			_curStarBtn = nil
			_curStarList = StarUtil.getExchangeListByCountry(_curCountry,_curSrcStarData)
		else
			_curStarList = StarUtil.getStarListByCountry(_curCountry)
		end
		_starTableView:reloadData()


	end
end

-- 创建4个标签
local function createMenuItem(  )
	local country_text = {GetLocalizeStringBy("key_1127"), GetLocalizeStringBy("key_1815"), GetLocalizeStringBy("key_1710"), GetLocalizeStringBy("key_2524")}
	local t_width = _tableViewSprite:getContentSize().width
	local itemPositionX = {20.0/600*t_width, 165.0/600*t_width, 305/600*t_width, 450/600*t_width}

	local image_n = "images/common/bg/button/ng_tab_n.png"
	local image_h = "images/common/bg/button/ng_tab_h.png"
	local rect_full_n 	= CCRectMake(0,0,63,43)
	local rect_inset_n 	= CCRectMake(25,20,13,3)
	local rect_full_h 	= CCRectMake(0,0,73,53)
	local rect_inset_h 	= CCRectMake(35,25,3,3)
	local btn_size_n	= CCSizeMake(135, 45)
	local btn_size_h	= CCSizeMake(140, 55)
	
	local text_color_n	= ccc3(0x76, 0x3b, 0x0b) 
	local text_color_h	= ccc3(0x7c, 0x48, 0x01) 
	local font			= g_sFontName
	local font_size		= 30
	local strokeCor_n	= ccc3(0xd7, 0xa5, 0x56) 
	local strokeCor_h	= ccc3(0xff, 0xf9, 0xd0)  
	local stroke_size	= 1

	local menuBar = CCMenu:create()
	menuBar:setTouchPriority(-230)
	menuBar:setPosition(ccp(0,0))
	_tableViewSprite:addChild(menuBar)

	

	for i=1,4 do
		local text = country_text[i]
		local menuItem = LuaCCMenuItem.createMenuItemOfRender(  image_n, image_h, rect_full_n, rect_inset_n, rect_full_h, rect_inset_h, btn_size_n, btn_size_h, text, text_color_n, text_color_h, font, font_size, strokeCor_n, strokeCor_h, stroke_size )
		menuItem:setAnchorPoint(ccp(0,0))
		menuItem:setPosition(ccp(itemPositionX[i], _tableViewSprite:getContentSize().height))
		menuItem:registerScriptTapHandler(countryAction)
		menuBar:addChild(menuItem, 1, 9000+i)
		if(i == 1) then
			_curCountyItem = menuItem
			_curCountyItem:selected()
		elseif( not table.isEmpty(_newStarInfos) and not table.isEmpty(_newStarInfos[i]) ) then
			local temp_num = 0
			for k,v in pairs(_newStarInfos[i]) do
				temp_num = temp_num + 1
			end
			-- 名将个数
		    -- local newSatrNumLabel = CCRenderLabel:create("new " .. temp_num , g_sFontName, 22, 1, ccc3( 0x49, 0x17, 0x00), type_stroke)
		    -- newSatrNumLabel:setColor(ccc3(0xff, 0xff, 0xff))
		    -- newSatrNumLabel:setPosition(40, 50)
		    -- menuItem:addChild(newSatrNumLabel, 1, 99)
		    require "script/utils/ItemDropUtil"
			local newSatrSprite = ItemDropUtil.getTipSpriteByNum(temp_num)  
			newSatrSprite:setAnchorPoint(ccp(0.5, 0.5))
			newSatrSprite:setPosition(menuItem:getContentSize().width, menuItem:getContentSize().height)
		    menuItem:addChild(newSatrSprite,1, 99)
		end
		

	end
end

-- 创建tableview
local function createStarTableView()

	local cellSize = CCSizeMake(565, 175)
    -- local myScale = bgLayer:getContentSize().width/cellBg:getContentSize().width/bgLayer:getElementScale()

	local h = LuaEventHandler:create(function(fn, table_t, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = cellSize --CCSizeMake(cellSize.width*myScale, cellSize.height*myScale)
		elseif fn == "cellAtIndex" then
			print("a1=====", a1)
			a2 = CCTableViewCell:create()
			local fullRect = CCRectMake(0,0,75, 75)
			local insetRect = CCRectMake(30,30,15,15)
			local cellSpite = CCScale9Sprite:create("images/star/cell9s.png", fullRect, insetRect)
			cellSpite:setPreferredSize(CCSizeMake(565, 165))  -- (CCSizeMake(640, 930))
			cellSpite:setAnchorPoint(ccp(0, 0))
			cellSpite:setPosition(ccp(0, 0))
			-- cellSpite:setScale(1/MainScene.elementScale)
			a2:addChild(cellSpite)

			-- 五个star
			local start = a1*5
			for i=1,5 do
				if (start + i <= #_curStarList) then
					local isNeedLine = true
					if(i==5 or (start + i) == #_curStarList)then
						isNeedLine = false
					end
					local onceHtid = HeroUtil.getOnceOrangeHtid(_curStarList[start + i].star_tid)
					local iconSprite = StarSprite.createIconButton( onceHtid, _curStarList[start + i].level, _curStarList[start + i].star_id, isNeedLine, clickBtnAction )
		            iconSprite:setAnchorPoint(ccp(0.5, 0.5))
		            iconSprite:setPosition(ccp( cellSpite:getContentSize().width/5/2 + (i-1) * cellSpite:getContentSize().width/5  , cellSpite:getContentSize().height * 0.5))
		            cellSpite:addChild(iconSprite)

		            if( tonumber(_curStarList[start + i].star_id) == tonumber(_curDisStarId) )then
						tolua.cast(iconSprite:getChildByTag(10):getChildByTag( _curDisStarId),"CCMenuItemImage"):selected()
						_curStarBtn = iconSprite:getChildByTag(10):getChildByTag( _curDisStarId)
						if(tolua.cast(_curHighLight,"CCSprite"))then
							_curHighLight:removeFromParentAndCleanup(true)
							_curHighLight = nil
						end
						_curHighLight 	= CCSprite:create("images/hero/quality/highlighted.png")
				    	_curHighLight:setAnchorPoint(ccp(0.5, 0.5))
				    	_curHighLight:setPosition(ccpsprite(0.5, 0.5, _curStarBtn))
				    	_curStarBtn:addChild(_curHighLight,2,10001)
					end

		            if( (not table.isEmpty(_newStarInfos)) and (not table.isEmpty(_newStarInfos[_curCountry])) ) then
		            	for t_star_id,v in pairs(_newStarInfos[_curCountry]) do
		            		if(tonumber(t_star_id) == tonumber(_curStarList[start + i].star_id) )then 
								-- local newSatrLabel = CCRenderLabel:create("new ", g_sFontName, 22, 1, ccc3( 0x49, 0x17, 0x00), type_stroke)
							    -- newSatrLabel:setColor(ccc3(0xff, 0xff, 0xff))
							    -- newSatrLabel:setPosition(40, 110)
							    -- iconSprite:addChild(newSatrLabel, 99)

							    require "script/utils/ItemDropUtil"
								local newSatrSprite = ItemDropUtil.getTipSpriteByNum(1)  
								newSatrSprite:setAnchorPoint(ccp(0.5, 0.5))
								newSatrSprite:setPosition(iconSprite:getContentSize().width, iconSprite:getContentSize().height)
							    iconSprite:addChild(newSatrSprite)
							    -- 删除
							    StarUtil.deleteNewStarBy( tonumber(t_star_id) )
		            		end
		            	end
		            end
				end
			end
            -- a2:setScale(myScale)

			r = a2
		elseif fn == "numberOfCells" then
			local count = #_curStarList
			-- if (math.mod(count, 5) == 0 ) then
			-- 	r = count /5
			-- else
			-- 	r = count /5 +1
			-- end
			r = math.ceil(count /5)

		elseif fn == "cellTouched" then
			print("a1=====", a1:getIdx())
		elseif (fn == "scroll") then
			
		end
		return r
	end)
	local viewHeight = nil
	if(_isShowExchange)then
		viewHeight = bgSprite:getContentSize().height-topSprite:getContentSize().height*MainScene.elementScale-130*MainScene.elementScale-_bottomNode:getContentSize().height*MainScene.elementScale
	else
		viewHeight = bgSprite:getContentSize().height-topSprite:getContentSize().height*MainScene.elementScale-130*MainScene.elementScale-totalLevelTitle:getPositionY()
	end
	_starTableView = LuaTableView:createWithHandler(h, CCSizeMake(570, viewHeight/MainScene.elementScale))
    _starTableView:setAnchorPoint(ccp(0, 0))
	_starTableView:setBounceable(true)
	_starTableView:setPosition(ccp(15, 10))
	_starTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	_tableViewSprite:addChild(_starTableView)
	
end

-- 返回的名将详情
local function backAction( tag, item )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	local starLayer = StarLayer.createLayer()
	MainScene.changeLayer(starLayer, "starLayer")
end

-- 关闭按钮回调
local function closeButtonCallback( tag, item_obj )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	local starLayer = StarLayer.createLayer(_curSrcStarData.star_id)
	MainScene.changeLayer(starLayer, "starLayer")
end

---- 
local function createUI()

	local bgSize = _bgLayer:getContentSize()
	local myScale = _bgLayer:getContentSize().width/640/_bgLayer:getElementScale()

	-- 顶部
	topSprite = CCSprite:create("images/item/equipinfo/topbg.png")
	topSprite:setAnchorPoint(ccp(0.5, 1))
	topSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5, _bgLayer:getContentSize().height))
	_bgLayer:addChild(topSprite, 2)
	topSprite:setScale(myScale)

	-- 标题
	local titleStr = nil
	if(_isShowExchange)then
		-- 好感互换
		titleStr = GetLocalizeStringBy("lic_1141")
	else
		-- 名将录
		titleStr = GetLocalizeStringBy("key_1525")
	end
	local titleLabel = LuaCCLabel.createShadowLabel(titleStr, g_sFontPangWa, 35)
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	titleLabel:setAnchorPoint(ccp(0.5, 0.5))
	titleLabel:setPosition(ccp(topSprite:getContentSize().width/2, topSprite:getContentSize().height* 0.6))
	topSprite:addChild(titleLabel)

	if(_isShowExchange)then
		-- 好感互换 关闭按钮
		local closeMenu = CCMenu:create()
		closeMenu:setPosition(ccp(0, 0))
		closeMenu:setAnchorPoint(ccp(0, 0))
		topSprite:addChild(closeMenu)
		local closeButton = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
		closeButton:setAnchorPoint(ccp(1, 0.5))
		closeButton:setPosition(ccp(topSprite:getContentSize().width, topSprite:getContentSize().height*0.5+4 ))
		closeButton:registerScriptTapHandler(closeButtonCallback)
		closeMenu:addChild(closeButton)
	end

	-- 背景
	local fullRect = CCRectMake(0,0,196, 198)
	local insetRect = CCRectMake(50,50,96,98)
	bgSprite = CCScale9Sprite:create("images/item/equipinfo/bg_9s.png", fullRect, insetRect)
	bgSprite:setPreferredSize(_bgLayer:getContentSize())  -- (CCSizeMake(640, 930))
	bgSprite:setAnchorPoint(ccp(0.5, 1))
	bgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5, _bgLayer:getContentSize().height))
	bgSprite:setScale(1/MainScene.elementScale)
	_bgLayer:addChild(bgSprite, 1)

	if(_isShowExchange)then
		-- 好感互换下部ui
		createStarExchangeNode()
	else
		---- 当前名将好感度总和
		--scale and position changed by zhang zihang
		totalLevelTitle = CCRenderLabel:create(GetLocalizeStringBy("key_1437") , g_sFontPangWa, 30, 1, ccc3( 0xff, 0xff, 0xff), type_stroke)
    totalLevelTitle:setColor(ccc3(0x78, 0x25, 0x00))
    --兼容东南亚英文版
    if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
    	totalLevelTitle:setPosition(bgSprite:getContentSize().width*0.1, bgSprite:getContentSize().height*0.17)
    else
    	totalLevelTitle:setPosition(bgSprite:getContentSize().width*0.25, bgSprite:getContentSize().height*0.17)
    end
    totalLevelTitle:setScale(g_fElementScaleRatio)
    totalLevelTitle:setAnchorPoint(ccp(0,1))
    bgSprite:addChild(totalLevelTitle,999)

    local totalLevel = CCRenderLabel:create(_curTotalLevel , g_sFontName, 32, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    totalLevel:setColor(ccc3(0x36, 0xff, 0x00))
    totalLevel:setScale(g_fElementScaleRatio)
    --兼容东南亚英文版
    if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
    	totalLevel:setPosition(totalLevelTitle:getContentSize().width*g_fElementScaleRatio+5+bgSprite:getContentSize().width*0.1, bgSprite:getContentSize().height*0.17)
    else
    	totalLevel:setPosition(totalLevelTitle:getContentSize().width*g_fElementScaleRatio+5+bgSprite:getContentSize().width*0.25, bgSprite:getContentSize().height*0.17)
    end
    totalLevel:setAnchorPoint(ccp(0,1.2))
    bgSprite:addChild(totalLevel,999)

    local heartSprite = CCSprite:create( Img_Path .. "heart_b.png")
    heartSprite:setAnchorPoint(ccp(0, 1.2))
    heartSprite:setScale(g_fElementScaleRatio)
    --兼容东南亚英文版
    if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
    	heartSprite:setPosition(ccp((totalLevelTitle:getContentSize().width+totalLevel:getContentSize().width)*g_fElementScaleRatio+15+bgSprite:getContentSize().width*0.1, bgSprite:getContentSize().height*0.17))
    else
    	heartSprite:setPosition(ccp((totalLevelTitle:getContentSize().width+totalLevel:getContentSize().width)*g_fElementScaleRatio+15+bgSprite:getContentSize().width*0.25, bgSprite:getContentSize().height*0.17))
    end
    bgSprite:addChild(heartSprite)


	---- 返回到名将详情
		require "script/libs/LuaCC"
		local backMenuBar = CCMenu:create()
		backMenuBar:setPosition(ccp(0, 0))
		bgSprite:addChild(backMenuBar)
	    local m_backButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(210,73),GetLocalizeStringBy("key_3012"),ccc3(255,222,0))
	    m_backButton:setAnchorPoint(ccp(0.5,0))
	    m_backButton:setPosition(ccp(bgSprite:getContentSize().width*0.5,bgSprite:getContentSize().height*0.02))
	    m_backButton:registerScriptTapHandler(backAction)
	    m_backButton:setScale(MainScene.elementScale)
	    backMenuBar:addChild(m_backButton)
	end

---- tableview的背景
	local fullRect_2 = CCRectMake(0,0,75, 75)
	local insetRect_2 = CCRectMake(30,30,15,15)
	_tableViewSprite = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png", fullRect_2, insetRect_2)
	local viewHeight = nil
	if(_isShowExchange)then
		viewHeight = bgSprite:getContentSize().height-topSprite:getContentSize().height*MainScene.elementScale-110*MainScene.elementScale-_bottomNode:getContentSize().height*MainScene.elementScale
	else
		viewHeight = bgSprite:getContentSize().height-topSprite:getContentSize().height*MainScene.elementScale-110*MainScene.elementScale-totalLevelTitle:getPositionY()
	end
	_tableViewSprite:setPreferredSize(CCSizeMake(600, viewHeight/MainScene.elementScale))  -- (CCSizeMake(640, 930))
	_tableViewSprite:setAnchorPoint(ccp(0.5, 1))
	_tableViewSprite:setPosition(ccp(bgSprite:getContentSize().width*0.5, bgSprite:getContentSize().height-topSprite:getContentSize().height*MainScene.elementScale-60*MainScene.elementScale))
	_tableViewSprite:setScale(MainScene.elementScale)
	bgSprite:addChild(_tableViewSprite, 1)


---- 创建4个国家标签
 	createMenuItem()
---- 创建tableview
	createStarTableView()





	
end

---- 默认的starId
-- p_type 类型kExchangeType为好感互换 默认nil为名将录
-- p_srcStarData:默认互换的名将数据
function createLayer( p_type, p_srcStarData)
	init()
	_bgLayer = MainScene.createBaseLayer("images/main/module_bg.png", true, false,true)

	if(p_type == kExchangeType)then
		_isShowExchange = true
		_curSrcStarData = p_srcStarData
		-- print("_curSrcStarData:")
		-- print_t(_curSrcStarData)
		_curStarList = StarUtil.getExchangeListByCountry(1,_curSrcStarData)
		-- _newStarInfos = StarUtil.getNewStarInfos()
	else
		_curStarList, _curTotalLevel = StarUtil.getStarListByCountry(1)
		_newStarInfos = StarUtil.getNewStarInfos()
	end

	createUI()


	return _bgLayer
end

