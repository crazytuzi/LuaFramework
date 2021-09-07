ReviveView = ReviveView or BaseClass(BaseView)

local ViewNameList = {
	ViewName.Forge, ViewName.Advance, ViewName.SpiritView, ViewName.Goddess, ViewName.BaoJu
}

function ReviveView:__init()
	self.ui_config = {"uis/views/reviveview", "ReviveView"}
	self.play_audio = true
	self.time_record = 0             --记录计时器时间；
end

function ReviveView:__delete()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	if self.buff_time_quest then
		GlobalTimerQuest:CancelQuest(self.buff_time_quest)
		self.buff_time_quest = nil
	end
	if self.buff_cd_time_quest then
		GlobalTimerQuest:CancelQuest(self.buff_cd_time_quest)
		self.buff_cd_time_quest = nil
	end
	self.time_record = nil
end

function ReviveView:CloseCallBack()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	if self.buff_time_quest then
		GlobalTimerQuest:CancelQuest(self.buff_time_quest)
		self.buff_time_quest = nil
	end
	if self.buff_cd_time_quest then
		GlobalTimerQuest:CancelQuest(self.buff_cd_time_quest)
		self.buff_cd_time_quest = nil
	end
	ReviveData.Instance:SetKillerName("")
end

function ReviveView:OpenCallBack()
	ReviveCtrl.Instance:SendHuguozhiliReq(HUGUOZHILI_OPERA_REQ_TYPE.REQ_INFO)
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	self:Flush()
end

function ReviveView:LoadCallBack()
	self:ListenEvent("OnClickLocal", BindTool.Bind(self.OnClickLocal, self))
	self:ListenEvent("OnClickFree", BindTool.Bind(self.OnClickFree, self))
	self:ListenEvent("OnClickBtn3", BindTool.Bind(self.OnClickBtn3, self))
	-- self:ListenEvent("OnClickButton1",
	-- 	BindTool.Bind(self.OnClickButton, self, 1))
	-- self:ListenEvent("OnClickButton2",
	-- 	BindTool.Bind(self.OnClickButton, self, 2))
	-- self:ListenEvent("OnClickButton3",
	-- 	BindTool.Bind(self.OnClickButton, self, 3))
	-- self:ListenEvent("OnClickButton4",
	-- 	BindTool.Bind(self.OnClickButton, self, 4))
	-- self:ListenEvent("OnClickButton5",
	-- 	BindTool.Bind(self.OnClickButton, self, 5))
	-- self:ListenEvent("OnClickLeft",
	-- 	BindTool.Bind(self.OnClickLeft, self))
	-- self:ListenEvent("OnClickRight",
	-- 	BindTool.Bind(self.OnClickRight, self))
	self:ListenEvent("ClickPre",
		BindTool.Bind(self.ClickPre, self))
	self:ListenEvent("ClickNext",
		BindTool.Bind(self.ClickNext, self))
	self:ListenEvent("OnClickGuildRevive",
		BindTool.Bind(self.OnClickGuildRevive, self))
	self:ListenEvent("OnClickActive", BindTool.Bind(self.OnClickActive, self))

	self.event = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_REALIVE, BindTool.Bind1(self.OnMainRoleRevive, self))

	self.time = self:FindVariable("Time")
	self.killer_name = self:FindVariable("Killer")
	self.revive_cost = self:FindVariable("ReviveCost")
	self.gold_img = self:FindVariable("GoldImg")
	self.show_free_revive = self:FindVariable("ShowFreeRevive")
	self.show_gold_revive = self:FindVariable("ShowGoldRevive")
	self.revive_item_text = self:FindVariable("ReviveItemText")
	self.show_revive_cost = self:FindVariable("ShowReviveCost")
	self.show_revive_enble = self:FindVariable("FreeReviveEnble")
	self.show_btn3 = self:FindVariable("ShowBtn3")
	self.btn3_cost = self:FindVariable("Btn3Cost")
	self.btn3_text = self:FindVariable("Btn3Text")
	self.revive_time = self:FindVariable("ReviveTime")
	self.free_revive_txt = self:FindVariable("FreeReviveTxt")
	self.show_normal_revive = self:FindVariable("ShowNormalRevive")
	self.show_boss_revive = self:FindVariable("ShowBossRevive")
	self.show_guild_revive = self:FindVariable("ShowGuildRevive")
	self.guild_rest_count = self:FindVariable("GuildRestCount")
	self.free_time = self:FindVariable("FreeTime")
	self.show_free = self:FindVariable("ShowFree")
	self.show_poop = self:FindVariable("ShowPoop")
	self.camp_fuhuo_num = self:FindVariable("CampFuHuoNum")
	self.revive_image = self:FindVariable("ReviveImage")
	self.active_time = self:FindVariable("ActiveTime")
	self.buff_time = self:FindVariable("BuffTime")
	self.can_active = self:FindVariable("CanActive")
	self.active_btn = self:FindObj("ActiveBtn")
	self.active_text = self:FindVariable("ActiveText")
	self.show_guild_revive:SetValue(false)

	self.list_view = self:FindObj("ListView")

	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetMountNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshMountCell, self)
	self.cell_list = {}
	-- self.scroll_rect = self:FindObj("ScrollRect").scroll_rect
end

function ReviveView:ReleaseCallBack()
	if self.cell_list ~= nil then
		for k, v in pairs(self.cell_list) do
			v:DeleteMe()
		end
		self.cell_list = nil
	end

	if self.event ~= nil then
		GlobalEventSystem:UnBind(self.event)
		self.event = nil
	end

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	UnityEngine.PlayerPrefs.DeleteKey("fuhuo")
	UnityEngine.PlayerPrefs.DeleteKey("aoto_active_huguozhili")

	-- 清理变量和对象
	self.time = nil
	self.killer_name = nil
	self.revive_cost = nil
	self.gold_img = nil
	self.show_free_revive = nil
	self.show_gold_revive = nil
	self.revive_item_text = nil
	self.show_revive_cost = nil
	self.show_revive_enble = nil
	self.show_btn3 = nil
	self.btn3_cost = nil
	self.btn3_text = nil
	self.revive_time = nil
	self.free_revive_txt = nil
	self.show_normal_revive = nil
	self.show_boss_revive = nil
	self.show_guild_revive = nil
	self.guild_rest_count = nil
	self.free_time = nil
	self.show_free = nil
	self.list_view = nil
	self.show_poop = nil
	self.camp_fuhuo_num = nil
	self.revive_image = nil
	self.active_time = nil
	self.buff_time = nil
	self.can_active = nil
	self.active_btn = nil
	self.active_text = nil
end

function ReviveView:GetMountNumberOfCells()
	local gongneng_sort = ReviveData.Instance:GetGongNeng()
	return #gongneng_sort
end

function ReviveView:RefreshMountCell(cell, cell_index)
	local gongneng_image = ReviveData.Instance:GetGongNeng()
	local gongneng_cell = self.cell_list[cell]
	if gongneng_cell == nil then
		gongneng_cell = GongNengCell.New(cell.gameObject)
		self.cell_list[cell] = gongneng_cell
	end
	local data = {}
	data.image_name = gongneng_image[cell_index+1].img_name
	data.view_name = gongneng_image[cell_index+1].view_name
	data.index = cell_index
	gongneng_cell:SetData(data)
	-- gongneng_cell:ListenClick(BindTool.Bind(self.OnClickListCell, self, mount_special_image[cell_index], cell_index, mount_cell))
end

function ReviveView:ClickPre()
	local position = self.list_view.scroller.ScrollPosition
	local index = self.list_view.scroller:GetCellViewIndexAtPosition(position)
	index = index - 1
	self:JumpToIndex(index)
end

function ReviveView:ClickNext()
	local position = self.list_view.scroller.ScrollPosition
	local index = self.list_view.scroller:GetCellViewIndexAtPosition(position)
	index = index + 1
	self:JumpToIndex(index)
end

-- 点击公会复活
function ReviveView:OnClickGuildRevive()
	FightCtrl.SendRoleReAliveReq(REALIVE_TYPE.REALIVE_TYPE_BIND_GOLD)
end

function ReviveView:OnClickActive()
	local function SendHuguozhiliReq()
		ReviveCtrl.Instance:SendHuguozhiliReq(HUGUOZHILI_OPERA_REQ_TYPE.REQ_ACTIVE_HUGUOZHILI)
	end
	local huguo_info = ReviveData.Instance:GetHuguozhiliInfo()
	local left_active_time = ReviveData.Instance:GetTotalActiveTime() - huguo_info.today_active_times
	if UnityEngine.PlayerPrefs.GetInt("aoto_active_huguozhili") == 1 then
		SendHuguozhiliReq()
	else
		TipsCtrl.Instance:ShowCommonTip(SendHuguozhiliReq, nil, string.format(Language.Fuhuo.IsActiveHuGuoZhiLi, left_active_time), nil, nil, true, false, "aoto_active_huguozhili")
	end
end

function ReviveView:JumpToIndex(index)
	local max_count = self:GetMountNumberOfCells()
	index = index >= max_count and max_count - 1 or index
	if index < 0 then
		index = 0
	end
	local width = self.list_view.transform:GetComponent(typeof(UnityEngine.RectTransform)).sizeDelta.x
	local space = self.list_view.scroller.spacing
	-- 当前页面可以显示的数量
	local count = math.floor((width + space) / (100 + space))
	if max_count <= count or index + count > max_count then
		return
	end

	local jump_index = index
	local scrollerOffset = 0
	local cellOffset = 0
	local useSpacing = false
	local scrollerTweenType = self.list_view.scroller.snapTweenType
	local scrollerTweenTime = 0.1
	local scroll_complete = nil
	self.list_view.scroller:JumpToDataIndexForce(
		jump_index, scrollerOffset, cellOffset, useSpacing, scrollerTweenType, scrollerTweenTime, scroll_complete)
end
-- function ReviveView:JudgeResurgence()
	
-- end
-- 原地满血复活
function ReviveView:OnClickLocal()
	-- local vo = GameVoManager.Instance:GetMainRoleVo()

	-- if self.remind_times ~= 0 then
	-- 	print(self.remind_times)
	-- elseif not ReviveView.CanUseItem() then
	-- 	local func = function ()
	-- 		FightCtrl.SendRoleReAliveReq(REALIVE_TYPE.REALIVE_TYPE_BIND_GOLD)
	-- 	end
	-- 	local str = string.format(Language.Fuhuo.BuyFuHuo4, ReviveView.ReviveCost())
	-- 	-- if ReviveView.ReviveCost() > PlayerData.Instance.role_vo.bind_gold then
	-- 	-- 	local gold = ReviveView.ReviveCost() - PlayerData.Instance.role_vo.bind_gold
	-- 	-- 	if PlayerData.Instance.role_vo.bind_gold > 0 then
	-- 	-- 		str = string.format(Language.Fuhuo.BuyFuHuo3, gold, PlayerData.Instance.role_vo.bind_gold)
	-- 	-- 	else
	-- 	-- 		str = string.format(Language.Fuhuo.BuyFuHuo, ReviveView.ReviveCost())
	-- 	-- 	end
	-- 	-- end
	-- 	TipsCtrl.Instance:ShowCommonAutoView("fuhuo", str, func)
	-- 	return
	-- end



	-- FightCtrl.SendRoleReAliveReq(REALIVE_TYPE.REALIVE_TYPE_BIND_GOLD)

	local role_realive_cost = ReviveData.Instance:GetRoleReAliveCostType()

	local function ok_func()
		local vo = GameVoManager.Instance:GetMainRoleVo()
		if role_realive_cost.local_revive_type == COUTRY_REVIVE_TYPE.ROLE_REALIVE_COST_TYPE_CAMP then					-- 国家复活
			FightCtrl.SendRoleReAliveReq(REALIVE_TYPE.REALIVE_TYPE_HERE_CAMP)    																		
		elseif role_realive_cost.local_revive_type == COUTRY_REVIVE_TYPE.ROLE_REALIVE_COST_TYPE_GOLD2 then				-- 元宝复活
			FightCtrl.SendRoleReAliveReq(REALIVE_TYPE.REALIVE_TYPE_HERE_GOLD)  
		elseif role_realive_cost.local_revive_type == COUTRY_REVIVE_TYPE.ROLE_REALIVE_COST_TYPE_RES then 				-- 复活石复活
			FightCtrl.SendRoleReAliveReq(REALIVE_TYPE.REALIVE_TYPE_HERE_STUFF)
		elseif role_realive_cost.local_revive_type == COUTRY_REVIVE_TYPE.ROLE_REALIVE_COST_TYPE_GOLD1 then 				-- 绑定元宝复活
			FightCtrl.SendRoleReAliveReq(REALIVE_TYPE.REALIVE_TYPE_HERE_BIND_GOLD)
		else   
			--FightCtrl.SendRoleReAliveReq(REALIVE_TYPE.REALIVE_TYPE_HERE_CAMP)
		end
	end

	if TipsCommonAutoView.AUTO_VIEW_STR_T["fuhuo"] and TipsCommonAutoView.AUTO_VIEW_STR_T["fuhuo"].is_auto_buy then
		ok_func()
	else
		local str = string.format(Language.Fuhuo.BuyFuHuo4, ReviveView.ReviveCost())
		local gold = ReviveView.ReviveCost() - PlayerData.Instance.role_vo.bind_gold
		if gold >= 0 and role_realive_cost.local_revive_type ~= COUTRY_REVIVE_TYPE.ROLE_REALIVE_COST_TYPE_CAMP then
			if PlayerData.Instance.role_vo.bind_gold > 0 then
				str = string.format(Language.Fuhuo.BuyFuHuo3, gold, PlayerData.Instance.role_vo.bind_gold)
			else
				str = string.format(Language.Fuhuo.BuyFuHuo, ReviveView.ReviveCost())
			end

			TipsCtrl.Instance:ShowCommonAutoView("fuhuo", str, ok_func)
		else
			ok_func()
		end
	end
end

function ReviveView:OnMainRoleRevive()
	self:Close()
end

-- 免费复活
function ReviveView:OnClickFree()
	local status_citan = NationalWarfareData.Instance:GetCampCitanStatus()
    local status_banzhuan = NationalWarfareData.Instance:GetCampBanzhuanStatus()
    local function SendReAliveReq()
		FightCtrl.SendRoleReAliveReq(REALIVE_TYPE.REALIVE_TYPE_BACK_HOME)
	end
	if status_citan.task_phase == 2 or status_banzhuan.task_phase == 2 then
		TipsCtrl.Instance:ShowCommonTip(SendReAliveReq, nil, Language.Fuhuo.FreeReviveTips,nil,nil,false,true,nil,false,nil,Language.Fuhuo.AutoDesTips,nil,nil,false,Language.Common.Cancel,self.time_record,true)
	else
	    FightCtrl.SendRoleReAliveReq(REALIVE_TYPE.REALIVE_TYPE_BACK_HOME)
	end
end

function ReviveView:OnClickBtn3()
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.ClashTerritory then
		local ct_info = ClashTerritoryData.Instance:GetTerritoryWarData()
		local revive_cost = ClashTerritoryData.Instance:GetReviveCost()
		if ct_info.current_credit >= revive_cost then
			ClashTerritoryCtrl.Instance:SendTerritoryWarReliveFightBuy(ClashTerritoryData.ReviveType, ClashTerritoryData.ReviveGoods)
			-- self:Close()
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.NotEnoughScore)
		end
	end
end

-- function ReviveView:OnClickButton(index)
-- 	ViewManager.Instance:Open(ViewNameList[index])
-- end

-- function ReviveView:OnClickLeft()
-- 	self.scroll_rect.normalizedPosition = Vector2(0, 1.0)
-- 	self.show_right_arrow:SetValue(true)
-- 	self.show_left_arrow:SetValue(false)
-- end

-- function ReviveView:OnClickRight()
-- 	self.scroll_rect.normalizedPosition = Vector2(1.5, 2.0)
-- 	self.show_left_arrow:SetValue(true)
-- 	self.show_right_arrow:SetValue(false)
-- end

function ReviveView:OnFlush(param_t)
	local inamg_name = NationalWarfareData.Instance:GetHasRelivePillar() and "title_revive3.png" or "title_revive2.png"
	self.revive_image:SetAsset(ResPath.GetReviveview(inamg_name))
	local fuhuo_num, fuhuo_gold = 0, 0 																				-- 国家次数，元宝价格
	local fuhuo_res, fuhuo_boundgold = 0, 0 																		-- 复活石数量，绑定元宝价格
	local role_realive_cost = ReviveData.Instance:GetRoleReAliveCostType()			
	if role_realive_cost.local_revive_type == COUTRY_REVIVE_TYPE.ROLE_REALIVE_COST_TYPE_CAMP then					-- 国家复活
		fuhuo_num = role_realive_cost.param2
		self.camp_fuhuo_num:SetValue(string.format(Language.FuHuoHint.GuoJia,fuhuo_num))       																		
	elseif role_realive_cost.local_revive_type == COUTRY_REVIVE_TYPE.ROLE_REALIVE_COST_TYPE_GOLD2 then				-- 元宝复活
		fuhuo_gold = role_realive_cost.param2
		self.camp_fuhuo_num:SetValue(string.format(Language.FuHuoHint.Gold,fuhuo_gold))
	elseif role_realive_cost.local_revive_type == COUTRY_REVIVE_TYPE.ROLE_REALIVE_COST_TYPE_RES then 				-- 复活石复活
		fuhuo_res = role_realive_cost.param2
		self.camp_fuhuo_num:SetValue(string.format(Language.FuHuoHint.FuHuoShi,fuhuo_res))
	elseif role_realive_cost.local_revive_type == COUTRY_REVIVE_TYPE.ROLE_REALIVE_COST_TYPE_GOLD1 then 				-- 绑定元宝复活
		fuhuo_boundgold = role_realive_cost.param2
		self.camp_fuhuo_num:SetValue(string.format(Language.FuHuoHint.BoundGold,fuhuo_boundgold))
	end

	--print_error("复活数量:", role_realive_cost.local_revive_type, fuhuo_num, fuhuo_gold)

	local diff_time = ReviveView.ReviveTime()
	self.revive_cost:SetValue(ReviveView.ReviveCost())
	self.gold_img:SetAsset(ResPath.GetYuanBaoIcon(1))
	self.killer_name:SetValue(ReviveData.Instance:GetKillerName())
	local scene_type = Scene.Instance:GetSceneType()
	self.show_free_revive:SetValue(ReviveView.CanUseFreeRevive())
	self.show_revive_enble:SetValue(ReviveView.FreeReviveEnble())
	self:UpdateShowBtn3()
	self.show_revive_cost:SetValue(not ReviveView.CanUseItem())
	self.show_normal_revive:SetValue(true)
	self.show_boss_revive:SetValue(false)
	local scene_id = Scene.Instance:GetSceneId()
	local free_txt = Language.Fuhuo.FreeReviveTxt[1]
	if BossData.IsBossScene(scene_id) then
		if BossData.IsFamilyBossScene(scene_id) then
			free_txt = Language.Fuhuo.FreeReviveTxt[2]
		else
			local main_role = Scene.Instance:GetMainRole()
			if main_role and main_role.vo.top_dps_flag and main_role.vo.top_dps_flag > 0 then
				free_txt = Language.Fuhuo.FreeReviveTxt[3]
			end
		end
	end
	self.free_revive_txt:SetValue(free_txt)
	if ReviveView.CanUseItem() then
		if Scene.Instance:GetSceneType() == SceneType.Kf_XiuLuoTower and KuaFuXiuLuoTowerData.Instance:GetReviveTxt() then
			local xlt_fh = KuaFuXiuLuoTowerData.Instance:GetReviveTxt()
			self.revive_item_text:SetValue(xlt_fh)
		else
			local item_count = ItemData.Instance:GetItemNumInBagById(ReviveDataItemId.ItemId)
			local name = ItemData.Instance:GetItemName(ReviveDataItemId.ItemId)
			self.revive_item_text:SetValue(name .. ":" .. item_count .. "/1")
		end
	else
		self.revive_item_text:SetValue("")
	end
	if BossData.IsMikuBossScene(Scene.Instance:GetSceneId()) and BossData.Instance:GetWroldBossWeary() >= 5 then
		self.show_normal_revive:SetValue(false)
		self.show_boss_revive:SetValue(true)
		if (TimeCtrl.Instance:GetServerTime() - BossData.Instance:GetWroldBossWearyLastDie()) >= 62 then
			FightCtrl.SendRoleReAliveReq(REALIVE_TYPE.REALIVE_TYPE_BACK_HOME)
			-- self:Close()
			return
		else
			diff_time = BossData.Instance:GetWroldBossWearyLastDie() + 61 - TimeCtrl.Instance:GetServerTime()
		end

		if self.count_down == nil then
			self.count_down = CountDown.Instance:AddCountDown(
				999999, 1, function(elapse_time, total_time)
					local left_time = BossData.Instance:GetWroldBossWearyLastDie() + 61 - TimeCtrl.Instance:GetServerTime()
					if left_time <= 0 then
						FightCtrl.SendRoleReAliveReq(REALIVE_TYPE.REALIVE_TYPE_BACK_HOME)
						return
					end
					local left_sec = math.floor(left_time)
					self.revive_time:SetValue(left_sec)
				end)
		end
		return
	end

	if self.count_down == nil then
		self.count_down = CountDown.Instance:AddCountDown(
			diff_time, 1, function(elapse_time, total_time)
				local left_time = math.ceil(diff_time - elapse_time)
				if left_time <= 0 then
					FightCtrl.SendRoleReAliveReq(REALIVE_TYPE.REALIVE_TYPE_BACK_HOME)
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
					-- self:Close()
					return
				end
				local left_sec = math.floor(left_time)
				self.time_record = left_time
				self.time:SetValue(left_sec)
			end)
	end
	self.time:SetValue(diff_time)
	local used_times=ReviveData.Instance.UsedTime or 0
	local today_free_revive_num= ReviveData.Instance.today_free_revive_num
    if used_times == today_free_revive_num then
    	self.show_free:SetValue(false)
    	self.remind_times = 0
    else
    	self.show_free:SetValue(true)
    	self.remind_times = today_free_revive_num-used_times
    	self.free_time:SetValue(self.remind_times)
    end
    if scene_type == SceneType.Kf_XiuLuoTower then
    	self.show_poop:SetValue(false)
    else
    	self.show_poop:SetValue(true)
    end
	-- self:CheckGuildRevive()

	local huguo_info = ReviveData.Instance:GetHuguozhiliInfo()
	local huguo_cfg = ReviveData.Instance:GetHuguozhiliCfg()
	
	local left_active_time = ReviveData.Instance:GetTotalActiveTime() - huguo_info.today_active_times
	local die_time = ReviveData.Instance:GetCanActiveTime()
	self.active_time:SetValue(string.format(Language.Fuhuo.ActiveTime, left_active_time))
	self.can_active:SetValue(not ReviveData.Instance:GetCanActive())
	self.active_btn.button.interactable = not ReviveData.Instance:GetCanActive()
	
	if left_active_time <= 0 then
		self.active_time:SetValue(string.format(Language.Fuhuo.DieTime, die_time))
		self.can_active:SetValue(false)
		self.active_btn.button.interactable = false
		self.active_text:SetValue(Language.Fuhuo.ActiveHuGuoZhiLi)
	end

	if ReviveData.Instance:GetCanActive() then
		self.active_text:SetValue(Language.Fuhuo.HasActive)
		local is_cd = ReviveData.Instance:GetBuffCd()
		if is_cd then
			--if nil == self.buff_cd_time_quest then
				--self.buff_cd_time_quest = GlobalTimerQuest:AddRunQuest(function()
					local _, cd_time = ReviveData.Instance:GetBuffCd()
					if cd_time < 0 then
						if self.active_text ~= nil then
							self.active_text:SetValue(Language.Fuhuo.ActiveHuGuoZhiLi)
						end

						if self.can_active ~= nil then
							self.can_active:SetValue(true)
						end

						if self.active_btn ~= nil then
							self.active_btn.button.interactable = true
						end
						
						if self.buff_cd_time_quest then
							GlobalTimerQuest:CancelQuest(self.buff_cd_time_quest)
							self.buff_cd_time_quest = nil
						end
					else
						if self.active_text then
							self.active_text:SetValue(string.format(Language.Fuhuo.BuffCd ,math.floor(cd_time)))
						end
					end
				--end, 0)
			--end
		end
	else
		self.active_text:SetValue(Language.Fuhuo.ActiveHuGuoZhiLi)
	end

	if not ReviveData.Instance:GetCanActive() and left_active_time > 0 then
		self.buff_time:InitValue(1)
	else
		--if nil == self.buff_time_quest then
			--self.buff_time_quest = GlobalTimerQuest:AddRunQuest(function() 
				local left_time = huguo_cfg.other[1].buff_interval_s - (TimeCtrl.Instance:GetServerTime() - huguo_info.active_huguozhili_timestamp)
				if self.buff_time then
					self.buff_time:SetValue(left_time / huguo_cfg.other[1].buff_interval_s)
				end
			--end, 0)
		--end
	end
end

-- 是否能够使用公会复活
function ReviveView:CheckGuildRevive()
	self.show_guild_revive:SetValue(false)
	if GameVoManager.Instance:GetMainRoleVo().guild_id > 0 then
		local rest_guild_daily_relive_times = GuildData.Instance:GetRestGuildTotalReviveCount() or 0
		local rest_personal_revive_times = GuildData.Instance:GetRestPersonalGuildReviveCount() or 0
		if rest_guild_daily_relive_times > 0 and rest_personal_revive_times > 0 then
			self.show_guild_revive:SetValue(true)
			self.show_revive_cost:SetValue(false)
			self.revive_item_text:SetValue(string.format(Language.Fuhuo.GuildRevive, rest_personal_revive_times))
			self.guild_rest_count:SetValue(rest_guild_daily_relive_times)
		end
	end
end

function ReviveView.CanUseItem()
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.ShuiJing then
		return false
	elseif scene_type == SceneType.Kf_XiuLuoTower and KuaFuXiuLuoTowerData.Instance:GetReviveTxt() then
		return true
	end
	local item_count = ItemData.Instance:GetItemNumInBagById(ReviveDataItemId.ItemId)
	if item_count < 1 then
		return false
	end
	return true
end

function ReviveView.ReviveTime()
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.ShuiJing then
		return ConfigManager.Instance:GetAutoConfig("activityshuijing_auto").other[1].relive_time
	elseif IsFightSceneType[scene_type] or scene_type == SceneType.Kf_XiuLuoTower then
		return 5
	end
	return ReviveDataTime.RevivieTime
end

function ReviveView.ReviveCost()
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.Kf_XiuLuoTower then
		return ConfigManager.Instance:GetAutoConfig("other_config_auto").other[1].cross_relive_gold
	end
	local shop_cfg = ShopData.Instance:GetShopItemCfg(ReviveDataItemId.ItemId) or {}
	return shop_cfg.gold or 20
end

function ReviveView.FreeReviveEnble()
	return true
end

function ReviveView.CanUseFreeRevive()
	return true
end

function ReviveView:UpdateShowBtn3()
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.ClashTerritory then
		self.show_btn3:SetValue(true)
		local ct_info = ClashTerritoryData.Instance:GetTerritoryWarData()
		local revive_cost = ClashTerritoryData.Instance:GetReviveCost()
		local color = revive_cost > ct_info.current_credit and "ff0000" or "00ff00"
		self.btn3_cost:SetValue(string.format(Language.ClashTerritory.ScoreCost, color, revive_cost))
	else
		self.show_btn3:SetValue(false)
	end
end

function ReviveView:PauseTimer()
	-- if self.buff_cd_time_quest then
	-- 	GlobalTimerQuest:CancelQuest(self.buff_cd_time_quest)
	-- 	self.buff_cd_time_quest = nil
	-- end
end

--------------------------------
---------GongNengCell
--------------------------------
GongNengCell = GongNengCell or BaseClass(BaseRender)
function GongNengCell:__init()
	self.Image = self:FindVariable("Image")
	self:ListenEvent("OnClick", BindTool.Bind(self.ClickOpen, self))
end

function GongNengCell:SetData(data)
	if data == nil then
		return
	end
	self.data = data
	local bundle, asset = ResPath.GetSystemIcon(self.data.image_name)
	self.Image:SetAsset(bundle, asset)
end

function GongNengCell:ClickOpen()
	if self.data then
		ViewManager.Instance:Open(self.data.view_name)
	end
end