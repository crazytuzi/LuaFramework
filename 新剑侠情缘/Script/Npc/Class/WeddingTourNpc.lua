
local tbNpc = Npc:GetClass("WeddingTourNpc");

function tbNpc:FormatTalkContent(szContent)
	local tbTourPlayer = Wedding:GetTourPlayer() or {}

	local tbBoyInfo = tbTourPlayer[Gift.Sex.Boy] or {}
	local szBoyName = tbBoyInfo.szName or ""

	local tbGirlInfo = tbTourPlayer[Gift.Sex.Girl] or {}
	local szGirlName = tbGirlInfo.szName or ""
	return string.format(szContent or "", szBoyName or "", szGirlName or "")
end
