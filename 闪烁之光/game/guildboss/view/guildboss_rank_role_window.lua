-- --------------------------------------------------------------------
-- 
-- 
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--     个人伤害排行版数据
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
GuildBossRankRoleWindow = GuildBossRankRoleWindow or BaseClass(BaseView)
local table_sort = table.sort
function GuildBossRankRoleWindow:__init()
    self.ctrl = GuildbossController:getInstance()
    self.is_full_screen = true
    self.win_type = WinType.Full
    self.layout_name = 'rank/rank_window'
    self.cur_type = 0
    self.res_list = {}
    self.tab_info_list = {}
    self.title_str = TI18N('伤害排行')
    self.first_list = {}
    self.click_index = RankConstant.RankType.union_boss
end

function GuildBossRankRoleWindow:open_callback()
    self.background = self.root_wnd:getChildByName('background')
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end
    self.main_panel = self.root_wnd:getChildByName('main_container')
    self:playEnterAnimatianByObj(self.main_panel, 1)
    self.close_btn = self.main_panel:getChildByName('close_btn')

    self.rank_panel = self.main_panel:getChildByName('rank_panel')
    self.my_rank = self.main_panel:getChildByName('my_rank')
    local title = self.my_rank:getChildByName('title')
    title:setString(TI18N('我的排名'))

    self.rank_index = self.my_rank:getChildByName('rank_id')
    self.four_label = createRichLabel(24, Config.ColorData.data_color4[175], cc.p(0.5, 0.5), cc.p(360, 35), 0, 0, 500)
    self.my_rank:addChild(self.four_label)
    self.my_rank_power = createLabel(24, Config.ColorData.data_color4[175], nil, 518, 35, '', self.my_rank, 0, cc.p(0.5, 0.5))

    self.my_head = PlayerHead.new(PlayerHead.type.circle)
    self.my_head:setHeadLayerScale(0.9)
    self.my_head:setPosition(150, 60)
    self.my_rank:addChild(self.my_head)

    self.no_rank = createLabel(24, Config.ColorData.data_color4[175], nil, 52, 45, TI18N('未上榜'), self.my_rank, 0, cc.p(0.5, 0.5))
    self.my_name = createLabel(24, Config.ColorData.data_color4[175], nil, 275, 56, '', self.my_rank, 0, cc.p(0.5, 0.5))

    self.title_con = self.main_panel:getChildByName('title_con')
    local title = self.title_con:getChildByName('title_label')
    local name = RankConstant.TitleName[self.click_index] or ''
    title:setString(name)

    self.top_bg = self.main_panel:getChildByName('top_bg')

    local res_id = PathTool.getPlistImgForDownLoad('bigbg/rank', 'rank_2')
    if not self.item_load then
        self.item_load = createResourcesLoad(res_id, ResourcesType.single,function()
            if not tolua.isnull(self.top_bg) then
                loadSpriteTexture(self.top_bg, res_id, LOADTEXT_TYPE)
            end
        end, self.item_load)
    end
    self:updateTitle()
end

function GuildBossRankRoleWindow:register_event()
    self.background:addTouchEventListener(
        function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playCloseSound()
                self.ctrl:openGuildbossRankRoleWindow(false)
            end
        end
    )
    self.close_btn:addTouchEventListener(
        function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playCloseSound()
                self.ctrl:openGuildbossRankRoleWindow(false)
            end
        end
    )
	if self.update_data_event == nil then
		self.update_data_event = GlobalEvent:getInstance():Bind(GuildbossEvent.UpdateGuildDunRank, function(data, index)
			if index == GuildBossConst.rank.role then
				self:updateRankList(data)
			end
		end)
	end 

    if self.update_worship_event == nil then
        self.update_worship_event = GlobalEvent:getInstance():Bind(RoleEvent.WorshipOtherRole, function(rid, srv_id, idx)
            if idx ~= nil and self.select_item ~= nil and self.select_item.data ~= nil then
                if idx == self.select_item.data.rank then
                    self.select_item:updateWorshipStatus()
                end
            end
        end)
    end
   
end

function GuildBossRankRoleWindow:openRootWnd(data)
    self.data = data
    if self.data then
        local protocal = {boss_id = self.data.boss_id, start_num = 1, end_num = 100}
        GuildbossController:getInstance():requestGuildDunRank(GuildBossConst.rank.role,protocal)
    end
end
--更新标题
function GuildBossRankRoleWindow:updateTitle()
    local title_list = RankConstant.RankTitle[self.click_index] or {}
    local num = #title_list or 0
    local pos_list = RankConstant.TitlePos[self.click_index] or {}
    local line_pos_list = RankConstant.TitleLinePos[self.click_index] or {}
    for i = 1, num do
        if i ~= num then
            local res = PathTool.getResFrame('common', 'common_1069')
            local line_offx = line_pos_list[i] or 0
            local line = createImage(self.main_panel, res, line_offx, 636, cc.p(0, 0.5), true, 1, false)
            line:setScaleY(0.8)
        end
        local offx = pos_list[i] or 0
        local label = createLabel(24, Config.ColorData.data_color4[175], nil, offx, 636, '', self.main_panel, 0, cc.p(0, 0.5))
        local str = title_list[i] or ''
        label:setString(str)
    end
end

function GuildBossRankRoleWindow:updateRankList(data)
    self.rank_data = data
    self:updateMyData()
    self:updateRankData()
    if not self.list_view then
        local scroll_view_size = cc.size(640, 430)
        local setting = {
            -- item_class = RankItem,      -- 单元类
            start_x = 0,                  -- 第一个单元的X起点
            space_x = 5,                    -- x方向的间隔
            start_y = 0,                    -- 第一个单元的Y起点
            space_y = 6,                   -- y方向的间隔
            item_width = 630,               -- 单元的尺寸width
            item_height = 120,              -- 单元的尺寸height
            row = 1,                        -- 行数，作用于水平滚动类型
            col = 1,                         -- 列数，作用于垂直滚动类型
            need_dynamic = true
        }
        self.list_view = CommonScrollViewSingleLayout.new(self.main_panel, cc.p(45, 170) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0,0))

        self.list_view:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.list_view:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.list_view:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
        -- self.list_view:registerScriptHandlerSingle(handler(self,self.onCellTouched), ScrollViewFuncType.OnCellTouched) --更新cell
    end

    -- local list = {}
    -- if not data or next(data) == nil then
    --     self:senProto(self.click_index)
    --     return
    -- end
    self.show_list = data.rank_list or {}
    self:showEmptyIcon(false)
    if #self.show_list <= 0 then
        self:showEmptyIcon(true)
    end
 
    self.list_view:reloadData()

end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function GuildBossRankRoleWindow:createNewCell(width, height)
    local cell = RankItem.new(1)
    cell:setExtendData({rank_type = RankConstant.RankType.union_boss})
    cell:addCallBack(function() self:worshipOtherRole(cell) end)
    return cell
end
--获取数据数量
function GuildBossRankRoleWindow:numberOfCells()
    if not self.show_list then return 0 end
    return #self.show_list
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function GuildBossRankRoleWindow:updateCellByIndex(cell, index)
    cell.index = index
    local data = self.show_list[index]
    if data then
        cell:setData(data, index)
    end
end


function GuildBossRankRoleWindow:worshipOtherRole(item)
    if item.data ~= nil then
        self.select_item = item
    end
end

--显示空白
function GuildBossRankRoleWindow:showEmptyIcon(bool)
    if not self.empty_con and bool == false then
        return
    end
    local main_size = self.main_panel:getContentSize()
    if not self.empty_con then
        local size = cc.size(200, 200)
        self.empty_con = ccui.Widget:create()
        self.empty_con:setContentSize(size)
        self.empty_con:setAnchorPoint(cc.p(0.5, 0))
        self.empty_con:setPosition(cc.p(main_size.width / 2, 330))
        self.main_panel:addChild(self.empty_con, 10)
        local res = PathTool.getPlistImgForDownLoad('bigbg', 'bigbg_3')
        local bg = createImage(self.empty_con, res, size.width / 2, size.height / 2, cc.p(0.5, 0.5), false)
        self.empty_label = createLabel(26, Config.ColorData.data_color4[175], nil, size.width / 2, -10, '', self.empty_con, 0, cc.p(0.5, 0))
    end
    local str = TI18N('当前排行榜暂无数据')
    self.empty_label:setString(str)
    self.empty_con:setVisible(bool)
end
--更新自己数据
function GuildBossRankRoleWindow:updateMyData()
    if not self.rank_data then
        return
    end
    local data = self.rank_data
    local str = TI18N('0')
    local my_idx = data.rank or 0
    if my_idx and my_idx > 0 then
        str = my_idx
    end
    self.no_rank:setVisible(false)
    local role_vo = RoleController:getInstance():getRoleVo()
    self.rank_index:setString(str)
    if my_idx and my_idx >= 1 and my_idx <= 3 then
        self.rank_index:setVisible(false)
        if not self.my_rank_icon then
            self.my_rank_icon = createImage(self.my_rank, nil, 33, 26, cc.p(0, 0), true, 1, false)
        end
        self.my_rank_icon:setVisible(true)
        self.my_rank_icon:loadTexture(PathTool.getResFrame('common', 'common_300' .. my_idx), LOADTEXT_TYPE_PLIST)
        self.my_rank_icon:setScale(0.7)
    else
        if my_idx <= 0 then
            self.no_rank:setVisible(true)
            self.rank_index:setVisible(false)
        else
            self.rank_index:setVisible(true)
            if self.my_rank_icon then
                self.my_rank_icon:setVisible(false)
            end
        end
    end
    self.my_head:setHeadRes(role_vo.face_id, false, LOADTEXT_TYPE, role_vo.face_file, role_vo.face_update_time)
    local name = role_vo.name or ''
    self.my_name:setString(name)
    self.four_label:setPositionX(555)
    self.four_label:setVisible(true)
    self.four_label:setPosition(cc.p(485, 50))
    self.four_label:setString(data.mydps)
end

--更新前三名头像
function GuildBossRankRoleWindow:updateRankData()
    if not self.rank_data then
        return
    end
    local rank_list = self.rank_data.rank_list or {}

    local count = 0
    local size = self.main_panel:getContentSize()
    for i = 1, 3 do
        self.first_list[i] = self.first_list[i] or {}

        if self.first_list[i].role_spine then
            self.first_list[i].role_spine:DeleteMe()
            self.first_list[i].role_spine = nil
        end

        local pos_x = size.width/2
        local pos_y = 883
        local off_y = 0
        if i ==2 then 
            pos_x = size.width/2-226
            pos_y = 870
            off_y = 6
        elseif i ==3 then 
            pos_x = size.width/2+234
            pos_y = 870
            off_y = 6
        end
        -- 名称
        if not self.first_list[i].name_txt then
            self.first_list[i].name_txt = createLabel(24,Config.ColorData.data_color4[1], 2,pos_x, 712 - off_y,TI18N("虚位以待"),self.main_panel,2, cc.p(0.5,0.5))
            self.first_list[i].name_txt:setLocalZOrder(1)
        end
         -- 排名
        if not self.first_list[i].title_sp then
            self.first_list[i].title_sp = createSprite(PathTool.getResFrame("common","common_300"..i), pos_x, pos_y+60, self.main_panel, cc.p(0.5,0.5))
            self.first_list[i].title_sp:setScale(0.7)
            self.first_list[i].title_sp:setLocalZOrder(1)
        end
    end

    for i,v in ipairs(rank_list) do
        local idx = v.idx or v.rank 
        if idx > 0 and idx <=3 then 
            count = count+1
            -- 形象id
            local look_id = v.look_id or v.lookid or v.leader_look_id or 110101
            if look_id == 0 then look_id = 110101 end --新增的字段，后端可能发0过来

            -- 模型
            local width = size.width/2
            local height = 873
            if idx ==2 then 
                width = size.width/2-226
                height = 860
            elseif idx ==3 then 
                width = size.width/2+234
                height = 860
            end
            local role_spine = BaseRole.new(BaseRole.type.role, look_id)
            role_spine:setScale(0.8)
            role_spine:setCascade(true)
            role_spine:setAnchorPoint(cc.p(0.5, 0))
            role_spine:setAnimation(0,PlayerAction.show,true)
            self.main_panel:addChild(role_spine)
            role_spine:setPosition(width, height-40)
            self.first_list[idx].role_spine = role_spine
            -- 名称
            if self.first_list[idx].name_txt then
                self.first_list[idx].name_txt:setString(v.name or "") 
            end
            -- 点击区域
            if not self.first_list[idx].touch_layer then
                local touch_layer = ccui.Layout:create()
                touch_layer:setAnchorPoint(cc.p(0.5, 0))
                touch_layer:setContentSize(cc.size(160, 260))
                touch_layer:setPosition(width, height-173)
                touch_layer:setTouchEnabled(true)
                self.main_panel:addChild(touch_layer)
                self.first_list[idx].touch_layer = touch_layer
            end
            self.first_list[idx].touch_layer:addTouchEventListener(function(sender, event)
                if ccui.TouchEventType.ended == event and v then
                    local roleVo = RoleController:getInstance():getRoleVo()
                    local touchPos = cc.p(sender:getTouchEndPosition().x + 320, sender:getTouchEndPosition().y)
                    local rid = v.r_rid or 0
                    local srv_id = v.r_srvid or ""
                    if roleVo.rid == rid and roleVo.srv_id == srv_id then
                        return
                    end
                    local vo = {rid = rid, srv_id = srv_id}
                    ChatController:getInstance():openFriendInfo(vo, touchPos)
                end
            end)
        end
        if count >=3 then 
            break
        end
    end
end

function GuildBossRankRoleWindow:close_callback()
    if self.rank_data and self.rank_data.time and self.rank_data.time ~= 0 then
        SysEnv:getInstance():saveRankFile(self.click_index, self.rank_data.time, self.rank_data, false)
    end
    self.ctrl:openGuildbossRankRoleWindow(false)
    if self.update_data_event then
        GlobalEvent:getInstance():UnBind(self.update_data_event)
        self.update_data_event = nil
    end
    if self.update_worship_event then
        GlobalEvent:getInstance():UnBind(self.update_worship_event)
        self.update_worship_event = nil
    end

    for i,v in pairs(self.first_list) do
        if v.role_spine then
            v.role_spine:DeleteMe()
            v.role_spine = nil
        end
    end
    self.first_list = nil
    if self.list_view then
        self.list_view:DeleteMe()
    end
    self.list_view = nil
    if self.item_load then
        self.item_load:DeleteMe()
    end
    self.item_load = nil
end
