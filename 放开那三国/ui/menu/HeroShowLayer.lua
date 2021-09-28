-- Filename: HeroShowLayer.lua.
-- Author: zhz.
-- Date: 2013-10-10
-- Purpose: 该文件用于武将图鉴

module ("HeroShowLayer", package.seeall)

require "script/ui/main/MenuLayer"
require "script/libs/LuaCCMenuItem"
require "script/ui/hero/HeroInfoLayer"
require "script/ui/hero/HeroPublicLua"
require "script/ui/hero/HeroPublicCC"
require "db/DB_Heroes"
require "script/model/hero/HeroModel"
require "script/network/RequestCenter"
require "script/ui/menu/CCMenuLayer"
require "script/ui/main/MainScene"
require "script/audio/AudioUtil"


local _bgLayer				-- 
local _panel				-- 标题
local _curMenuItem			-- 当前点击的 menuItem
local _curHeroes			-- 代表玩家已经收集到武将
local _allHeroes			-- 这页一共拥有的武将数码
local _numLabel 			-- 英雄的数量label
local _height				-- 高度
local _myTableViewSp		-- tableView 背景
local _myTableView  		-- tableView
local _curHerosData		  	-- 当前显示的英雄的数据
local _heroNumTable         -- tHeroNumByCountry = {wei=18, shu=56, wu=98, qun=99}
local _heroBookHtid			-- 从后端获得的


-- 初始化
local function init( )
	_bgLayer = nil
	_curMenuItem = nil
	_curHeroes = 0
	_allHeroes = 0
	_numLabel = nil
	_heroBookHtid = nil
	_heroNumTable = HeroModel.getHeroNumByCountry()

end

--关闭按钮的回调函数
local function closeCb( tag,item )
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	require "script/ui/menu/CCMenuLayer"
	local ccMenuLayer = CCMenuLayer.createMenuLayer()
	MainScene.changeLayer(ccMenuLayer, "ccMenu")
end

 -- 创建标题栏
local function createTitlePanel( )
	local panel = CCSprite:create("images/common/title_bg.png")
	panel:setScale(g_fScaleX/g_fElementScaleRatio)

	local menuLabel =  CCRenderLabel:create(GetLocalizeStringBy("key_1618"), g_sFontPangWa, 33, 1,ccc3(0x00,0x00,0x00), type_stroke)
	menuLabel:setColor(ccc3(0xff,0xe4,0x00))
	menuLabel:setPosition(ccp(panel:getContentSize().width*0.5,panel:getContentSize().height*0.5+3))
	menuLabel:setAnchorPoint(ccp(0.5,0.5))
	panel:addChild(menuLabel)

	--关闭按钮
	local menu = CCMenu:create()
	menu:setPosition(ccp(0,0))
	panel:addChild(menu)
	local closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeBtn:setAnchorPoint(ccp(1,0.5))
	closeBtn:setPosition(ccp(panel:getContentSize().width*1.01, panel:getContentSize().height/2))
	closeBtn:registerScriptTapHandler(closeCb)
	menu:addChild(closeBtn)

	return panel
end

-- 创建背景
local function createBackground(  )
	local spriteBg = CCScale9Sprite:create("images/common/bg/bg_ng.png")
	spriteBg:setContentSize(CCSizeMake(_bgLayer:getContentSize().width,_bgLayer:getContentSize().height))
	spriteBg:setPosition(_bgLayer:getContentSize().width*0.5,0)
	spriteBg:setScale(1/MainScene.elementScale)
	spriteBg:setAnchorPoint(ccp(0.5,0))
	_bgLayer:addChild(spriteBg)
end

-- 计算魏蜀吴 _heroNumTable 
function calHeroNumTable( )
	-- 计算魏国的hero
	local wei = 0
	local heroData = getHeroDataByIndex(1)
		if(not table.isEmpty(_heroBookHtid)) then
		for i =1, #heroData do
			for j =1 ,#_heroBookHtid do
				if( heroData[i] == _heroBookHtid[j]) then
					wei = wei+1
				end
			end
		end
	end
	_heroNumTable.wei = wei
	-- 蜀国
	local shu = 0
	local heroData = getHeroDataByIndex(2)
		if(not table.isEmpty(_heroBookHtid)) then
		for i =1, #heroData do
			for j =1 ,#_heroBookHtid do
				if( heroData[i] == _heroBookHtid[j]) then
					shu = shu+1
				end
			end
		end
	end
	_heroNumTable.shu = shu
	-- 吴国
	local wu = 0
	local heroData = getHeroDataByIndex(3)
		if(not table.isEmpty(_heroBookHtid)) then
		for i =1, #heroData do
			for j =1 ,#_heroBookHtid do
				if( heroData[i] == _heroBookHtid[j]) then
					wu = wu+1
				end
			end
		end
	end
	_heroNumTable.wu = wu
	-- 群
	local qun = 0
	local heroData = getHeroDataByIndex(4)
		if(not table.isEmpty(_heroBookHtid)) then
		for i =1, #heroData do
			for j =1 ,#_heroBookHtid do
				if( heroData[i] == _heroBookHtid[j]) then
					qun = qun+1
				end
			end
		end
	end
	_heroNumTable.qun = qun
end


local function menuAction( tag,item )
	_curMenuItem:unselected()
	_curMenuItem = item
	AudioUtil.playEffect("audio/effect/changtiaoxing.mp3")
	item:selected()
	tag = tag -1000
	if( tag == 1) then
		_curHerosData = getHeroDataByIndex(1)	
		_numLabel:setString( _heroNumTable.wei.. "/" .. #_curHerosData)
	elseif(tag == 2) then
		_curHerosData = getHeroDataByIndex(2)
		_numLabel:setString( _heroNumTable.shu .. "/" .. #_curHerosData)
	elseif (tag == 3) then
		_curHerosData = getHeroDataByIndex(3)
		_numLabel:setString( _heroNumTable.wu .. "/" .. #_curHerosData)
	else
		_curHerosData = getHeroDataByIndex(4)
		_numLabel:setString( _heroNumTable.qun .. "/" .. #_curHerosData)
	end
	_myTableView:reloadData()

end


-- 创建按钮
local function createMenuItem( )
	local heroText = {GetLocalizeStringBy("key_1609"),GetLocalizeStringBy("key_3189"),GetLocalizeStringBy("key_1305"),GetLocalizeStringBy("key_2524")}

	local menuBar = CCMenu:create()
	menuBar:setPosition(ccp(0,0))
	menuBar:setTouchPriority(-661)
	menuBar:setAnchorPoint(ccp(0,0))
	_bgLayer:addChild(menuBar)

	local image_n = "images/common/bg/button/ng_tab_n.png"
	local image_h = "images/common/bg/button/ng_tab_h.png"
	local rect_full_n 	= CCRectMake(0,0,63,43)
	local rect_inset_n 	= CCRectMake(25,20,13,3)
	local rect_full_h 	= CCRectMake(0,0,73,53)
	local rect_inset_h 	= CCRectMake(35,25,3,3)
	local btn_size_n	= CCSizeMake(117, 45)
	local btn_size_h	= CCSizeMake(117, 55)	
	local text_color_n	= ccc3(0x76, 0x3b, 0x0b) 
	local text_color_h	= ccc3(0x7c, 0x48, 0x01) 
	local font			= g_sFontName
	local font_size		= 30
	local strokeCor_n	= ccc3(0xd7, 0xa5, 0x56) 
	local strokeCor_h	= ccc3(0xff, 0xf9, 0xd0)  
	local stroke_size	= 1
	--计算高度
	local height = _bgLayer:getContentSize().height/MainScene.elementScale - _panel:getContentSize().height - 12
	 for i =1, 4 do 
		local text = heroText[i]
		local menuItem = LuaCCMenuItem.createMenuItemOfRender( image_n, image_h, rect_full_n, rect_inset_n, rect_full_h, rect_inset_h, btn_size_n, btn_size_h, text, text_color_n, text_color_h, font, font_size, strokeCor_n, strokeCor_h, stroke_size )
		menuItem:setPosition(ccp(_bgLayer:getContentSize().width*(0.12+(i-1)*0.2)/MainScene.elementScale, height))
		
		menuItem:setAnchorPoint(ccp(0,1))
		menuBar:addChild(menuItem,1, 1000+i)
		if(i == 1)  then 
			menuItem:selected()
			_curMenuItem = menuItem
			_height = height - menuItem:getContentSize().height
		end
		menuItem:registerScriptTapHandler(menuAction)
	end

end

-- 通过 index 获得所有武将的信息
-- 1,魏国， 2 ：蜀国，3：吴国，4：群雄
function getHeroDataByIndex( index )
	
	 require "db/DB_Hero_show"
	 local heroesData = DB_Hero_show.getDataById(index).heroes
	 heroesData = string.gsub(heroesData, " ", "")
	 heroesData = lua_string_split(heroesData, ",")
	 return heroesData
end

-- 得到不可显示英雄的头像
local function getEnableHeroIcon( )

	local potentialSprite = CCMenuItemImage:create("images/base/potential/props_1.png","images/base/potential/props_1.png") --CCSprite:create("images/base/potential/props_1.png")
	local headSprite  = CCSprite:create("images/common/ask.png")
	potentialSprite:setEnabled(false)
	headSprite:setAnchorPoint(ccp(0.5, 0.5))
	headSprite:setPosition(ccp(potentialSprite:getContentSize().width*0.5, potentialSprite:getContentSize().height*0.5))
	potentialSprite:addChild(headSprite)

	-- 名字的背景
	local nameBgSprite = CCScale9Sprite:create("images/common/bg/name.png")
	nameBgSprite:setAnchorPoint(ccp(0.5, 1))
	nameBgSprite:setScale(0.9)
	nameBgSprite:setPosition(ccp(potentialSprite:getContentSize().width*0.5, -potentialSprite:getContentSize().height*0.01))
	potentialSprite:addChild(nameBgSprite)

	-- 小问号
	local alertContent = {}
	alertContent[1] = CCSprite:create("images/common/ask.png")
	alertContent[1]:setScale(0.3)
	alertContent[2] = CCSprite:create("images/common/ask.png")
	alertContent[2]:setScale(0.3)
	alertContent[3]= CCSprite:create("images/common/ask.png")
	alertContent[3]:setScale(0.3)
	local nameNode = BaseUI.createHorizontalNode(alertContent)
	nameNode:setAnchorPoint(ccp(0.5,0.5))
	nameNode:setPosition(ccp(nameBgSprite:getContentSize().width/2, nameBgSprite:getContentSize().height/2))
	--nameNode:setContentSize(CCSizeMake(nameBgSprite:getContentSize().width,nameBgSprite:getContentSize().height))
	nameBgSprite:addChild(nameNode)

	return potentialSprite
end

-- 获得英雄的头像
local function getHeroButton( htid , boolLine)

	-- 判断是否获得过武将
	local boolExsit = false
	if(not table.isEmpty(_heroBookHtid)) then
		for i=1 ,#_heroBookHtid do
			if(htid == _heroBookHtid[i]) then
				boolExsit = true
			end
		end
	end
	if(false == boolExsit) then
		return  getEnableHeroIcon( )
	end

	local headSprite =  HeroPublicCC.getCMISHeadIconFullByHtid(htid)
	headSprite:setEnabled(boolExsit)
	-- 名字背景
	local nameBgSprite = CCScale9Sprite:create("images/common/bg/name.png")
	nameBgSprite:setAnchorPoint(ccp(0.5, 1))
	nameBgSprite:setScale(0.9)
	nameBgSprite:setPosition(ccp(headSprite:getContentSize().width*0.5, -headSprite:getContentSize().height*0.01))
	headSprite:addChild(nameBgSprite)
	
	-- 名字
	local heroData = DB_Heroes.getDataById(htid)

	local nameColor --=  HeroPublicLua.getCCColorByStarLevel(heroData.star_lv)
	if(boolExsit == true ) then
		nameColor = HeroPublicLua.getCCColorByStarLevel(heroData.star_lv)
	else
		nameColor = ccc3(0x64,0x64,0x64)
	end

	local nameLabel = CCRenderLabel:create("" .. heroData.name, g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    nameLabel:setColor(nameColor)
    nameLabel:setAnchorPoint(ccp(0.5, 0.5))
    nameLabel:setPosition(ccp(nameBgSprite:getContentSize().width*0.5, nameBgSprite:getContentSize().height*0.5))
    nameBgSprite:addChild(nameLabel)

    -- 线
    if( boolLine == true ) then
		local lineSprite = CCSprite:create("images/common/line.png")
		lineSprite:setAnchorPoint(ccp(0,0.5))
		lineSprite:setScaleY(0.8)
		lineSprite:setPosition(ccp(headSprite:getContentSize().width*1.2, headSprite:getContentSize().height*0.4))
		headSprite:addChild(lineSprite)
	end

    return headSprite
end

-- 获得英雄的信息
local function getHeroData( htid)
	local value = {}

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

	--closeCb()
	local data = getHeroData(tag)
	local tArgs = {}
	tArgs.sign = "HeroShowLayer"
	tArgs.fnCreate = HeroShowLayer.createLayer
	tArgs.reserved =  {index= 10001}
	HeroInfoLayer.createLayer(data, {isPanel=true})
	-- MainScene.changeLayer(HeroInfoLayer.createLayer(data, tArgs), "HeroInfoLayer")
end

-- 创建 tableView
function createTableView(  )
	
	-- tableView 的背景
    _myTableViewSpite = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
    _myTableViewSpite:setContentSize(CCSizeMake(589,_height - 79))
    -- _myTableViewSpite:setScale(MainScene.elementScale)
    print("_height is :", _height)
    _myTableViewSpite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_height*MainScene.elementScale ))
    _myTableViewSpite:setAnchorPoint(ccp(0.5,1))
    _bgLayer:addChild(_myTableViewSpite)

    _curHerosData = getHeroDataByIndex(1)
    print_t(_curHerosData)
    -- 创建TableView
    local cellSize = CCSizeMake(586, 145)           --计算cell大小
    local myScale 
        local h = LuaEventHandler:create(function(fn, table, a1, a2)    --创建
        local r
        if fn == "cellSize" then
            r = CCSizeMake(cellSize.width, cellSize.height)
        elseif fn == "cellAtIndex" then
           a2 = CCTableViewCell:create()
          	local cellSpite = CCScale9Sprite:create("images/star/cell9s.png")
			cellSpite:setPreferredSize(CCSizeMake(582, 140))  -- (CCSizeMake(640, 930))
			cellSpite:setAnchorPoint(ccp(0, 0))
			cellSpite:setPosition(ccp(0, 0))
			-- cellSpite:setScale(1/MainScene.elementScale)
			a2:addChild(cellSpite)

           local menu = BTSensitiveMenu:create()
           if(menu:retainCount()>1)then
		        menu:release()
		        menu:autorelease()
		    end
           menu:setPosition(ccp(0,0))
           cellSpite:addChild(menu)
           -- 判断是否有线
           local boolLine = true  
           for i =1, 4 do
           		if(a1*4 +i<= #_curHerosData) then 
           			if(i== 4) then
           				boolLine = false
           			end
           			-- 
	           	 	local headSprite = getHeroButton(_curHerosData[a1*4+i], boolLine) --HeroPublicCC.getCMISHeadIconByHtid(_curHerosData[a1*4+i])
	           	 	print(" the _curHerosData is :  " , _curHerosData[a1*4+i])   
	           		headSprite:setPosition(ccp(26+145*(i-1),cellSpite:getContentSize().height*0.58))
	           		headSprite:setAnchorPoint(ccp(0,0.5))
	           		headSprite:registerScriptTapHandler(heroSpriteCb)
	           		menu:addChild(headSprite,1, _curHerosData[a1*4+i])
	           	end
       	   end
           r = a2
        elseif fn == "numberOfCells" then
           r = math.ceil(#_curHerosData/4) 
          print("r is : ", r)
        elseif fn == "cellTouched" then
            print("cellTouched", a1:getIdx())

        elseif (fn == "scroll") then
            
        end
        return r
    end)
    _myTableView = LuaTableView:createWithHandler(h, CCSizeMake(590,_myTableViewSpite:getContentSize().height - 20))
    _myTableView:setBounceable(true)
    _myTableView:setPosition(ccp(3,10))
    _myTableView:setTouchPriority(-558)
    _myTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    _myTableViewSpite:addChild(_myTableView)

end



-- 创建英雄的数量 label
local function createHeroNum( )
	local numBg = CCScale9Sprite:create("images/common/bgng_lefttimes.png")
	numBg:setContentSize(CCSizeMake(130,35))
	numBg:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*30/817))
	numBg:setAnchorPoint(ccp(0.5,0))
	_bgLayer:addChild(numBg)

	_numLabel = CCLabelTTF:create( _heroNumTable.wei .. "/" .. #_curHerosData  ,g_sFontName,24)
	_numLabel:setColor(ccc3(0x36, 255, 0))
	_numLabel:setPosition(ccp(numBg:getContentSize().width/2,numBg:getContentSize().height/2-1.3))
	_numLabel:setAnchorPoint(ccp(0.5,0.5))
	numBg:addChild(_numLabel)

end

-- 获得 heroBook 的网络回调函数
local function getHeroBookAction( cbFlag, dictData, bRet )
	if(dictData.err ~= "ok") then
		return
	end
	_heroBookHtid = dictData.ret
	print_t(_heroBookHtid)
	createTableView()
	-- 计算heroNum
	calHeroNumTable()
	createHeroNum()
end


-- 创建界面
function createLayer(  )
	init()
	_bgLayer = MainScene.createBaseLayer("images/main/module_bg.png", true, false, true)
	-- 创建背景
	createBackground()

	-- 计算高度
	require "script/ui/main/BulletinLayer"
	local bulletinLayerSize = BulletinLayer.getLayerContentSize()
	-- local height = _bgLayer:getContentSize().height --  bulletinLayerSize.height*g_fScaleX
	print("_bgLayer:getContentSize().height  is : " , _bgLayer:getContentSize().height)
	-- 显示标题
	_panel = createTitlePanel( )
	_panel:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height))
	_panel:setAnchorPoint(ccp(0.5,1))
	_bgLayer:addChild(_panel)

	-- getHeroBook 的网络回调函数
	RequestCenter.hero_getHeroBook(getHeroBookAction)

	-- 创建标题按钮
	createMenuItem()
	
	return _bgLayer
end



