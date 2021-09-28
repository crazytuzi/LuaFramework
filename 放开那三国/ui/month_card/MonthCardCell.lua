-- Filename：	MonthCardCell.lua
-- Author：		zhz
-- Date：		2013-6-12
-- Purpose：		月卡功能

module("MonthCardCell", package.seeall)

function createCell( data ,pCardId)
	local cell = CCTableViewCell:create()
	--创建超值月卡的底部
	local normalBg = CCSprite:create("images/month_card/button_bg"..pCardId..".png")
	normalBg:setScale(g_fScaleX)
	cell:addChild(normalBg)
	--创建滑动框的背景
	local scollerBg = CCSprite:create("images/month_card/scollerbg.png")
	scollerBg:setAnchorPoint(ccp(0,0.5))
	scollerBg:setPosition(ccp(0,normalBg:getContentSize().height*0.55))
	normalBg:addChild(scollerBg)
	--创建超值月卡的右边部分
	local rightBg = CCSprite:create("images/month_card/right_bg"..pCardId..".png") --[[131,242]]
	rightBg:setAnchorPoint(ccp(1,0.5))
	rightBg:setPosition(ccp(normalBg:getContentSize().width,normalBg:getContentSize().height*0.5))
	normalBg:addChild(rightBg)
	--创建花边
	local bian = CCSprite:create("images/month_card/bian.png")
	bian:setAnchorPoint(ccp(1,1))
	bian:setPosition(ccp(normalBg:getContentSize().width,normalBg:getContentSize().height))
	normalBg:addChild(bian)
	local bianx = CCSprite:create("images/month_card/bian.png")
    bianx:setAnchorPoint(ccp(1,0))
    bianx:setPosition(ccp(normalBg:getContentSize().width,0))
    bianx:setRotation(360)
    bianx:setFlipY(true)
    normalBg:addChild(bianx)
	--“充值”文字图片
	local chongzhi = CCSprite:create("images/month_card/chongzhi.png")
	chongzhi:setAnchorPoint(ccp(0.5,0.5))
	chongzhi:setPosition(ccp(rightBg:getContentSize().width*0.5,rightBg:getContentSize().height*0.65))
	rightBg:addChild(chongzhi)
	--金币图片
	local goldSprite = CCSprite:create("images/common/gold.png")
	goldSprite:setAnchorPoint(ccp(0,0.5))
	goldSprite:setPosition(ccp(15,rightBg:getContentSize().height*0.4))
	rightBg:addChild(goldSprite)
	--金币数量
	local goldNum = CCRenderLabel:create(data.payneedgold,g_sFontPangWa,33,1,ccc3(0x00,0x00,0x00),type_stroke)
	goldNum:setColor(ccc3(0xff,0xf6,0x00))
	goldNum:setAnchorPoint(ccp(0,0.5))
	goldNum:setPosition(ccp(16+goldSprite:getContentSize().width,rightBg:getContentSize().height*0.4))
	rightBg:addChild(goldNum)
	--“超值月卡”文字图片
	local monthCard = CCSprite:create("images/month_card/yuaka"..pCardId..".png")
	monthCard:setAnchorPoint(ccp(0,1))
	monthCard:setPosition(ccp(10,normalBg:getContentSize().height-5))
	normalBg:addChild(monthCard)
	-- 文字“购买后30天内,每天领取以下奖励”
	local desLable = CCRenderLabel:create(GetLocalizeStringBy("fqq_075"),g_sFontPangWa, 21,1, ccc3(0x00,0,0),type_stroke)
	desLable:setColor(ccc3(0xff,0xfc,0xa2))
	desLable:setAnchorPoint(ccp(0.5,1))
	desLable:setPosition(ccp(normalBg:getContentSize().width*0.55,normalBg:getContentSize().height-10))
	normalBg:addChild(desLable)
	--“剩余”文字
	local shengyu = CCSprite:create("images/month_card/shengyu.png")
	shengyu:setAnchorPoint(ccp(0,1))
	shengyu:setPosition(ccp(10,scollerBg:getContentSize().height-5))
	scollerBg:addChild(shengyu)
	--分割线
	local line = CCSprite:create("images/month_card/line.png")
	line:setAnchorPoint(ccp(0,0.5))
	line:setPosition(ccp(scollerBg:getContentSize().width*0.2,scollerBg:getContentSize().height*0.5))
	scollerBg:addChild(line)
	--奖励的物品
	--计算滑框的宽度
	local rewarddata = string.split(data.cardReward,",")
	local contentWidth = table.count(rewarddata)*121
	local width = scollerBg:getContentSize().width*0.8 - 75
	local scrollView = CCScrollView:create()
    scrollView:setContentSize(CCSizeMake(contentWidth, 242))
    scrollView:setViewSize(CCSizeMake(width, 242))
    scrollView:ignoreAnchorPointForPosition(false)
    scrollView:setAnchorPoint(ccp(0,0.5))
    scrollView:setPosition(ccp(scollerBg:getContentSize().width*0.22,scollerBg:getContentSize().height *0.5))
    scrollView:setTouchPriority(-455)
    scrollView:setDirection(kCCScrollViewDirectionHorizontal)
    scollerBg:addChild(scrollView)
 
    for k,v in pairs(rewarddata) do
        local rewardInDb = ItemUtil.getItemsDataByStr(rewarddata[k])
        local icon,itemName,itemColor = ItemUtil.createGoodsIcon(rewardInDb[1], -450, 3000, -480,function ( ... )
    end,nil,nil,false)
    icon:setPosition(ccp(25*k+(k-1)*icon:getContentSize().width,85))
    scrollView:addChild(icon)
    local nameLabel = CCRenderLabel:create(itemName, g_sFontName,20,1,ccc3( 0x00, 0x00, 0x00),type_stroke)
    icon:addChild(nameLabel)
    nameLabel:setAnchorPoint(ccp(0.5,1))
    nameLabel:setColor(itemColor)
    nameLabel:setPosition(ccp(icon:getContentSize().width*0.57,0)) 
    end 

	local spriteNum1,spriteNum2 = MonthCardData.getSpriteNum(pCardId)
	local sprite1 = CCSprite:create("images/month_card/"..spriteNum1..".png")
	sprite1:setAnchorPoint(ccp(0,0.5))
	sprite1:setPosition(ccp(10,scollerBg:getContentSize().height*0.48))
	scollerBg:addChild(sprite1)
	local sprite2 = CCSprite:create("images/month_card/"..spriteNum2..".png")
	sprite2:setAnchorPoint(ccp(0,0.5))
	sprite2:setPosition(ccp(sprite1:getContentSize().width,sprite1:getContentSize().height*0.5))
	sprite1:addChild(sprite2)
	--字体"天"
	local dayLabel = CCSprite:create("images/month_card/day.png")
	dayLabel:setPosition(ccp(scollerBg:getContentSize().width*0.15,0))
	scollerBg:addChild(dayLabel)

	--购买月卡
	local menuBar = CCMenu:create()
    menuBar:setPosition(ccp(0,0))
    menuBar:setTouchPriority(-440)
    normalBg:addChild(menuBar)
    if(MonthCardData.isBuyOrRecive(pCardId))then
    	-- 购买月卡按钮
		local buyItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn_purple2_n.png","images/common/btn/btn_purple2_n.png",CCSizeMake(180,73),GetLocalizeStringBy("fqq_076"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		buyItem:setAnchorPoint(ccp(0.5,0))
		buyItem:setPosition(ccp(normalBg:getContentSize().width*0.5,-5))
		buyItem:registerScriptTapHandler(buyCallback)
		menuBar:addChild(buyItem,1,tonumber(data.id))
		
	else
		-- 已购买图片
		local haveBuySprite = CCSprite:create("images/month_card/havebuy.png")
		haveBuySprite:setPosition(normalBg:getContentSize().width*0.2, 5)
		haveBuySprite:setAnchorPoint(ccp(0.5,0))
		normalBg:addChild(haveBuySprite)

		local receiveItem = LuaCC.create9ScaleMenuItem("images/common/btn/btn1_d.png","images/common/btn/btn1_n.png",CCSizeMake(180, 73),GetLocalizeStringBy("key_1715"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
		receiveItem:setAnchorPoint(ccp(0.5,0))
		receiveItem:setPosition(ccp(normalBg:getContentSize().width/2.1,-5))
		receiveItem:registerScriptTapHandler(receiveCallBack)
		menuBar:addChild(receiveItem,1,tonumber(data.id))

		--已领取
		local hasReceiveItem = CCSprite:create("images/sign/receive_already.png")
		hasReceiveItem:setAnchorPoint(ccp(0.5,0))
		hasReceiveItem:setPosition(ccp(normalBg:getContentSize().width/2,2))
		normalBg:addChild(hasReceiveItem)

		--判断今天是否已经领取，返回true为未领取，返回false为已领取
			local isCanRecive = MonthCardData.getCanReceive(pCardId)
			receiveItem:setVisible(isCanRecive)
			receiveItem:setEnabled(isCanRecive)
			hasReceiveItem:setVisible(not isCanRecive)
    end
    return cell
end
--领取按钮的回调
function receiveCallBack(tag, item)
	local function callBack(  )
		print("receiveCallBackreceiveCallBack")
		local rewardTable = MonthCardData.getCardReward(tag)
		ItemUtil.addRewardByTable(rewardTable)
		-- local closeback = function ( ... )
			--刷新界面
			refreshAftUpdate( )
		-- end
		ReceiveReward.showRewardWindow( rewardTable,nil,nil,-500)
		
	end

	MonthCardService.getDailyReward(tag,callBack)

end
-- 购买月卡的回调函数
function buyCallback(tag,item)
	require "script/ui/month_card/MonthCardBuyLayer"
	MonthCardBuyLayer.showLayer(-460,nil,tag)
	
end
-- 月卡推送的
function refreshAftUpdate( )
		local callBack = function ( ... )
			MonthCardLayer.createTopUI()
			MonthCardLayer.createUI()
		end
		MonthCardService.getCardInfo(callBack)
end