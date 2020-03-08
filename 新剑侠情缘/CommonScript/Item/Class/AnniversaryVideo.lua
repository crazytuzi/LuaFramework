local tbItem = Item:GetClass("AnniversaryVideo")
function tbItem:OnClientUse()
	Pandora:OpenVideo(7)
end
