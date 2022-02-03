-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-11-01
-- --------------------------------------------------------------------
LadderController = LadderController or BaseClass(BaseController)

function LadderController:config()
    self.model = LadderModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function LadderController:getModel()
    return self.model
end

function LadderController:registerEvents()
	--[[if self.init_role_event == nil then
        self.init_role_event = GlobalEvent:getInstance():Bind(EventId.ROLE_CREATE_SUCCESS, function()
            GlobalEvent:getInstance():UnBind(self.init_role_event)
            self.init_role_event = nil

            -- 上线时请求
            self:requestLadderIsOpen()
        end)
    end--]]
end

-----------------------------@ c2s
-- 请求天梯个人信息
function LadderController:requestLadderMyBaseInfo(  )
	self:SendProtocal(24300, {})
end

-- 请求挑战列表
function LadderController:requestLadderEnemyListData(  )
	self:SendProtocal(24301, {})
end

-- 请求玩家信息
function LadderController:requestLadderEnemyData( rid, srv_id )
	local protocal = {}
    protocal.rid = rid
    protocal.srv_id = srv_id
    self:SendProtocal(24302, protocal)
end

-- 请求挑战玩家
function LadderController:requestChallengeEnemy( rid, srv_id )
	local protocal = {}
    protocal.rid = rid
    protocal.srv_id = srv_id
    self:SendProtocal(24303, protocal)
end

-- 请求刷新对手列表
function LadderController:requestRefreshEnemyList(  )
	self:SendProtocal(24304, {})
end

-- 请求购买挑战次数
function LadderController:requestBuyChallengeCount(  )
	self:SendProtocal(24305, {})
end

-- 请求一键挑战
function LadderController:requestQuickChallenge(  )
	self:SendProtocal(24306, {})
end

-- 请求前三名玩家数据（英雄殿）
function LadderController:requestTopThreeRoleData(  )
	self:SendProtocal(24308, {})
end

-- 请求排行榜信息
function LadderController:requestLadderRankData(  )
	self:SendProtocal(24309, {})
end

-- 请求日志记录
function LadderController:requestMyLogData(  )
	self:SendProtocal(24310, {})
end

-- 请求大神风采
function LadderController:requestGodLogData(  )
	self:SendProtocal(24311, {})
end

-- 请求天梯是否开启
function LadderController:requestLadderIsOpen(  )
	self:SendProtocal(24312, {})
end

-- 请求清除冷却时间
function LadderController:requestCleanCDTime(  )
	self:SendProtocal(24315, {})
end

-- 请求查看英雄信息
function LadderController:requestCheckRoleInfo( rid, srv_id, pos )
	local protocal = {}
    protocal.rid = rid
    protocal.srv_id = srv_id
    protocal.pos = pos
    self:SendProtocal(24316, protocal)
end

-- 请求天梯录像分享
function LadderController:requestShareVideo( replay_id, srv_id, channel, target_name )
	local protocal = {}
    protocal.replay_id = replay_id
    protocal.srv_id = srv_id
    protocal.channel = channel
    protocal.target_name = target_name
    self:SendProtocal(24318, protocal)
end

----------------------------@ s2c
function LadderController:registerProtocals()
	self:RegisterProtocal(24300, "handle24300")     -- 个人数据
	self:RegisterProtocal(24301, "handle24301")     -- 挑战对手列表
	self:RegisterProtocal(24302, "handle24302")     -- 对手数据
	self:RegisterProtocal(24303, "handle24303")     -- 挑战对手
	self:RegisterProtocal(24304, "handle24304")     -- 刷新对手
	self:RegisterProtocal(24305, "handle24305")     -- 购买挑战次数
	self:RegisterProtocal(24306, "handle24306")     -- 一键挑战
	self:RegisterProtocal(24307, "handle24307")     -- 挑战结算
	self:RegisterProtocal(24308, "handle24308")     -- 前三名玩家数据
	self:RegisterProtocal(24309, "handle24309")     -- 排行榜数据
	self:RegisterProtocal(24310, "handle24310")     -- 我的记录
	self:RegisterProtocal(24311, "handle24311")     -- 大神风采
	self:RegisterProtocal(24312, "handle24312")     -- 天梯是否开启
	self:RegisterProtocal(24313, "handle24313")     -- 英雄殿红点
	self:RegisterProtocal(24314, "handle24314")     -- 战报红点
	self:RegisterProtocal(24315, "handle24315")     -- 清除cd时间
	self:RegisterProtocal(24316, "handle24316")     -- 查看英雄信息
	self:RegisterProtocal(24317, "handle24317")     -- 挑战次数红点
	self:RegisterProtocal(24318, "handle24318")     -- 录像分享
end

-- 个人数据
function LadderController:handle24300( data )
	if data then
		self.model:setLadderMyBaseInfo(data)
	end
	GlobalEvent:getInstance():Fire(LadderEvent.UpdateLadderMyBaseInfo)
end

-- 挑战对手列表
function LadderController:handle24301( data )
	if data then
		if data.type == 0 then -- 全部更新
			self.model:setLadderEnemyListData(data.f_list)
		else -- 部分更新
			self.model:updateLadderEnemyListData(data.f_list)
		end
		GlobalEvent:getInstance():Fire(LadderEvent.UpdateAllLadderEnemyList)
	end
end

-- 对手数据
function LadderController:handle24302( data )
	if data then
		GlobalEvent:getInstance():Fire(LadderEvent.GetLadderEnemyData, data)
	end
end

-- 挑战对手
function LadderController:handle24303( data )
	message(data.msg)
    self:openLadderRoleInfoWindow(false)
end

-- 刷新对手
function LadderController:handle24304( data )
	message(data.msg)
end

-- 购买挑战次数
function LadderController:handle24305( data )
	message(data.msg)
	if data.code == 1 and self._temp_rid and self._temp_srv_id then
		self:requestChallengeEnemy(self._temp_rid, self._temp_srv_id)
		self._temp_rid = nil
		self._temp_srv_id = nil
	elseif data.code == 1 and self._temp_quick_flag then
		self:requestQuickChallenge()
		self._temp_quick_flag = nil
	end
end

-- 一键挑战
function LadderController:handle24306( data )
	message(data.msg)
end

-- 挑战结算
function LadderController:handle24307( data )
	BattleController:getInstance():openFinishView(true, BattleConst.Fight_Type.LadderWar, data)
end

-- 前三名数据
function LadderController:handle24308( data )
	if data and data.rank_list then
		GlobalEvent:getInstance():Fire(LadderEvent.UpdateLadderTopThreeRoleData, data.rank_list)
	end
end

-- 排行榜数据
function LadderController:handle24309( data )
	if data then
		GlobalEvent:getInstance():Fire(LadderEvent.UpdateLadderRankData, data)
	end
end

-- 我的记录
function LadderController:handle24310( data )
	if data then
		GlobalEvent:getInstance():Fire(LadderEvent.UpdateLadderMyLogData, data)
	end
end

-- 大神风采
function LadderController:handle24311( data )
	if data then
		GlobalEvent:getInstance():Fire(LadderEvent.UpdateLadderGodLogData, data)
	end
end

-- 天梯是否开启
function LadderController:handle24312( data )
	if data then
		self.model:setLadderOpenStatus(data.code)
		GlobalEvent:getInstance():Fire(LadderEvent.UpdateLadderOpenStatus)
	end
end

-- 英雄殿红点
function LadderController:handle24313( data )
	if data.code then
		if not self._login_flag and data.code == 1 then
			self._login_flag = true
			self.model:updateLadderRedStatus(LadderConst.RedType.TopThree, true)
		else
			self.model:updateLadderRedStatus(LadderConst.RedType.TopThree, false)
		end
	end
end

-- 英雄殿红点
function LadderController:handle24314( data )
	if data.code then
		self.model:updateLadderRedStatus(LadderConst.RedType.BattleLog, data.code==1)
	end
end

-- 清除cd时间
function LadderController:handle24315( data )
	message(data.msg)
end

-- 查看英雄
function LadderController:handle24316( data )
	message(data.msg)
end

-- 挑战次数红点
function LadderController:handle24317( data )
	if data.code then
		self.model:updateLadderRedStatus(LadderConst.RedType.Challenge, data.code==1)
	end
end

-- 录像分享
function LadderController:handle24318( data )
	message(data.msg)
end

-- 检测挑战次数并且进入战斗
function LadderController:checkJoinLadderBattle( rid, srv_id, is_quick )
	if self.model:getLeftChallengeCount() > 0 then
		if is_quick then
			self:requestQuickChallenge()
		else
			self:requestChallengeEnemy(rid, srv_id)
		end
	elseif self.model:getTodayLeftBuyCount() > 0 then
		local buy_combat_num = self.model:getTodayBuyCount()
		local cost_config = Config.SkyLadderData.data_buy_num[buy_combat_num+1]
		if cost_config then
			if is_quick then
				local str = string.format(TI18N("挑战次数不足，是否消耗<img src=%s visible=true scale=0.3 />%d购买一次挑战次数并且进行一键挑战？"), PathTool.getItemRes(3), cost_config.cost)				
				CommonAlert.show( str, TI18N("确定"), function()
					self._temp_quick_flag = true
					self:requestBuyChallengeCount()
		    	end, TI18N("取消"), nil, CommonAlert.type.rich)
			else
				local str = string.format(TI18N("挑战次数不足，是否消耗<img src=%s visible=true scale=0.3 />%d购买一次挑战次数并且进入战斗？"), PathTool.getItemRes(3), cost_config.cost)				
				CommonAlert.show( str, TI18N("确定"), function()
					-- 缓存布阵数据，购买次数成功返回后直接进入战斗
					self._temp_rid = rid
					self._temp_srv_id = srv_id
					self:requestBuyChallengeCount()
					self:openLadderRoleInfoWindow(false)
		    	end, TI18N("取消"), nil, CommonAlert.type.rich)
			end
		end
	else
		message(TI18N("挑战次数不足"))
		self:openLadderRoleInfoWindow(false)
	end
end

----------------------@ 打开界面
-- 天梯主界面
function LadderController:openMainWindow( status )
	if status then
		local role_vo = RoleController:getInstance():getRoleVo()
		local config = Config.SkyLadderData.data_const.join_min_lev
		if role_vo.lev < config.val then
	        message(config.desc)
	        return 
	    end

		if self.ladder_main_window == nil then
			self.ladder_main_window = LadderMainWindow.New()
		end
		self.ladder_main_window:open()
	else
		if self.ladder_main_window then
			self.ladder_main_window:close()
			self.ladder_main_window = nil
		end
	end
end

-- 天梯商店
function LadderController:openLadderShopWindow( status )
	if status then
		if self.ladder_shop_window == nil then
			self.ladder_shop_window = LadderShopWindow.New()
		end
		self.ladder_shop_window:open()
	else
		if self.ladder_shop_window then
			self.ladder_shop_window:close()
			self.ladder_shop_window = nil
		end
	end
end

-- 天梯对手信息
function LadderController:openLadderRoleInfoWindow( status, data )
	if status then
		if self.ladder_role_info_window == nil then
			self.ladder_role_info_window = LadderRoleInfoWindow.New()
		end
		self.ladder_role_info_window:open(data)
	else
		if self.ladder_role_info_window then
			self.ladder_role_info_window:close()
			self.ladder_role_info_window = nil
		end
	end
end

-- 天梯战报
function LadderController:openLadderLogWindow( status )
	if status then
		if self.ladder_log_window == nil then
			self.ladder_log_window = LadderLogWindow.New()
		end
		self.ladder_log_window:open()
	else
		if self.ladder_log_window then
			self.ladder_log_window:close()
			self.ladder_log_window = nil
		end
	end
end

-- 天梯奖励
function LadderController:openLadderAwardWindow( status )
	if status then
		if self.ladder_award_window == nil then
			self.ladder_award_window = LadderAwardWindow.New()
		end
		self.ladder_award_window:open()
	else
		if self.ladder_award_window then
			self.ladder_award_window:close()
			self.ladder_award_window = nil
		end
	end
end

-- 天梯排行榜
function LadderController:openLadderRankWindow( status )
	if status then
		if self.ladder_rank_window == nil then
			self.ladder_rank_window = LadderRankWindow.New()
		end
		self.ladder_rank_window:open()
	else
		if self.ladder_rank_window then
			self.ladder_rank_window:close()
			self.ladder_rank_window = nil
		end
	end
end

-- 天梯英雄殿
function LadderController:openLadderTopThreeWindow( status )
	if status then
		if self.ladder_top_three_window == nil then
			self.ladder_top_three_window = LadderTopThreeWindow.New()
		end
		self.ladder_top_three_window:open()
	else
		if self.ladder_top_three_window then
			self.ladder_top_three_window:close()
			self.ladder_top_three_window = nil
		end
	end
end

-- 天梯结算界面
function LadderController:openLadderBattleResultWindow( status, data )
	if status then
		if self.ladder_result_window == nil then
			self.ladder_result_window = LadderBattleResultWindow.New()
		end
		self.ladder_result_window:open(data)
	else
		if self.ladder_result_window then
			self.ladder_result_window:close()
			self.ladder_result_window = nil
		end
	end
end

function LadderController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end