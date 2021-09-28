-- Filename: ChangeUserNameLayer.lua
-- Author: zhz
-- Date: 2013-03-03
-- Purpose: 该文件用于: 改变玩家名字的layer

module("ChangeUserNameLayer", package.seeall)


require "script/ui/tip/AnimationTip"
require "script/network/RequestCenter"
require "script/audio/AudioUtil"
require "db/DB_Normal_config"
require "script/utils/BaseUI"
require "script/model/user/UserModel"
-- require "script/ui/main/AvatarInfoLayer"
require "script/ui/main/MainScene"

local _limitType			-- 0 是从正常进， 1是从背包进
local _bgLayer 				-- 灰色的layer
local _changeNameBg			-- 修改名字的背景
local _nameEditBox        	-- 礼品兑换码
local _touchProperty
local _zOrder
local _changeNameInfo={}
local _userName				-- 玩家获得的随即名
local _curIndex
local _curName
local _changeType =2 		--  int $type:  1.消耗金币 2.消耗物品
local _nameChangeDelegate

function init(  )
	_bgLayer = nil
	_changeNameBg= nil
	_nameEditBox= nil
	_touchProperty= nil
	_zOrder= nil
	_changeNameInfo = {}
	_curIndex= 0
	_userName= nil
	_curName= nil
	_changeType= 2
	_limitType=0
end


local function layerToucCb( )
	
	return true
end

function onNodeEvent( eventType,x,y )
	if(eventType == "exit") then
		print("exit")
		PreRequest.setBagDataChangedDelete(nil)
	end
end

local function getCostData( )
	local changeName= DB_Normal_config.getDataById(1).changeName
	local tmpName = lua_string_split(changeName , "|")
	_changeNameInfo.goldNum= tonumber(tmpName[1])
	_changeNameInfo.item_tid= tonumber(tmpName[2])

end

function showLayer(limitType ,touchProperty, zOrder )
	
	init()
	getCostData()
	_touchProperty= touchProperty or -800
	_zOrder = zOrder or 2000
	_limitType = limitType or 0

	_bgLayer= CCLayerColor:create(ccc4(11,11,11,166))
	_bgLayer:setTouchEnabled(true)
    _bgLayer:registerScriptTouchHandler(layerToucCb,false,_touchProperty,true)
    _bgLayer:registerScriptHandler(onNodeEvent)

   	local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,_zOrder,2013)

    local myScale = MainScene.elementScale
	local mySize = CCSizeMake(490,378)

	local fullRect = CCRectMake(0, 0, 213, 171)
	local insetRect = CCRectMake(84, 84, 2, 3)
   	_changeNameBg = CCScale9Sprite:create("images/common/viewbg1.png",fullRect,insetRect)
    _changeNameBg:setContentSize(mySize)
    _changeNameBg:setScale(myScale)
    _changeNameBg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5))
    _changeNameBg:setAnchorPoint(ccp(0.5,0.5))
    _bgLayer:addChild(_changeNameBg)

    local titleBg= CCSprite:create("images/common/viewtitle1.png")
	titleBg:setPosition(ccp(_changeNameBg:getContentSize().width*0.5, _changeNameBg:getContentSize().height-6))
	titleBg:setAnchorPoint(ccp(0.5, 0.5))
	_changeNameBg:addChild(titleBg)

	--奖励的标题文本
	local labelTitle = CCRenderLabel:create(GetLocalizeStringBy("key_1261"), g_sFontPangWa,33,2,ccc3(0x00,0x00,0x0),type_shadow)
	labelTitle:setColor(ccc3(0xff,0xe4,0x00))
    labelTitle:setAnchorPoint(ccp(0.5,0.5))
	labelTitle:setPosition(ccp(titleBg:getContentSize().width*0.5,titleBg:getContentSize().height*0.5))
	titleBg:addChild(labelTitle)

	local inputLabel= CCRenderLabel:create(GetLocalizeStringBy("key_2644"), g_sFontPangWa,25,1,ccc3(0xff,0xff,0xff),type_shadow)
	inputLabel:setColor(ccc3(0x78,0x25,0x00))
	inputLabel:setPosition(_changeNameBg:getContentSize().width*0.5,283)
	inputLabel:setAnchorPoint(ccp(0.5,0))
	_changeNameBg:addChild(inputLabel)

	-- 
	_nameEditBox = CCEditBox:create(CCSizeMake(284,60), CCScale9Sprite:create("images/common/bg/search_bg.png"))
	_nameEditBox:setPosition(ccp(84 ,217))
	_nameEditBox:setTouchPriority(_touchProperty-1)
	_nameEditBox:setAnchorPoint(ccp(0,0))
	_nameEditBox:setPlaceHolder(GetLocalizeStringBy("key_2916"))
	_nameEditBox:setFont(g_sFontName,24)
	_changeNameBg:addChild(_nameEditBox)

	-- 按钮
	local menu= CCMenu:create()
	menu:setPosition(ccp(0,0))
	menu:setTouchPriority(_touchProperty-1)
	_changeNameBg:addChild(menu)

	local sieveBtn = CCMenuItemImage:create("images/new_user/sieve/sieve_h.png", "images/new_user/sieve/sieve_n.png")
	sieveBtn:setPosition(ccp(389, 218 ))
	sieveBtn:registerScriptTapHandler(menuAction)
	menu:addChild(sieveBtn,11, 101)

	local sureBtn= LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(158, 64),GetLocalizeStringBy("key_1465"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	sureBtn:setPosition(_changeNameBg:getContentSize().width*0.25, 37)
	sureBtn:registerScriptTapHandler(menuAction)
	sureBtn:setAnchorPoint(ccp(0.5,0))
	menu:addChild(sureBtn,11, 102)

	local cancelBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(158, 64),GetLocalizeStringBy("key_2326"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
	cancelBtn:setPosition(_changeNameBg:getContentSize().width*0.75, 37)
	cancelBtn:registerScriptTapHandler(menuAction)
	cancelBtn:setAnchorPoint(ccp(0.5,0))
	menu:addChild(cancelBtn,11, 103)

	local closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    closeBtn:setPosition(ccp(mySize.width*1.03,mySize.height*1.03))
    closeBtn:setAnchorPoint(ccp(1,1))
    closeBtn:registerScriptTapHandler(menuAction)
    menu:addChild(closeBtn,11, 104)

    local cost_01Label= CCLabelTTF:create(GetLocalizeStringBy("key_1771"), g_sFontName,23)
    cost_01Label:setColor(ccc3(0x0,0x0,0x0))
    local goldSp= CCSprite:create("images/common/gold.png")
    local iteminfo = ItemUtil.getItemById(_changeNameInfo.item_tid)
    local cost_02_Label= CCLabelTTF:create(_changeNameInfo.goldNum .. GetLocalizeStringBy("key_3369") .. iteminfo.name .. GetLocalizeStringBy("key_2514") , g_sFontName,23)
    cost_02_Label:setColor(ccc3(0x0,0x0,0x0))

    local costNode = BaseUI.createHorizontalNode({cost_01Label, goldSp, cost_02_Label})
    costNode:setPosition(ccp(_changeNameBg:getContentSize().width/2,171))
    costNode:setAnchorPoint(ccp(0.5,0))
    _changeNameBg:addChild(costNode)

    local txtDescLabel= CCLabelTTF:create(GetLocalizeStringBy("key_2900") ..iteminfo.name .. ":", g_sFontName, 23)
    txtDescLabel:setColor(ccc3(0x0,0x0,0x0))
    local num= ItemUtil.getCacheItemNumBy( _changeNameInfo.item_tid )
    if(num == nil) then
    	num=0
    end
    _hasItemLabel= CCLabelTTF:create("" .. num , g_sFontName,23)
    _hasItemLabel:setColor(ccc3(0x00,0x6d,0x1f))

    local ItemNode= BaseUI.createHorizontalNode({ txtDescLabel, _hasItemLabel})
    ItemNode:setPosition(ccp(_changeNameBg:getContentSize().width/2,126))
    ItemNode:setAnchorPoint(ccp(0.5,0))
    _changeNameBg:addChild(ItemNode)



end



----------------------------------------------------[[刷新方法]]-----------------------------------------------------------------------
-- 刷新所有的UI
function refreshUI(  )
	
	-- 刷新物品：刷新令得数量 
	itemDelegate()
end


function registerNameChangeCb( callbackFunc)
    _nameChangeDelegate = callbackFunc
end



--------------------------------------------------[[按钮的回调 ]]-----------------------------------------------------
function menuAction( tag, item)

	if( tag== 101) then 
		require "script/audio/AudioUtil"
		AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
		createRandomName()
	elseif(tag == 102) then
		require "script/audio/AudioUtil"
		AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
		changeUserName()
	elseif(tag == 103) then
		require "script/audio/AudioUtil"
		AudioUtil.playEffect("audio/effect/guanbi.mp3")
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer=nil
	elseif(tag == 104) then
		require "script/audio/AudioUtil"
		AudioUtil.playEffect("audio/effect/guanbi.mp3")
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer=nil
	end
end


function closeCb( )
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer=nil
end

local function bagChangedDelegateFunc1( )

	local itemNum = ItemUtil.getCacheItemNumBy( _changeNameInfo.item_tid )
	_hasItemLabel:setString(tostring(itemNum))
	
end

function itemDelegate( )
	 PreRequest.setBagDataChangedDelete(bagChangedDelegateFunc1)
end

--  汉字的utf8 转换，
function getStringLength( str)
    local strLen = 0
    local i =1
    while i<= #str do
        if(string.byte(str,i) > 127) then
            -- 汉字
            strLen = strLen + 2
            i= i+ 3
        else
            i =i+1
            strLen = strLen + 1
        end
    end
    return strLen
end

-------------------------------------------------[[和网络事件]]]--------------------------------------------------------------------

function createRandomName( ... )
	_curIndex = _curIndex + 1
	if(_curIndex <= 20 and not table.isEmpty(_userName) ) then
		_nameEditBox:setText("" .. _userName[_curIndex].name)
	else 
		getRandomName()
	end
end

function getRandomName( )	
	local args = CCArray:create()
	args:addObject(CCInteger:create(20))
	local utid= UserModel.getUserUtid()
	args:addObject(CCInteger:create(tonumber(utid) -1 ))
	require "script/network/Network"
	RequestCenter.user_getRandomName(randomNameAction, args)
end

-- 获取网络请求的网络回调函数
function randomNameAction(cbFlag, dictData, bRet )
	if(dictData.err ~= "ok")then
		return
	end
	_userName = dictData.ret
	if(table.isEmpty(_userName)) then
		AnimationTip.showTip(GetLocalizeStringBy("key_2684"))
		return
	end
	_curName = _userName[1].name
	_curIndex = 1
	print("_curName  is : ", _curName)
	_nameEditBox:setText("" .. _curName)	
end


function changeUserName( )
	_curName = _nameEditBox:getText()
	

	-- int $_changeType: 1.消耗金币 2.消耗物品
	local num= ItemUtil.getCacheItemNumBy( _changeNameInfo.item_tid )
    if(num == nil or num== 0) then
    	_changeType=1
    end

    if(_curName == UserModel.getUserName()) then
    	AnimationTip.showTip(GetLocalizeStringBy("key_2547"))
	 	return
    end

    if(_curName== "") then
		AnimationTip.showTip(GetLocalizeStringBy("key_1706") )
		return
	--added by Zhang Zihang
	elseif(Platform.getPlatformFlag() == "ios_thailand" or Platform.getPlatformFlag() == "Android_taiguo" )then
	 	if  (getStringLength(_curName)>24) then
	 		AnimationTip.showTip(GetLocalizeStringBy("key_2250"))
	 		return
	 	end
	else
		if (getStringLength(_curName)>10) then
			AnimationTip.showTip(GetLocalizeStringBy("key_2250"))
	 		return
		end
	end

    if(_changeType==1 and UserModel.getGoldNumber() < _changeNameInfo.goldNum ) then
    	AnimationTip.showTip(GetLocalizeStringBy("key_2716"))
		return 
    end

    local args = CCArray:create()
	args:addObject(CCString:create("" .. _curName))
  	args:addObject(CCInteger:create(_changeType) )


	Network.rpc(changeNameAction, "user.changeName" , "user.changeName", args , true)
end

function changeNameAction(cbFlag, dictData, bRet )
	if(dictData.err ~= "ok")then
		return
	end

	if(dictData.ret == "ok") then
		_curName = _nameEditBox:getText()
		UserModel.setUserName(_curName)
		if(_changeType ==1) then 
			UserModel.addGoldNumber( -_changeNameInfo.goldNum )
		end
		MainScene.updateAvatarInfo()
		-- AvatarInfoLayer.refreshUI()
		if(_nameChangeDelegate ~= nil) then
        	_nameChangeDelegate()
    	end
		AnimationTip.showTip(GetLocalizeStringBy("key_2316"))
		closeCb()
		require "script/ui/bag/BagLayer"
		print(" _limitType is : ", _limitType)
		if( _limitType ==1) then
			-- print("=========================== ")
			PreRequest.setBagDataChangedDelete(BagLayer.refreshDataByType)
			-- print("=========================== refreshDataByType refreshDataByType")
		end
		return
	elseif(dictData.ret == "invalid_char") then
		AnimationTip.showTip(GetLocalizeStringBy("key_2458"))
		return
	elseif(dictData.ret == "sensitive_word") then
		AnimationTip.showTip(GetLocalizeStringBy("key_2458"))
		return 
	elseif(dictData.ret == "duplication") then
		AnimationTip.showTip(GetLocalizeStringBy("key_2547"))
		return
	end

end



