--
-- @Author: LaoY
-- @Date:   2019-12-27 20:26:26
--
MachineArmorUltSkillShow = MachineArmorUltSkillShow or class("MachineArmorUltSkillShow",BasePanel)

function MachineArmorUltSkillShow:ctor()
	self.abName = "machinearmor_scene"
	self.assetName = "MachineArmorUltSkillShow"
	self.layer = LayerManager.LayerNameList.Bottom

	self.use_background = false
	self.change_scene_close = true
end

function MachineArmorUltSkillShow:dctor()
	self:StopAction()
end

function MachineArmorUltSkillShow:Open( )
	MachineArmorUltSkillShow.super.Open(self)
end

function MachineArmorUltSkillShow:LoadCallBack()
	self.nodes = {
		"con/img_bg/img_mahine_armor","con/img_name_bg/img_mahine_armor_name","con"
	}
	self:GetChildren(self.nodes)
	
	self.img_mahine_armor_component = self.img_mahine_armor:GetComponent('Image')
	self.img_mahine_armor_name_component = self.img_mahine_armor_name:GetComponent('Image')

	SetAlignType(self.transform, bit.bor(AlignType.Left, AlignType.Top))
	self:AddEvent()
end

function MachineArmorUltSkillShow:AddEvent()
end

function MachineArmorUltSkillShow:OpenCallBack()
	self:UpdateView()
	--self:StartTime()
	self:StartEnterAction()
end

function MachineArmorUltSkillShow:UpdateView( )
	local main_role_data = RoleInfoModel:GetInstance():GetMainRoleData()
	local mecha_morph_buff_id = main_role_data:IsHaveBuffEffectType(enum.BUFF_EFFECT.BUFF_EFFECT_MECHA_MORPH)
	if not mecha_morph_buff_id then
		self:Close()
		return
	end
	local p_buff = main_role_data:GetBuffByID(mecha_morph_buff_id)
	if not p_buff then
		self:Close()
		return
	end
	local res_id = p_buff.value
	if res_id == 0 then
		res_id = 10001
	end
	local abName = 'iconasset/icon_machinearmor_' .. res_id
	lua_resMgr:SetImageTexture(self,self.img_mahine_armor_component, abName, "machinearmor",false)
	lua_resMgr:SetImageTexture(self,self.img_mahine_armor_name_component, abName, "machinearmor_name",false)
end

function MachineArmorUltSkillShow:StartTime()
	self:StopTime()
	local function step()
		self:StartLeaveAction()
	end
	self.time_id = GlobalSchedule:StartOnce(step,1.8)
end

function MachineArmorUltSkillShow:StopTime()
	if self.time_id then
		GlobalSchedule:Stop(self.time_id)
		self.time_id = nil
	end
end

function MachineArmorUltSkillShow:CloseCallBack(  )
	self:StopTime()
end

function MachineArmorUltSkillShow:StartEnterAction()
	-- self:SetPosition(-300,0)
	SetLocalPositionX(self.con,-300)
	--local action = cc.MoveTo(0.2,0,0)
	local action = cc.Sequence(cc.MoveTo(0.2,0,0),
		cc.DelayTime(1.8),
		cc.MoveTo(0.2,-300,0),
		cc.CallFunc(function()
				self:Close()
			end))
	cc.ActionManager:GetInstance():addAction(action,self.con)
end

function MachineArmorUltSkillShow:StopAction()
	cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.con)
end

function MachineArmorUltSkillShow:StartLeaveAction()
	local action = cc.MoveTo(0.2,-300,0)
	action = cc.Sequence(action,
		cc.CallFunc(function()
			self:Close()
		end))
	cc.ActionManager:GetInstance():addAction(action,self.con)
end	