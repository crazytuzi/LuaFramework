-- --------------------------------------------------------------------
-- 首充界面
-- --------------------------------------------------------------------
ActionFirstChargeWindow = ActionFirstChargeWindow or BaseClass(BaseView)

local controller = ActionController:getInstance()
local model = controller:getModel()
function ActionFirstChargeWindow:__init()
	self.win_type = WinType.Big
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.layout_name = "action/action_first_charge_window"
	self.tab_list = {}	
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("firstcharge", "firstcharge"), type = ResourcesType.plist},
		{path = PathTool.getPlistImgForDownLoad("bigbg/action", "txt_cn_action_bigbg_1"), type = ResourcesType.single},
	}
	self.cur_index = nil
	self.item_list = {}
	self.item_reward_list = {}
	for i=1,3 do
		self.item_reward_list[i] = {}
	end
end

function ActionFirstChargeWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
	self.background:setScale(display.getMaxScale())
	
	self.main_container = self.root_wnd:getChildByName("main_container")
	self:playEnterAnimatianByObj(self.main_container)
	local container = self.main_container:getChildByName("container")
	container:setPositionY(display.getTop())

	self.close_btn = container:getChildByName("close_btn")
	self.title_img = container:getChildByName("title_img")

	self.btn_return = container:getChildByName("btn_return")
	self.return_title = self.btn_return:getChildByName("Sprite_2")
	self.remain_charge = container:getChildByName("remain_charge")
	self.remain_charge:setVisible(false)

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
			object.title:setString(TI18N("第")..i..TI18N("天免费领"))
			object.list = {}
			self.item_list[i] = object 
		end
	end
	self.container = container
	self.switch_effect = createEffectSpine(PathTool.getEffectRes(350),cc.p(self.btn_return:getPositionX(),self.btn_return:getPositionY()),cc.p(0.5, 0.5),true,"action")
	self.switch_effect:setVisible(false)
	self.container:addChild(self.switch_effect)
end

function ActionFirstChargeWindow:openRootWnd(index)
	index = index or 1
	self:changeTabView(index)
	controller:sender21000()
end

function ActionFirstChargeWindow:changeTabView(index)
	self.cur_index = index
	local num = 3 + index
	loadSpriteTexture(self.title_img, PathTool.getResFrame("firstcharge","txt_cn_firstcharge_"..num), LOADTEXT_TYPE_PLIST)
	num = 1 + index
	loadSpriteTexture(self.return_title, PathTool.getResFrame("firstcharge","txt_cn_firstcharge_"..num), LOADTEXT_TYPE_PLIST)

	local first_data = model:getFirstRechargeData(index)
	self:fillItemList(first_data)

	if self.cur_index == 2 then
		self.switch_effect:setVisible(false)
		local role_vo = RoleController:getInstance():getRoleVo()
		local charge_num = (1000-role_vo.vip_exp)*0.1
		local visible = true
		if charge_num <= 0 then
			charge_num = 0
			visible = false
		end
		self.remain_charge:setVisible(visible)
		local str = string.format(TI18N("还需充值: %d元"),charge_num)
		self.remain_charge:setString(str)
	else
		self.switch_effect:setVisible(true)
		self.remain_charge:setVisible(false)
	end

	local start_pos = 4
	local end_pos = 6
	if self.cur_index == 2 then
		start_pos = 1
		end_pos = 3
	end
	--计算累充是否有可领取
	local status = false
	for i=start_pos,end_pos do
		local get_data = ActionController:getInstance():getModel():getFirstBtnStatus(i)
		if get_data then
			if get_data == 1 then
				status = true
				break
			end
		end
	end
	addRedPointToNodeByStatus(self.btn_return,status)
	
	if self.updata_charge_data then
		self:updateData(self.updata_charge_data)
	end
end

function ActionFirstChargeWindow:fillItemList(list)
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

function ActionFirstChargeWindow:register_event()
	registerButtonEventListener(self.close_btn, function()
		controller:openFirstChargeView(false)
	end, false, 2)

	registerButtonEventListener(self.btn_return, function()
		if self.cur_index == 1 then
			self.cur_index = 2
		elseif self.cur_index == 2 then
			self.cur_index = 1
		end
		self:changeTabView(self.cur_index)
	end, true, 2)

	registerButtonEventListener(self.btn_recharge, function()
		local first_data = model:getFirstRechargeData(self.cur_index)
		if self.get_gift_id == 0 then
			VipController:getInstance():openVipMainWindow(true, VIPTABCONST.CHARGE)
			--MallController:getInstance():openChargeShopWindow(true, MallConst.Charge_Shop_Type.Diamond)
		elseif self.get_gift_id == 1 then
			if first_data[self.gift_index] then
				controller:sender21001(first_data[self.gift_index].id)
			end
		else
			controller:openFirstChargeView(false)
		end
	end, true, 1)

	self:addGlobalEvent(ActionEvent.Update_First_Charge_Status, function(data)
		self.updata_charge_data = data
		self:updateData(data)
	end)
end


function ActionFirstChargeWindow:updateData(data)
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

	if self.cur_index == 2 then
		--当为累充界面时，需要判断首充是否有可领取的状态
		local status = false
		local is_first = 0
		for i,v in pairs(status_list[1]) do
			local sts = model:getFirstBtnStatus(v)
			if sts == 1 or sts == 2 then
				is_first = 1
			end
			if sts == 1 then
				status = true
				break
			end
		end
		if is_first == 0 then --判断用户是否激活的时候
			status = true
		end
		self.switch_effect:setVisible(status)
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

function ActionFirstChargeWindow:close_callback()
	doStopAllActions(self.main_container)
	for i=1,3 do
		for i,item in pairs(self.item_reward_list[i]) do
			item:DeleteMe()
		end
		self.item_reward_list[i] = nil
	end
	self.item_reward_list = {}
	if self.switch_effect then
        self.switch_effect:clearTracks()
        self.switch_effect:removeFromParent()
        self.switch_effect = nil
    end
	controller:openFirstChargeView(false)
end 