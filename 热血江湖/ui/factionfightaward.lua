module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------
wnd_factionFightAward = i3k_class("wnd_factionFightAward", ui.wnd_base)

local LXJLT = "ui/widgets/lxjlt"

function wnd_factionFightAward:ctor()
end

function wnd_factionFightAward:showTab(index)
    self.scroll:removeAllChildren()

    for i, v in ipairs(self.tabs) do
        if i == index then
            v:stateToPressed()
        else
            v:stateToNormal()
        end
    end

    local setItem = function(i,id,count,item)
        item["root" .. i]:setImage(
            g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id)
        )
        item["icon" .. i]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id))
        item["lock" .. i]:setVisible(id > 0)
        item["btn" .. i]:onClick(self, function ()
            g_i3k_ui_mgr:ShowCommonItemInfo(id)
        end)
        if math.abs(id) == g_BASE_ITEM_COIN then
            if count >= 10000 then
                item["countLabel" .. i]:setText(
                    string.format("x%s万", math.floor(count / 10000))
                )
            else
                item["countLabel" .. i]:setText(string.format("x%s", count))
            end
        else
            item["countLabel" .. i]:setText(string.format("x%s", count))
        end
    end

    if index == 1 then
        local lastRank = 1
        for i, v in ipairs(i3k_db_faction_fight_cfg.rankAward) do
            local nodeIndex = 1
            local node = require("ui/widgets/lxjlt")()
            self.scroll:addItem(node)
            node.vars.rankImg:hide()
            local rank = v.rank
            if rank - lastRank > 1 then
                node.vars.rankLabel:setText("第" .. lastRank + 1 .. "-" .. rank .. "名")
            else
                node.vars.rankLabel:setText("第" .. rank .. "名")
            end

            lastRank = rank
            if v.leaderAwardId ~= 0 then
                node.vars.leader:setVisible(true)
                setItem(nodeIndex,v.leaderAwardId,v.leaderAwardNum,node.vars)
                nodeIndex = nodeIndex + 1
            end

            for index = 1, 5, 1 do
				if nodeIndex > 5 then
					break
				end
				local items = v.memberAward[index]
				if items then
					node.vars["root" .. nodeIndex]:setVisible(true)
					setItem(nodeIndex, items.id, items.count, node.vars)
                nodeIndex = nodeIndex + 1
				else
					node.vars["root" .. nodeIndex]:setVisible(false)
				end
            end

            for i=nodeIndex,5,1 do
                node.vars["root" .. i]:setVisible(false)
            end
        end
    else
        for i, v in ipairs(i3k_db_faction_fight_cfg.award) do
            local nodeIndex = 1
            local node = require("ui/widgets/lxjlt")()
            self.scroll:addItem(node)
            node.vars.rankImg:hide()
            node.vars.rankLabel:setText(v.name)

            for index = 1, 5, 1 do
				if nodeIndex > 5 then
					break
				end
				local items = v.award[index]
				if items then
					node.vars["root" .. nodeIndex]:setVisible(true)
					setItem(nodeIndex, items.id, items.count, node.vars)
                nodeIndex = nodeIndex + 1
				else
					node.vars["root" .. nodeIndex]:setVisible(true)
				end
            end

            for i=nodeIndex,5,1 do
                node.vars["root" .. i]:setVisible(false)
            end
        end
    end
end

function wnd_factionFightAward:configure()
    self.ui = self._layout.vars
    self._layout.vars.close_btn:onClick(self, self.onCloseUI)
    self.scroll = self._layout.vars.scroll
    self.tabs = {
        self.ui.personBtn,
        self.ui.factionBtn
    }

    self.ui.tab1Title:setText("排行奖励")
    self.ui.tab2Title:setText("帮战奖励")

    for i, v in ipairs(self.tabs) do
        v:onClick(
            self,
            function()
                self:showTab(i)
            end
        )
    end
end

function wnd_factionFightAward:refresh()
	self:showTab(1)
end

function wnd_create(layout)
    local wnd = wnd_factionFightAward.new()
    wnd:create(layout)
    return wnd
end
