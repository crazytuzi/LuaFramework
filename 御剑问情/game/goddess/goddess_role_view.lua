GoddessRoleView = GoddessRoleView or BaseClass(BaseRender)

function GoddessRoleView:__init(instance)
	if instance == nil then
		return
	end
	GoddessRoleView.Instance = self
	self:ListenEvent("change_name_btn",BindTool.Bind(self.ChangeNameOnClick, self))
	self.show_name_text = self:FindVariable("show_name_text")
	self.level_text = self:FindVariable("level_text")
	self.current_id = -1
end

function GoddessRoleView:SetLevelValue(xiannv_level, quality)
	--local level =  ToColorStr(xiannv_level, SOUL_NAME_COLOR[quality]) --根据品质更改颜色
	self.level_text:SetValue(xiannv_level)
end

function GoddessRoleView:OnFlush(name, quality, xiannv_id)
	self.current_id = xiannv_id
	local xiannv_new_name_list = GoddessData.Instance:GetXianNvNameList()
	if xiannv_new_name_list[xiannv_id] == "" then
		--local name = ToColorStr(name,SOUL_NAME_COLOR[quality])--根据品质更改颜色
		self.show_name_text:SetValue(name)
	else
		self.show_name_text:SetValue(xiannv_new_name_list[xiannv_id])
	end
end

function GoddessRoleView:ChangeNameOnClick()
	if not GoddessData.Instance:JudgeXianIsActive(self.current_id) then
		TipsCtrl.Instance:ShowSystemMsg("该伙伴尚未激活, 激活后才能改名")
		return
	end
	local func = function(name)
		GoddessCtrl.Instance:SendCSXiannvRename(self.current_id, name)
	end
	local num_text = ToColorStr(GoddessData.Instance:GetXianNvOtherCfg().rename_consume_gold .. "", TEXT_COLOR.BLUE_4)
	TipsCtrl.Instance:ShowRename(func, nil, nil, "", num_text)
end
