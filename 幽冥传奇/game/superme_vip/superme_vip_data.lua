SuperMeData = SuperMeData or BaseClass()

function SuperMeData:__init()
	if SuperMeData.Instance then
		ErrorLog("[SuperMeData]:Attempt to create singleton twice!")
	end
	SuperMeData.Instance = self
end

function SuperMeData:__delete()
	SuperMeData.Instance = nil
end

function SuperMeData:isOpenSuperMe()
	local my_money = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_DRAW_GOLD_COUNT)
	if RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SUPER_VIP) <=0 or math.floor(my_money/10)< 1000 then
		return true
	end
	return false
end

