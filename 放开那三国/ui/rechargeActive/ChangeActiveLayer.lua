-- FileName: ChangeActiveLayer.lua 
-- Author: licong 
-- Date: 14-5-16 
-- Purpose: function description of module 


module("ChangeActiveLayer", package.seeall)

require "script/ui/rechargeActive/ActiveCache"
require "script/utils/TimeUtil"
require "script/model/utils/ActivityConfigUtil"
require "script/ui/item/ItemSprite"
require "script/ui/item/ItemUtil"
require "script/ui/hero/HeroPublicLua"

local _bgLayer 				= nil
local _titleBg 				= nil
local _listBg               = nil
local _listHight            = nil
local _listWidth            = nil
local _listView             = nil
local _tipLayer             = nil
local _tipId                = nil
local _tipCostNum           = nil

local _serviceData          = nil

local kTagyes               = 10001
local kTagCancel            = 10002
local _touchPriority        = -350

local function init( ... )
	_bgLayer 				= nil
	_titleBg 				= nil
    _listBg                 = nil   
	_listHight              = nil
    _listWidth              = nil
    _listView               = nil
    _curRefreshNum          = nil
    _serviceData            = nil
    _tipLayer               = nil
    _tipId                  = nil
    _tipCostNum             = nil
end

-- 材料x坐标 key是材料个数
local _posXTab = {
    -- 1个材料x坐标
    {0.3,0.7},
    -- 2个材料x坐标
    {0.2,0.5,0.8},
    -- 3个材料x坐标
    {0.11,0.37,0.63,0.89},
    -- 4个材料x坐标
    {0.2,0.2,0.5,0.5,0.8},
    -- 5个材料x坐标
    {0.11,0.11,0.37,0.63,0.63,0.89}
}
-- 材料y坐标 key是材料个数
local _posYTab = {
    -- 1个y坐标
    {0.56},
    -- 2个y坐标
    {0.56,0.56},
    -- 3个y坐标
    {0.56,0.56,0.56},
    -- 4个y坐标
    {0.75,0.3,0.75,0.3},
    -- 5个y坐标
    {0.75,0.3,0.5,0.75,0.3}
}

-- 目标x坐标 key是材料个数
local _desPosXTab = {0.7,0.8,0.89,0.8,0.89}
local _desPosYTab = {0.56,0.56,0.56,0.5,0.5}

-- 加号x坐标 key是材料个数-1
local _addPosXTab = {
    -- 2个材料
    {0.36},
    -- 3个材料
    {0.24,0.5},
    -- 4个材料
    {0.34},
    -- 5个材料
    {0.23,0.5}
}

-- 等号x坐标 key是材料个数
local _equalPosXTab = {0.5,0.65,0.76,0.65,0.75}


--[[
 @desc   处理touches事件
 @para   string event
 @return 
--]]
local function onTouchesHandler( eventType, x, y )
    if (eventType == "began") then
        return true
    elseif (eventType == "moved") then
    else
    end
end

--[[
 @desc   回调onEnter和onExit时间
 @para   string event
 @return void
 --]]
local function onNodeEventTip( event )
    if (event == "enter") then
        _tipLayer:registerScriptTouchHandler(onTouchesHandler, false, _touchPriority-150, true)
        _tipLayer:setTouchEnabled(true)
    elseif (event == "exit") then
        _tipLayer:unregisterScriptTouchHandler()
        _tipLayer = nil
    end
end


local function closeAction()
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    if(_tipLayer) then
        _tipLayer:removeFromParentAndCleanup(true)
        _tipLayer = nil
    end
end

-- 按钮响应
local function menuAction( tag, itemBtn )
    -- 关闭
    closeAction()

    if(tag == kTagyes) then
        -- 发送刷新请求
        refreshMenuItemSendSerViceFun( _tipId, _tipCostNum )
    elseif(tag == kTagCancel)then
    else
    end
end

-- 刷新金币提示
local function showRefreshTipLayer( p_id, p_costNum )
    _tipId                  = nil
    _tipCostNum             = nil
    _tipId                  = p_id
    _tipCostNum             = p_costNum
    -- layer
    _tipLayer = CCLayerColor:create(ccc4(0,0,0,155))
    _tipLayer:registerScriptHandler(onNodeEventTip)
    local runningScene = CCDirector:sharedDirector():getRunningScene()
    runningScene:addChild(_tipLayer, 2000)

    -- 背景
    local fullRect = CCRectMake(0,0,213,171)
    local insetRect = CCRectMake(50,50,113,71)
    local alertBg = CCScale9Sprite:create("images/common/viewbg1.png", fullRect, insetRect)
    alertBg:setPreferredSize(CCSizeMake(520, 360))
    alertBg:setAnchorPoint(ccp(0.5, 0.5))
    alertBg:setPosition(ccp(_tipLayer:getContentSize().width*0.5, _tipLayer:getContentSize().height*0.5))
    _tipLayer:addChild(alertBg)
    alertBg:setScale(g_fScaleX)

    local alertBgSize = alertBg:getContentSize()

    -- 关闭按钮bar
    local closeMenuBar = CCMenu:create()
    closeMenuBar:setPosition(ccp(0, 0))
    alertBg:addChild(closeMenuBar)
    closeMenuBar:setTouchPriority(_touchPriority-200)
    -- 关闭按钮
    local closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    closeBtn:registerScriptTapHandler(closeAction)
    closeBtn:setAnchorPoint(ccp(0.5, 0.5))
    closeBtn:setPosition(ccp(alertBg:getContentSize().width*0.95, alertBg:getContentSize().height*0.98))
    closeMenuBar:addChild(closeBtn)

    -- 标题
    local titleLabel = CCRenderLabel:create(GetLocalizeStringBy("key_3158"), g_sFontPangWa, 35, 1, ccc3( 0xff, 0xff, 0xff), type_stroke)
    titleLabel:setColor(ccc3(0x78, 0x25, 0x00))
    titleLabel:setAnchorPoint(ccp(0.5, 0.5))
    titleLabel:setPosition(ccp(alertBgSize.width*0.5, alertBgSize.height*0.8))
    alertBg:addChild(titleLabel)

    -- 描述
-- 第一行
    -- 刷新后，兑换材料及兑换物品都会改变
    local font1 = CCLabelTTF:create(GetLocalizeStringBy("lic_1119"), g_sFontName, 25)
    font1:setColor(ccc3(0x78, 0x25, 0x00))
    font1:setAnchorPoint(ccp(0.5, 0.5))
    font1:setPosition(ccp(alertBg:getContentSize().width*0.5,alertBgSize.height*0.6))
    alertBg:addChild(font1)
-- 第二行    
    -- 是否花费
    local font4 = CCLabelTTF:create(GetLocalizeStringBy("lic_1120"), g_sFontName, 25)
    font4:setColor(ccc3(0x78, 0x25, 0x00))
    font4:setAnchorPoint(ccp(0, 0.5))
    alertBg:addChild(font4)
    -- 金币图标
    local goldSp = CCSprite:create("images/common/gold.png")
    goldSp:setAnchorPoint(ccp(0,0.5))
    alertBg:addChild(goldSp)
    -- 刷新价格
    local costNumFont = CCLabelTTF:create(_tipCostNum, g_sFontName,25)
    costNumFont:setColor(ccc3(0x78, 0x25, 0x00))
    costNumFont:setAnchorPoint(ccp(0, 0.5))
    alertBg:addChild(costNumFont)
    -- 进行刷新
    local font5 = CCLabelTTF:create(GetLocalizeStringBy("lic_1121"), g_sFontName, 25)
    font5:setColor(ccc3(0x78, 0x25, 0x00))
    font5:setAnchorPoint(ccp(0, 0.5))
    alertBg:addChild(font5)
    -- 第二行居中
    local posX = (alertBg:getContentSize().width-font4:getContentSize().width-goldSp:getContentSize().width-costNumFont:getContentSize().width-font5:getContentSize().width)/2
    font4:setPosition(ccp(posX, alertBgSize.height*0.5))
    goldSp:setPosition(ccp(font4:getPositionX()+font4:getContentSize().width, font4:getPositionY()))
    costNumFont:setPosition(ccp(goldSp:getPositionX()+goldSp:getContentSize().width, font4:getPositionY()))
    font5:setPosition(ccp(costNumFont:getPositionX()+costNumFont:getContentSize().width, font4:getPositionY()))
    
    -- 按钮
    local menuBar = CCMenu:create()
    menuBar:setPosition(ccp(0,0))
    menuBar:setTouchPriority(_touchPriority-200)
    alertBg:addChild(menuBar)

    -- 确认
    require "script/libs/LuaCC"
    local confirmBtn = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(160, 70), GetLocalizeStringBy("lic_1097"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    confirmBtn:setAnchorPoint(ccp(0.5, 0.5))
    confirmBtn:setPosition(ccp(alertBgSize.width*0.3, alertBgSize.height*0.2))
    confirmBtn:registerScriptTapHandler(menuAction)
    menuBar:addChild(confirmBtn, 1, kTagyes)
    
    -- 取消
    local cancelBtn = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png", "images/star/intimate/btn_blue_h.png",CCSizeMake(160, 70), GetLocalizeStringBy("lic_1098"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    cancelBtn:setAnchorPoint(ccp(0.5, 0.5))
    cancelBtn:setPosition(ccp(alertBgSize.width*0.7, alertBgSize.height*0.2))
    cancelBtn:registerScriptTapHandler(menuAction)
    menuBar:addChild(cancelBtn, 1, kTagCancel)
end

local function onNodeEvent( event )
    if (event == "enter") then
    elseif (event == "exit") then
       _bgLayer = nil
    end
end

-- 查看物品信息返回回调 为了显示下排按钮
local function showDownMenu( ... )
    MainScene.setMainSceneViewsVisible(true, false, false)
end

-- 兑换预览
local function showChangeItem( ... )
    require "script/ui/rechargeActive/ChangeItemShowLayer"
    ChangeItemShowLayer.showChangeItemLayer()
end

-- 得到物品icon
local function getItemIconByData( itemData, menu_priority, zOrderNum, info_layer_priority, isDesIcon )
    -- print("itemData...")
    -- print_t(itemData)
    local iconBg = CCSprite:create("images/everyday/headBg1.png")
    local iconSp = nil
    local iconName = nil
    local nameColor = nil
    if(itemData.type == "gold") then
        -- 金币
        iconSp= ItemSprite.getGoldIconSprite()
        iconName = GetLocalizeStringBy("key_1491")
        local quality = ItemSprite.getGoldQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif(itemData.type == "item") then
        -- 物品
        iconSp =  ItemSprite.getItemSpriteById(tonumber(itemData.tid),nil, showDownMenu, nil,  menu_priority, zOrderNum, info_layer_priority)
        local itemData = ItemUtil.getItemById(itemData.tid)
        iconName = itemData.name
        nameColor = HeroPublicLua.getCCColorByStarLevel(itemData.quality)
    else
        print("no this type: itemData.type",itemData.type)
    end
    iconSp:setAnchorPoint(ccp(0.5,0.5))
    iconSp:setPosition(ccp(iconBg:getContentSize().width*0.5,iconBg:getContentSize().height*0.5))
    iconBg:addChild(iconSp)

    -- 物品数量
    local numStr = nil
    local numColor = nil
    -- print("isDesIcon",isDesIcon)
    if(isDesIcon)then
        numStr = itemData.num
        numColor = ccc3(0x00,0xff,0x18)
    else
        if(itemData.type == "gold") then
            numStr = itemData.needNum
        else
            numStr = itemData.haveNum .. "/" .. itemData.needNum 
        end

        if( tonumber(itemData.haveNum) >= tonumber(itemData.needNum) )then
            numColor = ccc3(0x00,0xff,0x18)
        else
            numColor = ccc3(0xff,0x00,0x00)
        end
    end
    local numberLabel =  CCRenderLabel:create( numStr, g_sFontPangWa,18,1,ccc3(0x00,0x00,0x00),type_stroke)
    numberLabel:setAnchorPoint(ccp(1,0))
    numberLabel:setColor(numColor)
    iconSp:addChild(numberLabel)
    if(isDesIcon)then
        numberLabel:setPosition(ccp(iconSp:getContentSize().width-5,5))
    else
        numberLabel:setPosition(ccp(iconSp:getContentSize().width-5,5))
    end
   
    -- 名字
    local iconName = CCRenderLabel:create(iconName,g_sFontPangWa,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    iconName:setColor(nameColor)
    iconName:setAnchorPoint(ccp(0.5,0.5))
    iconName:setPosition(ccp(iconBg:getContentSize().width*0.5,-10))
    iconBg:addChild(iconName)

    return iconBg
end

-- 是否可以兑换 可以true
local function isCanChange( id )
    local desData = _serviceData.goods_list[tostring(id)]
    local ret = false
    if(desData == nil)then
        return ret
    end
    local isCan = true
    -- 要兑换的公式的材料数据
    local reqItems = ActiveCache.getListReqData(desData.req)
    for i=1,#reqItems do
        if( tonumber(reqItems[i].haveNum) < tonumber(reqItems[i].needNum) )then
            -- 不满足需要的数量
            isCan = false
            print("no ok id ", i, reqItems[i].haveNum, reqItems[i].needNum  )
        end
    end
    if(isCan)then
        ret = true
    else
        ret = false
    end
    return ret
end

-- 现在可以兑换最大次数
local function getNowCanChangeNum( id )
    local desData = _serviceData.goods_list[tostring(id)]
    local ret = 0
    if(desData == nil)then
        return ret
    end
    local numTab = {}
    -- 要兑换的公式的材料数据
    local reqItems = ActiveCache.getListReqData(desData.req)
    for i=1,#reqItems do
        local num = math.floor(tonumber(reqItems[i].haveNum)/tonumber(reqItems[i].needNum))
        table.insert(numTab,num)
    end
    table.sort( numTab, function ( pData1, pData2 )
        return pData1 < pData2
    end )
    ret = tonumber(numTab[1])
    return ret
end

-- 展示兑换物品后确定回调
local function showRewardCallFun( ... )
    -- 重新创建列表
    local offset = nil
    if(_listView ~= nil)then
        offset = _listView:getContentOffset()
    end
    -- 重新创建列表
    createScrollView()
    if(offset)then
        _listView:setContentOffset(offset)
    end
end

--刷新请求
function refreshMenuItemSendSerViceFun( p_id, p_costNum )
    -- local desData = _serviceData.goods_list[tostring(p_id)]
    -- local price = ActiveCache.getChangeRefreshGold(desData.refresh_num, p_id)
    -- 刷新请求
    -- 刷新请求回调
    local function refreshServiceFun(cbFlag, dictData, bRet )
        if(dictData.err == "ok") then
            -- print("refreshServiceFun:")
            -- print_t(dictData.ret)
            -- 扣除金币
            UserModel.addGoldNumber(-p_costNum)
            -- 网络数据
            for k,v in pairs(dictData.ret) do
                _serviceData.goods_list[k] = v  
            end
            -- 重新创建列表
            local offset = nil
            if(_listView ~= nil)then
                offset = _listView:getContentOffset()
            end
            createScrollView()
            if(offset)then
                _listView:setContentOffset(offset)
            end
        end  
    end
    -- 参数
    local args = CCArray:create()
    args:addObject(CCInteger:create(p_id))
    Network.rpc(refreshServiceFun, "actexchange.rfrGoodsList", "actexchange.rfrGoodsList", args, true)
end

-- 刷新回调
local function refreshMenuItemAction( tag, itemBtn )
    local desData = _serviceData.goods_list[tostring(tag)]
    -- 刷新价格
    local price = 0
    if( tonumber(desData.free_refresh_num) > 0)then
        price = 0
    else
        price = ActiveCache.getChangeRefreshGold(desData.refresh_num, tag)
    end
    if( UserModel.getGoldNumber() < price )then
        -- 金币不足提示
        require "script/ui/tip/LackGoldTip"
        LackGoldTip.showTip()
        return
    end
    -- 刷新提示面板
    showRefreshTipLayer(tag,price)
end

-- 兑换
local function menuItemCallFun( tag, itemBtn )
    print("tag ==>", tag)
    -- 判断活动是否结束
    if( BTUtil:getSvrTimeInterval()<tonumber(ActivityConfig.ConfigCache.actExchange.start_time) or BTUtil:getSvrTimeInterval() > tonumber(ActivityConfig.ConfigCache.actExchange.end_time) ) then
        AnimationTip.showTip(GetLocalizeStringBy("key_1857"))
        return
    end 
    -- 物品背包满了
    require "script/ui/item/ItemUtil"
    if(ItemUtil.isBagFull() == true )then
        return
    end
    -- 武将满了
    require "script/ui/hero/HeroPublicUI"
    if HeroPublicUI.showHeroIsLimitedUI() then
        return
    end
    -- 兑换次数已达上限
    local haveNum = tonumber(_serviceData.goods_list[tostring(tag)].soldNum)
    local maxNum = ActiveCache.getMaxChangeNum(tag)
    if(haveNum >= maxNum)then
        require "script/ui/tip/AnimationTip"
        AnimationTip.showTip(GetLocalizeStringBy("key_1009"))
        return
    end
    -- 材料不足
    local isCan = isCanChange(tag)
    if(isCan == false)then
        require "script/ui/tip/AnimationTip"
        AnimationTip.showTip(GetLocalizeStringBy("lic_1007"))
        return
    end

    local function buyOverCallBack( pNum )
        -- 兑换网络请求
        local function changeServiceCallBack( cbFlag, dictData, bRet )
            if(dictData.err == "ok") then
                -- print("changeServiceCallBack:")
                -- print_t(dictData.ret)
                if(dictData.ret.ret == "ok")then
                    -- 增加目标兑换次数
                    _serviceData.goods_list[tostring(tag)].soldNum = tonumber(_serviceData.goods_list[tostring(tag)].soldNum) + pNum
                    -- 兑换后扣除金币材料部分
                    local desData = _serviceData.goods_list[tostring(tag)]
                    -- 要兑换的公式的材料数据
                    local reqItems = ActiveCache.getListReqData(desData.req)
                    for i=1,#reqItems do
                        if(reqItems[i].type == "gold") then
                            -- 扣除金币
                            UserModel.addGoldNumber(-tonumber(reqItems[i].needNum)*pNum)
                        end
                    end
                    -- 展示目标奖励
                    local itemData = ActiveCache.getListDesItemData(_serviceData.goods_list[tostring(tag)].acq)
                    -- print("show des ..")
                    -- print_t(itemData)
                    local tab = {}
                    tab[1] = {}
                    tab[1].tid = itemData[1].tid
                    tab[1].type = itemData[1].type
                    tab[1].num = tonumber(itemData[1].num)*pNum
                    require "script/ui/item/ReceiveReward"
                    ReceiveReward.showRewardWindow( tab,showRewardCallFun, 1010 )
                end

            end  
        end
        -- 参数
        local args = CCArray:create()
        args:addObject(CCInteger:create(tag))
        args:addObject(CCInteger:create(pNum))
        Network.rpc(changeServiceCallBack, "actexchange.buyGoods", "actexchange.buyGoods", args, true)

    end

    -- 现有可兑换最大次数
    local nowMaxNum = getNowCanChangeNum(tag)
    local choseMaxNum = 20
    if(nowMaxNum < choseMaxNum)then
        choseMaxNum = nowMaxNum
    end
    -- 剩余兑换次数
    local surplusNum = maxNum - haveNum
    if(surplusNum < choseMaxNum)then
        choseMaxNum = surplusNum
    end
    -- 选择购买数量
    require "script/utils/SelectNumDialog"
    local dialog = SelectNumDialog:create()
    dialog:setTitle(GetLocalizeStringBy("lic_1839"))
    dialog:setLimitNum(choseMaxNum)
    dialog:show(_touchPriority-150, 1010)

    -- 当前可兑换多少次
    local contentCostNode1 = CCRenderLabel:create(GetLocalizeStringBy("lic_1842",nowMaxNum),g_sFontName,22,1,ccc3(0x49,0x00,0x00),type_stroke)
    contentCostNode1:setColor(ccc3(0xfe,0xdb,0x1c))
    contentCostNode1:setAnchorPoint(ccp(0.5,0.5))
    contentCostNode1:setPosition(ccpsprite(0.5, 0.8, dialog))
    dialog:addChild(contentCostNode1)

    local desData = _serviceData.goods_list[tostring(tag)]
    local itemData = ActiveCache.getListDesItemData(desData.acq)
    local contentMsgInfo = {}
    contentMsgInfo.labelDefaultColor = ccc3(0xff,0xff,0xff)
    contentMsgInfo.labelDefaultSize = 25
    contentMsgInfo.defaultType = "CCRenderLabel"
    contentMsgInfo.lineAlignment = 1
    contentMsgInfo.lineAlignment = 2
    contentMsgInfo.labelDefaultFont = g_sFontName
    contentMsgInfo.defaultStrokeColor = ccc3(0x49,0x00,0x00)
    contentMsgInfo.elements = {
        {
            text = itemData[1].name,
            color = ccc3(0xfe,0xdb,0x1c),
            font = g_sFontPangWa,
            size = 30,
        }
    }
    local contentMsgNode = GetLocalizeLabelSpriteBy_2(GetLocalizeStringBy("lic_1840"), contentMsgInfo)
    contentMsgNode:setAnchorPoint(ccp(0.5,0.5))
    contentMsgNode:setPosition(ccpsprite(0.5, 0.7, dialog))
    dialog:addChild(contentMsgNode)
    -- 一次最多兑换20次
    local contentCostNode = CCRenderLabel:create(GetLocalizeStringBy("lic_1841"),g_sFontName,22,1,ccc3(0x49,0x00,0x00),type_stroke)
    contentCostNode:setColor(ccc3(0xfe,0xdb,0x1c))
    contentCostNode:setAnchorPoint(ccp(0.5,0.5))
    contentCostNode:setPosition(ccpsprite(0.5, 0.35, dialog))
    dialog:addChild(contentCostNode)
   
    -- 改变数量
    dialog:registerChangeCallback(function ( p_selectNum )
    end)

    -- 确定
    dialog:registerOkCallback(function ()
        --刷新cell显示
        local selectNum = dialog:getNum()
        buyOverCallBack(selectNum)
    end)
    dialog:registerCancelCallback(function ()     
    end)   
end

-- 创建列表cell
local function createListCell( id, cellData )
    -- 材料个数
    local reqItemsData = ActiveCache.getListReqData(cellData.req)
    -- 排序
    local reqItems = {}
    for i=1,#cellData.seq do
        for k,v in pairs(reqItemsData) do
            if(tonumber(v.tid) == tonumber(cellData.seq[i]))then
                table.insert(reqItems,v)
                break
            end
        end
    end
    -- print("reqItems==")
    -- print_t(reqItems)
    local reqCount = table.count(reqItems)
    -- 大背景
    local fullRect = CCRectMake(0,0,116,124)
    local insetRect = CCRectMake(52,44,6,4)
    local cellBg = CCScale9Sprite:create("images/common/bg/change_bg.png",fullRect, insetRect)
    -- 二级背景
    local fullRect = CCRectMake(0, 0, 75, 75)
    local insetRect = CCRectMake(30, 30, 15, 10)
    local goodsBg = CCScale9Sprite:create("images/common/bg/goods_bg.png",fullRect, insetRect)
    if( reqCount < 4)then
        cellBg:setContentSize(CCSizeMake(614,283))
        goodsBg:setContentSize(CCSizeMake(574,150))
    else
        cellBg:setContentSize(CCSizeMake(614,503))
        goodsBg:setContentSize(CCSizeMake(574,370))
    end
    goodsBg:setAnchorPoint(ccp(0.5,0))
    goodsBg:setPosition(ccp(cellBg:getContentSize().width*0.5,78))
    cellBg:addChild(goodsBg)

    -- 名字
    local  descBg= CCScale9Sprite:create("images/sign/sign_bottom.png")
    descBg:setContentSize(CCSizeMake(250,55))
    descBg:setAnchorPoint(ccp(0,1))
    descBg:setPosition(ccp(3,cellBg:getContentSize().height))
    cellBg:addChild(descBg)
    local desStr =  ActivityConfig.ConfigCache.actExchange.data[tonumber(id)].name
    print("id",id,desStr)
    local desLabel = CCRenderLabel:create( desStr, g_sFontPangWa,25,1,ccc3(0x00,0x00,0x00),type_stroke)
    desLabel:setColor(ccc3(0xff,0xff,0xff))
    desLabel:setAnchorPoint(ccp(0.5,0.5))
    desLabel:setPosition(ccp(descBg:getContentSize().width*0.5,descBg:getContentSize().height*0.5+2))
    descBg:addChild(desLabel)

    -- 可用次数
    local font1 = CCLabelTTF:create(GetLocalizeStringBy("lic_1232"),g_sFontName,25)
    font1:setColor(ccc3(0x78,0x25,0x00))
    font1:setAnchorPoint(ccp(0,1))
    font1:setPosition(ccp(380,cellBg:getContentSize().height-20))
    cellBg:addChild(font1)
    -- 兑换次数
    local haveNum = cellData.soldNum
    local maxNum = ActiveCache.getMaxChangeNum(id)
    local numFont = CCLabelTTF:create("(" .. haveNum .. "/" .. maxNum .. ")",g_sFontName,25)
    numFont:setColor(ccc3(0x00,0x8d,0x3d))
    numFont:setAnchorPoint(ccp(0,1))
    numFont:setPosition(ccp(font1:getPositionX()+font1:getContentSize().width+2,font1:getPositionY()))
    cellBg:addChild(numFont)

    -- 材料坐标 
    local posX = _posXTab[reqCount]
    local posY = _posYTab[reqCount]
    -- 物品icon
    -- print("整理后材料：")
    -- print_t(reqItems)
    for i=1,#reqItems do
        -- 图标
        local iconSprite = getItemIconByData( reqItems[i],-340, 1010, -420)
        iconSprite:setAnchorPoint(ccp(0.5,0.5))
        iconSprite:setPosition(ccp(goodsBg:getContentSize().width*posX[i],goodsBg:getContentSize().height*posY[i]))
        goodsBg:addChild(iconSprite)

        -- 加号
        if(reqCount > 1)then
            local addPosX = _addPosXTab[reqCount-1]
            for i=1,#addPosX do
                local addSp = CCSprite:create("images/recharge/change/jia.png")
                addSp:setAnchorPoint(ccp(0.5,0.5))
                addSp:setPosition(ccp(goodsBg:getContentSize().width*addPosX[i],goodsBg:getContentSize().height*0.5))
                goodsBg:addChild(addSp)
            end
        end
    end

    -- 等号
    local equalSp = CCSprite:create("images/recharge/change/deng.png")
    equalSp:setAnchorPoint(ccp(0.5,0.5))
    equalSp:setPosition(ccp(goodsBg:getContentSize().width*_equalPosXTab[reqCount],goodsBg:getContentSize().height*0.5))
    goodsBg:addChild(equalSp)

    -- 目标物品icon
    local itemData = ActiveCache.getListDesItemData(cellData.acq)
    -- print("目标物品")
    -- print_t(itemData)
    -- 图标
    local iconSprite = getItemIconByData( itemData[1], -340, 1010, -420,true)
    iconSprite:setAnchorPoint(ccp(0.5,0.5))
    iconSprite:setPosition(ccp(goodsBg:getContentSize().width*_desPosXTab[reqCount],goodsBg:getContentSize().height*_desPosYTab[reqCount]))
    goodsBg:addChild(iconSprite)

    -- 按钮
    local menu = BTSensitiveMenu:create()
    if(menu:retainCount()>1)then
        menu:release()
        menu:autorelease()
    end
    menu:setAnchorPoint(ccp(0,0))
    menu:setPosition(ccp(0,0))
    cellBg:addChild(menu)
    menu:setTouchPriority(_touchPriority)

    -- 刷新按钮
    local normalSprite  = CCScale9Sprite:create("images/common/btn/btn_blue_n.png")
    normalSprite:setContentSize(CCSizeMake(190,64))
    local selectSprite  = CCScale9Sprite:create("images/common/btn/btn_blue_h.png")
    selectSprite:setContentSize(CCSizeMake(190,64))
    local refreshMenuItem = CCMenuItemSprite:create(normalSprite,selectSprite)
    refreshMenuItem:setAnchorPoint(ccp(0.5,0))
    refreshMenuItem:registerScriptTapHandler(refreshMenuItemAction)
    menu:addChild(refreshMenuItem,1,tonumber(id))

    -- 是否有免费刷新次数
    if( tonumber(cellData.free_refresh_num) > 0)then
        -- 免费刷新
        local  itemfont1 = CCRenderLabel:create( GetLocalizeStringBy("lic_1164"), g_sFontPangWa, 30, 1, ccc3(0x00,0x00,0x00), type_stroke)
        itemfont1:setAnchorPoint(ccp(0.5,0.5))
        itemfont1:setColor(ccc3(0xfe,0xdb,0x1c))
        itemfont1:setPosition(ccp(refreshMenuItem:getContentSize().width*0.5,refreshMenuItem:getContentSize().height*0.5))
        refreshMenuItem:addChild(itemfont1)
    else
        -- 金币刷新
        local  itemfont1 = CCRenderLabel:create( GetLocalizeStringBy("lic_1011"), g_sFontPangWa, 30, 1, ccc3(0x00,0x00,0x00), type_stroke)
        itemfont1:setAnchorPoint(ccp(0,0.5))
        itemfont1:setColor(ccc3(0xfe,0xdb,0x1c))
        itemfont1:setPosition(ccp(27,refreshMenuItem:getContentSize().height*0.5))
        refreshMenuItem:addChild(itemfont1)
        local goldSp = CCSprite:create("images/common/gold.png")
        goldSp:setAnchorPoint(ccp(0,0.5))
        goldSp:setPosition(ccp(itemfont1:getPositionX()+itemfont1:getContentSize().width+5,refreshMenuItem:getContentSize().height*0.5))
        refreshMenuItem:addChild(goldSp)
        -- 价格
        local curRefreshNum = tonumber(cellData.refresh_num)
        local price = ActiveCache.getChangeRefreshGold(curRefreshNum,id)
        local priceFont = CCLabelTTF:create(price,g_sFontPangWa, 21)
        priceFont:setAnchorPoint(ccp(0,0.5))
        priceFont:setColor(ccc3(0xfe,0xdb,0x1c))
        priceFont:setPosition(ccp(goldSp:getPositionX()+goldSp:getContentSize().width+3,refreshMenuItem:getContentSize().height*0.5))
        refreshMenuItem:addChild(priceFont)
    end

    -- 兑换按钮
    local menuItem = CCMenuItemImage:create("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png")
    menuItem:setAnchorPoint(ccp(0.5,0))
    menu:addChild(menuItem,1,tonumber(id))
    -- 兑换字体
    local menuItemFont = CCRenderLabel:create( GetLocalizeStringBy("lic_1009"), g_sFontPangWa, 30, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    menuItemFont:setColor(ccc3(0xfe, 0xdb, 0x1c))
    menuItemFont:setAnchorPoint(ccp(0.5,0.5))
    menuItemFont:setPosition(ccp(menuItem:getContentSize().width*0.5,menuItem:getContentSize().height*0.5))
    menuItem:addChild(menuItemFont)
    -- 注册兑换回调
    menuItem:registerScriptTapHandler(menuItemCallFun)
    -- local haveNum = tonumber(_serviceData.goods_list[tostring(tag)].soldNum)
    -- local maxNum = ActiveCache.getMaxChangeNum(tag)
    if(tonumber(haveNum) >= tonumber(maxNum))then
        menuItem:setVisible(false)
        local hasReceiveItem = CCSprite:create("images/common/yiduihuan.png")
        hasReceiveItem:setAnchorPoint(ccp(0.5,0))
        local isShowRefreshBtn = ActivityConfig.ConfigCache.actExchange.data[tonumber(id)].isRefresh
        if(tonumber(isShowRefreshBtn) == 0)then
             hasReceiveItem:setPosition(ccp(cellBg:getContentSize().width*0.5,25))
        else
            hasReceiveItem:setPosition(ccp(cellBg:getContentSize().width*0.7,25)) 
        end
        cellBg:addChild(hasReceiveItem)
        -- return
    end
    
    -- 是否显示刷新按钮
    local isShowRefreshBtn = ActivityConfig.ConfigCache.actExchange.data[tonumber(id)].isRefresh
    if(tonumber(isShowRefreshBtn) == 0)then
        -- 不显示
        refreshMenuItem:setVisible(false)
        menuItem:setPosition(ccp(cellBg:getContentSize().width*0.5, 15))
    else
        -- 显示刷新按钮
        refreshMenuItem:setPosition(ccp(cellBg:getContentSize().width*0.3, 15))
        menuItem:setPosition(ccp(cellBg:getContentSize().width*0.7, 15))
    end
    return cellBg
end

local function createContainerLayer( ... )
     print("createContainerLayer")
    local containerLayer = CCNode:create()
    containerLayer:setContentSize(CCSizeMake(630,0))
    local cellHeight = 10
    -- 当前第几天配置 0是第一天
    local todayData = ActiveCache.getTodayData(tonumber(_serviceData.day)+1)
    print("todayData==")
    print_t(todayData)
    for i=#todayData,1,-1 do
        for k,v in pairs(_serviceData.goods_list) do
            if(tonumber(k) == tonumber(todayData[i]))then
                print("k==",k,"todayData[i]",todayData[i],"i",i)
                local cell = createListCell(k,v)
                cell:setAnchorPoint(ccp(0.5,0))
                cell:setPosition(ccp(containerLayer:getContentSize().width*0.5,cellHeight))
                containerLayer:addChild(cell)
                -- 累积高度
                cellHeight = cellHeight+cell:getContentSize().height+10
                break
            end
        end
    end
    -- 设置containerLayer的size
    containerLayer:setContentSize(CCSizeMake(630,cellHeight))
    return containerLayer
end

-- 创建scrollView
function createScrollView( ... )
    -- scrollView
    if(_listView ~= nil)then
        _listView:removeFromParentAndCleanup(true)
        _listView = nil
    end
    _listView = CCScrollView:create()
    _listView:setViewSize(CCSizeMake(_listWidth, _listHight/g_fScaleX-6))
    _listView:setBounceable(true)
    _listView:setTouchPriority(_touchPriority-5)
    -- 垂直方向滑动
    _listView:setDirection(kCCScrollViewDirectionVertical)
    _listView:setPosition(ccp(0,3))
    _listBg:addChild(_listView)
    -- 创建显示内容layer Container
    local containerLayer = createContainerLayer()
    _listView:setContainer(containerLayer)
    print("setContainer")
    _listView:setContentOffset(ccp(0,_listView:getViewSize().height-containerLayer:getContentSize().height))
end

-- 0点免费刷新
local function freeRefreshFun( ... )
    -- 网络请求回调
    local function getActiveInfoCallBack( cbFlag, dictData, bRet )
        if(dictData.err == "ok") then
            -- print("changeActiveInfo:")
            -- print_t(dictData.ret)
            -- 网络数据
            _serviceData = nil
            _serviceData = dictData.ret  
            -- 重新创建列表
            local offset = nil
            if(_listView ~= nil)then
                offset = _listView:getContentOffset()
            end
            createScrollView()
            if(offset)then
                _listView:setContentOffset(offset)
            end
        end
    end
    Network.rpc(getActiveInfoCallBack, "actexchange.getShopInfo", "actexchange.getShopInfo", nil, true)
end 

-- 活动0点系统免费刷新
local function freeRefresh( ... )
    if(_bgLayer ~= nil)then
        local subTime = tonumber(_serviceData.sys_refresh_cd) - TimeUtil.getSvrTimeByOffset(0)
        if(subTime > 0)then
            local actionArray = CCArray:create()
            actionArray:addObject(CCDelayTime:create(subTime))
            actionArray:addObject(CCCallFunc:create(freeRefreshFun))
            _bgLayer:runAction(CCSequence:create(actionArray))
        end
    end
end

-- 活动结束倒计时
local function timeDownFun( ... )
    if(_timeFont ~= nil)then
        local subNum = tonumber(ActivityConfig.ConfigCache.actExchange.end_time) - TimeUtil.getSvrTimeByOffset(0)
        if(subNum > 0)then
            local str = TimeUtil.getInternationalRemainFormat(subNum)
            _timeFont:setString(str)
        else
            _timeFont:stopAllActions()
            _timeFont:setString(GetLocalizeStringBy("lic_1010"))
        end

        local actionArray = CCArray:create()
        actionArray:addObject(CCDelayTime:create(1))
        actionArray:addObject(CCCallFunc:create(timeDownFun))
        _timeFont:runAction(CCSequence:create(actionArray))
    end
end

-- 初始化界面
local function initChangeActiveLayer( ... )
    require "script/ui/main/BulletinLayer"
    local bulletinLayerSize = RechargeActiveMain.getTopSize()
	local topMenuHeight = RechargeActiveMain.getBgWidth()+bulletinLayerSize.height*g_fScaleX
	-- 标题背景
    _titleBg = CCScale9Sprite:create("images/recharge/change/" .. ActivityConfig.ConfigCache.actExchange.data[1].title_bg)
    _titleBg:setAnchorPoint(ccp(0.5,1))
    _titleBg:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height-topMenuHeight))
    _bgLayer:addChild(_titleBg)
    _titleBg:setScale(g_fScaleX)

    -- 标题
    local titleSprite = CCSprite:create("images/recharge/change/" .. ActivityConfig.ConfigCache.actExchange.data[1].title )
	titleSprite:setAnchorPoint(ccp(0.5,1))
	titleSprite:setPosition(ccp(_titleBg:getContentSize().width*0.5,_titleBg:getContentSize().height-10))
	_titleBg:addChild(titleSprite)
	
    -- 开放时间
    local timeFont = CCRenderLabel:create( GetLocalizeStringBy("lic_1015"), g_sFontPangWa,18,1,ccc3(0x00,0x00,0x00),type_stroke)
    timeFont:setColor(ccc3(0x00,0xe4,0xff))
    timeFont:setAnchorPoint(ccp(1,0.5))
    timeFont:setPosition(ccp(137,47))
    _titleBg:addChild(timeFont)
    -- 开始时间 --- 结束时间
    -- 开始时间
    local startTime = tonumber(ActivityConfig.ConfigCache.actExchange.start_time)
    local startTimeStr = TimeUtil.getInternationalDateFormat( startTime )
    -- 结束时间
    local endTime = tonumber(ActivityConfig.ConfigCache.actExchange.end_time)
    local endTimeStr = TimeUtil.getInternationalDateFormat( endTime )
    local timeStr = startTimeStr .. " —— " ..  endTimeStr
    local timeStr_font = CCRenderLabel:create( timeStr, g_sFontPangWa,18,1,ccc3(0x00,0x00,0x00),type_stroke)
    timeStr_font:setColor(ccc3(0x00,0xff,0x18))
    timeStr_font:setAnchorPoint(ccp(0,0.5))
    timeStr_font:setPosition(ccp(timeFont:getPositionX()+5,timeFont:getPositionY()))
    _titleBg:addChild(timeStr_font)

    -- 活动剩余时间
    local font1 = CCRenderLabel:create(GetLocalizeStringBy("lic_1012"),g_sFontPangWa,18,1,ccc3(0x00,0x00,0x00),type_stroke)
    font1:setColor(ccc3(0x00,0xe4,0xff))
    font1:setAnchorPoint(ccp(1,0))
    font1:setPosition(ccp(137,10))
    _titleBg:addChild(font1)
    -- 时间倒计时
    local endTimeNum = tonumber(ActivityConfig.ConfigCache.actExchange.end_time) - TimeUtil.getSvrTimeByOffset(0)
    local endTimeStr = TimeUtil.getInternationalRemainFormat(endTimeNum)
    _timeFont = CCLabelTTF:create(endTimeStr,g_sFontPangWa,18)
    _timeFont:setColor(ccc3(0x00,0xff,0x18))
    _timeFont:setAnchorPoint(ccp(0,0))
    _timeFont:setPosition(ccp(font1:getPositionX()+5,font1:getPositionY()))
    _titleBg:addChild(_timeFont)

    -- 倒计时
    timeDownFun()

    -- 0点免费刷新
    freeRefresh()

    -- 兑换预览
    local menu = CCMenu:create()
    menu:setAnchorPoint(ccp(0,0))
    menu:setPosition(ccp(0,0))
    _titleBg:addChild(menu)
    menu:setTouchPriority(_touchPriority-10)
    local menuItem = CCMenuItemImage:create("images/recharge/change/yulan_n.png","images/recharge/change/yulan_h.png")
    menuItem:setAnchorPoint(ccp(1,0.5))
    menuItem:setPosition(ccp(_titleBg:getContentSize().width-10, _titleBg:getContentSize().height*0.5))
    menu:addChild(menuItem)
    menuItem:registerScriptTapHandler(showChangeItem)

    -- 列表背景
    local fullRect = CCRectMake(0,0,116,124)
    local insetRect = CCRectMake(50,50,6,4)
    _listBg = CCScale9Sprite:create("images/recharge/change/" .. ActivityConfig.ConfigCache.actExchange.data[1].list_bg,fullRect, insetRect) -- 中秋兑换
    _listHight = _titleBg:getPositionY()-_titleBg:getContentSize().height*g_fScaleX - (MenuLayer.getHeight()+25*g_fScaleX)
    _listWidth = 630
    _listBg:setContentSize(CCSizeMake(_listWidth,_listHight/g_fScaleX))
    _listBg:setAnchorPoint(ccp(0.5,1))
    _listBg:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_titleBg:getPositionY()-_titleBg:getContentSize().height*g_fScaleX))
    _bgLayer:addChild(_listBg)
    _listBg:setScale(g_fScaleX)
    
    -- 创建列表
    createScrollView()
end

-- 网络请求回调
local function getActiveInfoCallBack( cbFlag, dictData, bRet )
    if(dictData.err == "ok") then
        -- print("changeActiveInfo:")
        -- print_t(dictData.ret)
        -- 网络数据
        _serviceData = dictData.ret    

        -- 初始化界面
        initChangeActiveLayer()
    end
end

-- 创建兑换界面
function createChangeLayer( ... )
	init()
	_bgLayer = CCLayer:create()
    _bgLayer:registerScriptHandler(onNodeEvent)
    
    -- 中秋大背景
    if(ActivityConfig.ConfigCache.actExchange.data[1].act_bg ~= nil and string.len(ActivityConfig.ConfigCache.actExchange.data[1].act_bg) > 0 )then
        local bgSprite = CCScale9Sprite:create("images/recharge/change/" .. ActivityConfig.ConfigCache.actExchange.data[1].act_bg)
        bgSprite:setContentSize(CCSizeMake(_bgLayer:getContentSize().width,_bgLayer:getContentSize().height))
        bgSprite:setAnchorPoint(ccp(0.5,0.5))
        bgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
        _bgLayer:addChild(bgSprite)
        bgSprite:setScale(g_fScaleX)
    end

    -- 拉取兑换数据
	Network.rpc(getActiveInfoCallBack, "actexchange.getShopInfo", "actexchange.getShopInfo", nil, true)
	return _bgLayer
end


