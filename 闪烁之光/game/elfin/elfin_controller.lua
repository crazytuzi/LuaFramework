-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2019-08-13
-- --------------------------------------------------------------------
ElfinController = ElfinController or BaseClass(BaseController)

function ElfinController:config()
    self.model = ElfinModel.New(self)
	self.dispather = GlobalEvent:getInstance()
	self.elfin_awards = {}
end

function ElfinController:getModel()
    return self.model
end

function ElfinController:registerEvents()
	if self.init_role_event == nil then
        self.init_role_event = GlobalEvent:getInstance():Bind(EventId.ROLE_CREATE_SUCCESS, function()
            GlobalEvent:getInstance():UnBind(self.init_role_event)
            self.init_role_event = nil

            self.role_vo = RoleController:getInstance():getRoleVo()
            -- 监听vip等级更新，计算红点
            if not self.role_lev_event and self.role_vo then
                self.role_lev_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value) 
                    if key == "vip_lev" then
                        self.model:calculateElfinHatchLvupRedStatus()
                    end
                end)
            end
        end)
    end

	-- 物品数量变化
    if not self.goods_add_event then
        self.goods_add_event = GlobalEvent:getInstance():Bind(BackpackEvent.ADD_GOODS, function(bag_code, item_list) 
            if bag_code ~= BackPackConst.Bag_Code.BACKPACK then return end
            self:checkNeedUpdateRedStatus(item_list)
        end)
    end
    if not self.goods_modify_event then
        self.goods_modify_event = GlobalEvent:getInstance():Bind(BackpackEvent.MODIFY_GOODS_NUM, function(bag_code, item_list) 
            if bag_code ~= BackPackConst.Bag_Code.BACKPACK then return end
            self:checkNeedUpdateRedStatus(item_list)
        end)
    end
    if not self.goods_delete_event then
        self.goods_delete_event = GlobalEvent:getInstance():Bind(BackpackEvent.DELETE_GOODS, function(bag_code, item_list) 
            if bag_code ~= BackPackConst.Bag_Code.BACKPACK then return end
            self:checkNeedUpdateRedStatus(item_list)
        end)
    end
end

function ElfinController:registerProtocals()
	self:RegisterProtocal(26500, "handle26500")     -- 精灵孵化信息
	self:RegisterProtocal(26501, "handle26501")     -- 精灵孵化信息更新
	self:RegisterProtocal(26502, "handle26502")     -- 精灵孵化器升级
	self:RegisterProtocal(26535, "handle26535")     -- 精灵孵化器激活s
	
	self:RegisterProtocal(26503, "handle26503")     -- 请求孵化精灵
	self:RegisterProtocal(26504, "handle26504")     -- 请求加速孵化精灵
	self:RegisterProtocal(26505, "handle26505")     -- 停止孵化精灵
	self:RegisterProtocal(26506, "handle26506")     -- 领取孵化产物
	self:RegisterProtocal(26507, "handle26507")     -- 购买精灵道具
	self:RegisterProtocal(26508, "handle26508")     -- 精灵融合
	self:RegisterProtocal(26509, "handle26509")     -- 精灵图鉴

	self:RegisterProtocal(26510, "handle26510")     -- 古树信息
	self:RegisterProtocal(26511, "handle26511")     -- 古树升级
	self:RegisterProtocal(26512, "handle26512")     -- 古树进阶
	self:RegisterProtocal(26513, "handle26513")     -- 古树布置精灵
	self:RegisterProtocal(26514, "handle26514")     -- 古树批量布置精灵
	self:RegisterProtocal(26520, "handle26520")     -- 推送新激活的精灵

	self:RegisterProtocal(26550, "handle26550")     -- 精灵召唤数据
	self:RegisterProtocal(26551, "handle26551")     -- 精灵召唤
	self:RegisterProtocal(26552, "handle26552")     -- 领取保底礼包
	self:RegisterProtocal(26553, "handle26553")     -- 精灵抽奖结果
	self:RegisterProtocal(26554, "handle26554")     -- 设置幸运精灵（成功推送26550）

	
	self:RegisterProtocal(26555, "handle26555")     -- 精灵布阵信息
	self:RegisterProtocal(26556, "handle26556")     -- 精灵方案信息
	self:RegisterProtocal(26557, "handle26557")     -- 精灵方案保存
	self:RegisterProtocal(26558, "handle26558")     -- 精灵方案名字修改
	self:RegisterProtocal(26559, "handle26559")     -- 精灵方案信息（不能申请）
	self:RegisterProtocal(26560, "handle26560")     -- 精灵布阵自主保存
	self:RegisterProtocal(26561, "handle26561")     -- 精灵布阵使用方案保存
	self:RegisterProtocal(26562, "handle26562")     -- 购买精灵方案
    self:RegisterProtocal(26563, "handle26563")     -- 消耗精灵时是否需要弹提示框
	self:RegisterProtocal(26564, "handle26564")     -- 多队伍保存精灵布阵队伍顺序调整（跨服竞技场、巅峰冠军赛）

end

-- 请求精灵孵化信息
function ElfinController:sender26500(  )
    self:SendProtocal(26500, {})
end

function ElfinController:handle26500( data )
	if data.sprite_hatchs then
		self.model:setElfinHatchList(data.sprite_hatchs)
		
		GlobalEvent:getInstance():Fire(ElfinEvent.Get_Elfin_Hatch_Data_Event)
	end
	if data.info then
		self.model:setElfinBuyInfo(data.info)
	end
end

-- 更新灵窝数据（也可能是新增）
function ElfinController:handle26501( data )
	if data.sprite_hatch then
		self.model:updateElfinHatchData(data.sprite_hatch)
	end
end

-- 请求孵化器升级
function ElfinController:sender26502( id )
	local protocal = {}
    protocal.id = id
    self:SendProtocal(26502, protocal)
end

function ElfinController:handle26502( data )
	if data.msg then
		message(data.msg)
	end
	if data.result == 1 then
		local new_data = {}
		new_data.id = data.id
		new_data.lev = data.lev
		self.model:updateOneElfinHatchData(new_data)
		self:openElfinLvUpWindow(true, data.lev)
	end
end

-- 请求开始孵化
function ElfinController:sender26503( id, item_bid )
	local protocal = {}
    protocal.id = id
    protocal.item_bid = item_bid
    self:SendProtocal(26503, protocal)
end

function ElfinController:handle26503( data )
	if data.msg then
		message(data.msg)
	end
end

-- 请求加速孵化
function ElfinController:sender26504( id, item_bid, item_num, _type )
	local protocal = {}
    protocal.id = id
    protocal.item_bid = item_bid
    protocal.item_num = item_num
    protocal.type = _type or 0
    self:SendProtocal(26504, protocal)
end

function ElfinController:handle26504( data )
	if data.msg then
		message(data.msg)
	end
	-- 使用道具加速成功
	if data.result == 1 then
		GlobalEvent:getInstance():Fire(ElfinEvent.Use_Item_Hatch_Event, data.id)
	end
end

-- 请求停止孵化精灵
function ElfinController:sender26505( id )
	local protocal = {}
    protocal.id = id
    self:SendProtocal(26505, protocal)
end

function ElfinController:handle26505( data )
	if data.msg then
		message(data.msg)
	end
end

-- 请求领取孵化产物
function ElfinController:sender26506( id )
	local protocal = {}
    protocal.id = id
    self:SendProtocal(26506, protocal)
end

function ElfinController:handle26506( data )
	if data.msg then
		message(data.msg)
	end
	if data.result == 1 and data.awards then
		table.insert(self.elfin_awards, data.awards)
		self:checkElfinGain()
	end
end

-- 精灵孵化器激活s
function ElfinController:sender26535( id )
	local protocal = {}
	protocal.id = id
    self:SendProtocal(26535, protocal)
end

function ElfinController:handle26535( data )
	if data.flag == 1 then
		self:openElfinHatchUnlockPanel(false)
		self:openElfinLvUpWindow(true, data.id)
	end
	
	if data.msg then
		message(data.msg)
	end
end


-- 请求购买精灵蛋/砸蛋道具
function ElfinController:sender26507( _type, item_id, num, hatch_id )
	-- 标识是否购买成功后直接孵化
	if hatch_id then
		self.hatch_egg_bid_flag = item_id
		self.hatch_id_flag = hatch_id
	end

	local protocal = {}
    protocal.type = _type
    protocal.item_id = item_id
    protocal.num = num
    self:SendProtocal(26507, protocal)
end

function ElfinController:handle26507( data )
	if data.msg then
		message(data.msg)
	end
	if data.result == 1 and data.count and data.item_id then
		self.model:updateElfinBuyInfoByBid(data.item_id, data.count)
		GlobalEvent:getInstance():Fire(ElfinEvent.Buy_Elfin_Item_Success_Event, data.item_id)

		-- 购买成功后直接开始孵化
		if self.hatch_id_flag and self.hatch_egg_bid_flag and self.hatch_egg_bid_flag == data.item_id then
			self:sender26503(self.hatch_id_flag, data.item_id)
			self.hatch_egg_bid_flag = nil
			self.hatch_id_flag = nil
			self:openElfSelectItemWindow(false)
		end
	end
end

-- 请求精灵融合
function ElfinController:sender26508( item_bid, num, pos )
	local protocal = {}
    protocal.item_bid = item_bid
    protocal.num = num
    protocal.pos = pos
    self:SendProtocal(26508, protocal)
end

function ElfinController:handle26508( data )
	if data.msg then
		message(data.msg)
	end
	-- 融合成功，关闭融合界面
	if data.result == 1 then
		self:openElfinCompoundWindow(false)
		self:openElfinEggSyntheticPanel(false)
	end
end

-- 请求精灵图鉴数据
function ElfinController:sender26509(  )
	self:SendProtocal(26509, {})
end

function ElfinController:handle26509( data )
	if data.awards then
		self.model:setActivatedElfinList(data.awards)
		GlobalEvent:getInstance():Fire(ElfinEvent.Get_Activated_Elfin_Event)
	end
end

-- 请求古树信息
function ElfinController:sender26510(  )
	self:SendProtocal(26510, {})
end

function ElfinController:handle26510( data )
	self.model:setElfinTreeData(data)
	GlobalEvent:getInstance():Fire(ElfinEvent.Get_Elfin_Tree_Data_Event)
end

-- 请求古树升级
function ElfinController:sender26511(  )
	self:SendProtocal(26511, {})
end

function ElfinController:handle26511( data )
	if data.msg then
		message(data.msg)
	end
	if data.result == 1 then
		GlobalEvent:getInstance():Fire(ElfinEvent.Elfin_Tree_Lv_Up_Event)
	end
end

-- 请求古树进阶
function ElfinController:sender26512(  )
	self:SendProtocal(26512, {})
end

function ElfinController:handle26512( data )
	if data.msg then
		message(data.msg)
	end

end

-- 请求布置精灵
function ElfinController:sender26513( pos, item_bid )
	local protocal = {}
    protocal.pos = pos
    protocal.item_bid = item_bid
    self:SendProtocal(26513, protocal)
end

function ElfinController:handle26513( data )
	if data.msg then
		message(data.msg)
	end
    if data.result == TRUE then
        self:updateEflinDrama()
    end
end

-- 请求批量布置精灵
--@only_save 是否仅是保存(从 26560过来的 )
function ElfinController:sender26514( sprites , only_save)
	local protocal = {}
    protocal.sprites = sprites
    self:SendProtocal(26514, protocal)

    if not only_save then
        self.can_save_drama = true
    end
end

function ElfinController:handle26514( data )
	if self.can_save_drama then
		message(data.msg)
	end

    if data.result == TRUE and self.can_save_drama then
        self.can_save_drama = false
        self:updateEflinDrama()
    end
end

--更新剧情布阵
function ElfinController:updateEflinDrama()
    local data = self.model:getElfinTreeData()
    if data and data.sprites then
        self:send26560(PartnerConst.Fun_Form.Drama, data.sprites, 1 ,1 , true)
    end
end

-- 推送新激活的精灵
function ElfinController:handle26520( data )
	if data.awards then
		self.model:calculateElfinActivateRedStatus(data.awards)
	end
end

------------------------------------精灵召唤协议------------------------------------
-- 请求精灵召唤数据
function ElfinController:send26550(  )
	local protocal = {}
    self:SendProtocal(26550, protocal)
end

-- 精灵召唤数据
function ElfinController:handle26550( data )
	if data then
		self.model:setElfinSummonData(data)
		GlobalEvent:getInstance():Fire(ElfinEvent.Update_Elfin_Summon_Data_Event, data)
	end
end


-- 请求精灵召唤
function ElfinController:send26551( times, recruit_type ,is_return_gain)
	self.is_return_gain = is_return_gain	
	local protocal = {}
	protocal.times = times
	protocal.recruit_type = recruit_type
    self:SendProtocal(26551, protocal)
end

-- 精灵召唤获得
function ElfinController:handle26551( data )
	message(data.msg)
end

-- 请求领取礼包
function ElfinController:send26552( id )
	local protocal = {}
	protocal.id = id
    self:SendProtocal(26552, protocal)
end

-- 领取保底礼包
function ElfinController:handle26552( data )
	message(data.msg)
end

-- 精灵抽奖结果
function ElfinController:handle26553( data )
	TimesummonController:getInstance():openActionTimeElfinSummonGainWindow(false)
	TimesummonController:getInstance():openActionTimeElfinSummonGainWindow(true,data,TRUE,2)
	-- if self.is_return_gain == true then
	-- 	TimesummonController:getInstance():openActionTimeElfinSummonGainWindow(false)
	-- 	TimesummonController:getInstance():openActionTimeElfinSummonGainWindow(true,data,TRUE,2)
	-- 	GlobalEvent:getInstance():Fire(ElfinEvent.Update_Elfin_Item_Event, data)
	-- else
	-- 	GlobalEvent:getInstance():Fire(ElfinEvent.Update_Elfin_Summon_Rewards_Data_Event, data)
	-- end
	-- self.is_return_gain = false	
end

-- 设置幸运精灵（成功推送26550）
function ElfinController:send26554( lucky_ids )
	local protocal = {}
	protocal.lucky_ids = lucky_ids
    self:SendProtocal(26554, protocal)
end

-- 设置幸运精灵
function ElfinController:handle26554( data )
	message(data.msg)
end

-- 精灵布阵信息
function ElfinController:send26555( type )
	local protocal = {}
	protocal.type = type
    self:SendProtocal(26555, protocal)
end

-- 精灵布阵信息
function ElfinController:handle26555( data )
	GlobalEvent:getInstance():Fire(ElfinEvent.Elfin_Plan_From_Info_Event, data)
end

-- 精灵方案信息
function ElfinController:send26556(  )
	local protocal = {}
    self:SendProtocal(26556, protocal)
end
-- 精灵方案信息
function ElfinController:handle26556( data )
    self.model:setPlanData(data)
	GlobalEvent:getInstance():Fire(ElfinEvent.Elfin_Plan_Info_Event, data)
end

-- 精灵方案保存
function ElfinController:send26557( id, sprites, type, team )
	local protocal = {}
	protocal.id = id
	protocal.sprites = sprites
	protocal.type = type
	protocal.team = team or 1
    self:SendProtocal(26557, protocal)
end

-- 精灵方案保存
function ElfinController:handle26557( data )
	message(data.msg)
end

-- 精灵方案名字修改
function ElfinController:send26558( id, name )
	local protocal = {}
	protocal.id = id
	protocal.name = name
    self:SendProtocal(26558, protocal)
end

-- 精灵方案名字修改
function ElfinController:handle26558( data )
	message(data.msg)
end

-- 精灵方案信息（不能申请）
function ElfinController:handle26559( data )
	self.model:setPlanData({plan_list = {data}})
	GlobalEvent:getInstance():Fire(ElfinEvent.Elfin_Plan_Update_Event, data)
end

-- 精灵布阵自主保存
--@ only_save 从26514 过来的
function ElfinController:send26560( _type, sprites, team, flag, only_save)
	local protocal = {}
	protocal.type = _type
	protocal.sprites = sprites
    protocal.team = team or 1
	protocal.flag = flag or 1
    self:SendProtocal(26560, protocal)
    
    if _type == PartnerConst.Fun_Form.Drama and not only_save then
        self.sprites_26560 = sprites
    end
end

-- 精灵布阵自主保存
function ElfinController:handle26560( data )
    if data.type == PartnerConst.Fun_Form.Drama then
        if self.sprites_26560 then
            --剧情阵容的
            self:sender26514(self.sprites_26560, true)
            self.sprites_26560 = nil
            message(data.msg)
        end
    else
        if self.sprites_26560 == nil then
            message(data.msg)
        end
    end
   
    GlobalEvent:getInstance():Fire(ElfinEvent.Elfin_Plan_Save_From_Event, data)
end

-- 精灵布阵使用方案保存
function ElfinController:send26561( id, _type, team , sprites)
	local protocal = {}
	protocal.id = id
	protocal.type = _type
	protocal.team = team or 1
    self:SendProtocal(26561, protocal)

    if _type == PartnerConst.Fun_Form.Drama and sprites then
        self.sprites_26561 = sprites
    end
end

-- 精灵布阵使用方案保存
function ElfinController:handle26561( data )
	message(data.msg)
    if data.type == PartnerConst.Fun_Form.Drama and self.sprites_26561 then
        self:sender26514(self.sprites_26561, true)
        self.sprites_26561 = nil
    end
    GlobalEvent:getInstance():Fire(ElfinEvent.Elfin_Plan_Save_From_Event, data)
end

-- 购买精灵方案
function ElfinController:send26562( id )
	local protocal = {}
	protocal.id = id
    self:SendProtocal(26562, protocal)
end

-- 购买精灵方案
function ElfinController:handle26562( data )
	message(data.msg)
	if data.flag == TRUE then
		GlobalEvent:getInstance():Fire(ElfinEvent.Elfin_Plan_Buy_Event, data)
	end
end

-- 消耗精灵时是否需要弹提示框
function ElfinController:send26563( base_id, num )
    local protocal = {}
    protocal.base_id = base_id
    protocal.num = num
    self:SendProtocal(26563, protocal)
end

-- 购买精灵方案
function ElfinController:handle26563( data )
    GlobalEvent:getInstance():Fire(ElfinEvent.Elfin_Plan_Must_Tips_Event, data)
end

-- 多队伍保存精灵布阵队伍顺序调整（跨服竞技场、巅峰冠军赛）
function ElfinController:send26564( _type, team_list )
	local protocal = {}
	protocal.type = _type
	protocal.team_list = team_list
    self:SendProtocal(26564, protocal)
end

-- 购买精灵方案
function ElfinController:handle26564( data )
    message(data.msg)
end

-- 精灵方案管理
function ElfinController:openElfinFightPlanPanel(status, setting )
	if status == true then
		if not self.elfin_fight_plan_panel then
			self.elfin_fight_plan_panel = ElfinFightPlanPanel.New()
		end
		if self.elfin_fight_plan_panel:isOpen() == false then
			self.elfin_fight_plan_panel:open(setting)
		end
	else
		if self.elfin_fight_plan_panel then
			self.elfin_fight_plan_panel:close()
			self.elfin_fight_plan_panel = nil
		end
	end
end
-- 精灵方案选择提示
function ElfinController:openElfinFightPlanChooseTips(status, setting )
	if status == true then
		if not self.elfin_fight_plan_choose_tips then
			self.elfin_fight_plan_choose_tips = ElfinFightPlanChooseTips.New()
		end
		if self.elfin_fight_plan_choose_tips:isOpen() == false then
			self.elfin_fight_plan_choose_tips:open(setting)
		end
	else
		if self.elfin_fight_plan_choose_tips then
			self.elfin_fight_plan_choose_tips:close()
			self.elfin_fight_plan_choose_tips = nil
		end
	end
end
-- 精灵方案保存tips
function ElfinController:openElfinFightPlanSaveTips(status, setting )
	if status == true then
		if not self.elfin_fight_plan_save_tips then
			self.elfin_fight_plan_save_tips = ElfinFightPlanSaveTips.New()
		end
		if self.elfin_fight_plan_save_tips:isOpen() == false then
			self.elfin_fight_plan_save_tips:open(setting)
		end
	else
		if self.elfin_fight_plan_save_tips then
			self.elfin_fight_plan_save_tips:close()
			self.elfin_fight_plan_save_tips = nil
		end
	end
end

-------------- @ 红点相关
-- 监听当前古树升级、进阶消耗的物品数量变化、精灵的数量变化
function ElfinController:checkNeedUpdateRedStatus( item_list )
	if item_list == nil or next(item_list) == nil then return end
	local cost_bid_list = self.model:getElfinTreeCostBidList()
	local com_cost_bid_list = self.model:getElfinCompoundCostBidList()
	local is_check_uplv = false  -- 是否更新古树升级、进阶的红点
	local is_check_elfin = false -- 是否要更新古树放置精灵的红点
	local is_check_com = false   -- 是否要更新上阵精灵合成的红点
	local is_check_egg = false   -- 是否要更新可孵化的灵窝和蛋的红点
	for k,v in pairs(item_list) do
		if v.config then
			if BackPackConst.checkIsElfin(v.config.type) then
				is_check_elfin = true
			end
			if BackPackConst.checkIsElfinEgg(v.config.type) then
				is_check_egg = true
			end
			if cost_bid_list and next(cost_bid_list) ~= nil then
				for _,id in pairs(cost_bid_list) do
					if id == v.config.id then
						is_check_uplv = true
						break
					end
				end
			end
			if com_cost_bid_list and next(com_cost_bid_list) ~= nil then
				for _,id in pairs(com_cost_bid_list) do
					if id == v.config.id then
						is_check_com = true
						break
					end
				end
			end
        end
        if is_check_uplv and is_check_elfin and is_check_com and is_check_egg then
        	break
        end
	end
	if is_check_uplv then
		self.model:calculateTreeUplvRedStatus()
	end
	if is_check_elfin then
		self.model:calculateTreePutElfinRedStatus()
		self.model:calculateElfinHigherRedStatus()
	end
	if is_check_com then
		self.model:calculateElfinCompoundRedStatus()
	end
	if is_check_egg then
		self.model:calculateElfinHatchEggRedStatus()
	end
end

-------------------@ 界面相关
-- 打开获得精灵界面
function ElfinController:openElfGainWindow( status, data )
	if status == true then
		if not self.elfin_gain_wnd then
			self.elfin_gain_wnd = ElfinGainWindow.New()
		end
		if self.elfin_gain_wnd:isOpen() == false then
			self.elfin_gain_wnd:open(data)
		end
	else
		if self.elfin_gain_wnd then
			self.elfin_gain_wnd:close()
			self.elfin_gain_wnd = nil
			delayOnce(function()
				self:checkElfinGain()
			end, 0.2)
		end
	end
end

-- 打开精灵/锤子选择界面
function ElfinController:openElfSelectItemWindow( status, setting )
	if status == true then
		if not self.elfin_select_item_wnd then
			self.elfin_select_item_wnd = ElfinSelectItemWindow.New()
		end
		if self.elfin_select_item_wnd:isOpen() == false then
			self.elfin_select_item_wnd:open(setting)
		end
	else
		if self.elfin_select_item_wnd then
			self.elfin_select_item_wnd:close()
			self.elfin_select_item_wnd = nil
		end
		self.hatch_egg_bid_flag = nil
		self.hatch_id_flag = nil
	end
end

-- 引导需要
function ElfinController:getElfinSelectRoot()
	if self.elfin_select_item_wnd then
		return self.elfin_select_item_wnd.root_wnd
	end
end

-- 检测精灵蛋孵化获得弹窗
function ElfinController:checkElfinGain()
	if self.elfin_gain_wnd and self.elfin_gain_wnd:isOpen() == true then
		return
	end
	if self.elfin_awards and next(self.elfin_awards or {}) ~= nil then
		local awards = table.remove(self.elfin_awards, 1)
		if awards then
			self:openElfGainWindow(true, awards)
		end
	end
end


-- 特权灵窝提示弹窗
function ElfinController:openElfinPrivilegeWindow( status )
	if status == true then
		if not self.elfin_privilege_wnd then
			self.elfin_privilege_wnd = ElfinPrivilegeWindow.New()
		end
		if self.elfin_privilege_wnd:isOpen() == false then
			self.elfin_privilege_wnd:open()
		end
	else
		if self.elfin_privilege_wnd then
			self.elfin_privilege_wnd:close()
			self.elfin_privilege_wnd = nil
		end
	end
end

-- 打开精灵图鉴
function ElfinController:openElfinBookWindow( status )
	if status == true then
		if not self.elfin_book_wnd then
			self.elfin_book_wnd = ElfinBookWindow.New()
		end
		if self.elfin_book_wnd:isOpen() == false then
			self.elfin_book_wnd:open()
		end
	else
		if self.elfin_book_wnd then
			self.elfin_book_wnd:close()
			self.elfin_book_wnd = nil
		end
	end
end

-- 打开召唤许愿池
function ElfinController:openElfinWishWindow( status,data )
	if status == true then
		if not self.elfin_wish_wnd then
			self.elfin_wish_wnd = ElfinWishWindow.New()
		end
		if self.elfin_wish_wnd:isOpen() == false then
			self.elfin_wish_wnd:open(data)
		end
	else
		if self.elfin_wish_wnd then
			self.elfin_wish_wnd:close()
			self.elfin_wish_wnd = nil
		end
	end
end

-- 打开精灵蛋合成界面
function ElfinController:openElfinEggSyntheticPanel( status ,data)
	if status == true then
		if not self.elfin_egg_synthetic_wnd then
			self.elfin_egg_synthetic_wnd = ElfinEggSyntheticPanel.New()
		end
		if self.elfin_egg_synthetic_wnd:isOpen() == false then
			self.elfin_egg_synthetic_wnd:open(data)
		end
	else
		if self.elfin_egg_synthetic_wnd then
			self.elfin_egg_synthetic_wnd:close()
			self.elfin_egg_synthetic_wnd = nil
		end
	end
end

-- 打开精灵窝解锁s界面
function ElfinController:openElfinHatchUnlockPanel( status ,data)
	if status == true then
		if not self.elfin_hatch_unlock_wnd then
			self.elfin_hatch_unlock_wnd = ElfinHatchUnlockPanel.New()
		end
		if self.elfin_hatch_unlock_wnd:isOpen() == false then
			self.elfin_hatch_unlock_wnd:open(data)
		end
	else
		if self.elfin_hatch_unlock_wnd then
			self.elfin_hatch_unlock_wnd:close()
			self.elfin_hatch_unlock_wnd = nil
		end
	end
end



-- 打开精灵展示界面
function ElfinController:openElfinInfoWindow( status, data )
	if status == true then
		if not self.elfin_info_wnd then
			self.elfin_info_wnd = ElfinInfoWindow.New()
		end
		if self.elfin_info_wnd:isOpen() == false then
			self.elfin_info_wnd:open(data)
		end
	else
		if self.elfin_info_wnd then
			self.elfin_info_wnd:close()
			self.elfin_info_wnd = nil
		end
		GlobalEvent:getInstance():Fire(ElfinEvent.Elfin_Check_Show_Tips_Event)--检测是否继续弹tips
	end
end

-- 打开精灵古树唤醒界面
function ElfinController:openElfinTreeStepWindow( status )
	if status == true then
		if not self.tree_step_wnd then
			self.tree_step_wnd = ElfinTreeStepWindow.New()
		end
		if self.tree_step_wnd:isOpen() == false then
			self.tree_step_wnd:open()
		end
	else
		if self.tree_step_wnd then
			self.tree_step_wnd:close()
			self.tree_step_wnd = nil
		end
	end
end

-- 打开精灵古树唤醒成功界面
function ElfinController:openElfinTreeRouseWindow( status, old_data, new_data )
	if status == true then
		if not self.tree_rouse_wnd then
			self.tree_rouse_wnd = ElfinTreeRouseWindow.New()
		end
		if self.tree_rouse_wnd:isOpen() == false then
			self.tree_rouse_wnd:open(old_data, new_data)
		end
	else
		if self.tree_rouse_wnd then
			self.tree_rouse_wnd:close()
			self.tree_rouse_wnd = nil
		end
	end
end

-- 打开精灵选择界面
function ElfinController:openElfinChooseWindow( status, setting )
	if status == true then
		if not self.elfin_choose_wnd then
			self.elfin_choose_wnd = ElfinChooseWindow.New()
		end
		if self.elfin_choose_wnd:isOpen() == false then
			self.elfin_choose_wnd:open(setting)
		end
	else
		if self.elfin_choose_wnd then
			self.elfin_choose_wnd:close()
			self.elfin_choose_wnd = nil
		end
	end
end

-- 打开精灵融合界面
function ElfinController:openElfinCompoundWindow( status, elfin_bid, elfin_pos )
	if status == true then
		if not self.elfin_compound_wnd then
			self.elfin_compound_wnd = ElfinCompoundWindow.New()
		end
		if self.elfin_compound_wnd:isOpen() == false then
			self.elfin_compound_wnd:open(elfin_bid, elfin_pos)
		end
	else
		if self.elfin_compound_wnd then
			self.elfin_compound_wnd:close()
			self.elfin_compound_wnd = nil
		end
	end
end

-- 打开灵窝升级提示界面
function ElfinController:openElfinLvUpTipsWindow( status, hatch_id, hatch_lev )
	if status == true then
		if not self.elfin_lv_tips_wnd then
			self.elfin_lv_tips_wnd = ElfinLvUpTipsWindow.New()
		end
		if self.elfin_lv_tips_wnd:isOpen() == false then
			self.elfin_lv_tips_wnd:open(hatch_id, hatch_lev)
		end
	else
		if self.elfin_lv_tips_wnd then
			self.elfin_lv_tips_wnd:close()
			self.elfin_lv_tips_wnd = nil
		end
	end
end

-- 打开灵窝升级弹窗
function ElfinController:openElfinLvUpWindow( status, id )
	if status == true then
		if not self.elfin_lv_up_wnd then
			self.elfin_lv_up_wnd = ElfinLvUpWindow.New()
		end
		if self.elfin_lv_up_wnd:isOpen() == false then
			self.elfin_lv_up_wnd:open(id)
		end
	else
		if self.elfin_lv_up_wnd then
			self.elfin_lv_up_wnd:close()
			self.elfin_lv_up_wnd = nil
		end
	end
end

-- 打开精灵调整界面
function ElfinController:openElfinAdjustWindow( status, setting )
	if status == true then
		if not self.elfin_adjust_wnd then
			self.elfin_adjust_wnd = ElfinAdjustWindow.New()
		end
		if self.elfin_adjust_wnd:isOpen() == false then
			self.elfin_adjust_wnd:open(setting)
		end
	else
		if self.elfin_adjust_wnd then
			self.elfin_adjust_wnd:close()
			self.elfin_adjust_wnd = nil
		end
	end
end

function ElfinController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end