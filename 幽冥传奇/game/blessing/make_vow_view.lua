
-- 祈福
local MakeVowView = BaseClass(SubView)

function MakeVowView:__init()
	self.texture_path_list = {
		'res/xui/blessing.png',
	}
    self.config_tab = {
		{"blessing_ui_cfg", 3, {0}},
	}
end

function MakeVowView:__delete()
end

function MakeVowView:ReleaseCallBack()
	if self.yb_bless_num then
		self.yb_bless_num:DeleteMe()
		self.yb_bless_num = nil
	end

	if self.lv_bless_num then
		self.lv_bless_num:DeleteMe()
		self.lv_bless_num = nil
	end

	if self.bless_up then
		self.bless_up:DeleteMe()
		self.bless_up = nil
	end

	if nil ~= self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end
end

function MakeVowView:LoadCallBack(index, loaded_times)
	self:CritNumCreat()

	XUI.AddClickEventListener(self.node_t_list.btn_yb_bless.node, BindTool.Bind2(self.OnClickBless, self, 1))
	XUI.AddClickEventListener(self.node_t_list.btn_lv_bless.node, BindTool.Bind2(self.OnClickBless, self, 2))

	XUI.AddClickEventListener(self.node_t_list.btn_yb_ques.node, BindTool.Bind2(self.OnBlessQues, self))
	XUI.AddClickEventListener(self.node_t_list.btn_lv_ques.node, BindTool.Bind2(self.OnBlessQues, self))

	RenderUnit.CreateEffect(1133, self.node_t_list.layout_blessing.node, 10, nil, nil, 238, 370)
	RenderUnit.CreateEffect(1134, self.node_t_list.layout_blessing.node, 10, nil, nil, 685, 310)

	EventProxy.New(BlessingData.Instance, self):AddEventListener(BlessingData.BLESSING_NUM, BindTool.Bind(self.OnBlessingNum, self))
end

function MakeVowView:ShowIndexCallBack()
	self:Flush()
end

function MakeVowView:OnBlessingNum()
	self:Flush()
end

-- 创建暴击次数
function MakeVowView:CritNumCreat()
	if self.yb_bless_num == nil then
		local ph = self.ph_list.ph_yb_num
		self.yb_bless_num = NumberBar.New()
		self.yb_bless_num:Create(ph.x, ph.y, 180, 40, ResPath.GetCommon("num_116_"))
		self.yb_bless_num:SetGravity(NumberBarGravity.Left)
		self.yb_bless_num:SetSpace(0)
		self.node_t_list.layout_blessing.node:addChild(self.yb_bless_num:GetView(), 300, 300)
	end

	if self.lv_bless_num == nil then
		local ph = self.ph_list.ph_lv_num
		self.lv_bless_num = NumberBar.New()
		self.lv_bless_num:Create(ph.x, ph.y, 180, 40, ResPath.GetCommon("num_116_"))
		self.lv_bless_num:SetGravity(NumberBarGravity.Left)
		self.lv_bless_num:SetSpace(0)
		self.node_t_list.layout_blessing.node:addChild(self.lv_bless_num:GetView(), 300, 300)
	end

	local ph = self.ph_list.ph_com_cell
	if nil == self.cell then
		self.cell = BaseCell.New()
		self.cell:SetPosition(ph.x - 10, ph.y)
		self.cell:SetIndex(i)
		self.cell:SetAnchorPoint(0.5, 0.5)
		self.cell:GetView():setScale(0.4)
		self.node_t_list.layout_blessing.node:addChild(self.cell:GetView(), 103)
		self.cell:SetData({item_id = 22,num = 1,is_bind = 0})
		self.cell:SetItemTipFrom(EquipTip.FROM_NORMAL)
	end	
end

function MakeVowView:OnFlush(param_t)
	self.yb_bless_num:SetNumber(BlessingData.Instance:GetCritNumRemind(1))
	self.lv_bless_num:SetNumber(BlessingData.Instance:GetCritNumRemind(2))

	
	self:ConsumeNumFlush()
	self:BtnFlagFlush()
end

-- 消耗获取数值显示
function MakeVowView:ConsumeNumFlush()
	local gold = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD)
	local num_1, num_2 = BlessingData.Instance:GetBlessNum()
	local num_item_1 = BlessingData.Instance:GetBlessCfg(1)
	local num_item_2 = BlessingData.Instance:GetBlessCfg(2)
	num_1 = num_1 >= #num_item_1 and #num_item_1 or num_1+1
	num_2 = num_2 >= #num_item_2 and #num_item_2 or num_2+1

	local color1 = gold >= num_item_1[num_1].consume and COLOR3B.GREEN or COLOR3B.RED
	local color2 = gold >= num_item_2[num_2].consume and COLOR3B.GREEN or COLOR3B.RED

	self.node_t_list.lbl_get_yb.node:setString(num_item_1[num_1].get_num)
	self.node_t_list.lbl_comsume_yb.node:setString(num_item_1[num_1].consume)
	self.node_t_list.lbl_get_yb_1.node:setString("×  " .. num_item_2[num_2].get_num[1].count)
	self.node_t_list.lbl_comsume_yb_1.node:setString(num_item_2[num_2].consume)

	self.node_t_list.lbl_comsume_yb.node:setColor(color1)
	self.node_t_list.lbl_comsume_yb_1.node:setColor(color2)
end

-- 按钮提示刷新
function MakeVowView:BtnFlagFlush()
	local num_1, num_2 = BlessingData.Instance:GetBlessNum()
	local all_num = BlessingData.Instance:GetAllNum()
	local show_remind_times = pray_money_cfg and pray_money_cfg.show_remind_times or {0, 0}

	self.node_t_list.img_blesss_flag_1.node:setVisible(num_1 + 1 <= show_remind_times[1])
	self.node_t_list.img_blesss_flag_2.node:setVisible(num_2 + 1 <= show_remind_times[2])

	self.node_t_list.btn_yb_bless.node:setTitleText(num_1 == 0 and Language.Blessing.BtnTitle[1] or Language.Blessing.BtnTitle[2])
	self.node_t_list.btn_lv_bless.node:setTitleText(num_2 == 0 and Language.Blessing.BtnTitle[1] or Language.Blessing.BtnTitle[2])

	local color1 = all_num-num_1 > 0 and "55ff00" or "ff0000"
	local color2 = all_num-num_2 > 0 and "55ff00" or "ff0000"

	RichTextUtil.ParseRichText(self.node_t_list.rich_remind_time.node, string.format(Language.Blessing.RemindNum, color1, all_num-num_1, all_num), 18, COLOR3B.OLIVE)
	RichTextUtil.ParseRichText(self.node_t_list.rich_remind_time_1.node, string.format(Language.Blessing.RemindNum, color2, all_num-num_2, all_num), 18, COLOR3B.OLIVE)
	XUI.RichTextSetCenter(self.node_t_list.rich_remind_time.node)
	XUI.RichTextSetCenter(self.node_t_list.rich_remind_time_1.node)
end

-- 按钮点击
function MakeVowView:OnClickBless(index)
	local is_have = BlessingData.Instance:IsNumHave(index)
	if is_have then
		BlessingCtrl.Instance:SendBlessData(index+1)
	else
		self.bless_up = self.bless_up or Alert.New()
		self.bless_up:SetShowCheckBox(false)
		self.bless_up:SetLableString(Language.Blessing.NotNumTips)
		self.bless_up:SetOkFunc(function()
			ViewManager.Instance:OpenViewByDef(ViewDef.Vip)
		end)
		self.bless_up:Open()
	end
end

-- 规则说明
function MakeVowView:OnBlessQues()
	DescTip.Instance:SetContent(Language.Blessing.BlessDetail, Language.Blessing.BlessTitle)
end

return MakeVowView