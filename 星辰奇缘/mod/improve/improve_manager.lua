ImproveManager = ImproveManager or BaseClass(BaseManager)

local PlayerPrefs = UnityEngine.PlayerPrefs

function ImproveManager:__init()
    if ImproveManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
        return
    end
    ImproveManager.Instance = self
    self.roleinfo = RoleManager.Instance.RoleData
    self.model = ImproveModel.New()
    self.lastList = {}
    self:InitHandler()
    self.red = nil
    self.gloryfirst = true
    self.firstCheck = true
    self.curChild = nil
    -- PlayerPrefs.GetString("last_account")
    -- PlayerPrefs.SetString("last_account", self.input_field.text)
    -- PlayerPrefs.DeleteAll()
end

function ImproveManager:InitList()

end

function ImproveManager:InitHandler()
    EventMgr.Instance:AddListener(event_name.mainui_btn_init, function() self.gloryfirst = true self:OnStatusChange(true) end)
    EventMgr.Instance:AddListener(event_name.role_level_change, function() self.gloryfirst = true self:OnStatusChange(true) end)
    EventMgr.Instance:AddListener(event_name.role_exp_change, function() self:OnStatusChange(true) end)
    EventMgr.Instance:AddListener(event_name.role_attr_change, function() self:OnStatusChange(true) end)
    EventMgr.Instance:AddListener(event_name.role_name_change, function() self:OnStatusChange(true) end)
    EventMgr.Instance:AddListener(event_name.pet_update, function() self:OnStatusChange(true) end)
    EventMgr.Instance:AddListener(event_name.skill_update, function() self:OnStatusChange(true) end)
    EventMgr.Instance:AddListener(event_name.role_looks_change, function() self:OnStatusChange(true) end)
    EventMgr.Instance:AddListener(event_name.guard_recruit_success, function() self:OnStatusChange(true) end)
    EventMgr.Instance:AddListener(event_name.role_asset_change, function () self:OnStatusChange(true) end)
    EventMgr.Instance:AddListener(event_name.equip_item_change, function() self:OnStatusChange(true) end)
    EventMgr.Instance:AddListener(event_name.tower_reward_update, function() self:OnStatusChange(true) end)
    EventMgr.Instance:AddListener(event_name.tower_reward_update, function() self:OnStatusChange(true) end)
    EventMgr.Instance:AddListener(event_name.backpack_item_change, function() self:OnStatusChange(true) end)
    EventMgr.Instance:AddListener(event_name.role_wings_change, function() self:OnStatusChange(true) end)
    EventMgr.Instance:AddListener(event_name.buff_update, function() self:OnStatusChange(true) end)
    RideManager.Instance.OnUpdateRide:Add(function() self:OnStatusChange(true) end)
    ChildrenManager.Instance.OnChildStudyUpdate:Add(function() self:OnStatusChange(true) end)
    ChildrenManager.Instance.OnChildDataUpdate:Add(function() self:OnStatusChange(true) end)
    ChildrenManager.Instance.OnChildNoviceUpdate:Add(function() self:OnStatusChange(true) end)
    ExquisiteShelfManager.Instance.onUpdateEvent:Add(function() self:OnStatusChange(true) end)
    SkillManager.Instance.OnUpdateSkillEnergy:AddListener(function() self:OnStatusChange(true) end)
end

function ImproveManager:OnStatusChange(isEffect)
    local uid = BaseUtils.Key(RoleManager.Instance.RoleData.id, RoleManager.Instance.RoleData.platform, RoleManager.Instance.RoleData.zone_id)
    self.uid = uid
        self.buttonList = self.buttonList or {
        -- {name = TI18N("功能测试"), func = function() GmManager.Instance:OpenGmWindow() self.model:CloseWin() end, flag = function() return true end},
        -- {name = TI18N("功能测试2"), func = function() TruthordareManager.Instance.model:OpenEditorWindow() self.model:CloseWin() end, flag = function() return true end},
        -- {name = TI18N("战前准备"), func = function() BuffPanelManager.Instance.model:OpenPrewarPanel() self.model:CloseWin() end, flag = true},
        {name = TI18N("<color='#FFFF00'>活力可使用</color>"),   func = function() self:Open_UseEnergy() end,     flag = function() return DataAgenda.data_energy_max[RoleManager.Instance.RoleData.lev] ~= nil and (RoleManager.Instance.RoleData.energy / DataAgenda.data_energy_max[RoleManager.Instance.RoleData.lev].max_energy >= 0.5) end},
        {name = TI18N("可拜师"),   func = function() self:DoTeacher() end, flag = function() return RoleManager.Instance.world_lev >=45 and RoleManager.Instance.RoleData.lev <= 45 and RoleManager.Instance.RoleData.lev >= 20  and TeacherManager.Instance.model:IsHasTeahcerStudentRelationShip() == false and
        PlayerPrefs.GetString(BaseUtils.Key(uid, TI18N("可拜师"))) == "" end},
        -- {name = TI18N("悬赏任务可接"),   func = function() self:DoXuanSang() end,    flag = RoleManager.Instance.RoleData.lev <= 25 and RoleManager.Instance.RoleData.lev >= 20  and PlayerPrefs.GetString(BaseUtils.Key(uid, TI18N("悬赏任务可接"))) == ""},
        -- {name = "竞技场可挑战",   func = function() self:DoArena() end,    flag = RoleManager.Instance.RoleData.lev <= 40 and RoleManager.Instance.RoleData.lev >= 28  and PlayerPrefs.GetString(BaseUtils.Key(uid, "竞技场可挑战")) == ""},
        -- {name = "极寒试炼可挑战",   func = function() self:DoTrial() end,    flag = RoleManager.Instance.RoleData.lev <= 40 and RoleManager.Instance.RoleData.lev >= 32  and PlayerPrefs.GetString(BaseUtils.Key(uid, "极寒试炼可挑战")) == ""},
        -- {name = "35副本可挑战",   func = function() self:Do35Dungeon() end,    flag = RoleManager.Instance.RoleData.lev <= 40 and RoleManager.Instance.RoleData.lev >= 35  and PlayerPrefs.GetString(BaseUtils.Key(uid, "35副本可挑战")) == ""},
        -- {name = "天空之塔可挑战",   func = function() self:DoTower() end,    flag = RoleManager.Instance.RoleData.lev <= 45 and RoleManager.Instance.RoleData.lev >= 40  and PlayerPrefs.GetString(BaseUtils.Key(uid, "天空之塔可挑战")) == ""},
        -- {name = "55副本可挑战",   func = function() self:Do55Dungeon() end,    flag = RoleManager.Instance.RoleData.lev <= 57 and RoleManager.Instance.RoleData.lev >= 55  and PlayerPrefs.GetString(BaseUtils.Key(uid, "55副本可挑战")) == ""},
        {name = TI18N("通关奖励"),   func = function() self:Open_TowerReward() end,    flag = function() return (RoleManager.Instance.RoleData.lev >= 40 and DungeonManager.Instance:CheckTowerReward()) end},
         {name = TI18N("副本奖励可领"),func = function()  TeamDungeonManager.Instance:Send12151() self.model:CloseWin() end, flag = function() return self:CheckHasReward() end},
        {name = TI18N("人物加点"),   func = function() self:Open_PlayerAttribute() end,    flag = function() return (RoleManager.Instance.RoleData ~= nil and RoleManager.Instance.RoleData.point ~= nil and RoleManager.Instance.RoleData.point > 0) end},
        -- {name = "免费洗点",   func = function() self:Open_PlayerAttribute() end,    flag = (RoleManager.Instance.RoleData.lev >= 30 and RoleManager.Instance.RoleData.lev < 40 and RoleManager.Instance.RoleData.first_free == 0)},
        -- {name = "免费改名",   func = function() self:Open_Rename() end,    flag = (RoleManager.Instance.RoleData.lev >= 30 and RoleManager.Instance.RoleData.lev < 40  and RoleManager.Instance.RoleData.rename_free == 0)},
        {name = TI18N("宠物加点"),   func = function() self:Open_PetWindow() end,    flag = function() return (PetManager.Instance:Get_CurPet()~=nil and PetManager.Instance:Get_CurPet().point>0) end},
        -- {name = "宠物免费洗点",   func = function() self:Open_PetWindow() end,    flag = (PetManager.Instance:Get_CurPet()~=nil and PetManager.Instance:Get_CurPet().lev < 40 and PetManager.Instance:Get_CurPet().free_reset_flag == 0)},
        {name = TI18N("技能升级"),   func = function() self:Open_SkillWindow() end,    flag = function() return (SkillManager.Instance.model:checknewskill() or SkillManager.Instance.model:checkupgradeskill()) end},
        {name = TI18N("守护装备"),   func = function() WindowConfig.OpenFunc[WindowConfig.WinID.guardian]({1}) end, flag = function() return ShouhuManager.Instance.model:check_has_shouhu_equip_canup() end},
        {name = TI18N("守护招募"),   func = function() WindowConfig.OpenFunc[WindowConfig.WinID.guardian]({1}) end, flag = function() return ShouhuManager.Instance.model:check_has_shouhu_can_recruit() end},
        -- {name = "测试按钮7",   func = function() self:Test() end,    flag = true},
        -- {name = "测试按钮8",   func = function() self:Test1() end,    flag = true},
        -- {name = TI18N("翅膀可合成"), func = function() WindowConfig.OpenFunc[WindowConfig.WinID.backpack]({3, 4}) end, flag = WingsManager.Instance:Synthesizable()},
        {name = TI18N("翅膀可升级"), func = function() WindowConfig.OpenFunc[WindowConfig.WinID.backpack]({3}) end, flag = function() return WingsManager.Instance:Upgradable() end},
        {name = TI18N("装备强化"), func = function() WindowConfig.OpenFunc[WindowConfig.WinID.eqmadvance]() end, flag = function() return EquipStrengthManager.Instance.model:check_has_equip_can_up() end},

        {name = TI18N("装备可提升"), func = function() WindowConfig.OpenFunc[WindowConfig.WinID.eqmadvance]() end, flag = function() return EquipStrengthManager.Instance.model:check_has_equip_can_lev_up() end},
        {name = TI18N("补充饱食"), func = function() self:OpenSatiation() end, flag = function() return SatiationManager.Instance:IsHunger() end},
        {name = TI18N("补充坐骑精力"), func = function() WindowConfig.OpenFunc[WindowConfig.WinID.ridefeedwindow]() end, flag = function() return RideManager.Instance:IsNeedFeed() end},
        -- {name = TI18N("爵位可挑战"), func = function() self.gloryfirst = false WindowManager.Instance:OpenWindowById(WindowConfig.WinID.glory_window) end, flag = (GloryManager.Instance:ChallengeLevel() and self.gloryfirst == true)},
        {name = TI18N("节日礼物"), func = function() QuestManager.Instance.model:FindNpc("45_1") self.model:CloseWin() end, flag = function() return self:CheckFestival() end},
        {name = TI18N("可突破"), func = function()  WindowManager.Instance:OpenWindowById(WindowConfig.WinID.levelbreakwindow) self.model:CloseWin() end, flag = function() return RoleManager.Instance.RoleData.lev_break_times < 1 and RoleManager.Instance.RoleData.lev == 100 end},
        {name = TI18N("战力推荐"), func = function() ForceImproveManager.Instance.model:OpenForceImproveRecommendWindow() self.model:CloseWin() end, flag = function() return RoleManager.Instance.RoleData.fc * 2 < ForceImproveManager.Instance.model:GetRecommendFC() end},
        {name = TI18N("评分晋级"), func = function() ForceImproveManager.Instance.model:OpenWindow({2}) self.model:CloseWin() end, flag = function() return ForceImproveManager.Instance.model:CheckCanUpgrade(false) end},
        {name = TI18N("秘宝锤可用"), func = function()  WindowManager.Instance:OpenWindowById(WindowConfig.WinID.maze_window) self.model:CloseWin() end, flag = function() return self:CheckMaze() end},
        {name = TI18N("公会祈福"), func = function()  self:OnWish() self.model:CloseWin() end, flag = function() return self:CheckWish() end},
        {name = TI18N("等级可跃升"), func = function()  self:OnJumpLev() self.model:CloseWin() end, flag = function() return self:OnCheckJumpLev() end},
        {name = TI18N("子女课程学习"), func = function()  self:OnChildrenLearn() self.model:CloseWin() end, flag = function() return self:CheckChildLearn() end},
        {name = TI18N("心情值不足"), func = function()  self:OnOpenChildrenHappiness() self.model:CloseWin() end, flag = function() return self:CheckChildrenHappiness() end},
        -- inserted by 嘉俊 ：领取历练百环宝箱
        {name = TI18N("历练奖励可领"),func = function() self:OnOpenChainTreasure() self.model:CloseWin() end,flag = function() return self:CheckChainTreasure() end},
        -- end by 嘉俊

        {name = TI18N("宝阁奖励可领"),func = function() self:OnOpenExquisiteReward() self.model:CloseWin() end,flag = function() return self:CheckExquisiteReward() end},
        {name = TI18N("补充特技能量"),func = function() WingsManager.Instance.model:OpenEnergy() self.model:CloseWin() end,flag = function() return WingsManager.Instance:ImproveEnergy() end},

        {name = TI18N("诸神挑战奖励可领"),func = function() self:OnOpenGodsWarChallengeReward() end,flag = function() return self:CheckGodsWarChallengeReward() end},
        --{name = TI18N("补充技能灵气"),func = function() self:OnOpenSkillEnergy() self.model:CloseWin() end,flag = function() return SkillManager.Instance.model.finalSkill ~= nil and #SkillManager.Instance.model.finalSkill.skill_unique > 0 and SkillManager.Instance.sq_point < 40 end},
     }
    local tempList = {}
    for i,v in ipairs(self.buttonList) do
        if v.flag() then
            table.insert(tempList, v)
        end
    end
    if MainUIManager.Instance.MainUIIconView ~= nil then
        if RoleManager.Instance.RoleData.lev >= 40 then
            MainUIManager.Instance.MainUIIconView:hide_icon_by_idlist(17, false)
        else
            if #tempList == 0 then
                MainUIManager.Instance.MainUIIconView:hide_icon_by_idlist(17, true)
            else
                MainUIManager.Instance.MainUIIconView:hide_icon_by_idlist(17, false)
            end
        end
    end

    local hasNew = true
    if #self.lastList == #tempList then
        hasNew = false
        for i,v in ipairs(tempList) do
            if v.name ~= self.lastList[i].name then
                hasNew = true
            end
        end
    end
    if ((hasNew and isEffect) or self.firstCheck) and MainUIManager.Instance.MainUIIconView ~= nil then
        local icon = MainUIManager.Instance.MainUIIconView:getbuttonbyid(17)
        if icon ~= nil then
            self.red = icon.transform:Find("RedPointImage")
            if self.red ~= nil then
                self.firstCheck = false
                self.red.gameObject:SetActive(true)
            end
        end
    end
    self.lastList = tempList
end
--打开补充饱食度界面
function ImproveManager:OpenSatiation()
    self.model:CloseWin()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.satiation_window)
end

function ImproveManager:Test()
    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal
    data.content = TI18N("开面包")
    data.sureLabel = TI18N("window")
    data.cancelLabel = TI18N("panel")
    data.sureCallback = function()
        GuildAuctionManager.Instance.model:OpenWindow()
    end
    data.cancelCallback = function()
        GuildAuctionManager.Instance.model:OpenPanel()
    end
    NoticeManager.Instance:ConfirmTips(data)

    self.model:CloseWin()
end

function ImproveManager:Test1()
    ParadeManager.Instance:Require13302()
    self.model:CloseWin()
end

function ImproveManager:Open_UseEnergy()
    self.model:CloseWin()
    SkillManager.Instance.model:OpenUseEnergy()
end

function ImproveManager:Open_PlayerAttribute()
    BackpackManager.Instance.mainModel:OpenAddPoint()
    self.model:CloseWin()
end

function ImproveManager:Open_Rename()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.backpack, {1, 1, 1})
end

function ImproveManager:Open_PetWindow()
    PetManager.Instance.model:OpenPetWindow({1})
    self.model:CloseWin()
end

function ImproveManager:Open_SkillWindow()
    SkillManager.Instance.model:OpenSkillWindow()
    self.model:CloseWin()
end

function ImproveManager:Open_TowerReward()
    DungeonManager.Instance.model:OpenTowerReward()
    self.model:CloseWin()
end

function ImproveManager:DoXuanSang()
    PlayerPrefs.SetString(BaseUtils.Key(self.uid, "悬赏任务可接"), "1")
    self.model:CloseWin()
    QuestManager.Instance.model:DoOffer()
    self:OnStatusChange()
end

function ImproveManager:DoArena()
    PlayerPrefs.SetString(BaseUtils.Key(self.uid, TI18N("竞技场可挑战")), "1")
    self.model:CloseWin()
    -- AgendaManager.Instance:OpenWindow(1)
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.arena_window)
    self:OnStatusChange()
end

function ImproveManager:DoTrial()
    PlayerPrefs.SetString(BaseUtils.Key(self.uid, TI18N("极寒试炼可挑战")), "1")
    self.model:CloseWin()
    TrialManager.Instance.model:OpenWindow()
    self:OnStatusChange()
end

function ImproveManager:Do35Dungeon()
    PlayerPrefs.SetString(BaseUtils.Key(self.uid, TI18N("35副本可挑战")), "1")
    self.model:CloseWin()
    SceneManager.Instance.sceneElementsModel:Self_PathToTarget("10024_1")
    self:OnStatusChange()
end

function ImproveManager:DoTower()
    PlayerPrefs.SetString(BaseUtils.Key(self.uid, TI18N("天空之塔可挑战")), "1")
    self.model:CloseWin()
    DungeonManager.Instance:EnterTower(1)
    self:OnStatusChange()
end

function ImproveManager:Do55Dungeon()
    PlayerPrefs.SetString(BaseUtils.Key(self.uid, TI18N("55副本可挑战")), "1")
    self.model:CloseWin()
    SceneManager.Instance.sceneElementsModel:Self_PathToTarget("10023_1")
    self:OnStatusChange()
end

function ImproveManager:DoTeacher()
    PlayerPrefs.SetString(BaseUtils.Key(self.uid, TI18N("可拜师")), "1")
    if TeamManager.Instance:HasTeam() then
        NoticeManager.Instance:FloatTipsByString(TI18N("需要和师傅组队前往进行拜师"))
    end
    self.model:CloseWin()
    -- SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
    -- SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
    -- SceneManager.Instance.sceneElementsModel:Self_PathToTarget("2_1")
    local currentNpcData = DataUnit.data_unit[20001]
    currentNpcData.baseid = 20001
    local extra = {}
    extra.base = BaseUtils.copytab(DataUnit.data_unit[20001])
    MainUIManager.Instance.dialogModel:Open(currentNpcData, extra, true)
    self:OnStatusChange()
end


function ImproveManager:CheckFestival()
    return (not FestivalManager.Instance.isFestivalGot) and RoleManager.Instance.RoleData.lev >= 20
end

function ImproveManager:CheckMaze()
    local itemnum = BackpackManager.Instance:GetItemCount(21220)
    return itemnum >= 10 and DataAgenda.data_list[1027].engaged ~= DataAgenda.data_list[1027].max_try
end

function ImproveManager:CheckWish()
    if GuildManager.Instance.model:has_guild() then
        --有公会
        if RoleManager.Instance.world_lev < 70 then
            return false
        else
            if GuildManager.Instance.model.my_guild_data ~= nil and GuildManager.Instance.model.my_guild_data.element_info ~= nil and #GuildManager.Instance.model.my_guild_data.element_info > 0 then
                local tempData = GuildManager.Instance.model.prayElementData
                if tempData ~= nil then
                    local end_time = 0
                    for k, v in pairs(tempData.element_attr) do
                        if (v.effect_obj == 1) or (v.effect_obj == 2 and GuildManager.Instance.model:CheckPrayElementLev()) then
                            end_time  = v.end_time - BaseUtils.BASE_TIME
                            break
                        end
                    end
                    local roleCurList, roleNewList, petCurList, petNewList =  GuildManager.Instance.model:GetPrayList(tempData)
                    if end_time > 2 and #roleCurList > 0 and (#petCurList > 0 or not GuildManager.Instance.model:CheckPrayElementLev()) then
                        return false
                    else
                        return true
                    end
                end
                return true
            else
                return false
            end
        end
    else
        return false
    end
end

-- inserted by 嘉俊 ：检测是否有历练环宝箱可领取
function ImproveManager:CheckChainTreasure()
    if QuestManager.Instance.model.hasTreasureOfChain100 == 1 or QuestManager.Instance.model.hasTreasureOfChain200 == 1 then
        return true
    end
    return false
end
function ImproveManager:OnOpenChainTreasure()

end
-- end by 嘉俊

function ImproveManager:OnWish()
    if GuildManager.Instance.model:has_guild() then
        --有公会
        if RoleManager.Instance.world_lev < 70 then
            NoticeManager.Instance:FloatTipsByString(TI18N("世界等级尚未达到70级"))
        else
            if #GuildManager.Instance.model.my_guild_data.element_info > 0 then
                local tempData = GuildManager.Instance.model.prayElementData
                if tempData ~= nil then
                    local end_time = 0
                    for k, v in pairs(tempData.element_attr) do
                        if (v.effect_obj == 1) or (v.effect_obj == 2 and GuildManager.Instance.model:CheckPrayElementLev()) then
                            end_time  = v.end_time - BaseUtils.BASE_TIME
                            if end_time <= 0 then
                                if v.effect_obj == 1 then
                                    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.guild_pray_window, 1)
                                else
                                    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.guild_pray_window, 2)
                                end
                                return
                            end
                        end
                    end
                    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.guild_pray_window, 1)
                else
                    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.guild_pray_window, 1)
                end
            else
                NoticeManager.Instance:FloatTipsByString(TI18N("您的公会现在还未开启元素祭坛"))
            end
        end
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("尚未加入公会，无法进行公会祈福"))
    end
end

function ImproveManager:OnCheckJumpLev()
    local currlev = RoleManager.Instance.RoleData.lev
    if currlev == 0 then
        return false
    end

    local currexp = RoleManager.Instance.RoleData.exp
    local maxexp = DataLevup.data_levup[currlev].exp

    -- end
    if PlayerPrefs.GetString("Jumplev") ~= "1" and currexp >= maxexp and (currlev == 89 or currlev == 99 or currlev == 109)  then
        return true
    else
        return false
    end
end

function ImproveManager:OnJumpLev()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.leveljumpwindow)
end

function ImproveManager:CheckChildLearn()
    return (PlayerPrefs.GetInt("ChildLearnNotice") ~= -1 and ChildrenManager.Instance:CheckCanLearn())
end

function ImproveManager:OnChildrenLearn()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.child_study_win)
end

function ImproveManager:OnOpenChildrenHappiness()
    PetManager.Instance.model.currChild = self.curChild
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.pet_child_feed, {self.curChild,2})
end

function ImproveManager:CheckChildrenHappiness()
    local recVal = false
    local childrenData = ChildrenManager.Instance.childData
        if #childrenData ~= 0 then
        local noviceLev = 1
        for _,v in ipairs(childrenData) do
           local childrenNoviceData = ChildrenManager.Instance:GetChildNovice(v.child_id,v.platform,v.zone_id)
           if childrenNoviceData == nil then
               noviceLev = 4
               else
               noviceLev = childrenNoviceData.lev
           end
           local noviceNum = ChildrenEumn.ChildrenHungryNovice[noviceLev]
           if  noviceNum > v.hungry then
               recVal = true
               self.curChild = v
               break
           end
        end
    end
    return recVal
end

--检测是否有副本可领
function ImproveManager:CheckHasReward()
    local recVal = false
    if TeamDungeonManager.Instance.hasRewardData == 1 then
       recVal = true
    end
    return recVal
end

-- 打开玲珑宝阁奖励
function ImproveManager:OnOpenExquisiteReward()
    ExquisiteShelfManager.Instance:send20309()
end

function ImproveManager:CheckExquisiteReward()
    return ExquisiteShelfManager.Instance:HasnotReward()
end

function ImproveManager:OnOpenSkillEnergy()
    local checkFun = function(data)
            local id = DataSkillUnique.data_skill_unique[RoleManager.Instance.RoleData.classes.."_1"].learn_cost[1][1]
            if data.base_id == id then
                return true
            else
                return false
            end
        end
    local button3_callback = function()
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.market, { 2, 4 })
    end
    BackpackManager.Instance.mainModel:OpenQuickBackpackWindow({ checkFun = checkFun, showButtonType = 2, button3_callback = button3_callback})
end


-- 打开诸神挑战奖励
function ImproveManager:OnOpenGodsWarChallengeReward()
    self.model:CloseWin()
    if TeamManager.Instance:HasTeam() and not TeamManager.Instance:IsSelfCaptin() then
        NoticeManager.Instance:FloatTipsByString(TI18N("跟随队伍中,不能进行此操作"))
        return
    end
    SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
    SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
    SceneManager.Instance.sceneElementsModel:Self_PathToTarget("75_1")

    -- local target = BaseUtils.get_unique_npcid(20096, 1)
    -- SceneManager.Instance.sceneElementsModel:Self_AutoPath(10001, target, nil, nil, true)
    -- SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
end

function ImproveManager:CheckGodsWarChallengeReward()
    local recVal = false
    if GodsWarWorShipManager.Instance.HasAudienceReward == 1 then
       recVal = true
    end
    return recVal
end
