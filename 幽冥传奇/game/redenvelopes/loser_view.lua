LoserView = LoserView or BaseClass(XuiBaseView)

function LoserView:__init()
	self:SetModal(true)
	self.texture_path_list[1] = 'res/xui/loser.png'
	self.texture_path_list[2] = 'res/xui/redenvelopes.png'
	self.config_tab = {
		{"loser_ui_cfg", 1, {0}},
		{"loser_ui_cfg", 2, {0}}
	}
end

function LoserView:__delete()
	
end

function LoserView:ReleaseCallBack()
	if nil~=self.loser_scroll_list then
		self.loser_scroll_list:DeleteMe()
	end
	self.loser_scroll_list = nil
end


function LoserView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateLoserListScroll()
	end
end
function LoserView:ShowIndexCallBack(index)
	RedEnvelopesCtrl.Instance:RedEnvelopesReq(2, 1)
	self:Flush(index)
end

function LoserView:OnFlush(param_list, index)
	for k, v in pairs(param_list) do
		if "all" == k then
			self.loser_scroll_list:SetDataList(RedEnvelopesData.Instance:GetLoserItemList())
			self.loser_scroll_list:JumpToTop(true)
		elseif "showAnim" == k then
			self:ShowPickUpAnim(param_list.showAnim.index)
		end	
	end
end

function LoserView:CreateLoserListScroll()
	if nil == self.node_t_list.layout_zhanli_list then
		return
	end
	if nil == self.loser_scroll_list then
		local ph = self.ph_list.ph_zhanli_view_list
		self.loser_scroll_list = ListView.New()
		self.loser_scroll_list:Create(ph.x, ph.y, ph.w, ph.h, nil, LoserItemRender, nil, true, self.ph_list.ph_zhanli_list)
		self.loser_scroll_list:SetMargin(2)
		self.node_t_list.layout_zhanli_list.node:addChild(self.loser_scroll_list:GetView(), 100)
	end
end

function LoserView:ShowPickUpAnim(index)
	if nil == index then return end
		local act_render = self.loser_scroll_list:GetItemAt(index)
		if nil == act_render then 
			return 
		end
		local old_x= act_render:GetView():getPositionX()
		local action_time = 0.5
		local move_action = cc.MoveBy:create(action_time, cc.p(650, 0))
		local fadeout_action = cc.FadeOut:create(action_time)
		local spawn_action = cc.Spawn:create(move_action, fadeout_action)
		local callback = cc.CallFunc:create(function()
				act_render:GetView():setPositionX(old_x)
				act_render:GetView():setOpacity(255)
				self.loser_scroll_list:SetDataList(RedEnvelopesData.Instance:GetLoserItemList())
				self.loser_scroll_list:JumpToTop(true)
				self.loser_scroll_list:GetView():refreshView()
				RedEnvelopesData.Instance:SetActIndex(-1)
			end)
		local action = cc.Sequence:create(spawn_action, callback)
		act_render:GetView():runAction(action)
end
--------------------------
-----屌丝逆袭
--------------------------
LoserItemRender = LoserItemRender or BaseClass(BaseRender)
function LoserItemRender:__init()

end

function LoserItemRender:__delete()
	if nil ~= self.cell_zhanli_list then
		for k,v in pairs(self.cell_zhanli_list) do
			v:DeleteMe()
    		v = nil
		end
    end
	self.cell_zhanli_list = {}

	if nil ~= self.zhanli_num then
		self.zhanli_num:DeleteMe()
		self.zhanli_num = nil
	end

	if nil ~= self.buy_alert then 
		self.buy_alert:DeleteMe()
		self.buy_alert = nil
	end
end

function LoserItemRender:CreateChild()
	BaseRender.CreateChild(self)
	self.cell_zhanli_list = {}
	for i = 1, 6 do 
		local cell = BaseCell.New()
		local ph = self.ph_list["ph_zhanli_award_"..i]
		cell:SetPosition(ph.x, ph.y)
		cell:SetIndex(i)
		cell:SetAnchorPoint(0.5, 0.5)
		self.view:addChild(cell:GetView(), 300)
		table.insert(self.cell_zhanli_list, cell)
		local cell_effect = AnimateSprite:create()
		cell_effect:setPosition(ph.w / 2 - 5, ph.h / 2 - 2)
		cell:GetView():addChild(cell_effect, 300)
		cell_effect:setVisible(false)
		cell.cell_effect = cell_effect
	end
	XUI.AddClickEventListener(self.node_tree.btn_zhanli_lingqu.node, BindTool.Bind(self.OnClickGetRewardBtn, self), true)
	self:CreateNumberBar()
end

function LoserItemRender:CreateNumberBar()
	local ph = self.ph_list.ph_zhanli_num
	self.zhanli_num = NumberBar.New()
	self.zhanli_num:SetRootPath(ResPath.GetCommon("num_118_"))
	self.zhanli_num:SetPosition(ph.x, ph.y)
	self.zhanli_num:SetGravity(NumberBarGravity.Center)
	self.zhanli_num:GetView():setScale(0.8)
	self.view:addChild(self.zhanli_num:GetView(), 300, 300)
end

function LoserItemRender:OnClickGetRewardBtn()
	if self.data == nil then return end
	RedEnvelopesData.Instance:SetActIndex(self.index)
	local btntext = self.node_tree.btn_zhanli_lingqu.node:getTitleText()
	if btntext == Language.Loser.QuickUpgrade then                                                                                         --战力未达到弹出战力获取面板
		local data = {
			{stuff_way = Language.Loser.LoserWay[1], go_to = ActiveDegreeData.Instance:GetNpcQuicklyTransportId(84)},                      --未知暗殿
			{stuff_way = Language.Loser.LoserWay[2], go_to = ActiveDegreeData.Instance:GetNpcQuicklyTransportId(88)},                      --玛雅神殿
			{stuff_way = Language.Loser.LoserWay[3], go_to = ActiveDegreeData.Instance:GetNpcQuicklyTransportId(85)},                      --boss之家
			{stuff_way = Language.Loser.LoserWay[4], open_view =  ViewName.Boss},                                                          --挑战boss
			{stuff_way = Language.Loser.LoserWay[5], go_to = ActiveDegreeData.Instance:GetNpcQuicklyTransportId(80)},                      --副本总管
			{stuff_way = Language.Loser.LoserWay[6], open_view =  ViewName.Explore},                                                       --探索宝藏
		}
		TipCtrl.Instance:OpenStuffTip(Language.Loser.LoserWayTitle, data)
	elseif self.data.index < RedEnvelopesData.Instance:GetConsumLevel(ViewName.Loser) then       --直接领取
		RedEnvelopesCtrl.Instance:RedEnvelopesReq(2, 2, self.data.index)
	else                                                                         --消耗元宝
		if nil == self.data.consume then return end
		self.buy_alert = self.buy_alert or Alert.New()
		self.buy_alert:SetShowCheckBox(false)
		local des = string.format(Language.RedEnvelopes.BuyAlert, self.data.consume, self.data.consume)
		self.buy_alert:SetLableString(des)
		self.buy_alert:SetOkString(Language.RedEnvelopes.BuyAlertPick)
		self.buy_alert:SetCancelString(Language.RedEnvelopes.BuyAlertRecharge)
		self.buy_alert:SetOkFunc(function()
			if RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD) < self.data.consume then
				SysMsgCtrl.Instance:FloatingTopRightText(Language.Common.NoEnoughGold)
			end
			RedEnvelopesCtrl.Instance:RedEnvelopesReq(2, 2,self.data.index) 
		end)
		self.buy_alert:SetCancelFunc(function()
			ViewManager.Instance:OpenViewByDef(ViewDef.ZsVip.Recharge)
		end)
		self.buy_alert:Open()
	end
end


function LoserItemRender:OnFlush()
	if nil == self.data then
		return
	end
	for k,v in pairs(self.cell_zhanli_list) do
		local item_data = {}
		if nil ~= self.data[k] then
			item_data.item_id = self.data[k].id
			item_data.num = self.data[k].count
			item_data.is_bind = self.data[k].bind
			item_data.effectId = self.data[k].effectId
			v:SetData(item_data)
			if item_data.effectId ~= nil then
				local path, name = ResPath.GetEffectUiAnimPath(item_data.effectId)
				if path and name then
					v.cell_effect:setAnimate(path, name, COMMON_CONSTS.MAX_LOOPS, 0.23, false)
					v.cell_effect:setVisible(true)
				end
			else
				v.cell_effect:setVisible(false)
			end
		else
			v:SetData(nil)
		end
		v:SetVisible(self.data[k] ~= nil)
	end

	local power = self.data.power                                            
	local role_power = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BATTLE_POWER)              --战力
	self.zhanli_num:SetNumber(power/10000)
	if nil == self.data.sign then return end
	local is_lingqu = self.data.sign > 0
	local can_lingqu = power - role_power
	local show_btn = self.data.show_btn
	local path = is_lingqu and ResPath.GetCommon("stamp_1") or ResPath.GetEnvelopes("word_stamp")
	local text = can_lingqu > 0 and Language.Loser.QuickUpgrade or Language.Loser.Pick
	self.node_tree.img_zhanli_reward_state.node:loadTexture(path)
	self.node_tree.img_zhanli_reward_state.node:setVisible(not show_btn or is_lingqu)
	self.node_tree.btn_zhanli_lingqu.node:setTitleText(text)
	self.node_tree.btn_zhanli_lingqu.node:setVisible(show_btn and not is_lingqu)
	self.node_tree.rich_zhanli_2.node:setVisible((show_btn and not is_lingqu) and can_lingqu > 0)
	local str = string.format(Language.Loser.LoserNeed, can_lingqu)
	RichTextUtil.ParseRichText(self.node_tree.rich_zhanli_2.node, str, 22)
end