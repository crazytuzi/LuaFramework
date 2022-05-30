-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      巅峰冠军赛主界面 后端 锋林 策划 中建
-- <br/>Create: 2019年11月12日
ArenapeakchampionMainWindow = ArenapeakchampionMainWindow or BaseClass(BaseView)

local controller = ArenapeakchampionController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_sort = table.sort
local table_insert = table.insert
local math_ceil = math.ceil
local math_floor = math.floor

function ArenapeakchampionMainWindow:__init()
    self.win_type = WinType.Full
    self.is_full_screen = true
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("arenapeakchampion", "arenapeak_mian"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("bigbg/elitematch", "elitematch_matching_bg", true), type = ResourcesType.single},
    }
    self.layout_name = "arenapeakchampion/arenapeakchampion_main_window"

    self.vSize = cc.size(108,108)
end

function ArenapeakchampionMainWindow:open_callback(  )
    self.background = self.root_wnd:getChildByName("background")
    local scale = display.getMaxScale() or 1
    self.background:setScale(scale)
    self.background:loadTexture(PathTool.getPlistImgForDownLoad("bigbg/elitematch", "elitematch_matching_bg", true), LOADTEXT_TYPE)


    self.container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(self.container, 1)
    self.container_size = self.container:getContentSize()
    
    self.top_panel = self.container:getChildByName("top_panel")
    self.bottom_panel = self.container:getChildByName("bottom_panel")
    self.close_btn = self.container:getChildByName("close_btn")

    --top
    self.spine_node = self.top_panel:getChildByName("spine_node")
    self:showFlagSpine(true)
    
    --赛区名字
    self.name = self.top_panel:getChildByName("name")
    
    self.shop_btn = self.top_panel:getChildByName("shop_btn")
    self.shop_btn:getChildByName("label"):setString(TI18N("巅峰商店"))
    self.rank_btn = self.top_panel:getChildByName("rank_btn")
    self.rank_btn:getChildByName("label"):setString(TI18N("排行"))
    self.recrod_btn = self.top_panel:getChildByName("recrod_btn")
    self.recrod_btn:getChildByName("label"):setString(TI18N("历史赛季"))

    self.lay_head_list = {}

    local _getHeadInfo = function(lay_head)
        if lay_head then
            local head_data = {}
            head_data.lay_head = lay_head
            head_data.head_node = lay_head:getChildByName("head_node")
            head_data.tip_img = lay_head:getChildByName("tip_img")
            head_data.tip_img:setVisible(false)
            head_data.name_bg = lay_head:getChildByName("name_bg")
            head_data.name = head_data.name_bg:getChildByName("name")
            head_data.name:setString("")
            head_data.srv_name = lay_head:getChildByName("srv_name")
            head_data.srv_name:setString("")
            return head_data
        end
    end
    self.lay_head_list[1] = _getHeadInfo(self.top_panel:getChildByName("lay_head_1"))
    self.lay_head_list[1].title_img = self.lay_head_list[1].lay_head:getChildByName("title_img")
    self.lay_head_list[1].name:setZOrder(2)
    self.head_panel = self.top_panel:getChildByName("head_panel")
    for i=2,8 do
        local lay_head = self.head_panel:getChildByName("lay_head_"..i)
        self.lay_head_list[i] = _getHeadInfo(lay_head)
    end
    for i,v in ipairs(self.lay_head_list) do
        if i == 1 then
            v.head_node:setScale(1.23)
        elseif i > 4 then
            v.head_node:setScale(0.92)
        else
            v.head_node:setScale(1.02)
        end
    end

    --bottom
    self.rank_info = self.bottom_panel:getChildByName("rank_info")

    self.form_btn = self.bottom_panel:getChildByName("form_btn")
    self.form_btn:getChildByName("label"):setString(TI18N("布阵调整"))
    self.report_btn = self.bottom_panel:getChildByName("report_btn")
    self.report_btn:getChildByName("label"):setString(TI18N("我的赛程"))

    self.look_btn = self.bottom_panel:getChildByName("look_btn")

    self.fight_btn = self.bottom_panel:getChildByName("fight_btn")
    self.fight_btn:getChildByName("label"):setString(TI18N("进入大赛"))

    self.zone_btn = self.bottom_panel:getChildByName("zone_btn")
    self.zone_name = self.zone_btn:getChildByName("zone_name")
    self.zone_icon =  self.zone_btn:getChildByName("arenapeakchampion_mian_17_55")
    self.zone_btn:setVisible(false)

    self.bottom_panel:getChildByName("match_key"):setString(TI18N("当前赛程："))
    self.bottom_panel:getChildByName("time_key"):setString(TI18N("赛季时间："))
    self.bottom_panel:getChildByName("condition_key"):setString(TI18N("参与条件："))

    self.match_value = createRichLabel(20, Config.ColorData.data_new_color4[17], cc.p(0, 0.5), cc.p(190,390),nil,nil,1000)
    self.time_value = createRichLabel(20, Config.ColorData.data_new_color4[17], cc.p(0, 0.5), cc.p(190,360),nil,nil,1000)
    self.condition_value = createRichLabel(20, Config.ColorData.data_new_color4[1], cc.p(0, 1), cc.p(190,341),nil,nil,460)
    self.bottom_panel:addChild(self.match_value)
    self.bottom_panel:addChild(self.time_value)
    self.bottom_panel:addChild(self.condition_value)

    local str = ""
    local login_data = LoginController:getInstance():getModel():getLoginData()
    if login_data and login_data.isTry then
        --先行服
        local config = Config.ArenaPeakChampionData.data_const.battle_members1
        if config then
            str = string_format(TI18N("先行服跨服竞技场前%s名,进入巅峰冠军赛的预选赛阶段"), config.val)
        end
    else
        local config = Config.ArenaPeakChampionData.data_const.battle_members
        if config then
            str = string_format(TI18N("跨服竞技场前%s名,进入巅峰冠军赛的预选赛阶段"), config.val)
        end
    end
    self.condition_value:setString(str)
    self:adaptationScreen()
end

--设置适配屏幕
function ArenapeakchampionMainWindow:adaptationScreen()
    --对应主窗口.四面对应xy位置 ..相对位置是self.main_container左下角(0,0)
    local top_y = display.getTop(self.container)
    local bottom_y = display.getBottom(self.container)
    local left_x = display.getLeft(self.container)
    local right_x = display.getRight(self.container)

    local tab_y = self.top_panel:getPositionY()
    self.top_panel:setPositionY(top_y - (self.container_size.height - tab_y))

    local bottom_panel_y = self.bottom_panel:getPositionY()
    self.bottom_panel:setPositionY(bottom_y + bottom_panel_y)
    local close_btn_y = self.close_btn:getPositionY()
    self.close_btn:setPositionY(bottom_y + close_btn_y)

    -- --多出的高度
    local height = (top_y - self.container_size.height) - bottom_y

    local size = self.head_panel:getContentSize()
    self.head_panel:setContentSize(cc.size(size.width, size.height + height))

    for i=2,8 do
        local head_data = self.lay_head_list[i]
        if head_data then
            local pos_y = head_data.lay_head:getPositionY()
            local new_y = (size.height + height) * pos_y/size.height
            head_data.lay_head:setPositionY(new_y)
        end
    end
end


function ArenapeakchampionMainWindow:register_event(  )
    registerButtonEventListener(self.close_btn, handler(self, self.onClickCloseBtn), true, REGISTER_BUTTON_SOUND_CLOSED_TYPY)
    registerButtonEventListener(self.fight_btn, handler(self, self.onClickFightBtn), true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.look_btn, handler(self, self.onClickRuleBtn), true, REGISTER_BUTTON_SOUND_BUTTON_TYPY, nil)
    registerButtonEventListener(self.shop_btn, handler(self, self.onClickShopBtn), true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.rank_btn, handler(self, self.onClickRankBtn), true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
   
    registerButtonEventListener(self.form_btn, handler(self, self.onClickFormBtn), true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.report_btn, handler(self, self.onClickReportBtn), true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.zone_btn, handler(self, self.onClickZoneBtn), false, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    

    for i,head in pairs(self.lay_head_list) do
        registerButtonEventListener(head.lay_head, function() self:onClickHeadBtn(i) end, false, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    end

    -- 主协议信息
    self:addGlobalEvent(ArenapeakchampionEvent.ARENAPEAKCHAMPION_MAIN_EVENT, function(data)
        if not data then return end
        self:setScdata(data)
    end)
    -- 排行协议返回
    self:addGlobalEvent(ArenapeakchampionEvent.ARENAPEAKCHAMPION_CURRENT_RANK_EVENT, function(data)
        if not data then return end
        self:initPeakRankInfo(data)
    end)
    -- 27701
    self:addGlobalEvent(ArenapeakchampionEvent.ARENAPEAKCHAMPION_SINGLE_INFO_EVENT, function(data)
        if not data then return end
        self:setSingleInfo(data)
    end)

    -- 红点
    self:addGlobalEvent(ArenapeakchampionEvent.ARENAPEAKCHAMPION_ALL_RED_POINT_EVENT, function (  )
        self:updateRedPoint()
    end)
end

function ArenapeakchampionMainWindow:updateRedPoint()
    if model:getGuessRedPoint() or model.match_stage_redpoint then
        addRedPointToNodeByStatus(self.fight_btn, true, 0, 5)
    else
        addRedPointToNodeByStatus(self.fight_btn, false, 0, 5)
    end

    if model.my_match_redpoint then
        addRedPointToNodeByStatus(self.report_btn, true, 5, 5)
    else
        addRedPointToNodeByStatus(self.report_btn, false, 5, 5)
    end 

    if model.is_worship_redpoint then
        addRedPointToNodeByStatus(self.rank_btn, true, 5, 5)
    else
        addRedPointToNodeByStatus(self.rank_btn, false, 5, 5)
    end
end

-- 关闭
function ArenapeakchampionMainWindow:onClickCloseBtn(  )
    controller:openArenapeakchampionMainWindow(false)
end

--排行榜
function ArenapeakchampionMainWindow:onClickRankBtn()
    if not self.scdata then return end
    local setting = {}
    setting.rank_type = RankConstant.RankType.arena_peak_champion
    setting.title_name = TI18N("巅峰冠军赛排行榜")
    setting.background_path = PathTool.getPlistImgForDownLoad("bigbg/elitematch", "elitematch_matching_bg",true)
    if self.select_zone_index == nil or  self.zone_list == nil then
        setting.zone_id = self.scdata.zone_id
    else
        if self.zone_list[self.select_zone_index] then
            setting.zone_id = self.zone_list[self.select_zone_index].id
        else
            setting.zone_id = self.scdata.zone_id    
        end
    end
    -- setting.show_tips = TI18N("奖励将在活动结束后通过邮件发放")
    RankController:getInstance():openSingleRankMainWindow(true, setting)
end
--商店
function ArenapeakchampionMainWindow:onClickShopBtn()
    controller:openArenapeakchampionShop()
end
-- -- 打开规则说明
function ArenapeakchampionMainWindow:onClickRuleBtn(  )
    MainuiController:getInstance():openCommonExplainView(true, Config.ArenaPeakChampionData.data_explain)
end

-- 战斗
function ArenapeakchampionMainWindow:onClickFightBtn(  )
    if not self.scdata then return end
    controller:openArenapeakchampionGuessingWindow(true)
     -- MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.Arenapeakchampion)
end
-- 布阵
function ArenapeakchampionMainWindow:onClickFormBtn()
    HeroController:getInstance():openFormGoFightPanel(true, PartnerConst.Fun_Form.ArenapeakchampionDef, {}, HeroConst.FormShowType.eFormSave)
end
-- 点击头像
function ArenapeakchampionMainWindow:onClickHeadBtn( index )
    if not self.dic_arena_peak_rank then return end
    if self.dic_arena_peak_rank[index] then
        local rid = self.dic_arena_peak_rank[index].rid
        local srv_id = self.dic_arena_peak_rank[index].srv_id
        
        local roleVo = RoleController:getInstance():getRoleVo()
        if roleVo and rid == roleVo.rid and srv_id == roleVo.srv_id then 
            message(TI18N("这是你自己~"))
            return
        end

        if srv_id == "" then
            message(TI18N("角色信息丢失在异域中"))
            return
        end
        FriendController:getInstance():openFriendCheckPanel(true, {srv_id = srv_id, rid = rid})
    end
end
-- 我的比赛
function ArenapeakchampionMainWindow:onClickReportBtn(  )
    if not self.scdata then return end
    if model.my_match_redpoint then
        controller:sender27731(1)
        model:setMyMatchRedPoint(false)
    end
    controller:openArenapeakchampionMymatchPanel(true)
end

function ArenapeakchampionMainWindow:onClickZoneBtn()
    if not self.scdata then return end
    local world_pos = self.zone_btn:convertToWorldSpace(cc.p(0, 0))
    if not self.zone_list then
        self.zone_list = {}
        for i=1,self.scdata.max_zone_id do
            local value = string_format(TI18N("第%s赛区"), i)
            table_insert(self.zone_list, {id = i, value = value})
        end
        table_sort(self.zone_list, SortTools.KeyLowerSorter("id"))
    end
    local setting = {}
    setting.other_index = self.scdata.zone_id or 1
    setting.select_index = self.select_zone_index or setting.other_index
    setting.offsetx = 120
    setting.offsety = 45
    setting.combobox_max_size = cc.size(236, 190)
    setting.combobox_bg_size = cc.size(244, 198)
    setting.dir_type = 2
    setting.combo_show_type = 2
    CommonUIController:getInstance():openCommonComboboxPanel(true, world_pos, handler(self, self.onChoseZoneBtn), self.zone_list, setting )
end

function ArenapeakchampionMainWindow:onChoseZoneBtn(index, data, setting)
    if not self.scdata then return end

    controller:sender27714(data.id, 1,8)
    self.select_zone_index = index
    self.zone_name:setString(data.value)
    if self.scdata.zone_id == data.id then
        self.zone_icon:setVisible(true)
    else
        self.zone_icon:setVisible(false)
    end
end

function ArenapeakchampionMainWindow:openRootWnd(setting)
    -- local setting = setting or {}
    controller:sender27700()
    controller:sender27701() --个人信息
    controller:sender27714(0,1,8)
end

function ArenapeakchampionMainWindow:setSingleInfo(data)
    if data.best_rank == 0 then
        self.rank_info:setString(TI18N("历史最高排名: 未上榜"))
    else
        self.rank_info:setString(string_format(TI18N("历史最高排名: 第%s名"), data.best_rank))
    end
end

function ArenapeakchampionMainWindow:setScdata(scdata)

    self.scdata = scdata

    if self.scdata.step == 0 then
        self.zone_btn:setVisible(false)
    else
        self.zone_btn:setVisible(true)
    end
    if self.select_zone_index == nil then
        self.zone_name:setString(string_format(TI18N("第%s赛区"), self.scdata.zone_id))
    end
    
    self:initMatchText()
    self:updateRedPoint()
end

function ArenapeakchampionMainWindow:initMatchText( )
    if not self.scdata then return end

    if self.scdata.step_status == 2 then
        if model:isBeforeOpenMacthTime() then
            self.match_value:setString(TI18N("即将开赛"))
        else
            self.match_value:setString(TI18N("未开赛"))
        end
    else
        --比赛阶段 --根据数据组合文字
        local str, str1 = model:getMacthText(self.scdata.step, self.scdata.round, self.scdata.round_status)
        if str1 ~= nil then
            self.match_value:setString(str..str1)
        else
            self.match_value:setString(str)
        end
    end
    if self.scdata.period == 0 then
        self.name:setString("")
    else
        self.name:setString(string_format(TI18N("第%s赛季"), self.scdata.period))
    end

    
    --初始化时间新
    local start_str = TimeTool.getMD(self.scdata.start_time)
    local end_str = TimeTool.getMD(self.scdata.end_time)
    if self.scdata.step == 0 or self.scdata.step_status == 2 then
        local time = self.scdata.start_time - GameNet:getInstance():getTime()
        if time < 0 then
            time = 0
        end
        local time_str = TimeTool.GetTimeFormatDay(time)
        self.time_value:setString(string_format(TI18N("%s-%s(距离下次开启剩余%s)"), start_str, end_str, time_str))
    else
        local time = self.scdata.end_time - GameNet:getInstance():getTime()
        if time < 0 then
            time = 0
        end
        local time_str = TimeTool.GetTimeFormatDay(time)
        self.time_value:setString(string_format(TI18N("%s-%s(距离赛季结束%s)"), start_str, end_str, time_str))
    end
end

function ArenapeakchampionMainWindow:initPeakRankInfo( scdata )
    if scdata then
        self.dic_arena_peak_rank = {}
        for i,v in ipairs(scdata.rank_list) do
             self.dic_arena_peak_rank[v.rank] = v
        end
        self:updatePeakRankInfo(self.dic_arena_peak_rank)
    end
end

--初始化排名信息
function ArenapeakchampionMainWindow:updatePeakRankInfo(dic_arena_peak_rank)
    for i,v in ipairs(self.lay_head_list) do
        local rank_data = dic_arena_peak_rank[i]
        if rank_data then
            self:showHeadInfo(true, v, rank_data.face_id, rank_data.face_file, rank_data.face_update_time)
            if i == 1 and not self.is_init_1 then
                self.is_init_1 = true
                -- self:showFlagEffect(true)
            end
            v.tip_img:setVisible(false)
            v.name:setString(rank_data.name)
            
            local srv_name = getServerName(rank_data.srv_id)
            if srv_name == "" then
                srv_name = TI18N("异域")
            end
            v.srv_name:setString(string_format("[%s]",srv_name))
        else
            self:showHeadInfo(false, v)
            v.tip_img:setVisible(true)
            v.name:setString(TI18N("虚位以待"))
            v.srv_name:setString("")
        end

        setBgByLabel(v.name, v.name_bg, 20, -1)
    end
end

function ArenapeakchampionMainWindow:showHeadInfo(status, head_data, face_id, face_file, face_update_time)
    if status then
        head_data.head_node:setVisible(true)
        if head_data.clipNode == nil then
            local mask_res = PathTool.getResFrame("common", "common_1032") 
            local mask = createSprite(mask_res, self.vSize.width/2, self.vSize.height/2, nil, cc.p(0.5, 0.5))
            head_data.clipNode = cc.ClippingNode:create(mask)
            head_data.clipNode:setAnchorPoint(cc.p(0.5,0.5))
            head_data.clipNode:setContentSize(self.vSize)
            head_data.clipNode:setCascadeOpacityEnabled(true)
            -- head_data.clipNode:setPosition(self.vSize.width/2,self.vSize.height/2 )--+ self.offest_y)
            head_data.clipNode:setAlphaThreshold(0)
            head_data.head_node:addChild(head_data.clipNode, 2)

            head_data.icon = ccui.ImageView:create()
            head_data.icon:setScale(0.8)
            head_data.icon:setCascadeOpacityEnabled(true)
            head_data.icon:setAnchorPoint(0.5,0.5)
            head_data.icon:setPosition(self.vSize.width/2,self.vSize.height/2+2)
            head_data.clipNode:addChild(head_data.icon,3)
        end
        if face_id and (head_data.record_face_id == nil or head_data.record_face_id ~= face_id) then
            head_data.record_face_id = face_id
            self:setHeadRes(head_data.icon, face_id, false, LOADTEXT_TYPE, face_file, face_update_time)
            -- local res = PathTool.getHeadIcon(face_id)
            -- head_data.icon:loadTexture(res, LOADTEXT_TYPE)
        end
    else
        if head_data.head_node then
            head_data.head_node:setVisible(false)
        end
    end
end

function ArenapeakchampionMainWindow:setHeadRes(icon, res, is_external, load_type, free_res_id, face_update_time, force)
    if res == nil or res == "" then return end
    if free_res_id and free_res_id ~= "" and ( force or (face_update_time and face_update_time ~= 0)) then
        TencentCos:getInstance():downLoadHeadFile(free_res_id, face_update_time, function(local_path)
            if not tolua.isnull(icon) then
                self:setHeadRes(icon, local_path, true)
            end
        end)
    else
        is_external = is_external or false  
        load_type = load_type or LOADTEXT_TYPE
        -- 非外部资源,资源路径重组
        if is_external == false then
            res = PathTool.getHeadIcon(res)
        end 
        if tolua.isnull(icon) then return end
        icon:loadTexture(res, load_type)

        local icon_size = icon:getContentSize()
        -- 如果有遮罩的话,头像尺寸要根据遮罩去做缩放处理
        local off_scale = 1          
        local mark_size = cc.size(90, 90)
        -- if self.mark_bg ~= nil then
        --     mark_size = self.mark_bg:getContentSize()
        -- end
        off_scale = mark_size.width / icon_size.width > mark_size.height / icon_size.height and mark_size.height / icon_size.height or mark_size.width / icon_size.width    
        icon:setScale(off_scale)
    end
end

function ArenapeakchampionMainWindow:showFlagSpine(bool)
    if bool == true then
        if self.play_effect == nil then
            self.play_effect = createEffectSpine("dianfengsaibg", cc.p(0,0), cc.p(0.5, 0.5), true, PlayerAction.action)
            self.spine_node:addChild(self.play_effect, 1)
        end    
    else
        if self.play_effect then 
            self.play_effect:setVisible(false)
            self.play_effect:removeFromParent()
            self.play_effect = nil
        end
    end
end

function ArenapeakchampionMainWindow:showFlagEffect(bool)
    if bool == true then
        if self.flag_effect == nil then
            if self.lay_head_list and self.lay_head_list[1] and self.lay_head_list[1].lay_head then 
                self.flag_effect = createEffectSpine("E27405", cc.p(90, 90), cc.p(0.5, 0.5), true, PlayerAction.action)
                self.lay_head_list[1].lay_head:addChild(self.flag_effect, 1)
            end
        end    
    else
        if self.flag_effect then 
            self.flag_effect:setVisible(false)
            self.flag_effect:removeFromParent()
            self.flag_effect = nil
        end
    end
end

function ArenapeakchampionMainWindow:close_callback(  )
    -- if self.role_lev_event and self.role_vo then
    --     self.role_vo:UnBind(self.role_lev_event)
    --     self.role_lev_event = nil
    -- end
    self:showFlagSpine(false)
    self:showFlagEffect(false)

    controller:openArenapeakchampionMainWindow(false)
end