local MoShenRankingAwardItem = class("MoShenRankingAwardItem",function()
	return CCSItemCellBase:create("ui_layout/moshen_MoShenRankingAwardItem.json")
	end)
function MoShenRankingAwardItem:ctor(...)
	self._bgImage = self:getImageViewByName("Image_bg")
	self._label01 = self:getLabelByName("Label_01")
	self._label02 = self:getLabelByName("Label_02")
	self._label03 = self:getLabelByName("Label_03")
	-- self._label01:createStroke(Colors.strokeBrown,1)
	-- self._label02:createStroke(Colors.strokeBrown,1)
	-- self._label03:createStroke(Colors.strokeBrown,1)
end


function MoShenRankingAwardItem:update(index,gongxunAward,shanghaiAward)
	if index%2 == 0 then
		self._bgImage:loadTexture("ui/moshen/paihangjiangli_list1.png")
	else
		self._bgImage:loadTexture("ui/moshen/paihangjiangli_list2.png")
	end
	if gongxunAward.min_rank == gongxunAward.max_rank then
		self._label01:setText(G_lang:get("LANG_ARENA_RANKING",{rank=gongxunAward.min_rank}))
	else
		local text = gongxunAward.min_rank .. "-" .. gongxunAward.max_rank
		self._label01:setText(G_lang:get("LANG_ARENA_RANKING",{rank=text}))
	end

	self._label02:setVisible(gongxunAward ~= nil)
	self._label03:setVisible(shanghaiAward ~= nil)
	if gongxunAward ~= nil then
		self._label02:setText(G_lang:get("LANG_GOODS_JIANG_ZHANG") .. "x" .. gongxunAward.reward_size)
	end
	if shanghaiAward ~= nil then
		self._label03:setText(G_lang:get("LANG_GOODS_JIANG_ZHANG") .. "x" .. shanghaiAward.reward_size)
	end

end

return MoShenRankingAwardItem