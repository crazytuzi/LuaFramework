local ArenaRankingListLayer = class("ArenaRankingListLayer",UFCCSModelLayer)

function ArenaRankingListLayer.create(...)
	return ArenaRankingListLayer.new("ui_layout/arena_ArenaRankingListLayer.json",require("app.setting.Colors").modelColor,...)
end
function ArenaRankingListLayer:ctor(json,color,...)
	self._userList = {}
	self.super.ctor(self,...)
	self:_initWidgets()
	self:_initEvents()
	self:_setWidgets(...)
	self:_createStroke()
	self:showAtCenter(true)
	self:setVisible(false)
	G_HandlersManager.arenaHandler:sendRankingList()
end

function ArenaRankingListLayer:_initWidgets()
	-- 当前排行
	self._shengwangLabel = self:getLabelByName("Label_shengwang")
	self._moneyLabel = self:getLabelByName("Label_money")
	self._xilianLabel = self:getLabelByName("Label_xilian")
	self._myRankLabel = self:getLabelByName("Label_myrank")

	-- 目标排行
	self._shengwangLabelNext = self:getLabelByName("Label_shengwang_Next")
	self._moneyLabelNext = self:getLabelByName("Label_money_Next")
	self._xilianLabelNext = self:getLabelByName("Label_xilian_Next")
	self._myRankLabelNext = self:getLabelByName("Label_myrank_Next")

end

function ArenaRankingListLayer:_setWidgets(rank)
	local AwardConst = require("app.const.AwardConst")
	-- 当前排行
	self._myRankLabel:setText(rank)
	local goods01 = AwardConst.getAwardGoods01(rank)
	local goods02 = AwardConst.getAwardGoods02(rank)
	local goods03 = AwardConst.getAwardGoods03(rank)
	-- 当前排行还未能达到获取奖励的最低标准
	if rank <= AwardConst.getMaxAwardsRank() then   
		self:showWidgetByName("Label_noAwardTips",false)
		self:showWidgetByName("Panel_award",true)
		self:showWidgetByName("Label_awardTag",true)
	else
		self:showWidgetByName("Label_noAwardTips",true)
		self:showWidgetByName("Panel_award",false)
		self:showWidgetByName("Label_awardTag",false)
		self:getLabelByName("Label_noAwardTips"):setText(G_lang:get("LANG_NO_AWARD_TIPS"))
	end
	if type(goods01) == "table" then
	    self._shengwangLabel:setText(G_GlobalFunc.ConvertNumToCharacter3(goods01.size))
	else
	    self._shengwangLabel:setText(0)
	end
	if type(goods02) == "table" then
	    self._moneyLabel:setText(G_GlobalFunc.ConvertNumToCharacter3(goods02.size))
	else
	    self._moneyLabel:setText(0)
	end
	if type(goods03) == "table" then
	    self._xilianLabel:setText(G_GlobalFunc.ConvertNumToCharacter3(goods03.size))
	else
	    self._xilianLabel:setText(0)
	end 

	-- 目标排行
	if rank == 1 then 
		-- 如为第一则不再显示目标排名相关
		self:showWidgetByName("Panel_851", false) 
		local tipsMainPanel = self:getPanelByName("Panel_852")
		-- local oldHeight = tipsMainPanel:getSize().height
		tipsMainPanel:setPositionY(tipsMainPanel:getPositionY() - 25)
	else
		self:showWidgetByName("Label_noAwardTipsNext",false)

		local rankNext = AwardConst.getNextAwardsRank(rank)
		local goods01Next = AwardConst.getAwardGoods01(rankNext)
		local goods02Next = AwardConst.getAwardGoods02(rankNext)
		local goods03Next = AwardConst.getAwardGoods03(rankNext)

		self._myRankLabelNext:setText(rankNext)
		if type(goods01Next) == "table" then
		    self._shengwangLabelNext:setText(G_GlobalFunc.ConvertNumToCharacter3(goods01Next.size))
		else
		    self._shengwangLabelNext:setText(0)
		end
		if type(goods02Next) == "table" then
		    self._moneyLabelNext:setText(G_GlobalFunc.ConvertNumToCharacter3(goods02Next.size))
		else
		    self._moneyLabelNext:setText(0)
		end
		if type(goods03Next) == "table" then
		    self._xilianLabelNext:setText(G_GlobalFunc.ConvertNumToCharacter3(goods03Next.size))
		else
		    self._xilianLabelNext:setText(0)
		end
	end

end

function ArenaRankingListLayer:_createStroke()
	self._myRankLabel:createStroke(Colors.strokeBlack,1)
	self._myRankLabelNext:createStroke(Colors.strokeBlack,1)
end

function ArenaRankingListLayer:_initEvents()
	self:enableAudioEffectByName("Button_ok", false)
	self:registerBtnClickEvent("Button_ok",function() 
		self:animationToClose() 
		local soundConst = require("app.const.SoundConst")
		G_SoundManager:playSound(soundConst.GameSound.BUTTON_SHORT)
		end)
	self:enableAudioEffectByName("Button_close", false)
	self:registerBtnClickEvent("Button_close",function() 
		self:animationToClose() 
		local soundConst = require("app.const.SoundConst")
		G_SoundManager:playSound(soundConst.GameSound.BUTTON_SHORT)
		end)
end

function ArenaRankingListLayer:_getRankingList(data)
	if data.ret == 1 then
		self:setVisible(true)
		for i,v in ipairs(data.user_list) do
			self._userList[i] = v
		end
		if self._listview == nil then
			local panel = self:getPanelByName("Panel_listview")
			self._listview = CCSListViewEx:createWithPanel(panel,LISTVIEW_DIR_VERTICAL)
			self._listview:setCreateCellHandler(function(list,index)
				return require("app.scenes.arena.ArenaRankingListItem").new()
			end)
			self._listview:setUpdateCellHandler(function(list,index,cell) 
				local user = self._userList[index+1]
				cell:update(user)
				cell:setCheckUserInfoFunc(function()
					G_HandlersManager.arenaHandler:sendCheckUserInfo(user.user_id)
					end)
			end)
		end
		-- self._listview:initChildWithDataLength(#self._userList)
		self._listview:reloadWithLength(#self._userList,self._listview:getShowStart())
	end
end

function ArenaRankingListLayer:_onGetUserInfo(data)
	if data.ret == 1 then
		if data.user == nil or data.user.knights == nil or #data.user.knights == 0 then
			G_MovingTip:showMovingTip(G_lang:get("LANG_SERVER_DATA_EXCEPTION"))
			return
		end
		local layer = require("app.scenes.arena.ArenaZhenrong").create(data.user)
		uf_sceneManager:getCurScene():addChild(layer)
	end
end

function ArenaRankingListLayer:onLayerEnter()
	self:closeAtReturn(true)
	require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ARENA_RANKING_LIST, self._getRankingList, self) 
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ARENA_USER_INFO, self._onGetUserInfo, self) 
end
function ArenaRankingListLayer:onLayerExit()
	uf_eventManager:removeListenerWithTarget(self)
end

return ArenaRankingListLayer