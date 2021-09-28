-- zengqingfeng
-- 2018/4/16
--eUIID_WeaponEffect --huanling
-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_weapon_effect = i3k_class("weapon_effect", ui.wnd_base)

local WEAPON_EFFECT_ITEM = "ui/widgets/huanlingt"
local EFFECT_POS = eEquipWeapon
local STATE_LOCK = 1
local STATE_UNLOCK = 2 
local STATE_USE = 3
local EQ_GROW_LVL = 10 --暂时写死武器升级等级


function wnd_weapon_effect:ctor()
	self._allEffectInfo = nil --展示出来可以选择的特效信息
end

function wnd_weapon_effect:configure()
	local widgets = self._layout.vars

	widgets.close_btn:onClick(self,self.onCloseUI)
	
	self._scroll = widgets.notice_content
end

function wnd_weapon_effect:onShow()
	self:initItems()  
end

function wnd_weapon_effect:onHide()

end 

function wnd_weapon_effect:refresh()
	self:updateItems()
end 

function wnd_weapon_effect:initItems()
	local scrollView = self._scroll
	scrollView:removeAllChildren()
	local allEffectInfo = self:getAllEffectInfoCfg()
	for i, v in ipairs(allEffectInfo) do 
		local item = require(WEAPON_EFFECT_ITEM)()
		local widgets = item.vars 
		widgets.cfg = v 
		widgets.name:setText(g_i3k_game_context:getWeaponEffectName(v.starLower))
		--g_i3k_game_context:ResetTestFashionData()
		local equipInfo = g_i3k_game_context:GetWearEquips()
		equipInfo = clone(equipInfo)
		equipInfo[EFFECT_POS].eqGrowLvl = EQ_GROW_LVL
		equipInfo[EFFECT_POS].eqEvoLvl = v.starLower
		equipInfo[EFFECT_POS].effectInfo = nil 
		ui_set_hero_model(widgets.modle, i3k_game_get_player_hero(), equipInfo, g_i3k_game_context:GetIsShwoFashion())
		scrollView:addItem(item)
	end
end 

function wnd_weapon_effect:getAllEffectInfoCfg()
	if self._allEffectInfo then 
		return self._allEffectInfo
	end 
	local allEffectInfo = {}
	local curEqGrowLvl = EQ_GROW_LVL 
	local weaponEquip = g_i3k_game_context:getWeaponEquip()
	local startEvoLvl = i3k_db_common.equip.weaponEffectUseLvl
	local roleType = g_i3k_game_context:GetRoleType()
	local equipInfo = g_i3k_game_context:GetWearEquips()
	local equipId = equipInfo[EFFECT_POS] and equipInfo[EFFECT_POS].equip and equipInfo[EFFECT_POS].equip.equip_id
	if equipId then 
		for i = 1, #i3k_db_equip_effect do --筛选符合职业装备位置强化等级标准的cfg
			local cfg = i3k_db_equip_effect[i]
			if roleType == cfg.classType and cfg.posType == EFFECT_POS then
				if curEqGrowLvl >= cfg.strengLower and 
				   curEqGrowLvl <= cfg.strengUpper and 
				   startEvoLvl <= cfg.starUpper then
						table.insert(allEffectInfo, cfg)
				end
			end
		end
	end 
	self._allEffectInfo = allEffectInfo
	return allEffectInfo
end 

--每次数据变化是刷新全部item
--如果以后item太多可以保存上一个设置每次仅仅刷新两个item（新旧）
function wnd_weapon_effect:updateItems()  
	local curEvoLvl = g_i3k_game_context:getEffectEvoLvl()
	local items = self._scroll:getAllChildren() 
	for i, item in ipairs(items) do 
		self:updateItemState(item, curEvoLvl)
	end
end 

function wnd_weapon_effect:updateItemState(item, curEvoLvl)
	local widgets = item.vars
	local cfg = widgets.cfg
	if not cfg then return end  
	local weaponEquip = g_i3k_game_context:getWeaponEquip()
	if not weaponEquip then return end 
	local state 
	if weaponEquip.eqEvoLvl < cfg.starLower then --未解锁
		widgets.lockTxt:setText(i3k_get_string(17171, cfg.starLower))
		state = STATE_LOCK
	elseif (curEvoLvl >= cfg.starLower and curEvoLvl <= cfg.starUpper) then
		state = STATE_UNLOCK
	else
		widgets.useBtn:onClick(self, self.setEffectInfo, cfg.starLower)
		state = STATE_USE
	end
	widgets.lockTxt:setVisible(state == STATE_LOCK)
	widgets.inUse:setVisible(state == STATE_UNLOCK)
	widgets.useBtn:setVisible(state == STATE_USE) 
end 

--发送协议给后端设置新的特效
function wnd_weapon_effect:setEffectInfo(sender, evoLvl)
	i3k_sbean.equippart_setshowlvl(EFFECT_POS, evoLvl)
end 

--协议回执处理
function wnd_weapon_effect:onSetEffectInfo(req)
	g_i3k_game_context:SetEquipWeaponEffectInfoEvolvl(req.partId, req.evoLvl)
	self:refresh()
end 

function wnd_create(layout,...)
	local wnd = wnd_weapon_effect.new()
	wnd:create(layout,...)
	return wnd
end
