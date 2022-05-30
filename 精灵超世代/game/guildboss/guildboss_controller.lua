-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-06-07
-- --------------------------------------------------------------------
GuildbossController = GuildbossController or BaseClass(BaseController)

function GuildbossController:config()
    self.model = GuildbossModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function GuildbossController:getModel()
    return self.model
end

function GuildbossController:registerEvents()
    if self.init_role_event == nil then
        self.init_role_event = GlobalEvent:getInstance():Bind(EventId.ROLE_CREATE_SUCCESS, function()
            GlobalEvent:getInstance():UnBind(self.init_role_event)
            self.init_role_event = nil

            self.role_vo = RoleController:getInstance():getRoleVo()
            if self.role_vo ~= nil then
                self:requestInitProtocal(true)
                if self.role_assets_event == nil then
                    self.role_assets_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value)
                        if key == "guild_lev" then
                            self:requestInitProtocal()
                        elseif key == "gid" then
                            if value == 0 then
                                self:openMainWindow(false)
                            end
                        end
                    end)
                end 
            end
        end)
    end 

    if self.re_link_game_event == nil then
	    self.re_link_game_event = GlobalEvent:getInstance():Bind(LoginEvent.RE_LINK_GAME, function()
            self:openGuildBossPassRewardWindow(false)
            self:requestInitProtocal(true)
        end)
    end 
end

--==============================--
--desc:请求或者清除一些基础信息的东西
--time:2018-06-11 02:21:50
--@force:是否强制
--@return 
--==============================--
function GuildbossController:requestInitProtocal(force)
    if self.role_vo == nil then return end
    -- local config = Config.GuildDunData.data_const.guild_lev
    -- if config == nil then return end
    -- local need_val = 1
    if self.role_vo.gid == 0 then
    -- if self.role_vo.gid == 0 or self.role_vo.guild_lev < need_val then
        self.model:clearGuildBossInfo({})
    else
        if force == true then
            self:requestGuildDunBaseInfo()
        else -- 升级的时候并不需要不停重复请求
            local base_info = self.model:getBaseInfo()
            if base_info == nil or next(base_info) == nil then
                self:requestGuildDunBaseInfo() 
            end
        end
    end
end

function GuildbossController:registerProtocals()
    self:RegisterProtocal(21300, "handle21300")         -- 公会副本的基础信息

    self:RegisterProtocal(21307, "handle21307")         -- 重置返回
    self:RegisterProtocal(21308, "handle21308")         -- 请求挑战返回

    self:RegisterProtocal(21312, "handle21312")         -- 购买挑战次数返回

    self:RegisterProtocal(21318, "handle21318")         -- 公会排行榜
    self:RegisterProtocal(21319, "handle21319")         -- 个人排行榜

    self:RegisterProtocal(21303, "handle21303")         -- 公会宝箱情况
    self:RegisterProtocal(21304, "handle21304")         -- 领取公会宝箱

    self:RegisterProtocal(21309, "handle21309")         -- 战斗结果，用于显示战斗结算
    self:RegisterProtocal(21317, "handle21317")         -- 扫荡结果，用于显示战斗结算

    self:RegisterProtocal(21305, "handle21305")         -- 加buff
    -- self:RegisterProtocal(21320, "handle21320")         --首通奖励
    -- self:RegisterProtocal(21321, "handle21321")         --章节通关奖励
    self:RegisterProtocal(21323, "handle21323")         --集结
end

--==============================--
--desc:开关主窗体
--time:2018-06-07 03:52:34
--@status:
--@return 
--==============================--
function GuildbossController:openMainWindow(status)
    if not status then
        if self.main_window then
            self.main_window:close()
            self.main_window = nil
        end
    else
        if self.role_vo == nil or self.role_vo.gid == 0 then 
            message(TI18N("你当前还没有加入任何公会!"))
            return 
        end
        local config = Config.GuildDunData.data_const.guild_lev 
        if config == nil then 
            message(TI18N("公会副本数据异常!"))
            return
        end
        if self.role_vo.guild_lev < config.val then
            message(config.desc)
            return 
        end

        local open_data = Config.FunctionData.data_base[6]
        local bool = MainuiController:getInstance():checkIsOpenByActivate(open_data.activate)
        if bool == false then
            message(open_data.desc)
            return
        end
        if self.main_window == nil then
            self.main_window = GuildBossMainWindow.New()
        end
        self.main_window:open()
    end
end

--==============================--
--desc:开关boss总览窗体
--time:2018-06-08 09:57:37
--@status:
--@return 
--==============================--
function GuildbossController:openGuildBossPreviewWindow(status)
    if not status then
        if self.boss_preview_window then
            self.boss_preview_window:close()
            self.boss_preview_window = nil
        end
    else
        if self.boss_preview_window == nil then
            self.boss_preview_window = GuildBossPreviewWindow.New()
        end
        self.boss_preview_window:open()
    end 
end

--==============================--
--desc:打开boss重置面板
--time:2018-06-08 10:49:00
--@status:
--@return 
--==============================--
function GuildbossController:openGuildBossResetWindow(status)
    if not status then
        if self.reset_window then
            self.reset_window:close()
            self.reset_window = nil
        end
    else
        if self.reset_window == nil then
            self.reset_window = GuildBossResetWindow.New()
        end
        self.reset_window:open()
    end 
end

--==============================--
--desc:首通奖励面板
--time:2018-06-08 02:46:54
--@status:
--@return 
--==============================--
function GuildbossController:openGuildBossPassRewardWindow(status)
    if not status then
        if self.pass_reward_window then
            self.pass_reward_window:close()
            self.pass_reward_window = nil
        end
    else
        if self.pass_reward_window == nil then
            self.pass_reward_window = GuildBossPassRewardWindow.New()
        end
        self.pass_reward_window:open()
    end 
end

--==============================--
--desc:打开副本宝箱奖励
--time:2018-06-08 03:27:06
--@status:
--@return 
--==============================--
function GuildbossController:openGuildBossBoxRewardWindow(status)
    if not status then
        if self.box_reward_window then
            self.box_reward_window:close()
            self.box_reward_window = nil
        end
    else
        if self.box_reward_window == nil then
            self.box_reward_window = GuildBossBoxRewardWindow.New()
        end
        self.box_reward_window:open()
    end 
end

--==============================--
--desc:挑战或者扫荡结算面板
--time:2018-06-13 11:03:35
--@status:
--@data:
--@return 
--==============================--
function GuildbossController:openGuildbossResultWindow(status, data, fight_type)
    if not status then
        if self.result_window then
            self.result_window:close()
            self.result_window = nil
        end
    else
        if self.result_window == nil then
            self.result_window = GuildbossResultWindow.New()
        end
        if self.result_window:isOpen() == false then
            self.result_window:open(data, fight_type)
        end
    end 
end
--隐藏 结束界面 --位面特殊要求 -- by lwc
function GuildbossController:hideGuildbossResultWindow(status)
    if self.result_window then
        self.result_window:setVisible(status)
    end
end

--打开伤害排行
function GuildbossController:openGuildbossRankRoleWindow(status, data)
    if not status then
        if self.guildboos_rank_role_window then
            self.guildboos_rank_role_window:close()
            self.guildboos_rank_role_window = nil
        end
    else
        if self.guildboos_rank_role_window == nil then
            self.guildboos_rank_role_window = GuildBossRankRoleWindow.New()
        end
        if self.guildboos_rank_role_window:isOpen() == false then
            self.guildboos_rank_role_window:open(data)
        end
    end
end


--==============================--
--desc:打开结算面板的伤害输出排行榜
--time:2018-06-14 10:54:28
--@status:
--@data:
--@return 
--==============================--
function GuildbossController:openGuildbossResultDpsRankWindow(status, data)
    if not status then
        if self.dpsrank_window then
            self.dpsrank_window:close()
            self.dpsrank_window = nil
        end
    else
        if data == nil then return end

        if self.dpsrank_window == nil then
            self.dpsrank_window = GuildbossResultDpsRankWindow.New()
        end
        if self.dpsrank_window:isOpen() == false then 
            self.dpsrank_window:open(data)
        end
    end 
end

--==============================--
--desc:伤害排行榜
--time:2018-06-12 10:37:07
--@status:
--@return 
--==============================--
function GuildbossController:openGuildBossRankWindow(status,data)
    if not status then
        if self.rank_window then
            self.rank_window:close()
            self.rank_window = nil
        end
    else
        type = type or GuildBossConst.rank.guild
        if self.rank_window == nil then
            self.rank_window = GuildBossRankWindow.New()
        end
        self.rank_window:open(data)
    end 
end

--[[
    @desc: 打开总览奖励界面
    author:{author}
    time:2018-08-09 13:52:19
    @return:
]]
function GuildbossController:oepnGuildRewardShowView(status)
    if status == true then
        if self.reward_view == nil then
            self.reward_view = GuildBossRewardShowView.New()
        end
        self.reward_view:open()
    else
        if self.reward_view then
            self.reward_view:close()
            self.reward_view = nil
        end
    end
end


--==============================--
--desc:请求公会副本的基础信息，这个在每次打开面板的时候都请求一下吧
--time:2018-06-09 01:59:33
--@return 
--==============================--
function GuildbossController:requestGuildDunBaseInfo()
    self:SendProtocal(21300, {}) 
end

--==============================--
--desc:公会副本的基础信息返回
--time:2018-06-09 02:01:57
--@data:
--@return 
--==============================--
function GuildbossController:handle21300(data)
    self.model:updateGuildDunBaseInfo(data)
    GlobalEvent:getInstance():Fire(GuildbossEvent.MusterCoolTime, data.coldtime or 0)
end

--==============================--
--desc:购买次数提示，
--time:2018-06-14 07:42:33
--@buy_type: FALSE为普通购买次数 TRUE是挑战购买次数
--@return 
--==============================--
function GuildbossController:requestBuyChallengeTimes(buy_type)
    local base_info = self.model:getBaseInfo()
    if base_info == nil or base_info.buy_count == nil then return end
    local role_vo = RoleController:getInstance():getRoleVo()
    if role_vo == nil then return end

    if base_info.count ~= 0 then
        message(TI18N("挑战次数为0时可购买，请努力挑战Boss！"))
        return
    end

    local function buy_callback(type)
        local protocal = {}
        protocal.type = type
        self:SendProtocal(21312, protocal)
    end

    local buy_next_num = base_info.buy_count + 1
    local buy_config = Config.GuildDunData.data_buy_count[buy_next_num]
    if buy_config == nil then
        message(TI18N("当前购买次数已到达本日上限"))
    else
        if role_vo.vip_lev < buy_config.vip_lev then
            local msg = ""
            msg = string.format(TI18N("提升至<div fontcolor='#289b14'>vip%s</div>可提高<div fontcolor='#289b14'>1</div>点次数购买上限，是否前往充值提升vip等级"), buy_config.vip_lev)
            CommonAlert.show(msg,TI18N("我要提升"),function() 
                VipController:getInstance():openVipMainWindow(true,VIPTABCONST.CHARGE)
                --MallController:getInstance():openChargeShopWindow(true, MallConst.Charge_Shop_Type.Diamond)
            end,TI18N("取消"),nil, CommonAlert.type.rich )
        else
            local cost = buy_config.expend
            if cost == nil or #cost < 2 then return end
            local item_config = Config.ItemData.data_get_data(cost[1])
            if item_config then
                local msg = ""
                msg = string.format(TI18N("是否花费 <img src=%s visible=true scale=0.35 />%s 购买<div fontcolor='#289b14'>1</div>点挑战次数？"), PathTool.getItemRes(item_config.icon), cost[2])
                CommonAlert.show(msg, TI18N("确定"), function()
                    buy_callback(buy_type)
                end, TI18N("取消"), nil, CommonAlert.type.rich)
            end
        end
    end 
end

--==============================--
--desc:购买次数返回
--time:2018-06-11 05:43:34
--@data:
--@return 
--==============================--
function GuildbossController:handle21312(data)
    message(data.msg)
    if data.code == TRUE then
        self.model:updateBaseWithTimes(data.count, data.buy_count, data.type)
    end
end

--==============================--
--desc:请求重置公会章节信息
--time:2018-06-11 07:10:01
--@type:
--@return 
--==============================--
function GuildbossController:requestResetGuildDun(type)
    local protocal = {}
    protocal.type = type
    self:SendProtocal(21307, protocal)
end

--==============================--
--desc:重置返回
--time:2018-06-11 07:11:08
--@data:
--@return 
--==============================--
function GuildbossController:handle21307(data)
    if data.code == TRUE then
        self:openGuildBossResetWindow(false)
    end
    message(data.msg)
end

--==============================--
--desc:请求挑战指定的boss
--time:2018-06-12 09:51:17
--@boss_id:
--@formation_type:
--@pos_info:
--@return 
--==============================--
function GuildbossController:send21308(boss_id, formation_type, pos_info, hallows_id)
    local protocal = {}
    protocal.boss_id = boss_id
    protocal.formation_type = formation_type
    protocal.pos_info = pos_info 
    protocal.hallows_id = hallows_id 
    self:SendProtocal(21308, protocal)
end

--==============================--
--desc:请求挑战返回
--time:2018-06-12 09:52:30
--@data:
--@return 
--==============================--
function GuildbossController:handle21308(data)
    message(data.msg)
end

--==============================--
--desc:请求每日宝箱状态数据
--time:2018-06-13 09:43:46
--@return 
--==============================--
function GuildbossController:requestDayBoxRewards()
	-- self:SendProtocal(21303, {})
end

--==============================--
--desc:更新每日宝箱
--time:2018-06-13 09:44:53
--@data:
--@return 
--==============================--
function GuildbossController:handle21303(data)
    self.model:initDayBoxRewardsStatus(data.box_list)
end

--==============================--
--desc:请求领取公会章节宝箱
--time:2018-06-13 09:46:22
--@fid:
--@return 
--==============================--
function GuildbossController:requestGetChapterBox(fid)
    -- local protocal = {}
    -- protocal.fid = fid
    -- self:SendProtocal(21304, protocal)
end

--==============================--
--desc:领取宝箱返回
--time:2018-06-13 09:47:33
--@data:
--@return 
--==============================--
function GuildbossController:handle21304(data)
    message(data.msg)
    if data.code == TRUE then
        self.model:updateBoxRewards(data.fid, data.num)
    end
end

--首通奖励
function GuildbossController:requestFirstPassRewards()
    -- self:SendProtocal(21320, {})
end
function GuildbossController:handle21320(data)
    -- self.model:initFirstPassRewardList(data)
end

function GuildbossController:send21321(fid)
    -- local protocal = {}
    -- protocal.fid = fid
    -- self:SendProtocal(21321, protocal)
end
function GuildbossController:handle21321(data)
    message(data.msg)
    -- if data.code == 1 then
    --     self.model:setChargeGetPassData(data.fid)
    -- end
end
------------------
--集结
function GuildbossController:send21323()
    self:SendProtocal(21323, {})
end
function GuildbossController:handle21323(data)
    if data.code == 0 then
        message(data.msg)
    elseif data.code == 1 then
        local less_time = data.coldtime - GameNet:getInstance():getTime()
        GlobalEvent:getInstance():Fire(GuildbossEvent.MusterCoolTime, less_time or 0)  
    end
end

--加buff数据
function GuildbossController:send21305()
    local protocal = {}
    self:SendProtocal(21305,protocal)
end

function GuildbossController:handle21305(data)
    message(data.msg)
end

--==============================--
--desc:请求排行榜数据
--time:2018-06-12 07:26:17
--@index:GuildBossConst.rank.guild 或者 GuildBossConst.rank.role
--@return 
--==============================--
function GuildbossController:requestGuildDunRank(index,protocal)
    if index == GuildBossConst.rank.guild then
        self:SendProtocal(21318, {})
    elseif index == GuildBossConst.rank.role then
        if protocal then
            self:SendProtocal(21319,protocal) 
        end
    end
end

--==============================--
--desc:公会排行榜
--time:2018-06-12 07:28:47
--@data:
--@return 
--==============================--
function GuildbossController:handle21318(data)
    GlobalEvent:getInstance():Fire(GuildbossEvent.UpdateGuildDunRank, data, GuildBossConst.rank.guild)
end

--==============================--
--desc:个人排行榜
--time:2018-06-12 07:29:08
--@data:
--@return 
--==============================--
function GuildbossController:handle21319(data)
    self.model:setRaknRoleList(data)
    GlobalEvent:getInstance():Fire(GuildbossEvent.UpdateGuildDunRank, data, GuildBossConst.rank.role)
end

--==============================--
--desc:挑战结果，用于显示结算面板的
--time:2018-06-13 09:49:55
--@return 
--==============================--
function GuildbossController:handle21309(data)
    BattleController:getInstance():openFinishView(true, BattleConst.Fight_Type.GuildDun, data)
end

--==============================--
--desc:扫荡结算
--time:2018-06-13 09:50:29
--@data:
--@return 
--==============================--
function GuildbossController:handle21317(data)
    message(data.msg)
    if data.code == TRUE then
        BattleController:getInstance():openFinishView(true, BattleConst.Fight_Type.GuildDun, data)
        --self:openGuildbossResultWindow(true, data)
    end
end

--==============================--
--desc:请求扫荡指定boss
--time:2018-06-13 09:51:35
--@fid:
--@return 
--==============================--
function GuildbossController:requestMopupMonster(boss_id)
    local protocal = {}
    protocal.boss_id = boss_id
    self:SendProtocal(21317, protocal)
end 

function GuildbossController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end
