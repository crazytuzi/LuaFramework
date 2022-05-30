--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2018-11-28 21:36:01
-- @description    : 
		-- 失落神器（所有神器预览界面）
---------------------------------
HallowsPreviewWindow = HallowsPreviewWindow or BaseClass(BaseView)

local controller = HallowsController:getInstance()
local model = HallowsController:getInstance():getModel()

function HallowsPreviewWindow:__init()
    self.is_full_screen = true
	self.win_type = WinType.Full
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("hallows", "hallows"), type = ResourcesType.plist},
		{path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_69", true), type = ResourcesType.single},
		{path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_70"), type = ResourcesType.single}
	}
	self.layout_name = "hallows/hallows_preview_window"

	self.hallows_list = {}
	self.pos_nodes = {}
end

function HallowsPreviewWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	self.background:loadTexture(PathTool.getPlistImgForDownLoad("bigbg","bigbg_69",true), LOADTEXT_TYPE)
	self.background:setScale(display.getMaxScale())

	local main_panel = self.root_wnd:getChildByName("main_panel")
	self:playEnterAnimatianByObj(main_panel, 1)
	self.main_panel = main_panel

	local title_layout = main_panel:getChildByName("title_layout")

	self.close_btn = main_panel:getChildByName("close_btn")

	-- 适配
	local top_off = display.getTop(main_panel)
	title_layout:setPositionY(top_off - 150)
	local bottom_off = display.getBottom(main_panel)
	self.close_btn:setPositionY(bottom_off + 150)
end

function HallowsPreviewWindow:refreshView(  )
	local hallows_num = Config.HallowsData.data_base_length

	for i=1,hallows_num do
		local pos_node = self.main_panel:getChildByName("pos_node_" .. i)
		if pos_node then
			self.pos_nodes[i] = pos_node
			delayRun(pos_node, i*3/60, function (  )
				local hallows_item = self.hallows_list[i]
				if hallows_item == nil then
					hallows_item = HallowsPreviewItem.new()
					pos_node:addChild(hallows_item)
					self.hallows_list[i] = hallows_item
				end
				local config = Config.HallowsData.data_base[i] or {}
				hallows_item:setData(config)
			end)
		end
	end
end

function HallowsPreviewWindow:register_event(  )
	registerButtonEventListener(self.close_btn, handler(self, self._onClickCloseBtn), nil, 2)
end

function HallowsPreviewWindow:_onClickCloseBtn(  )
	controller:openHallowsPreviewWindow(false)
end

function HallowsPreviewWindow:openRootWnd(  )
	self:refreshView()
end

function HallowsPreviewWindow:close_callback(  )
	for k,node in pairs(self.pos_nodes) do
		node:stopAllActions()
	end
	for k,item in pairs(self.hallows_list) do
		item:DeleteMe()
		item = nil
	end
	controller:openHallowsPreviewWindow(false)
end

-----------------------@ item
HallowsPreviewItem = class("HallowsPreviewItem", function()
    return ccui.Widget:create()
end)

function HallowsPreviewItem:ctor()
	self.hallows_status = HallowsConst.Status.close
    self:configUI()
    self:register_event()
end

function HallowsPreviewItem:configUI(  )
	self.size = cc.size(250, 250)
    self:setTouchEnabled(false)
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setContentSize(self.size)

    local csbPath = PathTool.getTargetCSB("hallows/hallows_preview_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    local container = self.root_wnd:getChildByName("container")
    self.container = container

    self.hallows_pos_node = container:getChildByName("hallows_pos_node")
	self.hallows_pos_sp = container:getChildByName("hallows_pos_sp")
    self.name_label = container:getChildByName("name_label")
    self.hallows_bg = container:getChildByName("bg")
end

function HallowsPreviewItem:setData( data )
	self.data = data

	local hallows_id = data.id
	-- 引导需要
	self.container:setName("hallows_"..hallows_id)

	self.name_label:setString(data.name)

	local action = PlayerAction.action_2
	if self.hallows_model then
		self.hallows_model:removeFromParent()
		self.hallows_model = nil
	end
	self.hallows_model = createEffectSpine(data.effect, cc.p(0, -100), cc.p(0.5,0.5), true, action)
	self.hallows_model:setScale(0.65)
	self.hallows_pos_node:addChild(self.hallows_model)
	--改为图片显示
	loadSpriteTexture(self.hallows_pos_sp, "resource/hallows/trainer_"..hallows_id..".png", LOADTEXT_TYPE)
	local cur_hallows_id = model:getCurActivityHallowsId() -- 当前进行中的神器id
	if cur_hallows_id == hallows_id then
		self.hallows_status = HallowsConst.Status.underway
		setChildUnEnabled(true, self.hallows_model)
		self.hallows_model:setAnimation(0, PlayerAction.action_1, true)
		self:handleEffect(true)
		--改为图片显示
		setChildUnEnabled(true, self.hallows_pos_sp)
	elseif model:getHallowsById(hallows_id) then
		self.hallows_status = HallowsConst.Status.open
		setChildUnEnabled(false, self.hallows_model)
		self.hallows_model:setAnimation(0, PlayerAction.action_2, true)
		--改为图片显示
		setChildUnEnabled(false, self.hallows_pos_sp)
	else
		self.hallows_status = HallowsConst.Status.close
		setChildUnEnabled(true, self.hallows_model)
		self.hallows_model:setAnimation(0, PlayerAction.action_1, true)
		--改为图片显示
		setChildUnEnabled(true, self.hallows_pos_sp)
	end
end

function HallowsPreviewItem:handleEffect(status)
    if status == false then
		if self.play_effect then
			self.play_effect:clearTracks()
			self.play_effect:removeFromParent()
			self.play_effect = nil
		end
		if self.hallows_model then
			self.hallows_model:clearTracks()
			self.hallows_model:removeFromParent()
			self.hallows_model = nil
		end
    else
        if not tolua.isnull(self.hallows_bg) and self.play_effect == nil then
            self.play_effect = createEffectSpine(Config.EffectData.data_effect_info[546], cc.p(133, 133), cc.p(0.5, 0.5), true, PlayerAction.action)
            self.play_effect:setScale(1.8)
			--self.hallows_bg:addChild(self.play_effect)
			self.hallows_pos_sp:addChild(self.play_effect)
        elseif self.play_effect then
        	self.play_effect:setAnimation(0, PlayerAction.action, true)
        end
    end
end

function HallowsPreviewItem:register_event(  )
	registerButtonEventListener(self.container, handler(self, self._onClickContainer))
end

function HallowsPreviewItem:_onClickContainer(  )
	if self.hallows_status == HallowsConst.Status.close then
		message(TI18N("解锁上一神器后开启"))
	else
		-- 判断一下神器界面是否正在显示，没显示则打开它
		if controller:getHallowsRoot() then
			GlobalEvent:getInstance():Fire(HallowsEvent.UndateHallowsInfoEvent, self.data.id)
		else
			controller:openHallowsMainWindow(true, self.data.id)
		end
		controller:openHallowsPreviewWindow(false)
	end
end

function HallowsPreviewItem:DeleteMe(  )
	self:handleEffect(false)
	self:removeAllChildren()
    self:removeFromParent()
end