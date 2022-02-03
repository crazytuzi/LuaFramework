-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2019-10-10
-- --------------------------------------------------------------------
MonopolyController = MonopolyController or BaseClass(BaseController)

function MonopolyController:config()
    self.model = MonopolyModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function MonopolyController:getModel()
    return self.model
end

function MonopolyController:registerEvents()
end

function MonopolyController:registerProtocals()
	self:RegisterProtocal(27400, "handle27400") -- 活动基础数据
	self:RegisterProtocal(27401, "handle27401") -- 进入大富翁地图
	self:RegisterProtocal(27403, "handle27403") -- 扔骰子
	self:RegisterProtocal(27404, "handle27404") -- 触发事件
	self:RegisterProtocal(27405, "handle27405") -- 猜拳事件结果
	self:RegisterProtocal(27406, "handle27406") -- 触发对话
	self:RegisterProtocal(27407, "handle27407") -- 选择剧情触发对话答案
	self:RegisterProtocal(27408, "handle27408") -- 大富翁buff数据
	self:RegisterProtocal(27409, "handle27409") -- 弹出tips和奖励
	self:RegisterProtocal(27410, "handle27410") -- 对方阵容数据

	self:RegisterProtocal(27500, "handle27500") -- boss数据
	self:RegisterProtocal(27501, "handle27501") -- 挑战boss
	self:RegisterProtocal(27502, "handle27502") -- 个人排行
	self:RegisterProtocal(27503, "handle27503") -- 公会排行
	self:RegisterProtocal(27504, "handle27504") -- buff数据
	self:RegisterProtocal(27505, "handle27505") -- boss击杀数
	self:RegisterProtocal(27506, "handle27506") -- boss结算
end

-- 请求活动基础数据
function MonopolyController:sender27400(  )
	self:SendProtocal(27400, {})
end

function MonopolyController:handle27400(data)
	if data.flag == 1 then
		self.model:setMonopolyBaseInfo(data)
		GlobalEvent:getInstance():Fire(MonopolyEvent.Update_Monopoly_Base_Data_Event)
	else
		-- 活动未开启，关闭相关所有功能
		self:openHolynightMainWindow(false)
		self:openMonopolyMianScene(false)
		self:openHolynightBossWindow(false)
		self:openMonopolyDialogWindow(false)
		self:openMonopolyTips(false)
		self:openMonopolyChoseStepWindow(false)
		self:openMonopolyPumpkinWindow(false)
		self:openMonopolyMorraWindow(false)
		self:openMonopolyRankWindow(false)
		self:openMonopolyItemShowWindow(false)
	end
end

-- 请求进入大富翁地图
function MonopolyController:sender27401(id)
	local protocal = {}
	protocal.id = id
	self:SendProtocal(27401, protocal)
end

function MonopolyController:handle27401(data)
	if data.msg then
		message(data.msg)
	end
	if data.flag == TRUE then -- 进入地图成功
		local map_data = {}
		map_data.id = data.id
		map_data.map_id = data.map_id
		map_data.pos = data.pos
		map_data.events = data.events or {}
		map_data.now_type = data.now_type or 0
		self.model:updateMonopolyMapData(map_data)

		-- 更新关卡探索值
		self.model:updateDevelopValById(data.id, data.develop)
		-- 更新公会探索值
		self.model:updateGuildDevelopValById(data.id, data.guild_develop)
		-- 当前形象id
		self.model:setHomeLookId(data.look_id)

		GlobalEvent:getInstance():Fire(MonopolyEvent.Update_Monopoly_Map_Data_Event)
	end
end

-- 请求扔骰子
function MonopolyController:sender27403(_type, num)
	local protocal = {}
	protocal.type = _type
	protocal.num = num
	self:SendProtocal(27403, protocal)
end
-- 扔骰子返回/当遇到自动前进x格事件时，后端也会主动推送这条协议
function MonopolyController:handle27403(data)
	if data.msg then
		message(data.msg)
	end
	if data.flag == TRUE then -- 扔骰子成功
		-- 更新位置、当前位置的事件
		local new_data = {}
		new_data.id = data.id
		new_data.pos = data.pos
		new_data.now_type = data.now_type
		self.model:updateMonopolyMapData(new_data)
		-- 更新个人探索值
		self.model:updateDevelopValById(data.id, data.develop)
		-- 更新公会探索值
		self.model:updateGuildDevelopValById(data.id, data.guild_develop)
		
		-- 校验一下是否与当前地图id匹配
		if self.model:checkIsInCurMap(data.id) then
			-- 发送事件，停止南瓜机动画并且行走步数（如果南瓜机和选择步数界面没打开，则直接行走）
			local is_move = false
			if not self.monopoly_pumpkin_wnd and not self.chose_step_wnd then
				is_move = true
			end
			GlobalEvent:getInstance():Fire(MonopolyEvent.Get_Dice_Result_Event, data.num, is_move)
		end
	end
end

-- 请求触发事件
function MonopolyController:sender27404(args)
	local protocal = {}
	protocal.args = args
	self:SendProtocal(27404, protocal)
end

function MonopolyController:handle27404(data)
	if data.msg then
		message(data.msg)
	end
	if data.flag == TRUE then
		if self.model:checkIsInCurMap(data.id) then
			-- 更新当前事件类型为0
			self.model:clearMonopolyNowEvtType(data.id)
			
			-- 更新地面事件类型
			self.model:updateMonopolyEventType(data.id, data.pos, data.type)
		end
	end
end

-- 猜拳事件结果
function MonopolyController:handle27405(data)
	GlobalEvent:getInstance():Fire(MonopolyEvent.Get_Morra_Result_Event, data)
end

-- 触发对话内容
function MonopolyController:handle27406(data)
	if data.type then
		local drama_cfg = Config.MonopolyMapsData.data_drama[data.type]
		if drama_cfg and next(drama_cfg) ~= nil then
			self:openMonopolyDialogWindow(true, 99, 0, drama_cfg)
		end
	end
end

-- 请求特殊触发剧情的答案
function MonopolyController:sender27407(_type, choice)
	local protocal = {}
	protocal.type = _type
	protocal.choice = choice
	self:SendProtocal(27407, protocal)
end

function MonopolyController:handle27407(data)
	if data.msg then
		message(data.msg)
	end
end

-- 大富翁buff数据
function MonopolyController:sender27408(id)
	local protocal = {}
	protocal.id = id
	self:SendProtocal(27408, protocal)
end

function MonopolyController:handle27408(data)
	GlobalEvent:getInstance():Fire(MonopolyEvent.Update_Monopoly_Buff_Event, data)
end

-- 弹出tips和奖励
function MonopolyController:handle27409(data)
	if data.buffs and next(data.buffs) ~= nil then
		self.model:addWaitShowTipsData(data.buffs)
	end
	if data.reward and next(data.reward) ~= nil then
		self.model:addWaitShowAwardData(data.reward)
	end
	self:checkShowWaitTips()
end

-- 请求对方阵容数据
function MonopolyController:sender27410(id)
	local protocal = {}
	protocal.id = id
	self:SendProtocal(27410, protocal)
end

function MonopolyController:handle27410(data)
	GlobalEvent:getInstance():Fire(MonopolyEvent.Get_Master_Data_Event, data)
end

------------------------- @boss 相关

-- 请求boss数据
function MonopolyController:sender27500(id)
	local protocal = {}
	protocal.id = id
	self:SendProtocal(27500, protocal)
end

function MonopolyController:handle27500(data)
	if data.flag == 1 then
		GlobalEvent:getInstance():Fire(MonopolyEvent.Get_Boss_Data_Event, data)
	end
end

-- 请求挑战boss
function MonopolyController:sender27501(id, boss_id, formation_type, pos_info, hallows_id)
	local protocal = {}
	protocal.id = id
	protocal.boss_id = boss_id
	protocal.formation_type = formation_type
	protocal.pos_info = pos_info
	protocal.hallows_id = hallows_id
	self:SendProtocal(27501, protocal)
end

function MonopolyController:handle27501(data)
	if data.msg then
		message(data.msg)
	end
end

-- 请求个人排行榜
function MonopolyController:sender27502( id )
	local protocal = {}
	protocal.id = id
	self:SendProtocal(27502, protocal)
end

function MonopolyController:handle27502( data )
	GlobalEvent:getInstance():Fire(MonopolyEvent.Get_Personal_Rank_Data_Event, data)
end

-- boss公会排行数据
function MonopolyController:sender27503(id, num)
	local protocal = {}
	protocal.id = id
	protocal.num = num
	self:SendProtocal(27503, protocal)
end

function MonopolyController:handle27503(data)
	GlobalEvent:getInstance():Fire(MonopolyEvent.Get_Guild_Rank_Data_Event, data)
end

-- 获取buff数据
function MonopolyController:sender27504()
	self:SendProtocal(27504, {})
end

function MonopolyController:handle27504(data)
	if data then
		self.model:updateMonopolyBuffData(data.buffs)
		GlobalEvent:getInstance():Fire(MonopolyEvent.Update_Buff_Data_Event)
	end
end

-- boss击杀数
function MonopolyController:sender27505(  )
	self:SendProtocal(27505, {})
end

function MonopolyController:handle27505( data )
	self.model:updateMonopolyBossNum(data)
	GlobalEvent:getInstance():Fire(MonopolyEvent.Update_Boss_Num_Event)
end

-- boss结算
function MonopolyController:handle27506(data)
	GuildbossController:getInstance():openGuildbossResultWindow(true, data, BattleConst.Fight_Type.MonopolyBoss)
end

-- 触发事件相关
function MonopolyController:triggerGridEvtByType(evt_type, step_id)
	if evt_type == MonopolyConst.Event_Type.Normal then -- 普通地面
		self:sender27404({})
	elseif evt_type == MonopolyConst.Event_Type.Trap then -- 陷阱
		self:openMonopolyMasterInfoWindow(true, MonopolyConst.Event_Type.Trap, step_id)
	elseif evt_type == MonopolyConst.Event_Type.Award then -- 南瓜大礼包
		self:sender27404({})
	elseif evt_type == MonopolyConst.Event_Type.Morra then -- 对决
		self:openMonopolyMorraWindow(true)
	elseif evt_type == MonopolyConst.Event_Type.Dialog then -- 神秘事件
		self:openMonopolyDialogWindow(true, MonopolyConst.Event_Type.Dialog, step_id)
	elseif evt_type == MonopolyConst.Event_Type.Redbag then -- 天降红包
		self:sender27404({})
	elseif evt_type == MonopolyConst.Event_Type.Boss then -- Boss
		self:openMonopolyMasterInfoWindow(true, MonopolyConst.Event_Type.Boss, step_id)
	elseif evt_type == MonopolyConst.Event_Type.Advance then -- 冲呀，前进
		self:sender27404({})
	elseif evt_type == MonopolyConst.Event_Type.Buff then -- buff
		self:sender27404({})
	elseif evt_type == MonopolyConst.Event_Type.Wish then -- 祝福
		self:sender27404({})
	elseif evt_type == MonopolyConst.Event_Type.Medicine then -- 魔女的药锅
		self:sender27404({})
	elseif evt_type == MonopolyConst.Event_Type.Flag then -- flag
		self:openMonopolyDialogWindow(true, MonopolyConst.Event_Type.Flag, step_id)
	elseif evt_type == MonopolyConst.Event_Type.End then -- 终点
		self:sender27404({})
	elseif evt_type == MonopolyConst.Event_Type.Start then -- 起点
		self:sender27404({})
	end
end

-----------------------@ 界面相关
-- 打开圣夜奇境主界面
function MonopolyController:openHolynightMainWindow(status, sub_type)
	if status == true then
		if not self.holy_main_wnd then
			self.holy_main_wnd = HolynightMainWindow.New()
		end
		if self.holy_main_wnd:isOpen() == false then
			self.holy_main_wnd:open(sub_type)
		end
	else
		if self.holy_main_wnd then
			self.holy_main_wnd:close()
			self.holy_main_wnd = nil
		end
	end
end

-- 打开大富翁主场景
function MonopolyController:openMonopolyMianScene( status, id )
	if status == true then
		if not self.monopoly_main_scene then
			self.monopoly_main_scene = MonopolyMainScene.New()
		end
		if self.monopoly_main_scene:isOpen() == false then
			self.monopoly_main_scene:open(id)
		end
	else
		if self.monopoly_main_scene then
			self.monopoly_main_scene:close()
			self.monopoly_main_scene = nil
		end
		self:checkShowWaitAward() -- 关闭主场景时检测一下是否有待显示的奖励
	end
end

-- 打开圣夜奇境boss界面
function MonopolyController:openHolynightBossWindow(status, step_id)
	if status == true then
		if not self.holy_boss_wnd then
			self.holy_boss_wnd = HolynightBossWindow.New()
		end
		if self.holy_boss_wnd:isOpen() == false then
			self.holy_boss_wnd:open(step_id)
		end
	else
		if self.holy_boss_wnd then
			self.holy_boss_wnd:close()
			self.holy_boss_wnd = nil
		end
	end
end

-- 打开对话界面
function MonopolyController:openMonopolyDialogWindow(status, evt_type, step_id, data)
	if status == true then
		if not self.monopoly_dialog_wnd then
			self.monopoly_dialog_wnd = MonopolyDialogWindow.New()
		end
		if self.monopoly_dialog_wnd:isOpen() == false then
			self.monopoly_dialog_wnd:open(evt_type, step_id, data)
		end
	else
		if self.monopoly_dialog_wnd then
			self.monopoly_dialog_wnd:close()
			self.monopoly_dialog_wnd = nil
			self:checkShowWaitTips()
		end
	end
end

-- 打开圣夜奇境提示弹窗
function MonopolyController:openMonopolyTips(status, data)
	if status == true then
		if not self.monopoly_tips then
			self.monopoly_tips = MonopolyTips.New()
		end
		if self.monopoly_tips:isOpen() == false then
			self.monopoly_tips:open(data)
		end
	else
		if self.monopoly_tips then
			self.monopoly_tips:close()
			self.monopoly_tips = nil
		end
	end
end

-- 打开选择步数界面
function MonopolyController:openMonopolyChoseStepWindow(status)
	if status == true then
		if not self.chose_step_wnd then
			self.chose_step_wnd = MonopolyChoseStepWindow.New()
		end
		if self.chose_step_wnd:isOpen() == false then
			self.chose_step_wnd:open()
		end
	else
		if self.chose_step_wnd then
			self.chose_step_wnd:close()
			self.chose_step_wnd = nil
			self:checkShowWaitTips()
		end
	end
end

-- 打开南瓜机界面
function MonopolyController:openMonopolyPumpkinWindow(status)
	if status == true then
		if not self.monopoly_pumpkin_wnd then
			self.monopoly_pumpkin_wnd = MonopolyPumpkinWindow.New()
		end
		if self.monopoly_pumpkin_wnd:isOpen() == false then
			self.monopoly_pumpkin_wnd:open()
		end
	else
		if self.monopoly_pumpkin_wnd then
			self.monopoly_pumpkin_wnd:close()
			self.monopoly_pumpkin_wnd = nil
			self:checkShowWaitTips()
		end
	end
end

-- 打开猜拳界面
function MonopolyController:openMonopolyMorraWindow(status)
	if status == true then
		if not self.monopoly_morra_wnd then
			self.monopoly_morra_wnd = MonopolyMorraWindow.New()
		end
		if self.monopoly_morra_wnd:isOpen() == false then
			self.monopoly_morra_wnd:open()
		end
	else
		if self.monopoly_morra_wnd then
			self.monopoly_morra_wnd:close()
			self.monopoly_morra_wnd = nil
			self:checkShowWaitTips()
		end
	end
end

-- 排行榜界面
function MonopolyController:openMonopolyRankWindow( status, step_id, view_type )
	if status == true then
		if not self.monopoly_rank_wnd then
			self.monopoly_rank_wnd = MonopolyRankWindow.New()
		end
		if self.monopoly_rank_wnd:isOpen() == false then
			self.monopoly_rank_wnd:open(step_id, view_type)
		end
	else
		if self.monopoly_rank_wnd then
			self.monopoly_rank_wnd:close()
			self.monopoly_rank_wnd = nil
		end
	end
end

-- 图例展示
function MonopolyController:openMonopolyItemShowWindow(status)
	if status == true then
		if not self.monopoly_item_wnd then
			self.monopoly_item_wnd = MonopolyShowItemWindow.New()
		end
		if self.monopoly_item_wnd:isOpen() == false then
			self.monopoly_item_wnd:open()
		end
	else
		if self.monopoly_item_wnd then
			self.monopoly_item_wnd:close()
			self.monopoly_item_wnd = nil
		end
	end
end

-- 打开大富翁战斗事件的怪物信息
function MonopolyController:openMonopolyMasterInfoWindow(status, evt_type, step_id)
	if status == true then
		if not self.master_info_wnd then
			self.master_info_wnd = MonopolyMasterInfoWindow.New()
		end
		if self.master_info_wnd:isOpen() == false then
			self.master_info_wnd:open(evt_type, step_id)
		end
	else
		if self.master_info_wnd then
			self.master_info_wnd:close()
			self.master_info_wnd = nil
		end
	end
end

-- 检测显示tips
function MonopolyController:checkShowWaitTips()
	-- 以下界面都不存在，则通知场景显示tips，否则都在以下界面关闭时再触发
	if not self.monopoly_dialog_wnd and not self.chose_step_wnd and not self.monopoly_pumpkin_wnd and not self.monopoly_morra_wnd then
		if self.monopoly_main_scene then -- 当前没在大富翁场景，则无需显示tips，直接显示奖励
			GlobalEvent:getInstance():Fire(MonopolyEvent.Get_Show_Tips_Event)
		else
			self:checkShowWaitAward()
		end
	end
end

-- 检测显示奖励
function MonopolyController:checkShowWaitAward()
	local award_data = self.model:getWaitShowAwardData()
	local items = {}
	for i,v in ipairs(award_data or {}) do
		items[i] = {}
		items[i].bid = v.base_id
		items[i].num = v.num
	end
	if next(items) ~= nil then
		MainuiController:getInstance():openGetItemView(true, items, 0, {is_backpack = true}, MainuiConst.item_open_type.normal)
	end
	self.model:clearWaitShowAwardData()
end

function MonopolyController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end