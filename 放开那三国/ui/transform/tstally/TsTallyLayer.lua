-- FileName: TsTallyLayer.lua
-- Author: lgx
-- Date: 2016-08-22
-- Purpose: 兵符转换界面

module("TsTallyLayer", package.seeall)

require "script/ui/transform/tstally/TsTallyController"
require "script/ui/transform/tstally/TsTallyData"
require "script/ui/item/ItemUtil"
require "script/ui/item/ItemSprite"
require "script/ui/tally/TallyUtil"
require "script/ui/hero/HeroPublicLua"

-- UI控件引用变量 --
local _touchPriority 	= nil	-- 触摸优先级
local _zOrder 		 	= nil	-- 显示层级
local _bgLayer 		 	= nil	-- 背景层
local _leftTallySp 		= nil 	-- 左边原兵符
local _rightTallySp 	= nil 	-- 右边目标兵符
local _mainMenu 		= nil 	-- 按钮菜单
local _backItem 		= nil 	-- 返回按钮
local _directItem 		= nil 	-- 定向转换按钮
local _maskLayer 		= nil 	-- 屏蔽层

-- 模块局部变量 --
local _layerSize 		= nil 	-- 背景层大小
local _selectTid 		= nil 	-- 选择的目标兵符Tid
local _leftTallyInfo	= nil 	-- 左边原兵符信息
local _rightTallyInfo 	= nil 	-- 右边目标兵符信息
local _costGold 		= nil 	-- 转换需要的金币

--[[
	@desc 	: 初始化方法
	@param 	: 
	@return : 
--]]
local function init()
	_touchPriority 		= nil
	_zOrder 			= nil
	_bgLayer 			= nil
	_leftTallySp 		= nil
	_rightTallySp 		= nil
	_mainMenu 			= nil
	_backItem 			= nil
	_directItem 		= nil
	_maskLayer 			= nil
	_layerSize 			= nil
	_selectTid 			= nil
	_leftTallyInfo		= nil
	_rightTallyInfo 	= nil
	_costGold 			= nil
end

--[[
	@desc 	: 显示界面方法
	@param 	: pLayerSize 层大小
	@param 	: pTouchPriority 触摸优先级
	@param 	: pZorder 显示层级
	@return : 
--]]
function showLayer( pLayerSize, pTouchPriority, pZorder )
	local layer = createLayer(pLayerSize,pTouchPriority, pZorder)
	local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(layer,_zOrder)
end

--[[
	@desc 	: 创建Layer及UI
	@param 	: pLayerSize 层大小
	@param 	: pTouchPriority 触摸优先级
	@param 	: pZorder 显示层级
	@return : 
--]]
function createLayer( pLayerSize, pTouchPriority, pZorder )
	-- 初始化
	init()

	-- 清除选择的兵符
	TsTallyData.cleanSelectTallyList()

	_layerSize = pLayerSize
	_touchPriority = pTouchPriority or -550
	_zOrder = pZorder or 1000

	-- 背景层
	_bgLayer = CCLayer:create()
	_bgLayer:setPosition(ccp(0, 0))
	_bgLayer:setAnchorPoint(ccp(0, 0))
	_bgLayer:setContentSize(_layerSize)

	-- 背景图
	local bgSprite = CCSprite:create("images/transform/treasure_bg.png")
	bgSprite:setAnchorPoint(ccp(0.5,0.5))
	bgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
	bgSprite:setScale(g_fBgScaleRatio)
	_bgLayer:addChild(bgSprite)

	-- 左边原兵符位
	createLeftTally()

	-- 右边目标兵符位
	createRightTally()

	-- 箭头
	local arrow = CCSprite:create("images/hero/transfer/arrow.png")
	arrow:setAnchorPoint(ccp(0.5, 0.5))
	arrow:setPosition(ccp(_layerSize.width*0.5, _layerSize.height*0.75))
	_bgLayer:addChild(arrow)
	arrow:setScale(0.7 * g_fElementScaleRatio)

	-- 按钮菜单
	_mainMenu = CCMenu:create()
	_bgLayer:addChild(_mainMenu,5)
	_mainMenu:setPosition(ccp(0, 0))
	_mainMenu:setTouchPriority(_touchPriority)

	-- 兵符预览按钮
	local previewItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png", "images/common/btn/btn_blue_h.png", CCSizeMake(160, 73), GetLocalizeStringBy("lgx_1106"), ccc3(0xfe, 0xdb, 0x1c), 30, g_sFontPangWa, 1, ccc3(0x00, 0x00, 0x00))
	_mainMenu:addChild(previewItem)
	previewItem:setAnchorPoint(ccp(0.5, 0))
	previewItem:setPosition(ccp(_layerSize.width*0.5, _layerSize.height*0.55))
	previewItem:setScale(g_fElementScaleRatio)
	previewItem:registerScriptTapHandler(previewItemCallback)

	createBottomItem()

    return _bgLayer
end

--[[
	@desc	: 创建兵符形象
    @param	: pTallyInfo 兵符信息
    @return	: 
—-]]
function createTallyIcon( pTallyInfo )
	if (pTallyInfo == nil) then
		return
	end
	-- 当前兵符的tid
	local tallyTid = tonumber(pTallyInfo.item_template_id)
	-- 当前强化等级
	local enhanceLv = tonumber(pTallyInfo.va_item_text.tallyLevel)
	-- 当前进阶等级
	local devLv = tonumber(pTallyInfo.va_item_text.tallyDevelop)

	-- 兵符大图标
	local normalBigSprite = ItemSprite.getItemBigSpriteById(tallyTid)

	-- 信息背景
	local infoTitleBg = CCScale9Sprite:create("images/common/bg/bg_9s_2.png")
	infoTitleBg:setPreferredSize(CCSizeMake(220,32))
	infoTitleBg:setAnchorPoint(ccp(0.5,1))
	infoTitleBg:setPosition(ccp(normalBigSprite:getContentSize().width/2,-40))
	normalBigSprite:addChild(infoTitleBg)

	-- 兵符名字颜色
	local tallyQuality = TsTallyData.getTallyQualityByTid(tallyTid)
	local nameColor = HeroPublicLua.getCCColorByStarLevel(tallyQuality)
	-- 强化等级
	-- 名称
	-- 进阶等级
	local elements = {
		{
			type = "CCSprite",
	        image = "images/common/lv.png",
		},
		{
			size = 25,
			text = enhanceLv .. "  ",  -- 强化等级
		},
		{
			font = g_sFontPangWa,
			size = 25,
			text = TsTallyData.getTallyNameByTid(tallyTid),
			color = nameColor,
		},
		{
			font = g_sFontPangWa,
			size = 25,
			text = GetLocalizeStringBy("yr_4000",devLv),  -- 获取进阶等级
			color = ccc3(0x00,0xff,0x00),
		},
	}
	local infoText = TallyUtil.createRichSomeLabel(elements)
	infoText:setAnchorPoint(ccp(0.5,0.5))
	infoText:setPosition(ccp(infoTitleBg:getContentSize().width/2,infoTitleBg:getContentSize().height/2))
	infoTitleBg:addChild(infoText)
	infoTitleBg:setScale(1.3)

	return normalBigSprite
end

--[[
	@desc	: 创建左边兵符台子
    @param	: pTallyInfo 兵符信息
    @return	: 
—-]]
function createLeftTally( pTallyInfo )
	if (not tolua.isnull(_leftTallySp)) then
		_leftTallySp:removeFromParentAndCleanup(true)
		_leftTallySp = nil
	end

	-- _leftTallySp = CCSprite:create("images/transform/god_tai.png")
	_leftTallySp = CCSprite:create()
	_leftTallySp:setContentSize(CCSizeMake(246,140))
	_leftTallySp:setAnchorPoint(ccp(0.5,0.5))
	_leftTallySp:setPosition(_layerSize.width*0.25,_layerSize.height*0.6)
	_bgLayer:addChild(_leftTallySp)
	_leftTallySp:setScale(g_fElementScaleRatio)

	-- 特效
	local tallyEffect = XMLSprite:create("images/transform/effect/baowuzhuanhua/baowuzhuanhua")
    tallyEffect:setAnchorPoint(ccp(0.5,0))
    tallyEffect:setPosition(ccp(_leftTallySp:getContentSize().width*0.5,_leftTallySp:getContentSize().height*0.7))
    _leftTallySp:addChild(tallyEffect)

	-- 按钮菜单
	local menu = CCMenu:create()
	_leftTallySp:addChild(menu)
	menu:setPosition(0,0)
	menu:setTouchPriority(_touchPriority)

	-- 透明按钮
	local spriteN = CCSprite:create()
	spriteN:setContentSize(CCSizeMake(80,80))
	local spriteH = CCSprite:create()
	spriteH:setContentSize(CCSizeMake(80,80))
	local addItem = CCMenuItemSprite:create(spriteN,spriteH)
	addItem:setAnchorPoint(ccp(0.5, 0.5))
	addItem:setPosition(ccp(_leftTallySp:getContentSize().width*0.5, _leftTallySp:getContentSize().height+30))
	menu:addChild(addItem)
	addItem:registerScriptTapHandler(addItemCallback)

	if (pTallyInfo == nil) then
		-- 加号
		local addIcon = ItemSprite.createLucencyAddSprite()
		addItem:addChild(addIcon)
		addIcon:setAnchorPoint(ccp(0.5, 0.5))
	    addIcon:setPosition(ccp(addItem:getContentSize().width*0.5, addItem:getContentSize().height*0.5))
	    -- 添加兵符
		local addTip = CCRenderLabel:create(GetLocalizeStringBy("syx_1068"), g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_shadow)
	    addIcon:addChild(addTip)
	    addTip:setAnchorPoint(ccp(0.5, 1))
	    addTip:setPosition(ccp(addIcon:getContentSize().width*0.5, 5))
	    addTip:setColor(ccc3(0x00, 0xff, 0x18))
	else
		-- 创建兵符
		local tallyIcon = createTallyIcon(pTallyInfo)
		_leftTallySp:addChild(tallyIcon)
		tallyIcon:setAnchorPoint(ccp(0.5,0))
		tallyIcon:setPosition(ccp(_leftTallySp:getContentSize().width*0.5, _leftTallySp:getContentSize().height*0.5-20))
		tallyIcon:setScale(0.6)
	end
end

--[[
	@desc	: 刷新左边兵符显示
    @param	: 
    @return	: 
—-]]
function refreshLeftTally()
	local selectInfo = TsTallyData.getSelectTallyList()
	_leftTallyInfo = ItemUtil.getItemByItemId(selectInfo[1].item_id)

	-- 刷新左边兵符信息
    createLeftTally(_leftTallyInfo)

  	-- 刷新底部按钮
  	refreshBottomItem()
end

--[[
	@desc	: 创建右边兵符台子
    @param	: pTallyInfo 兵符信息
    @return	: 
—-]]
function createRightTally( pTallyInfo )
	if(  not tolua.isnull(_rightTallySp) )then 
		_rightTallySp:removeFromParentAndCleanup(true)
		_rightTallySp = nil
	end

	_rightTallySp = CCSprite:create()
	_rightTallySp:setContentSize(CCSizeMake(246,140))
	_rightTallySp:setAnchorPoint(ccp(0.5,0.5))
	_rightTallySp:setPosition(_layerSize.width*0.75,_layerSize.height*0.6)
	_bgLayer:addChild(_rightTallySp)
	_rightTallySp:setScale(g_fElementScaleRatio)

	-- 特效
	local tallyEffect = XMLSprite:create("images/transform/effect/baowuzhuanhua/baowuzhuanhua")
    tallyEffect:setAnchorPoint(ccp(0.5,0))
    tallyEffect:setPosition(ccp(_rightTallySp:getContentSize().width*0.5,_rightTallySp:getContentSize().height*0.7))
    _rightTallySp:addChild(tallyEffect)

	if (pTallyInfo == nil) then
		-- 问号
		local unknowSp = CCSprite:create("images/common/question_mask.png")
        _rightTallySp:addChild(unknowSp)
        unknowSp:setAnchorPoint(ccp(0.5, 0.5))
        unknowSp:setPosition(ccp(_rightTallySp:getContentSize().width*0.5, _rightTallySp:getContentSize().height+30))
	else
		-- 创建兵符
		local tallyIcon = createTallyIcon(pTallyInfo)
		_rightTallySp:addChild(tallyIcon)
		tallyIcon:setAnchorPoint(ccp(0.5,0))
		tallyIcon:setPosition(ccp(_rightTallySp:getContentSize().width*0.5, _rightTallySp:getContentSize().height*0.5-20))
		tallyIcon:setScale(0.6)
	end
end

--[[
	@desc	: 刷新右边兵符显示
    @param	: pSelectTid 选择的兵符Tid 
    @return	: 
—-]]
function refreshRihgtTally( pSelectTid )
	if( pSelectTid )then
		_selectTid = pSelectTid
		_rightTallyInfo = table.hcopy(_leftTallyInfo, {})
		_rightTallyInfo.item_template_id = _selectTid
		_rightTallyInfo.itemDesc = ItemUtil.getItemById(_selectTid)
	end

	-- 刷新右边兵符信息
    createRightTally(_rightTallyInfo)

  	-- 刷新底部按钮
  	refreshBottomItem()
end

--[[
	@desc	: 创建底部按钮
    @param	: 
    @return	: 
—-]]
function createBottomItem()
	-- 返回按钮
	_backItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_purple2_n.png", "images/common/btn/btn_purple2_h.png", CCSizeMake(240, 73), GetLocalizeStringBy("key_10014"), ccc3(0xfe, 0xdb, 0x1c), 32, g_sFontPangWa, 1, ccc3(0x00, 0x00, 0x00))
	_backItem:setAnchorPoint(ccp(0.5, 0))
	_backItem:setPosition(ccp(_bgLayer:getContentSize().width*0.3, 10*g_fElementScaleRatio))
	_backItem:registerScriptTapHandler(backItemCallback)
	_backItem:setScale(g_fElementScaleRatio)
	_backItem:setVisible(false)
	_mainMenu:addChild(_backItem)

	-- 定向转换按钮
	_directItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_purple2_n.png", "images/common/btn/btn_purple2_h.png", CCSizeMake(240, 73), GetLocalizeStringBy("key_10263"), ccc3(0xfe, 0xdb, 0x1c), 32, g_sFontPangWa, 1, ccc3(0x00, 0x00, 0x00))
	_directItem:setAnchorPoint(ccp(0.5, 0))
	_directItem:setPosition(ccp(_bgLayer:getContentSize().width*0.5, 10*g_fElementScaleRatio))
	_directItem:registerScriptTapHandler(directItemCallback)
	_directItem:setScale(g_fElementScaleRatio)
	_mainMenu:addChild(_directItem)
end

--[[
	@desc	: 刷新底部按钮显示
    @param	: 
    @return	: 
—-]]
function refreshBottomItem()
	if (_rightTallyInfo == nil) then
		_directItem:setVisible(true)
		_backItem:setVisible(false)
		if (not tolua.isnull(_replaceItem)) then 
			_replaceItem:removeFromParentAndCleanup(true)
			_replaceItem = nil
		end
	else
		_directItem:setVisible(false)
		_backItem:setVisible(true)

		-- 转换按钮
		if (not tolua.isnull(_replaceItem))then 
			_replaceItem:removeFromParentAndCleanup(true)
			_replaceItem = nil
		end
		local tallyDevelop = 0
	    if (_leftTallyInfo and _leftTallyInfo.va_item_text.tallyDevelop) then
	    	tallyDevelop = tonumber(_leftTallyInfo.va_item_text.tallyDevelop)
	    end
	    _costGold = TsTallyData.getTsTallyCostBy(tallyDevelop)
	    local replacerBtnInfo = {
	        normal      = "images/common/btn/btn_purple2_n.png",                   		-- 正常状态的图片
	        selected    = "images/common/btn/btn_purple2_h.png",                   		-- 按下状态的图片
	        disabled    = nil,                          		-- 不可点击时的图片
	        size        = CCSizeMake(240, 73),          		-- 按钮尺寸
	        icon        = "images/common/gold.png",     		-- 数字前的小图标
	        text        = GetLocalizeStringBy("key_8323"),   	-- 按钮上的文字
	        text_size   = 32,                           		-- 文字的尺寸
	        number      = tostring(_costGold),       			-- 数字 string类型的
	        number_size = 21,                           		-- 数字尺寸
	    }
	    _replaceItem = LuaCCSprite.createNumberMenuItem(replacerBtnInfo)
	    _mainMenu:addChild(_replaceItem)
	    _replaceItem:setAnchorPoint(ccp(0.5, 0))
	    _replaceItem:setPosition(ccp(_bgLayer:getContentSize().width * 0.7, 10*g_fElementScaleRatio))
	    _replaceItem:registerScriptTapHandler(replaceItemCallback)
	    _replaceItem:setScale(g_fElementScaleRatio)
	end
end

--[[
	@desc	: 兵符预览按钮回调
    @param	: 
    @return	: 
—-]]
function previewItemCallback()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	require "script/ui/transform/tstally/TsTallyPreviewLayer"
	TsTallyPreviewLayer.showLayer(_touchPriority-230, 1010)
end

--[[
	@desc	: 左边添加按钮回调
    @param	: 
    @return	: 
—-]]
function addItemCallback()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	require "script/ui/transform/tstally/TsTallyChooseLayer"
	TsTallyChooseLayer.showLayer(refreshLeftTally, _touchPriority-230, 1010 )
end

--[[
	@desc	: 定向选择按钮回调
    @param	: 
    @return	: 
—-]]
function directItemCallback()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	if (_leftTallyInfo == nil) then
		-- 没有选择兵符
		AnimationTip.showTip(GetLocalizeStringBy("lgx_1104"))
		return
	end

	require "script/ui/transform/tstally/TsTallyDirectLayer"
	TsTallyDirectLayer.showLayer(refreshRihgtTally, _leftTallyInfo.item_template_id, _touchPriority-230, 1010 )
end

--[[
	@desc	: 转换按钮回调
    @param	: 
    @return	: 
—-]]
function replaceItemCallback()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	-- 移除屏蔽层回调
    local removeMaskCallback = function ()
		if (not tolua.isnull(_maskLayer)) then
			_maskLayer:removeFromParentAndCleanup(true)
			_maskLayer = nil
		end
	end

	local transferCallback = function ( pRetItemId )
		-- 特效
        local effectSp = XMLSprite:create("images/base/effect/bianshen/bianshen")
	    effectSp:setAnchorPoint(ccp(0.5,0.5))
	    effectSp:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.8))
	    _bgLayer:addChild(effectSp,100)
	    effectSp:setReplayTimes(1)
	    effectSp:setScale(g_fElementScaleRatio)
        effectSp:registerEndCallback(function ()
        	-- 处理数据
        	_leftTallyInfo = table.hcopy(_rightTallyInfo, {})
        	_leftTallyInfo.item_id = pRetItemId
        	_rightTallyInfo = nil
        	_selectTid = nil
        	_costGold = nil

        	-- 清除选择的
			TsTallyData.cleanSelectTallyList()
			-- 添加新的
			TsTallyData.addTallyToSelectList(_leftTallyInfo.item_id)
        	-- 刷新UI
        	createLeftTally(_leftTallyInfo)
        	refreshRihgtTally()

        	removeMaskCallback()
        end)
	end

	-- 确认转换回调
    local cormfirmCallback = function ()
		removeMaskCallback()

		-- 确认转换
        local isSend = TsTallyController.transferTally(transferCallback, _leftTallyInfo.item_id, _leftTallyInfo.item_template_id, _selectTid, _costGold, removeMaskCallback)
       	-- 发送了请求才加屏蔽层
        if (isSend) then
	        -- 加屏蔽层
			_maskLayer = BaseUI.createMaskLayer(-5000,nil,nil,0)
			local runningScene = CCDirector:sharedDirector():getRunningScene()
			runningScene:addChild(_maskLayer, 10000)
    	end
    end

    local tipNode = CCNode:create()
    tipNode:setContentSize(CCSizeMake(400,100))
    local textInfo = {
            width = 400, 								-- 宽度
            alignment = 1, 								-- 对齐方式  1 左对齐，2 居中， 3右对齐
            labelDefaultFont = g_sFontName,				-- 默认字体
            labelDefaultSize = 25,          			-- 默认字体大小
            labelDefaultColor = ccc3(0x78,0x25,0x00),	-- 字体颜色
            linespace = 10, 							-- 行间距
            defaultType = "CCLabelTTF",					-- 默认类型
            elements =
            {   
                {
                    type = "CCLabelTTF",
                    text = _costGold,
                    color = ccc3(0x78,0x25,0x00),
                },
                {
                    type = "CCSprite",
                    image = "images/common/gold.png",
                },
            }
        }
    local tipDes = GetLocalizeLabelSpriteBy_2("lgx_1108", textInfo)
    tipDes:setAnchorPoint(ccp(0.5, 0.5))
    tipDes:setPosition(ccp(tipNode:getContentSize().width*0.5,tipNode:getContentSize().height*0.5))
    tipNode:addChild(tipDes)
    require "script/ui/tip/TipByNode"
    TipByNode.showLayer(tipNode,cormfirmCallback,CCSizeMake(500,360))
end

--[[
	@desc	: 返回按钮回调,返回替换操作
    @param	: 
    @return	: 
—-]]
function backItemCallback()
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	_selectTid = nil
	_rightTallyInfo = nil
	refreshRihgtTally()
end

