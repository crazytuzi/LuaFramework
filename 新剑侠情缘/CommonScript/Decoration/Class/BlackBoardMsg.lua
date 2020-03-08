
local tbBlackBoardMsg = Decoration:GetClass("BlackBoardMsg");

function tbBlackBoardMsg:OnRepObjSimpleTap(nId, nRepId, tbRepInfo)
	local tbTemplate = Decoration.tbAllTemplate[tbRepInfo.nTemplateId];
	if not tbTemplate or not tbTemplate.szBlackBoardMsg or tbTemplate.szBlackBoardMsg == "" then
		return;
	end

	me.SendBlackBoardMsg(tbTemplate.szBlackBoardMsg);
end