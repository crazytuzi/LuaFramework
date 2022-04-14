---
--- Created by R2D2.
--- DateTime: 2019/6/25 14:37
---
UsePetView = UsePetView or class("UsePetView", BasePanel)
local UsePetView = UsePetView

function UsePetView:ctor()
    self.abName = "system"
    self.assetName = "UseGoodsView"
    self.layer = "Top"

    self.scheduleId = nil
    self.timeCount = 5
    self.globalEvents = {}
    self.model = PetModel.GetInstance()
    self.events = {}
    UsePetView.super.Open(self)
end

function UsePetView:dctor()

    GlobalEvent:RemoveTabListener(self.globalEvents)
    self.globalEvents = {}

    self.model:RemoveTabListener(self.events)
    self.events = nil

    self:StopSchedule()

    if self.iconSettor ~= nil then
        self.iconSettor:destroy()
        self.iconSettor = nil
    end
    if self.petData then
        self.model.pet_views[self.petData.uid] = nil
    end
   
end

function UsePetView:LoadCallBack()
    self.nodes = {
        "CloseBtn", "nameTxt", "icon", "useBtn", "useBtn/Text",
        "bg", "fram", "time",
    }
    self:GetChildren(self.nodes)

    self:InitUI()
    self:AddEvent()
    self:RefreshView()
end

function UsePetView:InitUI()
    self.nameText = GetText(self.nameTxt)
    self.timeText = GetText(self.time)
    self.btnText = GetText(self.Text)

    self.itemRectTra = self.transform
    self.bgRectTra = self.bg
    self.frameRectTra = self.fram

    --self.btnText.text = ConfigLanguage.Equip.Change
end

function UsePetView:AddEvent()

    self.globalEvents[#self.globalEvents + 1] = GlobalEvent:AddListener(PetEvent.Pet_RecommendEvent, handler(self, self.OnRecommendPet))

    local function call_back(uid)
        if self.petData.uid == uid then
            self:Close()
        end
    end
    self.events[#self.events+1] = GlobalEvent:AddListener(PetEvent.Pet_Model_DeleteBagPetEvent, call_back)

    local function call_back()
        self:Close()
    end
    AddClickEvent(self.CloseBtn.gameObject, call_back)

    AddClickEvent(self.useBtn.gameObject, handler(self, self.EquipPet))
end

---有新的推荐且与之前的为同阶，则关闭
function UsePetView:OnRecommendPet(pet)
    local cfg = Config.db_pet[pet.id]

    if(cfg and cfg.order == self.petCfg.order) then
        self:Close()
    end
end

function UsePetView:GetOperation()
    local fightingPet = self.model:GetFightingPet()
    local fightOrder = self.model.fight_order
    local operation = 0

    if(fightingPet) then
        ---比出战的评分高则直接出战
        if(self.petData.score > fightingPet.score) then
            operation = 1
        else
            ---否则保持原来的出战/助战状态
            operation = self.petData.order == fightOrder and 1 or 0
        end
    else
        ---还没有出战的，就直接出战了
        operation = 1
    end
    return operation
end

---装备宠物
function UsePetView:EquipPet()

    local operation = self:GetOperation()

    PetController:GetInstance():RequestPetSet(self.petData.uid, operation)
    self.model:SaveRequestPetSetValue(operation)

    self:Close()
end

function UsePetView:SetData(pet)
    self.petData = pet
    self.petCfg = Config.db_pet[pet.id]

    if (self.is_loaded) then
        self:RefreshView()
    end
end

function UsePetView:RefreshView()

    if (self.petData == nil) then
        return
    end

    local itemCfg = Config.db_item[self.petData.id]
    self.nameText.text = string.format("<color=#%s>%s</color>", ColorUtil.GetColor( itemCfg.color),  self.petCfg.name)

    local roleLevel = RoleInfoModel:GetInstance():GetRoleValue("level")
    if (roleLevel < 100) then
        self.bgRectTra.sizeDelta = Vector2(self.bgRectTra.sizeDelta.x, self.bgRectTra.sizeDelta.y + 30)
        self.frameRectTra.sizeDelta = Vector2(self.frameRectTra.sizeDelta.x, self.frameRectTra.sizeDelta.y + 30)

        self.timeText.text = string.format(ConfigLanguage.Equip.AutoPutOn, self.timeCount)
        self.scheduleId = GlobalSchedule:Start(handler(self, self.AutoPutOn), 1, 600)
    else
        ---大于100级，不显示倒计时，不自动装备
        self.timeText.text = ""
        self.scheduleId = GlobalSchedule:Start(handler(self, self.AutoClose), 1, 600)
    end

    self:RefreshGoodIcon()
    self:SetPanelPosition()
    if self:GetOperation() == 1 then
        self.btnText.text = "Deploy"
    else
        self.btnText.text = "Assist"
    end
end

function UsePetView:AutoClose()
    if self.timeCount == 0 then
        self:Close()
    else
        self.timeCount = self.timeCount - 1
    end
end

function UsePetView:AutoPutOn()
    if self.timeCount == 0 then
        self:EquipPet()
    else
        self.timeCount = self.timeCount - 1
        self.timeText.text = string.format(ConfigLanguage.Equip.AutoPutOn, self.timeCount)
    end
end

function UsePetView:RefreshGoodIcon()
    local param = {}
    param["cfg"] = self.petCfg
    param["bind"] = (self.petData.bind and 1 or 2)
    param["show_up_tip"] = true
    param["up_tip_action"] = true
    self.iconSettor = GoodsIconSettorTwo(self.icon)
    self.iconSettor:SetIcon(param)
end

function UsePetView:SetPanelPosition()
    local x = ScreenWidth - self.bgRectTra.sizeDelta.x - 100
    local y = -ScreenHeight + self.bgRectTra.sizeDelta.y + 150
    self.itemRectTra.anchoredPosition = Vector2(x, y)
end

function UsePetView:StopSchedule()
    if self.scheduleId ~= nil then
        GlobalSchedule:Stop(self.scheduleId)
        self.scheduleId = nil
    end
end