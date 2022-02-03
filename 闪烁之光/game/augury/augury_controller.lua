-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--占卜
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-06-12
-- --------------------------------------------------------------------
AuguryController = AuguryController or BaseClass(BaseController)

function AuguryController:config()
    self.model = AuguryModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function AuguryController:getModel()
    return self.model
end

function AuguryController:registerEvents()
    -- if self.init_role_event == nil then
    --     self.init_role_event = GlobalEvent:getInstance():Bind(EventId.ROLE_CREATE_SUCCESS, function()
    --         GlobalEvent:getInstance():UnBind(self.init_role_event)
    --         self.init_role_event = nil

    --         self.role_vo = RoleController:getInstance():getRoleVo()
    --         if self.role_vo ~= nil then
    --             self:requestInitProtocal(true)

    --             if self.role_assets_event == nil then
    --                 self.role_assets_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value)
    --                     if key == "lev" or key == "open_day" then
    --                         self:requestInitProtocal()
    --                     end
    --                 end)
    --             end 
    --         end
    --     end)
    -- end 
end

function AuguryController:registerProtocals()
    self:RegisterProtocal(11330, "handle11330")     --请求占卜信息
    self:RegisterProtocal(11331, "handle11331")     --占卜
    self:RegisterProtocal(11332, "handle11332")     --运势刷新
end

function AuguryController:requestInitProtocal()
    local config = Config.CityData.data_base[CenterSceneBuild.study]
    if config == nil then return end
    local is_open = MainuiController:getInstance():checkIsOpenByActivate(config.activate)
    if is_open == true then
        if self.role_assets_event then
            if self.role_vo then
                self.role_vo:UnBind(self.role_assets_event)
                self.role_assets_event = nil
            end
        end
        self:sender11330()
    end
end 

--==============================--
--desc:引导需要
--time:2018-07-17 02:41:52
--@return 
--==============================--
function AuguryController:getAuguryRoot()
    if self.main_view then
        return self.main_view.root_wnd
    end
end

--打开主界面
function AuguryController:openMainView(bool)
    if bool == false then
        if self.main_view ~= nil then
            self.main_view:close()
            self.main_view = nil
        end
    else
        local data = MainSceneController:getInstance():getBuildVo(CenterSceneBuild.study)
        if data and data.is_lock then
            message(data.desc)
            return
        end
        if not self.main_view then 
            self.main_view = AuguryWindow.New()
        end
        if self.main_view and self.main_view:isOpen() == false then
            self.main_view:open()
        end
    end
end


function AuguryController:openAlertWidnow(bool,open_type)
    if bool == true then
        if not self.alert_window then 
            self.alert_window = AuguryAlertWindow.New(open_type)
        end
        if self.alert_window and self.alert_window:isOpen() == false then
            self.alert_window:open()
        end

    else 
        if self.alert_window then 
            self.alert_window:close()
            self.alert_window = nil
        end
    end
end
function AuguryController:openGetWidnow(bool,data)
    if bool == true then
        if not self.get_window then 
            self.get_window = AuguryGetWindow.New(data)
        end
        if self.get_window and self.get_window:isOpen() == false then
            self.get_window:open()
        end

    else 
        if self.get_window then 
            self.get_window:close()
            self.get_window = nil
        end
    end
end

--请求占卜信息
function AuguryController:sender11330()
    local protocal ={}
    self:SendProtocal(11330,protocal)
end
function AuguryController:handle11330( data )
   self.model:updateData(data)
end

--占卜
function AuguryController:sender11331(type,count)
    local protocal ={}
    protocal.type = type
    protocal.count = count
    self:SendProtocal(11331,protocal)
end
function AuguryController:handle11331( data )
    message(data.msg)
    if data.result == 1 then 
        GlobalEvent:getInstance():Fire(AuguryEvent.Augury_Success_Event,data)
        self.model:updateData(data)
    end
end

--运势刷新
function AuguryController:sender11332()
    local protocal ={}
    self:SendProtocal(11332,protocal)
end
function AuguryController:handle11332( data )
   message(data.msg)
   self.model:updateData(data)
end

function AuguryController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end