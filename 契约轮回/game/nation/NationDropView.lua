-- @Author: lwj
-- @Date:   2019-09-05 15:52:14 
-- @Last Modified time: 2019-09-05 15:52:19

NationDropView = NationDropView or class("NationDropView", BaseItem)
local NationDropView = NationDropView

function NationDropView:ctor(parent_node, layer)
    self.abName = "nation"
    self.assetName = "NationDropView"
    self.layer = layer

    self.model = NationModel.GetInstance()
    self.act_id = OperateModel.GetInstance():GetActIdByType(402)
    BaseItem.Load(self)
end

function NationDropView:dctor()
    for i, v in pairs(self.rewa_list) do
        if v then
            v:destroy()
        end
    end
    self.rewa_list = {}
end

function NationDropView:LoadCallBack()
    self.nodes = {
        "act_des", "bnt_go", "act_time", "rewa_con",
    }
    self:GetChildren(self.nodes)
    self.act_des = GetText(self.act_des)
    self.act_time = GetText(self.act_time)
    self.btn_go = self.bnt_go

    self:AddEvent()
    self:InitPanel()
end

function NationDropView:AddEvent()
    local function callback()
        local cf = self.model:GetThemeCfById(self.act_id)
        local list = String2Table(cf.sundries)
        local link = {}
        for i, v in pairs(list) do
            if v[1] == "jump" then
                link = v[2]
                break
            end
        end
        if table.isempty(link) then
            logError("NationDropView,没有跳转链接")
            return
        end
        OpenLink(unpack(link))
        self.model:Brocast(NationEvent.CloseNationPanel)
    end
    AddButtonEvent(self.bnt_go.gameObject, callback)
end

function NationDropView:InitPanel()
    self:InitTimeShow()
    self:LoadRewa()
end

function NationDropView:InitTimeShow()
    local start_stamp = OperateModel.GetInstance():GetActStartTimeByActId(self.act_id)
    local start_time_tbl = TimeManager.GetInstance():GetTimeDate(start_stamp)
    local end_stamp = self.model.act_end_list[self.act_id]
    local end_time_tbl = TimeManager.GetInstance():GetTimeDate(end_stamp)
    local s_min = self.model:FormatNum(start_time_tbl.min)
    local s_hour = self.model:FormatNum(start_time_tbl.hour)
    local e_min = self.model:FormatNum(end_time_tbl.min)
    local e_hour = self.model:FormatNum(end_time_tbl.hour)
    self.act_time.text = string.format(ConfigLanguage.OpenHigh.WeddingOpenTime, start_time_tbl.year, start_time_tbl.month, start_time_tbl.day, tostring(s_hour), tostring(s_min), end_time_tbl.year, end_time_tbl.month, end_time_tbl.day, tostring(e_hour), tostring(e_min))
    local act_cf = self.model:GetThemeCfById(self.act_id)
    self.act_des.text = act_cf.desc
end

function NationDropView:LoadRewa()
    local cf = self.model:GetThemeCfById(self.act_id)
    local list = String2Table(cf.reward)
    self.rewa_list = {}
    for i = 1, #list do
        local tbl = list[i]
        local param = {}
        local operate_param = {}
        param["item_id"] = tbl[1]
        param["model"] = self.model
        param["can_click"] = true
        param["operate_param"] = operate_param
        param["size"] = { x = 74, y = 74 }
        param["num"] = tbl[2]
        param.bind = tbl[3]
        local itemIcon = GoodsIconSettorTwo(self.rewa_con)
        itemIcon:SetIcon(param)
        self.rewa_list[#self.rewa_list + 1] = itemIcon
    end
end