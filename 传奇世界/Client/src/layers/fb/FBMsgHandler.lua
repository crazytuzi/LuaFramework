-- local updateSceneBtn = function(isCreate)
-- 	if isCreate then
-- 		local openList = function() 
-- 			g_msgHandlerInst:sendNetDataByTableExEx(COPY_CS_GETPROREWARDLIST,"GetProRewardListProtocol",{})
-- 		end
-- 		if G_MAINSCENE and not G_MAINSCENE:getChildByTag(617) then
-- 			local btn = G_MAINSCENE:createActivityIconData({priority= 30, 
-- 	    							btnResName = "res/mainui/subbtns/fbsy.png",
-- 	    							btnResLab = game.getStrByKey("title_fb_rewards"),
-- 	    							btnCallBack = openList,
-- 	    							btnZorder = 200})
-- 			userInfo.fbPrizeBtn = btn
-- 			userInfo.fbPrizeBtn:setTag(617)
-- 		end
-- 	else
-- 		if G_MAINSCENE then
-- 			G_MAINSCENE:removeActivityIconData({btnResName = "res/mainui/subbtns/fbsy.png",})
-- 		end
-- 		if userInfo.fbPrizeBtn then
-- 			userInfo.fbPrizeBtn = nil
-- 		end
-- 	end
-- end

-- local notifyPrize = function(buff)
-- 	cclog("notifyPrize")
-- 	updateSceneBtn(true)
-- end

-- local getPrizeList = function(buff)
-- 	cclog("getPrizeList")

-- 	local retTable = g_msgHandlerInst:convertBufferToTable("GetProRewardListRetProtocol", buff)
-- 	local timeNum = retTable.rewardCount
	
-- 	local prizeItems={}
-- 	local tempAwardList = retTable.rewardList
-- 	for i=1,timeNum do
-- 	 	local time = tempAwardList[i].rewardTime
-- 	 	local fbNum = tempAwardList[i].rewardCount
-- 	 	local tempData = tempAwardList[i].rewardList

-- 	 	for j=1, fbNum do
-- 	 		local fbId = tempData[j].copyID
-- 	 		local objNum = tempData[j].prizeNum
-- 	 		local detailAward = tempData[j].info

-- 	 		local idx = #prizeItems+1
-- 	 		prizeItems[idx] = {time, fbId, objNum}
-- 	 		prizeItems[idx][4] = {}
-- 	 		for o=1, objNum do
-- 	 			prizeItems[idx][4][o] = {detailAward[o].rewardId, detailAward[o].rewardCount}
-- 	 		end
-- 	 	end
-- 	end
-- 	dump(prizeItems, "prizeItems")
-- 	table.sort( prizeItems, function(a,b) return a[2] <b[2] end)

-- 	if #prizeItems <= 0 then
-- 		updateSceneBtn(false)
-- 	end
	
-- 	local panel = getRunScene():getChildByTag(303)
-- 	if panel then
-- 		panel:reloadList(prizeItems)
-- 	else
-- 		getRunScene():addChild(require("src/layers/fb/FBPrizePanel").new(prizeItems),200,303)
-- 	end
-- end

-- -- 多人守卫自身队伍信息更新
-- local MultipleTeamData = function (luabuffer)
--     local proto = g_msgHandlerInst:convertBufferToTable("CopyGetTeamDataRetProtocol", luabuffer)

-- 	MultiData.m_currTeamId = proto.teamId;
	
-- 	MultiData.m_fbId = proto.copyId;

--     -- 发送给服务器时候已经自动取最后一位小数
-- 	MultiData.m_battleRequire = proto.needBattle/10000;
-- 	MultiData.m_teamMemNum = proto.memNum;
	
--     local tmpInfo = proto.info;
-- 	MultiData.m_teamMemInfo = {};
-- 	for i=1, MultiData.m_teamMemNum do
-- 		--动态id 名字 战斗力 是否准备 职业 性别
-- 		MultiData.m_teamMemInfo[i] = {tmpInfo[i].memberId, tmpInfo[i].memberName, tmpInfo[i].memberBattle, tmpInfo[i].memberStatus, tmpInfo[i].memberSchool, tmpInfo[i].memberSex};
-- 	end

-- 	if G_MAINSCENE and G_MAINSCENE.map_layer and not G_MAINSCENE.map_layer:isHideMode(true) then
--         local multiLayer = getRunScene():getChildByTag(150)
--         if not multiLayer then
--             multiLayer = __GotoTarget({ru = "a37"})
--         end
        
--         -- 快捷链接加入别人队伍
-- 		MultiData:ExecuteCallback("multiplayer", 0);
--         -- 自己创建队伍
--         MultiData:ExecuteCallback("createTeamLayer", 0);
--         -- 自己加入别人队伍
--         MultiData:ExecuteCallback("teamDetail", 0);
-- 	end
-- end

-- local GetMultiCopyLv = function (luabuffer)
--     local proto = g_msgHandlerInst:convertBufferToTable("MultiCopyLvProtocol", luabuffer)

--     MultiData.m_curLvl = proto.currentLv;
--     if MultiData.m_curLvl > 3 then
--         MultiData.m_curLvl = 3;
--     end

--     if MultiData.m_curLvl < 1 then
--         MultiData.m_curLvl = 1;
--     end

--     MultiData:ExecuteCallback("multiplayer", 1);
-- end

-- -- 通关
-- local MultiCopyUpLv = function (luabuffer)
--     local proto = g_msgHandlerInst:convertBufferToTable("MultiCopyUpLvProtocol", luabuffer)
    
--     MultiData.m_curLvl = proto.currentLv;

--     local clientStr = "";
--     if MultiData.m_curLvl == 2 then
--         clientStr = "multiJuinorClearance";
--     elseif MultiData.m_curLvl == 3 then
--         clientStr = "multiSeniorClearance";
--     end

--     if clientStr ~= "" then
--         TIPS{ type = 4, str = game.getStrByKey(clientStr) };
--     end

--     if MultiData.m_curLvl > 3 then
--         MultiData.m_curLvl = 3;
--     end

--     if MultiData.m_curLvl < 1 then
--         MultiData.m_curLvl = 1;
--     end
-- end

-- g_msgHandlerInst:registerMsgHandler(COPY_SC_GETTEAMDATARET,MultipleTeamData)
-- g_msgHandlerInst:registerMsgHandler(COPY_SC_MULTICOPY_LV, GetMultiCopyLv)
-- g_msgHandlerInst:registerMsgHandler(COPY_SC_MULTICOPY_UPLV, MultiCopyUpLv)
-- --g_msgHandlerInst:registerMsgHandler(COPY_SC_NOTIFYPROREWARD,notifyPrize)
-- --g_msgHandlerInst:registerMsgHandler(COPY_SC_GETPROREWARDLISTRET,getPrizeList)
