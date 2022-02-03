-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--       排行榜页签 伤害排名
-- <br/> 2019年8月22日
-- --------------------------------------------------------------------
ActiontermbeginsRankTabRank = class("ActiontermbeginsRankTabRank", function()
    return ccui.Widget:create()
end)

local controller = ActiontermbeginsController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_insert = table.insert
local role_vo = RoleController:getInstance():getRoleVo()

local math_floor = math.floor
local table_sort = table.sort

function ActiontermbeginsRankTabRank:ctor(parent)
    self.parent = parent
    self:config()
    self:layoutUI()
    self:registerEvents()
end

function ActiontermbeginsRankTabRank:config()

end

function ActiontermbeginsRankTabRank:layoutUI()
    local csbPath = PathTool.getTargetCSB("actiontermbegins/action_term_begins_rank_tab_rank")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    --读取文件的大小
    self.size = self.root_wnd:getContentSize()
    self:setContentSize(self.size)

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.main_container_size = self.main_container:getContentSize()


    self.rank_panel = self.main_container:getChildByName("rank_panel")

    self.item_list = self.rank_panel:getChildByName("item_list")
    local title_bg = self.rank_panel:getChildByName("title_bg")
    title_bg:getChildByName("col_label_1"):setString(TI18N("排名"))
    title_bg:getChildByName("col_label_2"):setString(TI18N("玩家名字"))
    title_bg:getChildByName("col_label_3"):setString(TI18N("伤害累计"))

    self.my_rank = self.main_container:getChildByName("my_rank")
    local title = self.my_rank:getChildByName('title')
    title:setString(TI18N('我的排名'))
    self.no_rank_label = self.my_rank:getChildByName("no_rank_label")
    self.no_rank_label:setVisible(false)
    self.my_rank_id = self.my_rank:getChildByName("rank_id")
    self.my_name_label = self.my_rank:getChildByName("my_name_label")
    self.my_attk_label = self.my_rank:getChildByName("my_attk_label")
    self.rank_label = self.my_rank:getChildByName("rank_label")
    self.my_head = PlayerHead.new(PlayerHead.type.circle)
    self.my_head:setHeadLayerScale(0.8)
    self.my_head:setPosition(150, 66)
    self.my_rank:addChild(self.my_head)
end

--事件
function ActiontermbeginsRankTabRank:registerEvents()
    -- registerButtonEventListener(self.look_btn, function(param,sender, event_type) 
    --     if self.parent and self.parent.is_move_effect then return end
    --     local config = Config.ResonateData.data_const.rule_tips
    --     if config then
    --         TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition(),nil,nil,500)
    --     end
    -- end ,true, 2, nil, 0.8)
end

function ActiontermbeginsRankTabRank:setData()
    if not self.parent then return end

    if self.parent.rank_type == RankConstant.RankType.termbegins then
        if not self.is_init then
            self.is_init = true
            if self.parent.scdata then
                self:setScdata(self.parent.scdata)         
            end
        end
    end

    -- --测试
    -- self:setScdata(self.parent.scdata)
end


function ActiontermbeginsRankTabRank:setScdata(data )
    if not self.parent then return end
    data = data or {}
    local role_vo = RoleController:getInstance():getRoleVo()
    self.my_head:setHeadRes(role_vo.face_id, false, LOADTEXT_TYPE, role_vo.face_file, role_vo.face_update_time)
    self.my_head:setLev(role_vo.lev)
    self.my_name_label:setString(role_vo.name)
    -- self.my_attk_label:setString(role_vo.power)

    if self.parent.rank_type == RankConstant.RankType.termbegins then
        self.rank_label:setString(data.mydps)
    else
        self.rank_label:setString(TI18N("未知"))
    end

    if not data.rank or data.rank == 0 then
        self.no_rank_label:setVisible(true)
        self.my_rank_id:setVisible(false)
    else
        self.my_rank_id:setString(data.rank)
        self.no_rank_label:setVisible(false)
    end


    self.show_list  = data.rank_list
    table_sort( self.show_list, function(a, b) return a.rank < b.rank  end)
    self:updateList()
end

function ActiontermbeginsRankTabRank:updateList()
    if self.item_scrollview == nil then
        local scroll_view_size = self.item_list:getContentSize()
        local setting = {
            start_x = 0,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = 0,                     -- 第一个单元的Y起点
            space_y = 0,                     -- y方向的间隔
            item_width = 614,                -- 单元的尺寸width
            item_height = 128,               -- 单元的尺寸height
            row = 1,                         -- 行数，作用于水平滚动类型
            col = 1,                         -- 列数，作用于垂直滚动类型
            once_num = 1,                    -- 每次创建的数量
        }
        self.item_scrollview = CommonScrollViewSingleLayout.new(self.item_list, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0, 0))

        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    end

    if #self.show_list == 0 then
        commonShowEmptyIcon(self.item_list, true, {text = TI18N("暂无排行数据")})
    else
        commonShowEmptyIcon(self.item_list, false)
    end
    self.item_scrollview:reloadData()
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function ActiontermbeginsRankTabRank:createNewCell(width, height)
   local cell = TermbeginsRankItem.new(width, height, self)
   if self.parent then
       cell:initRankTypeUI(self.parent.rank_type)
    end
    -- cell:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end
--获取数据数量
function ActiontermbeginsRankTabRank:numberOfCells()
    if not self.show_list then return 0 end
    return #self.show_list
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function ActiontermbeginsRankTabRank:updateCellByIndex(cell, index)
    cell.index = index
    local cell_data = self.show_list[index]
    if not cell_data then return end
    cell:setData(cell_data, index)
end


function ActiontermbeginsRankTabRank:setVisibleStatus(bool)
    self:setVisible(bool)
end

--移除
function ActiontermbeginsRankTabRank:DeleteMe()
    if self.boss_form_event then
        GlobalEvent:getInstance():UnBind(self.boss_form_event)
        self.boss_form_event = nil
    end
    if self.item_list then
        for i,v in pairs(self.item_list) do
            v:DeleteMe()
        end
        self.item_list = nil
    end

    if self.item_scrollview then 
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
    doStopAllActions(self.item_scrollview)
end


------------------------------@ item
TermbeginsRankItem = class("TermbeginsRankItem",function()
    return ccui.Layout:create()
end)

function TermbeginsRankItem:ctor(width, height)
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("endlesstrail/endlesstrail_rank_item"))
    self.size = cc.size(width, height)
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setContentSize(self.size)

    self.root_wnd:setAnchorPoint(0.5, 0.5)
    self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
    self:addChild(self.root_wnd)

    local container = self.root_wnd:getChildByName("container")
    self.rank_img = container:getChildByName("rank_img")
    self.role_name = container:getChildByName("role_name")
    
    self.role_power = container:getChildByName("role_power")
    self.role_head = PlayerHead.new(PlayerHead.type.circle)
    self.role_head:setHeadLayerScale(0.95)
    self.role_head:setPosition(150, 65)
    container:addChild(self.role_head)
    self.role_head:setLev(99)

    self.container = container

    self:registerEvent()
end

function TermbeginsRankItem:registerEvent()
    self.role_head:addCallBack( function()
        if self.data ~= nil then
            FriendController:getInstance():openFriendCheckPanel(true, {srv_id = self.data.r_srvid, rid = self.data.r_rid})
        end
    end,false)
end

function TermbeginsRankItem:addCallBack(call_back)
    self.call_back = call_back
end

function TermbeginsRankItem:setData(data, index)
    local role_vo = RoleController:getInstance():getRoleVo()
    if data and role_vo then
        self.data = data
        self.role_name:setString(data.name)
        -- self.role_power:setString(data.val3)
        self.role_head:setHeadRes(data.face_id, false, LOADTEXT_TYPE, data.face_file, data.face_update_time)
        self.role_head:setLev(data.lev)
        local avatar_bid = data.avatar_bid 
        local vo = Config.AvatarData.data_avatar[avatar_bid]
        if vo then
            local res_id = vo.res_id or 1
            local res = PathTool.getTargetRes("headcircle", "txt_cn_headcircle_" .. res_id, false, false)
            self.role_head:showBg(res, nil, false, vo.offy)
        end

        if index <= 3 then
            if self.rank_num ~= nil then
                self.rank_num:setVisible(false)
            end
            if index == 0 then
                self.rank_img:setVisible(false)
            else
                local res_id = PathTool.getResFrame("common", string.format("common_200%s", index))
                if self.rank_res_id ~= res_id then
                    self.rank_res_id = res_id
                    loadSpriteTexture(self.rank_img, res_id, LOADTEXT_TYPE_PLIST)
                end
                self.rank_img:setVisible(true)
            end
        else
            if self.rank_num == nil then
                self.rank_num = CommonNum.new(1, self.container, 1, -2, cc.p(0.5, 0.5))
                self.rank_num:setPosition(59, 77)
            end
            self.rank_num:setVisible(true)
            self.rank_num:setNum(index)
            self.rank_img:setVisible(false)
        end
        self:updateOtherInfo(data)
    end
end

--初始化类型对应的ui
function TermbeginsRankItem:initRankTypeUI(rank_type)
    self.rank_type = rank_type or RankConstant.RankType.termbegins --开学季活动排行榜
    if self.rank_type == RankConstant.RankType.termbegins then
        self.role_name:setPositionY(65)
        self.container:getChildByName("role_power"):setVisible(false)
        self.container:getChildByName("Image_1"):setVisible(false)
        self.container:getChildByName("Sprite_1"):setVisible(false)
        self.role_head:setPosition(162, 65)
    else
        --其他ui
    end
end

function TermbeginsRankItem:updateOtherInfo(data)
    if self.rank_type == RankConstant.RankType.termbegins then --开学季活动排行榜
        local msg = string.format(TI18N("<div fontcolor=#249003 fontsize=22>%s</div>"), data.all_dps)
        if self.score_info == nil then
            self.score_info = createRichLabel(20, 175, cc.p(0.5, 0.5), cc.p(480, 65), nil, nil, 300)
            self.container:addChild(self.score_info)
        end
        self.score_info:setString(msg)
    else
        --其他类型
    end
end

function TermbeginsRankItem:DeleteMe()
    if self.rank_num ~= nil then
        self.rank_num:DeleteMe()
        self.rank_num = nil
    end
    self:removeAllChildren()
    self:removeFromParent()
end