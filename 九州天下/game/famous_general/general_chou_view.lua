GeneralChouView = GeneralChouView or BaseClass(BaseRender)
function GeneralChouView:__init()
	self.reward_item_list = {}
	self.chou_type = 0
	self.stuff_1_item_id = 0
	self.stuff_10_item_id = 0
	self.stuff_50_item_id = 0
end

function GeneralChouView:__delete()
	for k,v in pairs(self.reward_item_list) do
		v.item:DeleteMe()
	end

	if self.get_item_event then
		GlobalEventSystem:UnBind(self.get_item_event)
	end

	if self.display_model then 
		self.display_model:DeleteMe()
		self.display_model = nil
	end
	self.reward_item_list = {}
	self.chou_type = 0
	if self.item_change_callback then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_change_callback)
		self.item_change_callback = nil
	end

	TipsCommonBuyView.AUTO_LIST[self.stuff_1_item_id] = false
	TipsCommonBuyView.AUTO_LIST[self.stuff_10_item_id] = false
	TipsCommonBuyView.AUTO_LIST[self.stuff_50_item_id] = false
end

function GeneralChouView:LoadCallBack()	
	local other_cfg = FamousGeneralData.Instance:GetOtherCfg()
	self.get_item_event = GlobalEventSystem:Bind(OtherEventType.CHEST_SHOP_ITEM_LIST, BindTool.Bind(self.GetNewItem, self))
	self:ListenEvent("GetOne", BindTool.Bind(self.OnClickChou, self, GREATE_SOLDIER_DRAW_TYPE.GREATE_SOLDIER_DRAW_TYPE_1_DRAW, other_cfg.draw_1_item_id))
	self:ListenEvent("GetFive", BindTool.Bind(self.OnClickChou, self, GREATE_SOLDIER_DRAW_TYPE.GREATE_SOLDIER_DRAW_TYPE_10_DRAW, other_cfg.draw_10_item_id))
	self:ListenEvent("GetTen", BindTool.Bind(self.OnClickChou, self, GREATE_SOLDIER_DRAW_TYPE.GREATE_SOLDIER_DRAW_TYPE_50_DRAW, other_cfg.draw_50_item_id))
	self:ListenEvent("OpenHouse", BindTool.Bind(self.OnClickOpenHouse, self))
	self.stuff_1_item_id = other_cfg.draw_1_item_id
	self.stuff_10_item_id = other_cfg.draw_10_item_id
	self.stuff_50_item_id = other_cfg.draw_50_item_id

	self.show_name = self:FindVariable("ShowName")
	local display_obj = self:FindObj("Display")
	self.display_model = RoleModel.New("famous_general_panel")
	self.display_model:SetDisplay(display_obj.ui3d_display)

	for i = 1, 10 do
		local temp = {}
		temp.obj = self:FindObj("ItemCell" .. i)
		temp.item = ItemCell.New()
		temp.item:SetInstanceParent(temp.obj)
		self.reward_item_list[i] = temp
	end

	self.is_fitst = self:FindVariable("IsFirst")

	self.cost_1 = self:FindVariable("Cost_1")
	self.cost_2 = self:FindVariable("Cost_2")
	self.cost_3 = self:FindVariable("Cost_3")
	self.item_num = self:FindVariable("OwnItemNum")
	self.have_1 = self:FindVariable("Have_1")
	self.have_2 = self:FindVariable("Have_2")
	self.have_3 = self:FindVariable("Have_3")

	local other_cfg = FamousGeneralData.Instance:GetOtherCfg()
	local ten_num = FamousGeneralData.Instance:IsFirstTenChou() and other_cfg.daily_first_draw_10_item_num or other_cfg.draw_10_item_num
	self.cost_1:SetValue("/" .. other_cfg.draw_1_item_num)
	self.cost_2:SetValue("/" .. ten_num)
	self.cost_3:SetValue("/" .. other_cfg.draw_50_item_num)

	if not self.item_change_callback then
		self.item_change_callback = BindTool.Bind(self.ItemChangeCallBack, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_change_callback)
	end
	self:ItemChangeCallBack()
end

function GeneralChouView:OnFlush()
	local reward_cfg = FamousGeneralData.Instance:GetShowReward()
	local other_cfg = FamousGeneralData.Instance:GetOtherCfg()
	local show_cfg = FamousGeneralData.Instance:GetSingleDataBySeq(other_cfg.show_seq)

	if not show_cfg or not next(show_cfg) then return end
	self.display_model:SetMainAsset(ResPath.GetMingJiangRes(show_cfg.image_id))
	--self.show_name:SetValue(show_cfg.name)
	local is_first = FamousGeneralData.Instance:IsFirstTenChou()
	local ten_num = is_first and other_cfg.daily_first_draw_10_item_num or other_cfg.draw_10_item_num
	self.cost_2:SetValue("/" .. ten_num)
	self.is_fitst:SetValue(is_first)
	for k,v in pairs(self.reward_item_list) do
		if reward_cfg[k] and reward_cfg[k].reward_item then
			v.item:SetData(reward_cfg[k].reward_item)
			v.obj:SetActive(true)
			if reward_cfg[k].is_rare == 1 then
				v.item:ShowSpecialEffect(true)
				local bunble, asset = ResPath.GetItemEffect()
				v.item:SetSpecialEffect(bunble, asset)
			end
		else
			v.item:ShowSpecialEffect(false)
			v.obj:SetActive(false)
		end
	end
end

function GeneralChouView:OnClickOpenHouse()
	ViewManager.Instance:Open(ViewName.Treasure, TabIndex.treasure_warehouse)
end

function GeneralChouView:OnClickChou(chou_type, item_id)
	self.chou_type = chou_type
	local is_auto_buy = TipsCommonBuyView.AUTO_LIST[item_id] and 1 or 0
	FamousGeneralCtrl.Instance:SendRequest(GREATE_SOLDIER_REQ_TYPE.GREATE_SOLDIER_REQ_TYPE_DRAW, self.chou_type, is_auto_buy)
end
function GeneralChouView:OnClickChouTen()
	FamousGeneralCtrl.Instance:SendRequest(GREATE_SOLDIER_REQ_TYPE.GREATE_SOLDIER_REQ_TYPE_DRAW, GREATE_SOLDIER_DRAW_TYPE.GREATE_SOLDIER_DRAW_TYPE_50_DRAW)
end

function GeneralChouView:GetNewItem(item_list)
	TipsCtrl.Instance:OpenChouRewardTips(item_list, Language.FamousGeneral.GetGeneral, Language.FamousGeneral.ChouTen, self.OnClickChouTen)
end

function GeneralChouView:ItemChangeCallBack()
	local other_cfg = FamousGeneralData.Instance:GetOtherCfg()
	local str = ItemData.Instance:GetItemNumInBagById(other_cfg.draw_1_item_id)
	local is_first = FamousGeneralData.Instance:IsFirstTenChou()
	local ten_num = is_first and other_cfg.daily_first_draw_10_item_num or other_cfg.draw_10_item_num
	self.have_1:SetValue(str >= other_cfg.draw_1_item_num and string.format(Language.FamousGeneral.HaveEnoughNum, str) or string.format(Language.FamousGeneral.NoEnoughNum, str))
	self.have_2:SetValue(str >= ten_num and string.format(Language.FamousGeneral.HaveEnoughNum, str) or string.format(Language.FamousGeneral.NoEnoughNum, str))
	self.have_3:SetValue(str >= other_cfg.draw_50_item_num and string.format(Language.FamousGeneral.HaveEnoughNum, str) or string.format(Language.FamousGeneral.NoEnoughNum, str))
end