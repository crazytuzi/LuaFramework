--
-- @Author: LaoY
-- @Date:   2019-10-08 11:49:37
--

Weapon = Weapon or class("Weapon",DependStaticObject)

function Weapon:ctor()
end

function Weapon:dctor()
end


function Weapon:ResetParent()
	local parent_transform = self.owner_object:GetBoneNode(SceneConstant.BoneNode.RHand) or self.owner_object.transform
	self.parent_transform:SetParent(parent_transform)
end

function Weapon:AddEvent()
	local function call_back()
		self:ChangeBody()
	end
	self.owner_info_event_list[#self.owner_info_event_list+1] = self.owner_info:BindData("figure.weapon",call_back)
end

function Weapon:ChangeBody()
	local abName
	local assetName

	local res_id = self.owner_info.figure.weapon and self.owner_info.figure.weapon.model
	if not res_id or res_id == 0 then
		res_id = self.owner_info.body_res_id
	end
    local show = self.owner_info.figure.weapon and self.owner_info.figure.weapon.show
    if res_id == self.owner_info.body_res_id or show then
	    abName = "model_weapon_".. res_id
        assetName = "model_weapon_r_" .. res_id
    end
	
	if abName then
		self:CreateBodyModel(abName,assetName)
	end
end