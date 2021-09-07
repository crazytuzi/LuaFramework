JuBaoPenView = JuBaoPenView or BaseClass(BaseView)

function JuBaoPenView:__init()
	self.ui_config = {"uis/views/jubaopen", "JuBaoPenView"}
	self.play_audio = true
	self:SetMaskBg()
end

function JuBaoPenView:__delete()

end

function JuBaoPenView:LoadCallBack()
	self.is_rolling = false
	self:ListenEvent("ClickRoll", BindTool.Bind(self.ClickRoll, self))
	self:ListenEvent("Close", BindTool.Bind(self.Close, self))
	self:ListenEvent("AddGold", BindTool.Bind(self.HandleAddGold, self))
	self.price = self:FindVariable("Price")
	self.cur_charge = self:FindVariable("CurCharge")
	self.total_charge = self:FindVariable("TotalCharge")
	self.day = self:FindVariable("Day")
	self.hour = self:FindVariable("Hour")
	self.minute = self:FindVariable("Minute")
	self.gold = self:FindVariable("Gold")
	self.max_gold = self:FindVariable("MaxGold")
	self.need_charge = self:FindVariable("NeedCharge")
	self.have_record = self:FindVariable("HaveRecord")
	self.is_gray = self:FindVariable("IsGray")
	self.player_data_change = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.player_data_change)
	self:InitScroller()
	self.scroller_list = {}
	for i = 1, 5 do
		self.scroller_list[i] = {}
		self.scroller_list[i].obj = self:FindObj("Scroller" .. i)
		self.scroller_list[i].cell = JuBaoPenScroller.New(self.scroller_list[i].obj)
		self.scroller_list[i].cell:SetIndex(i)
		self.scroller_list[i].cell:SetCallBack(BindTool.Bind(self.RollComplete, self))
	end
	-- self.roll_bar_anim = self:FindObj("RollBar"):GetComponent(typeof(UnityEngine.Animator))
	self.need_anim_back = false
	self.can_roll = false
	self.complete_list = {}
end

function JuBaoPenView:ReleaseCallBack()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	if self.player_data_change then
		PlayerData.Instance:UnlistenerAttrChange(self.player_data_change)
		self.player_data_change = nil
	end
	for k,v in pairs(self.scroller_list) do
		v.cell:DeleteMe()
	end

	if self.is_rolling then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CORNUCOPIA, RA_CORNUCOPIA_OPERA_TYPE.RA_CORNUCOPIA_OPERA_TYPE_FETCH_REWARD_INFO)
	end
	self.scroller_list = {}
	self.cell_list = {}
	self.price = nil
	self.cur_charge = nil
	self.total_charge = nil
	self.reward_scroller = nil
	self.list_view_delegate = nil
	self.day = nil
	self.hour = nil
	self.minute = nil
	self.gold = nil
	-- self.roll_bar_anim = nil
	self.max_gold = nil
	self.need_charge = nil
	self.is_gray = nil
	self.have_record = nil
end

function JuBaoPenView:OpenCallBack()
	self:FlushPrice()
	self:FlushCharge()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CORNUCOPIA, RA_CORNUCOPIA_OPERA_TYPE.RA_CORNUCOPIA_OPERA_TYPE_QUERY_INFO)
	self:FlushRestTime()
	self:RemoveCountDown()
	self.count_down = CountDown.Instance:AddCountDown(99999999, 1, BindTool.Bind(self.FlushRestTime, self))
	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	JuBaoPenData.Instance:SetFirstOpen(false)
	RemindManager.Instance:Fire(RemindName.JuBaoPen)
	if self.need_anim_back then
		-- self.roll_bar_anim:SetTrigger("Back")
		self.need_anim_back = false
	end
end

function JuBaoPenView:CloseCallBack()
	self:RemoveCountDown()
end

function JuBaoPenView:HandleAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function JuBaoPenView:PlayerDataChangeCallback(attr_name, value, old_value)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if attr_name == "gold" then
		local count = vo.gold
		self.gold:SetValue(CommonDataManager.ConverMoney(count))
	end
end

function JuBaoPenView:ClickRoll()
	if self.is_rolling then
		return
	end
	if self.can_roll then
		self.is_rolling = true
	end
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CORNUCOPIA, RA_CORNUCOPIA_OPERA_TYPE.RA_CORNUCOPIA_OPERA_TYPE_FETCH_REWARD)
end

function JuBaoPenView:FlushPrice()
	local cur_lun = JuBaoPenData.Instance:GetRewardLun()
	local max_lun = JuBaoPenData.Instance:GetMaxLun()
	local price, max_gold = JuBaoPenData.Instance:GetNeedChargeByLun(cur_lun)
	self.price:SetValue(price)
	self.max_gold:SetValue(max_gold)
	self.is_gray:SetValue(cur_lun > max_lun)
	local record_list = JuBaoPenData.Instance:GetRecordList()
	if #record_list == 0 then
		self.have_record:SetValue(true)
	else
		self.have_record:SetValue(false)
	end
end

-- 刷新当前充值金额
function JuBaoPenView:FlushCharge()
	local history_chongzhi = JuBaoPenData.Instance:GetHistoryChongZhi() or 0
	local cur_lun = JuBaoPenData.Instance:GetRewardLun()
	local price = JuBaoPenData.Instance:GetNeedChargeByLun(cur_lun)
	local color = TEXT_COLOR.WHITE
	if history_chongzhi < price then
		color = TEXT_COLOR.RED
	end
	self.cur_charge:SetValue(ToColorStr(CommonDataManager.ConverMoney(history_chongzhi), color))
	local need_put_gold = JuBaoPenData.Instance:GetNeedPutGold(cur_lun)
	self.total_charge:SetValue(CommonDataManager.ConverMoney(need_put_gold))
	if need_put_gold == 0 then
		self.total_charge:SetValue(Language.Common.IsAllGet)
	end
	local need_charge = price - history_chongzhi
	need_charge = math.max(0, need_charge)
	if need_charge > 0 then
		self.can_roll = false
		--self.need_charge:SetValue(CommonDataManager.ConverMoney(need_charge))
		self.need_charge:SetValue(string.format(Language.JuBaoPen.CanRollText, CommonDataManager.ConverMoney(need_charge)))
	else
		self.can_roll = true
		self.need_charge:SetValue(string.format(Language.JuBaoPen.ChargeText, CommonDataManager.ConverMoney(need_put_gold)))
	end
	if self.reward_scroller.scroller.isActiveAndEnabled then
		self.reward_scroller.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function JuBaoPenView:StartRoll(reward_gold)
	local num_list = {}
	while (reward_gold > 0) do
		table.insert(num_list, math.floor(reward_gold % 10))
		reward_gold = math.floor(reward_gold / 10)
	end
	for i = 1, 5 do
		local num = num_list[i] or 0
		num = num + 1
		self.scroller_list[5 - i + 1].cell:StartScoller(2 + 0.5 * i, num, 129 + 10 * i)
	end
	-- self.roll_bar_anim:SetTrigger("Roll")
end

function JuBaoPenView:OnFlush(param_list)
	self:FlushPrice()
	for k,v in pairs(param_list) do
		if k == "roll" then
			self:StartRoll(v[1])
		elseif k == "charge" then
			self:FlushCharge()
		end
	end
end

function JuBaoPenView:FlushRestTime()
	local rest_time = 0
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CORNUCOPIA) then
		rest_time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CORNUCOPIA) or 0
	end
	if rest_time <= 0 then
		self.day:SetValue(0)
		self.hour:SetValue(0)
		self.minute:SetValue(0)
		self:RemoveCountDown()
		return
	end
	local time_tab = TimeUtil.Format2TableDHM(rest_time)
	if time_tab then
		self.day:SetValue(time_tab.day)
		self.hour:SetValue(time_tab.hour)
		self.minute:SetValue(time_tab.min)
	end
end

function JuBaoPenView:RemoveCountDown()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function JuBaoPenView:InitScroller()
	self.reward_scroller = self:FindObj("RewardScroller")
	self.cell_list = {}
	self.list_view_delegate = self.reward_scroller.list_simple_delegate
	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
end

function JuBaoPenView:GetNumberOfCells()
	local record_list = JuBaoPenData.Instance:GetRecordList()
	return #record_list
end

function JuBaoPenView:RefreshView(cell, data_index)
	local group_cell = self.cell_list[cell]
	if group_cell == nil then
		group_cell = JuBaoPenRecordInfo.New(cell.gameObject)
		self.cell_list[cell] = group_cell
	end
	local record_list = JuBaoPenData.Instance:GetRecordList()
	local data = record_list[data_index + 1]
	group_cell:SetData(data)
end

-- 转动完毕回调
function JuBaoPenView:RollComplete(index)
	self.complete_list[index] = true
	if self:CheckComplete() then
		self.is_rolling = false
		self.complete_list = {}
		-- self.roll_bar_anim:SetTrigger("Back")
		if not self.is_real_open then
			self.need_anim_back = true
		end
		-- 动画播完后通知服务端下发奖励
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CORNUCOPIA, RA_CORNUCOPIA_OPERA_TYPE.RA_CORNUCOPIA_OPERA_TYPE_FETCH_REWARD_INFO)
	end
end

-- 检查转盘是否全部滚动完毕
function JuBaoPenView:CheckComplete()
	local flag = true
	for i = 1, 5 do
		if not self.complete_list[i] then
			flag = false
			break
		end
	end
	return flag
end
------------------------------------------JuBaoPenScroller--------------------------------------------

JuBaoPenScroller = JuBaoPenScroller or BaseClass(BaseCell)

local IconCount = 10
-- 每个格子的高度
local cell_hight = 50
-- 每个格子之间的间距
local distance = 10

function JuBaoPenScroller:__init(instance)
	if instance == nil then
		return
	end
	local size = cell_hight + distance
	self.rect = self:FindObj("Rect")
	self.do_tween_obj = self:FindObj("DoTween")
	self.do_tween_obj.transform.position = Vector3(0, 0, 0)
	local original_hight = self.root_node.rect.sizeDelta.y
	-- 格子起始间距
	local offset = -60
	local hight = (IconCount + 2) * size + (cell_hight - offset * 2)
	self.percent = size / (hight - original_hight)
	self.rect.rect.sizeDelta = Vector2(self.rect.rect.sizeDelta.x, hight)
	self.scroller_rect = self.root_node:GetComponent(typeof(UnityEngine.UI.ScrollRect))
	self.scroller_rect.onValueChanged:AddListener(BindTool.Bind(self.OnValueChange, self))

	PrefabPool.Instance:Load(AssetID("uis/views/jubaopen_prefab", "Icon"), function(prefab)
        if nil == prefab then
            return
        end
        for i = 0, IconCount + 3 do
            local obj = U3DObject(GameObject.Instantiate(prefab))
            local obj_transform = obj.transform
            obj_transform:SetParent(self.rect.transform, false)
            obj_transform.localPosition = Vector3(0, -(i - 1) * size + offset, 0)
            local res_id = i - 1
            if res_id > IconCount then
            	res_id = res_id % IconCount
            end
            if i == 0 then
            	res_id = 9
            end
            if res_id == 0 then
            	res_id = IconCount
            end
            obj:GetComponent(typeof(UIVariableTable)):FindVariable("Icon"):SetAsset(ResPath.GetJuBaoPenIcon(res_id))
        end

        PrefabPool.Instance:Free(prefab)
    end)
    self.target_x = 0
    self.target = 1
end

function JuBaoPenScroller:__delete()
	self:RemoveCountDown()
end

function JuBaoPenScroller:OnValueChange(value)
	local x = value.y
end

function JuBaoPenScroller:StartScoller(time, target, movement_distance)
	self.do_tween_obj.transform.position = Vector3(self.target -1, 0, 0)
	self.target = target or 1
	if self.target == 1 then
		self.target = IconCount + 1
	end
	self:RemoveCountDown()
	self.target_x = movement_distance + self.target
	local tween = self.do_tween_obj.transform:DOMoveX(movement_distance + self.target, time)
	tween:SetEase(DG.Tweening.Ease.InOutExpo)
	self.count_down = CountDown.Instance:AddCountDown(time, 0.01, BindTool.Bind(self.UpdateTime, self))
end

function JuBaoPenScroller:UpdateTime(elapse_time, total_time)
	local value = self:IndexToValue(self.do_tween_obj.transform.position.x % 10)
	self.scroller_rect.normalizedPosition = Vector2(1, value)
	if elapse_time >= total_time then
		value = self:IndexToValue(self.target_x % 10)
		self.scroller_rect.normalizedPosition = Vector2(1, value)
		if self.call_back then
			self.call_back(self.index)
		end
	end
end

function JuBaoPenScroller:IndexToValue(index)
	return 1 - (self.percent * index % 1)
end

function JuBaoPenScroller:SetCallBack(call_back)
	self.call_back = call_back
end

function JuBaoPenScroller:RemoveCountDown()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

------------------------------------------JuBaoPenRecordInfo--------------------------------------------

JuBaoPenRecordInfo = JuBaoPenRecordInfo or BaseClass(BaseCell)

function JuBaoPenRecordInfo:__init()
	self.name = self:FindVariable("Name")
	self.rate = self:FindVariable("Rate")
	self.cost = self:FindVariable("Cost")
end

function JuBaoPenRecordInfo:__delete()

end

function JuBaoPenRecordInfo:OnFlush()
	if self.data then
		self.cost:SetValue(self.data.need_put_gold)
		self.rate:SetValue(self.data.reward_rate)
		self.name:SetValue(self.data.user_name)
	end
end
