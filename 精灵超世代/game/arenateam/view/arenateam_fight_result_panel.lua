-- --------------------------------------------------------------------
-- @author: lwcn@syg.com(必填, 创建模块的人员)
-- @editor: lwc@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--             组队竞技场结算界面
-- end)

ArenateamFightResultPanel = ArenateamFightResultPanel or BaseClass(BaseView)

local controller = ArenateamController:getInstance()

local string_format = string.format
local table_sort = table.sort

function ArenateamFightResultPanel:__init(result)
    self.win_type = WinType.Tips
    self.layout_name = "arenateam/arenateam_fight_result_panel"
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.is_full_screen = false
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("battle", "battle"), type = ResourcesType.plist },
        { path = PathTool.getPlistImgForDownLoad("arenateam", "arenateam"), type = ResourcesType.plist },
    }

    self.result = result
    self.fight_type = BattleConst.Fight_Type.Arean_Team
    -- self.role_vo = RoleController:getInstance():getRoleVo()
end


--初始化
function ArenateamFightResultPanel:open_callback()
    local res = ""

    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())
    self.container = self.root_wnd:getChildByName("container")
    --self.container:setScale(display.getMaxScale())
    self.title_container = self.container:getChildByName("title_container")
    self.title_width = self.title_container:getContentSize().width
    self.title_height = self.title_container:getContentSize().height
    self:handleEffect(true)

    if self.result == 1 then
        playOtherSound("b_win", AudioManager.AUDIO_TYPE.BATTLE) 
    else
        self.container:getChildByName("Sprite_1"):setVisible(false)
        self.container:getChildByName("Sprite_2"):setVisible(false)
        AudioManager:getInstance():playMusic(AudioManager.AUDIO_TYPE.BATTLE, "b_lose", false)
    end
    

    self.fight_text = self.container:getChildByName("fight_text")
    if self.fight_text then
        local name = Config.BattleBgData.data_fight_name[self.fight_type]
        if name then
            self.fight_text:setString(TI18N("当前战斗：")..name)
        end
    end
    self.harm_btn = self.container:getChildByName("harm_btn")
    self.harm_btn:setVisible(false)
    self.harm_btn:getChildByName("harm_lab"):setString(TI18N("数据统计"))

    self.my_arrow_1 = self.container:getChildByName("my_arrow_1")
    self.my_arrow_2 = self.container:getChildByName("my_arrow_2")
    self.enemy_arrow_1 = self.container:getChildByName("enemy_arrow_1")
    self.enemy_arrow_2 = self.container:getChildByName("enemy_arrow_2")

    self.my_team_name = self.container:getChildByName("my_team_name")
    self.my_team_score = self.container:getChildByName("my_team_score")
    self.my_team_change_score = self.container:getChildByName("my_team_change_score")
    self.my_team_rank = self.container:getChildByName("my_team_rank")
    self.my_team_change_rank = self.container:getChildByName("my_team_change_rank")

    self.enemy_team_name = self.container:getChildByName("enemy_team_name")
    self.enemy_team_score = self.container:getChildByName("enemy_team_score")
    self.enemy_team_change_score = self.container:getChildByName("enemy_team_change_score")
    self.enemy_team_rank = self.container:getChildByName("enemy_team_rank")
    self.enemy_team_change_rank = self.container:getChildByName("enemy_team_change_rank")

    self.my_head_node = self.container:getChildByName("my_head_node")
    self.enemy_head_node = self.container:getChildByName("enemy_head_node")

    self.my_head_list = {}
    for i=1,3 do
        self.my_head_list[i] = PlayerHead.new(PlayerHead.type.circle)
        self.my_head_list[i]:setSwallowTouches(false)
        self.my_head_list[i]:setHeadLayerScale(0.95)
        self.my_head_list[i]:setPosition(110 * (i - 1) , 0)
        -- self.my_head_list[i]:setLev(0)
        self.my_head_node:addChild(self.my_head_list[i])
    end
    self.enemy_head_list = {}
    for i=1,3 do
        self.enemy_head_list[i] = PlayerHead.new(PlayerHead.type.circle)
        self.enemy_head_list[i]:setSwallowTouches(false)
        self.enemy_head_list[i]:setHeadLayerScale(0.95)
        self.enemy_head_list[i]:setPosition(110 * (i - 1) , 0)
        -- self.my_head_list[i]:setLev(0)
        self.enemy_head_node:addChild(self.enemy_head_list[i])
    end

    self.cancel_btn = self.container:getChildByName("cancel_btn")
    self.cancel_btn:getChildByName("label"):setString(TI18N("回到竞技场"))
    self.comfirm_btn = self.container:getChildByName("comfirm_btn")
    self.comfirm_btn:getChildByName("label"):setString(TI18N("确 定"))
end


function ArenateamFightResultPanel:register_event()
    registerButtonEventListener(self.harm_btn, handler(self, self._onClickHarmBtn), true)
    registerButtonEventListener(self.cancel_btn, handler(self, self.onClickCancelBtn), true)
    registerButtonEventListener(self.comfirm_btn, handler(self, self.onClickComfirmBtn), true)
end

function ArenateamFightResultPanel:_onClickHarmBtn(  )
    if self.data and self.data.all_hurt_statistics then
        table.sort( self.data.all_hurt_statistics, function(a, b) return a.type < b.type end)
        local role_vo = RoleController:getInstance():getRoleVo()
        local atk_name = role_vo.name
        local dic_a_member = {}
        local dic_b_member = {}
        for i,v in ipairs(self.data.a_team_members) do
            dic_a_member[v.pos] = v
        end

        for i,v in ipairs(self.data.b_team_members) do
            dic_b_member[v.pos] = v
        end
        

        for i,v in ipairs(self.data.all_hurt_statistics) do
            if dic_a_member[v.a_round] then
                v.atk_name = dic_a_member[v.a_round].name
            else
                v.atk_name = TI18N("未知")
            end
            if dic_b_member[v.b_round] then
                v.target_role_name = dic_b_member[v.b_round].name
            else
                v.target_role_name = TI18N("未知")
            end
        end
        BattleController:getInstance():openBattleHarmInfoView(true, self.data.all_hurt_statistics)
    end
end

--回到竞技场
function ArenateamFightResultPanel:onClickCancelBtn(  )
    BattleResultReturnMgr:returnByFightType(self.fight_type) --先
    controller:openArenateamFightResultPanel(false)
end

--确定
function ArenateamFightResultPanel:onClickComfirmBtn(  )
    controller:openArenateamFightResultPanel(false)
end

function ArenateamFightResultPanel:openRootWnd(data,fight_type)
    if not data then return end
    self.data = data
    if self.data and self.data.all_hurt_statistics then
        self.harm_btn:setVisible(true)
    else
        self.harm_btn:setVisible(false)
    end

    self.my_team_name:setString(data.a_team_name or "")
    self.my_team_score:setString(string_format(TI18N("积分: %s"), data.a_new_score))
    local score = data.a_new_score - data.a_score
    self:updateChangeInfo(self.my_team_change_score, score, self.my_arrow_1)

    if data.a_new_rank > 0 then
        self.my_team_rank:setString(string_format(TI18N("排名: %s"), data.a_new_rank))
    else
        self.my_team_rank:setString(TI18N("排名: 未上榜"))
    end
    local score = 0
    if data.a_rank == 0 then
        score = data.a_new_rank
    else
        score = data.a_rank - data.a_new_rank    
    end
    self:updateChangeInfo(self.my_team_change_rank, score, self.my_arrow_2)

    self.enemy_team_name:setString(data.b_team_name or "")
    self.enemy_team_score:setString(string_format(TI18N("积分: %s"), data.b_new_score))
    local score = data.b_new_score - data.b_score
    self:updateChangeInfo(self.enemy_team_change_score, score, self.enemy_arrow_1)

    if data.b_new_rank > 0 then
        self.enemy_team_rank:setString(string_format(TI18N("排名: %s"), data.b_new_rank))
    else
        self.enemy_team_rank:setString(TI18N("排名: 未上榜"))
    end
    local score = data.b_rank - data.b_new_rank
    self:updateChangeInfo(self.enemy_team_change_rank, score, self.enemy_arrow_2)

    --头像
    self:updateHeadList(self.my_head_list, data.a_team_members)
    --地方头像
    self:updateHeadList(self.enemy_head_list, data.b_team_members)
end

function ArenateamFightResultPanel:updateChangeInfo(label, score, arrow_img)
    if score > 0 then
        arrow_img:setVisible(true)
        label:setString(score)
        label:setTextColor(cc.c4b(0x00,0x80,0x00,0xff))
        loadSpriteTexture(arrow_img, PathTool.getResFrame("common", "common_1086"), LOADTEXT_TYPE_PLIST) 
    elseif score < 0 then
        arrow_img:setVisible(true)
        label:setString(score)
        label:setTextColor(cc.c4b(0xff,0x4e,0x4e,0xff))
        loadSpriteTexture(arrow_img, PathTool.getResFrame("common", "common_1087"), LOADTEXT_TYPE_PLIST) 
    else
        label:setString("")
        arrow_img:setVisible(false)
    end
end


--更新头像
function ArenateamFightResultPanel:updateHeadList(head_list, team_members)
    if not team_members then return end
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

    for i,head in ipairs(head_list) do
       local member_data = team_members[i]
        if member_data then
            head:setHeadRes(member_data.face_id, false, LOADTEXT_TYPE, member_data.face_file, member_data.face_update_time)
            head:setLev(member_data.lev)
            head:showLeader(false)
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
            head:showLeader(false)
            local bgRes = PathTool.getResFrame("common","common_1031")
            head:showBg(bgRes, nil, true)
        end
    end
end

function ArenateamFightResultPanel:handleEffect(status)
    if status == false then
        if self.play_effect then
            self.play_effect:clearTracks()
            self.play_effect:removeFromParent()
            self.play_effect = nil
        end
    else
        if not tolua.isnull(self.title_container) and self.play_effect == nil then
            if self.result == 1 then
                self.play_effect = createEffectSpine(PathTool.getEffectRes(103), cc.p(self.title_width * 0.5, self.title_height * 0.5 - 10), cc.p(0.5, 0.5), false, PlayerAction.action_2)
            else
                self.play_effect = createEffectSpine(PathTool.getEffectRes(104), cc.p(self.title_width * 0.5, self.title_height * 0.5 + 10), cc.p(0.5, 0.5), false, PlayerAction.action)
            end
            self.title_container:addChild(self.play_effect, 1)
        end
    end
end 


--暂时没用
function ArenateamFightResultPanel:updateTimer()
    local time = 10
    local call_back = function()
        time = time - 1
        local new_time = math.ceil(time)
        local str = string.format(TI18N("%s秒后关闭"), new_time)
        if self.time_label and not tolua.isnull(self.time_label) then
            self.time_label:setString(str)
        end
        if new_time <= 0 then
            BattleController:getInstance():openFinishView(false,self.fight_type)
        end
    end
    GlobalTimeTicket:getInstance():add(call_back,1, 0, "result_timer" .. self.fight_type)
end

function ArenateamFightResultPanel:close_callback()
    -- 移除可能存在的装备tips
    HeroController:getInstance():openEquipTips(false)
    TipsManager:getInstance():hideTips()
    BattleController:getInstance():openFinishView(false,self.fight_type) 
    GlobalEvent:getInstance():Fire(BattleEvent.CLOSE_RESULT_VIEW,self.fight_type)
    GlobalTimeTicket:getInstance():remove("result_timer" .. self.fight_type)

    self:handleEffect(false)

    if BattleController:getInstance():getModel():getBattleScene() and BattleController:getInstance():getIsSameBattleType(self.fight_type) then
        BattleController:getInstance():getModel():result(self.data, self.is_leave_self)
    end
end
