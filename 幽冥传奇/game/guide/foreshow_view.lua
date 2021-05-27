-- 功能预告 预告视图
ForeshowView = ForeshowView or BaseClass(XuiBaseView)

function ForeshowView:__init()
	self.zorder = COMMON_CONSTS.ZORDER_FB_PANEL
	self.texture_path_list[1] = 'res/xui/foreshow.png'
	self:SetModal(true)
	self.roledata_change_callback = BindTool.Bind(self.RoleDataChangeCallback,self)
	self.can_click = false
end

function ForeshowView:__delete()
end

function ForeshowView:ReleaseCallBack()
	self.eff = nil

	if self.close_timer then
		GlobalTimerQuest:CancelQuest(self.close_timer)
		self.close_timer = nil
	end
end

function ForeshowView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self.foreshow_layout = XUI.CreateLayout(0, 0, 0, 0)
		self.root_node:addChild(self.foreshow_layout)

		self.foreshow_bg = XUI.CreateImageView(0, 0, ResPath.GetForeShow("foreshow_bg"), true)
		self.foreshow_layout:addChild(self.foreshow_bg, 2)
		XUI.AddClickEventListener(self.foreshow_bg, BindTool.Bind(self.OnClickBg, self), false)

		-- self.foreshow_title = XUI.CreateImageView(0, 160, ResPath.GetForeShow("title1"), true)
		-- self.foreshow_layout:addChild(self.foreshow_title, 3)

		self.foreshow_desc = XUI.CreateImageView(0, -90, ResPath.GetForeShow("desc1"), true)	
		self.foreshow_layout:addChild(self.foreshow_desc, 3)

		self.btn = XUI.CreateButton(0, -185, 0, 0, false, ResPath.GetCommon("btn_103"), ResPath.GetCommon("btn_103"), nil, true)
		self.btn:setTitleColor(COLOR3B.OLIVE)
		self.btn:setTitleFontName(COMMON_CONSTS.FONT)
		self.btn:setTitleFontSize(24)
		self.btn:setIsHittedScale(true)
		self.btn:setTitleText(Language.Common.LingQu)
		self.foreshow_layout:addChild(self.btn, 10)
		XUI.AddClickEventListener(self.btn, BindTool.Bind(self.OnClickBtn, self))

		self.text = XUI.CreateText(0, -142, 300, 22, cc.TEXT_ALIGNMENT_CENTER, "", nil, 21, COLOR3B.YELLOW)
		self.foreshow_layout:addChild(self.text, 20)
	end
end

function ForeshowView:OpenCallBack()
	RoleData.Instance:NotifyAttrChange(self.roledata_change_callback)
	AudioManager.Instance:PlayOpenCloseUiEffect()

	if self.close_timer then
		GlobalTimerQuest:CancelQuest(self.close_timer)
		self.close_timer = nil
	end
	self.cur_foreshow_obj = GuideData.Instance:GetCurForeshowObj()
	if self.cur_foreshow_obj and not self.cur_foreshow_obj.rec_condition() then
		self.close_timer = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.Close, self), 5)
	end

	self.can_click = false
	self:GetRootNode():setOpacity(0)
	local fade_in = cc.FadeIn:create(0.7)
	self:GetRootNode():runAction(cc.Sequence:create(fade_in, cc.CallFunc:create(function() self.can_click = true end)))
end

function ForeshowView:CloseCallBack(is_all)
	RoleData.Instance:UnNotifyAttrChange(self.roledata_change_callback)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ForeshowView:ShowIndexCallBack()
	self:Flush()
end

function ForeshowView:OnFlush(param_t, index)
	self.cur_foreshow_obj = GuideData.Instance:GetCurForeshowObj()
	if nil == self.cur_foreshow_obj then
		self:Close()
		return
	end

	local base_view = self.cur_foreshow_obj.base_view
	local foreshow_view_param = self.cur_foreshow_obj.foreshow_view_param
	local rec_cond = self.cur_foreshow_obj.rec_condition() 

	local txt = ""
	local color = COLOR3B.YELLOW

	if rec_cond then
		txt = Language.Foreshow.CanReceive
		color = COLOR3B.GREEN
	else
		if base_view.level then
			txt = string.format(Language.Foreshow.RecLevelLimit, base_view.level)
		end
		if base_view.login_days then
			txt = string.format(Language.Foreshow.RecLoginDaysLimit, base_view.login_days)
		end
	end
	self.text:setString(txt)
	self.text:setColor(color)

	XUI.SetButtonEnabled(self.btn, rec_cond)

	if foreshow_view_param.desc_img_path then
		self.foreshow_desc:loadTexture(ResPath.GetForeShow(foreshow_view_param.desc_img_path))
		self.foreshow_desc:setVisible(true)
	else
		self.foreshow_desc:setVisible(false)
	end

	if nil == self.eff then
		self.eff = RenderUnit.CreateEffect(base_view.eff_res_id, self.foreshow_layout, 6, nil, nil, -5, 68)
	else
		local anim_path, anim_name = ResPath.GetEffectUiAnimPath(base_view.eff_res_id)
		self.eff:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
	end
end

function ForeshowView:OnClickBtn()
	if not self.can_click or nil == self.cur_foreshow_obj then
		return
	end

	local foreshow_view_param = self.cur_foreshow_obj.foreshow_view_param
	if foreshow_view_param.btn_func then
		foreshow_view_param.btn_func(self)
	end
end

function ForeshowView:OnClickBg()
	if not self.can_click or nil == self.cur_foreshow_obj then
		return
	end

	if self.cur_foreshow_obj.rec_condition() then
		local foreshow_view_param = self.cur_foreshow_obj.foreshow_view_param
		if foreshow_view_param.btn_func then
			foreshow_view_param.btn_func(self)
		end
	else
		self:Close()
	end
end

function ForeshowView:RoleDataChangeCallback(key, value)
	if key == OBJ_ATTR.CREATURE_LEVEL then
		self:Flush()
	end
end
