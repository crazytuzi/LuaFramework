-- Filename: PreRecruitLayer.lua
-- Author: DJN
-- Date: 2014-11-24
-- Purpose: 该文件用于: 酒馆神将招将预览

module("PreRecruitLayer", package.seeall)
require "script/libs/LuaCCMenuItem"
require "script/ui/hero/HeroPublicCC"
require "script/model/DataCache"
require "script/ui/main/MainScene"
require "script/ui/hero/HeroInfoLayer"
require "script/ui/hero/HeroPublicLua"
require "script/audio/AudioUtil"

local _bgLayer 				-- 灰色的layer
local _myTableView          -- 
local _myTableViewSpite
local _allHeroData          -- 所有兑换武将的数据
local _curMenuItem 			-- 当前的按钮
local _index 				-- 当前是那个将：1 ，神将；2，良将；3， 战将
local _introduceLabel		-- 说明 
local _curHerosData 		-- 当前显示英雄的数据

local function init( )
	_bgLayer = nil
    _myTableView = nil
    _myTableViewSpite = nil
    _introduceLabel = nil
    _index = 1
    _curHerosData = nil
end

-- layer 的回调函数
local function layerToucCb(eventType, x, y)
	return true
end

-- 按钮的回调函数
-- local function menuAction( tag,menuItem )
-- 	_curMenuItem:unselected()
-- 	menuItem:selected()
-- 	_curMenuItem = menuItem
-- 	AudioUtil.playEffect("audio/effect/changtiaoxing.mp3")
-- 	tag = tag -1000
-- 	if( tag == 1) then
-- 		_introduceLabel:setString(GetLocalizeStringBy("key_1919"))
-- 		-- _index = 3
-- 		_curHerosData = getCurHerosData(3)
-- 		-- _myTableView:reloadData()
-- 	elseif(tag == 2) then
-- 		_introduceLabel:setString(GetLocalizeStringBy("key_1542"))
-- 		-- _index = 2
-- 		_curHerosData = getCurHerosData(2)
-- 		-- _myTableView:reloadData()
-- 	else 
-- 		_introduceLabel:setString(GetLocalizeStringBy("key_2965"))
-- 		-- _index = 1
-- 		_curHerosData = getCurHerosData(1)
-- 		-- _myTableView:reloadData()
-- 	end
-- 	_myTableView:reloadData()

-- end

-- 创建按钮
-- local function createMenuItem( heroExchangeBg)
-- 	local heroText = {GetLocalizeStringBy("key_1058"),GetLocalizeStringBy("key_1701"),GetLocalizeStringBy("key_2176")}

-- 	local menuBar = CCMenu:create()
-- 	menuBar:setPosition(ccp(0,0))
-- 	menuBar:setTouchPriority(-555)
-- 	heroExchangeBg:addChild(menuBar)

-- 	local image_n = "images/common/bg/button/ng_tab_n.png"
-- 	local image_h = "images/common/bg/button/ng_tab_h.png"
-- 	local rect_full_n 	= CCRectMake(0,0,63,43)
-- 	local rect_inset_n 	= CCRectMake(25,20,13,3)
-- 	local rect_full_h 	= CCRectMake(0,0,73,53)
-- 	local rect_inset_h 	= CCRectMake(35,25,3,3)
-- 	local btn_size_n	= CCSizeMake(174, 45)
-- 	local btn_size_h	= CCSizeMake(176, 55)	
-- 	local text_color_n	= ccc3(0x76, 0x3b, 0x0b) 
-- 	local text_color_h	= ccc3(0x7c, 0x48, 0x01) 
-- 	local font			= g_sFontName
-- 	local font_size		= 30
-- 	local strokeCor_n	= ccc3(0xd7, 0xa5, 0x56) 
-- 	local strokeCor_h	= ccc3(0xff, 0xf9, 0xd0)  
-- 	local stroke_size	= 1
-- 	 for i =1, 3 do 
-- 		local text = heroText[i]
-- 		local menuItem = LuaCCMenuItem.createMenuItemOfRender( image_n, image_h, rect_full_n, rect_inset_n, rect_full_h, rect_inset_h, btn_size_n, btn_size_h, text, text_color_n, text_color_h, font, font_size, strokeCor_n, strokeCor_h, stroke_size )
-- 		menuItem:setPosition(ccp(33+182*(i-1),554))
-- 		menuBar:addChild(menuItem,1, 1000+i)
-- 		if(i == 1)  then 
-- 			menuItem:selected()
-- 			_curMenuItem = menuItem
-- 		end
-- 		menuItem:registerScriptTapHandler(menuAction)
-- 	end

-- end

-- 获得英雄的信息
local function getHeroData( htid)
	value = {}

	value.htid = htid
	local db_hero = DB_Heroes.getDataById(htid)
	value.country_icon = HeroModel.getCiconByCidAndlevel(db_hero.country, db_hero.star_lv)
	value.name = db_hero.name
	value.level = db_hero.lv
	value.star_lv = db_hero.star_lv
	value.hero_cb = menu_item_tap_handler
	value.head_icon = "images/base/hero/head_icon/" .. db_hero.head_icon_id
    value.quality_bg = "images/hero/quality/"..value.star_lv .. ".png"
	value.quality_h = "images/hero/quality/highlighted.png"
	value.type = "HeroFragment"
	value.isRecruited = false
	value.evolve_level = 0

	return value
end

-- 点击英雄头像的回调函数
function heroSpriteCb( tag,menuItem )
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	--closeCb()
	local data = getHeroData(tag)
	local tArgs = {}
	tArgs.sign = "shopLayer"
	tArgs.fnCreate = ShopLayer.createLayer
	tArgs.reserved =  {index= 10001}
    tArgs.isPanel = true
    -- local param = {}
    -- param.isPanel = true
	HeroInfoLayer.createLayer(data, {isPanel=true},3005,-4030)
	--MainScene.changeLayer(HeroInfoLayer.createLayer(data, tArgs), "HeroInfoLayer")
end

-- 获得英雄的头像
local function getHeroButton( htid )

	-- 判断是否获得过武将

	local headSprite =  HeroPublicCC.getCMISHeadIconByHtid(htid)
	--headSprite:setEnabled(false)
    headSprite:setEnabled(true)
	-- 名字
	local nameBgSprite = CCScale9Sprite:create("images/common/bg/name.png")
	nameBgSprite:setAnchorPoint(ccp(0.5, 1))
	nameBgSprite:setScale(0.9)
	nameBgSprite:setScaleX(0.8)

	nameBgSprite:setPosition(ccp(headSprite:getContentSize().width*0.5, -headSprite:getContentSize().height*0.01))
	headSprite:addChild(nameBgSprite)
	
	-- 名字
	local heroData = DB_Heroes.getDataById(htid)

	local nameColor =  HeroPublicLua.getCCColorByStarLevel(heroData.star_lv)

	local nameLabel = CCRenderLabel:create("" .. heroData.name, g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    nameLabel:setColor(nameColor)
    nameLabel:setAnchorPoint(ccp(0.5, 0.5))
    nameLabel:setPosition(ccp(nameBgSprite:getContentSize().width*0.5, nameBgSprite:getContentSize().height*0.5))
    nameBgSprite:addChild(nameLabel)


    return headSprite
end

-- tableView
function createTableView( )
	local cellSize = CCSizeMake(550, 135)           --计算cell大小
    local myScale 
    -- 开始默认为 1， 即神将
     _curHerosData = getCurHerosData(3)
     -- print("the number of _curHerosData is : " , #_curHerosData)
     -- print("now the _curHerosData is : " , math.ceil(#_curHerosData/5))
    local h = LuaEventHandler:create(function(fn, table, a1, a2)    --创建
        local r
        if fn == "cellSize" then
            r = CCSizeMake(cellSize.width, cellSize.height)
        elseif fn == "cellAtIndex" then
           a2 = CCTableViewCell:create()
           local menu = BTSensitiveMenu:create()
           if(menu:retainCount()>1)then
		        menu:release()
		        menu:autorelease()
		    end
           menu:setPosition(ccp(0,0))
           menu:setTouchPriority(-4020)
           a2:addChild(menu)
                
           for i =1, 5 do
           		if(a1*5 +i<= #_curHerosData) then 
	           	 	local headSprite = getHeroButton(_curHerosData[a1*5+i]) --HeroPublicCC.getCMISHeadIconByHtid(_curHerosData[a1*5+i])
	           	 	print(" the _curHerosData is :  " , _curHerosData[a1*5+i])   
	           		headSprite:setPosition(ccp(17+112*(i-1),25))
	           		headSprite:registerScriptTapHandler(heroSpriteCb)
	           		menu:addChild(headSprite,1, _curHerosData[a1*5+i])
	           	end
       	   end
           r = a2
        elseif fn == "numberOfCells" then
           r = math.ceil(#_curHerosData/5)
          --print("r is : ", r)
        -- elseif fn == "cellTouched" then
        --     print("cellTouched", a1:getIdx())

        elseif (fn == "scroll") then
            
        end
        return r
    end)
    _myTableView = LuaTableView:createWithHandler(h, CCSizeMake(560,445))
    _myTableView:setBounceable(true)
    _myTableView:setPosition(ccp(0,10))
    _myTableView:setTouchPriority(-4021)
    _myTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    _myTableViewSpite:addChild(_myTableView)

end

-- 通过 _index 获得英雄的数据 
function getCurHerosData(_index )
	 -- _curHerosData
	 print("setCurHerosData  _index is : " , _index)
	 require "db/DB_Hero_view"
	 local tempData = DB_Hero_view.getDataById(_index).Heroes
	 tempData = string.gsub(tempData, " ", "")
	 tempData = lua_string_split(tempData, ",")
	 return tempData
end


-- 关闭按钮的回调函数
 function closeCb()
 	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
end

function createLayer()
	init()
	_bgLayer = CCLayerColor:create(ccc4(11,11,11,166))

	 -- 设置灰色layer的优先级
    _bgLayer:setTouchEnabled(true)
    -------------------因为上一个界面的touchPriority被写得奇高 为了避免穿透，这个界面不得不写很高
    _bgLayer:registerScriptTouchHandler(layerToucCb,false,-4010,true)
    -- local scene = CCDirector:sharedDirector():getRunningScene()

    local myScale = MainScene.elementScale
	local mySize = CCSizeMake(625,659)

	-- 背景
	local fullRect = CCRectMake(0, 0, 213, 171)
	local insetRect = CCRectMake(84, 84, 2, 3)
    local heroShowBg = CCScale9Sprite:create("images/common/viewbg1.png",fullRect,insetRect)
    heroShowBg:setContentSize(mySize)
    heroShowBg:setScale(myScale)
    heroShowBg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    heroShowBg:setAnchorPoint(ccp(0.5,0.5))
    _bgLayer:addChild(heroShowBg)

    -- 标题
    local titleBg= CCSprite:create("images/common/viewtitle1.png")
	titleBg:setPosition(ccp(heroShowBg:getContentSize().width*0.5, heroShowBg:getContentSize().height-6))
	titleBg:setAnchorPoint(ccp(0.5, 0.5))
	heroShowBg:addChild(titleBg)	
	 --武将兑换的的标题文本
	local labelTitle = CCRenderLabel:create(GetLocalizeStringBy("djn_96"), g_sFontPangWa,33,2,ccc3(0x00,0x00,0x0),type_shadow)
	-- labelTitle:setPosition(ccp(titleBg:getContentSize().width/2, (titleBg:getContentSize().height-1)/2))
	labelTitle:setColor(ccc3(0xff,0xe4,0x00))
	labelTitle:setPosition(ccp(titleBg:getContentSize().width*0.25,titleBg:getContentSize().height*0.87))
	titleBg:addChild(labelTitle)

	-- 关闭按钮
    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(-4020)
    heroShowBg:addChild(menu,99)
    local closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    closeBtn:setPosition(ccp(mySize.width*1.02,mySize.height*1.02))
    closeBtn:setAnchorPoint(ccp(1,1))
    closeBtn:registerScriptTapHandler(closeCb)
    menu:addChild(closeBtn)

    -- 黑色的背景
    _myTableViewSpite = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
    _myTableViewSpite:setContentSize(CCSizeMake(582,510))
    _myTableViewSpite:setPosition(ccp(mySize.width*0.5,45))
    _myTableViewSpite:setAnchorPoint(ccp(0.5,0))
    heroShowBg:addChild(_myTableViewSpite)

    -- 说明
    _introduceLabel = CCRenderLabel:create(GetLocalizeStringBy("djn_97"), g_sFontName,20,1,ccc3(0x49,0x00,0x0),type_stroke)
    _introduceLabel:setColor(ccc3(0xff,0xe4,0x00))
    _introduceLabel:setAnchorPoint(ccp(0.5,0))
    _introduceLabel:setPosition(ccp(mySize.width*0.5,520))
    heroShowBg:addChild(_introduceLabel)

    -- 添加按钮
   -- createMenuItem(heroShowBg)
    -- 创建TableView
    createTableView()
    -- setCurHerosData(_index)

	return _bgLayer

end
