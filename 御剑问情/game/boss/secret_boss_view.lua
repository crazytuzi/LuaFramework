SecretBossView = SecretBossView or BaseClass(BaseRender)
local DISPLAYNAME = {
	[3006001] = "boss_panel_4",
	[3025001] = "boss_panel_2",
}

function SecretBossView:__init()
    self.boss_data = {}
    self.select_scene_id = 1250 -- 场景id
    self.select_boss_id = 10-- 选中的bossid
    self.cell_list = {}
    self.boss_list = self:FindObj("BossList")
    self.list_view_delegate = self.boss_list.list_simple_delegate

    self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
    self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
    self:ListenEvent("ToActtack",
    BindTool.Bind(self.ToActtack, self))
    self:ListenEvent("QuestionClick",
    BindTool.Bind(self.QuestionClick, self))
    self:ListenEvent("OnClickZhenBao",
    BindTool.Bind(self.OnClickZhenBao, self))
    self:ListenEvent("OpenKillRecord",
    BindTool.Bind(self.OpenKillRecord, self))
    self.model_display = self:FindObj("display")
    self.model_view = RoleModel.New("boss_panel")
    self.model_view:SetDisplay(self.model_display.ui3d_display)
    self.turntable_info = TurntableInfoCell.New(self:FindObj("Turntable"))

    self.is_show = self:FindVariable("is_show")
    self.boss_num = self:FindVariable("boss_num")
    self:ListenEvent("OnClickQuick",BindTool.Bind(self.OnClickQuick, self))
end

function SecretBossView:__delete()
    if self.model_view then
        self.model_view:DeleteMe()
        self.model_view = nil
    end

    for _, v in pairs(self.cell_list) do
        if v then
            v:DeleteMe()
        end
    end

    self.cell_list = {}
    self.is_show = nil
    self.turntable_info:DeleteMe()
    self.turntable_info = nil
end

function SecretBossView:InitView()
end

function SecretBossView:FlushBossView()
    BossData.Instance:SecretBossRedPointTimer(false)
    BossCtrl.Instance:SetTimer()
    local boss_list,dead_boss = BossData.Instance:GetSecretBossList()
    self.select_boss_id = boss_list[1] and boss_list[1].monster_id or 10
    self:FlushBossList()
    self:FlushInfoList()

    local level = PlayerData.Instance:GetRoleVo().level
    local other_cfg = BossData.Instance:GetSecretOtherCfg()
    local num = BossData.Instance:GetTaskNum()
    if level >= other_cfg.skip_task_limit_level and  num > 0 then
        self.is_show:SetValue(true)
    else
        self.is_show:SetValue(false)
    end
    self.turntable_info:SetShowEffect(WelfareData.Instance:GetTurnTableRewardCount() ~= 0)
end

function SecretBossView:GetNumberOfCells()
    return #BossData.Instance:GetSecretBossList() or 0
end

function SecretBossView:RefreshView(cell, data_index)
    data_index = data_index + 1

    local boss_cell = self.cell_list[cell]
    if boss_cell == nil then
        boss_cell = SecretBossItem.New(cell.gameObject)
        boss_cell.root_node.toggle.group = self.boss_list.toggle_group
        boss_cell.boss_view = self
        self.cell_list[cell] = boss_cell
    end
    boss_cell:SetIndex(data_index)
    boss_cell:SetData(self.boss_data[data_index])
end

function SecretBossView:FlushBossList()
    local boss_list, dead_boss = BossData.Instance:GetSecretBossList()
    if #boss_list > 0 then
        for i = 1, #boss_list do
            self.boss_data[i] = boss_list[i]
        end
    end

    self.boss_list.scroller:ReloadData(0)

    local total_boss_num = #boss_list
    local boss_num = total_boss_num - #dead_boss
    local color = boss_num > 0 and COLOR.GREEN or COLOR.RED
    self.boss_num:SetValue(boss_num .. " / " .. total_boss_num)
end

function SecretBossView:FlushModel()
    if self.model_view == nil then
        return
    end
    -- if self.model_display.gameObject.activeInHierarchy then
        local res_id = BossData.Instance:GetMonsterInfo(self.select_boss_id).resid
		local display_name = self:DisplayName(res_id)
		self.model_view:SetPanelName(display_name)
        self.model_view:SetMainAsset(ResPath.GetMonsterModel(res_id))
        self.model_view:SetTrigger(ANIMATOR_PARAM.REST1)
    -- end
end

function SecretBossView:DisplayName(id)
	local display_name = "boss_panel"
	local boss_id = tonumber(id)
	for k,v in pairs(DISPLAYNAME) do
		if k == boss_id then
			display_name = v
			return display_name
		end
	end
	return display_name
end

function SecretBossView:ToActtack()
    if not BossData.Instance:GetCanGoAttack() then
        TipsCtrl.Instance:ShowSystemMsg(Language.Map.TransmitLimitTip)
        return
    end
    if self.select_scene_id == 0 then
        SysMsgCtrl.Instance:ErrorRemind(Language.Boss.SelectBoss)
        return
    end
    ViewManager.Instance:CloseAll()
    BossData.Instance:SetCurInfo(self.select_scene_id, self.select_boss_id)
    BossCtrl.SendEnterBossFamily(BOSS_ENTER_TYPE.TYPE_BOSS_PRECIOUS, self.select_scene_id)
end


function SecretBossView:QuestionClick()
    local tips_id = 214
    TipsCtrl.Instance:ShowHelpTipView(tips_id)
end


function SecretBossView:OnClickZhenBao()
    ViewManager.Instance:Open(ViewName.Exchange, TabIndex.exchange_mizang)
end

function SecretBossView:OpenKillRecord()
    ViewManager.Instance:Open(ViewName.Boss, TabIndex.drop)
end

function SecretBossView:GetSelectIndex()
    return self.select_index or 1
end

function SecretBossView:SetSelectIndex(index)
    if index then
        self.select_index = index
    end
end

function SecretBossView:SetSelectBossId(boss_id)
    self.select_boss_id = boss_id
end

function SecretBossView:FlushAllHL()
    for k, v in pairs(self.cell_list) do
        v:FlushHL()
    end
end

function SecretBossView:FlushInfoList()
    if self.select_boss_id ~= 0 then
        self:FlushModel()
    end
end

function SecretBossView:OnClickQuick()
    local skip_task_consume = BossData.Instance:GetSecretOtherCfg().skip_task_consume
    local num = BossData.Instance:GetTaskNum()
    local gold = num * skip_task_consume
    local str = string.format(Language.QuickCompletion[SKIP_TYPE.SKIP_TYPE_PRECIOUS_BOSS], gold, num)

    local ok_callback = function ()
        MarriageCtrl.Instance:SendCSSkipReq(SKIP_TYPE.SKIP_TYPE_PRECIOUS_BOSS, -1)
    end

    TipsCtrl.Instance:ShowCommonAutoView("", str, ok_callback, nil, true, nil, nil)
end
------------------------------------------------------------------------------
SecretBossItem = SecretBossItem or BaseClass(BaseCell)

function SecretBossItem:__init()
    self.boss_name = self:FindVariable("Name")
    self.icon = self:FindVariable("Icon")
    self.time = self:FindVariable("Time")
    self.iskill = self:FindVariable("IsKill")
    self.level = self:FindVariable("Level")
    self.image_gray_scale = self:FindVariable("image_gray_scale")
    self.show_hl = self:FindVariable("show_hl")
    self.show_limit = self:FindVariable("show_limit")
    self.can_kill = self:FindVariable("canKill")
    self.can_kill:SetValue(true)
    self.icon_image = self:FindVariable("icon_image")
    self:ListenEvent("ClickItem", BindTool.Bind(self.ClickItem, self))
end

function SecretBossItem:__delete()
    if self.time_coundown then
        GlobalTimerQuest:CancelQuest(self.time_coundown)
        self.time_coundown = nil
    end
end

function SecretBossItem:ClickItem(is_click)
    if is_click then
        self.root_node.toggle.isOn = true
        local select_index = self.boss_view:GetSelectIndex()
        self.boss_view:SetSelectIndex(self.index)
        self.boss_view:SetSelectBossId(self.data.monster_id)
        self.boss_view:FlushAllHL()
        if self.data == nil or select_index == self.index then
            return
        end
        self.boss_view:FlushInfoList()
    end
end

function SecretBossItem:OnFlush()
    if not self.data then return end
    self.root_node.toggle.isOn = false
    local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.data.monster_id]
    if monster_cfg then
        self.boss_name:SetValue(monster_cfg.name)
        self.level:SetValue("Lv." .. monster_cfg.level)
        self.icon:SetAsset(ResPath.GetBoss("bg_rare_" .. "02"))
        local bundle, asset = ResPath.GetBossItemIcon(monster_cfg.headid)
        self.icon_image:SetAsset(bundle, asset)
    end
    self.next_refresh_time = BossData.Instance:GetItemStatusById(self.data.monster_id)
    local diff_time = self.next_refresh_time - TimeCtrl.Instance:GetServerTime()
    if diff_time <= 0 then
        self.iskill:SetValue(false)
        if self.time_coundown then
            GlobalTimerQuest:CancelQuest(self.time_coundown)
            self.time_coundown = nil
        end
        self.time:SetValue(Language.Boss.HadFlush)
        self.image_gray_scale:SetValue(true)
    else
        self.iskill:SetValue(true)
        if nil == self.time_coundown then
            self.time_coundown = GlobalTimerQuest:AddTimesTimer(
            BindTool.Bind(self.OnBossUpdate, self), 1, self.next_refresh_time - TimeCtrl.Instance:GetServerTime())
            self:OnBossUpdate()
        end
        self:OnBossUpdate()
        self.image_gray_scale:SetValue(false)
    end
    self:FlushHL()
end

function SecretBossItem:OnBossUpdate()
    local time = math.max(0, self.next_refresh_time - TimeCtrl.Instance:GetServerTime())
    self.time:SetValue(TimeUtil.FormatSecond(time, 3))
    if time <= 0 then
        -- self:FlushLimit()
        self.iskill:SetValue(false)
        self.image_gray_scale:SetValue(true)
        self.time:SetValue(Language.Boss.HadFlush)
    else
        self.iskill:SetValue(true)
        self.image_gray_scale:SetValue(false)
        self.time:SetValue(TimeUtil.FormatSecond(time))
    end
end

function SecretBossItem:FlushHL()
    local select_index = self.boss_view:GetSelectIndex()
    self.show_hl:SetValue(select_index == self.index)

    local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.data.bossID]
    if monster_cfg then
        local my_level = GameVoManager.Instance:GetMainRoleVo().level
        self.show_limit:SetValue(my_level - monster_cfg.level > 200)
    end
end

-- function SecretBossItem:FlushLimit(monster_cfg)
--     local monster_cfg = monster_cfg or ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.data.monster_id]
--     if monster_cfg then
--         local my_level = GameVoManager.Instance:GetMainRoleVo().level
--         self.show_limit:SetValue(my_level - monster_cfg.level > 200)
--     end
-- end
