
local ITEM_CLASS = "FurnitureItem";
local tbItem = Item:GetClass(ITEM_CLASS);

function tbItem:OnUse(it)
	local tbFurniture = House:GetFurnitureInfo(it.dwTemplateId);
	if not tbFurniture then
		me.CenterMsg("异常道具");
		return;
	end
	if me.nHouseState ~= 1 then
		me.MsgBox("你还没有家园，传闻[FFFE0D]颖宝宝[-]处可打探到相关信息。",
		{
			{"现在就去", function () me.CallClientScript("Ui.HyperTextHandle:Handle", "[url=npc:testtt,2279,10]", 0, 0); end},
			{"等会儿吧"}
		});
		me.CallClientScript("Ui:CloseWindow", "QuickUseItem");
		return;
	end

	me.CenterMsg("成功放入到家具仓库中", true);
	Furniture:Add(me, it.dwTemplateId);
	--House:SetExpireTime(me, it.dwTemplateId)
	return 1;
end

function tbItem:GetTip(it)
	local tbFurniture = House:GetFurnitureInfo(it.dwTemplateId);
	if not tbFurniture then
		return "";
	end

	local szPutType = "室内、庭院";
	if tbFurniture.nIsHouse == 1 then
		szPutType = "室内";
	elseif tbFurniture.nIsHouse == 0 then
		szPutType = "庭院";
	end

	return string.format([[等级：%s
舒适度：%s
家具类型：%s
摆放位置：%s]], tbFurniture.nLevel, tbFurniture.nComfortValue, Furniture:GetTypeName(tbFurniture.nType), szPutType);
end

function tbItem:GetUseSetting(nItemTemplateId, nItemId)
	if not House.bHasHouse then
		return {
					szFirstName = "放入家具仓库",
					fnFirst = function ()
								Ui:CloseWindow("ItemTips");
								Ui:CloseWindow("ItemBox");

								me.MsgBox("你还没有家园，传闻[FFFE0D]颖宝宝[-]处可打探到相关信息。",
									{
										{"现在就去", function () Ui.HyperTextHandle:Handle("[url=npc:testtt,2279,10]", 0, 0); end},
										{"等会儿吧"}
									});
								end
				};
	end
	if not nItemId or nItemId <= 0 then
		if Ui:WindowVisible("HouseDecorationPanel") and not Ui:WindowVisible("HouseComfortableDetailsPanle") then
			local tbOpt = {};
			if Furniture:CanSell(nItemTemplateId) then
				table.insert(tbOpt, { szName = "出售", fnClick = function ()
					Shop:SellFakeItem("Furniture", nItemTemplateId, House.tbFurniture[nItemTemplateId]);
				end });
			end

			local _, x, y = me.GetWorldPos();
			local bCanPut = House:CheckCanPutFurnitureCommon(me.nMapTemplateId, x, y, 0, nItemTemplateId);
			if bCanPut then
				table.insert(tbOpt, { szName = "摆放", fnClick = function ( ... )
					UiNotify.OnNotify(UiNotify.emNOTIFY_PUT_DECORATION, nItemTemplateId);
					Ui:CloseWindow("ItemTips");
				end});
			end

			if #tbOpt == 0 then
				return {};
			end

			local tbParam = { bForceShow = true};
			if tbOpt[1] then
				tbParam.szFirstName = tbOpt[1].szName;
				tbParam.fnFirst = tbOpt[1].fnClick;
			end

			if tbOpt[2] then
				tbParam.szSecondName = tbOpt[2].szName;
				tbParam.fnSecond = tbOpt[2].fnClick;
			end

			return tbParam;
		end
		return {};
	end

	local pItem = me.GetItemInBag(nItemId);
	if not pItem then
		return {};
	end

	return {szFirstName = "放入家具仓库", fnFirst = "UseItem"};
end
