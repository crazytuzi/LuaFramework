-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2019-06-04
-- --------------------------------------------------------------------
HomeworldController = HomeworldController or BaseClass(BaseController)

function HomeworldController:config()
    self.model = HomeworldModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function HomeworldController:getModel()
    return self.model
end

function HomeworldController:registerEvents()
end

function HomeworldController:registerProtocals()
	self:RegisterProtocal(26001, "handle26001") -- 家园房间基础
	self:RegisterProtocal(26002, "handle26002") -- 家具摆放返回
	self:RegisterProtocal(26003, "handle26003") -- 请求进入玩家家园
	self:RegisterProtocal(26004, "handle26004") -- 形象基础
	self:RegisterProtocal(26005, "handle26005") -- 使用形象
	self:RegisterProtocal(26006, "handle26006") -- 购买形象
	self:RegisterProtocal(26007, "handle26007") -- 设置初始形象
	self:RegisterProtocal(26008, "handle26008") -- 访问形象通知
	self:RegisterProtocal(26009, "handle26009") -- 随机访问对象
	self:RegisterProtocal(26010, "handle26010") -- 来访者数据
	self:RegisterProtocal(26011, "handle26011") -- 我的家园名称变化
	self:RegisterProtocal(26012, "handle26012") -- 被点赞数更新
	self:RegisterProtocal(26013, "handle26013") -- 套装奖励数据
	self:RegisterProtocal(26014, "handle26014") -- 领取套装奖励
	self:RegisterProtocal(26015, "handle26015") -- 一些基础数据更新（今日剩余点赞次数）
	self:RegisterProtocal(26016, "handle26016") -- 在线累计时长
	self:RegisterProtocal(26017, "handle26017") -- 是否第一次打开的标识
	self:RegisterProtocal(26018, "handle26018") -- 登陆红点
	self:RegisterProtocal(26019, "handle26019") -- 今日点赞过的玩家
	self:RegisterProtocal(26020, "handle26020") -- 人气排行
	self:RegisterProtocal(26021, "handle26021") -- 更好主居室
end

-- 家园房间基础（先请求 26004形象数据，有设置形象才请求本条协议）
function HomeworldController:sender26001( floor )
	local protocal = {}
	protocal.floor = floor or 0
	self:SendProtocal(26001, protocal)
end

function HomeworldController:handle26001( data )
	if data.name then
		self.model:setMyHomeName(data.name)
	end

	if data.soft then
		self.model:setHomeComfortValue(data.soft)
	end

	if data.worship then
		self.model:setHomeWorship(data.worship)
	end

	if data.rest_worship then
		self.model:setLeftWorshipNum(data.rest_worship)
	end

	if data.acc_hook_time then
		self.model:setHomeAccHookTime(data.acc_hook_time)
	end

	if data.wall_bid then
		self.model:setMyHomeWallId(data.wall_bid)
	end

	if data.land_bid then
		self.model:setMyHomeFloorId(data.land_bid)
	end

	if data.list then
		self.model:setMyHomeFurnitureData(data.list)
	end

	if data.visitors then
		self.model:setMyHomeVisitorsData(data.visitors)
	end

	if data.floor then
		self.model:setMyHomeCurStoreyIndex(data.floor, data.max_soft_floor)
	end

	if data.main_floor then
		self.model:setMyHomeMainStoreyIndex(data.main_floor)
	end

	if data.max_all_soft then
		self.model:setMaxAllSoftValue(data.max_all_soft)
	end

	if data.other_bid then
		self.model:setOtherStoreyFurnitureData(data.other_bid)
	end

	if data.max_floor_soft then
		self.model:setMyHomeMaxStoreySoft(data.max_floor_soft)
	end

	GlobalEvent:getInstance():Fire(HomeworldEvent.Get_My_Home_Data_Event)
end

-- 请求设置家具数据
function HomeworldController:sender26002( wall_bid, land_bid, list, floor )
	local protocal = {}
	protocal.wall_bid = wall_bid
	protocal.land_bid = land_bid
	protocal.list = list
	protocal.floor = floor
	self:SendProtocal(26002, protocal)
end

function HomeworldController:handle26002( data )
	if data.msg then
		message(data.msg)
	end
	if data.code == 1 then -- 布局成功
		-- 舒适度
		if data.soft then
			self.model:setHomeComfortValue(data.soft)
		end
		-- 家具相关
		if data.wall_bid then
			self.model:setMyHomeWallId(data.wall_bid)
		end

		if data.land_bid then
			self.model:setMyHomeFloorId(data.land_bid)
		end

		if data.list then
			self.model:setMyHomeFurnitureData(data.list)
		end

		-- 舒适度最高楼层变化时提示
		if self.model:checkMaxStoreyIsChange(data.max_soft_floor) then
			local msg = string.format(TI18N("当前舒适度最高楼层为%d楼"), data.max_soft_floor)
	        local extend_msg = TI18N("家园币的产出仅由舒适度最高的楼层决定")
	        CommonAlert.show(msg,TI18N("确定"),nil,nil,nil,nil,nil,{off_y = 43, title = TI18N("提示"), extend_str = extend_msg, extend_offy = -5, extend_aligment = cc.TEXT_ALIGNMENT_CENTER })
		end

		if data.floor then
			self.model:setMyHomeCurStoreyIndex(data.floor, data.max_soft_floor)
		end

		if data.max_all_soft then
			self.model:setMaxAllSoftValue(data.max_all_soft)
		end

		if data.other_bid then
			self.model:setOtherStoreyFurnitureData(data.other_bid)
		end

		if data.max_floor_soft then
			self.model:setMyHomeMaxStoreySoft(data.max_floor_soft)
		end

		GlobalEvent:getInstance():Fire(HomeworldEvent.Update_Some_Data_Event)
	else  -- 布局失败
		GlobalEvent:getInstance():Fire(HomeworldEvent.Get_My_Home_Data_Event)
	end
end

-- 请求访问玩家家园
function HomeworldController:sender26003( rid, srv_id, floor )
	local protocal = {}
	protocal.rid = rid
	protocal.srv_id = srv_id
	protocal.floor = floor or 0
	self:SendProtocal(26003, protocal)
end

function HomeworldController:handle26003( data )
	if data.msg then
		message(data.msg)
	end
	if data.code == 1 then
		-- 进入其他玩家的家园
		if self.homeworld_scene then
			self.homeworld_scene:goToOtherPlayerHome(data)
		else
			self:openHomeworldScene(true, data)
		end
	end
end

-- 形象基础
function HomeworldController:sender26004(  )
    self:SendProtocal(26004, {})
end

function HomeworldController:handle26004( data )
	if data.is_finish == 1 then
		-- 当前形象id为0，且家园界面正在显示，则弹出初始形象选择界面
		if data.use_id == 0 then
			self:openHomeworldFigureChoseWindow(true)
		else
			self.model:setMyCurHomeFigureId(data.use_id or 0)
			if self.open_my_home_flag then -- 打开我的家园
				self.open_my_home_flag = false
				self:openHomeworldScene(true)
			elseif self.back_my_home_flag then -- 返回我的家园
				self.back_my_home_flag = false
				if self.homeworld_scene then
					self.homeworld_scene:backToMyHomeworld()
				else
					self:openHomeworldScene(true)
				end
			end
		end
		self.model:setMaxComfortValue(data.max_soft or 0)
		self.model:setActivateFigureList(data.list or {})
	else
		if not self.is_show_goto then
			self.is_show_goto = true
		    local desc = TI18N("前往【<div fontColor=#289b14 fontsize= 26>日常任务-进阶历练</div>】领取神秘奖励可开启家园，是否立即前往领取？")
		    local _comfirm = function()
		    	self.is_show_goto = false
		        TaskController:getInstance():openTaskMainWindow(true, TaskConst.type.exp)
			end

		    local _cancel = function ( )
		    	self.is_show_goto = false
		    end
		    CommonAlert.show(desc, TI18N("前往"), _comfirm, TI18N("取消"), _cancel, CommonAlert.type.rich, nil, {view_tag=ViewMgrTag.RECONNECT_TAG})
		end
		-- message(TI18N("前往【日常任务-进阶历练】领取神秘礼物后可开启家园"))
	end
end

-- 使用形象
function HomeworldController:sender26005( id )
	local protocal = {}
	protocal.id = id
	self:SendProtocal(26005, protocal)
end

function HomeworldController:handle26005( data )
	if data.msg then
		message(data.msg)
	end
	if data.code == 1 and data.id then
		self.model:setMyCurHomeFigureId(data.id)
		GlobalEvent:getInstance():Fire(HomeworldEvent.Update_My_Home_Figure_Event)
	end
end

-- 购买形象
function HomeworldController:sender26006( id )
	local protocal = {}
	protocal.id = id
	self:SendProtocal(26006, protocal)
end

function HomeworldController:handle26006( data )
	if data.msg then
		message(data.msg)
	end
	if data.code == 1 then
		self.model:addFigureIdToActiveList(data.id)
		GlobalEvent:getInstance():Fire(HomeworldEvent.Update_My_Figure_Data_Event, data.id)
	end
end

-- 设置初始形象
function HomeworldController:sender26007( id )
	local protocal = {}
	protocal.id = id
	self:SendProtocal(26007, protocal)
end

function HomeworldController:handle26007( data )
	if data.msg then
		message(data.msg)
	end
end

-- 访问形象通知
function HomeworldController:handle26008( data )

end

-- 请求随机访问者数据
function HomeworldController:sender26009(  )
	self:SendProtocal(26009, {})
end

function HomeworldController:handle26009( data )
	if data and data.list then
		self.model:setRandomVisiterData(data.list)
		GlobalEvent:getInstance():Fire(HomeworldEvent.Get_Random_Visiter_Event, data.list)
	end
end

-- 请求来访者数据
function HomeworldController:sender26010(  )
	self:SendProtocal(26010, {})
end

function HomeworldController:handle26010( data )
	if data and data.list then
		GlobalEvent:getInstance():Fire(HomeworldEvent.Get_My_Home_Visiter_Event, data.list)
	end
end

-- 请求修改家园名称
function HomeworldController:sender26011( name )
	local protocal = {}
	protocal.name = name
	self:SendProtocal(26011, protocal)
end

function HomeworldController:handle26011( data )
	if data.msg then
		message(data.msg)
	end
	if data.code == 1 then
		self.model:setMyHomeName(data.name)
		GlobalEvent:getInstance():Fire(HomeworldEvent.Update_My_Home_Name_Event, data.name)
	end
end

-- 我的家园一些数据变化（点赞数等）
function HomeworldController:handle26012( data )
	if data.worship then
		self.model:setHomeWorship(data.worship)
	end
	GlobalEvent:getInstance():Fire(HomeworldEvent.Update_Some_Data_Event)
end

-- 请求套装奖励数据
function HomeworldController:sender26013(  )
	self:SendProtocal(26013, {})
end

function HomeworldController:handle26013( data )
	if data and data.list then
		self.model:setHomeSuitAwardData(data.list)
		GlobalEvent:getInstance():Fire(HomeworldEvent.Get_Suit_Award_Data_Event)
	end
end

-- 请求领取套装奖励
function HomeworldController:sender26014( id )
	local protocal = {}
	protocal.id = id
	self:SendProtocal(26014, protocal)
end

function HomeworldController:handle26014( data )
	if data and data.msg then
		message(data.msg)
	end
end

-- 一些数据更新
function HomeworldController:handle26015( data )
	if data.rest_worship then
		self.model:setLeftWorshipNum(data.rest_worship)
		GlobalEvent:getInstance():Fire(HomeworldEvent.Update_Left_Worship_Num)
	end

	if data.acc_hook_time then
		self.model:setHomeAccHookTime(data.acc_hook_time)
		GlobalEvent:getInstance():Fire(HomeworldEvent.Update_Acc_Hook_Time_Data)
	end

	if data.max_soft then
		self.model:setMaxComfortValue(data.max_soft)
	end
end

-- 请求领取家园币
function HomeworldController:sender26016(  )
	self:SendProtocal(26016, {})
end

function HomeworldController:handle26016( data )
	if data and data.msg then
		message(data.msg)
	end
end

function HomeworldController:handle26017( data )
	if data then
		self.model:setHomeFirstOpenFlag(data.is_first)
	end
end

-- 登陆红点
function HomeworldController:handle26018( data )
	if data then
		local visit_red_status = false
		if data.code == 1 then
			visit_red_status = true
		end
		self.model:updateHomeworldRedStatus(HomeworldConst.Red_Index.Visit, visit_red_status, true)

		local hook_red_status = false
		if data.hook_code == 1 then
			hook_red_status = true
		end
		self.model:updateHomeworldRedStatus(HomeworldConst.Red_Index.Hook, hook_red_status)
	end
end

-- 请求今日点赞过的玩家数据
function HomeworldController:sender26019(  )
	self:SendProtocal(26019, {})
end

function HomeworldController:handle26019( data )
	if data.list then
		self.model:setTodayWorshipPlayerData(data.list)
		GlobalEvent:getInstance():Fire(HomeworldEvent.Get_Today_Worship_Data)
	end
end

-- 请求人气排行
function HomeworldController:sender26020(  )
	self:SendProtocal(26020, {})
end

function HomeworldController:handle26020( data )
	GlobalEvent:getInstance():Fire(HomeworldEvent.Get_Rank_Data_Event, data)
end

-- 设置为主居室
function HomeworldController:sender26021( main_floor )
	local protocal = {}
	protocal.main_floor = main_floor
	self:SendProtocal(26021, protocal)
end

function HomeworldController:handle26021( data )
	if data.msg then
		message(data.msg)
	end
	if data.code == TRUE and data.main_floor then
		self.model:setMyHomeMainStoreyIndex(data.main_floor)

		-- 舒适度最高楼层变化时提示
		if self.model:checkMaxStoreyIsChange(data.max_soft_floor) then
			local msg = string.format(TI18N("当前舒适度最高楼层为%d楼"), data.max_soft_floor)
	        local extend_msg = TI18N("家园币的产出仅由舒适度最高的楼层决定")
	        CommonAlert.show(msg,TI18N("确定"),nil,nil,nil,nil,nil,{off_y = 43, title = TI18N("提示"), extend_str = extend_msg, extend_offy = -5, extend_aligment = cc.TEXT_ALIGNMENT_CENTER })
		end

		self.model:updateMaxSoftStoreyIndex(data.max_soft_floor)
		
		GlobalEvent:getInstance():Fire(HomeworldEvent.Update_Main_Storey_Event)
	end
end

-----------------@ 界面相关
-- 请求进入家园(先请求 26004 形象数据，有设置形象才允许进入家园)
-- is_back:是否为从其他家园返回我的家园
function HomeworldController:requestOpenMyHomeworld( is_back )
	if not self.model:checkHomeworldIsOpen() then return end
	if is_back then
		self.back_my_home_flag = true
	else
		self.open_my_home_flag = true
	end
	self:sender26004()
end

--是否打开家园中
function HomeworldController:isOpenHomeWorldScene()
	if self.homeworld_scene and self.homeworld_scene:isOpen() then
		return true
	end
	return false
end

-- 打开家园主界面 other_data:打开别人家园时的家园数据
-- #warning#:进入家园不是调用这个接口，而是requestOpenMyHomeworld
function HomeworldController:openHomeworldScene( status, other_data )
	if status == true then
		if not self.model:checkHomeworldIsOpen() then return end

		if not self.homeworld_scene then
			self.homeworld_scene = HomeWorldScene.New()
		end
		if self.homeworld_scene:isOpen() == false then
			self.homeworld_scene:open(other_data)
		end
	else
		if self.homeworld_scene then
			self.homeworld_scene:close()
			self.homeworld_scene = nil
		end
	end
end

-- 引导需要
function HomeworldController:getHomeworldRoot(  )
	if self.homeworld_scene then
        return self.homeworld_scene.root_wnd
    end
end
-- 家园白天、黑夜切换
function HomeworldController:changeHomeTimeType( time )
	if self.homeworld_scene then
		self.homeworld_scene:updateHomeBgByTime(time)
	end
end

-- 获取家园中是否处于编辑状态
function HomeworldController:getHomeEditStatus(  )
	if self.homeworld_scene then
		return self.homeworld_scene:getHomeEditStatus()
	end
end

-- 根据家具bid获取当前家园场景中是否有该家具
function HomeworldController:checkCurHomeIsHaveUnitByBid( bid )
	local is_have = false
	if self.homeworld_scene then
		is_have = self.homeworld_scene:checkCurHomeIsHaveUnitByBid(bid)
	end
	return is_have
end

-- 获取家园当前场景中家具的实时舒适度
function HomeworldController:getCurHomeSoftVal(  )
	local soft_val = 0
	if self.homeworld_scene then
		soft_val = self.homeworld_scene:getCurHomeSoftVal()
	end
	return soft_val
end

-- 获取家园当前场景中地面家具所占格子数
function HomeworldController:getCurOccupyGridNum(  )
	local grid_num = 0
	if self.homeworld_scene then
		grid_num = self.homeworld_scene:getCurOccupyGridNum()
	end
	return grid_num
end

-- 获取家园场景中所有角色所占的格子
function HomeworldController:getAllRoleCurGridData(  )
	local grid_list = {}
	if self.homeworld_scene then
		grid_list = self.homeworld_scene:getAllRoleCurGridData()
	end
	return grid_list
end

-- 家园当前场景的缩放值
function HomeworldController:getHomeSceneScaleVal(  )
	if self.homeworld_scene then
		return self.homeworld_scene.cur_scale_val or 1
	end
end

-- 判断当前家园的主人是不是同一个
function HomeworldController:checkHomeIsSameByRidAndSrvId( rid, srv_id )
	if self.homeworld_scene then
		local other_rid, other_srv_id = self.homeworld_scene:getOtherHomeRidAndSrvId()
		if other_rid and other_srv_id and other_rid == rid and other_srv_id == srv_id then
			return true
		end
	end
	return false
end

-- 更新一下被占用格子的数据
--[[
	除去以下数据中的单位（如果只有 unit_type ，则该类单位都不计算格子）
	unit_data:{{unit_type, unit_id}, {unit_type, unit_id}}
	carpet_flag: 1:不计算地毯所占格子 2:家具中只计算地毯的格子
]]
function HomeworldController:updateOccupyGridList( unit_data, carpet_flag )
	if self.homeworld_scene then
		local grid_list = self.homeworld_scene:getOccupyGridList( unit_data, carpet_flag )
		self.model:updateOccupyGridList(grid_list)
	end
end

function HomeworldController:getOccupyGridList( unit_data, carpet_flag )
	local grid_list = {}
	if self.homeworld_scene then
		grid_list = self.homeworld_scene:getOccupyGridList( unit_data, carpet_flag )
	end
	return grid_list
end

-- 更新一下场景中家具和角色的层级关系
function HomeworldController:updateAllUnitZorder(  )
	if self.homeworld_scene then
		self.homeworld_scene:updateAllFurnitureZOrder()
	end
end

-- 进入预览模式
function HomeworldController:enterPreviewState( data )
	if self.homeworld_scene then
		self.homeworld_scene:enterPreviewState(data)
	end
end

-- 打开宅室商店
function HomeworldController:openHomeworldShopWindow( status , setting)
	if status == true then
		if not self.model:checkHomeworldIsOpen() then return end
		
		if not self.homeworld_shop then
			self.homeworld_shop = HomeworldShopWindow.New()
		end
		if self.homeworld_shop:isOpen() == false then
			self.homeworld_shop:open(setting)
		end
	else
		if self.homeworld_shop then
			self.homeworld_shop:close()
			self.homeworld_shop = nil
		end
	end
end

-- 引导需要
function HomeworldController:getHomeShopRoot( )
	if self.homeworld_shop then
		return self.homeworld_shop.root_wnd
	end
end

-- 打开解锁家园钥匙
function HomeworldController:openHomeworldUnlockKeyPanel( status )
	if status == true then
		if not self.homeworld_unlock_key then
			self.homeworld_unlock_key = HomeworldUnlockKeyPanel.New()
		end
		if self.homeworld_unlock_key:isOpen() == false then
			self.homeworld_unlock_key:open()
		end
	else
		if self.homeworld_unlock_key then
			self.homeworld_unlock_key:close()
			self.homeworld_unlock_key = nil
		end
	end
end
-- 引导需要
function HomeworldController:getHomeworldUnlockKey( )
	if self.homeworld_unlock_key then
		return self.homeworld_unlock_key.root_wnd
	end
end

-- 打开拜访界面
function HomeworldController:openHomeworldVisitWindow( status )
	if status == true then
		if not self.homeworld_visit then
			self.homeworld_visit = HomeworldVisitWindow.New()
		end
		if self.homeworld_visit:isOpen() == false then
			self.homeworld_visit:open()
		end
	else
		if self.homeworld_visit then
			self.homeworld_visit:close()
			self.homeworld_visit = nil
		end
	end
end

-- 打开套装一览界面
function HomeworldController:openHomeworldSuitWindow( status, suit_id )
	if status == true then
		if not self.homeworld_suit then
			self.homeworld_suit = HomeworldSuitWindow.New()
		end
		if self.homeworld_suit:isOpen() == false then
			self.homeworld_suit:open(suit_id)
		end
	else
		if self.homeworld_suit then
			self.homeworld_suit:close()
			self.homeworld_suit = nil
		end
	end
end

-- 隐藏/显示家具套装界面（用于预览时）
function HomeworldController:showHomeworldSuitWindow( status )
	if self.homeworld_suit then
		self.homeworld_suit:showSelfWindow(status)
	end
end

-- 形象设置
function HomeworldController:openHomeworldFigureWindow( status )
	if status == true then
		if not self.homeworld_figure then
			self.homeworld_figure = HomeworldFigureWindow.New()
		end
		if self.homeworld_figure:isOpen() == false then
			self.homeworld_figure:open()
		end
	else
		if self.homeworld_figure then
			self.homeworld_figure:close()
			self.homeworld_figure = nil
		end
	end
end

-- 选择形象界面
function HomeworldController:openHomeworldFigureChoseWindow( status )
	if status == true then
		if not self.homeworld_figure_chose then
			self.homeworld_figure_chose = HomeworldFigureChoseWindow.New()
		end
		if self.homeworld_figure_chose:isOpen() == false then
			self.homeworld_figure_chose:open()
		end
	else
		if self.homeworld_figure_chose then
			self.homeworld_figure_chose:close()
			self.homeworld_figure_chose = nil
		end
	end
end

-- 购买界面 open_type:1家具商城 2:出行商城 3:随机商城
function HomeworldController:openHomeworldBuyWindow( status, data, open_type )
	if status == true then
		if not self.homeworld_buy_wnd then
			self.homeworld_buy_wnd = HomeworldBuyUnitWindow.New()
		end
		if self.homeworld_buy_wnd:isOpen() == false then
			self.homeworld_buy_wnd:open(data, open_type)
		end
	else
		if self.homeworld_buy_wnd then
			self.homeworld_buy_wnd:close()
			self.homeworld_buy_wnd = nil
		end
	end
end

-- 引导需要
function HomeworldController:getHomeworldBuyRoot(  )
	if self.homeworld_buy_wnd then
		return self.homeworld_buy_wnd.root_wnd
	end
end

--萌宠跳转方法 行囊或旅行
function HomeworldController:openHomeperBag()
	local homepet_vo = HomepetController:getInstance():getModel():getHomePetVo()
	if not homepet_vo then return end
    local state = homepet_vo:getPetState()
    if state == HomepetConst.state_type.eNotActive then --未未激活
        HomepetController:getInstance():openHomePetGooutProgressPanel(true)
    elseif state == HomepetConst.state_type.eHome then --在家
        HomepetController:getInstance():openHomePetTravellingBagPanel(true)
    elseif state == HomepetConst.state_type.eOnWay then --路上
        HomepetController:getInstance():openHomePetGooutProgressPanel(true)
    end
end

--萌宠跳转方法 道具
function HomeworldController:openHomeperItem()
	local setting = {}
    setting.show_type = HomepetConst.Item_bag_show_type.eBagItemType
    HomepetController:getInstance():openHomePetItemBagPanel(true, setting)
end
--萌宠跳转方法 收藏
function HomeworldController:openHomeperCollect()
	HomepetController:getInstance():openHomePetCollectionPanel(true)
end

-- 家具信息界面
function HomeworldController:openFurnitureInfoWindow( status, id )
	if status == true then
		if not self.homeworld_unit_info then
			self.homeworld_unit_info = HomeworldUnitInfoWindow.New()
		end
		if self.homeworld_unit_info:isOpen() == false then
			self.homeworld_unit_info:open(id)
		end
	else
		if self.homeworld_unit_info then
			self.homeworld_unit_info:close()
			self.homeworld_unit_info = nil
		end
	end
end

-- 家园详情
function HomeworldController:openHomeInfoWindow( status )
	if status == true then
		if not self.homeworld_info then
			self.homeworld_info = HomeworldInfoWindow.New()
		end
		if self.homeworld_info:isOpen() == false then
			self.homeworld_info:open()
		end
	else
		if self.homeworld_info then
			self.homeworld_info:close()
			self.homeworld_info = nil
		end
	end
end

function HomeworldController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end

