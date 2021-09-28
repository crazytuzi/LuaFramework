-- FileName: TallyShopLayer.lua
-- Author: FQQ
-- Date: 2016-01-07
-- Purpose: 兵符商店
module("TallyShopLayer",package.seeall)
require "script/ui/shopall/tally/TallyShopCell.lua"
require "script/ui/shopall/tally/TallyShopController.lua"
require "script/ui/shopall/tally/TallyShopData.lua"


local _layer = nil                  -- 背景层
local _touchPriority = nil          -- 触摸优先级
local _tableViewSp = nil            -- 表示图背景
local _tableView = nil              -- 表视图
local _isShow = nil                 -- 不在商店整合中显示
local _centerSize = nil             -- 层的尺寸
local _centerLayer = nil            --中心层
local _timeValueLabel = nil         --刷新次数值文本
local _tallyPointNumLabel = nil     -- 兵符积分数量文本
local _refreshLabel = nil           -- 刷新时需要花费的金币的文本
local _refreshTimeBtn = nil         -- 刷新按钮
function init( ... )
    -- body
    _layer = nil
    _tableViewSp = nil
    _tableView = nil
    _layerSize = nil
    _isShow = nil
    _centerLayer = nil
    _timeValueLabel = nil
    _tallyPointNumLabel = nil
    _refreshLabel = nil
    _refreshTimeBtn = nil
end
--[[
    @des    : 在副本中显示
    @param  : 
    @return : 
--]]
function showLayer(touchPriority,zOrder)
    require "script/ui/shopall/ShoponeLayer"
    zOrder = zOrder or 999
    _touchPriority = touchPriority or -411
    local layer = createLayer()
    local centerLayer = createCenterLayer(ShoponeLayer.getCenterSize(),_touchPriority,zOrder,true)
    centerLayer:setPosition(ccpsprite(0.5, 0.5, layer))
    centerLayer:ignoreAnchorPointForPosition(false)
    centerLayer:setAnchorPoint(ccp(0.5, 0.5))
    layer:addChild(centerLayer)
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(layer,zOrder)
end
--[[
    @des    : 在商店整合中显示
    @param  : 
    @return : 
--]]
function createCenterLayer( p_LayerSize,touchPriority,zOrder,isShow )
    _touchPriority = touchPriority or -411
    _isShow = isShow or false
    _centerSize = p_LayerSize
    _centerLayer = CCLayer:create()
    _centerLayer:setContentSize(_centerSize)
    TallyShopController.getTallyInfo(function ( ... )
        createUI()
    end)
    return _centerLayer
end
--[[
    @des    : 创建UI
    @param  : 
    @return : 
--]]
function createUI( ... )
    -- 按钮
    local menu = CCMenu:create()
    menu:setAnchorPoint(ccp(0,0))
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(_touchPriority - 62)
    _centerLayer:addChild(menu)
    if not _isShow then
        -- 从商店整合进入
        local rect = CCRectMake(0,0,55,50)
        local innerRect = CCRectMake(26,30,6,4)
        local underLayer = CCScale9Sprite:create("images/tally/shop_bg.png",rect,innerRect)
        underLayer:setContentSize(_centerSize)
        underLayer:setAnchorPoint(ccp(0,0))
        underLayer:setPosition(ccp(0,0))
        _centerLayer:addChild(underLayer,-1)
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
        -- 从活动界面进入
        -- 关闭按钮
        local closeButton = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
        closeButton:setAnchorPoint(ccp(0, 1))
        closeButton:registerScriptTapHandler(closeButtonCallFunc)
        closeButton:setPosition(ccp(_centerSize.width * 0.85,_centerSize.height * 1.1))
        closeButton:setScale(g_fScaleX)
        menu:addChild(closeButton)
    end
    -- 背景人物
    local bgFigure = CCSprite:create("images/tally/bgsprite.png")
    bgFigure:setAnchorPoint(ccp(0,0.5))
    bgFigure:setPosition(ccp(0,_centerSize.height*0.5))
    _centerLayer:addChild(bgFigure)
    bgFigure:setScale(MainScene.elementScale)
    -- 标题
    local title = CCSprite:create("images/tally/title.png")
    title:setAnchorPoint(ccp(0.5,1))
    title:setPosition(ccp(_centerLayer:getContentSize().width*0.5,_centerLayer:getContentSize().height))
    _centerLayer:addChild(title)
    title:setScale(MainScene.elementScale)
    -- “兵符积分”
    local tallyPointLabel = CCRenderLabel:create(GetLocalizeStringBy("fqq_051"),g_sFontPangWa,23,1,ccc3(0, 0x00, 0x00))
    tallyPointLabel:setColor(ccc3( 0xff, 0xf6, 0x00))
    tallyPointLabel:setAnchorPoint(ccp(0,1))
    tallyPointLabel:setPosition(ccp(g_winSize.width*0.48,title:getPositionY() - title:getContentSize().height*g_fScaleX))
    _centerLayer:addChild(tallyPointLabel)
    tallyPointLabel:setScale(g_fScaleX)
    --兵符图标
    local tallyIcon = CCSprite:create("images/tally/bingfu.png")
    tallyPointLabel:addChild(tallyIcon)
    tallyIcon:setPosition(ccp(tallyPointLabel:getContentSize().width,0))
    -- 兵符积分数量
    local tallyPointNum = UserModel.getTallyPointNumber()
    _tallyPointNumLabel = CCRenderLabel:create(tallyPointNum,g_sFontPangWa,23,1,ccc3(0, 0x00, 0x00))
    _tallyPointNumLabel:setColor(ccc3( 0x00, 0xff, 0x18))
    _tallyPointNumLabel:setAnchorPoint(ccp(0,0))
    _tallyPointNumLabel:setPosition(ccp(tallyPointLabel:getContentSize().width+tallyIcon:getContentSize().width,0))
    tallyPointLabel:addChild(_tallyPointNumLabel)
    -- 表视图背景
    local rect = CCRectMake(0,0,67,67)
    local insert = CCRectMake(27,29,12,10)
    local height = tallyPointLabel:getPositionY() - tallyPointLabel:getContentSize().height*g_fElementScaleRatio - 75*g_fScaleX
    _tableViewSp = CCScale9Sprite:create("images/warcraft/warcraft_formation_bg.png",rect,insert)
    _tableViewSp:setContentSize(CCSizeMake(462*g_fScaleX,height))
    _tableViewSp:setAnchorPoint(ccp(1,1))
    _tableViewSp:setPosition(ccp(g_winSize.width-10*g_fScaleX,tallyPointLabel:getPositionY() - tallyPointLabel:getContentSize().height*g_fScaleX))
    _centerLayer:addChild(_tableViewSp)
    --创建tableview
    createTableView()
    --免费刷新label
    local refreshTimeLabel = CCLabelTTF:create(GetLocalizeStringBy("fqq_000"),g_sFontName,21)
    refreshTimeLabel:setPosition(ccp(_centerSize.width*0.03,_centerSize.height*0.04))
    _centerLayer:addChild(refreshTimeLabel)
    refreshTimeLabel:setScale(g_fScaleX)
    local freeTimeValue = TallyShopData.getFreeTimes()
    _timeValueLabel = CCLabelTTF:create(freeTimeValue,g_sFontName,21)
    _timeValueLabel:setColor(ccc3(0x00, 0xff, 0x18))
    _timeValueLabel:setPosition(ccpsprite(1,0,refreshTimeLabel))
    refreshTimeLabel:addChild(_timeValueLabel)
    --刷新按钮
    local normalSp = CCScale9Sprite:create("images/common/btn/btn_purple2_n.png")
    normalSp:setContentSize(CCSizeMake(220,79))
    local selectSp = CCScale9Sprite:create("images/common/btn/btn1_n.png")
    selectSp:setContentSize(CCSizeMake(220,79))
    _refreshTimeBtn = CCMenuItemSprite:create(normalSp,selectSp)
    _refreshTimeBtn:setAnchorPoint(ccp(0.5,0.5))
    _refreshTimeBtn:setPosition(ccp(_centerSize.width * 0.8,_centerSize.height*0.06))
    menu:addChild(_refreshTimeBtn)
    _refreshTimeBtn:setScale(g_fScaleX)
    _refreshTimeBtn:registerScriptTapHandler(refreshTimeHandler)
    createRefreshLabel()
end

function createLayer( ... )
    init()
    _layer = CCLayerColor:create(ccc4(11,11,11,166))
    _layer:registerScriptTouchHandler(onNodeEvent)
    return _layer
end
function onNodeEvent( event )
    if event == "enter" then
        _layer:registerScriptTouchHandler(onTouchesHandler,false,_touchPriority,true)
        _layer:setTouchEnabled(true)

    elseif eventType == "exit" then
        _layer:unregisterScriptTouchHandler()
        _layer = nil
    end
end
function onTouchesHandler( eventType )
     if (eventType == "began") then
        return true
    elseif (eventType == "moved") then
        print("moved")
    else
        print("end")
    end
end
--[[
    @des    : 创建表示图
    @param  : 
    @return : 
--]]
function createTableView()
    local goodInfoAry = TallyShopData.getGoodsList()
    local luaHandler = LuaEventHandler:create(function(fn,t,a1,a2)
        local ret
        if fn == "cellSize" then
            ret = CCSizeMake(442*g_fScaleX, 164*g_fScaleX)
        elseif fn == "cellAtIndex" then
            ret = TallyShopCell.createCell(goodInfoAry[a1 + 1])
        elseif fn == "numberOfCells" then
            ret = table.count(goodInfoAry)
        elseif fn == "cellTouched" then
        end
        return ret
    end
    )
    _tableView = LuaTableView:createWithHandler(luaHandler,CCSizeMake(442*g_fScaleX,_tableViewSp:getContentSize().height - 10))
    _tableView:setTouchPriority(_touchPriority - 2)
    _tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    _tableView:setAnchorPoint(ccp(0.5,0.5))
    _tableView:setPosition(ccpsprite(0.5,0.5,_tableViewSp))
    _tableView:ignoreAnchorPointForPosition(false)
    _tableViewSp:addChild(_tableView)
end
--[[
    @des    : 刷新次数按钮回调
    @param  : 
    @return : 
--]]
function refreshTimeHandler( ... )
    local freeTimeValue = TallyShopData.getFreeTimes()
    --如果免费刷新次数为0
    if freeTimeValue == 0 then
        --金币刷新次数用完的情况下
        local curTime = TallyShopData.getGoldTime()
        local maxTime = TallyShopData.getMaxFefreshNumber()
        if(curTime >= maxTime)then
            require "script/ui/tip/AnimationTip"
            AnimationTip.showTip(GetLocalizeStringBy("fqq_054"))
            return
        end
        -- 提示
        local cost = TallyShopData.getGoldCost()
        local richInfo = {
            elements = {
                {
                    ["type"] = "CCSprite",
                    image = "images/common/gold.png"
                },
                {
                    text = cost
                },
                {
                    text = 1
                }
            }
        }
        local newRichInfo = GetNewRichInfo(GetLocalizeStringBy("syx_1071"), richInfo)  --“是否消耗%s%s，刷新符印商店”
        local alertCallback = function ( isConfirm, _argsCB )
            if not isConfirm then
                return
            end
            TallyShopController.refreshTallyGoodsList(function ( ... )
                update()
            end)
        end
        require "script/ui/tip/RichAlertTip"
        RichAlertTip.showAlert(newRichInfo, alertCallback, true, nil, GetLocalizeStringBy("key_8129"), nil, nil, nil, nil, nil, nil, true)  --字是“确定”
    else
        TallyShopController.refreshTallyGoodsList(function ( ... )
            update()
        end)
    end
end
--[[
    @des    : 刷新
    @param  : 
    @return : 
--]]
function update( ... )
    if _tableView then
        _tableView:removeFromParentAndCleanup(true)
        _tableView = nil
    end
    createTableView()
    local timeValue = TallyShopData.getFreeTimes()
    _timeValueLabel:setString(timeValue)
    createRefreshLabel()
end
--[[
    @des    : 更新刷新时需要花费的金币
    @param  : 
    @return : 
--]]
function createRefreshLabel( ... )
    if not tolua.isnull(_refreshLabel) then
        _refreshLabel:removeFromParentAndCleanup(true)
        _refreshLabel = nil
    end
    -- “刷新”富文本
    local richInfo = {
        linespace = 2, -- 行间距
        alignment = 1, -- 对齐方式  1 左对齐，2 居中， 3右对齐
        lineAlignment = 2, -- 当前行在竖直方向上的对齐方式 1，下对齐， 2，居中， 3，上对齐
        labelDefaultFont = g_sFontPangWa,
        labelDefaultColor = ccc3(0xfe, 0xdb, 0x1c),
        labelDefaultSize = 30,
        defaultType = "CCRenderLabel",
        elements =
        {
            {
                type = "CCRenderLabel",
                newLine = false,
                text = GetLocalizeStringBy("key_1002"),
                renderType = 2,-- 1 描边， 2 投影
            },
        }
    }
    local freeTimeValue = TallyShopData.getFreeTimes()
    if freeTimeValue == 0 then
        -- 获取刷新需要花费的金币
        local goldCost = TallyShopData.getGoldCost()
        local elements =
            {
                {
                    ["type"] = "CCSprite",
                    image = "images/common/gold.png"
                },
                {
                    type = "CCRenderLabel",
                    newLine = false,
                    text = goldCost,
                    renderType = 2,-- 1 描边， 2 投影
                },
            }
        richInfo.elements = table.connect({richInfo.elements,elements})
    end
    require "script/libs/LuaCCLabel"
    _refreshLabel = LuaCCLabel.createRichLabel(richInfo)
    _refreshLabel:setAnchorPoint(ccp(0.5, 0.5))
    _refreshLabel:setPosition(ccp(_refreshTimeBtn:getContentSize().width*0.5,_refreshTimeBtn:getContentSize().height * 0.5))
    _refreshTimeBtn:addChild(_refreshLabel)
end
--[[
    @des    : 购买后刷新界面
    @param  : 
    @return : 
--]]
function updateAfterBuy( ... )
    local offset = _tableView:getContentOffset()
    _tableView:reloadData()
    _tableView:setContentOffset(offset)
    -- 更新兵符积分
    local tallyPointNum = UserModel.getTallyPointNumber()
    _tallyPointNumLabel:setString(tallyPointNum)
end
--[[
    @des    : 关闭
    @param  : 
    @return : 
--]]
function closeButtonCallFunc( ... )
    -- 播放关闭音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    if _layer then
        _layer:removeFromParentAndCleanup(true)
        _layer = nil
    end
end
--0点刷新
function refresh( ... )
    if(_layer == nil)then
        return
    end
    --刷新数据
    local callbcak = function ( ... )
        --刷新商店物品
        if _tableView then
            _tableView:removeFromParentAndCleanup(true)
            _tableView = nil
        end
        createTableView()
        --移除提示框
        TallyShopCell.removeBuyAlertTip()
        local timeValue = TallyShopData.getFreeTimes()
        _timeValueLabel:setString(timeValue)
        createRefreshLabel()
    end
    TallyShopController.getTallyInfo(callbcak)
end




