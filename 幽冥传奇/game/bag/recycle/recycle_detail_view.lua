-- 已弃用

------------------------------------------------------------
-- 回收
------------------------------------------------------------
RecycleDetailView = RecycleDetailView or BaseClass(XuiBaseView)

function RecycleDetailView:__init()
	self:SetModal(true)
	-- self:SetIsAnyClickClose(true)
	self.config_tab = {
		{"bag_ui_cfg", 5, {0}},
	}

	self.numberbar_list = {}
end

function RecycleDetailView:__delete()
end

function RecycleDetailView:ReleaseCallBack()
	for k, v in pairs(self.numberbar_list) do
		v:DeleteMe()
	end
	self.numberbar_list = {}
end

function RecycleDetailView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		XUI.AddClickEventListener(self.node_t_list.btn_free.node, BindTool.Bind(self.OnClickToRecycle, self, 1))
		XUI.AddClickEventListener(self.node_t_list.btn_double.node, BindTool.Bind(self.OnClickToRecycle, self, 2))
		self.node_t_list.loongstone.node:setVisible(false)
		self.node_t_list.shadowstone.node:setVisible(false)
		self:CreateNumber()
	end
end

function RecycleDetailView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end


function RecycleDetailView:ShowIndexCallBack(index)
	self:Flush(0, "detail")
end

function RecycleDetailView:OnFlush(param_t, index)
	for k,v in pairs(param_t) do
		if k == "detail" then
			self:FlushDetail()
		end
	end
end

function RecycleDetailView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function RecycleDetailView:CreateNumber()
	for i = 1, 5 do
		local ph = self.ph_list["ph_" .. i]
		local number_bar = NumberBar.New()
		number_bar:GetView():setPosition(ph.x, ph.y)
		number_bar:GetView():setAnchorPoint(0, 1)
		number_bar:SetGravity(NumberBarGravity.Left)
		self.node_t_list.layout_equip_recycle_detail.node:addChild(number_bar:GetView(), 10)
		self.numberbar_list[i] = number_bar
	end

	self.numberbar_list[1]:SetRootPath(ResPath.GetBag("num_1_"))
	self.numberbar_list[2]:SetRootPath(ResPath.GetBag("num_3_"))
	self.numberbar_list[3]:SetRootPath(ResPath.GetBag("num_1_"))
	self.numberbar_list[4]:SetRootPath(ResPath.GetBag("num_1_"))
	self.numberbar_list[5]:SetRootPath(ResPath.GetBag("num_2_"))
	--self.numberbar_list[6]:SetRootPath(ResPath.GetBag("num_2_"))
	--self.numberbar_list[7]:SetRootPath(ResPath.GetBag("num_2_"))
end
function RecycleDetailView:FlushDetail()
	local recycle_detail = BagData.Instance:GetEquipRecycleDetail()
	if nil == recycle_detail.exp then
		return
	end

	local data = {
		[1] = recycle_detail.exp or 0,
		[2] = (recycle_detail.exp or 0) * 2,
		[3] = recycle_detail.jade_debris or 0,
		[4] = recycle_detail.bind_gold or 0,
		[5] = recycle_detail.fuwen or 0,
		-- [6] = recycle_detail.loongstone or 0,
		-- [7] = recycle_detail.shadowstone or 0
	}

	self.node_t_list.btn_double.node:setEnabled(recycle_detail.exp > 0)

	for k, v in pairs(self.numberbar_list) do
		v:SetNumber(data[k])
	end
	local bind_gold = GameMath.FormatNum(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BIND_GOLD))
	RichTextUtil.ParseRichText(self.node_t_list.rich_self_bind_gold.node, string.format(Language.Bag.OwnBindGold, bind_gold))
	RichTextUtil.ParseRichText(self.node_t_list.rich_cost_bind_gold.node, string.format(Language.Bag.DoubleRecycle,recycle_detail.exp > 0 and recycle_detail.doublepay_bindgold or 0))
end

function RecycleDetailView:OnClickToRecycle(btn_type)
	local recycle_type = BagData.Instance:GetRecycleSelectBtn()
	local recycle_list = BagData.Instance:GetRecycleList()
	local list, count  = BagData.Instance:GetEquipIndexAndSeriesTable(recycle_list)

	if count > 0 then
		BagCtrl.Instance:SendBagRecycleRewardReq(count, recycle_type, btn_type, list)
	end
	self:Close()
end

