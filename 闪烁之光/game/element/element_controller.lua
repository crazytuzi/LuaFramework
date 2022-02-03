-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2019-03-04
-- --------------------------------------------------------------------
ElementController = ElementController or BaseClass(BaseController)

function ElementController:config()
    self.model = ElementModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function ElementController:getModel()
    return self.model
end

function ElementController:registerEvents()
	--[[if self.init_role_event == nil then
        self.init_role_event = GlobalEvent:getInstance():Bind(EventId.ROLE_CREATE_SUCCESS, function()
            GlobalEvent:getInstance():UnBind(self.init_role_event)
            self.init_role_event = nil

            -- 上线时请求
            self:sender25000() -- 用于红点
        end)
    end--]] 
end

function ElementController:registerProtocals()
	self:RegisterProtocal(25000, "handle25000") -- 元素神殿基础数据
	self:RegisterProtocal(25001, "handle25001") -- 元素神殿挑战
	self:RegisterProtocal(25002, "handle25002") -- 元素神殿扫荡
	self:RegisterProtocal(25003, "handle25003") -- 购买挑战次数
	self:RegisterProtocal(25004, "handle25004") -- 挑战次数刷新
	self:RegisterProtocal(25005, "handle25005") -- 最大关卡数更新
end

-- 请求元素神殿基础信息
function ElementController:sender25000(  )
	local protocal = {}
    self:SendProtocal(25000, protocal)
end

function ElementController:handle25000( data )
	if data then
		self.model:setElementData(data)
		GlobalEvent:getInstance():Fire(ElementEvent.Update_Element_Data_Event)
	    if NEEDCHANGEENTERSTATUS == 3 and not self.first_enter then
	        self.first_enter  = true
        	MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.ElementWar)
	    end
	end
end

-- 请求挑战
function ElementController:sender25001( type, boss_id, formation_type, pos_info, hallows_id )
	local protocal = {}
	protocal.type = type
	protocal.boss_id = boss_id
	protocal.formation_type = formation_type
	protocal.pos_info = pos_info
	protocal.hallows_id = hallows_id
    self:SendProtocal(25001, protocal)
end

function ElementController:handle25001( data )
	if data then
		message(data.msg)
	end
end

-- 扫荡元素神殿
function ElementController:sender25002( type, boss_id )
	local protocal = {}
	protocal.type = type
	protocal.boss_id = boss_id
    self:SendProtocal(25002, protocal)
end

function ElementController:handle25002( data )
	if data then
		message(data.msg)
	end
end

-- 请求购买挑战次数
function ElementController:sender25003(  )
	local protocal = {}
    self:SendProtocal(25003, protocal)
end

function ElementController:handle25003( data )
	if data then
		message(data.msg)
		if data.code == 1 and self._temp_ele_type and self._temp_customs_id and self._temp_formation_type and self._temp_pos_info and self._temp_hallows_id then
			self:sender25001(self._temp_ele_type, self._temp_customs_id, self._temp_formation_type, self._temp_pos_info, self._temp_hallows_id)
			self._temp_ele_type = nil
			self._temp_customs_id = nil
			self._temp_formation_type = nil
			self._temp_pos_info = nil
			self._temp_hallows_id = nil
		elseif data.code == 1 and self._temp_type and self._temp_boss_id then
			self:sender25002(self._temp_type, self._temp_boss_id)
			self._temp_type = nil
			self._temp_boss_id = nil
		end
	end
end

-- 挑战次数相关数据刷新
function ElementController:handle25004( data )
	if data then
		self.model:updateElementCountData(data)
		GlobalEvent:getInstance():Fire(ElementEvent.Update_Element_Count_Event)
	end
end

-- 最大关卡数更新
function ElementController:handle25005( data )
	if data then
		self.model:updateElementCustomsData(data)
		GlobalEvent:getInstance():Fire(ElementEvent.Update_Element_Customs_Event)
	end
end

-- 检测挑战次数并且进入战斗
function ElementController:checkJoinHeavenBattle( ele_type, customs_id, formation_type, pos_info, hallows_id )
	if self.model:getLeftChallengeCount() > 0 then
		self:sender25001(ele_type, customs_id, formation_type, pos_info, hallows_id)
		HeroController:getInstance():openFormGoFightPanel(false)
	elseif self.model:getTodayLeftBuyCount() > 0 then
		local normal_buy_count = self.model:getNormalBuyCount()
		local buy_cfg = Config.ElementTempleData.data_buy_count[normal_buy_count + 1]
		local privilege_status = RoleController:getInstance():getModel():checkPrivilegeStatus(4) -- 特权激活状态
		if buy_cfg then
			local str = string.format(TI18N("挑战次数不足，是否消耗<img src=%s visible=true scale=0.3 />%d购买一次挑战次数并且进入战斗？"), PathTool.getItemRes(3), buy_cfg.cost)				
			CommonAlert.show( str, TI18N("确定"), function()
				-- 缓存布阵数据，购买次数成功返回后直接进入战斗
				self._temp_ele_type = ele_type
				self._temp_customs_id = customs_id
				self._temp_formation_type = formation_type
				self._temp_pos_info = pos_info
				self._temp_hallows_id = hallows_id
				self:sender25003()
				HeroController:getInstance():openFormGoFightPanel(false)
	    	end, TI18N("取消"), nil, CommonAlert.type.rich)
		elseif privilege_status == true then
			local buy_count = self.model:getPrivilegeBuyCount()
			local pri_cost = Config.ElementTempleData.data_privilege[buy_count+1]
			if pri_cost then
				local str = string.format(TI18N("挑战次数不足，是否消耗<img src=%s visible=true scale=0.3 />%d购买一次挑战次数并且进入战斗？"), PathTool.getItemRes(3), pri_cost)				
				CommonAlert.show( str, TI18N("确定"), function()
					-- 缓存布阵数据，购买次数成功返回后直接进入战斗
					self._temp_ele_type = ele_type
					self._temp_customs_id = customs_id
					self._temp_formation_type = formation_type
					self._temp_pos_info = pos_info
					self._temp_hallows_id = hallows_id
					self:sender25003()
					HeroController:getInstance():openFormGoFightPanel(false)
		    	end, TI18N("取消"), nil, CommonAlert.type.rich)
			end
		end
	else
		message(TI18N("挑战次数不足"))
		HeroController:getInstance():openFormGoFightPanel(false)
	end
end

-- 检测挑战次数并且进行扫荡
function ElementController:checkSweepHeaven( type, boss_id )
	if self.model:getLeftChallengeCount() > 0 then
		self:sender25002(type, boss_id)
	elseif self.model:getTodayLeftBuyCount() > 0 then
		local normal_buy_count = self.model:getNormalBuyCount()
		local buy_cfg = Config.ElementTempleData.data_buy_count[normal_buy_count + 1]
		local privilege_status = RoleController:getInstance():getModel():checkPrivilegeStatus(4) -- 特权激活状态
		if buy_cfg then
			local str = string.format(TI18N("挑战次数不足，是否消耗<img src=%s visible=true scale=0.3 />%d购买一次挑战次数并且进行扫荡？"), PathTool.getItemRes(3), buy_cfg.cost)				
			CommonAlert.show( str, TI18N("确定"), function()
				-- 缓存布阵数据，购买次数成功返回后直接进入战斗
				self._temp_type = type
				self._temp_boss_id = boss_id
				self:sender25003()
	    	end, TI18N("取消"), nil, CommonAlert.type.rich)
		elseif privilege_status == true then
			local buy_count = self.model:getPrivilegeBuyCount()
			local pri_cost = Config.ElementTempleData.data_privilege[buy_count+1]
			if pri_cost then
				local str = string.format(TI18N("挑战次数不足，是否消耗<img src=%s visible=true scale=0.3 />%d购买一次挑战次数并且进行扫荡？"), PathTool.getItemRes(3), pri_cost)				
				CommonAlert.show( str, TI18N("确定"), function()
					-- 缓存布阵数据，购买次数成功返回后直接进入战斗
					self._temp_type = type
					self._temp_boss_id = boss_id
					self:sender25003()
		    	end, TI18N("取消"), nil, CommonAlert.type.rich)
			end
		end
	else
		message(TI18N("挑战次数不足"))
	end
end

-------------------------@ 界面相关
-- 打开元素神殿主界面
function ElementController:openElementMainWindow( status , setting )
	if status == true then
		local is_open = self.model:checkElementIsOpen()
		if not is_open then
			return
		end

		if self.element_main_wnd == nil then
			self.element_main_wnd = ElementMainWindow.New()
		end
		if self.element_main_wnd:isOpen() == false then
			self.element_main_wnd:open(setting)
		end
	else
		if self.element_main_wnd then
			self.element_main_wnd:close()
			self.element_main_wnd = nil
		end
	end
end

-- 打开元素神殿的副本挑战界面
function ElementController:openElementEctypeWindow( status, data )
	if status == true then
		if self.element_ectype_wnd == nil then
			self.element_ectype_wnd = ElementEctypeWindow.New()
		end
		if self.element_ectype_wnd:isOpen() == false then
			self.element_ectype_wnd:open(data)
		end
	else
		if self.element_ectype_wnd then
			self.element_ectype_wnd:close()
			self.element_ectype_wnd = nil
		end
	end
end

-- 打开排行榜界面
function ElementController:openElementRankWindow( status, view_type, ele_type )
	if status == true then
		if self.element_rank_wnd == nil then
			self.element_rank_wnd = ElementRankWindow.New()
		end
		if self.element_rank_wnd:isOpen() == false then
			self.element_rank_wnd:open(view_type, ele_type)
		end
	else
		if self.element_rank_wnd then
			self.element_rank_wnd:close()
			self.element_rank_wnd = nil
		end
	end
end

function ElementController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end