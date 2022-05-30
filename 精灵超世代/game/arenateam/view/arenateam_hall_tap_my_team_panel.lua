-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      组队
-- <br/> 2019年10月11日
-- --------------------------------------------------------------------
ArenateamHallTapMyTeamPanel = class("ArenateamHallTapMyTeamPanel", function()
    return ccui.Widget:create()
end)

local controller = ArenateamController:getInstance()
local model = controller:getModel()
local table_insert = table.insert
local table_sort = table.sort
local string_format = string.format
local math_floor = math.floor

local role_vo = RoleController:getInstance():getRoleVo()

function ArenateamHallTapMyTeamPanel:ctor(parent)
    self.parent = parent
    self:config()
    self:layoutUI()
    self:registerEvents()
end

function ArenateamHallTapMyTeamPanel:setVisibleStatus(bool)
    if not self.parent then return end
    self.visible_status = bool or false 
    self:setVisible(bool)
    if bool then
        --因为队伍信息有可能变化了
        controller:sender27221()
    end
end

function ArenateamHallTapMyTeamPanel:config()


    self.default_msg = TI18N("请输入需要搜索的队伍名字")
end

function ArenateamHallTapMyTeamPanel:layoutUI()
    local csbPath = PathTool.getTargetCSB("arenateam/arenateam_hall_tap_my_team_panel")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)
    --读取文件的大小
    self.size = self.root_wnd:getContentSize()
    self:setContentSize(self.size)

    self.container = self.root_wnd:getChildByName("container")

    self.team_name = self.container:getChildByName("team_name")
    self.team_name:setString("")
    self.level_value = self.container:getChildByName("level_value")
    self.level_value:setString(TI18N("不限"))
    self.power_value = self.container:getChildByName("power_value")
    self.power_value:setString(TI18N("不限"))
    self.power = self.container:getChildByName("power")
    self.power:setString(0)

    self.container:getChildByName("level_key"):setString(TI18N("申请条件:"))

    --改名
    self.chang_btn = self.container:getChildByName("chang_btn")
    --设置
    self.set_btn = self.container:getChildByName("set_btn")
    self.set_btn:getChildByName("label"):setString(TI18N("调整"))
    self.exit_btn = self.container:getChildByName("exit_btn")
    self.exit_btn:getChildByName("label"):setString(TI18N("退出队伍"))
    self.join_btn = self.container:getChildByName("join_btn")
    self.join_btn_lable = self.join_btn:getChildByName("label")
    self.join_btn_lable:setString(TI18N("报名参赛"))

    self.chang_btn:setVisible(false)
    self.set_btn:setVisible(false)
    self.exit_btn:setVisible(false)
    self.join_btn:setVisible(false)
    --队伍信息
    self.team_item_list = {}
    for i=1,3 do
        local team_item = self.container:getChildByName("team_item_"..i)
        if team_item then
            local size = team_item:getContentSize()
            self.team_item_list[i] = {}
            local team_info = team_item:getChildByName("team_info")
            local team_add = team_item:getChildByName("team_add")
            self.team_item_list[i].team_item = team_item
            self.team_item_list[i].team_info = team_info
            self.team_item_list[i].team_add = team_add

            self.team_item_list[i].player_name = createRichLabel(22, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0, 0.5), cc.p(132,177),nil,nil,800)
            team_info:addChild(self.team_item_list[i].player_name)
            self.team_item_list[i].power =  team_info:getChildByName("power")
            self.team_item_list[i].power:setString(0)
            --头像
            self.team_item_list[i].head = PlayerHead.new(PlayerHead.type.circle)
            self.team_item_list[i].head:setHeadLayerScale(0.8)
            self.team_item_list[i].head:setPosition(56 , 160)
            self.team_item_list[i].head:setLev(0)
            team_info:addChild(self.team_item_list[i].head)
            self.team_item_list[i].head:addCallBack(function() self:onClickHead(i) end )

            --宝可梦
            self.team_item_list[i].hero_item_list = {}
            local item_width = HeroExhibitionItem.Width * 0.8 + 10
            local x = size.width * 0.5 -item_width * 5 * 0.5 + item_width * 0.5
            local y = 58
            for j=1,5 do
                self.team_item_list[i].hero_item_list[j] = HeroExhibitionItem.new(0.8, true)
                self.team_item_list[i].hero_item_list[j]:setSwallowTouches(false)
                self.team_item_list[i].hero_item_list[j]:setPosition(x + (j - 1) * item_width, y)
                self.team_item_list[i].hero_item_list[j]:addCallBack(function() self:onClickHeroItemByIndex(i, j) end)
                -- self.hero_item_list[i]:setBgOpacity(128)
                team_info:addChild(self.team_item_list[i].hero_item_list[j])
            end
            self.team_item_list[i].del_btn = team_info:getChildByName("del_btn")
            self.team_item_list[i].del_btn:getChildByName("label"):setString(TI18N("踢出队伍"))
            self.team_item_list[i].team_btn = team_info:getChildByName("team_btn")
            self.team_item_list[i].team_btn:getChildByName("label"):setString(TI18N("移交队长"))

            self.team_item_list[i].add_btn = team_add:getChildByName("add_btn")
            self.team_item_list[i].add_btn:setPositionY(118)
            team_add:getChildByName("tips"):setString(TI18N("点击可查看申请列表或邀请玩家加入队伍"))
            

            team_item:setVisible(false)
        end
    end
end

--事件
function ArenateamHallTapMyTeamPanel:registerEvents()
    registerButtonEventListener(self.chang_btn, function() self:onChangBtn()  end ,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.set_btn, function() self:onSetBtn()  end ,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.exit_btn, function() self:onExitBtn()  end ,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.join_btn, function() self:onJoinBtn()  end ,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    if self.team_item_list then
        for i,item in ipairs(self.team_item_list) do
            registerButtonEventListener(item.del_btn, function() self:onDelBtnByIndex(i)  end ,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
            registerButtonEventListener(item.team_btn, function() self:onTeamBtnByIndex(i)  end ,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
            registerButtonEventListener(item.add_btn, function() self:onAddBtnByIndex(i)  end ,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
        end
    end


    if self.arenateam_my_team_info_event == nil then
        self.arenateam_my_team_info_event = GlobalEvent:getInstance():Bind(ArenateamEvent.ARENATEAM_MY_TEAM_INFO_EVENT,function (data)
            if not data then return end
            self:setData(data)
        end)
    end
    --报名参赛
    if self.arenateam_join_name_event == nil then
        self.arenateam_join_name_event = GlobalEvent:getInstance():Bind(ArenateamEvent.ARENATEAM_JOIN_GAME_EVENT,function ()
            --状态改变
            if self.scdata then 
                self.scdata.is_sign = 1
                self:updateJoinInfo()
            end
        end)
    end
    --报名参赛
    if self.arenateam_leave_name_event == nil then
        self.arenateam_leave_name_event = GlobalEvent:getInstance():Bind(ArenateamEvent.ARENATEAM_LEAVE_GAME_EVENT,function ()
            --状态改变
             if self.scdata then 
                self.scdata.is_sign = 0
                self:updateJoinInfo()
            end
        end)
    end

    if self.arenateam_change_name_callback == nil then
        self.arenateam_change_name_callback = GlobalEvent:getInstance():Bind(ArenateamEvent.ARENATEAM_CHANGE_NAME_CALLBACK,function (name)
            self.record_name = name
        end)
    end
    if self.arenateam_team_set_callback == nil then
        self.arenateam_team_set_callback = GlobalEvent:getInstance():Bind(ArenateamEvent.ARENATEAM_TEAM_SET_CALLBACK,function (limit_lev, limit_power)
            self.record_limit_lev = limit_lev or 0
            self.record_limit_power = limit_power or 0
        end)
    end
    --改名
    if self.arenateam_change_name_event == nil then
        self.arenateam_change_name_event = GlobalEvent:getInstance():Bind(ArenateamEvent.ARENATEAM_CHANGE_NAME_EVENT,function ()
            if self.record_name and self.scdata then
                self.scdata.team_name = self.record_name
                self.team_name:setString(self.scdata.team_name)
                self.record_name = nil
            end
        end)
    end

    --队伍设置
    if self.arenateam_team_set_event == nil then
        self.arenateam_team_set_event = GlobalEvent:getInstance():Bind(ArenateamEvent.ARENATEAM_TEAM_SET_EVENT,function ()
            if self.scdata then
                if self.record_limit_lev then
                   self.scdata.team_limit_lev = self.record_limit_lev
                   self.record_limit_lev = nil
                end

                if self.record_limit_power then
                    self.scdata.team_limit_power = self.record_limit_power
                    self.record_limit_power = nil
                end
                self:updateSetInfo()
            end
        end)
    end

    --有红点
    if self.arenateam_apply_redpoint_event == nil then
        self.arenateam_apply_redpoint_event = GlobalEvent:getInstance():Bind(ArenateamEvent.ARENATEAM_APPLY_RED_POINT_EVENT,function ()
            if self.scdata then
                self:updateRedPoint()   
            end
        end)
    end
    --红点发生变化
    if self.arenateam_all_redpoint_event == nil then
        self.arenateam_all_redpoint_event = GlobalEvent:getInstance():Bind(ArenateamEvent.ARENATEAM_ALL_RED_POINT_EVENT,function ()
            if self.scdata then
                self:updateRedPoint()   
            end
        end)
    end
end

function ArenateamHallTapMyTeamPanel:updateRedPoint()
    if self.scdata.tid ~= 0 and self.team_member then

        for i,team_item in ipairs(self.team_item_list) do
            if self.team_member[i] == nil then
                if model.is_apply_red then
                     addRedPointToNodeByStatus(team_item.add_btn, true, -20, -20)
                else
                     addRedPointToNodeByStatus(team_item.add_btn, false, 5, 5)
                end
            end
        end
    end
end

function ArenateamHallTapMyTeamPanel:onClickHead(i)
    if self.team_member and self.team_member[i] then
         local data = self.team_member[i]
        if role_vo and data.rid == role_vo.rid and data.sid == role_vo.srv_id then 
            message(TI18N("这是你自己~"))
            return
        end
        FriendController:getInstance():openFriendCheckPanel(true, {srv_id = data.sid, rid = data.rid})
    end
end

--改队伍名字
function ArenateamHallTapMyTeamPanel:onChangBtn()
    if not self.scdata then return end
    if role_vo and role_vo.rid == self.scdata.rid and role_vo.srv_id == self.scdata.sid then
        --角色是队长
        controller:openArenateamChangTeamNamePanel(true)
    else
        --角色是队员
        message(TI18N("只有队长可进行该操作"))
    end
    
end

-- 设置
function ArenateamHallTapMyTeamPanel:onSetBtn()
    if not self.scdata then return end
    if role_vo and role_vo.rid == self.scdata.rid and role_vo.srv_id == self.scdata.sid then
        --角色是队长
        if not self.scdata then return end
        local setting = {}
        setting.team_limit_power = self.scdata.team_limit_power
        setting.team_limit_lev = self.scdata.team_limit_lev
        setting.team_is_check = self.scdata.team_is_check
        controller:openArenateamTeamSetPanel(true, setting)
    else
        --角色是队员
        message(TI18N("只有队长可进行该操作"))
    end
    
end

--退出队伍
function ArenateamHallTapMyTeamPanel:onExitBtn()
    local msg = TI18N("请确认是否退出队伍，队长退队会将队长职位移交给队内战力最高的玩家")
    CommonAlert.show(msg, TI18N("确定"), function()
       controller:sender27211()
    end, TI18N("取消"), nil, CommonAlert.type.rich, nil,other_args)
end
--报名参赛
function ArenateamHallTapMyTeamPanel:onJoinBtn()
    if not self.scdata then return end
    
    if role_vo and role_vo.rid == self.scdata.rid and role_vo.srv_id == self.scdata.sid then
        --角色是队长
        if not self.team_member then return end
        if #self.team_member < 3  then
            message(TI18N("队伍人数不足"))
            return
        end
        if self.scdata.is_sign == 1 then
            controller:sender27241()
        else
            controller:sender27240()
        end
    else
        --角色是队员
        message(TI18N("只有队长可进行该操作"))
    end
end

--删除某个玩家
function ArenateamHallTapMyTeamPanel:onDelBtnByIndex(i)
    if not self.scdata then return end
    if self.team_member and self.team_member[i] then
        controller:openArenateamDeletePlayerPanel(true, {member_data = self.team_member[i]})
    end
end

--移交队长某个玩家
function ArenateamHallTapMyTeamPanel:onTeamBtnByIndex(i)
    if not self.team_member then return end
    if not self.team_member[i] then return end
    local member_data = self.team_member[i]
    
    local other_args = {}
    other_args.timer = 5
    other_args.timer_for = true
    -- other_args.off_y = 10
    other_args.title = TI18N("移交队长")

    local name = member_data.name
    local msg = string_format(TI18N("请确定将队长移交给玩家:<div fontcolor='#289b14'>%s</div>吗?"), name) 
    CommonAlert.show(msg, TI18N("确定"), function()
        controller:sender27213(member_data.rid, member_data.sid)
    end, TI18N("取消"), nil, CommonAlert.type.rich, nil,other_args)
end

--邀请
function ArenateamHallTapMyTeamPanel:onAddBtnByIndex(i)
    if not self.scdata then return end

    if self.scdata.tid  == 0 then
        message(TI18N("请先加入队伍"))
        return
    end
    local is_team_leader = false
    if role_vo and role_vo.rid == self.scdata.rid and role_vo.srv_id == self.scdata.sid then
        --角色是队长
        is_team_leader = true
    else
        --角色是队员
        is_team_leader = false
    end
    
    local index 
    --说明有申请人
    if model.is_apply_red then
        index = ArenateamConst.AddPlayerTabType.eApplyList
    else
        index = ArenateamConst.AddPlayerTabType.eInvitation
    end

    controller:openArenateamAddPlayerPanel(true, {is_team_leader = is_team_leader, index = index})
end

--点击某个宝可梦
function ArenateamHallTapMyTeamPanel:onClickHeroItemByIndex(i, j)
    
end

function ArenateamHallTapMyTeamPanel:setData(scdata)
    self.scdata = scdata
    if self.scdata.tid == 0 then
        --没有队伍
        self.chang_btn:setVisible(false)
        self.set_btn:setVisible(false)
        self.exit_btn:setVisible(false)
        self.join_btn:setVisible(false)

        self.team_name:setString(TI18N("未加入队伍"))
        self.level_value:setString(TI18N("不限"))
        self.power_value:setString(TI18N("不限"))
        self.power:setString(0)

        for pos, item in ipairs(self.team_item_list) do
            item.team_item:setVisible(false)
        end
        commonShowEmptyIcon(self.container, true, {text = TI18N("暂无队伍信息")})
        return
    else
        self.chang_btn:setVisible(true)
        self.set_btn:setVisible(true)
        self.exit_btn:setVisible(true)
        self.join_btn:setVisible(true)
        commonShowEmptyIcon(self.container, false)
    end
    self:updateJoinInfo()
 
    self.team_name:setString(self.scdata.team_name)
    self:updateSetInfo()
    
    self.power:setString(changeBtValueForPower(self.scdata.team_power))
    
    local arena_team_member = self.scdata.arena_team_member or {}
    local leader_data = nil
    local team_member = {}
    for i,v in ipairs(arena_team_member) do
        if v.rid == self.scdata.rid and v.sid == self.scdata.sid then
            leader_data = v
        else
            table_insert(team_member, v)
        end
    end
    table_sort(team_member, function(a, b) return a.pos < b.pos end)
    table_insert(team_member,1,leader_data)

    self.team_member = team_member
    for pos, item in ipairs(self.team_item_list) do
        local member_data = team_member[pos]
        item.team_item:setVisible(true)
        if member_data then
            item.team_info:setVisible(true)
            item.team_add:setVisible(false)
            self:updateTeamItem(item, member_data)
        else
            item.team_info:setVisible(false)
            item.team_add:setVisible(true)
        end
    end

    --红点
    self:updateRedPoint()
end

function ArenateamHallTapMyTeamPanel:updateJoinInfo()
    if not self.scdata then return end
    if self.scdata.is_sign == 1 then
        self.join_btn_lable:setString(TI18N("取消报名"))
    else
        self.join_btn_lable:setString(TI18N("报名参赛"))
    end
    
end

function ArenateamHallTapMyTeamPanel:updateSetInfo()
    if not self.scdata then return end
    if self.scdata.team_limit_lev == 0 then
        self.level_value:setString(TI18N("不限"))
    else
        self.level_value:setString(string_format(TI18N("等级: %s"), self.scdata.team_limit_lev))
    end
    if self.scdata.team_limit_power == 0 then
        self.power_value:setString(TI18N("不限"))
    else
        local power = math_floor(changeBtValueForPower(self.scdata.team_limit_power)/10000)
        self.power_value:setString(string_format(TI18N("战力: %sw"), power))
    end
end

function ArenateamHallTapMyTeamPanel:updateTeamItem(item, member_data)
    if not item then return end
    if not member_data then return end
    if not self.scdata then return end
    
    if self.scdata.rid == member_data.rid and self.scdata.sid == member_data.sid then
        item.player_name:setString(string_format(TI18N("<div fontcolor=#643223>%s</div><div fontcolor=#955322>(队长)</div>"), member_data.name))
        
        item.del_btn:setVisible(false)
        item.team_btn:setVisible(false)
    else
        item.player_name:setString(member_data.name)
        if role_vo and role_vo.rid == self.scdata.rid and role_vo.srv_id == self.scdata.sid then
            --角色是队长
            item.del_btn:setVisible(true)
            item.team_btn:setVisible(true)
        else
            item.del_btn:setVisible(false)
            item.team_btn:setVisible(false)    
        end
    end
    item.power:setString(changeBtValueForPower(member_data.power))
    --头像
    item.head:setHeadRes(member_data.face_id, false, LOADTEXT_TYPE, member_data.face_file, member_data.face_update_time)
    item.head:setLev(member_data.lev)
    local avatar_bid = member_data.avatar_bid 
    if item.record_res_bid == nil or item.record_res_bid ~= avatar_bid then
        item.record_res_bid = avatar_bid
        local vo = Config.AvatarData.data_avatar[avatar_bid]
        --背景框
        if vo then
            local res_id = vo.res_id or 1
            local res = PathTool.getTargetRes("headcircle", "txt_cn_headcircle_" .. res_id, false, false)
            item.head:showBg(res, nil, false, vo.offy)
        end
    end

    --宝可梦
    -- local dic_pos_parter = {}
    -- for i,v in ipairs(member_data.team_partner) do
    --     dic_pos_parter[v.pos]
    -- end
    table_sort(member_data.team_partner, function(a, b) return a.pos < b.pos end)
    for i,hero_item in ipairs(item.hero_item_list) do
        local hero_vo = member_data.team_partner[i]
        hero_item:setData(hero_vo)
    end
end

--移除
function ArenateamHallTapMyTeamPanel:DeleteMe()
    if self.arenateam_my_team_info_event then
        GlobalEvent:getInstance():UnBind(self.arenateam_my_team_info_event)
        self.arenateam_my_team_info_event = nil
    end
    if self.arenateam_join_name_event then
        GlobalEvent:getInstance():UnBind(self.arenateam_join_name_event)
        self.arenateam_join_name_event = nil
    end
    if self.arenateam_leave_name_event then
        GlobalEvent:getInstance():UnBind(self.arenateam_leave_name_event)
        self.arenateam_leave_name_event = nil
    end

    if self.arenateam_change_name_callback then
        GlobalEvent:getInstance():UnBind(self.arenateam_change_name_callback)
        self.arenateam_change_name_callback = nil
    end

    if self.arenateam_team_set_callback then
        GlobalEvent:getInstance():UnBind(self.arenateam_team_set_callback)
        self.arenateam_team_set_callback = nil
    end

    if self.arenateam_change_name_event then
        GlobalEvent:getInstance():UnBind(self.arenateam_change_name_event)
        self.arenateam_change_name_event = nil
    end

    if self.arenateam_team_set_event then
        GlobalEvent:getInstance():UnBind(self.arenateam_team_set_event)
        self.arenateam_team_set_event = nil
    end
    if self.arenateam_apply_redpoint_event then
        GlobalEvent:getInstance():UnBind(self.arenateam_apply_redpoint_event)
        self.arenateam_apply_redpoint_event = nil
    end
    if self.arenateam_all_redpoint_event then
        GlobalEvent:getInstance():UnBind(self.arenateam_all_redpoint_event)
        self.arenateam_all_redpoint_event = nil
    end

end
