--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2018-11-01 17:46:54
-- @description    : 
		-- 天梯主界面单个宝可梦
---------------------------------
LadderRoleItem = class("LadderRoleItem", function()
    return ccui.Widget:create()
end)

LadderRoleItem.Width = 243
LadderRoleItem.Height = 280

local controller = LadderController:getInstance()
local model = controller:getModel()

function LadderRoleItem:ctor()
	self:configUI()
	self:register_event()
end

function LadderRoleItem:configUI(  )
	self.size = cc.size(LadderRoleItem.Width, LadderRoleItem.Height)
	self:setContentSize(self.size)
	self:setAnchorPoint(cc.p(0.5, 0))

	local csbPath = PathTool.getTargetCSB("ladder/ladder_role_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

	local container = self.root_wnd:getChildByName("container")
	self.container = container
	self.touch_layer = container:getChildByName("touch_layer")

	self.image_line = container:getChildByName("image_line")
	self.rank_label = container:getChildByName("rank_label")
	self.name_label = container:getChildByName("name_label")
	self.attk_label = container:getChildByName("attk_label")
	self.atk_icon = container:getChildByName("atk_icon")
	self.pos_role = container:getChildByName("pos_role")
	self.attk_image = container:getChildByName("attk_image")
	self.rank_bg = container:getChildByName("rank_bg")
end

function LadderRoleItem:register_event(  )
	registerButtonEventListener(self.touch_layer, handler(self, self._onClickBtnContainer))
end

function LadderRoleItem:_onClickBtnContainer(  )
	local is_open = model:getLadderIsOpen()
	if is_open then
		controller:openLadderRoleInfoWindow(true, self.data)
	else
		local txt_cfg = Config.SkyLadderData.data_const["close_text"]
		if txt_cfg then
			message(string.format(TI18N("每%s天梯争霸"), txt_cfg.desc))
		end
	end
end

function LadderRoleItem:setData( data )
	self.data = data or {}

	local is_open = model:getLadderIsOpen()
	if not data.rank or data.rank == 0 then
		self.rank_label:setFontSize(20)
		self.rank_label:setString(TI18N("未上榜"))
	else
		self.rank_label:setFontSize(20)
		self.rank_label:setString(string.format(TI18N("第%d名"), data.rank))
	end
	local rank_size = self.rank_label:getContentSize()
	self.rank_bg:setCapInsets(cc.rect(40, 0, 2, 30))
	self.rank_bg:setContentSize(cc.size(rank_size.width+15, 30))

	if is_open then
		self.name_label:setString(transformNameByServ(data.name, data.srv_id))
		self.attk_label:setString(changeBtValueForPower(data.power or 0))
		local label_size = self.attk_label:getContentSize()
		self.attk_image:setVisible(true)
		self.atk_icon:setVisible(true)
		self.atk_icon:setPositionX(121-label_size.width/2)
	else
		self.name_label:setString(TI18N("虚位以待"))
		local txt_cfg = Config.SkyLadderData.data_const["close_text"]
		if txt_cfg then
			self.attk_label:setString(txt_cfg.desc)
		end
		self.attk_image:setVisible(false)
		self.atk_icon:setVisible(false)
	end

	if self.role_spine then
		self.role_spine:DeleteMe()
		self.role_spine = nil
	end
	if data.look then
		self.role_spine = BaseRole.new(BaseRole.type.role, data.look)
	    self.role_spine:setCascade(true)
	    self.role_spine:setAnchorPoint(cc.p(0.5, 0))
	    self.role_spine:setPosition(cc.p(0, 110))
	    self.role_spine:setScale(0.7)
	    self.role_spine:setAnimation(0,PlayerAction.show,true)
	    self.pos_role:addChild(self.role_spine)
	end

	-- 设置底框
	local res_path = self:getRoleBoxResPath(data.rank)
	if res_path then
		self.image_line:loadTexture(res_path, LOADTEXT_TYPE_PLIST)
		--self.image_line:setVisible(true)
		self.image_line:setVisible(false)--因为资源是旧的，暂时先隐藏段位
	else
		self.image_line:setVisible(false)
	end
end

function LadderRoleItem:getRoleBoxResPath( rank )
	local res_path
	local box_config = Config.SkyLadderData.data_const.role_box
	local index = 0
	if box_config and box_config.val then
		for k,v in pairs(box_config.val) do
			if rank >= v[1] and (rank <= v[2] or v[2] == 0) then
				index = k
			end
		end
	end
	if index == 1 then
		res_path = PathTool.getResFrame("ladder", "ladder_1019")
	elseif index == 2 then
		res_path = PathTool.getResFrame("ladder", "ladder_1018")
	elseif index == 3 then
		res_path = PathTool.getResFrame("ladder", "ladder_1017")
	elseif index == 4 then
		res_path = PathTool.getResFrame("ladder", "ladder_1016")
	end

	return res_path
end

function LadderRoleItem:DeleteMe(  )
	if self.role_spine then
		self.role_spine:DeleteMe()
		self.role_spine = nil
	end
end