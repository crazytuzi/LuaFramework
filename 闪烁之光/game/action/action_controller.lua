-- --------------------------------------------------------------------
-- 活动总入口
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-07-18
-- --------------------------------------------------------------------
ActionController = ActionController or BaseClass(BaseController)


function ActionController:config()
	self.model = ActionModel.New(self)
	self.dispather = GlobalEvent:getInstance()
	self.mainui_ctrl = MainuiController:getInstance()
	self.holiday_list = {}                          -- 活动列表类型
	self.holiday_award_list = {}                    -- 未领取活动奖励的列表
	self.holiday_del_list = {}                      -- 需要移除的标签页缓存列表
	self.need_show_init_red = {}                    -- 登录的时候需要显示红点的列表
	self.cache_function_list = {}
	self.return_action_shop_first_red = true      	--回归兑换首次红点
	self.return_action_shop_red = false				--回归兑换领取红点
end

function ActionController:getModel()
	return self.model
end

function ActionController:registerEvents()
	if self.init_role_event == nil then
		self.init_role_event = GlobalEvent:getInstance():Bind(EventId.ROLE_CREATE_SUCCESS, function()
			GlobalEvent:getInstance():UnBind(self.init_role_event)
			self.init_role_event = nil
			self:needRequireData()
		end)
	end
	
	-- 断线重连的时候要请求一下全部的活动图标,最好要关闭掉所有打开的 活动面板,并且把活动数据全清掉
	if self.re_link_game_event == nil then
		self.re_link_game_event = GlobalEvent:getInstance():Bind(LoginEvent.RE_LINK_GAME, function()
			self:needRequireData(true)
		end)
	end
end

--- 断线重连或者0点更新或者初始化需要请求的
function ActionController:needRequireData(force)
	self:openActionMainPanel(false)
	-- local function_id = MainuiConst.icon.welfare
	-- if self:isSpecialBid(bid) then
    --     self.mainui_ctrl:setFunctionTipsStatus(MainuiConst.icon.welfare, vo1)
	-- else
    --     self.mainui_ctrl:setFunctionTipsStatus(action_sub_vo.cli_type, vo1)
	-- 	function_id = action_sub_vo.cli_type
	-- end
	self.holiday_list = {}
	self.holiday_award_list = {}
	self.need_show_init_red = {}
	self.holiday_del_list = {}
	self.is_init_require = true
	self.model:clearFundSrvData()  						-- 断线时需要清掉基金缓存数据
	self:requestActionStatus()                          -- 请求所有活动图标
	self:requestHolidayList()       					-- 登陆的时候请求一下精彩活动的
	self:cs21100()										-- 刷新7天或8天登陆活动
end

function ActionController:registerProtocals()
	self:RegisterProtocal(21000, "on21000")             -- 首充礼包信息
	self:RegisterProtocal(21001, "on21001")             -- 领取首冲礼包
	self:RegisterProtocal(10922, "on10922")             -- 全服活动状态,服务端广播 
	self:RegisterProtocal(10923, "on10923")             -- 主要是用于服务段更新全服活动状态数据的
	self:RegisterProtocal(10924, "on10924")             -- 个人活动状态,服务端广播 
	self:RegisterProtocal(10925, "on10925")             -- 主要是用于服务段更新个人活动状态数据的
	--7天登录
	self:RegisterProtocal(21100, "on21100")              -- 7天登录信息
	self:RegisterProtocal(21101, "on21101")              -- 领取7天登录奖励
	self:RegisterProtocal(16601, "on16601")             -- 所有子活动的显示数据,主要用于活动面板左侧标签显示,以及部分面板内容显示
	self:RegisterProtocal(16602, "on16602")             -- 请求所有活动未领取奖励
	self:RegisterProtocal(16606, "on16606")             -- 领取活动返回
	self:RegisterProtocal(16603, "on16603")             -- 请求子活动
	self:RegisterProtocal(16604, "on16604")             -- 领取奖励
	--0点 5点更新
	self:RegisterProtocal(16607, "on16607")              -- 0点 5点更新
	-- 
	self:RegisterProtocal(16620, "on16620")				-- 一系列子活动类型
	--七天排行
	self:RegisterProtocal(22700, "on22700")             -- 七天排行列表
	self:RegisterProtocal(22701, "on22701")             -- 七天排行信息
	-- 7天排行任务
	self:RegisterProtocal(22702, "on22702")
	self:RegisterProtocal(22703, "on22703")
	self:RegisterProtocal(22704, "on22704")
	--七天目标
	self:RegisterProtocal(13601, "handle13601")
	self:RegisterProtocal(13602, "handle13602")
	--幸运转盘
	self:RegisterProtocal(16637, "handle16637")
	self:RegisterProtocal(16638, "handle16638")
	self:RegisterProtocal(16639, "handle16639")
	self:RegisterProtocal(16641, "handle16641")
	self:RegisterProtocal(16642, "handle16642")
	self:RegisterProtocal(16643, "handle16643")
	--升级有礼
	self:RegisterProtocal(21200, "handle21200")
	self:RegisterProtocal(21201, "handle21201")
	--限时礼包入口
	self:RegisterProtocal(21210, "handle21210")
	self:RegisterProtocal(21211, "handle21211") -- 推送激活了显示礼包.
	--点金活动奖励排行信息(以后可以是活动的通用)
	self:RegisterProtocal(16650, "handle16650")
	-- 基金相关
	self:RegisterProtocal(24700, "handle24700")
	self:RegisterProtocal(24701, "handle24701")
	self:RegisterProtocal(24702, "handle24702")
	--元宵冒险
	self:RegisterProtocal(24810, "handle24810") --获取元宵冒险 任务信息
	self:RegisterProtocal(24811, "handle24811") --推送任务变化"
	self:RegisterProtocal(24812, "handle24812") --任务领取

	self:RegisterProtocal(24813, "handle24813")
	self:RegisterProtocal(24814, "handle24814")
	self:RegisterProtocal(24815, "handle24815")
	self:RegisterProtocal(24816, "handle24816")
	self:RegisterProtocal(24817, "handle24817")
	self:RegisterProtocal(24818, "handle24818")

	-- 合服目标
	self:RegisterProtocal(27300, "handle27300")
	self:RegisterProtocal(27301, "handle27301")

	--是否可以充值
	self:RegisterProtocal(21016, "handle21016")

	self:RegisterProtocal(16665, "handle16665") --满减商城的购买协议      

	self:RegisterProtocal(16666, "handle16666") --满减商城的红点(以后可能通用)

	self:RegisterProtocal(16686, "handle16686") --10置换协议
	self:RegisterProtocal(16687, "handle16687") --新服限购的红点
	self:RegisterProtocal(16688, "handle16688") --杂货铺数据协议
	self:RegisterProtocal(16689, "handle16689") --杂货铺购买协议
	self:RegisterProtocal(16695, "handle16695") --嘉年华领取礼包码奖励

	--沙滩争夺战
	self:RegisterProtocal(25400, "handle25400") --	活动boss活动界面数据"
	self:RegisterProtocal(25401, "handle25401") --	活动boss信息"
	self:RegisterProtocal(25402, "handle25402") --	购买挑战次数"
	self:RegisterProtocal(25403, "handle25403") --	领取奖励"
	self:RegisterProtocal(25404, "handle25404") --	挑战活动boss"
	self:RegisterProtocal(25405, "handle25405") --	推送战斗结算（会推送25401）"

	--
	self:RegisterProtocal(25500, "handle25500")

	--英雄重生协议
	self:RegisterProtocal(11071, "handle11071") --重生
	self:RegisterProtocal(11072, "handle11072") --重生返回材料
	self:RegisterProtocal(11072, "handle11074") --伙伴皮肤重生
	

	--皮肤抽个奖
	self:RegisterProtocal(26600, "handle26600")
	self:RegisterProtocal(26601, "handle26601")
	self:RegisterProtocal(26602, "handle26602")

	self:RegisterProtocal(21020, "handle21020")
	--新春限购重置
	self:RegisterProtocal(16696, "handle16696")
	-- 元旦充值返利
	self:RegisterProtocal(28100, "handle28100")
	self:RegisterProtocal(28101, "handle28101")
	self:RegisterProtocal(28102, "handle28102")
	self:RegisterProtocal(28103, "handle28103")

	self:RegisterProtocal(26530, "handle26530")     -- 精灵重生
	self:RegisterProtocal(28400, "handle28400")     -- 幸运锦鲤基础数据
	self:RegisterProtocal(28402, "handle28402")     -- 幸运锦鲤红点
	self:RegisterProtocal(28403, "handle28403")     -- 幸运锦鲤红点

	-- 不放回抽奖
	self:RegisterProtocal(28300, "handle28300") 
	self:RegisterProtocal(28301, "handle28301") 
	self:RegisterProtocal(28302, "handle28302") 
	self:RegisterProtocal(28303, "handle28303") 
	self:RegisterProtocal(28305, "handle28305") 
	self:RegisterProtocal(28306, "handle28306") 

	-- 甜蜜大作战（情人节活动）
	self:RegisterProtocal(28500, "handle28500") 
	self:RegisterProtocal(28501, "handle28501") 
	self:RegisterProtocal(28502, "handle28502") 

	self:RegisterProtocal(16697, "handle16697")     -- 定时领奖图标控制
	self:RegisterProtocal(16698, "handle16698")     -- 领奖
	-- 白色情人节活动（女神试炼）
	self:RegisterProtocal(28800, "handle28800")     -- 查询活动信息
	self:RegisterProtocal(28801, "handle28801")     -- 挑战Boss
	self:RegisterProtocal(28802, "handle28802")     -- 战斗结果
	self:RegisterProtocal(28803, "handle28803")     -- 购买挑战次数

	self:RegisterProtocal(10971, "handle10971")     -- 获取token
	self:RegisterProtocal(16653, "handle16653")     -- 超值周卡基础
	self:RegisterProtocal(16654, "handle16654")     -- 领取奖励
end

--==============================--
--desc:登陆时候请求全服活动和个人活动状态全部数据
--time:2017-07-18 05:15:10
--@return 
--==============================--
function ActionController:requestActionStatus()
	-- 优先把全服活动的数据清空,其实也就是把22协议里面的图标全部干掉
	if self.protocal_list_22 and next(self.protocal_list_22 or {}) ~= nil then
		for k, v in pairs(self.protocal_list_22) do
			self.mainui_ctrl:removeFunctionIconById(v)
		end
		self.protocal_list_22 = {}
	end
	
	--如果出现更换周期的月份需要请求本期与下一期的，不然会出现断线跨0点时出错
	--self:send10925(OrderActionEntranceID.entrance_id5)
	--self:send10925(OrderActionEntranceID.entrance_id6)
	--self:send10925(OrderActionEntranceID.entrance_id7)
	self:send10925(OrderActionEntranceID.entrance_id8)
	self:send10925(OrderActionEntranceID.entrance_id9)
	RenderMgr:getInstance():doNextFrame(function()
		self:SendProtocal(10922, {})
		self:SendProtocal(10924, {})
	end)
end
--==============================--
--desc:登录时候请求一些特殊活动id的红点数据
--time:2017-07-18 05:15:10
--@return 
--==============================--
function ActionController:requestActionRedStatus()
	ActionController:getInstance():sender16687({bid=ActionRankCommonType.open_server})     --小额直购请求红点
    ActionController:getInstance():sender16687({bid=ActionRankCommonType.high_value_gift}) --小额礼包请求红点
    ActionController:getInstance():sender16687({bid=ActionRankCommonType.mysterious_store}) --神秘杂货店请求红点
end

--==============================--
--desc:登录时候请求一些特殊活动id的详细数据
--time:2017-07-18 05:15:10
--@return 
--==============================--
function ActionController:requestActionList()
	local list = {{id=91005}, {id=991011}, {id=1011}, {id=991014}, {id=91014},{id=991024},{id=991025}}

	local protocal = {}
	protocal.id_list = list
	self:SendProtocal(16620, protocal)
end

--首充礼包信息
function ActionController:sender21000()
	local protocal = {}
	self:SendProtocal(21000, protocal)
end

--首充详细数据
function ActionController:on21000(data)
	local day_info = nil
	for i,v in ipairs(data.first_gift) do
		if v.status == 1 then
			day_info = v
			break
		end
	end
	if day_info == nil then
		for i,v in ipairs(data.first_gift) do
			if v.status == 0 then
				day_info = v
				break
			end
		end
	end

	self.first_get_data = data.first_gift --首充是否可领取的数据
	self.model:setFirstBtnStatus(data.first_gift)
	
	self.dispather:Fire(ActionEvent.Update_First_Charge_Status, data, day_info)
end

--- 获取当前首充的数据,天数和状态
function ActionController:getFirstInfoData()
	return self.first_data_info
end

--领取首冲礼包
function ActionController:sender21001(id)
	local protocal = {}
	protocal.id = id
	self:SendProtocal(21001, protocal)
end

function ActionController:on21001(data)
	message(data.msg)
end

--==============================--
--desc:更新全服活动全部数据
--time:2017-07-18 04:35:11
--@data:
--@return 
--==============================--
function ActionController:on10922(data)
	if self.protocal_list_22 == nil then
		self.protocal_list_22 = {}
	end
	if data ~= nil and data.act_list then
		for i, v in ipairs(data.act_list) do
			self:handleActionStatusData(v)
			-- 先储存一下吧
			if v.status == ActionStatus.un_finish then
				self.protocal_list_22[v.id] = nil
			else
				self.protocal_list_22[v.id] = v.id
			end
		end
	end
end

--==============================--
--desc:更新指定id的全服活动数据
--time:2017-07-18 04:36:36
--@data:
--@return 
--==============================--
function ActionController:on10923(data)
	self:handleActionStatusData(data)
	
	if data ~= nil then
		if self.protocal_list_22 == nil then
			self.protocal_list_22 = {}
		end
		if data.status == ActionStatus.un_finish then
			self.protocal_list_22[data.id] = nil
		else
			self.protocal_list_22[data.id] = data.id
		end
	end
end

--==============================--
--desc:更新个人活动全部数据
--time:2017-07-18 04:35:34
--@data:
--@return 
--==============================--
function ActionController:on10924(data)
	local had_first = false
	if data ~= nil and data.act_list then
		for i, v in ipairs(data.act_list) do
			self:handleActionStatusData(v)
		end
	end
end

function ActionController:setFirstTipsStatus(func_id, status)
	self.mainui_ctrl:setFunctionTipsStatus(func_id, status)
end
--==============================--
--断线重连某个活动的状态
function ActionController:send10925(id)
	local protocal = {}
	protocal.id = id
	self:SendProtocal(10925, protocal)
end
--desc:更新指定id的个人活动数据
--time:2017-07-18 04:37:28
--@data:
--@return 
--==============================--
function ActionController:on10925(data)
	self:handleActionStatusData(data)
end

--==============================--
--desc:处理活动类图标数据()
--time:2017-07-18 05:05:37
--@data:
--@return 
--==============================--
function ActionController:handleActionStatusData(data)
	--25 是限时icon玩法的 id 这个表决定..不能改 --by lwc
	local func_id = 25
	if Config.FunctionData.data_info[func_id] then
		local config = Config.FunctionData.data_info[func_id]

		for i,id in ipairs(config.param1) do
			if id == data.id then
				--说明是显示玩法的图标
				self.model:updateLimitIconData(data)
				local dic_func = self.model:getLimitIconData()
				if next(dic_func) == nil then
					self.mainui_ctrl:removeFunctionIconById(func_id)
					if self.mainui_ctrl.setMergeServerContainerPositionY then
						self.mainui_ctrl:setMergeServerContainerPositionY(false)
					end
				else
					self.mainui_ctrl:addFunctionIconById(func_id)
					if self.mainui_ctrl.setMergeServerContainerPositionY then
						self.mainui_ctrl:setMergeServerContainerPositionY(true)
					end
				end
			 	return
			end
		end
	end
	
	if data then
		local config = Config.FunctionData.data_info[data.id]
		if config == nil then return end
		if data.status == ActionStatus.un_finish then
			self.mainui_ctrl:removeFunctionIconById(data.id)
		else
			self.mainui_ctrl:addFunctionIconById(data.id, data) 
			-- 如果是7天排行就请求一下任务
			if data.id == MainuiConst.icon.seven_rank then  -- 7天排行
				self:requestSevenDaysRank()
			elseif data.id == MainuiConst.icon.fund then
				self.model:checkFundRedStatus()
			end
		end
	end
end

-------打开首充界面
function ActionController:openFirstChargeView(status)
	if status then
		if not self.first_charge_win then
			self.first_charge_win = ActionFirstChargeWindow.New()
		end
		local role_vo = RoleController:getInstance():getRoleVo()
		local index = 1
		if role_vo.vip_exp ~= 0 then
			index = 2
		end
		if self.first_get_data then
			--首充是否可以领取
			local first_status = false
			for i=1,3 do
				if self.first_get_data[i].status == 1 then
					first_status = true
					index = 1
					break
				end
			end
			--累充是否可以领取
			local total_status = false
			for i=4,6 do
				if self.first_get_data[i].status == 1 then
					total_status = true
					index = 2
					break
				end
			end
			if first_status == true and total_status == true then
				index = 1
			end
		end

		self.first_charge_win:open(index)
	else
		if self.first_charge_win then
			self.first_charge_win:close()
			self.first_charge_win = nil
		end
	end
end

-------打开七天目标界面
function ActionController:openSevenGoalView(status)
	if status then
		if not self.seven_goal_win then
			self.seven_goal_win = ActionSevenGoalWindow.New()
		end
		self.seven_goal_win:open()
	else
		if self.seven_goal_win then
			self.seven_goal_win:close()
			self.seven_goal_win = nil
		end
	end
end
function ActionController:cs13601()
	self:SendProtocal(13601, {})
end
function ActionController:handle13601(data)
	if data.period == 0 then return end

	self.model:setSevenGoldPeriod(data.period or 1)
	self.model:initSevenWalfare(data.period or 1)

	self.model:setSevenGoalWelfareList(data.welfare_list)
	self.model:setSevenGoalGrowList(data.grow_list)
	self.model:setHalfGiftList(data.price_list)

	self.model:setSevenGoalBoxList(data.finish_list, data.num)
	self.model:checkRedPoint(data.cur_day)
	GlobalEvent:getInstance():Fire(ActionEvent.UPDATE_SEVENT_GOAL, data)
end
--请求七日活动领取
function ActionController:cs13602(type,day,id,item)
	local protocal = {}
	protocal.type = type
	protocal.day_type = day
	protocal.id = id
	protocal.item = item
	self:SendProtocal(13602, protocal)
end
function ActionController:handle13602(data)
	message(data.msg)
	if data.flag == 1 then
		GlobalEvent:getInstance():Fire(ActionEvent.UPDATE_SEVENT_GET, data)
	end
end

-------打开七天登录界面
function ActionController:openSevenLoginWin(status)
	if status then
		if not self.seven_login_win then
			self.seven_login_win = ActionSevenLoginWindow.New()
		end
		self.seven_login_win:open()
	else
		if self.seven_login_win then
			self.seven_login_win:close()
			self.seven_login_win = nil
		end
	end
end

-- 引导需要
function ActionController:getSevenLoginRoot(  )
	local root_wnd = nil
	if self.seven_login_win then
		root_wnd = self.seven_login_win.root_wnd
	end

	local data = self.model:getSevenLoginData()
	if data and data.type == 1 then --新版
		if self.eight_login_win then
			root_wnd = self.eight_login_win.root_wnd
		end
	end
	return root_wnd
end

-------打开八天登录界面
function ActionController:openEightLoginWin(status)
	if status then
		if not self.eight_login_win then
			self.eight_login_win = ActionEightLoginWindow.New()
		end
		self.eight_login_win:open()
	else
		if self.eight_login_win then
			self.eight_login_win:close()
			self.eight_login_win = nil
		end
	end
end

--打开限时礼包入口
--打开显示礼包id
function ActionController:openActionLimitGiftMainWindow(status, id)
	if status then
		if not self.action_limit_gift then
			self.action_limit_gift = ActionLimitGiftMainWindow.New()
		end
		self.action_limit_gift:open(id)
	else
		if self.action_limit_gift then
			self.action_limit_gift:close()
			self.action_limit_gift = nil
		end
	end
end

--打开开服超值礼包界面
function ActionController:openActionOpenServerGiftWindow(status, bid)
	if status then
		if not self.action_open_server_recharge then
			self.action_open_server_recharge = ActionOpenServerGiftWindow.New()
		end
		self.action_open_server_recharge:open(bid)
	else
		if self.action_open_server_recharge then
			self.action_open_server_recharge:close()
			self.action_open_server_recharge = nil
		end
	end
end

--==============================--
--desc:7天登录状态
--==============================--
function ActionController:cs21100()
	self:SendProtocal(21100, {})
end

function ActionController:on21100(data)
	local show_red = false
	for k, v in pairs(data.status_list) do
		if v.status == 2 then
			if data.type == 1 then --新版
				self.mainui_ctrl:setFunctionTipsStatus(MainuiConst.icon.eight_login, true)
			else
				self.mainui_ctrl:setFunctionTipsStatus(MainuiConst.icon.seven_login, true)
			end
			break
		end
	end
	local i = 0
	for k, v in pairs(data.status_list) do
		if v.status == 3 then
			i = i + 1
		end
	end
	if i == #data.status_list then
		if data.type == 1 then --新版
			self.mainui_ctrl:setFunctionTipsStatus(MainuiConst.icon.eight_login, false)
		else
			self.mainui_ctrl:setFunctionTipsStatus(MainuiConst.icon.seven_login, false)
		end
		
	end
    self.model:updateSevenLoginData(data) 
	
	GlobalEvent:getInstance():Fire(ActionEvent.UPDATE_SEVEN_LOGIN_STATUS, data)
end

--==============================--
--desc:7天登录领取奖励
--==============================--
function ActionController:cs21101(day)
	local protocal = {}
	protocal.day = day
	self:SendProtocal(21101, protocal)
end

function ActionController:on21101(data)
	message(data.msg)
	if data.code == 1 then
		GlobalEvent:getInstance():Fire(ActionEvent.UPDATE_SEVEN_LOGIN_REWARDS, data)
		self:cs21100()
	end
end

function ActionController:__delete()
	if self.model ~= nil then
		self.model:DeleteMe()
		self.model = nil
	end
end

-----打开幸运探宝界面-----
function ActionController:openLuckyTreasureWin(status, index)
	index = index or 1
	if status then
		--高级探宝的时候
		if index == 2 then
			ActionController:getInstance():getModel():setBuyRewardData()
			local open_data = ActionController:getInstance():getModel():getBuyRewardData(index)
			local open = MainuiController:getInstance():checkIsOpenByActivate(open_data[2].limit_open)
			if open == false then
				message(TI18N("人物等级不足"))
				return
			end
		end
		if not self.treasure_win then
			self.treasure_win = ActionTreasureWindow.New()
		end
		self.treasure_win:open(index)
	else
		if self.treasure_win then
			self.treasure_win:close()
			self.treasure_win = nil
		end
	end
end

-- 引导需要
function ActionController:getTreasureRoot(  )
	if self.treasure_win then
		return self.treasure_win.root_wnd
	end
end

-- 探宝获得物品界面
function ActionController:openTreasureGetItemWindow(status,data,index,count_type,func)
	if status then
		if not self.treasure_get_win then
			self.treasure_get_win = ActionTreasureGetWindow.New(data,index,count_type,func)
		end
		self.treasure_get_win:open()
	else
		if self.treasure_get_win then
			self.treasure_get_win:close()
			self.treasure_get_win = nil
		end
	end
end

-----打开直购礼包界面-----
function ActionController:openDirectBuyGiftWin(status, bid)
	if status then
		if not self.buygift_win then
			self.buygift_win = ActionDirectBuygiftWindow.New()
		end
		self.buygift_win:open(bid)
	else
		if self.buygift_win then
			self.buygift_win:close()
			self.buygift_win = nil
		end
	end
end
-----打开七天排行界面-----
function ActionController:openSevenRankWin(status)
	if status then
		if not self.seven_rank_win then
			self.seven_rank_win = ActionSevenRankWindow.New()
		end
		self.seven_rank_win:open()
	else
		if self.seven_rank_win then
			self.seven_rank_win:close()
			self.seven_rank_win = nil
		end
	end
end

--跨服排行
function ActionController:openCorssserverRankWin(status)
	-- body
	if status then
		if not self.crossserver_rank_win then
			self.crossserver_rank_win = ActionCrossServerRankWindow.New()
		end
		self.crossserver_rank_win:open()
	else
		if self.crossserver_rank_win then
			self.crossserver_rank_win:close()
			self.crossserver_rank_win= nil
		end
	end
end

--七天排行列表
function ActionController:sender22700(is_cluster)
	local protocal = {}
	protocal.is_cluster = is_cluster or 0
	self:SendProtocal(22700, protocal)
end

function ActionController:on22700(data)	
	if data.is_cluster == 1 then -- 跨服的
		-- self:openCorssserverRankWin(true)
		GlobalEvent:getInstance():Fire(ActionEvent.UPDATE_CROSSSERVER_RANK_LIST,data)
	elseif data.is_cluster == 0 then
		self:openSevenRankWin(true)
		GlobalEvent:getInstance():Fire(ActionEvent.UPDATE_SEVEN_RANK_LIST, data)
	end
end

--七天排行信息
function ActionController:sender22701(id)
	local protocal = {}
	protocal.id = id
	self:SendProtocal(22701, protocal)
end

function ActionController:on22701(data)
	local b = self.model:checkIsCrossServerRankList(data.id)
	if b then -- 是否跨服的id
		GlobalEvent:getInstance():Fire(ActionEvent.UPDATE_CROSSSERVER_RANK_DATA, data)
	else
		GlobalEvent:getInstance():Fire(ActionEvent.UPDATE_SEVEN_RANK_DATA, data)
	end

end

-- 节日登陆活动
function ActionController:openFestvalLoginWindow( status, bid )
	if status then
		if not self.festval_login_win then
			self.festval_login_win = ActionFestvalLoginWindow.New(bid)
		end
		self.festval_login_win:open()
	else
		if self.festval_login_win then
			self.festval_login_win:close()
			self.festval_login_win = nil
		end
	end
end

-- 特惠礼包（3星直升礼包）
function ActionController:openPreferentialWindow( status, bid ,icon_id)
	if status then
		if not self.preferential_win then
			self.preferential_win = ActionPreferentialWindow.New(icon_id)
		end
		self.preferential_win:open(bid)
	else
		if self.preferential_win then
			self.preferential_win:close()
			self.preferential_win = nil
		end
	end
end

-- 打开基金活动面板
function ActionController:openActionFundWindow( status, bid )
	if status then
		if not self.action_fund_win then
			self.action_fund_win = ActionFundMainWindow.New()
		end
		if self.action_fund_win:isOpen() == false then
			self.action_fund_win:open(bid)
		end
	else
		if self.action_fund_win then
			self.action_fund_win:close()
			self.action_fund_win = nil
		end
	end
end

-- 打开基金奖励预览界面
function ActionController:openActionFundAwardWindow( status, group_id, fund_id )
	if status then
		if not self.fund_award_win then
			self.fund_award_win = ActionFundAwardWindow.New()
		end
		if self.fund_award_win:isOpen() == false then
			self.fund_award_win:open(group_id, fund_id)
		end
	else
		if self.fund_award_win then
			self.fund_award_win:close()
			self.fund_award_win = nil
		end
	end
end

--==============================--
--desc:请求该类型活动的所有数据,主要用于主界面的左侧标签栏的,只需要请求一次
--time:2017-07-25 04:28:25
--@type:
--@return 
--==============================--
function ActionController:requestHolidayList()
	local proto = {}
	self:SendProtocal(16601, proto)
end

--==============================--
--desc:活动的左侧标签内容,顺带包含了右边的背景或者banner资源等
--time:2017-09-28 02:41:53
--@data:
--@return 
--==============================--
function ActionController:on16601(data)
	local temp_sub_vo
	local type_list = {}
	for i, v in ipairs(data.holiday_list) do
		if self.holiday_del_list[v.bid] == nil then
			temp_sub_vo = self.holiday_list[v.bid]
			if temp_sub_vo == nil then
				temp_sub_vo = ActionSubTabVo.New()
				self.holiday_list[v.bid] = temp_sub_vo
			end
			temp_sub_vo = self.holiday_list[v.bid]
			if temp_sub_vo ~= nil then
				temp_sub_vo:update(v)
			end
			-- 活动类的投资计划和基金不在活动面板显示
			if self:isSpecialBid(v.bid) then
				temp_sub_vo:setShowStatus(false)
				self:cs16603(v.bid)
			end

			-- 请求元旦钻石返利红点
			if v.bid == ActionRankCommonType.recharge_rebate then
				self:sender28102()
			end

			-- 请求幸运锦鲤红点
			if v.bid == ActionRankCommonType.lucky_dog then
				self:send28400()
				self:send28402()
			end

			-- 请求不放回抽奖红点设置campid
			if v.bid == ActionRankCommonType.FortuneBagDraw then
				self:sender28306()
				self.model:setFortuneBagCampId(v.camp_id)
			end

			-- 请求超值月卡
			if v.bid == ActionRankCommonType.super_week_card then
				self:sender16653()
			end

			-- 请求女神试炼基础数据
			if v.bid == ActionRankCommonType.white_day then
				self:sender28800()
			end

			-- 判断这个活动所属的图标,并且动态设置他的名字
			if temp_sub_vo.cli_type ~= 0 then
				if type_list[temp_sub_vo.cli_type] == nil then
					type_list[temp_sub_vo.cli_type] = {action_num = 0, action_name = ""}
				end
				if not self:isSpecialBid(temp_sub_vo.bid) then
					type_list[temp_sub_vo.cli_type].action_num = type_list[temp_sub_vo.cli_type].action_num + 1
					if temp_sub_vo.cli_type_name ~= "" and temp_sub_vo.cli_type_name ~= "null" and type_list[temp_sub_vo.cli_type].action_name == "" then
						type_list[temp_sub_vo.cli_type].action_name = temp_sub_vo.cli_type_name
					end
				end
			end
		end
	end
	
	-- 初始化之后请求对应的活动红点状态
	if self.is_init_require == true then
		self:requestActionAwardStatus()
		self.is_init_require = false
	end

	-- 判断是增删图标
	for function_id, object in pairs(type_list) do
		if object then
			if object.action_num > 0 then
				self.mainui_ctrl:addFunctionIconById(function_id, object.action_name)
			else
				self.mainui_ctrl:removeFunctionIconById(function_id)
			end
		end
	end
	GlobalEvent:getInstance():Fire(ActionEvent.UPDATE_ACTION_DATA_EVENT)
	self:startHolidayListTimeTicket()
	self:setReturnActionShopFirstRedStatus(true)
end


function ActionController:startHolidayListTimeTicket()
	if self.time_ticket == nil then
		local _callback = function() 
			if self.holiday_list then
				for k,v in pairs(self.holiday_list) do
					if v.remain_sec then
						v.remain_sec = v.remain_sec - 1
						if v.remain_sec < 0 then
							v.remain_sec = 0
						end
					end
				end
			end
		end
        self.time_ticket = GlobalTimeTicket:getInstance():add(_callback)
    end
end

-- function ActionController:clearTimeTicket()
--     if self.time_ticket ~= nil then
--         GlobalTimeTicket:getInstance():remove(self.time_ticket)
--         self.time_ticket = nil
--     end
-- end 

--- 是否可以创建指定活动类型,只有活动总列表里面有这个活动类型才可以创建
function ActionController:checkCanAddWonderful(function_id)
	if function_id == nil then return false end
	if self.holiday_list == nil or next(self.holiday_list) == nil then return false end
	for k,v in pairs(self.holiday_list) do
		if v.cli_type == function_id then
			return true
		end
	end
	return false
end

--==============================--
--desc:获得指定类型活动的所有子活动列表,用于主界面显示,这里做一个排序处理吧
--time:2017-07-25 04:55:30
--@function_id:现在活动根据图标绑定
--@return
--==============================--
function ActionController:getActionSubList(function_id)
	local action_sub_list = {}
	if self.holiday_list then
		for k,v in pairs(self.holiday_list) do
			if v.cli_type == function_id and v:isShowInAction() == true then
				table.insert(action_sub_list, v)
			end
		end
	end
	-- 做一个排序
	if next(action_sub_list) ~= nil then
		table.sort(action_sub_list, function(a, b)
			return a.sort_val < b.sort_val
		end)
	end
	return action_sub_list
end

--==============================--
--desc:请求所有活动未领取奖励状态
--time:2017-07-25 08:31:19
--@type:
--@return 
--==============================--
function ActionController:requestActionAwardStatus()
	local proto = {}
	self:SendProtocal(16602, proto)
end

--==============================--
--desc:所有活动未领取奖励列表
--time:2017-07-25 08:06:28
--@data:
--@return 
--==============================--
function ActionController:on16602(data)
	for i, v in ipairs(data.holiday_list) do
		self:setHolidayStatus(v.bid, (v.can_get_num ~= FALSE))
	end
end


--==============================--
--desc:请求子活动列表
--time:2017-07-26 07:56:10
--@bid:子活动ID
--@return 
--==============================--
function ActionController:cs16603(bid)
	local protocal = {}
	protocal.bid = bid
	self:SendProtocal(16603, protocal)
end

---特殊类的活动id,这类的需要做一些特殊判断,比如说上线没有充值的需要显示红点
function ActionController:isSpecialBid(bid)
	return bid == ActionSpecialID.invest or bid == ActionSpecialID.growfund
end

function ActionController:on16620(data)
	for i,v in ipairs(data.holiday_list) do
		self:on16603(v)
	end
end

--[[
    @desc:一些活动就算没有子活动 也不移除标签页 
    author:{author}
    time:2019-02-19 24:49:18
    --@bid: 
    @return:
]]
function ActionController:canRemoveTabVo(bid)
	return bid ~= 93015
end

function ActionController:on16603(data)
	--节日登录红点
	if data.bid == ActionRankCommonType.common_day or data.bid == ActionRankCommonType.festval_day or data.bid == ActionRankCommonType.lover_day then
		self.model:updataFestvalRedStatus(data.bid,data.aim_list)
	elseif data.bid == 1011 then
		self.model:updataCombineLoginRedStatus(data.aim_list)
	elseif data.bid == 991014 then
		self.model:updataPreferentialRedStatus(true, MainuiConst.icon.preferential)
	elseif data.bid == 91014 then
		self.model:updataPreferentialRedStatus(true, MainuiConst.icon.other_preferential)
	end
	-- 没有子活动列表了,直接移除掉标签,下次有效(现在作废)
	if #data.aim_list == 0 then
		self:handleHolidayList(0, data.bid)
	end
	-- 首充连冲
	if data.bid == 91005 then
		self:handle91005Data(data)
	elseif data.bid == ActionRankCommonType.seven_charge then --7天连充
		self.model:setSevenChargeData(data)
	elseif data.bid == ActionRankCommonType.skin_direct_purchase then --皮肤直购
		self:updateSkinDirectPurchase(data)
	end
	
	-- 现在只要活动列表是空的,那么是投资计划后者是基金就删掉标签页
	if self:isSpecialBid(data.bid) then
		--未激活的时候
		if data.finish == 0 and self.need_show_init_red[data.bid] == nil and #data.aim_list ~= 0 then
			local status = false
			local base_config = Config.HolidayClientData.data_info[data.bid]
			if base_config then
				local is_open = MainuiController:getInstance():checkIsOpenByActivate(base_config.open_lev)
				local role_vo = RoleController:getInstance():getRoleVo()
				if role_vo then
					if is_open and role_vo.lev then
						local grow_fund_status = SysEnv:getInstance():getBool(SysEnv.keys.grow_fund_redpoint,true)
						if is_open == true and grow_fund_status then
							status = true
						end
						SysEnv:getInstance():set(SysEnv.keys.grow_fund_redpoint, status)
					end
				end
			end

			self.need_show_init_red[data.bid] = status
			self:setHolidayStatus(data.bid, status)
			if data.bid == ActionSpecialID.growfund then
				WelfareController:getInstance():setWelfareStatus(ActionSpecialID.growfund, status)
			end
		else
			--激活的时候处理
			if data.bid == ActionSpecialID.growfund then
				local status = false
				if data and data.finish == ActionStatus.finish then
					for i,v in pairs(data.aim_list) do
						if v.status == ActionStatus.finish then
							status = true
							break
						end
					end
				end
				
				if SysEnv:getInstance():getBool(SysEnv.keys.grow_fund_redpoint) ~= true then
					self:setHolidayStatus(data.bid, status)
					WelfareController:getInstance():setWelfareStatus(ActionSpecialID.growfund, status)
				end
			end
		end
	end
	self.dispather:Fire(ActionEvent.UPDATE_HOLIDAY_SIGNLE, data)
end

-- 皮肤直购
function ActionController:updateSkinDirectPurchase(data)
	--判断是否已购买
	if data.finish ~= 0 then
		--已购买
		self.mainui_ctrl:removeFunctionIconById(MainuiConst.icon.skin_direct_purchase)
		if self.action_skin_direct_purchase_panel then
			self:openActionSkinDirectPurchasePanel(false)
		end
	end
end
--==============================--
--desc:每日充值额外处理
--time:2018-09-25 05:02:09
--@data:
--@return 
--==============================--
function ActionController:handle91005Data(data)
	--找出今日累充和累充天数的数据
	if not self.today_list then
		self.today_list = {}
	end

	if data.aim_list and next(data.aim_list) ~= nil then
		for k, v in pairs(data.aim_list) do
			for a, j in pairs(v.aim_args) do
				if j.aim_args_key == 3 then
					if j.aim_args_val == 1 then --今日累充
						self.today_list[k] = v
						self.today_list[k].has_num = self.has_num
						self.today_list[k].item_effect_list = self.item_effect_list
					end
				elseif j.aim_args_key == 4 then --需要充值多少钱
					if self.today_list[k] then
						self.today_list[k].need_charge = j.aim_args_val
					end
				elseif j.aim_args_key == 5 then --目标值 需要冲多少天
					if self.today_list[k] then
						self.today_list[k].charge_day = j.aim_args_val
					end
				elseif j.aim_args_key == 6 then --计数
					if self.today_list[k] then
						self.today_list[k].has_charge = j.aim_args_val
					end
				end
			end
		end
	end
	self:checkShowDayCharge()
end

--==============================--
--desc:判断显示每日充值与否
--time:2018-09-25 05:55:44
--@return 
--==============================--
function ActionController:checkShowDayCharge()
	local is_over = self:check91005Create()

	if is_over == true then
		self.mainui_ctrl:removeFunctionIconById(MainuiConst.icon.day_charge)
	else
		self.mainui_ctrl:addFunctionIconById(MainuiConst.icon.day_charge)
		-- 设置红点
		local show_red_status = false
		if self.today_list and next(self.today_list ) then
			for i, v in pairs(self.today_list) do
				if v.status == 1 then
					show_red_status = true
					break
				end
			end
		end
		self.mainui_ctrl:setFunctionTipsStatus(MainuiConst.icon.day_charge, show_red_status) 
	end
end

function ActionController:check91005Create()
	local is_all_get = true
	if self.today_list and next(self.today_list or {}) ~= 0 then
		for i, v in pairs(self.today_list) do
			if v.status == 1 or v.status == 0 then --有未达标或者没领取,都代表没领取完毕
				is_all_get = false
				break
			end
		end
	end
	return is_all_get
end

--==============================--
--desc:领取奖励
--time:2017-07-26 08:03:59
--@bid:活动编号
--@aim:完成目标值
--@arg:参数(具体各个活动的作用不一样,抢购的时候,表示一次购买的数量)
--@return 
--==============================--
function ActionController:cs16604(bid, aim, arg)
	local protocal = {}
	protocal.bid = bid
	protocal.aim = aim
	protocal.arg = arg or 0
	self:SendProtocal(16604, protocal)
end

function ActionController:on16604(data)
	showAssetsMsg(data.msg)
end


--==============================--
--desc:活动领取返回
--time:2017-08-10 04:32:02
--@data:
--@return 
--==============================--
function ActionController:on16606(data)
	self:setHolidayStatus(data.bid, (data.can_get_num ~= FALSE))
end

--==============================--
--desc:服务端通知客户端更新相关活动数据,这个时候全部清掉并且重新请求
--time:2019-02-16 05:29:46
--@data:
--@return 
--==============================--
function ActionController:on16607(data)
	if data and data.type == 0 then --0点更新
		self:needRequireData(true)
	end
end

--==============================--
--desc:获取指定类型和指定活动的id的子活动基础数据
--time:2017-07-25 04:56:20
--@bid:
--@return:返回的数据结构为 ActionSubTabVo
--==============================--
function ActionController:getActionSubTabVo(bid)
	return self.holiday_list[bid]
end


--==============================--
--desc:设置指定活动类型的指定子活动编号是否有可领取的奖励
--time:2017-08-31 10:40:42
--@id:活动id,现在活动id是唯一的....根据活动id确定图标
--@status:
--@return 
--==============================--
function ActionController:setHolidayStatus(bid, status)
	if self.holiday_list == nil or self.holiday_list[bid] == nil then return end

	if self.holiday_award_list == nil then
		self.holiday_award_list = {}
	end
	
	if bid == 93042 then--回归兑换bid
		self.return_action_shop_red = status
		if self.return_action_shop_first_red == true then
			status = true
		end
	end
	local vo = {bid = bid,status = status}
	
	local vo1
	if status then
		vo1 = {bid = bid,num = 1}
	else
		vo1 = {bid = bid,num = 0}
	end
	self.holiday_award_list[bid] = vo

	local action_sub_vo = self.holiday_list[bid]
	local function_id = MainuiConst.icon.welfare
	if self:isSpecialBid(bid) then
        self.mainui_ctrl:setFunctionTipsStatus(MainuiConst.icon.welfare, vo1)
	else
        self.mainui_ctrl:setFunctionTipsStatus(action_sub_vo.cli_type, vo1)
		function_id = action_sub_vo.cli_type
	end
	GlobalEvent:getInstance():Fire(ActionEvent.UPDATE_HOLIDAY_TAB_STATUS, function_id, vo)
end

--==============================--
--desc:获取一个指定类型活动指定子活动可领取状态数据
--time:2017-08-31 03:03:56
--@bid:
--@return 
--==============================--
function ActionController:getHolidayAweradsStatus(bid)
	if self.holiday_award_list then
		return self.holiday_award_list[bid]
	end
end


--==============================--
--desc:设置回归商店首次登录红点显示
--time:2017-08-31 03:03:56
--@bid:
--@return 
--==============================--
function ActionController:setReturnActionShopFirstRedStatus(status)
	self.return_action_shop_first_red = status
	local period = ReturnActionController:getInstance():getModel():getCurPeriodByOtherRole()
	if period > 0 then
		if self.return_action_shop_red ~= nil then
			self:setHolidayStatus(93042,self.return_action_shop_red)
		else
			self:setHolidayStatus(93042,false)
		end	
	end
end

--==============================--
--desc:增删一个精彩活动面板里的标签栏
--time:2017-08-31 02:17:25
--@type:0是删除,1是增加
--@bid:如果是存在,则去客户端配置白哦 holiday_client_data 中的配置
--@data:主要用于服务端的,客户端的也是 holiday_client_data 数据
--@return 
--==============================--
function ActionController:handleHolidayList(type, bid)
	-- if bid == nil then return end
	-- if self.holiday_list[bid] == nil then
	-- 	if type == 0 then			-- 如果是要删除的,但是还没来得及创建
	-- 		self.holiday_del_list[bid] = bid
	-- 	else
	-- 		local config = Config.HolidayClientData.data_info[bid]
	-- 		if config ~= nil then
	-- 			self.holiday_list[bid] = ActionSubTabVo.New()
	-- 			if self.holiday_list[bid].update then
	-- 				self.holiday_list[bid]:update(config)
	-- 			end
	-- 		end
	-- 	end
	-- else
	-- 	if type == 0 then
	-- 		self.holiday_list[bid] = nil
	-- 	end
	-- end
end


--==============================--
--desc:打开或者关闭活动主界面
--time:2017-07-25 04:01:56
--@status:打开或者关闭
--@action_type: 属于竞猜活动 还是属于节日活动,MainuiConst.icon.action 或者 MainuiConst.icon.festival
--@action_bid: 跳转的活动id
--@return 
--==============================--
function ActionController:openActionMainPanel(status, function_id, action_bid)
	if status == false then
		if self.action_operate ~= nil then
			if self.action_operate.panel_list ~= nil then
				for k, v in pairs(self.action_operate.panel_list) do
					if k == ActionRankCommonType.white_day then
						BattleController:getInstance():openBattleView(false)
						-- 还原ui战斗类型^M
						MainuiController:getInstance():resetUIFightType()
						break
					end
				end
			end
			self.action_operate:close()
			self.action_operate = nil
		end
	else
		if action_bid then
			local action_vo = self.holiday_list[action_bid]
			if action_vo then
				function_id = action_vo.cli_type
			end
		end
		if function_id == nil then
			function_id = MainuiConst.icon.action
		end

		if self.action_operate == nil then
			self.action_operate = ActionMainWindow.New()
		end
		if self.action_operate:isOpen() == false then
			self.action_operate:open(function_id, action_bid)
		end
	end
end


--- 7天排行任务
function ActionController:requestSevenDaysRank()
	self:SendProtocal(22703, {})
end

function ActionController:on22703(data)
	self.model:updateSevenQuestList(data.feat_list, true)
	GlobalEvent:getInstance():Fire(ActionEvent.UPDATE_SEVENT_QUEST)
end

function ActionController:on22702(data)
	self.model:updateSevenQuestList(data.feat_list)
	GlobalEvent:getInstance():Fire(ActionEvent.UPDATE_SEVENT_QUEST)
end

--- 提交一个7天目标任务
function ActionController:requestSubmitTask(quest_id)
	local protocal = {}
	protocal.quest_id = quest_id
	self:SendProtocal(22704, protocal)
end
function ActionController:on22704(data)
	message(data.msg)
	if data.result == TRUE then
		self.model:delSevenQuest(data.quest_id)
		GlobalEvent:getInstance():Fire(ActionEvent.UPDATE_SEVENT_QUEST)
	end
end

--- 幸运转盘
function ActionController:requestLucky()
	self:SendProtocal(16637, {})
end
function ActionController:handle16637(data)
	self.model:setTreasureInitData(data.dial_data)
	self.model:lucklyRedPoint()
	GlobalEvent:getInstance():Fire(ActionEvent.UPDATE_LUCKYROUND_GET, data)
end

function ActionController:send16638(type,count)
	local protocal = {}
	protocal.type = type
	protocal.type2 = count
	self:SendProtocal(16638, protocal)
end
function ActionController:handle16638(data)
	GlobalEvent:getInstance():Fire(ActionEvent.TREASURE_SUCCESS_DATA, data)
end

function ActionController:handle16639(data)
	GlobalEvent:getInstance():Fire(ActionEvent.UPDATE_LUCKLY_DATA, data)
end

function ActionController:send16640(type,id)
	local protocal = {}
	protocal.type = type
	protocal.id = id
	self:SendProtocal(16640, protocal)
end

function ActionController:handle16641(data)
	GlobalEvent:getInstance():Fire(ActionEvent.UPDATA_TREASURE_LOG_DATA, data)
end
function ActionController:send16642(type)
	local protocal = {}
	protocal.type = type
	self:SendProtocal(16642, protocal)
end
function ActionController:handle16642(data)
	message(data.msg)
	-- GlobalEvent:getInstance():Fire(ActionEvent.UPDATA_TREASURE_REFRESH, data)
end
--弹窗的
function ActionController:send16643(type,count)
	if self.treasure_win then
		local protocal = {}
		protocal.type = type
		protocal.type2 = count
		self:SendProtocal(16643, protocal)
	else
		message(TI18N("亲，不在探宝界面无法进行抽奖哦~~~"))
	end
end
function ActionController:handle16643(data)
	message(data.msg)
	if data.code == 1 then
		GlobalEvent:getInstance():Fire(ActionEvent.UPDATA_TREASURE_POPUPS_SEND, data)
	end
end

-------------------------------升级有礼协议-------------------------------------
function ActionController:send21200()
	local protocal = {}
	self:SendProtocal(21200, protocal)
end

function ActionController:handle21200(data)
	GlobalEvent:getInstance():Fire(ActionEvent.UPDATE_LEVEL_UP_GIFT, data)
end

function ActionController:send21201(id)
	local protocal = {}
	protocal.id = id
	self:SendProtocal(21201, protocal)
end

function ActionController:handle21201(data)
	message(data.msg)
end
-------------------------------升级有礼协议结束-------------------------------------


---------------------------------限时礼包入口信息协议-------------------------------------
function ActionController:send21210()
	local protocal = {}
	self:SendProtocal(21210, protocal)
end

function ActionController:handle21210(data)
	message(data.msg)
	GlobalEvent:getInstance():Fire(ActionEvent.LIMIT_GIFT_MAIN_EVENT, data)
end

--推送激活了显示礼包.并且在某些操作后需要显示
function ActionController:handle21211(data)
	local id = data.id or 0
	-- 18级的不提示
	if 2001 == id then return end
	BattleResultMgr:getInstance():addShowData(BattleConst.Closed_Result_Type.LimitGiftType, data)
end

--检测是否要打开限时礼包界面
--1召唤英雄关闭检测
--2熔炼祭坛升星界面 把英雄升星成功关闭检测
--3背包碎片合成关闭获取界面检测
--4玩家升级检测
function ActionController:checkOpenActionLimitGiftMainWindow(gift_id)
	local config = Config.StarGiftData.data_limit_gift(gift_id)
	if config then
		local gift_id = gift_id 
		local comfirm_callback = function()
			self:openActionLimitGiftMainWindow(true, gift_id)
			GlobalEvent:getInstance():Fire(BattleEvent.NEXT_SHOW_RESULT_VIEW)
		end

		local cancel_callback = function()
			GlobalEvent:getInstance():Fire(BattleEvent.NEXT_SHOW_RESULT_VIEW)
		end

		CommonAlert.show(config.desc,TI18N("前往"),comfirm_callback, TI18N("取消"), cancel_callback)
	else
		GlobalEvent:getInstance():Fire(BattleEvent.NEXT_SHOW_RESULT_VIEW)
	end
end

---------------------------------限时礼包入口信息协议结束-------------------------------------

---------------------------------点金排行榜奖励预览协议(以后可能是活动通用排行奖励信息)-------------------------------------
function ActionController:send16650(bid)
	local protocal = {}
	protocal.bid = bid
	self:SendProtocal(16650, protocal)
end

function ActionController:handle16650(data)
	message(data.msg)
	GlobalEvent:getInstance():Fire(ActionEvent.RANK_REWARD_LIST, data)
end
---------------------------------点金排行榜奖励预览协议(以后可能是活动通用排行奖励信息)结束-------------------------------------

------------------@ 基金相关协议
-- 请求基金开启数据
function ActionController:sender24700(  )
	local protocal = {}
	self:SendProtocal(24700, protocal)
end

function ActionController:handle24700( data )
	if data and data.ids then
		for k,v in ipairs(data.ids) do
	        v.show = 1
    	end
		self.model:setOpenFundIds(data.ids)
		GlobalEvent:getInstance():Fire(ActionEvent.UPDATA_FUND_ID_LIST_EVENT)
	end
end

-- 请求基金数据
function ActionController:sender24701( id )
	local protocal = {}
	protocal.id = id
	self:SendProtocal(24701, protocal)
end

function ActionController:handle24701( data )
	if data then
		self.model:setFundSrvData(data)
		self.model:setWelfareFundSrvData(data)
		GlobalEvent:getInstance():Fire(ActionEvent.UPDATA_FUND_DATA_EVENT, data.id)
	end
end

-- 请求领取基金
function ActionController:sender24702( id )
	local protocal = {}
	protocal.id = id
	self:SendProtocal(24702, protocal)
end

function ActionController:handle24702( data )
	if data.msg then
		message(data.msg)
	end
end


------------------@ 基金相关协议 over
--------------------元宵冒险协议开始-------------------------------------
-- 请求任务信息
function ActionController:sender24810()
	local protocal = {}
	self:SendProtocal(24810, protocal)
end

function ActionController:handle24810( data )
	message(data.msg)
	GlobalEvent:getInstance():Fire(ActionEvent.YUAN_ZHEN_DATA_EVENT, data)
end

--推送任务
function ActionController:handle24811( data )
	GlobalEvent:getInstance():Fire(ActionEvent.YUAN_ZHEN_UPDATA_EVENT, data)
end

-- 完成任务
function ActionController:sender24812(id)
	local protocal = {}
	protocal.id = id
	self:SendProtocal(24812, protocal)
end

function ActionController:handle24812( data )
	message(data.msg)
	if data.code == TRUE then
		GlobalEvent:getInstance():Fire(ActionEvent.YUAN_ZHEN_TASK_EVENT, data)
	end
end
--------------------元宵冒险协议结束-------------------------------------
--试炼之境
function ActionController:sender24813()
	self:SendProtocal(24813, {})
end
function ActionController:handle24813( data )
	message(data.msg)
	GlobalEvent:getInstance():Fire(ActionEvent.YUAN_ZHEN_DATA_EVENT, data)
end
function ActionController:sender24814(id)
	local protocal = {}
	protocal.id = id
	self:SendProtocal(24814, protocal)
end
function ActionController:handle24814( data )
	message(data.msg)
	if data.code == TRUE then
		GlobalEvent:getInstance():Fire(ActionEvent.YUAN_ZHEN_TASK_EVENT, data)
	end
end

--***************
function ActionController:sender24815()
	self:SendProtocal(24815, {})
end
function ActionController:handle24815( data )
	message(data.msg)
	GlobalEvent:getInstance():Fire(ActionEvent.YUAN_ZHEN_DATA_EVENT, data)
end
function ActionController:sender24816(id)
	local protocal = {}
	protocal.id = id
	self:SendProtocal(24816, protocal)
end
function ActionController:handle24816( data )
	message(data.msg)
	if data.code == TRUE then
		GlobalEvent:getInstance():Fire(ActionEvent.YUAN_ZHEN_TASK_EVENT, data)
	end
end

--***************
function ActionController:sender24817()
	self:SendProtocal(24817, {})
end
function ActionController:handle24817( data )
	message(data.msg)
	GlobalEvent:getInstance():Fire(ActionEvent.YUAN_ZHEN_DATA_EVENT, data)
end
function ActionController:sender24818(id)
	local protocal = {}
	protocal.id = id
	self:SendProtocal(24818, protocal)
end
function ActionController:handle24818( data )
	message(data.msg)
	if data.code == TRUE then
		GlobalEvent:getInstance():Fire(ActionEvent.YUAN_ZHEN_TASK_EVENT, data)
	end
end
--------------------满减商城协议开始-------------------------------------

-- 完成任务
function ActionController:sender16665(bid, ids)
	local protocal = {}
	protocal.bid = bid
	protocal.ids = ids
	self:SendProtocal(16665, protocal)
end

function ActionController:handle16665( data )
	message(data.msg)
end
-- 满减红点
function ActionController:sender16666(bid)
	local protocal = {}
	protocal.bid = bid
	self:SendProtocal(16666, protocal)
end

function ActionController:handle16666( data )
	-- message(data.msg)
end

--------------------满减商城协议结束-------------------------------------

-- 10置换活动协议
function ActionController:sender16686(partner_id, partner_bid, expend)
	local protocal = {}
	protocal.partner_id = partner_id
	protocal.partner_bid = partner_bid
	protocal.expend = expend
	self:SendProtocal(16686, protocal)
end

function ActionController:handle16686( data )
	message(data.msg)
end

--合服目标信息
function ActionController:sender27300()
	self:SendProtocal(27300, {})
end
function ActionController:handle27300( data )
	GlobalEvent:getInstance():Fire(ActionEvent.Merge_Aim_Event, data) -- 
end
function ActionController:sender27301( list )
	local protocal = {}
	protocal.reward_list = list
	self:SendProtocal(27301, protocal)
end

function ActionController:handle27301( data )
	GlobalEvent:getInstance():Fire(ActionEvent.Merge_Box_Status_Event, data)
end


--判断是否能充值
function ActionController:sender21016(charge_id)
	local protocal = {}
	protocal.charge_id = charge_id
	self:SendProtocal(21016, protocal)
end
function ActionController:handle21016(data)
	GlobalEvent:getInstance():Fire(ActionEvent.Is_Charge_Event, data)
end

--------------------新服限购协议开始-------------------------------------
--红点
function ActionController:sender16687(send_protocal)
	local protocal = send_protocal or {}
	if tableLen(protocal) == 0 then
		protocal.bid = 91029
	end
    self:SendProtocal(16687, protocal)
end
function ActionController:handle16687(data)
    local status = false
    if data.code == 1 then
        status = true
    end
    data.status = status
    if data.bid == ActionRankCommonType.open_server then
    	MainuiController:getInstance():setFunctionTipsStatus(MainuiConst.icon.open_server_recharge, status)
    elseif data.bid == ActionRankCommonType.high_value_gift or
    	data.bid == ActionRankCommonType.mysterious_store then
    	self.model:updateGiftRedPointStatus(data)
    end
end
--------------------新服限购协议结束-------------------------------------

--------------------杂货铺协议开始-------------------------------------
function ActionController:sender16688()
	local protocal = {}
    self:SendProtocal(16688, protocal)
end
function ActionController:handle16688(data)
	self.model:setStoneShopData(data.buy_info)
    GlobalEvent:getInstance():Fire(ActionEvent.UPDATE_STORE_DATA_EVENT)
end

function ActionController:sender16689(id,num)
	local protocal = {}
	protocal.id = id
	protocal.num = num
    self:SendProtocal(16689, protocal)
end
function ActionController:handle16689(data)
	message(data.msg)
	if data.code == 1 then
		GlobalEvent:getInstance():Fire(ActionEvent.UPDATE_STORE_DATA_SUCCESS_EVENT,data)
	end
end
--------------------新服限购协议结束-------------------------------------

--------------------嘉年华入口协议开始-------------------------------------
function ActionController:sender16695(card_id)
	local protocal = {}
	protocal.card_id = card_id
    self:SendProtocal(16695, protocal)
end

function ActionController:handle16695(data)
	message(data.msg)
	if data.code == 1 then
		self:cs16603(ActionRankCommonType.carnival_report)
	end
end
--------------------嘉年华入口协议结束-------------------------------------

----------------------沙滩争夺站开始---------------------------------------
--活动boss活动界面数据"
function ActionController:sender25400()
	local protocal = {}
    self:SendProtocal(25400, protocal)
end
function ActionController:handle25400(data)
    GlobalEvent:getInstance():Fire(ActionEvent.Aandybeach_Boss_Fight_Action_Event, data)
end

--活动boss信息"
function ActionController:sender25401()
	local protocal = {}
    self:SendProtocal(25401, protocal)
end
function ActionController:handle25401(data)
	self:sender25400()
	self.day_count = data.count
	self.setRemainCount = data.buy_count
    GlobalEvent:getInstance():Fire(ActionEvent.Aandybeach_Boss_Fight_Main_Event, data)
end
--购买挑战次数"
function ActionController:sender25402()
    self:SendProtocal(25402, {})
end
function ActionController:handle25402(data)
	message(data.msg)
    if data.code == 1 then
        self.day_count = data.count
		self.setRemainCount = data.buy_count
        if self.touch_buy_change and data.count == 1 then
            self:sender25404()
        end
        self.touch_buy_change = nil
        GlobalEvent:getInstance():Fire(ActionEvent.Aandybeach_Boss_Fight_Buy_Count_Event, data)
    end
end

--领取奖励"
function ActionController:sender25403(award_id)
	local protocal = {}
	protocal.award_id = award_id
    self:SendProtocal(25403, protocal)
end
function ActionController:handle25403(data)
    GlobalEvent:getInstance():Fire(ActionEvent.Aandybeach_Boss_Fight_Reward_Event, data)
end

--挑战活动boss
function ActionController:sender25404()
    self:SendProtocal(25404, {})
end

function ActionController:handle25404(data)
	message(data.msg)
	if data.code == 1 then
        HeroController:getInstance():openFormGoFightPanel(false)
    end
end

--推送战斗结算（会推送25401）"
function ActionController:handle25405(data)
	GuildbossController:getInstance():openGuildbossResultWindow(true, data, BattleConst.Fight_Type.SandybeachBossFight)
end
--判断次数是否为0,然后进行挑战*******************
--剩余挑战次数
function ActionController:getDayCount()
	if self.day_count then
		return self.day_count
	end
	return 0
end
--今日已购买次数
function ActionController:getRemainCount()
	if self.setRemainCount then
		return self.setRemainCount
	end
	return 0
end
function ActionController:checkJoinFight()
	local buy_data = Config.HolidayBossData.data_buy_info
	if not buy_data then return end

	local max_count = 0
    for i,v in pairs(buy_data) do
	    if v.max >= max_count then
	        max_count = v.max
	    end
	end
	local cur_count = self:getDayCount()
	local remain_count = self:getRemainCount()
	-- print("........... ",max_count,cur_count,remain_count)
	if remain_count >= max_count and cur_count == 0 then
		message(TI18N("今日次数已用完~~~"))
	else
		if cur_count <= 0 then
			local buy_config = self:getUseDiamond()
			if buy_config and next(buy_config.expend) ~= nil then
	            local iconsrc = PathTool.getItemRes(Config.ItemData.data_get_data(3).icon)
	            local count =  buy_config.expend[1][2]
	            local str = string.format(TI18N("是否花费 <img src='%s' scale=0.3 />%s购买一次挑战次数？"), iconsrc, count)
	            local call_back = function()
	                self.touch_buy_change = true
	                self:sender25402()
	            end
	            CommonAlert.show(str, TI18N("确定"), call_back, TI18N("取消"), nil, CommonAlert.type.rich)
	        end
        else
            self:sender25404()
        end
	end
end
--获取购买次数的钻石
function ActionController:getUseDiamond()
	local config_list = Config.HolidayBossData.data_buy_info
    if not config_list then return nil end
    local list = {}
    local table_insert = table.insert
    for i,v in pairs(config_list) do
        table_insert(list, v)
    end
    table.sort(list, function(a, b) return a.min < b.min end)
    if #list == 0 then return nil end

    local remain_count = self:getRemainCount()
    local buy_config
    for i,v in ipairs(list) do
        if remain_count >= v.min and remain_count <= v.max then
            buy_config = v
        end
    end
    return buy_config
end
--end*******************
-- 打开沙滩争夺战
function ActionController:openSandybeachBossFightMainWindow(bool, data)
    if bool == true then
        if not self.sandybeach_boss_fight_main_window then
            self.sandybeach_boss_fight_main_window = SandybeachBossFightMainWindow.New()
        end
        self.sandybeach_boss_fight_main_window:open(data)
    else
        if self.sandybeach_boss_fight_main_window then 
            self.sandybeach_boss_fight_main_window:close()
            self.sandybeach_boss_fight_main_window = nil
        end
    end
end


--end*******************
-- 打开合服目标奖励界面
function ActionController:openMergeAimRewardPanel(bool)
    if bool == true then
        if not self.merge_aim_reaward_panel then
            self.merge_aim_reaward_panel = MergeAimRewardPanel.New()
        end
        self.merge_aim_reaward_panel:open()
    else
        if self.merge_aim_reaward_panel then 
            self.merge_aim_reaward_panel:close()
            self.merge_aim_reaward_panel = nil
        end
    end
end


----------------------沙滩争夺站结束---------------------------------------

-- 打开通用奖励界面
function ActionController:openActionCommonRewardPanel(bool, setting)
    if bool == true then
        if not self.action_common_reward_panel then
            self.action_common_reward_panel = ActionCommonRewardPanel.New()
        end
        self.action_common_reward_panel:open(setting)
    else
        if self.action_common_reward_panel then 
            self.action_common_reward_panel:close()
            self.action_common_reward_panel = nil
        end
    end
end

--神装商店信息
function ActionController:sender25500()
    self:SendProtocal(25500, {})
end
function ActionController:handle25500(data)
	self.model:setLimitTypeData(data.list)
	GlobalEvent:getInstance():Fire(ActionEvent.Updata_Hero_Clothes_Shop_Data,data)
end


--检查活动是否存在exist
--@action_bid 活动基础id
--@camp_id 活动id 属于可以选参数, 如果有值表示需要判定  如果为nil 表示 不需要判定
function ActionController:CheckActionExistByActionBid(action_bid)
	if not action_bid then return false end
	local tab_vo = self:getActionSubTabVo(action_bid)
	if tab_vo then
		return true
	end	
	return false
end

-- 根据camp_id判断活动是否存在
function ActionController:checkActionExistByCampId( camp_id )
	if not camp_id then return false end
	local is_exist = false
	for k,tab_vo in pairs(self.holiday_list) do
		if tab_vo.camp_id == camp_id then
			is_exist = true
			break
		end
	end
	return is_exist 
end

-----------------------------------英雄重生协议============================
--英雄重生
function ActionController:sender11071(partner_id)
	local protocal = {}
    protocal.partner_id = partner_id
    self:SendProtocal(11071, protocal)
end
function ActionController:handle11071(data)
	message(data.msg)
	GlobalEvent:getInstance():Fire(ActionEvent.ACTION_HERO_RESET_EVENT, data)
end

--重生返回材料
function ActionController:sender11072(partner_id)
	local protocal = {}
    protocal.partner_id = partner_id
    self:SendProtocal(11072, protocal)
end

function ActionController:handle11072(data)
	message(data.msg)
	if data.code == TRUE then
		GlobalEvent:getInstance():Fire(ActionEvent.ACTION_HERO_RESET_ITEM_EVENT, data)
	end
end

--伙伴皮肤重生
function ActionController:sender11074(list)
	local protocal = {}
    protocal.list = list
    self:SendProtocal(11074, protocal)
end

function ActionController:handle11074(data)
	message(data.msg)
	
end
-----------------------------------英雄重生协议结束============================


--打开重生选择英雄界面
function ActionController:openActionHeroResetSelectPanel(status,data, open_type, partner)
    if status == true then
        if not self.action_hero_reset_select_panel then
            self.action_hero_reset_select_panel = ActionHeroResetSelectPanel.New()
        end
        self.action_hero_reset_select_panel:open(data, open_type, partner)
    else
        if self.action_hero_reset_select_panel then 
            self.action_hero_reset_select_panel:close()
            self.action_hero_reset_select_panel = nil
        end
    end
end


--打开重生选择英雄皮肤兑换界面
function ActionController:openActionHeroSkinResetPanel(status)
    if status == true then
        if not self.action_hero_skin_reset_panel then
            self.action_hero_skin_reset_panel = ActionHeroSkinResetPanel.New()
        end
        self.action_hero_skin_reset_panel:open(data, open_type, partner)
    else
        if self.action_hero_skin_reset_panel then 
            self.action_hero_skin_reset_panel:close()
            self.action_hero_skin_reset_panel = nil
        end
    end
end

--打开特殊VIP
function ActionController:openActionSpecialVIPWindow(status)
    if status == true then
        if not self.special_vip_view then
            self.special_vip_view = ActionSpecialVipWindow.New()
        end
        self.special_vip_view:open()
    else
        if self.special_vip_view then 
            self.special_vip_view:close()
            self.special_vip_view = nil
        end
    end
end
--打开优惠劵
function ActionController:openActionPerferPrizeWindow(status)
    if status == true then
        if not self.perfer_prize_view then
            self.perfer_prize_view = ActionPerferPrizeWindow.New()
        end
        self.perfer_prize_view:open()
    else
        if self.perfer_prize_view then 
            self.perfer_prize_view:close()
            self.perfer_prize_view = nil
        end
    end
end

--皮肤直购
function ActionController:openActionSkinDirectPurchasePanel(status)
    if status == true then
        if not self.action_skin_direct_purchase_panel then
            self.action_skin_direct_purchase_panel = ActionSkinDirectPurchasePanel.New()
        end
        self.action_skin_direct_purchase_panel:open()
    else
        if self.action_skin_direct_purchase_panel then 
            self.action_skin_direct_purchase_panel:close()
            self.action_skin_direct_purchase_panel = nil
        end
    end
end

--皮肤抽奖
function ActionController:sender26600()
    self:SendProtocal(26600)
end
function ActionController:handle26600(data)
	message(data.msg)
	if data.flag == 1 then
		self.model:updataLotteryItemData(data.sort)
		GlobalEvent:getInstance():Fire(ActionEvent.ACTION_SKIN_LOTTERY_GET,data)
	end
end

function ActionController:sender26601()
    self:SendProtocal(26601)
end
function ActionController:handle26601(data)
	GlobalEvent:getInstance():Fire(ActionEvent.ACTION_SKIN_LOTTERY_MSG,data)
	self.model:setLotteryItemData(data.sort_list, data.lottery_id)
end
function ActionController:sender26602()
    self:SendProtocal(26602)
end
function ActionController:handle26602( data )
	if data then
		local function func()
			GlobalEvent:getInstance():Fire(ActionEvent.ACTION_SKIN_LOTTERY_REWARD)
		end
		self:openTreasureGetItemWindow(true, data.reward_list, 1, 4,func)
	end
end

--是否能显示代金劵图标
function ActionController:handle21020( data )
	if data and data.status == 1 then
		GlobalEvent:getInstance():Fire(ActionEvent.ACTION_PERFER_ISOPEN,data.status)
	end
end

---------------------------------新春限购重置-----------------------------------
--推送新春限购重置
function ActionController:handle16696( data )
	if data and data.code == 1 then
		self:openActionResetChargeWindow(true)
	end
end

-- 打开重置提示界面
function ActionController:openActionResetChargeWindow(bool)
    if bool == true then
        if not self.action_return_charge_window then
            self.action_return_charge_window = ActionResetChargeWindow.New()
        end
        self.action_return_charge_window:open()
    else
        if self.action_return_charge_window then 
            self.action_return_charge_window:close()
            self.action_return_charge_window = nil
        end
    end
end


--元旦充值返利数据
function ActionController:sender28100()
	self:SendProtocal(28100)
end

--元旦充值返利数据
function ActionController:handle28100( data )
	if data then
		GlobalEvent:getInstance():Fire(ActionEvent.UPDATE_RECHARGE_REBATE_EVENT, data)
	end
end

-- 元旦充值返利上报
function ActionController:sender28101()
	self:SendProtocal(28101)
end

-- 元旦充值返利上报返回
function ActionController:handle28101( data )
end

-- 元旦充值返利活动红点
function ActionController:sender28102()
	self:SendProtocal(28102)
end

-- 元旦充值返利活动红点
function ActionController:handle28102( data )
	if data and data.code == 1 then
		self:setHolidayStatus(ActionRankCommonType.recharge_rebate, true)
	else
		self:setHolidayStatus(ActionRankCommonType.recharge_rebate, false)
	end
end

-- 元旦充值返利打开面板请求红点
function ActionController:sender28103()
	self:SendProtocal(28103)
end

function ActionController:handle28103( data )
end

-- 请求精灵重生
function ActionController:send26530( item_bid )
	local protocal = {}
	protocal.item_bid = item_bid
    self:SendProtocal(26530, protocal)
end

-- 精灵重生
function ActionController:handle26530( data )
	message(data.msg)
	GlobalEvent:getInstance():Fire(ActionEvent.SPRITE_RESET_EVENT,data)
end

--打开重生选择精灵界面
function ActionController:openActionSpriteResetSelectPanel(status,data, open_type, partner)
    if status == true then
        if not self.action_sprite_reset_select_panel then
            self.action_sprite_reset_select_panel = ActionSpriteResetSelectPanel.New()
        end
        self.action_sprite_reset_select_panel:open(data, open_type, partner)
    else
        if self.action_sprite_reset_select_panel then 
            self.action_sprite_reset_select_panel:close()
            self.action_sprite_reset_select_panel = nil
        end
    end
end

---------------------------------幸运锦鲤-----------------------------------
-- 请求基础信息
function ActionController:send28400()
	self:SendProtocal(28400)
end

-- 基础信息 
function ActionController:handle28400( data )
	self.model:setLuckyDogData(data)
	GlobalEvent:getInstance():Fire(ActionEvent.LUCKY_DOG_BASE_EVENT)
	self:setHolidayStatus(ActionRankCommonType.lucky_dog, self.lucky_dog_login_red or self.model:getLuckyDogAllRed())
end

-- 请求领取奖励
function ActionController:send28401(period)
	local protocal = {}
	protocal.period = period
    self:SendProtocal(28401, protocal)
end

function ActionController:send28402()
	self:SendProtocal(28402)
end

function ActionController:handle28402(data)
	self.lucky_dog_login_red = data.code == 1
	self:setHolidayStatus(ActionRankCommonType.lucky_dog, self.lucky_dog_login_red or self.model:getLuckyDogAllRed())
end

function ActionController:send28403()
	self:SendProtocal(28403)
end

function ActionController:handle28403(data)
end

---------------------------------不放回抽奖-----------------------------------
-- 打开不放回抽奖规则界面
function ActionController:openFortuneBagRuleWindow(status, rule_data)
	if status then
		if self.fortune_bag_rule_win == nil then
			self.fortune_bag_rule_win = ActionFortuneBagRuleWindow.New()
		end
			self.fortune_bag_rule_win:open(rule_data)
	else
		if self.fortune_bag_rule_win then
			self.fortune_bag_rule_win:close()
			self.fortune_bag_rule_win = nil
		end
	end
end

-- 打开不放回抽奖选择自选大奖界面
function ActionController:openFortuneBagSelectWindow(status, data)
	if status then
		if self.fortune_bag_select_win == nil then
			self.fortune_bag_select_win = ActionFortuneBagSelectWindow.New()
		end
			self.fortune_bag_select_win:open(data)
	else
		if self.fortune_bag_select_win then
			self.fortune_bag_select_win:close()
			self.fortune_bag_select_win = nil
		end
	end
end

-- 抽奖基础信息
function ActionController:sender28300()
	self:SendProtocal(28300)
end

function ActionController:handle28300( data )
	if data then
		GlobalEvent:getInstance():Fire(ActionEvent.FORTUNE_BAG_DRAW_BASE_EVENT, data)
	end
end

-- 奖池奖励信息
function ActionController:sender28301()
	self:SendProtocal(28301)
end

function ActionController:handle28301( data )
	if data then
		GlobalEvent:getInstance():Fire(ActionEvent.FORTUNE_BAG_SURPLUS_EVENT, data)
	end
end

-- 抽奖
function ActionController:sender28302(pos)
	local protocal = {}
    protocal.pos = pos
	self:SendProtocal(28302, protocal)
end

function ActionController:handle28302( data )
	message(data.msg)
end

-- 请求终极奖励可选列表
function ActionController:sender28303()
	self:SendProtocal(28303)
end

function ActionController:handle28303( data )
	if data then
		GlobalEvent:getInstance():Fire(ActionEvent.FORTUNE_BAG_ULTIMATE_EVENT, data)
	end
end

-- 选择终极奖励
function ActionController:sender28305(type_id)
	local protocal = {}
    protocal.type_id = type_id
	self:SendProtocal(28305, protocal)
end

function ActionController:handle28305( data )
end

function ActionController:sender28306()
	self:SendProtocal(28306)
end

-- 红点
function ActionController:handle28306( data )
	if data and data.code and data.code == 1 then
		self:setHolidayStatus(ActionRankCommonType.FortuneBagDraw, true)
		return
	end
	self:setHolidayStatus(ActionRankCommonType.FortuneBagDraw, false)
end

-- 打开活动面板请求
function ActionController:sender28307()
	self:SendProtocal(28307)
end

-- 请求前往下一轮
function ActionController:sender28308()
	self:SendProtocal(28308)
end

---------------------------------定时领奖（神明的新春祝福）-----------------------------------
-- 定时领奖图标控制
function ActionController:send16697( )
	local protocal = {}
    self:SendProtocal(16697, protocal)
end

-- 定时领奖图标控制
function ActionController:handle16697( data )
	self.model:setActionTimeCollectData(data)
	-- message(data.msg)
	GlobalEvent:getInstance():Fire(ActionEvent.Update_Time_Collect_Main_Icon_Event,data.code)
end

-- 领奖
function ActionController:send16698( id )
	local protocal = {}
	protocal.id = id
    self:SendProtocal(16698, protocal)
end

-- 领奖
function ActionController:handle16698( data )
	message(data.msg)
end

--打开定时领奖（神明的新春祝福）界面
function ActionController:openActionTimeCollectWindow(status,evt_type, step_id, data)
    if status == true then
        if not self.action_time_collect_window then
            self.action_time_collect_window = ActionTimeCollectWindow.New()
        end
        self.action_time_collect_window:open(evt_type, step_id, data)
    else
        if self.action_time_collect_window then 
            self.action_time_collect_window:close()
            self.action_time_collect_window = nil
        end
    end
end

function ActionController:sender10971()
	local protocal = {}
	protocal.bid = ActionRankCommonType.ouqi_gift
    self:SendProtocal(10971, protocal)
end
function ActionController:handle10971(data)
	local https_path = nil
    if PLATFORM_NAME == "demo" or PLATFORM_NAME == "release" or PLATFORM_NAME == "release2" then
    	https_path = "http://test-cms-sszg.shiyue.com/m/spring_festival.html"
    else
    	https_path = "https://sszg.shiyue.com/m/spring_festival.html"
    end

    local token = data.token
    local string_format = string.format
    local role_vo = RoleController:getInstance():getRoleVo()
    local platform, sid = unpack(Split(role_vo.srv_id, "_"))

    local result_str = string_format("%s%s%s%s%s", role_vo.rid, PLATFORM_NAME, sid, GameNet:getInstance():getTime(), "He952ae2a6ea8cdG7410j6T42d7ce32")
    result_str = cc.CCGameLib:getInstance():md5str(result_str)
    result_str = string_format("role_id=%s&platform=%s&zone_id=%s&ctime=%s&flag=%s&token=%s", role_vo.rid, PLATFORM_NAME, sid, GameNet:getInstance():getTime(), result_str,token)
    result_str = encodeBase64(result_str)
    result_str = string_format("%s?%s", https_path, result_str)    
    if IS_IOS_PLATFORM == true then
        sdkCallFunc("openSyW", result_str)
    else
        sdkCallFunc("openUrl", result_str)
    end
end

--打开欧气大礼包tips
function ActionController:openOuqiGiftTips()
	--消掉红点
	self:sender16687({bid=ActionRankCommonType.ouqi_gift}) 
	local call_back = function()
		self:sender10971()
    end
    local str = TI18N("抽取新年红包,需要打开浏览器哦~")
    CommonAlert.show(str, TI18N("确定"), call_back, nil, nil, CommonAlert.type.rich, nil, nil, nil, true)
end

--------------------------------@ 甜蜜大作战（情人节活动）
-- 请求基础信息
function ActionController:sender28500()
	local protocal = {}
    self:SendProtocal(28500, {})
end

function ActionController:handle28500( data )
	self.model:setSweetData(data)
	GlobalEvent:getInstance():Fire(ActionEvent.Update_Sweet_Data_Event)
end

-- 请求领取奖励
function ActionController:sender28501(reward_list)
	local protocal = {}
	protocal.reward_list = reward_list
    self:SendProtocal(28501, protocal)
end

function ActionController:handle28501( data )
	if data.msg and data.msg ~= "" then
		message(data.msg)
	end
end

-- 请求捐献物品
function ActionController:sender28502( id, num )
	local protocal = {}
	protocal.id = id
	protocal.num = num
    self:SendProtocal(28502, protocal)
end

function ActionController:handle28502( data )
	if data.msg and data.msg ~= "" then
		message(data.msg)
	end
	if data.code == TRUE then
		GlobalEvent:getInstance():Fire(ActionEvent.Sweet_Put_Success_Event, data.id)
	end
end

-- 打开甜蜜大作战奖励界面
function ActionController:openActionSweetAwardWindow( status )
	if status == true then
		if not self.sweet_award_wnd then
			self.sweet_award_wnd = ActionSweetAwardWindow.New()
		end
		self.sweet_award_wnd:open()
	else
		if self.sweet_award_wnd then
			self.sweet_award_wnd:close()
			self.sweet_award_wnd = nil
		end
	end
end

---------------------------------白色情人节活动（女神试炼）-----------------------------------
-- 查询活动信息
function ActionController:sender28800()
	local protocal = {}
    self:SendProtocal(28800, {})
end

function ActionController:handle28800(data)
	if data and data.time and data.time > 0 then
		self:setHolidayStatus(ActionRankCommonType.white_day, true)
	else
		self:setHolidayStatus(ActionRankCommonType.white_day, false)
	end
	self.model:setWhiteDayData(data)
	GlobalEvent:getInstance():Fire(ActionEvent.White_Day_Init_Event, data)
end

-- 挑战Boss
function ActionController:sender28801(id, formation_type, pos_info, hallows_id)
	local protocal = {}
	protocal.id = id
	protocal.formation_type = formation_type
	protocal.pos_info = pos_info
	protocal.hallows_id = hallows_id
	self:SendProtocal(28801, protocal)
end

function ActionController:handle28801(data)
	if data.msg then
		message(data.msg)
	end
end

-- 战斗结果
-- function ActionController:sender28802()
-- 	local protocal = {}
--     self:SendProtocal(28802, {})
-- end

function ActionController:handle28802(data)
	data.item_rewards = data.reward
    for i,v in ipairs(data.item_rewards) do
		v.bid = v.base_id
		local item_config = Config.ItemData.data_get_data(v.bid)
		v.quality = item_config.quality
	end
	table.sort(data.item_rewards,function(a,b) return a.quality > b.quality end)
	data.result = 1
    BattleController:getInstance():openFinishView(true, BattleConst.Fight_Type.WhiteDayWar, data)
end

-- 购买挑战次数
function ActionController:sender28803()
	local protocal = {}
    self:SendProtocal(28803, {})
end

function ActionController:handle28803(data)
	if data.msg then
		message(data.msg)
	end
end

---------------------------------超值周卡-----------------------------------
-- 超值周卡信息
function ActionController:sender16653()
	local protocal = {}
	self:SendProtocal(16653, {})
end

function ActionController:handle16653(data)
	self.model:setSuperWeekData(data)
	if data and data.award_list then
		local red_status = false
		for k, v in pairs(data.award_list) do
			if v and v.finish and v.finish == 1 then
				red_status = true
				break
			end
		end
		self:setHolidayStatus(ActionRankCommonType.super_week_card, red_status)
	end
	GlobalEvent:getInstance():Fire(ActionEvent.SuperValueWeeklyCard_Init_Event, data)
end

-- 领取超值周卡奖励
function ActionController:sender16654(id)
	local protocal = {}
	protocal.id = id
    self:SendProtocal(16654, protocal)
end

function ActionController:handle16654(data)
	if data.msg then
		message(data.msg)
	end
end