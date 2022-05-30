-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      每层结算展示
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
AdventureFloorResultWindow = AdventureFloorResultWindow or BaseClass(BaseView) 

local controller = AdventureController:getInstance()
local model = AdventureController:getInstance():getUiModel()

function AdventureFloorResultWindow:__init()
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.win_type = WinType.Tips
	self.layout_name = "adventure/adventure_floor_result_window"
	self.is_csb_action = true
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("levupgrade", "levupgrade"), type = ResourcesType.plist},
	}
end

function AdventureFloorResultWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
	self.background:setScale(display.getMaxScale())

	self.main_container = self.root_wnd:getChildByName("main_container")
    -- self:playEnterAnimatianByObj(self.main_container, 2)
	self.title_container = self.main_container:getChildByName("title_container")
    self.title_width = self.title_container:getContentSize().width
    self.title_height = self.title_container:getContentSize().height

    self.list_view = self.root_wnd:getChildByName("list_view")
	local size = self.list_view:getContentSize()
	local setting = {
		item_class = AdventureFloorResultItem,
		start_x = 0,
		space_x = 0,
		start_y = 8,
		space_y = 12,
		item_width = 720,
		item_height = 43,
		row = 0,
		col = 1,
		need_dynamic = true
	}
	self.scroll_view = CommonScrollViewLayout.new(self.list_view, nil, nil, nil, size, setting)

    self.item = self.root_wnd:getChildByName("item")
end

function AdventureFloorResultWindow:register_event()
	registerButtonEventListener(self.background, function() 
		controller:openAdventureFloorResultWindow(false)
	end, false, 1)
end

function AdventureFloorResultWindow:openRootWnd(data)
    playOtherSound("c_get") 
	self:handleEffect(true)

	local item_list = data.items_list
	if item_list then
		table.sort(item_list, function(a, b) 
			return a.num > b.num
		end)
	end
	self.scroll_view:setData(item_list, nil, nil, self.item)
end

function AdventureFloorResultWindow:handleEffect(status)
	if status == false then
		if self.play_effect then
			self.play_effect:clearTracks()
			self.play_effect:removeFromParent()
			self.play_effect = nil
		end
	else
		local effect_id = 274
		local action = PlayerAction.action_4
		if not tolua.isnull(self.title_container) and self.play_effect == nil then
			self.play_effect = createEffectSpine(PathTool.getEffectRes(effect_id), cc.p(self.title_width * 0.5, self.title_height * 0.5), cc.p(0.5, 0.5), false, action)
			self.title_container:addChild(self.play_effect, 1)
		end
	end
end 

function AdventureFloorResultWindow:close_callback()
	if self.scroll_view then
		self.scroll_view:DeleteMe()
	end
	self.scroll_view  = nil
	controller:openAdventureFloorResultWindow(false)
end



-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      收益物品展示
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
AdventureFloorResultItem = class("AdventureFloorResultItem", function()
	return ccui.Layout:create()
end)

function AdventureFloorResultItem:ctor()
	self.is_completed = false
end

function AdventureFloorResultItem:setExtendData(node)
	if not tolua.isnull(node) and self.root_wnd == nil then
		self.is_completed = true
		local size = node:getContentSize()
		self:setAnchorPoint(cc.p(0.5, 0.5))
		self:setContentSize(size)

		self.root_wnd = node:clone()
		self.root_wnd:setVisible(true)
		self.root_wnd:setAnchorPoint(0.5, 0.5)
		self.root_wnd:setPosition(size.width * 0.5, size.height * 0.5) 
		self.root_wnd:setCascadeOpacityEnabled(true)
		self:addChild(self.root_wnd)

		self.init_pos_y = self.root_wnd:getPositionY()

		self.item_name = self.root_wnd:getChildByName("item_name")

		self.item_num = self.root_wnd:getChildByName("item_num")

		self:playEnterActions()
	end
end

function AdventureFloorResultItem:playEnterActions()
	self.root_wnd:setPositionX(200)
	self.root_wnd:setOpacity(0)

	local move_to = cc.MoveTo:create(0.2, cc.p(460, self.init_pos_y))
	local fade_in = cc.FadeIn:create(0.2)
	local move_to_1 = cc.MoveTo:create(0.1, cc.p(360, self.init_pos_y))

	self.root_wnd:runAction(cc.Sequence:create(cc.Spawn:create(move_to,fade_in), move_to_1))
end

function AdventureFloorResultItem:setData(data)
	self.data = data
	if data then
		local item_config = Config.ItemData.data_get_data(data.bid)
		if item_config then
			if self.item_icon == nil then 
				self.item_icon = createSprite(nil, 164, 22, self.root_wnd, cc.p(0.5,0.5))
				self.item_icon:setScale(0.4)
			end
			if self.item_icon_res ~= item_config.icon then
				self.item_icon_res = item_config.icon
				loadSpriteTexture(self.item_icon, PathTool.getItemRes(item_config.icon), LOADTEXT_TYPE)
			end
			self.item_name:setString(item_config.name)
			self.item_num:setString(data.num)
		end
	end
end

function AdventureFloorResultItem:DeleteMe()
	self:removeAllChildren()
	self:removeFromParent()
end 