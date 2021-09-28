-- Filename: MainScene.lua.
-- Author: fang.
-- Date: 2013-05-17
-- Purpose: 该文件用于实现主城场景功能



require "script/ui/main/MenuLayer"
require "script/utils/extern"
require "script/animation/XMLSprite"
require "script/cocostudio/ccs"
require "script/model/user/UserModel"
-- 主城场景模块声明
module("MainScene", package.seeall)

bgScale = 1.0;
elementScale = 1.0;
layerBeginHeight = 0;

schedule_updata = nil       -- 定时器

local IMG_PATH = "images/main/"				-- 主城场景图片主路径
local IMG_PATH_MENU = IMG_PATH .. "menu/"	-- 主城场景菜单图片路径

local bgLayer			    -- 背景层
local _bulletinBg			-- 主城界面顶部文字滚动区域
local _avatarAttrBg			-- 主城界面顶部玩家信息区域
local menuLayer			    -- Dock层
local onRunningLayer	    -- 当前显示层
local onRunningLayerSign	-- 当前显示层标示
local onRunningLayerCallbackFunc	-- 当前显示层回调
-- 玩家信息区视图
-- 级别
local _level 
-- 头像
local _avatar_icon
-- 昵称
local _nickname 
-- VIP对应级别Sprite
local _vip_lv_num
-- 银两实际数据
local _silver_num 
-- 金币实际数据
local _gold_num 
-- 经验值信息
local _ccLabelExp
-- 经验值进度条
local _ccExpProgress
-- 经验值进度条初始宽度
local _nExpProgressOriWidth
-- 体力值信息
local _energy 
-- 体力值进度条
local _ccEnergyProgress
-- 体力值进度条初始宽度
local _nEnergyProgressOriWidth
-- 耐力值进度条
local _ccStaminaProgress
-- 耐力值信息
local _clStaminaValue

-- 战斗力
local _fight_value 

local visibleSize = g_winSize
local origin = g_origin

local _netFlagGetAllHeroes
-- 玩家头像
local _ccHeadIcon

-- 体力初始值上限
local _nOriEnergyLimit = 150

-- 注册耐力变化通知函数
local fnStaminaNumberChange = nil

-- 注册时装强化界面删除方法
local fnFashionEnhanceRemove = nil

-- web端的网页活动是否开启
local _webActivityUrl = nil

-- 获得web端网页活动的Url地址
local function getWebActivity()
    if(Platform.getActiveInfo ~= nil)then
        Platform.getActiveInfo(function( url )
            _webActivityUrl = url
        end)
    end
end

function getWebActivityUrl()
    return _webActivityUrl
end

-- 创建主城界面顶部
local createTopLayer = function ()
	-- 角色属性背景
    _avatarAttrBg = CCSprite:create (IMG_PATH.."avatar_attr_bg.png")
	-- 角色属性背景
	_avatarAttrBg:setAnchorPoint(ccp(0, 1))
    _avatarAttrBg:setPosition(0,g_winSize.height - _bulletinBg:getContentSize().height * g_fScaleX)
    _avatarAttrBg:setScale(g_fScaleX)
--	layer:addChild(_avatarAttrBg)
	-- 级别
    _level = CCLabelTTF:create ("1", g_sFontName, 18)
	_level:setPosition(60, 21)
	_level:setColor(ccc3(0xff, 0xea, 0x78))
	_avatarAttrBg:addChild(_level)
	-- 昵称
    _nickname = CCLabelTTF:create ("2", g_sFontName, 22)
	_nickname:setPosition(105, 108)
	_nickname:setColor(ccc3(0x6c, 0xff, 0x00))
	_avatarAttrBg:addChild(_nickname)
    if Platform.isAdShow == false  then
        -- VIP图标
        local vip_lv 
        vip_lv = CCSprite:create (IMG_PATH .. "vip/vip.png")
        vip_lv:setPosition(250, 110)
        _avatarAttrBg:addChild(vip_lv)
        -- VIP对应级别
        require "script/libs/LuaCC"
        _vip_lv_num = LuaCC.createSpriteOfNumbers("images/main/vip", "1", 15)
        if (_vip_lv_num ~= nil) then
            _vip_lv_num:setPosition(250+vip_lv:getContentSize().width, 120)
            _avatarAttrBg:addChild(_vip_lv_num)
        end
    end
	-- 银两实际数据
    _silver_num = CCLabelTTF:create("0", g_sFontName, 18)
	_silver_num:setColor(ccc3(0xe5, 0xf9, 0xff))
	_silver_num:setPosition(396, 110)
	_avatarAttrBg:addChild(_silver_num)
	-- 银两实际数据
    _gold_num = CCLabelTTF:create("0", g_sFontName, 18)
	_gold_num:setColor(ccc3(0xff, 0xe2, 0x44))
	_gold_num:setPosition(540, 110)
	_avatarAttrBg:addChild(_gold_num)
    -- 阅历进度条
    _ccExpProgress = CCSprite:create(IMG_PATH .. "progress_blue.png")
    local size = _ccExpProgress:getContentSize()
    _nExpProgressOriWidth = size.width
    _ccExpProgress:setPosition(162, 81)
    _ccExpProgress:setTextureRect(CCRectMake(0, 0, size.width, size.height))
    _avatarAttrBg:addChild(_ccExpProgress)
	-- 阅历值信息
    _ccLabelExp = CCLabelTTF:create ("1/1", g_sFontName, 16)
    _ccLabelExp:setPosition(size.width/2, size.height/2-2)
    _ccLabelExp:setColor(ccc3(0, 0, 0))
    _ccLabelExp:setAnchorPoint(ccp(0.5, 0.5))
    _ccExpProgress:addChild(_ccLabelExp)

    -- 体力进度条
    _ccEnergyProgress = CCSprite:create(IMG_PATH .. "progress_yellow.png")
    _nEnergyProgressOriWidth = size.width
    _ccEnergyProgress:setPosition(162, 54)
    _ccEnergyProgress:setTextureRect(CCRectMake(0, 0, size.width, size.height))
    _avatarAttrBg:addChild(_ccEnergyProgress)
    --体力上限
    _nOriEnergyLimit = UserModel.getMaxExecutionNumber()
    -- 体力值信息
    _energy = CCLabelTTF:create (_nOriEnergyLimit.."/".._nOriEnergyLimit, g_sFontName, 16)
    _energy:setColor(ccc3(0, 0, 0))
    _energy:setPosition(ccp(size.width/2, size.height/2-2))
    _energy:setAnchorPoint(ccp(0.5, 0.5))
    _ccEnergyProgress:addChild(_energy)

    -- 耐力进度条
    _ccStaminaProgress = CCSprite:create(IMG_PATH .. "progress_purple.png")
    _nEnergyProgressOriWidth = size.width
    _ccStaminaProgress:setPosition(162, 27)
    local nStaminaNum = UserModel.getStaminaNumber()
    local nStaminaMaxNum = UserModel.getMaxStaminaNumber()
    -- if nStaminaNum > nStaminaMaxNum then
    --     nStaminaNum = nStaminaMaxNum
    -- end
    local width = math.floor(nStaminaNum/nStaminaMaxNum*_nEnergyProgressOriWidth)
    if(width>_nEnergyProgressOriWidth ) then
        width = _nEnergyProgressOriWidth
    end
    _ccStaminaProgress:setTextureRect(CCRectMake(0, 0, width, size.height))
    _avatarAttrBg:addChild(_ccStaminaProgress)
    -- 耐力值信息
    _clStaminaValue = CCLabelTTF:create (nStaminaNum.."/"..nStaminaMaxNum, g_sFontName, 16)
    _clStaminaValue:setColor(ccc3(0, 0, 0))
    _clStaminaValue:setPosition(ccp(size.width/2, size.height/2-2))
    _clStaminaValue:setAnchorPoint(ccp(0.5, 0.5))
    _ccStaminaProgress:addChild(_clStaminaValue)

	-- 战斗力
    _fight_value = CCLabelAtlas:create("00", IMG_PATH.."numbers.png", 22, 32, 48)
    _fight_value:setPosition(426, 44)
    _fight_value:setAnchorPoint(ccp(0,0))
    _avatarAttrBg:addChild(_fight_value,999)

    -- 点击整个角色面板时回调处理
    local function fnHandlerOfAvatarPanel(tag, obj)
        --点击音效
        require "script/audio/AudioUtil"
        AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
        require "script/ui/main/AvatarInfoLayer"
        if AvatarInfoLayer.getObject() == nil then
            local scene = CCDirector:sharedDirector():getRunningScene()
            local ccLayerAvatarInfo = AvatarInfoLayer.createLayer()
            scene:addChild(ccLayerAvatarInfo,999,3122)
        end
    end

    local menu = CCMenu:create()
    local ccNgSprite = CCScale9Sprite:create("images/common/transparent.png", CCRectMake(0, 0, 3, 3), CCRectMake(1, 1, 1, 1))
    ccNgSprite:setPreferredSize(CCSizeMake(649, 148))
    local ccMenuItem = CCMenuItemSprite:create(ccNgSprite, ccNgSprite)
    ccMenuItem:registerScriptTapHandler(fnHandlerOfAvatarPanel)
    ccMenuItem:setPosition(0, 0)
    menu:setPosition(0, 0)
    menu:addChild(ccMenuItem)

    _avatarAttrBg:addChild(menu)

	return _avatarAttrBg
end

-- 更新体力值方法
function updateEnergyValueUI()
    if not _energy then
        return
    end
    -- 体力值信息显示
    require "script/model/user/UserModel"
    local userInfo = UserModel.getUserInfo()
    local energyValue = tonumber(userInfo.execution)
    _nOriEnergyLimit = UserModel.getMaxExecutionNumber()
    _energy:setString(energyValue.."/".._nOriEnergyLimit)
    local width = _nEnergyProgressOriWidth
    if energyValue < _nOriEnergyLimit then
        width = math.floor(energyValue*_nEnergyProgressOriWidth/_nOriEnergyLimit)
    end
    _ccEnergyProgress:setTextureRect(CCRectMake(0, 0, width, _ccEnergyProgress:getContentSize().height))
end

function updateStaminaValueUI( ... )
   if _ccStaminaProgress == nil then
        return
    end
    local nStaminaNum = UserModel.getStaminaNumber()
    local nStaminaMaxNum = UserModel.getMaxStaminaNumber()
    -- if nStaminaNum > nStaminaMaxNum then
    --     nStaminaNum = nStaminaMaxNum
    -- end
    local width = math.floor(nStaminaNum/nStaminaMaxNum * _nEnergyProgressOriWidth)
    if(width > _nEnergyProgressOriWidth) then
        width = _nEnergyProgressOriWidth
    end
    _ccStaminaProgress:setTextureRect(CCRectMake(0, 0, width, _ccStaminaProgress:getContentSize().height))
    _clStaminaValue:setString(nStaminaNum.."/"..nStaminaMaxNum)
end

-- 更新经验值显示方法及进度条
function updateExpValueUI()
    -- 更新显示数据
    require "script/model/user/UserModel"
    local userInfo = UserModel.getUserInfo()
    require "db/DB_Level_up_exp"
    local tUpExp = DB_Level_up_exp.getDataById(2)
    local nLevelUpExp = tUpExp["lv_"..(tonumber(userInfo.level)+1)]
    if not _ccLabelExp then
        return
    end
    _ccLabelExp:setString(math.floor(userInfo.exp_num).."/"..nLevelUpExp)
    -- 更新进度条
    local width = _nExpProgressOriWidth
    local nExpNum = tonumber(userInfo.exp_num)
    if nExpNum < nLevelUpExp then
        width = math.floor(nExpNum*_nExpProgressOriWidth/nLevelUpExp)
    end
    _ccExpProgress:setTextureRect(CCRectMake(0, 0, width, _ccExpProgress:getContentSize().height))
end

-- 主场景更新方法
function updateAvatarInfo()
    if not _level then
        return
    end
    require "script/model/user/UserModel"
    local userInfo = UserModel.getUserInfo()
    if userInfo == nil then
        return
    end
    -- 级别
    _level:setString(userInfo.level)
    require "script/model/hero/HeroModel"
    HeroModel.setMainHeroLevel(userInfo.level)
    -- 头像
    --avatar
    -- 昵称
    _nickname:setString(userInfo.uname)
    -- VIP对应级别
    --vip_lv:setString("" .. userInfo.vip)
    -- 银两实际数据
    _silver_num:setString(string.convertSilverUtilByInternational(userInfo.silver_num))  -- modified by yangrui at 2015-12-03
    -- 金币实际数据
    _gold_num:setString( "" .. tonumber(userInfo.gold_num))
    -- 经验值信息
    updateExpValueUI(userInfo.exp_num)

    if Platform.isAdShow == false  then
        -- 真实的VIP值显示
        local x, y = _vip_lv_num:getPosition()
        require "script/libs/LuaCC"
        if (_vip_lv_num ~= nil) then
            _vip_lv_num:removeFromParentAndCleanup(true)
        end
        _vip_lv_num = LuaCC.createSpriteOfNumbers("images/main/vip", userInfo.vip, 15)
        if (_vip_lv_num ~= nil) then
            _vip_lv_num:setPosition(x, y)
            _avatarAttrBg:addChild(_vip_lv_num)
        end
    end
    -- 更新体力值显示及进度条
    updateEnergyValueUI(userInfo.execution)
end

-- 算战斗力
function initFightValue( ... )
    require "script/model/hero/FightForceModel"
    local fight_value = FightForceModel.getFightForce()
    UserModel.setFightForceValue(math.floor(fight_value))
    print("initFightValue==>",fight_value)
    return fight_value
end

-- 更新战斗力方法
function fnUpdateFightValue( ... )
    if not _avatarAttrBg then
        return
    end
    -- require "script/model/hero/FightForceModel"
    -- local fight_value = FightForceModel.getFightForce()
    -- UserModel.setFightForceValue(math.floor(fight_value))
    
    local fight_value = UserModel.getFightForceValue() 
    _fight_value:setString(math.floor(fight_value))
    print("fnUpdateFightValue==>",fight_value)
    return fight_value
end

--更新战斗力ui显示。不重新计算
function updateUIFightForce()
    if not tolua.isnull(_fight_value) then
        local fightForceNum = UserModel.getFightForceValue()
        _fight_value:setString(math.floor(fightForceNum))
         print("updateUIFightForce")
    end
end


function addAvatarIcon( ... )
    if not _ccHeadIcon then
        require "db/DB_Heroes"
        require "script/model/utils/HeroUtil"
        local iconPath = HeroUtil.getHeroIconImgByHTID(UserModel.getAvatarHtid(), UserModel.getDressIdByPos(1))
        _ccHeadIcon = CCSprite:create(iconPath)

        -- added by zhz, vip 特效
        require "db/DB_Normal_config"
        local effectNeedVipLevel = DB_Normal_config.getDataById(1).vipEffect
        if( tonumber(UserModel.getVipLevel() ) >= tonumber(effectNeedVipLevel)) then
            local img_path=  CCString:create("images/base/effect/txlz/txlz")
            local openEffect=  CCLayerSprite:layerSpriteWithNameAndCount(img_path:getCString(), -1,CCString:create(""))
            openEffect:setPosition(_ccHeadIcon:getContentSize().width/2,_ccHeadIcon:getContentSize().width*0.5)
            openEffect:setAnchorPoint(ccp(0.5,0.5))
            _ccHeadIcon:addChild(openEffect,1)
        end

        _ccHeadIcon:setPosition(12, 55)
        _avatarAttrBg:addChild(_ccHeadIcon)
        print("create avatar iconing")
    end
end
function resetAvatarIcon( ... )
    print("refresh avatar iconing")
    if _ccHeadIcon ~= nil then
        _ccHeadIcon:removeFromParentAndCleanup(true)
        _ccHeadIcon=nil
    end
    addAvatarIcon()
end

-- 进入主场景, 初始化相关资源
function enter (...)
    --初始化体力上限，因为一开始体力上限为常量150，所以不得已在这里初始化
    --得到体力上限
    _nOriEnergyLimit = UserModel.getMaxExecutionNumber()

    --支付相关，勿动！！！！！！
    loadOther() 

    -- 检查是否有web端运营活动
    getWebActivity()

    -- 需要在游戏里只调用一次的函数集合
    callOnceInGame()

    -- 开启00:00：00 刷新的定时程序
    require "script/utils/TimerRequestCenter"
    TimerRequestCenter.startZeroRequest()

    -- if(BTUtil:getPlatform() == kBT_PLATFORM_IOS ) then
        -- 长时间未登录 本地通知 add by chengliang
        require "script/utils/NotificationUtil"
        NotificationUtil.addLongTimeNoSeeNotification()
        if(DataCache.getSwitchNodeState(ksOlympic, false)) then
            --添加擂台赛通知
            NotificationUtil.addOlympicRegisterNotification() --擂台赛 报名
            NotificationUtil.addOlympicFourNotification()     --擂台赛 4强    
            NotificationUtil.addOlympicChampionNotification() --擂台赛 冠军
        end
    -- end

    print("mainScene oN enter")
    -- 计算基础适配元素
    local standSize = CCSizeMake(640, 960)

    local winSize = CCDirector:sharedDirector():getWinSize()
    
    bgScale = 1.0;
    elementScale = 1.0;
    -- 计算界面元素及背景伸缩比率因子
    if(winSize.height/winSize.width>standSize.height/standSize.width) then
        bgScale = winSize.height/standSize.height;
        elementScale = winSize.width/standSize.width;
        -- 伸缩比率因子设成全局变量
        g_fElementScaleRatio = elementScale
        g_fBgScaleRatio = bgScale
        
        else
        elementScale = winSize.height/standSize.height;
        bgScale = winSize.width/standSize.width;
        -- 伸缩比率因子设成全局变量
        g_fElementScaleRatio = elementScale
        g_fBgScaleRatio = bgScale
    end
    
    require "script/ui/main/MainUtil"
    --需要根据实际底框计算
    local bottomBg = CCSprite:create(IMG_PATH_MENU .. "menu_bg.png")
    layerBeginHeight = bottomBg:getContentSize().height*elementScale;
    -- 主界面背景，按屏幕尺寸进行伸缩
    local mainBg = CCSprite:create(MainUtil.getMainBgName())
    mainBg:setScaleX(g_fScaleX)
    mainBg:setScaleY(g_fScaleY)
    
	local scene = CCScene:create()

    scene:addChild(mainBg)
    
    --加入鸟动画
    local birdsSprite = CCLayerSprite:layerSpriteWithName(CCString:create(MainUtil.getMainEffectName()), -1,CCString:create(""));
    birdsSprite:setPosition(320,480)
    mainBg:addChild(birdsSprite,0)

    -- 主城png2 主城特效2
    local mainBgFile2 = MainUtil.getMainBgName2()
    if( mainBgFile2 ~= nil)then
        local mainBg2 = CCSprite:create(mainBgFile2)
        mainBg2:setScaleX(g_fScaleX)
        mainBg2:setScaleY(g_fScaleY)
        scene:addChild(mainBg2,0)

        -- 主城特效2
        local mainEffectFile2 = MainUtil.getMainEffectName2()
        if( mainEffectFile2 ~= nil )then
            require "script/animation/XMLSprite"
            local mainEffect2 = XMLSprite:create(mainEffectFile2)
            mainEffect2:setPosition(320,480)
            mainBg2:addChild(mainEffect2,0)
        end
    end
    
    require "script/ui/main/BulletinLayer"
    scene:addChild(BulletinLayer.create(), 999, 999)
    _bulletinBg = BulletinLayer.getBg()

	local avatarLayer = createTopLayer()
	scene:addChild(avatarLayer, 999)

	MenuLayer.setVisible(true)
    menuLayer = MenuLayer.getObject()
    menuLayer:setAnchorPoint(ccp(0,0))
    menuLayer:setPosition(0,0)
    menuLayer:setScale(g_winSize.width/_bulletinBg:getContentSize().width)
	scene:addChild(menuLayer, 999, 10001)

    -- 装载主场景中间层模块
    require "script/ui/main/MainBaseLayer"
    --local main_base_layer = MainBaseLayer.create()
    onRunningLayer = MainBaseLayer.create()
--    onRunningLayer:retain()
    onRunningLayerSign = "main_base_layer" 
    scene:addChild(onRunningLayer, 998, 10002)
    CCDirector:sharedDirector():replaceScene(scene)
    onRunningLayerCallbackFunc = MainBaseLayer.exit

    --增加返回键监听
    local backClickLayer = CCLayer:create()
	scene:addChild(backClickLayer)
    local function KeypadHandler(strEvent)
        if "backClicked" == strEvent then

            Platform.exitSDK()
            --CCDirector:sharedDirector():endToLua()

        elseif "menuClicked" == strEvent then
--            CCDirector:sharedDirector():endToLua()
            Platform.clickMenu()
        end
    end
    backClickLayer:setKeypadEnabled(true)
    backClickLayer:registerScriptKeypadHandler(KeypadHandler)

  
    scene:registerScriptHandler(function ( eventType )
        if(eventType == "enter") then
            
            -- 更新体力耐力数据
            updateInfoData()
            updateAvatarInfo()
            addAvatarIcon()
            initFightValue()
            _fight_value:setString(math.floor(UserModel.getFightForceValue()))
            -- 监听竞技场发奖
            arenaRewardListener()
            require "script/utils/BaseUI"
            local noTouchLayer   = BaseUI.createMaskLayer(-5000,nil,nil,0)
            scene:addChild(noTouchLayer)

            local actionArray = CCArray:create()
            actionArray:addObject(CCDelayTime:create(0.1))
            actionArray:addObject(CCCallFunc:create(addNewGuideLayer))
            actionArray:addObject(CCCallFunc:create(function ( ... )
                noTouchLayer:removeFromParentAndCleanup(true)
            end))
            local newGuideAction = CCSequence:create(actionArray)
            scene:runAction(newGuideAction)

            require "script/cocostudio/ccs"
            --STTouchDispatcher:getInstance():startListen()

            if(UserModel.getHeroLevel() >= 7) then
                require "script/ui/main/GameNotice02"
                GameNotice02.showGameNotice()
                
            end
        end
    end)
    
end

function getAvatarLayerContentSize()
    return _avatarAttrBg:getContentSize()
end

--得到实际显示大小
function getAvatarLayerFactSize( ... )
    local  size = getAvatarLayerContentSize()
    local  factSize = CCSizeMake(size.width * _avatarAttrBg:getScaleX(), size.height * _avatarAttrBg:getScaleY())
    return factSize
end

function getBulletFactSize( ... )
    local  size = _bulletinBg:getContentSize()
    local  factSize = CCSizeMake(size.width * _bulletinBg:getScaleX(), size.height * _bulletinBg:getScaleY())
    return factSize
end

-- 获取avatar层的CCObject
function getAvatarLayerObj( ... )
    return _avatarAttrBg
end

-- 退出场景，释放不必要资源
function release (...)
    MainScene = nil
    package.loaded["MainScene"] = nil
    package.loaded["script/ui/main/MainScene"] = nil
end

--适配部分开始
--创建一个基础layer
function createBaseLayer(bgFileName,menuVisible,avatarVisible,bulletinVisible)

    require "script/audio/AudioUtil"
    AudioUtil.playMainBgm()
    --判断是否显示底栏
    if(menuVisible==nil) then
        menuVisible = true
    end
    menuLayer:setVisible(menuVisible)
    -- changed by fang. 2013.07.03
 --   local bottomBg = CCSprite:create(IMG_PATH_MENU .. "bottom.png")
 --   layerBeginHeight = menuLayer:isVisible() and bottomBg:getContentSize().height*elementScale or 0
    layerBeginHeight = menuLayer:isVisible() and MenuLayer.getHeight() or 0
        
    --判断是否显示玩家信息栏
    if(avatarVisible==nil)then
        avatarVisible = true
    end
    _avatarAttrBg:setVisible(avatarVisible)
    if avatarVisible then
        fnUpdateFightValue()
    end
    local avatarAttrBgHeight = (_avatarAttrBg:isVisible() and _avatarAttrBg:getContentSize().height*_avatarAttrBg:getScale() or 0)
    
    --判断是否显示通知滚动栏
    if(bulletinVisible==nil)then
        bulletinVisible = true
    end
    _bulletinBg:setVisible(bulletinVisible)
    local bulletinBgHeight = (_bulletinBg:isVisible() and _bulletinBg:getContentSize().height*_bulletinBg:getScale() or 0)
    
    --计算baselayer的信息
    local winSize = CCDirector:sharedDirector():getWinSize()
    
    local baseLayer = CSBaseUILayer:create(bgScale,elementScale)
    baseLayer:setPosition(0,layerBeginHeight)

    local baseLayerHeight = winSize.height-layerBeginHeight - avatarAttrBgHeight - bulletinBgHeight
    baseLayer:setContentSize(CCSizeMake(winSize.width,baseLayerHeight))
        
    --初始化背景
    if(bgFileName~=nil and type(bgFileName)=="string") then
        baseLayer:initBackground(bgFileName)
    end
    return baseLayer
end

function setMainSceneViewsVisible(menuVisible,avatarVisible,bulletinVisible)
    --判断是否显示底栏
    if(menuVisible==nil) then
        menuVisible = true
    end
    menuLayer:setVisible(menuVisible)
    
    --判断是否显示玩家信息栏
    if(avatarVisible==nil)then
        avatarVisible = true
    end
    _avatarAttrBg:setVisible(avatarVisible)
    if avatarVisible then
        fnUpdateFightValue()
    end
    
    --判断是否显示通知滚动栏
    if(bulletinVisible==nil)then
        bulletinVisible = true
    end
    _bulletinBg:setVisible(bulletinVisible)
end

--[[
    @des:得到底部主菜单显示状态
    @ret:bool
--]]
function isMenuVisible( ... )
    if menuLayer then
        return menuLayer:isVisible()
    else
        return false
    end
end

--[[
    @des:玩家信息栏显示状态
    @ret:bool
--]]
function isAvatarVisible( ... )
    if _avatarAttrBg then
        return _avatarAttrBg:isVisible()
    else
        return false
    end
end

--[[
    @des:得到通知滚动栏显示状态
    @ret:bool
--]]
function isBulletinVisible( ... )
    if _bulletinBg then
        return _bulletinBg:isVisible()
    else
        return false
    end
end


--更换当前显示层
function changeLayer(newLayer,sign,callbackFunc)
    -- require "script/battle/BattleCardUtil"
    -- if(BattleCardUtil.getBattlePlayerCardImage == nil)then
    --     checkUpdate()
    -- end

    if(newLayer==nil)then
        return
    end
    resetAvatarIcon()   --  刷新主角头像
    -- 有时装强化界面 chengeLayer时需要移除
    if(fnFashionEnhanceRemove)then 
        fnFashionEnhanceRemove()
    end
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:removeChild(onRunningLayer,true)
    --回调
    if(nil~=onRunningLayerCallbackFunc and type(onRunningLayerCallbackFunc) == "function")then
        onRunningLayerCallbackFunc()
    end
    scene:addChild(newLayer)
    onRunningLayer = newLayer
    onRunningLayerSign = sign
    onRunningLayerCallbackFunc = callbackFunc
    if MainBaseLayer then
        --MainBaseLayer.exit()
    end
    print("Platform.sendInformationToPlatform")
    if( (Platform.isAppStore() == true and Platform.sendInformationToPlatform ~= nil) or (config.getFlag() == "gwphone" and Platform.getOS() == "android") )then
        if( getOnRunningLayerSign() == "main_base_layer" )then
            isShowFloatingWindow(true)
        else
            isShowFloatingWindow(false)
        end
    end
    
    if g_system_type == kBT_PLATFORM_ANDROID then
        require "script/utils/LuaUtil"
        checkMem()
    else
        CCDirector:sharedDirector():purgeCachedData()
    end
    
    print(collectgarbage("count", 100))
    collectgarbage("collect", 100)
    print(collectgarbage("count", 100))
end
--获得当前显示层
function getOnRunningLayerSign()
    return onRunningLayerSign
end
--设置当前显示层标示，最好在changelayer中设置，不建议单独使用
function setOnRunningLayer(sign)
    onRunningLayer = sign
end
--获得当前baseLayer
function getOnRunningLayer()
    return onRunningLayer
end

--获得菜单位置，使用640*960下坐标（非baseLayer子节点）
function getMenuPosition(x,y)
    return ccp(x/(640.0)/elementScale,y/(960.0-117)/elementScale)
end

--获得菜单位置，使用640*960下坐标，确定layer（非baseLayer子节点）
function getMenuPositionByLayer(targetBaseLayer,x,y)
    return ccp(x/(640.0)/targetBaseLayer:getElementScale(),y/(960.0-117)/targetBaseLayer:getElementScale())
end

--获得标准位置，使用640*960下坐标（baseLayer子节点）
function getPosition(x,y)
    return ccp(x/640.0,y/(960.0-117))
end

--获得菜单位置，使用layer内比例坐标（非baseLayer子节点）
function getMenuPositionInTruePoint(x,y)
    return ccp(x/elementScale,y/elementScale)
end

--获得菜单位置，使用layer内比例坐标，确定layer（非baseLayer子节点）
function getMenuPositionInTruePointByLayer(targetBaseLayer,x,y)
    return ccp(x/targetBaseLayer:getElementScale(),y/targetBaseLayer:getElementScale())
end

function initScales()
    -- 计算基础适配元素
    local standSize = CCSizeMake(640, 960)
    
    local winSize = CCDirector:sharedDirector():getWinSize()
    
    bgScale = 1.0;
    elementScale = 1.0;
    -- 计算界面元素及背景伸缩比率因子
    if(winSize.height/winSize.width>standSize.height/standSize.width) then
        bgScale = winSize.height/standSize.height;
        elementScale = winSize.width/standSize.width;
        -- 伸缩比率因子设成全局变量
        g_fElementScaleRatio = elementScale
        g_fBgScaleRatio = bgScale
        
        else
        elementScale = winSize.height/standSize.height;
        bgScale = winSize.width/standSize.width;
        -- 伸缩比率因子设成全局变量
        g_fElementScaleRatio = elementScale
        g_fBgScaleRatio = bgScale
    end

end
--适配部分结束





-- add by lichenyang
function addNewGuideLayer(  )

    ---------------------新手引导---------------------------------
    require "script/ui/switch/SwitchOpen"
    SwitchOpen.registerLevelUpNotification()
   
    --初始化引导
    require "script/guide/NewGuide"
    NewGuide.init()
    NewGuide.saveUserUid()
     -- 保存通关第一个据点
    NewGuide.saveOneCopyStatus()
    print("UserHandler.isNewUser", UserHandler.isNewUser)
    print("NewGuide.isNeedOpen", NewGuide.isNeedOpen)
    -----------------------阵容---------------------------
    if( (UserHandler.isNewUser == true or NewGuide.isNeedOpen == true ) and UserModel.getHeroLevel() <= 2 ) then
        NewGuide.isNeedOpen = false
        require "script/ui/switch/SwitchOpen"
        SwitchOpen.isFight = false
        SwitchOpen.showNewSwitch(ksSwitchFormation)
        print("addNewGuideLayer 阵容")

    end
    ---------------------end-------------------------------
    -----------------------签到---------------------------
    require "script/guide/SignInGuide"
    -- if(NewGuide.guideClass ==  ksGuideSignIn and SignInGuide.stepNum == 0) then
    --     require "script/guide/FormationGuide"
    --     local formationButton = SignLayer.getSignBtn()
    --     local touchRect       = getSpriteScreenRect(formationButton)
    --     SignInGuide.show(1, touchRect)
    -- end
    --点击签到按钮
    local signButtonCallback = function ( )
        if(NewGuide.guideClass ==  ksGuideSignIn) then
            SignInGuide.changLayer()
            print("signButtonCallback")
        end
    end
    --签到加载完成
    local signLayerDidLoadCallback = function ( )
        if(NewGuide.guideClass ==  ksGuideSignIn and SignInGuide.stepNum == 1) then
            local buttonRect = SignRewardLayer.getReceiveBtn()
            local touchRect  = getSpriteScreenRect(buttonRect)
            SignInGuide.show(2, touchRect)
            print("signLayerDidLoadCallback")
        end
    end
    require "script/ui/sign/SignRewardLayer"
    SignRewardLayer.registerSignButtonClickCallback(signButtonCallback)
    SignRewardLayer.registerSignLayerDidLoadCallback(signLayerDidLoadCallback)


    require "script/ui/sign/SignRewardCell"
    local signGetCallback = function ( ... )
         if(NewGuide.guideClass ==  ksGuideSignIn and SignInGuide.stepNum == 2.5) then
            SignInGuide.changLayer()
            local buttonRect = SignRewardLayer.getCancelBtn()
            local touchRect  = getSpriteScreenRect(buttonRect)
            SignInGuide.show(3, touchRect)
            print("signLayerDidLoadCallback")
        end       
    end
    SignRewardCell.registerGetCallback(signGetCallback)

    local closeCallback = function ( ... )
        if(NewGuide.guideClass ==  ksGuideSignIn and SignInGuide.stepNum == 3) then
            -- SignInGuide.cleanLayer()
            -- NewGuide.guideClass = ksGuideClose
            -- BTUtil:setGuideState(false)
            -- NewGuide.saveGuideClass()

            SignInGuide.changLayer()
            require "script/ui/main/MenuLayer"
            local buttonRect = MenuLayer.getMenuItemNode(5)
            local touchRect  = getSpriteScreenRect(buttonRect)
            SignInGuide.show(4, touchRect)
            print("signLayerDidcloseCallback")
        end       
    end
    SignRewardLayer.registerSignLayerCloseCallback(closeCallback)
    ---------------------end-------------------------------------

    ----------------------10级等级礼包---------------------------
    require "script/guide/TenLevelGiftGuide"
    require "script/ui/level_reward/LevelRewardBtn"
    require "script/ui/level_reward/LevelRewardLayer"
    require "script/ui/shop/PubLayer"
    require "script/ui/shop/HeroDisplayerLayer"
    require "script/ui/formation/FormationLayer"
    require "script/ui/formation/FOfficerCell"
    require "script/ui/hero/HeroInfoLayer"
    --1

    --2
    local  levelRewardBtnCallback = function()
         if(NewGuide.guideClass ==  ksGuideTenLevelGift) then
            TenLevelGiftGuide.changLayer()
        end
    end
    LevelRewardBtn.registerLevelRewardBtnCallback(levelRewardBtnCallback)

    local levelRewardDidLoadCallback = function ()
        if(NewGuide.guideClass ==  ksGuideTenLevelGift and TenLevelGiftGuide.stepNum == 1) then
            local formationButton = LevelRewardLayer.getReceiveBtn(1)
            local touchRect       = getSpriteScreenRect(formationButton)
            TenLevelGiftGuide.show(2, touchRect)
        end
    end
    LevelRewardLayer.registerLevelRewardDidLoadCallback(levelRewardDidLoadCallback)
    --3
    local getLevelRewardOverCallback = function ( ... )
        if(NewGuide.guideClass ==  ksGuideTenLevelGift and TenLevelGiftGuide.stepNum == 2) then
            TenLevelGiftGuide.changLayer()
            local formationButton = LevelRewardLayer.getCloseBtn()
            local touchRect       = getSpriteScreenRect(formationButton)
            TenLevelGiftGuide.show(3, touchRect)
        end
    end
    LevelRewardCell.regisgerGetLevelRewardOverCallback(getLevelRewardOverCallback)
    --4
    local levelRewardCloseCallback = function ( ... )
        if(NewGuide.guideClass ==  ksGuideTenLevelGift and TenLevelGiftGuide.stepNum == 3) then
            TenLevelGiftGuide.changLayer()
            local formationButton = MenuLayer.getMenuItemNode(5)
            local touchRect       = getSpriteScreenRect(formationButton)
            TenLevelGiftGuide.show(4, touchRect)
        end
    end
    LevelRewardLayer.registerLevelRewardCloseCallback(levelRewardCloseCallback)
    --5
    local pubLayerDidLoadCallback = function ( )
        if(NewGuide.guideClass ==  ksGuideTenLevelGift and TenLevelGiftGuide.stepNum == 4) then
            TenLevelGiftGuide.changLayer()
            local formationButton = PubLayer.getGuideObject()
            local touchRect       = getSpriteScreenRect(formationButton)
            TenLevelGiftGuide.show(5, touchRect)
        end
    end
    PubLayer.registerPubLayerDidLoadCallback(pubLayerDidLoadCallback)
    local didClickRecruitingGeneralCallback = function ( ... )
        if(NewGuide.guideClass ==  ksGuideTenLevelGift and TenLevelGiftGuide.stepNum == 5) then
            TenLevelGiftGuide.cleanLayer()
        end
        print("didClickRecruitingGeneralCallback")
    end
    PubLayer.registerDidClickRecruitingGeneralCallback(didClickRecruitingGeneralCallback)
    --5.5 退出
    local didClickZhaoJiangCallback = function ( ... )
        if(NewGuide.guideClass ==  ksGuideTenLevelGift and TenLevelGiftGuide.stepNum == 5) then
            local formationButton = HeroDisplayerLayer.getGuideObject()
            local touchRect = getSpriteScreenRect(formationButton)
            TenLevelGiftGuide.show(5.5, touchRect)
        end
        print("didClickZhaoJiangCallback")
    end
    HeroDisplayerLayer.registerDidClickZhaoJiangCallback(didClickZhaoJiangCallback)
    --6 
    local heroDisplayerLayerCallback = function ( ... )
        if(NewGuide.guideClass ==  ksGuideTenLevelGift and TenLevelGiftGuide.stepNum == 5.5) then
            TenLevelGiftGuide.changLayer()
            local formationButton = MenuLayer.getMenuItemNode(2)
            local touchRect       = getSpriteScreenRect(formationButton)
            TenLevelGiftGuide.show(6, touchRect)
            print("heroDisplayerLayerCallback")
        end
    end
    HeroDisplayerLayer.registerHeroDisplayerLayerCloseCallback(heroDisplayerLayerCallback)
    -- 6
    local tenLevel7stCallback = function ( ... )
        if(NewGuide.guideClass ==  ksGuideTenLevelGift and TenLevelGiftGuide.stepNum == 6) then
            TenLevelGiftGuide.changLayer()
            local formationButton = FormationLayer.getGuideTopCell()
            local touchRect       = getSpriteScreenRect(formationButton)
            TenLevelGiftGuide.show(8, touchRect)
            print("tenLevel7stCallback")
        end
    end
    FormationLayer.registerFormationLayerDidLoadCallback(tenLevel7stCallback)
    -- 8 此步删除
    --[[
    local tenLevel8stCallback = function ( ... )
        if(NewGuide.guideClass ==  ksGuideTenLevelGift and TenLevelGiftGuide.stepNum == 7) then
            TenLevelGiftGuide.changLayer()
            local formationButton = FormationLayer.getGuideTopCell(2)
            local touchRect       = getSpriteScreenRect(formationButton)
            TenLevelGiftGuide.show(8, touchRect)
            print("tenLevel8stCallback")
        end
    end
    ]]--
    FOfficerCell.registerClickOnFormationCallback(tenLevel8stCallback)
    -- 8
    local tenLevel9stCallback = function ( ... )
        if(NewGuide.guideClass ==  ksGuideTenLevelGift and TenLevelGiftGuide.stepNum == 8) then
            TenLevelGiftGuide.changLayer()
            local formationButton = FormationLayer.getGuideTopCell(2)
            local touchRect       = CCRectMake(g_winSize.width * 0.5 - 120 * getScaleParm(), g_winSize.height * 0.5 - 180 * getScaleParm(), 240 * getScaleParm(), 450 * getScaleParm() )
            TenLevelGiftGuide.show(9, touchRect)
            print("tenLevel9stCallback")
        end
    end
    FormationLayer.registerSwapHeroCallback(tenLevel9stCallback)

    -- 9
    local tenLevel10stCallback = function ( ... )
        if(NewGuide.guideClass ==  ksGuideTenLevelGift and TenLevelGiftGuide.stepNum == 9) then
            TenLevelGiftGuide.changLayer()
            local touchRect       = getSpriteScreenRect(HeroInfoLayer.getChangeHeroButton())
            TenLevelGiftGuide.show(10, touchRect)
            print("tenLevel10stCallback")
        end
    end
    HeroInfoLayer.registerHeroInfoLayerCallback(tenLevel10stCallback)
    -- 10
    local tenLevel11stCallback = function ( ... )
   
    end
    HeroInfoLayer.registerChangeHeroCallback(tenLevel11stCallback)
    -- 11 10级等级礼包引导结束
    local tenLevel12stCallback = function ( ... )
        if(NewGuide.guideClass ==  ksGuideTenLevelGift and TenLevelGiftGuide.stepNum == 11) then
            TenLevelGiftGuide.cleanLayer()
            NewGuide.guideClass = ksGuideClose
            BTUtil:setGuideState(false)
            NewGuide.saveGuideClass()
        end       
    end 
    FOfficerCell.registerClickOnFormationCallback(tenLevel12stCallback)
    -----------------------end----------------------------------

end


-- 更新体力，耐力数据
function updateInfoData( ... )
    -- print(GetLocalizeStringBy("key_2374"))
    require "script/utils/TimeUtil"
    require "script/model/user/UserModel"
    require "script/utils/TimeUtil"
    local function updateTimedata()
        -- 当前服务器时间
        local curServerTime = TimeUtil.getSvrTimeByOffset()
        -- print("curServerTime == ",curServerTime)
        -- require "script/network/RequestCenter"
        -- require "script/network/Network"
        -- RequestCenter.user_checkValue(nil,Network.argsHandler("server_time",curServerTime,""),"user.checkValue_server_time" .. math.random(999))
        -- 当前体力值
        require "script/model/user/UserModel"
        local curExecution = UserModel.getEnergyValue()
        --体力最大值
        _nOriEnergyLimit = UserModel.getMaxExecutionNumber()
        -- 上次恢复体力时间
        local execution_time = UserModel.getEnergyValueTime()
        -- 小于上限开始恢复
        local passTime = tonumber(curServerTime) - execution_time
        local addExecution = math.floor(passTime/g_energyTime)
    
        if(addExecution >= 1)then
            local allExecution = curExecution + addExecution
            if(curExecution < _nOriEnergyLimit)then
                if(allExecution < _nOriEnergyLimit)then
                    -- 体力恢复
                    UserModel.addEnergyValue(addExecution)
                else
                    -- 体力恢复
                    local addExecution = _nOriEnergyLimit - curExecution
                    UserModel.addEnergyValue(addExecution)
                end

            end
            -- 恢复体力的时间
            -- 当前服务器时间
            local curServerTime = TimeUtil.getSvrTimeByOffset()
            UserModel.setEnergyValueTime(curServerTime)
        end
        
        -- 当前耐力值
        local curStamina = UserModel.getStaminaNumber()
        -- 耐力上限
        local staminaMax = UserModel.getMaxStaminaNumber()
        -- 上次恢复耐力时间
        local stamina_time = UserModel.getStaminaTime()
        -- print("staminaMax",staminaMax)
        -- 小于上限开始恢复
        local passTime = tonumber(curServerTime) - stamina_time
        local addStamina = math.floor(passTime/g_stainTime)
        
        if(addStamina >= 1)then
            local allStamina = curStamina + addStamina
            if(curStamina < staminaMax)then
                if(allStamina < staminaMax)then
                    -- 耐力恢复
                    UserModel.addStaminaNumber(addStamina)
                    -- require "script/network/RequestCenter"
                    -- require "script/network/Network"
                    -- RequestCenter.user_checkValue(nil,Network.argsHandler("stamina",UserModel.getStaminaNumber(),""),"user.checkValue_stamina" .. math.random(999))
                else
                    -- 耐力恢复
                    local addStamina = staminaMax - curStamina
                    UserModel.addStaminaNumber(addStamina)
                    -- require "script/network/RequestCenter"
                    -- require "script/network/Network"
                    -- RequestCenter.user_checkValue(nil,Network.argsHandler("stamina",UserModel.getStaminaNumber(),""),"user.checkValue_stamina" .. math.random(999))
                end
            end   
            -- 恢复耐力的时间
            -- 当前服务器时间
            -- local curServerTime = TimeUtil.getSvrTimeByOffset()
            -- require "script/network/RequestCenter"
            -- require "script/network/Network"
            -- RequestCenter.user_checkValue(nil,Network.argsHandler("server_time",curServerTime,""),"user.checkValue_server_time" .. math.random(999))
            UserModel.setStaminaTime(stamina_time + addStamina*g_stainTime)
            -- require "script/network/RequestCenter"
            -- require "script/network/Network"
            -- RequestCenter.user_checkValue(nil,Network.argsHandler("stamina_time",UserModel.getStaminaTime(),""),"user.checkValue_stamina_time" .. math.random(999))
            -- 调用耐力注册函数
            if(fnStaminaNumberChange ~= nil)then
                fnStaminaNumberChange()
            end
        end
    end
    -- schedule_updata = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updateTimedata, 1, false)
    schedule(_avatarAttrBg,updateTimedata, 1)
end


-- 耐力变化注册函数
function registerStaminaNumberChangeCallback( callFunc )
    fnStaminaNumberChange = callFunc
end


--加载必要信息，包括支付信息，非常重要。
function loadOther( ... )
    require "script/ui/login/ServerList"
    local serverInfo = ServerList.getSelectServerInfo()
    print_t(serverInfo)
    local pid = Platform.getPid()
    -- local uid = UserModel.getUserUid()
    
    print("purchase_groupId", serverInfo.group)

    CCUserDefault:sharedUserDefault():setStringForKey("purchase_pid", pid)
    CCUserDefault:sharedUserDefault():setStringForKey("purchase_group", tostring(serverInfo.group))
    CCUserDefault:sharedUserDefault():flush()

    print("Platform.getCurrentPlatform()=", Platform.getCurrentPlatform() )
    --支付监听器
    if(Platform.getCurrentPlatform() == kPlatform_AppStore) then

        Platform.addPurchaseListener()
    end
    
end

-- 注册时装强化界面删除方法
function registerFashionEnhanceRemove( callFunc )
    fnFashionEnhanceRemove = callFunc
end

-- 竞技场发奖 22:00 - 22:30 发送请求通知后端发奖 半个小时发奖
function arenaRewardListener( ... )
    -- 功能节点没开
    if not DataCache.getSwitchNodeState(ksSwitchArena,false) then
        return
    end
    local startTimeStr = "220000"
    local startTime = TimeUtil.getSvrIntervalByTime(startTimeStr)
    local endTime = startTime + 30*60
    if( TimeUtil.getSvrTimeByOffset(0) <=  endTime )then
        -- delayTime
        local delayTime = math.random(startTime,endTime)
        print("delayTime==>",delayTime)
        local runningScene = CCDirector:sharedDirector():getRunningScene()
        local actionArray = CCArray:create()
        actionArray:addObject(CCDelayTime:create(delayTime-TimeUtil.getSvrTimeByOffset(0)))
        actionArray:addObject(CCCallFunc:create(function ( ... )
           Network.rpc(requestFunc, "arena.sendRankReward", "arena.sendRankReward", nil, true)
        end))
        local seq = CCSequence:create(actionArray)
        runningScene:runAction(seq)
    end
end

----------------------------------------------------------------------------------
-- 活动列表记忆offset
local listOffset = nil

-- 设置offset
function setOffsetForList( p_offset )
    listOffset = p_offset
end

-- 得到offset
function getOffsetForList( ... )
    return listOffset
end
-----------------------------------------------------------------------------------

----------------------------- 登录只调一次的函数集合方法 --------------------------
function callOnceInGame( ... )
    -- 军团按钮小红圈
    require "script/ui/guild/GuildDataCache"
    local isShow = GuildDataCache.isShowRedTip()
    GuildDataCache.setIsShowRedTip( isShow )

    -- print("start fight time:", os.clock(), os.time())
    -- require "script/model/hero/FightForceModel"
    -- print("fight force by lichenyang:", FightForceModel.getFightForce())
    -- print("end fight time:", os.clock(), os.time())

    --记录当前登录的Pid
    CCUserDefault:sharedUserDefault():setStringForKey("user_pid", Platform.getPid())
    CCUserDefault:sharedUserDefault():flush()

end


local function updateCheck( versionInfos )
    require "script/ui/tip/AlertTip"

    local function tipFunc()
        local downloadUrl = "https://itunes.apple.com/cn/app/fang-kai-na-san-guo/id680465449?mt=8"
        if(versionInfos.base.package.packageUrl)then
            downloadUrl = versionInfos.base.package.packageUrl
        end
        print("downloadUrl == ",downloadUrl)
        Platform.openUrl(downloadUrl)
    end 
    AlertTip.showAlert(GetLocalizeStringBy("key_10050"),tipFunc, false, nil, GetLocalizeStringBy("key_10051"))
    return
end

local function checkVersionCallback( res, hnd )
    local versionJsonString = res:getResponseData()
    local retCode = res:getResponseCode()
    
    local cjson = require "cjson"
    local  version_info = cjson.decode(versionJsonString)

    updateCheck(version_info)
end


-- 检查
function checkUpdate()
    local g_checkVerion_url = "http://mapifknsg.zuiyouxi.com/phone/get3dVersion?"
    local check_version_url = g_checkVerion_url .. "&packageVersion=2.0.0&scriptVersion="..g_game_version  .. Platform.getUrlParam()
    local httpClient = CCHttpRequest:open(check_version_url, kHttpGet)
    httpClient:sendWithHandler(checkVersionCallback)
end

function isShowFloatingWindow( isShow )
    if( (Platform.isAppStore() == true and Platform.sendInformationToPlatform ~= nil) or (config.getFlag() == "gwphone" and Platform.getOS() == "android") )then
        if( isShow )then
            Platform.sendInformationToPlatform(Platform.kEnterTheGameHall)
        else
            Platform.sendInformationToPlatform(Platform.kLeaveTheGameHall)
        end
    end
end




