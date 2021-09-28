
local offlineMine = function(Buff)	
	if Buff then
		local params = {}
		local retTable = g_msgHandlerInst:convertBufferToTable("DigOffMineRet", Buff)
		params.start = retTable.logout
		params.offTime = retTable.digTime
		params.exp = retTable.exp

		params.awardTab = {}
		local award = retTable.reward
		local tabNum = 0
		if award then
			tabNum = tablenums(award)
		end
		for i = 1, tabNum do
			local temp = {}
			temp.itemID = award[i].itemID
			temp.num = award[i].count
			temp.boxType = award[i].type
			params.awardTab[i] = temp
		end
	    local acLayer = require( "src/layers/mine/offlineMineLog").new(params)
	    getRunScene():addChild(acLayer,200)

		  -- Manimation:transit(
		  -- {
		  --   ref = getRunScene(),
		  --   node = acLayer,
		  --   curve = "-",
		  --   sp = cc.p(display.width/2, display.height/2),
		  --   zOrder = 250,
		  --   swallow = true,
		  -- })
	end
end

-- local onNotifyMine = function(onNotifyMine)
-- 	cclog("onNotifyMine")
-- 	G_OFFLINE_DATA.couldGotoNext = true

-- 	DATA_Battle:setRedData("LXWK", G_OFFLINE_DATA.couldGotoNext )
	
-- 	-- if TOPBTNMG then TOPBTNMG:showRedMG( "Mining" , G_OFFLINE_DATA.couldGotoNext ) end
-- 	-- if __TOPS[ "offline" ] and __TOPS[ "offline" ].redFlag then __TOPS[ "offline" ].redFlag:setVisible( G_OFFLINE_DATA.couldGotoNext ) end
	
-- 	-- if G_MAINSCENE then
-- 	-- 	G_MAINSCENE:refreshActivityReddot()
-- 	-- 	if not minelog_menu and G_MAINSCENE.map_layer and (not G_MAINSCENE.map_layer.isMine) then
-- 	-- 	    minelog_menu = createTouchItem(G_MAINSCENE,"res/mainui/minelog.png",cc.p(g_scrCenter.x-100,235),__GoToMineLog,true)
-- 	-- 		minelog_menu:setLocalZOrder(8)
-- 	-- 		--createSprite(minelog_menu,"res/mainui/minelog.png",cc.p(30,30))
-- 	-- 	end
-- 	-- end
-- end
g_msgHandlerInst:registerMsgHandler(DIGMINE_SC_OFFMINE_RET,offlineMine)
