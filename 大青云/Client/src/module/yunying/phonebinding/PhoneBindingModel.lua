--[[
手机绑定
wangshuai
]]
_G.PhoneBindingModel = Module:new()

PhoneBindingModel.isBinding = false; -- 是否绑定

function PhoneBindingModel:ShowPhone()
	if not Version:IsOpenPhoneBinding() then return false; end
	return not self.isBinding;
end

function PhoneBindingModel:OnGetBindingState()
	return self.isBinding;
end;
