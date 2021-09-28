local MColor = require "src/config/FontColor"
return { new = function(t)
    --todo:需联调测试
    --[[
    1.轮空的情况
    2.不足4个队伍
    3.如果观战id为0会发生什么
    ]]
    --test data:
    --[[
    local MRoleStruct = {}
    local PLAYER_FIGHT_TEAM_ID = 2
    MRoleStruct.getAttr = function(obj, id)
        return 1
    end
    local t = {
        season = 1		-- 赛季
        , seasonName = "abc"
	    , stage = 4		-- 阶段  2是四分之一，3是半决赛，4是决赛
	    , date = 3		-- 日期
	    , time = 4		-- 时间
	    , teamData = {  -- 排名队伍
            {
	            teamID = 1		-- 战队id
	            , teamName = "team name1"		-- 战队名字
            }
            , {
	            teamID = 2		-- 战队id
	            , teamName = "team name2"		-- 战队名字
            }
            , {
	            teamID = 3		-- 战队id
	            , teamName = "team name3"		-- 战队名字
            }
            , {
	            teamID = 4		-- 战队id
	            , teamName = "team name4"		-- 战队名字
            }
            , {
	            teamID = 5		-- 战队id
	            , teamName = "team name5"		-- 战队名字
            }
            , {
	            teamID = 6		-- 战队id
	            , teamName = "team name6"		-- 战队名字
            }
            , {
	            teamID = 7		-- 战队id
	            , teamName = "team name7"		-- 战队名字
            }
            , {
	            teamID = 8		-- 战队id
	            , teamName = "team name8"		-- 战队名字
            }
        }
	    , teamRank = {  -- 队伍排名
            1, 2, 4, 3
            , 7, 4, 2, 3
        }
    }
    ]]
    --如果遇到队伍数量少于8个的情况补齐剩余队伍，队伍ID为0，用于显示ui界面，比赛时会直接轮空
    for i = 1, 8, 1 do
        if t.teamData[i] == nil then
            t.teamData[i] = {teamID = 0, teamName = ""}
        end
        if t.teamRank[i] == nil then
            t.teamRank[i] = i
        end
    end
    local Mbaseboard = require "src/functional/baseboard"
    local root = Mbaseboard.new(
    {
	    src = "res/common/bg/bg18.png",
	    close = {
		    src = {"res/component/button/x2.png", "res/component/button/x2_sel.png"},
		    offset = { x = -8, y = 4 },
	    },
	    title = {
		    src = game.getStrByKey("p3v3_entrance_title"),
		    size = 25,
		    color = MColor.lable_yellow,
		    offset = { y = -25 },
	    }
    })
    local rewardTaskReleaseBg = createSprite(root, "res/layers/rewardTask/rewardTaskReleaseBg.png", cc.p(33.0, 16.0), cc.p(0, 0))--rewardTaskReleaseBg.png移动到common
    local popoutbg = createSprite(root, "res/common/shadow/desc_shadow.png", cc.p(425.0, 298.0))
    local duiZhenBiao = createSprite(root, "res/layers/VS/duiZhenBiao.png", cc.p(425.0, 260.0))
    local label_saiJiTitle = createLabel(root, string.format(game.getStrByKey("p3v3_jueSaiPanelTitle"), t.seasonName, t.stage == 2 and "1/4" or (t.stage == 3 and "1/2" or "")), cc.p(425.0, 425.0), cc.p(0.5, 0.5), 20, nil, nil, nil, MColor.lable_yellow)
    local label_saiJiTimeSpan = createLabel(root, formatDateTimeStr(t.date), cc.p(425.0, 400.0), cc.p(0.5, 0.5), 18, nil, nil, nil, MColor.lable_yellow)--需要服务器改成显示日期
    local jieSuan_zhan = createSprite(root, "res/layers/VS/jieSuan_zhan.png", cc.p(424.6067, 262.18), nil, 0, 0.25)
    local label_duiWuName_1 = createLabel(root, t.teamData[1].teamName, cc.p(276.15, 371.0), cc.p(1.0, 0.5), 20, nil, nil, nil, MColor.lable_yellow)
    local label_duiWuName_8 = createLabel(root, t.teamData[8].teamName, cc.p(276.15, 297.0), cc.p(1.0, 0.5), 20, nil, nil, nil, MColor.lable_yellow)
    local label_duiWuName_4 = createLabel(root, t.teamData[4].teamName, cc.p(276.15, 223.0), cc.p(1.0, 0.5), 20, nil, nil, nil, MColor.lable_yellow)
    local label_duiWuName_5 = createLabel(root, t.teamData[5].teamName, cc.p(276.15, 149.0), cc.p(1.0, 0.5), 20, nil, nil, nil, MColor.lable_yellow)
    local label_duiWuName_2 = createLabel(root, t.teamData[2].teamName, cc.p(572.4096, 371.0), cc.p(0.0, 0.5), 20, nil, nil, nil, MColor.lable_yellow)
    local label_duiWuName_7 = createLabel(root, t.teamData[7].teamName, cc.p(572.4096, 297.0), cc.p(0.0, 0.5), 20, nil, nil, nil, MColor.lable_yellow)
    local label_duiWuName_3 = createLabel(root, t.teamData[3].teamName, cc.p(572.4096, 223.0), cc.p(0.0, 0.5), 20, nil, nil, nil, MColor.lable_yellow)
    local label_duiWuName_6 = createLabel(root, t.teamData[6].teamName, cc.p(572.4096, 149.0), cc.p(0.0, 0.5), 20, nil, nil, nil, MColor.lable_yellow)
    if t.stage == 2 then
        --开始的8条横杠
        local scale9_team1_z_first = createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(2, 231 - 7), cc.size(41, 5), cc.p(0, 0))
        local scale9_team8_z_first = createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(2, 231 - 81), cc.size(41, 5), cc.p(0, 0))
        local scale9_team4_z_first = createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(2, 231 - 7 - 148), cc.size(41, 5), cc.p(0, 0))
        local scale9_team5_z_first = createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(2, 231 - 81 - 148), cc.size(41, 5), cc.p(0, 0))
        local scale9_team2_z_first = createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(249, 231 - 7), cc.size(41, 5), cc.p(0, 0))
        local scale9_team7_z_first = createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(249, 231 - 81), cc.size(41, 5), cc.p(0, 0))
        local scale9_team3_z_first = createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(249, 231 - 7 - 148), cc.size(41, 5), cc.p(0, 0))
        local scale9_team6_z_first = createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(249, 231 - 81 - 148), cc.size(41, 5), cc.p(0, 0))
        --竖线
        local scale9_team1_z_second = createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(38, 231 - 39), cc.size(5, 32), cc.p(0, 0))
        local scale9_team8_z_second = createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(38, 231 - 76), cc.size(5, 32), cc.p(0, 0))
        createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(38, 231 - 44), cc.size(5, 5), cc.p(0, 0))
        local scale9_team4_z_second = createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(38, 231 - 39 - 148), cc.size(5, 32), cc.p(0, 0))
        local scale9_team5_z_second = createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(38, 231 - 76 - 148), cc.size(5, 32), cc.p(0, 0))
        createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(38, 231 - 192), cc.size(5, 5), cc.p(0, 0))
        local scale9_team2_z_second = createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(249, 231 - 39), cc.size(5, 32), cc.p(0, 0))
        local scale9_team7_z_second = createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(249, 231 - 76), cc.size(5, 32), cc.p(0, 0))
        createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(249, 231 - 44), cc.size(5, 5), cc.p(0, 0))
        local scale9_team3_z_second = createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(249, 231 - 39 - 148), cc.size(5, 32), cc.p(0, 0))
        local scale9_team6_z_second = createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(249, 231 - 76 - 148), cc.size(5, 32), cc.p(0, 0))
        createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(249, 231 - 192), cc.size(5, 5), cc.p(0, 0))
        --观战按钮
        local watchIcon_siFenZhiYi_1vs8 = createTouchItem(root, "res/layers/VS/watchIcon.png", cc.p(319.8094, 333.0), function() g_msgHandlerInst:sendNetDataByTable(FIGHTTEAM3V3_CS_WATCH, "FightTeam3v3WatchProtocol", {teamID = t.teamData[1].teamID}) end)
        local watchIcon_siFenZhiYi_4vs5 = createTouchItem(root, "res/layers/VS/watchIcon.png", cc.p(319.8094, 186.0), function() g_msgHandlerInst:sendNetDataByTable(FIGHTTEAM3V3_CS_WATCH, "FightTeam3v3WatchProtocol", {teamID = t.teamData[4].teamID}) end)
        local watchIcon_siFenZhiYi_2vs7 = createTouchItem(root, "res/layers/VS/watchIcon.png", cc.p(530.8753, 333.0), function() g_msgHandlerInst:sendNetDataByTable(FIGHTTEAM3V3_CS_WATCH, "FightTeam3v3WatchProtocol", {teamID = t.teamData[2].teamID}) end)
        local watchIcon_siFenZhiYi_3vs6 = createTouchItem(root, "res/layers/VS/watchIcon.png", cc.p(530.8753, 186.0), function() g_msgHandlerInst:sendNetDataByTable(FIGHTTEAM3V3_CS_WATCH, "FightTeam3v3WatchProtocol", {teamID = t.teamData[3].teamID}) end)
    elseif t.stage == 3 then
        --开始的8条横杠
        local scale9_team1_z_first = createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(2, 231 - 7), cc.size(41, 5), cc.p(0, 0))
        local scale9_team8_z_first = createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(2, 231 - 81), cc.size(41, 5), cc.p(0, 0))
        local scale9_team4_z_first = createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(2, 231 - 7 - 148), cc.size(41, 5), cc.p(0, 0))
        local scale9_team5_z_first = createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(2, 231 - 81 - 148), cc.size(41, 5), cc.p(0, 0))
        local scale9_team2_z_first = createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(249, 231 - 7), cc.size(41, 5), cc.p(0, 0))
        local scale9_team7_z_first = createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(249, 231 - 81), cc.size(41, 5), cc.p(0, 0))
        local scale9_team3_z_first = createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(249, 231 - 7 - 148), cc.size(41, 5), cc.p(0, 0))
        local scale9_team6_z_first = createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(249, 231 - 81 - 148), cc.size(41, 5), cc.p(0, 0))
        --进入前4强的竖线
        local oneWinTeamID_left
        if t.teamRank[1] == t.teamData[1].teamID or t.teamRank[2] == t.teamData[1].teamID or t.teamRank[3] == t.teamData[1].teamID or t.teamRank[4] == t.teamData[1].teamID then--是否属于前4名，属于前4名说明进入了半决赛
            oneWinTeamID_left = t.teamData[1].teamID
            local scale9_team1_z_second = createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(38, 231 - 39), cc.size(5, 32), cc.p(0, 0))
        elseif t.teamRank[1] == t.teamData[8].teamID or t.teamRank[2] == t.teamData[8].teamID or t.teamRank[3] == t.teamData[8].teamID or t.teamRank[4] == t.teamData[8].teamID then
            oneWinTeamID_left = t.teamData[8].teamID
            local scale9_team8_z_second = createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(38, 231 - 76), cc.size(5, 32), cc.p(0, 0))
        end
        if t.teamRank[1] == t.teamData[4].teamID or t.teamRank[2] == t.teamData[4].teamID or t.teamRank[3] == t.teamData[4].teamID or t.teamRank[4] == t.teamData[4].teamID then
            local scale9_team4_z_second = createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(38, 231 - 39 - 148), cc.size(5, 32), cc.p(0, 0))
        elseif t.teamRank[1] == t.teamData[5].teamID or t.teamRank[2] == t.teamData[5].teamID or t.teamRank[3] == t.teamData[5].teamID or t.teamRank[4] == t.teamData[5].teamID then
            local scale9_team5_z_second = createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(38, 231 - 76 - 148), cc.size(5, 32), cc.p(0, 0))
        end
        local onWinTeamID_right
        if t.teamRank[1] == t.teamData[2].teamID or t.teamRank[2] == t.teamData[2].teamID or t.teamRank[3] == t.teamData[2].teamID or t.teamRank[4] == t.teamData[2].teamID then--是否属于前4名，属于前4名说明进入了半决赛
            onWinTeamID_right = t.teamData[2].teamID
            local scale9_team2_z_second = createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(249, 231 - 39), cc.size(5, 32), cc.p(0, 0))
        elseif t.teamRank[1] == t.teamData[7].teamID or t.teamRank[2] == t.teamData[7].teamID or t.teamRank[3] == t.teamData[7].teamID or t.teamRank[4] == t.teamData[7].teamID then
            onWinTeamID_right = t.teamData[7].teamID
            local scale9_team7_z_second = createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(249, 231 - 76), cc.size(5, 32), cc.p(0, 0))
        end
        if t.teamRank[1] == t.teamData[3].teamID or t.teamRank[2] == t.teamData[3].teamID or t.teamRank[3] == t.teamData[3].teamID or t.teamRank[4] == t.teamData[3].teamID then
            local scale9_team3_z_second = createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(249, 231 - 39 - 148), cc.size(5, 32), cc.p(0, 0))
        elseif t.teamRank[1] == t.teamData[6].teamID or t.teamRank[2] == t.teamData[6].teamID or t.teamRank[3] == t.teamData[6].teamID or t.teamRank[4] == t.teamData[6].teamID then
            local scale9_team6_z_second = createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(249, 231 - 76 - 148), cc.size(5, 32), cc.p(0, 0))
        end
        --左侧横竖线
        createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(38, 231 - 44), cc.size(46, 5), cc.p(0, 0))
        createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(79, 231 - 113), cc.size(5, 69), cc.p(0, 0))
        createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(38, 231 - 192), cc.size(46, 5), cc.p(0, 0))
        createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(79, 231 - 187), cc.size(5, 69), cc.p(0, 0))
        createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(79, 231 - 118), cc.size(5, 5), cc.p(0, 0))
        --右侧横竖线
        createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(208, 231 - 44), cc.size(46, 5), cc.p(0, 0))
        createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(208, 231 - 113), cc.size(5, 69), cc.p(0, 0))
        createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(208, 231 - 192), cc.size(46, 5), cc.p(0, 0))
        createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(208, 231 - 187), cc.size(5, 69), cc.p(0, 0))
        createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(208, 231 - 118), cc.size(5, 5), cc.p(0, 0))
        --观战按钮
        local watchIcon_erFenZhiYi_left = createTouchItem(root, "res/layers/VS/watchIcon.png", cc.p(360.8387, 260.0), function() g_msgHandlerInst:sendNetDataByTable(FIGHTTEAM3V3_CS_WATCH, "FightTeam3v3WatchProtocol", {teamID = oneWinTeamID_left}) end)
        local watchIcon_erFenZhiYi_right = createTouchItem(root, "res/layers/VS/watchIcon.png", cc.p(489.4132, 260.0), function() g_msgHandlerInst:sendNetDataByTable(FIGHTTEAM3V3_CS_WATCH, "FightTeam3v3WatchProtocol", {teamID = onWinTeamID_right}) end)
    elseif t.stage == 4 then
        --开始的8条横杠
        local scale9_team1_z_first = createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(2, 231 - 7), cc.size(41, 5), cc.p(0, 0))
        local scale9_team8_z_first = createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(2, 231 - 81), cc.size(41, 5), cc.p(0, 0))
        local scale9_team4_z_first = createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(2, 231 - 7 - 148), cc.size(41, 5), cc.p(0, 0))
        local scale9_team5_z_first = createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(2, 231 - 81 - 148), cc.size(41, 5), cc.p(0, 0))
        local scale9_team2_z_first = createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(249, 231 - 7), cc.size(41, 5), cc.p(0, 0))
        local scale9_team7_z_first = createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(249, 231 - 81), cc.size(41, 5), cc.p(0, 0))
        local scale9_team3_z_first = createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(249, 231 - 7 - 148), cc.size(41, 5), cc.p(0, 0))
        local scale9_team6_z_first = createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(249, 231 - 81 - 148), cc.size(41, 5), cc.p(0, 0))
        --进入前4强的4条竖线
        if t.teamRank[1] == t.teamData[1].teamID or t.teamRank[2] == t.teamData[1].teamID or t.teamRank[3] == t.teamData[1].teamID or t.teamRank[4] == t.teamData[1].teamID then--是否属于前4名，属于前4名说明进入了半决赛
            local scale9_team1_z_second = createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(38, 231 - 39), cc.size(5, 32), cc.p(0, 0))
        elseif t.teamRank[1] == t.teamData[8].teamID or t.teamRank[2] == t.teamData[8].teamID or t.teamRank[3] == t.teamData[8].teamID or t.teamRank[4] == t.teamData[8].teamID then
            local scale9_team8_z_second = createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(38, 231 - 76), cc.size(5, 32), cc.p(0, 0))
        end
        if t.teamRank[1] == t.teamData[4].teamID or t.teamRank[2] == t.teamData[4].teamID or t.teamRank[3] == t.teamData[4].teamID or t.teamRank[4] == t.teamData[4].teamID then
            local scale9_team4_z_second = createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(38, 231 - 39 - 148), cc.size(5, 32), cc.p(0, 0))
        elseif t.teamRank[1] == t.teamData[5].teamID or t.teamRank[2] == t.teamData[5].teamID or t.teamRank[3] == t.teamData[5].teamID or t.teamRank[4] == t.teamData[5].teamID then
            local scale9_team5_z_second = createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(38, 231 - 76 - 148), cc.size(5, 32), cc.p(0, 0))
        end
        if (t.teamRank[1] == t.teamData[1].teamID or t.teamRank[2] == t.teamData[1].teamID or t.teamRank[1] == t.teamData[8].teamID or t.teamRank[2] == t.teamData[8].teamID) then
            createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(79, 231 - 113), cc.size(5, 69), cc.p(0, 0))
        else
            createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(79, 231 - 187), cc.size(5, 69), cc.p(0, 0))
        end
        if t.teamRank[1] == t.teamData[2].teamID or t.teamRank[2] == t.teamData[2].teamID or t.teamRank[3] == t.teamData[2].teamID or t.teamRank[4] == t.teamData[2].teamID then--是否属于前4名，属于前4名说明进入了半决赛
            local scale9_team2_z_second = createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(249, 231 - 39), cc.size(5, 32), cc.p(0, 0))
        elseif t.teamRank[1] == t.teamData[7].teamID or t.teamRank[2] == t.teamData[7].teamID or t.teamRank[3] == t.teamData[7].teamID or t.teamRank[4] == t.teamData[7].teamID then
            local scale9_team7_z_second = createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(249, 231 - 76), cc.size(5, 32), cc.p(0, 0))
        end
        if t.teamRank[1] == t.teamData[3].teamID or t.teamRank[2] == t.teamData[3].teamID or t.teamRank[3] == t.teamData[3].teamID or t.teamRank[4] == t.teamData[3].teamID then
            local scale9_team3_z_second = createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(249, 231 - 39 - 148), cc.size(5, 32), cc.p(0, 0))
        elseif t.teamRank[1] == t.teamData[6].teamID or t.teamRank[2] == t.teamData[6].teamID or t.teamRank[3] == t.teamData[6].teamID or t.teamRank[4] == t.teamData[6].teamID then
            local scale9_team6_z_second = createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(249, 231 - 76 - 148), cc.size(5, 32), cc.p(0, 0))
        end
        --进入前2强的2条竖线
        if (t.teamRank[1] == t.teamData[2].teamID or t.teamRank[2] == t.teamData[2].teamID or t.teamRank[1] == t.teamData[7].teamID or t.teamRank[2] == t.teamData[7].teamID) then
            createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(208, 231 - 113), cc.size(5, 69), cc.p(0, 0))
        else
            createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(208, 231 - 187), cc.size(5, 69), cc.p(0, 0))
        end
        --4条中间的横杠
        createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(38, 231 - 44), cc.size(46, 5), cc.p(0, 0))
        createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(38, 231 - 192), cc.size(46, 5), cc.p(0, 0))
        createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(208, 231 - 44), cc.size(46, 5), cc.p(0, 0))
        createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(208, 231 - 192), cc.size(46, 5), cc.p(0, 0))
        --2条中间的横杠
        createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(79, 231 - 118), cc.size(41, 5), cc.p(0, 0))
        createScale9Sprite(duiZhenBiao, "res/layers/VS/yellowBlcok.png", cc.p(172, 231 - 118), cc.size(41, 5), cc.p(0, 0))
        --观战按钮
        local watchIcon_final = createTouchItem(root, "res/layers/VS/watchIcon.png", cc.p(425.0, 211.013), function() g_msgHandlerInst:sendNetDataByTable(FIGHTTEAM3V3_CS_WATCH, "FightTeam3v3WatchProtocol", {teamID = t.teamRank[1]}) end)
    end
    local bool_canGetIn = false
    for k, v in ipairs(t.teamData) do
        if (
                (t.teamRank[1] == v.teamID or t.teamRank[2] == v.teamID or t.teamRank[3] == v.teamID or t.teamRank[4] == v.teamID or t.teamRank[5] == v.teamID or t.teamRank[6] == v.teamID or t.teamRank[7] == v.teamID or t.teamRank[8] == v.teamID)
                and v.teamID == MRoleStruct:getAttr(PLAYER_FIGHT_TEAM_ID)
                and t.stage == 2 --四分之一决赛
            )
            or
            (
                (t.teamRank[1] == v.teamID or t.teamRank[2] == v.teamID or t.teamRank[3] == v.teamID or t.teamRank[4] == v.teamID)
                and v.teamID == MRoleStruct:getAttr(PLAYER_FIGHT_TEAM_ID)
                and t.stage == 3 --半决赛
            )
            or
            (
                (t.teamRank[1] == v.teamID or t.teamRank[2] == v.teamID)
                and v.teamID == MRoleStruct:getAttr(PLAYER_FIGHT_TEAM_ID)
                and t.stage == 4 --决赛
            ) then
            bool_canGetIn = true
        end
    end
    local canJia_menu, canJia_btn = require("src/component/button/MenuButton").new(
    {
	    parent = root,
	    pos = cc.p(root:getContentSize().width / 2, 60),
        src = {"res/component/button/50.png", "res/component/button/50_sel.png", "res/component/button/50_gray.png"},
	    label = {
		    src = game.getStrByKey("p3v3_jueSai_btn_title"),
		    size = 22,
		    color = MColor.lable_yellow,
	    },
	    cb = function(tag, node)
            g_msgHandlerInst:sendNetDataByTable(FIGHTTEAM3V3_CS_GETINGAME, "FightTeam3v3GetInGameProtocol", {})
	    end,
    })
    canJia_btn:setEnabled(bool_canGetIn)
    --战斗录像开关
    local recordStr=createLabel(root, game.getStrByKey("sky_arena_record"),cc.p(275, 60) , cc.p(1, 0.5), 22, true, 10)
    local function changeSelect( )
        local isAutoRecorder=getLocalRecordByKey(3,"isAutoRecorder3v3")
        setLocalRecordByKey(3,"isAutoRecorder3v3",not isAutoRecorder)
        root.gou:setVisible(not isAutoRecorder)
    end
    local checkBox=createTouchItem(root,"res/component/checkbox/1.png",cc.p(164,60),changeSelect)
    root.gou=createSprite(root,"res/component/checkbox/1-1.png",cc.p(164,60))
    local isAutoRecorder=getLocalRecordByKey(3,"isAutoRecorder3v3")
    root.gou:setVisible(isSupportReplay())
    if not isAutoRecorder then
        setLocalRecordByKey(3,"isAutoRecorder3v3",false)
        root.gou:setVisible(false)
    end
    checkBox:setVisible(isSupportReplay())
    recordStr:setVisible(isSupportReplay())
    SwallowTouches(root)
    return root
end}