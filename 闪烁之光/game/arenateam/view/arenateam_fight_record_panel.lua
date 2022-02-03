-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      组队竞技场录像预览
-- <br/> 2019年10月17日
-- --------------------------------------------------------------------
ArenateamFightRecordPanel = ArenateamFightRecordPanel or BaseClass(BaseView)

local controller = ArenateamController:getInstance()
local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort

function ArenateamFightRecordPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Big   
    self.is_full_screen = false
    self.layout_name = "arenateam/arenateam_fight_record_panel"

    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("vedio","vedio"), type = ResourcesType.plist },
    }

    --奖励
    -- self.dic_reward_list = {}
    -- self.show_list = {}
    self.arena_elite_log_list = {}
end

function ArenateamFightRecordPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 1)
    self.main_panel = self.main_container:getChildByName("main_panel")

    self.title = self.main_panel:getChildByName("win_title")
    self.title:setString(TI18N("比赛记录"))

    self.scroll_container = self.main_panel:getChildByName("scroll_container")

    self.close_btn = self.main_panel:getChildByName("close_btn")
    self.top_label = self.main_panel:getChildByName("top_label")

     self.top_label:setString(TI18N("录像可以在\"详细\"中观看"))
end

function ArenateamFightRecordPanel:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickBtnClose) ,false, 1)
    registerButtonEventListener(self.close_btn, handler(self, self.onClickBtnClose) ,true, 2)

    --  --积分发送改变的时候
    self:addGlobalEvent(ArenateamEvent.ARENATEAM_MIAIN_REPORT_EVENT, function(data)
        if not data then return end
        self:setData(data)
    end)
end

--关闭
function ArenateamFightRecordPanel:onClickBtnClose()
    controller:openArenateamFightRecordPanel(false)
end

--@level_id 段位
function ArenateamFightRecordPanel:openRootWnd(setting)
    controller:sender27255()

    -- self:setData()
end

function ArenateamFightRecordPanel:setData(data)
    if not data then return end
    self.show_list = data.arena_team_log
    table_sort(self.show_list, function(a, b) return a.time > b.time end)
    self:updateList()
end

function ArenateamFightRecordPanel:updateList()
    if self.item_scrollview == nil then
        local scroll_view_size = self.scroll_container:getContentSize()
        local setting = {
            start_x = 0,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = 0,                     -- 第一个单元的Y起点
            space_y = 0,                     -- y方向的间隔
            item_width = 600,                -- 单元的尺寸width
            item_height = 275,               -- 单元的尺寸height
            row = 1,                         -- 行数，作用于水平滚动类型
            col = 1,                         -- 列数，作用于垂直滚动类型
            once_num = 1,                    -- 每次创建的数量
        }
        self.item_scrollview = CommonScrollViewSingleLayout.new(self.scroll_container, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0, 0))

        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    end

    if #self.show_list == 0 then
        commonShowEmptyIcon(self.scroll_container, true, {text = TI18N("暂无录像信息")})
    else
        commonShowEmptyIcon(self.scroll_container, false)
    end
    self.item_scrollview:reloadData()
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function ArenateamFightRecordPanel:createNewCell(width, height)
   local cell = ArenateamFightRecordItem.new(width, height)
   -- cell:setActionRankCommonType(self.holiday_bid, self.type)
    -- cell:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end
--获取数据数量
function ArenateamFightRecordPanel:numberOfCells()
    if not self.show_list then return 0 end
    return #self.show_list
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function ArenateamFightRecordPanel:updateCellByIndex(cell, index)
    cell.index = index
    local cell_data = self.show_list[index]
    if not cell_data then return end
    cell:setData(cell_data)
end


function ArenateamFightRecordPanel:close_callback()
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
    end
    self.item_scrollview = nil
    controller:openArenateamFightRecordPanel(false)
end


ArenateamFightRecordItem = class("ArenateamFightRecordItem", function()
    return ccui.Widget:create()
end)

function ArenateamFightRecordItem:ctor(width, height)
    self:configUI(width, height)
    self:register_event()
end

function ArenateamFightRecordItem:configUI(width, height)
    self.size = cc.size(width, height)
    self:setTouchEnabled(true)
    self:setContentSize(self.size)

    local csbPath = PathTool.getTargetCSB("arenateam/arenateam_fight_record_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    local container = self.root_wnd:getChildByName("container")


    self.result_win = container:getChildByName("result_win")
    self.result_loss = container:getChildByName("result_loss")
    self.result_win_x = self.result_win:getPositionX()
    self.result_loss_x = self.result_loss:getPositionX()

    self.play_btn = container:getChildByName("play_btn")
    --中间部分
    self.title_info = container:getChildByName("title_info")
    self.time_val = container:getChildByName("time_val")

    local _getItem = function(prefix, name_pos, score_pos, rank_pos)
        local item = {}
        if prefix == "left_" then
            item.name = createRichLabel(20, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0, 0.5), name_pos,nil,nil,600)
        else
            item.name = createRichLabel(20, cc.c4b(0x64,0x32,0x23,0xff), cc.p(1, 0.5), name_pos,nil,nil,600)
        end
        container:addChild(item.name)
        item.power_key = container:getChildByName(prefix.."power_key")
        item.power_key:setString("战力")
        item.score_key = container:getChildByName(prefix.."score_key")
        item.score_key:setString("积分")
        item.rank_key = container:getChildByName(prefix.."rank_key")
        item.rank_key:setString("排行")
        
        item.power_value = container:getChildByName(prefix.."power_value")
        item.score_value = container:getChildByName(prefix.."score_value")
        item.rank_value = container:getChildByName(prefix.."rank_value")
        
        item.score_value_1 = createRichLabel(20, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0, 0.5), score_pos,nil,nil,600)
        container:addChild(item.score_value_1)
        item.rank_value_1 = createRichLabel(20, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0, 0.5), rank_pos,nil,nil,600)
        container:addChild(item.rank_value_1)
        item.head_node = container:getChildByName(prefix.."head_node")
        item.head_list = {}
        for i=1,3 do
            item.head_list[i] = PlayerHead.new(PlayerHead.type.circle)
            item.head_list[i]:setHeadLayerScale(0.7)
            item.head_list[i]:setPosition(70 * (i - 1) , 0)
            -- item.head_list[i]:setLev(99)
            item.head_node:addChild(item.head_list[i])
            item.head_list[i]:addCallBack(function() self:onClickHeadBtn(i, prefix) end)
        end
        return item
    end
    local name_pos = cc.p(48, 206)
    local score_pos = cc.p(143, 61)
    local rank_pos = cc.p(143, 27)
    self.left_item = _getItem("left_", name_pos, score_pos, rank_pos)
    name_pos = cc.p(548, 206)
    score_pos = cc.p(484, 61)
    rank_pos = cc.p(484, 27)
    self.right_item = _getItem("right_", name_pos, score_pos, rank_pos)
    
end

function ArenateamFightRecordItem:register_event( )
    registerButtonEventListener(self.play_btn, handler(self, self.onClickPlayBtn) ,true, 2)
end

function ArenateamFightRecordItem:onClickHeadBtn(i, prefix)
    if not self.data then return end
    local team_members
    if prefix == "left_" then --左
        team_members = self.data.a_team_members
    else --右
        team_members = self.data.b_team_members
    end
    if team_members and team_members[i] then
        local roleVo = RoleController:getInstance():getRoleVo()
        if roleVo and team_members[i].rid == roleVo.rid and team_members[i].sid == roleVo.srv_id then 
            message(TI18N("这是你自己~"))
            return
        end
        FriendController:getInstance():openFriendCheckPanel(true, {srv_id = team_members[i].sid, rid = team_members[i].rid})
    end
end

function ArenateamFightRecordItem:onClickPlayBtn()
    if not self.data then return end
    controller:openArenateamFightVedioPanel(true, {data = self.data})
end

function ArenateamFightRecordItem:setData(data)
    if not data then return end
    self.data = data
    local time = TimeTool.getYMDHM(data.time)
    self.time_val:setString(time)
    --false 表示 我不是进攻方
    local my_is_atk = false
    local role_vo = RoleController:getInstance():getRoleVo() --奇怪在文件前面定义这个 居然说是空的
    if role_vo then
        for i,v in ipairs(data.a_team_members) do
            if v.rid == role_vo.rid and v.sid == role_vo.srv_id then
                my_is_atk = true --表示我是进攻方
                break
            end
        end
    end
    if data.ret == 1 then --左边胜利
        if my_is_atk then
            self.title_info:setString(TI18N("进攻成功"))
            self.title_info:setTextColor(cc.c3b(36, 144, 3))
        else
            self.title_info:setString(TI18N("防守失败")) 
            self.title_info:setTextColor(cc.c3b(217, 80, 20))
        end
        self.result_win:setPositionX(self.result_win_x)
        self.result_loss:setPositionX(self.result_loss_x)
    else --右边胜利了
         if my_is_atk then
            self.title_info:setString(TI18N("进攻失败"))    
            self.title_info:setTextColor(cc.c3b(217, 80, 20))
        else
            self.title_info:setString(TI18N("防守成功"))
            self.title_info:setTextColor(cc.c3b(36, 144, 3))
        end
        self.result_loss:setPositionX(self.result_win_x)
        self.result_win:setPositionX(self.result_loss_x)
    end


    --左右
    local srv_id = data.a_srv_id or "dev_1"
    local name = data.atk_name or "1111"
    local rank = data.a_rank
    local power = data.a_team_power
    local score = data.a_score
    local new_score = data.a_new_score
    local new_rank = data.a_new_rank
    local team_members = data.a_team_members
    self:initItemInfo(self.left_item, srv_id, name, rank, power, score, new_score, new_rank, team_members)

     srv_id = data.b_srv_id or "dev_1"
     name = data.b_team_name or "1111"
     rank = data.b_rank
     power = data.b_team_power
     score = data.b_score
     new_score = data.b_new_score
     new_rank = data.b_new_rank
     team_members = data.b_team_members
    self:initItemInfo(self.right_item, srv_id, name, rank, power, score, new_score, new_rank, team_members)
end

function ArenateamFightRecordItem:getArrowRes(value)
    if value > 0 then
        return PathTool.getResFrame("common", "common_1086")
    elseif value < 0 then
        return PathTool.getResFrame("common", "common_1087")
    end
    return ""
end

function ArenateamFightRecordItem:initItemInfo(item, srv_id, name, rank, power, score, new_score, new_rank, team_members)
    -- local srv_name = getServerName(srv_id)
    -- item.name:setString(string_format("<div fontcolor=#955322>[%s]</div><div fontcolor=#643223>%s</div>", srv_name, name))
    local str = transformNameByServ(name, srv_id)
    item.name:setString(str)

    item.power_value:setString(power or 0)
    item.score_value:setString(new_score or 0)

    local s = new_score - score

    local str
    if s == 0 then
        item.score_value_1:setString("")
    else
        local res = self:getArrowRes(s)
        if s > 0 then
            str = string_format("<div fontcolor=#249003>(<img src=%s visible=true scale=0.8 /><div> %s)</div>", res, s)
        else
            str = string_format("<div fontcolor=#951014>(<img src=%s visible=true scale=0.8 /><div> %s)</div>", res, s)
        end
        item.score_value_1:setString(str)
    end

    if new_rank == 0 then
        item.rank_value:setString(TI18N("暂无"))
        item.rank_value_1:setString("")
    else
        item.rank_value:setString(new_rank)
        local s = rank - new_rank
        if rank ~= 0 then
            if s == 0 then
                item.rank_value_1:setString("")
            else
                local res = self:getArrowRes(s)
                if s > 0 then
                    str = string_format("<div fontcolor=#249003>(<img src=%s visible=true scale=0.8 /><div> %s)</div>", res, s)
                else
                    str = string_format("<div fontcolor=#951014>(<img src=%s visible=true scale=0.8 /><div> %s)</div>", res, s)
                end
                item.rank_value_1:setString(str)
            end
        else
            item.rank_value_1:setString("")
        end
        
    end
    if item.head_list then
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
        for i=1,3 do
            local head = item.head_list[i]
            if head then
                local member_data = team_members[i]
                if member_data then
                    head:setHeadRes(member_data.face_id, false, LOADTEXT_TYPE, member_data.face_file, member_data.face_update_time)
                    head:setLev(member_data.lev, cc.p(16, 60))
                    if member_data.is_leader == 1 then
                        head:showLeader(true, 70, 74)  
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
        end
    end
end

function ArenateamFightRecordItem:DeleteMe( )

    if self.left_item.item_load then
        self.left_item.item_load:DeleteMe()
        self.left_item.item_load = nil
    end
    if self.right_item.item_load then
        self.right_item.item_load:DeleteMe()
        self.right_item.item_load = nil
    end
    if self.left_item.item_load_1 then
        self.left_item.item_load_1:DeleteMe()
        self.left_item.item_load_1 = nil
    end
    if self.right_item.item_load_1 then
        self.right_item.item_load_1:DeleteMe()
        self.right_item.item_load_1 = nil
    end
    self:removeAllChildren()
    self:removeFromParent()
end