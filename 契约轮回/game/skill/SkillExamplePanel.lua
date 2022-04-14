-- @Author: lwj
-- @Date:   2018-10-24 16:29:32
-- @Last Modified time: 2018-10-25 10:09:36

SkillExamplePanel = SkillExamplePanel or class("SkillExamplePanel",BasePanel)
local SkillExamplePanel = SkillExamplePanel

function SkillExamplePanel:ctor()
	self.abName = "skill"
	self.assetName = "SkillExamplePanel"
	self.layer = "UI"

end

function SkillExamplePanel:dctor()
end

function SkillExamplePanel:Open()
	SkillExamplePanel.super.Open(self)
end

function SkillExamplePanel:LoadCallBack()
	self.nodes = 
	{
		"btn_Confirm",
	}
	self:GetChildren(self.nodes)
	self:AddEvent()
end

function SkillExamplePanel:AddEvent()
	local function call_back()
		self:Close()
	end
 	AddClickEvent(self.btn_Confirm.gameObject,call_back)
end
