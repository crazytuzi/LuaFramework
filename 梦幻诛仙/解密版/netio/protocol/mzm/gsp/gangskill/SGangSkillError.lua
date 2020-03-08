local SGangSkillError = class("SGangSkillError")
SGangSkillError.TYPEID = 12599298
SGangSkillError.SILVER_NOT_ENOUGH = 1
SGangSkillError.BANG_GONG_NOT_ENOUGH = 2
SGangSkillError.NO_GANG = 3
SGangSkillError.TO_MAX_LEVEL = 4
SGangSkillError.ROLE_LEVEL_ERROR = 5
SGangSkillError.NO_SKILL = 6
SGangSkillError.SHUYUAN_OR_ROLELEVEL_ERROR = 7
function SGangSkillError:ctor(res)
  self.id = 12599298
  self.res = res or nil
end
function SGangSkillError:marshal(os)
  os:marshalInt32(self.res)
end
function SGangSkillError:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SGangSkillError:sizepolicy(size)
  return size <= 65535
end
return SGangSkillError
