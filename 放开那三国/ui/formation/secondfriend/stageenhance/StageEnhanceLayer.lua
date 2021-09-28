-- FileName : StageEnhanceLayer.lua
-- Author   : YangRui
-- Date     : 2015-12-07
-- Purpose  : 

module("StageEnhanceLayer", package.seeall)

require "script/ui/formation/secondfriend/stageenhance/StageEnhanceData"
require "script/ui/formation/secondfriend/stageenhance/StageEnhanceController"
require "script/ui/formation/secondfriend/stageenhance/StageEnhanceService"
require "script/libs/LuaCCLabel"
require "script/ui/tip/AnimationTip"

local _bgLayer             = nil
local _extraAffixTableview = nil
local _lvLabel             = nil
local _curLvPanelBg        = nil
local _nextLvPanelBg       = nil
local _stage               = nil  -- 宝座
local _markSp              = nil  -- 助战位类型
local _curLvAffixLabel     = nil  -- 创建本级属性值详情Label
local _nextLvAffixLabel    = nil  -- 创建下一级属性值详情Label
local _lvBg                = nil  -- 助战位等级背景
local _curAttrValLabel     = nil  -- 本级属性Sp
local _nextLvAttrLabel     = nil  -- 下级属性Sp
local _enhanceBtn          = nil  -- 强化按钮
local _costBg              = nil  -- 消耗背景

local _index               = nil
local _curLv               = nil
local _touchPriority       = -200
local _tipNum              = nil
local _affixPanelBgWidth   = nil
local ksCostLabelTag       = 100

--[[
 	@des 	: init
 	@param 	: 
 	@return : 
 --]]
function init( ... )
	_bgLayer             = nil
	_extraAffixTableview = nil
	_lvLabel             = nil
	_curLvPanelBg        = nil
	_nextLvPanelBg       = nil
	_stage               = nil  -- 宝座
	_markSp              = nil  -- 助战位类型
	_curLvAffixLabel     = nil  -- 创建本级属性值详情Label
	_nextLvAffixLabel    = nil  -- 创建下一级属性值详情Label
	_lvBg                = nil  -- 助战位等级背景
	_curAttrValLabel     = nil  -- 本级属性Sp
	_nextLvAttrLabel     = nil  -- 下级属性Sp
	_enhanceBtn          = nil  -- 强化按钮
	_costBg              = nil  -- 消耗背景

	_index               = nil
	_curLv               = nil
	_touchPriority       = -200
	_tipNum              = nil
	_affixPanelBgWidth 	 = nil
end

--[[
    @des    : 处理touches事件
    @para   : 
    @return : 
 --]]
function onTouchesHandler( eventType, x, y )
    return true
end

--[[
	@des 	: 回调onEnter和onExit事件
	@param 	: 
	@return : 
--]]
function onNodeEvent( event )
	if (event == "enter") then
    	_bgLayer:registerScriptTouchHandler(onTouchesHandler,false,_touchPriority,true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
	end
end

--[[
	@des 	: 关闭方法
	@param 	: 
	@return : 
--]]
function closeSelfCallback( ... )
	-- audio effect
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
    if _bgLayer ~= nil then
        _bgLayer:removeFromParentAndCleanup(true)
        _bgLayer = nil
    end
    -- 显示助战位信息
    SecondFriendLayer.showStageDetail()
end

--[[
	@des 	: 刷新属性 tableview
	@param 	: 
	@return : 
--]]
function refreshExtraAffixTableview( ... )
	_extraAffixTableview:reloadData()
end

--[[
	@des 	: 创建单条额外属性Label
	@param 	: 
	@return : 
--]]
function createSingleExtraAffixLabel( pData )
	local needLv,affixId,affixUpVal = StageEnhanceData.handleSingleExtraAffix(pData)
	local affixInfo,showNum,realNum = ItemUtil.getAtrrNameAndNum(affixId,affixUpVal)
	local showColor = nil
	if _curLv >= needLv then
		showColor = ccc3(0x00,0xff,0x18)
	else
		showColor = ccc3(0xbe,0xbe,0xbe)
	end
    local richInfo = {
        linespace = 2, -- 行间距
        alignment = 1, -- 对齐方式  1 左对齐，2 居中， 3右对齐
        lineAlignment = 2, -- 当前行在竖直方向上的对齐方式 1，下对齐， 2，居中， 3，上对齐
        labelDefaultFont = g_sFontName,
        labelDefaultColor = showColor,
        labelDefaultSize = 18,
        defaultType = "CCRenderLabel",
        elements =
        {
            {
                newLine = false,
                text = GetLocalizeStringBy("yr_7005",needLv),
                strokeSize = 1,
                strokeColor = ccc3(0x0,0x0,0x0),
                renderType = 2,  -- 1 描边， 2 投影
            },
            {
                newLine = false,
                text = GetLocalizeStringBy("yr_7006"),
                strokeSize = 1,
                strokeColor = ccc3(0x0,0x0,0x0),
                renderType = 2,  -- 1 描边， 2 投影
            },
            {
                newLine = false,
                text = affixInfo.sigleName .. "+" .. showNum,
                strokeSize = 1,
                strokeColor = ccc3(0x0,0x0,0x0),
                renderType = 2,  -- 1 描边， 2 投影
            },
        }
    }
    local SingleExtraAffixLabel = LuaCCLabel.createRichLabel(richInfo)
    return SingleExtraAffixLabel
end

--[[
	@des 	: 创建属性 cell
	@param 	: 
	@return : 
--]]
function createExtraAffixCell( pData, pIndex )
	local cell = CCTableViewCell:create()
	cell:setContentSize(CCSizeMake(_affixPanelBgWidth,28))
	local affixLabel = createSingleExtraAffixLabel(pData)
	affixLabel:setAnchorPoint(ccp(0,0.5))
	affixLabel:setPosition(ccp(80,cell:getContentSize().height/2))
	cell:addChild(affixLabel)

	return cell
end

--[[
	@des 	: 创建属性加成 tableview
	@param 	: 
	@return : 
--]]
function createExtraAffixTableView( ... )
	local tableViewSize = CCSizeMake(_affixPanelBgWidth,60)
	local affixData = StageEnhanceData.handleExtraAffix(_index)
	local luaHandler = LuaEventHandler:create(function(fn,t,a1,a2)
		local ret
		if fn == "cellSize" then
			ret = CCSizeMake(_affixPanelBgWidth,24)
		elseif fn == "cellAtIndex" then
			a2 = createExtraAffixCell(affixData[a1+1],a1+1)
			ret = a2
		elseif fn == "numberOfCells" then
			ret = #affixData
		elseif fn == "cellTouched" then
		end
		return ret
	end)
	local tableView = LuaTableView:createWithHandler(luaHandler,tableViewSize)
	tableView:setBounceable(true)
	tableView:setTouchPriority(_touchPriority-10)
	tableView:setDirection(kCCScrollViewDirectionVertical)
	tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	
	return tableView
end

--[[
	@des 	: 创建 助战位成就加成
	@param 	: 
	@return : 
--]]
function createAttrPanel( ... )
	local affixPanelBg = CCScale9Sprite:create("images/secondfriend/top_bg.png",CCRectMake(0,0,637,152),CCRectMake(32,26,570,80))
	affixPanelBg:setAnchorPoint(ccp(0.5,1))
	affixPanelBg:setPosition(ccp(_bgLayer:getContentSize().width/2,_bgLayer:getContentSize().height))
	affixPanelBg:setContentSize(CCSizeMake(480,210))
	affixPanelBg:setScale(g_fScaleX)
	_bgLayer:addChild(affixPanelBg)
	_affixPanelBgWidth = affixPanelBg:getContentSize().width
	-- 创建 助战位成就加成 title
	local titleBorder = CCSprite:create("images/secondfriend/enhance/border.png")
	titleBorder:setAnchorPoint(ccp(0.5,1))
	titleBorder:setPosition(ccp(affixPanelBg:getContentSize().width/2,affixPanelBg:getContentSize().height-24))
	affixPanelBg:addChild(titleBorder)
	local titleSp = CCSprite:create("images/secondfriend/enhance/zhuzhanwei.png")
	titleSp:setAnchorPoint(ccp(0.5,0.5))
	titleSp:setPosition(ccpsprite(0.5,0.5,titleBorder))
	titleBorder:addChild(titleSp)
	local extraTip = CCRenderLabel:create(GetLocalizeStringBy("yr_7010"),g_sFontPangWa,18,1,ccc3(0x00,0x00,0x00),type_shadow)
	extraTip:setAnchorPoint(ccp(0.5,1))
	extraTip:setPosition(ccp(titleBorder:getContentSize().width/2,-5))
	extraTip:setColor(ccc3(0xff,0xff,0xff))
	titleBorder:addChild(extraTip)
	-- 创建属性加成 tableview
	_extraAffixTableview = createExtraAffixTableView()
	_extraAffixTableview:setAnchorPoint(ccp(0,0))
	_extraAffixTableview:setPosition(ccpsprite(0,0.2,affixPanelBg))
	affixPanelBg:addChild(_extraAffixTableview)
	-- 向下滑动的提示
	local downArrowTip = CCSprite:create("images/common/arrow_down_h.png")
	downArrowTip:setAnchorPoint(ccp(0.5,1))
	downArrowTip:setPosition(ccp(affixPanelBg:getContentSize().width/2,50))
	affixPanelBg:addChild(downArrowTip)
	-- 提示的动画
	local arrAction = CCArray:create()
	arrAction:addObject(CCFadeOut:create(1))
	arrAction:addObject(CCFadeIn:create(1))
	local seq = CCSequence:create(arrAction)
	local action = CCRepeatForever:create(seq)
	downArrowTip:runAction(action)
end

--[[
	@des 	: 播放强化特效
	@param 	: 
	@return : 
--]]
function playEnhanceEffect( ... )
	local enhanceEffect = XMLSprite:create("images/secondfriend/enhance/HZjinhua/HZjinhua")
	enhanceEffect:setPosition(ccp(_stage:getContentSize().width/2,_stage:getContentSize().height*0.9))
	enhanceEffect:setReplayTimes(1,true)
	_stage:addChild(enhanceEffect)
end

--[[
	@des 	: 创建助战位
	@param 	: 
	@return : 
--]]
function createStage( ... )
	-- 创建宝座
	_stage = CCSprite:create("images/olympic/kingChair.png")
	_stage:setAnchorPoint(ccp(0.5,0))
	_stage:setPosition(ccp(_bgLayer:getContentSize().width/2,_bgLayer:getContentSize().height/2-120*g_fScaleY))
	_stage:setScale(g_fScaleY)
	_bgLayer:addChild(_stage)
	-- 创建宝座上的特效
	local curPosData = SecondFriendData.getDBdataByIndex(_index)
	local animSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/secondfriend/effect/" .. curPosData.methodEffect ), -1,CCString:create(""))
	animSprite:setAnchorPoint(ccp(0.5,0.5))
	animSprite:setPosition(ccp(_stage:getContentSize().width*0.48,_stage:getContentSize().height*0.9))
	_stage:addChild(animSprite,10)
	animSprite:setScale(0.7)
	-- 助战位类型
	_markSp = CCSprite:create("images/secondfriend/mark/" .. curPosData.picture)
	_markSp:setAnchorPoint(ccp(0.5,0))
	_markSp:setPosition(ccp(_stage:getContentSize().width/2,_stage:getContentSize().height+_markSp:getContentSize().height/3))
	_markSp:setScale(0.8)
	_stage:addChild(_markSp)
	-- 助战位类型 特效
	-- 上下浮动
	local arrAction = CCArray:create()
	arrAction:addObject(CCMoveBy:create(1,ccp(0,-20)))
	arrAction:addObject(CCMoveBy:create(1,ccp(0,20)))
	local seq = CCSequence:create(arrAction)
	local foreverAct = CCRepeatForever:create(seq)
	_markSp:runAction(foreverAct)
	-- 创建宝座等级
	_lvBg = CCScale9Sprite:create("images/common/bg/bg_9s_2.png")
	_lvBg:setAnchorPoint(ccp(0.5,0.5))
	_lvBg:setPosition(ccp(_stage:getContentSize().width/2,_stage:getContentSize().height/3))
	_lvBg:setContentSize(CCSizeMake(240,36))
	_lvBg:setVisible(false)
	_stage:addChild(_lvBg)
	local offsetX = 40
	_lvLabel = CCRenderLabel:create(_curLv,g_sFontPangWa,24,1,ccc3(0x00,0x00,0x00),type_shadow)
	_lvLabel:setAnchorPoint(ccp(1,0.5))
	_lvLabel:setPosition(ccp(_lvBg:getContentSize().width/2-offsetX,_lvBg:getContentSize().height/2))
	_lvLabel:setColor(ccc3(0xff,0xf6,0x00))
	_lvBg:addChild(_lvLabel,10)
	local lvTipLabel = CCRenderLabel:create(GetLocalizeStringBy("yr_7007"),g_sFontPangWa,24,1,ccc3(0x00,0x00,0x00),type_shadow)
	lvTipLabel:setAnchorPoint(ccp(0,0.5))
	lvTipLabel:setPosition(ccp(_lvBg:getContentSize().width/2-offsetX,_lvBg:getContentSize().height/2))
	lvTipLabel:setColor(ccc3(0xe4,0x00,0xff))
	_lvBg:addChild(lvTipLabel)
	if _curLv > 0 then
		_lvBg:setVisible(true)
	end
end

--[[
	@des 	: 刷新UI
	@param 	: 
	@return : 
--]]
function updateUI( ... )
	-- 修改当前等级
	_curLv = StageEnhanceData.getCurStageLv(_index)
	-- 播放特效
	playEnhanceEffect()
	-- 刷新tableview
	refreshExtraAffixTableview()
	-- 刷新当前拥有的物品数量
	refreshCurHaceItemNum()
	-- 刷新当前等级
	refreshStageLv()
	-- 刷新属性值
	refreshAffixLabel()
	-- 刷新强化消耗
	refreshEnhanceNextLvCostLabel()
end

--[[
	@des 	: 强化按钮回调
	@param 	: 
	@return : 
--]]
function enhanceBtnCallback( ... )
	-- 音效
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- 网络请求
	StageEnhanceController.strengthAttrExtra(_curLv,_index)
end

--[[
	@des 	: 刷新当前拥有的物品数量
	@param 	: 
	@return : 
--]]
function refreshCurHaceItemNum( ... )
	local haveResNum = StageEnhanceData.getNeedItemNum()
	print("===|haveResNum|===",haveResNum)
    _tipNum:setString(GetLocalizeStringBy("yr_7004",haveResNum))
end

--[[
	@des 	: 刷新等级
	@param 	: 
	@return : 
--]]
function refreshStageLv( ... )
	if _curLv > 0 then
		_lvLabel:setString(_curLv)
		if _curLv == 1 then
			_lvBg:setVisible(true)
		end
	end
end

--[[
	@des 	: 刷新
	@param 	: 
	@return : 
--]]
function refreshAffixLabel( ... )
	if _curLvAffixLabel ~= nil then
		local curAffixTab = StageEnhanceData.calcCurAffix(_index,_curLv)
		_curLvAffixLabel:removeFromParentAndCleanup(true)
		_curLvAffixLabel = nil
		_curLvAffixLabel = createAffixLabel(curAffixTab)
		_curLvAffixLabel:setAnchorPoint(ccp(0.5,1))
		_curLvAffixLabel:setPosition(ccp(_curAttrValLabel:getPositionX(),_curAttrValLabel:getPositionY()-_curAttrValLabel:getContentSize().height-10))
		_curLvPanelBg:addChild(_curLvAffixLabel)
	else
		print("not nil")
	end
	if _nextLvAffixLabel ~= nil then
		local nextAffixTab = StageEnhanceData.calcCurAffix(_index,_curLv+1)
		_nextLvAffixLabel:removeFromParentAndCleanup(true)
		_nextLvAffixLabel = nil
		local maxLv =  StageEnhanceData.getEnhanceMaxLv(_index)
		if _curLv >= maxLv then
			_nextLvAttrLabel:removeFromParentAndCleanup(true)
			_nextLvAttrLabel = nil
			local waitTip = CCRenderLabel:create(GetLocalizeStringBy("yr_7013"),g_sFontPangWa,20,1,ccc3(0x00,0x00,0x00),type_shadow)
			waitTip:setAnchorPoint(ccp(0.5,1))
			waitTip:setPosition(ccp(_nextLvPanelBg:getContentSize().width/4,_nextLvPanelBg:getContentSize().height*0.9))
			waitTip:setColor(ccc3(0xff,0xf6,0x00))
			_nextLvPanelBg:addChild(waitTip)
			return
		end
		_nextLvAffixLabel = createAffixLabel(nextAffixTab)
		_nextLvAffixLabel:setAnchorPoint(ccp(0.5,1))
		_nextLvAffixLabel:setPosition(ccp(_nextLvAttrLabel:getPositionX(),_nextLvAttrLabel:getPositionY()-_nextLvAttrLabel:getContentSize().height-10))
		_nextLvPanelBg:addChild(_nextLvAffixLabel)
	else
		print("not nil")
	end
end

--[[
	@des 	: 创建强化到下一级所需消耗
	@param 	: 
	@return : 
--]]
function refreshEnhanceNextLvCostLabel( ... )
	-- 判断强化按钮子节点
	local enhanceBtnLabel = _costBg:getChildByTag(ksCostLabelTag)
	if enhanceBtnLabel ~= nil then
		enhanceBtnLabel:removeFromParentAndCleanup(false)
		enhanceBtnLabel = nil
	end
	local maxLv =  StageEnhanceData.getEnhanceMaxLv(_index)
	if _curLv >= maxLv then
		local maxTip = CCRenderLabel:create(GetLocalizeStringBy("yr_7012"),g_sFontPangWa,24,1,ccc3(0x00,0x00,0x00),type_shadow)
	    maxTip:setAnchorPoint(ccp(0.5,0.5))
	    maxTip:setPosition(ccp(_costBg:getContentSize().width/2,_costBg:getContentSize().height/2))
	    _costBg:addChild(maxTip)
		return
	end
	local silverCost,itemCostId,itemCostNum = StageEnhanceData.getNextLvEnhanceCost(_curLv+1)
    print("===|_curLv,silverCost,itemCostNum|===",_curLv,silverCost,itemCostNum)
	-- 按钮上提示
	require "script/libs/LuaCCLabel"
    local enhanceBtnInfo = {
        linespace = 2, -- 行间距
        alignment = 1, -- 对齐方式  1 左对齐，2 居中， 3右对齐
        lineAlignment = 2, -- 当前行在竖直方向上的对齐方式 1，下对齐， 2，居中， 3，上对齐
        labelDefaultFont = g_sFontName,
        labelDefaultColor = ccc3(0xff,0xff,0xff),
        labelDefaultSize = 20,
        defaultType = "CCLabelTTF",
        elements =
        {
            {
                newLine = false,
                text = GetLocalizeStringBy("key_1771"),
            },
            {
                type = "CCSprite",
                newLine = false,
                image = "images/common/coin.png",
            },
            {
                newLine = false,
                text = silverCost,
                color = ccc3(0x00,0xff,0x18),
            },
            {
                newLine = true,
                text = GetLocalizeStringBy("key_1771"),
            },
            {
                type = "CCSprite",
                newLine = false,
                image = "images/common/secfriends_token_small.png",
            },
            {
                newLine = false,
                text = itemCostNum,
                color = ccc3(0x00,0xff,0x18),
            },
        }
    }
    enhanceBtnLabel = LuaCCLabel.createRichLabel(enhanceBtnInfo)
    enhanceBtnLabel:setAnchorPoint(ccp(0.5,0.5))
    enhanceBtnLabel:setPosition(ccp(_costBg:getContentSize().width/2,_costBg:getContentSize().height/2))
    _costBg:addChild(enhanceBtnLabel,1,ksCostLabelTag)
end

--[[
	@des 	: 创建属性值Label
	@param 	: 
	@return : 
--]]
function createAffixLabel( pData )
	local affixText = {
        linespace = 2, -- 行间距
        alignment = 1, -- 对齐方式  1 左对齐，2 居中， 3右对齐
        lineAlignment = 2, -- 当前行在竖直方向上的对齐方式 1，下对齐， 2，居中， 3，上对齐
        labelDefaultFont = g_sFontName,
        labelDefaultColor = ccc3(0xff,0xff,0xff),
        labelDefaultSize = 20,
        defaultType = "CCRenderLabel",
        elements = {
        	{
	            newLine = false,
	            text = "",
	            renderType = 1,  -- 1 描边， 2 投影
        	},
        },
    }
	for attrId,attrVal in pairs(pData) do
		local affixInfo,showNum,realNum = ItemUtil.getAtrrNameAndNum(attrId,attrVal)
		local afffixName = {
            newLine = true,
            text = affixInfo.sigleName,
            renderType = 1,  -- 1 描边， 2 投影
        }
        local afffixVal = {
            newLine = false,
            text = "+" .. showNum/100 .. "%",
            color = ccc3(0x00,0xff,0x18),
            renderType = 1,  -- 1 描边， 2 投影
        }
        table.insert(affixText.elements,afffixName)
        table.insert(affixText.elements,afffixVal)
	end
	local affixLabel = LuaCCLabel.createRichLabel(affixText)
	return affixLabel
end

--[[
	@des 	: 创建助战位属性强化信息
	@param 	: 
	@return : 
--]]
function createEnhancePanel( ... )
	-- 当前级属性BG
	_curLvPanelBg = CCScale9Sprite:create("images/common/bg/9s_1.png")
	_curLvPanelBg:setAnchorPoint(ccp(0.5,0.5))
	_curLvPanelBg:setPosition(ccp(0,_bgLayer:getContentSize().height/2))
	_curLvPanelBg:setContentSize(CCSizeMake(400,150))
	_curLvPanelBg:setScale(g_fScaleX)
	_bgLayer:addChild(_curLvPanelBg)
	-- 本级属性值Sp
	_curAttrValLabel = CCSprite:create("images/secondfriend/enhance/benjishuxingzhi.png")
	_curAttrValLabel:setAnchorPoint(ccp(0.5,1))
	_curAttrValLabel:setPosition(ccp(_curLvPanelBg:getContentSize().width*3/4,_curLvPanelBg:getContentSize().height*0.9))
	_curAttrValLabel:setColor(ccc3(0xff,0xf6,0x00))
	_curLvPanelBg:addChild(_curAttrValLabel)
	-- 创建本级属性值详情Label
	local curAffixTab = StageEnhanceData.calcCurAffix(_index,_curLv)
	_curLvAffixLabel = createAffixLabel(curAffixTab)
	_curLvAffixLabel:setAnchorPoint(ccp(0.5,1))
	_curLvAffixLabel:setPosition(ccp(_curAttrValLabel:getPositionX(),_curAttrValLabel:getPositionY()-_curAttrValLabel:getContentSize().height-10))
	_curLvPanelBg:addChild(_curLvAffixLabel)
	-- 下级属性BG
	_nextLvPanelBg = CCScale9Sprite:create("images/common/bg/9s_1.png")
	_nextLvPanelBg:setAnchorPoint(ccp(0.5,0.5))
	_nextLvPanelBg:setPosition(ccp(_bgLayer:getContentSize().width,_bgLayer:getContentSize().height/2))
	_nextLvPanelBg:setContentSize(CCSizeMake(400,150))
	_nextLvPanelBg:setScale(g_fScaleX)
	_bgLayer:addChild(_nextLvPanelBg)
	local maxLv =  StageEnhanceData.getEnhanceMaxLv(_index)
	if _curLv < maxLv then
		-- 下级属性值Sp
		_nextLvAttrLabel = CCSprite:create("images/secondfriend/enhance/xiajishuxingzhi.png")
		_nextLvAttrLabel:setAnchorPoint(ccp(0.5,1))
		_nextLvAttrLabel:setPosition(ccp(_nextLvPanelBg:getContentSize().width/4,_nextLvPanelBg:getContentSize().height*0.9))
		_nextLvPanelBg:addChild(_nextLvAttrLabel)
		-- 创建下一级属性值详情Label
		local nextAffixTab = StageEnhanceData.calcCurAffix(_index,_curLv+1)
		_nextLvAffixLabel = createAffixLabel(nextAffixTab)
		_nextLvAffixLabel:setAnchorPoint(ccp(0.5,1))
		_nextLvAffixLabel:setPosition(ccp(_nextLvAttrLabel:getPositionX(),_nextLvAttrLabel:getPositionY()-_nextLvAttrLabel:getContentSize().height-10))
		_nextLvPanelBg:addChild(_nextLvAffixLabel)
	else
		local waitTip = CCRenderLabel:create(GetLocalizeStringBy("yr_7013"),g_sFontPangWa,20,1,ccc3(0x00,0x00,0x00),type_shadow)
		waitTip:setAnchorPoint(ccp(0.5,1))
		waitTip:setPosition(ccp(_nextLvPanelBg:getContentSize().width/4,_nextLvPanelBg:getContentSize().height*0.9))
		waitTip:setColor(ccc3(0xff,0xf6,0x00))
		_nextLvPanelBg:addChild(waitTip)
	end
	-- 强化按钮
	local menu = CCMenu:create()
	menu:setAnchorPoint(ccp(0,0))
	menu:setPosition(ccp(0,0))
	menu:setTouchPriority(_touchPriority-10)
	_bgLayer:addChild(menu)
	-- 创建强化按钮
	local tSprite = {normal="images/common/btn/btn1_d.png",selected="images/common/btn/btn1_n.png"}
	local tLabel = {text=GetLocalizeStringBy("key_1269"),fontsize=30,nColor=ccc3(0xff,0xf6,0x00)}
	_enhanceBtn = LuaCCMenuItem.createMenuItemOfRenderLabelOnSprite(tSprite,tLabel)
	_enhanceBtn:setAnchorPoint(ccp(0.5,0))
	_enhanceBtn:setPosition(ccp(_bgLayer:getContentSize().width/2,60*g_fScaleY))
	_enhanceBtn:registerScriptTapHandler(enhanceBtnCallback)
	_enhanceBtn:setScale(g_fScaleY)
	menu:addChild(_enhanceBtn)
	-- Tip
	local enhanceTip = CCRenderLabel:create(GetLocalizeStringBy("yr_7011"),g_sFontPangWa,18,1,ccc3(0x00,0x00,0x00),type_shadow)
	enhanceTip:setAnchorPoint(ccp(0.5,1))
	enhanceTip:setPosition(ccp(_enhanceBtn:getContentSize().width/2,0))
	enhanceTip:setColor(ccc3(0xff,0xff,0xff))
	_enhanceBtn:addChild(enhanceTip)
	-- 消耗背景
	_costBg = CCScale9Sprite:create("images/common/bg/hui_bg.png")
	_costBg:setContentSize(CCSizeMake(200,60))
	_costBg:setAnchorPoint(ccp(0.5,0))
	_costBg:setPosition(ccp(_enhanceBtn:getContentSize().width/2,_enhanceBtn:getContentSize().height+10))
	_enhanceBtn:addChild(_costBg)
	-- 当前消耗
	-- 消耗
	-- 强化到下一级所需消耗
    refreshEnhanceNextLvCostLabel()
    -- 当前拥有强化资源
    -- Tips
    local tipLabel = CCRenderLabel:create(GetLocalizeStringBy("yr_7003"),g_sFontName,20,1,ccc3(0x00,0x00,0x00),type_shadow)
    tipLabel:setAnchorPoint(ccp(0,0.5))
    tipLabel:setPosition(ccp(_enhanceBtn:getPositionX()+(_enhanceBtn:getContentSize().width/2+10)*g_fScaleX,_enhanceBtn:getPositionY()+(_enhanceBtn:getContentSize().height/2)*g_fScaleY))
    tipLabel:setColor(ccc3(0x00,0xff,0x18))
    tipLabel:setScale(g_fScaleX)
    _bgLayer:addChild(tipLabel)
    -- icon
    local tipSp = CCSprite:create("images/common/secfriends_token_small.png")
    tipSp:setAnchorPoint(ccp(0,0.5))
    tipSp:setPosition(ccp(tipLabel:getContentSize().width,tipLabel:getContentSize().height/2))
    tipLabel:addChild(tipSp)
    -- tip num
    local haveResNum = StageEnhanceData.getNeedItemNum()
    _tipNum = CCRenderLabel:create(GetLocalizeStringBy("yr_7004",haveResNum),g_sFontName,20,1,ccc3(0x00,0x00,0x00),type_shadow)
    _tipNum:setAnchorPoint(ccp(0,0.5))
    _tipNum:setPosition(ccp(tipSp:getContentSize().width,tipSp:getContentSize().height/2))
    _tipNum:setColor(ccc3(0x00,0xff,0x18))
    tipSp:addChild(_tipNum)
end

--[[
	@des 	: 创建UI
	@param 	: 
	@return : 
--]]
function createUI( ... )
	-- 创建 助战位成就加成
	createAttrPanel()
	-- 创建助战位
	createStage()
	-- 创建助战位属性强化信息
	createEnhancePanel()
end

--[[
	@des 	: 创建返回按钮
	@param 	: 
	@return : 
--]]
function createBackBtn( ... )
	local btnMenu = CCMenu:create()
	btnMenu:setAnchorPoint(ccp(0,0))
	btnMenu:setPosition(ccp(0,0))
	btnMenu:setTouchPriority(-300)
	_bgLayer:addChild(btnMenu,20)
	-- 创建返回按钮
	local closeMenuItem = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
	closeMenuItem:setAnchorPoint(ccp(1,1))
	closeMenuItem:setPosition(ccp(_bgLayer:getContentSize().width,_bgLayer:getContentSize().height))
	closeMenuItem:registerScriptTapHandler(closeSelfCallback)
	closeMenuItem:setScale(g_fScaleX)
	btnMenu:addChild(closeMenuItem)
end

--[[
	@des 	: 预处理一些数据
	@param 	: 
	@return : 
--]]
function preHandleData( ... )
	-- 获取当前等级
    _curLv = StageEnhanceData.getCurStageLv(_index)
	local maxLv =  StageEnhanceData.getEnhanceMaxLv(_index)
	local needLv = _curLv+1
	if _curLv >= maxLv then
		needLv = maxLv
	end
    local _,itemCostId = StageEnhanceData.getNextLvEnhanceCost(needLv)
    local needItemNum = ItemUtil.getCacheItemNumBy(itemCostId)
	StageEnhanceData.setNeedItemNum(needItemNum)
end

--[[
	@des 	: 创建Layer
	@param 	: 
	@return : 
--]]
function createLayer( pWidth, pHeight, pIndex )
	-- init
	init()

	_index = pIndex
	print("===|_index|===",_index)

	_bgLayer = CCLayer:create()
	_bgLayer:setContentSize(CCSizeMake(pWidth,pHeight))
	_bgLayer:registerScriptHandler(onNodeEvent)
	-- 创建返回按钮
	createBackBtn()

	if StageEnhanceData.getStageLvData() ~= nil then
		print("===|有数据|===")
		preHandleData()
		createUI()
	else
		print("===|无数据|===")
		-- 获取助战位等级信息
		StageEnhanceController.getAttrExtraLevel(function( ... )
			preHandleData()
			createUI()
		end)
	end

	return _bgLayer
end
