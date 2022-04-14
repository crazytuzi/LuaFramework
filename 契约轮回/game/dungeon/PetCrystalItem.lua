PetCrystalItem = PetCrystalItem or class("PetCrystalItem", Node)
local this = PetCrystalItem

function PetCrystalItem:ctor(obj, data, index)
    self.transform = obj.transform
    self.gameObject = self.transform.gameObject;
    self.data = data;
    self.index = index
    self.image_ab = "dungeon_image";
    self.transform_find = self.transform.Find;
    self.events = {};
    self:Init();
    self:AddEvents();
end

function PetCrystalItem:dctor()
    GlobalEvent:RemoveTabListener(self.events);
    self.staritems = nil;

    if self.changeredschedule then
        GlobalSchedule.StopFun(self.changeredschedule);
    end

    if self.update_blood and self.data then
        self.data:RemoveListener(self.update_blood);
    end

    if self.blooditem then
        self.blooditem:destroy();
    end
end

function PetCrystalItem:Init()
    self.is_loaded = true;
    self.nodes = {
        "crystal_img_hit", "crystal_img", "bossheadframe", "blood", "pos_txt", "yipohuai",
    }
    self:GetChildren(self.nodes);

    self:InitUI();
end

function PetCrystalItem:InitUI()
    self.blooditem = BossBloodItem(self.blood);
    self.pos_txt = GetText(self.pos_txt);
    self.crystal_img = GetImage(self.crystal_img);
    self.crystal_img_hit = GetImage(self.crystal_img_hit);
    self.yipohuai = GetImage(self.yipohuai);

    self:SetData();
    self:UpdateHP(100, 100);
end

function PetCrystalItem:SetData()
    SetGameObjectActive(self.crystal_img_hit.gameObject, false);
    SetGameObjectActive(self.yipohuai.gameObject, false);
    if self.data then
        local creepConfig = Config.db_creep[self.data.id];
        self.pos_txt.text = tostring(self.data.name);

        local call_back1 = function()
            if self.data.hp <= 0 then
                self.data:RemoveListener(self.update_blood);
                self.blooditem:UpdateCurrentBlood(0, self.data.hpmax);
                SetGameObjectActive(self.crystal_img_hit.gameObject, true);
                SetGameObjectActive(self.crystal_img.gameObject, true);
                SetGameObjectActive(self.yipohuai.gameObject, true);
                ShaderManager:GetInstance():SetImageGray(self.crystal_img);
            else
                self.blooditem:UpdateCurrentBlood(self.data.hp, self.data.hpmax);
                self:SetRed();
            end
        end
        --if self.update_blood then
        --    self.data:RemoveListener(self.update_blood);
        --end
        --self.update_blood = self.data:BindData("hp", call_back1);

        --call_back1();
    end
end

function PetCrystalItem:UpdateHP(hp, hpmax)
    if hp <= 0 then
        --self.data:RemoveListener(self.update_blood);
        self.blooditem:UpdateCurrentBlood(0, self.data.hpmax);
        SetGameObjectActive(self.crystal_img_hit.gameObject, false);
        SetGameObjectActive(self.crystal_img.gameObject, true);
        SetGameObjectActive(self.yipohuai.gameObject, true);
        ShaderManager:GetInstance():SetImageGray(self.crystal_img);
    else
        self.blooditem:UpdateCurrentBlood(hp, hpmax);
        self:SetRed();
    end
end

function PetCrystalItem:UpdateData(data)
    self.data = data;
    self:SetData();
end

function PetCrystalItem:AddEvents()
    AddClickEvent(self.gameObject, handler(self, self.HandlePath));
end

function PetCrystalItem:HandlePath(go, x, y)
    local main_role = SceneManager:GetInstance():GetMainRole()
    local main_pos = main_role:GetPosition();
    -- local mon_pos = self.data.coord;
    local mon_pos = PetDungeonPanel.Position[self.index]

    local call_back = function()
        -- if not AutoFightManager:GetInstance():GetAutoFightState() then
        --     GlobalEvent:Brocast(FightEvent.AutoFight)
        --     AutoFightManager:GetInstance():SetAutoPosition(mon_pos)
        -- end

        AutoFightManager:GetInstance():Start(true)
        FightManager:GetInstance():UnLockFightTarget()
        AutoFightManager:GetInstance():SetAutoPosition(mon_pos)
    end

    OperationManager:GetInstance():TryMoveToPosition(nil, main_pos, mon_pos, call_back, self:GetRange());
end

function PetCrystalItem:GetRange()
    --if not AutoFightManager:GetInstance().def_range then
    --    return nil
    --end
    return 500
end

function PetCrystalItem:SetRed()
    if self.changeredschedule then
        GlobalSchedule.StopFun(self.changeredschedule);
    end

    local call_back = function()
        GlobalSchedule.StopFun(self.changeredschedule);

        SetGameObjectActive(self.crystal_img_hit.gameObject, false);
        --SetGameObjectActive(self.crystal_img.gameObject, true);
    end
    SetGameObjectActive(self.crystal_img_hit.gameObject, true);
    --SetGameObjectActive(self.crystal_img.gameObject, false);
    self.changeredschedule = GlobalSchedule.StartFunOnce(call_back, 1);
end