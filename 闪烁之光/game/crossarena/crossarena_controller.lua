-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2019-04-30
-- --------------------------------------------------------------------
CrossarenaController = CrossarenaController or BaseClass(BaseController)

function CrossarenaController:config()
    self.model = CrossarenaModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function CrossarenaController:getModel()
    return self.model
end

function CrossarenaController:registerEvents()
	-- 断线重连
    if self.re_link_game_event == nil then
        self.re_link_game_event = GlobalEvent:getInstance():Bind(LoginEvent.RE_LINK_GAME, function()
        	-- 断线重连成功后，如果结算界面正在显示，则重新请求一次翻牌数据
        	if self.crossarena_result_wnd then
        		self:sender25612()
        	end
        end)
    end
end

------------------ c2s
-- 请求个人信息
function CrossarenaController:sender25600(  )
	self:SendProtocal(25600, {})
end

-- 请求挑战列表
function CrossarenaController:sender25601(  )
	self:SendProtocal(25601, {})
end

-- 请求挑战玩家的信息
function CrossarenaController:sender25602( rid, srv_id )
	local protocal = {}
    protocal.rid = rid
    protocal.srv_id = srv_id
    self:SendProtocal(25602, protocal)
end

-- 查看对方英雄信息
function CrossarenaController:sender25603( rid, srv_id, order, pos )
	local protocal = {}
    protocal.rid = rid
    protocal.srv_id = srv_id
    protocal.order = order
    protocal.pos = pos
    self:SendProtocal(25603, protocal)
end

-- 请求设置阵法
function CrossarenaController:sender25604( type, formations )
	local protocal = {}
    protocal.type = type
    protocal.formations = formations
    if type == 2 then -- 缓存一下，设置成功之后再写入锁定英雄数据
    	self._temp_formations = formations
    end
    self:SendProtocal(25604, protocal)
end

-- 请求阵法数据
function CrossarenaController:sender25605( type )
	local protocal = {}
    protocal.type = type
    self:SendProtocal(25605, protocal)
end

-- 请求挑战玩家
function CrossarenaController:sender25606( rid, srv_id )
    --策划要求进入战斗要去掉提示
	PromptController:getInstance():getModel():removePromptDataByTpye(PromptTypeConst.Corss_arena_tips)
	local protocal = {}
    protocal.rid = rid
    protocal.srv_id = srv_id
    protocal.is_auto = self.model:getCrossarenaAutoBattle() or 0
    self:SendProtocal(25606, protocal)
end

-- 请求挑战次数奖励信息
function CrossarenaController:sender25607(  )
	self:SendProtocal(25607, {})
end

-- 领取挑战次数奖励
function CrossarenaController:sender25608( num )
	local protocal = {}
    protocal.num = num
    self:SendProtocal(25608, protocal)
end

-- 请求刷新挑战玩家列表
function CrossarenaController:sender25609(  )
	self:SendProtocal(25609, {})
end

-- 请求活动是否开启
function CrossarenaController:sender25610(  )
	self:SendProtocal(25610, {})
end

-- 请求结算界面翻牌数据
function CrossarenaController:sender25612(  )
	self:SendProtocal(25612, {})
end

-- 请求翻牌
function CrossarenaController:sender25613( pos )
	local protocal = {}
    protocal.pos = pos
    self:SendProtocal(25613, protocal)
end

-- 请求赛季荣耀信息
function CrossarenaController:sender25614(  )
	self:SendProtocal(25614, {})
end

-- 请求排行榜信息
function CrossarenaController:sender25615(  )
	self:SendProtocal(25615, {})
end

-- 请求挑战记录
function CrossarenaController:sender25616( _type )
	local protocal = {}
    protocal.type = _type
	self:SendProtocal(25616, protocal)
end

-- 请求记录详情
function CrossarenaController:sender25617( _type, id )
	local protocal = {}
    protocal.type = _type
    protocal.id = id
	self:SendProtocal(25617, protocal)
end

function CrossarenaController:registerProtocals()
	self:RegisterProtocal(25600, "handle25600")     -- 个人数据
	self:RegisterProtocal(25601, "handle25601")     -- 挑战角色列表数据
	self:RegisterProtocal(25602, "handle25602")     -- 挑战角色的信息
	self:RegisterProtocal(25603, "handle25603")     -- 查看对方英雄信息
	self:RegisterProtocal(25604, "handle25604")     -- 设置阵法
	self:RegisterProtocal(25605, "handle25605")     -- 请求阵法数据
	self:RegisterProtocal(25606, "handle25606")     -- 挑战玩家
	self:RegisterProtocal(25607, "handle25607")     -- 挑战次数奖励信息
	self:RegisterProtocal(25608, "handle25608")     -- 领取挑战次数奖励
	self:RegisterProtocal(25609, "handle25609")     -- 刷新挑战玩家列表
	self:RegisterProtocal(25610, "handle25610")     -- 请求活动是否开启
	self:RegisterProtocal(25611, "handle25611")     -- 战斗结算
	self:RegisterProtocal(25612, "handle25612")     -- 战斗结算翻牌数据
	self:RegisterProtocal(25613, "handle25613")     -- 战斗结算翻牌数据
	self:RegisterProtocal(25614, "handle25614")     -- 赛季荣耀数据
	self:RegisterProtocal(25615, "handle25615")     -- 排行榜数据
	self:RegisterProtocal(25616, "handle25616")     -- 挑战记录
	self:RegisterProtocal(25617, "handle25617")     -- 挑战记录详情
	self:RegisterProtocal(25618, "handle25618")     -- 红点相关
end

------------------ s2c
-- 个人信息
function CrossarenaController:handle25600( data )
	if data then
		self.model:setCrossarenaMyBaseInfo(data)
		GlobalEvent:getInstance():Fire(CrossarenaEvent.Update_MyBaseInfo_Event)
	end
end

-- 挑战角色列表数据
function CrossarenaController:handle25601( data )
	if data then
		if data.type == 0 then -- 全部更新
			self.model:setChallengeRoleData(data.f_list)
			GlobalEvent:getInstance():Fire(CrossarenaEvent.Update_Challenge_Role_Event)
		elseif data.type == 1 then -- 部分更新
			self.model:updateChallengeRoleData(data.f_list)
		end
	end
end

-- 挑战角色的信息
function CrossarenaController:handle25602( data )
	if data then
		self:openCrossarenaRoleTips(true, data)
	end
end

-- 查看对方英雄信息(成功返回11061)
function CrossarenaController:handle25603( data )
	if data then
		message(data.msg)
	end
end

-- 设置阵法
function CrossarenaController:handle25604( data )
	if data then
		message(data.msg)
		if data.code == 1 then -- 设置阵法成功，则通知布阵界面进入战斗
			GlobalEvent:getInstance():Fire(CrossarenaEvent.Save_Crossarena_Form_Event, data)
			if self._temp_formations then
				local model = HeroController:getInstance():getModel()
			    for i,v in ipairs(self._temp_formations) do
			        v.type = PartnerConst.Fun_Form.CrossArenaDef
			        model:setFormList(v, v.order)
			    end
				self._temp_formations = nil
			end
		end
	end
end

-- 阵法数据
function CrossarenaController:handle25605( data )
	if data.type == 2 then
	    local model = HeroController:getInstance():getModel()
	    for i,v in ipairs(data.formations) do
	        v.type = PartnerConst.Fun_Form.CrossArenaDef
	        model:setFormList(v, v.order)
	        v.type = nil
	    end
    end 
    -- for i,v in ipairs(data.formations) do
    --     v.old_order = v.order --记录旧的位置
    -- end
	GlobalEvent:getInstance():Fire(CrossarenaEvent.Update_Form_Data_Event, data) 
end

-- 挑战玩家
function CrossarenaController:handle25606( data )
	if data then
		message(data.msg)
	end
end

-- 挑战次数奖励信息
function CrossarenaController:handle25607( data )
	if data then
		self.model:setChallengeAwardData(data)
		GlobalEvent:getInstance():Fire(CrossarenaEvent.Update_Challenge_Award_Event)
	end
end

-- 领取挑战次数奖励
function CrossarenaController:handle25608( data )
	if data then
		message(data.msg)
	end
end

-- 刷新玩家挑战列表
function CrossarenaController:handle25609( data )
	if data then
		message(data.msg)
		if data.ref_time then
			self.model:updateRefreshTime(data.ref_time)
			GlobalEvent:getInstance():Fire(CrossarenaEvent.Update_Refresh_Time_Event)
		end
	end
end

-- 活动是否开启
function CrossarenaController:handle25610( data )
	if data then
		self.model:setCrossarenaStatus(data.code)
		GlobalEvent:getInstance():Fire(CrossarenaEvent.Update_Open_Status_Event)
	end
end

-- 战斗结算
function CrossarenaController:handle25611( data )
	if data then
		BattleController:getInstance():openFinishView(true, BattleConst.Fight_Type.CrossArenaWar, data)
	end
end

-- 结算翻牌数据
function CrossarenaController:handle25612( data )
	if data and data.card_info and next(data.card_info) ~= nil then
		GlobalEvent:getInstance():Fire(CrossarenaEvent.Update_Card_Info_Event, data.card_info)
	else
		self:openCrossarenaResultWindow(false)
	end
end

-- 翻牌返回
function CrossarenaController:handle25613( data )
	if data then
		message(data.msg)
	end
end

-- 赛季荣耀数据
function CrossarenaController:handle25614( data )
	if data then
		self.model:setHonourRoleData(data.rank_list)
		GlobalEvent:getInstance():Fire(CrossarenaEvent.Update_Honour_Data_Event)
	end
end

-- 排行榜数据
function CrossarenaController:handle25615( data )
	if data then
		GlobalEvent:getInstance():Fire(CrossarenaEvent.Update_Rank_Data_Event, data)
	end
end

-- 挑战记录
function CrossarenaController:handle25616( data )
	if data then
		GlobalEvent:getInstance():Fire(CrossarenaEvent.Update_Video_Data_Event, data)
	end
end

-- 挑战记录详情
function CrossarenaController:handle25617( data )
	if data then
		GlobalEvent:getInstance():Fire(ElitematchEvent.Elite_Challenge_Record_Info_Event, data)
	end
end

-- 红点数据
function CrossarenaController:handle25618( data )
	if data then
		-- 点赞红点（显示红点时，只在上线时处理一次，其他时间客户端计算）
		if not self.first_login_flag or data.worship_code == 0 then
			self.first_login_flag = true
			self.model:updateCrossarenaRedStatus(CrossarenaConst.Red_Index.Like, data.worship_code == 1)
		end
		-- 宝箱红点
		self.model:updateCrossarenaRedStatus(CrossarenaConst.Red_Index.Award, data.reward_code == 1)
		-- 挑战记录红点
		self.model:updateCrossarenaRedStatus(CrossarenaConst.Red_Index.Record, data.combat_code == 1)
	end
end

---------------@ 界面相关
-- 打开跨服竞技场主界面
function CrossarenaController:openCrossarenaMainWindow( status, sub_type )
	if status == true then
		-- 功能是否开启
		if not self.model:getCrossarenaIsOpen() then
			return
		end

		if not self.crossarena_main_wnd then
			self.crossarena_main_wnd = CrossareanMainWindow.New()
		end
		if self.crossarena_main_wnd:isOpen() == false then
			self.crossarena_main_wnd:open(sub_type)
		end
	else
		if self.crossarena_main_wnd then
			self.crossarena_main_wnd:close()
			self.crossarena_main_wnd = nil
		end
	end
end

function CrossarenaController:getCrossarenaMainRoot(  )
	if self.crossarena_main_wnd then
		return self.crossarena_main_wnd.root_wnd
	end
end

-- 打开排行榜界面
function CrossarenaController:openCrossarenaRankWindow( status )
	if status == true then
		if not self.crossarena_rank_wnd then
			self.crossarena_rank_wnd = CrossarenaRankWindow.New()
		end
		if self.crossarena_rank_wnd:isOpen() == false then
			self.crossarena_rank_wnd:open()
		end
	else
		if self.crossarena_rank_wnd then
			self.crossarena_rank_wnd:close()
			self.crossarena_rank_wnd = nil
		end
	end
end

-- 打开奖励预览界面
function CrossarenaController:openCrossarenaAwardWindow( status )
	if status == true then
		if not self.crossarena_award_wnd then
			self.crossarena_award_wnd = CrossarenaAwardWindow.New()
		end
		if self.crossarena_award_wnd:isOpen() == false then
			self.crossarena_award_wnd:open()
		end
	else
		if self.crossarena_award_wnd then
			self.crossarena_award_wnd:close()
			self.crossarena_award_wnd = nil
		end
	end
end

-- 打开声望商店界面
function CrossarenaController:openCrossarenaShopWindow( status )
	if status == true then
		if not self.crossarena_shop_wnd then
			self.crossarena_shop_wnd= CrossareanShopWindow.New()
		end
		if self.crossarena_shop_wnd:isOpen() == false then
			self.crossarena_shop_wnd:open()
		end
	else
		if self.crossarena_shop_wnd then
			self.crossarena_shop_wnd:close()
			self.crossarena_shop_wnd = nil
		end
	end
end

-- 打开角色tips界面
function CrossarenaController:openCrossarenaRoleTips( status, data )
	if status == true then
		if not self.crossarena_role_tips then
			self.crossarena_role_tips = CrossarenaRoleTips.New()
		end
		if self.crossarena_role_tips:isOpen() == false then
			self.crossarena_role_tips:open(data)
		end
	else
		if self.crossarena_role_tips then
			self.crossarena_role_tips:close()
			self.crossarena_role_tips = nil
		end
	end
end

-- 挑战记录界面
function CrossarenaController:openCrossarenaVideoWindow( status )
	if status == true then
		if not self.crossarena_video_wnd then
			self.crossarena_video_wnd = CrossareanVideoWindow.New()
		end
		if self.crossarena_video_wnd:isOpen() == false then
			self.crossarena_video_wnd:open()
		end
	else
		if self.crossarena_video_wnd then
			self.crossarena_video_wnd:close()
			self.crossarena_video_wnd = nil
		end
	end
end

-- 打开战斗结算界面
function CrossarenaController:openCrossarenaResultWindow( status, data )
	if status == true then
		if not self.crossarena_result_wnd then
			self.crossarena_result_wnd = CrossArenaResultWindow.New()
		end
		if self.crossarena_result_wnd:isOpen() == false then
			self.crossarena_result_wnd:open(data)
		end
	else
		if self.crossarena_result_wnd then
			self.crossarena_result_wnd:close()
			self.crossarena_result_wnd = nil
		end
	end
end

function CrossarenaController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end