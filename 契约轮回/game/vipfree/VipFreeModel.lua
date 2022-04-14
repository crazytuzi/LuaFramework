VipFreeModel = VipFreeModel or class("VipFreeModel",BaseModel)
local VipFreeModel = VipFreeModel

function VipFreeModel:ctor()
	VipFreeModel.Instance = self
	self:Reset()
end

function VipFreeModel:Reset()
	self.first_type = 6      --首充活动类型
	self.charge_type = 7     --连充活动类型
end

function VipFreeModel.GetInstance()
	if VipFreeModel.Instance == nil then
		VipFreeModel()
	end
	return VipFreeModel.Instance
end

--检查条件
function VipFreeModel:CheckReqs(reqs)
	for i=1, #reqs do 
		local req = reqs[i]
		if req[1] == "vip" then
			local viplevel = RoleInfoModel:GetInstance():GetMainRoleVipLevel()
			if viplevel < req[2] then
				return false
			end
		end
	end
	return true
end

function VipFreeModel:GetMutex(reqs)
	for i=1, #reqs do
		local req = reqs[i]
		if req[1] == "mutex" then
			return req[2]
		end
	end
end
