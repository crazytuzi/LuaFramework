-- Filename: GuildCopyLayer.lua
-- Author: zhz
-- Date: 2013-2-17
-- Purpose: 该文件用于: 军团组队

module ("GuildCopyLayer", package.seeall)

require "script/ui/main/MainScene"
require "script/audio/AudioUtil"
require "script/ui/guild/GuildDataCache"
require "script/ui/item/ItemUtil"
require "script/ui/guild/GuildUtil"
require "script/ui/guild/copy/GuildTeamData"
require "script/ui/guild/copy/GuildCopyCell"
require "script/ui/teamGroup/TeamGroupLayer"
require "db/DB_Legion_copy"

local _bgLayer			= nil			-- 
local _bgLaystatus 		= false

local _topBgSprite		= nil			-- 头部的sprite
local _bottomSprite		= nil 			-- 底部的sprite
local _titleBg							-- 军团大厅的描述
local _myTableView						-- 副本的TableView
local _copyInfo			= nil			-- 副本的数据
local silverLabel		= nil
local _callbackFunc		= nil
local _leftNumLabel
local _helpNumLabel
local _checkBox         = nil

local function init()
	_bgLayer= nil
	_bgLaystatus= false
	_topBgSprite= nil
	_bottomSprite= nil
	_myTableView= nil
	_copyInfo= {}
	silverLabel= nil
	_callbackFunc= nil
	_helpNumLabel=nil
	_leftNumLabel= nil
	_checkBox = nil
end



-- 
function createTopUI( )
	_topBgSprite = CCSprite:create("images/hero/avatar_attr_bg.png")
    _topBgSprite:setAnchorPoint(ccp(0,1))
    _topBgSprite:setPosition(0,_layerSize.height)
    _topBgSprite:setScale(g_fScaleX)
    _bgLayer:addChild(_topBgSprite)
    -- _bgLayer:registerScriptHandler(onNodeEvent)

    --添加战斗力文字图片
    local arributeDescLabel = CCSprite:create("images/guild/guangong/alltribute.png")
    arributeDescLabel:setAnchorPoint(ccp(0.5,0.5))
    arributeDescLabel:setPosition(_topBgSprite:getContentSize().width*0.15,_topBgSprite:getContentSize().height*0.43)
    _topBgSprite:addChild(arributeDescLabel)

    --读取用户信息
    local userInfo = UserModel.getUserInfo()
    if userInfo == nil then
        return
    end
    
    --总贡献
    totalGongxian = GuildDataCache.getSigleDoante()
    powerLabel = CCRenderLabel:create(totalGongxian, g_sFontName, 23, 1.5, ccc3( 0x00, 0x00, 0x00), type_stroke)
    powerLabel:setColor(ccc3(0xff, 0xff, 0xff))
    --m_powerLabel:setAnchorPoint(ccp(0,0.5))
    powerLabel:setPosition(_topBgSprite:getContentSize().width*0.27,_topBgSprite:getContentSize().height*0.66)
    _topBgSprite:addChild(powerLabel, 1, 101)
    
    --银币
	silverLabel = CCLabelTTF:create(string.convertSilverUtilByInternational(userInfo.silver_num),g_sFontName,18)  -- modified by yangrui at 2015-12-03
    silverLabel:setColor(ccc3(0xe5,0xf9,0xff))
    silverLabel:setAnchorPoint(ccp(0,0.5))
    silverLabel:setPosition(_topBgSprite:getContentSize().width*0.61,_topBgSprite:getContentSize().height*0.43)
    _topBgSprite:addChild(silverLabel, 1, 102)
    
    --金币
    goldLabel = CCLabelTTF:create(tostring(userInfo.gold_num),g_sFontName,18)
    goldLabel:setColor(ccc3(0xff,0xe2,0x44))
    goldLabel:setAnchorPoint(ccp(0,0.5))
    goldLabel:setPosition(_topBgSprite:getContentSize().width*0.82,_topBgSprite:getContentSize().height*0.43)
    _topBgSprite:addChild(goldLabel, 2, 103)
end

-- 创建底部的UI
local function createBottomSprite( )
	require "script/ui/guild/GuildBottomSprite"
	_bottomSprite= GuildBottomSprite.createBottomSprite()
	_bottomSprite:setScale(g_fScaleX)
	_bottomSprite:setAnchorPoint(ccp(0.5,0))
	_bottomSprite:setPosition(ccp(g_winSize.width/2,0))
	_bgLayer:addChild(_bottomSprite, 12)
end

-- 创建军团的显示UI,显示军团的UI
function createDescUI( )
	_titleBg = CCSprite:create("images/formation/topbg.png")
	_titleBg:setAnchorPoint(ccp(0.5,1))
	_titleBg:setPosition(ccp( _layerSize.width/2, _layerSize.height - _topBgSprite:getContentSize().height*g_fScaleX))
	_bgLayer:addChild(_titleBg, 99)
	_titleBg:setScale(g_fScaleX)

	local teamTitle = CCSprite:create("images/guild/guild_copy.png")
	--teamTitle:setPosition(ccp(9,_titleBg:getContentSize().height/2 ))
	teamTitle:setPosition(9,93)
	teamTitle:setAnchorPoint(ccp(0,0.5))
	_titleBg:addChild(teamTitle)

	local curLevelLabel = CCRenderLabel:create("LV." .. GuildDataCache.getCopyHallLevel(), g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	curLevelLabel:setPosition(213,59)
	curLevelLabel:setColor(ccc3(0xff,0xea,0x00))
	curLevelLabel:setAnchorPoint(ccp(0,0))
	_titleBg:addChild(curLevelLabel)

	local donateLabel = CCRenderLabel:create(GetLocalizeStringBy("key_1185"), g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	donateLabel:setColor(ccc3(0xff,0xea,0x00))
	donateNumLabel= CCRenderLabel:create(GuildDataCache.getGuildDonate(), g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	donateNumLabel:setColor(ccc3(0xff,0xff,0xff))

	local label1 = BaseUI.createHorizontalNode({donateLabel, donateNumLabel})
    -- label1:setAnchorPoint(ccp(0, 1))
	label1:setPosition(310,94)
	_titleBg:addChild(label1)

	local nextNeed = CCRenderLabel:create(GetLocalizeStringBy("key_3041"), g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	nextNeed:setColor(ccc3(0xfe, 0xdb, 0x1c))
	local nextLv = GuildDataCache.getCopyHallLevel() +1
	local maxLevel= GuildUtil.getMaxHallCopyLevel()
	local needNumber =nil
	if(GuildDataCache.getCopyHallLevel()< tonumber(maxLevel)) then
		needNumber= CCRenderLabel:create(GuildUtil.getMilitaryNeedExpByLv(nextLv) , g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	else
		needNumber= CCRenderLabel:create("--" , g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	end
	needNumber:setColor(ccc3(0xff,0xff,0xff))

	local label1 = BaseUI.createHorizontalNode({nextNeed, needNumber})
	label1:setPosition(310,57)
	_titleBg:addChild(label1)

	local menu= CCMenu:create()
	menu:setPosition(ccp(0,0))
	_titleBg:addChild(menu)

	require "script/ui/guild/copy/CheckBox"
	_checkBox = CheckBox:create()
	_checkBox:setLabel(GetLocalizeStringBy("zz_135"), g_sFontPangWa, 30, ccc3(0xff,0xe4,0x00), type_stroke)
	_checkBox:registerScriptCheckHandler(checkCB)
	_checkBox:setScale(0.9)
	_checkBox:setAnchorPoint(ccp(0.5,0.5))
	_checkBox:setPosition(190,30)
	-- _checkBox:readChecked(kCheckBoxKey)
	menu:addChild(_checkBox)

	-- 返回按钮的回调函数
    local backBtn = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
    backBtn:setAnchorPoint(ccp(1,0.5))
    backBtn:setPosition(ccp(_titleBg:getContentSize().width-10,_titleBg:getContentSize().height*0.5+6))
    backBtn:registerScriptTapHandler(backBtnCB)
    menu:addChild(backBtn,1)

end


-- 创建军团副本的list
function createCopyList( )
	
	if (_myTableView ) then
		_myTableView:removeFromParentAndCleanup(true)
		_myTableView= nil
	end

	local xHeight = _layerSize.height - _bottomSprite:getContentSize().height*_bottomSprite:getScale()- _topBgSprite:getContentSize().height*_topBgSprite:getScale()- _titleBg:getContentSize().height*_titleBg:getScale()

	_copyInfo= GuildTeamData.getCopyTeamData()

	-- print("  copyList ")
	-- print_t(_copyInfo)
	local cellSize= CCSizeMake(640, 193)
	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = CCSizeMake( cellSize.width *g_fScaleX, cellSize.height*g_fScaleX)
		elseif fn == "cellAtIndex" then
			a2 = GuildCopyCell.createCell(_copyInfo[a1+1])
			a2:setScale(g_fScaleX)
			r = a2
		elseif fn == "numberOfCells" then
			r =  #_copyInfo
		elseif fn == "cellTouched" then
			local curCopyInfo = _copyInfo[a1:getIdx() + 1]
			if(curCopyInfo.isGray) then
				AnimationTip.showTip( GuildTeamData.getOpenStr(curCopyInfo) )
				return
			end

			if(ItemUtil.isBagFull() == true)then
				return
			end
			local teamLimit= GuildTeamData.getTeamLimitById(tonumber(curCopyInfo.id ) )
			TeamGroupLayer.showLayer(curCopyInfo.id,teamLimit)
		
		elseif (fn == "scroll") then
			
		end
			return r
	end)
	_myTableView = LuaTableView:createWithHandler(h, CCSizeMake(640*g_fScaleX, xHeight ))
	_myTableView:setBounceable(true)
	_myTableView:setAnchorPoint(ccp(0, 0))
	_myTableView:setPosition(ccp(0, _bottomSprite:getContentSize().height*_bottomSprite:getScale()- 3*g_fScaleX ))
	-- _myTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	_bgLayer:addChild(_myTableView)
end

-- 创建今日剩余的UI
function createLeftNum()
	local canDefeatNumBg = CCScale9Sprite:create("images/copy/ecopy/lefttimesbg.png")
	canDefeatNumBg:setAnchorPoint(ccp(0.5,0.4))
	canDefeatNumBg:setContentSize(CCSizeMake(300, 65) )
	canDefeatNumBg:setPosition(ccp(_bottomSprite:getContentSize().width*0.5, _bottomSprite:getContentSize().height))
	_bottomSprite:addChild(canDefeatNumBg, 10)

	local canDefeatSize = canDefeatNumBg:getContentSize()

	-- 今日剩余次数
	local pLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2242"), g_sFontName, 20, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    pLabel:setColor(ccc3(0xff, 0xff, 0xff))
    -- pLabel:setPosition(ccp(canDefeatSize.width*0.1, canDefeatSize.height*0.5+pLabel:getContentSize().height*0.5))
    -- canDefeatNumBg:addChild(pLabel)
    local number = 0
    if(GuildTeamData.getLeftGuildAtkNum()) then
    	number = GuildTeamData.getLeftGuildAtkNum()
    end
    local numberColor= ccc3(0x36, 0xff, 0x00)
    if(number <=0) then
    	numberColor= ccc3(0xf0,0x02,0x01)
    end

    local max_atk_num = DB_Legion_copy.getDataById(1).max_atk_num
    -- 次数
    _leftNumLabel = CCRenderLabel:create(number, g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _leftNumLabel:setColor(numberColor)
    local limitNumLevel= CCRenderLabel:create("/" .. max_atk_num , g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    limitNumLevel:setColor(ccc3(0x36,0xff,0x00))
    local tiemLabel = CCRenderLabel:create(GetLocalizeStringBy("key_3010"), g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    tiemLabel:setColor(ccc3(0xff, 0xff, 0xff))
    local leftNode= BaseUI.createHorizontalNode({pLabel,_leftNumLabel, limitNumLevel,tiemLabel})
    leftNode:setAnchorPoint(ccp(0,0))
    leftNode:setPosition(ccp(canDefeatSize.width*0.1, 35))
    canDefeatNumBg:addChild(leftNode)


    local guild_help_num= GuildTeamData.getLeftHelpGuildNum()
    local helpNumberColor= ccc3(0xff,0xf6,0x00)

    local helpLabel = CCRenderLabel:create(GetLocalizeStringBy("key_2507"), g_sFontName, 20, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    pLabel:setColor(ccc3(0xff, 0xff, 0xff))
    _helpNumLabel= CCRenderLabel:create("" .. guild_help_num, g_sFontName, 20, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _helpNumLabel:setColor(helpNumberColor)
    local help_02Label= CCRenderLabel:create(GetLocalizeStringBy("key_3010"), g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    tiemLabel:setColor(ccc3(0xff, 0xff, 0xff))

    local helpNode= BaseUI.createHorizontalNode({helpLabel,_helpNumLabel,help_02Label})
    helpNode:setAnchorPoint(ccp(0,0))
    helpNode:setPosition(ccp(canDefeatSize.width*0.2, 8))
    canDefeatNumBg:addChild(helpNode)

    local menuBar= CCMenu:create()
    menuBar:setPosition(ccp(0,0))
    canDefeatNumBg:addChild(menuBar)

    local addAtkBtn = CCMenuItemImage:create("images/common/btn/btn_plus_h.png", "images/common/btn/btn_plus_n.png")
    addAtkBtn:setPosition(ccp(292, canDefeatNumBg:getContentSize().height/2 ))
    addAtkBtn:setAnchorPoint(ccp(1,0.5))
    addAtkBtn:registerScriptTapHandler(addAtkAction)
    menuBar:addChild(addAtkBtn)

end


function refreshLeftNumUI( ... )

	local number = 0

	 print(" number is ", number)
	 
    if(GuildTeamData.getLeftGuildAtkNum()) then
    	number = GuildTeamData.getLeftGuildAtkNum()
    end
    local numberColor= ccc3(0x36, 0xff, 0x00)
    if(number <=0) then
    	numberColor= ccc3(0xf0,0x02,0x01)
    end

    print(" number is ", number)

    -- 次数
    _leftNumLabel:setString( "" .. number)--- = CCRenderLabel:create(number
    _leftNumLabel:setColor(numberColor)
	goldLabel:setString(tostring(UserModel.getGoldNumber() ))

	
end

-- 刷新TableView和挑战次数
function refreshUI(  )

	if(_bgLaystatus ) then
		silverLabel:setString(string.convertSilverUtilByInternational(UserModel.getSilverNumber()))  -- modified by yangrui at 2015-12-03
		local args = CCArray:create()
		-- 这里的1 是：副本组队类型暂时只有一种组队类型 1.公会副本组队
		args:addObject(CCInteger:create(1))
		Network.rpc(getCopyTeamCallback_02, "copyteam.getCopyTeamInfo", "copyteam.getCopyTeamInfo", args, true)
	end
end

-- 刷新TableView
function refreshTableView( )
	if(_bgLaystatus ) then
		local args = CCArray:create()
		-- 这里的1 是：副本组队类型暂时只有一种组队类型 1.公会副本组队
		args:addObject(CCInteger:create(1))
		args:addObject(CCInteger:create(1))
		Network.rpc(getHallInfoCB_03, "team.getHallInfo", "team.getHallInfo", args, true)	
	end
end

--@desc	 回调onEnter和onExit时间
local function onNodeEvent( event )
	if (event == "enter") then
		_bgLaystatus= true
		GuildDataCache.setIsInGuildFunc(true)

	elseif (event == "exit") then
		GuildDataCache.setIsInGuildFunc(false)
		_bgLaystatus= false
		--_checkBox:writeChecked(kCheckBoxKey)
	end
end


--createLayer
function createLayer( callbackFunc )

	init()


	_callbackFunc =callbackFunc
	MainScene.setMainSceneViewsVisible(false, false, true)
	_bgLayer= CCLayer:create()
	_bgLayer:registerScriptHandler(onNodeEvent)
	_bgLaystatus= true

	local bg = CCSprite:create("images/main/module_bg.png")
	bg:setScale(g_fBgScaleRatio)
	_bgLayer:addChild(bg)

	local bulletinLayerSize = BulletinLayer.getLayerContentSize()
	_layerSize= {width=0,height=0}
	_layerSize.width= g_winSize.width
	_layerSize.height= g_winSize.height - (bulletinLayerSize.height)*g_fScaleX
	_bgLayer:setContentSize(CCSizeMake(_layerSize.width, _layerSize.height))


	createTopUI()
	createBottomSprite()
	createDescUI()

	local args = CCArray:create()
	-- 这里的1 是：副本组队类型暂时只有一种组队类型 1.公会副本组队
	args:addObject(CCInteger:create(1))
	Network.rpc(getCopyTeamCallback, "copyteam.getCopyTeamInfo", "copyteam.getCopyTeamInfo", args, true)

	TeamGroupLayer.registerTeamCloseDelegate(refreshTableView)

	return _bgLayer
	
end


--------------------------------  menuAction and network callback ------------------------------------

-- 获得军团副本得网络回调函数
function getCopyTeamCallback( cbFlag, dictData, bRet )
	if (dictData.err ~= "ok") then
		return
	end

	if tonumber(dictData.ret.invite_status) == 1 then
		_checkBox:checked()
	else
		_checkBox:unchecked()
	end

	GuildTeamData.setCopyTeamInfo(dictData.ret)
	local args= CCArray:create()
	-- 这里的1 是：副本组队类型暂时只有一种组队类型 1.公会副本组队
	args:addObject(CCInteger:create(1))
	args:addObject(CCInteger:create(1))
	Network.rpc(getHallInfoCB, "team.getHallInfo", "team.getHallInfo", args, true)	
end

-- 获取大厅信息
function getHallInfoCB( cbFlag, dictData, bRet )
	if (dictData.err ~= "ok") then
		return
	end

	print_t(dictData.ret)
	GuildTeamData.sethallInfo(dictData.ret)
	
	createCopyList()
	createLeftNum()

	if(_callbackFunc ~= nil) then
		_callbackFunc()
	end
end


function backBtnCB( tag, item)
	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	require "script/ui/guild/GuildMainLayer"
	local guildMainLayer = GuildMainLayer.createLayer(false)
	MainScene.changeLayer(guildMainLayer, "guildMainLayer")
end

-- 获得军团副本得网络回调函数
function getCopyTeamCallback_02( cbFlag, dictData, bRet )
	if (dictData.err ~= "ok") then
		return
	end

	GuildTeamData.setCopyTeamInfo(dictData.ret)

	-- 这里的1 是：副本组队类型暂时只有一种组队类型 1.公会副本组队
	local args= CCArray:create()
	args:addObject(CCInteger:create(1))
	args:addObject(CCInteger:create(1))
	Network.rpc(getHallInfoCB_02 , "team.getHallInfo", "team.getHallInfo", args, true)	
end

function getHallInfoCB_02( cbFlag, dictData, bRet )
	if (dictData.err ~= "ok") then
		return
	end

	print(" getHallInfoCB_02")
	GuildTeamData.sethallInfo(dictData.ret)
	local offset  = _myTableView:getContentOffset()
	_copyInfo= GuildTeamData.getCopyTeamData()
	_myTableView:reloadData()
	_myTableView:setContentOffset(offset)
	local number = 0
    if(GuildTeamData.getLeftGuildAtkNum()) then
    	number = GuildTeamData.getLeftGuildAtkNum()
    end
    -- 次数
    _leftNumLabel:setString(tostring(number))

     local guild_help_num= GuildTeamData.getLeftHelpGuildNum()
     _helpNumLabel:setString( tostring(guild_help_num) )
end


function getHallInfoCB_03( cbFlag, dictData, bRet )
	if (dictData.err ~= "ok") then
		return
	end

	print(" getHallInfoCB_03")
	GuildTeamData.sethallInfo(dictData.ret)
	local offset  = _myTableView:getContentOffset()
	_copyInfo= GuildTeamData.getCopyTeamData()

	_myTableView:reloadData()
	_myTableView:setContentOffset(offset)

end


-- 增加攻打副本次数 按钮的回调事件

function addAtkAction( tag, item )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	if(tonumber(GuildTeamData.getLeftGuildAtkNum())> 0) then
		AnimationTip.showTip(GetLocalizeStringBy("key_1607"))
		return
	end
	
	require "script/ui/tip/BuyCopyAtkLayer"

	BuyCopyAtkLayer.showLayer( 4, GuildTeamData.getBuyAtkNum() ,refreshLeftNumUI )
end

function checkCB( pTag, pItem )
	--print("checkCB-------",_checkBox == pItem)
	local isChecked = pItem:isChecked()
	local callBack = function ( ... )
		if isChecked then
			pItem:unchecked()
		else
			pItem:checked()
		end
	end
	require "script/ui/teamGroup/TeamGruopService"
	print("checkCB", isChecked)
	local status = isChecked == true and 0 or 1
	TeamGruopService.setInviteStatus(status,callBack)
end

