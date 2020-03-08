local tbItem = Item:GetClass("LTZItemCar");

function tbItem:GetUseSetting(nItemTemplateId, nItemId)
	LingTuZhan:GetSynKinBattleFightData()
	local tbShowInfo = { 
		bForceShow = true;
		szFirstName = "建造";
		fnFirst = function (  )
			LingTuZhan:BuildSupplyItem( nItemTemplateId )
		end;
		szSecondName = "使用";
		fnSecond = function ( ... )
			LingTuZhan:UseSupplyItem( nItemTemplateId )
		end;
	 }
	 return tbShowInfo
end