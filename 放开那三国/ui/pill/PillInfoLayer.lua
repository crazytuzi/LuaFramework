-- Filename：    PillInfoLayer.lua
-- Author：      DJN
-- Date：        2015-5-27
-- Purpose：     丹药信息面板
module("PillInfoLayer", package.seeall)
require "script/audio/AudioUtil"
require "db/DB_Item_normal"
require "script/ui/item/ItemSprite"
--require "script/ui/pill/PillControler"

local _bgLayer       --灰色背景屏蔽层
local _touchPriority --触摸优先级
local _ZOrder        --Z轴值
local _pType         --选中的类型
local _pPage         --选中的页码
local _pPos          --选中的位置
local TYPE_DEFENSE = 1 
local TYPE_LIFE    = 2
local TYPE_ATTACK  = 3
-- local _ifRemoveBtn   --是否有卸下按钮
----------------------------------------初始化函数
local function init()
    _bgLayer       = nil
    _touchPriority = nil
    _ZOrder        = nil 
    _pType         = nil
    _pPage         = nil
    _pPos          = nil   
    --_ifRemoveBtn = nil
end

----------------------------------------触摸事件函数
function onTouchesHandler(eventType,x,y)
    if eventType == "began" then
       -- print("onTouchesHandler,began")
        return true
    elseif eventType == "moved" then
        --print("onTouchesHandler,moved")
    else
        --print("onTouchesHandler,else")
    end
end

local function onNodeEvent(event)
    if event == "enter" then
        _bgLayer:registerScriptTouchHandler(onTouchesHandler,false,_touchPriority,true)
        _bgLayer:setTouchEnabled(true)
    elseif event == "exit" then
        _bgLayer:unregisterScriptTouchHandler()
    end
end

----------------------------------------回调函数
--[[
    @des    :关闭按钮回调
    @param  :
    @return :
--]]
local function closeMenuCallBack()
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    closeeCb()
end
function closeeCb( ... )
    _bgLayer:removeFromParentAndCleanup(true)
    _bgLayer = nil
end
--卸下一个丹药的回调
function removeCallBack( p_tag)
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    local curHid = PillLayer.getHeroInfo()
    -- print("removeCallBack getHeroInfo")
    -- print_t(curHid)
    curHid = curHid.hid
    --print("curHid.hid",curHid)
    PillControler.removePill(curHid,_pType,_pPage,p_tag)
    closeeCb()
end
----------------------------------------UI函数
--[[
    @des    :创建背景
    @param  :
    @return :
--]]
local function createBgUI()
    require "script/ui/main/MainScene"
    local bgSize = CCSizeMake(610,420)
    local bgScale = MainScene.elementScale
    
    --主黄色背景
    local bgSprite = CCScale9Sprite:create("images/common/viewbg1.png")
    bgSprite:setContentSize(bgSize)
    bgSprite:setAnchorPoint(ccp(0.5,0.5))
    bgSprite:setPosition(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5)
    bgSprite:setScale(bgScale)
    _bgLayer:addChild(bgSprite)
    
    -- TITLE
    local titleBg = CCSprite:create("images/battle/report/title_bg.png")
    titleBg:setAnchorPoint(ccp(0.5,0.5))
    titleBg:setPosition(ccpsprite(0.5,0.993,bgSprite))
    bgSprite:addChild(titleBg)
    
    local displayName = LuaCCLabel.createShadowLabel(GetLocalizeStringBy("djn_183"),g_sFontPangWa,33)
    displayName:setColor(ccc3( 0xff, 0xe4, 0x00));
    displayName:setAnchorPoint(ccp(0.5,0.5))
    displayName:setPosition((titleBg:getContentSize().width)/2,titleBg:getContentSize().height*0.5)
    titleBg:addChild(displayName)


    local bgMenu = CCMenu:create()
    bgMenu:setPosition(ccp(0,0))
    bgMenu:setTouchPriority(_touchPriority-1)
    bgSprite:addChild(bgMenu)
   
    --关闭按钮
    local colseMenuItem = LuaMenuItem.createItemImage("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    colseMenuItem:setAnchorPoint(ccp(0.5,0.5))
    colseMenuItem:setPosition(ccp(bgSprite:getContentSize().width*0.95,bgSprite:getContentSize().height*0.95))
    colseMenuItem:registerScriptTapHandler(closeMenuCallBack)
    bgMenu:addChild(colseMenuItem)

 
    --二级棕色背景
    require "script/utils/BaseUI"
    secondBgSprite = BaseUI.createContentBg(CCSizeMake(550,250))
    secondBgSprite:setAnchorPoint(ccp(0.5,0.5))
    secondBgSprite:setPosition(ccp(bgSprite:getContentSize().width*0.5,bgSprite:getContentSize().height*0.58))
    bgSprite:addChild(secondBgSprite)

    --左青龙
    local leftFlowerSprite = CCSprite:create("images/god_weapon/flower.png")
    leftFlowerSprite:setAnchorPoint(ccp(0,0.5))
    leftFlowerSprite:setPosition(ccp(0,220))
    leftFlowerSprite:setScaleX(0.8)
    --leftFlowerSprite:setScale(g_fScaleX)
    secondBgSprite:addChild(leftFlowerSprite)

    --右白虎
    local rightFlowerSprite = CCSprite:create("images/god_weapon/flower.png")
    rightFlowerSprite:setScaleX(-0.8)
    --rightFlowerSprite:setScaleY(g_fScaleX)
    rightFlowerSprite:setAnchorPoint(ccp(0,0.5))
    rightFlowerSprite:setPosition(ccp(550,220))
    secondBgSprite:addChild(rightFlowerSprite)
    local pillDbInfo = PillData.getInfoByTypeAndPage(_pPage,_pType)
    local pillId = pillDbInfo.Pill_id
    local pillName = DB_Item_normal.getDataById(pillId).name or ""
    local nameLabel = CCRenderLabel:create(pillName,g_sFontPangWa,24,1, ccc3(0xff,0xff,0xff), type_stroke)
    nameLabel:setColor(ccc3(0x78,0x25,0x00))
    nameLabel:setAnchorPoint(ccp(0.5,0.5))
    nameLabel:setPosition(ccp(275,220))
    secondBgSprite:addChild(nameLabel)
    local affixName = {{GetLocalizeStringBy("lcy_10014"),GetLocalizeStringBy("lcy_10015")},{GetLocalizeStringBy("llp_114")},{GetLocalizeStringBy("llp_113")}}
   -- print("affixName[_pTypes]",affixName[_pType])
    local addAffix = PillData.getAffixByPos(_pType,_pPage,_pPos)
    -- local sumAffix = 0
    -- if(table.isEmpty(addAffix) == false)then
    --     for k,v in pairs(addAffix)do
    --         sumAffix = sumAffix + v[2]
    --     end
    -- end
    if(table.isEmpty(addAffix))then
        addAffix[1][2] = 0
        addAffix[2][2] = 0
    end

    --描述说明
    local richInfo = {elements = {},alignment = 2,lineAlignment = 2,defaultType = "CCRenderLabel",width = 320}
        richInfo.elements[1] = {
                text = GetLocalizeStringBy("key_2371"),
                font = g_sFontPangWa,
                size = 18,
                color = ccc3(0xff,0xf6,0x00)}
        richInfo.elements[2] = {
                ["type"] = "CCSprite",
                newLine = true,
                image = "images/common/line01.png"}
        richInfo.elements[3] = { 
                text = DB_Item_normal.getDataById(pillId).desc or "",
                newLine = true,
                font = g_sFontName,
                size = 18,
                color = ccc3(0xff,0xff,0xff)}
        richInfo.elements[4] = {
                text = GetLocalizeStringBy("lic_1552"),
                newLine = true,
                font = g_sFontPangWa,
                size = 18,
                color = ccc3(0xff,0xf6,0x00)}
        richInfo.elements[5] = {
                ["type"] = "CCSprite",
                newLine = true,
                image = "images/common/line01.png"}
        richInfo.elements[6] = { 
                text = affixName[_pType][1],
                newLine = true,
                font = g_sFontName,
                size = 18,
                color = ccc3(0xff,0xff,0xff)}
        richInfo.elements[7] = { 
                text = "+"..addAffix[1][2],
                font = g_sFontName,
                size = 18,
                color = ccc3(0x00,0xff,0x18)}
        if(_pType == TYPE_DEFENSE)then
            richInfo.elements[8] = { 
                text = "  "..affixName[_pType][2],
                font = g_sFontName,
                size = 18,
                color = ccc3(0xff,0xff,0xff)}
            richInfo.elements[9] = { 
                text = "+"..addAffix[2][2],
                font = g_sFontName,
                size = 18,
                color = ccc3(0x00,0xff,0x18)}
        end


    local midSp = LuaCCLabel.createRichLabel(richInfo)
    midSp:setAnchorPoint(ccp(0,0.5))
    midSp:setPosition(ccpsprite(0.3,0.4,secondBgSprite))
    secondBgSprite:addChild(midSp)

    --pill icon
    local pillIcon = ItemSprite.getItemSpriteById(pillId)
    pillIcon:setAnchorPoint(ccp(0,0))
    pillIcon:setPosition(ccpsprite(0.1,0.3,secondBgSprite))
    secondBgSprite:addChild(pillIcon)

    local starNum = _pPage +1
    local starRichInfo = {elements = {}}
    for i = 1,starNum do
        starRichInfo.elements[i] = {
            ["type"] = "CCSprite",
            image = "images/formation/star.png"
         } 
    end
    local starNode = LuaCCLabel.createRichLabel(starRichInfo)
    starNode:setAnchorPoint(ccp(0.5,1))
    starNode:setPosition(ccpsprite(0.5,-0.05,pillIcon))
    pillIcon:addChild(starNode)

    local haveNum = PillData.getHaveNumByTypeAndPage(_pType,_pPage) or 0
    local totalNum = pillDbInfo.Pill_number or 0
    local haveColor = haveNum >= totalNum and ccc3(0x00,0xff,0x18) or ccc3(0xff,0x00,0x00)
    local progressRichInfo = {elements = {},alignment = 2}
        progressRichInfo.elements[1] = {
            ["type"] = "CCLabelTTF",
            text = GetLocalizeStringBy("djn_184"),
            font = g_sFontName,
            size = 18,
            color = ccc3(0x78,0x25,0x00)
        }
        progressRichInfo.elements[2] = {
            ["type"] = "CCRenderLabel",
            text = haveNum,
            font = g_sFontName,
            size = 18,
            color = haveColor
        }
        progressRichInfo.elements[3] = {
            ["type"] = "CCRenderLabel",
            text = "/" .. totalNum,
            font = g_sFontName,
            size = 18,
            color = ccc3(0x00,0xff,0x18)
        }
    local progressNode = LuaCCLabel.createRichLabel(progressRichInfo)
    progressNode:setAnchorPoint(ccp(0.5,0.5))
    -- if(_ifRemoveBtn)then
    --     progressNode:setPosition(ccpsprite(0.25,0.12,bgSprite))
    --     local removeBtn =  LuaCC.create9ScaleMenuItem("images/common/btn/btn_purple2_n.png","images/common/btn/btn_purple2_h.png",CCSizeMake(200, 73),GetLocalizeStringBy("djn_227"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    --     removeBtn:setAnchorPoint(ccp(0.5,0.5))
    --     removeBtn:setPosition(ccpsprite(0.7,0.05,bgMenu))
    --     removeBtn:registerScriptTapHandler(removeCallBack)
    --     bgMenu:addChild(removeBtn,99,pillDbInfo.id)
    -- else
        progressNode:setPosition(ccpsprite(0.5,0.12,bgSprite))
    --end
    bgSprite:addChild(progressNode)
end
-- --获取当前展示的丹药的type和page 以便卸下后改缓存
-- function getTypeAndPage( ... )
--     return _pType,_pPage
-- end
----------------------------------------入口函数
----------前三个参数不可省
function showLayer(p_type,p_page,p_pos,p_touchPriority,p_ZOrder,p_removeBtn)
    
        init()
        _touchPriority = p_touchPriority or -550
        _ZOrder = p_ZOrder or 999
        _pType = p_type or 1  --前三个参数不可省！为了防止崩才加了默认值
        _pPage = p_page or 1
        _pPos = p_pos or 1
        --_ifRemoveBtn = p_removeBtn or false

        _bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
        _bgLayer:registerScriptHandler(onNodeEvent)
        local curScene = CCDirector:sharedDirector():getRunningScene()
        curScene:addChild(_bgLayer,_ZOrder)
    
        --创建背景UI 
        createBgUI()
        
    return _bgLayer


end