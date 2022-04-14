--
-- @Author: LaoY
-- @Date:   2019-12-30 15:04:29
--
MachineArmorShield = MachineArmorShield or class("MachineArmorShield",BaseItem)

function MachineArmorShield:ctor(parent_node,layer)
	self.abName = "machinearmor_scene"
	self.assetName = "MachineArmorShield"
	self.layer = layer

	MachineArmorShield.super.Load(self)
end

function MachineArmorShield:dctor()
	self:StopAction()
end

function MachineArmorShield:LoadCallBack()
	self.nodes = {
		"img_bar_bg/img_bar","img_bar_bg/img_bar/text",
	}
	self:GetChildren(self.nodes)
	self.img_bar_component = self.img_bar:GetComponent('Image')
	self.text_component = self.text:GetComponent('Text')

	if self.is_need_reset_bar then
		local value = self.value
		self.value = nil
		self:UpdateBar(value,self.origin)
	end
	self:AddEvent()
end

function MachineArmorShield:AddEvent()
end

function MachineArmorShield:SetData(data)
end

--[[
	@author LaoY
	@des 	进度条的值 0-1	
	@param1 number 0-1
--]]
function MachineArmorShield:UpdateBar(value,origin)
	if self.value == value then
		return
	end
	local last_number = self.value or origin
	self.origin = origin
	self.value = value
	if not self.is_loaded then
		self.is_need_reset_bar = true
		return
	end
	if self.text_action and not self.text_action:isDone() then
		last_number = self.text_action.cur_num
	end
	self:StopAction()
	self.is_need_reset_bar = false
	-- self.img_bar_component.fillAmount = value
	local cur_fillAmount = value/origin
	local action = cc.ValueTo(0.2, cur_fillAmount, self.img_bar_component, "fillAmount")
    cc.ActionManager:GetInstance():addAction(action, self.img_bar_component)

    -- local action = cc.NumberTo(0.2,last_number,self.value,nil,"%s/" .. GetShowNumber(self.origin))
    -- cc.ActionManager:GetInstance():addAction(action,self.text_component)
    -- self.text_action = action

    self.text_component.text = GetShowNumber(self.value,nil,15) .. "/" .. GetShowNumber(self.origin,nil,15)
end

function MachineArmorShield:StopAction()
	cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.img_bar_component)
	cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.text_component)
end