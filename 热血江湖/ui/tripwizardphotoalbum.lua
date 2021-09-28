module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_tripWizardPhotoAlbum = i3k_class("wnd_tripWizardPhotoAlbum", ui.wnd_base)
local Album = "ui/widgets/xiangcet"
local headBtn = "ui/widgets/xiangcet2"
local AMOUNT = 12                      --每面图片数量
function wnd_tripWizardPhotoAlbum:ctor()
	self._checkedPhoto = {};
	self._wizardId = nil;
	self._ownPhotos = {}
	self._curPage = 1;
	self._maxPage = 1;
end
function wnd_tripWizardPhotoAlbum:configure()
    local widgets = self._layout.vars
	self.photoScroll = widgets.photoScroll
	self.photoScroll2 = widgets.photoScroll2
	self.headScroll = widgets.headScroll
	self.label = widgets.label
	widgets.shareBtn:onClick(self, self.onShareBtn)
	widgets.cancel:onClick(self, self.onCloseUI)
end

function wnd_tripWizardPhotoAlbum:refresh()
	self.photoScroll:setBounceEnabled(false)
	self.photoScroll2:setBounceEnabled(false)
	self:updatePhotoScroll()
	self._layout.vars.forward:onClick(self, self.onForward)
	self._layout.vars.backward:onClick(self, self.onBackward)
	self._layout.vars.pageNum:setText(self._curPage .. "/" .."3")
end

function wnd_tripWizardPhotoAlbum:updatePhotoScroll()
	self.headScroll:removeAllChildren()
	self.label:hide()
	local photo = {}
	local firstFlag = true
	local ownPhotos = g_i3k_game_context:getTripWizardOwnPhotos()
	for k,v in pairs(ownPhotos) do
		table.insert(photo,  v);
	end
	self.headScroll:setAlignMode(g_UIScrollList_HORZ_ALIGN_LEFT)
	self.headScroll:setBounceEnabled(false)
	for i,e in ipairs(photo) do
		local head = require(headBtn)()
		local pet = i3k_db_arder_pet[e.wizardId];
		head.vars.name:setText(pet.name)
		head.vars.btn:onClick(self, self.onHeadBtn, {wizardId = e.wizardId, index = i});
		if firstFlag then
			head.vars.btn:stateToPressed()
			self:updateScroll(e.wizardId);
			firstFlag = false
		end
		self.headScroll:addItem(head);
	end
	if #photo == 0 then
		self.label:show():setText(i3k_get_string(17080));
	end
end

function wnd_tripWizardPhotoAlbum:updateScroll(wizardId)
	self.label:hide()
	self._wizardId = wizardId;
	self._checkedPhoto = {}
	self._ownPhotos = {}
	self.photoScroll:removeAllChildren()
	self.photoScroll2:removeAllChildren()
	local photo = {};
	local ownPhotos = g_i3k_game_context:getTripWizardOwnPhotos()
	if ownPhotos and ownPhotos[wizardId] then
		for k,v in pairs(ownPhotos[wizardId].photos) do
			table.insert(photo,  { propID = k});
		end
		self:Sort(photo);
		self._ownPhotos = photo;

		if math.ceil(table.nums(photo)/AMOUNT) > 0 then
			self._maxPage = math.ceil(table.nums(photo)/AMOUNT);
		else
			self._maxPage = 1;
		end

		local children = self.photoScroll:addChildWithCount(Album, 2, math.min(#photo - (self._curPage - 1)*AMOUNT, AMOUNT/2));
		--for i,e in ipairs(photo) do
		--	local photo = i3k_db_arder_pet_photo[e.propID];
		--	children[i].vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(photo.iconId))
		--	children[i].vars.markBtn:onClick(self, self.onMarkBtn, {photoIndex = i, photoId = e.propID});
		--	children[i].vars.btn:onClick(self, self.onClickBtn, e.propID);
		--	children[i].vars.mark:hide()
		--end

		for i,e in ipairs(children) do
			local cfg = i3k_db_arder_pet_photo[photo[i + (self._curPage - 1)*AMOUNT].propID];
			e.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.iconId));
			e.vars.markBtn:onClick(self, self.onMarkBtn, {photoIndex = i + (self._curPage - 1)*AMOUNT, photoId = photo[i + (self._curPage - 1)*AMOUNT].propID});
			e.vars.btn:onClick(self, self.onClickBtn, photo[i + (self._curPage - 1)*AMOUNT].propID);
			e.vars.mark:hide();
		end

		local children2 = self.photoScroll2:addChildWithCount(Album, 2, math.min(#photo - (self._curPage - 1 + 0.5)*AMOUNT, AMOUNT/2));
		for i,e in ipairs(children2) do
			local cfg = i3k_db_arder_pet_photo[photo[i + (self._curPage - 1 + 0.5)*AMOUNT].propID];
			e.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.iconId));
			e.vars.markBtn:onClick(self, self.onMarkBtn, {photoIndex = i + (self._curPage - 1 + 0.5)*AMOUNT, photoId = photo[i + (self._curPage - 1 + 0.5)*AMOUNT].propID});
			e.vars.btn:onClick(self, self.onClickBtn, photo[i + (self._curPage - 1 + 0.5)*AMOUNT].propID);
			e.vars.mark:hide();
		end

	end
end

function wnd_tripWizardPhotoAlbum:Sort(tbl)
	local _cmp = function(d1, d2)
		return d1.propID < d2.propID;
	end
	table.sort(tbl, _cmp);
end

function wnd_tripWizardPhotoAlbum:onHeadBtn(sender, arg)
	local child = self.headScroll:getAllChildren(arg.index)
	if child then
		for i,e in ipairs(child) do
			if i == arg.index  then
				e.vars.btn:stateToPressed()
			else
				e.vars.btn:stateToNormal(true)
			end
		end
	end
	if self._wizardId ~= arg.wizardId then
		self._curPage = 1;
		self:updateScroll(arg.wizardId);
	end
end

function wnd_tripWizardPhotoAlbum:onMarkBtn(sender, arg)
	if arg.photoIndex - (self._curPage - 1)*AMOUNT <= AMOUNT/2 then
		local children = self.photoScroll:getAllChildren();
		if children and children[arg.photoIndex - (self._curPage - 1)*AMOUNT].vars then
			if children[arg.photoIndex - (self._curPage - 1)*AMOUNT].vars.mark:isVisible() then
				table.remove(self._checkedPhoto,  arg.photoIndex);
				children[arg.photoIndex - (self._curPage - 1)*AMOUNT].vars.mark:hide();
			else
				table.insert(self._checkedPhoto,  arg.photoId);
				children[arg.photoIndex - (self._curPage - 1)*AMOUNT].vars.mark:show();
			end
		end
	else
		local children2 = self.photoScroll2:getAllChildren();
		if children2 and children2[arg.photoIndex - (self._curPage - 1 + 0.5)*AMOUNT].vars then
			if children2[arg.photoIndex - (self._curPage - 1 + 0.5)*AMOUNT].vars.mark:isVisible() then
				table.remove(self._checkedPhoto,  arg.photoIndex);
				children2[arg.photoIndex - (self._curPage - 1 + 0.5)*AMOUNT].vars.mark:hide();
			else
				table.insert(self._checkedPhoto,  arg.photoId);
				children2[arg.photoIndex - (self._curPage - 1 + 0.5)*AMOUNT].vars.mark:show();
			end
		end
	end
end

function wnd_tripWizardPhotoAlbum:onClickBtn(sender, photoId)
	if not g_i3k_ui_mgr:GetUI(eUIID_TripWizardPhotoShow) then
		local hero = i3k_game_get_player_hero();
		g_i3k_ui_mgr:OpenUI(eUIID_TripWizardPhotoShow)
		g_i3k_ui_mgr:RefreshUI(eUIID_TripWizardPhotoShow, g_Album, {photoId}, hero._name)
	end
end

function wnd_tripWizardPhotoAlbum:onShareBtn(sender)
	if not g_i3k_ui_mgr:GetUI(eUIID_TripWizardSharePhoto) then
		if self._ownPhotos and #self._ownPhotos > 0 then
			if self._checkedPhoto and #self._checkedPhoto > 0 then
				g_i3k_ui_mgr:OpenUI(eUIID_TripWizardSharePhoto)
				g_i3k_ui_mgr:RefreshUI(eUIID_TripWizardSharePhoto, self._checkedPhoto, self._wizardId)
			else
				g_i3k_ui_mgr:PopupTipMessage("请先选择要分享的照片")
			end
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17077))
		end
	end
end

function wnd_tripWizardPhotoAlbum:onForward()
	if self._curPage + 1 > self._maxPage then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17074))
	else
		self._curPage = self._curPage + 1;
		self:updateScroll(self._wizardId)
	end
	self._layout.vars.pageNum:setText(self._curPage .. "/" .."3")
end

function wnd_tripWizardPhotoAlbum:onBackward()
	if self._curPage == 1 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17073))
	else
		self._curPage = self._curPage - 1;
		self:updateScroll(self._wizardId)
	end
	self._layout.vars.pageNum:setText(self._curPage .. "/" .."3")
end

function wnd_create(layout)
	local wnd = wnd_tripWizardPhotoAlbum.new();
		wnd:create(layout);
	return wnd;
end
