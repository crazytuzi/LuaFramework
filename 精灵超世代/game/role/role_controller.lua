--[[
    * 类注释写在这里-----------------
    * @author {AUTHOR}
    * <br/>Create: 2016-12-09
]]
RoleController = RoleController or BaseClass(BaseController)

-- DO_NOT_REALNAME_STATUS              是不是没有实名认证
-- OPEN_SDK_VISITIOR_WINDOW            是否打开了可取消的实名认证窗体
-- NEED_OPEN_OPEN_SDK_VISITIOR_WINDOW  是否需要打开无取消的实名认证窗体

function RoleController:config()
    self.model = RoleModel.New(self)
    self.dispather = GlobalEvent:getInstance()
    self.apk_data = nil
    self.is_re_connect = false
    get_apk_url(function(data)
        if data.success == true then
            self.apk_data = data
        end
    end)
end

function RoleController:getModel()
    return self.model
end

function RoleController:setReconnect(status)
    self.is_re_connect = status
end

function RoleController:registerEvents()

    --基础属性设置完毕
    if not self.role_vo_event then 
        self.role_vo_event = GlobalEvent:getInstance():Bind(RoleEvent.UPDATE_ROLE_BASE_ATTR,function ()
            if self.cache_list and next(self.cache_list) ~=nil then 
                local role_vo = self:getRoleVo()
                if role_vo then 
                    role_vo:setRoleAttribute(self.cache_list.key,self.cache_list.value)
                    self.cache_list = nil
                end
            end
        end)
    end
end

function RoleController:registerProtocals()
    self:RegisterProtocal(10301, "rgp_hander10301")  --角色基础信息
    self:RegisterProtocal(10302, "rgp_hander10302")  --角色资产信息
    self:RegisterProtocal(10305, "rgp_hander10305")  --资产改变

    -- self:RegisterProtocal(10303, "rgp_hander10303")  --角色资产信息

    self:RegisterProtocal(10306, "rgp_hander10306")  --角色战力变更推送
    self:RegisterProtocal(10307, "rgp_hander10307")  --更新角色事件数据
    self:RegisterProtocal(10309, "rgp_hander10309")  --个人签名修改
    self:RegisterProtocal(10315, "rgp_hander10315")  --查看角色信息

    self:RegisterProtocal(10316, "rgp_hander10316")  --膜拜角色
    self:RegisterProtocal(10318, "rgp_hander10318")  --pk验证角色

    self:RegisterProtocal(10325, "rgp_hander10325")  --头像列表
    self:RegisterProtocal(10327, "rgp_hander10327")  --设置头像

    self:RegisterProtocal(10342, "rgp_hander10342")  --强制改名字
    self:RegisterProtocal(10343, "rgp_hander10343")  --改名字

    self:RegisterProtocal(10345, "rgp_hander10345")  --形象信息
    self:RegisterProtocal(10346, "rgp_hander10346")  --形象使用
    self:RegisterProtocal(10347, "rgp_hander10347")  --激活形象

    self:RegisterProtocal(10317, "rgp_hander10317")  --自己被点赞数量
    self:RegisterProtocal(10319, "rgp_hander10319")  --周冠军赛被点赞次数

    self:RegisterProtocal(12745, "rgp_hander12745")  --资产信息不足提示
    self:RegisterProtocal(12746, "rgp_hander12746")  --物品不足弹来源途径

    self:RegisterProtocal(10995, "rgp_hander10995")  --角色主服务器数据

    self:RegisterProtocal(21500, "rgp_hander21500")  --头像框列表
    self:RegisterProtocal(21501, "rgp_hander21501")  --使用头像框
    self:RegisterProtocal(21502, "rgp_hander21502")  --更新头像框列表
    self:RegisterProtocal(21503, "rgp_hander21503")  --激活头像框列表

    self:RegisterProtocal(12700, "rgp_hander12700")  --聊天框列表
    self:RegisterProtocal(12701, "rgp_hander12701")  --使用聊天框
    self:RegisterProtocal(12702, "rgp_hander12702")  --更新聊天框列表
    self:RegisterProtocal(12703, "rgp_hander12703")  --激活聊天框列表

    self:RegisterProtocal(10380, "rgp_hander10380")  --获取玩家的注册天数跟当前服的开服天数

    self:RegisterProtocal(23300, "hander23300")      --称号列表
    self:RegisterProtocal(23301, "hander23301")      --使用称号
    self:RegisterProtocal(23302, "hander23302")      --更新称号数据
    self:RegisterProtocal(23303, "hander23303")      --激活称号

    self:RegisterProtocal(10945, "handle10945")     --礼包兑换

    self:RegisterProtocal(10994, "handle10994")     -- 服务端通知整点更新

    self:RegisterProtocal(10905, "handle10905")     -- 世界等级
    self:RegisterProtocal(10906, "handle10906")     -- 开服天数更新
    self:RegisterProtocal(10907, "handle10907")     -- 应国家要求做的屏蔽

    self:RegisterProtocal(10395, "handle10395")     -- 客户端通知查验身份认证（防沉迷）
    self:RegisterProtocal(12744, "handle12744")     -- 通用弹窗提示


    self:RegisterProtocal(10350, "handle10350")     -- 获取活动资产id
    self:RegisterProtocal(10351, "handle10351")     -- 推送活动资产id 

    self:RegisterProtocal(24500, "handle24500")     -- 特权激活情况 

    self:RegisterProtocal(12770, "handle12770")     -- 发送举报协议
    self:RegisterProtocal(12771, "handle12771")     -- 获取举报协议信息
    self:RegisterProtocal(12772, "handle12772")     -- 有参数的提示语

    --个人空间信息
    self:RegisterProtocal(25800, "handle25800")     -- 设置城市信息
    self:RegisterProtocal(25801, "handle25801")     -- 关注/取消关注
    self:RegisterProtocal(25802, "handle25802")     -- 粉丝排行榜协议

    --荣誉榜
    self:RegisterProtocal(25805, "handle25805")     -- 设置徽章使用
    self:RegisterProtocal(25806, "handle25806")     -- 请求所有徽章
    self:RegisterProtocal(25807, "handle25807")     -- 激活徽章推送
    
    
    self:RegisterProtocal(25815, "handle25815")     -- 徽章分享
    self:RegisterProtocal(25816, "handle25816")     -- 查看徽章分享

    self:RegisterProtocal(25817, "handle25817")     -- 历练任务 成就分享
    self:RegisterProtocal(25818, "handle25818")     -- 查看成就分享

    self:RegisterProtocal(25819, "handle25819")     -- 荣誉分享 荣誉等级
    self:RegisterProtocal(25820, "handle25820")     -- 查看荣誉分享 荣誉等级

    --成长之路
    self:RegisterProtocal(25830, "handle25830")     -- 查看成长之路
    self:RegisterProtocal(25831, "handle25831")     -- 查看成长之路分享
    self:RegisterProtocal(25832, "handle25832")     -- 查看成长之路分享
    self:RegisterProtocal(25833, "handle25833")     -- 成长之路嘉年华信息

    --留言板
    self:RegisterProtocal(25835, "handle25835")     -- 留言板留言
    self:RegisterProtocal(25836, "handle25836")     -- 留言板留言回复
    self:RegisterProtocal(25837, "handle25837")     -- 获取留言板留言信息
    self:RegisterProtocal(25838, "handle25838")     -- 删除留言板信息
    self:RegisterProtocal(25839, "handle25839")     -- 设置留言板回复权限    
    self:RegisterProtocal(25840, "handle25840")     -- 消除 气泡红点
    self:RegisterProtocal(25841, "handle25841")     -- 新增留言推送

    --隐藏的 家园成就 推送
    self:RegisterProtocal(25813, "handle25813")     -- 点击了隐藏成就
    self:RegisterProtocal(25814, "handle25814")     -- 请求要不要弹隐藏成就

    
    self:RegisterProtocal(10328, "handle10328")     -- 请求个人空间背景列表
    self:RegisterProtocal(10329, "handle10329")     -- 设置个人空间背景

    --实名认证
    self:RegisterProtocal(10960, "handle10960")     --实名认证奖励是否领取
    self:RegisterProtocal(10961, "handle10961")     --领取实名认证奖励

    -- 自定义头像
    self:RegisterProtocal(10330, "handle10330")
    self:RegisterProtocal(10332, "handle10332")
    self:RegisterProtocal(10333, "handle10333")

    -- 活动推送
    self:RegisterProtocal(10360, "handle10360")

    -- 第三方充值
    self:RegisterProtocal(10947, "handle10947")

    -- 红点系列已点过的红点
    self:RegisterProtocal(10985, "handle10985")
    -- 消除红点
    self:RegisterProtocal(10986, "handle10986")
end

--[[ 获得主角数据 ]]
function RoleController:getRoleVo()
    return self.model:getRoleVo()
end

--判断别人srv_id是不是与自己是不是同服
function RoleController:isTheSameSvr(srv_id)
    local role_vo = self:getRoleVo()
    local is_same = self.model:isTheSame(srv_id)

    if  srv_id and is_same then 
        return true
    else
        return false
    end
end

--[[ 判断一个人是否是自己 ]]
function RoleController:checkIsSelf(srv_id, rid)
    local role_vo = self:getRoleVo()
    if role_vo == nil then
        return false 
    else
        return role_vo.srv_id==srv_id and role_vo.rid==rid
    end
end

--[[ 角色基础信息 ]]
function RoleController:rgp_hander10301(data)
    self.model:initRoleBaseData(data)

    if not self.init_role then
        self.init_role = true
        RoleEnv:getInstance():load()

        -- 派发事件,角色登陆成功
        GlobalEvent:getInstance():Fire(EventId.ROLE_CREATE_SUCCESS)

        -- 请求自定义头像相关信息
        self:requestCustomHeadInfo()

        -- 添加GMCMD命令
        ViewManager:getInstance():initMainFunBar()

        self:sender10907() --屏蔽功能 --应该是最优先的
        -- 上线时请求
        SysController:getInstance():requestLoginProtocals()

        -- 缓存一下登陆的角色数据
        LoginController:getInstance():getModel():cacheNearLoginData(nil, data.rid, data.srv_id)

        -- sdk等级计算
        sdkSubmitUserData(3)  

        -- 防沉迷请求, 新包直接用sdk的年龄去判断实名制,旧包应该只要处理买量服的,
        if IS_NEED_REAL_NAME == true then
            if NEW_REAL_NAME_FLAG == true then
                local age = queryRealNameInfo()
                if age ~= "" then
                    if PLATFORM_NAME == "9377" then
                        RoleController:getInstance():sender10395(tonumber(age))
                    end
                end
            else
                RoleController:getInstance():sender10395(-1)
            end
        end
        sdkOnEnterServer()
    end
    
    if self.is_re_connect == true then
        self:SendProtocal(10380, {})  -- 后端要求断线重连时,请求一下开服天数数据
        GlobalEvent:getInstance():Fire(LoginEvent.RE_LINK_GAME)
        self.is_re_connect = false
        if CommonNumClearRes then
            CommonNumClearRes()--断线重连后.移除一下必要资源.
        end
        self:sender10907() --屏蔽功能
    end
    sdkUserEvent("af_startGame")
end

--[[ 角色资产信息 ]]
function RoleController:rgp_hander10302(data)
    -- dump(data)
    self.model:initRoleAssetsData(data)
end


--[[活动资产推送]] --登陆的时候推送
function RoleController:handle10350(data)
    self.model:initRoleActionAssetsData(data.holiday_assets, false)
end
--[[活动资产推送]] --变化的时候推送
function RoleController:handle10351(data)
    self.model:initRoleActionAssetsData(data.holiday_assets, true)
end

-- [[ 请求体力数据 ]]
function RoleController:requestEnergyData()
    -- local protocal = {}
    -- self:SendProtocal(10303, protocal)
end

-- [[ 体力信息 ]]
function RoleController:rgp_hander10303(data)
    -- self.model:initRoleAssetsData(data)
end

-- -- [[ 请求竞技劵信息]]
-- function RoleController:requestArenaTicketData()
--     local protocal = {}
--     self:SendProtocal(10306, protocal)
-- end

function RoleController:rgp_hander10307(data)
    local role = self:getRoleVo()
    if role ~= nil then
        role:setRoleAttribute("event", data.event)
    end
end

-- 更新人物战力
function RoleController:rgp_hander10306(data)
    local role = self:getRoleVo()
    if role and role.power then 
        -- local in_fight = BattleController:getInstance():isInFight() or false
        -- local is_story_state = StoryController:getInstance():getModel():isStoryState() or false 
        -- if in_fight == false and self.is_show_power == true and is_story_state==false then
        if self.is_show_power == true then
            local power = data.power - role.power or 0
            if power >0 then
                GlobalMessageMgr:getInstance():showPowerMove(power,nil,role.power)
            end
        end
        role:setPower(data.power)    
        role:setMaxPower(data.max_power)
    end
    self:showPower(false)
end
function RoleController:showPower(bool)
    self.is_show_power= bool
end
--[[ 资产改变 ]]
function RoleController:rgp_hander10305(data)
    local assets = data.assets
    if assets and next(assets) ~= nil then
        self.model:updateRoleAssets(assets)
    end
end
--角色主服务器
function RoleController:rgp_hander10995(data)
    if not data then return end
    local role_vo = self:getRoleVo()
    if role_vo then 
        if data.main_srv_id then 
            role_vo:setRoleAttribute("main_srv_id",data.main_srv_id)
        end
        self.model:setServerList(data.srv_list)
    else 
        self.cache_list = {key="main_srv_id",value =data.main_srv_id }
    end
end

-- [[ 头像框列表 ]]
function RoleController:sender21500()
    local protocal = {}
    self:SendProtocal(21500, protocal)
end

-- [[ 头像框列表 ]]
function RoleController:rgp_hander21500(data)
    GlobalEvent:getInstance():Fire(RoleEvent.GetFaceList,data)
end


-- [[ 使用头像框 ]]
function RoleController:sender21501(base_id)
    local protocal = {}
    protocal.base_id = base_id
    self:SendProtocal(21501, protocal)
end

-- [[ 使用头像框 ]]
function RoleController:rgp_hander21501(data)
    -- GlobalEvent:getInstance():Fire(RoleEvent.UseFaceItem,data)
end

-- [[ 更新头像框列表 ]]
function RoleController:rgp_hander21502(data)
    GlobalEvent:getInstance():Fire(RoleEvent.GetFaceList,data)
end

-- [[ 激活头像框 ]]
function RoleController:sender21503(base_id)
    local protocal = {}
    protocal.base_id = base_id
    self:SendProtocal(21503, protocal)
end

-- [[ 激活头像框 ]]
function RoleController:rgp_hander21503(data)
    GlobalEvent:getInstance():Fire(RoleEvent.GetFaceList,data)
end


-- [[ 聊天框列表 ]]
function RoleController:sender12700()
    local protocal = {}
    self:SendProtocal(12700, protocal)
end

-- [[ 聊天框列表 ]]
function RoleController:rgp_hander12700(data)
    GlobalEvent:getInstance():Fire(RoleEvent.GetBubbleList,data)
end


-- [[ 使用聊天框 ]]
function RoleController:sender12701(base_id)
    local protocal = {}
    protocal.base_id = base_id
    self:SendProtocal(12701, protocal)
end

-- [[ 使用聊天框 ]]
function RoleController:rgp_hander12701(data)
    GlobalEvent:getInstance():Fire(RoleEvent.UseBubbleItem,data)
end

-- [[ 更新聊天框列表 ]]
function RoleController:rgp_hander12702(data)

    GlobalEvent:getInstance():Fire(RoleEvent.GetBubbleList,data)
end

-- [[ 激活聊天框 ]]
function RoleController:sender12703(base_id)
    local protocal = {}
    protocal.base_id = base_id
    self:SendProtocal(12703, protocal)
end

-- [[ 激活聊天框 ]]
function RoleController:rgp_hander12703(data)
    GlobalEvent:getInstance():Fire(RoleEvent.GetBubbleList,data)
end
function RoleController:rgp_hander10380(data)
    self.model:setSrvDay(data)
end

-- 点击了隐藏成就
function RoleController:sender25813(id)
    local protocal = {}
    protocal.id = id
    self:SendProtocal(25813, protocal)
end

function RoleController:handle25813(data)

end

-- 请求要不要弹隐藏成就
function RoleController:sender25814()
    local protocal = {}
    self:SendProtocal(25814, protocal)
end

function RoleController:handle25814(data)
    if MAKELIFEBETTER == true then
        --审核服不弹
        return 
    end
    --屏蔽家园
    if IS_HIDE_HOMEWORLD then
        return
    end
    if data.result == 1 then
        --要弹隐藏成就
        local config = Config.RoomFeatData.data_const.home_world_feat
        if config then
            self:openRoleAchieveWindow(true, {id = config.val, view_tag = ViewMgrTag.LOADING_TAG})
        end
        
    end
end

 -- 请求个人空间背景列表
function RoleController:sender10328()
    local protocal = {}
    self:SendProtocal(10328, protocal)
end

function RoleController:handle10328(data)
    GlobalEvent:getInstance():Fire(RoleEvent.ROLE_BACKGROUND_LIST_EVENT,data)
end

 -- 设置个人空间背景
function RoleController:sender10329(backdrop_id)
    local protocal = {}
    protocal.backdrop_id = backdrop_id
    self:SendProtocal(10329, protocal)
end

function RoleController:handle10329(data)
    if data.code == TRUE then
        message(TI18N("设置空间背景成功"))
        self.model:setRoleAttribute("backdrop_id",data.backdrop_id)
    end
end

-- --打开角色面板
-- function RoleController:openNewRoleInfoView( status )
--     if status == true then
--         if self.role_info_new == nil then
--             self.role_info_new = RoleSetWindow.New(self)
--         end
--         self.role_info_new:open()
--     else
--         if self.role_info_new ~= nil then
--             self.role_info_new:close()
--             self.role_info_new = nil
--         end
--     end
-- end



-- --打开系统设置
function RoleController:openRoleSystemSetPanel(status)
    if status == true then
        if self.role_system_set_panel == nil then
            self.role_system_set_panel = RoleSystemSetPanel.New()
        end
        self.role_system_set_panel:open()
    else
        if self.role_system_set_panel ~= nil then
            self.role_system_set_panel:close()
            self.role_system_set_panel = nil
        end
    end
end

-- --打开展示队伍界面
function RoleController:openRoleHeroShowFormPanel(status, setting)
    if status == true then
        if self.role_hero_show_form_panel == nil then
            self.role_hero_show_form_panel = RoleHeroShowFormPanel.New()
        end
        self.role_hero_show_form_panel:open(setting)
    else
        if self.role_hero_show_form_panel ~= nil then
            self.role_hero_show_form_panel:close()
            self.role_hero_show_form_panel = nil
        end
    end
end

--打开新的角色面板 个人空间
function RoleController:openRolePersonalSpacePanel( status, setting )
    local setting = setting or {}
    local role_type = setting.role_type or RoleConst.role_type.eMySelf

   
    if role_type == RoleConst.role_type.eOther then
        --由于会出现嵌套打开同一个ui界面..这里相当于初始化两个
        self:openOtherRolePersonalSpacePanel(status, setting)
    else
        if status == true then
            if self.role_personal_space_panel  then
                self.role_personal_space_panel:close()
                self.role_personal_space_panel = nil
            end
            if self.role_personal_space_panel == nil then
                self.role_personal_space_panel = RolePersonalSpacePanel.New(self)
            end
            self.role_personal_space_panel:open(setting)
        else
            if self.role_personal_space_panel ~= nil then
                self.role_personal_space_panel:close()
                self.role_personal_space_panel = nil
            end
        end    
    end
end

function RoleController:openOtherRolePersonalSpacePanel( status, setting )
    if status == true then
        if self.role_other_personal_space_panel ~= nil then
            self.role_other_personal_space_panel:close()
            self.role_other_personal_space_panel = nil
        end

        if self.role_other_personal_space_panel == nil then
            self.role_other_personal_space_panel = RolePersonalSpacePanel.New(self)
        end
        self.role_other_personal_space_panel:open(setting)
    else
        if self.role_other_personal_space_panel ~= nil then
            self.role_other_personal_space_panel:close()
            self.role_other_personal_space_panel = nil
        end
    end    
end

--打开展示设置
function RoleController:openRoleSelectHonorListPanel(status, setting)
    if status == true then
        if self.role_select_honor_list_panel == nil then
            self.role_select_honor_list_panel = RoleSelectHonorListPanel.New(self)
        end
        self.role_select_honor_list_panel:open(setting)
    else
        if self.role_select_honor_list_panel ~= nil then
            self.role_select_honor_list_panel:close()
            self.role_select_honor_list_panel = nil
        end
    end
end

--激活解锁
function RoleController:openRoleHonorUnlockPanel(status, setting)
    if status == true then
        if self.role_honor_unlock_panel == nil then
            self.role_honor_unlock_panel = RoleHonorUnlockPanel.New(self)
        end
        self.role_honor_unlock_panel:open(setting)
    else
        if self.role_honor_unlock_panel ~= nil then
            self.role_honor_unlock_panel:close()
            self.role_honor_unlock_panel = nil
        end
    end
end

--隐藏成就
function RoleController:openRoleAchieveWindow(status, data)
    if status == true then
        if self.role_achieve_view == nil then
            local view_tag
            if data and type(data) == "table" then
                view_tag = data.view_tag
            end
            self.role_achieve_view = RoleAchieveWindow.New(view_tag)
        end
        if self.role_achieve_view then
            self.role_achieve_view:open(data)
        end
    else
        if self.role_achieve_view ~= nil then
            self.role_achieve_view:close()
            self.role_achieve_view = nil
            GlobalEvent:getInstance():Fire(BattleEvent.NEXT_SHOW_RESULT_VIEW)
        end
    end
end

function RoleController:openRoleMessageBoardReplyPanel(status, setting)
    if status == true then
        if self.role_message_board_reply_panel == nil then
            self.role_message_board_reply_panel = RoleMessageBoardReplyPanel.New(self)
        end
        if self.role_message_board_reply_panel then
            self.role_message_board_reply_panel:open(setting)
        end
    else
        if self.role_message_board_reply_panel ~= nil then
            self.role_message_board_reply_panel:close()
            self.role_message_board_reply_panel = nil
        end
    end
end

--打开实名认证面板
function RoleController:openRoleAttestationWindow( status )
    if status == true then
        if self.role_attestation_window == nil then
            self.role_attestation_window = RoleAttestationWindow.New(self)
        end
        self.role_attestation_window:open()
    else
        if self.role_attestation_window ~= nil then
            self.role_attestation_window:close()
            self.role_attestation_window = nil
        end
    end
end

--打开改名改性别面板
function RoleController:openRoleChangeNameView( status )
    if status == true then
            if self.role_change_name_view == nil then
                self.role_change_name_view = RoleChangeView.New(self)
            end
            if self.role_change_name_view:isOpen() == false and self.role_change_name_view then
                self.role_change_name_view:open()
            end
    else
        if self.role_change_name_view ~= nil then
            self.role_change_name_view:close()
            self.role_change_name_view = nil
        end
    end
end

---打开更改装饰界面
function RoleController:openRoleDecorateView( status, index, setting)
    if status == true then
        if self.role_decorate_new == nil then
            self.role_decorate_new = RoleDecorateWindow.New(self)
        end
        self.role_decorate_new:open(index, setting)
    else
        if self.role_decorate_new ~= nil then
            self.role_decorate_new:close()
            self.role_decorate_new = nil
        end
    end
end

--打开设置名称界面
function RoleController:openRoleSetNameView( status )
    xprint("打开设置名称界面")
    if status == true then
        if self.role_setname_new == nil then
            self.role_setname_new = RoleSetNameView.New(self)
        end
        self.role_setname_new:open()
    else
        if self.role_setname_new ~= nil then
            self.role_setname_new:close()
            self.role_setname_new = nil
        end
    end
end

-- 取名界面是否正在显示
function RoleController:checkRoleSetNameViewIsOpen(  )
    if self.role_setname_new then
        return true
    end
    return false
end

-----------------------------------------------举报功能协议和打开方法-------------------------
function RoleController:send12770(rid, srv_id, _type, msg, history)
    local protocal = {}
    protocal.rid = rid
    protocal.srv_id = srv_id
    protocal.type = _type or 1
    protocal.msg = msg or ""
    protocal.history = history or {}
    self:SendProtocal(12770, protocal)
end
function RoleController:handle12770(data)
    message(data.msg)
end

function RoleController:send12771(rid, srv_id)
    local protocal = {}
    protocal.rid = rid
    protocal.srv_id = srv_id
    self:SendProtocal(12771, protocal)
end
function RoleController:handle12771(data)
    GlobalEvent:getInstance():Fire(RoleEvent.ROLE_REPORTED_EVENT, data)
end

function RoleController:handle12772(data)
    if data then
        local time = data.end_time - GameNet:getInstance():getTime()
        message(string.format(data.msg, TimeTool.GetTimeFormatDay2(time)))
    end
end


--打开举报界面
function RoleController:openRoleReportedPanel(status, rid, srv_id, play_name)
    if status == true then
        if self.role_reported_panel == nil then
            self.role_reported_panel = RoleReportedPanel.New(self)
        end
        self.role_reported_panel:open(rid, srv_id, play_name)
    else
        if self.role_reported_panel ~= nil then
            self.role_reported_panel:close()
            self.role_reported_panel = nil
        end
    end
end
-----------------------------------------------举报功能协议和打开方法结束-------------------------

-----------------------------------------------个人空间功能协议开始-------------------------

function RoleController:send25800(city_id)
    local protocal = {}
    protocal.city_id = city_id
    self:SendProtocal(25800, protocal)
end
function RoleController:handle25800(data)
    message(data.msg)
    if data.code == TRUE then
        GlobalEvent:getInstance():Fire(RoleEvent.ROLE_CITY_EVENT, data)
    end
end

function RoleController:send25801(rid, srv_id)
    local protocal = {}
    protocal.rid = rid
    protocal.srv_id = srv_id
    self:SendProtocal(25801, protocal)
end
function RoleController:handle25801(data)
    message(data.msg)
    if data.code == TRUE then
        GlobalEvent:getInstance():Fire(RoleEvent.ROLE_FOLLOW_EVENT, data)
    end
end

function RoleController:send25802()
    local protocal = {}
    self:SendProtocal(25802, protocal)
end

function RoleController:handle25802(data)
    self.model.fans_rank_data = data
    GlobalEvent:getInstance():Fire(RoleEvent.ROLE_FANS_RANK_EVENT, data)
end

--荣誉墙
--设置徽章使用
function RoleController:send25805(pos, id)
    local protocal = {}
    protocal.pos = pos
    protocal.id = id
    self:SendProtocal(25805, protocal)
end

function RoleController:handle25805(data)
    GlobalEvent:getInstance():Fire(RoleEvent.ROLE_UPDATE_HONOR_WALL_EVENT, data)
end

--请求所有徽章
function RoleController:send25806(rid, srv_id)
    local protocal = {}
    protocal.rid = rid
    protocal.srv_id = srv_id
    self:SendProtocal(25806, protocal)
end

function RoleController:handle25806(data)
    GlobalEvent:getInstance():Fire(RoleEvent.ROLE_GET_HONOR_WALL_EVENT, data)
end
   
-- 激活徽章推送
function RoleController:handle25807(data)
    if data and data.id then
        self:openRoleHonorUnlockPanel(true, data)
    end
end

--分享协议
--徽章分享 --
function RoleController:send25815(id, channel)
    local protocal = {}
    protocal.id = id
    protocal.channel = channel
    self:SendProtocal(25815, protocal)
end

function RoleController:handle25815(data)
    message(data.msg)
end
-- 查看徽章分享
--@role_data 是 10315的协议信息
function RoleController:send25816(share_id, srv_id, role_data)
    if self.dic_share_info_25816 == nil then
        self.dic_share_info_25816 = {}
    end
    self.dic_share_info_25816[share_id] = role_data

    local protocal = {}
    protocal.share_id = share_id
    protocal.srv_id = srv_id
    self:SendProtocal(25816, protocal)
end

function RoleController:handle25816(data)
    if self.dic_share_info_25816 and self.dic_share_info_25816[data.share_id] then
        local setting = {}
        setting.id = data.id
        setting.show_type = RoleConst.role_type.eOther
        setting.have_name = self.dic_share_info_25816[data.share_id].name
        setting.have_time = data.finish_time
        TipsController:getInstance():openHonorIconTips(true, setting)
        self.dic_share_info_25816[data.share_id] = nil
    end 
end

--历练任务 成就分享
function RoleController:send25817(id, channel)
    local protocal = {}
    protocal.id = id
    protocal.channel = channel
    self:SendProtocal(25817, protocal)
end

function RoleController:handle25817(data)
    message(data.msg)
end
-- 查看成就分享
--@role_data 是 10315的协议信息
function RoleController:send25818(share_id, srv_id, role_data)
    if self.dic_share_info_25818 == nil then
        self.dic_share_info_25818 = {}
    end
    self.dic_share_info_25818[share_id] = role_data

    local protocal = {}
    protocal.share_id = share_id
    protocal.srv_id = srv_id
    self:SendProtocal(25818, protocal)
end

function RoleController:handle25818(data)
    if self.dic_share_info_25818[data.share_id] then
        local setting = {}
        setting.id = data.id
        setting.have_name = self.dic_share_info_25818[data.share_id].name
        setting.finish_time = data.finish_time
        TipsController:getInstance():openTaskExpTips(true, setting)
        self.dic_share_info_25818[data.share_id] = nil
    end 
end

--荣誉分享 荣誉等级
function RoleController:send25819(channel)
    local protocal = {}
    protocal.channel = channel
    self:SendProtocal(25819, protocal)
end

function RoleController:handle25819(data)
    message(data.msg)
end
-- 查看荣誉分享" 荣誉等级
--@role_data 是 10315的协议信息
function RoleController:send25820(share_id, srv_id, role_data)

    if self.dic_share_info_25820 == nil then
        self.dic_share_info_25820 = {}
    end
    self.dic_share_info_25820[share_id] = role_data

    local protocal = {}
    protocal.share_id = share_id
    protocal.srv_id = srv_id
    self:SendProtocal(25820, protocal)
end

function RoleController:handle25820(data)
    if self.dic_share_info_25820[data.share_id] then
        local setting = {}
        setting.point = data.point
        setting.num = data.num
        setting.role_data = self.dic_share_info_25820[data.share_id]
        TipsController:getInstance():openHonorLevelTips(true, setting)
        self.dic_share_info_25820[data.share_id] = nil
    end 
end

--查看成长之路 
function RoleController:send25830(start, num)
    local protocal = {}
    protocal.start = start
    protocal.num = num
    self:SendProtocal(25830, protocal)
end



function RoleController:handle25830(data)
    --num等于1是计算红点用途
    if data.num == 1 then
        data.is_redpoint = self.model:checkGrowthWayRedPoint(data)
    end
    self.model:setGrowthWayData(data)
    GlobalEvent:getInstance():Fire(RoleEvent.ROLE_MYSELF_GROWTH_WAY_EVENT, data)
end

--成长之路分享
function RoleController:send25831(channel)
    local protocal = {}
    protocal.channel = channel
    self:SendProtocal(25831, protocal)
end

function RoleController:handle25831(data)
    message(data.msg)
end
-- 查看成长之路分享
function RoleController:send25832(rid, srv_id, start, num)
    local protocal = {}
    protocal.rid = rid
    protocal.srv_id = srv_id
    protocal.start = start
    protocal.num = num
    self:SendProtocal(25832, protocal)
end

function RoleController:handle25832(data)
    self.model:setOtherGrowthWayData(data)
    GlobalEvent:getInstance():Fire(RoleEvent.ROLE_OHTER_GROWTH_WAY_EVENT, data)
end

--成长之路嘉年华数据
function RoleController:handle25833(data)
    self.model:setGrowthWayCarnivalData(data)
end

----------------留言板功能

--留言板留言
function RoleController:send25835(rid, srv_id, msg)
    local protocal = {}
    protocal.rid = rid
    protocal.srv_id = srv_id
    protocal.msg = msg
    self:SendProtocal(25835, protocal)
end

function RoleController:handle25835(data)
    message(data.msg)
end

--留言板留言回复
function RoleController:send25836(rid, srv_id, bbs_id, msg)
    local protocal = {}
    protocal.rid = rid
    protocal.srv_id = srv_id
    protocal.bbs_id = bbs_id --"留言板id"
    protocal.msg = msg
    self:SendProtocal(25836, protocal)
end

function RoleController:handle25836(data)
    message(data.msg)
    GlobalEvent:getInstance():Fire(RoleEvent.ROLE_MESSAGE_BOARD_REPLY_EVENT, data)
end

--留言板留言回复
function RoleController:send25837(rid, srv_id, start, num)
    local protocal = {}
    protocal.rid = rid
    protocal.srv_id = srv_id
    protocal.start = start
    protocal.num = num
    self:SendProtocal(25837, protocal)
end

function RoleController:handle25837(data)
    self.model:initMessageBoardData(data)
    GlobalEvent:getInstance():Fire(RoleEvent.ROLE_MESSAGE_BOARD_GET_INFO_EVENT, data)
end

--新增留言推送
function RoleController:handle25841(data)
    self.model:initMessageBoardData(data)
    GlobalEvent:getInstance():Fire(RoleEvent.ROLE_MESSAGE_BOARD_NEW_INFO_EVENT, data)
end

--删除留言板信息
function RoleController:send25838(bbs_id)
    local protocal = {}
    protocal.bbs_id = bbs_id
    self:SendProtocal(25838, protocal)
end

function RoleController:handle25838(data)
    self.model:deleteMessageBoardDataByBbsid(data.bbs_id)
    GlobalEvent:getInstance():Fire(RoleEvent.ROLE_MESSAGE_BOARD_DELETE_INFO_EVENT, data)
end

--设置留言板回复权限
function RoleController:send25839(type)
    local protocal = {}
    protocal.type = type
    self:SendProtocal(25839, protocal)
end

function RoleController:handle25839(data)
    message(data.msg)
    self.model:setRoleAttribute("room_bbs_set", data.type)
    GlobalEvent:getInstance():Fire(RoleEvent.ROLE_MESSAGE_BOARD_LIMMIT_EVENT, data)
end

--点击自身留言板灯泡或主动打开空间留言板后请求(用于后端计算灯泡提示)"
function RoleController:send25840(rid, srv_id, bbs_id)
    local protocal = {}
    protocal.rid = rid
    protocal.srv_id = srv_id
    protocal.bbs_id = bbs_id
    self:SendProtocal(25840, protocal)
end

function RoleController:handle25840(data)
    message(data.msg)
end


-----------------------------------------------个人空间功能协议结束-------------------------

--[[ 修改个人签名 ]]
function RoleController:changeSignature(signature)
    local protocal = {}
    protocal.signature = signature
    self:SendProtocal(10309, protocal)
end
function RoleController:rgp_hander10309(data)
    message(data.msg)
    if data.code == TRUE then
        self.model:setRoleAttribute("signature", data.signature)
    end
end

--[[ 请求头像列表 ]]
function RoleController:requestRoleHeadList()
    local protocal = {}
    self:SendProtocal(10325, protocal)
end
function RoleController:rgp_hander10325(data)
    if self.model ~= nil then
        self.model:updateRoleHeadList(data)
    end
end

--[[ 设置头像 ]]
function RoleController:changeRoleHead(face_id)
    local protocal = {}
    protocal.face_id = face_id
    self:SendProtocal(10327, protocal)
end
function RoleController:rgp_hander10327(data)
    message(data.msg)
    if data.code == TRUE then
        message(TI18N("设置头像成功"))
        -- 同时清掉自定义头像
        self.model:setRoleAttribute("face_update_time", 0)

        self.model:setRoleAttribute("face_id", data.face_id)
    end
end

-- 强制改名
function RoleController:rgp_hander10342()
    local playVideo = MainSceneController:getInstance():getPlayVideoStatus()
    if playVideo == true then       -- 如果是播放录像的时候延迟显示
        self.need_play_rename = true
    else
        self:openRoleSetNameView(true)
    end
end

-- 视频录像播放完全之后,开始播放创建
function RoleController:restartPlayRename()
    if self.need_play_rename == true then
        self:openRoleSetNameView(true)
        self.need_play_rename = false
    end
end

--[[ 改名字 ]]
function RoleController:changeRoleName(name,sex)
    local protocal = {}
    protocal.name = name
    protocal.sex = sex
    self:SendProtocal(10343, protocal)
    --print("send---10343-----",name,sex)
end
function RoleController:rgp_hander10343(data)
    --Debug.info(data)
    message(data.msg)
    if data.code == TRUE then
        self.model:setRoleAttribute("name", data.name)
        self.model:setRoleAttribute("sex",data.sex)
        
        self.model:setRoleAttribute("is_first_rename", data.is_first_rename)
        self:openRoleChangeNameView(false)
        self:openRoleSetNameView(false)
        if self.role_personal_space_panel then
            self.role_personal_space_panel:closeSetNameAlert()
        end
    end
end

--形象信息
function RoleController:requestRoleModelInfo(  )
    self:SendProtocal(10345, {})
end
function RoleController:rgp_hander10345( data )
    -- Debug.info(data)
    GlobalEvent:getInstance():Fire(RoleEvent.GetModelList,data)
end

--使用形象
function RoleController:changeRoleModel( id )
    local protocal = {}
    protocal.id = id
    self:SendProtocal(10346, protocal)
end
function RoleController:rgp_hander10346( data )
    --Debug.info(data)
    message(data.msg)
    if data.code == 1 then
        GlobalEvent:getInstance():Fire(RoleEvent.UpdateModel,data.id)
    end
end
--激活形象
function RoleController:activeRoleModel( id )
    local protocal = {}
    protocal.id = id
    self:SendProtocal(10347, protocal)
end
function RoleController:rgp_hander10347( data )
    -- Debug.info(data)
    message(data.msg)
    if data.code == 1 then
        GlobalEvent:getInstance():Fire(RoleEvent.ActiveModel,data.id)
    end
end

--==============================--
--desc:通用资产不足的提示
--time:2017-08-14 03:13:58
--@data:
--@return 
--==============================--
function RoleController:rgp_hander12745(data)
    local item_config = Config.ItemData.data_get_data(data.bid)
    if item_config then
        local function cancelfunc()

        end
        if data.bid == Config.ItemData.data_assets_label2id.gold or data.bid == Config.ItemData.data_assets_label2id.gold  then --钻石
            if FILTER_CHARGE then
                message(TI18N("钻石不足"))
            else
                local function fun()
                    --MallController:getInstance():openChargeShopWindow(true, MallConst.Charge_Shop_Type.Diamond)
                    VipController:getInstance():openVipMainWindow(true, VIPTABCONST.CHARGE)
                end
                local str = string.format(TI18N('%s不足，是否前往充值'), pay_config.name)
                CommonAlert.show(str, TI18N('确定'), fun, TI18N('取消'), nil, CommonAlert.type.rich, nil, nil, nil, true)
            end
        --     local function fun()
        --         ExchangeController:getInstance():openMainView(true,EXCHANGE_TAB.coin)
        --         cancelfunc()
        --     end
        --         local str = string.format(TI18N("%s不足，是否前往兑换"), item_config.name)
        --         CommonAlert.show(str, TI18N("确定"), fun, TI18N("取消"), cancelfunc, CommonAlert.type.rich, cancelfunc, nil, nil, true)
        -- elseif data.bid == Config.ItemData.data_assets_label2id.silver_coin then -- 银币
        --     local function fun()
        --         ExchangeController:getInstance():openMainView(true,EXCHANGE_TAB.sliver_coin)
        --         cancelfunc()
        --     end

        --         local str = string.format(TI18N("%s不足，是否前往兑换"), item_config.name)
        --         CommonAlert.show(str, TI18N("确定"), fun, TI18N("取消"), cancelfunc, CommonAlert.type.rich, cancelfunc, nil, nil, true)

        -- elseif data.bid == Config.ItemData.data_assets_label2id.partner_exp_all then -- 宝可梦池
            
        elseif data.bid == Config.ItemData.data_assets_label2id.energy then   -- 体力
            message(TI18N("情报不足"))
            --[[if MainuiController:getInstance():checkIsInSkySceneUIFight() then
                self.room_base_data = AdventureController:getInstance():getUiModel():getAdventureBaseData()
                if self.room_base_data then
                    local num, cost_num = AdventureController:getInstance():getUiModel():getCurIndex(self.room_base_data.energy_num, Config.AdventureData.data_energy_num)
                    if cost_num == 0 then
                        if self.room_base_data.energy_num == tableLen(Config.AdventureData.data_energy_num) then
                            message(TI18N("今日已无兑换次数"))
                            return
                        end
                        local min_index = math.min(self.room_base_data.energy_num + 1, tableLen(Config.AdventureData.data_energy_num))
                        local vip = Config.AdventureData.data_energy_num[min_index].vip
                        local str = string.format("提升至VIP<div fontColor=#249003 fontsize=26>%s</div>可增加<div fontColor=#249003 fontsize=26>1</div>次购买次数,是否前往购买?", vip)
                        local call_back = function()
                            VipController:getInstance():openVipMainWindow(true)
                        end
                        CommonAlert.show(str, TI18N("确定"), call_back, TI18N("取消"), nil, CommonAlert.type.rich)
                    else
                        local min_index = math.min(self.room_base_data.energy_num + 1, tableLen(Config.AdventureData.data_energy_num))
                        local config = Config.AdventureData.data_energy_num[min_index]

                        if config then
                            local str = string.format("消耗<img src=%s visible=true scale=0.35 /><div><div fontColor=#249003 fontsize=26>%s</div>可兑换<img src=%s visible=true scale=0.35 /><div fontColor=#249003 fontsize=26>%s</div>,是否兑换?",PathTool.getItemRes(Config.ItemData.data_assets_label2id.gold),config.cost,PathTool.getItemRes(Config.ItemData.data_assets_label2id.energy),config.energy)
                            local call_back = function()
                            end
                            CommonAlert.show(str, TI18N("确定"), call_back, TI18N("取消"), nil, CommonAlert.type.rich)
                        end
                    end
                    cancelfunc()
                end
            end--]]
        else
            local config = Config.ItemData.data_get_data(data.bid)
            if config then
                BackpackController:getInstance():openTipsSource(true,config )
            end
        end
    end
end

--==============================--
--desc:物品不足弹来源途径
--time:2018-07-19 03:30:13
--@data:
--@return 
--==============================--
function RoleController:rgp_hander12746(data)
    local item_config = Config.ItemData.data_get_data(data.item_id)
    if item_config then
        if CommonGoodsType.isAsset(data.item_id) == false then 
            BackpackController:getInstance():openTipsSource( true,item_config )
        end
    end
end
--查看角色信息
--@setting 有值表示有其他跳转要求
function RoleController:requestRoleInfo(rid, srv_id, setting)
    if rid == 0 or not srv_id then return end
    self.setting_10315 = setting
    local protocal = {}
    protocal.rid = rid
    protocal.srv_id = srv_id
    self:SendProtocal(10315, protocal)
end

function RoleController:rgp_hander10315( data )
    if self.setting_10315 then 
        local form_type = self.setting_10315.form_type
        if not form_type then return end
        local setting = {}
        setting.role_type = RoleConst.role_type.eOther
        setting.other_data = data

        if form_type == RoleConst.Other_Form_Type.eHonorLevelTips then
            setting.index = RoleConst.Tab_type.eHonorWall
        elseif form_type == RoleConst.Other_Form_Type.eGrowthWayShare then
            local share_id = self.setting_10315.share_id or 0
            setting.index = RoleConst.Tab_type.eGrowthWay
            setting.growth_way_share_id = share_id
        elseif form_type == RoleConst.Other_Form_Type.eMessageBoardInfo then
            setting.index = RoleConst.Tab_type.eMessageBoard
            setting.bbs_id = self.setting_10315.bbs_id
        end
        self:openRolePersonalSpacePanel(true, setting)
    else
        GlobalEvent:getInstance():Fire(RoleEvent.DISPATCH_PLAYER_VO_EVENT,data)
    end
end

function RoleController:__delete()
    if self.battle_exit_event ~= nil then
        GlobalEvent:getInstance():UnBind(self.battle_exit_event)
        self.battle_exit_event = nil
    end
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end

--[[
    @desc:请求膜拜角色
    author:{author}
    time:2018-05-15 17:35:40
    --@rid:
	--@srv_id: 
    return
]]
function RoleController:requestWorshipRole(rid, srv_id, index, type)
    if rid == nil or srv_id == nil then return end
    index = index or 0
    local protocal = {}
    protocal.type = type or 0
    protocal.rid = rid
    protocal.srv_id = srv_id
    protocal.idx = index
    self:SendProtocal(10316, protocal)
end

function RoleController:rgp_hander10316(data)
    message(data.msg)
    if data.code == TRUE then
        GlobalEvent:getInstance():Fire(RoleEvent.WorshipOtherRole, data.rid, data.srv_id, data.idx, data.type)
    end
end

--pk验证设置
function RoleController:sender10318( auto_pk )
    local protocal = {auto_pk = auto_pk or 0}
    self:SendProtocal(10318, protocal)   
end

function RoleController:rgp_hander10318(data)
    message(data.msg)
    if data.code == TRUE then
        self.model:setRoleAttribute("auto_pk",data.auto_pk)
    end
end

--称号列表
function RoleController:sender23300(  )
    local protocal = {}
    self:SendProtocal(23300, protocal)   
end

function RoleController:hander23300( data )
    self.use_title_id = data.base_id
    GlobalEvent:getInstance():Fire(RoleEvent.GetTitleList,data)
end

--使用称号
function RoleController:sender23301( base_id )
    local protocal = {}
    protocal.base_id = base_id
    self:SendProtocal(23301, protocal)  
end

function RoleController:hander23301( data )
    self.use_title_id = data.base_id
    GlobalEvent:getInstance():Fire(RoleEvent.UseTitle,data.base_id)
end

--更新称号列表
function RoleController:sender23302(  )
    local protocal = {}
    self:SendProtocal(23302, protocal)  
end

function RoleController:hander23302( data )
    --self.use_title_id = data.base_id
    GlobalEvent:getInstance():Fire(RoleEvent.UpdataTitleList,data)
end

--激活称号
function RoleController:sender23303( base_id )
    local protocal = {}
    protocal.base_id = base_id
    self:SendProtocal(23303, protocal)  
end

function RoleController:hander23303( data )
    --self.use_title_id = data.base_id
    GlobalEvent:getInstance():Fire(RoleEvent.UpdataTitleList,data)
end

function RoleController:getUseTitleId(  )
    return self.use_title_id or 0
end

--礼包兑换
function RoleController:sender10945(card_id)
    local protocal ={}
    protocal.card_id = card_id
    self:SendProtocal(10945,protocal)
end

function RoleController:handle10945( data )
    message(data.msg)   
end

function RoleController:requestWorshipNum()
    self:SendProtocal(10317, {})
end

function RoleController:rgp_hander10317(data)
    local role_vo = self.model:getRoleVo()
    if role_vo ~= nil then
        role_vo.worship = data.worship
        GlobalEvent:getInstance():Fire(RoleEvent.UpdateWorshipEvent,data.worship)
    end
end

function RoleController:requestCrossChamWorshipNum()
    self:SendProtocal(10319, {})
end

function RoleController:rgp_hander10319( data )
    local role_vo = self.model:getRoleVo()
    if role_vo ~= nil then
        role_vo.cross_cham_worship = data.worship
        GlobalEvent:getInstance():Fire(RoleEvent.UpdateCrossChamWorshipEvent,data.worship)
    end
end

function RoleController:handle10994(data)
    if data.type == 0 then
        self:requestOpenSrvDay()
        TaskController:getInstance():requestActivityInfo()      -- 活跃度需要重新请求一次
        BattleDramaController:getInstance():send13006()  -- 请求快速作战相关数据
        GuildController:getInstance():requestGuildDonateProtocal()      -- 联盟捐献
        VoyageController:getInstance():requestActivityStatus()  -- 请求远航活动状态
        PrimusController:getInstance():sender20706() --星河神殿请求红点
        ActionController:getInstance():requestActionRedStatus() --部分活动请求红点
        StartowerController:getInstance():sender11320()
        OrderActionController:getInstance():openOrderActionMainView(false)
        HeroController:getInstance():zeroUpdata() -- 0点更新
        -- GuildsecretareaController:getInstance():request26800() --公会秘境boss0点更新
        SysEnv:getInstance():set(SysEnv.keys.holy_plan_wear_tip, false, false) --0点刷新神装穿戴今日不再提示状态
        SysEnv:getInstance():set(SysEnv.keys.holy_plan_save_tip, false, false) --0点刷新神装保存今日不再提示状态
        SysEnv:getInstance():set(SysEnv.keys.elfin_plan_save_tip, false, false) --0点刷新精灵保存今日不再提示状态
        SysEnv:getInstance():set(SysEnv.keys.video_first_open, true, false) --0点刷新今日是否为首次录像馆
        SysEnv:getInstance():set(SysEnv.keys.guild_first_open, true, false) --0点刷新今日是否为首次公会
            
        BackpackController:getInstance():getModel():checkArtifactCount(true)
        SysEnv:getInstance():save()
    elseif data.type == 5 then
        GuildbossController:getInstance():requestInitProtocal(true)
        ArenaController:getInstance():requestInitProtocal()
    elseif data.type == 6 or data.type == 18 then   -- 这个时候需要切换一下主城资源了
        MainSceneController:getInstance():changeMainCityTimeType(data.type)
        HomeworldController:getInstance():changeHomeTimeType(data.type)
    end
end

function RoleController:getApkData()
    if self.apk_data then
        return  self.apk_data
    end
end

-- 获取一个随机名称
function RoleController:getRandomName( sex )
    sex = sex or 1
    local randomName = ""

    for i=1, Config.RandomNameData.data_list_length do
        local config = Config.RandomNameData.data_list[i] or {}
        -- 取出所有符合性别要求的名称
        local temp_data = {}
        for k,v in pairs(config) do
            if v.sex and (v.sex == sex or v.sex == 0) then
                table.insert(temp_data, v)
            end
        end
        local random_data = temp_data[math.random(1, tableLen(temp_data))] or {}            
        randomName = randomName .. (random_data.name or "")
    end

    return randomName
end

function RoleController:requestWorldLev()
    self:SendProtocal(10905, {})
end

function RoleController:handle10905(data)
    self.model:setWorldLev(data.world_lev)
    GlobalEvent:getInstance():Fire(RoleEvent.WORLD_LEV, data.world_lev)
end

function RoleController:requestOpenSrvDay(  )
    self:SendProtocal(10906, {})
end

function RoleController:handle10906( data )
    self.model:setOpenSrvDay(data.open_day)
    GlobalEvent:getInstance():Fire(RoleEvent.OPEN_SRV_DAY, data.open_day)

    -- 把开服天数写到角色信息里面去,这样判断只要处理角色变化事件就好了
    local role_vo = self:getRoleVo()
    if role_vo then
        role_vo:setRoleAttribute("open_day", data.open_day)
    end
end
function RoleController:sender10907(  )
    self:SendProtocal(10907, {})
end

function RoleController:handle10907( data )
    if setQingmingShield then
        if data.sys_ban == 1 then
            setQingmingShield(true)
        else
            setQingmingShield(false)
        end
    end
end

function RoleController:openRoleUpgradeMainWindow(status, data)
    if not status then
        if self.role_upgrade_window then
            self.role_upgrade_window:close()
            self.role_upgrade_window  = nil
        end
    else
        -- 这里需要判断一下,当前是否有可以提升的
        if data == nil then return end
        
        if self.role_upgrade_window == nil then
            self.role_upgrade_window = RoleUpgradeMainWindow.New()
        end
        self.role_upgrade_window:open(data)
    end
end

-- 请求实名认证
function RoleController:sender10395( age )
    local protocal ={}
    protocal.age = age
    self:SendProtocal(10395, protocal)
end

--- 防沉迷系统
function RoleController:handle10395(data)
    local role_vo = self:getRoleVo()
    if  role_vo then
        role_vo.pass_certify = data.status
        if data.status == 0 then
            MainuiController:getInstance():addFunctionIconById(MainuiConst.icon.certify)
        else
            MainuiController:getInstance():removeFunctionIconById(MainuiConst.icon.certify)
        end
    end
end

--- 通用弹窗
function RoleController:handle12744(data)
    if not IS_NEED_REAL_NAME then return end
    if data.type == 3 then
        CommonAlert.closeAllWin() --防止多个的时候过来导致重叠
        CommonAlert.show(data.msg, TI18N("确定"), function() 
            -- self:openRoleAttestationWindow(true)
        end, TI18N("取消"))
    end
end

-- 请求隐藏聊天vip标识
function RoleController:sender10348( is_show_vip )
    local protocal ={}
    protocal.is_show_vip = is_show_vip
    self:SendProtocal(10348, protocal)
end

function RoleController:handle10348( data )
    message(data.msg)
end

-- 特权激活情况
function RoleController:handle24500( data )
    if data and data.list then
        self.model:setPrivilegeData(data.list)
    end
end

--实名认证
function RoleController:sender10960()
    self:SendProtocal(10960, {})
end
function RoleController:handle10960(data)
    GlobalEvent:getInstance():Fire(RoleEvent.ROLE_NAME_AUTHENTIC, data)
end
function RoleController:sender10961()
    self:SendProtocal(10961, {})
end
function RoleController:handle10961(data)
    message(data.msg)
end

-- 请求自定义头像相关信息
function RoleController:requestCustomHeadInfo()
    self:SendProtocal(10330, {})
end

-- 自定义头像,这边只请求一次了
function RoleController:handle10330(data)
    if data then
        -- 初始化cos
        TencentCos:getInstance():initCos(data.secret_id, data.secret_key)
        -- 更新角色信息
        self.model:setRoleAttribute("custom_face_file", data.face_file)
    end
end

-- 通知服务端自定义头像成功路了
function RoleController:tellServerCustomSuccess()
    self:SendProtocal(10332, {})
end

-- 重新设置之前的自定义头像
function RoleController:resetCustomHeadImage()
    self:SendProtocal(10333, {})
end

-- 重新设置自定义头像返回
function RoleController:handle10333(data)
    if data.code == 1 then
        if self.model then
            self.model:updateCustomFace(data.face_file, data.face_update_time)
        end
    else
        message(data.msg)
    end
end

-- 通知上传头像成功返回
function RoleController:handle10332(data)
    if data.code == 1 then
        if self.model then
            self.model:updateCustomFace(data.face_file, data.face_update_time)
        end
    else
        message(data.msg)
    end
end

--自定义头像选择相机还是拍照界面
function RoleController:openRolePhotoChooseWindow(status)
    if not status then
        if self.photo_choose_view then
            self.photo_choose_view:close()
            self.photo_choose_view  = nil
        end
    else
        if self.photo_choose_view == nil then
            self.photo_choose_view = RolePhotoChooseWindow.New()
        end
        self.photo_choose_view:open()
    end
end

-- 活动登录推送
function RoleController:handle10360(data)
    if GuideController:getInstance():isInGuide() then return end        -- 在剧情或者在引导中不处理
    if StoryController:getInstance():getModel():isStoryState() then return end
    RenderMgr:getInstance():doNextFrame(function() 
        self:openActivePushWindow(true, data)
    end)
end

-- 活动登录推送窗口
function RoleController:openActivePushWindow(status, data)
    if not status then
        if self.active_push then
            self.active_push:close()
            self.active_push  = nil
        end
    elseif data ~= nil and data.ids ~= nil and next(data.ids) ~= nil then
        if self.active_push == nil then
            self.active_push = ActivePushWindow.New()
        end
        self.active_push:open(data.ids)
    end
end

-- 第三方充值
function RoleController:requestThirdCharge(charge_bid, host, info)
    self.charge_info = info
    local notify_url = string.format("http://%s/api.php/pf/sszg/dan/", host)
    local protocal = {}
    protocal.charge_id = tonumber(charge_bid)
    protocal.notify_url = notify_url
    self:SendProtocal(10947, protocal)
end

function RoleController:handle10947(data)
    if data and data.code == TRUE then
        sdkCallFunc("openSyW", data.url)
    else
        if self.charge_info and self.charge_info ~= "" then
            sdkCallFunc("dan", self.charge_info)
        end
    end
    self.charge_info = ""
end

--红点系列已点过的红点
function RoleController:sender10985()
    self:SendProtocal(10985, {})
end

function RoleController:handle10985(data)
    self.model:setRedPointData(data)
    GlobalEvent:getInstance():Fire(RoleEvent.UPDATE_RED_POINT)
    --dump(data,"xhj---------------handle10985--------------------")
end

--消除红点
function RoleController:sender10986(id)
    local protocal = {}
    protocal.id = id
    self:SendProtocal(10986, protocal)
end

function RoleController:handle10986(data)
    
end
