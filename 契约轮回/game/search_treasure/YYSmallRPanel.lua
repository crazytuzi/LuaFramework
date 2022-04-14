YYSmallRPanel = YYSmallRPanel or class("YYSmallRPanel",BasePanel)
local YYSmallRPanel = YYSmallRPanel

function YYSmallRPanel:ctor()
	self.abName = "search_treasure"
	self.assetName = "YYSmallRPanel"
	self.layer = "UI"

	self.use_background = true
	self.change_scene_close = true
	self.is_hide_other_panel = true

	self.smallR_model = YYSmallRModel:GetInstance()
	self.st_model = SearchTreasureModel:GetInstance()
	
	self.st_model_events = nil
	self.global_events = nil
	self.handle_select_max_count_lib_event_id = nil

	--倒计时item
	self.coundown_item = nil

	--珍稀奖励item
	self.rare_item = nil

	--模型item
	self.model_item = nil

	self.rt_model_con = nil
	self.render_texture = nil

	self.tex_layer = nil

	self.money_list = nil

	self.is_show_money = { Constant.GoldType.Gold, Constant.GoldType.BGold, Constant.GoldType.Coin }    --是否显示钱
end

function YYSmallRPanel:dctor()

	if self.st_model_events then
		self.st_model:RemoveTabListener(self.st_model_events)
		self.st_model_events = nil
	end

	if self.handle_select_max_count_lib_event_id then
		self.st_model:RemoveListener(self.handle_select_max_count_lib_event_id)
		self.handle_select_max_count_lib_event_id = nil
	end
	
	if self.global_events then
		GlobalEvent:RemoveTabListener(self.global_events)
		self.global_events = nil
	end

	if self.coundown_item then
		self.coundown_item:destroy()
		self.coundown_item = nil
	end

	if self.rare_item then
		self.rare_item:destroy()
		self.rare_item = nil
	end

	if self.model_item then
		self.model_item:destroy()
		self.model_item = nil 
	end

	if self.tex_layer then
		self.tex_layer:destroy()
		self.tex_layer = nil
	end

	if self.money_list then
		for k,v in pairs(self.money_list) do
			v:destroy()
		end
	end

	--清理RT
	if self.camera then
		self.camera.targetTexture = nil
	end
	if self.rt_model_con then
		self.rt_model_con.texture = nil
		ReleseRenderTexture(self.render_texture)
		self.render_texture = nil
	end

	self:StopAutoLotteryDraw()

	self.smallR_model:ClearData()
end



function YYSmallRPanel:LoadCallBack()
	self.nodes = {

		"money_con",

		"left_bg/img_model",
		"left_bg/left_des",
		"left_bg/model_con2",
		"left_bg/model_con",
		"left_bg/model_con/camera",
		"left_bg/effect_parent",
		"left_bg/img_title",

		"right/count_slider_bg/txt_cur_count",
		"right/count_slider_bg/count_slider",
		"right/btn_help",
		"right/count_slider_bg/txt_sum_count",
		"right/countdown",
		"right/rarebg/icon",
		"right/rarebg/img_is_get",
		"right/btn_right_arrow",
		"right/toggle",
		"right/btn_close",
		"right/btn_left_arrow",
		"right/btn_buy/txt_cost",
		"right/btn_buy/img_cost",
		"right/btn_buy",
		"right/btn_cancel",
	}
	self:GetChildren(self.nodes)

	self:InitUI()
	self:AddEvent()
end

function YYSmallRPanel:InitUI()

	self.img_model = GetImage(self.img_model)
	self.camera = GetCamera(self.camera)
	self.left_des = GetImage(self.left_des)
	self.img_title = GetImage(self.img_title)
	self.rt_model_con = GetRawImage(self.model_con)

	self.count_slider = GetImage(self.count_slider)
	self.txt_cur_count = GetText(self.txt_cur_count)
	self.txt_sum_count = GetText(self.txt_sum_count)
	self.img_cost = GetImage(self.img_cost)
	self.txt_cost = GetText(self.txt_cost)
	self.toggle = GetToggle(self.toggle)
	self.toggle.isOn = false
	 
	self.render_texture = CreateRenderTexture()
	self.rt_model_con.texture = self.render_texture
	self.camera.targetTexture = self.render_texture

	local order = LayerManager.GetInstance():GetMaxOrderIndex(self.transform)
	LayerManager.GetInstance():AddOrderIndexByCls(self, self.model_con, nil, true, order + 2)
	LayerManager.GetInstance():AddOrderIndexByCls(self, self.model_con2, nil, true, order + 2)
end

function YYSmallRPanel:AddEvent()
	
	self.st_model_events = {}
	local tab = Config.db_yunying_lottery_rewards
	--抽奖完毕
	local function call_back(type_id)


		local reward_ids = self.st_model:GetSearchResult()
		local reward_item = tab[reward_ids[1]]
		local rewards = String2Table(reward_item.rewards)
		local item_id = rewards[1][1]
		self:HandleGetItem(item_id)
		
		self:RequestUpdateLotteryCount()

		if self.smallR_model.is_auto_lottery_draw then
			--如果是自动抽奖 那就在0.25秒后再次尝试抽奖
			if self.smallR_model.auto_lottery_draw_scheld_id~= nil then
				GlobalSchedule:Stop(self.smallR_model.auto_lottery_draw_scheld_id)
			end
			self.smallR_model.auto_lottery_draw_scheld_id = GlobalSchedule:StartOnce(handler(self,self.TryRequestLotteryDraw),0.25)
		end

	end
	self.st_model_events[#self.st_model_events + 1] = self.st_model:AddListener(SearchTreasureEvent.SearchResult,call_back)

	--获取各个奖励库是否已抽取到珍稀奖励
	local function call_back(type_id,is_have)
		self.smallR_model.have_rare_tab[type_id] = is_have
		logError("奖励库"..type_id.."是否抽到了珍稀奖励："..tostring(is_have))
		
		self:UpdateIsHaveRare()

		self:HandleSelectMaxCountLib()
	end
	self.st_model_events[#self.st_model_events + 1] = self.st_model:AddListener(SearchTreasureEvent.HaveRare,call_back)

	--处理选择最大次数奖励库
	local function call_back()

		for k,v in pairs(self.smallR_model.act_id_list) do
			local info = self.st_model:GetInfo(v)
			self.smallR_model.lib_index_count_map[k] = info.bless_value
		end

		self:HandleSelectMaxCountLib()
	end
	self.handle_select_max_count_lib_event_id = self.st_model:AddListener(SearchTreasureEvent.UpdateInfo,call_back)
	
	
	self.global_events = {}

	--关闭按钮点击
	local function call_back(target,x,y)
		self:Close()
	end
	AddClickEvent(self.btn_close.gameObject,call_back)

	--右箭头点击
	local function call_back()
		--点击箭头后要取消自动抽奖
		self.toggle.isOn = false

		self:UpdateCurRewardLib(self.smallR_model.cur_reward_lib_index + 1)
	end
	AddClickEvent(self.btn_right_arrow.gameObject,call_back)

	--左箭头点击
	local function call_back()
		--点击箭头后要取消自动抽奖
		self.toggle.isOn = false

		self:UpdateCurRewardLib(self.smallR_model.cur_reward_lib_index - 1)
	end
	AddClickEvent(self.btn_left_arrow.gameObject,call_back)

	--抽奖按钮点击
	local function call_back()
		self:TryRequestLotteryDraw()
	end
	AddClickEvent(self.btn_buy.gameObject,call_back)

	--取消按钮点击
	local function call_back()
		self.toggle.isOn = false
	end
	AddClickEvent(self.btn_cancel.gameObject,call_back)

	--自动抽奖toggle
	local function call_back(target, value)
		if value then
			--弹出确认框
			self.smallR_model.is_auto_lottery_draw = true

			local function cancel_func(  )
				self.toggle.isOn = false
			end
			Dialog.ShowTwo(ConfigLanguage.SearchT.TipsTitle, "Did you select the quick draw?", nil, nil, nil, nil, cancel_func, nil, ConfigLanguage.SearchT.NoAlert, false, nil, "AutoLotteryDraw")
		else
			self:StopAutoLotteryDraw()
		end
    end
	AddValueChange(self.toggle.gameObject, call_back)
	
	--问号按钮（游戏说明）
    local function call_back(target, x, y)
		ShowHelpTip(HelpConfig.SearchT.smallR,true)
		
    end
    AddClickEvent(self.btn_help.gameObject, call_back)

end

function YYSmallRPanel:Open(id_list)

	YYSmallRPanel.super.Open(self)

	self.smallR_model:SetActIdList(id_list)
	
	--刷新珍稀奖励库信息
	self:UpdateRareRewardLib(id_list)
	

end

function YYSmallRPanel:OpenCallBack()


	

	self:SelectMaxCountLib()

	self:RequestHaveRareInfo()

	self:UpdateCountdown() 

	self:SetMoney(self.is_show_money)

	
end


function YYSmallRPanel:CloseCallBack()

end

--刷新珍稀奖励库信息
function YYSmallRPanel:UpdateRareRewardLib(id_list)

	self.smallR_model.rare_reward_lib = {}

	for k,v in pairs(Config.db_yunying_lottery_rewards) do
		for k2,v2 in pairs(id_list) do
			if v.yunying_id == v2 and v.is_rare == 1 then
				--是珍稀奖励
				self.smallR_model.rare_reward_lib[v.yunying_id] = self.smallR_model.rare_reward_lib[v.yunying_id] or {}
				table.insert( self.smallR_model.rare_reward_lib[v.yunying_id],v )
			end
		end
	end

	for k,v in pairs( self.smallR_model.rare_reward_lib) do
		table.sort(v,function( a,b )
			return a.absolute > b.absolute
		end)
	end
end

--刷新当前奖励库
function YYSmallRPanel:UpdateCurRewardLib(index)
	if index<= 0 and index > self.smallR_model.max_reward_lib_index then
		logError("刷新当前奖励库的index无效")
		return
	end

	if self.smallR_model.cur_reward_lib_index == index then
		logError("刷新当前奖励库的index与当前index相同")
		return
	end

	self.smallR_model.cur_reward_lib_index = index
	self.smallR_model.cur_reward_lib_id = self.smallR_model.act_id_list[index]

	--刷新相关UI
	self:UpdateView()
	
end


function YYSmallRPanel:UpdateView()

	self:UpdateArrow()
	
	self:UpdateRareReward()
	
	self:UpdateCost()
	
	self:RequestUpdateLotteryCount()

	self:UpdateModel()

	self:UpdateIsHaveRare()
end


--刷新箭头显示
function YYSmallRPanel:UpdateArrow()

	if self.smallR_model.max_reward_lib_index == 1 then
		--只有1个奖励库 不显示箭头
		SetVisible(self.btn_left_arrow,false)
		SetVisible(self.btn_right_arrow,false)
		return
	end

	if self.smallR_model.cur_reward_lib_index == 1 then
		--第1个奖励库
		SetVisible(self.btn_left_arrow,false)
		SetVisible(self.btn_right_arrow,true)
	elseif self.smallR_model.cur_reward_lib_index == self.smallR_model.max_reward_lib_index then
		--最后一个奖励库
		SetVisible(self.btn_left_arrow,true)
		SetVisible(self.btn_right_arrow,false)
	else
		SetVisible(self.btn_left_arrow,true)
		SetVisible(self.btn_right_arrow,true)
	end
end

--刷新倒计时
function YYSmallRPanel:UpdateCountdown()

	if not self.coundown_item then

		local act = OperateModel:GetInstance():GetAct(self.smallR_model.act_id_list[1])

		if not act then
			Notify.ShowText("Event locked")
			self:Close()
			return
		end

		local param = {
			isShowMin = true,
			isShowHour = true,
			isShowDay = true,
			isChineseType = true,
			duration = 0.033,
		}
		--开始倒计时
		self.coundown_item = CountDownText(self.countdown, param)
		

		local function call_back(  )
			self:Close()
		end

		self.coundown_item:StartSechudle(act.act_etime,call_back)
	end

end

--刷新珍稀奖励
function YYSmallRPanel:UpdateRareReward()
	local rare = self.smallR_model.rare_reward_lib[self.smallR_model.cur_reward_lib_id][1].rewards
	rare = String2Table(rare)[1]

	self.rare_item = self.rare_item or GoodsIconSettorTwo(self.icon)

	local param = {}
	param["item_id"] = rare[1]
	param["num"] = rare[2]
	param["bind"] = rare[3]
	param["size"] = {x=88,y=88}
	param["can_click"] = true
	param["color_effect"] = 4
	param["effect_type"] = 2
	self.rare_item:SetIcon(param)


end

--刷新抽奖消耗
function YYSmallRPanel:UpdateCost(  )
	local yycfg = Config.db_yunying[self.smallR_model.cur_reward_lib_id]
	local reqs = String2Table(yycfg.reqs)
	local cost
	for i=1, #reqs do

		if reqs[i][1] == "cost" then
			cost = reqs[i][2]
		end

	end

	if cost then
		self.smallR_model.cost_item_id = cost[1][2]
		self.smallR_model.cost_item_num = cost[1][3]
		local icon = Config.db_item[self.smallR_model.cost_item_id].icon
		GoodIconUtil.GetInstance():CreateIcon(self, self.img_cost, icon, true)
		self.txt_cost.text = string.format("×%s", self.smallR_model.cost_item_num)
	end
end

--请求刷新抽奖次数
function YYSmallRPanel:RequestUpdateLotteryCount()
	SearchTreasureController:GetInstance():RequestGetInfo(self.smallR_model.cur_reward_lib_id)
end

--刷新抽奖次数进度
function YYSmallRPanel:UpdateLotteryCount()

	local info = self.st_model:GetInfo(self.smallR_model.cur_reward_lib_id)
	local cur_count = info.bless_value
	self.smallR_model.cur_count = info.bless_value

--[[ 	if info.bless_value == 0 then
		if self.toggle.isOn then
			--抽到珍稀奖励 停止自动抽奖
			self.toggle.isOn  = false
		end
	end ]]

	local sum_count = 0
	if self.smallR_model.rare_reward_lib[self.smallR_model.cur_reward_lib_id][1] then
		sum_count = self.smallR_model.rare_reward_lib[self.smallR_model.cur_reward_lib_id][1].absolute
	end

	self.smallR_model.sum_count = sum_count

	self.count_slider.fillAmount = cur_count / sum_count

	self.txt_cur_count.text = cur_count
	self.txt_sum_count.text = sum_count

end

--刷新模型
function YYSmallRPanel:UpdateModel(  )
	local yycfg = Config.db_yunying[self.smallR_model.cur_reward_lib_id]
	local reqs = String2Table(yycfg.reqs)
	local show
	for i=1, #reqs do
		if reqs[i][1] == "show" then
			show = reqs[i]
		end
	end



	if show then
		if type(show[2]) == "number" then
			--显示模型
			SetVisible(self.img_model, false)
			SetVisible(self.model_con, true)

			if self.model_item then
				self.model_item:destroy()
			end

			local ModelType = show[2]  --获取模型类型
				if ModelType == enum.MODEL_TYPE.MODEL_TYPE_MOUNT then
					self.model_item = UIModelManager:GetInstance():InitModel(show[2], show[3], self.model_con, handler(self,self.Mount_CallBack), nil, 1)
				elseif ModelType == enum.MODEL_TYPE.MODEL_TYPE_ROLE then
					SetVisible(self.model_con, false)
					local tmp = {}
					tmp[1] = show[3]
					tmp[2] = show[4]
					self.model_item = UIModelManager:GetInstance():InitModel(show[2], tmp, self.model_con2, nil, nil, 2)
				elseif ModelType == enum.MODEL_TYPE.MODEL_TYPE_FABAO then
					self.model_item = UIModelManager:GetInstance():InitModel(show[2], show[3], self.model_con, handler(self,self.Fabao_CallBack), nil, 2)
				elseif ModelType == enum.MODEL_TYPE.MODEL_TYPE_FUSHOW then
					self.model_item = UIModelManager:GetInstance():InitModel(show[2], show[3], self.model_con, handler(self,self.FuShou_CallBack), nil, 1)
				else
					self.model_item = UIModelManager:GetInstance():InitModel(show[2], show[3], self.model_con, handler(self,self.Weapon_CallBack), nil, 1)
				end
		else
			--显示图片
			SetVisible(self.img_model, true)
			SetVisible(self.model_con, false)
--[[ 
			local act_id = self.smallR_model.cur_reward_lib_id
			if self.smallR_model.tmp_tab[act_id] then
				act_id =  self.smallR_model.tmp_tab[act_id]
			end ]]

			lua_resMgr:SetImageTexture(self,self.img_model, 'search_treasure_image', self.smallR_model.cur_reward_lib_id.. "",nil,nil,false)
			self:PlayAni()
		end
	else
		SetVisible(self.img_model, false)
		SetVisible(self.model_con, false)
	end

	--活动名

	lua_resMgr:SetImageTexture(self, self.img_title, 'search_treasure_image', 'act_title_' .. self.smallR_model.cur_reward_lib_id,true,nil,false)

	--奖品描述
	local function call_back(sp)
        self.left_des.sprite = sp
        if not self.tex_layer then
            self.tex_layer = LayerManager:GetInstance():AddOrderIndexByCls(self,self.left_des.transform,nil,true,nil,nil,4)
        end
    end
	lua_resMgr:SetImageTexture(self, self.left_des, 'search_treasure_image', 'act_des_' .. self.smallR_model.cur_reward_lib_id,nil,call_back,false)


end

function YYSmallRPanel:Mount_CallBack()
	self.model_item:AddAnimation({"show","idle"},false,"idle",0)
	SetLocalPosition(self.model_item.transform, -6002, -6070.9, 242)
	SetLocalRotation(self.model_item.transform, 0, 185, 0)
end

function YYSmallRPanel:Fabao_CallBack()
	SetLocalPosition(self.model_item.transform, -5998.1, -5992, -38)
end

function YYSmallRPanel:Weapon_CallBack()
	SetLocalPosition(self.model_item.transform, -5986.47, -6015, 50.55)
end

function YYSmallRPanel:FuShou_CallBack()
	SetLocalPosition(self.model_item.transform, -6029, -5983, 158.7)
end

function YYSmallRPanel:PlayAni()
    local action = cc.MoveTo(1, 1.569611, 42.99981)
    action = cc.Sequence(action, cc.MoveTo(1, 1.569611, 26.99981))
    action = cc.Repeat(action, 4)
    action = cc.RepeatForever(action)
    cc.ActionManager:GetInstance():addAction(action, self.img_model.transform)
end

--尝试请求抽奖
function YYSmallRPanel:TryRequestLotteryDraw()

	if self.smallR_model.cur_count >= self.smallR_model.sum_count then
		--当前抽取次数已满 不能再抽
		Notify.ShowText("Blessing is full, unable to draw anymore today")
		if self.toggle.isOn then
			self.toggle.isOn = false
		end
		return
	end


	--代币拥有数量
	local have_num
	--需要代币数量
	local need_num = self.smallR_model.cost_item_num

	local price  --最终要消耗的钻石数量

	if 	self.smallR_model.cost_item_id == 90010003 then
		--代币是钻石
		 have_num = RoleInfoModel:GetInstance():GetRoleValue(self.smallR_model.cost_item_id)
	 	 price = need_num
	else
		--代币是道具
		 have_num = BagController:GetInstance():GetItemListNum(self.smallR_model.cost_item_id)
	end

	--拥有代币数量不足
	if have_num < need_num then

		-- 是可用钻石补足的道具  提示用钻石补足
		if Config.db_voucher[self.smallR_model.cost_item_id]  then
			
			price = Config.db_voucher[self.smallR_model.cost_item_id].price * (need_num - have_num) 	
			local item_name = Config.db_item[self.smallR_model.cost_item_id].name
			local message = ""
			if have_num > 0 then
            	message = string.format(ConfigLanguage.SearchT.AlertMsg5, item_name, price, item_name, need_num - have_num)
        	else
            	message = string.format(ConfigLanguage.SearchT.AlertMsg4, item_name, price, item_name, need_num - have_num)
        	end

			local function ok_func()
            	self:RequestLotteryDraw(price)
			end
			local function cancel_func()
				--代币不足 不使用钻石补足时 取消自动抽奖
            	if self.toggle.isOn then
					self.toggle.isOn =  false
				end
			end

			Dialog.ShowTwo(ConfigLanguage.SearchT.TipsTitle, message, nil, ok_func, nil, nil, cancel_func, nil, ConfigLanguage.SearchT.NoAlert, false, nil, "TryRequestLotteryDraw")
		
		elseif self.smallR_model.cost_item_id == 90010003 then

			--是钻石 弹出通用的钻石不足提示充值的提示框
			self:RequestLotteryDraw(price)

		else
			Notify.ShowText(Config.db_item[self.smallR_model.cost_item_id].name.."Not enough")

			--代币是其他 并且不足时 取消自动抽奖
			if self.toggle.isOn then
				self.toggle.isOn =  false
			end

		end
		
	else
		self:RequestLotteryDraw(price)
	end
end

--请求抽奖
function YYSmallRPanel:RequestLotteryDraw(price)
	local bo = RoleInfoModel:GetInstance():CheckGold(price, Constant.GoldType.Gold)
	if not bo then
		--钻石不足 停止自动抽奖
		if self.toggle.isOn then
			self.toggle.isOn =  false
		end
		return
	end

	if self.smallR_model.is_auto_lottery_draw then
		--抽奖时 如果勾选了自动抽奖 那就隐藏抽奖按钮 显示取消按钮
		SetVisible(self.btn_buy,false)
		SetVisible(self.btn_cancel,true)
	end

	SearchTreasureController:GetInstance().show_resultPanel = false --不显示寻宝结果面板
	SearchTreasureController:GetInstance():RequestSearch(self.smallR_model.cur_reward_lib_id, 1)
end

--停止自动抽奖
function YYSmallRPanel:StopAutoLotteryDraw()
	self.smallR_model.is_auto_lottery_draw = false
	SetVisible(self.btn_buy,true)
	SetVisible(self.btn_cancel,false)

	if self.smallR_model.auto_lottery_draw_scheld_id~= nil then
		GlobalSchedule:Stop(self.smallR_model.auto_lottery_draw_scheld_id)
		self.smallR_model.auto_lottery_draw_scheld_id = nil
	end
end

--设置货币栏item
function YYSmallRPanel:SetMoney(list)
    if table.isempty(list) then
        return
    end
    self.money_list = {}
    local offx = 220
    for i = 1, #list do
        local item = MoneyItem(self.money_con, nil, list[i])
        local x = (i - #list) * offx
        local y = 0
        item:SetPosition(x, y)
        self.money_list[i] = item
    end
end

--选择抽奖次数最大且没获得珍稀奖励的奖励库
function YYSmallRPanel:SelectMaxCountLib()

	self.smallR_model.lib_index_count_map = {}

	for k,v in pairs(self.smallR_model.act_id_list) do
		SearchTreasureController:GetInstance():RequestGetInfo(v)
	end
end

function YYSmallRPanel:HandleSelectMaxCountLib(  )

	--所有奖励库的次数数据和珍稀获得数据都得到了 就开始找出次数最大且没获得珍稀奖励的的
	if table.nums(self.smallR_model.lib_index_count_map) == self.smallR_model.max_reward_lib_index
	   and table.nums(self.smallR_model.have_rare_tab) == self.smallR_model.max_reward_lib_index
	then

		local max_count_index = 1
		for k,v in pairs(self.smallR_model.act_id_list) do

			--先找出第一个没获得珍稀奖励的
			if self.smallR_model.have_rare_tab[v] == false then
				max_count_index = k
				break
			end
		end


		for k,v in pairs(self.smallR_model.act_id_list) do
			--然后让其他没获得珍稀奖励的来进行对比 找出次数最大的
			if self.smallR_model.have_rare_tab[v] == false
			  and self.smallR_model.lib_index_count_map[k] > self.smallR_model.lib_index_count_map[max_count_index]
			then
				max_count_index = k
			end
		end

		--移除事件监听
		self.st_model:RemoveListener(self.handle_select_max_count_lib_event_id)
		self.handle_select_max_count_lib_event_id = nil

		--添加事件监听
		function call_back(  )
			self:UpdateLotteryCount()
		end
		self.st_model_events[#self.st_model_events + 1] = self.st_model:AddListener(SearchTreasureEvent.UpdateInfo,call_back)
	
		--选择次数最大的那个奖励库
		self:UpdateCurRewardLib(max_count_index)
	
	end
end

--请求各个奖励库是否已抽到珍稀奖励信息
function YYSmallRPanel:RequestHaveRareInfo()
	self.smallR_model.have_rare_tab = {}
	for k,v in pairs(self.smallR_model.act_id_list) do
		SearchTreasureController:GetInstance():RequestHaveRare(v)
	end
end

--处理抽奖后获取物品
function YYSmallRPanel:HandleGetItem(item_id)

	    --抽到珍稀物品 停止自动 并切换到下一个奖励库
		local tab =	self.smallR_model.rare_reward_lib[self.smallR_model.cur_reward_lib_id][1].rewards
		tab = String2Table(tab)
		local rare_item_id = tab[1][1]
		--logError("当前物品"..item_id.."，当前奖励库珍稀物品"..rare_item_id)
		if item_id == rare_item_id then
			--logError("抽到了珍稀奖励"..item_id)
			self.smallR_model.have_rare_tab[self.smallR_model.cur_reward_lib_id] = true
			self:UpdateIsHaveRare()
			if self.toggle.isOn then
				self.toggle.isOn = false
			end
			self:ChangeToNextLib()
		end

		local item_icon = GoodsIconSettorTwo(self.icon)
		SetAnchoredPosition(item_icon.transform,0,-50)
		local param = {}
		param["item_id"] = item_id	
		param["size"] = {x=78,y=78}
		param["cfg"] = Config.db_item[item_id]
		item_icon:SetIcon(param)

		local move_action = cc.MoveTo(1, 341, -122, 0)
		local function end_callback()
           item_icon:destroy()
        end
        local call_action = cc.CallFunc(end_callback)
		local action = cc.Sequence( move_action, call_action)

		cc.ActionManager:GetInstance():addAction(action, item_icon.transform)
end

--刷新当前奖励库的已获得图标
function YYSmallRPanel:UpdateIsHaveRare()
	local is_have_rare = self.smallR_model.have_rare_tab[self.smallR_model.cur_reward_lib_id]
	SetVisible(self.img_is_get,is_have_rare)
end

--切换到下一个未抽到珍稀奖励的奖励库
function YYSmallRPanel:ChangeToNextLib()

	local next_lib_id = 0
	for k,v in ipairs(self.smallR_model.act_id_list) do
		if  self.smallR_model.have_rare_tab[v] == false then
			next_lib_id = v
			break
		end
	end
	if next_lib_id ~= 0 then
		for k,v in pairs(self.smallR_model.act_id_list) do
			if next_lib_id == v then
				self:UpdateCurRewardLib(k)
				return
			end
		end
	end
end