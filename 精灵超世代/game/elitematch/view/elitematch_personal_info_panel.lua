 -- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      精英赛个人战绩
-- <br/> 2019年3月6日
-- --------------------------------------------------------------------
ElitematchPersonalInfoPanel = ElitematchPersonalInfoPanel or BaseClass(BaseView)

local controller = ElitematchController:getInstance()
local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort


function ElitematchPersonalInfoPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Mini   
    self.is_full_screen = false
    self.layout_name = "elitematch/elitematch_personal_info_panel"

    self.res_list = {
        -- { path = PathTool.getPlistImgForDownLoad("vedio","vedio"), type = ResourcesType.plist },
    }
    --总记录
    self.record_data = nil
    --个人记录
    self.personal_record_list= {}
end

function ElitematchPersonalInfoPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 2)
    self.main_panel = self.main_container:getChildByName("main_panel")

    self.tab_container = self.main_panel:getChildByName("tab_container")
    local tab_name_list = {
        [1] = TI18N("总战绩"),
        [2] = TI18N("赛季战绩")
    }
    self.tab_list = {}
    for i=1,2 do
        local tab_btn = self.tab_container:getChildByName("tab_btn_"..i)
        if tab_btn then
            local object = {}
            object.select_bg = tab_btn:getChildByName('select_bg')
            object.select_bg:setVisible(false)
            object.unselect_bg = tab_btn:getChildByName('unselect_bg')
            object.title = tab_btn:getChildByName("title")
            --object.title:setTextColor(cc.c4b(0xcf, 0xb5, 0x93, 0xff))
            if tab_name_list[i] then
                object.title:setString(tab_name_list[i])
            end
            object.tab_btn = tab_btn
            object.index = i
            self.tab_list[i] = object
        end
    end
    self.title = self.main_panel:getChildByName("win_title")
    self.title:setString(TI18N("个人战绩"))

    self.panel = self.main_panel:getChildByName("panel")

    local key_left_list = {
        [1] = TI18N("当前段位:"),
        [2] = TI18N("历史最高段位:"),
        [3] = TI18N("所在赛区:"),
        [4] = TI18N("常规赛胜场:"),
        [5] = TI18N("常规赛胜率:"),
        [6] = TI18N("单场最高伤害:"),
        [7] = TI18N("mvp次数最多宝可梦:")
    }

    local key_right_list = {
        [1] = TI18N("当前积分:"),
        [2] = TI18N("历史最高积分:"),
        [3] = TI18N("赛季排名:"),
        [4] = TI18N("王者赛胜场:"),
        [5] = TI18N("王者赛胜率:"),
        [6] = TI18N("最大连胜场数:"),
        [7] = TI18N("最强对手:"),
    }
    self.left_value_list = {}
    self.right_value_list = {}
    for i=1,7 do
        local key_label = self.panel:getChildByName("key_label_"..i)
        if key_left_list[i] then
            key_label:setString(key_left_list[i])
        end
        local key_label_right = self.panel:getChildByName("key_label_right_"..i)
        if key_right_list[i] then
            key_label_right:setString(key_right_list[i])
        end
        if i ~= 7 then
            self.left_value_list[i] = self.panel:getChildByName("key_value_"..i)
            self.right_value_list[i] = self.panel:getChildByName("key_value_right_"..i)
        end
    end


    self.hero_name = self.panel:getChildByName("hero_name")
    self.player_name = self.panel:getChildByName("player_name")
    self.team_name1 = self.panel:getChildByName("team_name1")
    self.team_name1:setString(TI18N("队1"))
    self.team_name2 = self.panel:getChildByName("team_name2")
    self.team_name2:setString(TI18N("队2"))
    self.team_power1 = self.panel:getChildByName("team_power1")
    self.team_power2 = self.panel:getChildByName("team_power2")
    self.match_name = self.panel:getChildByName("match_name")

    self.panel_bg_1_1_0 = self.panel:getChildByName("panel_bg_1_1_0")
    self.Image_32 = self.panel:getChildByName("Image_32")
    self.Image_33 = self.panel:getChildByName("Image_33")
    self.Sprite_16 = self.panel:getChildByName("Sprite_16")
    self.Sprite_17 = self.panel:getChildByName("Sprite_17")

    self.hero_no_tips = self.panel:getChildByName("hero_no_tips")
    self.hero_no_tips:setString(TI18N("暂无"))
    self.player_no_tips = self.panel:getChildByName("player_no_tips")
    self.player_no_tips:setString(TI18N("暂无"))


    self.left_btn = self.main_panel:getChildByName("left_btn")
    self.right_btn = self.main_panel:getChildByName("right_btn")
    self.comfirm_btn = self.main_panel:getChildByName("comfirm_btn")
    self.comfirm_btn:getChildByName("label"):setString(TI18N("分享"))

    self.hero_item = HeroExhibitionItem.new(0.9, false)
    self.hero_item:setPosition(132, 36)
    self.panel:addChild(self.hero_item)

    self.player_head = PlayerHead.new(PlayerHead.type.circle)
    self.player_head:setPosition(386, 50)
    self.panel:addChild(self.player_head)    
end

function ElitematchPersonalInfoPanel:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickBtnClose) ,false, 2)
    registerButtonEventListener(self.left_btn, handler(self, self.onClickBtnLeft) ,true, 1)
    registerButtonEventListener(self.right_btn, handler(self, self.onClickBtnRight) ,true, 1)

    registerButtonEventListener(self.comfirm_btn, function ( param, sender )
        local world_pos = sender:convertToWorldSpace(cc.p(0.5, 0.5))
        self:onClickBtnComfirm(world_pos)
    end, true, 1)

    for k, object in pairs(self.tab_list) do
        if object.tab_btn then
            object.tab_btn:addTouchEventListener(function(sender, event_type)
                if event_type == ccui.TouchEventType.ended then
                    playTabButtonSound()
                    self:changeSelectedTab(object.index)
                end
            end)
        end
    end

    self.player_head:addCallBack(function()
        if not self.rid then return end
        if self.rid == 0 then return end
        FriendController:getInstance():openFriendCheckPanel(true, {srv_id = self.srv_id, rid = self.rid})
    end)

    self:addGlobalEvent(ElitematchEvent.Elite_Personal_Info_Event, function(data)
        if not data then return end
        if data.period == 0 then
            --所有赛季的
            self.record_data = data
            if self.index == 1 then
                self:initPanel(data)
            end
        else
            self.personal_record_list[data.period] = data
            if self.index == 2  and data.period == self.select_period then
                self:initPanel(data)
            end
        end
    end)
    self:addGlobalEvent(ElitematchEvent.Elite_Personal_Info_Event2, function(data)
        if not data then return end
        if data.period == 0 then
            --所有赛季的
            self.record_data = data
            if self.index == 1 then
                self:initPanel(data)
            end
        else
            self.personal_record_list[data.period] = data
            if self.index == 2  and data.period == self.select_period then
                self:initPanel(data)
            end
        end
    end)
end

--关闭
function ElitematchPersonalInfoPanel:onClickBtnClose()
    -- self:showSharePanel(false)
    controller:openElitematchPersonalInfoPanel(false)
end
--分享
function ElitematchPersonalInfoPanel:onClickBtnComfirm(world_pos)
    local callback = function(btn_type, setting)
        if not btn_type then return end
        if self.root_wnd and (not tolua.isnull(self.root_wnd)) then
            if btn_type == HeroConst.ShareBtnType.eHeroShareCross then
                --跨服频道
                controller:sender24941(ChatConst.Channel.Cross)
            elseif btn_type == HeroConst.ShareBtnType.eHeroShareWorld then
                --世界频道
                controller:sender24941(ChatConst.Channel.World)
            elseif btn_type == HeroConst.ShareBtnType.eHeroShareGuild then
                --公会频道
                controller:sender24941(ChatConst.Channel.Gang)
            end
        end
    end
    HeroController:getInstance():openHeroSharePanel(true, world_pos, callback, {offsetx = 230, offsety = 60})
end

--左
function ElitematchPersonalInfoPanel:onClickBtnLeft()
    if not self.select_period then return end
    self.select_period = self.select_period - 1
    if self.select_period <= 1 then
        self.select_period = 1
    end
    self:setTitle(self.select_period)
    self:setBtnShowStatus()
    self:updateData() 
end
--右
function ElitematchPersonalInfoPanel:onClickBtnRight()
    if not self.select_period then return end
    self.select_period = self.select_period + 1
    if self.select_period >= self.max_period then
        self.select_period = self.max_period
    end
    self:setTitle(self.select_period)
    self:setBtnShowStatus()
    self:updateData()
end

--设置按钮状态
function ElitematchPersonalInfoPanel:setBtnShowStatus()
    if not self.select_period then return end
    if self.max_period == 1 then
        self.left_btn:setVisible(false)
        self.right_btn:setVisible(false) 
        return 
    end
    if self.select_period == 1 then
        self.left_btn:setVisible(false)
        self.right_btn:setVisible(true) 
    elseif self.select_period == self.max_period then
        self.left_btn:setVisible(true)
        self.right_btn:setVisible(false) 
    else
        self.left_btn:setVisible(true)
        self.right_btn:setVisible(true)
    end
end


-- 切换标签页
function ElitematchPersonalInfoPanel:changeSelectedTab( index )
    if self.tab_object ~= nil and self.tab_object.index == index then return end
    if self.tab_object then
        self.tab_object.select_bg:setVisible(false)
        self.tab_object.title:setTextColor(Config.ColorData.data_new_color4[6])
        self.tab_object.title:disableEffect(cc.LabelEffect.SHADOW)
        self.tab_object = nil
    end
    self.tab_object = self.tab_list[index]
    if self.tab_object then
        self.tab_object.select_bg:setVisible(true)
        self.tab_object.title:setTextColor(Config.ColorData.data_new_color4[1])
        self.tab_object.title:enableShadow(Config.ColorData.data_new_color4[2],cc.size(0, -2),2)
    end
    self.index = index

    if not self.select_period then return end

    if index == 1 then
        self:setTitle()
        self.left_btn:setVisible(false)
        self.right_btn:setVisible(false)
        if self.record_data == nil then
            self:senderProto(0)
        else
            self:initPanel(self.record_data)
        end
    else
        self:setTitle(self.select_period)
        self:setBtnShowStatus()
        self:updateData()
    end
end

function ElitematchPersonalInfoPanel:senderProto(period)
     if self.is_share then
        if not self.id then return end
        if not self.share_srv_id then return end
        controller:sender24942(self.id, self.share_srv_id, period)
    else
        controller:sender24940(period)
    end
end

--@rid 个人id
--@svr_id 服务器id
function ElitematchPersonalInfoPanel:openRootWnd(period, elite_data)
    -- if not rid then return end
    -- if not svr_id then return end
    if not period then return end

    if elite_data then
        self.id = elite_data.id
        self.share_srv_id = elite_data.share_srv_id
        self.is_share = true
    end
    self.max_period = period
    self.select_period = period
    self:setTitle(period)
    
    if period == 0 then
        self:changeSelectedTab(1)
    else
        self:changeSelectedTab(2)
    end
    if self.is_share then
        self.comfirm_btn:setVisible(false)
    end
end

function ElitematchPersonalInfoPanel:updateData()
    if not self.select_period then return end
    if self.personal_record_list[self.select_period] then
        self:initPanel(self.personal_record_list[self.select_period])
    else
        self:senderProto(self.select_period)
    end
end


function ElitematchPersonalInfoPanel:setTitle(period)
    local str
    if period == nil then
        str = TI18N("总战绩")
    else
        str = string_format(TI18N("第S%s赛季"), period)
    end
    self.match_name:setString(str)
end

function ElitematchPersonalInfoPanel:initPanel(data)

    local config  = Config.ArenaEliteData.data_elite_level[data.my_elite_lev]
    if config then
        self.left_value_list[1]:setString(config.name) --当前段位
    else
        self.left_value_list[1]:setString(TI18N("暂无")) --当前段位
    end
    local config  = Config.ArenaEliteData.data_elite_level[data.max_lev]
    if config then
        self.left_value_list[2]:setString(config.name) --历史最高段位
    end
    self.left_value_list[4]:setString(data.combat_win_count1)--常规赛胜场
    local count
    if data.combat_all_count1 ~= 0 then
        count = math.floor(data.combat_win_count1 * 100 / data.combat_all_count1)
    else
        count = 0
    end
    --所在赛区： 无  
    if data.log_zone_id == 0 then
        self.left_value_list[3]:setString(TI18N("无"))
    else
        local config = Config.ArenaEliteData.data_zone[data.log_zone_id]
        if config then
            self.left_value_list[3]:setString(config.name..TI18N("赛区"))
        else
            self.left_value_list[3]:setString(TI18N("无"))
        end
    end
    --赛季排名： 无 
    if data.log_rank == 0 then
        self.right_value_list[3]:setString(TI18N("无"))--常规赛胜场
    else
        self.right_value_list[3]:setString(data.log_rank)--常规赛胜场
    end


    self.left_value_list[5]:setString(count.."%")--常规赛胜率
    self.left_value_list[6]:setString(data.max_dps) --单场最高伤害

    self.right_value_list[1]:setString(data.my_score) --当前积分
    self.right_value_list[2]:setString(data.max_score)--历史最高积分
    self.right_value_list[4]:setString(data.combat_win_count2) --王者赛总胜场
     if data.combat_all_count2 ~= 0 then
        count = math.floor(data.combat_win_count2 * 100 / data.combat_all_count2)
    else
        count = 0
    end
    self.right_value_list[5]:setString(count.."%")
    self.right_value_list[6]:setString(data.winning_streak)


    self.team_power1:setString("0")
    self.team_power2:setString("0")
    for i,v in ipairs(data.power) do
        if v.order == 1 then
            self.team_power1:setString(v.power)
        else
            self.team_power2:setString(v.power)
        end
    end
    local partner_config = Config.PartnerData.data_partner_base[data.best_mvp]
    if partner_config then
        self.hero_name:setVisible(true)
        self.hero_item:setVisible(true)
        self.hero_no_tips:setVisible(false)

         local star = partner_config.init_star or 1

        if data.use_skin and data.use_skin ~= 0 then
            local skin_config = Config.PartnerSkinData.data_skin_info[data.use_skin]
            if skin_config then
                self.hero_item:setHeadImg(skin_config.head_id)
            end
        else
            local key = getNorKey(partner_config.bid, star)
            local star_config = Config.PartnerData.data_partner_star(key)
            if star_config then
                self.hero_item:setHeadImg(star_config.head_id)
            end
        end

        -- 设置品质框
        self.hero_item:setQualityImg(partner_config.init_star)
        -- 设置阵营
        self.hero_item:setCampImg(partner_config.camp_type)

        self.hero_name:setString(partner_config.name)
    else
        self.hero_name:setVisible(false)
        self.hero_item:setVisible(false)
        self.hero_no_tips:setVisible(true)
    end

    if data.name == nil or data.name == "" then
        self:setRightVisible(false)
        self.rid = 0
    else
        self.rid = data.rid
        self.srv_id = data.srv_id
        self:setRightVisible(true)
        local srv_name = getServerName(data.srv_id)
        self.player_name:setString(string_format("[%s]%s", srv_name, data.name))
        self.player_head:setHeadRes(data.face, false, LOADTEXT_TYPE, data.face_file, data.face_update_time)
        self.player_head:setLev(data.lev)
    end
end

function ElitematchPersonalInfoPanel:setRightVisible( status)
    self.panel_bg_1_1_0:setVisible(status)
    self.Image_32:setVisible(status)
    self.Image_33:setVisible(status)
    self.Sprite_16:setVisible(status)
    self.Sprite_17:setVisible(status)
    self.player_head:setVisible(status)
    self.player_name:setVisible(status)
    self.team_power1:setVisible(status)
    self.team_power2:setVisible(status)
    self.team_name1:setVisible(status)
    self.team_name2:setVisible(status)

    self.player_no_tips:setVisible(not status)
end




function ElitematchPersonalInfoPanel:close_callback()
    controller:openElitematchPersonalInfoPanel(false)
end

