-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2019-04-10
-- --------------------------------------------------------------------
local _table_insert = table.insert

HeavenModel = HeavenModel or BaseClass()

function HeavenModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function HeavenModel:config()
	self.left_challenge_count = 0  -- 剩余挑战次数
	self.today_buy_count = 0	   -- 今日购买次数
	self.chapter_list = {} 		   -- 章节数据
	self.customs_list = {} 		   -- 关卡数据
	self.max_pass_chapter_id = 0   -- 最大通关（普通通关）章节id
	self.max_dun_id = 0 		   -- 最大通关关卡的配置副本id

	self.dial_data = {} 		   -- 神装转盘相关数据
	self.myself_record_data = {}   -- 玩家自己的抽奖记录
	self.all_record_data = {} 	   -- 全服抽奖记录
 
	self.heaven_red_list = {}

	self.all_score = 0 --战力前五神装总评分
end

function HeavenModel:clearData(  )
	self:config()
end

-- 设置剩余挑战次数
function HeavenModel:setLeftChallengeCount( count )
	self.left_challenge_count = count or 0
	self:checkHeavenRedStatus()
end
-- 获取剩余挑战次数
function HeavenModel:getLeftChallengeCount(  )
	return self.left_challenge_count
end

-- 设置今日购买次数
function HeavenModel:setTodayBuyCount( count )
	self.today_buy_count = count or 0
end
-- 获取今日购买次数
function HeavenModel:getTodayBuyCount(  )
	return self.today_buy_count
end
-- 获取今日剩余购买次数
function HeavenModel:getTodayLeftBuyCount(  )
	local max_count = Config.DungeonHeavenData.data_count_buy_length or 0
	local left_count = max_count - self.today_buy_count
	if left_count < 0 then left_count = 0 end
	return left_count
end

-- 设置最大通关关卡副本id
function HeavenModel:setMaxDunId( dun_id )
	if not self.max_dun_id or self.max_dun_id < dun_id then
		self.max_dun_id = dun_id
	end
end

function HeavenModel:getMaxDunId(  )
	return self.max_dun_id
end

-- 设置章节数据
function HeavenModel:setChapterData( data )
	self.chapter_list = {}
	for k,cData in pairs(data) do
		local chapter_vo = HeavenChapterVo.New()
		chapter_vo:updateData(cData)
		_table_insert(self.chapter_list, chapter_vo)
	end
	self:updateMaxPassChapterId()
	self:checkHeavenRedStatus()
end

-- 更新章节数据
function HeavenModel:updateChapterData( data )
	local is_add = false
	for _,cData in pairs(data) do
		local is_have = false
		for _,chapter_vo in pairs(self.chapter_list) do
			if chapter_vo.id == cData.id then
				is_have = true
				chapter_vo:updateData(cData)
			end
		end
		if not is_have then -- 新增
			is_add = true
			local chapter_vo = HeavenChapterVo.New()
			chapter_vo:updateData(cData)
			_table_insert(self.chapter_list, chapter_vo)
		end
	end
	self:updateMaxPassChapterId()
	self:checkHeavenRedStatus()
	if is_add then
		GlobalEvent:getInstance():Fire(HeavenEvent.Add_Chapter_Data_Event)
	end
end

-- 更新某一章节数据
function HeavenModel:updateOneChapterDataById( id, data )
	for _,chapter_vo in pairs(self.chapter_list) do
		if chapter_vo.id == id then
			chapter_vo:updateData(data)
			break
		end
	end
	self:updateMaxPassChapterId()
	self:checkHeavenRedStatus()
end

-- 是否有章节数据缓存
function HeavenModel:checkIsHaveChapterCache(  )
	if self.chapter_list and next(self.chapter_list) ~= nil then
		return true
	else
		return false
	end
end

-- 更新最大通关章节id
function HeavenModel:updateMaxPassChapterId(  )
	for _,chapter_vo in pairs(self.chapter_list) do
		if chapter_vo.is_finish ~= HeavenConst.Chapter_Pass_Status.NotPass and chapter_vo.id > self.max_pass_chapter_id then
			self.max_pass_chapter_id = chapter_vo.id
		end
	end
end

-- 获取某一章节的通关状态 HeavenConst.Chapter_Pass_Status
function HeavenModel:getChapterPassStatus( chapter_id )
	local pass_status = HeavenConst.Chapter_Pass_Status.NotPass
	for _,chapter_vo in pairs(self.chapter_list) do
		if chapter_vo.id == chapter_id then
			pass_status = chapter_vo.is_finish
		end
	end
	return pass_status
end

-- 根据章节id和星级奖励id获取奖励状态
function HeavenModel:getChapterStarAwardStatus( chapter_id, award_id )
	local award_status = 0
	local chapter_vo = self:getChapterDataById(chapter_id)
	if chapter_vo then
		for k,v in pairs(chapter_vo.award_info) do
			if v.id == award_id then
				award_status = v.flag
				break
			end
		end
	end
	return award_status
end

-- 获取最大通关章节id
function HeavenModel:getMaxPassChapterId(  )
	return self.max_pass_chapter_id
end

-- 获取当前开启的最大章节id
function HeavenModel:getOpenMaxChapterId(  )
	local chapter_id = 0
	for k,chapter_vo in pairs(self.chapter_list) do
		if chapter_id < chapter_vo.id then
			chapter_id = chapter_vo.id
		end
	end
	return chapter_id
end

-- 根据章节id获取章节数据
function HeavenModel:getChapterDataById( id )
	for _,chapter_vo in pairs(self.chapter_list) do
		if chapter_vo.id == id then
			return chapter_vo
		end
	end
end

-- 根据章节id判断该章节是否开启
function HeavenModel:checkHeavenChapterIsOpen( chapter_id )
	local config_data = Config.DungeonHeavenData.data_chapter[chapter_id]
	if not config_data then return false end

	local is_open = true
	local close_msg = ""
	-- 先判断上一章节是否通关
	if chapter_id > 1 then
		local pre_pass_status = self:getChapterPassStatus(chapter_id - 1)
		if pre_pass_status == HeavenConst.Chapter_Pass_Status.NotPass then
			is_open = false
			close_msg = TI18N("通关上一章")
		end
	end
	for k,cond in pairs(config_data.cond_info) do
		local chap_id = cond[1]
		local star = cond[2]
		local chap_vo = self:getChapterDataById(chap_id)
		if not chap_vo or chap_vo.all_star < star then
			is_open = false
			if close_msg == "" then
				close_msg = string.format(TI18N("第%d章完成%d个星级目标"), chap_id, star)
			else
				close_msg = close_msg .. string.format(TI18N("，且第%d章完成%d个星级目标"), chap_id, star)
			end
			break
		end
	end
	close_msg = close_msg .. TI18N("开启")
	return is_open, close_msg
end

-- 设置关卡数据
function HeavenModel:setCustomsData( data, chapter_id )
	self:updateCustomsData(data, chapter_id)
end

-- 更新关卡数据
function HeavenModel:updateCustomsData( data, chapter_id )
	for _,cData in pairs(data) do
		cData.chapter_id = chapter_id
		local is_have = false
		for _,customs_vo in pairs(self.customs_list) do
			if customs_vo.id == cData.id and customs_vo.chapter_id == chapter_id then
				is_have = true
				customs_vo:updateData(cData)
			end
		end
		if not is_have then -- 新增
			local customs_vo = HeavenCustomsVo.New()
			customs_vo:updateData(cData)
			_table_insert(self.customs_list, customs_vo)
		end
	end
end

-- 根据章节id判断是否有关卡数据
function HeavenModel:checkIsHaveCustomsCache( chapter_id )
	local is_have = false
	if self.customs_list then
		local customs_num = 0
		for _,customs_vo in pairs(self.customs_list) do
			if customs_vo.chapter_id == chapter_id then
				customs_num = customs_num + 1
			end
		end
		if Config.DungeonHeavenData.data_customs_num[chapter_id] == customs_num then
			is_have = true
		end
	end
	return is_have
end

-- 根据章节id获取该章节所有可以显示关卡数据(乱序)
function HeavenModel:getAllCanShowCustomsDataById( chapter_id )
	local all_customs = {}
	for k,customs_vo in pairs(self.customs_list) do
		if customs_vo.chapter_id == chapter_id and customs_vo.state ~= 0 then
			_table_insert(all_customs, customs_vo)
		end
	end
	return all_customs
end

-- 根据章节id和关卡id获取关卡数据
function HeavenModel:getCustomsDataById( chapter_id, customes_id )
	for _,customs_vo in pairs(self.customs_list) do
		if customs_vo.id == customes_id and customs_vo.chapter_id == chapter_id then
			return customs_vo
		end
	end
end

-- 根据章节id和关卡id获取是否为boss关
function HeavenModel:getCustomsIsBossType( chapter_id, customes_id )
	local is_boss = false
	local chapter_cfg = Config.DungeonHeavenData.data_customs[chapter_id]
	if chapter_cfg and chapter_cfg[customes_id] then
		is_boss = (chapter_cfg[customes_id].type == 1)
	end
	return is_boss
end

-- 根据关卡配置表唯一id判断该关卡是否通关
function HeavenModel:checkCustomsIsPassByDunId( dun_id )
	local is_pass = false
	if dun_id <= self.max_dun_id then
		is_pass = true
	end
	return is_pass
end

-- 根据章节id获取该章节最大星数
function HeavenModel:getChapterMaxStarNum( chapter_id )
	local max_star_num = 0
	if Config.DungeonHeavenData.data_customs_num[chapter_id] then
		max_star_num = Config.DungeonHeavenData.data_customs_num[chapter_id] * 3
	end
	return max_star_num
end

-- 缓存最后一次打开的章节id
function HeavenModel:setHeavenLastShowChapterId( chapter_id )
	self.last_show_chapter_id = chapter_id
end

function HeavenModel:getHeavenLastShowChapterId(  )
	return self.last_show_chapter_id
end

-- 天界副本开启判断
function HeavenModel:checkHeavenIsOpen( not_tips )
	local role_vo = RoleController:getInstance():getRoleVo()
	if role_vo == nil then 
		return false 
	end
	local is_open = false
	local world_lev_cfg = Config.DungeonHeavenData.data_const["open_world_lev"]
	local role_lev_cfg = Config.DungeonHeavenData.data_const["open_lev"]
	local open_lev_second_cfg = Config.DungeonHeavenData.data_const["open_lev_second"]
	local msg = ""
	if world_lev_cfg and role_lev_cfg then
		local world_lv = RoleController:getInstance():getModel():getWorldLev()
		is_open = true
		if world_lev_cfg.val > world_lv then
			is_open = false
			msg = world_lev_cfg.desc
		elseif role_lev_cfg.val > role_vo.lev then
			is_open = false
			msg = role_lev_cfg.desc
		end
	end
	-- 条件二（与条件一为或的关系）
	if not is_open and open_lev_second_cfg then
		is_open = true
		if open_lev_second_cfg.val > role_vo.lev then
			is_open = false
			msg = open_lev_second_cfg.desc
		end
	end
	if not is_open and not not_tips then
		message(msg)
	end
	return is_open
end

-- 神装转盘是否开启
function HeavenModel:checkHeavenDialIsOpen( not_tips )
	local is_open = false
	local world_lev_cfg = Config.HolyEqmLotteryData.data_const["world_lev_condition"]
	local role_lev_cfg = Config.HolyEqmLotteryData.data_const["player_lev_condition"]
	local second_condition_cfg = Config.HolyEqmLotteryData.data_const["player_lev_second_condition"]
	local dun_id_cfg = Config.HolyEqmLotteryData.data_const["heaven_dun_condition"]
	if world_lev_cfg and role_lev_cfg and dun_id_cfg then
		local world_lv = RoleController:getInstance():getModel():getWorldLev()
		local role_vo = RoleController:getInstance():getRoleVo()
		is_open = true
		local msg = ""
		if world_lev_cfg.val > world_lv then
			is_open = false
			msg = world_lev_cfg.desc
		elseif role_lev_cfg.val > role_vo.lev then
			is_open = false
			msg = role_lev_cfg.desc
		end
		-- 条件二（与条件一为或的关系）
		if not is_open and second_condition_cfg then
			is_open = true
			if second_condition_cfg.val > role_vo.lev then
				is_open = false
				msg = second_condition_cfg.desc
			end
		end
		-- if is_open and not self:checkCustomsIsPassByDunId(dun_id_cfg.val) then
		-- 	is_open = false
		-- 	msg = dun_id_cfg.desc
		-- end
		if not is_open and not not_tips then
			message(msg)
		end
	end
	return is_open
end

-- 设置神装转盘相关数据
function HeavenModel:setHeavenDailData( data )
	self.dial_data = data or {}
	self:checkHeavenRedStatus()
end

-- 根据神装转盘的组id获取是否有免费次数
function HeavenModel:getHeavenDialIsFreeById( group_id )
	local is_free = false
	for k,v in pairs(self.dial_data) do
		if v.group_id == group_id then
			if v.free_times >= 1 then
				is_free = true
			end
			break
		end
	end
	return is_free
end

-- 根据组id判断该石像是否开启
function HeavenModel:checkHeavenDialIsOpenByGId( group_id )
	local is_open = false
	for k,v in pairs(self.dial_data) do
		if v.group_id == group_id and v.is_open == 1 then
			is_open = true
			break
		end
	end
	
	return is_open
end

-- 根据神装转盘的组id获取是否有奖励可领取
function HeavenModel:getHeavenDialAwardRedById( group_id )
	local is_free = false
	for k,v in pairs(self.dial_data) do
		if v.group_id == group_id then
			local award_config = Config.HolyEqmLotteryData.data_award[v.group_id]
			if award_config then
				for i,j in pairs(award_config) do
					local _un_enabled = false
					for l,m in pairs(v.do_awards) do
						if j.id == m.award_id then
							_un_enabled = true
							break
						end
					end

					if _un_enabled == false and j.times <= v.all_award_count then
						return true
					end	
				end
			end
		end
	end
	return is_free
end

-- 获取神装组id数据
function HeavenModel:getHeavenDialById( group_id )
	for k,v in pairs(self.dial_data) do
		if v.group_id == group_id then
			return v
		end
	end
	return nil
end


-- 根据神装转盘的组id获取再抽X次触发保底
function HeavenModel:getHeavenDialBaodiCountById( group_id )
	local count = 0
	for k,v in pairs(self.dial_data) do
		if v.group_id == group_id then
			count = v.baodi_count or 0
			break
		end
	end
	return count
end

-- 玩家自己的抽奖记录
function HeavenModel:setMyselfDialRecordData( data )
	self.myself_record_data = data or {}
end

function HeavenModel:getMyselfDialRecordData(  )
	return self.myself_record_data
end

-- 全服抽奖记录
function HeavenModel:setAllDialRecordData( data, group_id )
	self.all_record_data[group_id] = data
end

function HeavenModel:getAllDialRecordData( group_id )
	return self.all_record_data[group_id] or {}
end

-- 根据组id判断本地是否有缓存全服记录数据
function HeavenModel:checkIsHaveDialRecordData( group_id )
	if self.all_record_data[group_id] and next(self.all_record_data[group_id]) ~= nil then
		return true
	end
	return false
end

---------------- 红点相关
function HeavenModel:updateHeavenRedStatus( bid, status )
	self.heaven_red_list[bid] = status

	local red_status = self:getHeavenRedStatus()
    MainSceneController:getInstance():setBuildRedStatus(CenterSceneBuild.adventure, {bid = AdventureActivityConst.Red_Type.heaven, status = red_status})
    GlobalEvent:getInstance():Fire(HeavenEvent.Update_Heaven_Red_Status, bid, status)
end

function HeavenModel:getHeavenRedStatus(  )
	local red_status = false
	for k,status in pairs(self.heaven_red_list) do
		if status == true then
			red_status = true
			break
		end
	end
	return red_status
end

function HeavenModel:getHeavenRedStatusByBid( bid )
	local red_status = false
	for k,status in pairs(self.heaven_red_list) do
		if bid == k then
			red_status = status
			break
		end
	end
	return red_status
end

function HeavenModel:checkHeavenRedStatus(  )
	if not self:checkHeavenIsOpen(true) then return end

	-- 剩余挑战次数
	local count_red_status = false
	if self.left_challenge_count > 0 then
		count_red_status = true
	end
	self:updateHeavenRedStatus(HeavenConst.Red_Index.Count, count_red_status)

	-- 章节奖励
	local award_red_status = false
	for k,chapter_vo in pairs(self.chapter_list) do
		if chapter_vo:getRedStatus() == true then
			award_red_status = true
			break
		end
	end
	self:updateHeavenRedStatus(HeavenConst.Red_Index.Award, award_red_status)

	-- 神装转盘免费次数
	local dial_red_status = false
	if self:checkHeavenDialIsOpen(true) then
		for k,v in pairs(self.dial_data) do
			local group_cfg = Config.HolyEqmLotteryData.data_group[v.group_id]
			if v.free_times >= 1 and group_cfg and self:checkHeavenDialIsOpenByGId(v.group_id) then
				dial_red_status = true
				break
			end
		end
	end
	self:updateHeavenRedStatus(HeavenConst.Red_Index.Dial, dial_red_status)

	local dial_award_red_status = false
	if self:checkHeavenDialIsOpen(true) then
		for k,v in pairs(self.dial_data) do
			local award_config = Config.HolyEqmLotteryData.data_award[v.group_id]
			if award_config then
				for i,j in pairs(award_config) do
					local _un_enabled = false
					for l,m in pairs(v.do_awards) do
						if j.id == m.award_id then
							_un_enabled = true
							break
						end
					end

					if _un_enabled == false and j.times <= v.all_award_count then
						dial_award_red_status = true
						break
					end	
				end
			end
			if dial_award_red_status == true then
				break
			end
		end
	end
	self:updateHeavenRedStatus(HeavenConst.Red_Index.DialAward, dial_award_red_status)
end

function HeavenModel:setAllScore( score )
	self.all_score = score
	GlobalEvent:getInstance():Fire(HeavenEvent.Update_All_Score)
end

function HeavenModel:getAllScore( )
	return self.all_score
end

-- 根据关卡配置表唯一id判断该关卡是否通关
function HeavenModel:checkIsOpenByScore( score )
	local is_open = false
	if score <= self.all_score then
		is_open = true
	end
	return is_open
end

function HeavenModel:__delete()
end