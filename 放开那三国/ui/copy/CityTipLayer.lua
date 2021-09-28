-- Filename: CityTipLayer.lua
-- Author: llp
-- Date: 2013-07-11
-- Purpose: 该文件用于:城池战提示


module ("CityTipLayer", package.seeall)


require "script/utils/LuaUtil"
require "script/ui/tip/AnimationTip"
require "script/network/RequestCenter"
require "script/audio/AudioUtil"
require "script/ui/guild/city/CityData"
require "script/ui/copy/CityMenuItem"
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
    --刷新主界面按钮
    require "script/ui/main/MainMenuLayer"
    MainMenuLayer.updateMiddleButton()
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
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    require "script/ui/copy/BigMap"
    local fortsLayer = BigMap.createFortsLayout()
    MainScene.changeLayer(fortsLayer, "BigMap")

    _bgLayer:removeFromParentAndCleanup(true)
    _bgLayer = nil
end

function getGuildInfoCallback( cbFlag, dictData, bRet )
    -- body
    _guildInfo      = dictData.ret
    if(not table.isEmpty(_guildInfo))then
        require "script/ui/guild/GuildDataCache"
        GuildDataCache.setGuildInfo(_guildInfo)
    end
    local rewardCodeBg = _bgLayer:getChildByTag(111)
    local signCity = CityData.getSignCity()
    local sucCity = CityData.getSucCity()
    print("1111111111")
    print_t(signCity)
    print("1111111111")

    print("2222222222")
    print_t(sucCity)
    print("2222222222")
    local posIndex = 1
    statusMenuBar = CCMenu:create()
    statusMenuBar:setPosition(ccp(0, 0))
    rewardCodeBg:addChild(statusMenuBar,10)
    if(sucCity==nil or table.isEmpty(sucCity))then
        for k, cityid in pairs(signCity) do
            print(GetLocalizeStringBy("key_2533"))
            print("cityidddddd",cityid)
            local cityItem = CityMenuItem.createItem(cityid, CityMenuItem.Type_City_Quick)
            -- cityItem:setScale(0.7)
            -- cityItem:setScale(g_fBgScaleRatio*0.7)
            local statusSprite = CCSprite:create("images/citybattle/sign.png")
            -- city1 = cityItem
            cityItem:setAnchorPoint(ccp(0.5, 0.5))
            if(posIndex == 1)then
                cityItem:setPosition(ccp(cityItem:getContentSize().width*1.15, (rewardCodeBg:getContentSize().height)*0.5))
            else
                cityItem:setPosition(ccp(rewardCodeBg:getContentSize().width*( 0.35 * posIndex), (rewardCodeBg:getContentSize().height)*0.5))
            end
            
            statusMenuBar:addChild(cityItem, 1, cityid)
            -- cityItem:registerScriptTapHandler(scrollToCity)--scrollToCity
            statusSprite:setAnchorPoint(ccp(0.5, 1))
            statusSprite:setPosition(ccp(cityItem:getContentSize().width*0.5, -20))
            cityItem:addChild(statusSprite,0,110)
            local _itemTipSprite = CCScale9Sprite:create("images/common/bg/bg_9s_2.png")
            _itemTipSprite:setContentSize(CCSizeMake(cityItem:getContentSize().width-20, cityItem:getContentSize().height))
            _itemTipSprite:setAnchorPoint(ccp(0.5, 0.5))
            _itemTipSprite:setPosition(ccp(cityItem:getContentSize().width*0.5, cityItem:getContentSize().height*0.5))
            posIndex = posIndex + 1
        end
    else
        for i=1,table.count(sucCity) do
            print(GetLocalizeStringBy("key_2790"))
            -- if(tonumber(sucCity[i])~=tonumber(cityid))then
                local cityItem = CityMenuItem.createItem(sucCity[i], CityMenuItem.Type_City_Quick)
                print("cityidddddd",sucCity[i])
                -- cityItem:setScale(0.7)
                -- cityItem:setScale(g_fBgScaleRatio*0.7)
                local statusSprite = CCSprite:create("images/citybattle/battle.png")
                -- city1 = cityItem
                cityItem:setAnchorPoint(ccp(0.5, 0.5))
                if(posIndex == 1)then
                    cityItem:setPosition(ccp(cityItem:getContentSize().width*g_fBgScaleRatio*1.15, (rewardCodeBg:getContentSize().height)*0.5))
                else
                    cityItem:setPosition(ccp(rewardCodeBg:getContentSize().width*( 0.35 * posIndex), (rewardCodeBg:getContentSize().height)*0.5))
                end
                
                statusMenuBar:addChild(cityItem, 1, sucCity[i])
                -- cityItem:registerScriptTapHandler(cityAction)--scrollToCity
                statusSprite:setAnchorPoint(ccp(0.5, 1))
                statusSprite:setPosition(ccp(cityItem:getContentSize().width*0.5, -20))
                cityItem:addChild(statusSprite,0,110)
                local _itemTipSprite = CCScale9Sprite:create("images/common/bg/bg_9s_2.png")
                _itemTipSprite:setContentSize(CCSizeMake(cityItem:getContentSize().width-20, cityItem:getContentSize().height))
                _itemTipSprite:setAnchorPoint(ccp(0.5, 0.5))
                _itemTipSprite:setPosition(ccp(cityItem:getContentSize().width*0.5, cityItem:getContentSize().height*0.5))
                posIndex = posIndex + 1
            -- end
        end
    end

    -- 已占领的城市
    local occupyCity = CityData.getOcupyCityInfos()
    local rewardCity = CityData.getRewardCity()
    print("3333333333")
    print_t(occupyCity)
    print("3333333333")

    print("4444444444")
    print_t(rewardCity)
    print("4444444444")
    if( not table.isEmpty(occupyCity)) then
        -- 可领奖的城市
        local rewardCity = CityData.getRewardCity()
        if(rewardCity ~= nil and tonumber(rewardCity)>0)then
            print(GetLocalizeStringBy("key_2233"))
            print("cityidddddd",rewardCity)
            local cityItem = CityMenuItem.createItem(rewardCity,  CityMenuItem.Type_City_Quick)
            local statusSprite = CCSprite:create("images/citybattle/reward.png")
            -- cityItem:setScale(g_fBgScaleRatio*0.7)
            -- city3 = cityItem
            cityItem:setAnchorPoint(ccp(0.5, 0.5))
            if(posIndex == 1)then
                cityItem:setPosition(ccp(cityItem:getContentSize().width*g_fBgScaleRatio*1.15, (rewardCodeBg:getContentSize().height)*0.5))
            else
                cityItem:setPosition(ccp(rewardCodeBg:getContentSize().width*( 0.35 * posIndex), (rewardCodeBg:getContentSize().height)*0.5))
            end
            statusMenuBar:addChild(cityItem, 1, rewardCity)
            -- cityItem:registerScriptTapHandler(scrollToCity)
            
            statusSprite:setAnchorPoint(ccp(0.5, 1))
            statusSprite:setPosition(ccp(cityItem:getContentSize().width*0.5, -20))
            cityItem:addChild(statusSprite)
            local _itemTipSprite = CCScale9Sprite:create("images/common/bg/bg_9s_2.png")
            _itemTipSprite:setContentSize(CCSizeMake(cityItem:getContentSize().width*1.3, cityItem:getContentSize().height))
            _itemTipSprite:setAnchorPoint(ccp(0.5, 0.5))
            _itemTipSprite:setPosition(ccp(cityItem:getContentSize().width*0.5, cityItem:getContentSize().height*0.5))
            posIndex = posIndex + 1

        else
            print(GetLocalizeStringBy("key_3409")..111111)
            for cityid, guildInfo in pairs(occupyCity) do
                print(GetLocalizeStringBy("key_3409")..222222)
                print(tonumber(guildInfo.guild_id))
                print("cityidddddd",cityid)
                local guildid = GuildDataCache.getMineSigleGuildId()
                print(tonumber(guildid).."GuildDataCache.getGuildId()")
            if( tonumber(guildInfo.guild_id) ==  tonumber(guildid))then
                print(GetLocalizeStringBy("key_3409")..333333)
                print(GetLocalizeStringBy("key_3409"))
                print("cityidddddd",cityid)
                local cityItem = CityMenuItem.createItem(cityid,  CityMenuItem.Type_City_Quick)
                local statusSprite = CCSprite:create("images/citybattle/occupy.png")
                -- cityItem:setScale(0.7)
                -- cityItem:setScale(g_fBgScaleRatio*0.7)
                -- city2 = cityItem
                cityItem:setAnchorPoint(ccp(0.5, 0.5))
                if(posIndex == 1)then
                    cityItem:setPosition(ccp(cityItem:getContentSize().width*g_fBgScaleRatio*1.15, (rewardCodeBg:getContentSize().height)*0.5))
                else
                    cityItem:setPosition(ccp(rewardCodeBg:getContentSize().width*( 0.35 * posIndex), (rewardCodeBg:getContentSize().height)*0.5))
                end
                statusMenuBar:addChild(cityItem, 1, cityid)
                -- cityItem:registerScriptTapHandler(scrollToCity)
                
                statusSprite:setAnchorPoint(ccp(0.5, 1))
                statusSprite:setPosition(ccp(cityItem:getContentSize().width*0.5, -20))
                cityItem:addChild(statusSprite)
                local _itemTipSprite = CCScale9Sprite:create("images/common/bg/bg_9s_2.png")
                _itemTipSprite:setContentSize(CCSizeMake(cityItem:getContentSize().width-20, cityItem:getContentSize().height))
                _itemTipSprite:setAnchorPoint(ccp(0.5, 0.5))
                _itemTipSprite:setPosition(ccp(cityItem:getContentSize().width*0.5, cityItem:getContentSize().height*0.4))
                posIndex = posIndex + 1
            end
        end
    end
    end
end

function signUpCallBack( cbFlag, dictData, bRet )
    -- body
    CityData.setCityServiceInfo(dictData)
    RequestCenter.guild_getGuildInfo(getGuildInfoCallback)
end

function show( ... )
    createLayer()
end

function createLayer( )
    local copyFileLua = "db/city1"
    _G[copyFileLua] = nil
    package.loaded[copyFileLua] = nil
    require (copyFileLua)
    local data = GuildDataCache.getMineSigleGuildInfo()
    local tempArgs = CCArray:create()
    tempArgs:addObject(CCInteger:create(data.guild_id))
    RequestCenter.GuildSignUpInfo(signUpCallBack, tempArgs)

	_bgLayer = CCLayerColor:create(ccc4(11,11,11,166))
	  -- 设置灰色layer的优先级
    _bgLayer:setTouchEnabled(true)
    _bgLayer:registerScriptTouchHandler(layerToucCb,false,-550,true)
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,999,2013)

	local myScale = MainScene.elementScale
	local mySize = CCSizeMake(605,570)

	-- 背景
	local fullRect = CCRectMake(0, 0, 213, 171)
	local insetRect = CCRectMake(84, 84, 2, 3)
    local rewardCodeBg = CCScale9Sprite:create("images/common/viewbg1.png",fullRect,insetRect)
    rewardCodeBg:setContentSize(mySize)
    rewardCodeBg:setScale(myScale)
    rewardCodeBg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    rewardCodeBg:setAnchorPoint(ccp(0.5,0.5))
    _bgLayer:addChild(rewardCodeBg,1,111)

    local titleBg= CCSprite:create("images/common/viewtitle1.png")
	titleBg:setPosition(ccp(rewardCodeBg:getContentSize().width*0.5, rewardCodeBg:getContentSize().height-6))
	titleBg:setAnchorPoint(ccp(0.5, 0.5))
	rewardCodeBg:addChild(titleBg)

    -- 时间提示
    -- 报名截止时间
    _allTimeTab = CityData.getTimeTable()
    print("hehehehehe")
    print_t(_allTimeTab)
    print("hehehehehe")
    local star_time_interVal = _allTimeTab.signupStart
    local startStr = CityData.getTimeStrByNum(star_time_interVal)
    local end_time_interval = _allTimeTab.signupEnd
    local endStr = CityData.getTimeStrByNum(end_time_interval)
    local str = GetLocalizeStringBy("key_1943") .. startStr .. GetLocalizeStringBy("key_2291") .. endStr
    local timeOutFont = CCLabelTTF:create(str, g_sFontPangWa, 21)
    timeOutFont:setAnchorPoint(ccp(0.5,0))
    timeOutFont:setColor(ccc3(0x78,0x25,0x00))
    timeOutFont:setPosition(ccp(rewardCodeBg:getContentSize().width*0.5,500))
    rewardCodeBg:addChild(timeOutFont,10)

    -- 开战时间
    local star_time = tonumber(_allTimeTab.arrAttack[1][1]) - tonumber(_allTimeTab.prepare)
    local startStr = CityData.getTimeStrByNum(star_time)
    local str = GetLocalizeStringBy("key_1278") .. startStr 
    local timeFont = CCLabelTTF:create(str, g_sFontPangWa, 21)
    timeFont:setAnchorPoint(ccp(0.5,0))
    timeFont:setColor(ccc3(0x78,0x25,0x00))
    timeFont:setPosition(ccp(rewardCodeBg:getContentSize().width*0.5,467))
    rewardCodeBg:addChild(timeFont)

    

	--夺城战概况的标题文本
	local labelTitle = CCRenderLabel:create(GetLocalizeStringBy("llp_75"), g_sFontPangWa,33,2,ccc3(0x00,0x00,0x0),type_shadow)
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
    -- local cancelBtn = CCMenuItemImage:create("images/common/btn/btn_blue_n.png", "images/common/btn/btn_blue_h.png")
    -- cancelBtn:setPosition(ccp(rewardCodeBg:getContentSize().width*0.75,35))
    -- cancelBtn:setAnchorPoint(ccp(0.5,0))
    -- menu:addChild(cancelBtn)
    -- local closeLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1284"), g_sFontPangWa,30,2,ccc3(0x00,0x00,0x0),type_stroke)
    -- closeLabel:setColor(ccc3(0xfe,0xdb,0x1c))
    -- local width = (cancelBtn:getContentSize().width - closeLabel:getContentSize().width)/2
    -- closeLabel:setPosition(width,54)
    -- cancelBtn:addChild(closeLabel)
    -- cancelBtn:registerScriptTapHandler(closeCb)

    -- 兑换，
    local confirmBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(200, 73),GetLocalizeStringBy("llp_76"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    confirmBtn:setPosition(ccp(rewardCodeBg:getContentSize().width*0.5,35))
    confirmBtn:setAnchorPoint(ccp(0.5,0))
    menu:addChild(confirmBtn)
    -- local confirmLabel = CCRenderLabel:create(GetLocalizeStringBy("llp_76"), g_sFontPangWa,30,2,ccc3(0x00,0x00,0x0),type_stroke)
    -- confirmLabel:setColor(ccc3(0xfe,0xdb,0x1c))
    -- local width = (confirmBtn:getContentSize().width - confirmLabel:getContentSize().width)/2
    -- local height = confirmBtn:getContentSize().height/2
    -- confirmLabel:setPosition(width,54)
    -- confirmBtn:addChild(confirmLabel)
    confirmBtn:registerScriptTapHandler(confirmCb)

    -- 黑色的背景
    local itemInfoSpite = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
    itemInfoSpite:setContentSize(CCSizeMake(556,285))
    itemInfoSpite:setPosition(ccp(mySize.width*0.5,114))
    itemInfoSpite:setAnchorPoint(ccp(0.5,0))
    rewardCodeBg:addChild(itemInfoSpite)
end
