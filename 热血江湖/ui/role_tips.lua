-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
role_tips = i3k_class("role_tips", ui.wnd_base)

--套装强化tips优化颜色 title,属性名,属性名描边,属性值,属性值描边
--达标 
local finish = {'ffffcb40','ff76d646','ff5b7838','ff76d646','ff5b7838'}
--未达标
local notFinish = {'ff9a9a9a','ffcdc7c1','ff8e847b','ffcdc7c1','ffa47848'}

local desc = {"全身装备升级均达到%s级", "全身装备强化均达到%s级", "全身装备宝石均达到%s级"}

function role_tips:ctor()

end

function role_tips:configure()
	local widgets = self._layout.vars
	self._layout.vars.close_btn:onClick(self, self.onCloseUI)
end

function role_tips:refresh(data)
	for ntype = 1, 3 do
		if data[ntype] then
			local cfg = data[ntype].cfg
			local count = data[ntype].count
			local property = data[ntype].property
			local isGet = count == 6
			local titleDesc = string.format(string.sub(data[ntype].desc,1,12))
			local awardDesc = string.format("+%s",cfg.args)
			local titleColor = isGet and finish[1] or notFinish[1]--title
			local attriColor = isGet and finish[2] or notFinish[2]--属性名
			local attriOutline = isGet and finish[3] or notFinish[3]--属性名描边
			local attriValColor = isGet and finish[4] or notFinish[4]--属性值
			local attriValOutline = isGet and finish[5] or notFinish[5]--属性值描边

			self._layout.vars["title"..ntype]:setText(titleDesc)
			--self._layout.vars["title"..ntype]:setTextColor(titleColor)
			self._layout.vars["awardValue"..ntype]:setText(awardDesc)
			self._layout.vars["awardValue"..ntype]:setTextColor(attriColor)
			self._layout.vars["awardValue"..ntype]:enableOutline(attriOutline)
			local str = string.format(desc[ntype], awardDesc)
			self._layout.vars["tips"..ntype]:setText(str)
			--self._layout.vars["tips"..ntype]:setTextColor(titleColor)
			if isGet then
				self._layout.vars["bg_" ..ntype]:enable()
				self._layout.vars["arrows_" ..ntype]:enable()
			else
				self._layout.vars["bg_" ..ntype]:disable()
				self._layout.vars["arrows_" ..ntype]:disable()
			end
			local propertyCfg = self:propertySort(property)
			for i=1, 3 do
				if propertyCfg[i] then
					self._layout.vars["attribute"..ntype..i]:show()
					self._layout.vars["attributeValue"..ntype..i]:show()
					self._layout.vars["icon"..ntype..i]:show()
					local name = g_i3k_db.i3k_db_get_attribute_name(propertyCfg[i].id)
					local icon = g_i3k_db.i3k_db_get_attribute_icon(propertyCfg[i].id)
					self._layout.vars["icon"..ntype..i]:setImage(icon)
					self._layout.vars["attribute"..ntype..i]:setText(name .. ":")
					--self._layout.vars["attribute"..ntype..i]:setTextColor(attriColor)
					self._layout.vars["attributeValue"..ntype..i]:setText(propertyCfg[i].value)
				
					self._layout.vars["attributeValue"..ntype..i]:setTextColor(attriValColor)
					self._layout.vars["attributeValue"..ntype..i]:enableOutline(attriValOutline)
					
				else
					self._layout.vars["attribute"..ntype..i]:hide()
					self._layout.vars["attributeValue"..ntype..i]:hide()
					self._layout.vars["icon"..ntype..i]:hide()
				end
			end
		end
	end
end

function role_tips:propertySort(property)
	local temp = {}
	for k,v in pairs(property) do
		table.insert(temp, {id = v.id, value = v.value})
	end
	table.sort(temp, function (a,b)
		return a.id < b.id
	end)
	return temp
end

function wnd_create(layout)
	local wnd = role_tips.new()
		wnd:create(layout)
	return wnd
end

