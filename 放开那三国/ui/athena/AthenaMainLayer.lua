-- Filename：	AthenaMainLayer.lua
-- Author：		zhang zihang
-- Date：		2015-3-25
-- Purpose：		主角星魂主页面，因为名字不知道咋翻译，所以和后端定的叫  雅典娜  吧  - -!

module("AthenaMainLayer",package.seeall)

require "script/ui/athena/AthenaService"
require "script/ui/athena/AthenaData"
require "script/ui/athena/AthenaUtils"
require "script/ui/athena/AthenaInfoLayer"
require "script/ui/athena/AthenaComposeLayer"
require "script/ui/tip/AnimationTip"
require "script/ui/hero/HeroPublicLua"
require "script/ui/hero/FightSoulAttrDialog"
require "script/utils/BaseUI"
require "script/model/hero/HeroModel"

local _mainLayer 									--主页面
local _curMapNo										--当前地图序号
local _leftNode										--左边那个图
local _middleNode									--中间显示的那个图
local _rightNode									--右边那个图
local _beginPoint 									--开始点击的位置
local _lastMovePoint 								--上次点击的点
local _midPos 										--中间图位置
local _ltPos 										--左图位置
local _rtPos 										--右图位置
local _bgMenu 										--背景menu
local _numLabel										--星魂数label
local _leftArrowSprite 								--左箭头
local _rightArrowSprite 							--右箭头
local _gapHeight									--中间node大小
local _canTouch
	
local kTouchPirority = -550  						--触摸优先级
local kMoveRight = 1 								--向右滑动
local kMoveLeft = 2 								--向左滑动
local kGapHeight = 85 								--顶端留出的距离
local kRouteTag = 100 								--路线tag
local kMenuTag = 200 								--菜单tag
local kSSTag = 300 									--特殊技能框tag
local kMoveValue = g_winSize.width*0.3 				--超过屏幕0.3的滑动开始滑

--================================= Init =======================
--[[
	@des 	:初始化
--]]
function init()
	_mainLayer = nil
	_curMapNo = nil
	_leftNode = nil 
	_middleNode = nil
	_rightNode = nil
	_beginPoint = nil
	_lastMovePoint = nil
	_midPos = nil
	_ltPos = nil
	_rtPos = nil
	_bgMenu = nil
	_numLabel = nil
	_gapHeight = nil
	_canTouch = true
end

--================================= Touch =======================
--[[
	@des 	:触摸回调
	@param  :事件
	@param  :触摸点x
	@param  :触摸点y
--]]
function touchLayerCb(p_eventType,p_x,p_y)
	if p_eventType == "began" then
		_beginPoint = ccp(p_x,p_y)
		_lastMovePoint = ccp(p_x,p_y)

		--防止没有创建出来
		if _middleNode == nil then
			return false
		end

print("began: _canTouch, x, y = ", _canTouch, p_x, p_y)

		if(_canTouch == false)then
			return false
		end

		local nodeSize = _middleNode:getContentSize()
		local nodeTouchPos = _middleNode:convertToNodeSpace(_beginPoint)
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
		moveNode(_middleNode,deltaX,_midPos)
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
			moveBackAction(_middleNode,_midPos)
			moveBackAction(_rightNode,_rtPos)
		end
	end
end

--[[
	@des 	:touch事件
	@param  :事件
--]]
function onNodeEvent( p_eventType )
	if p_eventType == "enter" then
		_mainLayer:registerScriptTouchHandler(touchLayerCb,false,kTouchPirority,false)
		_mainLayer:setTouchEnabled(true)
	elseif p_eventType == "exit" then
		_mainLayer:unregisterScriptTouchHandler()
	end
end

--[[
	@des 	:移动node
	@param  :node
	@param  :x偏移量
--]]
function moveNode(p_node,p_dx,p_oriPos)
	--如果没有node则
	if p_node == nil then
		return
	end

	--被注释的部分虽然也能滑动，但是用户体验不好，被策划一句   感觉不对   干掉了
	-- local curPositionX = p_node:getPositionX()
	-- local curPositionY = p_node:getPositionY()
	local curPositionX = p_oriPos.x
	local curPositionY = p_oriPos.y

	local nextPositionX = curPositionX + p_dx
	p_node:setPosition(nextPositionX,curPositionY)
end

--[[
	@des 	:左或右的图向中间移动
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
		nextNo = _curMapNo - 1
	else
		midMovePos = _ltPos
		toMidNode = _rightNode
		delNode = _leftNode
		nextNo = _curMapNo + 1
	end

	_canTouch = false

	toMidNode:runAction(CCMoveTo:create(moveTime,_midPos))

	local moveOverCallBack = function()
		--不为空才删除
		if delNode ~= nil then
			delNode:removeFromParentAndCleanup(true)
		end
		if p_direction == kMoveRight then
			_middleNode,_rightNode = toMidNode,_middleNode
			_leftNode = createMapNode(_curMapNo - 2,_ltPos)
		else
			_middleNode,_leftNode = toMidNode,_middleNode
			_rightNode = createMapNode(_curMapNo + 2,_rtPos)
		end

		AthenaData.setCurPageNo(nextNo)
		_curMapNo = nextNo

		_canTouch = true
	end

	_middleNode:runAction(CCSequence:createWithTwoActions(
		                   CCMoveTo:create(moveTime,midMovePos),
		                   CCCallFunc:create(moveOverCallBack)
		                   ))
end

--[[
	@des 	:回到原位
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

--================================= CallBack =======================
--[[
	@des 	:合成按钮回调
--]]
function composeCallBack()
	AthenaComposeLayer.showLayer(kTouchPirority - 10)
end

--[[
	@des 	:总属性回调
--]]
function totalCallBack()
	FightSoulAttrDialog.showTip(nil,HeroModel.getNecessaryHero().hid,nil,kTouchPirority - 10,AthenaData.getSkillPreviewInfo(),GetLocalizeStringBy("zzh_1327"))
end

--[[
	@des 	:返回回调
--]]
function returnCallBack()
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	--挥一挥衣袖，不带走一片云彩
	-- AthenaData.setAthenaInfo(nil)
	--返回到天命界面
	require "script/ui/destiny/DestinyLayer"
	local destinyLayer = DestinyLayer.createLayer()
	MainScene.changeLayer(destinyLayer, "destinyLayer")
end

--[[
	@des 	:点击普通技能按钮回调
	@param  :tag
--]]
function tapSkillCallBack(p_tag)
	local skillLv = AthenaData.getSkillLv(_curMapNo,p_tag)
	local infoLayerCb = function ( ... )
		tapSkillCallBack(p_tag)
	end
	AthenaInfoLayer.showLayer(p_tag,skillLv,kTouchPirority - 10,999,infoLayerCb)
end

--[[
	@des 	:刷新所有技能
	@param  :当前技能id
--]]
function refreshAllSkill(p_nowSkillId)
	local mapInfo = AthenaData.getTreeDBInfo(_curMapNo)
	local skillTable = AthenaData.getSkillTable(mapInfo.star_affix)
	local routeSprite = tolua.cast(_middleNode:getChildByTag(kRouteTag),"CCSprite")
	local curMenu = tolua.cast(routeSprite:getChildByTag(kMenuTag),"BTSensitiveMenu")
	local curMenuItem = tolua.cast(curMenu:getChildByTag(p_nowSkillId),"CCMenuItemSprite")

	-- AthenaUtils.refreshImgSprite(curMenuItem,p_nowSkillId,_curMapNo)
	--刷新当前技能的等级
	AthenaUtils.refreshLvLabel(curMenuItem,p_nowSkillId,_curMapNo)
	local skillInfo = AthenaData.getSkillDBInfo(p_nowSkillId)
	local kidSkillTable = string.split(skillInfo.kid_skill,"|")
	for i = 1,#kidSkillTable do
		local curSkillId = tonumber(kidSkillTable[i])
		local curMenuItem = tolua.cast(curMenu:getChildByTag(curSkillId),"CCMenuItemSprite")
		--刷新判断是否是彩色图
		AthenaUtils.refreshImgSprite(curMenuItem,curSkillId,_curMapNo)
	end
	--刷新当前页面的箭头，因为不用再取了
	for i = 1,#skillTable do
		local curSkillId = tonumber(skillTable[i])
		local curMenuItem = tolua.cast(curMenu:getChildByTag(curSkillId),"CCMenuItemSprite")
		AthenaUtils.refreshUpgradeSprite(curMenuItem,curSkillId,_curMapNo)
	end

	--刷新特殊技能
	local secBgSprite = tolua.cast(_middleNode:getChildByTag(kSSTag),"CCScale9Sprite")
	local curMenu = tolua.cast(secBgSprite:getChildByTag(kMenuTag),"BTSensitiveMenu")
	local ssItem = nil
	if  (tonumber(mapInfo[1]) >8)then
		ssItem = tolua.cast(curMenu:getChildByTag(mapInfo[12]),"CCMenuItemSprite")
	else
		ssItem= tolua.cast(curMenu:getChildByTag(AthenaData.getSSkillId(mapInfo)[1]),"CCMenuItemSprite")
	end
	AthenaUtils.refreshSSMenuItem(ssItem,_curMapNo)
	local allSkillTable = {
								{_curMapNo - 1,_leftNode},
								{_curMapNo + 1,_rightNode}
						  }
	--刷新所有箭头					  
	for i = 1,#allSkillTable do
		local firstTable = allSkillTable[i]
		local curPage = firstTable[1]
		local curNode = firstTable[2]
		--页面不为空，且页面开了
		if curNode ~= nil and AthenaData.isThisPageOpen(curPage) then
			local mapInfo = AthenaData.getTreeDBInfo(curPage)
			local skillTable = AthenaData.getSkillTable(mapInfo.star_affix)
			for j = 1,#skillTable do
				local curSkillId = tonumber(skillTable[j])
				local routeSprite = tolua.cast(curNode:getChildByTag(kRouteTag),"CCSprite")
				local curMenu = tolua.cast(routeSprite:getChildByTag(kMenuTag),"BTSensitiveMenu")
				local curMenuItem = tolua.cast(curMenu:getChildByTag(curSkillId),"CCMenuItemSprite")
				AthenaUtils.refreshUpgradeSprite(curMenuItem,curSkillId,curPage)
			end
		end
	end
end

--[[
	@des 	:刷新所有箭头
--]]
function refreshAllArrow()
	local allSkillTable = {
								{_curMapNo - 1,_leftNode},
								{_curMapNo,_middleNode},
								{_curMapNo + 1,_rightNode}
						  }
	--刷新所有箭头					  
	for i = 1,#allSkillTable do
		local firstTable = allSkillTable[i]
		local curPage = firstTable[1]
		local curNode = firstTable[2]
		if curNode ~= nil and AthenaData.isThisPageOpen(curPage) then
			local mapInfo = AthenaData.getTreeDBInfo(curPage)
			local skillTable = AthenaData.getSkillTable(mapInfo.star_affix)
			for j = 1,#skillTable do
				local curSkillId = tonumber(skillTable[j])
				local routeSprite = tolua.cast(curNode:getChildByTag(kRouteTag),"CCSprite")
				local curMenu = tolua.cast(routeSprite:getChildByTag(kMenuTag),"BTSensitiveMenu")
				local curMenuItem = tolua.cast(curMenu:getChildByTag(curSkillId),"CCMenuItemSprite")
				AthenaUtils.refreshUpgradeSprite(curMenuItem,curSkillId,curPage)
			end
		end
	end
end

--[[
	@des 	:刷新星星数量
--]]
function refreshStarNum()
	_numLabel:setString("X" .. AthenaData.getStarSoulNum())
end

--[[
	@des 	:创建下一个node
--]]
function createNextNode()
	_rightNode = createMapNode(_curMapNo + 1,_rtPos)
end

--[[
	@des 	:刷新箭头
--]]
function updateArrow()
	--没有下一页
	if _curMapNo < AthenaData.getPreviewNum() then
		_rightArrowSprite:setVisible(true)
	else
		_rightArrowSprite:setVisible(false)
	end

	if _curMapNo > 1 then
		_leftArrowSprite:setVisible(true)
	else
		_leftArrowSprite:setVisible(false)
	end
end
--================================= UI =======================
--[[
	@des 	:创建背景UI
--]]
function createBgUI()
	_bgMenu = CCMenu:create()
	_bgMenu:setAnchorPoint(ccp(0,0))
	_bgMenu:setPosition(ccp(0,0))
	_mainLayer:addChild(_bgMenu)

	-- 星魂录
	local previewMenuItem = CCMenuItemImage:create("images/athena/preview_n.png", "images/athena/preview_h.png")
	previewMenuItem:setAnchorPoint(ccp(0.5,1))
	previewMenuItem:setPosition(ccp(g_winSize.width*305/640,g_winSize.height))
	previewMenuItem:setScale(g_fElementScaleRatio)
	previewMenuItem:registerScriptTapHandler(previewCallBack)
	_bgMenu:addChild(previewMenuItem)

	--合成按钮
	local composeMenuItem = CCMenuItemImage:create("images/athena/compose_n.png", "images/athena/compose_h.png")
	composeMenuItem:setAnchorPoint(ccp(0.5,1))
	composeMenuItem:setPosition(ccp(g_winSize.width*395/640,g_winSize.height))
	composeMenuItem:setScale(g_fElementScaleRatio)
	composeMenuItem:registerScriptTapHandler(composeCallBack)
	_bgMenu:addChild(composeMenuItem)

	--总属性按钮
	local totalMenuItem = CCMenuItemImage:create("images/athena/total_n.png", "images/athena/total_h.png")
	totalMenuItem:setAnchorPoint(ccp(0.5,1))
	totalMenuItem:setPosition(ccp(g_winSize.width*485/640,g_winSize.height))
	totalMenuItem:setScale(g_fElementScaleRatio)
	totalMenuItem:registerScriptTapHandler(totalCallBack)
	_bgMenu:addChild(totalMenuItem)	

	local gapLenth = kGapHeight*g_fElementScaleRatio
	local halfLenth = gapLenth*0.5

	--返回按钮
	local returnMenuItem = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
	returnMenuItem:setAnchorPoint(ccp(0.5,0.5))
	returnMenuItem:setPosition(ccp(g_winSize.width*575/640,g_winSize.height - halfLenth))
	returnMenuItem:setScale(g_fElementScaleRatio)
	returnMenuItem:registerScriptTapHandler(returnCallBack)
	_bgMenu:addChild(returnMenuItem)	

	--总星魂数
	local totalSprite = CCSprite:create("images/athena/athena_num.png")
	--星星
	local starSprite = CCSprite:create("images/athena/tu.png")
	--星魂数
	_numLabel = CCLabelTTF:create("X" .. AthenaData.getStarSoulNum(),g_sFontPangWa,25)
	_numLabel:setColor(ccc3(0xff,0xff,0xff))

	local connectNode = BaseUI.createHorizontalNode({ totalSprite,starSprite,_numLabel })
	connectNode:setAnchorPoint(ccp(0,0.5))
	connectNode:setPosition(ccp(g_winSize.width*10/640,g_winSize.height - halfLenth))
	connectNode:setScale(g_fElementScaleRatio)
	_mainLayer:addChild(connectNode)

	-- --线图
	-- local lineSprite = CCSprite:create("images/copy/fort/top_cutline.png")
	-- lineSprite:setPosition(ccp(g_winSize.width/2,g_winSize.height - gapLenth))
	-- lineSprite:setAnchorPoint(ccp(0.5,1))
	-- lineSprite:setScale(g_fScaleX)
	-- _mainLayer:addChild(lineSprite)

	_leftArrowSprite = CCSprite:create("images/common/left_big.png")
	_leftArrowSprite:setAnchorPoint(ccp(0,0.5))
	_leftArrowSprite:setPosition(ccp(0,g_winSize.height*0.5))
	_leftArrowSprite:setScale(g_fElementScaleRatio)
	_leftArrowSprite:setVisible(false)
	_mainLayer:addChild(_leftArrowSprite)

	_rightArrowSprite = CCSprite:create("images/common/right_big.png")
	_rightArrowSprite:setAnchorPoint(ccp(1,0.5))
	_rightArrowSprite:setPosition(ccp(g_winSize.width,g_winSize.height*0.5))
	_rightArrowSprite:setScale(g_fElementScaleRatio)
	_rightArrowSprite:setVisible(false)
	_mainLayer:addChild(_rightArrowSprite)	

	AthenaUtils.addActionToSprite(_leftArrowSprite)
	AthenaUtils.addActionToSprite(_rightArrowSprite)

	--定时器
	schedule(_mainLayer,updateArrow,1)
end

--[[
	@des 	:星魂录
--]]
function previewCallBack( ... )
	btimport "script/ui/athena/AthenaPreviewLayer"
	AthenaPreviewLayer.show();
	-- btimport "script/ui/purgatorychallenge/PurgatoryRankLayer"
	-- PurgatoryRankLayer.show();
end
--[[
	@des 	:创建线路图node
--]]
function createMapNode(p_index,p_position)
	--如果比已开放的地图多，则返回空
	if p_index > AthenaData.getPreviewNum() or p_index < 1 then
		return nil
	end

	local nodeSize = CCSizeMake(g_winSize.width,_gapHeight)

	--背景node
	local bgNode = CCNode:create()
	bgNode:setContentSize(nodeSize)
	bgNode:setAnchorPoint(ccp(0.5,0.5))
	bgNode:setPosition(p_position)
	_mainLayer:addChild(bgNode)
	local mapInfo = AthenaData.getTreeDBInfo(p_index)


	local mapType = mapInfo.map

	--路线图
	local routeSprite = CCSprite:create("images/athena/map/" .. mapType)
	routeSprite:setAnchorPoint(ccp(0.5,0.5))
	routeSprite:setPosition(nodeSize.width*0.5,nodeSize.height*395/710)
	routeSprite:setScale(g_fElementScaleRatio*0.95)
	bgNode:addChild(routeSprite,1,kRouteTag)

	local routeSize = routeSprite:getContentSize()

	local xmlSprite = XMLSprite:create("images/base/effect/" .. mapInfo.effect .. "/" .. mapInfo.effect)
	xmlSprite:setPosition(ccp(routeSize.width*0.5,routeSize.height*0.5))
	routeSprite:addChild(xmlSprite)

	local titleSprite = CCSprite:create("images/athena/title/" .. mapInfo.name)
	titleSprite:setAnchorPoint(ccp(0.5,0.5))
	titleSprite:setPosition(ccp(nodeSize.width*0.5,nodeSize.height*660/710))
	titleSprite:setScale(g_fElementScaleRatio)
	bgNode:addChild(titleSprite)

	--技能按钮层
	local skillBgMenu = BTSensitiveMenu:create()
	if(skillBgMenu:retainCount()>1)then
		skillBgMenu:release()
		skillBgMenu:autorelease()
	end
	skillBgMenu:setAnchorPoint(ccp(0,0))
	skillBgMenu:setPosition(ccp(0,0))
	skillBgMenu:setTouchPriority(kTouchPirority + 10)
	routeSprite:addChild(skillBgMenu,1,kMenuTag)

	local skillTable = AthenaData.getSkillTable(mapInfo.star_affix)

	for i = 1,#skillTable do
		local skillId = tonumber(skillTable[i])

		--技能按钮
		local skillMenuItem = AthenaUtils.getNormalSkillMenuItem(skillId,p_index)
		skillMenuItem:setAnchorPoint(ccp(0.5,0.5))
		skillMenuItem:registerScriptTapHandler(tapSkillCallBack)
		skillBgMenu:addChild(skillMenuItem,1,skillId)
	end

	--特殊技能框大小
	local secBgSize = CCSizeMake(585,135)
	--特殊技能
	local specialBgSprite = CCScale9Sprite:create(CCRectMake(30,30,15,10),"images/athena/ss_bg.png")
	specialBgSprite:setContentSize(secBgSize)
	specialBgSprite:setAnchorPoint(ccp(0.5,0.5))
	specialBgSprite:setPosition(ccp(nodeSize.width*0.5,nodeSize.height*85/710))
	specialBgSprite:setScale(g_fElementScaleRatio)
	bgNode:addChild(specialBgSprite,1,kSSTag)
	--特殊技能按钮层
	local SSBgMenu = CCMenu:create()
	SSBgMenu:setAnchorPoint(ccp(0,0))
	SSBgMenu:setPosition(ccp(0,0))
	SSBgMenu:setTouchPriority(kTouchPirority - 1)
	specialBgSprite:addChild(SSBgMenu,1,kMenuTag)
	local SSId = nil
	-- 技能类型
	local skillType = mapInfo.type
	if skillType == AthenaData.kNormaoSkillType or skillType == AthenaData.kAngrySkillType then
		SSId = AthenaData.getSSkillId(mapInfo)[1]
	else
		SSId = mapInfo.awake_ability
	end
	-- 特殊技能按钮回调
	local tapSSCallBack = function ( ... )
		require "script/ui/athena/SSInfoLayer"
		SSInfoLayer.showLayer(SSId,kTouchPirority - 10)
	end
	--特殊技能按钮
	local SSMenuItem = AthenaUtils.getSpecialSkillMenuItem(p_index)
	SSMenuItem:setAnchorPoint(ccp(0,1))
	SSMenuItem:setPosition(ccp(25,secBgSize.height - 10))
	SSMenuItem:registerScriptTapHandler(tapSSCallBack)
	SSBgMenu:addChild(SSMenuItem,1,SSId)	

	local itemSize = SSMenuItem:getContentSize()
	local SSNameString = AthenaData.getSSDBInfo(SSId,skillType).name
	--名字
	local SSNameLabel = CCRenderLabel:create(SSNameString,g_sFontName,21,1,ccc3(0,0,0),type_stroke)
	SSNameLabel:setColor(ccc3(255,0,0xe1))
	SSNameLabel:setAnchorPoint(ccp(0.5,1))
	SSNameLabel:setPosition(ccp(itemSize.width*0.5,-5))
	SSMenuItem:addChild(SSNameLabel)

	local SSOpenNeed = AthenaData.getUnlockSSInfo(p_index)
	local firstString
	if #SSOpenNeed >1 then
		firstString = GetLocalizeStringBy("zzh_1311")
	else
		firstString = GetLocalizeStringBy("zzh_1316")
	end

	local widthGap = 225
	local midPosX = secBgSize.width - widthGap
	local gapY = 25
	local paramTable = {
		width = widthGap*2, -- 宽度
        alignment = 2, -- 对齐方式  1 左对齐，2 居中， 3右对齐
        elements = {}
	}

	for i = 1,#SSOpenNeed do
		local lockInfo = SSOpenNeed[i]
		local skillInfo = AthenaData.getSkillDBInfo(lockInfo.skill)
		local tempTable = {
			type = "CCLabelTTF",              							
            text = skillInfo.name,                     
            font = g_sFontName,
            size = 21,
            color = HeroPublicLua.getCCColorByStarLevel(skillInfo.skillQuality),
		}
		local comaTable = {
			type = "CCLabelTTF",              							
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
		type = "CCLabelTTF",              							
        text = firstString,                     
        font = g_sFontName,
        size = 21,
        color = ccc3(0x00,0xff,0x18),
	}
	table.insert(paramTable.elements,firstLabelTable)
	local secTable = {
		type = "CCLabelTTF",              							
        text = GetLocalizeStringBy("zzh_1312",SSOpenNeed[1].lv),                     
        font = g_sFontName,
        size = 21,
        color = ccc3(0xff,0x00,0x00),
	}
	table.insert(paramTable.elements,secTable)
	local triTable = {
		type = "CCLabelTTF",              							
        text = GetLocalizeStringBy("zzh_1313"),                     
        font = g_sFontName,
        size = 21,
        color = ccc3(0x00,0xff,0x18),
	}
	table.insert(paramTable.elements,triTable)
	local unLockFirstTable = {
		type = "CCLabelTTF",              							
        text = GetLocalizeStringBy("zzh_1314"),                     
        font = g_sFontName,
        size = 21,
        color = ccc3(0x00,0xff,0x18),
	}
	table.insert(paramTable.elements,unLockFirstTable)
	local unlockNameTable = {
		type = "CCLabelTTF",              							
        text = SSNameString,                     
        font = g_sFontName,
        size = 21,
        color = ccc3(255,0,0xe1),
	}
	table.insert(paramTable.elements,unlockNameTable)
	if AthenaData.getNextTree(p_index) ~= nil then
		local commaTable = {
			type = "CCLabelTTF",              							
	        text = ",",                     
	        font = g_sFontName,
	        size = 21,
	        color = ccc3(0x00,0xff,0x18),
		}
		table.insert(paramTable.elements,commaTable)
	end

	local upNode = LuaCCLabel.createRichLabel(paramTable)
	if AthenaData.getNextTree(p_index) ~= nil then
		upNode:setAnchorPoint(ccp(0.5,1))
		upNode:setPosition(ccp(midPosX,secBgSize.height - gapY))
	else
		upNode:setAnchorPoint(ccp(0.5,0.5))
		upNode:setPosition(ccp(midPosX,secBgSize.height*0.5))
	end
	specialBgSprite:addChild(upNode)

	if AthenaData.getNextTree(p_index) ~= nil then
		local unlockFirstLabel = CCLabelTTF:create(GetLocalizeStringBy("zzh_1331"),g_sFontName,21)
		unlockFirstLabel:setColor(ccc3(0x00,0xff,0x18))

		local unlockNameLabel = CCLabelTTF:create(GetLocalizeStringBy("zzh_1312",mapInfo.level),g_sFontName,21)
		unlockNameLabel:setColor(ccc3(0xff,0x00,0x00))

		local unlockSecLabel = CCLabelTTF:create(GetLocalizeStringBy("zzh_1328"),g_sFontName,21)
		unlockSecLabel:setColor(ccc3(0x00,0xff,0x18))

		local downLabel = BaseUI.createHorizontalNode({unlockFirstLabel,unlockNameLabel,unlockSecLabel})
		downLabel:setAnchorPoint(ccp(0.5,0))
		downLabel:setPosition(ccp(midPosX,gapY))
		specialBgSprite:addChild(downLabel)
	end

	return bgNode
end

--[[
	@des 	:创建UI
--]]
function createUI()
	local initPage = AthenaData.getCacheCurPageNo()
	AthenaData.setCurPageNo(initPage)
	_curMapNo = initPage

	--创建背景UI
	createBgUI()

	--创建路线图node
	_leftNode = createMapNode(_curMapNo - 1,_ltPos)
	_middleNode = createMapNode(_curMapNo,_midPos)
	_rightNode = createMapNode(_curMapNo + 1,_rtPos)
end

--================================= Entrance =======================
--[[
	@des 	:入口函数
--]]
function createLayer()
	init()

	--初始化剩余物品信息
	AthenaData.initRemainItemInfo()

	--菜单栏大小
	local menuSize = MenuLayer.getLayerContentSize()
	local menuHeight = menuSize.height

	_gapHeight = g_winSize.height - kGapHeight*g_fElementScaleRatio - menuHeight*g_fScaleX

	local posY = menuHeight*g_fScaleX + _gapHeight*0.5

	_ltPos = ccp(-g_winSize.width*0.5,posY)
	_midPos = ccp(g_winSize.width*0.5,posY)
	_rtPos = ccp(g_winSize.width*1.5,posY)

	_mainLayer = CCLayer:create()
	_mainLayer:registerScriptHandler(onNodeEvent)

	local bgSprite = CCSprite:create("images/destney/destney_bg.png")
	bgSprite:setAnchorPoint(ccp(0.5,1))
	bgSprite:setPosition(ccp(g_winSize.width*0.5,g_winSize.height))
	bgSprite:setScale(g_fBgScaleRatio)
	_mainLayer:addChild(bgSprite)

	AthenaService.getAthenaInfo(createUI)

	MainScene.setMainSceneViewsVisible(true,false,false)
	MainScene.changeLayer(_mainLayer,"AthenaMainLayer")
end