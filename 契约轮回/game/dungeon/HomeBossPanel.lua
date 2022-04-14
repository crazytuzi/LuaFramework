---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by win 10.
--- DateTime: 2018/10/10 10:53
---
HomeBossPanel = HomeBossPanel or class("HomeBossPanel", BaseItem)
local this = HomeBossPanel

function HomeBossPanel:ctor(parent_node, dungeonPanel, selectedBossid)
    self.abName = "dungeon";
    self.image_ab = "dungeon_image";
    self.assetName = "HomeBossPanel"
    self.layer = "Bottom"

    self.selectedBossid = selectedBossid;

    self.parentPanel = dungeonPanel;
    self.model = DungeonModel.GetInstance()
    self.events = {};
    self.schedules = {};
    HomeBossPanel.super.Load(self);
    --DungeonCtrl:GetInstance().HomeBossPanel = self;
end

function HomeBossPanel:dctor()
    self.model = nil;

    if self.map_bg then
        self.map_bg.transform:SetParent(self.transform);
    end

    GlobalEvent:RemoveTabListener(self.events);
    self.selectedItemIndex = 1;
    self:StopAllSchedules()

    destroyTab(self.items);
    self.items = {};

    self.parentPanel = nil;

    self.selectedBossid = nil;
    --destroyTab(self.togItems);
    self.togItems = nil;
end

function HomeBossPanel:Open(data)
    self.data = data;
    WindowPanel.Open(self)
end

function HomeBossPanel:LoadCallBack()
    self.nodes = {
        "bg_layer/shuoming", "boss_tog_1", "togLayer",
        "pilaoText", "qianwangBtn", "ScrollView/Viewport/Content",
        "bossitem_0", "qianwangBtn/qianwangText",
        "bg_layer/shuomingLabel","energe_parent/EnergeSlider",
        "energe_parent/reset_time","energe_parent","energe_parent/vigor_text",
    }
    self:GetChildren(self.nodes)

    SetLocalPosition(self.transform, 0, 0, 0)

    self:InitUI();

    self:AddEvent();

    --请求boss列表
    DungeonCtrl:GetInstance():RequestBossList(enum.BOSS_TYPE.BOSS_TYPE_HOME);
    self.parentPanel:DropCallBack();
end

function HomeBossPanel:InitUI()
    self.qianwangBtn = GetButton(self.qianwangBtn);

    self.pilaoText = GetText(self.pilaoText);
    --self.pilaoText.color = Color(59 / 255, 0x2e/255, 12 / 255, 1);
    --玩法说明
    self.shuoming = GetButton(self.shuoming);

    --self.shuoming.gameObject:SetActive(false);

    self.boss_tog_1 = GetToggle(self.boss_tog_1);

    self.qianwangText = GetText(self.qianwangText);

    self.shuomingLabel = GetText(self.shuomingLabel);
    self.reset_time = GetText(self.reset_time)
    self.EnergeSlider = GetSlider(self.EnergeSlider)
    self.vigor_text = GetText(self.vigor_text)

    --self.care = GetToggle(self.care);

    self:InitTog();
    self:InitBoss(self.currentFloor);
    --初始化掉落icon
    self.selectedItemIndex = 1;
    local ditem = self.items[self.selectedItemIndex];
    self.parentPanel:InitDrops(ditem);
    self.parentPanel:InitModelView(ditem);

    --lua_resMgr:SetImageTexture(self, self.winlose, self.image_ab, "dungeon_result2_win", true);
end

function HomeBossPanel:UpdateVigor()
    if self.currentFloor <= 3 then
        SetVisible(self.energe_parent, true)
        local main_role_data = RoleInfoModel:GetInstance():GetMainRoleData()
        if main_role_data then
            local buffer = main_role_data:GetBuffByID(enum.BUFF_ID.BUFF_ID_HOME_BOSS_VIGOR)
            local used_energe = (buffer and buffer.value or 0)
            used_energe = (used_energe > 100 and 100 or used_energe)
            self.EnergeSlider.value = (100 - used_energe)
            self.vigor_text.text = string.format("%s/%s", 100 - used_energe,100)
        end
        local hour = self:GetNextResetTime()
        self.reset_time.text = string.format("Reset: %02s:00", hour)
    else
        SetVisible(self.energe_parent, false)
    end
end

function HomeBossPanel:InitTog()
    self.togBoss = {};
    local viplv = RoleInfoModel:GetInstance():GetRoleValue("viplv");
    for k, v in pairs(self.model.homeBossTab) do
        if not self.togBoss[v.floor] then
            self.togBoss[v.floor] = {};
        end
        if self.selectedBossid then
            if v.id == self.selectedBossid then
                self.currentFloor = v.floor;
            end
        else
            local sceneConfig = Config.db_scene[v.scene];
            if sceneConfig then
                local free = String2Table(sceneConfig.free);--{vip,4}
                --reqs = reqs and reqs[1] or {};
                if free and free[1] == "vip" and SafetoNumber(free[2]) <= viplv and SafetoNumber(self.currentFloor) <= SafetoNumber(v.floor) then
                    self.currentFloor = v.floor;
                end
            end
        end
        table.insert(self.togBoss[v.floor], v);
    end
    self.currentFloor = self.currentFloor or 1;
    self.boss_tog_1.gameObject:SetActive(true);

    destroyTab(self.togItems);
    self.togItems = {};
    for i = 1, #self.togBoss, 1 do
        local tog = newObject(self.boss_tog_1);
        tog.gameObject.name = "boss_tog_" .. i;
        local labelObj = GetChild(tog, "Label");
        if labelObj then
            local labelText = GetText(labelObj);
            labelText.text = string.format("F%s", DungeonModel.NumToChinese[i]);
            SetColor(labelText, 255, 255, 255)
        end
        tog.isOn = false;
        tog.transform:SetParent(self.togLayer.transform);
        SetLocalPosition(tog.transform, 0, 0, 0);
        SetLocalScale(tog.transform, 1, 1, 1);
        self.togItems[i] = tog;
    end

    if self.currentFloor and self.currentFloor ~= 1 and self.togItems[self.currentFloor] then
        self:HandleTogClick(self.togItems[self.currentFloor].gameObject)
        self.togItems[self.currentFloor].isOn = true;
        self:SetToggleColor(self.togItems[self.currentFloor])
    else
        self.togItems[1].isOn = true;
        self:HandleTogClick();
        self:SetToggleColor(self.togItems[1])
    end

    self.boss_tog_1.gameObject:SetActive(false);
end

function HomeBossPanel:InitBoss(floor)
    destroyTab(self.items);

    self.items = {};
    self.selectedItemIndex = 1;
    local bosses = self.togBoss[self.currentFloor];
    if bosses then
        self.bossitem_0.gameObject:SetActive(true);
        table.sort(bosses, SeqCompareFun);
        for i = 1, #bosses, 1 do
            local bossTab = bosses[i];
            local item = DungeonScrollItem(newObject(self.bossitem_0), bossTab);
            item.gameObject.name = "home_boss_" .. i;
            self.items[i] = item;
            --item:SetJie();
            item:ShowCare(false);
            item:ShowPeace(bossTab.peace == 1);
            item.transform:SetParent(self.Content.transform);
            SetLocalScale(item.transform, 1, 1, 1);
            SetLocalPosition(item.transform, 0, 0, 0);
            self:RefreshDungeonScrollItem(item);
            if bossTab.id == self.selectedBossid then
                self.selectedItemIndex = i;
            end
        end
        self.items[self.selectedItemIndex]:SetSelected(true);
        local rt = self.Content:GetComponent("RectTransform");
        rt.sizeDelta = Vector2(rt.sizeDelta.x, #bosses * 107.15);
    end

    self.bossitem_0.gameObject:SetActive(false);

    for i = 1, #self.items, 1 do
        AddClickEvent(self.items[i].gameObject, handler(self, self.HandleSelectItem));
    end
    self.parentPanel:InitDrops(self.items[self.selectedItemIndex]);
    self.parentPanel:SetBG(self.items[self.selectedItemIndex]);
    self.parentPanel:InitModelView(self.items[self.selectedItemIndex]);

    local rt = self.Content:GetComponent("RectTransform");
    rt.anchoredPosition = Vector2(0, (self.selectedItemIndex - 1) * 60.2);

    self:SetQianWangText();
    self:HandleSelectItem(self.items[self.selectedItemIndex].gameObject);
    self:UpdateVigor()
end

function HomeBossPanel:CheckReqs(reqs)
    for i=1, #reqs do
        local req = reqs[i]
        if req[1] == "vip" then
            local vipLevel = RoleInfoModel:GetInstance():GetMainRoleVipLevel()
            if vipLevel < req[2] then
                Notify.ShowText(string.format("You must reach VIP%s to enter the Home Boss scene", req[2]))
                return false
            end 
        end
    end
    return true
end

function HomeBossPanel:AddEvent()

    --self.schedules[#self.schedules + 1] = GlobalSchedule:Start(callBack1, 1, -1);



    local qianwang_callback = function(target, x, y)
        local item = self.items[self.selectedItemIndex];
        if item then
            if item.data then
                local function ok_func()
                    local okFun = function()
                        local sceneid = item.data.scene;
                        local coord = String2Table(item.data.coord);
                        if sceneid and coord then
                            DungeonCtrl:GetInstance():RequestEnterWorldBoss(sceneid, coord[1], coord[2]);
                            DungeonModel:GetInstance().SelectedDungeonID = item.data.id;
                        end
                    end

                    local vipLevel = RoleInfoModel:GetInstance():GetMainRoleVipLevel();
                    local sceneID = item.data.scene;
                    local sceneConfig = Config.db_scene[sceneID];
                    local reqs = String2Table(sceneConfig.reqs)
                    local free = String2Table(sceneConfig.free)

                    if not self:CheckReqs(reqs) then
                        --Dialog.ShowOne("提示", "达到贵族4，才可以进入家园首领地图", "确定", nil, nil);
                        return ;
                    end
                    --if (item.data.floor + 4) > vipLevel then
                    --VIP等级不够
                    if sceneConfig then
                        local cost = String2Table(sceneConfig.force);
                        local needVipLevel = free[2];
                        if vipLevel >= needVipLevel then
                            okFun()
                        else
                            if table.isempty(cost) then
                                --if table.isempty(free) then
                                Dialog.ShowTwo("Tip", "Insufficient VIP level, fail to enter", "Confirm", nil, nil, "Cancel", nil, nil);
                                --else
                                --    Dialog.ShowTwo("提示", "VIP等级不足,是否消费" .. cost[2] .. "绑定钻石或钻石进入?", "确定", okFun, nil, "取消", nil, nil);
                                --end
                            else
                                Dialog.ShowTwo("Tip", "Insufficient VIP level, spend" .. cost[2] .. "bound diamonds or diamonds to enter?", "Confirm", okFun, nil, "Cancel", nil, nil);
                            end
                        end
                    else
                        Notify.ShowText("I don't know what to do to enter this place!");
                    end
                    --else
                    --    okFun();
                    --end
                end

                local boss_type = item.data.type
                local boss_drop_limit = String2Table(Config.db_game["boss_drop_limit"].val)[1]
                if table.containValue(boss_drop_limit, boss_type) then
                    local level = RoleInfoModel:GetInstance():GetRoleValue("level")
                    local creep = Config.db_creep[item.data.id]
                    if level-creep.level >= item.data.drop_lv then
                        Dialog.ShowTwo("Tip","\nYour level is X higher than the boss and no loot will be available after defeating it.\nProceed?","Confirm",ok_func,nil,"Cancel",nil,nil,"Don't notice me again today",false,nil,-10010)
                        return
                    end
                end
                local power = RoleInfoModel:GetInstance():GetMainRoleData().power
                if power < item.data.power  then
                    local str = string.format("\n\nThat boss has higher CP<color=#eb0000>(%s)</color> and challenging it might be difficult.Proceed anyway?\n   My CP：%s",item.data.power,power)
                    Dialog.ShowTwo("Tip",str,"Confirm",ok_func,nil,"Cancel",nil,nil,"Don't notice me again today",false,nil,-10011)
                    return
                end
                ok_func()

            end
        end
    end
    AddClickEvent(self.qianwangBtn.gameObject, qianwang_callback)

    local shuomingTip = function(target, x, y)
        ShowHelpTip(HelpConfig.Dungeon.homeBoss, true);
    end
    AddClickEvent(self.shuoming.gameObject, shuomingTip)

    for k, v in pairs(self.togItems) do
        AddValueChange(v.gameObject, handler(self, self.HandleTogClick));
    end

    self.events[#self.events + 1] = GlobalEvent.AddEventListener(DungeonEvent.WORLD_BOSS_LIST, handler(self, self.HaneleBossList));

    self.events[#self.events + 1] = GlobalEvent.AddEventListener(DungeonEvent.WORLD_BOSS_CARE, handler(self, self.HaneleBossCare));
end

function HomeBossPanel:HandleTogClick(target, bool)
    if bool then
        for i = 1, #self.togItems, 1 do
            local labelObj = GetChild(self.togItems[i], "Label")
            if labelObj then
                local LabelText = GetText(labelObj)
                SetColor(LabelText, 255, 255, 255)
            end
            if self.togItems[i].gameObject == target then
                self.currentFloor = i;
                self:InitBoss(i);
                local LabelText = GetText(labelObj)
                SetColor(LabelText, 133, 132, 176)
            end
        end
    end
end

function HomeBossPanel:SetToggleColor(target)
    if target then
        local labelObj = GetChild(target, "Label")
        if labelObj then
            local LabelText = GetText(labelObj)
            SetColor(LabelText, 133, 132, 176)
        end
    end
end

function HomeBossPanel:HaneleBossCare(data)
    if self.items then
        for i = 1, #self.items, 1 do
            local bossTab = self.items[i].data;
            if bossTab.id == data.id then
                self.items[i]:SetIsCare(data.op == 1);
            end
        end
    end
end

function HomeBossPanel:HaneleBossList(data)
    if self.items then
        for i = 1, #self.items, 1 do
            self:RefreshDungeonScrollItem(self.items[i]);
        end
        self.parentPanel:RefreshProp(self.items[self.selectedItemIndex]);
        local item = self.items[self.selectedItemIndex]
        local bossinfo = DungeonModel:GetInstance():GetDungeonBossInfo(enum.BOSS_TYPE.BOSS_TYPE_HOME, item.data.id)
        if bossinfo then
            self.parentPanel:SetIsCare(bossinfo.care)
        end
    end

    --BOSS 疲劳: 1/3
    --if data.tired then
    --    local tired = 10;
    --    if Config.db_game["boss_tired"] then
    --        tired = tonumber(Config.db_game["boss_tired"].val);
    --    end
    --    self.pilaoText.text = "BOSS 疲劳: " .. data.tired .. "/" .. tired;
    --end
end

function HomeBossPanel:RefreshDungeonScrollItem(item)
    local bossTab = item.data;

    local bossinfo = DungeonModel:GetInstance():GetDungeonBossInfo(enum.BOSS_TYPE.BOSS_TYPE_HOME, bossTab.id);
    if bossinfo then
        local time = bossinfo.born;--1541494877
        item:StartSechudle(time);
        --item:SetIsCare(bossinfo.care);
        --self.parentPanel:SetIsCare(bossinfo.care);
        --local monsterTab = Config.db_creep[bossTab.id];
        --self.valueTab[1].text = tostring(monsterTab.att);
        --self.valueTab[2].text = tostring(monsterTab.hpmax);
        --self.valueTab[3].text = tostring(monsterTab.def);
        --self.valueTab[4].text = tostring(monsterTab.hit);
        --self.valueTab[5].text = tostring(monsterTab.miss);
    end
end

function HomeBossPanel:HandleSelectItem(target, x, y)
    local item = nil;
    for i = 1, #self.items, 1 do
        if self.items[i].gameObject == target then
            item = self.items[i];
            self.selectedItemIndex = i;
        end
        self.items[i]:SetSelected(false);
    end
    item:SetSelected(true);

    self.parentPanel:InitDrops(item);
    self.parentPanel:SetBG(item);
    self.parentPanel:InitModelView(item);
    self.parentPanel:RefreshProp(item);

    local tab = DungeonModel:GetInstance():GetDungeonBossInfo(enum.BOSS_TYPE.BOSS_TYPE_HOME, item.data.id);
    if tab then
        self.parentPanel:SetIsCare(tab.care)
    end

    local item = self.items[self.selectedItemIndex];
    if item and item.data then
        local vipLevel = RoleInfoModel:GetInstance():GetMainRoleVipLevel();
        --if (item.data.floor + 3) > vipLevel then --VIP等级不够
        --
        --end
        local sceneID = item.data.scene;
        local sceneConfig = Config.db_scene[sceneID];
        local cost = String2Table(sceneConfig.force);
        local free = String2Table(sceneConfig.free);
        local needVipLevel = free[2];
        if table.isempty(cost) then
            self.shuomingLabel.text = "VIP level" .. needVipLevel .. "You can enter for free";
        else
            self.shuomingLabel.text = "Insufficient VIP level, spend" .. cost[2] .. "Use Bound Diamond or" .. cost[2] .. "Diamond to enter";
        end

        if vipLevel >= needVipLevel then
            self.qianwangText.text = "Go Now";
        else
            self.qianwangText.text = "VIP" .. needVipLevel .. "Free entrance";
        end

    end

end

function HomeBossPanel:SetQianWangText()
    if self.items then
        local vipLevel = RoleInfoModel:GetInstance():GetMainRoleVipLevel();
        local data = self.items[self.selectedItemIndex].data;
        self.qianwangText.text = "VIP" .. (data.floor + 3) .. "Enter now";
        self.qianwangText.resizeTextForBestFit = true;
        self.qianwangText.resizeTextMinSize = 10;
        self.qianwangText.resizeTextMaxSize = self.qianwangText.fontSize;
    end
end

function HomeBossPanel:StopAllSchedules()
    for i = 1, #self.schedules, 1 do
        GlobalSchedule:Stop(self.schedules[i]);
    end
    self.schedules = {};
end


function HomeBossPanel:GetSelectedID()
    if self.items and self.items[self.selectedItemIndex] and self.items[self.selectedItemIndex].data then
        return self.items[self.selectedItemIndex].data.id;
    end
    return 0;
end

function HomeBossPanel:GetSelectedBossType()
    return enum.BOSS_TYPE.BOSS_TYPE_HOME;
end

function HomeBossPanel:GetNextResetTime()
    local times = {0, 8, 16}
    local timeTab = os.date("*t", os.time())
    local hour = timeTab.hour
    table.sort(times)
    for i=1, #times do
        if hour < times[i] then
            return times[i]
        end
    end
    return 0
end