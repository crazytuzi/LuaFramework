-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_transfrom1 = i3k_class("wnd_transfrom1", ui.wnd_base)

local common_use_iconid = 151

function wnd_transfrom1:ctor()

end

function wnd_transfrom1:configure()
	local widgets = self._layout.vars
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	self.job_icon = widgets.job_icon
	self.job_poet1 = widgets.job_poet1
	self.job_poet2 = widgets.job_poet2
	self:initBaseItem(widgets)
	self.transfrom_btn = widgets.transfrom_btn
	self.transfrom_btn:onClick(self,self.onSendTransfromData)
	self.need_lvl = widgets.need_lvl
	self.transfer_desc = widgets.transfer_desc
end

function wnd_transfrom1:initBaseItem(widgets)
	self.base_Arry = {}
	self.otherArry = {}
	for i=1,3 do
		local temp_addAttr = "attribute"..i
		local temp_value = "value"..i
		self.otherArry[i]= {
			temp_addAttr = widgets[temp_addAttr],
			temp_value = widgets[temp_value],
		}
	end
	for i=1, 2 do
		local item_bg = "item" ..i.."_bg"
		local item_icon = "item" ..i.."_icon"
		local item_name = "item" ..i.."_name"
		local item_btn = "item" ..i.."_btn"
		local item_count = "item" ..i.."_count"

		local skill_bg = "skill" ..i.."_bg"
		local skill_icon = "skill" ..i.."_icon"
		local skill_name = "skill" ..i.."_name"
		local skill_btn = "skill" ..i.."_btn"
		self.base_Arry[i] = {
		item_bg    = widgets[item_bg],
		item_icon  = widgets[item_icon],
		item_name  = widgets[item_name],
		item_btn   = widgets[item_btn],
		item_count = widgets[item_count],
		item_suo = widgets["item_suo"..i],
		skill_bg   = widgets[skill_bg],
		skill_icon = widgets[skill_icon],
		skill_name = widgets[skill_name],
		skill_btn  = widgets[skill_btn],
		}
		widgets[skill_btn]:onClick(self,self.onSkillTips)
		widgets[item_btn]:onClick(self,self.onItemTips)
	end
end

function wnd_transfrom1:checkTransform(item,num1,num2,istrue)--文本设置
	local is_ok=true
	if istrue then
		item:setText(num2 .."/".. num1)
	else
		item:setText(num1)
	end
	if num1 > num2 then
		item:setTextColor(g_i3k_get_red_color())
		is_ok = false
	else
		item:setTextColor(g_i3k_get_green_color())
	end
	return is_ok
end

function wnd_transfrom1:initTemp()--属性附加
	for i=1,3 do
		local attrArry = self.otherArry[i]
		local temp_addAttr = "attribute"..i
		local temp_value = "value"..i
		local attr_data = i3k_db_zhuanzhi[self.roleType][self.transfromLvl][self.BWType][temp_addAttr]
		local value_data = i3k_db_zhuanzhi[self.roleType][self.transfromLvl][self.BWType][temp_value]
		attrArry.temp_addAttr:setText(i3k_db_prop_id[attr_data].desc)
		-- attrArry.temp_addAttr:setTextColor(i3k_db_prop_id[attr_data].textColor)
		attrArry.temp_value:setText("+" .. i3k_get_prop_show(attr_data,value_data))
		-- attrArry.temp_value:setTextColor(i3k_db_prop_id[attr_data].valuColor)
	end
end

function wnd_transfrom1:initSkill()--技能
	for i=1,2 do
		local SkillArry = self.base_Arry[i]
		local temp_id = "skill"..i
		local skillid = i3k_db_zhuanzhi[self.roleType][self.transfromLvl][self.BWType][temp_id]
		if skillid ~= 0 then
			SkillArry.skill_icon:setImage(i3k_db_icons[i3k_db_skills[skillid].icon].path)
			SkillArry.skill_name:setText("[武功]"..i3k_db_skills[skillid].name)
			SkillArry.skill_btn:setTag(skillid)
			SkillArry.skill_bg:setImage(i3k_db_icons[common_use_iconid].path)
		else
			local widgets = self._layout.vars
			widgets["skillRoot"..i]:hide()
			widgets["xinfaRoot"..i]:show()

			local qigongID = i3k_db_zhuanzhi[self.roleType][self.transfromLvl][self.BWType].newQiGongID
			local qigongBookID = i3k_db_xinfa[qigongID].itemID
			widgets["xinfaIcon"..i]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(qigongBookID, g_i3k_game_context:IsFemaleRole()))
			widgets["xinfaBg"..i]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(qigongBookID))
			widgets["xinfaName"..i]:setText("[气功]"..i3k_db_xinfa[qigongID].name)
			SkillArry.skill_btn:setTag(g_i3k_db.i3k_db_get_fiveTrans_skill_xinfa_tag(qigongID))
		end
	end
end

function wnd_transfrom1:showTop()--职位描述
	local db_job_icon_id = i3k_db_zhuanzhi[self.roleType][self.transfromLvl][self.BWType].icon
	local db_job_icon_path = i3k_db_icons[db_job_icon_id].path
	local db_job_poet1 = i3k_db_zhuanzhi[self.roleType][self.transfromLvl][self.BWType].poet1
	local db_job_poet2 = i3k_db_zhuanzhi[self.roleType][self.transfromLvl][self.BWType].poet2
	self.job_icon:setImage(db_job_icon_path)
	self.job_poet1:setText(db_job_poet1)
	self.job_poet2:setText(db_job_poet2)
end

function wnd_transfrom1:initItem()--消耗物品
	local is_ok1=true
	for i=1,2 do
		local ItemArry = self.base_Arry[i]
		local temp_id = "item"..i.."ID"
		local temp_num = "item"..i.."Count"
		local itemid = i3k_db_zhuanzhi[self.roleType][self.transfromLvl][self.BWType][temp_id]
		local itemCount = i3k_db_zhuanzhi[self.roleType][self.transfromLvl][self.BWType][temp_num]
		local have_count = g_i3k_game_context:GetCommonItemCanUseCount(itemid)
		ItemArry.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemid))
		ItemArry.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemid,i3k_game_context:IsFemaleRole()))
		ItemArry.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(itemid))
		ItemArry.item_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(itemid)))
		local is_ok = self:checkTransform(ItemArry.item_count,itemCount,have_count,math.abs(itemid) ~= 2)
		ItemArry.item_btn:setTag(itemid)
		ItemArry.item_suo:setVisible(itemid > 0)
		if not is_ok then
			is_ok1 = false
		end
	end
	return is_ok1
end

function  wnd_transfrom1:refData()
	self.roleType = g_i3k_game_context:GetRoleType()
	self.transfromLvl = g_i3k_game_context:GetTransformLvl()
	self.BWType = g_i3k_game_context:GetTransformBWtype()
	self.roleLvl = g_i3k_game_context:GetLevel()
	if self.transfromLvl == 0 then
		self.transfromLvl = 1
	else
		self.transfromLvl = self.transfromLvl + 1
	end
	local roleTypeName = i3k_db_zhuanzhi[self.roleType][self.transfromLvl][self.BWType].name
	local roleTypeDesc = i3k_db_zhuanzhi[self.roleType][self.transfromLvl][self.BWType].desc
	local needLvl = i3k_db_zhuanzhi[self.roleType][self.transfromLvl][self.BWType].needLV
	self.transfer_desc:setText(i3k_get_string(57,roleTypeName))
	local is_ok2 = true
	local is_ok1=self:initItem()
	is_ok2 = self:checkTransform(self.need_lvl,needLvl,self.roleLvl,false)
	if is_ok1 and is_ok2 then
		self.transfrom_btn:enableWithChildren()
	else
		self.transfrom_btn:disableWithChildren()
	end
end

function wnd_transfrom1:refresh()
	self:refData()
	self:initTemp()
	self:initSkill()
	self:showTop()
end

function wnd_transfrom1:onSendTransfromData(sender)
	if g_i3k_game_context:isStartSkillAllUnlock() then
		local data = i3k_sbean.role_transform_req.new()
		data.tlvl = self.transfromLvl
		data.bwType = self.BWType
		i3k_game_send_str_cmd(data,i3k_sbean.role_transform_res.getName())
		g_i3k_ui_mgr:CloseUI(eUIID_Transfrom1)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(280))
	end
end

function wnd_transfrom1:onSkillTips(sender)
	local tag = sender:getTag()
	g_i3k_ui_mgr:OpenUI(eUIID_TransfromSkillTips)
	g_i3k_ui_mgr:RefreshUI(eUIID_TransfromSkillTips,tag)
end

function wnd_transfrom1:onItemTips(sender)
	local tag = sender:getTag()
	g_i3k_ui_mgr:ShowCommonItemInfo(tag)
end
--[[function wnd_transfrom1:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_Transfrom1)
end--]]
function wnd_create(layout, ...)
	local wnd = wnd_transfrom1.new();
	wnd:create(layout, ...);
	return wnd;
end
