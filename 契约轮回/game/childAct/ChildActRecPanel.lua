

ChildActRecPanel = ChildActRecPanel or class("ChildActRecPanel", NationSeqRechargeView)
local ChildActRecPanel = ChildActRecPanel

function ChildActRecPanel:ctor(parent_node, layer, panel, act_id,abName, assetName)

end

function ChildActRecPanel:InitTime()
    local id =  OperateModel:GetInstance():GetActIdByType(772)
    self.end_time = OperateModel.GetInstance():GetActEndTimeByActId(id)
    if self.end_time then
        local param = {}
        param.isShowMin = true
        param.isShowHour = true
        param.isShowDay = true
        param.isShowSec = true
        param.isChineseType = true
        param.formatText = "Time left: %s"
        self.CDT = CountDownText(self.time_con, param)
        local function call_back()
            self.time.text = ConfigLanguage.Nation.ActivityIsOver
        end
        self.CDT:StartSechudle(self.end_time, call_back)
    end
end

function ChildActRecPanel:LoadAchiItem()
    local list = ChildActModel.GetInstance():GetAcIllRewaCf()  -- 图鉴

    if not self.is_init_title then
        local data_list = list[1]
        for i = 1, #data_list do
            local day = data_list[i].day
            self.title_list[i].text = string.format(ConfigLanguage.Nation.RechargeTitleDay, day)
        end
        self.title.text = ConfigLanguage.Nation.RechargeTitle
    end

    self.achi_item_list = self.achi_item_list or {}
    local model =  ChildActModel.GetInstance()
    local len = #list
    for i = 1, len do
        local item = self.achi_item_list[i]
        if not item then
            item = NationAchiItem(self.achi_obj, self.left_con)
            self.achi_item_list[i] = item
        else
            item:SetVisible(true)
        end
        list[i].idx = i
        item:SetData(list[i], self.left_StencilId, 3, model)
    end
    for i = len + 1, #self.achi_item_list do
        local item = self.achi_item_list[i]
        item:SetVisible(false)
    end
end

function ChildActRecPanel:SortDailyItem()
    local cf = ChildActModel.GetInstance():GetIllRewaCfByActId(OperateModel.GetInstance():GetActIdByType(776))

    self.cf_list = {}
    local fin_list = {}
    local inter = table.pairsByKey(cf)
    for act_task_id, act_task_cf in inter do
        local ser_info = ChildActModel.GetInstance():GetSingleTaskInfo(OperateModel.GetInstance():GetActIdByType(776), act_task_id)
        --奖励
        if ser_info.state == enum.YY_TASK_STATE.YY_TASK_STATE_REWARD then
            fin_list[#fin_list + 1] = act_task_cf
        else
            self.cf_list[#self.cf_list + 1] = act_task_cf
        end
    end
    for i = 1, #fin_list do
        self.cf_list[#self.cf_list + 1] = fin_list[i]
    end
end

function ChildActRecPanel:LoadDailyItem()
    self:SortDailyItem()
    local list = self.cf_list
    self.daily_item_list = self.daily_item_list or {}
    local model =  ChildActModel.GetInstance()
    local len = #list
    for i = 1, len do
        local item = self.daily_item_list[i]
        if not item then
            item = NationSeqDailyItem(self.daily_obj, self.right_con)
            self.daily_item_list[i] = item
        else
            item:SetVisible(true)
        end
        item:SetData(list[i], self.right_StencilId, 3, model)
    end
    for i = len + 1, #self.daily_item_list do
        local item = self.daily_item_list[i]
        item:SetVisible(false)
    end
end

function ChildActRecPanel:HandleSuccessExchange(data)
    if data.act_id ~= OperateModel.GetInstance():GetActIdByType(776) then
        return
    end

    self:LoadDailyItem()
    GlobalEvent:Brocast(ChildActEvent.UpdateMainRed)
end

function ChildActRecPanel:HandleUpdateRewardInfo()
    if self.panel then
        self:InitPanel()
		GlobalEvent:Brocast(ChildActEvent.UpdateMainRed)
    end
end





