
DigOreShow = DigOreShow or BaseClass(SceneObj)

local NAME_BOARD_OFFY = 30
function DigOreShow:__init(vo)
	self.obj_type = SceneObjType.DirOreObj
	self.height = 0
	self.show = nil
	self.vo = vo
	self.state = "free"
	self.act_list = {}
end

function DigOreShow:__delete()
	if self.show ~= nil then
		self.show:DeleteMe()
		self.show = nil
	end

	self.act_eff = nil
	self.ui_cfg = nil
	self.ui_node_list = {}
	self.ui_ph_list = {}
	self.act_list = {}
end

function DigOreShow:LoadInfoFromVo()
	self:SetLogicPos(self.vo.pos_x, self.vo.pos_y)

	if nil == self.ui_cfg then
		-- create ui
		local ui_config = ConfigManager.Instance:GetUiConfig("scene_obj_ui")
		for k, v in pairs(ui_config) do
			if v.n == "layer_dig_show" then
				self.ui_cfg = v
				break
			end
		end

		self.ui_node_list = {}
		self.ui_ph_list = {}
		XUI.GeneratorUI(self.ui_cfg, nil, nil, self.ui_node_list, nil, self.ui_ph_list)
	end

	if nil == self.show then
		local ph = self.ui_ph_list.ph_item_info_panel
		self.show = DigOreShowRender.New()
		self.show:SetUiConfig(ph, true)
		self.show:SetData(self.vo)
		self.show:GetView():setAnchorPoint(0.5, 0)
		self.model:AttachNode(self.show:GetView(), cc.p(0, 0), GRQ_SCENE_OBJ, InnerLayerType.Name)
	end
end

function DigOreShow:InitVo()
	self.vo.quality = 0
	self.vo.start_dig_time = 0
	self.vo.role_name = ""
	self.vo.gilde_name = ""
	self:UpdateShow()
end

function DigOreShow:UpdateShow()
	if SceneModal.Instance and SceneModal.Instance:IsInPk() then return end
	self.show:SetData(self.vo)
	local state = self.vo.role_name ~= "" and "dig" or "free"
	if state ~= self.state then
		if state == "dig"  then
			if nil == self.act_list.role or nil == self.act_list.wuqi then
				--创建人物动画
				local ph = self.ui_ph_list.ph_item_info_panel
				local role_animate = RenderUnit.CreateAnimSprite(nil, nil, nil, nil)
				role_animate:setScale(1.1)
				role_animate:setPosition(ph.x, ph.y)
				self.model:AttachNode(role_animate, cc.p(0, 0), GRQ_SCENE_OBJ, InnerLayerType.Name)
				self.act_list.role = role_animate

				local wuqi_animate = RenderUnit.CreateAnimSprite(nil, nil, nil, nil)
				wuqi_animate:setScale(1.1)
				wuqi_animate:setPosition(ph.x, ph.y)
				self.model:AttachNode(wuqi_animate, cc.p(0, 0), GRQ_SCENE_OBJ, InnerLayerType.Name)
				self.act_list.wuqi = wuqi_animate
			end

			local res_cfg = MiningActConfig.ClientResCfg[self.vo.quality]
			local anim_path2, anim_name2 = ResPath.GetRoleAnimPath(res_cfg.res_id, "atk1", MiningActConfig.miningPos[self.vo.slot].dir_num)
			self.act_list.role:setAnimate(anim_path2, anim_name2, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
			local anim_path, anim_name = ResPath.GetRoleAnimPath(res_cfg.wuqi_res_id, "atk1", MiningActConfig.miningPos[self.vo.slot].dir_num)
			self.act_list.wuqi:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
		else
			local anim_path, anim_name = ResPath.GetEffectUiAnimPath(999)
			self.act_eff:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
			self.act_eff:setScale(0.8)
		end
	end

	self.state = state

	self.act_eff:setVisible(state == "free")
	if self.act_list.role or self.act_list.wuqi then
		self.act_list.role:setVisible(state == "dig")
		self.act_list.wuqi:setVisible(state == "dig")
	end
end

function DigOreShow:InitAnimation()
	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(999)
	if nil == self.act_eff then
		self.act_eff = RenderUnit.CreateAnimSprite(anim_path, anim_name, nil, nil)
		self.act_eff:setScale(0.8)
		self.act_eff:setPosition(0, 0)
		self.model:AttachNode(self.act_eff, cc.p(0, 0), GRQ_SCENE_OBJ, InnerLayerType.Select)
	end
end

function DigOreShow:IsClick(x, y)
	return self.real_pos.x - 30 <= x and x <= self.real_pos.x + 30 and self.real_pos.y - 30 <= y and y <= self.real_pos.y + 30
end

function DigOreShow:OnClick()

end

function DigOreShow:SetHeight(height)
	self.height = height
end

------------------------------------------------------------
-- 其它商店物品配置
------------------------------------------------------------
DigOreShowRender = DigOreShowRender or BaseClass(BaseRender)
function DigOreShowRender:__init()
	self.item_cell = nil
end

function DigOreShowRender:__delete()
	if self.alert then
		self.alert:DeleteMe()
		self.alert = nil
	end

	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	if nil ~= self.eh_move_end then
		GlobalEventSystem:UnBind(self.eh_move_end)
		self.eh_move_end = nil
	end

	self:DeleteResumeTimer()
end

function DigOreShowRender:CreateChild()
	BaseRender.CreateChild(self)
	
	self.eh_move_end = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_MOVE_END, function ()
		local mainrole = Scene.Instance:GetMainRole()
		local role_pos_x, role_pos_y = mainrole:GetLogicPos()

		if self.data.role_name == "" and role_pos_x == self.data.pos_x and role_pos_y == self.data.pos_y then
			if not ExperimentCtrl.Instance:IsNeedOpenAwardView() then	
				ViewManager.Instance:GetView(ViewDef.DigOreAccount):SetData(self.data)
				ViewManager.Instance:OpenViewByDef(ViewDef.DigOreAccount)
			else
				ExperimentCtrl.Instance:SetCurrDigInfo(self.data)
			end
		end
	end)

	XUI.AddClickEventListener(self.node_tree.btn_get.node, function ()
		ViewManager.Instance:GetView(ViewDef.DigOreRob):SetData(self.data)
		ViewManager.Instance:OpenViewByDef(ViewDef.DigOreRob)
	end)
end

function DigOreShowRender:OnFlush()
	if nil == self.data then return end
	local playername = Scene.Instance:GetMainRole():GetName()
	local is_show_rob = playername ~= self.data.role_name and self.data.role_name ~= ""
	local is_self = self.data.role_name ~= "" and playername == self.data.role_name
	self.node_tree.btn_get.node:setVisible(is_show_rob)
	self.node_tree.img_lbl_1.node:setVisible(is_show_rob)
	self.node_tree.lbl_time_tip.node:setVisible(is_show_rob)
	
	self.node_tree.role_name.node:setString(self.data.role_name ~= "" and self.data.role_name or "空闲矿位")

	--倒计时
	self:FlushResumeTimer()
end

function DigOreShowRender:TimerFunc()
	local time = self.data.start_dig_time + MiningActConfig.finTimes - TimeCtrl.Instance:GetServerTime()
	if time <= 0 then
		self:DeleteResumeTimer()
	else
		self.node_tree.lbl_time_tip.node:setString(TimeUtil.FormatSecond(time))
	end
end

function DigOreShowRender:FlushResumeTimer()
	local is_diging = self.data.start_dig_time + MiningActConfig.finTimes - TimeCtrl.Instance:GetServerTime() > 0
	if nil == self.resume_timer and is_diging then
		self.resume_timer = GlobalTimerQuest:AddRunQuest(function ()
			self:TimerFunc()
		end, 1)
		self:TimerFunc()
	end
end

function DigOreShowRender:DeleteResumeTimer()
	if self.resume_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.resume_timer)
		self.resume_timer = nil
	end
end