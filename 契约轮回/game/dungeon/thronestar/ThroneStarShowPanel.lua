---
--- Created by  Administrator
--- DateTime: 2020/4/2 19:26
---
ThroneStarShowPanel = ThroneStarShowPanel or class("ThroneStarShowPanel", WindowPanel)
local this = ThroneStarShowPanel

function ThroneStarShowPanel:ctor(parent_node, parent_panel)
    self.abName = "dungeon";
    self.image_ab = "dungeon_image";
    self.assetName = "ThroneStarShowPanel"
    self.layer = "UI"
    self.dungeModel = DungeonModel.GetInstance()
    self.model = ThroneStarModel:GetInstance()
    self.events = {}
    self.modelEvents = {}
    self.bossItems = {}
    self.btnSelects = {}
    self.btnSelectsTex ={}
    self.views = {}
    self.icons = {}
    self.items = {}
    self.lastViewIdx = 1
    self.use_background = true
    self.click_bg_close = true
    self.panel_type = 3
end

function ThroneStarShowPanel:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    if self.boss_model then
        self.boss_model:destroy()
    end

    if not table.isempty(self.bossItems) then
        for i, v in pairs(self.bossItems) do
            v:destroy()
        end
    end
    if not table.isempty(self.items) then
        for i, v in pairs(self.items) do
            v:destroy()
        end
    end
    self.items = {}
    self.bossItems = {}
    self.btnSelects = {}
    self.btnSelectsTex ={}
    self.views = {}
    self.icons = {}
end

function ThroneStarShowPanel:LoadCallBack()
    self.nodes = {
        "topBtn/btn2","topBtn/btn2/btnSelect2","topBtn/btn2/btnName2","topBtn/btn1/btnName1",
        "topBtn/btn3/btnName3","topBtn/btn3","topBtn/btn1","dropBtn","bossInfo","ThroneStarShowItem",
        "rewards","bossView","topBtn/btn1/btnSelect1","topBtn/btn3/btnSelect3",
        "rewards/iconParent2","rewards/iconParent1","ScrollView/Viewport/Content",
        "bossView/valueCon/heart","bossView/valueCon/def","bossView/valueCon/life",
        "bossView/valueCon/attack","bossView/valueCon/dod","bossView/model_con",
    }
    self:GetChildren(self.nodes)
    self:SetTileTextImage("dungeon_image", "ThroneStar_title2")
    self.btnName1 = GetText(self.btnName1)
    self.btnName2 = GetText(self.btnName2)
    self.btnName3 = GetText(self.btnName3)

    self.btnSelects[1] = self.btnSelect1
    self.btnSelects[2] = self.btnSelect2
    self.btnSelects[3] = self.btnSelect3

    self.btnSelectsTex[1] = self.btnName1
    self.btnSelectsTex[2] = self.btnName2
    self.btnSelectsTex[3] = self.btnName3
    
    self.views[1] = self.rewards
    self.views[2] = self.bossView

    self.icons[1] = self.bossInfo
    self.icons[2] = self.dropBtn

    self.heart = GetText(self.heart)
    self.def = GetText(self.def)
    self.life = GetText(self.life)
    self.attack = GetText(self.attack)
    self.dod = GetText(self.dod)

    self:InitUI()
    self:AddEvent()
    self:Click(1)
    self:SetPage(1)
end

function ThroneStarShowPanel:InitUI()
   -- self.dungeModel.throneBossTab
   -- for i=1, #self.dungeModel.throneBossTab do
   --     local bossTab = self.dungeModel.throneBossTab[i]
   --     local lv = RoleInfoModel:GetInstance():GetMainRoleLevel()
   --     if lv >= bossTab.show_lv then
   --
   --     end
   -- end
end

function ThroneStarShowPanel:AddEvent()
    local function call_back()
        self:Click(1)
    end
    AddClickEvent(self.btn1.gameObject,call_back)
    local function call_back()
        self:Click(2)
    end
    AddClickEvent(self.btn2.gameObject,call_back)
    local function call_back()
        self:Click(3)
    end
    AddClickEvent(self.btn3.gameObject,call_back)

    local function call_back()
        self:SetPage(1)
    end
    AddButtonEvent(self.dropBtn.gameObject,call_back)

    local function call_back()
        self:SetPage(2)
    end
    AddButtonEvent(self.bossInfo.gameObject,call_back)


    self.modelEvents[#self.modelEvents + 1] = self.model:AddListener(ThroneStarEvent.ThroneStarShowItemClick,handler(self,self.ThroneStarShowItemClick))
end

function ThroneStarShowPanel:Click(index)
    for i = 1, 3 do
        if index == i then
            SetColor(self.btnSelectsTex[i], 133, 132, 176, 255)
            SetVisible(self.btnSelects[i],true)
            self:UpdateBossList(index)
        else
            SetColor(self.btnSelectsTex[i], 255, 255, 255, 255)
            SetVisible(self.btnSelects[i],false)
        end
    end
    
end

function ThroneStarShowPanel:SetPage(index)
    for i = 1, 2 do
        if index == i then
            SetVisible(self.views[i],true)
            SetVisible(self.icons[i],true)
        else
            SetVisible(self.views[i],false)
            SetVisible(self.icons[i],false)
        end
    end
end

function ThroneStarShowPanel:UpdateBossList(index)
    local curScene = self.model.sceneIds[index]
    local num = 0
    for i=1, #self.model.throneBossTab do
        local bossTab = self.model.throneBossTab[i]
        local lv = RoleInfoModel:GetInstance():GetMainRoleLevel()
        if --lv >= bossTab.show_lv and
                bossTab.scene == curScene then
            num = num +  1
            --self.bossItems
            local item = self.bossItems[num]
            if not item then
                item = ThroneStarShowItem(self.ThroneStarShowItem.gameObject,self.Content,"UI")
                self.bossItems[num] = item
            else
                item:SetVisible(true)
            end
            item:SetData(bossTab)
        end
    end
    for i = num + 1,#self.bossItems do
        local buyItem = self.bossItems[i]
        buyItem:SetVisible(false)
    end
    self:ThroneStarShowItemClick(self.bossItems[1].data)
end

function ThroneStarShowPanel:ThroneStarShowItemClick(data)
    for i, v in pairs(self.bossItems) do
        if v.data.id == data.id then
            v:SetSelect(true)
            self:UpdateBossInfo(data)
            self:ShowBossModel(data)
        else
            v:SetSelect(false)
        end
    end
end

function ThroneStarShowPanel:UpdateBossInfo(data)
    self:CreateIcon(String2Table(data.show))
end

function ThroneStarShowPanel:CreateIcon(tab)
    for i=1, #tab do
        local item_id = tab[i]
        local param = {}
        param["item_id"] = item_id
        param["bind"] = 2
        param["size"] = {x=70, y=70}
        param["can_click"] = true

        if not self.items[i] then
            self.items[i] = GoodsIconSettorTwo(self.iconParent2)
        else
            self.items[i]:SetVisible(true)
        end

        local item_cfg = Config.db_item[item_id]
        if item_cfg.type == enum.ITEM_TYPE.ITEM_TYPE_PET_EQUIP then
            --宠物装备特殊处理配置表
            param["cfg"] = Config.db_pet_equip[item_id.."@1"]
        end


        self.items[i]:SetIcon(param)
    end
    for i = #tab+1, #self.items do
        local item = self.items[i]
        item:SetVisible(false)
    end
end

function ThroneStarShowPanel:ShowBossModel(boss)
    local monsterTab = Config.db_creep[boss.id];
    local scale = monsterTab.scale
    if self.boss_model then
        self.boss_model:destroy()
    end
    local config = {}
    config.pos = { x = -1933, y = 10, z = 300 }
    config.rotate = { x = 0, y = 135, z = 0 }
    config.scale = { x = scale * 100, y = scale * 100, z = scale * 100}
    config.trans_offset = {x=-47.6, y=-39.6}
    config.trans_x = 950
    config.trans_y = 950
    config.carmera_size = 5
    self.boss_model = UIModelCommonCamera(self.model_con, nil, monsterTab.figure)
    self.boss_model:SetConfig(config)

    local monsterTab = Config.db_creep_attr[boss.id];
    self.attack.text = tostring(monsterTab.att);
    self.life.text = tostring(monsterTab.hpmax);
    self.def.text = tostring(monsterTab.def);
    self.heart.text = tostring(monsterTab.hit);
    self.dod.text = tostring(monsterTab.miss)
end