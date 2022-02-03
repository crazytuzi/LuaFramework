-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-09-07
-- --------------------------------------------------------------------
BarrageController = BarrageController or BaseClass(BaseController)

function BarrageController:config()
    self.model = BarrageModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function BarrageController:getModel()
    return self.model
end

function BarrageController:registerEvents()
    if self.barrage_enter_event == nil then
        self.barrage_enter_event = GlobalEvent:getInstance():Bind(BarrageEvent.HandleBarrageType, function(status, type, extend_data)
            if not status then
                self:openMainView(false)
            else
                self:openMainView(true, type, extend_data)
            end
        end)
    end
end

function BarrageController:registerProtocals()
    self:RegisterProtocal(12732, "on12732") --发送弹幕
    self:RegisterProtocal(12733, "on12733") --接受弹幕信息
end

function BarrageController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end

--==============================--
--desc:打开弹幕主界面,根据类型去判断
--time:2017-09-07 07:31:59
--@status:
--@type:
--@return 
--==============================--
function BarrageController:openMainView(status, type, battle_type)
    if status == false then
        if self.barrage_view ~= nil then
            self.barrage_view:close()
            self.barrage_view = nil
        end
    else
        if self.barrage_view == nil then
            self.barrage_view = BarrageMainView.New(type)
        end
        if self.barrage_view and self.barrage_view:isOpen() == false then
            self.barrage_view:open(type,battle_type)
        end
    end
end

--是否显示弹幕按钮
function BarrageController:showWirteBtn( status )
    if not self.barrage_view then return end
    if status then
        self.barrage_view:showBtn(true)
    else
        self.barrage_view:showBtn(false)
    end
end

--==============================--
--desc:打开弹幕编辑面板
--time:2017-09-08 10:36:41
--@status:
--@return 
--==============================--
function BarrageController:openEditView(status,type)
    if status == false then
        if self.barrage_edit_view ~= nil then
            self.barrage_edit_view:close()
            self.barrage_edit_view = nil
        end
    else
        if self.barrage_edit_view == nil then
            self.barrage_edit_view = BarrageEditView.New(BarrageController:getInstance())
        end
        if self.barrage_edit_view and self.barrage_edit_view:isOpen() == false then
            self.barrage_edit_view:open(type)
        end
    end
end

--==============================--
--desc:通知服务端进入指定类型的弹幕
--time:2017-09-08 03:05:54
--@type:弹幕类型
--@is_push:是否需要推送历史信息
--@return 
--==============================--
function BarrageController:requestEnterBarrage(type, is_push)
    is_push = is_push or TRUE
    local protocal = {}
    protocal.type = type
    protocal.is_push = is_push
    self:SendProtocal(12730, protocal)  
end

--==============================--
--desc:通知服务端退出弹幕
--time:2017-09-08 03:07:30
--@return 
--==============================--
function BarrageController:requestExitBarrage()
    self:SendProtocal(12731, {})  
end

--==============================--
--desc:通知服务端退出弹幕(巅峰冠军赛)
--time:2017-09-08 03:07:30
--@return 
--==============================--
function BarrageController:requestArenaPeakExitBarrage()
    self:SendProtocal(12729, {})  
end

--==============================--
--desc:请求发送弹幕
--time:2017-09-08 03:09:28
--@type:
--@msg:
--@return 
--==============================--
function BarrageController:sendBarrageMsg(type, msg)
    local protocal = {}
    protocal.type = type
    protocal.msg = msg
    self:SendProtocal(12732, protocal)  
end
function BarrageController:on12732(data)
    message(data.msg)
    if data.code == TRUE then
        self:openEditView(false)
    end 
end

--==============================--
--desc:接受指定弹幕
--time:2017-09-08 03:11:32
--@data:
--@return 
--==============================--
function BarrageController:on12733(data)
    GlobalEvent:getInstance():Fire(BarrageEvent.UpdateBarrageData, data)
end

--==============================--
--desc:内存缓存各类型弹幕的是否显示的状态
--time:2017-09-08 05:32:23
--@type:
--@status:
--@return 
--==============================--
function BarrageController:setBarrageOpen(type, status)
    if self.barrage_open_list == nil then
        self.barrage_open_list = RoleEnv:getInstance():get(RoleEnv.keys.barrage_type_key, {})
    end
    self.barrage_open_list[type] = status
    RoleEnv:getInstance():set(RoleEnv.keys.barrage_type_key, self.barrage_open_list, true)
end

--==============================--
--desc:弹幕系统改成本地缓存处理
--time:2017-09-25 03:02:23
--@type:
--@return 
--==============================--
function BarrageController:getBarrageOpen(type)
    if self.barrage_open_list == nil then
        self.barrage_open_list = RoleEnv:getInstance():get(RoleEnv.keys.barrage_type_key, {})
    end

    if self.barrage_open_list == nil or self.barrage_open_list[type] == nil then
        return true
    end
    return self.barrage_open_list[type]
end