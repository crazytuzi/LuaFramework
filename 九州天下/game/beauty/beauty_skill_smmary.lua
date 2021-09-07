require("game/beauty/beauty_item")
BeautySkillSmmaryView = BeautySkillSmmaryView or BaseClass(BaseView)

function BeautySkillSmmaryView:__init()
	self.ui_config = {"uis/views/beauty","BeautySkillSmmary"}
	self:SetMaskBg(true)
	self.item_seq = -1
	self.get_name_list = {}
	self.no_name_list = {}
end

function BeautySkillSmmaryView:LoadCallBack()
	self:ListenEvent("OnSkillSummaryBg", BindTool.Bind(self.OnClickClose, self))

	for i=1,7 do
		local get_item = self:FindObj("GetText"..i)
		local text = get_item:FindObj("Text")
		local skill_name = get_item:FindObj("Button/Text")
		local icon = get_item:FindObj("Image/Icon")
		table.insert(self.get_name_list, {get_item = get_item, text = text, skill_name = skill_name, icon = icon})

		local no_item = self:FindObj("NoText"..i)
		local no_text = no_item:FindObj("Text")
		local no_skill_name = no_item:FindObj("Button/Text")
		local no_icon = no_item:FindObj("Image/Icon")
		table.insert(self.no_name_list, {no_item = no_item, no_text = no_text, no_skill_name = no_skill_name, no_icon = no_icon})

		self:ListenEvent("OnGetSkilll" .. i, BindTool.Bind(self.OnGetSkillHandle, self, i))
		self:ListenEvent("OnNoSkilll" .. i, BindTool.Bind(self.OnNoSkillHandle, self, i))
	end
	self:Flush()
end

function BeautySkillSmmaryView:ReleaseCallBack()
	self.get_name_list = {}
	self.no_name_list = {}
end

function BeautySkillSmmaryView:OnClickClose()
	self:Close()
end

function BeautySkillSmmaryView:OnFlush(param_t)
	local get_skill_list, no_skill_list = BeautyData.Instance:GetBeautyItemList()
	for i=1,7 do
		if get_skill_list[i] then
			local cfg = BeautyData.Instance:GetBeautyActiveInfo(get_skill_list[i].seq - 1)
			if cfg == nil then return end
			local index = cfg.active_skill_type
			local skill_info = BeautyData.Instance:GetBeautySkill(index)
			local beauty_info = BeautyData.Instance:GetBeautyActiveInfo(get_skill_list[i].seq - 1)
			if beauty_info then
				self.get_name_list[i].text.text.text = skill_info.name .. "：" .. skill_info.desc
				self.get_name_list[i].skill_name.text.text = beauty_info.name
				self.get_name_list[i].icon.image:LoadSprite(ResPath.GetItemIcon(skill_info.kill_icon))
				self.get_name_list[i].get_item:SetActive(true)
			end
		else
			self.get_name_list[i].get_item:SetActive(false)
		end	

		if no_skill_list[i] then
			local cfg = BeautyData.Instance:GetBeautyActiveInfo(no_skill_list[i].seq - 1)
			if cfg == nil then return end
			local index = cfg.active_skill_type
			local skill_info = BeautyData.Instance:GetBeautySkill(index)
			local beauty_info = BeautyData.Instance:GetBeautyActiveInfo(no_skill_list[i].seq - 1)
			if beauty_info then
				self.no_name_list[i].no_text.text.text = skill_info.name .. "：" .. skill_info.desc
				self.no_name_list[i].no_skill_name.text.text = beauty_info.name
				self.no_name_list[i].no_icon.image:LoadSprite(ResPath.GetItemIcon(skill_info.kill_icon))
				self.no_name_list[i].no_item:SetActive(true)
			end
		else
			self.no_name_list[i].no_item:SetActive(false)
		end
	end
end

function BeautySkillSmmaryView:OnGetSkillHandle(index)
	local get_skill_list, _ = BeautyData.Instance:GetBeautyItemList()
	local item_seq = get_skill_list[index].seq or 1
	BeautyCtrl.Instance:FlushViewInfo("SkillSmmary", {item_seq = item_seq})
	self:Close()
end
function BeautySkillSmmaryView:OnNoSkillHandle(index)
	local _, no_skill_list = BeautyData.Instance:GetBeautyItemList()
	local item_seq = no_skill_list[index].seq or 1
	BeautyCtrl.Instance:FlushViewInfo("SkillSmmary", {item_seq = item_seq})
	self:Close()
end