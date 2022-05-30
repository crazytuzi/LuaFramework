-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      关卡页签
--      开学季活动boss战 后端 锦汉 策划 建军 
-- <br/> 2019年8月22日
-- --------------------------------------------------------------------
ActiontermbeginsTabChapterPanel = class("ActiontermbeginsTabChapterPanel", function()
    return ccui.Widget:create()
end)

local controller = ActiontermbeginsController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort
local role_vo = RoleController:getInstance():getRoleVo()

local math_floor = math.floor

function ActiontermbeginsTabChapterPanel:ctor(parent)
    self.parent = parent
    self:config()
    self:layoutUI()
    self:registerEvents()
end

function ActiontermbeginsTabChapterPanel:config()
    -- self.size = cc.size(680,372.97)
    -- self:setContentSize(self.size)
    --左上角难度图标
    self.diff_item_list = {}

    self.select_index = 1
end

function ActiontermbeginsTabChapterPanel:layoutUI()
    local csbPath = PathTool.getTargetCSB("actiontermbegins/action_term_begins_tab_chapter_panel")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    --读取文件的大小
    self.size = self.root_wnd:getContentSize()
    self:setContentSize(self.size)

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.look_btn = self.main_container:getChildByName("look_btn")

    --难度
    self.diff_item_list = {}
    local diff_name = {
        [1] = TI18N("简单"),
        [2] = TI18N("困难"),
        [3] = TI18N("地狱"),
        [4] = TI18N("噩梦")
    }
    local diff_panel = self.main_container:getChildByName("diff_panel")
    self.select_diff = diff_panel:getChildByName("select_diff")
    self.select_diff_x = self.select_diff:getPositionX()

    for i=1,4 do
        local item = diff_panel:getChildByName("diff_item_"..i)
        self.diff_item_list[i] = {}
        self.diff_item_list[i].btn = item
        self.diff_item_list[i].icon = item:getChildByName("icon")
        self.diff_item_list[i].diff_name = item:getChildByName("diff_name")
        if diff_name[i] then
            self.diff_item_list[i].diff_name:setString(diff_name[i])
        end
        self.diff_item_list[i].lock_img = item:getChildByName("lock_img")

    end

    self.chapter_item_list = {}
    for i=1, 5 do
        local item_lay = self.main_container:getChildByName("chapter_item_"..i)
        if item_lay then
            self.chapter_item_list[i] = {}
            self.chapter_item_list[i].item = item_lay
            self.chapter_item_list[i].btn = item_lay:getChildByName("btn")
            self.chapter_item_list[i].icon = item_lay:getChildByName("icon")
            self.chapter_item_list[i].bar = item_lay:getChildByName("bar")
            self.chapter_item_list[i].bar_num = item_lay:getChildByName("bar_num")
            self.chapter_item_list[i].lock_img = item_lay:getChildByName("lock_img")
            self.chapter_item_list[i].pass_img = item_lay:getChildByName("pass_img")
            self.chapter_item_list[i].chapter_name = item_lay:getChildByName("chapter_name")

            self.chapter_item_list[i].chapter_name:setString("")
            self.chapter_item_list[i].pass_img:setVisible(false)
            self.chapter_item_list[i].lock_img:setVisible(false)
            self.chapter_item_list[i].bar:setPercent(0)
        end
    end
    self.select_img_pos = {
        [1] = cc.p(50, 136),
        [2] = cc.p(52, 137),
        [3] = cc.p(50, 102),
        [4] = cc.p(50, 136),
        [5] = cc.p(50, 136)
    }
    self.select_img = self.main_container:getChildByName("select_img")
    if self.select_img then
        breatheShineAction4(self.select_img, 0.3, 10)
    end

    self.bottom_panel = self.main_container:getChildByName("bottom_panel")

    self.chapter_name = self.bottom_panel:getChildByName("chapter_name")
    self.dungeons_key = self.bottom_panel:getChildByName("dungeons_key")
    self.dungeons_key:setString(TI18N("关卡效果"))

    local x , y = self.dungeons_key:getPosition()
    self.dungeons_effect_label = {}
    self.dungeons_effect_label[1] = createRichLabel(20, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0, 0.5), cc.p(x, y - 30),nil,nil,720)
    self.dungeons_effect_label[2] = createRichLabel(20, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0, 0.5), cc.p(x, y - 56),nil,nil,720)
    self.dungeons_effect_label[3] = createRichLabel(20, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0, 0.5), cc.p(x, y - 82),nil,nil,720)
    self.bottom_panel:addChild(self.dungeons_effect_label[1])
    self.bottom_panel:addChild(self.dungeons_effect_label[2])
    self.bottom_panel:addChild(self.dungeons_effect_label[3])

    self.bottom_panel:getChildByName("power_key"):setString(TI18N("推荐战力:"))
    self.power = self.bottom_panel:getChildByName("power")
    self.reward_desc = self.bottom_panel:getChildByName("reward_desc")
    self.reward_desc:setString(TI18N("本关奖励"))
    self.fight_btn = self.bottom_panel:getChildByName("fight_btn")
    self.fight_btn_label = self.fight_btn:getChildByName("label")
    self.fight_btn_label:setString(TI18N("挑 战"))

    local buy_panel = self.bottom_panel:getChildByName("buy_panel")
    buy_panel:getChildByName("key"):setString(TI18N("挑战次数:"))
    self.buy_count = buy_panel:getChildByName("label")
    self.buy_btn = buy_panel:getChildByName("add_btn")

    self.buy_tips = createRichLabel(20, cc.c4b(0xff,0xf8,0xbf,0xff), cc.p(0.5,0.5), cc.p(566,126), nil, nil, 600)
    self.bottom_panel:addChild(self.buy_tips)

    self.item_scrollview = self.bottom_panel:getChildByName("item_scrollview")
    self.item_scrollview:setScrollBarEnabled(false)

    self.look_btn = self.main_container:getChildByName("look_btn")

    self.less_time = createRichLabel(22, cc.c4b(0xff,0xf8,0xbf,0xff), cc.p(1, 0.5), cc.p(700, 442),nil,nil,720)
    self.main_container:addChild(self.less_time)

    -- local bottom_y = display.getBottom(self.main_container)
end

--事件
function ActiontermbeginsTabChapterPanel:registerEvents()
    registerButtonEventListener(self.fight_btn, function() self:onChickFightBtn() end, true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.buy_btn, function() self:onClickBuyCountBtn() end, true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)

    registerButtonEventListener(self.look_btn, function(param,sender, event_type) 
        local config = Config.HolidayTermBeginsData.data_const.level_descreption
        TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition())
    end ,true, 1)


    for i,v in ipairs(self.diff_item_list) do
        registerButtonEventListener(v.btn, function() self:onClickDiffBtn(i)  end ,false, 2)
    end
    for i,v in ipairs(self.chapter_item_list) do
        registerButtonEventListener(v.btn, function() self:onClickChapterBtn(i)  end ,false, 2)
    end
    
    if not self.add_goods_event then
        self.add_goods_event = GlobalEvent:getInstance():Bind(ActiontermbeginsEvent.TERM_BEGINS_BUY_COUNT_EVENT, function(data)
            if data and self.scdata then 
                self.scdata.cha_count = data.count
                self.scdata.buy_count = data.buy_count
                self:updateBuyCount()
                if self.is_open_form then
                    self.is_open_form = false
                    HeroController:getInstance():openFormGoFightPanel(true, PartnerConst.Fun_Form.TermBegins)
                end
            end
        end)
    end
end

-- 购买次数
function ActiontermbeginsTabChapterPanel:onClickBuyCountBtn(  )
    if not self.scdata then return end
    if self.scdata.buy_count <= 0 then
        message(TI18N("购买次数已达上限"))
        return
    end
    local config = Config.HolidayTermBeginsData.data_const.action_num_espensive
    if not config then return end

    local cha_count = self.scdata.cha_count or 0
    local item_id = config.val[1] or Config.ItemData.data_assets_label2id.gold
    local count = config.val[2] or 1
    local iconsrc = PathTool.getItemRes(Config.ItemData.data_get_data(item_id).icon)
    local str = string_format(TI18N("是否花费<img src='%s' scale=0.3 />%s购买一次挑战次数？"), iconsrc, count)
    local call_back = function()
        controller:sender26701()
    end
    CommonAlert.show(str, TI18N("确定"), call_back, TI18N("取消"), nil, CommonAlert.type.rich)
end

function ActiontermbeginsTabChapterPanel:onChickFightBtn()
    if self.is_time_out  then
        message(TI18N("活动已结束"))
        return
    end
    if not self.scdata then return end
    if not self.select_index then return end
    local config = self.config_list[self.select_index]
    if not config then return end
    if config.order_id < self.scdata.order then
       --已通关
        message(TI18N("该关卡已通关"))
        return
    elseif config.order_id > self.scdata.order then
        --未通关的
        message(TI18N("该关卡未解锁"))
        return
    end

    if self.scdata.cha_count <= 0 then
        self.is_open_form = true
        self:onClickBuyCountBtn()
        return
    end
    HeroController:getInstance():openFormGoFightPanel(true, PartnerConst.Fun_Form.TermBegins)
end

function ActiontermbeginsTabChapterPanel:onClickDiffBtn(difficulty)
    if not self.scdata then return end
    if difficulty > self.scdata.difficulty then
        message(TI18N("请先通关上一难度"))
        return
    end
    local difficulty_config = self.round_chapter_config[difficulty]
    if not difficulty_config then return end

    self.select_difficulty = difficulty
    self.config_list = {}
    for i,v in pairs(difficulty_config) do
        table_insert(self.config_list, v)
    end
    table_sort(self.config_list, function(a, b) return a.order_id < b.order_id end)
    self:updateAllChapterData()
end

function ActiontermbeginsTabChapterPanel:onClickChapterBtn(index)
    self:upateSingleChapterInfo(index)
end

function ActiontermbeginsTabChapterPanel:setData()
    if not self.is_init then
        self.is_init = true
        if self.parent and self.parent.scdata then
            self:setScdata(self.parent.scdata)         
        end
    end
end

function ActiontermbeginsTabChapterPanel:setScdata(scdata)
    self.scdata = scdata 
    
    

    --最大难度
    local max_diff = Config.HolidayTermBeginsData.data_max_diff[self.scdata.round]
    if not max_diff then return end
    --最大关卡id
    local max_chapter_id = Config.HolidayTermBeginsData.data_max_chapter_id[self.scdata.round]
    if not max_chapter_id then return end
    --轮次信息
    local round_config = Config.HolidayTermBeginsData.data_round_info[self.scdata.round]
    if not round_config then return end
    --关卡信息
    self.round_chapter_config = Config.HolidayTermBeginsData.data_chapter_info[round_config.unit_round]
    if not self.round_chapter_config then return end

    --当前选择难度
    self.select_difficulty = self.scdata.difficulty
    if self.select_difficulty > max_diff then
        self.select_difficulty = max_diff
    end
    local difficulty_config = self.round_chapter_config[self.select_difficulty]
    if not difficulty_config then return end

    self.config_list = {}
    for i,v in pairs(difficulty_config) do
        table_insert(self.config_list, v)
    end
    table_sort(self.config_list, function(a, b) return a.order_id < b.order_id end)
    --标志通关全副本
    if self.scdata.order > max_chapter_id then
        self.is_pass_all = true
    end

    local time = self.scdata.end_time - GameNet:getInstance():getTime()
    if time <= 0 then
        time = 0
        self.is_time_out = true
    end
    commonCountDownTime(self.less_time, time, {callback = function(time) self:setTimeFormatString(time) end})


    self:updateAllChapterData()
    self:updateBuyCount()
end

function ActiontermbeginsTabChapterPanel:setTimeFormatString(time)
    if time > 0 then
        local str = string.format(TI18N("<div outline=2,#000000 >剩余时间:</div><div fontcolor=#80f731 outline=2,#000000>%s</div>"),TimeTool.GetTimeFormatDayIIIIII(time))
        self.less_time:setString(str)
    else
        local str = TI18N("<div outline=2,#000000 >剩余时间:</div><div fontcolor=#80f731 outline=2,#000000>00:00</div>")
        self.less_time:setString(str)
        self.is_time_out = true
        if not self.is_time_out_once and self.fight_btn  then
            self.is_time_out_once = true
            self.fight_btn_label:disableEffect(cc.LabelEffect.OUTLINE)
            setChildUnEnabled(true, self.fight_btn)
        end
    end
end

function ActiontermbeginsTabChapterPanel:updateAllChapterData()
    if not self.scdata then return end
    for i,v in ipairs(self.chapter_item_list) do
        local config = self.config_list[i]
        if config then
            v.item:setVisible(true)
            v.chapter_name:setString(config.order_name)
            if v.item_load == nil then
                local res = PathTool.getPlistImgForDownLoad("bigbg/termbegins", "term_begins_chapter_"..config.order_res)
                v.item_load = loadSpriteTextureFromCDN(v.icon , res, ResourcesType.single, v.item_load, nil, function()
                    if not tolua.isnull(v.icon) and self.scdata then
                        if config.order_id < self.scdata.order then
                            setChildUnEnabled(true, v.icon)
                        else
                            setChildUnEnabled(false, v.icon)
                        end
                    end
                end)
            end

            if config.order_id < self.scdata.order then
                v.lock_img:setVisible(false)
                v.pass_img:setVisible(true)
                v.bar:setPercent(0)
                v.bar_num:setString("0%")
                setChildUnEnabled(true, v.icon)
            elseif config.order_id == self.scdata.order then
                self.select_index = i
                v.lock_img:setVisible(false)
                v.pass_img:setVisible(false)
                local per = self.scdata.hp_per/10
                v.bar:setPercent(per)
                v.bar_num:setString(per.."%")
                setChildUnEnabled(false, v.icon)
            else --锁上的
                v.lock_img:setVisible(true)
                v.pass_img:setVisible(false)
                v.bar:setPercent(100)
                v.bar_num:setString("100%")
                setChildUnEnabled(false, v.icon)
            end
        else
            v.item:setVisible(false)
        end
    end
    self:upateSingleChapterInfo(self.select_index)
    -- 左上角的难度icon
    for i,v in ipairs(self.diff_item_list) do
        if i < self.scdata.difficulty then
            if v.lock_img then
                v.lock_img:setVisible(false)
            end
            setChildUnEnabled(false, v.icon)
        elseif i == self.scdata.difficulty then
            
            if v.lock_img then
                v.lock_img:setVisible(false)
            end
            setChildUnEnabled(false, v.icon)
        else
            if v.lock_img then
                v.lock_img:setVisible(true)
            end
            setChildUnEnabled(true, v.icon)
        end
    end
    self:setSelectDiff()
end

function ActiontermbeginsTabChapterPanel:setSelectDiff()
    if not self.select_difficulty then return end
    if self.select_diff then
        self.select_diff:setPositionX(self.select_diff_x + (self.select_difficulty -1) * 80) --80 是csb那个算出来的
    end
end


--更新关卡信息:
function ActiontermbeginsTabChapterPanel:upateSingleChapterInfo(index)
    if not self.config_list then return end
    local config = self.config_list[index]
    if not config then return end
    self.select_index = index

    if self.select_img_pos[index] and self.chapter_item_list[index] then
        local x, y = self.chapter_item_list[index].item:getPosition()
        local pos_x =  self.select_img_pos[index].x + x - 50
        local pos_y =  self.select_img_pos[index].y + y - 51
        self.select_img:setPosition(pos_x, pos_y)
    end

    self.chapter_name:setString(config.order_name)

    for i,v in ipairs(self.dungeons_effect_label) do
        if config.add_skill_decs[i] then
            v:setString(config.add_skill_decs[i])    
        else
            v:setString("")
        end
    end

    self.power:setString(config.power)

    local data_list = config.hit_award or {}
    local setting = {}
    setting.scale = 0.7
    setting.max_count = 5
    setting.is_center = true
    -- setting.show_effect_id = 263
    self.item_list = commonShowSingleRowItemList(self.item_scrollview, self.item_list, data_list, setting)
    local config = self.config_list[self.select_index]
    if config then
        if config.order_id < self.scdata.order then
           --已通关
            self.fight_btn_label:disableEffect(cc.LabelEffect.OUTLINE)
            setChildUnEnabled(true, self.fight_btn)
        elseif not self.is_time_out and config.order_id == self.scdata.order then
            --正在打
            self.fight_btn_label:enableOutline(Config.ColorData.data_color4[264], 2)
            setChildUnEnabled(false, self.fight_btn)
        else --锁上的
            --未通关的
            self.fight_btn_label:disableEffect(cc.LabelEffect.OUTLINE)
            setChildUnEnabled(true, self.fight_btn)
        end
    end
end

function ActiontermbeginsTabChapterPanel:updateBuyCount()
    if not self.scdata then return end
    local config = Config.HolidayTermBeginsData.data_const.free_fight_count
    if config then
        local str = string_format("%s/%s",self.scdata.cha_count, config.val)
        self.buy_count:setString(str)
    else
        self.buy_count:setString(self.scdata.cha_count)
    end
    -- local day_buy_count = self.scdata.day_buy_count or 1
    -- local count = self.scdata.day_max_buy_count - day_buy_count
    -- if count < 0 then
    --     count = 0
    -- end
    local str = string.format(TI18N("<div outline=2,#000000>%s</div><div fontcolor=#3df424 outline=2,#000000>%s</div>"),TI18N("剩余购买次数:"), self.scdata.buy_count)
    self.buy_tips:setString(str)

    if not self.is_time_out and self.scdata.cha_count > 0 and not self.is_pass_all  then
        addRedPointToNodeByStatus(self.fight_btn, true, 5, 5)
    else
        addRedPointToNodeByStatus(self.fight_btn, false, 5, 5)
    end
end

function ActiontermbeginsTabChapterPanel:setVisibleStatus(bool)
    self:setVisible(bool)
end

--移除
function ActiontermbeginsTabChapterPanel:DeleteMe()
     for i,v in ipairs(self.chapter_item_list) do
        if v.item_load then
            v.item_load:DeleteMe()
            v.item_load = nil
        end
    end

    if self.item_list then
        for i,v in pairs(self.item_list) do
            v:DeleteMe()
        end
        self.item_list = nil
    end
    doStopAllActions(self.item_scrollview)
    doStopAllActions(self.select_img)
end
