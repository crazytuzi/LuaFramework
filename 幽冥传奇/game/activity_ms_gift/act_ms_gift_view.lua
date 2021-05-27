
ActMsGiftView = ActMsGiftView or BaseClass(XuiBaseView)

function ActMsGiftView:__init()

	if	ActMsGiftView.Instance then
		ErrorLog("[ActMsGiftView]:Attempt to create singleton twice!")
	end
	self:SetIsAnyClickClose(true)
	self.is_modal = true
	self.background_opacity = 170	
	self.def_index = 1

	self.texture_path_list[1] = 'res/xui/activity_brilliant.png'
	self.config_tab = {
	 	{"common_ui_cfg", 1, {0}},
		{"act_ms_gift_ui_cfg", 1, {0}},
		{"act_ms_gift_ui_cfg", 2, {0}},
		{"common_ui_cfg", 2, {0}},
	}
end

function ActMsGiftView:__delete()
end

function ActMsGiftView:ReleaseCallBack()
	if self.gold_cap ~= nil then
		self.gold_cap:DeleteMe()
		self.gold_cap = nil
	end

	if nil ~= self.cell_charge_list then
    	for k,v in pairs(self.cell_charge_list) do
    		v:DeleteMe()
  		end
    	self.cell_charge_list = nil
    end

    if self.spare_time ~= nil then
		GlobalTimerQuest:CancelQuest(self.spare_time)
		self.spare_time = nil
	end
end


function ActMsGiftView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateItemList()
		self:CreateGoldNum()
		self:CreateSpareTimer()
		self.node_t_list.btn_buy.node:addClickEventListener(BindTool.Bind(self.OnClickBuyHandler, self))
	end
end

function ActMsGiftView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	self.current_index = 1
end

function ActMsGiftView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ActMsGiftView:OnFlush(param_list, index)
	self:FlushItemList()
end
function ActMsGiftView:UpdateSpareTime()
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.MSGIFT)
	if nil == cfg then return end
	local now_time =TimeCtrl.Instance:GetServerTime()
	local end_time = cfg.end_time 
	local spare_time = end_time - now_time 
	self.node_t_list.layout_act_ms_gift.lbl_turntable_time.node:setString(TimeUtil.FormatSecond2Str(spare_time))
end

function ActMsGiftView:CreateSpareTimer()
	self.spare_time = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.UpdateSpareTime, self), 1)
end

function ActMsGiftView:CreateItemList()
	self.cell_charge_list = {}
	for i=1,5 do 
		local cell = BaseCell.New()
		local ph = self.ph_list["ph_56_cell_"..i]
		cell:SetPosition(ph.x, ph.y)
		cell:SetIndex(i)
		cell:SetAnchorPoint(0.5, 0.5)
		self.node_t_list.layout_act_ms_gift.node:addChild(cell:GetView(), 300)
		table.insert(self.cell_charge_list, cell)
	end
	self:FlushItemList()
end

function ActMsGiftView:FlushItemList()
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.MSGIFT)
	if nil == cfg then return end

	local pro = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	local level = ActivityBrilliantData.Instance:GetMSGIFTLevel() --档次
 	if level == 0 then 
 		self:Close()
 		ViewManager.Instance:FlushView(ViewDef.MainUi, 0, "icon_pos")
 		self.node_t_list.btn_buy.node:setEnabled(false)
 		level = 4
 	end

	self.node_t_list.layout_act_ms_gift.lbl_gold_num.node:setString(cfg.config.GiftLevels[level].money.count)
	local data = cfg.config.GiftLevels[level].award[pro]
	for k,v in pairs(self.cell_charge_list) do
		local item_data = {}
		if nil ~= data[k] then
			item_data.item_id = data[k].id
			item_data.num = data[k].count
			item_data.is_bind = data[k].bind
			item_data.effectId = data[k].effectId
			v:SetData(item_data)
		else
			v:SetData(nil)
		end
		v:SetVisible(data[k] ~= nil)
	end
end

function ActMsGiftView:CreateSpareTimer()
	self.spare_time = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.UpdateSpareTime, self), 1)
end

function ActMsGiftView:CreateGoldNum()
	local cap_x, cap_y = self.node_t_list.lbl_gold_num.node:getPosition()
	self.gold_cap = NumberBar.New()
	self.gold_cap:SetRootPath(ResPath.GetScene("zdl_y_"))
	self.gold_cap:SetPosition(cap_x + 20, cap_y + 10)
	self.gold_cap:SetSpace(-2)
	self.node_t_list.layout_act_ms_gift.node:addChild(self.gold_cap:GetView(), 300, 300)
end

function ActMsGiftView:CreateTurntableReward()
	self.table_reward_t = {}
end

function ActMsGiftView:OnClickBuyHandler()
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.MSGIFT)
	if nil == cfg then return end
	local act_id = ACT_ID.MSGIFT
 	-- local cmd_id = ActivityBrilliantData.Instance:GetCmdIdByActId(act_id)
 	local level = ActivityBrilliantData.Instance:GetMSGIFTLevel()
	ActivityBrilliantCtrl.Instance.ActivityReq(4, act_id, level)
end