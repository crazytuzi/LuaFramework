-- GroupBuyRankAwardCell.lua

require("app.scenes.groupbuy.GroupBuyCommon")
local GroupBuyConst = require("app.const.GroupBuyConst")

local math = math
local table = table

local GroupBuyRankAwardCell = class("GroupBuyRankAwardCell", UFCCSNormalLayer)

function GroupBuyRankAwardCell.create(type, ... )
	local layer = GroupBuyRankAwardCell.new("ui_layout/groupbuy_RankAwardCell.json", ...)
	layer:init(type)
	return layer
end

function GroupBuyRankAwardCell:ctor( ... )
	self.super.ctor(self, ...)

	self._titleLabel = self:getLabelByName("Label_Title")
	self._listView = nil

end

function GroupBuyRankAwardCell:init(type)
	self._type = type
	if self._type == GroupBuyConst.RANK_AWARD_TYPE.NORMAL then
		self._titleLabel:setText(G_lang:get("LANG_GROUP_BUY_RANK_AWARD_NORMAL"))
	elseif self._type == GroupBuyConst.RANK_AWARD_TYPE.LUXURY then
		self._titleLabel:setText(G_lang:get("LANG_GROUP_BUY_RANK_AWARD_LUXURY"))
	end
	self._titleLabel:createStroke(Colors.strokeBrown, 1)
	self:_initListView()
end

function GroupBuyRankAwardCell:_initListView()
	local prize = self:_getPrizeData()
	self._listView = CCSListViewEx:createWithPanel(self:getPanelByName("Panel_Content"), LISTVIEW_DIR_VERTICAL)
	self._listView:setCreateCellHandler(function ( list, index)
            return require("app.scenes.groupbuy.GroupBuyRankAwardTextCell").new(list, index, 1)
        end)
        self._listView:setUpdateCellHandler(function ( list, index, cell)
            if  index < #prize/2 then
               cell:updateData(list, index, prize[index + 1]) 
            end
        end)
        self._listView:initChildWithDataLength(math.ceil(#prize/2))
end

function GroupBuyRankAwardCell:_getPrizeData()
    local prizeList = {}
    for i = 1 , wheel_prize_info.getLength() do 
        local info = wheel_prize_info.indexOf(i)
        if info.event_type == GroupBuyConst.RANK_AWARD_TEMP_ID and info.type == self._type then
            table.insert(prizeList, info)
        end
    end
    return prizeList
end

return GroupBuyRankAwardCell