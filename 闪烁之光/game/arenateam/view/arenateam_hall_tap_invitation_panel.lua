-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      组队要求
-- <br/> 2019年10月11日
-- --------------------------------------------------------------------
ArenateamHallTapInvitationPanel = class("ArenateamHallTapInvitationPanel", function()
    return ccui.Widget:create()
end)

local controller = ArenateamController:getInstance()
local model = controller:getModel()
local table_insert = table.insert
local table_sort = table.sort
local string_format = string.format
local math_floor = math.floor

function ArenateamHallTapInvitationPanel:ctor(parent)
    self.parent = parent
    self:config()
    self:layoutUI()
    self:registerEvents()
end

function ArenateamHallTapInvitationPanel:setVisibleStatus(bool)
    if not self.parent then return end
    self.visible_status = bool or false 
    self:setVisible(bool)

    if bool then
        controller:sender27206()
    end
    -- self:setData()
end

function ArenateamHallTapInvitationPanel:config()

end

function ArenateamHallTapInvitationPanel:layoutUI()
    local csbPath = PathTool.getTargetCSB("arenateam/arenateam_hall_tap_invitation_panel")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)
    --读取文件的大小
    self.size = self.root_wnd:getContentSize()
    self:setContentSize(self.size)

    self.container = self.root_wnd:getChildByName("container")

    self.key_btn = self.container:getChildByName("key_btn")
    self.key_btn:getChildByName("label"):setString(TI18N("一键清除"))

    --列表
    self.lay_srollview = self.container:getChildByName("lay_srollview")
end

--事件
function ArenateamHallTapInvitationPanel:registerEvents()
    registerButtonEventListener(self.key_btn, function() self:onKeyBtn()  end ,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY, nil, nil, 1)


    if self.arenateam_invitation_list_event == nil then
        self.arenateam_invitation_list_event = GlobalEvent:getInstance():Bind(ArenateamEvent.ARENATEAM_INVITATION_LIST_EVENT,function (data)
            if not data then return end
            self.is_init = true
            self:setData(data)
        end)
    end
    if self.arenateam_key_clear_event == nil then
        self.arenateam_key_clear_event = GlobalEvent:getInstance():Bind(ArenateamEvent.ARENATEAM_KEY_CLEAR_EVENT,function (data)
            self.show_list = {}
            self:updateTeamlist()
        end)
    end
end

--一键清除
function ArenateamHallTapInvitationPanel:onKeyBtn()
    controller:sender27208()
end


function ArenateamHallTapInvitationPanel:setData(scdata)
    if not scdata then return end
    self.scdata = scdata
    self.show_list = scdata.team_list
    table.sort(self.show_list, function(a, b) return a.team_power > b.team_power end)
    self:updateTeamlist()   
end

--列表
function ArenateamHallTapInvitationPanel:updateTeamlist()
    if not self.show_list then return end
    if self.scrollview_list == nil then
        local scrollview_size = self.lay_srollview:getContentSize()
        
        local setting = {
            start_x = 0,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = 0,                     -- 第一个单元的Y起点
            space_y = 0,                     -- y方向的间隔
            item_width = 600,                -- 单元的尺寸width
            item_height = 153,               -- 单元的尺寸height
            row = 1,                         -- 行数，作用于水平滚动类型
            col = 1,                         -- 列数，作用于垂直滚动类型
            delay = 1,                       -- 创建延迟时间
            once_num = 1,                    -- 每次创建的数量
        }
        self.scrollview_list = CommonScrollViewSingleLayout.new(self.lay_srollview, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scrollview_size, setting, cc.p(0, 0))

        self.scrollview_list:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.scrollview_list:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.scrollview_list:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    end

    self.scrollview_list:reloadData()

    if #self.show_list == 0 then
        commonShowEmptyIcon(self.lay_srollview, true, {text = TI18N("暂无邀请信息")})
    else
        commonShowEmptyIcon(self.lay_srollview, false)
    end
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function ArenateamHallTapInvitationPanel:createNewCell(width, height)
    local cell = ArenateamHallTapInvitationItem.new(width, height, self.parent)
    return cell
end

--获取数据数量
function ArenateamHallTapInvitationPanel:numberOfCells()
    if not self.show_list then return 0 end
    return #self.show_list
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function ArenateamHallTapInvitationPanel:updateCellByIndex(cell, index)
    cell.index = index
    local data = self.show_list[index]
    if not data then return end
    cell:setData(data)
end

--点击cell .需要在 createNewCell 设置点击事件
function ArenateamHallTapInvitationPanel:setCellTouched(cell)
    local index = cell.index
    local data = self.show_list[index]
    if not data then return end
end

--移除
function ArenateamHallTapInvitationPanel:DeleteMe()
    if self.arenateam_invitation_list_event then
        GlobalEvent:getInstance():UnBind(self.arenateam_invitation_list_event)
        self.arenateam_invitation_list_event = nil
    end
    if self.arenateam_key_clear_event then
        GlobalEvent:getInstance():UnBind(self.arenateam_key_clear_event)
        self.arenateam_key_clear_event = nil
    end

    if self.scrollview_list then
        self.scrollview_list:DeleteMe()
        self.scrollview_list = nil
    end
end


-- 子项arenateam_hall_tap_team_item
ArenateamHallTapInvitationItem = class("ArenateamHallTapInvitationItem", function()
    return ccui.Widget:create()
end)

function ArenateamHallTapInvitationItem:ctor(width, height, parent)
    self.parent = parent
    self:configUI(width, height)
    self:register_event()
end

function ArenateamHallTapInvitationItem:configUI(width, height)
    self.size = cc.size(width,height)
    self:setTouchEnabled(true)
    self:setContentSize(self.size)

    local csbPath = PathTool.getTargetCSB("arenateam/arenateam_hall_tap_invitation_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self.root_wnd:setAnchorPoint(cc.p(0.5, 0.5))
    self.root_wnd:setPosition(width * 0.5, height * 0.5)
    self:addChild(self.root_wnd)

    self.main_container = self.root_wnd:getChildByName("main_container")

    self.team_name = self.main_container:getChildByName("team_name")
    self.power = self.main_container:getChildByName("power")

    self.head_list = {}
    local x = 58
    for i=1,3 do
        self.head_list[i] = PlayerHead.new(PlayerHead.type.circle)
        self.head_list[i]:setHeadLayerScale(0.8)
        self.head_list[i]:setPosition(x + 95 * (i - 1) , 58)
        self.head_list[i]:setLev(99)
        self.main_container:addChild(self.head_list[i])
    end
    self.comfirm_btn = self.main_container:getChildByName("comfirm_btn")
    self.comfirm_label = self.comfirm_btn:getChildByName("label")
    self.comfirm_label:setString(TI18N("同 意"))
    self.cancel_btn = self.main_container:getChildByName("cancel_btn")
    self.cancel_btn_label = self.cancel_btn:getChildByName("label")
    self.cancel_btn_label:setString(TI18N("拒 绝"))
end

function ArenateamHallTapInvitationItem:register_event( )
    registerButtonEventListener(self.comfirm_btn, function() self:onArgeeBtn() end, true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.cancel_btn, function() self:onCancelBtn() end, true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    

    for i,head in ipairs(self.head_list) do
        head:addCallBack(function() self:onClickHead(i) end )
    end
end

function ArenateamHallTapInvitationItem:onClickHead(i)
    local team_members = self.data.team_members or {}
    local data = team_members[i]
    if not data then return end
    if self.head_list and self.head_list[i] then
        local roleVo = RoleController:getInstance():getRoleVo()
        if roleVo and data.rid == roleVo.rid and data.sid == roleVo.srv_id then 
            message(TI18N("这是你自己~"))
            return
        end
        FriendController:getInstance():openFriendCheckPanel(true, {srv_id = data.sid, rid = data.rid})
    end
end
--确定
function ArenateamHallTapInvitationItem:onArgeeBtn()
    if not self.data then return end
    controller:sender27207(self.data.tid, self.data.srv_id, 1)
end

--取消
function ArenateamHallTapInvitationItem:onCancelBtn()
    if not self.data then return end
    controller:sender27207(self.data.tid, self.data.srv_id, 0)
end


function ArenateamHallTapInvitationItem:setData(data)
    if not data then return end
    self.data = data
    self.team_name:setString(self.data.team_name)
    self.power:setString(self.data.team_power)

    local team_members = data.team_members or {}
    for i,member_data in ipairs(team_members) do
        member_data.is_leader = 0
        for i,v in ipairs(member_data.ext) do
            if v.extra_key == 1 then --是否队长
                if v.extra_val == 1 then
                    member_data.is_leader = 1 
                else
                    member_data.is_leader = - member_data.pos
                end
            end
        end
    end
    table_sort(team_members, function(a, b) return a.is_leader > b.is_leader end)

    for i,head in ipairs(self.head_list) do
        local member_data = team_members[i]
        if member_data then
            head:setHeadRes(member_data.face_id, false, LOADTEXT_TYPE, member_data.face_file, member_data.face_update_time)
            head:setLev(member_data.lev)
            head:addDesc(false)
            if member_data.is_leader == 1 then
                head:showLeader(true)  
            else
                head:showLeader(false)
            end

            local avatar_bid = member_data.avatar_bid
            if head.record_res_bid == nil or head.record_res_bid ~= avatar_bid then
                head.record_res_bid = avatar_bid
                local vo = Config.AvatarData.data_avatar[avatar_bid]
                --背景框
                if vo then
                    local res_id = vo.res_id or 1
                    local res = PathTool.getTargetRes("headcircle", "txt_cn_headcircle_" .. res_id, false, false)
                    head:showBg(res, nil, false, vo.offy)
                else
                    local bgRes = PathTool.getResFrame("common","common_1031")
                    head:showBg(bgRes, nil, true)
                end
            end
        else
            --没有数据..还原
            head:clearHead()
            head:closeLev()
            head:addDesc(true, TI18N("待加入"))
            local bgRes = PathTool.getResFrame("common","common_1031")
            head:showBg(bgRes, nil, true)
        end
    end
end

function ArenateamHallTapInvitationItem:DeleteMe()
    if self.head_list then
        for i,item in ipairs(self.head_list) do
            item:DeleteMe()
        end
        self.head_list = {}
    end

    self:removeAllChildren()
    self:removeFromParent()
end

