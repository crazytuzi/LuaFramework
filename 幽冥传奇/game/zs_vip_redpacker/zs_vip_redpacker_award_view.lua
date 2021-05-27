ZsVipRedpackerAwardView = ZsVipRedpackerAwardView or BaseClass(BaseView)

function ZsVipRedpackerAwardView:__init()
	self:SetModal(true)

	self.is_any_click_close = true										-- 是否点击其它地方要关闭界面
	
	self.texture_path_list = {
		'res/xui/zs_vip_redpacker.png'
	}
	self.config_tab = {
		{"zs_vip_redpacker_ui_cfg", 3, {0}},
	}
	
	-- require("scripts/game/zs_vip_redpacker/name").New(ViewDef.ZsVipRedpacker.name)

	-- 管理自定义对象
	self._objs = {}
end

function ZsVipRedpackerAwardView:ReleaseCallBack()
	-- 清理自定对象
	for k, v in pairs(self._objs) do
		if nil == v.DeleteMe then ErrorLog("不可清理的对象 ReleaseCallBack CrossBossRewardView") end
		v:DeleteMe()
	end
	self._objs = {}

	self.data = nil
end

function ZsVipRedpackerAwardView:LoadCallBack(index, loaded_times)
	local ph_cell = self.ph_list.ph_cell_item
	self._objs.cell = BaseCell.New()
	self._objs.cell:GetView():setAnchorPoint(0.5, 0.5)
	self._objs.cell:SetPosition(ph_cell.x, ph_cell.y)
	self.node_t_list["layout_award"].node:addChild(self._objs.cell:GetView(), 999)
end

function ZsVipRedpackerAwardView:SetData(data)
	self.data = data
end

function ZsVipRedpackerAwardView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ZsVipRedpackerAwardView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	self.data = nil
end

function ZsVipRedpackerAwardView:ShowIndexCallBack()
	self:FlushView()
end

function ZsVipRedpackerAwardView:FlushView()
	local cfg = BillionRedPacketCfg.redpackawards[self.data].awards[1]
	self._objs.cell:SetData({item_id = cfg.id, num = cfg.count})
	self._objs.cell:SetBindIconVisible(false)
end
