-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      队伍布阵
-- <br/> 2019年10月11日
-- --------------------------------------------------------------------
ArenateamFormPanel = ArenateamFormPanel or BaseClass(BaseView)

local controller = ArenateamController:getInstance()
local model = ArenateamController:getInstance():getModel()
local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort


function ArenateamFormPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Big 
    self.is_full_screen = false
    self.layout_name = "arenateam/arenateam_form_panel"

    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("arenateam","arenateam"), type = ResourcesType.plist },
    }
end

function ArenateamFormPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 1)
    self.main_panel = self.main_container:getChildByName("main_panel")

    self.title = self.main_panel:getChildByName("win_title")
    self.title:setString(TI18N("组队布阵"))

    self.close_btn = self.main_panel:getChildByName("close_btn")

    self.main_container:getChildByName("tips"):setString(TI18N("队长可在该界面调整玩家出战顺序"))
    
    self.left_btn = self.main_container:getChildByName("left_btn")
    self.left_btn:getChildByName("label"):setString(TI18N("个人布阵"))
    self.right_btn = self.main_container:getChildByName("right_btn")
    self.right_btn:getChildByName("label"):setString(TI18N("保存调整"))

    self.chang_12_btn = self.main_container:getChildByName("chang_12_btn")
    self.chang_23_btn = self.main_container:getChildByName("chang_23_btn")


    self.form_item_list = {}
    for i=1,3 do
        local form_item = {}
        local form_item_obj = self.main_container:getChildByName("form_item_"..i)
        form_item.form_item_obj = form_item_obj
        form_item.equip_btn = form_item_obj:getChildByName("equip_btn")
        form_item.elfin_btn = form_item_obj:getChildByName("elfin_btn")
        form_item.team_name = form_item_obj:getChildByName("team_name")
        form_item.power = form_item_obj:getChildByName("power")
        form_item.checkbox = form_item_obj:getChildByName("checkbox")
        form_item.checkbox:getChildByName("name"):setString(TI18N("隐藏队伍"))
        form_item.checkbox:setSelected(false)
        --神器
        local size = form_item.equip_btn:getContentSize()
        form_item.hallows_item = BackPackItem.new(false, false, false, 0.8)
        -- form_item.hallows_item:showAddIcon(true)
        form_item.hallows_item:setPosition(cc.p(size.width * 0.5, size.height * 0.5))
        form_item.equip_btn:addChild(form_item.hallows_item)
        --精灵
        form_item.elfin_item_list = {}
        --宝可梦
        form_item.pos_list = {}
        form_item.hero_item_list = {}
        for i=1,9 do
            local item_bg = form_item_obj:getChildByName("left_hero_bg_"..i)
            local x, y = item_bg:getPosition()
            form_item.pos_list[i] = cc.p(x, y)
            --item_bg:setVisible(false)
        end

        self.form_item_list[i] = form_item
    end
end

function ArenateamFormPanel:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickBtnClose) ,false, 2)
    registerButtonEventListener(self.close_btn, handler(self, self.onClickBtnClose) ,true, 2)
    registerButtonEventListener(self.left_btn, handler(self, self.onClickBtnLeft) ,true, 1)
    registerButtonEventListener(self.right_btn, handler(self, self.onClickBtnRight) ,true, 1)

    registerButtonEventListener(self.chang_12_btn, function() self:onChangeTeam(1,2) end ,true, 1)
    registerButtonEventListener(self.chang_23_btn, function() self:onChangeTeam(2,3) end ,true, 1)

    for i,form_item in ipairs(self.form_item_list) do
        -- registerButtonEventListener(form_item.equip_btn, function() self:onEquipBtn(i) end ,true, 1)
        -- registerButtonEventListener(form_item.elfin_btn, function() self:onElfinBtn(i) end ,false, 1)
        --跳过战斗
        form_item.checkbox:addTouchEventListener(function ( sender,event_type )
            if event_type == ccui.TouchEventType.began then
                playButtonSound2()
                form_item.check_box_status = form_item.checkbox:isSelected()
            elseif event_type == ccui.TouchEventType.ended then
                if not model:isLeader() then
                    message(TI18N("只有队长可进行该操作"))
                    form_item.checkbox:setSelected(form_item.check_box_status or false)
                    return
                end
                for k,item in ipairs(self.form_item_list) do
                    if item == form_item then
                        if self.form_data_list and self.form_data_list[k] then
                            self.form_data_list[k].is_hide = 1
                        end
                        item.checkbox:setSelected(true)
                    else
                        if self.form_data_list and self.form_data_list[k] then
                            self.form_data_list[k].is_hide = 0
                        end
                        item.checkbox:setSelected(false)
                    end
                end
            elseif event_type == ccui.TouchEventType.canceled then
                form_item.checkbox:setSelected(form_item.check_box_status or false)
            end
        end)
    end

    self:addGlobalEvent(ArenateamEvent.ARENATEAM_THREE_TEAM_INFO_EVENT, function(scdata)
        if not scdata then return end
        self:setScdata(scdata)
    end)
    self:addGlobalEvent(ArenateamEvent.ARENATEAM_REFRESH_TEAM_INFO_EVENT, function()
        self.is_refresh_team = true
        controller:sender27243()
    end)

        -- -- 阵容数据变化
    self:addGlobalEvent(ArenateamEvent.ARENATEAM_SAVE_FROM_EVENT, function ( data )
        if not data then return end
        message(data.msg)
        if self.from_type and self.from_type == 2 then
            self:onClickBtnClose()
            controller:sender27221()
        end
    end)
end

--交换队伍顺序
function ArenateamFormPanel:onChangeTeam(index1, index2)
    if not model:isLeader() then
        message(TI18N("只有队长可进行该操作"))
        return
    end

    if not self.form_data_list then return end
    local form_item_1 = self.form_item_list[index1]
    local form_item_2 = self.form_item_list[index2]

    local temp_data  = self.form_data_list[index1]
    self.form_data_list[index1] = self.form_data_list[index2]
    self.form_data_list[index2] = temp_data

    if self.form_data_list[index1] then
        self.form_data_list[index1].pos = index1
    end
    if self.form_data_list[index2] then
        self.form_data_list[index2].pos = index2
    end

    self:updateFormItem(form_item_1, index1)
    self:updateFormItem(form_item_2, index2)
end

--个人布阵
function ArenateamFormPanel:onClickBtnLeft()
    if not self.form_data_list then return end
    HeroController:getInstance():openFormGoFightPanel(true, PartnerConst.Fun_Form.ArenaTeam, {}, HeroConst.FormShowType.eFormSave)
end


--保存调整
function ArenateamFormPanel:onClickBtnRight()
    if not self.form_data_list then return end
    local pos_info = {}
    for i,v in pairs(self.form_data_list) do
        local data = {}
        data.rid = v.rid
        data.sid = v.sid
        data.pos = v.pos
        data.is_hide = v.is_hide
        table_insert(pos_info, data)
    end
    controller:sender27242(pos_info)
end

--关闭
function ArenateamFormPanel:onClickBtnClose()
    controller:openArenateamFormPanel(false)
end

function ArenateamFormPanel:openRootWnd(setting)
    local setting = setting or {}
    self.from_type = setting.from_type or 1
    controller:sender27243()
end
function ArenateamFormPanel:setScdata(scdata)
    if self.is_refresh_team and self.form_data_list then
        self.is_refresh_team = nil
        local role_vo = RoleController:getInstance():getRoleVo()
        --先从最新数据找到自己的信息
        local new_data = nil
        for i,v in ipairs(scdata.arena_team_member) do
            if role_vo and role_vo.rid == v.rid and role_vo.srv_id == v.sid then
                new_data = v
            end
        end 
        --在更新自己的信息
        for i,v in pairs(self.form_data_list) do
            if new_data and role_vo and role_vo.rid == v.rid and role_vo.srv_id == v.sid then
                --自己的队伍
                new_data.is_hide = v.is_hide
                self.form_data_list[i] = new_data
                if self.form_item_list[i] then
                    self:updateFormItem(self.form_item_list[i], i)
                end
                break
            end
        end   
    else
        self.form_data_list = {}
        for i,v in ipairs(scdata.arena_team_member) do
            self.form_data_list[v.pos] = v
        end    

        for i,form_item in ipairs(self.form_item_list) do
            delayRun(self.main_container, i*2 / display.DEFAULT_FPS, function (  )
                self:updateFormItem(form_item, i)
            end)
        end
    end
end

function ArenateamFormPanel:updateFormItem(form_item, i)
    if not self.form_data_list then return end
    local data = self.form_data_list[i]
    if data then
        form_item.team_name:setString(data.name)
        form_item.power:setString(data.power)
        self:updateFormItemInfo(form_item, data.team_partner, data.formation_type, data.rid, data.sid)
        local look_id = 0

        for i,v in ipairs(data.ext) do
            if v.extra_key == 5 then --幻化神器id
                look_id = v.extra_val or 0
            end
        end
        self:updateHallowsIcon(form_item, data.hallows_id, look_id) 
        self:updateElfinList(form_item, data.sprites) 
        if data.is_hide == 1 then 
            form_item.checkbox:setSelected(true)
        else
            form_item.checkbox:setSelected(false)
        end
    else
        form_item.team_name:setString(TI18N("无队员"))
        form_item.power:setString(0)
        self:updateFormItemInfo(form_item, {}, 1)
        self:updateHallowsIcon(form_item, 0, 0) 
        self:updateElfinList(form_item, {}) 
        form_item.checkbox:setSelected(false)
    end
end
--更新布阵
function ArenateamFormPanel:updateFormItemInfo(form_item, pos_info, formation_type, rid, srv_id)
    if not form_item then return end
    local formation_config = Config.FormationData.data_form_data[formation_type]
    if formation_config then

        --转换位置信息
        local dic_pos_info = {}
        for k,v in pairs(pos_info) do
            dic_pos_info[v.pos] = v
        end

        for k,hero_item in pairs(form_item.hero_item_list) do
            hero_item:setVisible(false)
        end

        for i,v in ipairs(formation_config.pos) do
            local index = v[1] 
            local pos = v[2] 
            local hero_vo = dic_pos_info[index]
            --更新位置
            if form_item.hero_item_list[index] == nil then
                form_item.hero_item_list[index] = HeroExhibitionItem.new(0.5, false)
                form_item.form_item_obj:addChild(form_item.hero_item_list[index])
            else
                form_item.hero_item_list[index]:setVisible(true)
            end
            form_item.hero_item_list[index]:setPosition(form_item.pos_list[pos])
            
            if hero_vo then
                hero_vo.use_skin = hero_vo.skin_id
                form_item.hero_item_list[index]:setData(hero_vo)
                form_item.hero_item_list[index]:addCallBack(function()
                    -- if rid and srv_id then
                    --     ArenaController:getInstance():requestRabotInfo(rid, srv_id, index)
                    -- end
                end)
            else
                form_item.hero_item_list[index]:setData(nil)
            end
        end
    end
end

--更新神器
function ArenateamFormPanel:updateHallowsIcon(form_item, hallows_id, look_id)
    if not form_item then return end
    local hallows_id = hallows_id or 0
    if hallows_id == 0 then
        form_item.hallows_item:setBaseData()
        form_item.hallows_item:setMagicIcon(false)
    else
        local hallows_config = Config.HallowsData.data_base[hallows_id]
        if not hallows_config  then return end

        if look_id and look_id ~= 0 then
            local magic_cfg = Config.HallowsData.data_magic[look_id]
            if magic_cfg then
                form_item.hallows_item:setBaseData(magic_cfg.item_id)
                form_item.hallows_item:setMagicIcon(true)
            else
                form_item.hallows_item:setBaseData(hallows_config.item_id)
                form_item.hallows_item:setMagicIcon(false)
            end
        else
            form_item.hallows_item:setBaseData(hallows_config.item_id)
            form_item.hallows_item:setMagicIcon(false)
        end
    end
end

-- 更新精灵
function ArenateamFormPanel:updateElfinList(form_item, elfin_bid_list)
    if not form_item then return end
    if not form_item.elfin_btn then return end
    -- local elfin_bid_list = ElfinController:getInstance():getModel():getElfinTreeElfinList() or {}
    local function getElfinBidByPos( pos )
        local elfin_bid
        for k,v in pairs(elfin_bid_list) do
            if v.pos == pos then
                elfin_bid = v.item_bid
                break
            end
        end
        return elfin_bid
    end
    for i=1,4 do
        local elfin_bid = getElfinBidByPos(i)
        local elfin_item = form_item.elfin_item_list[i]
        if elfin_item == nil then
            elfin_item = SkillItem.new(true, false, true, 0.4)
            local pos_x = 24.3
            local pos_y = 72.5
            if i == 3 or i == 4 then
                pos_y = 24.3
            end
            if i == 2 or i == 4 then
                pos_x = 72.5
            end
            elfin_item:setPosition(cc.p(pos_x + 8, pos_y + 5))
            form_item.elfin_btn:addChild(elfin_item)
            form_item.elfin_item_list[i] = elfin_item
        end
        if elfin_bid then
            elfin_item:showLockIcon(false)
            local elfin_cfg = Config.SpriteData.data_elfin_data(elfin_bid)
            if elfin_bid == 0 or not elfin_cfg then -- 已解锁，但未放置精灵
                elfin_item:setData()
            else
                local skill_cfg = Config.SkillData.data_get_skill(elfin_cfg.skill)
                if skill_cfg then
                    elfin_item:setData(skill_cfg)
                end
            end
        else
            elfin_item:setData()
            elfin_item:showLockIcon(true)
        end
    end
end

function ArenateamFormPanel:close_callback()
    controller:openArenateamFormPanel(false)
end