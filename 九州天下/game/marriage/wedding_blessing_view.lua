WeddingBlessingView = WeddingBlessingView or BaseClass(BaseView)

local PUTONG_YANHUA_ITEM_ID = 23876
local GAOJI_YANHUA_ITEM_ID = 23877

-- 宾客祝福界面
function WeddingBlessingView:__init()
	self:SetMaskBg()
	self.ui_config = {"uis/views/marriageview","WeddingBlessingView"}
	self.play_audio = true
	self.select_toggle_icon = 1
	self.select_toggle_index = 0
	self.select_type = 0
end

function WeddingBlessingView:ReleaseCallBack()
	self.player_icon = {}
	self.player_name = {}
	self.player_image = {}

	self.gold_num = {}
	self.flower_num = {}

	self.blessing_itemlog_list = nil
	self.toggle_icon = {}
	self.toggle = {}

	if self.blessing_itemlog_cell_list then
		for k,v in pairs(self.blessing_itemlog_cell_list) do
			v:DeleteMe()
		end
	end
	self.blessing_itemlog_cell_list = {}
end

function WeddingBlessingView:OpenCallBack()
	 MarriageCtrl.Instance:SendMarryOpera(GameEnum.HUNYAN_GET_BLESS_RECORD_INFO)
end

function WeddingBlessingView:LoadCallBack()
	self.player_icon = {}
	self.player_name = {}
	self.player_image = {}
	for i = 1,2 do
		self.player_icon[i] = self:FindVariable("player_icon"..i)
		self.player_name[i] = self:FindVariable("player_name"..i)
		self.player_image[i] = self:FindObj("player_image"..i)
	end

	self.gold_num = {}
	self.flower_num = {}
	for i = 1,3 do
		self.gold_num[i] = self:FindVariable("gold_num"..i)
		self.flower_num[i] = self:FindVariable("flower_num"..i)
	end

	self:ListenEvent("Close",BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("OnClickPresent",BindTool.Bind(self.OnClickPresent, self))
	self:ListenEvent("OnClickTip",BindTool.Bind(self.OnClickTip, self))
	----------------------------------------------------
	-- 祝福日志列表生成滚动条
	self.blessing_itemlog_cell_list = {}
	self.blessing_itemlog_listview_data = {}
	self.blessing_itemlog_list = self:FindObj("BlessingLogListView")
	local blessing_itemlog_list_delegate = self.blessing_itemlog_list.list_simple_delegate
	--生成数量
	blessing_itemlog_list_delegate.NumberOfCellsDel = function()
		return #self.blessing_itemlog_listview_data or 0
	end
	--刷新函数
	blessing_itemlog_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshBlessingItemLogListView, self)
	----------------------------------------------------
	self.toggle_icon = {}
	for i=1,2 do
		self.toggle_icon[i] = self:FindObj("ToggleIcon" .. i)
		self.toggle_icon[i].toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleIconChange, self, i))
	end

	self.toggle = {}
	for i=1,6 do
		self.toggle[i] = self:FindObj("Toggle" .. i)
		self.toggle[i].toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange, self, math.floor((i - 1) / 3), (i - 1) % 3))
	end

	self:SetNumber()
	self:Flush()
end

function WeddingBlessingView:SetNumber()
	for i = 1,3 do
		local gold_num = MarriageData.Instance:GetMarryFlowerItemIdBySeq(0, i - 1)
		self.gold_num[i]:SetValue(gold_num)

		local flower_id = MarriageData.Instance:GetMarryFlowerItemIdBySeq(1, i - 1)
		local item_cfg = ItemData.Instance:GetItemConfig(flower_id)
		self.flower_num[i]:SetValue(item_cfg.name)
	end
end

function WeddingBlessingView:OnToggleIconChange(index, ison)
	if ison then
		self.select_toggle_icon  = index
	end
end

function WeddingBlessingView:OnToggleChange(type, index,ison)
	if ison then
		self.select_type  = type
		self.select_toggle_index  = index
	end
end

function WeddingBlessingView:OnClickPresent()
	local marryuser_list = MarriageData.Instance:GetMarryUserList()
	local user_id = marryuser_list[self.select_toggle_icon].marry_uid or 0
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if main_role_vo.role_id == user_id then
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.ErrorRemind)
		return
	end
	if self.select_type == 0 then
		MarriageCtrl.Instance:SendMarryOpera(GameEnum.HUNYAN_OPERA_TYPE_RED_BAG, nil, nil, nil, user_id, self.select_toggle_index)
	else
		local item_id = MarriageData.Instance:GetMarryFlowerItemIdBySeq(1, self.select_toggle_index)
		local num = ItemData.Instance:GetItemNumInBagById(item_id)
		if num >= 1 then
			MarriageCtrl.Instance:SendMarryOpera(GameEnum.HUNYAN_OPERA_TYPE_FOLWER, nil, nil, nil, user_id, self.select_toggle_index)
		elseif TipsCommonBuyView.AUTO_LIST[item_id] then
			local item_cfg = ItemData.Instance:GetItemConfig(item_id)
			MarketCtrl.Instance:SendShopBuy(item_id, 1, 1, item_cfg.is_tip_use)
			MarriageCtrl.Instance:SendMarryOpera(GameEnum.HUNYAN_OPERA_TYPE_FOLWER, nil, nil, nil, user_id, self.select_toggle_index)
		else 
			local func = function(item_id2, item_num, is_bind, is_use, is_buy_quick)
				MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, is_use)
			end
			TipsCtrl.Instance:ShowCommonBuyView(func, item_id, nil, 1)
		end
	end
end

-- 刷新祝福日志列表listview
function WeddingBlessingView:RefreshBlessingItemLogListView(cell, data_index, cell_index)
	data_index = data_index + 1

	local blessing_item_log_cell = self.blessing_itemlog_cell_list[cell]
	if blessing_item_log_cell == nil then
		blessing_item_log_cell = BlessingItemCell.New(cell.gameObject)
		self.blessing_itemlog_cell_list[cell] = blessing_item_log_cell
	end
	blessing_item_log_cell:SetIndex(data_index)
	blessing_item_log_cell:SetData(self.blessing_itemlog_listview_data[data_index])
end

function WeddingBlessingView:OnClickClose()
	self:Close()
end

function WeddingBlessingView:OnFlush()
	self:OnFlushHeadportrait()

	-- 设置itemloglist数据
	local blessing_data = MarriageData.Instance:GetWeddingBlessingRecordInfo()
	self.blessing_itemlog_listview_data = blessing_data.bless_record_list or {}
	if self.blessing_itemlog_list.scroller.isActiveAndEnabled then
		self.blessing_itemlog_list.scroller:ReloadData(0)
	end

end

function WeddingBlessingView:OnFlushHeadportrait()
	local marryuser_list = MarriageData.Instance:GetMarryUserList()
	if nil == marryuser_list or nil == next(marryuser_list) then return end

	for i = 1,2 do
		local player_data = {}
		player_data.id = marryuser_list[i].marry_uid
		player_data.prof = marryuser_list[i].prof
		player_data.sex = marryuser_list[i].sex
		player_data.avatar_key_big = marryuser_list[i].avatar_key_big
		player_data.avatar_key_small = marryuser_list[i].avatar_key_small
		player_data.name = marryuser_list[i].marry_name

		self:LoadHeadIcon(player_data, self.player_icon[i], self.player_image[i])
		self.player_name[i]:SetValue(player_data.name or "")
	end
end

function WeddingBlessingView:LoadHeadIcon(data, def_icon, sp_icon)
	AvatarManager.Instance:SetAvatarKey(data.id, data.avatar_key_big, data.avatar_key_small)
	local avatar_path_small = AvatarManager.Instance:GetAvatarKey(data.id)
	if AvatarManager.Instance:isDefaultImg(data.id) == 0 or avatar_path_small == 0 then
		sp_icon.gameObject:SetActive(false)
		local bundle, asset = AvatarManager.GetDefAvatar(data.prof, false, data.sex)
		def_icon:SetAsset(bundle, asset)
	else
		local function callback(path)
			if path == nil then
				path = AvatarManager.GetFilePath(data.id, false)
			end
			sp_icon.raw_image:LoadSprite(path, function ()
				def_icon:SetAsset("", "")
				sp_icon.gameObject:SetActive(true)
			end)
		end
		AvatarManager.Instance:GetAvatar(data.id, false, callback)
	end
end

function WeddingBlessingView:OnClickTip()
	TipsCtrl.Instance:ShowHelpTipView(70)
end

----------------------------------------------------------------------------
-- 祝福记录Item
----------------------------------------------------------------------------
BlessingItemCell = BlessingItemCell or BaseClass(BaseCell)
function BlessingItemCell:__init()
	self.lbl_log_text = self:FindVariable("LogText")
end

function BlessingItemCell:__delete()
	self.lbl_log_text = nil
end

function BlessingItemCell:OnFlush()
	if not self.data or not next(self.data) then return end

	local str = ""
	if self.data.bless_type == 0 then
		local blessing_cfg = MarriageData.Instance:GetBlessingListCfg(self.data.param)
		str = string.format(Language.Marriage.BlessingTips1, self.data.role_name, self.data.to_role_name, self.data.param)
	elseif self.data.bless_type == 1 then
		local blessing_cfg = MarriageData.Instance:GetBlessingListCfg(self.data.param)
		local item_cfg = ItemData.Instance:GetItemConfig(blessing_cfg.param)
		str = string.format(Language.Marriage.BlessingTips2, self.data.role_name, self.data.to_role_name, item_cfg.name)
	else
		local item_id = 0
		if self.data.param > 10 then
			item_id = GAOJI_YANHUA_ITEM_ID
		else
			item_id = PUTONG_YANHUA_ITEM_ID
		end
		local item_cfg = ItemData.Instance:GetItemConfig(item_id)
		str = string.format(Language.Marriage.BlessingTips3, self.data.role_name, item_cfg.name, self.data.param)
	end
	self.lbl_log_text:SetValue(str)
end
