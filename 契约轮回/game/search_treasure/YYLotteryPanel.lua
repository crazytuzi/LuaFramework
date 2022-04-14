YYLotteryPanel = YYLotteryPanel or class("YYLotteryPanel",BasePanel)
local YYLotteryPanel = YYLotteryPanel

function YYLotteryPanel:ctor()
	self.abName = "search_treasure"
	self.assetName = "YYLotteryPanel"
	self.layer = "UI"

	self.use_background = true
	self.change_scene_close = true
	self.is_hide_other_panel = true

	self.model = SearchTreasureModel:GetInstance()
	--self.is_show_money = { 11044, Constant.GoldType.Gold, Constant.GoldType.BGold, Constant.GoldType.Coin }

	self.rare_item = nil
	self.item_list = {}
	self.leiji_list = {}
	self.msg_list = {}    --个人记录
    self.msg_list2 = {}   --全服记录
	self.events = {}
	self.global_events = {}
end

function YYLotteryPanel:dctor()
	
end

function YYLotteryPanel:Open(act_id)
	self.act_id = act_id
	self.model.act_id = act_id
	self.type_id = act_id
	YYLotteryPanel.super.Open(self)
end

function YYLotteryPanel:LoadCallBack()
	self.nodes = {
		"bigbg", "left_bg/effect_parent", "title_img","left_bg/model_img","left_bg/left_des","left_bg/left_title",
		"right/rarebg/icon","right/rarebg/price","right/ScrollView/Viewport/Content",
		"right/RecordScrollView/Viewport/RecordContent","right/togglegroup/allserver",
		"right/togglegroup/person","right/historybtn","right/buybtn","right/buyfifbtn","leiji/leiji_count",
		"leiji/leiji_content","btnclose","right/countdown",
		"left_bg/model_con","right/buybtn/moneyicon","right/buyfifbtn/moneyicon2",
		"right/buybtn/moneynum","right/buyfifbtn/moneynum2",
		"right/RecordScrollView2","right/RecordScrollView","right/RecordScrollView2/Viewport/RecordContent2",
		"right/helpbtn","right/buybtn/Text", "left_bg/model_con/Camera","left_bg/model_con2",
		"right/probbtn",
	}
	self:GetChildren(self.nodes)
	self.bigbg = GetImage(self.bigbg)
	self.title_img = GetImage(self.title_img)
	self.left_des = GetImage(self.left_des)
	self.model_img = GetImage(self.model_img)
	self.moneyicon = GetImage(self.moneyicon)
	self.moneyicon2 = GetImage(self.moneyicon2)
	self.moneynum = GetText(self.moneynum)
	self.moneynum2 = GetText(self.moneynum2)
	self.person_tog = GetToggle(self.person)
	self.allserver_tog = GetToggle(self.allserver)
	self.leiji_count_txt = GetText(self.leiji_count)
	self.Text_txt = GetText(self.Text)
	self.price_txt = GetText(self.price)
	self.model_con_img = GetRawImage(self.model_con)
	self.Camera_com = self.Camera:GetComponent("Camera")
	self.left_title = GetImage(self.left_title)
	--self.Slider_com = GetSlider(self.Slider)
	self:AddEvent()

	self.render_texture = CreateRenderTexture()
	self.model_con_img.texture = self.render_texture
	self.Camera_com.targetTexture = self.render_texture


	local res = "yylottery_big_bg"
    lua_resMgr:SetImageTexture(self, self.bigbg, "iconasset/icon_big_bg_"..res, res)
	lua_resMgr:SetImageTexture(self, self.title_img, 'search_treasure_image', 'act_title_' .. self.act_id)
	local function call_back(sp)
        self.left_des.sprite = sp
        if not self.texlayer then
            self.texlayer = LayerManager:GetInstance():AddOrderIndexByCls(self,self.left_des.transform,nil,true,nil,nil,4)
        end
    end
	lua_resMgr:SetImageTexture(self, self.left_des, 'search_treasure_image', 'act_des_' .. self.act_id,nil,call_back)
	local order = LayerManager.GetInstance():GetMaxOrderIndex(self.transform)
	LayerManager.GetInstance():AddOrderIndexByCls(self, self.model_con.transform, nil, true, order + 2)
	LayerManager.GetInstance():AddOrderIndexByCls(self, self.model_con2.transform, nil, true, order + 2)

	SearchTreasureController:GetInstance():RequestGetInfo(self.type_id)
	self.allserver_tog.isOn = true
	SearchTreasureController:GetInstance():RequestGetRecords(self.type_id, 1)
end

function YYLotteryPanel:AddEvent()
	local function call_back(target,x,y)
		self:Close()
	end
	AddButtonEvent(self.btnclose.gameObject,call_back)

	local function call_back(target,x,y)
		self:RequestSearch(1)
	end
	AddButtonEvent(self.buybtn.gameObject,call_back)

	local function call_back(target,x,y)
		self:RequestSearch(10)
	end
	AddButtonEvent(self.buyfifbtn.gameObject,call_back)

	local tmp = {
		[100501] = 3,
		[100502] = 4,
		[100503] = 5,
		[100504] = 6,
		[100505] = 7,
		[100506] = 8,
		[100507] = 9,
	}
	local function call_back(target,x,y)
		lua_panelMgr:GetPanelOrCreate(ProbaTipPanel):Open(tmp[self.act_id])
	end
	AddButtonEvent(self.probbtn.gameObject,call_back)

	local function call_back(target, value)
        if value then
            local messages = self.model:GetMessages(self.type_id, 1)
            if not messages then
                SearchTreasureController:GetInstance():RequestGetRecords(self.type_id, 1)
            else
                SetVisible(self.RecordScrollView, false)
                SetVisible(self.RecordScrollView2, true)
                self:UpdateMessages(self.msg_list2, self.RecordContent2, messages)
            end

        end
    end
    AddValueChange(self.allserver_tog.gameObject, call_back)

    local function call_back(target, value)
        if value then
            local messages = self.model:GetMessages(self.type_id, 0)
            if not messages then
                SearchTreasureController:GetInstance():RequestGetRecords(self.type_id, 0)
            else
                SetVisible(self.RecordScrollView, true)
                SetVisible(self.RecordScrollView2, false)
                self:UpdateMessages(self.msg_list, self.RecordContent, messages)
            end
        end
    end
    AddValueChange(self.person_tog.gameObject, call_back)

    local function call_back(target,x,y)
    	lua_panelMgr:GetPanelOrCreate(YYLotteryHistoryPanel):Open()
    end
    AddButtonEvent(self.historybtn.gameObject,call_back)

    local function call_back(target,x,y)
    	ShowHelpTip(HelpConfig.SearchT.searchyy)
    end
    AddClickEvent(self.helpbtn.gameObject,call_back)

	local function call_back()
        local is_global = 0
        if self.allserver_tog.isOn then
            is_global = 1
        end
        local messages = self.model:GetMessages(self.type_id, is_global)
        if is_global == 1 then
            SetVisible(self.RecordScrollView, false)
            SetVisible(self.RecordScrollView2, true)
            self:UpdateMessages(self.msg_list2, self.RecordContent2, messages)
        else
            SetVisible(self.RecordScrollView, true)
            SetVisible(self.RecordScrollView2, false)
            self:UpdateMessages(self.msg_list, self.RecordContent, messages)
        end
    end
    self.events[#self.events+1] = self.model:AddListener(SearchTreasureEvent.UpdateMessages, call_back)

    local function call_back()
        self:UpdateView()
    end
    self.events[#self.events+1] = self.model:AddListener(SearchTreasureEvent.UpdateInfo, call_back)

    local function call_back()
    	self:UpdateView()
    end
    self.global_events[#self.global_events+1] = GlobalEvent:AddListener(OperateEvent.DLIVER_YY_INFO, call_back)

    local function call_back()
		Notify.ShowText("Claimed")
	end
	self.global_events[#self.global_events+1] = GlobalEvent:AddListener(OperateEvent.SUCCESS_GET_REWARD, call_back)
end

function YYLotteryPanel:DoSearch(num, need_gold)
    local bo = RoleInfoModel:GetInstance():CheckGold(need_gold, Constant.GoldType.Gold)
    if not bo then
        return
    end
    SearchTreasureController:GetInstance():RequestSearch(self.type_id, num)
end

function YYLotteryPanel:RequestSearch(num)
	local cur_count = tonumber(self.leiji_count_txt.text)
    local had_num = BagController:GetInstance():GetItemListNum(self.item_id)
    local num2 = num
    if cur_count == 0 then
    	num2 = num2 - 1
    end
    local cost = self.cost
    local need_num = 1
    for i = 1, #cost do
        if num == cost[i][1] then
            need_num = cost[i][3]
            break
        end
    end
    if cur_count == 0 then
        need_num = need_num - cost[1][3]
    end
    if num2 == 0 or had_num >= need_num then
        self:DoSearch(num, 0)
    else
        local gold_num = need_num - had_num
        local gold = Config.db_voucher[self.item_id].price * gold_num
        local message = ""
        local ItemName = Config.db_item[self.item_id].name
        if had_num > 0 then
            message = string.format(ConfigLanguage.SearchT.AlertMsg5, ItemName, gold, ItemName, gold)
        else
            message = string.format(ConfigLanguage.SearchT.AlertMsg4, ItemName, gold, ItemName, gold)
        end
        local function ok_fun()
            self:DoSearch(num, gold)
        end
        Dialog.ShowTwo(ConfigLanguage.SearchT.TipsTitle, message, nil, ok_fun, nil, nil, nil, nil, ConfigLanguage.SearchT.NoAlert, false, nil, self.__cname)
    end
end


function YYLotteryPanel:OpenCallBack()
	self:UpdateView()
end

function YYLotteryPanel:UpdateView()
	if not self.schedule_id then
		local act = OperateModel:GetInstance():GetAct(self.act_id)
		if not self.coundownitem then
			local param = {
				isShowMin = true,
				isShowHour = true,
				isShowDay = true,
				isChineseType = true,
			    duration = 0.033,
			}
			self.coundownitem = CountDownText(self.countdown, param)
			self.coundownitem:StartSechudle(act.act_etime)
		end
		local rewards, rare = self.model:GetYYLotteryRewards(self.act_id)
		self.rare_item = self.rare_item or GoodsIconSettorTwo(self.icon)
		local rare_reward = String2Table(rare.rewards)[1]
		self.price_txt.text = string.format("Worth: %s", rare.price)
		local param = {}
		param["item_id"] = rare_reward[1]
		param["num"] = rare_reward[2]
		param["bind"] = rare_reward[3]
		param["size"] = {x=88,y=88}
		param["can_click"] = true
		param["color_effect"] = 4
		param["effect_type"] = 2
		self.rare_item:SetIcon(param)
		for i=1, #rewards do
			local item = self.item_list[i] or GoodsIconSettorTwo(self.Content)
			rare_reward = String2Table(rewards[i].rewards)[1]
			param = {}
			param["item_id"] = rare_reward[1]
			param["num"] = rare_reward[2]
			param["bind"] = rare_reward[3]
			param["size"] = {x=75,y=75}
			param["can_click"] = true
			item:SetIcon(param)
			self.item_list[#self.item_list+1] = item
		end
		self:SortScroll()
	    self:AutoScroll()
	    self:ShowModelAndCost()
	    self:UpdateYYInfo()
	end
	if not self.effect then
		self.effect = UIEffect(self.effect_parent, 10311)
	end
	local act_info = OperateModel:GetInstance():GetActInfo(self.act_id)
	local tasks = act_info.tasks
	local searchInfo = self.model:GetInfo(self.act_id)
	local count = (searchInfo and searchInfo.bless_value or 0)
	--[[if tasks[1] then
		count = tasks[1].count
	end--]]
	self.leiji_count_txt.text = count
	if count == 0 then
		self.moneynum.text = "Free"
		if not self.reddot then
			self.reddot = RedDot(self.buybtn)
			SetLocalPosition(self.reddot.transform, 86, 14)
			SetVisible(self.reddot, true)
		end
	else
		self.moneynum.text = self.pre_txt
		if self.reddot then
			self.reddot:destroy()
			self.reddot = nil
		end
	end
	lua_resMgr:SetImageTexture(self,self.left_title, 'search_treasure_image', "yyloter_title_" .. self.act_id)
	local action1 = cc.DelayTime(1)
	local action2 = cc.ScaleTo(0.2, 1.5, 1.5, 1.5)
	local action3 = cc.ScaleTo(0.2, 1, 1, 1)
	local action4 = cc.ScaleTo(0.2, 1.5, 1.5, 1.5)
	local action5 = cc.ScaleTo(0.2, 1, 1, 1)
	local action = cc.Sequence(action1, action2, action3, action4, action5)
    cc.ActionManager:GetInstance():addAction(action, self.left_title.transform)
end

--显示大奖形象
function YYLotteryPanel:ShowModelAndCost()
	local yycfg = Config.db_yunying[self.act_id]
	local reqs = String2Table(yycfg.reqs)
	local show, cost
	for i=1, #reqs do
		if reqs[i][1] == "show" then
			show = reqs[i]
		elseif reqs[i][1] == "cost" then
			cost = reqs[i][2]
		end
	end
	if show then
		if type(show[2]) == "number" then
			SetVisible(self.model_img, false)
			SetVisible(self.model_con, true)
			if not self.model_info then
				local ModelType = show[2]
				if ModelType == enum.MODEL_TYPE.MODEL_TYPE_MOUNT then
					self.model_info = UIModelManager:GetInstance():InitModel(show[2], show[3], self.model_con, handler(self,self.Mount_CallBack), nil, 1)
				elseif ModelType == enum.MODEL_TYPE.MODEL_TYPE_ROLE then
					SetVisible(self.model_con, false)
					self.model_info = UIModelManager:GetInstance():InitModel(show[2], show[3], self.model_con2, nil, nil, 2)
				elseif ModelType == enum.MODEL_TYPE.MODEL_TYPE_FABAO then
					self.model_info = UIModelManager:GetInstance():InitModel(show[2], show[3], self.model_con, handler(self,self.Fabao_CallBack), nil, 2)
				elseif ModelType == enum.MODEL_TYPE.MODEL_TYPE_FUSHOW then
					self.model_info = UIModelManager:GetInstance():InitModel(show[2], show[3], self.model_con, handler(self,self.FuShou_CallBack), nil, 1)
				elseif ModelType == enum.MODEL_TYPE.MODEL_TYPE_WEAPON then
					self.model_info = UIModelManager:GetInstance():InitModel(show[2], show[3], self.model_con, handler(self,self.Shenbing_CallBack), nil, 1)
				elseif ModelType == enum.MODEL_TYPE.MODEL_TYPE_WING then
					self.model_info = UIModelManager:GetInstance():InitModel(show[2], show[3], self.model_con, handler(self,self.Wing_CallBack), nil, 1)
				else
					self.model_info = UIModelManager:GetInstance():InitModel(show[2], show[3], self.model_con, handler(self,self.Weapon_CallBack), nil, 1)
				end
			end
		else
			SetVisible(self.model_img, true)
			SetVisible(self.model_con, false)
			lua_resMgr:SetImageTexture(self,self.model_img, 'search_treasure_image', self.act_id .. "")
			self:PlayAni()
		end
	else
		SetVisible(self.model_img, false)
		SetVisible(self.model_con, false)
	end
	if cost then
		local item_id = cost[1][2]
		local icon = Config.db_item[item_id].icon
		GoodIconUtil.GetInstance():CreateIcon(self, self.moneyicon, icon, true)
		GoodIconUtil.GetInstance():CreateIcon(self, self.moneyicon2, icon, true)
		self.item_id = item_id
		self.cost = cost
		self.moneynum.text = string.format("×%s", cost[1][3])
		self.pre_txt = string.format("×%s", cost[1][3])
		self.moneynum2.text = string.format("×%s", cost[2][3])
	end
end

function YYLotteryPanel:Mount_CallBack()
	self.model_info:AddAnimation({"show","idle"},false,"idle",0)
	SetLocalPosition(self.model_info.transform, -5982, -6070.9, 242)
	SetLocalRotation(self.model_info.transform, 0, 185, 0)
end

function YYLotteryPanel:Fabao_CallBack()
	SetLocalPosition(self.model_info.transform, -5995, -5985, 0)
end

function YYLotteryPanel:Weapon_CallBack()
	SetLocalPosition(self.model_info.transform, -5986.47, -6015, 50.55)
end
function YYLotteryPanel:Wing_CallBack()
	SetLocalPosition(self.model_info.transform, -6000, -5950, 300)
end

function YYLotteryPanel:FuShou_CallBack()
	SetLocalPosition(self.model_info.transform, -6029, -5983, 158.7)
end

function YYLotteryPanel:Shenbing_CallBack()
	SetLocalPosition(self.model_info.transform, -6011.21, -5946, 28.6)
	SetLocalRotation(self.model_info.transform, 8.36, -200.6, -3.3)
end

function YYLotteryPanel:PlayAni()
    local action = cc.MoveTo(1, 1.569611, 42.99981)
    action = cc.Sequence(action, cc.MoveTo(1, 1.569611, 26.99981))
    action = cc.Repeat(action, 4)
    action = cc.RepeatForever(action)
    cc.ActionManager:GetInstance():addAction(action, self.model_img.transform)
end

function YYLotteryPanel:SortScroll()
    local function update_func()
        local c_item, p_item
        for i = 1, #self.item_list do
            c_item = self.item_list[i]
            if i == 1 then
                c_item.transform.anchoredPosition = Vector2(-236, 0)
            else
                p_item = self.item_list[i - 1]
                c_item.transform.anchoredPosition = Vector2(p_item.transform.anchoredPosition.x + 86, 0)
            end
        end
    end
    self.schedule_id2 = GlobalSchedule:StartOnce(update_func, 0.1)
end

function YYLotteryPanel:AutoScroll()
    if self.schedule_id then
        return
    end
    local function update_func()
        local last_item = self.item_list[#self.item_list]
        if not last_item.transform then
            return
        end
        for i = 1, #self.item_list do
            local item = self.item_list[i]
            item.transform.anchoredPosition = Vector2(item.transform.anchoredPosition.x - 1, item.transform.anchoredPosition.y)
        end
        if self.item_list[1].transform.anchoredPosition.x <= -300 then
            local item = table.remove(self.item_list, 1)
            item.transform.anchoredPosition = Vector2(self.item_list[#self.item_list].transform.anchoredPosition.x + 86, item.transform.anchoredPosition.y)
            table.insert(self.item_list, item)
        end
    end
    self.schedule_id = GlobalSchedule:Start(update_func, 0.02)
end

function YYLotteryPanel:UpdateYYInfo()
	local rewards = OperateModel:GetInstance():GetRewardConfig(self.act_id)
	local sort_rewards = {}
	for _, reward in pairs(rewards) do
		sort_rewards[#sort_rewards+1] = reward
	end
	local function sort(a, b)
		return a.id < b.id
	end
	table.sort(sort_rewards, sort)
	for i=1, #sort_rewards do
		local item = self.leiji_list[i] or YYLotteryRewardItem(self.leiji_content)
		item:SetData(sort_rewards[i])
		self.leiji_list[i] = item
	end
	--self.Slider_com.maxValue = tonumber(sort_rewards[1].name)
end

function YYLotteryPanel:CloseCallBack()
	if self.schedule_id then
		GlobalSchedule:Stop(self.schedule_id)
	end
	if self.rare_item then
		self.rare_item:destroy()
		self.rare_item = nil
	end
	for i=1, #self.item_list do
		self.item_list[i]:destroy()
	end
	self.item_list = nil
	if self.coundownitem then
		self.coundownitem:destroy()
		self.coundownitem = nil
	end
	if self.model_info then
		self.model_info:destroy()
		self.model_info = nil 
	end
	for i = 1, #self.msg_list do
        self.msg_list[i]:destroy()
    end
    self.msg_list = nil
    for i = 1, #self.msg_list2 do
        self.msg_list2[i]:destroy()
    end
    self.msg_list2 = nil
    for i=1, #self.leiji_list do
    	self.leiji_list[i]:destroy()
    end
    self.leiji_list = nil

	self.model:RemoveTabListener(self.events)
	self.events = nil
	if self.effect then
		self.effect:destroy()
		self.effect = nil
	end
	if self.texlayer then
		self.texlayer:destroy()
		self.texlayer = nil
	end
	GlobalEvent:RemoveTabListener(self.global_events)
	self.global_events = nil
	if self.model_con_img then
		self.model_con_img.texture = nil
		ReleseRenderTexture(self.render_texture)
		self.render_texture = nil
	end
	if self.Camera_com then
		self.Camera_com.targetTexture = nil
	end
	self.pre_txt = nil
	if self.reddot then
		self.reddot:destroy()
		self.reddot = nil
	end
end

function YYLotteryPanel:UpdateMessages(msg_list, parent_node, messages)
	local height = 0
    for i = 1, #messages do
        local item = msg_list[i] or YYSTMessageItem(parent_node)
        item:SetData(messages[i])
        msg_list[i] = item
        height = height + item:GetHeight()
    end
    if #msg_list > #messages then
        for i = #msg_list, #messages + 1, -1 do
        	height = height - msg_list[i]:GetHeight()
            msg_list[i]:destroy()
            msg_list[i] = nil
        end
    end
    SetLocalPosition(parent_node.transform, parent_node.transform.anchoredPosition.x, height, 0)
end