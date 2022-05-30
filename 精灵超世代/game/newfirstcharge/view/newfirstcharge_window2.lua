-- --------------------------------------------------------------------
--******** 文件说明 ********
-- @Author:      xhj 
-- @description: 新版首充界面（利维坦的）
-- @DateTime:    2020-03-10 9:47:05
-- *******************************
NewFirstChargeWindow2 = NewFirstChargeWindow2 or BaseClass(BaseView)

local color_text = {
	[1] = cc.c4b(0x82,0xcd,0xec,0xff),
	[2] = cc.c4b(0x1d,0x3c,0x7c,0xff),
	[3] = cc.c4b(0xff,0xff,0xff,0xff),
}
local controller = NewFirstChargeController:getInstance()
local model = controller:getModel()
local string_format = string.format
function NewFirstChargeWindow2:__init()
	self.win_type = WinType.Big
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.layout_name = "newfirstcharge/newfirstcharge_window2"
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("newfirstcharge1", "newfirstcharge1"), type = ResourcesType.plist},
		{path = PathTool.getPlistImgForDownLoad("bigbg/action","txt_cn_action_bigbg_6"), type = ResourcesType.single},
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
	--物品特效
	self.item_effect_list = {}
	for i=1,2 do
		self.item_effect_list[i] = {}
		for m=1,3 do
			self.item_effect_list[i][m] = {}
		end
	end
end

function NewFirstChargeWindow2:open_callback()
	self.background = self.root_wnd:getChildByName("background")
	self.background:setScale(display.getMaxScale())
	
	self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 2) 
	local container = self.main_container:getChildByName("container")
	-- container:setPositionY(display.getTop())

	local bg = container:getChildByName("bg")
	local res = PathTool.getPlistImgForDownLoad("bigbg/action","txt_cn_action_bigbg_6")
	if not self.bg_item_load then
		self.bg_item_load = loadSpriteTextureFromCDN(bg, res, ResourcesType.single, self.bg_item_load)
	end

	self.close_btn = container:getChildByName("close_btn")
	self.title_img = container:getChildByName("title_img")
	self.remain_charge = container:getChildByName("remain_charge")
	self.remain_charge:setString(TI18N("已累充: "))

	-- 战斗预览按钮
	self.battle_preview_btn = container:getChildByName("battle_preview_btn")
	self.preview_btn_label = self.battle_preview_btn:getChildByName("preview_btn_label")
	self.preview_btn_label:setString(TI18N("战斗预览"))
	-- self.battle_preview_btn:setVisible(false)

	self.btn_recharge = container:getChildByName("btn")
	self.btn_label = self.btn_recharge:getChildByName("label")
	self.btn_label:setString(TI18N("前往充值"))

	model:setFirstRechargeNewData2()

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
	local title_name = {TI18N("首充赠礼"),TI18N("100元赠礼")}
	for i=1,2 do
		local tab = {}
		tab.btn = container:getChildByName("btn_grade_"..i)
		tab.normal = tab.btn:getChildByName("normal")
		tab.normal:setScale(0.8)
		tab.select = tab.btn:getChildByName("select")
		tab.select:setVisible(false)
		tab.title = tab.btn:getChildByName("title")
		tab.title:setPositionX(118)
		tab.title:setString(title_name[i])
		tab.title:setTextColor(color_text[1])
		tab.title:enableOutline(color_text[2],2)
		tab.title_barner = container:getChildByName("title_img_"..i)
		tab.title_barner:setOpacity(0)
		tab.index = i
		self.tab_view[i] = tab
	end
end

function NewFirstChargeWindow2:openRootWnd(index)
	index = index or 1
	self:changeTabView(index)
	controller:sender21030()
end

function NewFirstChargeWindow2:changeTabView(index)
	index = index or 1
	if self.cur_index == index then return end
	if self.tab_index ~= nil then
		self.tab_index.normal:setVisible(true)
		self.tab_index.select:setVisible(false)
		self.tab_index.title:setPositionX(118)
		self.tab_index.title:setTextColor(color_text[1])
	end
	self.tab_index = self.tab_view[index]
	if self.tab_index ~= nil then
		self.tab_index.normal:setVisible(false)
		self.tab_index.select:setVisible(true)
		self.tab_index.title:setPositionX(118)
		self.tab_index.title:setTextColor(color_text[3])
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
function NewFirstChargeWindow2:titleBarnerAction(index)
	local time_in = 0.2
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

function NewFirstChargeWindow2:stopAllActions()
	for i,v in pairs(self.tab_view) do
		doStopAllActions(v.title_barner)
	end
end

function NewFirstChargeWindow2:fillItemList(list)
	self:hideItemEffect()
	local scale = 0.7
	local size = 119 * scale
	local create_index = 1
	for i=1, tableLen(list) do
		local object = self.item_list[i]
		local num = tableLen(list[i].item_list)
        -- object.scroll:setInnerContainerSize(cc.size(size*num, object.scroll:getContentSize().height))
		for k=1, num do
			delayRun(self.main_container, create_index/15, function()
				local _x = size * k - size * 0.5+16
				local _y = size * 0.5+10
				if not self.item_reward_list[i][k] then
					self.item_reward_list[i][k] = BackPackItem.new(false, true, false, scale, false, true)
					object.scroll:addChild(self.item_reward_list[i][k])					
				end				
				if not self.item_effect_list[self.cur_index][i][k] then
					local pos_x = self.item_reward_list[i][k]:getContentSize().width/2
					local pos_y = self.item_reward_list[i][k]:getContentSize().height/2
					if list[i].effect_list then
						if not self.item_effect_list[self.cur_index][i][k] then
							local effect_action = "action"
							local scale = 1.0
							if list[i].effect_list[1][k] == 263 then
								effect_action = "action1"
								scale = 1.1
							end
							self.item_effect_list[self.cur_index][i][k] = createEffectSpine(PathTool.getEffectRes(list[i].effect_list[1][k]),cc.p(pos_x, pos_y),cc.p(0.5, 0.5),true,effect_action)
		    				self.item_reward_list[i][k]:addChild(self.item_effect_list[self.cur_index][i][k])
		    				self.item_effect_list[self.cur_index][i][k]:setScale(scale)
		    				self.item_effect_list[self.cur_index][i][k]:setVisible(false)
		    			end
	    			end
    			end
    			if self.item_effect_list[self.cur_index][i][k] then
					self.item_effect_list[self.cur_index][i][k]:setVisible(true)
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

--隐藏物品特效
function NewFirstChargeWindow2:hideItemEffect()
	for i=1,2 do
		for j=1,3 do
			for m=1,2 do
				if self.item_effect_list[i][j][m] then
					self.item_effect_list[i][j][m]:setVisible(false)
				end
			end
		end
	end
end

function NewFirstChargeWindow2:register_event()
	registerButtonEventListener(self.close_btn, function()
		controller:openNewFirstChargeView(false)
	end, false, 2)
	registerButtonEventListener(self.background, function()
		controller:openNewFirstChargeView(false)
	end, false, 2)

	registerButtonEventListener(self.btn_recharge, function()
		local first_data = model:getFirstRechargeData(self.cur_index)
		if self.get_gift_id == 0 then
			VipController:getInstance():openVipMainWindow(true, VIPTABCONST.CHARGE)
			--MallController:getInstance():openChargeShopWindow(true, MallConst.Charge_Shop_Type.Diamond)
		elseif self.get_gift_id == 1 then
			if first_data[self.gift_index] then
				controller:sender21031(first_data[self.gift_index].id)
			end
		else
			controller:openNewFirstChargeView(false)
		end
	end, true, 1)

	registerButtonEventListener(self.battle_preview_btn, function()
        TimesummonController:getInstance():send23219(BattlePreviewParm.FirstCharge2)
    end, true)

	for i,v in pairs(self.tab_view) do
		registerButtonEventListener(v.btn, function()
			self:changeTabView(v.index)
		end,true,1)
	end

	self:addGlobalEvent(NewFirstChargeEvent.New_First_Charge_Event, function(data)
		self.updata_charge_data = data
		local role_vo = RoleController:getInstance():getRoleVo()
		local totle_str = string_format(TI18N("已累充: %d"),math.floor(role_vo.vip_exp*0.1))
		self.remain_charge:setString(totle_str)
		
		self:setRedPointTab()
		self:updateData(data)
	end)
end
--红点
function NewFirstChargeWindow2:setRedPointTab()
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

function NewFirstChargeWindow2:updateData(data)
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

function NewFirstChargeWindow2:close_callback()
	doStopAllActions(self.main_container)
	self:stopAllActions()

 	for i=1,2 do
 		for j=1,3 do
 			for m=1,2 do
 				if self.item_effect_list[i][j][m] then
 					self.item_effect_list[i][j][m]:clearTracks()
			    	self.item_effect_list[i][j][m]:removeFromParent()
			        self.item_effect_list[i][j][m] = nil
 				end
 			end
 		end
 	end
 	self.item_effect_list = {}

	for i=1,3 do
		for i,item in pairs(self.item_reward_list[i]) do
			item:DeleteMe()
		end
		self.item_reward_list[i] = nil
	end
	self.item_reward_list = {}

	if self.bg_item_load then
        self.bg_item_load:DeleteMe()
    end
    self.bg_item_load = nil
	controller:openNewFirstChargeView(false)
end 