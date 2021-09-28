module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_battleEquip = i3k_class("wnd_battleEquip", ui.wnd_base)
local HuanXing = 4 --时装幻形页签
function wnd_battleEquip:ctor()

end
function wnd_battleEquip:configure()
    --装备推荐相关界面
	local batterequip = {}
	batterequip.BatterEquipRoot = self._layout.vars.BatterEquipRoot
	batterequip.EquipItem_bg = self._layout.vars.EquipItem_bg
	batterequip.EquipItem_icon = self._layout.vars.EquipItem_icon
	batterequip.EquipItem_btn = self._layout.vars.EquipItem_btn
	batterequip.BatterEquipPanel = self._layout.vars.BatterEquipPanel
	batterequip.BatterEquipClose = self._layout.vars.BatterEquipClose

    self._widgets = {}
	self._widgets.batterequip = batterequip
	self.flag = 0 -- flag值用来区分加载哪种进度条
	self.tag = 0
end
function wnd_battleEquip:refresh(args, taskCat, isDesertBattle)
	if args == nil then
		if isDesertBattle then
			self:onUpdateDesertBattleEquip()
		else
    	self:onUpdateBatterEquipShow()
		self:onUpdateItemTip()
		end
	else
		self:updateTaskItemRoot(args, taskCat)
		self.tag = args
	end
end

function wnd_battleEquip:isShowUI()
	return self._layout.vars.BatterEquipRoot:isVisible()
end



function wnd_battleEquip:updateTaskItemRoot(args, taskCat)
	self:show()
	self._widgets.batterequip.EquipItem_bg:setImage(g_i3k_get_icon_frame_path_by_rank(g_i3k_db.i3k_db_get_common_item_rank(args)))
	self._widgets.batterequip.EquipItem_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(args,i3k_game_context:IsFemaleRole()))
	self._widgets.batterequip.EquipItem_icon:setTag(args)
	self._widgets.batterequip.BatterEquipClose:hide() -- 隐藏关闭按钮
	self._layout.vars.BtnLabel:setText("使用")
	self._layout.vars.newImage:hide() -- 隐藏 “new”
	self._widgets.batterequip.EquipItem_btn:setTag(args)
	self._widgets.batterequip.EquipItem_btn:onClick(self,self.onUseItemAtPosition, {args = args, taskCat = taskCat})
end

function wnd_battleEquip:onUseItemAtPosition(sender, data)
	g_i3k_game_context:StopMove()

	if  data.taskCat == i3k_get_MrgTaskCategory() and g_i3k_game_context:CoupleDoTask(true,true) then
		return
	end
	self.flag=2
	self.tag = sender:getTag()
	g_i3k_ui_mgr:OpenUI(eUIID_BattleProcessBar)
	g_i3k_ui_mgr:RefreshUI(eUIID_BattleProcessBar,self.flag,self.tag,false, data.args, data.taskCat)
	g_i3k_game_context:ResetCurrTaskType()
	g_i3k_ui_mgr:CloseUI(eUIID_BattleEquip)
end

-- 0 挖矿结束，1可以挖矿，2正在挖矿
function wnd_battleEquip:updateMinePanel(status)
	self._widgets.batterequip.EquipItem_btn:onClick(self,self.onDigClick)
	g_i3k_ui_mgr:CloseUI(eUIID_BattleProcessBar)
	if status == 0 then
		g_i3k_ui_mgr:CloseUI(eUIID_BattleEquip)
	end
	if status == 1 then
		local MineInfo = g_i3k_game_context:GetMineInfo()
		self._widgets.batterequip.BatterEquipClose:hide() -- 隐藏关闭按钮
		self._layout.vars.newImage:hide() -- 隐藏 “new”
		self._widgets.batterequip.EquipItem_icon:setImage(i3k_db_icons[MineInfo._gcfg.headID].path)
		self._widgets.batterequip.EquipItem_bg:setImage(g_i3k_get_icon_frame_path_by_rank(1))
		self._layout.vars.BtnLabel:setText(MineInfo._gcfg.mineText)
		self.flag = 0
		self._mineactiontime = 0
	elseif status == 2 then
		self.flag=1
		self._mineactiontime = 0.01
		g_i3k_ui_mgr:OpenUI(eUIID_BattleProcessBar)
		g_i3k_ui_mgr:RefreshUI(eUIID_BattleProcessBar,self.flag,self.tag,true) -- show cancel btn
		g_i3k_ui_mgr:CloseUI(eUIID_BattleEquip)
	end
end

function wnd_battleEquip:onDigClick(sender)
	if g_i3k_game_context:getMineTaskType() == i3k_get_MrgTaskCategory() and g_i3k_game_context:CoupleDoTask(true,true) then
		return
	end

	local hero = i3k_game_get_player_hero();
	if hero then
		hero:PlayerDigMineStart()
	end
end


function wnd_battleEquip:onUpdateBatterEquipShow()
	local isShow = false
	self._widgets.batterequip.BatterEquipPanel:setVisible(false)
	for i = 1, eEquipCount do
		if g_i3k_game_context:GetBetterEquipStatusByPartID(i) then
			isShow = true
			self._widgets.batterequip.BatterEquipPanel:setVisible(true)
			local temp_pos,best_equip = g_i3k_game_context:GetBestEquipInfo()
			for k,v in pairs(temp_pos) do
				if v == i then
					local equip = best_equip[k]
					local rank = g_i3k_db.i3k_db_get_common_item_rank(equip.id)
					self._widgets.batterequip.EquipItem_bg:setImage(g_i3k_get_icon_frame_path_by_rank(rank))
					self._widgets.batterequip.EquipItem_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(equip.id,i3k_game_context:IsFemaleRole()))
					self._widgets.batterequip.EquipItem_btn:onClick(self, self.onBatterEquipClick,i)
				end
			end
			self._widgets.batterequip.BatterEquipClose:onClick(self, self.onBatterEquipCloseClicked,i)
			break;
		end
	end
	-- if not isShow and not g_i3k_game_context:getNewItemCheckId() then
	-- 	g_i3k_ui_mgr:CloseUI(eUIID_BattleEquip)
	-- end
end

function wnd_battleEquip:onBatterEquipClick(sender,args)
	local partID = args
	local equipNotFound = true
	local temp_pos,best_equip = g_i3k_game_context:GetBestEquipInfo()
	for k,v in pairs(temp_pos) do
		if v == partID then
			equipNotFound = false
			local wearEquips = g_i3k_game_context:GetWearEquips()
			local _data = wearEquips[partID].equip
			if _data and _data.smeltingProps and next(_data.smeltingProps) then
				local callback = function (isOk)
					if isOk then
						g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleEquip, "upWearEquip", best_equip[k], partID)
					end
				end
				g_i3k_ui_mgr:ShowCustomMessageBox2(i3k_get_string(1833), i3k_get_string(1834), i3k_get_string(1832), callback)
			else
				self:upWearEquip(best_equip[k], partID)
			end
			break;
		end
	end
	if equipNotFound then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(745))
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "onUpdateBatterEquipShow")
	end
end
function wnd_battleEquip:upWearEquip(equip, partID)
			if equip.id < 0 then
				local fun = (function(ok)
					if ok then
						i3k_sbean.equip_upwear(equip.id, equip.guids, partID)
						g_i3k_ui_mgr:CloseUI(eUIID_EquipTips)
						g_i3k_ui_mgr:CloseUI(eUIID_FlyingEquipInfo)
					end
				end)
				g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(292), fun)
			else
				i3k_sbean.equip_upwear(equip.id, equip.guids, partID)
	end
end

function wnd_battleEquip:onBatterEquipCloseClicked(sender,args)
	g_i3k_game_context:SetBetterEquipStatusByPartID(args,false)
	-- self:onUpdateBatterEquipShow()
	g_i3k_ui_mgr:CloseUI(eUIID_BattleEquip)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase,"onUpdateBatterEquipShow")
end

--决战荒漠快捷穿戴
function wnd_battleEquip:onUpdateDesertBattleEquip()
	self._widgets.batterequip.BatterEquipPanel:setVisible(false)
	--部位数读配置
	for partID = 1, #i3k_db_desert_battle_equip_part do
		if g_i3k_game_context:GetDesertBetterEquipStateByPartID(partID) then
			self._widgets.batterequip.BatterEquipPanel:setVisible(true)
			local _, equips = g_i3k_game_context:GetDesertBestEquipInfo()
			for k in pairs(equips) do
				if k == partID then
					local equipID = equips[k]
					local rank = g_i3k_db.i3k_db_get_common_item_rank(equipID)
					self._widgets.batterequip.EquipItem_bg:setImage(g_i3k_get_icon_frame_path_by_rank(rank))
					self._widgets.batterequip.EquipItem_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(equipID, g_i3k_game_context:IsFemaleRole()))
					self._widgets.batterequip.EquipItem_btn:onClick(self, self.onWearDesertEquip, partID)
				end
			end
			self._widgets.batterequip.BatterEquipClose:onClick(self, self.onCloseDesertEquip, partID)
			break
		end
	end
end
function wnd_battleEquip:onWearDesertEquip(sender, partID)
	local equipNotFound = true
	local _, equips = g_i3k_game_context:GetDesertBestEquipInfo()
	for k in pairs(equips) do
		if k == partID then
			equipNotFound = false
			local equipID = equips[k]
			i3k_sbean.survive_equip_upwear({[partID] = equipID})
			break
		end
	end
	if equipNotFound then
		g_i3k_game_context:SetDesertBetterEquipStateByPartID(partID, false)
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(745))
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "onUpdateDesertBetterEquipShow")
	end
end
function wnd_battleEquip:onCloseDesertEquip(sender, partID)
	g_i3k_game_context:SetDesertBetterEquipStateByPartID(partID, false)
	g_i3k_ui_mgr:CloseUI(eUIID_BattleEquip)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "onUpdateDesertBetterEquipShow")
end

-- 道具提示使用
function wnd_battleEquip:onUpdateItemTip()
	local item = g_i3k_game_context:getNewItemCheckId()
	if not item and not g_i3k_game_context:GetBatterEquipStatus() then
		g_i3k_ui_mgr:CloseUI(eUIID_BattleEquip)
		return
	end
	if item == nil or g_i3k_game_context:GetBatterEquipStatus() then
		return
	end
	self._widgets.batterequip.BatterEquipPanel:setVisible(true)
	local rank = g_i3k_db.i3k_db_get_other_item_cfg(item).rank
	self._layout.vars.BtnLabel:setText("使用")
	self._layout.vars.newImage:hide() -- 隐藏 “new”
	self._widgets.batterequip.EquipItem_bg:setImage(g_i3k_get_icon_frame_path_by_rank(rank))
	self._widgets.batterequip.EquipItem_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(item,i3k_game_context:IsFemaleRole()))
	self._widgets.batterequip.EquipItem_btn:onClick(self, self.onItemTipClick, item)
	self._widgets.batterequip.BatterEquipClose:onClick(self, self.onItemTipCloseClicked)
end

function wnd_battleEquip:onSuperWeaponUnlock()
	local widget = self._layout.vars
	local superWeaponID = g_i3k_game_context:GetSelectWeapon()
	local imageID = i3k_db_shen_bing[superWeaponID].fullMasterIconID
	widget.BatterEquipPanel:setVisible(true)
	widget.newImage:setVisible(false)
	widget.EquipItem_bg:setImage(g_i3k_db.i3k_db_get_icon_path(imageID))
	widget.EquipItem_icon:setVisible(false)
	widget.BtnLabel:setText(i3k_get_string(1581))
	widget.EquipItem_btn:onClick(self, self.onSuperWeaponUnlockClick)
	widget.BatterEquipClose:onClick(self, self.onItemTipCloseClicked, true)
end
function wnd_battleEquip:onItemTipClick(sender, itemId)
	local item_cfg = g_i3k_db.i3k_db_get_other_item_cfg(itemId)
	if item_cfg.isShowTip == 1 then
		if item_cfg.type == UseItemFirework then
			self:useFireWork(itemId)
		else
			self:onItemTipJumpUI(item_cfg.jumpUIID)
		end
	elseif item_cfg.type == UseItemFashion then -- 时装
		local cfg = g_i3k_db.i3k_db_get_fashion_cfg(item_cfg.args1)
		self:onItemTipFashion(cfg.fashionType)
	elseif item_cfg.type == UseItemHouseSkin then -- 家园装扮
		i3k_sbean.bag_use_house_skin_item(itemId)
	elseif item_cfg.type == UseItemDiaryDecorate then -- 心情日记装扮
		local itemCfg = g_i3k_db.i3k_db_get_other_item_cfg(itemId)
		local callback = function ()
			g_i3k_ui_mgr:OpenUI(eUIID_MoodDiaryBeauty)
			g_i3k_ui_mgr:RefreshUI(eUIID_MoodDiaryBeauty)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_MoodDiaryBeauty, "changeDecoration", nil, itemCfg.args1)
		end
		i3k_sbean.mood_diary_open_main_page(1, g_i3k_game_context:GetRoleId(), callback)
	elseif item_cfg.type == UseItemHeadPreview then -- 头像
		g_i3k_logic:OpenMyUI()
	elseif item_cfg.type == UseItemUniqueSkill then --绝技道具
		if g_i3k_db.i3k_db_get_isown_from_itemid(itemId) then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(958))
		else
			g_i3k_logic:OpeneUniqueskillPreviewUI(itemId)
		end
	elseif item_cfg.type == UseItemEscortCar then
		g_i3k_ui_mgr:OpenUI(eUIID_FactionEscort)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionEscort,"onUpdateSkin")
	elseif item_cfg.type == UseItemVit then
		if g_i3k_game_context:GetVitMax() <= g_i3k_game_context:GetVit() then
			g_i3k_ui_mgr:PopupTipMessage("体力已满")
		else
			self:onItemTipNormal(itemId)
		end
	elseif item_cfg.type == UseItemMetamorphosis then --幻形快捷使用
		self:onItemTipFashion(HuanXing)
	else
		self:onItemTipNormal(itemId) -- 正常逻辑类型道具
	end
	g_i3k_game_context:tryRemoveNewItemCheck()
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase,"onItemTipsShow")
end
function wnd_battleEquip:onSuperWeaponUnlockClick(sender)
	local allData, useID = g_i3k_game_context:GetShenbingData()
	g_i3k_ui_mgr:CloseUI(eUIID_BattleEquip)
	g_i3k_ui_mgr:OpenUI(eUIID_ShenBing)
	g_i3k_ui_mgr:RefreshUI(eUIID_ShenBing, useID)
	g_i3k_ui_mgr:OpenUI(eUIID_ShenBing_UniqueSkill)
	g_i3k_ui_mgr:RefreshUI(eUIID_ShenBing_UniqueSkill, useID)
end

function wnd_battleEquip:useFireWork(id)
	i3k_sbean.playFirework(id)
end

function wnd_battleEquip:onItemTipJumpUI(uiid)
	g_i3k_logic:JumpUIID(uiid)
end

function wnd_battleEquip:onItemTipFashion(showType)
	g_i3k_logic:OpenFashionDressUI(showType)
end

function wnd_battleEquip:onItemTipNormal(itemId)
	local item_cfg = g_i3k_db.i3k_db_get_other_item_cfg(itemId)
	local needItemId, needItemCount = g_i3k_db.i3k_db_get_day_use_consume_info(itemId)
	if g_i3k_db.i3k_db_get_bag_item_limitable(itemId) then
		local dayUseTimes, canAddMaxTimes, needVipLvl = g_i3k_db.i3k_db_get_day_use_item_day_use_times(itemId)
		if dayUseTimes ~= 0 then
			if needItemId == 0 or needItemCount == 0 then
				g_i3k_ui_mgr:OpenUI(eUIID_UseLimitItems)
				g_i3k_ui_mgr:RefreshUI(eUIID_UseLimitItems, itemId, item_cfg.type)
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_UseLimitItems, "onMax", nil, ccui.TouchEventType.ended)
			else
				g_i3k_ui_mgr:OpenUI(eUIID_UseLimitConsumeItems)
				g_i3k_ui_mgr:RefreshUI(eUIID_UseLimitConsumeItems, itemId, item_cfg.type)
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_UseLimitConsumeItems, "onMax", nil, ccui.TouchEventType.ended)
			end
		elseif canAddMaxTimes > 0 and needVipLvl > 0 then
			local fun = (function(ok)
				if ok then
					g_i3k_logic:OpenChannelPayUI()
				end
			end)
			g_i3k_ui_mgr:ShowCustomMessageBox2("升级贵族", "确定", i3k_get_string(289, needVipLvl), fun)
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(291))
		end
	else
		if not g_i3k_game_context:checkItemMailType(itemId) then -- 如果不是信件类型
			g_i3k_ui_mgr:OpenUI(eUIID_UseItems)
			g_i3k_ui_mgr:RefreshUI(eUIID_UseItems, itemId, item_cfg.type)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_UseItems, "checkItemCountEqualOne")
		else
			g_i3k_game_context:canOpenMailItemUI(itemId)
		end
	end
end

function wnd_battleEquip:onJoySendClick( )
	self._widgets.batterequip.EquipItem_btn:sendClick()
end

function wnd_battleEquip:onItemTipCloseClicked(sender, isSuperWeapon)
	if isSuperWeapon then
		g_i3k_ui_mgr:CloseUI(eUIID_BattleEquip)
	else
	g_i3k_game_context:tryRemoveNewItemCheck()
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase,"onItemTipsShow")
	end
end


function wnd_create(layout)
	local wnd = wnd_battleEquip.new();
		wnd:create(layout);
	return wnd;
end
