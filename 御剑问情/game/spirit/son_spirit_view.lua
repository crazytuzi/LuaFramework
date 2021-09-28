require("game/spirit/spirit_aptitude_view")

SonSpiritView = SonSpiritView or BaseClass(BaseRender)

-- 常亮定义
local BAG_MAX_GRID_NUM = 80
local BAG_ROW = 4
local BAG_COLUMN = 4
local EFFECT_CD = 1
local APTITUDE_TYPE = {"gongji_zizhi", "fangyu_zizhi", "maxhp_zizhi"}
local ATTR_TYPE = {"gongji", "fangyu", "maxhp"}
function SonSpiritView:__init(instance)
    self.need_num = self:FindVariable("UpgradeNeedPro")
    self.have_num = self:FindVariable("UpgradeHavePro")
    self.state_text = self:FindVariable("SpiritState")
    self.spirit_name = self:FindVariable("SpiritName")
    self.spirit_level = self:FindVariable("SpiritLevel")
    self.show_spirit_name = self:FindVariable("ShowSpiritName")
    self.show_uplevel_btn = self:FindVariable("ShowUplevelButton")
    self.show_uplevel_use = self:FindVariable("ShowUplevelUse")
    self.progress = self:FindVariable("Progress")
    self.cur_progress = self:FindVariable("CurProgress")
    self.progress_pre = self:FindVariable("ProgressPre")
    self.show_spirit_huanhua = self:FindVariable("ShowSpiritHuanhuaRedPoint")
    self.show_special_limt_time = self:FindVariable("ShowSpecialFreeTime")
    self.show_special_effect = self:FindVariable("ShowSpecialEffect")
    self.limit_free_time = self:FindVariable("LimitFreeTime")
    self.add_attr_per = self:FindVariable("AddAttrPer")
    self.show_title_btn = self:FindVariable("ShowTitleBtn")
    self.show_specia_btn =self:FindVariable("ShowSpecialBtn")
    self.special_spirit_icon = self:FindVariable("SpecialSpiritIcon")
    self.title_asset = self:FindVariable("TitleAsset")
    self.title_power = self:FindVariable("TitlePower")
    self.title_gray = self:FindVariable("TitleGray")
    self.show_title_time = self:FindVariable("ShowTitleTime")

    self:ListenEvent("OnClickBackPack", BindTool.Bind(self.OnClickBackPack, self))
    self:ListenEvent("OnClickHuanHua", BindTool.Bind(self.OnClickHuanHua, self))
    self:ListenEvent("OnClickFaZhen", BindTool.Bind(self.OnClickFaZhen, self))
    self:ListenEvent("OnClickZhaoHui", BindTool.Bind(self.OnClickZhaoHui, self))
    self:ListenEvent("OnClickUpgrade", BindTool.Bind(self.OnClickUpgrade, self))

    self:ListenEvent("OnClickTakeOff1", BindTool.Bind(self.OnClickTakeOff, self, 1))
    self:ListenEvent("OnClickTakeOff2", BindTool.Bind(self.OnClickTakeOff, self, 2))
    self:ListenEvent("OnClickTakeOff3", BindTool.Bind(self.OnClickTakeOff, self, 3))
    self:ListenEvent("OnClickTakeOff4", BindTool.Bind(self.OnClickTakeOff, self, 4))

    self:ListenEvent("OnClickOneKeyRecover", BindTool.Bind(self.OnClickOneKeyRecover, self))
    self:ListenEvent("OnClickOneKeyEquip", BindTool.Bind(self.OnClickOneKeyEquip, self))
    self:ListenEvent("OnClickCleanBag", BindTool.Bind(self.OnClickCleanBag, self))
    self:ListenEvent("OnClickHelp", BindTool.Bind(self.OnClickHelp, self))
    self:ListenEvent("OnClickReName", BindTool.Bind(self.OnClickReName, self))
    self:ListenEvent("OnClickSendMsg", BindTool.Bind(self.OnClickSendMsg, self))
    self:ListenEvent("OnClickReturn", BindTool.Bind(self.OnClickReturn, self))
    self:ListenEvent("OpenAttrView", BindTool.Bind2(self.OpenTagView, self, true))
    self:ListenEvent("OpenAptitudeView", BindTool.Bind2(self.OpenTagView, self, false))
    self:ListenEvent("OnClickBiPingReward", BindTool.Bind(self.OnClickBiPingReward, self))
    self:ListenEvent("OnClickSpecialSpirit",BindTool.Bind(self.OnClickSpecial, self))
    self:ListenEvent("OnClickSpecialTitle",BindTool.Bind(self.OnClickSpecialTitle, self))

    self.bag_list_view = self:FindObj("PackListView")
    -- self.fanzhen_list_view = self:FindObj("FaZhenListView")
    self.effect_root = self:FindObj("EffectRoot")
    self.attr_view = SpiritNewAttrView.New(self:FindObj("AttrView"))
    self.show_attr_view = self:FindObj("AttrView")
    self.show_aptitude_view = self:FindObj("AptitudeView")
    self.aptitude_view = SpiritNewAptitudeView.New(self.show_aptitude_view)
    self.show_backpack_view = self:FindObj("BackpackView")
    -- self.show_fazhen_view = self:FindObj("FaZhenView")
    self.bagpack_toggle = self:FindObj("BackpackButton")

    local model_display = self:FindObj("ModelDisplay")
    if model_display then
        self.role_model = RoleModel.New("son_skill_panel")
        self.role_model:SetDisplay(model_display.ui3d_display)
    end

    self.show_fight_out = self:FindVariable("ShowFightOut")
    self.show_effect = self:FindVariable("ShowEffect")
    self.show_bag_redpoint = self:FindVariable("ShowBagRedPoint")
    self.show_bag = self:FindVariable("ShowBag")
    self.show_read_lv = self:FindVariable("ShowReadLv")
    self.show_read_wuxin = self:FindVariable("ShowReadWuXin")
    self.total_power = self:FindVariable("TotalPower")
    self.bipin_redpoint = self:FindVariable("BiPinRedPoint")
    self.show_bipin_icon = self:FindVariable("ShowBiPingIcon")
    local is_get_reward = CompetitionActivityData.Instance:IsGetReward(TabIndex.spirit_spirit)
    local vis = CompetitionActivityData.Instance:GetBiPinRewardTips(TabIndex.spirit_spirit)
    self.show_bipin_icon:SetValue(vis and not is_get_reward)
    self.btn_tip_anim = self:FindObj("BtnTipAnim")
    self.btn_tip_anim_flag = true

    self.items = {}
    self.takeoff_image_list = {}
    self.show_fight_out_list = {}
    self.show_improve = {}
    for i = 1, 4 do
        local item_cell = ItemCell.New()
        item_cell:SetInstanceParent(self:FindObj("Item"..i))
        item_cell:SetToggleGroup(self:FindObj("ItemToggleGroup").toggle_group)
        self.items[i] = {item = self:FindObj("Item"..i), cell = item_cell}
        self.takeoff_image_list[i] = self:FindVariable("ShowClose"..i)
        self.show_fight_out_list[i] = self:FindVariable("ShowFightOut"..i)
        self.show_improve[i] = self:FindVariable("ShowImprove" .. i)
    end

    local list_delegate = self.bag_list_view.list_simple_delegate
    list_delegate.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
    list_delegate.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)

    -- local fazhen_list_delegate = self.fanzhen_list_view.list_simple_delegate
    -- fazhen_list_delegate.NumberOfCellsDel = BindTool.Bind(self.FaZhenGetNumberOfCells, self)
    -- fazhen_list_delegate.CellRefreshDel = BindTool.Bind(self.FaZhenRefreshCell, self)
    self.on_attr_view=true
    self.cur_click_index = 1
    self.show_spirit_index = 1
    self.fazhen_cells = {}
    self.spirit_cells = {}
    self.is_first = true
    self.fix_show_time = 8
    self.is_click_item = false
    self.res_id = 0
    self.temp_spirit_list = {}
    self.is_click_bag = false
    self.is_click_zhenfa = false
    self.effect_cd = 0
    self.old_count = 0
    self.click_num = 1
    self.delete_index = -1

    self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
    RemindManager.Instance:Bind(self.remind_change, RemindName.SpiritBag)
    RemindManager.Instance:Bind(self.remind_change, RemindName.SpiritHuanhua)
    self:FlushHuanHuaRedpoint()
end

function SonSpiritView:__delete()
    RemindManager.Instance:UnBind(self.remind_change, k)

    self.cur_bag_index = nil

    if self.fazhen_cells ~= nil then
        for k, v in pairs(self.fazhen_cells) do
            v:DeleteMe()
        end
    end
    if self.spirit_cells ~= nil then
        for k, v in pairs(self.spirit_cells) do
            v:DeleteMe()
        end
    end

    for k, v in pairs(self.items) do
        v.cell:DeleteMe()
    end
    self.items = {}

    if self.attr_view then
        self.attr_view:DeleteMe()
        self.attr_view = nil
    end

    if self.aptitude_view then
        self.aptitude_view:DeleteMe()
        self.aptitude_view = nil
    end

    if self.role_model then
        self.role_model:DeleteMe()
        self.role_model = nil
    end

    self.fazhen_cells = {}
    self.spirit_cells = {}
    self.is_first = nil
    self.cur_click_index = nil
    self.is_click_bag = nil
    self.temp_spirit_list = {}
    self.is_click_zhenfa = nil
    self.effect_cd = nil
    self.fix_show_time = nil
    self.res_id = nil
    self.model_display = nil
    self.click_num = nil
    self.delete_index = nil
    self.btn_tip_anim = nil
    self.btn_tip_anim_flag = nil
    self.bipin_redpoint = nil
    self.show_special_limt_time = nil
    self.show_special_effect = nil
    self:RemoveCountDown()
end

function SonSpiritView:OpenCallBack()
    self.is_first = true
    self.is_click_bag = false
    self.is_click_zhenfa = false
    self.temp_spirit_list = {}
    self:Flush()
    self:FlushBackPackState()
end

function SonSpiritView:CloseCallBack()
    GlobalTimerQuest:CancelQuest(self.time_quest)
    self.time_quest = nil
    self.res_id = 0
    self.is_first = true
end

function SonSpiritView:RemindChangeCallBack(remind_name, num)
    if RemindName.SpiritBag == remind_name then
        self.show_bag_redpoint:SetValue(num > 0)
    end
    self:FlushHuanHuaRedpoint()

end

-- 物品不足，购买成功后刷新物品数量
function SonSpiritView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
    self:FlushBagView()
end

function SonSpiritView:BagGetNumberOfCells()
    return BAG_MAX_GRID_NUM / BAG_ROW
end

function SonSpiritView:BagRefreshCell(cell, data_index)
    local group = self.spirit_cells[cell]
    if group == nil then
        group = SpiritBagGroup.New(cell.gameObject)
        self.spirit_cells[cell] = group
    end
    group:SetToggleGroup(self.bag_list_view.toggle_group)
    local page = math.floor(data_index / BAG_COLUMN)
    local column = data_index - page * BAG_COLUMN
    local grid_count = BAG_COLUMN * BAG_ROW
    for i = 1, BAG_ROW do
        local index = (i - 1) * BAG_COLUMN + column + (page * grid_count)
        local data = nil
        data = SpiritData.Instance:GetBagBestSpirit()[index + 1]
        data = data or {}
        data.locked = false
        if data.index == nil then
            data.index = index
        end
        group:SetData(i, data)
        group:ShowHighLight(i, not data.locked)
        group:SetHighLight(i, (self.cur_bag_index == index and nil ~= data.item_id))
        group:ListenClick(i, BindTool.Bind(self.HandleBagOnClick, self, data, group, i, index))
        group:SetInteractable(i, nil ~= data.item_id)
    end
end

function SonSpiritView:FlushBagView()
    -- self.bagpack_toggle.toggle.isOn = true
    if self.bag_list_view.scroller.isActiveAndEnabled then
        SpiritData.Instance:GetBagBestSpirit()
        self.cur_bag_index = -1
    end
    self.bag_list_view.scroller:RefreshActiveCellViews()

end

--点击格子事件
function SonSpiritView:HandleBagOnClick(data, group, group_index, data_index)
    local page = math.ceil((data.index + 1) / BAG_COLUMN)
    if data.locked then
        return
    end
    self.cur_bag_index = data_index
    group:SetHighLight(group_index, self.cur_bag_index == index)
    -- 弹出面板
    local item_cfg1, big_type1 = ItemData.Instance:GetItemConfig(data.item_id)
    local close_callback = function()
        group:SetHighLight(group_index, false)
        self.cur_bag_index = -1
    end
    if nil ~= item_cfg1 then
        TipsCtrl.Instance:OpenItem(data, TipsFormDef.FROM_SPIRIT_BAG, nil, close_callback)
    end
end

function SonSpiritView:OnClickSendMsg()
    if SpiritData.Instance:HasNotSprite() then
        TipsCtrl.Instance:ShowSystemMsg(Language.JingLing.PleaseEquipJingLing)
    end
    local name = ""
    local color = TEXT_COLOR.WHITE
    local spirit_info = SpiritData.Instance:GetSpiritInfo()
    local spirit_list = spirit_info.jingling_list
    local data_id = spirit_list[self.cur_click_index-1].item_id
    local btn_color = 0
    if nil == spirit_info or nil == next(spirit_info) or spirit_info.use_jingling_id <= 0 then return end

    -- 发送冷却CD
    if not ChatData.Instance:GetChannelCdIsEnd(CHANNEL_TYPE.WORLD) then
        local time = ChatData.Instance:GetChannelCdEndTime(CHANNEL_TYPE.WORLD) - Status.NowTime
        time = math.ceil(time)
        TipsCtrl.Instance:ShowSystemMsg(string.format(Language.Chat.SendFail, time))
        return
    end

    local item_cfg = ItemData.Instance:GetItemConfig(data_id)
    if nil ~= item_cfg then
        color = SOUL_NAME_COLOR_CHAT[item_cfg.color]
        name = item_cfg.name
        btn_color = item_cfg.color
    end

    local game_vo = GameVoManager.Instance:GetMainRoleVo()
    local content = string.format(Language.Chat.AdvancePreviewLinkList[7], game_vo.role_id, name, color, btn_color, CHECK_TAB_TYPE.SPIRIT)
    ChatCtrl.SendChannelChat(CHANNEL_TYPE.WORLD, content, CHAT_CONTENT_TYPE.TEXT)

    ChatData.Instance:SetChannelCdEndTime(CHANNEL_TYPE.WORLD)
    TipsCtrl.Instance:ShowSystemMsg(Language.Chat.SendSucc)
end

-- 点击精灵改名
function SonSpiritView:OnClickReName()
    local cost_num = SpiritData.Instance:GetSpiritOtherCfg().rename_cost
    local num_text = ToColorStr(cost_num .. "", TEXT_COLOR.BLUE_4)
    -- local des = string.format(Language.Common.IsXiaoHao, cost_num)
    local des_2 = Language.Common.ReSpiritName
    local callback = function(name)
        SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_RENAME,
        0, 0, 0, 0, name)
    end
    TipsCtrl.Instance:ShowRename(callback, false, nil, "", num_text)
end

function SonSpiritView:OnClickHelp()
    local tip_id = 40
    TipsCtrl.Instance:ShowHelpTipView(tip_id)
end

-- 一键回收
function SonSpiritView:OnClickOneKeyRecover()
    local func = function (is_recycle)
        local color = is_recycle and GameEnum.ITEM_COLOR_ORANGE or GameEnum.ITEM_COLOR_PURPLE
        SpiritCtrl.Instance:OneKeyRecoverSpirit(color)
    end
    TipsCtrl.Instance:ShowCommonTip(func, nil, Language.JingLing.OneKeyRecyle, nil, nil, false, false, nil, true, Language.JingLing.AutoRecyclePurple)
end

-- 一键装备
function SonSpiritView:OnClickOneKeyEquip()
    if self.delete_index ~= -1 then
        self.click_num = self.delete_index
        self.delete_index = -1
    end
    SpiritCtrl.Instance:AutoEquipOrChange()
end

-- 整理
function SonSpiritView:OnClickCleanBag()
    SpiritData.Instance:GetBagBestSpirit()
    self:FlushBagView()
end

function SonSpiritView:OnClickTakeOff(index)
	local  spirit_info = SpiritData.Instance:GetSpiritInfo()
    local spirit_list = spirit_info.jingling_list
    spirit_list = spirit_list or {}
    if spirit_list[index - 1] == nil then
        return
    end
    local item_cfg = ItemData.Instance:GetItemConfig(spirit_list[index - 1].item_id)
    if not item_cfg then return end
    if spirit_info.use_jingling_id == spirit_list[index-1].item_id then
        self:FightOutNext(index - 1)
    else
        if self.click_num == index then
            if self.temp_spirit_list[0] and self.temp_spirit_list[0].item_id == spirit_info.use_jingling_id then
                self:OnClickItem( 1, self.items[1].cell)
            else
                for i, v in pairs(self.temp_spirit_list) do
                    if v.item_id and v.item_id == spirit_info.use_jingling_id then
                        self:OnClickItem(i + 1, self.items[i + 1].cell)
                        break
                    end
                end
            end

        end
    end
    SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_TAKEOFF,
    index - 1, 0, 0, 0, item_cfg.name)
    self.on_take_off = true
    self:FlushBagView()
    if self.delete_index < index then
        self.delete_index = index
    end
    self:FlushBackPackState()
end



-- 法阵列表
function SonSpiritView:FaZhenGetNumberOfCells()
    return #SpiritData.Instance:GetSpiritGroupCfg()
end

function SonSpiritView:FaZhenRefreshCell(cell, data_index)
    local group_list = SpiritData.Instance:GetSpiritGroupCfg()

    local temp_data = group_list[data_index + 1]
    local data = SpiritData.Instance:GetSpiritGroup()[temp_data.id]
    local fazhen_cell = self.fazhen_cells[cell]
    if fazhen_cell == nil then
        fazhen_cell = SpiritFaZhenList.New(cell.gameObject)
        self.fazhen_cells[cell] = fazhen_cell
    end
    fazhen_cell:SetData(data)
end

function SonSpiritView:FlushFaZhenView()
    -- if self.fanzhen_list_view.scroller.isActiveAndEnabled then
    --     self.fanzhen_list_view.scroller:ReloadData(0)
    -- end
end
function SonSpiritView:FlushPanelInfoState()
    if self.on_take_off == true then
        self.on_take_off = false
    end

    local spirit_info = SpiritData.Instance:GetSpiritInfo()
    local first_index = {}
    if next(self.temp_spirit_list) then
        if self.show_backpack_view.gameObject.activeSelf == false then
            self.show_attr_view:SetActive(self.on_attr_view)
            self.attr_view:CloseCallBack(self.on_attr_view)
            self.show_aptitude_view:SetActive(not self.on_attr_view)
            self.aptitude_view:CloseCallBack(not self.on_attr_view)
            self.show_bag:SetValue(true)
            return
        end
        for i = 0, 3 do
            if self.temp_spirit_list[i] then
                table.insert(first_index, i)
                if self.temp_spirit_list[i].item_id == spirit_info.use_jingling_id then
                    self:OnClickItem(i + 1, self.items[i + 1].cell)
                    return
                end
            end
        end
        local index = first_index[1]
        self:OnClickItem(index + 1, self.items[index + 1].cell)
    else
        self:SetBackPackState(true)
        self:FlushBagView()
        self.show_bag:SetValue(false)
    end
end

function SonSpiritView:FlushBackPackState()
    if self.on_take_off == true then
        self.on_take_off = false
    end

    local spirit_info = SpiritData.Instance:GetSpiritInfo()
    local first_index = {}
    if next(self.temp_spirit_list) then
        if self.show_backpack_view.gameObject.activeSelf == false then
            self.show_attr_view:SetActive(self.on_attr_view)
            self.attr_view:CloseCallBack(self.on_attr_view)
            self.show_aptitude_view:SetActive(not self.on_attr_view)
            self.aptitude_view:CloseCallBack(not self.on_attr_view)
            self.show_bag:SetValue(true)
            for i = 0, 3 do
                if self.temp_spirit_list[i] and self.temp_spirit_list[i].item_id == spirit_info.use_jingling_id then
                    if self.click_num == i + 1 then
                        self.items[i + 1].cell:SetHighLight(true)
                        return
                    end
                end
            end
        end
        for i = 0, 3 do
            if self.temp_spirit_list[i] then
                table.insert(first_index, i)
                if self.temp_spirit_list[i].item_id == spirit_info.use_jingling_id then
                    self:OnClickItem(self.click_num, self.items[self.click_num].cell)
                    return
                end
            end
        end
        local index = first_index[1]
        self:OnClickItem(index + 1, self.items[index + 1].cell)
    else
        self:SetBackPackState(true)
        self:FlushBagView()
        self.show_bag:SetValue(false)
    end
end

function SonSpiritView:SetBackPackState(enable)
    self.backpack_open_flag = enable
    self.show_backpack_view:SetActive(enable)
    self.show_attr_view:SetActive(not enable)
    self.attr_view:CloseCallBack(not enable)
    self.show_aptitude_view:SetActive(not enable)
    self.aptitude_view:CloseCallBack(not enable)
    -- self.show_fazhen_view:SetActive(not enable)
end

function SonSpiritView:SetModleRestAni()
    self.timer = self.fix_show_time
    if not self.time_quest then
        self.time_quest = GlobalTimerQuest:AddRunQuest(function()
            if not self.timer then
                return
            end
            self.timer = self.timer - UnityEngine.Time.deltaTime
            if self.timer <= 0 then
                if self.role_model then
                    self.role_model:SetTrigger("rest")
                end
                self.timer = self.fix_show_time
            end
        end, 0)
    end
end

function SonSpiritView:ChangeModel(bundle, asset)
    local function call_back()
        -- local cfg = model:GetModelDisplayParameterCfg(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.SPIRIT], spirit_cfg.res_id)
        -- if root then
        --     if cfg then
        --         root.transform.localPosition = cfg.position
        --         root.transform.localRotation = Quaternion.Euler(cfg.rotation.x, cfg.rotation.y, cfg.rotation.z)
        --         root.transform.localScale = cfg.scale
        --     else
        --         root.transform.localPosition = Vector3(0, 0, 0)
        --         root.transform.localRotation = Quaternion.Euler(0, 0, 0)
        --         root.transform.localScale = Vector3(1, 1, 1)
        --     end
        -- end
        self:SetModleRestAni()
    end
    if self.role_model then
        self.role_model:SetMainAsset(bundle, asset, call_back)
        self.role_model:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.SPIRIT], asset, DISPLAY_PANEL.SEVEN_DAY_LOGIN)
    end
end

function SonSpiritView:OnClickItem(index, cell)
    self.click_num = index
    self.show_spirit_index = index

    -- self.show_read_lv:SetValue(level)
    -- self.show_read_wuxin:SetValue(wuxin)
    local spirit_info = SpiritData.Instance:GetSpiritInfo()
    local spirit_list = spirit_info.jingling_list
    local data = spirit_list[index-1] or {}
    local item_cfg, big_type = ItemData.Instance:GetItemConfig(data.item_id)
    local spirit_level_cfg = SpiritData.Instance:GetSpiritLevelCfgByLevel(data.index)
    local vo = GameVoManager.Instance:GetMainRoleVo()
    -- SpiritCtrl.Instance:FlushSpiritTopButton(self.on_attr_view)
    -- self.show_attr_view:SetActive(self.on_attr_view)
    -- self.show_aptitude_view:SetActive(not self.on_attr_view)
    -- self.show_backpack_view:SetActive(false)
    -- self.show_fazhen_view:SetActive(false)
    self.show_spirit_name:SetValue(item_cfg ~= nil)
    if nil ~= item_cfg and spirit_level_cfg ~= nil then
        self.cur_data = data
        local name_str = ""
        if spirit_info.use_jingling_id > 0 and spirit_info.jingling_name ~= "" then
            name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color] .. ">"..spirit_info.jingling_name.."</color>"
        else
            name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color] .. ">"..item_cfg.name.."</color>"
        end
        self.spirit_name:SetValue(name_str)
        self.spirit_level:SetValue(spirit_list[index - 1].param.rand_attr_val_1)

        local cost = spirit_level_cfg.cost_lingjing
        local count = vo.lingjing
        local progress_pre = cost > count and count or cost
        self.progress_pre:SetValue(progress_pre)
        self.cur_progress:SetValue(data.param.param3)
        self.progress:SetValue(data.param.param3 / cost)

        if cost > 99999 and cost <= 99999999 then
            cost = cost / 10000
            cost = math.floor(cost)
            cost = cost .. Language.Common.Wan
        elseif cost > 99999999 then
            cost = cost / 100000000
            cost = math.floor(cost)
            cost = cost .. Language.Common.Yi
        end
        self.need_num:SetValue(cost)


        if count > 99999 and count <= 99999999 then
            count = count / 10000
            count = math.floor(count)
            count = count .. Language.Common.Wan
        elseif count > 99999999 then
            count = count / 100000000
            count = math.floor(count)
            count = count .. Language.Common.Yi
        end
        self.have_num:SetValue(count)

        self.attr_view:SetSpiritAttr(data)
        local spirit_cfg = SpiritData.Instance:GetSpiritResIdByItemId(self.cur_data.item_id)
        if spirit_cfg.res_id ~= self.res_id then
            local bundle, asset = ResPath.GetSpiritModel(spirit_cfg.res_id)
            self:ChangeModel(bundle, asset)
            self.res_id = spirit_cfg.res_id
        end

        self.cur_click_index = index
    end
    if spirit_info.use_jingling_id == data.item_id then
        self.state_text:SetValue(Language.Common.CallBack)
    else
        self.state_text:SetValue(Language.Common.OutFight)
    end
    self.show_fight_out:SetValue(spirit_info.use_jingling_id ~= data.item_id)
    for k,v in pairs(self.items) do
        v.cell:SetHighLight(index == k)

    end
    self.show_uplevel_btn:SetValue(SpiritData.Instance:GetStrenthMaxLevelByid(self.cur_click_index - 1))

    self.show_uplevel_use:SetValue(spirit_list[self.cur_click_index - 1] ~= nil)
    self.is_click_item = true
    -- self.is_click_bag = false
    self.is_click_zhenfa = false
    -- self.show_bag:SetValue(true)
    self.aptitude_view:FlushData(self.cur_click_index and spirit_list[self.cur_click_index - 1] or {})
    self:FlushTotlePower()
end

function SonSpiritView:OnClickBackPack()
	if self.is_click_bag then
		self:OnClickReturn()
	else
		self.is_click_item = false
		self.show_attr_view:SetActive(false)
        self.attr_view:CloseCallBack(false)
		self.show_aptitude_view:SetActive(false)
        self.aptitude_view:CloseCallBack(false)
		SpiritCtrl.Instance:FlushSpiritTopButton(false)
		self.show_backpack_view:SetActive(true)
		self.backpack_open_flag = true
		-- self.show_fazhen_view:SetActive(false)
		if not self.is_click_bag then
			self:FlushBagView()
		end
		self.is_click_bag = true
		self.is_click_zhenfa = false
		self.show_bag:SetValue(false)
		self:FlushBackPackState()
	end
end

function SonSpiritView:OnClickHuanHua()
    self.is_click_item = false
    ViewManager.Instance:Open(ViewName.SpiritHuanHuaView)
end

function SonSpiritView:OnClickFaZhen()
    self.is_click_item = false
    if #SpiritData.Instance:GetSpiritGroupCfg() <= 0 then
        TipsCtrl.Instance:ShowSystemMsg(Language.JingLing.NoEquipJingLing)
        return
    end
    self.show_attr_view:SetActive(false)
    self.attr_view:CloseCallBack(false)
    self.show_aptitude_view:SetActive(false)
    self.aptitude_view:CloseCallBack(false)
    SpiritCtrl.Instance:FlushSpiritTopButton(false)
    self.show_backpack_view:SetActive(false)
    self.backpack_open_flag = false
    -- self.show_fazhen_view:SetActive(true)
    -- if self.fanzhen_list_view.scroller.isActiveAndEnabled and not self.is_click_zhenfa then
    --     self.fanzhen_list_view.scroller:ReloadData(0)
    -- end
    self.is_click_bag = false
    self.is_click_zhenfa = true
end

-- 出战、召回
function SonSpiritView:OnClickZhaoHui()
    local spirit_info = SpiritData.Instance:GetSpiritInfo()
    if self.cur_click_index == nil or self.cur_data == nil or spirit_info == nil then
        return
    end
    local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.cur_data.item_id)
    if spirit_info.use_jingling_id == self.cur_data.item_id then
        if spirit_info.count ~= 1 then
            SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_CALLBACK,
            self.cur_click_index - 1, 0, 0, 0, item_cfg.name)
            self:FightOutNext(self.cur_click_index-1)
            GlobalTimerQuest:CancelQuest(self.time_quest)
            self.time_quest = nil
        else
            TipsCtrl.Instance:ShowSystemMsg(Language.JingLing.MustFightOut)
        end
    else
        SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_FIGHTOUT,
        self.cur_click_index - 1, 0, 0, 0, item_cfg.name)
    end
end

function SonSpiritView:FightOutNext(cur_index)
    for i = 0, 3 do
        if self.temp_spirit_list[i] and i ~= cur_index then
            SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_FIGHTOUT,
            i, 0, 0, 0, self.temp_spirit_list[i].name)
            self.click_num = i + 1
            self:OnClickItem(i + 1, self.items[i + 1].cell)
            return
        end
    end

end

function SonSpiritView:OnClickUpgrade()
    local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.cur_data.item_id)
    local  vo = GameVoManager.Instance:GetMainRoleVo()
    if vo.lingjing == 0 then
        local id = 90011    -- 灵晶id
        -- TipsCtrl.Instance:ShowSystemMsg(Language.JingLing.LingJIngLack)
		TipsCtrl.Instance:ShowItemGetWayView(id)
    end
    SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_UPLEVEL,
    self.cur_click_index - 1, 0, 0, 0, item_cfg.name)
end

function SonSpiritView:FlushHuanHuaRedpoint()
    self.show_spirit_huanhua:SetValue(next(SpiritData.Instance:ShowHuanhuaRedPoint()) ~= nil)
end

function SonSpiritView:FlushSpecialBtton()
    local index = 1                        --特殊精灵在配置表的第一个
    local spirit_cfg = SpiritData.Instance:GetSingleSpecialSpiritCfgByIndex(index)
    --特殊精灵幻化id
    local special_index = SpiritData.Instance:GetSpecialSpiritHuanHuaId()
    --特殊精灵幻化信息
    local huanhua_cfg = SpiritData.Instance:GetSpecialSpiritImageCfg(special_index)
    if huanhua_cfg == nil then
        return
    end
    local fetch_flag = SpiritData.Instance:GetSpecialSpiritFetchFlag(index)
    local can_fetch = SpiritData.Instance:GetSpecialSpiritActiveCard(index)
    local limit_time = SpiritData.Instance:GetSpecialSpiritFreeTime(index) 
    local speical_item_id = huanhua_cfg.item_id
    local active_flag = SpiritData.Instance:GetSpecialSpiritActiveFlag()
    --背包
    local has_card_in_bag = ItemData.Instance:GetItemIndex(speical_item_id)
    --免费时间
    self.show_special_limt_time:SetValue(active_flag == false and limit_time > 0 and has_card_in_bag == -1 and can_fetch == false and fetch_flag == false)
    --特效
    self.show_special_effect:SetValue(active_flag)
    --头像
    self.special_spirit_icon:SetAsset(ResPath.GetItemIcon(huanhua_cfg.item_id))
    local add_attr = spirit_cfg.add_attr_per
    self.add_attr_per:SetValue(add_attr/100)
end

function SonSpiritView:ShowSpecialButton()
   local show_spirit_btn = SpiritData.Instance:GetLittleTargetActiveFlag()
   self.show_specia_btn:SetValue(show_spirit_btn)
   local title_cfg = SpiritData.Instance:GetSingleSpecialSpiritCfgByIndex(2)
   local can_fetch_title = SpiritData.Instance:GetSpecialSpiritActiveCard(2)
   local limit_time = SpiritData.Instance:GetSpecialSpiritFreeTime(2)
   if title_cfg == nil then return end
   --称号显示
    local title_special_cfg = ItemData.Instance:GetItemConfig(title_cfg.special_item.item_id)
    if title_special_cfg == nil then
        return 0
    end
   local power = title_special_cfg.power or 0
   self.show_title_time:SetValue( limit_time > 0 and can_fetch_title == false)
   self.title_gray:SetValue(can_fetch_title == true)
   self.title_power:SetValue(power)
   local bundle,asset = ResPath.GetTitleIcon(title_cfg.param_0)
   self.title_asset:SetAsset(bundle,asset)
end

function SonSpiritView:OnFlush()
    self:FlushSpecialBtton()
    self:ShowSpecialButton()
    self.cur_data = nil
    local vo = GameVoManager.Instance:GetMainRoleVo()
    local spirit_info = SpiritData.Instance:GetSpiritInfo()
    local spirit_list = spirit_info.jingling_list or {}
    local is_flush_bag = false
    
    for i=1,4 do
        self.show_improve[i]:SetValue((spirit_list[i - 1] ~= nil) and (SpiritData.Instance:CanUpgrade() or SpiritData.Instance:CanUpgradeWuxing()))
    end
    for k, v in pairs(self.items) do
        if v.cell:GetData().item_id then
            if spirit_list[k - 1] == nil then
                if self.cur_click_index == k then
                    if self.role_model then
                        self.role_model:ClearModel()
                    end
                    self.res_id = 0
                end
                v.cell:SetData({})
                v.cell:ClearItemEvent()
                v.cell:SetInteractable(false)
                v.cell:SetHighLight(false)
                -- print_error("kkkk",k)
            else
                if v.cell:GetData().param.strengthen_level < spirit_list[k - 1].param.strengthen_level then
                    if self.effect_cd and self.effect_cd - Status.NowTime <= 0 then
                        AudioService.Instance:PlayAdvancedAudio()
                        EffectManager.Instance:PlayAtTransformCenter(
                            "effects2/prefab/ui_x/ui_sjcg_prefab",
                            "UI_sjcg",
                            self.effect_root.transform,
                        2.0)
                        self.effect_cd = Status.NowTime + EFFECT_CD
                    end
                end
                if v.cell:GetData().param.param1 < spirit_list[k - 1].param.param1 then
                    if
                        self.effect_cd and self.effect_cd - Status.NowTime <= 0 then
                        AudioService.Instance:PlayAdvancedAudio()
                        EffectManager.Instance:PlayAtTransformCenter(
                            "effects2/prefab/ui_x/ui_sjcg_prefab",
                            "UI_sjcg",
                            self.effect_root.transform,
                        2.0)
                        self.effect_cd = Status.NowTime + EFFECT_CD
                    end
                end
                v.cell:IsDestroyEffect(false)
                v.cell:SetData(spirit_list[k - 1])
                v.cell:SetHighLight(self.cur_click_index == k)
            end

        elseif spirit_list[k - 1] and nil == v.cell:GetData().item_id then
            if vo.used_sprite_id == spirit_list[k - 1].item_id and self.is_first then
                self.cur_click_index = k
            elseif (not self.cur_click_index and spirit_list[k - 1]) or (not self.temp_spirit_list[k - 1] and spirit_list[k - 1] and not self.is_first) then
                self.cur_click_index = k
            end
            v.cell:SetData(spirit_list[k - 1])
            v.cell:ListenClick(BindTool.Bind(self.OnClickItem, self, k, v.cell))
            v.cell:SetInteractable(true)
            v.cell:SetHighLight(self.cur_click_index == k)
        else
            v.cell:SetData({})
            v.cell:SetInteractable(false)
        end
        self.takeoff_image_list[k]:SetValue(spirit_list[k - 1] ~= nil)
    end

    --特殊伙伴按钮信息刷新
    local index = 1
    local free_remind_time = SpiritData.Instance:GetSpecialSpiritFreeTime(index)
    if free_remind_time <= 0 then
        self.show_special_limt_time:SetValue(false) 
    else
        self:RemoveCountDown()
        self.count_down = CountDown.Instance:AddCountDown(free_remind_time, 1, BindTool.Bind(self.FlushCountDown, self))
    end

    --刷新提升箭头
    local level = false
    local wuxin = false
    for i=1,4 do
        local level_can_show = SpiritData.Instance:CanUpgradeByID(i - 1) and not SpiritData.Instance:IsMaxLevel(i - 1)   --and self.on_attr_view == false
        local wuxing_can_show = SpiritData.Instance:CanUpgradeWuxingByIndex(i - 1) and not SpiritData.Instance:IsMaxWuXing(i -1)  --and self.on_attr_view == true
        if level_can_show and self.show_spirit_index == i then
            level = true
        end
        if wuxing_can_show and self.show_spirit_index == i then
            wuxin = true
        end
        -- self.show_improve[i]:SetValue(level_can_show or wuxing_can_show)
    end

    if self.cur_click_index and spirit_list[self.cur_click_index - 1] then
        local spirit_level_cfg = SpiritData.Instance:GetSpiritLevelCfgByLevel(spirit_list[self.cur_click_index - 1].index)
        local item_cfg, big_type = ItemData.Instance:GetItemConfig(spirit_list[self.cur_click_index - 1].item_id)
        local name_str = ""
        if spirit_info.use_jingling_id > 0 and spirit_info.jingling_name ~= "" then
            name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color] .. ">"..spirit_info.jingling_name.."</color>"
        else
            name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color] .. ">"..item_cfg.name.."</color>"
        end

        self.spirit_name:SetValue(name_str)
        self.spirit_level:SetValue(spirit_list[self.cur_click_index - 1].param.rand_attr_val_1)
        local cost = spirit_level_cfg.cost_lingjing
        local count = vo.lingjing
        local  progress_pre = cost > count and count or cost
        self.progress_pre:SetValue(progress_pre)
        self.cur_progress:SetValue(spirit_list[self.cur_click_index - 1].param.param3)
        self.progress:InitValue(spirit_list[self.cur_click_index - 1].param.param3 / cost)
        if cost > 99999 and cost <= 99999999 then
            cost = cost / 10000
            cost = math.floor(cost)
            cost = cost .. Language.Common.Wan
        elseif cost > 99999999 then
            cost = cost / 100000000
            cost = math.floor(cost)
            cost = cost .. Language.Common.Yi
        end
        self.need_num:SetValue(cost)

        if count > 99999 and count <= 99999999 then
            count = count / 10000
            count = math.floor(count)
            count = count .. Language.Common.Wan
        elseif count > 99999999 then
            count = count / 100000000
            count = math.floor(count)
            count = count .. Language.Common.Yi
        end
        -- if vo.lingjing < spirit_level_cfg.cost_lingjing then
        --     self.have_num:SetValue(string.format(Language.Mount.ShowRedNum, count))
        -- else
        self.have_num:SetValue(count)

        -- end
        self.cur_data = spirit_list[self.cur_click_index - 1]
    end

    for k, v in pairs(self.show_fight_out_list) do
        v:SetValue(spirit_list[k - 1] and spirit_list[k - 1].item_id == spirit_info.use_jingling_id or false)
    end

    self.show_spirit_name:SetValue(self.cur_click_index and spirit_list[self.cur_click_index - 1] ~= nil or false)
    self.show_uplevel_btn:SetValue(SpiritData.Instance:GetStrenthMaxLevelByid(self.cur_click_index - 1))
    self.show_uplevel_use:SetValue(self.cur_click_index and spirit_list[self.cur_click_index - 1] ~= nil or false)
    self.attr_view:SetSpiritAttr(self.cur_click_index and spirit_list[self.cur_click_index - 1] or {})
    self.aptitude_view:FlushData(self.cur_click_index and spirit_list[self.cur_click_index - 1] or {})
    if self.cur_data ~= nil then
        if spirit_info.use_jingling_id == self.cur_data.item_id then
            self.state_text:SetValue(Language.Common.CallBack)
            self.state_text:SetValue(Language.Common.OutFight)
        end
        self.show_fight_out:SetValue(spirit_info.use_jingling_id ~= self.cur_data.item_id)
        local spirit_cfg = SpiritData.Instance:GetSpiritResIdByItemId(self.cur_data.item_id)
        if spirit_cfg and spirit_cfg.res_id and spirit_cfg.res_id > 0 then
            if self.res_id ~= spirit_cfg.res_id then
                local bundle, asset = ResPath.GetSpiritModel(spirit_cfg.res_id)
                self:ChangeModel(bundle, asset)
                self.res_id = spirit_cfg.res_id
            end
        end
        self.show_fight_out:SetValue(SpiritData.Instance:GetSpiritListLength() ~= 0 and spirit_info.use_jingling_id ~= self.cur_data.item_id)
    end

    -- 自动出战
    if not next(self.temp_spirit_list) and not self.is_first then
        for k, v in pairs(spirit_list) do
            local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
            SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_FIGHTOUT,
            k, 0, 0, 0, item_cfg.name)
            break
        end
    end

    for k, v in pairs(self.temp_spirit_list) do
        if not spirit_list[k] then
            is_flush_bag = true
            break
        elseif spirit_list[k].item_id ~= v.item_id then
            is_flush_bag = true
            break
        end
    end
    self.temp_spirit_list = spirit_list

    if self.is_first or is_flush_bag then
        self:FlushBagView()
        self:FlushFaZhenView()
    end

    self.is_first = false
    if spirit_info.count < self.old_count and self.show_backpack_view.gameObject.activeSelf == false then
        self:FlushBackPackState()
    end

    self.old_count = spirit_info.count

    --刷新总战力
    self:FlushTotlePower()

    -- 刷新成长和悟性红点
    self.show_read_lv:SetValue(SpiritData.Instance:CanUpgrade())
    self.show_read_wuxin:SetValue(SpiritData.Instance:CanUpgradeWuxing())

    local is_get_reward = CompetitionActivityData.Instance:IsGetReward(TabIndex.spirit_spirit)
    local vis = CompetitionActivityData.Instance:GetBiPinRewardTips(TabIndex.spirit_spirit)
    self.show_bipin_icon:SetValue(vis and not is_get_reward)
    local bp_redpoint = CompetitionActivityData.Instance:GetIsShowRedptByTabIndex(TabIndex.spirit_spirit)
    self.bipin_redpoint:SetValue(bp_redpoint)

    local cfg = SpiritData.Instance:GetSpiritResourceCfg()
    if SpiritData.Instance:GetSpiritListLength() == 1 then
        for k,v in pairs(spirit_list) do
            if v.item_id then
                SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_FIGHTOUT,
                v.index, 0, 0, 0, SpiritData.Instance:GetSpiritNameById(v.item_id))
                return
            end
        end
    end
end

function SonSpiritView:RemoveCountDown()
    if CountDown.Instance:HasCountDown(self.count_down) then
        CountDown.Instance:RemoveCountDown(self.count_down)
        self.count_down = nil
    end
end

function SonSpiritView:FlushCountDown(elapse_time, total_time)
    local time_interval = total_time - elapse_time
    if time_interval > 0 then
        self:SetTime(time_interval)
    else
        self.show_special_limt_time:SetValue(false)
    end
end

--设置时间
function SonSpiritView:SetTime(time)
    local show_time_str = ""
    if time > 3600 * 24 then
        show_time_str = TimeUtil.FormatSecond(time, 7)
    elseif time > 3600 then
        show_time_str = TimeUtil.FormatSecond(time, 1)
    else
        show_time_str = TimeUtil.FormatSecond(time, 4)
    end
    self.limit_free_time:SetValue(show_time_str)
end

function SonSpiritView:OnClickReturn()

    if SpiritData.Instance:HasNotSprite() then
        TipsCtrl.Instance:ShowSystemMsg(Language.JingLing.PleaseEquipJingLing)
        return
    end
    self:FlushBackPackState()
    self.show_bag:SetValue(true)
    SpiritCtrl.Instance:FlushSpiritTopButton(self.on_attr_view)
    self.show_attr_view:SetActive(self.on_attr_view)
    self.attr_view:CloseCallBack(self.on_attr_view)
    self.show_aptitude_view:SetActive(not self.on_attr_view)
    self.aptitude_view:CloseCallBack(not self.on_attr_view)
    self.show_backpack_view:SetActive(false)
		self.is_click_bag = false
    -- self.show_fazhen_view:SetActive(false)
end

function  SonSpiritView:OpenTagView(enable)
    if self.on_attr_view == enable then
        return
    end
    self.on_attr_view = enable
    -- if not self:GetBagView() then
    if SpiritData.Instance:HasNotSprite() then
        return
    end
	self:FlushPanelInfoState()
    self:Flush()
    -- end
end

function  SonSpiritView:OnClickBiPingReward()
     if self.btn_tip_anim_flag then
        self.btn_tip_anim.animator:SetBool("isClick", false)
    end
   ViewManager.Instance:Open(ViewName.CompetitionTips)
end

function SonSpiritView:OnClickSpecial()
    ViewManager.Instance:Open(ViewName.SpiritSpecialView)
end

function SonSpiritView:OnClickSpecialTitle()
    local title_cfg = SpiritData.Instance:GetSingleSpecialSpiritCfgByIndex(2)
    if title_cfg == nil then
        return
    end
    local can_fetch = SpiritData.Instance:GetSpecialSpiritActiveCard(title_cfg.special_item_index + 1)
    local time_stamp = SpiritData.Instance:GetSpecialSpiritFreeTime(2)
    local function fetch_callback()
        if can_fetch == false then
            SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_SPECIAL_JINGLING_BUY,title_cfg.special_item_index)
        else
            SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_SPECIAL_JINGLING_FETCH,title_cfg.special_item_index)
        end
    end

    local spirit_target_info = CommonStruct.TimeLimitTitleInfo()
    spirit_target_info.item_id = title_cfg.special_item.item_id
    spirit_target_info.cost = title_cfg.cost
    spirit_target_info.left_time = time_stamp or 0
    spirit_target_info.can_fetch = can_fetch == true
    spirit_target_info.from_panel = "specialspirit"
    spirit_target_info.call_back = fetch_callback
    TipsCtrl.Instance:ShowTimeLimitTitleView(spirit_target_info)
end

function SonSpiritView:GetBagView()
	return self.show_backpack_view.gameObject.activeSelf
end

function SonSpiritView:FlushTotlePower()
    -- CommonDataManager.GetCapabilityCalculation(SpiritData.Instance:GetZhenfaAttrList())
    local capability = self.attr_view:GetNewFightPower() + self.aptitude_view:GetFightPower()
    self.total_power:SetValue(capability)
end

-- 精灵属性
SpiritAttrView = SpiritAttrView or BaseClass(BaseRender)

function SpiritAttrView:__init(instance)
    self.base_attr_list = {}
    self.talent_attr_list = {}
    for i = 1, 7 do
        self.base_attr_list[i] = {name = self:FindVariable("BaseAttrName"..i), value = self:FindVariable("BaseAttrValue"..i),
            is_show = self:FindVariable("ShowBaseAttr"..i), next_value = self:FindVariable("BaseAttrNextValue"..i),
        show_image = self:FindVariable("ShowUpImag"..i), show_next_value = self:FindVariable("ShowNextAttr"..i)}
    end
    for i = 1, 4 do
        self.talent_attr_list[i] = {name = self:FindVariable("TalentAttrName"..i), value = self:FindVariable("TalentAttrValue"..i),
            is_show = self:FindVariable("ShowTalentAttr"..i), icon = self:FindVariable("TalentAttrIcon"..i),
        }
    end

    self.fight_power = self:FindVariable("FightPower")

    self.spirit_name = self:FindVariable("SpiritName")

    self.lv = self:FindVariable("SpiritLevel")

    self.cur_spirit_level = self:FindVariable("CurSpiritLevel")
    self.need_spirit_level = self:FindVariable("NeedSpiritLevel")
    self.skill_num = self:FindVariable("SkillNum")
    self.show_limit = self:FindVariable("ShowLimit")
    self.next_skill = self:FindVariable("NextSkill")
end

function SpiritAttrView:__delete()

end

local sort_t = {
        gongji = 1,
        fangyu = 2,
        maxhp = 3,
    }
function SpiritAttrView:SetSpiritAttr(data)
    if data == nil or data.param == nil then return end
    local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
    local spirit_info = SpiritData.Instance:GetSpiritInfo()
    local spirit_level_cfg = SpiritData.Instance:GetSpiritLevelCfgByLevel(data.index)
    local attr = CommonDataManager.GetAttributteNoUnderline(spirit_level_cfg)
    local talent_attr = SpiritData.Instance:GetSpiritTalentAttrCfgById(data.item_id)
    local had_base_attr = {}
    local wuxing = data.param.param1

    if item_cfg and spirit_level_cfg then
        local spirit_next_level_cfg = SpiritData.Instance:GetSpiritLevelCfgByLevel(data.index, spirit_info.jingling_list[data.index].param.strengthen_level + 1)
        local next_attr = CommonDataManager.GetAttributteNoUnderline(spirit_next_level_cfg, true)
        for k, v in pairs(attr) do
            if v > 0 then
                if next_attr[k] and next_attr[k] > 0 then
                    table.insert(had_base_attr, {key = k, value = v, next_value = next_attr[k]})
                else
                    table.insert(had_base_attr, {key = k, value = v, next_value = 0})
                end
            end
        end

        table.sort(had_base_attr, function (a, b)
            local a_value = sort_t[a.key] or 100
            local b_value = sort_t[b.key] or 100
            return a_value < b_value
        end)
        local aptitude = {}
        for i=1,3 do
        	table.insert(aptitude,talent_attr[APTITUDE_TYPE[i]])
        end
        local attr_after_aptitude = {}
        if next(had_base_attr) then
            for k, v in pairs(self.base_attr_list) do
                v.is_show:SetValue(had_base_attr[k] ~= nil)
                if had_base_attr[k] ~= nil then
                    v.name:SetValue(Language.Common.SpiritAttrNameNoUnderline[had_base_attr[k].key])
                    local value = SpiritData.Instance:GetAttrByAptitude(had_base_attr[k].value,aptitude[k],wuxing,APTITUDE_TYPE[k])
                    v.value:SetValue(value)

                    if spirit_info.jingling_list[data.index].param.strengthen_level + 1 <= SpiritData.Instance:GetMaxSpiritUplevel(data.item_id) then
                        v.show_image:SetValue(true)
                        v.show_next_value:SetValue(true)
                        local next_value = SpiritData.Instance:GetAttrByAptitude(had_base_attr[k].next_value,aptitude[k],wuxing,APTITUDE_TYPE[k])
                        v.next_value:SetValue(next_value)
                    else
                        v.show_image:SetValue(false)
                        v.show_next_value:SetValue(false)
                    end
                    attr_after_aptitude[ATTR_TYPE[k]] = value
                end
            end
        end
        for k, v in pairs(self.talent_attr_list) do
            v.is_show:SetValue(false)
        end
        if data.param then
            local bundle_t, asset_t = nil, nil
            if next(data.param.xianpin_type_list) then
                for k, v in pairs(data.param.xianpin_type_list) do
                    local cfg = SpiritData.Instance:GetSpiritTalentAttrCfgById(data.item_id)
                    if self.talent_attr_list[k] then
                        if cfg["type"..v] then
                            self.talent_attr_list[k].name:SetValue(JINGLING_TALENT_ATTR_NAME[JINGLING_TALENT_TYPE[v]])
                            self.talent_attr_list[k].value:SetValue(cfg["type"..v] / 100)
                            self.talent_attr_list[k].is_show:SetValue(true)
                            bundle_t, asset_t = ResPath.GetImages(SPIRIT_TALENT_ICON_LIST[v], "icon_atlas")
                            self.talent_attr_list[k].icon:SetAsset(bundle_t, asset_t)
                        else
                            print_error("Spirit Talent Cfg No Attr Type :", "type"..v)
                        end
                    end
                end
            end
        end
        local fight_power = CommonDataManager.GetCapabilityCalculation(attr_after_aptitude)
        self.fight_power:SetValue(fight_power)
        local name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color] .. ">"..item_cfg.name.."</color>"
        self.spirit_name:SetValue(name_str)
        self.lv:SetValue(data.param.rand_attr_val_1)
        local max_skill= SpiritData.Instance:GetMaxSkillNumByID(data.item_id) ==  spirit_level_cfg.skill_num
        self.show_limit:SetValue(not max_skill)
        local cur_level = "<color="..TEXT_COLOR.RED ..">" .. data.param.rand_attr_val_1 .. "</color>"
        local next_level = SpiritData.Instance:GetSkillNumNextLevelById(data.item_id,spirit_level_cfg.skill_num)
        self.cur_spirit_level:SetValue(cur_level)
        self.need_spirit_level:SetValue(next_level)
        self.skill_num:SetValue(spirit_level_cfg.skill_num)
        self.next_skill:SetValue(spirit_level_cfg.skill_num + 1)
    end
end

function SpiritAttrView:GetFightPower()
    if self.fight_power then
        return self.fight_power:GetInteger()
    end
    return 0
end


-- 背包格子
SpiritBagGroup = SpiritBagGroup or BaseClass(BaseRender)

function SpiritBagGroup:__init(instance)
    self.cells = {}
    for i = 1, BAG_ROW do
        self.cells[i] = ItemCell.New()
        self.cells[i]:SetInstanceParent(self:FindObj("Item"..i))
    end
end

function SpiritBagGroup:__delete()
    for k, v in pairs(self.cells) do
        v:DeleteMe()
    end
    self.cells = {}
end

function SpiritBagGroup:SetData(i, data)
    self.cells[i]:SetData(data)
end

function SpiritBagGroup:ListenClick(i, handler)
    self.cells[i]:ListenClick(handler)
end

function SpiritBagGroup:SetToggleGroup(toggle_group)
    for k, v in ipairs(self.cells) do
        v:SetToggleGroup(toggle_group)
    end
end

function SpiritBagGroup:SetHighLight(i, enable)
    self.cells[i]:SetHighLight(enable)
end

function SpiritBagGroup:ShowHighLight(i, enable)
    self.cells[i]:ShowHighLight(enable)
end

function SpiritBagGroup:SetInteractable(i, enable)
    self.cells[i]:SetInteractable(enable)
end


-- 法阵列表
SpiritFaZhenList = SpiritFaZhenList or BaseClass(BaseRender)

function SpiritFaZhenList:__init(instance)
    self.icons = {}
    self.attrs = {}
    for i = 1, 4 do
        local item_cell = ItemCell.New()
        item_cell:SetInstanceParent(self:FindObj("Item"..i))
        self.icons[i] = {item = item_cell, is_show = self:FindVariable("ShowIcon"..i)}
    end
    self.score_image = self:FindVariable("Score")
    self.show_score = self:FindVariable("ShowScore")
    self.attr_des = self:FindVariable("Attr_Des")
end

function SpiritFaZhenList:__delete()
    for k, v in pairs(self.icons) do
        v.item:DeleteMe()
    end
    self.icons = {}
end

function SpiritFaZhenList:SetData(data)
    if data == nil then return end
    self.show_score:SetValue(data.zuhe_pingfen ~= nil)
    local bundle, asset = ResPath.GetSpiritScoreIcon(data.zuhe_pingfen or 1)
    self.score_image:SetAsset(bundle, asset)

    local attr = CommonDataManager.GetAttributteNoUnderline(data, true)
    self.attr_des:SetValue(data.desc)

    for k, v in pairs(self.icons) do
        v.is_show:SetValue(data["itemid"..k] > 0)
        if data["itemid"..k] > 0 then
            local item_data = SpiritData.Instance:GetDressSpiritInfoById(data["itemid"..k])
            if nil == item_data then
                local temp_data = {item_id = data["itemid"..k], param = {strengthen_level = 0}}
                v.item:ShowQuality(false)
                v.item:SetData(temp_data)
                v.item:SetIconGrayScale(true)
            else
                v.item:ShowQuality(true)
                v.item:SetData(item_data)
                v.item:SetIconGrayScale(false)
            end
        end
    end
end

