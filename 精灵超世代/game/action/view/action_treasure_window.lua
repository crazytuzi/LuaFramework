-- --------------------------------------------------------------------
-- @author: 幸运探宝
-- --------------------------------------------------------------------
ActionTreasureWindow = ActionTreasureWindow or BaseClass(BaseView)

local controller = ActionController:getInstance()
local model = controller:getModel()
local string_format = string.format
local treasure_const = Config.DialData.data_const
local rand_list = Config.DialData.data_get_rand_list
local ROUND_COUNT = 8
local reward_pos = {{360,460},{480,410},{530,290},{480,170},{360,120},{240,170},{190,290},{240,410}}
--数字的转换  从0开始
local change_pos = {
    [0] = 1,
    [1] = 2,
    [2] = 3,
    [3] = 4,
    [4] = 5,
    [5] = 6,
    [6] = 7,
    [7] = 8,
    [8] = 1, --越界处理
}

function ActionTreasureWindow:__init()
    self.firstComein = true
    self.is_full_screen = true
    self.touchEnable = false --防止乱点，必须等到本地抽奖完成之后才能进行下一次
    self.touchRefresh = false
    self.tab_list = {}
    self.reward_lucky = {}
    self.treasureCount = 1
    self.cur_index = nil
    self.cur_effect_index = nil --用于播放音效的

    self.desc_item_name = {}
    self.desc_item_Lv = {}

    --拥有的劵数
    self.hasTreasure_num = {}
    --点击的探宝类型  -- 1  2
    self.touchTreasure_type = 1
    --查看更多里面的个数
    self.checkMoreCount = 1
    --标签页红点
    -- self.tabRedPoint = {false,false}
    --点击刷新控制特效
    self.touchEffect = {true,true}
    --探宝记录
    self.getRewardList = {}
    --幸运值达到领取奖励数字
    self.arriveLuckly_label = {}

    self.round_certer_load = {}
    self.item_list = {}
    self.luckly_item = {}
    self.win_type = WinType.Full 
    self.layout_name = "action/action_treasure_window"
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("welfare","welfare"), type = ResourcesType.plist },
        { path = PathTool.getPlistImgForDownLoad("bigbg/action","action_treasure",true), type = ResourcesType.single }
    }
end

function ActionTreasureWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end
	local main_container = self.root_wnd:getChildByName("main_container")
    self.main_container = main_container
    self:playEnterAnimatianByObj(self.main_container, 1)
	local bg = self.root_wnd:getChildByName("bg")
    bg:setScale(display.getMaxScale())
    local res = PathTool.getPlistImgForDownLoad("bigbg/action", "action_treasure", true)
    if not self.item_load then
        self.item_load = createResourcesLoad(res, ResourcesType.single, function()
            if not tolua.isnull(bg) then
                loadSpriteTexture(bg,res,LOADTEXT_TYPE)
            end
        end,self.item_load)
    end

    self.text_scroll = main_container:getChildByName("text_scroll")
    self.text_scroll:setScrollBarEnabled(false)
    self.probablity = main_container:getChildByName("probablity")
    self.probablity:setVisible(false)

    self.item_panel = main_container:getChildByName("item_panel")
    self.round_certer = self.item_panel:getChildByName("round")
    self.btnLockOther = self.item_panel:getChildByName("btnLockOther")
    main_container:getChildByName("Text_6"):setString(TI18N("下次免费刷新: "))
    self.refresh_time = main_container:getChildByName("refresh_time")
    self.refresh_time:setString("00:00:00")

    self.run_light = createSprite(PathTool.getResFrame("welfare","welfare_37"), 0, 0, self.item_panel, cc.p(0.5,0.5), LOADTEXT_TYPE_PLIST, 10)
    self.run_light:setVisible(false)

    self.status_count = 0

    model:setLucklyRewardData()
    model:setBuyRewardData()

    main_container:getChildByName("Text_2"):setString(TI18N("探宝记录"))
    local treasure_bg = self.main_container:getChildByName("treasure_bg")
    self.treasure_total = createRichLabel(22, cc.c4b(0xff,0xff,0xf8,0xff), cc.p(0,0.5), cc.p(0,20), nil, nil, 150)
    treasure_bg:addChild(self.treasure_total)
    
    self.luckyBar = main_container:getChildByName("luckyBar")
    --self.luckyBar:setScale9Enabled(true)

    local tab_container = main_container:getChildByName("tab_container")
    local text_title = {TI18N("幸运探宝"),TI18N("高级探宝")}
    for i=1, 2 do
        local tab_btn = tab_container:getChildByName(string.format("tab_btn_%s",i))
        tab_btn.label = tab_btn:getChildByName("title")
        tab_btn.label:setString(text_title[i])
        tab_btn.normal = tab_btn:getChildByName("normal")
        tab_btn.select = tab_btn:getChildByName("select")
        tab_btn.select:setVisible(false)
        tab_btn.redpoint = tab_btn:getChildByName("redpoint")
        tab_btn.redpoint:setVisible(false)
        --tab_btn.label:setTextColor(cc.c4b(0xff,0xc3,0x8d, 0xff))
        tab_btn.index = i
        self.tab_list[i] = tab_btn
    end

    for i=1,2 do
        local buy_reward_data = model:getBuyRewardData(i)
        local lottery_id = buy_reward_data[1].expend_item[1][1]
        self.hasTreasure_num[i] = BackpackController:getInstance():getModel():getBackPackItemNumByBid(lottery_id)
    end

    self.btnTreasure = {}
    for i=1,3 do
        local tab = {}
        tab.btn = main_container:getChildByName("btn_treasure_"..i) 
        tab.price = createRichLabel(26, Config.ColorData.data_color4[1], cc.p(0,0.5), cc.p(61,36), 20, nil, nil)
        tab.btn:addChild(tab.price)
        self.btnTreasure[i] = tab
    end

    self.text_lucky_num = main_container:getChildByName("text_lucky_num")
    self.text_lucky_num:setString("")
    self.btnRule = main_container:getChildByName("btnRule")
    self.btn_shop = main_container:getChildByName("btn_shop")
    self.btn_shop:getChildByName("Text_1"):setString(TI18N("探宝商店"))
    self.btn_return = main_container:getChildByName("btn_return")
    
    local pos_x = display.getLeft(self.main_container) + self.btn_return:getPositionX()
    local pos_y = display.getBottom(self.main_container)+ self.btn_return:getPositionY()*display.getMaxScale(self.root_wnd)
    self.btn_return:setPosition(cc.p(pos_x,pos_y))

    --预加载音效
    AudioManager:getInstance():preLoadEffect(AudioManager.AUDIO_TYPE.COMMON, 'c_turntable_game')
    AudioManager:getInstance():preLoadEffect(AudioManager.AUDIO_TYPE.COMMON, 'c_turntable_game_1')
end

function ActionTreasureWindow:openRootWnd(index)
    self.jump_index = index or 1
    self:changeTabLocalData(self.jump_index)
    controller:requestLucky()
end
--倍率
function ActionTreasureWindow:rewardProbility(index)
    index = index or 1
    local config_data = {}
    local lev_index = 1
    local role_ve = RoleController:getInstance():getRoleVo()
    config_data = Config.DialData.data_magnificat_list[index]

    if config_data == nil then
        self.probablity:setVisible(false)
        return
    end

    for i,v in ipairs(config_data) do
        if role_ve.lev >= v.min and role_ve.lev <= v.max then
            lev_index = i
            break
        end
    end
    local config = config_data[lev_index]

    for i=1, self.checkMoreCount do
        if self.desc_item_name[i] then
            self.desc_item_name[i]:setVisible(false)
        end
        if self.desc_item_Lv[i] then
            self.desc_item_Lv[i]:setVisible(false)
        end
    end
    self.checkMoreCount = tableLen(config.award)

    local num = math.floor(self.checkMoreCount/2)
    self.probablity:setContentSize(cc.size(self.probablity:getContentSize().width, 40*num))
    local pos_y = self.probablity:getContentSize().height - 35 

    doStopAllActions(self.probablity)
    for i=1, self.checkMoreCount do
        delayRun(self.probablity, i*2/60, function()
            if i <= num then
                local item_config = Config.ItemData.data_get_data(config.award[i][1])
                if not self.desc_item_name[i] then
                    self.desc_item_name[i] = createLabel(20,Config.ColorData.data_new_color4[6],nil,0,0,"",self.probablity,nil, cc.p(0,0.5))
                end
                if self.desc_item_name[i] then
                    self.desc_item_name[i]:setVisible(true)
                    self.desc_item_name[i]:setContentSize(cc.size(150,30))
                    self.desc_item_name[i]:setString(TI18N(item_config.name))
                    self.desc_item_name[i]:setPosition(40,pos_y-36*(i-1))
                end
                if not self.desc_item_Lv[i] then
                    self.desc_item_Lv[i] = createLabel(20,Config.ColorData.data_new_color4[12],nil,0,0,"",self.probablity,nil, cc.p(0,0.5))
                end
                if self.desc_item_Lv[i] then
                    self.desc_item_Lv[i]:setVisible(true)
                    self.desc_item_Lv[i]:setString(config.award[i][2].."%")
                    self.desc_item_Lv[i]:setPosition(265,pos_y-36*(i-1))
                end
            else
                local item_config = Config.ItemData.data_get_data(config.award[i][1])
                if not self.desc_item_name[i] then
                    self.desc_item_name[i] = createLabel(20,Config.ColorData.data_new_color4[6],nil,0,0,"",self.probablity,nil, cc.p(0,0.5))
                end
                if self.desc_item_name[i] then
                    self.desc_item_name[i]:setVisible(true)
                    self.desc_item_name[i]:setContentSize(cc.size(150,30))
                    self.desc_item_name[i]:setString(TI18N(item_config.name))
                    self.desc_item_name[i]:setPosition(350,pos_y-36*(i-(num+1)))
                end
                if not self.desc_item_Lv[i] then
                    self.desc_item_Lv[i] = createLabel(20,Config.ColorData.data_new_color4[12],nil,0,0,"",self.probablity,nil, cc.p(0,0.5))
                end
                if self.desc_item_Lv[i] then
                    self.desc_item_Lv[i]:setVisible(true)
                    self.desc_item_Lv[i]:setString(config.award[i][2].."%")
                    self.desc_item_Lv[i]:setPosition(575,pos_y-36*(i-(num+1)))
                end
            end
        end)
    end
end

function ActionTreasureWindow:itemRewardPos(list)
    if not list or next(list) == nil then return end
    --以12点钟方向为起点，顺时针
    for i=1, #list do
        delayRun(self.item_panel, i*2/60, function() 
            if not self.item_list[i] then
                local item = BackPackItem.new(true,true, false, 0.8)
                item:setAnchorPoint(0.5, 0.5)
                self.item_panel:addChild(item)
                self.item_list[i] = item
            end
            if self.item_list[i] then
                self.item_list[i]:setPosition(reward_pos[i][1], reward_pos[i][2])
                self.item_list[i]:setBaseData(rand_list[list[i].id][1].item_id, rand_list[list[i].id][1].item_num)
                self.item_list[i]:setDefaultTip()

                if list[i] then
                    if list[i].status == 1 then
                        setChildUnEnabled(true, self.item_list[i])
                    elseif list[i].status == 0 then
                        setChildUnEnabled(false, self.item_list[i])
                    end
                end
                local fadein = cc.FadeIn:create(0.01)
                self.item_list[i]:runAction(fadein)
            end
        end)
    end
    self:runLightUniformSpeed()
end

--不需要服务端返回就可以显示的东西，避免UI出来时候有空挡
function ActionTreasureWindow:changeTabLocalData(index)
    if self.cur_index == index then return end

    index = index or 1
    local res = PathTool.getPlistImgForDownLoad("bigbg/action", "action_treasure_round_"..index)
    if not self.round_certer_load[index] then
        self.round_certer_load[index] = loadSpriteTextureFromCDN(self.round_certer, res, ResourcesType.single, self.round_certer_load[index])
    end
    if self.round_certer_load[index] then
        loadSpriteTexture(self.round_certer,res,LOADTEXT_TYPE)
    end

    local buy_reward_data = model:getBuyRewardData(index)

    local lottery_id = buy_reward_data[1].expend_item[1][1]
    local item_config = Config.ItemData.data_get_data(lottery_id)
    local res = PathTool.getItemRes(item_config.icon)
    local str = string_format("<img src='%s' scale=0.5 />  %d",res,self.hasTreasure_num[index])
    self.treasure_total:setString(str)
    local code = cc.Application:getInstance():getCurrentLanguageCode()
    for i=1, 3 do
        if i == 3 then
            local str = string_format(TI18N("<div outline=2,#d63636>免费刷新</div>"))
            self.btnTreasure[i].price:setString(str)
            self.btnTreasure[i].price:setPosition(61,41)
        else
            local str = string_format(TI18N("    <img src=%s visible=true scale=0.50 /><div fontsize=22 fontcolor=#fff99e outline=2,#3d5078> %d\n</div><div outline=2,#d63636>探宝%d次</div>"), res, buy_reward_data[i].expend_item[1][2], treasure_const.treasure_num.val[index][i])
            self.btnTreasure[i].price:setString(str)
            self.btnTreasure[i].price:setPosition(61,75)
        end
        if code == "en" then
            self.btnTreasure[i].price:setPositionX(35)
        end
    end

    local barBG = self.main_container:getChildByName("Image_2_0")
    local luckly_num_data = model:getLucklyRewardData(index)
    local bar_interval = barBG:getContentSize().width / 5

    for i=1, 5 do
        if not self.luckly_item[i] then
            self.luckly_item[i] = RoundItem.new(true,0.55,0.7)
            self.luckyBar:addChild(self.luckly_item[i])
            self.luckly_item[i]:setPosition(cc.p(bar_interval*i,22))
        end
        
        if not self.arriveLuckly_label[i] and self.luckly_item[i] then
            self.arriveLuckly_label[i] = createLabel(28,Config.ColorData.data_color4[1],nil,65,-7,"",self.luckly_item[i],nil, cc.p(0.5,0.5))
        end
        if self.arriveLuckly_label[i] then
            self.arriveLuckly_label[i]:setString(luckly_num_data[i].lucky_val)
        end
        if self.luckly_item[i] then
            self.luckly_item[i]:setBaseData(luckly_num_data[i].award[1][1], luckly_num_data[i].award[1][2])
            self.luckly_item[i]:setVisibleRedPoint(false)
            self.luckly_item[i]:setVisibleRoundBG(false)
            local function func()
                controller:send16640(index, luckly_num_data[i].id)
            end
            self.luckly_item[i]:addCallBack(func)
        end
    end
end
--分段计算进度条
function ActionTreasureWindow:sectionCalculation(num,luckly_list)
    num = num or 10
    local segmeent = 20
    local percent = 1
    if luckly_list[1] and luckly_list[2] and luckly_list[3] and luckly_list[4] and luckly_list[5] then
        if num <= luckly_list[1].lucky_val then
            return num / luckly_list[1].lucky_val * segmeent
        elseif num > luckly_list[1].lucky_val and num <= luckly_list[2].lucky_val then
            percent = 2
        elseif num > luckly_list[2].lucky_val and num <= luckly_list[3].lucky_val then
            percent = 3
        elseif num > luckly_list[3].lucky_val and num <= luckly_list[4].lucky_val then
            percent = 4
        elseif num > luckly_list[4].lucky_val and num <= luckly_list[5].lucky_val then
            percent = 5
        else
            return 100
        end
        local adv = luckly_list[percent].lucky_val - luckly_list[percent-1].lucky_val
        local count = num - luckly_list[percent-1].lucky_val
        local percent_num = segmeent*(percent - 1) + ( count / adv ) * segmeent
        return percent_num
    else
        return 0
    end
end

--data:寻宝数据(服务端返回的)
function ActionTreasureWindow:commonShowData(data, luckly_list)
    if not next(data) or not next(luckly_list) then return end
    local lucky_num = 0
    if luckly_list[5] then
        lucky_num = luckly_list[5].lucky_val
    end
    self.text_lucky_num:setString(data.lucky.."/"..lucky_num)
    local mul = self:sectionCalculation(data.lucky, luckly_list)
    self.luckyBar:setPercent(mul)

    local code = cc.Application:getInstance():getCurrentLanguageCode()
    local refresh = data.end_time - GameNet:getInstance():getTime()
    if refresh > 0 then
        model:setCountDownTime(self.refresh_time,refresh)
        local item_config = Config.ItemData.data_get_data(treasure_const.refreash.val[1][1])
        local res = PathTool.getItemRes(item_config.icon)
        local str = string_format(TI18N("<img src=%s visible=true scale=0.50 /><div outline=2,#d63636> %d刷新</div>"),res,treasure_const.refreash.val[1][2])
        self.btnTreasure[3].price:setPositionX(45)
        if code == "en" then
            self.btnTreasure[3].price:setPositionX(20)
        end
        self.btnTreasure[3].price:setString(str)
        self.touchEffect[data.type] = false
    else
        local str = string_format(TI18N("<div outline=2,#d63636>免费刷新</div>"))
        self.btnTreasure[3].price:setPositionX(63)
        if code == "en" then
            self.btnTreasure[3].price:setPositionX(40)
        end
        self.btnTreasure[3].price:setString(str)
        doStopAllActions(self.refresh_time)
        self.refresh_time:setString("00:00:00")
        self.touchEffect[data.type] = true
    end

    local status = false
    for i,v in pairs(luckly_list) do
        local _bool = true
        for k,m in pairs(data.lucky_award) do
            if v.id == m.lucky then
                _bool = false
                break
            end
        end

        if data.lucky < v.lucky_val then
            _bool = false
        end

        setChildUnEnabled(false, self.luckly_item[i])
        if self.luckly_item[i] then
            self.luckly_item[i]:setDefaultTip(not _bool)
            status = status or _bool
            self.luckly_item[i]:setVisibleRedPoint(_bool)

            if _bool == false and data.lucky >= v.lucky_val then
                setChildUnEnabled(true, self.luckly_item[i])
            end
        end
    end
    model:setLucklyTabRedPoint(data.type,status)
    self:showRedpoint()
end

function ActionTreasureWindow:showRedpoint()
    local totle_status = false
    for i=1,2 do
        local status = model:getLucklyTabRedPoint(i)
        self.tab_list[i].redpoint:setVisible(status)
        totle_status = totle_status or status
    end
    MainuiController:getInstance():setFunctionTipsStatus(MainuiConst.icon.lucky_treasure,totle_status)
end

function ActionTreasureWindow:showTreasureLog(data)
    if not data or next(data) == nil then return end
    local str = ""
    local num = tableLen(data.log_list)
    if num >= 10 then
        num = 10
    end
    for i,v in pairs(self.getRewardList) do
        if v then
            v:setVisible(false)
        end
    end
    self.text_scroll:setInnerContainerSize(cc.size(self.text_scroll:getContentSize().width, 26*num))
    for i = 1, num do
        if data.log_list[i] then
            if not self.getRewardList[i] then
                self.getRewardList[i] = createRichLabel(16, Config.ColorData.data_new_color4[6], cc.p(0.5,1), cc.p(self.text_scroll:getContentSize().width*0.5-3,0), nil, nil, 300)
                self.text_scroll:addChild(self.getRewardList[i])
            end 
            if self.getRewardList[i] then
                self.getRewardList[i]:setVisible(true)
                local pos_y = self.text_scroll:getInnerContainerSize().height + 47
                self.getRewardList[i]:setPositionY(pos_y - 26*(i+1))
                local item_config = Config.ItemData.data_get_data(data.log_list[i].bid)
                str = string_format(TI18N(" <div fontcolor=#d63636>%s</div> 获得 <div fontcolor=#d63636>%s</div>"),data.log_list[i].role_name, item_config.name)
                self.getRewardList[i]:setString(str)
            end
        end
    end
end

function ActionTreasureWindow:changeTabView(index)
    index = index or 1
    if self.cur_index == index then return end
    if self.cur_tab ~= nil then
        self.cur_tab.label:setTextColor(Config.ColorData.data_new_color4[6])
        self.cur_tab.label:disableEffect(cc.LabelEffect.SHADOW)
        self.cur_tab.normal:setVisible(true)
        self.cur_tab.select:setVisible(false)
    end

    self.cur_index = index
    self.cur_tab = self.tab_list[self.cur_index]

    if self.cur_tab ~= nil then
        self.cur_tab.label:setTextColor(Config.ColorData.data_new_color4[1])
        self.cur_tab.label:enableShadow(Config.ColorData.data_new_color4[2],cc.size(0, -2),2)
        self.cur_tab.normal:setVisible(false)
        self.cur_tab.select:setVisible(true)
    end

    self.touchEnable = false

    local luckly_list = model:getLucklyRewardData(index)
    local initData = model:getTreasureInitData(index)
    self:commonShowData(initData, luckly_list)

    self:itemRewardPos(initData.rand_lists)
    self:showTreasureLog(initData)
end

function ActionTreasureWindow:register_event()
    self:addGlobalEvent(ActionEvent.UPDATE_LUCKYROUND_GET, function(data)
        if not data then
            controller:openLuckyTreasureWin(false)
            return
        end
        self:changeTabView(self.cur_index or self.jump_index)
    end)
    self:addGlobalEvent(ActionEvent.TREASURE_SUCCESS_DATA, function(data)
        if not data then return end
        if data.code == 0 then
            self.touchEnable = false
            message(data.msg)
            return
        end

        self:showLotteryAudioEffect(true)
        self.showRewardList = data
        self.pos = 0
        self.runProcess= 0
        self.process = self.status_count --开始的位置
        self.speed = 1
        self.addSpeed = 0
        self.targetPos = data.awards3[1].pos - 1 --停灯的位置(从0开始)
        self.step = 0
        self.round = 5 --圈数
        if self.targetPos <= 3 then
            self.round = 4
        end

        self:runLightUniformSpeedHide()
        if self.lottery_ticket == nil then
            self.lottery_ticket = GlobalTimeTicket:getInstance():add(function()
                self:runHandler()
            end,0.01)
        end
    end)
    self:addGlobalEvent(ActionEvent.UPDATA_TREASURE_LOG_DATA, function(data)
        if not data then return end
        model:updataTreasureLogData(data.type, data.log_list)
        local initData = model:getTreasureInitData(data.type)
        self:showTreasureLog(initData)
    end)
    --弹窗
    self:addGlobalEvent(ActionEvent.UPDATA_TREASURE_POPUPS_SEND, function(data)
        self.showRewardList = data
        self:runLightReward()
    end)

    self:addGlobalEvent(ActionEvent.UPDATE_LUCKLY_DATA, function(data)
        if not data then return end
        local buy_reward_data = model:getBuyRewardData(data.type)
        local lottery_id = buy_reward_data[1].expend_item[1][1]
        self.hasTreasure_num[data.type] = BackpackController:getInstance():getModel():getBackPackItemNumByBid(lottery_id)
        if self.hasTreasure_num[data.type] <= 0 then self.hasTreasure_num[data.type] = 0 end

        local item_config = Config.ItemData.data_get_data(lottery_id)
        if item_config then
            local res = PathTool.getItemRes(item_config.icon)
            local str = string_format("<img src='%s' scale=0.5 />  %d",res,self.hasTreasure_num[data.type])
            self.treasure_total:setString(str)
        end

        model:updataTreasureInitData(data.type, data)

        local luckly_list = model:getLucklyRewardData(data.type)
        local initData = model:getTreasureInitData(data.type)
        self:commonShowData(initData, luckly_list)
    end)

    self:addGlobalEvent(BackpackEvent.ADD_GOODS, function(bag_code,temp_list)
        self:changeTreasureNumber(temp_list)
    end)
    self:addGlobalEvent(BackpackEvent.DELETE_GOODS, function(bag_code,temp_list)
        self:changeTreasureNumber(temp_list)
    end)
    self:addGlobalEvent(BackpackEvent.MODIFY_GOODS_NUM, function(bag_code,temp_list)
        self:changeTreasureNumber(temp_list)
    end)
  
    for k, tab_btn in pairs(self.tab_list) do
        registerButtonEventListener(tab_btn, function()
            if self.touchEnable == true then return end
            self.probablity:setVisible(false)
            local role_ve = RoleController:getInstance():getRoleVo()
            local data = model:getBuyRewardData(tab_btn.index)

            if data and data[1].limit_open then
                if role_ve.lev >= data[1].limit_open[1][2] then
                    self:changeTabLocalData(tab_btn.index)
                    self:changeTabView(tab_btn.index)
                else
                    local str = string_format(TI18N("人物等级%d级开启"),data[1].limit_open[1][2])
                    message(str)
                end
            end
        end ,false, 1)
    end

    registerButtonEventListener(self.btn_return, function()
        controller:openLuckyTreasureWin(false)
    end ,true, 2)
    registerButtonEventListener(self.btnRule, function(param,sender, event_type)
        local config = Config.DialData.data_const.game_rule1
        if self.cur_index == 2 then
            config = Config.DialData.data_const.game_rule2
        end
        TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition(),nil,nil,500)
    end ,false, 1)

    registerButtonEventListener(self.btnLockOther, function()
        self.probablity:setVisible(true)
        self:rewardProbility(self.cur_index)
    end ,false, 1)
    registerButtonEventListener(self.probablity, function()
        self.probablity:setVisible(false)
    end ,false, 1)
    registerButtonEventListener(self.background, function()
        self.probablity:setVisible(false)
    end ,false, 1)

    registerButtonEventListener(self.btn_shop, function()
        StrongerController:getInstance():clickCallBack(406)
    end ,false, 1)    

    for i,v in ipairs(self.btnTreasure) do
        registerButtonEventListener(v.btn, function()
            self:sendTreasureLottery(i)
        end ,true, 1)
    end
end

function ActionTreasureWindow:showLotteryAudioEffect(status)
    if self.lottery_audio_effect then
        AudioManager:getInstance():removeEffectBySoundId(self.lottery_audio_effect)
        self.lottery_audio_effect = nil
    end
    if status then
        self.lottery_audio_effect = AudioManager:getInstance():playEffectForHandAudoRemove(AudioManager.AUDIO_TYPE.COMMON,"c_turntable_game", false)
    end
end

--
function ActionTreasureWindow:sendTreasureLottery(index)
    if not self.cur_index then return end

    if self.touchEnable == true then
        message(TI18N("探宝进行中"))
        return
    end
    self.cur_index = self.cur_index or 1
    if index == 3 then
        local role_vo = RoleController:getInstance():getRoleVo()
        if role_vo.gold < treasure_const.refreash.val[1][2] and self.touchEffect[self.cur_index] == false then 
            message(TI18N("钻石不足")) 
            return 
        end
        if self.touchRefresh == true then
            message(TI18N("刷新中..."))
            return
        end
        self.touchRefresh = true
        self:runLightUniformSpeedHide()
        self:startRefreshAction()
    else
        -- if self.hasTreasure_num[self.cur_index] > 0 then
        --     self.lottery_audio_effect = AudioManager:getInstance():playEffectForHandAudoRemove(AudioManager.AUDIO_TYPE.COMMON,"c_turntable_game", false)
        -- end
        local data = model:getBuyRewardData(self.cur_index)
        self.touchEnable = true
        local _bool = MainuiController:getInstance():checkIsOpenByActivate(data[index].limit_open)
        if _bool == true then
            self.touchTreasure_type = index
        else
            self.touchEnable = false
        end
        controller:send16638(self.cur_index, index)
    end
end
--更改探宝劵
function ActionTreasureWindow:changeTreasureNumber(list)
    for i,v in pairs(list) do
        if v.base_id == 37001 then
            self.hasTreasure_num[1] = BackpackController:getInstance():getModel():getBackPackItemNumByBid(37001)
            if self.cur_index == 1 then
                local item_config = Config.ItemData.data_get_data(37001)
                local res = PathTool.getItemRes(item_config.icon)
                local str = string_format("<img src='%s' scale=0.5 />  %d",res,self.hasTreasure_num[1])
                self.treasure_total:setString(str)
            end
        elseif v.base_id == 37002 then
            self.hasTreasure_num[2] = BackpackController:getInstance():getModel():getBackPackItemNumByBid(37002)
            if self.cur_index == 2 then
                local item_config = Config.ItemData.data_get_data(37002)
                local res = PathTool.getItemRes(item_config.icon)
                local str = string_format("<img src='%s' scale=0.5 />  %d",res,self.hasTreasure_num[2])
                self.treasure_total:setString(str)
            end
        end
    end
end

local slow_start = 3--开始减少灯的个数
function ActionTreasureWindow:runHandler()
    if self.step == 0 then
        self.process = self.process + 0.33
        if self.process >= 3 then
            self.step = 1
            self.speed = 0.9
        end
    elseif self.step == 1 then
        self.process = self.process+self.speed
        if self.process > ROUND_COUNT*self.round and self.targetPos > -1 then
            if self.targetPos > 3 then
                if (self.process % ROUND_COUNT) > slow_start then
                    self.speed = 0.04
                    self.step = 2
                end
            else
                if self.targetPos <= slow_start then
                    if (self.process % (ROUND_COUNT*self.round)) >= (self.targetPos-slow_start+ROUND_COUNT) then
                        self.speed = 0.04
                        self.step = 2
                    end
                end
            end
        end
    elseif self.step == 2 then
        self.process = self.process+self.speed
        local index = math.floor(self.process)
        if self.cur_effect_index ~= index then
            self.cur_effect_index = index
            -- print("******** self.cur_effect_index *********",self.cur_effect_index)
            if self.stop_audio_effect then
                AudioManager:getInstance():removeEffectBySoundId(self.stop_audio_effect)
            end
            self.stop_audio_effect = AudioManager:getInstance():playEffectForHandAudoRemove(AudioManager.AUDIO_TYPE.COMMON,"c_turntable_game_1", false)
        end

        if (self.process % ROUND_COUNT >= self.targetPos) and math.floor(self.process / ROUND_COUNT) >= 5 then
            if self.lottery_ticket ~= nil then
                GlobalTimeTicket:getInstance():remove(self.lottery_ticket)
                self.lottery_ticket = nil
                self.cur_effect_index = nil
                self:showLotteryAudioEffect(false)
                AudioManager:getInstance():removeEffectBySoundId(self.stop_audio_effect)
                -- print("跑灯结束~~~~~~")
                self:stopRunHandler()
            end
        end
    end
    local p,_ = math.modf(self.process)
    self:setPos(p)
end

function ActionTreasureWindow:setPos(pos)
    if pos <= 0 then
        pos  = pos + ROUND_COUNT
    elseif pos >= ROUND_COUNT then
        pos = pos % ROUND_COUNT
    end
    self.run_light:setVisible(true)
    self.run_light:setPosition(reward_pos[change_pos[pos]][1],reward_pos[change_pos[pos]][2])
end
--跑灯结束
function ActionTreasureWindow:stopRunHandler()
    self.touchEnable = false

    if self.run_light_show_reward == nil then
        self.run_light_show_reward = GlobalTimeTicket:getInstance():add(function()
            if not tolua.isnull(self.run_light) then
                self:runLightReward()
                self.showRewardList = nil
                self:runLightUniformSpeed()
            end
        end,1.0,1)
    end
end
--抽奖奖励
function ActionTreasureWindow:runLightReward()
    if self.showRewardList then
        local award = {}
        for i,v in ipairs(self.showRewardList.awards1) do
            if v then
                table.insert(award, v)
            end
        end
        for i,v in ipairs(self.showRewardList.awards2) do
            if v then
                table.insert(award, v)
            end
        end
        --类型， 次数类型
        controller:openTreasureGetItemWindow(true, award, self.cur_index, self.touchTreasure_type)
    end
    local initData = model:getTreasureInitData(self.cur_index)
    if initData then
        self:itemRewardPos(initData.rand_lists)
    end
    self.showRewardList = nil
end

function ActionTreasureWindow:runLightUniformSpeedHide()
    self.run_light:setVisible(false)
    if self.open_view_ticket ~= nil then
        GlobalTimeTicket:getInstance():remove(self.open_view_ticket)
        self.open_view_ticket = nil
    end
    if self.run_light_show_reward ~= nil then
        GlobalTimeTicket:getInstance():remove(self.run_light_show_reward)
        self.run_light_show_reward = nil
    end
end
--没有跑灯的时候匀速跑
function ActionTreasureWindow:runLightUniformSpeed()
    if self.open_view_ticket == nil then
        self.open_view_ticket = GlobalTimeTicket:getInstance():add(function()
            if not tolua.isnull(self.run_light) then
                self.run_light:setVisible(true)
                self.status_count = self.status_count % ROUND_COUNT
                self.run_light:setPosition(reward_pos[change_pos[self.status_count]][1],reward_pos[change_pos[self.status_count]][2])
                self.status_count = self.status_count + 1
            end
        end,0.5)
    end
end

function ActionTreasureWindow:getActionFunc(node)
    if not node then return end
    local fadeout = cc.FadeOut:create(0.07)
    node:runAction(fadeout)
end

function ActionTreasureWindow:startRefreshAction()
    local openSingle = {}
    for i=1, 8 do
        local function test()
            if self.item_list[i] then
                self:getActionFunc(self.item_list[i])
            end
        end
        openSingle[i] = cc.CallFunc:create(test)
    end
    local actionNode = cc.Node:create()
    self.item_panel:addChild(actionNode)
    local function func()
        controller:send16642(self.cur_index)
        self:handleEffect()
    end
    actionNode:runAction(cc.Sequence:create(openSingle[1],openSingle[2],openSingle[3],openSingle[4],openSingle[5],openSingle[6],
                                            openSingle[7],openSingle[8],openSingle[9],openSingle[10],openSingle[11],openSingle[12],  
                                            cc.CallFunc:create(func),cc.RemoveSelf:create(true)))
end
--特效
function ActionTreasureWindow:handleEffect()
    local function func()
        self.touchRefresh = false
        local initData = model:getTreasureInitData(self.cur_index)
        self:itemRewardPos(initData.rand_lists)
    end
    playEffectOnce(PathTool.getEffectRes(614),self.item_panel:getContentSize().width*0.5,self.item_panel:getContentSize().height*0.5,
                    self.item_panel,func, nil, nil, nil, PlayerAction.action_1, 1)
end

function ActionTreasureWindow:close_callback( )
    doStopAllActions(self.refresh_time)
    if self.lottery_ticket ~= nil then
        GlobalTimeTicket:getInstance():remove(self.lottery_ticket)
        self.lottery_ticket = nil
    end
    self:showLotteryAudioEffect(false)
    AudioManager:getInstance():removeEffectBySoundId(self.stop_audio_effect)
    if self.item_list and next(self.item_list or {}) ~= nil then
        for i, v in ipairs(self.item_list) do
            if v and v.DeleteMe then
                v:DeleteMe()
            end
        end
    end
    
    if self.luckly_item and next(self.luckly_item or {}) ~= nil then
        for i, v in ipairs(self.luckly_item) do
            if v and v.DeleteMe then
                v:DeleteMe()
            end
        end
    end

    if self.item_load then
        self.item_load:DeleteMe()
    end
    self.item_load = nil

    for i,v in pairs(self.round_certer_load) do
        if v and v.DeleteMe then
            v:DeleteMe()
        end
        v = nil
    end

    self:runLightReward()

    doStopAllActions(self.probablity)
    self:runLightUniformSpeedHide()
    controller:openLuckyTreasureWin(false)
end
