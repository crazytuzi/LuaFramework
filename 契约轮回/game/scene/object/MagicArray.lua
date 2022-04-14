MagicArray = MagicArray or class("MagicArray",DependStaticObject)
function MagicArray:ctor()
	SetLocalPosition(self.model_parent,0,0,0)
	self:SetBodyPosition(0,0)
	self.is_riding = false
end

function MagicArray:ResetParent()
	local parent_transform = self.owner_object:GetBoneNode(SceneConstant.BoneNode.Root) or self.owner_object.transform
	self.parent_transform:SetParent(parent_transform)
end

function MagicArray:dctor()
	local main_role = SceneManager:GetInstance():GetMainRole()
	main_role.ride_up_on_enter_call_back =  nil
	main_role.remove_mount_callback = nil
end

function MagicArray:InitMachine()

end

function MagicArray:AddEvent()
	local function call_back()
		self:ChangeBody()
	end
	self.owner_info_event_list[#self.owner_info_event_list+1] = self.owner_info:BindData("figure.fashion_footprint",call_back)

	local main_role = SceneManager:GetInstance():GetMainRole()

	local function call_back(  )
		SetVisible(self.transform,false)
		self.is_riding = true
	end
	main_role.ride_up_on_enter_callback = call_back

	local function call_back(  )
		SetVisible(self.transform,true)
		self.is_riding = false
	end
	main_role.remove_mount_callback = call_back
end

function MagicArray:ChangeBody()
	local abName
	local assetName

	local res_id = self.owner_info.figure.fashion_footprint and self.owner_info.figure.fashion_footprint.model
    local show = self.owner_info.figure.fashion_footprint and self.owner_info.figure.fashion_footprint.show
    if show then
	    abName = Config.db_effect[res_id].name
        assetName =  Config.db_effect[res_id].name
    end
	
	if abName then
		self:CreateBodyModel(abName,assetName,true)
	end
end

function MagicArray:LoadBodyCallBack()

	SetLocalPosition(self.transform, 0, 0, 0)
	SetLocalRotation(self.transform)

	if self.is_riding then
		SetVisible(self.transform,false)
	end

end