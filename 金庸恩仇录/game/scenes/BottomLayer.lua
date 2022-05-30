require("game.scenes.MainMenuLayer")
local data_config_config = require("data.data_config_config")

local BottomLayer = class("BottomLayer", function (showbg)
	return display.newNode()
end)

function BottomLayer:setMenuItemEnabled(b)
	
end

function BottomLayer:ctor(showbg)
	self:setNodeEventEnabled(true)	
	display.addSpriteFramesWithFile("ui/ui_bottom_layer.plist", "ui/ui_bottom_layer.pvr.ccz")
	local showbg = showbg or true
	if showbg == true then
		self.bottomBg = display.newScale9Sprite("#bl_bottom_bg.png")
		self.bottomBg:setPreferredSize(cc.size(display.width, self.bottomBg:getContentSize().height))
		self.bottomBg:setPosition(display.cx, self.bottomBg:getContentSize().height * 0.5)
		self:addChild(self.bottomBg)
	end
	self:initBottomFrame()
	self.bottomFrame = display.newScale9Sprite("#bl_bottom_layer.png")
	self.bottomFrame:setPreferredSize(cc.size(display.width, self.bottomFrame:getContentSize().height))
	self.bottomFrame:setPosition(display.width / 2, self.bottomFrame:getContentSize().height / 2)
	self:addChild(self.bottomFrame)
end

BottomLayer.tutoBtns = {}

function BottomLayer:addTutoBtns()
	for k, v in pairs(self.tutoBtns) do
		TutoMgr.addBtn(k, v)
	end
end

function BottomLayer:initBottomFrame(...)
	local bottomImage = {
	"#bl_shouye_up.png",
	"#bl_zhenrong_up.png",
	"#bl_fuben_up.png",
	"#bl_huodong_up.png",
	"#bl_beibao_up.png",
	"#bl_shop_up.png"
	}
	
	local bottomImageDown = {
	"#bl_shouye_down.png",
	"#bl_zhenrong_down.png",
	"#bl_fuben_down.png",
	"#bl_huodong_down.png",
	"#bl_beibao_down.png",
	"#bl_shop_down.png"
	}
	
	local baseBottomItems = {
	CCB_TAG.mm_shouye,
	CCB_TAG.mm_zhenrong,
	CCB_TAG.mm_fuben,
	CCB_TAG.mm_huodong,
	CCB_TAG.mm_beibao,
	CCB_TAG.mm_shop
	}
	
	local items = {}
	self.btns = {}
	self.allBtns = items
	for k, v in pairs(bottomImage) do
		local btn = ui.newImageMenuItem({
		image = bottomImage[k],
		tag = k,
		imageSelected = bottomImageDown[k],
		--listener = function ()
		--	PostNotice(NoticeKey.REMOVE_TUTOLAYER)
		--	self:onTouchBtn(baseBottomItems[k])
		--end
		})
		items[k] = btn
		btn:registerScriptTapHandler(function (tag)
			PostNotice(NoticeKey.REMOVE_TUTOLAYER)
			self:onTouchBtn(baseBottomItems[k])
		end)
		
		if v == "#bl_zhenrong_up.png" then
			TutoMgr.addBtn("zhujiemian_btn_zhenrong", btn)
			self.tutoBtns.zhujiemian_btn_zhenrong = btn
		end
		if v == "#bl_shop_up.png" then
			TutoMgr.addBtn("zhujiemian_btn_shangcheng", btn)
			self.tutoBtns.zhujiemian_btn_shangcheng = btn
		end
		if v == "#bl_fuben_up.png" then
			TutoMgr.addBtn("zhenrong_btn_fuben", btn)
			self.tutoBtns.zhenrong_btn_fuben = btn
		end
		if v == "#bl_huodong_up.png" then
			TutoMgr.addBtn("zhujiemian_btn_huodong", btn)
			self.tutoBtns.zhujiemian_btn_huodong = btn
		end
		if v == "#bl_shouye_up.png" then
			TutoMgr.addBtn("zhenrong_btn_shouye", btn)
			self.tutoBtns.zhenrong_btn_shouye = btn
		end
		self.btns[#self.btns + 1] = btn
		btn:setPosition(1 + (k - 1) * self.bottomBg:getContentSize().width / #bottomImage + btn:getContentSize().width / 2, btn:getContentSize().height * 0.5 + 9)
		if k == 3 then
			display.addSpriteFramesWithFile("ui/ui_toplayer.plist", "ui/ui_toplayer.pvr.ccz")
			self._jiangHuBtnNotice = display.newSprite("#toplayer_mail_tip.png")
			self._jiangHuBtnNotice:setAnchorPoint(cc.p(1, 1))
			self._jiangHuBtnNotice:setPosition(btn:getContentSize().width, btn:getContentSize().height)
			self._jiangHuBtnNotice:setVisible(false)
			btn:addChild(self._jiangHuBtnNotice, 100)
			local x = btn:getContentSize().width / 2
			local y = btn:getContentSize().height / 2
			local rootNode = {}
			self._jiantouEff = LoadUI("mainmenu/navigtion.ccbi", rootNode)
			self._jiantouEff:setVisible(false)
			self._jianTouNode = rootNode.mJianTouNode
			self._jianTouNode:setVisible(false)
			self._jiantouEff:setPosition(btn:getContentSize().width / 2, btn:getContentSize().height / 2)
			btn:addChild(self._jiantouEff, 100)
		end
		if k == 2 then
			self._formEquipBtn = btn
			addPrompt(btn)
		end
		if k == #bottomImage then
			display.addSpriteFramesWithFile("ui/ui_toplayer.plist", "ui/ui_toplayer.pvr.ccz")
			self._shopBtnNotice = display.newSprite("#toplayer_mail_tip.png")
			self._shopBtnNotice:setAnchorPoint(cc.p(1, 1))
			self._shopBtnNotice:setPosition(btn:getContentSize().width, btn:getContentSize().height)
			self._shopBtnNotice:setVisible(false)
			btn:addChild(self._shopBtnNotice, 100)
		end
	end
	local menu = ui.newMenu(items)
	menu:align(display.CENTER, display.cx, items[1]:getContentSize().height/2 + 9)
	menu:alignItemsHorizontally()
	self.bottomBg:addChild(menu)
	
	for k, v in pairs(G_BOTTOM_BTN) do
		if GameStateManager.currentState == v and 2 <= GameStateManager.currentState then
			items[k]:selected()
			if k ~= 3 and game.player.getLevel() >= data_config_config[1].tip_jianghu_level_begin and game.player.getLevel() < data_config_config[1].tip_jianghu_level then
				self._jiantouEff:setVisible(true)
			end
			break
		end
	end
	
	if GameStateManager.currentState == GAME_STATE.STATE_SUBMAP then
		items[3]:selected()
	end
end

function BottomLayer:refreshShopNotice()
	if self._shopBtnNotice ~= nil then
		dump(game.player:getChoukaNum())
		if game.player:getChoukaNum() > 0 then
			self._shopBtnNotice:setVisible(true)
		else
			self._shopBtnNotice:setVisible(false)
		end
	end
end


function BottomLayer:refreshJiangHuNotice()
	if self._jiangHuBtnNotice ~= nil then
		if game.player:getJiangHuBoxNum() > 0 then
			self._jiangHuBtnNotice:setVisible(true)
		else
			self._jiangHuBtnNotice:setVisible(false)
		end
	end
end

function BottomLayer:refreshFormEquipNotice()
	if self._formEquipBtn ~= nil then
		addPrompt(self._formEquipBtn)
	end
end

function BottomLayer:refreshJianTou()
	if self._jiantouEff ~= nil then
		if game.player.getLevel() >= data_config_config[1].tip_jianghu_level_begin and game.player.getLevel() < data_config_config[1].tip_jianghu_level then
			self._jiantouEff:setVisible(true)
		else
			self._jiantouEff:setVisible(false)
		end
		self._jianTouNode:setVisible(false)
	end
end

function BottomLayer:onEnter()

	RegNotice(self, function ()
		self:refreshShopNotice()
	end,
	NoticeKey.BottomLayer_Chouka)
	
	RegNotice(self, function ()
		self:refreshFormEquipNotice()
	end,
	NoticeKey.BottomLayer_ZhenRong)
	
	RegNotice(self, function ()
		self:setMenuItemEnabled(false)
	end,
	NoticeKey.LOCK_BOTTOM)
	
	RegNotice(self, function ()
		self:setMenuItemEnabled(true)
	end,
	NoticeKey.UNLOCK_BOTTOM)
	
	RegNotice(self, function ()
		self:refreshJiangHuNotice()
	end,
	NoticeKey.BottomLayer_JiangHu)
	
	self:refreshShopNotice()
	self:refreshJiangHuNotice()
	self:refreshJianTou()
	
end

function BottomLayer:onExit()
	TutoMgr.removeBtn("zhujiemian_btn_shangcheng")
	TutoMgr.removeBtn("zhujiemian_btn_huodong")
	TutoMgr.removeBtn("zhenrong_btn_shouye")
	UnRegNotice(self, NoticeKey.BottomLayer_Chouka)
	UnRegNotice(self, NoticeKey.BottomLayer_JiangHu)
	UnRegNotice(self, NoticeKey.BottomLayer_ZhenRong)
	UnRegNotice(self, NoticeKey.LOCK_BOTTOM)
	UnRegNotice(self, NoticeKey.UNLOCK_BOTTOM)
end


function BottomLayer:getContentSize(...)
	return self.bottomBg:getContentSize()
end


function BottomLayer:onTouchBtn(tag)
	GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
	local nextState = 0
	local msg = {}
	if tag == CCB_TAG.mm_shouye then
		nextState = GAME_STATE.STATE_MAIN_MENU
	elseif tag == CCB_TAG.mm_zhenrong then
		if game.player.m_formation == nil then
			RequestHelper.formation.list({
			m = "fmt",
			a = "list",
			pos = "0",
			param = {},
			callback = function (data)
				dump(data)
				game.player.m_formation = data
				game.player.addCulianAttr()
				nextState = GAME_STATE.STATE_ZHENRONG
				msg.type = 1
				msg.pos = 1
				GameStateManager:ChangeState(nextState, msg)
			end
			})
		else
			game.player.addCulianAttr()
			nextState = GAME_STATE.STATE_ZHENRONG
			msg.type = 1
			msg.pos = 1
			GameStateManager:ChangeState(nextState, msg)
		end
	elseif tag == CCB_TAG.mm_fuben then
		nextState = GAME_STATE.STATE_FUBEN
	elseif tag == CCB_TAG.mm_huodong then
		nextState = GAME_STATE.STATE_HUODONG
	elseif tag == CCB_TAG.mm_beibao then
		nextState = GAME_STATE.STATE_BEIBAO
	elseif tag == CCB_TAG.mm_shop then
		nextState = GAME_STATE.STATE_SHOP
	end
	
	for k, v in pairs(G_BOTTOM_BTN) do
		if GameStateManager.currentState == v and GameStateManager.currentState > 2 then
			self.allBtns[k]:selected()
			break
		end
	end
	GameStateManager:ChangeState(nextState, msg)
end

return BottomLayer