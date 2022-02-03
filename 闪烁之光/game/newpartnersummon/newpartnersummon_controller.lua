-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      伙伴召唤控制器
-- <br/>Create: 2018-05-13
-- --------------------------------------------------------------------
NewPartnersummonController = NewPartnersummonController or BaseClass(BaseController)

function NewPartnersummonController:config()
    self.model = NewPartnersummonModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function NewPartnersummonController:getModel()
    return self.model
end

function NewPartnersummonController:registerEvents()
    if self.init_role_event == nil then
        self.init_role_event = GlobalEvent:getInstance():Bind(EventId.ROLE_CREATE_SUCCESS, function()
            GlobalEvent:getInstance():UnBind(self.init_role_event)
            self:send23200() --登录先请求一下
        end)
    end
    -- 断线重连的时候
    if self.re_link_game_event == nil then
        self.re_link_game_event = GlobalEvent:getInstance():Bind(LoginEvent.RE_LINK_GAME, function()
            --self:send23200() --断线也请求一下
            -- 引导中不要关掉
            if GuideController:getInstance():isInGuide() == false then
                self:openNewPartnerSummonWindow(false)
            end
            self.req_flag = false -- 断线重连时重置请求标识
            --self:openPartnerSummonPreView(false)
        end)
    end
end

function NewPartnersummonController:registerProtocals()
    self:RegisterProtocal(23200,"handle23200")
    self:RegisterProtocal(23201,"handle23201")
    self:RegisterProtocal(23202,"handle23202")
    
end
--请求召唤信息
function NewPartnersummonController:send23200()
    self:SendProtocal(23200)
end
function NewPartnersummonController:handle23200(data)
    local temp = {}
    if data then
        self.model:setSummonItemData(data.recruit_list)
        PartnersummonController:getInstance():getModel():setFiveStarHeroIsOut(data.must_five_num)
        -- self.model:setSummonData(data)
    end
end

function NewPartnersummonController:send23201(group_id,times,recruit_type)
    local protocal = {}
    protocal.group_id = group_id
    protocal.times = times
    protocal.recruit_type = recruit_type
    self:SendProtocal(23201, protocal)
end
function NewPartnersummonController:handle23201(data)
    if data then
        PartnersummonController:getInstance():getModel():setFiveStarHeroIsOut(data.must_five_num)
        self.dispather:Fire(PartnersummonEvent.updateSummonFiveStarEvent)
        self.dispather:Fire(PartnersummonEvent.updateSummonItemEvent,data)
        PartnersummonController:getInstance():openSummonGainWindow(false)
        PartnersummonController:getInstance():openSummonGainWindow(true,data,TRUE)
    end
end
--更新召唤通用信息
function NewPartnersummonController:send23202()
    self:SendProtocal(23202)
end
function NewPartnersummonController:handle23202(data)
    if data then
        self.model:updataSummonItemData(data)
        self.dispather:Fire(PartnersummonEvent.updateSummonItemEvent,data)
    end
end

--打开召唤主界面
function NewPartnersummonController:openNewPartnerSummonWindow(status)
   if status == false then
        if self.new_partner_summon_window ~= nil then
            self.new_partner_summon_window:close()
            self.new_partner_summon_window = nil
        end
    else
        local data = MainSceneController:getInstance():getBuildVo(CenterSceneBuild.summon)
        if data and data.is_lock then
            message(data.desc)
            return
        end

        if self.new_partner_summon_window == nil then
            self.new_partner_summon_window = NewPartnerSummonWindow.New()
        end
        if self.new_partner_summon_window:isOpen() == false then
            self.new_partner_summon_window:open()
        end
    end
end

--引导需要
function NewPartnersummonController:getSummonRoot()
    if self.new_partner_summon_window ~= nil then
        return self.new_partner_summon_window.root_wnd
    end
end

function NewPartnersummonController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end
