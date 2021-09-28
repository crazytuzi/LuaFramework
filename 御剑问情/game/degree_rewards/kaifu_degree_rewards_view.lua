KaiFuDegreeRewardsView = KaiFuDegreeRewardsView or BaseClass(BaseView)

local ActivityTypeToDegreeType = {
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MOUNT_UPGRADE] = JINJIE_TYPE.JINJIE_TYPE_MOUNT,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_WING_UPGRADE] = JINJIE_TYPE.JINJIE_TYPE_WING,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HALO_UPGRADE_NEW] = JINJIE_TYPE.JINJIE_TYPE_HALO,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FOOTPRINT_UPGRADE_NEW] = JINJIE_TYPE.JINJIE_TYPE_FOOTPRINT,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FIGHTMOUNT_UPGRADE_NEW] = JINJIE_TYPE.JINJIE_TYPE_FIGHT_MOUNT,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SHENGONG_UPGRADE_NEW] = JINJIE_TYPE.JINJIE_TYPE_SHENGONG,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SHENYI_UPGRADE_NEW] = JINJIE_TYPE.JINJIE_TYPE_SHENYI,
}

function KaiFuDegreeRewardsView:__init()
	self.ui_config = {"uis/views/degreerewardsview_prefab","KaiFuDegreeRewardsView"}
	self.full_screen = false
	self.play_audio = true

	self.reward_list = {}
	self.data_list = {}
	self.special_data = nil
	KaiFuDegreeRewardsView.AC_TYPE = 0
end

function KaiFuDegreeRewardsView:ReleaseCallBack()
	self.reward_list_obj = nil
	self.title_image = nil
	self.left_text = nil
	self.select_suit_index = nil

	for k, v in pairs(self.reward_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.reward_list = {}
	self.special = nil
	if self.special_content then
		self.special_content:DeleteMe()
		self.special_content = nil
	end
	self.data_list = {}
	self.special_data = nil
end

function KaiFuDegreeRewardsView:LoadCallBack()
	self:ListenEvent("OnClose", BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("OnClickJinjie", BindTool.Bind(self.OnClickJinjie, self))

	self.reward_list_obj = self:FindObj("ListView")
	local list_delegate = self.reward_list_obj.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.title_image = self:FindVariable("TitleImage")
	self.left_text = self:FindVariable("LeftText")

	self.special = self:FindObj("Special")
	self.special_content = DegreeSpecialItem.New(self.special)
end

function KaiFuDegreeRewardsView:OpenCallBack()
	self:Flush()
end

function KaiFuDegreeRewardsView:GetNumberOfCells()
	return GetListNum(self.data_list)
end

function KaiFuDegreeRewardsView:RefreshCell(cell, data_index)
	local reward_cell = self.reward_list[cell]
	if reward_cell == nil then
		reward_cell = DegreeRewardsCell.New(cell.gameObject)
		reward_cell.parent_view = self
		self.reward_list[cell] = reward_cell
	end

	reward_cell:SetIndex(data_index)
	reward_cell:SetData(self.data_list[data_index])
	data_index = data_index + 1
end

function KaiFuDegreeRewardsView:SetSelectIndex(select_index)
	self.select_suit_index = select_index
end

function KaiFuDegreeRewardsView:GetSelectIndex()
	return self.select_suit_index
end

function KaiFuDegreeRewardsView:SetDegreeActivityType(activity_type)
    KaiFuDegreeRewardsView.AC_TYPE = activity_type
end

function KaiFuDegreeRewardsView:OnFlush()
	self.title_image:SetAsset(ResPath.GetDegreeTitle(KaiFuDegreeRewardsView.AC_TYPE))
	self.left_text:SetAsset(ResPath.GetDegreeLeftText(KaiFuDegreeRewardsView.AC_TYPE))
	self.data_list, self.special_data = KaiFuDegreeRewardsData.Instance:GetDegreeActivityReward()
	if self.reward_list_obj.scroller then
		self.reward_list_obj.scroller:ReloadData(0)
		self.reward_list_obj.scroller:RefreshAndReloadActiveCellViews(true)
	end
	self.special_content:SetActive(self.special_data ~= nil)
	if self.special_data then
		self.special_content:SetData(self.special_data)
	end
end

function KaiFuDegreeRewardsView:FlushAllHL()
	for k, v in pairs(self.reward_list) do
	    v:Flush()
	end
end

function KaiFuDegreeRewardsView:OnClickJinjie()
	if KaiFuDegreeRewardsView.AC_TYPE == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MOUNT_UPGRADE then
		ViewManager.Instance:Open(ViewName.Advance, TabIndex.mount_jinjie)

    elseif KaiFuDegreeRewardsView.AC_TYPE == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_WING_UPGRADE then
    	ViewManager.Instance:Open(ViewName.Advance, TabIndex.wing_jinjie)

    elseif KaiFuDegreeRewardsView.AC_TYPE == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_HALO_UPGRADE_NEW then
    	ViewManager.Instance:Open(ViewName.Advance, TabIndex.halo_jinjie)

    elseif KaiFuDegreeRewardsView.AC_TYPE == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FOOTPRINT_UPGRADE_NEW then
    	ViewManager.Instance:Open(ViewName.Advance, TabIndex.foot_jinjie)

    elseif KaiFuDegreeRewardsView.AC_TYPE == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FIGHTMOUNT_UPGRADE_NEW then
    	ViewManager.Instance:Open(ViewName.Advance, TabIndex.fight_mount)

    elseif KaiFuDegreeRewardsView.AC_TYPE == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SHENGONG_UPGRADE_NEW  then
    	ViewManager.Instance:Open(ViewName.Goddess, TabIndex.goddess_shengong)

    elseif KaiFuDegreeRewardsView.AC_TYPE == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SHENYI_UPGRADE_NEW then
    	ViewManager.Instance:Open(ViewName.Goddess, TabIndex.goddess_shenyi)

 	elseif KaiFuDegreeRewardsView.AC_TYPE == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_YAOSHI_UPGRADE then
		ViewManager.Instance:Open(ViewName.AppearanceView, TabIndex.appearance_waist)

 	elseif KaiFuDegreeRewardsView.AC_TYPE == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOUSHI_UPGRADE then
		ViewManager.Instance:Open(ViewName.AppearanceView, TabIndex.appearance_toushi)

 	elseif KaiFuDegreeRewardsView.AC_TYPE == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_QILINBI_UPGRADE then
		ViewManager.Instance:Open(ViewName.AppearanceView, TabIndex.appearance_qilinbi)

	elseif KaiFuDegreeRewardsView.AC_TYPE == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MASK_UPGRADE then
		ViewManager.Instance:Open(ViewName.AppearanceView, TabIndex.appearance_mask)

	elseif KaiFuDegreeRewardsView.AC_TYPE == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_XIANBAO_UPGRADE then
		ViewManager.Instance:Open(ViewName.AppearanceView, TabIndex.appearance_xianbao)

	elseif KaiFuDegreeRewardsView.AC_TYPE == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LINGZHU_UPGRADE then
		ViewManager.Instance:Open(ViewName.AppearanceView, TabIndex.appearance_lingzhu)

	elseif KaiFuDegreeRewardsView.AC_TYPE == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LINGCHONG_UPGRADE then
		ViewManager.Instance:Open(ViewName.Advance, TabIndex.lingchong_jinjie)

	elseif KaiFuDegreeRewardsView.AC_TYPE == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LINGGONG_UPGRADE then
		ViewManager.Instance:Open(ViewName.AppearanceView, TabIndex.appearance_linggong)

	elseif KaiFuDegreeRewardsView.AC_TYPE == ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LINGQI_UPGRADE then
		ViewManager.Instance:Open(ViewName.AppearanceView, TabIndex.appearance_lingqi)
    end
end

function KaiFuDegreeRewardsView:OnClickClose()
	self:Close()
end

--------------------------DegreeRewardsCell----------------------------
DegreeRewardsCell = DegreeRewardsCell or BaseClass(BaseCell)

function DegreeRewardsCell:__init()
	self.award_items = {}

	for i = 1, 2 do
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(self:FindObj("Item_"..i))
		self.award_items[i] = item_cell
	end

	self.can_rewards = self:FindVariable("CanRewards")
	self.received = self:FindVariable("Received")
	self.rare_received = self:FindVariable("Show_Rare_Item")
	self.unmet = self:FindVariable("Unmet")
	self.hight_light = self:FindVariable("HightLight")
	self.title = self:FindVariable("Title")

	self:ListenEvent("ClickItem", BindTool.Bind(self.ClickItem, self))
	self:ListenEvent("Click_LingQu", BindTool.Bind(self.ClickLingQU, self))
end

function DegreeRewardsCell:__delete()
	for k, v in pairs(self.award_items) do
		if v then
			v:DeleteMe()
		end
	end
	self.award_items = {}

	self.parent_view = nil
end

function DegreeRewardsCell:ClickItem()
	self.parent_view:SetSelectIndex(self.index) --返回选择的是哪个Item
	self.parent_view:FlushAllHL()
end

function DegreeRewardsCell:ClickLingQU()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(KaiFuDegreeRewardsView.AC_TYPE,
		RA_UPGRADE_NEW_OPERA_TYPE.RA_UPGRADE_NEW_OPERA_TYPE_FETCH_REWARD, self.data.cfg.seq)
end

function DegreeRewardsCell:OnFlush()
	if nil == self.data then return end
    local can_rewards = KaiFuDegreeRewardsData.Instance:GetCanReward(KaiFuDegreeRewardsView.AC_TYPE, self.data.cfg.seq) or 0
    local fetch_reward = KaiFuDegreeRewardsData.Instance:GetFetchReward(KaiFuDegreeRewardsView.AC_TYPE, self.data.cfg.seq) or 0
    local rare_reward = KaiFuDegreeRewardsData.Instance:GetRareReward(KaiFuDegreeRewardsView.AC_TYPE, self.data.cfg.seq) or 0

    local dereee_grade = KaiFuDegreeRewardsData.Instance:GetDegreeRewardsGrade(self.data.cfg.seq)
    local name = KaiFuDegreeRewardsData.Instance:GetDegreeName()
  	if (self.data.cfg.rare_reward_item == nil or self.data.cfg.rare_reward_item.item_id <= 0) 
    	and (self.data.cfg.super_reward == nil or self.data.cfg.super_reward.item_id <= 0) then
		self.award_items[2]:SetItemActive(false)
	else
		self.award_items[2]:SetItemActive(true)
	end

	self.unmet:SetValue(can_rewards ~= 1)
	self.can_rewards:SetValue(can_rewards == 1 and fetch_reward ~= 1)
	self.received:SetValue(fetch_reward == 1)
	self.rare_received:SetValue(rare_reward ~= 1)

	self.award_items[1]:SetData(self.data.cfg.reward_item)
	if self.data.cfg.rare_reward_item ~= nil and self.data.cfg.rare_reward_item.item_id > 0 then
		self.award_items[2]:SetData(self.data.cfg.rare_reward_item)
	elseif self.data.cfg.super_reward ~= nil and self.data.cfg.super_reward.item_id > 0 then
		self.award_items[2]:SetData(self.data.cfg.super_reward)
	end
	self.award_items[2]:SetLeftTopImg(ResPath.GetImages("label_1"))

    self.title:SetValue(string.format(Language.Common.DegreeCellTitle, name, dereee_grade))
    self:FlushHL()
end

function DegreeRewardsCell:FlushHL()
	local select_Index = self.parent_view:GetSelectIndex()
	self.hight_light:SetValue(select_Index == self.index)
end

DegreeSpecialItem = DegreeSpecialItem or BaseClass(BaseCell)

function DegreeSpecialItem:__init()
	self.recharge = self:FindVariable("Recharge")
	self.have_buy = self:FindVariable("have_buy")
	self.price = self:FindVariable("price")
	self.can_reward = self:FindVariable("CanReward")

	self.item = self:FindObj("Item")
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.item)

	self.item_cell2 = ItemCell.New()
	self.item_cell2:SetInstanceParent(self.item)

	self:ListenEvent("ClickBuy", BindTool.Bind(self.ClickBuy, self))
end

function DegreeSpecialItem:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
	if self.item_cell2 then
		self.item_cell2:DeleteMe()
		self.item_cell2 = nil
	end
end

function DegreeSpecialItem:OnFlush()
	if not self.data then
		return
	end
	local dereee_grade = KaiFuDegreeRewardsData.Instance:GetDegreeRewardsGrade(self.data.cfg.seq)
	if dereee_grade >= 10 then
		local str = Language.GradeName[10]
		local num = dereee_grade - 10
		if num > 0 then
			str = str .. num
		end
		self.recharge:SetValue(str)
	else
		self.recharge:SetValue(dereee_grade)
	end
	local can_rewards = KaiFuDegreeRewardsData.Instance:GetCanReward(KaiFuDegreeRewardsView.AC_TYPE, self.data.cfg.seq) or 0
    local fetch_reward = KaiFuDegreeRewardsData.Instance:GetFetchReward(KaiFuDegreeRewardsView.AC_TYPE, self.data.cfg.seq) or 0
	self.item_cell:SetData(self.data.cfg.reward_item)
	if self.data.cfg.rare_reward_item ~= nil and self.data.cfg.rare_reward_item.item_id > 0 then
		self.item_cell2:SetData(self.data.cfg.rare_reward_item)
	elseif self.data.cfg.super_reward ~= nil and self.data.cfg.super_reward.item_id > 0 then
		self.item_cell2:SetData(self.data.cfg.super_reward)
	end
	self.item_cell2:ListenClick(BindTool.Bind(self.ClickItemCell, self, function ()
  		self.item_cell2:OnClickItemCell()
  	end, self.data.cfg.need_value))
  	
	self.have_buy:SetValue(fetch_reward == 1)
	self.can_reward:SetValue(can_rewards == 1 and fetch_reward ~= 1)
end

function DegreeSpecialItem:ClickBuy()
	if not self.data then
		return
	end
	local can_rewards = KaiFuDegreeRewardsData.Instance:GetCanReward(KaiFuDegreeRewardsView.AC_TYPE, self.data.cfg.seq) or 0
    local fetch_reward = KaiFuDegreeRewardsData.Instance:GetFetchReward(KaiFuDegreeRewardsView.AC_TYPE, self.data.cfg.seq) or 0
	if self.data.cfg.need_value == 9 and can_rewards == 1 and fetch_reward == 0 then
		local _type = ActivityTypeToDegreeType[KaiFuDegreeRewardsView.AC_TYPE]
		JinJieRewardCtrl.Instance:SendJinJieRewardOpera(JINJIESYS_REWARD_OPEAR_TYPE.JINJIESYS_REWARD_OPEAR_TYPE_FETCH, _type, JIN_JIE_REWARD_TARGET_TYPE.BIG_TARGET)
	end
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(KaiFuDegreeRewardsView.AC_TYPE,
		RA_UPGRADE_NEW_OPERA_TYPE.RA_UPGRADE_NEW_OPERA_TYPE_FETCH_REWARD, self.data.cfg.seq)
end
function DegreeSpecialItem:ClickItemCell(func, item_id)
	local _type = self:GetType(item_id)
	if _type then
		JinJieRewardCtrl.Instance:OpenJinJieAwardView(_type)
	else
		func()
	end
	-- body
end

function DegreeSpecialItem:GetType(item_value)
	if item_value >= 9 then
		return ActivityTypeToDegreeType[KaiFuDegreeRewardsView.AC_TYPE]
	end
end