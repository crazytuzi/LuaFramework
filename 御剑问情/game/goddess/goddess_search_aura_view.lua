require("game/tips/ernie_view")

GoddessSearchAuraView = GoddessSearchAuraView or BaseClass(BaseView)

function GoddessSearchAuraView:__init()
     self.ui_config = {"uis/views/aurasearchview_prefab","GoddessSearchAuraView"}
     self.play_audio = true
     self.is_Rolling = false
     self.ling_count = 0
end

function GoddessSearchAuraView:__delete()
	UnityEngine.PlayerPrefs.DeleteKey("GoddessSearchAuraViewTips")
end

function GoddessSearchAuraView:InitScroller()
	self.scroller_list = {}
	local value_list = GoddessData.Instance:GetAuraSearchListInfo()
	for i = 1, 6 do
		self.scroller_list[i] = {}
		self.scroller_list[i].obj = self:FindObj("Aura_" .. i)
		self.scroller_list[i].cell = AuraScroller.New(self.scroller_list[i].obj)
		self.scroller_list[i].cell:SetIndex(i)
		self.scroller_list[i].cell:SetCallBack(BindTool.Bind(self.RollComplete, self))
		if value_list ~= nil and value_list[i - 1] ~= nil then
			self.scroller_list[i].cell:SetData({index = value_list[i - 1], key = "start"})
		end
	end

	local num = 0
	if value_list ~= nil then
		for k,v in pairs(value_list) do
			if v == 0 then
				num = num + 1
			end
		end
	end
	self:ShowReward(num)
end


function GoddessSearchAuraView:LoadCallBack()
	self:ListenEvent("Close", BindTool.Bind(self.CloseView, self))
	self:ListenEvent("Receive", BindTool.Bind(self.Receive, self))
	self:ListenEvent("Search", BindTool.Bind(self.Roll, self))
    self:ListenEvent("SkipAnimation", BindTool.Bind(self.SkipAnimation, self))
    self:ListenEvent("DoubleReceive", BindTool.Bind(self.DoubleReceive, self))
	self:ListenEvent("EventTip", BindTool.Bind(self.OnClickTip, self))



	self.skip_toggle = self:FindObj("SkipToggle")
	self.double_receive_toggle = self:FindObj("DoubleReceiveToggle")
	self.aura_nums = self:FindVariable("currentAuraNums")
	self.free_times = self:FindVariable("FreeTimes")
	self.shengyu_nums = self:FindVariable("ShengYuNums")
	self.receive_times = self:FindVariable("Receivetimes")
	--self.btn_res = self:FindVariable("SearchImg")
	self.btn_state = self:FindVariable("CanFree")
	self.is_show_consume = self:FindVariable("ShowConsume")
	self.sonsume_value = self:FindVariable("ConsumeValue")

	self.skip_toggle.toggle.isOn = GoddessData.Instance:GetAuraAnimationStatus()
	self.double_receive_toggle.isOn = GoddessData.Instance:GetAuraDoubleReceive()

	self:InitScroller()
end


function GoddessSearchAuraView:OpenCallBack()
    local last_info = GoddessData.Instance:GetAuraSearchListInfo()
    self:FlushFreeTimes()
    self:FlushShengYuNums()
    self:FlushReceivedTime()


	local data = GoddessData.Instance:GetAuraSearchListInfo()
	self.ling_count = 0
	for i = 1, 6 do
		if data[i - 1] == 0 then
			self.ling_count = self.ling_count + 1
		end
	end
    --self:ScrollerRoll(last_info,0.0001)
end

function GoddessSearchAuraView:CloseCallBack()
end

function GoddessSearchAuraView:ReleaseCallBack()
	for k,v in pairs(self.scroller_list) do
		v.cell:DeleteMe()
	end
	self.scroller_list = {}

	self.skip_toggle = nil
	self.double_receive_toggle = nil
	self.aura_nums = nil
	self.shengyu_nums = nil
	self.free_times = nil
	self.receive_times = nil
	self.receive_nums = nil
	--self.btn_res = nil
	self.btn_state = nil
	self.is_show_consume = nil
	self.sonsume_value = nil

	GoddessData.Instance:SetAuraDoubleReceive(false)
end

function GoddessSearchAuraView:SkipAnimation(switch)
	GoddessData.Instance:SetAuraIsPlayAnimation(switch)
end

function GoddessSearchAuraView:CloseView()
     self:Close()
end

function GoddessSearchAuraView:RollComplete(index)
	self.complete_list[index] = true
	if self:CheckIsComplete(6)  then
		self:ShowReward(self.ling_count)
	end
end

function GoddessSearchAuraView:Roll()
	local current_free_time = GoddessData.Instance:GetCurrentFreeTimes() or 0
	if self.receive_nums <= 0 then
		if current_free_time <= 0 then
			TipsCtrl.Instance:ShowSystemMsg(Language.AuraSearch.Warning2)
			return
		end
	end
	if self.is_Rolling or self.ling_count >= 6 then 
		if self.ling_count >= 6 then
			self.is_Rolling = false
			TipsCtrl.Instance:ShowSystemMsg(Language.Goddess.NeedReceiveTip)
		end
		return 
	end

	GoddessCtrl.Instance:SentCSXiannvShengwuReqReq(GODDESS_REQ_TYPE.CHOU_LING, 0, 0, 0)
end

function GoddessSearchAuraView:OnClickTip()
	print_log("sdf")
	TipsCtrl.Instance:ShowHelpTipView(208)
end

function GoddessSearchAuraView:ScrollerRoll(info,time)
	self.ling_count=0
    local animation_time=time or 3

	if self.skip_toggle.toggle.isOn then 
    --  animation_time=0.0001
    	for i = 1, 6 do
	 		if info ~= nil and info[i - 1] ~= nil and self.scroller_list[i] ~= nil then
				self.scroller_list[i].cell:SetData({index = info[i - 1], key = "start"})
				if info[i - 1] == 0 then
					self.ling_count = self.ling_count + 1
				end
			end
    	end

    	self.is_Rolling = false
    	self:ShowReward(self.ling_count)
    	return
    end

    self.is_Rolling=true
    local info_list=info
    for i= 0,5 do

      	info_list[i]=tonumber(info_list[i])+1

    	if not self.skip_toggle.toggle.isOn then
            animation_time=animation_time+(i-1)/5
        end

      	self.scroller_list[i+1].cell:StartScoller(animation_time,info_list[i])

      	if info[i]==1 then 
            self.ling_count=self.ling_count+1
            self.scroller_list[i+1].cell.flag=true
        end  

    end
  
    self.complete_list = {}

 end


function GoddessSearchAuraView:OnFlush(params)
	for k,v in pairs(params) do
		if k=="miling_list" then
			self:ScrollerRoll(v, 0.5)
		elseif k == "reset_eff" then
			self:ResetEff()
			return
		end
	end

	self:FlushFreeTimes()
	self:FlushReceivedTime()
	self:FlushShengYuNums()
end

function GoddessSearchAuraView:ResetEff()
	for i = 1, 6 do
		if self.scroller_list[i] ~= nil then
			self.scroller_list[i].cell:ShowEffect(false)
		end
	end

	local data = GoddessData.Instance:GetAuraSearchListInfo()
	for i = 1, 6 do
		if self.scroller_list[i] ~= nil then
			self.scroller_list[i].cell:ShowEffect(data[i - 1] == 0)
		end
	end
end

function GoddessSearchAuraView:FlushFreeTimes()
	local current_free_time = GoddessData.Instance:GetCurrentFreeTimes() or 0
	if self.free_times ~= nil then
		local str = string.format(Language.Goddess.FreeTimesTip, current_free_time)
		self.free_times:SetValue(current_free_time == 0 and "" or str)
	end

	if self.is_show_consume ~= nil then
		self.is_show_consume:SetValue(current_free_time == 0)
	end

	if self.sonsume_value ~= nil then
		self.sonsume_value:SetValue(GoddessData.Instance:GetAuraSearchConsume())
	end

	if self.btn_state ~= nil then
		self.btn_state:SetValue(current_free_time ~= 0) 
	end
end

function GoddessSearchAuraView:FlushAuraNums(ling_value)
	self.aura_nums:SetValue(ling_value)
end

function GoddessSearchAuraView:FlushShengYuNums()
	--local nums=GoddessData.Instance:GetAuraShengYuNums()
	local value = GoddessData.Instance:GetOtherByStr("double_ling_gold")
	self.shengyu_nums:SetValue(string.format(Language.Goddess.DoubleRewardTip, value or 0))
end

function GoddessSearchAuraView:CheckIsComplete(count)
	local flag = true

    local start=1+self.ling_count

    start=start>6 and 6 or start

	for i=start , count do
		if  not self.complete_list[i]  then
			flag = false
			break
		end
	end

	return flag
end

function GoddessSearchAuraView:ShowReward(nums)
	self.is_Rolling = false
	local ling_value=GoddessData.Instance:GetAuraNumsByLingNums(nums)
	self:FlushAuraNums(ling_value)
end

function GoddessSearchAuraView:Receive()
   

    if self.receive_nums <= 0 then 
    	TipsCtrl.Instance:ShowSystemMsg(Language.AuraSearch.Warning)
    	return
    end 

     if self.is_Rolling then 
		return 
	end

	if self.ling_count==6 then self.is_Rolling = false end
    if GoddessData.Instance:GetAuraDoubleReceive() then 
	 	for i=1,6 do
			self.scroller_list[i].cell.flag=false
		end
        GoddessCtrl.Instance:SentCSXiannvShengwuReqReq(GODDESS_REQ_TYPE.FETCH_LING,1,0,0)
    else
    	local func = function()
			for i=1,6 do
				self.scroller_list[i].cell.flag=false
			end
    	    GoddessCtrl.Instance:SentCSXiannvShengwuReqReq(GODDESS_REQ_TYPE.FETCH_LING,0,0,0)
    	 end
    	TipsCtrl.Instance:ShowCommonTip(func,nil,Language.AuraSearch.Remind1,nil,nil,true,nil,"GoddessSearchAuraViewTips")
    end 
end

function GoddessSearchAuraView:DoubleReceive(switch)
    GoddessData.Instance:SetAuraDoubleReceive(switch)
    self.is_Rolling = false
end

function GoddessSearchAuraView:FlushReceivedTime()
	local nums = GoddessData.Instance:GetAuraSearchReveivedTimes()
	local all_nums = GoddessData.Instance:GetOtherByStr("fetch_ling_time") or 0
	self.receive_nums = all_nums - nums
	local str = string.format(Language.Goddess.FreeTimesTip2, self.receive_nums)
    self.receive_times:SetValue(str)
end

-------------------------------------------------
AuraScroller = AuraScroller or BaseClass(BaseCell)

-- 每个格子的高度
local cell_hight = 100
-- 每个格子之间的间距
local distance = 15
-- 格子起始间距
local offset = 0
-- DoTween移动的距离(越大表示转动速度越快)
local movement_distance = 999

local IconCount=5

local icon_name="Icon_Aura"

local icon_path="uis/views/aurasearchview_prefab"

AuraScroller = AuraScroller or BaseClass(BaseCell)

function AuraScroller:__init(instance)
	if instance == nil then
		return
	end

	self.rect = self:FindObj("Rect")
	self.do_tween_obj = self:FindObj("DoTween")
	self.do_tween_obj.transform.position = Vector3(0, 0, 0)

    local original_hight = self.root_node.rect.sizeDelta.y
	local hight = IconCount * cell_hight
	self.percent = cell_hight / (hight - original_hight)
	self.rect.rect.sizeDelta = Vector2(self.rect.rect.sizeDelta.x, hight)
	self.scroller_rect = self.root_node:GetComponent(typeof(UnityEngine.UI.ScrollRect))
	self.scroller_rect.onValueChanged:AddListener(BindTool.Bind(self.OnValueChange, self))

	PrefabPool.Instance:Load(AssetID(icon_path,icon_name), function(prefab)
        if nil == prefab then
            return
        end

        for i = 1, IconCount + 3 do

            local obj = U3DObject(GameObject.Instantiate(prefab))

            local obj_transform = obj.transform

            obj_transform:SetParent(self.rect.transform, false)

            obj_transform.localPosition = Vector3(0, -(i - 1) * cell_hight+offset , 0)

            local res_id = i - 1

            if res_id > IconCount then
            	res_id = res_id % IconCount
            end
            if res_id == 0 then
            	res_id = IconCount
            end

            obj:GetComponent(typeof(UIVariableTable)):FindVariable("Icon"):SetAsset(ResPath.GetAuraImage(res_id))
        end
    end)

     self.target_x = 0
    self.target = 1
    self.falg = false
    self.is_start = true
    self.is_ling = false

    --self:InitEffect(false)
end

function AuraScroller:__delete()
	self:RemoveCountDown()

	self.rect = nil
	self.do_tween_obj = nil
	self.is_start = true
	self.effect = nil
	self.is_ling = false
end

function AuraScroller:OnValueChange(value)
	local x = value.y
end

function AuraScroller:StartScoller(time, target)
	if self.flag then 
		self.is_ling = true
		if self.effect then
			self.effect:SetActive(true)
		end
		return 
	end

	self.is_ling = target == 1
	if self.effect then
		self.effect:SetActive(false)
	end

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

function AuraScroller:UpdateTime(elapse_time, total_time)
	local value = self:IndexToValue(self.do_tween_obj.transform.position.x % 10)
	self.scroller_rect.normalizedPosition = Vector2(1, value)
	if elapse_time >= total_time then
		value = self:IndexToValue(self.target_x % 10)
		self.scroller_rect.normalizedPosition = Vector2(1, value)
		if self.call_back then
			self.call_back(self.index)
		end

		-- if self.is_ling then
		-- 	self.effect:SetActive(true)
		-- else
		-- 	self.effect:SetActive(false)
		-- end

		if self.index ~= nil and self.index == 6 then
			GoddessCtrl.Instance:ResetEff()
		end
	end
end

function AuraScroller:IndexToValue(index)
	return 1 - (self.percent*index%3)
end

function AuraScroller:SetCallBack(call_back)
	self.call_back = call_back
end

function AuraScroller:RemoveCountDown()
	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function AuraScroller:SetIndex(index)
	self.index = index
end

function AuraScroller:OnFlush()
	if self.data == nil or next(self.data) == nil then
		return
	end

	if self.data.key == "start" then
		local value = self:IndexToValue(self.data.index)
		self.scroller_rect.normalizedPosition = Vector2(1, value)
		self.is_start = false
		if self.data.index == 0 then
			if self.effect ~= nil then
				self.effect:SetActive(true)
				self.is_ling = true
			end
			self.flag = true
		end

		self:ShowEffect(self.data.index == 0)
	end
end

function AuraScroller:ShowEffect(flag)
	if self.effect == nil then
	  	PrefabPool.Instance:Load(AssetID("effects2/prefab/ui_x/ui_zhishengyijie_002_prefab", "UI_zhishengyijie_002"), function (prefab)
			if not prefab or self.effect then return end

			-- if self.is_is_destroy_effect_loading then
			-- 	self.is_loading = false
			-- 	self.is_is_destroy_effect_loading = false
			-- 	return
			-- end

			local obj = GameObject.Instantiate(prefab)
			PrefabPool.Instance:Free(prefab)
			local transform = obj.transform
			transform:SetParent(self.root_node.transform, false)
			self.effect = obj.gameObject
			self.is_loading = false
			self.effect:SetActive(flag)
		end)
	else
		self.effect:SetActive(flag)
	end
end