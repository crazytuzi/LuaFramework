---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by win 10.
--- DateTime: 18/11/19 17:34
---
ExpEntrancePanel = ExpEntrancePanel or class("ExpEntrancePanel", BaseItem)
local this = ExpEntrancePanel

ExpEntrancePanel.MAX_BUY_TIMES = 2;

function ExpEntrancePanel:ctor(parent_node, layer)
    self.abName = "dungeon"
    self.image_ab = "dungeon_image";
    self.assetName = "ExpEntrancePanel"
    self.layer = "UI"
    self.panel_type = 2;
    self.events = {};

    self.model = DungeonModel:GetInstance()

    ExpEntrancePanel.super.Load(self);

    self.dungeon_type = enum.SCENE_STYPE.SCENE_STYPE_DUNGE_EXP
    DungeonCtrl:GetInstance():RequestDungeonPanel(self.dungeon_type)
end

function ExpEntrancePanel:dctor()
    GlobalEvent:RemoveTabListener(self.events);
    destroyTab(self.items);
    destroyTab(self.awardItems);
    if self.countdownitem then
        self.countdownitem:destroy();
    end

    if self.enter_btn_reddot then
        self.enter_btn_reddot:destroy();
    end
    self.enter_btn_reddot = nil;
end

function ExpEntrancePanel:Open(tabIndex)
    --WindowPanel.Open(self)
    --self.default_table_index = tabIndex;
end

function ExpEntrancePanel:LoadCallBack()
    self.nodes = {
        "des/deslevel", "des/descontent", "left/left_text", "countdown/countdowntext", "countdown", "consume/entrance_consume_btn",
        "left/entrance_left_btn", "des/award_con/award_item_bg", "consume/consume_text", "des", "enter_btn", "des/award_con", "countdown/clear_cd_btn",
        "entrance_bg","merge","merge/Label",
    }
    self:GetChildren(self.nodes);

    SetLocalPosition(self.transform, 0, 0, 0);

    self:InitUI();
    self.Label = GetText(self.Label)
    self:AddEvent();

    self:UpdateData()
    self:UpdateInfo()

    local res = "dungeon_entrance_bg";
    lua_resMgr:SetImageTexture(self, self.entrance_bg, "iconasset/icon_big_bg_" .. res, res, false);
    --dungeon_entrance_title
    SetVisible(self.merge, RoleInfoModel:GetInstance():GetRoleValue("level") >= 385)
end

function ExpEntrancePanel:InitUI()
    self.entrance_bg = GetImage(self.entrance_bg);
    self.deslevel = GetText(self.deslevel);

    self.consume_text = GetText(self.consume_text);
    self.left_text = GetText(self.left_text);

    self.clear_cd_btn = GetButton(self.clear_cd_btn);
    self.merge_tg = GetToggle(self.merge)

    local param = {
        formatText = "In CD: <color=#ff0000>%s</color>",
        isShowMin = true,
        isShowDay = false,
    }
    --冷却时间
    self.countdownitem = CountDownText(self.countdown, param);

    local config = Config.db_scene[30101];
    local lv = 70;
    if config and config.reqs then
        local reqs = String2Table(config.reqs);
        if #reqs == 2 and _G.type(reqs[1]) ~= "table" then
            reqs = { reqs };
        end
        for k, v in pairs(reqs) do
            if v[1] == "level" then
                lv = tonumber(v[2]);
            end
        end
        --if #reqs > 0 and reqs[1] == "level" then
        --    lv = tonumber(reqs[2]);
        --end
    end
    self.deslevel = GetText(self.deslevel);
    self.deslevel.text = "Level limit：<color=#BC4109>" .. lv .. "At least Lv.</color>";

    self.awardItems = {};

    self:InitConsume();

    self:InitAwards();

    self.enter_btn_reddot = RedDot(self.enter_btn.transform, nil, RedDot.RedDotType.Nor)
    self.enter_btn_reddot:SetPosition(80, 21)

end

function ExpEntrancePanel:AddEvent()
    --进入点击事件
    AddClickEvent(self.enter_btn.gameObject, handler(self, self.HandleEnterDungeon));
    --入场券
    AddClickEvent(self.entrance_consume_btn.gameObject, handler(self, self.HandleAddConsume));
    --剩余次数
    AddClickEvent(self.entrance_left_btn.gameObject, handler(self, self.HandleLeft));
    --清除CD
    AddClickEvent(self.clear_cd_btn.gameObject, handler(self, self.HandleClearCd));


    local function call_back(target, value)
        local allData = self.model.dungeon_info_list[self.dungeon_type]
        local data = allData.info
        if data.rest_times <= 1 then
            if value then
                Notify.ShowText("Not enough attempts left")
            end
            self.merge_tg.isOn = false
            return
        end
        if value then
            local function ok_func(count)
                self.merge_tg.isOn = true
                self.model.exp_merge_count = count
                self.Label.text = string.format("Merge %s times", count)
            end
            local function cancle_func()
                self.merge_tg.isOn = false
                self.Label.text = "Combination"
            end
            lua_panelMgr:GetPanelOrCreate(DungeMergePanel):Open(self.dungeon_type, ok_func, cancle_func, data.rest_times, handler(self, self.HandleLeft))
        else
            self.model.exp_merge_count = 1
            self.Label.text = "Combination"
        end
    end
    AddValueChange(self.merge.gameObject, call_back)

    local function call_back(dungeon_type, data)
        if dungeon_type == self.dungeon_type then
            self:UpdateData()
        end
    end
    self.events[#self.events + 1] = GlobalEvent:AddListener(DungeonEvent.UpdateDungeonData, call_back)

    local function call_back(dungeon_type, data)
        if dungeon_type == self.dungeon_type then
            self:UpdateInfo()
        end
    end
    self.events[#self.events + 1] = GlobalEvent:AddListener(DungeonEvent.UpdateDungeonTime, call_back)

    local updateGoods = function()
        self:UpdateLeftTime();
        self:InitConsume();
    end
    AddEventListenerInTab(BagEvent.UpdateGoods, updateGoods, self.events);

    AddEventListenerInTab(DungeonEvent.UpdateReddot, handler(self, self.UpdateReddot), self.events);
end

function ExpEntrancePanel:UpdateData()
    local allData = self.model.dungeon_info_list[self.dungeon_type]
    if not allData then
        return
    end
    local data = allData.info;
    local call_back = function()
        self.countdown.gameObject:SetActive(false);
    end
    if data then
        if data.enter_cd and data.enter_cd ~= 0 then
            self.countdown.gameObject:SetActive(true);
            self.countdowntext.gameObject:SetActive(true);
            self.countdownitem:StartSechudle(data.enter_cd, call_back);
        else
            call_back();
            if self.countdownitem then
                self.countdownitem:StopSchedule();
            end
        end
        self:UpdateLeftTime();
    end
    self:InitConsume();

    self:InitAwards();
end

function ExpEntrancePanel:UpdateInfo()
    local data = self.model.dungeon_info_list[self.dungeon_type]
    if not data then
        return
    end
    local call_back = function()
        self.countdown.gameObject:SetActive(false);
    end
    if data then
        if data.enter_cd then
            if self.countdownitem then
                self.countdownitem:destroy();
            end
            self.countdown.gameObject:SetActive(true);
            self.countdowntext.gameObject:SetActive(true);
            self.countdownitem:StartSechudle(data.enter_cd, call_back);--os.time() +
        end
        --剩余次数: 0/1
        --if data.info.rest_times and data.info.max_times then
        --    if data.info.rest_times > 0 then
        --        self.left_text.text = "剩余次数: " .. data.info.rest_times .. "/" .. data.info.max_times;
        --    else
        --        self.left_text.text = "剩余次数: <color=#ff0000>" .. data.info.rest_times .. "</color>/" .. data.info.max_times;
        --    end
        --end
        self:UpdateLeftTime();
    end
    self:InitConsume();
end

function ExpEntrancePanel:UpdateLeftTime()
    local allData = self.model.dungeon_info_list[self.dungeon_type];
    local data = allData.info;
    --剩余次数: 0/1
    if self.left_text then
        if data.rest_times and data.max_times then
            if data.rest_times > 0 then
                self.left_text.text = "Attempts left: " .. data.rest_times .. "/" .. data.max_times;
            else
                self.left_text.text = "Attempts left: <color=#ff0000>" .. data.rest_times .. "</color>/" .. data.max_times;
            end
        end
    end
end

function ExpEntrancePanel:InitConsume()
    local info = self.model.dungeon_info_list[self.dungeon_type];
    if info then
        local data = Config.db_scene[info.id]
        if data then
            local costTab = String2Table(data.cost);
            if data.cost_type == 0 then
                --配置表改了,把cost改成一个数组,现在默认读数组第一个
                costTab = costTab[1];
            end
            --costTab[1] = 10004
            if costTab then
                local num = BagModel:GetInstance():GetItemNumByItemID(costTab[1]);
                if num >= costTab[2] then
                    self.consume_text.text = "Tickets: " .. num .. "/" .. costTab[2];
                else
                    self.consume_text.text = "Use tickets: <color=#ff0000>" .. num .. "</color>/" .. costTab[2];
                end
            end
        end
    end

end

function ExpEntrancePanel:InitAwards()
    destroyTab(self.awardItems);
    self.awardItems = {};
    local data = self.model.dungeon_info_list[self.dungeon_type]
    if not data then
        return
    end
    local dungeonTab = Config.db_dunge[data.id];
    if dungeonTab then
        local tab = String2Table(dungeonTab.reward_show);
        if tab then
            local item = AwardItem(self.award_item_bg);
            item:SetData(tab[1], 0);
            self.awardItems[1] = item;
            --item:UpdateNum(0);
            item:SetIsSelected(false);
            item:AddClickTips();
            --for i = 1, #tab, 1 do
            --
            --end
        end
    end
end

--self.role_data.gold 元宝(钻石)
--self.role_data.bgold 绑元
--self.role_data.coin 金币
function ExpEntrancePanel:HandleEnterDungeon(target, x, y)
    local data = self.model.dungeon_info_list[self.dungeon_type]
    if data then
        if data.info.rest_times <= 0 then
            Notify.ShowText("Not enough attempts left");
            return ;
        end
        local config = Config.db_dunge[data.id];
        local okFun = function()
            --服务端定一个协议
            local role_data = RoleInfoModel.GetInstance():GetMainRoleData();

            local cdCostTab = String2Table(config.clearcd);
            local cdCost = tonumber(cdCostTab[2]);

            if role_data.gold + role_data.bgold >= cdCost then
                DungeonCtrl:GetInstance():SingleIn(self.model.exp_merge_count);
                ----还是要判断
                --local config1 = Config.db_scene[data.id]
                --if config1 then
                --    local costTab = String2Table(config1.cost);
                --    costTab = costTab[1];--看上面这个引用到cost的注释
                --    local num = BagModel:GetInstance():GetItemNumByItemID(costTab[1]);
                --    if num > 0 then
                --        DungeonCtrl:GetInstance():SingleIn();
                --    else
                --        Notify.ShowText("入场券不足");
                --        return
                --    end
                --
                --end
            else
                Notify.ShowText("Not enough diamond");
            end
        end
        local config = Config.db_scene[data.id]
        if config then
            local costTab = String2Table(config.cost);
            costTab = costTab[1];--看上面这个引用到cost的注释
            local num = BagModel:GetInstance():GetItemNumByItemID(costTab[1]);
            if num > 0 then
                --DungeonCtrl:GetInstance():SingleIn();
                if self.countdownitem.isRuning then
                    --tonumber(data.enter_cd) > os.time;
                    Dialog.ShowTwo("Tip", "Use 100 Diamond (bound diamond first) to skip the CD?", "Confirm", okFun, nil, "Cancel", nil, nil);
                    return ;
                else
                    local count = self.model.exp_merge_count
                    if num >= count then
                        DungeonCtrl:GetInstance():SingleIn(self.model.exp_merge_count);
                    else
                        Notify.ShowText("Insufficient EXP Pass X".. count - num );
                    end
                end
            else
                Notify.ShowText("Not enough tickets");
                return
            end
        else
            Notify.ShowText("Unable to find scene list and cost");
            return
        end


    else
        Notify.ShowText("Unable to find EXP dungeon configuration, please contact engineer");
    end
end

function ExpEntrancePanel:HandleAddConsume(target, x, y)
    --Notify.ShowText("跳转到商城UI");
    UnpackLinkConfig("180@1@2@2@2202")
end

function ExpEntrancePanel:HandleLeft(target, x, y)
    local data = self.model.dungeon_info_list[self.dungeon_type]
    if data then
        lua_panelMgr:GetPanelOrCreate(DungeonEntranceBuyTip):Open(data.info, enum.VIP_RIGHTS.VIP_RIGHTS_DUNGE_EXP_BUY);
    end
end

function ExpEntrancePanel:HandleClearCd(target, x, y)
    local data = self.model.dungeon_info_list[self.dungeon_type]
    local okFun = function()
        --服务端定一个协议
        local role_data = RoleInfoModel.GetInstance():GetMainRoleData();
        local config = Config.db_dunge[data.id];
        local cdCostTab = String2Table(config.clearcd);
        local cdCost = tonumber(cdCostTab[2]);
        --print2(Table2String(data));
        if role_data.gold + role_data.bgold >= cdCost then
            DungeonCtrl:GetInstance():RequestClearTimes(data.stype);
        else
            Notify.ShowText("Not enough diamond");
        end
    end
    Dialog.ShowTwo("Tip", "Use 100 Diamond (bound diamond first) to skip the CD?", "Confirm", okFun, nil, "Cancel", nil, nil);
end

function ExpEntrancePanel:UpdateReddot()
    local tab = DungeonModel:GetInstance().red_dot_list;
    if tab and tab[self.dungeon_type] then
        self.enter_btn_reddot:SetRedDotParam(true);
    else
        self.enter_btn_reddot:SetRedDotParam(false);
    end
end