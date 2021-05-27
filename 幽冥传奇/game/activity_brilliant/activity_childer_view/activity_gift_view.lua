GiftView = GiftView or BaseClass(ActBaseView)

function GiftView:__init(view, parent, act_id)
	self:LoadView(parent)
	self.act_id = act_id
end

function GiftView:__delete()
	if nil~=self.grid_GFbaoshi_scroll_list then
		self.grid_GFbaoshi_scroll_list:DeleteMe()
	end
	self.grid_GFbaoshi_scroll_list = nil

	if nil~=self.grid_GFtejie_scroll_list then
		self.grid_GFtejie_scroll_list:DeleteMe()
	end
	self.grid_GFtejie_scroll_list = nil

	if nil~=self.grid_GFshengzhu_scroll_list then
		self.grid_GFshengzhu_scroll_list:DeleteMe()
	end
	self.grid_GFshengzhu_scroll_list = nil

	if nil~=self.grid_GFcharge_scroll_list then
		self.grid_GFcharge_scroll_list:DeleteMe()
	end
	self.grid_GFcharge_scroll_list = nil

	if nil~=self.grid_GFxiaofei_scroll_list then
		self.grid_GFxiaofei_scroll_list:DeleteMe()
	end
	self.grid_GFxiaofei_scroll_list = nil

	if nil~=self.grid_GFWing_scroll_list then
		self.grid_GFWing_scroll_list:DeleteMe()
	end
	self.grid_GFWing_scroll_list = nil
end

function GiftView:InitView()
	if self.act_id == ACT_ID.BSGIFT then
		self:CreateGFBaoshiGridScroll()
	elseif self.act_id == ACT_ID.TJGIFT then
		self:CreateGFTejieGridScroll()
	elseif self.act_id == ACT_ID.SZGIFT then
		self:CreateGFShengzhuGridScroll()
	elseif self.act_id == ACT_ID.CZGIFT then
		self:CreateGFChargeGridScroll()
	elseif self.act_id == ACT_ID.XFGIFT then
		self:CreateGFXiaofeiGridScroll()
	elseif self.act_id == ACT_ID.WINGGIFT then
		self:CreateGFWingGridScroll()
	end
end

function GiftView:RefreshView(param_list)
	local data = ActivityBrilliantData.Instance
	for k,v in pairs(param_list) do
		if k == "flush_view" then
			local reward_list = ActivityBrilliantData.Instance:GetRankList(v.act_id)
			local mine_num = data.mine_num[v.act_id]
			local mine_rank = data.mine_rank[v.act_id]
			self.node_t_list.lbl_activity_tip.node:setString(mine_num)
			self.node_t_list.lbl_gift_rank.node:setString(mine_rank)
			if v.act_id == ACT_ID.CZGIFT then 
				self.grid_GFcharge_scroll_list:SetDataList(reward_list)
				self.grid_GFcharge_scroll_list:JumpToTop()
			elseif v.act_id == ACT_ID.XFGIFT then
				self.grid_GFxiaofei_scroll_list:SetDataList(reward_list)
				self.grid_GFxiaofei_scroll_list:JumpToTop()
			elseif v.act_id == ACT_ID.BSGIFT then 
				self.grid_GFbaoshi_scroll_list:SetDataList(reward_list)
				self.grid_GFbaoshi_scroll_list:JumpToTop()
			elseif v.act_id == ACT_ID.SZGIFT then 
				self.grid_GFshengzhu_scroll_list:SetDataList(reward_list)
				self.grid_GFshengzhu_scroll_list:JumpToTop()
			elseif v.act_id == ACT_ID.TJGIFT then 
				self.grid_GFtejie_scroll_list:SetDataList(reward_list)
				self.grid_GFtejie_scroll_list:JumpToTop()
			elseif v.act_id == ACT_ID.WINGGIFT then 
				self.grid_GFWing_scroll_list:SetDataList(reward_list)
				self.grid_GFWing_scroll_list:JumpToTop()
			end
		end
	end
end

--全民宝石
function GiftView:CreateGFBaoshiGridScroll()
	local ph = self.ph_list.ph_charge_gift_view_list
	self.grid_GFbaoshi_scroll_list = GridScroll.New()
	self.grid_GFbaoshi_scroll_list:Create(ph.x, ph.y, ph.w, ph.h, 1, self.ph_list["ph_gift_list"].h + 3, GiftItemRender, ScrollDir.Vertical, false, self.ph_list.ph_gift_list)
	self.node_t_list.layout_baoshi_gift.node:addChild(self.grid_GFbaoshi_scroll_list:GetView(), 100)
end

--充值豪礼
function GiftView:CreateGFChargeGridScroll()
	local ph = self.ph_list.ph_gift_view_list
	self.grid_GFcharge_scroll_list = GridScroll.New()
	self.grid_GFcharge_scroll_list:Create(ph.x, ph.y, ph.w, ph.h, 1, self.ph_list["ph_gift_list"].h + 3, GiftItemRender, ScrollDir.Vertical, false, self.ph_list.ph_gift_list)
	self.node_t_list.layout_charge_gift.node:addChild(self.grid_GFcharge_scroll_list:GetView(), 100)
end

--消费豪礼
function GiftView:CreateGFXiaofeiGridScroll()
	local ph = self.ph_list.ph_charge_gift_view_list
	self.grid_GFxiaofei_scroll_list = GridScroll.New()
	self.grid_GFxiaofei_scroll_list:Create(ph.x, ph.y, ph.w, ph.h, 1, self.ph_list["ph_gift_list"].h + 3, GiftItemRender, ScrollDir.Vertical, false, self.ph_list.ph_gift_list)
	self.node_t_list.layout_xiaofei_gif.node:addChild(self.grid_GFxiaofei_scroll_list:GetView(), 100)
end

--全民特戒
function GiftView:CreateGFTejieGridScroll()
	local ph = self.ph_list.ph_charge_gift_view_list
	self.grid_GFtejie_scroll_list = GridScroll.New()
	self.grid_GFtejie_scroll_list:Create(ph.x, ph.y, ph.w, ph.h, 1, self.ph_list["ph_gift_list"].h + 3, GiftItemRender, ScrollDir.Vertical, false, self.ph_list.ph_gift_list)
	self.node_t_list.layout_tejie_gift.node:addChild(self.grid_GFtejie_scroll_list:GetView(), 100)
end

--全民圣珠
function GiftView:CreateGFShengzhuGridScroll()
	local ph = self.ph_list.ph_charge_gift_view_list
	self.grid_GFshengzhu_scroll_list = GridScroll.New()
	self.grid_GFshengzhu_scroll_list:Create(ph.x, ph.y, ph.w, ph.h, 1, self.ph_list["ph_gift_list"].h + 3, GiftItemRender, ScrollDir.Vertical, false, self.ph_list.ph_gift_list)
	self.node_t_list.layout_shengzhu_gift.node:addChild(self.grid_GFshengzhu_scroll_list:GetView(), 100)
end


--全民圣珠
function GiftView:CreateGFWingGridScroll()
	local ph = self.ph_list.ph_charge_gift_view_list
	self.grid_GFWing_scroll_list = GridScroll.New()
	self.grid_GFWing_scroll_list:Create(ph.x, ph.y, ph.w, ph.h, 1, self.ph_list["ph_gift_list"].h + 3, GiftItemRender, ScrollDir.Vertical, false, self.ph_list.ph_gift_list)
	self.node_t_list.layout_wing_gift.node:addChild(self.grid_GFWing_scroll_list:GetView(), 100)
end