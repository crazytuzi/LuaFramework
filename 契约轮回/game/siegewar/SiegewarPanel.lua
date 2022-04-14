SiegewarPanel = SiegewarPanel or class("SiegewarPanel", BaseItem)
local SiegewarPanel = SiegewarPanel

function SiegewarPanel:ctor()
	self.abName = "siegewar"
	self.assetName = "SiegewarPanel"
	self.layer = "UI"

	--self.panel_type = 2								--窗体样式  1 1280*720  2 850*545
	--self.show_sidebar = false		--是否显示侧边栏
	--self.table_index = nil
	self.model = SiegewarModel:GetInstance()
	self.events = {}
	self.global_events = {}
	self.reward_list = {}
	self.icons = {}
	self.gous = {}
	self.nums = {}
	self.max_medal = 0
	SiegewarPanel.super.Load(self)
end

--[[function SiegewarPanel:Open(scene)
	SiegewarPanel.super.Open(self)
end--]]

function SiegewarPanel:dctor()
	self.icons = nil
	self.gous = nil
	self.nums = nil

	if self.events then
		self.model:RemoveTabListener(self.events)
		self.events = nil
	end

	if self.global_events then
		GlobalEvent:RemoveTabListener(self.global_events)
		self.global_events = nil
	end

	if self.city8_item then
		self.city8_item:destroy()
	end

	if self.city2_item then
		self.city2_item:destroy()
	end
	if self.city4_item then
		self.city4_item:destroy()
	end
	if self.city3_item then
		self.city3_item:destroy()
	end

	if self.reward_list then
		destroyTab(self.reward_list)
		self.reward_list = nil
	end
end

--[[function SiegewarPanel:OpenCallBack()
	self:UpdateView()
end--]]

function SiegewarPanel:LoadCallBack()
	self.nodes = {
		"Slider","reward1/icon1","reward2/icon2","bg","rewardtitle2/medal",
		"reward3/icon3","reward4/icon4","reward1/gou1","reward2/gou2","reward3/gou3","reward4/gou4",
		"rewardtitle3/tired","lockbtn","nextbg/countdowntext","cityitem",
		"reward1/num1","reward2/num2","reward3/num3","reward4/num4","shopbtn",
	}
	self:GetChildren(self.nodes)
	self.num1 = GetText(self.num1)
	self.num2 = GetText(self.num2)
	self.num3 = GetText(self.num3)
	self.num4 = GetText(self.num4)
	self.icons[1] = self.icon1
	self.icons[2] = self.icon2
	self.icons[3] = self.icon3
	self.icons[4] = self.icon4
	self.gous[1] = self.gou1
	self.gous[2] = self.gou2
	self.gous[3] = self.gou3
	self.gous[4] = self.gou4
	self.nums[1] = self.num1
	self.nums[2] = self.num2
	self.nums[3] = self.num3
	self.nums[4] = self.num4
	self.Slider = GetSlider(self.Slider)
	self.medal = GetText(self.medal)
	self.tired = GetText(self.tired)
	self.countdowntext = GetText(self.countdowntext)
	self.bg = GetImage(self.bg)
	self:AddEvent()
	SetVisible(self.shopbtn, false)
	SiegewarController.GetInstance():RequestCity()
	RoleInfoController.GetInstance():RequestWorldLevel()
	self:UpdateFreshTime()
    local res = "siegewar__big_bg"
    lua_resMgr:SetImageTexture(self, self.bg, "iconasset/icon_big_bg_" .. res, res, false)
end

function SiegewarPanel:AddEvent()

	local function call_back(target,x,y)
		if self.model.medal < self.max_medal then
			local rewards = self.model:GetMedalRewards()
			local need_medal = rewards[3].id
			if self.model.medal < need_medal then
				return Notify.ShowText(string.format("Collect more than %s badges this week can purchase", need_medal))
			end
			local need_gold = math.ceil((self.max_medal-self.model.medal)/5)
			local function ok_func()
				local vo = RoleInfoModel:GetInstance():CheckGold(need_gold, Constant.GoldType.Gold)
				if not vo then
					return
				end
				SiegewarController.GetInstance():RequestBuyMedal()
			end
			local message = string.format("Spend %s diamond on %s badges?", need_gold, self.max_medal-self.model.medal)
			Dialog.ShowTwo("Tip",message,"Confirm",ok_func)
		end
	end
	AddClickEvent(self.lockbtn.gameObject,call_back)

	local function call_back()
		if self.model.rule == 3 then
			if not self.city8_item then
				self.city8_item = SiegewarEightItem(self.cityitem)
			end
		elseif self.model.rule == 1 then
			if not self.city2_item then
				self.city2_item = SiegewarTwoItem(self.cityitem)
			end
		elseif self.model.rule == 2 then
			if not self.city4_item then
				self.city4_item = SiegewarFourItem(self.cityitem)
			end
		elseif self.model.rule == 0 then
			if not self.city3_item then
				self.city3_item = SiegewarThreeItem(self.cityitem)
			end
		end
		self.tired.text = string.format("%s/%s", self.model:GetTired())
		self:UpdateMedalRewards()
	end
	self.events[#self.events+1] = self.model:AddListener(SiegewarEvent.UpdateCity, call_back)


	local function call_back()
		self:UpdateMedalRewards()
	end
	self.events[#self.events+1] = self.model:AddListener(SiegewarEvent.UpdateMedal, call_back)

	local function call_back()
		self.Slider.value = self.model.medal
		SetVisible(self.lockbtn, self.model.medal < self.max_medal)
		self:UpdateMedalRewards()
	end
	self.events[#self.events+1] = self.model:AddListener(SiegewarEvent.FullMedal, call_back)
end


function SiegewarPanel:UpdateMedalRewards()
	local rewards, max_medal = self.model:GetMedalRewards()
	self.max_medal = max_medal
	destroyTab(self.reward_list)
	self.reward_list = {}
	for i=1, #rewards do
		local param = {}
		param["can_click"] = true
		param["item_id"] = String2Table(rewards[i].reward)[1][1]
		param["size"] = {x=60, y=60}
		param["bind"] = 2
		if not table.containValue(self.model.fetch, rewards[i].id) and self.model.medal >= rewards[i].id then
			param["effect_type"] = 2
			param["color_effect"] = 3
		end
		local function call_back()
			if self.model.medal < rewards[i].id then
				return
			end
			if not table.containValue(self.model.fetch, rewards[i].id) then
				SiegewarController.GetInstance():RequestMedal(rewards[i].id)
			end 
		end
		param["out_call_back"] = call_back
		local item = GoodsIconSettorTwo(self.icons[i])
		item:SetIcon(param)
		self.reward_list[i] = item
		if self.nums[i] then
			self.nums[i].text = rewards[i].id
		end
		SetVisible(self.gous[i], table.containValue(self.model.fetch, rewards[i].id))
	end
	self.Slider.value = self.model.medal
	self.Slider.maxValue = self.max_medal
	self.medal.text = self.model.medal
	SetVisible(self.lockbtn, self.model.medal < self.max_medal)
end

--刷新下一轮时间
function SiegewarPanel:UpdateFreshTime()
	local cfg = Config.db_activity[11123]
	local time_arr = String2Table(string.format("{%s}", cfg.time))
	local timeTab = os.date("*t", os.time())
	local now_hour = timeTab.hour
	local now_min = timeTab.min
	local show_hour, show_min = 0, 0
	for i=1, #time_arr do
		local time = time_arr[i]
		local hour = time[1]
		local min = time[2]
		if now_hour < hour or (now_hour == hour and now_min < min) then
			show_hour = hour
			show_min = min
			break
		end
	end
	if show_hour > 0 then
		self.countdowntext.text = string.format("Next refresh: %s:%02d", show_hour, show_min)
	else
		show_hour = time_arr[1][1]
		show_min = time_arr[1][2]
		self.countdowntext.text = string.format("Next refresh: Tomorrow %s:%02d", show_hour, show_min)
	end
end

--[[function SiegewarPanel:UpdateView( )

end

function SiegewarPanel:CloseCallBack(  )

end

function SiegewarPanel:SwitchCallBack(index)
	if self.table_index == index then
		return
	end
	if self.child_node then
	 	self.child_node:SetVisible(false)
	end
	self.table_index = index
end--]]

