-- Filename：	GuildShopCell.lua
-- Author：		zhz
-- Date：		2014-01-13
-- Purpose：		军团商店

module("GuildShopCell", package.seeall)

require "script/ui/rechargeActive/ActiveUtil"
require "script/utils/BaseUI"
require "script/ui/guild/GuildDataCache"
require "script/ui/guild/GuildUtil"
require "script/ui/hero/HeroPublicUI"
require "script/ui/tip/AnimationTip"
require "script/audio/AudioUtil"
require "script/ui/item/ItemUtil"

local _good_data = {}

local _callbackFn= nil
local  _index = 1 			-- 通过 index 来判断是否为珍品还是道具，

local function guildShopBuyCb( cbFlag, dictData, bRet )
	if (dictData.err ~= "ok") then
		return
	end

	local limitType= tonumber(_good_data.limitType)

	if(limitType ==3 or limitType == 4 or limitType == 5) then
		if(dictData.ret== "failed" ) then
			AnimationTip.showTip(GetLocalizeStringBy("key_1009"))
			return 
		end
	end 
	local num=0 
	local  sum=0

	if(limitType ==1 or limitType == 2 or limitType == 3) then
		num=1
		sum=0
	elseif(limitType == 4 or limitType == 5) then
		num=1
		sum = 1
	end
	if( _index ==1) then
		GuildDataCache.addSpecialBuyNumById(_good_data.id, sum,num)
	else
		GuildDataCache.addNorBuyNumById(_good_data.id, sum,num)
	end
	GuildDataCache.addSigleDonate(-tonumber(_good_data.costContribution))
	ActiveUtil.showItemGift(_good_data)
	if(_callbackFn ~= nil) then
		_callbackFn()
	end

end


function buyAction( tag, item )
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")

	local goodId= tonumber(tag)
	print("goodId is : ", goodId)
	local buyNum -- = GuildDataCache.getNorBuyNumById(goodId) 
	if(_index==1) then
		_good_data = GuildUtil.getSpcialGooodById(goodId)
		buyNum =  GuildDataCache.getSpecialBuyNumById(goodId)
	else
		_good_data = GuildUtil.getNormalGoodById(goodId)
		buyNum = GuildDataCache.getNorBuyNumById(goodId) 
	end
	-- print_t(_good_data)
	local shoplevel = GuildDataCache.getShopLevel()
	if(shoplevel<_good_data.needLegionLevel ) then	
        AnimationTip.showTip( GetLocalizeStringBy("key_2523"))
        return
	end

	if UserModel.getAvatarLevel() < tonumber(_good_data.levelLimit) then
		AnimationTip.showTip( GetLocalizeStringBy("zzh_1289"))
        return
	end

	if( _good_data.type== 1 and ItemUtil.isBagFull() == true )then
			return
	end

	if(_good_data.type== 2 and  HeroPublicUI.showHeroIsLimitedUI()) then
		return
	end

	if(GuildDataCache.getSigleDoante()<  tonumber(_good_data.costContribution)) then
		AnimationTip.showTip( GetLocalizeStringBy("key_2038"))
        return
	end

	
	local canBuy , tip  = canBuyGood(_good_data , buyNum)
	if(canBuy== true) then
		-- 购买商品
		local args= CCArray:create()
		args:addObject(CCInteger:create(_good_data.id))
		args:addObject(CCInteger:create(1))

		Network.rpc(guildShopBuyCb, "guildshop.buy", "guildshop.buy", args, true)
	else
		AnimationTip.showTip(tip)
	end
end

-- 判断是否可以购买物品
function canBuyGood( good_data, buyNum )
	buyNum.num = buyNum.num or 0
	buyNum.sum = buyNum.sum or 0
	local limitType = tonumber(good_data.limitType)
	-- 个人购买次数
	local num=0 
	-- 军团购买次数
	local sum = 0
	local tip= GetLocalizeStringBy("key_1009")
	if( limitType ==1 or limitType == 2) then
		num=  good_data.personalLimit- buyNum.num
		if(num >0) then
			return true ,tip
		else
			return false, tip 
		end
	elseif(limitType ==3 or limitType == 4) then
		sum= good_data.baseNum- buyNum.sum 
		num= good_data.personalLimit - buyNum.num 
		if(num>0 and sum >0) then
			return true, tip
		else
			if limitType == 3 then
				tip = string.format(GetLocalizeStringBy("key_10282"), good_data.personalLimit)
			elseif(limitType == 4 ) then
				tip= GetLocalizeStringBy("key_2509") .. good_data.personalLimit .. GetLocalizeStringBy("key_3010")
			else
				tip= GetLocalizeStringBy("key_1541") .. good_data.personalLimit .. GetLocalizeStringBy("key_3010")
			end
			if(sum ==0 ) then
				tip= GetLocalizeStringBy("key_1009")
			end
			return false, tip
		end
	end
end



function createCell( goods_data , index, callbackFn)
	local tCell = CCTableViewCell:create()

	_callbackFn = callbackFn
	_index= index
	--背景
	local cellBackground = CCScale9Sprite:create("images/common/bg/bg_9s_4.png")
	cellBackground:setContentSize(CCSizeMake(459, 178))
	tCell:addChild(cellBackground)

	-- 小背景
	local textBg = CCScale9Sprite:create("images/copy/fort/textbg.png")
	textBg:setContentSize(CCSizeMake(270, 112))
	textBg:setAnchorPoint(ccp(0,0))
	textBg:setPosition(ccp(34, 49))
	cellBackground:addChild(textBg)

	local buyMenuBar = CCMenu:create()
	buyMenuBar:setPosition(ccp(0,0))
	cellBackground:addChild(buyMenuBar)

	-- 表中物品数据,物品图标
	local item_data = nil
	local iconSprite = nil
	
	local iconItem= ActiveUtil.getItemIcon(goods_data.type,goods_data.tid)
	iconItem:setPosition(8,11)
	textBg:addChild(iconItem)


    local num_data = goods_data.num or 1
    local num_font = CCRenderLabel:create(tostring(num_data), g_sFontName, 20, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    num_font:setColor(ccc3(0x70, 0xff, 0x18))
    num_font:setAnchorPoint(ccp(1,0))
    num_font:setPosition(ccp(iconItem:getContentSize().width-8,3))
    iconItem:addChild(num_font)

    -- 如果为珍品的话，图标上显示珍品
    if(_index==1) then
    	local sealSp= CCSprite:create("images/guild/shop/value_seal.png")
    	sealSp:setAnchorPoint(ccp(0.5, 0.5))
		sealSp:setPosition(ccp(iconItem:getContentSize().width*0.25, iconItem:getContentSize().height*0.9))
    	iconItem:addChild(sealSp)
    end

	 
local buyBtn
if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
	buyBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(119, 64),GetLocalizeStringBy("key_2689"),ccc3(0xfe, 0xdb, 0x1c),25,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
else
	buyBtn = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(119, 64),GetLocalizeStringBy("key_2689"),ccc3(0xfe, 0xdb, 0x1c),35,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
end
	buyBtn:setAnchorPoint(ccp(0, 0))
	buyBtn:setPosition(ccp(311, 73))
	buyBtn:registerScriptTapHandler(buyAction )
	buyMenuBar:addChild(buyBtn, 1,goods_data.id )

	local itemInfo= ActiveUtil.getItemInfo(goods_data.type,goods_data.tid)
	-- 物品名称
	local nameLabel = CCRenderLabel:create("" .. itemInfo.name , g_sFontPangWa, 24, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
    -- nameLabel:setColor(ccc3(0xff, 0xe4, 0x00))
    local color = HeroPublicLua.getCCColorByStarLevel(itemInfo.quality)
    nameLabel:setColor(color)
    nameLabel:setPosition(112, 69)
    nameLabel:setAnchorPoint(ccp(0,0))
    textBg:addChild(nameLabel)

    -- 物品贡献
    local donateLabel= CCRenderLabel:create(GetLocalizeStringBy("key_1016") , g_sFontName,23,1, ccc3(0x00,0x00,0x00), type_stroke)
    donateLabel:setColor(ccc3(0xff,0xf6,0x00))
    donateLabel:setPosition(114,27)
    donateLabel:setAnchorPoint(ccp(0,0))
    textBg:addChild(donateLabel)

    donateNumLabel= CCRenderLabel:create("" .. goods_data.costContribution ,g_sFontName, 23,1,ccc3(0x00,0x00,0x00), type_stroke)
    donateNumLabel:setColor(ccc3(0xff,0xff,0xff))
        --兼容东南亚英文版
if(Platform.getLayout ~= nil and Platform.getLayout() == "enLayout" ) then
    donateNumLabel:setPosition(200,27)
else
	donateNumLabel:setPosition(176,27)
end
    donateNumLabel:setAnchorPoint(ccp(0,0))
    textBg:addChild(donateNumLabel) 

    local leftStr= {}
    local leftNumber= 0
    local limitType = tonumber(goods_data.limitType)

    local buyNum 
    if(_index ==1) then
    	buyNum =GuildDataCache.getSpecialBuyNumById(tonumber(goods_data.id))
    else
   		buyNum =GuildDataCache.getNorBuyNumById(tonumber(goods_data.id)) 
   	end
   	-- print("buyNum  is : ")
   	-- print_t(buyNum)
    if(limitType==1) then
    	-- leftStr= GetLocalizeStringBy("key_2223")
    	leftStr[1]= GetLocalizeStringBy("key_2605")
    	leftStr[2]= GetLocalizeStringBy("key_2843")
    	leftStr[3]=GetLocalizeStringBy("key_1033")
    	leftNumber = goods_data.personalLimit - buyNum.num
    elseif(limitType== 2) then
    	-- leftStr= GetLocalizeStringBy("key_2760")
    	leftStr[1]= GetLocalizeStringBy("key_2605")
    	leftStr[2]= GetLocalizeStringBy("key_1053")
    	leftStr[3]=GetLocalizeStringBy("key_1033")
    	leftNumber= goods_data.personalLimit - buyNum.num
    elseif limitType == 3 then
    	leftStr[1]= GetLocalizeStringBy("key_2605")
    	leftStr[2]= GetLocalizeStringBy("key_10283")
    	leftStr[3]=GetLocalizeStringBy("key_1033")
    	leftNumber= goods_data.personalLimit - buyNum.num
    elseif(limitType ==4) then
    	-- leftStr= GetLocalizeStringBy("key_3062")
    	leftStr[1]= GetLocalizeStringBy("key_3406")
    	leftStr[2]= GetLocalizeStringBy("key_2843")
    	leftStr[3]=GetLocalizeStringBy("key_1673")
    	leftNumber= goods_data.baseNum- buyNum.sum
    elseif(limitType == 5)then
    	-- leftStr= GetLocalizeStringBy("key_1863")
    	leftStr[1]= GetLocalizeStringBy("key_3406")
    	leftStr[2]= GetLocalizeStringBy("key_1053")
    	leftStr[3]=GetLocalizeStringBy("key_1673")
    	leftNumber= goods_data.baseNum - buyNum.sum
    else
    	leftStr[1]= GetLocalizeStringBy("key_3406")
    	leftStr[2]= GetLocalizeStringBy("key_1053")
    	leftStr[3]=GetLocalizeStringBy("key_1673")
    	leftNumber = 0
    end
    local leftBuyNumLabel_1 = CCLabelTTF:create(leftStr[1], g_sFontName, 21)
    leftBuyNumLabel_1:setColor(ccc3(0x78,0x25,0x00))
    local leftBuyNumLabel_2= CCLabelTTF:create(leftStr[2], g_sFontName, 21)
    leftBuyNumLabel_2:setColor(ccc3(0xf4,0x00,0x00))
    local leftBuyNumLabel_3 = CCLabelTTF:create(leftStr[3] , g_sFontName, 21)
    leftBuyNumLabel_3:setColor(ccc3(0x78,0x25,0x00))
    local leftBuyNumLabel_3 = CCLabelTTF:create(leftStr[3] , g_sFontName, 21)
    leftBuyNumLabel_3:setColor(ccc3(0x78,0x25,0x00))

    local cc_3= ccc3(0xf4,0x00,0x00)
    if( leftNumber>0) then
    	cc_3= ccc3(0x78,0x25,0x00)
    else
    	leftNumber= 0
    	cc_3= ccc3(0xf4,0x00,0x00)
    end
    local leftBuyNumLabel_4 = CCLabelTTF:create(tostring(leftNumber) , g_sFontName, 21)
    leftBuyNumLabel_4:setColor(cc_3)
    local leftBuyNumLabel_5= CCLabelTTF:create(GetLocalizeStringBy("key_2557"), g_sFontName, 21)
    leftBuyNumLabel_5:setColor(ccc3(0x78,0x25,0x00))

    local leftBuyNumNode= BaseUI.createHorizontalNode({leftBuyNumLabel_1,leftBuyNumLabel_2,leftBuyNumLabel_3,leftBuyNumLabel_4,leftBuyNumLabel_5 })
    leftBuyNumNode:setPosition(40,17)
    cellBackground:addChild(leftBuyNumNode)

    local levelContent= {}
    levelContent[1]= CCLabelTTF:create(GetLocalizeStringBy("key_2174"),g_sFontName, 21)
    levelContent[1]:setColor(ccc3(0x78,0x25,0x00))
    levelContent[2]= CCLabelTTF:create(tostring(goods_data.needLegionLevel) ,g_sFontName, 21)
    levelContent[2]:setColor(ccc3(0xf4,0x00,0x00) )
    levelContent[3]= CCLabelTTF:create(GetLocalizeStringBy("key_1526"),g_sFontName, 21)
    levelContent[3]:setColor(ccc3(0x78,0x25,0x00))
    local levelNode= BaseUI.createHorizontalNode(levelContent)
    levelNode:setPosition(270,17)
    cellBackground:addChild(levelNode)
        -- 军团商店的等级
    if(GuildDataCache.getShopLevel()>= tonumber(goods_data.needLegionLevel)) then
    	levelNode:setVisible(false)
    end

    local personalLevelContent= {}
    personalLevelContent[1]= CCLabelTTF:create(GetLocalizeStringBy("zzh_1288"),g_sFontName, 21)
    personalLevelContent[1]:setColor(ccc3(0x78,0x25,0x00))
    personalLevelContent[2]= CCLabelTTF:create(tostring(goods_data.levelLimit) ,g_sFontName, 21)
    personalLevelContent[2]:setColor(ccc3(0xf4,0x00,0x00) )
    -- personalLevelContent[3]= CCLabelTTF:create(GetLocalizeStringBy("key_1526"),g_sFontName, 21)
    -- personalLevelContent[3]:setColor(ccc3(0x78,0x25,0x00))
    local personalLevelNode= BaseUI.createHorizontalNode(personalLevelContent)
    personalLevelNode:setPosition(260,17)
    cellBackground:addChild(personalLevelNode)
        -- 军团商店的等级
    if (UserModel.getAvatarLevel() >= tonumber(goods_data.levelLimit)) or (levelNode:isVisible()) then
    	personalLevelNode:setVisible(false)
    end


	return tCell
end





