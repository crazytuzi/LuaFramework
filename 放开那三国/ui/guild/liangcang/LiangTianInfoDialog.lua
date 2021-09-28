-- FileName: LiangTianInfoDialog.lua 
-- Author: licong 
-- Date: 14-12-1 
-- Purpose: 粮田详细信息


module("LiangTianInfoDialog", package.seeall)


require "script/utils/BaseUI"
require "script/ui/guild/GuildDataCache"
require "script/ui/guild/liangcang/BarnService"
require "script/ui/guild/liangcang/BarnData"
require "script/utils/LevelUpUtil"

local _bgLayer                  	= nil
local _backGround 					= nil
local _second_sp 					= nil
local _second_bg  					= nil
local _infoTableView 				= nil
local _liangtianSp 					= nil
local _expNode  					= nil
local _curGuildNumFont  			= nil
local _curMeritNumFont  			= nil
local _nextGuildNumFont 			= nil 
local _nextMeritNumFont 			= nil 
local _surplusCollectNumFont 		= nil

local _infoData 					= nil
local _liantianID 					= nil
local _maxCollectNum 				= nil
local _surplusCollectNum 			= nil

--[[
    @des    :init
    @param  :
    @return :
--]]
function init( ... )
	_bgLayer                    		= nil
	_backGround 						= nil
	_infoTableView 						= nil
	_second_sp 							= nil
	_second_bg  						= nil
	_liangtianSp 						= nil
	_expNode  							= nil
	_curGuildNumFont  					= nil
	_curMeritNumFont  					= nil
	_nextGuildNumFont 					= nil 
	_nextMeritNumFont 					= nil 
	_surplusCollectNumFont 				= nil

	_infoData 							= nil
	_liantianID 						= nil
	_maxCollectNum 						= nil
	_surplusCollectNum 					= nil
end

--[[
	@des 	:touch事件处理
	@param 	:
	@return :
--]]
local function layerTouch(eventType, x, y)
    return true
end

--[[
	@des 	:回调onEnter和onExit事件
	@param 	:
	@return :
--]]
function onNodeEvent( event )
	if (event == "enter") then
		_bgLayer:registerScriptTouchHandler(layerTouch,false,-670,true)
		_bgLayer:setTouchEnabled(true)
	elseif (event == "exit") then
		init()
	end
end

--[[
	@des 	:关闭按钮回调
	@param 	:
	@return :
--]]
function closeButtonCallback( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
	if(_bgLayer)then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
end

--[[
	@des 	:帮军团采集按钮按钮回调
	@param 	:
	@return :
--]]
function yesMenuItemCallback( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
	
	require "script/ui/guild/liangcang/LiangCangMainLayer"
	LiangCangMainLayer.liangTianCollectCallback(_liantianID,_liangtianSp)
end


----------------------------------------------------------- 创建UI ---------------------------------------------------------------

--[[
	@des 	: 刷新剩余次数
	@param 	:
	@return :
--]]
function refreshCollectNum( p_id )
	if( _bgLayer ~= nil )then 
		if(tonumber(p_id) == tonumber(_liantianID))then 
			if( tolua.cast(_surplusCollectNumFont,"CCRenderLabel") ~= nil )then 
				print("refreshCollectNum")
				-- 刷新剩余次数
				-- 剩余采集次数，当前等级，总经验
		    	_surplusCollectNum,_,_ = GuildDataCache.getSurplusCollectNumAndExpLv(_liantianID)
		    	_surplusCollectNumFont:setString( _surplusCollectNum .. "/" .. _maxCollectNum )
		    	print("11111111111111111111111")
		    end
	    end
	end
end

--[[
	@des 	: 刷新经验条
	@param 	: p_id 粮田id
	@return :
--]]
function refreshProress( p_id )
	if( _bgLayer ~= nil )then 
		if(tonumber(p_id) == tonumber(_liantianID))then 
			if(tolua.cast(_expNode,"CCNode") ~= nil)then
				print("refreshProress")
				-- 刷新经验条
				createProress()
			end
		end
	end
end

--[[
	@des 	: 粮田升级后刷新 升级特效 刷新产量
	@param 	:
	@return :
--]]
function refreshUiForUpgrade( p_id )
	if( _bgLayer ~= nil )then 
		if(tonumber(p_id) == tonumber(_liantianID))then
			if(_liangtianSp ~= nil)then
				print("refreshUiForUpgrade")
				local upAnimSprite = CCLayerSprite:layerSpriteWithNameAndCount("images/guild/liangcang/effect/maitianshengji", 1, CCString:create(""))
		        upAnimSprite:setAnchorPoint(ccp(0.5, 0.5))
		        upAnimSprite:setPosition(ccp(_liangtianSp:getContentSize().width*0.5,_liangtianSp:getContentSize().height*0.5))
		        _liangtianSp:addChild(upAnimSprite)

		        -- 剩余采集次数，当前等级，总经验
	    		local surplusCollectNum,curLv,curAllExp = GuildDataCache.getSurplusCollectNumAndExpLv(_liantianID)
		        -- 当前产量
		        local curMyNum,curGuildNum = BarnData.getLiangTianProduceGrainNum(_liantianID,curLv)
		        if(_curGuildNumFont ~= nil)then
					_curGuildNumFont:setString( "+" .. curGuildNum )
				end
				if(_curMeritNumFont ~= nil)then
					_curMeritNumFont:setString( "+" .. curMyNum )
				end

		        -- 下级产量
				local nextMyNum,nextGuildNum = BarnData.getLiangTianProduceGrainNum(_liantianID,curLv+1)
				local str1 = nil
				if(nextGuildNum == 0)then
					str1 = "--"
				else
					str1 = nextGuildNum
				end
				if(_nextGuildNumFont ~= nil)then
					_nextGuildNumFont:setString( "+" .. str1 )
				end

				local str2 = nil
				if(nextMyNum == 0)then
					str2 = "--"
				else
					str2 = nextMyNum
				end
				if(_nextMeritNumFont ~= nil)then
					_nextMeritNumFont:setString( "+" .. str2 )
				end
			end
		end
	end
end

--[[
	@des 	: 创建经验条
	@param 	:
	@return :
--]]
function createProress( ... )

	if(tolua.cast(_expNode,"CCNode") ~= nil)then
		_expNode:removeFromParentAndCleanup(true)
		_expNode = nil
	end

	-- 剩余采集次数，当前等级，总经验
    local surplusCollectNum,curLv,curAllExp = GuildDataCache.getSurplusCollectNumAndExpLv(_liantianID)
    -- 粮田升级经验id
    local curExpId = BarnData.getLiangTianExpId(_liantianID)
    -- 当前等级，结余经验，下级需要经验
   	local a,realExpNum,needExpNum = LevelUpUtil.getLvByExp(curExpId,curAllExp)
   	-- 描述node
    local nodeArr = {}
    -- 等级
    local lvSp = CCSprite:create("images/common/lv.png")
    table.insert(nodeArr,lvSp)
    local lvFont = CCRenderLabel:create(curLv .. " ", g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    lvFont:setColor(ccc3(0xff, 0xf6, 0x00))
    table.insert(nodeArr,lvFont)
    -- 经验条
    local rate = 0
    local expStr = nil
    if(needExpNum and needExpNum ~= 0)then
		rate = realExpNum/needExpNum
		if(rate > 1)then
			rate = 1
		end
		expStr = realExpNum .. "/" .. needExpNum
	else
		rate = 1
		expStr = "Max"
	end
    -- expbg
    local bgProress = CCScale9Sprite:create("images/common/exp_bg.png")
	bgProress:setContentSize(CCSizeMake(148, 23))
	table.insert(nodeArr,bgProress)
	-- 蓝条
	local progressSp = CCScale9Sprite:create("images/common/exp_progress.png")
	progressSp:setContentSize(CCSizeMake(bgProress:getContentSize().width*rate, 23))
	progressSp:setAnchorPoint(ccp(0, 0.5))
	progressSp:setPosition(ccp(0, bgProress:getContentSize().height * 0.5))
	bgProress:addChild(progressSp)
	-- 经验值
	local expLabel = CCRenderLabel:create(expStr, g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	expLabel:setColor(ccc3(0xff, 0xff, 0xff))
	expLabel:setAnchorPoint(ccp(0.5, 0.5))
	expLabel:setPosition(ccp(bgProress:getContentSize().width*0.5, bgProress:getContentSize().height*0.5))
	bgProress:addChild(expLabel)
	-- 提示
    _expNode = BaseUI.createHorizontalNode(nodeArr)
    _expNode:setAnchorPoint(ccp(0.5,1))
    _expNode:setPosition( _liangtianSp:getPositionX() , _liangtianSp:getPositionY()-_liangtianSp:getContentSize().height-5 )
    _second_sp:addChild(_expNode)
end


--[[
	@des 	: 创建抢粮敌人tableview
	@param 	:
	@return :
--]]
function createTopUi()
	if(_second_sp ~= nil)then
		_second_sp:removeFromParentAndCleanup(true)
		_second_sp = nil
	end
	-- 上边背景
	_second_sp = CCSprite:create()
	_second_sp:setContentSize(CCSizeMake(564,230))
	_second_sp:setAnchorPoint(ccp(0.5,1))
	_second_sp:setPosition(ccp(_backGround:getContentSize().width*0.5,_backGround:getContentSize().height-36))
	_backGround:addChild(_second_sp)

	-- 四个花
	-- 花纹 右边
 	local hua1 = CCSprite:create("images/hunt/hua.png")
 	hua1:setAnchorPoint(ccp(1,1))
 	hua1:setPosition(ccp(_second_sp:getContentSize().width,_second_sp:getContentSize().height))
 	_second_sp:addChild(hua1)
 	-- 左边
 	local hua2 = CCSprite:create("images/hunt/hua.png")
 	hua2:setAnchorPoint(ccp(1,1))
 	hua2:setPosition(ccp(0,_second_sp:getContentSize().height))
 	_second_sp:addChild(hua2)
 	hua2:setRotation(270)
 	-- 下左边
 	local hua3 = CCSprite:create("images/hunt/hua.png")
 	hua3:setAnchorPoint(ccp(1,1))
 	hua3:setPosition(ccp(0,0))
 	_second_sp:addChild(hua3)
 	hua3:setRotation(180)
 	-- 下右边
 	local hua4 = CCSprite:create("images/hunt/hua.png")
 	hua4:setAnchorPoint(ccp(1,1))
 	hua4:setPosition(ccp(_second_sp:getContentSize().width,0))
 	_second_sp:addChild(hua4)
 	hua4:setRotation(90)

	-- 粮田图片
	_liangtianSp = CCSprite:create("images/guild/liangcang/liangtian/1_n.png")
	_liangtianSp:setAnchorPoint(ccp(0.5, 1))
	_liangtianSp:setPosition(ccp(130, _second_sp:getContentSize().height-5))
	_second_sp:addChild(_liangtianSp,100)

	-- 粮田的序号
	local xuSp = CCSprite:create("images/guild/liangcang/xuhao.png")
	xuSp:setAnchorPoint(ccp(0,0.5))
	xuSp:setPosition(ccp(0,_liangtianSp:getContentSize().height*0.9))
	_liangtianSp:addChild(xuSp)
	local xuFont = CCRenderLabel:create(_liantianID,g_sFontPangWa, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    xuFont:setColor(ccc3(0xff, 0xf6, 0x00))
    xuFont:setAnchorPoint(ccp(0.5,0.5))
    xuFont:setPosition(xuSp:getContentSize().width*0.5,xuSp:getContentSize().height*0.5)
    xuSp:addChild(xuFont)

	-- 剩余采集次数，当前等级，总经验
    local surplusCollectNum,curLv,curAllExp = GuildDataCache.getSurplusCollectNumAndExpLv(_liantianID)
   
   	-- 经验条
   	createProress()

-- 当前产量
    local curProductionSp = CCSprite:create("images/guild/liangcang/cur_production.png")
    curProductionSp:setAnchorPoint(ccp(0,1))
    curProductionSp:setPosition(ccp(294,_second_sp:getContentSize().height-5))
    _second_sp:addChild(curProductionSp)
	-- 当前军团粮草
	local curBg1 = CCScale9Sprite:create("images/common/bg/bg_9s_1.png")
	curBg1:setContentSize(CCSizeMake(254, 33))
	curBg1:setAnchorPoint(ccp(0, 1))
	curBg1:setPosition(ccp(264, curProductionSp:getPositionY()-curProductionSp:getContentSize().height-5))
	_second_sp:addChild(curBg1)
	local curGuildFont = CCRenderLabel:create(GetLocalizeStringBy("lic_1373"), g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	curGuildFont:setColor(ccc3(0xff,0xff,0xff))
	curGuildFont:setAnchorPoint(ccp(0,0.5))
	curGuildFont:setPosition(ccp(22,curBg1:getContentSize().height*0.5))
	curBg1:addChild(curGuildFont)
	local curIcon1 = CCSprite:create("images/common/liangcao.png")
	curIcon1:setAnchorPoint(ccp(0,0.5))
	curIcon1:setPosition(ccp(curGuildFont:getPositionX()+curGuildFont:getContentSize().width,curGuildFont:getPositionY()))
	curBg1:addChild(curIcon1)
	-- 收益 个人功勋，军团粮草
	local curMyNum,curGuildNum = BarnData.getLiangTianProduceGrainNum(_liantianID,curLv)
	_curGuildNumFont =  CCRenderLabel:create( "+" .. curGuildNum, g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_curGuildNumFont:setColor(ccc3(0x00,0xe4,0xff))
	_curGuildNumFont:setAnchorPoint(ccp(0,0.5))
	_curGuildNumFont:setPosition(ccp(curIcon1:getPositionX()+curIcon1:getContentSize().width+10,curGuildFont:getPositionY()))
	curBg1:addChild(_curGuildNumFont)
	-- 当前个人功勋
	local curBg2 = CCScale9Sprite:create("images/common/bg/bg_9s_1.png")
	curBg2:setContentSize(CCSizeMake(254, 33))
	curBg2:setAnchorPoint(ccp(0, 1))
	curBg2:setPosition(ccp(264, curBg1:getPositionY()-curBg1:getContentSize().height-5))
	_second_sp:addChild(curBg2)
	local curMeritFont = CCRenderLabel:create(GetLocalizeStringBy("lic_1374"), g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	curMeritFont:setColor(ccc3(0xff,0xff,0xff))
	curMeritFont:setAnchorPoint(ccp(0,0.5))
	curMeritFont:setPosition(ccp(22,curBg2:getContentSize().height*0.5))
	curBg2:addChild(curMeritFont)
	local curIcon2 = CCSprite:create("images/common/gongxun.png")
	curIcon2:setAnchorPoint(ccp(0,0.5))
	curIcon2:setPosition(ccp(curMeritFont:getPositionX()+curMeritFont:getContentSize().width,curMeritFont:getPositionY()))
	curBg2:addChild(curIcon2)
	-- 个人功勋
	_curMeritNumFont = CCRenderLabel:create( "+" .. curMyNum, g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_curMeritNumFont:setColor(ccc3(0x00,0xe4,0xff))
	_curMeritNumFont:setAnchorPoint(ccp(0,0.5))
	_curMeritNumFont:setPosition(ccp(curIcon2:getPositionX()+curIcon2:getContentSize().width+10,curMeritFont:getPositionY()))
	curBg2:addChild(_curMeritNumFont)
-- 下一级产量
    local nextProductionSp = CCSprite:create("images/guild/liangcang/next_production.png")
    nextProductionSp:setAnchorPoint(ccp(0,1))
    nextProductionSp:setPosition(ccp(294, curBg2:getPositionY()-curBg2:getContentSize().height-10))
    _second_sp:addChild(nextProductionSp)
	-- 下一级军团粮草
	local nextBg1 = CCScale9Sprite:create("images/common/bg/bg_9s_1.png")
	nextBg1:setContentSize(CCSizeMake(254, 33))
	nextBg1:setAnchorPoint(ccp(0, 1))
	nextBg1:setPosition(ccp(264, nextProductionSp:getPositionY()-nextProductionSp:getContentSize().height-5))
	_second_sp:addChild(nextBg1)
	local nextGuildFont = CCRenderLabel:create(GetLocalizeStringBy("lic_1373"), g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	nextGuildFont:setColor(ccc3(0xff,0xff,0xff))
	nextGuildFont:setAnchorPoint(ccp(0,0.5))
	nextGuildFont:setPosition(ccp(22,nextBg1:getContentSize().height*0.5))
	nextBg1:addChild(nextGuildFont)
	local nextIcon1 = CCSprite:create("images/common/liangcao.png")
	nextIcon1:setAnchorPoint(ccp(0,0.5))
	nextIcon1:setPosition(ccp(nextGuildFont:getPositionX()+nextGuildFont:getContentSize().width,nextGuildFont:getPositionY()))
	nextBg1:addChild(nextIcon1)
	-- 收益 个人功勋，军团粮草
	local nextMyNum,nextGuildNum = BarnData.getLiangTianProduceGrainNum(_liantianID,curLv+1)
	-- 下一级军团粮草
	local str1 = nil
	if(nextGuildNum == 0)then
		str1 = "--"
	else
		str1 = nextGuildNum
	end
	_nextGuildNumFont =  CCRenderLabel:create( "+" .. str1, g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_nextGuildNumFont:setColor(ccc3(0x00,0xff,0x18))
	_nextGuildNumFont:setAnchorPoint(ccp(0,0.5))
	_nextGuildNumFont:setPosition(ccp(nextIcon1:getPositionX()+nextIcon1:getContentSize().width+10,nextGuildFont:getPositionY()))
	nextBg1:addChild(_nextGuildNumFont)
	-- 下一级个人功勋
	local nextBg2 = CCScale9Sprite:create("images/common/bg/bg_9s_1.png")
	nextBg2:setContentSize(CCSizeMake(254, 33))
	nextBg2:setAnchorPoint(ccp(0, 1))
	nextBg2:setPosition(ccp(264, nextBg1:getPositionY()-nextBg1:getContentSize().height-5))
	_second_sp:addChild(nextBg2)
	local nextMeritFont = CCRenderLabel:create(GetLocalizeStringBy("lic_1374"), g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	nextMeritFont:setColor(ccc3(0xff,0xff,0xff))
	nextMeritFont:setAnchorPoint(ccp(0,0.5))
	nextMeritFont:setPosition(ccp(22,nextBg2:getContentSize().height*0.5))
	nextBg2:addChild(nextMeritFont)
	local nextIcon2 = CCSprite:create("images/common/gongxun.png")
	nextIcon2:setAnchorPoint(ccp(0,0.5))
	nextIcon2:setPosition(ccp(nextMeritFont:getPositionX()+nextMeritFont:getContentSize().width,nextMeritFont:getPositionY()))
	nextBg2:addChild(nextIcon2)
	-- 下一级个人功勋
	local str2 = nil
	if(nextMyNum == 0)then
		str2 = "--"
	else
		str2 = nextMyNum
	end
	_nextMeritNumFont = CCRenderLabel:create( "+" .. str2, g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	_nextMeritNumFont:setColor(ccc3(0x00,0xff,0x18))
	_nextMeritNumFont:setAnchorPoint(ccp(0,0.5))
	_nextMeritNumFont:setPosition(ccp(nextIcon2:getPositionX()+nextIcon2:getContentSize().width+10,nextMeritFont:getPositionY()))
	nextBg2:addChild(_nextMeritNumFont)
end

--[[
	@des 	: 创建抢粮敌人tableview
	@param 	:
	@return :
--]]
function createInfoTableView()
	-- cell的size
	local cellSize = { width = 577, height = 162 } 

	require "script/ui/guild/liangcang/LiangTianInfoCell"
	local handler = LuaEventHandler:create(function(fn, table, a1, a2)
		local r
		if (fn == "cellSize") then
			-- 显示单元格的间距
			local interval = 0
			r = CCSizeMake(cellSize.width, (cellSize.height + interval))
		elseif (fn == "cellAtIndex") then
			r = LiangTianInfoCell.createCell(_infoData[a1+1])
		elseif (fn == "numberOfCells") then
			r = #_infoData
		else
		end
		return r
	end)
	
	_infoTableView = LuaTableView:createWithHandler(handler, CCSizeMake(600,450))
	_infoTableView:setBounceable(true)
	_infoTableView:ignoreAnchorPointForPosition(false)
	_infoTableView:setAnchorPoint(ccp(0.5, 0))
	_infoTableView:setPosition(ccp(_second_bg:getContentSize().width*0.5,5))
	_second_bg:addChild(_infoTableView)
	-- 设置单元格升序排列
	_infoTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	-- 设置滑动列表的优先级
	_infoTableView:setTouchPriority(-673)
end

--[[
	@des 	:创建界面
	@param 	:
	@return :
--]]
function createTipLayer( ... )

	_bgLayer = CCLayerColor:create(ccc4(11,11,11,200))
    _bgLayer:registerScriptHandler(onNodeEvent) 
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,1000,1)

	-- 创建背景
	_backGround = CCScale9Sprite:create(CCRectMake(100, 80, 10, 20),"images/common/viewbg1.png")
    _backGround:setContentSize(CCSizeMake(640,915))
    _backGround:setAnchorPoint(ccp(0.5,0.5))
    _backGround:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
    _bgLayer:addChild(_backGround)
    -- 适配
    setAdaptNode(_backGround)

	-- 关闭按钮
	local menu = CCMenu:create()
    menu:setTouchPriority(-675)
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0, 0))
	_backGround:addChild(menu,3)
	local closeButton = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeButton:setAnchorPoint(ccp(0.5, 0.5))
	closeButton:setPosition(ccp(_backGround:getContentSize().width * 0.955, _backGround:getContentSize().height*0.975 ))
	closeButton:registerScriptTapHandler(closeButtonCallback)
	menu:addChild(closeButton)

	-- 标题
    local titlePanel = CCScale9Sprite:create("images/common/viewtitle1.png")
    titlePanel:setContentSize(CCSizeMake(270,61))
	titlePanel:setAnchorPoint(ccp(0.5, 0.5))
	titlePanel:setPosition(ccp(_backGround:getContentSize().width/2, _backGround:getContentSize().height-6.6 ))
	_backGround:addChild(titlePanel)

	local titleLabel = CCLabelTTF:create( GetLocalizeStringBy("lic_1372"), g_sFontPangWa, 33)
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titlePanel:getContentSize().width*0.5, titlePanel:getContentSize().height*0.5))
	titlePanel:addChild(titleLabel)

 	-- 创建上半部分
 	createTopUi()

 	-- 粮草由军团长分配获得
 	local desFont = CCRenderLabel:create( GetLocalizeStringBy("lic_1376"), g_sFontPangWa, 23,1, ccc3( 0x00, 0x00, 0x00), type_stroke )
	desFont:setColor(ccc3(0xe4, 0x00, 0xff))
	desFont:setAnchorPoint(ccp(0.5,1))
	desFont:setPosition(ccp(_backGround:getContentSize().width*0.5, _second_sp:getPositionY()-_second_sp:getContentSize().height-5))
	_backGround:addChild(desFont)

	-- 二级背景
	_second_bg = BaseUI.createContentBg(CCSizeMake(600,488))
 	_second_bg:setAnchorPoint(ccp(0.5,1))
 	_second_bg:setPosition(ccp(_backGround:getContentSize().width*0.5, desFont:getPositionY()-desFont:getContentSize().height-8))
 	_backGround:addChild(_second_bg)

 	-- 采集信息
 	local caiFont = CCRenderLabel:create( GetLocalizeStringBy("lic_1378"), g_sFontPangWa, 21,1, ccc3( 0x00, 0x00, 0x00), type_stroke )
	caiFont:setColor(ccc3(0xff, 0xff, 0xff))
	caiFont:setAnchorPoint(ccp(0.5,1))
	caiFont:setPosition(ccp(_second_bg:getContentSize().width*0.5,_second_bg:getContentSize().height-5))
	_second_bg:addChild(caiFont,10)

 	-- 创建下半部分
	if( not table.isEmpty( _infoData ) )then 
	 	-- 创建奖励列表
	 	createInfoTableView()
	else
		local tipFont = CCLabelTTF:create( GetLocalizeStringBy("lic_1375"), g_sFontPangWa, 40)
		tipFont:setColor(ccc3(0xff, 0xe4, 0x00))
		tipFont:setAnchorPoint(ccp(0.5,0.5))
		tipFont:setPosition(ccp(_second_bg:getContentSize().width*0.5, _second_bg:getContentSize().height*0.5))
		_second_bg:addChild(tipFont)
	end

	-- 帮军团采集按钮
    local normalSprite  = CCScale9Sprite:create("images/common/btn/btn_green_n.png")
    normalSprite:setContentSize(CCSizeMake(251,71))
    local caiIcon1 = CCSprite:create("images/guild/liangcang/caiji_n.png")
	caiIcon1:setAnchorPoint(ccp(0.5,0.5))
	caiIcon1:setPosition(ccp(0,normalSprite:getContentSize().height*0.5))
	normalSprite:addChild(caiIcon1)
    local selectSprite  = CCScale9Sprite:create("images/common/btn/btn_green_h.png")
    selectSprite:setContentSize(CCSizeMake(251,71))
    local caiIcon2 = CCSprite:create("images/guild/liangcang/caiji_h.png")
	caiIcon2:setAnchorPoint(ccp(0.5,0.5))
	caiIcon2:setPosition(ccp(0,selectSprite:getContentSize().height*0.5))
	selectSprite:addChild(caiIcon2)
    local yesMenuItem = CCMenuItemSprite:create(normalSprite,selectSprite)
    yesMenuItem:setAnchorPoint(ccp(0.5,0))
    yesMenuItem:setPosition(ccp(_backGround:getContentSize().width*0.5, 50))
    yesMenuItem:registerScriptTapHandler(yesMenuItemCallback)
    menu:addChild(yesMenuItem)
    local  itemfont1 = CCRenderLabel:create( GetLocalizeStringBy("lic_1377"), g_sFontPangWa, 30, 1, ccc3(0x00,0x00,0x00), type_stroke)
    itemfont1:setAnchorPoint(ccp(0.5,0.5))
    itemfont1:setColor(ccc3(0xfe,0xdb,0x1c))
    itemfont1:setPosition(ccp(yesMenuItem:getContentSize().width*0.5,yesMenuItem:getContentSize().height*0.5))
    yesMenuItem:addChild(itemfont1)

    -- 采集次数
    local fontDes = CCRenderLabel:create(GetLocalizeStringBy("lic_1410"), g_sFontName, 22, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    fontDes:setColor(ccc3(0xff, 0xff, 0xff))
    fontDes:setAnchorPoint(ccp(0,0.5))
    yesMenuItem:addChild(fontDes)
    -- 剩余次数
    _surplusCollectNumFont = CCRenderLabel:create( _surplusCollectNum .. "/" .. _maxCollectNum, g_sFontName, 22, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    _surplusCollectNumFont:setColor(ccc3(0xff, 0xff, 0xff))
    _surplusCollectNumFont:setAnchorPoint(ccp(0,0.5))
    yesMenuItem:addChild(_surplusCollectNumFont)

    local posX = (yesMenuItem:getContentSize().width- fontDes:getContentSize().width - _surplusCollectNumFont:getContentSize().width)*0.5
    fontDes:setPosition(ccp(posX,-10))
    _surplusCollectNumFont:setPosition(ccp(fontDes:getPositionX()+fontDes:getContentSize().width,fontDes:getPositionY()))

end


--[[
	@des 	:显示粮田信息界面
	@param 	:p_id 粮田id
	@return :
--]]
function showLiangTianInfoLayer(p_id)
	-- 初始化
	init()
	
	-- 粮田id
	_liantianID = p_id

	-- 粮田累计最大采集次数
	_maxCollectNum = BarnData.getLiangTianCollectMaxNum()

	-- 剩余采集次数，当前等级，总经验
    _surplusCollectNum,_,_ = GuildDataCache.getSurplusCollectNumAndExpLv(_liantianID)

	-- 请求回调
	local nextFunction = function ( retData )
		-- 得到列表数据
		_infoData = retData

		-- 创建界面
		createTipLayer()
	end
	-- 发请求 策划需求显示最新的20条
	BarnService.getHarvestList(_liantianID,nextFunction)
end

















































