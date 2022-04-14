PersonalBossItem = PersonalBossItem or class("PersonalBossItem", BaseCloneItem)
local this = PersonalBossItem

function PersonalBossItem:ctor(obj, parent_node, layer)
    PersonalBossItem.super.Load(self)
    self.image_ab = "dungeon_image";
end

function PersonalBossItem:dctor()
    for i = 1, #self.events do
        self.model:RemoveListener(self.events[i])
    end
end

function PersonalBossItem:LoadCallBack()
    self.nodes = {
        "selected", "jieText", "bossName", "bg"
    }
    self:GetChildren(self.nodes)
    self.jieText = GetText(self.jieText)
    self.bossName = GetText(self.bossName)
    self.bg = GetImage(self.bg)
    self.model = DungeonModel:GetInstance()
    self.events = {}
    self:AddEvent()

    self:UpdateView()
end

function PersonalBossItem:AddEvent()
    local function call_back(dunge_id)
        SetVisible(self.selected, dunge_id == self.data.id)
    end
    self.events[#self.events + 1] = self.model:AddListener(DungeonEvent.PersonalBossClick, call_back)

    local function call_back(target, x, y)
        self.model:Brocast(DungeonEvent.PersonalBossClick, self.data.id)
    end
    AddClickEvent(self.bg.gameObject, call_back)
end

--data:db_dunge
function PersonalBossItem:SetData(data)
    self.data = data
    if self.is_loaded then
        self:UpdateView()
    end
end

function PersonalBossItem:UpdateView()
    if self.data then
        SetVisible(self.selected, false)
        self.jieText.text = self.data.order .. "Stage"
        local levelstr = "";
        local level = 1;
        local waveTab = Config.db_dunge_wave[self.data.id .. "@" .. 1];
        if waveTab then
            local creepsTab = String2Table(waveTab.creeps);
            if #creepsTab == 3 then
                local monster_id = creepsTab[1];
                local creep = Config.db_creep[monster_id];
                if creep then
                    level = creep.level;
                end
            end
        end

        --levelstr = GetLevelShow(level).."级"
        levelstr = level .. "Level"
        local roleLevel = RoleInfoModel:GetInstance():GetMainRoleLevel()
        if roleLevel >= self.data.level then
            self.bossName.text = self.data.name .. "  " .. levelstr;
        else
            self.bossName.text = "<color=#ff0000>" .. self.data.name .. "  " .. levelstr .. "</color>";
        end



        --self.bossName.text = self.data.name
        --lua_resMgr:SetImageTexture(self,self.bg, 'abName', 'assetName',true)
        local creepConfig = Config.db_dunge[self.data.id];
        if creepConfig then
            self:SetBossBg(creepConfig.icon);
        end
    end
end

function PersonalBossItem:SetBossBg(bgName)
    --print2(bgName);
    lua_resMgr:SetImageTexture(self, self.bg, "iconasset/icon_boss_image", tostring(bgName), true);
end

function PersonalBossItem:ShowPeace(bool)
    bool = toBool(bool);
    SetGameObjectActive(self.is_peace, bool);
end