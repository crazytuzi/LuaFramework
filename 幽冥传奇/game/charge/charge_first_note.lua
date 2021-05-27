ChargeFirstNoteView = ChargeFirstNoteView or BaseClass(XuiBaseView)

function ChargeFirstNoteView:__init()
	self.texture_path_list[1] = 'res/xui/charge_note.png'
	self.config_tab = {
		{"charge_ui_cfg", 4, {0}},
	}
	-- self.is_modal = true
	self.weapon_cfg = {38,39,40}
	self.pos_x = 0
	self.pos_y = 0
end

function ChargeFirstNoteView:__delete()
end

function ChargeFirstNoteView:ReleaseCallBack()
	if self.weapon_model then
		self.weapon_model:setStop()
		self.weapon_model = nil
	end	
end

function ChargeFirstNoteView:SetPos(pos_x, pos_y)
	self.pos_x = pos_x 
	self.pos_y =  pos_y 
	self:Flush(index)
	
end


function ChargeFirstNoteView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		XUI.AddClickEventListener(self.node_t_list.layout_get_reward.node, BindTool.Bind1(self.OpenChargeFirst, self))
		--XUI.AddClickEventListener(self.node_t_list.btn_close.node, BindTool.Bind1(self.OnCloseHandler, self))
		local ph = self.ph_list.ph_weapon_show
		self.weapon_model = AnimateSprite:create()
		self.weapon_model:setPosition(ph.x, ph.y)
		self.weapon_model:setScale(0.7)
		self.node_t_list.layout_charge_note.node:addChild(self.weapon_model, 5)
		local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
		local ani_path,ani_name = ResPath.GetEffectUiAnimPath(self.weapon_cfg[prof])
		self.weapon_model:setAnimate(ani_path,ani_name,COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
		local name_path = "title_name_" .. prof
		self.node_t_list.img_bg_1.node:loadTexture(ResPath.GetChargeNote(name_path))
	end
end

function ChargeFirstNoteView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ChargeFirstNoteView:ShowIndexCallBack(index)
	self:Flush(index)
end

function ChargeFirstNoteView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ChargeFirstNoteView:OnFlush(param_t, index)
	local content_size = self.node_t_list.layout_charge_note.node:getContentSize()
	local x = self.pos_x - content_size.width/2 + 10
	local y = self.pos_y - content_size.height/2 - 30
	self.real_root_node:setPosition(x, y)
end

function ChargeFirstNoteView:OpenChargeFirst()
	ViewManager.Instance:Open(ViewName.ChargeFirst)
	self:Close()
end

-- function ChargeFirstNoteView:OnCloseHandler()
-- 	self:Close()
-- end