local MODULE_NAME = (...)
local Lplus = require("Lplus")
local IReqTimeoutChecker = Lplus.Interface(MODULE_NAME)
local SSRequestBase = Lplus.ForwardDeclare("SSRequestBase")
local def = IReqTimeoutChecker.define
def.virtual(SSRequestBase).AddToCheckList = function(self, request)
end
def.virtual(SSRequestBase).RemoveFromCheckList = function(self, request)
end
return IReqTimeoutChecker.Commit()
