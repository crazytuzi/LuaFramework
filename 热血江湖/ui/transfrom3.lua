-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_transfrom3 = i3k_class("wnd_transfrom3", ui.wnd_base)


--???üí¨ó?±3?°?òid

local common_use_iconid = 151
function wnd_transfrom3:ctor()
	
end

function wnd_transfrom3:configure()
	local widgets = self._layout.vars
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	self.zTransfrom_btn = widgets.zTransfrom_btn
	self.xTransfrom_btn = widgets.xTransfrom_btn
	self.zTransfrom_btn:onClick(self,self.onSendTransfrom,1)
	self.xTransfrom_btn:onClick(self,self.onSendTransfrom,2)
	self.need_lvl = widgets.need_lvl
	self.zTransferDesc = widgets.zTransferDesc
	self.xTansferDesc = widgets.xTansferDesc
	self:getMem(widgets)
end
function wnd_transfrom3:getMem(widgets)--获取UI控件
	self.otherArry = {}
	for i=1,3 do
		local temp_addAttr = "attribute"..i 
		local temp_value = "value"..i
		self.otherArry[i]= {
			temp_addAttr = widgets[temp_addAttr],
			temp_value = widgets[temp_value],
		}
	end
	self.job_Arry = {}
	self.item_Arry = {}
	self.skill_arry = {}
	for i=1,2 do
		local name=nil
		local tag = nil
		if i==1 then
			name="z"
		elseif i==2 then
			name="x"
		end
		local job_icon = name .. "job_icon"
		local job_poet1 = name .. "job_poet1"
		local job_poet2 = name .. "job_poet2"
		
		local item_bg = "item" ..i.."_bg"
		local item_icon = "item" ..i.."_icon"
		local item_name = "item" ..i.."_name"
		local item_btn = "item" ..i.."_btn"
		local item_count = "item" ..i.."_count"
		self.job_Arry[i]={
		job_icon = widgets[job_icon],
		job_poet1 = widgets[job_poet1],
		job_poet2 = widgets[job_poet2],
		}
		self.item_Arry[i]={
			item_bg = widgets[item_bg],
			item_icon = widgets[item_icon],
			item_name = widgets[item_name],
			item_btn = widgets[item_btn],
			item_count = widgets[item_count],
			item_suo = widgets["item_suo"..i]
		}
		self.skill_arry[i]={}
		for j=1,2 do
			self.skill_arry[i][j]={}
			local skill_bg = name .."Skill" ..j.."_bg"
			local skill_icon = name .."Skill" ..j.."_icon"
			local skill_name = name .."Skill" ..j.."_name"
			local skill_btn = name .."Skill" ..j.."_btn"
			widgets[skill_btn]:onClick(self,self.onSkillTips)
			self.skill_arry[i][j]={
				skill_bg = widgets[skill_bg],
				skill_icon = widgets[skill_icon],
				skill_name = widgets[skill_name],
				skill_btn = widgets[skill_btn],
			}
		end
		widgets[item_btn]:onClick(self,self.onItemTips)
	end
end
function wnd_transfrom3:checkTransform(item,num1,num2,istrue)--文本颜色显示设置
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
function wnd_transfrom3:showTop()--初始化上方职位图标及介绍
	for i=1,2 do
		local JobArry = self.job_Arry[i]
		local db_zjob_icon_id = i3k_db_zhuanzhi[self.roleType][self.transfromLvl][i].icon
		local db_zjob_icon_path = i3k_db_icons[db_zjob_icon_id].path
		local db_zjob_poet1 = i3k_db_zhuanzhi[self.roleType][self.transfromLvl][i].poet1
		local db_zjob_poet2 = i3k_db_zhuanzhi[self.roleType][self.transfromLvl][i].poet2
		JobArry.job_icon:setImage(db_zjob_icon_path)
		JobArry.job_poet1:setText(db_zjob_poet1)
		JobArry.job_poet2:setText(db_zjob_poet2)
	end
end
function wnd_transfrom3:showTemp()--初始化属性
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
function wnd_transfrom3:showItem()--转职条件
	local is_ok1=true
	for i=1,2 do
		local ItemArry=self.item_Arry[i]
		local temp_id = "item"..i.."ID"
		local temp_num = "item"..i.."Count"
		local itemid = i3k_db_zhuanzhi[self.roleType][self.transfromLvl][self.BWType][temp_id]
		local itemCount = i3k_db_zhuanzhi[self.roleType][self.transfromLvl][self.BWType][temp_num]
		local have_count = g_i3k_game_context:GetCommonItemCanUseCount(itemid)
		ItemArry.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemid))
		ItemArry.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemid,i3k_game_context:IsFemaleRole()))
		ItemArry.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(itemid))
		ItemArry.item_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(itemid)))
		is_ok = self:checkTransform(ItemArry.item_count,itemCount,have_count,math.abs(itemid) ~= 2)
		ItemArry.item_btn:setTag(itemid)
		ItemArry.item_suo:setVisible(itemid > 0)
		if not is_ok then
			is_ok1 = false
		end
	end
	return is_ok1
end
function wnd_transfrom3:showSkill()--技能
	for i=1,2 do
		local temp_id = "skill"..i
		for j=1,2 do
			local SkillArry = self.skill_arry[j][i]
			local skillid = i3k_db_zhuanzhi[self.roleType][self.transfromLvl][j][temp_id]
			SkillArry.skill_icon:setImage(i3k_db_icons[i3k_db_skills[skillid].icon].path)
			SkillArry.skill_name:setText(i3k_db_skills[skillid].name)
			SkillArry.skill_btn:setTag(skillid)
			SkillArry.skill_bg:setImage(i3k_db_icons[common_use_iconid].path)
		end
	end
end
function wnd_transfrom3:refData()--刷新基础数据
	self.roleType = g_i3k_game_context:GetRoleType()
	self.transfromLvl = g_i3k_game_context:GetTransformLvl()
	self.BWType = g_i3k_game_context:GetTransformBWtype()
	self.roleLvl = g_i3k_game_context:GetLevel()
	self.transfromLvl = self.transfromLvl + 1
	self.BWType = self.BWType + 1
	local ZroleTypeName = i3k_db_zhuanzhi[self.roleType][self.transfromLvl][1].name
	local XroleTypeName = i3k_db_zhuanzhi[self.roleType][self.transfromLvl][2].name
	self.zTransferDesc:setText(i3k_get_string(57,ZroleTypeName))
	self.xTansferDesc:setText(i3k_get_string(57,XroleTypeName))
	local is_ok2 = true
	local is_ok1=self:showItem()
	local needLvl = i3k_db_zhuanzhi[self.roleType][self.transfromLvl][1].needLV
	is_ok2 = self:checkTransform(self.need_lvl,needLvl,self.roleLvl,false)
	if is_ok1 and is_ok2 then
		self.zTransfrom_btn:enableWithChildren()
		self.xTransfrom_btn:enableWithChildren()
	else
		self.xTransfrom_btn:disableWithChildren()
		self.zTransfrom_btn:disableWithChildren()
	end
end
function wnd_transfrom3:refresh()
	self:refData()
	self:showTemp()
	self:showSkill()
	self:showTop()
end
function wnd_transfrom3:onSendTransfrom(sender,num)
	local data = i3k_sbean.role_transform_req.new()
	data.tlvl = self.transfromLvl
	data.bwType = num
	i3k_game_send_str_cmd(data,i3k_sbean.role_transform_res.getName())
	g_i3k_ui_mgr:CloseUI(eUIID_Transfrom3)
end
function wnd_transfrom3:onSkillTips(sender)
	local tag = sender:getTag()
	g_i3k_ui_mgr:OpenUI(eUIID_TransfromSkillTips)
	g_i3k_ui_mgr:RefreshUI(eUIID_TransfromSkillTips,tag)
end
function wnd_transfrom3:onItemTips(sender)
	local tag = sender:getTag()
	g_i3k_ui_mgr:ShowCommonItemInfo(tag)
end
--[[function wnd_transfrom3:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_Transfrom3)
end--]]
function wnd_create(layout, ...)
	local wnd = wnd_transfrom3.new();
	wnd:create(layout, ...);
	return wnd;
end
