-- FileName: MonthCbLayer.lua 
-- Author: DJN 
-- Date: 14-10-13
-- Purpose: 月签到点击奖励图标回调弹窗


module("MonthCbLayer", package.seeall)
-- require "script/ui/rechargeActive/MonthCbLayer"
require "script/ui/rechargeActive/MonthSignData"
require "script/model/user/UserModel"
require "script/audio/AudioUtil"
 
local _bgLayer       --背景层
local _touchPriority --触摸优先级
local _ZOrder		 --Z轴值
local _count         -- 玩家选定的是第几天的奖励
local _info          --上个页面传来的选定的奖励的信息表格
local _signedInfo    --从后端获取当前玩家已经领取的奖励的数据
local _rewardTag     --用于领取奖励时候的标识  1.本日第一次领取（非VIP）  2.本日领取VIP  3.本日补领VIP
local _infoTable     --用于领取后弹窗提示用户已领取*** 的数据结构

function init()
	
	_bgLayer = nil
	_touchPriority = nil
	_ZOrder		   = nil
	_count = 0
    _info = nil
    _rewardTag = nil
    _signedInfo = MonthSignData.getSignData()
    _infoTable = nil
end
----------------------------------------触摸事件函数
function onTouchesHandler(eventType,x,y)
	if eventType == "began" then
		print("onTouchesHandler,began")
	    return true
    elseif eventType == "moved" then
    	print("onTouchesHandler,moved")
    else
        print("onTouchesHandler,else")
	end
end

local function onNodeEvent(event)
	if event == "enter" then
		_bgLayer:registerScriptTouchHandler(onTouchesHandler,false,_touchPriority,true)
		_bgLayer:setTouchEnabled(true)
	elseif event == "exit" then
		_bgLayer:unregisterScriptTouchHandler()
	end
end

----------------------------------------右上角关闭回调函数
--[[
	@des 	:关闭按钮回调
	@param 	:
	@return :
--]]
local function closeMenuCallBack()

	AudioUtil.playEffect("audio/effect/guanbi.mp3")
	--print("关闭按钮执行关闭")
    close()
end

--[[
	@des 	:关闭函数
	@param 	:
	@return :
--]]
function close( ... )
	_bgLayer:removeFromParentAndCleanup(true)
	_bgLayer = nil
end
--[[
	@des 	:发完领奖网络请求，请求成功后的回调动作
	@param 	:
	@return :
--]]
local function SignCb( ... )
	close()
	--这里加一个领取物品的弹窗
	
	if(_rewardTag == 2)then
		--领取了VIP双倍奖励的时候，展示的时候数量双倍
		_infoTable[1].num = _infoTable[1].num*2
	end 
	require "script/ui/rechargeActive/MonthSignAlertGet"
	MonthSignAlertGet.showLayer(_infoTable,MonthSignLayer.createScrollView,_touchPriority-10,_ZOrder)
	-- require "script/ui/item/ReceiveReward"
	-- ReceiveReward.showRewardWindow(_infoTable,MonthSignLayer.createScrollView,_ZOrder,_touchPriority-10,GetLocalizeStringBy("djn_67"))
end
----------------------------------------返回触摸优先级
function getTouchPriority( ... )
	return _touchPriority-20
end
---------------------------------------返回Z轴
function getZorder( ... )
	return _ZOrder +10
end
--[[
	@des 	:按钮回调
	@param 	:
	@return :
--]]
local function BtnCallBack()
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	--if(tonumber(_count) == (tonumber(_signedInfo.sign_num)+1) and tonumber(_signedInfo.reward_vip) == -1)then
	if(_rewardTag == 1 or _rewardTag == 2 or _rewardTag == 3)then
		--对于物品和英雄的奖励，先判断背包是否已经满了
		local isFull  = false
		--默认没有满
		if(_info.type == "item")then
            require "script/ui/item/ItemUtil"
			bagFull = ItemUtil.isBagFull()
			if (bagFull)then
               isFull = true
               close()
			end
		elseif(_info.type == "hero")then
			require "script/ui/hero/HeroPublicUI"
			local heroFull = HeroPublicUI.showHeroIsLimitedUI()
			if(heroFull)then
				isFull = true
				close()
			end
		else
		     --暂无其他上限判断
		end
        if(not isFull)then
        	--如果没有满，则发奖
        	--print("携带没有达到上限，可以发领奖请求")
        	MonthSignService.Sign(_count,SignCb)
        end

    else
    	--print("BtnCallBack执行一次关闭")
    	close()
	end
	
end
--返回此次发出领奖请求时候的领奖类型
function getRewardTag( ... )
	return _rewardTag
end
--返回此次领奖的奖励内容
function getCurReward( ... )
	return _info
end
----------------------------------------UI函数
--[[
	@des 	:创建背景
	@param 	:
	@return :
--]]
 function createBgUI()
	require "script/ui/main/MainScene"
	local bgSize = CCSizeMake(550,450)
	local bgScale = MainScene.elementScale
    
	--主黄色背景
	local bgSprite = CCScale9Sprite:create("images/common/viewbg1.png")
	bgSprite:setContentSize(CCSizeMake(bgSize.width,bgSize.height))
	bgSprite:setAnchorPoint(ccp(0.5,0.5))
	bgSprite:setPosition(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5)
	bgSprite:setScale(bgScale)
	_bgLayer:addChild(bgSprite)

 
	--二级棕色背景
	require "script/utils/BaseUI"
	secondBgSprite = BaseUI.createContentBg(CCSizeMake(470,170))
    secondBgSprite:setAnchorPoint(ccp(0.5,0.5))
    secondBgSprite:setPosition(ccp(bgSprite:getContentSize().width*0.5,bgSprite:getContentSize().height*0.7))
    bgSprite:addChild(secondBgSprite)


    local MenuBar = CCMenu:create()
	MenuBar:setPosition(ccp(0, 0))
	bgSprite:addChild(MenuBar)


	-- 关闭按钮
	local closeBtn = LuaMenuItem.createItemImage("images/common/btn_close_n.png", "images/common/btn_close_h.png" )
	closeBtn:setAnchorPoint(ccp(1, 0.5))
    closeBtn:setPosition(ccp(bgSprite:getContentSize().width*1.01, bgSprite:getContentSize().height*0.98))
    closeBtn:registerScriptTapHandler(closeMenuCallBack)
	MenuBar:addChild(closeBtn)
	MenuBar:setTouchPriority(_touchPriority-10)

	--领取/确定按钮
	local btnStr = GetLocalizeStringBy("key_8022")  --默认是确定按钮
	local userVip = UserModel.getVipLevel()
	local todayVip = tonumber(MonthSignData.todayVip(_count))
	local VIPdayTag = false
	if(todayVip >= 0)then
		--如果今天的VIP活动等级>=0 说明今天是VIP活动日
		VIPdayTag = true
	end

	if(tonumber(_count) == (tonumber(_signedInfo.sign_num)+1) )then
		--print("今天第一次进入这个界面")
		--点击的是今天的按钮
		
		--if( tonumber(_signedInfo.reward_vip) <0  )then
		if(MonthSignData.isDiffDay(MonthSignData.getSignData().sign_time))then
			--今天一次都没有领取过
			if(VIPdayTag)then
			--今天是VIP活动日	
			    print("今天是VIP活动日")
				if(tonumber(userVip) >= todayVip)then
					--达到今日VIP等级 领双倍
					_rewardTag = 2	
					print("可以领取VIP双倍")
				else
					_rewardTag = 1
					print("没有达到VIP ，只能领取单倍")
				end

			else
				--今天不是VIP活动日
				--领单倍
				_rewardTag = 1
				print("今天不是VIP活动日 ，只能领取单倍")
			end
			btnStr = GetLocalizeStringBy("key_1715")
		end
	elseif(tonumber(_count) == (tonumber(_signedInfo.sign_num)))then
		print("上一次领取时候的VIP，今日的VIP",_signedInfo.reward_vip,"--",todayVip)
	
		-- 	--已经不是今天第一次领取了 可能是VIP升级后来补领
		 if(VIPdayTag)then
		 	--大前提是今天是VIP活动日
			if(tonumber(_signedInfo.reward_vip) < todayVip)then
				--上一次领取的时候没有达到VIP等级，判断当前是否达到
				if(tonumber(userVip) >= todayVip)then
					print("升级了VIP 可以补领一次")
					_rewardTag = 3
					btnStr = GetLocalizeStringBy("key_1715")
				end
			end	
		end
    else		
	
	end
	
	local MenuItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_green_n.png","images/common/btn/btn_green_h.png",CCSizeMake(200, 73),btnStr,ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
    MenuItem:setAnchorPoint(ccp(0.5,0))
    MenuItem:setPosition(ccp(bgSprite:getContentSize().width*0.5,35))
    MenuItem:registerScriptTapHandler(BtnCallBack)
    MenuBar:addChild(MenuItem)
	
    -- 小背景
	local textBg = CCScale9Sprite:create("images/copy/fort/textbg.png")
	textBg:setContentSize(CCSizeMake(450, 135))
	textBg:setAnchorPoint(ccp(0.5,0.5))
	textBg:setPosition(ccp(secondBgSprite:getContentSize().width *0.5, secondBgSprite:getContentSize().height *0.5))
	secondBgSprite:addChild(textBg)

	local lineSprite = CCSprite:create("images/item/equipinfo/line.png")
	lineSprite:setScaleX(2.8)
	lineSprite:setAnchorPoint(ccp(0, 0))
	lineSprite:setPosition(ccp(110, 85))
	textBg:addChild(lineSprite)

    -- 描述
    local allDes = MonthSignData.getDes(_info)

    local goodsDesc = ""
    if(allDes.desc ~= nil )then 
    	goodsDesc = allDes.desc
    end

    local descLabel = CCLabelTTF:create(goodsDesc, g_sFontName, 20, CCSizeMake(325,70), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
    descLabel:setColor(ccc3(0x78, 0x25, 0x00))
    descLabel:setAnchorPoint(ccp(0,0))
    descLabel:setPosition(ccp(125, 5))
    textBg:addChild(descLabel)
    
    local icon = nil
    if(allDes.iconBg ~= nil)then
    	icon = allDes.iconBg
    end
    icon:setPosition(ccp(20,20))
    textBg:addChild(icon)
    
    --物品名称
    local name = ""
    if(allDes.iconName ~= nil)then
   		name = allDes.iconName
   	end
   	local nameLabel = CCRenderLabel:create(name, g_sFontName,28,1,ccc3( 0x00, 0x00, 0x00),type_stroke )
   	if(allDes.nameColor ~= nil)then
    	nameLabel:setColor(allDes.nameColor)
	else
        nameLabel:setColor(ccc3(0x78, 0x25, 0x00))
    end
    nameLabel:setAnchorPoint(ccp(0,0))
    nameLabel:setPosition(ccp(125, lineSprite:getPositionY()+lineSprite:getContentSize().height+5))
    textBg:addChild(nameLabel)
 
    --物品数量
    local num = ""
    if(_info.num ~= nil)then
    	num = _info.num
    end
    local numLabel = CCRenderLabel:create(GetLocalizeStringBy("djn_56")..num, g_sFontName,21,1,ccc3( 0x00, 0x00, 0x00),type_stroke )
    numLabel:setColor(ccc3(0xff, 0xff, 0xff))
    numLabel:setAnchorPoint(ccp(0,0))
    numLabel:setPosition(ccp(325, lineSprite:getPositionY()+lineSprite:getContentSize().height+5))
    textBg:addChild(numLabel)

    --累计签到*天可以获得那句话
    --这句话的位置取决于今天是否是VIP活动日，有些微调
    local LabelNum = CCLabelTTF:create(_count,g_sFontPangWa,23)
	LabelNum:setColor(ccc3(0x00,0x6d,0x2f))
	LabelNum:setAnchorPoint(ccp(0,0.5))
	LabelNum:setPosition(ccp(250,170))
	bgSprite:addChild(LabelNum)

    local isVIPday = MonthSignData.todayVip(_count)
    if(tonumber(isVIPday) ~= -1)then
    	--意味着是VIP活动日

        --require "script/utils/BaseUI"
        --(升级至VIP*可领取双倍奖励)，“可”这个字在屏幕最中间

        local strC = CCLabelTTF:create(GetLocalizeStringBy("key_1051"),g_sFontPangWa,23)
    	strC:setColor(ccc3(0x78,0x25,0x00))
    	strC:setPosition(ccp(bgSprite:getContentSize().width *0.5 -10,140))
        bgSprite:addChild(strC)

    	local strB = CCLabelTTF:create(GetLocalizeStringBy("djn_61")..isVIPday,g_sFontPangWa,23)
    	strB:setColor(ccc3(0x00,0x6d,0x2f))
    	strB:setPosition(ccp(strC:getPositionX() - strB:getContentSize().width -1, strC:getPositionY()))
    	bgSprite:addChild(strB)

    	local strA = CCLabelTTF:create(GetLocalizeStringBy("djn_60"),g_sFontPangWa,23)
    	strA:setColor(ccc3(0x78,0x25,0x00))
    	strA:setPosition(ccp(strB:getPositionX() - strA:getContentSize().width -1, strC:getPositionY()))
    	bgSprite:addChild(strA)
    	

    	local strD = CCLabelTTF:create(GetLocalizeStringBy("djn_62"),g_sFontPangWa,23)
    	strD:setColor(ccc3(0x00,0x6d,0x2f))
    	strD:setPosition(ccp(strC:getPositionX() + strC:getContentSize().width + 1, strC:getPositionY()))
    	bgSprite:addChild(strD)
    	local strE = CCLabelTTF:create(GetLocalizeStringBy("djn_63"),g_sFontPangWa,23)
    	strE:setColor(ccc3(0x78,0x25,0x00))
    	strE:setPosition(ccp(strD:getPositionX() + strD:getContentSize().width + 1, strC:getPositionY()))
    	bgSprite:addChild(strE)

    	-- local firstNode = BaseUI.createHorizontalNode({strA,strB,strC,strD,strE})
    	-- firstNode:ignoreAnchorPointForPosition(false)
    	-- firstNode:setAnchorPoint(ccp(0.5,1))
    	-- firstNode:setPosition(ccp(bgSprite:getContentSize().width *0.5,160))
    	-- bgSprite:addChild(firstNode)

    	LabelNum:setPosition(ccp(250,200))

    else
    	--LabelNum:setPosition(ccp(200,200))
    end
   
	local strOne = CCLabelTTF:create(GetLocalizeStringBy("djn_58"),g_sFontPangWa,23)
	strOne:setColor(ccc3(0x78,0x25,0x00))
	strOne:setAnchorPoint(ccp(1,0.5))
	strOne:setPosition(-10,LabelNum:getContentSize().height*0.5)
	LabelNum:addChild(strOne)

	local strTwo = CCLabelTTF:create(GetLocalizeStringBy("djn_59"),g_sFontPangWa,23)
	strTwo:setColor(ccc3(0x78,0x25,0x00))
	strTwo:setAnchorPoint(ccp(0,0.5))
	strTwo:setPosition(LabelNum:getContentSize().width+10,LabelNum:getContentSize().height*0.5)
	LabelNum:addChild(strTwo)

end

--[[
	@des 	:入口函数
	@param 	:tag:玩家选定的本月第几个奖励   allinfo:被选定的奖励信息
	@return :
--]]

function showLayer(tag,allinfo,p_touchPriority,p_ZOrder)
	init()
	_touchPriority = p_touchPriority or -599
	_ZOrder = p_ZOrder or 999
	_count = tag
	_info = allinfo[1]
	_infoTable = allinfo 
	_bgLayer = CCLayerColor:create(ccc4(0,0,0,155))
	_bgLayer:registerScriptHandler(onNodeEvent)
	--_bgLayer:setScale(g_fScaleX)
	local curScene = CCDirector:sharedDirector():getRunningScene()
    curScene:addChild(_bgLayer,_ZOrder)

    createBgUI()

	return _bgLayer
end
