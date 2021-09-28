-- Filename：    EatPillLayer.lua
-- Author：      DJN
-- Date：        2015-5-27
-- Purpose：     吃丹药界面
module("EatPillLayer", package.seeall)
require "script/audio/AudioUtil"
require "db/DB_Item_normal"
require "script/ui/hero/HeroPublicLua"

local _bgLayer       --灰色背景屏蔽层
local _touchPriority --触摸优先级
local _ZOrder        --Z轴值
local _pType         = nil --丹药类型
local _pPage         = nil --页码
local _pPos          = nil --位置
local _hid           = nil --武将hid
local _pItemId       --丹药的itemid
local _pId           --该丹药在pill表中的id
local _pHaveNum      = nil
local _lastFightForce = nil
local TYPE_DEFENSE = 1 
local TYPE_LIFE    = 2
local TYPE_ATTACK  = 3
----------------------------------------初始化函数
local function init()
    _bgLayer       = nil
    _touchPriority = nil
    _ZOrder        = nil 
    _pType         = nil
    _pPage         = nil
    _pPos          = nil 
    _hid           = nil  
    _pItemId       = nil
    _pId           = nil
    _lastFightForce = nil
    _pHaveNum      = nil
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
    closeCb()
end
function confirmCallBack( ... )
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    local confirmCb = function ( ... )
        closeCb()
        PillData.addPillByPos(_pType,_pId,1)
        PillData.setPropsTab((PillData.getInfoByTypeAndPage(_pPage,_pType)).Pill_id,-1)
        PillData.getAffixByHid(_hid,true)
        PillLayer.refreshUI()
        --飘窗
        --flyCb()
        

        local curFight = FightForceModel.dealParticularValues(_hid)
        ItemUtil.showAttrChangeInfo(_lastFightForce,curFight)
        
    end
    PillControler.equipPill(_hid,_pId,_pItemId,confirmCb)

end
function closeCb( ... )
    _bgLayer:removeFromParentAndCleanup(true)
    _bgLayer = nil
end
----------------------------------------UI函数
--[[
    @des    :创建排行榜背景
    @param  :
    @return :
--]]
local function createBgUI()
    require "script/ui/main/MainScene"
    local bgSize = CCSizeMake(580,320)
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
    
    local displayName = LuaCCLabel.createShadowLabel(GetLocalizeStringBy("djn_185"),g_sFontPangWa,33)
    displayName:setColor(ccc3( 0xff, 0xe4, 0x00));
    displayName:setAnchorPoint(ccp(0.5,0.5))
    displayName:setPosition((titleBg:getContentSize().width)/2,titleBg:getContentSize().height*0.5)
    titleBg:addChild(displayName)


    local bgMenu = CCMenu:create()
    bgMenu:setPosition(ccp(0,0))
    bgMenu:setTouchPriority(_touchPriority-1)
    bgSprite:addChild(bgMenu)
   
    -- --关闭按钮
    -- local colseMenuItem = LuaMenuItem.createItemImage("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    -- colseMenuItem:setAnchorPoint(ccp(0.5,0.5))
    -- colseMenuItem:setPosition(ccp(bgSprite:getContentSize().width*0.95,bgSprite:getContentSize().height*0.95))
    -- colseMenuItem:registerScriptTapHandler(closeMenuCallBack)
    -- bgMenu:addChild(colseMenuItem)

    --确认按钮    
    local confirmMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(160, 64),GetLocalizeStringBy("djn_186"),ccc3(0xff, 0xf6, 0x00),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    confirmMenuItem:setAnchorPoint(ccp(0.5,0))
    confirmMenuItem:setPosition(ccp(bgSprite:getContentSize().width*0.3, 50))
    confirmMenuItem:registerScriptTapHandler(confirmCallBack)
    bgMenu:addChild(confirmMenuItem)
    --取消按钮
    local cancelMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(160, 64),GetLocalizeStringBy("key_2326"),ccc3(0xff, 0xf6, 0x00),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    cancelMenuItem:setAnchorPoint(ccp(0.5,0))
    cancelMenuItem:setPosition(ccp(bgSprite:getContentSize().width*0.7, 50))
    cancelMenuItem:registerScriptTapHandler(closeMenuCallBack)
    bgMenu:addChild(cancelMenuItem)

    local affixName = {{GetLocalizeStringBy("lcy_10014"),GetLocalizeStringBy("lcy_10015")},{GetLocalizeStringBy("llp_114")},{GetLocalizeStringBy("llp_113")}}
    local pillId = (PillData.getInfoByTypeAndPage(_pPage,_pType)).Pill_id
    local dbInfo = DB_Item_normal.getDataById(pillId)
    local pillName = dbInfo.name or ""
    local pill_quality = dbInfo.quality or 1
    local addAffix = PillData.getAffixByPos(_pType,_pPage,_pPos)
    -- local sumAffix = 0
    -- if(table.isEmpty(addAffix) == false)then
    --     for k,v in pairs(addAffix)do
    --         sumAffix = sumAffix + v[2]
    --     end
    -- end

    --描述说明
   --print("createBgUI getHaveNumByTypeAndPage",PillData.getHaveNumByTypeAndPage(p_type,p_page))
    local richInfo = {elements = {},alignment = 2,lineAlignment = 2,defaultType = "CCRenderLabel",width = 400}
        richInfo.elements[1] = {
                text = GetLocalizeStringBy("key_2886"),
                font = g_sFontName,
                size = 22,
                color = ccc3(0xff,0xff,0xff)}
        richInfo.elements[2] = {
                text = PillData.getHaveNumByTypeAndPage(_pType,_pPage)+1,
                font = g_sFontName,
                size = 22,
                color = ccc3(0x00,0xff,0x18)}
        richInfo.elements[3] = { 
                text = GetLocalizeStringBy("key_3010")..GetLocalizeStringBy("djn_186"),
                font = g_sFontName,
                size = 22,
                color = ccc3(0xff,0xff,0xff)}
        richInfo.elements[4] = {
                text = pillName,
                font = g_sFontName,
                size = 22,
                color = HeroPublicLua.getCCColorByStarLevel(pill_quality) or ccc3(0xff,0xff,0xff)}
        richInfo.elements[5] = {
                text = ","..affixName[_pType][1],
                font = g_sFontName,
                size = 22,
                color = ccc3(0xff,0xff,0xff)}
        richInfo.elements[6] = { 
                text = "+"..addAffix[1][2],
                font = g_sFontName,
                size = 22,
                color = ccc3(0x00,0xff,0x18)}
        if(_pType == TYPE_DEFENSE)then
            richInfo.elements[7] = {
                text = ","..affixName[_pType][2],
                font = g_sFontName,
                size = 22,
                color = ccc3(0xff,0xff,0xff)}
            richInfo.elements[8] = { 
                text = "+"..addAffix[2][2],
                font = g_sFontName,
                size = 22,
                color = ccc3(0x00,0xff,0x18)}
        end
        local elementab = {}
        elementab = { 
                newLine = true,
                text = GetLocalizeStringBy("lcy_10019"),
                font = g_sFontName,
                size = 22,
                color = ccc3(0xff,0xff,0xff)}
        table.insert(richInfo.elements,elementab)
        elementab = {
                text = pillName,
                font = g_sFontName,
                size = 22,
                color = HeroPublicLua.getCCColorByStarLevel(pill_quality) or ccc3(0xff,0xff,0xff)}
        table.insert(richInfo.elements,elementab)
        elementab =  { 
                text = GetLocalizeStringBy("key_3205")..":".._pHaveNum,
                font = g_sFontName,
                size = 22,
                color = ccc3(0xff,0xff,0xff)}
        table.insert(richInfo.elements,elementab)

    local midSp = LuaCCLabel.createRichLabel(richInfo)
    midSp:setAnchorPoint(ccp(0.5,0.5))
    midSp:setPosition(ccpsprite(0.5,0.55,bgSprite))
    bgSprite:addChild(midSp)
end

----------------------------------------入口函数
----------前四个参数不可省
function showLayer(p_type,p_page,p_pos,p_hid,p_itemId,p_touchPriority,p_ZOrder,P_haveNum)
    
        init()
        _touchPriority = p_touchPriority or -550
        _ZOrder = p_ZOrder or 999
        _pType = tonumber(p_type) or 1  --前四个参数不可省！为了防止崩才加了默认值
        _pPage = tonumber(p_page) or 1
        _pPos = tonumber(p_pos) or 1
        _hid = tonumber(p_hid) or 1
        _pItemId = p_itemId or 1
        _pHaveNum = P_haveNum or 1
        _pId = PillData.getInfoByTypeAndPage(_pPage,_pType).id
        _lastFightForce = FightForceModel.dealParticularValues(_hid)
        _bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
        _bgLayer:registerScriptHandler(onNodeEvent)
        local curScene = CCDirector:sharedDirector():getRunningScene()
        curScene:addChild(_bgLayer,_ZOrder)
    
        --创建背景UI 
        createBgUI()
        
    return _bgLayer


end