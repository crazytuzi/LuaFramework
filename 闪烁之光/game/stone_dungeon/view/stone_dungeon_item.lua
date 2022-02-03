--[[
宝石副本Item项
--]]
StoneDungeonItem = class("StoneDungeonItem", function()
	return ccui.Widget:create()
end)

local scale = 0.8
local controller = Stone_dungeonController:getInstance()
local model = controller:getModel()
local string_format = string.format
function StoneDungeonItem:ctor()
    self.role_vo = RoleController:getInstance():getRoleVo()
    self.item_list = {}
	self:configUI()
    self:registerEvent()
end

function StoneDungeonItem:configUI()
	self._rootWnd = createCSBNote(PathTool.getTargetCSB("stonedungeon/stone_dungeon_item"))
    self:setAnchorPoint(cc.p(0, 1))
    self:addChild(self._rootWnd)
	self:setCascadeOpacityEnabled(true)
	self:setContentSize(cc.size(616,125))
	
	self.container = self._rootWnd:getChildByName("root")
	self._itemScrollview = self.container:getChildByName("item_scrollview")
	self._itemScrollview:setScrollBarEnabled(false)
    self._itemScrollview:setSwallowTouches(false)

    self.diff_lev = self.container:getChildByName("diff_lev")
    self.diff_text = self.diff_lev:getChildByName("Text_1")

    self.jian = self.container:getChildByName("Sprite_1")
    self.jian:setVisible(false)

	self.btnClear = self.container:getChildByName("btnClear")
    self.textClear = createRichLabel(24, 1, cc.p(0.5, 0.5), cc.p(self.btnClear:getContentSize().width*0.5, self.btnClear:getContentSize().height*0.5), nil, nil, 500)
    self.btnClear:addChild(self.textClear)
    self.btnClear:setVisible(false)
    self.textClear:setString(TI18N("<div fontcolor=#ffffff outline=2,#294A15>扫荡</div>"))

	self.btnChange = self.container:getChildByName("btnChange")
    self.textChange = createRichLabel(24, 1, cc.p(0.5, 0.5), cc.p(self.btnChange:getContentSize().width*0.5, self.btnChange:getContentSize().height*0.5), nil, nil, 500)
    self.btnChange:addChild(self.textChange)
    self.btnChange:setVisible(false)
    self.textChange:setString(TI18N("<div fontcolor=#ffffff outline=2,#294A15>挑战</div>"))

	self.textNumber = self.container:getChildByName("textNumber")
	self.textNumber:setString("")
end

function StoneDungeonItem:setExtendData(tab)
    self.expend = tab.expend
    self.free_count = tab.count
    self.title_pos = tab.title_pos
end
function StoneDungeonItem:setData(data)
    self:setChangeData(data)
end

function StoneDungeonItem:setChangeData(data)
    self.dungeonData = data
    if data.title_name ~= "" then
        self.diff_text:setString(data.title_name)
    else
        self.diff_text:setString("")
    end
    if self.title_pos == data.difficulty then
        self.jian:setVisible(true)
    else
        self.jian:setVisible(false)
    end
    
    self.btnChange:setVisible(false)
    self.btnClear:setVisible(false)

    self.diff_text:setColor(Config.ColorData.data_color4[253+data.difficulty])
    self.textNumber:setString(string_format(TI18N("战力%d开启"), data.power or 0))
    self.textNumber:setVisible(true)
    local is_first = 1
    local clearance = model:getPassClearanceID(data.id)
    setChildUnEnabled(false, self.btnChange)

    if clearance and clearance.status == 1 then --已经通关的
        if self.role_vo.max_power >= data.power then
            self.textNumber:setVisible(false)
            self.btnClear:setVisible(true)
            if self.free_count == 0 then
                self.textClear:setString(string_format(TI18N("<img src=%s visible=true scale=0.25 /><div fontcolor=#ffffff outline=2,#294A15>%s 扫荡</div>"), PathTool.getItemRes(15), self.expend))
            else
                self.textClear:setString(TI18N("<div fontcolor=#ffffff outline=2,#294A15>扫荡</div>"))
            end
        else
            self.btnClear:setVisible(false)
            self.btnChange:setVisible(true)
            self.textChange:setString(TI18N("<div fontcolor=#ffffff >未开启</div>"))
            setChildUnEnabled(true, self.btnChange)
        end
        is_first = nil
    else
        self.btnClear:setVisible(false)
        if self.role_vo.max_power >= data.power then
            self.textNumber:setVisible(false)
            self.btnChange:setVisible(true)
            local status = false
            if self.role_vo.lev < data.lev_limit then
                local str = string_format(TI18N("<div fontcolor=#ffffff >%d级开启</div>"),data.lev_limit)
                self.textChange:setString(str)
                status = true
            else
                if self.free_count == 0 then
                    self.textChange:setString(string_format(TI18N("<img src=%s visible=true scale=0.25 /><div fontcolor=#ffffff outline=2,#294A15>%s 挑战</div>"), PathTool.getItemRes(15), self.expend))
                else
                    self.textChange:setString(TI18N("<div fontcolor=#ffffff outline=2,#294A15>挑战</div>"))
                end
            end
            setChildUnEnabled(status, self.btnChange)
        else
            self.btnChange:setVisible(true)
            local str = TI18N("<div fontcolor=#ffffff >未开启</div>")
            if self.role_vo.lev < data.lev_limit then
                str = string_format(TI18N("<div fontcolor=#ffffff >%d级开启</div>"),data.lev_limit)
            end
            self.textChange:setString(str)
            setChildUnEnabled(true, self.btnChange)
        end
    end

    loadSpriteTexture(self.diff_lev, PathTool.getResFrame("activity",data.pis_str), LOADTEXT_TYPE_PLIST)
    
    for i,v in pairs(self.item_list) do
        v:setVisible(false)
    end
    --首通奖励
    self:firstAward(is_first)
    --展示奖励
    self:showAward(is_first)

    -- 引导需要
    if data and data.id and self.btnChange then
        self.btnChange:setName("stone_change_btn_"..data.id)
    end
end

function StoneDungeonItem:firstAward(is_first)
    if not is_first then return end
	if self.dungeonData.first_items[1] then
		if not self.item_list[1] then
			local item = BackPackItem.new(true,true,nil,scale)
			item:setAnchorPoint(0, 0.5)
		    self._itemScrollview:addChild(item)
		    item:setFirstIcon(true)
		    self.item_list[1] = item
		end
        if self.item_list[1] then
            self.item_list[1]:setVisible(true)
            self.item_list[1]:setPosition(cc.p(4,47))
            self.item_list[1]:setBaseData(self.dungeonData.first_items[1][1], self.dungeonData.first_items[1][2])
            self.item_list[1]:setDefaultTip()
        end
	end
end

function StoneDungeonItem:showAward(is_first)
    local _flag = is_first and 1 or 0
    if not self.dungeonData.first_items[1] then
        _flag = 0
        is_first = nil
    end
	local total_width = 135 * (#self.dungeonData.show_items+_flag) * scale + (#self.dungeonData.show_items+_flag) * 5
    local max_width = math.max(self._itemScrollview:getContentSize().width, total_width)
	self._itemScrollview:setInnerContainerSize(cc.size(max_width, self._itemScrollview:getContentSize().height))

	for i,v in ipairs(self.dungeonData.show_items) do
    	if not self.item_list[1+i] then
	    	local item = BackPackItem.new(true,true,nil,scale)
		    item:setAnchorPoint(0, 0.5)
		    self._itemScrollview:addChild(item)
		    self.item_list[1+i] = item
		end
		if self.item_list[1+i] then
            if is_first then
		    	self.item_list[1+i]:setPosition(cc.p(4*(i+1) + 109*i,47))
		    else
		    	self.item_list[1+i]:setPosition(cc.p(4*i + 109*(i-1),47))
		    end
            self.item_list[1+i]:setVisible(true)
		    self.item_list[1+i]:setBaseData(v[1],v[2])
            self.item_list[1+i]:setDefaultTip()
        end
    end
end

function StoneDungeonItem:registerEvent()
	--扫荡
    registerButtonEventListener(self.btnClear, function()
        controller:send13032(self.dungeonData.id)
    end ,false, 1)
    --挑战
    registerButtonEventListener(self.btnChange, function()
        if self.role_vo.lev < self.dungeonData.lev_limit then
            local str = string_format(TI18N("%d级开启"),self.dungeonData.lev_limit)
            message(str)
        else
            controller:send13031(self.dungeonData.id)
        end
    end ,false, 1)
end

function StoneDungeonItem:DeleteMe()
	if self.item_list and next(self.item_list or {}) ~= nil then
        for i, v in ipairs(self.item_list) do
            if v.DeleteMe then
                v:DeleteMe()
            end
        end
    end
    if self.updata_role_event then
        GlobalEvent:getInstance():UnBind(self.updata_role_event)
        self.updata_role_event = nil
    end
	self:removeAllChildren()
	self:removeFromParent()
end