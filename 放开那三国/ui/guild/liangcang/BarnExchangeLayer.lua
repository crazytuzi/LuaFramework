-- FileName: BarnExchangeLayer.lua 
-- Author: 	Zhang Zihang 
-- Date: 14-11-6
-- Purpose: 粮草兑换页面

module("BarnExchangeLayer", package.seeall)

require "script/utils/BaseUI"
require "script/libs/LuaCC"
require "script/ui/guild/liangcang/BarnService"
require "script/ui/guild/liangcang/BarnData"
require "script/ui/guild/GuildDataCache"
require "script/ui/item/ItemSprite"
require "script/ui/hero/HeroPublicLua"
require "script/ui/tip/AnimationTip"
require "script/ui/rechargeActive/ActiveUtil"
require "script/ui/item/ReceiveReward"

local _bgLayer
local _priority
local _zOrder 					
local _cornNumLabel 			--个人粮草数量label
local _exTableView
local _meritNumLabel
local _visibleNum

----------------------------------------初始化函数----------------------------------------
--[[
	@des 	:初始化函数
	@param 	:
	@return :
--]]
function init()
	_bgLayer = nil
	_priority = nil
	_zOrder = nil
	_cornNumLabel = nil
	_exTableView = nil
	_meritNumLabel = nil
	_visibleNum = nil
end

----------------------------------------事件函数----------------------------------------
--[[
	@des 	:事件注册函数
	@param 	:事件类型
	@return :
--]]
function onTouchesHandler(eventType)
	if (eventType == "began") then
	    return true
    elseif (eventType == "moved") then
    	print("moved")
    else
        print("end")
	end
end

--[[
	@des 	:事件注册函数
	@param 	:事件
	@return :
--]]
function onNodeEvent(event)
	if event == "enter" then
		-- _bgLayer:registerScriptTouchHandler(onTouchesHandler,false,_priority,true)
		--_bgLayer:setTouchEnabled(true)

		GuildDataCache.setIsInGuildFunc(true)
	elseif eventType == "exit" then
		--_bgLayer:unregisterScriptTouchHandler()

		GuildDataCache.setIsInGuildFunc(false)
	end
end

--[[
	@des 	:关闭界面回调
	@param 	:
	@return :
--]]
function closeCallBack()
	require "script/ui/guild/liangcang/LiangCangMainLayer"
	local liangcangLayer= LiangCangMainLayer.createLiangCangLayer()
	MainScene.changeLayer(liangcangLayer, "LiangCangMainLayer")
	
	-- _bgLayer:removeFromParentAndCleanup(true)
	-- _bgLayer = nil
end

--[[
	@des 	:得到奖励
	@param 	: $ tag 		:tag值
	@param 	: $ item 		:点击的那个元素
	@return :
--]]
function getPrizeCallBack(tag,item)
	--物品的DB数据
	local DBInfo = BarnData.getShopDBInfo(tag)

	--剩余兑换数目
	local remainNum = DBInfo.exchangeTimes - BarnData.getShopInfoById(tag)

	--如果需要开启等级大于粮仓等级，则表示未开启
	if DBInfo.granaryLv > GuildDataCache.getGuildBarnLv() then
		AnimationTip.showTip(GetLocalizeStringBy("zzh_1188"))
	--如果兑换数量已用尽
	elseif remainNum <= 0 then
		if DBInfo.limitType == 1 then
			AnimationTip.showTip(GetLocalizeStringBy("zzh_1189"))
		else
			AnimationTip.showTip(GetLocalizeStringBy("zzh_1211"))
		end
	--如果兑换所需粮草不足
	elseif  DBInfo.costForage ~= nil and DBInfo.costForage > GuildDataCache.getMyselfGrainNum() then
		AnimationTip.showTip(GetLocalizeStringBy("zzh_1190"))
	--所需功勋值不足
	elseif DBInfo.costExploit ~= nil and DBInfo.costExploit > GuildDataCache.getMyselfMeritNum() then
		AnimationTip.showTip(GetLocalizeStringBy("zzh_1206"))
	--背包满了
	elseif ItemUtil.isBagFull() then
		return
	--满足兑换条件，可以兑换
	else
		--购买回调
		local buyOverCallBack = function(p_num)
			--剩余兑换次数，并刷新UI
			remainNum = DBInfo.exchangeTimes - BarnData.getShopInfoById(tag)
			local baseMenu = tolua.cast(item:getParent(),"CCMenu")
			local baseSprite = tolua.cast(baseMenu:getParent(),"CCScale9Sprite")
			local numLabel = tolua.cast(baseSprite:getChildByTag(100),"CCRenderLabel")
			if DBInfo.limitType == 1 then
				numLabel:setString(GetLocalizeStringBy("zzh_1183") .. remainNum .. GetLocalizeStringBy("zz_124"))
			elseif DBInfo.limitType == 2 then
				numLabel:setString(GetLocalizeStringBy("zzh_1208") .. remainNum .. GetLocalizeStringBy("zz_124"))
			else
				numLabel:setString(GetLocalizeStringBy("zzh_1210") .. remainNum .. GetLocalizeStringBy("zz_124"))
			end

			local costCorn = DBInfo.costForage or 0
			local costExploit = DBInfo.costExploit or 0

			local cornNum = costCorn*p_num
			local exploitNum = costExploit*p_num

			local splitString = string.split(DBInfo.id,"|")
			local newNum = tonumber(splitString[3])*p_num
			local newString = splitString[1] .. "|" .. splitString[2] .. "|" .. newNum

			ItemUtil.addRewardByTable(BarnData.analyzeDBItem(newString))

			--刷新个人粮草数目
			GuildDataCache.setMyselfGrainNum(GuildDataCache.getMyselfGrainNum() - cornNum)
			--刷新个人功勋值
			GuildDataCache.setMyselfMeritNum(GuildDataCache.getMyselfMeritNum() - exploitNum)
			_cornNumLabel:setString(GuildDataCache.getMyselfGrainNum())
			_meritNumLabel:setString(GuildDataCache.getMyselfMeritNum())

			local rewardOkCallBack = function()
				BarnData.dealVisibleOrNot()

				local contentOffset = _exTableView:getContentOffset()
				if _visibleNum > BarnData.getVisibleNum() then
					contentOffset.y = contentOffset.y + 190*g_fScaleX
					_visibleNum = BarnData.getVisibleNum()
				end

				_exTableView:reloadData()

				_exTableView:setContentOffset(contentOffset)
			end

			ReceiveReward.showRewardWindow(BarnData.analyzeDBItem(newString),rewardOkCallBack)
		end

		local sureCallBack = function(p_num)
			if  DBInfo.costForage ~= nil and DBInfo.costForage*p_num > GuildDataCache.getMyselfGrainNum() then
				AnimationTip.showTip(GetLocalizeStringBy("zzh_1190"))
			--所需功勋值不足
			elseif DBInfo.costExploit ~= nil and DBInfo.costExploit*p_num > GuildDataCache.getMyselfMeritNum() then
				AnimationTip.showTip(GetLocalizeStringBy("zzh_1206"))
			else
				BarnService.exchangeItem(tag,p_num,buyOverCallBack)
			end
		end

		local _,paramName = ItemUtil.createGoodsIcon(BarnData.analyzeDBItem(DBInfo.id)[1])

		require "script/ui/common/BatchExchangeLayer"
		local paramTable = {}
		paramTable.title = GetLocalizeStringBy("key_2342")
		paramTable.first = GetLocalizeStringBy("key_1438")
		paramTable.max = remainNum
		paramTable.name = paramName
		paramTable.need = {}
		if DBInfo.costExploit ~= nil then
			local localTable = {needName = GetLocalizeStringBy("zzh_1239"),
								sprite = "images/common/gongxun.png",
								price = DBInfo.costExploit}
			table.insert(paramTable.need,localTable)
		end

		if DBInfo.costForage ~= nil then
			local localTable = {needName = GetLocalizeStringBy("zzh_1240"),
								sprite = "images/barn/corn.png",
								price = DBInfo.costForage}
			table.insert(paramTable.need,localTable)
		end

		BatchExchangeLayer.showBatchLayer(paramTable,sureCallBack)
	end
end

----------------------------------------UI函数----------------------------------------
--[[
	@des 	:创建tableView中的cell
	@param 	:物品id
	@return :创建好的cell
--]]
function createCell(p_id)
	local tCell = CCTableViewCell:create()
	--背景图片
	local cellBgSprite = CCScale9Sprite:create("images/common/bg/bg_9s_4.png")
	cellBgSprite:setContentSize(CCSizeMake(570, 185))
	cellBgSprite:setAnchorPoint(ccp(0,0))
	cellBgSprite:setPosition(ccp(35/2,5/2))
	tCell:addChild(cellBgSprite)

	--二级背景图片
	local innerBgSprite = CCScale9Sprite:create("images/copy/fort/textbg.png")
	innerBgSprite:setContentSize(CCSizeMake(320,120))
	innerBgSprite:setAnchorPoint(ccp(0,0))
	innerBgSprite:setPosition(ccp(25,50))
	cellBgSprite:addChild(innerBgSprite)

	--物品的DB数据
	local DBInfo = BarnData.getShopDBInfo(p_id)

	local iconString = BarnData.analyzeDBItem(DBInfo.id)[1]

	--显示菜单栏回调
	local function showDownMenu()
		MainScene.setMainSceneViewsVisible(false,false,false)
	end

	--物品图片
	--local itemSprite,itemName,itemColor = ItemUtil.createGoodsIcon(iconString,_priority - 3,nil,nil,showDownMenu,nil,nil,false)
	local itemSprite,itemName,itemColor = ItemUtil.createGoodsIcon(iconString,nil,nil,nil,showDownMenu,nil,nil,false)
	itemSprite:setAnchorPoint(ccp(0,0.5))
	itemSprite:setPosition(ccp(10,innerBgSprite:getContentSize().height/2))
	innerBgSprite:addChild(itemSprite)

	--文字位置
	local namePosX = 5 + itemSprite:getContentSize().width/2 + innerBgSprite:getContentSize().width/2
	--文字距离边的距离
	local gapLenth = 20

	--物品名称
	--local itemNameLabel = CCRenderLabel:create(DBInfo.name,g_sFontPangWa,24,1,ccc3(0x00,0x00,0x00),type_stroke)
	local itemNameLabel = CCRenderLabel:create(itemName,g_sFontPangWa,24,1,ccc3(0x00,0x00,0x00),type_stroke)
	--itemNameLabel:setColor(HeroPublicLua.getCCColorByStarLevel(DBInfo.quality))
	itemNameLabel:setColor(itemColor)
	itemNameLabel:setAnchorPoint(ccp(0.5,1))
	itemNameLabel:setPosition(ccp(namePosX,innerBgSprite:getContentSize().height - gapLenth + 10))
	innerBgSprite:addChild(itemNameLabel)

	local cornVisible
	local warVisible
	local cornPosition
	local warPosition

	local cornNum = DBInfo.costForage or 0
	local exploitNum = DBInfo.costExploit or 0

	if DBInfo.costForage ~= nil and DBInfo.costExploit == nil then
		cornVisible = true
		warVisible = false
		cornPosition = ccp(namePosX,gapLenth + 10)
		warPosition = ccp(namePosX,gapLenth)
	elseif DBInfo.costForage == nil and DBInfo.costExploit ~= nil then
		cornVisible = false
		warVisible = true
		cornPosition = ccp(namePosX,gapLenth + 10)
		warPosition = ccp(namePosX,gapLenth + 10)
	else
		cornVisible = true
		warVisible = true
		cornPosition = ccp(namePosX,gapLenth + 25)
		warPosition = ccp(namePosX,gapLenth - 10)
	end

	--文字 粮草
	local cornLabel = CCRenderLabel:create(GetLocalizeStringBy("zzh_1182"),g_sFontName,23,1,ccc3(0x00,0x00,0x00),type_stroke)
	cornLabel:setColor(ccc3(0xff,0xf6,0x00))
	--粮草图
	local cornSprite = CCSprite:create("images/barn/corn.png")
	--冒号
	local commaLabel = CCRenderLabel:create(":",g_sFontName,23,1,ccc3(0x00,0x00,0x00),type_stroke)
	commaLabel:setColor(ccc3(0xff,0xf6,0x00))
	--需要粮草数量
	local needNumLabel = CCRenderLabel:create(cornNum,g_sFontName,23,1,ccc3(0x00,0x00,0x00),type_stroke)
	needNumLabel:setColor(ccc3(0xff,0xff,0xff))

	--合并
	local connectNode = BaseUI.createHorizontalNode({cornLabel,cornSprite,commaLabel,needNumLabel})
	connectNode:setAnchorPoint(ccp(0.5,0))
	connectNode:setPosition(cornPosition)
	connectNode:setVisible(cornVisible)
	innerBgSprite:addChild(connectNode)

	--文字 功勋
	local exploitLabel = CCRenderLabel:create(GetLocalizeStringBy("zzh_1205"),g_sFontName,23,1,ccc3(0x00,0x00,0x00),type_stroke)
	exploitLabel:setColor(ccc3(0xff,0xf6,0x00))
	--粮草图
	local exploitSprite = CCSprite:create("images/common/gongxun.png")
	--冒号
	local commaLabel = CCRenderLabel:create(":",g_sFontName,23,1,ccc3(0x00,0x00,0x00),type_stroke)
	commaLabel:setColor(ccc3(0xff,0xf6,0x00))
	--需要粮草数量
	local needNumLabel = CCRenderLabel:create(exploitNum,g_sFontName,23,1,ccc3(0x00,0x00,0x00),type_stroke)
	needNumLabel:setColor(ccc3(0xff,0xff,0xff))

	--合并
	local connectNode = BaseUI.createHorizontalNode({exploitLabel,exploitSprite,commaLabel,needNumLabel})
	connectNode:setAnchorPoint(ccp(0.5,0))
	connectNode:setPosition(warPosition)
	connectNode:setVisible(warVisible)
	innerBgSprite:addChild(connectNode)

	--剩余兑换数目
	local remainNum = DBInfo.exchangeTimes - BarnData.getShopInfoById(p_id)

	if remainNum < 0 then
		remainNum = 0
	end

	--提示的位置
	local tipPosY = 25

	--今日可兑换多少次
	local canRewardLabel 
	--每日可兑换次数
	if DBInfo.limitType == 1 then
		canRewardLabel = CCRenderLabel:create(GetLocalizeStringBy("zzh_1183") .. remainNum .. GetLocalizeStringBy("zz_124"),g_sFontName,18,1,ccc3(0x00,0x00,0x00),type_stroke)
	--总共可兑换
	elseif DBInfo.limitType == 2 then
		canRewardLabel = CCRenderLabel:create(GetLocalizeStringBy("zzh_1208") .. remainNum .. GetLocalizeStringBy("zz_124"),g_sFontName,18,1,ccc3(0x00,0x00,0x00),type_stroke)
	--本周可兑换
	else
		canRewardLabel = CCRenderLabel:create(GetLocalizeStringBy("zzh_1210") .. remainNum .. GetLocalizeStringBy("zz_124"),g_sFontName,18,1,ccc3(0x00,0x00,0x00),type_stroke)
	end
	canRewardLabel:setColor(ccc3(0x00,0xff,0x18))
	canRewardLabel:setAnchorPoint(ccp(0,0))
	canRewardLabel:setPosition(ccp(35,tipPosY))
	cellBgSprite:addChild(canRewardLabel,1,100)

	--按钮层
	local cellMenu = CCMenu:create()
	cellMenu:setAnchorPoint(ccp(0,0))
	cellMenu:setPosition(ccp(0,0))
	--cellMenu:setTouchPriority(_priority - 2)
	cellBgSprite:addChild(cellMenu)

	--按钮位置
	local btnPosX = (cellBgSprite:getContentSize().width - 25 + innerBgSprite:getContentSize().width)/2

	--兑换按钮
	local exchangeMenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_shop_n.png","images/common/btn/btn_shop_h.png",
						     CCSizeMake(120,80),GetLocalizeStringBy("key_2689"),ccc3(0xff,0xe4,0x00),30,g_sFontPangWa,1,ccc3(0x00,0x00,0x00))
	exchangeMenuItem:setAnchorPoint(ccp(0.5,0.5))
	exchangeMenuItem:setPosition(ccp(btnPosX,50 + innerBgSprite:getContentSize().height/2))
	exchangeMenuItem:registerScriptTapHandler(getPrizeCallBack)
	cellMenu:addChild(exchangeMenuItem,1,p_id)

	--如果需要开启级别大于当前粮仓等级，则显示需要兑换级别
	if DBInfo.granaryLv > GuildDataCache.getGuildBarnLv() then
		--需要开启级别
		local needOpenLvLabel_1 = CCLabelTTF:create(GetLocalizeStringBy("zzh_1186"),g_sFontName,21)
		needOpenLvLabel_1:setColor(ccc3(0x78,0x25,0x00))
		local openLvLabel = CCLabelTTF:create(DBInfo.granaryLv,g_sFontName,21)
		openLvLabel:setColor(ccc3(0xf4,0x00,0x00))
		local needOpenLvLabel_2 = CCLabelTTF:create(GetLocalizeStringBy("zzh_1187"),g_sFontName,21)
		needOpenLvLabel_2:setColor(ccc3(0x78,0x25,0x00))

		--合并
		local openLvNode = BaseUI.createHorizontalNode({needOpenLvLabel_1,openLvLabel,needOpenLvLabel_2})
		openLvNode:setAnchorPoint(ccp(0.5,0))
		openLvNode:setPosition(ccp(btnPosX,tipPosY))
		cellBgSprite:addChild(openLvNode)
	end

	return tCell
end

--[[
	@des 	:创建tableView
	@param 	:参数table
	@return :创建好的tableView
--]]
function createTableView(p_param)
	_visibleNum = BarnData.getVisibleNum()

	local h = LuaEventHandler:create(function(fn,table,a1,a2)
		local r
		if fn == "cellSize" then
			r = CCSizeMake(605*g_fScaleX, 190*g_fScaleX)
		elseif fn == "cellAtIndex" then
			a2 = createCell(BarnData.getIdTable()[_visibleNum - a1])
			a2:setScale(g_fScaleX)
			r = a2
		elseif fn == "numberOfCells" then
			--r = BarnData.getItemNum()
			r = _visibleNum
		else
			print("other function")
		end

		return r
	end)

	return LuaTableView:createWithHandler(h, p_param.bgSize)
end

--[[
	@des 	:创建UI
	@param 	:
	@return :
--]]
function createUI()
	--粮草剩余背景
	local remainBgSprite = CCScale9Sprite:create("images/recharge/vip_benefit/desButtom.png")
	remainBgSprite:setContentSize(CCSizeMake(290,55))
	remainBgSprite:setAnchorPoint(ccp(0.5,1))
	remainBgSprite:setPosition(ccp(g_winSize.width/2,g_winSize.height*800/960))
	remainBgSprite:setScale(g_fElementScaleRatio)
	_bgLayer:addChild(remainBgSprite)
	
	--个人粮草 文字
	local ownTipLabel = CCLabelTTF:create(GetLocalizeStringBy("zzh_1181"),g_sFontPangWa,25)
	ownTipLabel:setColor(ccc3(0xff,0xff,0xff))
	--粮草图
	local cornSprite = CCSprite:create("images/barn/corn.png")
	--冒号
	local commaLabel = CCLabelTTF:create(":",g_sFontPangWa,25)
	commaLabel:setColor(ccc3(0xff,0xff,0xff))
	--粮草数量
	_cornNumLabel = CCLabelTTF:create(GuildDataCache.getMyselfGrainNum(),g_sFontPangWa,25)
	_cornNumLabel:setColor(ccc3(0x00,0xff,0x18))

	--连接Node
	local connectNode = BaseUI.createHorizontalNode({ownTipLabel,cornSprite,commaLabel,_cornNumLabel})
	connectNode:setAnchorPoint(ccp(0.5,0.5))
	connectNode:setPosition(ccp(remainBgSprite:getContentSize().width/2,remainBgSprite:getContentSize().height/2))
	remainBgSprite:addChild(connectNode)

	--功勋剩余背景
	local remainBgSprite_1 = CCScale9Sprite:create("images/recharge/vip_benefit/desButtom.png")
	remainBgSprite_1:setContentSize(CCSizeMake(290,55))
	remainBgSprite_1:setAnchorPoint(ccp(0.5,1))
	remainBgSprite_1:setPosition(ccp(g_winSize.width/2,g_winSize.height*740/960))
	remainBgSprite_1:setScale(g_fElementScaleRatio)
	_bgLayer:addChild(remainBgSprite_1)
	
	--个人功勋 文字
	local ownTipLabel_1 = CCLabelTTF:create(GetLocalizeStringBy("zzh_1209"),g_sFontPangWa,25)
	ownTipLabel_1:setColor(ccc3(0xff,0xff,0xff))
	--功勋图
	local cornSprite_1 = CCSprite:create("images/common/gongxun.png")
	--冒号
	local commaLabel_1 = CCLabelTTF:create(":",g_sFontPangWa,25)
	commaLabel_1:setColor(ccc3(0xff,0xff,0xff))
	--粮草数量
	_meritNumLabel = CCLabelTTF:create(GuildDataCache.getMyselfMeritNum(),g_sFontPangWa,25)
	_meritNumLabel:setColor(ccc3(0x00,0xff,0x18))

	--连接Node
	local connectNode = BaseUI.createHorizontalNode({ownTipLabel_1,cornSprite_1,commaLabel_1,_meritNumLabel})
	connectNode:setAnchorPoint(ccp(0.5,0.5))
	connectNode:setPosition(ccp(remainBgSprite_1:getContentSize().width/2,remainBgSprite_1:getContentSize().height/2))
	remainBgSprite_1:addChild(connectNode)

	--menu层
	local bgMenu = CCMenu:create()
	bgMenu:setAnchorPoint(ccp(0,0))
	bgMenu:setPosition(ccp(0,0))
	--bgMenu:setTouchPriority(_priority - 1)
	_bgLayer:addChild(bgMenu)

	--返回按钮
	local returnButton = CCMenuItemImage:create("images/common/close_btn_n.png","images/common/close_btn_h.png")
	returnButton:setScale(g_fElementScaleRatio)
	returnButton:setAnchorPoint(ccp(0.5,0.5))
	returnButton:setPosition(ccp(g_winSize.width*585/640,g_winSize.height*905/960))
	returnButton:registerScriptTapHandler(closeCallBack)
	bgMenu:addChild(returnButton)

	--tableView背景
	local viewBgSprite = CCScale9Sprite:create(CCRectMake(50,50,6,4),"images/barn/view_bg.png")
	viewBgSprite:setContentSize(CCSizeMake(g_winSize.width*605/640,g_winSize.height*645/960))
	viewBgSprite:setAnchorPoint(ccp(0.5,1))
	viewBgSprite:setPosition(ccp(g_winSize.width/2,g_winSize.height*675/960))
	_bgLayer:addChild(viewBgSprite)

	--创建tableView
	--本来应该新建文件写的，可是文件夹嵌套层次太深了，不好查bug，所以这里写一起吧
	--既然在内部，调用就用table吧，传地址省空间
	local paramTable = {}

	paramTable.bgSize = viewBgSprite:getContentSize()

	_exTableView = createTableView(paramTable)
	_exTableView:setAnchorPoint(ccp(0,0))
	_exTableView:setPosition(ccp(0,0))
	--_exTableView:setTouchPriority(_priority - 2)
	viewBgSprite:addChild(_exTableView)
end

--[[
	@des 	:防走光UI
	@param 	:
	@return :
--]]
function createBaseUI()
	--背景
	local underLayer = CCScale9Sprite:create("images/barn/under_orange.png")
	underLayer:setContentSize(CCSizeMake(g_winSize.width,g_winSize.height))
	underLayer:setAnchorPoint(ccp(0,0))
	underLayer:setPosition(ccp(0,0))
	_bgLayer:addChild(underLayer)

	--阳光
	local sunShineSprite = CCSprite:create("images/barn/sun_shine.png")
	sunShineSprite:setAnchorPoint(ccp(0.5,1))
	sunShineSprite:setPosition(ccp(g_winSize.width/2,g_winSize.height))
	sunShineSprite:setScale(g_fElementScaleRatio)
	_bgLayer:addChild(sunShineSprite)

	--小镁铝
	local girlSprite = CCSprite:create("images/barn/girl.png")
	girlSprite:setAnchorPoint(ccp(0,1))
	girlSprite:setPosition(ccp(-g_winSize.width*100/640,g_winSize.height))
	girlSprite:setScale(g_fElementScaleRatio)
	_bgLayer:addChild(girlSprite)

	--背景图
	local titleBgSprite = CCSprite:create("images/barn/title_bg.png")
	titleBgSprite:setAnchorPoint(ccp(0.5,1))
	titleBgSprite:setPosition(ccp(g_winSize.width/2,g_winSize.height))
	titleBgSprite:setScale(g_fElementScaleRatio)
	_bgLayer:addChild(titleBgSprite)

	--活动标题
	local titleSprite = CCSprite:create("images/barn/title.png")
	titleSprite:setAnchorPoint(ccp(0.5,0))
	titleSprite:setPosition(ccp(titleBgSprite:getContentSize().width/2,25))
	titleBgSprite:addChild(titleSprite)
end

----------------------------------------入口函数----------------------------------------
--[[
	@des 	:入口函数
	@param 	:
	@return :
--]]
function showLayer(p_touchPriority,p_zOrder)
	init()

	MainScene.setMainSceneViewsVisible(false,false,false)

	-- _priority = p_touchPriority or -1
	-- _zOrder = p_zOrder or 1

	_bgLayer = CCLayer:create()
	_bgLayer:registerScriptHandler(onNodeEvent)
	-- local scene = CCDirector:sharedDirector():getRunningScene()
 --    scene:addChild(_bgLayer,_zOrder)

 	MainScene.changeLayer(_bgLayer,"BarnExchangeLayer")

 	--防走光层
 	createBaseUI()

    --创建UI
	BarnService.getShopInfo(createUI)
	--createUI()
end