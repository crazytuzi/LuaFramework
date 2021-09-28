local ALIGN_CENTER = "align_center"
local ALIGN_LEFT = "align_left"
local ALIGN_RIGHT = "align_right"


require("app.cfg.contest_rank_award_info")
require("app.cfg.contest_points_buff_info")
local MoShenConst = require("app.const.MoShenConst")
local CommonFunc = require("app.scenes.moshen.rebelboss.RebelBossCommonFunc")

local RebelBossRankListLayer = class("RebelBossRankListLayer", UFCCSModelLayer)

function RebelBossRankListLayer.create(nMode, ...)
	return RebelBossRankListLayer.new("ui_layout/moshen_RebelBossRankListLayer.json", Colors.modelColor, nMode, ...)
end

function RebelBossRankListLayer:ctor(json, param, nMode, ...)
	self.super.ctor(self, json, param, ...)
	self._tRankListView = nil
	self._tAwardListView = nil
	self._tPrevSelectBtn = nil

	self._nMode = nMode or MoShenConst.REBEL_BOSS_RANK_MODE.HONOR
	self._nSelfGroup = G_Me.moshenData:getMyGroup()
	self._nCurGroup = (self._nSelfGroup ~= 0) and self._nSelfGroup or MoShenConst.GROUP.WEI

	self:_initWidgets()
end

function RebelBossRankListLayer:onLayerEnter()
	self:showAtCenter(true)
	self:closeAtReturn(true)

	-- 每切换一次阵营，就要重新拉取一次排行
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_REBEL_BOSS_GET_HONOR_RANK, self._reloadRankList, self)
	-- 玩家的阵容
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ARENA_USER_INFO, self._onGetUserInfo, self)
	

	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("Image_BkgPanel"), "smoving_bounce")
end

function RebelBossRankListLayer:onLayerExit()

end

function RebelBossRankListLayer:_initWidgets()
	
	self:_initRankListView()
	self:_initAwardListView()

	CommonFunc._updateLabel(self, "Label_AwardTip", {text=G_lang:get("LANG_REBEL_BOSS_AWARD_TIP"), stroke=Colors.strokeBrown})

	self:registerBtnClickEvent("Button_Close", handler(self, self._onClose))
	self:registerBtnClickEvent("Button_Close_TopRight", handler(self, self._onClose))
	self:registerBtnClickEvent("Button_RankAward", handler(self, self._onClickAward))
	for i=1, 4 do
		local btnGroup = self:getButtonByName("Button_Group_" .. i)
		if btnGroup then
			btnGroup:setTag(i)
		end
		self:registerBtnClickEvent("Button_Group_" .. i, handler(self, self._onClickGroup))
	end

	self:_onClickGroup(self:getWidgetByName("Button_Group_" .. self._nCurGroup))
end

-- 4个阵营列表
function RebelBossRankListLayer:_initRankListView()
	if not self._tRankListView then
		local panel = self:getPanelByName("Panel_RankList")
		self._tRankListView = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
		
		self._tRankListView:setCreateCellHandler(function(list, index)
			local RankItem = require("app.scenes.moshen.rebelboss.RebelBossRankItem")
			return RankItem.new(self._nMode)
		end)

		self._tRankListView:setUpdateCellHandler(function(list, index, cell)
			local tRankList = G_Me.moshenData:getRankList(self._nMode, self._nCurGroup) or {}
			local tRankItem = tRankList[index + 1]
			cell:updateItem(tRankItem)
		end)
	end

	self._tRankListView:setVisible(false)
end

-- 奖励列表
function RebelBossRankListLayer:_initAwardListView()
	if not self._tAwardListView then
		local panel = self:getPanelByName("Panel_AwardList")
		self._tAwardListView = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)

		self._tAwardListView:setCreateCellHandler(function(list, index)
			local AwardItem = require("app.scenes.moshen.rebelboss.RebelBossRankAwardItem")
			return AwardItem.new(self._nMode)
		end)

		self._tAwardListView:setUpdateCellHandler(function(list, index, cell)
			cell:updateItem(index + 1)
		end)
	end

	self._tAwardListView:reloadWithLength(rebel_boss_rank_info.getLength()/2, self._tAwardListView:getShowStart())
end

function RebelBossRankListLayer:_onClose()
	self:animationToClose()
end

-- 切换阵营
function RebelBossRankListLayer:_onClickGroup(sender)
	self:showWidgetByName("Panel_Rank", true)	
	self:showWidgetByName("Panel_RankAwards", false)	

	self._nCurGroup = sender:getTag()
	if self._tPrevSelectBtn then
		self._tPrevSelectBtn:setTouchEnabled(true)
	end
	sender:setTouchEnabled(false)
	self._tPrevSelectBtn = sender

	-- 发送协议
	G_HandlersManager.moshenHandler:sendRebelBossRank(self._nMode, self._nCurGroup)
end

-- 切换到奖励列表
function RebelBossRankListLayer:_onClickAward(sender)
	self:showWidgetByName("Panel_Rank", false)	
	self:showWidgetByName("Panel_RankAwards", true)	

	if self._tPrevSelectBtn then
		self._tPrevSelectBtn:setTouchEnabled(true)
		self._tPrevSelectBtn = nil
	end

	self:_initMyAwardInfo()
end

-- reload rank list
function RebelBossRankListLayer:_reloadRankList()
	local tRankList = G_Me.moshenData:getRankList(self._nMode, self._nCurGroup)
	local len = table.nums(tRankList)
	self._tRankListView:setVisible(true)
	self._tRankListView:reloadWithLength(len)

	-- 没有人上榜，显示一个tips
	self:showWidgetByName("Label_NoRankList", len == 0)
	if len == 0 then
		local groupName = rebel_boss_buff_info.get(self._nCurGroup).name
		local tip = G_lang:get("LANG_REBEL_BOSS_NO_RANK_LIST", {group = groupName})
		self:showTextWithLabel("Label_NoRankList", tip)
	end

	local tTmpl = rebel_boss_buff_info.get(self._nCurGroup)
	CommonFunc._updateLabel(self, "Label_GroupDesc", {text=tTmpl.tips})

	self:_initMyRankInfo()
end

function RebelBossRankListLayer:_initMyRankInfo()
	-- 显示自己的信息
	local tMyRankInfo = G_Me.moshenData:getMyRankInfo()
	local nMyRank = tMyRankInfo._nRank or 0
	local nMyGroup = tMyRankInfo._nGroup or 0
	local nValue = tMyRankInfo._nValue or 0
	CommonFunc._updateLabel(self, "Label_MyRank", {text=G_lang:get("LANG_REBEL_BOSS_MY_RANK")})
	if nMyRank == 0 then
		CommonFunc._updateLabel(self, "Label_MyRankValue", {text=G_lang:get("LANG_REBEL_BOSS_NOT_ON_RANK_1")})
	else
		CommonFunc._updateLabel(self, "Label_MyRankValue", {text=G_lang:get("LANG_REBEL_BOSS_RANK_NUMBER1", {num=nMyRank}) .. "(" .. G_Path.getGroupName(nMyGroup) .. ")"})
	end

	local szDesc = ""
	if self._nMode == MoShenConst.REBEL_BOSS_RANK_MODE.HONOR then
		szDesc = G_lang:get("LANG_REBEL_BOSS_TOTAL_HONOR")
	else
		szDesc = G_lang:get("LANG_REBEL_BOSS_MAX_HURT")
	end
	CommonFunc._updateLabel(self, "Label_MaxHarm", {text=szDesc})
	CommonFunc._updateLabel(self, "Label_MaxHarmValue", {text=G_GlobalFunc.ConvertNumToCharacter(nValue)})

	local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
        self:getLabelByName('Label_MyRank'),
        self:getLabelByName('Label_MyRankValue'),
    }, "L")
    self:getLabelByName('Label_MyRank'):setPositionXY(alignFunc(1))
    self:getLabelByName('Label_MyRankValue'):setPositionXY(alignFunc(2))

    local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
        self:getLabelByName('Label_MaxHarm'),
        self:getLabelByName('Label_MaxHarmValue'),
    }, "R")
    self:getLabelByName('Label_MaxHarm'):setPositionXY(alignFunc(1))
    self:getLabelByName('Label_MaxHarmValue'):setPositionXY(alignFunc(2))


    -- 更新主界面上自己的荣誉值及排行，最大伤害值及排行
    if nMyGroup == self._nCurGroup then
	    if self._nMode == MoShenConst.REBEL_BOSS_RANK_MODE.HONOR then
			uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_REBEL_BOSS_UPDATE_MY_HONOR, nil, false, nMyRank, nValue)
		elseif self._nMode == MoShenConst.REBEL_BOSS_RANK_MODE.MAX_HARM then
			uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_REBEL_BOSS_UPDATE_MY_MAXHARM, nil, false, nMyRank, nValue)
		end
	end
end

function RebelBossRankListLayer:_initMyAwardInfo()
	-- 我的排名奖励
	local tMyRankInfo = G_Me.moshenData:getMyRankInfo()
	local nMyRank = tMyRankInfo._nRank or 0
	local nMyGroup = tMyRankInfo._nGroup or 0

	if nMyRank <= rebel_boss_rank_info.getLength()/2 and nMyRank > 0 then
		CommonFunc._updateLabel(self, "Label_AwardMyRank", {text=G_lang:get("LANG_REBEL_BOSS_MY_RANK")})
		CommonFunc._updateLabel(self, "Label_AwardMyRankValue", {text=G_lang:get("LANG_REBEL_BOSS_RANK_NUMBER1", {num=nMyRank}) .. "(" .. G_Path.getGroupName(nMyGroup) .. ")"})

		self:showWidgetByName("Panel_MyAward", true)
		local tAwardTmpl = nil
		for i=1, rebel_boss_rank_info.getLength() do
			local tTmpl = rebel_boss_rank_info.indexOf(i)
			if tTmpl and tTmpl.type == self._nMode and tTmpl.rank_min == nMyRank then
				tAwardTmpl = tTmpl
			end
		end

		if tAwardTmpl then
			for i=1, 3 do
				local nType = tAwardTmpl["award_type" .. i]
				local nValue = tAwardTmpl["award_value" .. i]
				local nSize = tAwardTmpl["award_size" .. i]
			    local tGoods = G_Goods.convert(nType, nValue, nSize)
				self:_initGoods(i, tGoods)
			end
		end
	else
		-- 未止榜
		CommonFunc._updateLabel(self, "Label_AwardMyRank", {text=G_lang:get("LANG_REBEL_BOSS_MY_RANK")})
		CommonFunc._updateLabel(self, "Label_AwardMyRankValue", {text=G_lang:get("LANG_REBEL_BOSS_NOT_ON_RANK")})

		self:showWidgetByName("Panel_MyAward", false)
	end

    local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
        self:getLabelByName('Label_AwardMyRank'),
        self:getLabelByName('Label_AwardMyRankValue'),
    }, "L")
    self:getLabelByName('Label_AwardMyRank'):setPositionXY(alignFunc(1))
    self:getLabelByName('Label_AwardMyRankValue'):setPositionXY(alignFunc(2))   
end

function RebelBossRankListLayer:_initGoods(nIndex, tGoods)
	local imgBg = self:getImageViewByName("Image_MyAward" .. nIndex)
	if not tGoods then
		imgBg:setVisible(false)
	else
		imgBg:loadTexture(G_Path.getEquipIconBack(tGoods.quality))
		-- 掉落物品的品质框
		local btnQulaity = self:getButtonByName("Button_MyQualityFrame" .. nIndex)
		btnQulaity:loadTextureNormal(G_Path.getEquipColorImage(tGoods.quality, tGoods.type))
		btnQulaity:setTag(nIndex)
		btnQulaity._nType = tGoods.type
		btnQulaity._nValue= tGoods.value
		-- 掉落数量 
		local labelDropNum = self:getLabelByName("Label_MyAwardNum" .. nIndex)
		if labelDropNum then
			labelDropNum:setText("x".. tGoods.size)
			labelDropNum:createStroke(Colors.strokeBrown,1)
		end
		-- 掉落的物品icon
		local imgIcon = self:getImageViewByName("Image_MyAwardIcon" .. nIndex)
		if imgIcon then
			imgIcon:loadTexture(tGoods.icon)
		end
		-- 绑定点击事件
		self:registerBtnClickEvent("Button_MyQualityFrame" .. nIndex, handler(self, self._onClickAwardItem))
	end
end

function RebelBossRankListLayer:_onClickAwardItem(sender)
	local nType = sender._nType
	local nValue = sender._nValue
    G_SoundManager:playSound(require("app.const.SoundConst").GameSound.BUTTON_SHORT)
	require("app.scenes.common.dropinfo.DropInfo").show(nType, nValue)
end

function RebelBossRankListLayer:_onGetUserInfo(data)
	if data.ret == 1 then
		if data.user == nil or data.user.knights == nil or #data.user.knights == 0 then
			G_MovingTip:showMovingTip(G_lang:get("LANG_SERVER_DATA_EXCEPTION"))
			return
		end
		local layer = require("app.scenes.arena.ArenaZhenrong").create(data.user)
		uf_sceneManager:getCurScene():addChild(layer)
	end
end

return RebelBossRankListLayer