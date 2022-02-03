--------------------------------------------
-- @Author  : xhj
-- @Date    : 2020年3月23日
-- @description    : 
        -- 多人竞技场挑战布阵
---------------------------------
local controller = ArenaManyPeopleController:getInstance()
local model = controller:getModel()
local table_insert = table.insert
local string_format = string.format

ArenaManyPeopleFightTips = ArenaManyPeopleFightTips or BaseClass(BaseView)

function ArenaManyPeopleFightTips:__init( )
    self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.is_full_screen = false

    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("vedio", "vedio"), type = ResourcesType.plist},
    }
    self.layout_name = "arenamanypeople/amp_fight_info_panel"
    
    self.left_panel_list = {}
    self.right_panel_list = {}
    
end

function ArenaManyPeopleFightTips:open_callback(  )
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.container = self.root_wnd:getChildByName("main_panel")
    -- 通用进场动效
    ActionHelp.itemUpAction(self.container, 720, 0, 0.25)

    self.btn_challenge = self.container:getChildByName("right_btn")
    self.btn_challenge:getChildByName("label"):setString(TI18N("挑 战"))

    self.container:getChildByName("win_title"):setString(TI18N("挑 战"))
    self.container:getChildByName("tips_1"):setString(TI18N("我方队伍"))
    self.container:getChildByName("tips_2"):setString(TI18N("敌方队伍"))
    
    self.btn_form = self.container:getChildByName("left_btn")
    self.btn_form:getChildByName("label"):setString(TI18N("个人布阵"))

    self.ok_btn = self.container:getChildByName("ok_btn")
    self.ok_btn:getChildByName("label"):setString(TI18N("保存调整"))
    
    self.close_btn = self.container:getChildByName("close_btn")

    self.change_pos_btn_1 = self.container:getChildByName("change_pos_btn_1")
    self.change_pos_btn_2 = self.container:getChildByName("change_pos_btn_2")

    local _getItem = function(prefix,index)
        local item = {}
        item.fight_panel = self.container:getChildByName("fight_" .. index)
        item.team_name = item.fight_panel:getChildByName(prefix.."team_name")
        item.fight_count = item.fight_panel:getChildByName(prefix.."fight_count")
        item.wenhao = item.fight_panel:getChildByName(prefix.."wenhao")
        item.equip_node = item.fight_panel:getChildByName(prefix.."equip_node") --圣器信息
        item.elfin_key = item.fight_panel:getChildByName(prefix.."elfin_key")
        item.elfin_key:setString(TI18N("古树"))
        item.elfin_lev = item.fight_panel:getChildByName(prefix.."elfin_lev")
        item.panel_elfin = item.fight_panel:getChildByName(prefix.."panel_elfin")
        item.elfin_list = {}

        item.pos_list = {}
        item.hero_item_list = {}
        for i=1,9 do
            local item_bg = item.fight_panel:getChildByName(prefix.."hero_bg_"..i)
            local x, y = item_bg:getPosition()
            item.pos_list[i] = cc.p(x, y)
        end
        return item
    end

    for i=1,3 do
        self.left_panel_list[i] = _getItem("left_",i)
        self.right_panel_list[i] = _getItem("right_",i)
    end

    self.step_time = createRichLabel(22, cc.c4b(0xff,0xff,0xff,0xff), cc.p(0.5,0.5), cc.p(342,-20), nil, nil, 600)
    self.container:addChild(self.step_time)
    

end

function ArenaManyPeopleFightTips:register_event(  )
    registerButtonEventListener(self.background, function (  )
        controller:openArenaManyPeopleFightTips(false)
    end, false, 2)
    
    registerButtonEventListener(self.close_btn, function (  )
        controller:openArenaManyPeopleFightTips(false)
    end, true, 2)

    registerButtonEventListener(self.btn_form, function (  )
        HeroController:getInstance():openFormGoFightPanel(true, PartnerConst.Fun_Form.ArenaManyPeople, {}, HeroConst.FormShowType.eFormSave)
    end, true)

    registerButtonEventListener(self.ok_btn, function (  )
        self:onOkBtn()
    end, true)
    
    registerButtonEventListener(self.btn_challenge, function (  ) self:onChallengeBtn() end, true)

    registerButtonEventListener(self.change_pos_btn_1, function (  )
        self:changeTeamDataOrder(1)
    end, true)

    registerButtonEventListener(self.change_pos_btn_2, function (  )
        self:changeTeamDataOrder(2)
    end, true)


    self:addGlobalEvent(ArenaManyPeopleEvent.ARENAMANYPOEPLE_MATCH_MY_EVENT, function (  )
        local data = model:getMatchInfo()
        if not data then return end
        self.data = data
        
        --左右
        self:updateLeftData(data.atk_team_members)
    end)

end

function ArenaManyPeopleFightTips:onChallengeBtn()
    if not self.data then return end
    local pos_info = {}
    for i,v in ipairs(self.data.atk_team_members) do
        local data = {}
        data.rid = v.rid
        data.sid = v.sid
        data.pos = v.pos
        table_insert(pos_info, data)
    end
    controller:sender29019(pos_info)
end

function ArenaManyPeopleFightTips:onOkBtn()
    if not self.data then return end
    local pos_info = {}
    for i,v in ipairs(self.data.atk_team_members) do
        local data = {}
        data.rid = v.rid
        data.sid = v.sid
        data.pos = v.pos
        table_insert(pos_info, data)
    end
    controller:sender29022(pos_info)
    message(TI18N("调整保存成功!"))
end

--提醒 self.data 是敌方队伍信息
--selfl.data 是我放到队伍信息
function ArenaManyPeopleFightTips:openRootWnd( )
    self:setData()
end

--设置倒计时
function ArenaManyPeopleFightTips:setStepTime(less_time)
    local less_time =  less_time or 0
    if tolua.isnull(self.step_time) then
        return
    end
    self.step_time:stopAllActions()
    if less_time > 0 then
        self:setStepTimeFormatString(less_time)
        self.step_time:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1),
            cc.CallFunc:create(function()
                less_time = less_time - 1
                if less_time < 0 then
                    self.step_time:stopAllActions()
                    self.step_time:setString("")
                else
                    self:setStepTimeFormatString(less_time)
                end
            end))))
    else
        self:setStepTimeFormatString(less_time)
    end
end

function ArenaManyPeopleFightTips:setStepTimeFormatString(time)
    local str = string_format(TI18N("<div fontcolor=#7af655 >%s</div>秒后自动进入战斗"), time)
    self.step_time:setString(str)
end

function ArenaManyPeopleFightTips:setData()
    local data = model:getMatchInfo()
    if not data then return end
    self.data = data
    
    --左右
    self:updateLeftData(data.atk_team_members)
    self:updateRightData(data.def_team_members)

    if self.data then
        local time = self.data.end_time - GameNet:getInstance():getTime()
        if time < 0 then
            time = 0 
        end
        self:setStepTime(time)
    end
end

function ArenaManyPeopleFightTips:updateLeftData(scdata)
    for i,v in ipairs(scdata) do
        local item = self.left_panel_list[v.pos]
        local power = v.power 
        local pos_info = v.partner_infos 
        local formation_type = v.formation_type
        local rid = v.rid
        local srv_id = v.sid 
        local tree_lv = v.sprite_lev or 0
        local sprite_data = v.sprites or {}
        local hallows_id = v.hallows_id or 0
        local hallows_look_id = v.hallows_look_id or 0
        local name = v.name or ""
        local is_hide = false
        self:initItemInfo(item, name, power, pos_info,formation_type, rid, srv_id, tree_lv, sprite_data, hallows_id, hallows_look_id, is_hide)
    end
end

function ArenaManyPeopleFightTips:updateRightData(data)
    local index = model:getHideIndex()
    for i,v in ipairs(data) do
        local item = self.right_panel_list[v.pos]
        local power = v.power 
        local pos_info = v.partner_infos 
        local formation_type = v.formation_type
        local rid = v.rid
        local srv_id = v.sid 
        local tree_lv = v.sprite_lev or 0
        local sprite_data = v.sprites or {}
        local hallows_id = v.hallows_id or 0
        local hallows_look_id = v.hallows_look_id or 0
        local name = v.name or ""
        local is_hide = false
        if index and index == i then
            is_hide = true
        end
        self:initItemInfo(item, name, power, pos_info,formation_type, rid, srv_id, tree_lv, sprite_data, hallows_id, hallows_look_id, is_hide)
    end
end

function ArenaManyPeopleFightTips:initItemInfo(item, name, power, pos_info,formation_type, rid, srv_id, tree_lv, sprite_data, hallows_id, hallows_look_id, is_hide)
    item.team_name:setString(name)

    self:updateHeroInfo(item, pos_info, formation_type, rid, srv_id, is_hide)

    if is_hide then
        item.fight_count:setString("?")
        item.elfin_lev:setVisible(false)
        item.elfin_key:setVisible(false)
        item.panel_elfin:setVisible(false)
        item.equip_node:setVisible(false)
    else
        item.elfin_lev:setVisible(true)
        item.elfin_key:setVisible(true)
        item.panel_elfin:setVisible(true)
        item.equip_node:setVisible(true)
        item.fight_count:setString(power)
        item.elfin_lev:setString(string_format(TI18N("%s级"), tree_lv))
        local math_floor = math.floor
        --精灵技能
        local item_width = 34
        for i=1,4 do
            local elfin_item = item.elfin_list[i]
            if not elfin_item then
                elfin_item = SkillItem.new(true, true, true, 0.27, true)
                local pos_x =  item_width * ((i-1)%2) + item_width * 0.5
                local pos_y = 68 - (math_floor((i-1)/2) * item_width + item_width * 0.5)
                elfin_item:setPosition(pos_x, pos_y)
                item.panel_elfin:addChild(elfin_item)
                item.elfin_list[i] = elfin_item
            end
            self:setElfinSkillItemData(elfin_item, sprite_data, i)
        end
        --圣器
        self:updateHallowsIcon(item, hallows_id,hallows_look_id)
    end 
end

--更新神器item
function ArenaManyPeopleFightTips:updateHallowsIcon(item, hallows_id, look_id)
    if not hallows_id  then return end
    if not item  then return end
    
    if item.hallows_item == nil then
        item.hallows_item = BackPackItem.new(false, false, false, 0.5)
        -- item.hallows_item:showAddIcon(true)
        item.equip_node:addChild(item.hallows_item)
    end

    if hallows_id == 0 then
        item.hallows_item:setBaseData()
        item.hallows_item:setMagicIcon(false)
    else
        local hallows_config = Config.HallowsData.data_base[hallows_id]
        if not hallows_config  then return end
        if look_id and look_id ~= 0 then
            local magic_cfg = Config.HallowsData.data_magic[look_id]
            if magic_cfg then
                item.hallows_item:setBaseData(magic_cfg.item_id)
                item.hallows_item:setMagicIcon(true)
            else
                item.hallows_item:setBaseData(hallows_config.item_id)
                item.hallows_item:setMagicIcon(false)
            end
        else
            item.hallows_item:setBaseData(hallows_config.item_id)
            item.hallows_item:setMagicIcon(false)
        end
    end
end
-- 根据位置获取精灵的bid
function ArenaManyPeopleFightTips:getElfinBidByPos( sprite_data, pos )
    if not sprite_data or next(sprite_data) == nil then return end
    for k,v in pairs(sprite_data) do
        if v.pos == pos then
            return v.item_bid
        end
    end
end

function ArenaManyPeopleFightTips:setElfinSkillItemData( skill_item, sprite_data, pos )
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


function ArenaManyPeopleFightTips:updateHeroInfo(item, pos_info, formation_type, rid, srv_id, is_hide)
    if not item then return end

    if is_hide then
        --问号队伍
        for k,item in pairs(item.hero_item_list) do
            item:setVisible(false)
        end
        item.wenhao:setVisible(true)
    else
        item.wenhao:setVisible(false)
        --队伍位置
        local formation_config = Config.FormationData.data_form_data[formation_type]
        if formation_config then

            --转换位置信息
            local dic_pos_info = {}
            if pos_info then
                for k,v in pairs(pos_info) do
                    dic_pos_info[v.pos] = v
                end
            end

            for k,item in pairs(item.hero_item_list) do
                item:setVisible(false)
            end
            
            for i,v in ipairs(formation_config.pos) do
                local index = v[1] 
                local pos = v[2] 
                local hero_vo = dic_pos_info[index]
                
                --更新位置
                if item.hero_item_list[index] == nil then
                    item.hero_item_list[index] = HeroExhibitionItem.new(0.5, false)
                    item.fight_panel:addChild(item.hero_item_list[index])
                else
                    item.hero_item_list[index]:setVisible(true)
                end
                item.hero_item_list[index]:setPosition(item.pos_list[pos])
                
                if hero_vo then
                    item.hero_item_list[index]:setData(hero_vo)
                    item.hero_item_list[index]:addCallBack(function()
                        if rid and srv_id then
                            -- ArenaController:getInstance():requestRabotInfo(rid, srv_id, index)
                        end
                    end)
                else
                    item.hero_item_list[index]:setData(nil)
                end
            end
        end
    end
end

-- 切换阵容
function ArenaManyPeopleFightTips:changeTeamDataOrder( flag )
    if not self.data  then return end
    if flag == 1 then -- 队伍一和队伍二换位置
        for k,team_data in pairs(self.data.atk_team_members) do
            if team_data.pos == 1 then
                team_data.pos = 2
            elseif team_data.pos == 2 then
                team_data.pos = 1
            end
        end
    else -- 队伍二和队伍三换位置
        for k,team_data in pairs(self.data.atk_team_members) do
            if team_data.pos == 2 then
                team_data.pos = 3
            elseif team_data.pos == 3 then
                team_data.pos = 2
            end
        end
    end
    self:updateLeftData(self.data.atk_team_members)
end

function ArenaManyPeopleFightTips:close_callback(  )
    self.step_time:stopAllActions()
    for i,v in ipairs(self.left_panel_list) do
        if v and v.elfin_list and next(v.elfin_list) ~= nil then
            for i,k in pairs(v.elfin_list) do
                k:DeleteMe()
            end
            v.elfin_list = {}
        end

        if v and v.hero_item_list and next(v.hero_item_list) ~= nil then
            for i,k in pairs(v.hero_item_list) do
                k:DeleteMe()
            end
            v.hero_item_list = {}
        end
        
        if v.hallows_item and v.hallows_item.DeleteMe then
            v.hallows_item:DeleteMe()
            v.hallows_item = nil
        end
    end
    
    for i,v in ipairs(self.right_panel_list) do
        if v and v.elfin_list and next(v.elfin_list) ~= nil then
            for i,k in pairs(v.elfin_list) do
                k:DeleteMe()
            end
            v.elfin_list = {}
        end

        if v and v.hero_item_list and next(v.hero_item_list) ~= nil then
            for i,k in pairs(v.hero_item_list) do
                k:DeleteMe()
            end
            v.hero_item_list = {}
        end

        if v.hallows_item and v.hallows_item.DeleteMe then
            v.hallows_item:DeleteMe()
            v.hallows_item = nil
        end
    end

    controller:openArenaManyPeopleFightTips(false)
end