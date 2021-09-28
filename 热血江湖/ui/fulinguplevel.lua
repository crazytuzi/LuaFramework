-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_fulingUpLevel = i3k_class("wnd_fulingUpLevel", ui.wnd_base)

function wnd_fulingUpLevel:ctor()
	self._itemsEnough = true
end

function wnd_fulingUpLevel:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
	widgets.up_btn:onClick(self, self.onUpLevel)

end

function wnd_fulingUpLevel:refresh(id)
	self._id = id
	self:setIconInfo(id)
end

-- InvokeUIFunction
function wnd_fulingUpLevel:refreshWithoutArgs()
	local id = self._id
	self:refresh(id)

	local cfgID = g_i3k_db.i3k_db_get_wuxing_index(id, #i3k_db_longyin_sprite_addPoint)
	local cfg = i3k_db_longyin_sprite_born[cfgID]
	local points = g_i3k_game_context:getXiangshengPoint(cfgID)
	if not cfg[points + 1] then
		g_i3k_ui_mgr:OpenUI(eUIID_FulingUpLevelMax)
		g_i3k_ui_mgr:RefreshUI(eUIID_FulingUpLevelMax, id)
		g_i3k_ui_mgr:CloseUI(eUIID_FulingUpLevel)
		return
	end
end

function wnd_fulingUpLevel:setIconInfo(id)
	local cfgID = g_i3k_db.i3k_db_get_wuxing_index(id, #i3k_db_longyin_sprite_addPoint)
	local widgets = self._layout.vars

	local icon1, icon2 = g_i3k_db.i3k_db_get_wuxing_xiangsheng_icons(id, #i3k_db_longyin_sprite_addPoint)
	widgets.icon:setImage(g_i3k_db.i3k_db_get_icon_path(icon1))
	widgets.icon2:setImage(g_i3k_db.i3k_db_get_icon_path(icon2))

	local cfg = i3k_db_longyin_sprite_born[cfgID]
	local points = g_i3k_game_context:getXiangshengPoint(cfgID)
	if points == 0 then
		widgets.btn_label2:setText("启动")
	else
		widgets.btn_label2:setText("升级")
	end
	widgets.name:setText(cfg[1].name)

	local data = self:getShowData(id)

	local forwardCount = data.forwardCount -- 导表单词拼错了懒得改
	local forwardName = i3k_db_longyin_sprite_addPoint[cfg[1].forwardType][1].name
	local str1 = "<c=red>["..forwardCount.."]</c>"
	local str2 = "<c=green>["..forwardCount.."]</c>"
	local curPoints = g_i3k_game_context:getWuxingPoint(id)
	local str = curPoints >= forwardCount and str2 or str1
	self._condition = curPoints >= forwardCount
	widgets.quality:setText("前提："..forwardName.."投入"..str.."点")

	self:setCurEffect(data.cur)
	self:setNextEffect(data.next)
	self:setConsumes(data.consumes)
	self._consumes = data.consumes
end

-- id = 0,初始， id = #list 满级了
function wnd_fulingUpLevel:getShowData(id)
	local cfgID = g_i3k_db.i3k_db_get_wuxing_index(id, #i3k_db_longyin_sprite_addPoint)
	local cfg = i3k_db_longyin_sprite_born[cfgID]
	local points = g_i3k_game_context:getXiangshengPoint(cfgID)

	if points == 0 then
		return { cur = "无", next = cfg[points + 1].effectDesc, consumes = cfg[points + 1].consumes, forwardCount = cfg[points + 1].forwardCount}
	end
	if not cfg[points + 1] then
		return { cur = cfg[points].effectDesc, next = "无", consumes = {}, forwardCount = 0}
	end

	return {cur = cfg[points].effectDesc, next = cfg[points + 1].effectDesc, consumes = cfg[points + 1].consumes, forwardCount = cfg[points + 1].forwardCount}
end


function wnd_fulingUpLevel:setCurEffect(text)
	local widgets = self._layout.vars
	widgets.desc1:setText(text)
end

function wnd_fulingUpLevel:setNextEffect(text)
	local widgets = self._layout.vars
	widgets.desc2:setText(text)
end

function wnd_fulingUpLevel:setConsumes(items)
	local widgets = self._layout.vars
	local scroll = widgets.scroll
	scroll:removeAllChildren()
	self._itemsEnough = true
	for k, v in ipairs(items) do
		local ui = require("ui/widgets/lyflsxt")()
		local itemID = v.id
		ui.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemID))
		ui.vars.itemBg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemID))
		ui.vars.suo:setVisible(itemID > 0)
		ui.vars.name:setText(g_i3k_db.i3k_db_get_common_item_name(itemID))
		local rank = g_i3k_db.i3k_db_get_common_item_rank(itemID)
		ui.vars.name:setTextColor(g_i3k_db.g_i3k_get_color_by_rank(rank))
		local haveCount = g_i3k_game_context:GetCommonItemCanUseCount(v.id)
		if math.abs(itemID) == g_BASE_ITEM_COIN then
			ui.vars.item_count:setText(v.count)
		else
			ui.vars.item_count:setText(haveCount.."/"..v.count)
		end

		ui.vars.item_count:setTextColor(g_i3k_get_cond_color(haveCount >= v.count))
		if haveCount < v.count then
			self._itemsEnough = false
		end
		ui.vars.tip_btn:onClick(self, self.onItemTips, itemID)
		scroll:addItem(ui)
	end
end


function wnd_fulingUpLevel:onUpLevel(sender)
	if not self._itemsEnough then
		g_i3k_ui_mgr:PopupTipMessage("道具不足")
		return
	end
	if not self._condition then
		g_i3k_ui_mgr:PopupTipMessage("条件不满足升级")
		return
	end
	local id = self._id
	local cfgID = g_i3k_db.i3k_db_get_wuxing_index(id, #i3k_db_longyin_sprite_addPoint)
	local cfg = i3k_db_longyin_sprite_born[cfgID]
	local points = g_i3k_game_context:getXiangshengPoint(cfgID)
	if not cfg[points + 1] then
		g_i3k_ui_mgr:PopupTipMessage("已达到最高等级")
		return
	end

	i3k_sbean.fulingWuxingUplvl(cfgID, points + 1, self._consumes)
end

-- x生x头像
function wnd_fulingUpLevel:onItemBtn(sender, id)

end

function wnd_fulingUpLevel:onItemTips(sender, itemID)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemID)
end

function wnd_create(layout, ...)
	local wnd = wnd_fulingUpLevel.new()
	wnd:create(layout, ...)
	return wnd;
end
