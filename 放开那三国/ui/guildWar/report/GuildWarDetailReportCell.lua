-- FileName: GuildWarDetailReportCell.lua 
-- Author: licong 
-- Date: 15-1-26 
-- Purpose: 跨服军团战晋级赛查看两个军团直接的战报 cell


module("GuildWarDetailReportCell", package.seeall)

require "script/ui/guildWar/GuildWarDef"
require "script/ui/hero/HeroPublicLua"

--[[
	@des 	:创建预计出战cell
	@param 	:p_dataTab1:左边军团数据，p_dataTab2:右边军团数据
	@return :cell CCSizeMake(570, 113)
--]]
function  createCellOne( p_dataTab1, p_dataTab2)
	local tCell = CCTableViewCell:create()

	if(p_dataTab1 ~= nil)then
		-- 玩家1 
		local fightOrder1 = LuaCC.createSpriteOfNumbers("images/main/vip", tostring(p_dataTab1.index), 10)
		fightOrder1:setAnchorPoint(ccp(0.5,0.5))
	    fightOrder1:setPosition(ccp(45,55))
	    tCell:addChild(fightOrder1)

	    -- 玩家1的名字
	    local playerName1 = CCRenderLabel:create(p_dataTab1.uname ,g_sFontName,21,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		playerName1:setAnchorPoint(ccp(0.5,0.5))
		playerName1:setPosition(ccp(174,81))
		tCell:addChild(playerName1)
		local starLv = GuildWarReportData.getHeroQuality(p_dataTab1.htid)
		local nameColor = HeroPublicLua.getCCColorByStarLevel(starLv)
		playerName1:setColor(nameColor)

		-- 玩家1战斗力
		local fightSp1 = CCSprite:create("images/lord_war/fight_bg.png")
		fightSp1:setAnchorPoint(ccp(0.5,0.5))
		fightSp1:setPosition(ccp(174, 45))
		tCell:addChild(fightSp1)
		local fightLable1 = CCRenderLabel:create(tonumber(p_dataTab1.fight_force), g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    fightLable1:setColor(ccc3(0xff,0x00,0x00))
	    fightLable1:setAnchorPoint(ccp(0,0.5))
	    fightLable1:setPosition(ccp(34, fightSp1:getContentSize().height*0.5))
	   	fightSp1:addChild(fightLable1)
	end

	if(p_dataTab2 ~= nil)then
	   	-- 玩家2
		local fightOrder2 = LuaCC.createSpriteOfNumbers("images/main/vip", tostring(p_dataTab2.index), 10)
		fightOrder2:setAnchorPoint(ccp(0.5,0.5))
	    fightOrder2:setPosition(ccp(322,55))
	    tCell:addChild(fightOrder2)

	    -- 玩家2的名字
	    local playerName2 = CCRenderLabel:create(p_dataTab2.uname ,g_sFontName,21,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		playerName2:setAnchorPoint(ccp(0.5,0.5))
		playerName2:setPosition(ccp(446,81))
		tCell:addChild(playerName2)
		local starLv = GuildWarReportData.getHeroQuality(p_dataTab2.htid)
		local nameColor = HeroPublicLua.getCCColorByStarLevel(starLv)
		playerName2:setColor(nameColor)

		-- 玩家2战斗力
		local fightSp2 = CCSprite:create("images/lord_war/fight_bg.png")
		fightSp2:setAnchorPoint(ccp(0.5,0.5))
		fightSp2:setPosition(ccp(446, 45))
		tCell:addChild(fightSp2)
		local fightLable2 = CCRenderLabel:create(tonumber(p_dataTab2.fight_force), g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    fightLable2:setColor(ccc3(0xff,0x00,0x00))
	    fightLable2:setAnchorPoint(ccp(0,0.5))
	    fightLable2:setPosition(ccp(34, fightSp2:getContentSize().height*0.5))
	   	fightSp2:addChild(fightLable2)
	end

	-- 分割线
	local line = CCScale9Sprite:create("images/common/line02.png")
	line:setContentSize(CCSizeMake(551,4))
    line:setAnchorPoint(ccp(0.5, 0))
    line:setPosition(ccp(285,0))
    tCell:addChild(line)
    
	return tCell
end


--[[
	@des 	:创建对战结果cell
	@param 	:p_dataTab:战报数据
	@return :cell
--]]
function  createCellTwo( p_dataTab, p_menu_priority )
	-- print("p_dataTab")
	-- print_t(p_dataTab)
	local tCell = CCTableViewCell:create()

	-- 玩家1 
	local fightOrder1 = LuaCC.createSpriteOfNumbers("images/main/vip", tostring(p_dataTab.index), 10)
	fightOrder1:setAnchorPoint(ccp(0.5,0.5))
    fightOrder1:setPosition(ccp(26,55))
    tCell:addChild(fightOrder1)

	if( p_dataTab.player1 ~= nil )then
		-- 玩家1连胜次数
	    if( p_dataTab.player1.max_win ~= nil and tonumber(p_dataTab.player1.max_win) >= GuildWarDef.DEFAULT_WIN_NUM )then
			local lianSp1 = CCSprite:create("images/guild_war/liansheng.png")
			lianSp1:setAnchorPoint(ccp(0,0.5))
			lianSp1:setPosition(ccp(43, 100))
			tCell:addChild(lianSp1)
			local lianLable1 = CCRenderLabel:create( p_dataTab.player1.max_win .. GetLocalizeStringBy("lic_1484"), g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		    lianLable1:setColor(ccc3(0xff, 0xf6, 0x00))
		    lianLable1:setAnchorPoint(ccp(0.5,0.5))
		    lianLable1:setPosition(ccp(lianSp1:getContentSize().width*0.5, lianSp1:getContentSize().height*0.5))
		   	lianSp1:addChild(lianLable1)
		end
		
	    -- 玩家1的名字
	    local playerName1 = CCRenderLabel:create(p_dataTab.player1.uname ,g_sFontName,21,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		playerName1:setAnchorPoint(ccp(0.5,0.5))
		playerName1:setPosition(ccp(109,81))
		tCell:addChild(playerName1)
		local starLv1 = GuildWarReportData.getHeroQuality(p_dataTab.player1.htid)
		print("starLv1",starLv1,"htid1",p_dataTab.player1.htid)
		local nameColor1 = HeroPublicLua.getCCColorByStarLevel(starLv1)
		playerName1:setColor(nameColor1)

		-- 玩家1战斗力
		local fightSp1 = CCSprite:create("images/lord_war/fight_bg.png")
		fightSp1:setAnchorPoint(ccp(0.5,0.5))
		fightSp1:setPosition(ccp(129, 45))
		tCell:addChild(fightSp1)
		local fightLable1 = CCRenderLabel:create(tonumber(p_dataTab.player1.fight_force), g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    fightLable1:setColor(ccc3(0xff,0x00,0x00))
	    fightLable1:setAnchorPoint(ccp(0,0.5))
	    fightLable1:setPosition(ccp(34, fightSp1:getContentSize().height*0.5))
	   	fightSp1:addChild(fightLable1)

	   	if(p_dataTab.player1.isWin ~= nil and p_dataTab.player1.isWin ~= GuildWarDef.DRAW )then
		   	--胜负图1
			local fileStr = nil
			if( tonumber(p_dataTab.player1.isWin) == GuildWarDef.VICTORY ) then
				--胜利
				fileStr = "images/olympic/win.png"
			else
				--失败
				fileStr = "images/olympic/lost.png"
			end
			local resultSprite1 = CCSprite:create(fileStr)
			resultSprite1:setAnchorPoint(ccp(0.5,0.5))
			resultSprite1:setPosition(ccp(211,35))
			tCell:addChild(resultSprite1)
		end
	end

	if(p_dataTab.player1 ~= nil and p_dataTab.player2 ~= nil)then
		-- 中间大VS
		local vsSp = CCSprite:create("images/arena/vs.png")
	    vsSp:setAnchorPoint(ccp(0.5,0.5))
	    vsSp:setPosition(ccp(267,55))
	    tCell:addChild(vsSp)

		-- 平局 显示
	    if(p_dataTab.player1.isWin ~= nil and p_dataTab.player1.isWin == GuildWarDef.DRAW 
	    	and p_dataTab.player2.isWin ~= nil and p_dataTab.player2.isWin == GuildWarDef.DRAW)then
		    local pingLable = CCRenderLabel:create(GetLocalizeStringBy("lic_1494"), g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		    pingLable:setColor(ccc3(0x00,0xff,0x18))
		    pingLable:setAnchorPoint(ccp(0.5,1))
		    pingLable:setPosition(ccp(267, 113))
		   	tCell:addChild(pingLable)
		end
	end

    if( p_dataTab.player2 ~= nil )then
	    -- 玩家2连胜次数
	    if( p_dataTab.player2.max_win ~= nil and tonumber(p_dataTab.player2.max_win) >= GuildWarDef.DEFAULT_WIN_NUM )then
			local lianSp1 = CCSprite:create("images/guild_war/liansheng.png")
			lianSp1:setAnchorPoint(ccp(0,0.5))
			lianSp1:setPosition(ccp(312, 100))
			tCell:addChild(lianSp1)
			local lianLable1 = CCRenderLabel:create( p_dataTab.player2.max_win .. GetLocalizeStringBy("lic_1484"), g_sFontName, 18, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		    lianLable1:setColor(ccc3(0xff, 0xf6, 0x00))
		    lianLable1:setAnchorPoint(ccp(0.5,0.5))
		    lianLable1:setPosition(ccp(lianSp1:getContentSize().width*0.5, lianSp1:getContentSize().height*0.5))
		   	lianSp1:addChild(lianLable1)
		end
	    -- 玩家2的名字
	    local playerName2 = CCRenderLabel:create(p_dataTab.player2.uname ,g_sFontName,21,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		playerName2:setAnchorPoint(ccp(0,0.5))
		playerName2:setPosition(ccp(314,81))
		tCell:addChild(playerName2)
		local starLv2 = GuildWarReportData.getHeroQuality(p_dataTab.player2.htid)
		print("starLv2",starLv2,"htid2",p_dataTab.player2.htid)
		local nameColor2 = HeroPublicLua.getCCColorByStarLevel(starLv2)
		playerName2:setColor(nameColor2)

		-- 玩家2战斗力
		local fightSp2 = CCSprite:create("images/lord_war/fight_bg.png")
		fightSp2:setAnchorPoint(ccp(0,0.5))
		fightSp2:setPosition(ccp(314, 45))
		tCell:addChild(fightSp2)
		local fightLable2 = CCRenderLabel:create(tonumber(p_dataTab.player2.fight_force), g_sFontName, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	    fightLable2:setColor(ccc3(0xff,0x00,0x00))
	    fightLable2:setAnchorPoint(ccp(0,0.5))
	    fightLable2:setPosition(ccp(34, fightSp2:getContentSize().height*0.5))
	   	fightSp2:addChild(fightLable2)

	   	if(p_dataTab.player2.isWin ~= nil and p_dataTab.player1.isWin ~= GuildWarDef.DRAW )then
		   	--胜负图2
			local fileStr = nil
			if( tonumber(p_dataTab.player2.isWin) == GuildWarDef.VICTORY) then
				--胜利
				fileStr = "images/olympic/win.png"
			else
				--失败
				fileStr = "images/olympic/lost.png"
			end
			local resultSprite2 = CCSprite:create(fileStr)
			resultSprite2:setAnchorPoint(ccp(0.5,0.5))
			resultSprite2:setPosition(ccp(473,35))
			tCell:addChild(resultSprite2)
		end
	end

	if(p_dataTab.player1 ~= nil and p_dataTab.player2 ~= nil)then
		-- 查看战报按钮
		local menu = CCMenu:create()
		menu:setAnchorPoint(ccp(0,0))
		menu:setPosition(ccp(0,0))
		local menu_priority = p_menu_priority or -602
		menu:setTouchPriority(menu_priority)
		tCell:addChild(menu)

		local checkMenuItem = CCMenuItemImage:create("images/battle/battlefield_report/look_n.png","images/battle/battlefield_report/look_h.png")
		checkMenuItem:setAnchorPoint(ccp(0.5,0.5))
		checkMenuItem:setPosition(ccp(534,55))
		checkMenuItem:registerScriptTapHandler(checkCallBack)
		menu:addChild(checkMenuItem,1,1)
		checkMenuItem:setUserObject(CCString:create(p_dataTab.brid))
	end

	-- 分割线
	local line = CCScale9Sprite:create("images/common/line02.png")
	line:setContentSize(CCSizeMake(551,4))
    line:setAnchorPoint(ccp(0.5, 0))
    line:setPosition(ccp(285,0))
    tCell:addChild(line)

	return tCell
end


--[[
	@des 	:查看战报回调
	@param  :tag值
--]]
function checkCallBack(tag, itemBtn)
	local userObject = tolua.cast(itemBtn:getUserObject(), "CCString")
	local brid = userObject:getCString()

	require "script/battle/BattleUtil"
	BattleUtil.playerBattleReportById(brid,nil,nil,false)
end








































