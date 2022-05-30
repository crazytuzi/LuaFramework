--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2018-10-15 20:20:24
-- @description    : 
		-- 联盟战 进攻一览
---------------------------------
GuildwarAttkLookWindow = GuildwarAttkLookWindow or BaseClass(BaseView)

local controller = GuildwarController:getInstance()
local model = controller:getModel()

function GuildwarAttkLookWindow:__init(  )
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Big
	self.is_full_screen = false
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("guildwar", "guildwar"), type = ResourcesType.plist}
	}
	self.layout_name = "guildwar/guildwar_attk_look_window"
end

function GuildwarAttkLookWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    local container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(container, 1)

    local win_title = container:getChildByName("win_title")
    win_title:setString(TI18N("进攻一览"))

    self.challenge_label = container:getChildByName("challenge_label")
    self.close_btn = container:getChildByName("close_btn")
    self.confirm_btn = container:getChildByName("confirm_btn")
    self.confirm_btn_label = self.confirm_btn:getChildByName("label")
    self.confirm_btn_label:setString(TI18N("确定"))
    self.list_panel = container:getChildByName("list_panel")

    local bgSize = self.list_panel:getContentSize()
	local scroll_view_size = cc.size(bgSize.width, bgSize.height-8)
    local setting = {
        item_class = GuildwarAttkLookItem,      -- 单元类
        start_x = 1,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = 612,               -- 单元的尺寸width
        item_height = 124,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }

    self.item_scrollview = CommonScrollViewLayout.new(self.list_panel, cc.p(0,5) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)

    self:setData()
end

function GuildwarAttkLookWindow:register_event(  )
	self.background:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playCloseSound()
			controller:openAttkLookWindow(false)
		end
	end) 

	self.close_btn:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playCloseSound()
			controller:openAttkLookWindow(false)
		end
	end) 

	self.confirm_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
            controller:openAttkLookWindow(false)
		end
	end)
end

function GuildwarAttkLookWindow:openRootWnd(  )
	
end

function GuildwarAttkLookWindow:setData(  )
	-- 挑战次数
	local challenge_count = model:getGuildWarChallengeCount()
	local max_count = Config.GuildWarData.data_const.challange_time_limit.val
	self.challenge_label:setString(string.format(TI18N("挑战次数：%d/%d"), (max_count-challenge_count), max_count))

	local enemy_position_data = model:getEnemyGuildWarPositionList()
    local function sortFunc( objA, objB )
        if objA.hp == objB.hp then
            return objA.pos < objB.pos
        else
            return objA.hp > objB.hp
        end
    end
    table.sort(enemy_position_data, sortFunc)
	self.item_scrollview:setData(enemy_position_data)
end

function GuildwarAttkLookWindow:close_callback(  )
	if self.item_scrollview then
		self.item_scrollview:DeleteMe()
		self.item_scrollview = nil
	end
	controller:openAttkLookWindow(false)
end


----------------------------------------------
--@ 子项
GuildwarAttkLookItem = class("GuildwarAttkLookItem", function()
    return ccui.Widget:create()
end)

function GuildwarAttkLookItem:ctor()
	self:configUI()
	self:register_event()
end

function GuildwarAttkLookItem:configUI(  )
	self.size = cc.size(616,124)
	self:setTouchEnabled(true)
    self:setContentSize(self.size)

	local csbPath = PathTool.getTargetCSB("guildwar/guildwar_attk_look_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    self.container = self.root_wnd:getChildByName("container")

    self.build = self.container:getChildByName("build")
    self.name_label = self.container:getChildByName("name_label")
    self.attk_label = self.container:getChildByName("attk_label")
    self.tips_label = self.container:getChildByName("tips_label")
    self.tips_label:setString(TI18N("已达被挑战上限"))

    -- self.tips_label_2 = self.container:getChildByName("tips_label_2")
    self.tips_label_2 = createRichLabel(16,Config.ColorData.data_color3[183],
cc.p(0.5,0.5),cc.p(520,25),nil,nil,200)
    self.container:addChild(self.tips_label_2)
    self.tips_label_2:setString(TI18N("挑战废墟提升增益"))
    self.confirm_btn = self.container:getChildByName("confirm_btn")
    self.confirm_btn_label = self.confirm_btn:getChildByName("label")
    self.confirm_btn_label:setString(TI18N("挑战"))

    local temp_index = {
        [1] = 3,
        [2] = 2,
        [3] = 1
    }
    self.star_list = {}
    for i=1,3 do
    	local star = self.container:getChildByName(string.format("star_%d", i))
    	if star then
    		star:setVisible(false)
            local index = temp_index[i]
    		self.star_list[index] = star
    	end
    end
end

function GuildwarAttkLookItem:register_event(  )
	self.confirm_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            local status = model:getGuildWarStatus()
            if status == GuildwarConst.status.settlement then
                message(TI18N("本次公会战已结束啦，不能再挑战了哦"))
            elseif self.data then
                controller:openAttkPositionWindow(true, self.data.pos)
            end
        end
    end)
end

function GuildwarAttkLookItem:setData( data )
	if self.data ~= nil then
        if self.update_self_event ~= nil then
            self.data:UnBind(self.update_self_event)
            self.update_self_event = nil
        end
    end

    if data ~= nil then
        self.data = data
        if self.update_self_event == nil then
            self.update_self_event = self.data:Bind(GuildwarEvent.UpdateGuildWarPositionDataEvent, function() 
                self:refreshAttkLookItem()
            end)
        end
        self:refreshAttkLookItem()
    end
end

function GuildwarAttkLookItem:refreshAttkLookItem(  )
	if self.data.hp <= 0 then
		self.build:loadTexture(PathTool.getResFrame("guildwar","guildwar_1020"), LOADTEXT_TYPE_PLIST)
		local max_count = 0
        local count_config = Config.GuildWarData.data_const.ruins_challange_limit
        if count_config then
            max_count = count_config.val
        end
        if self.data.relic_def_count >= max_count then -- 达到挑战次数上线
            self.tips_label:setVisible(true)
            self.confirm_btn:setVisible(false)
            self.tips_label_2:setVisible(false)
        else
            self.tips_label:setVisible(false)
            self.confirm_btn:setVisible(true)
            self.tips_label_2:setVisible(true)
        end
        if not self.build_fall_effect then
            self.build_fall_effect = createEffectSpine(PathTool.getEffectRes(326), cc.p(68, 65), cc.p(0.5, 0.5), true, PlayerAction.action)
            self.build_fall_effect:setScale(0.8)
            self.container:addChild(self.build_fall_effect)
        end
        self.build_fall_effect:setVisible(true)
	else
		self.build:loadTexture(PathTool.getResFrame("guildwar","guildwar_1017"), LOADTEXT_TYPE_PLIST)
        self.tips_label:setVisible(false)
        self.confirm_btn:setVisible(true)
        self.tips_label_2:setVisible(false)
        if self.build_fall_effect then
            self.build_fall_effect:setVisible(false)
        end
	end

	for i=1,3 do
		local star = self.star_list[i]
		if self.data.hp < i then
			star:setVisible(true)
		else
			star:setVisible(false)
		end
	end

	self.name_label:setString(string.format(TI18N("所属玩家：%s"), self.data.name))
	self.attk_label:setString(string.format(TI18N("战力：%d"), self.data.power))
end

function GuildwarAttkLookItem:suspendAllActions()
    if self.data ~= nil then
        if self.update_self_event ~= nil then
            self.data:UnBind(self.update_self_event)
            self.update_self_event = nil
        end
        self.data = nil
    end
end

function GuildwarAttkLookItem:DeleteMe(  )
	if self.data ~= nil then
        if self.update_self_event ~= nil then
            self.data:UnBind(self.update_self_event)
            self.update_self_event = nil
        end
        self.data = nil
    end

    if self.build_fall_effect then
        self.build_fall_effect:clearTracks()
        self.build_fall_effect:removeFromParent()
        self.build_fall_effect = nil
    end

	self:removeAllChildren()
	self:removeFromParent()
end