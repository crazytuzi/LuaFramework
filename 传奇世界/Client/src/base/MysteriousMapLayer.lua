local MysteriousMapLayer = class("MysteriousMapLayer", require("src/base/MainMapLayer.lua"))
local MazeEventType = 
{
	NoLockedBox = 1,	--未上锁的宝箱, 直接拾取, 发送了游戏开始消息后
	LockedBox = 2,		--上锁的宝箱, 答题
	SealedBox = 3,		--被封印的宝箱
	CursedBox = 4,		--被诅咒的宝箱
	NaughtyBox = 5,		--调皮的小鬼
	BoredBox = 6,		--无聊的树妖
	LosedBox = 7,		--迷失的信使
	LittleBossBox = 8,	--小首领的宝箱
	BossBox = 9,		--首领的宝箱
}
local key_protoId = 999
local num_north = 1  --0x0001
local num_east = 2  --0x0010
local num_sourth = 4  --0x0100
local num_west = 8  --0x1000
local direction_north = 0
local direction_east = 1
local direction_sourth = 2
local direction_west = 3
local event_desc_font_size = 18
local label_kill_monster_count_zOrder = 1
local event_desc_icon_scale = 0.7 * 24 / 27

function MysteriousMapLayer:ctor(str_name, parent, pos, mapId, isFb)
    ----------------------------------------------通用部分:-----------------------------------------------------------------------------
    self.parent = parent
	self:initializePre()
	self:loadMapInfo(str_name, mapId, pos)
	self.parent:addChild(self, -1)
	self:loadSpritesPre()
	self.has_loadmap = true
    ------------------------------------------------------------------------------------------------------------------------------------
    self.isMysteriousMap = true
    -----------------------------------------------start logic:-------------------------------------------------------------------------
    self.panel_node = cc.Node:create()
    G_MAINSCENE:addChild(self.panel_node, require("src/config/CommDef").ZVALUE_UI - 1)
    for k, v in pairs(require("src/config/fanxianfront")) do
        if v.q_map_id == self.mapID then
            self.roomInfo = v
            break
        end
    end
    --钥匙数量
    local MPackManager = require "src/layers/bag/PackManager"
    local MPackStruct = require "src/layers/bag/PackStruct"
    local bag = MPackManager:getPack(MPackStruct.eBag)
    function refreshText()
        if self.richText_cost_key then
            self.richText_cost_key:removeFromParent()
        end
        local own_num_item = bag:countByProtoId(key_protoId)
        local line_height = 24
        local richTextSize_width = 960
        self.richText_cost_key = require("src/RichText").new(self.panel_node, cc.p(display.width - 20, display.cy + 150 - 105), cc.size(richTextSize_width, line_height), cc.p(1, 0.5), line_height, event_desc_font_size, MColor.white)
        self.richText_cost_key:setAutoWidth()
        local spr_key = cc.Sprite:create("res/layers/mysteriousArea/iocn2.png")
        spr_key:setScale(event_desc_icon_scale)
        self.richText_cost_key:addNodeItem(spr_key, false)
        self.richText_cost_key:addText(own_num_item)
        self.richText_cost_key:format()
    end
    local func_changed_item = function(observable, event, pos, pos1, new_grid)
        if not (event == "-" or event == "+" or event == "=") then return end
        refreshText()
    end
    self:registerScriptHandler(function(event)
	    if event == "enter" then
            --begin   初始状态先隐藏宝箱
            --地图上只会存在一个宝箱,先将它隐藏,根据房间状态:如果未完成，才显示它
            self.npc = nil
            self.npcId = nil
            local npc_res = nil
            for npc_index, npc in pairs(require("src/config/NPC")) do
                if npc.q_map == mapId then
                    npc_res = npc.q_resource
                    break
                end
            end
            for k, v in pairs(self.npc_tab) do
                if v:getResId() == npc_res then
                    self.npc = v
                    self.npcId = k
                    break
                end
            end
            self.npc_tab[self.npcId] = nil
            self.npc:setVisible(false)
            if self.roomInfo.q_lighteffect ~= 0 then
                cc.SpriteFrameCache:getInstance():addSpriteFrames("res/effectsplist/fanbox-on@0.plist")
                cc.SpriteFrameCache:getInstance():addSpriteFrames("res/effectsplist/fanbox-off@0.plist")
                self.eff_box = Effects:create(false)
                self.eff_box:setAsyncLoad(false)
                self.eff_box:setAnchorPoint(cc.p(0.5, 0.5))
                self.eff_box:setScale(0.6)
                self.eff_box:setPosition(cc.p(self.npc:getPositionX() + 13, self.npc:getPositionY() + 8))
                addEffectWithMode(self.eff_box, 1)
                self:addChild(self.eff_box)
            end
            --end   隐藏宝箱
            for k, v in ipairs(G_MYSTERIOUS_MAP_MSG_CACHE) do
                self:process_msg_maze_sc_notify(v)
            end
            G_MYSTERIOUS_MAP_MSG_CACHE = {}
            self.ready = true
            --获取小地图消息收发
            g_msgHandlerInst:registerMsgHandler(MAZE_SC_NOTIFY_RET, function(buff)
                local t = g_msgHandlerInst:convertBufferToTable("NotifyMazeRet", buff)
                --第一次收到地图通知先刷小地图
                if self.refresh_tiny_map then
                    if self.tiny_map then
                        self.tiny_map:removeFromParent()
                    end
                    self.tiny_map = require("src/layers/mysteriousArea/ma_tinyMap").new(t)
                    self.panel_node:addChild(self.tiny_map)
                    self.refresh_tiny_map = nil
                    return
                end
                --再次收到的消息是点击小地图发送的拉取通知
                local dialog = require("src/layers/mysteriousArea/ma_miniMapDialog").new(t)
                self.panel_node:addChild(dialog, 2)
            end)
            g_msgHandlerInst:registerMsgHandler(MAZENODE_SC_GAMEPRIZE_RET, function(buff)
                local t = g_msgHandlerInst:convertBufferToTable("MazeNodeGamePrizeRet", buff)
                --游戏领奖如果失败弹出领奖失败提示，只有被封印的宝箱会出现领奖失败的情况
                if t.reCode == 0 then   --0代表成功
                    return
                end
                TIPS({type = 1, str = game.getStrByKey("mysteriousArea_sealedBox_notFinished_tip")})
            end)
            g_msgHandlerInst:registerMsgHandler(MAZENODE_SC_REWARD_NOTIFY, function(buff)
                --一旦打开小鬼的翻牌对话框,小鬼对话框会接管并覆盖本协议的处理方式
                self:showReward(buff)
            end)
            g_msgHandlerInst:registerMsgHandler(MAZENODE_SC_COUTDOWN_NOTIFY, function(buff)
                --收到倒计时通知,显示倒计时
                --3分钟倒计时
                self.leftSecond = self.roomInfo.q_time
                self.timeBackground = createSprite(self.panel_node,"res/mainui/sideInfo/timeBg.png",cc.p(display.width-154-171, g_scrSize.height), cc.p(0, 1))
                local timeBgSize = self.timeBackground:getContentSize()
	            self.labTimeTitle = createLabel(self.timeBackground,game.getStrByKey("battle_countdown"), cc.p(timeBgSize.width/2, timeBgSize.height - 16), nil, 18, true)
	            self.labTime = createLabel(self.timeBackground, self.leftSecond, cc.p(timeBgSize.width/2, timeBgSize.height/2-8), cc.p(0.5,0.5),40,true,nil,nil,MColor.lable_yellow)
                local timeUpdate = function(timeElapsed)
		            if not self.leftSecond then
			            return
		            end
                    if math.floor(self.leftSecond - timeElapsed) < 0 then   
                        self.timeBackground:removeFromParent()
                        return
                    end
                    self.leftSecond = self.leftSecond - timeElapsed
                    self.labTime:setString(math.floor(self.leftSecond))
	            end
	            startTimerActionEx(self.timeBackground, 0.01, true, timeUpdate)
            end)
            g_msgHandlerInst:registerMsgHandler(MAZENODE_SC_KILLCOUNT_NOTIFY, function(buff)
                local t = g_msgHandlerInst:convertBufferToTable("MazeNodeKillCountNotify", buff)
                --杀怪通知,显示杀怪数量
                if not self.icon_killMonsterCount then
                    self.icon_killMonsterCount = cc.Sprite:create("res/layers/mysteriousArea/iocn3.png")
                    self.icon_killMonsterCount:setScale(event_desc_icon_scale)
                    self.icon_killMonsterCount:setPosition(cc.p(20, 406 + (g_scrSize.height-640)))
                    self.panel_node:addChild(self.icon_killMonsterCount, label_kill_monster_count_zOrder)
                    self.label_killMonsterCount = createLabel(self.panel_node, "0", cc.p(20 + 130 - 106, 406 + (g_scrSize.height-640)), cc.p(0, 0.5), event_desc_font_size, nil, label_kill_monster_count_zOrder, nil, MColor.white)
                end
                self.label_killMonsterCount:setString(t.param)
            end)
            g_msgHandlerInst:registerMsgHandler(MAZENODE_SC_HURTCOUNT_NOTIFY, function(buff)
                local t = g_msgHandlerInst:convertBufferToTable("MazeNodeHurtCountNotify", buff)
                --杀怪通知,显示造成总伤害
                if not self.icon_hurtMonsterDamage then
                    self.icon_hurtMonsterDamage = cc.Sprite:create("res/layers/mysteriousArea/icon1.png")
                    self.icon_hurtMonsterDamage:setScale(event_desc_icon_scale)
                    self.icon_hurtMonsterDamage:setPosition(cc.p(20, 406 + (g_scrSize.height-640)))
                    self.panel_node:addChild(self.icon_hurtMonsterDamage, label_kill_monster_count_zOrder)
                    self.label_killMonsterCount = createLabel(self.panel_node, "0", cc.p(20 + 130 - 106, 406 + (g_scrSize.height-640)), cc.p(0, 0.5), event_desc_font_size, nil, label_kill_monster_count_zOrder, nil, MColor.white)
                end
                self.label_killMonsterCount:setString(t.param)
            end)
            g_msgHandlerInst:registerMsgHandler(MAZE_SC_COMPLATE, function(buff)
                local t = g_msgHandlerInst:convertBufferToTable("MazeComplete", buff)
                --全部地图探明，弹出地图小地图
                --因为所有地图联通，因此不需要处理地图状态
                --暂时使用通天塔特效:领奖+点亮所有房间
                ShowEffectFont(self.panel_node, cc.p(display.cx, display.cy + 150), "sjwcFlag.png", 3)
                g_msgHandlerInst:sendNetDataByTable(MAZE_CS_NOTIFY_REQ, "NotifyMazeReq", {})
            end)
            g_msgHandlerInst:registerMsgHandler(MAZE_SC_USEQLYF_SUCESS, function(buff)
                --千里眼符使用成功
                self.refresh_tiny_map = true
                g_msgHandlerInst:sendNetDataByTable(MAZE_CS_NOTIFY_REQ, "NotifyMazeReq", {})
            end)
            self.parent.smallMap:setVisible(false)
            bag:register(func_changed_item)
            refreshText()
            self.refresh_tiny_map = true
            g_msgHandlerInst:sendNetDataByTable(MAZE_CS_NOTIFY_REQ, "NotifyMazeReq", {})
	    elseif event == "exit" then
            --小地图消息解除注册
            if self.schedulerHandle then
                self.scheduler:unscheduleScriptEntry(self.schedulerHandle)
            end
            g_msgHandlerInst:registerMsgHandler(MAZE_SC_NOTIFY_RET, nil)
            g_msgHandlerInst:registerMsgHandler(MAZENODE_SC_REWARD_NOTIFY, nil)
            g_msgHandlerInst:registerMsgHandler(MAZENODE_SC_COUTDOWN_NOTIFY, nil)
            g_msgHandlerInst:registerMsgHandler(MAZENODE_SC_KILLCOUNT_NOTIFY, nil)
            g_msgHandlerInst:registerMsgHandler(MAZENODE_SC_HURTCOUNT_NOTIFY, nil)
            g_msgHandlerInst:registerMsgHandler(MAZE_SC_USEQLYF_SUCESS, nil)
            G_MYSTERIOUS_QUESTION_STATE.currentQuestionIndex = 1    --离开场景时刷新当前回答的题目index为1
            G_MYSTERIOUS_QUESTION_STATE.questionRewardGot = false   --离开场景时刷新当前回答奖励获得情况为未领取
            G_MYSTERIOUS_QUESTION_STATE.refreshRandomQuestions()    --离开场景时刷新当前的5道题目
            G_MYSTERIOUS_GOBLINGAME_STATE.giftGot = false      --离开场景时刷新小鬼游戏接收状态重置为false
            bag:unregister(func_changed_item)
	    end
    end)
    G_MAINSCENE.taskBaseNode:setVisible(false)--不显示组队面板
    --退出按钮
    local exitBtnWidth, exitBtnHeight = 138, 58
    local topOffset = 75 + 105
    require("src/component/button/MenuButton").new(
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
            g_msgHandlerInst:sendNetDataByTable(MAZE_CS_EXIT_REQ, "ExitMazeReq", {})
	    end,
    })
    --[[
    --test button
    local MMenuButton = require "src/component/button/MenuButton"
    MMenuButton.new(
	{
        parent = self.panel_node,
	    pos = cc.p(237, 131),
		src = {"res/component/button/49.png", "res/component/button/49_sel.png", "res/component/button/49_gray.png"},
		label = {
			src = game.getStrByKey("sell"),
			size = 25,
			color = MColor.lable_yellow,
		},
		tab = 1,
		nodefaultMus = true,
		cb = function(tag, node)
			ShowEffectFont(self.panel_node, cc.p(display.cx, display.cy + 150), "sjwcFlag.png", 3)
            g_msgHandlerInst:sendNetDataByTable(MAZE_CS_NOTIFY_REQ, "NotifyMazeReq", {})
		end,
	})
    ]]
end

function MysteriousMapLayer:showReward(buff)
--暂时使用通天塔特效:领奖+点亮所有房间
    ShowEffectFont(self.panel_node, cc.p(display.cx, display.cy + 150), "sjwcFlag.png", 3)
--[[
    local t = g_msgHandlerInst:convertBufferToTable("MazeNodeRewardNotify", buff)
    --显示领取界面
    local table_allRewards = {}
    for k, v in ipairs(t.info) do
        local table_reward = {}
        table_reward.id = v.rewardId
        table_reward.num = v.rewardCount
        table_reward.streng = v.strength
        table_reward.showBind = true
        table_reward.isBind = v.bind
        table.insert(table_allRewards, table_reward)
    end
    Awards_Panel({awards = table_allRewards, award_tip = game.getStrByKey("get_awards")})
    ]]
end

function MysteriousMapLayer:process_chat_request()
    --为避免发送不必要的消息,减少服务器压力,用gameStarted屏蔽第一次以后的请求发送
    if self.currentMazeNode.eventType == MazeEventType.NoLockedBox and not self.gameStarted then
        --未上锁的宝箱,直接领奖
        g_msgHandlerInst:sendNetDataByTable(MAZENODE_CS_GAMEPRIZE_REQ, "MazeNodeGamePrizeReq", {})
    end
    if self.currentMazeNode.eventType == MazeEventType.LockedBox and not self.panel_node:getChildByTag(require("src/config/CommDef").TAG_MA_DIALOG_QUESTIONANDANSWER) then
        --上锁的宝箱,等答题完毕直接发送领奖
        local dialog_questionAndAnswer = require("src/layers/mysteriousArea/ma_questionAndAnswerDialog").new()
        dialog_questionAndAnswer:setTag(require("src/config/CommDef").TAG_MA_DIALOG_QUESTIONANDANSWER)
        self.panel_node:addChild(dialog_questionAndAnswer)
    end
    if self.currentMazeNode.eventType == MazeEventType.SealedBox then
        --被封印的宝箱,游戏开始后,直接刷怪进入开始状态,中途可以反复发送领奖消息,中途如果再次点击就发送领奖消息，服务器发送领奖失败就弹出tip
        g_msgHandlerInst:sendNetDataByTable(MAZENODE_CS_GAMEPRIZE_REQ, "MazeNodeGamePrizeReq", {})
    end
    if self.currentMazeNode.eventType == MazeEventType.CursedBox and not self.gameStarted then
        --诅咒的宝箱，只发送游戏开始，到时间3分钟服务器自动发送奖励
        g_msgHandlerInst:sendNetDataByTable(MAZENODE_CS_GAMESTART_REQ, "MazeNodeGameStartReq", {})
    end
    if self.currentMazeNode.eventType == MazeEventType.NaughtyBox and not self.panel_node:getChildByTag(require("src/config/CommDef").TAG_MA_DIALOG_NAUGHTYBOX) and not G_MYSTERIOUS_GOBLINGAME_STATE.giftGot then
        --顽皮小鬼
        local dialog_naughtyBox = require("src/layers/mysteriousArea/ma_goblinGameDialog").new(self)
        dialog_naughtyBox:setTag(require("src/config/CommDef").TAG_MA_DIALOG_NAUGHTYBOX)
        self.panel_node:addChild(dialog_naughtyBox)
    end
    if self.currentMazeNode.eventType == MazeEventType.BoredBox and not self.gameStarted then
        --无聊树妖，只发送游戏开始，到时间3分钟服务器自动发送奖励
        g_msgHandlerInst:sendNetDataByTable(MAZENODE_CS_GAMESTART_REQ, "MazeNodeGameStartReq", {})
    end
    if self.currentMazeNode.eventType == MazeEventType.LosedBox and not self.gameStarted then
        --迷失信徒，开始游戏，npc变身为铁血魔王,直接掉落道具
        g_msgHandlerInst:sendNetDataByTable(MAZENODE_CS_GAMESTART_REQ, "MazeNodeGameStartReq", {})
    end
    if self.currentMazeNode.eventType == MazeEventType.LittleBossBox and not self.gameStarted then
        --小首领的宝箱,直接领奖
        g_msgHandlerInst:sendNetDataByTable(MAZENODE_CS_GAMEPRIZE_REQ, "MazeNodeGamePrizeReq", {})
    end
    if self.currentMazeNode.eventType == MazeEventType.BossBox and not self.gameStarted then
        --首领的宝箱,直接领奖
        g_msgHandlerInst:sendNetDataByTable(MAZENODE_CS_GAMEPRIZE_REQ, "MazeNodeGamePrizeReq", {})
    end
    self.gameStarted = true
end

function MysteriousMapLayer:process_msg_maze_sc_notify(buff)
    local t = g_msgHandlerInst:convertBufferToTable("MazeNodeNotify", buff)
    --如果是刚进场景所收到的第一条房间消息已经是完成状态，说明这是一个已经通关的房间，那么保持宝箱被隐藏，否则显示宝箱
    --领奖以后宝箱消失
    if (
        t.mazeNode.eventState == 2
        or (t.mazeNode.eventState == 1 and (t.mazeNode.eventType == 6 or t.mazeNode.eventType == 7))
    ) then
        self.npc_tab[self.npcId] = nil
        self.npc:setVisible(false)
        if self.eff_box then
            self.eff_box:stopAllActions()
            self.eff_box:setVisible(false)
        end
    else
        self.npc_tab[self.npcId] = self.npc
        self.npc:setVisible(true)
        if self.eff_box then
            self.eff_box:playActionData(self.roomInfo.q_lighteffect == 1 and "fanbox-off" or "fanbox-on", 6, 0.6, -1)   --1.红色特效; 2.黄色特效
            self.eff_box:setVisible(true)
        end
    end
    local previousMazeNode = self.currentMazeNode
    self.currentMazeNode = t.mazeNode
    self.curPathIndexs = t.curPathIndexs
    --第一次获得房间消息需要创建传送门
    if not self.inited then
        self.inited = true
        --280 + (g_scrSize.height-640)
        self.roomDescPanel = createScale9Sprite(self.panel_node, "res/layers/mission/task_info_bg2.png", cc.p(2, 392 + (g_scrSize.height - 640)), cc.size(246, 82), cc.p(0, 0))
        createSprite(self.roomDescPanel, "res/common/blueTask.png", cc.p(0, self.roomDescPanel:getContentSize().height), cc.p(0, 1))
        createLabel(self.roomDescPanel, game.getStrByKey("mysteriousArea_event_tip_title"), cc.p(5, 70), cc.p(0, 0.5), event_desc_font_size, nil, nil, nil, MColor.yellow)
        createLabel(self.roomDescPanel, self.roomInfo.F1, cc.p(60, 70), cc.p(0, 0.5), event_desc_font_size, nil, nil, nil, MColor.yellow)
        self.label_event_tip_title = createLabel(self.roomDescPanel, self.roomInfo.q_des, cc.p(5, 70 - 25), cc.p(0, 0.5), event_desc_font_size, nil, nil, nil, MColor.white)
        self.teleportEffects = {}
        self.table_tilePosTransfor = {}
        if lua_byteAnd(self.currentMazeNode.openState, num_east) ~= 0 then
            self.table_tilePosTransfor[direction_east] = {x = string.split(self.roomInfo.q_right_xy, ",")[1], y = string.split(self.roomInfo.q_right_xy, ",")[2]}
        end
        if lua_byteAnd(self.currentMazeNode.openState, num_west) ~= 0 then
            self.table_tilePosTransfor[direction_west] = {x = string.split(self.roomInfo.q_left_xy, ",")[1], y = string.split(self.roomInfo.q_left_xy, ",")[2]}
        end
        if lua_byteAnd(self.currentMazeNode.openState, num_north) ~= 0 then
            self.table_tilePosTransfor[direction_north] = {x = string.split(self.roomInfo.q_up_xy, ",")[1], y = string.split(self.roomInfo.q_up_xy, ",")[2]}
        end
        if lua_byteAnd(self.currentMazeNode.openState, num_sourth) ~= 0 then
            self.table_tilePosTransfor[direction_sourth] = {x = string.split(self.roomInfo.q_down_xy, ",")[1], y = string.split(self.roomInfo.q_down_xy, ",")[2]}
        end
        --刷传送门,传送门状态:1.房间游戏进行中，传送门关闭的状态     2.房间游戏完成，已探索    3.房间游戏完成，未探索,需钥匙
        for k, v in pairs(self.table_tilePosTransfor) do
            local transforEffect = Effects:create(false)
	        transforEffect:setAnchorPoint(cc.p(0.5, 0.5))
	        local t_pos = self:tile2Space(cc.p(v.x, v.y))
	        transforEffect:setPosition(t_pos)
	        self:addChild(transforEffect,3)
	        transforEffect:playActionData("fanstrans_no",15,2,-1)   --todo:这里播放 1.房间游戏进行中，传送门关闭的状态
            transforEffect:setScale(1.1)
	        if self:isOpacity(cc.p(v.x,v.y)) then
		        transforEffect:setOpacity(100)
	        end
            self.teleportEffects[k] = transforEffect
        end
        self.scheduler = cc.Director:getInstance():getScheduler()
        self.schedulerHandle = self.scheduler:scheduleScriptFunc(function()
            --传送是否走到了热区
            if not G_ROLE_MAIN then
                --直接在迷仙阵中退出游戏会导致globalInit G_ROLE_MAIN = nil
                return
            end
            local tilePos_mainRole = self:space2Tile(cc.p(G_ROLE_MAIN:getPosition()))
            local previous_direction = self.target_direction
            self.target_direction = nil
            for k, v in pairs(self.table_tilePosTransfor) do
                if math.pow(tilePos_mainRole.x - v.x, 2) + math.pow(tilePos_mainRole.y - v.y, 2) < 10 then
                    self.target_direction = k
                    break
                end
            end
            if not (self.target_direction and previous_direction ~= self.target_direction) then
                return
            end
            if self.currentMazeNode.eventState ~= 2 then
                TIPS(getConfigItemByKeys("clientmsg", {"sth", "mid"}, {38000, -12}))
                return
            end
            if self.msgBoxConsumeKeyConfirm then
                return
            end
            --传送
            local target_room_index = (
            self.target_direction == direction_east and self.currentMazeNode.index + 1 or (
            self.target_direction == direction_west and self.currentMazeNode.index - 1 or (
            self.target_direction == direction_north and self.currentMazeNode.index - 7 or
            self.currentMazeNode.index + 7
            )))
            local bool_targetRoom_has_been_visited = false
            for k, v in ipairs(self.curPathIndexs) do
                if v == target_room_index then
                    bool_targetRoom_has_been_visited = true
                end
            end
            --需要消耗钥匙，没钥匙，提示没钥匙
            if not bool_targetRoom_has_been_visited and MPackManager:getPack(MPackStruct.eBag):countByProtoId(key_protoId) < 1 then
                TIPS(getConfigItemByKeys("clientmsg", {"sth", "mid"}, {38000, -5}))
                return
            end
            --需要消耗钥匙，有钥匙，弹确认
            if not bool_targetRoom_has_been_visited then
                if not G_MYSTERIOUS_NOT_SHOW_AGAIN_STETE.use_key then
                    local direction_storedByEnclosure = self.target_direction
                    self.msgBoxConsumeKeyConfirm = MessageBoxYesNo(nil, game.getStrByKey("mysteriousArea_transfor_will_comsume_key_confirm"), function()
                        G_MYSTERIOUS_NOT_SHOW_AGAIN_STETE.use_key = (self.msgBoxConsumeKeyConfirm.checkBox:getTexture() == TextureCache:getTextureForKey("res/component/checkbox/1-2.png"))
                        self.willEnterNextRoom = true
                        g_msgHandlerInst:sendNetDataByTable(MAZE_CS_ENTER_NEXT_REQ, "MazeEnterNextReq", {dir = direction_storedByEnclosure})
                        self.scheduler:unscheduleScriptEntry(self.schedulerHandle)
                        self.msgBoxConsumeKeyConfirm = nil
                    end, function()
                        self.msgBoxConsumeKeyConfirm = nil
                    end)
    	            self.msgBoxConsumeKeyConfirm.checkBox = createTouchItem(self.msgBoxConsumeKeyConfirm, "res/component/checkbox/1.png", cc.p(170, 110), function(sender)
                        sender:setTexture(sender:getTexture() == TextureCache:getTextureForKey("res/component/checkbox/1.png") and "res/component/checkbox/1-2.png" or "res/component/checkbox/1.png")
		            end)
    	            createLabel(self.msgBoxConsumeKeyConfirm, game.getStrByKey("ping_btn_no_more"), cc.p(195, 110), cc.p(0, 0.5), 20, true, nil, nil, MColor.lable_black, nil, nil, MColor.black, 3)
                else
                    self.willEnterNextRoom = true
    	            g_msgHandlerInst:sendNetDataByTable(MAZE_CS_ENTER_NEXT_REQ, "MazeEnterNextReq", {dir = self.target_direction})
                    self.scheduler:unscheduleScriptEntry(self.schedulerHandle)
                end
                return
            end
            --不需要消耗，直接传送
            self.willEnterNextRoom = true
            g_msgHandlerInst:sendNetDataByTable(MAZE_CS_ENTER_NEXT_REQ, "MazeEnterNextReq", {dir = self.target_direction})
            self.scheduler:unscheduleScriptEntry(self.schedulerHandle)
        end, 0.01, false)
    end
    --任务完成会收到房间状态改变消息，2.完成
    if self.currentMazeNode.eventState ~= 2 then
        return
    end
    self.label_event_tip_title:setString(game.getStrByKey("mysteriousArea_event_tip_enter_next"))
    if previousMazeNode and previousMazeNode.eventState ~= self.currentMazeNode.eventState then
        --领取奖励以后，房间状态变成2，重新刷新tiny_map, 消除微缩地图上的宝箱标志
        self.refresh_tiny_map = true
        g_msgHandlerInst:sendNetDataByTable(MAZE_CS_NOTIFY_REQ, "NotifyMazeReq", {})
    end
    --如果收到的是房间完成的消息，则根据对面房间是否曾经经过刷新传送门状态为"已探索"或"未探索"
    for direction, transforEffect in pairs(self.teleportEffects) do
        local target_room_index = (
        direction == direction_east and self.currentMazeNode.index + 1 or (
        direction == direction_west and self.currentMazeNode.index - 1 or (
        direction == direction_north and self.currentMazeNode.index - 7 or
        self.currentMazeNode.index + 7
        )))
        local bool_targetRoom_has_been_visited = false
        for k, v in ipairs(self.curPathIndexs) do
            if v == target_room_index then
                bool_targetRoom_has_been_visited = true
            end
        end
        if bool_targetRoom_has_been_visited then
            transforEffect:playActionData("transfor",15,2,-1)
        else
            transforEffect:playActionData("fanstrans_can",15,2,-1)
        end
    end
end

return MysteriousMapLayer