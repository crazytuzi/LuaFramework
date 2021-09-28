ErnieView = ErnieView or BaseClass(BaseView)

local IconCount = 5

function ErnieView:__init()
	self.ui_config = {"uis/views/ernieview_prefab", "ErnieView"}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
end

function ErnieView:LoadCallBack()
	self:InitScroller()

	self:ListenEvent("Close", BindTool.Bind(self.Close, self))
	self:ListenEvent("ClickRollOnce", BindTool.Bind(self.ClickRollOnce, self))
	self:ListenEvent("ClickRollTen", BindTool.Bind(self.ClickRollTen, self))
	self:ListenEvent("ClickSkip", BindTool.Bind(self.ClickSkip, self))
	self:ListenEvent("ClickHelp", BindTool.Bind(self.ClickHelp, self))

	self.skip_toggle = self:FindObj("SkipToggle")
	self.roll_bar_anim = self:FindObj("RollBar"):GetComponent(typeof(UnityEngine.Animator))

	self.price_once = self:FindVariable("PriceOnce")
	self.price_ten = self:FindVariable("PriceTen")
	self.show_free = self:FindVariable("ShowFree")
	self.free_time = self:FindVariable("FreeTime")


	self.complete_list = {}
	self.is_rolling = false
	self.box_index = 1
	self.info_list = {}
	self.has_set_trigger = false
	self.need_anim_back = false
	self.skip_toggle.toggle.isOn = ShengXiaoData.Instance:GetErnieIsStopPlayAni()
	self.price = 0
	local other_cfg = ShengXiaoData.Instance:GetOtherCfg()
	if other_cfg then
		self.price = other_cfg.ggl_consume_gold or 0
		self.price_once:SetValue(self.price)
		self.price_ten:SetValue(self.price * 10)
	end
	self:FlushTime()
	self.isRollTen = false
end

function ErnieView:OpenCallBack()
	if self.need_anim_back then
		self.roll_bar_anim:SetTrigger("Back")
		self.need_anim_back = false
	end
	self:FlushShowFree()
end

function ErnieView:CloseCallBack()
	TipsCtrl.Instance:DestroyFlyEffectByViewName(ViewName.ErnieView)
end

function ErnieView:ReleaseCallBack()
	for k,v in pairs(self.scroller_list) do
		v.cell:DeleteMe()
	end
	self.scroller_list = {}

	self.skip_toggle = nil
	self.roll_bar_anim = nil
	self.price_once = nil
	self.price_ten = nil
	self.show_free = nil
	self.free_time = nil

	if self.is_rolling then
		if ItemData.Instance then
			ItemData.Instance:HandleDelayNoticeNow(PUT_REASON_TYPE.PUT_REASON_ZODIAC_GGL_REWARD)
		end
	end
	self:RemoveCountDown()
end

-- 转一次
function ErnieView:ClickRollOnce()
	local flag = ShengXiaoData.Instance:IsErnieCanFree()
	if not flag then
		local gold_enough = self:IsGoldEnough(1)
		if gold_enough then return end
	end
	if self.is_rolling then
		return
	end
	self.isRollTen = false
 	self.is_rolling = true
 	ShengXiaoCtrl.Instance:SendTianxiangReq(CS_TIAN_XIANG_TYPE.CS_TIAN_XIANG_TYPE_GUNGUN_LE_REQ, 0)
end

-- 转十次
function ErnieView:ClickRollTen()
	local gold_enough = self:IsGoldEnough(10)
	if gold_enough then return end
	if self.is_rolling then
		return
	end
	self.isRollTen = true
	self.is_rolling = true
	ShengXiaoCtrl.Instance:SendTianxiangReq(CS_TIAN_XIANG_TYPE.CS_TIAN_XIANG_TYPE_GUNGUN_LE_REQ, 1)
end

function ErnieView:IsGoldEnough(num)
	if self.price == 0 then return false end
	local has_gold = PlayerData.Instance:GetRoleVo().gold
	local num = num or 1
	local need_gold = self.price * num
	if has_gold < need_gold then
		TipsCtrl.Instance:ShowLackDiamondView()
		return true
	end
	return false
end

-- 是否屏蔽动画
function ErnieView:ClickSkip(switch)
	ShengXiaoData.Instance:SetErnieIsStopPlayAni(switch)
	self.skip_toggle.toggle.isOn = switch
end

function ErnieView:InitScroller()
	self.scroller_list = {}
	for i = 1, 3 do
		self.scroller_list[i] = {}
		self.scroller_list[i].obj = self:FindObj("Scroller" .. i)
		self.scroller_list[i].cell = ErnieScroller.New(self.scroller_list[i].obj)
		self.scroller_list[i].cell:SetIndex(i)
		self.scroller_list[i].cell:SetCallBack(BindTool.Bind(self.EffectComplete, self))
	end
end

-- -- 转动完毕回调
-- function ErnieView:RollComplete(index)
-- 	self.complete_list[index] = true
-- 	if self:CheckComplete() then
-- 		self.complete_list = {}
-- 		if self.is_real_open then
-- 			for i = 1, 3 do
-- 				TipsCtrl.Instance:ShowFlyEffectManager(ViewName.ErnieView, "effects/prefabs", "UI_guangdian1", self.scroller_list[i].obj , self.box_list[self.box_index].obj,
-- 					nil, 1, BindTool.Bind(self.EffectComplete, self, i))
-- 			end
-- 		else
-- 			self:ShowReward()
-- 		end
-- 	end
-- end

-- 特效播放完毕回调
function ErnieView:EffectComplete(index)
	self.complete_list[index] = true
	if self:CheckComplete() then
		self.complete_list = {}
		self:ShowReward()
	end
end

-- 显示奖励面板
function ErnieView:ShowReward()
	if self.has_set_trigger then
		self.roll_bar_anim:SetTrigger("Back")
		self.has_set_trigger = false
		if not self.is_real_open then
			self.need_anim_back = true
		end
	end
	self.is_rolling = false
	-- 如果直接调用，由于数据是一条条发过来的，无法得知数据结束点，如果数据未结束就调用，则会造成显示错误，
	-- 暂时以延时方式解决此问题
	GlobalTimerQuest:AddDelayTimer(function ()
		ItemData.Instance:HandleDelayNoticeNow(PUT_REASON_TYPE.PUT_REASON_ZODIAC_GGL_REWARD)
	end,0.5)
	if self.is_real_open then
		if #self.info_list <= 1 then
			TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_ERNIE_BLESS_MODE_1)
		else
			TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_ERNIE_BLESS_MODE_10)
		end
	end
end

-- 检查转盘是否全部滚动完毕
function ErnieView:CheckComplete()
	local flag = true
	for i = 1, 3 do
		if not self.complete_list[i] then
			flag = false
			break
		end
	end
	return flag
end

function ErnieView:OnFlush(param)
	for k,v in pairs(param) do
		if k == "combine_type" then
			self:StartRoll(v)
		end
	end
	self:FlushTime()
	self:FlushShowFree()
end

-- 开始转动
function ErnieView:StartRoll(info_list)
	self.info_list = info_list
	-- 直接显示结果
	if self.skip_toggle.toggle.isOn or self.isRollTen then  --转10次不播放动画
		self:ShowReward()
	else
		self.is_rolling = true
		local index1 = 1
		local index2 = 1
		local index3 = 1
		self.box_index = 1
		local first_combine_type = info_list[1]
		if first_combine_type then
			local cfg = ShengXiaoData.Instance:GetRollInfoByType(first_combine_type)
			if cfg then
				self.box_index = cfg.box_index
			end
			index1 = first_combine_type % 10 + 1
			first_combine_type = math.floor(first_combine_type / 10)
			index2 = first_combine_type % 10 + 1
			first_combine_type = math.floor(first_combine_type / 10)
			index3 = first_combine_type + 1
		end
		self.scroller_list[1].cell:StartScoller(3, index1)
		self.scroller_list[2].cell:StartScoller(4, index2)
		self.scroller_list[3].cell:StartScoller(5, index3)
		self.roll_bar_anim:SetTrigger("Roll")
		self.has_set_trigger = true
		self.complete_list = {}
	end
end

function ErnieView:ClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(171)
end

function ErnieView:FlushTime()
	self:RemoveCountDown()
	--self.free_time:SetValue("")
	local rest_free_count = ShengXiaoData.Instance:GetRestFreeCount()	--获取当天剩余免费次数
	if rest_free_count > 0 then
		local rest_time = ShengXiaoData.Instance:GetNextFreeErnieTime() - TimeCtrl.Instance:GetServerTime()
		if rest_time > 0 then
			self:UpdateTime()
			self.count_down = CountDown.Instance:AddCountDown(rest_time + 1, 0.5, BindTool.Bind(self.UpdateTime, self))
		end
	else
		local rest_time = self:NowDaytimeEnd(TimeCtrl.Instance:GetServerTime()) - TimeCtrl.Instance:GetServerTime()
		self:UpdateTime2()
		self.count_down2 = CountDown.Instance:AddCountDown(rest_time + 1, 0.5, BindTool.Bind(self.UpdateTime2, self))
	end
end
--根据当前时间，获得当天结束的时间戳
function ErnieView:NowDaytimeEnd(now_time) 
	local tab = os.date("*t", now_time) 
	tab.hour = 0 
	tab.min = 0 
	tab.sec = 0
    local result = tonumber(os.time(tab) + 86400)
    return result
end 
--免费次数大于0且还处于cd中，则用此函数倒数
function ErnieView:UpdateTime()
	local rest_time = ShengXiaoData.Instance:GetNextFreeErnieTime() - TimeCtrl.Instance:GetServerTime()
	local time_str = ""
	if rest_time > 0 then
		time_str = string.format(Language.Treasure.ShowFreeTime, TimeUtil.FormatSecond(rest_time))
	else
		self:FlushShowFree()
	end
	self.free_time:SetValue(time_str)
end
--免费次数为0时，用该函数倒数
function ErnieView:UpdateTime2()
	local rest_time = self:NowDaytimeEnd(TimeCtrl.Instance:GetServerTime()) - TimeCtrl.Instance:GetServerTime()
	local time_str = ""
	if rest_time > 0 then
		time_str = string.format(Language.Treasure.ShowFreeTime, TimeUtil.FormatSecond(rest_time))
	else
		self:FlushShowFree()
	end
	self.free_time:SetValue(time_str)
end

function ErnieView:FlushShowFree()
	local flag = ShengXiaoData.Instance:IsErnieCanFree()
	self.show_free:SetValue(flag)
end

function ErnieView:RemoveCountDown()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
	if self.count_down2 ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down2)
		self.count_down2 = nil
	end
end

-----------------------------------------------Scroller--------------------------------------------

ErnieScroller = ErnieScroller or BaseClass(BaseCell)

-- 每个格子的高度(边长)
local cell_hight = 75
-- 每个格子之间的间距
local distance = 15
-- DoTween移动的距离(越大表示转动速度越快)
local movement_distance = 149

function ErnieScroller:__init(instance)
	if instance == nil then
		return
	end
	local size = cell_hight + distance
	self.rect = self:FindObj("Rect")
	self.do_tween_obj = self:FindObj("DoTween")
	self.do_tween_obj.transform.position = Vector3(0, 0, 0)
	local original_hight = self.root_node.rect.sizeDelta.y
	-- 格子起始间距
	local offset = cell_hight - (original_hight - (cell_hight + 2 * distance)) / 2
	local hight = (IconCount + 2) * size + (cell_hight - offset * 2)
	self.percent = size / (hight - original_hight)
	self.rect.rect.sizeDelta = Vector2(self.rect.rect.sizeDelta.x, hight)
	self.scroller_rect = self.root_node:GetComponent(typeof(UnityEngine.UI.ScrollRect))
	self.scroller_rect.onValueChanged:AddListener(BindTool.Bind(self.OnValueChange, self))

	PrefabPool.Instance:Load(AssetID("uis/views/ernieview_prefab", "Icon"), function(prefab)
        if nil == prefab then
            return
        end
        for i = 1, IconCount + 3 do
            local obj = U3DObject(GameObject.Instantiate(prefab))
            local obj_transform = obj.transform
            obj_transform:SetParent(self.rect.transform, false)
            obj_transform.localPosition = Vector3(0, -(i - 1) * size + offset, 0)
            obj_transform.sizeDelta = Vector2(cell_hight,cell_hight)
            local res_id = i - 1
            if res_id > IconCount then
            	res_id = res_id % IconCount
            end
            if res_id == 0 then
            	res_id = IconCount
            end
            obj:GetComponent(typeof(UIVariableTable)):FindVariable("Icon"):SetAsset(ResPath.GetErnieImage(res_id))
        end

        PrefabPool.Instance:Free(prefab)
    end)
    self.target_x = 0
    self.target = 1
end

function ErnieScroller:__delete()
	self:RemoveCountDown()
end

function ErnieScroller:OnValueChange(value)
	local x = value.y
end

function ErnieScroller:StartScoller(time, target)
	self.do_tween_obj.transform.position = Vector3(self.target - 1, 0, 0)
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

function ErnieScroller:UpdateTime(elapse_time, total_time)
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

function ErnieScroller:IndexToValue(index)
	return 1 - (self.percent * index % 1)
end

function ErnieScroller:SetCallBack(call_back)
	self.call_back = call_back
end

function ErnieScroller:RemoveCountDown()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end
