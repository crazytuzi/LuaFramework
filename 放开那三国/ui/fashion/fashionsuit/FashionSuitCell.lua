-- FileName: FashionSuitCell.lua 
-- Author: licong 
-- Date: 15/8/4 
-- Purpose: 时装套装cell 


module("FashionSuitCell", package.seeall)
require "script/ui/fashion/fashionsuit/FashionSuitData"

--[[
	@des 	:创建上边列表cell
	@param 	:p_id, 套装配方id
	@retrun :
]]
function createCell( p_id )
	print("p_id==>",p_id)

	local dbInfo = FashionSuitData.getDBInfoById(p_id)

	local cell = CCTableViewCell:create()
	cell:setContentSize(CCSizeMake(640,490))

	-- 背景
	local bg = CCScale9Sprite:create(CCRectMake(33, 35, 12, 45),"images/recharge/vip_benefit/vipBB.png")
	bg:setPreferredSize(CCSizeMake(604,458))
	bg:setAnchorPoint(ccp(0.5, 0))
	bg:setPosition(ccpsprite(0.5, 0, cell))
	cell:addChild(bg)

	-- 标题
	local nameBg = CCScale9Sprite:create(CCRectMake(86, 30, 4, 8), "images/dress_room/name_bg.png")
	bg:addChild(nameBg, 10)
	nameBg:setPreferredSize(CCSizeMake(258, 68))
	nameBg:setAnchorPoint(ccp(0.5, 0.5))
	nameBg:setPosition(ccp(bg:getContentSize().width * 0.5, bg:getContentSize().height - 3))

	local name = CCLabelTTF:create(dbInfo.name, g_sFontPangWa, 30)
	nameBg:addChild(name)
	name:setAnchorPoint(ccp(0.5, 0.5))
	name:setPosition(ccpsprite(0.5, 0.5, nameBg))
	name:setColor(ccc3(0xff, 0xf6, 0x00))

	-- 时装形象1
	local dressTids = FashionSuitData.getSuitItemsById(p_id) 
	local dressSprite1 = getDressSprite(dressTids[1])
	dressSprite1:setAnchorPoint(ccp(0,1))
	dressSprite1:setPosition(ccp(10,bg:getContentSize().height))
	bg:addChild(dressSprite1)

	-- 时装形象2
	local dressSprie2 = getDressSprite(dressTids[2])
	dressSprie2:setAnchorPoint(ccp(1,1))
	dressSprie2:setPosition(ccp(bg:getContentSize().width-10,bg:getContentSize().height))
	bg:addChild(dressSprie2)
	
	-- 是否激活套装
	local isActivate = FashionSuitData.isActivateSuitById(p_id)
	local color = ccc3(0x54,0x54,0x54)
	if(isActivate)then
		color = ccc3(0x0e,0x79,0x00)
	end

	-- 套装描述
	local desFont = CCLabelTTF:create(dbInfo.desc, g_sFontPangWa, 23)
	bg:addChild(desFont)
	desFont:setAnchorPoint(ccp(0.5, 0.5))
	desFont:setPosition(ccpsprite(0.5, 0.2, bg))
	desFont:setColor(color)

	-- 提示
	local tipFont = CCLabelTTF:create(GetLocalizeStringBy("lic_1628"), g_sFontPangWa, 23)
	bg:addChild(tipFont)
	tipFont:setAnchorPoint(ccp(0.5, 0.5))
	tipFont:setPosition(ccpsprite(0.5, 0.1, bg))
	tipFont:setColor(ccc3(0x7b, 0x37, 0x21))

	return cell
end


--[[
	@des 	:创建时装形象
	@param 	:p_tid:时装tid
	@retrun :
]]
function getDressSprite( p_tid )
	local retSprite = CCSprite:create()
	retSprite:setContentSize(CCSizeMake(281, 320))

	local bgSize = retSprite:getContentSize()
	local lightDatas = {
		{image = "bg.png", anchorPoint = ccp(0.5, 1), position = ccp(bgSize.width * 0.5, bgSize.height)},
		{image = "bg_light.png", anchorPoint = ccp(0.5, 0), position = ccp(bgSize.width * 0.5, bgSize.height - 290)},
		{image = "stage.png", anchorPoint = ccp(0.5, 0), position = ccp(bgSize.width * 0.5 - 2, bgSize.height - 322)},
		{image = "big_light.png", anchorPoint = ccp(0, 1), position = ccp(8, bgSize.height - 8)},
		{image = "big_light.png", anchorPoint = ccp(0, 1), position = ccp(bgSize.width - 8, bgSize.height - 8), scaleX = -1},
		{image = "small_light.png", anchorPoint = ccp(0, 1), position = ccp(80, bgSize.height - 10)},
		{image = "small_light.png", anchorPoint = ccp(0, 1), position = ccp(bgSize.width - 80, bgSize.height - 10), scaleX = -1},
	}
	-- 是否获得
	local isHave = FashionSuitData.isHaveDressByTid(p_tid)

	for i = 1, #lightDatas do
		local lightData = lightDatas[i]
		if(isHave == false)then
			lightData.image = "gray_" .. lightData.image
		end
		local light = CCSprite:create("images/dress_room/" .. lightData.image)
		retSprite:addChild(light)
		light:setAnchorPoint(lightData.anchorPoint)
		light:setPosition(lightData.position)
		if lightData.scaleX ~= nil then
			light:setScaleX(lightData.scaleX)
		end
	end

	-- 时装数据
	require "db/DB_Item_dress"
	local dbData = DB_Item_dress.getDataById(p_tid)
	-- 主角性别
	local myGenderId = UserModel.getUserSex()
	-- 时装的大图
	local bigImage = HeroUtil.getStringByFashionString( dbData.icon_big, myGenderId)
	local imagePath = "images/base/fashion/big/" .. bigImage

	local dressSprite = nil
	local noTipSprite = nil
	local color = nil
	if(isHave == false)then
		dressSprite = BTGraySprite:create(imagePath)
		noTipSprite = CCSprite:create("images/dress_room/not_get.png")
		color = ccc3(0xE2,0xDE,0xD3)
	else
		dressSprite = CCSprite:create(imagePath)
		color = ccc3(0xff, 0xf6, 0x00)
	end
	retSprite:addChild(dressSprite,9)
	dressSprite:setScale(0.8)
	dressSprite:setAnchorPoint(ccp(0.5, 0.5))
	dressSprite:setPosition(ccpsprite(0.5, 0.5, retSprite))

	local action_args = CCArray:create()
    action_args:addObject(CCMoveBy:create(0.8, ccp(0, 10)))
    action_args:addObject(CCMoveBy:create(0.8, ccp(0, -10)))
    action = CCRepeatForever:create(CCSequence:create(action_args))
    dressSprite:runAction(action)

    -- 未获得
    if(noTipSprite ~= nil)then
		retSprite:addChild(noTipSprite,20)
		noTipSprite:setAnchorPoint(ccp(0.5, 0.5))
		noTipSprite:setPosition(ccp(bgSize.width * 0.5, bgSize.height - 190))
	end

	-- 光圈
	if(isHave == true)then
		local guangSprite = XMLSprite:create("images/base/effect/huanzhuangxh/huanzhuangxh")
		retSprite:addChild(guangSprite, 10)
		guangSprite:setAnchorPoint(ccp(0.5, 0.5))
		guangSprite:setPosition(ccp(bgSize.width * 0.5 - 2, 70))
	end

	-- 时装名字
	local nameStr = HeroUtil.getStringByFashionString( dbData.name, myGenderId)
	local nameFont = CCRenderLabel:create(nameStr, g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	nameFont:setColor(color)
	nameFont:setAnchorPoint(ccp(0.5, 0.5))
	nameFont:setPosition(ccp(bgSize.width * 0.5, 30))
	retSprite:addChild(nameFont,30)

	return retSprite
end

















