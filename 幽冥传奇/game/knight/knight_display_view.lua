KnightDispalyView = KnightDispalyView or BaseClass(XuiBaseView)

function KnightDispalyView:__init()
	self.texture_path_list[1] = 'res/xui/knight.png'
	self.is_async_load = false
	self.is_modal = false	
	self.is_any_click_close = true
	self.config_tab = {
		--{"common_ui_cfg", 1, {0}},
		{"knight_ui_cfg", 3, {0}},
		--knight_ui_cfg", 2, {0}},
		--{"common_ui_cfg", 2, {0}},
	}
	
end

function KnightDispalyView:__delete()
	
end

function KnightDispalyView:ReleaseCallBack()
	if self.role_display then
		self.role_display:DeleteMe()
		self.role_display = nil 
	end
end

function KnightDispalyView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		if nil == self.role_display then
			local ph = self.ph_list.ph_display
			self.role_display = RoleDisplay.New(self.node_t_list.layout_display_show.node, 99, false, false,true, true)
			self.role_display:SetPosition(ph.x,ph.y)
		end
	end
end

function KnightDispalyView:OpenCallBack()
	
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function KnightDispalyView:ShowIndexCallBack(index)
	self:Flush(index)
end

function KnightDispalyView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end


function KnightDispalyView:OnFlush(param_t, index)
	local model_id = RoleData.Instance:GetAttr(OBJ_ATTR.ENTITY_MODEL_ID)
	local weapon_id = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_WEAPON_APPEARANCE)
	local wing_id = 16
	local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
	--print("333333333", model_id, weapon_id, wing_id, sex)
	local temp_vo = {
			[OBJ_ATTR.ENTITY_MODEL_ID] = model_id,
			[OBJ_ATTR.ACTOR_WEAPON_APPEARANCE] = weapon_id,
			[OBJ_ATTR.ACTOR_WING_APPEARANCE] = wing_id,
			[OBJ_ATTR.ACTOR_SEX] = sex,

		}
	self.role_display:SetRoleVo(temp_vo)
end