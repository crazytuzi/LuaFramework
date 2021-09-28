local skyArenaLayer = class("skyArenaLayer", function() return cc.Node:create() end)

local rescompath = "res/layers/skyArena/"
local p3V3DB = require("src/config/P3V3DB");
skyArenaLayer.seasonStart = false
skyArenaLayer.joinTimesRemind = 0
-----------------------------------------------------------

----------------------------------------------------------
-- btns
skyArenaLayer.singleJoinBtn = nil
skyArenaLayer.teamJoinBtn = nil
----------------------------------------------------------


function skyArenaLayer:ctor()

	log("[skyArenaLayer:ctor] called.")
    
    local bg = self:addBgRes()
    self:openMainPanel(bg)
    
end

function skyArenaLayer:addBgRes()
    local Mbaseboard = require "src/functional/baseboard"
    local root = Mbaseboard.new(
    {
	    src = "res/common/bg/bg18.png",
	    close = {
		    src = {"res/component/button/x2.png", "res/component/button/x2_sel.png"},
		    offset = { x = -8, y = 4 },
            handler = function(nod)
                removeFromParent(self);
            end
	    },
	    title = {
		    src = game.getStrByKey("sky_arena_title"),
		    size = 25,
		    color = MColor.lable_yellow,
		    offset = { y = -25 },
	    }
    })
    root:setPosition(g_scrCenter);
    self:addChild(root);

    local cnterBgSpr = createSprite( root , "res/layers/rewardTask/rewardTaskReleaseBg.png" , cc.p( root:getContentSize().width/2 , 15 ) , cc.p( 0.5 , 0 ) )
    local centerBgSize = cnterBgSpr:getContentSize();

    local popoutSpr = createSprite( cnterBgSpr, "res/common/shadow/desc_shadow.png", cc.p( centerBgSize.width/2 , 0 ), cc.p( 0.5 , 0 ) );
    return popoutSpr
end

function skyArenaLayer:openMainPanel(bg)
	local level = 20
    local season = 36
	local score_cur = 0
	local score_max = 0
	local ranking = 0
    local startTime = 0;
    local endtime = 0;
	local battle_count_remain = 2;
    local reward = 0;

	local text_size = 22
	local color_text = cc.c3b(180, 140, 100)
	local color_number = cc.c3b(255, 255, 255)

	if G_SKYARENA_DATA then
		if G_SKYARENA_DATA.SelfData then
			score_cur = G_SKYARENA_DATA.SelfData.SScore
			ranking = G_SKYARENA_DATA.SelfData.SRanking
            season = G_SKYARENA_DATA.SelfData.SId
            startTime = G_SKYARENA_DATA.SelfData.SStartTick;
            endtime = G_SKYARENA_DATA.SelfData.SEndTick;
            reward = G_SKYARENA_DATA.SelfData.SReward;
			battle_count_remain = 2 - G_SKYARENA_DATA.SelfData.SCount
			if battle_count_remain < 0 then
				battle_count_remain = 0
			end
		end
	end

    local tmpMaxScore = score_max;
    if p3V3DB then
        -- 获取最大分
        if p3V3DB.segmentList then
            local tmpMaxSeg = p3V3DB.segmentList[1];
            if tmpMaxSeg then
                tmpMaxScore = tmpMaxSeg.score;
            end
            local score_min = 0;
            local tmpMinSeg = p3V3DB.segmentList[#p3V3DB.segmentList];
            if tmpMinSeg then
                score_min = tmpMinSeg.score;
            end

            if score_cur < score_min then
                level = #p3V3DB.segmentList;
                score_max = score_min;
            elseif score_cur >= tmpMaxScore then
                level = 1;
                score_max = tmpMaxScore;
            else
                -- 获取当前段位
                for i = #p3V3DB.segmentList, 2, -1 do
                    local tmpSeg1 = p3V3DB.segmentList[i];
                    local tmpSeg2 = p3V3DB.segmentList[i-1]
                    if tmpSeg1 and tmpSeg2 then
                        if score_cur >= tmpSeg1.score and score_cur < tmpSeg2.score then
                            level = i;
                            score_max = tmpSeg2.score;
                            break;
                        end
                    end
                end
            end
        end
    end

	----------------------------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------------------------
    local nodeDlg = bg
    createLabel(nodeDlg, game.getStrByKey("sky_arena_levelTitle"),cc.p(120, 410) , cc.p(0, 0.5), text_size, true, 10)
    createLabel(nodeDlg, game.getStrByKey("sky_arena_limitLevel"),cc.p(230, 410) , cc.p(0, 0.5), text_size, true, 10,nil,MColor.drop_white)
    createLabel(nodeDlg, game.getStrByKey("sky_arena_rules"),cc.p(120, 360) , cc.p(0, 0.5), text_size, true, 10)
    
    --[[
    local fontSize = 20
    local width , height  = 480 , ( 300 - 40 )
    local pos = cc.p(36, 471)
    local str = require("src/config/PromptOp"):content(69)
    local tempNode = cc.Node:create()
	local text = require("src/RichText").new( tempNode , cc.p( 0 , 0 ) , cc.size( width - 30 , 0 ) , cc.p( 0 , 1 ) , fontSize + 10 , fontSize , MColor.lable_black )
	text:addText( str , MColor.lable_black , false )
	text:format()
    --text:setPosition(cc.p(230,365))
    ]]
    ---------------------------------------------------------------------------------------------
    local width , height  = 490 , 110
    local function createRichTextNode()
        local tempNode = cc.Node:create()
        local ruleTxt = require("src/RichText").new( tempNode , cc.p( 0 , 0 ) , cc.size( width-20 , 0 ) , cc.p( 0 , 0 ) , 22 , 20 , MColor.lable_black )
	    ruleTxt:addText( require("src/config/PromptOp"):content(69) , MColor.lable_black , false )
	    ruleTxt:format()

        tempNode:setContentSize( cc.size( width , math.abs( ruleTxt:getContentSize().height )  ) )
        setNodeAttr( ruleTxt , cc.p( 0 , 0 ) , cc.p( 0 , 0  ) )

        return tempNode;
    end
    
    local scrollView1 = cc.ScrollView:create()	  
    scrollView1:setViewSize(cc.size( width + 20  , height ) )
    scrollView1:setPosition( cc.p( 230 , 358 - height +10  ) )
    scrollView1:setScale(1.0)
    scrollView1:ignoreAnchorPointForPosition(true)
    local richNode = createRichTextNode()
    scrollView1:setContainer( richNode )
    scrollView1:updateInset()
    scrollView1:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL )
    scrollView1:setClippingToBounds(true)
    scrollView1:setBounceable(true)
    scrollView1:setDelegate()
    scrollView1:setContentOffset(cc.p(scrollView1:getContentOffset().x, scrollView1:getViewSize().height - scrollView1:getContentSize().height))
    nodeDlg:addChild(scrollView1)
    ---------------------------------------------------------------------------------------------

    local dropBoxId = 0
    local function setBattleCountRemain()
        local rReward = p3V3DB.rankReward
        local curSucNum = TMP_G_SKILLPROP_POS.winCnt
        local saCommFunc = require("src/layers/skyArena/skyArenaCommFunc")
        rReward = saCommFunc.reOrderTableByKey(rReward)
        if not curSucNum then
            MessageBox(game.getStrByKey("data_error"))
            return
        end
        for _,v in pairs(rReward) do
            if v[1] > curSucNum then
                battle_count_remain = v[1] - curSucNum
                dropBoxId = v[2]
                break
            end
        end
        
    end
    setBattleCountRemain()

    local function getWeekDayOfToday()
        local wd = tonumber( os.date("%w") )
        if wd == 0 then
            return 7
        end
        return wd
    end
    local function checkSeasonStart()
        self.seasonStart = false
        local anData = getConfigItemByKey("ActivityNormalDB","q_id",22)         -- 22
        if not anData.q_time then
            self.seasonStart = true
            return
        end
        local tt = unserialize(anData.q_time)[1]
        local week = tt.week
        local i=0
        local isToday = false
        for _,v in pairs(week) do
            i = i + 1
            if v == getWeekDayOfToday() then
                isToday = true
                break
            end
        end
        if i==0 or isToday then
            local startHour = tt.time[1]
            local startMin = tt.time[2]
            local startSec = tt.time[3]
            local startSecs = startHour*60*60 + startMin*60 + startSec
            local endHour = tt.time[4]
            local endMin = tt.time[5]
            local endSec = tt.time[6]
            local endSecs = endHour*60*60 + endMin*60 + endSec
            local hour = tonumber(os.date("%H")) 
            local minitues = tonumber(os.date("%M"))
            local seconds = tonumber(os.date("%S")) 
            local curSecs = hour*60*60 + minitues*60 + seconds
            if curSecs >= startSecs and curSecs <= endSecs then
                self.seasonStart = true
            end
        end
        
    end
    checkSeasonStart()

    local isSeasonStart = true -- when false set two buttons unclickable use self.seasonStart
    if isSeasonStart then

	    local prizeText = string.format(game.getStrByKey("sky_arena_prize"), battle_count_remain)
	    local rtPirze = require("src/RichText").new(nodeDlg, cc.p(120, 230), cc.size(500, 20), cc.p(0.0, 0.5), 20, text_size, MColor.lable_yellow)
	    rtPirze:addText(prizeText)
	    rtPirze:format()

        -- 奖励
        local awards = {}
        local DropOp = require("src/config/DropAwardOp")
        local dropId = 0;
        if p3V3DB and p3V3DB.segmentList then
            local levelCfg = p3V3DB.segmentList[level];
            if levelCfg then
                dropId = levelCfg.reward;
            end
        end
        local awardsConfig = DropOp:dropItem_ex(dropBoxId);
        if awardsConfig and tablenums(awardsConfig) >0 then
            table.sort( awardsConfig , function(a, b)
                if a == nil or a.px == nil or b == nil or b.px == nil then
                    return false;
                else
                    return a.px > b.px;
                end
            end)
        end
        for i=1, #awardsConfig do
            awards[i] =  { 
                              id = awardsConfig[i]["q_item"] ,       -- 奖励ID
                              num = awardsConfig[i]["q_count"]   ,    -- 奖励个数
                              streng = awardsConfig[i]["q_strength"] ,   -- 强化等级
                              quality = awardsConfig[i]["q_quality"] ,   -- 品质等级
                              upStar = awardsConfig[i]["q_star"] ,     -- 升星等级
                              time = awardsConfig[i]["q_time"] ,     -- 限时时间
                              showBind = true,
                              isBind = tonumber(awardsConfig[i]["bdlx"] or 0) == 1,                          
                            }
        end

        if tablenums( awards ) > 0 then
            local groupAwards =  __createAwardGroup( awards , nil , 85 , nil , false)
            setNodeAttr( groupAwards , cc.p( 105, 105 ) , cc.p( 0 , 0 ) )
            nodeDlg:addChild(groupAwards);
        end
    else
        -- no else logic here
	    
    end
    -------------------------------------------------------
    -- button
	
	local funcCBRanking = function()
		--g_msgHandlerInst:sendNetDataByTable(PVP3V3_CS_GETRANK, "P3V3GetRankProtocol", {})
		--cclog("[PVP3V3_CS_GETRANK] sent.")
        --getRunScene():addChild(require("src/layers/skyArena/skyArenaSkillSetting").new())
        self:addChild(require("src/layers/skyArena/skyArenaSkillSetting").new())
	end
    
    createLabel(nodeDlg, game.getStrByKey("sky_arena_label_times"),cc.p(610, 115) , cc.p(1, 0.5), text_size, true, 10)
    local today_times = createLabel(nodeDlg, TMP_G_SKILLPROP_POS.count,cc.p(625, 110) , cc.p(0, 0.5), text_size, true, 10,nil,MColor.white)
    --createLabel(nodeDlg, game.getStrByKey("sky_arena_button_skillset_content"),cc.p(575, 220) , cc.p(1, 0.5), text_size, true, 10)
	local btnRanking = createMenuItem(nodeDlg, "res/component/button/50.png", cc.p(160, 45), funcCBRanking)
	createLabel(btnRanking, game.getStrByKey("sky_arena_button_skillset"), getCenterPos(btnRanking), cc.p(0.5, 0.5), text_size, true, 10)
    --战斗录像开关
    local recordStr=createLabel(nodeDlg, game.getStrByKey("sky_arena_record"),cc.p(175, 220) , cc.p(1, 0.5), text_size, true, 10)
    
    local function changeSelect( )
        local isAutoRecorder=getLocalRecord("isAutoRecorder")
        setLocalRecord("isAutoRecorder",not isAutoRecorder)
        self.gou:setVisible(not isAutoRecorder)
    end
    local checkBox=createTouchItem(nodeDlg,"res/component/checkbox/1.png",cc.p(64,220),changeSelect)
    self.gou=createSprite(nodeDlg,"res/component/checkbox/1-1.png",cc.p(64,220))
    local isAutoRecorder=getLocalRecord("isAutoRecorder")
    self.gou:setVisible(isSupportReplay())
    if not isAutoRecorder then
        setLocalRecord("isAutoRecorder",false)
        self.gou:setVisible(false)
    end
    checkBox:setVisible(isSupportReplay())
    recordStr:setVisible(isSupportReplay())
    if isSeasonStart then
        local roleLevel = MRoleStruct:getAttr(ROLE_LEVEL)
        local funcCBSignupTeam = function()
            local saCommFunc = require("src/layers/skyArena/skyArenaCommFunc")
            if not self.seasonStart then
                MessageBox(game.getStrByKey("sky_arena_activitynotstart"))
                return
            end
            if not ( saCommFunc.checkTeam() and saCommFunc.checkTeamMemLevel() and saCommFunc.checkTeamMemTimes() ) then
                return 
            end

			g_msgHandlerInst:sendNetDataByTable(PVP3V3_CS_START_MATCH, "P3V3StartMatchProtocol", {type = 1})
			print("[PVP3V3_CS_START_MATCH] sent. team.............................................................")
            self.teamJoinBtn:setEnabled(false)
	    end

	    local funcCBSignupPersonal = function()
            local saCommFunc = require("src/layers/skyArena/skyArenaCommFunc")
            if not self.seasonStart then
                MessageBox(game.getStrByKey("sky_arena_activitynotstart"))
                return 
            elseif roleLevel < saCommFunc.limitLevel then
                MessageBox(game.getStrByKey("sky_arena_levelnot30"))
                return
            elseif TMP_G_SKILLPROP_POS.count < 1 then
                MessageBox(game.getStrByKey("sky_arena_timebelow1"))
                return
            end
		    g_msgHandlerInst:sendNetDataByTable(PVP3V3_CS_START_MATCH, "P3V3StartMatchProtocol", {type = 0})
		    print("[PVP3V3_CS_START_MATCH] sent. personal.......................................................")
            self.singleJoinBtn:setEnabled(false)
	    end

	    local btnSignupTeam = createMenuItem(nodeDlg, "res/component/button/50.png", cc.p(450, 45), funcCBSignupTeam,nil,true)
	    createLabel(btnSignupTeam, game.getStrByKey("sky_arena_button_team"), getCenterPos(btnSignupTeam), cc.p(0.5, 0.5), text_size, true, 10)
        self.teamJoinBtn = btnSignupTeam

	    local btnSignupPersonal = createMenuItem(nodeDlg, "res/component/button/50.png", cc.p(630, 45), funcCBSignupPersonal,nil,true)
	    createLabel(btnSignupPersonal, game.getStrByKey("sky_arena_button_personal"), getCenterPos(btnSignupPersonal), cc.p(0.5, 0.5), text_size, true, 10)
        self.singleJoinBtn = btnSignupPersonal
    else
        -- no else logic here
    end
    
    ---------------------------------------------------------------------------------------------------------------------------

	self:registerScriptHandler(function(event)
	 if event == "exit" then
		self.mDlgRank = nil
	 end
	 end)

	SwallowTouches(self)

end

function skyArenaLayer:reEnableBtns()
    -- 
    print("skyArenaLayer:reEnableBtns() called .............................................")
    if self.teamJoinBtn then
        self.teamJoinBtn:setEnabled(true)
    end

    if self.singleJoinBtn then
        self.singleJoinBtn:setEnabled(true)
    end
    
end

function skyArenaLayer:closeMainPanel()
	self:closeRankPanel()

--	if self.mDlgMain then
		removeFromParent(self.mDlgMain)
--		self.mDlgMain = nil
--	end

	self:closeMatchingPanel()
end

function skyArenaLayer:openRankPanel(rank_data)
	if self.mDlgRank then
		self:removeChild(self.mDlgRank)
	end

	-----------------------------------------------------------

--	local allData = {}
--	for i = 1, 20 do
--		local unitData = {}
--		unitData.char_name = "charname"
--		unitData.char_school = "fashi"
--		unitData.combat_power = "2000"
--		unitData.total_score = "10000"

--		allData[i] = unitData
--	end

	self.mDlgRank = require("src/layers/skyArena/skyArenaRank").new(self, rank_data)
end

function skyArenaLayer:closeRankPanel()
	if self.mDlgRank then
		self:removeChild(self.mDlgRank)
		self.mDlgRank = nil
	end
end

function skyArenaLayer:closeMatchingPanel()
	if self.mDlgMatching then
		self:removeChild(self.mDlgMatching)
		self.mDlgMatching = nil
	end
end


function skyArenaLayer:openResultPanel()
	if self.mDlgResult then
		self:removeChild(self.mDlgResult)
	end

	-----------------------------------------------------------

	local allData = {}
	for i = 1, 6 do
		local unitData = {}
		unitData.char_name = "charname"
		unitData.combat_power = "2000"
		unitData.kill_count = "20"
		unitData.death_count = "82"
		unitData.get_score = "1000"

		allData[i] = unitData
	end

	self.mDlgResult = require("src/layers/skyArena/skyArenaResult").new(self, allData)
end

function skyArenaLayer:closeResultPanel()
	if self.mDlgResult then
		self:removeChild(self.mDlgResult)
		self.mDlgResult = nil
	end
end


function skyArenaLayer:checkTeamInfo()
	if G_TEAM_INFO and G_TEAM_INFO.has_team then
		if G_TEAM_INFO.memCnt and G_TEAM_INFO.memCnt > 3 then
			TIPS( {str = game.getStrByKey("team_memcount_toomany"), type = 1} )
			return false
		else
			return true
		end
	else
		TIPS( {str = game.getStrByKey("need_team"), type = 1} )
		return false
	end
end

-----------------------------------------------------------
--[[
function skyArenaLayer:networkHander(luabuffer,msgid)

	cclog("[skyArenaLayer:networkHander] called." .. msgid)

    local switch = {
		[PVP3V3_SC_GETRANK] = function()

			local rankData = {}

			local trd = g_msgHandlerInst:convertBufferToTable("P3V3GetRankRetProtocol", luabuffer)
			local count = #trd.ranks
--			if trd and table.getn(trd) > 0 then
--				count = #trd.ranks
--			end
			for i = 1, count do
				rankData[i] = {}
				rankData[i].rank		= trd.ranks[i].rank
				rankData[i].char_name	= trd.ranks[i].name
				rankData[i].combat_power= trd.ranks[i].battle
				rankData[i].char_school	= trd.ranks[i].school
				rankData[i].total_score	= trd.ranks[i].score
			end

            if G_SKYARENA_DATA and G_SKYARENA_DATA.SelfData and trd.rank then
                G_SKYARENA_DATA.SelfData.SRanking = trd.rank;
            end

            self:openRankPanel(rankData)
			cclog("[PVP3V3_SC_GETRANK] received. count = %s.", count)
        end,
    }

    if switch[msgid] then 
        switch[msgid]()
    end

end
]]
-----------------------------------------------------------

return skyArenaLayer
