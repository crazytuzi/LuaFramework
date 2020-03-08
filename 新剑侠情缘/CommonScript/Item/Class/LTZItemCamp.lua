local tbItem = Item:GetClass("LTZItemCamp");

function tbItem:GetUseSetting(nItemTemplateId, nItemId)
	LingTuZhan:GetSynKinBattleFightData()
	local tbShowInfo = { 
		bForceShow = true;
		szFirstName = "使用";
		fnFirst = function (  )
			LingTuZhan:UseSupplyItem( nItemTemplateId )
		end;
		szSecondName = "前往";
		fnSecond = function ( ... )
			LingTuZhan:QuckGotoCamp()
		end;
	 }
	 return tbShowInfo
end