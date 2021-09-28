TipsGongGaoView = TipsGongGaoView or BaseClass(BaseView)

function  TipsGongGaoView:__init()
	self.ui_config = {"uis/views/gonggaoview_prefab", "GongGaoView"}
end

function TipsGongGaoView:LoadCallBack()
	self.list_view = self:FindObj("Listview")
	self.page_num = self:FindVariable("page_num")
	self:ListenEvent("CloseWindow",
		BindTool.Bind(self.CloseWindow, self))

	self.cell_list = {}
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function TipsGongGaoView:ShowIndexCallBack()
	self:Flush()
end

function TipsGongGaoView:ReleaseCallBack()
	for _, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.list_view = nil
	self.page_num = nil
	self.cell_list = {}
end

function TipsGongGaoView:CloseWindow()
	local des = Language.Common.Gonggao
	function ok_callback()
		MainUIViewChat.Instance:SetGongGaoBtnVisible(false)
	 	self:Close()
	end
	function cancel_callback()
	 	self:Close()
	end
	TipsCtrl.Instance:ShowCommonAutoView("", des, ok_callback, cancel_callback)
end

function TipsGongGaoView:FlushGongGao()
	self.list_view.scroller:ReloadData(0)
end

function TipsGongGaoView:GetNumberOfCells()
	return TipsData.Instance:GetGongGaoDataNum()
end

function TipsGongGaoView:RefreshCell(cell, cell_index)
	local gonggao_data = TipsData.Instance:GetGongGaoData()
	if nil == gonggao_data then
		return
	end

	local item_cell = self.cell_list[cell]
	if nil == item_cell then
		item_cell = GongGaoItem.New(cell.gameObject)
		self.cell_list[cell] = item_cell
	end

	item_cell:SetData(gonggao_data[cell_index + 1])
	item_cell:Flush()
end

function TipsGongGaoView:OnFlush()
	local page = TipsData.Instance:GetGongGaoDataNum()
	self.page_num:SetValue(page)
	self.list_view.list_page_scroll:SetPageCount(page)
	self:FlushGongGao()
end


--------------------- item --------------------

GongGaoItem = GongGaoItem or BaseClass(BaseCell)

function GongGaoItem:__init()
	self.gonggao_text = self:FindVariable("gonggao_text")
	self.gonggao_pic = self:FindObj("raw_img")
	self.is_pic = self:FindVariable("is_pic")
	self.is_text = self:FindVariable("is_text")
	self.is_pic:SetValue(false)
end

function GongGaoItem:__delete()
	self.gonggao_text = nil
	self.gonggao_pic = nil
end

function GongGaoItem:SetData(data)
	self.data = data
	if self.data and self.data.content and self.data.content ~= "" then
		self.is_text:SetValue(true)
		self.gonggao_text:SetValue(self.data.content)
	else
		self.is_text:SetValue(false)
	end
end

function GongGaoItem:OnFlush()
	if self.data and self.data.img_url and type(self.data.img_url) == "table" then
		local url = self.data.img_url.url
		local path = ResPath.GetFilePath2(self.data.img_url.name)

		local load_callback = function ()
		if nil == self.gonggao_pic or IsNil(self.gonggao_pic.gameObject) then
				return
			end
			local avatar_path = path
			self.gonggao_pic.raw_image:LoadSprite(avatar_path,
			function()
				self.is_pic:SetValue(true)
			end)
		end
		HttpClient:Download(url, path, load_callback)
	end
end