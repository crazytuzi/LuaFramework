local skyArenaResult = class("skyArenaResult", function() return cc.Node:create() end)

local rescompath = "res/layers/skyArena/"

isDiscardRecordingBtnExist=false
function skyArenaResult:ctor(parent)

--	log("[skyArenaResult:ctor] called.")

	if parent then
		self.parent = parent
		parent:addChild(self,66)
	end
	
	local data = self:getData()

	-----------------------------------------------------------

	local nodeDlgLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 220))
	self:addChild(nodeDlgLayer)
	local nodeDlg = cc.Node:create()
	nodeDlg:setContentSize(cc.size(960,640))
	nodeDlg:setAnchorPoint(cc.p(0.5,0.5))
	nodeDlg:setPosition(getCenterPos(nodeDlgLayer))
	nodeDlgLayer:addChild(nodeDlg)
	local centerX = getCenterPos(nodeDlg).x
	local bg=createSprite(nodeDlg, "res/layers/activity/arena_result_bg.png", cc.p(centerX, getCenterPos(nodeDlg).y+72), cc.p(0.5, 0.5))
	createSprite(nodeDlg, "res/layers/VS/jieSuan_zhan.png", cc.p(centerX, getCenterPos(nodeDlg).y), cc.p(0.5, 0.5))
	-- title
	createSprite(nodeDlg, rescompath .. "result/result-name.png", cc.p(centerX, 510), cc.p(0.5, 0.0))

	-- vs
	createSprite(nodeDlg, "res/layers/VS/jieSuan_winIcon.png", cc.p(centerX, 440), cc.p(0.5, 0.5))
	createLabel(nodeDlg, data.team1KillCount, cc.p(centerX-20, 440), cc.p(1, 0.5), 25, true, 10):setColor(MColor.blue)
	createLabel(nodeDlg, data.team2KillCount, cc.p(centerX+20, 440), cc.p(0, 0.5), 25, true, 10):setColor(MColor.red)
	-- win
	local sprtWin = createSprite(nodeDlg, "res/jjc/newCode.png", cc.p(230, 417), cc.p(0.5, 0.0))
	local sprtFail = createSprite(nodeDlg, "res/jjc/fail_word.png", cc.p(720, 417), cc.p(0.5, 0.0))
	if data.wint1 then
        -- 播放特效
        -- local winEff = playCommonEffect(self, "3v3up", 12, 2.0, 1, 100)
        -- if winEff then
        --     winEff:setPosition(cc.p(centerX, 510))
        --     winEff:setAnchorPoint(cc.p(0.5, 0.0))
        --     addEffectWithMode(winEff, 2);
        -- end
        sprtWin:setPosition(cc.p(230, 417))
		sprtFail:setPosition(cc.p(720, 417))
	elseif data.wint2 then
		sprtWin:setPosition(cc.p(720, 417))
		sprtFail:setPosition(cc.p(230, 417))
        -- local loseEff = playCommonEffect(self, "3v3down", 12, 2.0, 1, 100)
        -- if loseEff then
        --     loseEff:setPosition(cc.p(centerX, 510))
        --     loseEff:setAnchorPoint(cc.p(0.5, 0.0))
        --     addEffectWithMode(loseEff, 2)
        -- end
	else
		sprtWin:setTexture("res/layers/skyArena/result/result_equal.png")
		sprtFail:setTexture("res/layers/skyArena/result/result_equal.png")
	end
	-------------------------------------------------------

	local my_ranking = 20
	local my_combat_power = 364200
	local my_total_score = 200000

	local text_size = 22
	local color_text = cc.c3b(180, 140, 100)
	local color_number = cc.c3b(255, 255, 255)


	local posX = {110, 110, 200, 254, 280, 315, 337}
	local posY = 380
	local spaceY = 40
	local spaceX = 490
	local text_colon = game.getStrByKey("colon")

	
	-------------------------------------------------------
	-- first team

	local start,endIndex=1,3
	if data.isMeInTeamB then
		start,endIndex=4,6
	end
	for i = start, endIndex do
		-- name
		createLabel(nodeDlg, data.item[i].char_name, cc.p(posX[1], posY), cc.p(0.0, 0.5), text_size, true, 10):setColor(MColor.blue)
--		createLabel(nodeDlg, game.getStrByKey("invilid_namelen_ex"), cc.p(posX[1], posY), cc.p(0.0, 0.5), text_size, true, 10):setColor(MColor.blue)

		-- kill count
		createSprite(nodeDlg, rescompath .. "result/result-kill.png", cc.p(posX[4], posY), cc.p(0.0, 0.5))
		createLabel(nodeDlg, tostring(data.item[i].kill_count), cc.p(posX[5], posY), cc.p(0.0, 0.5), text_size, true, 10):setColor(color_number)

		-- death count
		createSprite(nodeDlg, rescompath .. "result/result-death-red.png", cc.p(posX[6], posY), cc.p(0.0, 0.5))
		createLabel(nodeDlg, tostring(data.item[i].death_count), cc.p(posX[7], posY), cc.p(0.0, 0.5), text_size, true, 10):setColor(color_number)

		posY = posY - 25
		-- battle power
		createLabel(nodeDlg, game.getStrByKey("combat_power")..text_colon, cc.p(posX[2], posY), cc.p(0.0, 0.5), text_size, true, 10)
		createLabel(nodeDlg, tostring(data.item[i].combat_power), cc.p(posX[3], posY), cc.p(0.0, 0.5), text_size, true, 10):setColor(color_number)
		


		posY = posY - spaceY
	end

	posY = 380

	-------------------------------------------------------
	-- second team
	start,endIndex=4,6
	if data.isMeInTeamB then
		start,endIndex=1,3
	end
	for i = start, endIndex do
		-- name
		createLabel(nodeDlg, data.item[i].char_name, cc.p(posX[1]+spaceX, posY), cc.p(0.0, 0.5), text_size, true, 10):setColor(MColor.red)

		

		-- kill count
		createSprite(nodeDlg, rescompath .. "result/result-kill.png", cc.p(posX[4]+spaceX, posY), cc.p(0.0, 0.5))
		createLabel(nodeDlg, tostring(data.item[i].kill_count), cc.p(posX[5]+spaceX, posY), cc.p(0.0, 0.5), text_size, true, 10):setColor(color_number)

		-- death count
		createSprite(nodeDlg, rescompath .. "result/result-death-red.png", cc.p(posX[6]+spaceX, posY), cc.p(0.0, 0.5))
		createLabel(nodeDlg, tostring(data.item[i].death_count), cc.p(posX[7]+spaceX, posY), cc.p(0.0, 0.5), text_size, true, 10):setColor(color_number)

		posY = posY - 25
		-- battle power
		createLabel(nodeDlg, game.getStrByKey("combat_power")..text_colon, cc.p(posX[2]+spaceX, posY), cc.p(0.0, 0.5), text_size, true, 10)
		createLabel(nodeDlg, tostring(data.item[i].combat_power), cc.p(posX[3]+spaceX, posY), cc.p(0.0, 0.5), text_size, true, 10):setColor(color_number)

		posY = posY - spaceY
	end


    -------------------------------------------------------
    -- button
	
	local funcCBExit = function()
		self:exit()
	end

	local btnConfirm = createMenuItem(nodeDlg, "res/component/button/2.png", cc.p(centerX, 95), funcCBExit)
	createLabel(btnConfirm, game.getStrByKey("exit"), getCenterPos(btnConfirm), cc.p(0.5,0.5), 22, true):setColor(MColor.lable_yellow)    

    -------------------------------------------------------
	-- time

	self.time_remain = 30
--	local text_time = string.format(game.getStrByKey("time_close"), time_remain)
--	self.richText = require("src/RichText").new(nodeDlg, cc.p(centerX, 52), cc.size(140, 20), cc.p(0.5, 0.5), 20, 20, MColor.white)
--	self.richText:addText(text_time)
--	self.richText:format()
	posY = 52
	self.labTimeValue = createLabel(nodeDlg, tostring(self.time_remain), cc.p(centerX-70, posY), cc.p(0.5, 0.5), text_size, true, 10, nil, MColor.red)
	createLabel(nodeDlg, game.getStrByKey("time_close"), cc.p(centerX+10, posY), cc.p(0.5, 0.5), text_size, true, 10, nil, MColor.green)


	local funcUpdate = function()
		self:timeUpdate()
	end
	startTimerActionEx(self, 1.0, true, funcUpdate)

    -------------------------------------------------------

	if G_MAINSCENE and G_MAINSCENE.mainui_node then
		G_MAINSCENE.mainui_node:setVisible(false)
	end

	SwallowTouches(nodeDlg)
	--local discardRecordingBtn=createTouchItem(nodeDlg,"res/layers/skyArena/result/record.png",cc.p(centerX,190),function() displayRecordingContent() end)
	--停止录制视频
	if getLocalRecordByKey(3,"isAutoRecorder") and isSupportReplay() then
		local discardRecordingBtn=createTouchItem(nodeDlg,"res/layers/skyArena/result/record.png",cc.p(centerX,190),function() displayRecordingContent() end)
		discardRecordingBtn:setVisible(false)
		isDiscardRecordingBtnExist=true
		discardRecordingBtn:registerScriptHandler(function(event)
			if event == "enter" then
			elseif event == "exit" then
				isDiscardRecordingBtnExist=false
			end
		end)
		function callbackTab.showDiscardRecordingBtn()
			if isDiscardRecordingBtnExist then
		    	discardRecordingBtn:setVisible(true)
		    end
		end
		stopRecording()
	end
	
end

function skyArenaResult:getData()

	local data = {}
	data.item = {}
	data.wint1 = false
	data.wint2 = false
	data.team1KillCount=0
	data.team2KillCount=0
	data.isMeInTeamB=false
	for i = 1, 6 do
		data.item[i] = {}
		data.item[i].char_name = ""
		data.item[i].combat_power = 0
		data.item[i].kill_count = 0
		data.item[i].death_count = 0
		data.item[i].get_score = 0
        data.item[i].teamId = 0;
        data.item[i].role_id = 0;
	end

	-------------------------------------------------------
	local MainRoleId = 0
	if userInfo then
		MainRoleId = userInfo.currRoleId
	end
	local myTeamId = 0
	if G_SKYARENA_DATA  then
		if G_SKYARENA_DATA.RoleData then
			for i = 1, 6 do
				if G_SKYARENA_DATA.RoleData[i] then
					data.item[i].char_name = G_SKYARENA_DATA.RoleData[i].role_name
					data.item[i].combat_power = G_SKYARENA_DATA.RoleData[i].battle_power
					data.item[i].kill_count = G_SKYARENA_DATA.RoleData[i].killother_count
					data.item[i].death_count = G_SKYARENA_DATA.RoleData[i].killed_count
					data.item[i].get_score = G_SKYARENA_DATA.RoleData[i].score
	                data.item[i].teamId = G_SKYARENA_DATA.RoleData[i].teamId
	                data.item[i].role_id = G_SKYARENA_DATA.RoleData[i].role_id
	                if MainRoleId == G_SKYARENA_DATA.RoleData[i].role_id then
						if G_SKYARENA_DATA.TeamData then
							if i <= 3 then
								myTeamId = G_SKYARENA_DATA.TeamData.TA_id
							else
								data.isMeInTeamB=true
								myTeamId = G_SKYARENA_DATA.TeamData.TB_id
							end
						end
					end
	            end
			end
		end
		if G_SKYARENA_DATA.TeamData then
			if data.isMeInTeamB==false then
				data.team1KillCount=G_SKYARENA_DATA.TeamData.TA_kill_count
				data.team2KillCount=G_SKYARENA_DATA.TeamData.TB_kill_count
			else
				data.team1KillCount=G_SKYARENA_DATA.TeamData.TB_kill_count
				data.team2KillCount=G_SKYARENA_DATA.TeamData.TA_kill_count
			end
			local result = G_SKYARENA_DATA.TeamData.result
			if result == G_SKYARENA_DATA.TeamData.TA_id or result == G_SKYARENA_DATA.TeamData.TB_id  then
				data.wint1 = myTeamId==result
				data.wint2 = myTeamId~=result
			end

            -- 或者平局
		end
        -- 自身队伍在哪一边 [1~3 4~5]
     --    local isSelfUp = true;
     --    local upTeamId = 0;
     --    local downTeamId = 0;
     --    local teamA = {};
     --    local teamB = {};
     --    local teamNil = {};
     --    for i = 1, 6 do
     --        if data.item[i].teamId == G_SKYARENA_DATA.TeamData.TA_id then
     --            local index = #teamA + 1
     --            teamA[index] = copyTable(data.item[i]);
     --            if G_ROLE_MAIN and G_ROLE_MAIN:getTag() == teamA[index].role_id then
     --                isSelfUp = true;
     --                upTeamId = G_SKYARENA_DATA.TeamData.TA_id;
     --                downTeamId = G_SKYARENA_DATA.TeamData.TB_id;
     --            end
     --        elseif data.item[i].teamId == G_SKYARENA_DATA.TeamData.TB_id then
     --            local index = #teamB + 1
     --            teamB[index] = copyTable(data.item[i]);
     --            if G_ROLE_MAIN and G_ROLE_MAIN:getTag() == teamB[index].role_id then
     --                isSelfUp = false;
     --                upTeamId = G_SKYARENA_DATA.TeamData.TB_id;
     --                downTeamId = G_SKYARENA_DATA.TeamData.TA_id;
     --            end
     --        else
     --            local index = #teamNil + 1
     --            teamNil[index] = copyTable(data.item[i]);
     --        end
     --    end

     --    for i = #teamA, 3 do
     --        local index = #teamA + 1
     --        teamA[index] = copyTable(teamNil[#teamNil]);
     --        teamNil[#teamNil] = nil;
     --    end

     --    for i = #teamB, 3 do
     --        local index = #teamB + 1
     --        teamB[index] = copyTable(teamNil[#teamNil]);
     --        teamNil[#teamNil] = nil;
     --    end

     --    local retData = {};
	    -- retData.item = {};

       
        
     --    if isSelfUp then
     --        for i=1, #teamA do
     --            local index = #(retData.item) + 1
     --            retData.item[index] = copyTable(teamA[i]);
     --        end

     --        for i=1, #teamB do
     --            local index = #(retData.item) + 1
     --            retData.item[index] = copyTable(teamB[i]);
     --        end
     --    else
     --        for i=1, #teamB do
     --            local index = #(retData.item) + 1
     --            retData.item[index] = copyTable(teamB[i]);
     --        end

     --        for i=1, #teamA do
     --            local index = #(retData.item) + 1
     --            retData.item[index] = copyTable(teamA[i]);
     --        end
     --    end

        --return retData;
	end

	-------------------------------------------------------

	return data
end

function skyArenaResult:timeUpdate()
	if self.time_remain > 0 then
		self.time_remain = self.time_remain - 1
	else
		self:exit()

		if G_MAINSCENE and G_MAINSCENE.mainui_node then
			G_MAINSCENE.mainui_node:setVisible(true)
		end
	end

	if self.labTimeValue then
		self.labTimeValue:setString(tostring(self.time_remain))
	end
end

function skyArenaResult:exit()
	g_msgHandlerInst:sendNetDataByTable(PVP3V3_CS_EXIT_MATCH, "P3V3ExitMatchProtocol", {type = 1})
	cclog("[PVP3V3_CS_EXIT_MATCH] sent. On exit.")
	removeFromParent(self)
end

-----------------------------------------------------------

return skyArenaResult
