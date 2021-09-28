-- Filename：	BuyCopyAtkLayer.lua
-- Author：		zhz
-- Date：		2014-5-4
-- Purpose：		花费金币增加对应副本的当前可攻打次数

module("BuyCopyAtkLayer", package.seeall)

require "script/audio/AudioUtil"
require "script/model/DataCache"
require "script/model/user/UserModel"
require "db/DB_Vip"



local _bgLayer 			= nil	--背景layer
local _buyAtkBg			= nil
local _touchPriority
local _zOrder
local _cType					-- 副本的类型，（目前仅仅是副本，其他的暂时不加）
local _buyedNumber	
local _copyCostTab 				-- 副本花费数据的Table 
local _callBackFn

local function init( ... )

	_bgLayer 			=nil
	_buyAtkBg			=nil
	_touchPriority		=nil
	_zOrder				=nil
	_cType				= 0
	_buyedNumber		= 0
	_copyCostTab		= {}
	_callBackFn			= nil
end



local  function layerToucCb( ... )
	return true
end


-- 显示layer， 
--cType :1==精英副本、2==摇钱树副本、3==经验宝物宝物副本、4==军团组队副本
function showLayer( cType, buyedNumber,callBackFn, touchProperty, zOrder)

	init()
	_cType = cType or 0
	_buyedNumber= tonumber(buyedNumber)  

	handleCopyCost()

	print("buy_atk_num is ",buyedNumber , " _cType  is ", _cType)
	-- if(tonumber(buyedNumber)< tonumber(_copyCostTab.maxBuyNUmber)) then
	-- 	AnimationTip.showTip(GetLocalizeStringBy("key_1607"))
	-- 	return
	-- end

	_bgLayer = CCLayerColor:create(ccc4(11,11,11,166))

	_touchPriority= touchPriority or -566
  	_zOrder = zOrder or 700

  	_cType = cType or 0
  	_buyedNumber= tonumber(buyedNumber)  
  	_callBackFn = callBackFn
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        	_bgLayer:setTouchEnabled(true)
    _bgLayer:registerScriptTouchHandler(layerToucCb,false,_touchPriority,true)

    local scene = CCDirector:sharedDirector():getRunningScene()
 	scene:addChild(_bgLayer,_zOrder,2014)

 	local mySize= CCSizeMake(572,360)
 	local myScale = MainScene.elementScale

	local fullRect = CCRectMake(0, 0, 213, 171)
    local insetRect = CCRectMake(100, 80, 10, 20)
    _buyAtkBg = CCScale9Sprite:create("images/common/viewbg1.png",fullRect,insetRect)
    _buyAtkBg:setContentSize(mySize)
    _buyAtkBg:setScale(myScale)
    _buyAtkBg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    _buyAtkBg:setAnchorPoint(ccp(0.5,0.5))
    _bgLayer:addChild(_buyAtkBg)


    local menuBar= CCMenu:create()
    menuBar:setPosition(0,0)
    menuBar:setTouchPriority(_touchPriority-1)
    _buyAtkBg:addChild(menuBar,11)

	local cancelBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(160, 73),GetLocalizeStringBy("key_1985"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	cancelBtn:setAnchorPoint(ccp(0.5, 0))
    cancelBtn:setPosition(ccp(_buyAtkBg:getContentSize().width*0.25, 28))
    cancelBtn:registerScriptTapHandler(sureCb)
	menuBar:addChild(cancelBtn, 1)

	local sureBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(160, 73),GetLocalizeStringBy("key_1202"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	sureBtn:setAnchorPoint(ccp(0.5, 0))
    sureBtn:setPosition(ccp(_buyAtkBg:getContentSize().width*0.75, 28))
    sureBtn:registerScriptTapHandler(closeCb)
	menuBar:addChild(sureBtn, 1)

    local closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    closeBtn:setPosition(ccp(mySize.width*1.05,mySize.height*1.05))
    closeBtn:setAnchorPoint(ccp(1,1))
    closeBtn:registerScriptTapHandler(closeCb)
    menuBar:addChild(closeBtn)

    createBuyBg()

end



function createBuyBg()
	local buyBg =CCScale9Sprite:create("images/common/bg/bg_ng_attr.png")
    buyBg:setContentSize(CCSizeMake(521,212))
    buyBg:setPosition(ccp(_buyAtkBg:getContentSize().width/2,100))
    buyBg:setAnchorPoint(ccp(0.5,0))
    _buyAtkBg:addChild(buyBg)

    local coseLabel_1= CCLabelTTF:create(GetLocalizeStringBy("key_1088"), g_sFontPangWa, 21)
    coseLabel_1:setColor(ccc3(0xff,0xff,0xff))
    local goldSp= CCSprite:create("images/common/gold.png")
    _costGoldLabel = CCLabelTTF:create("" .._copyCostTab.costGold+ _copyCostTab.addGold*_buyedNumber,g_sFontPangWa, 21)
    _costGoldLabel:setColor(ccc3(0xff,0xf6,0x00))

    local coseLabel_2= CCLabelTTF:create(GetLocalizeStringBy("key_1773") .. _copyCostTab.dbCopyName .. GetLocalizeStringBy("key_3232"),g_sFontPangWa,21  )
    coseLabel_2:setColor(ccc3(0xff,0xff,0xff))

    local costNode=  BaseUI.createHorizontalNode({coseLabel_1,goldSp,_costGoldLabel, coseLabel_2})
    costNode:setPosition(buyBg:getContentSize().width/2 ,155)
    costNode:setAnchorPoint(ccp(0.5,0 ))
    buyBg:addChild(costNode)

    local buyLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2168"), g_sFontName, 21) 
    buyLabel:setColor(ccc3(0x00,0xff, 0x18))
    _hasBuyLabel = CCLabelTTF:create("" ..  _buyedNumber .. GetLocalizeStringBy("key_3010") , g_sFontName,21 )
    _hasBuyLabel:setColor(ccc3(0x00,0xff, 0x18))

    local buyNode = BaseUI.createHorizontalNode({buyLabel,_hasBuyLabel} )
    buyNode:setPosition(buyBg:getContentSize().width/2, 96)
    buyNode:setAnchorPoint(ccp(0.5,0))
    buyBg:addChild(buyNode)

    -- 

 	local vipLabel_1 = CCLabelTTF:create(GetLocalizeStringBy("key_1620"), g_sFontPangWa, 21)
    vipLabel_1:setColor(ccc3(0xff,0xf6,0x00))
    local vip_lv  = CCSprite:create ( "images/common/vip.png")
    -- VIP对应级别
    require "script/libs/LuaCC"
    _vip_lv_num = LuaCC.createNumberSprite02("images/main/vip", UserModel.getVipLevel() , 15)
    local vipLabel_2= CCLabelTTF:create(GetLocalizeStringBy("key_2373"), g_sFontPangWa,21)
    vipLabel_2:setColor(ccc3(0xff,0xf6,0x00))
    vipLabel_3= CCLabelTTF:create("" .. _copyCostTab.maxBuyNumber,g_sFontPangWa ,21)
	vipLabel_3:setColor(ccc3(0x00,0xff,0x18))
	vipLabel_4= CCLabelTTF:create(GetLocalizeStringBy("key_3010") , g_sFontPangWa,21)
	vipLabel_4:setColor(ccc3(0xff,0xf6,0x00))

	local vipNode = BaseUI.createHorizontalNode( { vipLabel_1,vip_lv,_vip_lv_num, vipLabel_2, vipLabel_3,vipLabel_4 })
	vipNode:setPosition(buyBg:getContentSize().width/2, 40)
	vipNode:setAnchorPoint(ccp(0.5,0))
	buyBg:addChild(vipNode)

    -- local vipSp= CCSprite:create("images/common/gold.png")
    -- _costGoldLabel = CCLabelTTF:create("" .._copyCostTab.costGold+ _copyCostTab.addGold*_buyedNumber,g_sFontPangWa, 21)
    -- _copyCostLael:setColor(ccc3(0xff,0xf6,0x00))


end

function refreshBuyBg(  )
	_costGoldLabel:setString("" .._copyCostTab.costGold+ _copyCostTab.addGold*_buyedNumber)
	_hasBuyLabel:setString("" .. _buyedNumber)

end



function handleCopyCost( )
	
	local dbCopyCost = nil
	local curVipId= UserModel.getVipLevel()+1
	local dbCopyName = GetLocalizeStringBy("key_2748")

	if( _cType == 1) then 
		dbCopyCost= DB_Vip.getDataById(curVipId).eliteCopyCost
		dbCopyName= GetLocalizeStringBy("key_2748")
	elseif(_cType == 2) then
		dbCopyName= GetLocalizeStringBy("key_1644")
		dbCopyCost= DB_Vip.getDataById(curVipId).moneyTreeDayCost
	elseif(_cType == 3)then
		dbCopyName= GetLocalizeStringBy("key_1029")
		dbCopyCost= DB_Vip.getDataById(curVipId).expCopyCost
	elseif(_cType == 4) then	
		dbCopyName= GetLocalizeStringBy("key_1237")
		dbCopyCost= DB_Vip.getDataById(curVipId).teamCopyCost
	elseif(_cType == 5) then
		-- 主角经验副本	
		dbCopyName= GetLocalizeStringBy("lcyx_1818")
		dbCopyCost= DB_Vip.getDataById(curVipId).LeadExpCopyCost
	-- elseif(_cType == 6) then  --增加英雄天命 2016.5.27 zhangqiang
	-- 	dbCopyName= GetLocalizeStringBy("zq_0000")
	-- 	dbCopyCost= HeroDestineyCopyData.getBuyAtkNumString()
	end	


	local copyCost = lua_string_split( dbCopyCost , "|")
	_copyCostTab.maxBuyNumber = tonumber(copyCost[1])
	_copyCostTab.costGold= tonumber(copyCost[2])
	_copyCostTab.addGold = tonumber(copyCost[3])
	_copyCostTab.dbCopyName= dbCopyName

end

function closeLayer( )
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer=nil

	print("_callBackFn is ", _callBackFn)
	if( _callBackFn~= nil ) then
		_callBackFn()
	end
	
end




------------------------ [[按钮的回调事件 和网络事件]]------------------------------

function closeCb(tag, item)
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer=nil

	if( _callBackFn~= nil ) then
		_callBackFn()
	end
	
end

-- --cType :1==精英副本、2==摇钱树副本、3==经验宝物宝物副本、4==军团组队副本
function sureCb( tag, item)
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	local args= CCArray:create()
	args:addObject(CCInteger:create(1))

	if(  _buyedNumber>= _copyCostTab.maxBuyNumber ) then 
		AnimationTip.showTip(GetLocalizeStringBy("key_2222") )
		return
	end

	if(_copyCostTab.costGold + _copyCostTab.addGold*_buyedNumber > UserModel.getGoldNumber() ) then
		require "script/ui/tip/LackGoldTip"
		LackGoldTip.showTip()
		return
	end


	if(_cType==1) then

		Network.rpc(buyECopyAtkCb, "ecopy.buyAtkNum", "ecopy.buyAtkNum", args, true)

	elseif(_cType ==2 ) then
		Network.rpc(buyGoldTreeAtkCb, "acopy.buyGoldTreeAtkNum", "acopy.buyGoldTreeAtkNum", args, true)
	elseif( _cType ==3) then
		Network.rpc(buyExpTreasAtkCb, "acopy.buyExpTreasAtkNum", "acopy.buyExpTreasAtkNum", args, true)
	elseif( _cType== 4) then

		--if(  _buyedNumber< _copyCostTab.maxBuyNUmber ) then 		
			Network.rpc(buyCopyTeamAtkCb, "copyteam.buyAtkNum", "copyteam.buyAtkNum", args, true)
		--else
			
		--	return 
		--end
	elseif(_cType == 5) then
		--主角经验副本
		require "script/ui/copy/expcopy/ExpCopyController"
		ExpCopyController.buyExpUserAtkNum(1)
		closeLayer()
	-- elseif(_cType == 6) then --增加英雄天命 2016.5.27 zhangqiang
	-- 	-- AnimationTip.showTip(GetLocalizeStringBy("zq_0000"))

	-- 	require "script/ui/copy/heroDestineyCopy/HeroDestineyCopyService"
	-- 	HeroDestineyCopyService.buyDestinyAtkNum(1, buyDestinyAtkNumCb)
	end

end

-- 军团组队副本的购买回调函数
function buyCopyTeamAtkCb( cbFlag, dictData, bRet )
	require "script/ui/guild/copy/GuildTeamData"
	if(dictData.ret == "ok") then
		GuildTeamData.addGuildAtkNum(1)
		GuildTeamData.addBuyAtkNum(1)
		_buyedNumber =_buyedNumber+1

		AnimationTip.showTip(GetLocalizeStringBy("key_2512"))
		-- refreshBuyBg()
		local gold = _copyCostTab.costGold + _copyCostTab.addGold*(_buyedNumber-1) 
		UserModel.addGoldNumber(  -gold)
		
		closeLayer()
		
	end
end


function buyECopyAtkCb( cbFlag, dictData, bRet )
	require "script/model/DataCache"
	if(dictData.ret == "ok") then
		DataCache.addCanDefatNum(1)
		DataCache.addBuyAtkNum(1)
		_buyedNumber =_buyedNumber+1

		AnimationTip.showTip(GetLocalizeStringBy("key_1101"))

		local gold = _copyCostTab.costGold + _copyCostTab.addGold*(_buyedNumber-1) 
		UserModel.addGoldNumber(  -gold)

		-- refreshBuyBg()
		closeLayer()
		

	end
end

-- 购买摇钱树的
function buyGoldTreeAtkCb( cbFlag, dictData, bRet )
	require "script/model/DataCache"
	if(dictData.ret == "ok") then
		DataCache.addGoldTreeDefeatNum(1)
		DataCache.addGoldTreeAtkNum(1)
		_buyedNumber =_buyedNumber+1

		AnimationTip.showTip(GetLocalizeStringBy("key_2202"))
		-- refreshBuyBg()


		local gold = _copyCostTab.costGold + _copyCostTab.addGold*(_buyedNumber-1) 
		UserModel.addGoldNumber(  -gold)
		closeLayer()

	end
end

-- 购买经验书的
function buyExpTreasAtkCb( cbFlag, dictData, bRet)
	require "script/model/DataCache"
	if(dictData.ret == "ok") then
		DataCache.addTreasureExpDefeatNum(1)
		DataCache.addTreasureAtkNum(1)
		_buyedNumber =_buyedNumber+1

		AnimationTip.showTip(GetLocalizeStringBy("key_2520"))
		-- refreshBuyBg()
		local gold = _copyCostTab.costGold + _copyCostTab.addGold*(_buyedNumber-1) 
		UserModel.addGoldNumber(  -gold)
		closeLayer()

	end
end

-- -- 购买英雄天命的攻打次数
-- function buyDestinyAtkNumCb( pDictRet )
-- 	if(pDictRet == "ok")then
-- 		require "script/ui/copy/heroDestineyCopy/HeroDestineyCopyData"
-- 		HeroDestineyCopyData.addLeftAtkNum(1)
-- 		HeroDestineyCopyData.addBuyNum(1)
-- 		_buyedNumber =_buyedNumber+1

-- 		AnimationTip.showTip(GetLocalizeStringBy("zq_0007"))   --购买成功提示

-- 		local gold = _copyCostTab.costGold + _copyCostTab.addGold*(_buyedNumber-1) 
-- 		UserModel.addGoldNumber(  -gold)
-- 		closeLayer()
-- 	end
-- end


