local skyArenaLayerEnroll = class("skyArenaLayerEnroll", function() return cc.Node:create() end)
local PrizeLayer = class("PrizeLayer", require("src/TabViewLayer"))
local rescompath = "res/layers/skyArena/"
local p3V3DB = require("src/config/P3V3DB");
skyArenaLayerEnroll.seasonStart = false
skyArenaLayerEnroll.joinTimesRemind = 0
-----------------------------------------------------------

----------------------------------------------------------
-- btns
skyArenaLayerEnroll.singleJoinBtn = nil
skyArenaLayerEnroll.teamJoinBtn = nil
----------------------------------------------------------


function skyArenaLayerEnroll:ctor()

	log("[skyArenaLayerEnroll:ctor] called.")
    
    local bg = self:addBgRes()
    self.bg=bg
    self:openMainPanel(bg)
    
end

function skyArenaLayerEnroll:addBgRes()
   local base_node = createBgSprite( self , "公平竞技场" )
    local size = base_node:getContentSize()
    local left_bg_size = cc.size(896, 500)
    local left_bg = createScale9Frame(
        base_node,
        "res/common/scalable/panel_outer_base.png",
        "res/common/scalable/panel_outer_frame_scale9.png",
        cc.p(32, 38),
        left_bg_size,
        5
    )

    local insert_bg = createScale9Sprite(
        base_node,
        "res/common/scalable/panel_inside_scale9.png",
        cc.p(41, 46),
        cc.size(878, 254),
        cc.p(0, 0)
    )    
    createSprite( base_node , "res/layers/skyArena/bg_image.jpg" , cc.p( size.width/2 , size.height - 104 ) , cc.p(  0.5 , 1 ) , nil )  
    return base_node
end

function skyArenaLayerEnroll:getActivityCfg()
    local cfgs=getConfigItemByKey( "ActivityNormalDB" , "q_id"  )
    for k,v in pairs(cfgs) do
        if v.q_name == '公平竞技场' then
            return v
        end
    end
end

function skyArenaLayerEnroll:openMainPanel(bg)
	local level = 20
    local season = 36
	local score_cur = 0
	local score_max = 0
	local ranking = 0
    local startTime = 0;
    local endtime = 0;
	local battle_count_remain = 0;
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
			-- battle_count_remain = 2 - G_SKYARENA_DATA.SelfData.SCount
			-- if battle_count_remain < 0 then
			-- 	battle_count_remain = 0
			-- end
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
    local cfg = self:getActivityCfg()--getConfigItemByKey( "ActivityNormalDB" , "q_id" ,21 )

    local textCfg = {  
                        { str = game.getStrByKey("activity_time") , pos = cc.p( 600 , 280 - 20) , } ,
                        { str = game.getStrByKey("bodyguard_lv") .. "：" , pos = cc.p( 600  , 230) , } ,
                        --{ str = game.getStrByKey("activity_rule") , pos = cc.p( 75 - 30 , 280 - 40 - 20) , } ,
                        --{ str = game.getStrByKey("activity_awards") , pos =  cc.p( 75 - 30 , 260 - 180 + 20 ) , } ,
                    }
    for i = 1 , #textCfg do
        createLabel( bg , textCfg[i]["str"]  , textCfg[i]["pos"] , cc.p( 0 , 0 ) , 22 , nil , nil , nil , MColor.lable_yellow , nil , nil , MColor.black , 3 )
    end
    --活动时间
    local timeTab =  DATA_Battle:formatTime( cfg.q_time )      --活动时间
    local str = ""
    for i , v in ipairs( timeTab ) do str = str .. " " .. v end
    createLabel( bg , str , cc.p( 700, 280 - 20) , cc.p( 0 , 0 ) , 22 , nil , nil , nil , MColor.lable_black , nil , nil , MColor.black , 3 )
    createLabel( bg , cfg.q_level.."级" , cc.p( 706, 230) , cc.p( 0 , 0 ) , 22 , nil , nil , nil , MColor.lable_black , nil , nil , MColor.black , 3 )
    --说明文字
    createLabel( bg , "使用统一的属性和技能进行战斗" , cc.p( 75 , 260) , cc.p( 0 , 0 ) , 22 , nil , nil , nil , MColor.lable_yellow , nil , nil , MColor.black , 3 )
    createLabel( bg , "依次摧毁对方的箭塔和大营即可获胜" , cc.p( 75 , 230) , cc.p( 0 , 0 ) , 22 , nil , nil , nil , MColor.lable_yellow , nil , nil , MColor.black , 3 )
    createLabel( bg , "战场中定时刷新符文能量，获得后可使用符文技能" , cc.p( 75 , 200) , cc.p( 0 , 0 ) , 22 , nil , nil , nil , MColor.lable_yellow , nil , nil , MColor.black , 3 )
    
    local help = __createHelp(
    {
        parent = bg,
        str = require("src/config/PromptOp"):content(69),
        pos = cc.p(880, 490),
    })
	----------------------------------------------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------------------------
    local nodeDlg = bg
   

    --createLabel( nodeDlg , cfg.q_level or ""  , cc.p( 145  + 735 , 280 - 20) , cc.p( 0 , 0 ) , 22 , nil , nil , nil , MColor.white , nil , nil , MColor.black , 3 )
        
    ---------------------------------------------------------------------------------------------
    -- local width , height  = 490 , 110
    -- local function createRichTextNode()
    --     local tempNode = cc.Node:create()
    --     local ruleTxt = require("src/RichText").new( tempNode , cc.p( 0 , 0 ) , cc.size( width-20 , 0 ) , cc.p( 0 , 0 ) , 22 , 20 , MColor.lable_black )
	   --  ruleTxt:addText( require("src/config/PromptOp"):content(69) , MColor.lable_black , false )
	   --  ruleTxt:format()

    --     tempNode:setContentSize( cc.size( width , math.abs( ruleTxt:getContentSize().height )  ) )
    --     setNodeAttr( ruleTxt , cc.p( 0 , 0 ) , cc.p( 0 , 0  ) )

    --     return tempNode;
    -- end
    
    -- local scrollView1 = cc.ScrollView:create()	  
    -- scrollView1:setViewSize(cc.size( width + 20  , height ) )
    -- scrollView1:setPosition( cc.p( 157 , 133  ) )
    -- scrollView1:setScale(1.0)
    -- scrollView1:ignoreAnchorPointForPosition(true)
    -- local richNode = createRichTextNode()
    -- scrollView1:setContainer( richNode )
    -- scrollView1:updateInset()
    -- scrollView1:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL )
    -- scrollView1:setClippingToBounds(true)
    -- scrollView1:setBounceable(true)
    -- scrollView1:setDelegate()
    -- scrollView1:setContentOffset(cc.p(scrollView1:getContentOffset().x, scrollView1:getViewSize().height - scrollView1:getContentSize().height))
    -- nodeDlg:addChild(scrollView1)
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
        local anData =self:getActivityCfg()-- getConfigItemByKey("ActivityNormalDB","q_id",21)         -- 22
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
        --剩余几场获得奖励
	    local prizeText = string.format(game.getStrByKey("sky_arena_prize"), battle_count_remain)
        if battle_count_remain==0 then
            prizeText=game.getStrByKey("sky_arena_prize_full")
        end
	    local rtPirze = require("src/RichText").new(nodeDlg, cc.p(75, 150), cc.size(500, 20), cc.p(0.0, 0.5), 20, text_size, MColor.lable_yellow)
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
        local job = MRoleStruct:getAttr(ROLE_SCHOOL)
        local sex = MRoleStruct:getAttr(PLAYER_SEX) 
        local dropSetTab = {
            {7,8,9},
            {4,5,6}
        }
        for i=1, #awardsConfig do
            if math.floor(awardsConfig[i]["q_group"]/100) == dropSetTab[sex][job] or awardsConfig[i]["q_group"] < 400 then    
                awards[#awards+1] =  { 
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
        end

        if tablenums( awards ) > 0 then
            local groupAwards =  __createAwardGroup( awards , nil , 85 , nil , false)
            setNodeAttr( groupAwards , cc.p( 65, 25 ) , cc.p( 0 , 0 ) )
            nodeDlg:addChild(groupAwards);
        end

          -- button
        local checkReward = function()
            self.sPrizeLayer = PrizeLayer.new(self)
            Manimation:transit(
            {
                ref = self.bg,
                node = self.sPrizeLayer,
                curve = "-",
                sp = getCenterPos(self.bg),
                zOrder = 200,
                swallow = true,
            })
        end
        local lableWidth=cc.Label:createWithTTF(prizeText, g_font_path, 20):getContentSize().width
        local width2=15
        if battle_count_remain==0 then
            width2=15+79
        end
        --查看奖励
        createLinkLabel(nodeDlg, "查看奖励", cc.p(lableWidth+width2, 155), cc.p(0, 0.5), text_size, false, nil, MColor.lable_yellow, nil, checkReward, true)
    else
        -- no else logic here
	    
    end
    -------------------------------------------------------
  
	local funcCBRanking = function()
		--g_msgHandlerInst:sendNetDataByTable(PVP3V3_CS_GETRANK, "P3V3GetRankProtocol", {})
		--cclog("[PVP3V3_CS_GETRANK] sent.")
        --getRunScene():addChild(require("src/layers/skyArena/skyArenaSkillSetting").new())
        self:addChild(require("src/layers/skyArena/skyArenaSkillSetting").new())
	end
    --剩余次数
    createLabel(nodeDlg, game.getStrByKey("sky_arena_label_times"),cc.p(792, 155) , cc.p(1, 0.5), text_size, true, 10)
    --createLabel(nodeDlg, game.getStrByKey("sky_arena_button_skillset_content"),cc.p(650, 250) , cc.p(1, 0.5), text_size, true, 10)
   
    local today_times = createLabel(nodeDlg, TMP_G_SKILLPROP_POS.count,cc.p(795, 155) , cc.p(0, 0.5), text_size, true, 10,nil,MColor.white)
    --createLabel(nodeDlg, game.getStrByKey("sky_arena_button_skillset_content"),cc.p(575, 220) , cc.p(1, 0.5), text_size, true, 10)
	--设置技能
    local btnRanking = createMenuItem(nodeDlg, "res/component/button/50.png", cc.p(540, 90), funcCBRanking)
	createLabel(btnRanking, game.getStrByKey("sky_arena_button_skillset"), getCenterPos(btnRanking), cc.p(0.5, 0.5), text_size, true, 10)
    --战斗录像开关
    local recordStr=createLabel(nodeDlg, game.getStrByKey("sky_arena_record"),cc.p(600  , 200) , cc.p(0, 0), text_size, true, 10)
    
    local function changeSelect( )
        local isAutoRecorder=getLocalRecordByKey(3,"isAutoRecorder")
        setLocalRecordByKey(3,"isAutoRecorder",not isAutoRecorder)
        self.gou:setVisible(not isAutoRecorder)
        if getLocalRecordByKey(3,"isAutoRecorder") then
            print("isAutoRecordertrue")
        else
            print("isAutoRecorderfalse")
        end
    end
    local checkBox=createTouchItem(nodeDlg,"res/component/checkbox/1.png",cc.p(720,212),changeSelect)
    self.gou=createSprite(nodeDlg,"res/component/checkbox/1-1.png",cc.p(720,212))
    local isAutoRecorder=getLocalRecordByKey(3,"isAutoRecorder")
    self.gou:setVisible(isSupportReplay())
    if not isAutoRecorder then
        setLocalRecordByKey(3,"isAutoRecorder",false)
        self.gou:setVisible(false)
    end

    checkBox:setVisible(isSupportReplay())
    recordStr:setVisible(isSupportReplay())
    --中间的线
    local line=createSprite(nodeDlg,"res/common/bg/bg-3.png",cc.p(480,190))
    line:setScaleX(0.96)
    if isSeasonStart then
        local roleLevel = MRoleStruct:getAttr(ROLE_LEVEL)
        local funcCBSignupTeam = function()
            local saCommFunc = require("src/layers/skyArena/skyArenaCommFunc")
            if not ( saCommFunc.checkTeam() and saCommFunc.checkTeamMemLevel() and saCommFunc.checkTeamMemTimes() ) then
                return 
            end
            -- if not self.seasonStart then
            --     MessageBox(game.getStrByKey("sky_arena_activitynotstart"))
            --     return
            -- end
            

			g_msgHandlerInst:sendNetDataByTable(PVP3V3_CS_START_MATCH, "P3V3StartMatchProtocol", {type = 1})
			print("[PVP3V3_CS_START_MATCH] sent. team.............................................................")
            self.teamJoinBtn:setEnabled(false)
            startTimerAction(self, 0.2, false, function() self:reEnableBtns()  end)
	    end

	    local funcCBSignupPersonal = function()
            local saCommFunc = require("src/layers/skyArena/skyArenaCommFunc")
            if roleLevel < saCommFunc.limitLevel then
                MessageBox(game.getStrByKey("sky_arena_levelnot30"))
                return
            -- elseif not self.seasonStart then
            --     MessageBox(game.getStrByKey("sky_arena_activitynotstart"))
            --     return 
            elseif TMP_G_SKILLPROP_POS.count < 1 then
                MessageBox(game.getStrByKey("sky_arena_timebelow1"))
                return
            end
		    g_msgHandlerInst:sendNetDataByTable(PVP3V3_CS_START_MATCH, "P3V3StartMatchProtocol", {type = 0})
		    print("[PVP3V3_CS_START_MATCH] sent. personal.......................................................")
            self.singleJoinBtn:setEnabled(false)
            startTimerAction(self, 0.2, false, function() self:reEnableBtns()  end)
	    end

	    local btnSignupTeam = createMenuItem(nodeDlg, "res/component/button/50.png", cc.p(690, 90), funcCBSignupTeam,nil,true)
	    createLabel(btnSignupTeam, game.getStrByKey("sky_arena_button_team"), getCenterPos(btnSignupTeam), cc.p(0.5, 0.5), text_size, true, 10)
        self.teamJoinBtn = btnSignupTeam

	    local btnSignupPersonal = createMenuItem(nodeDlg, "res/component/button/50.png", cc.p(840, 90), funcCBSignupPersonal,nil,true)
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

function skyArenaLayerEnroll:reEnableBtns()
    -- 
    print("skyArenaLayerEnroll:reEnableBtns() called .............................................")
    if self.teamJoinBtn then
        self.teamJoinBtn:setEnabled(true)
    end

    if self.singleJoinBtn then
        self.singleJoinBtn:setEnabled(true)
    end
    
end

function skyArenaLayerEnroll:closeMainPanel()
	self:closeRankPanel()

--	if self.mDlgMain then
		removeFromParent(self.mDlgMain)
--		self.mDlgMain = nil
--	end

	self:closeMatchingPanel()
end

function skyArenaLayerEnroll:openRankPanel(rank_data)
	if self.mDlgRank then
		self:removeChild(self.mDlgRank)
	end

	self.mDlgRank = require("src/layers/skyArena/skyArenaRank").new(self, rank_data)
end

function skyArenaLayerEnroll:closeRankPanel()
	if self.mDlgRank then
		self:removeChild(self.mDlgRank)
		self.mDlgRank = nil
	end
end

function skyArenaLayerEnroll:closeMatchingPanel()
	if self.mDlgMatching then
		self:removeChild(self.mDlgMatching)
		self.mDlgMatching = nil
	end
end


function skyArenaLayerEnroll:openResultPanel()
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

function skyArenaLayerEnroll:closeResultPanel()
	if self.mDlgResult then
		self:removeChild(self.mDlgResult)
		self.mDlgResult = nil
	end
end


function skyArenaLayerEnroll:checkTeamInfo()
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
---------------------------------------------------------------------------------
function PrizeLayer:ctor(parent)
    self.slctPlayerIdx = 0
    self.parent = parent
    self.num = 10
    local rReward = p3V3DB.rankReward
    local saCommFunc = require("src/layers/skyArena/skyArenaCommFunc")
    rReward = saCommFunc.reOrderTableByKey(rReward)
    self.rewards=rReward
     --parent.netData.totalStarNum or 0
    --self:initAwardDropID()
    
    --parent:addChild(self,2)
    local bg = createSprite(self,"res/common/bg/bg27.png", g_scrCenter)
    --createSprite(bg,"res/common/bg/bg27-4.png", getCenterPos(bg, 0, -20),cc.p(0.5,0.5))
    createScale9Sprite( bg , "res/common/scalable/panel_inside_scale9.png", getCenterPos(bg, 0, -20), cc.size( 376 , 449 ) , cc.p(0.5 , 0.5 ) )
    createLabel(bg, "累胜奖励", cc.p(201,503), nil, 24, true)
    local closeFunc = function()   
        
        removeFromParent(self)
    end
    createTouchItem(bg,"res/component/button/x2.png",cc.p(bg:getContentSize().width - 35, bg:getContentSize().height - 25), closeFunc)
    self:createTableView(bg, cc.size(360,400), cc.p(21, 25), true)
    self:getTableView():setBounceable(true)

    -- local index = 1
    -- for i=1,#self.data do
    --     if self.data[i].prizeGotTag == 0 then
    --         index = i
    --         break
    --     end
    -- end
    -- local offsetY = -#self.data*145 + 400 + (index-1)* 145
    -- --print("offsetY1.. " .. offsetY)
    -- offsetY = offsetY > 0 and 0 or offsetY
    -- --print("offsetY2.. " .. offsetY)
    -- offsetY = (offsetY < -#self.data*145 + 400) and (-#self.data*145 + 400) or offsetY
    -- --print("offsetY3.. " .. offsetY)
    -- self:getTableView():setContentOffset(cc.p(0, offsetY))
    local curSucNum = TMP_G_SKILLPROP_POS.winCnt
    createLabel(bg, "已获胜"..curSucNum.."场战斗", cc.p(22, 445), cc.p(0, 0.5), 20):setColor(MColor.lable_yellow)
    --createLabel(bg, , cc.p(360 - 50, 445), cc.p(0.5, 0.5), 20):setColor(MColor.lable_yellow)

    registerOutsideCloseFunc( bg, closeFunc )
    self:registerScriptHandler(function(event)
        if event == "enter" then
        elseif event == "exit" then
           
        end
    end)
end

function PrizeLayer:initAwardDropID()
    local data = self.parent.fbData
    local item = data[1].starprize
    --dump(item,"item")
    local data = unserialize(item)
    --dump(data)
    for i=1,#self.data do
        for k,v in pairs(data) do
            if self.data[i].copyStarIndex == tonumber(k) then
                self.data[i].awardId = tonumber(v)
            end
        end
        
    end
    --dump(self.data, "self.data")
end

function PrizeLayer:cellSizeForTable(table,idx) 
    return 145, 360
end

function PrizeLayer:numberOfCellsInTableView(table)
    return #self.rewards
end

function PrizeLayer:tableCellTouched(table,cell)

end

function PrizeLayer:ChangeStarPrizeFlg(index)
    print("PrizeLayer:ChangeStarPrizeFlg .. " .. index)
    local cell = self:getTableView():cellAtIndex( index - 1)
    local cellData = self.data[index]
    if cell and cell.btn and cellData then
        if cell.btn and cell.sprFlg and cellData.prizeGotTag == 1 then
            cell.btn:setVisible(false)
            cell.sprFlg:setVisible(true)
        end
    end
end

function PrizeLayer:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell() 
    if nil == cell then
        cell = cc.TableViewCell:new()
    else
        cell:removeAllChildren()
    end

    --local cellData = self.data[idx + 1]
    local getFunc = function()
        
    end
    local reward=self.rewards[(idx+1)]
    --if cellData then
        local bg = createSprite(cell, "res/common/table/cell26.png", cc.p(0, 5), cc.p(0, 0))
        createLabel(bg, "获胜", cc.p(15, 110), cc.p(0, 0.5), 20):setColor(MColor.lable_black)
        createLabel(bg, "" .. reward[1] , cc.p(75, 110), cc.p(0.5, 0.5), 20)
        createLabel(bg, "场战斗可获得", cc.p(93, 110), cc.p(0, 0.5), 20):setColor(MColor.lable_black)

       
        local job = MRoleStruct:getAttr(ROLE_SCHOOL)
        local sex = MRoleStruct:getAttr(PLAYER_SEX) 
        local dropSetTab = {
            {7,8,9},
            {4,5,6}
        }
        
        --if cellData.awardId then
            local DropOp = require("src/config/DropAwardOp")
            local gdItem = DropOp:dropItem_ex(reward[2])
            local propOP = require("src/config/propOp")
            local myschool = MRoleStruct:getAttr(ROLE_SCHOOL)
            local mysex = MRoleStruct:getAttr(PLAYER_SEX)
            if gdItem then
                local i = 1
                for m,n in pairs(gdItem) do

                    local limtSex = propOP.sexLimits(n.q_item)
                    local schoolLimt = propOP.schoolLimits(n.q_item)
                    -- if (schoolLimt == myschool or schoolLimt == 0)
                    --     and (limtSex == mysex or limtSex == 0 ) then
                    if math.floor(n["q_group"]/100) == dropSetTab[sex][job] or n["q_group"] < 400 then 
                        if i > 3 then break end
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
                        icon:setPosition(cc.p(12 + (i - 0.5) * 85, 50))
                        bg:addChild(icon)
                        icon:setScale(0.9)
                        i = i + 1
                    end
                end
            end             
        --end
    --end
    
    return cell
end



return skyArenaLayerEnroll
