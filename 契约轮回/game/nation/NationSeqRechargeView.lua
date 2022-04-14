-- @Author: lwj
-- @Date:   2019-09-20 17:42:28
-- @Last Modified time: 2019-09-18 17:42:30

NationSeqRechargeView = NationSeqRechargeView or class("NationSeqRechargeView", BaseItem)
local NationSeqRechargeView = NationSeqRechargeView

function NationSeqRechargeView:ctor(parent_node, layer, panel, act_id,abName, assetName)
    self.abName = abName or "nation"
    self.assetName = assetName or "NationSeqRechargeView"
    self.layer = layer
    self.panel = panel
    self.act_id = act_id

    self.is_init_title = false
    self.model = NationModel.GetInstance()
    BaseItem.Load(self)
end

function NationSeqRechargeView:dctor()
    self.panel = nil
    if self.CDT then
        self.CDT:destroy()
        self.CDT = nil
    end
    if self.success_exchange_event_id then
        GlobalEvent:RemoveListener(self.success_exchange_event_id)
        self.success_exchange_event_id = nil
    end
    if self.update_info_event_id then
        GlobalEvent:RemoveListener(self.update_info_event_id)
        self.update_info_event_id = nil
    end
    self.title_list = {}
    if not table.isempty(self.achi_item_list) then
        for i, v in pairs(self.achi_item_list) do
            if v then
                v:destroy()
            end
        end
        self.achi_item_list = {}
    end

    if not table.isempty(self.daily_item_list) then
        for i, v in pairs(self.daily_item_list) do
            if v then
                v:destroy()
            end
        end
        self.daily_item_list = {}
    end
    if self.left_StencilMask then
        destroy(self.left_StencilMask)
        self.left_StencilMask = nil
    end
    if self.right_StencilMask then
        destroy(self.right_StencilMask)
        self.right_StencilMask = nil
    end
end

function NationSeqRechargeView:LoadCallBack()
    self.nodes = {
        "Right_Scroll/RightViewport/right_con/NationSeqDailyItem", "Right_Scroll/RightViewport/right_con",
        "LeftScroll/LeftViewport/left_con/NationAchiItem", "LeftScroll/LeftViewport/left_con",
        "LeftScroll/LeftViewport", "Right_Scroll/RightViewport",
        "Sundries/Title_Bg/title_1", "Sundries/Title_Bg/title", "Sundries/Title_Bg/title_2", "Sundries/Title_Bg/title_3",
        "time_con", "time_con/countdowntext",
    }
    self:GetChildren(self.nodes)
    self.achi_obj = self.NationAchiItem.gameObject
    self.daily_obj = self.NationSeqDailyItem.gameObject
    self.title = GetText(self.title)
    self.title_1 = GetText(self.title_1)
    self.title_2 = GetText(self.title_2)
    self.title_3 = GetText(self.title_3)

    self.title_list = {}
    self.title_list[#self.title_list + 1] = self.title_1
    self.title_list[#self.title_list + 1] = self.title_2
    self.title_list[#self.title_list + 1] = self.title_3

    self.time = GetText(self.countdowntext)

    self:AddEvent()
    self:SetLeftMask()
    self:InitTime()
    self:SetRightMask()
    self:InitPanel()
end

function NationSeqRechargeView:AddEvent()
    self.success_exchange_event_id = GlobalEvent:AddListener(OperateEvent.SUCCESS_GET_REWARD, handler(self, self.HandleSuccessExchange))
    self.update_info_event_id = GlobalEvent:AddListener(NationEvent.UpdateRewardInfo, handler(self, self.HandleUpdateRewardInfo))
end

function NationSeqRechargeView:InitPanel()
	self:LoadAchiItem()
    self:LoadDailyItem()
end

function NationSeqRechargeView:InitTime()
    if self.panel then
        self.end_time = OperateModel.GetInstance():GetActEndTimeByActId(174200)
    else
        self.end_time = self.model:GetEndTimeByActId(OperateModel.GetInstance():GetActIdByType(404))
    end

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

function NationSeqRechargeView:LoadAchiItem()
    local list = {}
    if self.panel then
        list = self.model:GetAcIllRewaCf()  -- 图鉴
    else
        list = self.model:GetAchiRewaCf()
    end

    if not self.is_init_title then
        local data_list = list[1]
        for i = 1, #data_list do
            local day = data_list[i].day
            self.title_list[i].text = string.format(ConfigLanguage.Nation.RechargeTitleDay, day)
        end
        self.title.text = ConfigLanguage.Nation.RechargeTitle
    end

    self.achi_item_list = self.achi_item_list or {}
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
        item:SetData(list[i], self.left_StencilId, 3)
    end
    for i = len + 1, #self.achi_item_list do
        local item = self.achi_item_list[i]
        item:SetVisible(false)
    end
end

function NationSeqRechargeView:SortDailyItem()
    local cf
    if self.panel then
         cf = self.model:GetIllRewaCfByActId(174201)
    else
         cf = self.model:GetRewaCfByActId(OperateModel.GetInstance():GetActIdByType(405))
    end

    self.cf_list = {}
    local fin_list = {}
    local inter = table.pairsByKey(cf)
    for act_task_id, act_task_cf in inter do
        local ser_info
        if self.panel then
            ser_info = self.model:GetSingleTaskInfo(174201, act_task_id)
        else
            ser_info = self.model:GetSingleTaskInfo(OperateModel.GetInstance():GetActIdByType(405), act_task_id)
        end

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

function NationSeqRechargeView:LoadDailyItem()
    self:SortDailyItem()
    local list = self.cf_list
    self.daily_item_list = self.daily_item_list or {}
    local len = #list
    for i = 1, len do
        local item = self.daily_item_list[i]
        if not item then
            item = NationSeqDailyItem(self.daily_obj, self.right_con)
            self.daily_item_list[i] = item
        else
            item:SetVisible(true)
        end
        item:SetData(list[i], self.right_StencilId, 3)
    end
    for i = len + 1, #self.daily_item_list do
        local item = self.daily_item_list[i]
        item:SetVisible(false)
    end
end

function NationSeqRechargeView:SetLeftMask()
    self.left_StencilId = GetFreeStencilId()
    self.left_StencilMask = AddRectMask3D(self.LeftViewport.gameObject)
    self.left_StencilMask.id = self.left_StencilId
end

function NationSeqRechargeView:SetRightMask()
    self.right_StencilId = GetFreeStencilId()
    self.right_StencilMask = AddRectMask3D(self.RightViewport.gameObject)
    self.right_StencilMask.id = self.right_StencilId
end

function NationSeqRechargeView:HandleSuccessExchange(data)
    if self.panel then
        if data.act_id ~= 174201 then
            return
        end
    else
        if data.act_id ~= OperateModel.GetInstance():GetActIdByType(405) then
            return
        end
    end
    self:LoadDailyItem()
end

function NationSeqRechargeView:HandleUpdateRewardInfo()
	 if self.panel then
		self:InitPanel()
	end
end