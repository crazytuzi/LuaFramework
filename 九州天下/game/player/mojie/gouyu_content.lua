GouyuContentView = GouyuContentView or BaseClass(BaseRender)

local MAX_LEVEL = 10	--每阶10级
function GouyuContentView:__init(instance)
	self.is_activation = false	--是否激活
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
end

function GouyuContentView:__delete()
	if self.attr_t then
		for _,v in pairs(self.attr_t) do
			v:DeleteMe()
		end
		self.attr_t = {}
	end

	if self.attr_t_n then
		for _,v in pairs(self.attr_t_n) do
			v:DeleteMe()
		end
		self.attr_t_n = {}
	end
	
	if self.stuff_cell ~= nil then
		self.stuff_cell:DeleteMe()
		self.stuff_cell = nil
	end

	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end
end

function GouyuContentView:LoadCallBack(instance)
	-- self.cur_Level = self:FindVariable("Level1")
	-- self.next_Level = self:FindVariable("Level2")
	self.gouyu_1 = self:FindVariable("Mojie1Gray")
	-- self.gouyu_2 = self:FindVariable("Mojie2Gray")
	self.cur_name = self:FindVariable("GouyuName1")
	-- self.next_name = self:FindVariable("GouyuName2")

	self.cur_attr = self:FindObj("AttrCur")
	self.next_attr = self:FindObj("AttrNext")
	self.attr_t = {}
	self.attr_t_n = {}
	for i = 1, 3 do
		local attr = self.cur_attr.transform:FindHard("Attr" .. i)
		if attr then
			table.insert(self.attr_t, GouyuAttrItem.New(attr))
		end
		attr = self.next_attr.transform:FindHard("Attr" .. i)
		if attr then
			table.insert(self.attr_t_n,  GouyuAttrItem.New(attr))
		end
	end
	self.stuff_cell = ItemCell.New()
	self.stuff_cell:SetInstanceParent(self:FindObj("Stuff"))
	self.stuff_cost = self:FindVariable("CostStuff")
	self.cur_cap = self:FindVariable("CurPower")
	self.next_cap = self:FindVariable("NextPower")
	self.up_btn_txt = self:FindVariable("UpBtnTxt")
	self.up_btn_gray = self:FindVariable("UpBtnGray")
	self.show_next_attr_panel = self:FindVariable("ShowNextAttrPanel")

	self.show_image = self:FindVariable("GouyuImage")
	self.gouyu_effect_qian = self:FindVariable("GouyuEffectsQian")
	self.gouyu_effect_hou = self:FindVariable("GouyuEffectsHou")
	self.gouyu_effect_bg = self:FindVariable("GouyuEffectsBg")
	self.show_effect = self:FindVariable("ShowEffect")
	self.gouyu_effect_bg:SetAsset("effects2/prefab/ui/gouyujunbian_prefab","gouyujunbian")
	self:ListenEvent("GoGet",
		BindTool.Bind(self.OnGotoGet, self))
	self:ListenEvent("UpGrade",
		BindTool.Bind(self.OnUpGrade, self))
	self:ListenEvent("ClickHelp",
		BindTool.Bind(self.OnClickHelp, self))

	self.show_gouyu_red = self:FindVariable("ShowGouYuRed")
	RemindManager.Instance:Bind(self.remind_change, RemindName.GouYu)
end

function GouyuContentView:RemindChangeCallBack(remind_name, num)
	self.show_gouyu_red:SetValue(num > 0)
end

function GouyuContentView:OnFlush(param_list)
	local level = MojieData.Instance:GetLevelInfo(EQUIPMENT_TYPE.EQUIPMENT_TYPE_GOUYU)
	local next_level = level + 1

	local max_cfg = MojieData.Instance:GetGouyuMaxCfg()
	local is_max_level = false					--是否是最大等级
	local is_one_activation = false				--是否已激活第一次
	if max_cfg and level >= max_cfg.level then
		is_max_level = true
		level = max_cfg.level
		next_level = max_cfg.level
	end
	if level > 0 then
		self.is_activation = true
	end

	local cfg = MojieData.Instance:GetGouyuLevelCfg(level)
	local next_cfg = MojieData.Instance:GetGouyuLevelCfg(next_level)
	local show_cfg, show_image = MojieData.Instance:GetGouyuShowCfg(level)
	self.show_effect:SetValue(true)
	if show_cfg and next_cfg then
		local str = string.format(Language.Mojie.GouyuCurAttr, show_cfg.gouyu_open, cfg and cfg.c_level or 0)
		self.cur_name:SetValue(self.is_activation and str or Language.Mojie.NoActivation)
		-- self.gouyu_1:SetValue(self.is_activation)
		self.gouyu_1:SetValue(true)
		if cfg then
			local has_stuff = ItemData.Instance:GetItemNumInBagById(cfg.stuff_id)
			local stuff_format = "<color=#%s>%d</color><color=#503635> / %d</color>"
		    local stuff_color = has_stuff < cfg.stuff_num and "ff0000" or "503635"
			self.stuff_cost:SetValue(string.format(stuff_format, stuff_color, has_stuff, cfg.stuff_num))
			self.stuff_cell:SetData({item_id = cfg.stuff_id, num = 1, is_bind = 0})
		end
		local bundle, asset = ResPath.GetPlayerImage("gouyu_" .. show_image)
		self.show_image:SetAsset(bundle, asset)

		local eff_name_qian = "gouyu_" .. show_image .. "_qian"
		local eff_name_hou = "gouyu_" .. show_image .. "_hou"
		self.gouyu_effect_qian:SetAsset("effects2/prefab/ui/" .. string.lower(eff_name_qian) .. "_prefab", eff_name_qian)
		self.gouyu_effect_hou:SetAsset("effects2/prefab/ui/" .. string.lower(eff_name_hou) .. "_prefab", eff_name_hou)

		local cur_attr = CommonDataManager.GetAttributteByClass(cfg)
		local next_attr = CommonDataManager.GetAttributteByClass(next_cfg)
		local index = 1
		for i,v in ipairs(MojieData.Attr) do
			if self.attr_t[index] and Language.Common.AttrName[v] then
				self.attr_t[index]:SetData(Language.Common.AttrName[v] .. "：<color=#503635>" .. (cur_attr[v] or 0) .. "</color>")
				self.attr_t_n[index]:SetData(Language.Common.AttrName[v] .. "：<color=#503635>" .. (next_attr[v] or 0) .. "</color>")
			end
			index = index + 1
		end
		self.cur_cap:SetValue(CommonDataManager.GetCapabilityCalculation(cur_attr))
		self.next_cap:SetValue(CommonDataManager.GetCapabilityCalculation(next_attr))
		self.up_btn_gray:SetValue(not is_max_level)
		self.up_btn_txt:SetValue(is_max_level and Language.Common.MaxLv or (self.is_activation and Language.Common.Up or Language.Common.Activate))		
	end
end

function GouyuContentView:OnGotoGet()
	ViewManager.Instance:Open(ViewName.Exchange, TabIndex.exchange_mojing)
end

function GouyuContentView:OnUpGrade()
	MojieCtrl.Instance:SendGouyuUplevelReq(EQUIPMENT_TYPE.EQUIPMENT_TYPE_GOUYU)
end

function GouyuContentView:OnClickHelp()
	local tip_id = 187
	TipsCtrl.Instance:ShowHelpTipView(tip_id)
end

GouyuAttrItem = GouyuAttrItem or BaseClass(BaseCell)

function GouyuAttrItem:__init(instance, mother_view)
	self.attr_value = self:FindVariable("AttrValue")
	self.is_show = self:FindVariable("IsShow")
end

function GouyuAttrItem:__delete()

end

function GouyuAttrItem:OnFlush()
	if self.data == nil then return end
	self.attr_value:SetValue(self.data)
end