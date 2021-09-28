-- Filename: SignRewardLayer.lua
-- Author: zz
-- Date: 2013-07-30
-- Purpose: 该文件用于: 签到系统

module ("SignRewardLayer", package.seeall)

require "script/utils/extern"

require "script/ui/sign/SignRewardCell"
require "script/libs/LuaCC"
require "script/ui/sign/SignCache"
require "script/network/RequestCenter"
require "script/ui/tip/AnimationTip"
require "script/model/DataCache"
require "script/audio/AudioUtil"

local _onRunningLayer= nil 					-- 当前运行的层

local _tableViewSp							-- tableView的背景
local _tableView = nil						-- 创建的tableView
local  _tipSprite
local IMG_PATH = "images/sign/" 

local signButtonClickCallback = nil
local layerDidLoadCalllback   = nil
local layerCloseCallback 	  = nil
local x = 1


function init( )

 	_onRunningLayer= nil
 	_signItemImage = nil
 	_tipSprite = nil
 	_signEffect = nil
 	
end

-- 初始化
function ininlize()

	_tableView = nil
	_tableViewSp = nil
	_cancelBtn = nil
	_signLayer = nil
	_signBG = nil
end



-- 关闭按钮函数
 function cancelBtnCallBack()

	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_boolEffect =  SignCache.getBoolEffect()
	if(_boolEffect == false and    _signEffect ~= nil ) then
		_signEffect:removeFromParentAndCleanup(true)
		_signEffect = nil
		-- _signEffect:setVisible(false)
		_tipSprite:setVisible(false)
	end
	if(layerCloseCallback ~= nil)then
		layerCloseCallback()
	end
	_signLayer:removeFromParentAndCleanup(true)
	_signLayer= nil
end

-- 签到的回调函数
local function signInfoCallbck( cbFlag, dictData, bRet )
	if(dictData.err == "ok") then
		-- print("dictData.re  ======0")
		-- print_t(dictData.ret)
		SignCache.setSignInfo(dictData.ret)

		createTableView()
	end

end

-- 创建签到的tableView 和升级按钮
function createTableView( )

	local rewardData = SignCache.getAllRewardData()
	local cellSize = CCSizeMake(551,204)	
	local handler = LuaEventHandler:create(function(fn, table, a1, a2)
		local r
		if (fn == "cellSize") then
			r = CCSizeMake(cellSize.width, cellSize.height)
		elseif (fn == "cellAtIndex") then
            	a2= SignRewardCell.createCell(rewardData[a1+1])
              r = a2
        elseif fn == "numberOfCells" then
            r=  #rewardData
		elseif (fn == "cellTouched") then
		else
		end
		return r
	end)	

	_tableView= LuaTableView:createWithHandler(handler,CCSizeMake(570,685))
	_tableView:setBounceable(true)
	_tableView:setTouchPriority(-551)
	_tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	_tableView:setPosition(ccp(5,5))
	_tableViewSp:addChild(_tableView)

	refreshTableView()
end

function refreshTableView(  )
	local contentOffset = _tableView:getContentOffset()
	local index= SignCache.getIndexOfCanReceive()
	-- print("index is :  ", index)

	contentOffset.y = contentOffset.y+ index*204

	_tableView:setContentOffset(contentOffset)
end


local function onTouchesHandler( eventType, x, y )
	if (eventType == "began") then
	    return true
	end
end

-- 创建签到界面
local function createSignLayer( )
	ininlize()
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	_signLayer = CCLayerColor:create(ccc4(11,11,11,166))
	runningScene:addChild(_signLayer,999)

	_signLayer:registerScriptTouchHandler(onTouchesHandler, false, -551, true)
	_signLayer:setTouchEnabled(true)

	-- 九宫格图片
	local fullRect = CCRectMake(0, 0, 213, 171)
	local insetRect = CCRectMake(84, 84, 2, 3)
	_signBG= CCScale9Sprite:create("images/common/viewbg1.png", fullRect, insetRect)
	require "script/ui/rewardCenter/AdaptTool"
	_signBG:setPreferredSize(CCSizeMake(628,797))
	_signBG:setPosition(ccp(g_winSize.width*0.5,g_winSize.height/2))
	_signBG:setAnchorPoint(ccp(0.5,0.5))
	AdaptTool.setAdaptNode(_signBG)
	_signLayer:addChild(_signBG)

	--createBgAction(_signBG)

	local titleBg= CCSprite:create("images/common/viewtitle1.png")
	titleBg:setPosition(ccp(_signBG:getContentSize().width*0.5,_signBG:getContentSize().height-6))
	titleBg:setAnchorPoint(ccp(0.5, 0.5))
	_signBG:addChild(titleBg)

	--奖励的标题文本
	 
local labelTitle
if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
	labelTitle = CCRenderLabel:create(GetLocalizeStringBy("key_1254"), g_sFontPangWa,25,2,ccc3(0x0,0x00,0x0),type_stroke)
else
	labelTitle = CCRenderLabel:create(GetLocalizeStringBy("key_1254"), g_sFontPangWa,35,2,ccc3(0x0,0x00,0x0),type_stroke)
end
	labelTitle:setSourceAndTargetColor(ccc3( 0xff, 0xf0, 0x49), ccc3( 0xff, 0xa2, 0x00));
	labelTitle:setPosition(ccp(titleBg:getContentSize().width*0.5,titleBg:getContentSize().height*0.5+2 ))
	labelTitle:setAnchorPoint(ccp(0.5,0.5))
	titleBg:addChild(labelTitle)

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
	_tableViewSp:setPreferredSize(CCSizeMake(574,700))
	_tableViewSp:setPosition(ccp(_signBG:getContentSize().width*0.05,40))
	_signBG:addChild(_tableViewSp)

	--网络和数据相关，
	local signInfo = SignCache.getSignInfo()  
	if(signInfo == nil) then 
		--RequestCenter.sign_getSignInfo(signInfoCallbck)
		Network.rpc(signInfoCallbck, "sign.getNormalInfo" , "sign.getNormalInfo", nil , true)
	else
		createTableView()
	end
	if(layerDidLoadCalllback ~= nil)then
		local seq = CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCCallFunc:create(function ( ... )
			layerDidLoadCalllback()
		end))
		_signBG:runAction(seq)
	end
end

-- 创建动画：背景打出屏幕得效果
function createBgAction( background)
	local args = CCArray:create()
	local scale1 = CCScaleBy:create(0.08,1.1)
	local scale2 = CCScaleBy:create(0.05,0.9)
    local scale3 = CCScaleTo:create(0.07,1)
    args:addObject(scale1)
    args:addObject(scale2)
    args:addObject(scale3)

    background:runAction(CCSequence:create(args))
end

function singBtnCallBack(  )
	if(signButtonClickCallback ~= nil)then
		signButtonClickCallback()
	end
	-- 功能节点开启
	local canEnter = DataCache.getSwitchNodeState(ksSwitchSignIn)
	if(canEnter) then 
		-- 调用签到界面函数
		AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
		createSignLayer()
	else
		return
	end
end



-- 创建签到按钮
function createSingBtn(bglayer)
	init()
	-- 创建按钮图标
	_signItemImage= CCMenuItemImage:create(IMG_PATH .. "sign/sign_n.png",IMG_PATH .. "sign/sign_h.png")
	_signItemImage:setAnchorPoint(ccp(0, 1))
	-- 感叹号
	createTipSprite()
	signEffect()
	_signItemImage:registerScriptTapHandler(singBtnCallBack)
	
	if bglayer then
		_onRunningLayer = bglayer
		local bgSize = bglayer:getContentSize()
		local menu = CCMenu:create()
		menu:setPosition(ccp(0,0))
		_onRunningLayer:addChild(menu)
		menu:addChild(_signItemImage,1,1)
		_signItemImage:setPosition(bgSize.width*0.8/MainScene.elementScale, bgSize.height*0.98/MainScene.elementScale)
	end
	return _signItemImage
end


-- 获得特效
function signEffect( )

	_boolEffect = SignCache.getBoolEffect()
	-- print("the boolEffect is : " , _boolEffect)
	-- 特效
	if(_signEffect ~= nil) then
		_signEffect:removeFromParentAndCleanup(true)
		_signEffect = nil
	end
	
	if(_boolEffect == true ) then
		local img_path = CCString:create("images/sign/qiandao/qiandao") 
		_signEffect =  CCLayerSprite:layerSpriteWithName(img_path, -1,CCString:create(""))
		-- 适配
		_signEffect:setPosition(ccp(_signItemImage:getContentSize().width*0.5,_signItemImage:getContentSize().height*0.5))
		_signEffect:setAnchorPoint(ccp(0.5,0.5))
		_signEffect:setFPS_interval(1/60.0)
		_signItemImage:addChild(_signEffect)
		_tipSprite:setVisible(true)
	end
end

function createTipSprite(  )
	require "script/utils/ItemDropUtil"
	_tipSprite=  ItemDropUtil.getTipSpriteByNum(1) --CCSprite:create("images/common/tip_1.png")
	_tipSprite:setPosition(ccp(_signItemImage:getContentSize().width*0.97, _signItemImage:getContentSize().height*0.98))
	_tipSprite:setAnchorPoint(ccp(1,1))
	_tipSprite:setVisible(false)
	_signItemImage:addChild(_tipSprite,1)


end


----------------------------------- 下面的是 ：新手引导 --------------------
-- 获得关闭按钮
 function getCancelBtn(  )
 	return _cancelBtn
 end

function getSignBtn( )
	return _signItemImage
end

-- 获得连续签到时的领取按钮
 function getReceiveBtn(  )
 	local curCell =  tolua.cast(_tableView:cellAtIndex(0),"CCTableViewCell")
 	print("curCell is :  ", curCell)
 	local receiveTag = 1
 	local receiveBtn = tolua.cast(curCell:getChildByTag(1):getChildByTag(101):getChildByTag(receiveTag),"CCMenuItemSprite")
 	return receiveBtn
 end

--add by lichenyang 2013.9.9
function registerSignButtonClickCallback( p_callback )
	-- body
	signButtonClickCallback = p_callback
end

function registerSignLayerDidLoadCallback( p_callback )
	layerDidLoadCalllback = p_callback	
end

function registerSignLayerCloseCallback( p_callback )
	layerCloseCallback = p_callback
end
