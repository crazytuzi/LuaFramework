PersonalBossPanel = PersonalBossPanel or class("PersonalBossPanel", BaseItem)
local PersonalBossPanel = PersonalBossPanel
local tableInsert = table.insert
local ConfigLanguage = require('game.config.language.CnLanguage');
function PersonalBossPanel:ctor(parent_node, dungeonPanel)
    self.abName = "dungeon"
    self.assetName = "PersonalBossPanel"
    self.layer = "UI"

    self.parentpanel = dungeonPanel
    self.model = DungeonModel:GetInstance()
    PersonalBossPanel.super.Load(self)

    self.items = {}
    self.events = {}
    self.global_events = {}
end

function PersonalBossPanel:dctor()
    for i = 1, #self.events do
        self.model:RemoveListener(self.events[i])
    end
    for i = 1, #self.global_events do
        GlobalEvent:RemoveListener(self.global_events[i])
    end
    for i = 1, #self.items do
        self.items[i]:destroy()
    end
    self.parentpanel = nil;
    if self.qianwangBtn_reddot then
        self.qianwangBtn_reddot:destroy();
    end
    self.qianwangBtn_reddot = nil;

    local panel = lua_panelMgr:GetPanel(DungeonSavageEntranceTicketPanel);
    if panel then
        panel:Close();
    end
end

function PersonalBossPanel:LoadCallBack()
    self.nodes = {
        "ScrollView/Viewport/Content/bossitem", "qianwangBtn", "bg_layer/shuomingLabel", "ScrollView/Viewport/Content",
        "bg_layer/shuoming",
    }
    self:GetChildren(self.nodes)
    self.shuomingLabel = GetText(self.shuomingLabel)
    self.bossitem_gameobject = self.bossitem.gameObject
    self:AddEvent()
    DungeonCtrl:GetInstance():RequestDungeonPanel(enum.SCENE_STYPE.SCENE_STYPE_DUNGE_ROLE_BOSS)
    self:UpdateView()

    if self.parentpanel and self.parentpanel.care then
        SetGameObjectActive(self.parentpanel.care.gameObject, false);
    end

    self.qianwangBtn_reddot = RedDot(self.qianwangBtn.transform, nil, RedDot.RedDotType.Nor)
    self.qianwangBtn_reddot:SetPosition(68, 22);
    self:CheckReddot();
end

function PersonalBossPanel:HandleBossClick(dunge_id)
    local item = {}
    local monster_id = String2Table(Config.db_dunge_wave[dunge_id .. "@" .. 1].creeps)[1]
    item.data = {}
    item.data.id = monster_id;

    local dungeonConfig = Config.db_dunge[dunge_id];
    if dungeonConfig then
        self.parentpanel:InitFixDrops(dungeonConfig);
    end
    if dungeonConfig.res_ratio == 0 then

    else
        item.data.res_ratio = dungeonConfig.res_ratio * 100;
    end

    self.parentpanel:InitModelView(item, false, 1)
    self.parentpanel:RefreshProp(item)

    self.parentpanel:InitPersonalDrops(dungeonConfig);
    self.select_dunge_id = dunge_id
end

function PersonalBossPanel:AddEvent()
    self.events[#self.events + 1] = self.model:AddListener(DungeonEvent.PersonalBossClick, handler(self, self.HandleBossClick));

    local function call_back(stype, data)
        if stype == enum.SCENE_STYPE.SCENE_STYPE_DUNGE_ROLE_BOSS then
            local viplv = RoleInfoModel:GetInstance():GetRoleValue("viplv")
            local vip_count = tonumber(Config.db_vip_rights[enum.VIP_RIGHTS.VIP_RIGHTS_ROLE_BOSS]["vip" .. viplv] or 0)
            local left_count = Config.db_dunge[self.select_dunge_id].enter_times - data.info.cur_times + vip_count
            self.cur_times = data.info.cur_times

            self.shuomingLabel.text = string.format(ConfigLanguage.Dungeon.SAVAGE_ENTER_TIP, tostring(left_count))

            self:CheckReddot();
        end
    end
    self.global_events[#self.global_events + 1] = GlobalEvent:AddListener(DungeonEvent.UpdateDungeonData, call_back)

    local function call_back(target, x, y)

    end
    AddClickEvent(self.qianwangBtn.gameObject, handler(self,self.HandleEnterDungeon))

    local function call_back(target, x, y)
        ShowHelpTip(HelpConfig.Dungeon.personalBoss, true)
    end
    AddClickEvent(self.shuoming.gameObject, call_back)
end

function PersonalBossPanel:HandleEnterDungeon(go,x,y)
    local viplv = RoleInfoModel:GetInstance():GetRoleValue("viplv")
    local vip_count = tonumber(Config.db_vip_rights[enum.VIP_RIGHTS.VIP_RIGHTS_ROLE_BOSS]["vip" .. viplv] or 0)
    local left_count = Config.db_dunge[self.select_dunge_id].enter_times - (self.cur_times or 0) + vip_count
    local level = RoleInfoModel:GetInstance():GetRoleValue("level")
    local need_level = Config.db_dunge[self.select_dunge_id].level;
    local ok_fun = function()
        DungeonCtrl:GetInstance():RequestEnterDungeon(nil, nil, self.select_dunge_id)
    end

    local dungeConfig =  Config.db_dunge[self.select_dunge_id];
    local sceneConfig
    local needVipLevel = 4;
    if dungeConfig then
        sceneConfig = Config.db_scene[dungeConfig.scene];
        if sceneConfig then
            local reqs = LString2Table(sceneConfig.reqs);
            if reqs then
                for k,v in pairs(reqs) do
                    if v[1] == "vip" then
                        needVipLevel = v[2];
                    end
                end
            end

        end
    end

    if viplv < needVipLevel then
        Notify.ShowText("Available for players above VIP4")
    elseif level < need_level then
        local lv = GetLevelShow(need_level)
        Notify.ShowText(string.format("Reach Lv.%s to enter it", lv))
    elseif left_count <= 0 then
        Notify.ShowText("Max access attempts reached")
    else
        --ok_fun();
        if sceneConfig then
            if sceneConfig.cost_type == 0 then
                local cost = String2Table(sceneConfig.cost);
                if cost then
                    cost = cost[1];
                    local itemID = cost[1];
                    local needItemNum = cost[2];
                    local panel = lua_panelMgr:GetPanel(DungeonSavageEntranceTicketPanel);
                    if panel then
                        panel:Close();
                    end

                    lua_panelMgr:GetPanelOrCreate(DungeonSavageEntranceTicketPanel):Open({ call_back = ok_fun, itemID = itemID, num = needItemNum, sceneName = dungeConfig.name });
                    return ;
                else
                    Notify.ShowText("Failed to find entrance item info");
                    return;
                end
                --if (DungeonModel:GetInstance().enter + 1) >= min and (DungeonModel:GetInstance().enter + 1) <= max then
                --
                --end
                --for k, v in pairs(cost) do
                --
                --end
                --Notify.ShowText("暂时无法进入,请联系管理员");
            else
                Notify.ShowText("Cost_type error， please check");
                return;
            end
        else
            Notify.ShowText("Failed to find scene configuration");
            return ;
        end
    end
end

function PersonalBossPanel:SetData(data)

end

function PersonalBossPanel:UpdateView()
    self:InitBoss()
end

function PersonalBossPanel:InitBoss()
    local bosses = {}
    for k, v in pairs(Config.db_dunge) do
        if v.stype == enum.SCENE_STYPE.SCENE_STYPE_DUNGE_ROLE_BOSS then
            tableInsert(bosses, v)
        end
    end

    local function sort_func(a, b)
        return a.level < b.level
    end
    table.sort(bosses, sort_func)
    local selectedItemIndex = 1;
    local level = RoleInfoModel:GetInstance():GetMainRoleLevel();

    for i, v in ipairs(bosses) do
        local item = PersonalBossItem(self.bossitem_gameobject, self.Content)
        item:SetData(v)
        item:ShowPeace(v.peace == 1);
        self.items[i] = item

        if v.level and level >= tonumber(v.level) then
            selectedItemIndex = i;
        end
    end

    if selectedItemIndex <= 3 then
        SetLocalPositionY(self.Content.transform, 0);
    else
        SetLocalPositionY(self.Content.transform, (50 + (selectedItemIndex - 3) * 90));
    end

    self.bossitem_gameobject:SetActive(false)

    --self.model:Brocast(DungeonEvent.PersonalBossClick, bosses[1].id)
    self.model:Brocast(DungeonEvent.PersonalBossClick, bosses[selectedItemIndex].id);
end

function PersonalBossPanel:CheckReddot()
    local tab = DungeonModel:GetInstance().red_dot_list;

    if tab[enum.SCENE_STYPE.SCENE_STYPE_DUNGE_ROLE_BOSS] and self.qianwangBtn_reddot then
        self.qianwangBtn_reddot:SetRedDotParam(true);
    else
        self.qianwangBtn_reddot:SetRedDotParam(false);
    end
end