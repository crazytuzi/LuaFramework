require("scripts/game/combineserver/combinesever_doubleexp_page")
require("scripts/game/combineserver/combinesever_explore_page")
require("scripts/game/combineserver/combinesever_limittime_page")
require("scripts/game/combineserver/combinesever_chargeeveryday_page")
require("scripts/game/combineserver/combinesever_shenmishop_page")
require("scripts/game/combineserver/combinesever_lczb_page")
require("scripts/game/combineserver/combinesever_superboss_page")
require("scripts/game/combineserver/combineserver_charge_rank_page")
require("scripts/game/combineserver/combineserver_consume_rank_page")
require("scripts/game/combineserver/combinesever_gift_page")
require("scripts/game/combineserver/combinesever_arena_page")
CombineServerView = CombineServerView or BaseClass(XuiBaseView)

function CombineServerView:__init()
	self:SetModal(true)
	-- self.def_index = TabIndex.combine_activity_double_exp
 	self.texture_path_list[1] = 'res/xui/combineserveractivity.png'
 	self.texture_path_list[2] = 'res/xui/wangchengzhengba.png'
 	self.texture_path_list[3] = 'res/xui/chongzhi.png'
 	self.texture_path_list[4] = 'res/xui/charge.png'
 	self.texture_path_list[5] = 'res/xui/shangcheng.png'
 	self.texture_path_list[6] = 'res/xui/operate_activity.png'
 	self.texture_path_list[7] = 'res/xui/openserviceacitivity.png'
 	self.texture_path_list[8] = 'res/xui/rankinglist.png'
 	self.texture_path_list[9] = 'res/xui/strength_fb.png'
 	self.title_img_path = ResPath.GetCombineServer("txt_title")
    self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"combineserver_ui_cfg", 1, {1,2,3,4,5,6,7,8,9,}},
		{"combineserver_ui_cfg", 2, {TabIndex.combine_activity_limittime_shop,TabIndex.combine_activity_charge_everyDay,TabIndex.combine_activity_mysterious_shop,TabIndex.combine_activity_lc_zb}},
		{"combineserver_ui_cfg", 3, {TabIndex.combine_activity_double_exp}},
		{"combineserver_ui_cfg", 4, {TabIndex.combine_activity_explore}},
		{"combineserver_ui_cfg", 5, {TabIndex.combine_activity_limittime_shop}},
		{"combineserver_ui_cfg", 6, {TabIndex.combine_activity_charge_everyDay}},
		{"combineserver_ui_cfg", 7, {TabIndex.combine_activity_mysterious_shop}},
		{"combineserver_ui_cfg", 8, {TabIndex.combine_activity_lc_zb}},
		{"combineserver_ui_cfg", 9, {TabIndex.combine_activity_super_boss}},
		{"combineserver_ui_cfg", 10, {TabIndex.combine_activity_charge_rank}},
		{"combineserver_ui_cfg", 10, {TabIndex.combine_activity_consume_rank}},
		{"combineserver_ui_cfg", 11, {TabIndex.combine_activity_gift}},
		{"combineserver_ui_cfg", 12, {0}},
		{"combineserver_ui_cfg", 13, {TabIndex.combine_activity_arena}},
		{"common_ui_cfg", 2, {0}},
	}
	--页面表
	self.page_list = {}
	self.page_list[TabIndex.combine_activity_double_exp] = CombineServerDoubleExpPage.New()
	self.page_list[TabIndex.combine_activity_explore] = CombineServerExplorePage.New()
	self.page_list[TabIndex.combine_activity_limittime_shop] = CombineServerLimitTimeShopPage.New()
	self.page_list[TabIndex.combine_activity_charge_everyDay] = CombineServerChargeEveryDayPage.New()
	self.page_list[TabIndex.combine_activity_mysterious_shop] = CombineServerMysteriousShopPage.New()
	self.page_list[TabIndex.combine_activity_lc_zb] = CombineServerLcZbPage.New()
	self.page_list[TabIndex.combine_activity_super_boss] = CombineServerSuperBossPage.New()
	self.page_list[TabIndex.combine_activity_charge_rank] = CombineServerChargeRankPage.New()
	self.page_list[TabIndex.combine_activity_consume_rank] = CombineServerConsumeRankPage.New()
	self.page_list[TabIndex.combine_activity_gift] = CombineServerGiftPage.New()
	self.page_list[TabIndex.combine_activity_arena] = CombineServerArenaPage.New()

	self.remind_temp = {}
	GlobalEventSystem:Bind(OtherEventType.REMIND_CAHANGE, BindTool.Bind(self.RemindChange, self))

	--self.combineserver_rank = CombineServerCharconsRankPage.New()

	self.remain_time = 0
	self.title_img_path = ResPath.GetCombineServer("txt_title")

end


function CombineServerView:__delete()

end

function CombineServerView:ReleaseCallBack()
	--清理页面生成信息
	for k,v in pairs(self.page_list) do
		v:DeleteMe()
	end
	if self.tabbar ~= nil then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end 
	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
		
end

function CombineServerView:LoadCallBack(index, loaded_times)	
	if loaded_times <= 1 then
		self:CreateTabbar()
		self:SetVisibleTabbar()
		
	end
	if self.page_list[index] then
		self.page_list[index]:InitPage(self)
	end
	if loaded_times <= 1 then
		self:BoolVisibleBTn(index)
	end
end

function CombineServerView:CreateTabbar()
	if nil == self.tabbar then
		self.tabbar = ScrollTabbar.New()
		self.tabbar.space_interval_V = 10
		self.tabbar:SetSpaceInterval(2)
		self.tabbar:CreateWithNameList(self.node_t_list.scroll_tabbar.node, 20, -15,
			BindTool.Bind1(self.SelectTabCallback, self), Language.CombineServerActivity.TabGroup_Name, 
			true, ResPath.GetCommon("btn_106"))
		self.tabbar:ChangeToIndex(self:GetShowIndex())
	end
end

function CombineServerView:SelectTabCallback(index)
	self:ChangeToIndex(index)
end

function CombineServerView:ShowIndexCallBack(index)
	self.tabbar:SelectIndex(index)
	if index == TabIndex.combine_activity_mysterious_shop then
		CombineServerCtrl.Instance:ExtractItemData(1)
	else
		self:Flush(index)
	end
end

function CombineServerView:OpenCallBack()
	CombineServerCtrl.Instance:ReqCombinserGiftInfo()
	CombineServerCtrl.Instance:ReqCombineServerActivityData()
	CombineServerCtrl.Instance:ChargeConsumeRankReq(1)
	CombineServerCtrl.Instance:ChargeConsumeRankReq(2)
	CombineServerCtrl.Instance:ReqGetArenaInfo()
	MagicCityCtrl.Instance:ReqRankinglistData(4)
	MagicCityCtrl.Instance:ReqRankinglistData(5)

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.FlushTimeChange, self, -1),  1)
	
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function CombineServerView:CloseCallBack(is_all)
	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

--刷新相应界面
function CombineServerView:OnFlush(flush_param_t, index)
	for k,v in pairs(flush_param_t) do
		if k == "all" then
			if nil ~= self.page_list[index] then
				--更新页面接口
				self.page_list[index]:UpdateData(flush_param_t)
				if index == TabIndex.combine_activity_super_boss then
					local boss_type = CombineServerData.GetBossActivityType() or 1
					RichTextUtil.ParseRichText(self.node_t_list.txt_desc.node, Language.CombineServerActivity.ActivityDesc[TabIndex.combine_activity_super_boss][boss_type] or "", 22, COLOR3B.OLIVE)
					XUI.SetRichTextVerticalSpace(self.node_t_list.txt_desc.node, 5)
				else
					if index ~= TabIndex.combine_activity_gift or index ~= TabIndex.combine_activity_arena then -- 特惠礼包 和 合服擂台不显示时间
						if Language.CombineServerActivity.ActivityDesc[index] then
							RichTextUtil.ParseRichText(self.node_t_list.txt_desc.node, Language.CombineServerActivity.ActivityDesc[index], 22, COLOR3B.OLIVE)
							XUI.SetRichTextVerticalSpace(self.node_t_list.txt_desc.node, 5)
						end
					end
				end
			end
			-- local effect = self.tabbar:SetEffectByIndex(TabIndex.combine_activity_arena,10)
			-- effect:setScaleX(0.9)
			self:FlushTabbar()
			CombineServerData.Instance:SetLoadTime(index)
			self.remain_time = CombineServerData.Instance:GetTime()
			self:FlushTimeChange()
			local _, start_time, end_time = CombineServerData.Instance:GetCombineRemindTime(index)
			local txt = os.date("%Y/%m/%d", start_time) .. (end_time == 0 and "" or " - " .. os.date("%Y/%m/%d", end_time))
			local txt_1 = string.format(Language.CombineServerActivity.activity_time, txt)
			if index == TabIndex.combine_activity_gift or index == TabIndex.combine_activity_arena then -- 特惠礼包 和 合服擂台不显示时间
				break
			end
			if self.node_t_list.activity_time then
				RichTextUtil.ParseRichText(self.node_t_list.activity_time.node, txt_1, 22, COLOR3B.OLIVE)	
			end
		elseif k == "remind_change" then
			self:FlushTabbar()
		elseif k == "gift_change" then
			self:BoolVisibleBTn()
		end
	end
end

function CombineServerView:SetVisibleTabbar()
	for k,v in pairs(Language.CombineServerActivity.TabGroup_Name) do
		local _, start_time, end_time = CombineServerData.Instance:GetCombineRemindTime(k)
		if start_time ~= 0 then
			self.tabbar:SetToggleVisible(k, true)
		else
			self.tabbar:SetToggleVisible(k, false)
		end
	end
	local index = 1
	for k,v in pairs(Language.CombineServerActivity.TabGroup_Name) do
		local _, start_time, end_time = CombineServerData.Instance:GetCombineRemindTime(k)
		local _, start_next_time, end_next_time = CombineServerData.Instance:GetCombineRemindTime(k + 1)
		if start_time ~= 0 then
			index = k
			break 
		elseif start_time == 0 and start_next_time ~= 0 then
			index = k + 1
			break 
		end
	end
	self.def_index = index
	self:ChangeToIndex(self.def_index)
	self.tabbar:SelectIndex(self.def_index)
end


function CombineServerView:RemindChange(remind_name, num)
	if remind_name == RemindName.ComBineServerCharge then
		self.remind_temp[TabIndex.combine_activity_charge_everyDay] = num
		self:Flush(0, "remind_change")
	end
end

function CombineServerView:FlushTabbar()
	for k,v in pairs(self.remind_temp) do
		self.tabbar:SetRemindByIndex(k, v > 0)
	end
end

function CombineServerView:FlushTimeChange()
	if self.remain_time < 0 then
		if self.node_t_list.txt_remian_time then
			RichTextUtil.ParseRichText(self.node_t_list.txt_remian_time.node, "", 22, COLOR3B.OLIVE)
		end
		return
	end
	if self:GetShowIndex() == TabIndex.combine_activity_super_boss then
		local txt = ""
		if CombineServerData.Instance:GetBossRreshTime() and CombineServerData.Instance:GetBossRreshTime()  == 1  then
			txt = Language.CombineServerActivity.Boss_State
		elseif  CombineServerData.Instance:GetBossRreshTime() and CombineServerData.Instance:GetBossRreshTime() == 3 then
			txt = Language.CombineServerActivity.Boss_killed
		elseif CombineServerData.Instance:GetBossRreshTime() and CombineServerData.Instance:GetBossRreshTime()  == 2 then
			local time_s = TimeUtil.FormatSecond2Str(self.remain_time - TimeCtrl.Instance:GetServerTime())
			txt = string.format(Language.CombineServerActivity.Remian_time, time_s)
		end	
		RichTextUtil.ParseRichText(self.node_t_list.txt_remian_time.node, txt, 22, COLOR3B.OLIVE)
	else
		if self:GetShowIndex() == TabIndex.combine_activity_gift or self:GetShowIndex() == TabIndex.combine_activity_arena then -- 特惠礼包 和 合服擂台不显示时间
			return 
		end
		local time_s = TimeUtil.FormatSecond2Str(self.remain_time - TimeCtrl.Instance:GetServerTime())
		local txt = string.format(Language.CombineServerActivity.Remian_time, time_s)
		if self.node_t_list.txt_remian_time then
			RichTextUtil.ParseRichText(self.node_t_list.txt_remian_time.node, txt, 22, COLOR3B.OLIVE)
		end	
	end
end

function CombineServerView:BoolVisibleBTn(index)
	if CombineServerData.Instance:IsShowGiftTab() == false then
		self.tabbar:SetToggleVisible(TabIndex.combine_activity_gift, CombineServerData.Instance:IsShowGiftTab())
		self:ChangeToIndex(self.def_index)
		self.tabbar:SelectIndex(self.def_index)
	else
		if index == TabIndex.combine_activity_gift then
			self:ChangeToIndex(TabIndex.combine_activity_gift)
			self.tabbar:SelectIndex(TabIndex.combine_activity_gift)
			self.def_index = TabIndex.combine_activity_gift
		elseif index == TabIndex.combine_activity_arena then
			self:ChangeToIndex(TabIndex.combine_activity_arena)
			self.tabbar:SelectIndex(TabIndex.combine_activity_arena)
			self.def_index = TabIndex.combine_activity_arena
		end
	end
end
