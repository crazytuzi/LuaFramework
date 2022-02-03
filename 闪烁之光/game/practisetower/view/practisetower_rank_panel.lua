-- --------------------------------------------------------------------
-- @author: xhj@syg.com(必填, 创建模块的人员)
-- @editor: @syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      新人练武场排行榜数据
-- <br/>Create: 2020-4-13
-- --------------------------------------------------------------------
PractisetowerRankPanel = class("PractisetowerRankPanel",function()
    return ccui.Layout:create()
end)

local controller = PractisetowerController:getInstance()
local model = controller:getModel() 

function PractisetowerRankPanel:ctor()
    self.is_init = true
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("practisetower/practise_tower_rank_panel"))

    self.size = self.root_wnd:getContentSize()
    self:setContentSize(self.size)

    self.root_wnd:setAnchorPoint(0.5, 0.5)
    self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
    self:addChild(self.root_wnd)

    self.scroll_container = self.root_wnd:getChildByName("scroll_container")
    self.empty_bg = self.scroll_container:getChildByName("empty_bg")
    self.empty_bg:setVisible(false)
    loadSpriteTexture(self.empty_bg, PathTool.getPlistImgForDownLoad("bigbg", "bigbg_3"), LOADTEXT_TYPE)
    self.desc_label = self.empty_bg:getChildByName("desc_label")
    self.desc_label:setPositionX(self.empty_bg:getContentSize().width / 2)
    self.desc_label:setString(TI18N("暂无记录"))
    
    local size = cc.size(self.scroll_container:getContentSize().width, self.scroll_container:getContentSize().height)
    local setting = {
        item_class = PractisetowerRankItem,
        start_x = 0,
        space_x = 0,
        start_y = 0,
        space_y = 2,
        item_width = 600,
        item_height = 135,
        row = 0,
        col = 1,
        need_dynamic = true
    }
    
    self.scroll_view = CommonScrollViewSingleLayout.new(self.scroll_container,  cc.p(0, 0), ScrollViewDir.vertical, ScrollViewStartPos.top, size, setting)
    self.scroll_view:registerScriptHandlerSingle(handler(self, self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
    self.scroll_view:registerScriptHandlerSingle(handler(self, self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
    self.scroll_view:registerScriptHandlerSingle(handler(self, self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell


    local my_container = self.root_wnd:getChildByName("my_container")
    local my_rank_title = my_container:getChildByName("my_rank_title")
    my_rank_title:setString(TI18N("我的排名"))
    self.root_wnd:getChildByName("title_1"):setString(TI18N("排名"))
    self.root_wnd:getChildByName("title_2"):setString(TI18N("玩家信息"))
    self.root_wnd:getChildByName("title_3"):setString(TI18N("回放"))
    self.root_wnd:getChildByName("title_4"):setString(TI18N("通关时间"))
    
    self.rank_img = my_container:getChildByName("rank_img")
    self.rank_img:setVisible(false)


    self.role_name = my_container:getChildByName("role_name")
    self.role_power = my_container:getChildByName("role_power")
    self.no_rank = my_container:getChildByName("no_rank")
    self.no_rank:setString(TI18N("未上榜"))
    self.no_rank:setVisible(false)
    
    self.voide_btn = my_container:getChildByName("voide_btn")
    self.voide_btn:setVisible(false)
    self.time_lab = my_container:getChildByName("time_lab")
    self.time_lab:setVisible(false)

    self.role_head = PlayerHead.new(PlayerHead.type.circle)
    self.role_head:setHeadLayerScale(0.9)
    self.role_head:setPosition(150, 76)
    self.role_head:setLev(99)
    my_container:addChild(self.role_head)

    self.my_container = my_container

    self:registerEvent()
    self:addToParent()
end


--创建cell
--@width 是setting.item_width
--@height 是setting.item_height
function PractisetowerRankPanel:createNewCell()
    local cell = PractisetowerRankItem.new()
    return cell
end

--获取数据数量
function PractisetowerRankPanel:numberOfCells()
    if not self.rank_list then
        return 0
    end
    return #self.rank_list
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function PractisetowerRankPanel:updateCellByIndex(cell, index)
    cell.index = index
    local cell_data = self.rank_list[index]
    if not cell_data then
        return
    end
    local time_desc = cell:setData(cell_data)
end

function PractisetowerRankPanel:registerEvent()
    if self.update_rank_event == nil then
        self.update_rank_event = GlobalEvent:getInstance():Bind(PractisetowerEvent.Update_Top3_rank, function(scdata) 
            if not scdata then return end
            self:updateRankList(scdata)
        end)
    end

    registerButtonEventListener(self.voide_btn, function()
        local role_vo = RoleController:getInstance():getRoleVo()
        if self.data and role_vo then
    		BattleController:getInstance():csRecordBattle(self.data.role_video_id,role_vo.srv_id)
        end
	end,true)

end

function PractisetowerRankPanel:setVisibleStatus(status)
    self:setVisible(status)
end

function PractisetowerRankPanel:addToParent()
    -- 窗体打开只请求一次，不是标签显示
    if self.is_init == true then
        controller:sender29105()
        self.is_init = false
    end
end


function PractisetowerRankPanel:updateRankList(data)
    local role_vo = RoleController:getInstance():getRoleVo()
    if data and role_vo then
        self.data = data
        self.role_name:setString(role_vo.name)
        self.role_power:setString(string.format(TI18N("通关层数：%d层") ,data.role_val ))
        
        if data.role_rank and data.role_rank <= 3 then
            if self.rank_num ~= nil then
                self.setVisible(false)
            end
            if data.role_rank == 0 then
                self.rank_img:setVisible(false)
                self.no_rank:setVisible(true)

            else
                self.no_rank:setVisible(false)
                local res_id = PathTool.getResFrame("common", string.format("common_200%s", data.role_rank))
                if self.rank_res_id ~= res_id then
                    self.rank_res_id  = res_id
                    loadSpriteTexture(self.rank_img, res_id, LOADTEXT_TYPE_PLIST)
                end
                self.rank_img:setVisible(true)
            end
        else
            if self.rank_num == nil then
                self.rank_num = CommonNum.new(1, self.my_container, 1, -2, cc.p(0.5, 0.5))
                self.rank_num:setPosition(48,90)
            end
            self.rank_num:setVisible(true)
            self.rank_num:setNum(data.role_rank)
            self.rank_img:setVisible(false)
        end


        self.role_head:setHeadRes(role_vo.face_id, false, LOADTEXT_TYPE, role_vo.face_file, role_vo.face_update_time)
        self.role_head:setLev(role_vo.lev)
        local avatar_bid = role_vo.avatar_bid
        local vo = Config.AvatarData.data_avatar[avatar_bid]
        if vo then
            local res_id = vo.res_id or 1
            local res = PathTool.getTargetRes("headcircle", "txt_cn_headcircle_" .. res_id, false, false)
            self.role_head:showBg(res, nil, false, vo.offy)
        end

        if data.role_video_id>0 then
            self.voide_btn:setVisible(true)
        end

        if data.role_unixtime>0 then
            self.time_lab:setVisible(true)
        end
        self.time_lab:setString(string.format( "%s\n%s",TimeTool.getYMD(data.role_unixtime),TimeTool.getHM(data.role_unixtime) ))

        self.rank_list = {}
        if data.practise_role_rank ~= nil and next(data.practise_role_rank) ~= nil then
            self.rank_list = data.practise_role_rank
            self.empty_bg:setVisible(false)
        else
            self.empty_bg:setVisible(true)
        end
        table.sort(self.rank_list, SortTools.KeyLowerSorter("rank"))
        self.scroll_view:reloadData()
    end
end


function PractisetowerRankPanel:DeleteMe()
    if self.update_rank_event ~= nil then
        GlobalEvent:getInstance():UnBind(self.update_rank_event)
        self.update_rank_event = nil
    end

    if self.role_head then
        self.role_head:DeleteMe()
        self.role_head = nil
    end

    if self.rank_num then
        self.rank_num:DeleteMe()
        self.rank_num = nil
    end
    if self.scroll_view then
        self.scroll_view:DeleteMe()
        self.scroll_view = nil
    end
end


-- --------------------------------------------------------------------
-- @author: xhj@syg.com(必填, 创建模块的人员)
-- @description:
--      排行榜单元
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
PractisetowerRankItem = class("PractisetowerRankItem",function()
    return ccui.Layout:create()
end)

function PractisetowerRankItem:ctor()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("practisetower/practise_tower_rank_item"))
    self.size = self.root_wnd:getContentSize()
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setContentSize(self.size)

    self.root_wnd:setAnchorPoint(0.5, 0.5)
    self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
    self:addChild(self.root_wnd)

    local container = self.root_wnd:getChildByName("container")
    self.rank_img = container:getChildByName("rank_img")
    self.role_name = container:getChildByName("role_name")
    self.role_power = container:getChildByName("role_power")
    
    
    self.voide_btn = container:getChildByName("voide_btn")
    self.time_lab = container:getChildByName("time_lab")

    self.role_head = PlayerHead.new(PlayerHead.type.circle)
    self.role_head:setHeadLayerScale(0.95)
    self.role_head:setPosition(150, 65)
    container:addChild(self.role_head)
    self.role_head:setLev(99)

    self.container = container

    self:registerEvent()
end

function PractisetowerRankItem:registerEvent()
    self.role_head:addCallBack( function()
        if self.data ~= nil then
            local role_vo = RoleController:getInstance():getRoleVo()
            if role_vo and self.data.rid == role_vo.rid and self.data.srv_id == role_vo.srv_id  then 
                message(TI18N("这是你自己~"))
                return
            end
            FriendController:getInstance():openFriendCheckPanel(true, {srv_id = self.data.srv_id, rid = self.data.rid})
        end
    end,false)

    registerButtonEventListener(self.voide_btn, function()
        if self.data then
    		BattleController:getInstance():csRecordBattle(self.data.video_id,self.data.srv_id)
        end
	end,true)
end

function PractisetowerRankItem:addCallBack(call_back)
    self.call_back = call_back
end
function PractisetowerRankItem:setData(data)
    local role_vo = RoleController:getInstance():getRoleVo()
    if data and role_vo then
        self.data = data
        self.role_name:setString(data.name)
        self.role_power:setString(string.format(TI18N("通关层数：%d层"),data.val ))
    
        self.role_head:setHeadRes(data.face_id, false, LOADTEXT_TYPE, data.face_file, data.face_update_time)
        self.role_head:setLev(data.lev)
        local avatar_bid = data.avatar_bid 
        local vo = Config.AvatarData.data_avatar[avatar_bid]
        if vo then
            local res_id = vo.res_id or 1
            local res = PathTool.getTargetRes("headcircle", "txt_cn_headcircle_" .. res_id, false, false)
            self.role_head:showBg(res, nil, false, vo.offy)
        end

        if data.rank <= 3 then
            if self.rank_num ~= nil then
                self.rank_num:setVisible(false)
            end
            if data.rank == 0 then
                self.rank_img:setVisible(false)
            else
                local res_id = PathTool.getResFrame("common", string.format("common_200%s", data.rank))
                if self.rank_res_id ~= res_id then
                    self.rank_res_id = res_id
                    loadSpriteTexture(self.rank_img, res_id, LOADTEXT_TYPE_PLIST)
                end
                self.rank_img:setVisible(true)
            end
        else
            if self.rank_num == nil then
                self.rank_num = CommonNum.new(1, self.container, 1, -2, cc.p(0.5, 0.5))
                self.rank_num:setPosition(43, 80)
            end
            self.rank_num:setVisible(true)
            self.rank_num:setNum(data.rank)
            self.rank_img:setVisible(false)
        end

        self.time_lab:setString(string.format( "%s\n%s",TimeTool.getYMD(data.unixtime),TimeTool.getHM(data.unixtime) ))
    end
end

function PractisetowerRankItem:DeleteMe()

    if self.role_head then
        self.role_head:DeleteMe()
        self.role_head = nil
    end
    
    if self.rank_num ~= nil then
        self.rank_num:DeleteMe()
        self.rank_num = nil
    end
    self:removeAllChildren()
    self:removeFromParent()
end
