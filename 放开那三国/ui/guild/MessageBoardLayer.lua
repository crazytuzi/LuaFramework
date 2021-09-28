-- FileName: MessageBoardLayer.lua 
-- Author: zhang zihang
-- Date: 14-5-13 
-- Purpose: 军团留言板 

module ("MessageBoardLayer", package.seeall)

require "script/ui/main/MainScene"
require "script/audio/AudioUtil"
require "script/libs/LuaCC"
require "script/ui/tip/AnimationTip"
require "script/model/user/UserModel"
require "script/utils/TimeUtil"
require "script/model/hero/HeroModel"
require "script/model/utils/HeroUtil"
require "script/ui/guild/GuildDataCache"
require "script/network/RequestCenter"

local _bgLayer
local _priority
local _zOrder
local _viewBg
local _remainTimes
local _chatViewBg
local _talkEditBox
local _mesData
local _mesTableView
local _cellSize
local _remainLeaveTime

local function init()
	_bgLayer 		= nil
	_priority 		= nil
	_zOrder 		= nil
	_viewBg 		= nil
	_remainTimes 	= nil
	_chatViewBg		= nil
	_talkEditBox	= nil
	_mesTableView 	= nil
	_cellSize		= nil
	_remainLeaveTime = 0
	_mesData 		= {}
end
local function onTouchesHandler(eventType, x, y)
	if (eventType == "began") then
	    return true
    elseif (eventType == "moved") then
    	print("move")
    else
    	print("end")
	end
end

local function onNodeEvent(event)
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler, false, _priority, true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		_bgLayer:unregisterScriptTouchHandler()
	end
end

local function closeCb()
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
end

local function getStringLength(str)
	local strLen = 0
    local i =1
    while i<= #str do
        if(string.byte(str,i) > 127) then
            -- 汉字
            strLen = strLen + 1
            i= i+ 3
        else
            i =i+1
            strLen = strLen + 1
        end
    end
    return strLen
end

local function sendClick()
	--后端回调
	local function senCallBack(cbFlag,dictData,bRet)
		print("留言回调")
		print_t(dictData)
		if not bRet then
        	return
    	end
    	if cbFlag == "guild.leaveMessage" then
			local subTable = {}
			--玩家模板id
			subTable.u_htid = UserModel.getAvatarHtid()
			--玩家姓名
			subTable.u_name = UserModel.getUserName()
			--玩家性别
			--1为男 2为女
			subTable.u_sex = UserModel.getUserSex()
			--玩家级别
			subTable.u_level = UserModel.getHeroLevel()
			--玩家时装
			--local dressInfo = HeroModel.getNecessaryHero().equip.dress
			subTable.u_dress = 0
			if UserModel.getDressIdByPos(1) ~= nil then
				subTable.u_dress = tonumber(UserModel.getDressIdByPos(1))
			end
			-- if (table.count(dressInfo) == 0 or tonumber(dressInfo["1"]) == 0) then
			-- 	subTable.u_dress = 0
			-- else
			-- 	subTable.u_dress = tonumber(dressInfo["1"].item_template_id)
			-- end
			--当前时间戳
			subTable.mes_time = TimeUtil.getSvrTimeByOffset()
			--留言内容
			subTable.mes_content = tostring(dictData.ret)
			--军团职务
			subTable.guild_duty = GuildDataCache.getMineSigleGuildInfo().member_type

			--留言次数减1
			_remainLeaveTime = _remainLeaveTime - 1
			--刷新留言次数
			_remainTimes:setString(tostring(_remainLeaveTime))

			_talkEditBox:setText("")
			_talkEditBox:setPlaceHolder(GetLocalizeStringBy("zzh_1012"))

			table.insert(_mesData,1,subTable)
			_mesTableView:reloadData()
			local tableOffet = _mesTableView:getContentOffset()
			if tableOffet.y < 0 then
				_mesTableView:setContentOffset(ccp(tableOffet.x,0))
			end
		end
	end
	
	--判断条件
	if getStringLength(_talkEditBox:getText()) > 80 then
		AnimationTip.showTip(GetLocalizeStringBy("zzh_1011"))
	elseif getStringLength(_talkEditBox:getText()) == 0 then
		AnimationTip.showTip(GetLocalizeStringBy("zzh_1010"))
	elseif _remainLeaveTime <= 0 then
		AnimationTip.showTip(GetLocalizeStringBy("zzh_1009"))
	else
		require "script/network/RequestCenter"
		local args = CCArray:create()
		args:addObject(CCString:create(_talkEditBox:getText()))
		RequestCenter.guild_leaveMessage(senCallBack,args)
	end
end

local function createBG()
	_viewBg = CCScale9Sprite:create("images/common/viewbg1.png")
	_viewBg:setContentSize(CCSizeMake(620,700))
	_viewBg:setAnchorPoint(ccp(0.5,0.5))
	_viewBg:setScale(MainScene.elementScale)
	_viewBg:setPosition(ccp(_bgLayer:getContentSize().width*0.5, _bgLayer:getContentSize().height*0.5))
	_bgLayer:addChild(_viewBg)

	local titleBg= CCSprite:create("images/common/viewtitle1.png")
	titleBg:setPosition(ccp(_viewBg:getContentSize().width*0.5, _viewBg:getContentSize().height-6))
	titleBg:setAnchorPoint(ccp(0.5, 0.5))
	_viewBg:addChild(titleBg)

	local labelTitle = CCRenderLabel:create(GetLocalizeStringBy("zzh_1008"), g_sFontPangWa,33,2,ccc3(0x00,0x00,0x0),type_shadow)
	labelTitle:setColor(ccc3(0xff,0xe4,0x00))
    labelTitle:setAnchorPoint(ccp(0.5,0.5))
	labelTitle:setPosition(ccp(titleBg:getContentSize().width*0.5,titleBg:getContentSize().height*0.5))
	titleBg:addChild(labelTitle)

	--手动拼接，类似叠罗汉，凑活看吧
	local remainMes_one = CCRenderLabel:create(GetLocalizeStringBy("zzh_1007"),g_sFontPangWa,21,1,ccc3(0x00,0x00,0x0),type_shadow)
	remainMes_one:setColor(ccc3(0xff,0xff,0xff))
	remainMes_one:setAnchorPoint(ccp(0,1))
	remainMes_one:setPosition(ccp(40,_viewBg:getContentSize().height-50))
	_viewBg:addChild(remainMes_one)

	_remainTimes = CCRenderLabel:create(tostring(_remainLeaveTime),g_sFontPangWa,21,1,ccc3(0x00,0x00,0x0),type_shadow)
	_remainTimes:setColor(ccc3(0x00,0xff,0x18))
	_remainTimes:setAnchorPoint(ccp(0,0.5))
	_remainTimes:setPosition(ccp(remainMes_one:getContentSize().width,remainMes_one:getContentSize().height/2))
	remainMes_one:addChild(_remainTimes)

	local remainMes_two = CCRenderLabel:create(GetLocalizeStringBy("zzh_1006"),g_sFontPangWa,21,1,ccc3(0x00,0x00,0x0),type_shadow)
	remainMes_two:setColor(ccc3(0xff,0xff,0xff))
	remainMes_two:setAnchorPoint(ccp(0,0.5))
	remainMes_two:setPosition(ccp(_remainTimes:getContentSize().width,_remainTimes:getContentSize().height/2))
	_remainTimes:addChild(remainMes_two)

	--留言保存天数
	local retainDays_one = CCRenderLabel:create(GetLocalizeStringBy("zzh_1005"),g_sFontPangWa,21,1,ccc3(0x00,0x00,0x0),type_shadow)
	retainDays_one:setColor(ccc3(0xff,0xff,0xff))
	retainDays_one:setAnchorPoint(ccp(1,1))
	retainDays_one:setPosition(ccp(_viewBg:getContentSize().width-40,_viewBg:getContentSize().height-50))
	_viewBg:addChild(retainDays_one)

	local retainDays_two = CCRenderLabel:create(GetLocalizeStringBy("zzh_1004"),g_sFontPangWa,21,1,ccc3(0x00,0x00,0x0),type_shadow)
	retainDays_two:setColor(ccc3(0x00,0xff,0x18))
	retainDays_two:setAnchorPoint(ccp(1,1))
	retainDays_two:setPosition(ccp(0,retainDays_one:getContentSize().height))
	retainDays_one:addChild(retainDays_two)

	local retainDays_three = CCRenderLabel:create(GetLocalizeStringBy("zzh_1003"),g_sFontPangWa,21,1,ccc3(0x00,0x00,0x0),type_shadow)
	retainDays_three:setColor(ccc3(0xff,0xff,0xff))
	retainDays_three:setAnchorPoint(ccp(1,1))
	retainDays_three:setPosition(ccp(0,retainDays_two:getContentSize().height))
	retainDays_two:addChild(retainDays_three)

	--留言框
	_chatViewBg = CCScale9Sprite:create(CCRectMake(30, 30, 15, 15),"images/common/bg/bg_ng_attr.png")
    _chatViewBg:setContentSize(CCSizeMake(570,455))
    _chatViewBg:setAnchorPoint(ccp(0.5,1))
    _chatViewBg:setPosition(ccp(_viewBg:getContentSize().width/2,_viewBg:getContentSize().height-100))
    _viewBg:addChild(_chatViewBg)

    --发送信息框
    _talkEditBox = CCEditBox:create (CCSizeMake(450,60), CCScale9Sprite:create("images/chat/input_bg.png"))
	_talkEditBox:setPosition(ccp(_viewBg:getContentSize().width*0.05, _viewBg:getContentSize().height*0.1))
	_talkEditBox:setAnchorPoint(ccp(0, 0.5))
	_talkEditBox:setPlaceHolder(GetLocalizeStringBy("zzh_1002"))
	_talkEditBox:setPlaceholderFontColor(ccc3(0xc3, 0xc3, 0xc3))
	_talkEditBox:setMaxLength(120)
	_talkEditBox:setReturnType(kKeyboardReturnTypeDone)
	_talkEditBox:setInputFlag (kEditBoxInputFlagInitialCapsWord)
    _talkEditBox:setTouchPriority(_priority)
    _talkEditBox:setFont(g_sFontName,23)
    _viewBg:addChild(_talkEditBox)

    local menuBar = CCMenu:create()
	menuBar:setPosition(ccp(0,0))
	_viewBg:addChild(menuBar)
	menuBar:setTouchPriority(_priority)

    local sendButton = LuaCC.create9ScaleMenuItem("images/star/intimate/btn_blue_n.png","images/star/intimate/btn_blue_h.png",CCSizeMake(120,64),GetLocalizeStringBy("zzh_1001"),ccc3(255,222,0))
    sendButton:setAnchorPoint(ccp(0.5,0.5))
    sendButton:setPosition(ccp(_viewBg:getContentSize().width*0.87,_viewBg:getContentSize().height*0.1))
    sendButton:registerScriptTapHandler(sendClick)
    menuBar:addChild(sendButton)

	local closeBtn = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
    closeBtn:setPosition(ccp(_viewBg:getContentSize().width*1.03,_viewBg:getContentSize().height*1.03))
    closeBtn:setAnchorPoint(ccp(1,1))
    closeBtn:registerScriptTapHandler(closeCb)
    menuBar:addChild(closeBtn)

    local maxCharacter = CCLabelTTF:create(GetLocalizeStringBy("zzh_1000"),g_sFontName,21)
    maxCharacter:setColor(ccc3(0x00,0x00,0x00))
    maxCharacter:setAnchorPoint(ccp(0,0))
    maxCharacter:setPosition(ccp(_viewBg:getContentSize().width*0.05,110))
    _viewBg:addChild(maxCharacter)
end

local function createCell(curData)
	local tCell = CCTableViewCell:create()
	local cellBg = CCScale9Sprite:create("images/common/bg/bg_9s_4.png")
	cellBg:setContentSize(_cellSize)
	cellBg:setAnchorPoint(ccp(0,0))
	tCell:addChild(cellBg)

	print("u_htid",curData.u_htid)
	print("u_dress")
	print_t(curData.u_dress)

	--时装信息
	local heroImage
	if curData.u_dress == 0 then
		heroImage = HeroUtil.getHeroIconByHTID(curData.u_htid)
	else
		heroImage = HeroUtil.getHeroIconByHTID(curData.u_htid,curData.u_dress,curData.u_sex)
	end

	heroImage:setAnchorPoint(ccp(0.5,0.5))
	heroImage:setPosition(ccp(75, 120))
	cellBg:addChild(heroImage)

	local nameBg = CCScale9Sprite:create("images/guild/guildmessage/name_bg.png")
	nameBg:setContentSize(CCSizeMake(200, 32))
	nameBg:setAnchorPoint(ccp(0,1))
	nameBg:setPosition(ccp(130,cellBg:getContentSize().height-30))
	cellBg:addChild(nameBg)

	local nameLabel = CCLabelTTF:create(curData.u_name, g_sFontName, 21) 
	--男
	if tonumber(curData.u_sex) == 1 then
		nameLabel:setColor(ccc3(0x00,0xe4,0xff))
	--女
	elseif tonumber(curData.u_sex) == 2 then
		nameLabel:setColor(ccc3(0xf9,0x59,0xff))
	end
	nameLabel:setAnchorPoint(ccp(0,0.5))
	nameLabel:setPosition(ccp(5,nameBg:getContentSize().height/2))
	nameBg:addChild(nameLabel)

	local levelLabel = CCLabelTTF:create(curData.u_level, g_sFontName, 21) 
	levelLabel:setPosition(nameBg:getContentSize().width-5, nameBg:getContentSize().height/2)
	levelLabel:setAnchorPoint(ccp(1, 0.5))
	levelLabel:setColor(ccc3(0xff, 0xf6, 0x00))
	nameBg:addChild(levelLabel)

	local levelSprite = CCSprite:create("images/common/lv.png")
	levelSprite:setAnchorPoint(ccp(1, 0.5))
	levelSprite:setPosition(ccp(0, levelLabel:getContentSize().height/2))
	levelLabel:addChild(levelSprite)

	local timeLabel = CCLabelTTF:create( TimeUtil.getTimeFormatYMDHMS(curData.mes_time), g_sFontName, 21)
	timeLabel:setPosition(ccp(cellBg:getContentSize().width - 30,cellBg:getContentSize().height - 30))
	timeLabel:setAnchorPoint(ccp(1,1))
	timeLabel:setColor(ccc3(0x78, 0x25, 0x00))
	cellBg:addChild(timeLabel)

	local messageInfoBg = CCScale9Sprite:create("images/common/bg/9s_5.png")
	messageInfoBg:setContentSize(CCSizeMake(410,100))
	messageInfoBg:setAnchorPoint(ccp(0,1))
	messageInfoBg:setPosition(ccp(135,cellBg:getContentSize().height-70))
	cellBg:addChild(messageInfoBg)

	local messageDelta = CCSprite:create("images/guild/guildmessage/say_delta.png")
	messageDelta:setAnchorPoint(ccp(1,0.5))
	messageDelta:setPosition(ccp(0,messageInfoBg:getContentSize().height/2+20))
	messageInfoBg:addChild(messageDelta)

	local messageInfo = CCLabelTTF:create(tostring(curData.mes_content), g_sFontName, 20, CCSizeMake(410, 120), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	messageInfo:setColor(ccc3(0xff,0xff,0xff))
	messageInfo:setAnchorPoint(ccp(0,1))
	messageInfo:setPosition(ccp(5,messageInfoBg:getContentSize().height-10))
	messageInfoBg:addChild(messageInfo)

	local dutySprite
	--会长
	if tonumber(curData.guild_duty) == 1 then
		dutySprite = CCSprite:create("images/guild/memberList/leader.png")
	--副会长
	elseif tonumber(curData.guild_duty) == 2 then
		dutySprite = CCSprite:create("images/guild/memberList/viceleader.png")
	--平民
	else
		dutySprite = CCRenderLabel:create(GetLocalizeStringBy("key_2169"), g_sFontPangWa, 25, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		dutySprite:setColor(ccc3(0xff,0xff,0xff))
	end

	dutySprite:setAnchorPoint(ccp(0.5,1))
	dutySprite:setPosition(ccp(heroImage:getContentSize().width/2,-5))
	heroImage:addChild(dutySprite)

	return tCell
end

local function createTableView()
	_cellSize = CCSizeMake(570, 190)

	local h = LuaEventHandler:create(function(fn, table, a1, a2)
		local r
		if fn == "cellSize" then
			r = _cellSize
		elseif fn == "cellAtIndex" then
	        a2 = createCell(_mesData[a1+1])
			r = a2
		elseif fn == "numberOfCells" then
			r = #_mesData
		elseif fn == "cellTouched" then
			print("cellTouched")
		elseif (fn == "scroll") then
			print("scroll")
		end
		return r
	end)

	_mesTableView = LuaTableView:createWithHandler(h, CCSizeMake(_chatViewBg:getContentSize().width,_chatViewBg:getContentSize().height))
    _mesTableView:setAnchorPoint(ccp(0,0))
    _mesTableView:setPosition(ccp(0,0))
	_mesTableView:setBounceable(true)
	_mesTableView:setTouchPriority(_priority)
	_chatViewBg:addChild(_mesTableView)

	local listOffset = _mesTableView:getContentOffset()
	if listOffset.y < 0 then
		_mesTableView:setContentOffset(ccp(listOffset.x,0))
	end
end

local function createUI()
	createBG()
	createTableView()
end

local function preDealData(cbFlag,dictData,bRet)
	print("拉取的留言信息")
	print_t(dictData)
	if not bRet then
        return
    end
    if cbFlag == "guild.getMessageList" then
		_mesData = {}
		--subTable 结构
		--[[
			u_htid 留言人模板id
			u_name 留言人姓名
			u_sex 留言人性别
			u_level 留言人级别
			u_dress 留言人时装信息
			mes_time 留言时间
			mes_content 留言内容
			guild_duty 军团职务
		--]]
		for k,v in pairs(dictData.ret.list) do
			local subTable = {}
			subTable.u_htid = v.htid
			subTable.u_name = v.uname
			subTable.u_sex = HeroModel.getSex(v.htid)
			subTable.u_level = v.level
			--时装判断
			if table.count(v.dress) == 0 then
				subTable.u_dress = 0
			else
				subTable.u_dress = tonumber(v.dress["1"])
			end
			print("时装信息",subTable.u_dress)
			subTable.mes_time = v.time
			subTable.mes_content = v.message
			subTable.guild_duty = v.type
			table.insert(_mesData,subTable)
		end
		
		_remainLeaveTime = tonumber(dictData.ret.num)

		createUI()
	end
end

function showLayer(touch_priority,z_order)
	init()
		
	_priority = touch_priority or - 550
	_zOrder = z_order or 999

	_bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bgLayer:registerScriptHandler(onNodeEvent)
	local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,_zOrder)

    local args = CCArray:create()
    args:addObject(CCInteger:create(0))
    args:addObject(CCInteger:create(100))
    RequestCenter.guild_getMessageList(preDealData,args)
    --preDealData()
end