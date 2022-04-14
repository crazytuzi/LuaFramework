---
--- Created by  R2D2
--- DateTime: 2019/4/2 19:30
---
require("game.pet.RequirePet")
PetController = PetController or class("PetController", BaseController)
local PetController = PetController

function PetController:ctor()
    PetController.Instance = self

    self.model = PetModel:GetInstance()
    self.pet_equip_model = PetEquipModel.GetInstance()
    self.events = {}
    self.model_events = {}
    self.role_events = {}
    self.pet_equip_model_events = {}
    self:AddEvents()
    self:RegisterAllProtocol()
end

function PetController:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    self.model:RemoveTabListener(self.model_events)

    if self.role_events then
        for _, event_id in pairs(self.role_events) do
            RoleInfoModel:GetInstance():GetMainRoleData():RemoveListener(event_id)
        end
        self.role_events = nil
    end

    self.pet_equip_model_events:RemoveTabListener(self.pet_equip_model_events_events)
end

function PetController:GetInstance()
    if not PetController.Instance then
        PetController.new()
    end
    return PetController.Instance
end
function PetController:AddEvents()

    self.events[#self.events + 1] = GlobalEvent:AddListener(EventName.ClosePanel, handler(self, self.OnGlobalPanelClose))

    self.events[#self.events + 1] = GlobalEvent:AddListener(PetEvent.Pet_OpenPanelEvent, handler(self, self.OnOpenPanel))
    self.events[#self.events + 1] = GlobalEvent:AddListener(BagEvent.PetBagDataEvent, handler(self, self.OnPetBagInfo))
    self.events[#self.events + 1] = GlobalEvent:AddListener(BagEvent.OtherBagAddEvent, handler(self, self.OnPetBagAdd))
    self.events[#self.events + 1] = GlobalEvent:AddListener(BagEvent.OtherBagDelEvent, handler(self, self.OnPetBagDel))
    self.events[#self.events + 1] = GlobalEvent:AddListener(BagEvent.OtherBagUpdateEvent, handler(self, self.OnPetBagUpdate))

    ---物品变化，用来刷新红点用
    self.events[#self.events + 1] = GlobalEvent:AddListener(BagEvent.UpdateGoods, handler(self, self.UpdateGoods))
    self.role_events[#self.role_events + 1] = RoleInfoModel:GetInstance():GetMainRoleData():BindData("money", handler(self, self.UpdateGoods))

    ---角色等级变化，用来刷新红点
    local function call_back()
        self.model:RefreshMainRedPoint()
    end
    self.role_events[#self.role_events + 1] = RoleInfoModel:GetInstance():GetMainRoleData():BindData("level", call_back)
    self.model_events[#self.model_events + 1] = self.model:AddListener(PetEvent.Pet_Model_ComposePetEvent, call_back)
    self.events[#self.events+1] = GlobalEvent:AddListener(EventName.UpdateOpenFunction, call_back)
end

function PetController:UpdateGoods()
    self.model:RefreshMainRedPoint()
end

function PetController:OnGlobalPanelClose(cname, layer, panelType)
    if (cname == "PetAcquirePanel") then
        self.model:TipClose()
    end
end

function PetController:OnOpenPanel(default_tag, default_tog)
    lua_panelMgr:GetPanelOrCreate(PetPanel):Open(default_tag, default_tog)
end

-- overwrite
function PetController:GameStart()
    local function step()
        self:RequestPetBagInfo()
        self:RequestPetInfo()
    end
    self.time_id = GlobalSchedule:StartOnce(step, Constant.GameStartReqLevel.Ordinary)
end

function PetController:RegisterAllProtocol()
    ---[[protobuff的模块名字，用到pb一定要写]]
    self.pb_module_name = "pb_1129_pet_pb"

    --self.pb_pet = "pb_1129_pet_pb"
    self.pb_bag = "pb_1101_bag_pb"
    self.pb_item = "pb_1102_item_pb"

    self:RegisterProtocal(proto.PET_INFO, self.HandlePetInfo)
    self:RegisterProtocal(proto.PET_SET, self.HandlePetSet)
    self:RegisterProtocal(proto.PET_STRONG, self.HandlePetStrong)
    self:RegisterProtocal(proto.PET_CROSS, self.HandlePetCross)
    self:RegisterProtocal(proto.PET_EVOLVE, self.HandlePetEvolution)
    self:RegisterProtocal(proto.PET_BACK, self.HandlePetBACK)
    self:RegisterProtocal(proto.PET_COMPOSE, self.HandlePetCompose)
    self:RegisterProtocal(proto.PET_DECOMPOSE, self.HandlePetDecompose)
    self:RegisterProtocal(proto.PET_EGG_RECORDS, self.HandleEggRecords)
    self:RegisterProtocal(proto.PET_SHOW, self.HandlePetShow)

    --self.pb_module_name = "pb_1101_bag_pb"
    --self:RegisterProtocal(proto.BAG_INFO, self.HandleBagInfo)
    --self:RegisterProtocal(proto.BAG_UPDATE, self.HandleBagUpdate)

    --宠物装备相关
    self:RegisterProtocal(proto.PET_EQUIPS, self.HandlePetEquips)
    self:RegisterProtocal(proto.PET_EQUIP_PUTON, self.HandlePetEquipPuton)
    self:RegisterProtocal(proto.PET_EQUIP_PUTOFF, self.HandlePetEquipPutoff)
    self:RegisterProtocal(proto.PET_EQUIP_REINF, self.HandlePetEquipReinf)
    self:RegisterProtocal(proto.PET_EQUIP_UPORDER, self.HandlePetEquipUporder)
    self:RegisterProtocal(proto.PET_EQUIP_SMELT, self.HandlePetEquipSmelt)
    self:RegisterProtocal(proto.PET_EQUIP_SPLIT, self.HandlePetEquipSplit)
    self:RegisterProtocal(proto.PET_EQUIP_INHERIT, self.HandlePetEquipInherit)
    
end

function PetController:OnPetBagAdd(bag_id, isTip, data)
    if (bag_id == PetModel.PetBag) then
        self.model:AddBagPet(data, true, isTip)
        self.model:RefreshMainRedPoint()
    end
end

function PetController:OnPetBagDel(bag_id, data)
    if (bag_id == PetModel.PetBag) then
        self.model:RemoveBagPet(data)
    end
end

function PetController:OnPetBagUpdate(bag_id, k, v)
    if (bag_id == PetModel.PetBag) then

    end
end

function PetController:OnPetBagInfo(data)
    if (data.bag_id == PetModel.PetBag) then
        self.model:SetBagPetList(data)
    end
end

---已上阵宠物
function PetController:HandlePetInfo()
    local data = self:ReadMsg("m_pet_info_toc")
    if (data) then
        if (#data.pets == 1 and data.pets[1].bag == PetModel.PetBag) then
            self.model:RepalceBagPet(data.pets[1])
        else
            self.model:SetBattlePetList(data)
            self.model:RefreshMainRedPoint()
        end
    end
end

---设置宠物状态
function PetController:HandlePetSet()
    local data = self:ReadMsg("m_pet_set_toc")
    if (data) then
        self.model:SetFightOrder(data.order)
    end
end

---训练宠物返回
function PetController:HandlePetStrong()
    local data = self:ReadMsg("m_pet_strong_toc")
    if (data) then
        self.model:OnTrainPet(data.order)
    end
end

---训练升段宠物返回
function PetController:HandlePetCross()
    local data = self:ReadMsg("m_pet_cross_toc")
    if (data) then
        self.model:OnCrossPet(data.order)
    end
end

---突破宠物返回
function PetController:HandlePetEvolution()
    local data = self:ReadMsg("m_pet_evolve_toc")
    if (data) then
        self.model:OnEvolutionPet(data.order)
    end
end

---退还突破宠物返回
function PetController:HandlePetBACK()
    local data = self:ReadMsg("m_pet_back_toc")
    if (data) then
        self.model:OnBackEvolutionPet(data.order)
    end
end

---整合宠物返回
function PetController:HandlePetCompose()
    local data = self:ReadMsg("m_pet_compose_toc")
    if (data) then
        self.model:OnComposePet(data.id, data.success)
    end
end

---分解宠物返回
function PetController:HandlePetDecompose()
    self.model:OnDecomposePet()
end

---开蛋记录返回
function PetController:HandleEggRecords()
    local data = self:ReadMsg("m_pet_egg_records_toc")
    if (data) then
        self.model:SetEggRecords(data)
    end
end

----以下为请求

---请求宠物背包
function PetController:RequestPetBagInfo()
    local pb = self:GetPbObject("m_bag_info_tos", self.pb_bag)
    pb.bag_id = PetModel.PetBag
    self:WriteMsg(proto.BAG_INFO, pb)
end

---请求出战宠物
function PetController:RequestPetInfo()
    local pb = self:GetPbObject("m_pet_info_tos")
    self:WriteMsg(proto.PET_INFO, pb)
end

---请求设置宠物出战，助阵
function PetController:RequestPetSet(uid, state)
    if self:IsInNewBeeSummon() then
        return Notify.ShowText("You can't control your pets in this scene")
    end
    local pb = self:GetPbObject("m_pet_set_tos")
    pb.uid = uid
    pb.is_fight = state
    self:WriteMsg(proto.PET_SET, pb)
end

---请求物品详细信息
function PetController:RequestItemInfo(pos, id)
    local pb = self:GetPbObject("m_item_detail_tos", self.pb_item)
    pb.pos = pos
    pb.id = id
    self:WriteMsg(proto.ITEM_DETAIL, pb)
end

---请求训练宠物
function PetController:RequestTrainPet(order)
    local pb = self:GetPbObject("m_pet_strong_tos")
    pb.order = order
    self:WriteMsg(proto.PET_STRONG, pb)
end

---请求训练升段宠物
function PetController:RequestCrossPet(order)
    local pb = self:GetPbObject("m_pet_cross_tos")
    pb.order = order
    self:WriteMsg(proto.PET_CROSS, pb)
end

---请求突破宠物
function PetController:RequestEvolutionPet(order)
    local pb = self:GetPbObject("m_pet_evolve_tos")
    pb.order = order
    self:WriteMsg(proto.PET_EVOLVE, pb)
end

---请求退还突破宠物
function PetController:RequestBackPet(order)
    local pb = self:GetPbObject("m_pet_back_tos")
    pb.order = order
    self:WriteMsg(proto.PET_BACK, pb)
end

---请求融合宠物
function PetController:RequestComposePet(id, uids)
    local pb = self:GetPbObject("m_pet_compose_tos")

    pb.id = id
    for k, _ in pairs(uids) do
        pb.uids:append(k)
    end

    self:WriteMsg(proto.PET_COMPOSE, pb)
end

---请求分解宠物
function PetController:RequestDecomposePet(uids)
    local pb = self:GetPbObject("m_pet_decompose_tos")

    for _, v in pairs(uids) do
        pb.uids:append(v)
    end

    self:WriteMsg(proto.PET_DECOMPOSE, pb)
end

---请求宠物开蛋记录
function PetController:RequestEggRecords()
    local pb = self:GetPbObject("m_pet_egg_records_tos")
    self:WriteMsg(proto.PET_EGG_RECORDS, pb)
end

function PetController:HandlePetShow()
    local data = self:ReadMsg("m_pet_show_toc")

    local pet = data.pet
    local p = Config.db_pet[pet.id]
    if p.quality >= PetModel.DecomposeQualityDivide then
        table.insert(self.model.TipPets, 1, { ["Data"] = pet, ["Config"] = p, ["IsInBag"] = true, ["IsFighting"] = false })
        self.model:CheckTip()
    end
end

--是否在人鱼副本
function PetController:IsInNewBeeSummon()
    local scene_id = SceneManager:GetInstance():GetSceneId()
    local scenecfg = Config.db_scene[scene_id]
    return scenecfg.stype == enum.SCENE_STYPE.SCENE_STYPE_DUNGE_NEWBIE_SUMMON
end

-------------------宠物装备相关请求与返回处理函数-----------------

---请求宠物装备列表
function PetController:RequestPetEquips(pet_id)
    local pb = self:GetPbObject("m_pet_equips_tos")
    pb.pet_id = pet_id;
    self:WriteMsg(proto.PET_EQUIPS, pb)
    --logError("请求宠物装备列表,pet_id-"..pet_id)
    
end

--宠物装备列表返回处理
function PetController:HandlePetEquips()
    local data = self:ReadMsg("m_pet_equips_toc")
    --logError("宠物装备列表返回"..Table2String(data.equips))
    self.pet_equip_model:HandlePetEquips(data.pet_id,data.equips)
    self.pet_equip_model:Brocast(PetEquipEvent.HandlePetEquips,data.pet_id,data.equips)
end

---请求宠物装备穿戴
function PetController:RequestPetEquipPuton(pet_id,equip_id)
    local pb = self:GetPbObject("m_pet_equip_puton_tos")
    pb.pet_id = pet_id;
    pb.equip_id = equip_id;
    self:WriteMsg(proto.PET_EQUIP_PUTON, pb)
    --logError("请求宠物装备穿戴")
    
end

--宠物装备穿戴返回处理
function PetController:HandlePetEquipPuton()
    local data = self:ReadMsg("m_pet_equip_puton_toc")
    --logError("宠物装备穿戴返回")
    self.pet_equip_model:HandlePetEquipPuton(data.pet_id,data.slot,data.equip)
    self.pet_equip_model:Brocast(PetEquipEvent.HandlePetEquipPuton,data.pet_id,data.slot,data.equip)

    --重新请求宠物装备列表
    self:RequestPetEquips(data.pet_id)
end

---请求宠物装备卸下
function PetController:RequestPetEquipPutoff(pet_id,slot)
    local pb = self:GetPbObject("m_pet_equip_putoff_tos")
    pb.pet_id = pet_id;
    pb.slot = slot;
    self:WriteMsg(proto.PET_EQUIP_PUTOFF, pb)
    --logError("请求宠物装备卸下")
    
end

--宠物装备卸下返回处理
function PetController:HandlePetEquipPutoff()
    local data = self:ReadMsg("m_pet_equip_putoff_toc")
    --logError("宠物装备卸下返回")

    self.pet_equip_model:HandlePetEquipPutoff(data.pet_id,data.slot)
    self.pet_equip_model:Brocast(PetEquipEvent.HandlePetEquipPutoff,data.pet_id,data.slot)
    
    --重新请求宠物装备列表
    self:RequestPetEquips(data.pet_id)
end

---请求宠物装备强化
function PetController:RequestPetEquipReinf(pet_id,slot)
    local pb = self:GetPbObject("m_pet_equip_reinf_tos")
    pb.pet_id = pet_id;
    pb.slot = slot;
    self:WriteMsg(proto.PET_EQUIP_REINF, pb)

    --logError("请求宠物装备强化")
end

--宠物装备强化返回处理
function PetController:HandlePetEquipReinf()
    local data = self:ReadMsg("m_pet_equip_reinf_toc")

    self.pet_equip_model:HandlePetEquipReinf(data.pet_id,data.slot,data.equip)
    self.pet_equip_model:Brocast(PetEquipEvent.HandlePetEquipReinf,data.pet_id,data.slot,data.equip)
    
    --重新请求宠物装备列表
    self:RequestPetEquips(data.pet_id)
    --logError("宠物装备强化返回")
end

---请求宠物装备升阶
function PetController:RequestPetEquipUporder(pet_id,slot)
    local pb = self:GetPbObject("m_pet_equip_uporder_tos")
    pb.pet_id = pet_id;
    pb.slot = slot;
    self:WriteMsg(proto.PET_EQUIP_UPORDER, pb)

    --logError("请求宠物装备升阶")
end

--宠物装备升阶返回处理
function PetController:HandlePetEquipUporder()
    local data = self:ReadMsg("m_pet_equip_uporder_toc")

    self.pet_equip_model:HandlePetEquipUporder(data.pet_id,data.slot,data.equip)
    self.pet_equip_model:Brocast(PetEquipEvent.HandlePetEquipUporder,data.pet_id,data.slot,data.equip)
    
    --重新请求宠物装备列表
    self:RequestPetEquips(data.pet_id)
    --logError("宠物装备升阶返回")
end

---请求宠物装备分解
function PetController:RequestPetEquipSmelt(item_uids)
    local pb = self:GetPbObject("m_pet_equip_smelt_tos")
    for k, v in pairs(item_uids) do
        pb.item_uid:append(k)
    end
    self:WriteMsg(proto.PET_EQUIP_SMELT, pb)

    --logError("请求宠物装备分解")
end

--宠物装备分解返回处理
function PetController:HandlePetEquipSmelt()
    local data = self:ReadMsg("m_pet_equip_smelt_toc")

    self.pet_equip_model:Brocast(PetEquipEvent.HandlePetEquipSmelt,data.refund)

    --logError("宠物装备分解返回")
end

---请求宠物装备拆解
function PetController:RequestPetEquipSplit(item_uid)
    local pb = self:GetPbObject("m_pet_equip_split_tos")
    pb.item_uid = item_uid
    self:WriteMsg(proto.PET_EQUIP_SPLIT, pb)

    --logError("请求宠物装备拆解")
end

--宠物装备拆解返回处理
function PetController:HandlePetEquipSplit()
    local data = self:ReadMsg("m_pet_equip_split_toc")

    self.pet_equip_model:Brocast(PetEquipEvent.HandlePetEquipSplit,data.equip,data.refund)
    BagController.GetInstance():RequestBagInfo(BagModel.PetEquip)
    --logError("宠物装备拆解返回")
end

---请求宠物装备继承
function PetController:RequestPetEquipInherit(src_item_uid,dst_item_uid)
    local pb = self:GetPbObject("m_pet_equip_inherit_tos")
    pb.src_item_uid = src_item_uid
    pb.dst_item_uid = dst_item_uid
    self:WriteMsg(proto.PET_EQUIP_INHERIT, pb)

    --logError("请求宠物装备继承,src_item_uid:"..src_item_uid..",dst_item_uid:"..dst_item_uid)
end

--宠物装备继承返回处理
function PetController:HandlePetEquipInherit()
    local data = self:ReadMsg("m_pet_equip_inherit_toc")

    self.pet_equip_model:Brocast(PetEquipEvent.HandlePetEquipInherit,data.src_item,data.dst_item)

    --logError("宠物装备继承返回")
end