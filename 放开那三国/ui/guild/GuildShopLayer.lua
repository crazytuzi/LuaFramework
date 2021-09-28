-- Filename：	GuildShopLayer.lua
-- Author：		zhz
-- Date：		2014-01-13
-- Purpose：		军团商店

module("GuildShopLayer",  package.seeall)

require "script/ui/main/MainScene"
require "script/audio/AudioUtil"
require "script/ui/guild/GuildDataCache"
require "script/utils/TimeUtil"
require "script/ui/guild/GuildUtil"
require "script/ui/guild/GuildShopCell"
require "script/ui/main/BulletinLayer"


local _bgLayer
local _bottomSprite
local _curDonateSp				-- 当前贡献的sp
local _curDonateLabel			-- 当前贡献的label
local _myTableViewSp			-- 列表的
local _myTableView
local _goodsInfo
local _girlSp
		

local _ksNormalTag = 1001		-- 道具的tag
local _ksValueTag = 1002		-- 珍品的tag
local _ksBackTag = 1003			-- 返回按钮的tag

local _index=1 					-- 当前在那个页面 
local _curItem= nil
local _updateTimer= nil			-- 定时器

-- 初始化
local function init( )
	_bgLayer= nil
	_bottomSprite= nil
	_curDonateSp= nil
	_curDonateLabel= nil
	_girlSp= nil
	_myTableViewSp=nil
	_myTableView= nil
	_goodsInfo= {}

	_updateTimer= nil
	_index= 1
	_curItem= nil
end

-- 上标题栏 显示战斗力，银币，金币
function createTopUI( ... )
	
	require "script/model/user/UserModel"
	
	_topBg = CCSprite:create("images/hero/avatar_attr_bg.png")
    _topBg:setAnchorPoint(ccp(0,1))
    _topBg:setPosition(0,_bgLayer:getContentSize().height)
    _topBg:setScale(g_fScaleX)
    _bgLayer:addChild(_topBg, 10)
    titleSize = _topBg:getContentSize()

    local powerDescLabel = CCSprite:create("images/common/fight_value.png")
    powerDescLabel:setAnchorPoint(ccp(0.5,0.5))
    powerDescLabel:setPosition(_topBg:getContentSize().width*0.13,_topBg:getContentSize().height*0.43)
    _topBg:addChild(powerDescLabel)
    
   	_powerLabel = CCRenderLabel:create( UserModel.getFightForceValue(), g_sFontName, 23, 1.5, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _powerLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    _powerLabel:setPosition(_topBg:getContentSize().width*0.23,_topBg:getContentSize().height*0.66)
    _topBg:addChild(_powerLabel)
    
    _silverLabel = CCLabelTTF:create( UserModel.getSilverNumber() ,g_sFontName,18)
    _silverLabel:setColor(ccc3(0xe5,0xf9,0xff))
    _silverLabel:setAnchorPoint(ccp(0,0.5))
    _silverLabel:setPosition(_topBg:getContentSize().width*0.61,_topBg:getContentSize().height*0.43)
    _topBg:addChild(_silverLabel)
    
    _goldLabel = CCLabelTTF:create(UserModel.getGoldNumber()  ,g_sFontName,18)
    _goldLabel:setColor(ccc3(0xff,0xe2,0x44))
    _goldLabel:setAnchorPoint(ccp(0,0.5))
    _goldLabel:setPosition(_topBg:getContentSize().width*0.82,_topBg:getContentSize().height*0.43)
    _topBg:addChild(_goldLabel)
    -- return _topBg
end

--创建夺宝按钮
local function createMenuSp(  )
    _btnFrameSp = CCScale9Sprite:create("images/common/menubg.png")
    _btnFrameSp:setPreferredSize(CCSizeMake(640, 93))
    _btnFrameSp:setAnchorPoint(ccp(0.5, 1))
    _btnFrameSp:setPosition(ccp(_bgLayer:getContentSize().width/2 , _bgLayer:getContentSize().height- _topBg:getContentSize().height * g_fScaleX ))
    _btnFrameSp:setScale(g_fScaleX)
    _bgLayer:addChild(_btnFrameSp, 10)

    local menuBar = CCMenu:create()
    menuBar:setPosition(ccp(0, 0))
    menuBar:setTouchPriority(-210)
    _btnFrameSp:addChild(menuBar, 10)

    -- 道具的按钮
    local normalButton = LuaMenuItem.createMenuItemSprite(GetLocalizeStringBy("key_1870"), 30)
    normalButton:setAnchorPoint(ccp(0, 0))
    normalButton:setPosition(ccp(_btnFrameSp:getContentSize().width*0.3, _btnFrameSp:getContentSize().height*0.1))
    normalButton:registerScriptTapHandler(menuCallBack)
    menuBar:addChild(normalButton,1, _ksNormalTag)
    -- normalButton:selected()

    -- 珍品的按钮
    local specialButton = LuaMenuItem.createMenuItemSprite(GetLocalizeStringBy("key_1544"), 30)
    specialButton:setAnchorPoint(ccp(0, 0))
    specialButton:setPosition(ccp(_btnFrameSp:getContentSize().width*0.05, _btnFrameSp:getContentSize().height*0.1))
    specialButton:registerScriptTapHandler(menuCallBack)
    menuBar:addChild(specialButton,1, _ksValueTag)
    specialButton:selected()
    _curItem= specialButton

    -- 返回按钮的回调函数
    local backBtn = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
    backBtn:setAnchorPoint(ccp(1,0.5))
    backBtn:setPosition(ccp(_btnFrameSp:getContentSize().width-20,_btnFrameSp:getContentSize().height*0.5+6))
    backBtn:registerScriptTapHandler(menuCallBack)
    menuBar:addChild(backBtn,1,_ksBackTag)
end

-- 创建中间的UI,物品列表
function createMiddleUI( )
	createCurDonateUI()
	createGoodTableView()

end

function createCurDonateUI( )

	local height = _laySize.height- _topBg:getContentSize().height*g_fScaleX - _btnFrameSp:getContentSize().height*g_fScaleX -28*g_fElementScaleRatio
	local shopTitleSp = CCSprite:create("images/guild/shop/shop_title.png")
	shopTitleSp:setPosition(12*g_fElementScaleRatio,height )
	shopTitleSp:setScale(g_fElementScaleRatio)
	shopTitleSp:setAnchorPoint(ccp(0,1))
	_bgLayer:addChild(shopTitleSp)

	local shopLevelLabel= CCRenderLabel:create( "Lv." .. tostring(GuildDataCache.getShopLevel() ) , g_sFontPangWa , 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	shopLevelLabel:setColor(ccc3(0xff,0xe4,0x00))

	shopLevelLabel:setPosition(shopTitleSp:getContentSize().width+5, 3)
	shopLevelLabel:setAnchorPoint(ccp(0,0))
	shopTitleSp:addChild(shopLevelLabel)

	-- 总的建设度
		local width
	--兼容东南亚英文版
    if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
    	width = 355/640*_laySize.width 
    else
    	width = 388/640*_laySize.width 
    end
	local height = _laySize.height- _topBg:getContentSize().height*g_fScaleX - _btnFrameSp:getContentSize().height*g_fScaleX- 10*MainScene.elementScale
	local totalDonate = CCRenderLabel:create(GetLocalizeStringBy("key_1185"), g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	totalDonate:setColor(ccc3(0xfe, 0xdb, 0x1c))
	local donateNumber = CCRenderLabel:create(GuildDataCache.getGuildDonate(), g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	donateNumber:setColor(ccc3(0xff,0xff,0xff))

	local label1 = BaseUI.createHorizontalNode({totalDonate, donateNumber})
    label1:setAnchorPoint(ccp(0, 1))
	label1:setPosition(ccp(width,height))
	_bgLayer:addChild(label1)
	label1:setScale(MainScene.elementScale)

	local nextNeed = CCRenderLabel:create(GetLocalizeStringBy("key_3041"), g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	nextNeed:setColor(ccc3(0xfe, 0xdb, 0x1c))
	local nextLv = GuildDataCache.getShopLevel() +1
	local maxLevel= GuildUtil.getMaxShopLevel()
	local needNumber =nil
	if(GuildDataCache.getShopLevel()< tonumber(maxLevel)) then
		needNumber= CCRenderLabel:create(GuildUtil.getShopNeedExpByLv(nextLv) , g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	else
		needNumber= CCRenderLabel:create("--" , g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	end
	needNumber:setColor(ccc3(0xff,0xff,0xff))

	height = height- label1:getContentSize().height-10*MainScene.elementScale
	local label2 = BaseUI.createHorizontalNode({nextNeed, needNumber})
    label2:setAnchorPoint(ccp(0, 1))
	label2:setPosition(ccp(width,height))
	_bgLayer:addChild(label2)
	label2:setScale(MainScene.elementScale)

	--
	--  当前的贡献值
	_curDonateSp =  CCSprite:create("images/guild/shop/cur_donate.png")
	width = 355/648*_laySize.width 
	height= height - label2:getContentSize().height- 10*MainScene.elementScale
	_curDonateSp:setPosition(width, height)
	_curDonateSp:setScale(MainScene.elementScale)
	_curDonateSp:setAnchorPoint(ccp(0,1))
	_bgLayer:addChild(_curDonateSp,11)
	-- 当前
	_curDonateLabel = CCRenderLabel:create(tostring(GuildDataCache.getSigleDoante() ) , g_sFontPangWa , 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_curDonateLabel:setPosition(_curDonateSp:getContentSize().width*0.52, _curDonateSp:getContentSize().height/2)
	_curDonateLabel:setAnchorPoint(ccp(0,0.5))
	_curDonateSp:addChild(_curDonateLabel)

end

function refreshCurDonateLabel( )
	_curDonateLabel:setString(tostring(GuildDataCache.getSigleDoante()))
end

function createGoodTableView( )
	if(_myTableViewSp~= nil) then
		_myTableViewSp:removeFromParentAndCleanup(true)
		_myTableViewSp= nil
	end
	-- _goodsInfo= GuildUtil.getNormalGoods()

	_myTableViewSp= CCScale9Sprite:create("images/guild/shop/shop_bottom.png")
	height = _curDonateSp:getPositionY() - _curDonateSp:getContentSize().height- _bottomSprite:getContentSize().height*g_fScaleX -15*g_fScaleX
	_myTableViewSp:setContentSize(CCSizeMake(_laySize.width, height))
	_myTableViewSp:setPosition(ccp(0,_bottomSprite:getContentSize().height*g_fScaleX ))
	_bgLayer:addChild(_myTableViewSp)

	if(_index==1) then
		_girlSp= CCSprite:create("images/guild/shop/pretty_girl_special.png")
		_goodsInfo= GuildUtil.getSpecialGoods()
	else
		_girlSp= CCSprite:create("images/guild/shop/pretty_girl_nor.png")
		_goodsInfo= GuildUtil.getNormalGoods()
	end
	-- print("SpecialGoods is : ")
	-- print_t(_goodsInfo)
	_girlSp:setPosition(0, _myTableViewSp:getContentSize().height/2)
	_girlSp:setAnchorPoint(ccp(0,0.5))
	_girlSp:setScale(g_fScaleX)
	_myTableViewSp:addChild(_girlSp)

	local cellSize = CCSizeMake(459, 182)			--计算cell大小
	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = CCSizeMake( 459*g_fScaleX, 182*g_fScaleX)
		elseif fn == "cellAtIndex" then
			-- if not a2 then
			a2 = GuildShopCell.createCell(_goodsInfo[a1+1],_index ,refreshMiddleUI)
			a2:setScale(g_fScaleX)
			r = a2
		elseif fn == "numberOfCells" then
			r = #_goodsInfo
		elseif fn == "cellTouched" then
			print("cellTouched", a1:getIdx())

		elseif (fn == "scroll") then
			
		end
		return r
	end)
	_myTableView = LuaTableView:createWithHandler(h, CCSizeMake(460*g_fScaleX, _myTableViewSp:getContentSize().height- 10*g_fScaleX ))
	_myTableView:setBounceable(true)
	_myTableView:setAnchorPoint(ccp(0, 0))
	_myTableView:setPosition(ccp(157*g_fScaleX, 3))
	_myTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	_myTableViewSp:addChild(_myTableView)

	if(_updateTimer~= nil) then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(_updateTimer)
		_updateTimer= nil
	end

	-- 当为珍品时，设置定时器，刷新
	if(_index==1) then
		_leftTimeLabel= CCLabelTTF:create(TimeUtil.getTimeString(GuildDataCache.getShopRefreshCd()) , g_sFontName,23)
		_leftTimeLabel:setPosition(ccp(32/640*_myTableViewSp:getContentSize().width,10*g_fScaleX))
		_leftTimeLabel:setColor(ccc3(0x00,0xff,0x18))
		_leftTimeLabel:setScale(g_fScaleX)
		_myTableViewSp:addChild(_leftTimeLabel)	
		local sheildLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2272"),g_sFontName,23)
		sheildLabel:setColor(ccc3(0x00,0xff,0x18))
		sheildLabel:setPosition(ccp(16*g_fScaleX,35*g_fScaleX))
		sheildLabel:setScale(g_fScaleX)
		_myTableViewSp:addChild(sheildLabel)
		 _updateTimer = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updateShieldTime, 1, false)	
	end

end

-- 刷新TableView
function refreshTableView( )
	if(_index==1) then
		_goodsInfo= GuildUtil.getSpecialGoods()
	else
		_goodsInfo= GuildUtil.getNormalGoods()
	end
	local contentOffset = _myTableView:getContentOffset()
	_myTableView:reloadData() 
	_myTableView:setContentOffset(contentOffset)
end

function refreshTableView_02( ... )
	if(_index==1) then
		_goodsInfo= GuildUtil.getSpecialGoods()
	else
		_goodsInfo= GuildUtil.getNormalGoods()
	end
	_myTableView:reloadData() 
end

-- 刷新中部的UI
function refreshMiddleUI( )
	refreshTableView()
	refreshCurDonateLabel()
end

-- 创建底部的UI
local function createBottomSprite( )
	require "script/ui/guild/GuildBottomSprite"
	_bottomSprite= GuildBottomSprite.createBottomSprite()
	_bottomSprite:setScale(g_fScaleX)
	_bottomSprite:setAnchorPoint(ccp(0.5,0))
	_bottomSprite:setPosition(ccp(g_winSize.width/2,0))
	_bgLayer:addChild(_bottomSprite)

end

function updateShieldTime( )
	 local shieldTime = "" .. TimeUtil.getTimeString(GuildDataCache.getShopRefreshCd())
	_leftTimeLabel:setString(shieldTime)

	if(GuildDataCache.getShopRefreshCd()<= 0) then
		Network.rpc(refreshListCallBack, "guildshop.refreshList", "guildshop.refreshList", nil, true)
	end	
end

--@desc	 回调onEnter和onExit时间
local function onNodeEvent( event )
	if (event == "enter") then
		GuildDataCache.setIsInGuildFunc(true)

	elseif (event == "exit") then
		GuildDataCache.setIsInGuildFunc(false)
		--取消定时器
		if(_updateTimer~= nil) then
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(_updateTimer)
		end
	end
end



-- 
function createLayer( )
	init()
	MainScene.setMainSceneViewsVisible(false, false, true)
	
	local bulletinLayerSize = BulletinLayer.getLayerContentSize()
	_bgLayer= CCLayer:create()
	_laySize= {width=0,height=0}
	_laySize.width= g_winSize.width
	_laySize.height= g_winSize.height - (bulletinLayerSize.height)*g_fScaleX
	_bgLayer:setContentSize(CCSizeMake(_laySize.width, _laySize.height))

	_bgLayer:registerScriptHandler(onNodeEvent)
	local bg = CCSprite:create("images/main/module_bg.png")
	bg:setScale(g_fBgScaleRatio)
	_bgLayer:addChild(bg)

	createTopUI( )
	createBottomSprite()
	createMenuSp( )

	-- createMiddleUI()

	-- 获得军团商店信息
	Network.rpc(getShopInfoCb, "guildshop.getShopInfo", "guildshop.getShopInfo", nil, true)

	return _bgLayer

end




---------------------------------------------- 网络及回调函数 -----------------------------------------------

-- 按钮事件的回调函数
function menuCallBack( tag,item)
	-- 
	_curItem:unselected()
	item:selected()
	_curItem= item 
	if(tag== _ksNormalTag ) then
		AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
		print(GetLocalizeStringBy("key_1352"))
		_index=2
		createGoodTableView()

	elseif(tag== _ksValueTag) then
		AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
		print(GetLocalizeStringBy("key_1455"))
		_index=1
		createGoodTableView()

	elseif(tag == _ksBackTag) then
		print("back ")
		AudioUtil.playEffect("audio/effect/guanbi.mp3")
		require "script/ui/guild/GuildMainLayer"
		local guildMainLayer = GuildMainLayer.createLayer(false)
		MainScene.changeLayer(guildMainLayer, "guildMainLayer")
	end
end

-- 获得军团商店信息的网络回调
function getShopInfoCb( cbFlag, dictData, bRet )
	if (dictData.err ~= "ok") then
		return
	end

	-- print("dictData.ret is : normalGood is : ")
	-- print_t(dictData.ret.normal_goods)
	GuildDataCache.setShopInfo(dictData.ret)
	createMiddleUI()
end

-- 刷新的回调函数
function refreshListCallBack( cbFlag, dictData, bRet )
	if (dictData.err ~= "ok") then
		return
	end
	GuildDataCache.setSpecialGoodsInfo(dictData.ret.special_goods,dictData.ret.refresh_cd)

	refreshTableView_02()
end










