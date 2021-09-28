HunYinExchangView = HunYinExchangView or BaseClass(BaseView)

HunYinExchangView.Middle_ShengLing_Type = 11					-- 中级圣灵兑换类型
HunYinExchangView.High_ShengLing_Type = 12						-- 高级圣灵兑换类型
HunYinExchangView.Top_ShengLing_Type = 13						-- 顶级圣灵兑换类型

function HunYinExchangView:__init()
	self.ui_config = {"uis/views/hunqiview_prefab", "HunYinExchange"}
	self.convert_cfg = ExchangeData.Instance:GetHunYinExchangeCfg()
	self.middle__type_shengling = {}
	self.high__type_shengling = {}
	self.top__type_shengling = {}
	for k,v in pairs(self.convert_cfg) do
		if HunYinExchangView.Middle_ShengLing_Type == v.price_type then
			table.insert(self.middle__type_shengling, v) 
		end
		if HunYinExchangView.High_ShengLing_Type == v.price_type then
			table.insert(self.high__type_shengling, v) 
		end
		if HunYinExchangView.Top_ShengLing_Type == v.price_type then
			table.insert(self.top__type_shengling, v) 
		end
	end	
	self.exchenge_cell_count = #self.middle__type_shengling
	self.current_shengling_info = {}
end

function HunYinExchangView:__delete()
		
end

function HunYinExchangView:LoadCallBack()
	self:ListenEvent("ClickClosen", BindTool.Bind(self.ClickClosen, self))
	self:ListenEvent("ClickMiddle", BindTool.Bind(self.ClickMiddle, self))
	self:ListenEvent("ClickSenior", BindTool.Bind(self.ClickSenior, self))
	self:ListenEvent("ClickClimax", BindTool.Bind(self.ClickClimax, self))
	self:ListenEvent("ClickAdd", BindTool.Bind(self.ClickAdd, self))

	self.lingzhi_icon = self:FindVariable("lingzhi_icon")
	self.lingzhi_count = self:FindVariable("lingzhi_count")

	self.exchange_list = {}
    self.exchange_list_obj = self:FindObj("ExchangeList")
    local page_simple_delegate = self.exchange_list_obj.page_simple_delegate
    page_simple_delegate.NumberOfCellsDel = BindTool.Bind(self.NumberOfCellsDel, self)
    page_simple_delegate.CellRefreshDel = BindTool.Bind(self.CellRefreshDel, self)

    self.button_list = {}
    for i=1,3 do
    	local btn = self:FindObj("Button_"..i)
    	table.insert(self.button_list, btn)
    end
end

-- 销毁前调用
function HunYinExchangView:ReleaseCallBack()
	self.exchange_list_obj = nil
	self.lingzhi_icon = nil
	self.lingzhi_count = nil
	self.button_group_obj = nil
	self.button_list = {}
	
	for k,v in pairs(self.exchange_list) do
		v:DeleteMe()
	end
	self.exchange_list = {}
end

-- 打开后调用
function HunYinExchangView:OpenCallBack()
	self:ClickMiddle()
end

-- 关闭前调用
function HunYinExchangView:CloseCallBack()
	self.button_list[1].toggle.isOn = true
end

--显示对应种类的圣灵
function HunYinExchangView:FlushHomologousView(type_shengling_info)
	if nil ~= next(type_shengling_info) then
		self.current_shengling_info = type_shengling_info
		self.exchenge_cell_count = #self.current_shengling_info
		self.exchange_list_obj.list_view:JumpToIndex(0)
		self.exchange_list_obj.list_view:Reload()
    	self.all_lingzhi = ExchangeData.Instance:GetAllLingzhi()	
	end
end

function HunYinExchangView:NumberOfCellsDel()
	return self.exchenge_cell_count
end

-- cell刷新 每个进入一次
function HunYinExchangView:CellRefreshDel(data_index, cell)
	data_index = data_index + 1
	local data = self.current_shengling_info[data_index]
	local item_cell = self.exchange_list[cell]
	if nil == item_cell then
		item_cell = ExchangeCell.New(cell.gameObject)
		self.exchange_list[cell] = item_cell
	end
	item_cell:SetClickCallBack(BindTool.Bind(self.ClickExchange, self))
	item_cell:SetIndex(data_index)
	item_cell:SetData(data)
end

function HunYinExchangView:ClickAdd()
	ViewManager.Instance:Open(ViewName.HunYinResolve)
	self:Close()
end

function HunYinExchangView:ClickExchange(item_cell)
	local item_data = item_cell:GetData()
	ExchangeCtrl.Instance:SendScoreToItemConvertReq(item_data.conver_type, item_data.seq, 1)
end

function HunYinExchangView:FlushLingzhiCount()
	self.all_lingzhi = ExchangeData.Instance:GetAllLingzhi()
	self.lingzhi_count:SetValue(self.all_lingzhi[self.current_type])
end

function HunYinExchangView:ClickMiddle()
	self:FlushHomologousView(self.middle__type_shengling)
	self.lingzhi_count:SetValue(self.all_lingzhi.blue)
	self.lingzhi_icon:SetAsset(ResPath.GetHunQiImg("lanlingzhi"))
	self.current_type = "blue"
end

function HunYinExchangView:ClickSenior()
 	self:FlushHomologousView(self.high__type_shengling)
 	self.lingzhi_count:SetValue(self.all_lingzhi.purple)
	self.lingzhi_icon:SetAsset(ResPath.GetHunQiImg("zilingzhi"))
	self.current_type = "purple"
end

function HunYinExchangView:ClickClimax()
	self:FlushHomologousView(self.top__type_shengling)
	self.lingzhi_count:SetValue(self.all_lingzhi.orange)
	self.lingzhi_icon:SetAsset(ResPath.GetHunQiImg("chenglingzhi"))
	self.current_type = "orange"
end

function HunYinExchangView:ClickClosen()
	self:Close()
end

------------------ExchangeCell--------------------
ExchangeCell = ExchangeCell or BaseClass(BaseCell)
function ExchangeCell:__init()
	self.current_cost = self:FindVariable("cost")
	self.curren_name = self:FindVariable("name")
	self.cost_img = self:FindVariable("cost_img")

	self.item_cell_parent = self:FindObj("item_cell")
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.item_cell_parent)
	self.item_cell:SetData({})
--兑换	
	self:ListenEvent("ClickExchange", BindTool.Bind(self.OnClick, self))

end

function ExchangeCell:__delete()
	self.current_cost = nil
	self.curren_name = nil
	self.curren_icon = nil
	self.item_cell_parent = nil
	self.cost_img = nil

	self.item_cell:DeleteMe()
	self.item_cell = nil
end

function ExchangeCell:OnFlush()
	local data = self:GetData()
	if data.price_type == HunYinExchangView.Middle_ShengLing_Type then
		self.cost_img:SetAsset(ResPath.GetHunQiImg("lanlingzhi"))
	elseif  data.price_type == HunYinExchangView.High_ShengLing_Type then
		self.cost_img:SetAsset(ResPath.GetHunQiImg("zilingzhi"))
	else
		self.cost_img:SetAsset(ResPath.GetHunQiImg("chenglingzhi"))
	end
	self.current_cost:SetValue(data.price)
	local name = ItemData.Instance:GetItemConfig(data.item_id).name
	self.curren_name:SetValue(name)

	local icon = HunQiData.Instance:GetHunYinItemIconId(data.item_id)
	if 0 == icon then
		icon = HunQiData.Instance:GetGiftItemIconId(data.item_id)
	end
	--self.item_cell.icon:SetAsset(ResPath.GetItemIcon(icon))
	self.item_cell:SetData(data)
end