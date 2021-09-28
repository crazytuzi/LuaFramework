-- FileName: SecondFriendLayer.lua 
-- Author: licong 
-- Date: 15-3-3 
-- Purpose: 第二套小伙伴主界面 


module("SecondFriendLayer", package.seeall)

require "script/ui/formation/secondfriend/SecondFriendService"
require "script/ui/formation/secondfriend/SecondFriendData"
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
local _myScale 							= nil

local _enhanceBtn 						= nil
---------------------------------- 常量 --------------------------------
local _bgLayerTouchPriority 			= -200
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
	_myScale 							= nil

	_enhanceBtn 						= nil
end

--[[
	@des 	:数据处理
--]]
function initData( ... )
	-- 小伙伴增加的最终属性数组
	_addAffixId = SecondFriendData.getSecFriendAddAttrTab()
	print("_addAffixId=")
	print_t(_addAffixId)
	-- 小伙伴总个数
	_allNum = SecondFriendData.getSecFriendAllNum()

	-- cellSize
	_cellSize = CCSizeMake(math.ceil(_bgLayer:getContentSize().width / 3), 400 * MainScene.elementScale)

	-- 增加的所有属性值
	_allAddAffixTab = SecondFriendAffixModel.getAffixByHid()
end

------------------------------------------------------------------------ 事件回调 --------------------------------------------------------------
--[[
 	@desc 	:得到提示文案 
 	@param 	:p_needData, p_index
--]]
function getTipStr( p_needData, p_index )
	local str = ""
	local needConut,needLv,isHave = SecondFriendData.getOpenLv(p_index)
	if(isHave == false)then
		str = str .. GetLocalizeStringBy("lic_1503",tostring(needConut),tostring(needLv)) .. "," 
	end
	for k,v in pairs(p_needData) do
		if(v.costType == 1)then
			-- 金币
			str = str .. GetLocalizeStringBy("lic_1504",tostring(v.costNum))  .. ","
		elseif(v.costType == 2)then
			-- 银币
			str = str .. GetLocalizeStringBy("lic_1505",tostring(v.costNum)) .. ","
		elseif(v.costType == 3)then
			-- 物品
			str = str .. GetLocalizeStringBy("lic_1506",tostring(v.costNum)) .. ","
		end
	end
	return str
end

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
        if _is_handle_touch == true then
            local drag_ended_x = _heroTableView:getContentOffset().x
            local touchEndPosition = _heroTableView:getParent():convertToNodeSpace(ccp(x, y))
            local drag_distance = touchEndPosition.x - _touch_began_x
            local offset = _heroTableView:getContentOffset()
            offset.x = -(_curIndex - 1) * _cellSize.width
            _tableViewIsMoving = true
            local array = CCArray:create()
            array:addObject(CCMoveTo:create(0.15, offset))
            local container = _heroTableView:getContainer()
            local endCallFunc = function()
            	_heroTableView:setContentOffset(offset)

            	refreshHeroCell()
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
	schedule(_topBg, refreshHeroCell, 1 / 60)
end

--[[
 	@desc 	清除刷新
--]]
function endRefreshHeroCell( ... )
	_topBg:cleanup()
end

--[[
 	@desc 	点击事件
--]]
function clickItemCallFun( tag, sender )
	print("clickItemCallFun tag ==>",tag)

	if(tag ~= _curIndex)then 
		return
	end

	local isOpen = SecondFriendData.getIsOpenByPos( tag )
	if( isOpen )then
		-- 已开启
		local hid = SecondFriendData.getSecondFriendHidByPos(tag)
		if(hid > 0)then
			-- 开启有英雄
			-- 显示武将信息 （带有 更换小伙伴 和 卸下 按钮的界面）
			require "script/ui/hero/HeroInfoLayer"
			require "script/ui/hero/HeroPublicLua"
			local data = HeroPublicLua.getHeroDataByHid(hid)
			local tArgs = {}
			tArgs.fnCreate = dischargeCallBackFun
			tArgs.reserved = hid
			tArgs.reserved2 = tag
			tArgs.needChangeSecFriend=true
			data.addPos = HeroInfoLayer.kFormationPos
			MainScene.changeLayer(HeroInfoLayer.createLayer(data, tArgs), "HeroInfoLayer")
		else
			-- 开启无英雄
			require "script/ui/formation/ChangeOfficerLayer"
			local changeOfficerLayer = ChangeOfficerLayer.createLayer(tag, nil,nil,true)
			require "script/ui/main/MainScene"
			MainScene.changeLayer(changeOfficerLayer, "changeOfficerLayer")
		end
	else
		-- 未开启
		local isCanOpen,needType = SecondFriendData.getIsCanOpenByPos(tag)

		if(isCanOpen == false)then
			local tipStr = getTipStr(needType,tag)
			AnimationTip.showTip(GetLocalizeStringBy("lic_1497",tipStr))
			return
		end
		-- 满足开启条件 二次确认开启

		local yesOpenCallBack = function ( ... )
			-- 发请求
			openPosService( tag )
		end

		-- 您确定要开启该位置吗?
	    local textInfo = {
	     		width = 400, -- 宽度
		        alignment = 2, -- 对齐方式  1 左对齐，2 居中， 3右对齐
		        labelDefaultFont = g_sFontName,      -- 默认字体
		        labelDefaultSize = 25,          -- 默认字体大小
		        labelDefaultColor = ccc3(0x78, 0x25, 0x00),
		        linespace = 10, -- 行间距
		 	}
		 	textInfo.elements = {}
		local needData = SecondFriendData.getOpenCost(tag)
		local iconArr = { "gold.png", "coin.png", "xiaoqi.png" } 
		local nameArr = {GetLocalizeStringBy("lic_1508"),GetLocalizeStringBy("lic_1509"),GetLocalizeStringBy("lic_1510")}
		for i=1,#needData do
			local tab1 = {}
			tab1.type = "CCSprite"
	        tab1.image = "images/common/" .. iconArr[ tonumber(needData[i].costType) ] 
	        table.insert(textInfo.elements, tab1)
	       	local tab2 = {}
			tab2.type = "CCLabelTTF"
	        tab2.text =  nameArr[tonumber(needData[i].costType)] .. needData[i].costNum .. " "
	       	tab2.color = ccc3(0x78,0x25,0x00)
	       	table.insert(textInfo.elements, tab2)
		end

	 	local tipNode = GetLocalizeLabelSpriteBy_2("lic_1507",textInfo)
	 	-- local tipNode =  LuaCCLabel.createRichLabel(textInfo)
	 	require "script/ui/tip/TipByNode"
		TipByNode.showLayer(tipNode,yesOpenCallBack,CCSizeMake(500,360))
	end
end

--[[
 	@des 	:开启位置请求
	@param 	:p_index
	@return :
--]]
function openPosService( p_index )
	local nextCallFun = function ()
		-- 扣消耗物品
		local costTab = SecondFriendData.getOpenCost(p_index)
		for k,v in pairs(costTab) do
			if(v.costType == 1)then
				-- 金币
				UserModel.addGoldNumber(-v.costNum)
			elseif(v.costType == 2)then
				-- 银币
				UserModel.addSilverNumber(-v.costNum)
			elseif(v.costType == 3)then
				-- 物品
			end
			--  刷新Ui
			_heroTableView:updateCellAtIndex(_curIndex)

			refreshHeroCell()

			_enhanceBtn:setVisible(true)
		end
	end
	-- 发请求
	SecondFriendService.openAttrExtra(p_index, nextCallFun)
end

--[[
	@des 	:卸下回调
	@param 	: p_hid英雄hid, position:位置
	@return :
--]]
function dischargeCallBackFun( p_hid, p_position )
	local nextCallFun = function ()
		-- 更新羁绊
		require "script/model/utils/UnionProfitUtil"
		UnionProfitUtil.refreshUnionProfitInfo()
		-- 创建阵容界面
		local laye = FormationLayer.createLayer(nil, false, nil, nil,nil,nil,true,p_position)
		MainScene.changeLayer(laye,"formationLayer")

	end
	SecondFriendService.delAttrExtra(p_hid,p_position,nextCallFun)
end
------------------------------------------------------------------------ 创建ui --------------------------------------------------------------
--[[
	@des 	:刷新下边UI
--]]
function refreshTopUI() 
	if( tolua.isnull( _topBg ) )then 
		return
	end
	_allAddAffixTab = SecondFriendAffixModel.getAffixByHid()
	for k_affxid,v_label in pairs(_addAffixNumTab) do 
		local addNum = _allAddAffixTab[k_affxid] or 0
		v_label:setString("+" .. addNum)
	end
end

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
	local hid = SecondFriendData.getSecondFriendHidByPos(_curIndex)
	local curPosData = SecondFriendData.getDBdataByIndex(_curIndex)
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
	 	local jibanData = UnionProfitUtil.getHeroUnionIfoByHid(hid)
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

	 	-- 属性
	 	local attrSp = CCSprite:create("images/secondfriend/shuxing.png")
		attrSp:setAnchorPoint(ccp(0.5, 1))
	 	attrSp:setPosition(ccp(518,_bottomAllSp:getContentSize().height-5))
	 	_bottomAllSp:addChild(attrSp)

	 	-- 属性显示
	 	local s_posX = {547,547,518}
	 	local s_posY = {75,47,17}
	 	local addAttrTab = SecondFriendAffixModel.getOfferAffixByHid( hid )
	 	local index = 0
	 	print("addAttrTab")
	 	print_t(addAttrTab)
	 	for k_affxid,v_num in pairs(addAttrTab) do
	 		index = index + 1
	 		local attrInfo = SecondFriendData.getAffixAttrInfoById(k_affxid)
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
	 	local addDBData = SecondFriendData.getSecFriendAddAttrByPos(_curIndex)
	 	print("lic_1499 addDBData",_curIndex)
		print_t(addDBData)
		-- 当前位置强化等级
		local curPosLv = StageEnhanceData.getCurStageLv( _curIndex )
		local curGrowAttrTab = StageEnhanceData.handleSingleUpAffix(_curIndex,curPosLv)
		local showNum = (tonumber(addDBData[1][3])+curGrowAttrTab[tonumber(addDBData[1][2])])/100
		local tipFont2 = CCRenderLabel:create(GetLocalizeStringBy("lic_1499",tostring(showNum), curPosData.name ), g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
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
		            	text = curPosData.description,
		            	color = ccc3(0xff,0xff,0xff)
		        	}
		        }
		 	}
	 	local desFont = LuaCCLabel.createRichLabel(textInfo)
	 	desFont:setAnchorPoint(ccp(0.5, 0.5))
	 	desFont:setPosition(ccp(_bottomAllSp:getContentSize().width*0.5,_bottomAllSp:getContentSize().height*0.5))
	 	_bottomAllSp:addChild(desFont)
	end
	if _enhanceBtn ~= nil then
		-- 未开启该助战位
		if hid == -1 then
			-- 设置助战位强化按钮不可见
			_enhanceBtn:setVisible(false)
		else
			_enhanceBtn:setVisible(true)
		end
	end
end

--[[
	@des 	:开启状态有武将
	@param 	:p_index: 位置 p_hid:英雄hid
	@return :sprite
--]]
function createOpenHaveHeroState( p_index, p_hid )
	local retSprite = CCSprite:create()
	retSprite:setContentSize(CCSizeMake(213,200))

	local heroInfo = HeroUtil.getHeroInfoByHid(p_hid)
	print("heroInfo ==>")
	print_t(heroInfo)
	-- 全身像
	local bodyOffset = HeroUtil.getHeroBodySpriteOffsetByHTID(heroInfo.htid)
	print("bodyOffset==>",bodyOffset)
	local cardSprite = HeroUtil.getHeroBodySpriteByHTID( heroInfo.htid, nil, nil, heroInfo.turned_id )
	cardSprite:setAnchorPoint(ccp(0.5,0))
	cardSprite:setPosition(ccp( retSprite:getContentSize().width*0.5, -bodyOffset))
	retSprite:addChild(cardSprite)
	-- cardSprite:setScale(1)

	local nameBg = CCScale9Sprite:create("images/common/bg/bg_9s_2.png")
	nameBg:setPreferredSize(CCSizeMake(258, 37))
	nameBg:setAnchorPoint(ccp(0.5, 0.5))
	nameBg:setPosition(ccp(retSprite:getContentSize().width * 0.5, -30))
	retSprite:addChild(nameBg,10)
	nameBg:setScale(1.5)

	local nameStr = HeroModel.getHeroName(heroInfo)
	local fontTab = {}
    fontTab[1] = CCRenderLabel:create("Lv." .. heroInfo.level .. " ", g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    fontTab[1]:setColor(ccc3(0xff,0xf6,0x00))
    fontTab[2] = CCRenderLabel:create(nameStr .. " ", g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    local nameColor = HeroPublicLua.getCCColorByStarLevel(heroInfo.localInfo.star_lv)
    fontTab[2]:setColor(nameColor)
    -- 进阶次数
	local evolveDes = "+0"
	if heroInfo.evolve_level then
    	if tonumber(heroInfo.localInfo.potential) <= 5 then 
    		evolveDes = "+" .. heroInfo.evolve_level
    	else
    		evolveDes = heroInfo.evolve_level .. GetLocalizeStringBy("zzh_1159")
    	end
    end
    fontTab[3] = CCRenderLabel:create(evolveDes, g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    fontTab[3]:setColor(ccc3(0x00,0xff,0x18))
    local nameFont = BaseUI.createHorizontalNode(fontTab)
    nameFont:setAnchorPoint(ccp(0.5,0.5))
	nameFont:setPosition(ccp(nameBg:getContentSize().width*0.5,nameBg:getContentSize().height*0.5))
	nameBg:addChild(nameFont)

	local curPosData = SecondFriendData.getDBdataByIndex(p_index)
	-- 属性特效
	local animSprite = CCLayerSprite:layerSpriteWithName( CCString:create("images/secondfriend/effect/" .. curPosData.attributeEffect ), -1,CCString:create(""))
	animSprite:setAnchorPoint(ccp(0.5, 0.5))
	animSprite:setPosition(ccp(retSprite:getContentSize().width*0.5,30))
	retSprite:addChild(animSprite)
	animSprite:setScale(0.6)

	return retSprite
end

--[[
	@des 	:未开启状态
	@param 	:p_index: 位置
	@return :sprite
--]]
function createCloseState( p_index )
	local retSprite = CCSprite:create()
	retSprite:setContentSize(CCSizeMake(213,200))

	local scaleNum = 1

	local costTab = SecondFriendData.getOpenCost(p_index)
	-- 消耗背景 
	local fullRect = CCRectMake(0,0,209,49)
    local insetRect = CCRectMake(86,14,45,20)
    local tipSp = CCScale9Sprite:create("images/common/bg/bg2.png",fullRect, insetRect)
	tipSp:setContentSize(CCSizeMake(209, (30 * #costTab)+10 ))
	tipSp:setAnchorPoint(ccp(0.5,0))
	tipSp:setPosition(ccp(retSprite:getContentSize().width*0.5,0))
	retSprite:addChild(tipSp)
	tipSp:setScale(scaleNum)

	-- 消耗提示
	local iconArr = { "gold.png", "coin.png", "xiaoqi.png" } 
	for i=1,#costTab do
		local font1 = CCRenderLabel:create(GetLocalizeStringBy("lic_1500") , g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		font1:setColor(ccc3(0xff,0xff,0xff))
		font1:setAnchorPoint(ccp(0, 0.5))
		font1:setPosition(ccp(36, tipSp:getContentSize().height- (18*i+(i-1)*14) ))
		tipSp:addChild(font1)
		local icon = CCSprite:create("images/common/" .. iconArr[ tonumber(costTab[i].costType) ]  )
		icon:setAnchorPoint(ccp(0, 0.5))
		icon:setPosition(ccp(font1:getContentSize().width+font1:getPositionX()+8, font1:getPositionY() ))
		tipSp:addChild(icon)
		local font2 = CCRenderLabel:create(costTab[i].costNum, g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		font2:setColor(ccc3(0xff,0xff,0xff))
		font2:setAnchorPoint(ccp(0, 0.5))
		font2:setPosition(ccp(icon:getContentSize().width+icon:getPositionX()+5, font1:getPositionY() ))
		tipSp:addChild(font2)
	end

	-- 开启条件
	local needConut,needLv,_ = SecondFriendData.getOpenLv(p_index)
	local tipLabel = CCRenderLabel:create(GetLocalizeStringBy("lic_1501",tostring(needConut),tostring(needLv)), g_sFontPangWa, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	tipLabel:setColor(ccc3(0xff,0xff,0xff))
	tipLabel:setAnchorPoint(ccp(0.5, 0))
	tipLabel:setPosition(ccp(retSprite:getContentSize().width*0.5, tipSp:getPositionY()+tipSp:getContentSize().height*tipSp:getScale()+2))
	retSprite:addChild(tipLabel)
	tipLabel:setScale(scaleNum)

	-- 属性图片
	local posData = SecondFriendData.getDBdataByIndex(p_index)
	local markSp = CCSprite:create("images/secondfriend/mark/" .. posData.picture)
	markSp:setAnchorPoint(ccp(0.5,0))
	markSp:setPosition(ccp(retSprite:getContentSize().width*0.5, tipLabel:getPositionY()+tipLabel:getContentSize().height*tipSp:getScale()+3))
	retSprite:addChild(markSp)
	markSp:setScale(scaleNum)

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

	local posData = SecondFriendData.getDBdataByIndex(p_index)

	-- 属性图片
	local markSp = CCSprite:create("images/secondfriend/mark/" .. posData.picture)
	markSp:setAnchorPoint(ccp(0.5,0.5))
	markSp:setPosition(ccpsprite(0.5, 1.2, retSprite))
	retSprite:addChild(markSp)
	markSp:setScale(scaleNum)

	-- 加号
	local addSprite = ItemSprite.createLucencyAddSprite()
	addSprite:setAnchorPoint(ccp(0.5,0.5))
	addSprite:setPosition(ccpsprite(0.5, 0.5, markSp))
	markSp:addChild(addSprite)

	-- 添加武将
	local tipLabel = CCRenderLabel:create(GetLocalizeStringBy("lic_1502"), g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	tipLabel:setColor(ccc3(0x00,0xff,0x18))
	tipLabel:setAnchorPoint(ccp(0.5, 0))
	tipLabel:setPosition(ccp(retSprite:getContentSize().width*0.5,50))
	retSprite:addChild(tipLabel)
	tipLabel:setScale(scaleNum)

	return retSprite
end

--[[
	@des 	:刷新小伙伴位置
--]]
function refreshHeroCell( ... )
	if _heroTableView ~= nil and _heroTableView:getContainer():getChildren():count() > 0  then
		local container = _heroTableView:getContainer()
		local cells = container:getChildren()
		local mainIndex = 0
		local maxScale = 0
		for i = 0, cells:count() - 1 do
			local cell = tolua.cast(cells:objectAtIndex(i), "CCTableViewCell")
			local hero = cell:getChildByTag(POS_TAG)
			if hero ~= nil then
				local position = cell:convertToWorldSpace(ccp(hero:getPositionX(), hero:getPositionY()))
				local scale = 1 - math.abs(_bgLayer:getContentSize().width * 0.5 - position.x) / _bgLayer:getContentSize().width
				hero:setScale(_myScale * scale *MainScene.elementScale * 1.2)
				hero:setPositionY(math.abs(_bgLayer:getContentSize().width * 0.5 - position.x) / _bgLayer:getContentSize().width * 0.5 * 400*g_fScaleX)
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
		if _curIndex ~= mainIndex and mainIndex ~= 0 and mainIndex ~= _allNum + 1 then
    		_curIndex = mainIndex
    		refreshBottomUI()
		end
	end
end

--[[
	@des 	:获得属性的信息
	@param 	:p_index: p_index
	@return :cell
--]]
function createHeroCell( p_index )
	local cell = CCTableViewCell:create()
	local cellSize = _cellSize
	cell:setContentSize(cellSize)
	if p_index == 0 or p_index == _allNum + 1 then
		return cell
	end
	-- local node = CCLayerColor:create(ccc4(100, 0, 0, 130))
	local node = CCSprite:create()
	cell:addChild(node)
	node:setCascadeColorEnabled(true)
	node:setTag(POS_TAG)
	node:setContentSize(cellSize)
	node:ignoreAnchorPointForPosition(false)
	node:setAnchorPoint(ccp(0.5, 0))
	node:setPosition(ccp( cell:getContentSize().width*0.5,cell:getContentSize().height*0))
	node:setScale(_myScale*MainScene.elementScale * 1.2)

	local stage = CCSprite:create("images/olympic/kingChair.png")
	node:addChild(stage)
	stage:setAnchorPoint(ccp(0.5, 0))
	stage:setPosition(ccp(node:getContentSize().width * 0.5, 0))
	stage:setScale(1.8)

	local curPosData = SecondFriendData.getDBdataByIndex(p_index)
	-- 台子特效
	local animSprite = CCLayerSprite:layerSpriteWithName( CCString:create("images/secondfriend/effect/" .. curPosData.methodEffect ), -1,CCString:create(""))
	animSprite:setAnchorPoint(ccp(0.5, 0.5))
	animSprite:setPosition(ccp(stage:getContentSize().width*0.5,stage:getContentSize().height*0.87))
	stage:addChild(animSprite)
	animSprite:setScale(0.7)

	-- 按钮
	local menu = BTSensitiveMenu:create()
	if(menu:retainCount()>1)then
		menu:release()
		menu:autorelease()
	end
	menu:setPosition(ccp(0,0))
	node:addChild(menu)

	local normalSp = CCSprite:create()
	normalSp:setContentSize(CCSizeMake(213,300))
	local selectSp = CCSprite:create()
	selectSp:setContentSize(CCSizeMake(213,300))
	local menuItem = CCMenuItemSprite:create(normalSp,selectSp)
	menuItem:setAnchorPoint(ccp(0.5, 0))
	menuItem:setPosition(ccp(node:getContentSize().width * 0.5, 95))
	menu:addChild(menuItem,10,p_index)
	-- 注册item回调
	menuItem:registerScriptTapHandler(clickItemCallFun)

	local onStageSp = nil
	local isOpen = SecondFriendData.getIsOpenByPos( p_index )
	if(isOpen)then
		local hid = SecondFriendData.getSecondFriendHidByPos(p_index)
		if(hid > 0)then
			-- 开启有英雄
			onStageSp = createOpenHaveHeroState(p_index,hid)
		else
			-- 开启无英雄
			onStageSp =createOpenState( p_index )
		end
	else
		-- 未开启
		onStageSp = createCloseState(p_index)
	end

	onStageSp:setAnchorPoint(ccp(0.5, 0))
	onStageSp:setPosition(ccp(menuItem:getContentSize().width * 0.5, 0))
	menuItem:addChild(onStageSp)

	return cell
end

--[[
	@des 	:创建中间小伙伴tableView
--]]
function createHeroTableView( ... )
	local viewHeight = _bgLayer:getContentSize().height - _topBg:getContentSize().height*g_fScaleX - _bottomBg:getContentSize().height*g_fScaleX - 20*MainScene.elementScale
	print("viewHeight",viewHeight)
	_cellSize = CCSizeMake(math.ceil(_bgLayer:getContentSize().width / 3), viewHeight)
	_myScale = viewHeight/_bgLayer:getContentSize().height
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
    _heroTableView = LuaTableView:createWithHandler(h, CCSizeMake(_bgLayer:getContentSize().width, viewHeight))
    _bgLayer:addChild(_heroTableView)
    _heroTableView:setAnchorPoint(ccp(0.5, 0.5))
    _heroTableView:setPosition(ccp(_bgLayer:getContentSize().width * 0.5, _bgLayer:getContentSize().height * 0.5))
    _heroTableView:ignoreAnchorPointForPosition(false)
    _heroTableView:setDirection(kCCScrollViewDirectionHorizontal)
    _heroTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    _heroTableView:setTouchPriority(_bgLayerTouchPriority - 10)
    _heroTableView:setTouchEnabled(false)

    _curIndex = _displayPos or SecondFriendData.getPosByHeroHid(_displayHid) or 1
    local offset = _heroTableView:getContentOffset()
    print("_curIndex",_curIndex,"offset.x",offset.x)
    if _curIndex > 0 or _curIndex < _allNum then
    	offset.x = -(_curIndex-1) * _cellSize.width
    	print("_curIndex",_curIndex,"offset.x",offset.x)
    	_heroTableView:setContentOffset(offset)
	end

	-- 刷新小伙伴cell
    refreshHeroCell()
    -- 刷新下边ui
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
	_bottomBg:setPosition(ccp(_bgLayer:getContentSize().width*0.5,20*MainScene.elementScale))
	_bgLayer:addChild(_bottomBg,10)
	_bottomBg:setScale(g_fScaleX)

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
	_topBg:setScale(g_fScaleX)

	-- 标题
	local titleSp = CCSprite:create("images/secondfriend/title.png")
	titleSp:setAnchorPoint(ccp(0.5,1))
	titleSp:setPosition(ccp(_topBg:getContentSize().width*0.5,_topBg:getContentSize().height*0.86))
	_topBg:addChild(titleSp)

	-- 增加属性名字 +数值
	for i=1, #_addAffixId do 
		local attrInfo = SecondFriendData.getAffixAttrInfoById(_addAffixId[i])
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
		_addAffixNumTab[tonumber(_addAffixId[i])] = attrNumLabel
	end

end

--[[
	@des 	: 创建助战位强化按钮  add by yangrui at 2015-12-07
	@param 	: 
	@return : 
--]]
function createStageEnchanceBtn( ... )
	local menu = CCMenu:create()
	menu:setAnchorPoint(ccp(0,0))
	menu:setPosition(ccp(0,0))
	menu:setTouchPriority(_bgLayerTouchPriority-320)
	_bgLayer:addChild(menu,20)
	_enhanceBtn = CCMenuItemImage:create("images/secondfriend/enhance/enhance_btn_n.png","images/secondfriend/enhance/enhance_btn_h.png")
	_enhanceBtn:setAnchorPoint(ccp(0.5,0.5))
	_enhanceBtn:setPosition(ccp((_bgLayer:getContentSize().width/g_fScaleX-_enhanceBtn:getContentSize().width/2-20)*g_fScaleX,_topBg:getPositionY()-_topBg:getContentSize().height*1.2*g_fScaleY))
	_enhanceBtn:setScale(g_fScaleX)
	_enhanceBtn:setVisible(false)
	_enhanceBtn:registerScriptTapHandler(function( ... )
		-- 音效
		AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
		-- 隐藏助战军详细
		_topBg:setVisible(false)
		_heroTableView:setVisible(false)
		_bottomBg:setVisible(false)
		_enhanceBtn:setVisible(false)
		require "script/ui/formation/secondfriend/stageenhance/StageEnhanceLayer"
		local stageEnhanceLayer = StageEnhanceLayer.createLayer(_bgLayer:getContentSize().width,_bgLayer:getContentSize().height,_curIndex)
		_bgLayer:addChild(stageEnhanceLayer)
	end)
	menu:addChild(_enhanceBtn)
end

--[[
	@des 	: 显示助战位
	@param 	: 
	@return : 
--]]
function showStageDetail( ... )
	refreshTopUI()
	refreshBottomUI()
	_topBg:setVisible(true)
	_heroTableView:setVisible(true)
	_bottomBg:setVisible(true)
	_enhanceBtn:setVisible(true)
end

--[[
	@des 	:创建第二套小伙伴界面
	@param 	:p_width:layer宽, p_height:layer高 p_display_hid展示的英雄hid p_showSecondFriendPos:展示的位置
	@return :
--]]
function createSecondFriendLayer( p_width, p_height, p_display_hid, p_showSecondFriendPos)
	-- 初始化
	init()

	_bgLayer = CCLayer:create()
	-- _bgLayer = CCLayerColor:create(ccc4(255,0,0,70))
	_bgLayer:setContentSize(CCSizeMake(p_width,p_height))
	
	_bgLayer:registerScriptHandler(onNodeEvent)

	-- 初始化数据
	initData()
	-- 展示的hid
	_displayHid = p_display_hid 
	-- 展示的位置
	_displayPos = p_showSecondFriendPos

	-- 创建上边ui
	createTopUI()

	-- 创建助战位强化按钮
	createStageEnchanceBtn()

	-- 创建下边ui
	createBottomUI()

	-- 创建中间ui
	createMiddleUI()

	return _bgLayer
end












  