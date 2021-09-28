-------------------------------------------------------
module(..., package.seeall)

local require = require;

--local ui = require("ui/base");
local ui = require("ui/underwear_profile");
require("ui/ui_funcs")
require("ui/treasure_get_cfg")

-------------------------------------------------------
wnd_shen_bing_unique_skill = i3k_class("wnd_shen_bing_unique_skill", ui.wnd_underwear_profile)

function wnd_shen_bing_unique_skill:ctor( )
	self.shenbingId = nil
end

function wnd_shen_bing_unique_skill:configure( )
	local widgets = self._layout.vars
	self.desc1 = widgets.desc1
	self.desc2 = widgets.desc2
	self.effect_name = widgets.effect_name
	self.desc_img = widgets.desc_img
	self.loadingbar = widgets.loadingbar
	self.jihuo_btn = widgets.jihuo_btn
	self.jihuo_btn:hide()
	self.jihuo_img = widgets.jihuo_img
	self.jihuo_img:hide()
	self.jihuo_text = widgets.jihuo_text
	self.close_btn = widgets.close_btn
	self.close_btn:onClick(self,self.onCloseUI)
	self.hero_module = widgets.hero_module
	self.unique_skill_img = widgets.unique_skill_img
	self.revolve = widgets.revolve
	self.unique_icon = widgets.unique_icon
	self.loading_root = widgets.loading_root
	self.new_img = widgets.new_img
	self.imageView = widgets.imageView
	self.moxingbg = widgets.moxingbg
	self.bianhua = widgets.bianhua
	self.potiangong = widgets.potiangong
	self.duigoudi = widgets.duigoudi
	self.duigou = widgets.duigou
	self.duigouBtn = widgets.duigouBtn
	self.duigouBtn:onClick(self,self.onDuiGouClick)
	self.desc = widgets.desc
	self.tianxiTxt = widgets.tianxiTxt
	self.tianxitimes = widgets.tianxitimes

end

function wnd_shen_bing_unique_skill:refresh(shenbingId)
	local isOpen,mastery,form = g_i3k_game_context:GetShenBingUniqueSkillData(shenbingId)
	self.shenbingId = shenbingId 
	self:SetUniqueData(isOpen,mastery,form)
	self:SetUniqueModule()
end

function wnd_shen_bing_unique_skill:onJihuo(sender)
	--if self:isBagEnough() then	
		i3k_sbean.shen_bing_activateUniqueSkill(self.shenbingId)
	--else
		--g_i3k_ui_mgr:PopupTipMessage("背包已满,请清理背包后再启动该神兵特技")
	--end
end

function wnd_shen_bing_unique_skill:SetUniqueData(isOpen,mastery,form)
	local cfg = i3k_db_shen_bing[self.shenbingId]
	local allShenbing ,useShenbing = g_i3k_game_context:GetShenbingData()
	if not allShenbing[self.shenbingId] then--解锁
		self.loading_root:hide()
		self.desc1:setText(cfg.desc1)
	else
		self:maxWeaponStar()
	end
	self.desc2:setText(cfg.desc2)
	self.desc_img:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_shen_bing[self.shenbingId].descIcon))
	self.effect_name:setText(cfg.uniqueSkillName.."效果:")

	if isOpen == 0 then
		self.loadingbar:setPercent(mastery/cfg.proficinecyMax*100)
		self.jihuo_text:setText(mastery.."/"..cfg.proficinecyMax)
		self.jihuo_img:hide()
		if mastery < cfg.proficinecyMax then
			self.jihuo_btn:hide()
		else
			self.jihuo_btn:show()
			self.jihuo_btn:onClick(self,self.onJihuo)
			self.loading_root:hide()
		end
		
	elseif isOpen == 1 then
		self.desc1:hide()
		self.jihuo_img:show()
		self.jihuo_btn:hide()
		self.loading_root:hide()
		if g_i3k_db.i3k_db_is_weapon_unique_skill_change_model(self.shenbingId) then
			self.bianhua:show()
			if form == g_WEAPON_FORM_ADVANCED then
				self.duigou:show()
				self.duigouBtn:stateToPressed()
			else
				self.duigou:hide()
				self.duigouBtn:stateToNormal()
			end
		end
		if self.shenbingId == 6 then
			self.potiangong:show()
			self.jihuo_img:hide()
			local info = i3k_db_shen_bing_unique_skill[self.shenbingId] or {}
			for k,v in pairs(info) do
				local curparameters = v.parameters
				if g_i3k_game_context:isMaxWeaponStar(self.shenbingId) then
					curparameters = v.manparameters
				end
				if v.uniqueSkillType == 13 then
					local times = curparameters[1] - g_i3k_game_context:getWeaponNpcEnterTimes()
					if times > 0 then
						self.tianxitimes:setText(string.format("本日可以进入天隙:%d%s",times,"次"))
					else
						self.tianxitimes:setText("本日不可再进入天隙")
					end
					break
				end
			end 
		end
	end
	self.unique_icon:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.uniqueIcon))
	self.new_img:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_shen_bing[self.shenbingId].entranceIcon))
end
function wnd_shen_bing_unique_skill:maxWeaponStar()
	local lvl = g_i3k_game_context:GetShenbingStarLvl(self.shenbingId)
	if i3k_db_shen_bing_upstar[self.shenbingId] then
		local info = i3k_db_shen_bing_upstar[self.shenbingId]
		local curcount = info[lvl].addCount + i3k_db_shen_bing[self.shenbingId].perAddProficiency
		local nextcount = 0
		local nextlvl = 0
		for i,v in ipairs(info) do
			if v.addCount + i3k_db_shen_bing[self.shenbingId].perAddProficiency > curcount then
				nextcount = v.addCount + i3k_db_shen_bing[self.shenbingId].perAddProficiency
				nextlvl = i
				break
			end
		end
		if nextcount > 0 then
			self.desc1:setText(i3k_get_string(881,curcount,nextlvl,nextcount))
		else
			self.desc1:setText(i3k_get_string(882,curcount))
		end
	end
end
function wnd_shen_bing_unique_skill:SetUniqueModule()
	local cfg = i3k_db_shen_bing[self.shenbingId]
	local list = cfg.UniqueModuleList
	local moduleId = cfg.UniqueModuleId
	if moduleId == -1 then
		self.moxingbg:hide()
		self.imageView:show()
		self.imageView:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.imageIconID))
		return
	end
	self.moxingbg:show()
	self.imageView:hide()
	if moduleId == 0 then
	 	if list then
			if #list == 1 then
				ui_set_hero_model(self.hero_module, i3k_game_get_player_hero(), g_i3k_game_context:GetWearEquips(),nil,nil,cfg.scalePro) 
				--self.revolve:onTouchEvent(self, self.onRotateBtn) --旋转模型
				self.hero_module:playAction(list[1])
				self.hero_module:setScale(0.4)
			else
				ui_set_hero_model(self.hero_module, i3k_game_get_player_hero(), g_i3k_game_context:GetWearEquips(),nil,nil,cfg.scalePro)
				for i,v in ipairs(list)	do
					self.hero_module:pushActionList(v, 1)
				end
				self.hero_module:pushActionList("stand",-1)
				self.hero_module:playActionList()
			end
	 	else
	 		self.hero_module:playAction("stand")
	 	end
	else
		if moduleId == -2 then
			local gender = 1 --男
			local roledata = g_i3k_game_context._roleData.curChar
			if roledata then
				gender = roledata._gender
			end
			local isOpen , mastery , form = g_i3k_game_context:GetShenBingUniqueSkillData(self.shenbingId)
			local wcfg = i3k_db_shen_bing[self.shenbingId];
			if wcfg and wcfg.UniqueModuleId == -2 then
				if gender == 1 then
					moduleId = wcfg.manModuleID
				else
					moduleId = wcfg.womanModuleID
				end
			end
		end
	 	ui_set_hero_model(self.hero_module,moduleId,nil,nil,cfg.scalePro)
		if list then
			for i,v in ipairs(list)	do
				self.hero_module:pushActionList(v, 1)
			end
			self.hero_module:pushActionList("stand",-1)
			self.hero_module:playActionList()
		else
			self.hero_module:playAction("stand")
		end
	end
	if cfg.widgetRotation ~= 0 then
		self.hero_module:setRotation(cfg.widgetRotation)
	else
		self.hero_module:setRotation(math.pi/2,-0.3)
	end
end

function wnd_shen_bing_unique_skill:isBagEnough()
	local info = i3k_db_shen_bing_unique_skill[self.shenbingId] or {}
	for k,v in pairs(info) do
		if v.uniqueSkillType == 1 then
			local curparameters = v.parameters
			if g_i3k_game_context:isMaxWeaponStar(self.shenbingId) then
				curparameters = v.manparameters
			end
			local item = {}
			item[curparameters[1]] = curparameters[2] 
			local isTrue = g_i3k_game_context:IsBagEnough(item)
			return isTrue 
		else 
			return true
		end
	end 
end

function wnd_shen_bing_unique_skill:SetActivateShenBingUniqueSkill(shenbingId)
	local info = i3k_db_shen_bing_unique_skill[self.shenbingId] or {}
	for k,v in pairs(info) do
		local curparameters = v.parameters
		if g_i3k_game_context:isMaxWeaponStar(self.shenbingId) then
			curparameters = v.manparameters
		end
		if v.uniqueSkillType == 1 then
			local gifts = {}
			gifts[1] = {id = curparameters[1] , count = curparameters[2]}
			g_i3k_ui_mgr:ShowGainItemInfo(gifts)
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(769, g_i3k_db.i3k_db_get_common_item_name(curparameters[1])))
			break
		end
		if v.uniqueSkillType == 5 then
			local uniqueId = curparameters[1] 
			local uniqueInitLvl = curparameters[2]
			local sortId = i3k_db_exskills[uniqueId].sortid
			local role_id = g_i3k_game_context:GetRoleType()
			local exskill = i3k_db_exskills[uniqueId].skills[role_id]
			local uniqueName = i3k_db_skills[exskill].name
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(771, uniqueName))
			g_i3k_game_context:SetCurRoleUniqueSkills(exskill,uniqueInitLvl, 0,sortId)--设置绝技
			break
		end
	end 
end

function wnd_shen_bing_unique_skill:onDuiGouClick(sender )
	if sender:isStatePressed() then
		i3k_sbean.weapon_setform( self.shenbingId , g_WEAPON_FORM_NORMAL )
	else
		i3k_sbean.weapon_setform( self.shenbingId , g_WEAPON_FORM_ADVANCED )
	end
end

function wnd_shen_bing_unique_skill:updateBianhua( form)
	if form == 1 then
		self.duigouBtn:stateToNormal()
		self.duigou:hide()
	else
		self.duigouBtn:stateToPressed()
		self.duigou:show()
	end
	self:SetUniqueModule()
end

function wnd_create(layout)
	local wnd = wnd_shen_bing_unique_skill.new()
	wnd:create(layout)
	return wnd
end
