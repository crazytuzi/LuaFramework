-- --------------------------------------------------------------------
-- 公会红包
--
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: cloud@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-07-16
-- --------------------------------------------------------------------
RedbagController = RedbagController or BaseClass(BaseController)

function RedbagController:config()
    self.model = RedbagModel.New(self)
    self.dispather = GlobalEvent:getInstance()
    self.red_bag_vo = nil --临时存储当前领的
end

function RedbagController:getModel()
    return self.model
end

function RedbagController:registerEvents()
       --角色数据创建完毕后，监听资产数据变化情况
    if not self.role_create_success then 
        self.role_create_success = GlobalEvent:getInstance():Bind(EventId.ROLE_CREATE_SUCCESS,function()
  
            GlobalEvent:getInstance():UnBind(self.role_create_success)
            self.role_create_success = nil
            
            self.role_vo = RoleController:getInstance():getRoleVo()
            --[[if self.role_vo.gid ~=0 and self.role_vo.gsrv_id ~="" then 
                self:sender13534()
            end--]]
            if self.role_vo then
                if self.role_update_event == nil then
                    self.role_update_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value)
                        if key == "gid" and value == 0 then
                            self.model:resetData()
                        end
                    end)
                end
            end
        end)
    end
    if not self.red_bg_event then
        self.red_bg_event = GlobalEvent:getInstance():Bind(MainuiEvent.CLOSE_ITEM_VIEW, function(data)
            if data and data.is_red_bag and data.is_red_bag == true then
                local info_data = self.model:getRedBagListById(data.info_data.id)
                if info_data ~= nil then
                    self:openLookWindow(true,info_data)
                end
            end
        end)
    end
    if not self.add_goods_event then
        self.add_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.ADD_GOODS, function(bag_code, data_list)
            if bag_code == BackPackConst.Bag_Code.BACKPACK then
                if self.model:getRebBagItemNumList() then
                    local list = self.model:getRebBagItemNumList()
                    for i, v in ipairs(list) do
                        for i1, v1 in pairs(data_list) do
                            if v and v.bid == v1.base_id then
                                self.model:checkRedBagRedPoint()
                            end
                        end
                    end
                end
            end
        end)
    end

    if not self.modify_goods_event then
        self.modify_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.MODIFY_GOODS_NUM, function(bag_code, data_list)
            if bag_code and bag_code == BackPackConst.Bag_Code.BACKPACK then 
                if self.model:getRebBagItemNumList() then
                    local list = self.model:getRebBagItemNumList()
                    for i, v in ipairs(list) do
                        for i1, v1 in pairs(data_list) do
                            if v and v.bid == v1.base_id  then
                                self.model:checkRedBagRedPoint()
                            end
                        end
                    end
                end
            end
        end)
    end

    if not self.delete_goods_event then
        self.delete_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.DELETE_GOODS, function(bag_code, data_list)
            if bag_code and bag_code == BackPackConst.Bag_Code.BACKPACK then 
                if self.model:getRebBagItemNumList() then
                    local list = self.model:getRebBagItemNumList()
                    for i, v in ipairs(list) do
                        for i1, v1 in pairs(data_list) do
                            if v and v.bid == v1.base_id  then
                                self.model:checkRedBagRedPoint()
                            end
                        end
                    end
                end
            end
        end)
    end
end

function RedbagController:registerProtocals()
    self:RegisterProtocal(13534, "handle13534")     --成员红包列表信息
    self:RegisterProtocal(13535, "handle13535")     --发放成员红包
    self:RegisterProtocal(13536, "handle13536")     --领取成员红包

    self:RegisterProtocal(13546, "handle13546")     -- 当前发放红包情况

    self:RegisterProtocal(13540, "handle13540")     --公会红包领取情况
    self:RegisterProtocal(13545, "handle13545")     --发红包排名
    
end
function RedbagController:openMainView(bool,extend_id)
    if bool == true then
        if isQingmingShield and isQingmingShield() then
            return
        end
        if not self.main_view then 
            self.main_view = RedBagWindow.New(extend_id)
        end
        if self.main_view and self.main_view:isOpen() == false then
            self.main_view:open()
        end

    else 
        if self.main_view then 
            self.main_view:close()
            self.main_view = nil
        end
    end
end
function RedbagController:openLookWindow(bool,data)
    if bool == true then
        if not self.look_window then 
            self.look_window = RedBagLookWindow.New(data)
        end
        if self.look_window and self.look_window:isOpen() == false then
            self.look_window:open()
        end

    else 
        if self.look_window then 
            self.look_window:close()
            self.look_window = nil
        end
    end
end

--成员红包列表信息
function RedbagController:sender13534()
    local protocal ={}
    self:SendProtocal(13534,protocal)
end

function RedbagController:handle13534( data )
    self.model:updateData(data)
end

-- 请求使用道具发放公会红包
function RedbagController:sender13535( type, loss_type )
    local protocal ={}
    protocal.type = type
    protocal.num = 1
    protocal.msg_id = 0
    protocal.loss_type = loss_type
    self:SendProtocal(13535,protocal)
end

function RedbagController:handle13535( data )
    if data then
        message(data.msg)
    end
end

--领取成员红包
function RedbagController:sender13536(id)
    local protocal ={}
    protocal.id = id
    self:SendProtocal(13536,protocal)
end
function RedbagController:handle13536(data)
    message(data.msg)
    if data.code == TRUE then
        self:openRegBagWindow(true,data)
    end
end

--公会红包领取情况
function RedbagController:sender13540(id)
    local protocal ={}
    protocal.id = id
    self:SendProtocal(13540,protocal)
end
function RedbagController:handle13540( data )
    GlobalEvent:getInstance():Fire(RedbagEvent.Get_List_Event,data)
end
--发红包排名
function RedbagController:sender13545()
    local protocal ={}
    self:SendProtocal(13545,protocal)
end
function RedbagController:handle13545( data )
    GlobalEvent:getInstance():Fire(RedbagEvent.Rank_List_Event,data)
end


function RedbagController:setRedBagVo(vo)
    self.red_bag_vo = vo
end
--打开红包特效界面
function RedbagController:openRegBagWindow(bool,data)
    if bool == true then
        if not self.open_window then
            self.open_window = RedBagOpenView.New()
        end
        if self.open_window and self.open_window:isOpen() == false then
            self.open_window:open(data)
        end
    else
        if self.open_window then
            self.open_window:close()
            self.open_window = nil
        end
    end
end

-- 请求红包数据
function RedbagController:send13546()
    self:SendProtocal(13546,{})
end

function RedbagController:handle13546(data)
    GlobalEvent:getInstance():Fire(RedbagEvent.Update_Red_Bag_Event, data.list) 
end


function RedbagController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end