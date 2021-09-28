-- Filename：	RefiningMenuItem.lua
-- Author：		zhang zihang
-- Date：		2015-4-22
-- Purpose：		炼化小的选中图标

RefiningMenuItem = class("RefiningMenuItem")
require "script/ui/item/ItemSprite"

--[[
	@des 	:构造函数
--]]
function RefiningMenuItem:ctor()
	self.menuItemSprite = nil
	self.menuSprite_n = nil
	self.menuSprite_h = nil
	self.headSprite = nil
	self.menuItemSize = nil
	self.nameLabel = nil
end

--[[
	@des 	:创建按钮
	@param  :图片路径
--]]
function RefiningMenuItem:createMenuItem(p_imgPath)
	self.menuSprite_n = RefiningUtils.getCommonMenuSprite(p_imgPath)
	self.menuSprite_h = RefiningUtils.getHightLightMenuSprite(p_imgPath)
	self.menuItemSprite = CCMenuItemSprite:create(self.menuSprite_n,self.menuSprite_h)
	self.menuItemSize = self.menuItemSprite:getContentSize()
end

--[[
	@des 	:得到按钮
	@param  :按钮
--]]
function RefiningMenuItem:getMenuItem()
	return self.menuItemSprite
end

--[[
	@des 	:在按钮上添加头像图
	@param  :头像图路径
--]]
function RefiningMenuItem:addHeadSprite(p_imgPath)
	local imagePath = p_imgPath or "images/common/add_new.png"
	local bgSize = self.menuItemSize
	self.headSprite = CCSprite:create(imagePath)
	self.headSprite:setAnchorPoint(ccp(0.5,0.5))
	self.headSprite:setPosition(ccp(bgSize.width*0.5,bgSize.height*0.5))
	self.menuItemSprite:addChild(self.headSprite)
end

--[[
	@des 	:设置头像闪烁
--]]
function RefiningMenuItem:setSpriteAction()
	local arrAction = CCArray:create()
	arrAction:addObject(CCFadeOut:create(1))
	arrAction:addObject(CCFadeIn:create(1))
	local sequence = CCSequence:create(arrAction)
	local action = CCRepeatForever:create(sequence)
	self.headSprite:runAction(action)
end

--[[
	@des 	:设置名字
	@param  :名字
	@param  :品质
--]]
function RefiningMenuItem:setName(p_name,p_quality)
	local bgSize = self.menuItemSize
	self.nameLabel = CCRenderLabel:create(p_name,g_sFontPangWa,25,1,ccc3(0x00,0x00,0x00),type_shadow)
	self.nameLabel:setColor(HeroPublicLua.getCCColorByStarLevel(p_quality))
	self.nameLabel:setAnchorPoint(ccp(0.5,1))
	self.nameLabel:setPosition(ccp(bgSize.width*0.5,-3))
	self.menuItemSprite:addChild(self.nameLabel)
end

--[[
	@des 	:设置进化次数
	@param  :进化次数
--]]
function RefiningMenuItem:setEvolveNum(p_num)
	local bgSize = self.menuItemSize
	local plusSprite = CCSprite:create("images/hero/transfer/numbers/add.png")
	plusSprite:setAnchorPoint(ccp(1,0))
	plusSprite:setPosition(ccp(bgSize.width/2,8))
	self.menuItemSprite:addChild(plusSprite)
	local numSprite = CCSprite:create("images/hero/transfer/numbers/" .. p_num .. ".png")
	numSprite:setAnchorPoint(ccp(0,0))
	numSprite:setPosition(ccp(bgSize.width/2,8))
	self.menuItemSprite:addChild(numSprite)
end
--[[
	@des 	:设置橙卡品阶
	@param  :
--]]
function RefiningMenuItem:setStageNum(p_num)
	local bgSize = self.menuItemSize
	local numSprite = CCRenderLabel:create(p_num.. GetLocalizeStringBy("zzh_1159"),g_sFontPangWa,21,1,ccc3(0x00,0x00,0x00),type_stroke)
	numSprite:setColor(ccc3(0x76,0xfc,0x06))
	numSprite:setAnchorPoint(ccp(0.5,0))
	numSprite:setPosition(ccp(bgSize.width/2,8))
	self.menuItemSprite:addChild(numSprite)
end
--[[
	@des 	:为套装加特效
	@param  :
--]]
function RefiningMenuItem:addEffectOnEuip( p_quality)
	local e_name = "lzgreen"
	if(p_quality == 3)then
		e_name = "lzgreen"
	elseif(p_quality == 4)then
		e_name = "lzpurple"
	elseif(p_quality == 5)then
		e_name = "lzzise"
	else
		e_name = "lzgreen"
	end

	local s_effect = ItemSprite.getSuitEquipEffect(e_name)
	s_effect:setPosition(ccp(self.menuItemSprite:getContentSize().width*0.5, self.menuItemSprite:getContentSize().height*0.5))
	self.menuItemSprite:addChild(s_effect)

	local suitTagSprite = CCSprite:create("images/common/suit_tag.png")
	suitTagSprite:setAnchorPoint(ccp(0.5, 0.5))
	suitTagSprite:setPosition(ccp(self.menuItemSprite:getContentSize().width*0.25, self.menuItemSprite:getContentSize().height*0.9))
	self.menuItemSprite:addChild(suitTagSprite)

end
--[[
	@des 	:为时装加特效
	@param  :
--]]
function RefiningMenuItem:addEffectOnCloth()
	local e_name = "jinzhuan"
	local s_effect = ItemSprite.getFashionEffect(e_name)
	s_effect:setPosition(ccp(self.menuItemSprite:getContentSize().width*0.5, self.menuItemSprite:getContentSize().height*0.5))
	self.menuItemSprite:addChild(s_effect)
end
