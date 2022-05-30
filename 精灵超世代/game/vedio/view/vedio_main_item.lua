--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-01-24 17:27:48
-- @description    : 
        -- 录像 item
---------------------------------
VedioMainItem = class("VedioMainItem", function()
    return ccui.Widget:create()
end)

local _table_insert = table.insert
local _controller = VedioController:getInstance()
local _model = _controller:getModel()
local _string_format = string.format

function VedioMainItem:ctor(is_share)
    self.is_share = is_share or false -- 是否为聊天中点开的录像详情
    self:configUI()
    self:register_event()
end

function VedioMainItem:configUI(  )
    self.size = cc.size(680, 500)
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setContentSize(self.size)

    local csbPath = PathTool.getTargetCSB("vedio/vedio_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    self.container = self.root_wnd:getChildByName("container")

    local image_panel = self.container:getChildByName("image_panel")
    self.image_panel = image_panel
    self.image_atk_left = image_panel:getChildByName("image_atk_left")
    self.image_atk_right = image_panel:getChildByName("image_atk_right")
    self.image_rank_left = image_panel:getChildByName("image_rank_left")
    self.image_rank_right = image_panel:getChildByName("image_rank_right")

    self.result_win = image_panel:getChildByName("result_win")
    self.result_loss = image_panel:getChildByName("result_loss")

    self.name_left = self.container:getChildByName("name_left")
    self.name_right = self.container:getChildByName("name_right")
    self.tree_lv_left = self.container:getChildByName("tree_lv_left")
    self.tree_lv_right = self.container:getChildByName("tree_lv_right")
    self.challenge_left = self.container:getChildByName("challenge_left")
    self.challenge_right = self.container:getChildByName("challenge_right")
    self.atk_label_left = self.container:getChildByName("atk_label_left")
    self.atk_label_right = self.container:getChildByName("atk_label_right")
    self.rank_label_left = self.container:getChildByName("rank_label_left")
    self.rank_label_right = self.container:getChildByName("rank_label_right")
    self.rank_title_left = self.container:getChildByName("rank_title_left")
    self.rank_title_right = self.container:getChildByName("rank_title_right")
    self.rank_title_left:setString(TI18N("排行"))
    self.rank_title_right:setString(TI18N("排行"))
    
    self.round_txt = self.container:getChildByName("round_txt")
    self.type_txt = self.container:getChildByName("type_txt")
    self.time_txt = self.container:getChildByName("time_txt")
    self.level_left = self.container:getChildByName("level_left")
    self.level_right = self.container:getChildByName("level_right")

    self.play_btn = image_panel:getChildByName("play_btn")
    self.share_btn = image_panel:getChildByName("share_btn")
    self.info_btn = image_panel:getChildByName("info_btn")
    self.collect_btn = image_panel:getChildByName("collect_btn")
    self.collect_btn:ignoreContentAdaptWithSize(true)
    self.like_btn = image_panel:getChildByName("like_btn")
    self.like_btn:ignoreContentAdaptWithSize(true)
    
    self.play_num = self.container:getChildByName("play_num")
    self.play_num:setString(0)
    self.share_num = self.container:getChildByName("share_num")
    self.share_num:setString(0)
    self.like_num = self.container:getChildByName("like_num")
    self.like_num:setString(0)

    --左右两边的item对象列表
    self.left_item_list = {}
    self.right_item_list = {}
    self.panel_role_left = image_panel:getChildByName("panel_role_left")
    self.panel_role_right = image_panel:getChildByName("panel_role_right")

    -- 精灵
    self.left_elfin_list = {}
    self.right_elfin_list = {}
    self.panel_elfin_left = self.container:getChildByName("panel_elfin_left")
    self.panel_elfin_right = self.container:getChildByName("panel_elfin_right")
    
    --local panel_size = self.panel_role_left:getContentSize()
    --local width = 66
    --local height = 66
    --local space_x = 12
    --local space_y = 12
    --local start_x = 13
    --local start_y = 10
    --9位置
    --self.postion_list = {}
    --for i=1,3 do
    --    for j=1,3 do
    --        local index = (i-1)*3 + j
    --        self.postion_list[index] = cc.p((width + space_x) * (j-1) + width * 0.5 +start_x, (height + space_y) * (3-i) + height * 0.5 + start_y)
    --    end
    --end
    self.hero_bg_list = {}
    for page = 0,1 do
        for pos = 1,9 do
            local index = page*10+pos
            local item = image_panel:getChildByName("image_icn_"..index)
            self.hero_bg_list[index] = item
            local res = PathTool.getResFrame("common", "common_2051")
            createSprite(res, 54, 56, item, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST, -1)
        end
    end
end

function VedioMainItem:register_event(  )
    -- 回放
    registerButtonEventListener(self.play_btn, function (  )
        if self.data then
            -- 天梯或者是从聊天中点开的录像详情，则发送a_srv_id
            if self.data.combat_type == BattleConst.Fight_Type.CrossChampion then 
                if self.data.ext and next(self.data.ext) ~= nil then
                    local srv_id
                    for k,v in pairs(self.data.ext) do
                        if v.key == 1 then
                            srv_id = v.str
                            break
                        end
                    end
                    if srv_id then
                        BattleController:getInstance():csRecordBattle(self.data.id, srv_id)
                    end
                end
            elseif self.vedioType == VedioConst.Tab_Index.Ladder or self.is_share == true then
                BattleController:getInstance():csRecordBattle(self.data.id, self.data.a_srv_id)
            else
                local role_vo = RoleController:getInstance():getRoleVo()
                BattleController:getInstance():csRecordBattle(self.data.id, role_vo.srv_id)
            end
            self.play_num:setString(self.data.play+1)
            local new_data = _model:updateVedioData(self.vedioType, self.data.id, "play", self.data.play+1)
            if self.is_myself or self.is_collect then
                GlobalEvent:getInstance():Fire(VedioEvent.UpdateVedioDataEvent, new_data)
            end
            if self._playCallBack then
                self._playCallBack()
            end
        end
    end, true, 1)
    -- 分享
    registerButtonEventListener(self.share_btn, function ( param, sender )
        if self.data.channel and self.data.channel == ChatConst.Channel.Cross then
            message(TI18N("抱歉，跨服分享的录像无法收藏、点赞和分享"))
            return
        end
        if self._shareCallBack and sender then
            local world_pos = sender:convertToWorldSpace(cc.p(0.5, 0))
            local srv_id
            if self.data.combat_type == BattleConst.Fight_Type.CrossChampion and self.data.ext and next(self.data.ext) ~= nil then
                for k,v in pairs(self.data.ext) do
                    if v.key == 1 then
                        srv_id = v.str or self.data.a_srv_id
                        break
                    end
                end
            else
                srv_id = self.data.a_srv_id
            end
            self._shareCallBack(world_pos, self.data.id, self.data.share+1, srv_id, self.data.combat_type)
        end
    end, true, 1)
    -- 数据
    registerButtonEventListener(self.info_btn, function (  )
        self:_onClickInfoBtn()
    end, true, 1)
    -- 收藏
    registerButtonEventListener(self.collect_btn, function (  )
        if self.data then
            if self.data.channel and self.data.channel == ChatConst.Channel.Cross then
                message(TI18N("抱歉，跨服分享的录像无法收藏、点赞和分享"))
                return
            end
            local srv_id
            if self.data.combat_type == BattleConst.Fight_Type.CrossChampion and self.data.ext and next(self.data.ext) ~= nil then
                for k,v in pairs(self.data.ext) do
                    if v.key == 1 then
                        srv_id = v.str or self.data.a_srv_id
                        break
                    end
                end
            else
                srv_id = self.data.a_srv_id
            end

            if self.data.is_collect == TRUE then
                self.data.is_collect = 0
                self.collect_btn:loadTexture(PathTool.getResFrame("common","common_icon_33",false,"commonicon"), LOADTEXT_TYPE_PLIST)
                self.collect_btn:setScale(0.8)
                self.collect_btn:getChildByName("title"):setString(TI18N("收藏"))
                _controller:requestCollectVedio(self.data.id, 0, srv_id, self.data.combat_type)
                local new_data = _model:updateVedioData(self.vedioType, self.data.id, "is_collect", 0)
                if self.is_myself or self.is_collect then
                    GlobalEvent:getInstance():Fire(VedioEvent.UpdateVedioDataEvent, new_data)
                end
            else
                self.collect_btn:getChildByName("title"):setString(TI18N("取消收藏"))

                _controller:requestCollectVedio(self.data.id, 1, srv_id, self.data.combat_type, self.vedioType)
            end
        end
    end, true, 1, nil, 0.8)
    -- 点赞
    registerButtonEventListener(self.like_btn, function (  )
        if self.data then
            if self.data.channel and self.data.channel == ChatConst.Channel.Cross then
                message(TI18N("抱歉，跨服分享的录像无法收藏、点赞和分享"))
                return
            end
            -- 今日是否还可以点赞
            if _model:checkTodayLikeIsFull() then
                message(TI18N("今日点赞次数已用完"))
                return
            end
            self.data.flag = 1
            if self.data.combat_type == BattleConst.Fight_Type.CrossChampion then
                if self.data.ext and next(self.data.ext) ~= nil then
                    local srv_id
                    for k,v in pairs(self.data.ext) do
                        if v.key == 1 then
                            srv_id = v.str or self.data.a_srv_id
                            break
                        end
                    end
                    _controller:requestLikeVedio(self.data.id, srv_id, self.data.combat_type)
                end
            else
                _controller:requestLikeVedio(self.data.id, self.data.a_srv_id, self.data.combat_type)
            end
            self.like_btn:setTouchEnabled(false)
            setChildUnEnabled(true, self.like_btn)
            self.like_btn:setScale(0.8)
            self.like_btn:getChildByName("title"):setString(TI18N("已点赞"))
            --self.like_btn:loadTexture(PathTool.getResFrame("common", "common_icon_41",false,"commonicon"), LOADTEXT_TYPE_PLIST)
            addRedPointToNodeByStatus(self.like_btn, false)
            if self.data.like then
                self.like_num:setString(self.data.like+1)
            end
            _model:updateVedioData(self.vedioType, self.data.id, "flag", 1)
            local new_data = _model:updateVedioData(self.vedioType, self.data.id, "like", self.data.like+1)
            if self.is_myself or self.is_collect then
                GlobalEvent:getInstance():Fire(VedioEvent.UpdateVedioDataEvent, new_data)
            end
        end
    end, true, 1, nil, 0.8)

    if not self.update_self_event then
        self.update_self_event = GlobalEvent:getInstance():Bind(VedioEvent.UpdateVedioDataEvent, function(data)
            if self.data and data and self.data.id == data.id then
                self:setData(data)
            end 
        end)
    end

    if not self.update_like_num_event then
        self.update_like_num_event = GlobalEvent:getInstance():Bind(VedioEvent.UpdateTodayLikeNum, function(data)
            if self.vedioType == VedioConst.Tab_Index.Hot or self.vedioType == VedioConst.Tab_Index.Newhero then
                self:updateLikeBtnRedStatus()
            end
        end)
    end
end

-- 查看伤害统计
function VedioMainItem:_onClickInfoBtn(  )
    if self.data then
        local harmInfo = {}
        harmInfo.atk_name = self.data.a_name
        harmInfo.target_role_name = self.data.b_name
        harmInfo.hurt_statistics = {}
        harmInfo.vedio_id = self.data.id            -- 录像id
        if self.data.combat_type == BattleConst.Fight_Type.CrossChampion and self.data.ext and next(self.data.ext) ~= nil then
            for k,v in pairs(self.data.ext) do
                if v.key == 1 then
                    harmInfo.srv_id = v.str 
                    break
                end
            end
        end
        harmInfo.srv_id = harmInfo.srv_id or self.data.a_srv_id     
        harmInfo.combat_type = self.data.combat_type

        if self.data.ret == 1 then
            harmInfo.result = 1
        elseif self.data.ret == 2 then
            harmInfo.result = 2
        end
        
        for i=1,2 do
            local temp_data = {}
            temp_data.type = i
            temp_data.partner_hurts = {}
            if i == 1 then
                for i,v in ipairs(self.data.a_plist) do
                    v.rid = self.data.a_rid
                    v.srvid = self.data.a_srv_id
                    _table_insert(temp_data.partner_hurts, v)
                end
            else
                for i,v in ipairs(self.data.b_plist) do
                    v.rid = self.data.b_rid
                    v.srvid = self.data.b_srv_id
                    _table_insert(temp_data.partner_hurts, v)
                end
            end
            table.insert(harmInfo.hurt_statistics, temp_data)
        end
        BattleController:getInstance():openBattleHarmInfoView(true, harmInfo)
    end
end

-- 更新点赞按钮红点
function VedioMainItem:updateLikeBtnRedStatus(  )
    local red_status = false
    -- 默认打开哪个界面，红点就显示在哪个界面的item
    if self.default_index and self.vedioType and self.default_index == self.vedioType then
        if not self.is_myself and self.data and self.data.flag ~= TRUE and not _model:checkTodayLikeIsFull() then
            red_status = true
        end
    end
    addRedPointToNodeByStatus(self.like_btn, red_status, 5, 5)
end

function VedioMainItem:addCallBack( shareCallBack )
    self._shareCallBack = shareCallBack
end

function VedioMainItem:addPlayCallBack( _playCallBack )
    self._playCallBack = _playCallBack
end

function VedioMainItem:setExtendData( extend )
    if extend then
        self.is_myself = extend.is_myself or false
        self.is_collect = extend.is_collect or false
        self.is_hot = extend.is_hot or false
        self.is_newhero = extend.is_newhero or false
        self.default_index = extend.default_index or VedioConst.Tab_Index.Hot
    end
end

function VedioMainItem:setData( data )
    if not data then return end
    self.data = data

    -- 精灵相关 的数据
    local left_tree_lv = 0
    local right_tree_lv = 0
    local left_sprite_data = {}
    local right_sprite_data = {}
    local left_pvp_power = 0
    local right_pvp_power = 0
    for k,v in pairs(self.data.ext or {}) do
        if v.key == 2 then -- 左侧古树等级
            left_tree_lv = v.val or 0
        elseif v.key == 3 then -- 左侧精灵数据
            left_sprite_data = v.ext_list or {}
        elseif v.key == 4 then -- 右侧古树等级
            right_tree_lv = v.val or 0
        elseif v.key == 5 then -- 右侧精灵等级
            right_sprite_data = v.ext_list or {}
        elseif v.key == 6 then -- 左边pvp战力
            left_pvp_power = v.val or 0
        elseif v.key == 7 then -- 右边pvp战力
            right_pvp_power = v.val or 0
        end
    end

    -- 类型
    self.type_txt:setString(data.name)

    -- 回合
    local total_round = 0
    local battle_type = data.combat_type
    local fight_list_config = Config.CombatTypeData.data_fight_list
    if fight_list_config and fight_list_config[battle_type] then
        total_round = fight_list_config[battle_type].max_action_count or 0
    end
    self.round_txt:setString(string.format(TI18N("%d/%d回合"), data.round or 0, total_round))

    -- 时间
    self.time_txt:setString(TimeTool.getYMDHM(data.time))

    -- 播放、分享、点赞数量
    self.play_num:setString(data.play)
    self.share_num:setString(data.share)
    self.like_num:setString(data.like)

    -- 收藏按钮
    if data.is_collect == TRUE then
        self.collect_btn:loadTexture(PathTool.getResFrame("common", "common_icon_32",false,"commonicon"), LOADTEXT_TYPE_PLIST)
        self.collect_btn:setScale(0.8)
        self.collect_btn:getChildByName("title"):setString(TI18N("取消收藏"))
    else
        self.collect_btn:loadTexture(PathTool.getResFrame("common", "common_icon_33",false,"commonicon"), LOADTEXT_TYPE_PLIST)
        self.collect_btn:setScale(0.8)
        self.collect_btn:getChildByName("title"):setString(TI18N("收藏"))
    end
    -- 是否被点赞
    if self.is_myself then
        self.like_btn:setTouchEnabled(false)
        setChildUnEnabled(true, self.like_btn)
        self.like_btn:setScale(0.8)
        self.like_btn:getChildByName("title"):setString(TI18N("点赞"))
        --self.like_btn:loadTexture(PathTool.getResFrame("common", "common_icon_31",false,"commonicon"), LOADTEXT_TYPE_PLIST)
    elseif data.flag == TRUE then
        self.like_btn:setTouchEnabled(false)
        setChildUnEnabled(true, self.like_btn)
        self.like_btn:setScale(0.8)
        self.like_btn:getChildByName("title"):setString(TI18N("已点赞"))
        --self.like_btn:loadTexture(PathTool.getResFrame("common", "common_icon_41",false,"commonicon"), LOADTEXT_TYPE_PLIST)
    else
        self.like_btn:setTouchEnabled(true)
        setChildUnEnabled(false, self.like_btn)
        self.like_btn:setScale(0.8)
        self.like_btn:getChildByName("title"):setString(TI18N("点赞"))
        --self.like_btn:loadTexture(PathTool.getResFrame("common", "common_icon_31",false,"commonicon"), LOADTEXT_TYPE_PLIST)
    end
    -- 跨服频道中点开的录像详情，不允许点赞和收藏
    if self.data.channel and self.data.channel == ChatConst.Channel.Cross then
        setChildUnEnabled(true, self.collect_btn)
        self.collect_btn:setScale(0.8)
        setChildUnEnabled(true, self.like_btn)
        self.like_btn:setScale(0.8)
        setChildUnEnabled(true, self.share_btn)
    else
        setChildUnEnabled(false, self.collect_btn)
        self.collect_btn:setScale(0.8)
        setChildUnEnabled(false, self.share_btn)
        if not self.is_myself then
            --setChildUnEnabled(true, self.like_btn)
        end
    end

    -- 类型
    if self.is_hot then
        self.vedioType = VedioConst.Tab_Index.Hot
    elseif self.is_newhero then
        self.vedioType = VedioConst.Tab_Index.Newhero
    elseif data.combat_type == BattleConst.Fight_Type.Arena then
        self.vedioType = VedioConst.Tab_Index.Arena
    elseif data.combat_type == BattleConst.Fight_Type.Champion then
        self.vedioType = VedioConst.Tab_Index.Champion
    elseif data.combat_type == BattleConst.Fight_Type.PK then
        self.vedioType = VedioConst.Tab_Index.Solo
    elseif data.combat_type == BattleConst.Fight_Type.GuildWar then
        self.vedioType = VedioConst.Tab_Index.Guildwar
    elseif data.combat_type == BattleConst.Fight_Type.LadderWar then
        self.vedioType = VedioConst.Tab_Index.Ladder
    elseif data.combat_type == BattleConst.Fight_Type.EliteMatchWar or data.combat_type == BattleConst.Fight_Type.EliteKingMatchWar then
        self.vedioType = VedioConst.Tab_Index.Elite
    elseif data.combat_type == BattleConst.Fight_Type.CrossChampion then
        self.vedioType = VedioConst.Tab_Index.Crosschampion
    end

    -- 胜负
    self.result_win:setVisible(true)
    self.result_loss:setVisible(true)
    if data.ret == 1 then
        self.result_win:setPosition(cc.p(40, 466))
        self.result_loss:setPosition(cc.p(640, 466))
    elseif data.ret == 2 then
        self.result_win:setPosition(cc.p(640, 466))
        self.result_loss:setPosition(cc.p(40, 466))
    else
        self.result_win:setVisible(false)
        self.result_loss:setVisible(false)
    end

    -- 点赞红点
    self:updateLikeBtnRedStatus()

    ----------------@ 左侧
    self.name_left:setString(transformNameByServ(data.a_name, data.a_srv_id))
    if data.combat_type == BattleConst.Fight_Type.Champion then
        self.challenge_left:setVisible(false)
    else
        self.challenge_left:setVisible(true)
        self.challenge_left:setString(TI18N("挑战方"))
        self.challenge_left:setTextColor(VedioConst.Color.Atk)
    end

    -- 战力
    self:showPvpArrowUI(1,left_pvp_power)
    self.atk_label_left:setString(changeBtValueForPower(data.a_power + left_pvp_power))
    -- 等级
    self.level_left:setString(string.format(TI18N("%s级"), data.a_lev))

    -- 调整位置
    local left_name_size = self.name_left:getContentSize()
    self.level_left:setPositionX(self.name_left:getPositionX()+left_name_size.width+10)

    if data.combat_type == BattleConst.Fight_Type.Arena then
        if data.a_rank > 0 then
            self.rank_label_left:setString(data.a_rank)
        else
            self.rank_label_left:setString(TI18N("暂无"))
        end
        self:showPvpText(false, 1)
        self.image_rank_left:setVisible(true)
        self.rank_title_left:setVisible(true)
        self.rank_label_left:setVisible(true)
        --self.image_atk_left:setPositionY(98)
    else
        self:showPvpText(true, 1, left_pvp_power)
        self.image_rank_left:setVisible(false)
        self.rank_title_left:setVisible(false)
        self.rank_label_left:setVisible(false)
        --self.image_atk_left:setPositionY(82)
    end
    -- 宝可梦
    local left_role_data = {}
    for i=1,9 do
        local index = VedioConst.Left_Role_Battle_Index[i]
        local role_data = self:getRoleInfoByIndex(index, data.a_plist)
        -- _table_insert(left_role_data, role_data)
        local hero_item = self.left_item_list[i]
        if role_data then
            if hero_item == nil then
                hero_item = self:createHeroExhibitionItemByIndex(i, 0)
                self.left_item_list[i] = hero_item
            else
                hero_item:setVisible(true)
            end
            hero_item:setData(role_data)
            hero_item:addCallBack(function() self:_onClickRoleHead(role_data, 1) end)
        else
            if hero_item then
                hero_item:setVisible(false)
            end
        end

    end
    -- self.left_scrollview:setData(left_role_data)

    --------------------@ 右侧
    self.name_right:setString(transformNameByServ(data.b_name, data.b_srv_id))
    if data.combat_type == BattleConst.Fight_Type.Champion then
        self.challenge_right:setVisible(false)
    else
        self.challenge_right:setVisible(true)
        self.challenge_right:setString(TI18N("防守方"))
        self.challenge_right:setTextColor(VedioConst.Color.Def)
    end
    -- 战力
    self:showPvpArrowUI(2, right_pvp_power)
    self.atk_label_right:setString(changeBtValueForPower(data.b_power + right_pvp_power))
    -- 等级
    self.level_right:setString(string.format(TI18N("%s级"), data.b_lev))

    -- 调整位置
    local right_name_size = self.name_right:getContentSize()
    self.level_right:setPositionX(self.name_right:getPositionX()-right_name_size.width-10)

    if data.combat_type == BattleConst.Fight_Type.Arena then
        if data.b_rank > 0 then
            self.rank_label_right:setString(data.b_rank)
        else
            self.rank_label_right:setString(TI18N("暂无"))
        end
        self:showPvpText(false, 2)
        self.image_rank_right:setVisible(true)
        self.rank_label_right:setVisible(true)
        self.rank_title_right:setVisible(true)
        --self.image_atk_right:setPositionY(98)
    else

        self:showPvpText(true, 2, right_pvp_power)
        self.image_rank_right:setVisible(false)
        self.rank_label_right:setVisible(false)
        self.rank_title_right:setVisible(false)
        --self.image_atk_right:setPositionY(82)
    end
    -- 宝可梦
    local right_role_data = {}
    for i=1,9 do
        local index = VedioConst.Right_Role_Battle_Index[i]
        local role_data = self:getRoleInfoByIndex(index, data.b_plist)
        -- _table_insert(right_role_data, role_data)
        local hero_item = self.right_item_list[i]
        if role_data then
            if hero_item == nil then
                hero_item = self:createHeroExhibitionItemByIndex(i, 1)
                self.right_item_list[i] = hero_item
            else
                hero_item:setVisible(true)
            end
            hero_item:setData(role_data)
            hero_item:addCallBack(function() self:_onClickRoleHead(role_data, 2) end)
        else
            if hero_item then
                hero_item:setVisible(false)
            end
        end
    end
    -- self.right_scrollview:setData(right_role_data)
    --暂时屏蔽精灵系统
    if IS_HIDE_ELFIN then
        self.tree_lv_left:setString(“”)
        self.tree_lv_right:setString(“”)
    else
        self.tree_lv_left:setString(_string_format(TI18N("古树：%d级"), left_tree_lv))
        self.tree_lv_right:setString(_string_format(TI18N("古树：%d级"), right_tree_lv))
        for i=1,4 do
            local left_elfin_item = self.left_elfin_list[i]
            if not left_elfin_item then
                left_elfin_item = SkillItem.new(true, true, true, 0.4, true)
                local pos_x = 22 + (i-1)*54
                left_elfin_item:setPosition(cc.p(pos_x, 24))
                self.panel_elfin_left:addChild(left_elfin_item)
                self.left_elfin_list[i] = left_elfin_item
            end
            self:setElfinSkillItemData(left_elfin_item, left_sprite_data, i)

            local right_elfin_item = self.right_elfin_list[i]
            if not right_elfin_item then
                right_elfin_item = SkillItem.new(true, true, true, 0.4, true)
                local pos_x = 22 + (i-1)*54
                right_elfin_item:setPosition(cc.p(pos_x, 24))
                self.panel_elfin_right:addChild(right_elfin_item)
                self.right_elfin_list[i] = right_elfin_item
            end
            self:setElfinSkillItemData(right_elfin_item, right_sprite_data, i)
        end
    end

end

--pos_type 1 左边 2 右边
function VedioMainItem:showPvpArrowUI(pos_type, pvp_power)
    if not pos_type then return end
    if pos_type == 1 then
        if pvp_power and pvp_power > 0 then
            if self.left_pvp_arrow == nil  then
                self.left_pvp_arrow = createImage(self.container, PathTool.getResFrame("common","common_1086"), 170, 98, cc.p(0.5,0.5), true)
                self.left_pvp_arrow:setScale(0.9)
            else
                self.left_pvp_arrow:setVisible(true)
            end
        else
            if self.left_pvp_arrow then
                self.left_pvp_arrow:setVisible(false)
            end
        end
    elseif pos_type == 2 then
        if pvp_power and pvp_power > 0 then
            if self.right_pvp_arrow == nil  then
                self.right_pvp_arrow = createImage(self.container, PathTool.getResFrame("common","common_1086"), 454, 98, cc.p(0.5,0.5), true)
                self.right_pvp_arrow:setScale(0.9)
            else
                self.right_pvp_arrow:setVisible(true)
            end
        else
            if self.right_pvp_arrow then
                self.right_pvp_arrow:setVisible(false)
            end
        end
    end
end

function VedioMainItem:showPvpText(status, pos_type, pvp_power)
    if not pos_type then return end

    if pos_type == 1 then
        if status and pvp_power and pvp_power > 0 then
            if self.left_show_pvp_tips == nil then
                self.left_show_pvp_tips = createLabel(20, cc.c3b(0x24,0x90,0x03), nil, 107, 66, TI18N("（公会pvp）"), self.container, nil, cc.p(0.5, 0.5))
            else
                self.left_show_pvp_tips:setVisible(true) 
            end
        else
            if self.left_show_pvp_tips then
                self.left_show_pvp_tips:setVisible(false)
            end
        end
    elseif pos_type == 2 then
        if status and pvp_power and pvp_power > 0 then
            if self.right_show_pvp_tips == nil then
                self.right_show_pvp_tips = createLabel(20, cc.c3b(0x24,0x90,0x03), nil, 555, 66, TI18N("（公会pvp）"), self.container, nil, cc.p(0.5, 0.5))
            else
                self.right_show_pvp_tips:setVisible(true) 
            end
        else
            if self.right_show_pvp_tips then
                self.right_show_pvp_tips:setVisible(false)
            end
        end
    end
end

-- 根据位置获取精灵的bid
function VedioMainItem:getElfinBidByPos( sprite_data, pos )
    if not sprite_data or next(sprite_data) == nil then return end
    for k,v in pairs(sprite_data) do
        if v.ext_list_key == pos then
            return v.ext_list_val
        end
    end
end

function VedioMainItem:setElfinSkillItemData( skill_item, sprite_data, pos )
    local elfin_bid = self:getElfinBidByPos(sprite_data, pos)
    if elfin_bid then
        skill_item:showLockIcon(false)
        local elfin_cfg = Config.SpriteData.data_elfin_data(elfin_bid)
        if elfin_bid == 0 or not elfin_cfg then -- 已解锁，但未放置精灵
            skill_item:setData()
            skill_item:showLevel(false)
        else
            local skill_cfg = Config.SkillData.data_get_skill(elfin_cfg.skill)
            if skill_cfg then
                skill_item:showLevel(true)
                skill_item:setData(skill_cfg)
            end
        end
    else
        skill_item:setData()
        skill_item:showLevel(false)
        skill_item:showLockIcon(true)
    end
end


--创建一个新的item根据位置索引
function VedioMainItem:createHeroExhibitionItemByIndex(pos, index)
    local hero_item = HeroExhibitionItem.new(1, true, nil, nil ,true)
    --local pos = self.postion_list[index] or cc.p(0,0)
    local parent = self.image_panel:getChildByName("image_icn_"..(index*10+pos))
    hero_item:setPosition(56,54)
    parent:addChild(hero_item)
    hero_item:setVisible(true)
    return hero_item
end

function VedioMainItem:_onClickRoleHead(data, dir_type)
    if not data or not self.data then return end
    local srv_id
    if self.data.combat_type == BattleConst.Fight_Type.CrossChampion and self.data.ext and next(self.data.ext) ~= nil then
        for k,v in pairs(self.data.ext) do
            if v.key == 1 then
                srv_id = v.str or self.data.a_srv_id
                break
            end
        end
    else
        srv_id = self.data.a_srv_id
    end    
    _controller:requestVedioHeroData(self.data.id, data.id, dir_type, srv_id, self.data.combat_type)
end

-- 根据位置获取宝可梦数据
function VedioMainItem:getRoleInfoByIndex( index, role_list )
    for k,v in pairs(role_list) do
        if v.pos == index then
            return v
        end
    end
    return nil
end

function VedioMainItem:DeleteMe(  )
    if self.left_item_list then
        for k,item in pairs(self.left_item_list) do
            item:DeleteMe()
        end
        self.left_item_list = nil
    end

    if self.right_item_list then
        for k,item in pairs(self.right_item_list) do
            item:DeleteMe()
        end
        self.right_item_list = nil
    end

    if self.left_elfin_list then
        for k,item in pairs(self.left_elfin_list) do
            item:DeleteMe()
            item = nil
        end
    end

    if self.right_elfin_list then
        for k,item in pairs(self.right_elfin_list) do
            item:DeleteMe()
            item = nil
        end
    end

    if self.update_self_event then
        GlobalEvent:getInstance():UnBind(self.update_self_event)
        self.update_self_event = nil
    end
    if self.update_like_num_event then
        GlobalEvent:getInstance():UnBind(self.update_like_num_event)
        self.update_like_num_event = nil
    end
end
