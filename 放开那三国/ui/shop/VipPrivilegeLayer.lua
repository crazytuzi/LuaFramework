-- Filename: VipPrivilegeLayer.lua
-- Author: Zhang Zihang
-- Date: 2014-11-10
-- Purpose: 改版后的VIP特权，原来华仔代码作古

module("VipPrivilegeLayer", package.seeall)

require "script/model/user/UserModel"
require "script/ui/shop/GiftsPakLayer"
require "script/ui/item/ItemSprite"
require "script/ui/item/ItemUtil"
require "script/ui/hero/HeroPublicLua"
require "db/DB_Vip_desc"

local _priority   			--触摸优先级
local _zOrder				--ZOrder
local _levelUpMoney			--升级所需经验
local _curPayMoney			--当前经验
local _bgLayer				--背景层
local _secondBgSprite 		--二级背景图
local _nowVip				--当前VIP
local _vipNode  			--vip特权node
local _bgMenu 				--二级背景按钮
local _innerBgSprite 		--内部背景图
local _vipScrollView 		--看名字就懂了
local _packTitleLabel 		--尊享礼包名称
local _packBgSprite 		--奖励背景图
local _scrollOffset 		--scrollView位移
local _beginPoint 			--滑动开始坐标
local _lastPoint 			--上次滑动位置
local _bool 				--控制是否执行完成的布尔变量

local tagLeft = 1000 		--向左点击按钮tag
local tagRight = 2000 		--向右点击按钮tag
local tagUp = 3000 			--向上点击按钮tag
local tagDown = 4000 		--向下点击按钮tag

--[[
	@des 	:初始化函数
	@param 	:
	@return :
--]]
function init()
	_priority = nil
	_zOrder = nil
	_bgLayer = nil
	_secondBgSprite = nil
	_bgMenu = nil
	_vipScrollView = nil
	_vipNode = nil
	_packTitleLabel = nil
	_packBgSprite = nil
	_beginPoint = nil
	_lastPoint = nil
	_bool = true
	_scrollOffset = 0
	_levelUpMoney = 0
	_curPayMoney = 0
	_nowVip = 0
end

--[[
	@des 	:触摸函数
	@param 	:$ p_eventType 		:触摸类型
	@param 	:$ p_touch_x 		:触摸点x轴
	@param 	:$ p_touch_y 		:触摸点y轴
	@return :true
--]]
function layerToucCb(p_eventType,p_touch_x,p_touch_y)
	return true
end

--[[
	@des 	:处理VIP相关数据
	@param 	:
	@return :
--]]
function dealData()
	--VIP下一级数据
    local nextVipLevelData
    --DB_Vip中第一条为vip0，所以表长度减1为最大VIP
    --如果是最大等级了，则下一等级数据为最大等级的vip信息
    if(tonumber(UserModel.getVipLevel()) == tonumber(table.count(DB_Vip.Vip) -1)) then
    	nextVipLevelData = DB_Vip.getDataById(UserModel.getVipLevel()+1)
    --否则是下一等级vip数据
    else
    	nextVipLevelData = DB_Vip.getDataById(UserModel.getVipLevel()+2)
    end

    --升级所需经验数
    _levelUpMoney = nextVipLevelData.rechargeValue or 0
    --当前经验数
    _curPayMoney =  DataCache.getChargeGoldNum()
    
    --防止溢出，做最大经验处理
    if tonumber(_curPayMoney) > tonumber(_levelUpMoney) then
    	_levelUpMoney = _curPayMoney
    end
end

--[[
	@des 	:关闭回调
	@param 	:
	@return :
--]]
function closeCallBack()
	require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
	
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
end

--[[
	@des 	:创建VIP图片Node
	@param 	:
	@return :
--]]
function createVIPNode()
	if _vipNode ~= nil then
		_vipNode:removeFromParentAndCleanup(true)
		_vipNode = nil
	end

	--vip表
	local vipTable = {}
	vipTable[1] = CCSprite:create("images/shop/vip_big/vip.png")
	vipTable[2] = LuaCC.createNumberSprite("images/shop/vip_big",_nowVip)
	vipTable[3] = CCSprite:create("images/hero/privilege.png")

	--vip特权node
	_vipNode = BaseUI.createHorizontalNode(vipTable)
	_vipNode:setAnchorPoint(ccp(0.5,0.5))
	_vipNode:setPosition(ccp(_secondBgSprite:getContentSize().width/2,_secondBgSprite:getContentSize().height - 40))
	_secondBgSprite:addChild(_vipNode)
end

--[[
	@des 	:切换按钮回调
	@param 	:tag值
	@return :
--]]
function changeCallBack(tag,item)
	-- local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
	-- if _bool == true then
	-- 	_bool = false
		if tag == tagLeft then
			_nowVip = _nowVip - 1
		else
			_nowVip = _nowVip + 1
		end

		--将按钮都设置为可点
		ableBtn()

		--设置不可点按钮
		disableBtn()

		--创建VIPNode
		createVIPNode()

		--创建vipScrollView
		createVIPScrollView(400)

		--刷新奖励名称
		_packTitleLabel:setString("vip" .. _nowVip .. GetLocalizeStringBy("zzh_1184"))

		--创建物品预览
		createGiftPreview(_innerBgSprite:getContentSize().height - 400 - 35/2)
	-- end
    -- end))

	--一次创建成功或
	-- if _bool == true then
	-- 	_bool = false
 --    	_bgLayer:runAction(seq)
 --    end
end

--[[
	@des 	:将该Sprite加到一个空的Sprite上，为了扩大可点击区域
	@param 	:一个Sprite
	@return :创建好的Sprite
--]]
function addToEmptySprite(p_sprite)
	local emptySprite = CCSprite:create()
	emptySprite:setContentSize(CCSizeMake(100,100))
	p_sprite:setAnchorPoint(ccp(0.5,0.5))
	p_sprite:setPosition(emptySprite:getContentSize().width/2,emptySprite:getContentSize().height/2)
	emptySprite:addChild(p_sprite)

	return emptySprite
end

--[[
	@des 	:创建切换按钮
	@param 	:tag值
	@return :
--]]
function createArrowBtn(p_tag)
	--普通图片路径
	local normalPath
	--高亮图片路径
	local highLightPath

	--按钮位置
	local btnPosX

	if p_tag == tagLeft then
		normalPath = "images/formation/btn_left.png"
		highLightPath = "images/formation/btn_left_h.png"
		btnPosX = 65
	else
		normalPath = "images/formation/btn_right.png"
		highLightPath = "images/formation/btn_right_h.png"
		btnPosX = _secondBgSprite:getContentSize().width - 65
	end
	--常态、点击态、不可点击三态图片
	local normalSprite = addToEmptySprite(CCSprite:create(normalPath))
	local highLightSprite = addToEmptySprite(CCSprite:create(highLightPath))
	local disableSprite = addToEmptySprite(BTGraySprite:create(normalPath))

	local arrowMenuItem = CCMenuItemSprite:create(normalSprite,highLightSprite,disableSprite)
	arrowMenuItem:setAnchorPoint(ccp(0.5,0.5))
	arrowMenuItem:setPosition(ccp(btnPosX,_secondBgSprite:getContentSize().height - 40))
	arrowMenuItem:registerScriptTapHandler(changeCallBack)
	_bgMenu:addChild(arrowMenuItem,1,p_tag)
end

--[[
	@des 	:将按钮设置为不可点
	@param 	:
	@return :
--]]
function disableBtn()
	--最左和最右按钮都不能点
    if _nowVip == 0 then
    	tolua.cast(_bgMenu:getChildByTag(tagLeft),"CCMenuItemSprite"):setEnabled(false)
    elseif _nowVip == tonumber(table.count(DB_Vip.Vip)-1) then
    	print("设置不可点")
    	tolua.cast(_bgMenu:getChildByTag(tagRight),"CCMenuItemSprite"):setEnabled(false)
    end
end

--[[
	@des 	:将按钮设置为可点
	@param 	:
	@return :
--]]
function ableBtn()
    tolua.cast(_bgMenu:getChildByTag(tagLeft),"CCMenuItemSprite"):setEnabled(true)
    tolua.cast(_bgMenu:getChildByTag(tagRight),"CCMenuItemSprite"):setEnabled(true)
end

--[[
	@des 	:创建scrollView
	@param 	:scrollView的高度
	@return :
--]]
function createVIPScrollView(p_height)
	if _vipScrollView ~= nil then
		_vipScrollView:removeFromParentAndCleanup(true)
		_vipScrollView = nil
	end

	--创建ScrollView
	_vipScrollView = CCScrollView:create()
	_vipScrollView:setViewSize(CCSizeMake(_innerBgSprite:getContentSize().width,p_height))
	_vipScrollView:setDirection(kCCScrollViewDirectionVertical)
	_vipScrollView:setTouchPriority(_priority - 1)
	_vipScrollView:setAnchorPoint(ccp(0,0))
	_vipScrollView:setPosition(ccp(0,_innerBgSprite:getContentSize().height - p_height))
	_innerBgSprite:addChild(_vipScrollView,1)

	--内部的layer
	local SVLayer = CCLayer:create()
	SVLayer:setAnchorPoint(ccp(0,0))
	_vipScrollView:setContainer(SVLayer)


	-- 富文本
	local textWidth = _innerBgSprite:getContentSize().width
	require "script/libs/LuaCCLabel"
    local richInfo = {
     	width = textWidth, -- 宽度
        alignment = 1, -- 对齐方式  1 左对齐，2 居中， 3右对齐
        lineAlignment = 2, -- 当前行在竖直方向上的对齐方式 1，下对齐， 2，居中， 3，上对齐
        labelDefaultFont = g_sFontName,
        labelDefaultColor = ccc3(0xff,0xff,0xff),
        labelDefaultSize = 21,
        defaultType = "CCLabelTTF",
        elements = {}
    }
    local dbStr = DB_Vip_desc.getDataById(_nowVip + 1).desc
    local descArr = string.split(dbStr,"\n")
    for i=1, #descArr do
    	local tempArr = string.split(descArr[i],"|")
    	local tipStr = tempArr[1]
    	local strColor = ccc3(0xff,0xff,0xff)
    	local strColorStr = tempArr[2]
    	if( strColorStr ~= nil)then
    		local colorTable = string.split(strColorStr,",")
	    	strColor = ccc3(tonumber(colorTable[1]), tonumber(colorTable[2]),tonumber(colorTable[3]))
    	end
    	local tempTab = {
    		text = tipStr,
            color = strColor,
    	}
    	if(i >1)then
    		tempTab.newLine = true 
    	end
    	table.insert(richInfo.elements,tempTab)
    end

    local richText = LuaCCLabel.createRichLabel(richInfo)
    richText:setAnchorPoint(ccp(0,0))
	richText:setPosition(ccp(15,15))
	SVLayer:addChild(richText)

    local layerHeight = richText:getContentSize().height + 30
	SVLayer:setContentSize(CCSizeMake(textWidth,layerHeight))
	SVLayer:setPosition(ccp(0,p_height - layerHeight))

	--用于箭头的显示与不显示
	_scrollOffset = p_height - layerHeight
end

--[[
	@des 	:奖励预览Cell
	@param 	:物品信息
	@return :创建好的cell
--]]
function createShowGiftCell(p_itemInfo)
	local prizeViewCell = CCTableViewCell:create()

	local itemDelegateAction = function()
    	MainScene.setMainSceneViewsVisible(true, false, true)
    end

	local itemSprite 
    local itemName
    local quality
    if p_itemInfo.type== "item" then
       itemSprite = ItemSprite.getItemSpriteById(p_itemInfo.tid,nil,itemDelegateAction,nil,_priority-5,_zOrder + 100)
       local itemTableInfo = ItemUtil.getItemById(tonumber(p_itemInfo.tid))
       itemName = itemTableInfo.name
       quality = itemTableInfo.quality
    elseif(p_itemInfo.type == "gold") then  
       itemSprite = ItemSprite.getGoldIconSprite()
       itemName= GetLocalizeStringBy("key_2385")
       quality = 5
    elseif(p_itemInfo.type == "silver") then  
       itemSprite = ItemSprite.getBigSilverSprite()
       itemName= GetLocalizeStringBy("key_2889") .. p_itemInfo.num
       quality = 3
    end

    local itemPosX = 565/8

    itemSprite:setPosition(ccp(itemPosX,55))
    itemSprite:setAnchorPoint(ccp(0.5,0))
    prizeViewCell:addChild(itemSprite)

    local itemNumLabel = CCRenderLabel:create(p_itemInfo.num,g_sFontName,18,1,ccc3(0x00,0x00,0x0),type_stroke)
    itemNumLabel:setColor(ccc3(0x00,0xff,0x18))
    itemNumLabel:setAnchorPoint(ccp(1,0))
    itemNumLabel:setPosition(ccp(itemSprite:getContentSize().width - 5,5))
    itemSprite:addChild(itemNumLabel)
    
    local itemNameLabel = CCRenderLabel:create(itemName,g_sFontName,18,1,ccc3(0x00,0x00,0x0),type_stroke)
    itemNameLabel:setColor(HeroPublicLua.getCCColorByStarLevel(quality))
    itemNameLabel:setPosition(ccp(itemPosX,25))
    itemNameLabel:setAnchorPoint(ccp(0.5,0))
    prizeViewCell:addChild(itemNameLabel)

	return prizeViewCell
end

--[[
	@des 	:奖励预览
	@param 	:主背景位置
	@return :
--]]
function createGiftPreview(p_posY)
	if _packBgSprite ~= nil then
		_packBgSprite:removeFromParentAndCleanup(true)
		_packBgSprite = nil
	end

	 --礼包主背景
    _packBgSprite = CCScale9Sprite:create(CCRectMake(20,20,10,10),"images/common/bg/astro_btnbg.png")
    _packBgSprite:setPreferredSize(CCSizeMake(565,185))
    _packBgSprite:setAnchorPoint(ccp(0.5,1))
    _packBgSprite:setPosition(ccp(_innerBgSprite:getContentSize().width/2,p_posY))
    _innerBgSprite:addChild(_packBgSprite,2)

    local items = GiftsPakLayer.getVipItemInfo(true,_nowVip)

    local cellNum = table.count(items)

    local h = LuaEventHandler:create(function(fn,table,a1,a2)
		local r
		if fn == "cellSize" then
			r = CCSizeMake(565/4, 185)
		elseif fn == "cellAtIndex" then
			a2 = createShowGiftCell(items[a1+1])
			r = a2
		elseif fn == "numberOfCells" then
			r = cellNum
		else
			print("other function")
		end

		return r
	end)

	local previewTableView = LuaTableView:createWithHandler(h, CCSizeMake(565, 185))
	previewTableView:setAnchorPoint(ccp(0,0))
	previewTableView:setPosition(ccp(0,0))
	previewTableView:setBounceable(true)
	previewTableView:setDirection(kCCScrollViewDirectionHorizontal)
	previewTableView:reloadData()
	previewTableView:setTouchPriority(_priority - 200)
	_packBgSprite:addChild(previewTableView)

	_bool = true
end

--[[
	@des 	:创建发光箭头
	@param 	:tag值
	@return :
--]]
function createShiningArrow(p_tag)
	local imagesPath
	local posY
	if p_tag == tagUp then
		imagesPath = "images/common/arrow_up_h.png"
		posY = _innerBgSprite:getContentSize().height - 10
	else
		imagesPath = "images/common/arrow_down_h.png"
		posY = _innerBgSprite:getContentSize().height - 360
	end

	local arrowSp = CCSprite:create(imagesPath)
	arrowSp:setPosition(_innerBgSprite:getContentSize().width - 35,posY)
	arrowSp:setAnchorPoint(ccp(0.5,1))
	_innerBgSprite:addChild(arrowSp,10,p_tag)

	--动画
	local arrActions = CCArray:create()
	arrActions:addObject(CCFadeOut:create(1))
	arrActions:addObject(CCFadeIn:create(1))
	local sequence = CCSequence:create(arrActions)
	local action = CCRepeatForever:create(sequence)
	arrowSp:runAction(action)
end

--[[
	@des 	:箭头是否可见
	@param 	: $ p_tag 		:tag值
	@param 	: $ p_visible 	:tag值
	@return :
--]]
function arrowVisible(p_tag,p_visible)
	tolua.cast(_innerBgSprite:getChildByTag(p_tag),"CCSprite"):setVisible(p_visible)
end

--[[
	@des 	:刷新箭头
	@param 	:
	@return :
--]]
function updateArrow()
	if _vipScrollView ~= nil then
		if tonumber(_vipScrollView:getContentOffset().y) <= _scrollOffset then
			arrowVisible(tagUp,false)
			arrowVisible(tagDown,true)
		elseif tonumber(_vipScrollView:getContentOffset().y) >= 0 then
			arrowVisible(tagDown,false)
			arrowVisible(tagUp,true)
		else
			arrowVisible(tagUp,true)
			arrowVisible(tagDown,true)
		end
	end
end

--[[
	@des 	:创建UI
	@param 	:
	@return :
--]]
function createUI()
	--主背景
	local fullRect = CCRectMake(0,0,213,171)
	local insetRect = CCRectMake(84,84,2,3)

	--背景
	local bgSprite = CCScale9Sprite:create("images/common/viewbg1.png",fullRect,insetRect)
	bgSprite:setPreferredSize(CCSizeMake(625,845))
	bgSprite:setAnchorPoint(ccp(0.5,0.5))
	bgSprite:setPosition(ccp(g_winSize.width/2,g_winSize.height/2))
	bgSprite:setScale(g_fElementScaleRatio)
	_bgLayer:addChild(bgSprite)

	--标题背景
	local titleBgSprite= CCSprite:create("images/common/viewtitle1.png")
	titleBgSprite:setPosition(bgSprite:getContentSize().width/2,bgSprite:getContentSize().height-6)
	titleBgSprite:setAnchorPoint(ccp(0.5, 0.5))
	bgSprite:addChild(titleBgSprite)

	--标题
	local titleLabel = CCRenderLabel:create(GetLocalizeStringBy("key_3285"), g_sFontPangWa,33,2,ccc3(0,0,0),type_shadow)
	titleLabel:setColor(ccc3(255,0xe4,0))
	titleLabel:setPosition(ccp(titleBgSprite:getContentSize().width/2,titleBgSprite:getContentSize().height/2))
    titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleBgSprite:addChild(titleLabel)

	--vip等级图片
	local alertContent = {}

    alertContent[1] = CCSprite:create("images/shop/vip_big/vip.png")
    alertContent[2] = LuaCC.createNumberSprite("images/shop/vip_big",UserModel.getVipLevel())
    alertContent[3] = CCSprite:create("images/shop/exp_bg.png")

    local vipNode = BaseUI.createHorizontalNode(alertContent)
    vipNode:setAnchorPoint(ccp(0.5,1))
    vipNode:setPosition(ccp(bgSprite:getContentSize().width/2,bgSprite:getContentSize().height - 50))
    bgSprite:addChild(vipNode)

    --经验条
    local expSprite = CCSprite:create("images/shop/exp_progress.png")
    local rate = _curPayMoney/_levelUpMoney
    if rate ~= 0 and rate < 0.05 then
        rate = 0.05
    end
    expSprite:setTextureRect(CCRectMake(0, 0, expSprite:getContentSize().width*rate, expSprite:getContentSize().height))
    expSprite:setPosition(ccp(0,0))
    expSprite:setAnchorPoint(ccp(0,0))
    alertContent[3]:addChild(expSprite)

    --经验
    local expLabel = CCLabelTTF:create(_curPayMoney .. "/" .. _levelUpMoney ,g_sFontName,20)
    expLabel:setColor(ccc3(0xff,0xff,0xff))
    expLabel:setPosition(ccp(alertContent[3]:getContentSize().width*0.5, alertContent[3]:getContentSize().height*0.5))
    expLabel:setAnchorPoint(ccp(0.5,0.5))
    alertContent[3]:addChild(expLabel)

    --二级背景
    _secondBgSprite = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
    _secondBgSprite:setAnchorPoint(ccp(0.5,1))
    _secondBgSprite:setPosition(ccp(bgSprite:getContentSize().width/2,bgSprite:getContentSize().height - 120))
    _secondBgSprite:setPreferredSize(CCSizeMake(565,680))
    bgSprite:addChild(_secondBgSprite)

    --当前VIP等级
    _nowVip = UserModel.getVipLevel()

    --特权标题
    createVIPNode()

    --二级背景按钮层
	_bgMenu = CCMenu:create()
    _bgMenu:setPosition(ccp(0,0))
    _bgMenu:setTouchPriority(_priority-1)
    _secondBgSprite:addChild(_bgMenu)

    --创建左、右按钮
    createArrowBtn(tagLeft)
    createArrowBtn(tagRight)

    --设置不可点按钮
    disableBtn()

    --内部背景框
    _innerBgSprite = CCScale9Sprite:create("images/common/bg/vip_bg.png")
    _innerBgSprite:setPreferredSize(CCSizeMake(565,595))
    _innerBgSprite:setAnchorPoint(ccp(0.5,1))
    _innerBgSprite:setPosition(ccp(_secondBgSprite:getContentSize().width/2,_secondBgSprite:getContentSize().height - 80))
    _secondBgSprite:addChild(_innerBgSprite)

    --分割线
    local separateSprite = CCScale9Sprite:create("images/common/line02.png")
    separateSprite:setPreferredSize(CCSizeMake(565,5))
    separateSprite:setAnchorPoint(ccp(0.5,0.5))
    separateSprite:setPosition(ccp(_innerBgSprite:getContentSize().width/2,_innerBgSprite:getContentSize().height))
    _innerBgSprite:addChild(separateSprite)

    local scrollViewHeight = 400

    --创建vip特权的scrollView
    createVIPScrollView(scrollViewHeight)

    local packPosY = _innerBgSprite:getContentSize().height - scrollViewHeight

    --礼包标题背景
    local packTitleBgSprite = CCScale9Sprite:create(CCRectMake(25,15,20,10),"images/common/astro_labelbg.png")
    packTitleBgSprite:setPreferredSize(CCSizeMake(245,35))
    packTitleBgSprite:setAnchorPoint(ccp(0.5,1))
    packTitleBgSprite:setPosition(ccp(_innerBgSprite:getContentSize().width/2,packPosY))
    _innerBgSprite:addChild(packTitleBgSprite,3)

    --标题
    _packTitleLabel = CCLabelTTF:create("vip" .. _nowVip .. GetLocalizeStringBy("zzh_1184"),g_sFontPangWa,24)
    _packTitleLabel:setColor(ccc3(0xff,0xf6,0x00))
    _packTitleLabel:setAnchorPoint(ccp(0.5,0.5))
    _packTitleLabel:setPosition(ccp(packTitleBgSprite:getContentSize().width/2,packTitleBgSprite:getContentSize().height/2))
    packTitleBgSprite:addChild(_packTitleLabel)

    createGiftPreview(packPosY - packTitleBgSprite:getContentSize().height/2)

    --箭头
    createShiningArrow(tagUp)
    createShiningArrow(tagDown)

    --上箭头不可见
    arrowVisible(tagUp,false)

   	--定时器
	schedule(_bgLayer,updateArrow,1)
    
    --背景按钮层
    local bgMenu = CCMenu:create()
    bgMenu:setPosition(ccp(0,0))
    bgMenu:setTouchPriority(_priority-1)
    bgSprite:addChild(bgMenu)

    --关闭按钮
    local closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    closeBtn:setPosition(ccp(bgSprite:getContentSize().width*1.02, bgSprite:getContentSize().height*1.02))
    closeBtn:setAnchorPoint(ccp(1,1))
    closeBtn:registerScriptTapHandler(closeCallBack)
    bgMenu:addChild(closeBtn)
end

--[[
	@des 	:入口函数，因为其他界面调用的缘故，所以原来的入口函数名称保留
	@param 	:$p_touchPriority 		:触摸优先级
	@param 	:$p_zOrder 				:zOrder
	@return :
--]]
function addPopLayer(p_touchPriority,p_zOrder)
	init()

	--触摸优先级和zOrder保持和阳仔代码一致
	_priority = p_touchPriority or -555
	_zOrder = p_zOrder or 1500

	--背景屏蔽层
	_bgLayer = CCLayerColor:create(ccc4(11,11,11,166))
	_bgLayer:setTouchEnabled(true)
	_bgLayer:registerScriptTouchHandler(layerToucCb,false,_priority,true)

	local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,_zOrder)

	--处理VIP相关数据
	dealData()

	--创建UI
	createUI()
end
