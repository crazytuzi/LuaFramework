local VSMapLayer = class("VSMapLayer", require("src/base/MainMapLayer.lua"))
local st_normal, st_dead, st_leave = 1, 2, 3    -- 1是进入，2是死亡，3是离开
local st_game_invalid, st_game_enter, st_game_zhunBei, st_game_fight, st_game_over = 0, 1, 2, 3, 4      --0是无效，1是进入，2是准备，3是战斗，4是结束
local line_height = 36

function VSMapLayer:ctor(str_name, parent, pos, mapId, isFb)
    ----------------------------------------------通用部分:-----------------------------------------------------------------------------
    self.parent = parent
	self:initializePre()
	self:loadMapInfo(str_name, mapId, pos)
	self.parent:addChild(self, -1)
	self:loadSpritesPre()
	self.has_loadmap = true
    ------------------------------------------------------------------------------------------------------------------------------------
    self.is3v3 = true
    -----------------------------------------------start 玩家信息窗口:------------------------------------------------------------------
    --使用local 变量 影响范围更小
    self.panel_node = cc.Node:create()
    G_MAINSCENE:addChild(self.panel_node, require("src/config/CommDef").ZVALUE_UI - 1)
    local pos_playersInfoNode = cc.p(display.width - (1050 - 706), display.height)
    self.node_playersInfo = cc.Node:create()
    self.node_playersInfo:setVisible(false)--为了让观战者不显示本界面
    self.node_playersInfo:setPosition(pos_playersInfoNode)
    self.panel_node:addChild(self.node_playersInfo)
    local spr_playersInfoBar = cc.Sprite:create("res/common/bg/jiFenPai_bar_bg.png")
    spr_playersInfoBar:setAnchorPoint(cc.p(0, 1))
    spr_playersInfoBar:setPosition(cc.p(0, 0))
    self.node_playersInfo:addChild(spr_playersInfoBar)
    self.headerHeight = spr_playersInfoBar:getContentSize().height
    local blackLayer_width = spr_playersInfoBar:getContentSize().width
    self.spr_playersInfoBG = cc.Sprite:create("res/common/bg/jiFenPai_bg.png")
    self.spr_playersInfoBG:setAnchorPoint(cc.p(0.5, 1))
    self.spr_playersInfoBG:setPosition(cc.p(spr_playersInfoBar:getContentSize().width / 2, - self.headerHeight + 5))
    self.node_playersInfo:addChild(self.spr_playersInfoBG)
    self.label_head = createLabel(self.node_playersInfo, "", cc.p(35, - self.headerHeight / 2), cc.p(0, 0.5), 22)
    self.label_head:setColor(MColor.white)
    self.playersInfo = {}
    --[[
    --test code:
    self.playersInfo = {
        {
	        roleSID = 1
	        , state = 1		-- 1是进入，2是死亡，3是离开
	        , fightTeamID = 3	-- 战队id
	        , name = "角色名字六字"		-- 玩家名字
        }
        , {
	        roleSID = 1
	        , state = 2		-- 1是进入，2是死亡，3是离开
	        , fightTeamID = 3	-- 战队id
	        , name = "def"		-- 玩家名字
        }
        , {
	        roleSID = 1
	        , state = 2		-- 1是进入，2是死亡，3是离开
	        , fightTeamID = 3	-- 战队id
	        , name = "abcd"		-- 玩家名字
        }
        , {
	        roleSID = 1
	        , state = 3		-- 1是进入，2是死亡，3是离开
	        , fightTeamID = 4	-- 战队id
	        , name = "角色名字六字"		-- 玩家名字
        }
    }
    ]]
    local enemyMemberCount = index
    local btn_jiFenPaiArrow = createTouchItem(self.node_playersInfo, "res/component/button/57_2.png", cc.p(blackLayer_width - self.headerHeight / 2 - 5, - self.headerHeight / 2), function(sender)
        sender:setRotation(sender:getRotation() + 180)
        self.spr_playersInfoBG:setVisible(not self.spr_playersInfoBG:isVisible())
        if not self.spr_playersInfoBG:isVisible() then
            while(self.node_playersInfo:getChildByTag(require("src/config/CommDef").TAG_3V3_PLAYERSINFO_CONTENT)) do
                self.node_playersInfo:removeChildByTag(require("src/config/CommDef").TAG_3V3_PLAYERSINFO_CONTENT)
            end
        else
            self:refreshPlayersInfo()
        end
    end)
    btn_jiFenPaiArrow:setRotation(180)
	--根据网络状况校准的真实时间倒计时
    self.timeBackground = createSprite(self.panel_node,"res/mainui/sideInfo/timeBg.png",cc.p(display.width-154-171, g_scrSize.height), cc.p(0, 1))
    local timeBgSize = self.timeBackground:getContentSize()
	self.labTimeTitle = createLabel(self.timeBackground,game.getStrByKey("battle_countdown"), cc.p(timeBgSize.width/2, timeBgSize.height - 16), nil, 18, true)
	self.labTime = createLabel(self.timeBackground, self.leftSecond, cc.p(timeBgSize.width/2, timeBgSize.height/2-8), cc.p(0.5,0.5),40,true,nil,nil,MColor.lable_yellow)
    local timeUpdate = function(timeElapsed)
		if not self.leftSecond or math.floor(self.leftSecond - timeElapsed) < 0 then
			return
		end
        self.leftSecond = self.leftSecond - timeElapsed
        self.labTime:setString(math.floor(self.leftSecond))
	end
	self.timeNode = startTimerActionEx(self.timeBackground, 0.01, true, timeUpdate)
    -----------------------------------------------end 玩家信息窗口------------------------------------------------------------------
    --只有从false变为true的时候才触发加时赛特效，如果已经是持续的true状态有可能是断线重连，不需要显示特效
    self.overTime = true
    self.eff_door_0, self.eff_door_1 = nil, nil
    self:registerScriptHandler(function(event)
	    if event == "enter" then
            for k, v in ipairs(G_VS_MAP_MSG_CACHE) do
                if v.cache_type == "game" then
                    self:process_msg_fightteam3v3_sc_gamestatenotify(v.data)
                elseif v.cache_type == "member" then
                    self:process_msg_fightteam3v3_sc_memberstatenotify(v.data)
                elseif v.cache_type == "timeCountDown" then
                    self:process_msg_fightteam3v3_sc_countdowntime(v.data)
                end
            end
            G_VS_MAP_MSG_CACHE = {}
            self.ready = true
            --战斗结算
            g_msgHandlerInst:registerMsgHandler(FIGHTTEAM3V3_SC_GAMEENDNOTIFY, function(buff)
                local t = g_msgHandlerInst:convertBufferToTable("FightTeam3v3GameEndNotifyProtocol", buff)
                --test code:
                --[[
                local t = {
                    winTeamID = 1
                    , myFightTeam = {
	                    fightTeamID = 1		-- 战队id
	                    , fightTeamName = "战队名称"		-- 战队名称
	                    , win = 3		-- 胜利场次
	                    , lose = 4		-- 失败场次
	                    , members = {   -- 成员信息
                            {
	                            roleSID = 1
	                            , roleName = "abc"		-- 角色名称
	                            , battle = 3000		-- 战力
	                            , kill = 8		-- 杀人数
                            }
                            , {
	                            roleSID = 2
	                            , roleName = "abcdd"		-- 角色名称
	                            , battle = 3003		-- 战力
	                            , kill = 0		-- 杀人数
                            }
                            , {
	                            roleSID = 3
	                            , roleName = "adfdbcdd"		-- 角色名称
	                            , battle = 3000		-- 战力
	                            , kill = 0		-- 杀人数
                            }
                        }
                    }
                    , enemyFightTeam = {
	                    fightTeamID = 2		-- 战队id
	                    , fightTeamName = "战队名称2"		-- 战队名称
	                    , win = 3		-- 胜利场次
	                    , lose = 4		-- 失败场次
	                    , members = {   -- 成员信息
                            {
	                            roleSID = 1
	                            , roleName = "abc"		-- 角色名称
	                            , battle = 3002		-- 战力
	                            , kill = 8		-- 杀人数
                            }
                            , {
	                            roleSID = 2
	                            , roleName = "abcdd"		-- 角色名称
	                            , battle = 3000		-- 战力
	                            , kill = 0		-- 杀人数
                            }
                        }
                    }
                }
                ]]
                local jieSuan_bg = CreateSettleFrame(self.panel_node, cc.p(display.cx, display.cy + 50), 325, cc.p(0.5, 0.5))
                local img_zhan = createSprite(jieSuan_bg, "res/layers/VS/jieSuan_zhan.png", cc.p(480, 200))
                local jieSuan_biSaiJieGuo_2 = createSprite(jieSuan_bg, "res/common/effectFont/jieSuan_biSaiJieGuo.png", cc.p(480, 424))
                local label_font_size = 22
                local line_height = 24
                local richTextSize_width = 960
                local posY_firstLine = 223
                local distance_nextLine = 25
                local distance_betweenMemberLine = 58
                local posX_teamBlock = 154
                createSprite(jieSuan_bg, t.winTeamID == t.myFightTeam.fightTeamID and "res/common/effectFont/jieSuan_sheng.png" or "res/common/effectFont/jieSuan_bai.png", cc.p(posX_teamBlock + 50, 307))
                createLabel(jieSuan_bg, t.myFightTeam.fightTeamName, cc.p(posX_teamBlock, 256), cc.p(0.0, 0.5), 22, nil, nil, nil, MColor.yellow)
                local int_total_shaRenShu_us = 0
                for k, v in ipairs(t.myFightTeam.members) do
                    local posY_currentLine_first = posY_firstLine - (k - 1) * distance_betweenMemberLine
                    createLabel(jieSuan_bg, v.roleName, cc.p(posX_teamBlock, posY_currentLine_first), cc.p(0.0, 0.5), 22, nil, nil, nil, MColor.blue)
                    local richText_killNumber = require("src/RichText").new(jieSuan_bg, cc.p(posX_teamBlock + 150, posY_currentLine_first), cc.size(richTextSize_width, line_height), cc.p(0, 0.5), line_height, label_font_size, MColor.white)
                    richText_killNumber:setAutoWidth()
                    richText_killNumber:addText(
                        string.format(game.getStrByKey("p3v3_jieSuan_killNum_format"), v.kill)
                    )
                    richText_killNumber:format()
                    local richText_battlePoint = require("src/RichText").new(jieSuan_bg, cc.p(posX_teamBlock, posY_currentLine_first - distance_nextLine), cc.size(richTextSize_width, line_height), cc.p(0, 0.5), line_height, label_font_size, MColor.white)
                    richText_battlePoint:setAutoWidth()
                    richText_battlePoint:addText(
                        string.format(game.getStrByKey("p3v3_jieSuan_zhanDouLi_format"), v.battle)
                    )
                    richText_battlePoint:format()
                    int_total_shaRenShu_us = int_total_shaRenShu_us + v.kill
                end
                local int_currentDaoJiShi = 30
                local richText_jieSuanDaoJiShi = require("src/RichText").new(jieSuan_bg, cc.p(jieSuan_bg:getContentSize().width / 2, -72), cc.size(350, 30), cc.p(0.5, 0.5), 30, 22, MColor.white)
                richText_jieSuanDaoJiShi:setAutoWidth()
                richText_jieSuanDaoJiShi:addText(string.format(game.getStrByKey("p3v3_jieSuan_dialog_daoJiShi"), int_currentDaoJiShi))
                richText_jieSuanDaoJiShi:format()
                local btn_fuHuo
                function btnCallBack()
                    g_msgHandlerInst:sendNetDataByTable(FIGHTTEAM3V3_CS_QUITGAME, "FightTeam3v3QuitGameProtocol", {})
                    jieSuan_bg:removeFromParent()
                end
                btn_fuHuo = createMenuItem(jieSuan_bg, "res/component/button/50.png", cc.p(jieSuan_bg:getContentSize().width / 2, -30), btnCallBack)
                --停止录制视频
                if getLocalRecordByKey(3,"isAutoRecorder3v3") and isSupportReplay() then
                    local discardRecordingBtn=createTouchItem(jieSuan_bg,"res/layers/skyArena/result/record.png",cc.p(jieSuan_bg:getContentSize().width / 2,60),function() displayRecordingContent() end)
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
                createLabel(btn_fuHuo, game.getStrByKey("p3v3_jieSuan_que_ding"), cc.p(btn_fuHuo:getContentSize().width / 2, btn_fuHuo:getContentSize().height / 2), cc.p(.5, .5), 22, false, 0, nil, require("src/config/FontColor").lable_yellow)
                jieSuan_bg:runAction(cc.Sequence:create({
                    cc.Repeat:create(cc.Sequence:create({
                        cc.DelayTime:create(1)
                        , cc.CallFunc:create(function()
                            int_currentDaoJiShi = int_currentDaoJiShi - 1
                            richText_jieSuanDaoJiShi:removeFromParent()
                            richText_jieSuanDaoJiShi = require("src/RichText").new(jieSuan_bg, cc.p(jieSuan_bg:getContentSize().width / 2, -72), cc.size(350, 30), cc.p(0.5, 0.5), 30, 22, MColor.white)
                            richText_jieSuanDaoJiShi:setAutoWidth()
                            richText_jieSuanDaoJiShi:addText(string.format(game.getStrByKey("p3v3_jieSuan_dialog_daoJiShi"), int_currentDaoJiShi))
                            richText_jieSuanDaoJiShi:format()
                        end)
                    }), int_currentDaoJiShi)
                    , cc.CallFunc:create(btnCallBack)
                }))
                if t.enemyFightTeam.fightTeamID == 0 then -- 敌人的队伍id为0代表轮空，没有找到匹配的队伍, 不需要显示敌人队伍信息
                    return
                end
                posX_teamBlock = 624
                createSprite(jieSuan_bg, t.winTeamID == t.enemyFightTeam.fightTeamID and "res/common/effectFont/jieSuan_sheng.png" or "res/common/effectFont/jieSuan_bai.png", cc.p(posX_teamBlock + 50, 307))
                createLabel(jieSuan_bg, t.enemyFightTeam.fightTeamName, cc.p(posX_teamBlock, 256), cc.p(0.0, 0.5), 22, nil, nil, nil, MColor.yellow)
                local int_total_shaRenShu_enemy = 0
                for k, v in ipairs(t.enemyFightTeam.members) do
                    local posY_currentLine_first = posY_firstLine - (k - 1) * distance_betweenMemberLine
                    createLabel(jieSuan_bg, v.roleName, cc.p(posX_teamBlock, posY_currentLine_first), cc.p(0.0, 0.5), 22, nil, nil, nil, MColor.red)
                    local richText_killNumber = require("src/RichText").new(jieSuan_bg, cc.p(posX_teamBlock + 150, posY_currentLine_first), cc.size(richTextSize_width, line_height), cc.p(0, 0.5), line_height, label_font_size, MColor.white)
                    richText_killNumber:setAutoWidth()
                    richText_killNumber:addText(
                        string.format(game.getStrByKey("p3v3_jieSuan_killNum_format"), v.kill)
                    )
                    richText_killNumber:format()
                    local richText_battlePoint = require("src/RichText").new(jieSuan_bg, cc.p(posX_teamBlock, posY_currentLine_first - distance_nextLine), cc.size(richTextSize_width, line_height), cc.p(0, 0.5), line_height, label_font_size, MColor.white)
                    richText_battlePoint:setAutoWidth()
                    richText_battlePoint:addText(
                        string.format(game.getStrByKey("p3v3_jieSuan_zhanDouLi_format"), v.battle)
                    )
                    richText_battlePoint:format()
                    int_total_shaRenShu_enemy = int_total_shaRenShu_enemy + v.kill
                end
                local label_kill_us = createLabel(jieSuan_bg, int_total_shaRenShu_us, cc.p(460 - 1, 327), cc.p(1, 0.5), 22)
                label_kill_us:setColor(MColor.blue)
                local label_kill_other = createLabel(jieSuan_bg, int_total_shaRenShu_enemy, cc.p(500, 327), cc.p(0, 0.5), 22)
                label_kill_other:setColor(MColor.red)
                local spr_vsIcon = createSprite(jieSuan_bg, "res/layers/VS/jieSuan_winIcon.png", cc.p(480, 327))
            end)
	    elseif event == "exit" then
            g_msgHandlerInst:registerMsgHandler(FIGHTTEAM3V3_SC_GAMEENDNOTIFY, nil)
            --停止录制视频
            if getLocalRecordByKey(3,"isAutoRecorder3v3") and isSupportReplay() then
                stopRecording()
            end
	    end
    end)
    local exitBtnWidth, exitBtnHeight = 138, 58
    local topOffset = 75
    local menu, exit_btn = require("src/component/button/MenuButton").new(
    {
	    parent = self.panel_node,
	    pos = cc.p(Director:getWinSize().width - exitBtnWidth / 2, Director:getWinSize().height - exitBtnHeight / 2 - topOffset),
        src = {"res/component/button/1.png", "res/component/button/1_sel.png", "res/component/button/1_gray.png"},
	    label = {
		    src = game.getStrByKey("exit"),
		    size = 22,
		    color = MColor.lable_yellow,
	    },
	    cb = function(tag, node)
            local bool_isFighter = table.size(self.playersInfo) ~= 0--只有对战者才会收到playersInfo
            if bool_isFighter then
                --退出比赛
                MessageBoxYesNo(nil, game.getStrByKey("p3v3_confirm_quit_game"), function()
                    g_msgHandlerInst:sendNetDataByTable(FIGHTTEAM3V3_CS_QUITGAME, "FightTeam3v3QuitGameProtocol", {})
                end)
            else
                --退出观战
                MessageBoxYesNo(nil, game.getStrByKey("p3v3_confirm_quit_watch"), function()
                    g_msgHandlerInst:sendNetDataByTable(FIGHTTEAM3V3_SC_QUITWATCH, "FightTeam3v3QuitWatchProtocol", {})
                end)
            end


	    end,
    })
    self.exit_btn = exit_btn
    --开始录制视频
    if getLocalRecordByKey(3,"isAutoRecorder3v3") and isSupportReplay() then
        startRecording()
    end
	G_MAINSCENE.taskBaseNode:setVisible(false)--不显示组队面板
end

function VSMapLayer:refreshPlayersInfo()
    while(self.node_playersInfo:getChildByTag(require("src/config/CommDef").TAG_3V3_PLAYERSINFO_CONTENT)) do
        self.node_playersInfo:removeChildByTag(require("src/config/CommDef").TAG_3V3_PLAYERSINFO_CONTENT)
    end
    local index = 0
    for k, v in ipairs(self.playersInfo) do
        while true do
            if v.fightTeamID ~=  MRoleStruct:getAttr(PLAYER_FIGHT_TEAM_ID) then
                break
            end
            local richText_head = require("src/RichText").new(self.node_playersInfo, cc.p(5, - self.headerHeight - 15 - line_height * index), cc.size(960, line_height), cc.p(0, 0.5), line_height, 22, MColor.white)
            richText_head:setTag(require("src/config/CommDef").TAG_3V3_PLAYERSINFO_CONTENT)
            richText_head:setAutoWidth()
            richText_head:addNodeItem(cc.Sprite:create(v.state == st_normal and "res/layers/VS/jiFenPai_empty.png" or (v.state == st_dead and "res/layers/VS/jiFenPai_siWang.png" or "res/layers/VS/jiFenPai_liXian.png")), false)
            richText_head:addText("^c(blue)" .. v.name .. "^")
            richText_head:format()
            index = index + 1
            break
        end
    end
    local ourMemberCount = index
    index = 0
    for k, v in ipairs(self.playersInfo) do
        while true do
            if v.fightTeamID ==  MRoleStruct:getAttr(PLAYER_FIGHT_TEAM_ID) then
                break
            end
            local richText_head = require("src/RichText").new(self.node_playersInfo, cc.p(5, - self.headerHeight - 123 - line_height * index), cc.size(960, line_height), cc.p(0, 0.5), line_height, 22, MColor.white)
            richText_head:setTag(require("src/config/CommDef").TAG_3V3_PLAYERSINFO_CONTENT)
            richText_head:setAutoWidth()
            richText_head:addNodeItem(cc.Sprite:create(v.state == st_normal and "res/layers/VS/jiFenPai_empty.png" or (v.state == st_dead and "res/layers/VS/jiFenPai_siWang.png" or "res/layers/VS/jiFenPai_liXian.png")), false)
            richText_head:addText("^c(red)" .. v.name .. "^")
            richText_head:format()
            index = index + 1
            break
        end
    end
    local enemyMemberCount = index
    self.label_head:removeFromParent()
    self.label_head = createLabel(self.node_playersInfo, string.format(game.getStrByKey("p3v3_infoPanel_head_bar_info"), ourMemberCount, enemyMemberCount), cc.p(35, - self.headerHeight / 2), cc.p(0, 0.5), 22, true)
    self.label_head:setColor(MColor.white)
end

function VSMapLayer:process_msg_fightteam3v3_sc_countdowntime(buff)
    --服务器发来的时间校准消息,忽略收到时的网络延迟
    local t = g_msgHandlerInst:convertBufferToTable("FightTeam3CountDownTimeProtocol", buff)
    self.leftSecond = t.leftTime
    self.timeNode:removeFromParent()
    local timeUpdate = function(timeElapsed)
		if not self.leftSecond or math.floor(self.leftSecond - timeElapsed) < 0 then
			return
		end
        self.leftSecond = self.leftSecond - timeElapsed
        self.labTime:setString(math.floor(self.leftSecond))
	end
	self.timeNode = startTimerActionEx(self.timeBackground, 0.01, true, timeUpdate)
end

function VSMapLayer:process_msg_fightteam3v3_sc_memberstatenotify(buff)
    --玩家信息更改
    --本消息在玩家进入战场(首次，重连)就会立刻收到
    --人物死亡，断线重连会直接进入观战模式,不用点击复活
    local t = g_msgHandlerInst:convertBufferToTable("FightTeam3v3MemberStateNotifyProtocol", buff)
    self.node_playersInfo:setVisible(true)--只有对战者会收到本条协议，观战者不会显示面板
    local bool_I_am_alive_before = false
    for k, v in pairs(self.playersInfo) do
        if v.roleSID == userInfo.currRoleStaticId and v.state == st_normal then
            bool_I_am_alive_before = true
            break
        end
    end
    self.playersInfo = t.memberState
    local bool_I_am_dead_now = false
    for k, v in pairs(self.playersInfo) do
        if v.roleSID == userInfo.currRoleStaticId and v.state == st_dead then
            bool_I_am_dead_now = true
            break
        end
    end
    table.sort(self.playersInfo, function(a, b) return a.roleSID > b.roleSID end)
    if self.spr_playersInfoBG:isVisible() then
        self:refreshPlayersInfo()
    end
    --start人物死亡弹窗------------------
    if not (bool_I_am_alive_before and bool_I_am_dead_now) then
        return
    end
    local node_dialog_fuHuo = createSprite(nil, "res/common/5.png", cc.p(display.cx, display.cy))
    local richText_fuHuoDescription = require("src/RichText").new(node_dialog_fuHuo, cc.p(30, 200), cc.size(350, 30), cc.p(0, 0.5), 30, 22, MColor.white)
    richText_fuHuoDescription:setAutoWidth()
    richText_fuHuoDescription:addText("^c(red)" .. game.getStrByKey("p3v3_fuHuo_dialog_message") .. "^")
    richText_fuHuoDescription:format()
    local int_currentDaoJiShi = 30
    local richText_fuHuoDaoJiShi = require("src/RichText").new(node_dialog_fuHuo, cc.p(110, 140), cc.size(350, 30), cc.p(0, 0.5), 30, 22, MColor.white)
    richText_fuHuoDaoJiShi:setAutoWidth()
    richText_fuHuoDaoJiShi:addText(string.format(game.getStrByKey("p3v3_fuHuo_dialog_daoJiShi"), int_currentDaoJiShi))
    richText_fuHuoDaoJiShi:format()
    local btn_fuHuo
    function btnCallBack()
        g_msgHandlerInst:sendNetDataByTable(FIGHTTEAM3V3_CS_RELIVE, "FightTeam3v3ReliveProtocol", {})
        --参赛人员即便进入观战状态仍然使用退出比赛协议退出观战
        self.exit_btn:setLabel({
		    src = game.getStrByKey("p3v3_map_btn_title_exit_guanZhan"),
		    size = 22,
		    color = MColor.lable_yellow
	    })
        node_dialog_fuHuo:removeFromParent()
    end
    btn_fuHuo = createMenuItem(node_dialog_fuHuo, "res/component/button/1.png", cc.p(200, 50), btnCallBack)
    createLabel(btn_fuHuo, game.getStrByKey("p3v3_fuHuo_dialog_btn_label"), cc.p(btn_fuHuo:getContentSize().width / 2, btn_fuHuo:getContentSize().height / 2), cc.p(.5, .5), 22, false, 0, nil, require("src/config/FontColor").lable_yellow)
    node_dialog_fuHuo:runAction(cc.Sequence:create({
        cc.Repeat:create(cc.Sequence:create({
            cc.DelayTime:create(1)
            , cc.CallFunc:create(function()
                int_currentDaoJiShi = int_currentDaoJiShi - 1
                richText_fuHuoDaoJiShi:removeFromParent()
                richText_fuHuoDaoJiShi = require("src/RichText").new(node_dialog_fuHuo, cc.p(110, 140), cc.size(350, 30), cc.p(0, 0.5), 30, 22, MColor.white)
                richText_fuHuoDaoJiShi:setAutoWidth()
                richText_fuHuoDaoJiShi:addText(string.format(game.getStrByKey("p3v3_fuHuo_dialog_daoJiShi"), int_currentDaoJiShi))
                richText_fuHuoDaoJiShi:format()
            end)
        }), int_currentDaoJiShi)
        , cc.CallFunc:create(btnCallBack)
    }))
    self.panel_node:addChild(node_dialog_fuHuo, 200)
    --end人物死亡弹窗------------------
end

function VSMapLayer:process_msg_fightteam3v3_sc_gamestatenotify(buff)
    --t.state 比赛状态		0是无效，1是进入，2是准备，3是战斗，4是结束
	local t = g_msgHandlerInst:convertBufferToTable("FightTeam3v3GameStateNotifyProtocol", buff)
    self.labTimeTitle:setString(
        (t.state == st_game_enter or t.state == st_game_zhunBei) and game.getStrByKey("p3v3_timeDecounting_title_zhunBei") or game.getStrByKey("p3v3_timeDecounting_title_fight")
    )
    self.timeBackground:setVisible(not (t.overTime or t.state == st_game_over))  --加时赛无倒计时，落雷伤害，到比赛结束
    if (t.state == st_game_enter or t.state == st_game_zhunBei) and not self.eff_door_0 then
        cc.SpriteFrameCache:getInstance():addSpriteFrames("res/effectsplist/3v3dooropen@0.plist")
        self.eff_door_0 = Effects:create(false)
        self.eff_door_0:setAsyncLoad(false)
        self.eff_door_0:setAnchorPoint(cc.p(0.5, 0.5))
        self.eff_door_0:setSpriteFrame("3v3dooropen/00000.png")
        self.eff_door_0:setPosition(cc.p(self:tile2Space(cc.p(15, 30)).x - 48, self:tile2Space(cc.p(15, 30)).y + 173))
        self:addChild(self.eff_door_0)
        self.eff_door_1 = Effects:create(false)
        self.eff_door_1:setAsyncLoad(false)
        self.eff_door_1:setAnchorPoint(cc.p(0.5, 0.5))
        self.eff_door_1:setSpriteFrame("3v3dooropen/00000.png")
        self.eff_door_1:setPosition(cc.p(self:tile2Space(cc.p(31, 16)).x + 40, self:tile2Space(cc.p(31, 16)).y + 147))
        self:addChild(self.eff_door_1)
        self:setBlockRectValue(cc.rect(14, 29, 0, 0), "1")
        self:setBlockRectValue(cc.rect(15, 30, 0, 0), "1")
        self:setBlockRectValue(cc.rect(13, 29, 0, 0), "1")
        self:setBlockRectValue(cc.rect(14, 30, 0, 0), "1")
        self:setBlockRectValue(cc.rect(15, 31, 0, 0), "1")
        self:setBlockRectValue(cc.rect(32, 16, 0, 0), "1")
        self:setBlockRectValue(cc.rect(33, 17, 0, 0), "1")
        self:setBlockRectValue(cc.rect(31, 16, 0, 0), "1")
        self:setBlockRectValue(cc.rect(32, 17, 0, 0), "1")
        self:setBlockRectValue(cc.rect(33, 18, 0, 0), "1")
    end
	if (t.state == st_game_enter or t.state == st_game_zhunBei) and not self.blackLayer then
        --准备中
	    self.blackLayer = cc.LayerColor:create(cc.c4b(10, 10, 10, 0))
	    --SwallowTouches(self.blackLayer)
	    self.panel_node:addChild(self.blackLayer)
        local runeffect = Effects:create(false)
        runeffect:setAnchorPoint(cc.p(0.5, 0.5))
        runeffect:playActionData("loading", 6, 0.6, -1)
        self.blackLayer:addChild(runeffect)
        runeffect:setPosition(cc.p(display.cx - 30, display.cy + 80))
        local spr_zhunBeiZhong = cc.Sprite:create("res/common/zhunBeiZhong.png")
        spr_zhunBeiZhong:setPosition(cc.p(display.cx, display.cy))
        self.blackLayer:addChild(spr_zhunBeiZhong)
    end
    if t.countDown then
        --倒计时
        local effect_countDown = Effects:create(false)
        effect_countDown:setAsyncLoad(false)
		self.blackLayer:addChild(effect_countDown)
		effect_countDown:setPosition(cc.p(display.cx, display.cy))
		effect_countDown:playActionData("ten_countdown", 10, 10, 1)
        self.blackLayer:runAction(cc.Sequence:create({
            cc.DelayTime:create(10)
            , cc.CallFunc:create(function()
                if not self.eff_door_0 then
                    return
                end
                self.eff_door_0:playActionData("3v3dooropen", 10, 0.6, 1)
                self.eff_door_1:playActionData("3v3dooropen", 10, 0.6, 1)
                self:setBlockRectValue(cc.rect(14, 29, 0, 0), "0")
                self:setBlockRectValue(cc.rect(15, 30, 0, 0), "0")
                self:setBlockRectValue(cc.rect(13, 29, 0, 0), "0")
                self:setBlockRectValue(cc.rect(14, 30, 0, 0), "0")
                self:setBlockRectValue(cc.rect(15, 31, 0, 0), "0")
                self:setBlockRectValue(cc.rect(32, 16, 0, 0), "0")
                self:setBlockRectValue(cc.rect(33, 17, 0, 0), "0")
                self:setBlockRectValue(cc.rect(31, 16, 0, 0), "0")
                self:setBlockRectValue(cc.rect(32, 17, 0, 0), "0")
                self:setBlockRectValue(cc.rect(33, 18, 0, 0), "0")
            end)
            , cc.RemoveSelf:create()
        }))
    end
    if not self.overTime and t.overTime then
        --加时赛特效
        local WinSize = Director:getWinSize()
        self.blackLayer = cc.LayerColor:create(cc.c4b(10, 10, 10, 0))
	    --SwallowTouches(self.blackLayer)
	    self.panel_node:addChild(self.blackLayer)
        local spr_kai = cc.Sprite:create("res/common/effectFont/vs_kai.png")
        spr_kai:setPosition(cc.p(WinSize.width + 100, display.cy))
        self.panel_node:addChild(spr_kai)
        local spr_shi_0 = cc.Sprite:create("res/common/effectFont/vs_shi_0.png")
        spr_shi_0:setPosition(cc.p(WinSize.width + 250, display.cy))
        self.panel_node:addChild(spr_shi_0)
        local spr_jia = cc.Sprite:create("res/common/effectFont/vs_jia.png")
        spr_jia:setPosition(cc.p(WinSize.width + 400, display.cy))
        self.panel_node:addChild(spr_jia)
        local spr_shi_1 = cc.Sprite:create("res/common/effectFont/vs_shi_1.png")
        spr_shi_1:setPosition(cc.p(WinSize.width + 550, display.cy))
        self.panel_node:addChild(spr_shi_1)
        local duration_flyIn, duration_flyOut, duration_delayBetweenWords = 0.5, 1.5, 0.2
        self.blackLayer:runAction(cc.Sequence:create({
            cc.Spawn:create(
                cc.TargetedAction:create(
                    spr_kai
                    , cc.Sequence:create({
                        cc.EaseSineIn:create(cc.MoveBy:create(duration_flyIn, cc.p(- WinSize.width / 2 - 200, 0)))
                        , cc.EaseSineIn:create(cc.MoveBy:create(duration_flyOut, cc.p(- WinSize.width / 2 - 400, 0)))
                        , cc.RemoveSelf:create()
                    })
                )
                , cc.TargetedAction:create(
                    spr_shi_0
                    , cc.Sequence:create({
                        cc.DelayTime:create(duration_delayBetweenWords)
                        , cc.EaseSineIn:create(cc.MoveBy:create(duration_flyIn, cc.p(- WinSize.width / 2 - 200, 0)))
                        , cc.EaseSineIn:create(cc.MoveBy:create(duration_flyOut, cc.p(- WinSize.width / 2 - 400, 0)))
                        , cc.RemoveSelf:create()
                    })
                )
                , cc.TargetedAction:create(
                    spr_jia
                    , cc.Sequence:create({
                        cc.DelayTime:create(duration_delayBetweenWords * 2)
                        , cc.EaseSineIn:create(cc.MoveBy:create(duration_flyIn, cc.p(- WinSize.width / 2 - 200, 0)))
                        , cc.EaseSineIn:create(cc.MoveBy:create(duration_flyOut, cc.p(- WinSize.width / 2 - 400, 0)))
                        , cc.RemoveSelf:create()
                    })
                )
                , cc.TargetedAction:create(
                    spr_shi_1
                    , cc.Sequence:create({
                        cc.DelayTime:create(duration_delayBetweenWords * 3)
                        , cc.EaseSineIn:create(cc.MoveBy:create(duration_flyIn, cc.p(- WinSize.width / 2 - 200, 0)))
                        , cc.EaseSineIn:create(cc.MoveBy:create(duration_flyOut, cc.p(- WinSize.width / 2 - 400, 0)))
                        , cc.RemoveSelf:create()
                    })
                )
            )
            , cc.RemoveSelf:create()
        }))
    end
    self.overTime = t.overTime
end

function VSMapLayer:showReliveLayer(objId)
    --为了让断线重连支持复活弹窗，不在这里创建复活弹窗,只用作重载
end

return VSMapLayer