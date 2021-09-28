-- Filename: GuildWarWorshipMainLayer.lua
-- Author: lichenyang
-- Date: 2015-01-20
-- Purpose: 个人跨服赛数据层

module("GuildWarWorshipMainLayer", package.seeall)

require "script/ui/guildWar/worship/GuildWarWorshipData"
require "script/ui/guildWar/worship/GuildWarWorshipService"

local kStationPos 	 = {ccps(0.19, 0.47),ccps(0.5, 0.25),ccps(0.81, 0.47)}
local kStationScale  = {0.75, 1, 0.75}
local kStationZorder = {5, 10, 5}

local _bgLayer 			= nil
local _layerSize 		= nil
local _selectIndex		= nil
local _championArray    = nil
local _moveLayer 		= nil
local _isMove 			= nil
local _updateScheduler 
local _bulletinVisible   --进来时记录顶部滚动通知栏是否显示，离开时恢复
local _touchPriority
local _zOrder

--[[
	@des 	:初始化
--]]
function init( ... )
	_bgLayer 		= nil
	_layerSize 		= nil
	_selectIndex	= 2
	_championArray  = {}
	_moveLayer 		= nil
	_isMove 		= true
	_bulletinVisible = false
	_touchPriority = nil
	_zOrder = nil
end

--[[
	@des 	:入口函数，用于场景切换
--]]
function show(p_touchPriority,p_zOrder)
	init()
    _touchPriority = p_touchPriority or -550
    _zOrder = p_zOrder or 999
    local layer = GuildWarWorshipMainLayer.createLayer()
    MainScene.changeLayer(layer, "GuildWarWorshipMainLayer")
end

--[[
	@des : 创建layer
--]]
function createLayer( ... )
	
	_bgLayer = CCLayer:create()
	
	_moveLayer = CCLayer:create()
	_bgLayer:addChild(_moveLayer, 20)	


	_layerSize = CCSizeMake(g_winSize.width, g_winSize.height)

	_bulletinVisible = MainScene.isBulletinVisible()

	MainScene.setMainSceneViewsVisible(false, false, false)
	local bgSprite = CCSprite:create("images/guild_war/worship/worship_bg.jpg")
	bgSprite:setAnchorPoint(ccp(0.5, 0.5))
	bgSprite:setPosition(ccps(0.5, 0.5))
	bgSprite:setScale(g_fBgScaleRatio)
	_bgLayer:addChild(bgSprite)

	_layerSize.height = g_winSize.height - MainScene.getBulletFactSize().height


	createTopUi()
	createCenterUi()
	GuildWarWorshipService.getTempleInfo(crateRole)

	return _bgLayer
end

--[[
	@des : 顶部ui
--]]
function createTopUi( ... )

	-- 上标题栏 显示战斗力，银币，金币
	-- local userInfo = UserModel.getUserInfo()
	-- local topBg = CCSprite:create("images/hero/avatar_attr_bg.png")
 --    topBg:setAnchorPoint(ccp(0,1))
 --    topBg:setPosition(0,_layerSize.height)
 --    topBg:setScale(g_fScaleX)
 --    _bgLayer:addChild(topBg)
 --    titleSize = topBg:getContentSize()
 --    _layerSize.height =_layerSize.height - topBg:getContentSize().height*g_fScaleX - 25 * MainScene.elementScale

 --    local powerDescLabel = CCSprite:create("images/common/fight_value.png")
 --    powerDescLabel:setAnchorPoint(ccp(0.5,0.5))
 --    powerDescLabel:setPosition(topBg:getContentSize().width*0.13,topBg:getContentSize().height*0.43)
 --    topBg:addChild(powerDescLabel)
    
 --    m_powerLabel = CCRenderLabel:create( tonumber(UserModel.getFightForceValue()), g_sFontName, 23, 1.5, ccc3( 0x00, 0x00, 0x00), type_stroke)
 --    m_powerLabel:setColor(ccc3(0xff, 0xf6, 0x00))
 --    m_powerLabel:setPosition(topBg:getContentSize().width*0.23,topBg:getContentSize().height*0.66)
 --    topBg:addChild(m_powerLabel)
    
 --    m_silverLabel = CCLabelTTF:create( tonumber(userInfo.silver_num),g_sFontName,18)
 --    m_silverLabel:setColor(ccc3(0xe5,0xf9,0xff))
 --    m_silverLabel:setAnchorPoint(ccp(0,0.5))
 --    m_silverLabel:setPosition(topBg:getContentSize().width*0.61,topBg:getContentSize().height*0.43)
 --    topBg:addChild(m_silverLabel)
    
 --    m_goldLabel = CCLabelTTF:create( tonumber(userInfo.gold_num),g_sFontName,18)
 --    m_goldLabel:setColor(ccc3(0xff,0xe2,0x44))
 --    m_goldLabel:setAnchorPoint(ccp(0,0.5))
 --    m_goldLabel:setPosition(topBg:getContentSize().width*0.82,topBg:getContentSize().height*0.43)
 --    topBg:addChild(m_goldLabel)

	--标题
	require "script/ui/guildWar/GuildWarUtil"
	local titleSprite = GuildWarUtil.getGuildWarNameSprite()
	titleSprite:setAnchorPoint(ccp(0.5, 1))
	titleSprite:setPosition(ccp(g_winSize.width * 0.5, _layerSize.height*0.95))
	_bgLayer:addChild(titleSprite)
    titleSprite:setScale(g_fScaleX)

	local menu = CCMenu:create()
	menu:setPosition(ccp(0,0))
	menu:setAnchorPoint(ccp(0,0))
	menu:setTouchPriority(_touchPriority -10)
	_bgLayer:addChild(menu)

	--关闭按钮
	local closeButton = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
	closeButton:setAnchorPoint(ccp(0.5, 0.5))
	closeButton:registerScriptTapHandler(closeButtonCallFunc)
	closeButton:setPosition(ccp(_layerSize.width * 0.9 ,_layerSize.height * 0.9))
	menu:addChild(closeButton)
	closeButton:setScale(MainScene.elementScale)

end


--[[
	@des : 中部ui
--]]
function createCenterUi( ... )
	
	local menu = CCMenu:create()
	menu:setPosition(ccp(0,0))
	menu:setAnchorPoint(ccp(0,0))
	menu:setTouchPriority(_touchPriority -10)
	_bgLayer:addChild(menu)

	--每日膜拜
	local norSprite = CCScale9Sprite:create("images/common/btn/btn_purple2_n.png")
	norSprite:setContentSize(CCSizeMake(193, 73))
	local norTitle  =  CCRenderLabel:create(GetLocalizeStringBy("llp_84"), g_sFontPangWa, 35, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
	norTitle:setColor(ccc3(0xfe, 0xdb, 0x1c))
	norTitle:setPosition(ccpsprite(0.5, 0.5, norSprite))
	norTitle:setAnchorPoint(ccp(0.5, 0.5))
	norSprite:addChild(norTitle)
	
	local higSprite = CCScale9Sprite:create("images/common/btn/btn_purple2_h.png")
	higSprite:setContentSize(CCSizeMake(193, 73))
	local higTitle  =  CCRenderLabel:create(GetLocalizeStringBy("llp_84"), g_sFontPangWa, 35, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
	higTitle:setColor(ccc3(0xfe, 0xdb, 0x1c))
	higTitle:setPosition(ccpsprite(0.5, 0.5, higSprite))
	higTitle:setAnchorPoint(ccp(0.5, 0.5))
	higSprite:addChild(higTitle)
	
	local graySprite = CCScale9Sprite:create("images/common/btn/btn1_g.png")
	graySprite:setContentSize(CCSizeMake(193, 73))
	local grayTitle  =  CCRenderLabel:create(GetLocalizeStringBy("llp_84"), g_sFontPangWa, 35, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
	grayTitle:setColor(ccc3(0xfe, 0xdb, 0x1c))
	grayTitle:setPosition(ccpsprite(0.5, 0.5, graySprite))
	grayTitle:setAnchorPoint(ccp(0.5, 0.5))
	graySprite:addChild(grayTitle)
	
	local worshipButton = CCMenuItemSprite:create(norSprite, higSprite, graySprite)
	worshipButton:setAnchorPoint(ccp(0.5, 0.5))
	worshipButton:registerScriptTapHandler(worshipButtonCallback)
	worshipButton:setPosition(ccps(0.5 ,0.12))
	menu:addChild(worshipButton)
	worshipButton:setScale(MainScene.elementScale)
	
end


--[[
	@des : 创建 初出茅庐冠军，傲视群雄冠军，傲视群雄亚军 角色
--]]
function crateRole( ... )

	local templeInfo = GuildWarWorshipData.getTempleInfo()
	local effectPath = {
		"images/base/effect/guanjunbiaoti/guanjunbiaoti",
		-- "images/base/effect/yinpai/yinpai",
		-- "images/base/effect/jinpai/jinpai",
		-- "images/base/effect/tongpai/tongpai",
	}
    -- 定义的数据结构
	-- tempInfo.guild_id              = "001"						--	军团Id
	-- tempInfo.guild_name            = "13222"					--	军团名称
	-- tempInfo.guild_server_id             = "game001"					--	服务器Id
	-- tempInfo.guild_server_name           = "剑问鱼肠"					--	服务器名称
	-- tempInfo.president_uname       = "冠军军团长"					--	军团长名称
	-- tempInfo.president_htid        = 20109						--	军团长主角形象
	-- tempInfo.president_level       = "99"						-- 	军团长等级
	-- tempInfo.president_vip_level   = "13"						--	军团长vip等级
	-- tempInfo.president_fight_force = "999999" 					--	军团长战斗力
	-- tempInfo.dress 				   = {"1" = 80001}				--	时装信息
--后端返回值
-- 	Cocos2d: [LUA-print] Table
-- (
-- Cocos2d: [LUA-print]     [president_vip_level] => 0
-- Cocos2d: [LUA-print]     [guild_name] => x33192
-- Cocos2d: [LUA-print]     [session] => 1
-- Cocos2d: [LUA-print]     [president_htid] => 20002
-- Cocos2d: [LUA-print]     [president_dress] => Table
--         (
-- Cocos2d: [LUA-print]         )
-- Cocos2d: [LUA-print]     [president_uname] => mbg_33192
-- Cocos2d: [LUA-print]     [guild_server_name] => 越狱混服_3001区
-- Cocos2d: [LUA-print]     [guild_server_id] => 3001
-- Cocos2d: [LUA-print]     [president_level] => 50
-- Cocos2d: [LUA-print]     [guild_id] => 10345
-- Cocos2d: [LUA-print]     [president_fight_force] => 1648
-- Cocos2d: [LUA-print] )

	if(templeInfo.president_htid ~= nil) then
		--底座阴影
		local taiZi = CCSprite:create("images/guild_war/worship/juntuanmobai.png")
		taiZi:setOpacity(170)
		taiZi:setPosition(kStationPos[2])
		taiZi:setAnchorPoint(ccp(0.5 ,0.5))
		_moveLayer:addChild(taiZi)
		taiZi:setScale(MainScene.elementScale * kStationScale[2])
		_moveLayer:reorderChild(taiZi,kStationZorder[2])
		_championArray = taiZi

		--人物形象
		local kingSprite = HeroUtil.getHeroBodySpriteByHTID(templeInfo.president_htid, templeInfo.president_dress["1"], HeroModel.getSex(templeInfo.president_htid))
		kingSprite:setPosition(ccp(taiZi:getContentSize().width *0.5, taiZi:getContentSize().height * 0.5))
		kingSprite:setAnchorPoint(ccp(0.5, 0))
		taiZi:addChild(kingSprite)
		kingSprite:setScale(0.7)

		--标题特效
		local animSprite = CCLayerSprite:layerSpriteWithName(CCString:create(effectPath[1]), -1,CCString:create(""))
		animSprite:setScale(g_fScaleX)
	    animSprite:setAnchorPoint(ccp(0.5, 0))
	    animSprite:setPosition(ccps(0.5,0.79))
	    _moveLayer:addChild(animSprite)
	    
        ---军团及服务器名字背景
	    local guildNameBg = CCScale9Sprite:create("images/common/bg/astro_btnbg.png")
	    guildNameBg:setScale(g_fScaleX)
	    guildNameBg:setContentSize(CCSizeMake(315,130))
	    guildNameBg:setAnchorPoint(ccp(0.5,1))
	    _moveLayer:addChild(guildNameBg)
	    guildNameBg:setPosition(ccps(0.5,0.77))

	    --军团名
	    local guildName = CCRenderLabel:create(templeInfo.guild_name,g_sFontPangWa,23,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    guildName:setColor(ccc3(0xff,0xf6,0x00))
	    guildName:setAnchorPoint(ccp(0.5,0))
	    guildNameBg:addChild(guildName)
	    guildName:setPosition(ccpsprite(0.7,0.55,guildNameBg))

	    --军旗
	    require "script/ui/guild/GuildUtil"
	    local guildFlag = GuildUtil.getGuildIcon(templeInfo.guild_badge)
	    guildFlag:setAnchorPoint(ccp(0,0.5))
	    guildNameBg:addChild(guildFlag)
	    guildFlag:setPosition(ccpsprite(0.05,0.5,guildNameBg))

	    --服务器名
	    local serverName = CCRenderLabel:create(templeInfo.guild_server_name,g_sFontName,23,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    serverName:setColor(ccc3(0xff,0xff,0xff))
	    serverName:setAnchorPoint(ccp(0.5,1))
	    guildNameBg:addChild(serverName)
	    serverName:setPosition(ccpsprite(0.7,0.5,guildNameBg))
        --“军团长”这三个字背景
        local presidentLabelBg = CCScale9Sprite:create("images/common/bg/bg_9s_2.png")
        presidentLabelBg:setScale(g_fScaleX)
        kingSprite:addChild(presidentLabelBg)
        presidentLabelBg:setOpacity(170)
        presidentLabelBg:setAnchorPoint(ccp(0.5, 0))
        presidentLabelBg:setPosition(ccpsprite(0.5, 1.05,kingSprite))
        presidentLabelBg:setContentSize(CCSizeMake(250, 40))

        --“军团长”三个字
        local presidentLabel = CCRenderLabel:create(  GetLocalizeStringBy("key_3219"), g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)       
        presidentLabel:setColor(ccc3(0xff,0xf6,0x00))
        presidentLabel:setAnchorPoint(ccp(0.5,0.5))
        presidentLabelBg:addChild(presidentLabel)
        presidentLabel:setPosition(ccpsprite(0.5,0.5,presidentLabelBg))


        --军团长名字背景
        local nameBg = CCScale9Sprite:create("images/common/bg/bg_9s_2.png")
        taiZi:addChild(nameBg)
        nameBg:setOpacity(170)
        nameBg:setAnchorPoint(ccp(0.5, 0.5))
        nameBg:setPosition(ccpsprite(0.5, -0.1, taiZi))
        nameBg:setContentSize(CCSizeMake(230, 32))
        --军团长名字
		local nameLabel = CCRenderLabel:create( templeInfo.president_uname , g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)       
        nameLabel:setColor(ccc3(0x00,0xe4,0xff))
        nameLabel:setAnchorPoint(ccp(0.5,0.5))
        nameBg:addChild(nameLabel)
        nameLabel:setPosition(ccpsprite(0.5,0.5,nameBg))
	end
end

-----------------------------------[[ 更新ui方法 ]]--------------------------------------


function updateTopUi( ... )
	local userInfo = UserModel.getUserInfo()
	m_silverLabel:setString(tonumber(userInfo.silver_num))
	m_goldLabel:setString(tonumber(userInfo.gold_num))
end



-----------------------------------[[ 回调事件 ]]-----------------------------------------

--[[
	@des : 关闭按钮回调事件
--]]
function closeButtonCallFunc( ... )
	MainScene.setMainSceneViewsVisible(false,false,_bulletinVisible)
	require "script/ui/guildWar/GuildWarMainLayer"
	local layer = GuildWarMainLayer.createLayer()
	MainScene.changeLayer(layer, "GuildWarMainLayer")
end


--[[
	@des : 膜拜按钮回调事件
--]]
function worshipButtonCallback( ... )
	require "script/ui/guildWar/worship/GuildWarWorshipDialog"
	--print("传递的touch",_touchPriority-50)
	GuildWarWorshipDialog.show(_touchPriority-50,_zOrder +10)
end



