-- Filename：	SSInfoLayer.lua
-- Author：		zhang zihang
-- Date：		2015-4-2
-- Purpose：		特殊技能信息页面

module("SSInfoLayer",package.seeall)

require "script/ui/athena/AthenaData"
require "script/ui/athena/AthenaUtils"

local _touchPriority
local _zOrder
local _bgLayer
local _itemId

--[[
	@des 	:初始化
--]]
function init()
    _touchPriority = nil
    _zOrder = nil
    _bgLayer = nil
    _itemId = nil
end

--[[
	@des 	:触摸回调
	@param  :事件
--]]
function onTouchesHandler(p_eventType)
    if p_eventType == "began" then
        return true
    end
end

--[[
	@des 	:touch事件
	@param  :事件
--]]
function onNodeEvent(p_event)
    if p_event == "enter" then
        _bgLayer:registerScriptTouchHandler(onTouchesHandler,false,_touchPriority,true)
        _bgLayer:setTouchEnabled(true)
    elseif p_event == "exit" then
        _bgLayer:unregisterScriptTouchHandler()
    end
end

--[[
	@des 	:关闭回调
--]]
function closeCallBack()
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    removeLayer()
end

--[[
	@des 	:删除layer
--]]
function removeLayer()
    _bgLayer:removeFromParentAndCleanup(true)
    _bgLayer = nil
end

--[[
	@des 	:创建UI
--]]
function createUI()
    --当前所在页面
    local curPage = AthenaData.getCurPageNo()
    local treeInfo = AthenaData.getTreeDBInfo(curPage)
    local skillType = tonumber(treeInfo.type)
    local skillInfo = AthenaData.getSSDBInfo(_itemId,skillType)
    --技能描述
    local desStr = skillInfo.des
    local skillType = AthenaData.getSkillType(curPage)
    if(skillType == AthenaData.kNormaoSkillType or skillType == AthenaData.kAngrySkillType)then
        --技能
        desStr = (string.gsub(desStr,GetLocalizeStringBy("djn_178"),""))
        desStr = (string.gsub(desStr,GetLocalizeStringBy("djn_179"),""))
        desStr = desStr..GetLocalizeStringBy("djn_180")
    end


    local desLabel = CCLabelTTF:create(desStr,g_sFontName,24,CCSizeMake(290,170),kCCTextAlignmentLeft)

    local desSize = desLabel:getContentSize()
    local addHeight = (desSize.height > 55) and (desSize.height - 55) or 0

    --背景大小
    local bgSize = CCSizeMake(555,395 + addHeight)
    --背景图
    local bgSprite = CCScale9Sprite:create(CCRectMake(100,80,10,20),"images/common/viewbg1.png")
    bgSprite:setContentSize(bgSize)
    bgSprite:setAnchorPoint(ccp(0.5,0.5))
    bgSprite:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    bgSprite:setScale(g_fElementScaleRatio)
    _bgLayer:addChild(bgSprite)


    --标题背景
    local titleSprite = CCSprite:create("images/common/viewtitle1.png")
    titleSprite:setAnchorPoint(ccp(0.5,0.5))
    titleSprite:setPosition(ccp(bgSprite:getContentSize().width/2,bgSprite:getContentSize().height - 6))
    bgSprite:addChild(titleSprite)

    local titleSize = titleSprite:getContentSize()

    --标题
    local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2276"),g_sFontPangWa,33)
    titleLabel:setColor(ccc3(0xff,0xe4,0x00))
    titleLabel:setAnchorPoint(ccp(0.5,0.5))
    titleLabel:setPosition(ccp(titleSize.width*0.5,titleSize.height*0.5))
    titleSprite:addChild(titleLabel)

    --背景按钮层
    local bgMenu = CCMenu:create()
    bgMenu:setAnchorPoint(ccp(0,0))
    bgMenu:setPosition(ccp(0,0))
    bgMenu:setTouchPriority(_touchPriority - 1)
    bgSprite:addChild(bgMenu)

    --关闭按钮
    local closeMenuItem = CCMenuItemImage:create("images/common/btn_close_n.png","images/common/btn_close_h.png")
    closeMenuItem:setAnchorPoint(ccp(1,1))
    closeMenuItem:setPosition(ccp(bgSize.width*1.03,bgSize.height*1.03))
    closeMenuItem:registerScriptTapHandler(closeCallBack)
    bgMenu:addChild(closeMenuItem)

    local secBgSize = CCSizeMake(495,220 + addHeight)
    -- 黑色的背景
    local secBgSprite = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
    secBgSprite:setContentSize(secBgSize)
    secBgSprite:setPosition(ccp(bgSize.width*0.5,bgSize.height - 55))
    secBgSprite:setAnchorPoint(ccp(0.5,1))
    bgSprite:addChild(secBgSprite)

    --技能名字
    local nameLabel = CCLabelTTF:create(skillInfo.name,g_sFontPangWa,30)
    nameLabel:setColor(ccc3(255,0,0xe1))
    nameLabel:setAnchorPoint(ccp(0.5,1))
    nameLabel:setPosition(ccp(secBgSize.width*0.5,secBgSize.height - 20))
    secBgSprite:addChild(nameLabel)
    --第一层分线
    local firstLineSprite = CCScale9Sprite:create("images/common/line02.png")
    firstLineSprite:setContentSize(CCSizeMake(470,5))
    firstLineSprite:setAnchorPoint(ccp(0.5,0.5))
    firstLineSprite:setPosition(ccp(secBgSize.width*0.5,secBgSize.height - 65))
    secBgSprite:addChild(firstLineSprite)

    local desPosY = secBgSize.height - 100

    --技能图标
    local skillSprite = AthenaUtils.getSpecialSkillSprite(curPage)
    skillSprite:setAnchorPoint(ccp(0,1))
    skillSprite:setPosition(ccp(30,desPosY + 5))
    secBgSprite:addChild(skillSprite)

    local pathString
    local nameString
    if skillType == AthenaData.kNormaoSkillType then
        pathString = "images/hero/info/normal.png"
        nameString = GetLocalizeStringBy("key_1129")
    elseif (skillType == AthenaData.kAngrySkillType) then
        pathString = "images/hero/info/anger.png"
        nameString = GetLocalizeStringBy("key_2064")
    elseif (skillType == AthenaData.kAwakeSkillType) then
        pathString = "images/hero/info/awake.png"
        nameString = GetLocalizeStringBy("fqq_053")
    end

    --怒
    local angrySprite = CCSprite:create(pathString)
    angrySprite:setAnchorPoint(ccp(0,1))
    angrySprite:setPosition(ccp(140,desPosY))
    secBgSprite:addChild(angrySprite)
    local angrySpriteSize = angrySprite:getContentSize()
    local angryLabel = CCLabelTTF:create(nameString,g_sFontName,25)
    angryLabel:setColor(ccc3(0xff,0xff,0xff))
    angryLabel:setAnchorPoint(ccp(0.5,0.5))
    angryLabel:setPosition(ccp(angrySpriteSize.width*0.5,angrySpriteSize.height*0.5))
    angrySprite:addChild(angryLabel)

    desLabel:setColor(ccc3(0xff,0xff,0xff))
    desLabel:setAnchorPoint(ccp(0,1))
    desLabel:setPosition(ccp(190,desPosY))
    secBgSprite:addChild(desLabel)


     if(skillType == AthenaData.kAwakeSkillType)then
        --如果是觉醒技能
        local tipDes = CCLabelTTF:create(GetLocalizeStringBy("fqq_055"),g_sFontName,23)
        tipDes:setColor(ccc3(0xff,0xff,0xff))
        tipDes:setAnchorPoint(ccp(0.5,0))
        tipDes:setPosition(ccp(secBgSprite:getContentSize().width*0.5,30))
        secBgSprite:addChild(tipDes)
    end
    local SSOpenNeed = AthenaData.getUnlockSSInfo(curPage)
    local firstString
    if #SSOpenNeed >1 then
        firstString = GetLocalizeStringBy("zzh_1311")
    else
        firstString = GetLocalizeStringBy("zzh_1316")
    end

    local paramTable = {
        width = 500, -- 宽度
        alignment = 2, -- 对齐方式  1 左对齐，2 居中， 3右对齐
        elements ={}
    }

    for i = 1,#SSOpenNeed do
        local lockInfo = SSOpenNeed[i]
        local skillInfo = AthenaData.getSkillDBInfo(lockInfo.skill)
        local tempTable = {
            type = "CCRenderLabel",
            text = skillInfo.name,
            font = g_sFontName,
            size = 21,
            color = HeroPublicLua.getCCColorByStarLevel(skillInfo.skillQuality),
        }
        local comaTable = {
            type = "CCRenderLabel",
            text = " , ",
            font = g_sFontName,
            size = 21,
            color = ccc3(0x00,0xff,0x18),
        }
        table.insert(paramTable.elements,tempTable)
        if i ~= #SSOpenNeed then
            table.insert(paramTable.elements,comaTable)
        end
    end

    local firstLabelTable = {
        type = "CCRenderLabel",
        text = firstString,
        font = g_sFontName,
        size = 21,
        color = ccc3(0x00,0xff,0x18),
    }
    table.insert(paramTable.elements,firstLabelTable)
    local secTable = {
        type = "CCRenderLabel",
        text = GetLocalizeStringBy("zzh_1312",SSOpenNeed[1].lv),
        font = g_sFontName,
        size = 21,
        color = ccc3(0xff,0x00,0x00),
    }
    table.insert(paramTable.elements,secTable)
    local triTable = {
        type = "CCRenderLabel",
        text = GetLocalizeStringBy("zzh_1315"),
        font = g_sFontName,
        size = 21,
        color = ccc3(0x00,0xff,0x18),
    }
    table.insert(paramTable.elements,triTable)

    local upNode = LuaCCLabel.createRichLabel(paramTable)
    upNode:setAnchorPoint(ccp(0.5,0.5))
    upNode:setPosition(ccp(bgSize.width*0.5,80))
    bgSprite:addChild(upNode)

end

--[[
	@des 	:入口函数
	@param  :技能id
	@param  :触摸优先级
	@param  :Z轴
--]]
function showLayer(p_itemId,p_touchPriority,p_zOrder)
    init()

    _touchPriority = p_touchPriority or -550
    _zOrder = p_zOrder or 999

    _itemId = tonumber(p_itemId)
    _bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
    _bgLayer:registerScriptHandler(onNodeEvent)
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,_zOrder)

    createUI()
end

