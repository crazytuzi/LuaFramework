-- --------------------------------------------------------------------
-- @author: xhj@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      多人竞技场录像预览
-- <br/> 2020-03-18
-- --------------------------------------------------------------------
ArenaManyPeopleFightRecordPanel = ArenaManyPeopleFightRecordPanel or BaseClass(BaseView)

local controller = ArenaManyPeopleController:getInstance()
local string_format = string.format
local table_sort = table.sort

function ArenaManyPeopleFightRecordPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Big   
    self.is_full_screen = false
    self.layout_name = "arenamanypeople/amp_fight_record_panel"

    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("vedio","vedio"), type = ResourcesType.plist },
    }

    --奖励
    self.show_list = {}
end

function ArenaManyPeopleFightRecordPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")

    -- 通用进场动效
    ActionHelp.itemUpAction(self.main_container, 720, 0, 0.25)

    self.main_panel = self.main_container:getChildByName("main_panel")

    self.title = self.main_panel:getChildByName("win_title")
    self.title:setString(TI18N("比赛记录"))

    self.scroll_container = self.main_panel:getChildByName("scroll_container")

    self.close_btn = self.main_panel:getChildByName("close_btn")
    self.top_label = self.main_panel:getChildByName("top_label")

     self.top_label:setString(TI18N("录像可以在\"详细\"中观看"))
end

function ArenaManyPeopleFightRecordPanel:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickBtnClose) ,false, 1)
    registerButtonEventListener(self.close_btn, handler(self, self.onClickBtnClose) ,true, 2)

    self:addGlobalEvent(ArenaManyPeopleEvent.ARENAMANYPOEPLE_MIAIN_REPORT_EVENT, function(data)
        if not data then return end
        self:setData(data)
    end)
end

--关闭
function ArenaManyPeopleFightRecordPanel:onClickBtnClose()
    controller:openArenaManyPeopleFightRecordPanel(false)
end

--@level_id 段位
function ArenaManyPeopleFightRecordPanel:openRootWnd()
    controller:sender29026()

end

function ArenaManyPeopleFightRecordPanel:setData(data)
    if not data then return end
    self.show_list = data.holiday_arena_team_log
    table_sort(self.show_list, function(a, b) return a.time > b.time end)
    self:updateList()
end

function ArenaManyPeopleFightRecordPanel:updateList()
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
function ArenaManyPeopleFightRecordPanel:createNewCell(width, height)
   local cell = ArenaManyPeopleFightRecordItem.new(width, height)
    return cell
end
--获取数据数量
function ArenaManyPeopleFightRecordPanel:numberOfCells()
    if not self.show_list then return 0 end
    return #self.show_list
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function ArenaManyPeopleFightRecordPanel:updateCellByIndex(cell, index)
    cell.index = index
    local cell_data = self.show_list[index]
    if not cell_data then return end
    cell:setData(cell_data)
end


function ArenaManyPeopleFightRecordPanel:close_callback()
    doStopAllActions(self.main_container)

    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
    end
    self.item_scrollview = nil
    controller:openArenaManyPeopleFightRecordPanel(false)
end


ArenaManyPeopleFightRecordItem = class("ArenaManyPeopleFightRecordItem", function()
    return ccui.Widget:create()
end)

function ArenaManyPeopleFightRecordItem:ctor(width, height)
    self:configUI(width, height)
    self:register_event()
end

function ArenaManyPeopleFightRecordItem:configUI(width, height)
    self.size = cc.size(width, height)
    self:setTouchEnabled(true)
    self:setContentSize(self.size)

    local csbPath = PathTool.getTargetCSB("arenamanypeople/amp_fight_record_item")
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
        item.image_rank_1 = container:getChildByName(prefix.."image_rank_1")
        item.image_rank_2 = container:getChildByName(prefix.."image_rank_2")
        item.power_key = container:getChildByName(prefix.."power_key")
        item.power_key:setString("战力")
        item.score_key = container:getChildByName(prefix.."score_key")
        item.score_key:setString("我的积分")
        item.rank_key = container:getChildByName(prefix.."rank_key")
        item.rank_key:setString("我的排行")
        
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
            item.head_node:addChild(item.head_list[i])
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

function ArenaManyPeopleFightRecordItem:register_event( )
    registerButtonEventListener(self.play_btn, handler(self, self.onClickPlayBtn) ,true, 2)
end


function ArenaManyPeopleFightRecordItem:onClickPlayBtn()
    if not self.data then return end
    controller:openArenaManyPeopleFightVedioPanel(true, {data = self.data})
end

function ArenaManyPeopleFightRecordItem:setData(data)
    
    if not data then return end
    self.data = data
    local time = TimeTool.getYMDHM(data.time)
    self.time_val:setString(time)
    --false 表示 我不是进攻方
    local my_is_atk = data.is_atk or 0

    if data.ret == 1 then --左边胜利
        if my_is_atk == 1 then
            self.title_info:setString(TI18N("进攻成功"))
            self.title_info:setTextColor(cc.c3b(36, 144, 3))
            self.result_win:setPositionX(self.result_win_x)
            self.result_loss:setPositionX(self.result_loss_x)
        else
            self.title_info:setString(TI18N("防守失败")) 
            self.title_info:setTextColor(cc.c3b(217, 80, 20))
            self.result_loss:setPositionX(self.result_win_x)
            self.result_win:setPositionX(self.result_loss_x)
        end
        
    else --右边胜利了
         if my_is_atk == 1 then
            self.title_info:setString(TI18N("进攻失败"))    
            self.title_info:setTextColor(cc.c3b(217, 80, 20))
            self.result_loss:setPositionX(self.result_win_x)
            self.result_win:setPositionX(self.result_loss_x)
        else
            self.title_info:setString(TI18N("防守成功"))
            self.title_info:setTextColor(cc.c3b(36, 144, 3))
            self.result_win:setPositionX(self.result_win_x)
            self.result_loss:setPositionX(self.result_loss_x)
        end
    end


    --左右
    local srv_id = data.srv_id or "dev_1"
    local name = data.atk_name or "1111"
    local rank = data.atk_ole_rank
    local power = data.atk_power or 0
    local score = data.atk_ole_score
    local new_score = data.atk_score
    local new_rank = data.atk_rank
    local team_members = data.atk_face
    
    if my_is_atk == 1 then
        self:initItemInfo(self.left_item, srv_id, name, rank, power, score, new_score, new_rank, team_members)
    else
        rank = nil
        score = nil
        new_score = nil
        new_rank = nil
        self:initItemInfo(self.right_item, srv_id, name, rank, power, score, new_score, new_rank, team_members)
    end
    

     srv_id = data.def_srv_id or "dev_1"
     name = data.def_name or "1111"
     rank = nil
     power = data.def_power or 0
     score = nil
     new_score = nil
     new_rank = nil
     team_members = data.def_face
    if my_is_atk == 1 then
        self:initItemInfo(self.right_item, srv_id, name, rank, power, score, new_score, new_rank, team_members)
    else
        rank = data.def_ole_rank
        score = data.def_ole_score
        new_score = data.def_score
        new_rank = data.def_rank
        self:initItemInfo(self.left_item, srv_id, name, rank, power, score, new_score, new_rank, team_members)
    end
   
end

function ArenaManyPeopleFightRecordItem:getArrowRes(value)
    if value > 0 then
        return PathTool.getResFrame("common", "common_1086")
    elseif value < 0 then
        return PathTool.getResFrame("common", "common_1087")
    end
    return ""
end

function ArenaManyPeopleFightRecordItem:initItemInfo(item, srv_id, name, rank, power, score, new_score, new_rank, team_members)
    local str = transformNameByServ(name, srv_id)
    item.name:setString(str)

    item.power_value:setString(power or 0)
    item.score_value:setString(new_score or 0)

    if score and new_score then
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
        item.score_key:setVisible(true)
        item.image_rank_1:setVisible(true)
    else
        item.score_value:setString("")
        item.score_value_1:setString("")
        item.score_key:setVisible(false)
        item.image_rank_1:setVisible(false)
    end
    
    if rank and new_rank then
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
        item.rank_key:setVisible(true)
        item.image_rank_2:setVisible(true)
    else
        item.rank_value:setString("")
        item.rank_value_1:setString("")
        item.rank_key:setVisible(false)
        item.image_rank_2:setVisible(false)
    end
    
    if item.head_list then
        
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

function ArenaManyPeopleFightRecordItem:DeleteMe( )

    if self.left_item and self.left_item.head_list then
        for k,v in pairs(self.left_item.head_list) do
            v:DeleteMe()
            v = nil
        end
        self.left_item.head_list = nil
    end
    if self.right_item and self.right_item.head_list then
        for k,v in pairs(self.right_item.head_list) do
            v:DeleteMe()
            v = nil
        end
        self.right_item.head_list = nil
    end
 
    self:removeAllChildren()
    self:removeFromParent()
end