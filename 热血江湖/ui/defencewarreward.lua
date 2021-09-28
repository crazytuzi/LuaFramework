-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
wnd_defenceWarReward = i3k_class("wnd_defenceWarReward", ui.wnd_base)

-- 城战奖励
-- [eUIID_DefenceWarReward]	= {name = "defenceWarReward", layout = "chengzhanjl", order = eUIO_TOP_MOST,},
-------------------------------------------------------

function wnd_defenceWarReward:ctor()

end

function wnd_defenceWarReward:configure()
	self._defaultSelectID = 1
	self:setButtons()
end

function wnd_defenceWarReward:refresh(mapValue)
	self._kings = mapValue
	self:setScrolls()
end

function wnd_defenceWarReward:onUpdate(dTime)

end

function wnd_defenceWarReward:onShow()
	self:setRewardUI()
end

function wnd_defenceWarReward:onHide()

end

function wnd_defenceWarReward:setButtons()
	local widgets = self._layout.vars
	widgets.Reward:onClick(self, self.onRewardBtn) -- 城池特产
	widgets.Score:onClick(self, self.onScoreBtn) -- 积分奖励
	widgets.Close:onClick(self, self.onCloseBtn)
	widgets.Help:onClick(self, self.onHelpBtn)
end

function wnd_defenceWarReward:onRewardBtn(sender)
	self:setRewardUI()
end

function wnd_defenceWarReward:onScoreBtn(sender)
	self:setScoreUI()
end

function wnd_defenceWarReward:onCloseBtn(sender)
	self:onCloseUI()
end

function wnd_defenceWarReward:onHelpBtn(sender)
	g_i3k_ui_mgr:ShowHelp("帮助信息")
end

-- 城池特产
function wnd_defenceWarReward:setRewardUI()
	local widgets = self._layout.vars
	widgets.Reward:stateToPressed()
	widgets.Score:stateToNormal()
	widgets.ScoreRoot:hide()
	widgets.RewardRoot:show()
end

-- 积分奖励
function wnd_defenceWarReward:setScoreUI()
	local widgets = self._layout.vars
	widgets.Reward:stateToNormal()
	widgets.Score:stateToPressed()
	widgets.ScoreRoot:show()
	widgets.RewardRoot:hide()
end



function wnd_defenceWarReward:setScrolls()
	local widgets = self._layout.vars
	local citys = i3k_db_defenceWar_city
	self:setScroll_cityScroll(citys)
	self:setCityInfo(self._defaultSelectID)
	local rewards = i3k_db_defenceWar_reward.captureStageReward
	self:setScroll_reward(rewards)
end

function wnd_defenceWarReward:setCityInfo(id)
	local cityCfg = i3k_db_defenceWar_city[id]
	local rewards = cityCfg.captureReward
	self:setScroll_rewardScroll(rewards)
	local timeLength = i3k_db_defenceWar_cfg.bless.blessSecond
	local text = string.format(cityCfg.fuli, cityCfg.storeDiscount / 1000, timeLength / 3600)
	self:setFuliText(text)
	-- self:setScroll_fuliScroll( {} )

	self:setLabels(id)
end

function wnd_defenceWarReward:setFuliText(text)
	local widgets = self._layout.vars
	widgets.fuliText:setText(text)
end

-- TODO
-- function wnd_defenceWarReward:setScroll_fuliScroll(list)
-- 	local widgets = self._layout.vars
-- 	local scroll = widgets.fuliScroll
-- 	scroll:removeAllChildren()
-- 	for k, v in ipairs(list) do
-- 		local ui = require("ui/widgets/chengzhanjlt1")()
-- 		ui.vars.text:setText()
-- 		scroll:addItem(ui)
-- 	end
-- end


-- TODO
function wnd_defenceWarReward:setScroll_cityScroll(list)
	local widgets = self._layout.vars
	local scroll = widgets.cityScroll
	scroll:removeAllChildren()
	for k, v in ipairs(list) do
		local ui = require("ui/widgets/chengzhanjlt2")()
		ui.vars.CityImg:setImage(g_i3k_db.i3k_db_get_icon_path(v.iconBattle))
		ui.vars.CityName:setText(v.name)
		ui.vars.City:onClick(self, self.onCityBtn, k)
		ui.vars.selectImg:setVisible(k == self._defaultSelectID)
		scroll:addItem(ui)
	end
end


-- TODO
function wnd_defenceWarReward:setScroll_rewardScroll(list)
	local widgets = self._layout.vars
	local scroll = widgets.rewardScroll
	scroll:removeAllChildren()
	for k, v in ipairs(list) do
		local ui = require("ui/widgets/chengzhanjlt3")()
		local itemID = v.id
		local count = v.count
		ui.vars.bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemID))
		ui.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemID, g_i3k_game_context:IsFemaleRole()))
		ui.vars.lock:setVisible(itemID > 0)
		ui.vars.count:setText("x"..count)
		ui.vars.Item:onClick(self, self.onItem, itemID)
		scroll:addItem(ui)
	end
end


-- TODO 修改下导表
function wnd_defenceWarReward:setScroll_reward(list)
	local widgets = self._layout.vars
	local scroll = widgets.reward
	scroll:removeAllChildren()
	local next = 0
	for k, v in ipairs(list) do
		local ui = require("ui/widgets/chengzhanjlt4")()
		if list[k + 1] then
			next = list[k + 1].score - 1
		else
			next = nil
		end
		local scoreText = v.score.."~"..(next and next or "更多")
		ui.vars.score:setText(scoreText)

		for i = 1, 6 do
			local itemCfg = v.rewards[i]
			local itemID = itemCfg.id
			if itemID ~= 0 then
				ui.vars["bg"..i]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemID))
				ui.vars["icon"..i]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemID, g_i3k_game_context:IsFemaleRole()))
				ui.vars["suo"..i]:setVisible(itemID > 0)
				ui.vars["count"..i]:setText("x"..itemCfg.count)
				ui.vars["btn"..i]:onClick(self, self.onItem, itemID)
			else
				ui.vars["bg"..i]:hide()
			end
		end
		scroll:addItem(ui)
	end
end

function wnd_defenceWarReward:getBelongToStr(sectInfo)
	if not sectInfo then
		return i3k_get_string(5318)
	end
	local chiefServerID = math.floor(sectInfo.chiefId / 1000000)
	return sectInfo.name.."("..chiefServerID.."区)"
end


function wnd_defenceWarReward:setLabels(id)
	local widgets = self._layout.vars
	local cityCfg = i3k_db_defenceWar_city[id]
	--	widgets.RewardLabel:setText("城池特产")
	--	widgets.ScoreLabel:setText("积分奖励")
	--	widgets.belongTo:setText("当前归属：")
	local sectInfo = self._kings[id]
	widgets.serverName:setText(self:getBelongToStr(sectInfo))
	local citySize = g_i3k_db.i3k_db_get_defence_war_city_sizeStr_by_grade(cityCfg.grade)
	widgets.size:setText(citySize)
	widgets.tip4:setText(i3k_get_string(5336))
	widgets.tip3:setText(i3k_get_string(5337))
	widgets.tip1:setText(i3k_get_string(5337))
	--	widgets.tip2:setText("在城战中，参与夺城获得积分，可获得一次性奖励。")
end

function wnd_defenceWarReward:onItem(sender, itemID)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemID)
end

function wnd_defenceWarReward:selectScrollItem(id)
	local widgets = self._layout.vars
	local scroll = widgets.cityScroll
	local children = scroll:getAllChildren()
	for k, v in ipairs(children) do
		v.vars.selectImg:setVisible(id == k)
	end
end

function wnd_defenceWarReward:onCityBtn(sender, index)
	self:selectScrollItem(index)
	self:setCityInfo(index)
end


function wnd_create(layout, ...)
	local wnd = wnd_defenceWarReward.new()
	wnd:create(layout, ...)
	return wnd;
end
