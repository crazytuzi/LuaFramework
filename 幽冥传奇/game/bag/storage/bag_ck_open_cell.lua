BagCkOpenCellView = BagCkOpenCellView or BaseClass(BaseView)
OpenCellModel = OpenCellModel or BaseClass()
BagOpenCellModel = BagOpenCellModel or BaseClass(OpenCellModel)
StorageOpenCellModel = StorageOpenCellModel or BaseClass(OpenCellModel)

function BagCkOpenCellView:__init()
	self:SetModal(true)
	self:SetIsAnyClickClose(true)

	self.config_tab = {
		{"storage_ui_cfg", 6, {0}},
		{"storage_ui_cfg", 7, {0}},
	}


	self.model_list = {}
	self.model_list[ViewDef.MainBagView.BagView] = BagOpenCellModel.New(ResPath.GetBag("titile_open_bag"), "花费元宝可永久开启背包格子")
	self.model_list[ViewDef.Storage] = StorageOpenCellModel.New(ResPath.GetBag("titile_open_storage"), "花费钻石可永久开启仓库格子")
	self.model = self.model_list[ViewDef.MainBagView.BagView]

	self.cell_id = 0
	self.bag_open_num = 0
end

function BagCkOpenCellView:__delete()
	for k,v in pairs(self.model_list) do
		v:DeleteMe()
	end
	self.model_list = {}
end

function BagCkOpenCellView:ReleaseCallBack()
	if nil ~= self.pop_num_view then
		self.pop_num_view:DeleteMe()
		self.pop_num_view = nil
	end
end

function BagCkOpenCellView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self.node_t_list.btn_OK.node:addClickEventListener(BindTool.Bind(self.OnClickOK, self))
		self.node_t_list.btn_max.node:addClickEventListener(BindTool.Bind(self.OnClickGetMaxNumView, self))
		XUI.AddClickEventListener(self.node_t_list.btn_cell_add.node, BindTool.Bind(self.OnClickChageNumView, self, true))
		XUI.AddClickEventListener(self.node_t_list.btn_cell_reduce.node, BindTool.Bind(self.OnClickChageNumView, self, false))
		XUI.AddClickEventListener(self.node_t_list.img9_open_num.node, BindTool.Bind(self.OnClickOpenNumView, self))
		self.pop_num_view = NumKeypad.New()
		self.pop_num_view:SetOkCallBack(BindTool.Bind1(self.OnOKCallBack, self))

		self.model:SetNumChage(1) --默认5
		self:FlushNumShow()
	end
end
	
function BagCkOpenCellView:OpenCallBack()
end

function BagCkOpenCellView:CloseCallBack()
	self.node_t_list.lbl_open_num.node:setString(0)
	self.node_t_list.lbl_consume.node:setString(0)
	self.pop_num_view:SetText(0)
end

function BagCkOpenCellView:ShowIndexCallBack()
	local res_info = self.model:GetResInfo()
	local content_size = self.root_node:getContentSize()
	self:CreateTopTitle(res_info.title_path, content_size.width / 2, content_size.height - 35)
	self.node_t_list.txt_tip_1.node:setString(res_info.tip_txt)
	if self.model then
		XUI.SetButtonEnabled(self.node_t_list.btn_max.node, not (self.model:GetCanExptendNum() == 0))
	end
end

function BagCkOpenCellView:SetViewForm(view_def)
	if self.model_list[view_def] then
		self.model = self.model_list[view_def]
		self:Open()
	else
		self:CloseHelper()
	end
end
	

function BagCkOpenCellView:FlushNumShow()
	local need_gold = self.model:GetNeedGold()
	local open_num = self.model:GetOpenNum()

	self.node_t_list.lbl_open_num.node:setString(open_num)
	self.node_t_list.lbl_consume.node:setString(need_gold)

	local role_gold = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD)
	self.node_t_list.lbl_consume.node:setColor(role_gold < need_gold and COLOR3B.RED or COLOR3B.GREEN)	
	--XUI.SetButtonEnabled(self.node_t_list.btn_max.node, not (self.model:GetCanExptendNum() == 0) )
	
end

function BagCkOpenCellView:OnClickOK()
	self.model:SendReq()
	self:Close()
end
	
function BagCkOpenCellView:OnClickGetMaxNumView()
	self.model:SetMaxNum()
	self:FlushNumShow()
end

function BagCkOpenCellView:OnClickChageNumView(is_add)
	self.model:SetNumChage(is_add and 1 or -1)
	self:FlushNumShow()
end

function BagCkOpenCellView:OnClickOpenNumView()
	self.pop_num_view:Open()
	self.pop_num_view:SetText(self.model:GetOpenNum()) --默认5
end

function BagCkOpenCellView:OnOKCallBack(num)
	self.model:SetNumChage(num - self.model:GetOpenNum())
	self:FlushNumShow()
end

function BagCkOpenCellView:OnClickRecharge()
	ViewManager.Instance:OpenViewByDef(ViewDef.ZsVip.Recharge)
	-- self:Close()
end

---------------------------------------------------
--				OpenCellModel
---------------------------------------------------
function OpenCellModel:__init(title_path, tip_txt)
	self.need_gold_ = 0
	self.title_path_ = title_path or ""
	self.tip_txt_ = tip_txt or ""
	self.open_num_ = 0
end

function OpenCellModel:__delete()
end

--UI回调
function OpenCellModel:SetDefualtNum()
	self.open_num = 1
	self:UpdateNeedGold()
end

function OpenCellModel:SetMaxNum()
	self:SetNumChage(9999)
end

function OpenCellModel:SetNumChage(num)
	local max_num = self:GetCanExptendNum()
	if max_num == 0 then
		SysMsgCtrl.Instance:ErrorRemind("可购买次数已用完")
		return
	end
	if self.open_num_ + num < 0 then return end
	if self.open_num_ + num > max_num then
		SysMsgCtrl.Instance:ErrorRemind("已达最大购买次数")
		self.open_num_ = max_num
	else
		self.open_num_ = self.open_num_ + num
	end

	self:UpdateNeedGold()
end

--数据相关
function OpenCellModel:GetOpenNum()
	return self.open_num_ or 0
end

function OpenCellModel:GetNeedGold()
	return self.need_gold_ or 0
end

--资源相关	
function OpenCellModel:GetResInfo()
	return {title_path = self.title_path_, tip_txt = self.tip_txt_}
end

---------重写--------
--计算所需元宝
function OpenCellModel:UpdateNeedGold()
end

--获取最大数量
function OpenCellModel:GetCanExptendNum()
end

--请求
function OpenCellModel:SendReq()
end

--------------------------------------
--              end
--------------------------------------




---------------背包数据---------------
--请求
function BagOpenCellModel:SendReq()
	if self:GetCanExptendNum() == 0 then
		SysMsgCtrl.Instance:ErrorRemind("可购买次数已用完")
		return
	end
	BagCtrl.Instance:SendExpandBagReq(self.open_num_)
end

function BagOpenCellModel:UpdateNeedGold()
	self.need_gold_ = self.open_num_ * BagConfig.speedCount
end

function BagOpenCellModel:GetCanExptendNum()
	local buy_grid_num = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BAG_BUY_GRID_COUNT)
	local vip_num = 0
	for i = 1, 12 do
		vip_num = vip_num + VipConfig.VipGrade[i].bagAddGrid
	end
	return  BagConfig.max - vip_num - buy_grid_num
end

---------------end-----------------------



--------------仓库数据-------------------
--请求
function StorageOpenCellModel:SendReq()
	if self:GetCanExptendNum() == 0 then
		SysMsgCtrl.Instance:ErrorRemind("可购买次数已用完")
		return
	end
	local storage_grid_count = bit:_rshift(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_STALL_GRID_COUNT), 16)
	local cell_id = storage_grid_count + self.open_num_
	BagCtrl.Instance:SendStorageBuyCell(cell_id)
end


function StorageOpenCellModel:UpdateNeedGold()
	local storage_grid_count = bit:_rshift(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_STALL_GRID_COUNT), 16) - 30
	local num = 0
	for i = storage_grid_count + 1, storage_grid_count + self.open_num_ do
		local gold = UserDepotCfg.ActivateGridsNeedYb[i] or 0
		num = num + gold
	end
	self.need_gold_ = num
end

function StorageOpenCellModel:GetCanExptendNum()
	local storage_grid_count = bit:_rshift(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_STALL_GRID_COUNT), 16) - 30
	return  #UserDepotCfg.ActivateGridsNeedYb - storage_grid_count
end
-----------------end------------------------
