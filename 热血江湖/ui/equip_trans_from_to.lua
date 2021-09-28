-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_equip_trans_from_to = i3k_class("wnd_equip_trans_from_to", ui.wnd_base)

local bwname = {"正", "邪"}
local careerName = {name = {"刀", "剑", "枪", "弓", "医", "刺", "符", "拳"}, icon = {5982, 5983, 5984, 5985, 5986, 5987, 5988, 9694}}
local WIDGET = "ui/widgets/zzxzt"

function wnd_equip_trans_from_to:ctor()
	--self.from = {}
	--self.to = {}
	self.fromTo = {}
end

function wnd_equip_trans_from_to:configure()
	self._layout.vars.close:onClick(self, self.onCloseUI)
end

function wnd_equip_trans_from_to:refresh()
	self._layout.vars.sureBtn:disableWithChildren()
	self:setScroll()
end

function wnd_equip_trans_from_to:setScroll()
	local count = #i3k_db_generals * 2
	local children1 = self._layout.vars.leftScroll:addItemAndChild(WIDGET, 2, count)
	local children2 = self._layout.vars.rightScroll:addItemAndChild(WIDGET, 2, count)
	for k = 1, 2 do
		for i = 1, 2 do
			for j = 1, #i3k_db_generals do
				local node = {}
				if k == 1 then
					node = children1[(j-1)*2 + i]
				else
					node = children2[(j-1)*2 + i]
				end
				node.vars.career:setText(string.format("%s%s", bwname[i], careerName.name[j]))
				node.vars.btn:onClick(self, self.onCareerWidget, {career = j, bwtype = i, node = node, index = k})
				if i == 1 then
					node.vars.btn:setImage(i3k_db_icons[5978].path)
				else
					node.vars.btn:setImage(i3k_db_icons[5979].path)
				end
				node.vars.careerIcon:setImage(i3k_db_icons[careerName.icon[j]].path)
			end
		end
	end
end

function wnd_equip_trans_from_to:onCareerWidget(sender, data)
	if self.fromTo[data.index] and self.fromTo[data.index].career and self.fromTo[data.index].career == data.career and self.fromTo[data.index].bwtype == data.bwtype then
		return
	else
		self.fromTo[data.index] = data
		local children = {}
		if data.index == 1 then
			children = self._layout.vars.leftScroll:getAllChildren()
		else
			children = self._layout.vars.rightScroll:getAllChildren()
		end
		for _, v in ipairs(children) do
			v.vars.bgIcon:show()
			v.vars.bgIcon:setImage(i3k_db_icons[5981].path)
		end
		data.node.vars.bgIcon:setImage(i3k_db_icons[5980].path)
		self:changeSureBtn()
	end
end

function wnd_equip_trans_from_to:changeSureBtn()
	if self.fromTo[1] and self.fromTo[2] and self.fromTo[1].career and self.fromTo[2].career and (self.fromTo[1].career ~= self.fromTo[2].career or self.fromTo[1].bwtype ~= self.fromTo[2].bwtype) then
		self._layout.vars.sureBtn:enableWithChildren()
		self._layout.vars.sureBtn:onClick(self, self.onSureBtn)
	else
		self._layout.vars.sureBtn:disableWithChildren()
	end
end

function wnd_equip_trans_from_to:onSureBtn(sender)
	if self.fromTo[1] and self.fromTo[2] and self.fromTo[1].career and self.fromTo[2].career then
		for k, v in pairs(i3k_db_equip_transform_cfg) do
			if self.fromTo[1].career == v.fromCareer and self.fromTo[1].bwtype == v.fromBWType and self.fromTo[2].career == v.toCareer and self.fromTo[2].bwtype == v.toBWType then
				g_i3k_ui_mgr:OpenUI(eUIID_EquipTransform)
				g_i3k_ui_mgr:RefreshUI(eUIID_EquipTransform, k)
				break
			end
		end
		g_i3k_ui_mgr:CloseUI(eUIID_EquipTransFromTo)
	else
		g_i3k_ui_mgr:PopupTipMessage("请先选择职业")
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_equip_trans_from_to.new();
		wnd:create(layout, ...);
	return wnd;
end
