DramaRoleType = { player = "1", monster = "2", npc = "3" }
DramaRole = class("DramaRole", DramaAbs);
DramaRole._roles = {}

function DramaRole:_Init()
    --log(tostring(self) .. "___" .. self.__cname)
end
function DramaRole:_Begin(fixed)
    if fixed and not self:_IsDelayDetele() then return end
    local t = self.config[DramaAbs.EvenType]
    local p1 = self.config[DramaAbs.EvenParam1]
    local p2 = self.config[DramaAbs.EvenParam2]
    local roleType = p1[2]
    self.rid = p1[1]
    local sourceId = tonumber(string.split(self.rid, '_')[1])
    --Warning("DramaRole.Begin: t=" .. tostring(t) .. ",rid=" .. tostring(self.rid)..",ptype=" .. tostring(roleType))
    self.role = DramaRole.GetDramaRole(self.rid, roleType, self._hero)
    if not self.role then
        self.role = self:CreateDramaRole(sourceId, roleType)
        DramaRole._roles[self.rid] = self
    end
    --if roleType == DramaRoleType.player then Warning(tostring(self.rid) .. "____" .. tostring(self.role)) end
    if t == DramaEventType.RoleShow then
        if table.concat(p2,nil,1,4) ~= "" then
            self.role:SetPosition(Convert.PointFromConfig(p2[1], p2[2], p2[3]), p2[4])
        end
        if #p2 > 4 and p2[5] ~= '' then
            local t = self.role:Play(p2[5], true)
            if t and t > 0 then
                self.showEndTime = nil
                self.showEndTime = DramaDirector.GetTimer(t, 1,function ()
                    self.showEndTime = nil
                    self.role:PlayDefualt()
                end)
            end
        else self.role:PlayDefualt() end
    else
        if t == DramaEventType.RolePath then
            local useMapHeight = #p2 > 1 and p2[2] == '1' or false
            self._path = PathAction:New():InitPath(self.role.transform, p2[1],function()
                self.role:PlayDefualt()
            end, nil, useMapHeight)
            self._path:Play()
            if #p2 > 2 then self.role:Play(p2[3]) end
            if fixed then 
                self._path:SetGrogress(10000)
            end
        elseif t == DramaEventType.RoleMove then
            self.role:MoveTo(Convert.PointFromConfig(p2[1], p2[2], p2[3]))
            --self.role:Play(#p2 > 3 and p2[4] or RoleActionName.run)
            if #p2 > 2 then self.role:Play(p2[3]) end
        elseif t == DramaEventType.RoleAction then
            self.role:Play(p2[1])
        end
    end
    self:_DelayDetele(self.role)
end
function DramaRole:CreateDramaRole(sourceId, roleType)
    local r = nil
    if roleType == DramaRoleType.player then
        if not DramaTimer.CLONE_HERO then
            r = self._hero
        else
            r = ConfigManager.Clone(self._hero)
            local go = Resourcer.Clone(self._hero.gameObject)
            --默认为角色当前位置
            local trf = self._hero.transform
            local trf2 = go.transform
           
		    trf2.position = trf.position
		    trf2.rotation = trf.rotation
            --重新指向显示对象
	        r.entity = go
	        r.gameObject = go
	        r.transform = go.transform
            go:SetActive(true)
            local rm = r._roleCreater
            rm._roleAvtar = UIUtil.GetComponentsInChildren( go,"Avtar")[0]
            rm._role = rm._roleAvtar.gameObject
            rm._roleAnimator = rm._role:GetComponent("Animator")
            if rm.checkAnimation then rm:_InitAnimation() end
            --防止删除主角引用
            r.namePanel = nil
            rm._render = nil
            rm._rightWeapon = nil 
            rm._leftWeapon = nil 
            rm._trump = nil 
            rm._rideCreater = nil 
            rm._shadow = nil 
        end
    else
        if roleType == DramaRoleType.monster then
            r = self:_AddMonster(sourceId)
        elseif roleType == DramaRoleType.npc then
            r = self:_AddNpc(sourceId)
        end
        r.gameObject.layer = Layer.Default
        NGUITools.SetChildLayer(r.transform, Layer.Default)
    end
    self.isRoleCreater = true
    r.IsDramaRole = true
    return r
end

function DramaRole.GetDramaRole(rid, roleType , hero)
    local r = nil
    --Warning("GetDramaRole____"  .. tostring(rid).. tostring(DramaRole._roles[rid]))
    --if roleType == DramaRoleType.player then r = hero
    --else
        local dr = DramaRole._roles[rid]
        if dr then r = dr.role end
    --end
    return r 
end

function DramaRole:_Dispose()
    if self._path then self._path:Clear() end
    if self.isRoleCreater and self.role then 
        if not self.isDelayDetele then
            --Warning(tostring(self.role.__cname))
            if self.role.__cname ~= 'HeroController' then 
                self.role:Dispose()
            else
                Resourcer.Recycle(self.role.gameObject, false)
            end
        end
        RemoveTableItem( DramaRole._roles, self)
        self.role = nil
    end
    if self.showEndTime then self.showEndTime:Stop() end
    self.showEndTime = nil
end

function DramaRole:_AddNpc(id)
    local npcCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_NPC);
    for i, v in pairs(npcCfg) do
        if (v.id == id) then
            --self.role = NpcModelCreater:New(self:_GetNpcData(pid), self._hero.transform.root, false)
            local npc = NpcController:New(v.id, false);
            npc:CheckLoadModel()
            npc.info.move_spd = 0.1
            --RoleNamePanel:New(npc):SetCheckRoleVisible(true)
            return npc
        end
    end
end
function DramaRole:_AddMonster(id)
    local monsterCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_MONSTER);
    --log("DramaRole:_AddMonster(id)=" .. id)
    for i, v in pairs(monsterCfg) do
        if (v.id == id) then
            local info = MonsterInfo:New(v.id);
            local role = nil
            if v.type  == MonsterInfoType.FIGHT_NPC then 
                role = HeroGuardController:New(info)
            else
                role = PerformanMonsterController:New(info);
            end            
            --RoleNamePanel:New(role):SetCheckRoleVisible(true)
            return role
        end
    end
end