local onTutoData = function(buffer)
	log("onTutoData")
	local t = g_msgHandlerInst:convertBufferToTable("GameConfigLoadGuardRetProtocol", buffer)
	local strTab = t.guardStep
	local tab = unserialize(strTab)
	dump(tab)
	-- dump(G_TUTO_DATA)
	-- dump(#G_TUTO_DATA == 0)
	-- print(debug.traceback())
	-- print("tab==",tab)
	if tab and type(tab) == "table" and G_TUTO_DATA then
		G_TUTO_DATA = getConfigItemByKey("TutoCfg")
		for k,v in pairs(tab) do
			local id = v
			-- print("newbie id ===",v)
			for i,v in ipairs(G_TUTO_DATA) do
				if v.q_id == id then
					v.q_state = TUTO_STATE_CLOSE
					log("close "..v.q_id)
				end
			end
		end
	end

	if G_TUTO_ON == false then
		G_TUTO_DATA = {}
	end
end

local onRecvMineTutoData = function(buffer)
	log("onRecvMineTutoData")
	local flag = buffer:popBool()

	if flag == false then
	 	startTimerAction(G_MAINSCENE, 2, false, function() 
	 		if G_NFTRIGGER_NODE then
				G_NFTRIGGER_NODE:unLockFunction(NF_SOUL)
				G_NFTRIGGER_NODE:check()
				G_NF_DATA.NF_SOUL = true
			end
	 	end)

	 	--开启离线矿洞的引导
		if G_TUTO_DATA then
			for k,v in pairs(G_TUTO_DATA) do
				if v.q_id == 29 then
					v.q_state = TUTO_STATE_OFF
				end
			end
		end
	else
		startTimerAction(G_MAINSCENE, 2, false, function() 
			if G_NFTRIGGER_NODE then
				G_NFTRIGGER_NODE:setFunc(NF_SOUL, true)
				G_NF_DATA.NF_SOUL = true
			end
		end)
	end
end

local onRecvShopData = function(buffer)
	log("onRecvShopData")
	local t = g_msgHandlerInst:convertBufferToTable("MysteryShopOpenProtocol", buffer)
	local flag = t.shopOpenState
	dump(flag)

	--神秘商店开启
	-- if flag == true then
	--  	startTimerAction(G_MAINSCENE, 2, false, function() 
	--  		if G_NFTRIGGER_NODE then
	-- 			G_NFTRIGGER_NODE:triggerById(NF_MYSTERY, false)
	-- 			G_NF_DATA.NF_MYSTERY = true
	-- 		end
	--  	end)
	-- else
	-- 	-- log("1111111111111111111111111111111111111")
	-- 	-- startTimerAction(G_MAINSCENE.baseNode, 2, false, function() 
	-- 	-- 	log("333333333333333333333333333333333333333")
	-- 	-- 	dump(G_MAINSCENE)
	-- 	-- 	if G_NFTRIGGER_NODE then
	-- 	-- 		log("22222222222222222222222222222222222222222")
	-- 	-- 		G_NFTRIGGER_NODE:setFunc(NF_MYSTERY, true)
	-- 			G_NF_DATA.NF_MYSTERY = true
	-- 	-- 	end
	-- 	-- end)
	-- end
end

g_msgHandlerInst:registerMsgHandler(GAMECONFIG_SC_LOADGUARD, onTutoData)
g_msgHandlerInst:registerMsgHandler(DIGMINE_SC_NOTIFYOPEN, onRecvMineTutoData)
g_msgHandlerInst:registerMsgHandler(TRADE_SC_MYST_OPEN, onRecvShopData)

