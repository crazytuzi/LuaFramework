require "Core.Module.Common.UIComponent"

SubPetLevelUpPanel = class("SubPetLevelUpPanel", UIComponent);
function SubPetLevelUpPanel:New()
    self = { };
    setmetatable(self, { __index = SubPetLevelUpPanel });
    return self
end

function SubPetLevelUpPanel:_Init()

end
 
function SubPetLevelUpPanel:_Dispose()

end


function SubPetLevelUpPanel:UpdateSubPetLevelUpPanel()

end