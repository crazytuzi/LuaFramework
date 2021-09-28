-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_faction_worship = i3k_class("wnd_faction_worship", ui.wnd_base)

function wnd_faction_worship:ctor()
	self._id = nil
	self._name = nil
	self._root = {}
end


function wnd_faction_worship:configure(...)
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	self.user_name = self._layout.vars.user_name 
	self.vip1_label = self._layout.vars.vip1_label 
	self.vip2_label = self._layout.vars.vip2_label 
	
	self.vip_bg1 = self._layout.vars.vip_bg1 
	self.vip_bg1:hide()
	self.vip_bg2 = self._layout.vars.vip_bg2 
	self.vip_bg2:hide()
	for i=1,3 do
		local tmp_btn = string.format("worship%s_btn",i)
		local worship_btn = self._layout.vars[tmp_btn]
		local tmp_desc = string.format("worship%s_desc",i)
		local worship_desc = self._layout.vars[tmp_desc]
		local tmp_exp = string.format("worship%s_exp",i)
		local worship_exp = self._layout.vars[tmp_exp]
		local tmp_label = string.format("worship%s_label",i)
		local worship_label = self._layout.vars[tmp_label]
		local tmp_count = string.format("money%s_count",i)
		local money_count = self._layout.vars[tmp_count]
		local tmp_cion =  string.format("money%s_icon",i)
		local money_cion = self._layout.vars[tmp_cion]
		local tmp_count = string.format("count_label%s",i)
		local count_label = self._layout.vars[tmp_count]
		local tmp_suo = string.format("suo_icon%s",i)
		local suo_icon = self._layout.vars[tmp_suo]
		self._root[i] = {worship_btn = worship_btn,worship_desc = worship_desc,worship_exp = worship_exp,worship_label = worship_label,
		money_count = money_count,money_cion = money_cion,count_label = count_label,suo_icon = suo_icon}
	end 
	self.role_model = self._layout.vars.role_model 
end

function wnd_faction_worship:onShow()
	
end

function wnd_faction_worship:refresh(id,name)
	self._id = id
	self._name = name
	self:updateWorshipData()
end 

function wnd_faction_worship:changeModel(id, bwType, gender, face, hair, equips,fashions,isshow,equipparts,armor, weaponSoulShow, isEffectFashion, soaringDisplay)
	local modelTable = {}
	modelTable.node = self.role_model
	modelTable.id = id
	modelTable.bwType = bwType
	modelTable.gender = gender
	modelTable.face = face
	modelTable.hair = hair
	modelTable.equips = equips
	modelTable.fashions = fashions
	modelTable.isshow = isshow
	modelTable.equipparts = equipparts
	modelTable.armor = armor
	modelTable.weaponSoulShow = weaponSoulShow
	modelTable.isEffectFashion = isEffectFashion
	modelTable.soaringDisplay = soaringDisplay
	self:createModelWithCfg(modelTable)
end

function wnd_faction_worship:updateWorshipData()
	
	self.user_name:setText(self._name)
	local my_data = g_i3k_game_context:GetRoleInfo()
	local my_vipLvl = my_data.curChar._viplvl
	local level = g_i3k_game_context:GetLevel()
	local _data = g_i3k_game_context:GetFactionWorshipData()
	for i=1,3 do
		local worship_btn = self._root[i].worship_btn
		local worship_desc = self._root[i].worship_desc
		local worship_exp = self._root[i].worship_exp
		local worship_label = self._root[i].worship_label
		local money_count = self._root[i].money_count
		local money_cion = self._root[i].money_cion
		local suo_icon = self._root[i].suo_icon
		local count_label =  self._root[i].count_label
		local worship_data = i3k_db_faction_worship[i]
		local need_vipLvl = i3k_db_faction_worship[i].vipOpen
		if my_vipLvl < need_vipLvl then
			worship_btn:disableWithChildren()
			if i == 2 then
				self.vip1_label:show()
				local tmp_str = string.format("贵族%s级开启",need_vipLvl)
				self.vip1_label:setText(tmp_str)
				self.vip_bg1:show()
			elseif i == 3 then
				self.vip2_label:show()
				local tmp_str = string.format("贵族%s级开启",need_vipLvl)
				self.vip2_label:setText(tmp_str)
				self.vip_bg2:show()
			end
			count_label:hide()
		else
			worship_btn:enableWithChildren()
			if i == 2 then
				self.vip1_label:hide()
				self.vip_bg1:hide()
			elseif i == 3 then
				self.vip2_label:hide()
				self.vip_bg2:hide()
			end
			count_label:show()
		end
		worship_btn:setTag(i)
		worship_btn:onTouchEvent(self,self.onWorship)
		local have_count  = _data[i] or 0
		local _tmp = string.format("worship%s",i)
		local max_count = i3k_db_kungfu_vip[my_vipLvl][_tmp] or 0
		local tmp_count = max_count - have_count
		if tmp_count ~= 0 then
			local tmp_str = string.format("剩余次数：%s",tmp_count)
			count_label:setText(tmp_str) 
		else
			count_label:setText("已膜拜")
			worship_btn:disableWithChildren()
		end
		local tmp_key_exp = string.format("exp%s",i)
		local tmp_key_contri = string.format("contrition%s",i)
		local get_exp = i3k_db_faction_worship_exp[level][tmp_key_exp]
		local get_contri = i3k_db_faction_worship_exp[level][tmp_key_contri]
		worship_exp:setText(get_exp)
		local consume_money = worship_data.moneyType
		suo_icon:setVisible(consume_money > 0)
		consume_money = math.abs(consume_money)
		money_count:setText(worship_data.moneyCount)
		local money_type = worship_data.moneyType
		money_cion:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(money_type,i3k_game_context:IsFemaleRole()))
		local tmp_str = string.format("消耗%s",g_i3k_db.i3k_db_get_common_item_name(money_type))
		worship_label:setText(tmp_str)
	end
end

function wnd_faction_worship:onWorship(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local my_data = g_i3k_game_context:GetRoleInfo()
		local my_vipLvl = my_data.curChar._viplvl
		local _type = sender:getTag()
		local _tmp = string.format("worship%s",_type)
		local max_count = i3k_db_kungfu_vip[my_vipLvl][_tmp] or 0
		
		local _data = g_i3k_game_context:GetFactionWorshipData()
		local have_count  = _data[_type] or 0
		if have_count >= max_count then
			g_i3k_ui_mgr:PopupTipMessage("膜拜次数已满")
			return 
		end
		
		local moneyType = i3k_db_faction_worship[_type].moneyType
		local moneyCount = i3k_db_faction_worship[_type].moneyCount
		
		if moneyType == 2 or moneyType == -2 then
			local have_count = 0
			if moneyType == 2 then
				have_count = g_i3k_game_context:GetMoneyCanUse(false)
			elseif moneyType == -2 then
				have_count = g_i3k_game_context:GetMoneyCanUse(true)
			end 
			if have_count < moneyCount then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(755))
				return 
			end
		elseif moneyType == 1 or moneyType == -1 then
			local have_count = 0
			if moneyType == 1 then
				have_count = g_i3k_game_context:GetDiamondCanUse(false)
			elseif moneyType == -1 then
				have_count = g_i3k_game_context:GetDiamondCanUse(true)
			end 
			
			if have_count < moneyCount then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(754))
				return 
			end
		end
		
		local data = i3k_sbean.sect_worship_req.new()
		data.roleId = self._id
		data.type = _type
		i3k_game_send_str_cmd(data,i3k_sbean.sect_worship_res.getName())
	end
end

--[[function wnd_faction_worship:onClose(sender,eventType)
	if eventType ==ccui.TouchEventType.ended then
		g_i3k_ui_mgr:CloseUI(eUIID_FactionWorship)
	end
end--]]

function wnd_create(layout, ...)
	local wnd = wnd_faction_worship.new();
		wnd:create(layout, ...);

	return wnd;
end

