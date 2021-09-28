ReviveView = ReviveView or BaseClass(BaseView)

local ViewNameList = {
	ViewName.Forge, ViewName.Advance, ViewName.SpiritView, ViewName.Goddess, ViewName.BaoJu
}

function ReviveView:__init()
	self.ui_config = {"uis/views/reviveview_prefab", "ReviveView"}
	self.view_layer = UiLayer.Normal
	self.play_audio = true
	self.active_close = false
end

function ReviveView:__delete()
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
	UnityEngine.PlayerPrefs.DeleteKey("fuhuo")
	self:StopCountDown()
end

function ReviveView:CloseCallBack()
	if self.event ~= nil then
		GlobalEventSystem:UnBind(self.event)
		self.event = nil
	end

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end

	if self.buff_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.buff_count_down)
		self.buff_count_down = nil
	end

	ReviveData.Instance:SetKillerName("")
end

function ReviveView:OpenCallBack()
	self.event = GlobalEventSystem:Bind(ObjectEventType.MAIN_ROLE_REALIVE, BindTool.Bind1(self.OnMainRoleRevive, self))

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	self:Flush()
	ReviveData.Instance:SetLastReviveType(-1)
	-- ReviveCtrl.Instance:SendDieBuffInfo(FETCH_BUFF_OPERATE_TYPE.FETCH_BUFF_INFO)
end

function ReviveView:LoadCallBack()
	self:ListenEvent("OnClickLocal",
		BindTool.Bind(self.OnClickLocal, self))
	self:ListenEvent("OnClickFree",
		BindTool.Bind(self.OnClickFree, self))
	self:ListenEvent("OnClickBtn3",
		BindTool.Bind(self.OnClickBtn3, self))
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
	self:ListenEvent("OnClickActive",
		BindTool.Bind(self.OnClickActive, self))

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
	self.show_xiuluota_num = self:FindVariable("ShowXiuLuoTaNum")
	self.show_des = self:FindVariable("ShowDes")
	self.xiuluota_is_drop_level = self:FindVariable("XiuLuoTaIsDropLevel")
	self.xiuluota_is_drop_level2 = self:FindVariable("XiuLuoTaIsDropLevel2")
	self.show_xiuluota_imagetext = self:FindVariable("ShowXiuLuoTaImageText")
	self.show_normal_text = self:FindVariable("ShowNormalText")
	self.weary_layer = self:FindVariable("WearyLayer")

	self.show_guild_revive:SetValue(false)

	self.list_view = self:FindObj("ListView")

	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetMountNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshMountCell, self)
	self.cell_list = {}
	-- self.scroll_rect = self:FindObj("ScrollRect").scroll_rect

	self.buff_remind = self:FindVariable("BuffRemind")
	self.buff_time = self:FindVariable("BuffTime")
	self.can_acvive = self:FindVariable("CanActive")
	self.buff_maxhp_per = self:FindVariable("MaxhpPer")
	self.button_text = self:FindVariable("ButtonText")
	self.is_active = self:FindVariable("IsActive")
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
	self.show_normal_text = nil
	self.weary_layer = nil
	self.show_xiuluota_num = nil
	self.xiuluota_is_drop_level = nil
	self.xiuluota_is_drop_level2 = nil
	self.show_xiuluota_imagetext = nil
	self.show_des = nil
	self.buff_remind = nil
	self.buff_time = nil
	self.can_acvive = nil
	self.buff_maxhp_per = nil
	self.button_text = nil
	self.is_active = nil
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
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.Kf_XiuLuoTower then
		local xiuluota_num = KuaFuXiuLuoTowerData.Instance:GetKuaFuXiuLuoTaNum()
		if xiuluota_num <= 0 then
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.KuaFuXiuLuoTaDes)
			return
		end
	end
	FightCtrl.SendRoleReAliveReq(REALIVE_TYPE.REALIVE_TYPE_HERE_ICON)
	ReviveData.Instance:SetLastReviveType(REALIVE_TYPE.REALIVE_TYPE_HERE_ICON)
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

-- 原地满血复活
function ReviveView:OnClickLocal()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if self.remind_times ~= 0 then
		FightCtrl.SendRoleReAliveReq(REALIVE_TYPE.REALIVE_TYPE_HERE_ICON)
		ReviveData.Instance:SetLastReviveType(REALIVE_TYPE.REALIVE_TYPE_HERE_ICON)
	elseif not ReviveView.CanUseItem() then
		local func = function ()
			FightCtrl.SendRoleReAliveReq(REALIVE_TYPE.REALIVE_TYPE_HERE_ICON)
			ReviveData.Instance:SetLastReviveType(REALIVE_TYPE.REALIVE_TYPE_HERE_ICON)
		end
		local str = string.format(Language.Fuhuo.BuyFuHuo4, ReviveView.ReviveCost())
		TipsCtrl.Instance:ShowCommonAutoView("fuhuo", str, func)
	end
end

function ReviveView:OnMainRoleRevive()
	self:Close()
end

-- 免费复活
function ReviveView:OnClickFree()
	if BossData.IsMikuBossScene(Scene.Instance:GetSceneId()) and BossData.Instance:GetWroldBossWeary() >= 5 then
	   SysMsgCtrl.Instance:ErrorRemind(Language.Common.FailRevive)
	   return
	end

	FightCtrl.SendRoleReAliveReq(REALIVE_TYPE.REALIVE_TYPE_BACK_HOME)
	ReviveData.Instance:SetLastReviveType(REALIVE_TYPE.REALIVE_TYPE_BACK_HOME)
	self:Close()
end

function ReviveView:OnClickBtn3()
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.ClashTerritory then
		local ct_info = ClashTerritoryData.Instance:GetTerritoryWarData()
		local revive_cost = ClashTerritoryData.Instance:GetReviveCost()
		if ct_info.current_credit >= revive_cost then
			ClashTerritoryCtrl.Instance:SendTerritoryWarReliveFightBuy(ClashTerritoryData.ReviveType, ClashTerritoryData.ReviveGoods)
			self:Close()
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
	local diff_time = ReviveView.ReviveTime()
	self.revive_cost:SetValue(ReviveView.ReviveCost())
	self.gold_img:SetAsset(ResPath.GetDiamonIcon(2))
	self.killer_name:SetValue(ReviveData.Instance:GetKillerName())
	local scene_type = Scene.Instance:GetSceneType()
	self.show_free_revive:SetValue(ReviveView.CanUseFreeRevive())
	self.show_revive_enble:SetValue(ReviveView.FreeReviveEnble())
	self:UpdateShowBtn3()
	self.show_revive_cost:SetValue(not ReviveView.CanUseItem())
	self.show_normal_text:SetValue(true)
	self.show_normal_revive:SetValue(true)
	self.show_boss_revive:SetValue(false)
	local scene_id = Scene.Instance:GetSceneId()
	local free_txt = Language.Fuhuo.FreeReviveTxt[1]

	self:FlushBuff()

	if BossData.IsMikuBossScene(Scene.Instance:GetSceneId()) then
		local layer = BossData.Instance:GetWroldBossWeary()
		if layer == 0 then
			layer = 1
		end
		self.weary_layer:SetValue(layer)
		self.show_normal_text:SetValue(false)
	end

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

	if self.count_down == nil then
		self.count_down = CountDown.Instance:AddCountDown(
			diff_time, 1, function(elapse_time, total_time)
				local left_time = math.ceil(diff_time - elapse_time)
				if left_time <= 0 then
					FightCtrl.SendRoleReAliveReq(REALIVE_TYPE.REALIVE_TYPE_BACK_HOME)
					ReviveData.Instance:SetLastReviveType(REALIVE_TYPE.REALIVE_TYPE_BACK_HOME)
					CountDown.Instance:RemoveCountDown(self.count_down)
					self.count_down = nil
					self:Close()
					return
				end
				local left_sec = math.floor(left_time)
				self.time:SetValue(left_sec)
			end)
	end
	self.time:SetValue(diff_time)
	local used_times = ReviveData.Instance.UsedTime
	local today_free_revive_num = ReviveData.Instance.today_free_revive_num
    if used_times == today_free_revive_num then
    	self.show_free:SetValue(false)
    	self.remind_times = 0
    else
    	self.show_free:SetValue(true)
    	self.remind_times = today_free_revive_num - used_times
    	self.free_time:SetValue(self.remind_times)
    end

    self.show_gold_revive:SetValue(self:IsShowGoldRevive())

    if scene_type == SceneType.Kf_XiuLuoTower then
    	-- local cu_layer = KuaFuXiuLuoTowerData.Instance:GetCurrentLayer()
		-- local is_drop_level = KuaFuXiuLuoTowerData.Instance:GetIsDropLayer(cu_layer)
		local is_show_drop_des = KuaFuXiuLuoTowerData.Instance:GetCurLayerDes()
		self.show_xiuluota_imagetext:SetValue(true)
		if nil ~= is_show_drop_des then
			self.xiuluota_is_drop_level:SetValue(is_show_drop_des)
			self.xiuluota_is_drop_level2:SetValue(not is_show_drop_des)
		end
    	self.show_des:SetValue(false)
    	if not KuaFuXiuLuoTowerData.Instance:GetReviveTxt() then
    		self.show_free:SetValue(false)
    	end
    	local xiuluota_num = KuaFuXiuLuoTowerData.Instance:GetKuaFuXiuLuoTaNum()
    	if xiuluota_num then
    		self.show_xiuluota_num:SetValue(xiuluota_num <= 0)
    	end
    	self.show_poop:SetValue(false)
    	self.show_free:SetValue(false)
    	self.show_revive_cost:SetValue(false)
    else
    	self.show_poop:SetValue(true)
    end
end

function ReviveView:StopCountDown()
	if self.buff_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.buff_count_down)
		self.buff_count_down = nil
	end

	if self.cooling_count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.cooling_count_down)
		self.cooling_count_down = nil
	end
end

function ReviveView:FlushBuff()
	self:StopCountDown()
	self.buff_info = ReviveData.Instance:GetDieBuffInfo()
	self.other_buff_cfg = ReviveData.Instance:GetOtherDieBuffCfg()

	if next(self.buff_info) == nil then
		return
	end

	local buff_maxhp_per = self.other_buff_cfg.injure_maxhp_per    -- 效果百分比
	local buff_interval_s = self.other_buff_cfg.buff_interval_s    -- 持续cd
	local buff_cd_s = self.other_buff_cfg.buff_cd_s                -- 冷却cd
	local max_can_active_times = ReviveData.Instance:GetMaxCanActiveBuffTimes()

	-- buff可激活次数
	local can_active_times = ReviveData.Instance:GetCanActiveTimesByDieTimes(self.buff_info.today_die_times) - self.buff_info.today_active_times
	if can_active_times > 0 and can_active_times <= max_can_active_times then
		self.buff_remind:SetValue(string.format(Language.Revive.BuffRemind1, can_active_times))
		self.can_acvive:SetValue(true)
	elseif self.buff_info.today_active_times >= max_can_active_times then
		self.buff_remind:SetValue(Language.Revive.BuffRemind3)
		self.can_acvive:SetValue(false)
	else
		self.can_acvive:SetValue(false)
		local need_die_time = ReviveData.Instance:GetNeedDieTimesByActivedTimes(self.buff_info.today_active_times + 1) - self.buff_info.today_die_times
		self.buff_remind:SetValue(string.format(Language.Revive.BuffRemind2, need_die_time))
	end

	-- buff描述
	self.buff_maxhp_per:SetValue(buff_maxhp_per)

	-- buff进度条
	local now_time = TimeCtrl.Instance:GetServerTime()
	local now_buff_time = math.max(0, (now_time - self.buff_info.active_buiff_timestamp + 1))
	self.buff_time:SetValue(0)
	self.is_active:SetValue(false)
	if now_buff_time <= buff_interval_s then
		self.is_active:SetValue(true)
		self.buff_time:SetValue((buff_interval_s - now_buff_time) / buff_interval_s)
		self.buff_count_down = CountDown.Instance:AddCountDown(
			buff_interval_s - now_buff_time, 1, function(elapse_time, total_time)
				local left_time = total_time - elapse_time
				if left_time <= 0 then
					CountDown.Instance:RemoveCountDown(self.buff_count_down)
					self.buff_count_down = nil
					return
				end
				local left_sec = left_time / buff_interval_s
				if self.buff_time then
					self.buff_time:SetValue(left_sec)
				end
			end)
	end
	-- 冷却时间
	if now_buff_time < buff_cd_s then
		self.can_acvive:SetValue(false)
		self.button_text:SetValue(TimeUtil.FormatSecond(buff_cd_s - now_buff_time, 2))
		self.cooling_count_down = CountDown.Instance:AddCountDown(
			buff_cd_s - now_buff_time, 1, function(elapse_time, total_time)
				local left_time = total_time - elapse_time
				if left_time <= 0 then
					CountDown.Instance:RemoveCountDown(self.cooling_count_down)
					self.cooling_count_down = nil
					self:Flush()
					return
				end
				local left_sec = TimeUtil.FormatSecond(left_time, 2)
				if self.button_text then
					self.button_text:SetValue(left_sec)
				end
			end)
	else
		self.button_text:SetValue(Language.Revive.ButtonText)
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
	if scene_type == SceneType.ShuiJing or scene_type == SceneType.CrossShuijing then
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
	if scene_type == SceneType.ShuiJing or scene_type == SceneType.CrossShuijing then
		return ConfigManager.Instance:GetAutoConfig("activityshuijing_auto").other[1].relive_time
	elseif scene_type == SceneType.Kf_XiuLuoTower then
		return 15
	elseif IsFightSceneType[scene_type]  then
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
	return shop_cfg.gold or 10
end

function ReviveView.FreeReviveEnble()
	local scene_type = Scene.Instance:GetSceneType()
	-- if scene_type == SceneType.ShuiJing or scene_type == SceneType.QunXianLuanDou or scene_type == SceneType.GongChengZhan then
	if scene_type == SceneType.ShuiJing or scene_type == SceneType.CrossShuijing then
		return false
	end
	return true
end

function ReviveView.CanUseFreeRevive()
local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.ShuiJing or scene_type == SceneType.CrossShuijing then
		return false
	end
	return true
end

function ReviveView:UpdateShowBtn3()
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.ClashTerritory then
		self.show_btn3:SetValue(true)
		local ct_info = ClashTerritoryData.Instance:GetTerritoryWarData()
		local revive_cost = ClashTerritoryData.Instance:GetReviveCost()
		local color = revive_cost > ct_info.current_credit and "fe3030" or "0065fc"
		self.btn3_cost:SetValue(string.format(Language.ClashTerritory.ScoreCost, color, revive_cost))
	else
		self.show_btn3:SetValue(false)
	end
end

function ReviveView:IsShowGoldRevive()
	local scene_type = Scene.Instance:GetSceneType()
	if scene_type == SceneType.ChaosWar then
		return false
	end
	return true
end

function ReviveView:OnClickActive()
	TipsCtrl.Instance:ShowCommonAutoView(nil, Language.Revive.ActiveRemind, function ()
		ReviveCtrl.Instance:SendDieBuffInfo(FETCH_BUFF_OPERATE_TYPE.ACTIVE_BUFF)
	end)
end

GongNengCell = GongNengCell or BaseClass(BaseRender)
function GongNengCell:__init()
	self.Image = self:FindVariable("Image")
	self.Text = self:FindVariable("Text")
	self:ListenEvent("OnClick", BindTool.Bind(self.ClickOpen, self))
end

function GongNengCell:SetData(data)
	if data == nil then
		return
	end
	self.data = data
	local bundle, asset = ResPath.GetSystemIcon(self.data.image_name)
	self.Image:SetAsset(bundle, asset)
	self.Text:SetAsset(bundle,asset .. "_text")
end

function GongNengCell:ClickOpen()
	if nil == self.data then
		return
	end
	
	if self.data.view_name == "BaoJu" then
		ViewManager.Instance:Open(self.data.view_name,TabIndex.baoju_medal)
	else
		ViewManager.Instance:Open(self.data.view_name)
	end
end