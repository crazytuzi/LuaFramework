--角色技能页面
RoleSkillPage = RoleSkillPage or BaseClass()


function RoleSkillPage:__init()
	self.view = nil
end	

function RoleSkillPage:__delete()
	self:RemoveEvent()

	if self.skill_list then
		self.skill_list:DeleteMe()
		self.skill_list = nil
	end
	if self.play_effect ~= nil then
		self.play_effect:setStop()
		self.play_effect = nil 
	end
	
	self.select_skill = nil
	self.select_skill_id = nil
	self.view = nil

	ClientCommonButtonDic[CommonButtonType.ROLE_SKILL_GRID] = nil
end	

--初始化页面接口
function RoleSkillPage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self:CreateSkillList()
	self.select_skill_index = 1

	self:InitEvent()
	
end	

--初始化事件
function RoleSkillPage:InitEvent()
	
	XUI.AddClickEventListener(self.view.node_t_list.quick_set_btn.node,BindTool.Bind(self.OnQuickSet,self))
	XUI.AddClickEventListener(self.view.node_t_list.senior_preview_btn.node,BindTool.Bind(self.OnSeniorPreview,self))
	XUI.AddClickEventListener(self.view.node_t_list.quest_btn.node,BindTool.Bind(self.OnQuest,self))
	self.role_skill_exp_change = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_SKILL_EXP_CHANGE,BindTool.Bind1(self.RoleSkillExpChange, self))
end

--移除事件
function RoleSkillPage:RemoveEvent()
	if self.role_skill_exp_change then
		GlobalEventSystem:UnBind(self.role_skill_exp_change)
		self.role_skill_exp_change = nil
	end
end

function RoleSkillPage:RoleSkillExpChange()
	-- local item = self.skill_list:GetSelectItem()
	-- local node = item:GetEffectPos()
	-- local pos = node:convertToWorldSpace(cc.p(0, 0))
	-- self:SetPlayEffect(3, pos.x, pos.y -10)
	self:FlushSkillList()
end

function RoleSkillPage:SetPlayEffect(effct_id, x, y)
	if self.play_effect == nil then
		self.play_effect = AnimateSprite:create()
		self.view.node_t_list.layout_role_skill.node:addChild(self.play_effect,999)
	end	
	self.play_effect:setPosition(x, y)
	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(effct_id)
	self.play_effect:setAnimate(anim_path, anim_name, 1, FrameTime.Effect, false)
end


function RoleSkillPage:OnQuest()
	DescTip.Instance:SetContent(Language.Role.SkillHelpContent,Language.Role.SkillHelpTitle)
end	

function RoleSkillPage:OnQuickSet()
	self.view:ShowIndex(TabIndex.role_skill_select)
end	

function RoleSkillPage:OnSeniorPreview()
	ViewManager.Instance:Open(ViewName.RoleSkillPreviewPage)
	ViewManager.Instance:FlushView(ViewName.RoleSkillPreviewPage, 0, "preview", {self.skill_preview_data})
end

function RoleSkillPage:FlushSkillList()
	local n_list, s_list = SkillData.Instance:GetShowSkillList()
	self.skill_list:SetDataList(n_list)
end
--更新视图界面
function RoleSkillPage:UpdateData(data)
	for k,v in pairs(data) do
		if k == "all" then
			
			self:FlushSkillList()
			self.skill_list:SelectIndex(self.select_skill_index)
			
		elseif k == "skill_auto" then
			local n_list, s_list = SkillData.Instance:GetShowSkillList()
			
			local cell = self.skill_list:GetItemAt(self.select_skill_index)
			if cell then
				cell:SetData(n_list[self.select_skill_index])
			end
			
		end
	end
end	

function RoleSkillPage:CreateSkillList()
	if self.skill_list then
		self.skill_list:GetView():removeFromParent()
		self.skill_list:DeleteMe()
		self.skill_list = nil
	end
	

	local ph = self.view.ph_list.ph_skill_list
	self.skill_list = ListView.New()
	self.skill_list:Create(ph.x, ph.y, ph.w, ph.h, nil, SkillListRender, nil, nil, self.view.ph_list.ph_skill_item)
	self.skill_list:GetView():setAnchorPoint(0, 0)
	self.view.node_t_list.layout_role_skill.node:addChild(self.skill_list:GetView(), 100)
	self.skill_list:SetItemsInterval(5)
	self.skill_list:SetMargin(3)
	self.skill_list:SetJumpDirection(ListView.Top)
	self.skill_list:SetSelectCallBack(BindTool.Bind1(self.SelectSkillCallBack, self))
	self.n_size = self.skill_list:GetView():getContentSize()
	
	ClientCommonButtonDic[CommonButtonType.ROLE_SKILL_GRID] = self.skill_list
end

function RoleSkillPage:SelectSkillCallBack(item)
	if nil == item or nil == item:GetData() then return end
	local data = item:GetData()
	
	self.select_skill_index = item:GetIndex()
	self.select_skill_id = data.id
	self.skill_preview_data = data
	
	-- if ViewManager.Instance:IsOpen(ViewName.RoleSkillPreviewPage) then
	-- 	ViewManager.Instance:FlushView(ViewName.RoleSkillPreviewPage, 0, "preview", {self.skill_preview_data})
	-- end
	
	local skill_info = SkillData.Instance:GetSkill(data.id)
	self.view.node_t_list.lbl_cur_skill_name.node:setString(data.name)
	self.view.node_t_list.lbl_next_lv_skill_name.node:setString(data.name)
	
	--是否技能信息
	if skill_info then
		local cur_level = SkillData.Instance:GetCurSkillLevel(data.id)
		
		local lv_cfg = SkillData.GetSkillLvCfg(data.id, cur_level) 

		self.view.node_t_list.lbl_cur_skill_lv.node:setString("Lv." .. cur_level)

		if lv_cfg then
			RichTextUtil.ParseRichText(self.view.node_t_list.rich_cur_skill_content.node, lv_cfg.desc)

			local mp = 0
			for k,v in pairs(lv_cfg.spellConds) do
				if v.cond == SkillData.SKILL_CONDITION.MP then
					mp = v.value
				end
			end

			self.view.node_t_list.lbl_skill_mp_cost.node:setString(mp > 0 and mp or Language.Common.No)
			self.view.node_t_list.lbl_skill_cool_sec.node:setString(string.format(Language.Role.XXMiao,lv_cfg.cooldownTime * 0.001))

		end	
		local n_lv_cfg = SkillData.GetSkillLvCfg(data.id, cur_level + 1)
		if n_lv_cfg then

			self.view.node_t_list.img_top_lv.node:setVisible(false)
			self.view.node_t_list.layout_next_lv_skill_info.node:setVisible(true)
			self.view.node_t_list.lbl_next_skill_lv.node:setString("Lv." .. (cur_level + 1))
			
			RichTextUtil.ParseRichText(self.view.node_t_list.rich_next_lv_skill_content.node, n_lv_cfg.desc)
			local n_lv = 0
			for k,v in pairs(n_lv_cfg.trainConds) do
				if v.cond == SkillData.SKILL_CONDITION.LEVEL then
					n_lv = v.value
				end
			end
			local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
			self.view.node_t_list.lbl_n_skill_lv_need.node:setVisible(level < n_lv)
			self.view.node_t_list.lbl_n_skill_lv_need.node:setString(string.format(Language.Common.LvCond, n_lv))
			local n_mp = 0
			for k,v in pairs(n_lv_cfg.spellConds) do
				if v.cond == SkillData.SKILL_CONDITION.MP then
					n_mp = v.value
				end
			end
			self.view.node_t_list.lbl_next_lv_skill_mp_cost.node:setString(n_mp > 0 and n_mp or Language.Common.No)
			self.view.node_t_list.lbl_skill_next_lv_cool_sec.node:setString(string.format(Language.Role.XXMiao, n_lv_cfg.cooldownTime * 0.001))
		else
			self.view.node_t_list.img_top_lv.node:setVisible(true)
			self.view.node_t_list.layout_next_lv_skill_info.node:setVisible(false)	
			self.view.node_t_list.lbl_next_skill_lv.node:setString("")
			self.view.node_t_list.lbl_next_lv_skill_name.node:setString("")
		end
			
	else
		self.view.node_t_list.lbl_cur_skill_lv.node:setString("Lv.0")
		self.view.node_t_list.lbl_skill_mp_cost.node:setString(Language.Common.No)
		self.view.node_t_list.img_top_lv.node:setVisible(false)
		self.view.node_t_list.lbl_skill_cool_sec.node:setString(Language.Common.No)
		self.view.node_t_list.lbl_next_skill_lv.node:setString("Lv." .. 1)
		
		local default_cfg = SkillData.GetSkillCfg(data.id)
		RichTextUtil.ParseRichText(self.view.node_t_list.rich_cur_skill_content.node, default_cfg.desc)
		
		local n_lv_cfg = SkillData.GetSkillLvCfg(data.id, 1)
		local n_lv = 0
		for k,v in pairs(n_lv_cfg.trainConds) do
			if v.cond == SkillData.SKILL_CONDITION.LEVEL then
				n_lv = v.value
			end
		end
		self.view.node_t_list.lbl_n_skill_lv_need.node:setString(n_lv .. Language.Common.Ji)
		RichTextUtil.ParseRichText(self.view.node_t_list.rich_next_lv_skill_content.node, n_lv_cfg.desc)

		local n_mp = 0
		for k,v in pairs(n_lv_cfg.spellConds) do
			if v.cond == SkillData.SKILL_CONDITION.MP then
				n_mp = v.value
			end
		end
		self.view.node_t_list.lbl_next_lv_skill_mp_cost.node:setString(n_mp > 0 and n_mp or Language.Common.No)
		self.view.node_t_list.lbl_skill_next_lv_cool_sec.node:setString(string.format(Language.Role.XXMiao, n_lv_cfg.cooldownTime * 0.001))
	end
end