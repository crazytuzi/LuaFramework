faker = faker or class("faker",BaseModel)
local faker = faker

function faker:ctor()
	faker.Instance = self
	self:Reset()
end

function faker:Reset()

end

function faker.GetInstance()
	if faker.Instance == nil then
		faker()
	end
	return faker.Instance
end

--是否假人
function faker:is_fake(role_id)
	role_id = tonumber(role_id)
	return Config.db_faker[role_id] ~= nil
end