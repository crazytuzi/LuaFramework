-- Filename：	HeroCell.lua
-- Author：		Cheng Liang
-- Date：		2013-7-4
-- Purpose：		阵型中英雄Cell

module("HeroCell", package.seeall)


require "script/model/hero/HeroModel"

-- local POTENTIAL_0 = "images/formation/potential/equip_1.png"

local POTENTIAL_Base = "images/base/potential/officer_"

local HighLight = "images/formation/potential/highlight.png"


--[[
	@desc	副本Cell的创建
	@para 	 hid
	@return CCTableViewCell
--]]
function createHeroCell( hid )
	local tCell = CCTableViewCell:create()
	print("hid=====", hid)
	hid = tonumber(hid)



	local headIconName = "images/formation/" .. "testhead.png"
	--更换底框 by 张梓航
	local potentialBgName = "images/formation/potential/officer_11.png"
	
	if(hid == 0) then
		headIconName = "images/formation/potential/newadd.png"
	elseif(hid == -2)then
		-- 小伙伴
		headIconName = "images/formation/littlef_icon.png"
	elseif(hid == -3)then
		-- 属性小伙伴
		headIconName = "images/formation/second_icon.png"
	else
		headIconName = "images/formation/potential/newlock.png"
	end

	-- local levelLabel = nil
	if (hid >0) then
		local heroRemoteInfo = nil
		local allHeros = HeroModel.getAllHeroes()

		for t_hid, t_hero in pairs(allHeros) do
			if( tonumber(t_hid) ==  hid) then
				heroRemoteInfo = t_hero
				break
			end
		end
		local status = require ("db/DB_Heroes")
		local heroLocalInfo = DB_Heroes.getDataById(tonumber(heroRemoteInfo.htid))

		potentialBgName = POTENTIAL_Base .. heroLocalInfo.potential .. ".png"
		if HeroModel.isNecessaryHero(heroRemoteInfo.htid) and UserModel.getDressIdByPos(1) ~= nil then
			local dressInfo = ItemUtil.getItemById(UserModel.getDressIdByPos(1))
			if(dressInfo.changeHeadIcon ~= nil)then
				headIconName = "images/base/hero/head_icon/" .. ItemSprite.getStringByFashionString(dressInfo.changeHeadIcon)
			else
				headIconName = "images/base/hero/head_icon/" .. heroLocalInfo.head_icon_id
			end
		else
			headIconName = "images/base/hero/head_icon/" .. heroLocalInfo.head_icon_id
		end
	end
	-- 品质框
	local potentialBg = CCSprite:create(potentialBgName)
	tCell:addChild(potentialBg, 1, 10001)

	tCell:setContentSize(potentialBg:getContentSize())
	-- 头像
	local  headIcon = CCSprite:create(headIconName)



	-- added by zhz 增加主角因VIP升级 ，这里没有没有调用 HeroUtis.getHeroIconByHTID()的方法，自能手动加特效了。
	require "db/DB_Normal_config"
	require "script/model/user/UserModel"
	local vip= UserModel.getVipLevel()
	local effectNeedVipLevel = DB_Normal_config.getDataById(1).vipEffect
	if( hid>0 and  HeroModel.isNecessaryHeroByHid(hid) and vip>= effectNeedVipLevel ) then
		 local img_path=  CCString:create("images/base/effect/txlz/txlz")
        local openEffect=  CCLayerSprite:layerSpriteWithNameAndCount(img_path:getCString(), -1,CCString:create(""))
        openEffect:setPosition(headIcon:getContentSize().width/2,headIcon:getContentSize().width*0.5)
        openEffect:setAnchorPoint(ccp(0.5,0.5))
        headIcon:addChild(openEffect,1)
	end

	if hid == 0 then
		local arrActions_2 = CCArray:create()
		arrActions_2:addObject(CCFadeOut:create(1))
		arrActions_2:addObject(CCFadeIn:create(1))
		local sequence_2 = CCSequence:create(arrActions_2)
		local action_2 = CCRepeatForever:create(sequence_2)
		headIcon:runAction(action_2)
	end
	if hid == -1 then
		require "script/ui/formation/FormationUtil"
		local nextLv = FormationUtil.nextOpendFormationNumAndLevel()
		local tishi = CCRenderLabel:create( tostring(nextLv) , g_sFontPangWa, 28, 1, ccc3(0x00, 0x00, 0x00), type_stroke)
		tishi:setColor(ccc3(0x45, 0xe7, 0xf1))
		tishi:setAnchorPoint(ccp(0.5,0.5))
		tishi:setPosition(ccp(headIcon:getContentSize().width*0.5,headIcon:getContentSize().height*0.5+10))
		local tishiSprite = CCSprite:create("images/formation/potential/jikaifang.png")
		tishiSprite:setAnchorPoint(ccp(0.5,0))
		tishiSprite:setPosition(ccp(headIcon:getContentSize().width*0.5,-5))
		headIcon:addChild(tishiSprite,3)
		headIcon:addChild(tishi,3)
	end
	headIcon:setAnchorPoint(ccp(0.5,0.5))
	headIcon:setPosition(ccp(potentialBg:getContentSize().width/2, potentialBg:getContentSize().height/2))
	potentialBg:addChild(headIcon)

	--高亮
	local seletedCellBg = CCSprite:create(HighLight)
	seletedCellBg:setAnchorPoint(ccp(0.5,0.5))
	seletedCellBg:setPosition(ccp(potentialBg:getContentSize().width/2, potentialBg:getContentSize().height/2))
	potentialBg:addChild(seletedCellBg, 1, 10002)
	seletedCellBg:setVisible(false)

	return tCell
end

function setSeletedCellBgVisible( tCell, isVisable )
	if(isVisable == nil) then
		isVisable = false
	end	
	if (tCell ~= nil) then
		tCell = tolua.cast(tCell, "CCTableViewCell")
		if(tCell ~=nil ) then
			local potentialBg = tolua.cast(tCell:getChildByTag(10001), "CCSprite")
			if( potentialBg) then
				local seletedCellBg = tolua.cast(potentialBg:getChildByTag(10002), "CCSprite")
				seletedCellBg:setVisible(isVisable)
			end
		end
	end
end
