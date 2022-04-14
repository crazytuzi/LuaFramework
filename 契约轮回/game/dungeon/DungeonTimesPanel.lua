---
--- Created by  Administrator
--- DateTime: 2019/12/7 14:36
---
DungeonTimesPanel = DungeonTimesPanel or class("DungeonTimesPanel", WindowPanel)
local this = DungeonTimesPanel

function DungeonTimesPanel:ctor(parent_node, parent_panel)
    self.abName = "dungeon"
    self.assetName = "DungeonTimesPanel"
    self.image_ab = "dungeon_image";
    self.layer = "UI"
    self.events = {}
    self.use_background = true
    self.click_bg_close = true
    self.panel_type = 4
   -- self.model = BabyModel:GetInstance()
end



function DungeonTimesPanel:Open(itemID)
    self.itemID = itemID
    CompeteGuessPanel.super.Open(self)
end


function DungeonTimesPanel:dctor()
    if self.itemicon then
        self.itemicon:destroy()
    end

    GlobalEvent:RemoveTabListener(self.events)
    if self.role_buff_event_id then
        RoleInfoModel:GetInstance():GetMainRoleData():RemoveListener(self.role_buff_event_id);
    end
    self.role_buff_event_id = nil;
end

function DungeonTimesPanel:LoadCallBack()
    self.nodes = {
        "iconParent","useBtn","times","des",
    }
    self:GetChildren(self.nodes)
    self.times = GetText(self.times)
    self:InitUI()
    self:AddEvent()
end

function DungeonTimesPanel:InitUI()
    self:CreateIcon()
    local main_role_data = RoleInfoModel:GetInstance():GetMainRoleData()
    if main_role_data then
        local type = enum.BUFF_ID.BUFF_ID_WORLD_BOSS_KILL_TIRED
        if self.itemID == 11102 then
            type = enum.BUFF_ID.BUFF_ID_BEAST_BOSS_KILL_TIRED
        end
        local buffer = main_role_data:GetBuffByID(type)
        local value = (buffer and buffer.value or 0)
        local tired = 10;
        if Config.db_game["boss_tired"] then
            local val = String2Table(Config.db_game["boss_tired"].val);
            tired = tonumber(val[1]);
        end
        local curTired = SafetoNumber(tired) - SafetoNumber(value)
        local color = "3DB712"
        if curTired <= 0 then
            color = "cb0000"
        end
        self.times.text = string.format("Fatigue left：<color=#%s>%s</color>",color,curTired)
    end
end

function DungeonTimesPanel:AddEvent()
    local function call_back()
        local uid = BagModel:GetInstance():GetUidByItemID(self.itemID) or 0
        if uid == 0 then
            Notify.ShowText("No available items")
            return
        end
        GoodsController:GetInstance():RequestUseGoods(uid,1)
    end
    AddClickEvent(self.useBtn.gameObject,call_back)

    local function call_back(id)
        if id == self.itemID then
            self:Close()
        end
    end
    self.events[#self.events + 1] = GlobalEvent:AddListener(GoodsEvent.UseItemSuccess, call_back)
    --local function call_back(id)
    --    logError(id,"物品")
    --end
    --self.events[#self.events + 1] = GlobalEvent:AddListener(GoodsEvent.UseGiftSuccess, call_back)
    local function call_back()
        self:InitUI()
    end
    self.role_buff_event_id = RoleInfoModel:GetInstance():GetMainRoleData():BindData("buffs", call_back)
end
function DungeonTimesPanel:CreateIcon()
    if self.itemicon == nil then
        self.itemicon = GoodsIconSettorTwo(self.iconParent)
    end
    local param = {}
    param["model"] = self.model
    param["item_id"] = self.itemID
    --local num = BagModel:GetInstance():GetItemNumByItemID(self.itemID) or 0
    --local color = "eb0000"
    --if num >= 1 then
    --    color = "6CFE00"
    --end
   -- param["num"] = string.format("<color=#%s>%s/%s</color>",color,num,1)
    param["num"] = BagModel:GetInstance():GetItemNumByItemID(self.itemID) or 0
    param["show_num"] = true
    param["bind"] = 1
    param["can_click"] = true
    param["show_num"] = true
    self.itemicon:SetIcon(param)
end