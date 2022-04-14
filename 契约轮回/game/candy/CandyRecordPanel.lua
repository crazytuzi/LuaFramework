-- @Author: lwj
-- @Date:   2019-02-25 15:49:33
-- @Last Modified time: 2019-02-25 15:49:35

CandyRecordPanel = CandyRecordPanel or class("CandyRecordPanel", WindowPanel)
local CandyRecordPanel = CandyRecordPanel

function CandyRecordPanel:ctor(parent_node, layer)
    self.abName = "candy"
    self.assetName = "CandyRecordPanel"
    self.layer = "UI"
    self.panel_type = 6

    self.model = CandyModel.GetInstance()
    self.record_item_list = {}
    self.labels = {}
end

function CandyRecordPanel:dctor()
   self.labels = nil
end

function CandyRecordPanel:Open()
    CandyRecordPanel.super.Open(self)
end

function CandyRecordPanel:LoadCallBack()
    self.nodes = {
        "record_content/record_scroll/Viewport/record_cont", "record_content/record_scroll", "record_content/record_scroll/Viewport/record_cont/CandyRecordItem", "top_toggle_group/toggle_recive", "top_toggle_group/toggle_give", "no_record_tip",
		"top_toggle_group/toggle_recive/Label","top_toggle_group/toggle_give/Label2",
    }
    self:GetChildren(self.nodes)
    self.tips_text = GetText(self.no_record_tip)
    self.labels[1] = GetText(self.Label)
    self.labels[2] = GetText(self.Label2)
    --self.remain_num = GetText(self.remain_num)
    self.record_item_gobj = self.CandyRecordItem.gameObject

    self:AddToggles()
    self:AddEvent()
    self:InitWinPanel()
    self:InitPanel()
end

function CandyRecordPanel:AddToggles()
    self.toggle_list = self.toggle_list or {}
    self.toggle_list[1] = self.toggle_recive
    self.toggle_list[2] = self.toggle_give
    self:SetTogColor(1)
end

function CandyRecordPanel:SetTogColor(idx)
    for i = 1, #self.labels do
        if i == idx then
            SetColor(self.labels[i], 133, 132, 176)
        else
            SetColor(self.labels[i], 255, 255, 255)
        end
    end
end

function CandyRecordPanel:AddEvent()
    self.change_end_event_id = GlobalEvent:AddListener(EventName.ChangeSceneEnd, handler(self, self.Close))
    for i = 1, #self.toggle_list do
        local function callback()
            self.model:Brocast(CandyEvent.RequestCandyRecord, i)
            self:SetTogColor(i)
        end
        AddClickEvent(self.toggle_list[i].gameObject, callback)
    end

    self.loadrecorditem_event_id = self.model:AddListener(CandyEvent.LoadRecordItem, handler(self, self.LoadRecordItem))
end

function CandyRecordPanel:InitWinPanel()
    self:SetTitleBgImage("system_image", "ui_title_bg_5")
    self:SetTopCenterBg("system_image", "ui_title_bg_6")
    self:SetTileTextImage("candy_image", "CandyRecordPanel_Title_Img")
    self:SetTitleImgPos(-10, 250)
    self:SetBtnCloseImg("system_image", "ui_close_btn_3", true)
end

function CandyRecordPanel:InitPanel()
    self:LoadRecordItem(1)
end

function CandyRecordPanel:LoadRecordItem(type)
    local ser_list = self.model:GetRecordListByType(type)
    local len = #ser_list
    if len == 0 then
        local key_str = "NoRecord_" .. type
        self.tips_text.text = ConfigLanguage.Candy[key_str]
        SetVisible(self.no_record_tip, true)
        for i = 1, #self.record_item_list do
            if self.record_item_list[i] then
                SetVisible(self.record_item_list[i], false)
            end
        end
    else
        SetVisible(self.no_record_tip, false)
        self.record_item_list = self.record_item_list or {}
        for i = 1, len do
            local item = self.record_item_list[i]
            if not item then
                item = CandyRecordItem(self.record_item_gobj, self.record_cont)
                self.record_item_list[i] = item
            else
                item:SetVisible(true)
            end
            item:SetData(ser_list[i])
        end
        for i = len + 1, #self.record_item_list do
            local item = self.record_item_list[i]
            item:SetVisible(false)
        end
    end
end

function CandyRecordPanel:OpenCallBack()
    self.model.isOpenningRecordPanel = true
end

function CandyRecordPanel:CloseCallBack()
    if self.toggle_list then
        self.toggle_list = nil
    end
    if self.change_end_event_id then
        GlobalEvent:RemoveListener(self.change_end_event_id)
        self.change_end_event_id = nil
    end
    self.model.isOpenningRecordPanel = false
    for i, v in pairs(self.record_item_list) do
        if v then
            v:destroy()
        end
    end
    self.record_item_list = {}

    if self.loadrecorditem_event_id then
        self.model:RemoveListener(self.loadrecorditem_event_id)
    end
    self.loadrecorditem_event_id = nil
    --self.model.targetPlayerId = nil
end



