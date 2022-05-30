--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-05-11 11:57:40
-- @description    : 
		-- 保存神装套装提示
---------------------------------
local _controller = HeroController:getInstance()
local _model = HeroController:getInstance():getModel()
local _string_format = string.format
local _table_insert = table.insert

HolyequipmentSaveTips = HolyequipmentSaveTips or BaseClass(BaseView)

function HolyequipmentSaveTips:__init()
    self.is_full_screen = false  
    self.win_type = WinType.Mini 
    self.view_tag = ViewMgrTag.DIALOGUE_TAG  
    self.layout_name = "hero/hero_holy_save_plan_tips"
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("hero", "hero"), type = ResourcesType.plist},
    }

    self.item_node_list = {}
    self.enter_status = false --进入时勾选框状态
end

function HolyequipmentSaveTips:open_callback()
	self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.main_panel = self.root_wnd:getChildByName("main_panel")
    self:playEnterAnimatianByObj(self.main_panel , 2) 

    local title_container = self.main_panel:getChildByName("title_container")
    title_container:getChildByName("title_label"):setString(TI18N("提示"))

    self.close_btn = self.main_panel:getChildByName("close_btn")
    self.confirm_btn = self.main_panel:getChildByName("confirm_btn")
    self.confirm_btn:getChildByName("label"):setString(TI18N("确 定"))
    self.cancel_btn = self.main_panel:getChildByName("cancel_btn")
    self.cancel_btn:getChildByName("label"):setString(TI18N("取 消"))
    self.box_btn = self.main_panel:getChildByName("box_btn")
    self.box_btn:getChildByName("name"):setString(TI18N("今日不再提示"))

    self.tips_label = createRichLabel(24, 274, cc.p(0.5, 0.5), cc.p(325, 374), 5, nil, 594)
    self.main_panel:addChild(self.tips_label)
end

function HolyequipmentSaveTips:register_event()
    registerButtonEventListener(self.background, handler(self, self.handleCbSelectStatus), true, 2)

	registerButtonEventListener(self.close_btn, handler(self, self.handleCbSelectStatus), true, 2)

	registerButtonEventListener(self.confirm_btn, function()
        if self.equip_list and self.select_vo then
            local list = {}
            local is_new = true
            for _type , equip_vo in pairs(self.equip_list) do
                local each_partner_id =  0
                if self.select_vo.config.type ==  _type then
                    if _model.dic_itemid_to_partner_id[self.select_vo.id] then
                        each_partner_id = _model.dic_itemid_to_partner_id[self.select_vo.id]
                    end
                    table.insert(list, {partner_id = each_partner_id, item_id = self.select_vo.id})
                    is_new = false
                else
                    if _model.dic_itemid_to_partner_id[equip_vo.id] then
                        each_partner_id = _model.dic_itemid_to_partner_id[equip_vo.id]
                    end
                    table.insert(list, {partner_id = each_partner_id, item_id = equip_vo.id})
                end
            end
            if is_new then
                local each_partner_id =  0
                if _model.dic_itemid_to_partner_id[self.select_vo.id] then
                    each_partner_id = _model.dic_itemid_to_partner_id[self.select_vo.id]
                end
                table.insert(list, {partner_id = each_partner_id, item_id = self.select_vo.id})
            end
            _controller:sender25221(self.id, self.partner_id, self.name, list) --获取选中的装备+已有装备新增为方案
        else
    		local list = {}
            local equip_list = _model:getHeroHolyEquipList(self.partner_id)
            for k,v in pairs(equip_list) do
                if v then
                    table.insert(list, {partner_id = self.partner_id, item_id = v.id})
                end
            end
            _controller:sender25221(self.id, self.partner_id, self.name, list) --获取当前的宝可梦新增为方案
        end
        SysEnv:getInstance():save() --点确定才保存勾选框状态
        _controller:openHolyequipmentSaveTips(false)
	end, true, 1)

	registerButtonEventListener(self.cancel_btn, handler(self, self.handleCbSelectStatus), true, 1)

	self.box_btn:addEventListener(function(sender,event_type)
        if event_type == ccui.CheckBoxEventType.selected then
            playButtonSound2()
            SysEnv:getInstance():set(SysEnv.keys.holy_plan_save_tip, true, false) 
        elseif event_type == ccui.CheckBoxEventType.unselected then 
            playButtonSound2()
            SysEnv:getInstance():set(SysEnv.keys.holy_plan_save_tip, false, false) 
        end
    end)
end

--放弃当前勾选框修改的状态
function HolyequipmentSaveTips:handleCbSelectStatus()
    local status = SysEnv:getInstance():getBool(SysEnv.keys.holy_plan_save_tip, false)
    if status ~= self.enter_status then
        SysEnv:getInstance():set(SysEnv.keys.holy_plan_save_tip, self.enter_status, false)
    end
    _controller:openHolyequipmentSaveTips(false)
end

function HolyequipmentSaveTips:openRootWnd(holy_data)
	self.holy_data = holy_data
	self.id = holy_data.id
	self.name = holy_data.name
	self.partner_id = holy_data.partner_id
	self.item_list = holy_data.item_list
    self.equip_list = holy_data.equip_list
    self.select_vo = holy_data.select_vo

	self:setData()
end

function HolyequipmentSaveTips:setData()
	if not self.holy_data then return end
	self.tips_label:setString(_string_format(TI18N("为<div fontcolor=249003>【%s】</div>保存新组合，会将以下神装从对应方案中卸下，是否继续?"), self.name))

    local status = SysEnv:getInstance():getBool(SysEnv.keys.holy_plan_save_tip, false)
    self.box_btn:setSelected(status)

    self.enter_status = status

    local type_list = {}
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
                item = HolyequipmentSaveItem.new(holy_type)
                self.main_panel:addChild(item)
                self.item_node_list[i] = item
            end
            if type_list[i] then
                item:setData(type_list[i])
            end
            item:setPosition(cc.p(start_x + (i-1)*(138+10), 230))
        end
    end
end

function HolyequipmentSaveTips:close_callback( )
	for k,v in pairs(self.item_node_list) do
		v:DeleteMe()
		v = nil
	end
	_controller:openHolyequipmentSaveTips(false)
end

-----------------------------@ item
HolyequipmentSaveItem = class("HolyequipmentSaveItem", function()
    return ccui.Widget:create()
end)

function HolyequipmentSaveItem:ctor(holy_type)
	self.holy_type = holy_type

	self:config()
    self:layoutUI()
end

function HolyequipmentSaveItem:config()
	self.size = cc.size(138, 211)
    self:setContentSize(self.size)
end

function HolyequipmentSaveItem:layoutUI()
    self.container = ccui.Layout:create()
    self.container:setContentSize(self.size)
    self:addChild(self.container)

    local sp_line = createSprite(PathTool.getResFrame("common","common_90097"), self.size.width/2, 63, self.container, cc.p(0.5, 0.5))

    self.item_node = BackPackItem.new(false,true,nil,1,false)
    self.item_node:setDefaultTip(true,false)
    self.item_node:setPosition(cc.p(self.size.width/2, self.size.height - BackPackItem.Height/2 - 15))
    self.container:addChild(self.item_node)
    local empty_res = PathTool.getResFrame("hero", HeroConst.HolyEmptyIconName[self.holy_type])
    local empty_icon = createImage(self.item_node:getRoot(), empty_res,60,60, cc.p(0.5,0.5), true, 10, false)
    self.item_node.empty_icon = empty_icon

    local name_bg = createImage(self.container, PathTool.getResFrame("common","common_90096"), self.size.width/2, 32, cc.p(0.5, 0.5), true, nil, true)
    name_bg:setContentSize(cc.size(138, 30))

    self.name_label = createLabel(20, 274, nil, self.size.width/2, 32, "", self.container, nil, cc.p(0.5, 0.5))
end

function HolyequipmentSaveItem:setData(data)
	if not data then return end
	if data.item_vo then
        self.item_node:setData(data.item_vo)
        if self.item_node.empty_icon then 
            self.item_node.empty_icon:setVisible(false)
        end
        self.item_node.data = data.item_vo
    else
        self.item_node:setData()
        if self.item_node.empty_icon then 
            self.item_node.empty_icon:setVisible(true)
        end
        self.item_node.data = nil
    end
    if data.name then
    	self.name_label:setString(data.name)
    end
end

function HolyequipmentSaveItem:DeleteMe()
	if self.item_node then
		self.item_node:DeleteMe()
		self.item_node = nil
	end
end