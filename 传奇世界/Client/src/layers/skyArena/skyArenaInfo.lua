local skyArenaInfo = class("skyArenaInfo", function() return cc.Node:create() end)

local rescompath = "res/layers/skyArena/"

local deathIcon=rescompath .. "result/result-death-white.png"
local offlineIcon=rescompath .. "result/offline.png"

function skyArenaInfo:ctor(parent)

--	log("[skyArenaInfo:ctor] called.")

	if parent then
		self.parent = parent
		parent:addChild(self)
	end
	
	self.expand = false
	self.continueKillNum=0
	self.iKillCount=0
	self.iDeadCount=0
--	data.I_kill = 208
--	data.I_death = 302
--	data.Team_kill = 200
--	data.Team_death = 280
--	data.item = {}
--	for i = 1, 6 do
--		data.item[i] = {}
--		data.item[i].name = game.getStrByKey("invilid_namelen_ex")
--		data.item[i].kill = 200
--		data.item[i].death = 400
--	end

	local data = self:getData()

	-----------------------------------------------------------

	local nodeDlg = createSprite(self, rescompath .. "result/result-bg.png", cc.p(g_scrSize.width-350, g_scrSize.height), cc.p(1.0, 1.0))
	local nodePanel = createSprite(nodeDlg, rescompath .. "result/result-info-bg.png", cc.p(-4, 5), cc.p(0.0, 1.0))
	self.nodeDlg = nodeDlg
	self.nodePanel = nodePanel

	-------------------------------------------------------

	local text_size = 20
	local color_text = cc.c3b(180, 140, 100)
	local color_number = cc.c3b(255, 255, 255)


	local posX = {12, 36, 168, 192, 230, 255}
	local posY = 20
	local spaceY = 30


	self.labSumWin = createLabel(nodeDlg, tostring(data.Team_kill), cc.p(44, posY), cc.p(1.0, 0.5), text_size, true, 10):setColor(MColor.blue)
	createSprite(nodeDlg, "res/jjc/vs.png", cc.p(60, posY-2), cc.p(0.5, 0.5)):setScale(0.5)
	self.labSumLose = createLabel(nodeDlg, tostring(data.Team_death), cc.p(72, posY), cc.p(0.0, 0.5), text_size, true, 10):setColor(MColor.red)

	createSprite(nodeDlg, rescompath .. "result/result-kill.png", cc.p(128, posY), cc.p(0.5, 0.5))
	self.labSumKill = createLabel(nodeDlg, tostring(data.I_kill), cc.p(140, posY), cc.p(0.0, 0.5), text_size, true, 10)

	createSprite(nodeDlg, rescompath .. "result/result-death-red.png", cc.p(198, posY), cc.p(0.5, 0.5))
	self.labSumDeath = createLabel(nodeDlg, tostring(data.I_death), cc.p(210, posY), cc.p(0.0, 0.5), text_size, true, 10)

	-------------------------------------------------------


	self.labInfoList = {}
	self.sprtState = {}
	posY = 200
	local textNameColor =data.isMeInTeamB and MColor.red or MColor.blue
	-------------------------------------------------------

	for i = 1, 6 do
		if i == 4 then
			textNameColor = data.isMeInTeamB and MColor.blue or MColor.red
			posY = posY - 16
		end

		self.labInfoList[i] = {}

		-- state
		self.sprtState[i] = createSprite(nodePanel, rescompath .. "result/result-death-white.png", cc.p(posX[1], posY-4), cc.p(0.0, 0.5))
		self.sprtState[i]:setVisible(data.item[i].state~=1)
		if data.item[i].state == 2 then
			self.sprtState[i]:setTexture(offlineIcon)
		end

		-- name
		self.labInfoList[i].labName = createLabel(nodePanel, data.item[i].name, cc.p(posX[2], posY), cc.p(0.0, 0.5), text_size, true, 10):setColor(textNameColor)

		-- kill count
		createSprite(nodePanel, rescompath .. "result/result-kill.png", cc.p(posX[3], posY), cc.p(0.0, 0.5))
		self.labInfoList[i].labKill = createLabel(nodePanel, tostring(data.item[i].kill), cc.p(posX[4], posY), cc.p(0.0, 0.5), text_size, true, 10):setColor(color_number)

		-- death count
		createSprite(nodePanel, rescompath .. "result/result-death-red.png", cc.p(posX[5], posY), cc.p(0.0, 0.5))
		self.labInfoList[i].labDeath = createLabel(nodePanel, tostring(data.item[i].death), cc.p(posX[6], posY), cc.p(0.0, 0.5), text_size, true, 10):setColor(color_number)


		posY = posY - spaceY
	end


    -------------------------------------------------------
    -- button
	
	local funcCBExpand = function()
		self.expand = not self.expand
		self:onShowSubPanel(self.expand)
	end

	local btnExpand = createMenuItem(nodeDlg, "res/component/button/57_1.png", cc.p(266, 20), funcCBExpand)
	self.btnExpand = btnExpand


	self:onShowSubPanel(self.expand)

    -------------------------------------------------------

    -- Ãƒâ‚¬Ã‚Â©Ã‚Â´ÃƒÂ³Ãƒâ€¢Ã‚Â¹Ã‚Â¿Ã‚ÂªÃƒâ€¡ÃƒÂ¸Ãƒâ€œÃƒÂ²ÃƒÂÃƒÂ¬Ãƒâ€œÃ‚Â¦Ã‚Â·Ã‚Â¶ÃƒÅ½Ã‚�?
    local listenner = cc.EventListenerTouchOneByOne:create()
	listenner:setSwallowTouches(true)
	listenner:registerScriptHandler(function(touch, event)
            if self.nodeDlg and touch and event then
				local pt = self.nodeDlg:getParent():convertTouchToNodeSpace(touch)
				if cc.rectContainsPoint(self.nodeDlg:getBoundingBox(), pt) then
					return true;
				end	  
            end  	
			return false;
		end,cc.Handler.EVENT_TOUCH_BEGAN)
	listenner:registerScriptHandler(function(touch, event)
            if self.nodeDlg and touch and event then
				local pt = self.nodeDlg:getParent():convertTouchToNodeSpace(touch)
				if cc.rectContainsPoint( self.nodeDlg:getBoundingBox(),pt) then
					if funcCBExpand then
                        funcCBExpand();
                    end
				end	  
            end

            return false;
		end,cc.Handler.EVENT_TOUCH_ENDED)
	local eventDispatcher = self.nodeDlg:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, self.nodeDlg)

	local function secondParse(secs)
		local h = math.floor(secs/3600)
		secs = secs-h*3600
		local m = math.floor(secs/60)
		secs = secs-m*60
		local str = ""
		if h > 0 then
			str = ""..h..game.getStrByKey("hour")
		end
		local ret = str..m..game.getStrByKey("min")..secs..game.getStrByKey("sec")
		--cclog(ret)
		return ret
	end
--	SwallowTouches(nodeDlg)
	local bg = createSprite(self,"res/mainui/sideInfo/timeBg.png", cc.p(display.width-154-171, g_scrSize.height), cc.p(0, 1))
	local timeBgSize = bg:getContentSize()
	self.labTimeTitle = createLabel(bg,game.getStrByKey("battle_countdown"), cc.p(timeBgSize.width/2, timeBgSize.height - 16), nil, 18, true)
	self.leftSecond=5*60
	self.labTime = createLabel(bg, self.leftSecond, cc.p(timeBgSize.width/2, timeBgSize.height/2-8), cc.p(0.5,0.5),40,true,nil,nil,MColor.lable_yellow)
	self.startTime=GetTime()
	self.endTime=self.startTime+5*60
	self.timeBg = bg
	local timeUpdate = function()
		if self.leftSecond==0 then
			return
		end
		local timeLeft=math.floor((self.endTime-GetTime()))
		if timeLeft<self.leftSecond then
			self.leftSecond=timeLeft
			self.labTime:setString(self.leftSecond)
		end
	end
	startTimerActionEx(bg, 0.01, true, timeUpdate)
end

function skyArenaInfo:getData()
	local data = {}
	data.item = {}

	data.I_kill = 0
	data.I_death = 0
	data.Team_kill = 0
	data.Team_death = 0
	data.isMeInTeamB=false
	for i = 1, 6 do
		data.item[i] = {}
		data.item[i].name = "xx"
		data.item[i].kill = 0
		data.item[i].death = 0
		data.item[i].state = 1
	end

	-------------------------------------------------------

	local MainRoleId = 0
	if userInfo then
		MainRoleId = userInfo.currRoleId
	end

	if G_SKYARENA_DATA  then
		local TeamTag = 1

		if G_SKYARENA_DATA.RoleData then
			for i = 1, 6 do
				if G_SKYARENA_DATA.RoleData[i] then
					data.item[i].name = G_SKYARENA_DATA.RoleData[i].role_name
					data.item[i].kill = G_SKYARENA_DATA.RoleData[i].killother_count
					data.item[i].death = G_SKYARENA_DATA.RoleData[i].killed_count
					data.item[i].state = G_SKYARENA_DATA.RoleData[i].state


					if MainRoleId == G_SKYARENA_DATA.RoleData[i].role_id then
						if G_SKYARENA_DATA.TeamData then
							if i <= 3 then
								TeamTag = G_SKYARENA_DATA.TeamData.TA_id
							else
								data.isMeInTeamB=true
								TeamTag = G_SKYARENA_DATA.TeamData.TB_id
							end
						end

						data.I_kill = data.item[i].kill
						data.I_death = data.item[i].death
					end
				end
			end
		end

		if G_SKYARENA_DATA.TeamData then
			if TeamTag == G_SKYARENA_DATA.TeamData.TA_id then
				data.Team_kill = G_SKYARENA_DATA.TeamData.TA_kill_count
				data.Team_death = G_SKYARENA_DATA.TeamData.TB_kill_count
			else
				data.Team_kill = G_SKYARENA_DATA.TeamData.TB_kill_count
				data.Team_death = G_SKYARENA_DATA.TeamData.TA_kill_count
			end
		end
	end

	return data
end

function skyArenaInfo:onShowSubPanel(show)
	self.nodePanel:setVisible(show)

	if show then
		self.btnExpand:setRotation(-90)
	else
		self.btnExpand:setRotation(0)
	end

end

function skyArenaInfo:updatePanelInfo()

	local data = self:getData()
	--dump(data,"updatePanelInfo")

	self.labSumWin:setString(tostring(data.Team_kill))
	self.labSumLose:setString(tostring(data.Team_death))

	self.labSumKill:setString(tostring(data.I_kill))
	self.labSumDeath:setString(tostring(data.I_death))

    -------------------------------------------------------
    local textNameColor =data.isMeInTeamB and MColor.red or MColor.blue
	-------------------------------------------------------
	for i = 1, 6 do
		if i == 4 then
			textNameColor = data.isMeInTeamB and MColor.blue or MColor.red
		end
		--state
		local isDeath = false
		if data.item[i].state == 0 then
			self.sprtState[i]:setTexture(deathIcon)
		end
		self.sprtState[i]:setVisible(data.item[i].state~=1)
		if data.item[i].state == 2 then
			self.sprtState[i]:setTexture(offlineIcon)
		end

		-- name
		self.labInfoList[i].labName:setString(data.item[i].name)
		self.labInfoList[i].labName:setColor(textNameColor)
		-- kill count
		self.labInfoList[i].labKill:setString(tostring(data.item[i].kill))

		-- death count
		self.labInfoList[i].labDeath:setString(tostring(data.item[i].death))

	end
	if data.I_kill>self.iKillCount then
		self.continueKillNum=self.continueKillNum+(data.I_kill-self.iKillCount)
		self.iKillCount=data.I_kill
		G_MAINSCENE:shaWarMykillNum(self.continueKillNum)
	end
	if data.I_death>self.iDeadCount then
		self.iDeadCount=data.I_death
		self.continueKillNum=0
	end 
end



-----------------------------------------------------------

return skyArenaInfo
