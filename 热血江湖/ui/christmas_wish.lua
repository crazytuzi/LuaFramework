-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_christmas_wish = i3k_class("wnd_christmas_wish", ui.wnd_base)

local e_Type_Send_Flower = 1
local e_Type_Send_Brick  = 2

function wnd_christmas_wish:ctor()
	self._bid = 1  --背景图ID
	self._rid = nil  --需要评价的人物id
end

function wnd_christmas_wish:configure()
	local widget = self._layout.vars
	widget.close_btn:onClick(self, self.onCloseUI)

	self.wish_root = widget.wishRoot
	self.comment_root = widget.commentRoot

	--许愿
	self.wish_btn = widget.wish_btn
	self.wish_btn:onClick(self, self.onWishBtn)
	self.wish_btn_text = widget.wish_btn_text
	self.changeBtns = {widget.btn1, widget.btn2, widget.btn3, widget.btn4, widget.btn5}  --模板按钮
	for i, v in ipairs(self.changeBtns) do
		v:setTag(i)
		v:onClick(self, self.onChangeBgBtn)
	end
	self.wish = widget.wish
	self.wish:setMaxLength(i3k_db_christmas_wish_cfg.inputMax)
	--self.wish:setPlaceHolder(string.format("%s~%s个汉字", i3k_db_christmas_wish_cfg.inputMin, i3k_db_christmas_wish_cfg.inputMax))
	self.wish:addEventListener(function(eventType)
		if eventType == "ended" then
			self.other_wish:setText(self.wish:getText())
			self.wish:setText("")
		end
	end)

	--砸砖和送花
	self.brick_btn = widget.brick_btn
	self.brick_btn:onClick(self, self.onBrickBtn)
	self.brick_btn:disableWithChildren()

	self.flower_btn = widget.flower_btn
	self.flower_btn:onClick(self, self.onFlowerBtn)
	self.flower_btn:disableWithChildren()

	self.brick_num = widget.brick_num
	self.flower_num = widget.flower_num
	
	--共用
	self.bg_img = widget.bg_img
	self.desc_name = widget.desc_name
	self.other_wish = widget.other_wish
end

function wnd_christmas_wish:refresh(wishUpdateTime, overview, openType)
	self:setUIRootVisible(openType)
	if openType == g_TYPE_Edit then
		self:updateWishInfo(wishUpdateTime, overview)
	elseif openType == g_TYPE_Scan then
		self:updateOtherWish(overview)
	elseif openType == g_TYPE_Comment then
		self:updateOtherWish(overview)
		self.flower_btn:enableWithChildren()
		self.brick_btn:enableWithChildren()
	end
	
	self._rid = overview.rid

	self._bid = overview.background ~= 0 and overview.background or 1
	self.bg_img:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_christmas_wish_bgImg[self._bid].bgID))

	self.desc_name:setText(string.format("--%s", overview.roleName))
end

function wnd_christmas_wish:setUIRootVisible(openType)
	self.wish_root:setVisible(openType == g_TYPE_Edit)
	self.wish:setVisible(openType == g_TYPE_Edit)
	self.comment_root:setVisible(openType ~= g_TYPE_Edit)
end

function wnd_christmas_wish:updateWishInfo(wishUpdateTime, overview)
	local wishText = ""
	if wishUpdateTime > 0 then  --已许过愿望
		wishText = overview.text
		self.wish_btn_text:setText("保存")
	else
		wishText = i3k_get_string(16932)
		self.wish_btn_text:setText("许愿")
	end
	self.other_wish:setText(wishText)
end

function wnd_christmas_wish:onChangeBgBtn(sender)
	local tag = sender:getTag()
	if self._bid ~= tag then
		self._bid = tag
		self.bg_img:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_christmas_wish_bgImg[self._bid].bgID))
	end
end

function wnd_christmas_wish:onWishBtn(sender)
	local text = self.other_wish:getText()
	local textcount = i3k_get_utf8_len(text)
	if textcount < i3k_db_christmas_wish_cfg.inputMin then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16933, i3k_db_christmas_wish_cfg.inputMin))
		return
	end
	if textcount > i3k_db_christmas_wish_cfg.inputMax then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16934, i3k_db_christmas_wish_cfg.inputMax))
		return
	end

	local oldText = g_i3k_game_context:GetMyChristmasCardInfo().overview.text
	local oldBid = g_i3k_game_context:GetMyChristmasCardInfo().overview.background

	if oldText == text and oldBid == self._bid then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16935))
		return
	end

	i3k_sbean.christmas_cards_wish(text, self._bid)
end
-----------------------------------------------------
function wnd_christmas_wish:updateOtherWish(overview)
	self.other_wish:setText(overview.text)
	self.brick_num:setText(overview.brick)
	self.flower_num:setText(overview.flower)
end

function wnd_christmas_wish:onBrickBtn(sender)
	if self._rid then
		i3k_sbean.christmas_cards_comment(self._rid, e_Type_Send_Brick)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16938))
	end
end

function wnd_christmas_wish:onFlowerBtn(sender)
	if self._rid then
		i3k_sbean.christmas_cards_comment(self._rid, e_Type_Send_Flower)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16938))
	end
end

--InvokeUIFunction
function wnd_christmas_wish:setCommentCnt(commentType)
	if commentType == e_Type_Send_Brick then
		self.brick_num:setText(tonumber(self.brick_num:getText()) + 1)
	elseif commentType == e_Type_Send_Flower then
		self.flower_num:setText(tonumber(self.flower_num:getText()) + 1)
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_christmas_wish.new();
	wnd:create(layout, ...);
	return wnd;
end
