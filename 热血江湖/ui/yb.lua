-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_r_func = i3k_class("wnd_r_func", ui.wnd_base)

local YBLAYER = "ui/widgets/ybt"
local YBLAYER2 = "ui/widgets/ybt2"

function wnd_r_func:ctor()
end

function wnd_r_func:configure()
	local widgets = self._layout.vars
	self.scroll = widgets.scroll
	self.skill_point = widgets.skill_point 
	self.role_point = widgets.role_point 
	self.weapon_point = widgets.weapon_point
	self.pet_point = widgets.pet_point
	self.streng_point = widgets.streng_point
	--self.clan_point = widgets.clan_point 
	--self.steed_point = widgets.steed_point
	--self.empowerment_point = widgets.empowerment_point
	self.bag_point = widgets.bag_point
	
	widgets.streng_btn:onClick(self, self.onStrengEquip)
	widgets.xinfa_btn:onClick(self, self.onXinFa)
--	widgets.set_btn:onClick(self, self.onSet)
	widgets.bag_btn:onClick(self, self.onBag)
	widgets.shenBing_btn:onClick(self, self.onShenBing)
--	widgets.toBangpai:onClick(self, self.toBangpaiCB)
--	widgets.master_btn:onClick(self, self.onMaster)
	widgets.pet_btn:onClick(self, self.onSuiCong)
--	widgets.my_firends_btn:onClick(self, self.onMyFirends)
--	widgets.toSteed:onClick(self, self.toSteedSystem)
--	widgets.ranklist_btn:onClick(self, self.onRankList)
--  widgets.empowerment_btn:onClick(self, self.onEmpowerment)
end

function wnd_r_func:onStrengEquip(sender)
	if g_i3k_game_context:GetIsSpringWorld() then
		g_i3k_ui_mgr:PopupTipMessage("温泉场景内禁止此操作")
		return
	end
	if g_i3k_game_context:isCanOpenEquipStreng() then
		g_i3k_logic:OpenStrengEquipUI()
	end
end

function wnd_r_func:onXinFa(sender)
	g_i3k_logic:OpenSkillLyUI()
end

function wnd_r_func:onSet(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_SetBlood)
end

function wnd_r_func:onMyFirends(sender)
	g_i3k_logic:OpenMyFriendsUI()
end

function wnd_r_func:onBag(sender)
	g_i3k_logic:OpenBagUI()
end

function wnd_r_func:onDailyTask(sender)

end

function wnd_r_func:onShenBing(sender)
	g_i3k_logic:OpenShenBingUI()
end

function wnd_r_func:onSuiCong(sender)
	g_i3k_logic:OpenPetUI()
end

function wnd_r_func:toBangpaiCB(sender)
	local data = i3k_sbean.sect_sync_req.new()
	i3k_game_send_str_cmd(data,i3k_sbean.sect_sync_res.getName())
end

function wnd_r_func:onMaster(sender)
	i3k_sbean.product_data_sync()
end

function wnd_r_func:toSteedSystem(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_Steed)
	g_i3k_ui_mgr:RefreshUI(eUIID_Steed)
end

function wnd_r_func:onRankList(sender)
	local cur_level = g_i3k_game_context:GetLevel()
	if cur_level >= i3k_db_rank_list[1].level then
		g_i3k_logic:OpenRankListUI()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(482,i3k_db_rank_list[1].level))
	end
	
end

function wnd_r_func:onEmpowerment(sender)
	i3k_sbean.goto_expcoin_sync()
end

function wnd_r_func:updateServerNotices()
	
end

function wnd_r_func:updateBagNotice()
	self.bag_point:setVisible(g_i3k_game_context:bagPointForLongYin() or g_i3k_game_context:GetLongYinRedpoint() or g_i3k_game_context:GetLongYinRedpoint2())
end

function wnd_r_func:updateStrengNotice()
	self.streng_point:setVisible(g_i3k_game_context:canBetterEquip())
end

function wnd_r_func:updateSkillNotice()
	self.skill_point:setVisible(g_i3k_game_context:canBetterSkillOrSpirit())
end

function wnd_r_func:updateWeaponNotice()
	self.weapon_point:setVisible(g_i3k_game_context:canBetterWeapon())
end

function wnd_r_func:updatePetNotice()
	self.pet_point:setVisible(g_i3k_game_context:canBetterPet())
end


function wnd_r_func:updateSteedNotice()

	self.steed_point:setVisible(g_i3k_game_context:canBetterSteed())
end 

function wnd_r_func:updateEmpowermentNotice()
	self.empowerment_point:setVisible(g_i3k_game_context:redPointForAllCheats() or g_i3k_game_context:redPointForBooks() or g_i3k_game_context:qiankunRedPoints())
end

function wnd_r_func:refresh()
	
	self:updateBagNotice()
	self:updateStrengNotice()
	self:updateSkillNotice()
	self:updateWeaponNotice()
	self:updatePetNotice()
	--[[
	self:updateClanNotice()
	self:updateSteedNotice()
	self:updateEmpowermentNotice()
	]]
	self:updateScroll()
end

local btnCount1 = {2071, 2070, 2069, 2068, 2067, 2245, 2065} 
local btnCount2 = {2071, 2070, 2069, 2067, 2245, 2065}  --隐藏历练按钮

function wnd_r_func:updateScroll()
	self.scroll:removeAllChildren()
	local btnCount = {}
	local level = g_i3k_game_context:GetLevel()
	if g_i3k_game_context:GetLevel() >= i3k_db_experience_args.args.hideLvl then
		btnCount = btnCount1
	else
		btnCount = btnCount2
	end
	for i=1, 8 - #btnCount do
		local _layer = require(YBLAYER2)()
		local widget = _layer.vars
		self.scroll:addItem(_layer)
	end
	local count = #btnCount
	for i=1, #btnCount do
		
		local _layer = require(YBLAYER)()
		local widget = _layer.vars
		widget.point:setVisible(false)
		local id = i
		if g_i3k_game_context:GetLevel() >= i3k_db_experience_args.args.hideLvl then
			if id == 1 then
				--self:onSet()
			elseif id == 2 then
				--self:onRankList()
			elseif id == 3 then
				--self:onMyFirends()
			elseif id == 4 then
				widget.point:setVisible(g_i3k_game_context:redPointForAllCheats() or g_i3k_game_context:redPointForBooks() or g_i3k_game_context:qiankunRedPoints())
			elseif id == 5 then
				widget.point:setVisible(g_i3k_game_context:canBetterSteed())
			elseif id == 6 then
				--widget.point:setVisible(g_i3k_game_context:IsCanCreateClan())
				widget.point:setVisible(false)
			elseif id == 7 then
				--self:toBangpaiCB()
			end
		else
			if id == 1 then
				--self:onSet()
			elseif id == 2 then
				--self:onRankList()
			elseif id == 3 then
				--self:onMyFirends()
			elseif id == 4 then
				widget.point:setVisible(g_i3k_game_context:canBetterSteed())
			elseif id == 5 then
				--widget.point:setVisible(g_i3k_game_context:IsCanCreateClan())
				widget.point:setVisible(false)
			elseif id == 6 then
				--self:toBangpaiCB()
			end
		end
		widget.btn:onClick(self,self.chooseOneBtn, i)
		widget.btn:setImage(g_i3k_db.i3k_db_get_icon_path(btnCount[i]))
		self.scroll:addItem(_layer)
	end
	self.scroll:stateToNoSlip()
end

function wnd_r_func:chooseOneBtn(sender,id)
	if g_i3k_game_context:GetLevel() >= i3k_db_experience_args.args.hideLvl then
		if id == 1 then
			self:onSet()
		elseif id == 2 then
			self:onRankList()
		elseif id == 3 then
			self:onMyFirends()
		elseif id == 4 then
			self:onEmpowerment()
		elseif id == 5 then
			self:toSteedSystem()
		elseif id == 6 then
			self:onMaster()
		elseif id == 7 then
			self:toBangpaiCB()
		end
	else
		if id == 1 then
			self:onSet()
		elseif id == 2 then
			self:onRankList()
		elseif id == 3 then
			self:onMyFirends()
		elseif id == 4 then
			self:toSteedSystem()
		elseif id == 5 then
			self:onMaster()
		elseif id == 6 then
			self:toBangpaiCB()
		end
	end
	
end

function wnd_create(layout)
	local wnd = wnd_r_func.new()
	wnd:create(layout)
	return wnd
end

