-- 武器
-- @author huangyq
-- @date   160726
GoWeaponPool = GoWeaponPool or BaseClass(GoBasePool)

function GoWeaponPool:__init(parent)
    self.name = "weapon_tpose"
    self.maxSize = 30
    self.checkCount = 43
    self.parent = parent
    self.Type = GoPoolType.Weapon
    self:SetIgnoreFlag()
end

function GoWeaponPool:__delete()
end

function GoWeaponPool:Reset(poolObj, path)
    self:ResetModel(poolObj)
end
