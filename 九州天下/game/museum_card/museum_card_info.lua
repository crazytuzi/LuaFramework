MuseumCardInfo = MuseumCardInfo or BaseClass(BaseView)

function MuseumCardInfo:__init()
	self.ui_config = {"uis/views/museumcardview", "MuseumCardInfo"}
	self:SetMaskBg()
	self.play_audio = true
	self.is_async_load = false
	self.active_close = false

	self.cur_select_file = 1
	self.cur_select_chapter = 1
	self.cur_select_card = 1
	self.card_seq = 1
end

function MuseumCardInfo:__delete()
end

function MuseumCardInfo:ReleaseCallBack()
	self.card_name = nil
	self.card_img = nil
	self.card_quality = nil
	self.card_desc = nil
	self.fight_power = nil
	self.gong_ji = nil
	self.fang_yu = nil
	self.max_hp = nil
	self.spec_attr_value1 = nil
	self.spec_attr_value2 = nil
	self.spec_attr_name1 = nil
	self.spec_attr_name2 = nil
	self.show_effect = nil
	self.item_num = nil

	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	self.star_list = {}
end

function MuseumCardInfo:LoadCallBack()
	self.card_name = self:FindVariable("CardName")
	self.card_img = self:FindVariable("CardImg")
	self.card_quality = self:FindVariable("CardQuality")
	self.card_desc = self:FindVariable("CardDesc")
	self.fight_power = self:FindVariable("FightPower")
	self.gong_ji = self:FindVariable("GongJi")
	self.fang_yu = self:FindVariable("FangYu")
	self.max_hp = self:FindVariable("MaxHp")
	self.spec_attr_value1 = self:FindVariable("SpecAttrValue1")
	self.spec_attr_value2 = self:FindVariable("SpecAttrValue2")
	self.spec_attr_name1 = self:FindVariable("SpecAttrName1")
	self.spec_attr_name2 = self:FindVariable("SpecAttrName2")
	self.show_effect = self:FindVariable("ShowEffect")
	self.item_num = self:FindVariable("ItemNum")
	self.item_cell = ItemCell.New()
  	self.item_cell:SetInstanceParent(self:FindObj"ItemCell")

	self.star_list = {}
	for i = 1, 10 do
		self.star_list[i] = self:FindVariable("Star" .. i)
	end

	self:ListenEvent("OnClickFenJie", BindTool.Bind(self.OnClickFenJie, self))
	self:ListenEvent("OnClickUpStar", BindTool.Bind(self.OnClickUpStar, self))
	self:ListenEvent("OnClickAutoUpStar", BindTool.Bind(self.OnClickAutoUpStar, self))
	self:ListenEvent("OnClose", BindTool.Bind(self.Close, self))
end

function MuseumCardInfo:SetData(file_id, chapter_id, card_id)
	self.cur_select_file = file_id
	self.cur_select_chapter = chapter_id
	self.cur_select_card = card_id
end

function MuseumCardInfo:OpenCallBack()
	MuseumCardCtrl.Instance:SendCommonOperateReq(RA_MUSEUM_CARD_OPERA_TYPE.RA_MUSEUM_CARD_OPERA_TYPE_ALL_INFO)
end

function MuseumCardInfo:OnFlush(param_t)
	for k ,v in pairs(param_t) do
		if k == "all" then
			local card_data = MuseumCardData.Instance:GetCardCfgByFileAndChap(self.cur_select_file, self.cur_select_chapter)
			local card_info = card_data[self.cur_select_card]
			self.card_name:SetValue(card_info.card_name)
			self.card_desc:SetValue(card_info.card_message)

			self.card_img:SetAsset(ResPath.GetMuseumCardImage("card_" .. self.cur_select_file .. "_" .. self.cur_select_chapter .. "_" .. self.cur_select_card))
			self.card_quality:SetAsset(ResPath.GetMuseumCardImage("quality_" .. card_info.quality))

			self.gong_ji:SetValue(card_info.gongji)
			self.fang_yu:SetValue(card_info.fangyu)
			self.max_hp:SetValue(card_info.maxhp)
			self.spec_attr_value1:SetValue(card_info.special_gongji)

			local power = CommonDataManager.GetCapabilityCalculation(card_info)
			self.fight_power:SetValue(power + card_info.capability)

			local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
			self.spec_attr_name1:SetValue(Language.MuseumCard.GongJiName[main_role_vo.prof])
			self.spec_attr_name2:SetValue(Language.MuseumCard.FangYuName[card_info.special_fangyu_type])

			self.show_effect:SetValue(card_info.quality == MuseumCardData.CardQuality.PURPLE)
		elseif k == "card_state" then
			local card_data = MuseumCardData.Instance:GetCardCfgByFileAndChap(self.cur_select_file, self.cur_select_chapter)
			local card_cfg = card_data[self.cur_select_card]
			self.card_seq = card_data[self.cur_select_card].card_seq
			local card_info = MuseumCardData.Instance:GetCardStateInfoBySeq(self.card_seq)
			for i = 1, 10 do
				if card_info.card_level < i then
					self.star_list[i]:SetAsset(ResPath.GetImages("star_0"))
				else
					self.star_list[i]:SetAsset(ResPath.GetImages("star_1002"))
				end
			end

			local next_upstar_info = MuseumCardData.Instance:GetCardUpStarCfgByQualAndLv(card_cfg.quality, card_info.card_level + 1)
			local upstar_info = MuseumCardData.Instance:GetCardUpStarCfgByQualAndLv(card_cfg.quality, card_info.card_level)
			
			local need_item = next_upstar_info.need_item or upstar_info.need_item

			self.item_cell:SetData(need_item)
			self.item_cell:SetNum(0)
			local item_num = ItemData.Instance:GetItemNumInBagById(need_item.item_id)
			if item_num >= need_item.num then
				self.item_num:SetValue(string.format(Language.MuseumCard.ItemNum, item_num .. "/" .. ToColorStr(need_item.num, TEXT_COLOR.GREEN)))
			else
				self.item_num:SetValue(string.format(Language.MuseumCard.ItemNum, item_num .. "/" .. ToColorStr(need_item.num, TEXT_COLOR.RED)))
			end

			local card_attr_info = {}
			card_attr_info.gongji = card_cfg.gongji + (upstar_info.gongji or 0)
			card_attr_info.fangyu = card_cfg.fangyu + (upstar_info.fangyu or 0)
			card_attr_info.maxhp = card_cfg.maxhp + (upstar_info.maxhp or 0)

			self.gong_ji:SetValue(card_attr_info.gongji)
			self.fang_yu:SetValue(card_attr_info.fangyu)
			self.max_hp:SetValue(card_attr_info.maxhp)
			self.spec_attr_value2:SetValue(upstar_info.special_fangyu or 0)

			local power = CommonDataManager.GetCapabilityCalculation(card_attr_info)
			self.fight_power:SetValue(power + card_cfg.capability + (upstar_info.extra_cap or 0))
		end
	end
end

function MuseumCardInfo:FlushUpStarResult(result)
	if result == 0 then
		self.is_auto = false
	elseif result == 1 then
		self:AutoUpStarOnce()
	end
end

function MuseumCardInfo:OnClickFenJie()
	ViewManager.Instance:Open(ViewName.MuseumCardFenJie)
end

function MuseumCardInfo:OnClickUpStar()
	MuseumCardCtrl.Instance:SendCommonOperateReq(RA_MUSEUM_CARD_OPERA_TYPE.RA_MUSEUM_CARD_OPERA_TYPE_UPSTAR, self.card_seq)
end

function MuseumCardInfo:OnClickAutoUpStar()
	self.is_auto = true
	MuseumCardCtrl.Instance:SendCommonOperateReq(RA_MUSEUM_CARD_OPERA_TYPE.RA_MUSEUM_CARD_OPERA_TYPE_UPSTAR, self.card_seq, 1)
end

function MuseumCardInfo:AutoUpStarOnce()
	local upgrade_next_time = 0
	if self.upgrade_timer_quest then
		if self.upgrade_next_time >= Status.NowTime then
			upgrade_next_time = self.upgrade_next_time - Status.NowTime
		end
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
	end
	if self.is_auto then
		self.upgrade_timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.UpdateOcne, self), upgrade_next_time)
	end
end

function MuseumCardInfo:UpdateOcne(upgrade_next_time)
	local is_auto = self.is_auto and 1 or 0
	MuseumCardCtrl.Instance:SendCommonOperateReq(RA_MUSEUM_CARD_OPERA_TYPE.RA_MUSEUM_CARD_OPERA_TYPE_UPSTAR, self.card_seq, is_auto)

	self.upgrade_next_time = Status.NowTime + 0.1
end