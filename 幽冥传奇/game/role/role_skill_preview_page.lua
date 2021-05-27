RoleSkillPreviewPage = RoleSkillPreviewPage or BaseClass(XuiBaseView)

function RoleSkillPreviewPage:__init()
	self.config_tab = {
						{"role_ui_cfg", 13, {0}}
					}

	-- self.can_penetrate = true
	-- self.is_any_click_close = true

	
	
end

function RoleSkillPreviewPage:__delete()
	
end

function RoleSkillPreviewPage:ReleaseCallBack()
	
end

function RoleSkillPreviewPage:OnFlush(paramt,index)
	if not paramt then return end

	for k, v in pairs(paramt) do
		if k == "preview" then
			local data = v[1]
			local skill_lv = 10
			local lv_cfg = SkillData.GetSkillLvCfg(data.id, skill_lv) 
			self.node_t_list.layout_preview_info.lbl_skill_name.node:setString(data.name)
			self.node_t_list.layout_preview_info.lbl_next_skill_lv.node:setString("Lv." .. skill_lv)
			if lv_cfg then
				RichTextUtil.ParseRichText(self.node_t_list.layout_preview_info.rich_skill_content.node, lv_cfg.desc)
			end
			local n_lv = 0
			for k1, v1 in pairs(lv_cfg.trainConds) do
				if v1.cond == SkillData.SKILL_CONDITION.LEVEL then
					n_lv = v1.value
				end
			end
			self.node_t_list.layout_preview_info.lbl_skill_lv_need.node:setString(string.format(Language.Common.LvCond, n_lv))
			local n_mp = 0
			for k2, v2 in pairs(lv_cfg.spellConds) do
				if v2.cond == SkillData.SKILL_CONDITION.MP then
					n_mp = v2.value
				end
			end
			self.node_t_list.layout_preview_info.lbl_skill_mp_cost.node:setString(n_mp > 0 and n_mp or Language.Common.No)
			self.node_t_list.layout_preview_info.lbl_skill_cool_sec.node:setString(string.format(Language.Role.XXMiao, lv_cfg.cooldownTime * 0.001))
		end
	end



	
	
	
end

function RoleSkillPreviewPage:LoadCallBack(index, loaded_time)
	if loaded_time <= 1 then
		XUI.AddClickEventListener(self.node_t_list.layout_preview_info.btn_close.node,BindTool.Bind(self.OnClose,self))
		self.node_t_list.layout_preview.node:setBackGroundColor(COLOR3B.BLACK)
		self.node_t_list.layout_preview.node:setBackGroundColorOpacity(100)
		self.root_node:setPosition(HandleRenderUnit:GetWidth() * 0.5 - 50, HandleRenderUnit:GetHeight() * 0.5 - 50)
	end
end

function RoleSkillPreviewPage:ShowIndexCallBack(index)
	self:Flush(index)
end

function RoleSkillPreviewPage:OnClose()
	self:Close()
end



