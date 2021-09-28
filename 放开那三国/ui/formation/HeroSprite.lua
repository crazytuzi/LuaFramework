-- Filename：	HeroSprite.lua
-- Author：		Cheng Liang
-- Date：		2013-7-9
-- Purpose：		阵型中英雄Sprite

module("HeroSprite", package.seeall)



require "script/model/utils/HeroUtil"
require "script/ui/formation/FormationUtil"

--[[
	@desc	创建
	@para 	
	@return CCSprite
--]]
function createHeroSprite(hero_data, f_pos)
	hero_data = tonumber(hero_data)
	local heroBg = CCSprite:create()   --("images/formation/changeformation/herobg.png")
	heroBg:setContentSize(CCSizeMake(124, 180))
	
	-- local heroBg = CCSprite:create( "images/base/hero/body_img/" .. heroAllInfo.localInfo.body_img_id)
	local heroBgSize = heroBg:getContentSize()

	if(hero_data >0) then
		local heroAllInfo = HeroUtil.getHeroInfoByHid(hero_data)
		-- 卡牌
		-- local cardIcon = CCSprite:create("images/base/hero/action_module/" .. heroAllInfo.localInfo.action_module_id)
		local dressId = nil
		if HeroModel.isNecessaryHero(heroAllInfo.htid) then
			dressId = UserModel.getDressIdByPos("1")
		end
		require "script/battle/BattleCardUtil"
		local cardIcon = BattleCardUtil.getFormationPlayerCard(hero_data, false, heroAllInfo.htid, dressId)
		cardIcon:setAnchorPoint(ccp(0.5, 0.5))
		cardIcon:setPosition(ccp(heroBgSize.width/2, heroBgSize.height*0.6))
		-- cardIcon:setScale(0.4)
		
		heroBg:addChild(cardIcon)

		-- lv
		local lvSp = CCSprite:create("images/common/lv.png")
		lvSp:setAnchorPoint(ccp(0,1))
		heroBg:addChild(lvSp)

		-- 等级
		local levelLabel = CCRenderLabel:create( heroAllInfo.level , g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    levelLabel:setColor(ccc3(0xff, 0xf6, 0x00))
	    heroBg:addChild(levelLabel)
	    local sPositionX = (heroBgSize.width -levelLabel:getContentSize().width - lvSp:getContentSize().width)  * 0.5
	    lvSp:setPosition(ccp(sPositionX, heroBgSize.height*0.13))
	    levelLabel:setPosition(ccp( sPositionX + lvSp:getContentSize().width, heroBgSize.height*0.13))

	    require "db/DB_Heroes"
	    require "script/model/user/UserModel"
	    -- print("咕嘿嘿黑")
	    -- print_t(heroAllInfo)
	    local heroName
	    if HeroModel.isNecessaryHero(heroAllInfo.htid) then
	    	local cutName = HeroUtil.getOriginalName(UserModel.getUserName())
	    	heroName = CCRenderLabel:create(cutName,g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_stroke)
	    else
	    	require "script/ui/redcarddestiny/RedCardDestinyData"
	    	heroName = CCRenderLabel:create(HeroModel.getHeroName(heroAllInfo), g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_stroke)
	    end
	    heroName:setColor(HeroPublicLua.getCCColorByStarLevel(DB_Heroes.getDataById(tonumber(heroAllInfo.htid)).potential))

	    local envolveNum = CCRenderLabel:create("",g_sFontPangWa,21,1,ccc3(0x00,0x00,0x00),type_stroke)
	    local heroModelInfo = HeroModel.getHeroByHid(heroAllInfo.hid)
	    if tonumber(heroModelInfo.evolve_level) ~= 0 then
	    	if tonumber(DB_Heroes.getDataById(tonumber(heroAllInfo.htid)).potential) <= 5 then 
	    		envolveNum:setString("+" .. heroModelInfo.evolve_level)
	    	else
	    		envolveNum:setString(heroModelInfo.evolve_level .. GetLocalizeStringBy("zzh_1159"))
	    	end
	    end
	    envolveNum:setColor(ccc3(0x76,0xfc,0x06))

	    -- heroName:setAnchorPoint(ccp(0.5,0))
	    -- heroName:setPosition(ccp(heroBgSize.width/2,-heroBgSize.height*0.13))
	    -- heroBg:addChild(heroName)

	    require "script/utils/BaseUI"
	    local underString = BaseUI.createHorizontalNode({heroName, envolveNum})
	    underString:setAnchorPoint(ccp(0.5,0))
	    underString:setPosition(ccp(heroBgSize.width/2,-heroBgSize.height*0.13))
	    heroBg:addChild(underString)

	elseif (hero_data < 0) then 
		local cardIcon = CCSprite:create("images/formation/potential/lock.png")
		cardIcon:setAnchorPoint(ccp(0.5, 0.5))
		cardIcon:setPosition(ccp(heroBgSize.width/2, heroBgSize.height*0.6))
		heroBg:addChild(cardIcon)
		local nextPos, nextLevel = FormationUtil.nextOpendPosAndLevel()
		print("nextPos==", nextPos, nextLevel)
		if (tonumber(f_pos) == tonumber(nextPos)) then
			
			local tipLabel = CCRenderLabel:create( FormationUtil.getOpenLevelByPosition(f_pos) .. GetLocalizeStringBy("key_1526") , g_sFontName, 24, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		    -- tipLabel:setSourceAndTargetColor(ccc3( 0xff, 0xf5, 0x83), ccc3( 0xff, 0xde, 0x00));
		    tipLabel:setColor(ccc3(0xff, 0xff, 0xff))
		    tipLabel:setPosition(ccp( (heroBgSize.width -tipLabel:getContentSize().width)  * 0.5, heroBgSize.height*0.4))
		    heroBg:addChild(tipLabel)
		end
	end
	
	return heroBg
end

--[[
	@desc	创建
	@para 	
	@return CCSprite
--]]
function createHeroSpriteByHeroData(hero_data)
	local heroBg = CCSprite:create() 
	heroBg:setContentSize(CCSizeMake(124, 180))
	local heroBgSize = heroBg:getContentSize()
	local heroAllInfo = hero_data
	-- 卡牌
	-- local cardIcon = CCSprite:create("images/base/hero/action_module/" .. heroAllInfo.localInfo.action_module_id)
	require "script/battle/BattleCardUtil"
	hero_data.dress = hero_data.dress or {}
	local cardIcon = BattleCardUtil.getFormationPlayerCardByHeroData(hero_data, false, hero_data.htid, hero_data.dress["1"])
	cardIcon:setAnchorPoint(ccp(0.5, 0.5))
	cardIcon:setPosition(ccp(heroBgSize.width/2, heroBgSize.height*0.6))
	-- cardIcon:setScale(0.4)
	
	heroBg:addChild(cardIcon)

	-- lv
	local lvSp = CCSprite:create("images/common/lv.png")
	lvSp:setAnchorPoint(ccp(0,1))
	heroBg:addChild(lvSp)

	-- 等级
	local levelLabel = CCRenderLabel:create( heroAllInfo.level , g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    levelLabel:setColor(ccc3(0xff, 0xf6, 0x00))
    heroBg:addChild(levelLabel)
    local sPositionX = (heroBgSize.width -levelLabel:getContentSize().width - lvSp:getContentSize().width)  * 0.5
    lvSp:setPosition(ccp(sPositionX, heroBgSize.height*0.13))
    levelLabel:setPosition(ccp( sPositionX + lvSp:getContentSize().width, heroBgSize.height*0.13))

    require "db/DB_Heroes"
    require "script/model/user/UserModel"
    -- print("咕嘿嘿黑")
    -- print_t(heroAllInfo)
    local name = nil
    if hero_data.name ~= nil then
    	name = hero_data.name
    else
    	name = DB_Heroes.getDataById(tonumber(hero_data.htid)).name
    end
    local heroName = CCRenderLabel:create(name, g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_stroke)
    heroName:setColor(HeroPublicLua.getCCColorByStarLevel(DB_Heroes.getDataById(tonumber(hero_data.htid)).potential))

    local envolveNum = CCRenderLabel:create("",g_sFontPangWa,21,1,ccc3(0x00,0x00,0x00),type_stroke)
    local heroModelInfo = hero_data
    if tonumber(heroModelInfo.evolve_level) ~= 0 then
    	if tonumber(DB_Heroes.getDataById(tonumber(hero_data.htid)).potential) <= 5 then 
    		envolveNum:setString("+" .. heroModelInfo.evolve_level)
    	else
    		envolveNum:setString(heroModelInfo.evolve_level .. GetLocalizeStringBy("zzh_1159"))
    	end
    end
    envolveNum:setColor(ccc3(0x76,0xfc,0x06))

    -- heroName:setAnchorPoint(ccp(0.5,0))
    -- heroName:setPosition(ccp(heroBgSize.width/2,-heroBgSize.height*0.13))
    -- heroBg:addChild(heroName)

    require "script/utils/BaseUI"
    local underString = BaseUI.createHorizontalNode({heroName, envolveNum})
    underString:setAnchorPoint(ccp(0.5,0))
    underString:setPosition(ccp(heroBgSize.width/2,-heroBgSize.height*0.13))
    heroBg:addChild(underString)
	
	return heroBg
end
