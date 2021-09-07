GodDropGiftView = GodDropGiftView or BaseClass(BaseView)

local CHARGE_NUM = {
	[1] = 60,
	[2] = 300,
}

local image_asset = {"best_gems_tips_image", "best_equip_tips_image", "direct_upgrade_tips_image"}
local image_path = "uis/views/goddropgiftview/images_atlas"

RA_DAILY_TOTAL_CHONGZHI_OPERA_TYPE = {
	RA_DAILY_TOTAL_CHONGZHI_OPERA_TYPE_ALL_INFO = 0,		    --请求信息
	RA_DAILY_TOTAL_CHONGZHI_OPERA_TYPE_FETCH_REWARD = 1,		--领去奖励
	RA_DAILY_TOTAL_CHONGZHI_OPERA_TYPE_MAX = 2
}

function GodDropGiftView:__init()
	self.ui_config = {"uis/views/goddropgiftview","GodDropGiftView"}
	self.full_screen = false
	self.play_audio = true
	self:SetMaskBg()

	self.item_list = {}
	self.item_icon_list = {}
	self.select_index = 1
end

function GodDropGiftView:__delete()

end

function GodDropGiftView:LoadCallBack()
	self.select_index = 1
	self.is_take = self:FindVariable("is_take")
	self.is_can_take = self:FindVariable("is_can_take")
	self.is_can_take_60 = self:FindVariable("is_can_take_60")
	self.is_can_take_300 = self:FindVariable("is_can_take_300")
	self.btn_text_1 = self:FindVariable("btn_text_1")
	self.btn_text_2 = self:FindVariable("btn_text_2")
	self.left_fp_text = self:FindVariable("left_fp_text")
	self.right_fp_text = self:FindVariable("right_fp_text")
	self.left_show_image = self:FindVariable("left_show_image")
	self.right_show_image = self:FindVariable("right_show_image")
	self.show_r_image = self:FindVariable("show_r_image")
	self.show_r_fp = self:FindVariable("show_r_fp")
	self.show_l_image = self:FindVariable("show_l_image")
	self.show_l_fp = self:FindVariable("show_l_fp")
	self.item_img = self:FindVariable("item_img")
	self.item_raw_img = self:FindVariable("item_raw_img")
	self.show_item_img = self:FindVariable("show_item_img")
	self.show_raw_item_img = self:FindVariable("show_raw_item_img")
	
	for i = 1, 3 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self:FindObj("item_" .. i))
		self.item_icon_list[i] = self:FindObj("item_icon_"..i)
	end

	self.display_l = self:FindObj("display_l")
	self.display_r = self:FindObj("display_r")
	self.toggle_1 = self:FindObj("toggle_1")
	self.toggle_2 = self:FindObj("toggle_2")
	
	self:ListenEvent("charge_click", BindTool.Bind(self.OnChargeClick, self))
	self:ListenEvent("reward_click", BindTool.Bind(self.OnRewardClick, self))
	self:ListenEvent("close_view", BindTool.Bind(self.OnCloseClick, self))
	self:ListenEvent("on_click_60", BindTool.Bind(self.OnClickToggle60, self))
	self:ListenEvent("on_click_300", BindTool.Bind(self.OnClickToggle300, self))
end

function GodDropGiftView:ReleaseCallBack()
	self.is_take = nil
	self.is_can_take = nil
	self.is_can_take_60 = nil
	self.is_can_take_300 = nil
	self.btn_text_1 = nil
	self.btn_text_2 = nil
	self.left_fp_text = nil
	self.right_fp_text = nil
	self.left_show_image = nil
	self.right_show_image = nil
	self.display_l = nil
	self.display_r = nil
	self.obj_model = nil
	self.show_r_image = nil
	self.show_r_fp = nil
	self.show_l_image = nil
	self.show_l_fp = nil
	self.toggle_1 = nil
	self.toggle_2 = nil
	self.item_img = nil
	self.item_raw_img = nil
	self.show_item_img = nil
	self.show_raw_item_img = nil

	for k, v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}

	self.item_icon_list = {}

	if nil ~= self.item_model_l then
		self.item_model_l:DeleteMe()
		self.item_model_l = nil
	end

	if nil ~= self.item_model_r then
		self.item_model_r:DeleteMe()
		self.item_model_r = nil
	end

	Runner.Instance:RemoveRunObj(self)
end

function GodDropGiftView:OpenCallBack()
	--定时器、监听、第一次OnFlush
	self:Flush()
	self:FlushOneTime()
	self:SetModelInfo(self.select_index)
end

function GodDropGiftView:CloseCallBack()
end

function GodDropGiftView:OnFlush()
	self:FlushInfo(self.select_index)
	self:FlushRedPointAndBtnState(self.select_index)
	self:FlushModelTipsImage(self.select_index)
end

--刷新model
function GodDropGiftView:FlushModel(model_l_id,model_l_path,model_r_id,model_r_path)
	Runner.Instance:RemoveRunObj(self)

	local data = GodDropGiftData.Instance:GetGodDropGiftInfo(CHARGE_NUM[self.select_index])
	if nil == next(data) then return end

	self.show_item_img:SetValue(data.model_type == 1)
	self.show_raw_item_img:SetValue(data.model_type == 2)

	if not self.item_model_r and self.display_r then
		self.item_model_r = RoleModel.New("second_warfare_view_baoshi")
		self.item_model_r:SetDisplay(self.display_r.ui3d_display)
	end
	self.item_model_r:SetMainAsset(model_r_path, model_r_id)

	if data.model_type == 0 then
		if not self.item_model_l and self.display_l then
			self.item_model_l = RoleModel.New("red_equip_armor")
			self.item_model_l:SetDisplay(self.display_l.ui3d_display)
		end
		
		self.item_model_l:SetMainAsset(model_l_path, model_l_id)	
		local cur_kaifu_day = TimeCtrl.Instance:GetCurOpenServerDay()
		if cur_kaifu_day < 5 then
			self.rotate_speed = 100
			Runner.Instance:AddRunObj(self, 16)
			self.obj_model = self.item_model_l.draw_obj.root.transform
		else
			self.obj_model = nil
		end
	elseif data.model_type == 1 then
		self.item_img:SetAsset(data.path_1, data.model_id1)
	elseif data.model_type == 2 then
		self.item_raw_img:SetAsset(data.path_1, data.model_id1)
	end
end

--每帧刷新(旋转)
function GodDropGiftView:Update()
	if self.obj_model == nil then return end
	self.obj_model.localRotation = self.obj_model.localRotation * 
								Quaternion.Euler(0,self.rotate_speed * UnityEngine.Time.deltaTime, 0)
end

function GodDropGiftView:FlushInfo(index)   
	local data = GodDropGiftData.Instance:GetGodDropGiftInfo(CHARGE_NUM[index])
	if nil == next(data) then return end

	local item_list_info = ItemData.Instance:GetGiftItemList(data.reward_item[0].item_id)
	if next(item_list_info) == nil then
		item_list_info = data.reward_item[0]
	end

	for k,v in pairs(self.item_list) do
		if item_list_info[k] then
			v:SetData(item_list_info[k])
			self.item_icon_list[k]:SetActive(true)
		else
			self.item_icon_list[k]:SetActive(false)
		end
	end
end

--充点小钱
function GodDropGiftView:OnChargeClick()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

--领取奖励
function GodDropGiftView:OnRewardClick()
	--没数据，不给操作
	local data = GodDropGiftData.Instance:GetGodDropGiftInfo(CHARGE_NUM[self.select_index])
	if nil == next(data) then return end
	GodDropGiftCtrl.Instance:SendFetchRewardInfo(
		RA_DAILY_TOTAL_CHONGZHI_OPERA_TYPE.RA_DAILY_TOTAL_CHONGZHI_OPERA_TYPE_FETCH_REWARD, self.select_index - 1)
	--（PS:背包满了，礼包到邮件）
end

function GodDropGiftView:FlushOneTime()
	if self.btn_text_1 and self.btn_text_2 then
		self.btn_text_1:SetValue(string.format(Language.GodDropGift.ToggleName, 60))
		self.btn_text_2:SetValue(string.format(Language.GodDropGift.ToggleName, 300))
	end
end

function GodDropGiftView:SetModelInfo(index)
	local data = GodDropGiftData.Instance:GetGodDropGiftInfo(CHARGE_NUM[index])
	if nil == next(data) then return end
	self:FlushModel(data.model_id1, data.path_1, data.model_id2, data.path_2)
end

function GodDropGiftView:OnCloseClick()
	self:Close()
end

function GodDropGiftView:OnClickToggle60()
	if self.select_index ~= 1 then
		self.select_index = 1
		self.toggle_1.toggle.isOn = true
		self:Flush()
		self:SetModelInfo(self.select_index)
	end
end

function GodDropGiftView:OnClickToggle300()
	if self.select_index ~= 2 then
		self.select_index = 2
		self.toggle_2.toggle.isOn = true
		self:Flush()
		self:SetModelInfo(self.select_index)
	end
end

function GodDropGiftView:FlushRedPointAndBtnState(index)
	local can_take_60 = GodDropGiftData.Instance:GetCanTakeFlag(CHARGE_NUM[1])
	local can_take_300 = GodDropGiftData.Instance:GetCanTakeFlag(CHARGE_NUM[2])
	local is_take = GodDropGiftData.Instance:GetFetchRewardFlag(CHARGE_NUM[index]) ~= 0 
	local charge_state = GodDropGiftData.Instance:GetChargeNum() >= CHARGE_NUM[index]
	--red point
	if self.is_can_take_60 and self.is_can_take_300 then
		self.is_can_take_60:SetValue(can_take_60)
		self.is_can_take_300:SetValue(can_take_300)
	end
	--btn state
	if self.is_can_take then
		self.is_can_take:SetValue(charge_state)
		self.is_take:SetValue(is_take)
	end
end

--非OnFlush()不要调用我，变量太多
function GodDropGiftView:FlushModelTipsImage(index)
	local cur_kaifu_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local data = GodDropGiftData.Instance:GetGodDropGiftInfo(CHARGE_NUM[index])
	if nil == next(data) then return end

	self.left_fp_text:SetValue(data.model_capbility1)
	self.right_fp_text:SetValue(data.model_capbility2)
	--默认
	self.show_l_image:SetValue(false)
	self.show_l_fp:SetValue(data.model_capbility1 > 0)
	self.show_r_image:SetValue(true)
	self.show_r_fp:SetValue(true)

	self.right_show_image:SetAsset(image_path, image_asset[1])
	if cur_kaifu_day <= 4 then
		self.left_show_image:SetAsset(image_path, image_asset[2])
		self.show_l_image:SetValue(true)
	elseif cur_kaifu_day == 7 then
		if index == 1 then
			self.show_l_image:SetValue(true)
			self.left_show_image:SetAsset(image_path, image_asset[3])
		end
	end
end
