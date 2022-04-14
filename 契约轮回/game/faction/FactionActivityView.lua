--
-- @Author: chk
-- @Date:   2018-12-05 11:51:41
--
FactionActivityView = FactionActivityView or class("FactionActivityView", BaseItem)
local this = FactionActivityView

function FactionActivityView:ctor(parent_node, layer)
    self.abName = "faction"
    self.assetName = "FactionActivityView"
    self.layer = layer

    self.model = FactionModel:GetInstance()
    FactionActivityView.super.Load(self)
end

function FactionActivityView:dctor()
    if self.emptyGirl ~= nil then
        self.emptyGirl:destroy()
    end

    --for _, item in pairs(self.panels) do
    --	item:destroy()
    --end

    if self.panels then
        self.panels:destroy()
    end
end

function FactionActivityView:LoadCallBack()

    self.nodes = {
        "HelpBtn",
        "girlContain",
        "PanelParent",
    }
    self:GetChildren(self.nodes)
    self:AddEvent()
    if self.loadAtCallback then
        self:LoadSubPanel(self.currentIndex)
    end
    self.loadAtCallback = nil;
    --self.emptyGirl = EmptyGirl(self.girlContain,ConfigLanguage.Mix.NotOpen)

end

function FactionActivityView:LoadSubPanel(index)
    if self.panels then
        self.panels:destroy();
    end
    self.panels = nil;
    self.currentIndex = index;
    if not self.PanelParent then
        self.loadAtCallback = true;
        return ;
    end
    if index == 1 then
        SetGameObjectActive(self.HelpBtn, true)
        self.panels = FactionBattlePanel(self.PanelParent, self)
    elseif index == 2 then
        SetGameObjectActive(self.HelpBtn)
        self.panels = GuildGuardEntrancePanel(self.PanelParent)
    elseif index == 3 then
        SetGameObjectActive(self.HelpBtn)
        self.panels = FactionSerWarMainPanel(self.PanelParent)
    end

end

function FactionActivityView:AddEvent()
    -- TODO  将来成为多个子页面时，要根据当前所在页判断弹出相应的说明
    local function helpTip ()
        ShowHelpTip(HelpConfig.FactionBattle.description, true)
    end
    AddClickEvent(self.HelpBtn.gameObject, helpTip)
end

function FactionActivityView:SetData(data)

end
