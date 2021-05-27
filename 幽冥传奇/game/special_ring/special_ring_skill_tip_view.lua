--------------------------------------------------------
-- 特戒提示  配置
--------------------------------------------------------

SpecialRingSkillTipView = SpecialRingSkillTipView or BaseClass(BaseView)

function SpecialRingSkillTipView:__init()
	self.texture_path_list[1] = 'res/xui/special_ring.png'
	self.is_any_click_close = true
	self:SetModal(true)

	self.config_tab = {
		{"special_ring_ui_cfg", 6, {0}},
	}

end

function SpecialRingSkillTipView:__delete()
end

--释放回调
function SpecialRingSkillTipView:ReleaseCallBack()
	self.skill_icon = nil
end

--加载回调
function SpecialRingSkillTipView:LoadCallBack(index, loaded_times)
	-- 按钮监听
end

function SpecialRingSkillTipView:OpenCallBack()
	--播放声音
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function SpecialRingSkillTipView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
	self.item_id = nil
end

--显示指数回调
function SpecialRingSkillTipView:ShowIndexCallBack(index)
	self:Flush()
end

function SpecialRingSkillTipView:SetData(item_id)
	self.item_id = item_id
end

----------视图函数----------

function SpecialRingSkillTipView:OnFlush()
	local rich, text
	local item_id = self.item_id or 0
	local cfg = VirtualSkillCfg or {}
	local cur_skill = cfg[item_id] or {}

	rich = self.node_t_list["rich_skill_name"].node
	text = cur_skill.name or ""
	rich = RichTextUtil.ParseRichText(rich, text, 22, COLOR3B.BLUE)
	rich:refreshView()

	rich = self.node_t_list["rich_skill_lv"].node
	text = cur_skill.lv or ""
	rich = RichTextUtil.ParseRichText(rich, text, 18, COLOR3B.WHITE)
	rich:refreshView()

	rich = self.node_t_list["rich_skill_tip"].node
	text = cur_skill.desc or ""
	rich = RichTextUtil.ParseRichText(rich, text, 18, COLOR3B.WHITE)
	rich:refreshView()

	local path = ResPath.GetItem(cur_skill.icon or 0)
	if self.skill_icon then
		self.skill_icon:loadTexture(path)
	else
		local ph = self.ph_list["ph_skill_icon"]
		local x, y = ph.x, ph.y
		self.skill_icon = XUI.CreateImageView(x, y, path, XUI.IS_PLIST)
		self.node_t_list["layout_skill_tips"].node:addChild(self.skill_icon, 20)
	end
end

----------end----------

--------------------
