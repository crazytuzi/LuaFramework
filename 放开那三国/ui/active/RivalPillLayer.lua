-- Filename：    RivalPillLayer.lua
-- Author：      DJN
-- Date：        2015-6-27
-- Purpose：     对方阵容丹药界面
module("RivalPillLayer", package.seeall)
require "script/ui/active/RivalPillData"
require "script/ui/pill/PillControler"
require "script/ui/star/StarSprite"
require "script/ui/item/ItemSprite"
require "script/libs/LuaCCLabel"
require "db/DB_Item_normal"
require "script/ui/hero/HeroPublicLua"

local _bgLayer
local _masklayer       -- 防止触摸向下传递的屏蔽层
local _priority
local _zOrder
local _remainBgSprite   --背景图
local _heroInfo         --当前武将信息
local _closeCb          --关闭后的回调
local TYPE_DEFENSE = 1 
local TYPE_LIFE    = 2
local TYPE_ATTACK  = 3
local _curType          --当前在哪种类型的丹药中
local _curPage          --当前在哪一页中
local _ltPos = ccp(-g_winSize.width*0.5,g_winSize.height*0.5)
local _midPos = ccp(g_winSize.width*0.5,g_winSize.height*0.5)
local _rtPos = ccp(g_winSize.width*1.5,g_winSize.height*0.5)
local _leftNode  --创建出左中右三个node 用于滑动切换 
local _midNode
local _rightNode 
local _beginPoint      --手指触摸起点
local _lastMovePoint   --松开点
local _canTouch        --控制当前屏幕是否可滑动
local kMoveValue = g_winSize.width*0.3              --超过屏幕0.3的滑动开始滑
local kMoveRight = 1                                --向右滑动
local kMoveLeft = 2                                 --向左滑动
local kLeftBtnTag = 1001                            --切换丹药类型的按钮
local kRightBtnTag = 1002
local _titleSprite                                  --标题中 描述丹药类型的图片
local tagPath =  {"images/pill/fangyu.png","images/pill/shengming.png","images/pill/gongji.png"}                           
local _maxTitlePath = {"images/pill/defense_pill_max.png","images/pill/life_pill_max.png","images/pill/attack_pill_max.png"}
local _minTitlePath = {"images/pill/defense_pill_min.png","images/pill/life_pill_min.png","images/pill/attack_pill_min.png"}
local _affixMap = {}--{{54,55},{51},{100}}                         --对应的三种类类型丹药增加的属性类型
local _refreshUINode    --界面中其余需要刷新元素的集合
local _maxPage          --当前类型最多有多少页 供刷新左右箭头使用
local _leftArrowSprite  --左箭头
local _rightArrowSprite  --右箭头
local _formationInfo     --筛选后的阵容信息
local _curHeroIndex      --当前武将在筛选后的信息中的位置索引
local _tagPosX = {0.2,0.5,0.8,0.2,0.5,0.8} --下面*品丹标签的位置X
local _tagPosY = {0.3,0.3,0.3,0.22,0.22,0.22} --下面*品丹标签的位置Y
local MAXTAG  = 6 --总共有*品丹
local _curTagMenuItem    --当前被选定的*品丹标签按钮
function init()
    _bgLayer = nil
    _priority = nil
    _zOrder = nil
    _heroInfo = {}
    _closeCb = nil
    _remainBgSprite = nil
    _curType = 1
    _curPage = 1
    _leftNode = nil
    _midNode = nil
    _rightNode = nil
    _beginPoint = nil
    _lastMovePoint = nil
    _canTouch = nil
    _refreshUINode = nil
    _titleSprite = nil
    _affixMap = {}
    _masklayer = nil
    --RivalPillData.initBagCache()
    _formationInfo = {}
    _curHeroIndex = nil
end
----------------------------------------事件函数----------------------------------------
--[[
    @des    :事件注册函数
    @param  :事件类型
    @return :
--]]
function onTouchesHandler(p_eventType,p_x,p_y)
    if p_eventType == "began" then
        _beginPoint = ccp(p_x,p_y)
        _lastMovePoint = ccp(p_x,p_y)

        --防止没有创建出来
        if _midNode == nil then
            return false
        end

        if(_canTouch == false)then
            return false
        end

        local nodeSize = _midNode:getContentSize()
        local nodeTouchPos = _midNode:convertToNodeSpace(_beginPoint)
        --如果点击范围在node范围内
        if p_x >= 0 and p_x <= g_winSize.width and
            nodeTouchPos.y >= 0 and nodeTouchPos.y <= nodeSize.height then
            _canTouch = false
            return true
        else
            return false
        end
    elseif p_eventType == "moved" then
        --偏移量
        local deltaX = p_x - _lastMovePoint.x
        moveNode(_leftNode,deltaX,_ltPos)
        moveNode(_midNode,deltaX,_midPos)
        moveNode(_rightNode,deltaX,_rtPos)
    else

        local deltaX = p_x - _lastMovePoint.x
        --如果向右滑动，且左边有图片则
        if deltaX > kMoveValue and _leftNode ~= nil  then
            moveToMidAction(kMoveRight)
          
        --如果向左滑动，且右边有图片则
        elseif deltaX < - kMoveValue and _rightNode ~= nil then
            moveToMidAction(kMoveLeft)
          
        else
            moveBackAction(_leftNode,_ltPos)
            moveBackAction(_midNode,_midPos)
            moveBackAction(_rightNode,_rtPos)
        end
        
    end
end

--[[
    @des    :事件注册函数
    @param  :事件
    @return :
--]]
function onNodeEvent(event)
    if event == "enter" then
        _bgLayer:registerScriptTouchHandler(onTouchesHandler,false,_priority,true)
        _bgLayer:setTouchEnabled(true)

    elseif eventType == "exit" then
        _bgLayer:unregisterScriptTouchHandler()

    end
end
function onTouchesHandlerMask(p_eventType,p_x,p_y)
    if p_eventType == "began" then
       return true
    elseif p_eventType == "moved" then     
    else
    end
end
--[[
    @des    :事件注册函数
    @param  :事件
    @return :
--]]
function onNodeEventMask(event)
    if event == "enter" then
        _masklayer:registerScriptTouchHandler(onTouchesHandlerMask,false,_priority,true)
        _masklayer:setTouchEnabled(true)

    elseif eventType == "exit" then
        _masklayer:unregisterScriptTouchHandler()

    end
end
--[[
    @des    :关闭界面回调
    @param  :
    @return :
--]]
function closeCallBack()
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    _masklayer:removeFromParentAndCleanup(true)
    _masklayer = nil
    if(_closeCb)then
        _closeCb()
    end
end
--中间三个标签的按钮回调
function typeCallBack(p_tag,p_item)
  
    local deltaType = 1
    if(p_tag == kLeftBtnTag)then
        deltaType = -1
    elseif(p_tag == kRightBtnTag)then
        deltaType = 1
    end
    _curType = _curType + deltaType
    if(_curType > TYPE_ATTACK)then
        _curType = TYPE_DEFENSE
    elseif(_curType < TYPE_DEFENSE)then
        _curType = TYPE_ATTACK
    end
    _curPage = 1
    refreshNodes()
    refreshUI()
end
--[[
    @des    :移动node
    @param  :node
    @param  :x偏移量
--]]
function moveNode(p_node,p_dx,p_oriPos)
    --如果没有node则
    if p_node == nil then
        return
    end
    local curPositionX = p_oriPos.x
    local curPositionY = p_oriPos.y

    local nextPositionX = curPositionX + p_dx
    p_node:setPosition(nextPositionX,curPositionY)
end
--[[
    @des    :左或右的图向中间移动
    @param  :方向
--]]
function moveToMidAction(p_direction)
    --滑动的时间
    local moveTime = 0.2
    --中间的图要移动到的位置
    local midMovePos
    --要移动到中间的node
    local toMidNode
    --要删除的node
    local delNode
    --下一个中间图片的下标
    local nextNo
    if p_direction == kMoveRight then
        midMovePos = _rtPos
        toMidNode = _leftNode
        delNode = _rightNode
        nextNo = _curHeroIndex - 1
    else
        midMovePos = _ltPos
        toMidNode = _rightNode
        delNode = _leftNode
        nextNo = _curHeroIndex + 1
    end

    _canTouch = false

    toMidNode:runAction(CCMoveTo:create(moveTime,_midPos))

    local moveOverCallBack = function()
        --不为空才删除
        if delNode ~= nil then
            delNode:removeFromParentAndCleanup(true)
        end
        if p_direction == kMoveRight then
            _midNode,_rightNode = toMidNode,_midNode
            _leftNode = createHeroUI(_curHeroIndex - 2,_ltPos)
        else
            _midNode,_leftNode = toMidNode,_midNode
            _rightNode = createHeroUI(_curHeroIndex + 2,_rtPos)
        end
        _curHeroIndex = nextNo
        --更改缓存中的当前武将信息
        _formationInfo = RivalPillData.getPillFormationInfo()
        local heroInfo =  _formationInfo[_curHeroIndex] 

        RivalPillData.transferPillInfo(heroInfo)
        refreshUI()
        _canTouch = true
    end

    _midNode:runAction(CCSequence:createWithTwoActions(
                           CCMoveTo:create(moveTime,midMovePos),
                           CCCallFunc:create(moveOverCallBack)
                           ))
end

--[[
    @des    :回到原位
    @param  :要移动的node
    @param  :原来的位置
--]]
function moveBackAction(p_node,p_position)
    if p_node == nil then
        return
    end
    p_node:runAction(CCSequence:createWithTwoActions(
                           CCMoveTo:create(0.2,p_position),
                           CCCallFunc:create(function ( ... )
                            _canTouch = true
                           end)
                           ))
    
    -- p_node:runAction(CCMoveTo:create(0.2,p_position))
end
--点击丹药标签的回调
function tagAction( p_tag,p_item)
   _curPage = p_tag
   _curTagMenuItem:setEnabled(true)
   _curTagMenuItem = p_item
   _curTagMenuItem:setEnabled(false)
   refreshUI()
end
--------------------------------为controler提供数据-------------------
function getCurType()
    return _curType
end
function getCurPage()
    return _curPage
end
function getTouchPri()
    return _priority
end
function getZorder()
    return _zOrder
end
function getHeroInfo()
    return _heroInfo
end
--------------------------------为controler提供数据结束-------------------   
--[[
    @des    :根据type和页码 创建一个页面UI
    @param  :
    @return :
--]]
function createPageUI(p_type,p_page)
    local p_type = tonumber(p_type)
    local p_page = tonumber(p_page)  
    local pillDbInfo = RivalPillData.getInfoByTypeAndPage(p_page,p_type)
    if(pillDbInfo == nil)then
        return 
    end
     -- body
    local nodeSize = CCSizeMake(640,960)
    --背景node
    local bgNode = CCNode:create()
    bgNode:setContentSize(nodeSize)
    bgNode:ignoreAnchorPointForPosition(false)
    bgNode:setAnchorPoint(ccp(0.5,0.5))
    --bgNode:setPosition(p_position)
    --bgNode:setScale(MainScene.elementScale)
    --_bgLayer:addChild(bgNode,3)

    -- local bgMenu = CCMenu:create()
    -- bgMenu:setTouchPriority(_priority-2)
    -- bgMenu:setAnchorPoint(ccp(0,0))
    -- bgMenu:setPosition(ccp(0,0))
    -- bgNode:addChild(bgMenu,2)
    local posInfoInDb = pillDbInfo.Pill_cxml
    local bgPos = nil
    local iconPos = {}
    --清一下上次加载的cxml
    package.loaded["db/drugCXml/"..posInfoInDb] = nil
    require ("db/drugCXml/"..posInfoInDb)    
    for k,v in pairs(DrugPosition.models.normal)do 
        local ID = tonumber(v.looks.look.armyID)
        if(ID == 10000)then
            bgPos = CCPointMake(tonumber(v.x),960 - tonumber(v.y))
        else
            iconPos[ID] = CCPointMake(tonumber(v.x),960 - tonumber(v.y))
        end
    end
    local iconBg = CCSprite:create("images/pill/"..pillDbInfo.Icon)
    iconBg:setAnchorPoint(ccp(1,0))
    iconBg:setPosition(bgPos)
    bgNode:addChild(iconBg)
    
    local pillNum = pillDbInfo.Pill_number
    local pillCount = RivalPillData.getHaveNumByTypeAndPage(p_type,p_page) or 0 
    --防止后端给的数据溢出UI
    if pillCount > pillNum then pillCount = pillNum end
    local menuItems = {}
    local iconSprite = {} 
   
    for i = 1,pillNum do
        local iconSprite = nil
        --iconSprite[i]实属不得已而为之 居然不支持相同的sprite多次被加到CCMenuItemSprite
        if(i <= pillCount)then 
            local i_data = DB_Item_normal.getDataById(pillDbInfo.Pill_id)
                iconSprite = CCSprite:create("images/base/props/" .. i_data.icon_small)
        elseif(i == pillCount +1)then
            -- local _,pillHaveNum = RivalPillData.getPillInBag(pillDbInfo.Pill_id)
            -- --print("pillHaveNumpillHaveNum",pillHaveNum)
            -- if(pillHaveNum and i <= pillCount + pillHaveNum)then
            --     --其实上面的 i <= pillCount + pillHaveNum 可以不判断  当需要开放所有孔位的时候 只用这一个判断就行
            --     iconSprite = CCSprite:create("images/pill/plus.png")
            --     PillControler.addActionToSprite(iconSprite)
            --     --schedule(_bgLayer,updateArrow,1)
            -- end
        end
        if(iconSprite)then
            -- local menuItems = CCMenuItemSprite:create(iconSprite,iconSprite) 
            -- menuItems:setAnchorPoint(ccp(1,0))
            -- menuItems:setPosition(iconPos[i])
            -- menuItems:registerScriptTapHandler(PillControler.pillIconCb)
            -- bgMenu:addChild(menuItems,1,i) 
            iconSprite:setAnchorPoint(ccp(1,0))
            iconSprite:setPosition(iconPos[i])
            bgNode:addChild(iconSprite)
        end

        --在图标下面加属性加成的标签
        local affixBg = CCScale9Sprite:create("images/common/bg/hui_bg.png")
        affixBg:setScaleY(0.8)
        affixBg:setScaleX(0.5)
        affixBg:ignoreAnchorPointForPosition(false)
        affixBg:setAnchorPoint(ccp(1, 1))
        affixBg:setPosition(iconPos[i])
        bgNode:addChild(affixBg)

        local addAffix = RivalPillData.getAffixByPos(p_type,p_page,i)
        -- local sumAffix = 0
        -- if(table.isEmpty(addAffix) == false)then
        --     for k,v in pairs(addAffix)do
        --         sumAffix = sumAffix + v[2]
        --     end
        -- end
        local numColor = i <= pillCount and ccc3(0x00,0xff,0x18) or ccc3(0xff,0xff,0xff)
        --描述说明
        local richInfo = {elements = {},alignment = 2,defaultType = "CCRenderLabel",}
            richInfo.elements[1] = {
                    ["type"] = "CCNode", 
                    create = function ( ... )
                        local nodeSprite = nil
                        if(i <= pillCount)then
                            nodeSprite = CCSprite:create(tagPath[p_type])
                        else
                            nodeSprite = BTGraySprite:create(tagPath[p_type])
                        end
                        return nodeSprite
                    end }
            richInfo.elements[2] = {
                    text = "+",
                    font = g_sFontName,
                    size = 21,
                    color = ccc3(0xff,0xff,0xff)}
            richInfo.elements[3] = { 
                    text = addAffix[1][2],
                    font = g_sFontName,
                    size = 21,
                    color = numColor}
        local midSp = LuaCCLabel.createRichLabel(richInfo)
        midSp:setScaleX(2)
        midSp:setAnchorPoint(ccp(0.5,0.5))
        midSp:setPosition(ccpsprite(0.5,0.5,affixBg))
        affixBg:addChild(midSp)
    end

    return bgNode

end
--[[
    @des    :根据type和页码 创建一个武将UI
    @param  :
    @return :
--]]
function createHeroUI(p_heroPage,p_position)
  
    local heroInfo =  _formationInfo[p_heroPage] 
    if(table.isEmpty(heroInfo))then
        return 
    end
     -- body
    local nodeSize = CCSizeMake(640,600)
    --背景node
    local bgNode = CCNode:create()
    bgNode:setContentSize(nodeSize)
    bgNode:ignoreAnchorPointForPosition(false)
    bgNode:setAnchorPoint(ccp(0.5,0.5))
    bgNode:setPosition(p_position)
    bgNode:setScale(MainScene.elementScale)
    _bgLayer:addChild(bgNode,2)

    --local heroSprite = StarSprite.createStarSprite(heroInfo.htid)
    --带时装的武将形象
    local dressId = nil
    if heroInfo.dress then
        dressId = heroInfo.dress["1"]
    end
    -- 新增幻化id, add by lgx 20160928
    local turnedId = tonumber(heroInfo.turned_id)
    local heroSprite = HeroUtil.getHeroBodySpriteByHTID( heroInfo.htid,dressId, nil, turnedId )
    heroSprite:setAnchorPoint(ccp(0.5,0.5))
    heroSprite:setPosition(ccpsprite(0.5,0.7,bgNode))
    bgNode:addChild(heroSprite)
    --变暗一些
    heroSprite:setColor(ccc3(155,155,155))
   
    return bgNode

end


function refreshUI()

    if(_refreshUINode ~= nil )then
        _refreshUINode:removeFromParentAndCleanup(true)
        _refreshUINode = nil
    end
    _refreshUINode = CCLayer:create()
    --_refreshUINode:setContentSize(CCSizeMake(640,960))
    _refreshUINode:ignoreAnchorPointForPosition(false)
    _bgLayer:addChild(_refreshUINode,3)

    local pillNode = createPageUI(_curType,_curPage)
    pillNode:ignoreAnchorPointForPosition(false)
    pillNode:setAnchorPoint(ccp(0.5,0.5))
    pillNode:setPosition(_midPos)
    pillNode:setScale(MainScene.elementScale)
    _refreshUINode:addChild(pillNode)

    --_refreshUINode:setScaleX(g_fScaleX)
    --刷新一下标题
    local maxTitleFrame = CCSpriteFrame:create(_maxTitlePath[_curType],CCRect(0,0,182,47))
    _titleSprite:setDisplayFrame(maxTitleFrame)
    local tagMenu = CCMenu:create()
    tagMenu:setAnchorPoint(ccp(0,0))
    tagMenu:setPosition(ccp(0,0))
    _refreshUINode:addChild(tagMenu)
    tagMenu:setTouchPriority(_priority-2) 
    for i = 1,MAXTAG do
        local tagSp = CCMenuItemImage:create("images/pill/"..i.."_tag_n.png","images/pill/"..i.."_tag_h.png","images/pill/"..i.."_tag_h.png")
        tagSp:setAnchorPoint(ccp(0.5,0.5))
        tagSp:setScale(MainScene.elementScale)
        tagSp:setPosition(ccpsprite(_tagPosX[i],_tagPosY[i],tagMenu))
        tagSp:registerScriptTapHandler(tagAction)
        tagMenu:addChild(tagSp,1,i)
    
        --**/**那句话
        local pillDbInfo = RivalPillData.getInfoByTypeAndPage(i,_curType)
        if(pillDbInfo)then
            local totalNum = pillDbInfo.Pill_number
            local haveNum = RivalPillData.getHaveNumByTypeAndPage(_curType,i)
            local numColor = ccc3(0xff,0x00,0x00)
            if(totalNum <= haveNum)then
                numColor = ccc3(0x00,0xff,0x18)
                --防止后端给的数据异常
                haveNum = totalNum
            end
            local richInfo = {elements = {},lineAlignment = 2,alignment = 2,defaultType = "CCRenderLabel",}
            richInfo.elements[1] = {
                    text = haveNum.."/",
                    font = g_sFontName,
                    size = 21,
                    color = ccc3(0x00,0xff,0x18)
                   }
            richInfo.elements[2] = {
                    text = totalNum,
                    font = g_sFontName,
                    size = 21,
                    color = numColor}
  
            local midSp = LuaCCLabel.createRichLabel(richInfo)
            midSp:setAnchorPoint(ccp(0.5,1))
            midSp:setPosition(ccpsprite(0.5,-0.01,tagSp))
            tagSp:addChild(midSp)
        end
    end
    --print("_curPage",_curPage)
    _curTagMenuItem = tolua.cast(tagMenu:getChildByTag(_curPage),"CCMenuItemImage")
    _curTagMenuItem:setEnabled(false)
    
    --底下的描述
    local fullRect = CCRectMake(0,0,640,51)
    local insetRect = CCRectMake(314,27,13,6)
    local bottomBg = CCScale9Sprite:create("images/god_weapon/view_bg.png",fullRect, insetRect)
    bottomBg:setContentSize(CCSizeMake(640,150))
    bottomBg:setAnchorPoint(ccp(0.5,0))
    bottomBg:setPosition(ccp(g_winSize.width*0.5,0)) 
    bottomBg:setScale(g_fScaleX)   
    _refreshUINode:addChild(bottomBg)

    local minTitle = CCSprite:create(_minTitlePath[_curType])
    minTitle:setAnchorPoint(ccp(0.5,0.5))
    minTitle:setPosition(ccpsprite(0.5,0.95,bottomBg))
    bottomBg:addChild(minTitle)

    local topLeftLine = CCSprite:create("images/god_weapon/cut_line.png")
    topLeftLine:setAnchorPoint(ccp(1,0.5))
    topLeftLine:setPosition(ccpsprite(0.4,0.75,bottomBg))
    bottomBg:addChild(topLeftLine)
    
    local topRightLine = CCSprite:create("images/god_weapon/cut_line.png")
    topRightLine:setAnchorPoint(ccp(1,0.5))
    topRightLine:setScaleX(-1)
    topRightLine:setPosition(ccpsprite(0.6,0.75,bottomBg))
    bottomBg:addChild(topRightLine)

    local affixStr = CCSprite:create("images/pill/affix_progress.png")
    affixStr:setAnchorPoint(ccp(0.5,0.5))
    affixStr:setPosition(ccpsprite(0.5,0.75,bottomBg))
    bottomBg:addChild(affixStr)

    local totalAffixArray = RivalPillData.getTotalAffixByTypeInDB(_curType)
    local totalAffix = RivalPillData.getAffixNumByMap(totalAffixArray,_affixMap[_curType][1]) or 10000
    local totalAffixForDefense = RivalPillData.getAffixNumByMap(totalAffixArray,_affixMap[_curType][2]) or 10000
    local haveAffix = RivalPillData.getAffixByHero(_formationInfo[_curHeroIndex])
    local haveAffixForOther = RivalPillData.getAffixNumByMap(haveAffix,_affixMap[_curType][1]) or 0
    local haveAffixForDefense = RivalPillData.getAffixNumByMap(haveAffix,_affixMap[_curType][2]) or 0
    local affixName = {{GetLocalizeStringBy("key_2804"),GetLocalizeStringBy("lcy_10015")},{GetLocalizeStringBy("llp_114")},{GetLocalizeStringBy("llp_113")}}
    --描述说明
    local richInfo = {elements = {},lineAlignment = 2,alignment = 2,defaultType = "CCLabelTTF",}
        local tmpRich ={}
        tmpRich = {
                text = affixName[_curType][1]..":",
                font = g_sFontName,
                size = 21,
                color = ccc3(0x00,0xff,0x18)
               }
        table.insert(richInfo.elements,tmpRich)
        tmpRich = {
                text = haveAffixForOther,
                font = g_sFontName,
                size = 21,
                color = ccc3(0x00,0xff,0x18)}
        table.insert(richInfo.elements,tmpRich)
        tmpRich = {
                text = "/"..totalAffix,
                font = g_sFontName,
                size = 21,
                color = ccc3(0xff,0xff,0xff)}
        table.insert(richInfo.elements,tmpRich)
    if(_curType == TYPE_DEFENSE)then
         tmpRich = {
                text = "   "..affixName[_curType][2]..":",
                font = g_sFontName,
                size = 21,
                color = ccc3(0x00,0xff,0x18)
               }
        table.insert(richInfo.elements,tmpRich)
        tmpRich = {
                text = haveAffixForDefense ,
                font = g_sFontName,
                size = 21,
                color = ccc3(0x00,0xff,0x18)}
        table.insert(richInfo.elements,tmpRich)
        tmpRich = {
                text = "/"..totalAffixForDefense,
                font = g_sFontName,
                size = 21,
                color = ccc3(0xff,0xff,0xff)}
        table.insert(richInfo.elements,tmpRich)
    end
 
    local midSp = LuaCCLabel.createRichLabel(richInfo)
    midSp:setAnchorPoint(ccp(0.5,1))
    midSp:setPosition(ccpsprite(0.5,0.65,bottomBg))
    bottomBg:addChild(midSp)

    --如果属性已经吃满 有max图标
    if(haveAffixForOther == totalAffix)then
        local maxSprite = CCSprite:create("images/pill/max.png")
        maxSprite:setAnchorPoint(ccp(1,1))
        maxSprite:setPosition(ccpsprite(0.9,0.65,bottomBg))
        bottomBg:addChild(maxSprite)
    end

    local bottomLeftLine = CCSprite:create("images/god_weapon/cut_line.png")
    bottomLeftLine:setAnchorPoint(ccp(1,0.5))
    bottomLeftLine:setPosition(ccpsprite(0.4,0.48,bottomBg))
    bottomBg:addChild(bottomLeftLine)
    
    local bottomRightLine = CCSprite:create("images/god_weapon/cut_line.png")
    bottomRightLine:setAnchorPoint(ccp(1,0.5))
    bottomRightLine:setScaleX(-1)
    bottomRightLine:setPosition(ccpsprite(0.6,0.48,bottomBg))
    bottomBg:addChild(bottomRightLine)

    local bottomRichInfo = {elements = {},lineAlignment = 2,alignment = 2,defaultType = "CCLabelTTF",}
    local tmpRich ={}
    tmpRich = {
                text = GetLocalizeStringBy("djn_191"),
                font = g_sFontName,
                size = 21,
                color = ccc3(0x00,0xff,0x18)
               }
    table.insert(bottomRichInfo.elements,tmpRich)       
        
    tmpRich = {
                text = GetLocalizeStringBy("djn_198"),
                newLine = true,
                font = g_sFontName,
                size = 21,
                color = ccc3(0x00,0xff,0x18)
               }
    table.insert(bottomRichInfo.elements,tmpRich)

    local bottomMidSp = LuaCCLabel.createRichLabel(bottomRichInfo)
    bottomMidSp:setAnchorPoint(ccp(0.5,0))
    bottomMidSp:setPosition(ccpsprite(0.5,0.09,bottomBg))
    bottomBg:addChild(bottomMidSp)
end
--刷新三个node
function refreshNodes( ... )
   
    if(_leftNode ~= nil)then
        _leftNode:removeFromParentAndCleanup(true)
        _leftNode = nil
    end
    _leftNode = createHeroUI(_curHeroIndex- 1,_ltPos)
    if(_midNode ~= nil)then
        _midNode:removeFromParentAndCleanup(true)
        _midNode = nil
    end
    _midNode = createHeroUI(_curHeroIndex,_midPos)
    if(_rightNode ~= nil)then
        _rightNode:removeFromParentAndCleanup(true)
        _rightNode = nil
    end
    _rightNode = createHeroUI(_curHeroIndex+1,_rtPos)
end
--[[
    @des    :刷新箭头
--]]
function updateArrow()
    --没有下一页
    if _curHeroIndex < _maxPage then
        _rightArrowSprite:setVisible(true)
    else
        _rightArrowSprite:setVisible(false)
    end

    if _curHeroIndex > 1 then
        _leftArrowSprite:setVisible(true)
    else
        _leftArrowSprite:setVisible(false)
    end
end
--[[
    @des    :创建不变的UI
    @param  :
    @return :
--]]
function createBaseUI()
    --背景
    _remainBgSprite = CCSprite:create("images/pill/starbg.png")
    _remainBgSprite:setScale(g_fBgScaleRatio)
    _remainBgSprite:setAnchorPoint(ccp(0.5,.5))
    _remainBgSprite:setPosition(ccp(g_winSize.width/2,g_winSize.height*0.5))
    --_remainBgSprite:setScale(g_fElementScaleRatio)
    _bgLayer:addChild(_remainBgSprite,1)
    _remainBgSprite:setColor(ccc3(155,155,155))

    --menu层
    local bgMenu = CCMenu:create()
    bgMenu:setAnchorPoint(ccp(0,0))
    bgMenu:setPosition(ccp(0,0))
    bgMenu:setTouchPriority(_priority - 1)
    _bgLayer:addChild(bgMenu,3)

    --返回按钮
    local returnButton = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
    returnButton:setScale(MainScene.elementScale)
    returnButton:setAnchorPoint(ccp(0.5,0.5))
    returnButton:setPosition(ccp(g_winSize.width*585/640,g_winSize.height*905/960))
    returnButton:registerScriptTapHandler(closeCallBack)
    bgMenu:addChild(returnButton)

    local titleBg = CCSprite:create("images/pill/title_box.png")
    titleBg:setAnchorPoint(ccp(0.5,1))
    titleBg:setScale(g_fScaleX)
    titleBg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height * 0.96))
    _bgLayer:addChild(titleBg,2) 
    --切换标签按钮
    local leftBtn = CCMenuItemImage:create("images/pill/left_btn_n.png","images/pill/left_btn_h.png")
    leftBtn:setAnchorPoint(ccp(0,1))
    leftBtn:setScale(g_fScaleX)
    leftBtn:setPosition(ccp(g_winSize.width*0.23,g_winSize.height * 0.95))
    leftBtn:registerScriptTapHandler(typeCallBack)
    bgMenu:addChild(leftBtn,1,kLeftBtnTag)

    local rightBtn = CCMenuItemImage:create("images/pill/right_btn_n.png","images/pill/right_btn_h.png")
    rightBtn:setAnchorPoint(ccp(1,1))
    rightBtn:setScale(g_fScaleX)
    rightBtn:setPosition(ccp(g_winSize.width*0.77,g_winSize.height * 0.95))
    rightBtn:registerScriptTapHandler(typeCallBack)
    bgMenu:addChild(rightBtn,1,kRightBtnTag)

    _titleSprite  = CCSprite:create(_maxTitlePath[_curType])
    _titleSprite:setAnchorPoint(ccp(0.5,0.5))
    titleBg:addChild(_titleSprite)
    _titleSprite:setPosition(ccpsprite(0.5,0.6,titleBg))

    --左右箭头
    _leftArrowSprite = CCSprite:create("images/common/left_big.png")
    _leftArrowSprite:setAnchorPoint(ccp(0,0.5))
    _leftArrowSprite:setPosition(ccp(0,g_winSize.height*0.5))
    _leftArrowSprite:setScale(g_fElementScaleRatio)
    _leftArrowSprite:setVisible(false)
    _bgLayer:addChild(_leftArrowSprite,2)

    _rightArrowSprite = CCSprite:create("images/common/right_big.png")
    _rightArrowSprite:setAnchorPoint(ccp(1,0.5))
    _rightArrowSprite:setPosition(ccp(g_winSize.width,g_winSize.height*0.5))
    _rightArrowSprite:setScale(g_fElementScaleRatio)
    _rightArrowSprite:setVisible(false)
    _bgLayer:addChild(_rightArrowSprite,2)  

    PillControler.addActionToSprite(_leftArrowSprite)
    PillControler.addActionToSprite(_rightArrowSprite)

    --定时器
    schedule(_bgLayer,updateArrow,1)

end
----------------------------------------入口函数----------------------------------------
function createLayer(p_heroIndex,p_closeCb,p_touch,p_zOr)   
    init()
    --MainScene.setMainSceneViewsVisible(false, false, false) 
   -- _heroInfo = p_heroInfo


    _closeCb = p_closeCb
    _priority = p_touch or -1100
    _zOrder = p_zOr or 19005

    _formationInfo = RivalPillData.getPillFormationInfo()
    print("RivalPillLayer _formationInfo")
    print_t(_formationInfo)
    _curHeroIndex = RivalPillData.getPillHeroIndex(p_heroIndex,_formationInfo)
    print("RivalPillLayer _curHeroIndex",_curHeroIndex)

    --print("_curHeroIndex",_curHeroIndex)
    --_heroInfo = p_heroInfo   
    _maxPage = table.count(_formationInfo)

    local heroInfo =  _formationInfo[_curHeroIndex] 

    RivalPillData.transferPillInfo(heroInfo)
    _affixMap =  RivalPillData.getAffixTypeTable()

    -- RivalPillData.transferPillInfo(_heroInfo)
    _masklayer =  CCLayer:create()
    _masklayer:registerScriptHandler(onNodeEventMask)

    _bgLayer = CCLayer:create()
    _bgLayer:registerScriptHandler(onNodeEvent)

    local curScene = CCDirector:sharedDirector():getRunningScene()
    curScene:addChild(_masklayer,_zOrder)

    _bgLayer:ignoreAnchorPointForPosition(false)
    _bgLayer:setAnchorPoint(ccp(0,0))
    _bgLayer:setPosition(ccp(0,0))
    _masklayer:addChild(_bgLayer)

    --创建背景UI
    createBaseUI()
    refreshUI()
    refreshNodes()

    return _bgLayer
end
