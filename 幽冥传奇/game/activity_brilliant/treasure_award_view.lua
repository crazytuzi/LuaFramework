TreasureAwardView = TreasureAwardView or BaseClass(XuiBaseView)

function TreasureAwardView:__init(index)
	if TreasureAwardView.Instance then
		ErrorLog("[TreasureAwardView] Attemp to create a singleton twice !")
	end
	self.texture_path_list[1] = "res/xui/activity_brilliant.png"
	self.config_tab = {
		{"itemtip_ui_cfg", 18, {0}}
	}
	self.item_config_bind = BindTool.Bind(self.FlushAwardCell, self)
	

	self:SetIsAnyClickClose(true)
	self.index = index
	self.cfg = {}
end

function TreasureAwardView:__delete()
	self.index = nil
	self.cfg = nil
	if self.award_cell_list then
    	self.award_cell_list:DeleteMe()
    	self.award_cell_list = nil
   	end
end

function TreasureAwardView:ReleaseCallBack()
	if ItemData.Instance then
		ItemData.Instance:UnNotifyItemConfigCallBack(self.item_config_bind)
	end
end

function TreasureAwardView:OpenCallBack()
	
end

function TreasureAwardView:CloseCallBack()
end

function TreasureAwardView:LoadCallBack()
	ItemData.Instance:NotifyItemConfigCallBack(self.item_config_bind)
	self.cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.SLLB)
	self:InitAwardCell()
	self.node_t_list.btn_lingqu.node:addClickEventListener(BindTool.Bind(self.OnClickLinQu, self))
end

function TreasureAwardView:ShowIndexCallBack()
	self:Flush()
end

function TreasureAwardView:InitAwardCell()
	self.award_cell_list = {}
	for i = 1, 4 do
		local cell_ph = nil
		cell_ph = self.ph_list["ph_cell_".. i]
		if nil == cell_ph then
			break
		end
		local cell = BaseCell.New()
		cell:SetPosition(cell_ph.x, cell_ph.y)
		cell:SetIndex(i)
		cell:SetAnchorPoint(0.5, 0.5)
		self.node_t_list.layout_award_bg.node:addChild(cell:GetView(), 103)
		table.insert(self.award_cell_list, cell)
	end
end

function TreasureAwardView:FlushAwardCell()
	if nil == self.cfg then return end
   	for k,v in pairs(self.cfg.config.integralAward[self.index].award) do
   		local data = ItemData.Instance:GetItemConfig(v.id)
   		if data then
   			self.award_cell_list[k]:SetData({item_id = data.item_id, icon = data.icon, num = v.count, is_blind = v.blind})
   		end
   	end	
   	local num = 4 - #self.cfg.config.integralAward[self.index].award
   	if num > 0 then
   		for i =1, num do
   			self.award_cell_list[4 - i + 1]:GetView():setVisible(false)
   		end

   		for i = 1, #self.cfg.config.integralAward[self.index].award do
   			local cell_ph = nil
   			cell_ph = self.ph_list["ph_cell_".. i]
   			if num == 1 then
   				self.award_cell_list[i]:SetPosition(cell_ph.x + 50, cell_ph.y)
   			elseif num == 2 then
   				self.award_cell_list[i]:SetPosition(cell_ph.x + 100, cell_ph.y)
   			elseif num == 3 then
   				self.award_cell_list[i]:SetPosition(cell_ph.x + 150, cell_ph.y)
   			end
   		end
   	end
end

function TreasureAwardView:OnFlush()
	self:FlushAwardCell()
	local score = ActivityBrilliantData.Instance:GetTreasureScore()
	if score >= self.cfg.config.integralAward[self.index].needIntegral then
		self.node_t_list.btn_lingqu.node:setEnabled(true)
	else
		self.node_t_list.btn_lingqu.node:setEnabled(false)
	end
end

function TreasureAwardView:OnClickLinQu()
	ActivityBrilliantCtrl.ActivityReq(4, ACT_ID.SLLB, 1,self.index)
	self:Close()
end