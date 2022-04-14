--
-- @Author: LaoY
-- @Date:   2019-12-12 21:05:30
--
--

Hand = Hand or class("Hand",DependStaticObject)

function Hand:ctor()
end

function Hand:dctor()
end

function Hand:func()
end

function Hand:ResetParent()
	local parent_transform = self.owner_object:GetBoneNode(SceneConstant.BoneNode.LHand) or self.owner_object.transform
	self.parent_transform:SetParent(parent_transform)
end

function Hand:AddEvent()
	local function call_back()
		self:ChangeBody()
	end
	self.owner_info_event_list[#self.owner_info_event_list+1] = self.owner_info:BindData("figure.offhand",call_back)
end

function Hand:ChangeBody()
	local abName
	local assetName
    local res_id = self.owner_info.body_res_id
    local hand = self.owner_info.figure.offhand
    if hand and hand.show then
        res_id = hand.model
    end
    local abName = "model_hand_" .. res_id
    local assetName = "model_hand_" .. res_id
	if abName then
		self:CreateBodyModel(abName,assetName)
	end
end

function Hand:OwnerEnterState(state_name)
	if self.animator then
		self.animator:CrossFadeInFixedTime(state_name, 0)
	end
end