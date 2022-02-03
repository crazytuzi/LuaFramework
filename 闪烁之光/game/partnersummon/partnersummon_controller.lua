-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      伙伴召唤控制器
-- <br/>Create: 2018-05-13
-- --------------------------------------------------------------------
PartnersummonController = PartnersummonController or BaseClass(BaseController)

function PartnersummonController:config()
    self.model = PartnersummonModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function PartnersummonController:getModel()
    return self.model
end

function PartnersummonController:registerEvents()
    --[[if self.init_role_event == nil then
        self.init_role_event = GlobalEvent:getInstance():Bind(EventId.ROLE_CREATE_SUCCESS, function()
            GlobalEvent:getInstance():UnBind(self.init_role_event)
            self:send23200() --登录先请求一下
        end)
    end--]]
    -- 断线重连的时候
    if self.re_link_game_event == nil then
        self.re_link_game_event = GlobalEvent:getInstance():Bind(LoginEvent.RE_LINK_GAME, function()
            --self:send23200() --断线也请求一下
            -- 引导中不要关掉
            if GuideController:getInstance():isInGuide() == false then
                self:openPartnerSummonWindow(false)
            end
            self.req_flag = false -- 断线重连时重置请求标识
            --self:openPartnerSummonPreView(false)
        end)
    end
    --新获得伙伴弹窗
    if not self.get_new_partner_event then
        self.get_new_partner_event = GlobalEvent:getInstance():Bind(MainuiEvent.CLOSE_ITEM_VIEW, function()
            if self.is_add_partner == true and self.add_partner_data then
                 self:openSummonGainShowWindow(true, self.add_partner_data)
                self.is_add_partner = false
                self.add_partner_data = nil
            end
        end)
    end

    if not self.battle_result_event then
        self.battle_result_event = GlobalEvent:getInstance():Bind(BattleEvent.CLOSE_RESULT_VIEW, function()
            if self.is_add_partner == true and self.add_partner_data then
                 self:openSummonGainShowWindow(true, self.add_partner_data)
                self.is_add_partner = false
                self.add_partner_data = nil
            end
        end)
    end
end

function PartnersummonController:registerProtocals()
    -- 普通召唤
    -- self:RegisterProtocal(23200,"handle23200") --请求召唤信息
    -- self:RegisterProtocal(23201,"handle23201") --召唤
    -- self:RegisterProtocal(23202,"handle23202") --更新召唤通用信息
    self:RegisterProtocal(23203,"handle23203") --领取召唤分享奖励
    self:RegisterProtocal(23204,"handle23204") --跟新单个召唤卡库信息
    self:RegisterProtocal(11095,"handle11095")--其他途径获得伙伴推送
    self:RegisterProtocal(23212,"handle23212")--推送新卡库开启
end

function PartnersummonController:send23200()
    local protocal = {}
    self:SendProtocal(23200, protocal)
end

function PartnersummonController:handle23200(data)
    if data then
        self.model:setSummonData(data)
    end
end

function PartnersummonController:send23201(group_id,times,recruit_type)
    --if self.req_flag then return end
    local protocal = {}
    protocal.group_id = group_id
    protocal.times = times
    protocal.recruit_type = recruit_type
    self.req_flag = true  -- 协议请求标识（协议返回后才能继续请求）
    self:SendProtocal(23201, protocal)
end

function PartnersummonController:handle23201(data)
    if data then
        self:openSummonGainWindow(false)
        self:openSummonGainWindow(true,data,TRUE)
        self.req_flag = false
        self.model:setFiveStarHeroIsOut(data.must_five_num)
        GlobalEvent:getInstance():Fire(PartnersummonEvent.SummonMustFiveStarEvent)
    end
end

function PartnersummonController:handle23202(data)
    if data then
        self.model:updateExtendData(data)
    end
end

function PartnersummonController:send23203()
    local protocal = {}
    self:SendProtocal(23203, protocal)
end

function PartnersummonController:handle23203(data)
    message(data.msg)
    if data and data.code == 1 then
        self.model:setShareData(data)
    end
end

-- 更新某个卡库的数据
function PartnersummonController:handle23204(data)
    if data and data.recruit_group then
        self.model:updateRecruitData(data.recruit_group)
    end
end
--打开召唤主界面
function PartnersummonController:openPartnerSummonWindow(status)
    NewPartnersummonController:getInstance():openNewPartnerSummonWindow(status)
--    if status == false then
--         if self.partner_summon_window ~= nil then
--             self.partner_summon_window:close()
--             self.partner_summon_window = nil
--         end
--     else
--         local data = MainSceneController:getInstance():getBuildVo(CenterSceneBuild.summon)
--         if data and data.is_lock then
--             message(data.desc)
--             return
--         end

--         local starttime = os.clock();                           --> os.clock()用法
--         -- print(string.format("start time : %.4f", starttime));
--         if self.partner_summon_window == nil then
--             self.partner_summon_window = PartnerSummonWindow.New()
--         end
--         if self.partner_summon_window:isOpen() == false then
--             self.partner_summon_window:open(starttime)
--         end
--     end
end

-- 打开神将召唤界面
function PartnersummonController:openGodPartnerSummonView( status )
    if status == true then
        if self.godpartner_summon_view == nil then
            self.godpartner_summon_view = PartnerSummonGodView.New()
        end
        if self.godpartner_summon_view:isOpen() == false then
            self.godpartner_summon_view:open()
        end
    else
        if self.godpartner_summon_view then
            self.godpartner_summon_view:close()
            self.godpartner_summon_view = nil
        end
    end
end

-- 打开积分召唤界面
function PartnersummonController:openPartnerSummonScoreWindow( status )
    if status == true then
        if self.score_summon_window == nil then
            self.score_summon_window = PartnerSummonScoreWindow.New()
        end
        if self.score_summon_window:isOpen() == false then
            self.score_summon_window:open()
        end
    else
        if self.score_summon_window then
            self.score_summon_window:close()
            self.score_summon_window = nil
        end
    end
end

--==============================--
--desc:引导需要
--time:2018-06-27 02:40:06
--@return 
--==============================--
function PartnersummonController:getSummonRoot()
    return NewPartnersummonController:getInstance():getSummonRoot()
end

--==============================--
--desc:召唤预览
--time:2018-06-27 02:59:24
--@return 
--==============================--
function PartnersummonController:getSummonResultRoot()
    if self.partner_summon_gain_window then
        return self.partner_summon_gain_window.root_wnd
    end
end

function PartnersummonController:handle11095(data)
    if data.status == 1 then
        self:openSummonGainShowWindow(true, data)
    else
        self.is_add_partner = true
        self.add_partner_data = data
    end
end

--打开召唤预览界面
--[[function PartnersummonController:openPartnerSummonPreView(status,group_id)
    if status == false then
        if self.partner_summon_preview ~= nil then
            self.partner_summon_preview:close()
            self.partner_summon_preview = nil
        end
    else
        if self.partner_summon_preview == nil then
            self.partner_summon_preview = PartnerSummonPreviewView.New()
        end
        if self.partner_summon_preview:isOpen() == false then
            self.partner_summon_preview:open(group_id)
        end
    end
end--]]

--召唤获得界面
function PartnersummonController:openSummonGainWindow(status,data,is_call)
    if status == false then
        if self.partner_summon_gain_window ~= nil then
            self.partner_summon_gain_window:close()
            self.partner_summon_gain_window = nil
        end
    else
        if self.partner_summon_gain_window == nil then
            self.partner_summon_gain_window = PartnerSummonGainWindow.New(is_call)
        end
        if self.partner_summon_gain_window:isOpen() == false then
            self.partner_summon_gain_window:open(data,is_call)
        end
    end
end

--@bg_type 背景类型
function PartnersummonController:openSummonGainShowWindow(status, data, bg_type)
    if status == false then
        if self.partner_summon_gain_show_window ~= nil then
            self.partner_summon_gain_show_window:close()
            self.partner_summon_gain_show_window = nil
        end
    else
        -- 判断一下配置表中是否需要展示该英雄
        if data.partner_bid then
            local config = Config.PartnerData.data_partner_base[data.partner_bid]
            if config and config.show_effect and config.show_effect == 1 then
                if self.partner_summon_gain_show_window == nil then
                    self.partner_summon_gain_show_window = PartnerSummonGainShowWindow.New(bg_type)
                end
                if self.partner_summon_gain_show_window:isOpen() == false then
                    self.partner_summon_gain_show_window:open(data)
                end
            end
        end
    end
end

function PartnersummonController:handle23212(data)
    -- print("\n\nPartnersummonController:handle23212(>>>>>>>>>>>\n")
end

--==============================--
--desc:引导需要
--time:2018-07-18 07:32:06
--@return 
--==============================--
function PartnersummonController:getSummonShowRoot()
    if self.partner_summon_gain_show_window then
        return self.partner_summon_gain_show_window.root_wnd
    end
end

function PartnersummonController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end
