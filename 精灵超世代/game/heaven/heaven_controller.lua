-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: htp
-- @editor: htp
-- @description:
--      天界副本
-- <br/>Create: 2019-04-10
-- --------------------------------------------------------------------
HeavenController = HeavenController or BaseClass(BaseController)

function HeavenController:config()
    self.model = HeavenModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function HeavenController:getModel()
    return self.model
end

function HeavenController:registerEvents()
	-- 断线重连时需要清掉缓存数据
    if self.re_link_game_event == nil then
        self.re_link_game_event = GlobalEvent:getInstance():Bind(LoginEvent.RE_LINK_GAME, function()
        	self.model:clearData()
        	self:sender25200()
        	self:sender25219()
        end)
    end
end

-------------------@ c2s
-- 请求天界基础数据
function HeavenController:sender25200(  )
	self:SendProtocal(25200, {})
end

-- 请求天界某一章节数据
function HeavenController:sender25201( id )
	local protocal = {}
	protocal.id = id
    self:SendProtocal(25201, protocal)
end

-- 请求挑战副本
function HeavenController:sender25205( id, order_id )
	local protocal = {}
	protocal.id = id
	protocal.order_id = order_id
    self:SendProtocal(25205, protocal)
end

-- 请求购买次数
function HeavenController:sender25207(  )
	self:SendProtocal(25207, {})
end

-- 请求扫荡
function HeavenController:sender25208( id, order_id )
	local protocal = {}
	protocal.id = id
	protocal.order_id = order_id
    self:SendProtocal(25208, protocal)
end

-- 请求天界副本阵法数据
function HeavenController:sender25210( type )
	local protocal = {}
	protocal.type = type
    self:SendProtocal(25210, protocal)
end

-- 设置天界副本阵法数据
function HeavenController:sender25211( type, formations )
	local protocal = {}
	protocal.type = type
	protocal.formations = formations
    self:SendProtocal(25211, protocal)
end

-- 请求领取章节星级奖励
function HeavenController:sender25215( id, award_id )
	local protocal = {}
	protocal.id = id
	protocal.award_id = award_id
    self:SendProtocal(25215, protocal)
end

-- 请求神装抽奖
function HeavenController:sender25217( group_id, times, recruit_type )
	local protocal = {}
	protocal.group_id = group_id
	protocal.times = times
	protocal.recruit_type = recruit_type
    self:SendProtocal(25217, protocal)
end

-- 请求抽奖日志
function HeavenController:sender25218( type, group_id )
	local protocal = {}
	protocal.type = type
	protocal.group_id = group_id
    self:SendProtocal(25218, protocal)
end

-- 请求神装抽奖相关数据
function HeavenController:sender25219(  )
	self:SendProtocal(25219, {})
end

------------------@ s2c
function HeavenController:registerProtocals()
	self:RegisterProtocal(25200, "handle25200")     -- 天界基础数据
	self:RegisterProtocal(25201, "handle25201")     -- 天界某一章节数据
	self:RegisterProtocal(25203, "handle25203")     -- 天界基础数据更新
	self:RegisterProtocal(25204, "handle25204")     -- 天界某一章数据更新
	self:RegisterProtocal(25205, "handle25205")     -- 天界挑战关卡
	self:RegisterProtocal(25206, "handle25206")     -- 天界挑战结算
	self:RegisterProtocal(25207, "handle25207")     -- 购买次数
	self:RegisterProtocal(25208, "handle25208")     -- 扫荡返回
	self:RegisterProtocal(25210, "handle25210")     -- 天界副本阵法数据
	self:RegisterProtocal(25211, "handle25211")     -- 设置阵法数据返回
	self:RegisterProtocal(25215, "handle25215")     -- 领取章节奖励返回

	self:RegisterProtocal(25216, "handle25216")     -- 当前是否还有未完成的战斗

	self:RegisterProtocal(25217, "handle25217")     -- 神装抽奖返回
	self:RegisterProtocal(25218, "handle25218")     -- 神装抽奖记录
	self:RegisterProtocal(25219, "handle25219")     -- 神装相关数据
	self:RegisterProtocal(25230, "handle25230")     -- 设置神装抽奖许愿（成功推送25219）
	self:RegisterProtocal(25231, "handle25231")     -- 领取保底礼包（成功推送25219）
	self:RegisterProtocal(25232, "handle25232")     -- 战力前五神装总评分
end

-- 天界基础数据
function HeavenController:handle25200( data )
	if data then
		if data.count then
			self.model:setLeftChallengeCount(data.count)
		end
		if data.buy_count then
			self.model:setTodayBuyCount(data.buy_count)
		end
		if data.max_dun_id then
			self.model:setMaxDunId(data.max_dun_id)
		end
		if data.chapter_info then
			self.model:setChapterData(data.chapter_info)
		end
		GlobalEvent:getInstance():Fire(HeavenEvent.Get_Chapter_Data_Event)
	end
end

-- 天界某一章节数据
function HeavenController:handle25201( data )
	if data then
		if data.dun_info then
			self.model:setCustomsData(data.dun_info, data.id)
		end
		GlobalEvent:getInstance():Fire(HeavenEvent.Update_Chapter_Basedata_Event)
	end
end

-- 天界基础数据更新
function HeavenController:handle25203( data )
	if data then
		if data.count then
			self.model:setLeftChallengeCount(data.count)
		end
		if data.buy_count then
			self.model:setTodayBuyCount(data.buy_count)
		end
		if data.max_dun_id then
			self.model:setMaxDunId(data.max_dun_id)
		end
		if data.chapter_info then
			self.model:updateChapterData(data.chapter_info)
		end
		GlobalEvent:getInstance():Fire(HeavenEvent.Update_Chapter_Count_Event)
	end
end

-- 天界某一章数据更新
function HeavenController:handle25204( data )
	if data then
		if data.dun_info then
			self.model:updateCustomsData(data.dun_info, data.id)
			GlobalEvent:getInstance():Fire(HeavenEvent.Update_Chapter_Basedata_Event)
		end
	end
end

-- 挑战关卡
function HeavenController:handle25205( data )
	if data then
		message(data.msg)
	end
end

-- 挑战结算
function HeavenController:handle25206( data )
	if data then
		BattleController:getInstance():openFinishView(true, BattleConst.Fight_Type.HeavenWar, data)
	end
end

-- 购买次数
function HeavenController:handle25207( data )
	if data then
		message(data.msg)
		if data.count then
			self.model:setLeftChallengeCount(data.count)
		end
		if data.buy_count then
			self.model:setTodayBuyCount(data.buy_count)
		end
		if data.code == 1 and self._temp_type and self._temp_formations then
			self:sender25211(self._temp_type, self._temp_formations)
			self._temp_type = nil
			self._temp_formations = nil
		elseif data.code == 1 and self._temp_id and self._temp_order_id then
			self:sender25208( self._temp_id, self._temp_order_id )
			self._temp_id = nil
			self._temp_order_id = nil
		end
		GlobalEvent:getInstance():Fire(HeavenEvent.Update_Chapter_Count_Event)
	end
end

-- 扫荡返回
function HeavenController:handle25208( data )
	if data then
		message(data.msg)
		if data.count then
			self.model:setLeftChallengeCount(data.count)
		end
		GlobalEvent:getInstance():Fire(HeavenEvent.Update_Chapter_Count_Event)
	end
end

-- 天界副本阵法数据
function HeavenController:handle25210( data )
	GlobalEvent:getInstance():Fire(HeavenEvent.Update_Heaven_Fun_Form, data)

    -- local _type = nil
    -- if data.type == 1 then
    --     _type = PartnerConst.Fun_Form.Heaven
    -- else
    --     _type = PartnerConst.Fun_Form.HeavenBoss
    -- end

    -- local model = HeroController:getInstance():getModel()
    -- for i,v in ipairs(data.formations) do
    --     v.type = _type
    --     model:setFormList(v, i)
    -- end
end

-- 设置阵法数据返回
function HeavenController:handle25211( data )
	if data then
		message(data.msg)
		GlobalEvent:getInstance():Fire(HeavenEvent.Save_Heaven_Fun_Form, data)
	end
end

-- 领取章节奖励返回
function HeavenController:handle25215( data )
	if data then
		message(data.msg)
		local temp_data = {}
		temp_data.award_info = data.award_info
		self.model:updateOneChapterDataById(data.id, temp_data)
		GlobalEvent:getInstance():Fire(HeavenEvent.Get_Chapter_Award_Event)
	end
end

-- 是否还有未完成的战斗
function HeavenController:handle25216( data )
	if data then
		BattleController:getInstance():getModel():setUnfinishedWarStatus(data.combat_type, data.flag)
		if data.flag == 0 then -- 服务端可能会先告知客户端有战斗，再结算，再告知无战斗
			MainuiController:getInstance():openRelevanceWindowAtOnce(data.combat_type)
		end
	end
end

-- 神装抽奖
function HeavenController:handle25217( data )
	if data then
		local items = {}
    	for i,v in ipairs(data.rewards or {}) do
    		items[i] = {}
    		items[i].bid = v.base_id
    		items[i].num = v.num
    		items[i].id = v.id
    	end
    	MainuiController:getInstance():openGetItemView(true, items, 0, {is_backpack = true, times = data.times, group_id = data.group_id}, MainuiConst.item_open_type.heavendial)
	end
end

-- 神装抽奖记录
function HeavenController:handle25218( data )
	if data then
		if data.type == 1 then -- 个人
			self.model:setMyselfDialRecordData(data.log_list)
		elseif data.type == 2 then -- 全服
			self.model:setAllDialRecordData(data.log_list, data.group_id)
		end
		GlobalEvent:getInstance():Fire(HeavenEvent.Update_Dial_Record_Data, data.type, data.group_id)
	end
end

-- 神装相关数据
function HeavenController:handle25219( data )
	if data then
		self.model:setHeavenDailData(data.recruit_list)
		GlobalEvent:getInstance():Fire(HeavenEvent.Update_Dial_Base_Data)
	end
end

-- 请求设置神装抽奖许愿（成功推送25219）
function HeavenController:sender25230( group_id ,lucky_holy_eqm)
	local protocal = {}
	protocal.group_id = group_id
	protocal.lucky_holy_eqm = lucky_holy_eqm
	self:SendProtocal(25230, protocal)
end

-- 设置神装抽奖许愿（成功推送25219）
function HeavenController:handle25230( data )
	if data then
		message(data.msg)
	end
end

-- 请求领取保底礼包（成功推送25219）
function HeavenController:sender25231( group_id ,id)
	local protocal = {}
	protocal.group_id = group_id
	protocal.id = id
	self:SendProtocal(25231, protocal)
end

-- 领取保底礼包（成功推送25219）
function HeavenController:handle25231( data )
	if data then
		message(data.msg)
	end
end

-- 请求战力前五神装总评分
function HeavenController:sender25232( )
	local protocal = {}
	self:SendProtocal(25232, protocal)
end

-- 战力前五神装总评分
function HeavenController:handle25232( data )
	if data then
		self.model:setAllScore(data.score)
	end
end

-- 检测挑战次数并且进入战斗
function HeavenController:checkJoinHeavenBattle( _type, formations )
	if self.model:getLeftChallengeCount() > 0 then
		self:sender25211(_type, formations)
	elseif self.model:getTodayLeftBuyCount() > 0 then
		local buy_num = self.model:getTodayBuyCount()
		local buy_cfg = Config.DungeonHeavenData.data_count_buy[buy_num+1]
		if buy_cfg then
			local str = string.format(TI18N("挑战次数不足，是否消耗<img src=%s visible=true scale=0.3 />%d购买一次挑战次数并且进入战斗？"), PathTool.getItemRes(3), buy_cfg.cost)					
			CommonAlert.show( str, TI18N("确定"), function()
				-- 缓存布阵数据，购买次数成功返回后直接进入战斗
				self._temp_type = _type
				self._temp_formations = formations
				self:sender25207()
	    	end, TI18N("取消"), nil, CommonAlert.type.rich)
		end
	else
		message(TI18N("挑战次数不足"))
		HeroController:getInstance():openFormGoFightPanel(false)
	end
end

-- 检测挑战次数并且进行扫荡
function HeavenController:checkHeavenSweep( id, order_id )
	if self.model:getLeftChallengeCount() > 0 then
		self:sender25208( id, order_id )
	elseif self.model:getTodayLeftBuyCount() > 0 then
		local buy_num = self.model:getTodayBuyCount()
		local buy_cfg = Config.DungeonHeavenData.data_count_buy[buy_num+1]
		if buy_cfg then
			local str = string.format(TI18N("挑战次数不足，是否消耗<img src=%s visible=true scale=0.3 />%d购买一次挑战次数并且进行扫荡？"), PathTool.getItemRes(3), buy_cfg.cost)					
			CommonAlert.show( str, TI18N("确定"), function()
				-- 缓存数据，购买次数成功返回后直接进入战斗
				self._temp_id = id
				self._temp_order_id = order_id
				self:sender25207()
	    	end, TI18N("取消"), nil, CommonAlert.type.rich)
		end
	else
		message(TI18N("挑战次数不足"))
	end
end

-----------------------@ 界面相关
-- 打开天界副本主界面 chapter_id:强制打开某一章节
function HeavenController:openHeavenMainWindow( status, chapter_id ,index,group_id,is_open_chapter)
	if status == true then
		-- 判断是否开启
		if not self.model:checkHeavenIsOpen() then
			return
		end

		if index and index == HeavenConst.Tab_Index.DialRecord then
			-- 判断功能是否开启
			if not self.model:checkHeavenDialIsOpen() then
				return
			end

			-- 判断对应的组别是否开启
			if group_id then
				if not self.model:checkHeavenDialIsOpenByGId(group_id) then
					local group_cfg = Config.HolyEqmLotteryData.data_group[group_id]
					if group_cfg then
						message(group_cfg.open_desc .. group_cfg.name)
					end
					return
				end
			end
		end

		if not self.heaven_main_wnd then
			self.heaven_main_wnd = HeavenMainWindow.New(index)
		end
		
		if self.heaven_main_wnd:isOpen() == false then
			local list = {group_id = group_id,index = index,is_open_chapter = is_open_chapter,chapter_id = chapter_id}
			self.heaven_main_wnd:open(list)
		elseif self.heaven_main_wnd:isOpen() == true and index then
			if self.heaven_main_wnd.changeSelectedTab then
				self.heaven_main_wnd:changeSelectedTab(index)
			end
		end

		if index and index == HeavenConst.Tab_Index.DialRecord then
			return
		end
		
	else
		if self.heaven_main_wnd then
			self.heaven_main_wnd:close()
			self.heaven_main_wnd = nil
		end
	end
end

-- 打开天界章节界面
function HeavenController:openHeavenChapterWindow( status, chapter_id )
	if status == true then
		if not self.heaven_chapter_wnd then
			self.heaven_chapter_wnd = HeavenChapterWindow.New()
		end
		if self.heaven_chapter_wnd:isOpen() == false then
			self.heaven_chapter_wnd:open(chapter_id)
		end
	else
		if self.heaven_chapter_wnd then
			self.heaven_chapter_wnd:close()
			self.heaven_chapter_wnd = nil
		end
	end
end

-- 打开天界排行榜
function HeavenController:openHeavenRankWindow( status )
	if status == true then
		if not self.heaven_rank_wnd then
			self.heaven_rank_wnd = HeavenRankWindow.New()
		end
		if self.heaven_rank_wnd:isOpen() == false then
			self.heaven_rank_wnd:open()
		end
	else
		if self.heaven_rank_wnd then
			self.heaven_rank_wnd:close()
			self.heaven_rank_wnd = nil
		end
	end
end

-- 星数奖励界面
function HeavenController:openHeavenStarAwardWindow( status, chapter_id )
	if status == true then
		if not self.star_award_wnd then
			self.star_award_wnd = HeavenStarAwardWindow.New()
		end
		if self.star_award_wnd:isOpen() == false then
			self.star_award_wnd:open(chapter_id)
		end
	else
		if self.star_award_wnd then
			self.star_award_wnd:close()
			self.star_award_wnd = nil
		end
	end
end

-- 战斗胜利结算界面
function HeavenController:openHeavenBattleWinView( status, data )
	if status == true then
		if not self.battle_win_view then
			self.battle_win_view = HeavenBattleWinView.New()
		end
		if self.battle_win_view:isOpen() == false then
			self.battle_win_view:open(data)
		end
	else
		if self.battle_win_view then
			self.battle_win_view:close()
			self.battle_win_view = nil
		end
	end
end

-- 打开神装转盘界面
function HeavenController:openHeavenDialWindow( status, group_id )
	if status == true then
		-- 判断功能是否开启
		if not self.model:checkHeavenDialIsOpen() then
			return
		end

		-- 判断对应的组别是否开启
		if group_id then
			local group_cfg = Config.HolyEqmLotteryData.data_group[group_id]
			if not group_cfg or not self.model:checkHeavenDialIsOpenByGId(group_id) then
				message(group_cfg.open_desc .. group_cfg.name)
				return
			end
		end

		if not self.heaven_dial_wnd then
			self.heaven_dial_wnd = HeavenDialWindow.New()
		end
		if self.heaven_dial_wnd:isOpen() == false then
			self.heaven_dial_wnd:open(group_id)
		end
	else
		if self.heaven_dial_wnd then
			self.heaven_dial_wnd:close()
			self.heaven_dial_wnd = nil
		end
	end
end

-- 打开抽奖记录界面
function HeavenController:openHeavenDialRecordWindow( status, group_id )
	if status == true then
		if not self.dial_record_wnd then
			self.dial_record_wnd = HeavenDialRecordWindow.New()
		end
		if self.dial_record_wnd:isOpen() == false then
			self.dial_record_wnd:open(group_id)
		end
	else
		if self.dial_record_wnd then
			self.dial_record_wnd:close()
			self.dial_record_wnd = nil
		end
	end
end

--打开心愿界面
function HeavenController:openHeavenDialWishWindow( status, pos,data )
	if status == true then
		if not self.dial_wish_wnd then
			self.dial_wish_wnd = HeavenDialWishWindow.New()
		end
		if self.dial_wish_wnd:isOpen() == false then
			self.dial_wish_wnd:open(pos,data)
		end
	else
		if self.dial_wish_wnd then
			self.dial_wish_wnd:close()
			self.dial_wish_wnd = nil
		end
	end
end

-- 天界副本界面
function HeavenController:getHeavenMainWindowRoot(  )
    if self.heaven_main_wnd ~= nil then
        return self.heaven_main_wnd.root_wnd
    end
end

function HeavenController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end