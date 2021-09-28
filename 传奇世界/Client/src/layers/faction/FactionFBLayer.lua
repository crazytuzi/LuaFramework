local FactionFBLayer = class("FactionFBLayer", function() return cc.Layer:create() end)

local path = "res/faction/"
local pathCommon = "res/common/"

function FactionFBLayer:ctor(factionData, bg)
	self.BossData = {}
	self.factionData = factionData
	self.bg = bg
	self.fbData = require("src/config/FactionCopyDB")
	self.curIndex = 1
	self.bossTime = -1
	self.copyId = 0
	self.copySetCount = 0
	self.labBossName = nil
	self.textBossInfo = nil

	local baseNode = cc.Node:create()
	self:addChild(baseNode)
	baseNode:setPosition(cc.p(0, 0))
	self.baseNode = baseNode


	local imageBg = createSprite(baseNode, path.."4.png", cc.p(0, 0), cc.p(0.0, 0.0))
	self.myBg = imageBg
	local size = imageBg:getContentSize()
	self.bgSize = size

	local preBtnFunc = function()
		self:updateCurIndex(self.curIndex - 1)
	end
	local preBtn = createMenuItem(imageBg, "res/group/arrows/18.png", cc.p(335, 260), preBtnFunc)
	self.preBtn = preBtn
	local nextBtnFunc = function()
		self:updateCurIndex(self.curIndex + 1)
	end
	local nextBtn = createMenuItem(imageBg, "res/group/arrows/19.png", cc.p(695, 260), nextBtnFunc)
	self.nextBtn = nextBtn

	createSprite(imageBg, "res/faction/5.png", cc.p(155, 425), nil, 2, 0.85)
	createSprite(imageBg, "res/faction/title_min2.png", cc.p(155, 425))
	__createHelp(
		{parent = imageBg, 
		 str = require("src/config/PromptOp"):content(40),
		 pos = cc.p(670, 460),
		}
	)
	
	local index = 1
	if G_FACTION_INFO.StartFbId ~= 0 then
		for i=1,#self.fbData do
			if G_FACTION_INFO.StartFbId == tonumber(self.fbData[i].ID) then
				index = i
				break
			end
		end
	end

	self:updateCurIndex(index)

	if G_MAINSCENE then
 		G_MAINSCENE:setFactionRedPointVisible(2, false)
    end


    g_msgHandlerInst:sendNetDataByTableExEx(FACTIONCOPY_CS_GET_PASS_TIME, "FactionCopyGetPassTime", {})
	cclog("[FACTIONCOPY_CS_GET_PASS_TIME] sent.")
	--addNetLoading(FACTIONCOPY_CS_GET_PASS_TIME, FACTIONCOPY_SC_GET_PASS_TIME_RET)
	local msgids = {FACTIONCOPY_SC_GET_PASS_TIME_RET, FACTIONCOPY_SC_SETOPEN_TIME_RET}
	require("src/MsgHandler").new(self,msgids)    
end


function FactionFBLayer:updateCurIndex(index, timeZero)
	if index < 1 or index > #self.fbData then
		return
	end

	self.curIndex = index
	local data = self.fbData[self.curIndex]
	local BossState = {state = 1, time = 0, time_zero = timeZero}

	local bossTimeCheck = self.bossTime

	if self.copyId > 0 and self.copyId == tonumber(data.ID) then
		if bossTimeCheck == -1 then
			BossState.state = 1
		elseif bossTimeCheck > 0 then
			BossState.state = 2
			BossState.time = bossTimeCheck
		elseif bossTimeCheck == 0 then
			BossState.state = 3
		elseif bossTimeCheck == -2 then
			BossState.state = 4
		end
	else

	end

--	if G_FACTION_INFO.StartFbId == tonumber(data.ID) and self.bossTime ~= -1 then
--		if self.bossTime < tonumber(data.bossFreshTime) and 0 <= self.bossTime then
--			BossState.state = 2
--			BossState.time = tonumber(data.bossFreshTime) - self.bossTime
--		elseif self.bossTime > tonumber(data.bossFreshTime) then
--			BossState.state = 3
--			BossState.time = tonumber(data.totalTime) - self.bossTime
--		end
--	end

	-------------------------------------------------------


	-------------------------------------------------------

	local monsterCfg = getConfigItemByKey( "monster", "q_id" )[tonumber(data.monsterID)]
	
	self:refBossInfo(monsterCfg, data)
	self:refBossState(BossState, data)
	self:updateAward(data)
	self:controlArrowHide(self.curIndex)
end

function FactionFBLayer:refBossInfo(monsterCfg,data)
	if monsterCfg then
		local bossNameInfo = monsterCfg.q_name
		self.textBossInfo = string.format(game.getStrByKey("factionJYT_text1"), bossNameInfo, data.costResource)
        if self.labBossName then
            self.labBossName:removeFromParent();
            self.labBossName = nil;
        end

        -- function RichText:ctor(parent, pos, size, anchor, lineHeight, fontSize, fontColor, tag, zOrder, isIgnoreHeight)
        self.labBossName = require("src/RichText").new(self.myBg, cc.p(510, 30), cc.size(300, 20), cc.p(0.5, 0.5), 24, 22, MColor.white)
	    self.labBossName:addText(self.textBossInfo)
	    self.labBossName:format();
	end

    if self.BossIcon ~= nil then
        self.BossIcon:removeFromParent(true)
    end

    local name, scale = self:getBossName(monsterCfg)
    self.BossIcon = createSprite(self.myBg, name, cc.p(515, 70), cc.p(0.5, 0))
    self.BossIcon:setScale(scale)
end

function FactionFBLayer:refBossState(BossState, data)

	if not data then return end

	local StateNode = self.myBg:getChildByTag(101)
	if StateNode then
		removeFromParent(StateNode)
	end
--	if self.timeAction then
--		self:stopAction(self.timeAction)
--		self.timeAction = nil
--	end

	StateNode = cc.Node:create()
	self.myBg:addChild(StateNode, 3, 101)

	-------------------------------------------------------

	local findNpc = function()
		if MRoleStruct:getAttr( ROLE_LEVEL ) < data.joinLevel then
			TIPS({ type = 1, str = string.format( game.getStrByKey("faction_joinFbLevLimite"), tonumber(data.joinLevel) ) })
			return
		end		
		local mapId, posX, posY = 10393, 22, 35
		local npcCfg = require("src/config/NPC")
		for i=1, #npcCfg do
			if tonumber(npcCfg[i].q_id) == 10393 then
				mapId = tonumber(npcCfg[i].q_map)
				posX = tonumber(npcCfg[i].q_x)
				posY = tonumber(npcCfg[i].q_y)
				break
			end
		end
		local WorkCallBack = function()
			require("src/layers/mission/MissionNetMsg"):sendClickNPC(10393)
			game.setAutoStatus(0)		
		end

     	local tempData = { targetType = 4 , mapID = mapId ,  x = posX , y = posY , callFun = WorkCallBack  }
        __TASK:findPath( tempData )
		__removeAllLayers()
	end	

	local funcSetOpen = function()
		if not self.textBossInfo then
			return
		end

		if self.factionData.facLv < data.factionLevel then
			TIPS({ type = 1, str = string.format(game.getStrByKey("faction_bossLessLevel"), data.factionLevel)})
			return
		end

		local function onShareToFactionGroup(factionID)
        	local title = "行会成员注意了！"
        	local desc = "会长修改了行会BOSS开启时间，请关注最新时间！"
        	local urlIcon = "http://game.gtimg.cn/images/cqsj/m/m201604/web_logo.png"
        	sdkSendToWXGroup(1, 1, factionID, title, desc, "MessageExt", "MSG_INVITE", urlIcon, "")
    	end

    	local function shareToFactionGroup(factionID)
        	if isWXInstalled() then
        		local isInWXGroup = getGameSetById(GAME_SET_ISINWXGROUP)
            	if isInWXGroup == 1 then
                	onShareToFactionGroup(factionID)
                	--TIPS({ type = 1  , str = game.getStrByKey("faction_wxgroup_sendMSGtoGroup") })
            	else
                	--TIPS({ type = 1  , str = game.getStrByKey("faction_wxgroup_notInWXgroup") })
            	end
        	else
            	--TIPS({ type = 1  , str = game.getStrByKey("faction_wxgroup_noInstalledWX") })
        	end
    	end

		local funcSet = function()
			require("src/layers/faction/FactionFBSetOpenTimeLayer").new(self.baseNode, self.textBossInfo, data.ID)
			local factionID = require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID)
			shareToFactionGroup(factionID)
		end

		MessageBoxYesNo(nil, game.getStrByKey("faction_hintOnceConfirm"), funcSet, nil)
	end

	-------------------------------------------------------

	local itemGotoJoin = createTouchItem(StateNode, "res/component/button/50.png", cc.p(154, 85), findNpc)
	createLabel(itemGotoJoin, game.getStrByKey("faction_gotoJoin"), getCenterPos(itemGotoJoin), nil, 22, true):setColor(MColor.lable_yellow)
	itemGotoJoin:setVisible(false)

	local itemSetOpen = createTouchItem(StateNode, "res/component/button/50.png", cc.p(154, 85), funcSetOpen)
	createLabel(itemSetOpen, game.getStrByKey("faction_setOpen"), getCenterPos(itemSetOpen), nil, 22, true):setColor(MColor.lable_yellow)
	itemSetOpen:setVisible(false)

	if self.factionData.facLv < 2 then
		createLabel(StateNode, game.getStrByKey("faction_fb_tip"), cc.p(154,35), nil, 20, true):setColor(MColor.red)
	end


	local labHint = createLabel(StateNode, "", cc.p(154, 85), nil, 22, true):setColor(MColor.lable_yellow)
	labHint:setVisible(false)

	local labTextMoney = createLabel(StateNode, game.getStrByKey("faction_MoneyNotEnough"), cc.p(160, 160), nil, 20, true):setColor(MColor.red)
	labTextMoney:setVisible(false)

	local labRemainTime = createLabel(StateNode, "", cc.p(154, 42), nil, 20, true):setColor(MColor.white)
	labRemainTime:setVisible(false)


	-------------------------------------------------------

	local hasRight = false
	if self.factionData.job >= 3 then
		hasRight = true
	end

	local textNotOpen = game.getStrByKey("faction_notOpen")
	local textBossKilled = game.getStrByKey("faction_bossKilled")
	local remainTime = BossState.time

	if BossState.state == 1 then
		if hasRight then
			local btnEnable = self.copySetCount == 0
			itemSetOpen:setVisible(true)
			itemSetOpen:setEnable(btnEnable)
		else
			labHint:setString(textNotOpen)
			labHint:setVisible(true)
		end
	elseif BossState.state == 2 then
		local strRemainTime = game.getStrByKey("faction_openRemain") .. secondParse(remainTime)
		labRemainTime:setString(strRemainTime)
		labRemainTime:setVisible(true)

		local timeLow = remainTime < 300

		if hasRight then
			if timeLow then
				itemGotoJoin:setVisible(true)
			else
				local btnEnable = self.copySetCount == 0
				itemSetOpen:setVisible(true)
				itemSetOpen:setEnable(btnEnable)
			end
		else
			local btnGoEnable = timeLow
			itemGotoJoin:setVisible(true)
			itemGotoJoin:setEnable(btnGoEnable)
		end

		if self.factionData.money < data.costResource then
			labTextMoney:setVisible(true)
		end

		---------------------------------------------------

--		self.timeAction = startTimerAction(self, 1, true, function()
--			if BossState.time > 0 then
--				BossState.time = BossState.time - 1
--				labRemainTime:setString(game.getStrByKey("faction_openRemain") .. secondParse(BossState.time))

--				if BossState.time < 300 then
--					self:refBossState(BossState, data)
--				end
--			else
--				BossState.state = 3
--				BossState.time = 0
--				self:refBossState(BossState, data)
--				self:stopAction(self.timeAction)
--				self.timeAction = nil
--			end
--			self.bossTime = BossState.time
--			log("Faction update time called. time = %s.", BossState.time)
--		end)

	elseif BossState.state == 3 then
		if not BossState.time_zero then
			local text = game.getStrByKey("faction_bossOpened")
			labRemainTime:setString(text)
			labRemainTime:setVisible(true)

			itemGotoJoin:setVisible(true)
		end
	elseif BossState.state == 4 then
		labHint:setString(textBossKilled)
		labHint:setVisible(true)
	end


--        if self.factionData.job >= 3 then
--			local func = function()
--				local okfunc = function()
--					--召唤boss
--					g_msgHandlerInst:sendNetDataByFmtExEx(FACTIONCOPY_CS_CALL_BOSS, "ii", G_ROLE_MAIN.obj_id, tonumber(self.fbData[self.curIndex].ID))
--					--addNetLoading(FACTIONCOPY_CS_CALL_BOSS, FACTIONCOPY_SC_CALL_BOSS_RET)				
--				end
--				if G_FACTION_INFO.StartFbId ~= 0 then 
--					TIPS( getConfigItemByKeys("clientmsg",{"sth","mid"},{15900, -5})  )
--                elseif self.factionData.facLv < data.factionLevel then
--					TIPS({ type = 1, str = game.getStrByKey("faction_bossLessLevel")})
--					return
--				elseif self.factionData.money < data.costResource then
--					TIPS({ type = 1, str = game.getStrByKey("faction_bossNoMoney")})
--					return
--				else
--					MessageBoxYesNo(nil, string.format(game.getStrByKey("faction_bossMoneyTips"), tonumber(data.costResource)), okfunc, nil)
--				end

--			end
--			local item = createMenuItem(StateNode, "res/component/button/50.png", cc.p(154, 85), func)
--			createLabel(item, game.getStrByKey("faction_callBoss"), getCenterPos(item), nil, 22, true):setColor(MColor.lable_yellow)

--		else
--			createLabel(StateNode, game.getStrByKey("faction_callBossLimit"), cc.p(154, 85), cc.p(0.5,0.5), 20, true):setColor(MColor.red)
--		end

end

function FactionFBLayer:getBossName(monsterCfg)
	if not monsterCfg then
		return "res/faction/boss1.png", 1
	end

    if monsterCfg.q_featureid == 20060 then
        return "res/faction/boss2.png", 0.9
    elseif monsterCfg.q_featureid == 20033 then
        return "res/faction/boss3.png", 0.8
    else
        return "res/faction/boss1.png", 0.75
    end
end

function FactionFBLayer:updateAward(data)
	if not data then 
		return
	end

	local node = self.myBg:getChildByTag(100)
	if node then
		removeFromParent(node)
	end

	node = cc.Node:create()
	self.myBg:addChild(node, 1, 100)

	local DropOp = require("src/config/DropAwardOp")
	local gdItem = DropOp:dropItem(tonumber(data.showReward))
	local j = 0
	local tableNum = tablenums(gdItem)
	for m,n in pairs(gdItem) do
		local Mprop = require "src/layers/bag/prop"
		local icon = Mprop.new(
		{
			protoId = tonumber(n.q_item),
			num = tonumber(n.q_count),
			swallow = true,
			cb = "tips",
            showBind = true,
            isBind = tonumber(n.bdlx or 0) == 1,		
		})
		icon:setTag(9)
		node:addChild(icon)
        local posX = 30 + (j%3) * 90
        local posY = 360 - ((j -(j%3))/3)*90
		icon:setPosition(cc.p(posX , posY))
		icon:setAnchorPoint(0, 0.5)
		j = j + 1
	end
end

function FactionFBLayer:controlArrowHide(index)
	if index == 1 then 
		self.preBtn:setVisible(false) 
		self.nextBtn:setVisible(true)
	elseif index == #self.fbData then 
		self.preBtn:setVisible(true) 
		self.nextBtn:setVisible(false)
	else
		self.preBtn:setVisible(true) 
		self.nextBtn:setVisible(true)		
	end
end

function FactionFBLayer:onTimeUpdate(timeZero)
	self:updateCurIndex(self.curIndex, timeZero)
end

function FactionFBLayer:networkHander(buff,msgid)
	local switch = {
	[FACTIONCOPY_SC_GET_PASS_TIME_RET] = function()
		local t = g_msgHandlerInst:convertBufferToTable("FactionCopyGetPassTimeRet", buff)
        self.bossTime = t.secToOpen
		self.copyId = t.copyID
		self.copySetCount = t.openTimes

		cclog("[FACTIONCOPY_SC_GET_PASS_TIME_RET] time = %s, copyid = %s, setcount = %s.", self.bossTime, self.copyId, self.copySetCount)

		local updateIndex = self.curIndex
		if self.bossTime > 0 or self.bossTime == -2 then
			if self.copyId > 0 then
				local fbData = require("src/config/FactionCopyDB")
				for i = 1, #fbData do
					if self.copyId == tonumber(fbData[i].ID) then
						updateIndex = i
						break
					end
				end
			end
		end
		self:updateCurIndex(updateIndex)

--		if self.bossTimeAdd then
--			self:stopAction(self.bossTimeAdd)
--		end

--		self.bossTimeAdd = startTimerAction(self, 1, true, function ( ... )
--			self.bossTime = self.bossTime + 1
--		end)

		if self.timeAction then
			self:stopAction(self.timeAction)
			self.timeAction = nil
		end

		if self.bossTime > 0 then
			self.timeAction = startTimerAction(self, 1, true, function()
				if self.bossTime > 1 then
					self.bossTime = self.bossTime - 1
					self:onTimeUpdate(false)
				else
					self.bossTime = 0
					self:stopAction(self.timeAction)
					self.timeAction = nil
					self:onTimeUpdate(true)
				end
			end)
		end

	end,

	[FACTIONCOPY_SC_SETOPEN_TIME_RET] = function()
		local t = g_msgHandlerInst:convertBufferToTable("FactionCopySetOpenTimeRet", buff) 

        local copyId = t.copyID
		local strTime = t.strtime
		local nTime = t.secToOpen
		local copySetCount = t.openTimes

		cclog("[FACTIONCOPY_SC_SETOPEN_TIME_RET] copyId = %s, strTime = %s, nTime = %s, copySetCount = %s.", copyId, strTime, nTime, copySetCount)

		self.copyId = copyId
		self.bossTime = nTime
		self.copySetCount = copySetCount
		self:updateCurIndex(self.curIndex)

		---------------------------------------------------

		if self.timeAction then
			self:stopAction(self.timeAction)
			self.timeAction = nil
		end

		if self.bossTime > 0 then
			self.timeAction = startTimerAction(self, 1, true, function()
				if self.bossTime > 1 then
					self.bossTime = self.bossTime - 1
					self:onTimeUpdate(false)
				else
					self.bossTime = 0
					self:stopAction(self.timeAction)
					self.timeAction = nil
					self:onTimeUpdate(true)
				end
			end)
		end

	end,
	}
	if switch[msgid] then
		switch[msgid]()
	end
end

return FactionFBLayer