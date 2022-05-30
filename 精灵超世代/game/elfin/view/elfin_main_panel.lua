--------------------------------------------
-- @Author  : htp
-- @Editor  : xhj
-- @Date    : 2019-08-13 15:36:39
-- @description    : 
		-- 精灵主界面
---------------------------------
ElfinMainPanel = class("ElfinMainPanel",function()
    return ccui.Layout:create()
end)

local _controller = ElfinController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert
local _table_sort = table.sort
local _string_format = string.format

function ElfinMainPanel:ctor(sub_type)
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("hero/hero_elfin_panel"))

    self.size = self.root_wnd:getContentSize()
    self:setContentSize(self.size)

    self.root_wnd:setAnchorPoint(0.5, 0.5)
    self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
    self:addChild(self.root_wnd)

    -- 初始化数据
    self:initElfinData()

    -- 资源加载
    local res_list = {}
    _table_insert(res_list, {path = PathTool.getPlistImgForDownLoad("elfin", "elfin"), type = ResourcesType.plist})
    if self.init_res_load then
        self.init_res_load:DeleteMe()
        self.init_res_load = nil
    end
    self.init_res_load = ResourcesLoad.New()
    self.init_res_load:addAllList(res_list, function()
        if not tolua.isnull(self.root_wnd) then
            self:loadResListCompleted(sub_type)
        end
    end)
end

function ElfinMainPanel:loadResListCompleted( sub_type )
	self:initView()
    self:registerEvent()

    -- 默认选中孵化页
    sub_type = sub_type or self:getDefaultTabIndex()
    self:changeSelectedTab(sub_type, true)
    self:updateElfinRedInfo()
end

-- 获取默认选中的tab
function ElfinMainPanel:getDefaultTabIndex(  )
    -- 有空闲或者有孵化完成的灵窝则选中孵化，否则选中古树
    local default_index = ElfinConst.Tab_Index.Rouse
    local hatch_data_list = _model:getElfinHatchList()
    for k,vo in pairs(hatch_data_list) do
        if vo.is_open == 1 and (vo.state == ElfinConst.Hatch_Status.Open or vo.state == ElfinConst.Hatch_Status.Over) then
            default_index = ElfinConst.Tab_Index.Hatch
            break
        end
    end
    return default_index
end

-- 初始化数据
function ElfinMainPanel:initElfinData(  )
	self.tab_list = {}
	self.cur_tab_index = ElfinConst.Tab_Index.Hatch  -- 当前选中的tab按钮

end

-- 初始化界面
function ElfinMainPanel:initView(  )
	self.container = self.root_wnd:getChildByName("container")

	local tab_container = self.container:getChildByName("tab_container")
    for i=1,3 do
        local object = {}
        local tab_btn = tab_container:getChildByName("tab_btn_"..i)
        if tab_btn then
            tab_btn:loadTextures(PathTool.getResFrame("common","common_1124"), "", "", LOADTEXT_TYPE_PLIST)
            local title = tab_btn:getChildByName("title")
            if i == 1 then
                title:setString(TI18N("孵化"))
            elseif i == 2 then
                title:setString(TI18N("复苏"))
            elseif i == 3 then
                title:setString(TI18N("召唤"))
                tab_btn:setName("guide_tab_btn")
            end
            local tips = tab_btn:getChildByName("tips")
            object.tab_btn = tab_btn
            object.label = title
            --object.label:setTextColor(cc.c3b(255, 244, 228))
            object.index = i
            object.tips = tips
            self.tab_list[i] = object
        end
    end

    

end

function ElfinMainPanel:registerEvent(  )
	-- tab 按钮
	for k, object in pairs(self.tab_list) do
	   if object.tab_btn then
            object.tab_btn:addTouchEventListener(function(sender, event_type)
                if event_type == ccui.TouchEventType.ended and not self.is_show_egg_effect then
                    playTabButtonSound()
                    self:changeSelectedTab(object.index)
                end
            end)
        end
    end


    -- 红点
    if not self.update_red_status_event then
        self.update_red_status_event = GlobalEvent:getInstance():Bind(ElfinEvent.Update_Elfin_Red_Event, function ( bid, status )
            self:updateElfinRedInfo(bid, status)
        end)
    end
end

function ElfinMainPanel:changeSelectedTab( index, force )
	if not force and self.cur_tab_index and self.cur_tab_index == index then return end
    if self.tab_object then
        self.tab_object.tab_btn:loadTextures(PathTool.getResFrame("common","common_1124"), "", "", LOADTEXT_TYPE_PLIST)
        self.tab_object.label:setTextColor(Config.ColorData.data_new_color4[6])
        self.tab_object.label:disableEffect(cc.LabelEffect.SHADOW)
        self.tab_object = nil
    end
    self.tab_object = self.tab_list[index]
    if self.tab_object then
        self.tab_object.tab_btn:loadTextures(PathTool.getResFrame("common","common_1125"), "", "", LOADTEXT_TYPE_PLIST)
        self.tab_object.label:setTextColor(Config.ColorData.data_new_color4[1])
        self.tab_object.label:enableShadow(Config.ColorData.data_new_color4[2], cc.size(0, -2),2)
    end

    self.cur_tab_index = index

    if index == ElfinConst.Tab_Index.Hatch then
        if self.elfin_rouse_panel then
            self.elfin_rouse_panel:setVisible(false)
        end
        if self.elfin_summon_panel then
            self.elfin_summon_panel:setVisible(false)
            self.elfin_summon_panel:setVisibleStatus(false)
        end
        
        if not self.elfin_hatch_panel then
            self.elfin_hatch_panel = ElfinHatchPanel.new()
            self.container:addChild(self.elfin_hatch_panel)
        end
        self.elfin_hatch_panel:setVisible(true)

        if not self.init_hatch_flag then
            self.init_hatch_flag = true
            _controller:sender26500()  -- 第一次打开时请求孵化数据
        end
    elseif index == ElfinConst.Tab_Index.Rouse then
        if self.elfin_summon_panel then
            self.elfin_summon_panel:setVisible(false)
            self.elfin_summon_panel:setVisibleStatus(false)
        end

        if self.elfin_hatch_panel then
            self.elfin_hatch_panel:setVisible(false)
        end
        if not self.elfin_rouse_panel then
            self.elfin_rouse_panel = ElfinRousePanel.new()
            self.container:addChild(self.elfin_rouse_panel)
        end

        
        self.elfin_rouse_panel:setVisible(true)

    elseif index == ElfinConst.Tab_Index.Summon then
        if self.elfin_rouse_panel then
            self.elfin_rouse_panel:setVisible(false)
        end
        if self.elfin_hatch_panel then
            self.elfin_hatch_panel:setVisible(false)
        end
        if not self.elfin_summon_panel then
            self.elfin_summon_panel = ElfinSummonPanel.new()
            self.container:addChild(self.elfin_summon_panel)
        end
        self.elfin_summon_panel:setVisible(true)
        self.elfin_summon_panel:setVisibleStatus(true)
      
    end
    
    self:updateTabBtnRedStatus()
end



------------------@ 红点
function ElfinMainPanel:updateElfinRedInfo( bid, status )
    self:updateTabBtnRedStatus()
end



-- tab按钮红点
function ElfinMainPanel:updateTabBtnRedStatus(  )
    for _,object in ipairs(self.tab_list) do
        local red_status = false
        if object.index == 1 and self.cur_tab_index ~= object.index then -- 孵化
            if _model:getElfinRedStatusByRedBid(HeroConst.RedPointType.eElfin_hatch_egg) or
                _model:getElfinRedStatusByRedBid(HeroConst.RedPointType.eElfin_hatch_done) or
                _model:getElfinRedStatusByRedBid(HeroConst.RedPointType.eElfin_hatch_lvup) or
                _model:getElfinRedStatusByRedBid(HeroConst.RedPointType.eElfin_hatch_open) or
                _model:getElfinRedStatusByRedBid(HeroConst.RedPointType.eElfin_activate) then
                red_status = true
            end
        elseif object.index == 2 and self.cur_tab_index ~= object.index then -- 古树复苏
            if _model:getElfinRedStatusByRedBid(HeroConst.RedPointType.eElfin_tree_lvup) or 
                _model:getElfinRedStatusByRedBid(HeroConst.RedPointType.eElfin_empty_pos) or
                _model:getElfinRedStatusByRedBid(HeroConst.RedPointType.eElfin_higher_lv) or
                _model:getElfinRedStatusByRedBid(HeroConst.RedPointType.eElfin_compound) then
                red_status = true
            end
        elseif object.index == 3 and self.cur_tab_index ~= object.index then --扭蛋
            if _model:getElfinRedStatusByRedBid(HeroConst.RedPointType.eElfin_summon) then
                red_status = true
            end
        end
        if object.tips then
            object.tips:setVisible(red_status)
        end
    end
end

function ElfinMainPanel:DeleteMe(  )
    if self.elfin_rouse_panel then
        self.elfin_rouse_panel:DeleteMe()
        self.elfin_rouse_panel = nil
    end

    if self.elfin_summon_panel then
        self.elfin_summon_panel:DeleteMe()
        self.elfin_summon_panel = nil
    end

    if self.elfin_hatch_panel then
        self.elfin_hatch_panel:DeleteMe()
        self.elfin_hatch_panel = nil
    end
    
    
	if self.init_res_load then
        self.init_res_load:DeleteMe()
        self.init_res_load = nil
    end
 
    if self.update_red_status_event then
        GlobalEvent:getInstance():UnBind(self.update_red_status_event)
        self.update_red_status_event = nil
    end
   
    _model:setNotCalculateHatchLvupRedFlag()
    _model:updateElfinRedStatus(HeroConst.RedPointType.eElfin_hatch_lvup, false)
    MainuiController:getInstance():setMainUIChatBubbleStatus(true)
    MainuiController:getInstance():setMainUIShowStatus(true)
end