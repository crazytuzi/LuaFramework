---------------------------------
-- @Author: htp
-- @Editor: htp
-- @date 2020/01/17 15:03:36
-- @description: gm 修改配置界面
---------------------------------
local _table_insert = table.insert
local _table_sort = table.sort

GmAdjustConfigPanel = GmAdjustConfigPanel or BaseClass(CommonUI)

function GmAdjustConfigPanel:__init(ctrl)
    local cfg_gm_path = "config_gm.lua"
    if PathTool.isFileExist(cfg_gm_path) then
        require ("config_gm")
    end
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self:createRootWnd()

    self.config_btn_list = {}
    self.sub_btn_list = {}
    self.input_item_list = {}
    
    self.is_open = true
end

function GmAdjustConfigPanel:createRootWnd(  )
    self.root_wnd = ccui.Layout:create()
    self.root_wnd:setTouchEnabled(true)
    self.root_wnd:setContentSize(cc.size(SCREEN_WIDTH,SCREEN_HEIGHT))
    self.root_wnd:setAnchorPoint(0,0)

    self.mask_bg = ccui.Layout:create()
    self.mask_bg:setContentSize(cc.size(SCREEN_WIDTH,SCREEN_HEIGHT))
    self.mask_bg:setAnchorPoint(0,0)
    self.mask_bg:setBackGroundColor(cc.c3b(80,80,80))
    self.mask_bg:setBackGroundColorOpacity(250)
    self.mask_bg:setBackGroundColorType(1)
    self.root_wnd:addChild(self.mask_bg)

    self.container = ccui.Layout:create()
    self.container:setContentSize(cc.size(SCREEN_WIDTH,SCREEN_HEIGHT))
    self.container:setAnchorPoint(0,0)
    self.root_wnd:addChild(self.container)

    ViewManager:getInstance():getLayerByTag(self.view_tag):addChild(self.root_wnd)

    self.close_btn = CustomButton.New(self.container, PathTool.getResFrame("common", "common_1028"),nil,nil,LOADTEXT_TYPE_PLIST)
    self.close_btn:setPosition(cc.p(680, 1200))
    self.close_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
	    	self:hide()
        end
    end)

    -- 配置修改指南
    self.tips_txt = createRichLabel(22, cc.c4b(46,139,87,255), cc.p(0, 1), cc.p(10, 1250), 5, nil, 640)
    self.tips_txt:setString("修改配置GM指北:\n1、左侧为配置列表，选择想要修改的配置表名称后，右侧将列出该配置表中每个分页的内容。\n2、选择右侧配置名称进入修改界面。\n3、输入想要修改的键值后点击搜索按钮，将列出该键值对应的配置，点击输入框即可进行修改。")
    self.container:addChild(self.tips_txt)

    local setting = {
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 5,                   -- y方向的间隔
        item_width = 300,               -- 单元的尺寸width
        item_height = 30,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
    }
    
	self.cfg_btn_scroll_view = CommonScrollViewSingleLayout.new(self.container, cc.p(30, 100) , ScrollViewDir.vertical, ScrollViewStartPos.top, cc.size(300, 880), setting, cc.p(0, 0))

	self.cfg_btn_scroll_view:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
	self.cfg_btn_scroll_view:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
	self.cfg_btn_scroll_view:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
	

    self.cfg_btn_scroll_view:setSwallowTouches(false)

    local setting = {
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 5,                   -- y方向的间隔
        item_width = 400,               -- 单元的尺寸width
        item_height = 30,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
    }
    self.sub_btn_scroll_view = CommonScrollViewSingleLayout.new(self.container, cc.p(350, 100) , ScrollViewDir.vertical, ScrollViewStartPos.top, cc.size(400, 880), setting, cc.p(0, 0))

	self.sub_btn_scroll_view:registerScriptHandlerSingle(handler(self,self.createNewCell_2), ScrollViewFuncType.CreateNewCell) --创建cell
	self.sub_btn_scroll_view:registerScriptHandlerSingle(handler(self,self.numberOfCells_2), ScrollViewFuncType.NumberOfCells) --获取数量
	self.sub_btn_scroll_view:registerScriptHandlerSingle(handler(self,self.updateCellByIndex_2), ScrollViewFuncType.UpdateCellByIndex) --更新cell
	

    self.sub_btn_scroll_view:setSwallowTouches(false)

    self:showConfigList()
end


--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function GmAdjustConfigPanel:createNewCell()
    local cell = configButton.new()
    cell:addCallBack(handler(self, self.onClickCfgKey))
    return cell
end

--获取数据数量
function GmAdjustConfigPanel:numberOfCells()
    if not self.config_btn_list then return 0 end
    return #self.config_btn_list
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function GmAdjustConfigPanel:updateCellByIndex(cell, index)
    cell.index = index
    local data = self.config_btn_list[index]
    if not data then return end
    cell:setData(data)
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function GmAdjustConfigPanel:createNewCell_2()
    local cell = subConfigButton.new()
    cell:addCallBack(handler(self, self.onClickSubCfgKey))
    return cell
end

--获取数据数量
function GmAdjustConfigPanel:numberOfCells_2()
    if not self.sub_btn_list then return 0 end
    return #self.sub_btn_list
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function GmAdjustConfigPanel:updateCellByIndex_2(cell, index)
    cell.index = index
    local data = self.sub_btn_list[index]
    if not data then return end
    cell:setData(data)
end

function GmAdjustConfigPanel:open(  )
	self.root_wnd:setVisible(true)
	self.root_wnd:setPosition(cc.p(0, 0))
	self.is_open = true
end

function GmAdjustConfigPanel:hide(  )
	self.root_wnd:setVisible(false)
	self.root_wnd:setPosition(cc.p(-1000, 0))
	self.is_open = false
end

function GmAdjustConfigPanel:isOpen(  )
	return self.is_open
end

function GmAdjustConfigPanel:showConfigList(  )
    local show_data = {}
    for key,cfg in pairs(Config) do
        if not Config_Gm_Show or Config_Gm_Show[key] then
            _table_insert(show_data, {key=key})
        end
    end

    local sortFunc = function ( objA, objB )
        local str_a = string.sub(objA.key, 1, 1)
        local str_b = string.sub(objB.key, 1, 1)
        return str_a < str_b
    end
    _table_sort(show_data, sortFunc)
    self.config_btn_list = show_data
    self.cfg_btn_scroll_view:reloadData()
end

function GmAdjustConfigPanel:onClickCfgKey( key, node )
    if self.cur_node then
        self.cur_node:setIsSelect(false)
    end
    node:setIsSelect(true)
    self.cur_node = node
    self:showSubConfigListByKey(key)
end

function GmAdjustConfigPanel:showSubConfigListByKey( f_key )
    if not f_key then return end
   self.cur_config = Config[f_key] or {}

    local show_data = {}
    for key,cfg in pairs(self.cur_config) do
        if type(cfg) == "table" or type(cfg) == "function" then
            _table_insert(show_data, {key=key, f_key=f_key})
        end
    end
    local sortFunc = function ( objA, objB )
        local str_a = string.sub(objA.key, 6, 6)
        local str_b = string.sub(objB.key, 6, 6)
        return str_a < str_b
    end
    _table_sort(show_data, sortFunc)
    self.sub_btn_list = show_data
    self.sub_btn_scroll_view:reloadData()
end

function GmAdjustConfigPanel:onClickSubCfgKey( key )
    if not key or not self.cur_config then return end

    local cfg_data = self.cur_config[key]
    if cfg_data then
        self:showChangeLayer(true, cfg_data, key)
    end
end

function GmAdjustConfigPanel:showChangeLayer( status, cfg_data, father_key )
    if status == true then
        self.cur_cfg_data = cfg_data or {}
        if not self.change_layer then
            self.change_layer = ccui.Layout:create()
            self.change_layer:setTouchEnabled(true)
            self.change_layer:setContentSize(cc.size(SCREEN_WIDTH,SCREEN_HEIGHT))
            self.change_layer:setAnchorPoint(0,0)
            self.change_layer:setBackGroundColor(cc.c3b(238, 238, 209))
            self.change_layer:setBackGroundColorType(1)
            self.container:addChild(self.change_layer)

            self.close_layer_btn = CustomButton.New(self.change_layer, PathTool.getResFrame("common", "common_1050"),nil,nil,LOADTEXT_TYPE_PLIST)
            self.close_layer_btn:setPosition(cc.p(360, 100))
            self.close_layer_btn:setBtnLabel(TI18N("关闭"))
            self.close_layer_btn:addTouchEventListener(function(sender, event_type)
                if event_type == ccui.TouchEventType.ended then
                    self:showChangeLayer(false)
                end
            end)

            -- 搜索框
            local title_txt = createLabel(24, 2, nil, 180, 1100, TI18N("键值:"), self.change_layer, nil, cc.p(0.5, 0.5))
            self.key_input = ccui.EditBox:create(cc.size(220, 60), PathTool.getResFrame("common", "common_1021"), LOADTEXT_TYPE_PLIST)
            self.key_input:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
            self.key_input:setInputFlag(cc.EDITBOX_INPUT_FLAG_INITIAL_CAPS_WORD)
            self.key_input:setReturnType(cc.KEYBOARD_RETURNTYPE_DEFAULT)
            self.key_input:setAnchorPoint(0.5, 0.5)
            self.change_layer:addChild(self.key_input)
            self.key_input:setPosition(360, 1100)
            self.key_input:setFontColor(cc.c3b(0,0,0))
            self.key_input:setFontSize(28)
            self.search_btn = CustomButton.New(self.change_layer, PathTool.getResFrame("common", "common_1093"),nil,nil,LOADTEXT_TYPE_PLIST)
            self.search_btn:setPosition(cc.p(520, 1100))
            self.search_btn:addTouchEventListener(function(sender, event_type)
                if event_type == ccui.TouchEventType.ended then
                    local text =  self.key_input:getText()
                    if text and text ~= "" then
                        self:showChangeCfgListByKey(text, father_key)
                    end
                end
            end)

            self.search_tips = createLabel(16, 2, nil, 360, 1050, "", self.change_layer, nil, cc.p(0.5, 0.5))
        end
        self.change_layer:setVisible(true)

        if type(self.cur_cfg_data) == "table" then
            local temp_index = 0
            local tips_str = TI18N("可搜索的键值:")
            for k,v in pairs(self.cur_cfg_data) do
                temp_index = temp_index + 1
                if StringUtil.getStrLen(tips_str) > 70 then
                    tips_str = tips_str .. "..."
                    break
                else
                    tips_str = tips_str .. k .. "、"
                end
            end
            self.search_tips:setString(tips_str)
        else
            self.search_tips:setString("")
        end

        if self.input_item_scrollview then
            self.input_item_list = {}
            self.input_item_scrollview:reloadData()
        end
        self.key_input:setText("")
    elseif self.change_layer then
        self.change_layer:setVisible(false)
    end
end

function GmAdjustConfigPanel:showChangeCfgListByKey( key, father_key )
    if not key or not self.cur_cfg_data then return end
    local show_cfg
    if type(self.cur_cfg_data) == "table" then
        show_cfg = self.cur_cfg_data[key] or self.cur_cfg_data[tonumber(key)]
    elseif type(self.cur_cfg_data) == "function" then
        show_cfg = self.cur_cfg_data(key) or self.cur_cfg_data(tonumber(key))
    end
    if not show_cfg or type(show_cfg) ~= "table" then
        message(TI18N("找不到相关配置数据"))
        return
    end

    local single_data = {}
    local table_data = {}
    for k,cfg in pairs(show_cfg) do
        local object = {}
        object.key = k
        object.cfg = cfg
        object.father_cfg = show_cfg
        object.father_key = father_key
        --[[ if type(cfg) == "table" then
            _table_insert(table_data, object)
        else
            _table_insert(single_data, object)
        end ]]
        _table_insert(single_data, object)
    end

    if not self.input_item_scrollview then
        local setting = {
            start_x = 0,                  -- 第一个单元的X起点
            space_x = 0,                    -- x方向的间隔
            start_y = 0,                    -- 第一个单元的Y起点
            space_y = 5,                   -- y方向的间隔
            item_width = 200,               -- 单元的尺寸width
            item_height = 30,              -- 单元的尺寸height
            row = 0,                        -- 行数，作用于水平滚动类型
            col = 1,                         -- 列数，作用于垂直滚动类型
        }
        
        self.input_item_scrollview = CommonScrollViewSingleLayout.new(self.change_layer, cc.p(100, 140) , ScrollViewDir.vertical, ScrollViewStartPos.top, cc.size(520, 880), setting, cc.p(0, 0))

        self.input_item_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell_3), ScrollViewFuncType.CreateNewCell) --创建cell
        self.input_item_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells_3), ScrollViewFuncType.NumberOfCells) --获取数量
        self.input_item_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex_3), ScrollViewFuncType.UpdateCellByIndex) --更新cell
	
        self.input_item_scrollview:setSwallowTouches(false)
    end
    self.input_item_list = single_data
    self.input_item_scrollview:reloadData()
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function GmAdjustConfigPanel:createNewCell_3()
    local cell = InputItem.new()
    return cell
end

--获取数据数量
function GmAdjustConfigPanel:numberOfCells_3()
    if not self.input_item_list then return 0 end
    return #self.input_item_list
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function GmAdjustConfigPanel:updateCellByIndex_3(cell, index)
    cell.index = index
    local data = self.input_item_list[index]
    if not data then return end
    cell:setData(data)
end

function GmAdjustConfigPanel:close()
    if tolua.isnull(self.root_wnd) then return end
    self:__close()
end

function GmAdjustConfigPanel:__close()
    if self.cfg_btn_scroll_view then
        self.cfg_btn_scroll_view:DeleteMe()
        self.cfg_btn_scroll_view = nil
    end
    if self.sub_btn_scroll_view then
        self.sub_btn_scroll_view:DeleteMe()
        self.sub_btn_scroll_view = nil
    end
    if self.input_item_scrollview then
        self.input_item_scrollview:DeleteMe()
        self.input_item_scrollview = nil
    end
    --移除
    doRemoveFromParent(self.root_wnd)
end

----------------@item 
configButton = class('configButton',function()
    return ccui.Layout:create()
end)

function configButton:ctor()
    self:configUI()
    self:registerEvent()
end

function configButton:configUI()
    self.size = cc.size(300, 30)
	self:setTouchEnabled(true)
    self:setContentSize(self.size)

    self.cfg_name = createLabel(24, 1, nil, 0, self.size.height*0.5, "", self, nil, cc.p(0, 0.5))
end

function configButton:registerEvent()
    registerButtonEventListener(self, function (  )
        if self.callback then
            self.callback(self.cfg_key, self)
        end
    end, true)
end

function configButton:setData(data)
    self.data = data or {}
    self.cfg_key = data.key or ""
    self.cfg_name:setString(self.cfg_key)

    self:setIsSelect(data.is_select)
end

function configButton:addCallBack( callback )
    self.callback = callback
end

function configButton:setIsSelect( status )
    self.data.is_select = status or false
    if self.data.is_select == true then
        if not self.select_sp then
            self.select_sp = createSprite(PathTool.getResFrame("common", "common_1043"), self.size.width-10, self.size.height*0.5, self, cc.p(1, 0.5), LOADTEXT_TYPE_PLIST)
        end
        self.select_sp:setVisible(true)
    elseif self.select_sp then
        self.select_sp:setVisible(false)
    end
end

function configButton:DeleteMe()
    self:removeAllChildren()
	self:removeFromParent()
end


subConfigButton = class('subConfigButton',function()
    return ccui.Layout:create()
end)

function subConfigButton:ctor()
    self:configUI()
    self:registerEvent()
end

function subConfigButton:configUI()
    self.size = cc.size(400, 30)
	self:setTouchEnabled(true)
    self:setContentSize(self.size)

    self.cfg_name = createLabel(28, 274, nil, 0, self.size.height*0.5, "", self, nil, cc.p(0, 0.5))
end

function subConfigButton:registerEvent()
    registerButtonEventListener(self, function (  )
        if self.callback then
            self.callback(self.cfg_key)
        end
    end, true)
end

function subConfigButton:setData(data)
    self.cfg_key = data.key or ""
    local f_key = data.f_key
    local sub_cfg_name = ""
    if Config_Gm_Cfg_Name and f_key and Config_Gm_Cfg_Name[f_key] and Config_Gm_Cfg_Name[f_key][self.cfg_key] then
        sub_cfg_name = Config_Gm_Cfg_Name[f_key][self.cfg_key]
    else
        sub_cfg_name = self.cfg_key
    end
    self.cfg_name:setString(sub_cfg_name)
end

function subConfigButton:addCallBack( callback )
    self.callback = callback
end

function subConfigButton:DeleteMe()
    self:removeAllChildren()
	self:removeFromParent()
end

-------------------@ 单个配置输入框
InputItem = class('InputItem',function()
    return ccui.Layout:create()
end)

function InputItem:ctor()
    self:configUI()
    self:registerEvent()
end

function InputItem:configUI()
    self.size = cc.size(200, 30)
	self:setTouchEnabled(true)
    self:setContentSize(self.size)

    self.key_name = createLabel(24, 274, nil, 0, self.size.height*0.5, "", self, nil, cc.p(0, 0.5))
    self.input_box = ccui.EditBox:create(cc.size(200, 30), PathTool.getResFrame("common", "common_1021"), LOADTEXT_TYPE_PLIST)
    self.input_box:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.input_box:setInputFlag(cc.EDITBOX_INPUT_FLAG_INITIAL_CAPS_WORD)
    self.input_box:setReturnType(cc.KEYBOARD_RETURNTYPE_DEFAULT)
    self.input_box:setAnchorPoint(0, 0.5)
    self:addChild(self.input_box)
    self.input_box:setPosition(0, self.size.height*0.5)
    self.input_box:setFontColor(cc.c3b(0, 0, 0))
end

function InputItem:registerEvent()
    local editBoxChange = function(eventType, sender)
        if eventType == "began" then
            sender._text_ = sender:getText()
            return false
        elseif eventType == "return" and sender._text_ ~= sender:getText() then
            return true
        end
    end
    self.input_box:registerScriptEditBoxHandler(function(eventType, sender)
        if editBoxChange(eventType, sender) then
            local new_val = self.input_box:getText()
            if self.val_type == "number" then
                new_val = tonumber(new_val)
            elseif self.val_type == "table" then
                new_val = GmStrToTable(new_val)
            end
            if self.data and self.data.father_cfg then
                self.data.father_cfg[self.data.key] = new_val
                message("修改成功")
            end
        end
    end)
end

function InputItem:setData(data)
    if not data then return end

    self.data = data
    local sym_name_data = {}
    local father_key = data.father_key or ""
    if Config_Gm_Sym_Name and Config_Gm_Sym_Name[father_key] then
        sym_name_data = Config_Gm_Sym_Name[father_key]
    end
    self.key_name:setString(sym_name_data[data.key] or data.key or "")
    local name_size = self.key_name:getContentSize()
    self.input_box:setPositionX(name_size.width+10)
    self.val_type = type(data.cfg)
    if type(data.cfg) == "table" then
        self.input_box:setText(GmTableToStr(data.cfg))
    else
        self.input_box:setText(data.cfg)
    end
end

function InputItem:addCallBack( callback )
    self.callback = callback
end

function InputItem:DeleteMe()
    self:removeAllChildren()
	self:removeFromParent()
end

-------------------------
-- table 转 string
function GmTableToStr(t)
    if t == nil then return "" end
    local retstr= "{"

    local i = 1
    for key,value in pairs(t) do
        local signal = ","
        if i==1 then
          signal = ""
        end

        if key == i then
            retstr = retstr..signal..GmToStringEx(value)
        else
            if type(key)=='number' or type(key) == 'string' then
                retstr = retstr..signal..'['..GmToStringEx(key).."]="..GmToStringEx(value)
            else
                if type(key)=='userdata' then
                    retstr = retstr..signal.."*s"..GmTableToStr(getmetatable(key)).."*e".."="..GmToStringEx(value)
                else
                    retstr = retstr..signal..key.."="..GmToStringEx(value)
                end
            end
        end

        i = i+1
    end

    retstr = retstr.."}"
    return retstr
end

-- string 转 table
function GmStrToTable(str)
    if str == nil or type(str) ~= "string" then
        return
    end
    
    return loadstring("return " .. str)()
end

function GmToStringEx(value)
    if type(value)=='table' then
       return GmTableToStr(value)
    elseif type(value)=='string' then
        return "\'"..value.."\'"
    else
       return tostring(value)
    end
end