-- Filename：	HorseInfoDialog.lua
-- Author：		LLP
-- Date：		2016-4-8
-- Purpose：		信息

module ("HorseInfoDialog", package.seeall)

require "script/network/RequestCenter"
require "script/model/DataCache"
require "script/ui/main/MainScene"
require "script/ui/common/LuaMenuItem"
require "script/ui/tip/AnimationTip"
require "script/model/user/UserModel"
require "script/utils/BaseUI"
require "db/DB_Normal_config"
require "script/ui/tip/SingleTip"
require "script/utils/LuaUtil"
require "db/DB_Vip"
require "script/libs/LuaCCSprite"
require "script/libs/LuaCCLabel"
require "db/DB_Mnlm_rule"
require "db/DB_Item_randgift"
----------------------------------
local dbInfo = DB_Mnlm_rule.getDataById(1)
local bgSprite = nil
local kRobTag 				= 101
local _bgLayer 				= nil		
local _occupyCountUpLabel 	= nil	
local _rewardTable 			= {}	
local _updateTimeScheduler	= nil
local _horseInfor 			= nil
local _horseItem 			= nil
local _costType 			= 1
local _leftRobTimeNumLabel  = nil
local _leftRobTimeLabel 	= nil
local _finishByGoldNum 		= 0
local _layer_touch_priority = -450
local _guard_time_label
------------------------------------------
local titleTable = {GetLocalizeStringBy("llp_370"),GetLocalizeStringBy("llp_371")}
local horseNameTable = {GetLocalizeStringBy("llp_361"),GetLocalizeStringBy("llp_362"),GetLocalizeStringBy("llp_363"),GetLocalizeStringBy("llp_364")}
-- 初始化
local function init( )
	_finishByGoldNum 		= 0
	_costType 				= 1
	bgSprite = nil
	_horseItem 				= nil
	_horseInfor 			= nil
	_bgLayer 				= nil		
	_occupyCountUpLabel 	= nil	
    _guard_time_label       = nil	
    _rewardTable 			= {}
    _leftRobTimeNumLabel  	= nil
    _leftRobTimeLabel 		= nil
end

-- create
function create()
	local bgLayerSize = _bgLayer:getContentSize()
end


--[[
 @desc	 处理touches事件
 @para 	 string event
 @return 
--]]
local function onTouchesHandler( eventType, x, y )
	
	if (eventType == "began") then
		return true
    elseif (eventType == "moved") then
	
    else
    	
	end
end


--[[
 @desc	 回调onEnter和onExit时间
 @para 	 string event
 @return void
 --]]
local function onNodeEvent( event )
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, -1001, true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		require "script/ui/horse/HorseRobRageDialog"
		HorseRobRageDialog.closeAction()
		_leftRobTimeNumLabel = nil
        stopTimeScheduler()
		_bgLayer:unregisterScriptTouchHandler()
	end
end

-- 关闭
function closeAction( tag, itembtn )
    if(_bgLayer~=nil)then
    	require "script/audio/AudioUtil"
    	AudioUtil.playEffect("audio/effect/guanbi.mp3")
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
end 

function stopTimeScheduler()
    if _updateTimeScheduler ~= nil then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(_updateTimeScheduler)
		_updateTimeScheduler = nil
	end
end

function starTimeScheduler()
    if _updateTimeScheduler == nil then
        _updateTimeScheduler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updateTime, 1, false)
    end
end

local function getTitleSpriteByText(text)
	local titleSp = CCSprite:create("images/hero/info/title_bg.png")
	titleSp:setAnchorPoint(ccp(0,0.5))
	local titleLabel = CCLabelTTF:create(text, g_sFontName, 21)
	titleLabel:setColor(ccc3(0x00, 0x00, 0x00))
	titleLabel:setAnchorPoint(ccp(0, 0.5))
	titleLabel:setPosition(ccp(titleSp:getContentSize().width * 0.1, titleSp:getContentSize().height * 0.5 + 2))
	titleSp:addChild(titleLabel)
	
	return titleSp
end

function updateTime()
    local dbInfo = DB_Mnlm_rule.getDataById(1)
	if(_horseInfor.begin_time + dbInfo.time<=BTUtil:getSvrTimeInterval() ) then
		_occupyCountUpLabel:setString("00:00:00")
		_bgLayer:removeFromParentAndCleanup(true)
	else
		local time_str = TimeUtil.getTimeString( (_horseInfor.begin_time + dbInfo.time - BTUtil:getSvrTimeInterval()))
		_occupyCountUpLabel:setString(time_str)
	end
end 

function afterLookCallBack( ... )
	-- body
	require "script/ui/horse/HorseTeamInfoDialog"
	HorseTeamInfoDialog.showInviteLayer(-2000,1000,tonumber(_horseInfor.uid))
end

function freshWatchSprite( pData )
	-- body
	bgSprite:removeChildByTag(111,true)
	pData.have_look_success =1
	pData.assistance_uid = 0
	_horseInfor.have_look_success = 1
	if(#pData==1)then
		pData.have_assistance = 0
	else
		pData.have_assistance = 1
	end
	local sprite = createWatchSprite(pData)
	bgSprite:addChild(sprite,1,111)
	sprite:setAnchorPoint(ccp(0.5, 0))
	sprite:setPosition(ccp(bgSprite:getContentSize().width * 0.5, 190))
end

function createTipDialog( ... )
	-- body
	-- 确定购买回调
	local yesBuyCallBack = function ( ... )
		if(tonumber(dbInfo.watch_cost)>UserModel.getGoldNumber())then
	        LackGoldTip.showTip(-5000)
	        return
	    end
		local nextFunction = function (pData)
			AnimationTip.showTip(GetLocalizeStringBy("llp_446"))
	    	freshWatchSprite(pData)
	    end
		-- 发请求
		HorseController.ChargeDartLook(nextFunction,tonumber(_horseInfor.uid),tonumber(dbInfo.watch_cost))
	end
	local tipNode = CCNode:create()
	tipNode:setContentSize(CCSizeMake(550,100))
	-- 第一行
    local textInfo1 = {
     		width = 550, -- 宽度
	        alignment = 2, -- 对齐方式  1 左对齐，2 居中， 3右对齐
	        labelDefaultFont = g_sFontName,      -- 默认字体
	        labelDefaultSize = 25,          -- 默认字体大小
	        elements =
	        {	
	            {
	            	type = "CCLabelTTF", 
	            	text = GetLocalizeStringBy("llp_445"),
	            	color = ccc3(0x78,0x25,0x00)
	        	},
	        	{
	            	type = "CCLabelTTF", 
	            	text = dbInfo.watch_cost,
	            	color = ccc3(0x78,0x25,0x00)
	        	},
	        	{
	        		type = "CCSprite",
                    image = "images/common/gold.png"
	        	},
	        	{	
	        		type = "CCLabelTTF", 
	        		text =  GetLocalizeStringBy("llp_436"),
	        		color = ccc3(0x78,0x25,0x00)
	        	}
	        }
	 	}
 	local font1 = LuaCCLabel.createRichLabel(textInfo1)
 	font1:setAnchorPoint(ccp(0.5, 0.5))
 	font1:setPosition(ccp(tipNode:getContentSize().width*0.5,tipNode:getContentSize().height*0.5))
 	tipNode:addChild(font1)
 	require "script/ui/tip/TipByNode"
	TipByNode.showLayer(tipNode,yesBuyCallBack,CCSizeMake(600,360),-2000)
end

function wathcAction( ... )
	-- bodywatch_cost
	local cost = tonumber(dbInfo.watch_cost)
	local userId = UserModel.getUserUid()
	if(userId~=tonumber(_horseInfor.uid) and userId~=tonumber(_horseInfor.assistance_uid) and tonumber(_horseInfor.have_look_success)~=1)then
		createTipDialog()
	elseif(tonumber(_horseInfor.have_look_success)==1)then
		HorseController.ChargeDartLook(afterLookCallBack,tonumber(_horseInfor.uid))
	else
		HorseController.ChargeDartLook(afterLookCallBack,tonumber(_horseInfor.uid))
	end
end

function createHelpSprite( pData )
	-- body
	local fullRect = CCRectMake(0,0,162,43)
	local insetRect = CCRectMake(70,20,22,3)
	local descSprite = CCScale9Sprite:create("images/common/bg/bg_9s_1.png", fullRect, insetRect)
	descSprite:setPreferredSize(CCSizeMake(420, 100))
	
	local menu = CCMenu:create()
		  menu:setTouchPriority(-1001 - 1)
		  menu:setPosition(ccp(0,0))
	descSprite:addChild(menu)
	local item = nil
	if(tonumber(pData.have_assistance)==0)then
		local label = CCLabelTTF:create(GetLocalizeStringBy("llp_435")..GetLocalizeStringBy("lic_1223"),g_sFontName,25)
			  label:setAnchorPoint(ccp(1,0.5))
			  label:setPosition(ccp(descSprite:getContentSize().width*0.5,descSprite:getContentSize().height*0.5))
		descSprite:addChild(label)
		item = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(119, 73), GetLocalizeStringBy("llp_368"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		item:setAnchorPoint(ccp(0,0.5))
		item:setPosition(ccp(descSprite:getContentSize().width*0.54,descSprite:getContentSize().height*0.5))
		item:registerScriptTapHandler(wathcAction)
		menu:addChild(item)
	else
		item = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(119, 73), GetLocalizeStringBy("llp_368"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		item:setAnchorPoint(ccp(0,0.5))
		item:setPosition(ccp(descSprite:getContentSize().width*0.65,descSprite:getContentSize().height*0.5))
		local label = CCLabelTTF:create(GetLocalizeStringBy("llp_435")..pData.assist_uname,g_sFontName,25)
			  label:setAnchorPoint(ccp(1,0.5))
			  label:setPosition(ccp(item:getPositionX()-20,descSprite:getContentSize().height*0.5))
		descSprite:addChild(label)
		item:registerScriptTapHandler(wathcAction)
		menu:addChild(item)
	end
	
	return descSprite
end

function freshRobNum( ... )
    -- body
    local horseInfo = HorseData.gethorseInfo()

    local str = horseInfo.rest_rob_num.."/"..dbInfo.free_loot
    if(_leftRobTimeNumLabel~=nil)then
    	_leftRobTimeNumLabel:setString(str)
    	_leftRobTimeNumLabel:setAnchorPoint(ccp(0,0))
	    _leftRobTimeNumLabel:setPosition(ccp(_leftRobTimeLabel:getPositionX()+_leftRobTimeLabel:getContentSize().width,_leftRobTimeLabel:getPositionY()))
    end
end

function createWatchSprite( pData )
	-- body
	local fullRect = CCRectMake(0,0,162,43)
	local insetRect = CCRectMake(70,20,22,3)
	local descSprite = CCScale9Sprite:create("images/common/bg/bg_9s_1.png", fullRect, insetRect)
	descSprite:setPreferredSize(CCSizeMake(420, 100))
	
	local menu = CCMenu:create()
		  menu:setPosition(ccp(0,0))
		  menu:setTouchPriority(-1001 - 1)
	descSprite:addChild(menu)
	local item = nil
	local uid = UserModel.getUserUid()
	if(uid==tonumber(pData.assistance_uid))then
		item = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(119, 73), GetLocalizeStringBy("key_1272"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		item:setAnchorPoint(ccp(0,0.5))
		item:setPosition(ccp(descSprite:getContentSize().width*0.5,descSprite:getContentSize().height*0.5))
		item:registerScriptTapHandler(wathcAction)
		local str = "1/1"
		local label = CCLabelTTF:create(GetLocalizeStringBy("llp_368")..str,g_sFontName,25)
			  label:setAnchorPoint(ccp(1,0.5))
			  label:setPosition(ccp(descSprite:getContentSize().width*0.5,descSprite:getContentSize().height*0.5))
		descSprite:addChild(label)
	else
		if(tonumber(pData.have_look_success)==0)then
			local force_occupy_btn_info = {
	        normal = "images/common/btn/btn_blue_n.png",
	        selected = "images/common/btn/btn_blue_h.png",
	        size = CCSizeMake(180, 73),
	        text_size = 30,
	        icon = "images/common/gold.png",
	        text = GetLocalizeStringBy("llp_379"),
	        number = tonumber(dbInfo.watch_cost)
		    }

		    item = LuaCCSprite.createNumberMenuItem(force_occupy_btn_info)
			item:setAnchorPoint(ccp(0,0.5))
			item:setPosition(ccp(descSprite:getContentSize().width*0.5,descSprite:getContentSize().height*0.5))
			item:registerScriptTapHandler(wathcAction)
			local label = CCLabelTTF:create(GetLocalizeStringBy("llp_435")..GetLocalizeStringBy("llp_437"),g_sFontName,25)
				  label:setAnchorPoint(ccp(1,0.5))
				  label:setPosition(ccp(descSprite:getContentSize().width*0.5,descSprite:getContentSize().height*0.5))
			descSprite:addChild(label)
		else
			item = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(119, 73), GetLocalizeStringBy("key_1272"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
			item:setAnchorPoint(ccp(0,0.5))
			item:setPosition(ccp(descSprite:getContentSize().width*0.5,descSprite:getContentSize().height*0.5))
			item:registerScriptTapHandler(wathcAction)
			local str = "0/1"
			if(tonumber(pData.have_assistance)==1)then
				str = "1/1"
			end
			local label = CCLabelTTF:create(GetLocalizeStringBy("llp_435")..str,g_sFontName,25)
				  label:setAnchorPoint(ccp(1,0.5))
				  label:setPosition(ccp(descSprite:getContentSize().width*0.5,descSprite:getContentSize().height*0.5))
			descSprite:addChild(label)
		end
	end
	menu:addChild(item)
	return descSprite
end

function afterQuick( pItem )
	-- body
	pItem:finishSelf()
end

function quickFinish( tag,item )
	-- body
	if(tonumber(_finishByGoldNum)>UserModel.getGoldNumber())then
        LackGoldTip.showTip(-5000)
        return
    end
	require "script/ui/horse/HorseController"
	closeAction()
	HorseController.finishByGold(_horseItem,afterQuick,_finishByGoldNum)
end

function rob( tag,item )
	local carInfo = HorseData.gethorseInfo()
	local beRobNum = tonumber(_horseInfor.be_robbed_num)
	local userId = UserModel.getUserUid()
	if(userId==tonumber(_horseInfor.assistance_uid))then
		AnimationTip.showTip(GetLocalizeStringBy("llp_441"))
		return
	end
	if(beRobNum>=2)then
		AnimationTip.showTip(GetLocalizeStringBy("llp_418"))
		return
	end
	local robNum = tonumber(carInfo.rest_rob_num)
	if(robNum==0)then
		AnimationTip.showTip(GetLocalizeStringBy("llp_419"))
		return
	end
	if(tonumber(_horseInfor.have_rob_success)==1)then
		AnimationTip.showTip(GetLocalizeStringBy("llp_426"))
		return
	end
	-- body
	require "script/ui/horse/HorseRobRageDialog"
	HorseRobRageDialog.show(_horseInfor,_rewardTable)
	-- closeAction()
end

function buyRobAction( ... )
	-- body
	require "script/ui/horse/BuyCarryTimeDialog"
	BuyCarryTimeDialog.showBatchBuyLayer(kRobTag)
end

--
local function createUI()
	local fullRect = CCRectMake(0,0,213,171)
	local insetRect = CCRectMake(50,50,113,71)
	bgSprite = CCScale9Sprite:create("images/formation/changeformation/bg.png", fullRect, insetRect)
    if true then
        bgSprite:setPreferredSize(CCSizeMake(515, 713))
    else
        bgSprite:setPreferredSize(CCSizeMake(515, 537))
    end

	bgSprite:setAnchorPoint(ccp(0.5, 0.5))
	bgSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5, _bgLayer:getContentSize().height*0.45))
	bgSprite:setScale(MainScene.elementScale)
	_bgLayer:addChild(bgSprite)

	local index = 1
	local isSelf = HorseData.isSelfInfo(tonumber(_horseInfor.uid))
	if(isSelf=="true")then
		index = 2
	end
	-- 标题
	local titleSp = CCSprite:create("images/formation/changeformation/titlebg.png")
	titleSp:setAnchorPoint(ccp(0.5,0.5))
	titleSp:setPosition(ccp(bgSprite:getContentSize().width/2, bgSprite:getContentSize().height*0.99))
	bgSprite:addChild(titleSp)
	local titleLabel = CCLabelTTF:create(titleTable[index], g_sFontPangWa, 33)
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	titleLabel:setAnchorPoint(ccp(0.5, 0.5))
	titleLabel:setPosition(ccp(titleSp:getContentSize().width/2, titleSp:getContentSize().height/2))
	titleSp:addChild(titleLabel)

    -- 关闭按钮bar
	local closeMenuBar = CCMenu:create()
	closeMenuBar:setPosition(ccp(0, 0))
	bgSprite:addChild(closeMenuBar)
	closeMenuBar:setTouchPriority(-1001 - 1)
	-- 关闭按钮
	local closeBtn = LuaMenuItem.createItemImage("images/common/btn_close_n.png", "images/common/btn_close_h.png", closeAction )
	closeBtn:setAnchorPoint(ccp(0.5, 0.5))
    closeBtn:setPosition(ccp(bgSprite:getContentSize().width*0.97, bgSprite:getContentSize().height*0.98))
	closeMenuBar:addChild(closeBtn)
	closeBtn:registerScriptTapHandler(closeAction)

---- 中间的UI
	-- 
	local fullRect_2 = CCRectMake(0, 0, 48, 48)
	local insetRect_2 = CCRectMake(20, 20, 10, 8)

    -- 当前位置
    local info_bar_y = bgSprite:getContentSize().height - 44
    -- 间距
    local info_bar_pitch = 7
    -- 单行的高度
    local info_bar_height_1 = 48
    local cell_x = 140
	-- 主人
	local productSprite = CCScale9Sprite:create("images/common/s9_1.png", fullRect_2, insetRect_2)
	productSprite:setPreferredSize(CCSizeMake(460, info_bar_height_1))
	productSprite:setAnchorPoint(ccp(0.5, 1))
	productSprite:setPosition(ccp( bgSprite:getContentSize().width * 0.5, info_bar_y))
	bgSprite:addChild(productSprite)
	-- 标题
	local productTitleSp = getTitleSpriteByText(GetLocalizeStringBy("llp_372"))
	productTitleSp:setAnchorPoint(ccp(0, 0.5))
	productTitleSp:setPosition(ccp(0, productSprite:getContentSize().height * 0.5))
	productSprite:addChild(productTitleSp)
	--主人名
	local nameLabel = CCLabelTTF:create(_horseInfor.uname,g_sFontName,25)
		  nameLabel:setAnchorPoint(ccp(0,0.5))
		  nameLabel:setPosition(ccp(cell_x,productSprite:getContentSize().height * 0.5))
		  nameLabel:setColor(ccc3(0x78, 0x25, 0x00))
	productSprite:addChild(nameLabel)

	local lvLabel = CCRenderLabel:create(GetLocalizeStringBy("djn_31").._horseInfor.level , g_sFontName, 25, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
		  lvLabel:setColor(ccc3(0xff,0xf6,0x00))
		  lvLabel:setAnchorPoint(ccp(1,0.5))
		  lvLabel:setPosition(ccp(productSprite:getContentSize().width-50,productSprite:getContentSize().height * 0.5))
	productSprite:addChild(lvLabel)
	-- 
    info_bar_y = info_bar_y - productSprite:getContentSize().height - info_bar_pitch
    
---- 木牛流马
	local rewardSprite = CCScale9Sprite:create("images/common/s9_1.png", fullRect_2, insetRect_2)
	rewardSprite:setPreferredSize(CCSizeMake(460, info_bar_height_1))
	rewardSprite:setAnchorPoint(ccp(0.5, 1))
	rewardSprite:setPosition(ccp( bgSprite:getContentSize().width * 0.5, info_bar_y))
	bgSprite:addChild(rewardSprite)
	-- 标题
	local rewardTitleSp = getTitleSpriteByText(GetLocalizeStringBy("llp_373"))
	rewardTitleSp:setPosition(ccp(0,rewardSprite:getContentSize().height * 0.5))
	rewardTitleSp:setAnchorPoint(ccp(0, 0.5))
	rewardSprite:addChild(rewardTitleSp)

	local qualityLable = CCLabelTTF:create(horseNameTable[tonumber(_horseInfor.stage_id)],g_sFontName,25)
		  qualityLable:setAnchorPoint(ccp(0,0.5))
		  qualityLable:setPosition(ccp(cell_x,rewardSprite:getContentSize().height * 0.5))
		  qualityLable:setColor(ccc3(0x78, 0x25, 0x00))
	rewardSprite:addChild(qualityLable)
	-- 
    info_bar_y = info_bar_y - rewardSprite:getContentSize().height - info_bar_pitch
    
---- 剩余时间
	local occupyTimeSprite = CCScale9Sprite:create("images/common/s9_1.png", fullRect_2, insetRect_2)
	occupyTimeSprite:setPreferredSize(CCSizeMake(460, info_bar_height_1))
	occupyTimeSprite:setAnchorPoint(ccp(0.5, 1))
	occupyTimeSprite:setPosition(ccp( bgSprite:getContentSize().width * 0.5, info_bar_y))
	bgSprite:addChild(occupyTimeSprite)
	-- 标题
	local occupyTitleSp = getTitleSpriteByText(GetLocalizeStringBy("llp_375"))
	occupyTitleSp:setPosition(ccp(0, occupyTimeSprite:getContentSize().height*0.5))
	occupyTitleSp:setAnchorPoint(ccp(0, 0.5))
	occupyTimeSprite:addChild(occupyTitleSp)
	-- 

	_occupyCountUpLabel = CCLabelTTF:create("", g_sFontName, 23)
	_occupyCountUpLabel:setColor(ccc3(0x00, 0x6d, 0x2f))
	_occupyCountUpLabel:setAnchorPoint(ccp(0, 0.5))
	_occupyCountUpLabel:setPosition(ccp(cell_x, occupyTimeSprite:getContentSize().height/2))
	occupyTimeSprite:addChild(_occupyCountUpLabel)
    
    info_bar_y = info_bar_y - occupyTimeSprite:getContentSize().height - info_bar_pitch

---- 被抢次数
	local occupyManSprite = CCScale9Sprite:create("images/common/s9_1.png", fullRect_2, insetRect_2)
	occupyManSprite:setPreferredSize(CCSizeMake(460, info_bar_height_1))
	occupyManSprite:setAnchorPoint(ccp(0.5, 1))
	occupyManSprite:setPosition(ccp( bgSprite:getContentSize().width * 0.5, info_bar_y))
	bgSprite:addChild(occupyManSprite)
	-- 标题
	local occupyManTitleSp = getTitleSpriteByText(GetLocalizeStringBy("llp_374"))
	occupyManTitleSp:setPosition(ccp(0, occupyManSprite:getContentSize().height*0.5))
	occupyManTitleSp:setAnchorPoint(ccp(0, 0.5))
	occupyManSprite:addChild(occupyManTitleSp)
	
    info_bar_y = info_bar_y - occupyManSprite:getContentSize().height - info_bar_pitch
    -- 被抢次数
    local robLimitNum = DB_Mnlm_rule.getDataById(1).plunder
    local robedTimeLable = CCLabelTTF:create(_horseInfor.be_robbed_num.."/"..robLimitNum,g_sFontName,25)
    	  robedTimeLable:setAnchorPoint(ccp(0,0.5))
    	  robedTimeLable:setColor(ccc3(0x00, 0x6d, 0x2f))
    	  robedTimeLable:setPosition(ccp(cell_x,occupyManSprite:getContentSize().height*0.5))
    occupyManSprite:addChild(robedTimeLable)

    if(isSelf=="false")then
	    local tipLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_433"),g_sFontName,20)
	    	  tipLabel:setAnchorPoint(ccp(1,0.5))
	    	  tipLabel:setColor(ccc3(0x5c, 0x61, 0x5e))
	    	  tipLabel:setPosition(ccp(occupyManSprite:getContentSize().width,occupyManSprite:getContentSize().height*0.5))
	    occupyManSprite:addChild(tipLabel)
	end
    -- 当前获得、拦截获得
    local help_sprite = CCScale9Sprite:create("images/common/s9_1.png", fullRect_2, insetRect_2)
	help_sprite:setPreferredSize(CCSizeMake(460, info_bar_height_1))
	help_sprite:setAnchorPoint(ccp(0.5, 1))
	help_sprite:setPosition(ccp( bgSprite:getContentSize().width * 0.5, info_bar_y))
	bgSprite:addChild(help_sprite)
	-- 标题
	help_sprite:setPreferredSize(CCSizeMake(460, 105))
	local str = GetLocalizeStringBy("llp_376")
	local userId = UserModel.getUserUid()
	
	if(isSelf=="false")then
		if(userId==tonumber(_horseInfor.assistance_uid))then
			str = GetLocalizeStringBy("llp_442")
		else
			str = GetLocalizeStringBy("llp_378")
		end
	end
    local guardTitleSp = getTitleSpriteByText(str)
    guardTitleSp:setAnchorPoint(ccp(0, 1))
    guardTitleSp:setPosition(ccp(0, help_sprite:getContentSize().height))
    help_sprite:addChild(guardTitleSp)

    local rewardInfo = DB_Mnlm_items.getDataById(_horseInfor.stage_id)
    local rewardData = rewardInfo.reward
	local levelRewardData = string.split(rewardData,";")
	local userLevel = UserModel.getAvatarLevel()
	local hostLevel = tonumber(_horseInfor.level)
	for k,v in pairs(levelRewardData) do
		local data = string.split(v,",")
		if(hostLevel>=tonumber(data[1]))then
			finalRewardData = data
		end
	end
	table.remove(finalRewardData,1)

	local specialreward = DB_Mnlm_items.getDataById(_horseInfor.stage_id).special_reward
	local specialrewardsplit = string.split(specialreward,";")
	local dataCache = {}
	for k,v in pairs(specialrewardsplit) do
		local data = string.split(v,",")
		if(userLevel>=tonumber(data[1]))then
			dataCache = data
		end
	end
	table.remove(dataCache,1)
	local dataCacheSplit = string.split(dataCache[1],"|")

	local finalExtraData = {}
	if(tonumber(_horseInfor.stage_id)>2)then
		local extraReward = DB_Mnlm_items.getDataById(_horseInfor.stage_id).once_special_reward
		local levelRewardDataExtra = string.split(extraReward,";")
		for k,v in pairs(levelRewardDataExtra) do
			local data = string.split(v,",")
			if(hostLevel>=tonumber(data[1]))then
				finalExtraData = data
			end
		end
	end
	table.remove(finalExtraData,1)
	table.insert(finalRewardData,finalExtraData[1])
	local extraData = string.split(finalExtraData[1],"|")
	local deltLevel = userLevel-hostLevel
	local index = 0
	local isdoubletime = HorseData.isDoubleTime(_horseInfor.begin_time)
	local stageNum = _horseInfor.stage_id
	local robData = DB_Mnlm_items.getDataById(stageNum)
	local helpPercent = tonumber(robData.assist)/10000
	local robPercent = tonumber(robData.rob)/10000
	_rewardTable = {}
	for k,v in pairs(finalRewardData) do
		index = index+1
		local data = ItemUtil.getItemsDataByStr(finalRewardData[index])
		local iconLabel = nil
		local numLabel = nil
		if(data[1].type == "silver")then
			iconLabel = CCLabelTTF:create(data[1].name,g_sFontName,22)
		elseif(data[1].type == "grain")then
			iconLabel = CCLabelTTF:create(data[1].name,g_sFontName,22)
		elseif(tonumber(extraData[2])~=tonumber(data[1].tid))then
			iconLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_434"),g_sFontName,22)
		else
			print("extraData[2]====",extraData[2])
			local dataExtra = DB_Item_randgift.getDataById(extraData[2]) --ItemUtil.getItemsDataByStr(extraData[2])
			iconLabel = CCLabelTTF:create(dataExtra.name,g_sFontName,22)
		end
		iconLabel:setAnchorPoint(ccp(0,1))
		iconLabel:setColor(ccc3(0x00, 0x6d, 0x2f))
		iconLabel:setPosition(ccp(cell_x,help_sprite:getContentSize().height-10-(index-1)*iconLabel:getContentSize().height))
		help_sprite:addChild(iconLabel)
		local num = 0
		if(tonumber(extraData[2])~=tonumber(data[1].tid))then
			if(isSelf=="false")then
				local userId = UserModel.getUserUid()
				if(userId==tonumber(_horseInfor.assistance_uid))then
					num = helpPercent*data[1].num
				else
					num = robPercent*data[1].num
				end
			else
				num = data[1].num - math.floor(tonumber(_horseInfor.be_robbed_num)*robPercent*data[1].num)
			end
			if(isdoubletime)then
				num = num*2
			end
			local rewardDbInfo = DB_Mnlm_rule.getDataById(1).level_protect
			local rewardDbInfoSplit = string.split(rewardDbInfo,",")
			local percent = 0
			for k,v in pairs(rewardDbInfoSplit) do
				local cacheData = string.split(v,"|")
				if(deltLevel>=tonumber(cacheData[1]))then
					percent = 1-(tonumber(cacheData[2])/10000)
				end
			end
			if(isSelf=="false" and deltLevel>0 and percent>0 and percent<1 )then
				num = math.floor(num*percent)
			else
				num = math.floor(num)
			end
		else
			if(isSelf=="false")then
				local userId = UserModel.getUserUid()
				if(userId==tonumber(_horseInfor.assistance_uid))then
					num = 0
				else
					num = data[1].num
				end
			else
				num = dataCacheSplit[3] - math.floor(tonumber(_horseInfor.be_robbed_num)*data[1].num)
			end
		end
		data[1].num = num
		table.insert(_rewardTable,data)
		numLabel = CCLabelTTF:create("*"..num,g_sFontName,22)
		numLabel:setColor(ccc3(0x00, 0x6d, 0x2f))
		numLabel:setAnchorPoint(ccp(0,0.5))
		numLabel:setPosition(ccp(cell_x+iconLabel:getContentSize().width,help_sprite:getContentSize().height-(index-1)*iconLabel:getContentSize().height-iconLabel:getContentSize().height))
		help_sprite:addChild(numLabel)
	end
    local sprite = nil
    if(isSelf=="true")then
    	sprite = createHelpSprite(_horseInfor)
    else
    	sprite = createWatchSprite(_horseInfor)
    end	
    sprite:setAnchorPoint(ccp(0.5, 0))
	sprite:setPosition(ccp(bgSprite:getContentSize().width * 0.5, 190))
	bgSprite:addChild(sprite,1,111)

	local bottomMenu = CCMenu:create()
		  bottomMenu:setPosition(ccp(0,0))
		  bottomMenu:setTouchPriority(-1001 - 1)
	bgSprite:addChild(bottomMenu)
	local bottomItem = nil
	local rewardStr = string.split(dbInfo.fast_cost,"|")
	local itemNum = ItemUtil.getCacheItemNumBy(rewardStr[1])
	local spriteStr = nil
	if(itemNum>0)then
		spriteStr = "images/base/props/jixingling28.png"
		itemNum = 1
		_costType = 1
	else
		spriteStr = "images/common/gold.png"
		itemNum = rewardStr[2]
		_finishByGoldNum = itemNum
		_costType = 2
	end
	if(isSelf=="true")then
		local force_occupy_btn_info = {
	        normal = "images/common/btn/btn_red_n.png",
	        selected = "images/common/btn/btn_red_h.png",
	        size = CCSizeMake(200, 73),
	        text_size = 30,
	        icon = spriteStr,
	        text = GetLocalizeStringBy("llp_381"),
	        number = itemNum
		    }
		bottomItem = LuaCCSprite.createNumberMenuItem(force_occupy_btn_info)
		bottomItem:registerScriptTapHandler(quickFinish)
	else
		bottomItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_red_n.png","images/common/btn/btn_red_h.png",CCSizeMake(150, 73), GetLocalizeStringBy("llp_380"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		bottomItem:registerScriptTapHandler(rob)
	end
	bottomItem:setAnchorPoint(ccp(0.5,0))
	bottomItem:setPosition(ccp(bgSprite:getContentSize().width*0.5,30))
	bottomMenu:addChild(bottomItem,1,_horseInfor.uid)

	local carInfo = HorseData.gethorseInfo()
	if(isSelf=="false")then	
		_leftRobTimeLabel = CCLabelTTF:create(GetLocalizeStringBy("llp_449"),g_sFontName,25)
		_leftRobTimeLabel:setColor(ccc3(0x00,0x6d,0x2f))
		_leftRobTimeLabel:setAnchorPoint(ccp(0,0))
		_leftRobTimeLabel:setPosition(ccp(bgSprite:getContentSize().width*0.3,bottomItem:getPositionY()+bottomItem:getContentSize().height*1.4))
		bgSprite:addChild(_leftRobTimeLabel)
		local leftNum = _horseInfor.rest_ship_num
	    _leftRobTimeNumLabel = CCLabelTTF:create(carInfo.rest_rob_num.."/"..dbInfo.free_loot,g_sFontName,25)
	    _leftRobTimeNumLabel:setColor(ccc3(0x78,0x25,0x00))
	    _leftRobTimeNumLabel:setAnchorPoint(ccp(0,0))
	    _leftRobTimeNumLabel:setPosition(ccp(_leftRobTimeLabel:getPositionX()+_leftRobTimeLabel:getContentSize().width,_leftRobTimeLabel:getPositionY()))
	    bgSprite:addChild(_leftRobTimeNumLabel)

	    local buyCarryNumItem = CCMenuItemImage:create("images/forge/add_h.png", "images/forge/add_n.png")
	    	  buyCarryNumItem:setAnchorPoint(ccp(0,0.5))
	    	  buyCarryNumItem:setPosition(ccp(_leftRobTimeNumLabel:getPositionX()+_leftRobTimeNumLabel:getContentSize().width,_leftRobTimeNumLabel:getPositionY()+_leftRobTimeNumLabel:getContentSize().height*0.5))
	   		  buyCarryNumItem:registerScriptTapHandler(buyRobAction)
	   	bottomMenu:addChild(buyCarryNumItem)
	end
	starTimeScheduler()
end

function show(pTag,pData,pItem)
    local layer = createLayer(pData,pItem)
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(layer,1000,pTag)
end

-- create
function createLayer(pData,pItem)
	init()
	require "db/DB_Mnlm_items"
	_horseItem = pItem
	_horseInfor = pData
	_bgLayer = CCLayer:create()
	_bgLayer:registerScriptHandler(onNodeEvent)

	createUI()

	return _bgLayer
end