--宠物装备辅助类
PetEquipHelper = PetEquipHelper or class("PetEquipHelper", BaseController)

function PetEquipHelper:ctor()
    PetEquipHelper.Instance = self

    self.pet_equip_model = PetEquipModel.GetInstance()
end

function PetEquipHelper:dctor()
  
end

function PetEquipHelper.GetInstance()
    if not PetEquipHelper.Instance then
        PetEquipHelper.new()
    end
    return PetEquipHelper.Instance
end

--穿上宠物装备
function PetEquipHelper:PutOnPetEquip(param)
    --logError("穿上宠物装备")
    PetController.GetInstance():RequestPetEquipPuton(self.pet_equip_model.cur_pet_data.Config.order,param[1])
end

--分解宠物装备
function PetEquipHelper:DecomposePetEquip(param)
    --logError("分解宠物装备")

    local item = param[1]
    local cfg = self.pet_equip_model.pet_equip_cfg[item.id][item.equip.stren_phase]
  
    local function call_back(  )
        local tbl = {}
        tbl[item.uid] = true
        PetController.GetInstance():RequestPetEquipSmelt(tbl)
        GlobalEvent:Brocast(GoodsEvent.CloseTipView)
    end

    --橙色以上需要有提示框
    if cfg.color >= 5 then
        local message = string.format( "This's a rare pet gear, sure to dismantle?\n Can get Pet Gear EXP *%s",cfg.exp) 
        Dialog.ShowTwo('Tip',message,'Confirm',call_back,nil,'Cancel',nil,nil,nil)
    else
        call_back()
    end
end

--上架宠物装备
function PetEquipHelper:PutOnSellPetEquip(param)
    --logError("上架宠物装备")
    GlobalEvent:Brocast(MarketEvent.UpShelfMarketUpBtn, 1,true)
    MarketModel.GetInstance().selectItem = param[1]
    GlobalEvent:Brocast(GoodsEvent.CloseTipView)
end

--拆解宠物装备
function PetEquipHelper:DismantlePetEquip(param)
    --logError("拆解宠物装备")

    local item = param[1]
    local cfg = self.pet_equip_model.pet_equip_cfg[item.id][item.equip.stren_phase]

    local function call_back(  )
        PetController.GetInstance():RequestPetEquipSplit(item.uid)
        GlobalEvent:Brocast(GoodsEvent.CloseTipView)
    end

    local message = "This's a rare pet gear, sure to dismantle?\n Can get"

    local cost = String2Table(cfg.costtotle)
    for k,v in pairs(cost) do
        local name = Config.db_item[v[1]].name
        local num = v[2]
        message = string.format( message.."%s*%s,",name,num)
    end

    local exp = self:GetDismantleExp(item.id,item.equip.stren_lv)
    message = string.format(message .. "Pet Gear*%s",exp)

    Dialog.ShowTwo('Tip',message,'Confirm',call_back,nil,'Cancel',nil,nil,nil)
end

--合成宠物装备
function PetEquipHelper:ComposePetEquip(param)
    --logError("合成宠物装备")

    OpenLink(unpack(param[2]))
    GlobalEvent:Brocast(GoodsEvent.CloseTipView)
end

--继承宠物装备
function PetEquipHelper:InheritPetEquip(param)
    --logError("继承宠物装备")
end

--进阶宠物装备
function PetEquipHelper:MoveUpPetEquip(param)
    --logError("进阶宠物装备")
    local item = param[1]
    local index = 1
    for k,v in pairs(self.pet_equip_model.cur_pet_equips) do
        if item.uid == v.uid then
           break;
        end
        index = index + 1
    end


    local panel = lua_panelMgr:GetPanelOrCreate(PetEquipStrengthenPanel)
    local data = {}
    data.select_index = index
	panel:Open()
    panel:SetData(data)
    
    GlobalEvent:Brocast(GoodsEvent.CloseTipView)
end

--卸下宠物装备
function PetEquipHelper:TakeOffPetEquip(param)
    --logError("卸下宠物装备")

    local function ok_func(  )
        PetController.GetInstance():RequestPetEquipPutoff(self.pet_equip_model.cur_pet_data.Config.order,param[1])
        GlobalEvent:Brocast(GoodsEvent.CloseTipView)
    end

    --检查是否有已生效的宠物套装效果
    if self.pet_equip_model:CheckAllSuit(self.pet_equip_model.cur_pet_data.Config.id,self.pet_equip_model.cur_pet_data.Config.order) then
        local message = "Remove the gear will disable the suit bonus, continue?"
        Dialog.ShowTwo('Tip',message,'Confirm',ok_func,nil,'Cancel',nil,nil,nil)
    else
        ok_func()
    end

   
end

--获取tip操作参数
function PetEquipHelper:GetOperateParam(item)
    
    local operate_param = {}

    if lua_panelMgr:GetPanel(PetEquipSuitPanel) then
        --套装界面 不可以进行tip操作
        return operate_param
    end

   

    local pet_equip_cfg = self.pet_equip_model.pet_equip_cfg[item.id][item.equip.stren_phase]
    local pet_cfg = self.pet_equip_model.cur_pet_data.Config
    local slot_item = self.pet_equip_model:GetPutOnBySlot(pet_equip_cfg.slot) 

    --是否在背包中
    local is_in_bag = not slot_item or slot_item.uid ~= item.uid

    --是否已装备
    local is_in_pet = slot_item and slot_item.uid == item.uid

    -- not self.pet_equip_model:GetPutOnBySlot(pet_equip_cfg.slot)

    --判断是否可穿戴
    if  is_in_bag
        and self:CheckEquipLimit(self.pet_equip_model.cur_pet_data.Config.quality,pet_equip_cfg)
        and self:IsPetAvtive()
    then
        GoodsTipController.Instance:SetPutOnCB(operate_param, handler(self, self.PutOnPetEquip), { item.uid })
    end

    --判断是否可分解
    if is_in_bag and item.equip.stren_lv == 0 then
        GoodsTipController.Instance:SetDecomposeCB(operate_param, handler(self, self.DecomposePetEquip), { item })        
    end

    --判断是否可拆解
    if is_in_bag and item.equip.stren_lv >= 1 then
        GoodsTipController.Instance:SetDismantleCB(operate_param, handler(self, self.DismantlePetEquip), { item })
    end

    --判断是否可进阶
    if is_in_pet and item.equip.stren_lv == item.equip.stren_phase * 10 and pet_equip_cfg.color >= 4  then
        GoodsTipController.Instance:SetMoveUpCB(operate_param, handler(self, self.MoveUpPetEquip), { item })
    end

    --判断是否可上架
    if is_in_bag and item.equip.stren_lv == 0  then
        GoodsTipController.Instance:SetPutOnSellCB(operate_param, handler(self, self.PutOnSellPetEquip), { item })
    end

    --判断是否可合成
    local item_cfg = Config.db_item[item.id]
    
    if item_cfg and item_cfg.compose and not table.isempty(String2Table(item_cfg.compose)) and is_in_bag and item.equip.stren_phase == 1 and item.equip.stren_lv == 0  then
        GoodsTipController.Instance:SetComposeCB(operate_param, handler(self, self.ComposePetEquip), { item,String2Table(item_cfg.compose) })
    end

    if false then
        GoodsTipController.Instance:SetInheritCB(operate_param, handler(self, self.InheritPetEquip), { item })
    end
   
    --判断是否可卸下
    if is_in_pet then
        GoodsTipController.Instance:SetTakeOffCB(operate_param, handler(self, self.TakeOffPetEquip), { pet_equip_cfg.slot })
    end

    return operate_param
end

--宠物是否激活
function PetEquipHelper:IsPetAvtive()
    local flag = true

    if self.pet_equip_model.cur_pet_data.Data then
        if  self.pet_equip_model.cur_pet_data.IsActive then
           local is_overdue = self.pet_equip_model.cur_pet_data:CheckOverdue()
           if is_overdue then
                --过期了
               flag = false
           end 
        else
            --未激活
            flag = false
        end
    else
        --没Data
        flag = false
    end

    return flag
end

--获取宠物装备拆解后能获得的宠物装备经验
function PetEquipHelper:GetDismantleExp(item_id,stren_lv)
    local exp = 0
    local slot = Config.db_item[item_id].stype
    for i=0,stren_lv - 1 do
        local stren_cfg = Config.db_pet_equip_strength[slot .. "@" .. i]
        local cost = String2Table(stren_cfg.cost)
        exp = exp + cost[2]
    end
    return exp
end

--装备穿戴限制
function PetEquipHelper:CheckEquipLimit(quality,cfg)

    local limit = String2Table(cfg.limit)[1][2]

    

    return limit <= quality
    

    -- if quatily <= 4 then
    --     return false
    -- elseif quatily == 5 then
    --     if cfg.color <= 5 then
    --         return true
    --     end
    -- elseif quatily == 6 then
    --     if cfg.color <= 6 and cfg.star <= 2 then
    --         return true
    --     end
    -- elseif quatily == 7 then
    --     if cfg.color <= 6 and cfg.star <= 3 then
    --         return true
    --     end
    -- elseif quatily == 8 then
    --     return true
    -- end

    -- return false
end
