CreateRoleModel = CreateRoleModel or BaseClass(BaseModel)

function CreateRoleModel:__init()
    self.create_role_win = nil

    self.create_role_visable = false

    self.maleEffectList = nil --男动作特效配置列表
    self.femaleEffectList = nil--男动作特效配置列表
    self:init_effect_list()
end

function CreateRoleModel:__delete()
    if self.create_role_win ~= nil then
        self.create_role_win:DeleteMe()
        self.create_role_win = nil
        self.create_role_visable = false
    end
end


function CreateRoleModel:InitMainUI()
    if BaseUtils.IsVerify then
        BaseUtils.VestPassCreateRole()
    else
        if self.create_role_win == nil then
            self.create_role_win= CreateRoleWindow.New(self)
            self.create_role_win:Open()
            self.create_role_visable = true
        end
    end
end

function CreateRoleModel:CloseMainUI()
    if self.create_role_win ~= nil then
        self.create_role_win:DeleteMe()
        self.create_role_win = nil
        self.create_role_visable = false
    end
end

--开始加载创建角色所需要的资源预设等
--初始化动作特效列表
function CreateRoleModel:init_effect_list()
    if self.maleEffectList == nil then
        self.maleEffectList = {}
        local ed = {EffectId = 15100 , EffectTargetPoint = EffectTargetPoint.LHand, Classes = 5}
        table.insert(self.maleEffectList, ed)
        ed = {EffectId = 15101 , EffectTargetPoint = EffectTargetPoint.Weapon, Classes = 5}
        table.insert(self.maleEffectList, ed)
        ed = {EffectId = 15102 , EffectTargetPoint = EffectTargetPoint.Origin, Classes = 5}
        table.insert(self.maleEffectList, ed)
        ed = {EffectId = 13100 , EffectTargetPoint = EffectTargetPoint.LWeapon, Classes = 3} --男战弓
        table.insert(self.maleEffectList, ed)
        ed = {EffectId = 13101 , EffectTargetPoint = EffectTargetPoint.Origin, Classes = 3}
        table.insert(self.maleEffectList, ed)
        ed = {EffectId = 12100 , EffectTargetPoint = EffectTargetPoint.Weapon, Classes = 2} --男魔导
        table.insert(self.maleEffectList, ed)
        ed = {EffectId = 12101 , EffectTargetPoint = EffectTargetPoint.Origin, Classes = 2}
        table.insert(self.maleEffectList, ed)


        ed = {EffectId = 11100 , EffectTargetPoint = EffectTargetPoint.LWeapon, Classes = 1} --男狂剑0.05
        table.insert(self.maleEffectList, ed)
        ed =  {EffectId = 11101 , EffectTargetPoint = EffectTargetPoint.RWeapon, Classes = 1}
        table.insert(self.maleEffectList, ed)
        ed = {EffectId = 11102 , EffectTargetPoint = EffectTargetPoint.Origin, Classes = 1}
        table.insert(self.maleEffectList, ed)


        ed =  {EffectId = 14100 , EffectTargetPoint = EffectTargetPoint.Origin, Classes = 4} --男兽灵
        table.insert(self.maleEffectList, ed)

        ed =  {EffectId = 14101 , EffectTargetPoint = EffectTargetPoint.Weapon, Classes = 4} --男兽灵
        table.insert(self.maleEffectList, ed)

        ed =  {EffectId = 17100 , EffectTargetPoint = EffectTargetPoint.Origin, Classes = 6} --男月魂
        table.insert(self.maleEffectList, ed)
        ed =  {EffectId = 17101 , EffectTargetPoint = EffectTargetPoint.Weapon, Classes = 6} --男月魂
        table.insert(self.maleEffectList, ed)

        ed = {EffectId = 18102 , EffectTargetPoint = EffectTargetPoint.LWeapon, Classes = 7} --男圣骑
        table.insert(self.maleEffectList, ed)
        ed =  {EffectId = 18101 , EffectTargetPoint = EffectTargetPoint.RWeapon, Classes = 7}
        table.insert(self.maleEffectList, ed)
        ed = {EffectId = 18100 , EffectTargetPoint = EffectTargetPoint.Origin, Classes = 7}
        table.insert(self.maleEffectList, ed)
    end
    if self.femaleEffectList == nil then
        self.femaleEffectList = {}
        local ed = {EffectId = 13100 , EffectTargetPoint = EffectTargetPoint.LWeapon, Classes = 3} --女战弓
        table.insert(self.femaleEffectList, ed)
        ed = {EffectId = 13101 , EffectTargetPoint = EffectTargetPoint.Origin, Classes = 3}
        table.insert(self.femaleEffectList, ed)

        ed = {EffectId = 12100 , EffectTargetPoint = EffectTargetPoint.Weapon, Classes = 2} --女魔导
        table.insert(self.femaleEffectList, ed)
        ed = {EffectId = 12101 , EffectTargetPoint = EffectTargetPoint.Origin, Classes = 2}
        table.insert(self.femaleEffectList, ed)

        ed = {EffectId = 11100 , EffectTargetPoint = EffectTargetPoint.LWeapon, Classes = 1} --女狂剑
        table.insert(self.femaleEffectList, ed)
        ed = {EffectId = 11101 , EffectTargetPoint = EffectTargetPoint.RWeapon, Classes = 1}
        table.insert(self.femaleEffectList, ed)
        ed = {EffectId = 11103 , EffectTargetPoint = EffectTargetPoint.Origin, Classes = 1}
        table.insert(self.femaleEffectList, ed)

        ed = {EffectId = 15101 , EffectTargetPoint = EffectTargetPoint.Weapon, Classes = 5} --女密言
        table.insert(self.femaleEffectList, ed)
        ed = {EffectId = 15100 , EffectTargetPoint = EffectTargetPoint.LHand, Classes = 5}
        table.insert(self.femaleEffectList, ed)
        ed = {EffectId = 15102 , EffectTargetPoint = EffectTargetPoint.Origin, Classes = 5}
        table.insert(self.femaleEffectList, ed)

        ed =  {EffectId = 14100 , EffectTargetPoint = EffectTargetPoint.Origin, Classes = 4} --女兽灵
        table.insert(self.femaleEffectList, ed)

        ed =  {EffectId = 14101 , EffectTargetPoint = EffectTargetPoint.Weapon, Classes = 4} --女兽灵
        table.insert(self.femaleEffectList, ed)

        ed =  {EffectId = 17100 , EffectTargetPoint = EffectTargetPoint.Origin, Classes = 6} --女月魂
        table.insert(self.femaleEffectList, ed)
        ed =  {EffectId = 17101 , EffectTargetPoint = EffectTargetPoint.Weapon, Classes = 6} --女月魂
        table.insert(self.femaleEffectList, ed)

        ed = {EffectId = 18102 , EffectTargetPoint = EffectTargetPoint.LWeapon, Classes = 7} --男圣骑
        table.insert(self.femaleEffectList, ed)
        ed =  {EffectId = 18101 , EffectTargetPoint = EffectTargetPoint.RWeapon, Classes = 7}
        table.insert(self.femaleEffectList, ed)
        ed = {EffectId = 18100 , EffectTargetPoint = EffectTargetPoint.Origin, Classes = 7}
        table.insert(self.femaleEffectList, ed)
    end
end
