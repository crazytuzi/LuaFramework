---------------------------------
-- @Author: htp
-- @Editor: htp
-- @date 2019/12/11 10:22:35
-- @description: 位面 buff遗物选择界面
---------------------------------
local _controller = PlanesController:getInstance()
local _model = _controller:getModel()

PlanesBuffChoseWindow = PlanesBuffChoseWindow or BaseClass(BaseView)

function PlanesBuffChoseWindow:__init()
	self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "planes/planes_buff_chose"

    self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("planes", "planes_buff"), type = ResourcesType.plist},
	}

	self.buff_item_list = {}
end

function PlanesBuffChoseWindow:open_callback( )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local main_container = self.root_wnd:getChildByName("main_container")
	self.main_container = main_container

	local txt_list = {
        {"tips_txt", "请选择需要的遗物"},
	}
	setTextContentList(main_container, txt_list)

	self.btn_chose = main_container:getChildByName("btn_chose")
	self.btn_chose:getChildByName("label"):setString(TI18N("确认选择"))
	self.btn_chose:setVisible(false)
end

function PlanesBuffChoseWindow:register_event( )
	registerButtonEventListener(self.background, handler(self, self.onClickCloseBtn), false, 2)
	registerButtonEventListener(self.btn_chose, handler(self, self.onClickChoseBtn), true)
end

function PlanesBuffChoseWindow:onClickCloseBtn(  )
	_controller:openPlanesBuffChoseWindow(false)
end

function PlanesBuffChoseWindow:onClickChoseBtn(  )
	if self.cur_buff_item and self.grid_index then
		local buff_id = self.cur_buff_item:getBuffId()
		local extend = {}
		extend.buff_id = buff_id
		extend.world_pos = self.cur_buff_item:convertToWorldSpace(cc.p(0, 0))
		extend.index = self.grid_index
		_controller:sender23104( self.grid_index, 1, {{type=PlanesConst.Proto_23104._9, val1=buff_id, val2 = 0}}, extend )
	end
end

function PlanesBuffChoseWindow:openRootWnd( buff_list, grid_index )
	self.grid_index = grid_index
	self:setData(buff_list)
end

function PlanesBuffChoseWindow:setData( buff_list )
	if not buff_list or next(buff_list) == nil then return end

	local main_con_size = self.main_container:getContentSize()
	local space_x = 20
	local item_width = 200
	local start_x = main_con_size.width*0.5 - (item_width+space_x)
	for i,buff_id in ipairs(buff_list) do
		local buff_cfg = Config.SecretDunData.data_buff[buff_id]
		if buff_cfg then
			local buff_item = self.buff_item_list[i]
			if not buff_item then
				buff_item = PlanesBuffItem.new(handler(self, self.onClickCallBack))
				self.main_container:addChild(buff_item)
				self.buff_item_list[i] = buff_item
			end
			buff_item:setData(buff_cfg)
			buff_item:setPosition(start_x+(i-1)*(item_width+space_x), 290)
		end
	end
end

-- 点击了某一buff
function PlanesBuffChoseWindow:onClickCallBack( item )
	if self.cur_buff_item then
		self.cur_buff_item:setIsSelect(false)
	end
	item:setIsSelect(true)
	self.cur_buff_item = item
	local pos_x = item:getPositionX()
	self.btn_chose:setPositionX(pos_x)
	self.btn_chose:setVisible(true)
end

function PlanesBuffChoseWindow:close_callback( )
	for k,item in pairs(self.buff_item_list) do
		item:DeleteMe()
		item = nil
	end
	_controller:openPlanesBuffChoseWindow(false)
end