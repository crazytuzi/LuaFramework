--- Created by Admin.
--- DateTime: 2019/10/31 17:33
DungeonGodTipPanel = DungeonGodTipPanel or class("DungeonGodTipPanel", BasePanel)
local DungeonGodTipPanel = DungeonGodTipPanel

function DungeonGodTipPanel:ctor()
    self.abName = "dungeon"
    self.assetName = "DungeonGodTipPanel"
    self.layer = "Top"
    self.model = DungeonModel:GetInstance()
    self.use_background = true
    self.items = {}
    self.events = {}

    self.str = "You can farm to the highest wave you reached now (<color=green>%s</color>)"
end


function DungeonGodTipPanel:dctor()
    if self.items then
        for i, v in pairs(self.items) do
            v:destroy()
        end
        self.items = {}
    end
    if self.event_id_1 then
        self.model:RemoveListener(self.event_id_1)
        self.event_id_1 = nil
    end
    GlobalEvent:RemoveTabListener(self.events)
end

function DungeonGodTipPanel:Open(data)
    self.data = data
    DungeonGodTipPanel.super.Open(self)
end


function DungeonGodTipPanel:LoadCallBack()
    self.nodes = {
        "btn_close","state1","state2","state1/enter","state1/saodang","state2/sure_btn",
        "des","Scroll View/Viewport/Content",
    }
    self:GetChildren(self.nodes)
    self.desTex = GetText(self.des)
    self:InitUI()
    self:AddEvent()
end

function DungeonGodTipPanel:InitUI()
    SetVisible(self.state1.gameObject, self.data.type == 2)
    SetVisible(self.state2.gameObject, self.data.type == 1)
    self.desTex.text = string.format(self.str, self.model.godsMaxReword)

    local lv = self.model.godsMaxReword
    local items = {}

    for i = 1, lv do
        local c = Config.db_dunge_wave[30601 .."@".. i]
        local v = String2Table(c.reward)
        for i = 1, #v do
            if items[v[i][1]] then
                items[v[i][1]] = v[i][2] + items[v[i][1]]
            else
                items[v[i][1]] = v[i][2]
            end
        end
    end

    for i, v in pairs(items) do
        self.items[i] = GoodsIconSettorTwo(self.Content.transform)
        local param = {}
        param["item_id"] = i;
        param["can_click"] = true;
        self.items[i]:SetIcon(param)
    end

end

function DungeonGodTipPanel:AddEvent()
     local function call_back()
         self:Close()
     end
    AddClickEvent(self.btn_close.gameObject, call_back)

    local function call_back()
        self.data.enter_call()
    end
    AddClickEvent(self.enter.gameObject, call_back)

    local function call_back()
        self.data.saodang_call()
    end
    AddClickEvent(self.saodang.gameObject, call_back)
    AddClickEvent(self.sure_btn.gameObject, call_back)

    local function call_back()
        self:Close()
    end
    self.event_id_1 = self.model:AddListener(DungeonEvent.ResEnterDungeonInfo, call_back)
    GlobalEvent.AddEventListenerInTab(DungeonEvent.DUNGEON_SWEEP_REFRESH,call_back, self.events);
end

function DungeonGodTipPanel:CloseCallBack()

end