-- Filename: WheelRankLayer.lua
-- Author: DJN
-- Date: 2015-3-31
-- Purpose: 积分轮盘排行

module("WheelRankLayer", package.seeall)
require "script/audio/AudioUtil"
require "script/ui/rechargeActive/scoreWheel/WheelRankTableView"
require "script/libs/LuaCCLabel"
require "script/ui/tip/AnimationTip"
require "script/ui/item/ItemUtil"
require "script/ui/item/ReceiveReward"


local _touchPriority    --触摸优先级
local _ZOrder           --Z轴
local _bgLayer          --触摸屏蔽层
local _curMenuItem      --排行榜、排行奖励、关闭 的索引
local _curMenuTag       --按钮索引的tag
local _RankTag   = 101  --排行榜的tag
local _RewardTag = 102  --排行奖励的tag
local _preViewLayer     --TableView
local _bgSprite         --大背景素材
local _MenuLayer        --底部按钮的menu（因为要刷新）
local _gotTag = 201     --按钮标签 已领取 用于回调时判断
local _receiveTag = 202 --按钮标签 可领取 用于回调时判断
local _scoreLimitTag = 203 --按钮标签 积分不够 用于回调时判断
--local _serverTag        --记录当前是服内还是跨服的tag 1:服内 2:跨服

----------------------------------------初始化函数----------------------------------------
local function init()
    _touchPriority = nil
    _ZOrder = nil
    _bgLayer = nil
    _curMenuTag = 101
    _curMenuItem = nil
    _preViewLayer = nil
    _bgSprite = nil
    _MenuLayer = nil
    --_serverTag = nil 
end

----------------------------------------触摸事件函数----------------------------------------
local function onTouchesHandler(eventType,x,y)
    if (eventType == "began") then
        return true
    elseif (eventType == "moved") then
        --print("moved")
    else
        --print("end")
    end
end

local function onNodeEvent(event)
    if event == "enter" then
        _bgLayer:registerScriptTouchHandler(onTouchesHandler, false, _touchPriority, true)
        _bgLayer:setTouchEnabled(true)
    elseif event == "exit" then
        _bgLayer:unregisterScriptTouchHandler()
    end
end
----------------------------------------回调函数----------------------------------------
-- function receiveCallBack( tag,item )
--     AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
--     require "script/ui/item/ItemUtil"
--     print("点击的按钮的tag",tag)
--     if(tag == _gotTag)then
--         return
--     elseif(tag == _scoreLimitTag)then
--         --提示积分不足
--         AnimationTip.showTip(GetLocalizeStringBy("djn_147"))
--     elseif(tag == _receiveTag)then
--         --可以领取啦
--         --判断一下是否是在活动的最后一小时 策划新规 在活动的最后一小时不可以手动领取 推到领奖中心领取
--         if(ScoreWheelData.isInLastOneHour())then
--             AnimationTip.showTip(GetLocalizeStringBy("djn_171"))
--             return
--         end
--          --判断背包
--         if (ScoreWheelData.isAllBagFull())then
--             --背包满，不做操作，给提示
--             _bgLayer:removeFromParentAndCleanup(true)
--             _bgLayer = nil
--         else
--             --为了防止玩家持有排行界面 跨越了转盘器和领奖期 而出现前缓存不准确的问题 在领奖的时候 拉一次排行数据 确保前端的领奖排名为最新
            
--             local getRankCb = function ( ... )
--                 ScoreWheelService.getRankReward(receiveRewardCb)
--             end
--             ScoreWheelService.getRankInfo(getRankCb)
--         end
--     end
-- end

-- ------领取排行奖励后的回调
-- function receiveRewardCb( ... )
--     -- body
--     --修改缓存领奖状态
--     ScoreWheelData.setIsReceived(1)
--     --发奖
--     --local infoForReward = {}
--         --table.insert(infoForReward,ScoreWheelData.getMyReward())
--         local infoForReward = ItemUtil.getItemsDataByStr(ScoreWheelData.getMyReward())
--         print("infoForReward") 
--         print_t(infoForReward)
--         ItemUtil.addRewardByTable(infoForReward)
--     --恭喜获得****
--         ReceiveReward.showRewardWindow(infoForReward,refreshButton,_ZOrder+2,
--                                     _touchPriority-20)
-- end
----------------------------------------UI函数----------------------------------------
--[[
    @des    :创建背景UI
    @param  :
    @return :
--]]
function createBgUI()
    require "script/ui/main/MainScene"
    local bgSize = CCSizeMake(620,800)
    local bgScale = MainScene.elementScale

    --主背景图
    _bgSprite = CCScale9Sprite:create("images/common/viewbg1.png")
    _bgSprite:setContentSize(CCSizeMake(bgSize.width,bgSize.height))
    _bgSprite:setAnchorPoint(ccp(0.5,0.5))
    _bgSprite:setPosition(ccp(_bgLayer:getContentSize().width/2,_bgLayer:getContentSize().height/2))
    _bgSprite:setScale(bgScale)
    _bgLayer:addChild(_bgSprite)

    --顶部花篮
    local titleSp = CCSprite:create("images/recharge/score_wheel/title_bg.png")
    titleSp:setAnchorPoint(ccp(0.5,0))
    titleSp:setPosition(ccpsprite(0.5,0.95,_bgSprite))
    _bgSprite:addChild(titleSp)

    local titleStr = CCSprite:create("images/recharge/score_wheel/title_str.png")
    titleStr:setAnchorPoint(ccp(0.5,0.5))
    titleStr:setPosition(ccpsprite(0.5,0.6,titleSp))
    titleSp:addChild(titleStr)
    --个人排名
    local myRank = ScoreWheelData.getPersonRank()
   -- print("myRank",myRank)
    require "script/model/user/UserModel"
    local _,kuafu_num = ScoreWheelData.getKuafuStateAndNum()
    if(tonumber(myRank) == 0 or tonumber(myRank) > 20*kuafu_num)then
        myRank = GetLocalizeStringBy("key_1054")
    end
    local richInfo = {elements = {},alignment = 2}
        richInfo.elements[1] = {
                type = "CCSprite",
                image = "images/recharge/score_wheel/rank_str.png"}
        richInfo.elements[2] = {
                ["type"] = "CCLabelTTF", 
                text = "  "..myRank,
                font = g_sFontName,
                size = 25,
                color = ccc3(0x78,0x25,0x00)}
    local midSp = LuaCCLabel.createRichLabel(richInfo)
    midSp:setAnchorPoint(ccp(0.5,1))
    midSp:setPosition(ccpsprite(0.5,0.93,_bgSprite))
    _bgSprite:addChild(midSp,999)

    --二级背景
    local brownSprite = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
    brownSprite:setContentSize(CCSizeMake(575,505))
    brownSprite:setAnchorPoint(ccp(0.5,0.5))
    brownSprite:setPosition(ccp(_bgSprite:getContentSize().width/2,_bgSprite:getContentSize().height*0.5))
    _bgSprite:addChild(brownSprite)

    --背景按钮层
    local bgMenu = CCMenu:create()
    bgMenu:setPosition(ccp(0,0))
    bgMenu:setTouchPriority(_touchPriority-2)
    _bgSprite:addChild(bgMenu)
    
    --排行榜按钮
    --local fullRect = CCRectMake(0,0,73,53)
    local insertRect = CCRectMake(35,20,1,1)
    local btnMenuN_Rank = CCScale9Sprite:create(insertRect,"images/common/btn/tab_button/btn1_n.png")
    btnMenuN_Rank:setPreferredSize(CCSizeMake(211,43))
    local btnMenuH_Rank = CCScale9Sprite:create(insertRect,"images/common/btn/tab_button/btn1_h.png")
    btnMenuH_Rank:setPreferredSize(CCSizeMake(211,53))
   
    local RankMenuItem = CCMenuItemSprite:create(btnMenuN_Rank, nil,btnMenuH_Rank)
    RankMenuItem:setPosition(ccp(_bgSprite:getContentSize().width*0.45,brownSprite:getContentSize().height*0.5+brownSprite:getPositionY()))
    RankMenuItem:setAnchorPoint(ccp(1,0))
    RankMenuItem:registerScriptTapHandler(menuCallBack)
    bgMenu:addChild(RankMenuItem,1,_RankTag)
    RankMenuItem:setEnabled(false)
    --设置排行榜按钮为默认选中的button
    _curMenuItem = RankMenuItem
    _curMenuTag = _RankTag


    --"积分排行"的字 根据是否被点击的状态创建两种字
    local labelRank_N = CCLabelTTF:create(GetLocalizeStringBy("djn_159"), g_sFontPangWa, 25)
    labelRank_N:setColor(ccc3(0xf4,0xdf,0xcb))
    labelRank_N:setAnchorPoint(ccp(0.5,0.5))
    labelRank_N:setPosition(ccp(btnMenuN_Rank:getContentSize().width*0.5,btnMenuN_Rank:getContentSize().height*0.5))
    btnMenuN_Rank:addChild(labelRank_N)

    local labelRank_H = CCRenderLabel:create(GetLocalizeStringBy("djn_159"),g_sFontPangWa , 28, 1 ,ccc3(0x00,0x00,0x00), type_stroke)
    labelRank_H:setColor(ccc3(0xff,0xff,0xff))
    labelRank_H:setAnchorPoint(ccp(0.5,0.5))
    labelRank_H:setPosition(ccp(btnMenuH_Rank:getContentSize().width*0.5,btnMenuH_Rank:getContentSize().height*0.5-2))
    btnMenuH_Rank:addChild(labelRank_H)

   
    --排行奖励按钮 
    local btnMenuN_Reward = CCScale9Sprite:create(insertRect,"images/common/btn/tab_button/btn1_n.png")
    btnMenuN_Reward:setPreferredSize(CCSizeMake(211,43))
    local btnMenuH_Reward = CCScale9Sprite:create(insertRect,"images/common/btn/tab_button/btn1_h.png")
    btnMenuH_Reward:setPreferredSize(CCSizeMake(211,53))
    local RewardMenuItem = CCMenuItemSprite:create(btnMenuN_Reward, nil,btnMenuH_Reward)
    RewardMenuItem:setPosition(ccp(RankMenuItem:getPositionX()+33 ,brownSprite:getContentSize().height*0.5+brownSprite:getPositionY()))
    RewardMenuItem:setAnchorPoint(ccp(0,0))
    
    RewardMenuItem:registerScriptTapHandler(menuCallBack)
    bgMenu:addChild(RewardMenuItem,1,_RewardTag)

    --"排行奖励"的字 根据是否被点击的状态创建两种字
    local labelReward_N = CCLabelTTF:create(GetLocalizeStringBy("djn_160"), g_sFontPangWa, 25)
    labelReward_N:setColor(ccc3(0xf4,0xdf,0xcb))
    labelReward_N:setAnchorPoint(ccp(0.5,0.5))
    labelReward_N:setPosition(ccp(btnMenuN_Reward:getContentSize().width*0.5,btnMenuN_Reward:getContentSize().height*0.5))
    btnMenuN_Reward:addChild(labelReward_N)

    local labelReward_H = CCRenderLabel:create(GetLocalizeStringBy("djn_160"),g_sFontPangWa , 28, 1 ,ccc3(0x00,0x00,0x00), type_stroke)
    labelReward_H:setColor(ccc3(0xff,0xff,0xff))
    labelReward_H:setAnchorPoint(ccp(0.5,0.5))
    labelReward_H:setPosition(ccp(btnMenuH_Reward:getContentSize().width*0.5,btnMenuH_Reward:getContentSize().height*0.5-2))
    btnMenuH_Reward:addChild(labelReward_H)

    --介绍得到多少积分才能领奖
    if(ScoreWheelData.getMinScoreForReward() ~= 0)then
        local scoreLimitLabel = CCLabelTTF:create(GetLocalizeStringBy("djn_162",ScoreWheelData.getMinScoreForReward()),g_sFontName,21)
        scoreLimitLabel:setColor(ccc3(0x78,0x25,0x00))
        scoreLimitLabel:setAnchorPoint(ccp(0.5,0))
        scoreLimitLabel:setPosition(ccpsprite(0.5,0.155,_bgSprite))
        _bgSprite:addChild(scoreLimitLabel)
        local desLabel = CCLabelTTF:create(GetLocalizeStringBy("djn_163"),g_sFontName,21)
        desLabel:setColor(ccc3(0x00,0x6d,0x2f))
        desLabel:setAnchorPoint(ccp(0.5,1))
        desLabel:setPosition(ccpsprite(0.5,0.15,_bgSprite))
        _bgSprite:addChild(desLabel)
    end

    --刷新下方按钮
    refreshButton()

    --默认进入时展示积分排行
    _preViewLayer = WheelRankTableView.createTableView(_curMenuTag)
    _preViewLayer:setAnchorPoint(ccp(0,0))
    _preViewLayer:setPosition(ccp(0,2))
    _preViewLayer:setTouchPriority(_touchPriority-1)
    brownSprite:addChild(_preViewLayer)
     
   
end
function refreshButton( ... )
    if(_MenuLayer ~= nil)then
        _MenuLayer:removeFromParentAndCleanup(true)
        _MenuLayer = nil
    end
    --按钮层
    _MenuLayer = CCMenu:create()
    _MenuLayer:setPosition(ccp(0,0))
    _MenuLayer:setTouchPriority(_touchPriority-2)
    _bgSprite:addChild(_MenuLayer)
    local getCloseBtn = function ( ... )
        return LuaCC.create9ScaleMenuItem("images/common/btn/btn_green_n.png","images/common/btn/btn_green_h.png",
                CCSizeMake(200, 71),GetLocalizeStringBy("key_1284"),ccc3(0xff, 0xf6, 0x00),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    end
    local closeMenuItem = getCloseBtn()
    closeMenuItem:setPosition(ccpsprite(0.5,0.03,_bgSprite))
    closeMenuItem:setAnchorPoint(ccp(0.5,0))
    closeMenuItem:registerScriptTapHandler(closeCallBack)
    _MenuLayer:addChild(closeMenuItem)
    -- if(ScoreWheelData.isInWheel())then
    --     --在转盘期，只有关闭按钮
    --     --关闭按钮
    --     local closeMenuItem = getCloseBtn()
    --     closeMenuItem:setPosition(ccpsprite(0.5,0.03,_bgSprite))
    --     closeMenuItem:setAnchorPoint(ccp(0.5,0))
    --     closeMenuItem:registerScriptTapHandler(closeCallBack)
    --     _MenuLayer:addChild(closeMenuItem)
    -- else 
    --     --在领奖期，上榜的人有领奖按钮， 没上榜的人只有关闭按钮
    --     if(ScoreWheelData.ifInRank() == false)then
    --         --关闭按钮
    --         local closeMenuItem =  getCloseBtn()
    --         closeMenuItem:setPosition(ccpsprite(0.5,0.08,_bgSprite))
    --         closeMenuItem:setAnchorPoint(ccp(0.5,0.5))
    --         closeMenuItem:registerScriptTapHandler(closeCallBack)
    --         _MenuLayer:addChild(closeMenuItem)
    --     elseif(ScoreWheelData.ifGotReward())then
    --         --上榜了，但是已经领取过了
    --         --已领取按钮和关闭按钮
    --         local closeMenuItem =  getCloseBtn()
    --         closeMenuItem:setPosition(ccpsprite(0.25,0.08,_bgSprite))
    --         closeMenuItem:setAnchorPoint(ccp(0.5,0.5))
    --         closeMenuItem:registerScriptTapHandler(closeCallBack)
    --         _MenuLayer:addChild(closeMenuItem)

    --         local gotMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_hui.png","images/common/btn/btn_hui.png",
    --                             CCSizeMake(200, 61),GetLocalizeStringBy("key_1369"),ccc3(0x7f,0x7f,0x7f),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    --         gotMenuItem:setAnchorPoint(ccp(0.5,0.5))
    --         gotMenuItem:setPosition(ccpsprite(0.75,0.08,_bgSprite))
    --         gotMenuItem:registerScriptTapHandler(receiveCallBack)
    --         _MenuLayer:addChild(gotMenuItem,1,_gotTag)
    --     else
    --         --上榜了，还没领取过
    --         --领奖按钮和关闭按钮
    --         local closeMenuItem =  getCloseBtn()
    --         closeMenuItem:setPosition(ccpsprite(0.25,0.08,_bgSprite))
    --         closeMenuItem:setAnchorPoint(ccp(0.25,0.5))
    --         closeMenuItem:registerScriptTapHandler(closeCallBack)
    --         _MenuLayer:addChild(closeMenuItem)

    --         local gotMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_bg_h.png","images/common/btn/btn_bg_n.png",
    --                             CCSizeMake(200, 61),GetLocalizeStringBy("key_2233"),ccc3(0xff, 0xf6, 0x00),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    --         gotMenuItem:setAnchorPoint(ccp(0.5,0.5))
    --         gotMenuItem:setPosition(ccpsprite(0.75,0.08,_bgSprite))
    --         gotMenuItem:registerScriptTapHandler(receiveCallBack)
    --         if(ScoreWheelData.isScoreEnhough())then
    --             _MenuLayer:addChild(gotMenuItem,1,_receiveTag)
    --         else
    --             _MenuLayer:addChild(gotMenuItem,1,_scoreLimitTag)
    --         end

    --     end
    -- end
end
----------------------------------------回调函数----------------------------------------
--[[
    @des    :关闭回调
    @param  :
    @return :
--]]
function closeCallBack()
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    _bgLayer:removeFromParentAndCleanup(true)
    _bgLayer = nil
end
----------------------------------------回调函数----------------------------------------
--[[
    @des    :Menu回调
    @param  :
    @return :
--]]

function menuCallBack(tag, item )
    AudioUtil.playEffect("audio/effect/changtiaoxing.mp3")
    require "script/ui/tip/AnimationTip"
    _curMenuItem:setEnabled(true)
   -- _curMenuItem:unselected()
    item:setEnabled(false)
    _curMenuItem= item

    if(_curMenuTag == tag) then
        return
    else
        _curMenuTag = tag
    end

    WheelRankTableView.setStage(_curMenuTag)
    WheelRankTableView.setTableInfo(_curMenuTag)
    _preViewLayer:reloadData()
  
   
end

----------------------------------------入口函数----------------------------------------
function showLayer(p_touchPriority,p_ZOrder)
    init()
    _touchPriority = p_touchPriority or -550
    _ZOrder = p_ZOrder or 999
    --绿色触摸屏蔽层
    _bgLayer = CCLayerColor:create(ccc4(0x00,0x2e,0x49,153))
    _bgLayer:registerScriptHandler(onNodeEvent)
    local curScene = CCDirector:sharedDirector():getRunningScene()
    curScene:addChild(_bgLayer,_ZOrder) 
    --创建背景UI
    createBgUI()

   
end
--[[
    @des    :获得触摸优先级
    @param  :
    @return :触摸优先级
--]]
function getTouchPriority()
    return _touchPriority
end
--[[
    @des    :获得Z轴
    @param  :
    @return :
--]]
function getZOrder()
    return _ZOrder
end