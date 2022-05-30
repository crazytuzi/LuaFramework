-- --------------------------------------------------------------------
--
--
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
-- [文件功能:战斗控制类]
-- <br/>Create: 2017-xx-xx
-- --------------------------------------------------------------------

BattleController = BattleController or BaseClass(BaseController)

-- 战斗类型定义
BattleTypeConf = {
	TYPE_ENEMY = - 1,
	TYPE_ROLE = 1,
	BATTLE_EXIT = 1
}
--战斗单位类型
BattleObjectType = {
	Role = 1,      --角色(暂时没有了)
	Pet = 2,       --伙伴(配置表取partern)
	Unit = 3,      --单位(配置表取unit)
	Hallows = 4,   --神器
    Elfin = 5,     --精灵
}
--战斗特效播放类型分组
BattleEffectPlayType = {
	ROLE = 1, 			--自己
	SCENE = 2, 			--场景
	ROLE_SCENE = 3, 	--友方场景
	ENEMY_SCENE = 4, 	--敌方场景
	TARGET = 5, 		--敌方目标
}
--战斗分组
BattleGroupTypeConf = {
	TYPE_GROUP_ENEMY = 2, 	--敌方
	TYPE_GROUP_ROLE = 1, 	--友方
}
--战斗场上单位目标类型
BattleTargetTypeConf = {
	ALIVE_ENEMY = 1, 				--敌方存活单位
	ALIVE_ALLY = 2,					--友方存活单位
	DEAD_ALLY = 3,					--友方死亡单位
	DEAD_ENEMY = 4,					--敌方死亡单位
	ALIVE_SELF = 5,					--自己
	ALIVE_EXEPT_SELF = 6,			--全场除自己
	ALIVE_ALLY_EXCEPT_SELF = 7, 	--友方存活单位除了自己
}
--战斗技能类型
BattleSkillTypeConf = {
	ACTIVE_SKILL = "active_skill", 				--主动技能
	PASSIVE_SKILL = "passive_skill",			--被动技能
	EQM_PASSIVE_SKILL = "eqm_passive_skill",	--装备被动技能
}
--人物额外数据
BattleRoleExtendType = {
	FASHION  = 5,               -- 皮肤
    RESONATE = 10,             -- 共鸣
    CRYSTAL  = 11,             -- 原力水晶上阵的宝可梦
} 

function BattleController:config()
    self.model = BattleModel.New() 
    self.battle_hook_model = BattleHookModel.New()
    self.dispather = GlobalEvent:getInstance()
    self.is_watch_replay = false                                --是否为录像
    self.is_watch_witness = false                               --是否为观战状态
    self.init_fight_status = false
    self.circle_round_data = nil                                --挂机缓存数据
    self.is_normal_battle = false                               --是否为挂机战斗
    self.cur_fight_type = 0
    self.is_battle_start = false                                --是否已进入战斗状态
    self.is_pk_battle = false                                   --是否切磋状态
    self.extend_fight_type = BattleConst.Fight_Type.Darma       --额外的战斗类型记录
    self.finish_fail_view_list = {}                             --失败面板列表
    self.finish_result_view_list = {}                           --胜利面板列表
    self.fighting_type_list = {}
    self.is_unlock_chapter = false                              --是否解锁章节中 
    self.is_drama_result = false
    self.sum_lev = 0                                            --己方总等级
    self.enemy_lev = 0                                          --敌方总等级

    self.model:initConfig()                                     --把初始化放到下面来
    self.battle_hook_model:initConfig()
end

function BattleController:getModel()
    return self.model
end
function BattleController:getNormalModel()
    return self.battle_hook_model
end

function BattleController:isInFight()
    if self.model == nil then
        return false
    else
        if not self.is_normal_battle then
            return self.model:isInFight()
        else
            return self.battle_hook_model:isInFight()
        end
    end
end

function BattleController:registerEvents()
    if self.init_role_event == nil then
        self.init_role_event = GlobalEvent:getInstance():Bind(EventId.ROLE_CREATE_SUCCESS, function()
            GlobalEvent:getInstance():UnBind(self.init_role_event)
            self.main_vo = RoleController:getInstance():getRoleVo()
        end)
    end
end

function BattleController:registerProtocals()
    
    self:RegisterProtocal(20027, "scInitFightStart")        --战斗真正初始化
    self:RegisterProtocal(20002, "scRoundFightStart")       --回合开始数据
    self:RegisterProtocal(20004, "scUseSkillData")          --使用技能战斗播报
    self:RegisterProtocal(20006, "scFightEnd")              --战斗结果
    self:RegisterProtocal(20008, "scFightExit")             --退出战斗
    self:RegisterProtocal(20009, "scSkipFirstTeam")         --跳过一队
    self:RegisterProtocal(20013, "scReBattleFight")         --战斗重连

    self:RegisterProtocal(20014, "scBattlePk")              --战斗切磋请求
    self:RegisterProtocal(20015, "scBattlePkRe")            --战斗切磋返回
    self:RegisterProtocal(20016, "scBattlePkTwice")         --战斗切磋同意

    self:RegisterProtocal(20020, "scRoundNextFight")        --下一波怪物
    self:RegisterProtocal(20022, "scFightSpeed")            --战斗加速协议

    self:RegisterProtocal(20033, "handle20033")             --切磋结算
    self:RegisterProtocal(20034, "handle20034")             --切磋视频分享
    self:RegisterProtocal(20036, "handle20036")             --观看跨服录像

    self:RegisterProtocal(20060, "handle20060")             --切换按钮时候先请求这个东西是否在战斗
    self:RegisterProtocal(20061, "handle20061")             --假播报战斗数据
    self:RegisterProtocal(20062, "handle20062")             --跳过战斗

    --试调bug用
    self:RegisterProtocal(10957, "handle10957")             --"通知客户端发送战斗信息"
end

--和后端协商接受的发送战斗信息 马上向后端返回当前战斗信息
function BattleController:handle10957()
    --目前收集的是 
    local string_format = string.format
    local msg = string_format("[fight_type:%s]",self.cur_fight_type) -- 当前的战斗类型
    if BaseView and BaseView.winMap and #BaseView.winMap > 0 then
        -- local cur_win = BaseView.winMap[#BaseView.winMap]
        for i,win in ipairs(BaseView.winMap) do
            msg = msg..string_format(",[%s]",win.layout_name)
        end
        -- msg = msg.. string_format(",[open_win:%s]", cur_win.layout_name) -- 当前的ui没有类名字..拿layout名字也可以知道
    end
    local protocal = {}
    protocal.combat_msg = msg
    self:SendProtocal(10958, protocal)
end

--准备战斗数据
function BattleController:csReadyFightStart()
    local protocal = {}
    self:SendProtocal(20001, protocal)
end

--回合数据
function BattleController:scRoundFightStart(data)
    if PLATFORM_NAME == "demo" or PLATFORM_NAME == "release" then
        -- print("playRoundStart数据")
	end
    if data then
        self.model:playRoundStart(data)
    end
end

--技能播报
function BattleController:scUseSkillData(data)
    if PLATFORM_NAME == "demo" or PLATFORM_NAME == "release" then
		-- print("addRoundDatas数据")
	end
    self.model:setUseSkillStatus(false)
    self.model:addRoundData(data)
end

--通知服务器完成
function BattleController:csSkillPlayEnd()
    if PLATFORM_NAME == "demo" or PLATFORM_NAME == "release" then
        print("正常播报,通知服务器播报完成")
        -- print(debug.traceback())
    end
    local protocal = {}
    self:SendProtocal(20005, protocal)
end

--==============================--
--desc:这里是弹开结算面板
--time:2017-06-22 05:13:48
--@data:
--@return
--==============================--
function BattleController:scFightEnd(data)
     if data then
        if PLATFORM_NAME == "demo" or PLATFORM_NAME == "release" then
            print("服务器通知战斗结束", data.combat_type, os.time())
        end
        local is_replay = false
        if data.combat_type > 1000 then  -- 如果结束的战斗是录像，那么战斗类型后端会+1000以标识这是录像
            data.combat_type = data.combat_type - 1000
            is_replay = true
        end
        self.fighting_type_list[data.combat_type] = nil
        self.model:showWin(data, is_replay)

        --冒险中在没有返回战斗结算之前不能点击其他事件
        if data.combat_type == BattleConst.Fight_Type.Adventrue then
            AdventureController:getInstance():getUiModel():setAdventureFightReturnTag(true)
        end
        -- 无尽试炼的战斗的话,都要移除掉无尽战斗buff选择提示
        if data.combat_type == BattleConst.Fight_Type.Endless then
            PromptController:getInstance():getModel():removePromptDataByTpye(PromptTypeConst.Endless_trail)
            Endless_trailController:getInstance():sendRankInfo()
        end
    end
end
--退出战斗
function BattleController:csFightExit()
    local protocal = {}
    self:SendProtocal(20008, protocal)
end

function BattleController:scFightExit(data)
    message(data.msg)
end

-- 跳过一队
function BattleController:csSkipFirstTeam(  )
    local protocal = {}
    self:SendProtocal(20009, protocal)
end

function BattleController:scSkipFirstTeam( data )
    if data then
        message(data.msg)
    end
end

--确认切磋请求
function BattleController:confirmBattlePk(promptVo)
	if promptVo == nil and next(promptVo.list) == nil then return end
    local data = promptVo.list[1].data
    local start_time = promptVo.list[1].time
    local time = GameNet:getInstance():getTime() - start_time
    if time >= Config.CombatTypeData.data_const.pk_agree_timeout.val then
        message(TI18N("请求已超时"))
        return
    end
    if data then
        local rid, srv_id, role_name, guild_name = promptVo:getSridByData(data)
        local accept_fun = function()
            self:csBattlePkRe(true, {target_srv_id = srv_id, target_id = rid})
        end
        local refuse_fun = function()
        	self:csBattlePkRe(false, {target_srv_id = srv_id, target_id = rid})
        end
        CommonAlert.show(string.format(TI18N("玩家[%s]对你发出了切磋请求，是否同意？\n（同意后对方将与您的镜像进行战斗）"), transformNameByServ(role_name or "", srv_id)), TI18N("同意"),
            accept_fun, TI18N("拒绝"), refuse_fun, CommonAlert.type.rich, nil, {no_clear=true})
    end
end

--战斗切磋请求
function BattleController:csBattlePk(target_id,target_srv_id,is_province)
    local protocal = {}
    protocal.target_id = target_id
    protocal.target_srv_id = target_srv_id
    protocal.is_province = is_province
    self:SendProtocal(20014,protocal)
end

--战斗切磋请求返回
function BattleController:scBattlePk(data)
    if data then
        ChatController:getInstance():closeChatUseAction()
        FriendController:getInstance():openFriendCheckPanel(false)
        message(data.msg)
    end
end

--同不同意切磋
function BattleController:csBattlePkRe(bool,data)
    local protocal = {}
    protocal.target_id = data.target_id
    protocal.target_srv_id = data.target_srv_id
    protocal.is_agree = bool and TRUE or FALSE
    self:SendProtocal(20015,protocal)
end

--同不同意切磋请求返回
function BattleController:scBattlePkRe(data)
    message(data.msg)
end

--切磋的2次确认提示返回
function BattleController:scBattlePkTwice(data)
    if data then
        if not self:isInFight() then
            local accept_fun = function()
                self:csBattlePkTwiceConfirm(true, {target_srv_id = data.target_srv_id, target_id = data.target_id})
            end
            local refuse_fun = function()
                self:csBattlePkTwiceConfirm(false,{target_srv_id = data.target_srv_id, target_id = data.target_id})
            end
            CommonAlert.show(string.format(TI18N("玩家<div fontcolor=#0x249015>%s</div>同意了你的切磋请求,点击”立即切磋“立即进入切磋战斗？"),data.target_name or ""), TI18N("立即切磋"),
                accept_fun,TI18N("改主意了"), refuse_fun, CommonAlert.type.rich, nil, {no_clear=true,timer = 10,timer_for = true,timer_auto_close = TRUE,pk_status = TRUE})
        end
    end
end

--切磋的2次确认
function BattleController:csBattlePkTwiceConfirm(bool,data)
    local protocal = {}
    protocal.target_id = data.target_id
    protocal.target_srv_id = data.target_srv_id
    protocal.is_agree = bool and TRUE or FALSE
    self:SendProtocal(20016,protocal)
end

--切磋结算
function BattleController:handle20033(data)
    if not data.combat_type then
        data.combat_type = BattleConst.Fight_Type.PK
    end
    if not data.show_panel_type then
        data.show_panel_type = 1
    end
    self.model:showWin(data)
    self.model:setFinishData(data)
end

--请求切磋视频分享
function BattleController:on20034(replay_id,channel,target_name,share_type)
   local protocal = {}
   protocal.replay_id = replay_id
   protocal.channel = channel
   protocal.target_name = target_name
   protocal.share_type = share_type
   self:SendProtocal(20034,protocal)
end

--切磋视频分享
function BattleController:handle20034(data)
    message(data.msg)
end

--战斗重连
function BattleController:scReBattleFight(data)
    if PLATFORM_NAME == "demo" or PLATFORM_NAME == "release" then
        print("scReBattleFight战斗重连",data, data.combat_type, os.time())
    end
    if data then
        self.fighting_type_list[data.combat_type] = true
        if BattleConst.getUIFightByFightType(data.combat_type) == MainuiController:getInstance():getUIFightType() then
            self.model:setReconnectStatus(true)
            self:setInitStatus(false)
            self.model:createBattleScence(data)
        end
    end
end

--回合开始播放完成告诉服务器
function BattleController:csRoundFightEnd()
    if PLATFORM_NAME == "demo" or PLATFORM_NAME == "release" then
		print("回合播报,通知服务器播报完成")
        -- print(debug.traceback())
	end
    self:SendProtocal(20019, {})
end

--下一波怪物更新接口
function BattleController:scRoundNextFight(data)
    if data then
        if self.model:getBattleScene() then
            self.model:setNextMonStatus(true)
            self.model:upDateNextMon(data)
        end
    end
end
--地图加载完成
function BattleController:csLoadMapFinish()
    if PLATFORM_NAME == "demo" or PLATFORM_NAME == "release" then
		print("csLoadMapFinish地图准备完成")
	end
    local protocal = {}
    self:SendProtocal(20026,protocal)
end

--战斗真正初始化
function BattleController:scInitFightStart(data)
    if PLATFORM_NAME == "demo" or PLATFORM_NAME == "release" then
        print("scInitFightStart战斗初始化",data, data.combat_type, os.time())
    end
    if data then
        self.lase_fight_data = data        
        self.fighting_type_list[data.combat_type] = true
        self:setInitStatus(true)
        self:setCurFightType(data.combat_type)
        self.battle_hook_model:chanegBattle(data)
    end
end

-- 实时战斗状态信息
function BattleController:setCurFightInfo(list)
    self.fighting_type_list = {}
    for i, v in pairs(list) do
        self.fighting_type_list[v.combat_type] = true
    end
end

-- 获取指定类型实时战斗状态信息
function BattleController:getCurFightInfo(combat_type)
    combat_type = self:getCurFightType()
    if combat_type ~= BattleConst.Fight_Type.GodBattle and combat_type ~= BattleConst.Fight_Type.Darma then 
        return false
    end
    return self.fighting_type_list and self.fighting_type_list[combat_type]
end

--重连准备好了
function BattleController:csReBattleFightReady()
    if PLATFORM_NAME == "demo" or PLATFORM_NAME == "release" then
        print("csReBattleFightReady重连准备好了")
    end
    local protocal = {}
    self:SendProtocal(20028,protocal)
end

-- 改变战斗速度
function BattleController:csFightSpeed( speed )
    local protocal = {}
    protocal.speed = speed
    self:SendProtocal(20022,protocal)
end

-- 改变战斗速度返回
function BattleController:scFightSpeed( data )
    message(data.msg)
end

--是否进去后台
function BattleController:csEnterBackGround(bool)
    if not RoleController or not RoleController:getInstance():getRoleVo() then return end
    local protocal = {}
    protocal.status = bool and TRUE or FALSE
    self:SendProtocal(10397,protocal)
end

--光看录像状态记录
function BattleController:setWatchReplayStatus(bool)
    self.is_watch_replay = bool
end
--
function BattleController:getWatchReplayStatus()
    return  self.is_watch_replay
end

-- 是否为宝可梦试玩的战斗
function BattleController:setIsHeroTestWar( status )
    self.is_hero_test = status
end
function BattleController:getIsHeroTestWar(  )
    return self.is_hero_test
end

function BattleController:csRecordBattle(replay_id,replay_srv_id)
    if replay_srv_id == nil then
        local role_vo = RoleController:getInstance():getRoleVo();
        if role_vo == nil then return end
        replay_srv_id = role_vo.srv_id
    end

    local protocal = {}
    protocal.replay_id = replay_id
    protocal.replay_srv_id = replay_srv_id
    self:SendProtocal(20036,protocal)
end

function BattleController:handle20036(data)
    message(data.msg)
    if data.code == 1 then
        ChatController:getInstance():closeChatUseAction()
        self:setWatchReplayStatus(true)
    end 
end

--==============================--
--desc:保存观战状态
--time:2017-12-07 02:36:32
--@id:
--@return
--==============================--
function BattleController:setWatchWitnessBattleStatus(status)
	self.is_watch_witness = status
end

function BattleController:getWatchWitnessBattleStatus()
	return self.is_watch_witness
end

--==============================--
--desc:进入战斗场景
--time:2018-09-07 12:04:45
--@data:
--@return 
--==============================--
function BattleController:openBattleScene(data)
    self.model:createBattleScence(data)
end

function BattleController:getActTime(key)
    local val = 1
    if Config.BattleActData.data_get_act_data and Config.BattleActData.data_get_act_data[key] then
        val = Config.BattleActData.data_get_act_data[key].val/100
    end
    return val
end

--打开游戏结算
function BattleController:openFinishView(bool,fight_type,data)
    if bool == true then
        self.fighting_type_list[fight_type] = nil
        if self.finish_result_view_list[fight_type] then
            self.finish_result_view_list[fight_type]:close()
            self.finish_result_view_list[fight_type] = nil
        end
        -- 如果是在剧情引导中,则不需要弹出这些
        if GuideController:getInstance():isInGuide() then
            self.model:result(data) -- 但需要清理战斗场景
            return
        end
        if not self.is_unlock_chapter then
            if fight_type == BattleConst.Fight_Type.WorldBoss then --世界boss特殊处理,无论输赢都显示物品展示界面
            
            elseif fight_type == BattleConst.Fight_Type.PK then
                self.finish_result_view_list[fight_type] = BattlePkResultView.New(data.result,BattleConst.Fight_Type.PK)
                self.finish_result_view_list[fight_type]:open(data)
            elseif fight_type == BattleConst.Fight_Type.Arena then --竞技场
                ArenaController:getInstance():openLoopResultWindow(true, data)
            elseif fight_type == BattleConst.Fight_Type.GuildDun then --公会副本
                GuildbossController:getInstance():openGuildbossResultWindow(true, data, fight_type)
            elseif fight_type == BattleConst.Fight_Type.StarTower then --星命塔
                StartowerController:getInstance():openResultWindow(true, data)
            elseif fight_type == BattleConst.Fight_Type.SingleBoss then
            
            elseif fight_type == BattleConst.Fight_Type.Darma and data and data.result == 1 then -- 剧情副本战斗胜利时
                -- 设置不要马上显示升级
                LevupgradeController:getInstance():waitForOpenLevUpgrade(true)
                BattleResultMgr:getInstance():setWaitShowPanel(true)

                self.finish_result_view_list[fight_type] = BattleMvpView.New(data)
                self.finish_result_view_list[fight_type]:open(data)
            elseif fight_type == BattleConst.Fight_Type.LadderWar then
                LadderController:getInstance():openLadderBattleResultWindow(true, data)
            elseif fight_type == BattleConst.Fight_Type.HeavenWar and data.result == 1 then -- 天界副本战斗胜利
                HeavenController:getInstance():openHeavenBattleWinView(true, data)
            elseif fight_type == BattleConst.Fight_Type.CrossArenaWar then -- 跨服竞技场
                CrossarenaController:getInstance():openCrossarenaResultWindow(true, data)
            elseif fight_type == BattleConst.Fight_Type.AdventrueMine then -- 秘矿冒险
                AdventureController:getInstance():openAdventureMineFightResultPanel(true, data)
            elseif fight_type == BattleConst.Fight_Type.TermBeginsBoss then -- 开学季战斗类型
                ActiontermbeginsController:getInstance():openActiontermbeginsFightResultPanel(true, data)
            elseif fight_type == BattleConst.Fight_Type.Arean_Team then --组队竞技场
                ArenateamController:getInstance():openArenateamFightResultPanel(true, data)
            elseif fight_type == BattleConst.Fight_Type.PlanesWar and data.result == 1 then -- 位面战斗胜利不用弹结算，直接清除战斗场景,会走独立协议弹窗
                GuildbossController:getInstance():openGuildbossResultWindow(true, data, BattleConst.Fight_Type.PlanesWar)
                self.model:result(data)
            elseif fight_type == BattleConst.Fight_Type.YearMonsterWar and data.result == 1 and data.type ~= ActionyearmonsterConstants.Evt_Type.Monster then -- 年兽活动
                ActionyearmonsterController:getInstance():openActionyearmonsterResultPanel(true, data)
            elseif fight_type == BattleConst.Fight_Type.WhiteDayWar and data.result == 1 then -- 女神试炼
                ActionyearmonsterController:getInstance():openActionyearmonsterResultPanel(true, data, fight_type)
                data.combat_type = fight_type
                self.model:result(data)
            elseif fight_type == BattleConst.Fight_Type.AreanManyPeople then --多人竞技场活动
                ArenaManyPeopleController:getInstance():openArenaManyPeopleFightResultPanel(true, data)
            elseif fight_type == BattleConst.Fight_Type.PractiseTower then --试练塔
                PractisetowerController:getInstance():openResultWindow(true, data)
            else
                if not self.finish_result_view_list[fight_type] then
                    if data.result == 1 then
                        -- 设置不要马上显示升级
                        LevupgradeController:getInstance():waitForOpenLevUpgrade(true) 
                        BattleResultMgr:getInstance():setWaitShowPanel(true)
                        self.finish_result_view_list[fight_type] = BattleResultView.New(data.result, fight_type)
                        self.finish_result_view_list[fight_type]:open(data,fight_type)
                    else
                        self:openFailFinishView(true, fight_type, data.result, data)
                    end
                end
            end
        else
            if MainuiController:getInstance():checkIsInDramaUIFight() then
                MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.Darma)
            end
        end
    else
        if self.finish_result_view_list[fight_type] then
            self.finish_result_view_list[fight_type]:close()
            self.finish_result_view_list[fight_type]= nil
	    end
    end
end

-- 打开战斗伤害统计界面
function BattleController:openBattleHarmInfoView( status, data, setting )
    self:openBattleResultShowInfoWindow(status, data, setting)
    -- if status == true then
    --     if self.harm_info_view == nil then
    --         self.harm_info_view = BattleHarmInfoView.New()
    --     end
    --     if self.harm_info_view:isOpen() == false then
    --         self.harm_info_view:open(data, tab_count)
    --     end
    -- else
    --     if self.harm_info_view then
    --         self.harm_info_view:close()
    --         self.harm_info_view = nil
    --     end
    -- end
end

-- 打开buff总览界面
function BattleController:openBattleBuffInfoView( status, left_name, right_name )
    if status == true then
        if self.buff_info_view == nil then
            self.buff_info_view = BattleBuffInfoView.New()
        end
        if self.buff_info_view:isOpen() == false then
            self.buff_info_view:open(left_name, right_name)
        end
    else
        if self.buff_info_view then
            self.buff_info_view:close()
            self.buff_info_view = nil
        end
    end
end

-- 打开buff列表界面
function BattleController:openBattleBuffListView( status, data, group, partner_bid )
    if status == true then
        if self.buff_list_view == nil then
            self.buff_list_view = BattleBuffListView.New()
        end
        if self.buff_list_view:isOpen() == false then
            self.buff_list_view:open(data, group, partner_bid)
        end
    else
        if self.buff_list_view then
            self.buff_list_view:close()
            self.buff_list_view = nil
        end
    end
end

-- 更新buff列表界面数据
function BattleController:updateBattleBuffListView( data, group, partner_bid )
    if self.buff_list_view and self.buff_list_view:checkIsChosedBuffList(group, partner_bid) then
        self.buff_list_view:setData(data)
    end
end

function BattleController:openFailFinishView(status,fight_type,result,data)
    if status == true then
        -- 如果是在剧情中,则不需要弹出这些
        if GuideController:getInstance():isInGuide() then
            self.model:result(data) -- 但需要清理战斗场景
            return
        end
        
        if not self.is_unlock_chapter then
            if not self.finish_fail_view_list[fight_type] then
                -- 设置不要马上显示升级
                LevupgradeController:getInstance():waitForOpenLevUpgrade(true) 
                BattleResultMgr:getInstance():setWaitShowPanel(true)
                
                local finish_view = BattleFailView.New(fight_type,result,data)
                if finish_view then
                    finish_view:open()
                end
                self.finish_fail_view_list[fight_type] = finish_view
            end
        else
            if MainuiController:getInstance():checkIsInDramaUIFight() then
                MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.Darma)
            end
        end
    else
        if self.finish_fail_view_list[fight_type] then
            self.finish_fail_view_list[fight_type]:close()
            self.finish_fail_view_list[fight_type] = nil
        end
    end
end

-- 打开阵营详细面板
function BattleController:openBattleCampView( status, form_id_list )
    if status == true then
        if self.battle_camp_view == nil then
            self.battle_camp_view = BattleCampView.New()
        end
        if self.battle_camp_view:isOpen() == false then
            self.battle_camp_view:open(form_id_list)
        end
    else
        if self.battle_camp_view then
            self.battle_camp_view:close()
            self.battle_camp_view = nil
        end
    end
end

--==============================--
--desc:获取剧情副本结算面板,引导也需要
--time:2018-07-11 11:46:07
--@return 
--==============================--
function BattleController:getFinishView(combat_type)
    if self.finish_result_view_list then
        return self.finish_result_view_list[combat_type]
    end
end

--- 引导需要,如果引导出现,那么关闭相关的结算界面
function BattleController:closeBattleResultWindow()
    for k,window in pairs(self.finish_result_view_list) do
        window:close()
    end
    self.finish_result_view_list = {}

    for k,window in pairs(self.finish_fail_view_list) do
        window:close()
    end
    self.finish_fail_view_list = {}
end


function BattleController:setInitStatus(status)
    self.init_fight_status = status
end

function BattleController:getInitStatus()
    return self.init_fight_status
end

function BattleController:openBattleView(status, combat_type)
    if status then
        self:createMap(nil, BattleConst.Fight_Type.Darma)
    else
        if self.resources_load then
            self.resources_load:DeleteMe()
            self.resources_load = nil
        end
        self:setCurFightType(0)
        self:send20060(0)
        self.circle_round_data = nil
        -- 这个地方感觉需要判断当前是不是在战斗中,否则这里也会抛出退出战斗事件
        self:clear(true)
    end

end

function BattleController:send20060(combat_type)
    local protocal = {}
    protocal.combat_type = combat_type
    self:SendProtocal(20060, protocal)
end

function BattleController:handle20060(data)
    if PLATFORM_NAME == "demo" or PLATFORM_NAME == "release" then
        print("recv_20060====", data.combat_type)
    end
    self:setCurFightType(data.combat_type)
    if data.combat_type == BattleConst.Fight_Type.Darma and MainuiController:getInstance():checkIsInDramaUIFight() then --剧情副本的话直接在这里处理吧.因为他不存在type==0的情况
        self:openBattleView(true,BattleConst.Fight_Type.Darma)
    end
    GlobalEvent:getInstance():Fire(BattleEvent.COMBAT_TYPE_BACK, data.combat_type, data.type)
end

function BattleController:getCurFightType()
    if self.cur_fight_type then
        return  self.cur_fight_type
    end
end

function BattleController:setCurFightType(fight_type)
    self.cur_fight_type = fight_type
end

function BattleController:getExtendFightType()
    if self.extend_fight_type then
        return self.extend_fight_type
    end
end

function BattleController:setUnlockChapterStatus(status)
    self.is_unlock_chapter = status
end

function BattleController:getUnlockChapterStatus(status)
    return self.is_unlock_chapter
end

function BattleController:setExtendFightType(fight_type)
    self.extend_fight_type = fight_type
end

function BattleController:handle20061(data)
    if data then
        self:setCircleData(data)
        if self.battle_scene and MainuiController:getInstance():checkIsInDramaUIFight() then
            self.battle_scene:updateNormalBattle(data)
        end
    end
end

function BattleController:send20062()
    local protocal = {}
    self:SendProtocal(20062, protocal)
end

function BattleController:handle20062(data)
    message(data.msg)
end

--挂机战斗
function BattleController:openNormalBattle(data)
    print(":挂机战斗:")
    self.model:clearAllObject()
    self.battle_hook_model:clearRole()
    if self.battle_hook_model and data and not self.battle_hook_model:getInitNormalStatus() then
        self.battle_hook_model:createBattleScence(data)
    else
        self.battle_hook_model:openNormalBattle(data,true)
    end
end

--挂机战斗数据
function BattleController:getCircleData()
    if self.circle_round_data then
        return self.circle_round_data
    end
end

--设置挂机战斗数据
function BattleController:setCircleData(data)
    self.circle_round_data = data
end

--是否在播放下一关表现
function BattleController:getDramaStatus()
    if self.is_drama_result then
        return self.is_drama_result
    end
end

function BattleController:setSumLev(sum_lev)
    self.sum_lev = sum_lev
end

function BattleController:getSumlev()
    if self.sum_lev then
        return  self.sum_lev
    end
end

function BattleController:setEnemySumLev(enemy_lev)
    self.enemy_lev = enemy_lev
end

function BattleController:getEnemySumlev()
    if self.enemy_lev then
        return self.enemy_lev
    end
end

function BattleController:setDramaStatus(status)
    self.is_drama_result = status
end

--是否在pk或者观看录像或宝可梦试玩状态
function BattleController:getIsClickStatus()
    return  self:getWatchReplayStatus() or self.is_pk_battle or self:getIsHeroTestWar()
end

function BattleController:setPkStatus(status)
    self.is_pk_battle  = status
end

--先创建地图
function BattleController:createMap(data, combat_type, is_hook_battle)
    combat_type = combat_type or data.combat_type
    if self.fight_type and self.fight_type == combat_type and self.battle_scene then
        if data ~= nil then
            self.model:enterBattle(data)
        end
        return
    end
    self:setPkStatus(false)
    self:setIsHeroTestWar(false)
    if combat_type == BattleConst.Fight_Type.PK then
       self:setPkStatus(true)
    elseif combat_type == BattleConst.Fight_Type.HeroTestWar then
        self:setIsHeroTestWar(true)
    end
    if self.resources_load then
        self.resources_load:DeleteMe()
        self.resources_load = nil
    end
    self:clear()
    self.fight_type = combat_type --战斗类型
    if not self.resources_load then
        self.resources_load = ResourcesLoad.New(true)
        if self.resources_load then
            self.res_list = {
                { path = PathTool.getPlistImgForDownLoad("battle", "battle"), type = ResourcesType.plist },
            }
            self.resources_load:addAllList(self.res_list, function()
                -- self:clear()
                if self.cur_fight_type == self.fight_type then
                    if not self.battle_scene then
                        -- self.battle_scene = BattleSceneNewView.create()
                        self.battle_scene = BattleSceneNewView.new()
                        ViewManager:getInstance():addToLayerByTag(self.battle_scene, ViewMgrTag.BATTLE_LAYER_TAG)
                    end
                    if not tolua.isnull(self.battle_scene) then
                        self.battle_scene:init(self.fight_type)
                        if data ~= nil then
                            self.model:enterBattle(data)
                        end
                    end
                    --MainSceneController:getInstance():handleSceneStatus(false)
                end
            end)
        end
    end
end

--清理场景相关
function BattleController:clear(is_change)
    self.model:clear(true)
    self.battle_hook_model:battleclear()
    local is_detele = self:getExtendFightType() ~= BattleConst.Fight_Type.Darma or self.cur_fight_type == 0
    if self.battle_scene and not tolua.isnull(self.battle_scene) then
        if is_detele == true or is_change == true then
            if self.resources_load then
                self.resources_load:DeleteMe()
                self.resources_load = nil
            end
            self.battle_scene:cleanFightView()
            self.battle_scene:removeAllChildren()
            self.battle_scene:removeFromParent()
            self.battle_scene = nil
            self.fight_type = nil
        end
    end
end

--获取当前战斗资源ID
function BattleController:curBattleResId(combat_type)
    local battle_res_id = 10001
    local is_single_bg = 0
    if combat_type == BattleConst.Fight_Type.Darma then
        local data = BattleDramaController:getInstance():getModel():getDramaData()
        if data and Config.DungeonData.data_drama_world_info and Config.DungeonData.data_drama_world_info[data.mode] and Config.DungeonData.data_drama_world_info[data.mode][data.chapter_id] then
            battle_res_id = Config.DungeonData.data_drama_world_info[data.mode][data.chapter_id].map_id
            is_single_bg = Config.BattleBgData.data_info2[combat_type][battle_res_id].is_single_bg
        end
    else
        local base_config = Config.BattleBgData.data_info[combat_type]
        if base_config == nil then
            base_config = Config.BattleBgData.data_info[BattleConst.Fight_Type.Default]
        end
        if base_config == nil then
            battle_res_id = 10001
        else
            battle_res_id = base_config.bid
            is_single_bg = base_config.is_single_bg
        end
        -- 神界冒险需要根据当前地图id,去读取战斗背景id,所以这里有不一样处理
        if combat_type == BattleConst.Fight_Type.Adventrue then
            local base_data = AdventureController:getInstance():getUiModel():getAdventureBaseData() 
            if base_data then
                local config = Config.AdventureData.data_battle_res[base_data.id] 
                if config and config.battle_res_id then
                    battle_res_id = config.battle_res_id
                end
            end
        -- elseif combat_type == BattleConst.Fight_Type.PlanesWar then -- 位面
        --     battle_res_id = PlanesController:getInstance():getModel():getPlanesBattleBgId() or battle_res_id
        end
    end
    return  battle_res_id,is_single_bg
end

--获取当前战斗场景
function BattleController:getCtrlBattleScene()
    if self.battle_scene and not tolua.isnull(self.battle_scene) then
        return  self.battle_scene
    end
end

--战斗场景的显隐
function BattleController:handleBattleSceneStatus(status)
    if self.battle_scene and not tolua.isnull(self.battle_scene) then
        self.battle_scene:handleBattleSceneStatus(status)
    end
end

--获取地图场景
function BattleController:getMapLayer()
    if not tolua.isnull(self.battle_scene) then
        return self.battle_scene:getMapLayer()
    end
end

--记录是否为假战斗的战斗
function BattleController:setIsNormaBattle(status)
     self.is_normal_battle = status
end

--- 是否是假战斗....
function BattleController:getIsNoramalBattle()
    return self.is_normal_battle 
end


--设置是否已进入战斗状态
function  BattleController:setBattleStartStatus(status)
    self.is_battle_start = status
end

--获取时候已进入战斗状态
function BattleController:getBattleStatus()
    return self.is_battle_start
end

function BattleController:getIsSameBattleType(fight_type)
    return fight_type == self.model:getBattleType()
end

function BattleController:DeleteMe()
    if self.enter_backgroud_event then
        GlobalEvent:getInstance():UnBind(self.enter_backgroud_event)
        self.enter_backgroud_event = nil
    end

    if self.enter_foreground_event then
        GlobalEvent:getInstance():UnBind(self.enter_foreground_event)
        self.enter_foreground_event = nil
    end

    if  self.vip_open_event then
        GlobalEvent:getInstance():UnBind(self.vip_open_event)
        self.vip_open_event = nil
    end

    if  self.disconnect_view_event then
        GlobalEvent:getInstance():UnBind(self.disconnect_view_event)
        self.disconnect_view_event = nil
    end

    if self.disconnect_event then
        GlobalEvent:getInstance():UnBind(self.disconnect_event)
        self.disconnect_event = nil
    end
    self.circle_round_data = nil
    
    self.is_init = false
end

--- 飘资产
function BattleController:playResourceCollect(x, y)
    if tolua.isnull(self.battle_scene) then return end
    if self.battle_scene.playResourceCollect then
        self.battle_scene:playResourceCollect(x, y)
    end
end

--[[
    @desc: 通用战斗结算数据界面
    author:{author}
    time:2020-02-07 17:51:13
    --@status:
	--@data: 
    @return:
]]
function  BattleController:openBattleResultShowInfoWindow(status, data, setting)
    if status == true and data then
        if self.showinfo_window == nil then
            self.showinfo_window = BattleResultShowInfoWindow.New()
        end
        self.showinfo_window:open(data, setting)
    else
        if self.showinfo_window then
            self.showinfo_window:close()
            self.showinfo_window = nil
        end
    end
end