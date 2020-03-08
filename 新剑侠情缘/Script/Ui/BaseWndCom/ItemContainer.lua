
local tbCont = Ui:CreateClass("ItemContainer");

function tbCont:SetItem(nIdx, nItemId, fnClick, szUi, tbGridParams, szHighlightAni, szHighlightAniAtlas)
	local tbItemGrid = self["item"..nIdx]
	if tbItemGrid then
		tbItemGrid:SetItem(nItemId, tbGridParams, nil, szHighlightAni, szHighlightAniAtlas)
		tbItemGrid.szItemOpt = szUi
		tbItemGrid.fnClick = fnClick or tbItemGrid.DefaultClick;
	end
end

function tbCont:Update(nIdx)
	local tbItemGrid = self["item"..nIdx]
	if tbItemGrid then
		tbItemGrid:Update()
	end
end

function tbCont:GetGrid(nIdx)
	return self["item"..nIdx]
end





