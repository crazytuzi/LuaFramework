GoddessShengWuSkillView = GoddessShengWuSkillView or BaseClass(BaseView)

function GoddessShengWuSkillView:__init()
	self.ui_config = {"uis/views/goddess_prefab","GoddessShengWuSkillTip"}
	self.view_layer = UiLayer.Pop

	self.title_str = ""
	self.now_level = ""
	self.total_level_name = ""
	self.attr_list = {}
	self.next_attr_list = {}
	self.play_audio = true
	self.shengwu_id = 0
	self.shengwu_level = 0
end

function GoddessShengWuSkillView:__delete()

end

function GoddessShengWuSkillView:LoadCallBack()
	--获取变量
	--self.now_total_des = self:FindVariable("text_now_title")		--当前等级
	--self.next_total_des = self:FindVariable("text_next_title")		--下一级等级

	self.text_show_lingye = self:FindVariable("text_show_lingye")

	self.cur_gongji = self:FindVariable("cur_gongji")
	self.next_gongji = self:FindVariable("next_gongji")
	self.img_now_bg = self:FindVariable("img_now_bg")
	self.img_next_bg = self:FindVariable("img_next_bg")
	self.img_now_show = self:FindVariable("img_now_show")
	self.img_next_show = self:FindVariable("img_next_show")

	self.btn_show = self:FindVariable("btn_show")
	self.btn_text_show = self:FindVariable("btn_text_show")	

	self.has_next = self:FindVariable("has_next")
	self.has_now = self:FindVariable("has_now")

	self.now_level_text = self:FindVariable("now_level_text")
	self.next_level_text = self:FindVariable("next_level_text")

	self.skill_icon = self:FindVariable("skill_icon")
	self.skill_text = self:FindVariable("skill_text")

	self.show_level_text = self:FindVariable("show_level_text")
	self.show_next_level_text = self:FindVariable("show_next_level_text")

	self:ListenEvent("CloseWindow", BindTool.Bind(self.CloseWindow, self))
end

function GoddessShengWuSkillView:ReleaseCallBack()
	-- 清理变量和对象
	-- self.now_total_des = nil
	-- self.next_total_des = nil
	self.text_show_lingye = nil

	self.img_now_bg = nil
	self.img_next_bg = nil
	self.img_now_show = nil
	self.img_next_show = nil
	self.btn_show = nil
	self.btn_text_show = nil
	self.has_next = nil
	self.has_now = nil
	self.now_level_text = nil
	self.next_level_text = nil
	self.skill_icon = nil
	self.skill_text = nil

	self.cur_gongji = nil
	self.next_gongji = nil
	self.shengwu_id = 0
	self.shengwu_level = 0

	self.show_level_text = nil
	self.show_next_level_text = nil
end


function GoddessShengWuSkillView:SetShengWuId(id)
	self.shengwu_id = id
end

function GoddessShengWuSkillView:CloseWindow()
	self:Close()
end

function GoddessShengWuSkillView:CloseCallBack()
	self.title_str = ""
	self.now_level = ""
	self.total_level_name = ""
	self.attr_list = {}
	self.next_attr_list = {}

end

function GoddessShengWuSkillView:OpenCallBack()
	self:Flush()
end

function GoddessShengWuSkillView:OnFlush()
	local sc_info_data = GoddessData.Instance:GetXiannvScShengWuIconAttr(self.shengwu_id)
	self.shengwu_level = sc_info_data.level
	local info_data = GoddessData.Instance:GetXianNvShengWuCfg(self.shengwu_id, self.shengwu_level)

	if info_data == nil then
		return
	end

	local skill_id = info_data.skill_id or 1
	local skill_level = info_data.skill_level or 0
	local skill_level_next = skill_level + 1
	local icon_num = info_data.icon_num or 0

	local now_data = GoddessData.Instance:GetXianNvShengWuSkillCfg(skill_id, skill_level)
	local next_data = GoddessData.Instance:GetXianNvShengWuSkillCfg(skill_id, skill_level_next)

	if nil == now_data then
		return
	end

	--local has_now = (skill_level ~= 0)
	local is_zore = (skill_level == 0)
	local has_now = true
	local has_next_info = (next_data ~= nil)

	self.has_now:SetValue(has_now)
	self.has_next:SetValue(has_next_info)

	self.skill_text:SetValue(now_data.name)
	self.skill_icon:SetAsset(ResPath.GetGoddessRes("goddess_shengwu_skill_" .. icon_num))
	local level_str = Language.Goddess.GoddessSkillLevelTip

	-- 设置下级属性的显示
	if has_next_info then
		self.show_next_level_text:SetValue(string.format(Language.Goddess.GoddessSkillLevelNextTip, skill_level_next))
		--self.next_total_des:SetValue(string.format(level_str, skill_level_next))
		self.next_gongji:SetValue(next_data.skill_desc)
		self.next_level_text:SetValue(string.format(Language.Goddess.GoddessSkillTipText, info_data.name, next_data.shengwu_level))
	end

	-- 设置当前
	--if has_now then
	self.show_level_text:SetValue(string.format(Language.Goddess.GoddessSkillLevelTip, skill_level))
	if has_next_info then
		if is_zore then
			self.now_level_text:SetValue(Language.Goddess.GoddessUpTextWeiJiHuo)
		else
			self.now_level_text:SetValue(ToColorStr(Language.Goddess.GoddessUpTextJiHuo, TEXT_COLOR.BLUE_4))
		end
	else
		self.now_level_text:SetValue(Language.Goddess.GoddessUpTextManJi)
	end
	--self.now_total_des:SetValue(string.format(level_str, skill_level))
	if is_zore then
		self.cur_gongji:SetValue(Language.Goddess.LabelNoText)
	else
		self.cur_gongji:SetValue(now_data.skill_desc)
	end
	--end
end