DungeonBottomRightItem = DungeonBottomRightItem or class("DungeonBottomRightItem", BaseItem);
local this = DungeonBottomRightItem

function DungeonBottomRightItem:ctor(parent_node , bossid)
    self.abName = "dungeon";
    self.image_ab = "dungeon_image";
    self.assetName = "DungeonBottomRightItem"
    self.layer = "Top"
    self.bossid = bossid;
    self.model = DungeonModel.GetInstance()
    self.events = {};
    self.schedules = {};
    DungeonBottomRightItem.super.Load(self)
end

function DungeonBottomRightItem:dctor()
    GlobalEvent:RemoveTabListener(self.events);
    if self.schedule then
        GlobalSchedule:Stop(self.schedule);
    end
    DungeonCtrl:GetInstance().dbri = nil;
end

function DungeonBottomRightItem:LoadCallBack()
    self.nodes = {
        "buyBtn", "bg", "close", "icon", "Text", "buyBtn/buyLabel",
    }
    self:GetChildren(self.nodes)

    SetLocalPosition(self.transform, 445.2  , -108, 0)
    --Notify.ShowText(GetSizeDeltaX(self.bg.transform))
    self:InitUI();

    self:AddEvents();
end

function DungeonBottomRightItem:InitUI()
    self.buyBtn = GetButton(self.buyBtn);
    self.head = GetImage(self.icon);
    self.Text = GetText(self.Text);
    self.buyLabel = GetText(self.buyLabel);

    if self.bossid then
        local creep = Config.db_creep[self.bossid]
        local config = Config.db_boss[self.bossid]
        if creep.rarity == enum.CREEP_RARITY.CREEP_RARITY_TIMEBOSS then
            config = Config.db_timeboss[self.bossid]
        end
        if config then
            self.data = config;
            self.Text.text = config.name;

            lua_resMgr:SetImageTexture(self,self.head , "iconasset/icon_boss_head", config.boss_res, true);
        else
            Notify.ShowText("Abnormal bossid: " .. self.bossid);
        end
    end
end

function DungeonBottomRightItem:UpdateItem(data)
    self.data = data;
    lua_resMgr:SetImageTexture(self, self.head, self.image_ab, "boss_kill_record", true);
end

function DungeonBottomRightItem:AddEvents()
    AddClickEvent(self.buyBtn.gameObject, handler(self, self.HandleEnter));
    AddClickEvent(self.close.gameObject, handler(self, self.HandleClose))
end

function DungeonBottomRightItem:HandleEnter(target, x, y)
    if self.data then
        local sceneid = self.data.scene;
        local scenecfg = Config.db_scene[sceneid]
        if scenecfg.stype == enum.SCENE_STYPE.SCENE_STYPE_TIMEBOSS then
            SceneControler.GetInstance():RequestSceneChange(sceneid, enum.SCENE_CHANGE.SCENE_CHANGE_ACT, nil, nil, 11101)
        else
            if scenecfg.stype == enum.SCENE_STYPE.SCENE_STYPE_BOSS_FISSURE then
                --时空裂缝的boss
                self:HandleEnterSpacetimeCrackBoss(sceneid)
            else
                local coord = String2Table(self.data.coord);
                DungeonCtrl:GetInstance():RequestEnterWorldBoss(sceneid, coord[1], coord[2]);
                DungeonModel:GetInstance().SelectedDungeonID = self.bossid;
            end
           
        end
       -- lua_panelMgr:GetPanelOrCreate(DungeonPanel):Open(1, 1,self.bossid);
        self:HandleClose();
    end
end

function DungeonBottomRightItem:HandleClose(target, x, y)
    local localPos = self.transform.localPosition;

    local end_call_back = function()
        self:destroy();
    end

    local moveAction = cc.MoveTo(0.3, localPos.x, localPos.y - 100, localPos.z)
    --moveAction = cc.EaseIn(moveAction , 3);
    local finishAction = cc.CallFunc(end_call_back)
    local action = cc.Sequence(moveAction, finishAction);
    cc.ActionManager:GetInstance():addAction(action, self.transform);
end

--处理前往时空裂缝boss
function DungeonBottomRightItem:HandleEnterSpacetimeCrackBoss( sceneid  )
    local vipLevel = RoleInfoModel:GetInstance():GetMainRoleVipLevel();
    local vipRightTab = Config.db_vip_rights[enum.VIP_RIGHTS.VIP_RIGHTS_SPATIOTEMPORAL_BOSS];
    local base = tonumber(vipRightTab.base);
    local added = tonumber(vipRightTab["vip" .. vipLevel]);
    local maxtime = base + added;
    local enterTimes = DungeonModel:GetInstance().spacetime_boss_list_info.enter;

    if (maxtime - enterTimes) <= 0 then
        Notify.ShowText(SpacetimeCrackDungePanel.EnterTimeTip);
        return;
    end

    local okFun = function()
        local coord = DungeonModel.GetInstance():GetSpacetimeCrackBossCoord(self.data)
        if sceneid then
            if coord then
                --普通boss
                DungeonCtrl:GetInstance():RequestEnterWorldBoss(sceneid, coord[1], coord[2]);
            else
                --宝箱 守卫 隐藏boss
                DungeonCtrl:GetInstance():RequestEnterWorldBoss(sceneid);
            end
            
            DungeonModel:GetInstance().SelectedDungeonID = self.data.id;
        end

        local panel = lua_panelMgr:GetPanel(DungeonSavageEntranceTicketPanel);
        if panel then
            panel:Close();
        end
    end

    local sceneConfig = Config.db_scene[sceneid];
    if sceneConfig then
        if sceneConfig.cost_type == 1 then
            local cost = String2Table(sceneConfig.cost);
            for k, v in pairs(cost) do
                local min = v[1];
                local max = v[2];

                if (enterTimes + 1) >= min and (enterTimes + 1) <= max then
                    local costItemTab = v[3][1];
                    if costItemTab then
                        local panel = lua_panelMgr:GetPanel(DungeonSavageEntranceTicketPanel);
                        if panel then
                            panel:Close();
                        end

                        lua_panelMgr:GetPanelOrCreate(DungeonSavageEntranceTicketPanel):Open({ call_back = okFun, itemID = costItemTab[1], num = costItemTab[2], sceneName = sceneConfig.name });
                        return ;
                    else
                        --Notify.ShowText("没有找到进入物品需求");
                    end
                end
            end
        else
           -- Notify.ShowText("cost_type不对,请检查");
           local costItemTab = String2Table(sceneConfig.cost)
            lua_panelMgr:GetPanelOrCreate(DungeonSavageEntranceTicketPanel):Open({ call_back = okFun, itemID = costItemTab[1][1], num = costItemTab[1][2], sceneName = sceneConfig.name });
        end
    else
        --Notify.ShowText("找不到场景配置");
        return ;
    end
end