-- 功能预告 预告基础视图
ForeshowBaseView = ForeshowBaseView or BaseClass(XuiBaseView)

function ForeshowBaseView:__init()
	self.root_x, self.root_y = 0, 0
end

function ForeshowBaseView:__delete()
end

function ForeshowBaseView:ReleaseCallBack()
	self.eff = nil
end

function ForeshowBaseView:OpenCallBack()
end

function ForeshowBaseView:CloseCallBack(is_all)
end

-- 重写更新Z轴，防止当前视图太靠前
function ForeshowBaseView:UpdateLocalZOrder()
	if nil ~= self.real_root_node then
		self.real_root_node:setLocalZOrder(-3)
	end
end

local layout_w, layout_h = 120, 120
function ForeshowBaseView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		local screen_w, screen_h = HandleRenderUnit:GetWidth(), HandleRenderUnit:GetHeight()

		self.root_x, self.root_y = 440, screen_h - layout_h * 0.5
		self.root_node:setPosition(self.root_x, self.root_y)
		self.foreshow_layout = XUI.CreateLayout(0, 0, layout_w, layout_h)
		self.root_node:addChild(self.foreshow_layout)
		self.foreshow_layout:setHittedScale(1.05)
		-- self.foreshow_layout:setBackGroundColor(COLOR3B.RED)

		self.foreshow_bg = XUI.CreateImageView(layout_w * 0.5, 0 - 5, ResPath.GetCommon("bg_106"), true)
		self.foreshow_layout:addChild(self.foreshow_bg, 10)
		self.foreshow_bg:setScaleX(0.5)
		self.foreshow_bg:setScaleY(0.62)
		self.foreshow_text = XUI.CreateText(layout_w * 0.5, 0 - 5, 300, 21, cc.TEXT_ALIGNMENT_CENTER, text, nil, 21, COLOR3B.YELLOW)
		self.foreshow_layout:addChild(self.foreshow_text, 20)

		XUI.AddClickEventListener(self.foreshow_layout, BindTool.Bind(self.OnClickView, self), true)
	end
end

function ForeshowBaseView:ShowIndexCallBack()
	self:Flush()
end

function ForeshowBaseView:OnFlush(param_t, index)
	self.cur_foreshow_obj = GuideData.Instance:GetCurForeshowObj()
	if nil == self.cur_foreshow_obj then
		self:Close()
		return
	end

	local base_view = self.cur_foreshow_obj.base_view
	local txt = ""
	local color = COLOR3B.YELLOW
	if self.cur_foreshow_obj.rec_condition() then
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
	self.foreshow_text:setString(txt)
	self.foreshow_text:setColor(color)

	if nil == self.eff then
		self.eff = RenderUnit.CreateEffect(base_view.eff_res_id, self.foreshow_layout, 1, nil, nil, layout_w * 0.5, layout_h * 0.5)
	else
		local anim_path, anim_name = ResPath.GetEffectUiAnimPath(base_view.eff_res_id)
		self.eff:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
	end
	self.eff:setScale(base_view.eff_scale or 0.75)
	self.foreshow_text:setVisible(base_view.foreshow_text_vis == nil or base_view.foreshow_text_vis)
	self.foreshow_bg:setVisible(base_view.foreshow_bg_vis == nil or base_view.foreshow_bg_vis)

	-- self.eff:setVisible(true)
end

function ForeshowBaseView:FlyToScene()
	local fly_y = 130
	self.root_node:stopAllActions()
	self.root_node:setPosition(self.root_x, self.root_y + fly_y)
	local fadein = cc.FadeIn:create(1)
	local move_to = cc.MoveTo:create(2, cc.p(self.root_x, self.root_y))
	local action = cc.Spawn:create(fadein, move_to)
	self.root_node:runAction(move_to)
end

function ForeshowBaseView:EffectFlyToCenter()
	self.cur_foreshow_obj = GuideData.Instance:GetCurForeshowObj()
	if nil == self.cur_foreshow_obj then
		return
	end

	if not self:IsOpen() then
		self:Open()
	end

	local base_view = self.cur_foreshow_obj.base_view
	-- self.eff:setVisible(false)

	local fly_eff = RenderUnit.CreateEffect(base_view.eff_res_id)
	local node_world_pos = self.foreshow_layout:convertToWorldSpace(cc.p(layout_w * 0.5, layout_h * 0.5))
	HandleRenderUnit:AddUi(fly_eff, COMMON_CONSTS.ZORDER_SYSTEM_EFFECT)
	local hx, hy = HandleRenderUnit:GetWidth(), HandleRenderUnit:GetHeight()
	fly_eff:setPosition(node_world_pos.x, node_world_pos.y)
	fly_eff:setScale(0.75)

	local scale_to = cc.ScaleTo:create(2.5, 1)
	local move_to = cc.MoveTo:create(2.5, cc.p(hx / 2 - 5, hy / 2 + 68))
	local fade_out = cc.FadeOut:create(1)
	local callback1 = cc.CallFunc:create(function()
		self:OnClickView()
	end)
	local callback2 = cc.CallFunc:create(function()
		if fly_eff then
			fly_eff:removeFromParent()
		end
		fly_eff = nil
	end)
	local action = cc.Sequence:create(cc.Spawn:create(move_to, scale_to), callback1, cc.DelayTime:create(0.5), fade_out, callback2)
	fly_eff:runAction(action)
end

function ForeshowBaseView:OnClickView()
	if self.cur_foreshow_obj and self.cur_foreshow_obj.click_func then
		self.cur_foreshow_obj.click_func()
	end
end
