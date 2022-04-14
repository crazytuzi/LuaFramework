EquipStoneUpPanel = EquipStoneUpPanel or class("EquipStoneUpPanel",WindowPanel)
local EquipStoneUpPanel = EquipStoneUpPanel

function EquipStoneUpPanel:ctor()
	self.abName = "equip"
	self.assetName = "EquipStoneUpView"
	self.layer = "UI"

	-- self.change_scene_close = true 				--切换场景关闭
	-- self.default_table_index = 1					--默认选择的标签
	-- self.is_show_money = {Constant.GoldType.Coin,Constant.GoldType.BGold,Constant.GoldType.Gold}	--是否显示钱，不显示为false,默认显示金币、钻石、宝石，可配置
	
	self.panel_type = 4								--窗体样式  1 1280*720  2 850*545
	self.show_sidebar = false		--是否显示侧边栏
	self.table_index = nil
	self.globalEvents = {}
	self.model = EquipMountStoneModel:GetInstance()
	self.role_data = RoleInfoModel.GetInstance():GetMainRoleData()
end

function EquipStoneUpPanel:dctor()
end

function EquipStoneUpPanel:Open(stoneId,slot,hole)
	self.stoneId = stoneId
	self.slot = slot
	self.hole = hole
	EquipStoneUpPanel.super.Open(self)
end

function EquipStoneUpPanel:LoadCallBack()
	self.nodes = {
		"bg/crntStone",
		"bg/crntStone/crntIcon","bg/crntStone/crntName","bg/crntStone/crntAttr",
		"bg/nextStone/nextIcon","bg/nextStone/nextName","bg/nextStone/nextAttr",
		"bg/cost/costValue","upBtn",
	}
	self:GetChildren(self.nodes)

	self.upBtnBtn = self.upBtn:GetComponent('Button')
	self.costValueTxt = self.costValue:GetComponent('Text')
	self.crntStoneRctTra = self.crntStone:GetComponent('RectTransform')
	self.crntAttrTxt = self.crntAttr:GetComponent('Text')
	self.crntNameTxt = self.crntName:GetComponent('Text')
	self.nextAttrTxt = self.nextAttr:GetComponent('Text')
	self.nextNameTxt = self.nextName:GetComponent('Text')
	--self.lessValueTxt = self.lessValue:GetComponent('Text')

	self:AddEvent()

	self:SetPanelSize(500, 327)
	self:SetTileTextImage("equipmountstone_image", "stone_up_f")
end

function EquipStoneUpPanel:AddEvent()
	local function call_back()
		if not self.upBtnBtn.interactable then
			return
		end
		local need_gold = self.model:GetNextStoneUpCost(self.stoneId,self.model.cur_state)
		local bo = RoleInfoModel:GetInstance():CheckGold(need_gold, Constant.GoldType.Gold)
		if bo then
			EquipController.Instance:RequestUpStone(self.slot,self.hole,self.model:GetNextStoneLevel(self.stoneId,self.model.cur_state))
		end
	end
	AddClickEvent(self.upBtn.gameObject,call_back)

	self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(EquipEvent.UpdateEquipDetail,handler(self,self.DealEquipUpdate))
end

function EquipStoneUpPanel:DealEquipUpdate(equip)
	self:Close()
end

function EquipStoneUpPanel:SetHighestStoneInfo(stoneId)
	SetVisible(self.arrow.gameObject,false)
	SetVisible(self.nextStone.gameObject,false)
	self.crntAttrTxt.text = self.model:GetStoneAttrInfo(stoneId,self.model.cur_state)
	self.upBtnBtn.interactable = false
	self.crntStoneRctTra.anchoredPosition = Vector2(34.5,self.crntStoneRctTra.anchoredPosition.y)

	local crntItemCfg = Config.db_item[stoneId]
	self.crntNameTxt.text = string.format("<color=#%s>%s</color>",ColorUtil.GetColor(crntItemCfg.color),
			crntItemCfg.name)
end

function EquipStoneUpPanel:OpenCallBack()
	self:UpdateView()
end

function EquipStoneUpPanel:UpdateView()
	local stoneCfg = Config.db_stone[self.stoneId]
	if self.model.cur_state == self.model.states.spar then
		stoneCfg = Config.db_spar[self.stoneId]
	end

	if stoneCfg.next_level_id == 0 then
		self:SetHighestStoneInfo(stoneCfg.id)
	else
		local need_num = stoneCfg.need_num-1
		local result, had = self.model:calc_need_stones(self.stoneId, need_num, {},self.model.cur_state)
		local need_gold = Config.db_voucher[self.stoneId].price * need_num
		for k, v in pairs(had) do
			need_gold = need_gold - Config.db_voucher[k].price*v
			local itemcfg = Config.db_item[k]
		end
		--self.lessValueTxt.text = str--self.model:GetLessInfo(self.stoneId)
		self.costValueTxt.text = need_gold--self.model:GetNextStoneUpCost(self.stoneId) .. ""
		if self.crntIconStor == nil then
			self.crntIconStor = GoodsIconSettorTwo(self.crntIcon)
		end
		local param = {}
		param["model"] = self.model
		param["item_id"] = self.stoneId
		self.crntIconStor:SetIcon(param)

		--self.crntIconStor:UpdateIconByItemId(self.stoneId)
		self.crntAttrTxt.text = self.model:GetStoneAttrInfo(self.stoneId,self.model.cur_state)

		local crntItemCfg = Config.db_item[self.stoneId]
		self.crntNameTxt.text = string.format("<color=#%s>%s</color>",ColorUtil.GetColor(crntItemCfg.color),
			crntItemCfg.name)

		if self.nextIconStor == nil then
			self.nextIconStor = GoodsIconSettorTwo(self.nextIcon)
		end
		local param = {}
		param["model"] = self.model
		param["item_id"] = stoneCfg.next_level_id
		self.nextIconStor:SetIcon(param)
		--self.nextIconStor:UpdateIconByItemId(stoneCfg.next_level_id)
		self.nextAttrTxt.text = self.model:GetStoneAttrInfo(stoneCfg.next_level_id,self.model.cur_state)

		local nextItemCfg = Config.db_item[stoneCfg.next_level_id]
		self.nextNameTxt.text = string.format("<color=#%s>%s</color>",ColorUtil.GetColor(nextItemCfg.color),
			nextItemCfg.name)
	end
end

function EquipStoneUpPanel:CloseCallBack(  )
	for i, v in pairs(self.globalEvents) do
		GlobalEvent:RemoveListener(v)
	end

	if self.crntIconStor then
		self.crntIconStor:destroy()
	end
	if self.nextIconStor then
		self.nextIconStor:destroy()
	end
end
function EquipStoneUpPanel:SwitchCallBack(index)
	if self.table_index == index then
		return
	end
	if self.child_node then
	 	self.child_node:SetVisible(false)
	end
	self.table_index = index
end