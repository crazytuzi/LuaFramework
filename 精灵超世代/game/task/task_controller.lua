-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-05-22
-- --------------------------------------------------------------------
TaskController = TaskController or BaseClass(BaseController)

function TaskController:config()
    self.model = TaskModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function TaskController:getModel()
    return self.model
end

function TaskController:registerEvents()
    if self.init_quest_event == nil then
        self.init_quest_event = GlobalEvent:getInstance():Bind(EventId.ROLE_CREATE_SUCCESS, function()
            GlobalEvent:getInstance():UnBind(self.init_quest_event)
            self.init_quest_event = nil
            
            -- 角色更新之后请求3条任务相关数据
            --self:requestBaseQuestData()

            self.role_vo = RoleController:getInstance():getRoleVo()
            if self.role_assets_event == nil then
                self.role_assets_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value)
                    if key == "activity" then
                        self.model:checkQuestAndFeatStatus(TaskConst.update_type.activity)
                    end
                end)
            end
        end)
    end

    --[[if self.re_link_game_event == nil then
        self.re_link_game_event = GlobalEvent:getInstance():Bind(LoginEvent.RE_LINK_GAME, function()
            self:openTaskMainWindow(false)
            self:requestBaseQuestData()
        end)
    end--]]
end

function TaskController:requestBaseQuestData()
    self:SendProtocal(10400, {})                            -- 请求所有任务列表
    self:SendProtocal(16400, {})                            -- 请求当前所有的成就列表
    self:requestActivityInfo()                              -- 请求活跃度
end

function TaskController:registerProtocals()
    self:RegisterProtocal(10400, "on10400") --全部任务列表
    self:RegisterProtocal(10403, "on10403") --增加已接任务
    self:RegisterProtocal(10406, "on10406") --提交任务返回，客户端自己更新内存缓存数据
    self:RegisterProtocal(10409, "on10409") --更新已接任务进度
    
    self:RegisterProtocal(16400, "on16400") --全部成就列表
    self:RegisterProtocal(16401, "on16401") --更新成就进度，也可能是新增成就
    self:RegisterProtocal(16402, "on16402") --提交成就返回

    self:RegisterProtocal(20300, "on20300") --已领取的活跃宝箱
    self:RegisterProtocal(20301, "on20301") --请求领取活跃宝箱

    --历练协议
    self:RegisterProtocal(25810, "handle25810") --已接成就列表
    self:RegisterProtocal(25811, "handle25811") --推送成就列表
    self:RegisterProtocal(25812, "handle25812") --领取成就奖励
end

--[[
    @desc:打开日常任务主界面
    author:{author}
    time:2018-05-22 11:32:35
    --@status:打开或者关闭
	--@index:自动跳转到
    return
]]
function TaskController:openTaskMainWindow(status, index)
    if status == false then
        if self.task_main_window ~= nil then
            self.task_main_window:close()
            self.task_main_window = nil
        end
    else
        if self.task_main_window == nil then
            self.task_main_window = TaskMainWindow.New()
        end
        if self.task_main_window:isOpen() == false then
            self.task_main_window:open(index)
        end
    end
end

--[[
    @desc:点击任务前往
    author:{author}
    time:2018-05-22 21:00:26
    --@data:
	--@index:
	--@open_type: 
    return
]]
function TaskController:handleTaskProgress(data, index, open_type)
    index = index or 1
    if data.config.progress == nil or #data.config.progress == 0 then
        if data.id then
            print("=================> 处理任务进度时出错,任务id为 " .. data.id .. " 的没有配置任务进度")
        end
        return
    end
    local progressConfig = data.config.progress[index]
    if progressConfig == nil then
        if data.id then
            print("=================> 处理任务id为 " .. data.id .. " 的第 " .. index .. " 个进度要求时出错")
        end
        return
    end
    -- 扩展参数用于跳转
    local extra = data.config.extra
    self:gotoTagertFun(progressConfig, extra, open_type)
end

--==============================--
--desc:任务和成就的跳转
--time:2018-07-07 03:57:59
--@progressConfig:
--@extra:
--@open_type:
--@return 
--==============================--
function TaskController:gotoTagertFun(progressConfig, extra, open_type)
    if progressConfig == nil then return end
    local _progress = Config.QuestData.data_progress_lable
    if progressConfig.cli_label == _progress.evt_recruit then --进行X次宝可梦召唤
        JumpController:getInstance():jumpViewByEvtData({1})
    elseif progressConfig.cli_label == _progress.evt_partner then --获得1个SS宝可梦2.获得XX个宝可梦3.集齐冰雪领域（图书馆XX类型收集）的所有宝可梦4.获得XX个SS宝可梦
        if extra and next(extra) then
            local extra_type = extra[1]
            local extra_val = extra[2]
            JumpController:getInstance():jumpViewByEvtData({2, extra_type, extra_val})
        else
            PartnersummonController:getInstance():openPartnerSummonWindow(true)
        end
    elseif progressConfig.cli_label == _progress.evt_arena_fight or --竞技场挑战X次（无论成败）
        progressConfig.cli_label == _progress.evt_arena_fight_result or --竞技场挑战胜利X次
        progressConfig.cli_label == _progress.evt_arena_score or --竞技场
        progressConfig.cli_label == _progress.evt_arena_rank then --竞技场排行达到前XX名
        JumpController:getInstance():jumpViewByEvtData({3})
    elseif progressConfig.cli_label == _progress.evt_friend_present or --向好友赠送
        progressConfig.cli_label == _progress.evt_friend then --拥有XX个好友
        JumpController:getInstance():jumpViewByEvtData({4})
    elseif progressConfig.cli_label == _progress.evt_dungeon_pass then --通过指定副本id
        JumpController:getInstance():jumpViewByEvtData({5})
    elseif progressConfig.cli_label == _progress.evt_levup or   --人物角色达到XX级
        progressConfig.cli_label == _progress.evt_get_item or   -- 获得一个物品
        progressConfig.cli_label == _progress.evt_dungeon_enter then --每日挑战X次地下城副本
        JumpController:getInstance():jumpViewByEvtData({5})
    elseif progressConfig.cli_label == _progress.evt_loss_silver_coin then --累计消耗xx银币,    elseif progressConfig.cli_label == _progress.evt_loss_coin then --累计消耗xx金币,
        JumpController:getInstance():jumpViewByEvtData({6})
    elseif progressConfig.cli_label == _progress.evt_loss_red_gold_or_gold then --累计消耗xx红蓝钻,

    elseif progressConfig.cli_label == _progress.evt_gain_silver_coin then --拥有xx银币,

    elseif progressConfig.cli_label == _progress.evt_gain_coin then --拥有xx金币,

    elseif progressConfig.cli_label == _progress.evt_gain_gold then --拥有xx蓝钻
        JumpController:getInstance():jumpViewByEvtData({7})
    elseif progressConfig.cli_label == _progress.evt_eqm_sell then --装备熔炼
        JumpController:getInstance():jumpViewByEvtData({8})
    elseif progressConfig.cli_label == _progress.evt_say then --世界聊天
        JumpController:getInstance():jumpViewByEvtData({9})
    elseif progressConfig.cli_label == _progress.evt_friend_sns then --私聊
        JumpController:getInstance():jumpViewByEvtData({10})
    elseif progressConfig.cli_label == _progress.evt_market_gold_buy then --在金币市场购买一次商品

    elseif progressConfig.cli_label == _progress.evt_dungeon_fast_combat then --快速作战X次
        JumpController:getInstance():jumpViewByEvtData({11})
    elseif progressConfig.cli_label == _progress.evt_adventure_explore or --探险X间未探索的房间
        progressConfig.cli_label == _progress.evt_adventure_plunder or --任意掠夺他人X次（无论成败
        progressConfig.cli_label == _progress.evt_adventure_goto_floor or --进入神界冒险第X层
        progressConfig.cli_label == _progress.evt_adventure_box or --开启宝箱XX次(宝箱总数)7.宝箱开出X次神器
        progressConfig.cli_label == _progress.evt_adventure_finger_guessing or --猜拳累计获胜X次8.猜拳累计失败X次
        progressConfig.cli_label == _progress.evt_adventure_answer_all_right or --智力大乱斗答题全对累计X次
        progressConfig.cli_label == _progress.evt_adventure_plunder_result or --累计成功掠夺X次
        progressConfig.cli_label == _progress.evt_adventure_kill_mon then --累计击败小怪X次
    elseif progressConfig.cli_label == _progress.evt_boss_fight or --挑战X次个人BOSS
        progressConfig.cli_label == _progress.evt_boss_fight_result then --击败XX级个人BOSS（指定类)

    elseif progressConfig.cli_label == _progress.evt_world_boss_fight or --挑战X次世界BOSS3.累计挑战XX次世界BOSS
        progressConfig.cli_label == _progress.evt_world_boss_fight_ko then   --完成一次任意世界BOSS的击杀（最后一击）
        
    elseif progressConfig.cli_label == _progress.evt_star_tower_pass then --扫荡或挑战星命塔任意一层X次
        JumpController:getInstance():jumpViewByEvtData({12})
    elseif progressConfig.cli_label == _progress.evt_guild_dun_fight or --挑战任意公会bossX次
        progressConfig.cli_label == _progress.evt_guild_dun_fight_ko then --对公会Boss的最后一击达到x次
        JumpController:getInstance():jumpViewByEvtData({31}) 
    elseif progressConfig.cli_label == _progress.evt_guild_donate then --2.公会任意种类捐献X次3.公会XX类型捐献达到X次4.公会所以类型捐献总共达到XX次
        JumpController:getInstance():jumpViewByEvtData({13})
    elseif progressConfig.cli_label == _progress.evt_partner_enchant_eqm or --精炼装备X次
        progressConfig.cli_label == _progress.evt_partner_levelup or --升级宝可梦X次
        progressConfig.cli_label == _progress.evt_partner_eqm or --装备X套橙色装备（即武器、衣服、头盔、鞋子都为橙色）
        progressConfig.cli_label == _progress.evt_partner_artifact or --装备1件神器
        progressConfig.cli_label == _progress.evt_eqm_compound then --进阶x装备
        JumpController:getInstance():jumpViewByEvtData({19})
    elseif progressConfig.cli_label == _progress.evt_star_divination then --任意进行X次观星（普通观星和皇家观星）
        AuguryController:getInstance():openMainView(true) 
    elseif progressConfig.cli_label == _progress.evt_dungeon_auto then --扫荡剧情副本
        JumpController:getInstance():jumpViewByEvtData({5})
    elseif progressConfig.cli_label == _progress.evt_guild_join then --加入一个公会
        JumpController:getInstance():jumpViewByEvtData({14})
    elseif progressConfig.cli_label == _progress.evt_gain_guild then --公会贡献达到
        JumpController:getInstance():jumpViewByEvtData({14})
    elseif progressConfig.cli_label == _progress.evt_loss_guild then --累计消耗XX贡献点
        JumpController:getInstance():jumpViewByEvtData({15, MallConst.MallType.UnionShop})
    elseif progressConfig.cli_label == _progress.evt_power then --战力达到多少
        JumpController:getInstance():jumpViewByEvtData({16})
    elseif progressConfig.cli_label == _progress.evt_formation_open or --已学习的阵法达到X个
        progressConfig.cli_label == _progress.evt_formation_level_up then --X个阵法达到X级
    elseif progressConfig.cli_label == _progress.evt_market_silver_buy then --累计在市场消耗XX银币

    elseif progressConfig.cli_label == _progress.evt_market_coin_sold then --累计在市场赚取XX金币3.累计在金币市场卖出XX件金币物品

    elseif progressConfig.cli_label == _progress.evt_market_silver_sold then --累计在银币摆摊卖出XX件银币物品5.累计在银币摆摊中赚取XX银币
    
    elseif progressConfig.cli_label  == _progress.evt_dungeon_stone_fight then --1.参与x次宝石副本2.参与x次圣器副本,
        JumpController:getInstance():jumpViewByEvtData({17}) 
    elseif progressConfig.cli_label == _progress.evt_shipping then --参与远航,
        JumpController:getInstance():jumpViewByEvtData({18}) 
    elseif progressConfig.cli_label == _progress.evt_escort_enter or progressConfig.cli_label == _progress.evt_escort_fight then -- 萌兽
        MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene, MainuiConst.sub_type.escort) 
    elseif progressConfig.cli_label == _progress.evt_endless_fight then -- 无尽试炼
         JumpController:getInstance():jumpViewByEvtData({43}) 
    elseif progressConfig.cli_label == _progress.evt_mystery_buy then -- 打开商城
        if progressConfig.target == 1 then
            JumpController:getInstance():jumpViewByEvtData({15, MallConst.MallType.GodShop})
        elseif progressConfig.target == 2 then
            JumpController:getInstance():jumpViewByEvtData({15, MallConst.MallType.Recovery})
        elseif progressConfig.target == 3 then
            JumpController:getInstance():jumpViewByEvtData({15, MallConst.MallType.ScoreShop})
        elseif progressConfig.target == 4 then -- 杂货店
            JumpController:getInstance():jumpViewByEvtData({6})
        else
            JumpController:getInstance():jumpViewByEvtData({15, MallConst.MallType.Recovery})
        end
    elseif progressConfig.cli_label == _progress.evt_partner_stone_all_lv then -- 打开宝可梦主界面宝石
        
    elseif progressConfig.cli_label == _progress.evt_partner_star then -- 打开宝可梦主界面
        JumpController:getInstance():jumpViewByEvtData({19})
    elseif progressConfig.cli_label == _progress.evt_hallows_all_step then -- 打开提升圣器
        JumpController:getInstance():jumpViewByEvtData({20})
    elseif progressConfig.cli_label == _progress.evt_guild_war then -- 打开公会站
        JumpController:getInstance():jumpViewByEvtData({21})
    elseif progressConfig.cli_label == _progress.evt_endless_pass then -- 打开无尽之塔
        Endless_trailController:getInstance():openEndlessMainWindow(true)
    elseif progressConfig.cli_label == _progress.evt_partner_decompose then -- 祭祀小屋
        JumpController:getInstance():jumpViewByEvtData({22})
    elseif progressConfig.cli_label == _progress.evt_partner_star_up then -- 融合祭坛
        JumpController:getInstance():jumpViewByEvtData({23})
    elseif progressConfig.cli_label == _progress.evt_star_tower_floor_pass then -- 试练塔
        JumpController:getInstance():jumpViewByEvtData({12})
    elseif progressConfig.cli_label == _progress.evt_recruit_high then -- 先知殿 
        JumpController:getInstance():jumpViewByEvtData({24})
    elseif progressConfig.cli_label == _progress.evt_expedition_fight then  -- 远征
        JumpController:getInstance():jumpViewByEvtData({25})
    elseif progressConfig.cli_label == _progress.evt_artifact_compose then  -- 锻造屋符文锻造
        JumpController:getInstance():jumpViewByEvtData({26, ForgeHouseConst.Tab_Index.Artifact})
    elseif progressConfig.cli_label == _progress.evt_friend_present then -- 好友界面
        JumpController:getInstance():jumpViewByEvtData({4})
    elseif progressConfig.cli_label == _progress.evt_primus_fight then -- 星河
        JumpController:getInstance():jumpViewByEvtData({27})
    elseif progressConfig.cli_label == _progress.evt_arena_elite_rank then -- 精英大赛
        JumpController:getInstance():jumpViewByEvtData({28})
    elseif progressConfig.cli_label == _progress.evt_sky_ladder_rank then -- 跨服天梯
        JumpController:getInstance():jumpViewByEvtData({29})
    elseif progressConfig.cli_label == _progress.evt_equipment_compound then -- 装备合成
        JumpController:getInstance():jumpViewByEvtData({26, ForgeHouseConst.Tab_Index.Equip})
    elseif progressConfig.cli_label == _progress.evt_worship then -- 家园
        JumpController:getInstance():jumpViewByEvtData({51})
    elseif progressConfig.cli_label == _progress.evt_get_speciality or -- 萌宠
        progressConfig.cli_label == _progress.evt_get_furniture or -- 萌宠
        progressConfig.cli_label == _progress.evt_travel_time then -- 萌宠
        JumpController:getInstance():jumpViewByEvtData({51})
    elseif progressConfig.cli_label == _progress.evt_planes_kill_guard then -- 位面
        JumpController:getInstance():jumpViewByEvtData({68})
    end
end

--- ------------------------任务相关 start
function TaskController:on10400(data)
    self.model:addTaskList(data.quest_list, false, true)
end
function TaskController:on10403(data)
    self.model:addTaskList(data.quest_list)
end
function TaskController:on10409(data)
    self.model:addTaskList(data.quest_list, true)
end
function TaskController:on10406(data)
    message(data.msg)
    if data.flag == TRUE then
        self.model:setTaskCompleted(data.id)
    end
end
function TaskController:requestSubmitTask(id)
    local protocal = {}
    protocal.id = id
    self:SendProtocal(10406, protocal) 
end
--- ------------------------任务相关 end


--- ------------------------成就相关 start
function TaskController:on16400(data)
    self.model:addFeatList(data.feat_list, false, true)
end
function TaskController:on16401(data)
    self.model:addFeatList(data.feat_list, true)
end
function TaskController:on16402(data)
    message(data.msg)
    if data.code == TRUE then
        self.model:setFeatCompleted(data.id)
    end
end
function TaskController:requestSubmitFeat(id)
    local protocal = {}
    protocal.id = id
    self:SendProtocal(16402, protocal) 
end
--- ------------------------成就相关 end

--- ------------------------活跃度相关 start
function TaskController:requestActivityInfo()
    self:SendProtocal(20300, {})
end
function TaskController:on20300(data)
    self.model:updateActivityData(data.activity_box)
end
function TaskController:requestGetActivityAwards(activity)
    local proto = {}
    proto.activity = activity
    self:SendProtocal(20301, proto)
end
function TaskController:on20301(data)
    message(data.msg)
    if data.code == TRUE then
        self.model:updateSingleActivityData(data.activity)
    end
end
--- ------------------------活跃度相关 end


-----------------------------历练协议开始-=----------------------------
--已接成就列表" sys那边了
-- function TaskController:sender25810(partner_id)
--     local protocal ={}
--     self:SendProtocal(25810,protocal)
-- end

function TaskController:handle25810(data)
    self.model:updateTaskExpList(data)
end


--推送成就列表"
function TaskController:handle25811(data)
    self.model:updateTaskExpList(data, true)
    GlobalEvent:getInstance():Fire(TaskEvent.TASK_EXP_UPDATE_EVENT)
end

--领取成就奖励
function TaskController:sender25812(id)
    local protocal = {}
    protocal.id = id
    self:SendProtocal(25812,protocal)
end

function TaskController:handle25812(data)
    local config = Config.RoomFeatData.data_const.home_world_feat
    if config and config.val == data.id then
        --领取的是家园钥匙
        HomeworldController:getInstance():openHomeworldUnlockKeyPanel(true)
    end

    self.model:updateTaskExpDataByID(data.id, data.finish_time)
    GlobalEvent:getInstance():Fire(TaskEvent.TASK_EXP_UPDATE_TINE_EVENT)
end

-----------------------------历练协议结束-=----------------------------



function TaskController:openTaskSharePanel(status, setting)
    if status == false then
        if self.task_share_panel ~= nil then
            self.task_share_panel:close()
            self.task_share_panel = nil
        end
    else
        if self.task_share_panel == nil then
            self.task_share_panel = TaskSharePanel.New()
        end
        if self.task_share_panel:isOpen() == false then
            self.task_share_panel:open(setting)
        end
    end
end

function TaskController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end
