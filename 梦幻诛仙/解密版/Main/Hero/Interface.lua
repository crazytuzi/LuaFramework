local Interface = {}
local HeroModule = require("Main.Hero.HeroModule")
function Interface.GetHeroProp()
  return HeroModule.Instance():GetHeroProp()
end
function Interface.GetBasicHeroProp()
  local heroProp = Interface.GetHeroProp()
  local basicHeroProp
  if heroProp then
    basicHeroProp = {
      id = heroProp.id,
      name = heroProp.name,
      gender = heroProp.gender,
      occupation = heroProp.occupation,
      level = heroProp.level
    }
  else
    local role = require("Main.Login.LoginModule").Instance():GetLastLoginRole()
    if role then
      basicHeroProp = {
        id = role.roleid,
        name = role.basic.name,
        gender = role.basic.gender,
        occupation = role.basic.occupation,
        level = role.basic.level
      }
    else
      warn("Attemp to get basic hero prop before hero login!!!", debug.traceback())
      return nil
    end
  end
  return basicHeroProp
end
function Interface.RoleIDToDisplayID(roleId)
  local displayId = require("Main.Hero.HeroUtility").Instance():RoleIDToDisplayID(roleId)
  return displayId
end
function Interface.DisplayIDToRoleID(displayId)
  local roleId = require("Main.Hero.HeroUtility").Instance():DisplayIDToRoleID(displayId)
  return roleId
end
function Interface.MoveTo(mapId, x, y)
  warn("Do not call this Function", debug.traceback())
end
return Interface
