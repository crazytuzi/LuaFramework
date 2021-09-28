-- Filename: PillComposeLayer.lua
-- Author: lgx
-- Date: 2016-05-30
-- Purpose: 六品丹药合成界面

module("PillComposeLayer", package.seeall)

require "script/ui/hero/HeroPublicLua"
require "script/ui/pill/PillData"
require "script/ui/pill/PillControler"

-- 丹药类型
local TYPE_DEFENSE 	= 1 
local TYPE_LIFE    	= 2
local TYPE_ATTACK  	= 3

local _touchPriority 	= nil -- 触摸优先级
local _zOrder 		 	= nil -- 显示层级
local _bgLayer 		 	= nil -- 背景层
local _maskLayer 		= nil -- 屏蔽层
local _leftArrowSp 		= nil -- 左箭头
local _rightArrowSp 	= nil -- 右箭头
local _pillTypeTabView	= nil -- 丹药列表tableView
local _curType 			= 0	  -- 记录当前类型
local _totalType 		= 3	  -- 记录类型总数
local _isNeedRefresh 	= false -- 记录是否需要刷新丹药主界面

-- 丹药类型图片路径
local _typeTitlePath = {
	"images/pill/defense_pill_max.png",
	"images/pill/life_pill_max.png",
	"images/pill/attack_pill_max.png"
}

--[[
	@desc 	: 初始化方法
	@param 	: 
	@return : 
--]]
local function init()
	_touchPriority 	 = nil
	_zOrder 		 = nil
	_bgLayer 		 = nil
	_maskLayer 		 = nil
	_leftArrowSp	 = nil
	_rightArrowSp 	 = nil
	_pillTypeTabView = nil
	_curType 		 = 0
	_totalType		 = 3
	_isNeedRefresh 	 = false
end

--[[
	@desc 	: 显示界面方法
	@param 	: pType 当前丹药类型
	@param 	: pTouchPriority 触摸优先级
	@param 	: pZorder 显示层级
	@return : 
--]]
function showLayer( pType, pTouchPriority, pZorder )
	_curType = pType or TYPE_DEFENSE
	_touchPriority = pTouchPriority or -600
	_zOrder = pZorder or 600

	local layer = createLayer(_curType,_touchPriority, _zOrder)
	local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(layer,_zOrder)
end

--[[
	@desc 	: 背景层触摸回调
	@param 	: eventType 事件类型 x,y 触摸点
	@return : 
--]]
local function layerToucCallback( eventType, x, y )
	return true
end

--[[
	@desc 	: 回调onEnter和onExit事件
	@param 	: event 事件名
	@return : 
--]]
function onNodeEvent( event )
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(layerToucCallback,false,_touchPriority,true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
		_bgLayer = nil
	end
end

--[[
	@desc	: 创建箭头闪烁动画
	@param	: pArrow 箭头精灵
	@return : 
--]]
local function runArrowAction( pArrow )
	local actionArrs = CCArray:create()
	actionArrs:addObject(CCFadeOut:create(1))
	actionArrs:addObject(CCFadeIn:create(1))
	local sequenceAction = CCSequence:create(actionArrs)
	local foreverAction = CCRepeatForever:create(sequenceAction)
	pArrow:runAction(foreverAction)
end

--[[
	@desc	: 更新箭头显示状态
	@param	: pIndex 当前选中的索引
	@return : 
--]]
local function updateArrowShowSttus( pIndex )
	-- 根据当前的显示的页数,更新箭头显示
	if (pIndex == 1) then 
		_leftArrowSp:setVisible(false)
		_rightArrowSp:setVisible(true)
	elseif (pIndex == _totalType) then 
		_leftArrowSp:setVisible(true)
		_rightArrowSp:setVisible(false)
	else
		_leftArrowSp:setVisible(true)
		_rightArrowSp:setVisible(true)
	end
end

--[[
	@desc 	: 创建Layer及UI
	@param 	: pType 当前丹药类型
	@param 	: pTouchPriority 触摸优先级
	@param 	: pZorder 显示层级
	@return : 
--]]
function createLayer( pType, pTouchPriority, pZorder )
	-- 初始化
	init()

	_curType = pType or TYPE_DEFENSE
	_touchPriority = pTouchPriority or -600
	_zOrder = pZorder or 600

	-- 背景层
	_bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bgLayer:setPosition(ccp(0, 0))
	_bgLayer:registerScriptHandler(onNodeEvent)
	_bgLayer:setAnchorPoint(ccp(0, 0))

	-- 背景大小
	local bgSize = CCSizeMake(615,775)

	-- 背景图
	local bgSprite = CCScale9Sprite:create(CCRectMake(100,80,10,20),"images/common/viewbg1.png")
	bgSprite:setContentSize(bgSize)
	bgSprite:setAnchorPoint(ccp(0.5,0.5))
	bgSprite:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
	bgSprite:setScale(g_fElementScaleRatio)
	_bgLayer:addChild(bgSprite)

	-- 标题背景
	local titleSprite = CCSprite:create("images/common/viewtitle1.png")
	titleSprite:setAnchorPoint(ccp(0.5,0.5))
	titleSprite:setPosition(ccp(bgSprite:getContentSize().width/2,bgSprite:getContentSize().height - 6))
	bgSprite:addChild(titleSprite)

	local titleSize = titleSprite:getContentSize()

	-- 标题
	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("lgx_1068"),g_sFontPangWa,33)
	titleLabel:setColor(ccc3(0xff,0xe4,0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titleSize.width*0.5,titleSize.height*0.5))
	titleSprite:addChild(titleLabel)

	-- 背景按钮层
	local bgMenu = CCMenu:create()
	bgMenu:setAnchorPoint(ccp(0,0))
	bgMenu:setPosition(ccp(0,0))
	bgMenu:setTouchPriority(_touchPriority - 1)
	bgSprite:addChild(bgMenu)

	-- 关闭按钮
	local closeItem = CCMenuItemImage:create("images/common/btn_close_n.png","images/common/btn_close_h.png")
	closeItem:setAnchorPoint(ccp(1,1))
	closeItem:setPosition(ccp(bgSize.width*1.03,bgSize.height*1.03))
	closeItem:registerScriptTapHandler(closeItemCallBack)
	bgMenu:addChild(closeItem)

	-- 全部合成按钮
    local composeAllItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(210,75),GetLocalizeStringBy("zzh_1319"),ccc3(0xfe,0xdb,0x1c),35,g_sFontPangWa,1,ccc3(0x00,0x00,0x00))
    composeAllItem:setAnchorPoint(ccp(0.5,0))
    composeAllItem:setPosition(ccp(bgSize.width*0.25,35))
    composeAllItem:registerScriptTapHandler(composeAllCallBack)
    bgMenu:addChild(composeAllItem)

	-- 合成按钮
    local composeOneItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(210,75),GetLocalizeStringBy("key_1363"),ccc3(0xfe,0xdb,0x1c),35,g_sFontPangWa,1,ccc3(0x00,0x00,0x00))
    composeOneItem:setAnchorPoint(ccp(0.5,0))
    composeOneItem:setPosition(ccp(bgSize.width*0.75,35))
    composeOneItem:registerScriptTapHandler(composeOneCallBack)
    bgMenu:addChild(composeOneItem)

    -- 二级背景
 	-- local secBgSprite = CCSprite:create("images/athena/compose_bg.png")
 	-- secBgSprite:setAnchorPoint(ccp(0.5,1))
 	-- secBgSprite:setPosition(ccp(bgSize.width*0.5,bgSize.height - 55))
 	-- bgSprite:addChild(secBgSprite)

   	-- 左箭头
    _leftArrowSp = CCSprite:create( "images/common/left_big.png")
    _leftArrowSp:setAnchorPoint(ccp(0,0.5))
    _leftArrowSp:setPosition(0,bgSize.height*0.5)
    bgSprite:addChild(_leftArrowSp,1)
    runArrowAction(_leftArrowSp)

    -- 右箭头
    _rightArrowSp = CCSprite:create( "images/common/right_big.png")
    _rightArrowSp:setAnchorPoint(ccp(1,0.5))
    _rightArrowSp:setPosition(bgSize.width,bgSize.height*0.5)
    bgSprite:addChild(_rightArrowSp,1)
    runArrowAction(_rightArrowSp)

    -- 更新箭头状态
    local curIndex = PillData.getIndexByPillType(_curType)
    -- print("curIndex -> ",curIndex)
    updateArrowShowSttus(curIndex)

    -- 创建合成丹药列表
    local tabViewSize = CCSizeMake(bgSize.width-40,bgSize.height-140)
    local eventHandler = function ( functionName, tableView, index, cell )
		if functionName == "cellSize" then
			return tabViewSize
		elseif functionName == "cellAtIndex" then
			return createEachTypeCell(index)
		elseif functionName == "numberOfCells" then
			return _totalType
		elseif functionName == "cellTouched" then
			
		elseif functionName == "scroll" then
			
		elseif functionName == "moveEnd" then
			-- 更新箭头
    		updateArrowShowSttus(index)
    		_curType = PillData.getPillTypeByIndex(index)
		end
	end
	-- 合成丹药tabView
    _pillTypeTabView = STTableView:create()
    _pillTypeTabView:setDirection(kCCScrollViewDirectionHorizontal)
    _pillTypeTabView:setContentSize(tabViewSize)
	_pillTypeTabView:setEventHandler(eventHandler)
	_pillTypeTabView:setPageViewEnabled(true)
	_pillTypeTabView:setTouchPriority(_touchPriority - 10)
	_pillTypeTabView:ignoreAnchorPointForPosition(false)
	_pillTypeTabView:setAnchorPoint(ccp(0.5,0))
	_pillTypeTabView:setPosition(ccp(bgSize.width*0.5,95))
	bgSprite:addChild(_pillTypeTabView)
	_pillTypeTabView:reloadData()

	-- 设置显示当前类型
	_pillTypeTabView:showCellByIndex(curIndex)

	return _bgLayer
end

--[[
	@desc 	: 创建每一类型丹药合成Cell
	@param	: pIndex 显示索引
	@return	: STTableViewCell
--]]
function createEachTypeCell( pIndex )
	local cell = STTableViewCell:create()

	local tableSize = CCSizeMake(615-40,775-140)
	-- 二级背景
 	local secBgSprite = CCSprite:create("images/athena/compose_bg.png")
 	-- local secBgSprite = CCSprite:create()
 	-- secBgSprite:setContentSize(CCSizeMake(568,589))
 	secBgSprite:setAnchorPoint(ccp(0.5,0))
 	secBgSprite:setPosition(ccp(tableSize.width*0.5,30))
 	cell:addChild(secBgSprite,1,kTAG_SECBG)
 	-- 保存下引用，用于加合成特效时获取父节点
 	cell.secBgSprite = secBgSprite

 	local secBgSize = secBgSprite:getContentSize()

 	local pillType = PillData.getPillTypeByIndex(pIndex)
 	-- 丹药类型
 	local typeSprite  = CCSprite:create(_typeTitlePath[pillType])
    typeSprite:setAnchorPoint(ccp(0.5,0.5))
    secBgSprite:addChild(typeSprite)
    typeSprite:setPosition(ccpsprite(0.5,0.925,secBgSprite))

 	-- 两个箭头
 	local arrowPosX = 120
 	local arrowPosY = 266
 	local angle = 90
 	local arrowTable = {
 							{ccp(arrowPosX,arrowPosY),-angle},
 							{ccp(secBgSize.width - arrowPosX,arrowPosY),angle}
 					   }
 	for i = 1,2 do
 		local arrowSprite = CCSprite:create("images/athena/arrow.png")
 		arrowSprite:setRotation(arrowTable[i][2])
 		arrowSprite:setAnchorPoint(ccp(0.5,1))
 		arrowSprite:setPosition(arrowTable[i][1])
 		secBgSprite:addChild(arrowSprite)
 	end

    --[[
		{
		    "result" => Table
		        {
		            tid => 61306
		            num => 1
		        }
		    "needItem" => Table
		        {
		            [1] => Table
		                {
		                    tid => 61305
		                    num => 4
		                }
		            [2] => Table
		                {
		                    tid => 61000
		                    num => 1
		                }
		        }
		}
    --]]

    local pillCompInfo = PillData.getPillComposeInfoByType(pillType)

     -- 合成的丹药 背景
    local finalBgSprite = CCSprite:create("images/athena/item_bg.png")
    finalBgSprite:setAnchorPoint(ccp(0.5,0.5))
    finalBgSprite:setPosition(ccp(secBgSize.width*0.5,270))
    secBgSprite:addChild(finalBgSprite)

    local itemBgSize = finalBgSprite:getContentSize()

    -- 合成的丹药物品
    local finalPillTid = pillCompInfo.result.tid
    local finalPillSprite = ItemSprite.getItemSpriteById(finalPillTid,nil,nil,nil,_touchPriority - 30)
    finalPillSprite:setAnchorPoint(ccp(0.5,0.5))
    finalPillSprite:setPosition(ccp(itemBgSize.width*0.5,itemBgSize.height*0.5))
    finalBgSprite:addChild(finalPillSprite)

    local finalPillInfo = ItemUtil.getItemById(finalPillTid)
    local finalPillNameLabel = CCRenderLabel:create(finalPillInfo.name,g_sFontPangWa,25,1,ccc3(0x00,0x00,0x00),type_stroke)
    finalPillNameLabel:setColor(HeroPublicLua.getCCColorByStarLevel(finalPillInfo.quality))
    finalPillNameLabel:setAnchorPoint(ccp(0.5,1))
    finalPillNameLabel:setPosition(ccp(itemBgSize.width*0.5,0))
    finalBgSprite:addChild(finalPillNameLabel)

    local canCompNum = PillData.getMaxComposeNumByType(pillType)
    local finalPillNumLabel = CCRenderLabel:create(""..canCompNum,g_sFontName,18,1,ccc3(0x00,0x00,0x00),type_stroke)
    finalPillNumLabel:setColor(ccc3(0x00,0xff,0x18))
    finalPillNumLabel:setAnchorPoint(ccp(1,0))
    finalPillNumLabel:setPosition(ccp(itemBgSize.width - 20,20))
    finalBgSprite:addChild(finalPillNumLabel)

    -- 消耗材料物品
    local gapLenth = 85
    local gapHeight = 270
    local posTable = { 
    				   {gapLenth,gapHeight},
    				   {secBgSize.width - gapLenth,gapHeight} 
					 }
	local needItemTab = pillCompInfo.needItem 
	for i = 1,#needItemTab do
    	-- 物品背景
    	local itemBgSprite = CCSprite:create("images/athena/item_bg.png")
    	itemBgSprite:setAnchorPoint(ccp(0.5,0.5))
    	itemBgSprite:setPosition(ccp(posTable[i][1],posTable[i][2]))
    	secBgSprite:addChild(itemBgSprite,1,i)

    	-- 物品图
    	local needItemTid = needItemTab[i].tid
    	local itemSprite = ItemSprite.getItemSpriteById(needItemTid,nil,nil,nil,_touchPriority - 30)
    	itemSprite:setAnchorPoint(ccp(0.5,0.5))
    	itemSprite:setPosition(ccp(itemBgSize.width*0.5,itemBgSize.height*0.5))
    	itemBgSprite:addChild(itemSprite)

    	-- 名字底
    	local noSprite = CCSprite:create("images/athena/name_bg.png")
    	noSprite:setAnchorPoint(ccp(0.5,0))
    	noSprite:setPosition(ccp(itemBgSize.width*0.5,itemBgSize.height))
    	itemBgSprite:addChild(noSprite)

    	local noSize = noSprite:getContentSize()
    	-- 编号
    	local noLabel = CCRenderLabel:create(tostring(i),g_sFontPangWa,25,1,ccc3(0x00,0x00,0x00),type_stroke)
    	noLabel:setColor(ccc3(0xff,0xff,0xff))
    	noLabel:setAnchorPoint(ccp(0.5,0.5))
    	noLabel:setPosition(ccp(15,noSize.height*0.5))
    	noSprite:addChild(noLabel)

    	local itemInfo = ItemUtil.getItemById(needItemTid)
    	-- 名字
    	local nameLabel = CCRenderLabel:create(itemInfo.name,g_sFontPangWa,25,1,ccc3(0x00,0x00,0x00),type_stroke)
    	nameLabel:setColor(HeroPublicLua.getCCColorByStarLevel(itemInfo.quality))
    	nameLabel:setAnchorPoint(ccp(0,0.5))
    	nameLabel:setPosition(ccp(40,noSize.height*0.5))
    	noSprite:addChild(nameLabel)

    	-- 当前拥有数量
    	local haveItemNum = ItemUtil.getCacheItemNumBy(needItemTid)
    	local needItemNum = needItemTab[i].num
    	local numColor = (haveItemNum >= needItemNum) and ccc3(0x00,0xff,0x18) or ccc3(0xff,0x00,0x00)
    	local numLabel = CCRenderLabel:create(haveItemNum .. "/" .. needItemNum,g_sFontName,18,1,ccc3(0x00,0x00,0x00),type_stroke)
    	numLabel:setColor(numColor)
    	numLabel:setAnchorPoint(ccp(1,0))
    	numLabel:setPosition(ccp(itemBgSize.width - 20,20))
    	itemBgSprite:addChild(numLabel,1)
    end

	return cell
end

--[[
	@desc 	: 创建合成特效动画
	@param 	: pOverCallback 所有特效动画播放完成的回调
	@return : 
--]]
function createComposeEffect( pOverCallback )
	-- 获取当前丹药类型的Cell
	local curIndex = PillData.getIndexByPillType(_curType)
	-- print("curIndex ->",curIndex)
	local pillCell = _pillTypeTabView:cellAtIndex(curIndex)
	-- print("-------createComposeEffect-------")
	-- print(pillCell)
	local secBgSprite = tolua.cast(pillCell.secBgSprite,"CCSprite")
	local secBgSize = secBgSprite:getContentSize()

	local pillCompInfo = PillData.getPillComposeInfoByType(_curType)
	local needItemTab = pillCompInfo.needItem

	local moveEndCallback = function()
		-- 合成特效播放
	    local fuseEffectSprite = XMLSprite:create("images/treasure/effect/bsqdE")
	    fuseEffectSprite:setAnchorPoint(ccp(0.5, 0.5))
	    fuseEffectSprite:setPosition(ccp(secBgSize.width*0.5,270))
	    secBgSprite:addChild(fuseEffectSprite,80)

	    local overCallback = function()
	    	-- 移除特效
			fuseEffectSprite:removeFromParentAndCleanup(true)
        	fuseEffectSprite = nil
        	-- 回调
        	if pOverCallback ~= nil then
        		pOverCallback()
        	end
		end
	    fuseEffectSprite:registerEndCallback(overCallback)
	end

	local gapLenth = 85
    local gapHeight = 270
    local posTable = { 
    				   {gapLenth,gapHeight},
    				   {secBgSize.width - gapLenth,gapHeight} 
					 }
	for i = 1,#needItemTab do

		local needItemTid = needItemTab[i].tid
		local itemSprite = ItemSprite.getItemSpriteByItemId(needItemTid)
		itemSprite:setAnchorPoint(ccp(0.5, 0.5))
		itemSprite:setPosition(ccp(posTable[i][1],posTable[i][2]))
		secBgSprite:addChild(itemSprite,30)

		-- 移动到中心
		local moveTo = CCMoveTo:create(0.8, ccp(secBgSize.width*0.5,270))
		local actions = CCArray:create()
		actions:addObject(moveTo)
		actions:addObject(CCCallFunc:create(function()
			itemSprite:removeFromParentAndCleanup(true)
			moveEndCallback()
			actions:release()
		end))
		actions:retain()

		-- 消耗物品特效
		local appearEffectSprite = XMLSprite:create("images/base/effect/astro/zhanxingbao")
        appearEffectSprite:setAnchorPoint(ccp(0.5, 0.5))
        appearEffectSprite:setPosition(ccp(itemSprite:getPositionX(), itemSprite:getPositionY()))
        secBgSprite:addChild(appearEffectSprite,50)

        local animationEndCallback = function()
        	local seqAction = CCSequence:create(actions)
        	itemSprite:runAction(seqAction)
        	appearEffectSprite:removeFromParentAndCleanup(true)
        	appearEffectSprite = nil
	    end
	    appearEffectSprite:registerEndCallback( animationEndCallback )

        print("丹药合成特效 = ", needItemTid)
	end
end

--[[
	@desc 	: 创建屏蔽层
	@param 	: 
	@return : 
--]]
function addMaskLayer()
	require "script/utils/BaseUI"
	_maskLayer = BaseUI.createMaskLayer(-5000, nil, nil, 0)
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(_maskLayer, 2000)
end

--[[
	@desc 	: 移除屏蔽层
	@param 	: 
	@return : 
--]]
function removeMaskLayer()
	if (_maskLayer) then
		_maskLayer:removeFromParentAndCleanup(true)
		_maskLayer = nil
	end
end

--[[
	@desc 	: 刷新丹药背包数据缓存及丹药主界面
	@param 	: 
	@return : 
--]]
function refreshPillLayer()
	-- 刷新丹药背包数据缓存(当初硬拷贝的一份道具背包数据需要重新初始化下)
	PillData.initBagCache()
	-- 刷新丹药主界面
	require "script/ui/pill/PillLayer"
	PillLayer.refreshUI()
end

--[[
	@desc 	: 全部合成按钮回调,消耗材料合成当前所能合成的最大值
	@param 	: 
	@return : 
--]]
function composeAllCallBack()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	-- 合成成功回调
	local successCallback = function(retData)
		-- 需要刷新主界面
		_isNeedRefresh = true
		-- 播放合成成功特效
		createComposeEffect(function()
			-- 移除屏蔽层
			removeMaskLayer()
			-- 弹出奖励面板
			local rewardInfo = PillData.dealPillComposeRetData(retData)
			local okCallback = function()
				-- 若点击全部合成，则弹出提示弹板后，丹药合成界面自动关闭
				closeItemCallBack()
			end
			require "script/ui/item/ReceiveReward"
        	ReceiveReward.showRewardWindow(rewardInfo, okCallback, 10000, -800)
		end)
	end
	PillControler.composeAllPill(successCallback,_curType)
end

--[[
	@desc 	: 合成按钮回调,消耗材料合成1个物品
	@param 	: 
	@return : 
--]]
function composeOneCallBack()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	-- 合成成功回调
	local successCallback = function(retData)
		-- 需要刷新主界面
		_isNeedRefresh = true
		-- 播放合成成功特效
		createComposeEffect(function()
			-- 移除屏蔽层
			removeMaskLayer()
			-- 弹出奖励面板
			local rewardInfo = PillData.dealPillComposeRetData(retData)
			local okCallback = function()
				-- 若点击合成，则弹出提示弹板后，丹药合成界面不自动关闭
				-- 刷新对应丹药类型的Cell
				local curIndex = PillData.getIndexByPillType(_curType)
				-- _pillTypeTabView:updateCellAtIndex(curIndex)

				-- 需要全部Cell都刷新下
				_pillTypeTabView:reloadData()
				-- 设置显示当前Cell
				_pillTypeTabView:showCellByIndex(curIndex)
			end
			require "script/ui/item/ReceiveReward"
        	ReceiveReward.showRewardWindow(rewardInfo, okCallback, 10000, -800)
		end)
	end
	PillControler.composeOnePill(successCallback,_curType)
end

--[[
	@desc 	: 关闭界面(移除背景层)
	@param 	: 
	@return : 
--]]
function removeBgLayer()
	if (_isNeedRefresh) then
		-- 刷新丹药主界面
		refreshPillLayer()
	end
	if not tolua.isnull(_bgLayer) then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
end

--[[
	@desc 	: 关闭按钮回调,关闭界面
	@param 	: 
	@return : 
--]]
function closeItemCallBack()
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	removeBgLayer()
end