
local ALIGN_CENTER = "align_center"
local ALIGN_LEFT = "align_left"
local ALIGN_RIGHT = "align_right"

local CommonFunc = require("app.scenes.moshen.rebelboss.RebelBossCommonFunc")
local MoShenConst = require("app.const.MoShenConst")

local RebelBossRankItem = class("RebelBossRankItem", function()
	return CCSItemCellBase:create("ui_layout/moshen_RebelBossRankItem.json")
end)

function RebelBossRankItem:ctor(nMode)
	self._nMode = nMode
end

function RebelBossRankItem:updateItem(tRankItem)
	if not tRankItem then
		return
	end

	local knightInfo = knight_info.get(tRankItem._nId)

	local nFightValue = G_GlobalFunc.ConvertNumToCharacter(tRankItem._nFightValue) 
	local nTotalHonor = G_GlobalFunc.ConvertNumToCharacter(tRankItem._nValue) 
	local szUserName = tRankItem._szName or ""
	local szLegionName = "[" .. ((tRankItem._szLegionName ~= "") and tRankItem._szLegionName or G_lang:get("LANG_REBEL_BOSS_NOT_JOININ_LEGION")) .. "]"
	local nRank = tRankItem._nRank or 1

	CommonFunc._updateLabel(self, "Label_Power", {text=G_lang:get("LANG_REBEL_BOSS_FIGHT_VALUE")})
	CommonFunc._updateLabel(self, "Label_PowerNum", {text=nFightValue})
	CommonFunc._updateLabel(self, "Label_Other", {text= (self._nMode == MoShenConst.REBEL_BOSS_RANK_MODE.HONOR) and G_lang:get("LANG_REBEL_BOSS_TOTAL_HONOR") or 
																										 G_lang:get("LANG_REBEL_BOSS_MAX_HARM")})
	CommonFunc._updateLabel(self, "Label_OtherNum", {text=nTotalHonor})
	CommonFunc._updateLabel(self, "Label_UserName", {text=szUserName, stroke=Colors.strokeBrown, color=Colors.qualityColors[knightInfo.quality]})
	CommonFunc._updateLabel(self, "Label_ServerName", {text=szLegionName})

	self:_showCrown(nRank)
	self:_updateBoardColor(tRankItem._nUserId == G_Me.userData.id)

	-- head icon
	local resID = knightInfo.res_id

	resID = G_Me.dressData:getDressedResidWithClidAndCltm(tRankItem._nId, tRankItem._nDressId,
		tRankItem.clid,tRankItem.cltm,tRankItem.clop)

	self:getImageViewByName("Image_Head"):loadTexture(G_Path.getKnightIcon(resID))

	-- quality frame
	local qualityTex = G_Path.getEquipColorImage(knightInfo.quality, G_Goods.TYPE_KNIGHT)
	self:getImageViewByName("Image_QualityFrame"):loadTexture(qualityTex, UI_TEX_TYPE_PLIST)
	local imgQualityFrame = self:getImageViewByName("Image_QualityFrame")
	imgQualityFrame._nUserId = tRankItem._nUserId

    local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
        self:getLabelByName('Label_Power'),
        self:getLabelByName('Label_PowerNum'),
    }, "L")
    self:getLabelByName('Label_Power'):setPositionXY(alignFunc(1))
    self:getLabelByName('Label_PowerNum'):setPositionXY(alignFunc(2))

    local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
        self:getLabelByName('Label_Other'),
        self:getLabelByName('Label_OtherNum'),
    }, "L")
    self:getLabelByName('Label_Other'):setPositionXY(alignFunc(1))
    self:getLabelByName('Label_OtherNum'):setPositionXY(alignFunc(2))

    self:registerWidgetTouchEvent("Image_QualityFrame", handler(self, self._checkLineUp))
end

function RebelBossRankItem:_showCrown(nRank)
	local imgCrown = self:getImageViewByName("Image_RankCrown")
	local labelRank = self:getLabelBMFontByName("BitmapLabel_Rank")
	if imgCrown then
		if nRank <=3 then
			imgCrown:loadTexture(G_Path.getRankCrownImage(nRank), UI_TEX_TYPE_LOCAL)
			imgCrown:setVisible(true)
		else
			imgCrown:setVisible(false)
		end
	end
	if labelRank then
		labelRank:setText(nRank)
		labelRank:setVisible(nRank > 3)
	end
end

function RebelBossRankItem:_updateBoardColor(isMe)
	if isMe then
		self:getPanelByName("Root"):setBackGroundImage("board_red.png",UI_TEX_TYPE_PLIST)
		self:getImageViewByName("Image_InfoFrame"):loadTexture("list_board_red.png", UI_TEX_TYPE_PLIST)
	else
		self:getPanelByName("Root"):setBackGroundImage("board_normal.png",UI_TEX_TYPE_PLIST)
		self:getImageViewByName("Image_InfoFrame"):loadTexture("list_board.png", UI_TEX_TYPE_PLIST)
	end
end

-- 查看阵容
function RebelBossRankItem:_checkLineUp(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		local nUserId = sender._nUserId
		assert(nUserId)
		G_HandlersManager.arenaHandler:sendCheckUserInfo(nUserId)
	end
end



return RebelBossRankItem