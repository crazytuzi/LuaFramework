-- FileName: BarnExchangeLayer.lua
-- Author:  Zhang Zihang
-- Date: 14-11-6
-- Purpose: 粮草兑换页面

module("BarnExchangeLayer", package.seeall)

require "script/utils/BaseUI"
require "script/libs/LuaCC"
require "script/ui/guild/liangcang/BarnService"
require "script/ui/guild/liangcang/BarnData"
require "script/ui/guild/GuildDataCache"
require "script/ui/item/ItemSprite"
require "script/ui/hero/HeroPublicLua"
require "script/ui/tip/AnimationTip"
require "script/ui/rechargeActive/ActiveUtil"
require "script/ui/item/ReceiveReward"

local _bgLayer
local _priority
local _zOrder
local _cornNumLabel             --个人粮草数量label
local _exTableView
local _meritNumLabel
local _visibleNum
local _centerLayer
----------------------------------------初始化函数----------------------------------------
--[[
    @des    :初始化函数
    @param  :
    @return :
--]]
function init()
     _bgLayer = nil
    _priority = nil
    _zOrder = nil
    _cornNumLabel = nil
    _exTableView = nil
    _meritNumLabel = nil
    _visibleNum = nil
    _centerLayer = nil
end

----------------------------------------事件函数----------------------------------------
--[[
    @des    :事件注册函数
    @param  :事件类型
    @return :
--]]
function onTouchesHandler(eventType)
    if (eventType == "began") then
        return true
    elseif (eventType == "moved") then
        print("moved")
    else
        print("end")
    end
end

--[[
    @des    :事件注册函数
    @param  :事件
    @return :
--]]
function onNodeEvent(event)
    if event == "enter" then
        -- _bgLayer:registerScriptTouchHandler(onTouchesHandler,false,_priority,true)
        --_bgLayer:setTouchEnabled(true)

        GuildDataCache.setIsInGuildFunc(true)
    elseif eventType == "exit" then
        --_bgLayer:unregisterScriptTouchHandler()

        GuildDataCache.setIsInGuildFunc(false)
    end
end

--[[
    @des    :关闭界面回调
    @param  :
    @return :
--]]
function closeCallBack()

    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    if not tolua.isnull(_bgLayer) then
        _bgLayer:removeFromParentAndCleanup(true)
    end
end

--[[
    @des    :得到奖励
    @param  : $ tag         :tag值
    @param  : $ item        :点击的那个元素
    @return :
--]]
function getPrizeCallBack(tag,item)
    --物品的DB数据
    local DBInfo = BarnData.getShopDBInfo(tag)

    --剩余兑换数目
    local remainNum = DBInfo.exchangeTimes - BarnData.getShopInfoById(tag)

    --如果需要开启等级大于粮仓等级，则表示未开启
    if DBInfo.granaryLv > GuildDataCache.getGuildBarnLv() then
        AnimationTip.showTip(GetLocalizeStringBy("zzh_1188"))
        --如果兑换数量已用尽
    elseif remainNum <= 0 then
        if DBInfo.limitType == 1 then
            AnimationTip.showTip(GetLocalizeStringBy("zzh_1189"))
        else
            AnimationTip.showTip(GetLocalizeStringBy("zzh_1211"))
        end
        --如果兑换所需粮草不足
    elseif  DBInfo.costForage ~= nil and DBInfo.costForage > GuildDataCache.getMyselfGrainNum() then
        AnimationTip.showTip(GetLocalizeStringBy("zzh_1190"))
        --所需功勋值不足
    elseif DBInfo.costExploit ~= nil and DBInfo.costExploit > GuildDataCache.getMyselfMeritNum() then
        AnimationTip.showTip(GetLocalizeStringBy("zzh_1206"))
        --背包满了
    elseif ItemUtil.isBagFull() then
        return
        --满足兑换条件，可以兑换
    else
        --购买回调
        local buyOverCallBack = function(p_num)
            --剩余兑换次数，并刷新UI
            remainNum = DBInfo.exchangeTimes - BarnData.getShopInfoById(tag)
            local baseMenu = tolua.cast(item:getParent(),"CCMenu")
            local baseSprite = tolua.cast(baseMenu:getParent(),"CCScale9Sprite")
            local numLabel = tolua.cast(baseSprite:getChildByTag(100),"CCRenderLabel")
            if DBInfo.limitType == 1 then
                numLabel:setString(GetLocalizeStringBy("zzh_1183") .. remainNum .. GetLocalizeStringBy("zz_124"))
            elseif DBInfo.limitType == 2 then
                numLabel:setString(GetLocalizeStringBy("zzh_1208") .. remainNum .. GetLocalizeStringBy("zz_124"))
            else
                numLabel:setString(GetLocalizeStringBy("zzh_1210") .. remainNum .. GetLocalizeStringBy("zz_124"))
            end

            local costCorn = DBInfo.costForage or 0
            local costExploit = DBInfo.costExploit or 0

            local cornNum = costCorn*p_num
            local exploitNum = costExploit*p_num

            local splitString = string.split(DBInfo.id,"|")
            local newNum = tonumber(splitString[3])*p_num
            local newString = splitString[1] .. "|" .. splitString[2] .. "|" .. newNum

            ItemUtil.addRewardByTable(BarnData.analyzeDBItem(newString))

            --刷新个人粮草数目
            GuildDataCache.setMyselfGrainNum(GuildDataCache.getMyselfGrainNum() - cornNum)
            --刷新个人功勋值
            GuildDataCache.setMyselfMeritNum(GuildDataCache.getMyselfMeritNum() - exploitNum)
            _cornNumLabel:setString(GuildDataCache.getMyselfGrainNum())
            _meritNumLabel:setString(GuildDataCache.getMyselfMeritNum())

            local rewardOkCallBack = function()
                BarnData.dealVisibleOrNot()

                local contentOffset = _exTableView:getContentOffset()
                if _visibleNum > BarnData.getVisibleNum() then
                    contentOffset.y = contentOffset.y + 190*g_fScaleX
                    _visibleNum = BarnData.getVisibleNum()
                end

                _exTableView:reloadData()

                _exTableView:setContentOffset(contentOffset)
            end
            rewardOkCallBack()
            ReceiveReward.showRewardWindow(BarnData.analyzeDBItem(newString),nil,nil,_priority - 45)
        end

        local sureCallBack = function(p_num)
            if  DBInfo.costForage ~= nil and DBInfo.costForage*p_num > GuildDataCache.getMyselfGrainNum() then
                AnimationTip.showTip(GetLocalizeStringBy("zzh_1206"))
                --所需功勋值不足
            elseif DBInfo.costExploit ~= nil and DBInfo.costExploit*p_num > GuildDataCache.getMyselfMeritNum() then
                AnimationTip.showTip(GetLocalizeStringBy("zzh_1206"))
            else
                BarnService.exchangeItem(tag,p_num,buyOverCallBack)
            end
        end

        local _,paramName = ItemUtil.createGoodsIcon(BarnData.analyzeDBItem(DBInfo.id)[1])

        require "script/ui/common/BatchExchangeLayer"
        local paramTable = {}
        paramTable.title = GetLocalizeStringBy("key_2342")
        paramTable.first = GetLocalizeStringBy("key_1438")
        paramTable.max = remainNum
        paramTable.name = paramName
        paramTable.need = {}
        if DBInfo.costExploit ~= nil then
            local localTable = {needName = GetLocalizeStringBy("zzh_1239"),
                sprite = "images/common/gongxun.png",
                classes = 1,
                price = DBInfo.costExploit}
            table.insert(paramTable.need,localTable)
        end

        if DBInfo.costForage ~= nil then
            local localTable = {needName = GetLocalizeStringBy("zzh_1240"),
                sprite = "images/barn/corn.png",
                classes = 2,
                price = DBInfo.costForage}
            table.insert(paramTable.need,localTable)
        end

        BatchExchangeLayer.showBatchLayer(paramTable,sureCallBack,_priority - 30)
    end
end

----------------------------------------UI函数----------------------------------------
--[[
    @des    :创建tableView中的cell
    @param  :物品id
    @return :创建好的cell
--]]
function createCell(p_id)
    local tCell = CCTableViewCell:create()
    --背景图片
    local cellBgSprite = CCScale9Sprite:create("images/common/bg/bg_9s_4.png")
    cellBgSprite:setContentSize(CCSizeMake(454, 182))
    -- cellBgSprite:setAnchorPoint(ccp(0,0))
    -- cellBgSprite:setPosition(ccp(35/2,5/2))
    cellBgSprite:setScale(g_fScaleX)
    tCell:addChild(cellBgSprite)

    --二级背景图片
    local innerBgSprite = CCScale9Sprite:create("images/copy/fort/textbg.png")
    innerBgSprite:setContentSize(CCSizeMake(300,120))
    -- innerBgSprite:setScale(g_fElementScaleRatio)
    innerBgSprite:setAnchorPoint(ccp(0,0))
    innerBgSprite:setPosition(ccp(25,45))
    cellBgSprite:addChild(innerBgSprite)

    --物品的DB数据
    local DBInfo = BarnData.getShopDBInfo(p_id)

    local iconString = BarnData.analyzeDBItem(DBInfo.id)[1]

    --显示菜单栏回调
    local function showDownMenu()
        MainScene.setMainSceneViewsVisible(false,false,false)
    end

    --物品图片
    --local itemSprite,itemName,itemColor = ItemUtil.createGoodsIcon(iconString,_priority - 3,nil,nil,showDownMenu,nil,nil,false)
    local itemSprite,itemName,itemColor = ItemUtil.createGoodsIcon(iconString,nil,nil,-900,showDownMenu,nil,nil,false)
    itemSprite:setAnchorPoint(ccp(0,0.5))
    itemSprite:setPosition(ccp(10,innerBgSprite:getContentSize().height/2))
    innerBgSprite:addChild(itemSprite)

    --文字位置
    local namePosX = 10+ itemSprite:getContentSize().width/2 + innerBgSprite:getContentSize().width/2
    --文字距离边的距离
    local gapLenth = 20

    --物品名称
    --local itemNameLabel = CCRenderLabel:create(DBInfo.name,g_sFontPangWa,24,1,ccc3(0x00,0x00,0x00),type_stroke)
    local itemNameLabel = CCRenderLabel:create(itemName,g_sFontPangWa,24,1,ccc3(0x00,0x00,0x00),type_stroke)
    --itemNameLabel:setColor(HeroPublicLua.getCCColorByStarLevel(DBInfo.quality))
    itemNameLabel:setColor(itemColor)
    itemNameLabel:setAnchorPoint(ccp(0.5,1))
    itemNameLabel:setPosition(ccp(namePosX,innerBgSprite:getContentSize().height - gapLenth + 10))
    innerBgSprite:addChild(itemNameLabel)

    local cornVisible
    local warVisible
    local cornPosition
    local warPosition

    local cornNum = DBInfo.costForage or 0
    local exploitNum = DBInfo.costExploit or 0

    if DBInfo.costForage ~= nil and DBInfo.costExploit == nil then
        cornVisible = true
        warVisible = false
        cornPosition = ccp(namePosX,gapLenth + 10)
        warPosition = ccp(namePosX,gapLenth)
    elseif DBInfo.costForage == nil and DBInfo.costExploit ~= nil then
        cornVisible = false
        warVisible = true
        cornPosition = ccp(namePosX,gapLenth + 10)
        warPosition = ccp(namePosX,gapLenth + 10)
    else
        cornVisible = true
        warVisible = true
        cornPosition = ccp(namePosX,gapLenth + 25)
        warPosition = ccp(namePosX,gapLenth - 10)
    end

    --文字 粮草
    local cornLabel = CCRenderLabel:create(GetLocalizeStringBy("zzh_1182"),g_sFontName,23,1,ccc3(0x00,0x00,0x00),type_stroke)
    cornLabel:setColor(ccc3(0xff,0xf6,0x00))
    --粮草图
    local cornSprite = CCSprite:create("images/barn/corn.png")
    --冒号
    local commaLabel = CCRenderLabel:create(":",g_sFontName,23,1,ccc3(0x00,0x00,0x00),type_stroke)
    commaLabel:setColor(ccc3(0xff,0xf6,0x00))
    --需要粮草数量
    local needNumLabel = CCRenderLabel:create(cornNum,g_sFontName,23,1,ccc3(0x00,0x00,0x00),type_stroke)
    needNumLabel:setColor(ccc3(0xff,0xff,0xff))

    --合并
    local connectNode = BaseUI.createHorizontalNode({cornLabel,cornSprite,commaLabel,needNumLabel})
    connectNode:setAnchorPoint(ccp(0.5,0))
    connectNode:setPosition(cornPosition)
    connectNode:setVisible(cornVisible)
    innerBgSprite:addChild(connectNode)

    --文字 功勋
    local exploitLabel = CCRenderLabel:create(GetLocalizeStringBy("zzh_1205"),g_sFontName,23,1,ccc3(0x00,0x00,0x00),type_stroke)
    exploitLabel:setColor(ccc3(0xff,0xf6,0x00))
    --粮草图
    local exploitSprite = CCSprite:create("images/common/gongxun.png")
    --冒号
    local commaLabel = CCRenderLabel:create(":",g_sFontName,23,1,ccc3(0x00,0x00,0x00),type_stroke)
    commaLabel:setColor(ccc3(0xff,0xf6,0x00))
    --需要粮草数量
    local needNumLabel = CCRenderLabel:create(exploitNum,g_sFontName,23,1,ccc3(0x00,0x00,0x00),type_stroke)
    needNumLabel:setColor(ccc3(0xff,0xff,0xff))

    --合并
    local connectNode = BaseUI.createHorizontalNode({exploitLabel,exploitSprite,commaLabel,needNumLabel})
    connectNode:setAnchorPoint(ccp(0.5,0))
    connectNode:setPosition(warPosition)
    connectNode:setVisible(warVisible)
    innerBgSprite:addChild(connectNode)

    --剩余兑换数目
    local remainNum = DBInfo.exchangeTimes - BarnData.getShopInfoById(p_id)

    if remainNum < 0 then
        remainNum = 0
    end

    --提示的位置
    local tipPosY = 25

    --今日可兑换多少次
    local canRewardLabel
    --每日可兑换次数
    if DBInfo.limitType == 1 then
        canRewardLabel = CCRenderLabel:create(GetLocalizeStringBy("zzh_1183") .. remainNum .. GetLocalizeStringBy("zz_124"),g_sFontName,18,1,ccc3(0x00,0x00,0x00),type_stroke)
        --总共可兑换
    elseif DBInfo.limitType == 2 then
        canRewardLabel = CCRenderLabel:create(GetLocalizeStringBy("zzh_1208") .. remainNum .. GetLocalizeStringBy("zz_124"),g_sFontName,18,1,ccc3(0x00,0x00,0x00),type_stroke)
        --本周可兑换
    else
        canRewardLabel = CCRenderLabel:create(GetLocalizeStringBy("zzh_1210") .. remainNum .. GetLocalizeStringBy("zz_124"),g_sFontName,18,1,ccc3(0x00,0x00,0x00),type_stroke)
    end
    canRewardLabel:setColor(ccc3(0x00,0xff,0x18))
    -- canRewardLabel:setScale(g_fElementScaleRatio)
    canRewardLabel:setAnchorPoint(ccp(0,0))
    canRewardLabel:setPosition(ccp(35,tipPosY))
    cellBgSprite:addChild(canRewardLabel,1,100)

    --按钮层
    local cellMenu = CCMenu:create()
    cellMenu:setAnchorPoint(ccp(0,0))
    cellMenu:setPosition(ccp(0,0))
    cellMenu:setTouchPriority(_priority - 2)
    cellBgSprite:addChild(cellMenu)

    --按钮位置
    local btnPosX = (cellBgSprite:getContentSize().width  + innerBgSprite:getContentSize().width)/2 -15*g_fScaleX

    --兑换按钮
    local exchangeMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_shop_n.png","images/common/btn/btn_shop_h.png",
        CCSizeMake(120,80),GetLocalizeStringBy("key_2689"),ccc3(0xff,0xe4,0x00),30,g_sFontPangWa,1,ccc3(0x00,0x00,0x00))
    exchangeMenuItem:setAnchorPoint(ccp(0,0.5))
    exchangeMenuItem:setPosition(ccp(innerBgSprite:getPositionX()+innerBgSprite:getContentSize().width,innerBgSprite:getPositionY()+innerBgSprite:getContentSize().height/2))
    exchangeMenuItem:registerScriptTapHandler(getPrizeCallBack)
    cellMenu:addChild(exchangeMenuItem,1,p_id)

    --如果需要开启级别大于当前粮仓等级，则显示需要兑换级别
    if DBInfo.granaryLv > GuildDataCache.getGuildBarnLv() then
        --需要开启级别
        local needOpenLvLabel_1 = CCLabelTTF:create(GetLocalizeStringBy("zzh_1186"),g_sFontName,21)
        needOpenLvLabel_1:setColor(ccc3(0x78,0x25,0x00))
        local openLvLabel = CCLabelTTF:create(DBInfo.granaryLv,g_sFontName,21)
        openLvLabel:setColor(ccc3(0xf4,0x00,0x00))
        local needOpenLvLabel_2 = CCLabelTTF:create(GetLocalizeStringBy("zzh_1187"),g_sFontName,21)
        needOpenLvLabel_2:setColor(ccc3(0x78,0x25,0x00))

        --合并
        local openLvNode = BaseUI.createHorizontalNode({needOpenLvLabel_1,openLvLabel,needOpenLvLabel_2})
        openLvNode:setAnchorPoint(ccp(0.5,0))
        openLvNode:setPosition(ccp(btnPosX,tipPosY))
        cellBgSprite:addChild(openLvNode)
    end
     if remainNum <= 0 then
        exchangeMenuItem:setVisible(false)
        local hasReceiveItem = CCSprite:create("images/common/yiduihuan.png")
        hasReceiveItem:setAnchorPoint(ccp(0,0.5))
        hasReceiveItem:setPosition(ccp(innerBgSprite:getPositionX()+innerBgSprite:getContentSize().width,innerBgSprite:getPositionY()+innerBgSprite:getContentSize().height/2))
        cellBgSprite:addChild(hasReceiveItem)
    end
    return tCell
end

--[[
    @des    :创建tableView
    @param  :参数table
    @return :创建好的tableView
--]]
function createTableView(p_param)
    _visibleNum = BarnData.getVisibleNum()

    local h = LuaEventHandler:create(function(fn,table,a1,a2)
        local r
        if fn == "cellSize" then
            r = CCSizeMake(454*g_fScaleX, 182*g_fScaleX)
        elseif fn == "cellAtIndex" then
            a2 = createCell(BarnData.getIdTable()[_visibleNum - a1])
            -- a2:setScale(g_fScaleX)
            r = a2
        elseif fn == "numberOfCells" then
            --r = BarnData.getItemNum()
            r = _visibleNum
        else
            print("other function")
        end

        return r
    end)

    return LuaTableView:createWithHandler(h, p_param.bgSize)
end

--[[
    @des    :创建UI
    @param  :
    @return :
--]]
function createUI()

    --个人粮草 文字
    local ownTipLabel = CCRenderLabel:create(GetLocalizeStringBy("fqq_007"),g_sFontPangWa,23,2,ccc3(0x00,0x00,0x00),type_shadow)
    ownTipLabel:setColor(ccc3(0xff,0xf6,0x00))
    --粮草图
    local cornSprite = CCSprite:create("images/barn/corn.png")

    --粮草数量
    _cornNumLabel = CCRenderLabel:create(GuildDataCache.getMyselfGrainNum(),g_sFontPangWa,23,2,ccc3(0x00,0x00,0x00),type_shadow)
    _cornNumLabel:setColor(ccc3(0x00,0xff,0x18))

    --连接Node
    connectNode1 = BaseUI.createHorizontalNode({ownTipLabel,cornSprite,_cornNumLabel})
    connectNode1:setAnchorPoint(ccp(0.5,1))
    connectNode1:setScale(g_fElementScaleRatio)
    connectNode1:setPosition(ccp(_centerLayer:getContentSize().width*0.43,_centerLayer:getContentSize().height-60*g_fScaleX))
    _centerLayer:addChild(connectNode1)


    --个人功勋 文字
    local ownTipLabel_1 = CCRenderLabel:create(GetLocalizeStringBy("fqq_008"),g_sFontPangWa,23,2,ccc3(0x00,0x00,0x00),type_shadow)
    ownTipLabel_1:setColor(ccc3(0xff,0xf6,0x00))
    --功勋图
    local cornSprite_1 = CCSprite:create("images/common/gongxun.png")
    --粮草数量
    _meritNumLabel = CCRenderLabel:create(GuildDataCache.getMyselfMeritNum(),g_sFontPangWa,23,2,ccc3(0x00,0x00,0x00),type_shadow)
    _meritNumLabel:setColor(ccc3(0x00,0xff,0x18))

    --连接Node
    local connectNode = BaseUI.createHorizontalNode({ownTipLabel_1,cornSprite_1,_meritNumLabel})
    connectNode:setAnchorPoint(ccp(0.5,1))
    connectNode:setScale(g_fElementScaleRatio)
    connectNode:setPosition(ccp(_centerLayer:getContentSize().width*0.5+connectNode1:getContentSize().width*g_fElementScaleRatio,_centerLayer:getContentSize().height-60*g_fScaleX))
    _centerLayer:addChild(connectNode)


    local height = connectNode:getPositionY()- connectNode:getContentSize().height*g_fElementScaleRatio -30*g_fScaleX
    local viewBgSprite = CCScale9Sprite:create(CCRectMake(50,50,6,4),"images/common/bg/9s_1.png")
    viewBgSprite:setContentSize(CCSizeMake(460*g_fScaleX, height))
    viewBgSprite:setAnchorPoint(ccp(1,1))
    viewBgSprite:setPosition(ccp(g_winSize.width - 10*g_fScaleX,connectNode:getPositionY()- connectNode:getContentSize().height*g_fElementScaleRatio))
    _centerLayer:addChild(viewBgSprite, 10)
    --创建tableView
    --本来应该新建文件写的，可是文件夹嵌套层次太深了，不好查bug，所以这里写一起吧
    --既然在内部，调用就用table吧，传地址省空间
    local paramTable = {}

    paramTable.bgSize = CCSizeMake(450*g_fScaleX,height-10)

    _exTableView = createTableView(paramTable)
    _exTableView:setAnchorPoint(ccp(0,0))
    _exTableView:setPosition(ccp(0,10))
    _exTableView:setTouchPriority(_priority - 2)
    viewBgSprite:addChild(_exTableView)
end

--[[
    @des    :防走光UI
    @param  :
    @return :
--]]
function createBaseUI()
    if not _isShow then
        --背景
        local underLayer = CCScale9Sprite:create("images/barn/under_hong.png")
        underLayer:setContentSize(_centerSize)
        underLayer:setAnchorPoint(ccp(0,0))
        underLayer:setPosition(ccp(0,0))
        _centerLayer:addChild(underLayer)

        --上波浪
        local up = CCSprite:create("images/match/shang.png")
        up:setAnchorPoint(ccp(0,1))
        up:setPosition(ccp(0, _centerSize.height))
        up:setScale(g_fScaleX)
        underLayer:addChild(up)
        --下波浪
        local down = CCSprite:create("images/match/xia.png")
        down:setPosition(ccp(0,0))
        down:setScale(g_fScaleX)
        underLayer:addChild(down)
    else
        local menuBar = CCMenu:create()
        menuBar:setPosition(ccp(0, 0))
        menuBar:setTouchPriority(_priority-30)
        _bgLayer:addChild(menuBar, 10)
        -- 返回按钮的回调函数
        local backBtn = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
        backBtn:setAnchorPoint(ccp(1,0.5))
        backBtn:setScale(g_fScaleX)
        backBtn:setPosition(ccp(_bgLayer:getContentSize().width-20,_bgLayer:getContentSize().height*0.9))
        backBtn:registerScriptTapHandler(closeCallBack)
        menuBar:addChild(backBtn)
    end
    --小镁铝
    local girlSprite = CCSprite:create("images/shop/shopall/liangcao.png")
    girlSprite:setAnchorPoint(ccp(0,0.5))
    girlSprite:setPosition(ccp(0,_centerSize.height*0.5))
    girlSprite:setScale(g_fElementScaleRatio)
    _centerLayer:addChild(girlSprite)

    --活动标题
    local titleSprite = CCSprite:create("images/guild/liangcang/shopname.png")
    titleSprite:setAnchorPoint(ccp(0.5,1))
    titleSprite:setScale(g_fElementScaleRatio)
    titleSprite:setPosition(ccp(_centerLayer:getContentSize().width/2,_centerLayer:getContentSize().height))
    _centerLayer:addChild(titleSprite)



end

----------------------------------------入口函数----------------------------------------


--在原来的接口进
function show(p_touchPriority, p_zOrder)
   
    local bgLayer = create(p_touchPriority, p_zOrder)
    local curScene = MainScene:getOnRunningLayer()
    curScene:addChild(bgLayer, _zOrder)
end

-- 在整合里面进
function createCenterLayer(p_centerLayerSizse, p_touchPriority, p_zOrder, p_isShow)
    
    _priority = p_touchPriority or -700
    _isShow = p_isShow or false
    _zOrder = p_zOrder or 10
    _centerSize = p_centerLayerSizse
    _centerLayer = CCLayer:create()
    _centerLayer:setContentSize(_centerSize)
    --防走光层
    createBaseUI()
    --创建UI
    BarnService.getShopInfo(createUI)
    return _centerLayer
end

function create(p_touchPriority, p_zOrder)
    init()
    _priority = p_touchPriority or -700
    _zOrder = p_zOrder or 10
    require "script/ui/shopall/ShoponeLayer"
    _bgLayer = LuaCCSprite.createMaskLayer(ccc4(0, 0, 0, 200), _priority)
    local centerLayer = createCenterLayer(ShoponeLayer.getCenterSize(), _priority, _zOrder, true)
    _bgLayer:addChild(centerLayer)
    centerLayer:ignoreAnchorPointForPosition(false)
    centerLayer:setAnchorPoint(ccp(0.5, 0.5))
    centerLayer:setPosition(ccpsprite(0.5, 0.5, _bgLayer))
    -- loadMenu() -- 返回按钮
    return _bgLayer
end



