--******** 文件说明 ********
-- @Author:      hyxing 
-- @description: 皮肤抽奖
-- @DateTime:    2019-08-22 10:57:23
-- *******************************
ActionSkinLotteryPanel = class("ActionSkinLotteryPanel", function()
    return ccui.Widget:create()
end)

local controller = ActionController:getInstance()
local lottery_config_msg = Config.HolidaySkinDrawData.data_lottery_msg
local consum_config = Config.HolidaySkinDrawData.data_consum_count

local item_pos = {{235,567},{180,443},{289,443},{124,335},{233,335},{338,335}, {71,220},{179,220},{285,220},{390,220}}
local item_scale = {1.0,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8,0.8}
local run_image_scale = {1.2,1.1,1.1,1.0,1.0,1.0,1.0,1.0,1.0,1.0}

function ActionSkinLotteryPanel:ctor(bid)
	self.holiday_bid = bid
	self.item_list = {}
    self.cur_count = nil --当前次数 
    self.is_lottery_start = nil --是否可以抽奖
	self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("elitesummon","elitesummon"), type = ResourcesType.plist },
    } 
    self.resources_load = ResourcesLoad.New(true)
    self.resources_load:addAllList(self.res_list, function()
        if self.loadResListCompleted then
            self:loadResListCompleted()
        end
    end)
end

function ActionSkinLotteryPanel:loadResListCompleted()
    self:configUI()
    self:register_event()
end

function ActionSkinLotteryPanel:configUI()
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_skin_lottery_panel"))
    self.root_wnd:setPosition(-40,-82)
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0, 0)

    self.main_container = self.root_wnd:getChildByName("main_container")
    local image_bg = self.main_container:getChildByName("image_bg")
    local str_bg = "txt_cn_hero_skin_lottery"
    local tab_vo = controller:getActionSubTabVo(self.holiday_bid)
    if tab_vo and tab_vo.aim_title ~= "" and tab_vo.aim_title then
        str_bg = tab_vo.aim_title
    end
    local res = PathTool.getPlistImgForDownLoad("bigbg/action", str_bg)
    if not self.bg_load then
        self.bg_load = loadSpriteTextureFromCDN(image_bg, res, ResourcesType.single, self.bg_load)
    end

    self.icon = self.main_container:getChildByName("icon")
    self.icon_text = self.main_container:getChildByName("icon_text")
    self.icon_text:setString("")
    self.btn_rule = self.main_container:getChildByName("btn_rule")
    self.btn_video = self.main_container:getChildByName("btn_video")
    self.btn_video:setScale(1.0)
    local text = self.btn_video:getChildByName("Text_1")
    text:setString(TI18N("皮肤预览"))
    text:setFontSize(20)

    self.btn_lottery = self.main_container:getChildByName("btn_lottery")
    self.btn_lottery_label = self.btn_lottery:getChildByName("Text_2")
    self.btn_lottery_label:setString(TI18N("祈愿1次"))
    self.btn_lottery_item = createRichLabel(18,cc.c4b(0xff,0xff,0xff,0xff),cc.p(0.5,0.5),cc.p(118,21),nil,nil,180)
	self.btn_lottery:addChild(self.btn_lottery_item)

    self.main_container:getChildByName("Text_3"):setString(TI18N("剩余时间："))
    self.time_text = self.main_container:getChildByName("time_text")
    self.time_text:setString("")
    controller:sender26601()
end

function ActionSkinLotteryPanel:setData()
    if not self.lottery_id then return end

    if lottery_config_msg and lottery_config_msg[self.lottery_id] then
        self.lottery_iten_id = lottery_config_msg[self.lottery_id].lottery_item
        local item_config = Config.ItemData.data_get_data(self.lottery_iten_id)
        if item_config then
            local res = PathTool.getItemRes(item_config.icon)
            loadSpriteTexture(self.icon, res, LOADTEXT_TYPE)
            self.icon:setScale(0.40)
        end
        local count = BackpackController:getInstance():getModel():getBackPackItemNumByBid(self.lottery_iten_id)
        self.icon_text:setString(count)
    end

    local stock_config = Config.HolidaySkinDrawData.data_lottery_stock
    if stock_config and stock_config[self.lottery_id] then
        local list = {}
        for i,v in pairs(stock_config[self.lottery_id]) do
            table.insert(list,v)
        end
        table.sort(list,function(a,b) return a.sort < b.sort end)
        
        local model = controller:getModel()
    	for i=1,10 do
    		if not self.item_list[i] then
    			delayRun(self.main_container, i*2 / display.DEFAULT_FPS,function ()
                    if not self.item_list[i] then
                        local item = BackPackItem.new(nil,true)
                        item:setAnchorPoint(0.5, 0.5)
                        self.main_container:addChild(item)
                        self.item_list[i] = item
                    end
                    if self.item_list[i] then
                        self.item_list[i]:setPosition(item_pos[i][1], item_pos[i][2])
                        self.item_list[i]:setBaseData(list[i].reward_id, list[i].num)
                        self.item_list[i]:setScale(item_scale[i])
                        self.item_list[i]:setDefaultTip()

                        self.item_list[i]:setSelfBackground(0)
                        self.item_list[i]:setBackgroundOpacity(128)
                        local status = model:getLotteryItemData(list[i].sort)
                        if status == 1 then
                            self.item_list[i]:IsGetStatus(true,128)
                        else
                           self.item_list[i]:IsGetStatus(false) 
                        end
                    end
                end)
    		end
    	end

        self.item_effect = createSprite(PathTool.getResFrame("elitesummon","elitesummon_6"), item_pos[1][1], item_pos[1][2], self.main_container, cc.p(0.5,0.5), LOADTEXT_TYPE_PLIST, 10)
        self.item_effect:setScale(run_image_scale[1])
        self.item_effect:setOpacity(200)
        self.is_lottery_start = true
    end
end

function ActionSkinLotteryPanel:register_event()
    --基础信息
    if not self.lottery_skin_msg then
        self.lottery_skin_msg = GlobalEvent:getInstance():Bind(ActionEvent.ACTION_SKIN_LOTTERY_MSG,function(data)
            if not data then return end
            self.lottery_id = data.lottery_id
            self:btnLotteryCount(data.time)
            if consum_config[self.lottery_id] then
                if data.time >= #consum_config[self.lottery_id] then
                    data.time = #consum_config[self.lottery_id]
                end
            end
            self.cur_count = data.time
            
            self:setData()
            FestivalActionConst.CountDownTime(self.time_text, {less_time = data.last_time, time_model = 2})
        end)
    end
    --抽奖返回
    if not self.lottery_skin_get then
        self.lottery_skin_get = GlobalEvent:getInstance():Bind(ActionEvent.ACTION_SKIN_LOTTERY_GET,function(data)
            if not data then return end
            self.cur_count = data.time
            self:clearRunLotteryTicker()
            self:runItemEffectAction(data.sort)
        end)
    end
    if not self.lottery_skin_rewawrd then
        self.lottery_skin_rewawrd = GlobalEvent:getInstance():Bind(ActionEvent.ACTION_SKIN_LOTTERY_REWARD,function()
            self:btnLotteryCount(self.cur_count)
            self:changeLotteryItem()

            self.is_lottery_start = true
            self:clearIsStartTicker()
        end)
    end   

	registerButtonEventListener(self.btn_lottery, function()
        if not self.is_lottery_start then
            message(TI18N("点击过快~~~~"))
        end
        if self.is_lottery_start then
            self.is_lottery_start = nil
            --是否开启，，如果6S服务端没有返回将继续点击
            if self.is_start_ticket == nil then
                self.is_start_ticket = GlobalTimeTicket:getInstance():add(function()
                    self.is_lottery_start = true
                    self:clearIsStartTicker()
                end,6)
            end
            self:btnLotterySendProtocal()
        end
	end, true)
    registerButtonEventListener(self.btn_rule, function(param,sender, event_type)
        if self.lottery_id and lottery_config_msg and lottery_config_msg[self.lottery_id] then
            TipsManager:getInstance():showCommonTips(lottery_config_msg[self.lottery_id].desc, sender:getTouchBeganPosition(),nil,nil,500)
        end
    end, true)
    registerButtonEventListener(self.btn_video, function()
        TimesummonController:getInstance():send23219(self.holiday_bid)
    end, true,nil,nil,0.9)
    
    if not self.grade_count_add_event then
        self.grade_count_add_event = GlobalEvent:getInstance():Bind(BackpackEvent.ADD_GOODS,function(bag_code,temp_list)
            self:changeLotteryCount(temp_list)
        end)
    end
    if not self.grade_count_delete_event then
        self.grade_count_delete_event = GlobalEvent:getInstance():Bind(BackpackEvent.DELETE_GOODS,function(bag_code,temp_list)
            self:changeLotteryCount(temp_list)
        end)
    end
    if not self.grade_count_modify_event then
        self.grade_count_modify_event = GlobalEvent:getInstance():Bind(BackpackEvent.MODIFY_GOODS_NUM,function(bag_code,temp_list)
            self:changeLotteryCount(temp_list)
        end)
    end
end
function ActionSkinLotteryPanel:changeLotteryCount(list)
    if not self.lottery_iten_id then return end
    for i,v in pairs(list) do
        if v.base_id == self.lottery_iten_id then
            local count = BackpackController:getInstance():getModel():getBackPackItemNumByBid(self.lottery_iten_id)
            self.icon_text:setString(count)
        end
    end
end
--转动奖品
function ActionSkinLotteryPanel:runItemEffectAction(stop_pos)
    self.pos = 0
    self.runProcess= 0
    self.process = 0
    self.speed = 1
    self.addSpeed = 0
    self.targetPos = stop_pos - 1 --停灯的位置(从0开始)
    self.step = 0
    if self.lottery_ticket == nil then
        self.lottery_ticket = GlobalTimeTicket:getInstance():add(function()
            self:runHandler()
        end,0.05)
    end
end
--旋转
local ROUND_COUNT = 10
function ActionSkinLotteryPanel:runHandler()
    if self.step == 0 then
        self.process = self.process + 0.33
        if self.process >= 5 then
            self.step = 1
        end
    elseif self.step == 1 then
        self.process = self.process+self.speed
        if self.process > (ROUND_COUNT*5) and self.targetPos > -1 then
            self.startPos = self.pos
            self.process = 0
            self.speed = 0.4
            self.runProcess = self.targetPos - self.pos
            --加速度
            self.addSpeed = - self.speed * self.speed * 0.5 / self.runProcess
            self.step = 2
        end
    elseif self.step == 2 then
        local prev_speed = self.speed
        self.speed = self.speed + self.addSpeed
        self.process = (self.speed + prev_speed) * 0.5+self.process
        if  self.process >= self.runProcess or self.speed < 0.01 then
            self.speed = 0
            self.process = self.runProcess
            self:clearRunLotteryTicker()
            self:DelayTimeSendProtocal()
            if self.delaytime_send_protocal == nil then
                self.delaytime_send_protocal = GlobalTimeTicket:getInstance():add(function()
                    controller:sender26602()
                    self:DelayTimeSendProtocal()
                end,0.5)
            end
        end
    end
    local p,_ = math.modf(self.process,ROUND_COUNT)
    self:setPos(p)
end
local change_pos = {
    [0] = 1,
    [1] = 2,
    [2] = 3,
    [3] = 4,
    [4] = 5,
    [5] = 6,
    [6] = 7,
    [7] = 8,
    [8] = 9,
    [9] = 10,
    [10] = 1, --越界处理
}
--延时请求获取的界面
function ActionSkinLotteryPanel:DelayTimeSendProtocal()
    if self.delaytime_send_protocal ~= nil then
        GlobalTimeTicket:getInstance():remove(self.delaytime_send_protocal)
        self.delaytime_send_protocal = nil
    end
end
function ActionSkinLotteryPanel:clearRunLotteryTicker()
    if self.lottery_ticket ~= nil then
        GlobalTimeTicket:getInstance():remove(self.lottery_ticket)
        self.lottery_ticket = nil
    end
end
function ActionSkinLotteryPanel:clearIsStartTicker()
    if self.is_start_ticket ~= nil then
        GlobalTimeTicket:getInstance():remove(self.is_start_ticket)
        self.is_start_ticket = nil
    end
end

function ActionSkinLotteryPanel:setPos(pos)
    if pos < 0 then
        pos = pos + ROUND_COUNT
    elseif pos >= ROUND_COUNT then
        pos = pos % ROUND_COUNT
    end
    if self.item_effect then
        self.item_effect:setScale(run_image_scale[change_pos[pos]])
        self.item_effect:setPosition(cc.p(item_pos[change_pos[pos]][1], item_pos[change_pos[pos]][2]))
    end
end

--根据次数来计算每次抽奖所用的石头
function ActionSkinLotteryPanel:btnLotteryCount(count)
    if not self.lottery_id then return end
    if not count then return end
    local temp_count = count
    if consum_config and consum_config[self.lottery_id] then
        if count > #consum_config[self.lottery_id] then
            temp_count = #consum_config[self.lottery_id]
        end
        local data = consum_config[self.lottery_id][temp_count]
        if data then
            local item_config = Config.ItemData.data_get_data(data.loss_id)
            local res = PathTool.getItemRes(item_config.icon)
            local str = string.format(TI18N("<img src=%s visible=true scale=0.30 />x %d"),res, data.num)
            self.btn_lottery_item:setString(str)
            if count > #consum_config[self.lottery_id] then
                setChildUnEnabled(true, self.btn_lottery)
                self.btn_lottery:setTouchEnabled(false)
                self.btn_lottery_label:disableEffect(cc.LabelEffect.OUTLINE)
            end
        end
    end
end
--抽奖之后物品的状态
function ActionSkinLotteryPanel:changeLotteryItem()
    if self.item_list then
        local model = controller:getModel()
        for i,v in pairs(self.item_list) do
            local status = model:getLotteryItemData(i)
            if self.item_list[i] then
                if status == 1 then
                    self.item_list[i]:IsGetStatus(true, 128)
                else
                   self.item_list[i]:IsGetStatus(false)
                end
            end
        end
    end
end
--发送抽奖协议
function ActionSkinLotteryPanel:btnLotterySendProtocal()
    if not self.lottery_iten_id then return end
    if not self.lottery_id then return end
    if consum_config and consum_config[self.lottery_id] then
        local data = consum_config[self.lottery_id][self.cur_count]
        if data then
            local count = BackpackController:getInstance():getModel():getBackPackItemNumByBid(self.lottery_iten_id)  
            if count >= data.num then
                controller:sender26600()
            else
                local num = data.num - count
                local str = nil
                if lottery_config_msg and lottery_config_msg[self.lottery_id] then
                    local sonsum_diamo = lottery_config_msg[self.lottery_id].star_diammond
                    --不足但是有的时候
                    local item_config = Config.ItemData.data_get_data(self.lottery_iten_id)
                    local res = PathTool.getItemRes(item_config.icon)
                    str = string.format(TI18N("祈愿还差<img src=%s visible=true scale=0.35 /> *%d个，是否消耗 <img src=%s visible=true scale=0.35 /><div fontColor=#289b14 fontsize=26> *%d</div> 补足并进行祈愿"),res,num, PathTool.getItemRes(3),num*sonsum_diamo[1][2])
                end
                if str then
                    local function call_back()
                        controller:sender26600()
                    end
                    CommonAlert.show(str, TI18N("确定"), call_back, TI18N("取消"), function()
                        self.is_lottery_start = true
                        self:clearIsStartTicker()
                    end, CommonAlert.type.rich)
                end
            end
        end
    end
end

function ActionSkinLotteryPanel:setVisibleStatus(bool)
    bool = bool or false
    self:setVisible(bool)
end

function ActionSkinLotteryPanel:DeleteMe()
	if self.bg_load then
		self.bg_load:DeleteMe()
		self.bg_load = nil
	end
    self:clearIsStartTicker()
    self:clearRunLotteryTicker()
    self:DelayTimeSendProtocal()
	doStopAllActions(self.time_text)
	doStopAllActions(self.main_container)
    if self.item_list and next(self.item_list or {}) ~= nil then
        for i, v in ipairs(self.item_list) do
            if v and v.DeleteMe then
                v:DeleteMe()
            end
        end
    end
    if self.lottery_skin_msg then
        GlobalEvent:getInstance():UnBind(self.lottery_skin_msg)
        self.lottery_skin_msg = nil
    end
    if self.lottery_skin_get then
        GlobalEvent:getInstance():UnBind(self.lottery_skin_get)
        self.lottery_skin_get = nil
    end
    if self.lottery_skin_rewawrd then
        GlobalEvent:getInstance():UnBind(self.lottery_skin_rewawrd)
        self.lottery_skin_rewawrd = nil
    end

    if self.grade_count_add_event then
        GlobalEvent:getInstance():UnBind(self.grade_count_add_event)
        self.grade_count_add_event = nil
    end
    if self.grade_count_delete_event then
        GlobalEvent:getInstance():UnBind(self.grade_count_delete_event)
        self.grade_count_delete_event = nil
    end
    if self.grade_count_modify_event then
        GlobalEvent:getInstance():UnBind(self.grade_count_modify_event)
        self.grade_count_modify_event = nil
    end
end