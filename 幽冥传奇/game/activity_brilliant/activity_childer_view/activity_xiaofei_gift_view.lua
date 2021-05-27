QMXiaoFeiView = QMXiaoFeiView or BaseClass(ActBaseView)

function QMXiaoFeiView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function QMXiaoFeiView:__delete()
	if self.xiaofei_progressbar then
		self.xiaofei_progressbar:DeleteMe()
		self.xiaofei_progressbar = nil
	end

	if self.xf_grid then
		self.xf_grid:DeleteMe()
		self.xf_grid = nil
	end

	if self.xiaofei_reward_list then 
		self.xiaofei_reward_list:DeleteMe()
		self.xiaofei_reward_list = nil
	end

	if self.xf_cell then
		self.xf_cell:DeleteMe()
		self.xf_cell = nil
	end
end

function QMXiaoFeiView:InitView()
	self.bar_pos_two = {0, 20, 50}
	self.act_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.QMXF)
	if nil == self.act_cfg then 
		return
	end
	self.xf_list = ActivityBrilliantData.Instance:GetXiaofeiSignList(ACT_ID.QMXF)
	self.xf_list[0] = table.remove(self.xf_list, 1)

	self.xf_cell = nil
	self:CreateXiaofeiGiftRewards(self.act_cfg.act_id)
	self:CreateXFGridScroll()
	self:CreateXFProgressbar()
	self:FlushGiftReward(2)
	self.node_t_list.layout_qm_xiaofei.btn_lingqu_2.node:addClickEventListener(BindTool.Bind(self.OnClicLingquHandler, self, 2))
	self.node_t_list.layout_qm_xiaofei.btn_lingqu.node:addClickEventListener(BindTool.Bind(self.OnClicLingquHandler, self, 1))
end

function QMXiaoFeiView:RefreshView(param_list)
	local list = ActivityBrilliantData.Instance:GetXiaofeiSignList(28)
	local can_lingqu_list = ActivityBrilliantData.Instance:GetAutoLingquList(list)
	local is_lingqu_2 = ActivityBrilliantData.Instance.sign_2[ACT_ID.QMXF] == 0 and ActivityBrilliantData.Instance.consum_gold[ACT_ID.QMXF] >= self.act_cfg.config[1].one
	local is_lingqu_3 = ActivityBrilliantData.Instance.sign_2[ACT_ID.QMXF] ~= 0 and ActivityBrilliantData.Instance.consum_gold[ACT_ID.QMXF] >= self.act_cfg.config[1].one
	self.node_t_list.lbl_xiaofei_tip.node:setString(ActivityBrilliantData.Instance.consum_gold[ACT_ID.QMXF])
	self.node_t_list.layout_qm_xiaofei.btn_lingqu.node:setEnabled(is_lingqu_2)
	self.node_t_list.layout_qm_xiaofei.img_xf_reward_state.node:setVisible(is_lingqu_3)
	self.node_t_list.layout_qm_xiaofei.img_xf_reward_state.node:setLocalZOrder(999)
	self.xf_grid:SetDataList(self.xf_list)
	for k,v in pairs(param_list) do
		if k == "flush_view" then
			self.node_t_list.layout_qm_xiaofei.btn_lingqu_2.node:setEnabled(nil ~= can_lingqu_list[1])
			if nil == can_lingqu_list[1] then return end
			self:FlushGiftReward(can_lingqu_list[1].index + 1)
			self.xf_grid:SelectCellByIndex(can_lingqu_list[1].index -1)
			self.xf_grid:ChangeToPage(math.floor(can_lingqu_list[1].index / 4) + 1)

			local per = self:GetGiftBarPer(math.floor(can_lingqu_list[1].index / 4) + 1)
			self.xiaofei_progressbar:SetPercent(per,false)
		end
	end
end

local reward_index = 2
function QMXiaoFeiView:CreateXFGridScroll()
	if nil == self.act_cfg then return end
	local ph_shouhun = self.ph_list.ph_xiaofei_gift_list
	local list = ActivityBrilliantData.Instance:GetXiaofeiSignList(ACT_ID.QMXF)
	local cell_num = #self.act_cfg.config - 1
	if nil == self.xf_grid  then
		self.xf_grid = BaseGrid.New() 
		local grid_node = self.xf_grid:CreateCells({w = ph_shouhun.w, h = ph_shouhun.h, itemRender = XiaofeiItemRender, ui_config = self.ph_list.ph_xiaofei_item, cell_count = cell_num, col = 3, row = 1})
		self.node_t_list.layout_qm_xiaofei.node:addChild(grid_node, 10)
		self.xf_grid:GetView():setPosition(ph_shouhun.x, ph_shouhun.y)
		self.xf_grid:SetSelectCallBack(BindTool.Bind(self.SelectRewardCallBack, self))
		self.xf_index = self.xf_grid:GetCurPageIndex()
		self.xf_grid:SetPageChangeCallBack(BindTool.Bind(self.OnGiftPageChangeCallBack, self))
		self.xf_grid:SelectCellByIndex(0)
		self.xf_grid:SetDataList(self.xf_list)
	end
end

function QMXiaoFeiView:OnGiftPageChangeCallBack(grid, page_index, prve_page_index)
	self:FlushGiftReward(page_index * 3 - 1)
	self.xf_grid:SelectCellByIndex((page_index - 1) * 3)
	local per = self:GetGiftBarPer(page_index)
	self.xiaofei_progressbar:SetPercent(per,false)
end


function QMXiaoFeiView:SelectRewardCallBack(render)
	self:FlushGiftReward(render:GetIndex() + 2)
end

function QMXiaoFeiView:CreateXFProgressbar()
	local per = self:GetGiftBarPer(1)
	self.xiaofei_progressbar = ProgressBar.New()
	self.xiaofei_progressbar:SetView(self.node_t_list.prog9_qh.node)
	self.xiaofei_progressbar:SetTailEffect(991, nil, true)
	self.xiaofei_progressbar:SetEffectOffsetX(-20)
	self.xiaofei_progressbar:SetPercent(per,false)
end

function QMXiaoFeiView:GetGiftBarPer(page_index)
	local index = 0
	local page_index = page_index
	for i = 2, #self.act_cfg.config do
		local consum_gold = self.act_cfg.config[i].numbers
		if ActivityBrilliantData.Instance.consum_gold[ACT_ID.QMXF] < consum_gold  then
			index = i - 2
			break
		else
			index = 999
		end
	end
	local per = 100 
	if index == 999 then 
		per = 100
	elseif index >= 3 and nil == page_index then
		per = 100 
	elseif page_index and page_index > 1 and index > 3 then 
		per = self.bar_pos_two[index % 3 + 1]
	elseif page_index and page_index > 1 and index <= 3 then
		per = self.bar_pos_two[1]
	elseif  index < 3 then
		per = self.bar_pos_two[index + 1]
	else
		per = 100
	end
	return per
end

function QMXiaoFeiView:CreateXiaofeiGiftRewards(act_id)
	--左侧奖励
	self.xiaofei_reward_list = ListView.New()
	self.xiaofei_reward_list:Create(20, 123, 440, 90, ScrollDir.Horizontal, ActBaseCell, ListViewGravity.CenterVertical, false, {w = 80, h = 80})
	self.xiaofei_reward_list:SetItemsInterval(10)
	self.xiaofei_reward_list:GetView():setAnchorPoint(0, 0)
	self.xiaofei_reward_list:SetMargin(8)
	self.node_t_list.layout_qm_xiaofei.node:addChild(self.xiaofei_reward_list:GetView(), 100)
	--右侧奖励
	if nil == self.xf_cell then
		self.xf_cell = ActBaseCell.New()
		local ph = self.ph_list.ph_xf_cell
		self.xf_cell:SetPosition(ph.x, ph.y)
		self.xf_cell:SetAnchorPoint(0.5, 0.5)
		self.node_t_list.layout_qm_xiaofei.node:addChild(self.xf_cell:GetView(), 500)
	end
	if nil ~= self.act_cfg.config then
		local data =  self.act_cfg.config[1].award[1]
		if data.type == tagAwardType.qatEquipment then
			self.xf_cell:SetData({["item_id"] = data.id, ["num"] = data.count, is_bind = data.bind, effectId = data.effectId})
		else
			local virtual_item_id = ItemData.GetVirtualItemId(data.type)
			if virtual_item_id then
				self.xf_cell:SetData({["item_id"] = virtual_item_id, ["num"] = data.count, is_bind = 0, effectId = data.effectId})
			end
		end
	else
		self.xf_cell:SetData(nil)
	end
	self.node_t_list.lbl_text_1.node:setString(string.format(Language.ActivityBrilliant.Text8, self.act_cfg.config[1].one or 0 ))
end

function QMXiaoFeiView:OnClicLingquHandler(tag)
	local opreat_index = 0
	if tag == 2 then
		opreat_index = reward_index
	elseif tag == 1 then
		opreat_index = 1
	end
	local act_id = ACT_ID.QMXF
	ActivityBrilliantCtrl.Instance.ActivityReq(4, act_id,opreat_index)
end

function QMXiaoFeiView:FlushGiftReward(index)
	local tag = (index - 1) % 3  == 0 and 3 or (index - 1) % 3
	local ph = 128 + (tag - 1) * 140
	reward_index = index
	local list = ActivityBrilliantData.Instance:GetXiaofeiSignList(ACT_ID.QMXF)
	local consum_gold = self.act_cfg.config[index].numbers
	self.node_t_list.layout_qm_xiaofei.btn_lingqu_2.node:setEnabled(list[index - 1].sign == 0 and consum_gold <= ActivityBrilliantData.Instance.consum_gold[ACT_ID.QMXF])
	self.node_t_list.layout_qm_xiaofei.xunbao_arrow.node:setPositionX(ph)
	local data_list = {}
	if self.act_cfg then
		for _, v in pairs(self.act_cfg.config[index].award) do
			table.insert(data_list, ItemData.FormatItemData(v))
		end
	end
	self.xiaofei_reward_list:SetDataList(data_list)
end

XiaofeiItemRender = XiaofeiItemRender or BaseClass(BaseRender)
function XiaofeiItemRender:__init()
	self:AddClickEventListener()
end

function XiaofeiItemRender:__delete()
	if nil ~= self.cell_charge_list then
    	for k,v in pairs(self.cell_charge_list) do
    		v:DeleteMe()
  		end
    	self.cell_charge_list = nil
    end
end

function XiaofeiItemRender:CreateChild()
	BaseRender.CreateChild(self)
	local index = self:GetIndex()
	local act_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.QMXF)
	if nil == act_cfg or nil == act_cfg.config[index + 2] then return end
	local consum_gold = act_cfg.config[index + 2].numbers
	self.node_tree.lbl_consum_gold.node:setString(string.format(Language.ActivityBrilliant.Text6, consum_gold))
end

function XiaofeiItemRender:OnFlush()
	local index = self:GetIndex()
	local act_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.QMXF)
	if nil == act_cfg or nil == act_cfg.config[index + 2] then return end
	local consum_gold = act_cfg.config[index + 2].numbers
	if consum_gold and consum_gold <= ActivityBrilliantData.Instance.consum_gold[ACT_ID.QMXF] then
		self.node_tree.text_4.node:loadTexture(ResPath.GetActivityBrilliant("text_5"))
	end
end

function XiaofeiItemRender:OnClick()
	local index = self:GetIndex() + 2
	if nil ~= self.click_callback then
		self.click_callback(self)
	end
end

function XiaofeiItemRender:CreateSelectEffect()
	local size = self.view:getContentSize()
	self.select_effect = XUI.CreateImageViewScale9(size.width / 2, size.height / 2 , size.width - 20, size.height - 90, ResPath.GetCommon("cell_112_select"), true)
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end

	self.view:addChild(self.select_effect, 999)
end