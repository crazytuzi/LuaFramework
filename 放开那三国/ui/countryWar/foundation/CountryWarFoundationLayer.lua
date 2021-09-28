-- FileName : CountryWarFoundationLayer.lua
-- Author   : YangRui
-- Date     : 2015-11-23
-- Purpose  : 

module("CountryWarFoundationLayer", package.seeall)

require "script/ui/countryWar/foundation/CountryWarFoundationData"
require "script/ui/countryWar/foundation/CountryWarFoundationController"
require "script/ui/countryWar/foundation/CountryWarFoundationService"

local _bgLayer                         = nil
local _bgSp                            = nil
local _goldNumLabel                    = nil  -- 金币数值Label
local _countryWarCoinNumLabel          = nil  -- 国战币数值Label
local _rechargeCountryWarCoinNum       = 0    -- 兑换国战币数量
local _rechargeCountryWarCoinLabel     = nil  -- 兑换国战币数量Label
local _rechargeCountryWarCoinCostNum   = 0    -- 兑换国战币消耗数值
local _rechargeCountryWarCoinCostLabel = 0    -- 兑换国战币消耗数值Label

local kAddTenTag                       = 10001
local kAddHundredTag                   = 10002
local kAddThousandTag                  = 10003

local _touchPriority                   = nil
local _zOrder                          = nil

--[[
	@des 	: 初始化
	@param 	: 
	@return : 
--]]
function init( ... )
	_bgLayer                         = nil
	_bgSp                            = nil
	_goldNumLabel                    = nil  -- 金币数值Label
	_countryWarCoinNumLabel          = nil  -- 国战币数值Label
	_rechargeCountryWarCoinNum       = 0    -- 兑换国战币数量
	_rechargeCountryWarCoinLabel     = nil  -- 兑换国战币数量Label
	_rechargeCountryWarCoinCostNum   = 0    -- 兑换国战币消耗数值
	_rechargeCountryWarCoinCostLabel = 0    -- 兑换国战币消耗数值Label

	_touchPriority                   = nil 
	_zOrder                          = nil
end

--[[
    @des    : 处理touches事件
    @para   : 
    @return : 
 --]]
function onTouchesHandler( eventType, x, y )
    return true
end

--[[
	@des 	: 回调onEnter和onExit事件
	@param 	: 
	@return : 
--]]
function onNodeEvent( pEvent )
    if pEvent == "enter" then
    	_bgLayer:registerScriptTouchHandler(onTouchesHandler,false,_touchPriority,true)
		_bgLayer:setTouchEnabled(true)
    elseif pEvent == "exit" then
    	_bgLayer:unregisterScriptTouchHandler()
    end
end

--[[
	@des 	: 清空按钮回调
	@param 	: 
	@return : 
--]]
function resetBtnCallback( ... )
	-- 音效
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	if _rechargeCountryWarCoinNum ~= 0 then
		_rechargeCountryWarCoinNum = 0
		_rechargeCountryWarCoinCostNum = _rechargeCountryWarCoinNum*CountryWarFoundationData.getGoldToCoutryWarCoinCost()
		_rechargeCountryWarCoinLabel:setString(_rechargeCountryWarCoinNum)
		_rechargeCountryWarCoinCostLabel:setString(_rechargeCountryWarCoinCostNum)
	end
end

--[[
	@des 	: 改变兑换国战币数量的回调
	@param 	: 
	@return : 
--]]
function changeNumAction( tag, itemBtn )
	-- 音效
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	if ( tag == kAddTenTag ) then
		-- +10
		_rechargeCountryWarCoinNum = _rechargeCountryWarCoinNum+10
	elseif ( tag == kAddHundredTag ) then
		-- +100
		_rechargeCountryWarCoinNum = _rechargeCountryWarCoinNum+100
	elseif ( tag == kAddThousandTag ) then
		-- +1000
		_rechargeCountryWarCoinNum = _rechargeCountryWarCoinNum+1000
	end
	-- 下限
    local lower = 0
	if ( _rechargeCountryWarCoinNum < lower ) then
		_rechargeCountryWarCoinNum = lower
	end
	-- 上限
    local upper = CountryWarFoundationData.curGoldCanBuyNum()
    local goldCanBuyNum = CountryWarFoundationData.calcGoldCanChargeNum()
	if _rechargeCountryWarCoinNum > goldCanBuyNum then
		local haveNum = CountryWarMainData.getCocoin()
		local willHaveNum = goldCanBuyNum+haveNum
		local canBuyUpNum = CountryWarFoundationData.getCarryUpper()
		if willHaveNum < canBuyUpNum then
			AnimationTip.showTip(GetLocalizeStringBy("key_1255"))
		end
	end
	if ( _rechargeCountryWarCoinNum >= upper ) then
		_rechargeCountryWarCoinNum = upper
	end
	_rechargeCountryWarCoinCostNum = _rechargeCountryWarCoinNum*CountryWarFoundationData.getGoldToCoutryWarCoinCost()
	_rechargeCountryWarCoinLabel:setString(tostring(_rechargeCountryWarCoinNum))
	_rechargeCountryWarCoinCostLabel:setString(_rechargeCountryWarCoinCostNum)
end

--[[
	@des 	: 确定按钮回调
	@param 	: 
	@return : 
--]]
function confirmBtnCallback( ... )
	-- 音效
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- 网络请求
	CountryWarFoundationController.exchangeCocoin(_rechargeCountryWarCoinNum,function( ... )
		closeFunc()
		AnimationTip.showTip(GetLocalizeStringBy("yr_5021",_rechargeCountryWarCoinNum))
	end)
end

--[[
	@des 	: 创建兑换详细
	@param 	: 
	@return : 
--]]
function createRechargeDetail( ... )
	-- 兑换详细背景
	local innerBgSp = CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
	innerBgSp:setContentSize(CCSizeMake(550,380))
	innerBgSp:setAnchorPoint(ccp(0.5,0))
	innerBgSp:setPosition(ccp(_bgSp:getContentSize().width/2,120))
	_bgSp:addChild(innerBgSp)
	-- 纹理
	local grain_left = CCSprite:create("images/country_war/brown_grain.png")
	grain_left:setAnchorPoint(ccp(0,0.5))
	grain_left:setPosition(ccp(5,innerBgSp:getContentSize().height-grain_left:getContentSize().height-10))
	innerBgSp:addChild(grain_left)
	local grain_right = CCSprite:create("images/country_war/brown_grain.png")
	grain_right:setAnchorPoint(ccp(0,0.5))
	grain_right:setPosition(ccp(innerBgSp:getContentSize().width-5,innerBgSp:getContentSize().height-grain_right:getContentSize().height-10))
	grain_right:setRotation(180)
	grain_right:setFlipY(true)
	innerBgSp:addChild(grain_right)
	-- 选择兑换国战币数量 yr_5015
	local detailTip = CCRenderLabel:create(GetLocalizeStringBy("yr_5015"),g_sFontPangWa,25,1,ccc3(0x00,0x00,0x00),type_shadow)
	detailTip:setAnchorPoint(ccp(0.5,0.5))
	detailTip:setPosition(ccp(innerBgSp:getContentSize().width/2,grain_right:getPositionY()))
	detailTip:setColor(ccc3(0xff,0xf6,0x00))
	innerBgSp:addChild(detailTip)
	-- 兑换国战币数量背景
	local numberBg = CCScale9Sprite:create("images/common/checkbg.png")
	numberBg:setContentSize(CCSizeMake(170,65))
	numberBg:setAnchorPoint(ccp(0.5,0.5))
	numberBg:setPosition(ccp(innerBgSp:getContentSize().width/2,detailTip:getPositionY()-detailTip:getContentSize().height-40))
	innerBgSp:addChild(numberBg)
	-- 兑换国战币数量Label
	_rechargeCountryWarCoinLabel = CCRenderLabel:create(_rechargeCountryWarCoinNum,g_sFontPangWa,30,1,ccc3(0x00,0x00,0x00),type_shadow)
	_rechargeCountryWarCoinLabel:setAnchorPoint(ccp(0.5,0.5))
	_rechargeCountryWarCoinLabel:setPosition(ccp(numberBg:getContentSize().width/2,numberBg:getContentSize().height/2))
	_rechargeCountryWarCoinLabel:setColor(ccc3(0xff,0xf6,0x00))
	numberBg:addChild(_rechargeCountryWarCoinLabel)
	-- 国战币icon
	local countryWarCoin = CCSprite:create("images/common/countrycoin.png")
	countryWarCoin:setAnchorPoint(ccp(1,0.5))
	countryWarCoin:setPosition(ccp(-20,numberBg:getContentSize().height/2))
	numberBg:addChild(countryWarCoin)
	-- 按钮Bar
	local btnMenuBar = CCMenu:create()
    btnMenuBar:setPosition(ccp(0,0))
    btnMenuBar:setTouchPriority(_touchPriority-30)
    innerBgSp:addChild(btnMenuBar)
    -- 清空按钮 yr_5016
    local tSprite = {normal="images/common/btn/anniu_blue_btn_n.png",selected="images/common/btn/anniu_blue_btn_h.png"}
    local tLabel = {text=GetLocalizeStringBy("yr_5016"),fontsize=30,color=ccc3(0xff,0xf6,0x00)}
	local resetBtn = LuaCCMenuItem.createMenuItemOfRenderLabelOnSprite(tSprite,tLabel)
	resetBtn:setAnchorPoint(ccp(0,0.5))
	resetBtn:setPosition(ccp(numberBg:getPositionX()+numberBg:getContentSize().width/2+20,numberBg:getPositionY()))
	resetBtn:registerScriptTapHandler(resetBtnCallback)
	btnMenuBar:addChild(resetBtn)
	-- +10
	local tSprite = {normal="images/common/btn/anniu_red_btn_n.png",selected="images/common/btn/anniu_red_btn_h.png"}
    local tLabel = {text="+10",fontsize=30,color=ccc3(0xff,0xf6,0x00)}
	local add10Btn = LuaCCMenuItem.createMenuItemOfRenderLabelOnSprite(tSprite,tLabel)
	add10Btn:setAnchorPoint(ccp(0.5,0.5))
	add10Btn:setPosition(ccp(innerBgSp:getContentSize().width/2-add10Btn:getContentSize().width-40,numberBg:getPositionY()-numberBg:getContentSize().height-add10Btn:getContentSize().height/2))
	add10Btn:registerScriptTapHandler(changeNumAction)
	btnMenuBar:addChild(add10Btn,1,kAddTenTag)
	-- +100
	local tSprite = {normal="images/common/btn/anniu_red_btn_n.png",selected="images/common/btn/anniu_red_btn_h.png"}
    local tLabel = {text="+100",fontsize=30,color=ccc3(0xff,0xf6,0x00)}
	local add100Btn = LuaCCMenuItem.createMenuItemOfRenderLabelOnSprite(tSprite,tLabel)
	add100Btn:setAnchorPoint(ccp(0.5,0.5))
	add100Btn:setPosition(ccp(innerBgSp:getContentSize().width/2,numberBg:getPositionY()-numberBg:getContentSize().height-add100Btn:getContentSize().height/2))
	add100Btn:registerScriptTapHandler(changeNumAction)
	btnMenuBar:addChild(add100Btn,1,kAddHundredTag)
	-- +1000
	local tSprite = {normal="images/common/btn/anniu_red_btn_n.png",selected="images/common/btn/anniu_red_btn_h.png"}
    local tLabel = {text="+1000",fontsize=30,color=ccc3(0xff,0xf6,0x00)}
	local add1000Btn = LuaCCMenuItem.createMenuItemOfRenderLabelOnSprite(tSprite,tLabel)
	add1000Btn:setAnchorPoint(ccp(0.5,0.5))
	add1000Btn:setPosition(ccp(innerBgSp:getContentSize().width/2+add1000Btn:getContentSize().width+40,numberBg:getPositionY()-numberBg:getContentSize().height-add1000Btn:getContentSize().height/2))
	add1000Btn:registerScriptTapHandler(changeNumAction)
	btnMenuBar:addChild(add1000Btn,1,kAddThousandTag)
	-- 需花费Num Label
	_rechargeCountryWarCoinCostLabel = CCRenderLabel:createWithAlign(_rechargeCountryWarCoinCostNum,g_sFontPangWa,25,1,ccc3(0x00,0x00,0x00),type_stroke,CCSizeMake(125,32),kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
	_rechargeCountryWarCoinCostLabel:setAnchorPoint(ccp(0.5,0.5))
	_rechargeCountryWarCoinCostLabel:setPosition(ccp(innerBgSp:getContentSize().width/2,105))
	_rechargeCountryWarCoinCostLabel:setColor(ccc3(0xff,0xf6,0x00))
	innerBgSp:addChild(_rechargeCountryWarCoinCostLabel)
	-- 需花费： yr_5017
	local needSpeedLabel = CCRenderLabel:create(GetLocalizeStringBy("yr_5017"),g_sFontPangWa,25,1,ccc3(0x00,0x00,0x00),type_stroke)
	needSpeedLabel:setAnchorPoint(ccp(1,0.5))
	needSpeedLabel:setPosition(ccp(_rechargeCountryWarCoinCostLabel:getPositionX()-_rechargeCountryWarCoinCostLabel:getContentSize().width/2-20,_rechargeCountryWarCoinCostLabel:getPositionY()))
	innerBgSp:addChild(needSpeedLabel)
	-- gold icon
	local goldIcon = CCSprite:create("images/common/gold.png")
	goldIcon:setAnchorPoint(ccp(0,0.5))
	goldIcon:setPosition(ccp(_rechargeCountryWarCoinCostLabel:getPositionX()+_rechargeCountryWarCoinCostLabel:getContentSize().width/2+35,_rechargeCountryWarCoinCostLabel:getPositionY()))
	innerBgSp:addChild(goldIcon)
	--确定按钮
    local confirmMenuItem =  LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(180,73),GetLocalizeStringBy("key_1465"),ccc3(0xfe,0xdb,0x1c),30,g_sFontPangWa,1,ccc3(0x00,0x00,0x00))
    confirmMenuItem:setAnchorPoint(ccp(1,0))
    confirmMenuItem:setPosition(ccp(innerBgSp:getContentSize().width*0.45,10))
    confirmMenuItem:registerScriptTapHandler(confirmBtnCallback)
    btnMenuBar:addChild(confirmMenuItem)
    --取消按钮
    local closeMenuItem =  LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(180,73),GetLocalizeStringBy("key_2326"),ccc3(0xfe,0xdb,0x1c),30,g_sFontPangWa,1,ccc3(0x00,0x00,0x00))
    closeMenuItem:setAnchorPoint(ccp(0,0))
    closeMenuItem:setPosition(ccp(innerBgSp:getContentSize().width*0.55,10))
    closeMenuItem:registerScriptTapHandler(closeBtnCallback)
    btnMenuBar:addChild(closeMenuItem)
end

--[[
	@des 	: 关闭方法
	@param 	: 
	@return : 
--]]
function closeFunc( ... )
	if _bgLayer ~= nil then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
end

--[[
	@des 	: 关闭按钮回调
	@param 	: 
	@return : 
--]]
function closeBtnCallback( ... )
	-- audio effect
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	closeFunc()
end

--[[
	@des 	: 创建UI
	@param 	: 
	@return : 
--]]
function createUI( ... )
    -- bg
    _bgSp = CCScale9Sprite:create("images/common/viewbg1.png")
    _bgSp:setContentSize(CCSizeMake(610,650))
    _bgSp:setAnchorPoint(ccp(0.5,0.5))
    _bgSp:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
    _bgSp:setScale(g_fScaleX)
    _bgLayer:addChild(_bgSp)
    -- 关闭按钮Bar
    local btnMenuBar = CCMenu:create()
    btnMenuBar:setPosition(ccp(0,0))
    btnMenuBar:setTouchPriority(_touchPriority-20)
    _bgSp:addChild(btnMenuBar)
    -- 关闭按钮
    local closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png","images/common/btn_close_h.png")
    closeBtn:setPosition(ccp(_bgSp:getContentSize().width*0.97,_bgSp:getContentSize().height*0.98))
    closeBtn:setAnchorPoint(ccp(0.5,0.5))
    closeBtn:registerScriptTapHandler(closeBtnCallback)
    btnMenuBar:addChild(closeBtn)
    -- 金币 key_1298
    local goldLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1298"),g_sFontPangWa,25,1,ccc3(0x00,0x00,0x00),type_shadow)
    goldLabel:setAnchorPoint(ccp(0,0.5))
    goldLabel:setPosition(ccp(80,_bgSp:getContentSize().height-60))
    goldLabel:setColor(ccc3(0xff,0xf6,0x00))
    _bgSp:addChild(goldLabel)
    -- 金币icon
    local goldIcon = CCSprite:create("images/common/gold.png")
    goldIcon:setAnchorPoint(ccp(0,0.5))
    goldIcon:setPosition(ccp(goldLabel:getPositionX()+goldLabel:getContentSize().width+35,goldLabel:getPositionY()))
    _bgSp:addChild(goldIcon)
    -- 金币数值Label
    local goldNum = UserModel.getGoldNumber()
    _goldNumLabel = CCRenderLabel:create(goldNum,g_sFontPangWa,25,1,ccc3(0x00,0x00,0x00),type_shadow)
    _goldNumLabel:setAnchorPoint(ccp(0,0.5))
    _goldNumLabel:setPosition(ccp(goldIcon:getPositionX()+goldIcon:getContentSize().width+10,goldIcon:getPositionY()))
    _goldNumLabel:setColor(ccc3(0xff,0xf6,0x00))
    _bgSp:addChild(_goldNumLabel)
    -- 国战币 yr_5011
	local countryWarCoinLabel = CCRenderLabel:create(GetLocalizeStringBy("yr_5011"),g_sFontPangWa,25,1,ccc3(0x00,0x00,0x00),type_shadow)
    countryWarCoinLabel:setAnchorPoint(ccp(0,0.5))
    countryWarCoinLabel:setPosition(ccp(80,goldLabel:getPositionY()-goldLabel:getContentSize().height-20))
    countryWarCoinLabel:setColor(ccc3(0xff,0xf6,0x00))
    _bgSp:addChild(countryWarCoinLabel)
    -- 国战币icon
    local countryWarCoin = CCSprite:create("images/common/countrycoin.png")
    countryWarCoin:setAnchorPoint(ccp(0,0.5))
    countryWarCoin:setPosition(ccp(countryWarCoinLabel:getPositionX()+countryWarCoinLabel:getContentSize().width+10,countryWarCoinLabel:getPositionY()))
    _bgSp:addChild(countryWarCoin)
    -- 国战币数值Label
    local coCoin = CountryWarMainData.getCocoin()
    _countryWarCoinNumLabel = CCRenderLabel:create(coCoin,g_sFontPangWa,25,1,ccc3(0x00,0x00,0x00),type_shadow)
    _countryWarCoinNumLabel:setAnchorPoint(ccp(0,0.5))
    _countryWarCoinNumLabel:setPosition(ccp(countryWarCoin:getPositionX()+countryWarCoin:getContentSize().width+10,countryWarCoin:getPositionY()))
    _countryWarCoinNumLabel:setColor(ccc3(0xff,0xf6,0x00))
    _bgSp:addChild(_countryWarCoinNumLabel)
    -- 国战币携带上限 yr_5012
    local upperNum = CountryWarFoundationData.getCarryUpper()
    local upperLabel = CCLabelTTF:create(GetLocalizeStringBy("yr_5012",upperNum),g_sFontName,18)
    upperLabel:setAnchorPoint(ccp(0,0.5))
    upperLabel:setPosition(ccp(_bgSp:getContentSize().width-upperLabel:getContentSize().width-20,countryWarCoinLabel:getPositionY()))
    upperLabel:setColor(ccc3(0xfe,0x7e,0x00))
    _bgSp:addChild(upperLabel)
    -- 创建兑换详细
    createRechargeDetail()
    -- 创建底部说明
    require "script/libs/LuaCCLabel"
    local richInfo = {
        linespace = 2, -- 行间距
        alignment = 2, -- 对齐方式  1 左对齐，2 居中， 3右对齐
        lineAlignment = 2, -- 当前行在竖直方向上的对齐方式 1，下对齐， 2，居中， 3，上对齐
        labelDefaultFont = g_sFontname,
        labelDefaultColor = ccc3(0x78,0x25,0x00),
        labelDefaultSize = 21,
        defaultType = "CCLabelTTF",
        elements =
        {
            {
                newLine = false,
                text = GetLocalizeStringBy("yr_5013"),
            },
            {
                newLine = true,
                text = GetLocalizeStringBy("yr_5014"),
            },
        }
    }
    local richTextLayer = LuaCCLabel.createRichLabel(richInfo)
    richTextLayer:setAnchorPoint(ccp(0.5,0.5))
    richTextLayer:setPosition(ccp(_bgSp:getContentSize().width/2,80))
    _bgSp:addChild(richTextLayer)
end

--[[
	@des 	: 创建Layer
	@param 	: 
	@return : 
--]]
function createLayer( pTouchPriority, pZorder )
	-- init
	init()
	_touchPriority = pTouchPriority or -620
	_zOrder = pZorder or 1000
	_bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bgLayer:registerScriptHandler(onNodeEvent)
	-- createUI
	createUI()

	return _bgLayer
end

--[[
	@des 	: 显示Layer
	@param 	: 
	@return : 
--]]
function showLayer( pTouchPriority, pZorder )
	local layer = createLayer(pTouchPriority,pZorder)
	local runningScene = CCDirector:sharedDirector():getRunningScene()
    runningScene:addChild(layer,_zOrder)
end
