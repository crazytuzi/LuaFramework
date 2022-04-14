--
-- @Author: LaoY
-- @Date:   2019-10-08 11:08:35
--
--require("game.xx.xxx")

Wing = Wing or class("Wing",DependStaticObject)

function Wing:ctor()
end

function Wing:dctor()
end


function Wing:ResetParent()
	local parent_transform
	if self.be_depend_object.__cname == "Fairy" then
		parent_transform = self.be_depend_object:GetBoneNode(SceneConstant.BoneNode.Wing) or self.be_depend_object.transform
		-- parent_transform = self.be_depend_object.transform
	else
		parent_transform = self.owner_object:GetBoneNode(SceneConstant.BoneNode.Wing) or self.owner_object.transform
	end
	self.parent_transform:SetParent(parent_transform)
end

function Wing:AddEvent()
	local function call_back()
		self:ChangeBody()
	end
	if self.be_depend_object.__cname == "Fairy" then
		self.owner_info_event_list[#self.owner_info_event_list+1] = self.owner_info:BindData("figure.baby_wing",call_back)
	else
		self.owner_info_event_list[#self.owner_info_event_list+1] = self.owner_info:BindData("figure.wing",call_back)
	end
end

function Wing:ChangeBody()
	local abName
	local assetName
	local res_id,show
	if self.be_depend_object.__cname == "Fairy" then
		res_id = self.owner_info.figure.baby_wing and self.owner_info.figure.baby_wing.model
	    show = self.owner_info.figure.baby_wing and self.owner_info.figure.baby_wing.show
	    if show then
		    abName = "model_child_".. res_id
	        assetName = "model_child_" .. res_id
	    end
	else
		res_id = self.owner_info.figure.wing and self.owner_info.figure.wing.model
	    show = self.owner_info.figure.wing and self.owner_info.figure.wing.show
	    if show then
		    abName = "model_wing_".. res_id
	        assetName = "model_wing_" .. res_id
	    end
	end
	
	if abName then
		self:CreateBodyModel(abName,assetName)
	end
end