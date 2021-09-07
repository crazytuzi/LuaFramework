TempMountData = TempMountData or BaseClass()

function TempMountData:__init()
    if TempMountData.Instance then
        print_error("[TempMountData]:Attempt to create singleton twice!")
    end
    TempMountData.Instance = self
    self.temporary_image = ConfigManager.Instance:GetAutoConfig("mount_auto").temporary_image or {}
    self.temp_wing_cfg = ConfigManager.Instance:GetAutoConfig("wing_auto").temporary_image or {}
end

function TempMountData:__delete()
    TempMountData.Instance = nil
end

function TempMountData:GetTempMountInfoByIndex(index)
	return self.temporary_image[index] or nil
end

function TempMountData:GetResIdById(id)
	for k,v in pairs(self.temporary_image) do
		if id == v.temporary_image_id then
			return v.res_id
		end
	end
end

function TempMountData:GetMountNameById(id)
    for k,v in pairs(self.temporary_image) do
        if id == v.temporary_image_id then
            return v.image_name
        end
    end
end

function TempMountData:GetWingNameById(id)
    for k,v in pairs(self.temp_wing_cfg) do
        if id == v.temporary_image_id then
            return v.image_name
        end
    end
end

function TempMountData:GetTempWingInfoByIndex(index)
    return self.temp_wing_cfg[index] or nil
end

function TempMountData:GetWingResIdById(id)
    for k,v in pairs(self.temp_wing_cfg) do
        if id == v.temporary_image_id then
            return v.res_id
        end
    end
end