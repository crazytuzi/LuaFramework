-- --------------------------------------------------------------------
-- 竖版排行榜排行界面
-- 
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
RankWindow = RankWindow or BaseClass(BaseView)
local table_sort = table.sort
local elite_controller = ElitematchController:getInstance()
local elite_level_data = Config.ArenaEliteData.data_elite_level
function RankWindow:__init(index, is_cluster)
    self.is_cluster = is_cluster or false
    self.ctrl = RankController:getInstance()
    self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.layout_name = "rank/rank_window"
    self.cur_type = 0
    self.res_list = {}
    self.tab_info_list = {}
    self.first_list = {}
    self.click_index = index or 1
end

function RankWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end
    self.main_panel = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_panel, 1)
    self.close_btn = self.main_panel:getChildByName("close_btn")

    self.rank_panel = self.main_panel:getChildByName("rank_panel")
    self.my_rank = self.main_panel:getChildByName("my_rank")
    local title = self.my_rank:getChildByName("title")
    title:setString(TI18N("我的排名"))

    self.rank_index = self.my_rank:getChildByName("rank_id")
    self.four_label = createRichLabel(24, Config.ColorData.data_new_color4[6], cc.p(0.5, 0.5), cc.p(370, 35), 0, 0, 400)
    self.my_rank:addChild(self.four_label)
    self.my_rank_power = createLabel(24, Config.ColorData.data_new_color4[6], nil, 528, 60, "", self.my_rank, 0,
        cc.p(0.5, 0.5))

    local offx = 17
    local data_pos = RankConstant.DataPos[self.click_index]
    local head_x = data_pos[2] + offx
    local head_y = 74
    local name_x = data_pos[2] + offx
    local name_y = 22

    self.my_head = PlayerHead.new(PlayerHead.type.circle)
    self.my_head:setHeadLayerScale(0.8)
    self.my_head:setPosition(cc.p(head_x, head_y))
    self.my_rank:addChild(self.my_head)

    self.no_rank = createLabel(24, Config.ColorData.data_new_color4[6], nil, data_pos[1] + offx, 45, TI18N("未上榜"),
        self.my_rank, 0, cc.p(0.5, 0.5))
    self.my_name = createLabel(24, Config.ColorData.data_new_color4[6], nil, name_x, name_y, "", self.my_rank, 0,
        cc.p(0.5, 0.5))

    if self.click_index == RankConstant.RankType.elite then
        self.rank_index:setVisible(false)
        self.my_head:setVisible(false)
        self.my_name:setVisible(false)
        self.elite_lev = createSprite("", 220, 60, self.my_rank, cc.p(0.5, 0.5), LOADTEXT_TYPE)
        self.elite_lev:setVisible(false)
        local bg_res =
            PathTool.getPlistImgForDownLoad("elitematch/elitematch_icon", "elitemmatch_little_icon_01", false)
        if not self.elite_load then
            self.elite_load = loadSpriteTextureFromCDN(self.elite_lev, bg_res, ResourcesType.single, self.elite_load)
        end

        self.rank_score = createLabel(24, Config.ColorData.data_new_color4[6], nil, 333, 60, "", self.my_rank, 0,
            cc.p(0.5, 0.5))
        self.rank_score:setString("0")
        local btn = createButton(self.my_rank, TI18N('查看结算奖励'), 509, 60, cc.size(179, 54),
            PathTool.getResFrame('common', 'common_1018'), 26, cc.c4b(0x25, 0x55, 0x05, 0xff))
        btn:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                local lev = ElitematchController:getInstance():getModel():getEliteLev()
                local rank = ElitematchController:getInstance():getModel():getEliteRank()
                ElitematchController:getInstance():openElitematchRewardPanel(true, 3, lev, rank)
            end
        end)
    end

    local title = self.main_panel:getChildByName("title_label")
    if self.click_index == RankConstant.RankType.elite then
        local name = string.format(TI18N("S%d赛季"), elite_controller:getModel():getElitePeriod())
        title:setString(name)
    else
        local name = RankConstant.TitleName[self.click_index] or ""
        title:setString(name)
    end
    self.top_bg = self.main_panel:getChildByName("top_bg")
    -- self.top_bg:setScale(0.9)

    local res_id = PathTool.getPlistImgForDownLoad("bigbg/rank", "rank_2")
    if not self.item_load then
        self.item_load = createResourcesLoad(res_id, ResourcesType.single, function()
            if not tolua.isnull(self.top_bg) then
                loadSpriteTexture(self.top_bg, res_id, LOADTEXT_TYPE)
            end
        end, self.item_load)

    end
    self:updateTitle()
end

function RankWindow:register_event()
    self.background:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            self.ctrl:openRankView(false)
        end
    end)
    self.close_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            self.ctrl:openRankView(false)
        end
    end)
    if not self.update_data_event then
        self.update_data_event = GlobalEvent:getInstance():Bind(RankEvent.RankEvent_Get_Rank_data, function(data)
            self:updateRankList(data)
        end)
    end
    if not self.arnea_data_event then
        self.arnea_data_event = GlobalEvent:getInstance():Bind(ArenaEvent.UpdateLoopChallengeRank, function(data)
            self:updateRankList(data)
        end)
    end
    if not self.get_time_event then
        self.get_time_event = GlobalEvent:getInstance():Bind(RankEvent.RankEvent_Get_Time_event, function(data)
            if not data or not self.click_index then
                return
            end
            local index = self.click_index or RankConstant.RankType.drama
            if data.type and index ~= data.type then
                return
            end
            local info = SysEnv:getInstance():loadRankFile(index, self.is_cluster)
            if not info or next(info) == nil then
                self:senProto(index)
            else
                if data.time and info.data and data.type and (data.time == 0 or data.time == info.timestamp) and index ==
                    data.type then
                    self:updateRankList(info.data)
                else
                    self:senProto(index)
                end
            end
        end)
    end

end

function RankWindow:openRootWnd()
    if self.click_index == RankConstant.RankType.fans then -- 粉丝排行榜
        local role_model = RoleController:getInstance():getModel()
        if role_model and role_model.fans_rank_data then
            self:updateRankList(role_model.fans_rank_data)
        end
    else
        self.ctrl:send_12901(self.click_index, self.is_cluster)
    end
end

function RankWindow:setPanelData()
end
-- 更新标题
function RankWindow:updateTitle()
    local title_list = RankConstant.RankTitle[self.click_index] or {}
    local num = #title_list or 0
    local pos_list = RankConstant.TitlePos[self.click_index] or {}
    local line_pos_list = RankConstant.TitleLinePos[self.click_index] or {}
    print("index:::::" .. self.click_index)
    for i = 1, num do
        -- if i ~= num then
        --     local res = PathTool.getResFrame("common","common_1069")   
        --     local line_offx = line_pos_list[i] or 0
        --     local line = createImage(self.main_panel, res,line_offx,636, cc.p(0,0.5), true, 1, false)
        --     line:setScaleY(0.8)
        -- end
        local offx = pos_list[i] or 0
        -- local label = createLabel(24,Config.ColorData.data_new_color4[6],nil,offx,693,"",self.main_panel,0, cc.p(0,0.5))
        local code = cc.Application:getInstance():getCurrentLanguageCode()
        local fontsize = 22
        -- local fontsize = 24
        -- if (self.click_index == RankConstant.RankType.union) and (code ~= "zh") then
        --     fontsize = 22
        -- end
        print("iiiiiiii:::" .. i .. " title>>>>>" .. title_list[i])
        local label = createLabel(fontsize, Config.ColorData.data_new_color4[6], nil, offx, 693, "", self.main_panel, 0,
            cc.p(0, 0.5))
        local str = title_list[i] or ""
        label:setString(str)
    end
end

function RankWindow:updateRankList(data)
    if self.click_index == RankConstant.RankType.elite then
        return
    end
    self.data = data
    self:updateMyData()
    self:updateRankData()
    if not self.list_view then
        local scroll_view_size = cc.size(604, 510) -- 488)
        local setting = {
            -- item_class = RankItem,      -- 单元类
            start_x = 17, -- 第一个单元的X起点
            space_x = 5, -- x方向的间隔
            start_y = 11, -- 第一个单元的Y起点
            space_y = 6, -- y方向的间隔
            item_width = 570, -- 单元的尺寸width
            item_height = 114, -- 单元的尺寸height
            row = 1, -- 行数，作用于水平滚动类型
            col = 1, -- 列数，作用于垂直滚动类型
            need_dynamic = true
        }
        self.list_view = CommonScrollViewSingleLayout.new(self.rank_panel, cc.p(0, 6), ScrollViewDir.vertical,
            ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0, 0))

        self.list_view:registerScriptHandlerSingle(handler(self, self.createNewCell), ScrollViewFuncType.CreateNewCell) -- 创建cell
        self.list_view:registerScriptHandlerSingle(handler(self, self.numberOfCells), ScrollViewFuncType.NumberOfCells) -- 获取数量
        self.list_view:registerScriptHandlerSingle(handler(self, self.updateCellByIndex),
            ScrollViewFuncType.UpdateCellByIndex) -- 更新cell
        -- self.list_view:registerScriptHandlerSingle(handler(self,self.onCellTouched), ScrollViewFuncType.OnCellTouched) --更新cell
    end
    if not data or next(data) == nil then
        self:senProto(self.click_index)
        return
    end

    self.show_list = data.rank_list or {}
    self.list_view:reloadData()

    if #self.show_list == 0 then
        self:showEmptyIcon(true)
    else
        self:showEmptyIcon(false)
    end
end
-- 创建cell 
-- @width 是setting.item_width
-- @height 是setting.item_height
function RankWindow:createNewCell(width, height)
    local cell = RankItem.new(1)
    cell:setExtendData({
        rank_type = self.click_index,
        is_cluster = self.is_cluster
    })
    return cell
end
-- 获取数据数量
function RankWindow:numberOfCells()
    if not self.show_list then
        return 0
    end
    return #self.show_list
end

-- 更新cell(拖动的时候.刷新数据时候会执行次方法)
-- cell :createNewCell的返回的对象
-- index :数据的索引
function RankWindow:updateCellByIndex(cell, index)
    cell.index = index
    local data = self.show_list[index]
    if data then
        cell:setData(data, index)
    end
end

-- --点击cell .需要在 createNewCell 设置点击事件
-- function RankWindow:onCellTouched(cell)
--     local index = cell.index
--     local data = self.show_list[index]
-- end

-- 显示空白
function RankWindow:showEmptyIcon(bool)
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
        local res = PathTool.getPlistImgForDownLoad("bigbg", "bigbg_3")
        local bg = createImage(self.empty_con, res, size.width / 2, size.height / 2, cc.p(0.5, 0.5), false)
        self.empty_label = createLabel(26, Config.ColorData.data_new_color4[6], nil, size.width / 2, -10, "",
            self.empty_con, 0, cc.p(0.5, 0))
    end
    local str = TI18N("当前排行榜暂无数据")
    self.empty_label:setString(str)
    self.empty_con:setVisible(bool)
end

function RankWindow:senProto(index)
    if index == RankConstant.RankType.union then
        self.ctrl:send_12903(self.is_cluster)
    elseif index == RankConstant.RankType.arena then
        ArenaController:getInstance():requestLoopChalllengeRank()
    elseif index == RankConstant.RankType.action_partner then
        self.ctrl:send_12904(0, 100)
    else
        self.ctrl:send_12900(index, nil, nil, self.is_cluster)
    end
end

-- 更新自己数据
function RankWindow:updateMyData()
    if not self.data then
        return
    end
    local data = self.data
    local str = TI18N("0")
    local my_idx = data.my_idx or data.rank or 0
    if my_idx and my_idx > 0 then
        str = my_idx
    end

    local data_pos = RankConstant.DataPos[self.click_index]
    local offx = 20
    local datay = 53

    self.no_rank:setVisible(false)
    local role_vo = RoleController:getInstance():getRoleVo()
    self.rank_index:setString(str)
    if my_idx and my_idx >= 1 and my_idx <= 3 then
        self.rank_index:setVisible(false)
        if not self.my_rank_icon then
            self.my_rank_icon = createImage(self.my_rank, nil, 43, 26, cc.p(0, 0), true, 1, false)
        end
        self.my_rank_icon:setVisible(true)
        self.my_rank_icon:loadTexture(PathTool.getResFrame("common", RankConstant.RankIconRes[my_idx]),
            LOADTEXT_TYPE_PLIST)
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
    local name = role_vo.name or ""
    self.my_name:setString(name)
    local avatar_bid = data.avatar_bid
    local vo = Config.AvatarData.data_avatar[avatar_bid]
    if vo then
        local res_id = vo.res_id or 1
        local res = PathTool.getTargetRes("headcircle", "txt_cn_headcircle_" .. res_id, false, false)
        self.my_head:showBg(res, nil, false, vo.offy)
    end

    local str = ""
    -- self.my_rank_power:setPositionX(528)
    self.four_label:setVisible(true)
    if self.rune_item then
        self.rune_item:setVisible(false)
    end
    self.my_rank_power:setString("")
    -- self.four_label:setPosition(cc.p(485,50))
    self.four_label:setPosition(cc.p(data_pos[3] + offx, datay))
    if data_pos[4] ~= nil then
        self.my_rank_power:setPosition(cc.p(data_pos[4] + offx, datay))
    end
    if self.click_index == RankConstant.RankType.power or self.click_index == RankConstant.RankType.action_power then
        -- self.my_rank_power:setString(data.power)
        -- local res = PathTool.getResFrame("common","common_90002")
        -- local power = data.my_val1 or 0
        -- str = string.format( "<img src='%s' /> %s",res,power)
        str = data.my_val1 or 0
    elseif self.click_index == RankConstant.RankType.drama or self.click_index == RankConstant.RankType.action_drama then
        local config = Config.DungeonData.data_drama_dungeon_info(data.my_val1)
        if config then
            str = config.name
        end
    elseif self.click_index == RankConstant.RankType.union then
        str = string.format(TI18N("<div fontsize=20 fontcolor=%s>会长：%s</div>"),
            Config.ColorData.data_new_color_str[6], data.leader_name)
        if role_vo.gid == 0 then
            str = TI18N("暂无公会")
        end
        self.my_name:setString(role_vo.gname)
        self.my_name:setPosition(cc.p(215, 82))
        self.my_head:setVisible(false)
        self.four_label:setPosition(cc.p(215, datay))
        local power = data.power or 0
        if power <= 0 then
            self.my_rank_power:setString("")
        else
            self.my_rank_power:setString(power)
        end
        self.my_rank_power:setPositionX(data_pos[5] + offx)
    elseif self.click_index == RankConstant.RankType.voyage then
        local val1_str = (data.my_val1 ~= 0) and data.my_val1 or ""
        self.my_rank_power:setString(val1_str)
        self.my_rank_power:setPositionX(data_pos[3] + offx)
    elseif self.click_index == RankConstant.RankType.tower or self.click_index == RankConstant.RankType.action_tower then
        local num = data.my_val2 or 0
        local tim = TimeTool.GetTimeMS(num, true)
        if data.my_val1 and data.my_val1 == 0 then
            tim = ""
            self.four_label:setVisible(false)
        end
        self.my_rank_power:setString(tim)
        str = data.my_val1 or ""
        -- self.four_label:setPosition(cc.p(data_pos[3]+offx,datay))
        -- self.my_rank_power:setPosition(cc.p(data_pos[4]+offx,datay))
    elseif self.click_index == RankConstant.RankType.adventure then
        str = data.my_val1 or 0
        local val2_str = (data.my_val2 ~= 0) and data.my_val2 or ""
        self.my_rank_power:setString(val2_str)
        -- self.four_label:setPosition(cc.p(430,datay))
        -- self.my_rank_power:setPosition(cc.p(540,datay))
    elseif self.click_index == RankConstant.RankType.arena or self.click_index == RankConstant.RankType.action_arena then
        -- local res = PathTool.getItemRes("8")
        -- local score = self.data.score or self.data.my_val1 or 0
        -- str = string.format( "<img src='%s' scale=0.35 /> %s",res,score)
        str = self.data.score or self.data.my_val1 or 0
    elseif self.click_index == RankConstant.RankType.action_adventure then
        local res = PathTool.getResFrame("common", "common_90002")
        local power = data.my_val1 or 0
        str = power
    elseif self.click_index == RankConstant.RankType.hallows_power or self.click_index == RankConstant.RankType.treasure then
        local res = PathTool.getResFrame("common", "common_90002")
        local power = data.my_val1 or 0
        str = power
    elseif self.click_index == RankConstant.RankType.action_partner then
        local res = PathTool.getResFrame("common", "common_90002")
        local power = data.power or 0
        str = power
        if power > 0 then
            if not self.hero_item then
                self.hero_item = HeroExhibitionItem.new(0.8, true)
                self.hero_item:setPosition(cc.p(410, 60))
                self.my_rank:addChild(self.hero_item)
                self.hero_item:addCallBack(function(item)
                    local vo = item:getData()
                    if vo and next(vo) ~= nil then
                        local role_vo = RoleController:getInstance():getRoleVo()
                        LookController:sender11061(role_vo.rid, role_vo.srv_id, vo.partner_id)
                    end
                end)
            end
            local vo = self:createPartnerVo()
            self.hero_item:setData(vo)
        end
        self.four_label:setPosition(cc.p(525, datay))
    elseif self.click_index == RankConstant.RankType.action_star or self.click_index == RankConstant.RankType.star_power then
        local res = PathTool.getResFrame("common", "common_90002")
        local power = data.my_val1 or 0
        str = power
        self.four_label:setPosition(cc.p(525, datay))
    elseif self.click_index == RankConstant.RankType.elite then
        self.elite_lev:setVisible(true)
        self.rank_score:setString(self.data.score or 0)
        local lev = self.data.elite_lev or 1
        local bg_res = PathTool.getPlistImgForDownLoad("elitematch/elitematch_icon", elite_level_data[lev].little_ico,
            false)
        if self.elite_load then
            loadSpriteTexture(self.elite_lev, bg_res, LOADTEXT_TYPE)
        end
    elseif self.click_index == RankConstant.RankType.ladder then
        -- local res = PathTool.getResFrame("common","common_90002")
        -- local power = data.my_val1 or 0
        -- str = string.format( "<img src='%s' /> %s",res,power)
        str = data.my_val1 or 0
        if self.guild_name == nil then
            self.guild_name = createLabel(24, Config.ColorData.data_new_color4[6], nil, data_pos[4] + offx, 53, "",
                self.my_rank, 0, cc.p(0.5, 0.5))
        end

        local guild_str
        if role_vo.gid == 0 then
            guild_str = TI18N("暂未加入公会")
        else
            guild_str = role_vo.gname
        end
        self.guild_name:setString(guild_str)
        self.my_name:setPosition(data_pos[2] + offx, 24)
        -- self.four_label:setPosition(data_pos[3]+offx, 50)
    elseif self.click_index == RankConstant.RankType.fans then
        str = role_vo.fans_num
    elseif self.click_index == RankConstant.RankType.planes_rank or self.click_index == RankConstant.RankType.sweet then
        str = self.data.my_val1 or 0
        -- self.my_name:setAnchorPoint(cc.p(0, 0.5))
        self.my_name:setPositionX(data_pos[2]+offx)
        self.four_label:setPosition(445, 58)
    end
    if str == 0 then
        str = ""
    end
    self.four_label:setString(str)
end
-- 创建一个宝可梦数据
function RankWindow:createPartnerVo()
    local vo = HeroVo.New()
    local data = {
        partner_id = self.data.pid,
        bid = self.data.pbid,
        lev = self.data.plev,
        star = self.data.pstar
    }
    vo:updateHeroVo(data)
    return vo
end
-- 更新前三名头像
function RankWindow:updateRankData()
    if not self.data then
        return
    end
    local rank_list
    if self.click_index == RankConstant.RankType.elite then
        rank_list = self.data.arena_elite_rank or {}
    else
        rank_list = self.data.rank_list or {}
    end
    local count = 0
    local size = self.main_panel:getContentSize()

    for i = 1, 3 do
        self.first_list[i] = self.first_list[i] or {}

        if self.first_list[i].role_spine then
            self.first_list[i].role_spine:DeleteMe()
            self.first_list[i].role_spine = nil
        end

        local pos_x = size.width / 2
        local pos_y = 883
        local off_y = 0
        if i == 2 then
            pos_x = size.width / 2 - 156
            pos_y = 870
            off_y = 4
        elseif i == 3 then
            pos_x = size.width / 2 + 156
            pos_y = 870
            off_y = 4
        end
        -- 名称
        if not self.first_list[i].name_txt then
            local font_size = 22
            if i == 1 then
                font_size = 24
            end
            self.first_list[i].name_txt = createLabel(font_size, Config.ColorData.data_new_color4[11], nil, pos_x,
                752 - off_y, TI18N("虚位以待"), self.main_panel, 2, cc.p(0.5, 0.5))
            self.first_list[i].name_txt:setLocalZOrder(1)
        end
        -- 排名
        if not self.first_list[i].title_sp then
            self.first_list[i].title_sp = createSprite(PathTool.getResFrame("common", RankConstant.RankIconRes[i]),
                pos_x + 70, pos_y - 80, self.main_panel, cc.p(0.5, 0.5))
            self.first_list[i].title_sp:setScale(0.6)
            self.first_list[i].title_sp:setLocalZOrder(1)
        end
    end

    for i, v in ipairs(rank_list) do
        local idx = v.idx or v.rank
        if idx > 0 and idx <= 3 then
            count = count + 1
            -- 形象id
            local look_id = v.look_id or v.lookid or v.leader_look_id or 110101
            if look_id == 0 then
                look_id = 110101
            end -- 新增的字段，后端可能发0过来

            -- 模型
            local width = size.width / 2
            local height = 813
            if idx == 2 then
                width = size.width / 2 - 156
                height = 810
            elseif idx == 3 then
                width = size.width / 2 + 156
                height = 810
            end
            -- local role_spine = BaseRole.new(BaseRole.type.role, look_id)
            -- role_spine:setScale(0.8)
            -- role_spine:setCascade(true)
            -- role_spine:setAnchorPoint(cc.p(0.5, 0))
            -- role_spine:setAnimation(0,PlayerAction.show,true)
            -- self.main_panel:addChild(role_spine)
            -- role_spine:setPosition(width, height-40)
            -- self.first_list[idx].role_spine = role_spine
            local role_spine = PlayerHead.new(PlayerHead.type.circle)
            local scale = 1
            if i == 1 then
                scale = 1.1
            end
            role_spine:setScale(scale)
            role_spine:setAnchorPoint(cc.p(0.5, 0))
            self.main_panel:addChild(role_spine)
            role_spine:setPosition(width, height - 40)
            self.first_list[idx].role_spine = role_spine

            local face_id = v.face_id or v.face or v.leader_face or 10401
            if face_id == 0 then
                face_id = 10401
            end -- 新增的字段，后端可能发0过来

            local avatar_bid = v.avatar_bid or v.leader_avatar_bid
            local vo = Config.AvatarData.data_avatar[avatar_bid]
            if vo then
                local res_id = vo.res_id or 1
                local res = PathTool.getTargetRes("headcircle", "txt_cn_headcircle_" .. res_id, false, false)
                role_spine:showBg(res, nil, false, vo.offy)
            end

            role_spine:setHeadRes(face_id, false, LOADTEXT_TYPE, v.face_file, v.face_update_time)
            -- 名称
            if self.first_list[idx].name_txt then
                self.first_list[idx].name_txt:setString(v.name or "")
            end
            -- 点击区域
            if not self.first_list[idx].touch_layer then
                local touch_layer = ccui.Layout:create()
                touch_layer:setAnchorPoint(cc.p(0.5, 0))
                touch_layer:setContentSize(cc.size(140, 160))
                touch_layer:setPosition(width, height - 80)
                touch_layer:setTouchEnabled(true)
                self.main_panel:addChild(touch_layer)
                self.first_list[idx].touch_layer = touch_layer
            end
            self.first_list[idx].touch_layer:addTouchEventListener(function(sender, event)
                if ccui.TouchEventType.ended == event and v then
                    local touchPos = cc.p(sender:getTouchEndPosition().x + 320, sender:getTouchEndPosition().y)
                    local rid = v.rid or v.leader_rid or 0
                    local srv_id = v.srv_id or v.leader_srvid or 0
                    self.ctrl:openChatMessage(rid, srv_id, nil, touchPos)
                end
            end)
        end
        if count >= 3 then
            break
        end
    end
end
function RankWindow:onEnterAnim()
end
function RankWindow:close_callback()
    if self.data and self.data.time and self.data.time ~= 0 then
        SysEnv:getInstance():saveRankFile(self.click_index, self.data.time, self.data, self.is_cluster)
    end
    self.ctrl:openRankView(false)
    if self.update_data_event then
        GlobalEvent:getInstance():UnBind(self.update_data_event)
        self.update_data_event = nil
    end
    if self.arnea_data_event then
        GlobalEvent:getInstance():UnBind(self.arnea_data_event)
        self.arnea_data_event = nil
    end
    if self.get_time_event then
        GlobalEvent:getInstance():UnBind(self.get_time_event)
        self.get_time_event = nil
    end
    for i, v in pairs(self.first_list) do
        if v.role_spine then
            v.role_spine:DeleteMe()
            v.role_spine = nil
        end
    end
    self.first_list = {}
    if self.list_view then
        self.list_view:DeleteMe()
    end
    self.list_view = nil

    if self.elite_list_view then
        self.elite_list_view:DeleteMe()
    end
    self.elite_list_view = nil

    if self.item_load then
        self.item_load:DeleteMe()
    end
    if self.hero_item then
        self.hero_item:DeleteMe()
    end
    self.hero_item = nil
    self.item_load = nil
    if self.elite_load then
        self.elite_load:DeleteMe()
    end
    self.elite_load = nil
end
