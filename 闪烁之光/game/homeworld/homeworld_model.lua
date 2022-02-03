-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2019-06-04
-- --------------------------------------------------------------------
local _table_insert = table.insert
local _table_remove = table.remove

HomeworldModel = HomeworldModel or BaseClass()

function HomeworldModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function HomeworldModel:config()
	self.my_home_figure_id = 0  -- 当前家园角色形象id
	self.my_home_name = "" 		-- 我的家园名称
	self.home_comfort_val = 0 	-- 当前舒适度
	self.home_worship = 0 		-- 家园被点赞数量
	self.left_worship_num = 0 	-- 剩余点赞次数
	self.acc_hook_time = 0 		-- 家园累计挂机时间（秒）
	self.home_wall_id = 0 		-- 当前墙纸id
	self.home_floor_id = 0 		-- 当前地板id
	self.max_comfort_val = 0    -- 单层楼历史最大舒适度（用于形象解锁、商店物品购买）
	self.max_all_soft_val = 0 	-- 所有楼层总历史最大舒适度
	self.home_furniture_data = {}  -- 家具数据
	self.home_visitors_data = {}   -- 我的家园拜访者角色数据
	self.activate_figure_list = {} -- 当前激活的形象id列表
	self.suit_award_data = {} 	-- 套装奖励数据
	self.cur_storey_index = 1   -- 当前家园层数
	self.max_soft_storey = 1    -- 舒适度最高层数
	self.max_storey_soft = 0 	-- 计算家园币产出的舒适度（舒适度最高层的舒适度）
	self.main_storey_index = 1  -- 家园主居室层数
	self.other_storey_data = {} -- 其他楼层的家具数据（用于仓库显示、商店计算已拥有数量）

	self.is_open_home_flag = 0  -- 是否打开过家园

	self.occupy_grid_list = {}  -- 已被占用的格子
	self.today_worship_data = {} -- 今日点赞过的玩家
	self.random_visiter_data = {} -- 随机拜访的玩家数据

	self.home_red_list = {}
end

-- 退出家园时，清掉一些数据
function HomeworldModel:clearHomeCacheData(  )
	self.home_wall_id = 0 		-- 当前墙纸id
	self.home_floor_id = 0 		-- 当前地板id
	self.home_furniture_data = {}  -- 家具数据
	self.home_visitors_data = {}   -- 我的家园拜访者角色数据
	self.occupy_grid_list = {}  -- 已被占用的格子
	self.today_worship_data = {} -- 今日点赞过的玩家
	self.random_visiter_data = {} -- 随机拜访的玩家数据
end

-- 设置当前家园角色形象id
function HomeworldModel:setMyCurHomeFigureId( id )
	self.my_home_figure_id = id
end

function HomeworldModel:getMyCurHomeFigureId(  )
	return self.my_home_figure_id
end

-- 设置我的家园名称
function HomeworldModel:setMyHomeName( name )
	self.my_home_name = name
end

function HomeworldModel:getMyHomeName(  )
	return self.my_home_name
end

-- 设置当前舒适度
function HomeworldModel:setHomeComfortValue( val )
	self.home_comfort_val = val
end

function HomeworldModel:getHomeComfortValue(  )
	return self.home_comfort_val
end

-- 根据当前舒适度计算家园币每小时的产量
function HomeworldModel:getHomeCoinOutput(  )
	local output_val = 0
	local diff_val
	for k,v in pairs(Config.HomeData.data_home_coin) do
		if self.max_storey_soft >= v.soft then
			if not diff_val or diff_val > (self.max_storey_soft-v.soft) then
				diff_val = self.max_storey_soft-v.soft
				output_val = v.home_coin
			end
		end
	end
	return output_val
end

-- 设置家园被点赞数量
function HomeworldModel:setHomeWorship( worship )
	self.home_worship = worship
end

function HomeworldModel:getHomeWorship(  )
	return self.home_worship
end

-- 设置剩余点赞次数
function HomeworldModel:setLeftWorshipNum( num )
	self.left_worship_num = num
end

function HomeworldModel:getLeftWorshipNum(  )
	return self.left_worship_num
end

-- 设置家园累计挂机时间（秒）
function HomeworldModel:setHomeAccHookTime( time )
	self.acc_hook_time = time

	local red_status = false
	local hook_time_cfg = Config.HomeData.data_const["coin_redpoint_time_condition"]
	if hook_time_cfg and hook_time_cfg.val*3600 <= time then
		red_status = true
	end
	self:updateHomeworldRedStatus(HomeworldConst.Red_Index.Hook, red_status)
end

function HomeworldModel:getHomeAccHookTime(  )
	return self.acc_hook_time
end

-- 家园当前墙纸id
function HomeworldModel:setMyHomeWallId( wall_id )
	self.home_wall_id = wall_id
end

function HomeworldModel:getMyHomeWallId(  )
	return self.home_wall_id
end

-- 家园当前地板id
function HomeworldModel:setMyHomeFloorId( floor_id )
	self.home_floor_id = floor_id
end

function HomeworldModel:getMyHomeFloorId(  )
	return self.home_floor_id
end

-- 我的家园当前层数
function HomeworldModel:setMyHomeCurStoreyIndex( index, max_soft_floor )
	self.cur_storey_index = index
	self.max_soft_storey = max_soft_floor
end

-- 更新最大舒适度层数
function HomeworldModel:updateMaxSoftStoreyIndex( max_soft_floor )
	self.max_soft_storey = max_soft_floor
end

function HomeworldModel:getMyHomeCurStoreyIndex(  )
	return self.cur_storey_index, self.max_soft_storey
end

function HomeworldModel:checkMaxStoreyIsChange( storey )
	if self.max_soft_storey == storey then
		return false
	end
	return true
end

function HomeworldModel:setMyHomeMaxStoreySoft( max_storey_soft )
	self.max_storey_soft = max_storey_soft
end

function HomeworldModel:getMyHomeMaxStoreySoft(  )
	return self.max_storey_soft
end

-- 我的家园主居室层数
function HomeworldModel:setMyHomeMainStoreyIndex( index )
	self.main_storey_index = index
end

function HomeworldModel:getMyhomeMainStoreyIndex(  )
	return self.main_storey_index
end

-- 设置其他楼层的家具数据
function HomeworldModel:setOtherStoreyFurnitureData( data )
	self.other_storey_data = data or {}
end

function HomeworldModel:getOtherStoreyFurnitureData(  )
	return self.other_storey_data
end

-- 设置我的家具数据
function HomeworldModel:setMyHomeFurnitureData( list )
	self.home_furniture_data = {}
	for k,data in pairs(list) do
		local vo = FurnitureVo.New()
		vo:updateData(data)
		_table_insert(self.home_furniture_data, vo)
	end
end

function HomeworldModel:getMyHomeFurnitureData(  )
	return self.home_furniture_data
end

-- 判断是否有家具数据
function HomeworldModel:checkIsHaveFurnitureData(  )
	if next(self.home_furniture_data) == nil then
		return false
	end
	return true
end

-- 获取家具拥有数量（仓库里的数量+房间里的数量）
function HomeworldModel:getFurnitureAllNumByBid( bid )
	-- 背包中的数量
	local bag_num = BackpackController:getInstance():getModel():getItemNumByBid(bid, BackPackConst.Bag_Code.HOME)
	-- 当前楼层中的数量
	local home_num = 0
	if bid == self.home_wall_id or bid == self.home_floor_id then
		home_num = 1
	else
		for k,v in pairs(self.home_furniture_data) do
			if v.bid == bid then
				home_num = home_num + 1
			end
		end
	end
	-- 其他楼层的数量
	local other_storey_num = 0
	for k,v in pairs(self.other_storey_data) do
		if v.bid == bid then
			other_storey_num = v.num or 0
			break
		end
	end

	return (bag_num+home_num+other_storey_num)
end

-- 设置我的家园拜访者数据
function HomeworldModel:setMyHomeVisitorsData( data )
	self.home_visitors_data = data or {}
end

function HomeworldModel:getMyHomeVisitorsData(  )
	return self.home_visitors_data
end

-- 设置单层楼最大舒适度
function HomeworldModel:setMaxComfortValue( val )
	self.max_comfort_val = val

	-- 是否有形象可以解锁
	local red_status = false
	for k,cfg in pairs(Config.HomeData.data_figure) do
		if self:getFigureActiveStatus(cfg.id) == HomeworldConst.Figure_State.CanUnlock then
			red_status = true
			break
		end
	end
	self:updateHomeworldRedStatus(HomeworldConst.Red_Index.Figure, red_status, true)
end

function HomeworldModel:getMaxComfortValue(  )
	return self.max_comfort_val
end

-- 设置所有楼层总历史最高舒适度
function HomeworldModel:setMaxAllSoftValue( val )
	self.max_all_soft_val = val
end

function HomeworldModel:getMaxAllSoftValue(  )
	return self.max_all_soft_val
end

-- 设置已经激活的角色形象id
function HomeworldModel:setActivateFigureList( list, not_check_red )
	self.activate_figure_list = list

	-- 是否有形象可以解锁
	if not not_check_red then -- 从位面那边设置数据，忽略红点相关逻辑
		local red_status = false
		for k,cfg in pairs(Config.HomeData.data_figure) do
			if self:getFigureActiveStatus(cfg.id) == HomeworldConst.Figure_State.CanUnlock then
				red_status = true
				break
			end
		end
		self:updateHomeworldRedStatus(HomeworldConst.Red_Index.Figure, red_status, true)
	end
end

-- 添加已经激活的角色形象id
function HomeworldModel:addFigureIdToActiveList( figure_id )
	local is_have = false
	for k,v in pairs(self.activate_figure_list) do
		if v.id == figure_id then
			is_have = true
			break
		end
	end
	if not is_have then
		_table_insert(self.activate_figure_list, {id = figure_id})
	end
end

-- 根据形象id获取该形象的状态
function HomeworldModel:getFigureActiveStatus( id )
	local figure_cfg = Config.HomeData.data_figure[id]
	if not figure_cfg then return HomeworldConst.Figure_State.Lock end

	local is_have = false
	for k,v in pairs(self.activate_figure_list) do
		if id == v.id then
			is_have = true
			break
		end
	end
	
	if is_have then
		return HomeworldConst.Figure_State.Unlock
	elseif figure_cfg.tips ~=nil and figure_cfg.tips ~= "" then
		return HomeworldConst.Figure_State.Lock
	elseif self.max_comfort_val >= figure_cfg.open_soft then
		return HomeworldConst.Figure_State.CanUnlock
	else
		return HomeworldConst.Figure_State.Lock
	end
end

-- 设置套装奖励数据
function HomeworldModel:setHomeSuitAwardData( data )
	self.suit_award_data = data

	-- 计算一下套装的红点
	local red_status = false
	for _,v in pairs(data) do
		local have_num = #v.collect
		local suit_award_cfg = Config.HomeData.data_suit_award[v.set_id] or {}
		for _,cfg in pairs(suit_award_cfg) do
			if have_num >= cfg.num then
				local is_have = false
				for _,rData in pairs(v.reward) do
					if rData.id == cfg.id then
						is_have = true
						break
					end
				end
				if not is_have then
					red_status = true
				end
			end
			if red_status == true then
				break
			end
		end
		if red_status == true then
			break
		end
	end
	self:updateHomeworldRedStatus(HomeworldConst.Red_Index.Suit, red_status)
end

-- 根据套装id、奖励id获取该套装是否有奖励可领取
function HomeworldModel:checkSuitAwardRedStatus( set_id, award_id )
	if not set_id then return false end

	local red_status = false
	for _,v in pairs(self.suit_award_data) do
		if v.set_id == set_id then
			local have_num = #v.collect
			local suit_award_cfg = Config.HomeData.data_suit_award[set_id] or {}
			for _,cfg in pairs(suit_award_cfg) do
				if have_num >= cfg.num and (not award_id or award_id == cfg.id) then
					local is_have = false
					for _,rData in pairs(v.reward) do
						if rData.id == cfg.id then
							is_have = true
							break
						end
					end
					if not is_have then
						red_status = true
					end
				end
				if red_status then
					break
				end
			end
			break
		end
	end

	return red_status
end

-- 根据套装奖励id获取奖励数据
function HomeworldModel:getHomeSuitAwardDataById( set_id )
	for k,data in pairs(self.suit_award_data) do
		if data.set_id == set_id then
			return data
		end
	end
end

function HomeworldModel:checkIsHaveSuitAwardData(  )
	if self.suit_award_data and next(self.suit_award_data) ~= nil then
		return true
	end
	return false
end

-- 获取格子可走类型
function HomeworldModel:checkGridWalkType( grid_x, grid_y )
	if not self.walk_cfg then
		self.walk_cfg = Config.MapBlock.data(HomeworldConst.Map_Id)
	end
	if self.walk_cfg and self.walk_cfg[grid_y] and self.walk_cfg[grid_y][grid_x] then
		return self.walk_cfg[grid_y][grid_x]
	end
	return 0
end

-- 根据格子坐标和类型判断格子是否能用
function HomeworldModel:checkGridIsCanWalk( grid_x, grid_y, grid_type, grid_list )
	local walk_type = self:checkGridWalkType(grid_x, grid_y)
	if walk_type == grid_type then
		local is_can = true
		grid_list = grid_list or self.occupy_grid_list
		for k,v in pairs(grid_list) do
			if v[1] == grid_x and v[2] == grid_y then
				is_can = false
				break
			end
		end
		return is_can
	end
	return false
end

-- 暂存一下不可用的格子数据
function HomeworldModel:updateOccupyGridList( grid_list )
	self.occupy_grid_list = grid_list or {}
end

function HomeworldModel:setHomeFirstOpenFlag( flag )
	self.is_open_home_flag = flag
end

-- 是否为第一次打开家园
function HomeworldModel:getIsFirstTimeOpenHome(  )
	if self.is_open_home_flag == 1 then
		return false
	end
	return true
end

-- 家园功能是否开启
function HomeworldModel:checkHomeworldIsOpen( not_tips )
	local is_open = false
	local role_vo = RoleController:getInstance():getRoleVo()
	local open_lv_cfg = Config.HomeData.data_const["open_lev"]
	if open_lv_cfg and role_vo and open_lv_cfg.val <= role_vo.lev then
		is_open = true
	end
	if is_open == false and not not_tips and open_lv_cfg then
		message(open_lv_cfg.desc)
	end
	return is_open
end

-- 设置今日点赞过的玩家信息
function HomeworldModel:setTodayWorshipPlayerData( data )
	self.today_worship_data = data
end

function HomeworldModel:checkIsHaveTodayWorshipData(  )
	if self.today_worship_data and next(self.today_worship_data) ~= nil then
		return true
	end
	return false
end

function HomeworldModel:addPlayerToWorshipData( rid, srv_id )
	local is_have = false
	for k,v in pairs(self.today_worship_data) do
		if v.rid == rid and v.srv_id == srv_id then
			is_have = true
			break
		end
	end
	if not is_have then
		_table_insert(self.today_worship_data, {rid=rid, srv_id=srv_id})
	end
end

-- 根据 rid, srv_id 判断该玩家今日是否被点赞过
function HomeworldModel:checkPlayerTodayIsWorship( rid, srv_id )
	local is_worship = 0
	for k,v in pairs(self.today_worship_data) do
		if v.rid == rid and v.srv_id == srv_id then
			is_worship = 1
			break
		end
	end
	return is_worship
end

-- 设置随机拜访的玩家数据
function HomeworldModel:setRandomVisiterData( data )
	self.random_visiter_data = data or {}
end

-- 获取下一位的玩家列表(按照未点赞>好友的顺序排序) rid, srv_id:当前家园的玩家，固定排在第一位
function HomeworldModel:getNextPlayerList( rid, srv_id )
	local palyer_list = {}

	-- 好友
	local friend_data = FriendController:getInstance():getModel():getOpenHomeFriendList()
	for _,friend_vo in pairs(friend_data) do
		local n_data = {}
		n_data.rid = friend_vo.rid
		n_data.srv_id = friend_vo.srv_id
		n_data.is_friend = 1
		n_data.is_worship = self:checkPlayerTodayIsWorship(friend_vo.rid, friend_vo.srv_id)
		if friend_vo.rid == rid and friend_vo.srv_id == srv_id then
			n_data.is_first = 1
		else
			n_data.is_first = 0
		end
		_table_insert(palyer_list, n_data)
	end

	-- 添加一个非好友数据
	local function checkAddPlayerToList( p_rid, p_srv_id )
		local is_have = false
		for k,n_data in pairs(palyer_list) do
			if n_data.rid == p_rid and n_data.srv_id == p_srv_id then
				is_have = true
				break
			end
		end
		if not is_have then
			local n_data = {}
			n_data.rid = p_rid
			n_data.srv_id = p_srv_id
			n_data.is_friend = 0
			n_data.is_worship = self:checkPlayerTodayIsWorship(p_rid, p_srv_id)
			if p_rid == rid and p_srv_id == srv_id then
				n_data.is_first = 1
			else
				n_data.is_first = 0
			end
			_table_insert(palyer_list, n_data)
		end
	end

	-- 随机拜访的玩家
	for _,v in pairs(self.random_visiter_data) do
		checkAddPlayerToList(v.rid, v.srv_id)
	end

	checkAddPlayerToList(rid, srv_id)

	local function sortFunc( objA, objB )
		if objA.is_first ~= objB.is_first then
			return objA.is_first > objB.is_first
		elseif objA.is_friend ~= objB.is_friend then
			return objA.is_friend > objB.is_friend
		else
			return objA.is_worship < objB.is_worship
		end
	end
	table.sort( palyer_list, sortFunc )
	return palyer_list
end

-- 红点相关 just_home:是否仅在家园中显示红点
function HomeworldModel:updateHomeworldRedStatus( bid, status, just_home )
    local _status = self.home_red_list[bid]

    self.home_red_list[bid] = status

    if not just_home then
    	MainSceneController:getInstance():setBuildRedStatus(CenterSceneBuild.home, {bid = bid, status = status})
    end
    GlobalEvent:getInstance():Fire(HomeworldEvent.Update_Red_Status_Data, bid, status)
end

function HomeworldModel:checkHomeworldRedStatus(  )
	local status = false
	for k,v in pairs(self.home_red_list) do
		if v == true then
			status = true
			break
		end
	end
	return status
end

function HomeworldModel:getRedStatusById( bid )
	local status = false
	for id,v in pairs(self.home_red_list) do
		if id == bid then
			status = v
			break
		end
	end
	return status
end

function HomeworldModel:__delete()
end