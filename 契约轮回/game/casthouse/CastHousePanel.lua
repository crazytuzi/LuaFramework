CastHousePanel = CastHousePanel or class("CastHousePanel",BasePanel)
local CastHousePanel = CastHousePanel

function CastHousePanel:ctor()
	self.abName = "casthouse"
	self.assetName = "CastHousePanel"
	self.layer = "UI"

	self.use_background = true
	self.change_scene_close = true
	self.panel_type = 2

	self.boxes = {}
	self.events = {}
	self.global_events = {}
	self.item_list = {}
	self.goods_list = {}
	self.sprite_list = {}

	self.model = CasthouseModel:GetInstance()
end

function CastHousePanel:dctor()
end

function CastHousePanel:Open( )
	CastHousePanel.super.Open(self)
end

function CastHousePanel:LoadCallBack()
	self.nodes = {
		"btnclose","grids/grid1","grids/grid2","grids/grid3","grids/grid4","grids/grid5","grids/grid6","grids/grid7","grids/grid8",
		"grids/grid9","grids/grid10","grids/grid11","grids/grid12","grids/grid13","grids/grid14","grids/grid15","grids/grid16",
		"grids/grid17","grids/grid18","grids/grid19","grids/grid20","grids/grid21","grids/grid22","grids/grid23","grids/grid24",
		"grids/grid25","sure/sure1","sure/sure2","bg2/reset_count","bg2/max_count","bg2/vip","tipsbtn","pinkbtn",
		"startbtn","ScrollView/Viewport/Content","item_num","Label","sezi","grids", "resettbtn",
		"grids/CastHouseItem","title_item/item_num2","title_item/item_num3","title_item",
	}
	self:GetChildren(self.nodes)

	self:InitBoxArray()
	self.item_num_txt = GetText(self.item_num)
	self.Label = GetText(self.Label)
	self.reset_count = GetText(self.reset_count)
	self.max_count = GetText(self.max_count)
	self.vip = GetText(self.vip)
	self.sezi = GetImage(self.sezi)
	self.CastHouseItem_go = self.CastHouseItem.gameObject
	self.item_num2 = GetText(self.item_num2)
	self.item_num3 = GetText(self.item_num3)
	SetVisible(self.CastHouseItem_go, false)
	self:AddEvent()
	self:LoadSprite()
	CasthouseController:GetInstance():RequestInfo()
end

function CastHousePanel:InitBoxArray()
	self.grid1 = GetImage(self.grid1)
	self.grid2 = GetImage(self.grid2)
	self.grid3 = GetImage(self.grid3)
	self.grid4 = GetImage(self.grid4)
	self.grid5 = self.grid5
	self.grid6 = GetImage(self.grid6)
	self.grid7 = GetImage(self.grid7)
	self.grid8 = GetImage(self.grid8)
	self.grid9 = GetImage(self.grid9)
	self.grid10 = self.grid10
	self.grid11 = GetImage(self.grid11)
	self.grid12 = GetImage(self.grid12)
	self.grid13 = GetImage(self.grid13)
	self.grid14 = GetImage(self.grid14)
	self.grid15 = self.grid15
	self.grid16 = GetImage(self.grid16)
	self.grid17 = GetImage(self.grid17)
	self.grid18 = GetImage(self.grid18)
	self.grid19 = GetImage(self.grid19)
	self.grid20 = self.grid20
	self.grid21 = GetImage(self.grid21)
	self.grid22 = GetImage(self.grid22)
	self.grid23 = GetImage(self.grid23)
	self.grid24 = GetImage(self.grid24)
	self.grid25 = GetImage(self.grid25)
	table.insert(self.boxes, self.grid1)
	table.insert(self.boxes, self.grid2)
	table.insert(self.boxes, self.grid3)
	table.insert(self.boxes, self.grid4)
	table.insert(self.boxes, self.grid5)
	table.insert(self.boxes, self.grid6)
	table.insert(self.boxes, self.grid7)
	table.insert(self.boxes, self.grid8)
	table.insert(self.boxes, self.grid9)
	table.insert(self.boxes, self.grid10)
	table.insert(self.boxes, self.grid11)
	table.insert(self.boxes, self.grid12)
	table.insert(self.boxes, self.grid13)
	table.insert(self.boxes, self.grid14)
	table.insert(self.boxes, self.grid15)
	table.insert(self.boxes, self.grid16)
	table.insert(self.boxes, self.grid17)
	table.insert(self.boxes, self.grid18)
	table.insert(self.boxes, self.grid19)
	table.insert(self.boxes, self.grid20)
	table.insert(self.boxes, self.grid21)
	table.insert(self.boxes, self.grid22)
	table.insert(self.boxes, self.grid23)
	table.insert(self.boxes, self.grid24)
	table.insert(self.boxes, self.grid25)
end

function CastHousePanel:LoadSprite()
	local arr_spirite = {"saizi_1_2","saizi_2_2","saizi_3_2","saizi_4_2",
		"saizi_5_2","saizi_6_2","saizi_7_2","saizi_8_2","saizi_9_2",
	"saizi_1","saizi_2","saizi_3","saizi_4","saizi_5","saizi_6"}
	
	for i=1, #arr_spirite do
		local function call_back(objs)
	        self.sprite_list[i] = objs[0]
	    end
        lua_resMgr:LoadSprite(self, 'saizi_image', arr_spirite[i], call_back)
    end
end


function CastHousePanel:AddEvent()
	local function call_back(data)
		self.grid = data.grid
		self.count = data.count
		self.reset = data.reset_count
		self.free_count = data.sezi_count
		self.turn = data.turn
		self.num = data.num
		self:UpdateView()
	end
	self.events[#self.events+1] = self.model:AddListener(CasthouseEvent.UpdateInfo, call_back)

	local function call_back(data)
		self.num = data.num
		self.free_count = data.sezi_count
		self:UpdateCost()
		self:UpdateSezi(true)
	end
	self.events[#self.events+1] = self.model:AddListener(CasthouseEvent.UpdateSezi, call_back)

	local function call_back(data)
		self.grid = data.grid
		local item_ids = data.item_ids
		self:PlayGridReward(item_ids)
		self:UpdateButtons()
	end
	self.events[#self.events+1] = self.model:AddListener(CasthouseEvent.UpdateGrid, call_back)

	local function call_back(is_hide)
		SetVisible(self.pet_model, not is_hide)
	end
	--self.events[#self.events+1] = self.model:AddListener(CasthouseEvent.UpdatePetModel, call_back)

	local function call_back( ... )
		self:UpdateCost()
	end
	self.global_events[#self.global_events+1] = GlobalEvent:AddListener(BagEvent.UpdateGoods, call_back)

	local function call_back(cname, layer)
		if cname ~= "DialogPanel" and cname ~= "GiftSelectPanel" and cname ~= "BatchUsePanel"
		 and cname ~= "CasthouseResultPanel" then
			return
		end
		if layer=="UI" or layer=="Top" then
			SetVisible(self.pet_model, false)
		end
	end
	--self.global_events[#self.global_events+1] = GlobalEvent:AddListener(EventName.OpenPanel, call_back)

	local function call_back(cname, layer)
		if cname ~= "DialogPanel" and cname ~= "GiftSelectPanel" and cname ~= "BatchUsePanel" 
		 and cname ~= "CasthouseResultPanel" then
			return
		end
		if self:IsHavePanelOpened()then
			return
		end
		if layer=="UI" or layer=="Top" then
			SetVisible(self.pet_model, true)
		end
	end
	--self.global_events[#self.global_events+1] = GlobalEvent:AddListener(EventName.ClosePanel, call_back)

	local function call_back(target,x,y)
		self:Close()
	end
	AddClickEvent(self.btnclose.gameObject,call_back)

	local function call_back()
		local cfg = Config.db_casthouse[1]
		local maxfreecount = cfg.free_count
		if self.free_count >= maxfreecount then
			local cost = String2Table(cfg.cost)[1]
			local item_id = cost[1]
			local need_num = cost[2]
			local had_num = BagController:GetInstance():GetItemListNum(item_id)
			local need_gold = (need_num - had_num) * Config.db_voucher[item_id].price
			if need_gold > 0 then
				local function ok_func()
					local vo = RoleInfoModel:GetInstance():CheckGold(need_gold, Constant.GoldType.Gold)
					if not vo then
						return
					end
					CasthouseController:GetInstance():RequestStart()
				end
				local message = string.format("Insufficient Coupons,\r\nSpend <color=#22980A>%s diamond</color> in toss Dice?", need_gold)
				Dialog.ShowTwo("Tip", message, "Confirm", ok_func, nil, nil, nil, nil, "Don't notice anymore until next time I log in", false, nil, self.__cname)
			else
				CasthouseController:GetInstance():RequestStart()
			end
		else
			CasthouseController:GetInstance():RequestStart()
		end
	end
	AddButtonEvent(self.startbtn.gameObject, call_back)

	local function call_back(target,x,y)
		if self.reset >= self.max_reset_count then
			return Notify.ShowText("Today's reset attempts used out")
		end
		local cfg = Config.db_casthouse[1]
		local cost = String2Table(cfg.reset_cost)[1]
		local need_gold = cost[2]
		local function ok_func()
			local vo = RoleInfoModel:GetInstance():CheckGold(need_gold, Constant.GoldType.Gold)
			if not vo then
				return
			end
			CasthouseController:GetInstance():RequestReset()
			SetVisible(self.pet_model, true)
		end
		local message = string.format("It needs consume %s diamond, continue?", need_gold)
		local function cancel_func()
			SetVisible(self.pet_model, true)
		end
		Dialog.ShowTwo("Tip",message,"Confirm",ok_func, nil, nil, cancel_func)
	end
	AddButtonEvent(self.resettbtn.gameObject,call_back)

	local function call_back(target,x,y)
		OpenLink(120, 1, 1, 5, 5, "true")
	end
	AddClickEvent(self.pinkbtn.gameObject,call_back)

	local function call_back(target,x,y)
		ShowHelpTip(HelpConfig.casthouse.Help, true)
	end
	AddClickEvent(self.tipsbtn.gameObject,call_back)

	local function call_back()
		if self.pet_model and self.pet_model.gameObject then
			local flag = self:IsHavePanelOpened()
			SetVisible(self.pet_model, not flag)
		end
	end
	self.schedule_id = GlobalSchedule:Start(call_back, 0.5)
end

function CastHousePanel:IsHavePanelOpened()
	local panel1 = lua_panelMgr:GetPanel(DialogPanel)
	local panel2 =lua_panelMgr:GetPanel(GiftSelectPanel)
	local panel3 =lua_panelMgr:GetPanel(BatchUsePanel)
	local panel4 =lua_panelMgr:GetPanel(CasthouseResultPanel)
	return (panel1 and panel1.gameObject.activeInHierarchy) or panel2 or panel3 or panel4
end

function CastHousePanel:OpenCallBack()
	--self:UpdateView()
end

function CastHousePanel:UpdateView( )
	self:ShowBox()
	self:UpdateCost()
	self:UpdateDropShow()
	self:UpdateModelPos()
	self:UpdateButtons()
	self:UpdateSezi()
	self:UpdateResetCount()
end

function CastHousePanel:CloseCallBack(  )
	for i=1, #self.boxes do
		self.boxes[i] = nil
	end
	self.boxes = nil
	if self.goodsitem1 then
		self.goodsitem1:destroy()
		self.goodsitem1 = nil
	end
	if self.goodsitem2 then
		self.goodsitem2:destroy()
		self.goodsitem2 = nil
	end
	for i=1, #self.item_list do
		self.item_list[i]:destroy()
	end
	self.item_list = nil
	for i=1, #self.goods_list do
		self.goods_list[i]:destroy()
	end
	self.goods_list = nil
	self.model:RemoveTabListener(self.events)
	if self.pet_model then
		self.pet_model:destroy()
		self.pet_model = nil
	end
	if self.lua_link_text then
		self.lua_link_text:destroy()
		self.lua_link_text = nil
	end
	if self.action then
        cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.sezi)
        self.action = nil
    end
    for i=1, #self.sprite_list do
    	self.sprite_list[i] = nil
    end
    self.sprite_list = nil
    GlobalEvent:RemoveTabListener(self.global_events)
    self.global_events = nil
    if self.schedule_id then
    	GlobalSchedule:Stop(self.schedule_id)
    	self.schedule_id = nil
    end
end

function CastHousePanel:UpdateResetCount()
	local vip = RoleInfoModel:GetInstance():GetMainRoleVipLevel()
	local key = string.format("vip%s", vip)
	local rightscfg = Config.db_vip_rights[enum.VIP_RIGHTS.VIP_RIGHTS_CAST_RESET] or {}
	local max_count = tonumber(rightscfg[key] or 0)
	local left_count = max_count - self.reset
	self.reset_count.text = left_count
	local show_vip = vip
	for i=vip, 12 do
		key = string.format("vip%s", i)
		local count = tonumber(rightscfg[key] or 0)
		if count > max_count then
			show_vip = i
			max_count = count
			break
		end 
	end
	self.vip.text = string.format("VIP %s", show_vip)
	self.max_count.text = max_count
	self.max_reset_count = max_count
end

function CastHousePanel:PlayGridReward(item_ids)
	local cfg = Config.db_casthouse_grid[self.grid]
	if cfg.res ~= "box2" then
		local res = cfg.res .. "-2"
		lua_resMgr:SetImageTexture(self,self.boxes[self.grid], 'casthouse_image', res)
	end
	local pos = String2Table(cfg.pos)
	for i=1, #item_ids do
		local item_id = item_ids[i]
		local action1 = cc.MoveTo(0.5, pos[1], pos[2]+60)
		local action2 = cc.MoveTo(0.3, pos[1], pos[2]+60)
		local action3 = cc.MoveTo(2, 570.14, -170)
		local icon = CastHouseItem(self.CastHouseItem_go, self.grids)
		icon:SetData(item_id, pos)
		local function call_back()
			icon:destroy()
			icon = nil
		end
		local action4 = cc.CallFunc(call_back)
		local action = cc.Sequence(action1, action2, action3, action4)
		cc.ActionManager:GetInstance():addAction(action, icon.transform)
	end
end

function CastHousePanel:UpdateSezi(is_animation)
	if is_animation then
		self:PlaySeziAnimate(self.num)
	else
		local num = (self.num == 0 and 6 or self.num)
		local res = string.format("saizi_%s", num)
		lua_resMgr:SetImageTexture(self,self.sezi, 'saizi_image', res)
	end
end


function CastHousePanel:PlaySeziAnimate(num)
    time = 1
    local last_sprite_index = num+9
    local delayperunit = 0.1
    local loop_count = 9
    local function start_action()
        if self.action then
            cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.sezi)
            self.action = nil
        end
        local action = cc.Animate(self.sprite_list, time, self.sezi, last_sprite_index, delayperunit, loop_count)
        cc.ActionManager:GetInstance():addAction(action, self.sezi)
        self.action = action
    end

    start_action()
    local function call_back()
    	local res = string.format("saizi_%s", num)
		lua_resMgr:SetImageTexture(self,self.sezi, 'saizi_image', res)
    	self:UpdateModelPos()
    end
    GlobalSchedule:StartOnce(call_back, 1.1)
end

function CastHousePanel:UpdateButtons()
	if not Config.db_casthouse_grid[self.grid+1] then
		SetVisible(self.startbtn, false)
		SetVisible(self.resettbtn, true)
	else
		SetVisible(self.startbtn, true)
		SetVisible(self.resettbtn, false)
	end
end

--更新模型位置
function CastHousePanel:UpdateModelPos()
	if not self.pet_model then
		local pet_id = Config.db_casthouse[1].model
		self.pet_model = UIPetModel(self.grids, pet_id, handler(self,self.LoadModelCallback), true)
	else
		self:LoadModelCallback()
		--self:MoveToPos()
	end
end

function CastHousePanel:LoadModelCallback()
	local pos = String2Table(Config.db_casthouse_grid[self.grid].pos)
	SetLocalPositionXY(self.pet_model.transform, pos[1], pos[2])
	SetLocalRotation(self.pet_model.transform, 0, 185, 0)
	self:MoveToPos()
end

local rotateY = 185
function CastHousePanel:MoveToPos()
	local time = self.num * 0.2
	local loop = self.num
	local grid = self.grid
	local actions = {}
	for i=1, loop do
		if Config.db_casthouse_grid[grid+i-1] and Config.db_casthouse_grid[grid+i] then
			local pos1 = String2Table(Config.db_casthouse_grid[grid+i-1].pos)
			local pos2 = String2Table(Config.db_casthouse_grid[grid+i].pos)

			local function start_call()
				local dir = Vector2(pos2[1], pos2[2]) - Vector2(pos1[1], pos1[2])
				local angle = Vector2.GetAngle(dir)
				--local angle = Vector2.Angle(dir, self.pet_model.transform.forward)
				local old = Vector3(0, angle-rotateY, 0)
				rotateY = angle
				self.pet_model.transform:Rotate(old)
			end
			local action3 = cc.CallFunc(start_call)
			actions[#actions+1] = action3
			local action1 = cc.MoveTo(0.4, pos2[1], pos2[2])
			actions[#actions+1] = action1
			local function end_call()
				CasthouseController:GetInstance():RequestReward()
			end
			local action2 = cc.CallFunc(end_call)
			actions[#actions+1] = action2
		end
	end
	if #actions > 0 then
		self.pet_model:AddAnimation({"run"}, true)
		local function end_run()
			--SetLocalRotation(self.pet_model.transform, 0, 185, 0)
			self.pet_model.transform:Rotate(Vector3(0,185-rotateY,0))
			rotateY = 185
			self.pet_model:AddAnimation({"attack1", "idle"}, false, "idle")
		end
		local action = cc.CallFunc(end_run)
		actions[#actions+1] = action
		local action = cc.Sequence(unpack(actions))
		cc.ActionManager:GetInstance():addAction(action, self.pet_model.transform)
	end
end

function CastHousePanel:UpdateCost()
	local cfg = Config.db_casthouse[1]
	local maxfreecount = cfg.free_count
	if self.free_count < maxfreecount  then
		self.item_num_txt.text = string.format("Free: %s/%s", maxfreecount-self.free_count, maxfreecount)
		SetVisible(self.title_item, false)
		SetVisible(self.item_num, true)
		self.Label.text = string.format("(%s free attempts everyday)", maxfreecount)
	else
		SetVisible(self.title_item, true)
		SetVisible(self.item_num, false)
		local cost = String2Table(cfg.cost)[1]
		local item_id = cost[1]
		self.item_num2.text = Config.db_voucher[item_id].price * cost[2]
		self.item_num3.text = string.format("(Coupons: %s)", BagController:GetInstance():GetItemListNum(item_id))
		self.Label.text = string.format("(A coupon can be used as %s diamond)", Config.db_voucher[item_id].price)
	end
end

function CastHousePanel:UpdateDropShow()
	local cfg = Config.db_casthouse[1]
	local drop_show = String2Table(cfg.drop_show)
	if #self.item_list == 0 then
		for i=1, #drop_show do
			local item_id = drop_show[i]
			local item = GoodsIconSettorTwo(self.Content)
			local param = {}
			param["item_id"] = item_id
			param["can_click"] = true
			param["bind"] = 2
			item:SetIcon(param)
			self.item_list[#self.item_list+1] = item
		end
	end
end

--显示宝箱
function CastHousePanel:ShowBox()
	local index = 1
	for i=1, #self.boxes do
		local cfg = Config.db_casthouse_grid[i]
		local res = cfg.res
		if res == "box2" then
			local param = {}
			param["item_id"] = String2Table(cfg.items)[1][2][1]
			param["can_click"] = true
			param["bind"] = 2
			param["color_effect"] = 3
			param["size"] = {x=70,y=70}
			if not self.goods_list[index] then
				self.goods_list[index] = GoodsIconSettorTwo(self.boxes[i])
			end 
			self.goods_list[index]:SetIcon(param)
			index = index + 1
		else
			if i <= self.grid then
				res = (res ~= "box2" and res .. "-2" or res)
				lua_resMgr:SetImageTexture(self,self.boxes[i], 'casthouse_image', res)
			else
				lua_resMgr:SetImageTexture(self,self.boxes[i], 'casthouse_image', res)
			end
		end
	end
	local items = String2Table(Config.db_casthouse_grid[25].items)
	local item_ids = {}
	for i=1, #items do
		local v = items[i]
		if self.turn >= v[1] then
			item_ids = v[2]
		end
	end
	if item_ids[1] then
		if not self.goodsitem1 then
			self.goodsitem1 = GoodsIconSettorTwo(self.sure1)
		end
		local param={}
		param["item_id"] = item_ids[1]
		param["can_click"] = true
		param["bind"] = 2
		param["color_effect"] = 3
		param["size"] = {x=70,y=70}
		self.goodsitem1:SetIcon(param)
	end
	if item_ids[2] then
		if not self.goodsitem2 then
			self.goodsitem2 = GoodsIconSettorTwo(self.sure2)
		end
		local param={}
		param["item_id"] = item_ids[2]
		param["can_click"] = true
		param["bind"] = 2
		param["color_effect"] = 3
		param["size"] = {x=70,y=70}
		self.goodsitem2:SetIcon(param)
	end
	
end