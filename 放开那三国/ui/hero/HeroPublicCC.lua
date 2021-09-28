-- Filename: HeroPublicCC.lua
-- Author: fang
-- Date: 2013-08-05
-- Purpose: 该文件用于: 武将系统有关cocos2d-x公用方法


module("HeroPublicCC", package.seeall)

-- CCSprite类型
m_ksTypeSprite=1
-- CCLabel类型
m_ksTypeLabel=2
-- CCRenderLabel类型
m_ksTypeRenderLabel=3

function createTitleWithLabelAndMenuItems(tSprite, tLabel, tMenuItems)
	require "script/libs/LuaCCSprite"
	local sprite = LuaCCSprite.createSpriteWithRenderLabel(tSprite.file, tLabel)

	return sprite
end

function createStars(filename, count, start_position, space)
	local stars = CCSprite:create(filename)
	local size = stars:getContentSize()
	stars:setPosition(start_position)
	local x = size.width + space
	for i=2, count do
		local tmp = CCSprite:create(filename)
		tmp:setPosition(ccp(x, 0))
		x = x + size.width + space
		stars:addChild(tmp)
	end

	return stars
end

-- 创建进阶等级FadeIn, FadeOut效果
-- tParam, 需要包含武将进阶次数
-- pCsParent: 需要加进阶次数动画的父节点
function createEvovleLevelSprite(tParam, pCsParent)
	local evolve_level = tParam.evolve_level or 0
	if tonumber(evolve_level) < 1 then
		return
	end

	local tEvolveSize = {width=0, height=0}
	local tElements = {
 		{ctype=LuaCC.m_ksTypeSprite, file="images/hero/transfer/numbers/add.png", hOffset=0},
 	}
 	local db_hero = HeroUtil.getHeroLocalInfoByHtid( tonumber(tParam.htid) )
	if db_hero.star_lv >=6 then
		tElements = { }
	end
 	local sEvolveLevel = tostring(tParam.evolve_level)
	for i=1, #sEvolveLevel do
	 	local sImageFile = "images/hero/transfer/numbers/"..(string.byte(sEvolveLevel, i)-48)..".png"
		table.insert(tElements, {ctype=LuaCC.m_ksTypeSprite, file=sImageFile, hOffset=0} )
	end

	--橙卡显示“？阶”
	if db_hero.star_lv >=6 then
		table.insert(tElements,{ctype=LuaCC.m_ksTypeRenderLabel, text=GetLocalizeStringBy("zz_100"), strokeSize=1, color = ccc3(0x00,0xff,0x00), fontname=g_sFontPangWa, strokeColor=ccc3(0x00,0x00,0x00), vOffset=32})
	end

	require "script/libs/LuaCC"
	tObjs = LuaCC.createCCNodesOnHorizontalLine(tElements)
	tObjs[1]:setAnchorPoint(ccp(0, 0))
	for i=1, #tObjs do
		tEvolveSize.width = tEvolveSize.width + tObjs[i]:getContentSize().width
	end
	local tParentSize = pCsParent:getContentSize()

	tObjs[1]:setPosition((tParentSize.width- tEvolveSize.width)/2, -4)
	-- for i=1, #tObjs do
	-- 	tObjs[i]:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCFadeIn:create(1), CCFadeOut:create(1))))
	-- end

	return tObjs
end

-- 创建武将头像
-- 返回CCMenuItem对象
function createHeroHeadIcon(tParam, dressId)
	local db_hero
	local tHero = tParam
	if tParam.db_hero then
		db_hero = tParam.db_hero
	else
		require "script/model/hero/HeroModel"
		tHero = HeroModel.getHeroByHid(tHero.hid)
		db_hero = DB_Heroes.getDataById(tHero.htid)
	end
	require "script/model/utils/HeroUtil"
	-- 是不是主角

	local csQuality = HeroUtil.getHeroIconByHTID(tHero.htid, dressId,nil ,UserModel.getVipLevel(), tParam.turned_id)
	local csQualityLighted = HeroUtil.getHeroIconByHTID(tHero.htid, dressId,nil, UserModel.getVipLevel(), tParam.turned_id)
	local csFrame = CCSprite:create("images/hero/quality/highlighted.png")

	csFrame:setAnchorPoint(ccp(0.5, 0.5))
	csFrame:setPosition(csQualityLighted:getContentSize().width/2, csQualityLighted:getContentSize().height/2)
	csQualityLighted:addChild(csFrame)

	local csHeadIconBg = CCMenuItemSprite:create(csQuality, csQualityLighted)
	csHeadIconBg:setPosition(ccp(14, 14))

	local tObjs=createEvovleLevelSprite(tHero, csHeadIconBg)
	if tObjs then
		csHeadIconBg:addChild(tObjs[1])
	end

	return csHeadIconBg
end

function createTableViewCell(tCellValue)
	local tag = -1
	local ccCell = CCTableViewCell:create()
	-- 背景
	local bgFile = tCellValue.bgFile or "images/hero/attr_bg.png"
	local cellBg = CCSprite:create(bgFile)
	cellBg:setAnchorPoint(ccp(0, 0))
	-- 背景精灵的tag
	tag = tCellValue.tag_bg or -1
	ccCell:addChild(cellBg, 1, tag)

	-- 武将所属国家
	local country = CCSprite:create(tCellValue.country_icon)
	country:setAnchorPoint(ccp(0, 0))
	country:setPosition(ccp(16, 105))
	cellBg:addChild(country)
	-- 武将等级
--	local lv = CCRenderLabel:create("Lv."..tCellValue.level, g_sFontName, 21, 1, ccc3(0xff, 0xf6, 0), type_stroke)
--	lv:setColor(ccc3(0x89, 0, 0x1a))
	local lv = CCLabelTTF:create("Lv."..tCellValue.level, g_sFontName, 20)
	lv:setAnchorPoint(ccp(0, 1))
	lv:setPosition(68, 135)
	lv:setColor(ccc3(0xff, 0xee, 0x3a))
	cellBg:addChild(lv)
	-- 武将名称
	local name = CCLabelTTF:create(tCellValue.name, g_sFontName, 22, CCSizeMake(136, 30), kCCTextAlignmentCenter)
	name:setPosition(139, 106)
	local cccQuality = HeroPublicLua.getCCColorByStarLevel(tCellValue.star_lv)
	name:setColor(cccQuality)
	cellBg:addChild(name)
	-- 星级
	local star_lv = createStars("images/hero/star.png", tCellValue.star_lv, ccp(290, 112), 4)
	cellBg:addChild(star_lv)
	-- 已上阵
	if tCellValue.isBusy then
		local being_front = CCSprite:create("images/hero/being_fronted.png")
		being_front:setPosition(ccp(534, 82))
		cellBg:addChild(being_front)
	end
	local head_icon_bg = createHeroHeadIcon(tCellValue)
	if tCellValue.cb_hero then
		head_icon_bg:registerScriptTapHandler(tCellValue.cb_hero)
	end
	-- cell中的菜单
	local menu_ms = CCMenu:create()
	-- 英雄头像的tag
	tag = tCellValue.tag_hero or -1
	menu_ms:addChild(head_icon_bg, 0, tag)
	-- cell中的菜单tag
	tag = tCellValue.tag_menu or -1
	cellBg:addChild(menu_ms, 0, tag)
	menu_ms:setPosition(ccp(0, 0))

	return ccCell
end


function createSpriteCardShow(htid, dressId, turnedId)
	print("htid = ", htid, "dressId=", dressId)
	require "db/DB_Heroes"
	local db_hero = DB_Heroes.getDataById(htid)
	-- 英雄品质: 1-2白，3绿，4蓝，5紫，6橙，7红
-- 品质背景
	local ccSpriteCardBG = CCSprite:create("images/common/hero_show/quality/"..db_hero.star_lv..".png")

-- 增加星星显示
	local tArrNodes = {}
	for i=1, db_hero.star_lv do
		tArrNodes[i] = {ctype=LuaCC.m_ksTypeSprite, file="images/hero/star.png", hOffset=1, }
	end
	local tObjs = LuaCC.createCCNodesOnHorizontalLine(tArrNodes)
	tObjs[1]:setPosition(18, 18)
	ccSpriteCardBG:addChild(tObjs[1])
-- 所属国家图标
	require "script/model/hero/HeroModel"
	local country_icon = HeroModel.getLargeCiconByCidAndlevel(db_hero.country, db_hero.star_lv)
	local ccSpriteCountry = CCSprite:create(country_icon)
	ccSpriteCountry:setPosition(ccp(242, 4))
	ccSpriteCardBG:addChild(ccSpriteCountry)	
-- 角色展示
	local sex = HeroModel.getSex(htid)
	local image_file = HeroUtil.getHeroBodyImgByHTID(htid, dressId, sex, turnedId)--"images/base/hero/body_img/"..db_hero.body_img_id
	if(dressId and tonumber(dressId) > 0) then
		require "db/DB_Item_dress"
		require "script/model/utils/HeroUtil"
		local dressInfo = DB_Item_dress.getDataById(dressId)
		local genderId = HeroModel.getSex(htid)

		local dressImg =  HeroUtil.getStringByFashionString(dressInfo.changeBodyImg, genderId)
		if(dressImg) then
			image_file = "images/base/hero/body_img/" .. dressImg
		end
	end
	local ccSpriteCardShow = CCSprite:create(image_file)
	-- local yOffset = 0
	-- if db_hero.body_img_id == "shi_jiang_zhangbao.png" then
	-- 	yOffset = 177
	-- elseif db_hero.body_img_id == "shi_jiang_caocao.png" then
	-- 	yOffset = 32
	-- end

	local yOffset = getYOffset(db_hero.body_img_id)
	-- 全身像偏移量
	local offset = HeroUtil.getHeroBodySpriteOffsetByHTID(htid, dressId, turnedId)
	ccSpriteCardShow:setPosition(ccSpriteCardBG:getContentSize().width/2, 62-yOffset-offset)
	ccSpriteCardShow:setAnchorPoint(ccp(0.5, 0))
-- 把角色展示图片放在背景上
	ccSpriteCardBG:addChild(ccSpriteCardShow)
	if db_hero.beauty_id then
		local csFamous = CCSprite:create("images/hero/famous.png")
		csFamous:setPosition(20, 70)
		ccSpriteCardBG:addChild(csFamous)
	end

	return ccSpriteCardBG
end

function getYOffset(p_imgString)
	local yOffset = 0
	if p_imgString == "shi_jiang_zhangbao.png" then
		yOffset = 177
	elseif p_imgString == "shi_jiang_caocao.png" then
		yOffset = 32
	end

	return yOffset
end

-- getCMISHeadIconByHtid
-- 通过武将htid，获得该武将的整体头像, 不带disabled状态，仅有normal和highlighted状态
-- in. htid: 武将的htid
-- out. 该武将的整体头像，是个CCMenuItemSprite对象
function getCMISHeadIconByHtid(htid)
	require "db/DB_Heroes"
	local db_hero = DB_Heroes.getDataById(htid)
	local sHeadIconImg="images/base/hero/head_icon/" .. db_hero.head_icon_id
	local sQualityBgImg="images/hero/quality/"..db_hero.star_lv .. ".png"
	local sQualityLightedImg="images/hero/quality/highlighted.png"

	local csQuality = CCSprite:create(sQualityBgImg)
	local csQualityLighted = CCSprite:create(sQualityBgImg)
	local csFrame = CCSprite:create(sQualityLightedImg)
	csFrame:setAnchorPoint(ccp(0.5, 0.5))
	csFrame:setPosition(csQualityLighted:getContentSize().width/2, csQualityLighted:getContentSize().height/2)
	csQualityLighted:addChild(csFrame)

	local cmisHeadIcon = CCMenuItemSprite:create(csQuality, csQualityLighted)
	-- 武将头像图标
	local csHeadIcon = CCSprite:create(sHeadIconImg)
	csHeadIcon:setPosition(ccp(9, 8))
	cmisHeadIcon:addChild(csHeadIcon)

	return cmisHeadIcon
end

-- getCMISHeadIconFullByHtid
-- 通过武将htid，获得该武将的整体头像，带disabled状态
-- in. htid: 武将的htid pNeedGray 是否需要置灰 (add by lgx 20160509 用于武将图鉴置灰也可以点)
-- out. 该武将的整体头像，是个CCMenuItemSprite对象
function getCMISHeadIconFullByHtid( htid, pNeedGray )
	require "db/DB_Heroes"
	local db_hero = DB_Heroes.getDataById(htid)
	local sHeadIconImg="images/base/hero/head_icon/" .. db_hero.head_icon_id
	local sQualityBgImg="images/hero/quality/"..db_hero.star_lv .. ".png"
	local sQualityLightedImg="images/hero/quality/highlighted.png"

	local csQuality = CCSprite:create(sQualityBgImg)
	local csQualityLighted = CCSprite:create(sQualityBgImg)
	local csFrame = CCSprite:create(sQualityLightedImg)
	csFrame:setAnchorPoint(ccp(0.5, 0.5))
	csFrame:setPosition(csQualityLighted:getContentSize().width/2, csQualityLighted:getContentSize().height/2)
	csQualityLighted:addChild(csFrame)

	-- 武将头像图标，普通状态
	local csHeadIconNormal = CCSprite:create(sHeadIconImg)
	csHeadIconNormal:setPosition(ccp(9, 8))
	csQuality:addChild(csHeadIconNormal)
	-- 武将头像图标，高亮状态
	local csHeadIconHighlighted = CCSprite:create(sHeadIconImg)
	csHeadIconHighlighted:setPosition(ccp(9, 8))
	csQualityLighted:addChild(csHeadIconHighlighted)
	-- 武将头像图标，灰色状态
	local csHeadIconGray = BTGraySprite:create(sHeadIconImg)
	csHeadIconGray:setPosition(ccp(9, 8))
	local csDisabled = BTGraySprite:create(sQualityBgImg)
	csDisabled:addChild(csHeadIconGray)
	local cmisHeadIcon = nil
	-- 根据是否要置灰创建按钮
	if (pNeedGray) then
		cmisHeadIcon = CCMenuItemSprite:create(csDisabled, csDisabled, csDisabled)
	else
		cmisHeadIcon = CCMenuItemSprite:create(csQuality, csQualityLighted, csDisabled)
	end

	return cmisHeadIcon
end

