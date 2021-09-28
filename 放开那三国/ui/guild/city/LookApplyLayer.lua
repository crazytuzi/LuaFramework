-- FileName: LookApplyLayer.lua 
-- Author: licong 
-- Date: 14-4-21 
-- Purpose: 查看报名军团 


module("LookApplyLayer", package.seeall)

require "script/utils/BaseUI"
require "script/ui/guild/city/CityService"
require "script/ui/guild/GuildImpl"


local _bgLayer                  = nil
local _backGround 				= nil
local second_bg  				= nil
local _thisCityID 				= nil
local _listData 				= nil
local _selfData 				= nil

function init( ... )
	_bgLayer                    = nil
	_backGround 				= nil
	second_bg  					= nil
	_thisCityID 				= nil
	_listData 					= nil
	_selfData 					= nil
end

-- 测试数据
-- _listDataTem = {
-- 	{guild_name = GetLocalizeStringBy("key_1840"), guild_level = 21, contri_week = 100000, fight_force = 100000},
-- 	{guild_name = GetLocalizeStringBy("key_1912"), guild_level = 21, contri_week = 100000, fight_force = 100000},
-- 	{guild_name = GetLocalizeStringBy("key_1833"), guild_level = 21, contri_week = 100000, fight_force = 100000},
-- 	{guild_name = GetLocalizeStringBy("key_2715"), guild_level = 21, contri_week = 100000, fight_force = 100000},
-- 	{guild_name = GetLocalizeStringBy("key_1915"), guild_level = 21, contri_week = 100000, fight_force = 100000},
-- 	{guild_name = GetLocalizeStringBy("key_2085"), guild_level = 21, contri_week = 100000, fight_force = 100000},
-- 	{guild_name = GetLocalizeStringBy("key_1843"), guild_level = 21, contri_week = 100000, fight_force = 100000},
-- 	{guild_name = GetLocalizeStringBy("key_2012"), guild_level = 21, contri_week = 100000, fight_force = 100000},
-- 	{guild_name = GetLocalizeStringBy("key_1881"), guild_level = 21, contri_week = 100000, fight_force = 100000},
-- 	{guild_name = GetLocalizeStringBy("key_1134"), guild_level = 21, contri_week = 100000, fight_force = 100000},
-- }

-- _selfData = {
-- 	{guild_name = GetLocalizeStringBy("key_1840"), guild_level = 21, contri_week = 100000, fight_force = 100000}
-- }

-- touch事件处理
local function cardLayerTouch(eventType, x, y)
    return true    
end

-- 关闭按钮回调
function closeButtonCallback( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
	-- print("closeButtonCallback")
	if(_bgLayer)then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
end

function onNodeEvent( event )
	if (event == "enter") then
		print("enter")
		_bgLayer:registerScriptTouchHandler(cardLayerTouch,false,-453,true)
		_bgLayer:setTouchEnabled(true)
		-- 注册删除回调
		GuildImpl.registerCallBackFun("LookApplyLayer",closeButtonCallback)
	elseif (event == "exit") then
		print("exit")
		_bgLayer:unregisterScriptTouchHandler()
		_bgLayer = nil
		GuildImpl.registerCallBackFun("LookApplyLayer",nil)
	end
end

-- 初始化界面
function initLookApplyLayer( ... )
	
	_bgLayer = CCLayerColor:create(ccc4(11,11,11,200))
    _bgLayer:registerScriptHandler(onNodeEvent)
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,1000,1)

	-- 创建背景
	_backGround = CCScale9Sprite:create(CCRectMake(100, 80, 10, 20),"images/common/viewbg1.png")
    _backGround:setContentSize(CCSizeMake(620, 693))
    _backGround:setAnchorPoint(ccp(0.5,0.5))
    _backGround:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    _bgLayer:addChild(_backGround)
    -- 适配
    setAdaptNode(_backGround)
    -- 标题
    local titlePanel = CCSprite:create("images/common/viewtitle1.png")
	titlePanel:setAnchorPoint(ccp(0.5, 0.5))
	titlePanel:setPosition(ccp(_backGround:getContentSize().width/2, _backGround:getContentSize().height-6.6 ))
	_backGround:addChild(titlePanel)
	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("key_3364"), g_sFontPangWa, 33)
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titlePanel:getContentSize().width*0.5, titlePanel:getContentSize().height*0.5))
	titlePanel:addChild(titleLabel)

	-- 关闭按钮
	local menu = CCMenu:create()
    menu:setTouchPriority(-454)
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0, 0))
	_backGround:addChild(menu,3)
	local closeButton = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeButton:setAnchorPoint(ccp(0.5, 0.5))
	closeButton:setPosition(ccp(_backGround:getContentSize().width * 0.955, _backGround:getContentSize().height*0.975 ))
	closeButton:registerScriptTapHandler(closeButtonCallback)
	menu:addChild(closeButton)

-- 二级背景
	second_bg = BaseUI.createContentBg(CCSizeMake(556,377))
 	second_bg:setAnchorPoint(ccp(0.5,0))
 	second_bg:setPosition(ccp(_backGround:getContentSize().width*0.5,205))
 	_backGround:addChild(second_bg)

-- 标题栏
	local fullRect = CCRectMake(0,0,74,63)
	local insetRect = CCRectMake(34,18,4,1)
	local titleBg = CCScale9Sprite:create("images/guild/city/titleBg.png", fullRect, insetRect)
	titleBg:setContentSize(CCSizeMake(563,63))
	titleBg:setAnchorPoint(ccp(0.5,0))
	titleBg:setPosition(ccp(second_bg:getContentSize().width/2,second_bg:getContentSize().height-15))
	second_bg:addChild(titleBg)
	local ming = CCSprite:create("images/guild/city/ming.png")
	ming:setAnchorPoint(ccp(0,0))
	ming:setPosition(ccp(30,22))
	titleBg:addChild(ming)
	local fenSp1 = CCSprite:create("images/guild/city/fen.png")
	fenSp1:setAnchorPoint(ccp(0,0))
	fenSp1:setPosition(ccp(ming:getPositionX()+ming:getContentSize().width+20,20))
	titleBg:addChild(fenSp1)
	local zhan = CCSprite:create("images/guild/city/zhan.png")
	zhan:setAnchorPoint(ccp(0,0))
	zhan:setPosition(ccp(fenSp1:getPositionX()+fenSp1:getContentSize().width+20,22))
	titleBg:addChild(zhan)
	local fenSp2 = CCSprite:create("images/guild/city/fen.png")
	fenSp2:setAnchorPoint(ccp(0,0))
	fenSp2:setPosition(ccp(zhan:getPositionX()+zhan:getContentSize().width+20,20))
	titleBg:addChild(fenSp2)
	local dengji = CCSprite:create("images/guild/city/dengji.png")
	dengji:setAnchorPoint(ccp(0,0))
	dengji:setPosition(ccp(fenSp2:getPositionX()+fenSp2:getContentSize().width+20,22))
	titleBg:addChild(dengji)
	local fenSp3 = CCSprite:create("images/guild/city/fen.png")
	fenSp3:setAnchorPoint(ccp(0,0))
	fenSp3:setPosition(ccp(dengji:getPositionX()+dengji:getContentSize().width+20,20))
	titleBg:addChild(fenSp3)
	local gongxian = CCSprite:create("images/guild/city/gongxian.png")
	gongxian:setAnchorPoint(ccp(0,0))
	gongxian:setPosition(ccp(fenSp3:getPositionX()+fenSp3:getContentSize().width+20,22))
	titleBg:addChild(gongxian)

-- 创建tableView
	createTableView()

-- 自己军团的排名
	local hongdi = CCSprite:create("images/guild/city/hongdi.png")
	hongdi:setAnchorPoint(ccp(0.5,0))
	hongdi:setPosition(ccp(_backGround:getContentSize().width/2,162))
	_backGround:addChild(hongdi)

	if(_selfData and not table.isEmpty(_selfData))then
		-- 名次
		local positionNum = _selfData.position or 0
		local positionFont = CCLabelTTF:create(positionNum,g_sFontPangWa,28)
		positionFont:setAnchorPoint(ccp(0,0.5))
		positionFont:setColor(ccc3(0x00,0xff,0x18))
		positionFont:setPosition(ccp(30,hongdi:getContentSize().height/2))
		hongdi:addChild(positionFont)
		
		-- 军团名字
		local guildName = _selfData.guild_name or GetLocalizeStringBy("key_1586")
		local guildNameFont = CCLabelTTF:create(guildName,g_sFontName,21)
		guildNameFont:setAnchorPoint(ccp(0,0.5))
		guildNameFont:setColor(ccc3(0x00,0xff,0x18))
		guildNameFont:setPosition(ccp(70,hongdi:getContentSize().height/2))
		hongdi:addChild(guildNameFont)
		
		-- 战斗力
		local fightScore = _selfData.fight_force or 0
		local fightFont = CCLabelTTF:create(fightScore,g_sFontName,21)
		fightFont:setColor(ccc3(0x00,0xff,0x18))
		fightFont:setAnchorPoint(ccp(0,0.5))
		fightFont:setPosition(ccp(195,hongdi:getContentSize().height/2))
		hongdi:addChild(fightFont)

		-- 军团等级
		local guildLevel = _selfData.guild_level or 0
		require "script/libs/LuaCC"
	    local lvNumSp = LuaCC.createNumberSprite02("images/main/vip", guildLevel)
	    lvNumSp:setAnchorPoint(ccp(0,0.5))
	    lvNumSp:setPosition(ccp(334,hongdi:getContentSize().height/2))
	    hongdi:addChild(lvNumSp)

		-- 贡献
		local gongxianNum = _selfData.contri_week or 0
		local gongxianFont = CCLabelTTF:create(gongxianNum,g_sFontName,21)
		gongxianFont:setColor(ccc3(0x00,0xff,0x18))
		gongxianFont:setAnchorPoint(ccp(0,0.5))
		gongxianFont:setPosition(ccp(436,hongdi:getContentSize().height/2))
		hongdi:addChild(gongxianFont)
	else
		local tishiFont = CCLabelTTF:create(GetLocalizeStringBy("key_2424"),g_sFontName,21)
		tishiFont:setColor(ccc3(0x00,0xff,0x18))
		tishiFont:setAnchorPoint(ccp(0.5,0.5))
		tishiFont:setPosition(ccp(hongdi:getContentSize().width/2,hongdi:getContentSize().height/2))
		hongdi:addChild(tishiFont)
	end


-- 两行字
	local isTip = false
	local str1 = nil
 	local str2 = nil
	local zhanling = CityInfoLayer.getOccupyInfo()
	if(not table.isEmpty(zhanling) and zhanling.guild_id and tonumber(zhanling.guild_id) > 0)then
		--  有占领军团
		str1 = GetLocalizeStringBy("key_2915")
		str2 = GetLocalizeStringBy("key_2755")
		-- 判断 是否提示
		if(_selfData and not table.isEmpty(_selfData))then
			if(_selfData.position > 2)then
				isTip = true
			end
		end
	else
		--  无占领军团
		str1 = GetLocalizeStringBy("key_2232")
		str2 = GetLocalizeStringBy("key_2756")
		-- 判断 是否提示
		if(_selfData and not table.isEmpty(_selfData))then
			if(_selfData.position > 3)then
				isTip = true
			end
		end
	end
 	local str3 = GetLocalizeStringBy("key_2834")
 	local str4 = GetLocalizeStringBy("key_3013")
 	local str5 = GetLocalizeStringBy("key_1795")
 	local font1 = CCLabelTTF:create(str1,g_sFontPangWa,25)
 	font1:setColor(ccc3(0x78,0x25,0x00))
 	font1:setAnchorPoint(ccp(0,0))
 	_backGround:addChild(font1)
 	local font2 = CCLabelTTF:create(str2,g_sFontPangWa,25)
 	font2:setColor(ccc3(0x00,0x8d,0x3d))
 	font2:setAnchorPoint(ccp(0,0))
 	_backGround:addChild(font2)
 	local font3 = CCLabelTTF:create(str3,g_sFontPangWa,25)
 	font3:setColor(ccc3(0x78,0x25,0x00))
 	font3:setAnchorPoint(ccp(0,0))
 	_backGround:addChild(font3)
 	local font4 = CCLabelTTF:create(str4,g_sFontPangWa,25)
 	font4:setColor(ccc3(0x78,0x25,0x00))
 	font4:setAnchorPoint(ccp(0.5,0))
 	_backGround:addChild(font4)
 	local font5 = CCLabelTTF:create(str5,g_sFontPangWa,25)
 	font5:setColor(ccc3(0x78,0x25,0x00))
 	font5:setAnchorPoint(ccp(0.5,0))
 	_backGround:addChild(font5)
 	
 	if(isTip)then
	 	local tiStr1 = GetLocalizeStringBy("key_1476")
	 	local tiStr2 = GetLocalizeStringBy("key_1275")
	 	local tiStr3 = GetLocalizeStringBy("key_2257")
	 	local tiFont1 = CCLabelTTF:create(tiStr1,g_sFontPangWa,25)
	 	tiFont1:setColor(ccc3(0x78,0x25,0x00))
	 	tiFont1:setAnchorPoint(ccp(0,0))
	 	_backGround:addChild(tiFont1)
	 	local tiFont2 = CCLabelTTF:create(tiStr2,g_sFontPangWa,25)
	 	tiFont2:setColor(ccc3(0xff,0x00,0x00))
	 	tiFont2:setAnchorPoint(ccp(0,0))
	 	_backGround:addChild(tiFont2)
	 	local tiFont3 = CCLabelTTF:create(tiStr3,g_sFontPangWa,25)
	 	tiFont3:setColor(ccc3(0x78,0x25,0x00))
	 	tiFont3:setAnchorPoint(ccp(0,0))
	 	_backGround:addChild(tiFont3)

	 	local pox = (_backGround:getContentSize().width-tiFont1:getContentSize().width-tiFont2:getContentSize().width-tiFont3:getContentSize().width)/2
	 	tiFont1:setPosition(ccp(pox,136))
	 	tiFont2:setPosition(ccp(tiFont1:getPositionX()+tiFont1:getContentSize().width,tiFont1:getPositionY()))
	 	tiFont3:setPosition(ccp(tiFont2:getPositionX()+tiFont2:getContentSize().width,tiFont1:getPositionY()))

	 	-- 两行字坐标
	 	font1:setPosition(ccp(35,107))
 		font2:setPosition(ccp(font1:getPositionX()+font1:getContentSize().width,font1:getPositionY()))
 		font3:setPosition(ccp(font2:getPositionX()+font2:getContentSize().width,font1:getPositionY()))
 		font4:setPosition(ccp(_backGround:getContentSize().width/2,77))
 		font5:setPosition(ccp(_backGround:getContentSize().width/2,47))
	else
		-- 两行字坐标
 		font1:setPosition(ccp(35,131))
 		font2:setPosition(ccp(font1:getPositionX()+font1:getContentSize().width,font1:getPositionY()))
 		font3:setPosition(ccp(font2:getPositionX()+font2:getContentSize().width,font1:getPositionY()))
 		font4:setPosition(ccp(_backGround:getContentSize().width/2,101))
 		font5:setPosition(ccp(_backGround:getContentSize().width/2,71))
	end

end

-- 创建tableView
function createTableView( ... )
	local cellSize = CCSizeMake(534, 80)
	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = cellSize
		elseif fn == "cellAtIndex" then
			r = createCell(_listData[a1+1])
		elseif fn == "numberOfCells" then
			r =  #_listData
		else
		end
		return r
	end)

	local tableView = LuaTableView:createWithHandler(h, CCSizeMake(534, 365))
	tableView:setBounceable(true)
	tableView:setTouchPriority(-453)
	tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	tableView:ignoreAnchorPointForPosition(false)
	tableView:setAnchorPoint(ccp(0.5,0.5))
	tableView:setPosition(ccp(second_bg:getContentSize().width*0.5,second_bg:getContentSize().height*0.5))
	second_bg:addChild(tableView)
end

-- cell
function createCell( tcellData )
	-- print("tcellData .. ")
	-- print_t(tcellData)

	local cell = CCTableViewCell:create()

	-- 名次
	local positionNum = tonumber(tcellData.position) or 1
	local positionFont = CCLabelTTF:create(positionNum,g_sFontPangWa,28)
	positionFont:setAnchorPoint(ccp(0,0.5))
	positionFont:setPosition(ccp(0,44))
	cell:addChild(positionFont)
	if(positionNum == 1)then
		positionFont:setColor(ccc3(0xff,0x00,0x00))
	elseif(positionNum == 2)then
		positionFont:setColor(ccc3(0xff,0x00,0xe4))
	elseif(positionNum == 3)then
		positionFont:setColor(ccc3(0x00,0xe4,0xff))
	else
		positionFont:setColor(ccc3(0xff,0xff,0xff))
	end

	-- 军团名字
	local guildName = tcellData.guild_name or GetLocalizeStringBy("key_1112")
	local guildNameFont = CCLabelTTF:create(guildName,g_sFontName,21)
	guildNameFont:setAnchorPoint(ccp(0,0.5))
	guildNameFont:setPosition(ccp(40,44))
	cell:addChild(guildNameFont)
	if(positionNum == 1)then
		guildNameFont:setColor(ccc3(0xff,0x00,0x00))
	elseif(positionNum == 2)then
		guildNameFont:setColor(ccc3(0xff,0x00,0xe4))
	elseif(positionNum == 3)then
		guildNameFont:setColor(ccc3(0x00,0xe4,0xff))
	else
		guildNameFont:setColor(ccc3(0xff,0xff,0xff))
	end

	-- 战斗力
	local fightScore = tcellData.fight_force or 0
	local fightFont = CCLabelTTF:create(fightScore,g_sFontName,21)
	fightFont:setColor(ccc3(0xff,0xf6,0x00))
	fightFont:setAnchorPoint(ccp(0,0.5))
	fightFont:setPosition(ccp(165,44))
	cell:addChild(fightFont)

	-- 军团等级
	local guildLevel = tcellData.guild_level or 0
	require "script/libs/LuaCC"
    local lvNumSp = LuaCC.createNumberSprite02("images/main/vip", guildLevel)
    lvNumSp:setPosition(ccp(304,44))
    lvNumSp:setAnchorPoint(ccp(0,0.5))
    cell:addChild(lvNumSp)

	-- 贡献
	local gongxianNum = tcellData.contri_week or 0
	local gongxianFont = CCLabelTTF:create(gongxianNum,g_sFontName,21)
	gongxianFont:setColor(ccc3(0x00,0xff,0x18))
	gongxianFont:setAnchorPoint(ccp(0,0.5))
	gongxianFont:setPosition(ccp(406,44))
	cell:addChild(gongxianFont)


	-- 分割线
 	local lineSprite = CCScale9Sprite:create("images/common/line02.png")
	lineSprite:setContentSize(CCSizeMake(534, 4))
	lineSprite:setAnchorPoint(ccp(0.5, 0))
	lineSprite:setPosition(ccp(247,0))
	cell:addChild(lineSprite)

	return cell
end

-- 网络请求回调
function serviceCallFunc( serviceData )
	-- list数据
	_listData = serviceData.list
	-- 自己公会的数据
	if(serviceData.self)then
		if(not table.isEmpty(serviceData.self) )then
			for k,v in pairs(serviceData.self) do
				v.position = tonumber(k)
				_selfData = v
			end
		end
	end
	-- 前端加入位置字段 position
	for k,v in pairs(_listData) do
		v.position = tonumber(k)
	end

	-- 初始化界面
	initLookApplyLayer()
end

-- 创建报名军团layer
function showLookApplyLayer( city_id )
	init()

	-- 该城池的报名列表
	_thisCityID = city_id

	-- 自己公会的id
	local data = GuildDataCache.getMineSigleGuildInfo()
	print("look---------")
	print_t(data)
	-- 网络请求
	CityService.getCitySignupList( _thisCityID, data.guild_id, serviceCallFunc)
end

















