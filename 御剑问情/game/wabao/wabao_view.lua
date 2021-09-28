WaBaoView = WaBaoView or BaseClass(BaseView)

function WaBaoView:__init()
	self.ui_config = {"uis/views/wabao_prefab","WaBaoView"}
	self.full_screen = false
	self.play_audio = true
end

function WaBaoView:LoadCallBack()
	self:ListenEvent("OnCloseClick",BindTool.Bind(self.OnCloseClick, self))
	self:ListenEvent("XunBaoClick",BindTool.Bind(self.XunBaoClick, self))
	self:ListenEvent("OnQuickClick",BindTool.Bind(self.OnQuickClick, self))
	self:ListenEvent("OnTipClick",BindTool.Bind(self.OnTipClick, self))
	self:ListenEvent("OnGoClick",BindTool.Bind(self.OnGoClick, self))

	self.item_cell_list = {}
	for i=1,3 do
		self.item_cell_list[i] = ItemCell.New()
		self.item_cell_list[i]:SetInstanceParent(self:FindObj("item"..i))
	end
	self.raw_img = self:FindVariable("raw_img")
	self.map_pic = self:FindVariable("map_pic")
	self.map_text = self:FindVariable("map_text")
	self.remain_text = self:FindVariable("remain_text")
	self.slider_value = self:FindVariable("SliderValue")
	self.now_active_text = self:FindVariable("now_active_text")
	self.next_active_text = self:FindVariable("next_active_text")
	self.prog_active_text = self:FindVariable("prog_active_text")
	local cfg = WaBaoData.Instance:GetShowItems()
	for i=1,3 do
		self.item_cell_list[i]:SetData(cfg[i])
	end
end

function WaBaoView:ReleaseCallBack()
	for i=1,3 do
		self.item_cell_list[i]:DeleteMe()
		self.item_cell_list[i] = nil
	end
	self.item_cell_list = {}

	self.raw_img = nil
	self.map_pic = nil
	self.map_text = nil
	self.remain_text = nil
	self.daoju_display = nil
	self.slider_value = nil
	self.now_active_text = nil
	self.next_active_text = nil
	self.prog_active_text = nil
end

function WaBaoView:OpenCallBack()
	local pos_cfg = WaBaoData.Instance:GetWaBaoInfo()
	if pos_cfg and next(pos_cfg) and pos_cfg.baotu_count ~= 0 and pos_cfg.baozang_scene_id == 0 then
		WaBaoCtrl.SendWabaoOperaReq(WA_BAO_OPERA_TYPE.OPERA_TYPE_START, 0)
	end
	self:Flush()
end

function WaBaoView:OnCloseClick()
	self:Close()
end

function WaBaoView:CloseCallBack()

end

function WaBaoView:OnFlush()
	-- if pos_cfg.baotu_count ~= 0 and pos_cfg.baozang_scene_id == 0 then
	-- 	WaBaoCtrl.SendWabaoOperaReq(WA_BAO_OPERA_TYPE.OPERA_TYPE_START, 0)
	-- end
	local pos_cfg = WaBaoData.Instance:GetWaBaoInfo()
	if pos_cfg and next(pos_cfg) and pos_cfg.baozang_scene_id and pos_cfg.baozang_scene_id ~= 0 then
		local bundle, asset = ResPath.GetWaBaoPic(pos_cfg.baozang_scene_id)
		self.map_pic:SetAsset(bundle, asset)
		local scene_cfg = ConfigManager.Instance:GetSceneConfig(pos_cfg.baozang_scene_id)
		self.map_text:SetValue(scene_cfg.name)
	end
	self.remain_text:SetValue(pos_cfg.baotu_count)
	local now_total_degree = WaBaoData.Instance:GetActiveDegree()
	local max_total_degree = WaBaoData.Instance:GetMaxActiveDegree()
	self.now_active_text:SetValue(string.format(Language.WaBao.NowTotalDegree, now_total_degree, max_total_degree))
	self.prog_active_text:SetValue(string.format(now_total_degree, max_total_degree))
	self.slider_value:SetValue(now_total_degree / max_total_degree)
end

function WaBaoView:XunBaoClick()
	local wabao_data = WaBaoData.Instance
	local info = wabao_data:GetWaBaoInfo()
	if info.baozang_scene_id == 0 then
		if info.baotu_count > 0 then
			wabao_data:SetWaBaoFlag(true)
			WaBaoCtrl.SendWabaoOperaReq(WA_BAO_OPERA_TYPE.OPERA_TYPE_START, 0)
			self:Close()
		else
			TipsCtrl.Instance:ShowSystemMsg(Language.Common.WaBaoLimit)
		end
	elseif
		info.baozang_scene_id and info.wabao_reward_type == 0 then
		MoveCache.cant_fly = true
		GuajiCtrl.Instance:MoveToPos(info.baozang_scene_id, info.baozang_pos_x, info.baozang_pos_y, 0, 0)
		self:Close()
	end
end

function WaBaoView:OnQuickClick()
	local info = WaBaoData.Instance:GetWaBaoInfo()
	local pos_cfg = WaBaoData.Instance:GetWaBaoInfo()
	local cfg = WaBaoData.Instance:GetOtherCfg()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local my_money = vo.gold + vo.bind_gold
	local  total_const = pos_cfg.baotu_count * cfg.quick_complete_cost
	local describe = string.format(Language.Daily.WaBaoRenWu, ToColorStr(total_const, TEXT_COLOR.BLUE_4))
	local call_back = function ()
		if my_money >= total_const then
			GuajiCtrl.Instance:StopGuaji()
			WaBaoCtrl.SendWabaoOperaReq(WA_BAO_OPERA_TYPE.OPERA_TYPE_QUICK_COMPLETE, 0)
			WaBaoData.Instance:SetFastWaBaoFlag(true)
		else
			TipsCtrl.Instance:ShowLackDiamondView()
		end
	end
	TipsCtrl.Instance:ShowCommonAutoView("advance_index", describe, call_back, nil, nil)
	self:Flush()
	-- WaBaoCtrl.SendWabaoOperaReq(WA_BAO_OPERA_TYPE.OPERA_TYPE_GET_INFO, 0)
end

function WaBaoView:OnTipClick()
	TipsCtrl.Instance:ShowHelpTipView(170)
end

function WaBaoView:OnGoClick()
	self:Close()
	ViewManager.Instance:Open(ViewName.BaoJu,TabIndex.baoju_zhibao_active)
end