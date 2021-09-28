TipsSpiritHomeHarvestView = TipsSpiritHomeHarvestView or BaseClass(BaseView)

local BAG_MAX_GRID_NUM = 40         -- 最大格子数
local BAG_PAGE_NUM = 2                  -- 页数
local BAG_PAGE_COUNT = 20               -- 每页个数
local BAG_ROW = 4                       -- 行数
local BAG_COLUMN = 5                    -- 列数

function TipsSpiritHomeHarvestView:__init()
	self.ui_config = {"uis/views/tips/spirithometip_prefab","SpiritHomeHarvestTip"}
	self.view_layer = UiLayer.Pop
	self.str = ""
	self.early_close_state = false

    self.bag_cell = {}
    self.data_list = {}
end

function TipsSpiritHomeHarvestView:__delete()
end

function TipsSpiritHomeHarvestView:ReleaseCallBack()
    self.data_list = {}
    for k, v in pairs(self.bag_cell) do
        v:DeleteMe()
    end
    self.bag_cell = {}

    if self.count_timer ~= nil then
        CountDown.Instance:RemoveCountDown(self.count_timer)
        self.count_timer = nil
    end

	self.time_str = nil
    self.is_show_timer = nil
	self.bag_list_view = nil
    self.btn_str = nil
    self.title_str = nil
    self.other_str = nil
end

function TipsSpiritHomeHarvestView:SetData(select_index)
    self.select_index = select_index
    if not self:IsOpen() then
        self:Open()
    end
end

function TipsSpiritHomeHarvestView:OpenCallBack()
    self:ResetItemList()
end

function TipsSpiritHomeHarvestView:CloseCallBack()
    if self.count_timer ~= nil then
        CountDown.Instance:RemoveCountDown(self.count_timer)
        self.count_timer = nil
    end
end

function TipsSpiritHomeHarvestView:LoadCallBack()
    self.bag_list_view = self:FindObj("ListView")
    local list_delegate = self.bag_list_view.page_simple_delegate
    list_delegate.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
    list_delegate.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)

	self.time_str = self:FindVariable("TimeStr")
    self.is_show_timer = self:FindVariable("ShowTimer")
    self.btn_str = self:FindVariable("BtnStr")
    self.title_str = self:FindVariable("TitleStr")
    self.other_str = self:FindVariable("OtherStr")

	self:ListenEvent("CloseView", BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("Harvest", BindTool.Bind(self.OnClickHarvest, self))
end

function TipsSpiritHomeHarvestView:BagGetNumberOfCells()
    return BAG_MAX_GRID_NUM
end

function TipsSpiritHomeHarvestView:BagRefreshCell(index, cellObj)
    -- 构造Cell对象.
    local cell = self.bag_cell[cellObj]
    if nil == cell then
        cell = ItemCell.New(cellObj)
        cell:SetToggleGroup(self.bag_list_view.toggle_group)
        self.bag_cell[cellObj] = cell
    end

    local page = math.floor(index / BAG_PAGE_COUNT)
    local cur_colunm = math.floor(index / BAG_ROW) + 1 - page * BAG_COLUMN
    local cur_row = math.floor(index % BAG_ROW) + 1
    local grid_index = (cur_row - 1) * BAG_COLUMN - 1 + cur_colunm  + page * BAG_ROW * BAG_COLUMN

    cell:SetHighLight(false)
    cell:SetInteractable(false)
    cell:SetData(self.data_list[grid_index + 1] or {}, false)
    cell:SetIconGrayScale(false)
end

function TipsSpiritHomeHarvestView:OnClickClose()
	self:Close()
end

function TipsSpiritHomeHarvestView:OnClickHarvest()
    if self.select_index == nil then
        return
    end

    local is_my = SpiritData.Instance:GetIsMyHome()
    if is_my then
      local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
      SpiritCtrl.Instance:SendJingLingHomeOperReq(JING_LING_HOME_OPER_TYPE.JING_LING_HOME_OPER_TYPE_GET_REWARD, main_role_vo.role_id, self.select_index - 1)
    else
        local cfg = SpiritData.Instance:GetMySpiritInOther()
        if cfg.item_id <= 0 then
            SysMsgCtrl.Instance:ErrorRemind(Language.JingLing.PleaseEquipJingLing)
            return
        end

        local cfg, num = SpiritData.Instance:GetSpiritHomeRewardList(self.select_index)

        if num == nil or num <= 0 then
            SysMsgCtrl.Instance:ErrorRemind(Language.JingLing.SpiritHomeNoThing)
            return
        end

        TipsCtrl.Instance:OpenSpiritHomeConfirmView(self.select_index)
    end

    self:Close()
end

function TipsSpiritHomeHarvestView:FlushList()
    if self.bag_list_view ~= nil then
        self.bag_list_view.list_view:Reload()
    end
end

function TipsSpiritHomeHarvestView:OnFlush(param_t)
    if self.select_index == nil then
        return
    end

    for k,v in pairs(param_t) do
        if "all" == k then
            --self:ResetItemList()

        local cfg = SpiritData.Instance:GetSpiritHomeRewardList(self.select_index)
        if cfg ~= nil and cfg.reward_item_list ~= nil then
            self.data_list = cfg.reward_item_list
        end
            self:FlushList()
            local is_my = SpiritData.Instance:GetIsMyHome()
            if self.is_show_timer ~= nil then
                self.is_show_timer:SetValue(is_my)
               -- if is_my then
                    if self.time_str ~= nil then
                        self.time_str:SetValue(is_my)
                    end

                  self:CheckTimer()
               -- end
              --  else
                    if self.other_str ~= nil then
                        local per = SpiritData.Instance:GetSpiritOtherCfgByName("home_rob_hunli_per") or 0
                        local value_max =SpiritData.Instance:GetSpiritOtherCfgByName("home_rob_lingjing_max") or 0
                        local min_num = SpiritData.Instance:GetSpiritOtherCfgByName("home_rob_item_min") or 0
                        local max_num = SpiritData.Instance:GetSpiritOtherCfgByName("home_rob_item_max") or 0
                        self.other_str:SetValue(string.format(Language.JingLing.SpiritHomeHarvestHelp, per, value_max, min_num, max_num))
                    end                  
               -- end
            end

            if self.btn_str ~= nil then
                local str_type = is_my and 0 or 1
                self.btn_str:SetValue(Language.JingLing.SpiritHomeHarvestBtn[str_type])
            end

            if self.title_str ~= nil then
                local str_tab = Language.JingLing.SpiritHomePerviewTitle
                local str_index = is_my and 0 or 1
                self.title_str:SetValue(str_tab[str_index])
            end
        elseif "flush_item" == k then
           -- self:ResetItemList()
        end
    end
end

function TipsSpiritHomeHarvestView:ResetItemList()
    if self.select_index == nil then
        return
    end

    local cfg = SpiritData.Instance:GetSpiritHomeRewardList(self.select_index)
    if cfg ~= nil and cfg.reward_item_list ~= nil then
        self.data_list = cfg.reward_item_list
    end

    if self.bag_list_view and self.bag_list_view.list_page_scroll2.isActiveAndEnabled then
        self.bag_list_view.list_page_scroll2:JumpToPageImmidate(0)
        self:Flush()
    end
end

function TipsSpiritHomeHarvestView:CheckTimer()
    if self.count_timer ~= nil then
        CountDown.Instance:RemoveCountDown(self.count_timer)
        self.count_timer = nil
    end

    if self.select_index == nil then
        return
    end

    local limlit = SpiritData.Instance:GetSpiritOtherCfgByName("home_reward_times_limit")
    if limlit == nil then
        return
    end

    local cfg = SpiritData.Instance:GetSpiritHomeRewardList(self.select_index)
    if cfg == nil or next(cfg) == nil then
        return
    end

    if cfg.reward_times < limlit then
        local interval = SpiritData.Instance:GetSpiritOtherCfgByName("home_reward_interval")
        local total_time = cfg.reward_beging_time + interval - TimeCtrl.Instance:GetServerTime()
        if total_time <= 0 then
            total_time = interval
        end

        if total_time > 0 then
            self.count_timer = CountDown.Instance:AddCountDown(total_time, 0.1, BindTool.Bind(self.UpdateBottom, self, self.select_index))
        end 
    else
        if self.time_str ~= nil then
            self.time_str:SetValue(Language.JingLing.SpiritHomeRewardIsMax)
        end
    end
end

function TipsSpiritHomeHarvestView:UpdateBottom(index, elapse_time, total_time)
    local is_my = SpiritData.Instance:GetIsMyHome()
    if self.time_str ~= nil and is_my then
        local cfg = SpiritData.Instance:GetSpiritHomeInfoByIndex(index)
        if cfg == nil or next(cfg) == nil then
            return
        end
        local time_value = TimeCtrl.Instance:GetServerTime() - cfg.last_get_time
        local time_t = TimeUtil.Format2TableDHMS(math.floor(time_value))
        self.time_str:SetValue(string.format(Language.JingLing.NextRewardStr, time_t.hour, time_t.min, time_t.s))
    end

    if elapse_time - total_time >= 0 then
        self:CompleteBottom()
    end
end

function TipsSpiritHomeHarvestView:CompleteBottom()
    if self.count_timer ~= nil then
        CountDown.Instance:RemoveCountDown(self.count_timer)
        self.count_timer = nil
    end

    --local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
    local role_id = SpiritData.Instance:GetHomeRoleId()
    SpiritCtrl.Instance:SendJingLingHomeOperReq(JING_LING_HOME_REASON.JING_LING_HOME_REASON_DEF, role_id)
end
------------------- 背包格子---------------------------------
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

function SpiritBagGroup:SetInteractable(i, enable)
    self.cells[i]:SetInteractable(enable)
end