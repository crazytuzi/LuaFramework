--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-01-17 11:58:06
-- @description    : 
		-- 符文技能预览界面
---------------------------------
ArtifactSkillWindow = ArtifactSkillWindow or BaseClass(BaseView)

local _controller = HeroController:getInstance()
local _model = _controller:getModel()
local table_insert = table.insert

local SKILL_TAB = {
	LOW = 1,  -- 低级技能
	MEDIUM = 2, -- 中级技能
	HIGH = 3,  -- 高级技能
}

function ArtifactSkillWindow:__init()
	self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "forgehouse/artifact_skill_window"

	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("artifact", "artifact"), type = ResourcesType.plist},
	}

	self.tab_list = {}

    self.title_height = 60 --横条高度
end

function ArtifactSkillWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local main_container = self.root_wnd:getChildByName("main_container")
	self.main_container = main_container
    self:playEnterAnimatianByObj(main_container, 1)

	main_container:getChildByName("win_title"):setString(TI18N("技能预览"))

	self.explain_btn = main_container:getChildByName("explain_btn")
	self.close_btn = main_container:getChildByName("close_btn")

	local tab_container = main_container:getChildByName("tab_container")
	for i=1,3 do
		local object = {}
        local tab_btn = tab_container:getChildByName("tab_btn_"..i)
        if tab_btn then
            local title = tab_container:getChildByName("title_"..i)
            object.tab_btn = tab_btn
			object.label = title
			object.index = i
            self.tab_list[i] = object

            if i == SKILL_TAB.LOW then
                title:setString(TI18N("低级技能"))
            elseif i == SKILL_TAB.MEDIUM then
                title:setString(TI18N("中级技能"))
            elseif i == SKILL_TAB.HIGH then
            	title:setString(TI18N("高级技能"))
            end
        end
    end

    self.skill_panel = main_container:getChildByName("skill_panel")
end

function ArtifactSkillWindow:register_event(  )
	registerButtonEventListener(self.explain_btn, function ( param, sender )
		local config = Config.PartnerArtifactData.data_artifact_const.recastskill_rule
        if config then
            TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition())
        end
	end)

	registerButtonEventListener(self.close_btn, function (  )
		_controller:openArtifactSkillWindow(false)
	end, nil, 2)

	registerButtonEventListener(self.background, function (  )
		_controller:openArtifactSkillWindow(false)
	end, nil, 2)

	for k, object in pairs(self.tab_list) do
		if object.tab_btn then
			object.tab_btn:addTouchEventListener(function(sender, event_type)
				if event_type == ccui.TouchEventType.ended then
					playTabButtonSound()
					self:changeSelectedTab(object.index)
				end
			end)
		end
    end
end

function ArtifactSkillWindow:changeSelectedTab( index )
	if self.tab_object and self.tab_object.index == index then return end
	if self.tab_object then
		local unselect_res = PathTool.getResFrame("common","common_2010")
		--if self.tab_object.index == SKILL_TAB.MEDIUM then
		--	unselect_res = PathTool.getResFrame("common","common_2010")
		--end
		self.tab_object.tab_btn:loadTextures(unselect_res, "", "", LOADTEXT_TYPE_PLIST)
		--self.tab_object.tab_btn:setCapInsets(cc.rect(12, 20 ,1, 1))
        self.tab_object.label:disableEffect(cc.LabelEffect.SHADOW)
		self.tab_object.label:setTextColor(Config.ColorData.data_new_color4[6])
		--self.tab_object.label:enableOutline(cc.c3b(42, 22, 14), 2)
		self.tab_object = nil
	end
	self.tab_object = self.tab_list[index]
	if self.tab_object then
		local select_res = PathTool.getResFrame("common","common_2009")
		--if self.tab_object.index == SKILL_TAB.MEDIUM then
		--	select_res = PathTool.getResFrame("common","common_2024")
		--end
		self.tab_object.tab_btn:loadTextures(select_res, "", "", LOADTEXT_TYPE_PLIST)
		--self.tab_object.tab_btn:setCapInsets(cc.rect(12, 20 ,1, 1))
		self.tab_object.label:setTextColor(Config.ColorData.data_new_color4[1])
        self.tab_object.label:enableShadow(Config.ColorData.data_new_color4[2], cc.size(0, -2),2)
		--self.tab_object.label:enableOutline(cc.c3b(42, 22, 14), 2)
	end

    local skill_list
    if self.show_type == 2 then
        skill_list = Config.PartnerSkillData.data_partner_skill_view[index] or {}
    else
        skill_list = Config.PartnerArtifactData.data_artifact_skill[index] or {}
    end
    local partner_awakening_skill_config = Config.PartnerSkillData.data_partner_awakening_skill

	self.show_list = {}
    self.awakenig_list = {} --觉醒技能如果有的话
	for i,skill_id in ipairs(skill_list) do
		local skill_config = Config.SkillData.data_get_skill(skill_id) or {}
		if skill_config then
            if partner_awakening_skill_config[skill_id] then
                --说明是觉醒技能
                table_insert(self.awakenig_list, skill_config)
            else
    			table_insert(self.show_list, skill_config)
            end
		end
	end

    local temp_list = {} 
    for i,v in ipairs(self.show_list) do
        local sort = 3
        if _model:checkIsUnusualSkillById(v.bid) then -- 稀有      
            sort = 1
        elseif _model:checkIsUnusualSkillById2(v.bid) then --强力
            sort = 2
        end 
        table_insert(temp_list, {vo = v,sort = sort})
    end
    table.sort(temp_list, SortTools.KeyLowerSorter("sort"))

    local temp_list_2 = {}
    for i,v in ipairs(temp_list) do
        table_insert(temp_list_2, v.vo)
    end

    self.show_list = temp_list_2
    
    self:updateScrollview()
	-- self.skill_scrollview:setData(skill_data)
end

--是否显示觉醒技能 
function ArtifactSkillWindow:isShowAwakeningSkill()
    --策划 要求 只有玩家已有1个13星宝可梦就可以开显示
    if self.is_showAwakeningSkill == nil then
        local dic_had_hero_info = _model:getHadHeroInfo()
        for k,star in pairs(dic_had_hero_info) do
            if star >= 13 then
                self.is_showAwakeningSkill = true
                return true
            end
        end
        self.is_showAwakeningSkill = false
        return false
    end
    return self.is_showAwakeningSkill
end


--@ show_type  1 表示 符文技能 2 表示天赋技能
function ArtifactSkillWindow:openRootWnd( show_type, sub_type )
    self.show_type = show_type or 1
    sub_type = sub_type or SKILL_TAB.LOW
    if self.show_type == 2 then
        self.explain_btn:setVisible(false)
    end
	self:changeSelectedTab(sub_type)
end

--初始化13星星信息 并处理好显示位置
function ArtifactSkillWindow:initThirteenInfo()
    if #self.awakenig_list > 0 and self:isShowAwakeningSkill() then
        if not self.list_setting then return end
        local awakening_count = #self.awakenig_list
        local temp = awakening_count % self.list_setting.col
        for i,v in ipairs(self.awakenig_list) do
            table_insert(self.show_list, i, v)
        end
        if temp ~= 0 then --如果不是4的倍数 需要在后面补到4个
            local len = self.list_setting.col - temp
            for i=1,len do
                table_insert(self.show_list, awakening_count + i, {})
            end
            awakening_count = awakening_count + (self.list_setting.col - temp)
        end

        -- --计算位置
        local position_data_list = {}
        local item_width = self.list_setting.item_width
        local item_height = self.list_setting.item_height

        local max_col =  math.ceil(#self.show_list/self.list_setting.col)
        local scroll_height =  self.title_height * 2 + max_col* item_height + self.list_setting.start_y * 2 + (max_col - 1) * self.list_setting.space_y

        local y = scroll_height - self.list_setting.start_y
        local x = 0
        local tittle_pos_y = 0 --第二个title的位置
        for i,v in ipairs(self.show_list) do
            if i == 1 or  i == awakening_count + 1 then
                if i == awakening_count + 1 then
                    tittle_pos_y = y
                end
                y = y -  self.title_height
            end 
            local x = self.list_setting.start_x + ((i - 1) % self.list_setting.col) * (item_width + self.list_setting.space_x) + item_width * 0.5
            position_data_list[i] = cc.p(x, y - item_height * 0.5)

            if i > 1 and i % self.list_setting.col == 0 then
                y = y - (item_height + self.list_setting.space_y)
            end
        end

        return position_data_list, scroll_height, tittle_pos_y
    end
end

function ArtifactSkillWindow:createTitleItem(name,x, y)
    if not self.skill_scrollview then return end
    local size = cc.size(128, 50)
    local item = {}
    local res = PathTool.getResFrame("common","common_90003")
    --item.bg = createImage(self.skill_scrollview.scroll_view, res, x, y - self.title_height *0.5 , cc.p(0.5, 0.5), true, nil, false)
    --item.bg:setScale(5)
    item.bg = createScale9Sprite(res, x, y - self.title_height *0.5 , LOADTEXT_TYPE_PLIST, self.skill_scrollview.scroll_view)
    item.bg:setCapInsets(cc.rect(23, 0, 2, 42))
    item.bg:setContentSize(cc.size(400, 42))
    item.label = createLabel(26, Config.ColorData.data_new_color4[6], nil, x, y - self.title_height *0.5, name, self.skill_scrollview.scroll_view, nil, cc.p(0.5, 0.5))
end

function ArtifactSkillWindow:updateScrollview()
    if self.skill_scrollview == nil then 
        local scroll_view_size = self.skill_panel:getContentSize()
        self.list_setting = {
            -- item_class = ArtifactSkillItem,      -- 单元类
            start_x = 5,                  -- 第一个单元的X起点
            space_x = 32,                    -- x方向的间隔
            start_y = 5,                    -- 第一个单元的Y起点
            space_y = 12,                   -- y方向的间隔
            item_width = 119,               -- 单元的尺寸width
            item_height = 149,              -- 单元的尺寸height
            row = 0,                        -- 行数，作用于水平滚动类型
            col = 4,                         -- 列数，作用于垂直滚动类型
            -- need_dynamic = true
        }
        local position_data_list, container_height, tittle_pos_y = self:initThirteenInfo()
        self.list_setting.position_data_list = position_data_list
        self.list_setting.container_height = container_height
        -- self.skill_scrollview = CommonScrollViewLayout.new(skill_panel, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
        self.skill_scrollview = CommonScrollViewSingleLayout.new(self.skill_panel, cc.p(0, 0), ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, self.list_setting, cc.p(0, 0)) 

        self.skill_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.skill_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.skill_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
        -- self.skill_scrollview:registerScriptHandlerSingle(handler(self,self.onCellTouched), ScrollViewFuncType.OnCellTouched) --更新cell
        if #self.awakenig_list > 0 and self:isShowAwakeningSkill() then
            --显示两个标题
            self:createTitleItem(TI18N("职业专属觉醒天赋"), scroll_view_size.width*0.5, container_height)
            self:createTitleItem(TI18N("通用天赋"), scroll_view_size.width*0.5, tittle_pos_y)
        end
    else
        if #self.awakenig_list > 0 and self:isShowAwakeningSkill() then
            local awakening_count = #self.awakenig_list
            local temp = awakening_count % self.list_setting.col
            for i,v in ipairs(self.awakenig_list) do
                table_insert(self.show_list, i, v)
            end
            if temp ~= 0 then --如果不是4的倍数 需要在后面补到4个
                local len = self.list_setting.col - temp
                for i=1,len do
                    table_insert(self.show_list, awakening_count + i, {})
                end
            end
        end
    end

    self.skill_scrollview:reloadData()
end

--@width 是setting.item_width
--@height 是setting.item_height
function ArtifactSkillWindow:createNewCell(width, height)
    local cell = ArtifactSkillItem.new()
    -- cell:setScale(0.9)
    -- cell.skill_item:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end
--获取数据数量
function ArtifactSkillWindow:numberOfCells()
    if not self.show_list then return 0 end
    return #self.show_list
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function ArtifactSkillWindow:updateCellByIndex(cell, index)
    -- cell.index = index
    local skill_data = self.show_list[index]
    if skill_data then
        cell:setVisible(true)
        cell:setData(skill_data)
    else
        cell:setVisible(false)
    end
end

function ArtifactSkillWindow:close_callback(  )
	if self.skill_scrollview then
		self.skill_scrollview:DeleteMe()
		self.skill_scrollview = nil
	end
	_controller:openArtifactSkillWindow(false)
end

-----------------------@ skill item
ArtifactSkillItem = class("ArtifactSkillItem", function()
    return ccui.Widget:create()
end)

function ArtifactSkillItem:ctor()
	self:configUI()
	self:register_event()
end

function ArtifactSkillItem:configUI(  )
	self.size = cc.size(119, 149)
	self:setTouchEnabled(false)
    self:setContentSize(self.size)

	local csbPath = PathTool.getTargetCSB("forgehouse/artifact_skill_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    self.container = self.root_wnd:getChildByName("container")

    self.skill_name = self.container:getChildByName("skill_name")
end

function ArtifactSkillItem:register_event(  )
end

function ArtifactSkillItem:setData( skill_config )
	if not skill_config then return end
	self.skill_name:setString(skill_config.name)

	if not self.skill_item then
		self.skill_item = SkillItem.new(true,true,true,nil,nil,false)
		self.skill_item:setPosition(cc.p(self.size.width/2, self.size.height/2+15))
		self.container:addChild(self.skill_item)
	end
    self.skill_item:setData(skill_config)
    
    local is_unusual = false
    local type = 1
    if _model:checkIsUnusualSkillById(skill_config.bid) then -- 稀有      
        is_unusual = true
    elseif _model:checkIsUnusualSkillById2(skill_config.bid) then --强力
        is_unusual = true
        type = 2
    end	
    self.skill_item:showUnusualIcon(is_unusual,type)
end

function ArtifactSkillItem:DeleteMe(  )
	if self.skill_item then
		self.skill_item:DeleteMe()
		self.skill_item = nil
	end
end