SendFlowerView = SendFlowerView or BaseClass(BaseView)

function SendFlowerView:__init()
	self.ui_config = {"uis/views/sendflowerview", "SendFlowerView"}
	self.play_audio = true
	self:SetMaskBg()
	self.item_list = {}
	self.flower_data = {}
	self.num = 0
	self.charm_cfg = {}
	self.des = {}
	self.reward_item = {}
end

function SendFlowerView:__delete()
	
end

function SendFlowerView:LoadCallBack()
	self:ListenEvent("Close", BindTool.Bind(self.Close, self))
	self.display = self:FindObj("Display")
	self.list = self:FindObj("ListView")
	self.title = self:FindVariable("tittle")
	self.slider = self:FindVariable("slider")
	self.slider_text = self:FindVariable("slidertext")
	self.show_effect = self:FindVariable("IsShowEffect")
	for i = 1, 2 do
		self.des[i] = self:FindVariable("des"..i)
		local item = ItemCell.New()
		item:SetInstanceParent(self:FindObj("Rewarditem"..i)) 
		self.reward_item[i] = item
	end
	self.flower_data, self.charm_cfg, self.num = SendFlowerData.Instance:GetFlowerCfg()

	local list_delegate = self.list.list_simple_delegate
	list_delegate.NumberOfCellsDel = function()
		return self.num
	end
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshListView, self)

	local vo = GameVoManager.Instance:GetMainRoleVo()
	self.temp_vo = {prof = vo.prof, sex = vo.sex, appearance = {}}
	self:FlushModel()
end

function SendFlowerView:ReleaseCallBack()
	for i = 1, 2 do
		self.reward_item[i]:DeleteMe()
		self.des[i] = nil
	end
	self.des = {}
	self.reward_item = {}

	for i,v in ipairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
	if nil ~= self.role_model then
		self.role_model:DeleteMe()
		self.role_model = nil
	end
	self.title = nil
	self.slider = nil
	self.slider_text = nil
	self.display = nil
	self.list = nil
	self.show_effect = nil
end

function SendFlowerView:FlushModel()
	local model = SendFlowerData.Instance:GetQiXiModel()
	local weapons_id = model.weapons_id or 0
	local clothes_id = model.clothes_id or 0
	local halo_id = model.halo_id or 0
	if not self.role_model then
		self.role_model = RoleModel.New("send_flower")
		self.role_model:SetDisplay(self.display.ui3d_display)
	end
	self.temp_vo.appearance.fashion_wuqi = weapons_id
	self.temp_vo.appearance.fashion_body = clothes_id
	if self.role_model then
		self.role_model:SetModelResInfo(self.temp_vo)
		self.role_model:SetHaloResid(halo_id)
	end
end

function SendFlowerView:RefreshListView(cell, data_index)
	local list_cell = self.item_list[cell]
	if nil == list_cell then
		list_cell = SendFlowerList.New(cell.gameObject)
	    self.item_list[cell] = list_cell
	end
	local data = self.flower_data[data_index]
	list_cell:SetIndex(data_index)
	list_cell:SetData(data)
	data_index = data_index + 1
end

function SendFlowerView:OpenCallBack()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_QIXI_SEND_FLOWER,SENDING_FLOWER.INFO)
end

function SendFlowerView:CloseCallBack()

end

function SendFlowerView:OnFlush(param_t)
	if self.list.scroller.isActiveAndEnabled then
		self.list.scroller:ReloadData(0)
	end
	self:SetData()
end

function SendFlowerView:SetData()
	local info = SendFlowerData.Instance:GetInfo()
	for i = 1, 2 do
		local flag = SendFlowerData.Instance:GetActiveFlag(self.charm_cfg[i].index) == 0
		local text = info.qixi_flower_charm >= self.charm_cfg[i].require_count and string.format(Language.SendFlower.Finish) or
		string.format(Language.SendFlower.NumTime,info.qixi_flower_charm,self.charm_cfg[i].require_count)
		self.des[i]:SetValue(text)
		self.reward_item[i]:SetData(self.charm_cfg[i].reward_item[0])
	end	
	self.show_effect:SetValue(info.qixi_flower_charm < self.charm_cfg[2].require_count)
	local progress = info.qixi_flower_charm / self.charm_cfg[2].require_count
	local title = self.charm_cfg[1].account
	self.slider:SetValue(progress)
	self.title:SetValue(title)
end

------------------------
SendFlowerList = SendFlowerList or BaseClass(BaseCell)
function SendFlowerList:__init()
	self.reward_item = {}
	for i = 1, 3 do
		local item = ItemCell.New()
		item:SetInstanceParent(self:FindObj("rewarditem"..i)) 
		self.reward_item[i] = item
	end
	self.des = self:FindVariable("des")
	self.btn_text = self:FindVariable("btntext")
	self.redpoint = self:FindVariable("redpoint")
	self.btn_gray = self:FindVariable("btngray")
	self.des_text = self:FindVariable("destext")
	self:ListenEvent("GetReward", BindTool.Bind(self.GetReward, self))
end

function SendFlowerList:__delete()
	for k,v in pairs(self.reward_item) do
		v:DeleteMe()
	end
	self.reward_item = {}
	self.des = nil
	self.btn_text = nil
	self.redpoint = nil
	self.btn_gray = nil
end

function SendFlowerList:OnFlush()
	local draw_time_list = SendFlowerData.Instance:GetInfoDrawTimeList(self.data.index)
	local flag = SendFlowerData.Instance:GetActiveFlag(self.data.index) == 0
	local reward_list = SendFlowerData.Instance:GetRewardIist(self.data.reward_item[0].item_id)
	local text = ""
	if draw_time_list <= 0  then
		text = string.format(Language.SendFlower.BtnText[3])
		self.btn_gray:SetValue(true)
	else
		text = flag and string.format(Language.SendFlower.BtnText[2]) or string.format(Language.SendFlower.BtnText[1])
		self.btn_gray:SetValue(false)
	end
	local text2 = string.format(Language.SendFlower.GetNumTime,draw_time_list)
	self.btn_text:SetValue(text)
	self.des_text:SetValue(text2)
	self.des:SetValue(self.data.account)
	self.redpoint:SetValue(flag)
	for i = 1, 3 do
		self.reward_item[i]:SetActive(reward_list[i] ~= nil)
		self.reward_item[i]:SetData(reward_list[i])
	end
end

function SendFlowerList:GetReward()
	local flag = SendFlowerData.Instance:GetActiveFlag(self.data.index) == 0
	local draw_time_list = SendFlowerData.Instance:GetInfoDrawTimeList(self.data.index) 
	if flag then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_QIXI_SEND_FLOWER,SENDING_FLOWER.GETREWARD,self.data.index)
	else
		ViewManager.Instance:Open(ViewName.Flowers)
	end
end