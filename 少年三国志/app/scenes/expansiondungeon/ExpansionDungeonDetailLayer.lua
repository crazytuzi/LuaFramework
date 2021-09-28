require("app.cfg.expansion_dungeon_stage_info")
local KnightPic = require("app.scenes.common.KnightPic")
local ExpansionDungeonCommonFunc = require("app.scenes.expansiondungeon.ExpansionDungeonCommonFunc")

local ExpansionDungeonDetailLayer = class("ExpansionDungeonDetailLayer", UFCCSModelLayer)

function ExpansionDungeonDetailLayer.create(nChapterId, nStageId, ...)
	return ExpansionDungeonDetailLayer.new("ui_layout/expansiondungeon_DetailLayer.json", Colors.modelColor, nChapterId, nStageId, ...)
end

function ExpansionDungeonDetailLayer:ctor(json, param, nChapterId, nStageId, ...)
	self._nChapterId = nChapterId or 1
	self._nStageId = nStageId
	self._tStageTmpl = expansion_dungeon_stage_info.get(self._nStageId)
	self._tStage = G_Me.expansionDungeonData:getStageById(self._nChapterId, self._nStageId)
	assert(self._tStage)
	assert(self._tStageTmpl)
	-- 3个目标
	self._tTargetList = {}

	self._imgHead = nil

	self.super.ctor(self, json, param, ...)
end

function ExpansionDungeonDetailLayer:onLayerLoad()
	self:_initView()
	self:_initWidgets()

	self:_setData()
end

function ExpansionDungeonDetailLayer:onLayerEnter()
	self:showAtCenter(true)
	self:closeAtReturn(true)

	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("ImageView_Bg"), "smoving_bounce")
end

function ExpansionDungeonDetailLayer:onLayerExit()
	
end

function ExpansionDungeonDetailLayer:onLayerUnload()
	
end

function ExpansionDungeonDetailLayer:_initView()
	G_GlobalFunc.updateLabel(self, "Label_StageTitle", {stroke=Colors.strokeBrown, size=2})
	G_GlobalFunc.updateLabel(self, "Label_StarAward", {stroke=Colors.strokeBrown})
end

function ExpansionDungeonDetailLayer:_initWidgets()
	self:registerBtnClickEvent("closebtn", handler(self, self._onCloseWindow))
	self:registerBtnClickEvent("Button_Challenge", handler(self, self._onChallenge))
	self:registerBtnClickEvent("Button_Lineup", handler(self, self._onLineup))
end

function ExpansionDungeonDetailLayer:_onCloseWindow()
	self:animationToClose()
end

function ExpansionDungeonDetailLayer:_onChallenge()
	local nStar = G_Me.expansionDungeonData:getStageStarNum(self._tStage)
	if nStar < 3 then
		if G_Me.userData.vit >= self._tStageTmpl.expend_size then
			local isPassTotalChapter = G_Me.expansionDungeonData:isPassTotalChapter()
			G_Me.expansionDungeonData:setPassTotalChapterState(isPassTotalChapter, nil)

			G_HandlersManager.expansionDungeonHandler:sendExcuteExpansiveDungeonStage(self._nStageId)
			self:close()
		else
			G_GlobalFunc.showPurchasePowerDialog(1)
		end
	else
		G_MovingTip:showMovingTip(G_lang:get("LANG_EX_DUNGEON_THREE_STAR_ALREADY"))
	end
end

function ExpansionDungeonDetailLayer:_onLineup()
	require("app.scenes.hero.HerobuZhengLayer").showBuZhengLayer()
end

function ExpansionDungeonDetailLayer:_setData()
	-- stage名字
	G_GlobalFunc.updateLabel(self, "Label_StageTitle", {text=self._tStageTmpl.name})

	if not self._imgHead then
		local panel = self:getPanelByName("Panel_Hero")
		panel:setScale(0.8)
		self._imgHead = KnightPic.createKnightPic(self._tStageTmpl.icon, panel, "head", true)
	end

	if self._tStage._nMaxFV ~= 0 then
		-- 最强通关
		G_GlobalFunc.updateLabel(self, "Label_Best_Name", {text=self._tStage._szMaxName})
		G_GlobalFunc.updateLabel(self, "Label_Best_FightValue", {text=G_lang:get("LANG_EX_DUNGEON_FIGHT_VALUE")..G_GlobalFunc.ConvertNumToCharacter(self._tStage._nMaxFV)})
	else
		G_GlobalFunc.updateLabel(self, "Label_Best_Name", {text=G_lang:get("LANG_REBEL_BOSS_WAITING_FOR_YOU")})
		G_GlobalFunc.updateLabel(self, "Label_Best_FightValue", {text=""})
	end

	if self._tStage._nMinFV ~= 0 then
		-- 极限通关
		G_GlobalFunc.updateLabel(self, "Label_Extre_Name", {text=self._tStage._szMinName})
		G_GlobalFunc.updateLabel(self, "Label_Extre_FightValue", {text=G_lang:get("LANG_EX_DUNGEON_FIGHT_VALUE")..G_GlobalFunc.ConvertNumToCharacter(self._tStage._nMinFV)})
	else
		G_GlobalFunc.updateLabel(self, "Label_Extre_Name", {text=G_lang:get("LANG_REBEL_BOSS_WAITING_FOR_YOU")})
		G_GlobalFunc.updateLabel(self, "Label_Extre_FightValue", {text=""})
	end

	-- 经验
	local tRoleTmpl = role_info.get(G_Me.userData.level)
	assert(tRoleTmpl)
	local nExp = math.floor(self._tStageTmpl.expend_size / 5) * tRoleTmpl.pve_exp
	local szExpAdd = G_Me.userData:getExpAdd(nExp)
	G_GlobalFunc.updateLabel(self, "Label_Exp_Value", {text=nExp})
	G_GlobalFunc.updateLabel(self, "Label_Exp_Value_Add", {text=szExpAdd})

	-- 3个目标
	for i=1, 3 do
		self:_setAward(i)
	end

	self:_updateStarNum()

	self:_updateExpand()
end

function ExpansionDungeonDetailLayer:_updateStarNum()
	local nStar = G_Me.expansionDungeonData:getStageStarNum(self._tStage)
	for i=1, 3 do
		self:showWidgetByName("Image_Light_Star"..i, nStar >= i)
	end
end

-- 消耗的物品
function ExpansionDungeonDetailLayer:_updateExpand()
	local nType = self._tStageTmpl.expend_type
	local nValue = self._tStageTmpl.expend_value
	local nSize = self._tStageTmpl.expend_size

	local szStr = ""
	if nType == 7 then -- 体力
		szStr = G_lang:get("LANG_EX_DUNGEON_EXCUTE_EXPAND", {num=nSize})
	end
	G_GlobalFunc.updateLabel(self, "Label_Expand", {text=szStr})

end

function ExpansionDungeonDetailLayer:_setAward(nIndex)
	if type(nIndex) ~= "number" then
		assert(false, "nIndex should be a number")
	end
	if nIndex < 1 or nIndex > 3 then
		assert(false, "error nIndex = %d", nIndex)
	end
	local isReached	= self._tStage["_bTarget"..nIndex]


	self:showWidgetByName(string.format("Image_TargetStarLight%d", nIndex), isReached)
	G_GlobalFunc.updateLabel(self, "Label_Target"..nIndex, {text=self._tStageTmpl["target_description_"..nIndex]})

	local nType = self._tStageTmpl["reward_type_"..nIndex]
	local nValue = self._tStageTmpl["reward_value_"..nIndex]
	local nSize = self._tStageTmpl["reward_size_"..nIndex]

	local tGoods = G_Goods.convert(nType, nValue, nSize)
	if tGoods then
		G_GlobalFunc.updateImageView(self, string.format("Image_AwardIcon%d", nIndex), {texture=tGoods.icon, texType=UI_TEX_TYPE_LOCAL})
		G_GlobalFunc.updateImageView(self, string.format("Image_ColorBg%d", nIndex), {texture=G_Path.getEquipIconBack(tGoods.quality), texType=UI_TEX_TYPE_PLIST})
		G_GlobalFunc.updateImageView(self, string.format("Image_QualityFrame%d", nIndex), {texture=G_Path.getEquipColorImage(tGoods.quality), texType=UI_TEX_TYPE_PLIST})
		G_GlobalFunc.updateLabel(self, string.format("Label_Num%d", nIndex), {text="x"..G_GlobalFunc.ConvertNumToCharacter2(tGoods.size), stroke=Colors.strokeBrown})
		G_GlobalFunc.updateImageView(self, string.format("Image_Mark%d", nIndex), {visible=isReached})

		self:registerWidgetClickEvent(string.format("Image_QualityFrame%d", nIndex), function()
			if type(nType) == "number" and type(nValue) == "number" then
		    	require("app.scenes.common.dropinfo.DropInfo").show(nType, nValue)
			end
		end)
	end
end


return ExpansionDungeonDetailLayer