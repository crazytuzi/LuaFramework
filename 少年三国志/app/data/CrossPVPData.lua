require("app.cfg.crosspvp_buff_info")
require("app.cfg.crosspvp_value_info")
require("app.cfg.crosspvp_schedule_info")
require("app.cfg.crosspvp_fight_info")
require("app.cfg.bullet_screen_info")
require("app.cfg.crosspvp_bet_info")

local CrossPVPData = class("CrossPVPData")

local CrossPVPConst = require("app.const.CrossPVPConst")

--[[ 赛段信息和赛场信息
local COURSE_INFO = { has_bet = false,	-- 该赛段是否有投注
					  total_start,
					  total_close,
					  stage_time = { {start, close} x 4}	-- 每个阶段的开始结束时间
					}

local FIELD_INFO = { min_level = 0,		-- 最低等级
					 max_level = 0,		-- 最高等级
					 max_attender = 0,	-- 最大参赛人数
					 cur_attender = 0,  -- 当前参赛人数
					 course_info = { COURSE_INFO x 7},  -- 每个赛段的信息
				   }
]]

local UNAPPLIED  = 0 -- 未参赛
local APPLIED 	 = 1 -- 已报名（有资格参加）
local ELIMINATED = 2 -- 被淘汰

function CrossPVPData:ctor()
	-- 通用数据
	self._course		= 0		-- 当前赛程
	self._stage			= 0 	-- 当前赛程中的哪一个阶段
	self._isApplied		= 0		-- 是否已报名(0-未参赛 1-已报名 2-被淘汰)
	self._battlefield	= 0 	-- 我参加的赛场号
	self._activeField	= 0 	-- 当前活跃赛场号（部分轮次比赛时间各赛场是不一样的）
	self._score 		= 0 	-- 积分
	self._fieldRank 	= 0 	-- 赛区排名
	self._fieldInfo		= {}	-- 四个战场信息（比赛时间表）
	self._hasRcvTime	= false	-- 是否已经拉到过时间
	self._hasAddNotify	= false -- 是否已经注册过本地通知
	self._isWaitResult  = false -- 是否在等待结算结果

	-- 投注相关
	self._numGetFlower	= 0     -- 得到鲜花的数量
	self._numGetEgg		= 0 	-- 得到鸡蛋的数量
	self._numBetFlower	= 0 	-- 献鲜花的数量
	self._numBetEgg 	= 0 	-- 扔鸡蛋的数量
	self._flowerTarget 	= nil	-- (当前)献鲜花的对象
	self._eggTarget 	= nil 	-- (当前)扔鸡蛋的对象
	self._prevFlowerTarget = nil-- (上轮)献鲜花的对象
	self._prevEggTarget = nil 	-- (上轮)扔鸡蛋的对象

	-- 鼓舞相关
	self._numInspireAtk = 0		-- 鼓舞伤害提升的次数
	self._numInspireDef = 0		-- 鼓舞伤害减免的次数

	-- 战斗相关
	self._roomID		= 0 	-- 房间号
	self._roomRank  	= 0 	-- 房间排名
	self._lastAttackArenaTime = 0  -- 记录玩家上次攻打坑位的时间，玩家攻打有CD时间限制
	self._hasObRight 	= false -- 玩家是否有权观看比赛 
	self._obStage 		= 0     -- 玩家观战的战场
	self._obRoom		= 0     -- 玩家观战的房间

	-- 结束及领奖相关
	self._fightCount 	= 0 	-- 总的战斗次数
	self._winCount 		= 0 	-- 赢的战斗次数
	self._hasMatchAward = false -- 是否有比赛奖励
	self._hasFlowerAward= false -- 是否有鲜花奖励
	self._hasEggAward 	= false -- 是否有鸡蛋奖励

	-- 排行缓存
	self._scoreRanks 	= {} 	-- 战场积分排行榜

	self._lastSendBSTime = 0    -- 上次发送弹幕的时间戳
	self._nSelectedPreInstall = 0 -- 选中的预设
end

-- 新一轮比赛开始，重置一些数据
function CrossPVPData:reset()
	self._numBetFlower 	= 0
	self._numBetEgg		= 0
	self._numGetFlower	= 0
	self._numGetEgg		= 0
	self._isWaitResult 	= false
end

-- 根据拉到baseinfo的时间戳，计算赛程和阶段
function CrossPVPData:calcCourseStageByTime(time)
	self._course = 0
	self._stage  = 0
	self._activeField = 0
	local lowField = CrossPVPConst.BATTLE_FIELD_TYPE.PRIMARY
	local highField = CrossPVPConst.BATTLE_FIELD_TYPE.EXTREME

	-- 计算当前所在赛程
	for i = 1, CrossPVPConst.COURSE_EXTRA do
		local courseStart = self._fieldInfo[lowField].course_info[i].total_start
		local courseClose = self._fieldInfo[highField].course_info[i].total_close

		if time >= courseStart and time < courseClose then
			self._course = i
			break
		end
	end

	-- 计算当前所在阶段
	if self._course > CrossPVPConst.COURSE_APPLY then
	   	for i = lowField, highField do
	   		local courseInfo = self._fieldInfo[i].course_info[self._course]

	   		if time >= courseInfo.total_start and time < courseInfo.total_close then
	   			self._activeField = i -- 此字段只在不同步轮次有用

	   			for j = CrossPVPConst.STAGE_REVIEW, CrossPVPConst.STAGE_FIGHT do
	   				if time >= courseInfo.stage_time[j].start and time < courseInfo.stage_time[j].close then
	   					self._stage = j
	   					break
	   				end
	   			end

	   			break
	   		end
	   	end
	end
end

-- 更新玩家的比赛基本信息
function CrossPVPData:updateBaseInfo(data)
	self._isApplied 	= data.has_apply
	self._battlefield 	= data.stage
	self._numInspireAtk = data.current_attack_buff or 0
	self._numInspireDef = data.current_defend_buff or 0

	-- 根据时间戳计算当前的赛程和阶段（确保之前已拉到所有时间段）
	self:calcCourseStageByTime(data.time)

	--__LogTag(TAG, "----服务器返回的时间：" .. G_ServerTime:getTimeString(data.time))
	--__LogTag(TAG, "----当前的赛程：" .. self._course .. " 阶段：" .. self._stage)
	--__LogTag(TAG, "----我的赛场：" .. self._battlefield  .. " 活跃赛场：" ..self._activeField)
end

-- 更新整个赛程的时间和赛区基本配置
function CrossPVPData:updateScheduleInfo(data)
	for i = 1, #data.activity do
		local activity 		= data.activity[i]
		local field 		= {}
		field.min_level		= activity.info.level_min
		field.max_level 	= activity.info.level_max
		field.cur_attender	= activity.info.current
		field.max_attender 	= activity.info.max
		field.course_info 	= {}

		--__LogTag(TAG, "----赛区" .. i .. " 当前人数：" .. field.cur_attender .. " 时间：")
		for j = 1, #activity.details do
			local detail 		= activity.details[j]
			local course 		= {}
			course.has_bet 		= detail.has_bet
			course.total_start	= detail.start_time
			course.total_close  = detail.end_time
			course.stage_time	= { 
									{start = detail.start_time, close = detail.view_time},	-- 预览阶段
									{start = detail.view_time, close = detail.pre_time},	-- 投注阶段
									{start = detail.pre_time, close = detail.battle_time},	-- 鼓舞阶段
									{start = detail.battle_time, close = detail.end_time}	-- 战斗阶段
								  }

			-- 如果没有投注阶段或者是决赛之后的一轮，强行把预览时间延长到投注结束
			if not course.has_bet or detail.round == CrossPVPConst.COURSE_EXTRA then
				local betEndTime = course.stage_time[CrossPVPConst.STAGE_BET].close
				course.stage_time[CrossPVPConst.STAGE_REVIEW].close = betEndTime
				course.stage_time[CrossPVPConst.STAGE_BET].start = betEndTime
			end

			field.course_info[detail.round] = course
			if detail.round == 1 then 
				--__LogTag(TAG, "--------报名：" .. G_ServerTime:getTimeString(course.total_start) .. " -> " .. G_ServerTime:getTimeString(course.total_close))
			else
				--__LogTag(TAG, "--------赛程" .. detail.round .. "：")
				--__LogTag(TAG, "------------回顾：" .. G_ServerTime:getTimeString(course.stage_time[1].start) .. " -> " .. G_ServerTime:getTimeString(course.stage_time[1].close))
				--__LogTag(TAG, "------------投注：" .. G_ServerTime:getTimeString(course.stage_time[2].start) .. " -> " .. G_ServerTime:getTimeString(course.stage_time[2].close))
				--__LogTag(TAG, "------------鼓舞：" .. G_ServerTime:getTimeString(course.stage_time[3].start) .. " -> " .. G_ServerTime:getTimeString(course.stage_time[3].close))
				--__LogTag(TAG, "------------战斗：" .. G_ServerTime:getTimeString(course.stage_time[4].start) .. " -> " .. G_ServerTime:getTimeString(course.stage_time[4].close))
			end
		end

		self._fieldInfo[activity.info.stage] = field
	end

	self._hasRcvTime = true
end

-- 更新赛场信息
function CrossPVPData:updateFieldInfo(data)
	for i, v in ipairs(data.info) do
		local field 		= self._fieldInfo[v.stage]
		field.min_level 	= v.level_min
		field.max_level 	= v.level_max
		field.cur_attender 	= v.current
		field.max_attender	= v.max

		--__LogTag(TAG, "----赛区" .. v.stage .. " 当前报名人数：" .. v.current)
	end
end

-- 更新报名信息
function CrossPVPData:updateApplyInfo(data, isFull)
	if isFull then
		self._fieldInfo[data.stage].cur_attender = self._fieldInfo[data.stage].max_attender
		return
	end

	self._isApplied = 1
	self._battlefield = data.stage
	self._fieldInfo[data.stage].cur_attender = data.num or 0
end

-- 更新上轮比赛回顾信息
function CrossPVPData:updateReviewInfo(data)
	--self._battlefield	= data.stage
	self._fieldRank 	= rawget(data, "rank") or 0
	self._roomRank 		= rawget(data, "room_rank") or 0
	self._score 		= rawget(data, "score") or 0
	self._fightCount 	= rawget(data, "battle_count") or 0
	self._winCount 		= rawget(data, "win_count") or 0
	self._hasMatchAward = rawget(data, "has_award") or false
	self._hasFlowerAward= rawget(data, "flower_award") and true or false
	self._hasEggAward 	= rawget(data, "egg_award") and true or false
	self:updatePrevBetTarget(rawget(data, "flower_award"), rawget(data, "egg_award"))

	-- 有时候服务器尚未完成排名结算，需要设置一下等待标记
	if self._isApplied ~= UNAPPLIED then
		self._isWaitResult = rawget(data, "rank") == nil

		-- 为了避免baseinfo中的晋级状态不同步，、
		-- 一旦排名结算完成，重新计算一下是否晋级
		if not self._isWaitResult then
			local isPromote = self:canPromoteToNext()
			self._isApplied = isPromote and APPLIED or ELIMINATED
		end
	else
		self._isWaitResult = false
	end
end

-- 更新押注信息
function CrossPVPData:updateBetInfo(data)
	self:updateMyFlowerEggNum(data.flower_get, data.egg_get)
	self:updateBetTarget(rawget(data, "flower_receiver"), rawget(data, "egg_receiver"))
end

-- 更新我得到的鲜花鸡蛋数量
function CrossPVPData:updateMyFlowerEggNum(flowerNum, eggNum)
	self._numGetFlower 	= flowerNum or 0
	self._numGetEgg 	= eggNum or 0
end

-- 更新上轮投注的对象
function CrossPVPData:updatePrevBetTarget(flowerTarget, eggTarget)
	self._prevFlowerTarget	= nil
	self._prevEggTarget 	= nil

	if flowerTarget then
		self._prevFlowerTarget	= { id 			= flowerTarget.id,
									sid 		= flowerTarget.sid,
									name 		= flowerTarget.name,
									main_role 	= flowerTarget.main_role,
									dress_id 	= flowerTarget.dress_id,
									fight_value	= flowerTarget.fight_value or 0,
									lastRank    = rawget(flowerTarget, "sp1"), -- 上一轮的排名
									betByMe		= rawget(flowerTarget, "sp3"), -- 我献的鲜花数量
									totalBet	= rawget(flowerTarget, "sp4"), -- 总的被献鲜花数
						  	  	  }
	end

	if eggTarget then
		self._prevEggTarget = { id 			= eggTarget.id,
								sid 		= eggTarget.sid,
								name 		= eggTarget.name,
								main_role 	= eggTarget.main_role,
								dress_id 	= eggTarget.dress_id,
								fight_value	= eggTarget.fight_value or 0,
								lastRank    = rawget(eggTarget, "sp1"), -- 上一轮的排名
								betByMe		= rawget(eggTarget, "sp3"), -- 我扔的鸡蛋数量
								totalBet	= rawget(eggTarget, "sp4"), -- 总的被扔鸡蛋数
						  	  }
	end
end

-- 更新投注的对象
function CrossPVPData:updateBetTarget(flowerTarget, eggTarget)
	self._flowerTarget 	= nil
	self._eggTarget 	= nil

	-- 献鲜花的对象
	if flowerTarget then
		self._flowerTarget	= { id 			= flowerTarget.id,
								sid 		= flowerTarget.sid,
								name 		= flowerTarget.name,
								sname 		= flowerTarget.sname,
								main_role 	= flowerTarget.main_role,
								dress_id 	= flowerTarget.dress_id,
								fight_value	= flowerTarget.fight_value or 0,
								lastRank    = rawget(flowerTarget, "lastRank") or rawget(flowerTarget, "sp1"), -- 上一轮的排名
								battlefield = rawget(flowerTarget, "battlefield") or rawget(flowerTarget, "sp2"),
								betByMe		= rawget(flowerTarget, "betByMe") or rawget(flowerTarget, "sp3"), -- 我献的鲜花数量
								totalBet	= rawget(flowerTarget, "totalBet") or rawget(flowerTarget, "sp4"), -- 总的被献鲜花数
						  	  }
		self._numBetFlower = self._flowerTarget.betByMe

		if tostring(flowerTarget.id) == tostring(G_Me.userData.id) and
	   	   tostring(flowerTarget.sid) == tostring(G_PlatformProxy:getLoginServer().id) then
	   	   self._numGetFlower = self._flowerTarget.totalBet
	   	end
	end

	-- 扔鸡蛋的对象
	if eggTarget then
		self._eggTarget = { id 			= eggTarget.id,
							sid 		= eggTarget.sid,
							name 		= eggTarget.name,
							sname 		= eggTarget.sname,
							main_role 	= eggTarget.main_role,
							dress_id 	= eggTarget.dress_id,
							fight_value	= eggTarget.fight_value or 0,
							lastRank    = rawget(eggTarget, "lastRank") or rawget(eggTarget, "sp1"), -- 上一轮的排名
							battlefield = rawget(eggTarget, "battlefield") or rawget(eggTarget, "sp2"),
							betByMe		= rawget(eggTarget, "betByMe") or rawget(eggTarget, "sp3"), -- 我扔的鸡蛋数量
							totalBet	= rawget(eggTarget, "totalBet") or rawget(eggTarget, "sp4"), -- 总的被扔鸡蛋数
						  }
		self._numBetEgg = self._eggTarget.betByMe

		if tostring(eggTarget.id) == tostring(G_Me.userData.id) and
	   	   tostring(eggTarget.sid) == tostring(G_PlatformProxy:getLoginServer().id) then
	   	   self._numGetEgg = self._eggTarget.totalBet
	   	end
	end
end

-- 更新当前投注对象的总鲜花数或总鸡蛋熟
function CrossPVPData:updateBetTargetNum(betType, newNum)
	if betType == CrossPVPConst.BET_FLOWER and self._flowerTarget then
		self._flowerTarget.totalBet = newNum
	elseif betType == CrossPVPConst.BET_EGG and self._eggTarget then
		self._eggTarget.totalBet = newNum
	end
end

-- 更新房间号
function CrossPVPData:updateRoomInfo(data)
	self._roomID = rawget(data, "room") or 0
	self._score  = rawget(data, "score") or 0
end

-- 增加押注量
function CrossPVPData:addBetNum(betType, betCount)
	if betType == CrossPVPConst.BET_FLOWER then
		self._numBetFlower = self._numBetFlower + betCount
	elseif betType == CrossPVPConst.BET_EGG then
		self._numBetEgg = self._numBetEgg + betCount
	end
end

-- 领取投注奖励完成
function CrossPVPData:onGetBetAward(data)
	if data.type == CrossPVPConst.BET_FLOWER then
		self._hasFlowerAward = false
	elseif data.type == CrossPVPConst.BET_EGG then
		self._hasEggAward = false
	end
end

-- 领取比赛奖励完成
function CrossPVPData:onGetMatchAward()
	self._hasMatchAward = false
end

-- 更新战场排行榜
function CrossPVPData:updateScoreRanks(data)
	self._scoreRanks[data.stage] = clone(data.ranks)
	self._scoreRanks[data.stage].course = self._course
end

-- 需要直接返回成员变量的都写在这里
function CrossPVPData:hasRcvTime() return self._hasRcvTime end
function CrossPVPData:hasAddNotify() return self._hasAddNotify end
function CrossPVPData:setHasAddNotify(hasAdd) self._hasAddNotify = hasAdd end
function CrossPVPData:isWaitResult() return self._isWaitResult end
function CrossPVPData:getCourse() return self._course end
function CrossPVPData:getStage() return self._stage end
function CrossPVPData:isApplied() return self._isApplied == APPLIED end 		-- 是否报名参赛（被淘汰了不算）
function CrossPVPData:isEliminated() return self._isApplied == ELIMINATED end 	-- 是否已被淘汰
function CrossPVPData:getBattlefield() return self._battlefield end
function CrossPVPData:getActiveField() return self._activeField end
function CrossPVPData:getRoomID() return self._roomID end
function CrossPVPData:getScore() return self._score end 						-- 返回积分
function CrossPVPData:getFieldRank() return self._fieldRank end 				-- 返回赛区排名
function CrossPVPData:getRoomRank() return self._roomRank end  					-- 返回房间排名
function CrossPVPData:getNumInspireAtk() return self._numInspireAtk end 		-- 鼓舞增伤的次数
function CrossPVPData:getNumInspireDef() return self._numInspireDef end 		-- 鼓舞减伤的次数
function CrossPVPData:getNumGetFlower() return self._numGetFlower end 			-- 被献鲜花的数量
function CrossPVPData:getNumGetEgg() return self._numGetEgg end 				-- 被扔鸡蛋的数量
function CrossPVPData:getNumBetFlower() return self._numBetFlower end 			-- 献出鲜花的数量
function CrossPVPData:getNumBetEgg() return self._numBetEgg end 	 			-- 扔出鸡蛋的数量
function CrossPVPData:getFlowerTarget() return self._flowerTarget end 			-- 本轮我献鲜花的对象
function CrossPVPData:getEggTarget() return self._eggTarget end 				-- 本轮我扔鸡蛋的对象
function CrossPVPData:getPrevFlowerTarget() return self._prevFlowerTarget end 	-- 上轮我献鲜花的对象
function CrossPVPData:getPrevEggTarget() return self._prevEggTarget end 		-- 上轮我扔鸡蛋的对象
function CrossPVPData:getFightCount() return self._fightCount end       		-- 战斗场数
function CrossPVPData:getWinCount() return self._winCount end  					-- 胜利场数
function CrossPVPData:hasMatchAward() return self._hasMatchAward end 			-- 是否有比赛奖励
function CrossPVPData:hasFlowerAward() return self._hasFlowerAward end 			-- 是否有鲜花奖励
function CrossPVPData:hasEggAward() return self._hasEggAward end 				-- 是否有鸡蛋奖励
function CrossPVPData:hasBetAward() return self._hasFlowerAward or self._hasEggAward end -- 是否有投注奖励
function CrossPVPData:getScoreRanks(field) return self._scoreRanks[field] end 	-- 获取某个战场的排行榜

function CrossPVPData:hasBetStage() return self._fieldInfo[1].course_info[self._course].has_bet end 		-- 本轮比赛是否有投注
function CrossPVPData:hasBetStageByCourse(course) return self._fieldInfo[1].course_info[course].has_bet end
function CrossPVPData:canWatchGame() return self:hasBetStage() end	-- 是否可以观战（定义如果本轮有投注就可以观战）
function CrossPVPData:setLastAttackArenaTime(nTime) self._lastAttackArenaTime = nTime or 0 end
function CrossPVPData:getLastAttackArenaTime() return self._lastAttackArenaTime end
function CrossPVPData:setHasObRight(bIs) self._hasObRight = bIs or false end
function CrossPVPData:hasObRight() return self._hasObRight end
function CrossPVPData:setObStage(nStage) self._obStage = nStage end
function CrossPVPData:getObStage() return self._obStage end
function CrossPVPData:setObRoom(nRoom) self._obRoom = nRoom end
function CrossPVPData:getObRoom() return self._obRoom end

function CrossPVPData:setLastSendBSTime(nTime) self._lastSendBSTime = nTime or 0 end
function CrossPVPData:getLastSendBSTime() return self._lastSendBSTime end
function CrossPVPData:setSelectedPreInstall(nIndex) self._nSelectedPreInstall = nIndex end
function CrossPVPData:getSelectedPreInstall() return self._nSelectedPreInstall end

-- 是否在报名开始之前
function CrossPVPData:isBeforeApply()
	if #self._fieldInfo > 0 then
		local applyStartTime, _ = self:getCourseTime(CrossPVPConst.COURSE_APPLY)
		return G_ServerTime:getLeftSeconds(applyStartTime) > 0
	end

	return false
end

-- 上轮比赛是否有投注
function CrossPVPData:hasLastBetStage()
	if self._course == CrossPVPConst.COURSE_APPLY then
		return false
	end

	return self._fieldInfo[1].course_info[self._course - 1].has_bet
end

-- 返回某个赛程的开始和结束时间戳
function CrossPVPData:getCourseTime(course)
	-- 某些阶段各赛场不同步，所以是四个赛场的总时间
	local lowField = CrossPVPConst.BATTLE_FIELD_TYPE.PRIMARY
	local highField = CrossPVPConst.BATTLE_FIELD_TYPE.EXTREME

	local start = self._fieldInfo[lowField].course_info[course].total_start
	local close = self._fieldInfo[highField].course_info[course].total_close
	return start, close
end

-- 返回某个赛程的开战时间（从投注或鼓舞开始算起）
function CrossPVPData:getCourseBattleBeginTime(course)
	-- 取最低级战场的预览结束时间
	return self._fieldInfo[1].course_info[course].stage_time[1].close
end

-- 返回某个赛区当前赛程的开战时间（从投注或鼓舞开始算起）
function CrossPVPData:getFieldBattleBeginTime(field)
	-- 取预览结束时间
	course = self._course == CrossPVPConst.COURSE_APPLY and self._course + 1 or self._course
	return self._fieldInfo[field].course_info[course].stage_time[1].close
end

-- 返回某个赛区当前赛程的战斗结束时间
function CrossPVPData:getFieldBattleEndTime(field)
	local stage = CrossPVPConst.STAGE_FIGHT
	return self._fieldInfo[field].course_info[self._course].stage_time[stage].close
end

-- 返回当前赛段某个阶段的开始和结束时间戳
function CrossPVPData:getStageTime(stage)
	-- 报名流程时没有阶段概念，直接返回报名的开始结束时间
	if self._course == CrossPVPConst.COURSE_APPLY then
		return self:getCourseTime(self._course)
	end
	
	local stageTime = self._fieldInfo[self._activeField].course_info[self._course].stage_time[stage]
	return stageTime.start, stageTime.close
end

-- 步进到下一个阶段（赛程）
function CrossPVPData:stepToNextStage()
	assert(not (self._course == CrossPVPConst.COURSE_FINAL and self._stage == CrossPVPConst.STAGE_END),
		   "CrossPVPData:stepToNextStage - the match is over, cannot step to next stage!")

	if self._course == CrossPVPConst.COURSE_APPLY then
		-- 如果当前是报名流程，那么就步入下一个赛程，并把阶段置为初始阶段
		self._course = self._course + 1
		self._stage  = CrossPVPConst.STAGE_REVIEW
		self._activeField = 1
	elseif self._stage == CrossPVPConst.STAGE_FIGHT then

		if self._activeField == CrossPVPConst.BATTLE_FIELD_NUM then
			-- 如果是本赛程的最后一个阶段，那么就步入下一个赛程，并把阶段置为初始阶段，
			self._course = self._course + 1
			self._stage  = CrossPVPConst.STAGE_REVIEW
			self._activeField = 1
		else
			self._stage  = CrossPVPConst.STAGE_REVIEW
			self._activeField = self._activeField + 1
		end
	else
		self._stage = self._stage + 1
	end

	return self._course, self._stage
end

-- 获取某个赛场的报名等级限制(最小和最大)
function CrossPVPData:getApplyLevelLimit(battlefield)
	assert(battlefield > 0 and battlefield <= CrossPVPConst.BATTLE_FIELD_NUM, "CrossPVPData:getApplyLevelLimit - invalid battlefield type")
	local fieldInfo = self._fieldInfo[battlefield]
	return fieldInfo.min_level, fieldInfo.max_level
end

-- 获取某个赛场的报名人数和总人数
function CrossPVPData:getApplyNum(battlefield)
	assert(battlefield > 0 and battlefield <= CrossPVPConst.BATTLE_FIELD_NUM, "CrossPVPData:getApplyNum - invalid battlefield type")
	local fieldInfo = self._fieldInfo[battlefield]
	return fieldInfo.cur_attender, fieldInfo.max_attender
end

-- 是否满足某个战场的等级要求
function CrossPVPData:isLevelSatisfy(battlefield)
	assert(battlefield > 0 and battlefield <= CrossPVPConst.BATTLE_FIELD_NUM, "CrossPVPData:isLevelSatisfy - invalid battlefield type")
	local minLevel, maxLevel = self:getApplyLevelLimit(battlefield)
	local myLevel = G_Me.userData.level
	return myLevel >= minLevel and myLevel <= maxLevel
end

-- 某个赛程是否开始（从投注或鼓舞开始算起）
function CrossPVPData:isCourseBegin(course)
	-- 取最低级战场的预览结束时间
	local beginTime = self:getCourseBattleBeginTime(course)
	return G_ServerTime:getLeftSeconds(beginTime) <= 0 
end

-- 某个赛区当前轮次是否已开始（从投注或鼓舞开始算起）
function CrossPVPData:isFieldBattleBegin(battlefield)
	local beginTime = self:getFieldBattleBeginTime(battlefield)
	return G_ServerTime:getLeftSeconds(beginTime) <= 0
end

-- 获取某个赛区当前所处的阶段
function CrossPVPData:getFieldStage(battlefield)
	-- 报名期间不分阶段
	if self._course == CrossPVPConst.COURSE_APPLY then
		return 0
	end

	local fieldInfo = self._fieldInfo[battlefield]
	local courseInfo = fieldInfo.course_info[self._course]
	local stage_time = courseInfo.stage_time

	for i = 1, CrossPVPConst.STAGE_FIGHT do
		if G_ServerTime:getLeftSeconds(stage_time[i].close) >= 0 then
			return i
		end
	end

	-- 如果已经过了所有阶段，返回这个阶段
	return CrossPVPConst.STAGE_END
end

-- 我的比赛是否已开始（这里不是战斗阶段开始，而是从投注开始算起，如果没有投注则从鼓舞算起）
function CrossPVPData:isMyMatchBegin()
	if self._isApplied ~= APPLIED or self._battlefield == 0 then return false end
	return self:isFieldBattleBegin(self._battlefield)
end

-- 我的比赛是否已结束（战斗结束）
function CrossPVPData:isMyMatchEnd()
	if self._isApplied ~= APPLIED or self._battlefield == 0 then return true end
	local endTime = self:getFieldBattleEndTime(self._battlefield)
	return G_ServerTime:getLeftSeconds(endTime) <= 0
end

-- 是否可以拉取上轮信息(在刚进模块的时候判断)
function CrossPVPData:canRequestReviewInfo()
	-- 报名阶段一律不拉取上轮信息
	if self._course == CrossPVPConst.COURSE_APPLY then
		return false
	end

	local canRequest = false
	if self._isApplied == APPLIED or self._isApplied == ELIMINATED then
		-- 参赛或者被淘汰的人，在比赛结束至下轮投注之间，可以拉取上轮信息
		-- 海选赛必须在自己赛区比赛结束后才可以
		local myStage = self:getFieldStage(self._battlefield)
		if self._course == CrossPVPConst.COURSE_PROMOTE_1024 then
			canRequest = (myStage == CrossPVPConst.STAGE_END)
		else
			canRequest = (myStage <= CrossPVPConst.STAGE_BET or myStage == CrossPVPConst.STAGE_END)
		end
	else
		-- 不参赛的人，如果上一轮有投注，且在本轮回顾和投注阶段，才拉取上轮信息
		local hasLastBet = self:hasLastBetStage()
		if hasLastBet and self._stage <= CrossPVPConst.STAGE_BET then
			canRequest = true
		end
	end

	return canRequest
end

-- 是否需要拉取上轮信息（在阶段切换时判断，注意跟上面那个函数意义不一样）
function CrossPVPData:needRequestReviewInfo()
	local needRequest = false
	if self._isApplied == APPLIED or self._isApplied == ELIMINATED then
		-- 参赛或者被淘汰的人，在比赛结束时拉取上轮信息
		local myStage = self:getFieldStage(self._battlefield)
		if self._course == CrossPVPConst.COURSE_PROMOTE_1024 then
			needRequest = (myStage == CrossPVPConst.STAGE_END)
		else
			needRequest = (myStage == CrossPVPConst.STAGE_REVIEW)
		end
	else
		-- 不参赛的人，如果上一轮有投注，那么在本轮回顾阶段就拉取
		local hasLastBet = self:hasLastBetStage()
		if hasLastBet and self._stage == CrossPVPConst.STAGE_REVIEW then
			needRequest = true
		end
	end

	return needRequest
end

-- 是否需要拉取房间号
function CrossPVPData:needRequestRoomID()
	if self._isApplied == APPLIED and self._battlefield > 0 then
		local myStage = self:getFieldStage(self._battlefield)
		if myStage == CrossPVPConst.STAGE_FIGHT then
			return true
		end
	end

	return false
end

-- 是否有排行榜缓存
function CrossPVPData:hasScoreRankCache(field)
	local cache = self._scoreRanks[field]
	return cache and cache.course and cache.course == self._course and #cache > 0
end

function CrossPVPData:storeInspireInfo(tData)
	if tData.apply_type == 1 then
		self._numInspireAtk = tData.current or 0
	elseif tData.apply_type == 2 then
		self._numInspireDef = tData.current or 0
	end
end

---------- 用于判断征战快捷入口显示的接口 ----------
-- 是否在报名阶段
function CrossPVPData:isApplying()
	return self._course == CrossPVPConst.COURSE_APPLY
end

-- 是否在投注阶段
function CrossPVPData:isBetting()
	return self._course > 0 and self:hasBetStage() and self._stage == CrossPVPConst.STAGE_BET
end

-- 是否在战斗阶段
-- 对于参赛的人：自己战场处于鼓舞和战斗
-- 对于不参赛的人：任意一个战场处于鼓舞和战斗（这里以初级战场开始为判断）
function CrossPVPData:isInBattle()
	if self._course <= 0 or self._course > CrossPVPConst.COURSE_FINAL then
		return false
	end

	local stage = 0
	if self:isApplied() and self._battlefield > 0 then
		stage = self:getFieldStage(self._battlefield)
	elseif self._activeField > 0 then
		stage = self:getFieldStage(self._activeField)
	end

	return stage == CrossPVPConst.STAGE_ENCOURAGE or stage == CrossPVPConst.STAGE_FIGHT
end

-- 是否可以拿比赛奖励
function CrossPVPData:canGetMatchAward()
	if self._course > 0 and self:isApplied() and self:hasMatchAward() then
		local stage = self:getFieldStage(self:getBattlefield())
		return stage == CrossPVPConst.STAGE_REVIEW or
			   stage == CrossPVPConst.STAGE_BET or
			   stage == CrossPVPConst.STAGE_END
	end

	return false
end

-- 是否可以拿投注奖励
function CrossPVPData:canGetBetAward()
	if self._course > 0 and self:hasBetAward() then
		local stage = self:getFieldStage(1)
		return stage == CrossPVPConst.STAGE_REVIEW or
			   stage == CrossPVPConst.STAGE_BET
	end

	return false
end

-- 是否晋级下一轮
function CrossPVPData:canPromoteToNext()
	if self._roomRank == 0 then
		return false
	end

	-- 获取晋级条件
	local course = self._course
	if course ~= CrossPVPConst.COURSE_PROMOTE_1024 then
		course = course - 1
	end

	local promoteInfo = crosspvp_schedule_info.get(course - 1)
	return self._roomRank <= promoteInfo.rank_num
end

---------- 用于获取推送通知时间的接口 ----------
-- 通知每一轮战斗开始的时间点（从鼓舞开始，报名除外)
function CrossPVPData:notifyBattleTime(_course, _field)
	local field = _field or 1
	local courseInfo = self._fieldInfo[field].course_info[_course]

	if _course == CrossPVPConst.COURSE_APPLY then
		return courseInfo.total_start
	else
		return courseInfo.stage_time[CrossPVPConst.STAGE_ENCOURAGE].start
	end
end

-- 通知投注开始的时间点
function CrossPVPData:notifyBetTime(_course)
	local courseInfo = self._fieldInfo[1].course_info[_course]
	if courseInfo.has_bet then
		return courseInfo.stage_time[CrossPVPConst.STAGE_BET].start
	end

	return 0
end

return CrossPVPData