-- @Author: lwj
-- @Date:   2019-09-18 16:59:43 
-- @Last Modified time: 2019-09-18 16:59:45

NationExchangeView = NationExchangeView or class("NationExchangeView", BaseItem)
local NationExchangeView = NationExchangeView

function NationExchangeView:ctor(parent_node, layer)
    self.abName = "nation"
    self.assetName = "NationExchangeView"
    self.layer = layer

    self.model = NationModel.GetInstance()

    self.is_initted_icon = false
    BaseItem.Load(self)
end

function NationExchangeView:dctor()
    for i, v in pairs(self.model_event) do
        self.model:RemoveListener(v)
    end
    self.model_event = {}
    if not table.isempty(self.item_list) then
        for i, v in pairs(self.item_list) do
            if v then
                v:destroy()
            end
        end
        self.item_list = {}
    end
    if self.CDT then
        self.CDT:destroy()
        self.CDT = nil
    end
end

function NationExchangeView:LoadCallBack()
    self.nodes = {
        "Rest_con/rest", "Rest_con/btn_plus", "Scroll/Viewport/item_con", "Rest_con/icon", "Scroll/Viewport/item_con/NationExchangeItem",
        "time_con", "time_con/countdowntext",
    }
    self:GetChildren(self.nodes)
    self.rest = GetText(self.rest)
    self.icon = GetImage(self.icon)
    self.item_obj = self.NationExchangeItem.gameObject
    self.time = GetText(self.countdowntext)
    self.theme_cf = self.model:GetThemeCfById()

    self:AddEvent()
    self:InitPanel()
end

function NationExchangeView:AddEvent()
    self.model_event = {}
    self.model_event[#self.model_event + 1] = self.model:AddListener(NationEvent.CheckExchangeItemRest, handler(self, self.HandleRestUpdate))

    local function callback()
        local tbl = String2Table(self.theme_cf.sundries)
        local jump = {}
        for _, table in pairs(tbl) do
            if table[1] == "jump" then
                jump = table[2]
                break
            end
        end
        if table.isempty(jump) then
            logError("NationExchangeView: 没有加号的跳转")
            return
        end
        local open_link = GetOpenLink(unpack(jump))
        local id = OperateModel.GetInstance():GetActIdByType(open_link.param)
        if id == 0 then
            return
        end
        if self.model:IsActOutDate(id) then
            Notify.ShowText(ConfigLanguage.Nation.ActivityIsOver)
            return
        end
        OpenLink(unpack(jump))
    end
    AddButtonEvent(self.btn_plus.gameObject, callback)
end

function NationExchangeView:InitPanel()
    self.theme_cf = self.model:GetThemeCfById(OperateModel.GetInstance():GetActIdByType(401))
    self:LoadItem()
    self:InitTime()
    self:UpdateRestShow()
end

function NationExchangeView:UpdateRestShow()
    if not self.is_initted_icon then
        GoodIconUtil.GetInstance():CreateIcon(self, self.icon, tostring(self.cost_item_id), true)
    end
    local cur_num = BagModel.GetInstance():GetItemNumByItemID(self.cost_item_id)
    self.rest.text = cur_num
end

function NationExchangeView:InitTime()
    self.end_time = self.model:GetEndTimeByActId(OperateModel.GetInstance():GetActIdByType(401))
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

function NationExchangeView:LoadItem()
    local list = self.model:GetExchangeItemList()
    if not self.cost_item_id then
        self.cost_item_id = String2Table(list[1].cost)[1][1]
    end
    self.item_list = self.item_list or {}
    local len = #list
    for i = 1, len do
        local item = self.item_list[i]
        if not item then
            item = NationExchangeItem(self.item_obj, self.item_con)
            self.item_list[i] = item
        else
            item:SetVisible(true)
        end
        item:SetData(list[i])
    end
    for i = len + 1, #self.item_list do
        local item = self.item_list[i]
        item:SetVisible(false)
    end
end

function NationExchangeView:HandleRestUpdate()
    local remain = BagModel.GetInstance():GetItemNumByItemID(self.cost_item_id)
    self.rest.text = remain
end