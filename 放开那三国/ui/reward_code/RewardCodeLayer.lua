-- Filename: RewardCodeLayer.lua
-- Author: zhz
-- Date: 2013-09-09
-- Purpose: 该文件用于:礼包兑换


module ("RewardCodeLayer", package.seeall)


require "script/utils/LuaUtil"
require "script/ui/tip/AnimationTip"
require "script/network/RequestCenter"
require "script/audio/AudioUtil"

local _bgLayer 				-- 灰色的layer

local _itemData				-- 物品的本地属性信息
local _numberEditBox        -- 礼品兑换码

local function init( )
	_bgLayer = nil
	_numberEditBox = nil
end

-- layer 的回调函数
local function layerToucCb(eventType, x, y)
	return true
end

-- 关闭按钮的回调函数
local function closeCb()
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
end

-- 网络reward_getGiftByCode函数的回调函数
local function getGiftByCodeAction( cbFlag, dictData, bRet )
    if(dictData.err ~= "ok" ) then 
        return 
    end
    print("dictData.ret is : ", dictData.ret.ret)
    if(tonumber(dictData.ret.ret) == 0 ) then
        AnimationTip.showTip(GetLocalizeStringBy("key_3281"))
        return
    elseif(tonumber(dictData.ret.ret) == 1) then 
        AnimationTip.showTip(GetLocalizeStringBy("key_3076"))
        return
    elseif(tonumber(dictData.ret.ret) == 2) then 
        AnimationTip.showTip(GetLocalizeStringBy("key_2083"))
        return
    elseif(tonumber(dictData.ret.ret) == 3) then 
        AnimationTip.showTip(GetLocalizeStringBy("key_2483"))
        return
    elseif(tonumber(dictData.ret.ret) == 4) then 
        AnimationTip.showTip(GetLocalizeStringBy("key_3003"))
        return
    elseif(tonumber(dictData.ret.ret) == 5) then 
        AnimationTip.showTip(GetLocalizeStringBy("key_3217"))
        return
    elseif(dictData.ret.ret == "ok") then
        local rewardInfo = dictData.ret.reward
         createRewardLayer(rewardInfo)
         _bgLayer:removeFromParentAndCleanup(true)
         _bgLayer = nil 
    else
        return 
    end  

end 

function createRewardLayer(rewardInfo)
   require "script/utils/ItemTableView"
    local runningScene = CCDirector:sharedDirector():getRunningScene()
    local itemData = getGiftInfo(rewardInfo)

    local layer = ItemTableView:create(itemData)
    layer:setTitle(GetLocalizeStringBy("key_1809"))
    runningScene:addChild(layer,10000)
    refreshUI(itemData)
end

function refreshUI(itemData )
    require "script/model/user/UserModel"
    print("========---------------------  ")
    print_t(itemData)
    for i=1,#itemData  do
        if( itemData[i].type == "silver" ) then
            UserModel.addSilverNumber(itemData[i].num)
        elseif(itemData[i].type =="gold") then
             UserModel.addGoldNumber(itemData[i].num)
        elseif (itemData[i].type == "soul") then
            UserModel.addSoulNum(itemData[i].num)
        end
    end

end
--得到礼包物品数据
function getGiftInfo( rewardInfo )
    require "script/ui/item/ItemUtil"       
    local items = {}
    for k,v in  pairs(rewardInfo) do

        if( k == "hero") then
            local goods = rewardInfo.hero
            for k ,v in pairs(goods) do
                local item={}
                item.type = "hero"
                item.tid = k
                item.num = v
                table.insert(items, item)
            end
        elseif(k == "item") then 
            local goods = rewardInfo.item
            for k ,v in pairs(goods) do
                local item={}
                item.type = "item"
                item.tid = k
                item.num = v
                table.insert(items, item)
            end
        else
            local item = {}
            item.type = k
            item.num = v
            table.insert(items, item)
            
        end
    end

    return items

end

-- 确定按钮的回调函数
local function confirmCb( )
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	local curNumber = _numberEditBox:getText()
    local args = CCArray:create()
    args:addObject(CCString:create(curNumber))
    RequestCenter.reward_getGiftByCode(getGiftByCodeAction,args)

end

function createLayer( )

	_bgLayer = CCLayerColor:create(ccc4(11,11,11,166))
	  -- 设置灰色layer的优先级
    _bgLayer:setTouchEnabled(true)
    _bgLayer:registerScriptTouchHandler(layerToucCb,false,-550,true)
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,999,2013)

	local myScale = MainScene.elementScale
	local mySize = CCSizeMake(605,454)

	-- 背景
	local fullRect = CCRectMake(0, 0, 213, 171)
	local insetRect = CCRectMake(84, 84, 2, 3)
    local rewardCodeBg = CCScale9Sprite:create("images/common/viewbg1.png",fullRect,insetRect)
    rewardCodeBg:setContentSize(mySize)
    rewardCodeBg:setScale(myScale)
    rewardCodeBg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    rewardCodeBg:setAnchorPoint(ccp(0.5,0.5))
    _bgLayer:addChild(rewardCodeBg)

    local titleBg= CCSprite:create("images/common/viewtitle1.png")
	titleBg:setPosition(ccp(rewardCodeBg:getContentSize().width*0.5, rewardCodeBg:getContentSize().height-6))
	titleBg:setAnchorPoint(ccp(0.5, 0.5))
	rewardCodeBg:addChild(titleBg)

	--奖励的标题文本
	local labelTitle = CCRenderLabel:create(GetLocalizeStringBy("key_2727"), g_sFontPangWa,33,2,ccc3(0x00,0x00,0x0),type_shadow)
	labelTitle:setColor(ccc3(0xff,0xe4,0x00))
    labelTitle:setAnchorPoint(ccp(0.5,0.5))
	labelTitle:setPosition(ccp(titleBg:getContentSize().width*0.5,titleBg:getContentSize().height*0.5))
	titleBg:addChild(labelTitle)

	   -- 关闭按钮
    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(-551)
    rewardCodeBg:addChild(menu,99)
    local closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    closeBtn:setPosition(ccp(mySize.width*1.03,mySize.height*1.03))
    closeBtn:setAnchorPoint(ccp(1,1))
    closeBtn:registerScriptTapHandler(closeCb)
    menu:addChild(closeBtn)

    -- 关闭按钮
    local cancelBtn = CCMenuItemImage:create("images/common/btn/btn_blue_n.png", "images/common/btn/btn_blue_h.png")
    cancelBtn:setPosition(ccp(rewardCodeBg:getContentSize().width*0.75,35))
    cancelBtn:setAnchorPoint(ccp(0.5,0))
    menu:addChild(cancelBtn)
    local closeLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1284"), g_sFontPangWa,30,2,ccc3(0x00,0x00,0x0),type_stroke)
    closeLabel:setColor(ccc3(0xfe,0xdb,0x1c))
    local width = (cancelBtn:getContentSize().width - closeLabel:getContentSize().width)/2
    closeLabel:setPosition(width,54)
    cancelBtn:addChild(closeLabel)
    cancelBtn:registerScriptTapHandler(closeCb)


    -- 兑换，
    local confirmBtn = CCMenuItemImage:create("images/common/btn/btn_blue_n.png", "images/common/btn/btn_blue_h.png")
    confirmBtn:setPosition(ccp(rewardCodeBg:getContentSize().width*0.25,35))
    confirmBtn:setAnchorPoint(ccp(0.5,0))
    menu:addChild(confirmBtn)
    local confirmLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2689"), g_sFontPangWa,30,2,ccc3(0x00,0x00,0x0),type_stroke)
    confirmLabel:setColor(ccc3(0xfe,0xdb,0x1c))
    local width = (confirmBtn:getContentSize().width - confirmLabel:getContentSize().width)/2
    local height = confirmBtn:getContentSize().height/2
    confirmLabel:setPosition(width,54)
    confirmBtn:addChild(confirmLabel)
    confirmBtn:registerScriptTapHandler(confirmCb)

    -- 黑色的背景
    local itemInfoSpite = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
    itemInfoSpite:setContentSize(CCSizeMake(556,285))
    itemInfoSpite:setPosition(ccp(mySize.width*0.5,114))
    itemInfoSpite:setAnchorPoint(ccp(0.5,0))
    rewardCodeBg:addChild(itemInfoSpite)

    local explainLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2333"), g_sFontPangWa , 26)
    explainLabel:setColor(ccc3(0xfe,0xdb,0x1c))
    explainLabel:setPosition(ccp(mySize.width*0.5,324))
    explainLabel:setAnchorPoint(ccp(0.5,0))
    rewardCodeBg:addChild(explainLabel)

   -- createNameBox(rewardCodeBg)
   --change scale by zhang zihang
   	_numberEditBox = CCEditBox:create(CCSizeMake(413,60), CCScale9Sprite:create("images/common/bg/search_bg.png"))
	_numberEditBox:setPosition(ccp(rewardCodeBg:getContentSize().width/2,rewardCodeBg:getContentSize().height/2))
	_numberEditBox:setTouchPriority(-551)
	_numberEditBox:setAnchorPoint(ccp(0.5,0.5))
    --_numberEditBox:setScale(1/myScale)
	_numberEditBox:setPlaceHolder(GetLocalizeStringBy("key_2860"))
	_numberEditBox:setFont(g_sFontName,24)
	rewardCodeBg:addChild(_numberEditBox)

	
end
