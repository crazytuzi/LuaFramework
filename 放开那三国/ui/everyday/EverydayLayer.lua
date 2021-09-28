-- FileName: EverydayLayer.lua 
-- Author: Li Cong 
-- Date: 14-3-18 
-- Purpose: function description of module 


module("EverydayLayer", package.seeall)

require "script/utils/BaseUI"
require "script/libs/LuaCC"
require "script/ui/everyday/EverydayData"
require "script/ui/everyday/EverydayService"

local _bgLayer                  = nil
local backGround 				= nil
local _addProgressBar 			= nil
local second_bg  				= nil
local menuBar 					= nil
local proress_bg1 				= nil
local _tableView 				= nil

local _isNeedUp 				= nil -- 是否需要升级
local _tasksTab 				= nil

function init( ... )
	_bgLayer                    = nil
	backGround 					= nil
	_addProgressBar 			= nil
	second_bg  					= nil
	menuBar 					= nil
	proress_bg1 				= nil

	_isNeedUp 					= nil
	_tableView 					= nil
	_tasksTab 					= nil
end

-- touch事件处理
local function cardLayerTouch(eventType, x, y)
   
    return true
    
end

--[[
	@des 	:确定升级奖励按钮回调  
	@param 	:
	@return :num
--]]
function yesBuyCallBack()
	local nextCallFun = function ( ... )
		-- 删除每日任务界面
		if( _bgLayer ~= nil)then
			_bgLayer:removeFromParentAndCleanup(true)
			_bgLayer = nil
		end
		-- 重新创建每日任务
		showEverydayLayer()
	end
	EverydayService.upgrade(nextCallFun)
end


--[[
	@des 	:升级奖励按钮回调  
	@param 	:
	@return :num
--]]
function upMenuItemCallFun(tag, sender )
	-- 有可以领取的箱子不让升级
	local isHave = false
	for i=1,3 do
		local status,_ = EverydayData.getBoxStateInfoById(i)
		if(status == 2)then
			isHave = true
		end
	end
	if(isHave)then
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(GetLocalizeStringBy("lic_1415"))
		return
    end

	-- 第一行
	local tipNode = CCNode:create()
	tipNode:setContentSize(CCSizeMake(550,100))
    local textInfo1 = {
     		width = 550, -- 宽度
	        alignment = 2, -- 对齐方式  1 左对齐，2 居中， 3右对齐
	        labelDefaultFont = g_sFontName,      -- 默认字体
	        labelDefaultSize = 25,          -- 默认字体大小
	        elements =
	        {	
	            {
	            	type = "CCLabelTTF", 
	            	text = GetLocalizeStringBy("lic_1413",_refreshOwnCost),
	            	color = ccc3(0x78,0x25,0x00)
	        	}
	        }
	 	}
 	local font1 = LuaCCLabel.createRichLabel(textInfo1)
 	font1:setAnchorPoint(ccp(0.5, 0.5))
 	font1:setPosition(ccp(tipNode:getContentSize().width*0.5,80))
 	tipNode:addChild(font1)

 	-- 第二行
    local textInfo2 = {
     		width = 550, -- 宽度
	        alignment = 2, -- 对齐方式  1 左对齐，2 居中， 3右对齐
	        labelDefaultFont = g_sFontName,      -- 默认字体
	        labelDefaultSize = 25,          -- 默认字体大小
	        linespace = 15, -- 行间距
	        elements =
	        {	
	            {
	            	type = "CCLabelTTF", 
	            	text = GetLocalizeStringBy("lic_1414"),
	            	color = ccc3(0x78,0x25,0x00)
	        	}
	        }
	 	}
 	local font2 = LuaCCLabel.createRichLabel(textInfo2)
 	font2:setAnchorPoint(ccp(0.5, 0.5))
 	font2:setPosition(ccp(tipNode:getContentSize().width*0.5,20))
 	tipNode:addChild(font2)
   
	require "script/ui/tip/TipByNode"
	TipByNode.showLayer(tipNode,yesBuyCallBack,CCSizeMake(600,360))
end

-- 关闭按钮回调
function closeButtonCallback( tag, sender )
    -- 音效
    require "script/audio/AudioUtil"
    AudioUtil.playEffect("audio/effect/guanbi.mp3")
	-- print("closeButtonCallback")
	if(_bgLayer)then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end

	require "script/ui/main/MainBaseLayer"
	local isShowTip = EverydayData.getIsShowTipSprite()
	local menuItem = MainBaseLayer.getEverydayBtn()
	print("menuItem==",menuItem)
	MainBaseLayer.showTipSprite(menuItem,isShowTip)
end

-- 创建layer
function initEverydayLayer( ... )
	init()

	-- 是否需要升级
	_isNeedUp = EverydayData.getEverydayIsNeedUpgrade()

	_bgLayer = CCLayerColor:create(ccc4(11,11,11,200))
    _bgLayer:setTouchEnabled(true)
    _bgLayer:registerScriptTouchHandler(cardLayerTouch,false,-420,true)
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(_bgLayer,1000,1)

	-- 创建背景
	backGround = CCScale9Sprite:create(CCRectMake(100, 80, 10, 20),"images/common/viewbg1.png")
    backGround:setAnchorPoint(ccp(0.5,0.5))
    backGround:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.5 - 24))
    _bgLayer:addChild(backGround)
    -- 适配
    setAdaptNode(backGround)

    if(_isNeedUp)then
    	backGround:setContentSize(CCSizeMake(630, 840))
    else
    	backGround:setContentSize(CCSizeMake(630, 770))
    end

    -- 标题
    local titlePanel = CCSprite:create("images/common/viewtitle1.png")
	titlePanel:setAnchorPoint(ccp(0.5, 0.5))
	titlePanel:setPosition(ccp(backGround:getContentSize().width/2, backGround:getContentSize().height-6.6 ))
	backGround:addChild(titlePanel)
	local titleLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2426"), g_sFontPangWa, 33)
	titleLabel:setColor(ccc3(0xff, 0xe4, 0x00))
	titleLabel:setAnchorPoint(ccp(0.5,0.5))
	titleLabel:setPosition(ccp(titlePanel:getContentSize().width*0.5, titlePanel:getContentSize().height*0.5))
	titlePanel:addChild(titleLabel)

	-- 关闭按钮
	local menu = CCMenu:create()
    menu:setTouchPriority(-420)
	menu:setPosition(ccp(0, 0))
	menu:setAnchorPoint(ccp(0, 0))
	backGround:addChild(menu,3)
	local closeButton = CCMenuItemImage:create("images/common/btn_close_n.png", "images/common/btn_close_h.png")
	closeButton:setAnchorPoint(ccp(0.5, 0.5))
	closeButton:setPosition(ccp(backGround:getContentSize().width * 0.955, backGround:getContentSize().height*0.975 ))
	closeButton:registerScriptTapHandler(closeButtonCallback)
	menu:addChild(closeButton)

	-- 花纹 右边
 	local hua1 = CCSprite:create("images/hunt/hua.png")
 	hua1:setAnchorPoint(ccp(1,1))
 	hua1:setPosition(ccp(backGround:getContentSize().width-33,backGround:getContentSize().height-55))
 	backGround:addChild(hua1)
 	-- 左边
 	local hua2 = CCSprite:create("images/hunt/hua.png")
 	hua2:setAnchorPoint(ccp(1,1))
 	hua2:setPosition(ccp(33,backGround:getContentSize().height-55))
 	backGround:addChild(hua2)
 	hua2:setRotation(270)
 	
	-- 当前积分
	local curScoreFont = CCSprite:create("images/everyday/cur_score_font.png")
	curScoreFont:setAnchorPoint(ccp(0,0.5))
	curScoreFont:setPosition(ccp(198,backGround:getContentSize().height-75))
	backGround:addChild(curScoreFont)
	local curScoreNum = EverydayData.getCurScore()
	local totalNum = EverydayData.getMaxScore()
	local curScoreNumFont = CCLabelTTF:create(curScoreNum .. "/",g_sFontPangWa,25)
	curScoreNumFont:setColor(ccc3(0x0e,0x79,0x00))
	curScoreNumFont:setAnchorPoint(ccp(0,0.5))
	curScoreNumFont:setPosition(ccp(curScoreFont:getPositionX()+curScoreFont:getContentSize().width+5,curScoreFont:getPositionY()))
	backGround:addChild(curScoreNumFont)
	local totalNumFont = CCLabelTTF:create(totalNum,g_sFontPangWa,25)
	totalNumFont:setColor(ccc3(0xa1,0x35,0x00))
	totalNumFont:setAnchorPoint(ccp(0,0.5))
	totalNumFont:setPosition(ccp(curScoreNumFont:getPositionX()+curScoreNumFont:getContentSize().width+2,curScoreFont:getPositionY()))
	backGround:addChild(totalNumFont)

	-- 进度条
	local rate = curScoreNum/totalNum
	if(rate > 1)then
		rate = 1
	end
	local proress_bg = CCSprite:create("images/everyday/progress3.png")
	proress_bg:setAnchorPoint(ccp(0.5,0))
	proress_bg:setPosition(ccp(backGround:getContentSize().width*0.5,curScoreFont:getPositionY()-curScoreFont:getContentSize().height*0.5-120 ))
	backGround:addChild(proress_bg)

	_addProgressBar = CCSprite:create("images/everyday/progress2.png")
    local _nEnergyProgressOriWidth = _addProgressBar:getContentSize().width
    local width = math.floor(rate*_nEnergyProgressOriWidth)
    if(width>_nEnergyProgressOriWidth ) then
        width = _nEnergyProgressOriWidth
    end
    _addProgressBar:setTextureRect(CCRectMake(0, 0, width, _addProgressBar:getContentSize().height))
    _addProgressBar:setAnchorPoint(ccp(0,0))
    _addProgressBar:setPosition(45, 12)
    proress_bg:addChild(_addProgressBar)

    if(width < _nEnergyProgressOriWidth ) then
	    local xing = CCSprite:create("images/everyday/xing.png")
	    xing:setAnchorPoint(ccp(0.5,0.5))
	    xing:setPosition(ccp(width,_addProgressBar:getContentSize().height*0.5))
	    _addProgressBar:addChild(xing)
	end

	proress_bg1 = CCSprite:create("images/everyday/progress1.png")
	proress_bg1:setAnchorPoint(ccp(0.5,0))
	proress_bg1:setPosition(ccp(proress_bg:getContentSize().width*0.5,4))
	proress_bg:addChild(proress_bg1,3)

	-- 二级背景
	second_bg = BaseUI.createContentBg(CCSizeMake(584,435))
 	second_bg:setAnchorPoint(ccp(0.5,1))
 	second_bg:setPosition(ccp(backGround:getContentSize().width*0.5,proress_bg:getPositionY()-15))
 	backGround:addChild(second_bg)

 	-- 两行字
 	local str1 = GetLocalizeStringBy("key_3235")
 	local str2 = GetLocalizeStringBy("key_1358")
 	local str1_font = CCLabelTTF:create(str1,g_sFontPangWa,21)
 	str1_font:setColor(ccc3(0x0e,0x79,0x00))
 	str1_font:setAnchorPoint(ccp(0.5,0))
 	str1_font:setPosition(ccp(backGround:getContentSize().width*0.5,75))
 	backGround:addChild(str1_font)
 	local str2_font = CCLabelTTF:create(str2,g_sFontPangWa,25)
 	str2_font:setColor(ccc3(0xa1,0x35,0x00))
 	str2_font:setAnchorPoint(ccp(0.5,0))
 	str2_font:setPosition(ccp(backGround:getContentSize().width*0.5,35))
 	backGround:addChild(str2_font)

 	-- 金银铜箱子
 	menuBar = CCMenu:create()
 	menuBar:setAnchorPoint(ccp(0,0))
 	menuBar:setPosition(ccp(0,0))
 	menuBar:setTouchPriority(-420)
 	proress_bg1:addChild(menuBar)
 	local posX = {0.2,0.5,0.8}
 	-- 铜 状态 需要分数
 	local tongStatus,tongNeedScore = EverydayData.getBoxStateInfoById(1)
 	local tongBoxBtn = createBoxBtn("tong",tongStatus,tongNeedScore)
 	tongBoxBtn:setAnchorPoint(ccp(0.5,0))
 	tongBoxBtn:setPosition(ccp(proress_bg1:getContentSize().width*posX[1],15))
 	menuBar:addChild(tongBoxBtn,1,1)
 	tongBoxBtn:registerScriptTapHandler(boxBtnCallFun)

 	-- 银 状态 需要分数
 	local yinStatus,yinNeedScore = EverydayData.getBoxStateInfoById(2)
 	local yinBoxBtn = createBoxBtn("yin",yinStatus,yinNeedScore)
 	yinBoxBtn:setAnchorPoint(ccp(0.5,0))
 	yinBoxBtn:setPosition(ccp(proress_bg1:getContentSize().width*posX[2],15))
 	menuBar:addChild(yinBoxBtn,1,2)
 	yinBoxBtn:registerScriptTapHandler(boxBtnCallFun)

 	-- 金 状态 需要分数
 	local jinStatus,jinNeedScore = EverydayData.getBoxStateInfoById(3)
 	local jinBoxBtn = createBoxBtn("jin",jinStatus,jinNeedScore)
 	jinBoxBtn:setAnchorPoint(ccp(0.5,0))
 	jinBoxBtn:setPosition(ccp(proress_bg1:getContentSize().width*posX[3],15))
 	menuBar:addChild(jinBoxBtn,1,3)
 	jinBoxBtn:registerScriptTapHandler(boxBtnCallFun)

 	-- 创建任务列表
 	createTasksTableView()

 	-- 奖励升级按钮
	if(_isNeedUp)then
		-- 是否可以升级
		local isCanUp = EverydayData.getEverydayIsCanUpgrade()
		if(isCanUp)then
			local normalSp = CCScale9Sprite:create("images/common/btn/btn_blue_n.png")
			normalSp:setContentSize(CCSizeMake(160,64))
			local selectSp = CCScale9Sprite:create("images/common/btn/btn_blue_h.png")
			selectSp:setContentSize(CCSizeMake(160,64))
		    local upMenuItem = CCMenuItemSprite:create(normalSp, selectSp)
			upMenuItem:setAnchorPoint(ccp(0.5,0.5))
			upMenuItem:setPosition(ccp(backGround:getContentSize().width*0.5,135))
			menu:addChild(upMenuItem)
			-- 注册挑战回调
			upMenuItem:registerScriptTapHandler(upMenuItemCallFun)
			-- 阵容字体
			local item_font = CCRenderLabel:create( GetLocalizeStringBy("lic_1411") , g_sFontPangWa, 28, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		    item_font:setColor(ccc3(0xfe, 0xdb, 0x1c))
		    item_font:setAnchorPoint(ccp(0.5,0.5))
		    item_font:setPosition(ccp(upMenuItem:getContentSize().width*0.5,upMenuItem:getContentSize().height*0.5))
		   	upMenuItem:addChild(item_font)
		else
			local needLv = EverydayData.getEverydayUpgradeNeedLv()
			local richInfo = {}
	        richInfo.defaultType = "CCLabelTTF"
	        richInfo.labelDefaultColor = ccc3(0xff, 0x00, 0xf0)
	       	richInfo.labelDefaultSize = 28
	       	richInfo.labelDefaultFont = g_sFontPangWa
	        richInfo.elements = {
	        	{
	        		text = needLv,
	        		color = ccc3(0x0e,0x79,0x00)
	        	}
	    	}
	    	local tipFont = GetLocalizeLabelSpriteBy_2("lic_1412", richInfo)
	    	tipFont:setAnchorPoint(ccp(0.5, 0.5))
	    	tipFont:setPosition(ccp(backGround:getContentSize().width*0.5,135))
	    	backGround:addChild(tipFont)
		end
	end

end

-- status 1 2 3 
function createBoxBtn( type_str, status, score )
	local menuItem = CCMenuItemImage:create("images/everyday/" .. type_str .. "_" .. status .. "_n.png", "images/everyday/" .. type_str .. "_" .. status .. "_h.png")

	if( tonumber(status) == 2)then
		if("tong" == type_str)then
			-- 铜宝箱
			local spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/copy/copperBox/tongxiangzi"), -1,CCString:create(""));
		    spellEffectSprite:retain()
		    spellEffectSprite:setPosition(menuItem:getContentSize().width*0.5,menuItem:getContentSize().height*0.5+5)
		    menuItem:addChild(spellEffectSprite)
		    spellEffectSprite:release()
		elseif("yin" == type_str)then
			-- 银宝箱
			local spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/copy/silverBox/yinxiangzi"), -1,CCString:create(""));
		    spellEffectSprite:retain()
		    spellEffectSprite:setPosition(menuItem:getContentSize().width*0.5,menuItem:getContentSize().height*0.5+5)
		    menuItem:addChild(spellEffectSprite)
		    spellEffectSprite:release()
		elseif("jin" == type_str)then
			-- 金宝箱
			local spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/copy/goldBox/jinxiangzi"), -1,CCString:create(""));
		    spellEffectSprite:retain()
		    spellEffectSprite:setPosition(menuItem:getContentSize().width*0.5+3,menuItem:getContentSize().height*0.5+5)
		    menuItem:addChild(spellEffectSprite)
		    spellEffectSprite:release()
		end
	end


	-- 积分数
	local sprite1 = LuaCC.createNumberSprite02("images/everyday",score)
    menuItem:addChild(sprite1)

	-- 积分sp
	local sprite2 = CCSprite:create("images/everyday/score_font.png")
	sprite2:setAnchorPoint(ccp(0,0))
	menuItem:addChild(sprite2)
	local posX = (menuItem:getContentSize().width-sprite1:getContentSize().width+sprite2:getContentSize().width)*0.5
	sprite1:setPosition(ccp(2,-14))
	sprite2:setPosition(ccp(sprite1:getPositionX()+sprite1:getContentSize().width,0))

	return menuItem
end

--[[
	@des 	:刷新任务列表
	@param 	:
	@return :
--]]
function refreshTasksTableView( ... )
	local offset = _tableView:getContentOffset()
	_tasksTab = EverydayData.getTaskInfo()
	_tableView:reloadData()
	_tableView:setContentOffset(offset)
end

-- 创建任务列表
function createTasksTableView( ... )
	_tasksTab = EverydayData.getTaskInfo()
	require "script/ui/everyday/EverydayCell"
	local cellSize = CCSizeMake(574, 210)
	local h = LuaEventHandler:create(function(fn, table, a1, a2) 	--创建
		local r
		if fn == "cellSize" then
			r = cellSize
		elseif fn == "cellAtIndex" then
			r = EverydayCell.createCell(_tasksTab[a1+1])
		elseif fn == "numberOfCells" then
			r =  #_tasksTab
		else
		end
		return r
	end)

	_tableView = LuaTableView:createWithHandler(h, CCSizeMake(574, 430))
	_tableView:setBounceable(true)
	_tableView:setTouchPriority(-423)
	_tableView:ignoreAnchorPointForPosition(false)
	_tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	_tableView:setAnchorPoint(ccp(0.5,0.5))
	_tableView:setPosition(ccp(second_bg:getContentSize().width*0.5,second_bg:getContentSize().height*0.5))
	second_bg:addChild(_tableView)
end

-- 箱子回调
function boxBtnCallFun( tag, itemBtn )
	require "script/ui/everyday/ShowBoxLayer"
	ShowBoxLayer.showBoxRewardLayer(tag,refreshBoxBtn)
end

-- 刷新箱子回调
function refreshBoxBtn( boxId )
	local menuItem = tolua.cast(menuBar:getChildByTag(tonumber(boxId)),"CCMenuItemImage")
	if(menuItem)then
		menuItem:removeFromParentAndCleanup(true)
	end

	local data,_= EverydayData.getBoxRewardDataByBoxId(boxId)

	local nameArr = {"tong","yin","jin"}
	local posX = {0.2,0.5,0.8}
	local boxBtn = createBoxBtn(nameArr[tonumber(boxId)],3,data.needScore)
 	boxBtn:setAnchorPoint(ccp(0.5,0))
 	boxBtn:setPosition(ccp(proress_bg1:getContentSize().width*posX[tonumber(boxId)],28))
 	menuBar:addChild(boxBtn,1,tonumber(boxId))
 	boxBtn:registerScriptTapHandler(boxBtnCallFun)
end

-- 显示layer
function showEverydayLayer( ... )
	EverydayService.getActiveInfo(initEverydayLayer)
end










































