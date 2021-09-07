GuildModel = GuildModel or BaseClass(BaseModel)

function GuildModel:__init()
    self.find_win = nil
    self.create_win = nil
    self.main_win = nil
    self.build_win = nil
    self.change_signature_win = nil
    self.position_win = nil
    self.purpose_win = nil
    self.apply_list_win = nil
    self.store_win = nil
    self.totem_win = nil
    self.question_enter_win = nil
    self.question_win = nil
    self.recommend_win = nil
    self.build_speedup_win = nil
    self.change_name_win = nil
    self.look_change_name_win = nil
    self.plant_flower_panel = nil
    self.set_fresh_man_lev_win = nil
    self.week_reward_panel = nil
    self.new_build_panel = nil
    self.apply_msg_panel = nil
    self.pray_confrim_panel = nil

    self.red_bag_win = nil
    self.red_bag_unopen_win = nil
    self.red_bag_set_win = nil
    self.red_bag_money_win = nil
    self.mem_manage_win = nil
    self.merge_win = nil
    self.healthy_win = nil
    self.merge_tips_win = nil
    self.npc_exchange_win = nil
    self.npc_exchange_fund_win = nil
    self.mem_delete_win = nil
    self.pray_win = nil

    self.my_guild_data = nil
    self.guild_member_list = nil
    self.store_list = nil-- 请求商店数据返回
    self.store_flesh_time = 0
    self.apply_list = nil
    self.current_red_bag = nil
    self.shenshou_data = nil
    self.guild_soldiers = nil
    self.mine_soldier = nil
    self.question_notify_data = nil
    self.current_guild_question_data = nil
    self.activity_guild_question_data = nil
    self.pay_data = nil
    self.prayElementData = nil

    self.reset_info = false --重置公会信息
    self.occupy_id = 30001 --公会领地地图id

    self.merge_type = 1
    self.npc_exchange_left_num = 0
    self.fundNum = 0

    self.has_do_last_delete = false

    self.guild_store_has_refresh = false --标记公会商店是否刚刷新
    self.guild_store_is_warm_tips = false --是否开启mainui提醒

    self.guildTreasure = nil --公会宝藏信息
    self.guildLoot = nil -- 功勋宝箱（战利品宝库）
    self.guildLeagueLoot = nil -- 联赛功勋宝箱（战利品宝库）

    self.unfresh_man_lev = 40

    self.guild_soldier_look_dat = nil
    self.member_position_names = {
        [0] = TI18N("新秀")
        ,[10] = TI18N("成员")
        ,[20] = TI18N("精英")
        ,[25] = TI18N("宝贝")
        ,[30] = TI18N("兵长")
        ,[40] = TI18N("长老")
        ,[50] = TI18N("副会长")
        ,[60] = TI18N("会长")
    }

    self.member_positions = {
        stduy = 0, --学徒
        mem = 10, --普通成员
        baby = 25, --宝贝
        elite = 20, --精英
        sergeant = 30, --兵长
        elder = 40, --长老
        vice_leader = 50, --副会长
        leader = 60 --会长
    }

    --公会建筑类型
    self.guild_build_type = {
        guild = 0,
        castle = 1,
        study = 2,
        forge = 3,
        store = 4
    }

    --加速类型
    self.speedup_type = {
        type1 = 1
        ,type2 = 2
        ,type3 = 3
    }


    self.dataTypeList = {
        [1] = {name = TI18N("贡\n献"), order = 1, icon = "90011",
        },
        [2] = {name = TI18N("兑\n换"), order = 2, icon = "90036",
            subList = {
                [16] = {name = TI18N("兄弟商店"), spriteFunc = function(imageLoader) imageLoader:SetSprite(SingleIconType.Item, 90036) end, order = 1}
            }
        }
    }

    self.onUpdateStore = EventLib.New()

    self.select_mem_oper_data = nil
    self.change_signature_data  = nil
    self.build_selected_index = self.guild_build_type.guild
    self.selected_build_index = 0

    self.board_announcement_type = 1

    self:InitLang()

    self.waterFlowerInfo = nil
    self.sceneListener = function() self:OnMapLoaded() end
    self.sceneListener1 = function() self:UnitListUpdate() end

    self.lev_sort = function(a, b)
        return a.Lev > b.Lev
    end

    self.post_sort = function(a, b)
        return a.Post > b.Post
    end

    self.gx_sort = function(a, b)
        return a.active > b.active
    end

    self.cup_sort = function(a, b)
        return a.ability > b.ability
    end

    self.require_sort = function(a, b)
        return #a.requirement > #b.requirement
    end

    self.last_login_sort = function(a, b)
        return a.LastLogin > b.LastLogin
    end

    self.lev_sort3 = function(a, b)
        if a.Status ~= b.Status then
            return a.Status > b.Status
        else
            return a.Lev > b.Lev
        end
    end

    self.post_sort3 = function(a, b)
        if a.Status ~= b.Status then
            return a.Status > b.Status
        else
            return a.Post > b.Post
        end
    end

    self.gx_sort3 = function(a, b)
        if a.Status ~= b.Status then
            return a.Status > b.Status
        else
            return a.active > b.active
        end
    end

    self.cup_sort3 = function(a, b)
        if a.Status ~= b.Status then
            return a.Status > b.Status
        else
            return a.ability > b.ability
        end
    end

    self.require_sort3 = function(a, b)
        if a.Status ~= b.Status then
            return a.Status > b.Status
        else
            return #a.requirement > #b.requirement
        end
    end

    self.last_login_sort3 = function(a, b)
        if a.Status ~= b.Status then
            return a.Status > b.Status
        else
            return a.LastLogin > b.LastLogin
        end
    end


    ------反排序
    self.lev_sort2 = function(a, b)
        return a.Lev < b.Lev
    end

    self.post_sort2 = function(a, b)
        return a.Post < b.Post
    end

    self.gx_sort2 = function(a, b)
        return a.active < b.active
    end

    self.cup_sort2 = function(a, b)
        return a.ability < b.ability
    end

    self.require_sort2 = function(a, b)
        return #a.requirement < #b.requirement
    end

    self.last_login_sort2 = function(a, b)
        return a.LastLogin < b.LastLogin
    end



     ------反排序
    self.lev_sort4 = function(a, b)
        if a.Status ~= b.Status then
            return a.Status > b.Status
        else
            return a.Lev < b.Lev
        end
    end

    self.post_sort4 = function(a, b)
        if a.Status ~= b.Status then
            return a.Status > b.Status
        else
            return a.Post < b.Post
        end
    end

    self.gx_sort4 = function(a, b)
        if a.Status ~= b.Status then
            return a.Status > b.Status
        else
            return a.active < b.active
        end
    end

    self.cup_sort4 = function(a, b)
        if a.Status ~= b.Status then
            return a.Status > b.Status
        else
            return a.ability < b.ability
        end
    end

    self.require_sort4 = function(a, b)
        if a.Status ~= b.Status then
            return a.Status > b.Status
        else
            return #a.requirement < #b.requirement
        end
    end

    self.last_login_sort4 = function(a, b)
        if a.Status ~= b.Status then
            return a.Status > b.Status
        else
            return a.LastLogin < b.LastLogin
        end
    end
end

function GuildModel:__delete()
    self:CloseMainUI()
    self:CloseCreateUI()
    self:CloseFindUI()
    self:CloseRecommendUI()
    self:CloseQuestionUI()
    self:CloseTotemUI()
    self:CloseStoreUI()
    self:CloseApplyListUI()
    self:ClosePositionUI()
    self:ClosePurposeUI()
    self:CloseChangeSignatureUI()
    self:CloseFindUI()
    self:CloseCreateUI()
    self:CloseBuildUI()
end

--根据公会状态打开公会
function GuildModel:OpenGuildUI(args)
    if self.reset_info then
        self:InitMainUI(args)
        self.reset_info = false
    elseif self.my_guild_data ~= nil and self.my_guild_data.GuildId ~= 0 then
        self:InitMainUI(args)
    else
        self:InitFindUI()
    end
end

--打开公会主界面
function GuildModel:InitMainUI(args)
    if self.main_win == nil then
        self.main_win = GuildMainWindow.New(self)
    end
    self.main_win:Open(args)
end

function GuildModel:CloseMainUI()
    if self.main_win ~= nil and not BaseUtils.isnull(self.main_win.gameObject) then
        WindowManager.Instance:CloseWindow(self.main_win)
    end
    if self.main_win == nil then
        -- print("===================self.main_win is nil")
    else
        -- print("===================self.main_win is not nil")
    end
end

--打开公会祈福界面
function GuildModel:InitPrayUI(args)
    if RoleManager.Instance.world_lev < 70 then
        NoticeManager.Instance:FloatTipsByString(TI18N("世界等级达到<color='#ff000'>70</color>后可由<color='#23F0F7'>会长/副会长</color>开启"))
        return
    else
        if #GuildManager.Instance.model.my_guild_data.element_info <= 0 or GuildManager.Instance.model.my_guild_data.upgrade_element_time > 0 then
            self:InitBuildUI(2)
        else
            if self.pray_win == nil then
                self.pray_win = GuildPrayWindow.New(self)
            end
            self.pray_win:Open(args)
        end
    end
end

function GuildModel:ClosePrayUI()
    if self.pray_win ~= nil then
        WindowManager.Instance:CloseWindow(self.pray_win)
    end
end

function GuildModel:UpdatePrayPanelAttr(data)
    if self.pray_win ~= nil then
        self.pray_win:UpdatePrayPanelAttr(data)
    end
end

function GuildModel:PlayPraySuccessEffect(data)
    if self.pray_win ~= nil then
        self.pray_win:PlayPraySuccessEffect(data)
    end
end

function GuildModel:UpdateElementUpPrice(data)
    if self.pray_win ~= nil then
        self.pray_win:UpdateElementUpPrice(data)
    end
end


function GuildModel:OnSwitchPrayToggle()
    if self.pray_win ~= nil then
        self.pray_win:OnSwitchPrayToggle()
    end
end

function GuildModel:UpdateManagePanel()
    if self.pray_win ~= nil then
        self.pray_win:UpdateManagePanel()
    end
end


--打开公会建筑管理面板
function GuildModel:InitBuildUI(args)
    -- Connection.Instance:send(9900, {cmd = "增加公会资金 1000000000000"})

    if self.build_win == nil then
        self.build_win = GuildBuildWindow.New(self)
    end
    self.build_win:Open(args)
end

function GuildModel:CloseBuildUI()
    WindowManager.Instance:CloseWindow(self.build_win, true)
    if self.build_win == nil then
        -- print("===================self.build_win is nil")
    else
        -- print("===================self.build_win is not nil")
    end
end

--打开创建公会界面
function GuildModel:InitCreateUI()
    if self.create_win == nil then
        self.create_win= GuildCreateWindow.New(self)
        self.create_win:Open()
    end
end

--关闭创建公会界面
function GuildModel:CloseCreateUI()
    WindowManager.Instance:CloseWindow(self.create_win)
    if self.create_win == nil then
        -- print("===================self.create_win is nil")
    else
        -- print("===================self.create_win is not nil")
    end
end

--打开公会查找界面
function GuildModel:InitFindUI()
    if self.find_win == nil then
        self.find_win= GuildFindWindow.New(self)
        self.find_win:Open()
    end
end

--关闭公会查找界面
function GuildModel:CloseFindUI()
    WindowManager.Instance:CloseWindow(self.find_win)
    if self.find_win == nil then
        -- print("===================self.find_win is nil")
    else
        -- print("===================self.find_win is not nil")
    end
end

-- 打开更改公会成员签名
function GuildModel:InitChangeSignatureUI()
    if self.change_signature_win == nil then
        self.change_signature_win = GuildChangeSignatrueWindow.New(self)
        self.change_signature_win:Open()
    end
end

--关闭更改公会成员签名
function GuildModel:CloseChangeSignatureUI()
    WindowManager.Instance:CloseWindow(self.change_signature_win)
    if self.change_signature_win == nil then
        -- print("===================self.change_signature_win is nil")
    else
        -- print("===================self.change_signature_win is not nil")
    end
end

--打开公会宗旨更爱
function GuildModel:InitPurposeUI()
    if self.purpose_win == nil then
        self.purpose_win = GuildChangePurposeWindow.New(self)
        self.purpose_win:Open()
    end
end

--关闭公会宗旨
function GuildModel:ClosePurposeUI()
    WindowManager.Instance:CloseWindow(self.purpose_win)
    if self.purpose_win == nil then
        -- print("===================self.purpose_win is nil")
    else
        -- print("===================self.purpose_win is not nil")
    end
end

-- 更改职位窗口
function GuildModel:InitPositionUI()
    -- print("------------------222")
    if self.position_win == nil then
        self.position_win = GuildPositionWindow.New(self)
        self.position_win:Show()
    end
end

--关闭更改职位窗口
function GuildModel:ClosePositionUI()
    -- WindowManager.Instance:CloseWindow(self.position_win)
    if self.position_win ~= nil then
        self.position_win:DeleteMe()
        self.position_win = nil
    end
    if self.position_win == nil then
        -- print("===================self.position_win is nil")
    else
        -- print("===================self.position_win is not nil")
    end
end

--打开公会申请列表窗口
function GuildModel:InitApplyListUI()
    if self.apply_list_win == nil then
        self.apply_list_win = GuildApplyListWindow.New(self)
        self.apply_list_win:Open()
    end
end

--关闭公会申请列表窗口
function GuildModel:CloseApplyListUI()
    WindowManager.Instance:CloseWindow(self.apply_list_win)
    if self.apply_list_win == nil then
        -- print("===================self.apply_list_win is nil")
    else
        -- print("===================self.apply_list_win is not nil")
    end
end

--打开商店
function GuildModel:InitStoreUI(args)
    if ((self.my_guild_data or {}).GuildId or 0) == 0 then
        NoticeManager.Instance:FloatTipsByString(TI18N("当前你没加入公会，请加入公会再尝试"))
        return
    end
    if (args or {})[1] == 2 and RoleManager.Instance.RoleData.lev < 65 then
        args = nil
    end
    if self.store_win == nil then
        self.store_win = GuildStoreWindow.New(self)
    end
    self.store_win:Open(args)
end

--关闭商店
function GuildModel:CloseStoreUI()
    WindowManager.Instance:CloseWindow(self.store_win)
    if self.store_win == nil then
        -- print("===================self.store_win is nil")
    else
        -- print("===================self.store_win is not nil")
    end
end

--打开修改公会图腾的界面
function GuildModel:InitTotemUI()
    -- print("==========================进来了")
    print(self.totem_win)

    if self.totem_win == nil then
        self.totem_win = GuildTotemWindow.New(self)
        self.totem_win:Open()
    end
end

--关闭公会图腾界面
function GuildModel:CloseTotemUI()
    WindowManager.Instance:CloseWindow(self.totem_win)
    if self.totem_win == nil then
        -- print("===================self.totem_win is nil")
    else
        -- print("===================self.totem_win is not nil")
    end
end

--打开公会答题界面
function GuildModel:InitQuestionUI()
    if self.question_win == nil then
        self.question_win = GuildQuestionWindow.New(self)
        self.question_win:Open()
    end
end

--关闭公会答题界面
function GuildModel:CloseQuestionUI()
    WindowManager.Instance:CloseWindow(self.question_win)
    if self.question_win == nil then
        -- print("===================self.question_win is nil")
    else
        -- print("===================self.question_win is not nil")
    end
end


--打开公会自荐列表面板
function GuildModel:InitRecommendUI()
    if self.recommend_win == nil then
        self.recommend_win = GuildRecommendWindow.New(self)
        self.recommend_win:Open()
    end
end

--关闭公会自荐列表面板
function GuildModel:CloseRecommendUI()
    WindowManager.Instance:CloseWindow(self.recommend_win)
    if self.recommend_win == nil then
        -- print("===================self.recommend_win is nil")
    else
        -- print("===================self.recommend_win is not nil")
    end
end

--打开公会建筑加速面板面板
function GuildModel:InitBuildSpeedupUI(args)
    if self.build_speedup_win == nil then
        self.build_speedup_win = GuildBuildSpeedupWindow.New(self)
    end
    self.build_speedup_win:Show(args)
end

--关闭公会自荐列表面板
function GuildModel:CloseBuildSpeedupUI()
    if self.build_speedup_win ~= nil then
        self.build_speedup_win:DeleteMe()
        self.build_speedup_win = nil
    else
        -- print("===================self.build_speedup_win is not nil")
    end
end

-- 打开公会建筑额度选择面板
function GuildModel:InitBuildRestrictionSelectUI(index,curSelectItem)
    if self.build_restriction_select_win == nil then
        self.build_restriction_select_win = GuildBuildRestrictionSelectWindow.New(self,index,curSelectItem)
    end
    self.build_restriction_select_win:Show(index)
end

-- 关闭公会建筑额度选择面板
function GuildModel:CloseBuildRestrictionSelectUI()
    -- WindowManager.Instance:CloseWindow(self.build_restriction_select_win)
    if self.build_restriction_select_win ~= nil then
        self.build_restriction_select_win:DeleteMe()
        self.build_restriction_select_win = nil
    end
end


--打开公会周工资面板
function GuildModel:InitWeekRewardUI()
    if self.week_reward_panel == nil then
        self.week_reward_panel = GuildWeekRewardWindow.New(self)
        self.week_reward_panel:Show()
    end
end

--关闭公会自荐列表面板
function GuildModel:CloseWeekRewardUI()
    if self.week_reward_panel ~= nil then
        self.week_reward_panel:DeleteMe()
        self.week_reward_panel = nil
    else
        -- print("===================self.week_reward_panel is not nil")
    end
end

function GuildModel:OpenGetNewBuildWindow(args)
    if self.new_build_panel == nil then
        self.new_build_panel = GuildNewBuildView.New(self)
        self.new_build_panel.callback = function()
            self:CloseGetNewBuildWindow()
            self:InitPrayUI()
        end
    end
    self.new_build_panel:Show(args)
end

function GuildModel:CloseGetNewBuildWindow()
    if self.new_build_panel ~= nil then
        -- WindowManager.Instance:CloseWindow(self.new_build_panel)
        self.new_build_panel:DeleteMe()
        self.new_build_panel = nil
    end
end

function GuildModel:OpenApplyMsgWindow(args)
    if self.apply_msg_panel == nil then
        self.apply_msg_panel = GuildApplyMsgWindow.New(self)
    end
    self.apply_msg_panel:Show(args)
end

function GuildModel:CloseApplyMsgWindow()
    if self.apply_msg_panel ~= nil then
        -- WindowManager.Instance:CloseWindow(self.apply_msg_panel)
        self.apply_msg_panel:DeleteMe()
        self.apply_msg_panel = nil
    end
end


function GuildModel:OpenPrayConfirmWindow(args)
    if self.pray_confrim_panel == nil then
        self.pray_confrim_panel = GuildPrayConfirmWindow.New(self)
    end
    self.pray_confrim_panel:Show(args)
end

function GuildModel:ClosePrayConfirmWindow()
    if self.pray_confrim_panel ~= nil then
        self.pray_confrim_panel:DeleteMe()
        self.pray_confrim_panel = nil
    end
end

function GuildModel:UpdatePrayConfirmWindow(data)
    if self.pray_confrim_panel ~= nil then
        self.pray_confrim_panel:UpdateInfo(data)
    end
end


--打开公会改名面板
function GuildModel:InitChangeNameUI()
    if self.change_name_win == nil then
        self.change_name_win = GuildChangeNamePanel.New(self)
        self.change_name_win:Show()
    end
end

--关闭公会公会改名面你不
function GuildModel:CloseChangeNameUI()
    self.change_name_win:DeleteMe()
    self.change_name_win = nil
    if self.change_name_win == nil then
        -- print("===================self.change_name_win is nil")
    else
        -- print("===================self.change_name_win is not nil")
    end
end


--打开公会查看改名
function GuildModel:InitChangeNameLookUI()
    if self.look_change_name_win == nil then
        self.look_change_name_win = GuildLookNamePanel.New(self)
        self.look_change_name_win:Show()
    end
end

--关闭公会查看改名
function GuildModel:CloseChangeNameLookUI()
    self.look_change_name_win:DeleteMe()
    self.look_change_name_win = nil
    if self.look_change_name_win == nil then
        -- print("===================self.look_change_name_win is nil")
    else
        -- print("===================self.look_change_name_win is not nil")
    end
end


--打开公会新秀设置等级
function GuildModel:InitSetFreshManLevUI()
    if self.set_fresh_man_lev_win == nil then
        self.set_fresh_man_lev_win = GuildSetFreshManLevWindow.New(self)
        self.set_fresh_man_lev_win:Show()
    end
end

--关闭公会自荐列表面板
function GuildModel:CloseSetFreshManLevUI()
    self.set_fresh_man_lev_win:DeleteMe()
    self.set_fresh_man_lev_win = nil
    if self.set_fresh_man_lev_win == nil then
        -- print("===================self.set_fresh_man_lev_win is nil")
    else
        -- print("===================self.set_fresh_man_lev_win is not nil")
    end
end

--打开公会宝藏分配界面
function GuildModel:InitGiveGuildFightBoxUI()
    if self.guild_fight_givebox_panel == nil then
        self.guild_fight_givebox_panel = GuildfightGiveBoxPanel.New(self)
    end
    self.guild_fight_givebox_panel:Show()
end

--关闭公会宝藏分配界面
function GuildModel:CloseGiveGuildFightBoxUI()
    if self.guild_fight_givebox_panel ~= nil then
        self.guild_fight_givebox_panel:Hiden()
        self.guild_fight_givebox_panel:DeleteMe()
    end
    self.guild_fight_givebox_panel = nil
end

--打开公会宝藏分配界面
function GuildModel:InitGiveGuildLeagueBoxUI()
    if self.guild_league_givebox_panel == nil then
        self.guild_league_givebox_panel = GuildLeagueGiveBoxPanel.New(self)
    end
    self.guild_league_givebox_panel:Show()
end

--关闭公会宝藏分配界面
function GuildModel:CloseGiveGuildLeagueBoxUI()
    if self.guild_league_givebox_panel ~= nil then
        self.guild_league_givebox_panel:Hiden()
        self.guild_league_givebox_panel:DeleteMe()
    end
    self.guild_league_givebox_panel = nil
end

function GuildModel:ReSetGiveBoxSelectedMember()
    if self.guild_fight_givebox_panel ~= nil then
        self.guild_fight_givebox_panel:ReSetSelectedMember()
    end
end

--显示公会种花界面
function GuildModel:ShowGuildPlantFlowerPanel(data)
    if self.plant_flower_panel == nil then
        self.plant_flower_panel = GuildInvitewaterPanel.New(self)
    end
    self.plant_flower_panel:Open(data)
end
--隐藏公会种花界面
function GuildModel:HideGuildPlantFlowerPanel()
    self.plant_flower_panel:Hide()
end

function GuildModel:OnMapLoaded()
    EventMgr.Instance:RemoveListener(event_name.scene_load, self.sceneListener)
    local key = BaseUtils.get_unique_npcid(self.waterFlowerInfo.unitId, self.waterFlowerInfo.battleId)
    -- Log.Debug("公会种花，聊天寻路到npc="..key)
    SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
    SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
    SceneManager.Instance.sceneElementsModel:Self_MoveToTarget(key)
end

function GuildModel:UnitListUpdate()
    EventMgr.Instance:RemoveListener(event_name.npc_list_update, self.sceneListener1)
    local key = BaseUtils.get_unique_npcid(self.waterFlowerInfo.unitId, self.waterFlowerInfo.battleId)
    -- Log.Debug("公会种花，聊天寻路到npc="..key)
    SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
    SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
    SceneManager.Instance.sceneElementsModel:Self_MoveToTarget(key)
end
function GuildModel:GoToGuildAreaForWaterFlower(data)
    self.waterFlowerInfo = data
    if SceneManager.Instance:CurrentMapId() == 30001 then
        local key = BaseUtils.get_unique_npcid(self.waterFlowerInfo.unitId, self.waterFlowerInfo.battleId)
        -- Log.Debug("公会种花，聊天寻路到npc="..key)
        SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
        SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
        SceneManager.Instance.sceneElementsModel:Self_MoveToTarget(key)
    else
        EventMgr.Instance:AddListener(event_name.scene_load, self.sceneListener)
        EventMgr.Instance:AddListener(event_name.npc_list_update, self.sceneListener1)
        QuestManager.Instance:Send(11128, {})
    end
end

--打开公会红包面板
function GuildModel:InitRedBagUI()
    if self.red_bag_win == nil then
        self.red_bag_win = GuildRedBagWindow.New(self)
        self.red_bag_win:Show()
    end
end

--关闭公会红包面板
function GuildModel:CloseRedBagUI()
    if self.red_bag_win ~= nil then
        self.red_bag_win:DeleteMe()
        self.red_bag_win = nil
    end
end

--打开公会红包打开面板
function GuildModel:InitUnRedBagUI()
    if self.red_bag_unopen_win == nil then
        self.red_bag_unopen_win = GuildRedBagUnOpenWindow.New(self)
        self.red_bag_unopen_win:Show()
    end
end

--关闭公会红包打开面板
function GuildModel:CloseUnRedBagUI()
    if self.red_bag_unopen_win ~= nil then
        self.red_bag_unopen_win:DeleteMe()
        self.red_bag_unopen_win = nil
    end
end

--打开公会红包设置面板
function GuildModel:InitRedBagSetUI()
    if self.red_bag_set_win == nil then
        self.red_bag_set_win = GuildRedBagSetWindow.New(self)
        self.red_bag_set_win:Show()
    end
end

--关闭公会红包设置面板
function GuildModel:CloseRedBagSetUI()
    if self.red_bag_set_win ~= nil then
        self.red_bag_set_win:DeleteMe()
        self.red_bag_set_win = nil
    end
end


--打开公会红包设置选钱面板
function GuildModel:InitRedBagMoneyUI()
    if self.red_bag_money_win == nil then
        self.red_bag_money_win = GuildRedBagMoneyWindow.New(self)
        self.red_bag_money_win:Show()
    end
end

--关闭公会红包设置选钱面板
function GuildModel:CloseRedBagMoneyUI()
    if self.red_bag_money_win ~= nil then
        self.red_bag_money_win:DeleteMe()
        self.red_bag_money_win = nil
    end
end

--打开公会成员管理面板
function GuildModel:InitGuildMemManageUI()
    if self.mem_manage_win == nil then
        self.mem_manage_win = GuildMemManageWindow.New(self)
    end
    self.mem_manage_win:Open()
end

--关闭公会成员管理面板
function GuildModel:CloseGuildMemManageUI()
    WindowManager.Instance:CloseWindow(self.mem_manage_win)
    if self.mem_manage_win == nil then
        -- print("===================self.mem_manage_win is nil")
    else
        -- print("===================self.mem_manage_win is not nil")
    end
end

--打开公会合并面板
function GuildModel:InitGuildMergeUI()
    if self.merge_win == nil then
        self.merge_win = GuildMergeWindow.New(self)
        self.merge_win:Open()
    end
end

--关闭公会合并面板
function GuildModel:CloseGuildMergeUI()
    if self.merge_win ~= nil then
        WindowManager.Instance:CloseWindow(self.merge_win)
    end
    if self.merge_win == nil then
        -- print("===================self.merge_win is nil")
    else
        -- print("===================self.merge_win is not nil")
    end
end

--打开公会健康度面板
function GuildModel:InitGuildHealthyUI()
    if self.healthy_win == nil then
        self.healthy_win = GuildHealthyWindow.New(self)
        self.healthy_win:Open()
    end
end

--关闭公会健康度面板
function GuildModel:CloseGuildHealthyUI()
    WindowManager.Instance:CloseWindow(self.healthy_win)
    if self.healthy_win == nil then
        -- print("===================self.healthy_win is nil")
    else
        -- print("===================self.healthy_win is not nil")
    end
end

--打开公会合并tips面板
function GuildModel:InitGuildMergeTipsUI()
    if self.merge_tips_win == nil then
        self.merge_tips_win = GuildMergeTipsWindow.New(self)
        self.merge_tips_win:Show()
    end
end

--关闭公会健康度面板
function GuildModel:CloseGuildMergeTipsUI()
    self.merge_tips_win:DeleteMe()
    self.merge_tips_win = nil
    if self.merge_tips_win == nil then
        -- print("===================self.merge_tips_win is nil")
    else
        -- print("===================self.merge_tips_win is not nil")
    end
end

--打开公会npc兑换面板
function GuildModel:InitGuildNpcExchangeUI()
    print("我进入了公会兑换贡献面板")
    if self.npc_exchange_win == nil then
        self.npc_exchange_win = GuildNpcExchangeWindow.New(self)
    end
    self.npc_exchange_win:Show()
end

--打开公会npc资金兑换面板
function GuildModel:InitGuildNpcFundExchangeUI()
    if self.npc_exchange_fund_win == nil then
        self.npc_exchange_fund_win = GuildNpcExchangeFundWindow.New(self)
    end
    self.npc_exchange_fund_win:Show()
end

--关闭公会npc兑换面板
function GuildModel:CloseGuildNpcExchangeUI()
    if self.npc_exchange_win ~= nil then
        self.npc_exchange_win:DeleteMe()
        self.npc_exchange_win = nil
    end
end

function GuildModel:CloaseGuildNpcFundExchangeUI()
    if self.npc_exchange_fund_win ~= nil then
        self.npc_exchange_fund_win:DeleteMe()
        self.npc_exchange_fund_win = nil
    end
end


--打开公会成员开除面板
function GuildModel:InitMemDeleteUI(_data)
    self.mem_delete_data = _data
    if self.mem_delete_win == nil then
        self.mem_delete_win = GuildMemDeleteWindow.New(self)
        self.mem_delete_win:Show()
    end
end

--关闭公会成员开除
function GuildModel:CloseMemDeleteUI()
    self.mem_delete_win:DeleteMe()
    self.mem_delete_win = nil
    if self.mem_delete_win == nil then
        -- print("===================self.mem_delete_win is nil")
    else
        -- print("===================self.mem_delete_win is not nil")
    end
end

----------------------------各种界面更新逻辑
--公会查找界面更新mo
function GuildModel:find_win_update_view()
    if self.find_win ~= nil then
        self.find_win:update_view()
    end
end

--公会查找界面显示条目
function GuildModel:find_win_display_items(templist)
    if self.find_win ~= nil then
        self.find_win:display_search_result_list(templist)
    end
end

--公会建筑管理面板更新
function GuildModel:build_win_update()
    if self.build_win ~= nil then
        self.build_win:update_view()
    end
end

--公会建筑加速面板更新
function GuildModel:build_speedupwin_update()
    if self.build_speedup_win ~= nil then
        self.build_speedup_win:update_info()
    end
end

--更行公会申请列表面板
function GuildModel:update_apply_list()
    if self.apply_list_win ~= nil then
        self.apply_list_win:update_apply_list()
    end
end

--更新商店面板右边
function GuildModel:update_store_right()
    -- if self.store_win ~= nil then
    --     self.store_win:update_right()
    -- end
    self.onUpdateStore:Fire()
end

--更新商店面板主内容，用于商店协议返回
function GuildModel:update_store_view()
    self.onUpdateStore:Fire()
    -- if self.store_win ~= nil then
    --     self.store_win:update_view()
    -- end
end

----公会答题面板内容更新
function GuildModel:update_question_win_11147(data)
    if self.question_win ~= nil then
        self.question_win:on_socket_11147_back(data)
    end
end

function GuildModel:update_question_win_11148(data)
    if self.question_win ~= nil then
        self.question_win:on_socket_11148_back(data)
    end
end

function GuildModel:update_question_win_11150(data)
    if self.question_win ~= nil then
        self.question_win:on_socket_11150_back(data)
    end
end

function GuildModel:update_question_win_11151(data)
    if self.question_win ~= nil then
        self.question_win:on_socket_11151_back(data)
    end
end

function GuildModel:update_question_win_11152(data)
    if self.question_win ~= nil then
        self.question_win:on_socket_11152_back(data)
    end
end

function GuildModel:update_question_win_11154(data)
    if self.question_win ~= nil then
        self.question_win:on_socket_11154_back(data)
    end
end


--更新会长自荐列表面板
function GuildModel:update_recommend_list(list)
    if self.recommend_win ~= nil then
        self.recommend_win:update_recommend_list(list)
    end
end

--更新发送红包界面
function GuildModel:update_red_bag_set_win(_type)
    if self.red_bag_set_win ~= nil then
        self.red_bag_set_win:update_send_info(_type)
    end
end

---更新新秀转正等级设置界面
function GuildModel:update_fresh_man_win()
    if self.set_fresh_man_lev_win ~= nil then
        self.set_fresh_man_lev_win:update_info()
    end
end

--------------------------子界面更新逻辑
--更新tab红点状态
function GuildModel:update_tab_red_point(index)
    if self.main_win ~= nil then
        self.main_win:Set_red_point_state(index)
    end
end

--公会信息panel更新
function GuildModel:update_left_guild_info()
    if self.main_win ~= nil and self.main_win.subFirst ~= nil then
        self.main_win.subFirst:update_left_guild_info()
    end
end

function GuildModel:update_info_apply_list()
    if self.main_win ~= nil and self.main_win.subFirst ~= nil then
        self.main_win.subFirst:update_info_apply_list()
    end
end

function GuildModel:update_left_gonghui_mem()
    if self.main_win ~= nil and self.main_win.subFirst ~= nil then
        self.main_win.subFirst:update_left_gonghui_mem()
    end
end

function GuildModel:update_info_mem_model(looks)
    if self.main_win ~= nil and self.main_win.subFirst ~= nil then
        self.main_win.subFirst:update_info_mem_model(looks)
    end
end

function GuildModel:update_ToTem_icon(totem)
    if self.main_win ~= nil and self.main_win.subFirst ~= nil then
        self.main_win.subFirst:update_ToTem_icon(totem)
    end
end

function GuildModel:update_left_guild_info()
    if self.main_win ~= nil and self.main_win.subFirst ~= nil then
        self.main_win.subFirst:update_left_guild_info()
    end
end

function GuildModel:update_member_list()
    if self.main_win ~= nil and self.main_win.subFirst ~= nil then
        self.main_win.subFirst:update_member_list()
    end
end

function GuildModel:update_info_pray()
    if self.main_win ~= nil and self.main_win.subFirst ~= nil then
        self.main_win.subFirst:update_info_pray()
    end
end

function GuildModel:update_totem_btn()
    if self.main_win ~= nil and self.main_win.subFirst ~= nil then
        self.main_win.subFirst:update_totem_btn()
    end
end

function GuildModel:update_one_member(d)
    if self.main_win ~= nil and self.main_win.subFirst ~= nil then
        self.main_win.subFirst:update_one_member(d)
    end
end

function GuildModel:delete_fire_member(d)
    self.has_do_last_delete = true
    if self.main_win ~= nil and self.main_win.subFirst ~= nil then
        -- self.main_win.subFirst:delete_fire_member(d)
        self.main_win.subFirst:update_member_list()
    end
    if self.mem_manage_win ~= nil then
        self.mem_manage_win:update_mem_list()
    end
end

function GuildModel:update_left_guild_info()
    if self.main_win ~= nil and self.main_win.subFirst ~= nil then
        self.main_win.subFirst:update_left_guild_info()
    end
end

function GuildModel:update_welfare_pay_item()
    if self.main_win ~= nil and self.main_win.subSecond ~= nil then
        self.main_win.subSecond:update_welfare_pay_item()
    end
end

function GuildModel:update_welfare_left_exchange()
    if self.main_win ~= nil and self.main_win.subSecond ~= nil then
        self.main_win.subSecond:update_left_num()
    end
end

--更新公会信息面板里面的左边公会成员信息
function GuildModel:update_guild_signature(_signature)
    if self.main_win ~= nil and self.main_win.subFirst ~= nil then
        self.main_win.subFirst:update_guild_signature(_signature)
    end
end

--更新公会图腾次数
function GuildModel:update_totem_change_time()
    if self.totem_win ~= nil then
        self.totem_win:update_change_time()
    end
end

--更新公会合并界面列表
function GuildModel:update_merge_win_list(_list)
    if self.merge_win ~= nil then
        self.merge_win:display_items(_list, 1)
    end
end


--
function GuildModel:update_left_exchange_num()
    if self.npc_exchange_win ~= nil then
        self.npc_exchange_win:update_left_num()
    end
end

--更新健康度
function GuildModel:update_healthy_win()
    if self.healthy_win ~= nil then
        self.healthy_win:update_guild_healthy()
    end
end

--更新健康度
function GuildModel:update_merge_tips_win()
    if self.merge_tips_win ~= nil then
        self.merge_tips_win:update_guild_healthy()
    end
end

------------------------------对frozenbutton的click和release调用
--商店兑换按钮frozen
function GuildModel:Frozen_store_exchange()
    if self.store_win ~= nil then
        if self.store_win.restoreFrozen_exchange ~= nil then
            self.store_win.restoreFrozen_exchange:OnClick()
        end
    end
end

function GuildModel:Release_store_exchange()
    if self.store_win ~= nil then
        if self.store_win.restoreFrozen_exchange ~= nil then
            self.store_win.restoreFrozen_exchange:Release()
        end
    end
end

--建筑加速按钮frozen
function GuildModel:Frozen_build_speed()
    if self.build_speedup_win ~= nil then
        if self.build_speedup_win.restoreFrozen_btn1 ~= nil then
            self.build_speedup_win.restoreFrozen_btn1:OnClick()
        end
        if self.build_speedup_win.restoreFrozen_btn2 ~= nil then
            self.build_speedup_win.restoreFrozen_btn2:OnClick()
        end
        if self.build_speedup_win.restoreFrozen_btn3 ~= nil then
            self.build_speedup_win.restoreFrozen_btn3:OnClick()
        end
    end
end

function GuildModel:Release_build_speed()
    if self.build_speedup_win ~= nil then
        if self.build_speedup_win.restoreFrozen_btn1 ~= nil then
            self.build_speedup_win.restoreFrozen_btn1:Release()
        end
        if self.build_speedup_win.restoreFrozen_btn2 ~= nil then
            self.build_speedup_win.restoreFrozen_btn2:Release()
        end
        if self.build_speedup_win.restoreFrozen_btn3 ~= nil then
            self.build_speedup_win.restoreFrozen_btn3:Release()
        end
    end
end



---------------------各种get 各种check 各种has 数据列表遍历和数学计算逻辑

--根据公会健康度获取对应健康名字
function GuildModel:get_guild_healthy_name()
    if self.my_guild_data.Health >= 81 and self.my_guild_data.Health <= 100 then
        return string.format("<color='#ffa500'>%s(%s)</color>", TI18N("兴旺昌盛"), self.my_guild_data.Health)
    end
    if self.my_guild_data.Health >= 61 and self.my_guild_data.Health <= 80 then
        return string.format("<color='#ffa500'>%s(%s)</color>", TI18N("生机盎然"), self.my_guild_data.Health)
    end
    if self.my_guild_data.Health >= 40 and self.my_guild_data.Health <= 60 then
        return string.format("<color='#01c0ff'>%s(%s)</color>", TI18N("中规中矩"), self.my_guild_data.Health)
    end
    if self.my_guild_data.Health >= 21 and self.my_guild_data.Health <= 39 then
        return string.format("<color='#2fc823'>%s(%s)</color>", TI18N("危在旦夕"), self.my_guild_data.Health)
    end
    if self.my_guild_data.Health < 21 then
        return string.format("<color='#df3435'>%s(%s)</color>", TI18N("独木难支"), self.my_guild_data.Health)
    end
end

--根据公会健康度获取描述
function GuildModel:get_guild_healthy_desc()
    if self.my_guild_data.Health >= 81 and self.my_guild_data.Health <= 100 then
        return TI18N("我们公会的成员非常活跃，非常强大！")
    end
    if self.my_guild_data.Health >= 61 and self.my_guild_data.Health <= 80 then
        return TI18N("当前公会健康度很高，可接受其他公会合并申请")
    end
    if self.my_guild_data.Health >= 40 and self.my_guild_data.Health <= 60 then
        return TI18N("当前公会健康度不佳，建议申请合入其他公会")
    end
    if self.my_guild_data.Health >= 21 and self.my_guild_data.Health <= 39 then
        return TI18N("当前公会健康度危险，随时可能被合并")
    end
    if self.my_guild_data.Health < 21 then
        return TI18N("当前公会已经难以支撑，可能会被系统强制合并")
    end
end

--传入公会建筑等级，获取配置数据
function GuildModel:get_guild_gb_data(lev)
    for i=1,#DataGuild.data_get_guild_up_data do
        local gbd = DataGuild.data_get_guild_up_data[i]
        if gbd.lev==lev then
            return gbd
        end
    end
    return nil
end

--传入城堡建筑等级，获取配置数据
function GuildModel:get_hotel_gb_data(lev)
    for i=1,#DataGuild.data_get_hotel_up_data do
        local gbd = DataGuild.data_get_hotel_up_data[i]
        if gbd.lev==lev then
            return gbd
        end
    end
    return nil
end


--传入研究院等级，获取配置数据
function GuildModel:get_research_gb_data(lev)
    for i=1,#DataGuild.data_get_research_up_data do
        local gbd = DataGuild.data_get_research_up_data[i]
        if gbd.lev==lev then
            return gbd
        end
    end
    return nil
end

--传入铸造工坊等级，获取配置数据
function GuildModel:get_forge_gb_data(lev)
    for i=1,#DataGuild.data_get_forge_up_data do
        local gbd = DataGuild.data_get_forge_up_data[i]
        if gbd.lev==lev then
            return gbd
        end
    end
    return nil
end

--传入商店等级，获取配置数据
function GuildModel:get_store_gb_data(lev)
    for i=1,#DataGuild.data_get_store_up_data do
        local gbd = DataGuild.data_get_store_up_data[i]
        if gbd.lev==lev then
            return gbd
        end
    end
    return nil
end

local get_effect_data_help = function(dic,key)
    local val = nil
    if dic == nil then
        return val
    end
    for k,v in pairs(dic) do
        if k == key then
            val = v
            break
        end
    end
    return val
end

function GuildModel:get_he_data(lev)
    return get_effect_data_help(DataGuild.data_get_hotel_effect_data,lev)
end

function GuildModel:get_se_data(lev)
    return get_effect_data_help(DataGuild.data_get_store_effect_data,lev)
end

function GuildModel:get_re_data(lev)
    return get_effect_data_help(DataGuild.data_get_research_effect_data,lev)
end

function GuildModel:get_fe_data(lev)
    return get_effect_data_help(DataGuild.data_get_forge_effect_data,lev)
end

--根据传入的公会名字查找公会
function GuildModel:search_guild_by_name(guildName)
    local temp = {}
    for i=1,#self.guild_list do
        local d = self.guild_list[i]
        if string.find(d.Name,guildName) ~= nil then
            table.insert(temp, d)
        end
    end
    return temp
end

--查找我在帮派中的职位，如果返回100，则说明找不到
function GuildModel:get_my_guild_post()
    if self.my_guild_data.MyPost == nil then
        return 0
    end
    return self.my_guild_data.MyPost
end

function GuildModel:check_me_is_leader()
    if self.my_guild_data.LeaderRid==RoleManager.Instance.RoleData.id and self.my_guild_data.LeaderZoneId==RoleManager.Instance.RoleData.zone_id and self.my_guild_data.LeaderPlatform==RoleManager.Instance.RoleData.platform then
        return true
    end
    return false
end

function GuildModel:check_has_join_guild()
    if self.my_guild_data ~= nil and self.my_guild_data.GuildId ~= 0 then
        return true
    end
    return false
end

--根据传入的信息获取公会成员信息
function GuildModel:get_guild_member_by_id(rid,platForm,zoneId)
    if self.guild_member_list == nil or #self.guild_member_list == 0 then
        return nil
    end
    for i=1,#self.guild_member_list do
        local d = self.guild_member_list[i]
        if d.Rid == rid and d.PlatForm == platForm and d.ZoneId == zoneId then
            return d
        end
    end
    return nil
end

--传入职位类型，获取当前帮派中该职位已经有多少人
function GuildModel:get_post_num(pos)
    local num = 0
    for i=1,#self.guild_member_list do
        local d = self.guild_member_list[i]
        if d.Post==pos then
            num =num + 1
        end
    end

    return num
end

--一键申请加入
function GuildModel:one_key_apply_all_guild()
    for i=1,#self.guild_list do
        local d = self.guild_list[i]
        d.hasApply = true
        -- GuildManager.Instance:request11104(d.GuildId,d.PlatForm,d.ZoneId)
    end
    GuildManager.Instance:request11161()
    if self.find_win ~= nil then
        self.find_win:RefreshAllItemsData()
    end
end

--获取金库强化成功率
function GuildModel:get_my_vault_enchant_rate()
    if self.my_guild_data == nil or self.my_guild_data.GuildId == 0 then --没有公会
        return 0
    end

    return DataGuild.data_get_research_up_data[self.my_guild_data.academy_lev].enchant_rate/10
end

--获取我加入公会的时间
function GuildModel:get_my_join_guild_time()
    if self.guild_member_list == nil then
        return 0
    end
    for i=1,#self.guild_member_list do
        local data = self.guild_member_list[i]
        if RoleManager.Instance.RoleData.id == data.Rid and RoleManager.Instance.RoleData.zone_id == data.ZoneId and RoleManager.Instance.RoleData.platform == data.PlatForm then
            return data.EnterTime
        end
    end
    return 0
end



--获取我的公会成员信息
function GuildModel:get_mine_member_data()
    for i=1, #self.guild_member_list do
        local mem = self.guild_member_list[i]
        if RoleManager.Instance.RoleData.id == mem.Rid and RoleManager.Instance.RoleData.zone_id == mem.ZoneId and RoleManager.Instance.RoleData.platform == mem.PlatForm then
            return mem
        end
    end
    return nil
end

-- 检查是否有公会
function GuildModel:has_guild()
    if self.my_guild_data ~= nil and self.my_guild_data.GuildId ~= 0 then
        return true
    end
    return false
end


--从公会商店配置中读取对应的数据
function GuildModel:get_store_next_cfg_list()
    local cur_list = DataGuild.data_get_store_effect_data[self.my_guild_data.store_lev].id_list
    if DataGuild.data_get_store_effect_data[self.my_guild_data.store_lev+1] == nil then
        return {}
    end
    local next_list = DataGuild.data_get_store_effect_data[self.my_guild_data.store_lev+1].id_list
    local result_list = {}
    for i=1, #next_list do
        local next_dat = next_list[i]
        local has = false
        for j=1,#cur_list do
            local cur_dat = cur_list[j]
            if cur_dat.id == next_dat.id then
                has = true
                break
            end
        end
        if has == false then
            table.insert(result_list, next_dat)
        end
    end

    return result_list
end

--判断下当前是否有建筑在等级加速升级
function GuildModel:check_has_build_lev_up()
    if self.my_guild_data.lev_time > 0 or self.my_guild_data.academy_time > 0 or self.my_guild_data.exchequer_time > 0 or self.my_guild_data.store_time > 0 then
        return true
    end
    return false
end

--判断下是否可以领取分红
function GuildModel:check_can_get_pay()
    if self.pay_data == nil then
        return false
    end
     if self.pay_data.daily == 1 then
        local time_gap = BaseUtils.BASE_TIME - self:get_my_join_guild_time()
        if time_gap >= 172800 then
            local currentWeek = tonumber(os.date("%w", BaseUtils.BASE_TIME))
            if currentWeek == 0 then
                currentWeek = 7
            end
            if currentWeek == 7 then
                return false
            else
                return true
            end
        else
            return false
        end
    else
        return false
    end
    return false
end

--传入公会祈祷协议数据，组装返回属性列表
function GuildModel:GetPrayList(data)
    local roleCurList = {}
    local roleNewList = {}
    local petCurList = {}
    local petNewList = {}
    for k, v in pairs(data.element_attr) do
        if v.effect_obj == 1 then
            for k1, v1 in pairs(v.attr) do
                table.insert(roleCurList, v1)
            end
            for k1, v1 in pairs(v.high_attr) do
                table.insert(roleCurList, v1)
            end
            for k1, v1 in pairs(v.add_skill_list) do
                table.insert(roleCurList, v1)
            end
        elseif v.effect_obj == 2 then
            for k1, v1 in pairs(v.attr) do
                table.insert(petCurList, v1)
            end
            for k1, v1 in pairs(v.high_attr) do
                table.insert(petCurList, v1)
            end
            for k1, v1 in pairs(v.add_skill_list) do
                table.insert(petCurList, v1)
            end
        end
    end
    for k, v in pairs(data.tmp_element_attr) do
        if v.effect_obj == 1 then
            for k1, v1 in pairs(v.attr) do
                table.insert(roleNewList, v1)
            end
            for k1, v1 in pairs(v.high_attr) do
                table.insert(roleNewList, v1)
            end
            for k1, v1 in pairs(v.add_skill_list) do
                table.insert(roleNewList, v1)
            end
        elseif v.effect_obj == 2 then
            for k1, v1 in pairs(v.attr) do
                table.insert(petNewList, v1)
            end
            for k1, v1 in pairs(v.high_attr) do
                table.insert(petNewList, v1)
            end
            for k1, v1 in pairs(v.add_skill_list) do
                table.insert(petNewList, v1)
            end
        end
    end
    return roleCurList ,roleNewList ,petCurList ,petNewList
    end


--过滤掉成员列表里面deleted状态的成员
function GuildModel:filter_deleted_mem()
    self.has_do_last_delete = false
    local new_list = {}
    for i=1,#self.guild_member_list do
        local data = self.guild_member_list[i]
        if data.deleted ~= true then
            table.insert(new_list, data)
        end
    end
    self.guild_member_list = new_list
end

--检查是否有祈福元素至少一个元素升至50级
function GuildModel:CheckPrayElementLev()
    if self:has_guild() then
        local openPet = false
        for i = 1, #self.my_guild_data.element_info do
            if self.my_guild_data.element_info[i].lev >= 20 then
                openPet = true
                break
            end
        end
        return openPet
    else
        return false
    end
end

function GuildModel:TposeSpecail(npcView, transform)
    --判断一下是否是祭坛
    if npcView.baseData ~= nil and (npcView.baseData.id == 20102 or npcView.baseData.id == 20101) then
        SceneManager.Instance.sceneElementsModel.selected_effect_special_mark = true
        transform.localPosition = Vector3(0, 0.4, 20)
        transform.localScale = Vector3(4.5, 4.5, 4.5)
    end
end

function GuildModel:InitLang()
    self.guild_lang = {
        GUILD_INFO_TAN_HAO_WORD_1 = TI18N("等级≤35级的角色加入公会自动成为【公会新秀】"),
        GUILD_INFO_TAN_HAO_WORD_2 = TI18N("1.【公会新秀】可以和正常成员一样享用公会频道，完成公会任务，参与部分公会活动") ,
        GUILD_INFO_TAN_HAO_WORD_3 = TI18N("2.【公会新秀】不能获得公会福利") ,
        GUILD_INFO_TAN_HAO_WORD_4 = TI18N("3.离线时间＞48小时自动踢除公会") ,
        GUILD_INFO_TAN_HAO_WORD_5 = TI18N("4.等级＞35级自动转为正式成员") ,
        GUILD_INFO_TAN_HAO_WORD_6 = TI18N("5.会长可直接设置相应角色转为正式成员") ,


        GUILD_INFO_NOTIFY_WORD_1 = TI18N("请选择要操作的公会成员"),
        GUILD_INFO_NOTIFY_WORD_2 = TI18N("不能更改自己的职位") ,
        GUILD_INFO_NOTIFY_WORD_3 = TI18N("你没有足够权限设置该成员的职位") ,
        GUILD_INFO_NOTIFY_WORD_4 = TI18N("没有权限设置职位") ,


        GUILD_INFO_OUT_NOTIFY_1 = TI18N("是否要解散公会？") ,
        GUILD_INFO_OUT_NOTIFY_2 = TI18N("是否要退出公会？") ,
        GUILD_INFO_OUT_NOTIFY_3 = TI18N("是否要踢除%s"),
        GUILD_INFO_OUT_NOTIFY_4 = TI18N("只有长老以上才能执行此操作"),

        GUILD_INFO_CHANGE_PURPOSE_NOTIFY = TI18N("你不是会长，没有权限更改公会宗旨"),
        --公会建筑名字
        GUILD_BUILD_NAME_0 = TI18N("公会"),
        GUILD_BUILD_NAME_1 = TI18N("公会民房"),
        GUILD_BUILD_NAME_2 = TI18N("公会神兽"),
        GUILD_BUILD_NAME_3 = TI18N("公会佣兵"),
        GUILD_BUILD_NAME_4 = TI18N("商店"),
        GUILD_BUILD_NAME_5 = TI18N("福利领取"),
        GUILD_BUILD_NAME_6 = TI18N("公会分红"),
        GUILD_BUILD_LEV = TI18N("级"),


        --公会建筑未开启
        GUILD_BUILD_UNOPEN_0 = TI18N("·开启公会城堡可扩充公会人数上限\n·同时可以提高公会福利奖励以及增加名额上限\n·公会城堡达到1级开启该建筑"),
        GUILD_BUILD_UNOPEN_1 = TI18N("·开启研究院可<color='#00ff00'>获得属性加成</color>\n·同时可额外<color='#00ff00'>提高公会任务奖励</color>\n   ·公会城堡达到<color='#00ff00'>2级</color>自动开启该建筑"),
        GUILD_BUILD_UNOPEN_2 = TI18N("·开启铸造工坊可提高锻造<color='#00ff00'>强化成功率</color>\n·同时可增加<color='#00ff00'>公会资金上限</color>\n ·公会城堡达到<color='#00ff00'>3级</color>自动开启该建筑"),
        GUILD_BUILD_UNOPEN_3 = TI18N("·开启商店可购买<color='#00ff00'>珍稀物品</color>\n·提高商店等级可增加<color='#00ff00'>物品数量</color>\n  ·公会城堡达到<color='#00ff00'>4级</color>自动开启该建筑"),

        --公会建筑未开启开启条件
        GUILD_RESEARCH_OPEN_CONDITION = TI18N("公会城堡达到2级自动开启"),
        GUILD_FORGE_OPEN_CONDITION = TI18N("公会城堡达到3级自动开启"),
        GUILD_STORE_OPEN_CONDITION = TI18N("公会达到5级自动开启"),

        GUILD_NOT_JOIN_Notice = TI18N("你尚未加入任何公会"),
        GUILD_BUILD_HAS_FINISH_upGRADE = TI18N("该建筑升级已完成"),

        GUILD_BUILD_UNOPEN_TIPS_DESC = TI18N("未开启"),



        --公会福利领取面板
        GUILD_WEL_FARE_LEFT_0 = TI18N("经验：<color='#8DE92A'>%s</color>\n金币：<color='#8DE92A'>%s</color>"),
        GUILD_WEL_FARE_LEFT_1 = TI18N("本周公会分红已领取"),
        GUILD_WEL_FARE_LEFT_2 = TI18N("今日公会分红已领取"),




        --公会信息面板福利选项卡
        GUILD_RESEARCH_EFFECT_STR = TI18N("建筑等级已提升至<color='#ACE92A'>%s级</color>，公会任务奖励加成<color='#ACE92A'>%s</color>"),
        GUILD_STORE_EFFECT_STR = TI18N("可在商店消耗贡献兑换道具，下一批道具刷新时间剩余"),
        GUILD_FORGE_EFFECT_STR = TI18N("建筑等级已提升至<color='#ACE92A'>%s级</color>，装备强化成功率提升<color='#ACE92A'>%s</color>"),
        GUILD_HOTEL_EFFECT_STR = TI18N("你本周的福利尚未领取，公会福利每周可领取一次"),
        GUILD_WELFARE_TIME_PREFIX = TI18N("每天刷新道具时间：9点 12点 15点 18点 20点"),

        --你本周的分红为xxxx，每周日晚发放分红
        GUILD_PAY_EFFECT_STR_0 = TI18N("你本周的分红为xxxx，每周日晚发放分红"),
        GUILD_RESEARCH_EFFECT_STR_0 = TI18N("每天喂养神兽可进化，同时可获得个人贡献"),
        GUILD_STORE_EFFECT_STR_0 = TI18N("公会达到<color='#ACE92A'>5级</color>自动开启商店建筑，可在商店中<color='#ACE92A'>兑换珍稀道具</color>"),
        GUIlD_STORE_EFFECT_STR_TIPS_0 = TI18N("公会达到5级才可开启商店建筑"),
        GUILD_FORGE_EFFECT_STR_0 = TI18N("将守护派至佣兵营地可获得银币奖励"),
        GUILD_HOTEL_EFFECT_STR_0 = TI18N("城堡建筑达到1级可领取公会福利，奖励丰厚"),
        GUILD_PAY_EFFECT_STR_TIPS = TI18N("每天完成公会任务以及参与公会活动可提高分红"),

        --公会信息面板福利选项卡,打开按钮
        GUILD_RESEARCH_BTN_STR=TI18N("任务"),
        GUILD_STORE_BTN_STR=TI18N("兑换"),
        GUILD_FORGE_BTN_STR=TI18N("打开"),
        GUILD_HOTEL_BTN_STR=TI18N("领取"),

        --商店
        GUILD_STORE_ITEM_LIMIT = TI18N("限购：<color='#ACE92A'>%s</color>个"),
        GUILD_STORE_ITEM_LIMIT_1 = TI18N("<color='#ff0000'>购买达到上限</color>"),
        GUILD_STORE_CUR_LEV = TI18N("商店等级：<color='#ACE92A'>%s级</color>"),
        GUILD_STORE_EXCHANGE_UNSELECT_NOTICE = TI18N("请选择要兑换的物品"),


        --祈祷界面tips
        GUILD_PRAY_ITEM3_TIP1 = TI18N("<color='#ffff00'>神恩</color>\n在公会频道发放公会贡献红包"),

        --神兽面板叹号tips描述
        GUILD_SHENSHOU_PANEL_TANHAO_TIPS1 = TI18N("1.神兽分为10个等阶，经验值满可升阶"),
        GUILD_SHENSHOU_PANEL_TANHAO_TIPS2 = TI18N("2.公会温泉开启时会长可召唤神兽"),
        GUILD_SHENSHOU_PANEL_TANHAO_TIPS3 = TI18N("3.击败神兽与随从珍兽可获得奖励"),
        GUILD_SHENSHOU_PANEL_TANHAO_TIPS4 = TI18N("4.会长可给神兽进行更改名字，每周可更改1次"),
    }
end
