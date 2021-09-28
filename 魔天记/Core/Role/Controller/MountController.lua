--[[
  载具 控制器  飞行载具
]]

require "Core.Role.Controller.RoleController";
require "Core.Info.MonsterInfo";
require "Core.Role.ModelCreater.MountModelCreater"


MountController = class("MountController", RoleController);

function MountController:New(data, modeInitCompleteHandler, hd_target)
    self = { };
    setmetatable(self, { __index = MountController });
    self.state = RoleState.STAND;
    self.roleType = ControllerType.MOUNT;
    self.modeInitCompleteHandler = modeInitCompleteHandler;
    self.hd_target = hd_target;
    self:_Init(data);
    return self;
end


function MountController:_Init(data)
    self.id = data.id;

    -- 路径对象
    self.info = data;

    self:_InitEntity(EntityNamePrefix.MOUNT .. self.info.model_id);
    self:SetLayer(Layer.Player);
    self:_LoadModel(MountModelCreater);

end

function MountController:GetName()
    return self.info.name;
end

function MountController:_LoadModel(creater)

    local tg_ct = self.hd_target:GetRoleCreater();
    local parenl = tg_ct._parent;

    local roleCreate = creater:New(self.info, parenl, true, function(val) self:_OnLoadModelSource(val) end)
    self._roleCreater = roleCreate

    tg_ct:SetLayer(tg_ct._parent.gameObject.layer);
    Warning(" MountController:_LoadModel    -->  " .. tostring(self._roleCreater));

    if self._roleCreater == nil then

        Error(" MountController:_LoadModel    -->  self._roleCreater == nil  ");

    end

    -- self.gameObject:SetActive(false);
    -- self._roleCreater:SetActive(false)
    self.loadingMode = true;
    self:SetVisible(false)
end

function MountController:_OnLoadModelSource(model)

    FixedUpdateBeat:Add(self.TryDisHandler, self);

end

function MountController:TryDisHandler()

    self.loadingMode = false;
    if self.modeInitCompleteHandler ~= nil and self.hd_target ~= nil then
        self.modeInitCompleteHandler(self.hd_target, self);
    end

    FixedUpdateBeat:Remove(self.TryDisHandler, self);

end


function MountController:_GetModern()


    return "Roles/Mounts", self.info.model_id;
end

function MountController:Is_end_hp()
    return self.info.is_end_hp;
end

function MountController:GetMountId()
    if self.info == nil then
        return nil;
    end
    return self.info.id;
end

function MountController:Start(playerController)

    self._playerController = playerController;

    self:CheckHidePartSt()

    -- 需要获取挂点 对象
    local mount_hang_point_name = self.info.mount_hang_point_name;
    -- Warning(" MountController:Start    -->  ");
    --[[
    if self._roleCreater == nil then
     return;
    end
    ]]
    local myrol = self._roleCreater._role
    local myTf = myrol.transform;

    local tobjs = UIUtil.GetComponentsInChildren(myTf, "Transform");
    self._mount_hang_point = UIUtil.GetChildInComponents(tobjs, mount_hang_point_name);

    local creater = self._playerController:GetRoleCreater();

    if creater == nil then
        -- 延时处理
        UpdateBeat:Add(MountController.TryStartAgain, self)
        return;
    end

    -- local role = self._playerController;
    -- 必须用这个， 不然 设置不了挂点
    local role = creater:GetRole();

    if role ~= nil then
        local tg_tf = role.transform;

        UIUtil.AddChild(self._mount_hang_point, tg_tf);


        local player_process_action_name = self.info.player_process_action_name;
        local mount_process_action_name = self.info.mount_process_action_name;

        self._playerController:Play(player_process_action_name);

        -- 如果是自己， 那么 设置 在跳场景的时候， 载具不会自动 销毁
        if self._playerController.__cname == "HeroController" then
            GameObject.DontDestroyOnLoad(self.transform.gameObject);
        end

        self:Play(mount_process_action_name);

        self.moving = false;

        self.selfTf = self.transform;
        local parenl = creater._parent;
        self.transform = parenl;

        -- self.gameObject:SetActive(true);
        -- self._roleCreater:SetActive(true)
        self:SetVisible(true)
    else
        -- 没有找到对象， 移除载具
        log("---------------------没有找到对象， 移除载具-------------------");
        self:Stop();
    end



end


function MountController:TryStartAgain()
    UpdateBeat:Remove(MountController.TryStartAgain, self);
    self:Start(self._playerController);
end

function MountController:CheckHidePartSt()
    local cf = self:GetCfInfo()

    if cf.is_hide_body then
        self._playerController:HideBody();
    end

    if cf.is_hide_weapon then
        self._playerController:HideWeapon();
    end

    if cf.is_hide_wing then
        self._playerController:HideWing();
    end

    if cf.is_hide_pet then
        self._playerController:HidePet();
    end

    if cf.is_hide_golem then
        self._playerController:HidePuppet();
    end

    if cf.is_hide_fabao then
        self._playerController:HideTrump();
    end

    if cf.is_hide_ride then
        self._playerController:HideRide();
    end


end

function MountController:CheckShowPartSt()

    local cf = self:GetCfInfo()

    if cf.is_hide_body then
        self._playerController:ShowBody();
    end

    if cf.is_hide_weapon then
        self._playerController:ShowWeapon();
    end

    if cf.is_hide_wing then
        self._playerController:ShowWing();
    end

    if cf.is_hide_pet then
        self._playerController:ShowPet();
    end

    if cf.is_hide_golem then
        self._playerController:ShowPuppet();
    end

    if cf.is_hide_fabao then
        self._playerController:ShowTrump();
    end

    if cf.is_hide_ride then
        self._playerController:ShowRide();
    end

end



function MountController:GetCfInfo()
    return self.info;
end


--[[

  path_id  路线 id 在配置表  move_path_prefab.lua
    per           飞行载具 进度， 一般可以不填 或者 为  0
]]
function MountController:MoveToTarget(path_id, per, isSelf)

    self.moving = true;

    self.movePathCf = ConfigManager.GetMovePath(path_id);

    self.moving = true;


    self:StopAction(3);

    local lineDir = "MountPath/";

    if isSelf then
        -- 只有自己才有 摄像机 录像

        -- 自己坐载具

        --- 使用 编辑路径
        local camerCt = MainCameraController:GetInstance();

        self.mount_action = camerCt:TraceRolePath(lineDir .. self.movePathCf.camer_path, lineDir .. self.movePathCf.line_path, function()
            self:MountMoveComplete()
            self:Stop();

        end , self, self.transform)

        camerCt:PlayPath();

        self.mount_action:SetGrogress(per);

        self.currTime = 30;

        self:TrySendLineMovePreInfo()

        UpdateBeat:Remove(self.UpTime, self)
        UpdateBeat:Add(self.UpTime, self)


    else

        -- 别人

        self.mount_action = PathAction:New();
        self.mount_action:InitPath(self.transform, lineDir .. self.movePathCf.line_path, function()

            self:MountMoveComplete()
            self:Stop();

        end , nil);

        self:DoAction(action);

        self.mount_action:SetGrogress(per);

    end


    -- 充点小钱
end

function MountController:MountMoveComplete()

    if (self._playerController.__cname == "HeroController") then

        SequenceManager.TriggerEvent(SequenceEventType.Base.VEHICLE_FLY_COMPLETE, self.movePathCf.id);
    end

end

function MountController:UpTime()

    if self.currTime > 0 then
        self.currTime = self.currTime - 1;
        if self.currTime == 0 then

            self:TrySendLineMovePreInfo()
            self.currTime = 20;
        end

    end

end

--[[
        1B 轨迹移动数据
输入：
x
y
z
rid：路线id
per：进度0-10000

输出：


        ]]
function MountController:TrySendLineMovePreInfo()

    if self.mount_action ~= nil then

        local pos = self.mount_action:GetPos();
        self.pre = self.mount_action:GetGrogress();


        local s_x = math.floor(pos.x * 100);
        local s_y = math.floor(pos.y * 100);
        local s_z = math.floor(pos.z * 100);


        SocketClientLua.Get_ins():SendMessage(CmdType.SendLineMovePre, { x = s_x, y = s_y, z = s_z, rid = self.movePathCf.id .. "", per = self.pre });
    end

end

-- 尝试发送 出身点
function MountController:TrySendMapBronPointInfo()


    local mapcf = ConfigManager.GetMapById(GameSceneManager.id)
    local pos = Convert.PointFromServer(mapcf.born_x, mapcf.born_y, mapcf.born_z);

    if self._playerController ~= nil then

        local trf = self._playerController.transform;

        MapTerrain.SampleTerrainPositionAndSetPos(trf, pos);

    end

    -- SocketClientLua.Get_ins():SendMessage(CmdType.SendLineMovePre, { x = math.floor(pos.x * 100), y = math.floor(pos.x * 100), z = math.floor(pos.x * 100), rid = self.movePathCf.id .. "", per = self.pre });
end

function MountController:Stop(notNeedSendToServer)

    if self.moving then
        self.mount_action:Clear();
        self.mount_action = nil;

    end

    if self._playerController ~= nil then

        self._playerController:GetRoleCreater():ResetTransformToParent();

        self._playerController:OutMount(notNeedSendToServer);
        self:CheckShowPartSt();
    end

    UpdateBeat:Remove(self.UpTime, self)

    self.transform = self.selfTf;
    self:Dispose();

    self.moving = false;

    if self._playerController ~= nil then
        self._playerController:OutMountComplete();
    end
end

function MountController:Die()



    self:Stop();

end

function MountController:Dispose()

    FixedUpdateBeat:Remove(self.TryDisHandler, self);
    UpdateBeat:Remove(self.UpTime, self)
    UpdateBeat:Remove(MountController.TryStartAgain, self);
    self.hd_target = nil;
    self.modeInitCompleteHandler = nil;

    if (self.transform) then
        self:StopAction(3)
        self._dispose = true
        self.visible = false
        --    if (self._shadow) then
        --        Resourcer.Recycle(self._shadow)
        --        self._shadow = nil
        --    end
        self:ClearSkillEffect();
        if (self._disappearTimer) then
            self._disappearTimer:Stop();
            self._disappearTimer = nil;
        end
        if (self._pauseFrameTimer) then
            self._pauseFrameTimer:Stop();
            self._pauseFrameTimer = nil;
        end
        if (self._buffCtrl) then
            self._buffCtrl:RemoveAll()
            self._buffCtrl = nil;
        end
        self:_DisposeNamePanel()

        self:_DisposeHandler();

        Warning(" MountController:Dispose    -->  ");
        if (self.transform) then
            if (self._roleCreater) then
                self._roleCreater:Dispose()
                self._roleCreater = nil
            end
            Resourcer.Recycle(self.gameObject, false)

        end
        self.transform = nil;
        self.state = RoleState.DIE;
    end
end