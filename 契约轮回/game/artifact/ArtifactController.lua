---
--- Created by  Administrator
--- DateTime: 2020/6/17 14:53
---
require('game.artifact.RequireArtifact')
ArtifactController = ArtifactController or class("ArtifactController", BaseController)
local ArtifactController = ArtifactController

function ArtifactController:ctor()
    ArtifactController.Instance = self
    self.model = ArtifactModel.GetInstance()
    self.events = {}
    self:AddEvents()
    self:RegisterAllProtocol()
end

function ArtifactController:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function ArtifactController:GetInstance()
    if not ArtifactController.Instance then
        ArtifactController.new()
    end
    return ArtifactController.Instance
end

function ArtifactController:AddEvents()

    local function call_back()
        lua_panelMgr:GetPanelOrCreate(ArtifactPanel):Open()
    end
    GlobalEvent:AddListener(ArtifactEvent.OpenArtifactPanel,call_back)

    local function call_back()
        self.model:CheckRedPoint()
    end
    GlobalEvent:AddListener(ArtifactEvent.ArtifactBagInfo,call_back)

    local function call_back()
        self.model:CheckRedPoint()
    end
    GlobalEvent:AddListener(BagEvent.UpdateGoods, call_back)

    local function call_back()
        self.model:CheckRedPoint()
    end
    RoleInfoModel:GetInstance():GetMainRoleData():BindData(Constant.GoldType.artScore1, call_back)
    RoleInfoModel:GetInstance():GetMainRoleData():BindData(Constant.GoldType.artScore2, call_back)
    RoleInfoModel:GetInstance():GetMainRoleData():BindData(Constant.GoldType.artScore3, call_back)
    RoleInfoModel:GetInstance():GetMainRoleData():BindData(Constant.GoldType.artScore4, call_back)
    RoleInfoModel:GetInstance():GetMainRoleData():BindData(Constant.GoldType.artScore5, call_back)
end

-- overwrite
function ArtifactController:GameStart()
    local function step()
        self:RequstArtifactListInfo()
        for i, v in pairs(self.model.FoldData) do
            self:RequstArtielemListInfo(i)
        end
        BagController:GetInstance():RequestBagInfo(BagModel.artifact)
    end
    GlobalSchedule:StartOnce(step, Constant.GameStartReqLevel.Ordinary)
end

function ArtifactController:RegisterAllProtocol()
    ---[[protobuff的模块名字，用到pb一定要写]]
    --self.pb_module_name = "protobuff_Name"
    self.pb_module_name = "pb_1149_artifact_pb"
    self:RegisterProtocal(proto.ARTIFACT_LIST, self.HandleArtifactListInfo)
    self:RegisterProtocal(proto.ARTIELEM_UPGRADE, self.HandleArtielemUpGradeInfo)
    self:RegisterProtocal(proto.ARTIFACT_REINF, self.HandleArtifactReinfInfo)
    self:RegisterProtocal(proto.ARTIFACT_PUTON, self.HandleArtifactPutOnInfo)
    self:RegisterProtocal(proto.ARTIFACT_PUTOFF, self.HandleArtifactPutOffInfo)
    self:RegisterProtocal(proto.ARTIFACT_ENCHANT, self.HandleArtifactEnchantInfo)
    self:RegisterProtocal(proto.ARTIELEM_LIST, self.HandleArtielemListInfo)

end


function ArtifactController:RequstArtifactListInfo()
    local pb = self:GetPbObject("m_artifact_list_tos");
    self:WriteMsg(proto.ARTIFACT_LIST, pb);
end

function ArtifactController:HandleArtifactListInfo()
    local data = self:ReadMsg("m_artifact_list_toc");
    self.model.artis = data.artis
   -- logError(Table2String(data))
    self.model:CheckRedPoint()
    self.model:Brocast(ArtifactEvent.ArtifactListInfo,data)
end


function ArtifactController:RequstArtielemListInfo(type)
    local pb = self:GetPbObject("m_artielem_list_tos");
    pb.type = type
    self:WriteMsg(proto.ARTIELEM_LIST, pb);
end


function ArtifactController:HandleArtielemListInfo()
    local data = self:ReadMsg("m_artielem_list_toc");
    self.model:DealArtielemInfo(data)
    self.model:CheckRedPoint()
    self.model:Brocast(ArtifactEvent.ArtielemListInfo,data)
end



function ArtifactController:RequstArtielemUpGradeInfo(type,artielemid)
    local pb = self:GetPbObject("m_artielem_upgrade_tos");
    pb.arti_type = type
    pb.elem_id = artielemid
    self:WriteMsg(proto.ARTIELEM_UPGRADE, pb);
end

function ArtifactController:HandleArtielemUpGradeInfo()
    local data = self:ReadMsg("m_artielem_upgrade_toc");
   -- logError("升级成功")
    Notify.ShowText("Upgraded")
  --  logError(data.is_unlock)
    --if data.is_unlock then
    --    self:RequstArtifactListInfo()
    --end
    self.model:SetUpGradeInfo(data)
    self.model:CheckRedPoint()
    self.model:Brocast(ArtifactEvent.ArtielemUpGradeInfo,data)
end


function ArtifactController:RequstArtifactReinfInfo(artifactid,materials)
    local pb = self:GetPbObject("m_artifact_reinf_tos");
    pb.arti_id = artifactid
    for i, uid in pairs(materials) do
        pb.materials:append(uid)
    end
   -- pb.item_id = itemid
    self:WriteMsg(proto.ARTIFACT_REINF, pb);
end

function ArtifactController:HandleArtifactReinfInfo()
    local data = self:ReadMsg("m_artifact_reinf_toc");
    Notify.ShowText("Enhanced")
    self.model:SetAriLv(data)
    if self.model.selectEquip then
        self.model.selectEquip = {}
    end
    self.model:CheckRedPoint()
    self.model:Brocast(ArtifactEvent.ArtifactReinfInfo,data)
end


function ArtifactController:RequstArtifactPutOnInfo(artifactid,itemuid)
    local pb = self:GetPbObject("m_artifact_puton_tos");
    pb.arti_id = artifactid
    pb.item_uid = itemuid
    self:WriteMsg(proto.ARTIFACT_PUTON, pb);
end

function ArtifactController:HandleArtifactPutOnInfo()
    local data = self:ReadMsg("m_artifact_puton_toc");
    self.model:AddEquip(data)
    self.model:CheckRedPoint()
    self.model:Brocast(ArtifactEvent.ArtifactPutOnInfo,data)
end


function ArtifactController:RequstArtifactPutOffInfo(artifactid,slot_id)
    local pb = self:GetPbObject("m_artifact_putoff_tos");
    pb.arti_id = artifactid
    pb.slot_id = slot_id
    self:WriteMsg(proto.ARTIFACT_PUTOFF, pb);
end

function ArtifactController:HandleArtifactPutOffInfo()
    local data = self:ReadMsg("m_artifact_putoff_toc");
    self.model:RemoveEquip(data)
    self.model:CheckRedPoint()
    self.model:Brocast(ArtifactEvent.ArtifactPutOffInfo,data)
end



function ArtifactController:RequstArtifactEnchantInfo(id)
    local pb = self:GetPbObject("m_artifact_enchant_tos");
    pb.arti_id = id
    self:WriteMsg(proto.ARTIFACT_ENCHANT, pb);
end

function ArtifactController:HandleArtifactEnchantInfo()
    local data = self:ReadMsg("m_artifact_enchant_toc");
    self.model:SetEnchant(data)
    self.model:CheckRedPoint()
    self.model:Brocast(ArtifactEvent.ArtifactEnchantInfo,data)
end












