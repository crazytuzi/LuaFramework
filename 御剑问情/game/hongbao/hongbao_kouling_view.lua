HongBaoKoulingView = HongBaoKoulingView or BaseClass(BaseView)

function HongBaoKoulingView:__init()
	self.ui_config = {"uis/views/tips/hongbaotips_prefab","PasswordHongBaoDetailView"}
	self.play_audio = true
	self.data = nil
	self.is_open_view = false
	self.data_list = {}
end

function HongBaoKoulingView:__delete()

end

function HongBaoKoulingView:ReleaseCallBack()
	if next(self.cell_list) then
		for _,v in pairs(self.cell_list) do
			if v then
				v:DeleteMe()
			end
		end
		self.cell_list = {}
	end
	self.raw_image_obj = nil
	self.image_res = nil
	self.red_pocket_list = nil
	self.have_mine = nil
	self.from_name = nil
	self.money_text = nil
	self.kouling = nil
	self.has_open = nil
	self.show_image = nil
end

function HongBaoKoulingView:LoadCallBack()
	self.have_mine = self:FindVariable("have_mine")
	self.from_name = self:FindVariable("FromName")
	self.money_text = self:FindVariable("MoneyText")
	self.kouling = self:FindVariable("Kouling")
	self.has_open = self:FindVariable("IsOpen")

	--头像
	self.raw_image_obj = self:FindObj("raw_image_obj")
	self.image_res = self:FindVariable("image_res")
	self.show_image = self:FindVariable("show_image")

	self.cell_list = {}
	self.red_pocket_list = self:FindObj("PanelList")
	local list_delegate = self.red_pocket_list.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self:ListenEvent("OnClickSend", BindTool.Bind(self.OnClickSend, self))
	self:ListenEvent("OnClickClose", BindTool.Bind(self.OnClickClose, self))
end


function HongBaoKoulingView:GetNumberOfCells()
	return #self.data_list
end

function HongBaoKoulingView:RefreshCell(cell, data_index)
	local decs_item = self.cell_list[cell]
	if decs_item == nil then
		decs_item = RedPocketListItemRender.New(cell.gameObject)
		self.cell_list[cell] = decs_item
	end
	local fetch_info_list = self.data_list
	decs_item:SetData(fetch_info_list[data_index + 1])
end

function HongBaoKoulingView:ShowIndexCallBack()

end

function HongBaoKoulingView:OpenCallBack()
	self.data = HongBaoData.Instance:GetKoulingRedPaperInfo()
	self:Flush()
end


function HongBaoKoulingView:OnFlush(param_t)
	if nil == self.data then
		return
	end
	for k,v in pairs(param_t) do
		if k == "all" then
			self.have_mine:SetValue(true)
			self.from_name:SetValue(self.data.creater_name)
			self.kouling:SetValue(self.data.kouling_msg)
			self.has_open:SetValue(true)
			local cfg = ConfigManager.Instance:GetAutoConfig("commandspeaker_auto").other[1]
			self.money_text:SetValue(cfg.reward_role_limit * cfg.bind_gold_num)
			CommonDataManager.NewSetAvatar(self.data.creater_uid, self.show_image, self.image_res, self.raw_image_obj, self.data.sex, self.data.prof, false)
		elseif k == "detail" then
			self.is_open_view = true
			self.has_open:SetValue(false)
			local info = HongBaoData.Instance:GetOneKoulingRedPaper(self.data.id)
			if info then
				self.data_list = info.log_list
				local has_mine = false
				local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
			    for k,v in pairs(self.data_list) do
			        if role_id == v.uid then
			            has_mine = true
			            self.money_text:SetValue(v.gold_num)
			        end
			    end
			    self.have_mine:SetValue(has_mine)
			end
		end
	end
end


function HongBaoKoulingView:OnClickSend()
	if nil == self.data then return end
	HongBaoCtrl.Instance:SendFetchCommandRedPaper(self.data.id)
end

function HongBaoKoulingView:OnClickClose()
	self:Close()
end

function HongBaoKoulingView:CloseCallBack()
	if self.data then
		HongBaoData.Instance:RemoveKoulingRedPaper(self.data.id)
	end
	self.data = nil
	self.is_open_view = false
	self.data_list = {}
end

-----------------------------------------------------------
RedPocketListItemRender = RedPocketListItemRender or BaseClass(BaseCell)

function RedPocketListItemRender:__init()
	self.lbl_name = self:FindVariable("Name")
	self.lbl_red_gold = self:FindVariable("Score")
	self.biggest = self:FindVariable("IsLuck")
end

function RedPocketListItemRender:__delete()
	self.lbl_name = nil
	self.lbl_red_gold = nil
	self.biggest = nil
end

function RedPocketListItemRender:OnFlush()
	if not self.data then return end
	self.lbl_name:SetValue(self.data.name)
	self.lbl_red_gold:SetValue(self.data.gold_num)
	local zuijia_id = GuildData.Instance:GetRedPocketZuiJia()
	self.biggest:SetValue(zuijia_id == self.data.uid)
end