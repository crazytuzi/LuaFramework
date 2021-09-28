require "Core.Role.AI.AbsAiController";

local AutoFightPathCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_AUTO_FIGHT_PATH);
local WAITTONEXTTIME = 2;
local DELAYTIME = 0.2;

AutoFightAiController = class("AutoFightAiController", AbsAiController)



function AutoFightAiController:New(role)
    self = { };
    setmetatable(self, { __index = AutoFightAiController });
    self:_Init(role);
    self._orgPoint = role.transform.position;
    self._attackAllArea = true;
    self._currTime = 0;
    self._resumeWait = 0;
    self._startTime = 0
    self._blToNext = false;
    self._step = 1;
    self._canPK = false;
    self._waitToNextTime = WAITTONEXTTIME;
    self._isAutoMoving = false;
    self.isAutoFight = false
    self.isAutoKill = false
    self.isPause = false;
    self._defSkill = nil;
    self:_InitListener();
    self:_InitPath();
    return self;
end

--[[设置 角色控制器
]]
function AutoFightAiController:SetRole(role)
    if (self._role) then
        self._role:StopAttack();
    end
    self._role = role;
    self._skill = nil;
    self._defSkill = nil;
end

function AutoFightAiController:SetDefaultSkill(skill)
    self._defSkill = skill;
    if (self._defSkill) then
        if (not self.isPause and self._resumeWait < 0) then
            self:_OnTickHandler();
        end
    else
        self._role:StopAttack();
        if (self._defSkill == self._skill) then
            self._skill = nil;
        end
    end
end

local auto_set_cf = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_AUTO_SET);
local auto_set_cf_type_1 = 1;
local auto_set_cf_type_2 = 2;
local _sortfunc = table.sort

function AutoFightAiController.GetSpidTypeInAutoSet(curr_spid)
    curr_spid = tonumber(curr_spid);
    for key, value in pairs(auto_set_cf) do
        if value.id == curr_spid then
            return value.name;
        end
    end
    return nil;
end

function AutoFightAiController.GetListByNameInAutoSet(name, req_lev)
    name = tonumber(name);
    req_lev = tonumber(req_lev);

    local res = { };
    for key, value in pairs(auto_set_cf) do
        if value.name == name and value.req_lev <= req_lev then
            table.insert(res, value);
        end
    end

    ---  需要进行排序
    _sortfunc(res, function(a, b)
        return a.order < b.order
    end )

    return res;

end

function AutoFightAiController.GetCanBuySetCfPro(curr_spid)

    local me = HeroController:GetInstance();
    local heroInfo = me.info;
    local my_lv = heroInfo.level;

    local type = AutoFightAiController.GetSpidTypeInAutoSet(curr_spid);
    local canBuyList = AutoFightAiController.GetListByNameInAutoSet(type, my_lv);

    return canBuyList[1];

end

function AutoFightAiController.TryShowuse_DrugBuy(key, needCheckMomey)

    local autoSetcf = AutoFightAiController.GetCanBuySetCfPro(AutoFightManager[key]);
    local spid = autoSetcf.id;

    local num = 99;

    if needCheckMomey then
        -- 当需要检测 是否够钱购买的时候， 如果不够钱， 那么不
        local price = autoSetcf.price or 1;
        local needTotal = price * num;
        local my_money = MoneyDataManager.Get_money();
        if my_money < needTotal then
            -- 不够钱，不处理
            return;
        end
    end


    AutoFightAiController.setAndSavePro = function(spid, am)
        AutoFightManager[key] = spid;
        AutoFightManager.Save();
    end
    ModuleManager.SendNotification(ConvenientUseNotes.SHOW_CONVENIENTBUYPANEL, { shop_id = ShopDataManager.shtop_ids.SUISHENG, spid = spid, num = num, doFun = AutoFightAiController.setAndSavePro });
end

function AutoFightAiController:StartAutoFight()
    self._defSkill = nil;
    if (self._timer == nil) then
        self._timer = Timer.New( function(val) self:_OnTickHandler(val) end, DELAYTIME, -1, false);
        self._timer:Start();
    end



    if AutoFightManager.use_Drug_HP_id == nil or AutoFightManager.use_Drug_MP_id == nil then

        if (GameSceneManager and GameSceneManager.map) then
            if (GameSceneManager.map.info.type ~= InstanceDataManager.MapType.Novice) then

                MsgUtils.ShowTips(nil, nil, nil, LanguageMgr.Get("figth/autoFight/notRestore"));
            end
        end

    else
        local pb_hp_item = BackpackDataManager.GetProductBySpid(AutoFightManager.use_Drug_HP_id);
        local pb_mp_item = BackpackDataManager.GetProductBySpid(AutoFightManager.use_Drug_MP_id);
        if (pb_hp_item == nil or pb_mp_item == nil) then
            MsgUtils.ShowTips(nil, nil, nil, LanguageMgr.Get("figth/autoFight/notDrug"));
            if (pb_hp_item == nil) then

                AutoFightAiController.TryShowuse_DrugBuy("use_Drug_HP_id");
              
            elseif (pb_mp_item == nil) then
               
                AutoFightAiController.TryShowuse_DrugBuy("use_Drug_MP_id");


            end
        end
    end
    self._step = 1
    self.isAutoFight = true;
    self.isPause = false;
    self._isAutoMoving = false;
    self._resumeWait = 0;
    self._waitToNextTime = WAITTONEXTTIME;
end

function AutoFightAiController:StopAutoFight()
    self._defSkill = nil;
    if (self.isAutoFight) then
        self.isAutoFight = false;
        if (self._role) then
            self._role:StopAttack();
            self._role:StopAction(3);
            self._role:Stand()
        end
        if (self.isAutoKill == false) then
            self:Stop()
        end
    end
end

function AutoFightAiController:StartAutoKill(id)
    self._defSkill = nil;
    if (self._timer == nil) then
        self._timer = Timer.New( function(val) self:_OnTickHandler(val) end, DELAYTIME, -1, false);
        self._timer:Start();
    end
    self._role:SetTarget(nil);
    self.isAutoKill = true;
    self.isPause = false;
    self._isAutoMoving = false;
    self._resumeWait = 0;
    self._waitToNextTime = WAITTONEXTTIME;
    self._killTarget = id
end

function AutoFightAiController:StopAutoKill()
    self._defSkill = nil;
    if (self.isAutoKill) then
        self.isAutoKill = false;
        self._killTarget = nil;
        if (self._role) then
            self._role:StopAttack();
            self._role:StopAction(3);
            self._role:Stand()
        end
        if (self.isAutoFight == false) then
            self:Stop()
        end
    end
end

-- 暂停
function AutoFightAiController:Pause()
    self._role:StopAttack()
    self.isPause = true;
    self._isAutoMoving = false;
    self._blToNext = false;
end

function AutoFightAiController:Resume()
    self._orgPoint = self._role.transform.position;
    self.isPause = false;
    self._resumeWait = 2;
    self._startTime = os.time()
end

function AutoFightAiController:IsResumeTime()
    if (self._resumeWait and self._resumeWait > 0) then
        return true
    end
    return false;
end

function AutoFightAiController:Stop()

    local role = self._role;
    self._defSkill = nil;
    self._skill = nil
    self.setAndSavePro = nil;
    self.isPause = false;
    self.isAutoFight = false;
    if (self._timer) then
        self._timer:Stop();
        self._timer = nil;
    end
    if (role) then
        role:StopAttack();
    end
end

function AutoFightAiController:_InitListener()
    MessageManager.AddListener(GameSceneManager, GameSceneManager.MESSAGE_SCENE_START, self._SceneStartHandler, self);
   
end

function AutoFightAiController:_DisposeListener()
    MessageManager.RemoveListener(GameSceneManager, GameSceneManager.MESSAGE_SCENE_START, self._SceneStartHandler, self);
   
    self.setAndSavePro = nil;
end

function AutoFightAiController:_DisposeHandler()
    self:_DisposeListener();
end

function AutoFightAiController:_SceneStartHandler()
    self:_InitPath();
end




function AutoFightAiController:_InitPath()
    local path = { };
    local id = GameSceneManager.id;
    local i = 1;
    local item = AutoFightPathCfg[id .. "_" .. i];
    while item do
        path[i] = item;
        i = i + 1;
        item = AutoFightPathCfg[id .. "_" .. i];
    end
    if (#path > 0) then
        self._path = path
    else
        self._path = nil;
    end
    self._waitToNextTime = 0;
end

function AutoFightAiController:_GetReplaceSkill(skill)
    -- local role = self._role;
    -- if (role and role.info and skill) then
    --     local refSkill = SkillManager.RefSkillId(skill.id);
    --     if (refSkill ~= skill.id) then
    --         return role.info:GetSkill(refSkill)
    --     end
    -- end
    return skill
end

function AutoFightAiController:_GetSkill()
    local role = self._role;
    if (role) then
        if (self._defSkill) then
            local currSkill = self:_GetReplaceSkill(self._defSkill)
            if (not currSkill:IsCooling() and role.info.mp >= currSkill.mp_cost) then
                return currSkill
            end
            return nil;
        else
            local info = role.info;
            local skills = info:GetSkills()
            for i = 1, 6 do
                local v = self:_GetReplaceSkill(skills[i]);
                if (v and(not v:IsCooling()) and info.mp >= v.mp_cost and ((info.level >= v.req_lv) or v.skill_lv >1)) then
                    if (v.dmg_type == 3) then
                        local tRole = GameSceneManager.map:GetSameTeamLowHPRole(role.info.camp, role.transform.position, 20)
                        local hpR = info.hp / info.hp_max;
                        local thpR = 1;
                        if (tRole ~= nil) then
                            thpR = tRole.info.hp / tRole.info.hp_max;
                        end
                        if (hpR < 0.8 or thpR < 0.8) then
                            return v;
                        end
                    else
                        return v;
                    end
                end
            end
            local tSkill = info:GetTrumpSkill();
            if (tSkill and(not tSkill:IsCooling()) and info.mp >= tSkill.mp_cost) then
                return tSkill;
            end
            return self:_GetReplaceSkill(info:GetBaseSkill());
        end
    end
    return nil;
end

function AutoFightAiController:_GetTargetBySkill(skill)

    local role = self._role;
    local target = role.target;
    local pkType = role.info.pkType;
    local seriesSkill = skill:GetSeriesSkill();
    if (target and target:CanSelect() == false) then
        target = nil
    end
    if (seriesSkill) then

        local skDistance = 10;
        -- seriesSkill.max_distance / 100;
        local mapInfo = GameSceneManager.map.info
        local maxDistance = skDistance;
        local pt = self._orgPoint;
        if (self._attackAllArea == true) then
            maxDistance = 20;
            pt = role.transform.position
        end
        if (seriesSkill.target_type == 1) then
            target = role;
        elseif (seriesSkill.target_type == 2) then
            -- target = role;
            target = GameSceneManager.map:GetSameTeamLowHPRole(role.info.camp, pt, maxDistance)
            if (target == nil) then
                target = role;
            else
                local sHPR = role.info.hp / role.info.hp_max;
                local tHPR = target.info.hp / target.info.hp_max;
                if (sHPR < tHPR) then
                    target = role;
                end
            end
        elseif (seriesSkill.target_type == 3 or seriesSkill.target_type == 4) then
            local blSearch = false;

            if (self._killTarget ~= nil) then
                if (target == nil) then
                    blSearch = true
                else
                    if (target.info.camp == role.info.camp or target.info.kind ~= self._killTarget or target:IsDie()) then
                        blSearch = true
                    end
                end

                if (blSearch) then
                    target = GameSceneManager.map:GetCanAttackTargetById(self._killTarget, role.info.camp, pt, maxDistance);
                    if (target ~= nil) then
                        return target;
                    end
                end
            end
            blSearch = false

            if (target == nil or(target and(target:IsDie() or target.info == nil))) then
                -- 目标为空，从找目标
                blSearch = true;
            else
                if (target == role) then
                    -- 目标为自身，从找目标
                    blSearch = true;
                else
                    if (target.info.camp == 0 or target.state == RoleState.RETREAT or Vector3.Distance2(pt, target.transform.position) > maxDistance) then
                        -- 中立、返回出生点、超出技能最大距离，从找目标
                        blSearch = true;
                    else
                        if (target.info.camp == role.info.camp) then
                            if (mapInfo.is_pk and target.roleType == ControllerType.PLAYER and target.info.level > 20) then
                                if (PartData.IsMyTeammate(target.id) or GuildDataManager.IsSameGuild(role.info.tgn, target.info.tgn)) then
                                    -- 目标为队友，从找目标
                                    blSearch = true;
                                else
                                    if (pkType == 0) then
                                        if (target.info.camp == role.info.camp) then
                                            blSearch = true;
                                        end
                                    elseif (pkType == 1) then
                                        if (target.info.pkState == 0) then
                                            blSearch = true;
                                        end
                                    elseif (pkType == 2) then
                                        if ((target.info.pkType == 0 and target.info.pkState == 0) or(target.info.pkType == 1 and target.info.pkState == 0)) then
                                            blSearch = true;
                                        end
                                    end
                                end
                            else
                                blSearch = true;
                            end
                        end
                    end
                end
            end
            if (blSearch) then
                target = GameSceneManager.map:GetCanAttackTarget(role.info.camp, pt, maxDistance, pkType, role.info.tgn, 2, false, false);
            end
        end
    end
    return target;
end

function AutoFightAiController:_OnTickHandler()
    -- Time.fixedDeltaTime;
    -- if (self._resumeWait > 0) then
    if self._resumeWait >(os.time() - self._startTime) then
        -- self._resumeWait = self._resumeWait - Timer.deltaTime;
        return
    end
    if (GameSceneManager.map == nil) then return end
    if (not self.isPause and(self.isAutoFight or self.isAutoKill)) then
        self:_OnTimerHandler();
    end
end

function AutoFightAiController:_OnTimerHandler()
    local role = self._role;
    if (role and role.transform) then
        if (not role:IsDie()) then
            local action = role:GetAction();
            local target = role.target
            -- if (action == nil or(action and action.actionType ~= ActionType.BLOCK)) then
            self._waitToNextTime = self._waitToNextTime + DELAYTIME;

            if (self._defSkill ~= nil) then
                if (role.info:GetSkill(self._defSkill.id) == nil) then
                    self._defSkill = nil
                else
                    if ((not self._defSkill:IsCooling()) and self._defSkill.mp_cost < role.info.mp) then
                        self._skill = self._defSkill
                    else
                        if (self._skill == self._defSkill) then
                            self._skill = nil;
                        end
                        self._defSkill = nil;
                    end
                end
            else

                if (self._skill == nil or self._skill == role.info:GetBaseSkill() or self._skill:IsCooling() or self._skill.mp_cost > role.info.mp or role.info:GetSkill(self._skill.id) == nil) then
                    self._skill = self:_GetSkill();
                end
            end
            if (self._skill ~= nil) then
                target = self:_GetTargetBySkill(self._skill);


                if (role.target ~= target) then
                    role:SetTarget(target);
                    if (target == nil) then
                        role:SetTarget(nil)
                    end
                end
                if (target ~= nil) then
                    if (target.isAppear ~= true) then
                        role:CastSkill(self._skill, false);
                    else
                        role:StopAttack();
                        if (action == nil or(action and action.actionType ~= ActionType.BLOCK)) then
                            if (role.state ~= RoleState.STAND) then
                                role:Stand();
                            end
                            role:LockTarget(target);
                        end
                    end
                    self._waitToNextTime = 0
                    self._isAutoMoving = false;
                else
                    if (self._defSkill and self._skill == self._defSkill) then
                        role:CastSkill(self._skill, false);
                        self._waitToNextTime = WAITTONEXTTIME
                        self._isAutoMoving = false;
                    else
                        self._skill = nil;
                        role:StopAttack();
                        if (self._waitToNextTime >= WAITTONEXTTIME and self._path) then
                            self:_OnMoveHandler()
                        end
                    end
                end
            else
                role:StopAttack();
            end
        else
            self._step = 1;
            self._resumeWait = 1;
            self._startTime = os.time()
        end
    else
        self._waitToNextTime = WAITTONEXTTIME
        self._blToNext = false;
    end
end

function AutoFightAiController:_OnMoveHandler()
    local role = self._role;
    if (role and role.transform and(not role:IsDie())) then
        local action = role:GetAction();
        if (action == nil or(action and action.actionType ~= ActionType.BLOCK)) then
            local speed =(role:GetMoveSpeed() / 100) * FPSScale * 1.5;
            if (not self._isAutoMoving) then
                self._currPoint = self:_GetNearPoint();
                if (self._currPoint) then
                    local pathStr = GameSceneManager.mpaTerrain:FindPath(role.transform.position, self._currPoint);
                    -- Warning(">>>>>>>> 1 " .. pathStr)
                    if (pathStr and pathStr ~= "") then
                        local path = string.splitToNum(pathStr, ",");
                        role:MoveToPath(path);
                        self._isAutoMoving = true;
                    else
                        self._step = self._step * -1;
                        self._currPoint = self:_GetNextPoint(1);
                        -- Warning(">>>>>>>> 1 -1" .. pathStr)
                    end
                end
            else
                if (self._currPoint) then
                    local d = Vector3.Distance2(self._currPoint, role.transform.position)
                    -- Warning(">>>>>>>>> "..d);
                    if (d < speed) then
                        self._currPoint = self:_GetNextPoint();
                        if (self._currPoint) then
                            local pathStr = GameSceneManager.mpaTerrain:FindPath(role.transform.position, self._currPoint);
                            -- Warning(">>>>>>>> 2 " .. pathStr)
                            if (pathStr and pathStr ~= "") then
                                local path = string.splitToNum(pathStr, ",");
                                role:MoveToPath(path);
                            else
                                self._step = self._step * -1;
                                self._currPoint = self:_GetNextPoint(1);
                                if (self._currPoint) then
                                    local pathStr = GameSceneManager.mpaTerrain:FindPath(role.transform.position, self._currPoint);
                                    if (pathStr and pathStr ~= "") then
                                        local path = string.splitToNum(pathStr, ",");
                                        role:MoveToPath(path);
                                        -- Warning(">>>>>>>> 2 -1" .. pathStr)
                                    end
                                end
                            end
                        end
                    else
                        if (role.state ~= RoleState.MOVE) then
                            local pathStr = GameSceneManager.mpaTerrain:FindPath(role.transform.position, self._currPoint);
                            if (pathStr and pathStr ~= "") then
                                local path = string.splitToNum(pathStr, ",");
                                role:MoveToPath(path);
                                -- Warning(">>>>>>>> 2 -1" .. pathStr)
                            end
                        end
                    end
                else
                    if (action == nil or(action and action.actionType ~= ActionType.BLOCK and action.__cname ~= "SendMoveToPathAction")) then
                        self._isAutoMoving = false;
                        -- Warning(">>>>>>>> 3 ")
                    end
                end
            end
        end
    end
end

function AutoFightAiController:_GetNextPoint()
    if (self._path) then
        local si = 0;
        if (stepIndex) then
            si = stepIndex;
        end
        local currIndex = self._pathIndex
        local item = self._path[currIndex + self._step];
        if (item == nil) then
            self._step = self._step * -1
            item = self._path[currIndex + self._step];
            if (item == nil) then
                return nil;
            end
        end
        self._pathIndex = currIndex + self._step + si
        return Vector3.New(item.pos_x / 100, item.pos_y / 100, item.pos_z / 100);
    end
    return nil;
end

function AutoFightAiController:_GetNearPoint()
    if (self._path) then
        local role = self._role;
        local len = #self._path;
        local currIndex = self:_GetNearIndex()
        local item = self._path[currIndex];
        local pt = Vector3.New(item.pos_x / 100, item.pos_y / 100, item.pos_z / 100);
        self._pathIndex = currIndex;
        if (role and role.transform and len > 1) then
            local rolePt = role.transform.position;
            if ((currIndex > 1 and currIndex < len) or(currIndex == 1 and self._step > 0) or(currIndex == len and self._step < 0)) then
                local nitem = self._path[currIndex + self._step];
                local npt = Vector3.New(nitem.pos_x / 100, nitem.pos_y / 100, nitem.pos_z / 100);
                local pr = math.atan2(npt.x - pt.x, npt.z - pt.z);
                local rr = math.atan2(npt.x - rolePt.x, npt.z - rolePt.z);
                if (math.abs(pr - rr) < 0.1) then
                    self._pathIndex = currIndex + self._step;
                    return npt
                end
            end
        end
        return pt;
    end
    return nil;
end

function AutoFightAiController:_GetNearIndex()
    local index = 0;
    if (self._path) then
        local max = 999999999;
        local role = self._role;
        if (role and role.transform) then
            local rolePt = role.transform.position;
            for i, v in ipairs(self._path) do
                local pt = Vector3.New(v.pos_x / 100, v.pos_y / 100, v.pos_z / 100);
                local d = Vector3.Distance2(rolePt, pt);
                if (d < max) then
                    index = i;
                    max = d;
                end
            end
        end
    end
    return index;
end

function AutoFightAiController:_CheckInToArea()
    local role = self._role;
    if (role and role.transform and self._toNextPoint) then
        return Vector3.Distance2(role.transform.position, self._toNextPoint) < 2;
    end
    return false
end
