-- FileName: ChariotInfoLayer.lua
-- Author: lgx 
-- Date: 16-06-27
-- Purpose: 战车信息界面

module("ChariotInfoLayer", package.seeall)

require "script/ui/chariot/ChariotDef"
require "script/ui/chariot/ChariotMainController"
require "script/ui/chariot/ChariotMainData"
require "script/ui/chariot/ChariotUtil"
require "script/ui/active/RivalInfoData"

local _touchPriority 	= nil	-- 触摸优先级
local _zOrder 		 	= nil	-- 显示层级
local _bgLayer 		 	= nil	-- 背景层
local _bgSprite 		= nil	-- 背景
local _topSprite 		= nil	-- 标题背景
local _bottomBg 		= nil	-- 底下背景
local _showType 		= nil	-- 显示状态
local _chariotPos 		= nil	-- 战车装备的位置
local _itemId 			= nil	-- 战车物品id
local _itemTid 			= nil 	-- 战车物品模板id
local _curLv 			= nil	-- 战车等级
local _chariotInfo 		= nil	-- 战车信息

--[[
	@desc 	: 初始化方法
	@param 	: 
	@return : 
--]]
local function init()
	_touchPriority 	= nil
	_zOrder 		= nil
	_bgLayer 		= nil
	_bgSprite		= nil
	_topSprite		= nil
	_bottomBg		= nil
	_showType		= nil
	_chariotPos 	= nil
	_itemId 		= nil
	_itemTid 		= nil
	_curLv			= nil
	_chariotInfo	= nil
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
	@desc 	: 显示界面方法
	@param	: pShowType 显示状态
	@param	: pItemId 战车物品id
	@param	: pItemTid 战车物品模板id
	@param 	: pTouchPriority 触摸优先级
	@param 	: pZorder 显示层级
	@return : 
--]]
function showLayer( pShowType, pItemId, pItemTid, pTouchPriority, pZorder )
	local layer = createLayer(pShowType,pItemId,pItemTid,pTouchPriority, pZorder)
	local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(layer,_zOrder)
end

--[[
	@desc 	: 创建Layer及UI
	@param	: pShowType 显示状态
	@param	: pItemId 战车物品id
	@param	: pItemTid 战车物品模板id
	@param 	: pTouchPriority 触摸优先级
	@param 	: pZorder 显示层级
	@return : CCLayerColor 背景层
--]]
function createLayer( pShowType, pItemId, pItemTid, pTouchPriority, pZorder )
	-- 初始化
	init()

	_showType = pShowType or ChariotDef.kChariotInfoTypeBase
	_chariotPos = ChariotMainData.getChariotPosByItemId(pItemId) or 0
	_itemId = pItemId or 0
	_itemTid = pItemTid or 0
	_touchPriority = pTouchPriority or -800
	_zOrder = pZorder or 800

	-- 获取战车数据 
	if (_showType == ChariotDef.kChariotInfoTypeEquip) then
		-- 装备中
		_chariotInfo = ChariotMainData.getEquipChariotInfoByPos(_chariotPos)
		_itemId = _chariotInfo.item_id
		_itemTid = _chariotInfo.item_template_id
		_curLv = tonumber(_chariotInfo.va_item_text.chariotEnforce)
	elseif (_showType == ChariotDef.kChariotInfoTypeBag) then
		-- 背包里
		_chariotInfo = ItemUtil.getItemByItemId(pItemId)
		if (_chariotInfo == nil) then
			-- 背包里装备上的战车
			_chariotInfo = ChariotMainData.getEquipChariotInfoByPos(_chariotPos)
		end
		_itemId = _chariotInfo.item_id
		_itemTid = _chariotInfo.item_template_id
		_curLv = tonumber(_chariotInfo.va_item_text.chariotEnforce)
	elseif (_showType == ChariotDef.kChariotInfoTypeRival) then
		-- 对方阵容
		_chariotPos = RivalInfoData.getChariotPosByItemId(pItemId)
		_chariotInfo = RivalInfoData.getChariotInfoByPos(_chariotPos)
		_itemId = _chariotInfo.item_id
		_itemTid = _chariotInfo.item_template_id
		_curLv = tonumber(_chariotInfo.va_item_text.chariotEnforce)
	else
		-- 其他
		_chariotInfo = {}
		_chariotInfo.item_template_id = pItemTid
		_chariotInfo.itemDesc = ItemUtil.getItemById(pItemTid)
		_itemTid = pItemTid
		_curLv = 0
	end

	-- 背景层
	_bgLayer = CCLayer:create()
	_bgLayer:setPosition(ccp(0, 0))
	_bgLayer:registerScriptHandler(onNodeEvent)
	_bgLayer:setAnchorPoint(ccp(0, 0))

	-- 创建背景
	createBgSprite()

	return _bgLayer
end

--[[
	@desc 	: 创建背景
	@param 	: 
	@return : 
--]]
function createBgSprite()

	local nWidth = _bgLayer:getContentSize().width
	local nHeight = _bgLayer:getContentSize().height

	if (_showType == ChariotDef.kChariotInfoTypeBag) then
		-- 公告栏大小
		require "script/ui/main/BulletinLayer"
		local bulletinLayerSize = BulletinLayer.getLayerContentSize()
		nWidth = _bgLayer:getContentSize().width
		nHeight = _bgLayer:getContentSize().height - bulletinLayerSize.height*g_fScaleX
	end

	-- 背景
	_bgSprite = CCScale9Sprite:create("images/item/equipinfo/bg_9s.png")
	_bgSprite:setContentSize(CCSizeMake(nWidth/g_fScaleX, nHeight/g_fScaleX))
	_bgSprite:setAnchorPoint(ccp(0.5, 1))
	_bgSprite:setPosition(ccp(nWidth*0.5, nHeight))
	_bgLayer:addChild(_bgSprite)
	_bgSprite:setScale(g_fScaleX)

	-- 标题背景
	_topSprite = CCSprite:create("images/item/equipinfo/topbg.png")
	_topSprite:setAnchorPoint(ccp(0.5, 1))
	_topSprite:setPosition(ccp(_bgSprite:getContentSize().width*0.5, _bgSprite:getContentSize().height))
	_bgSprite:addChild(_topSprite,10)

	-- 标题 战车信息
	local titleLabel = CCRenderLabel:create(GetLocalizeStringBy("lgx_1075"), g_sFontPangWa, 35, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    titleLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    titleLabel:setAnchorPoint(ccp(0.5,0.5))
    titleLabel:setPosition(ccpsprite(0.5,0.5,_topSprite))
    _topSprite:addChild(titleLabel)

    -- 关闭按钮
    local colseMenu = CCMenu:create()
	colseMenu:setPosition(ccp(0, 0))
	_topSprite:addChild(colseMenu)
	colseMenu:setTouchPriority(_touchPriority-4)

	local closeItem = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png" )
	closeItem:setAnchorPoint(ccp(1, 0.5))
    closeItem:setPosition(ccp(_topSprite:getContentSize().width*1.01, _topSprite:getContentSize().height*0.54))
    closeItem:registerScriptTapHandler(closeItemCallBack)
	colseMenu:addChild(closeItem)

	-- 底部背景
	_bottomBg = CCSprite:create("images/common/sell_bottom.png")
	_bottomBg:setAnchorPoint(ccp(0.5,0))
	_bottomBg:setPosition(ccp(_bgSprite:getContentSize().width*0.5,0))
	_bgSprite:addChild(_bottomBg,10)

	-- 底部按钮
    local bottoMenu = CCMenu:create()
	bottoMenu:setPosition(ccp(0, 0))
	_bottomBg:addChild(bottoMenu)
	bottoMenu:setTouchPriority(_touchPriority-4)

	-- 按钮字体大小
	local fontSize = 35

	-- 更换按钮
 	local changeItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(160, 73),GetLocalizeStringBy("key_1543"),ccc3(0xfe, 0xdb, 0x1c),fontSize,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	changeItem:setAnchorPoint(ccp(0.5, 0.5))
	bottoMenu:addChild(changeItem)
	changeItem:registerScriptTapHandler(changeItemCallBack)
	changeItem:setVisible(false)

	-- 卸下按钮
	local upEquipItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(160, 73),GetLocalizeStringBy("key_2933"),ccc3(0xfe, 0xdb, 0x1c),fontSize,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	upEquipItem:setAnchorPoint(ccp(0.5, 0.5))
	bottoMenu:addChild(upEquipItem)
	upEquipItem:registerScriptTapHandler(upEquipItemCallBack)
	upEquipItem:setVisible(false)

	-- 按钮位置
	if (_showType == ChariotDef.kChariotInfoTypeEquip) then 
		-- 更换 卸下
		changeItem:setVisible(true)
		upEquipItem:setVisible(true)
		changeItem:setPosition(ccp(_bottomBg:getContentSize().width*0.25, _bottomBg:getContentSize().height*0.5))
		upEquipItem:setPosition(ccp(_bottomBg:getContentSize().width*0.75, _bottomBg:getContentSize().height*0.5))
	elseif (_showType == ChariotDef.kChariotInfoTypeBag or _showType == ChariotDef.kChariotInfoTypeRival or _showType == ChariotDef.kChariotInfoTypeBase) then
		-- 确定按钮
		local comfirmItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_green_n.png","images/common/btn/btn_green_h.png",CCSizeMake(200, 71),GetLocalizeStringBy("key_1985"),ccc3(0xfe, 0xdb, 0x1c),fontSize,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		comfirmItem:setAnchorPoint(ccp(0.5, 0.5))
		bottoMenu:addChild(comfirmItem)
		comfirmItem:registerScriptTapHandler(closeItemCallBack)
		comfirmItem:setPosition(ccp(_bottomBg:getContentSize().width*0.5, _bottomBg:getContentSize().height*0.5))
	else
		-- 无按钮
		print("NO Btn !!")
	end

	-- 创建内容
    createContentView()
end

--[[
	@desc 	: 创建内容
	@param 	: 
	@return : 
--]]
function createContentView()
	-- ScrollView
	local scrollView = CCScrollView:create()
	scrollView:setTouchPriority(_touchPriority-3)
	local scrollViewHeight = _bgSprite:getContentSize().height - _topSprite:getContentSize().height - _bottomBg:getContentSize().height
	scrollView:setViewSize(CCSizeMake(_bgSprite:getContentSize().width, scrollViewHeight))
	scrollView:setDirection(kCCScrollViewDirectionVertical)

	local contentLayer = CCLayer:create()

	-- 记录高度
	local contentHeight = 0

	-- 战车
	local bigChariotSprite = createBigChariotSprite()
	bigChariotSprite:setAnchorPoint(ccp(0.5,1))
	contentLayer:addChild(bigChariotSprite)
	contentHeight = contentHeight + bigChariotSprite:getContentSize().height + 15

	-- 属性
	local chariotAttrSprite = createChariotAttrSprite()
	chariotAttrSprite:setAnchorPoint(ccp(0.5,1))
	contentLayer:addChild(chariotAttrSprite)
	contentHeight = contentHeight + chariotAttrSprite:getContentSize().height + 30

	-- 技能
	local chariotSkillSprite = createChariotSkillSprite()
	chariotSkillSprite:setAnchorPoint(ccp(0.5,1))
	contentLayer:addChild(chariotSkillSprite)
	contentHeight = contentHeight + chariotSkillSprite:getContentSize().height + 30

	-- 简介
	local briefIntrSprite = createBriefIntrSprite()
	briefIntrSprite:setAnchorPoint(ccp(0.5,1))
	contentLayer:addChild(briefIntrSprite)
	contentHeight = contentHeight + briefIntrSprite:getContentSize().height + 30

	-- 设置position
	local posY = contentHeight - 15
	bigChariotSprite:setPosition(ccp(_bgSprite:getContentSize().width*0.5,posY))
	posY = posY - bigChariotSprite:getContentSize().height-30

	chariotAttrSprite:setPosition(ccp(_bgSprite:getContentSize().width*0.5,posY))
	posY = posY - chariotAttrSprite:getContentSize().height-30

	chariotSkillSprite:setPosition(ccp(_bgSprite:getContentSize().width*0.5,posY))
	posY = posY - chariotSkillSprite:getContentSize().height-30

	briefIntrSprite:setPosition(ccp(_bgSprite:getContentSize().width*0.5,posY))

	--  设置contentLayer
	print("contentHeight => ",contentHeight)
	contentLayer:setContentSize(CCSizeMake(640,contentHeight))
	scrollView:setContainer(contentLayer)
	scrollView:setPosition(ccp(0,_bottomBg:getContentSize().height))
	_bgSprite:addChild(scrollView)
	scrollView:setContentOffset(ccp(0,scrollView:getViewSize().height-contentLayer:getContentSize().height))
end

--[[
	@desc 	: 创建战车大图标
	@param 	: 
	@return : 
--]]
function createBigChariotSprite()
	local retSprite = CCScale9Sprite:create("images/hero/info_bg.png")
	retSprite:setContentSize(CCSizeMake(587,537))

	local chariotSprite = ChariotUtil.createChariotBigItemByTid(_itemTid)
	chariotSprite:setAnchorPoint(ccp(0.5,0.5))
	chariotSprite:setPosition(ccp(retSprite:getContentSize().width*0.5,300))
	retSprite:addChild(chariotSprite)

	-- 等级 和 名称
	local nameBg = ChariotUtil.createChariotNameLabByNameAndLv("".._chariotInfo.itemDesc.name,CCSizeMake(250, 40),_chariotInfo.itemDesc.quality,_curLv)
	nameBg:setAnchorPoint(ccp(0.5,0.5))
	nameBg:setPosition(ccp(retSprite:getContentSize().width*0.5, 120))
	retSprite:addChild(nameBg,2)

	return retSprite
end

--[[
	@desc 	: 创建战车属性
	@param 	: 
	@return : 
--]]
function createChariotAttrSprite()
	local retSprite = CCScale9Sprite:create("images/copy/fort/textbg.png")

	local attrInfo = ChariotMainData.getSortedChariotAttrInfoByTidAndLv(_itemTid,_curLv)

	-- 计算长度
	local needHeight = 0
	local attrCount = table.count(attrInfo)
	if( attrCount > 1)then 
		needHeight = attrCount/2*30+50
	else
		needHeight = 85
	end
	print("needHeight",needHeight)
	retSprite:setContentSize(CCSizeMake(590, needHeight))

	-- 标题
	local titleBg = CCScale9Sprite:create("images/hero/info/title_bg.png")
	titleBg:setContentSize(CCSizeMake(145, 40))
	titleBg:setAnchorPoint(ccp(0,0.5))
	titleBg:setPosition(ccp(0,retSprite:getContentSize().height))
	retSprite:addChild(titleBg,5)

	-- 属性
	local titleFont = CCLabelTTF:create(GetLocalizeStringBy("key_1141"), g_sFontName,22)
	titleFont:setColor(ccc3(0x00,0x00,0x00))
	titleFont:setAnchorPoint(ccp(0.5,0.5))
	titleFont:setPosition(ccp(titleBg:getContentSize().width*0.5, titleBg:getContentSize().height*0.5))
	titleBg:addChild(titleFont)

	-- 属性数值
	local posY = retSprite:getContentSize().height - 55
    for i,v in ipairs(attrInfo) do
    	local row = math.floor((i-1)/2)+1
 		local col = (i-1)%2+1
    	local affixDesc, displayNum = ItemUtil.getAtrrNameAndNum(v.id, v.num)
        local attrNameLabel = CCLabelTTF:create(affixDesc.sigleName .. ":",g_sFontName,21)
        attrNameLabel:setColor(ccc3(0x78,0x25,0x00))
        attrNameLabel:setAnchorPoint(ccp(0,0))
        attrNameLabel:setPosition(ccp(retSprite:getContentSize().width*0.2+180*(col-1),posY-30*(row-1)))
        retSprite:addChild(attrNameLabel)

        local attrNumLabel = CCLabelTTF:create(displayNum, g_sFontName,21)
        attrNumLabel:setColor(ccc3(0x00,0x00,0x00))
        attrNumLabel:setAnchorPoint(ccp(0,0))
        attrNumLabel:setPosition(ccp(retSprite:getContentSize().width*0.2+180*(col-1)+attrNameLabel:getContentSize().width,attrNameLabel:getPositionY()))
        retSprite:addChild(attrNumLabel)
    end

	return retSprite
end

--[[
	@desc 	: 创建战车攻击方式及技能
	@param 	: 
	@return : 
--]]
function createChariotSkillSprite()
	local retSprite = CCScale9Sprite:create("images/copy/fort/textbg.png")

	-- 第一行
	local skillName,skillDesc = ChariotMainData.getSkillNameAndDescById(_chariotInfo.itemDesc.warcar_skill)
	-- 技能名称
	local skillNameLabel = CCLabelTTF:create(skillName.." ", g_sFontName,21)
    skillNameLabel:setColor(ccc3(0x85,0x00,0x7a))

	-- 技能描述
    local textInfo = {
     		width = 550-skillNameLabel:getContentSize().width, -- 宽度
	        alignment = 1, -- 对齐方式  1 左对齐，2 居中， 3右对齐
	        labelDefaultFont = g_sFontName, -- 默认字体
	        labelDefaultSize = 21, -- 默认字体大小
	        elements =
	        {	
	            {
	            	type = "CCLabelTTF",
	            	text = skillDesc,
	            	color = ccc3(0x78,0x25,0x00)
	        	}
	        }
	 	}
 	local fontNode = LuaCCLabel.createRichLabel(textInfo)

 	-- 第二行
 	local textInfo1 = {
     		width = 550, -- 宽度
	        alignment = 2, -- 对齐方式  1 左对齐，2 居中， 3右对齐
	        labelDefaultFont = g_sFontPangWa, -- 默认字体
	        labelDefaultSize = 21, -- 默认字体大小
	        elements =
	        {	
	        	{
	            	type = "CCLabelTTF", 
	            	text = GetLocalizeStringBy("lgx_1096"),
	            	color = ccc3(0xff,0x84,0x00)
	        	}
	        }
	 	}
 	local fontNode1 = LuaCCLabel.createRichLabel(textInfo1)
 	
 	needHeight = fontNode:getContentSize().height + fontNode1:getContentSize().height + 50
	print("needHeight",needHeight)
	retSprite:setContentSize(CCSizeMake(590, needHeight))

	-- 标题
	local titleBg = CCScale9Sprite:create("images/hero/info/title_bg.png")
	titleBg:setContentSize(CCSizeMake(145, 40))
	titleBg:setAnchorPoint(ccp(0,0.5))
	titleBg:setPosition(ccp(0,retSprite:getContentSize().height))
	retSprite:addChild(titleBg,5)

	-- 技能
	local titleFont = CCLabelTTF:create(GetLocalizeStringBy("lgx_1078"), g_sFontName,22)
	titleFont:setColor(ccc3(0x00,0x00,0x00))
	titleFont:setAnchorPoint(ccp(0.5,0.5))
	titleFont:setPosition(ccp(titleBg:getContentSize().width*0.5, titleBg:getContentSize().height*0.5))
	titleBg:addChild(titleFont)

	-- 技能名称
	skillNameLabel:setAnchorPoint(ccp(0,1))
    skillNameLabel:setPosition(ccp(20,retSprite:getContentSize().height-25))
    retSprite:addChild(skillNameLabel)

	-- 技能描述
	fontNode:setAnchorPoint(ccp(0, 1))
 	fontNode:setPosition(ccp(20+skillNameLabel:getContentSize().width,retSprite:getContentSize().height-25))
 	retSprite:addChild(fontNode)

 	fontNode1:setAnchorPoint(ccp(0.5, 1))
 	fontNode1:setPosition(ccp(retSprite:getContentSize().width*0.5,retSprite:getContentSize().height-(28+fontNode:getContentSize().height)))
 	retSprite:addChild(fontNode1)

	return retSprite
end

--[[
	@desc 	: 创建战车简介UI
	@param 	: 
	@return : 
--]]
function createBriefIntrSprite()
	local retSprite = CCScale9Sprite:create("images/copy/fort/textbg.png")

	-- 第一行
    local textInfo = {
     		width = 550, -- 宽度
	        alignment = 1, -- 对齐方式  1 左对齐，2 居中， 3右对齐
	        labelDefaultFont = g_sFontName, -- 默认字体
	        labelDefaultSize = 21, -- 默认字体大小
	        elements =
	        {	
	            {
	            	type = "CCLabelTTF", 
	            	text = _chariotInfo.itemDesc.explain,
	            	color = ccc3(0x78,0x25,0x00)
	        	}
	        }
	 	}
 	local fontNode = LuaCCLabel.createRichLabel(textInfo)
 	
 	needHeight = fontNode:getContentSize().height + 50
	print("needHeight",needHeight)
	retSprite:setContentSize(CCSizeMake(590, needHeight))

	-- 标题
	local titleBg = CCScale9Sprite:create("images/hero/info/title_bg.png")
	titleBg:setContentSize(CCSizeMake(145, 40))
	titleBg:setAnchorPoint(ccp(0,0.5))
	titleBg:setPosition(ccp(0,retSprite:getContentSize().height))
	retSprite:addChild(titleBg,5)

	-- 简介
	local titleFont = CCLabelTTF:create(GetLocalizeStringBy("key_2371"), g_sFontName,22)
	titleFont:setColor(ccc3(0x00,0x00,0x00))
	titleFont:setAnchorPoint(ccp(0.5,0.5))
	titleFont:setPosition(ccp(titleBg:getContentSize().width*0.5, titleBg:getContentSize().height*0.5))
	titleBg:addChild(titleFont)

	-- 简介描述
	fontNode:setAnchorPoint(ccp(0.5, 1))
 	fontNode:setPosition(ccp(retSprite:getContentSize().width*0.5,retSprite:getContentSize().height-25))
 	retSprite:addChild(fontNode)

 	return retSprite
end

--[[
	@desc 	: 更换按钮回调
	@param 	: 
	@return : 
--]]
function changeItemCallBack()
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	require "script/ui/chariot/ChariotChooseLayer"
	ChariotChooseLayer.showLayer(_chariotPos,-1000,888)
	-- 关闭界面
	closeSelfCallBack()
end

--[[
	@desc 	: 卸下按钮回调
	@param 	: 
	@return : 
--]]
function upEquipItemCallBack()
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- 卸下战车
	ChariotMainController.unEquip(function()
		print("---------------unEquip Success--------------")
		-- 关闭界面
		closeSelfCallBack()
	end,_chariotPos,_itemId)
end

--[[
	@desc 	: 关闭界面
	@param 	: 
	@return : 
--]]
function closeSelfCallBack()
	if not tolua.isnull(_bgLayer) then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
end

--[[
	@desc 	: 关闭按钮回调
	@param 	: 
	@return : 
--]]
function closeItemCallBack()
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	closeSelfCallBack()
end
