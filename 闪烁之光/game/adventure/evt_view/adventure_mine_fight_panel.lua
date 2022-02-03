-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      冒险准备战斗 和 矿脉管理
-- <br/> 2019年7月16日
-- --------------------------------------------------------------------
AdventureMineFightPanel = AdventureMineFightPanel or BaseClass(BaseView)

local controller = AdventureController:getInstance()
local model = controller:getUiModel()
local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort


function AdventureMineFightPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Big   
    self.is_full_screen = false
    self.layout_name = "adventure/adventure_mine_fight_panel"

    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("adventure","adventuremine"), type = ResourcesType.plist },
    }

    --英雄对象
    self.hero_item_list = {}

       --收费次数
    local config = Config.AdventureMineData.data_const.diamond_attack
    if config then
        self.max_buy_count = config.val
    else
        self.max_buy_count = 3    
    end
end

function AdventureMineFightPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 1)
    self.main_panel = self.main_container:getChildByName("main_panel")

    self.title = self.main_panel:getChildByName("win_title")
    -- self.title:setString(TI18N("战斗记录"))

    --战斗力
    local  power_click = self.main_container:getChildByName("power_click")
    self.fight_label = CommonNum.new(20, power_click, 0, - 2, cc.p(0.5, 0.5))
    self.fight_label:setPosition(103, 28)

    self.mine_icon = self.main_container:getChildByName("mine_icon")
    self.mine_name = self.main_container:getChildByName("mine_name")

    self.player_name_key = self.main_container:getChildByName("player_name_key")
    self.player_name = self.main_container:getChildByName("player_name")
    self.put_info_key = self.main_container:getChildByName("put_info_key")
    self.put_info_key:setString(TI18N("灵矿产出："))
    self.put_info = createRichLabel(24, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0,0.5), cc.p(435, 526), 6, nil, 900)
    self.main_container:addChild(self.put_info)
    --地方阵容 和 我方阵容
    self.desc1 = self.main_container:getChildByName("desc1")
    self.desc2 = self.main_container:getChildByName("desc2")
    self.fight_count = createRichLabel(22, cc.c4b(0xff,0xf2,0xc7,0xff), cc.p(1,0.5), cc.p(652, 256), 6, nil, 900)
    self.main_container:addChild(self.fight_count)

    self.challenge_btn = self.main_container:getChildByName("challenge_btn")
    self.challenge_btn:getChildByName("label"):setString(TI18N("挑 战"))

    self.left_btn = self.main_container:getChildByName("left_btn")
    self.left_btn:getChildByName("label"):setString(TI18N("放弃占领"))
    self.center_btn = self.main_container:getChildByName("center_btn")
    self.center_btn:getChildByName("label"):setString(TI18N("防守布阵"))

    self.hero_node = self.main_container:getChildByName("hero_node")
    self.item_scrollview = self.main_container:getChildByName("item_scrollview")
    self.item_scrollview:setScrollBarEnabled(false)
    -- self.close_btn = self.main_panel:getChildByName("close_btn")
    local label_color = Config.ColorData.data_color4[175]
    self.empty_label = createLabel(26, label_color, nil, 350, 170, TI18N("暂无收益"), self.main_container, 0, cc.p(0.5, 0.5)) 
end

function AdventureMineFightPanel:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickBtnClose) ,false, 1)
    -- registerButtonEventListener(self.close_btn, handler(self, self.onClickBtnClose) ,true, 2)

    registerButtonEventListener(self.challenge_btn, handler(self, self.onClickBtnChallenge) ,true, 2)
    registerButtonEventListener(self.left_btn, handler(self, self.onClickBtnLeft) ,true, 2)
    registerButtonEventListener(self.center_btn, handler(self, self.onClickBtnCenter) ,true, 2)


    
    self:addGlobalEvent(AdventureEvent.ADVENTURE_MINE_SINGLE_INFO_EVENT, function(data)
        if not data then return end
        self:setData(data)
    end)

    --放弃占领
    self:addGlobalEvent(AdventureEvent.ADVENTURE_MINE_GIVE_UP_OCCUPY_EVENT, function(data)
        self:onClickBtnClose()
    end)

    --购买次数
    -- self:addGlobalEvent(AdventureEvent.ADVENTURE_MINE_BUY_COUNT_EVENT, function(data)
    --     if not data then return end
    --     self:onClickBtnChallenge({is_occupy_count = true, is_buy_count = true })
    -- end)
    --保存布阵返回
    self:addGlobalEvent(AdventureEvent.ADVENTURE_MINE_SAVE_BACK_EVENT, function(mine_pos_info, id, hallows_id)
        if not mine_pos_info then return end
        for i,v in ipairs(mine_pos_info) do
            local hero_vo = HeroController:getInstance():getModel():getHeroById(v.id)
            if hero_vo then
                v.id = hero_vo.id
                v.bid = hero_vo.bid
                v.lev = hero_vo.lev
                v.star = hero_vo.star
                v.use_skin = hero_vo.use_skin
            end
        end
        if self.scdata then
            self.scdata.defense = mine_pos_info
            self.scdata.id = id
            self.scdata.hallows_id = hallows_id
            self:updateHeroList()
        end
    end)
end

--关闭
function AdventureMineFightPanel:onClickBtnClose()
    controller:openAdventureMineFightPanel(false)
end

--挑战
function AdventureMineFightPanel:onClickBtnChallenge(setting)
    if not self.scdata then return end
    if not self.floor then return end
    if not self.room_id then return end

    if self:checkTimeInfo() then
        return
    end
    if not self.max_buy_count then return end
    local buy_count = model:getMineBuyCount()
    if not buy_count then return end
    local challenge_count = model:getChallengeCount()
    if challenge_count == 0 then
        if buy_count >= self.max_buy_count then
                message(TI18N("已达到今日挑战次数上限"))
            return
        end
    end
    
    local setting = setting or {}
    if not setting.is_occupy_count then
        if self:checkMaxOccupyInfo() then
            return
        end
    end

    if not setting.is_buy_count then
        local challenge_count = model:getChallengeCount()
        if challenge_count == 0 then
            self:onBuyBtn()
            return
        end
    end
    if self:checkLayerInfo() then
        return
    end
    self:onFormGoFight() 
end

function AdventureMineFightPanel:onFormGoFight()
    local setting = {}
    setting.floor = self.floor
    setting.room_id = self.room_id
    HeroController:getInstance():openFormGoFightPanel(true, PartnerConst.Fun_Form.Adventure_Mine, setting)
end
--检查时间
function AdventureMineFightPanel:checkTimeInfo()
    if not self.scdata then return end
    local config = Config.AdventureMineData.data_const.protect_time
    if config then
        local time = config.val * 60
        local less_time = time - (GameNet:getInstance():getTime() - self.scdata.occupy_time)
        if less_time > 0 then 
            local min = math.floor(less_time/60)
            if min > 0 then
                message(string_format(TI18N("该灵矿现在还不能进攻哦，%s分钟后再来吧！"), min))    
            else
                local sec = math.floor(less_time % 60)    
                message(string_format(TI18N("该灵矿现在还不能进攻哦，%s秒后再来吧！"), sec))    
            end
            return true
        end
    end
    return false
end

--检查是否占领矿脉上限
function AdventureMineFightPanel:checkMaxOccupyInfo()
    local count = model:getMineOccupyCount() or 0
    local max_count = model:getMineLockCount() or 0
    if count >= max_count then
        local msg = TI18N("当前灵矿占领数量已达上限,确定进攻吗?")
        CommonAlert.show(msg, TI18N("确定"), function()
            self:onClickBtnChallenge({is_occupy_count = true})
        end, TI18N("取消"), nil, nil, nil, {title = TI18N("提示")}, nil, nil) 
        return true
    end
    return false
end

function AdventureMineFightPanel:onBuyBtn()
    local item_id =  Config.ItemData.data_assets_label2id.gold 
    local count =  50
    local config = Config.AdventureMineData.data_const.diamond_cost
    if config then
        count = config.val
    end
    local iconsrc = PathTool.getItemRes(Config.ItemData.data_get_data(item_id).icon)
    local str = string_format(TI18N("挑战次数不足, 是否花费 <img src='%s' scale=0.3 /> %s购买一次挑战次数？"), iconsrc, count)
    
    local call_back = function()
        controller:send20655()
    end
    CommonAlert.show(str, TI18N("确定"), call_back, TI18N("取消"), nil, CommonAlert.type.rich) 
end

--检查衰减层
function AdventureMineFightPanel:checkLayerInfo()
    if not self.config then return  end
    if not self.floor then return  end
    if next(self.config.hook_items) == nil then return end

    local num = self.config.hook_items[1][2]
    local dec_rate, rate = model:getMineRate(self.floor, num)
    dec_rate = num - dec_rate --衰减值
    if  dec_rate > 0 then
        rate = rate or 0
        rate = rate/10
        local msg = TI18N("确定进攻该层灵矿吗？")
        local extend_msg = string_format(TI18N("(因层数过低, 该层灵矿收益将会减少%s%%)"), rate)
        self.alert = CommonAlert.show(msg, TI18N("确定"), function()
            self:onFormGoFight()
            if self.alert then
                self.alert:close()
                self.alert = nil
            end
        end, TI18N("取消"), nil, nil, nil, {off_y = 43, title = TI18N("提示"), extend_str = extend_msg, extend_offy = -5, extend_aligment = cc.TEXT_ALIGNMENT_CENTER }, nil, nil) 
        return true
    end
    return false
end




--放弃占领
function AdventureMineFightPanel:onClickBtnLeft()
    if not self.scdata then return end
    if not self.floor then return end
    if not self.room_id then return end

     local msg = TI18N("确定要放弃占领吗？")
    local extend_msg = TI18N("(放弃后只能获得当前累积收益)")
    CommonAlert.show(msg, TI18N("确定"), function()
        controller:send20651(self.floor, self.room_id)
    end, TI18N("取消"), nil, nil, nil, {timer = 3, timer_for = true, off_y = 43, title = TI18N("提示"), extend_str = extend_msg, extend_offy = -5, extend_aligment = cc.TEXT_ALIGNMENT_CENTER }, nil, nil) 
end
--防守阵营
function AdventureMineFightPanel:onClickBtnCenter()
    if not self.scdata then return end
    if not self.floor then return end
    if not self.room_id then return end
    local setting = {}
    setting.floor = self.floor
    setting.room_id = self.room_id
    setting.defense = self.scdata.defense
    setting.formation_type = self.scdata.id
    setting.hallows_id = self.scdata.hallows_id
    HeroController:getInstance():openAdventureMineFormGoFightPanel(true, PartnerConst.Fun_Form.Adventure_Mine_Def, setting, HeroConst.FormShowType.eFormSave)
end
--@setting.show_type 显示类型 0表示中立怪的准备战斗 1 表示 准备战斗  2 表示管理
function AdventureMineFightPanel:openRootWnd(setting)
    local setting = setting or {}
    self.show_type = setting.show_type or 1
    self.floor = setting.floor 
    self.room_id = setting.room_id
    if not self.floor or not self.room_id then return end
    controller:send20641(self.floor, self.room_id)
end

function AdventureMineFightPanel:setData(data)
    self.scdata = data

    self.config = Config.AdventureMineData.data_mine_data(self.scdata.mine_id)
    if not self.config then return end

    local res_id = self.config.res_id
    if res_id == nil or res_id == "" then
        res_id = 1001
    end
    local res = PathTool.getPlistImgForDownLoad("adventure/mine_icon", res_id, false)
    if self.record_res == nil or self.record_res ~= res then
        self.record_res = res
        self.item_load = loadSpriteTextureFromCDN(self.mine_icon, res, ResourcesType.single, self.item_load) 
    end
    self.mine_name:setString(self.config.name)
    self.fight_label:setNum(self.scdata.power)

    if next(self.config.hook_items) ~= nil then
        local item_id = self.config.hook_items[1][1]
        local num = self.config.hook_items[1][2]
        
        local item_config  = Config.ItemData.data_get_data(item_id)
        local res = PathTool.getItemRes(item_config.icon)

        self.base_data = model:getAdventureBaseData()
         -- 计算衰减
        if self.base_data then
            local dec_rate = model:getMineRate(self.floor, num)
            dec_rate = num - dec_rate --衰减值
            if dec_rate and dec_rate > 0 then
                --有衰减
                self.put_info:setString(string_format(TI18N("<img src=%s scale=0.3 /><div fontcolor=#d95014>%s/m(-%s)</div>"),res, num, dec_rate))    
            else
                --无衰减 
                self.put_info:setString(string_format(TI18N("<img src=%s scale=0.3 /><div fontcolor=#643223>%s/m</div>"),res, num))    
            end
        else
            --容错用的
            self.put_info:setString(string_format(TI18N("<img src=%s scale=0.3 /><div fontcolor=#643223>%s/m</div>"),res, num))    
        end
    end

    if self.show_type == 1 or self.show_type == 0 then --准备战斗
        self.title:setString(TI18N("准备进攻"))
        self.player_name_key:setString(TI18N("当前领主："))
        self.player_name:setString(self.scdata.name)

        self.desc1:setString(TI18N("敌方阵容"))
        if self.show_type == 0 then
            self.desc2:setVisible(false)
            self.fight_count:setVisible(false)
        else
            self.desc2:setString(TI18N("可掠夺资源"))
            self.fight_count:setString(string_format(TI18N("剩余可掠夺次数：<div fontcolor=#92ff75>%s</div>"), self.scdata.plunder_count))
        end

        self.challenge_btn:setVisible(true)
        self.left_btn:setVisible(false)
        self.center_btn:setVisible(false)
    else--矿脉管理
        self.title:setString(TI18N("矿脉管理"))
        self.player_name_key:setString(TI18N("已占领："))
        local time = GameNet:getInstance():getTime() - self.scdata.occupy_time
        self:setLessTime(time)

        self.desc1:setString(TI18N("防守阵容"))
        self.desc2:setString(TI18N("当前累计收益"))
        self.fight_count:setString(string_format(TI18N("被掠夺次数：<div fontcolor=#92ff75>%s</div>"), self.scdata.plunder_count))

        self.challenge_btn:setVisible(false)
        self.left_btn:setVisible(true)
        self.center_btn:setVisible(true)
    end

    self:updateHeroList()
    self:updateItem()
end

--设置倒计时
function AdventureMineFightPanel:setLessTime( less_time )
    if tolua.isnull(self.player_name) then return end
    doStopAllActions(self.player_name)
    self.player_name:setString(TimeTool.GetTimeForFunction(less_time))
    self.player_name:runAction(cc.RepeatForever:create(cc.Sequence:create(
        cc.DelayTime:create(1), cc.CallFunc:create(function()
        less_time = less_time + 1
        self.player_name:setString(TimeTool.GetTimeForFunction(less_time))
    end)
    )))
end

--更新阵容
function AdventureMineFightPanel:updateHeroList()
    if not self.hero_node then return end
    if not self.scdata then return end

    self.hero_list = self.scdata.defense
    if not self.hero_list then return end
    table.sort(self.hero_list, function(a, b) return a.pos < b.pos end)
    for i,v in ipairs(self.hero_list) do
        v.rid = self.scdata.rid
        v.srv_id = self.scdata.srv_id
    end

    for i,v in ipairs(self.hero_item_list) do
        v:setVisible(false)
    end

    local item_width = 124
    local x = -item_width * 5 * 0.5 + item_width * 0.5

    for i,v in ipairs(self.hero_list) do
        if self.hero_item_list[i] == nil then
            self.hero_item_list[i] = HeroExhibitionItem.new(0.9, true)
            self.hero_item_list[i]:setPosition(x + (i - 1) * item_width, 0)
            self.hero_item_list[i]:addCallBack(function() self:onClickHeroItemByIndex(i) end)
            self.hero_node:addChild(self.hero_item_list[i])
        else
            self.hero_item_list[i]:setVisible(true)
        end
        self.hero_item_list[i]:setData(v)
    end
end

function AdventureMineFightPanel:onClickHeroItemByIndex(i)
    local  hero_vo = self.hero_list[i]
    if not hero_vo then return end

    if self.show_type == 0 then
        --机器人不用返回
    elseif self.show_type == 1 then
        --敌方的
        LookController:getInstance():sender11061(hero_vo.rid, hero_vo.srv_id, hero_vo.id)
    else
        --我防守阵容
        local hero_vo2 = HeroController:getInstance():getModel():getHeroById(hero_vo.id)
        if hero_vo2 then
            HeroController:getInstance():openHeroTipsPanel(true, hero_vo2)
        end
    end
end

--更新掠夺或者被掠夺item
function AdventureMineFightPanel:updateItem()
    if not self.scdata then return end
    local data_list = {}
    for i,v in ipairs(self.scdata.items) do
        table_insert(data_list, {v.item_id, v.num})
    end
    local setting = {}
    setting.scale = 0.9
    setting.max_count = 5
    setting.is_center = true
    self.item_list = commonShowSingleRowItemList(self.item_scrollview, self.item_list, data_list, setting)

    if #data_list == 0 then
        self.empty_label:setVisible(true)
    else
        self.empty_label:setVisible(false)
    end
end

function AdventureMineFightPanel:close_callback()

    if self.item_load then
        self.item_load:DeleteMe()
    end
    self.item_load = nil

    if self.fight_label then
        self.fight_label:DeleteMe()
    end
    self.fight_label = nil

    if self.hero_item_list then
        for i,v in ipairs(self.hero_item_list) do
            v:DeleteMe()
        end
        self.hero_item_list = nil
    end

    if self.item_list ~= nil then
        for k, v in pairs(self.item_list) do
            v:DeleteMe()
        end
    end
    doStopAllActions(self.player_name)
    controller:openAdventureMineFightPanel(false)
end