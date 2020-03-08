--用来把背包里的最低品质的锦盒重新随机品质的道具
local tbItem = Item:GetClass("BrocadeBoxRerandom")
local tbAct = MODULE_GAMESERVER and Activity:GetClass("BrocadeBoxAct") or Activity.BrocadeBoxAct

function tbItem:OnUse(pItem)
	--寻找背包里最低品质的道具
	local nItemCount = 0
	local tbGetItem = nil
	local tbQualityLevel = {}
	for _, nQualityLevel in pairs(tbAct.tbQuality) do
		table.insert(tbQualityLevel, nQualityLevel)
	end
	table.sort(tbQualityLevel, function (nQ1, nQ2) return nQ1 < nQ2 end)
	for _, nQualityLevel in ipairs(tbQualityLevel) do
		local nItemTId = tbAct:GetItemTIdByQuality(nQualityLevel)
		nItemCount, tbGetItem = me.GetItemCountInBags(nItemTId)
		if nItemCount > 0 then
			break;
		end
	end
	if nItemCount > 0 then
		--弹窗提示玩家是否进行随机
		local pBrocadeBoxItem = tbGetItem[1]
		--获取原锦盒的有效期，随机后继承该有效期
		local nTimeOut = pBrocadeBoxItem.GetTimeOut()
		local nRerandItemId = pItem.dwId
		local nBrocadeBoxItemId = pBrocadeBoxItem.dwId
		local szMsg = string.format("确定将[FFFE0D]%s[-]进行重新随机？", pBrocadeBoxItem.szName)
		me.MsgBox(szMsg, {{"确定", function ()
					local pBrocadeBoxItem = me.GetItemInBag(nBrocadeBoxItemId)
					local pRerandItem = me.GetItemInBag(nRerandItemId)
					if not pBrocadeBoxItem or not pRerandItem then
						me.CenterMsg("道具不存在")
						return
					end
					local nRet = Item:Consume(pBrocadeBoxItem, 1)	--扣除锦盒
					Item:Consume(pRerandItem, 1)					--扣除重随机道具
					if nRet == 1 then
						local nTotalRate = 0
						for _, nRate in pairs(tbAct.tbRerandomRate) do
							nTotalRate = nTotalRate + nRate
						end
						local nRandomRate = MathRandom(1, nTotalRate)
						nTotalRate = 0
						local nRandomQualityLevel = 0
						for nQualityLevel, nRate in pairs(tbAct.tbRerandomRate) do
							nTotalRate = nTotalRate + nRate
							if nRandomRate <= nTotalRate then
								nRandomQualityLevel = nQualityLevel
								break;
							end
						end
						Log("[Re-random BrocadeBox] PlayerId", me.dwID, "RandomValue", nRandomRate)
						local nRandomItemTId = tbAct:GetItemTIdByQuality(nRandomQualityLevel)
						me.SendAward({{"item", nRandomItemTId, 1, nTimeOut}}, true, true, Env.LogWay_BrocadeBoxAct)
					end
				end},{"取消"}})
	else
		me.CenterMsg("找了一圈，您的背包里似乎没有锦盒")
	end
	me.CallClientScript("Ui:CloseWindow", "ItemTips")
end