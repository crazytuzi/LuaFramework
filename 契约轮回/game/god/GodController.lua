---
--- Created by  Administrator
--- DateTime: 2019/9/6 15:10
---
require('game.god.RequireGod')
GodController = GodController or class("GodController", BaseController)
local GodController = GodController

function GodController:ctor()
    GodController.Instance = self
    self.model = GodModel:GetInstance()
    self.events = {}
    self:AddEvents()
    self:RegisterAllProtocol()
end

function GodController:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function GodController:GetInstance()
    if not GodController.Instance then
        GodController.new()
    end
    return GodController.Instance
end

function GodController:AddEvents()
    local function call_back(index)
        lua_panelMgr:GetPanelOrCreate(GodPanel):Open(index)
    end
    GlobalEvent:AddListener(GodEvent.OpenGodPanel, call_back)

    local function call_back()

        lua_panelMgr:GetPanelOrCreate(GodsActivityPanel):Open()
    end
    GlobalEvent:AddListener(GodEvent.OpenGodTargetPanel, call_back)

    local function call_back(id)
        if table.isempty(self.model.itemsId) then
            self.model:InitItems()
        end
        local cfg = Config.db_god_equip[id]
        if not cfg then
            self.model:CheckIsBatterEquip()
        end
        for i, v in pairs(self.model.itemsId) do
            if id == i then
                self.model:CheckRedPoint()
            end
        end
    end
    GlobalEvent:AddListener(BagEvent.UpdateGoods, call_back)

    local function call_back(data)
        if data.id == 171100 then
            self.model:UpdateGodsData(data)
        end
    end
    GlobalEvent:AddListener(OperateEvent.DLIVER_YY_INFO, call_back)

    local function call_back()
        if not self.model.rightState then
            local count = BagModel:GetInstance():GetItemNumByItemID(55403);
            if count >= self.model.needNum then
                GlobalEvent:Brocast(MainEvent.ChangeRedDot, "godtarget", true)
            else
                GlobalEvent:Brocast(MainEvent.ChangeRedDot, "godtarget", false)
            end
        end
    end
    GlobalEvent:AddListener(BagEvent.UpdateGoods, call_back)
    --GlobalEvent:AddListener(BagEvent.UpdateItems, call_back)
    --GlobalEvent:AddListener(BagEvent.AddItems, call_back)


    local function call_back()
        self.model:CheckRedPoint()
    end
    RoleInfoModel:GetInstance():GetMainRoleData():BindData(Constant.GoldType.GodScore, call_back)
   -- GlobalEvent:AddListener(BagEvent.AddItems, call_back)
end

function GodController:RegisterAllProtocol()
    ---[[protobuff的模块名字，用到pb一定要写]]
    --self.pb_module_name = "protobuff_Name"
    self.pb_module_name = "pb_1144_god_equips_pb"
    self:RegisterProtocal(proto.GOD_EQUIP, self.HandleGodEquipInfo);
    self:RegisterProtocal(proto.GOD_EQUIP_PUTON, self.HandleGodEquipPutOnInfo);
    self:RegisterProtocal(proto.GOD_EQUIP_UPLEVEL, self.HandleGodEquiUpLevelInfo);
    self:RegisterProtocal(proto.GOD_EQUIP_DECOMPOSE, self.HandleGodEquiDecomposeInfo);

end

-- overwrite
function GodController:GameStart()
    local function step()
        self:RequstGodEquipInfo()
    end
    GlobalSchedule:StartOnce(step, Constant.GameStartReqLevel.Ordinary)
end

function GodController:CheckRedPoint()
    
end

function GodController:RequstGodEquipInfo()
    local pb = self:GetPbObject("m_god_equip_tos")
    self:WriteMsg(proto.GOD_EQUIP,pb)
end


function GodController:HandleGodEquipInfo()
    local data = self:ReadMsg("m_god_equip_toc")
    self.model:DealEquipsInfo(data)
    self.model:Brocast(GodEvent.GodEquipInfo,data)
    self.model:CheckRedPoint()
   -- self.model:CheckIsBatterEquip()
end


function GodController:RequstGodEquipPutOnInfo(uid)
    local pb = self:GetPbObject("m_god_equip_puton_tos")
    pb.uid = uid
    self:WriteMsg(proto.GOD_EQUIP_PUTON,pb)
end

function GodController:HandleGodEquipPutOnInfo()
    local data = self:ReadMsg("m_god_equip_puton_toc")
    Notify.ShowText("Equipped")
    self.model:Brocast(GodEvent.GodEquipPutOnInfo,data)
end



function GodController:RequstGodEquipUpLevelInfo(slot)
    local pb = self:GetPbObject("m_god_equip_uplevel_tos")
    pb.slot = slot
    self:WriteMsg(proto.GOD_EQUIP_UPLEVEL,pb)
end

function GodController:HandleGodEquiUpLevelInfo()
    local data = self:ReadMsg("m_god_equip_uplevel_toc")

    self.model:Brocast(GodEvent.GodEquipUpLevelInfo,data)
end



function GodController:RequstGodEquipDecomposeInfo(uids)
    local pb = self:GetPbObject("m_god_equip_decompose_tos")
    for i, uid in pairs(uids) do
        pb.uid:append(uid)
    end
    self:WriteMsg(proto.GOD_EQUIP_DECOMPOSE,pb)
end


function GodController:HandleGodEquiDecomposeInfo()
    local data = self:ReadMsg("m_god_equip_decompose_toc")
    if self.model.selectEquip then
        self.model.selectEquip = {}
    end
    self.model:Brocast(GodEvent.GodEquipDecomposeInfo,data)
end









