--------------------------------------------
-- @Author  : lwc
-- @Date    : 2019年10月14日
-- @description    : 
        -- 组队竞技场挑战tips
---------------------------------
local controller = ArenateamController:getInstance()
local model = controller:getModel()
local table_insert = table.insert
local string_format = string.format
local table_sort = table.sort

ArenateamFightTips = ArenateamFightTips or BaseClass(BaseView)

function ArenateamFightTips:__init( )
    self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.is_full_screen = false

    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("arenateam_form", "arenateam_form"), type = ResourcesType.plist},
    }
    self.layout_name = "arenateam/arenateam_fight_tips"
    self.atk_name_list = {}
    self.atk_txt_list = {}
    self.hero_item_list = {}

    self.my_atk_name_list = {}
    self.my_atk_txt_list = {}
    self.my_hero_item_list = {}

    -- self.skip_cfg = Config.ArenaClusterData.data_const["arena_skip_count"]
end

function ArenateamFightTips:open_callback(  )
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(self.container, 1)

    self.btn_challenge = self.container:getChildByName("btn_challenge")
    -- local btn_size = self.btn_challenge:getContentSize()
    self.btn_challenge:getChildByName("label"):setString(TI18N("挑 战"))
    -- self.btn_challenge_label = createRichLabel(26, cc.c3b(113, 40, 4), cc.p(0.5, 0.5), cc.p(btn_size.width/2, btn_size.height/2))
    -- self.btn_challenge_label:setString(TI18N("挑 战"))
    -- self.btn_challenge:addChild(self.btn_challenge_label)

    -- self.ticket_bid = Config.ArenaClusterData.data_const["arena_ticket"].val
    -- local item_config = Config.ItemData.data_get_data(self.ticket_bid) 
    -- if item_config then
    --     self.btn_challenge_label:setString(string_format(TI18N("<img src='%s' scale=0.4 />3 挑战"), PathTool.getItemRes(item_config.icon)))
    -- end
    --F9D74E
    self.txt_name = createRichLabel(26, cc.c4b(0x3d,0x50,0x78,0xff), cc.p(1, 0.5), cc.p(669, 948),nil,nil,1000) 
    self.container:addChild(self.txt_name)
    self.txt_score = self.container:getChildByName("txt_score")
    self.txt_total_atk = self.container:getChildByName("txt_total_atk")

    self.txt_my_name = createRichLabel(26, cc.c4b(0x3d,0x50,0x78,0xff), cc.p(1, 0.5), cc.p(669, 470),nil,nil,1000) 
    self.container:addChild(self.txt_my_name)
    self.txt_my_score = self.container:getChildByName("txt_my_score")
    self.txt_my_total_atk = self.container:getChildByName("txt_my_total_atk")

    self.skip_battle_btn = self.container:getChildByName("skip_battle_btn")
    self.skip_battle_btn:setVisible(true)
    self.is_skip_fight = SysEnv:getInstance():getBool(SysEnv.keys.arenateam_skip_fight, true)
    self.skip_battle_btn:setSelected(self.is_skip_fight)
    self.skip_battle_btn:getChildByName("name"):setString(TI18N("跳过战斗"))

    self.btn_form = self.container:getChildByName("btn_form")
    self.btn_form:getChildByName("label"):setString(TI18N("调整布阵"))

    self.change_pos_btn_1 = self.container:getChildByName("change_pos_btn_1")
    self.change_pos_btn_2 = self.container:getChildByName("change_pos_btn_2")


    for i=1,3 do
        local title_team = self.container:getChildByName("title_team_" .. i)
        if title_team then
            title_team:setString(TI18N("队伍") .. StringUtil.numToChinese(i))
            self.atk_name_list[i] = title_team
        end
        local txt_atk = self.container:getChildByName("txt_atk_" .. i)
        if txt_atk then
            table_insert(self.atk_txt_list, txt_atk)
        end

        local title_my_team = self.container:getChildByName("title_my_team_" .. i)
        if title_my_team then
            title_my_team:setString(TI18N("队伍") .. StringUtil.numToChinese(i))
            self.my_atk_name_list[i] = title_my_team
        end
        local txt_my_atk = self.container:getChildByName("txt_my_atk_" .. i)
        if txt_my_atk then
            table_insert(self.my_atk_txt_list, txt_my_atk)
        end
    end
     --头像node
    self.txt_head_node = self.container:getChildByName("txt_head_node")
    self.txt_my_head_node = self.container:getChildByName("txt_my_head_node")
    self.role_head_list = {}
    self.my_head_list = {}
    for i=1,3 do
        self.role_head_list[i] = PlayerHead.new(PlayerHead.type.circle)
        self.role_head_list[i]:setHeadLayerScale(0.7)
        self.role_head_list[i]:setPosition(95 * (i - 1) , 0)
        -- self.role_head_list[i]:setLev(99)
        self.txt_head_node:addChild(self.role_head_list[i])

        self.my_head_list[i] = PlayerHead.new(PlayerHead.type.circle)
        self.my_head_list[i]:setHeadLayerScale(0.7)
        self.my_head_list[i]:setPosition(95 * (i - 1) , 0)
        -- self.role_head_list[i]:setLev(99)
        self.txt_my_head_node:addChild(self.my_head_list[i])
    end

end

function ArenateamFightTips:register_event(  )
    registerButtonEventListener(self.background, function (  )
        controller:openArenateamFightTips(false)
    end, false, 2)

    registerButtonEventListener(self.btn_form, function (  )
        controller:openArenateamFormPanel(true, {from_type = 2})
    end, true)

    registerButtonEventListener(self.btn_challenge, function (  ) self:onChallengeBtn() end, true)

    registerButtonEventListener(self.change_pos_btn_1, function (  )
        self:changeTeamDataOrder(1)
    end, true)

    registerButtonEventListener(self.change_pos_btn_2, function (  )
        self:changeTeamDataOrder(2)
    end, true)

    self.skip_battle_btn:addEventListener(function ( sender,event_type )
        self.is_skip_fight = self.skip_battle_btn:isSelected()
    end)

    -- -- 我的进攻阵容数据
    self:addGlobalEvent(ArenateamEvent.ARENATEAM_MY_TEAM_INFO_EVENT, function ( scdata )
        if scdata  then
            self:updateMyselfInfo(scdata)
        end
    end)

    -- -- 阵容数据变化
    self:addGlobalEvent(ArenateamEvent.ARENATEAM_SAVE_FROM_EVENT, function ( data )
        if self.is_on_fight then
            self.is_on_fight = false
            if self.data and self.data.tid and self.data.srv_id then
                local is_auto
                if self.is_skip_fight then
                    is_auto = 1
                else
                    is_auto = 0
                end
                controller:sender27252(self.data.tid, self.data.srv_id, is_auto)
                controller:openArenateamFightTips(false)
            end
        end
    end)
end

function ArenateamFightTips:onChallengeBtn()
    if not self.scdata then return end
    if self.data and self.data.tid and self.data.srv_id then
        local pos_info = {}
        for i,v in ipairs(self.scdata.arena_team_member) do
            local data = {}
            data.rid = v.rid
            data.sid = v.sid
            data.pos = v.pos
            data.is_hide = v.is_hide
            table_insert(pos_info, data)
        end
        self.is_on_fight = true
        controller:sender27242(pos_info)
    end
end


--提醒 self.data 是敌方队伍信息
--selfl.scdata 是我放到队伍信息
function ArenateamFightTips:openRootWnd( setting )
    local setting = setting or {}
    local data = setting.data
    if not data then return end
    self:setData(data)
    local scdata = model:getMyTeamDetailsInfo()
    if scdata then
        delayRun(self.container, 0.1, function (  )
            self:updateMyselfInfo(scdata)
        end)
    else
        controller:sender27221()
    end
end

function ArenateamFightTips:setData( data )
    if not data then return end

    self.data = data
    -- 名称
    local str =  string_format(TI18N("敌方队伍名:<div fontcolor=#3d5078>%s</div>"), transformNameByServ(data.team_name, data.sid))
    self.txt_name:setString(str)
    -- 积分
    self.txt_score:setString(string_format(TI18N("积分:%d"), data.team_score))

    -- 总战力
    self.txt_total_atk:setString(data.team_power)
    local team_members = data.team_members or {}
    
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

    self:updateHeadInfo(self.role_head_list, team_members) 

    -- 队伍
    local team_list = data.team_members or {}

    for i,team_data in ipairs(team_list) do
        -- 战力
        local akt_txt = self.atk_txt_list[i]
        if akt_txt then
            if team_data.is_hide == 1 then
                akt_txt:setString("???")
            else
                akt_txt:setString(team_data.power or 0)
            end
        end
        if self.atk_name_list[i] then
            self.atk_name_list[i]:setString(team_data.name)
        end
        -- 宝可梦
        if team_data.is_hide == 1 or not team_data.team_partner or next(team_data.team_partner) == nil then
            for n=1,5 do
                delayRun(self.container, n*2 / display.DEFAULT_FPS, function (  )
                    local hero_item = HeroExhibitionItem.new(0.7, true)
                    hero_item:setPosition(cc.p(230+(n-1)*(HeroExhibitionItem.Width*0.7+10), 826 - (i-1)*100))
                    self.container:addChild(hero_item)
                    hero_item:showUnknownIcon(true)
                    table_insert(self.hero_item_list, hero_item)
                end)
            end
        elseif team_data.team_partner then
            table.sort(team_data.team_partner, SortTools.KeyLowerSorter("pos"))
            for n=1,5 do
                delayRun(self.container, n*2 / display.DEFAULT_FPS, function (  )
                    local hero_data = team_data.team_partner[n]
                    local hero_item = HeroExhibitionItem.new(0.7, true)
                    -- hero_item:addCallBack(function (  )
                    --     if hero_data and hero_data.rid and hero_data.srv_id and team_data.order and hero_data.pos then
                    --         controller:sender25603( hero_data.rid, hero_data.srv_id, team_data.order, hero_data.pos )
                    --     end
                    -- end)
                    hero_item:setPosition(cc.p(230+(n-1)*(HeroExhibitionItem.Width*0.7+10), 826 - (i-1)*100))
                    self.container:addChild(hero_item)
                    table_insert(self.hero_item_list, hero_item)
                    if hero_data then
                        local hero_vo = HeroVo.New()
                        hero_vo.bid = hero_data.bid
                        hero_vo.lev = hero_data.lev
                        hero_vo.star = hero_data.star
                        hero_vo.use_skin = hero_data.use_skin
                        hero_item:setData(hero_vo)
                    end
                end)
            end
        end
    end
end


function ArenateamFightTips:updateHeadInfo(head_list, dic_pos_member_data)
    if not head_list then return end
    dic_pos_member_data = dic_pos_member_data or {}
    for i,head in ipairs(head_list) do
        local member_data = dic_pos_member_data[i]
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

-- 玩家自己的阵容数据
function ArenateamFightTips:updateMyselfInfo(scdata)
    if not scdata then return end
    self.scdata = scdata

    local my_team_info = model:getMyTeamInfo()
    local score = 0
    if my_team_info then
        score = my_team_info.score
    end

    local str =  string_format(TI18N("我方队伍名:<div fontcolor=#3d5078>%s</div>"), self.scdata.team_name)
    self.txt_my_name:setString(str)
    self.txt_my_score:setString(string_format(TI18N("积分:%d"), score))
    self.txt_my_total_atk:setString(self.scdata.team_power)

    local team_members = scdata.arena_team_member or {}
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
    self:updateHeadInfo(self.my_head_list, team_members) 

    local dic_pos_member_data = {}
    for i,v in ipairs(team_members) do
        dic_pos_member_data[v.pos] = v
    end

    for i=1,3 do
        delayRun(self.container, i*2 / display.DEFAULT_FPS, function (  )
            local member_data = dic_pos_member_data[i]
            if member_data then
                if self.my_atk_txt_list[i] then
                    self.my_atk_txt_list[i]:setString(member_data.power or 0)
                end

                if self.my_atk_name_list[i] then
                    self.my_atk_name_list[i]:setString(member_data.name)
                end

                table.sort( member_data.team_partner, function(a,b) return a.pos < b.pos end )
                self.my_hero_item_list[i] = self:updateHeroInfo(230, 352 - (i-1)*110 -25, member_data.team_partner, self.my_hero_item_list[i])
            end
        end)
    end
end

function ArenateamFightTips:updateHeroInfo(x, y, hero_list, hero_item_list)
    if hero_item_list == nil then
        hero_item_list = {}
    end
    for n=1,5 do
        local hero_item = hero_item_list[n]
        if hero_item == nil then
            hero_item = HeroExhibitionItem.new(0.7, true)
            hero_item:setPosition(cc.p(x+(n-1)*(HeroExhibitionItem.Width*0.7+10), y))
            self.container:addChild(hero_item)
            hero_item_list[n] = hero_item
        end
        
        local hero_data = hero_list[n]
        if hero_data then
            hero_item:setData(hero_data)
        else
            hero_item:setData(nil)
        end
        -- hero_item:addCallBack(function (  )
        --     if hero_data and hero_data.rid and hero_data.srv_id and team_data.order and hero_data.pos then
        --         controller:sender25603( hero_data.rid, hero_data.srv_id, team_data.order, hero_data.pos )
        --     end
        -- end)
    end
    return hero_item_list
end

-- 切换阵容
function ArenateamFightTips:changeTeamDataOrder( flag )
    if not self.scdata  then return end
    if flag == 1 then -- 队伍一和队伍二换位置
        for k,team_data in pairs(self.scdata.arena_team_member) do
            if team_data.pos == 1 then
                team_data.pos = 2
            elseif team_data.pos == 2 then
                team_data.pos = 1
            end
        end
    else -- 队伍二和队伍三换位置
        for k,team_data in pairs(self.scdata.arena_team_member) do
            if team_data.pos == 2 then
                team_data.pos = 3
            elseif team_data.pos == 3 then
                team_data.pos = 2
            end
        end
    end
    self:updateMyselfInfo(self.scdata)
end

function ArenateamFightTips:close_callback(  )
    SysEnv:getInstance():set(SysEnv.keys.arenateam_skip_fight, self.is_skip_fight, true)
     if self.my_head_list then
        for i,item in ipairs(self.my_head_list) do
            item:DeleteMe()
        end
        self.my_head_list = {}
    end
    if self.role_head_list then
        for i,item in ipairs(self.role_head_list) do
            item:DeleteMe()
        end
        self.role_head_list = {}
    end
    if self.hero_item_list then
        for k,item in pairs(self.hero_item_list) do
            item:DeleteMe()
        end
        self.hero_item_list = nil
    end
    if self.my_hero_item_list then
        for k,list in pairs(self.my_hero_item_list) do
            for i,item in ipairs(list) do
                item:DeleteMe()
            end
        end
        self.my_hero_item_list = nil
    end
    controller:openArenateamFightTips(false)
end