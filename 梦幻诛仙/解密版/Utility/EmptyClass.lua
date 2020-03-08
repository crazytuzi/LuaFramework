local Lplus = require("Lplus")
local EmptyClass = Lplus.Class("EmptyClass")
do
  local def = EmptyClass.define
  def.static("string", "=>", "table").Make = function(name)
    return EmptyClass.MakeInner(name)
  end
  def.static("=>", "table").MakeAnonymous = function()
    return EmptyClass.MakeInner(nil)
  end
  def.static("dynamic", "=>", "table").MakeInner = function(name)
    local Class = Lplus.Class(name)
    local l_empty
    do
      local def = Class.define
      def.static("=>", Class).Empty = function()
        return l_empty
      end
    end
    Class.Commit()
    l_empty = Class()
    return Class
  end
end
return EmptyClass.Commit()
