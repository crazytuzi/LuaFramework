-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_steed_practice_tips = i3k_class("wnd_steed_practice_tips", ui.wnd_base)

function wnd_steed_practice_tips:ctor()
	self.enhanceLvl = 0
end

function wnd_steed_practice_tips:configure()

end

function wnd_steed_practice_tips:onShow()
	
end

function wnd_steed_practice_tips:getColor(limtlvl)
	return self.enhanceLvl >= limtlvl and g_i3k_get_orange_color() or g_i3k_get_grey_color()
end

function wnd_steed_practice_tips:refresh(info)
	local vars = self._layout.vars
	local steedCfg = i3k_db_steed_cfg[info.id]
	vars.enhanceLvlLabel:setText(string.format("%s:%d", "洗练等级", info.enhanceLvl))
	local huanHuacfg = i3k_db_steed_huanhua[steedCfg.huanhuaInitId]
	vars.steedName:setText(huanHuacfg.name)
	vars.closeBtn:onClick(self, self.onCloseUI)

	self.enhanceLvl = info.enhanceLvl
	for i,v in ipairs(i3k_db_steed_Properties_ui[steedCfg.refineId]) do
		local node = require("ui/widgets/zqtipst1")()
		
		node.vars.name:setText(i3k_db_prop_id[v.propId].desc..":")
		node.vars.value:setText(v.minValue.."~"..v.maxValue)
		vars.attrScroll:addItem(node)
	end
	local limtiLvl = {}
	local limti_Lvl = {}
	local lockNum = {}
	local lock_Num = {}
	local addProp = {}
	local add_prop = {}
	for i , v in ipairs(i3k_steed_lvl_propLock) do
		if v.propNum > i3k_steed_lvl_propLock[1].propNum then
			if not limtiLvl[v.propNum] then
				limtiLvl[v.propNum] = i
				table.insert(limti_Lvl,{ propNum = v.propNum, lvl = i})
			end
		end
		if v.maxLockNum > i3k_steed_lvl_propLock[1].maxLockNum then
			if not lockNum[v.maxLockNum] then
				lockNum[v.maxLockNum] = i
				table.insert(lock_Num,{ lockNum = v.maxLockNum, lvl = i})
			end
		end
		if v.isAddProp then
			if v.isAddProp > 0 and not addProp[v.isAddProp] then
				addProp[v.isAddProp] = i
				table.insert(add_prop,{ lvl = i})
			end
		end
	end
	
	local descTb = {}
	for i,v in ipairs(limti_Lvl) do
		table.insert(descTb,{lvl = v.lvl, desc = i3k_get_string(15350,v.lvl, v.propNum)})
	end
	for i,v in ipairs(lock_Num) do
		table.insert(descTb,{lvl = v.lvl, desc = i3k_get_string(15351,v.lvl, v.lockNum)})
	end
	table.insert(descTb,{lvl = add_prop[1].lvl, desc = i3k_get_string(15352,add_prop[1].lvl)})
	table.sort(descTb,function (a, b)
		if a.lvl ~= b.lvl then
			return a.lvl < b.lvl
		end
		return false
	end)
	for i,v in ipairs(descTb) do
		local node = require("ui/widgets/zqtipst2")()
		node.vars.desc:setText(v.desc)
		node.vars.desc:setTextColor(self:getColor(v.lvl))
		
		node.vars.desc:setRichTextFormatedEventListener(function(sender)
			local nheight = node.vars.desc:getInnerSize().height
			local tSizeH = node.vars.desc:getSize().height
			if nheight > tSizeH then
				local size = node.rootVar:getContentSize()
				node.rootVar:changeSizeInScroll(vars.descScroll, size.width, size.height + nheight - tSizeH, true)
		 	end
			node.vars.desc:setRichTextFormatedEventListener(nil)
		end)
		vars.descScroll:addItem(node)
	end
end


function wnd_create(layout, ...)
	local wnd = wnd_steed_practice_tips.new()
	wnd:create(layout, ...)
	return wnd;
end
