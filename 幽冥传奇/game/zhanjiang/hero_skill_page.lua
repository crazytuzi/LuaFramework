--角色技能页面
HeroSkillPage = HeroSkillPage or BaseClass()


function HeroSkillPage:__init()
	self.view = nil
end	

function HeroSkillPage:__delete()
	self:RemoveEvent()

	if self.skill_list then
		self.skill_list:DeleteMe()
		self.skill_list = nil
	end
	
	self.select_skill = nil
	self.select_skill_id = nil
	self.view = nil
end	

--初始化页面接口
function HeroSkillPage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self:CreateSkillList()
	self.select_skill_index = 1

	self:InitEvent()
	
end	

--初始化事件
function HeroSkillPage:InitEvent()
	
	-- XUI.AddClickEventListener(self.view.node_t_list.quick_set_btn.node,BindTool.Bind(self.OnQuickSet,self))
	-- XUI.AddClickEventListener(self.view.node_t_list.senior_preview_btn.node,BindTool.Bind(self.OnSeniorPreview,self))
	XUI.AddClickEventListener(self.view.node_t_list.quest_btn.node,BindTool.Bind(self.OnQuest,self))
	self.skill_data_change = GlobalEventSystem:Bind(HeroDataEvent.HERO_SKILL_DATA_CHANGE, BindTool.Bind(self.UpdateData, self))
end

--移除事件
function HeroSkillPage:RemoveEvent()
	if self.skill_data_change then
		GlobalEventSystem:UnBind(self.skill_data_change)
		self.skill_data_change = nil
	end
end

function HeroSkillPage:OnQuest()
	DescTip.Instance:SetContent(Language.Zhanjiang.SkillHelpContent,Language.Role.SkillHelpTitle)
end	

function HeroSkillPage:OnQuickSet()
	self.view:ShowIndex(TabIndex.role_skill_select)
end	

function HeroSkillPage:OnSeniorPreview()
	ViewManager.Instance:Open(ViewName.RoleSkillPreviewPage)
	ViewManager.Instance:FlushView(ViewName.RoleSkillPreviewPage, 0, "preview", {self.skill_preview_data})
end

--更新视图界面
function HeroSkillPage:UpdateData(data)
	local n_list = ZhanjiangData.Instance:GetHeroSkillData()
	self.skill_list:SetDataList(n_list)
	
	self.skill_list:SelectIndex(self.select_skill_index)
			
end	

function HeroSkillPage:CreateSkillList()
	if self.skill_list then
		-- self.skill_list:GetView():removeFromParent()
		-- self.skill_list:DeleteMe()
		-- self.skill_list = nil
		return
	end
	

	local ph = self.view.ph_list.ph_skill_list
	self.skill_list = ListView.New()
	self.skill_list:Create(ph.x, ph.y, ph.w, ph.h, nil, HeroSkillListRender, nil, nil, self.view.ph_list.ph_skill_item)
	-- self.skill_list:GetView():setAnchorPoint(0, 0)
	self.view.node_t_list.layout_hero_skill.node:addChild(self.skill_list:GetView(), 100)
	self.skill_list:SetItemsInterval(6)
	self.skill_list:SetMargin(3)
	self.skill_list:SetJumpDirection(ListView.Top)
	self.skill_list:SetSelectCallBack(BindTool.Bind1(self.SelectSkillCallBack, self))
	-- self.n_size = self.skill_list:GetView():getContentSize()
	
end

function HeroSkillPage:SelectSkillCallBack(item)
	if nil == item or nil == item:GetData() then return end
	local data = item:GetData()
	
	self.select_skill_index = item:GetIndex()
	self.select_skill_id = data.skill_id
	self.skill_preview_data = data
	local skill_info = SkillData.GetSkillCfg(data.skill_id)
	-- if ViewManager.Instance:IsOpen(ViewName.RoleSkillPreviewPage) then
	-- 	ViewManager.Instance:FlushView(ViewName.RoleSkillPreviewPage, 0, "preview", {self.skill_preview_data})
	-- end
	
	-- local skill_info = SkillData.Instance:GetSkill(data.skill_id)
	
	--是否技能信息
	if skill_info then
		self.view.node_t_list.lbl_cur_skill_name.node:setString(skill_info.name)
		self.view.node_t_list.lbl_next_lv_skill_name.node:setString(skill_info.name)

		
		local add_level = ZhanjiangData.Instance:GetAddSkillLevelBySkillID(data.skill_id)
		local cur_level = data.skill_lv + add_level
		
		local lv_cfg = SkillData.GetSkillLvCfg(data.skill_id, cur_level) 

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
		else
			RichTextUtil.ParseRichText(self.view.node_t_list.rich_cur_skill_content.node, "")
			self.view.node_t_list.lbl_skill_mp_cost.node:setString(Language.Common.No)
			self.view.node_t_list.lbl_skill_cool_sec.node:setString("--")
		end	
		
		local n_lv_cfg = SkillData.GetSkillLvCfg(data.skill_id, cur_level + 1)
		if n_lv_cfg then

			self.view.node_t_list.img_top_lv.node:setVisible(false)
			self.view.node_t_list.layout_next_lv_skill_info.node:setVisible(true)
			self.view.node_t_list.lbl_next_skill_lv.node:setString("Lv." .. (cur_level + 1))
			

			RichTextUtil.ParseRichText(self.view.node_t_list.rich_next_lv_skill_content.node, n_lv_cfg.desc)
			local n_lv = 0
			for k,v in pairs(n_lv_cfg.trainConds) do
				if v.cond == SkillData.SKILL_CONDITION.FUWEN_LV then
					n_lv = v.value
				end
			end
			local step, star = ZhanjiangData.GetFuWenStepStar(n_lv)
			self.view.node_t_list.lbl_n_skill_lv_need.node:setString("") --string.format(Language.Zhanjiang.SkillOpenCondTxt, step, star)
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
		
		local default_cfg = SkillData.GetSkillCfg(data.skill_id)
		RichTextUtil.ParseRichText(self.view.node_t_list.rich_cur_skill_content.node, default_cfg.desc)
		
		local n_lv_cfg = SkillData.GetSkillLvCfg(data.skill_id, 1)
		local n_lv = 0
		for k,v in pairs(n_lv_cfg.trainConds) do
			if v.cond == SkillData.SKILL_CONDITION.FUWEN_LV then
				n_lv = v.value
			end
		end
		self.view.node_t_list.lbl_n_skill_lv_need.node:setString("") --n_lv .. Language.Common.Ji
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