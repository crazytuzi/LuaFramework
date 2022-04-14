--
-- @Author: LaoY
-- @Date:   2019-11-21 14:16:38
--
require("game/config/auto/db_gm")
require("common/input/GmItem")

require "common/FuzzySearch"

GMSubPanel = GMSubPanel or class("GMSubPanel", BaseItem)
GMSubPanel.Last_String = nil

local search_config_list = {}

local function initSearchConfig(config,search_key,save_key,func)
    if not search_config_list[config] then
        search_config_list[config] = FuzzySearch(config,search_key,save_key,func)
    end
end

local function find(config,str)
    if search_config_list[config] then
        return search_config_list[config]:find(str)
    end
    return nil
end

function GMSubPanel:ctor()
    self.abName = "debug"
    self.assetName = "GMSubPanel"
    self.layer = "UI"

    self.use_background = true
    self.change_scene_close = true

    self.item_list = {}


    local function handlerSearchFunc(list)
        local t = {}
        local len = #list
        for i=1,len do
            local v = list[i]
            t[#t+1] = v.name .. '(' .. v.id ..  ')'
        end
        return t
    end
    initSearchConfig(Config.db_item,"name",nil,handlerSearchFunc)
    
    -- self.model = 2222222222222end:GetInstance()

    GMSubPanel.super.Load(self)
end

function GMSubPanel:dctor()
    for k, item in pairs(self.item_list) do
        item:destroy()
    end
    self.item_list = {}

    UpdateBeat:Remove(self.Update, self);

    -- DebugManager:GetInstance():CheckGlobal(self.gameObject)
    -- DebugManager:GetInstance():CheckGlobal(self.transform)
    -- DebugManager:GetInstance():CheckCls(GMSubPanel)
end

function GMSubPanel:LoadCallBack()
    self.nodes = {
        "input", "btn_send", "text_id", "scroll", "scroll/Viewport/Content", "btn_serach", "btn_serach/text_serach", "GmItem",
        "btn_histroy","GMTestItem"
    }
    self:GetChildren(self.nodes)
    self.input_text = self.input:GetComponent("InputField")
    local str = string.format("Player ID: %s,Secne ID: %s", RoleInfoModel:GetInstance():GetMainRoleId() or "", SceneManager:GetInstance():GetSceneId() or "")
    self.id_text = self.text_id:GetComponent('InputField')
    -- self.id_text.text = str
    if GMSubPanel.Last_String then
        self.input_text.text = GMSubPanel.Last_String
    end

    self.text_serach_component = self.text_serach:GetComponent('Text')

    self.GmItem_gameObject = self.GmItem.gameObject
    SetVisible(self.GmItem, false)

    SetLocalScale(self.transform,0.82)

    self:AddEvent()

    self.input_text:ActivateInputField();

    self:UpdateView()
end

function GMSubPanel:AddEvent()
    local function call_back(target, x, y)
        Yzprint('--LaoY GMSubPanel.lua,line 38-- data=', ip_str)
        -- NetManager:GetInstance():SendMessage(proto.GAME_CHEAT,"s",ip_str)
        self:HandGm()
        if GMSubPanel.Last_String ~= "" then
            GMModel.GetInstance():AddHistroy(GMSubPanel.Last_String)
        end
    end
    AddClickEvent(self.btn_send.gameObject, call_back)

    local function call_back(target, x, y)
        if self.is_search then
            for k, v in pairs(self.item_list) do
                v:SetVisible(true)
            end
            self.is_search = false
            self.text_serach_component.text = "Search"
            self.id_text.text = ""
        else
            self:OnSearch()
        end
    end
    AddClickEvent(self.btn_serach.gameObject, call_back)

    local function callback()
        lua_panelMgr:GetPanelOrCreate(GMHistroyPanel):Open()
    end
    AddButtonEvent(self.btn_histroy.gameObject, callback)

    UpdateBeat:Add(self.Update, self);

    -- self.close_event = GlobalEvent:AddListener(MainEvent.CloseGMSubPanel, handler(self, self.Close))
     self.update_histroy_event_id = GlobalEvent:AddListener(MainEvent.UpdateGMPanelInput, handler(self, self.UpdateInstruction))
end

function GMSubPanel:Update()
    if Input.GetKeyDown(KeyCode.Return) then
        self:HandGm();
    end
end

function GMSubPanel:HandGm()
    local is_send = true
    local ip_str = self.input_text.text
    ip_str = string.lower(ip_str)
    local ip_str_tab = string.split(ip_str, "-")
    if ip_str == "id" then
        self.input_text.text = RoleInfoModel:GetInstance():GetMainRoleId() or ""
        return
    elseif ip_str == "hideui" then
        LayerManager:GetInstance():HideUI(true)
    elseif ip_str == "scene" then
        self.input_text.text = SceneManager:GetInstance():GetSceneId() or ""
        return
    elseif ip_str == "pos" then
        local main_role = SceneManager:GetInstance():GetMainRole()
        if main_role then
            self.input_text.text = string.format("[%d,%d]", main_role.position.x, main_role.position.y)
            return
        end
    elseif ip_str_tab[1] == "items" then

    elseif ip_str_tab[1] == "showitem" then
        is_send = false
        local cf = GMModel.GetInstance():GetItemCf()
        local start_idx = tonumber(ip_str_tab[2])
        local end_idx = tonumber(ip_str_tab[3])
        local len = end_idx - start_idx + 1
        for i = 1, len do
            local idx = start_idx
            local id = cf[idx].id
            local str = "item-" .. id .. "-1"
            self:SendGm(str)
            start_idx = start_idx + 1
        end
    end
    if is_send then
        self:SendGm(ip_str)
    end
end

function GMSubPanel:SendGm(ip_str)
    GMSubPanel.Last_String = ip_str
    LoginController:GetInstance():RequestGameCheat(ip_str)
end

function GMSubPanel:UpdateView()
    local list = Config.db_gm
    local len = #list
    local function call_back(id)
        self:CallBack(id)
    end

    SetSizeDeltaY(self.Content, math.ceil(len/7) * 80)

    for i = 1, len do
        local item = self.item_list[i]
        if not item then
            item = GmItem(self.GmItem_gameObject, self.Content)
            item:SetCallBack(call_back)
            self.item_list[i] = item
        else
            item:SetVisible(true)
        end
        item:SetData(list[i])
    end

    local max_len = #self.item_list
    for i = len + 1, max_len do
        local item = self.item_list[i]
        item:destroy()
        self.item_list[i] = nil
    end
end

function GMSubPanel:OnSearch()
    if self.is_search then
        return
    end
    local str = self.id_text.text
    if #str < 1 then
        return
    end

    local t = {}
    for k, v in pairs(Config.db_gm) do
        if string.find(v.name, str) then
            t[#t + 1] = k
        end
    end

    for k, item in pairs(self.item_list) do
        item:SetVisible(false)
    end
    for k, v in pairs(t) do
        self.item_list[v]:SetVisible(true)
    end

    local list = find(Config.db_item,str)

    local search_str = table.concat( list, ", ")

    self.input_text.text = search_str
    self.is_search = true
    self.text_serach_component.text = "Cancel search"
end

function GMSubPanel:CallBack(id)
    local cf = Config.db_gm[id]
    if not cf then
        return
    end
    local ip_str = ""
    if cf.gm_type == 1 then
        local str = self.input_text.text
        local tab = string.split(str, ",")
        local count = 0
        for k, v in string.gmatch(cf.gm, "-%%s") do
            count = count + 1
        end

        if count ~= 0 and #tab == count then
            str = string.format(cf.gm, unpack(tab))
            self.input_text.text = str
            self:SendGm(str)
        else
            str = string.gsub(cf.gm, "-%%s", "")
            str = str .. "-"
            self.input_text.text = str
        end
    elseif cf.gm_type == 2 then
        self.input_text.text = cf.gm
        self:SendGm(cf.gm)
    elseif cf.gm_type == 3 then
        -- self.input_text.text = cf.gm
    elseif cf.gm_type == 4 then
        -- self.input_text.text = cf.gm
    end
end

function GMSubPanel:UpdateInstruction(str)
    self.input_text.text = str
end

function GMSubPanel:CloseCallBack()
    if self.close_event then
        GlobalEvent:RemoveListener(self.close_event)
        self.close_event = nil
    end
    if self.update_histroy_event_id then
        GlobalEvent:RemoveListener(self.update_histroy_event_id)
        self.update_histroy_event_id = nil
    end
end