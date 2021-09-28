-- FileName: SingleRechargeCell.lua 
-- Author: fuqiongqiong
-- Date: 2016-3-7
-- Purpose: 单充回馈cell

module("SingleRechargeCell",package.seeall)
require "script/ui/rechargeActive/singleRecharge/SignleRechargeController"
require "script/ui/rechargeActive/singleRecharge/SignleRechargeData"
-- require "script/ui/shop/RechargeLayer"
local _whiteBg = nil
local _touchPriority = nil
function create( tCellInfo ,p_index,p_touchPriority)
    _touchPriorit = p_touchPriority
	local cell = CCTableViewCell:create()
	--cell背景
	local fullRect = CCRectMake(0,0,116,124)
    local insetRect = CCRectMake(52,44,6,4)
	local bg = CCScale9Sprite:create("images/common/bg/change_bg.png",fullRect, insetRect)
	bg:setPreferredSize(CCSizeMake(615,195))
	cell:addChild(bg)
	-- 标题背景
    local titleBg = CCScale9Sprite:create("images/sign/sign_bottom.png")
    titleBg:setContentSize(CCSizeMake(270,60))
    titleBg:setAnchorPoint(ccp(0,1))
    titleBg:setPosition(ccp(0,bg:getContentSize().height+10))
    bg:addChild(titleBg)
    local titleBgSize = titleBg:getContentSize()
    -- 标题文本
    local  titleLabel = CCRenderLabel:create(tCellInfo.activityExplain,g_sFontPangWa,25,1,ccc3(0x00,0x00,0x00),type_stroke) 
    titleLabel:setColor(ccc3(0xff,0xff,0xff))
    titleLabel:setAnchorPoint(ccp(0.5,0.5))
    titleLabel:setPosition(titleBgSize.width / 2,titleBgSize.height / 2)
    titleBg:addChild(titleLabel)

    _whiteBg = CCScale9Sprite:create("images/common/bg/goods_bg.png")
	_whiteBg:setContentSize(CCSizeMake(437,125))
	_whiteBg:setAnchorPoint(ccp(0,1))
	_whiteBg:setPosition(ccp(20,145))
	bg:addChild(_whiteBg)
    createScrollView(tCellInfo)
   --剩余次数
   local allTimes = tonumber(tCellInfo.daytimes)
    local remainTimes = allTimes - SignleRechargeData.getallredayRechargeNum(tonumber(tCellInfo.id))
    local lableDes = CCLabelTTF:create(GetLocalizeStringBy("key_2242"),g_sFontName,21)
    lableDes:setColor(ccc3(0x78,0x28,0x00))
    lableDes:setAnchorPoint(ccp(0,1))
    lableDes:setPosition(ccp(_whiteBg:getPositionX()+_whiteBg:getContentSize().width*0.93,bg:getContentSize().height-15))
    bg:addChild(lableDes)

    local remainTimesLabel = CCLabelTTF:create(remainTimes,g_sFontName,21)
    remainTimesLabel:setColor(ccc3(0x75,0x28,0x00))
    remainTimesLabel:setAnchorPoint(ccp(0,0.5))
    remainTimesLabel:setPosition(ccp(lableDes:getContentSize().width,lableDes:getContentSize().height*0.5))
    lableDes:addChild(remainTimesLabel)

    local allTimesLabel = CCLabelTTF:create("/"..allTimes,g_sFontName,21)
    allTimesLabel:setColor(ccc3(0x75,0x28,0x00))
    allTimesLabel:setAnchorPoint(ccp(0,0.5))
    allTimesLabel:setPosition(ccp(lableDes:getContentSize().width+remainTimesLabel:getContentSize().width+5,lableDes:getContentSize().height*0.5))
    lableDes:addChild(allTimesLabel)
    --判断是去充值还是领取
    local getOrRecharge = SignleRechargeData.getOrRecharge(tCellInfo.id)
    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    bg:addChild(menu)
    menu:setTouchPriority(_touchPriorit)
   
    if(getOrRecharge)then
        --领取 
        -- local btn = LuaCC.create9ScaleMenuItem("images/level_reward/receive_btn_n.png","images/level_reward/receive_btn_h.png",CCSizeMake(130, 80),GetLocalizeStringBy("fqq_062"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
        -- btn:setAnchorPoint(ccp(1,0.5))
        -- btn:setPosition(ccp(bg:getContentSize().width-15,bg:getContentSize().height*0.5))
        -- btn:registerScriptTapHandler(getCallBack)
        -- menu:addChild(btn,1,tonumber(tCellInfo.id))

        local bNeedSelected = SignleRechargeData.isRewardForSelected(tCellInfo.id)   --是否需要选择
        local btn = nil
        if bNeedSelected then
            btn = LuaCC.create9ScaleMenuItem("images/recharge/rechargegift/receive_btn_n.png","images/recharge/rechargegift/receive_btn_h.png",CCSizeMake(130, 83),GetLocalizeStringBy("fqq_062"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
        else
            btn = LuaCC.create9ScaleMenuItem("images/level_reward/receive_btn_n.png","images/level_reward/receive_btn_h.png",CCSizeMake(130, 83),GetLocalizeStringBy("fqq_062"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
        end
        btn:setAnchorPoint(ccp(1,0.5))
        btn:setPosition(ccp(bg:getContentSize().width-15,bg:getContentSize().height*0.5))
        btn:registerScriptTapHandler(getCallBack)
        menu:addChild(btn,1,tonumber(tCellInfo.id))
    
    else 
        --去充值
        local normalSprite  = CCSprite:create("images/level_reward/anniu_n.png")
        local selectSprite  = CCSprite:create("images/level_reward/anniu_h.png")
        local disabledSprite = BTGraySprite:create("images/level_reward/anniu_n.png")
        local btn = CCMenuItemSprite:create(normalSprite,selectSprite,disabledSprite)
        btn:setAnchorPoint(ccp(1,0.5))
        btn:setPosition(ccp(bg:getContentSize().width-15,bg:getContentSize().height*0.5))
        btn:registerScriptTapHandler(rechargecallBcak)
        menu:addChild(btn,1,tonumber(tCellInfo.id))
        local des = CCRenderLabel:create(GetLocalizeStringBy("fqq_061"),g_sFontPangWa,30,1,ccc3(0x00, 0x00, 0x00),type_stroke)
        des:setColor(ccc3(0xfe, 0xdb, 0x1c))
        des:setAnchorPoint(ccp(0.5,0.5))
        des:setPosition(ccp(btn:getContentSize().width*0.5,btn:getContentSize().height*0.5))
        btn:addChild(des)
        --判断剩余次数，若为0，按钮变灰，不可点击
         if(remainTimes == 0)then
            -- des:setColor(ccc3(0xff,0xff,0xff))
            btn:setVisible(false)
            local receive_alreadySp = CCSprite:create("images/sign/receive_already.png")
            receive_alreadySp:setPosition(ccp(bg:getContentSize().width-15,bg:getContentSize().height*0.5))
            receive_alreadySp:setAnchorPoint(ccp(1,0.5))
            bg:addChild(receive_alreadySp)
         end
    end

    return cell
end
--[[
    @des    :创建奖励scrollview
    @param  :
    @return :
--]]
function createScrollView( tCellInfo )

    local scrollView = CCScrollView:create()
    scrollView:setContentSize(CCSizeMake(_whiteBg:getContentSize().width, _whiteBg:getContentSize().height))
    scrollView:setViewSize(CCSizeMake(_whiteBg:getContentSize().width, _whiteBg:getContentSize().height))
    scrollView:ignoreAnchorPointForPosition(false)
    scrollView:setAnchorPoint(ccp(0.5,0.5))
    scrollView:setPosition(ccp(_whiteBg:getContentSize().width*0.5,_whiteBg:getContentSize().height *0.5))
    scrollView:setTouchPriority(_touchPriorit)
    scrollView:setDirection(kCCScrollViewDirectionHorizontal)
    _whiteBg:addChild(scrollView)
    local data = SignleRechargeData.getRewardArray(tonumber(tCellInfo.id))
    local bNeedSelected = SignleRechargeData.isRewardForSelected(tonumber(tCellInfo.id))    --是否是N选1
    local nCount, nSpace = table.count(data), bNeedSelected == true and 48 or 25
    for k,v in pairs(data) do
        local rewardInDb = ItemUtil.getItemsDataByStr(data[k])
        local icon,itemName,itemColor = ItemUtil.createGoodsIcon(rewardInDb[1], -400, 800, -500,function ( ... )
        end,nil,nil,false)
        -- icon:setPosition(ccp(25*k+(k-1)*icon:getContentSize().width,25))
        icon:setPosition(25+(k-1)*(icon:getContentSize().width+nSpace),25)
        scrollView:addChild(icon)
        local nameLabel = CCRenderLabel:create(itemName, g_sFontName,20,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
        icon:addChild(nameLabel)
        nameLabel:setAnchorPoint(ccp(0.5,1))
        nameLabel:setColor(itemColor)
        nameLabel:setPosition(ccp(icon:getContentSize().width*0.57,0)) 

        if bNeedSelected and k < nCount then
            local spOr = CCSprite:create("images/recharge/or.png")
            spOr:setPosition(icon:getContentSize().width + 5, icon:getContentSize().height*0.5 - 18)
            icon:addChild(spOr)
        end
    end 
end
--充值回调
function rechargecallBcak(tag,item )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    local isActiveOver = SignleRechargeData.isActiveOver()
    --如果活动结束
    if(isActiveOver)then
        require "script/ui/tip/AnimationTip"
        AnimationTip.showTip(GetLocalizeStringBy("fqq_063"))
        return
     end
    local layer = RechargeLayer.createLayer()
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(layer,1111)
   
end

--领取回调
function getCallBack( tag,item)
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    local isActiveOver = SignleRechargeData.isActiveOver()
    --如果活动结束
    if(isActiveOver)then
        require "script/ui/tip/AnimationTip"
        AnimationTip.showTip(GetLocalizeStringBy("fqq_064"))
        return
    end

    local bNeedSelected = SignleRechargeData.isRewardForSelected(tag)   --是否需要对奖励进行多选一
    if bNeedSelected then
        -- 弹出奖励选择面板  玩家进行选择
        local tbRewardConfig = SignleRechargeData.getRewardInfoById(tag)
        local sRewardStr = (tbRewardConfig == nil or tbRewardConfig.payReward == nil) and "" or tbRewardConfig.payReward

        UseGiftLayer.showTipLayer(nil, sRewardStr, function( rewardIdx )
            -- SignleRechargeController.obtainReward(tonumber(pRewardData.id),rewardId,nil)
            print("getCallBack reward index: ", rewardIdx)
            SignleRechargeController.gainReward(tag, rewardIdx)
        end)
    else
        -- 直接领取
        SignleRechargeController.gainReward(tag, 0)
    end
end
