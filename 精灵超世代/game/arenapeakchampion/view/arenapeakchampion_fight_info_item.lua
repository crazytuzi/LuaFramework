-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      巅峰冠军赛 双方阵容战斗信息 对战详情 子项
-- <br/> 2019年11月19日
-- ---------------------------------------------------------------------
ArenapeakchampionFightInfoItem = class("ArenapeakchampionFightInfoItem", function()
    return ccui.Widget:create()
end)

local string_format = string.format

function ArenapeakchampionFightInfoItem:ctor(width, height)
    self:configUI(width, height)
    self:register_event()
end

function ArenapeakchampionFightInfoItem:configUI( width, height )
    self.size = cc.size(width, height)
    self:setTouchEnabled(true)
    self:setContentSize(self.size)

    local csbPath = PathTool.getTargetCSB("arenapeakchampion/arenapeakchampion_fight_info_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    local container = self.root_wnd:getChildByName("container")
    self.container = container

    local _getItem = function(prefix)
        local item = {}
        item.team_name = container:getChildByName(prefix.."team_name")
        item.fight_count = container:getChildByName(prefix.."fight_count")
        item.wenhao = container:getChildByName(prefix.."wenhao")
        item.equip_node = container:getChildByName(prefix.."equip_node") --圣器信息
        item.elfin_key = container:getChildByName(prefix.."elfin_key")
        item.elfin_key:setString(TI18N("古树"))
        item.elfin_lev = container:getChildByName(prefix.."elfin_lev")
        item.panel_elfin = container:getChildByName(prefix.."panel_elfin")
        item.elfin_list = {}

        item.pos_list = {}
        item.hero_item_list = {}
        for i=1,9 do
            local item_bg = container:getChildByName(prefix.."hero_bg_"..i)
            local x, y = item_bg:getPosition()
            item.pos_list[i] = cc.p(x, y)
        end
        return item
    end
    self.left_item = _getItem("left_")
    self.right_item = _getItem("right_")
end

function ArenapeakchampionFightInfoItem:register_event( )
    -- registerButtonEventListener(self.play_btn, handler(self, self.onClickPlayBtn) ,true, 2)
end

function ArenapeakchampionFightInfoItem:setData(data, a_is_hide, b_is_hide)
    if not data then return end
    self.data = data
    
    --左右
    local order = data.a_order
    local power = data.a_power 
    local pos_info = data.a_plist 
    local formation_type = data.a_formation_type
    local rid = data.rid
    local srv_id = data.srv_id 
    local tree_lv = data.a_tree_lv or 0
    local sprite_data = data.a_sprite_data or {}
    local hallows_id = data.a_hallows_id or 0
    local hallows_look_id = data.a_hallows_look_id or 0

    local is_hide = a_is_hide or false
    self:initItemInfo(self.left_item, order, name, power, pos_info,formation_type, rid, srv_id, tree_lv, sprite_data, hallows_id, hallows_look_id, is_hide)

    local order = data.b_order
    local power = data.b_power 
    local pos_info = data.b_plist 
    local formation_type = data.b_formation_type
    local rid = data.b_rid
    local srv_id = data.b_srv_id 
    local tree_lv = data.b_tree_lv or 0
    local sprite_data = data.b_sprite_data or {}
    local hallows_id = data.b_hallows_id or 0
    local hallows_look_id = data.b_hallows_look_id or 0

    local is_hide = b_is_hide or false
    self:initItemInfo(self.right_item, order, name, power, pos_info,formation_type, rid, srv_id, tree_lv, sprite_data, hallows_id, hallows_look_id, is_hide)
end

function ArenapeakchampionFightInfoItem:initItemInfo(item, order, name, power, pos_info,formation_type, rid, srv_id, tree_lv, sprite_data, hallows_id, hallows_look_id, is_hide)
    local str =  string_format("[%s%s]", TI18N("队伍"), order)
    item.team_name:setString(str)

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
function ArenapeakchampionFightInfoItem:updateHallowsIcon(item, hallows_id, look_id)
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
function ArenapeakchampionFightInfoItem:getElfinBidByPos( sprite_data, pos )
    if not sprite_data or next(sprite_data) == nil then return end
    for k,v in pairs(sprite_data) do
        if v.pos == pos then
            return v.item_bid
        end
    end
end

function ArenapeakchampionFightInfoItem:setElfinSkillItemData( skill_item, sprite_data, pos )
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


function ArenapeakchampionFightInfoItem:updateHeroInfo(item, pos_info, formation_type, rid, srv_id, is_hide)
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
                local hero_vo = dic_pos_info[pos]
                if hero_vo and hero_vo.ext then
                    for i,v in ipairs(hero_vo.ext) do
                        if v.key == 5 then
                            hero_vo.use_skin = v.val
                        end
                    end
                end
                --更新位置
                if item.hero_item_list[index] == nil then
                    item.hero_item_list[index] = HeroExhibitionItem.new(0.5, false)
                    self.container:addChild(item.hero_item_list[index])
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

function ArenapeakchampionFightInfoItem:DeleteMe( )
    if self.item_list then
        for i,v in ipairs(self.item_list) do
            v:DeleteMe()
        end
    end
    if self.item_load then
        self.item_load:DeleteMe()
        self.item_load = nil
    end

    if self.left_item and self.left_item.elfin_list and next(self.left_item.elfin_list) ~= nil then
        for i,v in pairs(self.left_item.elfin_list) do
            v:DeleteMe()
        end
        self.left_item.elfin_list = {}
    end
    if self.right_item and self.right_item.elfin_list and next(self.right_item.elfin_list) ~= nil then
        for i,v in pairs(self.right_item.elfin_list) do
            v:DeleteMe()
        end
        self.right_item.elfin_list = {}
    end
    self:removeAllChildren()
    self:removeFromParent()
end