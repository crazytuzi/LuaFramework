-- FileName: TransformGodLayer.lua 
-- Author: licong 
-- Date: 16/3/1 
-- Purpose: 转换神兵主界面


module("TransformGodLayer", package.seeall)
require "script/ui/item/GodWeaponItemUtil"
require "script/libs/LuaCCSprite"
require "script/ui/transform/TransformGodData"
require "script/ui/transform/TransformGodController"

local _bgLayer 							= nil
local _bgSprite 						= nil
local _leftStageSp 						= nil
local _rightStageSp 					= nil
local _menuBar 							= nil
local _leftFixAttrSp 					= nil
local _rightFixAttrSp 					= nil
local _backBtn 							= nil
local _orientationBtn 					= nil
local _replaceBtn 						= nil
local _maskLayer 						= nil

local _layerSize 						= nil
local _leftItemInfo 					= nil
local _rightItemInfo 					= nil
local _chooseTid 						= nil
local _costNum 							= nil

local _touchPriority 					= -200

--[[
	@des 	: 创建主界面
	@param 	: 
	@return : 
--]]
function init()
	_bgLayer 							= nil
	_bgSprite 							= nil
	_leftStageSp 						= nil
	_rightStageSp 						= nil
	_menuBar 							= nil
	_leftFixAttrSp 						= nil
	_rightFixAttrSp 					= nil
	_backBtn 							= nil
	_orientationBtn 					= nil
	_replaceBtn 						= nil
	_maskLayer 							= nil

	_layerSize 							= nil
	_leftItemInfo 						= nil
	_rightItemInfo 						= nil
	_chooseTid 							= nil
	_costNum 							= nil
end

--[[
	@des 	:回调onEnter和onExit事件
	@param 	:
	@return :
--]]
function onNodeEvent( event )
	if (event == "enter") then
	elseif (event == "exit") then
	end
end

--[[
	@des 	: 神兵预览
	@param 	: 
	@return : 
--]]
function previewCallback( tag, menuItem )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/changtiaoxing.mp3")

	require "script/ui/transform/TsGodPreviewLayer"
	TsGodPreviewLayer.showLayer( nil, _touchPriority-230, 1010 )
end

--[[
	@des 	: 返回替换操作
	@param 	: 
	@return : 
--]]
function backCallback( tag, menuItem )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/changtiaoxing.mp3")

	_chooseTid = nil
	_rightItemInfo = nil
	refreshRihgtUI()
end

--[[
	@des 	: 替换操作
	@param 	: 
	@return : 
--]]
function replaceCallback( tag, menuItem )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/changtiaoxing.mp3")

	local nextCallFun = function ( p_retItemId )
		-- 特效
        local effectSp = XMLSprite:create("images/base/effect/bianshen/bianshen")
	    effectSp:setAnchorPoint(ccp(0.5,0.5))
	    effectSp:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.73))
	    _bgLayer:addChild(effectSp,100)
	    effectSp:setReplayTimes(1)
	    effectSp:setScale(g_fElementScaleRatio)
        effectSp:registerEndCallback(function ( ... )
        	_leftItemInfo = table.hcopy(_rightItemInfo, {})
        	_leftItemInfo.item_id = p_retItemId
        	_rightItemInfo = nil
        	_chooseTid = nil
        	_costNum = nil
        	-- 清除选择的
			TransformGodData.cleanSelectGodList()
			--  添加新的
			TransformGodData.addGodToSelectList(_leftItemInfo.item_id)
        	-- 刷新UI
        	createLeftStageUI(_leftItemInfo)
        	refreshRihgtUI()
        	if( not tolua.isnull(_maskLayer) )then
				_maskLayer:removeFromParentAndCleanup(true)
				_maskLayer = nil
			end
        end)
	end

	-- 二次确认框
    local yesCallBack = function ( ... )
    	-- 加屏蔽层 
		if( not tolua.isnull(_maskLayer) )then
			_maskLayer:removeFromParentAndCleanup(true)
			_maskLayer = nil
		end

        local isSend = TransformGodController.transformGodWp( _leftItemInfo.item_id, _leftItemInfo.item_template_id, _chooseTid, _costNum, nextCallFun)
    	-- 发送了请求才加屏蔽层
    	if (isSend) then
	    	_maskLayer = BaseUI.createMaskLayer(-5000,nil,nil,0)
			local runningScene = CCDirector:sharedDirector():getRunningScene()
			runningScene:addChild(_maskLayer, 10000)
    	end
    end

    local tipNode = CCNode:create()
    tipNode:setContentSize(CCSizeMake(400,100))
    local textInfo = {
            width = 400, -- 宽度
            alignment = 1, -- 对齐方式  1 左对齐，2 居中， 3右对齐
            labelDefaultFont = g_sFontName,      -- 默认字体
            labelDefaultSize = 25,          -- 默认字体大小
            labelDefaultColor = ccc3(0x78,0x25,0x00),
            linespace = 10, -- 行间距
            defaultType = "CCLabelTTF",
            elements =
            {   
                {
                    type = "CCLabelTTF", 
                    text = _costNum,
                    color = ccc3(0x78,0x25,0x00),
                },
                {
                    type = "CCSprite", 
                    image = "images/common/gold.png",
                },
            }
        }
    local tipDes = GetLocalizeLabelSpriteBy_2("lic_1802", textInfo)
    tipDes:setAnchorPoint(ccp(0.5, 0.5))
    tipDes:setPosition(ccp(tipNode:getContentSize().width*0.5,tipNode:getContentSize().height*0.5))
    tipNode:addChild(tipDes)
    require "script/ui/tip/TipByNode"
    TipByNode.showLayer(tipNode,yesCallBack,CCSizeMake(500,360))
end

--[[
	@des 	: 定向变身
	@param 	: 
	@return : 
--]]
function orientationCallback( tag, menuItem )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/changtiaoxing.mp3")

	if(_leftItemInfo == nil)then
		-- 没有选择神兵
		AnimationTip.showTip( GetLocalizeStringBy("lic_1796"))
		return
	end

	require "script/ui/transform/GodOrientationLayer"
	GodOrientationLayer.showLayer( _leftItemInfo.item_template_id, refreshRihgtUI, _touchPriority-230, 1010 )
end

--[[
	@des 	: 加号按钮
	@param 	: 
	@return : 
--]]
function addMenuItemAction( tag, menuItem )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/changtiaoxing.mp3")

	require "script/ui/transform/TsGodChooseLayer"
	TsGodChooseLayer.showLayer( refreshLeftUI, _touchPriority-230, 1010 )
end

--[[
	@des 	: 刷新左边台子
	@param 	: 
	@return : 
--]]
function refreshLeftUI()
	local chooseItemidTab = TransformGodData.getSelectGodList()
	_leftItemInfo = ItemUtil.getItemByItemId(chooseItemidTab[1].item_id)
	-- 刷新左边台子
    createLeftStageUI(_leftItemInfo)
  	-- 刷新下边按钮
  	refreshBottomBtn()
end

--[[
	@des 	: 刷新左边台子
	@param 	: 
	@return : 
--]]
function refreshRihgtUI( p_chooseTid )
	if( p_chooseTid )then
		_chooseTid = p_chooseTid
		_rightItemInfo = table.hcopy(_leftItemInfo, {})
		_rightItemInfo.item_template_id = _chooseTid
		_rightItemInfo.itemDesc = ItemUtil.getItemById(_chooseTid)
	end
	-- 刷新左边台子
    createRightStageUI(_rightItemInfo)
  	-- 刷新下边按钮
  	refreshBottomBtn()
end

--[[
	@des 	: 刷新按钮
	@param 	: 
	@return : 
--]]
function refreshBottomBtn()
	if( _rightItemInfo == nil )then
		_orientationBtn:setVisible(true)
		_backBtn:setVisible(false)
		if(not tolua.isnull(_replaceBtn))then 
			_replaceBtn:removeFromParentAndCleanup(true)
			_replaceBtn = nil
		end
	else
		_orientationBtn:setVisible(false)
		_backBtn:setVisible(true)

		-- 替换按钮
		if(not tolua.isnull(_replaceBtn))then 
			_replaceBtn:removeFromParentAndCleanup(true)
			_replaceBtn = nil
		end
	    local evolveNum = 0
	    if(_leftItemInfo and _leftItemInfo.va_item_text.evolveNum )then
	    	evolveNum = tonumber(_leftItemInfo.va_item_text.evolveNum)
	    end
	    _costNum = TransformGodData.getTransformCostBy(evolveNum)
	    local replacerBtnInfo = {
	        normal      = "images/common/btn/btn_purple2_n.png",                   		-- 正常状态的图片
	        selected    = "images/common/btn/btn_purple2_h.png",                   		-- 按下状态的图片
	        disabled    = nil,                          		-- 不可点击时的图片
	        size        = CCSizeMake(240, 73),          		-- 按钮尺寸
	        icon        = "images/common/gold.png",     		-- 数字前的小图标
	        text        = GetLocalizeStringBy("key_8323"),   	-- 按钮上的文字
	        text_size   = 32,                           		-- 文字的尺寸
	        number      = tostring(_costNum),       			-- 数字 string类型的
	        number_size = 21,                           		-- 数字尺寸
	    }
	    _replaceBtn = LuaCCSprite.createNumberMenuItem(replacerBtnInfo)
	    _menuBar:addChild(_replaceBtn)
	    _replaceBtn:setAnchorPoint(ccp(0.5, 0))
	    _replaceBtn:setPosition(ccp(_bgLayer:getContentSize().width * 0.7, 10*g_fElementScaleRatio))
	    _replaceBtn:registerScriptTapHandler(replaceCallback)
	    _replaceBtn:setScale(g_fElementScaleRatio)
	end
end

--[[
	@des 	: 创建神兵形象
	@param 	: 
	@return : 
--]]
function createGodWpSp( p_itemInfo, p_parent )
	--神兵全身像
	local bodySprite = GodWeaponItemUtil.getWeaponBigSprite(nil,nil,nil,p_itemInfo,nil,false)
	p_parent:addChild(bodySprite)
	bodySprite:setAnchorPoint(ccp(0.5,0))
	bodySprite:setPosition(ccp(p_parent:getContentSize().width*0.5, p_parent:getContentSize().height*0.7))
	bodySprite:setScale(0.5)
	--五行图片
	local fiveSprite = CCSprite:create("images/god_weapon/five/" .. p_itemInfo.itemDesc.type .. ".png")
	fiveSprite:setAnchorPoint(ccp(0,0.5))
	fiveSprite:setPosition(ccp(20,p_parent:getContentSize().height))
	p_parent:addChild(fiveSprite,10)
	fiveSprite:setScale(0.7)
	-- 等级名字
	local nameBgSprite = CCScale9Sprite:create("images/common/bg/bg_9s_2.png")
	nameBgSprite:setContentSize(CCSizeMake(215,32))
	nameBgSprite:setAnchorPoint(ccp(0.5,0))
	nameBgSprite:setPosition(ccp(p_parent:getContentSize().width*0.5,0))
	p_parent:addChild(nameBgSprite,10)

	local quality,evolveNum,showEvolveNum = GodWeaponItemUtil.getGodWeaponQualityAndEvolveNum(nil,nil,p_itemInfo)
	local nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
	local textInfo = {
        alignment = 2, -- 对齐方式  1 左对齐，2 居中， 3右对齐
        lineAlignment = 2, -- 当前行在竖直方向上的对齐方式 1，下对齐， 2，居中， 3，上对齐
        labelDefaultFont = g_sFontName,      -- 默认字体
        labelDefaultColor = nameColor,  -- 默认字体颜色
        labelDefaultSize = 21,          -- 默认字体大小
        defaultType = "CCRenderLabel",
        defaultStrokeSize = 1,
        elements =
        {	
        	{	
        		type = "CCSprite",
        		image = "images/common/lv.png",
        	},
        	{	
        		text = p_itemInfo.va_item_text.reinForceLevel,
        		color = ccc3(0xff,0xf6,0x00),
        	},
            {
                text = " " .. p_itemInfo.itemDesc.name .. showEvolveNum .. GetLocalizeStringBy("zzh_1159"), 
                font = g_sFontPangWa,                  
            }
        }
 	}
 	local nameLabel = LuaCCLabel.createRichLabel(textInfo)
 	nameBgSprite:addChild(nameLabel)
 	nameLabel:setAnchorPoint(ccp(0.5,0.5))
 	nameLabel:setPosition(nameBgSprite:getContentSize().width*0.5,nameBgSprite:getContentSize().height*0.5)
end

--[[
	@des 	: 创建神兵洗练属性
	@param 	: 
	@return : 
--]]
function createGodWpFixSp( p_itemInfo )
	local retSprite =  CCScale9Sprite:create("images/common/bg/astro_btnbg.png")
	retSprite:setContentSize(CCSizeMake(200, 230))

	-- ScrollView
	local scrollView = CCScrollView:create()
	scrollView:setTouchPriority(_touchPriority)
	retSprite:addChild(scrollView)
	scrollView:setViewSize(CCSizeMake(retSprite:getContentSize().width, retSprite:getContentSize().height-20))
	scrollView:setDirection(kCCScrollViewDirectionVertical)
	scrollView:ignoreAnchorPointForPosition(false)
	scrollView:setAnchorPoint(ccp(0.5,0.5))
	scrollView:setPosition(ccp(retSprite:getContentSize().width*0.5,retSprite:getContentSize().height*0.5))

	-- 内容
	local contentLayer = CCLayer:create()
	local contentHeight = 0
	local titleFontArr = {}
	local tipFontArr = {}
	local attrNameFontArr = {}
	local attrDesFontArr = {}
	-- 洗练的总层数
	require "script/ui/godweapon/godweaponfix/GodWeaponFixData"
	local allFixNum = GodWeaponFixData.getGodWeapinFixNum(nil,nil,p_itemInfo)
	-- print("allFixNum",allFixNum)
	for fixId=1,allFixNum do
		-- 第几层
		-- 绿 蓝 紫 橙
		local colorArr = {ccc3(0, 0xeb, 0x21),ccc3(0x51, 0xfb, 0xff),ccc3(255, 0, 0xe1),ccc3(255, 0x84, 0),ccc3(0xff,0x00,0x00)}
		local titleArr = {GetLocalizeStringBy("lic_1457"),GetLocalizeStringBy("lic_1458"),GetLocalizeStringBy("lic_1459"),GetLocalizeStringBy("lic_1460"),GetLocalizeStringBy("llp_515")}
		local titleFont = CCRenderLabel:create(GetLocalizeStringBy("lic_1456",titleArr[fixId]) ,g_sFontPangWa,20,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		titleFont:setColor(colorArr[fixId])
		titleFont:setAnchorPoint(ccp(0,0))
		contentLayer:addChild(titleFont)
		local lineSp = CCSprite:create("images/god_weapon/cut_line.png")
		titleFont:addChild(lineSp)
		lineSp:setAnchorPoint(ccp(1,0.5))
		lineSp:setPosition(titleFont:getContentSize().width+3,titleFont:getContentSize().height*0.5)
		lineSp:setScaleX(-0.3)
		titleFontArr[fixId] = titleFont
		contentHeight = contentHeight+30
		-- 属性名字
		local attrId = nil
		if( not table.isEmpty(p_itemInfo.va_item_text.confirmed) )then
			attrId = p_itemInfo.va_item_text.confirmed[tostring(fixId)]
		end
		-- print("attrId==>",attrId)
		if( attrId == nil)then
			-- 无属性
			local tipFont = CCRenderLabel:create(GetLocalizeStringBy("lic_1480") ,g_sFontName,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			tipFont:setColor(ccc3(0xff,0xff,0xff))
			tipFont:setAnchorPoint(ccp(0,0))
			contentLayer:addChild(tipFont)
			tipFontArr[fixId] = tipFont
			contentHeight = contentHeight+30
		else
			local attrInfo = GodWeaponFixData.getGodWeapinFixAttrInfoById(attrId)
			-- print("attrInfo==>")
			-- print_t(attrInfo)
			local attrColor = GodWeaponFixData.getGodWeapinFixAttrColor( nil, fixId, attrId, p_itemInfo )
			-- 属性名字
			local attrNameFont = CCRenderLabel:create(attrInfo.name,g_sFontName,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			attrNameFont:setColor(attrColor)
			attrNameFont:setAnchorPoint(ccp(0,0))
			contentLayer:addChild(attrNameFont)
			attrNameFontArr[fixId] = attrNameFont
			contentHeight = contentHeight+30
			-- 属性描述
			local attrDesFont = CCRenderLabel:create(attrInfo.dis,g_sFontName,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
			attrDesFont:setColor(ccc3(0xff,0xff,0xff))
			attrDesFont:setAnchorPoint(ccp(0,0))
			contentLayer:addChild(attrDesFont)
			attrDesFontArr[fixId] = attrDesFont
			contentHeight = contentHeight+30
		end
	end

	-- 设置scrollview
	contentLayer:setContentSize(CCSizeMake(retSprite:getContentSize().width,contentHeight))
	scrollView:setContainer(contentLayer)
	scrollView:setContentOffset(ccp(0,scrollView:getViewSize().height-contentLayer:getContentSize().height))

	-- 设置位置
	local posY = contentLayer:getContentSize().height
	for i=1,allFixNum do
		if(titleFontArr[i])then
			posY = posY - 30
			titleFontArr[i]:setPosition(ccp(10,posY))
		end
		if(tipFontArr[i])then
			posY = posY - 30
			tipFontArr[i]:setPosition(ccp(40,posY))
		end
		if(attrNameFontArr[i])then
			posY = posY - 30
			attrNameFontArr[i]:setPosition(ccp(40,posY))
		end
		if(attrDesFontArr[i])then
			posY = posY - 30
			attrDesFontArr[i]:setPosition(ccp(40,posY))
		end
	end

	return retSprite
end

--[[
	@des 	: 创建左边台子
	@param 	: 
	@return : 
--]]
function createLeftStageUI( p_itemInfo )
	if(not tolua.isnull(_leftStageSp))then
		_leftStageSp:removeFromParentAndCleanup(true)
		_leftStageSp = nil
	end
	if(not tolua.isnull(_leftFixAttrSp))then
		_leftFixAttrSp:removeFromParentAndCleanup(true)
		_leftFixAttrSp = nil
	end
	
	_leftStageSp = CCSprite:create("images/transform/god_tai.png")
	_leftStageSp:setAnchorPoint(ccp(0.5,0.5))
	_leftStageSp:setPosition(_layerSize.width*0.25,_layerSize.height*0.6)
	_bgLayer:addChild(_leftStageSp)
	_leftStageSp:setScale(g_fElementScaleRatio)

	-- 加号
	local menu = CCMenu:create()
	_leftStageSp:addChild(menu)
	menu:setPosition(0,0)
	menu:setTouchPriority(_touchPriority)
	local sprite_n = CCSprite:create()
	sprite_n:setContentSize(CCSizeMake(80,80))
	local sprite_h = CCSprite:create()
	sprite_h:setContentSize(CCSizeMake(80,80))
	local addMenuItem = CCMenuItemSprite:create(sprite_n,sprite_h)
	addMenuItem:setAnchorPoint(ccp(0.5, 0.5))
	addMenuItem:setPosition(ccp(_leftStageSp:getContentSize().width*0.5, _leftStageSp:getContentSize().height+30))
	menu:addChild(addMenuItem)
	-- 注册回调
	addMenuItem:registerScriptTapHandler(addMenuItemAction)

	if( p_itemInfo == nil)then
		-- 加号
		local addIcon = ItemSprite.createLucencyAddSprite()
		addMenuItem:addChild(addIcon)
		addIcon:setAnchorPoint(ccp(0.5, 0.5))
	    addIcon:setPosition(ccp(addMenuItem:getContentSize().width*0.5, addMenuItem:getContentSize().height*0.5))
		local addTip = CCRenderLabel:create(GetLocalizeStringBy("lic_1794"), g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
	    addIcon:addChild(addTip)
	    addTip:setAnchorPoint(ccp(0.5, 1))
	    addTip:setPosition(ccp(addIcon:getContentSize().width*0.5, 5))
	    addTip:setColor(ccc3(0x00, 0xff, 0x18))
	else
		-- 创建神兵
		createGodWpSp( p_itemInfo, _leftStageSp )
		-- 创建神兵洗练属性
		_leftFixAttrSp = createGodWpFixSp(p_itemInfo)
		_bgLayer:addChild(_leftFixAttrSp)
		_leftFixAttrSp:setAnchorPoint(ccp(0.5,0.5))
		_leftFixAttrSp:setPosition(_layerSize.width*0.2,_layerSize.height*0.3)
		_leftFixAttrSp:setScale(g_fElementScaleRatio)
	end
end

--[[
	@des 	: 创建右边台子
	@param 	: 
	@return : 
--]]
function createRightStageUI( p_itemInfo )
	if(  not tolua.isnull(_rightStageSp) )then 
		_rightStageSp:removeFromParentAndCleanup(true)
		_rightStageSp = nil
	end
	if(not tolua.isnull(_rightFixAttrSp))then
		_rightFixAttrSp:removeFromParentAndCleanup(true)
		_rightFixAttrSp = nil
	end

	_rightStageSp = CCSprite:create("images/transform/god_tai.png")
	_rightStageSp:setAnchorPoint(ccp(0.5,0.5))
	_rightStageSp:setPosition(_layerSize.width*0.75,_layerSize.height*0.6)
	_bgLayer:addChild(_rightStageSp)
	_rightStageSp:setScale(g_fElementScaleRatio)

	if( p_itemInfo == nil)then

		local unknowSp = CCSprite:create("images/common/question_mask.png")
        _rightStageSp:addChild(unknowSp)
        unknowSp:setAnchorPoint(ccp(0.5, 0.5))
        unknowSp:setPosition(ccp(_rightStageSp:getContentSize().width*0.5, _rightStageSp:getContentSize().height+30))
	else
		-- 创建神兵
		createGodWpSp( p_itemInfo, _rightStageSp )
		-- 创建神兵洗练属性
		_rightFixAttrSp = createGodWpFixSp(p_itemInfo)
		_bgLayer:addChild(_rightFixAttrSp)
		_rightFixAttrSp:setAnchorPoint(ccp(0.5,0.5))
		_rightFixAttrSp:setPosition(_layerSize.width*0.8,_layerSize.height*0.3)
		_rightFixAttrSp:setScale(g_fElementScaleRatio)
	end
end

--[[
	@des 	: 创建底部按钮
	@param 	: 
	@return : 
--]]
function createBottomBtn()
    -- 返回按钮
    _backBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_purple2_n.png", "images/common/btn/btn_purple2_h.png", CCSizeMake(240, 73), GetLocalizeStringBy("key_10014"), ccc3(0xfe, 0xdb, 0x1c), 32, g_sFontPangWa, 1, ccc3(0x00, 0x00, 0x00))
    _menuBar:addChild(_backBtn)
    _backBtn:setAnchorPoint(ccp(0.5, 0))
    _backBtn:setPosition(ccp(_bgLayer:getContentSize().width * 0.3, 10*g_fElementScaleRatio))
    _backBtn:registerScriptTapHandler(backCallback)
    _backBtn:setScale(g_fElementScaleRatio)
    _backBtn:setVisible(false)

    -- 定向变身按钮
    _orientationBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_purple2_n.png", "images/common/btn/btn_purple2_h.png", CCSizeMake(240, 73), GetLocalizeStringBy("key_10263"), ccc3(0xfe, 0xdb, 0x1c), 32, g_sFontPangWa, 1, ccc3(0x00, 0x00, 0x00))
    _menuBar:addChild(_orientationBtn)
    _orientationBtn:setAnchorPoint(ccp(0.5, 0))
    _orientationBtn:setPosition(ccp(_bgLayer:getContentSize().width * 0.5, 10*g_fElementScaleRatio))
    _orientationBtn:registerScriptTapHandler(orientationCallback)
    _orientationBtn:setScale(g_fElementScaleRatio)
    
end

--[[
	@des 	: 创建主界面
	@param 	: 
	@return : 
--]]
function createLayer( p_layerSize )
	-- 初始化
	init()

	TransformGodData.cleanSelectGodList()

	-- 界面
	_layerSize = p_layerSize
	_bgLayer = CCLayer:create()
	_bgLayer:registerScriptHandler(onNodeEvent) 
	_bgLayer:setContentSize(_layerSize)

	-- 大背景
    _bgSprite = CCSprite:create("images/transform/god_bg.png")
    _bgSprite:setAnchorPoint(ccp(0.5,0.5))
    _bgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
    _bgLayer:addChild(_bgSprite)
    _bgSprite:setScale(g_fBgScaleRatio)

    -- 创建左边台子
    createLeftStageUI()
    -- 创建右边台子
    createRightStageUI()
    -- 箭头
    local arrow = CCSprite:create("images/hero/transfer/arrow.png")
    arrow:setAnchorPoint(ccp(0.5, 0.5))
    arrow:setPosition(ccp(_layerSize.width*0.5, _layerSize.height *0.7))
    _bgLayer:addChild(arrow)
    arrow:setScale(0.7 * g_fElementScaleRatio)
    
    -- 按钮
    _menuBar = CCMenu:create()
    _bgLayer:addChild(_menuBar,5)
    _menuBar:setPosition(ccp(0, 0))
    _menuBar:setTouchPriority(_touchPriority)

    -- 神兵预览
    local previewBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png", "images/common/btn/btn_blue_h.png", CCSizeMake(160, 73), GetLocalizeStringBy("lic_1793"), ccc3(0xfe, 0xdb, 0x1c), 30, g_sFontPangWa, 1, ccc3(0x00, 0x00, 0x00))
    _menuBar:addChild(previewBtn)
    previewBtn:setAnchorPoint(ccp(0.5, 0))
    previewBtn:setPosition(ccp(_layerSize.width * 0.5, _layerSize.height * 0.5))
    previewBtn:setScale(g_fElementScaleRatio)
    previewBtn:registerScriptTapHandler(previewCallback)

    -- 下边按钮
    createBottomBtn()

	return _bgLayer
end

