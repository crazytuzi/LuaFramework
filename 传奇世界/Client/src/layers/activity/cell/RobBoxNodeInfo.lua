local robBoxNodeInfo = class("robBoxNodeInfo", function() return cc.Node:create() end)

local path = "res/empire/"

local function getCenterPos(node)
	return cc.p(node:getContentSize().width/2, node:getContentSize().height/2)
end

function robBoxNodeInfo:ctor()
	self.isShow = true
	self.data = {BoxInfo = {}}

	local msgids = {LUOXIA_SC_GETREMAINTIME_RET, LUOXIA_SC_OUT_RET, LUOXIA_SC_BOXINFO, LUOXIA_SC_BOXPOS, LUOXIA_SC_BOXOVER}
	require("src/MsgHandler").new(self,msgids)

	self:createInfoView()
	g_msgHandlerInst:sendNetDataByTableExEx(LUOXIA_CS_GETREMAINTIME, "LuoxiaGetRmainTimeProtocol", {})
end

function robBoxNodeInfo:createInfoView()
	local function getTimeStr(time)
		return string.format("%02d", (math.floor(time/60)%60))..":"..string.format("%02d", math.floor(time%60)) 
	end
	
	local exitFunc = function()
		local OkQry = function()
			g_msgHandlerInst:sendNetDataByTableExEx(LUOXIA_CS_OUT, "LuoxiaOutProtocol", {})
		end
		
		local str = game.getStrByKey("robBox_ExitTips")
		if G_ROLE_MAIN and G_ROLE_MAIN:isHaveCarry(G_ROLE_MAIN) then
			str = game.getStrByKey("robBox_ExitTips2")
		end
		MessageBoxYesNo(nil, str, OkQry, nil)
	end
    local item = createMenuItem(self, "res/component/button/1.png", cc.p(g_scrSize.width-70, g_scrSize.height-110), exitFunc)
    item:setSmallToBigMode(false)
    createLabel(item, game.getStrByKey("exit"), getCenterPos(item), cc.p(0.5,0.5), 22, true):setColor(MColor.lable_yellow)    

    local timeBg = createSprite(self, "res/mainui/sideInfo/timeBg.png", cc.p(display.width-154-171, g_scrSize.height), cc.p(0, 1))
    local timeBgSize = timeBg:getContentSize()
    createLabel(timeBg, game.getStrByKey("robBox_HandTime1"), cc.p(timeBgSize.width/2, timeBgSize.height - 16), cc.p(0.5, 0.5), 18, true):setColor(MColor.lable_yellow)
    self.boxTimeText = createLabel(timeBg, "05:00", cc.p(timeBgSize.width/2, timeBgSize.height/2-10), cc.p(0.5, 0.5), 22, true)
    self.boxTimeText:setColor(MColor.green)

    timeBg:setVisible(false)
    self.timeBg = timeBg
end

function robBoxNodeInfo:changeStatus()
	--是否隐藏主界面箭头
	if not self.data.BoxInfo.haseOwner and self.data.BoxInfo.isOwner and self.data.BoxInfo.OwnerName ~= G_ROLE_MAIN:getTheName() then
		G_MAINSCENE:setArrowBtnVisable(true)
	elseif not self.data.BoxInfo.BossDead then
		G_MAINSCENE:setArrowBtnVisable(true)
	else
		G_MAINSCENE:setArrowBtnVisable(false)
	end	

	if self.time then 
		self.time:stopAllActions()
		self.time = nil
	end

	local function getTimeStr(time)
	    return string.format("%02d", (math.floor(time/60)%60)) .. ":" .. string.format("%02d", math.floor(time%60)) 
	end

	self.timeBg:setVisible(false)
	if self.data.BoxInfo.haseOwner  then
		self.timeBg:setVisible(true)
		self.boxTimeText:setString("已被获取")		
	elseif self.data.BoxInfo and self.data.BoxInfo.isOwner and self.data.BoxInfo.ownerTime then
		self.time =  startTimerActionEx(self, 1, true, function (delTime)
				self.timeBg:setVisible(true)
				self.data.BoxInfo.ownerTime = self.data.BoxInfo.ownerTime - delTime
				if self.data.BoxInfo.ownerTime >= 0 then
					self.boxTimeText:setString(game.getStrByKey("robBox_HandTime") .. getTimeStr(self.data.BoxInfo.ownerTime))
				end
				
				if self.data.BoxInfo.ownerTime <= 0 then 
					G_MAINSCENE:showArrowPointToMonster(false)
					self.timeBg:setVisible(false)
					if self.time then 
						self.time:stopAllActions()
						self.time = nil 
					end
				end
		end)
	end

	-- if not self.data.BoxInfo.BossDead and G_MAINSCENE then
	-- 	local monsterCfg = getConfigItemByKey( "monsterUpdate" , "q_id" , 522)
	-- 	if monsterCfg and monsterCfg.q_center_x and monsterCfg.q_center_y then
	-- 		G_MAINSCENE:showArrowPointToMonster(true, cc.p(monsterCfg.q_center_x, monsterCfg.q_center_y), true)
	-- 	end
	-- end
end

function robBoxNodeInfo:networkHander(buff, msgid)
	local switch = {
		[LUOXIA_SC_GETREMAINTIME_RET] = function() --参与结果返回
			local retTable = g_msgHandlerInst:convertBufferToTable("LuoxiaGetRmainTimeRetProtocol", buff)
			self.data.leftTime = retTable.lastTime
			if self.data.leftTime <= 0 then
				dump("networkHander error!!!!!")
			end
		end,
		[LUOXIA_SC_OUT_RET] = function()   --退出请求返回

		end,
		[LUOXIA_SC_BOXINFO] = function()  --宝盒归属信息
			self.data.BoxInfo = {}

			local retTable = g_msgHandlerInst:convertBufferToTable("LuoBoxInfoProtocol", buff)
			self.data.BoxInfo.BossDead  = retTable.hasBossDie  --BOSS是否死亡
			self.data.BoxInfo.haseOwner = retTable.hasBeGet --宝箱是否被收进背包
			self.data.BoxInfo.isOwner   = retTable.isHold   --宝箱是否被顶在头顶
			if self.data.BoxInfo.isOwner then
				self.data.BoxInfo.OwnerName = retTable.name
				self.data.BoxInfo.facName = retTable.facName
				self.data.BoxInfo.ownerTime = 300 - retTable.holdTime
				self.data.BoxInfo.isHelp = retTable.isSameTeam
				if self.data.BoxInfo.facName == "" then
					self.data.BoxInfo.facName = game.getStrByKey("biqi_str1")
				end
			else
				self.data.pos = nil
			end

			if self.data.BoxInfo.haseOwner then
				self.data.pos = nil
			end
			dump(self.data.BoxInfo, "self.data.BoxInfo")

			self:changeStatus()
		end,
		[LUOXIA_SC_BOXPOS] = function()   --宝盒位置信息
			local retTable = g_msgHandlerInst:convertBufferToTable("LuoBoxPosProtocol", buff)
			local isBoss = retTable.isBoss
			self.data.pos = cc.p(retTable.mapX, retTable.mapY)
			--dump(self.data.pos, "self.data.pos")
			
			if not self.data.BoxInfo  or (not self.data.BoxInfo.isOwner and self.data.BoxInfo.BossDead) then 
				return 
			end

			if self.data.pos and G_MAINSCENE then
				G_MAINSCENE:showArrowPointToMonster(true, cc.p(self.data.pos.x, self.data.pos.y), true)
			end
		end,
		[LUOXIA_SC_BOXOVER] = function()  --宝盒收入包裹
			
		end,
	}

 	if switch[msgid] then 
 		switch[msgid]()
 	end
end

return robBoxNodeInfo