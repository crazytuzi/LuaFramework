--
-- @Author: LaoY
-- @Date:   2019-01-09 20:16:20
-- 法宝
Talisman = Talisman or class("Talisman",DependObjcet)
function Talisman:ctor()
	self.check_follow_range_square = 130*130
	self.smooth_time = 0.6
	self.stop_check_offset_time = 3
	self.follow_angle = 225

	self:ChangeBody()
	self:SetPosition(self:GetFollowPosition())
	self:SetBodyPosition(0,120)
end

function Talisman:dctor()
end

function Talisman:AddEvent()
	local function call_back()
		self:ChangeBody()
	end
	self.owner_info_event_list[#self.owner_info_event_list+1] = self.owner_info:BindData("figure.talis",call_back)
end

function Talisman:ChangeBody()

	local res_id = self.owner_info.figure.talis.model;
	local abName = "model_fabao_" .. res_id
	local assetName = "model_fabao_" .. res_id
	self:CreateBodyModel(abName,assetName)
end

function Talisman:SetAlpha()
end