-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      挑战队伍界面
-- <br/> 2019年10月8日
-- --------------------------------------------------------------------
ArenateamFightListPanel = ArenateamFightListPanel or BaseClass(BaseView)

local controller = ArenateamController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort


function ArenateamFightListPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Mini   
    self.is_full_screen = false
    self.layout_name = "arenateam/arenateam_fight_list_panel"

    self.res_list = {
        -- {path = PathTool.getPlistImgForDownLoad("arenateam_hall", "arenateam_hall"), type = ResourcesType.plist}
    }

    self.refresh_cd = 10
    local config = Config.ArenaTeamData.data_const.refresh_cd
    if config then 
        self.refresh_cd = config.val
    end
end

function ArenateamFightListPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 2)
    self.main_panel = self.main_container:getChildByName("main_panel")

    self.title = self.main_panel:getChildByName("win_title")
    self.title:setString(TI18N("挑 战"))

    self.close_btn = self.main_panel:getChildByName("close_btn")
    self.lay_srollview = self.main_container:getChildByName("lay_srollview")

    self.left_btn = self.main_container:getChildByName("left_btn")
    self.left_btn:getChildByName("label"):setString(TI18N("布阵调整"))
    self.right_btn = self.main_container:getChildByName("right_btn")
    self.right_btn:getChildByName("label"):setString(TI18N("刷 新"))
    self.right_btn_label = self.right_btn:getChildByName("label")


end

function ArenateamFightListPanel:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickBtnClose) ,false, 2)
    registerButtonEventListener(self.close_btn, handler(self, self.onClickBtnClose) ,true, 2)
    registerButtonEventListener(self.left_btn, handler(self, self.onClickBtnLeft) ,true, 1)
    

    --匹配对手返回
    self:addGlobalEvent(ArenateamEvent.ARENATEAM_MATCH_OTHER_EVENT, function(data)
        if not data then return end
        self:setData(data)
    end)

    self:addGlobalEvent(ArenateamEvent.ARENATEAM_TIMER_EVENT, function(time)
        if not time then return end
        self:setTimeFormatString(time)
    end)
    --一定在 事件之后
    local time_step = model:getTimeStep()
    if time_step > 0 then
        self:startTimer()
        self:setTimeFormatString(time_step)
    end
    registerButtonEventListener(self.right_btn, handler(self, self.onClickBtnRight) ,true, 1)
end

--点击英雄
function ArenateamFightListPanel:onClickHeroItemByIndex(i)
    if not self.hero_data then return end
    LookController:getInstance():sender11061(self.hero_data.rid, self.hero_data.srv_id, self.hero_data.id)
end

--调整布阵
function ArenateamFightListPanel:onClickBtnLeft()
    if model:isLeader() then
        controller:openArenateamFormPanel(true)
    else
        message(TI18N("只有队长可进行该操作"))
    end
end

--刷新
function ArenateamFightListPanel:onClickBtnRight()
    if self.is_start_timer then return end
    if model:isLeader() then
        controller:sender27250()
        --进入倒计时
        self:startTimer(true)
    else
        message(TI18N("只有队长可进行该操作"))
    end
end

--关闭
function ArenateamFightListPanel:onClickBtnClose()
    controller:openArenateamFightListPanel(false)
end

function ArenateamFightListPanel:startTimer(is_new)
    if self.is_start_timer then return end
    self.is_start_timer = true
    self.right_btn_label:disableEffect(cc.LabelEffect.OUTLINE)
    setChildUnEnabled(true, self.right_btn)
    self.right_btn:setTouchEnabled(false)
    if is_new then
        self:setTimeFormatString(self.refresh_cd)
        model:startTimeTicket()
    end
end

function ArenateamFightListPanel:setTimeFormatString(time) 
    if time > 0 then
        self.right_btn_label:setString(string_format(TI18N("刷新(%s)"), time))
    else
        self.right_btn_label:setString(TI18N("刷 新"))
        setChildUnEnabled(false, self.right_btn)
        self.right_btn_label:enableOutline(Config.ColorData.data_color4[264], 2)
        self.is_start_timer = false

        self.right_btn:setTouchEnabled(true)
    end
end

function ArenateamFightListPanel:openRootWnd(setting)
    local setting = setting or {}
    controller:sender27251()
end

function ArenateamFightListPanel:setData(data)
    if not data then return end
    self.show_list = data.rival_list or {}
    self:updateItemlist() 
end

--列表
function ArenateamFightListPanel:updateItemlist()
    if not self.show_list then return end
    if self.scrollview_list == nil then
        local scrollview_size = self.lay_srollview:getContentSize()
        
        local setting = {
            start_x = 0,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = 0,                     -- 第一个单元的Y起点
            space_y = 0,                     -- y方向的间隔
            item_width = 606,                -- 单元的尺寸width
            item_height = 130,               -- 单元的尺寸height
            row = 1,                         -- 行数，作用于水平滚动类型
            col = 1,                         -- 列数，作用于垂直滚动类型
            delay = 1,                       -- 创建延迟时间
            once_num = 1,                    -- 每次创建的数量
        }
        self.scrollview_list = CommonScrollViewSingleLayout.new(self.lay_srollview, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scrollview_size, setting, cc.p(0, 0))

        self.scrollview_list:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.scrollview_list:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.scrollview_list:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
        self.scrollview_list:setClickEnabled(false)
    end
    self.scrollview_list:reloadData()
    if #self.show_list == 0 then
        commonShowEmptyIcon(self.lay_srollview, true)
    else
        commonShowEmptyIcon(self.lay_srollview, false)
    end
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function ArenateamFightListPanel:createNewCell(width, height)
    local cell = ArenateamFightListItem.new(width, height, self)
    return cell
end

--获取数据数量
function ArenateamFightListPanel:numberOfCells()
    if not self.show_list then return 0 end
    return #self.show_list
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function ArenateamFightListPanel:updateCellByIndex(cell, index)
    cell.index = index
    local data = self.show_list[index] 
    if data then
        cell:setData(data, index)
        if model:isLeader() then
            cell:setBtnUnEnabled(false)
        else
            cell:setBtnUnEnabled(true)
        end
    end
end


function ArenateamFightListPanel:close_callback()
    controller:openArenateamFightListPanel(false)
end

-- 子项
ArenateamFightListItem = class("ArenateamFightListItem", function()
    return ccui.Widget:create()
end)

function ArenateamFightListItem:ctor(width, height, parent)
    self.parent = parent
    self:configUI(width, height)
    self:register_event()
end

function ArenateamFightListItem:configUI(width, height)
    self.size = cc.size(width,height)
    self:setTouchEnabled(true)
    self:setContentSize(self.size)

    local csbPath = PathTool.getTargetCSB("arenateam/arenateam_fight_list_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self.root_wnd:setAnchorPoint(cc.p(0.5, 0.5))
    self.root_wnd:setPosition(width * 0.5, height * 0.5)
    self:addChild(self.root_wnd)

    self.main_container = self.root_wnd:getChildByName("main_container")

    self.head_node = self.main_container:getChildByName("head_node")
    self.head_list = {}
    for i=1,3 do
        self.head_list[i] = PlayerHead.new(PlayerHead.type.circle)
        self.head_list[i]:setHeadLayerScale(0.8)
        self.head_list[i]:setPosition(90 * (i - 1) , 0)
        self.head_list[i]:setLev(99)
        self.head_node:addChild(self.head_list[i])
    end

    self.team_name = self.main_container:getChildByName("team_name")
    self.team_score = self.main_container:getChildByName("team_score")
    self.power = self.main_container:getChildByName("power")

    self.comfirm_btn = self.main_container:getChildByName("comfirm_btn")
    self.comfirm_label = self.comfirm_btn:getChildByName("label")
    self.comfirm_label:setString(TI18N("挑 战"))
end

function ArenateamFightListItem:register_event( )
    registerButtonEventListener(self.comfirm_btn, function() self:onComfirmBtn() end, true, 2, nil, nil, 1)

    -- for i,head in ipairs(self.head_list) do
    --     head:addCallBack(function() self:onClickHead(i) end )
    -- end
end

function ArenateamFightListItem:onClickHead(i)
    if self.head_list and self.head_list[i] then
        if self.data then
            -- FriendController:getInstance():openFriendCheckPanel(true, {srv_id = self.data.srv_id, rid = self.data.rid})
        end
    end
end

function ArenateamFightListItem:setBtnUnEnabled(status)
    if status then
        setChildUnEnabled(true, self.comfirm_btn)
        self.comfirm_btn:setTouchEnabled(false)
    else
        setChildUnEnabled(false, self.comfirm_btn)
        self.comfirm_btn:setTouchEnabled(true)
    end
end

--挑战
function ArenateamFightListItem:onComfirmBtn(i)
    if not self.data then return end
    if model:isLeader() then
        controller:openArenateamFightTips(true, {data = self.data})
    else
        message(TI18N("只有队长可进行该操作"))
    end
    
end

function ArenateamFightListItem:setData(data, index)
    self.data = data
    local team_members = self.data.team_members or {}

    for i,member_data in ipairs(team_members) do
        member_data.is_leader = 0
        for i,v in ipairs(member_data.ext) do
            if v.extra_key == 1 then --是否队长
                if v.extra_val == 1 then
                    member_data.is_leader = 1  
                else
                    member_data.is_leader = -member_data.pos  
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
            head:showLeader(false)
            if member_data.is_leader == 1 then
                head:showLeader(true, 80, 80)  
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
            head:showLeader(false)
            local bgRes = PathTool.getResFrame("common","common_1031")
            head:showBg(bgRes, nil, true)
        end
    end

    self.team_name:setString(self.data.team_name)
    self.team_score:setString(string_format(TI18N("积分: %s"), self.data.team_score))
    self.power:setString(self.data.team_power)
end


function ArenateamFightListItem:DeleteMe()
    if self.item_list then
        for i,item in ipairs(self.item_list) do
            item.item:DeleteMe()
        end
        self.item_list = {}
    end

    self:removeAllChildren()
    self:removeFromParent()
end

