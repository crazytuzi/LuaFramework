
local ALIGN_CENTER = "align_center"
local ALIGN_LEFT = "align_left"
local ALIGN_RIGHT = "align_right"


local function getFlag(nState, n)
	return math.mod(math.floor(nState / (2^n)), 10)
end

local CommonFunc = require("app.scenes.moshen.rebelboss.RebelBossCommonFunc")
local MoShenConst = require("app.const.MoShenConst")

local RebelBossAwardItem = class("RebelBossAwardItem", function()
	return CCSItemCellBase:create("ui_layout/moshen_RebelBossAwardItem.json")
end)

-- 荣誉，Boss等级，军团
function RebelBossAwardItem:ctor(nMode)

	self._nMode = nMode or MoShenConst.REBEL_BOSS_AWARD_MODE.HONOR
	if self._nMode == MoShenConst.REBEL_BOSS_AWARD_MODE.HONOR or self._nMode == MoShenConst.REBEL_BOSS_AWARD_MODE.BOSS_LEVEL then
		self:showWidgetByName("Panel_Honor", true)
		self:showWidgetByName("Panel_Legion", false)
	else
		self:showWidgetByName("Panel_Honor", false)
		self:showWidgetByName("Panel_Legion", true)
	end

	self:attachImageTextForBtn("Button_Claim", "Image_71")

	self._nClaimState = nil
end

function RebelBossAwardItem:updateItem(tTmpl)
	if not tTmpl then
		return
	end

	if self._nMode == MoShenConst.REBEL_BOSS_AWARD_MODE.HONOR then
		self:_updateHonorAwardInfo(tTmpl)
	elseif self._nMode == MoShenConst.REBEL_BOSS_AWARD_MODE.BOSS_LEVEL then
		self:_updateBossLevelAwardInfo(tTmpl)
	else
		self:_updateLegionAwardInfo(tTmpl)
	end

end

function RebelBossAwardItem:_updateHonorAwardInfo(tTmpl)
	self:getPanelByName("Panel_Honor"):setTag(tTmpl.id)
	local tGoods = G_Goods.convert(tTmpl.type, tTmpl.value, tTmpl.size)
	self:_initGoods(tGoods)

	-- 名称，物品的名称
	CommonFunc._updateLabel(self, "Label_WinStreak_Num", {text=tGoods.name, stroke=Colors.strokeBrown, size=1})
	-- 可领取条件描述
	CommonFunc._updateLabel(self, "Label_Progress_Title", {visible=false})
	CommonFunc._updateLabel(self, "Label_Progress", {text=G_lang:get("LANG_REBEL_BOSS_GET_HONOR_AWARD_CONDITION", {num=G_GlobalFunc.ConvertNumToCharacter(tTmpl.boss_exploit)})})
	-- 当前进度
	local nMyTotalHonor = G_Me.moshenData:getMyTotalHonor()
	CommonFunc._updateLabel(self, "Label_Award_Title", {text=G_lang:get("LANG_REBEL_BOSS_CURRENT_SCHEDULE")})
	CommonFunc._updateLabel(self, "Label_Award_Content", {text=G_GlobalFunc.ConvertNumToCharacter(nMyTotalHonor) .. "/" .. G_GlobalFunc.ConvertNumToCharacter(tTmpl.boss_exploit)})
	-- 领取状态, 不可领取，可领取，已经领取
	local imgClaimState = self:getImageViewByName("ImageView_AwardStatus")
	if tTmpl._nState == MoShenConst.AWARD_STATE.CLAIMED then
		self._nClaimState = MoShenConst.AWARD_STATE.CLAIMED
		imgClaimState:loadTexture("ui/text/txt/jqfb_yilingqu.png", UI_TEX_TYPE_LOCAL)
		imgClaimState:setVisible(true)
	elseif tTmpl._nState == MoShenConst.AWARD_STATE.UNFINISH then
		if nMyTotalHonor >= tTmpl.boss_exploit then
			self._nClaimState = MoShenConst.AWARD_STATE.CAN_CLAIM
			imgClaimState:loadTexture("ui/text/txt/jqfb_dianjilingqu.png", UI_TEX_TYPE_LOCAL)
			imgClaimState:setVisible(true)
		else
			self._nClaimState = MoShenConst.AWARD_STATE.UNFINISH
			imgClaimState:setVisible(false)
		end
	end

    local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
        self:getLabelByName('Label_Progress'),
    }, "L")
    self:getLabelByName('Label_Progress'):setPositionXY(alignFunc(1))  


    local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
        self:getLabelByName('Label_Award_Title'),
        self:getLabelByName('Label_Award_Content'),
    }, "L")
    self:getLabelByName('Label_Award_Title'):setPositionXY(alignFunc(1))
    self:getLabelByName('Label_Award_Content'):setPositionXY(alignFunc(2))  

    self:registerWidgetTouchEvent("Panel_Honor", handler(self, self._onClickCell))

end

function RebelBossAwardItem:_updateBossLevelAwardInfo(tTmpl)
	self:getPanelByName("Panel_Honor"):setTag(tTmpl.id)
	local tGoods = G_Goods.convert(tTmpl.type, tTmpl.value, tTmpl.size)
	self:_initGoods(tGoods)

	-- 名称，物品的名称
	CommonFunc._updateLabel(self, "Label_WinStreak_Num", {text=tGoods.name, stroke=Colors.strokeBrown, size=1})
	-- 可领取条件描述
	CommonFunc._updateLabel(self, "Label_Progress_Title", {visible=false})
	CommonFunc._updateLabel(self, "Label_Progress", {text=tTmpl.name})
	-- 当前进度
	local tBoss = G_Me.moshenData:getRebelBoss()
	local nBossLevel = tBoss._nLevel
	local nDeadLevel = nBossLevel
	-- 领取状态, 不可领取，可领取，已经领取
	local imgClaimState = self:getImageViewByName("ImageView_AwardStatus")
	if tTmpl._nState == MoShenConst.AWARD_STATE.CLAIMED then
		self._nClaimState = MoShenConst.AWARD_STATE.CLAIMED
		imgClaimState:loadTexture("ui/text/txt/jqfb_yilingqu.png", UI_TEX_TYPE_LOCAL)
		imgClaimState:setVisible(true)
	elseif tTmpl._nState == MoShenConst.AWARD_STATE.UNFINISH then
		if nBossLevel > tTmpl.boss_level then
			self._nClaimState = MoShenConst.AWARD_STATE.CAN_CLAIM
			imgClaimState:loadTexture("ui/text/txt/jqfb_dianjilingqu.png", UI_TEX_TYPE_LOCAL)
			imgClaimState:setVisible(true)
		elseif nBossLevel == tTmpl.boss_level then
			if tBoss._nCurHp == 0 then
				self._nClaimState = MoShenConst.AWARD_STATE.CAN_CLAIM
				imgClaimState:loadTexture("ui/text/txt/jqfb_dianjilingqu.png", UI_TEX_TYPE_LOCAL)
				imgClaimState:setVisible(true)
			else
				self._nClaimState = MoShenConst.AWARD_STATE.UNFINISH
				imgClaimState:setVisible(false)
			end
		else
			self._nClaimState = MoShenConst.AWARD_STATE.UNFINISH
			imgClaimState:setVisible(false)
		end
	end

	if tBoss._nCurHp ~= 0 then
		nDeadLevel = nBossLevel - 1
	else
		nDeadLevel = nBossLevel
	end

	CommonFunc._updateLabel(self, "Label_Award_Title", {text=G_lang:get("LANG_REBEL_BOSS_CURRENT_SCHEDULE")})
	CommonFunc._updateLabel(self, "Label_Award_Content", {text=G_GlobalFunc.ConvertNumToCharacter(nDeadLevel) .. "/" .. G_GlobalFunc.ConvertNumToCharacter(tTmpl.boss_level)})

    local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
        self:getLabelByName('Label_Progress'),
    }, "L")
    self:getLabelByName('Label_Progress'):setPositionXY(alignFunc(1))  


    local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
        self:getLabelByName('Label_Award_Title'),
        self:getLabelByName('Label_Award_Content'),
    }, "L")
    self:getLabelByName('Label_Award_Title'):setPositionXY(alignFunc(1))
    self:getLabelByName('Label_Award_Content'):setPositionXY(alignFunc(2))  

    self:registerWidgetTouchEvent("Panel_Honor", handler(self, self._onClickCell))
end

function RebelBossAwardItem:_updateLegionAwardInfo(tTmpl)
	if not tTmpl then
		return
	end
	
	self:getPanelByName("Panel_Legion"):setTag(tTmpl.id)
	self:getButtonByName("Button_Claim"):setTag(tTmpl.id)
	local tGoods = G_Goods.convert(tTmpl.award_type1, tTmpl.award_value1, tTmpl.award_size1)
	self:_initLegionGoods(tGoods)

	local nRank = tTmpl.rank
	local tLegionRankInfoList = G_Me.moshenData:getLegionRankInfoList()
	local tLegionRankInfo = nil
	for key, val in pairs(tLegionRankInfoList) do
		local tInfo = val
		if tInfo._nRank == nRank then
			tLegionRankInfo = tInfo
			break
		end
	end

	local szLegionName = G_lang:get("LANG_REBEL_BOSS_WAITING_FOR_YOU")
	local nHonor = 0
	local tStateList = {}
	if tLegionRankInfo then
		szLegionName = tLegionRankInfo._szLegionName
		nHonor = tLegionRankInfo._nHonor
		tStateList = tLegionRankInfo._tStateList
	end

	-- 名称，物品的名称
	CommonFunc._updateLabel(self, "Label_WinStreak_NumLegion", {text=tTmpl.name, stroke=Colors.strokeBrown, size=1})
	-- 可领取条件描述
	CommonFunc._updateLabel(self, "Label_Current_Title", {text=G_lang:get("LANG_REBEL_BOSS_CURRENT")})
	CommonFunc._updateLabel(self, "Label_Current", {text=szLegionName})
	-- 当前荣誉
	CommonFunc._updateLabel(self, "Label_LegionHonor_Title", {text=G_lang:get("LANG_REBEL_BOSS_CURRENT_HONOR")})
	CommonFunc._updateLabel(self, "Label_LegionHonor_Content", {text=G_GlobalFunc.ConvertNumToCharacter(nHonor)})
	self:showWidgetByName("Button_Claim", false)
	-- 结束后自动发入
	CommonFunc._updateLabel(self, "Label_NotFinish", {text=G_lang:get("LANG_REBEL_BOSS_NOT_FINISH")})
	CommonFunc._updateLabel(self, "Label_NotFinish1", {text=G_lang:get("LANG_REBEL_BOSS_NOT_FINISH1")})
	-- 领取状态, 不可领取，可领取，已经领取
	local imgClaimState = self:getImageViewByName("ImageView_AwardStatusLegion")
	imgClaimState:loadTexture("ui/text/txt/yifafang.png", UI_TEX_TYPE_LOCAL)
	
	local tInitInfo = G_Me.moshenData:getInitializeInfo()
	if tInitInfo._nState == MoShenConst.REBEL_BOSS_STAGE.START then
		self:showWidgetByName("Panel_NotFinish", true)
		imgClaimState:setVisible(false)
	else
		self:showWidgetByName("Panel_NotFinish", false)
		imgClaimState:setVisible(true)
	end

    local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
        self:getLabelByName('Label_Current_Title'),
        self:getLabelByName('Label_Current'),
    }, "L")
    self:getLabelByName('Label_Current_Title'):setPositionXY(alignFunc(1))  
    self:getLabelByName('Label_Current'):setPositionXY(alignFunc(2))  


    local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
        self:getLabelByName('Label_LegionHonor_Title'),
        self:getLabelByName('Label_LegionHonor_Content'),
    }, "L")
    self:getLabelByName('Label_LegionHonor_Title'):setPositionXY(alignFunc(1))
    self:getLabelByName('Label_LegionHonor_Content'):setPositionXY(alignFunc(2))  
end

function RebelBossAwardItem:_initGoods(tGoods)
	local imgBg = self:getImageViewByName("ImageView_IconFrame")
	if not tGoods then
		imgBg:setVisible(false)
	else
		imgBg:loadTexture(G_Path.getEquipIconBack(tGoods.quality))
		-- 掉落物品的品质框
		local imgQulaity = self:getImageViewByName("Image_QualityFrame")
		imgQulaity:loadTexture(G_Path.getEquipColorImage(tGoods.quality, tGoods.type))
		imgQulaity._nType = tGoods.type
		imgQulaity._nValue= tGoods.value
		-- 掉落数量 
		local labelDropNum = self:getLabelByName("Label_Award_Num")
		if labelDropNum then
			labelDropNum:setText("x".. G_GlobalFunc.ConvertNumToCharacter3(tGoods.size))
			labelDropNum:createStroke(Colors.strokeBrown,1)
		end
		-- 掉落的物品icon
		local imgIcon = self:getImageViewByName("ImageView_AwardIcon")
		if imgIcon then
			imgIcon:loadTexture(tGoods.icon)
		end
		-- 绑定点击事件
		self:registerWidgetTouchEvent("Image_QualityFrame", handler(self, self._onClickAwardItem))
	end
end

function RebelBossAwardItem:_initLegionGoods(tGoods)
	local imgBg = self:getImageViewByName("ImageView_IconFrameLegion")
	if not tGoods then
		imgBg:setVisible(false)
	else
		imgBg:loadTexture(G_Path.getEquipIconBack(tGoods.quality))
		-- 掉落物品的品质框
		local imgQulaity = self:getImageViewByName("Image_QualityFrameLegion")
		imgQulaity:loadTexture(G_Path.getEquipColorImage(tGoods.quality, tGoods.type))
		imgQulaity._nType = tGoods.type
		imgQulaity._nValue= tGoods.value
		-- 掉落数量 
		local labelDropNum = self:getLabelByName("Label_Award_NumLegion")
		if labelDropNum then
			labelDropNum:setText("x".. G_GlobalFunc.ConvertNumToCharacter3(tGoods.size))
			labelDropNum:createStroke(Colors.strokeBrown,1)
		end
		-- 掉落的物品icon
		local imgIcon = self:getImageViewByName("ImageView_AwardIconLegion")
		if imgIcon then
			imgIcon:loadTexture(tGoods.icon)
		end
		-- 绑定点击事件
		self:registerWidgetTouchEvent("Image_QualityFrameLegion", handler(self, self._onClickLegionAwardItem))
	end
end

function RebelBossAwardItem:_onClickAwardItem(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		local nType = sender._nType
		local nValue = sender._nValue
	    G_SoundManager:playSound(require("app.const.SoundConst").GameSound.BUTTON_SHORT)
		require("app.scenes.common.dropinfo.DropInfo").show(nType, nValue)
	end
end

function RebelBossAwardItem:_onClickLegionAwardItem(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		local nType = sender._nType
		local nValue = sender._nValue
	    G_SoundManager:playSound(require("app.const.SoundConst").GameSound.BUTTON_SHORT)
		local tItem = item_info.get(nValue)
		assert(tItem)
		if tItem.item_type == 1 then
			local layer = require("app.scenes.shop.ShopGiftReviewDialog").create(tItem)
            uf_sceneManager:getCurScene():addChild(layer)
		else
			assert(false, "error item type")
		end
	end
end

function RebelBossAwardItem:_onClickCell(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		if self._nClaimState == MoShenConst.AWARD_STATE.UNFINISH then
			G_MovingTip:showMovingTip(G_lang:get("LANG_REBEL_BOSS_MISSION_UNFINISH"))
		elseif self._nClaimState == MoShenConst.AWARD_STATE.CAN_CLAIM then
			if self._nMode == MoShenConst.REBEL_BOSS_AWARD_MODE.HONOR or self._nMode == MoShenConst.REBEL_BOSS_AWARD_MODE.BOSS_LEVEL then
				local nId = sender:getTag()
				G_HandlersManager.moshenHandler:sendRebelBossAward(self._nMode, nId)
			else
				-- 点击事件在按钮上
			end
		elseif self._nClaimState == MoShenConst.AWARD_STATE.CLAIMED then
			G_MovingTip:showMovingTip(G_lang:get("LANG_REBEL_BOSS_AWARD_HAS_CLAIMED"))
		end
	end
end

function RebelBossAwardItem:_onClaimLegionAward(sender)
	local nId = sender:getTag()
	G_HandlersManager.moshenHandler:sendRebelBossAward(self._nMode, nId)
end

return RebelBossAwardItem