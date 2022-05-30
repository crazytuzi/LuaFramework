--------------------------------------------
-- @Author  : xhj
-- @Editor  : xhj
-- @Date    : 2020-3-1 17:10:31
-- @description    : 
		-- 无尽试炼
---------------------------------
EndlessTrailMainWindow = EndlessTrailMainWindow or BaseClass(BaseView)

local controller = Endless_trailController:getInstance()
local model = controller:getModel()

function EndlessTrailMainWindow:__init()
	self.win_type = WinType.Full
	self.is_full_screen = true
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("endless", "endless"), type = ResourcesType.plist},
		{path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_51",true), type = ResourcesType.single },
	}
	self.layout_name = "endlesstrail/endlesstrail_main_window"
	self.panel_list = {}
	self.tab_list = {}
	self.cur_tab_index = Endless_trailEvent.Tab_Index.endless
end

function EndlessTrailMainWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())
	self.background:loadTexture(PathTool.getPlistImgForDownLoad("bigbg","bigbg_51",true), LOADTEXT_TYPE)
    local main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(main_container, 1)

	self.close_btn = main_container:getChildByName("close_btn")
    

    self.tab_container = main_container:getChildByName("tab_container")
	self.tab_container:setVisible(false)
    local tab_name_list = {
        [1] = TI18N("综合试炼"),
        [2] = TI18N("草系试炼")
    }
    for i=1,2 do
        local tab_btn = self.tab_container:getChildByName("tab_btn_"..i)
		self.tab_btn = tab_btn
        if tab_btn then
            local object = {}
            object.unselect_bg = tab_btn:getChildByName('unselect_bg')
            object.unselect_bg:setVisible(true)
            object.select_bg = tab_btn:getChildByName('select_bg')
            object.select_bg:setVisible(false)

            -- object.label:setTextColor(cc.c4b(0xcf, 0xb5, 0x93, 0xff))
            object.lable = tab_btn:getChildByName("title")
			object.lable:setString(tab_name_list[i])
			-- setLabelAutoScale(object.lable,object.select_bg,60)
			object.tab_btn = tab_btn
			object.tips = tab_btn:getChildByName("tips")
            object.index = i
            self.tab_list[i] = object
        end
    end

	self.container = main_container:getChildByName("container")
	self.top_panel = main_container:getChildByName("top_panel")
	self.rank_container = self.top_panel:getChildByName("rank_container")
	--self.rank_bg_2 = self.top_panel:getChildByName("Image_9")
	
	self.bottom_panel = main_container:getChildByName("bottom_panel")
	self.bottom_panel:getChildByName("titile_lab_1"):setString(TI18N("排\n名\n奖\n励"))
	self.bottom_panel:getChildByName("titile_lab_2"):setString(TI18N("通\n关\n奖\n励"))
	-- 适配
	local top_off = display.getTop(main_container)
	--self.tab_container:setPositionY(top_off - 128)
	--self.top_panel:setPositionY(top_off - 152)
	local bottom_off = display.getBottom(main_container)
	--self.close_btn:setPositionY(bottom_off + 135)
	--self.bottom_panel:setPositionY(bottom_off + 114)
end

function EndlessTrailMainWindow:register_event(  )
	registerButtonEventListener(self.close_btn, handler(self, self._onClickCloseBtn), nil, 2)

	if not self.update_base_event then
        self.update_base_event = GlobalEvent:getInstance():Bind(Endless_trailEvent.UPDATA_BASE_DATA,function()
			self:updateTab()
			self:updateTabShowStatus()
			self:updateTabBtnRedStatus()
        end)
    end

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

function EndlessTrailMainWindow:updateTab( )
	local data = model:getEndlessData()
	
	if data then
		local str = TI18N("系试炼")
		if data.select_type == Endless_trailEvent.endless_type.water then
			str = TI18N("水系试炼")
		elseif data.select_type == Endless_trailEvent.endless_type.fire then
			str = TI18N("火系试炼")
		elseif data.select_type == Endless_trailEvent.endless_type.wind then
			str = TI18N("风系试炼")
		elseif data.select_type == Endless_trailEvent.endless_type.light_dark then
			str = TI18N("光暗试炼")
		end
		if self.tab_list and self.tab_list[2] and self.tab_list[2].lable then
			self.tab_list[2].lable:setString(str)
		end
		-- setLabelAutoScale(self.tab_list[2].lable,self.tab_btn)
	end
end

function EndlessTrailMainWindow:updateTabShowStatus(  )
	if controller:checkNewEndLessIsShow() == false then
		self.tab_container:setVisible(false)
	else
		self.tab_container:setVisible(true)
	end
end

function EndlessTrailMainWindow:setRankShow()
    if RankController:getInstance():checkRankIsShow() then
		self.rank_container:setVisible(true)
		--self.rank_bg_2:setVisible(true)
    else
		self.rank_container:setVisible(false)
		--self.rank_bg_2:setVisible(false)
    end
end

-- tab按钮红点
function EndlessTrailMainWindow:updateTabBtnRedStatus(  )
    for _,object in ipairs(self.tab_list) do
        local red_status = false
		if object.index == Endless_trailEvent.Tab_Index.endless and self.cur_tab_index ~= object.index then -- 老版
			if model:getIsGetAllReward() or 
			model:getFirstGet(Endless_trailEvent.endless_type.old) or
			model:getIsSendPartner() then
                red_status = true
            end
		elseif object.index == Endless_trailEvent.Tab_Index.campEndless and self.cur_tab_index ~= object.index and controller:checkNewEndLessIsOpen() == true then -- 新版
			local data = model:getEndlessData()
			if data then
				 -- model:getIsSendPartner() or 
				if model:getFirstGet(data.select_type) or
				model:getIsGetAllRewardNew() then
					red_status = true
				end
			end
		end
		
        if object.tips then
            object.tips:setVisible(red_status)
        end
    end
end

-- 切换标签页
function EndlessTrailMainWindow:changeSelectedTab( index )
	if self.tab_object ~= nil and self.tab_object.index == index then return end
    
    if self.tab_object then
        self.tab_object.select_bg:setVisible(false)
        self.tab_object = nil
    end
    self.tab_object = self.tab_list[index]
    if self.tab_object then
        self.tab_object.select_bg:setVisible(true)
    end
	self.cur_tab_index = index
	if self.select_panel then
		self.select_panel:addToParent(false)
		self.select_panel = nil
	end
	self.select_panel = self.panel_list[index]
	if self.select_panel == nil then
		if index == Endless_trailEvent.Tab_Index.endless then
			self.select_panel = EndlessTrailPanel.new()
		elseif index == Endless_trailEvent.Tab_Index.campEndless then
			self.select_panel = EndlessTrailCampPanel.new()
		end
		if self.select_panel then
			self.container:addChild(self.select_panel)
			self.panel_list[index] = self.select_panel
		end
	end
	if self.select_panel then
		self.select_panel:addToParent(true)
	end

	self:updateTabBtnRedStatus()
end


function EndlessTrailMainWindow:openRootWnd( )
	local index = Endless_trailEvent.Tab_Index.endless
	local data = model:getEndlessData()
	if data then
		if data.type ~= 0 and data.type ~= Endless_trailEvent.endless_type.old then
			index = Endless_trailEvent.Tab_Index.campEndless
		end
	end
	self:changeSelectedTab(index)
	self:setRankShow()
	controller:send23900()
end

-----------------@ 按钮点击事件
-- 关闭
function EndlessTrailMainWindow:_onClickCloseBtn(  )
	controller:openEndlessMainWindow(false)
end


function EndlessTrailMainWindow:close_callback(  )
	if self.update_base_event then
        GlobalEvent:getInstance():UnBind(self.update_base_event)
        self.update_base_event = nil
	end
	
	for k, panel in pairs(self.panel_list) do
        panel:DeleteMe()
    end
    self.panel_list = nil

    controller:openEndlessMainWindow(false)
end