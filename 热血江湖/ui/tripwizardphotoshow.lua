module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_tripWizardPhotoShow = i3k_class("wnd_tripWizardPhotoShow", ui.wnd_base)
function wnd_tripWizardPhotoShow:ctor()
	self._index = 0;
	self._currPhoto = nil
end
function wnd_tripWizardPhotoShow:configure()
    local widgets = self._layout.vars
	self.icon = widgets.icon
	self.topTitle = widgets.topTitle
	self.topImage = widgets.topImage
	self.leftBtn = widgets.leftBtn
	self.rightBtn = widgets.rightBtn
	widgets.leftBtn:onClick(self, self.onLeftBtn)
	widgets.rightBtn:onClick(self, self.onRightBtn)
	widgets.cancel:onClick(self, self.onCloseUI)
end

function wnd_tripWizardPhotoShow:refresh(getType, photo, sendRoleName)
	self.leftBtn:hide();
	self.rightBtn:hide();
	if getType == g_Album or getType == g_Share then
		self.topTitle:setText(i3k_get_string(17075, sendRoleName));
	else
		self.topTitle:setText(i3k_get_string(17088));
	end

	if photo then
		self._currPhoto = photo;
	else
		self._currPhoto = g_i3k_game_context:getCurrPhotos();
	end

	if self._currPhoto and #self._currPhoto >= 1 then
		self._index = 1;
		if #self._currPhoto >= 2 then
			self.leftBtn:show();
			self.rightBtn:show();
		end
		self:SetShowImage();
		if getType == g_tripGet then
			i3k_sbean.roleWizardTripReadPhoto()
			g_i3k_game_context:clsCurrPhotos()
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "UpdateTripWizard");
		end
	end

end

function wnd_tripWizardPhotoShow:onLeftBtn(sender)
	if self._index == 1 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17073))
		return
	end
	self._index = math.max(1, self._index - 1);
	self:SetShowImage();
end

function wnd_tripWizardPhotoShow:onRightBtn(sender)
	if self._index == #self._currPhoto then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17074))
		return
	end
	self._index = math.max(1, self._index + 1);
	self:SetShowImage();
end

function wnd_tripWizardPhotoShow:SetShowImage()
	local photo = i3k_db_arder_pet_photo[self._currPhoto[self._index]];
	if photo then
		self.icon:setImage(g_i3k_db.i3k_db_get_icon_path(photo.iconId))
	end
end

function wnd_create(layout)
	local wnd = wnd_tripWizardPhotoShow.new();
		wnd:create(layout);
	return wnd;
end
