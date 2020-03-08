
Require("CommonScript/Item/Define.lua");

Item.tbItemColor = LoadTabFile("Setting/Item/ItemColor.tab", "dssssdsdd", "Quality", {"Quality", "Color", "FrameColor", "Animation", "AnimationAtlas", "EffectId", "TxtColor", "GTopColorID", "GBottomColorID"});
Item.MAX_STAR_LEVEL = 20;

Item.emITEMPOS_BAG = 200;		-- 背包

-- Item基础模板，详细的在default.lua中定义
if not Item.tbClassBase then
	Item.tbClassBase = {};
end

-- 防止重载脚本的时候模板库丢失
if not Item.tbClass then
	-- Item模板库
	Item.tbClass =
	{
		-- 默认模板，可以提供直接使用
		["default"]	= Item.tbClassBase,
		[""]		= Item.tbClassBase,
	};
end

function Item:LoadEquipShow()
	local tbFile = LoadTabFile("Setting/Item/EquipShow.tab", "dssddddss", nil, {"ShowType", "Name", "Faction", "Sex", "ResId", "IconId", "BigIconId", "Desc", "Desc2"});
	local tbUnidentifyItemList = {}
	local tbUnidentifyToId = {}
	for i,v in ipairs(tbFile) do
		Item.tbEquipShow[v.ShowType] = Item.tbEquipShow[v.ShowType] or {};
		if v.Faction and v.Sex then
		    Item.tbEquipShow[v.ShowType][v.Faction] = Item.tbEquipShow[v.ShowType][v.Faction] or {};
		    --Item.tbEquipShow[v.ShowType][v.Faction][v.Sex] = Item.tbEquipShow[v.ShowType][v.Faction][v.Sex] or {};
		    Item.tbEquipShow[v.ShowType][v.Faction][v.Sex] = {ShowType = v.ShowType,Name = v.Name,Faction = v.Faction,Sex = v.Sex,ResId = v.ResId,IconId = v.IconId,BigIconId = v.BigIconId,Desc = v.Desc,Desc2 = v.Desc2} or {};
		elseif v.Faction then
		    Item.tbEquipShow[v.ShowType][v.Faction] = Item.tbEquipShow[v.ShowType][v.Faction] or {};
		    Item.tbEquipShow[v.ShowType][v.Faction] = {ShowType = v.ShowType,Name = v.Name,Faction = v.Faction,Sex = v.Sex,ResId = v.ResId,IconId = v.IconId,BigIconId = v.BigIconId,Desc = v.Desc,Desc2 = v.Desc2};
		else
		    Item.tbEquipShow[v.ShowType] = {ShowType = v.ShowType,Name = v.Name,Faction = v.Faction,Sex = v.Sex,ResId = v.ResId,IconId = v.IconId,BigIconId = v.BigIconId,Desc = v.Desc,Desc2 = v.Desc2};
		end
	end
end

function Item:Init()
	-- 注册格子类型对应外观类型和优先级
	KItem.RegisterPos2Part(Item.EQUIPPOS_WEAPON, 	Npc.NpcResPartsDef.npc_part_weapon, 1)
	KItem.RegisterPos2Part(Item.EQUIPPOS_BODY, 		Npc.NpcResPartsDef.npc_part_body, 1)
	KItem.RegisterPos2Part(Item.EQUIPPOS_HORSE, 	Npc.NpcResPartsDef.npc_part_horse, 1)
	KItem.RegisterPos2Part(Item.EQUIPPOS_HEAD, 		Npc.NpcResPartsDef.npc_part_head, 1);
	KItem.RegisterPos2Part(Item.EQUIPPOS_WAIYI, 	Npc.NpcResPartsDef.npc_part_body, 2);
	KItem.RegisterPos2Part(Item.EQUIPPOS_WAI_WEAPON,Npc.NpcResPartsDef.npc_part_weapon, 2);
	KItem.RegisterPos2Part(Item.EQUIPPOS_WAI_HORSE, Npc.NpcResPartsDef.npc_part_horse, 2);
	KItem.RegisterPos2Part(Item.EQUIPPOS_WAI_HEAD, 	Npc.NpcResPartsDef.npc_part_head, 2);
	KItem.RegisterPos2Part(Item.EQUIPPOS_WAI_BACK,  Npc.NpcResPartsDef.npc_part_back, 2);
	KItem.RegisterPos2Part(Item.EQUIPPOS_BACK2,  Npc.NpcResPartsDef.npc_part_wing, 1);
	KItem.RegisterPos2Part(Item.EQUIPPOS_WAI_BACK2,  Npc.NpcResPartsDef.npc_part_wing, 2);

	self.tbItemPosToNpcPart = {
		[Item.EQUIPPOS_WEAPON]  	= 	Npc.NpcResPartsDef.npc_part_weapon;
		[Item.EQUIPPOS_BODY]  		= 	Npc.NpcResPartsDef.npc_part_body;
		[Item.EQUIPPOS_HORSE]  		= 	Npc.NpcResPartsDef.npc_part_horse;
		[Item.EQUIPPOS_HEAD]  		= 	Npc.NpcResPartsDef.npc_part_head;
		[Item.EQUIPPOS_WAIYI]  		= 	Npc.NpcResPartsDef.npc_part_body;
		[Item.EQUIPPOS_WAI_WEAPON]  = 	Npc.NpcResPartsDef.npc_part_weapon;
		[Item.EQUIPPOS_WAI_HORSE]  	= 	Npc.NpcResPartsDef.npc_part_horse;
		[Item.EQUIPPOS_WAI_HEAD]  	= 	Npc.NpcResPartsDef.npc_part_head;
		[Item.EQUIPPOS_WAI_BACK]  	= 	Npc.NpcResPartsDef.npc_part_back;
		[Item.EQUIPPOS_BACK2]  	= 	Npc.NpcResPartsDef.npc_part_wing;
		[Item.EQUIPPOS_WAI_BACK2]  	= 	Npc.NpcResPartsDef.npc_part_wing;
	};

	for nPos = Item.EQUIPPOS_SKILL_BOOK, Item.EQUIPPOS_SKILL_BOOK_End do
		KItem.RegisterItemType2Pos(Item.EQUIP_SKILL_BOOK, nPos);
	end

	JueXue:RegisterItemType2Pos()

	KItem.RegisterItemType2Pos(Item.EQUIP_WEAPON_SERIES, Item.EQUIPPOS_WEAPON_SERIES);
	KItem.RegisterItemType2Pos(Item.EQUIP_ARMOR_SERIES, Item.EQUIPPOS_ARMOR_SERIES);
	KItem.RegisterItemType2Pos(Item.EQUIP_RING_SERIES, Item.EQUIPPOS_RING_SERIES);
	KItem.RegisterItemType2Pos(Item.EQUIP_NECKLACE_SERIES, Item.EQUIPPOS_NECKLACE_SERIES);
	KItem.RegisterItemType2Pos(Item.EQUIP_AMULET_SERIES, Item.EQUIPPOS_AMULET_SERIES);
	KItem.RegisterItemType2Pos(Item.EQUIP_BOOTS_SERIES, Item.EQUIPPOS_BOOTS_SERIES);
	KItem.RegisterItemType2Pos(Item.EQUIP_BELT_SERIES, Item.EQUIPPOS_BELT_SERIES);
	KItem.RegisterItemType2Pos(Item.EQUIP_HELM_SERIES, Item.EQUIPPOS_HELM_SERIES);
	KItem.RegisterItemType2Pos(Item.EQUIP_CUFF_SERIES, Item.EQUIPPOS_CUFF_SERIES);
	KItem.RegisterItemType2Pos(Item.EQUIP_PENDANT_SERIES, Item.EQUIPPOS_PENDANT_SERIES);


	-- 注册道具类型对应到格子类型
	--KItem.RegisterItemType2Pos(Item.EQUIP_WAI_WEAPON, Item.EQUIPPOS_WAI_WEAPON);
	--KItem.RegisterItemType2Pos(Item.EQUIP_WAI_HORSE, Item.EQUIPPOS_WAI_HORSE);
	--KItem.RegisterItemType2Pos(Item.EQUIP_REIN, Item.EQUIPPOS_REIN);
	--KItem.RegisterItemType2Pos(Item.EQUIP_SADDLE, Item.EQUIPPOS_SADDLE);
	--KItem.RegisterItemType2Pos(Item.EQUIP_PEDAL, Item.EQUIPPOS_PEDAL);
	KItem.RegisterItemType2Pos(Item.EQUIP_BACK2, Item.EQUIPPOS_BACK2);
	KItem.RegisterItemType2Pos(Item.EQUIP_WAI_BACK2, Item.EQUIPPOS_WAI_BACK2);

	self.tbForbidList = {};	-- 道具禁用表
	self.tbUnForbidList = {};	-- 临时不禁用

	self:LoadItemIcon();
	self:LoadStarLevel();

	if MODULE_GAMESERVER then
		Item:GetClass("RandomItem"):LoadItemList();	-- 随机道具相关 客户端在需要时只读取固定奖励的道具
		Item:GetClass("RandomItemByLevel"):LoadSetting();
	end


	if not MODULE_GAMESERVER then
		self:LoadEquipStarColor()
	end

	self:LoadUnidentifyItem(); --再读了一次未鉴定表，只取其鉴定后与非鉴定的关系
	self.tbHorseShowNpc = LoadTabFile("Setting/Item/HorseShowNpc.tab", "dd", "ItemID", {"ItemID", "NpcResID"});
	self:LoadEquipShow();
end

function Item:GetHorseShoNpc(nItemID)
    local tbInfo  = self.tbHorseShowNpc[nItemID];
    if not tbInfo then
        return 0;
    end

    return tbInfo.NpcResID;
end

function Item:LoadUnidentifyItem()
	local tbFile = LoadTabFile("Setting/Item/Other/UnidentifyItem.tab", "dd", nil, {"ExtParam1", "TemplateId"});
	local tbUnidentifyItemList = {}
	local tbUnidentifyToId = {}
	for i,v in ipairs(tbFile) do
		tbUnidentifyItemList[v.ExtParam1] = v.TemplateId
		tbUnidentifyToId[v.TemplateId] = v.ExtParam1
	end
	self.tbUnidentifyItemList = tbUnidentifyItemList
	self.tbUnidentifyToId = tbUnidentifyToId
end

function Item:GetIdAfterIdentify(nUnidentifyId)
	return self.tbUnidentifyToId[nUnidentifyId]
end

function Item:LoadItemIcon()
	self.tbItemIcon = {};
	self.tbAtlasKey = {}; --[Id] = szAtlas
	local tbTempKeyToAtlas = {};
	local nAtalasyKeyCount = 1;
	local tbFile = LoadTabFile("Setting/Item/ItemIcon.tab", "dssss", nil, {"IconId", "Atlas", "Sprite", "ExtAtlas", "ExtSprite"});
	for i,v in ipairs(tbFile) do
		local nAtlasKey = tbTempKeyToAtlas[v.Atlas]
		if not nAtlasKey then
			nAtalasyKeyCount = nAtalasyKeyCount + 1;
			nAtlasKey = nAtalasyKeyCount
			tbTempKeyToAtlas[v.Atlas] = nAtlasKey
			self.tbAtlasKey[nAtlasKey] = v.Atlas
		end
		local tbInfo;
		if v.ExtSprite == "" then
			tbInfo = {
				Sprite = v.Sprite;
				nAtlasKey =nAtlasKey;
			}
		else
			tbInfo = {
				Sprite = v.Sprite;
				nAtlasKey =nAtlasKey;
				ExtSprite = v.ExtSprite;
				ExtAtlas = v.ExtAtlas
			}
		end

		self.tbItemIcon[v.IconId] = tbInfo;
	end
	if not self.tbItemIcon then
		Log("Load Item Icon Failed!!!!")
		return;
	end

	self.tbItemDisIcon = LoadTabFile("Setting/Item/ItemIconDisable.tab", "dd", "IconId", {"IconId", "IconDisableId"}) or {};
end

function Item:GetType(nItemId)
	local tbBase = KItem.GetItemBaseProp(nItemId)
	return tbBase and tbBase.nItemType or 0
end

function Item:GetLevel(nItemId)
	local tbBase = KItem.GetItemBaseProp(nItemId)
	return tbBase and tbBase.nLevel or 0
end

function Item:GetQuality(nItemId)
	local tbBase = KItem.GetItemBaseProp(nItemId)
	return tbBase and tbBase.nQuality or 0
end

function Item:GetIcon(nIconId, bDisable)
	if bDisable then
		nIconId = (self.tbItemDisIcon[nIconId] or {}).IconDisableId or nIconId;
	end

	local tbIcon = self.tbItemIcon[nIconId]
	if not tbIcon then
		--tbIcon = self.tbItemIcon[212];
		--Log("[EEEEEEEEEE]Item:GetIcon,nIconId=", nIconId, bDisable);
		Log("Error Item:GetIcon", nIconId, tostring( bDisable))
		
		if nIconId > 0 then
		    Log(debug.traceback())
		end
		
		return "UI/Atlas/Common/icon.prefab", "Fork";
	end
	return self.tbAtlasKey[tbIcon.nAtlasKey], tbIcon.Sprite, tbIcon.ExtAtlas, tbIcon.ExtSprite;
end

function Item:LoadStarLevel()
	local szSetting = "Setting/Item/StarLevel.tab"
	self.tbStarLevelValue = {};
	local tbFile	= Lib:LoadTabFile(szSetting, {ItemType = 1});
	if (not tbFile) then	-- 未能读取到
		print("load "..szSetting.." failed!");
		return;
	end
	for _, tbRow in pairs(tbFile) do
		if tbRow.ItemType then
			self.tbStarLevelValue[tbRow.ItemType] = {}
			for i = 1, self.MAX_STAR_LEVEL do
				self.tbStarLevelValue[tbRow.ItemType][i] = tonumber(tbRow["StartLv"..i]) or 0
			end
		end
	end
end

function Item:LoadEquipStarColor()
	local tbEquipStarColor = {}
	local file = LoadTabFile("Setting/Item/EquipStarColor.tab", "ddddddddd", nil, { "StarLevel","1", "2", "3", "4","5","6", "7", "9"});
	for i,v in ipairs(file) do
		tbEquipStarColor[v.StarLevel] = v
	end

	for i = file[1].StarLevel, self.MAX_STAR_LEVEL do
		if not tbEquipStarColor[i] then
			tbEquipStarColor[i] = tbEquipStarColor[i -1]
		end
	end

 	self.tbEquipStarColor = tbEquipStarColor
end

if not MODULE_GAMESERVER then
	function Item:GetEqipShowColor(pItem, bEquiped, pPlayer)
		--只是客户端调,装备的最大品质以自身装备等级为参考
		local szClass = pItem.szClass;
		if szClass == "equip" or szClass == "PiFeng" then
		local tbRandomAttrib, nMaxQuality = Item:GetClass(szClass):GetRandomAttrib(pItem, pPlayer)
			local tbBaseAttrib, nBaseQuality = Item:GetClass(szClass):GetBaseAttrib(pItem.dwTemplateId);
			nMaxQuality = math.max(nMaxQuality, nBaseQuality)
			local nValue = pItem.nValue
			-- if bEquiped then
			-- 	nValue = nValue + StarAttrib:GetEquipAttachValue(pPlayer or me, pItem.nEquipPos);
			-- end
			local nStarLevel = Item:GetStarLevel(pItem.nItemType, nValue)
			if self.tbEquipStarColor[nStarLevel] then
				return self.tbEquipStarColor[nStarLevel][tostring(nMaxQuality)]
			end
			return nMaxQuality
		elseif szClass == "ZhenYuan" then
			--如果有技能就替换掉
			if pItem.GetIntValue(Item.tbZhenYuan.nItemKeySKillInfo) ~= 0 then
				local nQuality = pItem.nQuality
				return Item.tbZhenYuan.tbShowColor[nQuality]
			end
		end

	end
end



function Item:GetStarLevel(nItemType, nValue)
	local nLevel = 0
	if not self.tbStarLevelValue then
		return 0;
	end
	for i, nStar in ipairs(self.tbStarLevelValue[nItemType] or {}) do
		if nStar <= nValue then
			nLevel = i;
		else
			break;
		end
	end
	return nLevel
end

function Item:GetQualityColor(nQuality)
	local tbColor = self.tbItemColor[nQuality] or {};
	if tbColor then
		return tbColor.Color, tbColor.FrameColor, tbColor.Animation, tbColor.AnimationAtlas, tbColor.TxtColor, tbColor.GTopColorID, tbColor.GBottomColorID;
	end
end

function Item:GetQualityEffect(nQuality)
	local tbColor = self.tbItemColor[nQuality]
	if tbColor then
		return tbColor.EffectId
	end
end

-- 取得特定类名的Item模板
function Item:GetClass(szClassName, bNotCreate)
	local tbClass = self.tbClass[szClassName];
	if (not tbClass) and (bNotCreate ~= 1) then		-- 如果没有bNotCreate，当找不到指定模板类时会自动建立新模板类
		tbClass	= Lib:NewClass(self.tbClassBase);	-- 新模板从父模板类派生
		self.tbClass[szClassName] = tbClass;		-- 加入到模板库里面
	end
	return	tbClass;
end

-- 继承特定类名的Item模板
function Item:NewClass(szClassName, szParent)
	if (self.tbClass[szClassName]) then				-- 指定模板类必须还不存在
		print("[ITEM] class "..tostring(szClassName).." already exist, please check out");
		return;
	end
	local tbParent = self.tbClass[szParent];
	if (not tbParent) then							-- 父模板类必须已经存在
		print("[ITEM] class"..tostring(szParent).." already exist, please check out");
		return;
	end
	local tbClass = Lib:NewClass(tbParent);			-- 从父模板类派生
	self.tbClass[szClassName] = tbClass;			-- 加入到模板库里面
	return	tbClass;
end

-- Server
function Item:OnCreate(szClassName, ...)
	local tbClass = self.tbClass[szClassName] or self.tbClass["default"];
	return	tbClass:OnCreate(...);
end

-- 系统调用，默认的道具生成信息初始化（服务端&客户端 道具创建的时候就被叠加不会调用这个函数）
function Item:OnItemInit(szClassName, ...)
	local tbClass = self.tbClass[szClassName] or self.tbClass["default"];
	return	tbClass:OnInit(...);
end

function Item:CheckCanSell(pItem)
	local tbClass = self.tbClass[pItem.szClass];
	if not tbClass or not tbClass.CheckCanSell then
		return true;
	end

	return tbClass:CheckCanSell(pItem);
end

function Item:IsUsableItem(pPlayer, dwTemplateId)
	local tbItemBae = KItem.GetItemBaseProp(dwTemplateId)
	if not tbItemBae then
		return
	end
	local szClassName = tbItemBae.szClass
	local tbClass = self.tbClass[szClassName];
	if not tbClass or not tbClass.IsUsableItem then
		return true;
	end
	return tbClass:IsUsableItem(pPlayer, dwTemplateId)
end

function Item:CheckUsable(pItem, szClassName)
	local tbClass = self.tbClass[szClassName];
	if (not tbClass) then
		tbClass = self.tbClass["default"];
	end

	-- local nMapId = -1;
	-- nMapId = me.nTemplateMapId;

--  local nCanUse, szMsg = self:CheckIsUseAtMap(nMapId, pItem.szForbidType);
--	if nCanUse ~= 1 then
--		me.Msg(szMsg);
--		return 0;
--	end

	local nTemplateId = pItem.dwTemplateId
	if (self.tbForbidList[szClassName] and 		-- 在禁用表
		not self.tbUnForbidList[szClassName]) then	-- 没在临时不禁用表
		return 0, "很遗憾，系统检测到该道具异常，暂时无法使用。";
	end

	if pItem.nUseLevel > me.nLevel then
		return 0, string.format("%d级之后可使用", pItem.nUseLevel);
	end
	-- TODO cd


	return	tbClass:CheckUsable(pItem);
end

function Item:CheckIsForbid(szClassName)
	if (self.tbForbidList[szClassName] and 		-- 在禁用表
		not self.tbUnForbidList[szClassName]) then	-- 没在临时不禁用表
		return true;
	end
	return false;
end

function Item:NotifyItem(pPlayer,nId,tbMsg)
	local pItem = pPlayer.GetItemInBag(nId)
	if not pItem then
		print("Notify Unexsit Item "..nId)
		return;
	end

	local szClassName = pItem.szClass;
	local tbClass = self.tbClass[szClassName];
	if tbClass and tbClass.OnNotifyItem then
		tbClass:OnNotifyItem(pPlayer,pItem,tbMsg);
	end
end

function Item:UseItem(nId)
	local pItem = me.GetItemInBag(nId)
	if not pItem then
		print("Unexsit Item "..nId)
		return;
	end

	local szClassName = pItem.szClass;
	local dwTemplateId = pItem.dwTemplateId;

	local bRet, nOpenRetCode = pcall(self.OnUse, self, pItem)
	if (not bRet) then
		self.tbForbidList[szClassName] = true;
		Log(nOpenRetCode);
		Log(debug.traceback());
	end
	Log(string.format("Item:OnUse dwTemplateId:%d, bRet:%s, nOpenRetCode:%s, player:%d", dwTemplateId, bRet and "ok" or "fail", type(nOpenRetCode) == "number" and nOpenRetCode or "nil", me.dwID))
end

function Item:UseAllItem(nId)
	local pItem = me.GetItemInBag(nId)
	if not pItem then
		print("Unexsit Item "..nId)
		return;
	end

	local szClassName = pItem.szClass;
	local dwTemplateId = pItem.dwTemplateId;

	local bRet, nOpenRetCode = pcall(self.OnUseAll, self, pItem)
	if (not bRet) then
		self.tbForbidList[szClassName] = true;
		Log(nOpenRetCode);
		Log(debug.traceback());
	end

	Log(string.format("Item:OnUseAll dwTemplateId:%d, bRet:%s, nOpenRetCode:%s, player:%d", dwTemplateId, bRet and "ok" or "fail", type(nOpenRetCode) == "number" and nOpenRetCode or "nil", me.dwID))
end

function Item:OnUse(pItem)
	local szClassName = pItem.szClass
	local nRet, szMsg = self:CheckUsable(pItem, szClassName)
	if nRet ~= 1 then
		if szMsg then
			me.CenterMsg(szMsg)
		end
		return 0;
	end

	local tbClass = self.tbClass[szClassName];
	local nRetCode = 0;
	if tbClass and tbClass.OnUse then
		nRetCode = tbClass:OnUse(pItem);
		if nRetCode and nRetCode > 0 then
			assert(Item:Consume(pItem, nRetCode) == 1)
		end
	end

	return nRetCode;
end

-- 消耗道具，不足则失败且不消耗
function Item:Consume(pItem, nCount)
	local nCurCount = pItem.nCount
	if nCount > 0 and nCurCount > nCount then
		pItem.SetCount(nCurCount - nCount, Env.LogWay_UseItem)
		--Log(string.format("Item:Consume SetCount dwTemplateId:%d, nCurCount:%d, nCount:%d, player:%d", pItem.dwTemplateId, nCurCount, nCount, me.dwID) )
	elseif nCurCount == nCount then
		pItem.Delete(Env.LogWay_UseItem);
		--Log(string.format("Item:Consume Delete dwTemplateId:%d, player:%d", pItem.dwTemplateId, me.dwID) )
	else
		return 0
	end
	return 1;
end

function Item:IsMainEquipPos(nEquipPos)
    if 0 <= nEquipPos and nEquipPos < Item.EQUIPPOS_MAIN_NUM then
    	return true;
    end

    return false;
end

local tbFubActiveReqDesc =
{
	[Item.emEquipActiveReq_Ride] = function (szMagicName, tbMagic)
	    return "上马激活";
	end
}

function Item:GetActiveReqDesc(nActiveReq)
    local fnMsg = tbFubActiveReqDesc[nActiveReq];
    if not fnMsg then
    	return;
    end

    return fnMsg();
end

function Item:OnUseAll(pItem)
	local szClassName = pItem.szClass
	local nRet, szMsg = self:CheckUsable(pItem, szClassName)
	if nRet ~= 1 then
		if szMsg then
			me.CenterMsg(szMsg)
		end
		return 0;
	end
	local tbClass = self.tbClass[szClassName];
	local nRetCode = 0;
	if tbClass and tbClass.OnUseAll then
		nRetCode = tbClass:OnUseAll(pItem);
		if nRetCode and nRetCode > 0 then
			assert(Item:Consume(pItem, nRetCode) == 1)
		end
	end
	return nRetCode;
end

function Item:UseEquip(nId, bSlient, nEquipPos)
	local pEquip = me.GetItemInBag(nId)
	if not pEquip then
		print("Unexsit Equip "..nId)
		return;
	end

	if pEquip.nUseLevel > me.nLevel then
		return;
	end

	if ActionInteract:IsInteract(me) then
		me.CenterMsg("动作交互下不能操作");
        return;
    end

	if Toy:GetUsing(me) then
		me.CenterMsg("当前状态不能操作");
        return;
    end

	local nEquipType = pEquip.nItemType;
	local tbEquipClass;
	if not Lib:IsEmptyStr(pEquip.szClass) then
		tbEquipClass = Item:GetClass(pEquip.szClass);
		if tbEquipClass.CheckUseEquip then
			local bRet, szMsg = tbEquipClass:CheckUseEquip(me, pEquip, nEquipPos);
			if not bRet then
				me.CenterMsg(szMsg);
				return;
			end
		else
			nEquipPos = -1;
		end
		if tbEquipClass.BeforeUseEquip then
			tbEquipClass:BeforeUseEquip(me, pEquip, nEquipPos)
		end
	else
		nEquipPos = -1;
	end


	RecordStone:ClearEquipRecord(me, pEquip.nEquipPos)
	self:ClearEquipString(me, pEquip.nEquipPos)
	-- 装备判断
	local nResult = me.UseEquip(nId, nEquipPos or -1);
	if nResult == 1 then
		nEquipPos = pEquip.nEquipPos
		self.GoldEquip:UpdateSuitAttri(me)
		self.GoldEquip:UpdateTrainAttri(me, nEquipPos)
		RecordStone:UpdateCurRecoreStoneToEquip(me, nEquipPos)
		self:UpdateEquipPosString(me, nEquipPos)
		if tbEquipClass and tbEquipClass.AfterUseEquip then
			tbEquipClass:AfterUseEquip(me, pEquip)
		end

		FightPower:ChangeFightPower(FightPower:GetFightPowerTypeByEquipPos(nEquipPos), me, bSlient);
		if nEquipPos == Item.EQUIPPOS_HORSE then
			local szEquipName = Item:GetItemTemplateShowInfo(pEquip.dwTemplateId, me.nFaction, me.nSex);
			me.CenterMsg(string.format("%s上阵成功", szEquipName));
		end

		TeacherStudent:OnChangeEquip(me)
		Lib:CallBack({ChatMgr.ChatEquipBQ.OnUseEquip, ChatMgr.ChatEquipBQ, me, pEquip.dwTemplateId})
		Lib:CallBack({JueXue.OnUseEquip, JueXue, me, pEquip})
	end
	--StarAttrib:CalcStarAttrib(me, true);
	Log(string.format("Item:UseEquip pPlayer:%d, dwTemplateId:%d, nId:%d, nPos:%d", me.dwID, pEquip.dwTemplateId, nId, pEquip.nPos) );
end

function Item:UnuseEquip(nPos)
	if ActionInteract:IsInteract(me) then
		me.CenterMsg("动作交互下不能操作");
        return;
    end

    if Toy:GetUsing(me) then
		me.CenterMsg("当前状态不能操作");
        return;
    end

	local pEquip   = me.GetEquipByPos(nPos)
	if not pEquip then
		me.CenterMsg("当前位置没有装备")
		return
	end
	local tbEquipClass;
	if not Lib:IsEmptyStr(pEquip.szClass) then
		tbEquipClass = Item:GetClass(pEquip.szClass);
	end
	RecordStone:ClearEquipRecord(me, nPos)
	self:ClearEquipString(me, nPos)

	me.UnuseEquip(nPos);

	if tbEquipClass and tbEquipClass.AfterUnuseEquip then
		tbEquipClass:AfterUnuseEquip(me, pEquip, nPos)
	end

	self.GoldEquip:UpdateSuitAttri(me)
	self.GoldEquip:UpdateTrainAttri(me, nPos)
	FightPower:ChangeFightPower(FightPower:GetFightPowerTypeByEquipPos(nPos), me);
	Lib:CallBack({JueXue.OnUnuseEquip, JueXue, me, nPos, pEquip})
	--StarAttrib:CalcStarAttrib(me);
	Log(string.format("Item:UnuseEquip pPlayer:%d, nPos:%d", me.dwID, nPos) );
end

function Item:UseChooseItem(nId, tbChoose)
	local pItem = me.GetItemInBag(nId)
	if not pItem then
		print("UseChooseItem Error Unexsit Item " .. nId)
		return
	end

	local szClassName = pItem.szClass
	local tbClass = self.tbClass[szClassName]
	if tbClass and tbClass.OnSelectItem then
		local nRetCode = tbClass:OnSelectItem(pItem, tbChoose)
		if nRetCode and nRetCode > 0 then
			local nCurCount = pItem.nCount
			if nRetCode <= nCurCount then
				assert(self:Consume(pItem, nRetCode) == 1)
			else
				assert(me.ConsumeItemInAllPos(pItem.dwTemplateId, nRetCode, Env.LogWay_UseItem) == nRetCode)
			end
		end
	end
end

function Item:DoUseItem(nItemId)
	local pItem = me.GetItemInBag(nItemId)
	if not pItem then
		return
	end

	local szClassName = pItem.szClass
	local tbClass = self.tbClass[szClassName]
	if tbClass and tbClass.OnClientUse then
		local nRetCode = tbClass:OnClientUse(pItem)
		if nRetCode and nRetCode > 0 then
			return
		end
	end
	RemoteServer.UseItem(nItemId);
end

function Item:ClientUseItem(nItemId)
	if not nItemId then
		return
	end

	local pItem = me.GetItemInBag(nItemId)
	if not pItem then
		return
	end
	local szSureTip = Gift:CheckUseSure(Gift.GiftType.MailGift, pItem.dwTemplateId)
    if szSureTip then
        me.MsgBox(szSureTip,
        {
            {"确定", function ()
                self:DoUseItem(nItemId)
            end},
            {"取消"},
        })
    else
        self:DoUseItem(nItemId)
    end
end

function Item:NotifyTimeOut(dwTemplateId, nCount)
	local szItemName = Item:GetItemTemplateShowInfo(dwTemplateId, me.nFaction, me.nSex)
	local szMsg = string.format("您的物品%s已过期！", szItemName)
	me.CenterMsg(szMsg);
	me.Msg(szMsg)

	local tbBaseProp = KItem.GetItemBaseProp(dwTemplateId)
	if tbBaseProp and self.tbClass[tbBaseProp.szClass] and self.tbClass[tbBaseProp.szClass].OnTimeOut then
		self.tbClass[tbBaseProp.szClass]:OnTimeOut(dwTemplateId, nCount)		-- 注意：没有 it
	end
end

function Item:GetItemTimeOut(pItem)
	if pItem and pItem.GetIntValue(-9996) > 0 then
		return os.date("%Y年%m月%d日 %H:%M:%S", pItem.GetIntValue(-9996))
	end
end

function Item:GoAndUseItem(nMapId, nX, nY, nItemId)
	if MODULE_GAMESERVER then
		return;
	end

	Ui:CloseWindow("ItemBox");
	Ui:CloseWindow("ItemTips");
	local pItem = KItem.GetItemObj(nItemId);
	if not pItem then
		return;
	end

	local function fnOnArive()
		RemoteServer.UseItem(nItemId);
	end

	AutoPath:GotoAndCall(nMapId, nX, nY, fnOnArive);
end

function Item:GetExtBagCount(pPlayer)
	if MODULE_GAMESERVER and pPlayer.nTempExtBagCount then
		-- 服务器缓存一下结果，避免每次都去算
		return pPlayer.nTempExtBagCount;
	end
	local nExtBagCount = 0;
	for _, tbInfo in pairs(self.tbExtBagSetting) do
		local nSaveId, nBagCount = unpack(tbInfo)
		local nUsedCount = self:GetExtBagValue(pPlayer, nSaveId)
		nExtBagCount = nExtBagCount + nUsedCount * nBagCount
	end
	pPlayer.nTempExtBagCount = nExtBagCount
	return nExtBagCount;
end

function Item:GetExtBagUserValueId(nId)
	local nUserId = math.floor((nId - 1) / 4) + 1		-- 按字节存，1个uservalue 4个byte
	local nByteIndex = (nId % 4 == 0) and 4 or (nId % 4)
	return nUserId, nByteIndex
end

function Item:GetExtBagValue(pPlayer, nId)
	local nUserId, nByteIndex = self:GetExtBagUserValueId(nId)
	local nUserValue = pPlayer.GetUserValue(self.EXT_USER_VALUE_GROUP, nUserId)
	return KLib.GetByte(nUserValue, nByteIndex)
end

function Item:SetExtBagValue(pPlayer, nId, nValue)
	if nValue > 127 then
		return false;
	end
	local nUserId, nByteIndex = self:GetExtBagUserValueId(nId)
	local nUserValue = pPlayer.GetUserValue(self.EXT_USER_VALUE_GROUP, nUserId)
	local nNewValue = KLib.SetByte(nUserValue, nByteIndex, nValue)
	pPlayer.SetUserValue(self.EXT_USER_VALUE_GROUP, nUserId, nNewValue)
	pPlayer.nTempExtBagCount = nil;
	return true;
end

function Item:SetEquipPosString(pPlayer, nPos, szString)
	pPlayer.tbEquipString = pPlayer.tbEquipString or {}
    pPlayer.tbEquipString[nPos] = szString
    local pEquip = pPlayer.GetEquipByPos(nPos)
    if not pEquip then
        return
    end
    pEquip.SetStrValue(1, szString)
end

function Item:UpdateEquipPosString(pPlayer, nPos)
	if not pPlayer.tbEquipString then
		return
	end
	if not pPlayer.tbEquipString[nPos] or pPlayer.tbEquipString[nPos] == "" then
		return;
	end

	local pEquip = pPlayer.GetEquipByPos(nPos)
    if not pEquip then
        return
    end
    pEquip.SetStrValue(1, pPlayer.tbEquipString[nPos])
end

function Item:ClearEquipString(pPlayer, nPos)
	if not pPlayer.tbEquipString then
		return
	end
	if not pPlayer.tbEquipString[nPos] or pPlayer.tbEquipString[nPos] == "" then
		return;
	end

	local pEquip = pPlayer.GetEquipByPos(nPos)
    if not pEquip then
        return
    end
    pEquip.SetStrValue(1, "")
end

function Item:IsForbidStall(pItem)
	local nBitState = pItem.GetBaseIntValue(1)
	return Lib:LoadBits(nBitState, 1, 1)~=0
end

function Item:GetItemTemplateShowInfo(nItemTemplateId, nFaction, nSex)
    if not nItemTemplateId then
	    return "未知道具"
	end

	local nFactionFix = nFaction
	if nFactionFix == 19 then
	    nFactionFix = 15
	elseif nFactionFix == 20 then
	    nFactionFix = 16
	elseif nFactionFix == 21 then
	    nFactionFix = 4
	elseif nFactionFix == 22 then
	    nFactionFix = 1
	elseif nFactionFix == 23 then
	    nFactionFix = 2
	elseif nFactionFix == 24 then
	    nFactionFix = 3
	elseif nFactionFix == 25 then
	    nFactionFix = 4
	end

	if nFactionFix and nSex then
	    return KItem.GetItemShowInfo(nItemTemplateId, nFactionFix, nSex)
	elseif nFactionFix then
	    return KItem.GetItemShowInfo(nItemTemplateId, nFactionFix)
	else
	    return KItem.GetItemShowInfo(nItemTemplateId)
	end
end

function Item:GetDBItemShowInfo(pItem, nFaction, nSex)
    if not pItem then
        Log("[EEEEEEEEEE]GetDBItemShowInfo,pItem=nil", nFaction, nSex);
	    return nil
	end

	local nFactionFix = nFaction
	if nFactionFix == 19 then
	    nFactionFix = 15
	elseif nFactionFix == 20 then
	    nFactionFix = 16
	elseif nFactionFix == 21 then
	    nFactionFix = 4
	elseif nFactionFix == 22 then
	    nFactionFix = 1
	elseif nFactionFix == 23 then
	    nFactionFix = 2
	elseif nFactionFix == 24 then
	    nFactionFix = 3
	elseif nFactionFix == 25 then
	    nFactionFix = 4
	end

	if nFactionFix and nSex then
	    return pItem.GetItemShowInfo(nFactionFix, nSex)
	elseif nFactionFix then
	    return pItem.GetItemShowInfo(nFactionFix)
	else
	    return pItem.GetItemShowInfo()
	end
end


--[[
function Item:GetItemTemplateShowInfo(nItemTemplateId, nFaction, nSex)
    --Log("[EEEEEEEEEE]GetItemTemplateShowInfo,init", nItemTemplateId, nFaction, nSex);

	if nFaction == 18 or nFaction == 19 then
		return Item:GetDBItemShowInfoNewJob(nItemTemplateId, nFaction, nSex)
	end

	if nFaction and nSex then
	    return KItem.GetItemShowInfo(nItemTemplateId, nFaction, nSex)
	elseif nFaction then
	    return KItem.GetItemShowInfo(nItemTemplateId, nFaction)
	else
	    return KItem.GetItemShowInfo(nItemTemplateId)
	end

	--if nItemTemplateId == 2424 then
	--    for i, v in pairs(ret) do
	--    	Log("[DDDDDDDDDD]GetItemTemplateShowInfo", i, v);
	--    end
	--end
	--return unpack(ret)
end

function Item:GetDBItemShowInfo(pItem, nFaction, nSex)
    if not pItem then
        Log("[EEEEEEEEEE]GetDBItemShowInfo,pItem=nil", nFaction, nSex);
	    return nil
	end

    --Log("[EEEEEEEEEE]GetDBItemShowInfo,init", pItem.dwTemplateId, nFaction, nSex);

	if nFaction == 18 or nFaction == 19 then
		return Item:GetDBItemShowInfoNewJob(pItem.dwTemplateId, nFaction, nSex)
	end

	if nFaction and nSex then
	    return pItem.GetItemShowInfo(nFaction, nSex)
	elseif nFaction then
	    return pItem.GetItemShowInfo(nFaction)
	else
	    return pItem.GetItemShowInfo()
	end

	--if pItem.dwTemplateId == 2424 then
	--    for i, v in pairs(ret) do
	--    	Log("[DDDDDDDDDD]GetDBItemShowInfo", i, v);
	--    end
	--end
	--return unpack(ret)
end

--local szName, nIcon, nView
--local szName, nIcon, nView, nQuality, nRes
--pItem.dwTemplateId
--    local nType = KItem.GetItemExtParam(pItem.dwTemplateId, 1)
--	local nShowType = KItem.GetEquipShowType(dwTemplateId)
--   local tbInfo = KItem.GetItemBaseProp(2690) --只提示非礼物道具
--	local nShowType = KItem.GetEquipShowType(dwTemplateId)

function Item:GetDBItemShowInfoNewJob(nItemTemplateId, nFaction, nSex)
    if not nItemTemplateId then
        Log("[EEEEEEEEEE]GetDBItemShowInfoNewJob,nItemTemplateId=nil", nFaction, nSex);
	    return nil
	end

    local bGet = false
    local nShowType = KItem.GetEquipShowType(nItemTemplateId)

    if nShowType and nShowType > 0 then
        Log("[EEEEEEEEEE]GetDBItemShowInfoNewJob, GetEquipShowType ID,nShowType=", nItemTemplateId, nShowType);
	    if nFaction and nSex then
		    if Item.tbEquipShow[nShowType] and Item.tbEquipShow[nShowType][nFaction] and Item.tbEquipShow[nShowType][nFaction][nSex] then
			    local tbRet = Item.tbEquipShow[nShowType][nFaction][nSex];
	            return tbRet.Name,tbRet.IconId,tbRet.BigIconId,2,tbRet.ResId;
			end
	    elseif nFaction then
		    if Item.tbEquipShow[nShowType] and Item.tbEquipShow[nShowType][nFaction] then
			    local tbRet = Item.tbEquipShow[nShowType][nFaction];
	            return tbRet.Name,tbRet.IconId,tbRet.BigIconId,2,tbRet.ResId;
			end
	    end
	else
        Log("[EEEEEEEEEE]GetDBItemShowInfoNewJob, GetEquipShowType nShowType=null,ID=", nItemTemplateId);

	    if nFaction and nSex then
	        return KItem.GetItemShowInfo(nItemTemplateId, nFaction, nSex)
	    elseif nFaction then
	        return KItem.GetItemShowInfo(nItemTemplateId, nFaction)
	    else
	        return KItem.GetItemShowInfo(nItemTemplateId)
	    end
    end
end
]]
