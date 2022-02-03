-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2019-07-22
-- --------------------------------------------------------------------
CrosschampionController = CrosschampionController or BaseClass(BaseController)

function CrosschampionController:config()
    self.model = CrosschampionModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function CrosschampionController:getModel()
    return self.model
end

function CrosschampionController:registerEvents()
	-- 点赞事件监听，判断红点
	self.role_worship_event = GlobalEvent:getInstance():Bind(RoleEvent.WorshipOtherRole, function(rid, srv_id, idx, _type) 
        if _type == WorshipType.crosschampion then
        	self.model:updateTopThreeRoleWorshipStatus(rid, srv_id)
        end
    end)
end

function CrosschampionController:registerProtocals()
	self:RegisterProtocal(26200, "handle26200")		-- 赛程整体实时状态信息
	self:RegisterProtocal(26201, "handle26201")		-- 个人信息
	self:RegisterProtocal(26202, "handle26202")		-- 我的比赛信息
	self:RegisterProtocal(26203, "handle26203")		-- 竞猜信息
	self:RegisterProtocal(26204, "handle26204")		-- 竞猜押注
	self:RegisterProtocal(26205, "handle26205")		-- 我的竞猜信息
	self:RegisterProtocal(26206, "handle26206")		-- 上次比赛结果
	self:RegisterProtocal(26207, "handle26207")		-- 竞猜押注实时更新
	self:RegisterProtocal(26208, "handle26208")		-- 我的PK信息
	self:RegisterProtocal(26209, "handle26209")		-- 64强赛信息
	self:RegisterProtocal(26210, "handle26210")		-- 8强赛信息
	self:RegisterProtocal(26211, "handle26211")		-- 64/8强赛竞猜位置
	self:RegisterProtocal(26212, "handle26212")		-- 64/8强赛指定位置对战信息
	self:RegisterProtocal(26213, "handle26213")		-- 前三名排行信息
	self:RegisterProtocal(26214, "handle26214")		-- 排行榜信息
	self:RegisterProtocal(26215, "handle26215")		-- 冠军信息弹窗
end

-- 赛程整体实时状态信息
function CrosschampionController:sender26200(  )
	self:SendProtocal(26200, {})
end

function CrosschampionController:handle26200( data )
	self.model:updateChampionBaseInfo(data)
    self:sender26201()

    local is_open = self.model:checkCrossChampionIsOpen(true)
    if not is_open then return end

    if data.step_status == ArenaConst.champion_step_status.opened then
        -- 这里时候要判断一下是否有引导,有引导不处理,剧情中也不需要弹
        if GuideController:getInstance():isInGuide() then return end
        if StoryController:getInstance():getModel():isStoryState() then return end 

        if self.crosschampion_wnd == nil and not ArenaController:getInstance():checkChampionWndIsOpen() then
            if data.round_status == ArenaConst.champion_round_status.guess then -- 每次竞猜都要弹提示
                ActivityController:openSignView(true, ActivitySignType.cross_champion_guess, {timer = true})
            else
                if not self.had_show_notice then
                    ActivityController:openSignView(true, ActivitySignType.cross_champion, {timer = true})
                    self.had_show_notice = true
                end
            end
        end
    end
end

-- 请求个人信息
function CrosschampionController:sender26201(  )
	self:SendProtocal(26201, {})
end

function CrosschampionController:handle26201( data )
	self.model:setRoleInfo(data)
end

-- 请求我的比赛信息
function CrosschampionController:sender26202(  )
	self:SendProtocal(26202, {})
end

function CrosschampionController:handle26202( data )
	GlobalEvent:getInstance():Fire(ArenaEvent.UpdateMyMatchInfoEvent, data)
end

-- 请求竞猜
function CrosschampionController:sender26203(  )
	self:SendProtocal(26203, {})
end

function CrosschampionController:handle26203( data )
	GlobalEvent:getInstance():Fire(ArenaEvent.UpdateGuessMatchInfoEvent, data)
end

-- 竞猜押注
function CrosschampionController:sender26204( bet_type, bet_val )
	local protocal = {}
    protocal.bet_type = bet_type
    protocal.bet_val = bet_val
    self:SendProtocal(26204, protocal)
end

function CrosschampionController:handle26204( data )
	if data.msg then
		message(data.msg)
	end
	if data.code == TRUE then
        local role_info = self.model:getRoleInfo()
        role_info.can_bet = data.can_bet
        GlobalEvent:getInstance():Fire(ArenaEvent.UpdateRoleInfoBetEvent, data.can_bet, data.bet_type)
        ArenaController:getInstance():openArenaChampionGuessWindow(false)
    end
end

-- 我的竞猜信息
function CrosschampionController:sender26205(  )
	self:SendProtocal(26205, {})
end

function CrosschampionController:handle26205( data )
	GlobalEvent:getInstance():Fire(ArenaEvent.UpdateMyGuessListEvent, data.list)
end

-- 上次比赛结果
function CrosschampionController:sender26206(  )
	self:SendProtocal(26206, {})
end

function CrosschampionController:handle26206( data )
	ArenaController:getInstance():openArenaChampionBestInfoWindow(true, data, ArenaConst.champion_type.cross)
end

-- 竞猜押注实时更新
function CrosschampionController:handle26207( data )
	GlobalEvent:getInstance():Fire(ArenaEvent.UpdateBetMatchValueEvent, data)
end

-- 我的PK信息
function CrosschampionController:sender26208(  )
	self:SendProtocal(26208, {})
end

function CrosschampionController:handle26208( data )
	GlobalEvent:getInstance():Fire(ArenaEvent.UpdateMylogListEvent, data.list)
end

-- 64 强赛信息
function CrosschampionController:sender26209(  )
	self:SendProtocal(26209, {})
end

function CrosschampionController:handle26209( data )
	GlobalEvent:getInstance():Fire(ArenaEvent.UpdateTop32InfoEvent, data.list)
end

-- 8 强赛信息
function CrosschampionController:sender26210(  )
	self:SendProtocal(26210, {})
end

function CrosschampionController:handle26210( data )
	GlobalEvent:getInstance():Fire(ArenaEvent.UpdateTop4InfoEvent, data.pos_list)
end

-- 64/8强赛竞猜位置
function CrosschampionController:sender26211(  )
	self:SendProtocal(26211, {})
end

function CrosschampionController:handle26211( data )
	GlobalEvent:getInstance():Fire(ArenaEvent.UpdateTop324GuessGroupEvent, data.group, data.pos)
end

-- 64/8强赛指定位置对战信息
function CrosschampionController:sender26212( group, pos )
	local protocal = {}
    protocal.group = group
    protocal.pos = pos
    self:SendProtocal(26212, protocal)
end

function CrosschampionController:handle26212( data )
	GlobalEvent:getInstance():Fire(ArenaEvent.UpdateTop324GroupPosEvent, data)
end

-- 前三名排行信息
function CrosschampionController:sender26213(  )
	self:SendProtocal(26213, {})
end

function CrosschampionController:handle26213( data )
	if data then
		self.model:setTopThreeRoleData(data.rank_list)
		GlobalEvent:getInstance():Fire(CrosschampionEvent.UpdateChampionTop3Event, data.rank_list)
	end
end

-- 排行榜信息
function CrosschampionController:sender26214(  )
	self:SendProtocal(26214, {})
end

function CrosschampionController:handle26214( data )
	GlobalEvent:getInstance():Fire(ArenaEvent.UpdateChampionRankEvent, data)
end

-- 冠军信息弹窗
function CrosschampionController:sender26215(  )
	self:SendProtocal(26215, {})
end

function CrosschampionController:handle26215( data )
	if GuideController:getInstance():isInGuide() then return end
    if StoryController:getInstance():getModel():isStoryState() then return end 
    RenderMgr:getInstance():doNextFrame(function() 
        ArenaController:getInstance():openArenaChampionTop3Window(true, data, ArenaConst.champion_type.cross)
    end)
end

-- 进入周冠军赛玩家主界面（通知后端，用于触发成就）
function CrosschampionController:sender26216(  )
	self:SendProtocal(26216, {})
end

---------------------@ 界面相关
-- 打开跨服冠军赛入口主界面
function CrosschampionController:openCrosschampionMainWindow( status, force )
	if status == true then
		-- 玩法是否开启
		if not self.model:checkCrossChampionIsOpen(true) then
			return
		end

		-- 如果冠军赛正在进行，则直接进入冠军赛玩法界面
		if not force and self.model:getMyMatchStatus() ~= ArenaConst.champion_my_status.unopened and self.model:getOpenCrosschampionViewStatus() then
			self:setCrosschampionOpenFlag(true)
			self:sender26206()
    		self:sender26201()
			ArenaController:getInstance():openArenaChampionMatchWindow(true, 1, ArenaConst.champion_type.cross)
			return
		end

		self:setCrosschampionOpenFlag(false)

		if not self.crosschampion_wnd then
			self.crosschampion_wnd = CrosschampionMainWindow.New()
		end
		if self.crosschampion_wnd:isOpen() == false then
			self.crosschampion_wnd:open()
		end
	else
		if self.crosschampion_wnd then
			self.crosschampion_wnd:close()
			self.crosschampion_wnd = nil
		end
	end
end

function CrosschampionController:getCrosschampionOpenFlag(  )
	return self.open_flag
end

function CrosschampionController:setCrosschampionOpenFlag( flag )
	self.open_flag = flag
end

-- 打开跨服冠军赛商店
function CrosschampionController:openCrosschampionShopWindow( status )
	if status == true then
		if not self.crosschampion_shop then
			self.crosschampion_shop = CrosschampionShopWindow.New()
		end
		if self.crosschampion_shop:isOpen() == false then
			self.crosschampion_shop:open()
		end
	else
		if self.crosschampion_shop then
			self.crosschampion_shop:close()
			self.crosschampion_shop = nil
		end
	end
end

function CrosschampionController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end