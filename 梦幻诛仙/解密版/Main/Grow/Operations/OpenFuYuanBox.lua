local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local OpenAwardPanel = import(".OpenAwardPanel")
local OpenFuYuanBox = Lplus.Extend(OpenAwardPanel, CUR_CLASS_NAME)
local AwardPanel = require("Main.Award.ui.AwardPanel")
local def = OpenFuYuanBox.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  return false
end
return OpenFuYuanBox.Commit()
