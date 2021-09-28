-- FileName: LimitFundBuyCell.lua 
-- Author: fuqiongqiong
-- Date: 2016-9-14
-- Purpose: 限时基金Cell

module("LimitFundCell",package.seeall)
require "script/ui/rechargeActive/limitfund/LimitFundMXLayer"

function createCell( pData,pIndex,pTouchpriority )
	local cell = CCTableViewCell:create()

    
        --小背景
        local littleSprite =  CCSprite:create("images/recharge/jijinban.png")
        littleSprite:setAnchorPoint(ccp(0,1))
        littleSprite:setPosition(ccp(5,235))
        cell:addChild(littleSprite)
        local menuBar = CCMenu:create()
        menuBar:setPosition(ccp(0,0))
        menuBar:setTouchPriority(-630)
        littleSprite:addChild(menuBar,10)
       

		--物品icon
		
        --显示数量
        local returnNum = 0
        local typeNumTable = LimitFundData.getTypeOfNumTable()
        for k,v in pairs(typeNumTable) do
        	local dataTable = LimitFundData.getDataOfWay(tonumber(v.type))
        	local dataTable2 = dataTable[pIndex]
        	local allreadyNum = LimitFundData.getAllreadyNum(tonumber(v.type))
        	returnNum = returnNum + dataTable2[4]*allreadyNum
        end
        local dataTable = LimitFundData.getDataOfWay(tonumber(typeNumTable[1].type))
        local dataTable2 = dataTable[pIndex]
        local rewarddata = dataTable2[2].."|"..dataTable2[3].."|".."1"
        local rewardInDb = ItemUtil.getItemsDataByStr(rewarddata)
        local icon,itemName,itemColor = ItemUtil.createGoodsIcon(rewardInDb[1], -450, 3000, -480,function ( ... )
        end,nil,nil,false,false)
        icon:setAnchorPoint(ccp(0.5,0.5))
        icon:setPosition(ccp(littleSprite:getContentSize().width*0.5,littleSprite:getContentSize().height*0.47))
        littleSprite:addChild(icon)
        local dataTable = LimitFundData.getDataOfWay(tonumber(typeNumTable[1].type))
        local dataTable2 = dataTable[pIndex]
        local dayNum = dataTable2[1]
        local dayNum1 = dayNum - tonumber( LimitFundData.getLimitFundInfoById(1).buy_time)
        local curLable_1 = CCRenderLabel:create(GetLocalizeStringBy("fqq_174")..dayNum1..GetLocalizeStringBy("fqq_175"),g_sFontPangWa,19,1,ccc3(0x00,0x00,0x00),type_stroke)
        curLable_1:setColor(ccc3(0xff,0xf6,0x00))
        curLable_1:setAnchorPoint(ccp(0.5,1))
        curLable_1:setPosition(ccp(littleSprite:getContentSize().width*0.5,littleSprite:getContentSize().height-7))
        littleSprite:addChild(curLable_1)
        local shuliang =  CCRenderLabel:create(returnNum,g_sFontPangWa,20,1,ccc3(0x00,0x00,0x00),type_stroke)
        shuliang:setColor(ccc3(0x00,0xff,0x18))
        icon:addChild(shuliang)
        shuliang:setAnchorPoint(ccp(1,0))
        shuliang:setPosition(ccp(icon:getContentSize().width-5,3))
        local mingxiCallBack = function ( ... )
            LimitFundMXLayer.showPurchaseLayer(pIndex,returnNum)
        end
        local returnButton = CCMenuItemImage:create("images/recharge/fangda-n.png","images/recharge/fangda-h.png")
        returnButton:setScale(0.7)
        returnButton:setAnchorPoint(ccp(0,1))
        returnButton:setPosition(ccp(littleSprite:getContentSize().width*0.12,littleSprite:getContentSize().height*0.83))
        returnButton:registerScriptTapHandler(mingxiCallBack)
        menuBar:addChild(returnButton,1,pIndex)
         --   按钮状态 
        local statues = LimitFundData.getStatues(tonumber(typeNumTable[1].type),pIndex)
        if(statues == 0)then
        	--未达到领取条件
        	local dataTable = LimitFundData.getDataOfWay(tonumber(typeNumTable[1].type))
        	local dataTable2 = dataTable[pIndex]
        	local dayNum = dataTable2[1]
        	local dayNum1 = dayNum - LimitFundData.getDayOfAlreadyOpen()
        	local miaoshu = CCRenderLabel:create(GetLocalizeStringBy("fqq_156"),g_sFontPangWa,22,1,ccc3(0x00,0x00,0x00),type_stroke)
		    miaoshu:setColor(ccc3(0xff,0xff,0xff))
		    miaoshu:setAnchorPoint(ccp(0.5,0.5))
		    miaoshu:setPosition(ccp(littleSprite:getContentSize().width*0.55,-40))
		    littleSprite:addChild(miaoshu)
		    local miaoshuNum = CCRenderLabel:create(dayNum1,g_sFontPangWa,20,1,ccc3(0x00,0x00,0x00),type_stroke)
		    miaoshuNum:setColor(ccc3(0x00,0xff,0x18))
		    miaoshuNum:setAnchorPoint(ccp(1,0.5))
		    miaoshuNum:setPosition(ccp(0,miaoshu:getContentSize().height*0.5))
		    miaoshu:addChild(miaoshuNum)
        elseif statues == 1 then
        	--可领取状态
        	local reciveBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(135, 65),GetLocalizeStringBy("fqq_062"),ccc3(0xfe, 0xdb, 0x1c),28,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
        	reciveBtn:setAnchorPoint(ccp(0.5,0.5))
            reciveBtn:setPosition(ccp(littleSprite:getContentSize().width*0.5,-40))
            reciveBtn:registerScriptTapHandler(receiveCallBack)
            menuBar:addChild(reciveBtn, 1,pIndex)
        elseif statues == 2 then
        	--已领取状态
            local receive_alreadySp = CCSprite:create("images/sign/receive_already.png")
         	receive_alreadySp:setAnchorPoint(ccp(0.5,0.5))
            receive_alreadySp:setPosition(ccp(littleSprite:getContentSize().width*0.5, -40))
            littleSprite:addChild(receive_alreadySp)
        end       
	return cell
end

function receiveCallBack(index)
    if(LimitFundData.isActivityOver())then
        require "script/ui/tip/AnimationTip"
        AnimationTip.showTip(GetLocalizeStringBy("fqq_114"))
        return
    end
	LimitFundController.gain(index)
end

-- function mingxiCallBack( ... )
--     -- body
-- end