--------------------------------------------
-- @Author  : htp
-- @Editor  : xhj
-- @Date    : 2018-11-20 17:10:31
-- @description    : 
		-- 天界副本
---------------------------------
HeavenMainWindow = HeavenMainWindow or BaseClass(BaseView)

local controller = HeavenController:getInstance()
local model = controller:getModel()

function HeavenMainWindow:__init(index)
	self.win_type = WinType.Full
	self.is_full_screen = true
	self.cur_index = index or HeavenConst.Tab_Index.Dungeon
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_85",true), type = ResourcesType.single },
		{path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_86",true), type = ResourcesType.single},
	}
	self.layout_name = "heaven/heaven_main_window"
	self.panel_list = {}
	self.tab_list = {}
	self.cur_tab_index = HeavenConst.Tab_Index.Dungeon  -- 当前选中的tab按钮

	self.role_vo = RoleController:getInstance():getRoleVo()
end

function HeavenMainWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    local main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(main_container, 1)  

	self.close_btn = main_container:getChildByName("close_btn")
	self.close_btn:setName("guide_close_btn")
    local tab_container = main_container:getChildByName("tab_container")

    local tab_name_list = {
        [1] = TI18N("天界副本"),
        [2] = TI18N("天界祈祷")
    }
    for i=1,2 do
        local tab_btn = tab_container:getChildByName("tab_btn_"..i)
        if tab_btn then
            local object = {}
            object.unselect_bg = tab_btn:getChildByName('unselect_bg')
            object.unselect_bg:setVisible(true)
            object.select_bg = tab_btn:getChildByName('select_bg')
            object.select_bg:setVisible(false)
            -- object.label:setTextColor(cc.c4b(0xcf, 0xb5, 0x93, 0xff))
			object.lable = tab_btn:getChildByName("title")
			object.tips = tab_btn:getChildByName("tips")
            object.lable:setString(tab_name_list[i])
            object.tab_btn = tab_btn
            object.index = i
            self.tab_list[i] = object
        end
    end

	self.container = main_container:getChildByName("container")
	-- 适配
	local top_off = display.getTop(main_container)
	tab_container:setPositionY(top_off - 143)
	local bottom_off = display.getBottom(main_container)
	self.close_btn:setPositionY(bottom_off+147)
end

function HeavenMainWindow:register_event(  )
	registerButtonEventListener(self.close_btn, handler(self, self._onClickCloseBtn), nil, 2)


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
	
	
	--红点
	if not self.update_heaven_red_status  then
		self.update_heaven_red_status = GlobalEvent:getInstance():Bind(HeavenEvent.Update_Heaven_Red_Status,function (bid)
			if bid == HeavenConst.Red_Index.Dial then
				self:updateTabBtnRedStatus()
			end
		end)
	end


end

-- 切换标签页
function HeavenMainWindow:changeSelectedTab( index )
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
	if index == HeavenConst.Tab_Index.Dungeon then
		self.background:loadTexture(PathTool.getPlistImgForDownLoad("bigbg","bigbg_85",true), LOADTEXT_TYPE)
	elseif index == HeavenConst.Tab_Index.DialRecord then
		self.background:loadTexture(PathTool.getPlistImgForDownLoad("bigbg","bigbg_86",true), LOADTEXT_TYPE)
	end

	if self.select_panel then
		self.select_panel:addToParent(false)
		self.select_panel = nil
	end
	self.select_panel = self.panel_list[index]
	if self.select_panel == nil then
		if index == HeavenConst.Tab_Index.Dungeon then
			self.select_panel = HeavenDungeonPanel.new()
            
		elseif index == HeavenConst.Tab_Index.DialRecord then
			self.select_panel = HeavenDialWindow.new(self.dial_group_id)
		end
		if self.select_panel then
			self.container:addChild(self.select_panel)
			self.panel_list[index] = self.select_panel
		end
	end
    
    if index == HeavenConst.Tab_Index.Dungeon then
        local cur_fight_type = BattleController:getInstance():getCurFightType()
        if cur_fight_type ~= BattleConst.Fight_Type.HeavenWar then
            MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.HeavenWar)
        end
    elseif index == HeavenConst.Tab_Index.DialRecord then
        BattleController:getInstance():openBattleView(false)
    end
	if self.select_panel then
		self.select_panel:addToParent(true)
	end
	self:updateTabBtnRedStatus()
end

-- tab按钮红点
function HeavenMainWindow:updateTabBtnRedStatus(  )
    for _,object in ipairs(self.tab_list) do
        local red_status = false
        if object.index == HeavenConst.Tab_Index.Dungeon and self.cur_tab_index ~= object.index then -- 天界副本
			if model:getHeavenRedStatusByBid(HeavenConst.Red_Index.Count) or 
			model:getHeavenRedStatusByBid(HeavenConst.Red_Index.Award) then
                red_status = true
            end
        elseif object.index == HeavenConst.Tab_Index.DialRecord and self.cur_tab_index ~= object.index then -- 天界祈祷
			if model:getHeavenRedStatusByBid(HeavenConst.Red_Index.Dial) or 
			model:getHeavenRedStatusByBid(HeavenConst.Red_Index.DialAward) then
                red_status = true
            end
        end
        if object.tips then
            object.tips:setVisible(red_status)
        end
    end
end

--data数据{group_id ,index,is_open_chapter,chapter_id}
function HeavenMainWindow:openRootWnd(data)
	if data then
		self.dial_group_id = data.group_id
		self.cur_index = data.index or HeavenConst.Tab_Index.Dungeon
		self:changeSelectedTab(self.cur_index)
		GlobalEvent:getInstance():Fire(MainuiEvent.HEAD_UPDATE_WEALTH_EVENT, 2, Config.ItemData.data_assets_label2id.gold)

		--[[
			1.强制打开某一章节
			2.记录上一次打开的章节界面，如果有打开过，则默认直接打开
		]]
		
		if data.is_open_chapter == true then
			local last_show_chapter_id = model:getHeavenLastShowChapterId()
			chapter_id = data.chapter_id or last_show_chapter_id
			if chapter_id then
				controller:openHeavenChapterWindow(true, chapter_id)
			end
		end
	end
	
	
end

-----------------@ 按钮点击事件
-- 关闭
function HeavenMainWindow:_onClickCloseBtn(  )
	controller:openHeavenMainWindow(false)
end


function HeavenMainWindow:close_callback(  )
	for k, panel in pairs(self.panel_list) do
        panel:DeleteMe()
    end
	self.panel_list = nil
	
	if self.update_heaven_red_status then
        GlobalEvent:getInstance():UnBind(self.update_heaven_red_status)
        self.update_heaven_red_status = nil
	end

    if self.role_vo ~= nil then
        if self.role_assets_event ~= nil then
            self.role_vo:UnBind(self.role_assets_event)
            self.role_assets_event = nil
        end
    end

	controller:openHeavenMainWindow(false)
	if HeroController:getInstance():getHeroMainInfoWindow() then
		GlobalEvent:getInstance():Fire(MainuiEvent.HEAD_UPDATE_WEALTH_EVENT, 2, Config.ItemData.data_assets_label2id.hero_exp)
	end
end