-- @Author: lwj
-- @Date:   2019-01-30 17:10:38
-- @Last Modified time: 2019-01-30 17:10:41


DailyShowPanel = DailyShowPanel or class("DailyShowPanel", WindowPanel)
local DailyShowPanel = DailyShowPanel

function DailyShowPanel:ctor(parent_node, layer)
    self.abName = "daily"
    self.assetName = "DailyShowPanel"
    self.layer = "UI"
    self.panel_type = 3

    self.model = DailyModel:GetInstance()
    self.model.isOpenningShowPanel = true
    self.cur_model_lv = 1
end

function DailyShowPanel:dctor()
end

function DailyShowPanel:Open()
    DailyShowPanel.super.Open(self)
end

function DailyShowPanel:LoadCallBack()
    self.nodes = {
        "Poi_con/propertyContent/DailyShowProItem", "Poi_con/progress", "Poi_con/prog_text", "Poi_con/propertyContent", "btn_upLv", "title",
        "scene_img", "btn_upLv/red_con",
    }
    self:GetChildren(self.nodes)
    self.prog_text = GetText(self.prog_text)
    self.progress = GetSlider(self.progress)
    self.title = GetText(self.title)
    self.property_item_gameObject = self.DailyShowProItem.gameObject
    SetLocalPosition(self.transform, 0, 0, 0);

    self:AddEvent()
    self:SetPanelSize(894, 525)
    self:SetTileTextImage("daily_image", "vip_show_title_img");
    self:SortConModel()
    self:InitPanel()
end

function DailyShowPanel:SortConModel()
    self.con_model_list = self.con_model_list or {}
    local tbl = Config.db_daily_show
    local group = 1
    local data = {}
    data.group = 1
    data.level = tbl[1].level
    self.con_model_list[#self.con_model_list + 1] = data
    for i = 1, #tbl do
        if tbl[i].group ~= group then
            local data = {}
            data.group = tbl[i].group
            group = tbl[i].group
            data.level = tbl[i].level
            self.con_model_list[#self.con_model_list + 1] = data
        end
    end
end

function DailyShowPanel:AddEvent()
    local function call_back()
        local illu_info = self.model:GetIllutionInfo()
        local tbl = Config.db_daily_show[illu_info.level + 1]
        if tbl then
            local need_act = tbl.activation
            if illu_info.exp >= need_act then
                self.model:Brocast(DailyEvent.RequestUpDailyLevel)
            else
                Notify.ShowText(ConfigLanguage.Daily.ActOfDailyIsNotEnough)
            end
        end
    end
    AddButtonEvent(self.btn_upLv.gameObject, call_back)

    self.handleshowlvup_event_id = self.model:AddListener(DailyEvent.HandleShowUpLv, handler(self, self.InitPanel))
    self.handle_change_rd_event_id = self.model:AddListener(DailyEvent.UpdateShapeRD, handler(self, self.SetRedDot))
end

function DailyShowPanel:InitPanel()
    local illu_info = self.model:GetIllutionInfo()
    local model_tbl = self.con_model_list[illu_info.show_id]
    self.title.text = Config.db_daily_show[model_tbl.level].name
    self.cur_model_lv = model_tbl.group
    local resource = Config.db_daily_show[model_tbl.level].resource
    local tbl = string.split(resource, '_')
    self:LoadShowModel(tonumber(tbl[3]))
    self:UpdateRight()
    self:SetRedDot(self.model.is_show_shape_rd)
end

function DailyShowPanel:LoadShowModel(resource)
    self:DestroyRoleModel()
    --self.role_model = UIModelManager:GetInstance():InitModel(nil, resource, self.scene_img, handler(self, self.LoadModelCallBack), true)
    self.role_model = UIMountCamera(self.scene_img.transform, nil, resource, enum.ITEM_STYPE.ITEM_STYPE_TALIS_MORPH);
    local config = {};
    config.rotate = { x = 0, y = 180, z = 0 };
    config.offset = { x = 4000, y = 0, z = 0 };
    config.cameraPos = { x = 4000, y = -1000, z = 0 };
    config.offset = { x = 6000, y = -940, z = -550 };
    config.scale = { x = 100, y = 100, z = 100 };
    self.role_model:SetConfig(config)
end

function DailyShowPanel:LoadModelCallBack()
    SetLocalPosition(self.role_model.transform, 7, -110, -400)
    SetLocalRotation(self.role_model.transform, 10, 180, 0)
    SetLocalScale(self.role_model.transform, 400, 400, 400)
end

function DailyShowPanel:OpenCallBack()
end

function DailyShowPanel:DestroyRoleModel()
    if self.role_model ~= nil then
        self.role_model:destroy()
        self.role_model = nil
    end
end

function DailyShowPanel:UpdateRight()
    local illu_info = self.model:GetIllutionInfo()
    local lv = illu_info.level
    local conTbl = Config.db_daily_show
    local attr_tbl = {}
    attr_tbl[1] = String2Table(conTbl[lv].attr)
    local next_atr_tbl = nil
    if conTbl[lv + 1] then
        next_atr_tbl = String2Table(conTbl[lv + 1].attr)
    end
    if next_atr_tbl then
        attr_tbl[2] = next_atr_tbl
    end

    self.attr_item_list = self.attr_item_list or {}
    local len = #attr_tbl
    for i = 1, len do
        local item = self.attr_item_list[i]
        if not item then
            item = DailyShowProItem(self.property_item_gameObject, self.propertyContent)
            self.attr_item_list[i] = item
        else
            item:SetVisible(true)
        end
        item:SetData(attr_tbl[i], i)
    end
    for i = len + 1, #self.attr_item_list do
        local item = self.attr_item_list[i]
        item:SetVisible(false)
    end
    if next_atr_tbl then
        self.prog_text.text = illu_info.exp .. '/' .. conTbl[lv + 1].activation
        self.progress.value = illu_info.exp / conTbl[lv + 1].activation
    else
        SetVisible(self.btn_upLv, false)
        self.prog_text.text = "Max Lvl"
        self.progress.value = 1
    end
end

function DailyShowPanel:CloseCallBack()
    if self.handle_change_rd_event_id then
        self.model:RemoveListener(self.handle_change_rd_event_id)
        self.handle_change_rd_event_id = nil
    end
    destroySingle(self.red_dot)
    self.red_dot = nil
    self.model.isOpenningShowPanel = false
    self:DestroyRoleModel()
    for i, v in pairs(self.attr_item_list) do
        if v then
            v:destroy()
        end
    end
    self.attr_item_list = {}
    if self.handleshowlvup_event_id then
        self.model:RemoveListener(self.handleshowlvup_event_id)
        self.handleshowlvup_event_id = nil
    end
end

function DailyShowPanel:SetRedDot(isShow)
    if not self.red_dot then
        self.red_dot = RedDot(self.red_con, nil, RedDot.RedDotType.Nor)
    end
    self.red_dot:SetPosition(0, 0)
    self.red_dot:SetRedDotParam(isShow)
end
