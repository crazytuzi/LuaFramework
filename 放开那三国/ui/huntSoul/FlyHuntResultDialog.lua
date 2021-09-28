-- FileName: FlyHuntResultDialog.lua 
-- Author: licong 
-- Date: 15/11/4 
-- Purpose: 极速猎魂结果展示


module("FlyHuntResultDialog", package.seeall)

local _bgLayer 						= nil
local _backGround 					= nil

local _showItems 					= nil
local _costNum 						= nil
local _fsExpNum 					= nil
local _materials 					= nil

local _zOrder 						= nil
local _touchPriority 				= nil

--[[
	@des 	:初始化
	@param 	:
	@return :
--]]
function init( ... )
	_bgLayer 						= nil
	_backGround 					= nil

	_showItems 						= nil
	_costNum 						= nil
	_fsExpNum 						= nil
	_materials 						= nil

	_zOrder 						= nil
	_touchPriority 					= nil
end

--[[
	@des 	:touch事件处理
	@param 	:
	@return :
--]]
function layerTouch(eventType, x, y)
    return true
end

--[[
	@des 	:关闭按钮
	@param 	:
	@return :
--]]
function closeBtnCallback( ... )
	-- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
	if(_bgLayer)then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
end

--[[
	@des 	:创建ScrollView
	@param 	:
	@return :
--]]
function createScrollView( ... )
	-- ScrollView
	local scrollView = CCScrollView:create()
	scrollView:setTouchPriority(_touchPriority-2)
	local scrollViewHeight = _backGround:getContentSize().height - 50
	scrollView:setViewSize(CCSizeMake(_backGround:getContentSize().width-10, scrollViewHeight))
	scrollView:setDirection(kCCScrollViewDirectionVertical)

	local contentLayer = CCLayer:create()

	-- 计算高度
	local contentHeight = 0

	-- 消耗的银币
	local costFont = CCRenderLabel:create(GetLocalizeStringBy("lic_1716"), g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    costFont:setColor(ccc3(0x00, 0xff, 0x18))
    costFont:setAnchorPoint(ccp(0.5,1))
    contentLayer:addChild(costFont)
    contentHeight =  contentHeight + costFont:getContentSize().height + 10

    -- 消耗银币数量
    local costNumFont = CCRenderLabel:create(_costNum, g_sFontName, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    costNumFont:setColor(ccc3(0xff, 0xff, 0xff))
    costNumFont:setAnchorPoint(ccp(0.5,1))
    contentLayer:addChild(costNumFont)
    contentHeight =  contentHeight + costNumFont:getContentSize().height + 10

	-- 获得战魂标题
	local fsFont = CCRenderLabel:create(GetLocalizeStringBy("lic_1717"), g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    fsFont:setColor(ccc3(0x00, 0xff, 0x18))
    fsFont:setAnchorPoint(ccp(0.5,1))
    contentLayer:addChild(fsFont)
    contentHeight =  contentHeight + fsFont:getContentSize().height + 40

    -- 获得的战魂
    contentHeight = contentHeight + math.ceil(#_showItems/4)*40 + 30

   	-- 获得战魂经验
   	local fsExpFont = CCRenderLabel:create(GetLocalizeStringBy("lic_1718"), g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    fsExpFont:setColor(ccc3(0x00, 0xff, 0x18))
    fsExpFont:setAnchorPoint(ccp(0.5,1))
    contentLayer:addChild(fsExpFont)
    contentHeight =  contentHeight + fsExpFont:getContentSize().height + 10

    -- 战魂经验数量
    local fsExpNumFont = CCRenderLabel:create(_fsExpNum, g_sFontName, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    fsExpNumFont:setColor(ccc3(0xff, 0xff, 0xff))
    fsExpNumFont:setAnchorPoint(ccp(0.5,1))
    contentLayer:addChild(fsExpNumFont)
    contentHeight =  contentHeight + fsExpNumFont:getContentSize().height + 10

    -- 获得材料标题
    local materialFont = CCRenderLabel:create(GetLocalizeStringBy("lic_1719"), g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    materialFont:setColor(ccc3(0x00, 0xff, 0x18))
    materialFont:setAnchorPoint(ccp(0.5,1))
    contentLayer:addChild(materialFont)
    contentHeight =  contentHeight + materialFont:getContentSize().height + 10

    -- 获得的材料
    contentHeight = contentHeight + table.count(_materials)*30 + 20

	--  设置contentLayer
	print("contentHeight==>",contentHeight)
	contentLayer:setContentSize(CCSizeMake(scrollView:getViewSize().width,contentHeight))
	scrollView:setContainer(contentLayer)
	scrollView:ignoreAnchorPointForPosition(false)
	scrollView:setAnchorPoint(ccp(0.5,0.5))
	scrollView:setPosition(ccp(_backGround:getContentSize().width*0.5,_backGround:getContentSize().height*0.5))
	_backGround:addChild(scrollView)
	scrollView:setContentOffset(ccp(0,scrollView:getViewSize().height-contentLayer:getContentSize().height))

	-- 设置坐标
	costFont:setPosition(ccp(contentLayer:getContentSize().width*0.5,contentLayer:getContentSize().height-20))
	costNumFont:setPosition(ccp(contentLayer:getContentSize().width*0.5, costFont:getPositionY()-costFont:getContentSize().height-10))
	fsFont:setPosition(ccp(contentLayer:getContentSize().width*0.5, costNumFont:getPositionY()-costNumFont:getContentSize().height-10))

	local posX = {70,190,290,390}
    local posY = fsFont:getPositionY()-fsFont:getContentSize().height-40
	if( table.isEmpty(_showItems) )then 
   		local tipFont = CCRenderLabel:create(GetLocalizeStringBy("lic_1223"),g_sFontName,21,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		tipFont:setColor(ccc3(0xff,0xff,0xff))
		tipFont:setAnchorPoint(ccp(0.5,0))
		tipFont:setPosition(ccp(contentLayer:getContentSize().width*0.5, posY ))
		contentLayer:addChild(tipFont)
   else
	    for i=0,#_showItems-1 do 
	    	local curPosY = posY-math.floor(i/4)*40
	    	local fsData = ItemUtil.getItemById(_showItems[i+1])
	    	local nameColor = HeroPublicLua.getCCColorByStarLevel(fsData.quality)
	    	local fsNameFont = CCRenderLabel:create(fsData.name,g_sFontName,21,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			fsNameFont:setColor(nameColor)
			fsNameFont:setAnchorPoint(ccp(0,0))
			fsNameFont:setPosition(ccp(posX[i%4+1], curPosY ))
			contentLayer:addChild(fsNameFont)
	    end
	end
	
    local posY = posY-math.ceil(#_showItems/4)*40-10
    fsExpFont:setPosition(ccp(contentLayer:getContentSize().width*0.5, posY))
    fsExpNumFont:setPosition(ccp(contentLayer:getContentSize().width*0.5, fsExpFont:getPositionY()-fsExpFont:getContentSize().height-10))
    materialFont:setPosition(ccp(contentLayer:getContentSize().width*0.5, fsExpNumFont:getPositionY()-fsExpNumFont:getContentSize().height-10))

   local posY1 = materialFont:getPositionY()-materialFont:getContentSize().height-10
   if( table.isEmpty(_materials) )then 
   		local tipFont = CCRenderLabel:create(GetLocalizeStringBy("lic_1223"),g_sFontName,21,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		tipFont:setColor(ccc3(0xff,0xff,0xff))
		tipFont:setAnchorPoint(ccp(0.5,0))
		tipFont:setPosition(ccp(contentLayer:getContentSize().width*0.5, posY1 ))
		contentLayer:addChild(tipFont)
   else
	   local i = 1
	   for k_id,v_num in pairs(_materials) do 
	    	posY1 = posY1-30
	    	i = i+1
	    	local itemData = ItemUtil.getItemById(k_id)
	    	local nameColor = HeroPublicLua.getCCColorByStarLevel(itemData.quality)
	    	local itemNameFont = CCRenderLabel:create(itemData.name .. "X" .. v_num,g_sFontName,21,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			itemNameFont:setColor(nameColor)
			itemNameFont:setAnchorPoint(ccp(0.5,0))
			itemNameFont:setPosition(ccp(contentLayer:getContentSize().width*0.5, posY1 ))
			contentLayer:addChild(itemNameFont)
	    end
	end
end

--[[
	@des 	:获得的战魂提示框
	@param 	:p_items 获得的所有战魂,p_fs_exp:获得战魂经验, p_costCoin:实际花费银币, p_material:材料
	@return :
--]]
function showTip( p_items, p_fs_exp, p_costCoin, p_material, p_zOrder, p_touchPriority )
	_showItems = HuntSoulData.getSortData(p_items)
	_fsExpNum = p_fs_exp 
	_costNum = p_costCoin 
	_materials = p_material
	_zOrder = p_zOrder or 1010
	_touchPriority = p_touchPriority or -530

	_bgLayer = CCLayerColor:create(ccc4(11,11,11,200))
    _bgLayer:setTouchEnabled(true)
    _bgLayer:registerScriptTouchHandler(layerTouch,false,_touchPriority,true)
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,_zOrder,1)

	-- 创建背景
	local fullRect = CCRectMake(0,0,170,158)
	local insetRect = CCRectMake(65,65,5,5)
	_backGround = CCScale9Sprite:create("images/common/bg/bg3.png", fullRect, insetRect)
    _backGround:setContentSize(CCSizeMake(550, 490))
    _backGround:setAnchorPoint(ccp(0.5,0.5))
    _backGround:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
    _bgLayer:addChild(_backGround)
    -- 适配
    setAdaptNode(_backGround)

	-- 关闭按钮
	local menuBar = CCMenu:create()
    menuBar:setTouchPriority(_touchPriority-4)
	menuBar:setPosition(ccp(0, 0))
	menuBar:setAnchorPoint(ccp(0, 0))
	_backGround:addChild(menuBar,3)
	-- 确定
	local closeBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(146, 73), GetLocalizeStringBy("lic_1097"),ccc3(0xfe, 0xdb, 0x1c),28,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	closeBtn:setAnchorPoint(ccp(0.5, 1))
	closeBtn:setPosition(ccp( _backGround:getContentSize().width*0.5, 0 ))
	menuBar:addChild(closeBtn)
	closeBtn:registerScriptTapHandler(closeBtnCallback)

	-- 创建滑动列表
	createScrollView()
end











