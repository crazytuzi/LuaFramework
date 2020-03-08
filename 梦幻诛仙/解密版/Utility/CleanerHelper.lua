local Lplus = require("Lplus")
local GcCallbacks = require("Utility.GcCallbacks")
local CleanerHelper = Lplus.Class()
do
  local def = CleanerHelper.define
  def.static("dynamic", "string", "string").defineCleaner = function(definer, getterName, disposerName)
    local cleanerFieldName = "m_" .. getterName
    definer.field(GcCallbacks)[cleanerFieldName] = nil
    definer.method("=>", GcCallbacks)[getterName] = function(self)
      local cleaner = self[cleanerFieldName]
      if not cleaner then
        cleaner = GcCallbacks()
        self[cleanerFieldName] = cleaner
      end
      return cleaner
    end
    definer.method()[disposerName] = function(self)
      local cleaner = self[cleanerFieldName]
      if cleaner then
        cleaner:dispose()
        self[cleanerFieldName] = nil
      end
    end
  end
end
return CleanerHelper.Commit()
