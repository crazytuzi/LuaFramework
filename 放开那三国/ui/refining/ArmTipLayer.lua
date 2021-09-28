-- Filename: ArmTipLayer.lua
-- Author: zhang zihang
-- Date: 2015-4-28
-- Purpose: 该文件用于: 炼化装备提示

module ("ArmTipLayer", package.seeall)

require "script/ui/hero/HeroPublicLua"
require "script/utils/BaseUI"

local _bgLayer = nil
local _touchProperty 
local _zOrder
local _callBackFn
local beginHeight
local breakSayBg

local function init()
	_bgLayer = nil
	_touchProperty= nil
	_zOrder= nil
	_callBackFn= nil
    beginHeight = nil
    breakSayBg = nil
end

local function onTouchesHandler(  )
	return true
end

local function onNodeEvent( event )
    if (event == "enter") then
        _bgLayer:registerScriptTouchHandler(onTouchesHandler, false, _touchProperty, true)
        _bgLayer:setTouchEnabled(true)
    elseif (event == "exit") then

        _bgLayer:unregisterScriptTouchHandler()
    end
end

function closeCb()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
end

function okCb()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil

	if(_callBackFn~= nil) then 
		_callBackFn()
	end
end

-- 
function showLayer( itemInfo, callBackFn,touchProperty, zOrder )
	init()

    local fiveInfo = itemInfo.fiveItem
    local sixInfo = itemInfo.sixItem

	_callBackFn= callBackFn
	_touchProperty = touchProperty or -555
	_zOrder = zOrder or _zOrder

	_bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
    _bgLayer:registerScriptHandler(onNodeEvent)
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(_bgLayer, 999)

    local sizeHeight = 200 + math.ceil(table.count(fiveInfo)/3)*40 + math.ceil(table.count(sixInfo)/3)*40 
    if not table.isEmpty(fiveInfo) then
        sizeHeight = sizeHeight + 80
    end

    if not table.isEmpty(sixInfo) then
        sizeHeight = sizeHeight + 160
    end

	require "script/ui/main/MainScene"
    local myScale = MainScene.elementScale
	local mySize = CCSizeMake(550,sizeHeight)

	local fullRect = CCRectMake(0, 0, 213, 171)
	local insetRect = CCRectMake(84, 84, 2, 3)
    breakSayBg = CCScale9Sprite:create("images/common/viewbg1.png",fullRect,insetRect)
    breakSayBg:setContentSize(mySize)
    breakSayBg:setScale(myScale)
    breakSayBg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    breakSayBg:setAnchorPoint(ccp(0.5,0.5))
    _bgLayer:addChild(breakSayBg)

    local labelTitle = CCRenderLabel:create(GetLocalizeStringBy("key_3158"), g_sFontPangWa,35,2,ccc3(0xff,0xff,0xff),type_shadow)
	labelTitle:setPosition(ccp(breakSayBg:getContentSize().width/2, breakSayBg:getContentSize().height-35))
	labelTitle:setAnchorPoint(ccp(0.5,1))
	labelTitle:setColor(ccc3(0x78,0x25,0x00))
	breakSayBg:addChild(labelTitle)

    beginHeight = breakSayBg:getContentSize().height - 60

    if not table.isEmpty(sixInfo) then
        addNode(sixInfo)
    end

    if not table.isEmpty(fiveInfo) then
        addNode(fiveInfo)
    end

    local menu = CCMenu:create()
    menu:setPosition(ccp(0,0))
    menu:setTouchPriority(-600)
    breakSayBg:addChild(menu,99)

    local width = nil
    local cancelBtn = CCMenuItemImage:create("images/common/btn/btn_blue_n.png", "images/common/btn/btn_blue_h.png")
    cancelBtn:setPosition(ccp(breakSayBg:getContentSize().width*0.75,35))
    cancelBtn:setAnchorPoint(ccp(0.5,0))
    menu:addChild(cancelBtn)
    local closeLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2326"), g_sFontPangWa,30,2,ccc3(0x00,0x00,0x0),type_stroke)
    closeLabel:setColor(ccc3(0xfe,0xdb,0x1c))
    width = (cancelBtn:getContentSize().width - closeLabel:getContentSize().width)/2
    closeLabel:setPosition(ccp(width,54))
    cancelBtn:addChild(closeLabel)
    cancelBtn:registerScriptTapHandler(closeCb)

    local okBtn = CCMenuItemImage:create("images/common/btn/btn_blue_n.png", "images/common/btn/btn_blue_h.png")
    okBtn:setPosition(ccp(breakSayBg:getContentSize().width*0.25,35))
    okBtn:setAnchorPoint(ccp(0.5,0))
    menu:addChild(okBtn)
    local closeLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1465"), g_sFontPangWa,30,2,ccc3(0x00,0x00,0x0),type_stroke)
    closeLabel:setColor(ccc3(0xfe,0xdb,0x1c))
    width = (okBtn:getContentSize().width - closeLabel:getContentSize().width)/2
    closeLabel:setPosition(ccp(width,54))
    okBtn:addChild(closeLabel)
    okBtn:registerScriptTapHandler(okCb)
    
    local closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    closeBtn:setPosition(ccp(mySize.width*1.03,mySize.height*1.03))
    closeBtn:setAnchorPoint(ccp(1,1))
    closeBtn:registerScriptTapHandler(closeCb)
    menu:addChild(closeBtn)

end

--[[
    @des    :添加node的公共方法
    @param  :物品信息
    @return :
--]]
function addNode(itemInfo)
    beginHeight = beginHeight - 40

    local content = CCLabelTTF:create(GetLocalizeStringBy("key_2364") , g_sFontName ,24)
    content:setColor(ccc3(0x78,0x25,0x00))
    content:setPosition(ccp(breakSayBg:getContentSize().width/2, beginHeight))
    content:setAnchorPoint(ccp(0.5,0.5))
    breakSayBg:addChild(content)

    if table.count(itemInfo) > 3 then
        local contentTable = {}
        for i = 1,3 do
            local aleteNode = getContentNode(itemInfo[i])
            table.insert(contentTable,aleteNode)
        end

        addNodeChild(contentTable)

        local contentTable = {}
        for i = 4,#itemInfo do
            local aleteNode = getContentNode(itemInfo[i])
            table.insert(contentTable,aleteNode)
        end

        addNodeChild(contentTable)
    else
        local contentTable = {}
        for i = 1,#itemInfo do
            local aleteNode = getContentNode(itemInfo[i])
            table.insert(contentTable,aleteNode)
        end

        addNodeChild(contentTable)
    end

    local content2 = CCLabelTTF:create(GetLocalizeStringBy("key_1079"), g_sFontName ,24)
    content2:setColor(ccc3(0x78,0x25,0x00))
    local content3 = CCRenderLabel:create( itemInfo[1].itemDesc.quality .. GetLocalizeStringBy("key_1119"), g_sFontName ,24,1,ccc3(0x0,0x0,0x0), type_stroke)
    content3:setColor(HeroPublicLua.getCCColorByStarLevel(tonumber(itemInfo[1].itemDesc.quality)))
    local content4 = CCLabelTTF:create( GetLocalizeStringBy("key_3388"), g_sFontName ,24)
    content4:setColor(ccc3(0x78,0x25,0x00))

    local content_1 = CCLabelTTF:create(GetLocalizeStringBy("zzh_1173"),g_sFontName,24)
    content_1:setColor(ccc3(0x78,0x25,0x00))
    
    beginHeight = beginHeight - 40

    local aleteNode
    local exLabelTTF
    local exLabelTTF_2
    if tonumber(itemInfo[1].itemDesc.quality) == 5 then
        aleteNode = BaseUI.createHorizontalNode({content2, content3,content4})
    else
        aleteNode = BaseUI.createHorizontalNode({content2, content3,content_1})
        exLabelTTF = CCLabelTTF:create(GetLocalizeStringBy("zzh_1177"),g_sFontName,24)
        exLabelTTF:setColor(ccc3(0x78,0x25,0x00))
        exLabelTTF:setAnchorPoint(ccp(0.5,0.5))
        exLabelTTF_2 = CCLabelTTF:create(GetLocalizeStringBy("zzh_1174"),g_sFontName,24)
        exLabelTTF_2:setColor(ccc3(0x78,0x25,0x00))
        exLabelTTF_2:setAnchorPoint(ccp(0.5,0.5))
    end
    aleteNode:setAnchorPoint(ccp(0.5, 0.5))
    aleteNode:setPosition(ccp(breakSayBg:getContentSize().width/2, beginHeight))

    if tonumber(itemInfo[1].itemDesc.quality) == 6 then
        beginHeight = beginHeight - 40
        exLabelTTF:setPosition(ccp(breakSayBg:getContentSize().width/2, beginHeight))
        breakSayBg:addChild(exLabelTTF)
        beginHeight = beginHeight - 40
        exLabelTTF_2:setPosition(ccp(breakSayBg:getContentSize().width/2, beginHeight))
        breakSayBg:addChild(exLabelTTF_2)
    end
    
    breakSayBg:addChild(aleteNode)
end

--[[
    @des    :添加内部node的公用方法
    @param  :物品信息
    @return :添加好的node
--]]
function getContentNode(p_info)
    local content = CCRenderLabel:create("[" .. p_info.itemDesc.name .. "]", g_sFontName ,24,1,ccc3(0x0,0x0,0x0), type_stroke)
    content:setColor(HeroPublicLua.getCCColorByStarLevel(p_info.itemDesc.quality))
    local content2 = CCLabelTTF:create("，", g_sFontName ,24)
    content2:setColor(ccc3(0x78,0x25,0x00))
    local aleteNode = BaseUI.createHorizontalNode({content, content2})

    return aleteNode
end

--[[
    @des    :把node添加为child
    @param  :node信息
    @return :
--]]
function addNodeChild(p_table)
    beginHeight = beginHeight - 40

    local aleteNode = BaseUI.createHorizontalNode(p_table)
    aleteNode:setAnchorPoint(ccp(0.5, 0.5))
    aleteNode:setPosition(ccp(breakSayBg:getContentSize().width/2, beginHeight))
    breakSayBg:addChild(aleteNode)
end