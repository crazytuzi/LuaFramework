WeaponNoTimeTip = WeaponNoTimeTip or BaseClass(XuiBaseView)
function WeaponNoTimeTip:__init()
	-- if WeaponNoTimeTip.Instance then
	-- 	ErrorLog("[WeaponNoTimeTip] Attemp to create a singleton twice !")
	-- end
	self.texture_path_list[1] = 'res/xui/charge.png'
	WeaponNoTimeTip.Instance = self
	self.is_modal = true
	self.background_opacity = 200
	self.config_tab  = {
		{"func_task_ui_cfg",3,{0},}
	}
	self.root_node_off_pos = {x = -50, y = 0}

end

function WeaponNoTimeTip:__delete()
	--WeaponNoTimeTip.Instance = nil
end

function WeaponNoTimeTip:ReleaseCallBack()
	-- override
	if self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end
end

function WeaponNoTimeTip:LoadCallBack(index, loaded_time)
	if loaded_time <= 1 then
		XUI.AddClickEventListener(self.node_t_list.layout_btn.node, BindTool.Bind1(self.CloseWindow, self))
		XUI.AddClickEventListener(self.node_t_list.btn_close.node, BindTool.Bind1(self.CloseWindow, self))
		local ph = self.ph_list.ph_cell
		self.cell = BaseCell.New()
		self.cell:SetPosition(ph.x, ph.y)
		self.node_t_list.layout_weapon_time_limit.node:addChild(self.cell:GetView(), 99)
	end
end

--欢迎界面的logo替换写到了opencallback中
function WeaponNoTimeTip:ShowIndexCallBack()
	self:Flush(index)
end

function WeaponNoTimeTip:CloseWindow()
	local guild_id = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GUILD_ID)
	if guild_id > 0 then
		ViewManager.Instance:Open(ViewName.Guild, TabIndex.guild_exploit)
	else
		ViewManager.Instance:Open(ViewName.Guild, TabIndex.guild_join_list)
	end
	self:Close()
end

function WeaponNoTimeTip:SetData(data)
	self.data = data
	self:Open()
end

function WeaponNoTimeTip:OnFlush(param_t, index)
	-- print("index:", index)
	self.cell:SetData(self.data)
	self.cell:SetQualityEffect(920, 1)
end