---
--- Created by  Administrator
--- DateTime: 2019/12/19 14:53
---
require('game.machinearmor.RequireMachineArmor')
MachineArmorController = MachineArmorController or class("MachineArmorController", BaseController)
local MachineArmorController = MachineArmorController

function MachineArmorController:ctor()
    MachineArmorController.Instance = self
    self.model = MachineArmorModel:GetInstance()
    self.events = {}
    self:AddEvents()
    self:RegisterAllProtocol()
end

function MachineArmorController:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function MachineArmorController:GetInstance()
    if not MachineArmorController.Instance then
        MachineArmorController.new()
    end
    return MachineArmorController.Instance
end

function MachineArmorController:AddEvents()

    local function call_back(default_tag)
        local isHaveAct = false
        for id, v in pairs(self.model.allMechas) do
            if self.model:IsActive(id) then
                isHaveAct = true
            end
        end
        
        if default_tag then
            if default_tag == 1  then
                if not   IsOpenModular(GetSysOpenDataById("1450@1"), GetSysOpenTaskById("1450@1")) then
                    Notify.ShowText("Mecha system locked")
                    return
                end
            elseif default_tag == 2 then
                if not   IsOpenModular(GetSysOpenDataById("1450@1"), GetSysOpenTaskById("1450@1")) then
                    Notify.ShowText("Mecha system locked")
                    return
                end
                if not isHaveAct then
                    default_tag = 1
                end
            else
                if not   IsOpenModular(GetSysOpenDataById("1450@1"), GetSysOpenTaskById("1450@1")) then
                    Notify.ShowText("Mecha system locked")
                    return
                end
                if  not IsOpenModular(GetSysOpenDataById("1450@3"), GetSysOpenTaskById("1450@3")) then
                    Notify.ShowText("Mecha Gear locked")
                    return
                end
                if not isHaveAct then
                    default_tag = 1
                end
            end
        end

        lua_panelMgr:GetPanelOrCreate(MachineArmorPanel):Open(default_tag)
    end
    GlobalEvent:AddListener(MachineArmorEvent.OpenMachineArmorPanel,call_back)


    local function callBack(id)
        --OpenTipModel:GetInstance():IsOpenSystem()
        --  logError(id)
        --print2(OpenTipModel:GetInstance():IsOpenSystem(570,1),"1111")
        if id == "1450@1" then
            self:RequstMechaListInfo()
        end
        --dump(OpenTipModel:GetInstance().syslist)
    end
    GlobalEvent:AddListener(MainEvent.CheckLoadMainIcon, callBack);

    local function call_back()
        self.model:CheckRedPoint()
    end
    GlobalEvent:AddListener(BagEvent.UpdateGoods, call_back)

    local function call_back()
        self.model:CheckRedPoint()
    end
    RoleInfoModel:GetInstance():GetMainRoleData():BindData(Constant.GoldType.mechaScore, call_back)
end

function MachineArmorController:RegisterAllProtocol()
    ---[[protobuff的模块名字，用到pb一定要写]]
    self.pb_module_name = "pb_1147_mecha_pb"

    self:RegisterProtocal(proto.MECHA_LIST, self.HandleMechaListInfo);
    self:RegisterProtocal(proto.MECHA_UPSTAR, self.HandleUpStarInfo);
    self:RegisterProtocal(proto.MECHA_UPGRADE, self.HandleUpGradeInfo);
    self:RegisterProtocal(proto.MECHA_SELECT, self.HandleSelectInfo);
    self:RegisterProtocal(proto.MECHA_EQUIP, self.HandleEquipInfo);
    self:RegisterProtocal(proto.MECHA_EQUIP_PUTON, self.HandleEquipPutOnInfo);
    self:RegisterProtocal(proto.MECHA_EQUIP_UPLEVEL, self.HandleEquipUpLevelInfo);
    self:RegisterProtocal(proto.MECHA_EQUIP_DECOMPOSE, self.HandleEquipDecomposeInfo);


end

-- overwrite
function MachineArmorController:GameStart()
    local function step()
        --BagController:GetInstance():RequestBagInfo(BagModel.mecha)
        self:RequstMechaListInfo()
        self:RequstAllEquipInfo()
    end
    GlobalSchedule:StartOnce(step, Constant.GameStartReqLevel.Ordinary)
end


function MachineArmorController:RequstAllEquipInfo()
    local tab = self.model.allMechas
    for id, _ in pairs(tab) do
        self:RequstEquipInfo(id)
    end
end


--列表
function MachineArmorController:RequstMechaListInfo()
    local pb = self:GetPbObject("m_mecha_list_tos")
    self:WriteMsg(proto.MECHA_LIST,pb)
end

function MachineArmorController:HandleMechaListInfo()
    local data = self:ReadMsg("m_mecha_list_toc")
    self.model:DealMechaInfo(data)
    self.model:Brocast(MachineArmorEvent.MechaListInfo,data)
    self.model:CheckRedPoint()
end

--升星
function MachineArmorController:RequstUpStarInfo(id)
    local pb = self:GetPbObject("m_mecha_upstar_tos")
    pb.id = id
    self:WriteMsg(proto.MECHA_UPSTAR,pb)
end

function MachineArmorController:HandleUpStarInfo()
    local data = self:ReadMsg("m_mecha_upstar_toc")
    self.model:SetMechaInfo(data.mecha)
    self.model:Brocast(MachineArmorEvent.MechaUpStarInfo,data)
    self.model:CheckRedPoint()
end

--升級
function MachineArmorController:RequstUpGradeInfo(id,item_id)
    local pb = self:GetPbObject("m_mecha_upgrade_tos")
    pb.id = id
    pb.item_id = item_id
    self:WriteMsg(proto.MECHA_UPGRADE,pb)

end

function MachineArmorController:HandleUpGradeInfo()
    local data = self:ReadMsg("m_mecha_upgrade_toc")
    self.model:SetMechaInfo(data.mecha)
    self.model:Brocast(MachineArmorEvent.MechaUpGradeInfo,data)
    self.model:CheckRedPoint()
end
--出战
function MachineArmorController:RequstSelectInfo(id)
    local pb = self:GetPbObject("m_mecha_select_tos")
    pb.id = id
    self:WriteMsg(proto.MECHA_SELECT,pb)
end

function MachineArmorController:HandleSelectInfo()
    local data = self:ReadMsg("m_mecha_select_toc")
    self.model.usedMecha = data.id
    self.model:Brocast(MachineArmorEvent.MechaSelectInfo,data)
end

--装备列表
function MachineArmorController:RequstEquipInfo(id)
    local pb = self:GetPbObject("m_mecha_equip_tos")
    pb.id = id
    self:WriteMsg(proto.MECHA_EQUIP,pb)
end

function MachineArmorController:HandleEquipInfo()
    local data = self:ReadMsg("m_mecha_equip_toc")
    self.model:DealEquipInfo(data)
    self.model:Brocast(MachineArmorEvent.MechaEquipInfo,data)
    self.model:CheckRedPoint()
end


--穿戴
function MachineArmorController:RequstEquipPutOnInfo(id,uid)
    local pb = self:GetPbObject("m_mecha_equip_puton_tos")
    pb.id = id
    pb.uid = uid
    self:WriteMsg(proto.MECHA_EQUIP_PUTON,pb)
end


function MachineArmorController:HandleEquipPutOnInfo()
    local data = self:ReadMsg("m_mecha_equip_puton_toc")
    self.model:Brocast(MachineArmorEvent.MechaEquipPutOnInfo,data)
    self.model:CheckRedPoint()
end

--装备升级
function MachineArmorController:RequstEquipUpLevelInfo(slot,id)
    local pb = self:GetPbObject("m_mecha_equip_uplevel_tos")
    pb.id = id
    pb.slot = slot
    self:WriteMsg(proto.MECHA_EQUIP_UPLEVEL,pb)
end

function MachineArmorController:HandleEquipUpLevelInfo()
    local data = self:ReadMsg("m_mecha_equip_uplevel_toc")
    self.model:Brocast(MachineArmorEvent.MechaEquipUpLevelInfo,data)
end


--分解
function MachineArmorController:RequstEquipDecomposeInfo(uids)
    local pb = self:GetPbObject("m_mecha_equip_decompose_tos")
    for i, uid in pairs(uids) do
        pb.uid:append(uid)
    end
    self:WriteMsg(proto.MECHA_EQUIP_DECOMPOSE,pb)
end

function MachineArmorController:HandleEquipDecomposeInfo()
    local data = self:ReadMsg("m_mecha_equip_decompose_toc")
    if self.model.selectEquip then
        self.model.selectEquip = {}
    end
    self.model:Brocast(MachineArmorEvent.MechaEquipDecomposeInfo,data)
end













