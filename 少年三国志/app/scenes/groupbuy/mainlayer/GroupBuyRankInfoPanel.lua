-- GroupBuyRankInfoPanel.lua

local GroupBuyRankInfoPanel = class("GroupBuyRankInfoPanel", UFCCSNormalLayer)

local table = table

function GroupBuyRankInfoPanel.create( ... )
	return GroupBuyRankInfoPanel.new("ui_layout/groupbuy_RankInfoPanel.json", ...)
end

function GroupBuyRankInfoPanel:ctor(...)
	self.super.ctor(self, ...)

	self._nodes = {
		self:getImageViewByName("Image_1"),
		self:getImageViewByName("Image_2"),
		self:getImageViewByName("Image_3"),
	}
	self:setRankInfo()
end

function GroupBuyRankInfoPanel:setRankInfo(infos)
	local function func(lhs, rhs)
		return lhs.sp1 < rhs.sp1
	end
	infos = infos or {}
	table.sort(infos, func)
	for i = 1, #self._nodes do
		local node = self._nodes[i]
		local info = infos[i] or {}
		local nameLabel = UIHelper:seekWidgetByName(node, "Label_Name")
    	nameLabel = tolua.cast(nameLabel,"Label")
    	nameLabel:setText(info.name or "")

    	local descLabel = UIHelper:seekWidgetByName(node, "Label_Desc")
    	descLabel = tolua.cast(descLabel,"Label")
    	descLabel:setText(G_lang:get("LANG_GROUP_BUY_SCORE"))

    	local scoreLabel = UIHelper:seekWidgetByName(node, "Label_Score")
    	scoreLabel = tolua.cast(scoreLabel,"Label")
    	scoreLabel:setText(info.sp2 or "")
	end
	
end

return GroupBuyRankInfoPanel