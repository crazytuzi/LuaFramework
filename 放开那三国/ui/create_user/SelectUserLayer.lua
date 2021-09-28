-- Filename： SelectUserLayer.lua
-- Author：		zhz
-- Date：		2013-9-2
-- Purpose：		创建角色和名字

module("SelectUserLayer",  package.seeall)

require "script/network/RequestCenter"
require "script/ui/tip/AnimationTip"
-- require "script/ui/create_user/UserCache"

local IMG_PATH = "images/new_user/"
local _selectLayer				-- 创建用户的界面
local _selectBg 				-- 背景
local _utid						--  用户模版id 1:女 2:男 
local _selectSprite				-- 选中的sprite
local _nameEditBox				-- 名字的editBox
local _curName					-- 当前用户的选中的名字
local _curIndex					-- 当前第n个名字
local _UserName					-- 用户的姓名
local _createUserBtn
local function init()
	_selectLayer = nil
	_selectBg = nil
	_utid = 2
	_UserName = nil
	_selectSprite = nil
	_nameEditBox = nil
	_curIndex = 0
	_createUserBtn = nil

end
-- 通过 utid创建 userSprite
local function createUserSpriteByUtid()

	if(_utid ==1) then  -- 女主
		_selectSprite = CCSprite:create(IMG_PATH .. "girl.png")
		_selectSprite:setPosition(ccps(0.52, 331/960))
		_selectSprite:setAnchorPoint(ccp(0.5,0))
		setAdaptNode(_selectSprite)
		_selectLayer:addChild(_selectSprite)
	elseif(_utid ==2 ) then
		_selectSprite = CCSprite:create(IMG_PATH .. "boy.png")
		_selectSprite:setPosition(ccps(0.408, 331/960))
		_selectSprite:setAnchorPoint(ccp(0.5,0))
		setAdaptNode(_selectSprite)
		_selectLayer:addChild(_selectSprite)
	end

end

-- 返回按钮的回调函数
local function backBtnCb()
	require "script/ui/create_user/UserLayer"
	_selectLayer:removeFromParentAndCleanup(true)
	_selectLayer = nil
	local userLayer = UserLayer.createUserLayer()
	local scene = CCDirector:sharedDirector():getRunningScene()
	scene:addChild(userLayer)

end

-- 创建EditorBox
local function createNameBox( )
	_nameEditBox = CCEditBox:create(CCSizeMake(342,59), CCScale9Sprite:create(IMG_PATH .."input.png"))
	_nameEditBox:setPosition(ccps(0.5,158/960))
	_nameEditBox:setAnchorPoint(ccp(0.5,0))
	 _nameEditBox:setPlaceHolder(GetLocalizeStringBy("key_2136"))
	_nameEditBox:setMaxLength(10)
	_nameEditBox:setFont(g_sFontName,21)
	setAdaptNode(_nameEditBox)
	_selectLayer:addChild(_nameEditBox)

end

-- 获取网络请求的网络回调函数
local function randomNameAction(cbFlag, dictData, bRet )
	if(dictData.err ~= "ok")then
		return
	end
	_UserName = dictData.ret
	if(table.isEmpty(_UserName)) then
		AnimationTip.showTip(GetLocalizeStringBy("key_2684"))
		return
	end
	_curName = _UserName[1].name
	_curIndex = 1
	_nameEditBox:setText("" .. _curName)	
end

-- 获取随即名字的网络请求
local function getRandomName( )	
	local args = CCArray:create()
	args:addObject(CCInteger:create(20))
	args:addObject(CCInteger:create(tonumber(_utid) -1 ))
	require "script/network/Network"
	RequestCenter.user_getRandomName(randomNameAction, args)
end

-- 得到用户的性别：用户模版id 1:女 2:男 
function getUserSex( )
	return _utid
end

-- 创建角色按钮的网络回调函数
local function createuserAction(cbFlag, dictData, bRet )
	if(dictData.err ~= "ok")then
		return
	end
	require "script/ui/tip/AnimationTip"
	_createUserBtn:setEnabled(true)
	if(dictData.ret == "ok") then
		AnimationTip.showTip(GetLocalizeStringBy("key_1789"))
		Network.rpc(UserHandler.fnGetUsers, "user.getUsers", "user.getUsers", nil, true)
		return
	elseif(dictData.ret == "invalid_char") then
		AnimationTip.showTip(GetLocalizeStringBy("key_2458"))
		return
	elseif(dictData.ret == "sensitive_word") then
		AnimationTip.showTip(GetLocalizeStringBy("key_2458"))
		return 
	elseif(dictData.ret == "name_used") then
		AnimationTip.showTip(GetLocalizeStringBy("key_2547"))
		return
	end
end

--  汉字的utf8 转换，
local function getStringLength( str)
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

-- 创建角色按钮的回调函数
local function createUserCb( tag,item)
	_curName = _nameEditBox:getText()
	local args = CCArray:create()
	args:addObject(CCInteger:create(_utid))
	args:addObject(CCString:create("" .. _curName))
	if(_curName== "") then
		AnimationTip.showTip(GetLocalizeStringBy("key_1706") )
		return
	--added by Zhang Zihang
	elseif (Platform.getPlatformFlag() == "ios_thailand" or Platform.getPlatformFlag() == "Android_taiguo" ) then
	 	--要求是12个泰字，可是咱们这里判断太简陋了，所以白老师让扩大以规避
	 	if (getStringLength(_curName)>24) then
	 		AnimationTip.showTip(GetLocalizeStringBy("key_2250"))
	 		return
	 	end
	else
		if (getStringLength(_curName)>10) then
			AnimationTip.showTip(GetLocalizeStringBy("key_2250"))
	 		return
		end
	end
	LoginScene.setReconnStatus(false)
	item:setEnabled(false)
	RequestCenter.user_createUser(createuserAction,args)
end 

-- 置筛子的回调函数
local function sieveBtnCb( )
	if(table.isEmpty(_UserName)) then
		AnimationTip.showTip(GetLocalizeStringBy("key_2684"))
		return
	end

	_curIndex = _curIndex + 1
	if(_curIndex <= 20 ) then
		_nameEditBox:setText("" .. _UserName[_curIndex].name)
	else 
		getRandomName()
	end
end

function createSelectLayer( utid )
	init()
	_utid = utid
	_selectLayer = CCLayer:create()
	local scene = CCDirector:sharedDirector():getRunningScene()
	scene:addChild(_selectLayer,101)
	-- 背景
	_selectBg = CCSprite:create(IMG_PATH .. "user_bg.jpg")
	_selectBg:setPosition(ccps(0.5,0.5))
	_selectBg:setAnchorPoint(ccp(0.5,0.5))
	_selectLayer:addChild(_selectBg)
	setAllScreenNode(_selectBg)

	-- vip 继承提示
	local hasVip, vipLv = UserHandler.hasVip()
	if( hasVip==true and vipLv>0)then
		require "script/model/utils/UserUtil"
		local vipTipSprite = UserUtil.getVipTipSpriteByVipNum( vipLv )
	    vipTipSprite:setAnchorPoint(ccp(0.5, 0.5))
	    vipTipSprite:setPosition(_selectLayer:getContentSize().width*0.5, _selectLayer:getContentSize().height*0.85)
	    _selectLayer:addChild(vipTipSprite,200)
	    vipTipSprite:setScale(g_fElementScaleRatio)
	end

	-- 站台
	local userStage = CCSprite:create(IMG_PATH .. "stage.png")
	userStage:setPosition(ccps(0.5,240/960))
	userStage:setAnchorPoint(ccp(0.5,0))
	setAdaptNode(userStage)
	_selectLayer:addChild(userStage)

	createUserSpriteByUtid()

	-- 返回按钮
	local menu = CCMenu:create()
	menu:setPosition(ccp(0,0))
	_selectLayer:addChild(menu)
	local backBtn = CCMenuItemImage:create("images/common/close_btn_n.png", "images/common/close_btn_h.png")
	backBtn:setPosition(ccps(533/640,830/960))
	setAdaptNode(backBtn)
	backBtn:registerScriptTapHandler(backBtnCb)
	menu:addChild(backBtn)

	-- 创建角色按钮
	_createUserBtn = CCMenuItemImage:create(IMG_PATH .. "create/create_usr_n.png", IMG_PATH .. "create/create_usr_h.png")
	_createUserBtn:setPosition(ccps(0.5,42/960))
	_createUserBtn:setAnchorPoint(ccp(0.5,0))
	setAdaptNode(_createUserBtn)
	_createUserBtn:registerScriptTapHandler(createUserCb)
	menu:addChild(_createUserBtn)

	local sieveBtn = CCMenuItemImage:create(IMG_PATH .. "sieve/sieve_h.png", IMG_PATH .. "sieve/sieve_n.png")
	sieveBtn:setPosition(ccps(495/640, 158/960 ))
	sieveBtn:registerScriptTapHandler(sieveBtnCb)
	setAdaptNode(sieveBtn)
	menu:addChild(sieveBtn)

	-- 获得随即名字
	getRandomName()
	createNameBox()




	return _selectLayer
end
