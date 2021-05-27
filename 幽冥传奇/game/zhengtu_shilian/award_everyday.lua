--------------------------------------------------------
-- 试炼每日奖励  配置 TrialEveryDayAward
--------------------------------------------------------

AwardEveryView = AwardEveryView or BaseClass(BaseView)

function AwardEveryView:__init()
	self:SetModal(true)
	self.is_any_click_close = true

	self.texture_path_list = {
		'res/xui/zhengtu_shilian.png',
	}
	self.config_tab = {
		{"zhengtu_shilian_ui_cfg", 4, {0}},
	}

	self.cfg = TrialEveryDayAwardCfg
	self.data = ZhengtuShilianData.Instance:GetDailyRewardData()
end

function AwardEveryView:ReleaseCallBack()
	if self.drop_list then
		self.drop_list:DeleteMe()
		self.drop_list = nil
	end
end


function AwardEveryView:OpenCallBack()
	-- 请求试炼每日奖励
	if not ZhengtuShilianData.Instance:IsNotNeedSendReqEverydayAward() then
		ZhengtuShilianCtrl.Instance.SendShiLianAwardInfoReq()
	end

	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function AwardEveryView:LoadCallBack(index, loaded_times)
	self:CreateDropList() --掉落

	XUI.AddClickEventListener(self.node_t_list["btn_lingqu"].node, BindTool.Bind(self.OnReceive, self), true)

	EventProxy.New(ZhengtuShilianData.Instance, self):AddEventListener(ZhengtuShilianData.DAILY_REWARD_DATA_CHANGE, BindTool.Bind(self.OnDailyRewardDataChange, self))
end

function AwardEveryView:ShowIndexCallBack(index)
	local list = ZhengtuShilianData.Instance:GetEverydayAwardCfg()
	if nil ~= list then
		self.drop_list:SetDataList(list)
		self.drop_list:JumpToTop()
	end
end

function AwardEveryView:CreateDropList()
	if nil == self.drop_list then
		local ph = self.ph_list.ph_award_list
		self.drop_list = GridScroll.New()
		self.drop_list:Create(ph.x, ph.y, ph.w, ph.h, 4, 110, self.ItemRender, ScrollDir.Vertical, false, self.ph_list.ph_item)
		self.node_t_list.layout_award_everyday.node:addChild(self.drop_list:GetView(), 100)
	end
end

function AwardEveryView:OnFlush(param_t, index)

end

-- 领取按钮点击回调
function AwardEveryView:OnReceive()
	-- 请求领取试炼每日奖励
	ZhengtuShilianCtrl.Instance.SendSCSShiLianAwardLingQuReq()
	self:Close()
end

-- 试炼每日奖励数据改变回调
function AwardEveryView:OnDailyRewardDataChange()
	local list = ZhengtuShilianData.Instance:GetEverydayAwardCfg()
	if nil ~= list then
		self.drop_list:SetDataList(list)
		self.drop_list:JumpToTop()
	end
end

----------------------------------------
-- 物品显示配置
----------------------------------------
AwardEveryView.ItemRender = BaseClass(BaseRender)
local ItemRender = AwardEveryView.ItemRender

function ItemRender:__init()
	self.item_cell = nil
end

function ItemRender:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function ItemRender:CreateChild()
	BaseRender.CreateChild(self)
	self.item_cell = BaseCell.New()
	self.item_cell:SetPosition(self.ph_list.ph_jp.x, self.ph_list.ph_jp.y)
	self.item_cell:GetView():setAnchorPoint(cc.p(0.5, 0.5))
	self.view:addChild(self.item_cell:GetView(), 7)
end

function ItemRender:OnFlush()
	if nil == self.data then return end

	local item_config = ItemData.Instance:GetItemConfig(self.data.item_id)
	self.item_cell:SetData(self.data)
	self.node_tree.lbl_jp.node:setColor(Str2C3b(string.sub(string.format("%06x", item_config.color), 1, 6)))
	self.node_tree.lbl_jp.node:setString(item_config.name)
end

function ItemRender:CreateSelectEffect()
	return
end

function ItemRender:OnClickBuyBtn()
	if nil ~= self.click_callback then
		self.click_callback(self)
	end
end

function ItemRender:OnClick()
	if nil ~= self.click_callback then
		-- self.click_callback(self)
	end
end