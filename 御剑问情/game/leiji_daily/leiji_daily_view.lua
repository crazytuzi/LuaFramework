LeiJiDailyView = LeiJiDailyView or BaseClass(BaseView)

local WINGRESID = {
    RES_1 = 8104001,
    RES_2 = 8108001,
}

local LEIJI_REWARD_MAX_NUM = 5
local ACTIVE_REWARD_MAX_NUM = 5
local CUR_SHOW_ID = 0

function LeiJiDailyView:__init()
    self.ui_config = {"uis/views/leijirechargeview_prefab", "LeiJiDailyView"}
    self.full_screen = false
    self.play_audio = true
    self.auto_close_time = 0
    self.is_stop_task = false
    self.temp_select_index = -1
end

function LeiJiDailyView:LoadCallBack()
    self:ListenEvent("Close", BindTool.Bind(self.OnClickClose, self))
    self:ListenEvent("Draw", BindTool.Bind(self.OnClickDraw, self))

    self.person_glal_change_handle = GlobalEventSystem:Bind(OtherEventType.VIRTUAL_TASK_CHANGE, BindTool.Bind(self.Flush, self))

    self.btn_text = self:FindVariable("ButtonText")
    self.btn_active = self:FindVariable("BtnActive")

    self.cell_list = {}
    self.items_list = {}

    self.current_index = 1

    self.list_view = self:FindObj("ListView")
    local list_delegate = self.list_view.list_simple_delegate
    list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
    list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

    for i = 1, LEIJI_REWARD_MAX_NUM do
        self.items_list[i] = ItemCell.New()
        self.items_list[i]:SetInstanceParent(self:FindObj("Item"..i))
    end

    self.active_flag = true
    self.is_active = self:FindVariable("IsActive")
    self.active_pro_value = self:FindVariable("ActiveProValue")
    self.need_active_num = self:FindVariable("NeedActiveNum")
    self.slogan_flag = self:FindVariable("SloganFlag")
    self.now_active_num = self:FindVariable("NowActiveValue")
    self.power_value = self:FindVariable("PowerValue")
    self.god_image = self:FindVariable("GodImage")
    self.is_zsd = self:FindVariable("IsZsd")
    self.active_items_list = {}
    self.is_got_list = {}
    self.show_eff_list = {}
    for i = 1, ACTIVE_REWARD_MAX_NUM do
        self.active_items_list[i] = ItemCell.New()
        self.active_items_list[i]:SetInstanceParent(self:FindObj("ActiveItem"..i))
        self.is_got_list[i] = self:FindVariable("IsGot"..i)
        self.show_eff_list[i] = self:FindVariable("ShowEff"..i)
    end

    self.display = self:FindObj("Display")
end

function LeiJiDailyView:ReleaseCallBack()
    CUR_SHOW_ID = 0
    self.list_view = nil
    self.btn_text = nil
    self.btn_active = nil

    for k, v in pairs(self.cell_list) do
        v:DeleteMe()
    end
    for k, v in pairs(self.items_list) do
        v:DeleteMe()
    end
    for k,v in pairs(self.active_items_list) do
        v:DeleteMe()
    end
    if self.model then
        self.model:DeleteMe()
        self.model = nil
    end

    self.items_list = {}
    self.cell_list = {}
    self.active_items_list = {}
    self.show_eff_list = {}

    self.active_flag = nil
    self.is_active = nil
    self.active_pro_value = nil
    self.need_active_num = nil
    self.slogan_flag = nil
    self.now_active_num = nil
    self.power_value = nil
    self.god_image = nil
    self.is_zsd = nil
    self.display = nil
    self.is_got_list = {}
    self.show_eff_list = {}

    if self.person_glal_change_handle then
        GlobalEventSystem:UnBind(self.person_glal_change_handle)
        self.person_glal_change_handle = nil
    end
end

function LeiJiDailyView:GetNumberOfCells()
    local cfg = DailyChargeData.Instance:GetTotalLeijiDailyReward()
    return #cfg
end

function LeiJiDailyView:RefreshCell(cell, cell_index)
    -- 默认活跃奖励放第一个
    cell_index = cell_index + 1
    local target_cell = self.cell_list[cell]
    if target_cell == nil then
        target_cell = LeiJIRechargeCell.New(cell.gameObject)
        target_cell.view = self
        self.cell_list[cell] = target_cell
    end

    local data_list = DailyChargeData.Instance:GetTotalLeijiDailyReward()
    target_cell:SetIndex(cell_index)
    target_cell:SetData(data_list[cell_index])
end

function LeiJiDailyView:OpenCallBack()
    RemindManager.Instance:SetTodayDoFlag(RemindName.DailyLeiJi)
    self.current_index = DailyChargeData.Instance:GetLeijiDailyViewCurIndex()
    self.is_open_active_reward = DailyChargeData.Instance:GetIsOpenActiveReward()

    if self.is_open_active_reward and self.current_index == 1 then
        self.active_flag = true
    else
        self.active_flag = false
    end

    if self.bipin_state then
        self.current_index = 3
    end

    self:Flush()
end

function LeiJiDailyView:CloseCallBack()
    self.bipin_state = false
end

function LeiJiDailyView:BiPinState(state)
    self.bipin_state = state
end

function LeiJiDailyView:OnClickClose()
    self:Close()
end

function LeiJiDailyView:OnClickDraw()
    if self.is_open_active_reward and self.current_index == 1 then
        self:DrawActiveReward()
    else
        self:DrawLeiJiReward()
    end
end

function LeiJiDailyView:DrawLeiJiReward()
    local cfg = DailyChargeData.Instance:GetTotalLeijiDailyReward()
    local info = DailyChargeData.Instance:GetChongZhiInfo()
    if next(cfg) == nil or next(info) == nil then
        return
    end
    local list = info.daily_chongzhi_fetch_reward2_flag
    local today_recharge = info.today_recharge
    local cur_cfg = cfg[self.current_index]
    if list[32 - cur_cfg.seq] ~= 1 and today_recharge < cur_cfg.need_chongzhi then
        VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
        ViewManager.Instance:Open(ViewName.VipView)
        ViewManager.Instance:Close(ViewName.LeiJiDailyView)
    else
        RechargeCtrl.Instance:SendChongzhiFetchReward(CHONGZHI_REWARD_TYPE.CHONGZHI_REWARD_TYPE_DAILY2, cur_cfg.seq, 0)
    end
end

function LeiJiDailyView:DrawActiveReward()
    local active_reward_info = ZhiBaoData.Instance:GetDailyActiveRewardInfo()
    ZhiBaoCtrl.Instance:SendGetActiveReward(FETCH_ACTIVE_REWARD_OPERATE_TYEP.FETCH_ACTIVE_REWARD_IN_LEIJI_DAILY_VIEW, active_reward_info.cur_index - 1)
end

function LeiJiDailyView:SetNextCurrentIndex()
    local reward_info = DailyChargeData.Instance:GetDailyLeiJiRewardDay()
    local active_info = ZhiBaoData.Instance:GetDailyActiveRewardInfo()
    local open_flag = DailyChargeData.Instance:GetIsOpenActiveReward()
    local reward_count = #reward_info
    if next(reward_info) == nil then
        return
    end

    -- 出现活跃度奖励
    if open_flag then
        if next(active_info) == nil then
            return
        end
        if self.current_index == 1 and ZhiBaoData.Instance:IsShowActiveRewardRedPoint() then
            return
        end
        if self.current_index == 1 and DailyChargeData.Instance:IsLeijiRewardRedPoint() == false then
            if ZhiBaoData.Instance:IsShowActiveRewardRedPoint() then
                return
            end
        end
    end
    -- 每日累充奖励有红点情况下的跳转
    local index = open_flag and 2 or 1
    reward_count = open_flag and reward_count + 1 or reward_count
    for i = index, reward_count do
        if DailyChargeData.Instance:GetDailyChargeRedPointByIndex(i) then
            self.current_index = i
            return
        end
    end
    -- 每日累充奖励没有红点情况下的跳转
    local leiji_reward_index = DailyChargeData.Instance:GetDailyChargeNowIndex()
    if leiji_reward_index == -1 then
        if open_flag and active_info.reward_on_day_flag_list[5] == 0 then
            self.current_index = 1
        end
        return
    end
    self.current_index = leiji_reward_index
end

function LeiJiDailyView:OnFlush()
    self.list_view.scroller:RefreshAndReloadActiveCellViews(true)
    self:FlushLeftList()
    self:SetModel()

    self.active_flag = self.current_index == 1 and DailyChargeData.Instance:GetIsOpenActiveReward()
    self.is_active:SetValue(self.active_flag)
    if self.active_flag then
        self:FlushActiveContent()
    else
        self:FlushRightContent()
    end
end

function LeiJiDailyView:SetCurrentIndex(index)
    self.current_index = index or 1
end

function LeiJiDailyView:FlushLeftList()
    for k,v in pairs(self.cell_list) do
        v:FlushIsSelected(self.current_index)
    end
end

function LeiJiDailyView:FlushRightContent()
    local cfg, max_seq = DailyChargeData.Instance:GetTotalLeijiDailyReward()
    if next(cfg) == nil then
        return
    end
    local cur_cfg = cfg[self.current_index]

    -- 设置item
    local effect_list = Split(cur_cfg.item_effect, ",")
    for k, v in pairs(self.items_list) do
        v:SetData(cur_cfg.reward_item[k - 1])
        v.root_node:SetActive(cur_cfg.reward_item[k - 1] ~= nil and cur_cfg.reward_item[k - 1].item_id > 0)
        if tonumber(effect_list[k]) == 1 then
            v:ShowSpecialEffect(true)
            local bunble, asset = ResPath.GetItemActivityEffect()
            v:SetSpecialEffect(bunble, asset)
        end
    end

    -- 设置按钮
    local seq_list = DailyChargeData.Instance:GetChongZhiInfo().daily_chongzhi_fetch_reward2_flag
    local today_recharge = DailyChargeData.Instance:GetChongZhiInfo().today_recharge
    if seq_list[32 - cur_cfg.seq] ~= 1 and today_recharge >= cur_cfg.need_chongzhi then
        self.btn_text:SetValue(Language.Common.LingQuJiangLi)
        self.btn_active:SetValue(true)
    elseif seq_list[32 - cur_cfg.seq] == 1 then
        self.btn_text:SetValue(Language.Common.YiLingQu)
        self.btn_active:SetValue(false)
    else
        self.btn_text:SetValue(Language.Common.Recharge)
        self.btn_active:SetValue(true)
    end
end

function LeiJiDailyView:FlushActiveContent()
    local active_reward_info = ZhiBaoData.Instance:GetDailyActiveRewardInfo()
    if next(active_reward_info) == nil then
        return
    end

    local total_degree = active_reward_info.total_degree
    local max_reward_num = #active_reward_info.reward_list
    local degree_limit = active_reward_info.reward_list[active_reward_info.cur_index].degree_limit
    local has_reach = max_reward_num
    for i,v in ipairs(active_reward_info.reward_list) do
        if v.degree_limit > total_degree then
            has_reach =  i - 1
            break
        end
    end

    self.btn_active:SetValue(total_degree >= degree_limit and active_reward_info.reward_on_day_flag_list[has_reach] == 0)
    self.btn_text:SetValue(Language.Common.LingQuJiangLi)
    self.now_active_num:SetValue(total_degree)
    self.slogan_flag:SetValue(active_reward_info.reward_on_day_flag_list[max_reward_num] == 1)

    -- 进度条(换算到精准位置)
    local pro_conver_list = {{0, 0}, {20, 0.139}, {40, 0.315}, {60, 0.49}, {80, 0.664}, {100, 0.84}}
    local pro_list_limit = pro_conver_list[#pro_conver_list][1]
    for i = #pro_conver_list,1,-1 do
        if total_degree >= pro_conver_list[i][1] and total_degree < pro_list_limit then
            local diff = total_degree - pro_conver_list[i][1]
            local bili = (pro_conver_list[i+1][2] - pro_conver_list[i][2]) / (pro_conver_list[i+1][1] - pro_conver_list[i][1])
            local pro = diff * bili + pro_conver_list[i][2]
            self.active_pro_value:SetValue(pro)
            break
        elseif total_degree == pro_list_limit then
            self.active_pro_value:SetValue(pro_conver_list[#pro_conver_list][2])
        elseif total_degree > pro_list_limit then
            self.active_pro_value:SetValue(1)
        end
    end

    for i = 1, #self.active_items_list do
        self.show_eff_list[i]:SetValue(i <= has_reach and active_reward_info.reward_on_day_flag_list[i] == 0)
        self.active_items_list[i]:SetData(active_reward_info.reward_list[i].item)
        self.is_got_list[i]:SetValue(active_reward_info.reward_on_day_flag_list[i])
    end

    if has_reach <= max_reward_num then
        local reach = has_reach == max_reward_num and max_reward_num or (has_reach + 1)
        local diff = active_reward_info.reward_list[reach].degree_limit - total_degree
        diff = diff > 0 and diff or 0
        self.need_active_num:SetValue(diff)
    end
end

function LeiJiDailyView:SetModel()
    if CUR_SHOW_ID == model_item_id then
        return
    end
    CUR_SHOW_ID = model_item_id

    if self.model == nil then
        self.model = RoleModel.New()
        self.model:SetDisplay(self.display.ui3d_display)
    end

    local zsd_seq = DailyChargeData.Instance:GetCanGetZhishengdanSeq()
    local now_reward_cfg = DailyChargeData.Instance:GetLeijiDailyShowModelItemId()
    local model_item_id = now_reward_cfg.model_item_id or 0
    local display_name = "threepiece_panel"
    self.model:SetPanelName(display_name)
    local is_zsd = CompetitionActivityData.Instance:isBipinZSD(model_item_id)
    self.is_zsd:SetValue(is_zsd)

    if not is_zsd then
        LeiJiDailyView.ChangeModel(self.model, model_item_id)
        local power_text = ItemData.GetFightPower(model_item_id)
        if self.power_value then
            self.power_value:SetValue(power_text)
        end
    else
         CompetitionActivityData.Instance:ChangeModelByZSD(self.model, model_item_id)
        local power_text = CompetitionActivityData.Instance:GetFightPowerByZSD(model_item_id)
        if self.power_value then
            self.power_value:SetValue(power_text)
        end
    end

    self.god_image:SetAsset(ResPath.GetLeiJIGodImage(now_reward_cfg.need_chongzhi or 0))
end

function LeiJiDailyView.ChangeModel(model, item_id, item_id2)
    local cfg = ItemData.Instance:GetItemConfig(item_id)
    if cfg == nil then
        return
    end
    local display_role = cfg.is_display_role
    local bundle, asset = nil, nil
    local game_vo = GameVoManager.Instance:GetMainRoleVo()
    local main_role = Scene.Instance:GetMainRole()
    local res_id = 0
    if model then
        local halo_part = model.draw_obj:GetPart(SceneObjPart.Halo)
        local weapon_part = model.draw_obj:GetPart(SceneObjPart.Weapon)
        local wing_part = model.draw_obj:GetPart(SceneObjPart.Wing)
        model.display:SetRotation(Vector3(0, 0, 0))
        if display_role ~= DISPLAY_TYPE.FOOTPRINT then
            model:SetInteger(ANIMATOR_PARAM.STATUS, 0)
        end
        if halo_part then
            halo_part:RemoveModel()
        end
        if wing_part then
            wing_part:RemoveModel()
        end
        if weapon_part then
            weapon_part:RemoveModel()
        end
    end
    if display_role == DISPLAY_TYPE.MOUNT then
        for k, v in pairs(MountData.Instance:GetSpecialImagesCfg()) do
            if v.item_id == item_id then
                bundle, asset = ResPath.GetMountModel(v.res_id)
                res_id = v.res_id
                break
            end
        end
    elseif display_role == DISPLAY_TYPE.WING then
        for k, v in pairs(WingData.Instance:GetSpecialImagesCfg()) do
            if v.item_id == item_id then
                bundle, asset = ResPath.GetWingModel(v.res_id)
                res_id = v.res_id
                break
            end
        end
    elseif display_role == DISPLAY_TYPE.FOOTPRINT then
            for k, v in pairs(FootData.Instance:GetSpecialImagesCfg()) do
                if v.item_id == item_id then
                    res_id = v.res_id
                    break
                end
            end
            model:SetRoleResid(main_role:GetRoleResId())
            model:SetFootResid(res_id)
            model:SetPanelName("leiji_daily_foot_panel")
            model.display:SetRotation(Vector3(0, -90, 0))
            model:SetInteger(ANIMATOR_PARAM.STATUS, 1)
    elseif display_role == DISPLAY_TYPE.FASHION then
        local weapon_res_id = 0
        local weapon2_res_id = 0
        local item_id2 = item_id2 or 0
        for k, v in pairs(FashionData.Instance:GetFashionCfgs()) do
            if v.active_stuff_id == item_id or (0 ~= item_id2 and v.active_stuff_id == item_id2) then
                if v.part_type == 1 then
                    res_id = v["resouce"..game_vo.prof..game_vo.sex]
                else
                    weapon_res_id = v["resouce"..game_vo.prof..game_vo.sex]
                    local temp = Split(weapon_res_id, ",")
                    weapon_res_id = temp[1]
                    weapon2_res_id = temp[2]
                end
            end
        end
        if res_id == 0 then
            res_id = main_role:GetRoleResId()
        end
        if weapon_res_id == 0 then
            weapon_res_id = main_role:GetWeaponResId()
            weapon2_res_id = main_role:GetWeapon2ResId()
        end
        model:SetRoleResid(res_id)
        model:SetWeaponResid(weapon_res_id)
        if weapon2_res_id then
            model:SetWeapon2Resid(weapon2_res_id)
        end
        model:SetPanelName("leiji_daily_fashion_panel")
    elseif display_role == DISPLAY_TYPE.HALO then
            for k, v in pairs(HaloData.Instance:GetSpecialImagesCfg()) do
                if v.item_id == item_id then
                    res_id = v.res_id
                    break
                end
            end
            model:SetRoleResid(main_role:GetRoleResId())
            model:SetHaloResid(res_id)
    elseif display_role == DISPLAY_TYPE.SPIRIT then
        for k, v in pairs(SpiritData.Instance:GetSpiritHuanImageConfig()) do
            if v.item_id and v.item_id== item_id then
                bundle, asset = ResPath.GetSpiritModel(v.res_id)
                res_id = v.res_id
                break
            end
        end
    elseif display_role == DISPLAY_TYPE.FIGHT_MOUNT then
        for k, v in pairs(FightMountData.Instance:GetSpecialImagesCfg()) do
            if v.item_id == item_id then
                bundle, asset = ResPath.GetFightMountModel(v.res_id)
                res_id = v.res_id
                break
            end
        end
    elseif display_role == DISPLAY_TYPE.SHENGONG then
        for k, v in pairs(ShengongData.Instance:GetSpecialImagesCfg()) do
            if v.item_id == item_id then
                res_id = v.res_id
                local info = {}
                info.role_res_id = GoddessData.Instance:GetShowXiannvResId()
                info.weapon_res_id = v.res_id
                model:SetPanelName("leiji_daily_xian_nv_panel")
                ItemData.SetModel(model, info)
                return
            end
        end
    elseif display_role == DISPLAY_TYPE.SHENYI then
        for k, v in pairs(ShenyiData.Instance:GetSpecialImagesCfg()) do
            if v.item_id == item_id then
                res_id = v.res_id
                local info = {}
                info.role_res_id = GoddessData.Instance:GetShowXiannvResId()
                info.wing_res_id = v.res_id
                model:SetPanelName("leiji_daily_xian_nv_panel")
                ItemData.SetModel(model, info)
                return
            end
        end
    elseif display_role == DISPLAY_TYPE.XIAN_NV then
        local goddess_cfg = ConfigManager.Instance:GetAutoConfig("xiannvconfig_auto")
        if goddess_cfg then
            local xiannv_resid = 0
            local xiannv_cfg = goddess_cfg.xiannv
            if xiannv_cfg then
                for k, v in pairs(xiannv_cfg) do
                    if v.active_item == item_id then
                        xiannv_resid = v.resid
                        break
                    end
                end
            end
            if xiannv_resid == 0 then
                local huanhua_cfg = goddess_cfg.huanhua
                if huanhua_cfg then
                    for k, v in pairs(huanhua_cfg) do
                        if v.active_item == item_id then
                            xiannv_resid = v.resid
                            break
                        end
                    end
                end
            end
            if xiannv_resid > 0 then
                local info = {}
                info.role_res_id = xiannv_resid
                bundle, asset = ResPath.GetGoddessModel(xiannv_resid)
            end
            res_id = xiannv_resid
        end
        model:SetPanelName("leiji_daily_xian_nv_panel")
    elseif display_role == DISPLAY_TYPE.ZHIBAO then
        for k, v in pairs(ZhiBaoData.Instance:GetActivityHuanHuaCfg()) do
            if v.active_item == item_id then
                bundle, asset = ResPath.GetHighBaoJuModel(v.image_id)
                res_id = v.image_id
                break
            end
        end
        model:SetPanelName("leiji_daily_zhibao_panel")
    end
    if bundle and asset and model then
        if display_role == DISPLAY_TYPE.FIGHT_MOUNT then
            model:SetPanelName("leiji_daily_fight_mount_panel")
        elseif display_role == DISPLAY_TYPE.SPIRIT then
            model:SetPanelName("leiji_daily_spirit_panel")
        elseif display_role == DISPLAY_TYPE.FOOTPRINT then
            model:SetPanelName("leiji_daily_foot_panel")
        elseif display_role == DISPLAY_TYPE.WING then
            if res_id then
                if res_id == WINGRESID.RES_1 then
                    model:SetPanelName("leiji_daily_8104001_wing_panel")
                elseif res_id == WINGRESID.RES_2 then
                    model:SetPanelName("leiji_daily_8108001_wing_panel")
                else
                    model:SetPanelName("leiji_daily_wing_panel")
                end
            end
        elseif display_role == DISPLAY_TYPE.MOUNT then
            model:SetPanelName("leiji_daily_mount_panel")
        end
        model:SetMainAsset(bundle, asset)
        if display_role == DISPLAY_TYPE.XIAN_NV or
            display_role == DISPLAY_TYPE.SPIRIT then
            model:SetTrigger("show_idle_1")
        elseif display_role ~= DISPLAY_TYPE.FIGHT_MOUNT then
            model:SetInteger(ANIMATOR_PARAM.STATUS, -1)
        end
    end
end


LeiJIRechargeCell = LeiJIRechargeCell or BaseClass(BaseCell)

function LeiJIRechargeCell:__init(obj, i)
    self.view = nil
    self.gold_text = self:FindVariable("GoldText")
    self.is_selected = self:FindVariable("IsSelected")
    self.is_drew = self:FindVariable("IsDrew")
    self.is_show_red_point = self:FindVariable("IsShowRedPoint")
    self.is_active = self:FindVariable("IsActive")
    self:ListenEvent("ClickButton", BindTool.Bind(self.OnClick, self))

    self.is_selected:SetValue(false)
end

function LeiJIRechargeCell:__delete()
    self.gold_text = nil
    self.is_selected = nil
    self.is_drew = nil
    self.data = nil
    self.view = nil
end

function LeiJIRechargeCell:SetIndex(index)
    self.index = index
end

function LeiJIRechargeCell:SetData(data)

    local open_flag = DailyChargeData.Instance:GetIsOpenActiveReward()
    if open_flag and self.index == 1 then
        self:SetActiveData(data)
        return
    end

    self.data = data
    self.is_active:SetValue(false)
    self.gold_text:SetValue(CommonDataManager.ConverMoney(self.data.need_chongzhi))
    self:FlushIsSelected(self.view.current_index)

    -- 标签红点
    local seq_list = DailyChargeData.Instance:GetChongZhiInfo().daily_chongzhi_fetch_reward2_flag
    if seq_list[32 - self.data.seq] == 1 then
        self.is_drew:SetValue(true)
    else
        self.is_drew:SetValue(false)
    end

    self.is_show_red_point:SetValue(DailyChargeData.Instance:GetDailyChargeRedPointByIndex(self.index))
end

function LeiJIRechargeCell:SetActiveData(data)
    self.is_active:SetValue(true)
    self.gold_text:SetValue(Language.Common.ActiveReward)
    self:FlushIsSelected(self.view.current_index)

    local active_reward_info = ZhiBaoData.Instance:GetDailyActiveRewardInfo()
    self.is_show_red_point:SetValue(ZhiBaoData.Instance:IsShowActiveRewardRedPoint())

    self.is_drew:SetValue(active_reward_info.reward_on_day_flag_list[5])
end

function LeiJIRechargeCell:OnClick()
    self.view:SetCurrentIndex(self.index)
    self.view:Flush()
end

function LeiJIRechargeCell:FlushIsSelected(index)
    self.is_selected:SetValue(index == self.index)
end