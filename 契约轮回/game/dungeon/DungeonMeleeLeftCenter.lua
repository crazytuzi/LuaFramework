DungeonMeleeLeftCenter = DungeonMeleeLeftCenter or class("DungeonMeleeLeftCenter", BaseItem);
local this = DungeonMeleeLeftCenter

function DungeonMeleeLeftCenter:ctor(parent_node, bossid)
    self.abName = "dungeon";
    self.image_ab = "dungeon_image";
    self.assetName = "DungeonMeleeLeftCenter"
    self.layer = "Bottom"
    self.bossid = bossid;
    self.model = DungeonModel.GetInstance()
    self.events = {};
    self.schedules = {};

    self.items = {};
    DungeonMeleeLeftCenter.super.Load(self)
end

function DungeonMeleeLeftCenter:dctor()
    GlobalEvent:RemoveTabListener(self.events);
    if self.schedule then
        GlobalSchedule:Stop(self.schedule);
    end

    destroyTab(self.items);
    self.items = {};

    if self.autoRequestRank then
        GlobalSchedule.StopFun(self.autoRequestRank);
    end
    self.autoRequestRank = nil;

    if self.autoRequestDamage then
        GlobalSchedule.StopFun(self.autoRequestDamage);
        self.autoRequestDamage = nil;
    end

    destroyTab(self.rankItems);
    self.rankItems = {};

    destroyTab(self.damageItems);
    self.damageItems = {};

    if self.mineItem then
        self.mineItem:destroy();
    end
    self.mineItem = nil;

    if self.bossSchedule then
        GlobalSchedule.StopFun(self.bossSchedule);
    end
    self.bossSchedule = nil;

    if self.meleeschedules then
        GlobalSchedule.StopFun(self.meleeschedules);
    end
    self.meleeschedules = nil;
end

function DungeonMeleeLeftCenter:LoadCallBack()
    self.nodes = {
        "min_btn", "con/contents_1", "con/contents_2", "con/contents_3", "con",
        --content1
        "con/contents_1/ranks", "con/contents_1/content_text_1", "con/contents_1/rank_item_0", "con/contents_1/qianwang_1",
        --"con/contents_1/rank_item_0/score","con/contents_1/rank_item_0/role_name",
        --content2
        "con/contents_2/content_label_2", "con/contents_2/value1", "con/contents_2/value2", "con/contents_2/wenhao1",
        "con/contents_2/content_label_1", "con/contents_2/chakanjifen", "con/contents_2/content_label_3", "con/contents_2/content_label_4", "con/contents_2/value3",
        "con/contents_2/ScrollView/Viewport/awardCon",
        --content3
        "con/contents_3/items/list_item_1", "con/contents_3/close", "con/contents_3/items/list_item_2", "con/contents_3/items/list_item_3", "con/contents_3/items/list_item_4", "con/contents_3/items/list_item_5",
        "con/contents_3/mine", "con/contents_3/wenhao2",

        "endTime", "startTime", "endTime/endTitleTxt", "startTime/time",
    }
    self:GetChildren(self.nodes)

    SetLocalPosition(self.transform, 0, 0, 0);

    SetAlignType(self.con.transform, bit.bor(AlignType.Left, AlignType.Null));
   -- SetAlignType(self.transform, bit.bor(AlignType.Left, AlignType.Null))
    LayerManager.GetInstance():AddOrderIndexByCls(self, self.contents_3, nil, true, nil, 1, 2)

    self:InitUI();

    self:AddEvents();

    self:CheckMove();
    DungeonCtrl:GetInstance():RequestMeleeInfo();

  end

function DungeonMeleeLeftCenter:CheckMove()
    local call_back = function()
        if not AutoFightManager:GetInstance():GetAutoFightState() then
            GlobalEvent:Brocast(FightEvent.AutoFight)
        end
    end

    if self.items then
        if DungeonModel:GetInstance().SelectedDungeonID then
            for k, v in pairs(self.items) do
                if v.data.id == DungeonModel:GetInstance().SelectedDungeonID then
                    local tab = v.data;
                    local coord = String2Table(tab.coord);
                    local main_role = SceneManager:GetInstance():GetMainRole()
                    local main_pos = main_role:GetPosition();
                    TaskModel:GetInstance():StopTask();--先停掉任务,因为任务优先级高
                    OperationManager:GetInstance():TryMoveToPosition(nil, main_pos, { x = coord[1], y = coord[2] }, call_back);
                    DungeonModel:GetInstance().SelectedDungeonID = nil;
                    return ;
                end
            end
        end
    end
end

function DungeonMeleeLeftCenter:InitUI()
    self.min_btn = GetButton(self.min_btn);
    SetGameObjectActive(self.min_btn, false);

    self.endTitleTxt = GetText(self.endTitleTxt);--副本倒计时: 07:21
    self.time = GetText(self.time);

    SetGameObjectActive(self.endTime, false);

    self.chakanjifen = GetImage(self.chakanjifen);

    self.close = GetButton(self.close);

    self.value1 = GetText(self.value1);
    self.value2 = GetText(self.value2);
    self.value3 = GetText(self.value3);

    destroyTab(self.rankItems);
    self.rankItems = {};
    for i = 1, 5 do
        local item = MeleeCenterItem(self["list_item_" .. i], nil, 2);
        self.rankItems[i] = item;
        item:SetKing(i);

        --SetGameObjectActive(item.gameObject, false);
        --SetLocalPosition(item.transform, 0, 0, 0);
        --SetLocalScale(item.transform, 1, 1, 1);
    end
    self.mineItem = MeleeCenterItem(self.mine, nil, 2);
    SetGameObjectActive(self.mineItem, false);

    SetGameObjectActive(self.rank_item_0, false);

    SetGameObjectActive(self.contents_3, false);
    SetGameObjectActive(self.contents_2, false);
end

function DungeonMeleeLeftCenter:AddEvents()
    AddClickEvent(self.chakanjifen.gameObject, handler(self, self.HandleChaKanJiFen));

    AddClickEvent(self.close.gameObject, handler(self, self.HandleCloseScoreRank));

    AddClickEvent(self.qianwang_1.gameObject, handler(self, self.HandleQianWang));

    AddEventListenerInTab(MELEEEvent.MELEE_INFO, handler(self, self.HandleMeleeInfo), self.events);
    AddEventListenerInTab(MELEEEvent.MELEE_SELF, handler(self, self.HandleMeleeSelf), self.events);
    AddEventListenerInTab(MELEEEvent.MELEE_ROUND_BEGIN, handler(self, self.HandleRoundBegin), self.events);
    AddEventListenerInTab(MELEEEvent.MELEE_ROUND_END, handler(self, self.HandleRoundEnd), self.events);
    AddEventListenerInTab(MELEEEvent.MELEE_SCORE_RANK, handler(self, self.HandleScoreRank), self.events);
    AddEventListenerInTab(MELEEEvent.MELEE_DAMAGE_RANK, handler(self, self.HandleDamageRank), self.events);

    local tip2 = function()
        ShowHelpTip(HelpConfig.Melee.dungeon2, nil, 500);
    end
    local tip1 = function()
        ShowHelpTip(HelpConfig.Melee.dungeon1, nil, 500);
    end
    AddClickEvent(self.wenhao2.gameObject, tip2);
    SetGameObjectActive(self.wenhao2.gameObject, false);
    AddClickEvent(self.wenhao1.gameObject, tip1);

    self:AddMeleeItemEvent();
    GlobalEvent.AddEventListenerInTab(EventName.GameReset, function()
        self:destroy()
    end, self.events);

    --结束副本时间
    self.meleeschedules = GlobalSchedule:Start(handler(self, self.EndDungeon), 0.2, -1);

    local call_back = function()
        SetGameObjectActive(self.endTime.gameObject, false);
        self.hideByIcon = true;
    end

    self.events[#self.events + 1] = GlobalEvent.AddEventListener(MainEvent.ShowTopRightIcon, call_back);

    local call_back1 = function()
        SetGameObjectActive(self.endTime.gameObject, true);
        self.hideByIcon = nil;
    end

    self.events[#self.events + 1] = GlobalEvent.AddEventListener(MainEvent.HideTopRightIcon, call_back1);
end

function DungeonMeleeLeftCenter:AddMeleeItemEvent()
    for i = 1, #self.rankItems do
        AddClickEvent(self.rankItems[i].gameObject, handler(self, self.HandleRankItemClick, self.rankItems[i]));
    end
end

function DungeonMeleeLeftCenter:HandleRankItemClick(go, x, y, rankItem)
    if self.rankItems then
        for k, v in pairs(self.rankItems) do
            v:SetSelected(false);
        end
    end

    rankItem:SetSelected(true);
end

function DungeonMeleeLeftCenter:HandleQianWang(go, x, y)
    --Notify.ShowText("前往杀怪");
    local bossID = 30311010;
    local coord = SceneConfigManager:GetInstance():GetCreepPosition(nil, bossID);
    if coord then
        local call_back = function()
            --if not AutoFightManager:GetInstance():GetAutoFightState() then
            --    GlobalEvent:Brocast(FightEvent.AutoFight)
            --end
            AutoFightManager:GetInstance():Start(true)

            local object = SceneManager:GetInstance():GetCreepByTypeId(bossID)
            if object then
                object:OnClick()
            end
            local data = Config.db_boss[bossID];
            if data then
                local tab = data;
                local coord = String2Table(tab.coord);
                AutoFightManager:GetInstance():SetAutoPosition(coord)
            end
        end
        --OperationManager:GetInstance():TryMoveToPosition(nil, SceneManager:GetInstance():GetMainRole():GetPosition(), coord, call_back);
        OperationManager:GetInstance():TryMoveToPosition(nil, SceneManager:GetInstance():GetMainRole():GetPosition(), coord, call_back, self:GetRange());
    else

    end
end

function DungeonMeleeLeftCenter:HandleMeleeInfo(data)
    local boss_refresh = data.boss_refresh;
    self.end_time = data.etime;
    --print2("DungeonMeleeLeftCenter:HandleMeleeInfo");
    if boss_refresh then
        if boss_refresh == 0 then
            self:RoundBegin();
        else
            self:RoundEnd(boss_refresh);
        end
    end
    if data and data.activity_id == DungeonModel.MELEE_CROSS_ACTIVITY_ID then
        self.isCross = true;
    else
        self.isCross = false;
    end
end

function DungeonMeleeLeftCenter:EndDungeon()
    local timeTab = nil;
    local timestr = "";
    local formatTime = "%02d";
    --整个副本的结束时间
    if self.end_time then
        if not self.startSchedule and not self.hideByIcon then
            SetGameObjectActive(self.endTime.gameObject, true);
        else
            SetGameObjectActive(self.endTime.gameObject, false);
        end

        timeTab = TimeManager:GetLastTimeData(os.time(), self.end_time);
        if table.isempty(timeTab) then
            --Notify.ShowText("副本结束了,需要做清理了");
            SetGameObjectActive(self.endTime.gameObject, false);
            GlobalSchedule.StopFun(self.meleeschedules);
        else
            timeTab.min = timeTab.min or 0;
            if timeTab.min then
                timestr = timestr .. string.format(formatTime, timeTab.min) .. ":";
            end
            if timeTab.sec then
                timestr = timestr .. string.format(formatTime, timeTab.sec);
            end
            self.endTitleTxt.text = timestr;--"副本倒计时: " ..
        end
    end
    if self.dungeon_is_exit then
        SetGameObjectActive(self.endTime.gameObject, false);
    end
end

function DungeonMeleeLeftCenter:RoundBegin()
    self:StartDamageRequest();
    SetGameObjectActive(self.contents_3, false);
    SetGameObjectActive(self.contents_2, false);
    SetGameObjectActive(self.contents_1, true);
    --SetGameObjectActive(self.content_text_1, false);
    --self.content_text_1.text = "(夺宝守护者已刷新)";
end

function DungeonMeleeLeftCenter:RoundEnd(boss_refresh)
    self:StopDamageRequest();
    SetGameObjectActive(self.contents_3, false);
    SetGameObjectActive(self.contents_2, true);
    SetGameObjectActive(self.contents_1, false);
    self:StartBossCountDown(boss_refresh);
    SetGameObjectActive(self.content_text_1, true);
    --self.content_text_1.text = "(夺宝守护者已刷新)";


end

function DungeonMeleeLeftCenter:StartBossCountDown(boss_refresh)
    self.boss_refresh = boss_refresh;
    if self.bossSchedule then
        GlobalSchedule.StopFun(self.bossSchedule);
        self.bossSchedule = nil;
    end
    self.bossSchedule = GlobalSchedule.StartFun(handler(self, self.HandleBossCountDown), 0.2, -1);
end

function DungeonMeleeLeftCenter:HandleBossCountDown()
    local timeTab = nil;
    local timestr = "";
    local formatTime = "%02d";
    if self.boss_refresh then
        timeTab = TimeManager:GetLastTimeData(os.time(), self.boss_refresh);

        if table.isempty(timeTab) then
            GlobalSchedule.StopFun(self.bossSchedule);
            self.boss_refresh = nil;
        else
            timeTab.min = timeTab.min or 0;
            if timeTab.min then
                timestr = timestr .. string.format(formatTime, timeTab.min) .. ":";
            end
            if timeTab.sec then
                timestr = timestr .. string.format(formatTime, timeTab.sec);
            end
            self.value1.text = timestr;
        end
    end
end

function DungeonMeleeLeftCenter:StopDamageRequest()
    if self.autoRequestDamage then
        GlobalSchedule.StopFun(self.autoRequestDamage);
        self.autoRequestDamage = nil;
    end
end
function DungeonMeleeLeftCenter:StartDamageRequest()
    self:StopDamageRequest();
    self.autoRequestDamage = GlobalSchedule.StartFun(handler(self, self.HandleRequestDamage), 3, -1);
end

function DungeonMeleeLeftCenter:HandleRequestDamage()
    DungeonCtrl:GetInstance():RequestDamageRank();
end

function DungeonMeleeLeftCenter:HandleMeleeSelf(data)
    --print2("DungeonMeleeLeftCenter:HandleMeleeSelf");
    self.value2.text = tostring(data.score);
    self.value3.text = tostring(data.rank);
    local name = RoleInfoModel:GetInstance():GetMainRoleData().name;
    if self.mineItem and not self.mineItem.is_dctored then
        SetGameObjectActive(self.mineItem, true);
        self.mineItem:UpdateData2(data.rank, data.score, name)
    end

    if self.rank ~= data.rank then
        self:InitRewards(data.rank);
    end
    self.rank = data.rank;
end

function DungeonMeleeLeftCenter:InitRewards(rank)
    destroyTab(self.awardItems);
    self.awardItems = {};
    local max = 3;
    local index = 1;
    local tab = Config.db_melee_score[rank];
    if tab then
        local rewardTab = String2Table(tab.reward);
        if self.isCross then
            rewardTab = String2Table(tab.cross_reward);
        end
        for i = 1, #rewardTab do
            if index <= max then
                local reward = rewardTab[i];
                local awardItem = AwardItem(self.awardCon);
                local level = RoleInfoModel:GetInstance():GetMainRoleLevel();
                if Config.db_exp_acti_base[level] and reward[1] == enum.ITEM.ITEM_PLAYER_EXP then
                    local num = Config.db_exp_acti_base[level].worldlv_exp * reward[2];
                    awardItem:SetData(reward[1], num);
                else
                    awardItem:SetData(reward[1], reward[2]);
                end

                awardItem:AddClickTips();
                table.insert(self.awardItems, awardItem);
                index = index + 1;
            end

        end

        local mailTab = String2Table(tab.mail_reward);
        if self.isCross then
            mailTab = String2Table(tab.cross_mail_reward);
        end
        for i = 1, #mailTab do
            if index <= max then
                local reward = mailTab[i];
                local awardItem = AwardItem(self.awardCon);
                awardItem:SetData(reward[1], reward[2]);
                awardItem:AddClickTips();
                table.insert(self.awardItems, awardItem);
                index = index + 1;
            end
        end
    end
end

function DungeonMeleeLeftCenter:HandleRoundBegin()
    --print2("DungeonMeleeLeftCenter:HandleRoundBegin");
    Notify.ShowText("Boss comes out, go and challenge");
    self:RoundBegin();
end

function DungeonMeleeLeftCenter:GetRange()
    if not AutoFightManager:GetInstance().def_range then
        return nil
    end
    -- return AutoFightManager:GetInstance().def_range * 0.9
    return 500
end

function DungeonMeleeLeftCenter:HandleRoundEnd(boss_refresh)
    --print2("DungeonMeleeLeftCenter:HandleRoundEnd");
    self:RoundEnd(boss_refresh);
end

function DungeonMeleeLeftCenter:HandleScoreRank(data)
    --print2("DungeonMeleeLeftCenter:HandleScoreRank");
    local ranks = data;
    for i = 1, 5 do
        if ranks[i] then
            SetGameObjectActive(self.rankItems[i].gameObject, true);
            self.rankItems[i]:UpdateData(ranks[i]);
        else
            SetGameObjectActive(self.rankItems[i].gameObject, false);
        end
    end


end

function DungeonMeleeLeftCenter:HandleDamageRank(data)
    --print2("DungeonMeleeLeftCenter:HandleDamageRank");
    local damages = data;
    destroyTab(self.damageItems);
    self.damageItems = {};
    SetGameObjectActive(self.rank_item_0, true);
    for i = 1, #damages do
        local damageItem = MeleeCenterItem(newObject(self.rank_item_0), damages[i], 1);
        self.damageItems[i] = damageItem;
        SetParent(damageItem.transform, self.ranks.transform);
        SetLocalPosition(damageItem.transform, 0, 0, 0);
        SetLocalScale(damageItem.transform, 1, 1, 1);
    end
    SetGameObjectActive(self.rank_item_0, false);

    if table.isempty(damages) then

    else
        SetGameObjectActive(self.content_text_1, false);
    end
end

function DungeonMeleeLeftCenter:HandleRequestRankInfo()
    DungeonCtrl:GetInstance():RequestScoreRank();
end

function DungeonMeleeLeftCenter:HandleChaKanJiFen()
    SetGameObjectActive(self.contents_3.gameObject, not self.contents_3.gameObject.activeSelf);
    if self.contents_3.gameObject.activeSelf then
        self:HandleRequestRankInfo();
        if self.autoRequestRank then
            GlobalSchedule.StopFun(self.autoRequestRank);
            self.autoRequestRank = nil;
        end
        self.autoRequestRank = GlobalSchedule.StartFun(handler(self, self.HandleRequestRankInfo), 3, -1);
    else

        if self.autoRequestRank then
            GlobalSchedule.StopFun(self.autoRequestRank);
            self.autoRequestRank = nil;
        end
    end
end

function DungeonMeleeLeftCenter:HandleCloseScoreRank()
    SetGameObjectActive(self.contents_3.gameObject, false);
    if self.autoRequestRank then
        GlobalSchedule.StopFun(self.autoRequestRank);
        self.autoRequestRank = nil;
    end
end

function DungeonMeleeLeftCenter:AddTogEvents()
    for i = 1, #self.items, 1 do
        local item = self.items[i];
        AddClickEvent(item.gameObject, handler(self, self.HandleMoveTo));
    end
end

function DungeonMeleeLeftCenter:HandleMin(target, x, y)
    RemoveClickEvent(self.min_btn.gameObject);
    local scale = self.min_btn.transform.localScale;
    local localPos = self.contents.transform.localPosition;

    local end_call_back = function()
        SetLocalScale(self.min_btn.transform, -scale.x, 1, 1);
        if scale.x == 1 then
            --self.contents.gameObject:SetActive(false);
        end
        AddClickEvent(self.min_btn.gameObject, handler(self, self.HandleMin))
    end

    local moveAction;
    local finishAction;
    local action;

    if scale.x == -1 then
        moveAction = cc.MoveTo(0.3, 0, 0, 0);
        finishAction = cc.CallFunc(end_call_back)
        action = cc.Sequence(moveAction, finishAction);
        cc.ActionManager:GetInstance():addAction(action, self.contents.transform);
        --self.contents.gameObject:SetActive(true);
    else
        moveAction = cc.MoveTo(0.3, -300, localPos.y, localPos.z)
        finishAction = cc.CallFunc(end_call_back)
        action = cc.Sequence(moveAction, finishAction);
        cc.ActionManager:GetInstance():addAction(action, self.contents.transform);
    end
end

MeleeCenterItem = MeleeCenterItem or class("MeleeCenterItem", BaseItem);
local this = MeleeCenterItem

function MeleeCenterItem:ctor(obj, tab, itemType)
    self.abName = "dungeon";
    self.image_ab = "dungeon_image";
    self.layer = "Bottom"

    self.data = tab;
    self.itemType = itemType;

    self.transform = obj.transform
    self.gameObject = self.transform.gameObject;
    self.transform_find = self.transform.Find;

    self.events = {};
    self.schedules = {};

    self:Init();
end

function MeleeCenterItem:dctor()
    GlobalEvent:RemoveTabListener(self.events);
    if self.schedule then
        GlobalSchedule:Stop(self.schedule);
    end
end

function MeleeCenterItem:Init()
    self.is_loaded = true;
    if self.itemType == 1 then
        self.nodes = {
            "role_name", "score", "role_rank",
        }
    elseif self.itemType == 2 then
        self.nodes = {
            "selected", "role_name", "score", "rankicon", "role_rank",
        }
    else
        self.nodes = {
            "selected", "role_name", "score", "rankicon", "role_rank",
        }
    end

    self:GetChildren(self.nodes)

    --SetLocalPosition(self.transform, 0, 0, 0);---474.63,-93.2,0
    self:InitUI();

    self:AddEvents();
end
--堕落战神 <color=#ffffff>Lv.260</color>
function MeleeCenterItem:InitUI()
    self.role_name = GetText(self.role_name.gameObject);
    self.score = GetText(self.score.gameObject);
    if self.selected then
        self.selected = GetImage(self.selected.gameObject);
    end
    if self.role_rank then
        self.role_rank = GetText(self.role_rank.gameObject);
    end

    if self.rankicon then
        self.rankicon = GetImage(self.rankicon.gameObject);
    end

    if self.data then


        if self.itemType == 1 then
            self.role_name.text = self.data.rank .. ":" .. self.data.name;
            self.score.text = self.data.val;
        else
            --self.role_name.text = self.data.name;--  1    :陈镇火六个字
            if self.role_rank then
                self.role_rank.text = tostring(self.data.rank);
            end

            if self.role_name then
                self.role_name.text = ":" .. self.data.name;
            end

            if self.score then
                self.score.text = self.data.val;
            end

        end

        if self.itemType == 2 then
            self.rankicon = GetImage(self.rankicon.gameObject);
            --if self.data.rank < 4 then
            --    SetGameObjectActive(self.rankicon.gameObject, true);
            --else
            --    SetGameObjectActive(self.rankicon.gameObject, false);
            --end
        elseif self.itemType == 3 then

        end

        self:SetSelected(false);
    end
end

function MeleeCenterItem:AddEvents()

end

function MeleeCenterItem:SetKing(num)
    --if self.rankicon then
    --    if num < 3 then
    --        SetGameObjectActive(self.rankicon.gameObject, true);
    --        --lua_resMgr:SetImageTexture(self, self.cardAdds[i], self.image_ab, "magic_card_embed_added", false);
    --        lua_resMgr:SetImageTexture(self, self.rankicon, self.image_ab, "melee_dungeon_rank_icon_" .. num, false)
    --    else
    --        SetGameObjectActive(self.rankicon.gameObject, false);
    --    end
    --
    --end

end

function MeleeCenterItem:UpdateData(data)
    self.data = data;
    self:InitUI();
end

function MeleeCenterItem:UpdateData2(rank, score, name)

    if self.role_rank then
        if rank > 5 then
            self.role_rank.text = "5+";
        else
            self.role_rank.text = tostring(rank);
        end

    end

    if self.role_name then
        self.role_name.text = ":" .. name;
    end
    --if rank > 5 then
    --    self.role_name.text = "  5+   :" .. name;
    --else
    --    self.role_name.text = "  " .. rank .. "   :" .. name;
    --end
    --self.role_name.text = name;--  1+   :陈镇火六个字
    if self.score then
        self.score.text = score;
    end

end

function MeleeCenterItem:SetSelected(bool)
    bool = toBool(bool);
    if self.selected then
        self.selected.gameObject:SetActive(bool);
    end

end