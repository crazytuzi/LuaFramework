--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-07-02 15:32:33
-- @description    : 
		-- 家园形象选择界面
---------------------------------
local _controller = HomeworldController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert

HomeworldFigureChoseWindow = HomeworldFigureChoseWindow or BaseClass(BaseView)

function HomeworldFigureChoseWindow:__init()
	self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "homeworld/homeworld_figure_chose"

	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("homeworld", "homeworld"), type = ResourcesType.plist},
	}
end

function HomeworldFigureChoseWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 2) 

	self.main_container:getChildByName("win_title"):setString(TI18N("初始形象选择"))
	self.main_container:getChildByName("txt_tips_1"):setString(TI18N("请从下列形象中选取一个形象"))
	self.main_container:getChildByName("txt_tips_2"):setString(TI18N("未被选中的形象在家园玩法后续可解锁，请放心选择"))

	self.close_btn = self.main_container:getChildByName("close_btn")
	self.btn_chose = self.main_container:getChildByName("btn_chose")
	self.btn_chose:getChildByName("label"):setString(TI18N("确认选择"))
	
	self.image_select = self.main_container:getChildByName("image_select")
	self.image_select:setVisible(true)

	self.image_left = self.main_container:getChildByName("image_left")
	self.left_name_txt = self.image_left:getChildByName("name_txt")

	self.image_right = self.main_container:getChildByName("image_right")
	self.right_name_txt = self.image_right:getChildByName("name_txt")

end

function HomeworldFigureChoseWindow:register_event(  )
	registerButtonEventListener(self.close_btn, function (  )
		_controller:openHomeworldFigureChoseWindow(false)
	end, true, 2)

	registerButtonEventListener(self.image_left, function (  )
		self:setSelectImageStatus(1)
	end, false, 1)

	registerButtonEventListener(self.image_right, function (  )
		self:setSelectImageStatus(2)
	end, false, 1)

	registerButtonEventListener(self.btn_chose, function (  )
		self:onClickChoseBtn()
	end, true)
end

function HomeworldFigureChoseWindow:onClickChoseBtn(  )
	local figure_id
	if self.cur_index == 1 and self.left_config then
		figure_id = self.left_config.id
	elseif self.cur_index == 2 and self.right_config then
		figure_id = self.right_config.id
	end
	if figure_id then
		_controller:sender26007(figure_id)
	end
end

function HomeworldFigureChoseWindow:setSelectImageStatus( index )
	if self.cur_index and self.cur_index == index then return end
	if index == 1 then
		self.image_select:setPositionX(197)
		if self.left_spine then
			self.left_spine:setToSetupPose()
			self.left_spine:setAnimation(0, PlayerAction.move, true)
		end
		if self.right_spine then
			self.right_spine:setToSetupPose()
			self.right_spine:setAnimation(0, PlayerAction.idle, true)
		end
	else
		self.image_select:setPositionX(482)
		if self.left_spine then
			self.left_spine:setToSetupPose()
			self.left_spine:setAnimation(0, PlayerAction.idle, true)
		end
		if self.right_spine then
			self.right_spine:setToSetupPose()
			self.right_spine:setAnimation(0, PlayerAction.move, true)
		end
	end
	self.cur_index = index
end

function HomeworldFigureChoseWindow:setData(  )
	if not self.left_config or not self.right_config then return end

	-- 左侧
	if self.left_config.look_id and not self.left_spine then
		self.left_spine = createEffectSpine( self.left_config.look_id, cc.p(197, 220), cc.p(0.5, 0), true, PlayerAction.idle )
		self.main_container:addChild(self.left_spine)
	end
	self.left_name_txt:setString(self.left_config.name or "")

	-- 右侧
	if self.right_config.look_id and not self.right_spine then
		self.right_spine = createEffectSpine( self.right_config.look_id, cc.p(482, 220), cc.p(0.5, 0), true, PlayerAction.idle )
		self.main_container:addChild(self.right_spine)
	end
	self.right_name_txt:setString(self.right_config.name or "")

	self:setSelectImageStatus(1)
end

function HomeworldFigureChoseWindow:openRootWnd(  )
	-- test 配置为常量
	self.left_config = Config.HomeData.data_figure[1]
	self.right_config = Config.HomeData.data_figure[2]
	
	self:setData()
end

function HomeworldFigureChoseWindow:close_callback(  )
	if self.left_spine then
        self.left_spine:clearTracks()
        self.left_spine:removeFromParent()
        self.left_spine = nil
    end
    if self.right_spine then
        self.right_spine:clearTracks()
        self.right_spine:removeFromParent()
        self.right_spine = nil
    end
	_controller:openHomeworldFigureChoseWindow(false)
end