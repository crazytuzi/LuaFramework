-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_refine_tip = i3k_class("wnd_refine_tip", ui.wnd_base)

function wnd_refine_tip:ctor()

end

function wnd_refine_tip:configure()
	self._layout.vars.loseBtn:onClick(self, self.onCloseUI)
	self._layout.vars.saveBtn:onClick(self, self.onSave)
end
function wnd_refine_tip:refresh(data, newProps, isFree)
	self.data=data
	self.newProps = newProps
	self.isFree = isFree
end
function wnd_refine_tip:UpdateLab(old,new,costItem)
	local OriginalScroll = self._layout.vars.OriginalLab
	local NewScroll = self._layout.vars.NewLab
	local gid = g_i3k_db.i3k_db_get_other_item_cfg(costItem).args1  --组id
	local itemid =g_i3k_db.i3k_db_get_other_item_cfg(costItem).args2 --随机数量
	self.levelReq = g_i3k_db.i3k_db_get_other_item_cfg(costItem).levelReq --装备等级
	self.maxPower = i3k_db_equip_refine[gid][itemid].propUp --最大战力
	self.mutiArgsLvl = i3k_db_equip_refine[gid][itemid].mutiArgs1 --等级需求
	self.mutiArgsNum = i3k_db_equip_refine[gid][itemid].mutiArgs2 --战力系数需求
	OriginalScroll:removeAllChildren()
	NewScroll:removeAllChildren()
	if new then
		for i,v in ipairs(new) do
			local item = require("ui/widgets/jltipst")()
			NewScroll:addItem(item)
			if i3k_db_prop_id[v.id].desc then
				item.vars.txtName:setText(i3k_db_prop_id[v.id].desc)
				self:JudgeMax(i3k_get_prop_show(v.id, v.value),v.id,item)
			else
				return
			end
		end
	end
	if old then
		for i,v in ipairs(old) do
			local item = require("ui/widgets/jltipst")()
			OriginalScroll:addItem(item)
			if i3k_db_prop_id[v.id].desc then
				item.vars.txtName:setText(i3k_db_prop_id[v.id].desc)
				self:JudgeMax(i3k_get_prop_show(v.id, v.value),v.id,item)
			else
				return
			end
		end
	end
end
function wnd_refine_tip:onSave()
	i3k_sbean.refine_equip_save(self.data.id,self.data.guid,self.data.pos, self.newProps, self.isFree)
	g_i3k_ui_mgr:CloseUI(eUIID_RefineTip)
end
function wnd_refine_tip:JudgeMax(powerNum,itemId,item)
	local refineItem = g_i3k_db.i3k_db_get_equip_item_cfg(self.data.id).refineAllItems --使用的精炼道具列表
	local powerTime = nil --属性最大值
	local mutiArgs1 = nil --等级区分
	local mutiArgs2 = nil --属性系数
	local index = 1
	for i,v in ipairs(refineItem) do --精炼道具遍历
		local gid = g_i3k_db.i3k_db_get_other_item_cfg(v).args1 --组id
		for a,b in ipairs(i3k_db_equip_refine[gid]) do --遍历装备精炼表的组内情况通过组id
			if itemId == b.propID then --取到的功能id是否等于遍历组id得到的功能id
				if not powerTime then --判断属性是否为最大值
					powerTime = b.propUp
					mutiArgs1 = b.mutiArgs1
					mutiArgs2 = b.mutiArgs2
				elseif powerTime < b.propUp then
					powerTime = b.propUp
					mutiArgs1 = b.mutiArgs1
					mutiArgs2 = b.mutiArgs2
				else
				end
			end
		end
	end
	if not mutiArgs1 or not mutiArgs2 then
		return
	end
	for i,v in ipairs(mutiArgs1) do
		if not (g_i3k_db.i3k_db_get_equip_item_cfg(self.data.id).levelReq > v) then
			index = i
			break
		end
	end
	mutiArgs2 = mutiArgs2[index]
	if powerNum >= powerTime * mutiArgs2 then
		item.vars.txtTime:setText("+"..powerNum)
		item.vars.maxImg:show()
	else
		item.vars.txtTime:setText("+"..powerNum)
		item.vars.maxImg:hide()
	end
end
function wnd_create(layout, ...)
	local wnd = wnd_refine_tip.new()
	wnd:create(layout, ...)
	return wnd;
end
