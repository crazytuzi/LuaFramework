--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-05-11 11:58:40
-- @description    : 
		-- 穿戴神装套装提示
---------------------------------
local _controller = HeroController:getInstance()
local _model = HeroController:getInstance():getModel()
local _string_format = string.format
local _table_insert = table.insert

HolyequipmentWearTips = HolyequipmentWearTips or BaseClass(BaseView)

function HolyequipmentWearTips:__init()
    self.is_full_screen = false  
    self.win_type = WinType.Mini 
    self.view_tag = ViewMgrTag.DIALOGUE_TAG  
    self.layout_name = "hero/hero_holy_wear_tips"

    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("hero", "hero"), type = ResourcesType.plist},
    }
    
    self.item_node_list = {}
    self.enter_status = false
end

function HolyequipmentWearTips:open_callback()
	self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.main_panel = self.root_wnd:getChildByName("main_panel")

    local title_container = self.main_panel:getChildByName("title_container")
    self:playEnterAnimatianByObj(title_container , 2) 
    title_container:getChildByName("title_label"):setString(TI18N("提示"))

    self.close_btn = self.main_panel:getChildByName("close_btn")
    self.confirm_btn = self.main_panel:getChildByName("confirm_btn")
    self.confirm_btn:getChildByName("label"):setString(TI18N("确 定"))
    self.cancel_btn = self.main_panel:getChildByName("cancel_btn")
    self.cancel_btn:getChildByName("label"):setString(TI18N("取 消"))
    self.box_btn = self.main_panel:getChildByName("box_btn")
    self.box_btn:getChildByName("name"):setString(TI18N("今日不再提示"))

    self.tips_label = createRichLabel(24, 274, cc.p(0.5, 0.5), cc.p(325, 458), 5, nil, 594)
    self.main_panel:addChild(self.tips_label)
end

function HolyequipmentWearTips:register_event()
    registerButtonEventListener(self.background, handler(self, self.handleCbSelectStatus), true, 2)

	registerButtonEventListener(self.close_btn, handler(self, self.handleCbSelectStatus), true, 2)

	registerButtonEventListener(self.confirm_btn, function()
		_controller:sender25224(self.hero_vo.partner_id, self.id) --装配方案
        SysEnv:getInstance():save() --点确定才保存勾选框状态
		_controller:openHolyequipmentWearTips(false)
	end, true, 1)

	registerButtonEventListener(self.cancel_btn, handler(self, self.handleCbSelectStatus), true, 1)

	self.box_btn:addEventListener(function(sender,event_type)
        if event_type == ccui.CheckBoxEventType.selected then
            playButtonSound2()
            SysEnv:getInstance():set(SysEnv.keys.holy_plan_wear_tip, true, false) 
        elseif event_type == ccui.CheckBoxEventType.unselected then 
            playButtonSound2()
            SysEnv:getInstance():set(SysEnv.keys.holy_plan_wear_tip, false, false)
        end
    end)
end

--放弃当前勾选框修改的状态
function HolyequipmentWearTips:handleCbSelectStatus()
    local status = SysEnv:getInstance():getBool(SysEnv.keys.holy_plan_wear_tip, false)
    if status ~= self.enter_status then
        SysEnv:getInstance():set(SysEnv.keys.holy_plan_wear_tip, self.enter_status, false)
    end
    _controller:openHolyequipmentWearTips(false)
end

function HolyequipmentWearTips:openRootWnd(holy_data)
	self.holy_data = holy_data
	self.id = holy_data.id
	self.name = holy_data.name
	self.hero_vo = holy_data.hero_vo
	self.item_list = holy_data.item_list
	
	self:setData()
end

function HolyequipmentWearTips:setData()
	if not self.holy_data then return end

    local desc_str = _string_format(TI18N("为<div fontcolor=249003>【%s】</div>装配方案，会将以下神装从这些宝可梦中卸下，是否继续？"), self.hero_vo.name)
    self.tips_label:setString(desc_str)

    local status = SysEnv:getInstance():getBool(SysEnv.keys.holy_plan_wear_tip, false)
    self.box_btn:setSelected(status)

    self.enter_status = status

    local type_list = {} --按类型装载神装数据
    for i=1,4 do
        local holy_type = HeroConst.HolyequipmentPosList[i]
        if self.item_list[holy_type] then
            _table_insert(type_list, self.item_list[holy_type])
        end
    end
    local item_count = tableLen(self.item_list)
    if item_count > 0 then
    	local start_x = 102
        if item_count < 4 then
            start_x = start_x + (4 - item_count) * 75
        end
    	for i=1,#type_list do
    		local item = self.item_node_list[i]
    		local holy_type = HeroConst.HolyequipmentPosList[i]
    		if not item then
    			item = HolyequipmentWearItem.new(holy_type)
    			self.main_panel:addChild(item)
    			self.item_node_list[i] = item
    		end
    		if type_list[i] then
    			item:setData(type_list[i])
    		end
    		item:setPosition(cc.p(start_x + (i-1)*(138+10), 268))
    	end
    end
end

function HolyequipmentWearTips:close_callback()
	for k,v in pairs(self.item_node_list) do
		v:DeleteMe()
		v = nil
	end
	_controller:openHolyequipmentWearTips(false)
end

-----------------------------@ item
HolyequipmentWearItem = class("HolyequipmentWearItem", function()
    return ccui.Widget:create()
end)

function HolyequipmentWearItem:ctor(holy_type)
	self.holy_type = holy_type

	self:config()
    self:layoutUI()
end

function HolyequipmentWearItem:config()
	self.size = cc.size(119, 295)
    self:setContentSize(self.size)
end

function HolyequipmentWearItem:layoutUI()
    self.container = ccui.Layout:create()
    self.container:setContentSize(self.size)
    self:addChild(self.container)

    local sp_line = createSprite(PathTool.getResFrame("common","common_90097"), self.size.width/2, self.size.height/2, self.container, cc.p(0.5, 0.5))

    self.holy_item = BackPackItem.new(false,true,nil,1,false)
    self.holy_item:setDefaultTip(true,false)
    self.holy_item:setPosition(cc.p(self.size.width/2, self.size.height*3/4))
    self.container:addChild(self.holy_item)
    local empty_res = PathTool.getResFrame("hero", HeroConst.HolyEmptyIconName[self.holy_type])
    local empty_icon = createImage(self.holy_item:getRoot(), empty_res,60,60, cc.p(0.5,0.5), true, 10, false)
    self.holy_item.empty_icon = empty_icon

    self.hero_item = HeroExhibitionItem.new(1, false)
    self.hero_item:setPosition(cc.p(self.size.width/2, self.size.height/4))
    self.container:addChild(self.hero_item)
end

function HolyequipmentWearItem:setData(data)
	if not data then return end
	if data.item_vo then
        self.holy_item:setData(data.item_vo)
        if self.holy_item.empty_icon then 
            self.holy_item.empty_icon:setVisible(false)
        end
        self.holy_item.data = data.item_vo
    else
        self.holy_item:setData()
        if self.holy_item.empty_icon then 
            self.holy_item.empty_icon:setVisible(true)
        end
        self.holy_item.data = nil
    end
    if data.partner_id then
    	local hero_vo = _model:getHeroById(data.partner_id)
    	self.hero_item:setData(hero_vo)
    end
end

function HolyequipmentWearItem:DeleteMe()
	if self.holy_item then
		self.holy_item:DeleteMe()
		self.holy_item = nil
	end
	if self.hero_item then
		self.hero_item:DeleteMe()
		self.hero_item = nil
	end
end