HunYinAllView = HunYinAllView or BaseClass(BaseView)
function HunYinAllView:__init()
	self.ui_config = {"uis/views/hunqiview", "AllHunYin"}
	self:SetMaskBg()
end

function HunYinAllView:__delete()
	-- body
end

function HunYinAllView:LoadCallBack()
	self.green = self:FindVariable("green")
	self.blue = self:FindVariable("blue")
	self.purple = self:FindVariable("purple")
	self.orange = self:FindVariable("orange")

	self.power_green = self:FindVariable("power_green")
	self.power_blue = self:FindVariable("power_blue")
	self.power_purple = self:FindVariable("power_purple")
	self.power_orange = self:FindVariable("power_orange")

	self:ListenEvent("ClickGreen", BindTool.Bind(self.ClickGreen, self))
	self:ListenEvent("ClickBlue", BindTool.Bind(self.ClickBlue, self))
	self:ListenEvent("ClickPurple", BindTool.Bind(self.ClickPurple, self))
	self:ListenEvent("ClickOrange", BindTool.Bind(self.ClickOrange, self))
	self.green_cell_data = {}
	self.blue_cell_data = {}
	self.purple_cell_data = {}
	self.orange_cell_data = {}

	self.top_hunyin_count = 0
	self.hunyin_all = HunQiData.Instance:GetHunYinAllInfo()
	self.hunyin_info = HunQiData.Instance:GetHunQiInfo()

	local top_hunyin = {}
	for k,v in pairs(self.hunyin_all) do
		local color_id = v.hunyin_color
		if color_id == 1 then
			self.green_cell_data = v
		end
		if color_id == 2 then
			self.blue_cell_data = v
		end
		if color_id == 3 then
			self.purple_cell_data = v
		end
		if color_id == 4 then
			self.orange_cell_data = v
		end
		if color_id == 5 then
			self.top_hunyin_count = self.top_hunyin_count + 1
			table.insert(top_hunyin, v)
		end
	end

	self.top_list_obj = self:FindObj("top_list")
	self.top_list = {}
		for i = 1, self.top_hunyin_count do
		local top_obj = self.top_list_obj.transform:GetChild(i - 1).gameObject
		local top_item = TopCell.New(top_obj)
		top_item:SetData(top_hunyin[i])
		top_item:SetClickCallBack(BindTool.Bind(self.SlotClick, self))
		table.insert(self.top_list, top_item)
	end
	self:ListenEvent("ClickClosen", BindTool.Bind(self.ClickClosen, self))
end

-- 销毁前调用
function HunYinAllView:ReleaseCallBack()
	self.green = nil
	self.blue = nil
	self.purple = nil
	self.orange = nil
	self.top_list_obj = nil
	self.power_green = nil
	self.power_blue = nil
	self.power_purple = nil
	self.power_orange = nil

	for k,v in pairs(self.top_list) do
		v:DeleteMe()
	end
	self.top_list = {}
end

-- 打开后调用
function HunYinAllView:OpenCallBack()
	self.green:SetAsset(ResPath.GetItemIcon(HunQiData.Instance:GetHunYinItemIconId(self.green_cell_data.hunyin_id)))
	self.blue:SetAsset(ResPath.GetItemIcon(HunQiData.Instance:GetHunYinItemIconId(self.blue_cell_data.hunyin_id)))
	self.purple:SetAsset(ResPath.GetItemIcon(HunQiData.Instance:GetHunYinItemIconId(self.purple_cell_data.hunyin_id)))
	self.orange:SetAsset(ResPath.GetItemIcon(HunQiData.Instance:GetHunYinItemIconId(self.orange_cell_data.hunyin_id)))

	self.power_green:SetValue(CommonDataManager.GetCapability(self.hunyin_info[self.green_cell_data.hunyin_id][1]))
	self.power_blue:SetValue(CommonDataManager.GetCapability(self.hunyin_info[self.blue_cell_data.hunyin_id][1]))
	self.power_purple:SetValue(CommonDataManager.GetCapability(self.hunyin_info[self.purple_cell_data.hunyin_id][1]))
	self.power_orange:SetValue(CommonDataManager.GetCapability(self.hunyin_info[self.orange_cell_data.hunyin_id][1]))
end

-- 关闭前调用
function HunYinAllView:CloseCallBack()
	-- override
end

function HunYinAllView:ClickGreen()
	self:ShowAttrView(self.green_cell_data.hunyin_id)
end

function HunYinAllView:ClickBlue()
	self:ShowAttrView(self.blue_cell_data.hunyin_id)
end

function HunYinAllView:ClickPurple()
	self:ShowAttrView(self.purple_cell_data.hunyin_id)
end

function HunYinAllView:ClickOrange()
	self:ShowAttrView(self.orange_cell_data.hunyin_id)
end

function HunYinAllView:SlotClick(item_cell)
	local hunyin_id = item_cell:GetData().hunyin_id
	self:ShowAttrView(hunyin_id)
end

function HunYinAllView:ShowAttrView(hunyin_id)
	hunyin_id = hunyin_id or 0
	local data = self.hunyin_info[hunyin_id][1]
	local attr_info = CommonStruct.AttributeNoUnderline()
	attr_info.maxhp = data.maxhp
	attr_info.gongji = data.gongji
	attr_info.fangyu = data.fangyu
	attr_info.mingzhong = data.mingzhong
	attr_info.shanbi = data.shanbi
	attr_info.baoji = data.baoji
	attr_info.jianren = data.jianren
	for k,v in pairs(self.hunyin_all) do
	 	if v.hunyin_id == hunyin_id then
	 		attr_info.name = v.name
	 	end
	 end
	--TipsCtrl.Instance:ShowAttrView(attr_info)

	TipsCtrl.Instance:OpenGeneralView(attr_info, attr_info.name)
end

function HunYinAllView:ClickClosen()
	self:Close()
end
-----------------TopCell----------------------
TopCell = TopCell or BaseClass(BaseCell)
function TopCell:__init()
	self.name = self:FindVariable("name")
	self.effect = self:FindVariable("effect")
	self.img = self:FindVariable("img")
	self.power = self:FindVariable("power")
	self:ListenEvent("Click", BindTool.Bind(self.OnClick, self))
	self.hunyin_info = HunQiData.Instance:GetHunQiInfo()
end

function TopCell:__delete()
	self.name = nil
	self.effect = nil
	self.img = nil
	self.power = nil
end

function TopCell:OnFlush()
	local data = self:GetData()
	if nil ~= data then
		self.name:SetValue(data.name)
		local item_id = data.hunyin_id
		-- self.effect:SetAsset(ResPath.GetEffect(data.effect))
		self.img:SetAsset(ResPath.GetItemIcon(HunQiData.Instance:GetHunYinItemIconId(item_id)))
		local attr_data = self.hunyin_info[item_id][1]
		local attr_info = CommonStruct.AttributeNoUnderline()
		attr_info.maxhp = attr_data.maxhp
		attr_info.gongji = attr_data.gongji
		attr_info.fangyu = attr_data.fangyu
		attr_info.mingzhong = attr_data.mingzhong
		attr_info.shanbi = attr_data.shanbi
		attr_info.baoji = attr_data.baoji
		attr_info.jianren = attr_data.jianren
		self.power:SetValue(CommonDataManager.GetCapability(attr_info))
	end
end