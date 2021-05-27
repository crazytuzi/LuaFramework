ShilianView = ShilianView or BaseClass(BaseView)

function ShilianView:__init()
	self.title_img_path = ResPath.GetWord("word_shilian")
	self:SetModal(true)
	self.texture_path_list = {
		'res/xui/zhengtu_shilian.png',
	}
	self.config_tab = {
		{"zhengtu_shilian_ui_cfg", 2, {0}},
	}


	self.daily_reward_data = nil -- 每日奖励数据
	self.free_count = nil -- 每日奖励免费领取次数
end

function ShilianView:ReleaseCallBack()
	self.drop_list:DeleteMe()

	self.remind_bg_sprite = nil
	self.remind_zw_sprite = nil
	self.remind = nil
end


function ShilianView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleDataChangeCallback, self))
end

function ShilianView:RoleDataChangeCallback(vo)
	if vo.key == OBJ_ATTR.ACTOR_RING_CRYSTAL then
		self:Flush()
	elseif key == OBJ_ATTR.ACTOR_SOUL2 then
	end
end

function ShilianView:CreateDropList()
	--掉落列表
	local ph = self.ph_list.ph_shilian_list
	self.drop_list = ListView.New()

	self.drop_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, NameCell)
	self.drop_list:SetItemsInterval(10)
	self.node_t_list.layout_shilian.node:addChild(self.drop_list:GetView(), 300)

	local list = {}
	for i,v in ipairs(TrialMapConfig.showItems) do
		list[i] = ItemData.FormatItemData(v)
	end

	self.drop_list.Update = function (_, list)
		self.drop_list:SetDataList(list)
		--设置居中
		local temp_node = self.drop_list:GetView()
			local render_w = 90
			local width = render_w * self.drop_list:GetCount()
			local cont_w = self.ph_list.ph_shilian_list.w
			local offest = cont_w - width < 0 and cont_w or (cont_w - width) / 2
			temp_node:setPositionX(temp_node:getPositionX() + offest)
		temp_node = nil
	end

	self.drop_list:Update(list)
end

function ShilianView:LoadCallBack(index, loaded_times)
	self.daily_reward_data = ZhengtuShilianData.Instance:GetDailyRewardData() -- 获取每日奖励数据
	self.free_count = TrialEveryDayAwardCfg.freeCount -- 获取每日奖励免费领取次数

	if loaded_times <= 1 then
		self:CreateDropList() --掉落
		self:CreateTopTitle(self.title_img_path, 275, 695, self.node_t_list.layout_shilian.node)

		self.rich_link = RichTextUtil.CreateLinkText(Language.ShiLian.RankTip, 20, COLOR3B.GREEN, nil, true)
		self.rich_link:setPosition(80, 430)
		self.node_t_list.layout_shilian.node:addChild(self.rich_link, 100)
		XUI.AddClickEventListener(self.rich_link,function ()
			local can_open_rankinglist = GameCondMgr.Instance:GetValue("CondId71")
			if not can_open_rankinglist then
				SysMsgCtrl.Instance:FloatingTopRightText(Language.Prestige.OpenTips)
			else
				ViewManager.Instance:OpenViewByDef(ViewDef.RankingList.Trial)
			end
		end)

        if IS_AUDIT_VERSION then
        	self.node_t_list.btn_rotary_table.node:setVisible(false)
            self.rich_link:setVisible(false)
    	end
		XUI.AddClickEventListener(self.node_t_list.btn_zt.node, function () ViewManager.Instance:OpenViewByDef(ViewDef.BattleFuwen) end)
		XUI.AddClickEventListener(self.node_t_list.btn_go.node,function () PracticeCtrl.SendEnterPractice(1); self:Close() end, true)
		XUI.AddClickEventListener(self.node_t_list.btn_rotary_table.node,function () ViewManager.Instance:OpenViewByDef(ViewDef.ShiLianRotaryTable); self:Close() end, true)
		XUI.AddClickEventListener(self.node_t_list.btn_award_everyday.node, BindTool.Bind(self.OnAwardEveryDay, self), ture)
	end

	--战纹数据发生变化
	EventProxy.New(BattleFuwenData.Instance, self):AddEventListener(BattleFuwenData.BATTLE_FUWEN_ONE_INFO_CHANGE, BindTool.Bind(self.FlushZhanWenRemind, self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.FlushZhanWenRemind, self))
	EventProxy.New(ZhengtuShilianData.Instance, self):AddEventListener(ZhengtuShilianData.DAILY_REWARD_DATA_CHANGE, BindTool.Bind(self.OnDailyRewardDataChange, self))
end

function ShilianView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ShilianView:ShowIndexCallBack(index)
	self:FlushDailyRewardView()
	self:Flush(index)
end

function ShilianView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ShilianView:OnFlush(param_t, index)
	local act_part_num = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_RING_CRYSTAL)
	local part_num = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SOUL2)

	-- self.btn_zt_effect:setVisible(part_num >= (act_part_num + 1) * 10)

	self.node_t_list.lbl_part_num.node:setString("已闯关: " .. part_num)

	local exp_num = part_num == 0 and 0 or TrialFloorConfig.Floor[part_num].nExp * 6 * 60
	self.node_t_list.lbl_exp_num.node:setString(string.format(Language.ShiLian.Tip1, exp_num))

	self:FlushRemind()
	self:FlushZhanWenRemind()
end

-- 刷新寻宝按钮特效提示
function ShilianView:FlushRemind()
	local vis = ZhengtuShilianData.Instance.GetRemindIndex() > 0
	local node = self.node_t_list["btn_rotary_table"].node
	self:SetRemind(node, vis)	
end

-- 设置提醒
function ShilianView:SetRemind(node, vis)
	if vis and nil == self.remind_bg_sprite then
		self.remind_bg_sprite = RenderUnit.CreateEffect(333, node, 999)
	elseif self.remind_bg_sprite then
		self.remind_bg_sprite:setVisible(vis)
	end
end

-- 刷新战纹按钮特效提示
function ShilianView:FlushZhanWenRemind()
	local vis = BattleFuwenData.Instance:GetRewardRemind() > 0
	local node = self.node_t_list["btn_zt"].node
	self:SetZhanWenRemind(node, vis)
end

function ShilianView:FlushDailyRewardView()
	local bool = self.daily_reward_data.times < self.free_count
	local text = bool and Language.ShiLian.Tip3 or Language.ShiLian.Tip2
	self.node_t_list["lbl_award_tip"].node:setString(text)
	self:SetDailyRewardRemind(self.node_t_list["btn_award_everyday"].node, bool)
end

-- 设置提醒
function ShilianView:SetZhanWenRemind(node, vis)
	if vis and nil == self.remind_zw_sprite then
		self.remind_zw_sprite = RenderUnit.CreateEffect(336, node, 999)
	elseif self.remind_zw_sprite then
		self.remind_zw_sprite:setVisible(vis)
	end
end

-- 设置每日奖励提醒
function ShilianView:SetDailyRewardRemind(node, vis, path, x, y)
	path = path or ResPath.GetMainui("remind_flag")
	local size = node:getContentSize()
	x = x or size.width - 15
	y = y or size.height - 17
	if vis and nil == self.remind then		
		self.remind = XUI.CreateImageView(x, y, path, true)
		node:addChild(self.remind, 1, 1)
	elseif self.remind then
		self.remind:setVisible(vis)
	end
end

function ShilianView:OnAwardEveryDay()
	local part_num = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SOUL2)
	if part_num == 0 then
		SysMsgCtrl.Instance:FloatingTopRightText(Language.ShiLian.Tip4)
		return
	end
	if self.daily_reward_data.times >= self.free_count then
		SysMsgCtrl.Instance:FloatingTopRightText(Language.ShiLian.Tip2)
	else
		ViewManager.Instance:OpenViewByDef(ViewDef.AwardEveryDay)
	end
end

-- 每日奖励数据改变回调
function ShilianView:OnDailyRewardDataChange()
	self:FlushDailyRewardView()
end

----------------------------------------------------
-- 带名字basecell
----------------------------------------------------
NameCell = NameCell or BaseClass(BaseCell)

function NameCell:__init()
end

function NameCell:__delete()
end

function NameCell:OnFlush(...)
	if BaseCell.OnFlush(self, ...) then
		local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
		if nil == self.item_name then
			self.item_name = XUI.CreateText(BaseCell.SIZE / 2, - 12, 0, 0, cc.TEXT_ALIGNMENT_CENTER, item_cfg.name, nil, 18)
			self.view:addChild(self.item_name, 300)
		end
		self.item_name:setString(item_cfg.name)
		self.item_name:setColor(Str2C3b(string.sub(string.format("%06x", item_cfg.color), 1, 6)))
	end
end

function NameCell:CreateSelectEffect()
end