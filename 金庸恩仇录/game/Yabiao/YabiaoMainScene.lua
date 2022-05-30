local Zorder = 12002
require("game.Biwu.BiwuFuc")
require("game.Yabiao.YabiaoConst")
require("game.Yabiao.YabiaoFuc_new")
local data_huodong_huodong = require("data.data_huodong_huodong")

local BaseScene = require("game.BaseScene")
local YabiaoMainScene = class("YabiaoMainScene", BaseScene)

function YabiaoMainScene:ctor(param)
	YabiaoMainScene.super.ctor(self, {
	bgImage = "ui_common/common_bg.png"
	})
	self:loadRes()
	self:setUpView()
end

function YabiaoMainScene:setUpView()
	self:setUpBottomView()
	self:setUpMapView()
end

function YabiaoMainScene:setUpMapView()
	local scrollView = CCScrollView:create()
	scrollView:setViewSize(cc.size(display.width, display.height - self:getTopHeight() - self:getBottomHeight()))
	scrollView:setPosition(cc.p(0, self:getBottomHeight()))
	scrollView:setDirection(kCCScrollViewDirectionVertical)
	scrollView:setClippingToBounds(true)
	scrollView:setBounceable(false)
	self:addChild(scrollView)
	scrollView:setAnchorPoint(cc.p(0, 0))
	local content = CCNode:create()
	scrollView:setContainer(content)
	local ccbiName = data_huodong_huodong[7].ccb_bg .. ".ccbi"
	local proxy = CCBProxy:create()
	self._node = {}
	local node = CCBuilderReaderLoad("ccbi/battle_bg/" .. ccbiName, proxy, self._node)
	node:setPosition(display.width * 0.5, 0)
	mapMaxDistance = display.height - self:getTopHeight() - self:getBottomHeight()
	content:addChild(node)
	content:setContentSize(cc.size(display.width, 1600))
	mapHeight = 1300
	titleHeight = self:getTopHeight()
	self._gameController = require("game.Yabiao.YabiaoController").new({
	map = content,
	mainscene = self,
	scroll = scrollView
	})
	--self._gameController:retain()
	
	--·µ»Ø°´¼ü
	local backBtn = ResMgr.newNormalButton({
	scaleBegan = 0.9,
	sprite = "#back_btn.png",
	handle = function()
		self:close()
	end,
	})
	backBtn:setPosition(display.width * 0.9, display.height - 120)
	self:addChild(backBtn)
	
	local disBtn = ResMgr.newNormalButton({
	scaleBegan = 0.8,
	scaleEnd = 0.85,
	sprite = "#lianhua_note_btn.png",
	handle = function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		local layer = require("game.SplitStove.SplitDescLayer").new(5)
		CCDirector:sharedDirector():getRunningScene():addChild(layer, 100)
	end,
	})
	disBtn:setPosition(display.width * 0.75, display.height - 120)
	self:addChild(disBtn)
	
	--ÑºïÚ
	self.yabiaoBtn = ResMgr.newNormalButton({
	scaleBegan = 0.9,
	sprite = "#yabiao_btn.png",
	})
	self.yabiaoBtn:setPosition(display.width * 0.2, self:getContentSize().height * 0.18)
	self:addChild(self.yabiaoBtn)
	
	--Ë¢ÐÂ
	self.shuaxinBtn = ResMgr.newNormalButton({
	scaleBegan = 0.9,
	sprite = "#shuaxin_btn.png",
	})
	self.shuaxinBtn:setPosition(display.width * 0.8, self:getContentSize().height * 0.18)
	self:addChild(self.shuaxinBtn)
	
	self.countDownLabel = ui.newBMFontLabel({
	text = "",
	size = 25,
	align = ui.TEXT_ALIGN_CENTER,
	color = FONT_COLOR.WHITE,
	font = FONTS_NAME.font_btns
	})
	self.countDownLabel:setPosition(cc.p(self.shuaxinBtn:getContentSize().width / 2, self.shuaxinBtn:getContentSize().height / 2))
	self.countDownLabel:setAnchorPoint(cc.p(0.5, 0.5))
	self.shuaxinBtn:bgAddChild(self.countDownLabel)
end

function YabiaoMainScene:onEnter()
	YabiaoMainScene.super.onEnter(self)
end

function YabiaoMainScene:onExit()
	YabiaoMainScene.super.onExit(self)
	self:releaseRes()
	if self._gameController then
		self._gameController:clearTimer()
		self._gameController = nil
	end
end

function YabiaoMainScene:setUpBottomView()
	PostNotice(NoticeKey.UNLOCK_BOTTOM)
	self:setBottomBtnEnabled(true)
	ResMgr.removeBefLayer()
end

function YabiaoMainScene:loadRes()
	display.addSpriteFramesWithFile("ui/ui_yabiao_common.plist", "ui/ui_yabiao_common.png")
	display.addSpriteFramesWithFile("ui/ui_window_base.plist", "ui/ui_window_base.png")
	display.addSpriteFramesWithFile("ui/ui_guild_common_bg.plist", "ui/ui_guild_common_bg.png")
	display.addSpriteFramesWithFile("ui/ui_lianhualu.plist", "ui/ui_lianhualu.png")
end

function YabiaoMainScene:releaseRes()
	display.removeSpriteFramesWithFile("ui/ui_yabiao_common.plist", "ui/ui_yabiao_common.png")
	display.removeSpriteFramesWithFile("ui/ui_window_base.plist", "ui/ui_window_base.png")
	display.removeSpriteFramesWithFile("ui/ui_guild_common_bg.plist", "ui/ui_guild_common_bg.png")
	display.removeSpriteFramesWithFile("ui/ui_lianhualu.plist", "ui/ui_lianhualu.png")
end

function YabiaoMainScene:close()
	GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
	GameStateManager:ChangeState(GAME_STATE.STATE_HUODONG)
	self:removeSelf()
end

return YabiaoMainScene