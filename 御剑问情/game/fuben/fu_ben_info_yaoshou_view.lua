FuBenInfoYaoShouView = FuBenInfoYaoShouView or BaseClass(BaseView)

local boss_count = 1


ATTR_TYPE = {
	[0] = "木",
	[1] = "金",
	[2] = "火",
	[3] = "水",
}


ATTR_TYPE_MODEL_NAME = {
	[0] = BUFF_TYPE.EBT_LV,
	[1] = BUFF_TYPE.EBT_HUANG,
	[2] = BUFF_TYPE.EBT_HOU,
	[3] = BUFF_TYPE.EBT_LAN,
}



function FuBenInfoYaoShouView:__init()
	self.ui_config = {"uis/views/fubenview_prefab", "TeamYaoShouFBInfoView"}
	self.active_close = false
	self.fight_info_view = true
	self.view_layer = UiLayer.FloatText
end

function FuBenInfoYaoShouView:__delete()

end

function FuBenInfoYaoShouView:ReleaseCallBack()

    ---清理变量和对象
	self.boss_name = nil
	self.kill_boss_num = nil
	self.boss_num = nil
	self.fb_all_wave = nil
	self.finish_wave = nil
	self.cur_property = nil
	self.show_panel = nil
	self.kezhi_attr = nil
	self.show_warning_img = nil

end

function FuBenInfoYaoShouView:LoadCallBack()
	self.boss_name = self:FindVariable("BossName")
	self.kill_boss_num = self:FindVariable("KillBossNum")
	self.boss_num = self:FindVariable("BossNum")
	self.fb_all_wave = self:FindVariable("AllWave")
	self.finish_wave = self:FindVariable("FinishWave")
	self.cur_property = self:FindVariable("CurrentProperty")
	self.show_panel = self:FindVariable("ShowPanel")
	self.kezhi_attr = self:FindVariable("KeZhiAttr")
	self.show_warning_img = self:FindVariable("ShowWarning")

end

function FuBenInfoYaoShouView:PortraitToggleChange(state)
	if state == true then
		self:Flush()
	end
	if self.show_panel then
		self.show_panel:SetValue(state)
	end
end

function FuBenInfoYaoShouView:CloseCallBack()
	self.is_create_Attr_dis = nil

	if self.role_list then
		for k,v in pairs(self.role_list) do
			if v.uid ~= 0 then
				local role = Scene.Instance:GetObjByUId(v.uid)
				if role then
					role:RemoveBuff(ATTR_TYPE_MODEL_NAME[v.attr])
				end
			end
			
		end
		self.role_list = nil
	end

	self.up_boss_attr = nil

	if self.menu_toggle_event then
		GlobalEventSystem:UnBind(self.menu_toggle_event)
		self.menu_toggle_event = nil
	end

	if self.obj_create_event then
		GlobalEventSystem:UnBind(self.obj_create_event)
		self.obj_create_event = nil
	end

	if self.up_boss_attr then
		self.up_boss_attr = nil
	end

	self.warning_time = nil

	if self.count_down_time_quest then
		CountDown.Instance:RemoveCountDown(self.count_down_time_quest)
		self.count_down_time_quest = nil
	end
end

function FuBenInfoYaoShouView:OpenCallBack()
	MainUICtrl.Instance:SetViewState(false)
	self.boss_num:SetValue(boss_count)
	self.wave_max_num = 0 
	-- 获取最大的波数
	for k,v in pairs(FuBenData.Instance:GetYsjtTeamFbCfg()) do
		if v.wave>self.wave_max_num then
			self.wave_max_num = v.wave
		end
	end

	self.yaoshou_info = FuBenData.Instance:GetYsjtTeamFbSceneLogicInfo() 
	
	if self.yaoshou_info~=nil then
		local mode = self.yaoshou_info.mode		
		local wave = self.yaoshou_info.pass_wave
		local monster_id = FuBenData.Instance:GetYsjtTeamFbMonsterId(mode, wave + 1)
		self:CreateBossAttrBuff(self.yaoshou_info.boss_attr_type, monster_id)
	end

	self.fb_all_wave:SetValue(self.wave_max_num)
	self:ChangeName()
	
	self.is_create_Attr_dis = false
	self.up_boss_attr = 0

	self.menu_toggle_event = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.PortraitToggleChange, self))

	--监听obj创建
	self.obj_create_event = GlobalEventSystem:Bind(ObjectEventType.OBJ_CREATE,
		BindTool.Bind(self.ObjCreate, self))

	if self.count_down_time_quest then
		CountDown.Instance:RemoveCountDown(self.count_down_time_quest)
		self.count_down_time_quest = nil
	end
	self.warning_time = 10
	self.show_warning_img:SetValue(true)
	self.count_down_time_quest = CountDown.Instance:AddCountDown(self.warning_time, 1, BindTool.Bind(self.CountDownWarningActive, self))
	self:Flush()

end

function FuBenInfoYaoShouView:OnClickOpenBuff()
	TipsCtrl.Instance:TipsExpInSprieFuBenView()
end

function FuBenInfoYaoShouView:OnClickOpenPotion()
	TipsCtrl.Instance:ShowTipExpFubenView()
end

function FuBenInfoYaoShouView:ObjCreate(obj)
	if nil == obj.draw_obj then
		return
	end

	local obj_type = obj.draw_obj:GetObjType()
	if obj_type == SceneObjType.Monster then
		self:CreateBossAttrBuff(self.yaoshou_info.boss_attr_type, obj.vo.monster_id)
	end
end

function FuBenInfoYaoShouView:OnFlush()
	if not self.yaoshou_info then
		self.yaoshou_info = {}
	end
	self.yaoshou_info = FuBenData.Instance:GetYsjtTeamFbSceneLogicInfo() 
	
	if self.yaoshou_info~=nil then

		local mode = self.yaoshou_info.mode		
		local wave = self.yaoshou_info.pass_wave		
		local name = FuBenData.Instance:GetYsjtTeamFbMonsterName(mode, wave + 1)

		local monster_id = FuBenData.Instance:GetYsjtTeamFbMonsterId(mode, wave + 1)

		self:CreateBossAttrBuff(self.yaoshou_info.boss_attr_type, monster_id)

		self.finish_wave:SetValue(wave)
		self.boss_name:SetValue(name)
		self.kill_boss_num:SetValue(self.yaoshou_info.kill_boss_num)
		self.cur_property:SetValue(ATTR_TYPE[self.yaoshou_info.boss_attr_type]) 
		local kezhi = self.yaoshou_info.boss_attr_type
		kezhi = kezhi~=0 and kezhi - 1 or 3
		self.kezhi_attr:SetValue(ATTR_TYPE[kezhi])
	end	

end

function FuBenInfoYaoShouView:ChangeName()		-- 给玩家头顶的名字，增加属性前缀
	if self.is_create_Attr_dis then
		return
	end

	local info = FuBenData.Instance:GetYsjtTeamFbSceneLogicInfo() 
	self.role_list = info.role_attrs
	for k,v in pairs(info.role_attrs) do
		if v.uid ~= 0 then
			local role = Scene.Instance:GetObjByUId(v.uid)
			self:OnChangeName(role)
			self:CreateAttrBuff(v.attr, role)
		end
	end


	self.is_create_Attr_dis = true

end

function FuBenInfoYaoShouView:OnChangeName(role)
	role:ChangeFollowUiName()
end

function FuBenInfoYaoShouView:CreateAttrBuff(attr, role)
	if not attr and not role then
		return 
	end
	role:AddBuff(ATTR_TYPE_MODEL_NAME[attr])
end

function FuBenInfoYaoShouView:CreateBossAttrBuff(attr, monster_id)
	local monster_list = Scene.Instance:GetMonsterList() or {}
	local monster = nil
	for k, v in pairs(monster_list) do
		if v.vo.monster_id == monster_id then
			monster = v
			break
		end
	end
	if monster then

		if not self.up_boss_attr then
			self.up_boss_attr = attr
		end
		for k,v in pairs(monster_list) do
			v:RemoveBuff(ATTR_TYPE_MODEL_NAME[self.up_boss_attr])
		end	
		self.up_boss_attr = attr
		monster:AddBuff(ATTR_TYPE_MODEL_NAME[attr])
	end
end

function FuBenInfoYaoShouView:CountDownWarningActive()
	self.warning_time = self.warning_time - 1
	if self.warning_time == 0 then	
		self.show_warning_img:SetValue(false)
		CountDown.Instance:RemoveCountDown(self.count_down_time_quest)
	end
end



