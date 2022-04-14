PetEquipSettor = PetEquipSettor or class("PetEquipSettor", BaseBagGoodsSettor)

--宠物装备Settor
function PetEquipSettor:ctor(parent_node, layer)

    self.abName = "system"
    self.assetName = "EquipItem"
    self.layer = layer
    self.stepLbl = nil
    PetEquipSettor.super.Load(self)
end



function PetEquipSettor:LoadCallBack()
    self.nodes = {
        "upPowerTip",
        "downPowerTip",
        "notCantPutPutOn",
        "stepTxt",
    }

    self:GetChildren(self.nodes)
    self:InitUI()
    PetEquipSettor.super.LoadCallBack(self)
end

function PetEquipSettor:InitUI(  )
    self.stepTxt = GetText(self.stepTxt)
end

--重写父类的updateinfo方法
function PetEquipSettor:UpdateInfo(param)
    PetEquipSettor.super.UpdateInfo(self, param)

    if self.is_loaded then
        self:UpdateStep()
        self:UpdateStar()
    end
end

--刷新阶位
function PetEquipSettor:UpdateStep()
    local cfg = Config.db_pet_equip[self.id]
    self.stepTxt.text = cfg.order .. "Stage"
end

--刷新星数
function PetEquipSettor:UpdateStar()
    local cfg = Config.db_pet_equip[self.id]
    local star = cfg.star
    local startCount = self.starContain.childCount
    for i = 0, startCount - 1 do
        if i < star then
            SetVisible(self.starContain:GetChild(tostring(i)), true)
        else
            SetVisible(self.starContain:GetChild(tostring(i)), false)
        end

    end
end


