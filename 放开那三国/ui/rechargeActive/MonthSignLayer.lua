-- FileName: MonthSignLayer.lua 
-- Author: DJN 
-- Date: 14-10-13
-- Purpose: 月签到活动界面 


module("MonthSignLayer", package.seeall)
require "script/ui/rechargeActive/MonthSignService"
require "script/ui/rechargeActive/MonthSignData"
require "db/DB_Month_sign"
require "script/ui/item/ItemUtil"
require "script/ui/rechargeActive/MonthCbLayer"
require "script/model/user/UserModel"

local _bgLayer 				= nil
local _packBackground       = nil
local _secondBgSprite       = nil  
local _scrollView           = nil
local _mainMenu             = nil
local _ksTagMainMenu 		= 1001
local _touchPriority        = nil
local _signedInfo           = nil
local _topLabelNum          --顶部*月签到奖励的数字
local _downLabelNum         --本月已累积签到*天的数字
local _allDayforUse         --解析后的VIP天数和等级配置
local _dayCount             --本月有多少天是VIP活动日
local _monId                --通过month_sign中的circle算出这个月应该使用第几行的奖励
local _ZOrder		        = nil

function init( ... )
	_bgLayer 				= nil 
	_packBackground         = nil  
	_scrollView             = nil
	_mainMenu               = nil
	_touchPriority          = nil
	_signedInfo             = nil
	_secondBgSprite         = nil 
	_topLabelNum            = nil
	_downLabelNum           = nil
	_allDayforUse           = MonthSignData.analyzeGoodsTabStr(allDay) --解析后的VIP天数和等级配置
	_dayCount               = table.count(_allDayforUse) --本月有多少天是VIP活动日
	_ZOrder		            = nil
	_monId                  = tonumber(MonthSignData.getMonId())
end
--[[
	@des 	:创建UI
	@param 	:
	@return :
--]]
function createLayer( ... )
	if( _packBackground ~= nil ) then
		_packBackground:removeFromParentAndCleanup(true)
		_packBackground = nil
	end
	_packBackground = CCScale9Sprite:create(CCRectMake(33, 35, 12, 45),"images/recharge/vip_benefit/vipBB.png")
	-- _layer:setScale(1/MainScene.elementScale)

	require "script/ui/main/BulletinLayer"
	require "script/ui/main/MainScene"
	require "script/ui/main/MenuLayer"
	require "script/ui/rechargeActive/RechargeActiveMain"
	
	local bulletinLayerSize = RechargeActiveMain.getTopSize()
	local menuLayerSize = MenuLayer.getLayerContentSize()
	local height = g_winSize.height - (menuLayerSize.height + bulletinLayerSize.height )*g_fScaleX  - RechargeActiveMain.getBgWidth()-15*g_fScaleX

	_packBackground:setContentSize(CCSizeMake(g_winSize.width,height))
	_packBackground:setPosition(ccp(0,menuLayerSize.height*g_fScaleX+15*g_fScaleX))

	--_packBackground:setScale(g_fScaleX)

	--二级棕色背景
	require "script/utils/BaseUI"
	_secondBgSprite = BaseUI.createContentBg(CCSizeMake(g_winSize.width-30*g_fScaleX,_packBackground:getContentSize().height-120*g_fScaleX))
    _secondBgSprite:setAnchorPoint(ccp(0.5,0))
    _secondBgSprite:setPosition(ccp(_packBackground:getContentSize().width*0.5,40*g_fScaleX))
    --_secondBgSprite:setScale(g_fScaleX)
    _packBackground:addChild(_secondBgSprite)
   
	_bgLayer:addChild(_packBackground)
	createScrollView()

	--“月签到奖励”那个图片
	if(_topLabelNum ~= nil)then
		local topLabelSprite = CCSprite:create("images/sign/month_sign/title.png")
		topLabelSprite:setAnchorPoint(ccp(0,0.5))
		topLabelSprite:setPosition(ccp(_topLabelNum:getPositionX()+10,_topLabelNum:getPositionY()))
		topLabelSprite:setScale(g_fScaleX)
		_packBackground:addChild(topLabelSprite)		
	end
end
--[[
	@des 	:刷新“*月签到”及下面的“本月第*次签到”
	@param 	:
	@return :
--]]
function refershLabel()
	if( _topLabelNum ~= nil ) then
		--print("之前的月份数字已经存在，刷新")
		_topLabelNum:removeFromParentAndCleanup(true)
		_topLabelNum = nil
		--topBgSp:removeChildByTag(2000,true)
	end
	require "script/utils/TimeUtil"
	local curTime = TimeUtil.getSvrTimeByOffset()
	local curdate = os.date("*t", curTime)
	--print("系统时间获得到的月份数",curdate.month)

	_topLabelNum = CCRenderLabel:create(curdate.month, g_sFontPangWa,45,1,ccc3( 0x00, 0x00, 0x00),type_stroke )
	_topLabelNum:setColor(ccc3(0xff,0xff,0xff))
	_topLabelNum:setAnchorPoint(ccp(1,0.5))
	_topLabelNum:setPosition(ccp(237*g_fScaleX,_packBackground:getContentSize().height - 40*g_fScaleX))
	_topLabelNum:setScale(g_fScaleX)
	_packBackground:addChild(_topLabelNum)

	if( _downLabelNum ~= nil ) then
		--print("之前的次数数字已经存在，刷新")
		_downLabelNum:removeFromParentAndCleanup(true)
		_downLabelNum = nil
		--topBgSp:removeChildByTag(2000,true)
	end
	_downLabelNum = CCLabelTTF:create(_signedInfo.sign_num,g_sFontPangWa,23)
	_downLabelNum:setColor(ccc3(0x00,0x6d,0x2f))
	_downLabelNum:setAnchorPoint(ccp(0,0.5))
	_downLabelNum:setPosition(ccp(390*g_fScaleX,28*g_fScaleX))
	_downLabelNum:setScale(g_fScaleX)
	_packBackground:addChild(_downLabelNum)

	local strOne = CCLabelTTF:create(GetLocalizeStringBy("djn_57"),g_sFontPangWa,23)
	strOne:setColor(ccc3(0x78,0x25,0x00))
	strOne:setAnchorPoint(ccp(1,0.5))
	strOne:setPosition(-10,_downLabelNum:getContentSize().height*0.5)
	_downLabelNum:addChild(strOne)

	local strTwo = CCLabelTTF:create(GetLocalizeStringBy("key_2825"),g_sFontPangWa,23)
	strTwo:setColor(ccc3(0x78,0x25,0x00))
	strTwo:setAnchorPoint(ccp(0,0.5))
	strTwo:setPosition(_downLabelNum:getContentSize().width+10,_downLabelNum:getContentSize().height*0.5)
	_downLabelNum:addChild(strTwo)
    
end
--[[
	@des 	:创建奖励scrollview
	@param 	:
	@return :
--]]
function createScrollView( ... )
	print("createScrollView")

	if( _scrollView~= nil ) then
		_scrollView:removeFromParentAndCleanup(true)
		_scrollView=nil
		--topBgSp:removeChildByTag(2000,true)
	end

	_scrollView = CCScrollView:create()
    _scrollView:setContentSize(CCSizeMake(g_winSize.width-30, 155*g_fScaleX *math.ceil(DB_Month_sign.getDataById(_monId).num /4)))
    _scrollView:setViewSize(CCSizeMake(g_winSize.width-30, _secondBgSprite:getContentSize().height*0.95))
    _scrollView:ignoreAnchorPointForPosition(false)
    _scrollView:setAnchorPoint(ccp(0.5,0.5))
    _scrollView:setPosition(ccp(_secondBgSprite:getContentSize().width*0.5,_secondBgSprite:getContentSize().height *0.5))
    _scrollView:setTouchPriority(_touchPriority)
    _scrollView:setDirection(kCCScrollViewDirectionVertical)

    _scrollView:setContentOffset(ccp(0,_scrollView:getViewSize().height - _scrollView:getContentSize().height ))
    --_scrollView:setScale(g_fScaleX)

    _secondBgSprite:addChild(_scrollView,1,2000)

    --创建menu
    _mainMenu = BTMenu:create(true)
	_scrollView:addChild(_mainMenu,1 , _ksTagMainMenu)
	_mainMenu:setPosition(0,0)
	_mainMenu:setTouchPriority(_touchPriority+10)
	_mainMenu:setScrollView(_scrollView)
	--_mainMenu:setStyle(kMenuRadio)
 
	local count = 0
	local firstItem = nil

	local allDay = MonthSignData.getVIPday()
	_allDayforUse = MonthSignData.analyzeGoodsTabStr(allDay) --解析后的VIP天数和等级配置
	_dayCount = table.count(_allDayforUse) --本月有多少天是VIP活动日

	--获取已经签到的信息
    _signedInfo = MonthSignData.getSignData()
	local signedTime =  tonumber(_signedInfo.sign_num) 
	
	for i=1, DB_Month_sign.getDataById(_monId).num do

		local lineCount   --行数
		local rolumCount  --列数
	
        lineCount = math.floor((i-1)/4) + 1 
		rolumCount = i - (4*(lineCount-1))  --列数
		-- if(lineCount > 4)then
		-- 	_scrollView:setContentSize(CCSizeMake(_packBackground:getContentSize().width, 130*lineCount))
		-- end
		--print("输出行数，列数",lineCount,"---",rolumCount,"--",i)
		--解析后获得奖励的icon
		local dataAfterDeal = ItemUtil.getItemsDataByStr(DB_Month_sign.getDataById(_monId)["reward"..i])
		-- print("处理后的奖励字符串"..i)
		-- print_t(dataAfterDeal)
		local itemSprite =  ItemUtil.createGoodsIcon(dataAfterDeal[1],nil,nil,nil,nil,nil,true)		
		--local itemSprite =  ItemUtil.createGoodsIcon(dataAfterDeal[1],nil, nil, nil, nil ,nil,true)

		--local node = CCNode:create()
		local node = CCSprite:create()
		local iconbg 
		local selected = nil
		if(i< signedTime)then
			--在已经签到的天数之前的背景
			iconbg = CCSprite:create("images/sign/month_sign/got.png")
			selected = CCSprite:create("images/sign/month_sign/selected.png")
		elseif(i == signedTime )then
			if(MonthSignData.todayVip(i) ~= -1)then
				--意味着今天是VIP活动日
				if(MonthSignData.haveChance(i))then
					--还有机会通过升级补领 不遮挡
					iconbg = CCSprite:create("images/sign/month_sign/today.png")
				else
					iconbg = CCSprite:create("images/sign/month_sign/got.png")
					selected = CCSprite:create("images/sign/month_sign/selected.png")
				end
			else
				--今天不是VIP活动日
				iconbg = CCSprite:create("images/sign/month_sign/got.png")
				selected = CCSprite:create("images/sign/month_sign/selected.png")
			end
		elseif(i == signedTime+1 )then
			--如果今天没签过
			if(MonthSignData.isDiffDay(MonthSignData.getSignData().sign_time))then
				iconbg = CCSprite:create("images/sign/month_sign/today.png")
			else
				iconbg = CCSprite:create("images/sign/month_sign/other.png")
			end

			--今天已经领取过
		else
			iconbg = CCSprite:create("images/sign/month_sign/other.png")
		end


		--local node = CCLayerColor:create(ccc4(255,0,0,255))
		node:setContentSize(iconbg:getContentSize())
		node:ignoreAnchorPointForPosition(false)
		--node:setScale(g_fScaleX)
		--node:setAnchorPoint(ccp(0,1))
		iconbg:setAnchorPoint(ccp(0.5,0.5))
		iconbg:setPosition(ccp(node:getContentSize().width*0.5,node:getContentSize().height*0.5))
		node:addChild(iconbg,1)
		--print("加入背景成功")

		itemSprite:setAnchorPoint(ccp(0.5,0.5))
		itemSprite:setPosition(ccp(node:getContentSize().width*0.5,node:getContentSize().height*0.5))
		node:addChild(itemSprite,2)

		--用于VIP双倍的日子加效果
		for k = 1,_dayCount do

			if( tonumber(i)== tonumber(_allDayforUse[k][1]))then

				--获取数字素材
				local vipStr = tostring(_allDayforUse[k][2])
				-- print("输出VIP数字",vipStr)
				local vipLength = string.len(vipStr)
				-- print("输出VIP数字长度",vipLength)
				local numLabel = CCNode:create()
				local posX = 0
				local posY = 0
				for j = 1,vipLength do
					--print("输出VIP单位数字",string.sub(vipStr,j,j))

					local imgPath 
					local numberSprite = CCSprite:create("images/sign/month_sign/"..string.sub(vipStr,j,j)..".png")
					numberSprite:setAnchorPoint(ccp(0.5,0.5))
					numberSprite:setPosition(ccp(posX,posY))
					numLabel:addChild(numberSprite)
					posX = posX + 6
					if(tonumber(vipStr) == 11 )then
						--策划严格要求拼接效果，因为1这个数字比其他数字都要瘦，所以11这个数字做偏移量的时候稍有不同
						posY = posY - 5
					else
						posY = posY - 6
					end
				end
				numLabel:setContentSize(CCSizeMake(posX,0))
				numLabel:ignoreAnchorPointForPosition(false)
				numLabel:setAnchorPoint(ccp(0.5,0.5))
				local vipTag = nil
				if(vipLength == 1)then
					vipTag = CCSprite:create("images/sign/month_sign/VIP_1.png")
					numLabel:setPosition(ccp(48,43))
				else
					--一位数的vip和两位数的vip摆放上有一些微调
					--暂时未考虑三位数vip数字的摆放
					vipTag = CCSprite:create("images/sign/month_sign/VIP_2.png")
					numLabel:setPosition(ccp(47,47))
				end
				-- if(tonumber(_allDayforUse[k][2])<10)then
				-- local vipNum = CCSprite:create("images/sign/month_sign/".._allDayforUse[k][2]..".png")
				vipTag:addChild(numLabel)
                vipTag:setAnchorPoint(ccp(0.5,0.5))
				vipTag:setPosition(ccp(itemSprite:getContentSize().width-15,itemSprite:getContentSize().height-2))	
				itemSprite:addChild(vipTag)
			end
		end

		if(selected ~= nil)then
			local hide = CCLayerColor:create(ccc4(0,0,0,50))
			hide:setContentSize(node:getContentSize())
			hide:ignoreAnchorPointForPosition(false)
				--node:setAnchorPoint(ccp(0,1))
			hide:setAnchorPoint(ccp(0.5,0.5))
			hide:setPosition(ccp(node:getContentSize().width*0.5,node:getContentSize().height*0.5))
			node:addChild(hide,3)

			selected:setAnchorPoint(ccp(0.5,0.5))
			selected:setPosition(ccp(node:getContentSize().width*0.5,node:getContentSize().height*0.5))
			node:addChild(selected,4)
		end


		--itemSprite:setAnchorPoint(ccp(0,1))
		local heightForIcon = _scrollView:getContentSize().height-2
		local menuItem = CCMenuItemSprite:create(node,node,node)
		
		menuItem:setAnchorPoint(ccp(0,1))
		menuItem:setPosition(ccp(7*g_fScaleX*g_fScaleX+(rolumCount-1)*150*g_fScaleX,heightForIcon - (lineCount-1)*155*g_fScaleX))
		menuItem:registerScriptTapHandler(touchButton)
		menuItem:setScale(g_fScaleX)	
		_mainMenu:addChild(menuItem)
		menuItem:setTag(i)     
	end
	--因为执行刷新操作的时候 执行的是createScrollview这个函数 ，所以把页面中上下两个数字的label的刷新也放在这里了。
	refershLabel()
	
end
--[[
	@des 	:点击奖励icon后的回调
	@param 	:
	@return :
--]]
function touchButton(tag,menuItem)
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	local itemTag = tag
	local ifChance = MonthSignData.haveChance(itemTag)
    if(tonumber(itemTag) < tonumber(_signedInfo.sign_num))then
    	--之前领过的 点击无反应
    elseif (tonumber(itemTag) == tonumber(_signedInfo.sign_num))then
    	if (ifChance)then
    		
    		local userVip = UserModel.getVipLevel()
    		if(tonumber(userVip) >= tonumber(MonthSignData.todayVip(itemTag)))then
    			--玩家通过升级VIP可以补领取奖励
    			local dataAfterDeal = ItemUtil.getItemsDataByStr(DB_Month_sign.getDataById(_monId)["reward"..itemTag])
				MonthCbLayer.showLayer(itemTag,dataAfterDeal,_touchPriority-10)
    		else

    			local VIP = MonthSignData.todayVip(itemTag)
    			if(tonumber(VIP) >= 0)then
	    			require "script/ui/rechargeActive/MonSignCharge"
	    			MonSignCharge.showLayer(VIP,_touchPriority-10)
    			end
    		end
    	
    	else
    		-- 已经领取过 ，且今日无机会再补领
    		-- 无响应
    	end
    else
		local dataAfterDeal = ItemUtil.getItemsDataByStr(DB_Month_sign.getDataById(_monId)["reward"..itemTag])
		MonthCbLayer.showLayer(itemTag,dataAfterDeal,_touchPriority-10)
    end	
end
--[[
	@des 	:入口函数
	@param 	:
	@return :
--]]
function showLayer(touchpriority,ZOrder)
	init()
	_touchPriority = touchpriority or -499
    _ZOrder = ZOrder or 999
	_bgLayer = CCLayer:create()
	--_bgLayer:setScale(g_fScaleX)
	MonthSignService.getSignInfo(createLayer)
	
	return _bgLayer
end