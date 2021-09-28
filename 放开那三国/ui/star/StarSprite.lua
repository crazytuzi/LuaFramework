-- Filename：	StarSprite.lua
-- Author：		Cheng Liang
-- Date：		2013-8-8
-- Purpose：		star

module("StarSprite", package.seeall)


require "script/model/DataCache"
require "script/utils/LuaUtil"
require "script/model/user/UserModel"
require "script/model/utils/HeroUtil"
require "script/ui/item/ItemUtil"
require "script/ui/hero/HeroPublicLua"


-- 名将的全身像
function createStarSprite( star_tid )

	-- -- 查找名将的信息
	-- require "db/DB_Star"
	-- local starDesc = DB_Star.getDataById(tonumber(star_tid))


	-- local starSprite = CCSprite:create("images/base/hero/body_img/" .. starDesc.image)

	-- return starSprite;

	--因为要显示橙卡武将的全身像，所以要读heroes表确定武将全身像
	--changed by Zhang Zihang
	require "db/DB_Heroes"
	local starDesc = DB_Heroes.getDataById(tonumber(star_tid))
	local starSprite = CCSprite:create("images/base/hero/body_img/" .. starDesc.body_img_id)

	return starSprite
end

-- 获得名将的头像
function createIconButton( star_tid, level, star_id, isNeedLine, iconSpriteCallFun )


	-- 查找名将的信息
	-- require "db/DB_Star"
	-- local starDesc = DB_Star.getDataById(tonumber(star_tid))
	--changed by Zhang Zihang
	require "db/DB_Heroes"
	local starDesc = DB_Heroes.getDataById(tonumber(star_tid))
 

	local bgSprite = CCSprite:create("images/base/potential/officer_" .. starDesc.star_lv .. ".png")
	local iconFile = "images/base/hero/head_icon/" .. starDesc.head_icon_id

	-- 按钮Bar
	local menuBar = CCMenu:create()
	menuBar:setPosition(ccp(0, 0))
	bgSprite:addChild(menuBar,1,10)
	-- 按钮
	local item_btn = CCMenuItemImage:create(iconFile,iconFile)
	item_btn:registerScriptTapHandler(iconSpriteCallFun)
	item_btn:setAnchorPoint(ccp(0.5, 0.5))
	item_btn:setPosition(ccp(bgSprite:getContentSize().width/2, bgSprite:getContentSize().height/2))
	menuBar:addChild(item_btn, 1, tonumber(star_id))

	local nameBgSprite = CCSprite:create("images/common/bg/name.png")
	nameBgSprite:setAnchorPoint(ccp(0.5, 1))
	nameBgSprite:setScaleX(0.8)
	nameBgSprite:setPosition(ccp(item_btn:getContentSize().width*0.5, -item_btn:getContentSize().height*0.1))
	item_btn:addChild(nameBgSprite)


	-- 名将名称
	--local nameColor = HeroPublicLua.getCCColorByStarLevel(starDesc.quality)
	local nameColor = HeroPublicLua.getCCColorByStarLevel(starDesc.star_lv)
	local nameLabel = CCRenderLabel:create(starDesc.name, g_sFontName, 23, 2, ccc3( 0x00, 0x00, 0x00), type_stroke)
    nameLabel:setColor(nameColor)
    nameLabel:setAnchorPoint(ccp(0.5, 0.5))
    nameLabel:setPosition(ccp(nameBgSprite:getContentSize().width*0.5, nameBgSprite:getContentSize().height*0.5))
    nameBgSprite:addChild(nameLabel)

	if(level) then
		-- 心
		local heartSprite = CCSprite:create("images/star/intimate/heart_s.png")
		heartSprite:setAnchorPoint(ccp(0,0))
		heartSprite:setPosition(ccp(bgSprite:getContentSize().width*0.5,  bgSprite:getContentSize().height*1))
		bgSprite:addChild(heartSprite)

		-- 等级
		local levelLabel = CCLabelTTF:create(level, g_sFontName, 25)
		levelLabel:setColor(ccc3(0x00, 0x6d, 0x2f))
		levelLabel:setAnchorPoint(ccp(0.5, 0))
		levelLabel:setPosition(ccp(bgSprite:getContentSize().width*0.3,  bgSprite:getContentSize().height*1))
		bgSprite:addChild(levelLabel)
	end

	if(isNeedLine == true) then
		local lineSprite = CCSprite:create("images/common/line.png")
		lineSprite:setAnchorPoint(ccp(0,0.5))
		lineSprite:setScale(0.95)
		lineSprite:setPosition(ccp(bgSprite:getContentSize().width*1.08, bgSprite:getContentSize().height*0.5))
		bgSprite:addChild(lineSprite)
	end

	return bgSprite
end

