-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--     冒险一击必杀界面
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
AdventureShotKillWindow = AdventureShotKillWindow or BaseClass(BaseView)

local controller = AdventureController:getInstance()
local model = AdventureController:getInstance():getUiModel()
local string_format = string.format
local table_insert = table.insert
local game_net = GameNet:getInstance()

function AdventureShotKillWindow:__init()
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.win_type = WinType.Big
	self.index = 2
	self.layout_name = "adventure/adventure_shot_kill_window"
    self.evt_path = "resource/adventure/evt/%s.png"

    self.monster_list = {}

	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("adventure", "adventurewindow"), type = ResourcesType.plist},
	}
end 

function AdventureShotKillWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    local container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(container, 2)

    self.skill_name = container:getChildByName("skill_name")
    self.skill_desc = container:getChildByName("skill_desc")
    self.skill_num = container:getChildByName("skill_num")
    self.skill_num2 = container:getChildByName("skill_num2")

    self.empty_desc = container:getChildByName("empty_desc")
    self.empty_desc:setString(TI18N("暂无可击杀守卫"))

    self.choose_container = container:getChildByName("choose_container")
    self.choose_container:getChildByName("choose_title"):setString(TI18N("请选择使用目标"))
    self.total_width = self.choose_container:getContentSize().width

    self.cancen_btn = self.choose_container:getChildByName("cancen_btn")
    self.cancen_btn:getChildByName("label"):setString(TI18N("取消"))
    -- self.cancen_btn:setTitleColor(Config.ColorData.data_color4[1])
    -- self.cancen_btn:setTitleText(TI18N("取消"))
    -- self.cancen_btn_label = self.cancen_btn:getTitleRenderer()
    -- if self.cancen_btn_label ~= nil then
    --     self.cancen_btn_label:enableOutline(Config.ColorData.data_color4[278], 2)
    -- end
    self.confirm_btn = self.choose_container:getChildByName("confirm_btn")
    self.confirm_btn:getChildByName("label"):setString(TI18N("确定"))
    -- self.confirm_btn:setTitleColor(Config.ColorData.data_color4[1])
    -- self.confirm_btn:setTitleText(TI18N("确定"))
    -- self.confirm_btn_label = self.confirm_btn:getTitleRenderer()
    -- if self.confirm_btn_label ~= nil then
    --     self.confirm_btn_label:enableOutline(Config.ColorData.data_color4[277], 2)
    -- end

    self.buy_btn = container:getChildByName("buy_btn")
    self.buy_btn:getChildByName("label"):setString(TI18N("购买"))
end

function AdventureShotKillWindow:register_event()
	registerButtonEventListener(self.background, function()
        controller:openAdventureShotKillWindow(false)
	end, false, REGISTER_BUTTON_SOUND_CLOSED_TYPY)

    registerButtonEventListener(self.cancen_btn, function()
        controller:openAdventureShotKillWindow(false)
    end, false, REGISTER_BUTTON_SOUND_CLOSED_TYPY)

	registerButtonEventListener(self.buy_btn, function()
        if not self.config then return end
        local const_config = Config.AdventureData.data_adventure_const.poison_price
        if not const_config then return end
        if const_config.val and next(const_config.val) ~= nil then
            local item_id = const_config.val[1][1] or 3
            local price  = const_config.val[1][2] or 1
            --单次购买上限
            local limit_num = 5

            local count = BackpackController:getInstance():getModel():getItemNumByBid(bid)
            local has_buy = math.floor(count/price)
            if has_buy > limit_num then
                has_buy = limit_num
            end
            local data = {}
            -- data.item_bid = self.config.id
            data.name = self.config.name
            data.limit_num = limit_num --写死上限50
            data.has_buy = has_buy or 1
            data.price = price
            data.pay_type = item_id
            data.shop_type = MallConst.MallType.AdventureShotKillBuy
            -- data.is_show_limit_label = true
            MallController:getInstance():openMallBuyWindow(true, data)
        end

	end, true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)

	registerButtonEventListener(self.confirm_btn, function()
        if self.select_object == nil or self.select_object.data == nil then 
            message(TI18N("请选择击杀目标"))
            return   
        end
        if self.config then
            controller:send20607(self.config.id, self.select_object.data.id) 
        end
	end, false, REGISTER_BUTTON_SOUND_BUTTON_TYPY)

    self:addGlobalEvent(AdventureEvent.UpdateShotKillInfo, function(list) 
        self:updateMonsterList(list)
    end)

    self:addGlobalEvent(AdventureEvent.UpdateSkillInfo, function(data_list)
        if not self.config then return end
        if data_list then
            for i,v in ipairs(data_list) do
                if self.config.id == v.bid  then
                    self:updateCount(v.num)
                end
            end
        end
    end)
end

function AdventureShotKillWindow:openRootWnd(data)
    controller:send20611()
    if data and data.config then
        self.config = data.config
        self.use_count = data.use_count
        self.skill_name:setString(self.config.name)
        self.skill_desc:setString(TI18N("效果：")..self.config.desc)
        local num = data.num or 0
        self:updateCount(num)
    end
end

function AdventureShotKillWindow:updateCount(num)
    if not self.config then return end
    local max_num = self.config.max_num
    if max_num and max_num > 0 then

        local use_count = self.use_count or 0
        self.skill_num:setString(string_format(TI18N("本轮剩余使用次数：%s"), (max_num-use_count)))
        self.skill_num2:setString(string_format(TI18N("驱魂药剂剩余：%s"), num))
    else
        self.skill_num:setString(TI18N("剩余数量：")..num)
        self.skill_num2:setString("")
    end
end

function AdventureShotKillWindow:updateMonsterList(list)
    if list == nil or next(list) == nil then
        self.choose_container:setVisible(false)
        self.empty_desc:setVisible(true)
    else
        self.choose_container:setVisible(true)
        self.empty_desc:setVisible(false)

        local count = #list
        local tmp_width = count * 120 -- 总的个数需要的长度
        local start_x = ( self.total_width - tmp_width ) * 0.5
        -- 创建头像
        for i,v in ipairs(list) do
            self:createMonsterHead(v, i, start_x)
        end
    end
end

--==============================--
--desc:创建怪物头像
--time:2019-01-25 09:42:43
--@data:
--@index:
--@return 
--==============================--
function AdventureShotKillWindow:createMonsterHead(data, index, start_x)
    if data == nil or data.evt_id == nil then return end
    local evt_config = Config.AdventureData.data_adventure_event(data.evt_id)

    if evt_config == nil or evt_config.res_id == nil or evt_config.res_id[1] == nil or evt_config.res_id[1][2] == nil then return end
    if self.monster_list[data.evt_id] then return end
    local object = {}

    local container = ccui.Layout:create()
    container:setContentSize(cc.size(120, 120))
    container:setAnchorPoint(0.5, 0.5)
    container:setPosition(start_x + 60 + (index - 1) * 120, 142)
    container:setTouchEnabled(true)
    container:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
	    if event_type == ccui.TouchEventType.ended then 
            playButtonSound2()
            self:selectMonsterIcon(data.evt_id)
        end
    end)
    self.choose_container:addChild(container)


	local head = PlayerHead.new(PlayerHead.type.other, nil, nil, PathTool.getResFrame("common","common_1031"), nil, true)
	head:setPosition(60, 60)
	head:setHeadRes(evt_config.face)
	container:addChild(head)

    local select = createSprite(PathTool.getResFrame("adventure","adventurewindow_15",false,"adventurewindow"), 60, 60, container, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)
    local mark_icon = createSprite(PathTool.getResFrame("common","common_1043"), 42.5, 42.5, select, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)
    select:setVisible(false)

    local event_path = string_format(self.evt_path, evt_config.res_id[1][2]) 
    local background = createSprite(event_path, 60, 60, container, cc.p(0.5,0.5), LOADTEXT_TYPE)

    object.container = container
    object.head = head
    object.select = select
    object.data = data
    self.monster_list[data.evt_id] = object
end

function AdventureShotKillWindow:selectMonsterIcon(evt_id)
    if self.select_object and self.select_object.data and self.select_object.data.evt_id == evt_id then return end
    if self.select_object then
        self.select_object.select:setVisible(false)
        self.select_object = nil
    end
    self.select_object = self.monster_list[evt_id]
    if self.select_object then
        self.select_object.select:setVisible(true)
    end
end

function AdventureShotKillWindow:close_callback()
    for k, object in pairs(self.monster_list) do
        if object.head then
            object.head:DeleteMe()
        end
    end
    self.monster_list = nil
    self.config = nil
    controller:openAdventureShotKillWindow(false)
end
