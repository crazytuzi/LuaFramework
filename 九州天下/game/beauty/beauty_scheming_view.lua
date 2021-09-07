require("game/beauty/beauty_skill")
local TIAN_TAB = 0
local DI_TAB = 1
local REN_TAB = 2
local MAX_SKILL_NUM = 10
BeautySchemingView = BeautySchemingView or BaseClass(BaseRender)

function BeautySchemingView:__init(instance)
	self.cur_tab = 0
	self.skill_list = {}
	self.skill_cur_type = 0
	self.skill_cur_index = 0

	self.item_list = {}
	self.item_cell_list = {}
	self.select_index = 1
end

function BeautySchemingView:__delete()
	if self.skill_list then
		for k, v in pairs(self.skill_list) do
			v:DeleteMe()
		end
		self.skill_list = {}
	end

	if self.item_cell_list then
		for k, v in pairs(self.item_cell_list) do
			if v[1] then
				v[1]:DeleteMe() 
			end
		end
		self.item_cell_list = {}
	end

	if self.right_skill_list then
		for k, v in pairs(self.right_skill_list) do
			v.select_btn:DeleteMe() 
		end
		self.right_skill_list = {}
	end

	if self.skill_item_cell then
		self.skill_item_cell:DeleteMe()
	end
	self.skill_item_cell = nil

	if self.item_cell then
		self.item_cell:DeleteMe()
	end
	self.item_cell = nil

	self.show_learn_red = nil
	for i = 1, 3 do
		self["show_tab_red" .. i] = nil
	end
end

function BeautySchemingView:LoadCallBack(instance)
	self:ListenEvent("OnStudyBtn", BindTool.Bind(self.OnStudyBtnHandle, self))
	self:ListenEvent("OnTianTab", BindTool.Bind(self.OnTabHandle, self, TIAN_TAB))
	self:ListenEvent("OnDiTab", BindTool.Bind(self.OnTabHandle, self, DI_TAB))
	self:ListenEvent("OnRenTab", BindTool.Bind(self.OnTabHandle, self, REN_TAB))
	self:ListenEvent("OnCloseSkillUp", BindTool.Bind(self.OnCloseSkillUp, self))
	self:ListenEvent("OnSkillLockBtn", BindTool.Bind(self.OnSkillLockBtn, self))
	self:ListenEvent("OnSkillUpBtn", BindTool.Bind(self.OnSkillUpBtn, self))
	self:ListenEvent("OnHelpBtn", BindTool.Bind(self.OnHelpBtn, self))

	local skill_data = BeautyData.Instance:GetXinjiTypeInfo(self.cur_tab)
	for i=1,10 do
		self.skill_list[i] = BeautySkill.New(self:FindObj("Skill" .. i))
		self.skill_list[i]:SetIndex(i)
		self.skill_list[i]:SetData(self.cur_tab, skill_data.skill_list[i])
	end
	
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))
	self.item_name = self:FindVariable("ItemName")

	self.exp_radio = self:FindVariable("ExpRadio")
	self.cur_value = self:FindVariable("ProgeCurValue")
	self.next_value = self:FindVariable("ProgeNextValue")
	self.show_skill_uplevel = self:FindVariable("ShowSkillUpLevel")
	self.dose = self:FindVariable("Dose")
	self.dose:SetValue(Language.Beaut.ShemingTip)
	self.skill_name = self:FindVariable("SkillUpName")
	self.skill_level = self:FindVariable("SkillUpLevel")
	self.skill_desc = self:FindVariable("SkillDesc")
	self.skill_success = self:FindVariable("SkillSuccess")
	self.skill_item_name = self:FindVariable("SkillUpItemName")
	self.skill_icon = self:FindVariable("SkillIcon")
	self.is_open_lock = self:FindVariable("IsOpenLock")
	self.is_max_level = self:FindVariable("IsMaxLevel")
	self.skill_btn_text = self:FindVariable("SkillBtnText")
	self.cur_num = self:FindVariable("CurNum")
	self.add_num = self:FindVariable("AddNum")
	self.skill_item_cell = ItemCell.New(self:FindObj("SkillItem"))

	self.show_learn_red = self:FindVariable("ShowLearnRed")
	for i = 1, 3 do
		self["show_tab_red" .. i] = self:FindVariable("ShowTabRed" .. i)
	end

	self.right_skill_list = {}
	-- local xinji_skill = BeautyData.Instance:GetLevelXinjiSkillSetCfg()
	for i = 1, MAX_SKILL_NUM do
		self.right_skill_list[i] = {}
		self.right_skill_list[i].select_btn = BeautySkillItem.New(self:FindObj("select_btn_" .. i))
		-- self.right_skill_list[i].select_btn:SetSkillData(xinji_skill[i])
		self.right_skill_list[i].list = self:FindObj("List_" .. i)
		self:ListenEvent("SelectBtn_" .. i ,BindTool.Bind(self.OnClickSelect, self, i))
	end
	self:LoaddateList()
end
function BeautySchemingView:OnClickSelect(index)
	self.select_index = index
end

function BeautySchemingView:LoaddateList()
	local cfg_list = BeautyData.Instance:GetLevelXinjiSkillSetCfg()
	if cfg_list == nil then return end
	self.right_skill_list[self.select_index].list:SetActive(false)
	self.item_list = {}
	self.item_cell_list = {}
	for i = 1, #cfg_list do
		self.right_skill_list[i].select_btn:SetActive(true)
		self.right_skill_list[i].select_btn:SetData(cfg_list[i])
		self:LoadCell(i)
	end
	if #cfg_list == MAX_SKILL_NUM then
		return
	end
	for i = #cfg_list + 1, MAX_SKILL_NUM do
		self.right_skill_list[i].select_btn:SetActive(false)
	end
end

function BeautySchemingView:LoadCell(index)
	local cfg_list = BeautyData.Instance:GetLevelXinjiSkillSetCfg()
	if cfg_list and cfg_list[index] then
		self.item_cell_list[index] = {}
		PrefabPool.Instance:Load(AssetID("uis/views/beauty_prefab", "SkillXinjiItem"), function (prefab)
			if nil == prefab then
				return
			end
			local obj = GameObject.Instantiate(prefab)
			local obj_transform = obj.transform
			if not IsNil(obj_transform) and self.right_skill_list[index] ~= nil then
				obj_transform:SetParent(self.right_skill_list[index].list.transform, false)
			end
			
			local item_cell = BeautySkillTipsItem.New(obj)
			item_cell:SetData(cfg_list[index])
			self.item_list[#self.item_list + 1] = obj_transform
			self.item_cell_list[index][1] = item_cell

			PrefabPool.Instance:Free(prefab)
		end)
	end
end

function BeautySchemingView:OnFlush(param_list)
	self:UpSkillData(self.cur_tab)
	if self.open_types and self.open_index then
		self:SetSkillUpData(self.open_types, self.open_index)
	end
	local oter_cfg = BeautyData.Instance:GetBeautyOther()
	if oter_cfg then
		self.item_cell:SetData({item_id = oter_cfg.xinji_skill_item})

		local item_num = 1
		local has_stuff = ItemData.Instance:GetItemNumInBagById(oter_cfg.xinji_skill_item)
		local stuff_format = "<color=#%s> %d</color> / %d"
		local stuff_color = has_stuff < item_num and "ff0000" or "00931f"
		self.item_name:SetValue(string.format(stuff_format, stuff_color, has_stuff, item_num))
	end
	self:UpCellData()
	self:FlushRed()
end

function BeautySchemingView:FlushRed()
	if self.cur_tab == nil then
	end

	local num, no_num, book_num, tab_red_list = BeautyData.Instance:GetShowRedSkillList()
	if self.show_learn_red ~= nil then
		self.show_learn_red:SetValue(BeautyData.Instance:GetIsCanLearnSkill(no_num > 0 and book_num > 0))
	end

	for i = 1, 3 do
		if self["show_tab_red" .. i] ~= nil then
			self["show_tab_red" .. i]:SetValue(tab_red_list[i - 1] or false)
		end
	end
end

function BeautySchemingView:UpCellData()
	local cfg_list = BeautyData.Instance:GetLevelXinjiSkillSetCfg()
	if cfg_list then
		for i = 1, #cfg_list do
			if self.right_skill_list[i] and self.right_skill_list[i].select_btn then
				self.right_skill_list[i].select_btn:SetData(cfg_list[i])
			end
			if self.item_cell_list[i] and self.item_cell_list[i][1] then
				self.item_cell_list[i][1]:SetData(cfg_list[i])
			end
		end
	end
end

function BeautySchemingView:OnTabHandle(index)
	if self.cur_tab == index then return end
	self.cur_tab = index
	
	self:UpSkillData(self.cur_tab)
end

function BeautySchemingView:OnCloseSkillUp()
	self.show_skill_uplevel:SetValue(false)
end

function BeautySchemingView:ShowSkillUpLevel(types, index)
	self.open_types = types
	self.open_index = index
	self.show_skill_uplevel:SetValue(true)
	self:SetSkillUpData(types, index)
end

--设置技能升级信息
function BeautySchemingView:SetSkillUpData(types, index)
	self.skill_cur_type = types
	self.skill_cur_index = index - 1
	local skill_data = BeautyData.Instance:GetXinjiTypeInfo(types)
	local skill = skill_data.skill_list[index]
	local skill_cfg = BeautyData.Instance:GetCurLevelXinjiSkillCfg(skill.seq, skill.level)
	local skill_attr = CommonDataManager.GetAttributteByClass(skill_cfg)
	local is_max_level = false
	if nil == skill_cfg or nil == skill_cfg.item then
		is_max_level = true
	end

	local percent_value = nil
	if skill_cfg and skill then
		local attr_num = 0
		for k,v in pairs(skill_attr) do
			if v > 0 then
				attr_num = (v * skill_cfg.attrs_rate)
			end
		end
		if skill_cfg.if_percent == 1 then
			percent_value = attr_num
			attr_num = MojieData.Instance:GetAttrRate(attr_num)
		end
		self.skill_name:SetValue(skill_cfg.name)
		self.skill_level:SetValue(string.format(Language.Beaut.SkillLevel, skill.level))
		local other_add = ""
		if skill.is_lock == 1 then
			local other_cfg = BeautyData.Instance:GetBeautyOther()
			local value = percent_value ~= nil and percent_value or attr_num
			if percent_value ~= nil then
				value = math.floor(value * (other_cfg.xinji_slot_lock_add_attr_per) * 0.01)
				value = MojieData.Instance:GetAttrRate(value)
				other_add = ToColorStr("(+" .. value .. ")", COLOR.GREEN)
			else
				other_add = ToColorStr("(+" .. math.floor(value * (other_cfg.xinji_slot_lock_add_attr_per) * 0.01) .. ")", COLOR.GREEN)
			end
		end
		self.skill_desc:SetValue(skill_cfg.explain .. ":" .. attr_num .. other_add)
		self.skill_success:SetValue(string.format(Language.Beaut.SkillSuccess, skill_cfg.succ_rate))
		self.skill_item_cell:SetData({item_id = skill_cfg.item})
		self.skill_item_name:SetValue(ItemData.Instance:GetItemName(skill_cfg.item))
		self.skill_icon:SetAsset(ResPath.GetItemIcon(skill_cfg.kill_icon))
		self.is_open_lock:SetValue(skill.is_lock == 1)

		local has_stuff = ItemData.Instance:GetItemNumInBagById(skill_cfg.item) 
		local stuff_format = "<color=#%s>%d</color>"
		local stuff_color = has_stuff < 1 and "ff0000" or "00931f"
		self.cur_num:SetValue(string.format(stuff_format, stuff_color, has_stuff))
		self.add_num:SetValue(1)
	end
	self.is_max_level:SetValue(is_max_level)
	self.skill_btn_text:SetValue(is_max_level and Language.Beaut.SkillMaxLevel or Language.Beaut.SkillUpLevel)
end

--点击小锁锁定当前技能
function BeautySchemingView:OnSkillLockBtn()
	local data = BeautyData.Instance:GetSkillLockInfo(self.open_types, self.open_index)
	if data == nil or next(data) == nil then
		return
	end

	local str = ""
	local function call(is_auto_buy)
		BeautyCtrl.Instance:SendBeautyCommonReq(BEAUTY_COMMON_REQ_TYPE.BEAUTY_COMMON_REQ_TYPE_XINJI_LOCK_SKILL, self.skill_cur_type, self.skill_cur_index, is_auto_buy or 0)
	end

	if not data.cur_is_lock then
		if data.active_num <= 2 or (data.active_num < 10 and (data.active_num - 2) <= data.lock_num) then
			SysMsgCtrl.Instance:ErrorRemind(Language.Beaut.NoCanLockTip)
			return
		end

		if data.lock_num >= 10 then
			SysMsgCtrl.Instance:ErrorRemind(Language.Beaut.NoCanLockTip)
			return		
		end

		-- local lock_cfg = BeautyData.Instance:GetSkillLockCfg(data.lock_num + 1)
		-- if lock_cfg ~= nil and next(lock_cfg) ~= nil then
		-- 	local item_data = ItemData.Instance:GetItemConfig(lock_cfg.consume_item_id)
		-- 	if item_data ~= nil then
		-- 		str = string.format(Language.Beaut.LockSkillTip, lock_cfg.consume_item_num, item_data.name, data.add_value)
		-- 		TipsCtrl.Instance:ShowCommonTip(call, nil, str)
		-- 	end
		-- end
		BeautyCtrl.Instance:OpenLockSkillTip(self.open_types, self.open_index, call)
	else
		local lock_cfg = BeautyData.Instance:GetSkillLockCfg(data.lock_num)
		if lock_cfg ~= nil and next(lock_cfg) ~= nil then
			local item_data = ItemData.Instance:GetItemConfig(lock_cfg.consume_item_id)
			if item_data ~= nil then
				str = string.format(Language.Beaut.UnLockSkillTip, lock_cfg.consume_item_num, item_data.name)
				TipsCtrl.Instance:ShowCommonTip(call, nil, str)
			end
		end
	end
end

--点击升级技能
function BeautySchemingView:OnSkillUpBtn()
	BeautyCtrl.Instance:SendBeautyCommonReq(BEAUTY_COMMON_REQ_TYPE.BEAUTY_COMMON_REQ_TYPE_XINJI_UPLEVEL_SKILL, self.skill_cur_type, self.skill_cur_index)
end

function BeautySchemingView:OnHelpBtn()
	TipsCtrl.Instance:ShowHelpTipView(196)
end

function BeautySchemingView:UpSkillData(type)
	local skill_data = BeautyData.Instance:GetXinjiTypeInfo(type)
	for i=1,10 do
		self.skill_list[i]:SetData(type, skill_data.skill_list[i])
	end

	self.exp_radio:SetValue(skill_data.bless_val/1000)
	self.cur_value:SetValue(skill_data.bless_val)
	self.next_value:SetValue(100)
end

function BeautySchemingView:OnStudyBtnHandle()
	BeautyCtrl.Instance:SendBeautyCommonReq(BEAUTY_COMMON_REQ_TYPE.BEAUTY_COMMON_REQ_TYPE_XINJI_LEARN_SKILL, self.cur_tab)
end


BeautySkillItem = BeautySkillItem or BaseClass(BaseCell)
function BeautySkillItem:__init(instance)
	self.name = self:FindVariable("Name")
	self.attr_text = self:FindVariable("AttrText")
	self.skill_num = self:FindVariable("SkillNum")
	self.icon_list = {}
	self.icon_name_list = {}
	self.icon_gray_list = {}
	self.show_name_list = {}
	for i=1,3 do
		self.icon_list[i] = self:FindVariable("Icon" .. i)
		self.icon_name_list[i] = self:FindVariable("IconName" .. i)
		self.icon_gray_list[i] = self:FindVariable("IconGray" .. i)
		self.show_name_list[i] = self:FindVariable("ShowIconName" .. i)
	end
end

function BeautySkillItem:__delete()

end

function BeautySkillItem:OnFlush()
	if nil == self.data then return end
	self.name:SetValue(self.data.name)
	self.attr_text:SetValue(self.data.explain)
	self.skill_num:SetValue(self.data.need_skill_count)
	local icon_name = {"tian", "di", "ren"}
	if self.data.need_skill_count > 0 then
		for i=1,3 do
			local bundle, asset = ResPath.GetBeautySkillRes(icon_name[i])
			self.icon_list[i]:SetAsset(bundle, asset)
			self.show_name_list[i]:SetValue(true)
			self.icon_name_list[i]:SetValue(string.format(Language.Beaut.SkillZuheName[i], self.data.need_skill_count))
			local gray_bool = BeautyData.Instance:GetTypesIconIsGray(i - 1, self.data.need_skill_count)
			self.icon_gray_list[i]:SetValue(gray_bool)
		end
	else
		for i=1,3 do
			local skill_cfg = BeautyData.Instance:GetCurLevelXinjiSkillCfg(self.data.seq_list[i], 1)
			local gray_bool = BeautyData.Instance:GetcurIconIsGray(self.data.seq_list[i])
			self.icon_list[i]:SetAsset(ResPath.GetItemIcon(skill_cfg.kill_icon))
			self.show_name_list[i]:SetValue(false)
			self.icon_gray_list[i]:SetValue(gray_bool)
		end
	end
end	


BeautySkillTipsItem = BeautySkillTipsItem or BaseClass(BaseCell)
function BeautySkillTipsItem:__init(instance)
	self.tips_list = {}
	for i=1,3 do
		self.tips_list[i] = self:FindVariable("Tips" .. i)
	end
end

function BeautySkillTipsItem:__delete()

end

function BeautySkillTipsItem:OnFlush()
	if nil == self.data then return end
	if next(self.data.seq_list) then
		for i,v in ipairs(self.data.seq_list) do
			local color = BeautyData.Instance:GetcurIconIsGray(v) and TEXT_COLOR.GREEN or TEXT_COLOR.GRAY_WHITE
			local skill_info = BeautyData.Instance:GetBeautyXinjiSkillCfg(v)
			if skill_info then
				self.tips_list[i]:SetValue(string.format(Language.Beaut.SkillZuheTips[i], color, skill_info.name))
			end
		end
	elseif self.data.need_skill_count > 0 then
		for i=1,3 do
			local color = BeautyData.Instance:GetTypesIconIsGray(i - 1, self.data.need_skill_count) and TEXT_COLOR.GREEN or TEXT_COLOR.GRAY_WHITE
			self.tips_list[i]:SetValue(string.format(Language.Beaut.SkillTipsList[i], color, self.data.need_skill_count))
		end
	end
end	


