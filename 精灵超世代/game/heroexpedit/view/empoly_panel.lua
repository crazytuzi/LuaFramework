--************************
--好友助阵
--************************
EmpolyPanel = EmpolyPanel or BaseClass(BaseView)

local controller = HeroExpeditController:getInstance()
local model = controller:getModel()

local table_insert = table.insert
local table_sort = table.sort
function EmpolyPanel:__init()
    self.is_full_screen = false
    self.layout_name = "heroexpedit/empoly_panel"
    self.win_type = WinType.Tips   
    self.view_tag = ViewMgrTag.DIALOGUE_TAG 
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("heroexpedit", "heroexpedit"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("bigbg", "bigbg_3"), type = ResourcesType.single},
    }
    self.cur_index = nil
    self.tab_list = {}
end

function EmpolyPanel:open_callback()
	self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    --我的支援宝可梦列表
    self.hero_list = HeroController:getInstance():getModel():getExpeditHeroData()
    self.hero_list = self.hero_list or {}

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 2) 
    self.main_container:getChildByName("Image_6"):getChildByName("Text_7"):setString(TI18N("好友助阵"))
    self.text_empoly_num = self.main_container:getChildByName("Text_2")
    self.text_empoly_num:setString("")
    	
    local tab_container = self.main_container:getChildByName("tab_container")
    local tab_name = {TI18N("支援我的"),TI18N("我的支援")}
    for i=1,2 do
    	local tab = {}
    	tab.btn = tab_container:getChildByName("btn_"..i)
    	tab.normal = tab.btn:getChildByName("normal")
    	tab.select = tab.btn:getChildByName("select")
    	tab.select:setVisible(false)
    	tab.title = tab.btn:getChildByName("title")
        tab.title:setString(tab_name[i])
    	tab.title:setTextColor(cc.c4b(0xcf, 0xb5, 0x93, 0xff))
    	tab.title:enableOutline(cc.c4b(0x2a,0x16,0x0e,0xff), 2)
    	tab.index = i
    	self.tab_list[i] = tab
    end

    local good_cons = self.main_container:getChildByName("good_cons")
    self.empty_bg = createSprite(PathTool.getPlistImgForDownLoad("bigbg", "bigbg_3"), good_cons:getContentSize().width*0.5, good_cons:getContentSize().height*0.5, good_cons, cc.p(0.5, 0.5), LOADTEXT_TYPE)
    local empty_label = createLabel(24,Config.ColorData.data_color4[187],nil,self.empty_bg:getContentSize().width*0.5,-10,"",self.empty_bg,0, cc.p(0.5,0.5))
    empty_label:setString(TI18N("暂无可雇佣宝可梦，快去叫好友派遣宝可梦吧~~~"))
    self.empty_bg:setVisible(false)

    local scroll_view_size = good_cons:getContentSize()
    local setting = {
        item_class = EmpolyPanelItem,      -- 单元类
        start_x = 2,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 5,                    -- y方向的间隔
        item_width = 631,               -- 单元的尺寸width
        item_height = 149,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }
    self.item_scrollview = CommonScrollViewLayout.new(good_cons, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
end

function EmpolyPanel:tabChangeView(index)
	index = index or 1
	if self.cur_index == index then return end
	if self.cur_tab ~= nil then
		self.cur_tab.select:setVisible(false)
		self.cur_tab.title:setTextColor(cc.c4b(0xcf, 0xb5, 0x93, 0xff))
	end
	self.cur_index = index

	self.cur_tab = self.tab_list[self.cur_index]
	if self.cur_tab ~= nil then
		self.cur_tab.select:setVisible(true)
		self.cur_tab.title:setTextColor(cc.c4b(0xff, 0xed, 0xd6, 0xff))
	end

 	if index == 1 then
 		controller:sender24406()
		self.text_empoly_num:setVisible(true)
 	elseif index == 2 then
 		self.text_empoly_num:setVisible(false)
 		self.empty_bg:setVisible(false)
 		controller:sender24405()
 	end
end

function EmpolyPanel:isVisibleRedPoint()
	local status = controller:getModel():getHeroSendRedPoint()
	addRedPointToNodeByStatus(self.tab_list[2].btn, status,nil,11)
end

function EmpolyPanel:openRootWnd()
	self:tabChangeView(1)
	self:isVisibleRedPoint()
end

function EmpolyPanel:powerSort(data_list)
	local function sort_func(a,b)
		if a.is_employ and b.is_employ then
			if a.is_employ == 1 and b.is_employ == 1 then
				return a.power > b.power
			elseif a.is_employ == 1 and b.is_employ == 0 then
				return a.sort > b.sort
			elseif a.is_employ == 0 and b.is_employ == 1 then
				return false
			elseif a.is_employ == 0 and b.is_employ == 0 then
				return a.power > b.power
			end
		else
			return a.power > b.power
		end
	end
	table_sort(data_list,sort_func)
end
-- 支援我的
function EmpolyPanel:helpMeHero()
	local help_me_data = model:getEmployHelpMeData()
	if next(help_me_data) ~= nil then
		self.empty_bg:setVisible(false)
		local hero_list = {}
		local num = 0
		for i,v in pairs(help_me_data) do
			v.sort = 0
			v.help_type = 2
			if v.is_employ == 1 then
				v.sort = 2
				num = num + 1
			end
			table_insert(hero_list,v)
		end
		self:powerSort(hero_list)
		if self.item_scrollview then
			self.item_scrollview:setData(hero_list)
		end
		local str = string.format(TI18N("今日已雇佣： %d/%d"),num,3)
		self.text_empoly_num:setString(str)
	else
		self.empty_bg:setVisible(true)
		if self.item_scrollview then
			self.item_scrollview:setData({})
		end
	end
end
function EmpolyPanel:helpMeSort(list)
	local function sort_func(a,b)
		if a.sort and b.sort then
			if a.sort == 1 and b.sort == 1 then
				return a.power > b.power
			elseif a.sort == 1 and b.sort == 0 then
				return a.sort > b.sort
			elseif a.sort == 0 and b.sort == 1 then
				return false
			elseif a.sort == 0 and b.sort == 0 then
				return a.power > b.power
			end
		else
			return a.power > b.power
		end
	end
	table_sort(list,sort_func)
end
--我的支援
function EmpolyPanel:meHelpHero(help_list)
	if next(self.hero_list) ~= nil then
		local list = {}
		local insert_status = false
		for i,v in pairs(self.hero_list) do
			v.sort = 0
			v.help_type = 1
			if help_list and next(help_list) then
				for k,val in pairs(help_list) do
					if v.id == val.id then
						v.sort = 1
						insert_status = true
					end
				end
			end
			table_insert(list,v)
		end
		if help_list and next(help_list) ~= nil and insert_status == false then --当宝可梦分解掉的时候
			help_list[1].sort = 1 --每次只能派出出一个宝可梦
			table_insert(list,1,help_list[1])
		end
		self:helpMeSort(list)
		if self.item_scrollview then
			self.item_scrollview:setData(list)
		end
	else
		if self.item_scrollview then
			self.item_scrollview:setData({})
		end
	end
end
function EmpolyPanel:register_event()
	--支援我的
	self:addGlobalEvent(HeroExpeditEvent.Employ_Help_Me, function()
		self:helpMeHero()
	end)
	--我的支援
	self:addGlobalEvent(HeroExpeditEvent.Employ_Me_Help,function(data)
		self:meHelpHero(data.list)
	end)
	self:addGlobalEvent(HeroExpeditEvent.MeHelp_RedPoint_Event,function(data)
		self:isVisibleRedPoint()
	end)
 	for i,v in pairs(self.tab_list) do
    	registerButtonEventListener(v.btn, function()
	        self:tabChangeView(v.index)
	    end,false, 1)
    end
    registerButtonEventListener(self.background,function()
    	controller:openEmpolyPanelView(false)
    end,false,2)
end

function EmpolyPanel:close_callback()
	if self.item_scrollview then 
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
	controller:openEmpolyPanelView(false)
end

--========================
--子项
--========================
EmpolyPanelItem = class("EmpolyPanelItem", function()
    return ccui.Widget:create()
end)

local partner_data = Config.PartnerData.data_partner_base
function EmpolyPanelItem:ctor()
    self:createRootWnd()
    self:registerEvent()
end
function EmpolyPanelItem:createRootWnd()
    self.rootWnd = createCSBNote(PathTool.getTargetCSB("heroexpedit/empoly_panel_item"))
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:addChild(self.rootWnd)
    self:setCascadeOpacityEnabled(true)
    self:setContentSize(cc.size(631, 149))

    self.main_container = self.rootWnd:getChildByName("main_container")

    self.btn_enpoly = self.main_container:getChildByName("btn_enpoly")
    self.btn_enpoly:setVisible(false)
    self.text_btn_enpoly = self.btn_enpoly:getChildByName("Text_1_0")
    self.text_btn_enpoly:setString(TI18N("已雇佣"))
    self.btn_config = self.main_container:getChildByName("btn_config")
    self.btn_config:setVisible(false)
    self.btn_config:getChildByName("Text_1"):setString(TI18N("选择"))

    self.text_name = self.main_container:getChildByName("text_name")
    self.text_power = self.main_container:getChildByName("text_power")
    self.text_firend = self.main_container:getChildByName("text_firend")
    self.text_firend_label = self.main_container:getChildByName("text_power_0")
    self.text_firend_label:setVisible(false)
    self.text_firend_label:setString("来自好友:")
    self.text_firend:setVisible(false)

    self.my_head = HeroExhibitionItem.new(1, false)
    self.my_head:setPosition(cc.p(72,72))
    self.main_container:addChild(self.my_head)
 end

function EmpolyPanelItem:setData(data)
	if not data or not next(data) then return end
	self.data = data

	local str = TI18N("选择")
	if data.sort == 1 then
		str = TI18N("已派遣")
	elseif data.sort == 2 then
		str = TI18N("已雇佣")
	end
	self.btn_config:setVisible(data.sort == 0)
	self.btn_enpoly:setVisible(data.sort == 1 or data.sort == 2)
	self.text_btn_enpoly:setString(str)

	if data.help_type == 2 then
		self.text_firend_label:setVisible(true)
    	self.text_firend:setVisible(true)
	else
		self.text_firend_label:setVisible(false)
    	self.text_firend:setVisible(false)
	end
	self.text_firend:setString(data.name or "")
	self.text_power:setString(data.power or 0)

	local name = ""
	if partner_data[data.bid] and partner_data[data.bid].name then
		name = partner_data[data.bid].name
	end
	self.text_name:setString(name)

	self.my_head:setData(data)
end

function EmpolyPanelItem:registerEvent()
    registerButtonEventListener(self.btn_config,function()
    	self:setChooseHero()
    end,true,1)
end
function EmpolyPanelItem:setChooseHero()
	if self.data and self.data.help_type then
        if self.data and self.data.help_type == 1 then
            --我的支援需要检查共鸣宝可梦
            if self.data.checkResonateHero and self.data:checkResonateHero() then
                return
            end
        end

		local function call_back()
			if self.data and self.data.help_type == 1 then
				controller:sender24407(self.data.id)
			elseif self.data and self.data.help_type == 2 then
				controller:sender24408(self.data.rid, self.data.srv_id, self.data.id)
			end
		end
		local str 
	    if self.data.help_type == 2 then
	    	str = TI18N("是否确认雇佣该宝可梦？")
        else
            str = TI18N("是否确认派遣该宝可梦？")
	    end
		CommonAlert.show(str, TI18N("确定"), call_back, TI18N("取消"), nil, CommonAlert.type.rich,nil,nil,26)
	end
end
function EmpolyPanelItem:DeleteMe()
	if self.my_head then
        self.my_head:DeleteMe()
        self.my_head = nil
    end 
	self:removeAllChildren()
	self:removeFromParent()
end
