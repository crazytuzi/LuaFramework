--锦盒道具
local tbItem = Item:GetClass("BrocadeBox")
local tbAct = MODULE_GAMESERVER and Activity:GetClass("BrocadeBoxAct") or Activity.BrocadeBoxAct

function tbItem:GetUseSetting(nTemplateId, nItemId)
	return {
		szFirstName = "放置",
		fnFirst = function ()
					RemoteServer.BrocadeBoxActCall("TryUseBoxItem", nTemplateId, nItemId)
				end
	}
end