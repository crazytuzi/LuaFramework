------------------------------------------------------------
-- 威望任务 配置 PrestigeSysConfig
------------------------------------------------------------

PrestigeTaskView = PrestigeTaskView or BaseClass(BaseView)

function PrestigeTaskView:__init()
	-- self:SetModal(true)
	self:SetIsAnyClickClose(true)
	self.texture_path_list[1] = "res/xui/prestige_task.png"
	self.texture_path_list[2] = "res/xui/fuben.png"
	self.texture_path_list[3] = "res/xui/fuben_cl.png"
	self.config_tab = {
		
		{"common2_ui_cfg", 1, {0}},
		{"prestige_task_ui_cfg", 1, {0}},
		{"common2_ui_cfg", 2, {0}, nil, 999},
	}

	self.award_list_view = nil
	self.convertible = false -- 可兑换标记
end

function PrestigeTaskView:__delete()
end

function PrestigeTaskView:ReleaseCallBack()
	if self.prestige_task_awradlist ~= nil then
		self.prestige_task_awradlist:DeleteMe()
		self.prestige_task_awradlist = nil
	end

	if self.award_list_view then
		self.award_list_view:DeleteMe()
		self.award_list_view = nil
	end

	self.convertible = false
end

function PrestigeTaskView:LoadCallBack(index, loaded_times)
	self.data = PrestigeTaskData.Instance:GetData()
	self:CreateAwardListView()
	self:CreateTextBtn()

	local path, name = ResPath.GetEffectUiAnimPath(301)
	self.effect = AnimateSprite:create(path, name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
	self.effect:setPosition(self.ph_list["ph_effect"].x, self.ph_list["ph_effect"].y)
	self.node_t_list["layout_prestige_task"].node:addChild(self.effect, 50)
	CommonAction.ShowJumpAction(self.effect, 10) -- 上下浮动特效

	self.node_t_list["btn_challenge"].node:addClickEventListener(BindTool.Bind(self.OnChallenge, self, true))
	self.node_t_list["btn_challenge"].remind_eff = RenderUnit.CreateEffect(23, self.node_t_list["btn_challenge"].node, 1)
	EventProxy.New(PrestigeTaskData.Instance, self):AddEventListener(PrestigeTaskData.TASK_DATA_CHANGE, BindTool.Bind(self.OnDataChange, self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagDataChange, self))
end

function PrestigeTaskView:OpenCallBack()
	--播放声音
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function PrestigeTaskView:CloseCallBack(is_all)
	PrestigeTaskData.Instance:SetRewardListVis(false)
	self.convertible = false
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function PrestigeTaskView:OnFlush(param_t, index)
end 

function PrestigeTaskView:ShowIndexCallBack(index)
	self:FlushTextView()
	if self.data.vis then
		self:FlushAwardList()
	end
	self:FlushBtn()

	ViewManager.Instance:CloseViewByDef(ViewDef.Tasks) -- 加载完后关闭"任务面板"
end

----------视图函数----------
function PrestigeTaskView:CreateAwardListView()
	local prestige_task_data = PrestigeSysConfig
	local prestige_task_award = prestige_task_data.item_list--奖励数据
	local ph = self.ph_list.ph_prestige_task_award_list--获取区间列表
	local items = {}
	for k, v in pairs(prestige_task_award) do
		items[k] = ItemData.FormatItemData(v)
	end
	
	--local Num = #items
	local line = 2  --行
	local lie = 3 --列
	local width = ph.w + 100 --可视区域宽
	local height = line * ph.h  --可视区域高
	
	self.prestige_task_awradlist = GridScroll.New()
	self.prestige_task_awradlist:Create(ph.x-30, ph.y,width,height,lie, ph.h, BaseCell, ScrollDir.Vertical, true)
	self.node_t_list["layout_prestige_task"].node:addChild(self.prestige_task_awradlist:GetView(), 100)
	self.prestige_task_awradlist:SetDataList(items)
end

-- 刷新文本视图
function PrestigeTaskView:FlushTextView()
	local item = PrestigeSysConfig.changecfg[1][1].consume[1] -- 获取配置
	local item_num = BagData.Instance:GetItemNumInBagById(item.id, nil) --获取背包的物品数量
	local text = "当前拥有屠魔令：{color;1eff00;" .. item_num .. "}"
	RichTextUtil.ParseRichText(self.node_t_list["rich_count"].node, text, 18, COLOR3B.DULL_GOLD)
	XUI.RichTextSetCenter(self.node_t_list["rich_count"].node)

	local times = PrestigeSysConfig.dayMaxCount - self.data.times
	text = "今日剩余兑换次数：{color;1eff00;" .. self.data.times .. "/" .. PrestigeSysConfig.dayMaxCount .. "}"
	RichTextUtil.ParseRichText(self.node_t_list["rich_times"].node, text, 18, COLOR3B.DULL_GOLD)
	XUI.RichTextSetCenter(self.node_t_list["rich_times"].node)
end

function PrestigeTaskView:CreateAwardList()
	--奖励render
	if self.award_list_view then return end
	self.award_list_view = ListView.New()
	self.award_list_view:Create(405, 300, 900, 250, ScrollDir.Horizontal, self.RewardRender, nil, nil, self.ph_list.ph_lingqu_item)
	self.award_list_view:GetView():setVisible(false)
	self.award_list_view:SetItemsInterval(5)
	self.award_list_view:GetView():setScale(0.9)
	self.node_t_list["layout_prestige_task"].node:addChild(self.award_list_view:GetView(), 300)

	local img_bg = XUI.CreateLayout(512 / 2, 659 / 2, 512, 659)
	img_bg:setBackGroundColor(COLOR3B.BLACK)
	img_bg:setBackGroundColorOpacity(200)
	self.node_t_list["layout_prestige_task"].node:addChild(img_bg, 200)

	self.award_list_view.SetVisible = function (_, bool)
		self.award_list_view:GetView():setVisible(bool) 
		img_bg:setVisible(bool)
	end

	XUI.AddClickEventListener(img_bg, function()
		self.award_list_view.SetVisible(false)
	end)
end

function PrestigeTaskView:FlushAwardList()
	if self.data.times == PrestigeSysConfig.dayMaxCount then return end
	if nil == self.award_list_view then
		self:CreateAwardList()
	end
	self.award_list_view:SetVisible(true)
	local list = {}
	local cfg = PrestigeSysConfig.changecfg
	for k,v in ipairs(cfg[(self.data.times + 1)]) do
		list[k] = {prestige_value = v.award[1].count,  count = v.consume[1].count, gold_cfg = v.consume[2], index = k,}
	end
	self.award_list_view:SetDataList(list)
end

function PrestigeTaskView:FlushBtn()
	if self.data.times ~= PrestigeSysConfig.dayMaxCount then
		local item_cfg = PrestigeSysConfig.changecfg[self.data.times + 1][1].consume[1] -- 获取屠魔令配置
		local item_num = BagData.Instance:GetItemNumInBagById(item_cfg.id, nil)	--获取背包的屠魔令数量
		if item_num >= item_cfg.count then
			self.node_t_list["btn_challenge"].node:setTitleText("可兑换")
			self.node_t_list["btn_challenge"].remind_eff:setVisible(true)
			self.convertible = true
		else
			self.node_t_list["btn_challenge"].node:setTitleText("挑 战")
			self.node_t_list["btn_challenge"].remind_eff:setVisible(false)
			self.convertible = false
			if nil ~= self.award_list_view then
				self.award_list_view.SetVisible(false)
			end
		end
	else
		self.node_t_list["btn_challenge"].node:setTitleText("挑 战")
		self.node_t_list["btn_challenge"].remind_eff:setVisible(false)
		self.convertible = false
	end
end


-- 创建"查看威望"按钮
function PrestigeTaskView:CreateTextBtn()
	local ph = self.ph_list["ph_text_btn"]
	local text = RichTextUtil.CreateLinkText("查看威望", 19, COLOR3B.GREEN, nil, true)
	text:setPosition(ph.x, ph.y)
	self.node_t_list["layout_prestige_task"].node:addChild(text, 99)
	XUI.AddClickEventListener(text, BindTool.Bind(self.OnTextBtn, self), true)
end

----------end----------

-- "挑战按钮"点击回调
function PrestigeTaskView:OnChallenge()
	-- 可兑换时
	if self.convertible then
		self:FlushAwardList()
	else
		self:Close()
		PrestigeTaskCtrl.Instance:SendPrestigeTaskChallenge()
	end
end

function PrestigeTaskView:OnDataChange()
	self:FlushTextView()
	self:FlushBtn()
end

function PrestigeTaskView:OnBagDataChange()
	self:FlushTextView()
	self:FlushBtn()
	if self.award_list_view then
		self.award_list_view.SetVisible(false)
	end
end

-- "文本按钮"点击回调
function PrestigeTaskView:OnTextBtn()
	-- 打开威望面板
	ViewManager.Instance:OpenViewByDef(ViewDef.Prestige)
	self:Close()
end

----------奖励列表----------

PrestigeTaskView.RewardRender = BaseClass(BaseRender)
local RewardRender = PrestigeTaskView.RewardRender
function RewardRender:__init()
	
end

function RewardRender:__delete()
    if self.alert_window then
		self.alert_window:DeleteMe()
  		self.alert_window = nil
	end	
end

function RewardRender:CreateChild()
	BaseRender.CreateChild(self)
	
	if nil == self.data then return end
	self.gold = self.data.gold_cfg ~= nil and self.data.gold_cfg.count or 0
	XUI.AddClickEventListener(self.node_tree.btn_lingqu.node, function ()
		local playergold = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD)
		if playergold < self.gold then
            self:OpenTipView()
--			SysMsgCtrl.Instance:ErrorRemind(Language.Common.NoEnoughGold)
		else
			PrestigeTaskCtrl.Instance:SendGetPrestigeTaskAward(self.data.index)
		end
	end, true)
end

function RewardRender:OpenTipView()
	if self.alert_window == nil then
		self.alert_window = Alert.New()
		self.alert_window:SetOkString(Language.Common.BtnRechargeText)
		self.alert_window:SetLableString(Language.Common.RechargeAlertText)
		self.alert_window:SetOkFunc(BindTool.Bind(self.OnChargeRightNow, self))
	end
	self.alert_window:Open()
end

--充值
function RewardRender:OnChargeRightNow()
    ViewManager.Instance:OpenViewByDef(ViewDef.ZsVip.Recharge)
end

function RewardRender:CreateSelectEffect()
end

function RewardRender:OnFlush()
	if nil == self.data then return end
	self.node_tree.lbl_exp_num.node:setString("威望值:" .. self.data.prestige_value)
	self.node_tree.lbl_count.node:setString("上交屠魔令*" .. self.data.count)
	self.node_tree.img_times.node:loadTexture(ResPath.GetFuben("img_times_" .. self.data.index))
    if 3 == self.data.index then
        RenderUnit.CreateEffect(23, self.node_tree.btn_lingqu.node, 1)
    end
	if self.gold > 0 then
		self.node_tree.lbl_lingqu_tip.node:setString(self.gold)
	else
		self.node_tree.lbl_lingqu_tip.node:setString("(免费)")
	end
	self.node_tree.img_gold.node:setVisible(self.gold > 0)
end

----------end----------
