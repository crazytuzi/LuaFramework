-- --------------------------------------------------------------------
-- 众神战场奖励和说明面板
-- 
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @editor: shiraho@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--     奖励和说明
-- <br/>Create: 2017-xx-xx
-- --------------------------------------------------------------------
GodBattleRewardsWindow = GodBattleRewardsWindow or BaseClass(BaseView)

local controller = GodbattleController:getInstance()

function GodBattleRewardsWindow:__init()
    self.is_full_screen = false
    self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.layout_name = "godbattle/godbattle_rewards_window"
    self.res_list = {
        
    }
    self.tab_list = {}
    self.panel_list = {}
end

function GodBattleRewardsWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display:getMaxScale())

    local main_container  = self.root_wnd:getChildByName("main_container")
    local main_panel = main_container:getChildByName("main_panel")
    main_panel:getChildByName("win_title"):setString(TI18N("众神战场"))

    self.close_btn = main_panel:getChildByName("close_btn")
    self.container = main_panel:getChildByName("container")

    local tab_container = main_panel:getChildByName("tab_container")
    for i=1,2 do
		local object = {}
        local tab_btn = tab_container:getChildByName("tab_btn_"..i)
        if tab_btn then
            local title = tab_btn:getChildByName("title")
			local tips = tab_btn:getChildByName("tips")
            if i == 1 then
                title:setString(TI18N("规则说明"))
            elseif i == 2 then
                title:setString(TI18N("奖励预览"))
            end
            title:setTextColor(cc.c4b(0xcf, 0xb5, 0x93, 0xff))
            tab_btn:setBright(false)
            object.tab_btn = tab_btn
            object.label = title
			object.index = i
			object.tips = tips
            self.tab_list[i] = object
        end
    end
end

function GodBattleRewardsWindow:register_event()
	self.close_btn:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playCloseSound()
			controller:openGodBattleRewardsWindow(false)
		end
	end) 
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

function GodBattleRewardsWindow:openRootWnd(type)
    type = type or 1
    self:changeSelectedTab(type)

end

function GodBattleRewardsWindow:changeSelectedTab(index)
	if self.tab_object ~= nil and self.tab_object.index == index then return end
	if self.tab_object then
		self.tab_object.tab_btn:setBright(false)
		self.tab_object.label:setTextColor(cc.c4b(0xcf, 0xb5, 0x93, 0xff)) 
		self.tab_object = nil
	end
	self.tab_object = self.tab_list[index]
	if self.tab_object then
		self.tab_object.label:setTextColor(cc.c4b(0xff, 0xed, 0xd6, 0xff))
		self.tab_object.tab_btn:setBright(true)
	end
	if self.select_panel then
		self.select_panel:addToParent(false)
		self.select_panel = nil
	end
	self.select_panel = self.panel_list[index]
	if self.select_panel == nil then
		if index == 1 then
            self.select_panel = GodBattleExplainPanel.New(self.container)
		elseif index == 2 then
            self.select_panel = GodBattleRankRewardPanel.New(self.container)
		end
        if self.select_panel then
            self.panel_list[index] = self.select_panel
        end
	end
    if self.select_panel then
	    self.select_panel:addToParent(true)
    end
end

function GodBattleRewardsWindow:close_callback()
    for k, panel in pairs(self.panel_list) do
        panel:DeleteMe()
    end
    self.panel_list = nil
    controller:openGodBattleRewardsWindow(false)
end
