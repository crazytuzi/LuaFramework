-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-05-30
-- --------------------------------------------------------------------
GuildController = GuildController or BaseClass(BaseController)

function GuildController:config()
    self.model = GuildModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function GuildController:getModel()
    return self.model
end

function GuildController:registerEvents()
    if self.init_role_event == nil then
        self.init_role_event = GlobalEvent:getInstance():Bind(EventId.ROLE_CREATE_SUCCESS, function()
            GlobalEvent:getInstance():UnBind(self.init_role_event)
            self.init_role_event = nil

            self.role_vo = RoleController:getInstance():getRoleVo()
            if self.role_vo ~= nil then
                self:requestInitProtocal()
                if self.role_assets_event == nil then
                    self.role_assets_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value)
                        if key == "gid" then
                            if value == 0 then -- 这个时候表示退帮。或者被提出公会，或者解散公会
                                self:openGuildMainWindow(false)             -- 关闭主界面
                                self:openGuildMemberWindow(false)           -- 关闭成员面板
                                self:openGuildDonateWindow(false)           -- 关闭捐献面板
                                HeroController:getInstance():getModel():clearHeroVoDetailedInfo()
                            else
                                -- 有公会的时候，如果处于初始窗体的时候，就标识申请加入或者创建，这个时候直接打开主ui
                                if self.init_window then
                                    self.request_open_main_window = true
                                    HeroController:getInstance():getModel():clearHeroVoDetailedInfo()
                                end
                                self:openGuildInitWindow(false)             -- 关闭潜在打开的初始窗体
                            end
                            self:requestInitProtocal()
                        elseif key == "position" then
                            self.model:updateMemberByPosition(value)
                        end
                    end)
                end 
            end
        end)
    end

    if self.re_link_game_event == nil then
	    self.re_link_game_event = GlobalEvent:getInstance():Bind(LoginEvent.RE_LINK_GAME, function()
            self:requestInitProtocal()
        end)
    end 

    if self.update_red_point_event == nil then
	    self.update_red_point_event = GlobalEvent:getInstance():Bind(RoleEvent.UPDATE_RED_POINT, function()
            self:updateSkillFirstRedPoint()
        end)
    end 
    
end

--==============================--
--desc:登录成功或者断线重连需要请求的一些数据
--time:2018-05-31 07:30:31
--@return 
--==============================--
function GuildController:requestInitProtocal()
    if self.role_vo ~= nil then
        if self.role_vo.gid == 0 then       -- 这边自己清理掉本地缓存中的自己公会信息
            self.model:clearMyGuildInfo()
        else
            self:requestGuildDonateProtocal()
            
            self:SendProtocal(13518, {})                -- 本公会信息
            self:SendProtocal(16900, {})
            if self.role_vo.position ~= GuildConst.post_type.member then
                self:SendProtocal(13573, {})                -- 公会申请红点
            end

            --公会秘境开启弹窗
            GuildsecretareaController:getInstance():sender26807()
            GuildsecretareaController:getInstance():sender26800()
        end
    end 
end

function GuildController:requestGuildDonateProtocal()
    self:SendProtocal(13523, {})                -- 捐献情况
end

function GuildController:registerProtocals()
    self:RegisterProtocal(13500, "handle13500")         -- 创建公会
    self:RegisterProtocal(13501, "handle13501")         -- 公会列表
    self:RegisterProtocal(13503, "handle13503")         -- 申请加入公会
    self:RegisterProtocal(13505, "handle13505")         -- 操作申请成员的列表
    self:RegisterProtocal(13507, "handle13507")         -- 更新申请加入列表
    self:RegisterProtocal(13513, "handle13513")         -- 从公会中踢人
    self:RegisterProtocal(13514, "handle13514")         -- 退帮
    self:RegisterProtocal(13516, "handle13516")         -- 解散公会
    self:RegisterProtocal(13518, "handle13518")         -- 本公会基础信息
    self:RegisterProtocal(13519, "handle13519")         -- 本公会成员列表
    self:RegisterProtocal(13520, "handle13520")         -- 职位设置
    self:RegisterProtocal(13521, "handle13521")         -- 修改宣言
    self:RegisterProtocal(13522, "handle13522")         -- 设置申请
    self:RegisterProtocal(13523, "handle13523")         -- 玩家基础捐献信息
    self:RegisterProtocal(13524, "handle13524")         -- 捐献返回
    self:RegisterProtocal(13542, "hander13542")         -- 增删更新成员
    self:RegisterProtocal(13558, "handle13558")         -- 公会招募广告

    self:RegisterProtocal(13565, "handle13565")         -- 弹劾

    self:RegisterProtocal(13568, "handle13568")         -- 修改公会名字
    self:RegisterProtocal(13573, "handle13573")         -- 公会申请列表红点

    self:RegisterProtocal(13574, "handle13574")         -- 领取捐献宝箱情况
    self:RegisterProtocal(13575, "handle13575")         -- 更新当前捐献进度值

    self:RegisterProtocal(13576, "handle13576")         -- 欢迎新人

    self:RegisterProtocal(16900, "handle16900")
    self:RegisterProtocal(16901, "handle16901")
    self:RegisterProtocal(16902, "handle16902")
    self:RegisterProtocal(16903, "handle16903")
    self:RegisterProtocal(16904, "handle16904")
    
    self:RegisterProtocal(13577, "handle13577")         -- 公会日志列表
    self:RegisterProtocal(13578, "handle13578")         -- 新增公会日志
    self:RegisterProtocal(13579, "handle13579")         -- 公会一键提醒
    self:RegisterProtocal(13580, "handle13580")         -- 公会发送邮件
end

--==============================--
--desc:打开公会的外部接口，主要是场景图标点击使用的，这里面会判断有没有公会，从而判断打开窗体
--time:2018-05-30 04:31:47
--@index:
--@return 
--==============================--
function GuildController:checkOpenGuildWindow(index)
    if self.role_vo  == nil or self.role_vo.gid == 0 then
        self:openGuildInitWindow(true, index)
    else
        self:openGuildMainWindow(true, index)
    end
end

--==============================--
--desc:打开公会的初始窗体，这个在没有公会的时候默认打开
--time:2018-05-30 04:26:27
--@status:
--@index:
--@return 
--==============================--
function GuildController:openGuildInitWindow(status, index)
    if not status then
        if self.init_window ~= nil then
            self.init_window:close()
            self.init_window = nil
        end
    else
        if self.init_window == nil then
            self.init_window = GuildInitWindow.New()
        end
        self.init_window:open(index)
    end
end

--==============================--
--desc:引导需要
--time:2018-07-17 11:22:50
--@return 
--==============================--
function GuildController:getGuildInitRoot()
    if self.init_window then
        return self.init_window.root_wnd
    end
end

--==============================--
--desc:打开公会的主窗体，这个是有公会的时候默认打开的
--time:2018-05-30 04:29:29
--@status:
--@index:
--@return 
--==============================--
function GuildController:openGuildMainWindow(status, index)
    if not status then
        if self.main_window ~= nil then
            self.main_window:close()
            self.main_window = nil
        end
    else
        if self.main_window == nil then
            self.main_window = GuildNewMainWindow.New()
        end
        self.main_window:open(index) 
    end
end

--==============================--
--desc:打开或者关闭成员列表
--time:2018-05-31 08:48:39
--@status:
--@return 
--==============================--
function GuildController:openGuildMemberWindow(status, index)
    if not status then
        if self.member_window ~= nil then
            self.member_window:close()
            self.member_window = nil
        end
    else
        if self.member_window == nil then
            self.member_window = GuildMemberWindow.New()
        end
        if self.member_window:isOpen() == false then
            self.member_window:open(index)
        end
    end 
end

--==============================--
--desc:公会捐献面板
--time:2018-06-04 10:45:50
--@status:
--@return 
--==============================--
function GuildController:openGuildDonateWindow(status)
    if not status then
        if self.donate_window ~= nil then
            self.donate_window:close()
            self.donate_window = nil
        end
    else
        if self.role_vo == nil or not self.role_vo:isHasGuild() then
            message(TI18N("您暂时还没有加入公会"))
            return
        end
        local open_data = Config.FunctionData.data_base[6]
        local bool = MainuiController:getInstance():checkIsOpenByActivate(open_data.activate)
        if bool == false then
            message(open_data.desc)
            return
        end

        if self.donate_window == nil then
            self.donate_window = GuildDonateWindow.New()
        end 
        self.donate_window:open() 
    end
end

--==============================--
--desc:打开公会申请界面
--time:2018-06-04 03:02:09
--@status:
--@return 
--==============================--
function GuildController:openGuildApplyWindow(status)
    if not status then
        if self.apply_window ~= nil then
            self.apply_window:close()
            self.apply_window = nil
        end
    else
        if self.apply_window == nil then
            self.apply_window = GuildApplyWindow.New()
        end
        self.apply_window:open()
    end 
end

--打开公会活跃面板
function GuildController:openGuildActionGoalWindow(status)
    if not status then
        if self.goal_window ~= nil then
            self.goal_window:close()
            self.goal_window = nil
        end
    else
        if self.goal_window == nil then
            self.goal_window = GuildActionGoalWindow.New()
        end
        self.goal_window:open()
    end 
end

-- 打开公会活跃图标选择界面
function GuildController:openGuildActiveIconWindow( status )
    if status == true then
        if not self.active_icon_wnd then
            self.active_icon_wnd = GuildActiveIconWindow.New()
        end
        if self.active_icon_wnd:isOpen() == false then
            self.active_icon_wnd:open()
        end
    else
        if self.active_icon_wnd then
            self.active_icon_wnd:close()
            self.active_icon_wnd = nil
        end
    end
end

--打开公会活跃奖励预览面板
function GuildController:openGuildRewardWindow(status)
    if not status then
        if self.reward_window ~= nil then
            self.reward_window:close()
            self.reward_window = nil
        end
    else
        if self.reward_window == nil then
            self.reward_window = GuildRewardWindow.New()
        end
        self.reward_window:open()
    end 
end
--==============================--
--desc:公会申请设置面板
--time:2018-06-04 05:38:59
--@status:
--@return 
--==============================--
function GuildController:openGuildApplySetWindow(status)
    if not status then
        if self.apply_set_window ~= nil then
            self.apply_set_window:close()
            self.apply_set_window = nil
        end
    else
        if self.apply_set_window == nil then
            self.apply_set_window = GuildApplySetWindow.New()
        end
        self.apply_set_window:open()
    end 
end

--==============================--
--desc:职位任免和踢人面板
--time:2018-06-05 11:01:26
--@status:
--@list:
--@return 
--==============================--
function GuildController:openGuildOperationPostWindow(status, data)
    if not status then
        if self.operation_post_window ~= nil then
            self.operation_post_window:close()
            self.operation_post_window = nil
        end
    else
        if data == nil then return end
        if self.operation_post_window == nil then
            self.operation_post_window = GuildOperationPostWindow.New()
        end
        if self.operation_post_window:isOpen() == false then
            self.operation_post_window:open(data)
        end
    end 
end

--弹劾帮主
function GuildController:openGuildImpeachPostWindow(status)
    if status == true then
        if self.impeach_post_window == nil then
            self.impeach_post_window = GuildImpeachPostWindow.New()
        end
        self.impeach_post_window:open()
    else
        if self.impeach_post_window ~= nil then
            self.impeach_post_window:close()
            self.impeach_post_window = nil
        end
    end 
end

--==============================--
--desc:公会改名面板
--time:2018-06-05 03:11:18
--@status:
--@return 
--==============================--
function GuildController:openGuildChangeNameWindow(status)
    if not status then

        if self.change_name_window ~= nil then
            self.change_name_window:close()
            self.change_name_window = nil
        end
    else
        if isQingmingShield and isQingmingShield() then
            return
        end
        if self.change_name_window == nil then
            self.change_name_window = GuildChangeNameWindow.New()
        end
        self.change_name_window:open()
    end 
end

--==============================--
--desc:公会宣言修改
--time:2018-06-05 04:17:58
--@status:
--@return 
--==============================--
function GuildController:openGuildChangeSignWindow(status)
    if not status then
        if self.change_sign_window ~= nil then
            self.change_sign_window:close()
            self.change_sign_window = nil
        end
    else
        if self.change_sign_window == nil then
            self.change_sign_window = GuildChangeSignWindow.New()
        end
        self.change_sign_window:open()
    end 
end

--==============================--
--desc:公会发送邮件
--time:2019-06-03 14:45:58
--@status:
--@return 
--==============================--
function GuildController:openGuildSendMailWindow(status)
    if not status then
        if self.send_mail_window ~= nil then
            self.send_mail_window:close()
            self.send_mail_window = nil
        end
    else
        if self.send_mail_window == nil then
            self.send_mail_window = GuildSendMailWindow.New()
        end
        self.send_mail_window:open()
    end 
end

--==============================--
--desc:公会公告
--time:2019-06-03 17:06:50
--@status:
--@return 
--==============================--
function GuildController:openGuildNoticeWindow(status)
    if not status then
        if self.notice_window ~= nil then
            self.notice_window:close()
            self.notice_window = nil
        end
    else
        if self.notice_window == nil then
            self.notice_window = GuildNoticeWindow.New()
        end
        self.notice_window:open()
    end 
end

--==============================--
--desc:请求创建公会
--time:2018-05-30 08:17:57
--@name:公会名字
--@sign:宣言
--@apply_type:申请类型(0:自动审批 1:手动审批 2:不允许申请)
--@apply_lev:最小等级要求
--@return 
--==============================--
function GuildController:requestCreateGuild(name, sign, apply_type, apply_lev, power)
    apply_type = apply_type or 0
    apply_lev = apply_lev or 1
    local protocal = {}
    protocal.name = name
    protocal.sign = sign
    protocal.apply_type = apply_type 
    protocal.apply_lev = apply_lev
    protocal.apply_power = power
    self:SendProtocal(13500, protocal) 
end

--==============================--
--desc:创建公会返回
--time:2018-05-30 08:14:50
--@data:
--@return 
--==============================--
function GuildController:handle13500(data)
    message(data.msg)
    if data.code == TRUE then
    end
end

--==============================--
--desc:请求公会列表
--time:2018-05-30 08:20:49
--@page:页码
--@flag:是否显示满人的公会 0:不显示 1:显示
--@num:每页显示条数
--@name:如果不为“”表示是搜索
--@return 
--==============================--
function GuildController:requestGuildList(page, flag, num, name)
    page = page or 0
    flag = flag or 1
    num = num or 0
    name = name or ""
    local protocal = {}
    protocal.page = page
    protocal.flag = flag
    protocal.num = num
    protocal.name = name
    self:SendProtocal(13501, protocal) 
end

--==============================--
--desc:获取公会列表
--time:2018-05-30 08:16:01
--@data:
--@return 
--==============================--
function GuildController:handle13501(data)
    self.model:updateGuildList(data.name, data.guilds)
end

--==============================--
--desc:申请加入公会
--time:2018-05-31 02:04:41
--@gid:
--@gsrv_id:
--@type:
--@return 
--==============================--
function GuildController:requestJoinGuild(gid, gsrv_id, type)
    if gid == nil or gsrv_id == nil then return end
    local protocal = {}
    type = type or 1
    protocal.gid = gid
    protocal.gsrv_id = gsrv_id
    protocal.type = type
    self:SendProtocal(13503, protocal) 
end

--==============================--
--desc:请求加入公会返回
--time:2018-05-31 02:06:29
--@data:
--@return 
--==============================--
function GuildController:handle13503(data)
    message(data.msg)
    if data.code == TRUE then
        self.model:updateGuildApplyStatus(data.gid, data.gsrv_id, data.is_apply)
    end
end

--==============================--
--desc:更新自己公会的信息
--time:2018-05-31 07:34:44
--@data:
--@return 
--==============================--
function GuildController:handle13518(data)
    self.model:updateMyGuildInfo(data)

    -- 新申请立马进帮，或者创建公会的时候，直接打开主界面
    if self.request_open_main_window == true then
        self.request_open_main_window = false
        self:openGuildMainWindow(true)
    end
end

--弹劾帮主
function GuildController:send13565()
    self:SendProtocal(13565, {})
end
function GuildController:handle13565(data)
    -- dump(data)
    message(data.msg)
end

--==============================--
--desc:请求公会成员列表
--time:2018-05-31 09:17:53
--@return 
--==============================--
function GuildController:requestGuildMemberList()
    self:SendProtocal(13519, {})
end

--==============================--
--desc:更新整个公会成员列表
--time:2018-05-31 09:00:01
--@data:
--@return 
--==============================--
function GuildController:handle13519(data)
    self.model:updateMyGuildMemberList(data.members, 1)
end

function GuildController:handle13523(data)
    self.model:updateDonateInfo(data.donate_list)

    -- 更新捐献宝箱情况
    self.model:updateDonateBoxInfo(data.boxes, data.donate_exp)
    RedbagController:getInstance():getModel():updateRedBagNum(data.day_send_num,data.day_recv_num)
end

--==============================--
--desc:请求公会捐献
--time:2018-06-04 11:40:48
--@type:
--@return 
--==============================--
function GuildController:requestGuildDonate(type)
    local protocal = {}
    protocal.type = type
    self:SendProtocal(13524, protocal)
end

--==============================--
--desc:公会捐献返回
--time:2018-06-04 11:41:35
--@data:
--@return 
--==============================--
function GuildController:handle13524(data)
    message(data.msg)
    if data.code == TRUE then
        self.model:setGuildDonateStatus()
    end
end

--==============================--
--desc:更新，增加或者删除成员
--time:2018-05-31 09:04:11
--@data:
--@return 
--==============================--
function GuildController:hander13542(data)
    self.model:updateMyGuildMemberList(data.members, data.type)
end

--==============================--
--desc:会长或者副会长处理操作申请列表
--time:2018-06-04 04:59:28
--@type:
--@rid:
--@srv_id:
--@return 
--==============================--
function GuildController:requestOperationApply(type, rid, srv_id) 
    local protocal = {}
    protocal.type = type
    protocal.rid = rid
    protocal.srv_id = srv_id
    self:SendProtocal(13505, protocal)
end

--==============================--
--desc:操作申请玩家列表返回
--time:2018-06-04 05:01:07
--@data:
--@return 
--==============================--
function GuildController:handle13505(data)
    message(data.msg)
    if data.code == TRUE then
        self.model:deleteApplyInfo(data.rid, data.srv_id)
    end
end

--==============================--
--desc:请求当前申请加入的公会列表
--time:2018-06-04 04:54:49
--@page:
--@num:
--@return 
--==============================--
function GuildController:requestGuildApplyList(page, num)
    page = page or 0
    num = num or 0
    local protocal = {}
    protocal.page = page
    protocal.num = num
    self:SendProtocal(13507, protocal)
end

--==============================--
--desc:更新申请列表
--time:2018-06-04 04:53:53
--@data:
--@return 
--==============================--
function GuildController:handle13507(data)
    self.model:updateGuildApplyList(data.guids)
end

--==============================--
--desc:请求退帮
--time:2018-06-04 08:29:21
--@return 
--==============================--
function GuildController:requestExitGuild()
    local role_vo = RoleController:getInstance():getRoleVo()
    if role_vo == nil then return end
    if role_vo.position == GuildConst.post_type.leader then         -- 自己是帮主，则是解散公会
        local msg = string.format(TI18N("是否确定解散公会【%s】？"), role_vo.gname)
        local extend_msg = ""
        if role_vo.guild_quit_time ~= 0 then
            extend_msg = TI18N("(解散公会后，12小时内无法加入其他公会，24小时内无法创建公会)")
        else
            extend_msg = TI18N("(首次解散公会后，可立即加入其他公会，24小时内无法创建公会。)") 
        end
        CommonAlert.show(msg,TI18N("确定"),function() 
            self:SendProtocal(13516, {})
        end,TI18N("取消"),nil,nil,nil,{timer=3, timer_for=true, off_y = 43, title = TI18N("解散公会"), extend_str = extend_msg, extend_offy = -5, extend_aligment = cc.TEXT_ALIGNMENT_CENTER },nil,nil)
    else
        local msg = string.format(TI18N("是否确定退出公会【%s】？"), role_vo.gname)
        local extend_msg = "" 
        if role_vo.guild_quit_time ~= 0 then
            extend_msg = TI18N("(退出公会后12小时内无法创建公会、加入其他公会)")
        else
            extend_msg = TI18N("(首次退出后可立即加入其他公会，12小时内无法创建公会)")
        end 
        CommonAlert.show(msg, TI18N("确定"), function()
            self:SendProtocal(13514, {})
        end, TI18N("取消"), nil, nil, nil, {timer = 3, timer_for = true, off_y = 43, title = TI18N("退出公会"), extend_str = extend_msg, extend_offy = -5, extend_aligment = cc.TEXT_ALIGNMENT_CENTER }, nil, nil) 
    end
end

--==============================--
--desc:退帮
--time:2018-06-04 08:28:49
--@data:
--@return 
--==============================--
function GuildController:handle13514(data)
    message(data.msg)
end

--==============================--
--desc:解散
--time:2018-06-04 08:28:54
--@data:
--@return 
--==============================--
function GuildController:handle13516(data)
    message(data.msg)
end

--==============================--
--desc:设置修改申请条件
--time:2018-06-04 09:08:32
--@apply_type:
--@apply_lev:
--@return 
--==============================--
function GuildController:requestChangeApplySet(apply_type, apply_lev, apply_power)
    local protocal = {}
    protocal.apply_type = apply_type
    protocal.apply_lev = apply_lev
    protocal.apply_power = apply_power
    self:SendProtocal(13522, protocal)
end

--==============================--
--desc:设置权限返回
--time:2018-06-04 09:08:03
--@data:
--@return 
--==============================--
function GuildController:handle13522(data)
    message(data.msg)
    if data.code == TRUE then
        self:openGuildApplySetWindow(false)
    end
end

--==============================--
--desc:请求修改公会宣言
--time:2018-06-05 04:26:36
--@sign:
--@return 
--==============================--
function GuildController:requestChangeGuildSign(sign)
    local protocal = {}
    protocal.sign = sign 
    self:SendProtocal(13521, protocal)
end

--==============================--
--desc:公会宣言修改
--time:2018-06-05 04:27:16
--@data:
--@return 
--==============================--
function GuildController:handle13521(data)
    message(data.msg)
    if data.code == TRUE then
        self:openGuildChangeSignWindow(false)
    end
end

--==============================--
--desc:从公会中踢人
--time:2018-06-05 11:38:29
--@rid:
--@srv_id:
--@return 
--==============================--
function GuildController:requestKickoutMember(rid, srv_id, name)
    local function call_back()
        local protocal = {}
        protocal.rid = rid
        protocal.srv_id = srv_id
        self:SendProtocal(13513, protocal)
    end
    local msg = string.format(TI18N("是否确认将【%s】玩家移除出公会？"), name)
    CommonAlert.show(msg, TI18N("确定"), function()
        call_back()
    end, TI18N("取消"))
end

--==============================--
--desc:踢人返回
--time:2018-06-05 11:39:36
--@data:
--@return 
--==============================--
function GuildController:handle13513(data)
    message(data.msg)
    if data.code == TRUE then
        self:openGuildOperationPostWindow(false)
    end
end

--==============================--
--desc:职位任命
--time:2018-06-05 11:41:15
--@rid:
--@srv_id:
--@position:
--@return 
--==============================--
function GuildController:requestOperationPost(rid, srv_id, position)
    local protocal = {}
    protocal.rid = rid
    protocal.srv_id = srv_id
    protocal.position = position
    self:SendProtocal(13520, protocal)
end

--==============================--
--desc:职位任命
--time:2018-06-05 11:42:08
--@data:
--@return 
--==============================--
function GuildController:handle13520(data)
	message(data.msg)
	if data.code == TRUE then
		self:openGuildOperationPostWindow(false)
	end
end 

--==============================--
--desc:请求改名
--time:2018-06-05 03:58:46
--@name:
--@return 
--==============================--
function GuildController:requestChangGuildName(name)
    local protocal = {}
    protocal.name = name
    self:SendProtocal(13568, protocal)
end

--==============================--
--desc:公会改名
--time:2018-06-05 03:55:59
--@data:
--@return 
--==============================--
function GuildController:handle13568(data)
    message(data.msg)
    if data.code == TRUE then
        self:openGuildChangeNameWindow(false)
    end
end

--==============================--
--desc:发送公会招募广告
--time:2018-06-05 04:37:16
--@return 
--==============================--
function GuildController:requestGuildRecruit()
    local my_info = self.model:getMyGuildInfo()
    if my_info ~= nil then
        local list = {}

        local config = Config.GuildData.data_const.recruit_limit
        local limit_count = 5
        if config then
            limit_count = config.val
        end
        local count = limit_count - my_info.recruit_num
        if count <= 0 then
            message(TI18N("当天招募次数已用完"))
            return
        end
        local extend_msg2= string.format(TI18N("<div fontcolor=#68452a>剩余次数：%s</div>"), count)
        list[2] = {extend_type = CommonAlert.type.rich, extend_size = 24, extend_str = extend_msg2, extend_offy = - 55, extend_aligment = cc.TEXT_ALIGNMENT_CENTER }

        if my_info.recruit_num == 0 then
            local msg = TI18N("是否确定发布招募公告？")
            local extend_msg = TI18N("（每日首次发布公告免费）")

            list[1] = {extend_str = extend_msg, extend_offy = - 5, extend_aligment = cc.TEXT_ALIGNMENT_CENTER }
            

            CommonAlert.show(msg, TI18N("确定"), function()
                self:SendProtocal(13558, {})
            end, TI18N("取消"), nil, nil, nil, {off_y = 43, extend_list = list}, nil, nil)
        else
            local config = Config.GuildData.data_const.recruit_cost
            local role_vo = RoleController:getInstance():getRoleVo()
            if config and role_vo then
                local total = role_vo.gold + role_vo.red_gold
                local msg = string.format(TI18N("是否确定花费<img src=%s visible=true scale=0.35 />%s发布招募广告？"), PathTool.getItemRes(15), config.val)
                local extend_msg = string.format("%s<img src=%s visible=true scale=0.35 />%s/%s", TI18N("发布消耗："), PathTool.getItemRes(15),  MoneyTool.GetMoneyString(total), config.val)

                list[1] = {extend_type = CommonAlert.type.rich, extend_str = extend_msg, extend_offy = - 5, extend_aligment = cc.TEXT_ALIGNMENT_CENTER}
                CommonAlert.show(msg, TI18N("确定"), function()
                    self:SendProtocal(13558, {})
                end, TI18N("取消"), nil, CommonAlert.type.rich, nil, {off_y = 43, extend_list = list}, nil, nil)
            end
        end
    end
end

--==============================--
--desc:招募广告返回
--time:2018-06-05 04:37:47
--@data:
--@return 
--==============================--
function GuildController:handle13558(data)
    message(data.msg)
end

--==============================--
--desc:公会申请红点
--time:2018-06-07 09:37:51
--@data:
--@return 
--==============================--
function GuildController:handle13573(data)
    self.model:updateGuildRedStatus(GuildConst.red_index.apply, (data.code == TRUE))
end

--==============================--
--desc:有玩家申请加入的提示，
--time:2018-06-07 09:36:29
--@data:
--@return 
--==============================--
function GuildController:setApplyListStatus(data)
    self.model:updateGuildRedStatus(GuildConst.red_index.apply, true) 
end

--==============================--
--desc:请求领取指定捐献宝箱
--time:2018-07-11 02:28:02
--@box_id:
--@return 
--==============================--
function GuildController:requestDonateBoxRewards(box_id)
    local protocal = {}
    protocal.box_id = box_id
    self:SendProtocal(13574, protocal)
end

--==============================--
--desc:领取捐献宝箱返回
--time:2018-07-11 02:26:45
--@data:
--@return 
--==============================--
function GuildController:handle13574(data)
    message(data.msg)
    if data.code == TRUE then
        self.model:setDonateBoxStatus(data.box_id)
    end
end

--==============================--
--desc:更新捐献进度值
--time:2018-07-11 02:26:55
--@data:
--@return 
--==============================--
function GuildController:handle13575(data)
    self.model:updateDonateActivity(data.donate_exp)
end 

function GuildController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
    if self.role_vo ~= nil then
        if self.role_assets_event ~= nil then
            self.role_vo:UnBind(self.role_assets_event)
            self.role_assets_event = nil
        end
        self.role_vo = nil
    end
end

function GuildController:welcomeNewMember(rid, srv_id)
    local protocal = {}
    protocal.rid = rid
    protocal.srv_id = srv_id
    self:SendProtocal(13576, protocal)
end

function GuildController:handle13576(data)
    message(data.msg)
end

--********公会活跃

--基本信息
function GuildController:send16900()
    self:SendProtocal(16900, {})
end
function GuildController:handle16900(data)
    self.model:updataGuildActionRedStatus(data)
    GlobalEvent:getInstance():Fire(GuildEvent.UpdataGuildGoalBasicData, data)
end

--任务信息
function GuildController:send16901()
    self:SendProtocal(16901, {})
end
function GuildController:handle16901(data)
    GlobalEvent:getInstance():Fire(GuildEvent.UpdataGuildGoalTaskData, data)
end

--单条任务信息
function GuildController:handle16902(data)
    GlobalEvent:getInstance():Fire(GuildEvent.UpdataGuildGoalSingleTaskData, data)
end

--提交任务
function GuildController:send16903(id)
    local protocal = {}
    protocal.id = id
    self:SendProtocal(16903, protocal)
end
function GuildController:handle16903(data)
    message(data.msg)
end

function GuildController:send16904()
    self:SendProtocal(16904, {})
end
function GuildController:handle16904(data)
    message(data.msg)
end

-------------------公会日志和邮件--------------------
--获取公会日志列表
function GuildController:send13577()
    self:SendProtocal(13577, {})
end
function GuildController:handle13577(data)
    self.model:initGuildNoticeList(data.guild_log_info_list)
end

--新增日志
function GuildController:handle13578(data)
    self.model:addGuildNoticeItem(data.guild_log_info_list)
    self.model:updateGuildRedStatus(GuildConst.red_index.notice, true)
end

--公会一键提醒
function GuildController:send13579(type, id_list)
    local protocal = {}
    protocal.type = type
    protocal.id_list = id_list
    self:SendProtocal(13579, protocal)
end
function GuildController:handle13579(data)
    message(data.msg)
end

--公会发送邮件
function GuildController:send13580(content)
    local protocal = {}
    protocal.content = content
    self:SendProtocal(13580, protocal)
end
function GuildController:handle13580(data)
    message(data.msg)
end
----------------------------------------------------

--==============================--
--desc:更新技能首次红点
--time:2020-4-17 09:36:29
--@data:
--@return 
--==============================--
function GuildController:updateSkillFirstRedPoint()
    if self.role_vo and self.role_vo.gid ~= 0 and self.role_vo.gsrv_id ~= "" then --表示有公会
        local red_status = RoleController:getInstance():getModel():getRedPointStatus(RoleConst.red_point.red_point_2)
        self.model:updateGuildRedStatus(GuildConst.red_index.all_skill, red_status) 
    end
end
