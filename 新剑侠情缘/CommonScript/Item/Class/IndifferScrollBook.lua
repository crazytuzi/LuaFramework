local tbItem = Item:GetClass("IndifferScrollBook"); --心魔幻境里的秘籍进阶卷轴

function tbItem:GetUseSetting(nTemplateId, nItemId)
    local tbUseSetting = { szFirstName = "出售",  fnFirst = "SellItem", szSecondName = "使用"};
    tbUseSetting.fnSecond = function ()
        Ui:OpenWindow("DreamlandLevelUpPanel","BookUpgrade", nItemId)
        Ui:CloseWindow("ItemTips")
    end;

    return tbUseSetting;        
end

function tbItem:CheckUsable(it)
	local tbSkillBook = Item:GetClass("SkillBook");
	for nIndex, nNeedLevel in ipairs(tbSkillBook.tbSkillBookHoleLevel) do
		local nCurEquipPos = nIndex + Item.EQUIPPOS_SKILL_BOOK - 1
		local pEquip = me.GetEquipByPos(nCurEquipPos);
		if pEquip then
			local tbBookInfo = tbSkillBook:GetBookInfo(pEquip.dwTemplateId);
			if tbBookInfo.UpgradeItem > 0 and tbBookInfo.Type < InDifferBattle.tbDefine.nMaxSkillBookType then --只能升到中级
				return 1;
			end
		end
	end
	return 0;
end

function tbItem:IsUsableItem(pPlayer, dwTemplateId)
	--4本都是最大等级的 才算是无用的
	local tbSkillBook = Item:GetClass("SkillBook");
	for nIndex, nNeedLevel in ipairs(tbSkillBook.tbSkillBookHoleLevel) do
		local nCurEquipPos = nIndex + Item.EQUIPPOS_SKILL_BOOK - 1
		local pEquip = pPlayer.GetEquipByPos(nCurEquipPos);
		if not pEquip then
			return true
		end
		local tbBookInfo = tbSkillBook:GetBookInfo(pEquip.dwTemplateId);
		if tbBookInfo.Type < InDifferBattle.tbDefine.nMaxSkillBookType then
			return true
		end
	end
    return false
end


local tbBook = Item:GetClass("IndifferRandomBook"); --心魔幻境里的随机门派秘籍