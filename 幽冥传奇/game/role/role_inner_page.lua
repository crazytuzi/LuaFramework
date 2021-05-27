--角色内功页面
RoleInnerPage = RoleInnerPage or BaseClass()


function RoleInnerPage:__init()
	self.view = nil
end	

function RoleInnerPage:__delete()

	self:RemoveEvent()
	self.inner_eff = nil
	if self.inner_progressbar then
		self.inner_progressbar:DeleteMe()
		self.inner_progressbar = nil
	end

	if self.inner_lv_numBar then
		self.inner_lv_numBar:DeleteMe()
		self.inner_lv_numBar = nil
	end

	self.view = nil
end	

--初始化页面接口
function RoleInnerPage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self.view.node_t_list.btn_inner_uplevel.node:addClickEventListener(BindTool.Bind1(self.OnUpLevelInner, self))
	if not self.inner_progressbar then
		self.inner_progressbar = ProgressBar.New()
		self.inner_progressbar:SetView(self.view.node_t_list.prog9_role_inner.node)
		self.inner_progressbar:SetTotalTime(1)
		self.inner_progressbar:SetTailEffect(991, nil, true)
		self.inner_progressbar:SetEffectOffsetX(-20)
		self.inner_progressbar:SetPercent(0)
	end
	self:InitEvent()
	if not self.inner_lv_numBar then
		self.inner_lv_numBar = NumberBar.New()
		self.inner_lv_numBar:SetRootPath(ResPath.GetCommonPath("num_100_"))
		self.inner_lv_numBar:SetPosition(view.ph_list.ph_lev.x, view.ph_list.ph_lev.y)
		self.inner_lv_numBar:SetGravity(NumberBarGravity.Center)
		self.inner_lv_numBar:SetSpace(-4)
		self.view.node_t_list.layout_inner.node:addChild(self.inner_lv_numBar:GetView(), 300, 300)
	end
	
	
	self.isUpdateBar = false
	
end	

--初始化事件
function RoleInnerPage:InitEvent()
	if self.role_data_event then return end
	
	self.role_data_event = BindTool.Bind(self.OnRoleAttrChangeCallback, self)
	RoleData.Instance:NotifyAttrChange(self.role_data_event)
end

--移除事件
function RoleInnerPage:RemoveEvent()
	if self.role_data_event then
		RoleData.Instance:UnNotifyAttrChange(self.role_data_event)
		self.role_data_event = nil
	end

	if self.inner_eff_countdown_timer then
		GlobalTimerQuest:CancelQuest(self.inner_eff_countdown_timer)
		self.inner_eff_countdown_timer = nil
	end
end

--更新视图界面
function RoleInnerPage:UpdateData(data)
	for k,v in pairs(data) do
		if k == "all" then
			self:FlushPage()
		end
	end
end	

function RoleInnerPage:FlushPage()
	local inner_level = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_INNER_LEVEL)
	-- self.view.node_t_list.lbl_inner_level.node:setString(inner_level)
	self.inner_lv_numBar:SetNumber(inner_level)
	local inner_level_cfg = InnerData.GetInnerLevelCfg(inner_level)
	local inner_level_cfg_next = InnerData.GetInnerLevelCfg(inner_level + 1)
	local per = 0
	if inner_level_cfg then
		self.view.node_t_list.lbl_inner_value.node:setString(inner_level_cfg[InnerData.INNER_ATTR.INNER_MAX])		--RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_INNER)
		self.view.node_t_list.lbl_inner_jianshang.node:setString(inner_level_cfg[InnerData.INNER_ATTR.JIANSHANG] / 100 .. "%")
	else
		self.view.node_t_list.lbl_inner_value.node:setString(0)
		self.view.node_t_list.lbl_inner_jianshang.node:setString(0)
	end
	if inner_level_cfg_next then
		local inner_exp = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_INNER_EXP)
		local inner_max_exp = inner_level_cfg_next[InnerData.INNER_ATTR.INNER_EXP]
		per = math.min(100, math.floor(inner_exp / inner_max_exp * 100))
		self.view.node_t_list.lbl_role_inner.node:setString(inner_exp .. "/" .. inner_max_exp)
		if self.old_inner_lv and self.old_inner_lv ~= inner_level then
			self.inner_progressbar:SetPercent(0, false)
			self:SetShowInnerEff(35, self.view.ph_list.ph_effe.x, self.view.ph_list.ph_effe.y, 1)
			if self.inner_eff_countdown_timer then
				GlobalTimerQuest:CancelQuest(self.inner_eff_countdown_timer)
			end
			self.inner_eff_countdown_timer = GlobalTimerQuest:AddDelayTimer(function ()
				-- self:SetShowInnerEff(902, 320, 100, 1)
				if per >= 100 then
					InnerCtrl.SendInnerUpReq()
				end
			end, 0.5)
		end
		if not self.isUpdateBar then
			self.inner_progressbar:SetPercent(per, false)
			self.isUpdateBar = true
		else
			self.inner_progressbar:SetPercent(per)
		end
		self.old_inner_lv = inner_level
	else
		self.view.node_t_list.lbl_role_inner.node:setString("")
		self.inner_progressbar:SetPercent(100)
	end
	self.view.node_t_list.btn_inner_uplevel.node:setEnabled(per >= 100)
end

function RoleInnerPage:OnUpLevelInner()
	if IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.OnCrossServerTip)
		return 
	end	
	InnerCtrl.SendInnerUpReq()
end

function RoleInnerPage:SetShowInnerEff(eff_id, x, y, scale, frame_interval)
	scale = scale or 1
	if self.inner_eff == nil then
		self.inner_eff = AnimateSprite:create()
		self.view.node_t_list.layout_inner.node:addChild(self.inner_eff, 3)
	end
	self.inner_eff:setPosition(x, y)
	self.inner_eff:setScale(scale)
	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(eff_id)
	self.inner_eff:setAnimate(anim_path, anim_name, 1, frame_interval or FrameTime.Effect, false)
end

function RoleInnerPage:OnRoleAttrChangeCallback(key, value, old_value)
	if key == OBJ_ATTR.ACTOR_INNER_LEVEL or key == OBJ_ATTR.ACTOR_INNER_EXP then
		self:FlushPage()
	end
end