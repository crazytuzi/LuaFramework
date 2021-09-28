-- Filename：    CostPreviewLayer.lua
-- Author：      DJN
-- Date：        2015-7-26
-- Purpose：     武将进化消耗预览 展示所有武将的

module ("CostPreviewLayer", package.seeall)

require "script/ui/main/MainScene"
require "script/utils/BaseUI"
require "script/ui/develop/DevelopData"
require "script/ui/develop/costPreview/DevelopCostLayer"

local _touchPriority    
local _zOrder
local _bgLayer              --背景层
local _bgMenu               --背景按钮层
local _lastCountryBtn = nil -- 当前选择的国家按钮
local _secondSprite         --二级背景
local _beginX = 100         --按钮开始位置
local _gapX = 140           --按钮间隔长度
local _scrollView = nil 
local _stars = {6, 7}        --页面中都需要展示哪些星级的武将
----------------------------------------初始化函数----------------------------------------
local function init()
    _touchPriority = nil
    _zOrder = nil
    _bgLayer = nil
    _bgMenu = nil
    _scrollView = nil
    _secondSprite = nil
    _lastCountryBtn = nil
end

----------------------------------------触摸事件函数----------------------------------------
local function onTouchesHandler(eventType,x,y)
    if (eventType == "began") then
        -- local beganPoint = _secondSprite:convertToNodeSpace(ccp(x,y))
        -- print("beganPoint",beganPoint.x,"--",beganPoint.y)
        -- print("_secondSprite:getContentSize().width",_secondSprite:getContentSize().width,"_secondSprite:getContentSize().height",_secondSprite:getContentSize().height)
        -- if(beganPoint.x >0 and beganPoint.x < _secondSprite:getContentSize().width and beganPoint.y >0 and beganPoint.y < _secondSprite:getContentSize().height)then
        --     return false
        -- else
        --     return true

        -- end

        local point = _scrollView:convertToNodeSpace(ccp(x, y))
        local bounding_box = _scrollView:boundingBox()
        if bounding_box:containsPoint(point) then
           return false
        end
        return true

    elseif (eventType == "moved") then
       -- print("moved")
    else
       -- print("end")
    end
end

local function onNodeEvent(event)
    if event == "enter" then
        _bgLayer:registerScriptTouchHandler(onTouchesHandler, false, _touchPriority-2 , true)
        _bgLayer:setTouchEnabled(true)
    elseif eventType == "exit" then
        _bgLayer:unregisterScriptTouchHandler()
    end
end

----------------------------------------回调函数----------------------------------------
--[[
    @des    :更换国家回调
    @param  :按钮tag值
    @return :
--]]
function changeCountryCB(p_tag,p_item)
    _pointSprite:setPositionX(p_item:getPositionX())
    p_item:setEnabled(false)
    if _lastCountryBtn ~= nil then
        _lastCountryBtn:setEnabled(true)
    end
    _lastCountryBtn = p_item
    refreshScrollView(p_tag)
end

--[[
    @des    :关闭按钮回调
    @param  :
    @return :
--]]
function closeCallBack()
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    _bgLayer:removeFromParentAndCleanup(true)
    _bgLayer = nil
end

----------------------------------------UI函数----------------------------------------
--[[
    @des    :创建UI
    @param  :
    @return :
--]]
function createUI()
    --主背景图片
    local bgSprite = CCScale9Sprite:create("images/common/viewbg1.png")
    bgSprite:setContentSize(CCSizeMake(620,700))
    bgSprite:setAnchorPoint(ccp(0.5,0.5))
    bgSprite:setPosition(ccp(g_winSize.width/2,g_winSize.height/2))
    bgSprite:setScale(MainScene.elementScale)
    _bgLayer:addChild(bgSprite)

    --标题背景
    local titleSprite = CCSprite:create("images/common/viewtitle1.png")
    titleSprite:setAnchorPoint(ccp(0.5,0.5))
    titleSprite:setPosition(ccp(bgSprite:getContentSize().width/2,bgSprite:getContentSize().height - 6))
    bgSprite:addChild(titleSprite)

    --标题
    local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("djn_218"), g_sFontPangWa, 33)
    titleLabel:setColor(ccc3(0xff,0xe4,0x00))
    titleLabel:setAnchorPoint(ccp(0.5,0.5))
    titleLabel:setPosition(ccp(titleSprite:getContentSize().width/2,titleSprite:getContentSize().height/2))
    titleSprite:addChild(titleLabel)

    --箭头的高度变量
    local arrowPosY = bgSprite:getContentSize().height - 115

    --指示箭头
    _pointSprite = CCSprite:create("images/illustrate/bottom_trangle.png")
    _pointSprite:setAnchorPoint(ccp(0.5,1))
    _pointSprite:setPosition(ccp(0,arrowPosY))
    bgSprite:addChild(_pointSprite)
    
    --背景层
    _bgMenu = CCMenu:create()
    _bgMenu:setAnchorPoint(ccp(0,0))
    _bgMenu:setPosition(ccp(0,0))
    _bgMenu:setTouchPriority(_touchPriority - 30)
    bgSprite:addChild(_bgMenu)

    --关闭按钮
    local closeMenuItem = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    closeMenuItem:setPosition(ccp(bgSprite:getContentSize().width*1.03,bgSprite:getContentSize().height*1.03))
    closeMenuItem:setAnchorPoint(ccp(1,1))
    closeMenuItem:registerScriptTapHandler(closeCallBack)
    _bgMenu:addChild(closeMenuItem)

    --4个国家按钮
    local nameTable = {
                            [1] = "wei",
                            [2] = "shu",
                            [3] = "wu",
                            [4] = "qun",
                      }
    for i = 1,4 do
        local nameString = "images/illustrate/hero/" .. nameTable[i] .. "/" .. nameTable[i]
        local countryMenuItem = CCMenuItemImage:create(nameString .. "_n.png", nameString .. "_h.png", nameString .. "_h.png")
        countryMenuItem:setAnchorPoint(ccp(0.5,1))
        countryMenuItem:setPosition(ccp(_beginX + _gapX*(i - 1),bgSprite:getContentSize().height - 50))
        countryMenuItem:registerScriptTapHandler(changeCountryCB)
        if i == 1 then
            changeCountryCB(1, countryMenuItem)
        end
        _bgMenu:addChild(countryMenuItem,1, i)
    end

    --二级背景
    _secondSprite = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
    _secondSprite:setContentSize(CCSizeMake(580,475))
    _secondSprite:setAnchorPoint(ccp(0.5,1))
    _secondSprite:setPosition(ccp(bgSprite:getContentSize().width/2,arrowPosY - _pointSprite:getContentSize().height))
    bgSprite:addChild(_secondSprite)

    --提示文字
    local desLabel_1 = CCLabelTTF:create(GetLocalizeStringBy("djn_219"),g_sFontPangWa,21)
    desLabel_1:setColor(ccc3(0x78,0x25,0x00))
    --伟大的拼接过程
    local tipNode = BaseUI.createHorizontalNode({desLabel_1,desLabel_2})
    tipNode:setAnchorPoint(ccp(0.5,0.5))
    tipNode:setPosition(ccp(bgSprite:getContentSize().width/2,60))
    bgSprite:addChild(tipNode)

    -- require "script/ui/develop/costPreview/CostTableView"
    -- --创建魏国tableView
    -- local weiTableView = CostTableView.createTableView(DevelopData.getCostHeroByCountry(1))
    -- weiTableView:setAnchorPoint(ccp(0,0))
    -- weiTableView:setPosition(ccp(0,0))
    -- weiTableView:setTouchPriority(_touchPriority - 20)
    -- _secondSprite:addChild(weiTableView,1,kButtomTag + 1)
    loadScrollView()
end

----------------------------------------入口函数----------------------------------------
function showLayer(p_touchPriority,p_zOrder)
    init()

    _touchPriority = p_touchPriority or -550
    _zOrder = p_zOrder or 999

    _bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
    _bgLayer:registerScriptHandler(onNodeEvent)
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,_zOrder)

    --创建UI层
    createUI()
end


function loadScrollView()
    _scrollView = CCScrollView:create()
    _secondSprite:addChild(_scrollView)
    _scrollView:setAnchorPoint(ccp(0.5, 0.5))
    _scrollView:setPosition(ccpsprite(0.5, 0.5, _secondSprite))
    _scrollView:setViewSize(CCSizeMake(_secondSprite:getContentSize().width - 10, _secondSprite:getContentSize().height - 10))
    _scrollView:setTouchPriority(_touchPriority - 20)
    _scrollView:setDirection(kCCScrollViewDirectionVertical)
    _scrollView:ignoreAnchorPointForPosition(false)
    refreshScrollView(1)
end

function refreshScrollView(countryIndex)
    if _scrollView == nil then
        return
    end
    local container = _scrollView:getContainer()
    container:removeAllChildrenWithCleanup(true)

    local height = 0
    local normalConfigDb = DB_Normal_config.getDataById(1)
    for i = 1, #_stars do
        local star = _stars[i]
        local htidsStr = normalConfigDb[string.format("star%dheroesPreviewCard%d", star, countryIndex)]
        if htidsStr ~= nil then
            local htids = parseField(htidsStr, 1)
            local htidCount = #htids
            local lineCount = math.ceil(htidCount / 4)
            local full_rect = CCRectMake(0,0,116, 124)
            local inset_rect = CCRectMake(50,60,10,10)
            local bg1 = CCScale9Sprite:create("images/common/bg/change_bg.png", full_rect, inset_rect)
            container:addChild(bg1)
            bg1:setContentSize(CCSizeMake(_scrollView:getViewSize().width, 80 + 130 * lineCount))
            bg1:setAnchorPoint(ccp(0.5, 0))
            bg1:setPosition(ccp(_scrollView:getViewSize().width * 0.5, height))
            
            local starBg = CCScale9Sprite:create("images/digCowry/star_bg.png")
            bg1:addChild(starBg)
            starBg:setAnchorPoint(ccp(0, 1))
            starBg:setPosition(ccp(0, bg1:getContentSize().height))
            starBg:setContentSize(CCSizeMake(270, starBg:getContentSize().height))
            
            for j = 1, star do
                local starSprite = CCSprite:create("images/hero/star.png")
                starBg:addChild(starSprite)
                starSprite:setAnchorPoint(ccp(0.5, 0.5))
                starSprite:setScale(0.8)
                starSprite:setPosition(ccp(10 + j * 30, starBg:getContentSize().height * 0.5 + 2))
            end

            local bg2 = CCScale9Sprite:create("images/common/bg/goods_bg.png")
            bg1:addChild(bg2)
            bg2:setAnchorPoint(ccp(0.5, 0))
            bg2:setPosition(ccp(bg1:getContentSize().width * 0.5, 25))
            bg2:setContentSize(CCSizeMake(bg1:getContentSize().width - 40, bg1:getContentSize().height - 70))
            
            local iconMenu = CCMenu:create()
            iconMenu:setContentSize(bg2:getContentSize())
            iconMenu:setAnchorPoint(ccp(0,0))
            iconMenu:setPosition(ccp(0,0))
            iconMenu:setTouchPriority(_touchPriority - 1)
            bg2:addChild(iconMenu)

            for j = 1, htidCount do
                local heroDb = DB_Heroes.getDataById(htids[j])
                --武将头像
        
                local headSprite = HeroUtil.getHeroIconByHTID(htids[j])
                local headItem = CCMenuItemSprite:create(headSprite,headSprite)
                headItem:setAnchorPoint(ccp(0, 1))
                headItem:setPosition(ccp(14 + math.mod(j - 1, 4) * 130, bg2:getContentSize().height - math.floor((j - 1) / 4) * 130 - 9))
                headItem:registerScriptTapHandler(heroCb)
                iconMenu:addChild(headItem,1,htids[j])
                              
                -- heroHead:setPosition(ccp(14 + math.mod(j - 1, 4) * 130, bg2:getContentSize().height - math.floor((j - 1) / 4) * 130 - 9))
                local nameColor = HeroPublicLua.getCCColorByStarLevel(heroDb.star_lv)
                local nameLabel = CCRenderLabel:create(heroDb.name, g_sFontName, 23, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
                nameLabel:setColor(nameColor)
                nameLabel:setAnchorPoint(ccp(0.5, 1))
                nameLabel:setPosition(ccp(headItem:getContentSize().width * 0.5, -2))
                headItem:addChild(nameLabel)
            end
            height = height + bg1:getContentSize().height + 15
        end
    end
    _scrollView:setContentSize(CCSizeMake(_scrollView:getViewSize().width, height))
    container:setPositionY(_scrollView:getViewSize().height - height)
end
-- 点击武将头像的回调
function heroCb( p_tag,p_item)
    DevelopCostLayer.showLayer(p_tag,CostPreviewLayer.getTouchPriority() - 30)
    -- body
end
function getTouchPriority( ... )
    return _touchPriority
end