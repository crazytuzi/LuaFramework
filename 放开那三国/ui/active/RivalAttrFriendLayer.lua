-- FileName: RivalAttrFriendLayer.lua 
-- Author: DJN 
-- Date: 15-3-20
-- Purpose: 查看对方阵容 第二套小伙伴主界面 


module("RivalAttrFriendLayer", package.seeall)

-- require "script/ui/formation/secondfriend/SecondFriendService"
-- require "script/ui/formation/secondfriend/SecondFriendData"
require "script/ui/active/RivalInfoData"
require "script/model/utils/UnionProfitUtil"
require "script/ui/tip/AnimationTip"
require "script/model/affix/SecondFriendAffixModel"

local _bgLayer 							= nil
local _topBg 							= nil
local _bottomBg 						= nil
local _addAffixNumTab 					= {}   	-- 小伙伴增加的最终属性label
local _heroTableView 					= nil
local _cellSize 						= nil
local _bottomAllSp 						= nil

local _addAffixId 						= nil  	-- 小伙伴增加的最终属性组
local _allNum 							= nil  	-- 小伙伴总数
local _curIndex 						= nil  	-- 当前居中index
local _tableViewIsMoving  				= false	-- 是否在滑动
local _is_handle_touch 					= false -- 是否触摸
local _drag_began_x 					= nil
local _touch_began_x 					= nil
local _displayHid 						= nil
local _displayPos 						= nil
local _allAddAffixTab 					= nil
local _nodeSize 							= nil
---------------------------------- 常量 --------------------------------
local _bgLayerTouchPriority 			= -1090
local _addFontPosX = {0.1,0.6,0.1,0.6}
local _addFontPosY = {0.55,0.55,0.35,0.35}

local POS_TAG = 1234 -- 位置的tag

--[[
	@des 	:初始化
--]]
function init( ... )
	_bgLayer 							= nil
	_topBg 								= nil
	_bottomBg 							= nil
	_addAffixNumTab 					= {}
	_heroTableView 						= nil
	_cellSize 							= nil
	_bottomAllSp 						= nil

	_addAffixId 						= nil 
	_allNum 							= nil
	_tableViewIsMoving  				= false
	_is_handle_touch 					= false
	_drag_began_x 						= nil
	_touch_began_x 						= nil
	_displayHid 						= nil
	_displayPos 						= nil
	_allAddAffixTab 					= nil
	_nodeSize 							= nil
end

--[[
	@des 	:数据处理
--]]
function initData( ... )
	-- 小伙伴增加的最终属性数组
	_addAffixId = RivalInfoData.getSecFriendAddAttrTab()
	print("_addAffixId=")
	print_t(_addAffixId)
	-- 小伙伴总个数
	_allNum = RivalInfoData.getSecFriendAllNum()


	-- 增加的所有属性值
	_allAddAffixTab = RivalInfoData.getTotalAffix()

end

------------------------------------------------------------------------ 事件回调 --------------------------------------------------------------


--[[
 	@desc	 回调onEnter和onExit事件
--]]
function onNodeEvent( event )
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, _bgLayerTouchPriority, false)
		_bgLayer:setTouchEnabled(true)

	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
	end
end

--[[
	@des 	:touch事件处理
--]]
function onTouchesHandler(event, x, y)
	if _tableViewIsMoving == true then
		_is_handle_touch = false
		return true
	end
	local position = _heroTableView:convertToNodeSpace(ccp(x, y))

    if event == "began" then
    	print("began==========")
        local rect = _heroTableView:boundingBox()
        if rect:containsPoint(_heroTableView:getParent():convertToNodeSpace(ccp(x, y))) then
            _drag_began_x = _heroTableView:getContentOffset().x
            _touch_began_x = position.x
            beginRefreshHeroCell()
            _is_handle_touch = true
        else
            _is_handle_touch = false
        end
        local offset = _heroTableView:getContentOffset()
        return true
    elseif event == "moved" then
    	print("moved==========")
        if _is_handle_touch == true then
            local distance = position.x - _touch_began_x
            local offsetDistance = _heroTableView:getContentOffset().x - _drag_began_x
       		if offsetDistance > 0 and offsetDistance > _cellSize.width then
       			return
       		elseif offsetDistance < 0 and offsetDistance < -_cellSize.width then
       			return
       		end
       		local offset = _heroTableView:getContentOffset()
       		offset.x = _drag_began_x + distance
       		local minX = -(_allNum - 1) * _cellSize.width
            if offset.x < minX then
                offset.x = minX
            elseif offset.x > 0 then
            	offset.x = 0
            end
            _heroTableView:setContentOffset(offset)
        end
    elseif event == "ended" or event == "cancelled" then
    print("ended==========")
        if _is_handle_touch == true then
            local drag_ended_x = _heroTableView:getContentOffset().x
            local touchEndPosition = _heroTableView:getParent():convertToNodeSpace(ccp(x, y))
            local drag_distance = touchEndPosition.x - _touch_began_x
            if(drag_distance > 100 )then 
            	_curIndex = _curIndex - 1
            elseif(drag_distance < -100)then
                _curIndex = _curIndex +1
            end
            if(_curIndex > _allNum)then
            	_curIndex = _allNum
        	elseif(_curIndex < 1)then
        		_curIndex = 1
        	end
            local offset = _heroTableView:getContentOffset()
            offset.x = -(_curIndex - 1) * _cellSize.width
            _tableViewIsMoving = true
            local array = CCArray:create()
            array:addObject(CCMoveTo:create(0.15, offset))
            local container = _heroTableView:getContainer()
            local endCallFunc = function()
            	_heroTableView:setContentOffset(offset)
             
            	refreshHeroCell()
            	refreshBottomUI()
            	endRefreshHeroCell()
                _tableViewIsMoving = false
            end
            array:addObject(CCCallFunc:create(endCallFunc))
            container:runAction(CCSequence:create(array))
            print("cellcount ======", container:getChildren():count())
        end
    end
end

--[[
 	@desc 	移动时刷新
--]]
function beginRefreshHeroCell( ... )
	print("beginRefreshHeroCell====")
	--schedule(_topBg, refreshUI, 1 / 60)
	schedule(_topBg, refreshHeroCell, 1 / 60)
end

--[[
 	@desc 	清除刷新
--]]
function endRefreshHeroCell( ... )
	_topBg:cleanup()
end

------------------------------------------------------------------------ 创建ui --------------------------------------------------------------
--[[
	@des 	:刷新下边UI
--]]
function refreshBottomUI() 
	if( tolua.cast( _bottomAllSp, "CCSprite") == nil )then 
		return
	end

	if _curIndex == 0 or _curIndex == _allNum + 1 then
		return
	end
	-- 清除所有
	_bottomAllSp:removeAllChildrenWithCleanup(true)

	-- 当前hid
	local hid = -1
	local htid = -1
	local attr = {} --这个小伙伴给上阵武将的加成属性
	local curPosDataInDb = RivalInfoData.getDBdataByIndex(_curIndex)
	local curPosData = RivalInfoData.getSecondFriendInfoByPos(_curIndex)
	if( table.isEmpty(curPosData ) == false )then
		hid = tonumber(curPosData.hid)
		htid = tonumber(curPosData.htid)
		attr = curPosData.attr
    end
	if(hid > 0)then
		-- 羁绊
		local jibanSp = CCSprite:create("images/secondfriend/jiban.png")
		jibanSp:setAnchorPoint(ccp(0.5, 1))
	 	jibanSp:setPosition(ccp(170,_bottomAllSp:getContentSize().height-5))
	 	_bottomAllSp:addChild(jibanSp)
	 	-- 羁绊坐标
	 	local posX = {15,117,222,15,117,222}
	 	local posY = {54,54,54,20,20,20}
	 	-- 羁绊数据
	 	local jibanData = RivalInfoData.getAttrUnionInfo(hid,htid)
	 	for i=1, #jibanData do
	 		local dbData = UnionProfitUtil.getUnionDBInfoByUid( jibanData[i].unionId )
	 		local jibanName = CCRenderLabel:create(dbData.union_arribute_name, g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			jibanName:setColor(ccc3(0xff,0xff,0xff))
			jibanName:setAnchorPoint(ccp(0, 0))
			jibanName:setPosition(ccp(posX[i], posY[i]))
			_bottomAllSp:addChild(jibanName)
			if(jibanData[i].isOpen)then
				jibanName:setColor(ccc3(0xff,0xae,0x6d))
			end
	 	end
        ----------------------------------------------------------
	 	-- 属性
	 	local attrSp = CCSprite:create("images/secondfriend/shuxing.png")
		attrSp:setAnchorPoint(ccp(0.5, 1))
	 	attrSp:setPosition(ccp(518,_bottomAllSp:getContentSize().height-5))
	 	_bottomAllSp:addChild(attrSp)

	 	-- 属性显示
	 	local s_posX = {547,547,518}
	 	local s_posY = {75,47,17}
	 	--local addAttrTab = RivalInfoData.getOfferAffixByHid( hid )
	 	--local addAttrTab = attr
	 	local index = 0
	 	print_t(attr)
	 	for k_affxid,v_num in pairs(attr) do
	 		index = index + 1
	 		local attrInfo = RivalInfoData.getAffixAttrInfoById(k_affxid)
	 		local tipFont = CCRenderLabel:create(GetLocalizeStringBy("lic_1498",attrInfo.godarmName), g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			tipFont:setColor(ccc3(0xff,0xff,0xff))
			tipFont:setAnchorPoint(ccp(1, 0.5))
			tipFont:setPosition(ccp(s_posX[index], s_posY[index]))
			_bottomAllSp:addChild(tipFont)
			local tipNumFont = CCRenderLabel:create(v_num, g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			tipNumFont:setColor(ccc3(0x00,0xff,0x18))
			tipNumFont:setAnchorPoint(ccp(0, 0.5))
			tipNumFont:setPosition(ccp(tipFont:getPositionX()+5, tipFont:getPositionY()))
			_bottomAllSp:addChild(tipNumFont)
	 	end
	 	-- (100%武将攻击值)
	 	-- local addDBData = RivalInfoData.getSecFriendAddAttrByPos(_curIndex)
	 	local percentage = RivalInfoData.getStageUpAffixPercentageByPos(_curIndex)
		-- print_t(addDBData)
		-- local tipFont2 = CCRenderLabel:create(GetLocalizeStringBy("lic_1499",tostring(tonumber(addDBData[1][3])/100), curPosDataInDb.name ), g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		local tipFont2 = CCRenderLabel:create(GetLocalizeStringBy("lic_1499",percentage, curPosDataInDb.name ), g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		tipFont2:setColor(ccc3(0x00,0xff,0x18))
		tipFont2:setAnchorPoint(ccp(0.5, 0.5))
		tipFont2:setPosition(s_posX[index+1], s_posY[index+1])
		_bottomAllSp:addChild(tipFont2)

	else
		-- 没有武将显示提示
	    local textInfo = {
	     		width = 520, -- 宽度
		        alignment = 2, -- 对齐方式  1 左对齐，2 居中， 3右对齐
		        labelDefaultFont = g_sFontPangWa,      -- 默认字体
		        labelDefaultSize = 21,          -- 默认字体大小
		        linespace = 10, -- 行间距
		        elements =
		        {	
		            {
		            	type = "CCRenderLabel", 
		            	text = curPosDataInDb.description,
		            	color = ccc3(0xff,0xff,0xff)
		        	}
		        }
		 	}
	 	local desFont = LuaCCLabel.createRichLabel(textInfo)
	 	desFont:setAnchorPoint(ccp(0.5, 0.5))
	 	desFont:setPosition(ccp(_bottomAllSp:getContentSize().width*0.5,_bottomAllSp:getContentSize().height*0.5))
	 	_bottomAllSp:addChild(desFont)
	end
end

--[[
	@des 	:开启状态有武将
	@param 	:p_index: 位置 p_hid:英雄hid
	@return :sprite
--]]
function createOpenHaveHeroState( p_index, p_hid )
	local heroInfoFromBack = RivalInfoData.getSecondFriendInfoByPos(p_index)
	local retSprite = CCSprite:create()
	retSprite:setContentSize(CCSizeMake(213,200))
	--local heroInfo = HeroUtil.getHeroInfoByHid(p_hid)
	local heroInfo = HeroUtil.getHeroLocalInfoByHtid(heroInfoFromBack.htid)
	-- 全身像
	-- 新增幻化id, add by lgx 20160928
	local turnedId = tonumber(heroInfoFromBack.turned_id)
	local bodyOffset = HeroUtil.getHeroBodySpriteOffsetByHTID(heroInfoFromBack.htid,nil,turnedId)
	local cardSprite = HeroUtil.getHeroBodySpriteByHTID( heroInfoFromBack.htid, nil, nil, turnedId )
	cardSprite:setAnchorPoint(ccp(0.5,0))
	cardSprite:setPosition(ccp( retSprite:getContentSize().width*0.5, -bodyOffset - 50))
	retSprite:addChild(cardSprite)
	cardSprite:setScale(0.7)

	local nameBg = CCScale9Sprite:create("images/common/bg/bg_9s_2.png")
	nameBg:setPreferredSize(CCSizeMake(258, 37))
	nameBg:setAnchorPoint(ccp(0.5, 0.5))
	nameBg:setPosition(ccp(retSprite:getContentSize().width * 0.5, -30))
	retSprite:addChild(nameBg,10)
	-- nameBg:setScale(1.5)

	local fontTab = {}
    fontTab[1] = CCRenderLabel:create("Lv." .. heroInfoFromBack.level .. " ", g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    fontTab[1]:setColor(ccc3(0xff,0xf6,0x00))
    fontTab[2] = CCRenderLabel:create(heroInfo.name .. " ", g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    local nameColor = HeroPublicLua.getCCColorByStarLevel(heroInfo.star_lv)
    fontTab[2]:setColor(nameColor)
     -- 进阶次数
	local evolveDes = "+0"
	if heroInfoFromBack.evolve_level then
    	if tonumber(heroInfo.potential) <= 5 then 
    		evolveDes = "+" .. heroInfoFromBack.evolve_level
    	else
    		evolveDes = heroInfoFromBack.evolve_level .. GetLocalizeStringBy("zzh_1159")
    	end
    end
    fontTab[3] = CCRenderLabel:create( evolveDes, g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    fontTab[3]:setColor(ccc3(0x00,0xff,0x18))
    local nameFont = BaseUI.createHorizontalNode(fontTab)
    nameFont:setAnchorPoint(ccp(0.5,0.5))
	nameFont:setPosition(ccp(nameBg:getContentSize().width*0.5,nameBg:getContentSize().height*0.5))
	nameBg:addChild(nameFont)

	local curPosData = RivalInfoData.getDBdataByIndex(p_index)
	-- 属性特效
	local animSprite = CCLayerSprite:layerSpriteWithName( CCString:create("images/secondfriend/effect/" .. curPosData.attributeEffect ), -1,CCString:create(""))
	animSprite:setAnchorPoint(ccp(0.5, 0.5))
	animSprite:setPosition(ccp(retSprite:getContentSize().width*0.5,30))
	retSprite:addChild(animSprite)
	animSprite:setScale(0.4)

	return retSprite
end



--[[
	@des 	:创建开启无英雄状态
	@param 	:p_index: 位置
	@return :sprite
--]]
function createOpenState( p_index )
	local retSprite = CCSprite:create()
	retSprite:setContentSize(CCSizeMake(213,200))

	local scaleNum = 1

	local posData = RivalInfoData.getDBdataByIndex(p_index)

	-- 属性图片
	local markSp = CCSprite:create("images/secondfriend/mark/" .. posData.picture)
	markSp:setAnchorPoint(ccp(0.5,0.5))
	markSp:setPosition(ccpsprite(0.5, 0.6, retSprite))
	retSprite:addChild(markSp)
	markSp:setScale(0.6)

	return retSprite
end

--[[
	@des 	:刷新小伙伴位置
--]]
function refreshHeroCell( ... )
	if _heroTableView ~= nil then
		local container = _heroTableView:getContainer()
		local cells = container:getChildren()
		local mainIndex = 0
		local maxScale = 0
		for i = 0, cells:count() - 1 do
			local cell = tolua.cast(cells:objectAtIndex(i), "CCTableViewCell")
			local hero = cell:getChildByTag(POS_TAG)
			if hero ~= nil then
				local position = cell:convertToWorldSpace(ccp(hero:getPositionX(), hero:getPositionY()))
				position = _bgLayer:convertToNodeSpace(position)
				local scale = 1 - math.abs(_bgLayer:getContentSize().width * 0.5 - position.x) / _bgLayer:getContentSize().width 
				hero:setScale(scale)
				hero:setPositionY((math.abs(_bgLayer:getContentSize().width * 0.5 - position.x) / _bgLayer:getContentSize().width * 0.5) * 400)
				if scale > maxScale then
					mainIndex = cell:getIdx()
					maxScale = scale
				end
				container:reorderChild(cell, hero:getScale() * 10)
			end		
		end
		for i=0, cells:count() - 1 do
			local cell = tolua.cast(cells:objectAtIndex(i), "CCTableViewCell")
			local hero = tolua.cast(cell:getChildByTag(POS_TAG), "CCSprite")
			if hero ~= nil then
				if cell:getIdx() ~= mainIndex then
					hero:setColor(ccc3(0xad, 0xad, 0xad))
				else
					hero:setColor(ccc3(0xff, 0xff, 0xff))
				end
			end
		end
		-- if _curIndex ~= mainIndex and mainIndex ~= 0 and mainIndex ~= _allNum + 1 then
  --   		_curIndex = mainIndex
  --   		print("heihei-===", _curIndex)
  --   		refreshBottomUI()
		-- end
	end
end

--[[
	@des 	:获得属性的信息
	@param 	:p_index: p_index
	@return :cell
--]]
function createHeroCell( p_index )
	local cell = CCTableViewCell:create()
	cell:setContentSize(_cellSize)
	if p_index == 0 or p_index == _allNum + 1 then
		return cell
	end
	--local node = CCLayerColor:create(ccc4(100, 0, 0, 130))
	local node = CCSprite:create()
	cell:addChild(node)
	node:setCascadeColorEnabled(true)
	node:setTag(POS_TAG)
	node:setContentSize(_nodeSize)
	node:ignoreAnchorPointForPosition(false)
	node:setAnchorPoint(ccp(0.5, 0))
	node:setPosition(ccp(cell:getContentSize().width*0.5, 0))

	local stage = CCSprite:create("images/olympic/kingChair.png")
	node:addChild(stage)
	stage:setAnchorPoint(ccp(0.5, 0))
	stage:setPosition(ccp(node:getContentSize().width * 0.5, 0))

	local curPosData = RivalInfoData.getDBdataByIndex(p_index)
	-- 台子特效
	local animSprite = CCLayerSprite:layerSpriteWithName( CCString:create("images/secondfriend/effect/" .. curPosData.methodEffect ), -1,CCString:create(""))
	animSprite:setAnchorPoint(ccp(0.5, 0.5))
	animSprite:setPosition(ccp(stage:getContentSize().width*0.5,stage:getContentSize().height*0.87))
	stage:addChild(animSprite)
	animSprite:setScale(0.7)

	local onStageSp = nil
	local isOpen = RivalInfoData.getIsOpenByPos( p_index )
	if(isOpen)then
		local hid = RivalInfoData.getSecondFriendHidByPos(p_index)
		if(hid > 0)then
			-- 开启有英雄
			onStageSp = createOpenHaveHeroState(p_index,hid)
		else
			-- 开启无英雄
			onStageSp =createOpenState( p_index )
		end
	else
		-- 未开启
		--onStageSp = createCloseState(p_index)
		onStageSp =createOpenState( p_index )
	end
	onStageSp:setAnchorPoint(ccp(0.5, 0))
	onStageSp:setPosition(ccp(node:getContentSize().width * 0.5, 95))
	node:addChild(onStageSp)
	-- 助战位等级富文本
	local extraLevel = RivalInfoData.getAttrExtraLevelByPos(p_index)
	if tonumber(extraLevel) >= 0 then
	    local richInfo = {
	        linespace = 2, -- 行间距
	        alignment = 1, -- 对齐方式  1 左对齐，2 居中， 3右对齐
	        lineAlignment = 2, -- 当前行在竖直方向上的对齐方式 1，下对齐， 2，居中， 3，上对齐
	        labelDefaultFont = g_sFontPangWa,
	        labelDefaultColor = ccc3(0x00,0xff,0x18),
	        labelDefaultSize = 23,
	        defaultType = "CCRenderLabel",
	        elements =
	        {
	            {
	                type = "CCRenderLabel",
	                newLine = false,
	                text = extraLevel,
	                color = ccc3(0xff,0xf6,0x00),
	                renderType = 2,-- 1 描边， 2 投影
	            },
	            {
	                type = "CCRenderLabel",
	                newLine = false,
	                text = GetLocalizeStringBy("syx_1073"),
	                renderType = 2,-- 1 描边， 2 投影
	            },
	        }
	    }
	    require "script/libs/LuaCCLabel"
	    local richLabel = LuaCCLabel.createRichLabel(richInfo)
	    richLabel:setAnchorPoint(ccp(0.5, 0))
	    richLabel:setPosition(ccp(onStageSp:getContentSize().width*0.5,-80))
	    onStageSp:addChild(richLabel)
	end
	return cell
end

--[[
	@des 	:创建中间小伙伴tableView
--]]
function createHeroTableView( ... )
	local nodeHeight = _bgLayer:getContentSize().height - _topBg:getContentSize().height - _bottomBg:getContentSize().height
	_cellSize = CCSizeMake(math.ceil(_bgLayer:getContentSize().width / 3), nodeHeight + 100)
	_nodeSize = CCSizeMake(_cellSize.width, nodeHeight)

	local numberOfCells = _allNum + 2
    local h = LuaEventHandler:create(function(fn, table, a1, a2)    --创建
        local r
        if fn == "cellSize" then
            r = _cellSize
        elseif fn == "cellAtIndex" then
            r = createHeroCell(a1)
        elseif fn == "numberOfCells" then
            r = numberOfCells
        elseif fn == "cellTouched" then
        elseif (fn == "scroll") then
        end
        return r
    end)
    local x = 1
    _heroTableView = LuaTableView:createWithHandler(h, CCSizeMake(_bgLayer:getContentSize().width, _cellSize.height))
    _bgLayer:addChild(_heroTableView)
    _heroTableView:setAnchorPoint(ccp(0.5, 0))
    _heroTableView:setPosition(ccp(_bgLayer:getContentSize().width * 0.5, _bottomBg:getContentSize().height))
    _heroTableView:ignoreAnchorPointForPosition(false)
    _heroTableView:setDirection(kCCScrollViewDirectionHorizontal)
    _heroTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    _heroTableView:setTouchPriority(_bgLayerTouchPriority - 10)
    _heroTableView:setTouchEnabled(false)

    _curIndex = 1
	-- 刷新小伙伴cell
    refreshHeroCell()
    -- 刷新下边ui
	refreshBottomUI()
end

function refreshUI( ... )
	refreshHeroCell()
	refreshBottomUI()
end

--[[
	@des 	:创建中间UI
--]]
function createMiddleUI()

	-- 创建小伙伴tableView
	createHeroTableView()

end

--[[
	@des 	:创建下边UI
--]]
function createBottomUI()
	-- 下边背景
	local fullRect = CCRectMake(0,0,75,75)
    local insetRect = CCRectMake(30,30,15,10)
    _bottomBg = CCScale9Sprite:create("images/common/bg/astro_btnbg.png",fullRect, insetRect)
    _bottomBg:setContentSize(CCSizeMake(634,125))
	_bottomBg:setAnchorPoint(ccp(0.5,0))
	_bottomBg:setPosition(ccp(_bgLayer:getContentSize().width*0.5,0))
	_bgLayer:addChild(_bottomBg,10)
	--_bottomBg:setScale(g_fScaleX)

	-- 空白sp
	_bottomAllSp = CCSprite:create()
	_bottomAllSp:setContentSize(_bottomBg:getContentSize())
	_bottomAllSp:setAnchorPoint(ccp(0.5,0.5))
	_bottomAllSp:setPosition(ccp(_bottomBg:getContentSize().width*0.5,_bottomBg:getContentSize().height*0.5))
	_bottomBg:addChild(_bottomAllSp)
end

--[[
	@des 	:创建上边UI
--]]
function createTopUI()
	-- 上边背景
	_topBg = CCSprite:create("images/secondfriend/top_bg.png")
	_topBg:setAnchorPoint(ccp(0.5,1))
	_topBg:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height))
	_bgLayer:addChild(_topBg,20)
	--_topBg:setScale(g_fScaleX)

	-- 标题
	local titleSp = CCSprite:create("images/secondfriend/title.png")
	titleSp:setAnchorPoint(ccp(0.5,1))
	titleSp:setPosition(ccp(_topBg:getContentSize().width*0.5,_topBg:getContentSize().height*0.86))
	_topBg:addChild(titleSp)

	-- 增加属性名字 +数值
	for i=1, #_addAffixId do 
		local attrInfo = RivalInfoData.getAffixAttrInfoById(_addAffixId[i])
		local attrLabel = CCRenderLabel:create(attrInfo.godarmName, g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		attrLabel:setColor(ccc3(0x00,0xff,0x18))
		attrLabel:setAnchorPoint(ccp(0, 0.5))
		attrLabel:setPosition(ccp(_topBg:getContentSize().width*_addFontPosX[i],_topBg:getContentSize().height*_addFontPosY[i]))
		_topBg:addChild(attrLabel)
		local addNum = _allAddAffixTab[tonumber(_addAffixId[i])] or 0
		local attrNumLabel = CCRenderLabel:create("+" .. addNum, g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		attrNumLabel:setColor(ccc3(0xff,0xff,0xff))
		attrNumLabel:setAnchorPoint(ccp(0, 0.5))
		attrNumLabel:setPosition(ccp(attrLabel:getPositionX()+attrLabel:getContentSize().width+15, attrLabel:getPositionY()))
		_topBg:addChild(attrNumLabel)

		-- 保存下attrNumLabel
		_addAffixNumTab[tostring(_addAffixId[i])] = attrNumLabel
	end

end

--[[
	@des 	:创建第二套小伙伴界面
	@param 	:p_width:layer宽, p_height:layer高 p_display_hid展示的英雄hid p_showSecondFriendPos:展示的位置
	@return :
--]]
function createSecondFriendLayer( p_width, p_height)
	-- 初始化
	init()

	_bgLayer = CCLayer:create()
	-- _bgLayer = CCLayerColor:create(ccc4(255,0,0,70))
	_bgLayer:setContentSize(CCSizeMake(p_width,p_height))
    if(table.isEmpty(RivalInfoData.getAttrFriendInfo()) == false)then 
        _bgLayer:registerScriptHandler(onNodeEvent)
		-- 初始化数据
		initData()
		
		-- 创建上边ui
		createTopUI()

		-- 创建下边ui
		createBottomUI()

		-- 创建中间ui
		createMiddleUI()
	else
		local emptyBg = CCSprite:create("images/formation/rival_noAttrFriend.png")
		emptyBg:setAnchorPoint(ccp(0.5,0.5))
		emptyBg:setPosition(ccp(p_width*0.5,p_height*0.5))
		_bgLayer:addChild(emptyBg)
	end

	return _bgLayer
end












  