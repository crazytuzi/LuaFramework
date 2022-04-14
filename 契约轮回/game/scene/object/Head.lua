--
-- @Author: LaoY
-- @Date:   2019-12-12 20:57:55
--
--require("game.xx.xxx")

Head = Head or class("Head",DependStaticObject)

function Head:ctor()
end

function Head:dctor()
end

function Head:func()
end

function Head:ResetParent()
	local parent_transform = self.owner_object:GetBoneNode(SceneConstant.BoneNode.Head) or self.owner_object.transform
	self.parent_transform:SetParent(parent_transform)
end

function Head:AddEvent()
	local function call_back()
		self:ChangeBody()
	end
	self.owner_info_event_list[#self.owner_info_event_list+1] = self.owner_info:BindData("figure.fashion_head",call_back)
end

function Head:ChangeBody()
	local abName
	local assetName
    local res_id = self.owner_info.body_res_id
    local head = self.owner_info.figure.fashion_head
    if head and head.show then
        res_id = head.model
    end
    local abName = "model_head_" .. res_id
    local assetName = "model_head_" .. res_id
	if abName then
		self:CreateBodyModel(abName,assetName)
	end
end

function Head:OwnerEnterState(state_name)
	if self.animator then
		self.animator:CrossFadeInFixedTime(state_name, 0)
	end
end