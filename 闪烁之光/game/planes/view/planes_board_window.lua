---------------------------------
-- @Author: htp
-- @Editor: htp
-- @date 2019/12/09 14:36:26
-- @description: 位面 广告牌
---------------------------------
local _controller = PlanesController:getInstance()
local _model = _controller:getModel()
local _string_format = string.format

PlanesBoardWindow = PlanesBoardWindow or BaseClass(BaseView)

function PlanesBoardWindow:__init()
	self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "planes/planes_board_window"

    self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("planes", "planes_map"), type = ResourcesType.plist},
	}
end

function PlanesBoardWindow:open_callback( )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local main_container = self.root_wnd:getChildByName("main_container")
	self.main_container = main_container

	self.win_title = main_container:getChildByName("win_title")
	self.btn_comfirm = main_container:getChildByName("btn_comfirm")
	self.btn_comfirm_label = self.btn_comfirm:getChildByName("label")

	self.board_sp = main_container:getChildByName("board_sp")
	self.title_txt = main_container:getChildByName("title_txt") -- 标题

	self.main_con_size = main_container:getContentSize()
end

function PlanesBoardWindow:register_event( )
	registerButtonEventListener(self.background, handler(self, self.onClickCloseBtn), false, 2)
	registerButtonEventListener(self.btn_comfirm, handler(self, self.onClickComfirmBtn), true)
end

function PlanesBoardWindow:onClickCloseBtn(  )
	_controller:openPlanesBoardWindow(false)
end

function PlanesBoardWindow:onClickComfirmBtn(  )
	if not self.board_id or not self.grid_index then return end
	if self.board_show_type == 2 then return end --年兽活动没有 此事件
	-- 告示牌和升降台无需操作
	if self.board_id == PlanesConst.Recover_Id or self.board_id == PlanesConst.Revive_Id or self.board_id == PlanesConst.Switch_Id or self.board_id == PlanesConst.DesBarrier_Id then
		if self.board_id == PlanesConst.Recover_Id and not _model:checkIsHaveHpNotFullHero() then -- 回复泉水时，所有英雄都是满血
			CommonAlert.show(TI18N("当前所有非阵亡英雄均满血，使用回复泉水将不会有效，是否继续？"), TI18N("确认"), function (  )
				_controller:sender23104( self.grid_index, 1, {} )
			end, TI18N("取消"))
		elseif self.board_id == PlanesConst.Revive_Id and not _model:checkIsHaveDieHero() then -- 复活时，没有死亡的英雄
			CommonAlert.show(TI18N("当前无阵亡英雄且存活的英雄均满血，使用复活十字架将不会有效，是否继续？"), TI18N("确认"), function (  )
				_controller:sender23104( self.grid_index, 1, {} )
			end, TI18N("取消"))
		else
			_controller:sender23104( self.grid_index, 1, {} )
		end
	end
	_controller:openPlanesBoardWindow(false)
end

function PlanesBoardWindow:openRootWnd( id, index , setting)
	self.board_id = id
	self.grid_index = index
	setting = setting or {}
	--广告显示类型: 1 位面的  2 年兽活动
	self.board_show_type = setting.show_type or 1
	self.board_cfg = setting.board_cfg

	self:setData(id, board_cfg)
end

function PlanesBoardWindow:setData( id, board_cfg)
	if not id then return end
	local board_cfg 
	if self.board_show_type == 2 then
		board_cfg = self.board_cfg
	else
		board_cfg = Config.SecretDunData.data_board[id]
	end
	if not board_cfg then return end

	-- 按钮
	if board_cfg.btn_str ~= "" then
		self.btn_comfirm:setVisible(true)
		self.btn_comfirm_label:setString(board_cfg.btn_str)
	else
		self.btn_comfirm:setVisible(false)
	end

	-- 标题
	self.win_title:setString(board_cfg.title)

	-- 图片
	if self.board_show_type == 2 then
		local board_res = _string_format("resource/planes/board_img/%s.png", board_cfg.res_id)
		self.board_img_load = loadSpriteTextureFromCDN(self.board_sp, board_res, ResourcesType.single, self.board_img_load)
	else
		local board_res = _string_format("resource/planes/board_img/%s.png", board_cfg.res_id)
		self.board_img_load = loadSpriteTextureFromCDN(self.board_sp, board_res, ResourcesType.single, self.board_img_load)
	end

	-- 标题
	self.title_txt:setString(board_cfg.title)

	-- 描述内容一
	if not self.desc_txt_1 then
		self.desc_txt_1 = createRichLabel(24, cc.c4b(149, 83, 34, 255), cc.p(0.5, 1), cc.p(self.main_con_size.width*0.5, 420), 0, 0, self.main_con_size.width - 100)
		self.main_container:addChild(self.desc_txt_1)
	end
	self.desc_txt_1:setString(board_cfg.desc_1)

	-- 描述内容二
	if not self.desc_txt_2 then
		self.desc_txt_2 = createRichLabel(24, cc.c4b(149, 83, 34, 255), cc.p(0.5, 1), cc.p(self.main_con_size.width*0.5, 0), 0, 0, self.main_con_size.width - 100)
		self.main_container:addChild(self.desc_txt_2)
	end
	self.desc_txt_2:setString(board_cfg.desc_2)
	local desc_txt_size = self.desc_txt_1:getContentSize()
	self.desc_txt_2:setPositionY(420 - desc_txt_size.height - 50)
end

function PlanesBoardWindow:close_callback( )
	if self.board_img_load then
		self.board_img_load:DeleteMe()
		self.board_img_load = nil
	end
	_controller:openPlanesBoardWindow(false)
end