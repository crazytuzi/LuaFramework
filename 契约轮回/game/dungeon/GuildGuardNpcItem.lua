GuildGuardNpcItem = GuildGuardNpcItem or class("GuildGuardNpcItem", Node)
local this = GuildGuardNpcItem

function GuildGuardNpcItem:ctor(obj, data, pos)
    self.transform = obj.transform
    self.gameObject = self.transform.gameObject;
    self.data = data;
    self.image_ab = "dungeon_image";
    self.boss_head_ab = "iconasset/icon_boss_head";
    self.transform_find = self.transform.Find;
    self.pos = pos;
    self.events = {};
    self:Init();
    self:AddEvents();
end

function GuildGuardNpcItem:dctor()
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

function GuildGuardNpcItem:Init()
    self.is_loaded = true;
    self.nodes = {
        "pos_txt", "crystal_img", "blood", "bossheadframe", "head_icon", "crystal_img_hit", "yipohuai", "exp_add",
    }
    self:GetChildren(self.nodes);

    self:InitUI();
end

function GuildGuardNpcItem:InitUI()
    self.blooditem = BossBloodItem(self.blood);
    self.pos_txt = GetText(self.pos_txt);
    self.crystal_img = GetImage(self.crystal_img);
    self.crystal_img_hit = GetImage(self.crystal_img_hit);
    self.yipohuai = GetImage(self.yipohuai);
    self.head_icon = GetImage(self.head_icon);
    if self.exp_add then
        self.exp_add = GetText(self.exp_add);
        self.exp_add.text = "";
    end

    self:SetData();
    self:UpdateHP(100, 100);
end

function GuildGuardNpcItem:SetData()
    SetGameObjectActive(self.crystal_img_hit.gameObject, false);
    SetGameObjectActive(self.yipohuai.gameObject, false);
    if self.data then
        local creepConfig = Config.db_creep[self.data.id];
        self.pos_txt.text = tostring(creepConfig.name);

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
        call_back1();
        lua_resMgr:SetImageTexture(self, self.crystal_img, self.boss_head_ab, creepConfig.avatar, true);
    end
end

function GuildGuardNpcItem:UpdateHP(hp, hpmax)
    --if self.pos == 1 then
    --    print2("1");
    --elseif self.pos == 2 then
    --    print2("2");
    --elseif self.pos == 3 then
    --    print2("3");
    --end

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

function GuildGuardNpcItem:UpdateData(data)
    self.data = data;
    ShaderManager:GetInstance():SetImageNormal(self.crystal_img);
    self:SetData();
end

function GuildGuardNpcItem:InitWithID(id)
    if not id then
        return ;
    end
    local creepConfig = Config.db_creep[id];
    if creepConfig then
        self.pos_txt.text = tostring(creepConfig.name);
        self.blooditem:UpdateCurrentBlood(0, 100);
        SetGameObjectActive(self.crystal_img_hit.gameObject, false);
        SetGameObjectActive(self.yipohuai.gameObject, true);
        ShaderManager:GetInstance():SetImageGray(self.crystal_img);
        lua_resMgr:SetImageTexture(self, self.crystal_img, self.boss_head_ab, creepConfig.avatar, true);
    end
end

function GuildGuardNpcItem:SetExpAdd(str)
    if str and self.exp_add then
        if tostring(str) == "EXP +0%" then
            SetGameObjectActive(self.exp_add);
        else
            self.exp_add.text = str;
        end
    end
end

function GuildGuardNpcItem:AddEvents()
    AddClickEvent(self.gameObject, handler(self, self.HandlePath));
end

function GuildGuardNpcItem:HandlePath(go, x, y)
    local call_back = function()
        if not AutoFightManager:GetInstance():GetAutoFightState() then
            GlobalEvent:Brocast(FightEvent.AutoFight)
        end
    end

    local main_role = SceneManager:GetInstance():GetMainRole()
    local main_pos = main_role:GetPosition();
    local mon_pos = self.data.coord;
    AutoFightManager:GetInstance():SetAutoPosition(mon_pos)
    OperationManager:GetInstance():TryMoveToPosition(nil, main_pos, mon_pos, call_back);
end

function GuildGuardNpcItem:SetRed()
    if self.changeredschedule then
        GlobalSchedule.StopFun(self.changeredschedule);
    end

    local call_back = function()
        GlobalSchedule.StopFun(self.changeredschedule);

        SetGameObjectActive(self.crystal_img_hit.gameObject, false);
    end
    SetGameObjectActive(self.crystal_img_hit.gameObject, true);
    self.changeredschedule = GlobalSchedule.StartFunOnce(call_back, 1);
end

