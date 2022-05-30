-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2019-03-07
-- --------------------------------------------------------------------
HalidomController = HalidomController or BaseClass(BaseController)

function HalidomController:config()
    self.model = HalidomModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function HalidomController:getModel()
    return self.model
end

function HalidomController:registerEvents()
	if self.init_role_event == nil then
        self.init_role_event = GlobalEvent:getInstance():Bind(EventId.ROLE_CREATE_SUCCESS, function()
            GlobalEvent:getInstance():UnBind(self.init_role_event)
            self.init_role_event = nil

            self.role_vo = RoleController:getInstance():getRoleVo()
            -- 监听金币更新，计算红点
            if not self.role_lev_event and self.role_vo then
                self.role_lev_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value) 
                    if key == "coin" then
                        self.model:calculateHalidomRedStatus()
                    end
                end)
            end

            -- 上线时请求
            --self:sender22200()
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

function HalidomController:registerProtocals()
	self:RegisterProtocal(22200, "handle22200") -- 圣物数据
	self:RegisterProtocal(22201, "handle22201") -- 圣物数据更新
	self:RegisterProtocal(22202, "handle22202") -- 激活圣物
	self:RegisterProtocal(22203, "handle22203") -- 注能圣物
	self:RegisterProtocal(22204, "handle22204") -- 进阶圣物
	self:RegisterProtocal(22205, "handle22205") -- 圣物升级
end

-- 请求圣物数据
function HalidomController:sender22200(  )
	local protocal = {}
    self:SendProtocal(22200, protocal)
end

function HalidomController:handle22200( data )
	if data then
		self.model:setAllHalidomData(data.list)
		GlobalEvent:getInstance():Fire(HalidomEvent.Get_Halidom_Data_Event)
	end
end

-- 圣物数据更新
function HalidomController:handle22201( data )
	if data then
		local is_have = self.model:updateHalidomData(data)
		GlobalEvent:getInstance():Fire(HalidomEvent.Update_Halidom_Data_Event, data.id)
		if not is_have then -- 新增的，则为解锁
			self:openHalidomUnlockWindow(true, data.id)
		end
	end
end

-- 请求激活圣物
function HalidomController:sender22202( id, list )
	local protocal = {}
	protocal.id = id
	protocal.list = list
    self:SendProtocal(22202, protocal)
end

function HalidomController:handle22202( data )
	if data then
		message(data.msg)
	end
end

-- 	请求升级圣物
function HalidomController:sender22203( id )
	local protocal = {}
	protocal.id = id
    self:SendProtocal(22203, protocal)
end

function HalidomController:handle22203( data )
	if data then
		message(data.msg)
	end
end

-- 请求进阶圣物
function HalidomController:sender22204( id, list1, list2 )
	local protocal = {}
	protocal.id = id
	protocal.list1 = list1
	protocal.list2 = list2
    self:SendProtocal(22204, protocal)
end

function HalidomController:handle22204( data )
	if data then
		message(data.msg)
		if data.code == TRUE then
			self:openHalidomUpStepWindow(true, data.id)
		end
	end
end

-- 圣物升级
function HalidomController:handle22205( data )
	if data and data.id then
		self:openHalidomUpLvWindow(true, data.id)
	end
end

-- 道具数量变化计算红点
function HalidomController:checkNeedUpdateRedStatus( item_list )
	if item_list == nil or next(item_list) == nil then return end
	local cost_cfg = Config.HalidomData.data_const["halidom_cost"]
	if cost_cfg then
		local is_have = false
		for k,v in pairs(item_list) do
			if v.config then
				for _,id in pairs(cost_cfg.val or {}) do
					if id == v.config.id then
						is_have = true
						break
					end
				end
	        end
	        if is_have then
	        	break
	        end
		end
		if is_have then
			self.model:calculateHalidomRedStatus()
		end
	end
end

-------------------------------------------
-- @ 打开进阶成功界面
function HalidomController:openHalidomUpStepWindow( status, id )
	if status == true then
		if self.up_step_window == nil then
			self.up_step_window = HalidomUpStepWindow.New()
		end
		if self.up_step_window:isOpen() == false then
			self.up_step_window:open(id)
		end
	else
		if self.up_step_window then
			self.up_step_window:close()
		end
	end
end

-- @ 打开圣物升级界面
function HalidomController:openHalidomUpLvWindow( status, id )
	if status == true then
		if self.up_lv_window == nil then
			self.up_lv_window = HalidomUpLvWindow.New()
		end
		if self.up_lv_window:isOpen() == false then
			self.up_lv_window:open(id)
		end
	else
		if self.up_lv_window then
			self.up_lv_window:close()
		end
	end
end

-- @ 打开圣物激活界面
function HalidomController:openHalidomUnlockWindow( status, id )
	if status == true then
		if self.unlock_window == nil then
			self.unlock_window = HalidomUnlockWindow.New()
		end
		if self.unlock_window:isOpen() == false then
			self.unlock_window:open(id)
		end
	else
		if self.unlock_window then
			self.unlock_window:close()
		end
	end
end

-- 打开圣物进阶预览
function HalidomController:openHalidomStepPreView( status, id )
	if status == true then
		if self.step_pre_view == nil then
			self.step_pre_view = HalidomStepPreView.New()
		end
		if self.step_pre_view:isOpen() == false then
			self.step_pre_view:open(id)
		end
	else
		if self.step_pre_view then
			self.step_pre_view:close()
		end
	end
end

function HalidomController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end