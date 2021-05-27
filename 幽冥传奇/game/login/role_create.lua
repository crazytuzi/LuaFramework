RoleCreateView = RoleCreateView or BaseClass(BaseView)
ROLE_CREATE_FONT_SIZE = 28

ROLE_MODEL_SHOW_EFFECT = {
	[0] = {101, 103, 105},
	[1] = {102, 104, 106}
}

ROLE_MODEL_POS_SCALE_CFG = {
	-- 男性（左右、上下、大小）
	[0] = {
		[1] = {-25, -45, 1, 0.10},		-- 战士
		[2] = {20, 50, 1.3, 0.10},			-- 法师
		[3] = {0, 65, 1.3, 0.10},			-- 道士
	},
	-- 女性
	[1] = {
		[1] = {-15, -50, 1, 0.10},			-- 战士
		[2] = {20, 100, 1.45, 0.10},		-- 法师
		[3] = {75, 65, 1.35, 0.10},			-- 道士
	},
}

--创建角色
function RoleCreateView:__init()
	self.close_mode = CloseMode.CloseDestroy
	self.zorder = COMMON_CONSTS.ZORDER_LOGIN
	self.is_async_load = false

	self.texture_path_list[1] = 'res/xui/role_create.png'

	self.config_tab = {
		{"role_create_ui_cfg", 3, {0}},
		{"role_create_ui_cfg", 2, {0}},
		{"role_create_ui_cfg", 1, {0}},
	}

	self.last_send_create_time = 0
	self.prof_select_list = {}
end

function RoleCreateView:__delete()
end

function RoleCreateView:ReleaseCallBack()
	for k, v in pairs(self.prof_select_list) do
		v:DeleteMe()
	end
	self.prof_select_list = {}
	-- self.painting_0 = nil
	-- self.painting_1 = nil
end

function RoleCreateView:LoadCallBack()
	local screen_w = HandleRenderUnit:GetWidth()
	local screen_h = HandleRenderUnit:GetHeight()

	self.root_node:setContentWH(screen_w, screen_h)
	self.layout_right = self.node_tree.layout_right
	self.layout_left = self.node_tree.layout_left
	self.layout_center = self.node_tree.layout_center
	self.edit_name = self.node_tree.layout_center.edit_name_1.node

	local bg = XUI.CreateImageView(screen_w / 2, screen_h / 2, ResPath.GetBigPainting("select_role_bg", true), true)
	bg:setScale(1) 
	self.root_node:addChild(bg)

	self.layout_left.node:setAnchorPoint(0, 1)
	self.layout_center.node:setAnchorPoint(0.5, 0)
	self.layout_right.node:setAnchorPoint(1, 1)
	self.layout_left.node:setPosition(0, screen_h)
	self.layout_center.node:setPosition(screen_w/2+218, 5)
	self.layout_right.node:setPosition(screen_w, screen_h)
	self.layout_center.node:setLocalZOrder(101)
	self.layout_left.node:setLocalZOrder(100)

	self.edit_name:setFontName(COMMON_CONSTS.FONT)
	self.edit_name:setFontSize(ROLE_CREATE_FONT_SIZE)
	self.edit_name:setFontColor(COLOR3B.G_W2)
	self.edit_name:registerScriptEditBoxHandler(BindTool.Bind2(ChatData.ExamineEditNameNum, self.edit_name, 12))

	self.img_desc = self.layout_right.img_desc.node
	self.desc_x, self.desc_y = self.img_desc:getPosition()
	self.img_desc2 = XUI.CreateImageView(self.desc_x + 300, self.desc_y, ResPath.GetRoleCreate("prof_desc_1"), true)
	self.layout_right.node:addChild(self.img_desc2, -1)
	self:SetDesVisible(false)

	self.prof_index = GameEnum.ROLE_PROF_1
	self.role_sex = GameEnum.MALE
	self.role_name = ""

	self.role_create_view_is_show = false

	self.turn_queue = {}

	self.name_cfg = ConfigManager.Instance:GetAutoConfig("randname_auto").random_name[1]

	self:CreateProfAndSexSelect()
	-- self:CreateRoleBigImg()
	self:CreateRoleEffChess()

	self:RigisterRoleCreateEvents()
end

function RoleCreateView:OpenRoleCreate()
	self:SetCreateVisible(true)
	self:ResetRolePosition()
	self:RandomName()
	self:SetDesVisible(true)
end

function RoleCreateView:CreateProfAndSexSelect()
	self.prof_select_list = {}
	local prof_render_ph
	for i = GameEnum.ROLE_PROF_1, GameEnum.ROLE_PROF_3 do
		prof_render_ph = self.ph_list["ph_prof_select_render" .. i]
		local prof_render = ProfSelectRender.New(self, i)
		prof_render:SetUiConfig(prof_render_ph, false)
		prof_render:Flush()
		prof_render:GetView():setVisible(false)
		prof_render:SetPosition(prof_render_ph.x, prof_render_ph.y)
		prof_render:AddClickEventListener(BindTool.Bind(self.ProfChange, self, i, false), false)
		self.layout_left.node:addChild(prof_render:GetView(), 99)

		self.prof_select_list[i] = prof_render
	end

	-- for i = 0, 1 do
	-- 	local select_sex_node = self.node_t_list.layout_center["layout_sex_" .. i].node
	-- 	select_sex_node:setVisible(false)
	-- 	local x, y = select_sex_node:getPosition()
	-- 	select_sex_node:setPosition(x + (-150)*i, y)
	-- 	select_sex_node:setScale(0.8)
	-- 	XUI.AddClickEventListener(select_sex_node, BindTool.Bind(self.SexHandler, self, i), false)
	-- end
end

-- 人物选择特效创建
function RoleCreateView:CreateRoleEffChess()
	-- local painting_cfg = {0, 0, 1}
	-- local anim_path, anim_name = ResPath.GetEffectUiAnimPath(ROLE_MODEL_SHOW_EFFECT[0][1])
	-- local painting_frametime = 0.18
	-- self.painting_0:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, painting_frametime, false)
	-- self.painting_0:setPosition(0, 420)



	-- painting_cfg = ROLE_MODEL_POS_SCALE_CFG[1] and ROLE_MODEL_POS_SCALE_CFG[1][1] or {0, 0, 1}
	-- anim_path, anim_name = ResPath.GetEffectUiAnimPath(ROLE_MODEL_SHOW_EFFECT[1][1])

	-- self.painting_1:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, painting_frametime, false)
	-- self.painting_1:setPosition(450, 420)

	local pos_x, pos_y = self.node_t_list.layout_left.layout_sex_0.node:getPosition()
	self.eff_0 = RenderUnit.CreateEffect(101, self.node_t_list.layout_left.layout_sex_0.node, 10, nil, nil, pos_x-650, pos_y-30)
	-- XUI.AddClickEventListener(self.node_t_list.layout_left.layout_sex_0.node, BindTool.Bind(self.SexHandler, self, 0), false)

	pos_x, pos_y = self.node_t_list.layout_left.layout_sex_1.node:getPosition()
	self.eff_1 = RenderUnit.CreateEffect(102, self.node_t_list.layout_left.layout_sex_1.node, 10, nil, nil, pos_x-640, pos_y-30)
	-- XUI.AddClickEventListener(self.node_t_list.layout_left.layout_sex_1.node, BindTool.Bind(self.SexHandler, self, 1), false)

	XUI.AddClickEventListener(self.node_t_list.layout_center.layout_sex_0.node, BindTool.Bind(self.SexHandler, self, 0), false)
	XUI.AddClickEventListener(self.node_t_list.layout_center.layout_sex_1.node, BindTool.Bind(self.SexHandler, self, 1), false)

end

function RoleCreateView:CreateRoleBigImg()
	if nil == self.painting_0 then
		self.painting_0 = AnimateSprite:create()
		self.layout_center.node:addChild(self.painting_0, 0)
	end

	if nil == self.painting_1 then
		self.painting_1 = AnimateSprite:create()
		self.layout_center.node:addChild(self.painting_1, 0)
	end
end

function RoleCreateView:ProfChange(prof, ignore)
	-- if self.prof_index ~= prof or ignore then
	-- 	self.prof_index = prof
	-- 	self:FlushView()
	-- end
end

function RoleCreateView:SexHandler(sex)
	if self.role_sex ~= sex then
		self.role_sex = sex
		self:FlushView()
	end
end

function RoleCreateView:RigisterRoleCreateEvents()
	local btn_size = self.layout_center.layout_begin_btn.node:getContentSize()
	RenderUnit.CreateEffect(1138, self.layout_center.layout_begin_btn.node, 99, nil, nil, btn_size.width / 2+10, btn_size.height / 2+25)
	XUI.AddClickEventListener(self.layout_center.layout_return_btn.node, BindTool.Bind(self.ReturnToLogin, self), true)
	XUI.AddClickEventListener(self.layout_center.layout_begin_btn.node, BindTool.Bind(self.EnterCreateRole, self), true, 1)
	XUI.AddClickEventListener(self.layout_center.btn_random.node, BindTool.Bind(self.RandomName, self))
end

function RoleCreateView:ReturnToLogin()
	self:SetCreateVisible(false)

	-- self.painting:setVisible(false)

	self.prof_index = GameEnum.ROLE_PROF_1
	self.role_sex = GameEnum.MALE
	self.role_name = ""
	self.edit_name:setText("")

	self.action_list = {}

	self:SetDesVisible(false)
	local user_vo = GameVoManager.Instance:GetUserVo()
	if next(user_vo:GetRoleList()) then
		LoginController.Instance:DoOpenCombineSelectRoleView()
	else
		LoginController.Instance:CreateRoleViewReturnLogin()
	end
end

function RoleCreateView:SetCreateVisible(is_show)
	self.role_create_view_is_show = is_show
	LoginController.Instance.loginview.node_tree.layout_bg.node:setVisible(not is_show)
	LoginController.Instance.loginview.node_tree.layout_bg.layout_select_sever_list.node:setVisible(not is_show)
	LoginController.Instance.loginview.node_tree.layout_bg.layout_server_recommend.node:setVisible(not is_show)
	LoginController.Instance.loginview.node_tree.layout_bg.layout_all.node:setVisible(not is_show)
	LoginController.Instance.loginview:SetLogoVisible(not is_show)
	self.root_node:setVisible(is_show)
end

function RoleCreateView:RoleCreateViewIsShow()
	return self.role_create_view_is_show
end

function RoleCreateView:ResetRolePosition()
	self.role_sex = math.random(0, 1)
	-- self:ProfChange(math.random(1, 3), true)
	self:FlushView()
end

function RoleCreateView:SetDesVisible(is_show)
	self.img_desc:setVisible(is_show)
	self.img_desc2:setVisible(is_show)
end

function RoleCreateView:FlushView()
	self:SetDesVisible(true)
	self:RandomName()

	-- for k, v in pairs(self.prof_select_list) do
	-- 	v:SetSelect(k == self.prof_index)
	-- end
	-- self.eff_0:setColor(self.role_sex == 0 and COLOR3B.WHITE or COLOR3B.GRAY2)
	-- self.eff_1:setColor(self.role_sex == 1 and COLOR3B.WHITE or COLOR3B.GRAY2)
	self.eff_0:setVisible(self.role_sex == 0)
	self.eff_1:setVisible(self.role_sex == 1)
	for i = 0, 1 do
		local select_sex_node = self.node_t_list.layout_center["layout_sex_" .. i].node
		local is_select = self.role_sex == i


		--图片选择特效
		if nil == select_sex_node.select_effect then
			select_sex_node.select_effect = XUI.CreateImageView(47.5, 46, ResPath.GetCommon("img9_156"))
			select_sex_node:addChild(select_sex_node.select_effect, -1)
		end
		select_sex_node.select_effect:setVisible(is_select)
		-- XUI.MakeGlow(select_sex_node, is_select)
	end

	local screen_w = HandleRenderUnit:GetWidth()
	local screen_h = HandleRenderUnit:GetHeight()

	-- 职业介绍
	if self.last_prof_index ~= self.prof_index then
		if nil ~= self.last_prof_index then
			self.img_desc:loadTexture(ResPath.GetRoleCreate("prof_desc_" .. self.prof_index))
			self.img_desc:setPositionX(self.desc_x + 300)
			self.img_desc2:loadTexture(ResPath.GetRoleCreate("prof_desc_" .. self.last_prof_index))
			self.img_desc2:setPositionX(self.desc_x)

			self.img_desc:stopAllActions()
			self.img_desc:setOpacity(0)
			local act = cc.Spawn:create(cc.MoveTo:create(0.5, cc.p(self.desc_x, self.desc_y)), cc.FadeIn:create(0.5))
		    local actionseq = cc.Sequence:create(act, cc.CallFunc:create(function()
			end))
		    self.img_desc:runAction(actionseq)

		    self.img_desc2:setScale(1)
		    self.img_desc2:stopAllActions()
			self.img_desc2:setOpacity(255)
			local act = cc.Spawn:create(cc.MoveTo:create(0.5, cc.p(self.desc_x + 300, self.desc_y)), cc.FadeOut:create(0.5))
		    local actionseq = cc.Sequence:create(cc.ScaleTo:create(0.15, 0.85), act, cc.CallFunc:create(function()
			end))
		    self.img_desc2:runAction(actionseq)

			self.last_prof_index = self.prof_index
		else
			self.img_desc:loadTexture(ResPath.GetRoleCreate("prof_desc_" .. self.prof_index))
			self.last_prof_index = self.prof_index
		end
	end

	-- 人物模型
	-- local painting_cfg = ROLE_MODEL_POS_SCALE_CFG[self.role_sex] and ROLE_MODEL_POS_SCALE_CFG[self.role_sex][self.prof_index] or {0, 0, 1}
	-- local normal_scale = painting_cfg[3] or 1
	-- self.painting:stopAllActions()
	-- local call_func1 = cc.CallFunc:create(function()
		-- local anim_path, anim_name = ResPath.GetEffectUiAnimPath(ROLE_MODEL_SHOW_EFFECT[self.role_sex][self.prof_index])
		-- local painting_frametime = painting_cfg[4] or 0.18
		-- self.painting:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, painting_frametime, false)		
	-- end)
	-- local call_func2 = cc.CallFunc:create(function()
		-- self.painting:setPosition((painting_cfg[1] or 0) + (550), (painting_cfg[2] or 0) + (420))
	-- 	self.painting:setScale(0.8)
	-- 	self.painting:setOpacity(0)
	-- 	self.painting:setVisible(true)
	-- end)
	-- local scale_fade_in = cc.Spawn:create(cc.ScaleTo:create(0.2, normal_scale), cc.FadeIn:create(0.2))
	-- self.painting:runAction(cc.Sequence:create(cc.FadeOut:create(0.1), call_func1, cc.DelayTime:create(0.2), call_func2, scale_fade_in))

	-- 刷新人物职业、性别render
	-- for k, v in pairs(self.prof_select_list) do
	-- 	v:Flush()
	-- end
end

function RoleCreateView:RandomName()
	self.role_name = ""
	local front = ""
	local middle = ""
	local back = ""

	--前缀
	local random_num_front = math.random(0,1)
	if 0 == random_num_front and #self.name_cfg.common_first > 0 then--采用公共前缀
		local index = math.random(1,#self.name_cfg.common_first)
		if nil ~= self.name_cfg.common_first[index] then
			front = self.name_cfg.common_first[index]
		end
	else
		if 0 == self.role_sex and #self.name_cfg.male_first > 0 then --男
			local index = math.random(1,#self.name_cfg.male_first)
			if nil ~= self.name_cfg.male_first[index] then
				front = self.name_cfg.male_first[index]
			end
		elseif #self.name_cfg.female_first > 0 then -- 女
			local index = math.random(1,#self.name_cfg.female_first)
			if nil ~= self.name_cfg.female_first[index] then
				front = self.name_cfg.female_first[index]
			end
		end
	end

	--中间
	if #self.name_cfg.common_middle > 0 then
		local middle_index = math.random(1,#self.name_cfg.common_middle)
		if nil ~= self.name_cfg.common_middle[middle_index] then
			middle = self.name_cfg.common_middle[middle_index]
		end
	end

	--后缀
	local random_num_back = math.random(0,1)
	if 0 == random_num_back and #self.name_cfg.common_last > 0 then--采用公共后缀
		local index = math.random(1,#self.name_cfg.common_last)
		if nil ~= self.name_cfg.common_last[index] then
			back = self.name_cfg.common_last[index] 
		end
	else
		if 0 == self.role_sex and #self.name_cfg.male_last > 0 then --男
			local index = math.random(1,#self.name_cfg.male_last)
			if nil ~= self.name_cfg.male_last[index] then
				back = self.name_cfg.male_last[index]
			end
		elseif #self.name_cfg.female_last > 0 then -- 女
			local index = math.random(1,#self.name_cfg.female_last)
			if nil ~= self.name_cfg.female_last[index] then
				back = self.name_cfg.female_last[index]
			end
		end
	end

	--判断名字是否在六个字内
	local final = ""
	if front ~= "" or back ~= "" then
		final = front .. middle .. back
		if string.len(final) >= 16 then
			self:RandomName()
		else
			-- 增加敏感词过滤
			final = ChatFilter.Instance:Filter(final)
			
			self.edit_name:setText(final)
		end
	else
		self:RandomName()
	end
end

function RoleCreateView:EnterCreateRole()
	self.role_name = self.edit_name:getText()
	local len = string.len(self.role_name)
	if len <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Login.EditName, true)
		return
	end

	if AdapterToLua:utf8FontCount(self.role_name) > 12 or AdapterToLua:utf8CharCount(self.role_name) > 6 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Login.NameToLong, true)
		return
	end
	
	if ChatFilter.Instance:IsIllegal(self.role_name, true) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.IllegalContent, true)
		return
	end

	local i, j = string.find(self.role_name, "*")
	if i ~= nil and j ~= nil then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.IllegalContent, true)
		return
	end
	local qukong_text = string.gsub(self.role_name, "%s", "")
	local qukong_text_len = string.len(qukong_text)  
	--判断输入的名字是否带空格	
	if qukong_text_len ~= len then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.IllegalContent, true)
		return 
	end

	if GLOBAL_CONFIG.param_list.switch_list and GLOBAL_CONFIG.param_list.switch_list.open_CharacterCreation ~= nil and GLOBAL_CONFIG.param_list.switch_list.open_CharacterCreation == false then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.NotCreateRoleTip, true)
		return
	end	
	
	if Status.NowTime > self.last_send_create_time + 1 then
		MainProber:Step(MainProber.STEP_SERVER_CREATE_ROLE_BEG, self.role_name, self.prof_index, self.role_sex)
		if MainProber.Step2 then 
			MainProber.role_name = mime.b64(self.role_name)
			MainProber:Step2(1000, MainProber.user_id, MainProber.server_id, MainProber.role_name) 
		end

		self.last_send_create_time = Status.NowTime
        local cleate_role_limint = GLOBAL_CONFIG.param_list.create_role_limit
        if 0 == cleate_role_limint or nil == cleate_role_limint then
		    LoginController.Instance:SendCreateRole(self.role_name, self.prof_index, self.role_sex)
        else
            SysMsgCtrl.Instance:ErrorRemind(Language.Login.CreateRoleLimit, true)
        end
	end
end

--------------------------------------------------
-- 选择职业render
--------------------------------------------------
ProfSelectRender = ProfSelectRender or BaseClass(BaseRender)
function ProfSelectRender:__init(ctrl, prof_index)
	self.ctrl = ctrl
	self.prof_index = prof_index
	-- self.is_select = false
	self.ignore_data_to_select = true
end

function ProfSelectRender:__delete()
end

function ProfSelectRender:CreateChild()
	BaseRender.CreateChild(self)

	-- self.select_effect = RenderUnit.CreateEffect(1206, self.view, 99)
	-- self.select_effect:setScale(1)
	-- self.select_effect:setVisible(self.is_select)

	self.node_tree.img_icon.node:loadTexture(ResPath.GetRoleCreate(string.format("prof_img_%d", self.prof_index)))

end

function ProfSelectRender:OnFlush()
	-- local is_select = self.is_select
	-- self.is_select = self.ctrl.prof_index == self.prof_index

	-- if is_select ~= self.is_select then
	-- 	if self.is_select then
	-- 		self.select_effect:stopAllActions()
	-- 		self.select_effect:setOpacity(0)
	-- 		self.select_effect:setScale(2)
	-- 		self.select_effect:setVisible(true)
	-- 		local scale_to = cc.Spawn:create(cc.ScaleTo:create(0.2, 1), cc.FadeIn:create(0.2))
	-- 	    local actionseq = cc.Sequence:create(scale_to, cc.CallFunc:create(function()  end))
	-- 	    self.select_effect:runAction(actionseq)
	-- 	else
	-- 		self.select_effect:stopAllActions()
	-- 		self.select_effect:setScale(1)
	-- 		self.select_effect:setVisible(true)
	-- 		local scale_to = cc.Spawn:create(cc.ScaleTo:create(0.1, 0), cc.FadeOut:create(0.1))
	-- 	    local actionseq = cc.Sequence:create(scale_to, cc.CallFunc:create(function()
	-- 	    	self.select_effect:setOpacity(255)
	-- 			self.select_effect:setVisible(false)
	--     	end))
	-- 	    self.select_effect:runAction(actionseq)
	-- 	end
	-- end
end

function ProfSelectRender:OnSelectChange(is_select)
	if self.node_tree.img_icon then
		local sprite = self.node_tree.img_icon.node:getRenderer()
		XUI.MakeGlow(sprite, self:IsSelect())
	end
end

--图片选择特效
function ProfSelectRender:CreateSelectEffect()
	-- local size = self.view:getContentSize()
	-- local y = self.prof_index == 2 and size.height / 2 + 10 or size.height / 2
	-- self.select_effect = XUI.CreateImageView(size.width / 2, y, ResPath.GetRoleCreate("select_effect_" .. self.prof_index))
	-- self.view:addChild(self.select_effect, -1)
end
