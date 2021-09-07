WeddingFuBenView = WeddingFuBenView or BaseClass(BaseView)

--撒花特效播放时间
local EFFECT_TIME = 3
local PUTONG_YANHUA_ITEM_ID = 23876
local GAOJI_YANHUA_ITEM_ID = 23877

function WeddingFuBenView:__init()
	self.ui_config = {"uis/views/marriageview","WeddingFuBenView"}
	self.cd_time_count = 0
	self.flower_effect_list = {}
	self.active_close = false
	self.fight_info_view = true
	self.is_open_danmu = true
	self.rewards = {}
	self.item_list = {}
	self.item_num = {}
	self.btn_text = {}
	self.is_safe_area_adapter = true
end

function WeddingFuBenView:ReleaseCallBack()
	for k, v in pairs(self.rewards) do
		v:DeleteMe()
	end
	self.rewards = {}

	for k, v in pairs(self.answer_creel_cell_list) do
		v:DeleteMe()
	end
	self.answer_creel_cell_list = {}

	-- 清理变量和对象
	self.content = nil
	self.wedding_name = nil
	self.wedding_name2 = nil
	self.is_show_wedding_title = nil
	self.left_times = nil
	self.rewards_text = nil
	self.is_show_banner = nil
	self.banner_marrier_name = nil
	self.wedding_icon = nil
	self.is_marrier_view = nil
	self.cd_progress = nil
	self.cd_time = nil
	self.is_first = nil
	self.show_left_panel = nil
	self.can_pao_hua = nil
	self.collect_time_text  = nil
	self.renqi_value = nil
	self.is_open_notice = nil
	self.edit_text = nil
	self.free_time_text = nil
	self.danmu_res = nil
	self.add_exp = nil
	self.hunyan_desc = nil
	self.exp_radio = nil
	self.exp_text = nil
	self.btn_baitang_gray = nil
	self.btn_baitang = nil
	self.btn_xitang_gray = nil
	self.btn_xitang = nil

	self.item_num = {}
	self.btn_text = {}

	UnityEngine.PlayerPrefs.DeleteKey("show_danmu")

	if self.item_change ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_change)
		self.item_change = nil
	end
	UnityEngine.PlayerPrefs.DeleteKey("wedding_candies")
end

function WeddingFuBenView:LoadCallBack()
	self.content = self:FindObj("Content")

	-- self:ListenEvent("OnClickExit", BindTool.Bind(self.OnClickExit, self))
	self:ListenEvent("OnClicBless", BindTool.Bind(self.OnClicBless, self))
	self:ListenEvent("OnClickScatterFlower", BindTool.Bind(self.OnClickScatterFlower, self))
	self:ListenEvent("OnClickScatterFlowerBall", BindTool.Bind(self.OnClickScatterFlowerBall, self))
	self:ListenEvent("OnBtnHeCi", BindTool.Bind(self.OnBtnHeCiHandler, self))
	self:ListenEvent("OnPublishNotice", BindTool.Bind(self.OnPublishNoticeHandler, self))
	self:ListenEvent("OnCloseNotice", BindTool.Bind(self.OnCloseNoticeHandler, self))
	self:ListenEvent("OnBtnDanMu", BindTool.Bind(self.OnBtnDanMuHandler, self))
	self:ListenEvent("OnBtnBaiTang", BindTool.Bind(self.OnBtnBaiTangHandler, self))
	self:ListenEvent("OnBtnSongFu", BindTool.Bind(self.OnBtnSongFuHandler, self))
	self:ListenEvent("OnBtnGuestManage", BindTool.Bind(self.OnBtnGuestManageHandler, self))
	self:ListenEvent("OnBtnChuJiYanHua", BindTool.Bind(self.OnBtnChuJiYanHuaHandler, self))
	self:ListenEvent("OnBtnGaoJiYanHua", BindTool.Bind(self.OnBtnGaoJiYanHuaHandler, self))
	self:ListenEvent("OnBtnSeekNPC", BindTool.Bind(self.OnBtnSeekNPC, self))
	self.is_open_notice = self:FindVariable("IsOpenNotice")
	self.edit_text = self:FindObj("EditText")
	self.free_time_text = self:FindVariable("FreeTimeText")

	for i = 1, 2 do
		self.item_list[i] = self:FindObj("Item"..i)
		self.rewards[i] = ItemCell.New()
		self.rewards[i]:SetInstanceParent(self.item_list[i])
		self.item_num[i] = self:FindVariable("item_num_" .. i)
		self.btn_text[i] = self:FindVariable("btn_text_" .. i)
	end
	self.rewards[1]:SetData({item_id = PUTONG_YANHUA_ITEM_ID, is_bind = 0})
	self.rewards[2]:SetData({item_id = GAOJI_YANHUA_ITEM_ID, is_bind = 0})

	self.wedding_name = self:FindVariable("WeddingName")
	self.wedding_name2 = self:FindVariable("WeddingName2")
	self.is_show_wedding_title = self:FindVariable("IsShowWeddingTitle")
	self.left_times = self:FindVariable("LeftTimes")
	self.rewards_text = self:FindVariable("RewardsText")
	self.is_show_banner = self:FindVariable("IsShowBanner")
	self.banner_marrier_name = self:FindVariable("BannerMarrierName")
	self.wedding_icon = self:FindVariable("WeddingIcon")
	self.is_marrier_view = self:FindVariable("IsMarrierView")
	self.cd_progress = self:FindVariable("CDProgress")
	self.cd_progress:SetValue(0)
	self.cd_time = self:FindVariable("CDTime")
	self.cd_time:SetValue("")
	self.is_first = self:FindVariable("IsFirst")
	self.show_left_panel = self:FindVariable("ShowLeftPanel")
	self.can_pao_hua = self:FindVariable("CanPaoHua")
	self.collect_time_text = self:FindVariable("CollectTimeText")
	self.renqi_value = self:FindVariable("RenqiValue")
	self.danmu_res = self:FindVariable("DanMuRes")
	self.add_exp = self:FindVariable("add_exp")
	self.hunyan_desc = self:FindVariable("hunyan_desc")
	self.hunyan_desc:SetValue(Language.Marriage.HunYanDesc)
	self.exp_radio = self:FindVariable("exp_radio")
	self.exp_text = self:FindVariable("exp_text")
	self.btn_baitang_gray = self:FindVariable("btn_baitang_gray")
	self.btn_baitang = self:FindObj("BtnBaiTang")
	self.btn_xitang_gray = self:FindVariable("btn_xitang_gray")
	self.btn_xitang = self:FindObj("BtnXiTang")
	self:ChangeDanMuRes()

	self.cd_time_max = MarriageData.Instance:GetActivityCfg().paohuaqiu_cd_s

	if not self.item_change then
		self.item_change = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_change)
	end

	self:FlushItemInfo()
	-- GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_MODE_LIST, BindTool.Bind(self.OnMainUIModeListChange, self))
	self.answer_creel_cell_list = {}
	self.creel_listview_data = {}
	self.creel_list = self:FindObj("ListView")
	local creel_list_delegate = self.creel_list.list_simple_delegate
	--生成数量
	creel_list_delegate.NumberOfCellsDel = function()
		return #MarriageData.Instance:GetHunyanQuestionRankInfo() or 0
	end
	creel_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCreelListView, self)
end

function WeddingFuBenView:OnMainUIModeListChange(is_show)
	self.show_left_panel:SetValue(not is_show)
end

function WeddingFuBenView:OpenCallBack()
	self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
		BindTool.Bind(self.SwitchButtonState, self))

	self.chat_hight_change = GlobalEventSystem:Bind(MainUIEventType.CHAT_VIEW_HIGHT_CHANGE,
		BindTool.Bind(self.FulshBtnPosition, self))

	self:Flush()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local marryuser_list = MarriageData.Instance:GetMarryUserList()
	MarriageCtrl.Instance:SendMarryOpera(GameEnum.HUNYAN_GET_WEDDING_ROLE_INFO)
end

function WeddingFuBenView:RefreshCreelListView(cell, data_index, cell_index)
	data_index = data_index + 1
	self.listview_data = MarriageData.Instance:GetHunyanQuestionRankInfo()
	local creel_cell = self.answer_creel_cell_list[cell]
	if creel_cell == nil then
		creel_cell = WeddingAnswerItemRender.New(cell.gameObject)
		self.answer_creel_cell_list[cell] = creel_cell
	end

	creel_cell:SetIndex(data_index)
	creel_cell:SetData(self.listview_data[data_index])
end

function WeddingFuBenView:FulshBtnPosition(param)
	if self.content.gameObject.activeInHierarchy then
		local y = -150
		if param == "to_length" then
			y = -50
		end
		local tween = self.content.rect:DOAnchorPosY(y, 0.5, false)
		tween:SetEase(DG.Tweening.Ease.Linear)
	end
end

function WeddingFuBenView:SwitchButtonState(enable)
	self.show_left_panel:SetValue(enable)
end

function WeddingFuBenView:CloseCallBack()
	if self.show_or_hide_other_button then
		GlobalEventSystem:UnBind(self.show_or_hide_other_button)
		self.show_or_hide_other_button = nil
	end

	if self.chat_hight_change then
		GlobalEventSystem:UnBind(self.chat_hight_change)
		self.chat_hight_change = nil
	end
	if self.time_quest then
		CountDown.Instance:RemoveCountDown(self.time_quest)
		self.time_quest = nil
	end

	for k, v in pairs(self.flower_effect_list) do
		GameObjectPool.Instance:Free(v)
	end
	self.flower_effect_list = {}
	if self.hua_effect then
		local game_obj = self.hua_effect.gameObject
		if not IsNil(game_obj) then
			GameObject.Destroy(game_obj)
		end
		self.hua_effect = nil
	end
end

-- function WeddingFuBenView:OnClickExit()
	-- local func = function()
	-- 	FuBenCtrl.Instance:SendExitFBReq()
	-- end
	-- TipsCtrl.Instance:ShowCommonTip(func, nil, "是否退出婚宴")
	-- print("点击退出按钮 FuBenInfoTowerView")
-- end

function WeddingFuBenView:OnClicBless()
	MarriageCtrl.Instance:SendMarryBless()
end

function WeddingFuBenView:OnClickScatterFlower()
	MarriageCtrl.Instance:SendMarryOpera(GameEnum.HUNYAN_OPERA_TYPE_SAXIANHUA)
end

function WeddingFuBenView:OnClickScatterFlowerBall()
	local func = function ()
		MarriageCtrl.Instance:SendMarryOpera(GameEnum.HUNYAN_OPERA_TYPE_PAOHUAQIU)
	end

	if MarriageData.Instance:IsFreePaoHuaQiu() then
		local price = MarriageData.Instance:GetHuaQiuGold()
		local str = string.format(Language.Marriage.PaoHuaQiu, price)
		TipsCtrl.Instance:ShowCommonAutoView("chongzhi", str, func)
	else
		local str = string.format(Language.Marriage.WeddingCandies)
		local click_func = function ()
			MarriageCtrl.Instance:SendMarryOpera(GameEnum.HUNYAN_OPERA_TYPE_PAOHUAQIU)
		end
		if UnityEngine.PlayerPrefs.GetInt("wedding_candies") == 1 then
			click_func()
		else
			TipsCtrl.Instance:ShowCommonTip(click_func, nil, str, nil, nil, true, false, "wedding_candies")
		end

	end
end

--花球CD
function WeddingFuBenView:HandleHuaQiuCD(start_time)
	--抛花球的CD时间
	local cd_time = self.cd_time_max
	--先把倒计时取消掉
	if self.time_quest then
		CountDown.Instance:RemoveCountDown(self.time_quest)
		self.time_quest = nil
	end

	--判断花球是否可抛
	local server_time = TimeCtrl.Instance:GetServerTime()
	local left_cd_time = (start_time + cd_time) - server_time
	left_cd_time = math.ceil(left_cd_time)
	left_cd_time = left_cd_time > self.cd_time_max and self.cd_time_max or left_cd_time
	if left_cd_time <= 0 then
		self.cd_time:SetValue("")
		self.cd_progress:SetValue(0)
		return
	end
	self.time_quest = CountDown.Instance:AddCountDown(left_cd_time, 1, BindTool.Bind(self.HuaQiuCDTimer, self))

	self.cd_time:SetValue(left_cd_time)
	self.cd_progress:SetValue(left_cd_time / cd_time)
end

--花球CDTimer
function WeddingFuBenView:HuaQiuCDTimer(elapse_time, total_time)
	local left_time = total_time - elapse_time
	left_time = math.ceil(left_time)
	left_time = left_time > self.cd_time_max and self.cd_time_max or left_time
	if left_time <= 0 then
		if self.time_quest then
			CountDown.Instance:RemoveCountDown(self.time_quest)
			self.time_quest = nil
		end
		self.cd_time:SetValue("")
		self.cd_progress:SetValue(0)
		return
	end

	self.cd_time:SetValue(left_time)
	self.cd_progress:SetValue(left_time / self.cd_time_max)
end

function WeddingFuBenView:FlushView()
	--注意:data可能为空
	local data = MarriageData.Instance:GetWeddingInfo()
	if not next(data) then
		return
	end
	-- self:AddFlowerEffect()

	if data.is_self_hunyan == 1 and data.paohuoqiu_timestmp > 0 then
		self:HandleHuaQiuCD(data.paohuoqiu_timestmp)
	else
		self.cd_time:SetValue("")
		self.cd_progress:SetValue(0)
	end
	self.yanhui_type = data.yanhui_type
	self.remainder_eat_times = data.remainder_eat_food_num
	local cfg = MarriageData.Instance:GetWeddingCfgByType(self.yanhui_type)
	local activity_cfg = MarriageData.Instance:GetActivityCfg()
	local paohuoqiu_times = MarriageData.Instance:GetPaohuoqiu_times()
	if self.yanhui_type == 1 then
		self.wedding_name2:SetValue(cfg.marry_name)
		self.is_show_wedding_title:SetValue(true)
		local times = activity_cfg.paohuaqiu_free_times_1 - paohuoqiu_times
		self.collect_time_text:SetValue(times >= 0 and times or 0)
	else
		self.wedding_name:SetValue(cfg.marry_name)
		self.is_show_wedding_title:SetValue(false)

		local times_2 = activity_cfg.paohuaqiu_free_times_2 - paohuoqiu_times
		self.collect_time_text:SetValue(times_2 >= 0 and times_2 or 0)
	end
	self.can_pao_hua:SetValue(true)
	
	self.free_time_text:SetValue(data.guest_bless_free_times)
	self.left_times:SetValue(self.remainder_eat_times)

	self:FlushHunyanRenQiValue()
end

function WeddingFuBenView:OnFlush(param_t)
	if param_t.sahua then
		self:AddFlowerEffect()
	elseif param_t.role_info then
		self:FlushReDu()
		self:FlushBtnState()
		self:FlushMarryUseList()
		self:FlushView()
	end
	for k,v in pairs(param_t) do
		if k == "answer_rank" then
			if self.creel_list.scroller.isActiveAndEnabled then
				self.creel_list.scroller:ReloadData(0)
			end
		end
	end
	self:FlushView()
end

--添加撒花特效
function WeddingFuBenView:AddFlowerEffect()
	local count = 0
	for k, v in pairs(self.flower_effect_list) do
		count = count + 1
	end
	--大过三个忽略
	if count >= 3 then
		return
	end

	if not self.hua_effect then
		self.hua_effect = U3DObject(GameObject.New())
		local asset_name = Scene.Instance:GetSceneAssetName()
		local scene = UnityEngine.SceneManagement.SceneManager.GetSceneByName(asset_name .. "_Detail")
		local objects = UnityEngine.SceneManagement.Scene.GetRootGameObjects(scene)

		local effects = objects:ToTable()[1].transform:GetChild(1)
		self.hua_effect.transform:SetParent(effects.transform, false)
		self.hua_effect.transform.localPosition = Vector3(245, 263, 50)				--暂时写死特效的位置
	end

	GameObjectPool.Instance:SpawnAsset("effects2/prefab/ui/zc01_hua_1_prefab", "Zc01_hua_1", function (obj)
		if nil == obj then
			return
		end
		obj.transform:SetParent(self.hua_effect.transform, false)
		self.flower_effect_list[obj] = obj

		GlobalTimerQuest:AddDelayTimer(function()
			self.flower_effect_list[obj] = nil
			GameObjectPool.Instance:Free(obj)
		end, EFFECT_TIME)
	end)
end

function WeddingFuBenView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	if item_id == PUTONG_YANHUA_ITEM_ID or item_id == GAOJI_YANHUA_ITEM_ID then
		self:FlushItemInfo()
	end
end

function WeddingFuBenView:FlushHunyanRenQiValue()
	local renqi_value = MarriageData.Instance:GetHunyanRenQiValueInfo()
	self.renqi_value:SetValue(renqi_value)
end

function WeddingFuBenView:FlushReDu()
	local wedding_role_info = MarriageData.Instance:GetWeddingRoleInfo()
	if next(wedding_role_info) then
		local redu_cfg = MarriageData.Instance:GetHunYanCfgByReDu(wedding_role_info.wedding_liveness)

		local percent = 0
		if wedding_role_info.wedding_liveness <= redu_cfg.liveness_var then
			percent = wedding_role_info.wedding_liveness / redu_cfg.liveness_var	
		else
			percent = 100
		end
		self.exp_radio:SetValue(percent)
		self.exp_text:SetValue(wedding_role_info.wedding_liveness .. "/" .. redu_cfg.liveness_var)

		self.add_exp:SetValue(CommonDataManager.ConverNum(wedding_role_info.total_exp))
	end
end

function WeddingFuBenView:FlushItemInfo()
	local item_num_str1 = ""
	local item_num_str2 = ""
	local item_num1 = ItemData.Instance:GetItemNumInBagById(PUTONG_YANHUA_ITEM_ID)
	local item_num2 = ItemData.Instance:GetItemNumInBagById(GAOJI_YANHUA_ITEM_ID)
	if item_num1 < 1 then
		self.btn_text[1]:SetValue(Language.Marriage.TextBuy)
		item_num_str1 = ToColorStr(item_num1 .. "/", TEXT_COLOR.RED) .. "1"
	else
		self.btn_text[1]:SetValue(Language.Marriage.TextUse)
		item_num_str1 = ToColorStr(item_num1 .. "/", TEXT_COLOR.GREEN) .. "1"
	end
	if item_num2 < 1 then
		self.btn_text[2]:SetValue(Language.Marriage.TextBuy)
		item_num_str2 = ToColorStr(item_num2 .. "/", TEXT_COLOR.RED) .. "1"
	else
		self.btn_text[2]:SetValue(Language.Marriage.TextUse)
		item_num_str2 = ToColorStr(item_num2 .. "/", TEXT_COLOR.GREEN) .. "1"
	end
	self.item_num[1]:SetValue(item_num_str1)
	self.item_num[2]:SetValue(item_num_str2)
end

function WeddingFuBenView:FlushBtnState()
	local cur_wedding_info = MarriageData.Instance:GetCurWeddingInfo()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local wedding_role_info = MarriageData.Instance:GetWeddingRoleInfo()
	if main_role_vo.role_id == cur_wedding_info.marryuser_list[1].marry_uid or main_role_vo.role_id == cur_wedding_info.marryuser_list[2].marry_uid then
		self.btn_baitang_gray:SetValue(wedding_role_info.is_baitang ~= 2)
		self.btn_baitang.toggle.interactable = wedding_role_info.is_baitang ~= 2
		self.btn_xitang_gray:SetValue(true)
		self.btn_xitang.toggle.interactable = true
	else
		self.btn_baitang_gray:SetValue(false)
		self.btn_baitang.toggle.interactable = false
		self.btn_xitang_gray:SetValue(false)
		self.btn_xitang.toggle.interactable = false
	end
end

function WeddingFuBenView:FlushMarryUseList()
	local marryuser_list = MarriageData.Instance:GetMarryUserList()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	--婚宴名
	local name_text = ""
	local is_marrier = false
	
	for k,v in pairs(marryuser_list) do
		if name_text == "" and v.marry_name ~= "" then
			name_text = ToColorStr(v.marry_name, TEXT_COLOR.YELLOW)
		elseif v.marry_name ~= "" then
			name_text = name_text.. Language.Marriage.AndDes ..ToColorStr(v.marry_name, TEXT_COLOR.YELLOW)
		end
		if v.marry_uid == main_role_vo.role_id then
			is_marrier = true
		end
	end
	self.is_marrier_view:SetValue(is_marrier)
	self.banner_marrier_name:SetValue(name_text)
end

-- 打开宾客祝福面板
function WeddingFuBenView:OnBtnHeCiHandler()
	self.is_open_notice:SetValue(true)
	self.edit_text.input_field.text = ""
end

-- 关闭宾客祝福面板
function WeddingFuBenView:OnCloseNoticeHandler()
	self.is_open_notice:SetValue(false)
end

-- 发送按钮
function WeddingFuBenView:OnPublishNoticeHandler()
	if self.edit_text.input_field.text == "" then
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.ContentNotNull)
		return
	-- elseif ChatFilter.Instance:IsIllegal(self.edit_text.input_field.text) then
	-- 	SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.ContentIsIllegal)
	-- 	return
	end
	local activity_cfg = MarriageData.Instance:GetActivityCfg()

	local data = MarriageData.Instance:GetWeddingInfo()
	if not next(data) then
		return
	end

	local ok_fun = function ()
		self:SendBless()
	end
	if data.guest_bless_free_times == 0 then
		if UnityEngine.PlayerPrefs.GetInt("show_danmu") == 1 then
			self:SendBless()
		else
			TipsCtrl.Instance:ShowCommonTip(ok_fun, nil, string.format(Language.Marriage.GuestBlessingTip,activity_cfg.guest_bless_need_gold), nil, nil, true, false, "show_danmu")
		end
	else
		self:SendBless()
	end
end

function WeddingFuBenView:SendBless()
	local str_len = string.len(self.edit_text.input_field.text)
	local text = ChatFilter.Instance:Filter(self.edit_text.input_field.text)
	MarriageCtrl.Instance:SendMarryOpera(GameEnum.HUNYAN_OPERA_GUEST_BLESS, str_len, 0, text)
	self.is_open_notice:SetValue(false)
end

function WeddingFuBenView:ChangeDanMuRes()
	if self.is_open_danmu then
		local bundle, asset = ResPath.GetMarryImage("close_danmu")
		self.danmu_res:SetAsset(bundle, asset)
	else
		local bundle, asset = ResPath.GetMarryImage("open_danmu")
		self.danmu_res:SetAsset(bundle, asset)
	end
end

function WeddingFuBenView:OnBtnDanMuHandler()
	self.is_open_danmu = not self.is_open_danmu
	self:ChangeDanMuRes()

	if not self.is_open_danmu then
		if RollingBarrageCtrl.Instance.view:IsOpen() then
			RollingBarrageCtrl.Instance.view:Close()
		end
	end
end

function WeddingFuBenView:GetIsOpenDanMu()
	return self.is_open_danmu
end

function WeddingFuBenView:OnBtnBaiTangHandler()
	MarriageCtrl.Instance:SendMarryOpera(GameEnum.HUNYAN_OPERA_TYPE_BAITANG_REQ)
end

function WeddingFuBenView:OnBtnSongFuHandler()
	ViewManager.Instance:Open(ViewName.WeddingBlessing)
end

function WeddingFuBenView:OnBtnGuestManageHandler()
	ViewManager.Instance:Open(ViewName.WeddingInviteView)
end

function WeddingFuBenView:OnBtnChuJiYanHuaHandler()
	local is_enough = ItemData.Instance:GetItemNumIsEnough(PUTONG_YANHUA_ITEM_ID, 1)
	if is_enough then
		local item_index = ItemData.Instance:GetItemIndex(PUTONG_YANHUA_ITEM_ID)
		PackageCtrl.Instance:SendUseItem(item_index)
	else
		if self.is_auto_buy_chuji then
			MarketCtrl.Instance:SendShopBuy(PUTONG_YANHUA_ITEM_ID, 1, 0, 0)
			return
		end
		local func = function(item_id2, item_num, is_bind, is_use, is_buy_quick)
			MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, is_use)
			if is_buy_quick then
				self.is_auto_buy_chuji = is_buy_quick
			end
		end
		TipsCtrl.Instance:ShowCommonBuyView(func, PUTONG_YANHUA_ITEM_ID, nil, 1)
	end
end

function WeddingFuBenView:OnBtnGaoJiYanHuaHandler()
	local is_enough = ItemData.Instance:GetItemNumIsEnough(GAOJI_YANHUA_ITEM_ID, 1)
	if is_enough then
		local item_index = ItemData.Instance:GetItemIndex(GAOJI_YANHUA_ITEM_ID)
		PackageCtrl.Instance:SendUseItem(item_index)
	else
		if self.is_auto_buy_gaoji then
			MarketCtrl.Instance:SendShopBuy(GAOJI_YANHUA_ITEM_ID, 1, 0, 0)
			return
		end
		local func = function(item_id2, item_num, is_bind, is_use, is_buy_quick)
			MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, is_use)
			if is_buy_quick then
				self.is_auto_buy_gaoji = is_buy_quick
			end
		end
		TipsCtrl.Instance:ShowCommonBuyView(func, GAOJI_YANHUA_ITEM_ID, nil, 1)
	end
end

function WeddingFuBenView:OnBtnSeekNPC()
	local user_info, question_list = MarriageData.Instance:GetHunyanQuestionUserInfo()
	if question_list[user_info.cur_question_idx + 1] then
		local npc_id = MarriageData.Instance:GetQuestionNpc(user_info.cur_question_idx + 1)
		local pos = MarriageData.Instance:GetQuestionNpcPos(question_list[user_info.cur_question_idx + 1].npc_pos_seq)
		MoveCache.end_type = MoveEndType.NpcTask
		MoveCache.param1 = npc_id
		GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), pos.pos_x, pos.pos_y, 1, 1, false)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.AchieveQuestion)
	end
end

----------------------------------------------------------------------------
--WeddingAnswerItemRender	答题排行面板
----------------------------------------------------------------------------
WeddingAnswerItemRender = WeddingAnswerItemRender or BaseClass(BaseCell)
function WeddingAnswerItemRender:__init()
	self.rank = self:FindVariable("wedding_rank")
	self.rank_icon = self:FindVariable("rank_icon")
	self.name = self:FindVariable("wedding_name")
	self.score = self:FindVariable("wedding_score")
end

function WeddingAnswerItemRender:__delete()
	
end

function WeddingAnswerItemRender:OnFlush()
	if self.data == nil and next(self.data) == nil then return end
	self.rank:SetValue(self.data.rank)
	self.name:SetValue(self.data.name)
	self.score:SetValue(self.data.score)
	if self.data.rank <= 3 and self.data.rank > 0 then
		local bundle, asset = ResPath.GetRankIcon(self.data.rank)
		self.rank_icon:SetAsset(bundle, asset)
	end
end