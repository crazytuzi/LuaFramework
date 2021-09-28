-- FileName: TuanRewardCell.lua 
-- Author: licong 
-- Date: 14-5-22 
-- Purpose: 团购奖励cell


module("TuanRewardCell", package.seeall)

require "script/model/user/UserModel"
require "script/ui/item/ItemSprite"
require "script/ui/item/ItemUtil"
require "script/ui/hero/HeroPublicLua"
require "script/ui/hero/HeroPublicCC"

function createCell(tCellValues,isChange,tag)
	local tCell = CCTableViewCell:create()
	local isChange = isChange
	-- 礼包预览
	local index = TuanLayer.getButtonMarkType(tCellValues.goodsId)
	local dbData = ActivityConfig.ConfigCache.groupon.data[tCellValues.goodsId]

	-- 物品icon
    local iconBg = CCSprite:create("images/everyday/headBg1.png")
    iconBg:setAnchorPoint(ccp(0,0.5))
    iconBg:setPosition(ccp(10,128))
    tCell:addChild(iconBg)
    -- 图标底
    local iconSpriteBg1 = CCSprite:create("images/base/potential/props_" .. tCellValues.rewardQuality .. ".png")
    iconSpriteBg1:setAnchorPoint(ccp(0.5,0.5))
    iconSpriteBg1:setPosition(ccp(iconBg:getContentSize().width*0.5,iconBg:getContentSize().height*0.5))
    iconBg:addChild(iconSpriteBg1)

    -- 礼包预览
    local lookCallBack = function ( ... )
	    local itemsData = ItemUtil.getItemsDataByStr( tCellValues.rewardStr )
	    -- print("jiangli ")
	    -- print_t(itemsData)
	    -- 展示奖励
	    require "script/ui/item/ReceiveReward"
	    ReceiveReward.showRewardWindow( itemsData, nil , 1001, -455, GetLocalizeStringBy("lic_1021") )
	end
    -- icon按钮
    local iconMenu = BTSensitiveMenu:create()
	if(iconMenu:retainCount()>1)then
		iconMenu:release()
		iconMenu:autorelease()
	end
    iconMenu:setAnchorPoint(ccp(0,0))
    iconMenu:setPosition(ccp(0,0))
    iconSpriteBg1:addChild(iconMenu)
    iconMenu:setTouchPriority(-330)
    -- 奖励礼包图片
	local bagFile = "images/recharge/tuan/" .. tCellValues.rewardIcon
    local iconSp_n = CCSprite:create(bagFile)
    local iconSp_h = CCSprite:create(bagFile)
    local iconItem = CCMenuItemSprite:create(iconSp_n,iconSp_h)
    iconItem:setAnchorPoint(ccp(0.5,0.5))
    iconItem:setPosition(ccp(iconSpriteBg1:getContentSize().width*0.5,iconSpriteBg1:getContentSize().height*0.5))
    iconMenu:addChild(iconItem,1)
    iconItem:registerScriptTapHandler(lookCallBack)

    -- 多少人团购
    local needNum = tCellValues.needNum
	local desLabelNum = CCRenderLabel:create( needNum, g_sFontPangWa,18,1,ccc3(0x00,0x00,0x00),type_stroke)
	desLabelNum:setColor(ccc3(0xff,0xff,0xff))
	desLabelNum:setAnchorPoint(ccp(0,0.5))
	iconBg:addChild(desLabelNum)
	local desLabelSp = CCSprite:create("images/recharge/tuan/des.png")
	desLabelSp:setAnchorPoint(ccp(0,0.5))
	iconBg:addChild(desLabelSp)
	local posX = (iconBg:getContentSize().width-desLabelNum:getContentSize().width-desLabelSp:getContentSize().width)/2
	desLabelNum:setPosition(ccp(posX,iconBg:getContentSize().height+10))
	desLabelSp:setPosition(ccp(desLabelNum:getPositionX()+desLabelNum:getContentSize().width,desLabelNum:getPositionY()))

	-- 领取回调
	local itemCallFun = function( tag, item)
		-- 判断活动是否结束
		if( BTUtil:getSvrTimeInterval()<tonumber(ActivityConfig.ConfigCache.groupon.start_time) or BTUtil:getSvrTimeInterval() > tonumber(ActivityConfig.ConfigCache.groupon.end_time) ) then
			AnimationTip.showTip(GetLocalizeStringBy("key_1857"))
			return
		end	
		-- 物品背包满了
		require "script/ui/item/ItemUtil"
		if(ItemUtil.isBagFull() == true )then
			return
		end
		-- 武将满了
		require "script/ui/hero/HeroPublicUI"
	    if HeroPublicUI.showHeroIsLimitedUI() then
	    	return
	    end
		local function requestCallback( )
			-- 弹出奖励物品
	        local rewardData = ItemUtil.getItemsDataByStr( tCellValues.rewardStr )
	        -- 修改本地数据 加奖励
	        -- print("rewardDat goodsId,id",tCellValues.goodsId,tCellValues.id)
	        -- print_t(rewardData)
	        ItemUtil.addRewardByTable(rewardData)
	        -- 刷新tableView
	        TuanLayer.createRewardList(true,tag)
	        -- 展现领取奖励列表
	        require "script/ui/item/ReceiveReward"
	        ReceiveReward.showRewardWindow( rewardData, nil , 1001, -455 )
	        -- 加领取的奖励id
	        TuanData.addHaveRewardIndex(tCellValues.goodsId,tCellValues.id)
		end
		TuanService.recReward( tCellValues.goodsId, tCellValues.id, requestCallback )
	end

	-- 领取按钮
	local normalSprite  = CCSprite:create("images/common/btn/btn_blue_n.png")
    local selectSprite  = CCSprite:create("images/common/btn/btn_blue_n.png")
    local disabledSprite = CCSprite:create("images/common/btn/btn_blue_hui.png")
    local item = CCMenuItemSprite:create(normalSprite,selectSprite,disabledSprite)
    item:setAnchorPoint(ccp(0.5,0.5))
    item:setPosition(ccp(iconSpriteBg1:getContentSize().width*0.5,-39))
    iconMenu:addChild(item,1,tonumber(tCellValues.id))
    item:registerScriptTapHandler(itemCallFun)
   
	-- 先判断是否领取过
	local isHaveGet = TuanData.isHaveReward(tCellValues.goodsId, tCellValues.id )

			if(isHaveGet)then
		-- -- 已经领取
		-- local fontStr = GetLocalizeStringBy("key_1369")
		-- local itemFont = CCRenderLabel:create(fontStr,  g_sFontPangWa, 30, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
		-- itemFont:setColor(ccc3(0xf1,0xf1,0xf1))
		-- itemFont:setAnchorPoint(ccp(0.5,0.5))
		-- itemFont:setPosition(ccp(item:getContentSize().width*0.5,item:getContentSize().height*0.5))
		-- item:addChild(itemFont,1,123)
		-- 按钮不可点，文字颜色置灰
		item:setVisible(false)
		local receive_alreadySp = CCSprite:create("images/sign/receive_already.png")
        receive_alreadySp:setPosition(ccp(iconSpriteBg1:getContentSize().width*0.5,-39))
        receive_alreadySp:setAnchorPoint(ccp(0.5,0.5))
        iconSpriteBg1:addChild(receive_alreadySp)
	else
		-- 没有领取的
		local fontStr = GetLocalizeStringBy("key_1085")
		local itemFont = CCRenderLabel:create(fontStr,  g_sFontPangWa, 30, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
		itemFont:setColor(ccc3(0xfe,0xdb,0x1c))
		itemFont:setAnchorPoint(ccp(0.5,0.5))
		itemFont:setPosition(ccp(item:getContentSize().width*0.5,item:getContentSize().height*0.5))
		item:addChild(itemFont,1,123)
		-- 判断是否够资格领取
		if( tCellValues.state == 0)then
			-- 没参团不够资格
			item:setEnabled(false)
			itemFont:setColor(ccc3(0xf1,0xf1,0xf1))
		else
			-- 参团人数不足 不能领
			if(tCellValues.needNum > tCellValues.haveNum )then
				-- 已购买人数不够 不够资格领取 按钮不可点且置灰
				item:setEnabled(false)
				itemFont:setColor(ccc3(0xf1,0xf1,0xf1))
			end
		end
	end
	if(isChange)then
		if(tonumber(tCellValues.id) == tonumber(tag))then
			item:setVisible(false)
			local receive_alreadySp = CCSprite:create("images/sign/receive_already.png")
	        receive_alreadySp:setPosition(ccp(iconSpriteBg1:getContentSize().width*0.5,-39))
	        receive_alreadySp:setAnchorPoint(ccp(0.5,0.5))
	        iconSpriteBg1:addChild(receive_alreadySp)
		end	
	end
	return tCell
end
