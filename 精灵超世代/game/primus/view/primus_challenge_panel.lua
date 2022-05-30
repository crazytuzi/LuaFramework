-- --------------------------------------------------------------------
--
-- @author: liwenchuang@syg.com(必填, 创建模块的人员)
-- @editor: @syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      荣耀神殿玩法的挑战界面
-- <br/>Create: 2018年10月27日
-- --------------------------------------------------------------------

PrimusChallengePanel = PrimusChallengePanel or BaseClass(BaseView)


local controller = PrimusController:getInstance()
local string_format = string.format
local table_insert = table.insert
local string_find = string.find

function PrimusChallengePanel:__init(data)
    self.win_type = WinType.Mini
    self.layout_name = "primus/primus_challenge_panel"
    self.is_full_screen = false
    self.is_use_csb = false
    self.res_list = {
        -- { path = PathTool.getPlistImgForDownLoad("adventure", "adventure"), type = ResourcesType.plist },
        {path = PathTool.getPlistImgForDownLoad("bigbg/primus", "primus_bigbg_3", false), type = ResourcesType.single}
    }

    --属性列表
    self.attr_label_list = {}
    self.attr_icon_list = {}
    --复选框
    self.checkbox_list = {}
    self.checkbox_counts = {1,5,10}
    --boss 主动技能
    self.act_skill_item_list = {}
    --boss 被动技能
    self.passive_skill_item_list = {}

    --技能宽高
    self.skill_width = 88
end

function PrimusChallengePanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 1)
    self.main_panel = self.main_container:getChildByName("main_panel")
    self.close_btn = self.main_panel:getChildByName("close_btn")
    self.win_title = self.main_panel:getChildByName("win_title")
    self.win_title:setString(TI18N("神殿挑战"))

    self.record_btn     = self.main_panel:getChildByName("record_btn")
    --站台
    local station_lay   = self.main_panel:getChildByName("station_lay")
    self.mode_node      = station_lay:getChildByName("mode_node")
    self.occupant_tips  = station_lay:getChildByName("occupant_tips")
    self.tips_node    = station_lay:getChildByName("tips_node")
    self.head_node      = station_lay:getChildByName("head_node") 
    self.title_img      = station_lay:getChildByName("title_img")

    self.name           = station_lay:getChildByName("name")
    self.name_bg        = station_lay:getChildByName("name_bg")
    --boss技能
    local boss_panel    = self.main_panel:getChildByName("boss_panel")
    local desc_label     = boss_panel:getChildByName("desc_label")
    local desc_label_1   = boss_panel:getChildByName("desc_label_1")
    local desc_label_2   = boss_panel:getChildByName("desc_label_2")
    desc_label:setString(TI18N("Boss技能"))
    desc_label_1:setString(TI18N("主动技能"))
    desc_label_2:setString(TI18N("被动技能"))

    --主动技能scrollview
    self.item_container_1 = boss_panel:getChildByName("item_container_1")
    self.item_container_1:setScrollBarEnabled(false)
    --被动技能scrollview
    self.item_container_2 = boss_panel:getChildByName("item_container_2")
    self.item_container_2:setScrollBarEnabled(false)

    --属性
    self.attr_panel     = self.main_panel:getChildByName("attr_panel")
    self.arrt_title     = self.attr_panel:getChildByName("title")

    for i=1,4 do
        self.attr_label_list[i] = self.attr_panel:getChildByName("attr_label"..i)
        self.attr_icon_list[i] = self.attr_panel:getChildByName("attr_icon"..i)
    end
    self.arrt_title:setString(TI18N("神位称号属性加成"))

    --复选框
    local box_panel     = self.main_panel:getChildByName("box_panel")
    self.checkbox_list[1] = box_panel:getChildByName("checkbox1")
    self.checkbox_list[2] = box_panel:getChildByName("checkbox5")
    self.checkbox_list[3] = box_panel:getChildByName("checkbox10")
    local name = self.checkbox_list[1]:getChildByName("name")
    name:setString(string_format(TI18N("进化%s次"),self.checkbox_counts[1]))
    name = self.checkbox_list[2]:getChildByName("name")
    name:setString(string_format(TI18N("进化%s次"),self.checkbox_counts[2]))
    name = self.checkbox_list[3]:getChildByName("name")
    name:setString(string_format(TI18N("进化%s次"),self.checkbox_counts[3]))
    self.select_checkbox = 1

    self.warning_tips = box_panel:getChildByName("warning_tips")
    self.warning_tips:setString(TI18N("(难度大请谨慎)"))
    
    self.tips_name = self.main_panel:getChildByName("tips_name")
    self.challenge_btn = self.main_panel:getChildByName("challenge_btn")

    local goto_node = self.main_panel:getChildByName("goto_node")
    self.gotoe_label = createRichLabel(24, cc.c3b(36, 144, 3), cc.p(0, 0.5), cc.p(0, 0))
    self.gotoe_label:setString(string_format("<div href=xxx>%s</div>", TI18N("前往竞技场")))
    self.gotoe_label:addTouchLinkListener(function(type, value, sender, pos)
        ArenaController:getInstance():requestOpenArenWindow(extend)
    end, { "click", "href" })
    goto_node:addChild(self.gotoe_label)

    local tips_node = self.main_panel:getChildByName("tips_node")
    self.tips_label = createRichLabel(20, Config.ColorData.data_new_color4[6] , cc.p(0.5, 0.5), cc.p(0, 0),nil,nil,580)
    tips_node:addChild(self.tips_label)
end

function PrimusChallengePanel:register_event()
    registerButtonEventListener(self.close_btn, function() controller:openPrimusChallengePanel(false) end ,false, 2)
    registerButtonEventListener(self.record_btn, handler(self, self._onClickChallengeRecordBtn) ,true, 2)
    registerButtonEventListener(self.challenge_btn, handler(self, self._onClickChallengeBtn) ,true, 2)


    for i,box in ipairs(self.checkbox_list) do
        box:addEventListener(function ( sender,event_type )
            playButtonSound2()
            if self.sever_data then
                self.select_checkbox = i
                self:setSelectCheckBox()
                local num = self.sever_data.num + self.checkbox_counts[i]
                self:initBossSkill(num)
            end
        end)
    end

    -- self:addGlobalEvent(TaskEvent.UpdateUIRedStatus, function(key, value)
    --     self:updateUIRedStatus(key)
    -- end)
end
--去挑战去
function PrimusChallengePanel:_onClickChallengeBtn()
    if not self.sever_data then return end

    local _send20702 = function()
        local num = self.checkbox_counts[self.select_checkbox]
        controller:sender20702(self.sever_data.pos ,num)
    end
    if self.is_have_title then
        CommonAlert.show(TI18N("您当前已占有一个神位，若挑战其他神位成功，将失去原有神位，是否继续挑战？"),TI18N("确定"), _send20702,TI18N("取消"),nil,CommonAlert.type.rich)
    else
        _send20702()
    end
end
--查看挑战记录
function PrimusChallengePanel:_onClickChallengeRecordBtn()
    if not self.sever_data then return end
    controller:sender20703(self.sever_data.pos)
end


function PrimusChallengePanel:openRootWnd(data, is_have_title)
    if not data then return end
    self.is_have_title = is_have_title
    self.sever_data = data
    self.local_data = Config.PrimusData.data_upgrade[data.pos]

    local honor_data = Config.HonorData.data_title[self.local_data.honor_id] 
    if honor_data and self.title_img then
        local res = PathTool.getTargetRes("honor","txt_cn_honor_"..honor_data.res_id,false,false)
        self.item_load = loadSpriteTextureFromCDN(self.title_img, res, ResourcesType.single, self.item_load)
    end 

    
    if self.tips_node and self.local_data then 
        local str = string_format(TI18N("<div fontColor=#ffffff>已进化<div fontcolor=#14ff32>%s</div>次</div>"), self.sever_data.num)
        local label = createRichLabel(24, 1, cc.p(0.5,0.5), cc.p(0,0))
        label:setString(str)
        self.tips_node:addChild(label)
    end
    if self.sever_data.name ~= nil or self.sever_data.name ~= "" then
        local roleVo = RoleController:getInstance():getRoleVo()
        if roleVo and data.rid == roleVo.rid and data.srv_id == roleVo.srv_id then 
            --是自己
            self.tips_name:setString(TI18N("已占领神位"))
            self.challenge_btn:setVisible(false)
            self.gotoe_label:setVisible(false)
        end
    end

    --更新模型
    -- if self.local_data then
    --     self:updateSpine(self.local_data.look_id)
    -- end
    --头像
    self:initHeadUi()

    --boss技能
    self:initBossSkill(self.sever_data.num + 1)
    --称号属性
    self:initHonorAttribute()

    self:setSelectCheckBox()

    self:updateTipsLabel()
end

function PrimusChallengePanel:updateTipsLabel()
    local my_data = ArenaController:getInstance():getModel():getMyLoopData()
    if self.tips_label and self.local_data then
        if my_data and my_data.rank and my_data.rank > 0 then
            self.tips_label:setString(string_format(TI18N("挑战条件:当前竞技场处于前%s名(我的排名:<div fontcolor=#249003>%s</div>)"), self.local_data.arena_rank, my_data.rank))
        else
            self.tips_label:setString(string_format(TI18N("挑战条件:当前竞技场处于前%s名(我的排名:<div fontcolor=#249003>无</div>)"), self.local_data.arena_rank))
        end
    end
end

--初始化头像ui
function PrimusChallengePanel:initHeadUi()
    if not self.sever_data then return end

    if self.sever_data.name == nil or self.sever_data.name == "" then
        self.occupant_tips:setString(TI18N("虚位以待"))
        self.name_bg:setVisible(false)
        self.name:setVisible(false)
        return
    end
    
    --头像
    self.play_head = PlayerHead.new(PlayerHead.type.circle,nil,cc.size(96,96))
    self.head_node:addChild(self.play_head)
    self.play_head:setPosition(cc.p(0,0))
    self.play_head:setHeadRes(self.sever_data.face_id, false, LOADTEXT_TYPE, self.sever_data.face_file, self.sever_data.face_update_time)

    -- self.play_head:setHeadData(data)
    if self.sever_data.lev then
        self.play_head:setLev(self.sever_data.lev,cc.p(0,67))
    end
    self.name:setString(self.sever_data.name)

    self.play_head:addCallBack(function( )
        FriendController:getInstance():openFriendCheckPanel(true, {srv_id = self.sever_data.srv_id, rid = self.sever_data.rid})
    end)
end

function PrimusChallengePanel:initHonorAttribute()
    if not self.local_data then return end
    if not self.attr_label_list then return end
    if not self.attr_icon_list then return end
    local honor_data = Config.HonorData.data_title[self.local_data.honor_id]
    if honor_data then
        for i,lab in ipairs(self.attr_label_list) do
            local icon = self.attr_icon_list[i]
            if honor_data.attr[i] then
                lab:setVisible(true)
                local atrr_name = Config.AttrData.data_key_to_name[honor_data.attr[i][1]]
                -- if string_find(honor_data.attr[i][1], 'per') then
                if PartnerCalculate.isShowPerByStr(honor_data.attr[i][1]) then
                    local value = honor_data.attr[i][2]/10
                    lab:setString(string_format("%s + %s%%", TI18N(atrr_name), value))
                else
                    lab:setString(string_format("%s + %s ", TI18N(atrr_name), honor_data.attr[i][2]))
                end

                if icon then
                    icon:setVisible(true)
                    local res_id = PathTool.getAttrIconByStr(honor_data.attr[i][1])
                    local res = PathTool.getResFrame("common",res_id)
                    loadSpriteTexture(icon, res, LOADTEXT_TYPE_PLIST)
                end
            else
                lab:setVisible(false)
                if icon then
                    icon:setVisible(false)
                end
            end
        end
    end    
end

function PrimusChallengePanel:initBossSkill(num)
    if self.unit_data_list == nil then
        self.unit_data_list = {} 
        for i,v in pairs(Config.PrimusData.data_unitdata) do
            if self.sever_data.pos == v.pos then
                table_insert(self.unit_data_list, v)
            end
        end
    end

    table.sort( self.unit_data_list, function(a,b) return a.min < b.min end)
    local cur_data = nil
    local lenght = #self.unit_data_list
    for i,v in ipairs(self.unit_data_list) do
        if num >= v.min and num <= v.max then
            cur_data = v
            break
        end
        if i == lenght then
            cur_data = v
        end
    end
    if cur_data == nil then
        return
    end
    local look_id = cur_data.look_id or 340502
    self:updateSpine(look_id)

    if self.cur_unit_data and self.cur_unit_data.min == cur_data.min then
        --同一个对象.不用初始化
        return
    end

    self.cur_unit_data = cur_data
    local act_skill = cur_data.act_skill
    local passive_skill = cur_data.passive_skill

    --主动技能
    local item_width = self.skill_width * #act_skill
    local max_width = math.max(self.item_container_1:getContentSize().width, item_width)
    self.item_container_1:setInnerContainerSize(cc.size(max_width, self.item_container_1:getContentSize().height))
    for i,v in ipairs(self.act_skill_item_list) do
        v.con:setVisible(false)
    end

    for i,id in ipairs(act_skill) do
        local vo = Config.SkillData.data_get_skill(id)
        if vo then
            if self.act_skill_item_list[i] == nil then
                self.act_skill_item_list[i] = {}
                self.act_skill_item_list[i] = self:updateSkillItem(vo, self.act_skill_item_list[i], true) 
                self.item_container_1:addChild(self.act_skill_item_list[i].con)
            else
                self.act_skill_item_list[i].con:setVisible(true)
                self:updateSkillItem(vo, self.act_skill_item_list[i])
            end
            self.act_skill_item_list[i].con:setPosition((self.skill_width + 5) * (i - 1) + self.skill_width/2, self.skill_width/2)
        else 
            print(string_format("技能表id: %s 没发现", tostring(id)))
        end
    end

    --被动技能
    local item_width = self.skill_width * #passive_skill
    local max_width = math.max(self.item_container_2:getContentSize().width, item_width)
    self.item_container_2:setInnerContainerSize(cc.size(max_width, self.item_container_2:getContentSize().height))

    for i,v in ipairs(self.passive_skill_item_list) do
        v.con:setVisible(false)
    end

    for i,id in ipairs(passive_skill) do
        local vo = Config.SkillData.data_get_skill(id)
        if vo then
            if self.passive_skill_item_list[i] == nil then
                self.passive_skill_item_list[i] = {}
                self.passive_skill_item_list[i] = self:updateSkillItem(vo, self.passive_skill_item_list[i], false) 
                self.item_container_2:addChild(self.passive_skill_item_list[i].con)
            else
                self.passive_skill_item_list[i].con:setVisible(true)
                self:updateSkillItem(vo, self.passive_skill_item_list[i])
            end
            self.passive_skill_item_list[i].con:setPosition((self.skill_width + 5) * (i - 1) + self.skill_width/2, self.skill_width/2)
        else
            print(string_format("技能表id: %s 没发现", tostring(id)))
        end
    end
    
end

function PrimusChallengePanel:updateSpine(look_id)
    if not look_id then return end
    local fun = function()
        if not self.spine then
            self.spine = BaseRole.new(BaseRole.type.role, look_id)
            self.spine:setAnimation(0,PlayerAction.show,true) 
            self.spine:setCascade(true)
            self.spine:setPosition(cc.p(0,70))
            self.spine:setAnchorPoint(cc.p(0.5,0))
            --self.spine:setScale(0.5)
            self.mode_node:addChild(self.spine) 
            self.spine:setCascade(true)
            self.spine:setOpacity(0)
            local action = cc.FadeIn:create(0.2)
            self.spine:runAction(action)
        end
    end
    if self.spine then
        self.spine:setCascade(true)
        local action = cc.FadeOut:create(0.2)
        self.spine:runAction(cc.Sequence:create(action, cc.CallFunc:create(function()
                doStopAllActions(self.spine)
                self.spine:removeFromParent()
                self.spine = nil
                fun()
        end)))
    else
        fun()
    end
end

--@is_act 是否主动技能
function PrimusChallengePanel:updateSkillItem(config, skill_item, is_act)
    local size = cc.size(self.skill_width,self.skill_width)
    local skill_size = cc.size(self.skill_width - 4 ,self.skill_width - 4)

    skill_item.config = config
    if skill_item.con == nil then
        local con = ccui.Widget:create()
        con:setContentSize(size)
        con:setTouchEnabled(true)
        con:addTouchEventListener(function(sender, event_type) 
            if event_type == ccui.TouchEventType.ended then
                if skill_item.config then
                    playButtonSound2()
                    TipsManager:getInstance():showSkillTips(skill_item.config)
                end
            end
        end)
        skill_item.con = con
        --背景
        local res = PathTool.getNormalSkillBg()
        local bg = createImage(con, res,  size.width/2,size.height/2, cc.p(0.5,0.5), true, 0, true)
        bg:setContentSize(size)
    end

    --技能icon
    local res = PathTool.getSkillRes(config.icon)
    if skill_item.icon == nil then
        skill_item.icon = createImage(skill_item.con, res,  size.width/2,size.height/2, cc.p(0.5,0.5), false, 0, false)
        -- skill_item.icon:ignoreContentAdaptWithSize(true)
        skill_item.icon:setScale(0.75)
        -- skill_item.icon:setContentSize(cc.size(30 ,30))
    else
        skill_item.icon:loadTexture(res, LOADTEXT_TYPE)
        skill_item.icon:setScale(0.75)
        -- skill_item.icon:ignoreContentAdaptWithSize(true)
        -- skill_item.icon:setContentSize(cc.size(30 ,30))
    end
    --[[if is_act then
        --类型icon
        local type_res 
        if config.target_multi and config.target_multi == 1 then
            type_res = PathTool.getResFrame("primus","txt_cn_primus_2") --群
        else
            type_res = PathTool.getResFrame("primus","txt_cn_primus_1") --单
        end
        --类型icon
        if skill_item.type_icon == nil then
            skill_item.type_icon = createImage(skill_item.con, type_res,  0 ,self.skill_width, cc.p(0,1), true, 10, false)
        else
            skill_item.type_icon:loadTexture(type_res, LOADTEXT_TYPE_PLIST)
        end
    end--]]

    --技能等级
    local level = config.level or 1
    if config.client_lev and config.client_lev>0 then
        level = config.client_lev
    end
    if skill_item.lev_label == nil then
        skill_item.lev_label = createLabel(20,Config.ColorData.data_color4[1],Config.ColorData.data_color4[2], self.skill_width - 8,0,tostring(level), skill_item.con,2, cc.p(1,0),nil)
    else
        skill_item.lev_label:setString(tostring(level))
    end

    return skill_item
end

--设置选择框
function PrimusChallengePanel:setSelectCheckBox()
    if not self.select_checkbox then return end
    if not self.checkbox_list then return end

    for i,box in ipairs(self.checkbox_list) do
        if self.select_checkbox == i then
            box:setSelected(true)
        else
            box:setSelected(false)
        end
    end
end

function PrimusChallengePanel:close_callback()
    -- for k,v in pairs(self.partner_list) do
    --     if v.DeleteMe then
    --         v:DeleteMe()
    --     end
    -- end
    -- self.partner_list = nil
    if self.spine_model then
        self.spine_model:DeleteMe()
        self.spine_model = nil
    end
    if self.item_load then
        self.item_load:DeleteMe()
        self.item_load = nil
    end

    if self.play_head then
        self.play_head:DeleteMe()
        self.play_head = nil
    end
    controller:openPrimusChallengePanel(false)
end