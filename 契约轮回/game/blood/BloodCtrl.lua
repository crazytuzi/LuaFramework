---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by win 10.
--- DateTime: 18/11/10 10:57
---

require('game.blood.RequireBlood')

BloodCtrl = BloodCtrl or class("BloodCtrl", BaseController)
local this = BloodCtrl
BloodCtrl.allShowBloodRarity = {
    [enum.CREEP_RARITY.CREEP_RARITY_BOSS2] = true,
    [enum.CREEP_RARITY.CREEP_RARITY_BOSS] = true,
    [enum.CREEP_RARITY.CREEP_RARITY_HUNT] = true,
    [enum.CREEP_RARITY.CREEP_GUILD_BOSS] = true,
}
--BloodCtrl
function BloodCtrl:ctor()
    BloodCtrl.Instance = self;
    self:Init();

    self:AddEvents()
end

function BloodCtrl:dctor()
    GlobalEvent:RemoveTabListener(self.events);
end

function BloodCtrl:GetInstance()
    if not BloodCtrl.Instance then
        BloodCtrl()
    end
    return BloodCtrl.Instance
end

function BloodCtrl:Init()
    self.model = DungeonModel:GetInstance()
    self.events = {};
    self.monsters = {};

    self.blood = BossBloodView(LayerManager:GetInstance():GetLayerByName(LayerManager.LayerNameList.Bottom));
end
function BloodCtrl:AddEvents()
    self.schedule = GlobalSchedule.StartFun(handler(self, self.HandleGuard), 0.2, -1)
    GlobalEvent.AddEventListenerInTab(EventName.NewSceneObject, handler(self, self.HandleNewCreate), self.events);
    GlobalEvent.AddEventListenerInTab(EventName.CLEAR_BLOOD_MONSTER, handler(self, self.HandleChangeScene), self.events);

    --[[StopSchedule(self.schedule);
    self.schedule = GlobalSchedule.StartFun(handler(self, self.HandleGuard), 0.2, -1);
    
    --考虑去掉
    self.events[#self.events + 1] = GlobalEvent.AddEventListener(DungeonEvent.SHOW_BOSS_BLOOD, handler(self, self.HandleShowBossBlood))
    GlobalEvent.AddEventListenerInTab(DungeonEvent.CLOSE_BOSS_BLOOD, handler(self, self.CloseBossBloodView), self.events);

    local call_back = function()
        self.blood:SetVisibleState(BossBloodView.VisibleBitState.TopRightIcon,true)
        self.hideByIcon = true;
    end

    self.events[#self.events + 1] = GlobalEvent.AddEventListener(MainEvent.ShowTopRightIcon, call_back);

    local call_back1 = function()
        self.hideByIcon = false;
        if self.lock_role and self.isLockRole then
            self:HandleRoleBeLock(self.lock_role, self.isLockRole);
        end

        self.blood:SetVisibleState(BossBloodView.VisibleBitState.TopRightIcon,false)
    end
    self.events[#self.events + 1] = GlobalEvent.AddEventListener(MainEvent.HideTopRightIcon, call_back1);

    GlobalEvent.AddEventListenerInTab(EventName.MONSTER_BE_LOCK, handler(self, self.HandleBeLock), self.events);

    GlobalEvent.AddEventListenerInTab(EventName.ROLE_BE_LOCK, handler(self, self.HandleRoleBeLock), self.events);--]]

    GlobalEvent.AddEventListenerInTab(EventName.MONSTER_BE_LOCK, handler(self, self.HandleBeLock), self.events);

    GlobalEvent.AddEventListenerInTab(EventName.ROLE_BE_LOCK, handler(self, self.HandleBeLock), self.events);
end

function BloodCtrl:HandleChangeScene(SCENE_ID)
    self.monsters = {};
    if self.object_info_event then
        for k, v in pairs(self.object_info_event) do
            k:RemoveListener(v);
        end
    end
    self.object_info_event = {};

end

function BloodCtrl:HandleNewCreate(monster)
    logWarn("BloodCtrl:HandleNewCreate" .. debug.traceback());
    self.object_info_event = self.object_info_event or {};
    if monster and monster.object_type == enum.ACTOR_TYPE.ACTOR_TYPE_CREEP then
        local object_info = monster.object_info;
        local config = Config.db_boss[object_info.id];
        if monster.config then
            --普通的BOSS也要显示血条
            if self.allShowBloodRarity[monster.config.rarity] and monster.config.kind == enum.CREEP_KIND.CREEP_KIND_MONSTER then
                table.insert(self.monsters, monster);
                --elseif monster.config.rarity == enum.CREEP_RARITY.CREEP_RARITY_BOSS3 then
                --else
                --    if object_info then
                --        self.object_info_event[object_info] = object_info:BindData("hp", handler(self, self.HandleBindHp , monster));
                --    end
            end
        elseif config then
            table.insert(self.monsters, monster);
        end
    end
end

function BloodCtrl:HandleGuard()
    local del_tab
    local len = #self.monsters
    for k=1,len do
        local monster = self.monsters[k]
        if monster.is_dctored then
            del_tab = del_tab or {}
            del_tab[#del_tab + 1] = k
        elseif monster and monster.object_info and monster.object_info.hp <= 0 then
            del_tab = del_tab or {}
            del_tab[#del_tab + 1] = k
        end
    end
    if del_tab then
        table.RemoveByIndexList(self.monsters, del_tab)
    end
    local isShow = false;
    for k, monster in pairs(self.monsters) do
        local object_info = monster.object_info;
        if object_info then
            local main_role = SceneManager:GetInstance():GetMainRole();

            local config = Config.db_creep[object_info.id];
            local bossConfig = Config.db_boss[object_info.id];
            if config and bossConfig then
                local coord = String2Table(bossConfig.coord);
                if DungeonModel.GetInstance():IsSpacetimeCrackBoss(bossConfig.type) then
                    coord = DungeonModel.GetInstance():GetSpacetimeCrackBossCoord(bossConfig)
                end
                if coord then
                    coord = { x = coord[1], y = coord[2] };
                end
                if main_role then
                local main_role_data = main_role.object_info;
                    --if Vector2.Distance()
                    if coord and coord.x and coord.y and Vector2.Distance(main_role_data.coord, coord) < config.guard then
                        --GlobalEvent.BrocastEvent(DungeonEvent.SHOW_BOSS_BLOOD, object_info);
--[[                        if not self.isLockRole then
                            self:HandleShowBossBlood(object_info);
                        end--]]
                        --self.blood:ShowBloodType(1);
                        isShow = true;
                    --else
                    --    print2("距离太远");
                    end
                end
                local belong_role = (object_info["ext"] and object_info["ext"]["belong_role"] and object_info["ext"]["belong_role"] ~= "0") and object_info["ext"]["belong_role"];
                local belong_team = (object_info["ext"] and object_info["ext"]["belong_team"] and object_info["ext"]["belong_team"] ~= "0") and object_info["ext"]["belong_team"];
                --if monster.object_info["ext"] and (object_info["ext"]["belong_role"] or object_info["belong_role"] or ) then
                --monster.object_info["ext"] and
                if belong_role then
                    --if belong_role == "0" or belong_role == nil then
                    --    belong_role = object_info["belong_role"]
                    --end
                    local role = SceneManager:GetInstance():GetObject(belong_role);
                    if role then
                        local role_info = role.object_info;--SceneManager:GetInstance():GetObjectInfo(belong_role);

                        if role_info and coord and coord.x and coord.y then
                            local isInGuard = Vector2.Distance(role.position, coord) < config.guard;
                            role.name_container:ShowBelong(isInGuard);
                            monster:AddBelong(role, isInGuard);

                            local allRole2 = SceneManager:GetInstance():GetObjectListByType(enum.ACTOR_TYPE.ACTOR_TYPE_ROLE);
                            if allRole2 then
                                if main_role then
                                    allRole2[main_role.object_info.uid] = main_role;
                                end

                                for uid, role1 in pairs(allRole2) do
                                    if uid ~= belong_role then
                                        role1.name_container:ShowBelong(false);
                                        monster:AddBelong(role1, false);
                                    end
                                end
                            end
                            if self.blood and self.blood.uid == object_info.uid then
                                GlobalEvent.BrocastEvent(SceneEvent.MONSTER_BELONG_CHANGE, role_info);
                            end
                        end
                    end

                    if belong_team then
                        local teamInfo = TeamModel:GetInstance():GetTeamInfo();
                        if teamInfo and tostring(teamInfo.id) == belong_team then
                            for i = 1, #teamInfo.members do
                                role = SceneManager:GetInstance():GetObject(teamInfo.members[i].role_id);
                                if role and coord and coord.x and coord.y then
                                    local isInGuard = Vector2.Distance(role.position, coord) < config.guard;
                                    role.name_container:ShowBelong(isInGuard);
                                    monster:AddBelong(role, isInGuard);
                                end
                            end
                        end

                        local allRole = SceneManager:GetInstance():GetObjectListByType(enum.ACTOR_TYPE.ACTOR_TYPE_ROLE);
                        if allRole then
                            for uid2, role3 in pairs(allRole) do
                                if tostring(role3.object_info["team"]) ~= belong_team then
                                    role3.name_container:ShowBelong(false);
                                    monster:AddBelong(role3, false);
                                end
                            end
                        end

                        local myteam = TeamModel:GetInstance():GetTeamInfo();
                        --local mainrole = SceneManager:GetInstance():GetMainRole();
                        if myteam and tostring(myteam.id) == belong_team then
                            if main_role then
                                main_role.name_container:ShowBelong(true);
                                monster:AddBelong(main_role, true);
                            end
                        else
                            if main_role then
                                main_role.name_container:ShowBelong(false);
                                monster:AddBelong(main_role, false);
                            end
                        end
                    end
                else
                    monster:ClearBelong();
                    if self.blood then
                        self.blood:HandleBossBelong(nil);
                    end
                end
            --[[elseif config and self.allShowBloodRarity[monster.config.rarity] then
                local coord = monster:GetPosition();

                if main_role then
                    local main_role_data = main_role.object_info;
                    --if Vector2.Distance()
                    if Vector2.Distance(main_role_data.coord, coord) < config.guard then
                        isShow = true;
                        if not self.isLockRole then
                            self:HandleShowBossBlood(object_info);
                        end
                        --self.blood:ShowBloodType(1);
                        --GlobalEvent.BrocastEvent(DungeonEvent.SHOW_BOSS_BLOOD, object_info);
                    end
                    --不需要停止定时器
                    --if object_info.hp <= 0 then
                    --    StopSchedule(self.schedule);
                    --end
                end--]]
            end
        end
    end
    --[[if self.lock_role_uid then
        local main_role = SceneManager:GetInstance():GetMainRole();
        local role = SceneManager:GetInstance():GetObject(self.lock_role_uid);
        local role_info = SceneManager:GetInstance():GetObjectInfo(self.lock_role_uid);
        if not role_info then
            self.lock_role_uid = nil;
        end
        if main_role then
            local main_role_data = main_role.object_info;
            --if Vector2.Distance()
            if Vector2.Distance(main_role_data.coord, role_info.coord) < 500 then
                self:HandleShowBossBlood(role_info);
                isShow = true;
            end
        end
    end
    if (table.isempty(self.monsters) or not isShow) and not self.isLockShow and not self.isLockRole then
        self:CloseBossBloodView();
    end--]]
end

function BloodCtrl:HandleBeLock(monster, isLock)
    logWarn("BloodCtrl:HandleBeLock" .. debug.traceback());
    if PeakArenaModel:GetInstance().isOpenBattlePanel or CompeteModel:GetInstance().isOpenBattlePanel then  --巅峰1v1不显示血条
        return 
    end
    local uid = FightManager.GetInstance().client_lock_target_id
    local obj = SceneManager.GetInstance():GetObject(uid)
    if obj and obj.object_info then
        if obj.object_type == enum.ACTOR_TYPE.ACTOR_TYPE_CREEP then
            local monster = Config.db_creep[obj.object_info.id]
            if monster.rarity ==  enum.CREEP_RARITY.CREEP_RARITY_BOSS or
               monster.rarity == enum.CREEP_RARITY.CREEP_RARITY_BOSS2 or
               monster.rarity == enum.CREEP_RARITY.CREEP_RARITY_BOSS3 or 
               monster.rarity == enum.CREEP_RARITY.CREEP_RARITY_HUNT or
               monster.rarity == enum.CREEP_RARITY.CREEP_GUILD_BOSS or
               monster.rarity == enum.CREEP_RARITY.CREEP_RARITY_TIMEBOSS or 
               monster.rarity == enum.CREEP_RARITY.CREEP_RARITY_SIEGEBOSS
            or monster.rarity == enum.CREEP_RARITY.CREEP_RARITY_THRONE then
                self:HandleShowBossBlood(obj);
                self.blood:ShowBloodType(1);
            else
                self:CloseBossBloodView()
            end
        elseif obj.object_type == enum.ACTOR_TYPE.ACTOR_TYPE_ROLE then
            self:HandleShowBossBlood(obj);
            self.blood:ShowBloodType(2);
        end
    else
        self:CloseBossBloodView()
    end
    --[[if monster and monster.object_info then
        if isLock then
            self.isLockShow = true;
            self:HandleShowBossBlood(monster.object_info);
            self.blood:ShowBloodType(1);
        else
            if self.blood and (self.blood.uid == nil or self.blood.uid == monster.object_info.uid) then
                self.isLockShow = false;
            end
        end
    else
        if not isLock then
            self.isLockShow = false;
        end
    end--]]
end

function BloodCtrl:HandleRoleBeLock(role, isLock)
    --print2("锁定角色 : " .. role.object_info.uid .. " : " .. tostring(toBool(isLock)));
	
	if PeakArenaModel:GetInstance().isOpenBattlePanel then  --巅峰1v1不显示血条
		return 
	end
    logWarn("BloodCtrl:HandleRoleBeLock" .. debug.traceback() .. tostring(isLock));
    if role and role.object_info then
        if role.object_info.uid == RoleInfoModel:GetInstance():GetMainRoleId() then
            print2("不能选中自已>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>血条输出");
            return;
        end
    end
    if role and role.object_info then
        if isLock then
            self.lock_role = role;
            self.isLockRole = true;
            self:HandleShowBossBlood(role);
            self.blood:ShowBloodType(2);
        else
            if self.blood and self.blood.uid == role.object_info.uid then
                self.isLockRole = false;
                self.lock_role = nil;
                self:CloseBossBloodView();
                self.blood:ShowBloodType(1);
            end
        end
    else
        if not isLock then
            self.isLockRole = false;
            self.lock_role = nil;
            self.blood:ShowBloodType(1);
        end
    end
end

function BloodCtrl:HandleShowBossBlood(obj)
    logWarn("BloodCtrl:HandleShowBossBlood" .. debug.traceback());
    if not self.hideByIcon then
        self.blood:SetVisibleState(BossBloodView.VisibleBitState.CloseBlood,false)
    end
    local object_info = obj.object_info
    if object_info and self.lock_role and object_info.uid ~= self.lock_role.object_info.uid then
        logError("暂不处理~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
        return;
    end

    if self.blood.is_loaded and not self.blood.is_dctored then
        if obj.object_type == enum.ACTOR_TYPE.ACTOR_TYPE_ROLE then
            self.blood:HandleEnemy(object_info);
        else
            if self.blood.uid == nil or self.blood.uid == object_info.uid then
                self.blood:UpdateShowTime(object_info);
            else
                self.blood:ChangeInfo(object_info);
            end
        end
    end
end

function BloodCtrl:CloseBossBloodView(object_info)
    -- if self.blood and self.blood.isShow then
    --     logWarn("BloodCtrl:CloseBossBloodView1" .. debug.traceback());
    --     self.blood:SetVisibleState(BossBloodView.VisibleBitState.CloseBlood,true)
    --     self.blood:ClearBlood();
    -- elseif self.blood and self.hideByIcon then
    --     logWarn("BloodCtrl:CloseBossBloodView2" .. debug.traceback());
    --     self.blood:ClearBlood();
    -- end

    if self.blood then
        self.blood:SetVisibleState(BossBloodView.VisibleBitState.CloseBlood,true)
        self.blood:ClearBlood();
    end
end

--function BloodCtrl:HandleRoleBeLock(role, flag)
--    print2("锁定角色 : " .. role.object_info.uid .. " : " .. tostring(toBool(flag)));
--    if not flag then
--        self.lock_role_uid = nil;
--        return ;
--    end
--    if role and role.object_info then
--        local main_role = SceneManager:GetInstance():GetMainRole();
--        if role.object_info.uid == main_role.object_info.uid then
--            return;
--        end
--
--        self.lock_role_uid = role.object_info.uid;
--    end
--
--end
