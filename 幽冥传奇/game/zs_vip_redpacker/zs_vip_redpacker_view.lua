ZsVipRedpackerView = ZsVipRedpackerView or BaseClass(BaseView)

function ZsVipRedpackerView:__init()
	self:SetModal(true)
	self:SetBackRenderTexture(true)
	
	self.texture_path_list = {
		'res/xui/zs_vip_redpacker.png'
	}
	self.config_tab = {
		{"zs_vip_redpacker_ui_cfg", 1, {0}},
		{"zs_vip_redpacker_ui_cfg", 2, {0}},
	}
	
	-- require("scripts/game/zs_vip_redpacker/name").New(ViewDef.ZsVipRedpacker.name)

	-- 管理自定义对象
	self._objs = {}
end

function ZsVipRedpackerView:ReleaseCallBack()
	-- 清理自定对象
	for k, v in pairs(self._objs) do
		if nil == v.DeleteMe then ErrorLog("不可清理的对象 ReleaseCallBack CrossBossRewardView") end
		v:DeleteMe()
	end
	self._objs = {}
end

function ZsVipRedpackerView:LoadCallBack(index, loaded_times)
	 ZsVipRedpackerCtrl.SendZsVipRedpackerReq()
	self.data = ZsVipRedpackerData.Instance				--数据
	EventProxy.New(ZsVipRedpackerData.Instance, self):AddEventListener(ZsVipRedpackerData.INFO_CHANGE, BindTool.Bind(self.OnDataChange, self))
	XUI.AddClickEventListener(self.node_t_list["btn_charge"].node, function()
		ViewManager.Instance:OpenViewByDef(ViewDef.ZsVip.Privilege)
	end, true)

	--奖励列表
	local ph = self.ph_list.ph_award_list
	self._objs.awards1 = ListView.New()
	self._objs.awards1:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, RedPackerBaseCell, nil, nil, self.ph_list.ph_award_cell)
	self.node_t_list.layout_zhanjiang.node:addChild(self._objs.awards1:GetView(), 10)

	local ph = self.ph_list.ph_tq_award_list
	self._objs.awards2 = ListView.New()
	self._objs.awards2:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, RedPackerBaseCell, nil, nil, self.ph_list.ph_award_cell)
	self.node_t_list.layout_zhanjiang.node:addChild(self._objs.awards2:GetView(), 10)
end

function ZsVipRedpackerView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ZsVipRedpackerView:ShowIndexCallBack()
	self:FlushView()
end

function ZsVipRedpackerView:OnDataChange(vo)
	self:FlushView()
end

function ZsVipRedpackerView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

Language.ZsVipRedpacker = {
	desc = string.format(
		[[
获取方式：{wordcolor;1eff00;每日爆%s次}
触发机制：{wordcolor;1eff00;%s级以上}BOSS有几率触发并获得{wordcolor;ff2828;红包}
]],
		BillionRedPacketCfg.generalMaxTms, 
		BillionRedPacketCfg.bossLv
	),

	tq_desc = string.format(
		[[
获取方式：{wordcolor;1eff00;开通贵族+%s次、王者+%s次、至尊+%s次}
触发机制：{wordcolor;1eff00;%s级以上}BOSS有几率触发并获得{wordcolor;ff2828;大红包}
]],
		BillionRedPacketCfg.PrivilegeAddTms[1], 
		BillionRedPacketCfg.PrivilegeAddTms[2], 
		BillionRedPacketCfg.PrivilegeAddTms[3], 
		BillionRedPacketCfg.bossLv
	),
}

local tq_all_num = BillionRedPacketCfg.PrivilegeAddTms[1] + BillionRedPacketCfg.PrivilegeAddTms[2] + BillionRedPacketCfg.PrivilegeAddTms[3]
function ZsVipRedpackerView:FlushView()
	self.node_t_list.spare_times.node:setString(BillionRedPacketCfg.generalMaxTms - self.data.done_num)
	self.node_t_list.tq_spare_times.node:setString(self.data.tq_add_num - self.data.tq_done_num)
	RichTextUtil.ParseRichText(self.node_t_list.tq_desc.node, Language.ZsVipRedpacker.tq_desc, 20)
	RichTextUtil.ParseRichText(self.node_t_list.desc.node, Language.ZsVipRedpacker.desc, 20)


	-- 奖励
	local data = {}
	for i = 1, BillionRedPacketCfg.generalMaxTms do
		data[i] = {is_show_icon = i <= self.data.done_num, award = BillionRedPacketCfg.redpackawards[1].awards[1]}
	end
	self._objs.awards1:SetDataList(data)

	local data2 = {}
	for i = 1, tq_all_num do
		data2[i] = {is_show_icon = i <= self.data.tq_done_num, award = BillionRedPacketCfg.redpackawards[2].awards[1]}
	end
	self._objs.awards2:SetDataList(data2)
end

RedPackerBaseCell = RedPackerBaseCell or BaseClass(BaseRender)

function RedPackerBaseCell:CreateChildCallBack()
	self:AddClickEventListener(function ()
		if self.data.is_show_icon then
			TipCtrl.Instance:OpenItem({item_id = self.data.award.id})
		end
	end, false)
end

function RedPackerBaseCell:OnFlush()
	BaseRender.OnFlush(self)
	self.node_tree.img_quesion.node:setVisible(not self.data.is_show_icon)
	self.node_tree.img_icon.node:setVisible(self.data.is_show_icon)
	self.node_tree.img_icon.node:loadTexture(ResPath.GetItem(ItemData.Instance:GetItemConfig(self.data.award.id).icon))
end

function RedPackerBaseCell:CreateSelectEffect()
end
