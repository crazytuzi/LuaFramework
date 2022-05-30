-- --------------------------------------------------------------------
-- 新版首充界面（宝可梦3选1的）
-- --------------------------------------------------------------------
NewFirstChargeWindow = NewFirstChargeWindow or BaseClass(BaseView)

local color_text = {
	[1] = cc.c4b(0xff,0xff,0xff,0xff),
	[2] = cc.c4b(0x71,0x00,0x42,0xff),
	[3] = cc.c4b(0xc4,0x5a,0x14,0xff),
	[4] = cc.c4b(0x25,0x55,0x05,0xff),
}
local controller = NewFirstChargeController:getInstance()
local model = controller:getModel()
local string_format = string.format
function NewFirstChargeWindow:__init()
	self.win_type = WinType.Big
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.layout_name = "newfirstcharge/newfirstcharge_window"
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("newfirstcharge", "newfirstcharge"), type = ResourcesType.plist},
		{path = PathTool.getPlistImgForDownLoad("bigbg/action","txt_cn_action_bigbg_3"), type = ResourcesType.single},
	}
	self.action_fadein_1 = true
	self.action_fadein_2 = true
	self.action_fadeout_1 = true
	self.action_fadeout_2 = true
	self.cur_index = nil
	self.item_list = {}
	self.item_reward_list = {}
	for i=1,3 do
		self.item_reward_list[i] = {}
	end
end

function NewFirstChargeWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
	self.background:setScale(display.getMaxScale())
	
	self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 2) 
	local container = self.main_container:getChildByName("container")
	container:setPositionY(display.getTop())

	local bg = container:getChildByName("bg")
	local res = PathTool.getPlistImgForDownLoad("bigbg/action","txt_cn_action_bigbg_3")
	if not self.item_load then
		self.item_load = loadSpriteTextureFromCDN(bg, res, ResourcesType.single, self.item_load)
	end

	self.close_btn = container:getChildByName("close_btn")
	self.title_img = container:getChildByName("title_img")
	self.remain_charge = container:getChildByName("remain_charge")
	self.remain_charge:setString(TI18N("已累充: "))

	self.btn_recharge = container:getChildByName("btn")
	self.btn_label = self.btn_recharge:getChildByName("label")
	self.btn_label:setString(TI18N("前往充值"))

	model:setFirstRechargeData()

	for i=1,3 do
		local item = container:getChildByName("item_"..i)
		if item then
			local object = {}
			object.scroll = item:getChildByName("scroll")
			object.scroll:setScrollBarEnabled(false)
			object.finish_icon = item:getChildByName("finish_icon")
			object.finish_icon:setVisible(false)
			object.title = item:getChildByName("title")
			local str = string_format(TI18N("第%d天免费领"),i)
			object.title:setString(str)
			object.list = {}
			self.item_list[i] = object
		end
	end

	self.tab_view = {}
	for i=1,2 do
		local tab = {}
		tab.btn = container:getChildByName("btn_grade_"..i)
		tab.normal = tab.btn:getChildByName("normal")
		tab.select = tab.btn:getChildByName("select")
		tab.select:setVisible(false)
		tab.title = tab.btn:getChildByName("title")
		tab.title:setTextColor(color_text[1])
		tab.title:enableOutline(color_text[2],2)
		tab.title_barner = container:getChildByName("title_img_"..i)
		tab.title_barner:setOpacity(0)
		tab.index = i
		self.tab_view[i] = tab
	end

	self.tab_get_hero = {}
	for i=1,3 do
		local tab = {}
		tab.btn = container:getChildByName("btn_"..i)
		tab.title = tab.btn:getChildByName("Text_1")
		tab.get = container:getChildByName("get_"..i)
		tab.get:setVisible(false)
		tab.index = i
		self.tab_get_hero[i] = tab
	end
end

function NewFirstChargeWindow:openRootWnd(index)
	index = index or 1
	self:changeTabView(index)
	controller:sender21012()
end

function NewFirstChargeWindow:changeTabView(index)
	index = index or 1
	if self.cur_index == index then return end
	if self.tab_index ~= nil then
		self.tab_index.normal:setVisible(true)
		self.tab_index.select:setVisible(false)
		self.tab_index.title:enableOutline(color_text[2],2)
	end
	self.tab_index = self.tab_view[index]
	if self.tab_index ~= nil then
		self.tab_index.normal:setVisible(false)
		self.tab_index.select:setVisible(true)
		self.tab_index.title:enableOutline(color_text[3],2)
	end

	self.cur_index = index

	self:titleBarnerAction(index)

	local first_data = model:getFirstRechargeData(index)
	self:fillItemList(first_data)
	
	if self.updata_charge_data then
		self:updateData(self.updata_charge_data)
	end
end

--标题动作
function NewFirstChargeWindow:titleBarnerAction(index)
	local time_in = 1
	local time_out = 0.4
	self:stopAllActions()
	if index == 1 then
		local fadein = cc.FadeIn:create(time_in)
		self.tab_view[2].title_barner:setOpacity(0)
		self.tab_view[1].title_barner:runAction(fadein)
	elseif index == 2 then
		local fadein = cc.FadeIn:create(time_in)
		self.tab_view[1].title_barner:setOpacity(0)
		self.tab_view[2].title_barner:runAction(fadein)
	end
end

function NewFirstChargeWindow:stopAllActions()
	for i,v in pairs(self.tab_view) do
		doStopAllActions(v.title_barner)
	end
end

function NewFirstChargeWindow:fillItemList(list)
	local scale = 0.8
	local size = 119 * scale
	local create_index = 1
	for i=1, tableLen(list) do
		local object = self.item_list[i]
		local num = tableLen(list[i].item_list)
        object.scroll:setInnerContainerSize(cc.size(size*num, object.scroll:getContentSize().height))
		for k=1, num do
			delayRun(self.main_container, create_index/15, function()
				local _x = size * k - size * 0.5
				local _y = size * 0.5
				if not self.item_reward_list[i][k] then
					self.item_reward_list[i][k] = BackPackItem.new(false, true, false, scale, false, true)
					object.scroll:addChild(self.item_reward_list[i][k])
				end
				if self.item_reward_list[i][k] then
					self.item_reward_list[i][k]:setPosition(_x, _y)
					self.item_reward_list[i][k]:setBaseData(list[i].item_list[k][1],list[i].item_list[k][2])
				end
			end)
			create_index = create_index + 1
		end
	end
end

function NewFirstChargeWindow:register_event()
	registerButtonEventListener(self.close_btn, function()
		controller:openNewFirstChargeView(false)
	end, false, 2)

	registerButtonEventListener(self.btn_recharge, function()
		local first_data = model:getFirstRechargeData(self.cur_index)
		if self.get_gift_id == 0 then
			VipController:getInstance():openVipMainWindow(true, VIPTABCONST.CHARGE)
			--MallController:getInstance():openChargeShopWindow(true, MallConst.Charge_Shop_Type.Diamond)
		elseif self.get_gift_id == 1 then
			if first_data[self.gift_index] then
				controller:sender21013(first_data[self.gift_index].id)
			end
		else
			controller:openNewFirstChargeView(false)
		end
	end, true, 1)

	for i,v in pairs(self.tab_view) do
		registerButtonEventListener(v.btn, function()
			self:changeTabView(v.index)
		end,true,1)
	end
	for i,v in pairs(self.tab_get_hero) do
		registerButtonEventListener(v.btn, function()
			if v.index and self.updata_charge_data then
				if self.updata_charge_data.choosen_status == 1 then
					local list = {20501,30506,10505}
					local role_data = Config.PartnerData.data_partner_base[list[v.index]]
					if role_data then
						local str = string_format(TI18N("<div fontcolor='#643223'>是否确定选择</div> <div fontcolor='#bc3f0e' fontsize=26>%s</div> <div fontcolor='#643223'>作为奖励？\n</div> <div fontcolor='#643223'>  确定后其它宝可梦将不可领取</div>"),role_data.name)
						CommonAlert.show(str,TI18N("确定"),function()
							controller:sender21014(v.index)
						end,TI18N("取消"),nil,CommonAlert.type.rich,nil,nil,26)
					end
				else
					controller:sender21014(v.index)
				end
			end
		end,true,1)
	end

	self:addGlobalEvent(NewFirstChargeEvent.New_First_Charge_Event, function(data)
		self.updata_charge_data = data
		if data.choosen_status and data.has_choosen_id then
			self:getChooseHeroStatus(data.choosen_status, data.has_choosen_id)
		end

		local role_vo = RoleController:getInstance():getRoleVo()
		local totle_str = string_format(TI18N("已累充: %d"),math.floor(role_vo.vip_exp*0.1))
		self.remain_charge:setString(totle_str)
		
		self:setRedPointTab()
		self:updateData(data)
	end)
end
--红点
function NewFirstChargeWindow:setRedPointTab()
	local status_1 = false
	for i=1,3 do
		local get_data = model:getFirstBtnStatus(i)
		if get_data then
			if get_data == 1 then
				status_1 = true
				break
			end
		end
	end
	addRedPointToNodeByStatus(self.tab_view[1].btn,status_1)
	local status_2 = false
	for i=4,6 do
		local get_data = model:getFirstBtnStatus(i)
		if get_data then
			if get_data == 1 then
				status_2 = true
				break
			end
		end
	end
	addRedPointToNodeByStatus(self.tab_view[2].btn,status_2)
end

--选择宝可梦按钮
function NewFirstChargeWindow:getChooseHeroStatus(status, choose_id)
	for i=1,3 do
		if status == 0 then
			self.tab_get_hero[i].get:setVisible(false)
			self.tab_get_hero[i].btn:setVisible(true)
			setChildUnEnabled(true, self.tab_get_hero[i].btn, color_text[1])
		elseif status == 1 then
			self.tab_get_hero[i].get:setVisible(false)
			self.tab_get_hero[i].btn:setVisible(true)
			setChildUnEnabled(false, self.tab_get_hero[i].btn, color_text[4])
		elseif status == 2 then
			self.tab_get_hero[i].btn:setVisible(false)
			if i == choose_id then
				self.tab_get_hero[i].get:setVisible(true)
			end
		end
	end
end

function NewFirstChargeWindow:updateData(data)
	if data == nil then return end
	local status_list = {{1,2,3},{4,5,6}}
	local charge_list = {}
	for i,v in ipairs(status_list[self.cur_index]) do
		local status = model:getFirstBtnStatus(v)
		charge_list[i] = status
		self.item_list[i].finish_icon:setVisible(status==2)
	end

	self.gift_index = 0 --领取的位置
	local totle = 0
	self.get_gift_id = 10
	for i,v in ipairs(charge_list) do
		totle = totle + v
		if v == 1 then
			self.get_gift_id = 1
			self.gift_index = i
		end
	end

	if totle == 0 then
		self.get_gift_id = 0
		self.btn_label:setString(TI18N("前往充值"))
	elseif totle == 1 or totle == 3 or totle == 5 then
		self.btn_label:setString(TI18N("领取奖励"))
	elseif totle == 2 or totle == 4 then
		self.btn_label:setString(TI18N("明日再来"))
	elseif totle == 6 then
		self.btn_label:setString(TI18N("领取完毕"))
	end
end

function NewFirstChargeWindow:close_callback()
	doStopAllActions(self.main_container)
	self:stopAllActions()
	for i=1,3 do
		for i,item in pairs(self.item_reward_list[i]) do
			item:DeleteMe()
		end
		self.item_reward_list[i] = nil
	end
	self.item_reward_list = {}
	if self.item_load then
        self.item_load:DeleteMe()
    end
    self.item_load = nil
	controller:openNewFirstChargeView(false)
end 