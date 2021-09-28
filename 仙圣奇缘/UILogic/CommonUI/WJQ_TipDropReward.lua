--------------------------------------------------------------------------------------
-- 文件名:	CTipDropItem.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	陆奎安
-- 日  期:	2015-1-15 9:24
-- 版  本:	1.0
-- 描  述:	Tip界面
-- 应  用:  
---------------------------------------------------------------------------------------
Game_TipDropReward = class("Game_TipDropReward")
Game_TipDropReward.__index = Game_TipDropReward

function Game_TipDropReward:initWnd()
end
function Game_TipDropReward:closeWnd()
	if self.CSV_DropItem.wndCloseEevent then
		self.CSV_DropItem.wndCloseEevent()
	end
end
function Game_TipDropReward:openWnd(CSV_DropItem)
	if not CSV_DropItem then return end 
	self.CSV_DropItem = CSV_DropItem
	local Image_TipDropRewardPNL = tolua.cast(self.rootWidget:getChildByName("Image_TipDropRewardPNL"), "ImageView")
	local Image_RewardCard = tolua.cast(Image_TipDropRewardPNL:getChildByName("Image_RewardCard"), "ImageView")
	Image_RewardCard:setVisible(false)
	local Image_RewardEquip = tolua.cast(Image_TipDropRewardPNL:getChildByName("Image_RewardEquip"), "ImageView")
	Image_RewardEquip:setVisible(false)
	local Image_RewardFate = tolua.cast(Image_TipDropRewardPNL:getChildByName("Image_RewardFate"), "ImageView")
	Image_RewardFate:setVisible(false)
	local Image_RewardHunPo = tolua.cast(Image_TipDropRewardPNL:getChildByName("Image_RewardHunPo"), "ImageView")
	Image_RewardHunPo:setVisible(false)
	local Image_RewardMaterial = tolua.cast(Image_TipDropRewardPNL:getChildByName("Image_RewardMaterial"), "ImageView")
	Image_RewardMaterial:setVisible(false)
	local Image_RewardFrag = tolua.cast(Image_TipDropRewardPNL:getChildByName("Image_RewardFrag"), "ImageView")
	Image_RewardFrag:setVisible(false)
	local Image_RewardUseItem = tolua.cast(Image_TipDropRewardPNL:getChildByName("Image_RewardUseItem"), "ImageView")
	Image_RewardUseItem:setVisible(false)
	local Image_RewardFormula = tolua.cast(Image_TipDropRewardPNL:getChildByName("Image_RewardFormula"), "ImageView")
	Image_RewardFormula:setVisible(false)
	local Image_RewardEquipPack = tolua.cast(Image_TipDropRewardPNL:getChildByName("Image_RewardEquipPack"), "ImageView")
	Image_RewardEquipPack:setVisible(false)
	local Image_RewardSoul = tolua.cast(Image_TipDropRewardPNL:getChildByName("Image_RewardSoul"), "ImageView")
	Image_RewardSoul:setVisible(false)
	local Image_RewardResource = tolua.cast(Image_TipDropRewardPNL:getChildByName("Image_RewardResource"), "ImageView")
	Image_RewardResource:setVisible(false)
	
	local Label_Name = tolua.cast(Image_TipDropRewardPNL:getChildByName("Label_Name"), "Label")
	local Label_Desc = tolua.cast(Image_TipDropRewardPNL:getChildByName("Label_Desc"), "Label")

	if CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_CARD then 	--伙伴
		local CSV_CardBase = g_DataMgr:getCardBaseCsv(CSV_DropItem.DropItemID, CSV_DropItem.DropItemStarLevel)
		if not CSV_CardBase then return end
		
		Image_RewardCard:setVisible(true)
		local CCSprite_Icon = SpriteCoverlipping(getIconImg(CSV_CardBase.SpineAnimation), getIconImg("Qishu_Skill1"))
		if CCSprite_Icon ~= nil then
			CCSprite_Icon:setScale(0.98)
			Image_RewardCard:addNode(CCSprite_Icon, 0)
		end
		
		local Image_Frame = tolua.cast(Image_RewardCard:getChildByName("Image_Frame"), "ImageView")
		Image_Frame:loadTexture(getCardCoverByEvoluteLev(CSV_DropItem.DropItemEvoluteLevel))
		local Image_StarLevel = tolua.cast(Image_RewardCard:getChildByName("Image_StarLevel"), "ImageView")
		Image_StarLevel:loadTexture(getIconStarLev(CSV_DropItem.DropItemStarLevel))
		
		Label_Name:setText(CSV_CardBase.Name.."×"..CSV_DropItem.DropItemNum)
		Label_Desc:setText(_T("您已获得")..CSV_DropItem.DropItemNum.._T("个的伙伴[")..CSV_CardBase.Name.."]")
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_EQUIP then 	--装备
		local CSV_Equip = g_DataMgr:getEquipCsv(CSV_DropItem.DropItemID, CSV_DropItem.DropItemStarLevel)
		
		Image_RewardEquip:setVisible(true)
		Image_RewardEquip:loadTexture(getUIImg("FrameEquipLight"..CSV_Equip.ColorType))
		local Image_Icon = tolua.cast(Image_RewardEquip:getChildByName("Image_Icon"), "ImageView")
		Image_Icon:loadTexture(getIconImg(CSV_Equip.Icon))
		equipSacleAndRotate(Image_Icon, CSV_Equip.SubType)
		
		Label_Name:setText(CSV_Equip.Name.."×"..CSV_DropItem.DropItemNum)
		Label_Desc:setText(_T("您已获得")..CSV_DropItem.DropItemNum.._T("个件装备[")..CSV_Equip.Name.."]")
		
		local Image_IconTag = tolua.cast(Image_RewardEquip:getChildByName("Image_IconTag"), "ImageView")
		Image_IconTag:loadTexture(getUIImg("Image_EquipTag"..(CSV_Equip.StarLevel-1)))
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_ARRAYMETHOD then 	--阵法(暂时作废)
		
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_FATE then 	--异兽
		local CSV_CardFate = g_DataMgr:getCardFateCsv(CSV_DropItem.DropItemID, CSV_DropItem.DropItemStarLevel)
		
		Image_RewardFate:setVisible(true)
		Image_RewardFate:loadTexture(getUIImg("FrameEquipLight"..CSV_CardFate.ColorType))
		local Image_Icon = tolua.cast(Image_RewardFate:getChildByName("Image_Icon"), "ImageView")
		Image_Icon:loadTexture(getIconImg(CSV_CardFate.Animation))
		Image_Icon:setPosition(ccp(CSV_CardFate.OffsetX, CSV_CardFate.OffsetY))
		
		Label_Name:setText(CSV_CardFate.Name.."×"..CSV_DropItem.DropItemNum)
		Label_Desc:setText(_T("您已获得")..CSV_DropItem.DropItemNum.._T("个只[")..CSV_CardFate.Name.."]")
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_CARD_GOD then 	--魂魄
		local CSV_CardHunPo = g_DataMgr:getCardHunPoCsv(CSV_DropItem.DropItemID)
		if not CSV_CardHunPo then return end
		local CSV_CardBase = g_DataMgr:getCardBaseCsv(CSV_DropItem.DropItemID, CSV_CardHunPo.CardStarLevel)
		if not CSV_CardBase then return end
		
		Image_RewardHunPo:setVisible(true)
		Image_RewardHunPo:loadTexture(getUIImg("SummonHunPoBase"..CSV_CardHunPo.CardStarLevel))
		local Image_Frame = tolua.cast(Image_RewardHunPo:getChildByName("Image_Frame"),"ImageView")
		Image_Frame:loadTexture(getUIImg("SummonHunPoCoverB"..CSV_CardHunPo.CardStarLevel))
		local CCSprite_Icon = SpriteCoverlipping(getIconImg(CSV_CardBase.SpineAnimation), getUIImg("SummonHunPoBase"..CSV_CardHunPo.CardStarLevel))
		if CCSprite_Icon ~= nil then
			CCSprite_Icon:setScale(0.98)
			Image_RewardHunPo:addNode(CCSprite_Icon, 1)
		end
		
		Label_Name:setText(CSV_CardHunPo.Name.."×"..CSV_DropItem.DropItemNum)
		Label_Desc:setText(_T("您已获得")..CSV_DropItem.DropItemNum.._T("个").."["..CSV_CardHunPo.Name.."]")
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_MATERIAL then 	--ItemBase(道具)
		local CSV_ItemBase = g_DataMgr:getItemBaseCsv(CSV_DropItem.DropItemID, CSV_DropItem.DropItemStarLevel)
		if not CSV_ItemBase then return nil end
		if CSV_ItemBase.Type == NUM_ItemBaseType.Material then --材料
			Image_RewardMaterial:setVisible(true)
			Image_RewardMaterial:loadTexture(getUIImg("FrameEquipLight"..CSV_ItemBase.ColorType))
			local Image_Icon = tolua.cast(Image_RewardMaterial:getChildByName("Image_Icon"), "ImageView")
			Image_Icon:loadTexture(getIconImg(CSV_ItemBase.Icon))
		
			Label_Name:setText(CSV_ItemBase.Name.."×"..CSV_DropItem.DropItemNum)
			Label_Desc:setText(_T("您已获得")..CSV_DropItem.DropItemNum.._T("个材料[")..CSV_ItemBase.Name.."]")
			
			local Image_IconTag = tolua.cast(Image_RewardMaterial:getChildByName("Image_IconTag"), "ImageView")
			if CSV_ItemBase.SubType == NUM_ItemBaseSubType.EquipComposeMaterial then
				Image_IconTag:setVisible(true)
				Image_IconTag:loadTexture(getUIImg("Image_EquipTag"..CSV_ItemBase.FormulaType))
			else
				Image_IconTag:setVisible(false)
			end
		elseif CSV_ItemBase.Type == NUM_ItemBaseType.SkillFrag then --碎片
			Image_RewardFrag:setVisible(true)
			Image_RewardFrag:loadTexture(getUIImg("FrameEquipLight"..CSV_ItemBase.ColorType))
			local Image_Icon = tolua.cast(Image_RewardFrag:getChildByName("Image_Icon"), "ImageView")
			Image_Icon:loadTexture(getIconImg(CSV_ItemBase.Icon))
		
			Label_Name:setText(CSV_ItemBase.Name.."×"..CSV_DropItem.DropItemNum)
			Label_Desc:setText(_T("您已获得")..CSV_DropItem.DropItemNum.._T("个").."["..CSV_ItemBase.Name.."]")
		elseif CSV_ItemBase.Type == NUM_ItemBaseType.CanUseItem or CSV_ItemBase.Type == NUM_ItemBaseType.CardExpItem then --道具
			Image_RewardUseItem:setVisible(true)
			Image_RewardUseItem:loadTexture(getUIImg("FrameBack"..CSV_ItemBase.ColorType))
			
			local Image_Frame = tolua.cast(Image_RewardUseItem:getChildByName("Image_Frame"),"ImageView")
			Image_Frame:loadTexture(getUIImg("SummonFragCoverB"..CSV_ItemBase.ColorType))
			
			local Image_Icon = tolua.cast(Image_RewardUseItem:getChildByName("Image_Icon"), "ImageView")
			Image_Icon:loadTexture(getIconImg(CSV_ItemBase.Icon))
		
			Label_Name:setText(CSV_ItemBase.Name.."×"..CSV_DropItem.DropItemNum)
			Label_Desc:setText(_T("您已获得")..CSV_DropItem.DropItemNum.._T("个道具[")..CSV_ItemBase.Name.."]")
			
			local Image_IconTag = tolua.cast(Image_RewardUseItem:getChildByName("Image_IconTag"), "ImageView")
			if CSV_ItemBase.SubType == NUM_ItemBaseSubType.EquipMaterialPack or CSV_ItemBase.SubType == NUM_ItemBaseSubType.EquipFormulaPack then
				Image_IconTag:setVisible(true)
				Image_IconTag:loadTexture(getUIImg("Image_EquipTag"..CSV_ItemBase.StarLevel))
			elseif CSV_ItemBase.SubType == NUM_ItemBaseSubType.SoulMaterialPack then
				Image_IconTag:setVisible(true)
				Image_IconTag:loadTexture(getUIImg("Image_SoulTag_"..CSV_ItemBase.ColorType.."_"..CSV_ItemBase.FormulaType))
			elseif CSV_ItemBase.SubType == NUM_ItemBaseSubType.RandomPack then
				Image_IconTag:setVisible(true)
				Image_IconTag:loadTexture(getUIImg("Image_PackRandTag"..CSV_ItemBase.ColorType))
			elseif CSV_ItemBase.SubType == NUM_ItemBaseSubType.SelectedPack then
				Image_IconTag:setVisible(true)
				Image_IconTag:loadTexture(getUIImg("Image_PackSelectTag"..CSV_ItemBase.ColorType))
			else
				Image_IconTag:setVisible(false)
			end
		elseif CSV_ItemBase.Type == NUM_ItemBaseType.EquipFormula then --配方
			Image_RewardFormula:setVisible(true)
			Image_RewardFormula:loadTexture(getUIImg("FrameEquipLight"..CSV_ItemBase.ColorType))
			local Image_Icon = tolua.cast(Image_RewardFormula:getChildByName("Image_Icon"), "ImageView")
			Image_Icon:loadTexture(getIconImg(CSV_ItemBase.Icon))
			local Image_Symbol = tolua.cast(Image_RewardFormula:getChildByName("Image_Symbol"), "ImageView")
			Image_Symbol:loadTexture(getFrameSymbolFormula(CSV_ItemBase.ColorType))
		
			Label_Name:setText(CSV_ItemBase.Name.."×"..CSV_DropItem.DropItemNum)
			Label_Desc:setText(_T("您已获得")..CSV_DropItem.DropItemNum.._T("个").."["..CSV_ItemBase.Name.."]")
		elseif CSV_ItemBase.Type == NUM_ItemBaseType.EquipPackAll then --装备材料包
			Image_RewardEquipPack:setVisible(true)
			Image_RewardEquipPack:loadTexture(getUIImg("FrameEquipLight"..CSV_ItemBase.ColorType))
			local Image_Icon = tolua.cast(Image_RewardEquipPack:getChildByName("Image_Icon"), "ImageView")
			Image_Icon:loadTexture(getIconImg(CSV_ItemBase.Icon))
			local Image_Symbol = tolua.cast(Image_RewardEquipPack:getChildByName("Image_Symbol"), "ImageView")
			Image_Symbol:loadTexture(getIconImg("ResourceItem_MaterialPack"..CSV_ItemBase.ColorType))
		
			Label_Name:setText(CSV_ItemBase.Name.."×"..CSV_DropItem.DropItemNum)
			Label_Desc:setText(_T("您已获得")..CSV_DropItem.DropItemNum.._T("个").."["..CSV_ItemBase.Name.."]")
		else
			--
		end
	elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_SOUL then 	--元神
		local CSV_CardSoul = g_DataMgr:getCardSoulCsv(CSV_DropItem.DropItemID, CSV_DropItem.DropItemStarLevel)
		if not CSV_CardSoul then return end
		Image_RewardSoul:setVisible(true)
		Image_RewardSoul:loadTexture(getUIImg("SummonSoulBase"..CSV_DropItem.DropItemStarLevel))
		local Image_Frame = tolua.cast(Image_RewardSoul:getChildByName("Image_Frame"),"ImageView")
		Image_Frame:loadTexture(getUIImg("SummonSoulCoverB"..CSV_DropItem.DropItemStarLevel))
		local CCSprite_Icon = SpriteCoverlipping(getIconImg(CSV_CardSoul.SpineAnimation), getUIImg("SummonSoulBase"..CSV_DropItem.DropItemStarLevel))
		if CCSprite_Icon ~= nil then
			CCSprite_Icon:setScale(0.98)
			Image_RewardSoul:addNode(CCSprite_Icon, 1)
		end

		local Image_SoulType = tolua.cast(Image_RewardSoul:getChildByName("Image_SoulType"), "ImageView")
		if CSV_CardSoul.Class < 5 then
			Image_SoulType:loadTexture(getUIImg("Image_SoulTag_"..CSV_CardSoul.StarLevel.."_"..CSV_CardSoul.FatherLevel))
		else
			Image_SoulType:loadTexture(getEctypeIconResource("FrameEctypeNormalChar", CSV_CardSoul.StarLevel))
		end
		
		Label_Name:setText(CSV_CardSoul.Name.._T("Lv.")..CSV_CardSoul.Level.." ".."×"..CSV_DropItem.DropItemNum)
		Label_Desc:setText(_T("您已获得")..CSV_DropItem.DropItemNum.._T("个").."["..CSV_CardSoul.Name.."]")
	else	--主角资源数值
		Image_RewardResource:setVisible(true)
		if CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_MASTER_EXP then 	--主角经验
			Label_Name:setText(_T("主角经验"))
			Label_Desc:setText(_T("您已获得")..CSV_DropItem.DropItemNum.._T("点主角经验"))
			local CCSprite_Icon = SpriteCoverlipping(getIconImg("ResourceDrop8_YueLi"), getIconImg("Qishu_Skill1"))
			if CCSprite_Icon ~= nil then
				CCSprite_Icon:setScale(0.98)
				Image_RewardResource:addNode(CCSprite_Icon, 0)
			end
			local Image_Frame = tolua.cast(Image_RewardResource:getChildByName("Image_Frame"),"ImageView")
			Image_Frame:loadTexture(getUIImg("SummonFragCoverB5"))
		elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_MASTER_ENERGY then 	--体力
			Label_Name:setText(_T("体力"))
			Label_Desc:setText(_T("您已获得")..CSV_DropItem.DropItemNum.._T("点体力"))
			local CCSprite_Icon = SpriteCoverlipping(getIconImg("ResourceDrop9_Energy"), getIconImg("Qishu_Skill1"))
			if CCSprite_Icon ~= nil then
				CCSprite_Icon:setScale(0.98)
				Image_RewardResource:addNode(CCSprite_Icon, 0)
			end
			local Image_Frame = tolua.cast(Image_RewardResource:getChildByName("Image_Frame"),"ImageView")
			Image_Frame:loadTexture(getUIImg("SummonFragCoverB5"))
		elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_COUPONS then 	--点券、元宝
			Label_Name:setText(_T("元宝"))
			Label_Desc:setText(_T("您已获得")..CSV_DropItem.DropItemNum.._T("个元宝"))
			local CCSprite_Icon = SpriteCoverlipping(getIconImg("ResourceDrop10_YuanBao"), getIconImg("Qishu_Skill1"))
			if CCSprite_Icon ~= nil then
				CCSprite_Icon:setScale(0.98)
				Image_RewardResource:addNode(CCSprite_Icon, 0)
			end
			local Image_Frame = tolua.cast(Image_RewardResource:getChildByName("Image_Frame"),"ImageView")
			Image_Frame:loadTexture(getUIImg("SummonFragCoverB5"))
		elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_GOLDS then 	--金币、铜钱
			Label_Name:setText(_T("铜钱"))
			Label_Desc:setText(_T("您已获得")..CSV_DropItem.DropItemNum.._T("个铜钱"))
			local CCSprite_Icon = SpriteCoverlipping(getIconImg("ResourceDrop11_TongQian"), getIconImg("Qishu_Skill1"))
			if CCSprite_Icon ~= nil then
				CCSprite_Icon:setScale(0.98)
				Image_RewardResource:addNode(CCSprite_Icon, 0)
			end
			local Image_Frame = tolua.cast(Image_RewardResource:getChildByName("Image_Frame"),"ImageView")
			Image_Frame:loadTexture(getUIImg("SummonFragCoverB5"))
		elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_PRESTIGE then 	--声望
			Label_Name:setText(_T("声望"))
			Label_Desc:setText(_T("您已获得")..CSV_DropItem.DropItemNum.._T("点声望"))
			local CCSprite_Icon = SpriteCoverlipping(getIconImg("ResourceDrop12_Prestige"), getIconImg("Qishu_Skill1"))
			if CCSprite_Icon ~= nil then
				CCSprite_Icon:setScale(0.98)
				Image_RewardResource:addNode(CCSprite_Icon, 0)
			end
			local Image_Frame = tolua.cast(Image_RewardResource:getChildByName("Image_Frame"),"ImageView")
			Image_Frame:loadTexture(getUIImg("SummonFragCoverB5"))
		elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_KNOWLEDGE then 	--阅历
			Label_Name:setText(_T("阅历"))
			Label_Desc:setText(_T("您已获得")..CSV_DropItem.DropItemNum.._T("点阅历"))
			local CCSprite_Icon = SpriteCoverlipping(getIconImg("ResourceDrop13_Knowledge"), getIconImg("Qishu_Skill1"))
			if CCSprite_Icon ~= nil then
				CCSprite_Icon:setScale(0.98)
				Image_RewardResource:addNode(CCSprite_Icon, 0)
			end
			local Image_Frame = tolua.cast(Image_RewardResource:getChildByName("Image_Frame"),"ImageView")
			Image_Frame:loadTexture(getUIImg("SummonFragCoverB5"))
		elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_INCENSE then 	--香贡
			Label_Name:setText(_T("香贡"))
			Label_Desc:setText(_T("您已获得")..CSV_DropItem.DropItemNum.._T("点香贡"))
			local CCSprite_Icon = SpriteCoverlipping(getIconImg("ResourceDrop14_Incense"), getIconImg("Qishu_Skill1"))
			if CCSprite_Icon ~= nil then
				CCSprite_Icon:setScale(0.98)
				Image_RewardResource:addNode(CCSprite_Icon, 0)
			end
			local Image_Frame = tolua.cast(Image_RewardResource:getChildByName("Image_Frame"),"ImageView")
			Image_Frame:loadTexture(getUIImg("SummonFragCoverB5"))
		elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_POWER then 	--神力
			Label_Name:setText(_T("神力"))
			Label_Desc:setText(_T("您已获得")..CSV_DropItem.DropItemNum.._T("点神力"))
			local CCSprite_Icon = SpriteCoverlipping(getIconImg("ResourceDrop19_CardExp"), getIconImg("Qishu_Skill1"))
			if CCSprite_Icon ~= nil then
				CCSprite_Icon:setScale(0.98)
				Image_RewardResource:addNode(CCSprite_Icon, 0)
			end
			local Image_Frame = tolua.cast(Image_RewardResource:getChildByName("Image_Frame"),"ImageView")
			Image_Frame:loadTexture(getUIImg("SummonFragCoverB5"))
		elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_ARENA_TIME then 	--竞技场挑战次数
			Label_Name:setText(_T("天榜次数"))
			Label_Desc:setText(_T("您已获得")..CSV_DropItem.DropItemNum.._T("次天榜次数"))
			local CCSprite_Icon = SpriteCoverlipping(getIconImg("ResourceDrop16_ArenaTimes"), getIconImg("Qishu_Skill1"))
			if CCSprite_Icon ~= nil then
				CCSprite_Icon:setScale(0.98)
				Image_RewardResource:addNode(CCSprite_Icon, 0)
			end
			local Image_Frame = tolua.cast(Image_RewardResource:getChildByName("Image_Frame"),"ImageView")
			Image_Frame:loadTexture(getUIImg("SummonFragCoverB5"))
		elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_ESSENCE then 	--灵力
			Label_Name:setText(_T("灵力"))
			Label_Desc:setText(_T("您已获得")..CSV_DropItem.DropItemNum.._T("点灵力"))
			local CCSprite_Icon = SpriteCoverlipping(getIconImg("ResourceDrop17_Essence"), getIconImg("Qishu_Skill1"))
			if CCSprite_Icon ~= nil then
				CCSprite_Icon:setScale(0.98)
				Image_RewardResource:addNode(CCSprite_Icon, 0)
			end
			local Image_Frame = tolua.cast(Image_RewardResource:getChildByName("Image_Frame"),"ImageView")
			Image_Frame:loadTexture(getUIImg("SummonFragCoverB5"))
		elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_CARDEXPINBATTLE then 	--友情之心
			Label_Name:setText(_T("友情之心"))
			Label_Desc:setText(_T("您已获得")..CSV_DropItem.DropItemNum.._T("个友情之心"))
			local CCSprite_Icon = SpriteCoverlipping(getIconImg("ResourceDrop18_FriendPoints"), getIconImg("Qishu_Skill1"))
			if CCSprite_Icon ~= nil then
				CCSprite_Icon:setScale(0.98)
				Image_RewardResource:addNode(CCSprite_Icon, 0)
			end
			local Image_Frame = tolua.cast(Image_RewardResource:getChildByName("Image_Frame"),"ImageView")
			Image_Frame:loadTexture(getUIImg("SummonFragCoverB5"))
		elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_CARDEXPINBATTLE then 	--伙伴经验
			Label_Name:setText(_T("伙伴经验"))
			Label_Desc:setText(_T("您已获得")..CSV_DropItem.DropItemNum.._T("点伙伴经验"))
			local CCSprite_Icon = SpriteCoverlipping(getIconImg("ResourceDrop19_CardExp"), getIconImg("Qishu_Skill1"))
			if CCSprite_Icon ~= nil then
				CCSprite_Icon:setScale(0.98)
				Image_RewardResource:addNode(CCSprite_Icon, 0)
			end
			local Image_Frame = tolua.cast(Image_RewardResource:getChildByName("Image_Frame"),"ImageView")
			Image_Frame:loadTexture(getUIImg("SummonFragCoverB5"))
		elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIAN_LING then 	--仙令
			Label_Name:setText(_T("仙令"))
			Label_Desc:setText(_T("您已获得")..CSV_DropItem.DropItemNum.._T("个仙令"))
			local CCSprite_Icon = SpriteCoverlipping(getIconImg("ResourceDrop20_XianLing"), getIconImg("Qishu_Skill1"))
			if CCSprite_Icon ~= nil then
				CCSprite_Icon:setScale(0.98)
				Image_RewardResource:addNode(CCSprite_Icon, 0)
			end
			local Image_Frame = tolua.cast(Image_RewardResource:getChildByName("Image_Frame"),"ImageView")
			Image_Frame:loadTexture(getUIImg("SummonFragCoverB5"))
		elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_DRAGON_BALL then 	--神龙令
			Label_Name:setText(_T("神龙令"))
			Label_Desc:setText(_T("您已获得")..CSV_DropItem.DropItemNum.._T("个神龙令"))
			local CCSprite_Icon = SpriteCoverlipping(getIconImg("ResourceDrop21_ShenLongLing"), getIconImg("Qishu_Skill1"))
			if CCSprite_Icon ~= nil then
				CCSprite_Icon:setScale(0.98)
				Image_RewardResource:addNode(CCSprite_Icon, 0)
			end
			local Image_Frame = tolua.cast(Image_RewardResource:getChildByName("Image_Frame"),"ImageView")
			Image_Frame:loadTexture(getUIImg("SummonFragCoverB5"))
		elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_ONE_KEY then 	--一键消除
			Label_Name:setText(_T("一键消除"))
			Label_Desc:setText(_T("您已获得")..CSV_DropItem.DropItemNum.._T("次一键消除技能使用次数"))
			local CCSprite_Icon = SpriteCoverlipping(getIconImg("ResourceItem_XiaoChu1"), getIconImg("Qishu_Skill1"))
			if CCSprite_Icon ~= nil then
				CCSprite_Icon:setScale(0.98)
				Image_RewardResource:addNode(CCSprite_Icon, 0)
			end
			local Image_Frame = tolua.cast(Image_RewardResource:getChildByName("Image_Frame"),"ImageView")
			Image_Frame:loadTexture(getUIImg("SummonFragCoverB5"))
		elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_BA_ZHE then 	--霸者横栏
			Label_Name:setText(_T("霸者横栏"))
			Label_Desc:setText(_T("您已获得")..CSV_DropItem.DropItemNum.._T("次霸者横栏技能使用次数"))
			local CCSprite_Icon = SpriteCoverlipping(getIconImg("ResourceItem_XiaoChu2"), getIconImg("Qishu_Skill1"))
			if CCSprite_Icon ~= nil then
				CCSprite_Icon:setScale(0.98)
				Image_RewardResource:addNode(CCSprite_Icon, 0)
			end
			local Image_Frame = tolua.cast(Image_RewardResource:getChildByName("Image_Frame"),"ImageView")
			Image_Frame:loadTexture(getUIImg("SummonFragCoverB5"))
		elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_LIAN_SUO then 	--消除连锁
			Label_Name:setText(_T("消除连锁"))
			Label_Desc:setText(_T("您已获得")..CSV_DropItem.DropItemNum.._T("次消除连锁技能使用次数"))
			local CCSprite_Icon = SpriteCoverlipping(getIconImg("ResourceItem_XiaoChu3"), getIconImg("Qishu_Skill1"))
			if CCSprite_Icon ~= nil then
				CCSprite_Icon:setScale(0.98)
				Image_RewardResource:addNode(CCSprite_Icon, 0)
			end
			local Image_Frame = tolua.cast(Image_RewardResource:getChildByName("Image_Frame"),"ImageView")
			Image_Frame:loadTexture(getUIImg("SummonFragCoverB5"))
		elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_DOU_ZHUAN then 	--斗转星移
			Label_Name:setText(_T("斗转星移"))
			Label_Desc:setText(_T("您已获得")..CSV_DropItem.DropItemNum.._T("次斗转星移技能使用次数"))
			local CCSprite_Icon = SpriteCoverlipping(getIconImg("ResourceItem_XiaoChu4"), getIconImg("Qishu_Skill1"))
			if CCSprite_Icon ~= nil then
				CCSprite_Icon:setScale(0.98)
				Image_RewardResource:addNode(CCSprite_Icon, 0)
			end
			local Image_Frame = tolua.cast(Image_RewardResource:getChildByName("Image_Frame"),"ImageView")
			Image_Frame:loadTexture(getUIImg("SummonFragCoverB5"))
		elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_DIAN_DAO then 	--颠倒乾坤
			Label_Name:setText(_T("颠倒乾坤"))
			Label_Desc:setText(_T("您已获得")..CSV_DropItem.DropItemNum.._T("次颠倒乾坤技能使用次数"))
			local CCSprite_Icon = SpriteCoverlipping(getIconImg("ResourceItem_XiaoChu5"), getIconImg("Qishu_Skill1"))
			if CCSprite_Icon ~= nil then
				CCSprite_Icon:setScale(0.98)
				Image_RewardResource:addNode(CCSprite_Icon, 0)
			end
			local Image_Frame = tolua.cast(Image_RewardResource:getChildByName("Image_Frame"),"ImageView")
			Image_Frame:loadTexture(getUIImg("SummonFragCoverB5"))
		elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_METAL then 	--金灵核
			Label_Name:setText(_T("金灵核"))
			Label_Desc:setText(_T("您已获得")..CSV_DropItem.DropItemNum.._T("个金灵核作为奖励"))
			local CCSprite_Icon = SpriteCoverlipping(getIconImg("ResourceItem_LingHe1"), getIconImg("Qishu_Skill1"))
			if CCSprite_Icon ~= nil then
				CCSprite_Icon:setScale(0.98)
				Image_RewardResource:addNode(CCSprite_Icon, 0)
			end
			local Image_Frame = tolua.cast(Image_RewardResource:getChildByName("Image_Frame"),"ImageView")
			Image_Frame:loadTexture(getUIImg("SummonFragCoverB5"))
		elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_NATURE then 	--木灵核
			Label_Name:setText(_T("木灵核"))
			Label_Desc:setText(_T("您已获得")..CSV_DropItem.DropItemNum.._T("个木灵核作为奖励"))
			local CCSprite_Icon = SpriteCoverlipping(getIconImg("ResourceItem_LingHe2"), getIconImg("Qishu_Skill1"))
			if CCSprite_Icon ~= nil then
				CCSprite_Icon:setScale(0.98)
				Image_RewardResource:addNode(CCSprite_Icon, 0)
			end
			local Image_Frame = tolua.cast(Image_RewardResource:getChildByName("Image_Frame"),"ImageView")
			Image_Frame:loadTexture(getUIImg("SummonFragCoverB5"))
		elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_WATER then 	--水灵核
			Label_Name:setText(_T("水灵核"))
			Label_Desc:setText(_T("您已获得")..CSV_DropItem.DropItemNum.._T("个水灵核作为奖励"))
			local CCSprite_Icon = SpriteCoverlipping(getIconImg("ResourceItem_LingHe3"), getIconImg("Qishu_Skill1"))
			if CCSprite_Icon ~= nil then
				CCSprite_Icon:setScale(0.98)
				Image_RewardResource:addNode(CCSprite_Icon, 0)
			end
			local Image_Frame = tolua.cast(Image_RewardResource:getChildByName("Image_Frame"),"ImageView")
			Image_Frame:loadTexture(getUIImg("SummonFragCoverB5"))
		elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_FIRE then 	--火灵核
			Label_Name:setText(_T("火灵核"))
			Label_Desc:setText(_T("您已获得")..CSV_DropItem.DropItemNum.._T("个火灵核作为奖励"))
			local CCSprite_Icon = SpriteCoverlipping(getIconImg("ResourceItem_LingHe4"), getIconImg("Qishu_Skill1"))
			if CCSprite_Icon ~= nil then
				CCSprite_Icon:setScale(0.98)
				Image_RewardResource:addNode(CCSprite_Icon, 0)
			end
			local Image_Frame = tolua.cast(Image_RewardResource:getChildByName("Image_Frame"),"ImageView")
			Image_Frame:loadTexture(getUIImg("SummonFragCoverB5"))
		elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_EARTH then 	--土灵核
			Label_Name:setText(_T("土灵核"))
			Label_Desc:setText(_T("您已获得")..CSV_DropItem.DropItemNum.._T("个土灵核作为奖励"))
			local CCSprite_Icon = SpriteCoverlipping(getIconImg("ResourceItem_LingHe5"), getIconImg("Qishu_Skill1"))
			if CCSprite_Icon ~= nil then
				CCSprite_Icon:setScale(0.98)
				Image_RewardResource:addNode(CCSprite_Icon, 0)
			end
			local Image_Frame = tolua.cast(Image_RewardResource:getChildByName("Image_Frame"),"ImageView")
			Image_Frame:loadTexture(getUIImg("SummonFragCoverB5"))
		elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_AIR then 	--风灵核
			Label_Name:setText(_T("风灵核"))
			Label_Desc:setText(_T("您已获得")..CSV_DropItem.DropItemNum.._T("个风灵核作为奖励"))
			local CCSprite_Icon = SpriteCoverlipping(getIconImg("ResourceItem_LingHe6"), getIconImg("Qishu_Skill1"))
			if CCSprite_Icon ~= nil then
				CCSprite_Icon:setScale(0.98)
				Image_RewardResource:addNode(CCSprite_Icon, 0)
			end
			local Image_Frame = tolua.cast(Image_RewardResource:getChildByName("Image_Frame"),"ImageView")
			Image_Frame:loadTexture(getUIImg("SummonFragCoverB5"))
		elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_LIGHTNING then 	--雷灵核
			Label_Name:setText(_T("雷灵核"))
			Label_Desc:setText(_T("您已获得")..CSV_DropItem.DropItemNum.._T("个雷灵核作为奖励"))
			local CCSprite_Icon = SpriteCoverlipping(getIconImg("ResourceItem_LingHe7"), getIconImg("Qishu_Skill1"))
			if CCSprite_Icon ~= nil then
				CCSprite_Icon:setScale(0.98)
				Image_RewardResource:addNode(CCSprite_Icon, 0)
			end
			local Image_Frame = tolua.cast(Image_RewardResource:getChildByName("Image_Frame"),"ImageView")
			Image_Frame:loadTexture(getUIImg("SummonFragCoverB5"))
		elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_SECRET_JIANGHUN then 	--将魂石
			Label_Name:setText(_T("将魂石"))
			Label_Desc:setText(_T("您已获得")..CSV_DropItem.DropItemNum.._T("个将魂石作为奖励"))
			local CCSprite_Icon = SpriteCoverlipping(getIconImg("ResourceDrop40_JiangHunShi"), getIconImg("Qishu_Skill1"))
			if CCSprite_Icon ~= nil then
				CCSprite_Icon:setScale(0.98)
				Image_RewardResource:addNode(CCSprite_Icon, 0)
			end
			local Image_Frame = tolua.cast(Image_RewardResource:getChildByName("Image_Frame"),"ImageView")
			Image_Frame:loadTexture(getUIImg("SummonFragCoverB5"))
		elseif CSV_DropItem.DropItemType == macro_pb.ITEM_TYPE_SECRET_REFRESH_TOKEN then 	--将魂令
			Label_Name:setText(_T("将魂令"))
			Label_Desc:setText(_T("您已获得")..CSV_DropItem.DropItemNum.._T("个将魂令作为奖励"))
			local CCSprite_Icon = SpriteCoverlipping(getIconImg("ResourceDrop41_RefreshToken"), getIconImg("Qishu_Skill1"))
			if CCSprite_Icon ~= nil then
				CCSprite_Icon:setScale(0.98)
				Image_RewardResource:addNode(CCSprite_Icon, 0)
			end
			local Image_Frame = tolua.cast(Image_RewardResource:getChildByName("Image_Frame"),"ImageView")
			Image_Frame:loadTexture(getUIImg("SummonFragCoverB5"))
		end
	end
	
	local Image_Arrow = tolua.cast(Image_TipDropRewardPNL:getChildByName("Image_Arrow"), "ImageView")
	g_CreateUpAndDownAnimation(Image_Arrow)
end

function Game_TipDropReward:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_TipDropRewardPNL = tolua.cast(self.rootWidget:getChildByName("Image_TipDropRewardPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_TipDropRewardPNL, funcWndOpenAniCall, 1.05, 0.2)
end
function Game_TipDropReward:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_TipDropRewardPNL = tolua.cast(self.rootWidget:getChildByName("Image_TipDropRewardPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_TipDropRewardPNL, funcWndCloseAniCall, 1.05, 0.2)
end

--[[接口协议
CSV_DropItem = {
	DropItemType,
	DropItemID,
	DropItemStarLevel,
	DropItemNum,
	DropItemEvoluteLevel,
	wndCloseEevent,
}
]]--

function g_ShowSingleRewardBox(CSV_DropItem)
	if not CSV_DropItem then return cclog("==========CSV_DropItem Is Nil==============") end
	g_WndMgr:showWnd("Game_TipDropReward", CSV_DropItem)
end