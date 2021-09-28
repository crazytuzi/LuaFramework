-- FileName: TsTreasureLayer.lua 
-- Author: licong 
-- Date: 16/3/4 
-- Purpose: 宝物转换主界面 


module("TsTreasureLayer", package.seeall)

require "script/libs/LuaCCSprite"
require "script/ui/transform/TsTreasureData"
require "script/ui/transform/TsTreasureController"

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
	@des 	: 宝物预览
	@param 	: 
	@return : 
--]]
function previewCallback( tag, menuItem )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/changtiaoxing.mp3")

	require "script/ui/transform/TsTreasurePreviewLayer"
	TsTreasurePreviewLayer.showLayer( nil, _touchPriority-230, 1010 )
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
	    effectSp:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.8))
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
			TsTreasureData.cleanSelectList()
			--  添加新的
			TsTreasureData.addToSelectList(_leftItemInfo.item_id)
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

        local isSend = TsTreasureController.transferTreasure( _leftItemInfo.item_id, _leftItemInfo.item_template_id, _chooseTid, _costNum, nextCallFun)
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
    local tipDes = GetLocalizeLabelSpriteBy_2("lic_1810", textInfo)
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
		-- 没有选择宝物
		AnimationTip.showTip( GetLocalizeStringBy("lic_1805"))
		return
	end

	require "script/ui/transform/TreasOrientationLayer"
	TreasOrientationLayer.showLayer( _leftItemInfo.item_template_id, refreshRihgtUI, _touchPriority-230, 1010 )
end

--[[
	@des 	: 加号按钮
	@param 	: 
	@return : 
--]]
function addMenuItemAction( tag, menuItem )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/changtiaoxing.mp3")

	require "script/ui/transform/TsTreasureChooseLayer"
	TsTreasureChooseLayer.showLayer( refreshLeftUI, _touchPriority-230, 1010 )
end

--[[
	@des 	: 刷新左边台子
	@param 	: 
	@return : 
--]]
function refreshLeftUI()
	local chooseItemidTab = TsTreasureData.getSelectList()
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
	    _costNum = TsTreasureData.getTransformCost()
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
	@des 	: 创建宝物形象
	@param 	: 
	@return : 
--]]
function createTreasureSp( p_itemInfo, p_parent )
	--宝物全身像
	local bodySprite = ItemSprite.getItemBigSpriteById(p_itemInfo.item_template_id)
	p_parent:addChild(bodySprite)
	bodySprite:setAnchorPoint(ccp(0.5,0))
	bodySprite:setPosition(ccp(p_parent:getContentSize().width*0.5, p_parent:getContentSize().height*0.5+10))
	bodySprite:setScale(0.5)
	
	-- 等级名字
	local nameBgSprite = CCScale9Sprite:create("images/common/bg/bg_9s_2.png")
	nameBgSprite:setContentSize(CCSizeMake(215,32))
	nameBgSprite:setAnchorPoint(ccp(0.5,0))
	nameBgSprite:setPosition(ccp(p_parent:getContentSize().width*0.5,0))
	p_parent:addChild(nameBgSprite,10)

	local quality = ItemUtil.getTreasureQualityByItemInfo( p_itemInfo )
	local nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
	local nameStr = ItemUtil.getTreasureNameStrByItemInfo(p_itemInfo)
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
        		text = p_itemInfo.va_item_text.treasureLevel,
        		color = ccc3(0xff,0xf6,0x00),
        	},
            {
                text = nameStr, 
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
	@des 	:得到洗练等级图标
	@param 	:p_maxLv 最大洗练等级, p_curWasterLv 当前洗练等级
	@return :sprite
--]]
function getEvolveLvSp(p_maxLv, p_curWasterLv )
	local diamondBg = CCSprite:create()
	diamondBg:setContentSize(CCSizeMake(275, 30))
	require "script/ui/treasure/TreasureUtil"
	for i=1, 10 do
		local sprite = nil
		if(i <= (p_curWasterLv)%10) then
			sprite 	= TreasureUtil.getFixedLevelSprite(p_curWasterLv)
		else
			sprite 	= CCSprite:create("images/common/big_gray_gem.png")
		end

		if math.floor(tonumber(p_curWasterLv)/10) >= 1 and tonumber(p_curWasterLv)%10==0  then
			sprite 	= TreasureUtil.getFixedLevelSprite(p_curWasterLv)
		end
		
		sprite:setAnchorPoint(ccp(0.5, 0.5))
		local dis  	= 27
		local x    	= dis/2 + dis * (i-1)
		local y 	= diamondBg:getContentSize().height/2
		sprite:setPosition(ccp(x , y))
		diamondBg:addChild(sprite)
		sprite:setScale(0.8)
	end
	return diamondBg
end

--[[
	@des 	: 得到符印图标
	@param 	: $p_index 		:第几个符印位置,p_tresData宝物数据
	@return : sprite
--]]
function getRuneSprite(p_index,p_tresData)
	local iconBg = CCSprite:create("images/common/rune_bg_b.png")
	
	if(p_tresData.va_item_text and p_tresData.va_item_text.treasureInlay and p_tresData.va_item_text.treasureInlay[tostring(p_index)] )then
		-- 有符印
		local runeItemInfo = p_tresData.va_item_text.treasureInlay[tostring(p_index)]
		local runeIcon = ItemSprite.getItemSpriteByItemId(runeItemInfo.item_template_id)
		runeIcon:setAnchorPoint(ccp(0.5,0.5))
		runeIcon:setPosition(ccp(iconBg:getContentSize().width*0.5,iconBg:getContentSize().height*0.5))
		iconBg:addChild(runeIcon)
	else
		-- 没有符印
		local isOpen,needNum = TreasureData.getRunePosIsOpen(p_tresData.item_template_id,p_tresData.item_id,p_tresData,p_index)
		if(isOpen)then
			-- 开启 加号
			local addSprite = CCSprite:create("images/common/add_new.png")
			addSprite:setAnchorPoint(ccp(0.5,0.5))
			addSprite:setPosition(ccp(iconBg:getContentSize().width*0.5,iconBg:getContentSize().height*0.5))
			iconBg:addChild(addSprite)
		else
			-- 没开启 锁
			local lockSp = CCSprite:create("images/common/rune_lock_b.png")
			lockSp:setAnchorPoint(ccp(0.5,0.5))
			lockSp:setPosition(ccp(iconBg:getContentSize().width*0.5,iconBg:getContentSize().height*0.5))
			iconBg:addChild(lockSp)
		end
	end
	return iconBg
end

--[[
	@des 	: 创建洗练属性
	@param 	: 
	@return : 
--]]
function createTreasureFixSp( p_itemInfo )
	local retSprite =  CCScale9Sprite:create("images/common/bg/astro_btnbg.png")
	retSprite:setContentSize(CCSizeMake(278, 230))

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

	-- 精炼属性
	local titleFontSp = CCSprite:create("images/transform/jinglian.png")
	titleFontSp:setAnchorPoint(ccp(0.5,0))
	contentLayer:addChild(titleFontSp)
	local lineSp = CCSprite:create("images/god_weapon/cut_line.png")
	titleFontSp:addChild(lineSp)
	lineSp:setAnchorPoint(ccp(1,0.5))
	lineSp:setPosition(titleFontSp:getContentSize().width+10,titleFontSp:getContentSize().height*0.5)
	lineSp:setScaleX(-0.35)
	local lineSp2 = CCSprite:create("images/god_weapon/cut_line.png")
	titleFontSp:addChild(lineSp2)
	lineSp2:setAnchorPoint(ccp(1,0.5))
	lineSp2:setPosition(-10,titleFontSp:getContentSize().height*0.5)
	lineSp2:setScaleX(0.35)
	contentHeight = contentHeight+titleFontSp:getContentSize().height
	-- 精炼等级
	local washLvSp = getEvolveLvSp(tonumber(p_itemInfo.itemDesc.max_upgrade_level ), tonumber(p_itemInfo.va_item_text.treasureEvolve))
	contentLayer:addChild(washLvSp)
	contentHeight = contentHeight + washLvSp:getContentSize().height
	-- 精炼属性
	local washTab = TreasAffixModel.getUpgradeAffixByInfo(p_itemInfo)
	contentHeight = contentHeight + table.count(washTab)*30 + 10
	--符印
	local fuyinFontSp = CCSprite:create("images/transform/fuyin.png")
	fuyinFontSp:setAnchorPoint(ccp(0.5,0))
	contentLayer:addChild(fuyinFontSp)
	local lineSp3 = CCSprite:create("images/god_weapon/cut_line.png")
	fuyinFontSp:addChild(lineSp3)
	lineSp3:setAnchorPoint(ccp(1,0.5))
	lineSp3:setPosition(fuyinFontSp:getContentSize().width+10,fuyinFontSp:getContentSize().height*0.5)
	lineSp3:setScaleX(-0.45)
	local lineSp4 = CCSprite:create("images/god_weapon/cut_line.png")
	fuyinFontSp:addChild(lineSp4)
	lineSp4:setAnchorPoint(ccp(1,0.5))
	lineSp4:setPosition(-10,fuyinFontSp:getContentSize().height*0.5)
	lineSp4:setScaleX(0.45)
	contentHeight = contentHeight+fuyinFontSp:getContentSize().height
	contentHeight = contentHeight+80

	-- 设置scrollview
	contentLayer:setContentSize(CCSizeMake(retSprite:getContentSize().width,contentHeight))
	scrollView:setContainer(contentLayer)
	scrollView:setContentOffset(ccp(0,scrollView:getViewSize().height-contentLayer:getContentSize().height))

	-- 位置
	local posY = contentLayer:getContentSize().height-30
	titleFontSp:setPosition(contentLayer:getContentSize().width*0.5,posY)
	posY = posY-40
	washLvSp:setAnchorPoint(ccp(0.5,0))
	washLvSp:setPosition(ccp(contentLayer:getContentSize().width*0.5,posY))
	for attr_id,attr_value in pairs(washTab) do
		local affixInfo,showNum,realNum = ItemUtil.getAtrrNameAndNum(attr_id,attr_value)
		local attrNameLabel = CCRenderLabel:create(affixInfo.sigleName .. "：", g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		attrNameLabel:setColor(ccc3(0xff, 0xff, 0xff))
		attrNameLabel:setAnchorPoint(ccp(1, 0))
		posY = posY-30
		attrNameLabel:setPosition(ccp(contentLayer:getContentSize().width*0.5,posY))
		contentLayer:addChild(attrNameLabel)

		local attrNumLabel = CCRenderLabel:create("+" .. showNum,g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		attrNumLabel:setColor(ccc3(0xff, 0xff, 0xff))
		attrNumLabel:setAnchorPoint(ccp(0, 0))
		attrNumLabel:setPosition(ccp(attrNameLabel:getPositionX()+10,attrNameLabel:getPositionY()))
		contentLayer:addChild(attrNumLabel)
	end
	-- 符印
	posY = posY-30
	fuyinFontSp:setPosition(contentLayer:getContentSize().width*0.5,posY)
	-- 镶嵌的符印
	posY = posY-40
	local posX = {0.15,0.38,0.62,0.85}
	for i=1,4 do
		local runeBg = getRuneSprite(i,p_itemInfo)
		runeBg:setAnchorPoint(ccp(0.5,0.5))
		runeBg:setPosition(ccp(contentLayer:getContentSize().width*posX[i], posY))
		contentLayer:addChild(runeBg)
		runeBg:setScale(0.5)
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
	
	_leftStageSp = CCSprite:create()
	_leftStageSp:setContentSize(CCSizeMake(246,140))
	_leftStageSp:setAnchorPoint(ccp(0.5,0.5))
	_leftStageSp:setPosition(_layerSize.width*0.25,_layerSize.height*0.6)
	_bgLayer:addChild(_leftStageSp)
	_leftStageSp:setScale(g_fElementScaleRatio)

	-- 特效
	local effect1 = XMLSprite:create("images/transform/effect/baowuzhuanhua/baowuzhuanhua")
    effect1:setAnchorPoint(ccp(0.5,0.5))
    effect1:setPosition(ccp(_leftStageSp:getContentSize().width*0.5,_leftStageSp:getContentSize().height*0.7))
    _leftStageSp:addChild(effect1)

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
		local addTip = CCRenderLabel:create(GetLocalizeStringBy("lic_1804"), g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
	    addIcon:addChild(addTip)
	    addTip:setAnchorPoint(ccp(0.5, 1))
	    addTip:setPosition(ccp(addIcon:getContentSize().width*0.5, 5))
	    addTip:setColor(ccc3(0x00, 0xff, 0x18))
	else
		-- 创建宝物
		createTreasureSp( p_itemInfo, _leftStageSp )
		-- 创建宝物洗练属性
		_leftFixAttrSp = createTreasureFixSp(p_itemInfo)
		_bgLayer:addChild(_leftFixAttrSp)
		_leftFixAttrSp:setAnchorPoint(ccp(0,0.5))
		_leftFixAttrSp:setPosition(10*g_fElementScaleRatio,_layerSize.height*0.3)
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

	_rightStageSp = CCSprite:create()
	_rightStageSp:setContentSize(CCSizeMake(246,140))
	_rightStageSp:setAnchorPoint(ccp(0.5,0.5))
	_rightStageSp:setPosition(_layerSize.width*0.75,_layerSize.height*0.6)
	_bgLayer:addChild(_rightStageSp)
	_rightStageSp:setScale(g_fElementScaleRatio)

	-- 特效
	local effect1 = XMLSprite:create("images/transform/effect/baowuzhuanhua/baowuzhuanhua")
    effect1:setAnchorPoint(ccp(0.5,0))
    effect1:setPosition(ccp(_rightStageSp:getContentSize().width*0.5,_rightStageSp:getContentSize().height*0.7))
    _rightStageSp:addChild(effect1)

	if( p_itemInfo == nil)then

		local unknowSp = CCSprite:create("images/common/question_mask.png")
        _rightStageSp:addChild(unknowSp)
        unknowSp:setAnchorPoint(ccp(0.5, 0.5))
        unknowSp:setPosition(ccp(_rightStageSp:getContentSize().width*0.5, _rightStageSp:getContentSize().height+30))
	else
		-- 创建宝物
		createTreasureSp( p_itemInfo, _rightStageSp )
		-- 创建宝物洗练属性
		_rightFixAttrSp = createTreasureFixSp(p_itemInfo)
		_bgLayer:addChild(_rightFixAttrSp)
		_rightFixAttrSp:setAnchorPoint(ccp(1,0.5))
		_rightFixAttrSp:setPosition(_layerSize.width-10*g_fElementScaleRatio,_layerSize.height*0.3)
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

	-- 清除选择的
	TsTreasureData.cleanSelectList()

	-- 界面
	_layerSize = p_layerSize
	_bgLayer = CCLayer:create()
	_bgLayer:registerScriptHandler(onNodeEvent) 
	_bgLayer:setContentSize(_layerSize)

	-- 大背景
    _bgSprite = CCSprite:create("images/transform/treasure_bg.png")
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
    arrow:setPosition(ccp(_layerSize.width*0.5, _layerSize.height *0.75))
    _bgLayer:addChild(arrow)
    arrow:setScale(0.7 * g_fElementScaleRatio)
    
    -- 按钮
    _menuBar = CCMenu:create()
    _bgLayer:addChild(_menuBar,5)
    _menuBar:setPosition(ccp(0, 0))
    _menuBar:setTouchPriority(_touchPriority)

    -- 宝物预览
    local previewBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png", "images/common/btn/btn_blue_h.png", CCSizeMake(160, 73), GetLocalizeStringBy("lic_1807"), ccc3(0xfe, 0xdb, 0x1c), 30, g_sFontPangWa, 1, ccc3(0x00, 0x00, 0x00))
    _menuBar:addChild(previewBtn)
    previewBtn:setAnchorPoint(ccp(0.5, 0))
    previewBtn:setPosition(ccp(_layerSize.width * 0.5, _layerSize.height * 0.55))
    previewBtn:setScale(g_fElementScaleRatio)
    previewBtn:registerScriptTapHandler(previewCallback)

    -- 下边按钮
    createBottomBtn()

	return _bgLayer
end

