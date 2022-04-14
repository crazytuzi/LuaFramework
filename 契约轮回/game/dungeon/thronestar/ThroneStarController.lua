---
--- Created by  Administrator
--- DateTime: 2020/3/31 17:23
---
require('game.dungeon.thronestar.RequireThroneStar')
ThroneStarController = ThroneStarController or class("ThroneStarController", BaseController)
local ThroneStarController = ThroneStarController

function ThroneStarController:ctor()
    ThroneStarController.Instance = self
    self.model = ThroneStarModel:GetInstance()
    self.events = {}
    self:AddEvents()
    self:RegisterAllProtocol()
end

function ThroneStarController:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function ThroneStarController:GetInstance()
    if not ThroneStarController.Instance then
        ThroneStarController.new()
    end
    return ThroneStarController.Instance
end

function ThroneStarController:AddEvents()

    local function call_back()
        lua_panelMgr:GetPanelOrCreate(CrossPanel):Open(1,4)
    end
    GlobalEvent:AddListener(ThroneStarEvent.OpenThronePanel,call_back)

    local function call_back(show,id)
        if id == self.model.actId and show then
            if self.model.sceneIds[SceneManager:GetInstance():GetSceneId()]  then
                return
            end
            local function call_back()
                lua_panelMgr:GetPanelOrCreate(CrossPanel):Open(1,4)
            end
            Dialog.ShowTwo("Tip", "Throne of Star luanched, switch to that page?", "Yes", call_back, nil, "Cancel");
        end
    end
    GlobalEvent:AddListener(ActivityEvent.ChangeActivity,call_back)
end

function ThroneStarController:RegisterAllProtocol()
    ---[[protobuff的模块名字，用到pb一定要写]]
    self.pb_module_name = "pb_1610_throne_pb"
    self:RegisterProtocal(proto.THRONE_PANEL, self.HandlePanelInfo);
    self:RegisterProtocal(proto.THRONE_BOSS, self.HandleBossListInfo);
    self:RegisterProtocal(proto.THRONE_BOSS_UPDATE, self.HandleBossUpdateInfo);
    self:RegisterProtocal(proto.THRONE_DAMAGE, self.HandleDamageInfo);
    self:RegisterProtocal(proto.THRONE_SCORE, self.HandleScoreInfo);
    self:RegisterProtocal(proto.THRONE_IS_UNLOCK, self.HandleLockInfo);


end

-- overwrite
function ThroneStarController:GameStart()

end


function ThroneStarController:RequestPanelInfo()
    local pb = self:GetPbObject("m_throne_panel_tos")
    self:WriteMsg(proto.THRONE_PANEL,pb)
end

function ThroneStarController:HandlePanelInfo()
    local data = self:ReadMsg("m_throne_panel_toc")
    self.model.isLock = data.unlock
    self.model:Brocast(ThroneStarEvent.ThronePanelInfo,data)
end



function ThroneStarController:RequestBossListInfo()
    local pb = self:GetPbObject("m_throne_boss_tos")
    self:WriteMsg(proto.THRONE_BOSS,pb)
end

function ThroneStarController:HandleBossListInfo()
    local data = self:ReadMsg("m_throne_boss_toc")
   -- self.model.bossInfos = data.bosses
    self.model:DealBossInfo(data.bosses)
    self.model:Brocast(ThroneStarEvent.ThroneBossListInfo,data)
end

function ThroneStarController:HandleBossUpdateInfo()
    local data = self:ReadMsg("m_throne_boss_update_toc")
    if self.model.bossInfos[data.id] then
        self.model.bossInfos[data.id].born = data.born
    end
    self.model:Brocast(ThroneStarEvent.ThroneBossUpdateInfo,data)
end


function ThroneStarController:RequestDamageInfo(bossID)
    local pb = self:GetPbObject("m_throne_damage_tos")
   -- logError("请求bossId：",bossID)
    pb.boss_id = bossID
    self:WriteMsg(proto.THRONE_DAMAGE,pb)
end


function ThroneStarController:HandleDamageInfo()
    local data = self:ReadMsg("m_throne_damage_toc")
    self.model:Brocast(ThroneStarEvent.ThroneDamageInfo,data)
end

function ThroneStarController:RequestScoreInfo()
    local pb = self:GetPbObject("m_throne_score_tos")
    self:WriteMsg(proto.THRONE_SCORE,pb)
end



function ThroneStarController:HandleScoreInfo()
    local data = self:ReadMsg("m_throne_score_toc")
    self.model:Brocast(ThroneStarEvent.ThroneScoreInfo,data)
end



function ThroneStarController:RequestLockInfo()
    local pb = self:GetPbObject("m_throne_is_unlock_tos")
    self:WriteMsg(proto.THRONE_IS_UNLOCK,pb)
end

function ThroneStarController:HandleLockInfo()
    local data = self:ReadMsg("m_throne_is_unlock_toc")
    self.model.isLock = data.unlock
    --logError("解锁",self.model.isLock )
    self.model:Brocast(ThroneStarEvent.ThroneLockInfo,data)
end














