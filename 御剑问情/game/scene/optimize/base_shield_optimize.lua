BaseShieldOptimize = BaseShieldOptimize or BaseClass()

function BaseShieldOptimize:__init()
	self.max_appear_count = 100
	self.min_appear_count = 10
end

function BaseShieldOptimize:__delete()

end

function BaseShieldOptimize:GetAllObjIds()
	return {}, 0
end

function BaseShieldOptimize:OnFpsSampleCallback(fps)
	local appear_count = math.floor(self.max_appear_count * (fps / GAME_FPS))
	appear_count = math.max(appear_count, self.min_appear_count)
	appear_count = math.min(appear_count, self.max_appear_count)

	self:SetAppearCount(appear_count)
end

function BaseShieldOptimize:SetAppearCount(appear_count)
	local all_objids, old_appear_count = self:GetAllObjIds()

	if appear_count == old_appear_count then
		return
	end

	local to_visible = (appear_count - old_appear_count) > 0
	local inc_count = math.abs(appear_count - old_appear_count)

	local count = 0
	for k, v in pairs(all_objids) do
		if count >= inc_count then
			break
		end

		if (v ~= to_visible and to_visible and self:AppearObj(k))
			or (v ~= to_visible and not to_visible and self:DisAppearObj(k)) then
			count = count + 1
		end
	end
end

function BaseShieldOptimize:AppearObj(obj_id)
	return false
end

function BaseShieldOptimize:DisAppearObj(obj_id)
	return false
end