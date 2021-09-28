-- Filename：    RedCardDestinyLayer.lua
-- Author：      LLP
-- Date：        2016-5-30
-- Purpose：     红卡天命界面
module("RedCardDestinyLayer", package.seeall)

require "db/DB_Hero_destiny"
require "script/ui/redcarddestiny/RedCardDestinyData"
require "script/ui/redcarddestiny/RedCardDestinyController"
require "script/ui/item/ItemUtil"
require "script/utils/LevelUpUtil"

kInfo = 1
kFormation = 2
local _isSelf           = true
local _dbInfo           = DB_Hero_destiny.getDataById(1)
local _bottomBg         = nil
local _iconBackPos      = ccp(0,0)
local _bgLayer 			= nil
local _heroInfo 		= nil
local _leftNode 		= nil
local _midNode 			= nil
local _rightNode 		= nil
local _resourceHid  	= nil
local _effectDisPos     = ccp(0,0)
local _curPageBtn       = nil   -- 当前的分页
local _enterType 		= 0
local _curClick         = 1
local _priority 		= -1000
local _isPlay           = false
local _canTouch 		= true
local _isClickedItem    = nil
local _lastMovePoint	= nil
local _endPos           = ccp(-100,0)
local _beginPos         = ccp(-100,0)
local _posTable         = {}
local _itemTable        = {}
local _finalItem        = nil
local _specialTalentLabel       = nil
local _timer_refresh_arrows     = nil
local _pageMenuBarBg            = nil
local _destinyCountLabel        = nil
local _page_menu_offset                         -- 滑动偏移量
local _page_scroll_view                         -- 页数的ScrollView
local _left_arrows                              -- 左边箭头
local _left_arrows_gray
local _right_arrows                             -- 右边箭头
local _right_arrows_gray
local _ltPos 			= ccp(-g_winSize.width*0.5,g_winSize.height*0.5)
local _midPos 			= ccp(g_winSize.width*0.5,g_winSize.height*0.5)
local _rtPos 			= ccp(g_winSize.width*1.5,g_winSize.height*0.5)
local _curHeroIndex 	= 1
local _maxPage          = 0
local kMoveValue 		= g_winSize.width*0.3
local kMoveRight        = 1                                --向右滑动
local kMoveLeft         = 2                                 --向左滑动
local _cell_width       = 90
function init()
    _isSelf                 = true
    _effectDisPos           = ccp(0,0)
    _bottomBg               = nil
    _posTable               = {}
    _itemTable              = {}
    _page_menu_offset       = ccp(0,0)
    _iconBackPos            = ccp(0,0)
    _endPos                 = ccp(-100,0)
    _beginPos               = ccp(-100,0)
    _curClick               = 1
    _finalItem              = nil
    _pageMenuBarBg          = nil
    _page_scroll_view       = nil                    -- 页数的ScrollView
    _left_arrows            = nil                    -- 左边箭头
    _left_arrows_gray       = nil
    _right_arrows           = nil                    -- 右边箭头
    _right_arrows_gray      = nil
    _curPageBtn             = nil
    _specialTalentLabel     = nil
    _destinyCountLabel      = nil
    _isClickedItem    = nil
	_bgLayer 		= nil
	_heroInfo 		= {}
	_leftNode 		= nil
	_midNode 		= nil
	_rightNode 		= nil
	_resourceHid  	= nil
    _timer_refresh_arrows     = nil
	_enterType 		= 0
	_priority 		= -400
    _isPlay           = false
	_canTouch 		= true
	_lastMovePoint	= nil
	_curHeroIndex 	= 1
    _maxPage        = 0
	_ltPos 			= ccp(-g_winSize.width*0.5,g_winSize.height*0.5)
	_midPos 		= ccp(g_winSize.width*0.5,g_winSize.height*0.5)
	_rtPos 			= ccp(g_winSize.width*1.5,g_winSize.height*0.5)
end

----------------------------------------事件函数----------------------------------------
--[[
    @des    :事件注册函数
    @param  :事件类型
    @return :
--]]
function onTouchesHandler(p_eventType,p_x,p_y)
    if p_eventType == "began" then
        if(_resourceHid)then
            return false
        end
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
--[[
    @des    :关闭界面回调
    @param  :
    @return :
--]]
function closeCallBack()
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
    _bgLayer:removeFromParentAndCleanup(true)
    _bgLayer = nil
    if(_isSelf)then
        if(_enterType==2)then
            require("script/ui/formation/FormationLayer")
            local formationLayer = FormationLayer.createLayer()
            MainScene.changeLayer(formationLayer, "formationLayer")
        else
            require "script/ui/hero/HeroLayer"
            MainScene.changeLayer(HeroLayer.createLayer(), "HeroLayer")
        end
    end
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
            delNode = nil
        end
        if p_direction == kMoveRight then
            _midNode,_rightNode = toMidNode,_midNode
            _leftNode = createHeroUI(_curHeroIndex - 2,_ltPos)
        else
            _midNode,_leftNode = toMidNode,_midNode
            _rightNode = createHeroUI(_curHeroIndex + 2,_rtPos)
        end
        _curHeroIndex = nextNo
        local num = tonumber(_heroInfo[_curHeroIndex].destiny)+1
        if(tonumber(_heroInfo[_curHeroIndex].destiny)==table.count(DB_Hero_destiny.Hero_destiny))then
            _bgLayer:removeChildByTag(3,true)
            num = tonumber(_heroInfo[_curHeroIndex].destiny)
            local label1 = CCLabelTTF:create(GetLocalizeStringBy("llp_461"),g_sFontPangWa,25)
                  label1:setScale(g_fElementScaleRatio)
                  label1:setAnchorPoint(ccp(0.5,0))
                  label1:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.2))
            if(_isSelf)then
                _bgLayer:addChild(label1,100,1)
            end
        else
            freshCost()
        end
        freshDestinyPoint(math.ceil(num/5),_curHeroIndex)
        freshTipLabel()

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
end

--[[
    @des    :显示Layer
    @param  :
    @return :
--]]
function showLayer( pEnterType,pHid,pPriority,pZorder,pWhereType )
	local layer = createLayer(pEnterType,pHid,pPriority)
	MainScene.changeLayer(layer, "RedCardDestinyLayer")
    MainScene.setMainSceneViewsVisible(false,false,false)
end

--[[
    @des    :创建Layer
    @param  :
    @return :
--]]
function createLayer(pEnterType,pHid,pPriority,pInfo)
	init()

	_enterType = pEnterType
	_priority = pPriority or _priority
	_bgLayer = CCLayer:create()
	_bgLayer:registerScriptHandler(onNodeEvent)
    local destinyTable = {}
    if(pInfo~=nil)then
        _heroInfo = pInfo.arrHero
        for k,v in pairs(_heroInfo) do
            _heroInfo[k].localInfo = DB_Heroes.getDataById(v.htid)
            local starLv = tonumber(DB_Heroes.getDataById(v.htid).star_lv)
            if(starLv>=7 and tonumber(v.hid)~=tonumber(pInfo.squad[1]))then
                table.insert(destinyTable,v)
            end
        end
        _heroInfo = destinyTable
        _isSelf = false
        if(table.count(_heroInfo)>1)then
            for k,v in pairs(_heroInfo) do
                if(tonumber(v.hid)==tonumber(pHid))then
                    _curHeroIndex = k
                    break
                end
            end
        end
    else
	   initHeroInfo(pEnterType,pHid)
    end
	createUI()

	return _bgLayer
end

--[[
    @des    :初始化英雄信息
    @param  :
    @return :
--]]
function initHeroInfo(pEnterType,pHid)
	if(pEnterType == 1)then
		_resourceHid = pHid
		_heroInfo[1] = HeroUtil.getHeroInfoByHid(pHid)
	else
        require "script/ui/hero/HeroPublicLua"
        local isOn = (HeroPublicLua.isInFormationByHid(pHid))
        if((HeroPublicLua.isInFormationByHid(pHid)))then
		    _heroInfo = DataCache.getRedFormation()
        else
            _resourceHid = pHid
            _heroInfo[1] = HeroUtil.getHeroInfoByHid(pHid)
        end
	end
    if(table.count(_heroInfo)>1)then
        for k,v in pairs(_heroInfo) do
            if(tonumber(v.hid)==tonumber(pHid))then
                _curHeroIndex = k
                return
            end
        end
    end
end

--[[
    @des    :创建基础UI
    @param  :
    @return :
--]]
function createUI()
	createBg()
    refreshNodes()
    local pageNum = math.ceil((tonumber(_heroInfo[_curHeroIndex].destiny)+1)/5)
    if(pageNum==0)then
        pageNum=1
    end
    if(tonumber(_heroInfo[_curHeroIndex].destiny)==table.count(DB_Hero_destiny.Hero_destiny))then
        pageNum = math.ceil((tonumber(_heroInfo[_curHeroIndex].destiny))/5)
    end
    createDestinyPoint(pageNum,1)
    if(_isSelf)then
        createBottom()
    end
end

function resetAction( ... )
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    local isCan = false
    if((tonumber(_heroInfo[_curHeroIndex].destiny) > 0))then
        if(tonumber(_heroInfo[_curHeroIndex].htid)<80000)then
            isCan = true
        elseif(tonumber(_heroInfo[_curHeroIndex].htid)>=80000 and tonumber(_heroInfo[_curHeroIndex].destiny) > 20)then
            isCan = true
        end
    else
        isCan = false
    end
    if( isCan == false )then
        require "script/ui/tip/AnimationTip"
        AnimationTip.showTip(GetLocalizeStringBy("llp_463"))
        return
    end
    local yesCallBack = function ()
        -- 判断背包是否满了
        if(ItemUtil.isBagFull())then
            closeCallBack()
            return
        end
        -- 判断金币是否够
        if(UserModel.getGoldNumber() < tonumber(DB_Normal_config.getDataById(1).destiny_reborn)) then
            require "script/ui/tip/AnimationTip"
            AnimationTip.showTip(GetLocalizeStringBy("key_1255"))
            return
        end
        local nextCallFun = function (p_retData )
            _bgLayer:removeChildByTag(9999,true)
            RedCardDestinyData.clearTotalAttForFightForce(_heroInfo[_curHeroIndex].hid)
            local isGold = false
            if(tonumber(_heroInfo[_curHeroIndex].htid)>=80000)then
                isGold = true
            end
            local data = RedCardDestinyData.getAllReward(_heroInfo[_curHeroIndex],isGold)
            -- for k,v in pairs(data) do
            --     local rewardData = string.split(v,"|")
            --     local cache = ItemUtil.getItemTypeByTId(tonumber(rewardData[2]))
            -- end
            -- 添加奖励
            local rewardTable = {}
            local data = RedCardDestinyData.getAllReward(_heroInfo[_curHeroIndex],isGold)
            for k,v in pairs(data) do
                local cache = ItemUtil.getItemsDataByStr(v)
                rewardTable[k] = cache[1]
            end
            require "script/ui/item/ReceiveReward"
            ReceiveReward.showRewardWindow( rewardTable, nil, 1010, _priority-30, GetLocalizeStringBy("llp_468"), {rewardTable} )
            -- 扣金币
            local num = tonumber(DB_Normal_config.getDataById(1).destiny_reborn)
            UserModel.addGoldNumber(-num)

            HeroModel.clearDestinyByHid( _heroInfo[_curHeroIndex].hid )
            initHeroInfo(_enterType,_heroInfo[_curHeroIndex].hid)
            local freshCallBack = function ( ... )
                local pageNum = math.ceil(tonumber(_heroInfo[_curHeroIndex].destiny+1)/5)
                if(pageNum==0)then
                    pageNum = 1
                end
                freshDestinyPoint(pageNum)
                createBottom()
            end
            
            local runningScene = CCDirector:sharedDirector():getRunningScene()
            performWithDelay(runningScene,freshCallBack,0.1)
        end
        require "script/ui/huntSoul/HuntSoulService"
        RedCardDestinyController.resetDestiny(_heroInfo[_curHeroIndex].hid,nextCallFun)
    end

    local tipNode = CCNode:create()
    tipNode:setContentSize(CCSizeMake(400,100))
    local str = RedCardDestinyData.getCurSpecialName(_heroInfo[_curHeroIndex].destiny,_heroInfo[_curHeroIndex])
    if(string.len(str)==0)then
        local dbInfo = DB_Heroes.getDataById(_heroInfo[_curHeroIndex].htid)
        str = dbInfo.name
    end
    
    local textInfo = {
            width = 400, -- 宽度
            alignment = 2, -- 对齐方式  1 左对齐，2 居中， 3右对齐
            labelDefaultFont = g_sFontName,      -- 默认字体
            labelDefaultSize = 25,          -- 默认字体大小
            labelDefaultColor = ccc3(0x78,0x25,0x00),
            linespace = 10, -- 行间距
            defaultType = "CCLabelTTF",
            elements =
            {   
                {
                    type = "CCLabelTTF", 
                    text = DB_Normal_config.getDataById(1).destiny_reborn,
                    color = ccc3(0x78,0x25,0x00),
                },
                {
                    type = "CCSprite", 
                    image = "images/common/gold.png",
                },
                {
                    type = "CCLabelTTF", 
                    text = str,
                    color = ccc3(255,0,0)
                }
            }
        }
    local tipDes = GetLocalizeLabelSpriteBy_2("llp_462", textInfo)
    tipDes:setAnchorPoint(ccp(0.5, 0.5))
    tipDes:setPosition(ccp(tipNode:getContentSize().width*0.5,tipNode:getContentSize().height*0.5))
    tipNode:addChild(tipDes)
    require "script/ui/tip/TipByNode"
    TipByNode.showLayer(tipNode,yesCallBack,CCSizeMake(500,360),-2000)
end

function lookAttAction( ... )
    -- body
    local data = RedCardDestinyData.getTotalAtt(_heroInfo[_curHeroIndex])
    RedCardDestinyData.getTotalAttForFightForce(_heroInfo[_curHeroIndex])
    if(table.isEmpty(data))then
        AnimationTip.showTip(GetLocalizeStringBy("llp_466"))
        return
    end
    local arrTabel = {}
    for k,v in pairs(data) do
        arrTabel[k] = {}
        local attName,disNum,realNum = ItemUtil.getAtrrNameAndNum(tonumber(v.txt),v.num)
        arrTabel[k].name = attName.sigleName
        arrTabel[k].value = disNum
    end
    require "script/ui/redcarddestiny/RedCardDestinyAttrDialog"
    RedCardDestinyAttrDialog.showTip(nil,nil,nil,-102001,arrTabel,GetLocalizeStringBy("llp_464"))
end

--[[
    @des    :创建Bg
    @param  :
    @return :
--]]
function createBg()
	--背景
    _remainBgSprite = CCSprite:create("images/redcarddestiny/destinybg.jpg")
    _remainBgSprite:setScale(g_fBgScaleRatio)
    _remainBgSprite:setAnchorPoint(ccp(0.5,0.5))
    _remainBgSprite:setPosition(ccp(g_winSize.width/2,g_winSize.height*0.5))
    _bgLayer:addChild(_remainBgSprite,1)
    --变暗一些
    _remainBgSprite:setColor(ccc3(155,155,155))


    _xmlSprite = XMLSprite:create("images/redcarddestiny/tainmingliuxing/tainmingliuxing")
    _xmlSprite:setPosition(ccp(_remainBgSprite:getContentSize().width*0.5,_remainBgSprite:getContentSize().height*0.5))
    _remainBgSprite:addChild(_xmlSprite)
    --menu层
    _bgMenu = CCMenu:create()
    _bgMenu:setAnchorPoint(ccp(0,0))
    _bgMenu:setPosition(ccp(0,0))
    _bgMenu:setTouchPriority(_priority - 1)
    _bgLayer:addChild(_bgMenu,3)

    --返回按钮
    local returnButton = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
    returnButton:setScale(MainScene.elementScale)
    returnButton:setAnchorPoint(ccp(0.5,0.5))
    returnButton:setPosition(ccp(g_winSize.width*585/640,g_winSize.height*900/960))
    returnButton:registerScriptTapHandler(closeCallBack)
    _bgMenu:addChild(returnButton)

    --天命总览
    local attTotalButton = CCMenuItemImage:create("images/redcarddestiny/atttotal1.png","images/redcarddestiny/atttotal2.png")
    attTotalButton:setScale(MainScene.elementScale)
    attTotalButton:setAnchorPoint(ccp(0,0.5))
    attTotalButton:setPosition(ccp(20,g_winSize.height*900/960))
    attTotalButton:registerScriptTapHandler(lookAttAction)
    _bgMenu:addChild(attTotalButton)

    --重置
    if(_isSelf)then
        local resetButton = CCMenuItemImage:create("images/redcarddestiny/reset1.png","images/redcarddestiny/reset2.png")
        resetButton:setScale(MainScene.elementScale)
        resetButton:setAnchorPoint(ccp(0,0.5))
        resetButton:setPosition(ccp(attTotalButton:getContentSize().width*MainScene.elementScale+40,g_winSize.height*900/960))
        resetButton:registerScriptTapHandler(resetAction)
        _bgMenu:addChild(resetButton)
    end

    local arrActions_1 = CCArray:create()
    arrActions_1:addObject(CCFadeOut:create(2))
    arrActions_1:addObject(CCFadeIn:create(2))
    local sequence_1 = CCSequence:create(arrActions_1)
    local action_1 = CCRepeatForever:create(sequence_1)

    local arrActions_2 = CCArray:create()
    arrActions_2:addObject(CCFadeOut:create(2))
    arrActions_2:addObject(CCFadeIn:create(2))
    local sequence_2 = CCSequence:create(arrActions_2)
    local action_2 = CCRepeatForever:create(sequence_2)
    --左右箭头
    _leftArrowSprite = CCSprite:create("images/common/left_big.png")
    _leftArrowSprite:setAnchorPoint(ccp(0,0.5))
    _leftArrowSprite:setPosition(ccp(0,g_winSize.height*0.5))
    _leftArrowSprite:setScale(g_fElementScaleRatio)
    _leftArrowSprite:setVisible(false)
    _bgLayer:addChild(_leftArrowSprite,3)
    _leftArrowSprite:runAction(action_1)

    _rightArrowSprite = CCSprite:create("images/common/right_big.png")
    _rightArrowSprite:setAnchorPoint(ccp(1,0.5))
    _rightArrowSprite:setPosition(ccp(g_winSize.width,g_winSize.height*0.5))
    _rightArrowSprite:setScale(g_fElementScaleRatio)
    _rightArrowSprite:setVisible(false)
    _bgLayer:addChild(_rightArrowSprite,3)  
    _rightArrowSprite:runAction(action_2)
    --定时器
    schedule(_bgLayer,updateArrow,1)
end

--[[
    @des    :根据type和页码 创建一个武将UI
    @param  :
    @return :
--]]
function createHeroUI(p_heroPage,p_position)
  
    local heroInfo =  _heroInfo[p_heroPage] 
    print("hahahahaha")
    print_t(heroInfo)
    _maxPage = table.count(_heroInfo)
    if(heroInfo == nil)then
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

   -- local heroSprite = StarSprite.createStarSprite(heroInfo.htid)
    --带时装的武将形象
    local dressId = nil
    if(_isSelf)then
        if(HeroModel.isNecessaryHeroByHid(heroInfo.hid))then
            --主角才带时装
            dressId = UserModel.getDressIdByPos(1)
        end
    end
    -- 新增幻化id, add by lgx 20160928
    local turnedId = tonumber(heroInfo.turned_id)
    local heroSprite = HeroUtil.getHeroBodySpriteByHTID( heroInfo.htid,dressId,nil,turnedId )
    heroSprite:setAnchorPoint(ccp(0.5,0.5))
    heroSprite:setPosition(ccpsprite(0.5,0.6,bgNode))
    bgNode:addChild(heroSprite)
    --变暗一些
    heroSprite:setColor(ccc3(155,155,155))
   
    return bgNode

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

function moveAction( i )
    -- body
    _itemTable[6]:setVisible(true)
    local moveEndPos = nil
    if(i==1)then
        moveEndPos = _posTable[11]
    else
        moveEndPos = _posTable[i-1]
    end
    local actionArray = CCArray:create()
    if(i==1)then
        actionArray:addObject(CCSpawn:createWithTwoActions(CCMoveTo:create(0.3, _endPos), CCScaleTo:create(1, 0)))
    else
        actionArray:addObject(CCMoveTo:create(0.3,moveEndPos))
    end
    
    actionArray:addObject(CCCallFuncN:create(function ( pNode )
        local dispearEffect = XMLSprite:create("images/redcarddestiny/tmxingxiaoshi/tmxingxiaoshi")
              dispearEffect:setAnchorPoint(ccp(1,0))
              dispearEffect:setReplayTimes(1,true)
              dispearEffect:setPosition(_effectDisPos)
              dispearEffect:setScale(g_fScaleX)
        _bgLayer:addChild(dispearEffect,111)
        if(i>1)then
            _itemTable[i-1] = _itemTable[i]
        end
        if(_itemTable[5]:getTag()== _finalItem:getTag()+4 )then
            for k,v in pairs(_itemTable)do
                v:stopAllActions()    
            end
            freshDestinyPoint(math.ceil((_finalItem:getTag()+1)/5))
            return
        end
        if(i>1)then
            moveAction(i-1)
        end
    end))
    _itemTable[i]:runAction(CCSequence:create(actionArray))
end

function firstEffectcallBack( ... )
        -- body
        -- 创建屏蔽层
        local runningScene = CCDirector:sharedDirector():getRunningScene()
        local maskLayer = BaseUI.createMaskLayer(-5000,nil,nil,0)
        runningScene:addChild(maskLayer,10000)
        -- 特效
        local successLayerSp = XMLSprite:create("images/base/effect/hero/transfer/zhuangchang")
        successLayerSp:setPosition(ccp((g_winSize.width-320*2*g_fElementScaleRatio)/2,g_winSize.height))
        successLayerSp:setScale(g_fElementScaleRatio)
        local runningScene = CCDirector:sharedDirector():getRunningScene()
        runningScene:addChild(successLayerSp,9999)
        -- 特效播放结束后
        local animationEnd = function()
            successLayerSp:removeFromParentAndCleanup(true)
            successLayerSp = nil
            -- 干掉屏蔽层
            if( maskLayer ~= nil )then
                maskLayer:removeFromParentAndCleanup(true)
                maskLayer = nil
            end
            fnCreateTransferEffect()
        end
        successLayerSp:registerEndCallback( animationEnd )
    end

-- 创建进阶特效
function fnCreateTransferEffect()

    local heroData = _heroInfo[_curHeroIndex]
    local affixData = FightForceModel.getHeroDisplayAffixByHeroInfo(heroData)
    
    local runningScene = CCDirector:sharedDirector():getRunningScene()
    local colorLayer = CCLayerColor:create(ccc4(0, 0, 0, 255))
    colorLayer:setTouchEnabled(true)
    colorLayer:setTouchPriority(-32767)
    local afterPlay = function ( ... )
        -----------开启每页最后一个天命运行的跑动Action
        if(tonumber(heroData.destiny)~=table.count(DB_Hero_destiny.Hero_destiny))then
            for i=1,10 do
                moveAction(i)
            end
        end
        ------------------------------------------
    end
    local function fnHandlerOfTouch(event, x, y)
        if event == "ended" then
            colorLayer:removeFromParentAndCleanup(true)
            colorLayer = nil
            for i=1,5 do
                local pItem = _itemTable[i]
                pItem:removeChildByTag(100,true)
                local openEffect = XMLSprite:create("images/redcarddestiny/tianmingbao/tianmingbao")
                if(i==1)then
                    openEffect:registerEndCallback(afterPlay)
                end
                openEffect:setReplayTimes(1,true)
                openEffect:setPosition(ccp(pItem:getContentSize().width*0.5*pItem:getScale(),pItem:getContentSize().height*0.5*pItem:getScale()))
                pItem:addChild(openEffect)
            end
            
        end
        return true
    end
    colorLayer:registerScriptTouchHandler(fnHandlerOfTouch, false, -32767, true)

    -- 转光特效
    local clsEffectZhuanGuang=XMLSprite:create("images/redcarddestiny/faguang/faguang")
    clsEffectZhuanGuang:setPosition(g_winSize.width/2, 500*g_fScaleY)
    clsEffectZhuanGuang:setScale(g_fElementScaleRatio)
    colorLayer:addChild(clsEffectZhuanGuang, 11, 100)
    clsEffectZhuanGuang:setVisible(false)
    
    -- 进阶成功特效
    local clsEffectSuccess=XMLSprite:create("images/redcarddestiny/dianliangchenggong/dianliangchenggong")
    clsEffectSuccess:setAnchorPoint(ccp(0.5, 0.5))
    clsEffectSuccess:setReplayTimes(1,false)
    clsEffectSuccess:setScale(g_fElementScaleRatio)
    clsEffectSuccess:setPosition(g_winSize.width/2, 250*g_fScaleY)
    colorLayer:addChild(clsEffectSuccess, 999, 999)
    -- if _tHeroTransferedAttr then
        require "script/ui/hero/HeroPublicCC"
        local csCardShow = HeroPublicCC.createSpriteCardShow(_heroInfo[_curHeroIndex].htid)
        csCardShow:setAnchorPoint(ccp(0.5, 0.5))
        csCardShow:setScale(g_fElementScaleRatio)
        csCardShow:setPosition(g_winSize.width/2, 500*g_fScaleY)
        colorLayer:addChild(csCardShow, 999, 999)
        csCardShow:setScale(1.5*g_fElementScaleRatio)
        local sequence = CCSequence:createWithTwoActions(CCScaleTo:create(0.3, 0.8*g_fElementScaleRatio),
            CCCallFunc:create(function ( ... )
                clsEffectZhuanGuang:setVisible(true)
                require "script/audio/AudioUtil"
                AudioUtil.playEffect("audio/effect/zhuanguang.mp3")
            end))
        csCardShow:runAction(sequence)
    -- end
    local nameStr = RedCardDestinyData.getCurSpecialName(_heroInfo[_curHeroIndex].destiny,_heroInfo[_curHeroIndex])
    if(string.len(nameStr)>0)then
        local spriteNode = CCSprite:create()
              spriteNode:setAnchorPoint(ccp(0.5,1))
        local openLabel = CCLabelTTF:create(GetLocalizeStringBy("key_8346"), g_sFontName, 32)
              openLabel:setAnchorPoint(ccp(0,0))
              openLabel:setPosition(ccp(0,0))
              openLabel:setScale(g_fElementScaleRatio)
        spriteNode:addChild(openLabel)
        local nameLabel = CCLabelTTF:create(nameStr, g_sFontName, 32)
              nameLabel:setAnchorPoint(ccp(0, 0))
              nameLabel:setScale(g_fElementScaleRatio)
			  if(tonumber(_heroInfo[_curHeroIndex].htid)>=80000)then --天命判断武将ID获取颜色在界面上显示【真和圣】
                nameLabel:setColor(ccc3(255,255,0))
				else
				nameLabel:setColor(ccc3(255,0,0))
            end
              --nameLabel:setColor(ccc3(255,0,0))
              nameLabel:setPosition(ccp(20*g_fElementScaleRatio + openLabel:getContentSize().width*g_fElementScaleRatio,0))
        spriteNode:addChild(nameLabel)
        spriteNode:setContentSize(CCSizeMake(20*g_fElementScaleRatio + openLabel:getContentSize().width*g_fElementScaleRatio+nameLabel:getContentSize().width*g_fElementScaleRatio,nameLabel:getContentSize().height*g_fElementScaleRatio))
        spriteNode:setPosition(g_winSize.width/2, 200*g_fElementScaleRatio)
        colorLayer:addChild(spriteNode, 999, 999)
    end
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/zhuanshengchenggong.mp3")
    local cnTalentUnlock = CCSprite:create()
    local destinyNum = _heroInfo[_curHeroIndex].destiny
    local str = RedCardDestinyData.getCurSpecialName(destinyNum,_heroInfo[_curHeroIndex])
    local awakeData = RedCardDestinyData.getCurSpecialAwake(destinyNum,_heroInfo[_curHeroIndex])
    local dbInfo = DB_Hero_destiny.getDataById(destinyNum)
    local attStr = dbInfo.attArr or ""
    
    if(table.count(awakeData)>0)then
        -- 天赋解锁显示区
        local csTalentUnlock = CCSprite:create("images/hero/transfer/level_up/unlock.png")
        cnTalentUnlock:setScale(g_fElementScaleRatio)
        cnTalentUnlock:addChild(csTalentUnlock)
        local desc = GetLocalizeStringBy("key_1554")

        local clTalentUnlockDesc = CCLabelTTF:create(awakeData.name, g_sFontName, 32)
        clTalentUnlockDesc:setColor(ccc3(255, 0xf6, 0))
        local tNodeSize = csTalentUnlock:getContentSize()
        clTalentUnlockDesc:setPosition(tNodeSize.width + 10, 0)
        csTalentUnlock:setPosition(csTalentUnlock:getPositionX(), 0)
        cnTalentUnlock:addChild(clTalentUnlockDesc)
        tNodeSize.width = tNodeSize.width + 10 + clTalentUnlockDesc:getContentSize().width
        cnTalentUnlock:setAnchorPoint(ccp(0.5, 1))
        cnTalentUnlock:setContentSize(CCSizeMake(tNodeSize.width, tNodeSize.height))
        cnTalentUnlock:setPosition(g_winSize.width/2, 160*g_fElementScaleRatio)
        clTalentUnlockDesc:setVisible(false)
        colorLayer:addChild(cnTalentUnlock)
        clTalentUnlockDesc:setVisible(true)
    elseif(string.len(attStr)>0)then
        local labelNode = CCSprite:create()
              labelNode:setAnchorPoint(ccp(0.5,1))
        colorLayer:addChild(labelNode)
        local labelSprite = CCSprite:create("images/redcarddestiny/labelSprite.png")
              labelSprite:setScale(g_fElementScaleRatio)
              labelSprite:setAnchorPoint(ccp(0,0))
              labelSprite:setPosition(ccp(0,0))
        labelNode:addChild(labelSprite,999)
        local attArray = string.split(attStr,"|")
        local attName,disNum,realNum = ItemUtil.getAtrrNameAndNum(attArray[1],attArray[2])
        local attLabel = CCLabelTTF:create(attName.sigleName.."+"..disNum,g_sFontName,32)
              attLabel:setScale(g_fElementScaleRatio)
              attLabel:setAnchorPoint(ccp(0,0))
              attLabel:setColor(ccc3(255,255,0))
              attLabel:setPosition(ccp(labelSprite:getContentSize().width*g_fElementScaleRatio,0))
        labelNode:addChild(attLabel,999)
        labelNode:setContentSize(CCSizeMake(labelSprite:getContentSize().width*g_fElementScaleRatio+attLabel:getContentSize().width*g_fElementScaleRatio,labelSprite:getContentSize().height*g_fElementScaleRatio))
        labelNode:setPosition(ccp(colorLayer:getContentSize().width*0.5,180*g_fScaleY))
    end
    

    runningScene:addChild(colorLayer, 32767, 32767)
end

function afterOpenDestinyCallBack( pItem )
    _curPage = math.ceil((_curClick+1)/5)
    local freshCallBack = function ( ... )
        local data = DB_Hero_destiny.getDataById(_curClick)
        if(tonumber(data.special)==1 or tonumber(data.special)==2)then
            firstEffectcallBack()
        else
            showFlyLabel(_curClick)
        end
        if((_curClick+1)>table.count(DB_Hero_destiny.Hero_destiny))then
            _bgLayer:removeChildByTag(1,true)
            _bgLayer:removeChildByTag(3,true)
            local label1 = CCLabelTTF:create(GetLocalizeStringBy("llp_461"),g_sFontPangWa,25)
                  label1:setScale(g_fElementScaleRatio)
                  label1:setAnchorPoint(ccp(0.5,0))
                  label1:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.2))
            _bgLayer:addChild(label1,100,1)
            freshDestinyPoint(math.ceil((tonumber(_heroInfo[_curHeroIndex].destiny))/5),_curHeroIndex)
            _canTouch = true
            return 
        end
        freshTipLabel()
        freshCost()
        if((_curClick%5)==0)then
            freshDestinyPoint(_curPage-1,_curHeroIndex)
        else
            if(_curPage==0)then
                _curPage = 1
            end
        end
        _canTouch = true
    end
    local runningScene = CCDirector:sharedDirector():getRunningScene()
    performWithDelay(runningScene,freshCallBack,0.1)
end

function isOneLine( pId )
    if(pId==100 or pId == 51 or pId== 54 or pId==55 or pId==59)then
        return true
    else
        return false
    end
end

function clickDestiny( tag,item )
    if(not _isSelf)then
        return
    end
    if(_isPlay==true)then
        return
    end
    _curClick = tag
    local pPage = math.ceil((tonumber(_heroInfo[_curHeroIndex].destiny))/5)
    if(pPage==0)then
        pPage=1
    end
    local labelName = nil
    local labelNum = nil
    if(item:getChildByTag(100) or tonumber(_heroInfo[_curHeroIndex].destiny)==table.count(DB_Hero_destiny.Hero_destiny))then
    
    else
        if(tag ~= (tonumber(_heroInfo[_curHeroIndex].destiny)+1))then
            local actionArray = CCArray:create()
                  actionArray:addObject(CCFadeOut:create(3))
                  actionArray:addObject(CCCallFuncN:create(function ( node )
                    node:removeFromParentAndCleanup(true)
                  end))
            local specialSprite = CCSprite:create("images/redcarddestiny/special.png")
                  specialSprite:setAnchorPoint(ccp(0.5,0))
                  specialSprite:setPosition(ccp(item:getContentSize().width*0.5,item:getContentSize().height))
            _dbInfo = DB_Hero_destiny.getDataById(tag)
            local attStr = _dbInfo.attArr
            local attArray = string.split(attStr,"|")
            local attName,disNum,realNum = ItemUtil.getAtrrNameAndNum(attArray[1],attArray[2])

            local isOne = isOneLine(tonumber(attArray[1]))
                if(isOne)then
                    labelName = CCLabelTTF:create(attName.sigleName.."+"..disNum,g_sFontName,20)
                          labelName:setAnchorPoint(ccp(0.5,0.5))
                          labelName:setPosition(ccp(specialSprite:getContentSize().width*0.5,specialSprite:getContentSize().height*0.5))
                          specialSprite:addChild(labelName)
                else
                    labelName = CCLabelTTF:create(attName.sigleName,g_sFontName,20)
                          labelName:setAnchorPoint(ccp(0.5,0))
                          labelName:setPosition(ccp(specialSprite:getContentSize().width*0.5,specialSprite:getContentSize().height*0.5))
                    labelNum = CCLabelTTF:create("+"..disNum,g_sFontName,20)
                          labelNum:setAnchorPoint(ccp(0.5,1))
                          labelNum:setPosition(ccp(specialSprite:getContentSize().width*0.5,specialSprite:getContentSize().height*0.5))
                    specialSprite:addChild(labelName)
                    specialSprite:addChild(labelNum)
                end
            item:addChild(specialSprite,1,101)
            specialSprite:runAction(CCSequence:create(actionArray))
            labelName:runAction(CCFadeOut:create(2.5))
            if(labelNum~=nil)then
                labelNum:runAction(CCFadeOut:create(2.5))
            end
            
        end
    end
    
    if( tag == (tonumber(_heroInfo[_curHeroIndex].destiny)+1) )then
        _canTouch = false
        local costData = RedCardDestinyData.getCostData(tonumber(_heroInfo[_curHeroIndex].destiny),_heroInfo[_curHeroIndex],true)
        local data = string.split(costData,",")
        local num = 0
        if(table.count(data)>1)then
            for k,v in pairs(data) do
                local cache = string.split(v,"|")
                num = ItemUtil.getCacheItemNumBy(tonumber(cache[2]))
                if(tonumber(num)<tonumber(cache[3]))then
                    AnimationTip.showTip(GetLocalizeStringBy("lic_1634"))
                    return 
                end
            end
        else
            local cache = string.split(data[1],"|")
            num = ItemUtil.getCacheItemNumBy(tonumber(cache[2]))
            if(tonumber(num)<tonumber(cache[3]))then
                AnimationTip.showTip(GetLocalizeStringBy("llp_465"))
                return 
            end
        end
        item:removeChildByTag(999,true)
        item:removeChildByTag(100,true)
        _isPlay = true
        _curPage = math.ceil((_curClick+1)/5)
        local afterPlay = function ( ... )
            freshDestinyPoint(_curPage,_curHeroIndex)
        end
        local openEffect = XMLSprite:create("images/redcarddestiny/tianmingbao/tianmingbao")
              openEffect:registerEndCallback(afterPlay)
              openEffect:setPosition(ccp(item:getContentSize().width*0.5*item:getScale(),item:getContentSize().height*0.5*item:getScale()))
        item:addChild(openEffect)
        RedCardDestinyController.openDestiny(_heroInfo[_curHeroIndex].hid,tonumber(_heroInfo[_curHeroIndex].destiny)+1,item,afterOpenDestinyCallBack)
    end
end

function showFlyLabel( tag )
    ------------飞字用--------------
    _dbInfo           = DB_Hero_destiny.getDataById(tag)
    local flyArray = {}
    local attStr = _dbInfo.attArr
    local attArray = string.split(attStr,",")
    for i,v in pairs(attArray) do
        local temArr = {}
        local data = string.split(v,"|")
        local attName,disNum,realNum = ItemUtil.getAtrrNameAndNum(data[1],data[2])
        temArr.txt = attName.sigleName
        temArr.num = data[2]
        table.insert(flyArray,temArr)
    end
    LevelUpUtil.showFlyText(flyArray)
    ---------------------------------
end

function afterClearDestinyCallBack( ... )
    local freshCallBack = function ( ... )
        freshDestinyPoint()
        freshTipLabel()
        freshCost()
    end
    local runningScene = CCDirector:sharedDirector():getRunningScene()
    performWithDelay(runningScene,freshCallBack,0.1)
end

function clearDestiny()
    RedCardDestinyController.resetDestiny(_heroInfo[_curHeroIndex].hid,afterClearDestinyCallBack)
end

--[[
    @des    :创建天命点
    @param  :
    @return :
--]]
function createDestinyPoint( pPage, pHeroIndex)
    local p_page = tonumber(pPage) 
    local p_heroIndex = tonumber(pHeroIndex)
    local heroData = _heroInfo[_curHeroIndex]
    require "script/model/affix/HeroAffixModel"
    local destinyDbInfo = RedCardDestinyData.getInfoByTypeAndPage(p_page)
    if(destinyDbInfo == nil)then
        return 
    end
     -- body
    local nodeSize = CCSizeMake(640,960)
    --背景node
    local bgNode = CCSprite:create()
    bgNode:setContentSize(nodeSize)

    local bgMenu = CCMenu:create()
    bgMenu:setTouchPriority(_priority-2)
    bgMenu:setAnchorPoint(ccp(0,0))
    bgMenu:setPosition(ccp(0,0))
    bgNode:addChild(bgMenu,2)
    local posInfoInDb = destinyDbInfo.cxmlName
    local bgPos = nil
    local iconPos = {}
    --清一下上次加载的cxml
    package.loaded["db/destCXml/"..posInfoInDb] = nil
    require ("db/destCXml/"..posInfoInDb)   
    for k,v in pairs(DestPosition.models.normal)do 
        local ID = tonumber(v.looks.look.armyID)
        if(ID == 100)then
            bgPos = CCPointMake(tonumber(v.x),960 - tonumber(v.y))
            _iconBackPos = bgPos
        elseif(ID == 101)then
            _effectDisPos = CCPointMake(tonumber(v.x)*g_fScaleX,(960 - tonumber(v.y))*g_fScaleX)
        elseif(ID == 1000)then
            _endPos = CCPointMake(tonumber(v.x),960 - tonumber(v.y))
        elseif(ID == 10000)then
            _beginPos = CCPointMake(tonumber(v.x),960 - tonumber(v.y))
        else
            iconPos[ID] = CCPointMake(tonumber(v.x),960 - tonumber(v.y))
            local str = ""
            local iconArray = string.sub(v.looks.look.modelURL,1,-5)
            local scaleNum = 0.8
            local strEffect = iconArray
            if(ID==5)then
                local iconArray1 = string.sub(iconArray,1,-3)
                strEffect = iconArray1..""
                scaleNum = 1
            end
            local iconEffect = nil
            if((tonumber(heroData.destiny)+1)>(ID+5*(pPage-1)))then
                str = "images/redcarddestiny/"..iconArray.."1.png"
            else
                str = "images/redcarddestiny/"..iconArray..".png"
            end
            local iconItem = CCMenuItemImage:create(str,"images/redcarddestiny/"..iconArray.."1.png")
            if((tonumber(heroData.destiny)+1)>(ID+5*(pPage-1)))then
                iconEffect = XMLSprite:create("images/redcarddestiny/"..strEffect.."/"..strEffect)
                iconEffect:setScale(scaleNum)
                iconEffect:setAnchorPoint(ccp(0.5,0.5))
                iconEffect:setPosition(ccp(iconItem:getContentSize().width*0.5,iconItem:getContentSize().height*0.5))
            end
              iconItem:setAnchorPoint(ccp(1,0))
              iconItem:setPosition(iconPos[ID])
              iconItem:registerScriptTapHandler(clickDestiny)
              if(iconEffect~=nil)then
                 iconItem:addChild(iconEffect,1)
              end
              _itemTable[ID] = iconItem
            if(ID==5)then
                --添加常在提示
                local specialSprite = CCSprite:create("images/redcarddestiny/special.png")
                      specialSprite:setAnchorPoint(ccp(0.5,0))
                      specialSprite:setPosition(ccp(iconItem:getContentSize().width*0.5,iconItem:getContentSize().height))
                iconItem:addChild(specialSprite,1,100)
                local effectSprite = XMLSprite:create("images/redcarddestiny/tmwufangbiankuang/tmwufangbiankuang")
                effectSprite:setAnchorPoint(ccp(0.5,0.5))
                effectSprite:setPosition(ccp(specialSprite:getContentSize().width*0.5,specialSprite:getContentSize().height*0.5))
                specialSprite:addChild(effectSprite,1)
                local str = RedCardDestinyData.getCurSpecialName((ID+5*(pPage-1)),_heroInfo[_curHeroIndex])
                local awakeData = RedCardDestinyData.getCurSpecialAwake((ID+5*(pPage-1)),_heroInfo[_curHeroIndex])
                if(string.len(str)~=0)then
                    local label = CCLabelTTF:create(str,g_sFontName,20)
                          label:setAnchorPoint(ccp(0.5,0.5))
                          label:setPosition(ccp(specialSprite:getContentSize().width*0.5,specialSprite:getContentSize().height*0.5))
                    specialSprite:addChild(label)
                elseif(table.count(awakeData)>0)then
                    local label = CCLabelTTF:create( GetLocalizeStringBy("lic_1329"),g_sFontName,20)
                          label:setAnchorPoint(ccp(1,0.5))
                          label:setPosition(ccp(specialSprite:getContentSize().width*0.47,specialSprite:getContentSize().height*0.5))
                    specialSprite:addChild(label)
                    local labe2 = CCLabelTTF:create(awakeData.name,g_sFontName,20)
                          labe2:setColor(ccc3(255,0,0))
                          labe2:setAnchorPoint(ccp(0,0))
                          labe2:setPosition(ccp(label:getContentSize().width,0))
                    label:addChild(labe2)
                else
                    _dbInfo = DB_Hero_destiny.getDataById((ID+5*(pPage-1)))
                    local attStr = _dbInfo.attArr
                    local attArray = string.split(attStr,"|")
                    local attName,disNum,realNum = ItemUtil.getAtrrNameAndNum(attArray[1],attArray[2])
                    local isOne = isOneLine(tonumber(attArray[1]))
                    if(isOne)then
                        local labelName = CCLabelTTF:create(attName.sigleName.."+"..disNum,g_sFontName,20)
                              labelName:setAnchorPoint(ccp(0.5,0.5))
                              labelName:setPosition(ccp(specialSprite:getContentSize().width*0.5,specialSprite:getContentSize().height*0.5))
                              specialSprite:addChild(labelName)
                    else
                        local labelName = CCLabelTTF:create(attName.sigleName,g_sFontName,20)
                              labelName:setAnchorPoint(ccp(0.5,0))
                              labelName:setPosition(ccp(specialSprite:getContentSize().width*0.5,specialSprite:getContentSize().height*0.5))
                        local labelNum = CCLabelTTF:create("+"..disNum,g_sFontName,20)
                              labelNum:setAnchorPoint(ccp(0.5,1))
                              labelNum:setPosition(ccp(specialSprite:getContentSize().width*0.5,specialSprite:getContentSize().height*0.5))
                        specialSprite:addChild(labelName)
                        specialSprite:addChild(labelNum)
                    end
                end
            end
            local destinyId = (p_page-1)*5+ID
            if(destinyId==tonumber(_heroInfo[_curHeroIndex].destiny)+1)then
                --添加当前应当点亮特效
                local effectSprite = XMLSprite:create("images/redcarddestiny/dianliangtishi/dianliangtishi")
                effectSprite:setAnchorPoint(ccp(0.5,0.5))
                effectSprite:setPosition(ccp(iconItem:getContentSize().width*0.5,iconItem:getContentSize().height*0.5))
                iconItem:addChild(effectSprite,1,999)
                local specialSprite = CCSprite:create("images/redcarddestiny/special.png")
                      specialSprite:setAnchorPoint(ccp(0.5,0))
                      specialSprite:setPosition(ccp(iconItem:getContentSize().width*0.5,iconItem:getContentSize().height))
                iconItem:addChild(specialSprite,1,100)
                local str = RedCardDestinyData.getCurSpecialName((ID+5*(pPage-1)),_heroInfo[_curHeroIndex])
                local awakeData = RedCardDestinyData.getCurSpecialAwake((ID+5*(pPage-1)),_heroInfo[_curHeroIndex])
                if(string.len(str)~=0)then
                    local label = CCLabelTTF:create(str,g_sFontName,20)
                          label:setAnchorPoint(ccp(0.5,0.5))
                          label:setPosition(ccp(specialSprite:getContentSize().width*0.5,specialSprite:getContentSize().height*0.5))
                    specialSprite:addChild(label)
                elseif(table.count(awakeData)>0)then
                    local label = CCLabelTTF:create( GetLocalizeStringBy("lic_1329"),g_sFontName,20)
                          label:setAnchorPoint(ccp(1,0.5))
                          label:setPosition(ccp(specialSprite:getContentSize().width*0.47,specialSprite:getContentSize().height*0.5))
                    specialSprite:addChild(label)
                    local labe2 = CCLabelTTF:create(awakeData.name,g_sFontName,20)
                          labe2:setColor(ccc3(255,0,0))
                          labe2:setAnchorPoint(ccp(0,0))
                          labe2:setPosition(ccp(label:getContentSize().width,0))
                    label:addChild(labe2)
                else
                    _dbInfo = DB_Hero_destiny.getDataById((ID+5*(pPage-1)))
                    local attStr = _dbInfo.attArr
                    local attArray = string.split(attStr,"|")
                    local attName,disNum,realNum = ItemUtil.getAtrrNameAndNum(attArray[1],attArray[2])
                    local isOne = isOneLine(tonumber(attArray[1]))
                    if(isOne)then
                        local labelName = CCLabelTTF:create(attName.sigleName.."+"..disNum,g_sFontName,20)
                              labelName:setAnchorPoint(ccp(0.5,0.5))
                              labelName:setPosition(ccp(specialSprite:getContentSize().width*0.5,specialSprite:getContentSize().height*0.5))
                              specialSprite:addChild(labelName)
                    else
                        local labelName = CCLabelTTF:create(attName.sigleName,g_sFontName,20)
                              labelName:setAnchorPoint(ccp(0.5,0))
                              labelName:setPosition(ccp(specialSprite:getContentSize().width*0.5,specialSprite:getContentSize().height*0.5))
                        local labelNum = CCLabelTTF:create("+"..disNum,g_sFontName,20)
                              labelNum:setAnchorPoint(ccp(0.5,1))
                              labelNum:setPosition(ccp(specialSprite:getContentSize().width*0.5,specialSprite:getContentSize().height*0.5))
                        specialSprite:addChild(labelName)
                        specialSprite:addChild(labelNum)
                    end
                end
            end
            bgMenu:addChild(iconItem,1,(p_page-1)*5+ID)
        end
    end
    local nextDestinyDbInfo = RedCardDestinyData.getInfoByTypeAndPage(p_page+1)
    if(nextDestinyDbInfo==nil)then
    else
        local nextPosInfoInDb = nextDestinyDbInfo.cxmlName
        package.loaded["db/destCXml/"..posInfoInDb] = nil
        package.loaded["db/destCXml/"..nextPosInfoInDb] = nil
        require ("db/destCXml/"..nextPosInfoInDb)   
        for k,v in pairs(DestPosition.models.normal)do 
            local ID = tonumber(v.looks.look.armyID)
            if(ID == 100)then
                bgPos = CCPointMake(tonumber(v.x),960 - tonumber(v.y))
            elseif(ID == 101)then
                _effectDisPos = CCPointMake(tonumber(v.x)*g_fScaleX,(960 - tonumber(v.y))*g_fScaleX)
            elseif(ID == 1000)then
                _endPos = CCPointMake(tonumber(v.x),960 - tonumber(v.y))
            elseif(ID == 10000)then
                _beginPos = CCPointMake(tonumber(v.x),960 - tonumber(v.y))
            else
                iconPos[ID+5] = CCPointMake(614,960 - 444)
                local iconArray = string.sub(v.looks.look.modelURL,1,-5)
                local str = "images/redcarddestiny/"..iconArray..".png"
                local iconItem = CCMenuItemImage:create(str,"images/redcarddestiny/"..iconArray.."1.png")
                      iconItem:setAnchorPoint(ccp(1,0))
                      -- iconItem:setScale(g_fElementScaleRatio)
                      iconItem:setPosition(ccp(iconPos[ID+5].x,iconPos[ID+5].y))
                      iconItem:registerScriptTapHandler(clickDestiny)
                      _itemTable[ID+5] = iconItem
                      iconItem:setVisible(false)
                      if((ID+5)==6)then
                        _finalItem = iconItem
                      end
                if(ID==5)then
                    --添加常在提示
                    local specialSprite = CCSprite:create("images/redcarddestiny/special.png")
                          specialSprite:setAnchorPoint(ccp(0.5,0))
                          specialSprite:setPosition(ccp(iconItem:getContentSize().width*0.5,iconItem:getContentSize().height))
                    iconItem:addChild(specialSprite,1,100)
                end
                local destinyId = (p_page-1)*5+ID
                if(destinyId==tonumber(_heroInfo[_curHeroIndex].destiny)+1)then
                    --添加当前应当点亮特效
                end
                bgMenu:addChild(iconItem,1,(p_page)*5+ID)
            end
        end
    end
    _posTable = iconPos
    table.insert(_posTable,ccp(76,iconPos[1].y))
    local iconBg = CCSprite:create("images/redcarddestiny/"..destinyDbInfo.connection_graph)
          iconBg:setAnchorPoint(ccp(1,0))
          iconBg:setPosition(bgPos)
    bgNode:addChild(iconBg)
    bgNode:setScale(g_fScaleX)
    _bgLayer:addChild(bgNode,112)
    local iconBgBack = CCSprite:create("images/redcarddestiny/xian1back.png")
          iconBgBack:setAnchorPoint(ccp(1,0))
          iconBgBack:setPosition(bgPos)
          iconBgBack:setScale(g_fScaleX)
    _bgLayer:addChild(iconBgBack,1)
    bgNode:setTag(9999)
    _isPlay = false
end

function createLabelFunction( ... )
    if(_bgLayer:getChildByTag(1))then
        _bgLayer:removeChildByTag(1,true)
    end
    if((tonumber(_heroInfo[_curHeroIndex].destiny)+1)>table.count(DB_Hero_destiny.Hero_destiny))then
        return 
    end
    local labelSprite = CCSprite:create()

    local label2 = CCLabelTTF:create(GetLocalizeStringBy("llp_458"),g_sFontPangWa,25)
          label2:setScale(g_fElementScaleRatio)
          label2:setAnchorPoint(ccp(0,0))
          label2:setPosition(ccp(0,0))
    labelSprite:addChild(label2)

    local specialCount = RedCardDestinyData.getToSpecialDestinyCount(_heroInfo[_curHeroIndex].destiny)
    _destinyCountLabel = CCLabelTTF:create(specialCount,g_sFontPangWa,25)
    _destinyCountLabel:setScale(g_fElementScaleRatio)
    _destinyCountLabel:setColor(ccc3(0,255,0))
    _destinyCountLabel:setAnchorPoint(ccp(0,0))
    _destinyCountLabel:setPosition(ccp(label2:getContentSize().width*g_fElementScaleRatio,0))
    labelSprite:addChild(_destinyCountLabel)

    local label1 = CCLabelTTF:create(GetLocalizeStringBy("llp_459"),g_sFontPangWa,25)
          label1:setScale(g_fElementScaleRatio)
          label1:setAnchorPoint(ccp(0,0))
          label1:setPosition(ccp(label2:getContentSize().width*g_fElementScaleRatio+_destinyCountLabel:getContentSize().width*g_fElementScaleRatio,0))
    labelSprite:addChild(label1,100,1)

    local str = RedCardDestinyData.getSpecialName(_heroInfo[_curHeroIndex].destiny,_heroInfo[_curHeroIndex])
    _specialTalentLabel = CCLabelTTF:create(str,g_sFontPangWa,25)
    _specialTalentLabel:setScale(g_fElementScaleRatio)
	if(tonumber(_heroInfo[_curHeroIndex].htid)>=80000)then --天命判断武将ID获取颜色在界面上显示【真和圣】
                _specialTalentLabel:setColor(ccc3(255,255,0))
				else
				_specialTalentLabel:setColor(ccc3(255,0,0))
            end
    --_specialTalentLabel:setColor(ccc3(255,0,0))
    _specialTalentLabel:setAnchorPoint(ccp(0,0))
    _specialTalentLabel:setPosition(ccp(label1:getPositionX()+label1:getContentSize().width*g_fElementScaleRatio,0))
    labelSprite:addChild(_specialTalentLabel)

    labelSprite:setContentSize(CCSizeMake(label1:getContentSize().width*g_fElementScaleRatio+_specialTalentLabel:getContentSize().width*g_fElementScaleRatio+label2:getContentSize().width*g_fElementScaleRatio,
        label1:getContentSize().height))
    labelSprite:setAnchorPoint(ccp(0.5,0))
    labelSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bottomBg:getContentSize().height*g_fScaleX+labelSprite:getContentSize().height*0.6))
    _bgLayer:addChild(labelSprite,100,1)
end

function createCostFunction( ... )
    _bottomBg= CCScale9Sprite:create("images/common/bg/9s_1.png")
    _bottomBg:setContentSize(CCSizeMake(581,144))
    _bottomBg:setScale(g_fScaleX)
    _bottomBg:setPosition(_bgLayer:getContentSize().width/2, 0)
    _bottomBg:setAnchorPoint(ccp(0.5,0))
    _bgLayer:addChild(_bottomBg,11,3)
    local costLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_460"),g_sFontName,25)
          costLabel:setAnchorPoint(ccp(1,0.5))
          -- costLabel:setScale(g_fElementScaleRatio)
          costLabel:setPosition(ccp(_bottomBg:getContentSize().width*0.3,_bottomBg:getContentSize().height*0.5))
    _bottomBg:addChild(costLabel,100,3)
    local costData = RedCardDestinyData.getCostData(tonumber(_heroInfo[_curHeroIndex].destiny),_heroInfo[_curHeroIndex],true)
    local data = string.split(costData,",")
    if(table.count(data)>1)then
        for k,v in pairs(data)do
            local arry = string.split(v,"|")
            local rewardData = ItemUtil.getItemsDataByStr(v)
            local sprite = ItemUtil.createGoodsIcon(rewardData[1],-1002,nil,-1002,nil,nil,nil,nil,false)
                  sprite:setAnchorPoint(ccp(0,0.5))
                  sprite:setPosition(ccp(costLabel:getContentSize().width+sprite:getContentSize().width*(k-1)+15*(k-1),costLabel:getContentSize().height*0.8))
            costLabel:addChild(sprite,100,3)
            if(tonumber(arry[3])>1)then
                local num = ItemUtil.getCacheItemNumBy(tonumber(arry[2]))
                local numLabel = CCRenderLabel:create(num.."/"..arry[3],g_sFontName,21,2,ccc3(0x00,0x00,0x00),type_stroke)
                      numLabel:setAnchorPoint(ccp(0.5,0))
                      numLabel:setPosition(ccp(sprite:getContentSize().width*0.5,0))
                sprite:addChild(numLabel)
                
                if(num<tonumber(arry[3]))then
                    numLabel:setColor(ccc3(255,0,0))
                else
                    numLabel:setColor(ccc3(0,255,0))
                end
            end
        end
    else
        local rewardData = ItemUtil.getItemsDataByStr(costData)
        local sprite = ItemUtil.createGoodsIcon(rewardData[1],-1002,nil,-1002,nil,nil,nil,nil,false)
              sprite:setAnchorPoint(ccp(0,0.5))
              sprite:setPosition(ccp(costLabel:getContentSize().width,costLabel:getContentSize().height*0.5))
        costLabel:addChild(sprite,100,3)
    end
end

--[[
    @des    :创建底部文字已经点亮消耗
    @param  :
    @return :
--]]
function createBottom( ... )
    if((tonumber(_heroInfo[_curHeroIndex].destiny)+1)>table.count(DB_Hero_destiny.Hero_destiny))then
        local label1 = CCLabelTTF:create(GetLocalizeStringBy("llp_461"),g_sFontPangWa,25)
              label1:setScale(g_fElementScaleRatio)
              label1:setAnchorPoint(ccp(0.5,0))
              label1:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.2))
        _bgLayer:addChild(label1,100,1)
    else
        if(_isSelf)then
            createCostFunction()
	        createLabelFunction()
       end
    end
end

--[[
    @des    :刷新天命点
    @param  :
    @return :
--]]
function freshDestinyPoint( pPage )
    _bgLayer:removeChildByTag(9999,true)
	createDestinyPoint(pPage,_curHeroIndex)
end

--[[
    @des    :刷新提示文字
    @param  :
    @return :
--]]
function freshTipLabel( ... )
    if(_isSelf)then
	   createLabelFunction()
    end
end

--[[
    @des    :刷新点亮消耗
    @param  :
    @return :
--]]
function freshCost( ... )
    if(_isSelf)then
        _bgLayer:removeChildByTag(3,true)
	   createCostFunction()
    end
end