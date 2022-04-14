--宠物装备背包项Goods 负责UI显示刷新，被icon settor持有
PetEquipBagGoodsSettor = PetEquipBagGoodsSettor or class("PetEquipBagGoodsSettor", BaseBagGoodsSettor)

function PetEquipBagGoodsSettor:ctor(parent_node, layer)

    self.abName = "system"
    self.assetName = "EquipItem"
    self.layer = layer


    self.pet_equip_model = PetEquipModel.GetInstance()

    self.pet_equip_cfg = nil

    PetEquipBagGoodsSettor.super.Load(self)

    self.pet_equip_effect = nil
end

function PetEquipBagGoodsSettor:dctor()

    if self.pet_equip_effect then
        self.pet_equip_effect:destroy()
        self.pet_equip_effect = nil
    end
end




function PetEquipBagGoodsSettor:LoadCallBack()
    self.nodes = {
        "upPowerTip",
        "downPowerTip",
        "notCantPutPutOn",
        "stepTxt",
    }

    self:GetChildren(self.nodes)
    self:InitUI()
    PetEquipBagGoodsSettor.super.LoadCallBack(self)
end

function PetEquipBagGoodsSettor:InitUI(  )
    self.stepTxt = GetText(self.stepTxt)
end

--重写父类的updateinfo方法
function PetEquipBagGoodsSettor:UpdateInfo(param)
    --local item = param["item"]
    local index = param["itemIndex"]
    local item = param["get_item_cb"](index)
    local order = item.misc.stren_phase
    self.pet_equip_cfg = self.pet_equip_model.pet_equip_cfg[item.id][order]
    if not self.pet_equip_cfg then
       logError("PetEquipBagGoodsSettor 没有 宠物装备配置,id"..item.id..",阶位"..order)
       return
    end

    param["custom_icon_id"] = self.pet_equip_cfg.icon

    PetEquipBagGoodsSettor.super.UpdateInfo(self, param)

   
    

    if self.is_loaded then
        self:UpdateStep()
        self:UpdateStar()
        self:UpdateStrenLv(item.misc.stren_lv)
        self:UpdatePetEquipEeffect(param["pet_equip_effect_id"])
    end
end

--刷新阶位
function PetEquipBagGoodsSettor:UpdateStep()
    if not self.pet_equip_cfg then
        SetVisible(self.stepTxt,false)
        return
    end
    SetVisible(self.stepTxt,true)
    self.stepTxt.text = "T" .. self.pet_equip_cfg.order
end

--刷新星数
function PetEquipBagGoodsSettor:UpdateStar()
    if not self.pet_equip_cfg then
        SetVisible(self.starContain,false)
        return
    end
    SetVisible(self.starContain,true)
    local star = self.pet_equip_cfg.star
    local startCount = self.starContain.childCount
    for i = 0, startCount - 1 do
        if i < star then
            SetVisible(self.starContain:GetChild(tostring(i)), true)
        else
            SetVisible(self.starContain:GetChild(tostring(i)), false)
        end

    end
end

--刷新强化等级
function PetEquipBagGoodsSettor:UpdateStrenLv(stren_lv)
    if stren_lv == 0 then
        SetVisible(self.countBG.gameObject,false)
        return
    end

    SetVisible(self.countBG.gameObject,true)
    self.countTxt.text = "+"..stren_lv
end

--刷新宠物装备特效
function PetEquipBagGoodsSettor:UpdatePetEquipEeffect(effect_id)
    if effect_id then
        if self.pet_equip_effect then
            SetVisible(self.pet_equip_effect.transform,true)
        else

            self.pet_equip_effect =  UIEffect(self.icon,effect_id)
            local pos = { x = 0, y = 0, z = 0 }
           
            self.pet_equip_effect:SetConfig({useStencil = true, stencilId = self.stencil_id, stencilType = 3, pos = pos })
        end

       
    else 
        if self.pet_equip_effect and self.pet_equip_effect.transform then
            SetVisible(self.pet_equip_effect.transform,false)
        end
    end
end

