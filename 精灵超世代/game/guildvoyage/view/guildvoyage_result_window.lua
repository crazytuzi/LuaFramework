-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      公会远航结算界面
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
GuildvoyageResultWindow = GuildvoyageResultWindow or BaseClass(BaseView)

local controller = GuildvoyageController:getInstance()
local model = controller:getModel()
local table_insert = table.insert

function GuildvoyageResultWindow:__init()
	self.order_type = type
	self.win_type = WinType.Mini
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.is_init = false
	self.res_list = {
	}
	self.layout_name = "guildvoyage/guildvoyage_result_window"
    self.effect_cache_list = {}
    self.item_list = {}
end 

function GuildvoyageResultWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    local container = self.root_wnd:getChildByName("container")
    container:getChildByName("rewards_title_1"):setString(TI18N("固定奖励"))
    container:getChildByName("rewards_title_2"):setString(TI18N("概率奖励"))

    self.title_container = self.root_wnd:getChildByName("title_container")
    self.title_width = self.title_container:getContentSize().width
    self.title_height = self.title_container:getContentSize().height

    self.desc = container:getChildByName("desc")
    self.desc:setString(TI18N("概率奖励未获得"))  -- 183(未获得颜色)  11ff32(已获得)

    self.main_width = container:getContentSize().width
    self.container = container 
end

function GuildvoyageResultWindow:register_event()
    self.background:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then 
            controller:openGuildvoyageResultWindow(false)
        end
    end)
end

function GuildvoyageResultWindow:openRootWnd(order_id, is_success, is_double)
    playOtherSound("c_get") 
    self:handleEffect(true)
    local order = model:getOrderById(order_id)
    self.is_success = is_success
    self.is_double = is_double
    if order and order.config then
        self:createRewardsList(order.config.rewards)
        self:createRandRewardsList(order.config.rand_rewards)
        if is_success == TRUE then
            self.desc:setTextColor(cc.c4b(0x11,0xff,0x32,0xff))
            self.desc:setString(TI18N("概率奖励已获得"))
        else
            self.desc:setTextColor(Config.ColorData.data_color4[183])
            self.desc:setString(TI18N("概率奖励未获得")) 
        end
    end
end

function GuildvoyageResultWindow:handleEffect(status)
	if status == false then
		if self.play_effect then
			self.play_effect:clearTracks()
			self.play_effect:removeFromParent()
			self.play_effect = nil
		end
	else
        if not tolua.isnull(self.title_container) and self.play_effect == nil then
            self.play_effect = createEffectSpine(PathTool.getEffectRes(103), cc.p(self.title_width * 0.5, self.title_height * 0.5), cc.p(0.5, 0.5), false, PlayerAction.action_1)
            self.title_container:addChild(self.play_effect, 1)
        end
	end
end 

--==============================--
--desc:创建固定奖励
--time:2018-06-26 05:56:35
--@return 
--==============================--
function GuildvoyageResultWindow:createRewardsList(list)
	if list == nil or next(list) == nil then return end
	local item_num = #list
    local space = 40
	local scale = 0.8
    local total_width = item_num * BackPackItem.Width * scale + ( item_num - 1 ) * space
    local start_x = ( self.main_width - total_width ) / 2
    local _x = 0
    local item = nil
    local rate = 1
    if self.is_double == TRUE then
        rate = 2
    end
    for i, v in ipairs(list) do
        if v[1] and v[2] then
            item = BackPackItem.new(false, true, false, scale, false, true)
            item:setBaseData(v[1], v[2] * rate)
            _x = start_x + (i - 1) * (BackPackItem.Width * scale + space) + BackPackItem.Width * scale * 0.5
            item:setPosition(_x, 367)
            self.container:addChild(item)
            table_insert(self.item_list, item)

            local item_config = Config.ItemData.data_get_data(v[1])
            if item_config then
                local item_name = createLabel(22, 1, nil, _x, 302, item_config.name, self.container, nil, cc.p(0.5, 0.5))
            end
        end
    end 
end

--==============================--
--desc:创建随机奖励
--time:2018-06-26 05:56:52
--@return 
--==============================--
function GuildvoyageResultWindow:createRandRewardsList(list)
	if list == nil or next(list) == nil then return end
	local item_num = #list
    local space = 40
	local scale = 0.8
    local total_width = item_num * BackPackItem.Width * scale + ( item_num - 1 ) * space
    local start_x = ( self.main_width - total_width ) / 2
    local _x = 0
    local item = nil
    local rate = 1
    if self.is_double == TRUE then
        rate = 2
    end
    for i, v in ipairs(list) do
        if v[1] and v[2] then
            item = BackPackItem.new(false, true, false, scale, false, true)
            item:setBaseData(v[1], v[2] * rate)
            _x = start_x + (i - 1) * (BackPackItem.Width * scale + space) + BackPackItem.Width * scale * 0.5
            item:setPosition(_x, 165)
            self.container:addChild(item)
            table_insert(self.item_list, item)

            local item_config = Config.ItemData.data_get_data(v[1])
            if item_config then
                local item_name = createLabel(22, 1, nil, _x, 100, item_config.name, self.container, nil, cc.p(0.5, 0.5))
            end
            if self.is_success == FALSE then
                setChildUnEnabled(true, item)
            end
        end
    end 
end 

function GuildvoyageResultWindow:close_callback()
    for k,item in pairs(self.item_list) do
        item:DeleteMe()
    end
    self.item_list = nil

    self:handleEffect(false) 
    controller:openGuildvoyageResultWindow(false)
end