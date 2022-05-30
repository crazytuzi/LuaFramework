-- --------------------------------------------------------------------
-- 战斗结算返回管理
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--     战斗结算返回管理
-- <br/>2019年9月2日
-- --------------------------------------------------------------------
BattleResultReturnMgr = BattleResultReturnMgr or BaseClass(BaseController)

function BattleResultReturnMgr:config()
    
end

--根据类型返回
function BattleResultReturnMgr:returnByFightType(fight_type)
    local is_click_status = BattleController:getInstance():getIsClickStatus() 
    if is_click_status then
        --观战中无法跳转
        message(TI18N("观战中无法跳转"))
        return
    end

    if not fight_type then return end
    local cur_win = BaseView.winMap[#BaseView.winMap]
    if cur_win == nil then
        --说明是在 主界面 也可能在 剧情界面 都可以直接不用跳转
        if fight_type == BattleConst.Fight_Type.AdventrueMine then --秘矿冒险特殊处理
            AdventureController:getInstance():requestEnterMaxAdventureMine()
        elseif fight_type == BattleConst.Fight_Type.YearMonsterWar then --年兽活动特殊..需要申请协议进入
            ActionyearmonsterController:getInstance():sender28204()
        else
            MainuiController:getInstance():requestOpenBattleRelevanceWindow(fight_type)
        end
    else
        if self:checkFightTypeWinPos(fight_type) then
            --在就在对应的战斗类型对应的ui界面..所以不做任何处理
            return 
        end

        --打印测试用途
        -- BaseView.printWinLog()
        --关闭所有tis界面
        BaseView.closeViewAndTips()
        if fight_type == BattleConst.Fight_Type.Darma then --剧情
            --剧情比较特殊
            MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.drama_scene)
        elseif fight_type == BattleConst.Fight_Type.Arena then --竞技场
            MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.arena_call)
        elseif fight_type == BattleConst.Fight_Type.StarTower then --试练塔
            MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.startower)
        elseif fight_type == BattleConst.Fight_Type.GuildDun then --公会副本
            MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.guild_boss)
        elseif fight_type == BattleConst.Fight_Type.DungeonStone then --宝石副本
            MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.dungeonstone)
        elseif fight_type == BattleConst.Fight_Type.GuildWar then --联盟战斗
            MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.guildwar)
        elseif fight_type == BattleConst.Fight_Type.LadderWar then --跨服天梯
            MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.ladderwar)
        elseif fight_type == BattleConst.Fight_Type.ExpeditFight then --远征
            MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.expedit_fight)
        elseif fight_type == BattleConst.Fight_Type.ElementWar then --元素神殿
            local setting = {}
            setting.open_type = ElementController:getInstance():getModel():getRecordOpenType()
            MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.elementWar, setting)
        elseif fight_type == BattleConst.Fight_Type.HeavenWar then --天界副本
            MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.heavenwar)
        elseif fight_type == BattleConst.Fight_Type.CrossArenaWar then --跨服竞技场
            MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.crossarenawar)
        elseif fight_type == BattleConst.Fight_Type.LimitExercise then --试炼之镜
            MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.limitexercise)
        elseif fight_type == BattleConst.Fight_Type.TermBegins then --开学季副本
            MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.termbegins)
        elseif fight_type == BattleConst.Fight_Type.TermBeginsBoss then --开学季副本
            MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.termbeginsboss)
        elseif fight_type == BattleConst.Fight_Type.Endless then --无尽试炼
            MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.endless)
        elseif fight_type == BattleConst.Fight_Type.PrimusWar then --星河
            MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.primuswar)
        elseif fight_type == BattleConst.Fight_Type.Adventrue then --神界
            MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.adventure)
        elseif fight_type == BattleConst.Fight_Type.AdventrueMine then --神界
            MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.adventruemine)
        elseif fight_type == BattleConst.Fight_Type.EliteMatchWar or
               fight_type == BattleConst.Fight_Type.EliteKingMatchWar then --精英赛王者赛
               ElitematchController:getInstance():openElitematchMainWindow(true)
            -- MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.adventruemine)
        elseif fight_type == BattleConst.Fight_Type.GuildSecretArea then --公会秘境
            MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.guildsecretarea)
        elseif fight_type == BattleConst.Fight_Type.Arean_Team then --组队竞技场
            MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.arenateam)
        elseif fight_type == BattleConst.Fight_Type.MonopolyWar_1 then -- 大富翁阶段一
            MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.monopolywar_1)
        elseif fight_type == BattleConst.Fight_Type.MonopolyWar_2 then -- 大富翁阶段二
            MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.monopolywar_2)
        elseif fight_type == BattleConst.Fight_Type.MonopolyWar_3 then -- 大富翁阶段三
            MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.monopolywar_3)
        elseif fight_type == BattleConst.Fight_Type.MonopolyWar_4 then -- 大富翁阶段四
            MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.monopolywar_4)
        elseif fight_type == BattleConst.Fight_Type.MonopolyBoss then -- 大富翁boss
            MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.monopolyboss)
        elseif fight_type == BattleConst.Fight_Type.PlanesWar then -- 位面
            MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.planeswar)
        elseif fight_type == BattleConst.Fight_Type.YearMonsterWar then -- 年兽活动
            MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.yearmonsterWar)
        elseif fight_type == BattleConst.Fight_Type.WhiteDayWar then -- 女神试炼
            MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.whitedaywar)
        elseif fight_type == BattleConst.Fight_Type.AreanManyPeople then -- 多人竞技场
            MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.arenamanypeople)
        else
            print("错误的类型: "..tostring(fight_type))
        end
    end
end

--检查战斗类型是否在对应的战斗界面里面..如果在无需做任何操作只需要关闭当前页面
--对应玩法的 controller win对象
-- return 
function BattleResultReturnMgr:checkFightTypeWinPos(fight_type)
    --当前界面定义..只要满足其中一个界面存在都会判定 存在该界面
    local cur_win, cur_win2
    local is_cur_win = false
    if fight_type == BattleConst.Fight_Type.Arena then --竞技场
        cur_win = ArenaController:getInstance().loop_match_window

    elseif fight_type == BattleConst.Fight_Type.StarTower then --试练塔
        cur_win = StartowerController:getInstance().main_view
        
    elseif fight_type == BattleConst.Fight_Type.GuildDun then --公会副本
        cur_win = GuildbossController:getInstance().main_window
        
    elseif fight_type == BattleConst.Fight_Type.DungeonStone then --宝石副本
        cur_win = Stone_dungeonController:getInstance().stoneDungeonView
        
    elseif fight_type == BattleConst.Fight_Type.GuildWar then --联盟战斗
        cur_win = GuildwarController:getInstance().main_window
        
    elseif fight_type == BattleConst.Fight_Type.LadderWar then --跨服天梯
        cur_win = LadderController:getInstance().ladder_main_window
        
    elseif fight_type == BattleConst.Fight_Type.ExpeditFight then --远征
        cur_win = HeroExpeditController:getInstance().heroExpeditView

    elseif fight_type == BattleConst.Fight_Type.ElementWar then --元素神殿
        cur_win = ElementController:getInstance().element_main_wnd
        cur_win2 = ElementController:getInstance().element_ectype_wnd
        local win = BaseView.winMap[#BaseView.winMap]
        if win and win == cur_win2 then
            is_cur_win = true
        end
    elseif fight_type == BattleConst.Fight_Type.HeavenWar then --天界副本
        cur_win = HeavenController:getInstance().heaven_chapter_wnd
        
    elseif fight_type == BattleConst.Fight_Type.CrossArenaWar then --跨服竞技场
        cur_win = CrossarenaController:getInstance().crossarena_main_wnd
        
    elseif fight_type == BattleConst.Fight_Type.LimitExercise then --试炼之镜
        cur_win = LimitExerciseController:getInstance().limit_exercise_view
        
    elseif fight_type == BattleConst.Fight_Type.TermBegins or
           fight_type == BattleConst.Fight_Type.TermBeginsBoss then --开学季副本
        cur_win = ActiontermbeginsController:getInstance().action_term_begins_main_window
        
    elseif fight_type == BattleConst.Fight_Type.Endless then --无尽
        cur_win = Endless_trailController:getInstance().endless_main_window
        
    elseif fight_type == BattleConst.Fight_Type.PrimusWar then --星界
        cur_win = PrimusController:getInstance().primus_main_window
        cur_win2 = PrimusController:getInstance().primus_challenge_panel
        
    elseif fight_type == BattleConst.Fight_Type.Adventrue then --神界冒险
        cur_win = AdventureController:getInstance().adventure_window
        
    elseif fight_type == BattleConst.Fight_Type.AdventrueMine then --矿脉
        cur_win = AdventureController:getInstance().adventure_mine_window
        
    elseif fight_type == BattleConst.Fight_Type.EliteMatchWar or
        fight_type == BattleConst.Fight_Type.EliteKingMatchWar then --精英赛王者赛
        cur_win = ElitematchController:getInstance().elitematch_main_window
        cur_win2 = ElitematchController:getInstance().elitematch_matching_window
        
    elseif fight_type == BattleConst.Fight_Type.GuildSecretArea then --公会秘境
        cur_win = GuildsecretareaController:getInstance().guildsecretarea_main_window
    elseif fight_type == BattleConst.Fight_Type.Arean_Team then --组队竞技场
        cur_win = ArenateamController:getInstance().arenateam_main_window
    elseif fight_type == BattleConst.Fight_Type.PlanesWar then --位面
        cur_win = PlanesafkController:getInstance().planesafk_main_window
        if cur_win then
            is_cur_win = true
        end
    elseif fight_type == BattleConst.Fight_Type.YearMonsterWar then -- 年兽活动
        cur_win = ActionyearmonsterController:getInstance().actionyearmonster_main_window
        cur_win2 = ActionyearmonsterController:getInstance().actionyearmonster_challenge_panel
    elseif fight_type == BattleConst.Fight_Type.WhiteDayWar then -- 女神试炼
        local cur_win = ActionController:getInstance().action_operate
        if cur_win and cur_win:isOpen() and 
            cur_win.selected_tab and 
            cur_win.selected_tab.data and 
            cur_win.selected_tab.data.bid == ActionRankCommonType.white_day then
            is_cur_win = true
        end
    elseif fight_type == BattleConst.Fight_Type.AreanManyPeople then -- 多人竞技场
        cur_win = ArenaManyPeopleController:getInstance().arenamanypeople_main_window
    else
        print("错误的类型: "..tostring(fight_type))
    end

    if (cur_win and cur_win:isOpen()) or (cur_win2 and cur_win2:isOpen()) or is_cur_win then
        return true
    end
    return false
end

