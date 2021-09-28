-- Filename: AccSignRewardLayer.lua
-- Author: zhz
-- Date: 2013-12-2
-- Purpose: 该文件用于: 累计签到

module("AccSignRewardLayer", package.seeall)

require "script/ui/sign/AccSignRewardCell"
require "script/libs/LuaCC"
require "script/ui/sign/SignCache"
require "script/network/RequestCenter"
require "script/ui/tip/AnimationTip"
require "script/model/DataCache"
require "script/audio/AudioUtil"
require "script/utils/ItemDropUtil"

local _onRunningLayer= nil 					-- 当前运行的层

local _tableViewSp							-- tableView的背景
local _tableView = nil						-- 创建的tableView
local  _tipSprite
local _boolEffect 							-- 是否有特效
local _canReceiveNum						-- 可以领取的数量
local IMG_PATH = "images/sign/" 

local signButtonClickCallback = nil


function init( )

 	_onRunningLayer= nil
 	_signItemImage = nil
 	_tipSprite = nil
 	_signEffect = nil
 	_boolEffect= nil
 	_canReceiveNum = nil
end

-- 初始化
function ininlize()
	_tableView = nil
	_tableViewSp = nil
	_cancelBtn = nil
	_accSignLayer = nil
	_accSignBG = nil
end

-- 关闭按钮函数
 function cancelBtnCallBack()

	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	-- _boolEffect =  SignCache.getBoolEffect()
	-- if(_boolEffect == false and    _signEffect ~= nil ) then
	-- 	_signEffect:removeFromParentAndCleanup(true)
	-- 	_signEffect = nil
	-- 	-- _signEffect:setVisible(false)
	-- 	_tipSprite:setVisible(false)
	-- end
	_accSignLayer:removeFromParentAndCleanup(true)
	_accSignLayer= nil
	releaseEffect()
	releaseBtn()
	require "script/ui/main/MainMenuLayer"
	MainMenuLayer.updateTopButton()
end



-- 创建签到的tableView 和升级按钮
function createTableView( )

	local rewardData = SignCache.getAccRewardData()
	local cellSize = CCSizeMake(551,204)	
	local handler = LuaEventHandler:create(function(fn, table, a1, a2)
		local r
		if (fn == "cellSize") then
			r = CCSizeMake(cellSize.width, cellSize.height)
		elseif (fn == "cellAtIndex") then
            	a2= AccSignRewardCell.createCell(rewardData[a1+1])
              r = a2
        elseif fn == "numberOfCells" then
            r=  #rewardData
		elseif (fn == "cellTouched") then
		else
		end
		return r
	end)	

	_tableView= LuaTableView:createWithHandler(handler,CCSizeMake(570,615))
	_tableView:setBounceable(true)
	_tableView:setTouchPriority(-551)
	_tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	_tableView:setPosition(ccp(5,5))
	_tableViewSp:addChild(_tableView)


	refreshTableView()

end

function refreshTableView(  )
	local contentOffset = _tableView:getContentOffset()
	local index= SignCache.getAccIndexofCanReceive()
	print("index is :  ", index)

	contentOffset.y = contentOffset.y+ index*204

	_tableView:setContentOffset(contentOffset)
end

function accSignInfoCallbck( cbFlag, dictData, bRet )
	if(dictData.err == "ok") then
		-- print("dictData.re  ======0")
		-- print_t(dictData.ret)
		SignCache.setAccSignInfo(dictData.ret)
		createTableView()
	end

end

-- 
local function onTouchesHandler( eventType, x, y )
	if (eventType == "began") then
	    return true
	end
end

-- 创建签到界面
local function createAccSignLayer( )
	ininlize()
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	_accSignLayer = CCLayerColor:create(ccc4(11,11,11,166))
	runningScene:addChild(_accSignLayer,999)

	_accSignLayer:registerScriptTouchHandler(onTouchesHandler, false, -551, true)
	_accSignLayer:setTouchEnabled(true)

	-- 九宫格图片
	local fullRect = CCRectMake(0, 0, 213, 171)
	local insetRect = CCRectMake(84, 84, 2, 3)
	_signBG= CCScale9Sprite:create("images/common/viewbg1.png", fullRect, insetRect)
	require "script/ui/rewardCenter/AdaptTool"
	_signBG:setPreferredSize(CCSizeMake(628,797))
	_signBG:setPosition(ccp(g_winSize.width*0.5,g_winSize.height/2))
	_signBG:setAnchorPoint(ccp(0.5,0.5))
	AdaptTool.setAdaptNode(_signBG)
	_accSignLayer:addChild(_signBG)

 --	createBgAction( _signBG)

	local titleBg= CCSprite:create("images/common/viewtitle1.png")
	titleBg:setPosition(ccp(_signBG:getContentSize().width*0.5,_signBG:getContentSize().height-6))
	titleBg:setAnchorPoint(ccp(0.5, 0.5))
	_signBG:addChild(titleBg)

	--奖励的标题文本
	local labelTitle = CCRenderLabel:create(GetLocalizeStringBy("key_3141"), g_sFontPangWa,35,2,ccc3(0x0,0x00,0x0),type_stroke)
	labelTitle:setSourceAndTargetColor(ccc3( 0xff, 0xf0, 0x49), ccc3( 0xff, 0xa2, 0x00));
	labelTitle:setPosition(ccp(titleBg:getContentSize().width*0.5,titleBg:getContentSize().height*0.5+2 ))
	labelTitle:setAnchorPoint(ccp(0.5,0.5))
	titleBg:addChild(labelTitle)

	local alertContent = {}
	--兼容东南亚英文版
	if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
		alertContent[1] =  CCRenderLabel:create(GetLocalizeStringBy("key_1621"), g_sFontPangWa, 30,1, ccc3(0xff,0xff,0xff),type_stroke)
		alertContent[1]:setColor(ccc3(0x78,0x25,0x00))
	else
		alertContent[1] = CCRenderLabel:create(GetLocalizeStringBy("key_2571"), g_sFontPangWa, 30,1, ccc3(0xff,0xff,0xff),type_stroke)
		alertContent[1]:setColor(ccc3(0x78,0x25,0x00))
		alertContent[2] = CCRenderLabel:create("7", g_sFontPangWa, 30,1, ccc3(0xff,0xff,0xff),type_stroke)
		alertContent[2]:setColor(ccc3(0x08,0x78,0x00))
		alertContent[3] =  CCRenderLabel:create(GetLocalizeStringBy("key_1621"), g_sFontPangWa, 30,1, ccc3(0xff,0xff,0xff),type_stroke)
		alertContent[3]:setColor(ccc3(0x78,0x25,0x00))
		alertContent[4] = CCRenderLabel:create(GetLocalizeStringBy("key_1268"), g_sFontPangWa, 30,1, ccc3(0xff,0xff,0xff),type_stroke)
		alertContent[4]:setColor(ccc3(0xaa,0x18,0xb3))
		alertContent[5]= CCRenderLabel:create("”！", g_sFontPangWa, 30,1, ccc3(0xff,0xff,0xff),type_stroke)
		alertContent[5]:setColor(ccc3(0x78,0x25,0x00))
	end
	local alertNode = BaseUI.createHorizontalNode(alertContent)
	alertNode:setPosition(ccp(_signBG:getContentSize().width/2,690))
	alertNode:setAnchorPoint(ccp(0.5,0))
	_signBG:addChild(alertNode)


	-- 关闭按钮
	local menu =CCMenu:create()
	menu:setPosition(ccp(0,0))
	menu:setTouchPriority(-551)
	_signBG:addChild(menu,1000)
	_cancelBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	_cancelBtn:setAnchorPoint(ccp(1, 1))
	_cancelBtn:setPosition(ccp(_signBG:getContentSize().width+14, _signBG:getContentSize().height+14))
	_cancelBtn:registerScriptTapHandler(cancelBtnCallBack)
	menu:addChild(_cancelBtn)

	local rect = CCRectMake(0,0,75,75)
	local insert = CCRectMake(28,28,6,6)
	_tableViewSp = CCScale9Sprite:create("images/sign/tableBg.png",rect,insert)
	--_tableViewSp:setPreferredSize(CCSizeMake(574, 492))
	_tableViewSp:setPreferredSize(CCSizeMake(574,625))
	_tableViewSp:setPosition(ccp(_signBG:getContentSize().width*0.05,40))
	_signBG:addChild(_tableViewSp)

	--网络和数据相关，
	local accSignInfo = SignCache.getAccSignInfo()  
	-- if(accSignInfo == nil) then 
	 Network.rpc(accSignInfoCallbck, "sign.getAccInfo" , "sign.getAccInfo", nil , true)
	-- else
		--createTableView()
	-- end
end

-- 创建动画：背景打出屏幕得效果
function createBgAction( background)
	local args = CCArray:create()
	local scale1 = CCScaleBy:create(0.08,1.1)
	local scale2 = CCScaleBy:create(0.06,0.8)
    local scale3 = CCScaleTo:create(0.07,1)
    args:addObject(scale1)
    args:addObject(scale2)
    args:addObject(scale3)

    background:runAction(CCSequence:create(args))
end

function accSingBtnCallBack( tag,item )

	-- if(signButtonClickCallback ~= nil)then
	-- 	signButtonClickCallback()
	-- end
	--if(DataCache.getSwitchNodeState(ksSwitchSignIn)) then
		AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
		createAccSignLayer()
	--end
end


-- 创建签到按钮
function createAccSingBtn(bglayer)
	init()
	_onRunningLayer = bglayer

	-- 当所有奖励领取完事后，按钮不显示
		-- print("SignCache.getAccSignTimes()  is : ", SignCache.getAccSignTimes())
	if(tonumber(SignCache.getAccSignTimes())== table.count(DB_Accumulate_sign.Accumulate_sign) ) then
		-- print("SignCache.getAccSignTimes()  is : ", SignCache.getAccSignTimes())
		return 
	end
	
	local bgSize = bglayer:getContentSize()
	local menu = CCMenu:create()
	menu:setPosition(ccp(0,0))
	menu:setAnchorPoint(ccp(0, 0))
	_onRunningLayer:addChild(menu)

	-- 创建按钮图标
	_signItemImage= CCMenuItemImage:create(IMG_PATH .. "sign_acc/pack_n.png",IMG_PATH .. "sign_acc/pack_h.png")
	_signItemImage:setAnchorPoint(ccp(0, 0))
	-- 位置有问题
	local size = _onRunningLayer:getContentSize()
	_signItemImage:setPosition(0, 0)
	menu:addChild(_signItemImage,1,1)

	_signItemImage:registerScriptTapHandler(accSingBtnCallBack)

	--createTipSprite()
	signEffect( )

end

function isShow()
	if not tolua.isnull(_signItemImage) then
		if _signItemImage:isVisible() then
			return true
		end
	end
	return false
end


-- 获得特效
function signEffect( )

	_boolEffect, _canReceiveNum  = SignCache.getBoolAccEffect()
---	print("the boolEffect is :  ============== ==== +++++++++++++++++++++++++ " , _boolEffect, "   can ", _canReceiveNum)
	-- 特效
	if(_signEffect ~= nil) then
		_signEffect:removeFromParentAndCleanup(true)
		_signEffect = nil
	end

	createTipSprite()
	
	if(_boolEffect == true ) then
		-- "images/base/effect/kaifulibao/kaifulibao"
		local img_path = CCString:create("images/base/effect/kaifulibao/kaifulibao") 
		_signEffect =  CCLayerSprite:layerSpriteWithName(img_path, -1,CCString:create(""))
		-- 适配
		_signEffect:setPosition(ccp(_signItemImage:getContentSize().width*0.5,_signItemImage:getContentSize().height*0.5))
		_signEffect:setAnchorPoint(ccp(0.5,0.5))
		_signEffect:setFPS_interval(1/60.0)
		_signItemImage:addChild(_signEffect,11)
		_tipSprite:setVisible(true)
	end
end

function createTipSprite(  )
	
	_tipSprite= ItemDropUtil.getTipSpriteByNum(_canReceiveNum) --  CCSprite:create("images/common/tip_1.png")
	_tipSprite:setPosition(ccp(_signItemImage:getContentSize().width*0.97, _signItemImage:getContentSize().height*0.98))
	_tipSprite:setAnchorPoint(ccp(1,1))
	_tipSprite:setVisible(false)
	_signItemImage:addChild(_tipSprite,12)

end

-- 释放按钮
function releaseBtn( )
	if(tonumber(SignCache.getAccSignTimes())== table.count(DB_Accumulate_sign.Accumulate_sign) and _signItemImage ~= nil) then
		_signItemImage:removeFromParentAndCleanup(true)
		_signItemImage= nil
		
	end
end

-- 判断是否可以释放特效
function releaseEffect( )

	local boolEffect , canReceiveNum = SignCache.getBoolAccEffect()
	if(boolEffect== false and _signEffect ~= nil) then
		_signEffect:removeFromParentAndCleanup(true)
		_signEffect = nil
		-- _tipSprite:removeFromParentAndCleanup(true)
		_tipSprite:setVisible(false)
	else
		-- local numLabel= tolua.cast(_tipSprite:getChildByTag(101), "CCLabelTTF") 
		-- numLabel:setString("" .. canReceiveNum)
		ItemDropUtil.refreshNum(_tipSprite,canReceiveNum)
	end
end


function registerSignButtonClickCallback( p_callback )
	-- body
	signButtonClickCallback = p_callback
end


























