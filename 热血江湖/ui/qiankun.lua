-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_qiankun = i3k_class("wnd_qiankun", ui.wnd_base)


function wnd_qiankun:ctor()
	self.qiankunWidget = {}
end

function wnd_qiankun:configure( )
	local widgets = self._layout.vars
	
	self:initQiankunWidget(widgets)
	widgets.qiankunBtn:stateToPressed()
	
	self.rule = widgets.rule
	self.leftTimes = widgets.leftTimes
	self.resetBtn = widgets.resetBtn
	self.buyBtn = widgets.buyBtn
	self.buyText = widgets.buyText
	self.red_point = widgets.red_point1
	self.red_point2 = widgets.red_point2
	self.red_point3 = widgets.red_point3
	
	widgets.penetrate_btn:onClick(self, self.penetrateBtn)
	widgets.library_btn:onClick(self, self.libraryBtn)
	widgets.empowerment_btn:onClick(self, self.empowermentBtn)
	
	widgets.buyBtn:onClick(self, self.onClickBuyBtn)
	widgets.resetBtn:onClick(self, self.onClickResetBtn)
	widgets.closeBtn:onClick(self, self.onCloseUI)
end

function wnd_qiankun:initQiankunWidget(widgets)
	for i=1, 16 do
		local lvlTxt = "lvlTxt"..i
		local descTxt = "descTxt"..i
		local addBtn = "addBtn"..i
		
		self.qiankunWidget[i] = {
			lvlTxt		= widgets[lvlTxt],
			descTxt		= widgets[descTxt],
			addBtn		= widgets[addBtn],
		}
	end
end

function wnd_qiankun:refresh()
	local qiankuninfo = g_i3k_game_context:getQiankunInfo()
	g_i3k_game_context:SetQianKunRedRecord(true)
	self.rule:setText(i3k_get_string(891))
	for i, e in ipairs(i3k_db_experience_universe) do
		local lvl = qiankuninfo.levels[i] or 0
		local cfg = e[lvl]
		local desc = g_i3k_db.i3k_db_get_attribute_name(cfg.propertyId)
		self.qiankunWidget[i].lvlTxt:setText(i3k_get_string(929, lvl))
		self.qiankunWidget[i].descTxt:setText(desc..i3k_get_prop_show(cfg.propertyId, cfg.propertyValue))
		self.qiankunWidget[i].addBtn:onClick(self, self.onAddPoint, {id = i, lvl = lvl, isMax = lvl == #e, cfg = cfg})
	end
	self.leftTimes:setText(g_i3k_game_context:getCanUseQiankunPoint())
	self.resetBtn:setVisible(qiankuninfo.usePoints ~= 0)
	self.buyBtn:setVisible(qiankuninfo.totalPoints < i3k_db_experience_args.experienceUniverse.maxPoint)
	self.red_point:setVisible(g_i3k_game_context:redPointForAllCheats() or g_i3k_game_context:redPointForBooks()) --红点逻辑
	self.red_point2:setVisible(g_i3k_game_context:qiankunRedPoints() ) --红点逻辑
	self.red_point3:setVisible(g_i3k_game_context:isShowCunWnRed())
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_XB, "updateEmpowermentNotice")
end

function wnd_qiankun:onClickResetBtn(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_QiankunReset)
	g_i3k_ui_mgr:RefreshUI(eUIID_QiankunReset)
end

function wnd_qiankun:onAddPoint(sender, info)
	if info.isMax then
		local desc = g_i3k_db.i3k_db_get_attribute_name(info.cfg.propertyId)
		g_i3k_ui_mgr:ShowMessageBox1(i3k_get_string(930, desc, i3k_get_prop_show(info.cfg.propertyId, info.cfg.propertyValue)))
	else
		g_i3k_ui_mgr:OpenUI(eUIID_QiankunUp)
		g_i3k_ui_mgr:RefreshUI(eUIID_QiankunUp, info.id, info.lvl)
	end
end

function wnd_qiankun:onClickBuyBtn(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_QiankunBuy)
	g_i3k_ui_mgr:RefreshUI(eUIID_QiankunBuy)
end

function wnd_qiankun:libraryBtn(sender)
	if g_i3k_game_context:GetLevel() < i3k_db_experience_args.args.libraryShowLevel then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(931, i3k_db_experience_args.args.libraryShowLevel))
		return
	end
	i3k_sbean.goto_rarebook_sync()   --同步藏书协议
end

function wnd_qiankun:penetrateBtn()
	i3k_sbean.goto_grasp_sync()      --同步参悟协议
end

function wnd_qiankun:empowermentBtn(sender,data)
	i3k_sbean.goto_expcoin_sync()   --历练协议
end

function wnd_create(layout)
	local wnd = wnd_qiankun.new()
	wnd:create(layout)
	return wnd
end


	
