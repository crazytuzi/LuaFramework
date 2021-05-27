------------------------------------------------------------
-- 经验副本view
------------------------------------------------------------
local DungeonJingyanView = BaseClass(SubView)

function DungeonJingyanView:__init()
	self.texture_path_list = {
		'res/xui/fuben_cl.png',
		'res/xui/fuben.png',
		'res/xui/level_and_deify.png',
	}
	self.config_tab = {
		{"fuben_cl_and_jy_ui_cfg", 4, {0}},
	}
	self.sy_times = 0
end
function DungeonJingyanView:__delete()
	self.remind_turntable = nil
end

function DungeonJingyanView:ReleaseCallBack()

end

function DungeonJingyanView:LoadCallBack()
	local text = ""
	for k, v in pairs(Language.JiYanFubenShow.LanaguageDesc) do
		text = text .. string.format(v, ResPath.LeveAndDeify("img_point")).."\n"
	end
	RichTextUtil.ParseRichText(self.node_t_list.rich_text.node, text, 18, Str2C3b("9c9181"))
	XUI.SetRichTextVerticalSpace(self.node_t_list.rich_text.node,5)
	self:CreateGuankaList()
	XUI.AddClickEventListener(self.node_t_list.btn_sweeep.node, BindTool.Bind(self.OnBtnSweep, self))
	XUI.AddClickEventListener(self.node_t_list.btn_fight.node, BindTool.Bind(self.OnEnnterFight, self))
	EventProxy.New(FubenData.Instance, self):AddEventListener(FubenData.JY_FUBEN_DATA, BindTool.Bind(self.FlushShow, self))

	local ph_duihuan = self.ph_list["ph_link"]
	local text = RichTextUtil.CreateLinkText("VIP特权", 19, COLOR3B.GREEN)
	text:setPosition(ph_duihuan.x + 20, ph_duihuan.y + 5)
	self.node_t_list.layout_new_jiyan_fuben.node:addChild(text, 90)
	XUI.AddClickEventListener(text, function()
		ViewManager.Instance:OpenViewByDef(ViewDef.Vip)
	end, true)
	self.guaka_level = 1
end

function DungeonJingyanView:ShowIndexCallBack()
	self:OnFlush()
end

function DungeonJingyanView:CloseCallBack()
end

function DungeonJingyanView:OpenCallBack()
	if FubenData.Instance:GetCurFightLevel() > 0 then --奖励未领取，打开领取奖励
		ViewManager.Instance:OpenViewByDef(ViewDef.ShowRewardExp)
	end
end

function DungeonJingyanView:ShowIndexCallBack(index)
	self:Flush(index)
end

function DungeonJingyanView:OnFlush()
	self:FlushData()
	self:FlushShow()

	local index = 1
	local data = DungeonData.Instance:GetListInfo()
	for k, v in pairs(data) do
		if DungeonData.Instance:GetIsOpen(v.conditions, v.level) then
			index = v.level
		end
	end
	self.guaka_list:SelectIndex(index)

	local cur_max_level = FubenData.Instance:GetCurMaxLevel()
	if FubenData.Instance:GetHadMaxBo() < 15 then
		-- 未达到S级时,只能扫荡上一关
		cur_max_level = cur_max_level - 1
	end

	self.node_t_list.btn_sweeep.node:setEnabled(cur_max_level > 0)
end

----------视图函数----------

function DungeonJingyanView:CreateGuankaList()
	local ph = self.ph_list.ph_list
	if self.guaka_list == nil then
		self.guaka_list = ListView.New()
		self.guaka_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, self.GuaKaItem, nil, nil, self.ph_list.ph_list_item)
		self.guaka_list:SetItemsInterval(0)--格子间距
		self.guaka_list:SetMargin(0)
		self.guaka_list:SetJumpDirection(ListView.Top)--置顶
		self.node_t_list.layout_new_jiyan_fuben.node:addChild(self.guaka_list:GetView(), 20)
		self.guaka_list:SetSelectCallBack(BindTool.Bind(self.SelectEquipListCallback, self))
		self.guaka_list:GetView():setAnchorPoint(0, 0)
		self:AddObj("guaka_list")
	end
end

function DungeonJingyanView:FlushData()
	local data = DungeonData.Instance:GetListInfo()
	self.guaka_list:SetData(data)
end

function DungeonJingyanView:FlushShow()
	local level = self.guaka_level 
	local condion = DungeonData.Instance:GetCurConditionByLevel(level)
	local is_open = DungeonData.Instance:GetSaoDangIsOpen(level)
	local pos_x = 840
	local consume = expFubenConfig.sweepConsume[1]
	local consume_id = consume.id
	local need_count = consume.count
	local item_cfg = ItemData.Instance:GetItemConfig(consume_id)
	local path = ResPath.GetItem(item_cfg.icon)
	local had_num = BagData.Instance:GetItemNumInBagById(consume_id)
	
	local is_show_tips = 1
	local scale = 0.5

	local color = had_num < need_count and "ff0000" or "00ff00"
	local text1 = string.format(Language.Bag.ComposeTip1, path,"20,20", scale, consume_id, is_show_tips, color, had_num, need_count)
	local text = "消耗："..text1

	RichTextUtil.ParseRichText(self.node_t_list.rich_text_consume.node, text)
	XUI.RichTextSetCenter(self.node_t_list.rich_text_consume.node)
	local zs_lv =  RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_VIP_GRADE)
	local i_num = VipConfig.VipGrade[zs_lv] and  VipConfig.VipGrade[zs_lv].expFbAddCount or 0
	
	local buy_time = FubenData.Instance:JyFubenBuyTime()
	local totol_times = expFubenConfig.dayEnCount  + i_num + buy_time
	local had_times = FubenData.Instance:GetHadFightingNum()
	local sy_times = totol_times - had_times < 0 and 0 or  totol_times - had_times
	self.sy_times = sy_times

	local text1 = string.format("剩余次数：%d/%d", sy_times, totol_times)
	RichTextUtil.ParseRichText(self.node_t_list.text_remain_time.node, text1)
	XUI.RichTextSetCenter(self.node_t_list.text_remain_time.node)
	self.node_t_list.btn_fight.node:setPositionX(pos_x)

	local btn_txt = sy_times == 0 and "购买次数" or "开始挑战"
	self.node_t_list.btn_fight.node:setTitleText(btn_txt)
end

----------视图函数end----------

function DungeonJingyanView:SelectEquipListCallback(cell)
	if cell == nil or cell:GetData() == nil then
		return
	end
	local data = cell:GetData()
	local bool  = false 
	if DungeonData.Instance:GetIsOpen(data.conditions, data.level) then
		self.guaka_level = cell:GetData().level
		self:FlushShow()
		bool = true
	else
		SysMsgCtrl.Instance:FloatingTopRightText(Language.JiYanFubenShow.SelectTip)
	end
	cell:SetSelect(bool)

	local item = self.guaka_list:GetItemAt(self.guaka_level)
	if item then
		if not bool then
			item:SetSelect(true)
		end
	end
end

--扫荡经验副本
function DungeonJingyanView:OnBtnSweep()
	if FubenData.Instance:GetCurFightLevel() > 0 then
		ViewManager.Instance:OpenViewByDef(ViewDef.ShowRewardExp)
	else
		local cur_max_level = FubenData.Instance:GetCurMaxLevel()
		if FubenData.Instance:GetHadMaxBo() < 15 then
			-- 未达到S级时,只能扫荡上一关
			cur_max_level = cur_max_level - 1
		end

		if cur_max_level > 0 then
			if nil == self.alert then
				self.alert = Alert.New()
				self:AddObj("alert")
			end
			
			self.alert:SetLableString(string.format(Language.JiYanFubenShow.SweepTips, cur_max_level))
			self.alert:SetOkFunc(function()
				FubenCtrl.Instance:SendSweepJIYanFuben(cur_max_level)
			end)
			self.alert:SetShowCheckBox(false)
			self.alert:Open()
		end
	end
end

function DungeonJingyanView:OnEnnterFight()
	if self.sy_times == 0 then
		if nil == self.alert then
			self.alert = Alert.New()
			self:AddObj("alert")
		end

		self.alert:SetLableString(string.format(Language.DailyTasks.BuyTimeTxt, expFubenConfig.buyTmsCost[1].count))
		self.alert:SetOkFunc(function()
			DungeonCtrl.SendBuyExpFubenTimeReq()
		end)
		self.alert:SetShowCheckBox(false)
		self.alert:Open()
	else
		if FubenData.Instance:GetCurFightLevel() > 0 then
			ViewManager.Instance:OpenViewByDef(ViewDef.ShowRewardExp)
		else
			FubenCtrl.Instance:SendEnterJiYanFuben(self.guaka_level)
		end	
	end
end

----------------------------------------

DungeonJingyanView.GuaKaItem = BaseClass(BaseRender)
local GuaKaItem = DungeonJingyanView.GuaKaItem

function GuaKaItem:__init()
	-- body
end

function GuaKaItem:__delete()
	if self.cell then
		self.cell:DeleteMe()
		self.cell = nil 
	end
end

function GuaKaItem:CreateChild()
	BaseRender.CreateChild(self)
	local ph = self.ph_list.ph_cell_2
	if self.cell == nil then
		self.cell = BaseCell.New()
		self.cell:GetView():setPosition(ph.x + 10, ph.y + 5)
		self.view:addChild(self.cell:GetView(), 99)
		self.cell:GetView():setScale(0.8)
	end
end


function GuaKaItem:OnFlush()
	if self.data == nil then
		return
	end
	self.cell:SetData({item_id = self.data.showAwards[1].id, num = self.data.showAwards[1].count, is_bind = 0})
	self.node_tree.text_level.node:setString("难度：" .. self.data.level)

	local text = self.data.conditions.level .. "级"
	if self.data.conditions.circle > 0 then
		text = self.data.conditions.circle .. "转"
	end
	self.node_tree.text_condition.node:setString(text)

	self.node_tree.img_bg1.node:setVisible((self.index % 2 == 0))

	local is_open = DungeonData.Instance:GetIsOpen( self.data.conditions, self.data.level)
	self:SetGrey(not is_open)
end


function GuaKaItem:SetGrey(boolean)
	if self.cell then
		self.cell:MakeGray(boolean)
	end
	local color = boolean and COLOR3B.GRAY or COLOR3B.GREEN
	self.node_tree.text_condition.node:setColor(color)
	self.node_tree.text_level.node:setColor(color)
end

return DungeonJingyanView