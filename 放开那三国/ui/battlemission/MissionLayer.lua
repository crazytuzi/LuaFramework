-- Filename: MissionLayer.lua
-- Author: llp
-- Date: 2014-6-10
-- Purpose: 该文件用于: 军团任务

module ("MissionLayer", package.seeall)

require "script/ui/main/MainScene"
require "script/audio/AudioUtil"
require "script/ui/guild/GuildDataCache"
require "script/ui/item/ItemUtil"
require "script/ui/guild/GuildUtil"
require "script/ui/guild/copy/GuildTeamData"
require "script/ui/guild/copy/GuildCopyCell"
require "script/ui/teamGroup/TeamGroupLayer"
require "db/DB_Legion_copy"
require "db/DB_Corps_quest"
require "db/DB_Corps_quest_config"
require "script/ui/guild/city/CityData"
require "script/ui/battlemission/MissionData"
require "script/ui/battlemission/MissionService"
require "script/ui/item/ReceiveReward"

local _bgLayer          = nil           --
local _bgLaystatus      = false
local _topBgSprite      = nil           -- 头部的sprite
local _bottomSprite     = nil           -- 底部的sprite
local _titleBg          = nil           -- 军团大厅的描述
local _myTableView      = nil           -- 副本的TableView
local _copyInfo         = nil           -- 副本的数据
local silverLabel       = nil
local _callbackFunc     = nil
local _leftNumLabel     = nil
local _helpNumLabel     = nil
local _missionTable     = {}            -- 后端的数据
local tagCpy            = 0
local doneNum           = 0
local _talkbg           = nil           -- 谈话的背景
local _bottomArrayBg    = {}
local _nowSelectTaskId  = nil           --当前选择的任务的id
local _nowSelectTaskPos = nil           --当前选择的任务的位置编号
local _handInItemTid    = nil           --要提交的物品的tid
local _refreshButton    = nil
local kTalkDialogTag    = 101

local function init()
    _bgLayer          = nil
    _bgLaystatus      = false
    _topBgSprite      = nil
    _bottomSprite     = nil
    _myTableView      = nil
    _copyInfo         = {}
    silverLabel       = nil
    _callbackFunc     = nil
    _helpNumLabel     =nil
    _leftNumLabel     = nil
    _missionTable     = {}
    tagCpy            = 0
    doneNum           = 0
    _talkbg           = nil
    _nowSelectTaskId  = nil
    _refreshButton    = nil
    _nowSelectTaskPos = 1
end

----------------------------------------------[[ 节点事件 ]] -------------------------------------------
function onNodeEvent( event)
     if(event == "enter") then
        _bgLaystatus= true
        GuildDataCache.setIsInGuildFunc(true)
     elseif(event == "exit") then
         GuildDataCache.setIsInGuildFunc(false)
        _bgLaystatus= false
        for i=1,3 do
        if(_bottomArrayBg[i]) then
            _bottomArrayBg[i]= nil
        end
        _canDefeatNumBg = nil
    end
     end
end
----------------------------------------------[[ 创建ui ]] -------------------------------------------
function createTopUI( )
    _topBgSprite = CCSprite:create("images/hero/avatar_attr_bg.png")
    _topBgSprite:setAnchorPoint(ccp(0,1))
    _topBgSprite:setPosition(0,_layerSize.height)
    _topBgSprite:setScale(g_fScaleX)
    _bgLayer:addChild(_topBgSprite)
    _bgLayer:registerScriptHandler(onNodeEvent)

    --添加战斗力文字图片
    local arributeDescLabel = CCSprite:create("images/guild/guangong/alltribute.png")
    arributeDescLabel:setAnchorPoint(ccp(0.5,0.5))
    arributeDescLabel:setPosition(_topBgSprite:getContentSize().width*0.15,_topBgSprite:getContentSize().height*0.43)
    _topBgSprite:addChild(arributeDescLabel)

    --读取用户信息
    local userInfo = UserModel.getUserInfo()
    if userInfo == nil then
        return
    end

    --总贡献
    -- totalGongxian = 11
    powerLabel = CCRenderLabel:create(guildExp, g_sFontName, 23, 1.5, ccc3( 0x00, 0x00, 0x00), type_stroke)
    powerLabel:setColor(ccc3(0xff, 0xff, 0xff))
    --m_powerLabel:setAnchorPoint(ccp(0,0.5))
    powerLabel:setPosition(_topBgSprite:getContentSize().width*0.27,_topBgSprite:getContentSize().height*0.66)
    _topBgSprite:addChild(powerLabel, 1, 101)

    --银币
    silverLabel = CCLabelTTF:create(tostring(userInfo.silver_num),g_sFontName,18)
    silverLabel:setColor(ccc3(0xe5,0xf9,0xff))
    silverLabel:setAnchorPoint(ccp(0,0.5))
    silverLabel:setPosition(_topBgSprite:getContentSize().width*0.61,_topBgSprite:getContentSize().height*0.43)
    _topBgSprite:addChild(silverLabel, 1, 102)

    --金币
    goldLabel = CCLabelTTF:create(tostring(userInfo.gold_num),g_sFontName,18)
    goldLabel:setColor(ccc3(0xff,0xe2,0x44))
    goldLabel:setAnchorPoint(ccp(0,0.5))
    goldLabel:setPosition(_topBgSprite:getContentSize().width*0.82,_topBgSprite:getContentSize().height*0.43)
    _topBgSprite:addChild(goldLabel, 2, 103)
end

-- 创建底部的UI
function createBottomSprite( )
    require "script/ui/guild/GuildBottomSprite"
    _bottomSprite= GuildBottomSprite.createBottomSprite()
    _bottomSprite:setScale(g_fScaleX)
    _bottomSprite:setAnchorPoint(ccp(0.5,0))
    _bottomSprite:setPosition(ccp(g_winSize.width/2,0))
    _bgLayer:addChild(_bottomSprite, 12)
end

-- 创建中间UI
function createMidUi()

    _bottomArrayBg = {}
    for i=1,3 do
        local menu = CCMenu:create()
        menu:setPosition(ccp(0,0))
        local id = tonumber(_missionTable[i].id)
        local des = DB_Corps_quest.getDataById(id)
        local tab = string.split(des.completeConditions,",")
        local diBg = CCSprite:create("images/battlemission/stand.png")
        _bgLayer:addChild(diBg,1,i)
        diBg:setScale(g_fElementScaleRatio)
        _bottomArrayBg[i]=diBg

        diBg:setAnchorPoint(ccp(0.5,0.5))
        diBg:setPosition(ccp(_bgLayer:getContentSize().width*0.2+_bgLayer:getContentSize().width*(i-1)*0.3,_bgLayer:getContentSize().height*0.56))
        diBg:addChild(menu)
        spCoin = CCMenuItemImage:create("images/base/hero/body_img/"..des.heroId,"images/base/hero/body_img/"..des.heroId)
        menu:addChild(spCoin)
        spCoin:setAnchorPoint(ccp(0.5,0))
        spCoin:setPosition(ccp(diBg:getContentSize().width*0.5,diBg:getContentSize().height*0.6))
        spCoin:setScale(0.5)
        spCoin:setTag(i)
        spCoin:registerScriptTapHandler(MenuItemCallFun)

        local tanCoin = nil
        if(tonumber(_missionTable[i].status)==0)then
            tanCoin = CCSprite:create("images/battlemission/tan.png")
        elseif(tonumber(_missionTable[i].status)==1)then
            tanCoin = CCSprite:create("images/battlemission/hui.png")
        end
        tanCoin:setScale(0.6)
        if(tonumber(_missionTable[i].num)>=tonumber(tab[3]))then
            tanCoin = CCSprite:create("images/battlemission/wen.png")
        end
        tanCoin:setAnchorPoint(ccp(0.5,0))
        diBg:addChild(tanCoin)
        tanCoin:setPosition(ccp(diBg:getContentSize().width*0.5,260))

        require "script/ui/hero/HeroPublicLua"
        local nameColor = HeroPublicLua.getCCColorByStarLevel(des.questStar)
        local desLabel = CCRenderLabel:create(des.questName, g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        desLabel:setAnchorPoint(ccp(0.5,0.5))
        desLabel:setColor(nameColor)
        desLabel:setPosition(ccp(diBg:getContentSize().width*0.5,desLabel:getContentSize().height*1.5))
        diBg:addChild(desLabel)

        --数字
        local pNumLabel = CCRenderLabel:create(des.questStar, g_sFontPangWa,21,1,ccc3( 0x00, 0x00, 0x00), type_stroke)
        pNumLabel:setColor(ccc3(0x00,0xff,0x18))
        pNumLabel:setAnchorPoint(ccp(1,0))
        diBg:addChild(pNumLabel,10)
        pNumLabel:setPosition(ccp(diBg:getContentSize().width*0.5,0))

        --星星
        local pStarSprite = CCSprite:create("images/common/small_star.png")
        pStarSprite:setAnchorPoint(ccp(0,0))
        pStarSprite:setPosition(ccp(diBg:getContentSize().width*0.5,0))
        diBg:addChild(pStarSprite,10)

        local pStatusSprite = nil--CCSprite:create("images/battlemission/ing.png")

        if(tonumber(_missionTable[i].num)>=tonumber(tab[3]))then
            pStatusSprite = CCSprite:create("images/battlemission/finish.png")
        --end
        elseif(tonumber(_missionTable[i].status)==0)then
            pStatusSprite = CCSprite:create("images/battlemission/accept.png")
        elseif(tonumber(_missionTable[i].status)==1)then
            pStatusSprite = CCSprite:create("images/battlemission/ing.png")
        end

        print(" (missionTable[i].num is ", _missionTable[i].num , " tab[3] is ", tab[3] )
        pStatusSprite:setAnchorPoint(ccp(0.5,0.5))
        diBg:addChild(pStatusSprite)
        pStatusSprite:setPosition(ccp(diBg:getContentSize().width*0.5,-pStarSprite:getContentSize().height))
    end
end


-- 创建军团的任务大厅顶部UI
function createDescUI( )
    local winSize = CCDirector:sharedDirector():getWinSize()
    _titleBg = CCSprite:create("images/formation/topbg.png")
    _titleBg:setAnchorPoint(ccp(0.5,1))
    _titleBg:setPosition(ccp( _layerSize.width/2, winSize.height))
    _bgLayer:addChild(_titleBg, 99)
    _titleBg:setScale(g_fScaleX)

    local teamTitle = CCSprite:create("images/battlemission/mission.png")
    teamTitle:setPosition(ccp(9,_titleBg:getContentSize().height/2 ))
    teamTitle:setAnchorPoint(ccp(0,0.5))
    _titleBg:addChild(teamTitle)

    local curLevelLabel = CCRenderLabel:create("LV." .. guildLevel, g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    curLevelLabel:setPosition(213,39)
    curLevelLabel:setColor(ccc3(0xff,0xea,0x00))
    curLevelLabel:setAnchorPoint(ccp(0,0))
    _titleBg:addChild(curLevelLabel)

    local donateLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1185"), g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    donateLabel:setColor(ccc3(0xff,0xea,0x00))
    donateNumLabel= CCRenderLabel:create(guildExp, g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    donateNumLabel:setColor(ccc3(0xff,0xff,0xff))

    local label1 = BaseUI.createHorizontalNode({donateLabel, donateNumLabel})
    -- label1:setAnchorPoint(ccp(0, 1))
    label1:setPosition(350,64)
    _titleBg:addChild(label1)

    local nextNeed = CCRenderLabel:create(GetLocalizeStringBy("key_3041"), g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    nextNeed:setColor(ccc3(0xfe, 0xdb, 0x1c))
    local nextLv = guildLevel +1
    local maxLevel= GuildUtil.getMaxHallCopyLevel()
    local needNumber =nil
    if(1< tonumber(maxLevel)) then
        needNumber= CCRenderLabel:create(GuildUtil.getMilitaryNeedExpByLv(nextLv) , g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    else
        needNumber= CCRenderLabel:create("--" , g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    end
    needNumber:setColor(ccc3(0xff,0xff,0xff))

    local label1 = BaseUI.createHorizontalNode({nextNeed, needNumber})
    label1:setPosition(350,27)
    _titleBg:addChild(label1)

    local menu= CCMenu:create()
    menu:setPosition(ccp(0,0))
    _titleBg:addChild(menu)
    -- 返回按钮的回调函数
    local backBtn = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
    backBtn:setAnchorPoint(ccp(1,0.5))
    backBtn:setPosition(ccp(_titleBg:getContentSize().width-10,_titleBg:getContentSize().height*0.5-5))
    backBtn:registerScriptTapHandler(backBtnCB)
    menu:addChild(backBtn,1)
    local tanCoin = CCSprite:create("images/battlemission/tan.png")
    local spCoin = CCSprite:create("images/base/hero/body_img/quan_bin_baimayicong.png")
    local diBg = CCSprite:create("images/battlemission/stand.png")
    createMidUi()

    local wanFinishLabel = CCRenderLabel:create(GetLocalizeStringBy("llp_38"), g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    wanFinishLabel:setColor(ccc3(0xff,0xf6,0x00))

    local wanFinishLabel1 = CCRenderLabel:create(GetLocalizeStringBy("llp_39"), g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    wanFinishLabel1:setColor(ccc3(0xe4,0x00,0xff))

    local wanFinishLabel2 = CCRenderLabel:create(GetLocalizeStringBy("llp_40"), g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    wanFinishLabel2:setColor(ccc3(0x00,0xe4,0xff))

    local wanFinishLabel3 = CCRenderLabel:create(GetLocalizeStringBy("llp_41"), g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    wanFinishLabel3:setColor(ccc3(0xff,0xf6,0x00))

    local contentNode = BaseUI.createHorizontalNode({wanFinishLabel,wanFinishLabel1,wanFinishLabel2,wanFinishLabel3})
    contentNode:setAnchorPoint(ccp(0.5,1))
    contentNode:setPosition(ccp(_bgLayer:getContentSize().width*0.5, winSize.height -_titleBg:getContentSize().height*g_fScaleX))
    contentNode:setScale(MainScene.elementScale)
    _bgLayer:addChild(contentNode,10)

end

--下面九分图
function createLeftNum(index)

    if(_canDefeatNumBg~=nil) then
        _canDefeatNumBg:removeFromParentAndCleanup(true)
        _canDefeatNumBg= nil
    end

    _canDefeatNumBg = CCScale9Sprite:create("images/copy/ecopy/lefttimesbg.png")
    _canDefeatNumBg:setAnchorPoint(ccp(0.5,0))
    -- _canDefeatNumBg:setContentSize(CCSizeMake(640, pUpLabel:getContentSize().height+pYeBack:getContentSize().height+_refreshButton:getContentSize().height) )
    _canDefeatNumBg:setContentSize(CCSizeMake(640, 200) )
    _bottomSprite:addChild(_canDefeatNumBg, 10)

    local canDefeatSize = _canDefeatNumBg:getContentSize()
    local id = tonumber(_missionTable[index].id)
    local des = DB_Corps_quest.getDataById(id)
    local desConfig = DB_Corps_quest_config.getDataById(1)
    local tab = string.split(des.completeConditions,",")

    local taskCount = tonumber(tab[3])

    -- treas :
    -- dictionary{
    --     5000003 :
    --         dictionary{
    --             item_id : "113671506"
    --             item_template_id : "502402"
    --             item_num : "1"
    --             item_time : "1414465361.000000"
    --             va_item_text :
    --                 dictionary{
    --                     treasureLevel : "0"
    --                     treasureExp : "0"
    --                     treasureEvolve : "0"
    --                 }
    --         }

    --上缴宝物
    local pUpLabel = CCRenderLabel:create(des.questName, g_sFontPangWa,21,1,ccc3( 0x00, 0x00, 0x00), type_stroke)
    pUpLabel:setColor(ccc3(0xff,0xff,0xff))
    pUpLabel:setAnchorPoint(ccp(0,1))
    _canDefeatNumBg:addChild(pUpLabel,10)

    --数字
    local pNumLabel = CCRenderLabel:create(des.questStar, g_sFontPangWa,21,1,ccc3( 0x00, 0x00, 0x00), type_stroke)
    pNumLabel:setColor(ccc3(0x00,0xff,0x18))
    pNumLabel:setAnchorPoint(ccp(0,1))
    _canDefeatNumBg:addChild(pNumLabel,10)

    --星星
    local pStarSprite = CCSprite:create("images/common/small_star.png")
    pStarSprite:setAnchorPoint(ccp(0,1))
    _canDefeatNumBg:addChild(pStarSprite,10)

    --右数字尾
    local pRightNumLabel = CCRenderLabel:create("/"..tab[3], g_sFontPangWa,21,1,ccc3( 0x00, 0x00, 0x00), type_stroke)
    pRightNumLabel:setColor(ccc3(0xff,0xff,0xff))
    pRightNumLabel:setAnchorPoint(ccp(1,1))
    _canDefeatNumBg:addChild(pRightNumLabel,10)

    --右数字尾2
    local pRight2NumLabel = nil
    bagInfo = DataCache.getBagInfo()
    local countNum = 0

    if (tonumber(des.questType)==2 and bagInfo) then
        -- if(tonumber(tab[1])==tonumber(des.type))then
            for i=1,#bagInfo.treas do
                local bagdes = DB_Item_treasure.getDataById(bagInfo.treas[i].item_template_id)
                if(tonumber(tab[1])==tonumber(bagdes.type) and tonumber(bagdes.quality)==tonumber(tab[2])) then
                    countNum = countNum+1
                end
            end
        -- end
    end
    if(countNum<tonumber(tab[3]) and tonumber(des.questType)==2)then
        pRight2NumLabel = CCRenderLabel:create(countNum, g_sFontPangWa,21,1,ccc3( 0x00, 0x00, 0x00), type_stroke)
    else
        pRight2NumLabel = CCRenderLabel:create(countNum, g_sFontPangWa,21,1,ccc3( 0x00, 0x00, 0x00), type_stroke)
    end

    if(tonumber(des.questType)~=2)then
        pRight2NumLabel = CCRenderLabel:create(_missionTable[index].num, g_sFontPangWa,21,1,ccc3( 0x00, 0x00, 0x00), type_stroke)
    end


    pRight2NumLabel:setColor(ccc3(0x00,0xff,0x18))
    pRight2NumLabel:setAnchorPoint(ccp(1,1))
    _canDefeatNumBg:addChild(pRight2NumLabel,10)

    --任务进度
    local pMission = CCSprite:create("images/battlemission/missionprogress.png")
    pMission:setAnchorPoint(ccp(1,1))
    _canDefeatNumBg:addChild(pMission,10)

    --黄色透明底
    local pYeBack = CCScale9Sprite:create("images/battlemission/yeback.png")
    pYeBack:setAnchorPoint(ccp(0,1))
    pYeBack:setContentSize(CCSizeMake(320, 100) )
    _canDefeatNumBg:addChild(pYeBack, 10)

    --任务物品底框
    local pBack = CCSprite:create("images/battlemission/headback.png")
    pBack:setAnchorPoint(ccp(0,0))
    pYeBack:addChild(pBack)
    pYeBack:setContentSize(CCSizeMake(320,pBack:getContentSize().height))

    local pHead = CCSprite:create("images/base/hero/head_icon/"..des.iconId)
    pHead:setAnchorPoint(ccp(0.5,0.5))
    pHead:setScale(1.2)
    pBack:addChild(pHead)
    pHead:setPosition(ccp(pBack:getContentSize().width*0.5,pBack:getContentSize().height*0.5))

    --说明文字
    local pDesLabel = CCRenderLabel:create(GetLocalizeStringBy("llp_42"), g_sFontPangWa,21,1,ccc3( 0x00, 0x00, 0x00), type_stroke)
    pDesLabel:setColor(ccc3(0xff,0xf6,0x00))
    pDesLabel:setAnchorPoint(ccp(0,0))
    pYeBack:addChild(pDesLabel,10)
    --说明具体说明
    local pDesDetailLabel = CCRenderLabel:create(des.questExplain, g_sFontName,21,1,ccc3( 0x00, 0x00, 0x00), type_stroke)
    pDesDetailLabel:setColor(ccc3(0x00,0xf4,0xff))
    pDesDetailLabel:setAnchorPoint(ccp(0,0))
    pYeBack:addChild(pDesDetailLabel,10)
    --奖励文字
    local pRewardLabel = CCRenderLabel:create(GetLocalizeStringBy("llp_43"), g_sFontPangWa,21,1,ccc3( 0x00, 0x00, 0x00), type_stroke)
    pRewardLabel:setColor(ccc3(0xff,0xf6,0x00))
    pRewardLabel:setAnchorPoint(ccp(0,0))
    pYeBack:addChild(pRewardLabel,10)

    local reward = string.split(des.questReward,",")
    local nodeReward = ItemUtil.getRewardNode(reward[1])
    pRewardLabel:addChild(nodeReward)
    nodeReward:setPosition(ccp(pRewardLabel:getContentSize().width,0))

    local nodeReward1 = ItemUtil.getRewardNode(reward[3])
    pRewardLabel:addChild(nodeReward1)
    -- nodeReward1:setAnchorPoint(ccp(0,1))
    local sprite   = CCSprite:create("images/base/props/shengwang.png")
    nodeReward1:setPosition(ccp(pRewardLabel:getContentSize().width,sprite:getContentSize().height*-1*0.4))

    local inMenu = CCMenu:create()
    _canDefeatNumBg:addChild(inMenu)
    inMenu:setPosition(ccp(0,0))
    inMenu:setColor(ccc3(0x00,0xff,0x18))
    local item = nil
    -- item:setScaleX(0.7)

    --银币数字
    local pAcceptLabel = nil
    if(tonumber(_missionTable[index].status)==0)then
        pAcceptLabel = CCRenderLabel:create(GetLocalizeStringBy("llp_44"), g_sFontPangWa,33,1,ccc3( 0x00, 0x00, 0x00), type_stroke)
        item = CCMenuItemImage:create("images/common/btn/btn_bg_n.png","images/common/btn/btn_bg_h.png")
        item:registerScriptTapHandler(acceptTaskCallback)
    else
        pAcceptLabel = CCRenderLabel:create(GetLocalizeStringBy("llp_45"), g_sFontPangWa,33,1,ccc3( 0x00, 0x00, 0x00), type_stroke)
        item = CCMenuItemImage:create("images/battlemission/red.png","images/battlemission/red1.png")
        item:registerScriptTapHandler(forgiveTaskCallback)
    end
    if(tonumber(_missionTable[index].num)>=tonumber(tab[3]))then
        pAcceptLabel = CCRenderLabel:create(GetLocalizeStringBy("llp_46"), g_sFontPangWa,33,1,ccc3( 0x00, 0x00, 0x00), type_stroke)
        item = CCMenuItemImage:create("images/common/btn/btn_bg_n.png","images/common/btn/btn_bg_h.png")
        item:registerScriptTapHandler(doneTaskCallback)
    end
    item:setAnchorPoint(ccp(0.5,0.5))
    item:setPosition(ccp(item:getContentSize().width*0.5,item:getContentSize().height*0.5))
    inMenu:addChild(item)
    pAcceptLabel:setColor(ccc3(0xfe,0xdb,0x1c))
    pAcceptLabel:setAnchorPoint(ccp(0.5,0.5))
    pAcceptLabel:setPosition(ccp(item:getContentSize().width*0.5,item:getContentSize().height*0.5))
    item:addChild(pAcceptLabel,10,1)
    -- pAcceptLabel:setScaleX(1/0.7)

    local norSprite = CCScale9Sprite:create("images/common/btn/btn_bg_n.png")
    norSprite:setContentSize(CCSizeMake(240, 61))
    local higSprite = CCScale9Sprite:create("images/common/btn/btn_bg_h.png")
    higSprite:setContentSize(CCSizeMake(240, 61))

    local item1 = CCMenuItemSprite:create(norSprite, higSprite)
    item1:setAnchorPoint(ccp(0,0))
    item1:setPosition(ccp(item:getContentSize().width,0))
    item1:registerScriptTapHandler(doneTaskByGoldCallback)
    inMenu:addChild(item1,1, index)

    --立即完成
    local pAcceptLabel1 = CCRenderLabel:create(GetLocalizeStringBy("llp_47"), g_sFontPangWa,33,1,ccc3( 0x00, 0x00, 0x00), type_stroke)
    pAcceptLabel1:setColor(ccc3(0xfe,0xdb,0x1c))
    pAcceptLabel1:setAnchorPoint(ccp(0.5,0.5))
    pAcceptLabel1:setPosition(ccp(item1:getContentSize().width*0.5,item1:getContentSize().height*0.5))
    local goldIcon = CCSprite:create("images/common/gold.png")

    local goldNum = MissionData.getCompleteTaskGoldByPos(_nowSelectTaskPos)
    local itemGoldNumLabel = CCRenderLabel:create(goldNum, g_sFontPangWa,18,1,ccc3( 0x00, 0x00, 0x00), type_stroke )
    itemGoldNumLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))

    local item1ContentNode = BaseUI.createHorizontalNode({pAcceptLabel1, goldIcon, itemGoldNumLabel})
    item1ContentNode:setAnchorPoint(ccp(0.5, 0.5))
    item1ContentNode:setPosition(item1:getContentSize().width *0.5, item1:getContentSize().height * 0.5)
    item1:addChild(item1ContentNode,10,1)

    item2 = CCMenuItemImage:create("images/common/btn/btn_bg_n.png","images/common/btn/btn_bg_h.png")
    item2:setAnchorPoint(ccp(1,0.5))
    inMenu:addChild(item2)
    --银币数字
    local pAcceptLabel2 = CCRenderLabel:create(GetLocalizeStringBy("llp_48"), g_sFontPangWa,33,1,ccc3( 0x00, 0x00, 0x00), type_stroke)
    pAcceptLabel2:setColor(ccc3(0xfe,0xdb,0x1c))
    pAcceptLabel2:setAnchorPoint(ccp(0.5,0.5))
    pAcceptLabel2:setPosition(ccp(item2:getContentSize().width*0.5,item2:getContentSize().height*0.5))
    item2:addChild(pAcceptLabel2,10)
    print("_missionTable[index].status", _missionTable[index].status)
    print("des.questType"..des.questType)
    item2:registerScriptTapHandler(goNow)
    if(tonumber(_missionTable[index].status)~=1 or tonumber(des.questType)~=4 and tonumber(des.questType)~=5 and tonumber(des.questType)~=6 )then
        item2:setVisible(false)
    else


        -- if(tonumber(des.questType)==2)then
        --     pAcceptLabel2:removeFromParentAndCleanup(true)
        --     local pAcceptLabel2 = CCRenderLabel:create(GetLocalizeStringBy("llp_109"), g_sFontPangWa,33,1,ccc3( 0x00, 0x00, 0x00), type_stroke)
        --     pAcceptLabel2:setColor(ccc3(0xfe,0xdb,0x1c))
        --     pAcceptLabel2:setAnchorPoint(ccp(0.5,0.5))
        --     pAcceptLabel2:setPosition(ccp(item2:getContentSize().width*0.5,item2:getContentSize().height*0.5))
        --     item2:addChild(pAcceptLabel2,10)
        --     item2:registerScriptTapHandler(getGift)
        -- end
        item2:setVisible(true)
    end
    if(countNum<tonumber(tab[3]) and tonumber(des.questType)==2)then
        if(tonumber(des.questType)==2)then
            pAcceptLabel2:removeFromParentAndCleanup(true)
            local pAcceptLabel2 = CCRenderLabel:create(GetLocalizeStringBy("llp_109"), g_sFontPangWa,33,1,ccc3( 0x00, 0x00, 0x00), type_stroke)
            pAcceptLabel2:setColor(ccc3(0xfe,0xdb,0x1c))
            pAcceptLabel2:setAnchorPoint(ccp(0.5,0.5))
            pAcceptLabel2:setPosition(ccp(item2:getContentSize().width*0.5,item2:getContentSize().height*0.5))
            item2:addChild(pAcceptLabel2,10)
            item2:registerScriptTapHandler(getGift)
        end
        item2:setVisible(true)
    end

    if(tonumber(_missionTable[index].status)~=1)then
        item2:setVisible(false)
    end


    --格子框初始图片
    csQuality = CCMenuItemImage:create("images/common/border.png","images/common/border.png")
    csQuality:setAnchorPoint(ccp(1,0.5))
    csQuality:registerScriptTapHandler(chooseItem)

    head_icon=CCSprite:create("images/common/add_new.png")
    local arrActions_2 = CCArray:create()
    arrActions_2:addObject(CCFadeOut:create(1))
    arrActions_2:addObject(CCFadeIn:create(1))
    local sequence_2 = CCSequence:create(arrActions_2)
    local action_2 = CCRepeatForever:create(sequence_2)
    head_icon:runAction(action_2)
    csQuality:addChild(head_icon)
    head_icon:setAnchorPoint(ccp(0.5,0.5))
    head_icon:setPosition(ccp(csQuality:getContentSize().width*0.5,csQuality:getContentSize().height*0.5))
    inMenu:addChild(csQuality)

    if(tonumber(_missionTable[index].status)~=1 or tonumber(des.questType)~=1 and tonumber(des.questType)~=2)then
        csQuality:setVisible(false)
    else
        csQuality:setVisible(true)
    end

    if(tonumber(des.questType)==2 and countNum<tonumber(tab[3]))then
        csQuality:setVisible(false)
    -- else
    --     csQuality:setVisible(true)
    end


    --可完成状态
    if(MissionData.getTaskNum(index) >= taskCount) then
        csQuality:setVisible(false)
        item2:setVisible(false)
        item1:setVisible(false)
    end

    --进行中得物品状态
    if(MissionData.getTaskNum(index) >= taskCount and _handInItemTid ~= nil) then
        csQuality:setVisible(false)
        local itemIcon = ItemSprite.getItemSpriteByItemId(_handInItemTid)
        itemIcon:setAnchorPoint(ccp(1,0.5))
        itemIcon:setPosition(ccp(600,_canDefeatNumBg:getContentSize().height*0.5))
        _canDefeatNumBg:addChild(itemIcon)
    end




    -- added by zhz
    require "script/libs/LuaCC"
    _refreshButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(229,73),"",ccc3(255,222,0))
    _refreshButton:registerScriptTapHandler(surFreshTip)
    _refreshButton:setAnchorPoint(ccp(0.5,0))
    inMenu:addChild(_refreshButton)

    local normalLabel = CCRenderLabel:create(GetLocalizeStringBy("llp_49"), g_sFontPangWa, 32, 1.5, ccc3(0,0,0), type_stroke)
    normalLabel:setColor(ccc3(255,222,0))
    normalLabel:setAnchorPoint(ccp(0.5, 1))
    normalLabel:setPosition((_refreshButton:getContentSize().width)*0.4,(_refreshButton:getContentSize().height)*0.8)
    _refreshButton:addChild(normalLabel,1)

    local goldIcon = CCSprite:create("images/common/gold.png")
    goldIcon:setAnchorPoint(ccp(0.5,0.5))
    goldIcon:setPosition( 169 ,_refreshButton:getContentSize().height*0.5)
    _refreshButton:addChild(goldIcon)

    print(" MissionData.getRfcGold() is ", MissionData.getRfcGold() )
    _goldLabel = CCRenderLabel:create("" .. MissionData.getRfcGold() , g_sFontPangWa, 18,1,ccc3( 0x00, 0x00, 0x00), type_stroke )
    _goldLabel:setColor(ccc3(0xfe,0xdb,0x1c))
    _goldLabel:setAnchorPoint( ccp(0.5,1) )
    _goldLabel:setPosition(goldIcon:getPositionX()+goldIcon:getContentSize().width ,_refreshButton:getContentSize().height*0.7)
    _refreshButton:addChild(_goldLabel)


    --完成
    pFinishLabel = CCRenderLabel:create(GetLocalizeStringBy("llp_50").. desConfig.questMaxNum-MissionData.getFinlishTaskNum() .."/"..desConfig.questMaxNum, g_sFontName,21,1,ccc3( 0x00, 0x00, 0x00), type_stroke)
    pFinishLabel:setColor(ccc3(0xff,0xff,0xff))
    pFinishLabel:setAnchorPoint(ccp(1,1))
    _canDefeatNumBg:addChild(pFinishLabel,10)

    local finishTaskNum = MissionData.getFinlishTaskNum()
    if(tonumber(desConfig.questMaxNum)==tonumber(finishTaskNum))then
        _refreshButton:setVisible(false)
    else
        _refreshButton:setVisible(true)
    end

    csQuality:setPosition(ccp(600,_canDefeatNumBg:getContentSize().height*0.5))
    _canDefeatNumBg:setPosition(ccp(320, _bottomSprite:getContentSize().height-5))
    pUpLabel:setPosition(ccp(10,_canDefeatNumBg:getContentSize().height))
    pNumLabel:setPosition(ccp(10+pUpLabel:getContentSize().width,_canDefeatNumBg:getContentSize().height))
    pStarSprite:setPosition(ccp(10+pUpLabel:getContentSize().width+pNumLabel:getContentSize().width,_canDefeatNumBg:getContentSize().height))
    pRightNumLabel:setPosition(ccp(_canDefeatNumBg:getContentSize().width*0.95,_canDefeatNumBg:getContentSize().height-pMission:getContentSize().height*0.5))
    pRight2NumLabel:setPosition(ccp(_canDefeatNumBg:getContentSize().width*0.95-pRightNumLabel:getContentSize().width,_canDefeatNumBg:getContentSize().height-pMission:getContentSize().height*0.5))
    pMission:setPosition(ccp(_canDefeatNumBg:getContentSize().width*0.95-pRightNumLabel:getContentSize().width-pRight2NumLabel:getContentSize().width,_canDefeatNumBg:getContentSize().height-pMission:getContentSize().height*0.5))
    pYeBack:setPosition(ccp(0, _canDefeatNumBg:getContentSize().height-pUpLabel:getContentSize().height-5))
    pDesLabel:setPosition(ccp(pBack:getContentSize().width,pBack:getContentSize().height-pDesLabel:getContentSize().height))
    pDesDetailLabel:setPosition(ccp(pBack:getContentSize().width+pDesLabel:getContentSize().width,pBack:getContentSize().height-pDesLabel:getContentSize().height))
    pRewardLabel:setPosition(ccp(pBack:getContentSize().width,pBack:getContentSize().height-pDesLabel:getContentSize().height-pRewardLabel:getContentSize().height*1.5))
    item2:setPosition(ccp(640,_canDefeatNumBg:getContentSize().height*0.5))
    pFinishLabel:setPosition(ccp(608,pFinishLabel:getContentSize().height*1.5))
    _refreshButton:setPosition(ccp(320,_canDefeatNumBg:getContentSize().height-8))
end

--createLayer
function createLayer( level,exp )

    init()
    guildLevel = GuildDataCache.getGuildBookLevel()
    guildExp =  GuildDataCache.getGuildDonate()
    _callbackFunc =callbackFunc

    MainScene.setMainSceneViewsVisible(false, false, true)
    _bgLayer= CCLayer:create()
    _bgLayer:registerScriptHandler(onNodeEvent)
    _bgLaystatus= true



    local bulletinLayerSize = BulletinLayer.getLayerContentSize()
    _layerSize= {width=0,height=0}
    _layerSize.width= g_winSize.width
    _layerSize.height= g_winSize.height - (bulletinLayerSize.height)*g_fScaleX
    _bgLayer:setContentSize(CCSizeMake(_layerSize.width, _layerSize.height))


    local bg = CCSprite:create("images/battlemission/backgroud.jpg")
    bg:setScale(g_fBgScaleRatio)
    bg:setAnchorPoint(ccp(0.5, 0))
    bg:setPosition(_layerSize.width/2, 0)
    _bgLayer:addChild(bg)


    createTopUI()
    createBottomSprite()

    MissionService.getTaskInfo(function ()
        _missionTable = MissionData.getTask()
        createDescUI()
        createLeftNum(1)
        setDefalutSelected()
    end)

    return _bgLayer
end

function showLayer( ... )
    if(MissionData.isGuildMissonOpen()) then
        require "script/ui/battlemission/MissionLayer"
        local destinyLayer = MissionLayer.createLayer()
        MainScene.changeLayer(destinyLayer, "MissionLayer")
    else
        --任务大厅需要军团大厅等级达到%d且人物等级达到%d才可进入
        AnimationTip.showTip(string.format(GetLocalizeStringBy("lcy_10043"),MissionData.getLimitHallLevel(), MissionData.getLimitUserLevel()))
    end
end

----------------------------------------[[  更新ui 方法 ]] ----------------------------------------------
function setDefalutSelected( ... )
    for i=1,3 do
        local taskStatus = MissionData.getTaskStatus(i)
        if(tonumber(taskStatus) ~= 0) then
            _nowSelectTaskPos = i
            break
        end
    end
    if(_nowSelectTaskPos == nil) then
        _nowSelectTaskPos = 1
    end
    MenuItemCallFun(_nowSelectTaskPos)
end

--更新ui
function updateUI( ... )
    for i=1,3 do
        if(_bottomArrayBg[i]) then
            _bottomArrayBg[i]:removeFromParentAndCleanup(true)
            _bottomArrayBg[i]= nil
        end
    end
    createMidUi()
    createLeftNum(_nowSelectTaskPos)
end


--------------------------------[[ menuAction and network callback ]]------------------------------------

--返回按钮回调
function backBtnCB( tag, item)
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    require "script/ui/guild/GuildMainLayer"
    bg = nil
    local guildMainLayer = GuildMainLayer.createLayer(false)
    MainScene.changeLayer(guildMainLayer, "guildMainLayer")
end

-- 重置攻打次数回调
function resetAtkTimesDelegate()
    -- _bgLayer:removeFromParentAndCleanup(true)
    -- _bgLayer = nil

    -- local fortInfoLayer = FortInfoLayer.createLayer(curCopyId, curFortId, _progressState, _strongHoldInfo.fight_times)
    -- local runningScene = CCDirector:sharedDirector():getRunningScene()
    -- runningScene:addChild(fortInfoLayer, 99)
end

--前往夺宝回调
function getGift( tag,item )
    -- body
    require "script/ui/treasure/TreasureMainView"
    local treasureLayer = TreasureMainView.create()
    MainScene.changeLayer(treasureLayer,"treasureLayer")
end

--立即前往按钮
function goNow( tag,item )
    if(ItemUtil.isBagFull() == true )then
        return
    end
    require "script/ui/hero/HeroPublicUI"
    if HeroPublicUI.showHeroIsLimitedUI() then

        return
    end
    require "script/model/user/UserModel"
    if( 5 > UserModel.getEnergyValue() )then
        require "script/ui/item/EnergyAlertTip"
        EnergyAlertTip.showTip()
        return
    end
    local des = DB_Corps_quest.getDataById(tonumber(_missionTable[tagCpy+1].id))
    local  tab = string.split(des.completeConditions,",")
    require "script/ui/copy/CopyUtil"


    local doBattleCallback = function ( newData, isVictory, extra_reward, extra_info )
        MissionService.getTaskInfo(function ()
            _missionTable = MissionData.getTask()
            updateUI()
            MenuItemCallFun(_nowSelectTaskPos)
        end)
        if(isVictory == true)then
            DataCache.addDefeatNumByCopyAndFort( tab[1], tab[2], -1 )
        end
    end

    -- 据点信息
    local curCopyId = tab[1]
    local curFortId = tab[2]
    local _strongHoldInfo = DB_Stronghold.getDataById(tonumber(curFortId))


    if(tonumber(des.questType)==4)then
        local haveStrong = CopyUtil.isCopyFortCanDefeat( tab[1], tab[2] )
        if(haveStrong==false)then
            -- AnimationTip.showTip(GetLocalizeStringBy("llp_54"))
            require "script/ui/copy/FortDefeatNUmTip"
            FortDefeatNUmTip.showAlert( curCopyId, curFortId, _strongHoldInfo.fight_times, resetAtkTimesDelegate)
            return
        end
        require "script/battle/BattleLayer"
        local battleLayer = BattleLayer.enterBattle(tab[1], tab[2], 1, doBattleCallback)
    elseif(tonumber(des.questType)==2)then

    else
        require "script/ui/copy/BigMap"
        local fortsLayer = BigMap.createFortsLayout()
        MainScene.changeLayer(fortsLayer, "BigMap")
    end
end

--身体点击回调
function MenuItemCallFun(tag,item)
    _nowSelectTaskPos = tag
    tagCpy = tag-1
    CityData.setMissionId(tonumber(_missionTable[tag].id))
    local id = tonumber(_missionTable[tag].id)
    local des = DB_Corps_quest.getDataById(id)
    updateUI()

    if(_talkbg~=nil)then
        _bottomArrayBg[_nowSelectTaskPos]:removeChildByTag(kTalkDialogTag, true)
        _talkbg = nil
    end
    _talkbg = CCSprite:create("images/battlemission/talkbg.png")
    _talkbg:setPosition(ccp(0,200))
    _bottomArrayBg[_nowSelectTaskPos]:addChild(_talkbg,1,kTalkDialogTag)


    local label = CCRenderLabel:createWithAlign(des.heroTalk, g_sFontName,18,1,ccc3( 0x00, 0x00, 0x00) ,type_stroke,CCSizeMake(129, 42) ,kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
    label:setPosition(ccp(7,_talkbg:getContentSize().height-10 ))
    _talkbg:addChild(label,1,tag)


    local sp = CCSprite:create("images/battlemission/standbig.png")
    _bgLayer:getChildByTag(tag):setTexture(sp:getTexture())
    for i=1,3 do
        if(i~=tonumber(tag))then
            local spSmall = CCSprite:create("images/battlemission/stand.png")
            _bgLayer:getChildByTag(i):setTexture(spSmall:getTexture())
        end
    end
end


--选择物品列表回调
function treasureChooseCallback( p_chooseItems )
    local requestCallback = function( cbFlag, dictData, bRet )
        _missionTable = MissionData.getTask()
        updateUI()
        MenuItemCallFun(_nowSelectTaskPos)
    end
    local itemIds = {}
    for k,v in pairs(p_chooseItems) do
        table.insert(itemIds, v.item_id)
        _handInItemTid = v.itemDesc.id
    end
    printTable("p_chooseItems", p_chooseItems)
    printTable("itemIds", itemIds)
    MissionService.handIn(_nowSelectTaskPos -1,
                          MissionData.getTaskIdbyPos(_nowSelectTaskPos),
                          itemIds,
                          requestCallback)
end

--选择贡献物品
function chooseItem( tag,item )
    local des         = DB_Corps_quest.getDataById(tonumber(_missionTable[tagCpy+1].id))
    local tab         = string.split(des.completeConditions,",")
    local itemQuality = tab[2]
    local itemType    = tab[1]
    local itemCount   = tab[3]
    if(tonumber(des.questType)==1)then
        require "script/ui/battlemission/EquipMissionLayer"
        local equipMissionLayer = EquipMissionLayer.createLayer(itemType, itemQuality, itemCount, treasureChooseCallback, -350)
        _bgLayer:addChild(equipMissionLayer, 350)
    else
        require "script/ui/battlemission/GoodMissionLayer"
        local equipMissionLayer = GoodMissionLayer.createLayer(itemType, itemQuality, itemCount, treasureChooseCallback, -350)
        _bgLayer:addChild(equipMissionLayer, 350)
    end
end

--确认刷新弹板
function surFreshTip(tag,item )
    -- body
    local haveHighStar = false
    for i=1,3 do
        local menu = CCMenu:create()
        menu:setPosition(ccp(0,0))
        local id = tonumber(_missionTable[i].id)
        local des = DB_Corps_quest.getDataById(id)
        if(tonumber(des.questStar)>=4)then
            haveHighStar = true
            require "script/ui/tip/AlertTip"
            local giveUp = function(is_confirmed, arg)
                if is_confirmed == true then
                    freshFun()
                end
                AlertTip.closeAction()
            end
            AlertTip.showAlert(GetLocalizeStringBy("llp_95"), giveUp, true, nil)
            break
        end
    end
    if(haveHighStar == false)then
        freshFun()
    end

end

--刷新全部
function freshFun()
    local  desConfig = DB_Corps_quest_config.getDataById(1)
    if desConfig.refreshPay > UserModel.getGoldNumber() then
        require "script/ui/tip/SingleTip"
        SingleTip.showTip(GetLocalizeStringBy("key_2376"))
        return
    end

    local function callBack(  )
        _missionTable= MissionData.getTask()
        updateUI()
        _goldLabel:setString("" .. MissionData.getRfcGold())
        MenuItemCallFun(_nowSelectTaskPos)
    end
    MissionService.refTask(callBack )
end

-- 完成的回调函数
function doneTaskCallback( tag, sender )
    local questReward = ItemUtil.getItemsDataByStrForTask( MissionData.getTaskReward(_nowSelectTaskPos))
    local  requestCallBack = function( ... )
        _missionTable= MissionData.getTask()
        updateUI()
        MenuItemCallFun(_nowSelectTaskPos)
        ReceiveReward.showRewardWindow(questReward, nil , 1008, -800 )
        _handInItemTid = nil
    end
    if( tonumber(_missionTable[_nowSelectTaskPos].status)==1) then
        MissionService.doneTask(_nowSelectTaskPos -1, MissionData.getTaskIdbyPos(_nowSelectTaskPos), 0, requestCallBack)
    else
        AnimationTip.showTip(GetLocalizeStringBy("llp_51"))
    end
end


--立即完成回调函数
function doneTaskByGoldCallback( tag,item )

    local questReward = ItemUtil.getItemsDataByStrForTask( MissionData.getTaskReward(_nowSelectTaskPos))
    local spendGold = MissionData.getCompleteTaskGoldByPos(_nowSelectTaskPos)

    if(spendGold > UserModel.getGoldNumber()) then
        AnimationTip.showTip(GetLocalizeStringBy("key_1092"))
        return
    end
    printTable("questReward",questReward)

    local  requestCallBack = function( ... )
        _missionTable= MissionData.getTask()
        updateUI()
        MenuItemCallFun(_nowSelectTaskPos)
        ReceiveReward.showRewardWindow(questReward, nil , 1008, -800 )
        _handInItemTid = nil
    end
    if( tonumber(_missionTable[tag].status)==1) then
        MissionService.doneTask( _nowSelectTaskPos -1, MissionData.getTaskIdbyPos(_nowSelectTaskPos), 1, requestCallBack)
    else
        AnimationTip.showTip(GetLocalizeStringBy("llp_51"))
    end
end


--接受任务
function acceptTaskCallback(tag,item)
    local  desConfig = DB_Corps_quest_config.getDataById(1)
    local  taskNumber =tonumber( MissionData.getFinlishTaskNum() )
    local questionMaxNum= tonumber(desConfig.questMaxNum)

    if(taskNumber>= questionMaxNum ) then
        AnimationTip.showTip(GetLocalizeStringBy("llp_52"))
        return
    end

    for i=1,3 do
        if(tonumber(_missionTable[i].status)==1)then
            require "script/ui/tip/AlertTip"
            AlertTip.showAlert(GetLocalizeStringBy("llp_53"), nil, false, nil)
            return
        end
    end
    local requestCallback = function( )
        _missionTable = MissionData.getTask()
        print_table("_missionTable", _missionTable)
        updateUI()
        MenuItemCallFun(_nowSelectTaskPos)
    end
    MissionService.acceptTask(_nowSelectTaskPos -1, MissionData.getTaskIdbyPos(_nowSelectTaskPos), requestCallback)
end


--放弃任务
function forgiveTaskCallback( tag,item )
    local requestCallback = function( cbFlag, dictData, bRet )
        _missionTable[tagCpy+1].num = 0
        _missionTable = MissionData.getTask()
        updateUI()
        MenuItemCallFun(_nowSelectTaskPos)
    end
    MissionService.forgiveTask(_nowSelectTaskPos -1, MissionData.getTaskIdbyPos(_nowSelectTaskPos), requestCallback)
end




