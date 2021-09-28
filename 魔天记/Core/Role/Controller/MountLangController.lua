--[[
  地面载具 控制器

  http://www.jb51.net/article/55152.htm   属性重载
]]

require "Core.Role.Controller.RoleController";
-- require "Core.Role.Controller.MountAttackController";
require "Core.Role.Controller.AttackController"
require "Core.Info.MountInfo";
require "Core.Role.ModelCreater.MountModelCreater"

require "Core.Role.Action.SendCmd.SendMoveToAngleAction"

MountLangController = class("MountLangController", RoleController);

function MountLangController:New(mount_id, modeInitCompleteHandler, hd_target)
    self = { };
    setmetatable(self, { __index = MountLangController });
    self.state = RoleState.STAND;
    self.roleType = ControllerType.MOUNT;
    self.modeInitCompleteHandler = modeInitCompleteHandler;
    self.hd_target = hd_target;
    self.level = 0;

    self._attrInfo = nil;
    self:_HeroAttChange()
    self.paush = false;
    self:_Init(mount_id);
    return self;
end


function MountLangController:_Init(mount_id)

   

    self.mount_config = ConfigManager.GetMount(mount_id)
    self.mount_id = tonumber(mount_id);

    self.is_battle = self.mount_config.is_battle;

    -- 测试不能进行 操作
    -- self.is_battle = false;

    -- 添加攻击管理
    -- self._attkCtrl = MountAttackController:New(self);
    self._attkCtrl = AttackController:New(self);

    -- 设置 载具 信息
    self.info = MountInfo:New(mount_id);

    self.info.mount_id = mount_id;

    --  这个 是直接用 herocontroll 的 transform
    self:_InitEntity(EntityNamePrefix.MOUNT .. self.mount_config.model_id);


    self:SetLayer(Layer.Player);
    self:_LoadModel(MountModelCreater);


end

function MountLangController:GetName()
    return self.mount_config.name;
end


function MountLangController:SetTarget(target)
    if (target == nil or(target ~= nil and target:CanSelect())) then
        self.target = target;
        if (self._playerController) then
            self._playerController:SetTarget(target)
        end
    end
end


function MountLangController:Is_end_hp()
    return self.mount_config.is_end_hp;
end

function MountLangController:GetMountId()
    if self.mount_config == nil then
        return nil;
    end

    return self.mount_config.id;
end

function MountLangController:_LoadModel(creater)

    local tg_ct = self.hd_target:GetRoleCreater();
    local parent = tg_ct._parent;

    local roleCreate = creater:New(self.info, parent, true, function(val) self:_OnLoadModelSource(val) end)
    self._roleCreater = roleCreate

    tg_ct:SetLayer(tg_ct._parent.gameObject.layer)
end



function MountLangController:_OnLoadModelSource(model)

    FixedUpdateBeat:Add(self.TryDisHandler, self);
end

function MountLangController:TryDisHandler()

    if self.modeInitCompleteHandler ~= nil then
        self.modeInitCompleteHandler(self.hd_target, self);
    end

    FixedUpdateBeat:Remove(self.TryDisHandler, self);
end


function MountLangController:_GetModern()
    return "Roles/Mounts", self.mount_config.model_id;
end


function MountLangController:Paush()

    self.paush = true;
    self:StopAction(3);

    if self._playerController ~= nil then
        self._playerController:GetRoleCreater():ResetTransformToParent();
        self:CheckShowPartSt()
    end

    self._roleCreater:SetActive(false);
end

-- 继续 载具， 是重新设置 节点
function MountLangController:ReStart()

    self._roleCreater:SetActive(true);
    self:Start(self._playerController, self.lmount_elseTime)
end


function MountLangController:Start(playerController, lmount_elseTime)
    self._playerController = playerController;
    self.paush = false;

    self.info.camp = playerController.info.camp;
    self.info.pkState = playerController.info.pkState;
    self.info.pkType = playerController.info.pkType;

    self:CheckHidePartSt();
    self._playerController:StopAction(3);

    -- 需要获取挂点 对象
    local mount_hang_point_name = self.mount_config.mount_hang_point_name;

    local myrol = self._roleCreater._role
    local myTf = myrol.transform;

    local tobjs = UIUtil.GetComponentsInChildren(myTf, "Transform");
    self._mount_hang_point = UIUtil.GetChildInComponents(tobjs, mount_hang_point_name);

    local rCreate = self._playerController:GetRoleCreater();

    local tf_role = rCreate:GetRole();

    if tf_role == nil and playerController.__cname == "PlayerController" then
        tf_role = playerController;
    end

    local tg_tf = tf_role.transform;
    UIUtil.AddChild(self._mount_hang_point, tg_tf);

    local player_process_action_name = self.info.player_process_action_name;
    local mount_process_action_name = self.info.mount_process_action_name;
    self._playerController:Play(player_process_action_name);
    -- 如果是自己， 那么 设置 在跳场景的时候， 载具不会自动 销毁
    if self._playerController.__cname == "HeroController" then
        GameObject.DontDestroyOnLoad(self.transform.gameObject);
    end

    self:Play(mount_process_action_name);

    if lmount_elseTime == nil then
        lmount_elseTime = math.floor(self.mount_config.count_down * 0.001);
    end

    self.lmount_elseTime = lmount_elseTime;
    self.selfTf = self.transform;

    -- 这里 逼不得已才这个处理， 因为 所有 的 动作 都直接 读取 transform, 而 本对象 的 transform  不是在 最顶层
    local tg_ct = self._playerController:GetRoleCreater();
    local parenl = tg_ct._parent;
    self.transform = parenl;


    self._roleCreater:SetActive(true);
    self._playerController:UpdateNamePanel()

end

function MountLangController:CheckHidePartSt()
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

function MountLangController:CheckShowPartSt()

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

function MountLangController:GetCfInfo()
    return self.mount_config;
end


function MountLangController:Stop(notSendToServer)
    if self._playerController ~= nil then
        self._playerController:GetRoleCreater():ResetTransformToParent();
        self._playerController:OutMountLang(notSendToServer);
        self:CheckShowPartSt()
    end

    self.transform = self.selfTf;
    self:Dispose();

    if self._attkCtrl ~= nil then
        self._attkCtrl:Dispose();
    end



end

function MountLangController:MoveToAngle(angle, pos)

    if self.paush then
        return;
    end

    local action = self._action;
    local cooperation = self._cooperation;
    if (action) then
        if (action.canMove) then
            if (cooperation and cooperation.__cname == "SendSkillMoveAction") then
                cooperation:SetAngle(angle);
            else
                self:DoAction(SendSkillMoveAction:New(angle));
            end
        else
            if (action.actionType ~= ActionType.BLOCK) then
                if (action.__cname == "SendMoveToAngleAction") then
                    action:SetAngle(angle);
                else
                    self:StopAction(3);
                    self:DoAction(SendMoveToAngleAction:New(angle));
                end
            end
        end
    else
        --
        self:StopAction(3);
        self:DoAction(SendMoveToAngleAction:New(angle));
    end

end

function MountLangController:PMoveToAngle(angle, pos, speed)

    if self.paush then
        return;
    end

    if (not self:IsDie()) then
        local action = self._action;
        local cooperation = self._cooperation;

        self:SetMoveSpeed(speed);

        if (action) then
            if (action.canMove) then

                if (cooperation and cooperation.__cname == "SkillMoveAction") then
                    cooperation:SetAngle(angle);
                else
                    self:DoAction(SkillMoveAction:New(angle));
                end
            else
                if (action.actionType ~= ActionType.BLOCK) then
                    if (action.__cname == "MoveToAngleAction") then
                        action:SetAngle(angle);
                    else
                        self:StopAction(3);
                        self:DoAction(MoveToAngleAction:New(angle));
                    end
                end
                -- if
            end
            -- end  if (action.canMove) then
        else
            self:StopAction(3);
            self:DoAction(MoveToAngleAction:New(angle));
        end

        self:SetPosition(pos)
    end

end

function MountLangController:Stand()

    if self.paush then
        return;
    end

    local action = self._action;
    if (action) then
        if (action.canMove) then
            self:DoAction(SendSkillStandAction:New());
        else
            if (action.actionType ~= ActionType.BLOCK) then
                self:StopAction(2);
                self:DoAction(SendStandAction:New());
            end
        end
    else
        self:StopAction(3);
        self:DoAction(SendStandAction:New());
    end
end

function MountLangController:PStand()

    if self.paush then
        return;
    end

    if (not self:IsDie()) then
        local action = self._action;
        local cooperation = self._cooperation;
        if (action) then
            if (action.canMove) then
                local standAct = StandAction:New(position, angle)
                standAct.actionType = ActionType.COOPERATION;
                self:StopAction(2);
                self:DoAction(standAct);

            else
                if (action.actionType ~= ActionType.BLOCK) then
                    self:StopAction(3);
                    self:DoAction(StandAction:New(position, angle));
                end
            end
        else
            self:StopAction(3);
            self:DoAction(StandAction:New(position, angle));
        end
    end
end

-- 普通攻击
function MountLangController:Attack(start)

    if self.paush then
        return;
    end

    if not self.is_battle then
        MsgUtils.ShowTips("MountLangController/label1");
        return;
    end

    local attkCtrl = self._attkCtrl;

    if (attkCtrl) then
        if (start) then
            attkCtrl:StartAttack();
        else
            attkCtrl:StopAttack();
        end
    end
end

function MountLangController:StopAttack()

    if self.paush then
        return;
    end

    local attkCtrl = self._attkCtrl;
    if (attkCtrl) then
        attkCtrl:StopAttack();
    end
end

-- 使用技能
function MountLangController:CastSkill(skill, autoSearch)

    if self.paush then
        return;
    end

    if (not self:IsDie() and self:_CanDoAction()) then

        if not self.is_battle then
            MsgUtils.ShowTips("MountLangController/label1");
            return;
        end

        local attkCtrl = self._attkCtrl;
        if (attkCtrl and skill) then
            attkCtrl:CastSkill(skill, autoSearch);
        end
    end
end

-- 使用技能
function MountLangController:PCastSkill(skill)

    if self.paush then
        return;
    end

    if (not self:IsDie() and skill) then

        if not self.is_battle then
            MsgUtils.ShowTips("MountLangController/label1");
            return;
        end

        self:StopAction(3);
        self:DoAction(SkillAction:New(skill));
    end
end

-- 移动，路径
function MountLangController:MoveToPath(path)

    if self.paush then
        return;
    end

    if (not self:IsDie()) then
        self:StopAction(3);
        self:DoAction(MoveToPathAction:New(path))
    end
end

function MountLangController:MoveTo(pt, map, gotoSceneNeedShowLoader)

    if self.paush then
        return;
    end

    self:DoAction(SendMoveToAction:New(pt, map, gotoSceneNeedShowLoader));
end

function MountLangController:MoveToNpc(id, map, pos)

    if self.paush then
        return;
    end

    self:DoAction(SendMoveToNpcAction:New(id, map, pos));
end


function MountLangController:GetMoveSpeed()
    return self.mount_config.speed;
end


function MountLangController:_DisposeHandler()
    self._playerController = nil;
end 

function MountLangController:Die()

    if (self._attkCtrl) then
        self._attkCtrl:StopAttack();
    end

    self.state = RoleState.DIE;

    self:Stop();

end


function MountLangController:SetAttribute(dinfo, heroInfo, monsterAtt, mount_mod_att, key)
    -- 	生命	=	A生命	+	（玩家主角生命*B生命修正值）×0.01		
    local mod_key = key .. "_mod";
    dinfo[key] = monsterAtt[key] +(heroInfo[key] * mount_mod_att[mod_key]) * 0.01;
    dinfo[key] = math.floor(dinfo[key]);

end



function MountLangController:_HeroAttChange()
    self._attrInfoChange = true;
end

-- 获取载具的 属性 值
-- 如果返回 是 nil 的话， 那么就 显示 角色属性， 不需要显示 载具属性
function MountLangController:GetAttribute()

    local att_type = self.mount_config.att_type;
    if att_type == 2 then

        local heroInfo = HeroController:GetInstance().info;
        local my_lv = heroInfo.level;

        if self.level ~= my_lv or self._attrInfoChange then
            if (self._attrInfoChange == true) then
                self._attrInfoChange = false
            end

            local att_mod_calc = self.mount_config.att_mod_calc;
            local attr_calc = self.mount_config.attr_calc;
            -- 对应的 怪物属性表
            local monsterAtt = ConfigManager.GetMonAtt(attr_calc, my_lv);

            if monsterAtt == nil then
                log(" 获取 怪物属性表 出错 ， key == " .. attr_calc .. "_" .. my_lv);
            end

            local mount_mod_att = ConfigManager.GetMountAtt(att_mod_calc);

            local attkeys = BaseAttrInfo.GetAttKeys();
            local attkeys_num = table.getn(attkeys);

            local att = { };
     
            -- 遍历所有属性
            for k = 1, attkeys_num do
                self:SetAttribute(att, heroInfo, monsterAtt, mount_mod_att, attkeys[k])
            end
       
            
            if self._attrInfo == nil then
                self._attrInfo = BaseAttrInfo:New()
                self._attrInfo:Init(att);
                self._attrInfo.hp = self._attrInfo.hp_max;
                self._attrInfo.mp = self._attrInfo.mp_max;
            end

            self._attrInfo:Init(att); 
            self.level = my_lv; 
        end

        return self._attrInfo;
    end

    return nil;
end