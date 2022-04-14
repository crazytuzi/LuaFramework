---
--- Author: R2D2
--- Date: 2019-02-14 17:39:47
---

FactionBattleDungeonPanel = FactionBattleDungeonPanel or class("FactionBattleDungeonPanel", DungeonMainBasePanel)
local this = FactionBattleDungeonPanel

function FactionBattleDungeonPanel:ctor()
    self.abName = "factionbattle"
    self.assetName = "FactionBattleDungeonPanel"

    self.dungeon_type = enum.SCENE_STYPE.SCENE_STYPE_GUILD_WAR
    self.use_background = false
    self.change_scene_close = true

    self.dataModel = FactionBattleModel:GetInstance()
    self.sceneId = SceneManager:GetInstance():GetSceneId()
    self.dataModel:SetCrystalInfo(self.sceneId)

    self.modelEvents = {}

end

function FactionBattleDungeonPanel:dctor()
    --if self.event_id_1 then
    --    self.model:RemoveListener(self.event_id_1)
    --    self.event_id_1 = nil
    --end

    self.dataModel:RemoveTabListener(self.modelEvents)
    self.modelEvents = {}
    self.dataModel = nil

    if (self.minimapView) then
        self.minimapView:destroy()
        self.minimapView = nil
    end

    if (self.countDownView) then
        self.countDownView:destroy()
        self.countDownView = nil
    end
end

function FactionBattleDungeonPanel:Open()
    FactionBattleDungeonPanel.super.Open(self)
end

function FactionBattleDungeonPanel:LoadCallBack()
    self.nodes = { "CountDownParent", }
    self:GetChildren(self.nodes)

    --self:InitUI()
    self:LoadSubPanel()
    self:AddEvent()
end

--function FactionBattleDungeonPanel:InitUI()
--end

function FactionBattleDungeonPanel:AddEvent()
    --local function call_back()
    --    OperationManager:GetInstance():StopAStarMove()
    --    AutoFightManager:GetInstance():StartAutoFight()
    --end
    --self.event_id_1 = self.dataModel:AddListener(DungeonEvent.ResEnterDungeonInfo, call_back)
    self.modelEvents[#self.modelEvents + 1] = self.dataModel:AddListener(FactionBattleEvent.FactionBattle_Model_RankListEvent, handler(self, self.OnRankList))
    self.modelEvents[#self.modelEvents + 1] = self.dataModel:AddListener(FactionBattleEvent.FactionBattle_Model_ActivityChange, handler(self, self.OnActivityChange))

end

function FactionBattleDungeonPanel: OnActivityChange()
     if( self.countDownView ) then
         self.countDownView:CheckCountDown()
     end
end

function FactionBattleDungeonPanel: OnRankList()
    lua_panelMgr:GetPanelOrCreate(FactionBattleSettlementPanel):Open()
end

function FactionBattleDungeonPanel:LoadSubPanel()
    self.minimapView = FactionBattleMinimapView(self.transform)
    SetAlignType(self.minimapView, bit.bor(AlignType.Left, AlignType.Null))

    self.countDownView = FactionBattleCountDownView(self.CountDownParent)
end


function MagicTowerDungeonPanel:OpenCallBack()
    self:UpdateView()
end

function MagicTowerDungeonPanel:UpdateView()
end

function MagicTowerDungeonPanel:CloseCallBack()
end
