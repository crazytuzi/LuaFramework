--[[
手机绑定
wangshuai
]]

_G.PhoneContrller = setmetatable({},{__Index = IController});
PhoneContrller.name = "PhoneContrller";

function PhoneContrller:Create()

end

-- 是否领取
function PhoneContrller:OnPhoneIsBinding(state)
	if state == 1 then
		PhoneBindingModel.isBinding = true;
	end
end
