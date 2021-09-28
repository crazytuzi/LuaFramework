-- Filename: GlobalVars.lua
-- Author: fang
-- Date: 2013-05-20
-- Purpose: 该文件用于: 全局变量（非模块）声明及初始化;
-- 注意事项：该文件尽量只用于全局变量声明及初始化，初始化为常量或原生语言数值获取，不能取lua模块内部的数值。


-- 版本号修改：如果使用脚本自动化打包，则以下版本号需要通过脚本修改，手工打发布包时只能通过手工修改
-- 游戏发布的版本号

-- 系统平台类型，目前有ios, android
g_system_type = BTUtil:getPlatform()

require "script/Util"
require "script/Logger"

TOLUA_CAST_TABLEVIEW = "LuaTableView"

if g_system_type ~= kBT_PLATFORM_IOS and g_system_type ~= kBT_PLATFORM_ANDROID then
    require "script/Legacy"
    TOLUA_CAST_TABLEVIEW = "CCTableView"
end
require "script/network/Network"

amf3 = require "amf3"

g_publish_version = NSBundleInfo:getAppVersion()


-- 游戏脚本版本号
local function getScriptVersion()

    local base_path = CCFileUtils:sharedFileUtils():fullPathForFilename("script/ScriptVersion.plist")
    local b_dict = CCDictionary:createWithContentsOfFile(base_path)
    local s_version = b_dict:valueForKey("ScriptVersion"):getCString()
    print("s_version==sssss=", s_version )
    return s_version
end

g_game_version = getScriptVersion()


g_host = "192.168.1.91"
g_port = 7777

-- 是否为调试模式
g_debug_mode = BTUtil:getDebugStatus()
-- g_debug_mode = false
-- 设备可视化size
g_winSize = CCDirector:sharedDirector():getVisibleSize()
-- 设备可视起始坐标
g_origin = CCDirector:sharedDirector():getVisibleOrigin()

-- 项目美术资源原始设备size
g_originalDeviceSize = {width=640, height=960}

-- X轴伸缩比
g_fScaleX = g_winSize.width/g_originalDeviceSize.width
-- Y轴伸缩比
g_fScaleY = g_winSize.height/g_originalDeviceSize.height

-- 界面元素伸缩比
g_fElementScaleRatio = 1.0
-- 界面背景伸缩比
g_fBgScaleRatio = 1.0

-- 通用图片路径
g_pathCommonImage = "images/common/"

-- 通用字体名称
--g_sFontName = "STHeitiSC-Light"
g_sFontName = "STHeitiSC-Medium"
-- g_sFontName = "SimHei"
-- 胖娃体
g_sFontPangWa = "JPangWa"

-- 竞技场奖励显示用字体
g_sFontBold = "HelveticaNeue-Bold"

-- 系统平台类型，目前有ios, android
-- g_system_type = BTUtil:getPlatform()

local function fnSelectFont( ... )
    
    if g_system_type == kBT_PLATFORM_ANDROID then
        g_sFontPangWa = "fonts/py.ttf"
        g_sFontName = "fonts/Hei.ttf"
    elseif g_system_type == kBT_PLATFORM_IOS then
        if NSBundleInfo then
            local sys_lang = NSBundleInfo:getSysLanguage()
            if( sys_lang == "zh-Hant" or sys_lang == "zh-HK" )then
                g_sFontPangWa = "DFHaiBao-W12-WINP-BF"
            elseif( sys_lang == "vi" )then
                g_sFontPangWa = "UVNNguyenDu"
            else
                g_sFontPangWa = "JPangWa"
            end

            local model = NSBundleInfo:getDeviceModel()
            local version = NSBundleInfo:getSysVersion()

            if(version < "2.3.3")then
                g_sFontName = ""
                print("g_sFontName = ",g_sFontName)
            end 
        else
            g_sFontPangWa = "JPangWa"
        end
    elseif(g_system_type == kBT_PLATFORM_WP8) then
        g_sFontPangWa = "fonts/Hei.ttf"
        g_sFontName = "fonts/Hei.ttf"
    end
    if (Platform.getConfig().getGsFont ~= nil) then
        g_sFontPangWa = Platform.getConfig().getGsFont().fontPangWa or "JPangWa"
        g_sFontName =  Platform.getConfig().getGsFont().fontName or "STHeitiSC-Medium"
    end
end


fnSelectFont()

-- TableViewCell动画进入时长
g_cellAnimateDuration = 0.05

-- 提示的显示时长
g_tipAnimateDuration = 2.0

-- 判定左右手势滑动的 x轴有效横移像素点
g_limitedPixels = 10

-- 判定左右手势滑动的 斜率临界值
g_limitedK = 0.5

-- 最大上阵将领个数
g_limitedHerosOnFormation = 6

-- 耐力最大值
g_staminaNum = 100

-- 最大体力上限
g_maxEnergyNum = 150

-- 设备唯一标识符
g_dev_udid = "0000000000"
-- 初始化UDID值
local function initUDIDValue( ... )
    if g_system_type == kBT_PLATFORM_IOS then
        g_dev_udid = UDID:getMacAddr()
    end
end
initUDIDValue()

--新手引导touch权限等级
g_guideTouchPriority = -5000

-- 体力恢复一点时间 added by zhz
g_energyTime = 360

-- 耐力恢复一点时间 15分钟恢复一点
g_stainTime = 900

-- 网络状态值记录
g_network_disconnected=1                    -- 网络状态：断开
g_network_connecting=2                      -- 网络状态：连接中
g_network_connected=3                       -- 网络状态：已连接
g_network_status = g_network_disconnected   -- 网络状态：初始化为“断开”

-------------------------------------功能节点枚举值-------------------------------------
-- add by lichenyang 2013.08.29
ksSwitchFormation        = 1         --阵容
ksSwitchForge            = 2         --强化所
ksSwitchShop             = 3         --商店
ksSwitchEliteCopy        = 4         --精英副本
ksSwitchActivity         = 5         --活动
ksSwitchGreatSoldier     = 6         --名将
ksSwitchContest          = 7         --比武
ksSwitchArena            = 8         --竞技场
ksSwitchActivityCopy     = 9         --活动副本
ksSwitchPet              = 10        --宠物
ksSwitchResource         = 11        --资源矿
ksSwitchStar             = 12        --占星
ksSwitchSignIn           = 13        --签到
ksSwitchLevelGift        = 14        --等级礼包
ksSwitchSmithy           = 15        --铁匠铺
ksSwitchWeaponForge      = 16        --装备强化
ksSwitchGeneralForge     = 17        --武将强化
ksSwitchGeneralTransform = 18        --武将进阶
ksSwitchTreasureForge    = 19        --宝物强化
ksSwitchRobTreasure      = 20        --夺宝系统
ksSwitchResolve          = 21        --炼化炉
ksSwitchDestiny          = 22        --天命系统
ksSwitchGuild            = 23        --军团系统
ksSwitchEquipFixed       = 24        --装备洗练
ksSwitchTreasureFixed    = 25        --宝物精炼
ksSwitchTower            = 26        -- 爬塔
ksSwitchWorldBoss        = 27        -- 世界boss
ksSwitchBattleSoul       = 28        -- 战魂
ksSwitchEveryDayTask     = 30        -- 每日任务
ksHeroBiography          = 32        -- 武将列传
ksFindDragon             = 33        -- 寻龙探宝
ksOlympic                = 34        -- 擂台争霸
ksChangeSkill            = 35        -- 主角换技能
ksTransfer               = 36        -- 武将变身
ksHeroDevelop            = 37        -- 武将进化
ksWeekendShop            = 38        -- 周末商店
kMonthSignIn             = 39        -- 月签到
ksSwitchWarcraft         = 40        -- 阵法
ksSwitchGodWeapon        = 42        -- 神兵副本功能节点
ksSecondFriend           = 43        -- 助战军(第二套小伙伴)
ksExpCopy                = 44        -- 主角经验副本
ksSwitchStarSoul         = 45        -- 主角星魂系统
ksSwitchMoon             = 46        -- 水月之境
ksSwitchHellCopy         = 47        -- 炼狱副本
ksSwitchDrug             = 48        -- 丹药系统
ksSwitchLoyal            = 49        -- 聚义厅
ksSwitchKFBW             = 52        -- 跨服比武
ksSwitchRedHero          = 51        -- 红卡进化
ksSwitchRedEquip         = 53        -- 红色装备
ksSwitchTally            = 54        -- 兵符
ksSwitchPetDevelop       = 55        -- 宠物进阶
ksSwitchMnlm             = 56        -- 木牛流马
ksSwitchTitle            = 57        -- 称号系统
ksSwitchChariot          = 58        -- 战车系统
ksSwitchSevenLottery     = 59        -- 七星谭
ksSwitchHeroTurned       = 60        -- 武将幻化
-----------------------引导类型-----------------------
ksGuideFormation        =  1    --引导阵容
ksGuideForge            =  2    --引导强化所
ksGuideFiveLevelGift    =  3    --5级等级礼包
ksGuideCopyBox          =  4    --引导副本箱子
ksGuideTenLevelGift     =  5    --10级等级礼包
ksGuideSignIn           =  6    --引导签到
ksGuideForthFormation   =  7    --引导第4个上阵栏位开启
ksGuideEliteCopy        =  8    --引导精英副本开启
ksGuideGreatSoldier     =  9    --引导名将系统开启
ksGuideArena            =  10   --引导竞技场
ksGuidePet              =  11   --引导宠物系统
ksGuideResource         =  12   --引导资源矿系统
ksGuideAstrology        =  13   --引导占星系统
ksGuideContest          =  14   --比武引导
ksGuideRobTreasure      =  15   --夺宝引导系统
ksGuideSmithy           =  16   --铁匠铺引导系统
ksGuideGeneralUpgrade   =  17   --武将进阶新手引导
ksGuideResolve          =  18   --炼化炉引导
ksGuideDestiny          =  19   --天命系统新手引导
ksGuideBattleSoul       =  20   --战魂系统新手引导
ksGuideHeroBiography    =  21   --武将列传新手
ksGuideFindDragon       =  22   -- 寻龙探宝新手
ksGuideOlympic          =  23   -- 擂台争霸新手引导
ksGuideChangeSkill      =  24   -- 主角换技能
ksGuideHeroDevelop      =  25   -- 武将进化
ksGuideWarcraft         =  26   -- 阵法引导
ksGuideClose            =  99999  --当前关闭引导

---------------------宝物类型--------------------------
kTreasureHorseType      = 1     --1：名马
kTreasureBookType       = 2     --2：名书
kTreasureWeaponType     = 3     --3：名兵(暂无，预留)
kTreasureGemType        = 4     --4：珍宝(暂无，预留)



---------------------平台id-----------------------------
kPlatform_91_ios       = 1001       --91    ios
kPlatform_91_android   = 1002       --91    android
kPlatform_pp           = 1003       --pp    ios
kPlatform_360          = 1004       --360   android
kPlatform_uc           = 1005       --uc    android
kPlatform_dk           = 1006       --百度多酷
kPlatform_xiaomi       = 1007       --小米
kPlatform_dangle       = 1008       --当乐
kPlatform_wandoujia    = 1009       --豌豆荚
kPlatform_anzhi        = 1010       --安智市场
kPlatform_37wan        = 1011       --37wan
kPlatform_jifeng       = 1012       --机锋
kPlatform_tbt          = 1013       --同步推 ios
kPlatform_AppStore     = 1014       --AppSotre
kPlatform_iTools       = 1015       --itools
kPlatform_dangleios    = 1016       --当乐ios
kPlatform_pingguoyuan  = 1017       --苹果园
kPlatform_pp2          = 1018       --pp2
kPlatform_kuaiyong     = 1019
kPlatform_Zuiyouxi     = 1000       --Zuiyouxi
kPlatform_kimi         = 1030       --kimi
kPlatform_pps          = 1031       --pps
kPlatform_kldny        = 1032       --昆仑东南亚
kPlatform_kugou        = 1020       --酷狗
kPlatform_pps          = 1021       --pps
kPlatform_jinshan      = 1022       --金山
kPlatform_chukong      = 1023       --触控

kPlatform_oppo         = 1024       --OPPO
kPlatform_kuwo         = 1025       --酷我
kPlatform_huawei       = 1026       --华为
kPlatform_sogou        = 1027       --搜狗
kPlatform_mumayi       = 1028       --木蚂蚁
kPlatform_youmi        = 1029       --有米

kPlatform_pptv         = 2001       --pptv
kPlatform_yingyonghui  = 2002       --应用汇
kPlatform_xunlei       = 2003       --迅雷
kPlatform_lenovo       = 2004       --联想
kPlatform_chukong_lt   = 2007       --触控联通
kPlatform_chukong_ydm  = 2008       --触控移动MM
kPlatform_chukong_ydg  = 2009       --触控移动游戏基地
kPlatform_3g           = 2010       --3g
kPlatform_vivo         = 2011       --vivo
kPlatform_lenovoPush   = 2012       --联想Push版
kPlatform_c1wan        = 2013       --c1wan
kPlatform_chaohaowan   = 2014       --超好玩
kPlatform_4399         = 2015       --4399
kPlatform_baofeng      = 2016       --暴风影音

kPlatform_debug        = 9000       --线下测试


-- 计算背景及界面元素比率因子
local function calculate_scale_ratio()
    if g_fScaleX > g_fScaleY then
        g_fElementScaleRatio = g_fScaleY
        g_fBgScaleRatio = g_fScaleX
    else
        g_fElementScaleRatio = g_fScaleX
        g_fBgScaleRatio = g_fScaleY
    end
end

calculate_scale_ratio()

--李晨阳添加适配方法
--将node 安照等高缩放的比率 缩放到对应的大小
function setAdaptNode( node )
    node:setScale(g_fElementScaleRatio)
    return node
end

--设置当前节点拉伸到屏幕大小
--注意：此方法会使图片变形
function setAllScreenNode( node )
    local  deviceHeith = g_winSize.height
    local  deviceWidth = g_winSize.width
    local scaleX =  deviceWidth/node:getContentSize().width
    local scaleY = deviceHeith/node:getContentSize().height
    node:setScaleX(scaleX)
    node:setScaleY(scaleY)
end

-- 得到等高缩放比例
function getScaleParm()
    return g_fElementScaleRatio
end

function getMaxScaleParm( ... )
    return g_fBgScaleRatio
end

--按百分比计费屏幕位置 ccp(0.5,0.5) 就是屏幕中心
function ccps( xp,yp )
	local xt = g_winSize.width  * xp
	local yt = g_winSize.height * yp
	return ccp(xt, yt)
end
--按照sprite 的百分比计算位置 ccpsprite(0.5,0.5,mysprite) 就是mysprite中心
function ccpsprite( xp,yp,sprite )
	local xt = sprite:getContentSize().width  * xp
	local yt = sprite:getContentSize().height * yp
	return ccp(xt, yt)
end

--得到sprite的屏幕矩形
function getSpriteScreenRect( sprite )

    local scaleX = sprite:getScaleX()
    local scaleY = sprite:getScaleY()
    local pNode = sprite:getParent()
    print("sprite scale = (" .. scaleX .. "," .. scaleY .. ")")
    while (pNode ~= nil) do
        scaleX = scaleX * pNode:getScaleX()
        scaleY = scaleY * pNode:getScaleY()
        print("scaleX = ", scaleX)
        print("scaleY = ", scaleY)
        pNode = pNode:getParent()
    end
    local anrchoPos = sprite:getAnchorPoint()
    local pos       = sprite:convertToWorldSpace(ccp(0, 0))

    print("pos = (" .. pos.x .. "," .. pos.y .. ")")
    print("scale = (" .. scaleX .. "," .. scaleY .. ")")

    local x     = pos.x
    local y     = pos.y
    local width = sprite:getContentSize().width  * scaleX
    local height= sprite:getContentSize().height * scaleY

    local frameRect = CCRectMake(x, y, width, height)
    return frameRect
end

--新手箭头Action
function runMoveAction( arrowSprite )

    local rotation =math.rad(arrowSprite:getRotation())
    local moveDis = -15*getScaleParm()

    local ox,oy = arrowSprite:getPosition()
    local nx = math.cos(rotation) * moveDis
    local ny = - math.sin(rotation) * moveDis

    local actionArray = CCArray:create()

    local moveUp = CCMoveBy:create(0.5, ccp(nx, ny))
    actionArray:addObject(moveUp)
    local moveDown = CCMoveTo:create(0.5, ccp(ox, oy))
    actionArray:addObject(moveDown)

    local seq = CCSequence:create(actionArray)
    local repeatAction = CCRepeatForever:create(seq)
    arrowSprite:runAction(repeatAction)
end
