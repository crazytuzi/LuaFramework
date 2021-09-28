-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_xr = i3k_class("wnd_xr", ui.wnd_base)

--邪派名字颜色
local EVIL_COLOUR = "FFF13010"
--正派名字颜色
local JUSE_COLOUR = "FFBB8400"
--中立名字颜色
local NORMAL_COLOUR = "FF23C3FF"

local USER_NEW_ROLE_CREATE_REQ_EXISTING_MAX_LVL = {0, 0, 0, 0, 80, 90}--, 70, 80

function wnd_xr:ctor()
	self._select_img = {}
	self._auto_img = {}
	self._aoto_id = 0
end

function wnd_xr:configure(layout)
	local btnPlay = self._layout.vars.btnPlay
	btnPlay:onTouchEvent(self, self.onPlay)
	self.lstChars = self._layout.vars.lstChars;

	self._selectChar = -1
end

function wnd_xr:onShow()
end

function wnd_xr:refresh()
	self:updateData()
end

function wnd_xr:updateData()
	if not g_i3k_game_context then return; end

	local roleInfo = g_i3k_game_context:GetRoleList()
	local index = 0
	local cfg = g_i3k_game_context:GetUserCfg()
	local maxLvl = 0
	for k, v in ipairs(roleInfo) do
		index = index + 1

		local item = require("ui/widgets/xjs2t")()

		local labName = item.vars.labName;
		labName:setText(v._name)
		local typeLabel = item.vars.typeLabel
		if v._bwType == 0 then
			typeLabel:setTextColor(NORMAL_COLOUR)
			typeLabel:setText("中立")
		elseif v._bwType == 1 then
			typeLabel:setTextColor(JUSE_COLOUR)
			typeLabel:setText("正派")
		elseif v._bwType == 2 then
			typeLabel:setTextColor(EVIL_COLOUR)
			typeLabel:setText("邪派")
		end
		local labLvl = item.vars.labLvl
		local temp_str = string.format("%s级",v._level)
		maxLvl = v._level > maxLvl and v._level or maxLvl

		labLvl:setText(temp_str)
		item.vars.headBg:setImage(g_i3k_get_head_bg_path(v._bwType, v._headBorder))

		local selectImg = item.vars.selectImg
		local imgPlayer = item.vars.imgPlayer
		local selectBtn = item.vars.selectBtn
		local typeLabel = item.vars.typeLabel
		local last_role = cfg:GetSelectRole()
		if index == cfg:GetSelectRole() then
			selectImg:show()
			self._selectChar = cfg:GetSelectRole()
			imgPlayer:hide()
			self._aoto_id = index
		end
		self._select_img[index] = selectImg

		self._auto_img[index] = imgPlayer

		selectBtn:onClick(self, self.onSelectChar,index)
		self.lstChars:addItem(item);


		local head = item.vars.head;
		local hicon = g_i3k_db.i3k_db_get_head_icon(v._gender, v._face or 0, v._hair or 0, g_i3k_db.eHeadShapeCircie);
		if hicon and hicon > 0 then
			head:setImage(g_i3k_db.i3k_db_get_icon_path(hicon));
		end
		local imgClass = item.vars.imgClass;
		imgClass:setImage(g_i3k_db.i3k_db_get_general_class_icon(v._type));
	end
	if index == 0 then
		local btnPlay = self._layout.vars.btnPlay
		btnPlay:hide()
	end

	local nextNewRoleMaxLvl = USER_NEW_ROLE_CREATE_REQ_EXISTING_MAX_LVL[ #roleInfo + 1 ]
	if nextNewRoleMaxLvl then
		local item = require("ui/widgets/xjst")();
		local btnCreate = item.vars.btnCreate;
		btnCreate:onTouchEvent(self, self.onCreateChar, {maxLvl = maxLvl, nextNewRoleMaxLvl = nextNewRoleMaxLvl})
		self.lstChars:addItem(item)
	end

end

function wnd_xr:autoRole()
	if self._aoto_id ~= 0 and self.onSelectCharacter then
		self.onSelectCharacter(self._aoto_id)
	end
end

function wnd_xr:onHide()
end

function wnd_xr:updateImagState()
	for k,v in ipairs(self._select_img) do
		v:hide()
	end
end

function wnd_xr:updateAutoImagState()
	for k,v in ipairs(self._auto_img) do
		v:show()
	end
end

function wnd_xr:onSelectChar(sender, index)
	self._selectChar = index
	if self.onSelectCharacter then
		self.onSelectCharacter(index)
		self:updateImagState()
		self:updateAutoImagState()
		self._select_img[index]:show()
		self._auto_img[index]:hide()
		local cfg = g_i3k_game_context:GetUserCfg()
		if cfg then
			cfg:SetSelectRole(index)
		end
	end
end

-- InvokeUIFunction
function wnd_xr:createChar()
	if self.onCreateCharacter then
		self.onCreateCharacter();
	end
end

function wnd_xr:onCreateChar(sender, eventType, args)
	if eventType == ccui.TouchEventType.ended then
		if args.maxLvl < args.nextNewRoleMaxLvl then
			return g_i3k_ui_mgr:PopupTipMessage(string.format("任意一个角色达到%s级开启", args.nextNewRoleMaxLvl))
		end
		self:createChar()
	end
end

function wnd_xr:onPlay(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		if self.onPlayGame and self._selectChar > 0 then
			self.onPlayGame(self._selectChar);
		end
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_xr.new();
		wnd:create(layout, ...);

	return wnd;
end
