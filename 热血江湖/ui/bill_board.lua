-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
local bill_board_editor = require("ui/bill_board_editor")

require("i3k_ui_mgr")

-------------------------------------------------------
wnd_bill_board = i3k_class("wnd_bill_board", ui.wnd_base)

function wnd_bill_board:ctor( )
	self.bianji_btn   = {}
	self.player_text  = {}
	self.player_name  = {}
	self.ding_btn     = {}
	self.ding_text    = {}
	self.cai_btn      = {}
	self.cai_text     = {}
	self.red_point_compare = {}
	self.blank_text = {}

	self.retain_text = {}
	self.retain_revise_text = {}

end

function wnd_bill_board:configure( )

	local widgets = self._layout.vars

	self.zmjd = widgets.zmjd
	self.bmjd = widgets.bmjd

	self._layout.vars.close_btn:onClick(self, self.onCloseUI)

	self.zm_btn = widgets.zm_btn
	self.bm_btn = widgets.bm_btn

	self.red_point1 = widgets.red_point1
	self.red_point2 = widgets.red_point2

	self.zm_btn:stateToPressed()
	self.bm_btn:stateToNormal()
	self.zm_btn:onClick(self, self.onTouch_zm_btn)
	self.bm_btn:onClick(self, self.onTouch_bm_btn)
	self._layout.vars.marry_btn:onClick(self, self.onTouch_marry_reserve)

	for i=1,10 do
		local bianji_btn  = "bianji_btn"..i

		local player_text = "player_text"..i
		local player_name = "player_name"..i

		local ding_btn    = "ding_btn"..i
		local ding_text   = "ding_text"..i
		local cai_btn     = "cai_btn"..i
		local cai_text    = "cai_text"..i

		local blank_text  = "blank_text"..i

		table.insert(self.bianji_btn,widgets[bianji_btn])
		table.insert(self.player_text,widgets[player_text])
		table.insert(self.player_name,widgets[player_name])
		table.insert(self.ding_btn,widgets[ding_btn])
		table.insert(self.ding_text,widgets[ding_text])
		table.insert(self.cai_btn,widgets[cai_btn])
		table.insert(self.cai_text,widgets[cai_text])
		table.insert(self.blank_text,widgets[blank_text])
	end

	for i=1,10 do
		self.retain_text[i] = ""
		self.retain_revise_text[i] = ""
	end
end

function wnd_bill_board:onCloseUI()
	g_i3k_ui_mgr:CloseUI(eUIID_BillBoard)
end

function wnd_bill_board:onEditor(sender, zm_fm_id)
	for i,v in ipairs(i3k_db_bill_board) do
		if v.zm_fm == zm_fm_id.zm_fm and v.id == zm_fm_id.id then
			local total_time = i3k_db_bill_board[i].guard_time+zm_fm_id.sendTime
			local time = i3k_game_get_time()
			local judge_time = time - zm_fm_id.sendTime
			if total_time >= time and zm_fm_id.sendTime ~= 0 then
				if i3k_db_bill_board[i].guard_time - judge_time >= 60 then
					local t1,t2 = math.modf((i3k_db_bill_board[i].guard_time - judge_time)/60)
					g_i3k_ui_mgr:PopupTipMessage(string.format("当前不可发布，请您耐心等待%d%s%d%s",t1,"分",math.floor(t2*60),"秒"))
				else
					g_i3k_ui_mgr:PopupTipMessage(string.format("当前不可发布，请您耐心等待0分%d%s",(i3k_db_bill_board[i].guard_time-judge_time),"秒"))
				end
			else
				g_i3k_ui_mgr:OpenUI(eUIID_BillBoard_Editor)
				g_i3k_ui_mgr:RefreshUI(eUIID_BillBoard_Editor,zm_fm_id.zm_fm,zm_fm_id.id,zm_fm_id.cost_type,zm_fm_id.roleName,zm_fm_id.lifeTime)
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_BillBoard_Editor, "initialize_edit_box",self.retain_text[i])
			end
			break
		end
	end
end

function wnd_bill_board:onTouch_zm_btn()
	self.zm_btn:stateToPressed()
	self.bm_btn:stateToNormal()
	self.zmjd:setVisible(true)
	self.bmjd:setVisible(false)
	self._layout.vars.marry_root:hide()
	self._layout.vars.marry_btn:stateToNormal()
end

function wnd_bill_board:onTouch_bm_btn()
	self.red_point2:setVisible(false)
	self.zm_btn:stateToNormal()
	self.bm_btn:stateToPressed()
	self.zmjd:setVisible(false)
	self.bmjd:setVisible(true)
	self._layout.vars.marry_root:hide()
	self._layout.vars.marry_btn:stateToNormal()
end

function wnd_bill_board:onTouch_marry_reserve()
	local data = g_i3k_game_context:getMarryReserveData()
	if not next(data) then
		g_i3k_ui_mgr:PopupTipMessage("当前没有玩家预约婚礼，敬请期待！")
		return
	end
	self.zm_btn:stateToNormal()
	self.bm_btn:stateToNormal()
	self.zmjd:hide()
	self.bmjd:hide()
	self._layout.vars.marry_root:show()
	self._layout.vars.marry_btn:stateToPressed()
	self:setMarryReserveData()
end

function wnd_bill_board:setMarryReserveData()
	self._layout.vars.scroll:removeAllChildren()
	local data = g_i3k_game_context:getMarryReserveData()
	for _,e in ipairs(data) do
		if i3k_db_marry_reserve[e.timeIndex] then
			local layer = require("ui/widgets/bgbjmt")()
			local widget = layer.vars
			local needTime = string.split(i3k_db_marry_reserve[e.timeIndex].marryTime, ";")
			widget.time:setText(needTime[1] .. "~" .. needTime[2])
			widget.line:setText(i3k_get_string(i3k_db_marry_line[e.line].lineTipsId))
			widget.mName:setText(e.manName)
			widget.gName:setText(e.ladyName)
			self._layout.vars.scroll:addItem(layer)
		end
	end
end

function wnd_bill_board:onTouch_ding_btn(sender,zm_fm_id)
		i3k_sbean.comment_bill_board(zm_fm_id.zm_fm,zm_fm_id.id,1)
end

function wnd_bill_board:onTouch_cai_btn(sender,zm_fm_id)
		i3k_sbean.comment_bill_board(zm_fm_id.zm_fm,zm_fm_id.id,2)
end

function wnd_bill_board:set_count(zm_fm,id,comment)
	if comment == 1 then
		for i,v in ipairs(i3k_db_bill_board) do
			if v.zm_fm == zm_fm and v.id == id then
				local before_ding_text = self.ding_text[i]:getText()
				self.ding_text[i]:setText(tonumber(before_ding_text)+1)
			end
		end
	elseif comment == 2 then
		for i,v in ipairs(i3k_db_bill_board) do
			if v.zm_fm == zm_fm and v.id == id then
				local before_cai_text = self.cai_text[i]:getText()
				self.cai_text[i]:setText(tonumber(before_cai_text)+1)
			end
		end
	end
end

function wnd_bill_board:set_content(zm_fm,id,content,time,anonymous,isrewrite)
	for k,v in ipairs(i3k_db_bill_board) do
		if v.zm_fm == zm_fm and v.id == id then
			self.player_text[k]:setText(content)
			if anonymous == 0 then
				self.player_name[k]:setText("--"..g_i3k_game_context:GetRoleName())
			elseif anonymous == 1 then
				self.player_name[k]:setText("-----"..i3k_get_string(1555))
			end
		end
	end
	if isrewrite == 1 then
		for k,v in ipairs(i3k_db_bill_board) do
			if v.zm_fm == zm_fm and v.id == id then
				self.ding_text[k] = 0
				self.cai_text[k] = 0
			end
		end
	end
end

function wnd_bill_board:refresh(t,fm_new_msg)
	self:SetbillBoardInfo(t,fm_new_msg)
end

function wnd_bill_board:SetbillBoardInfo(t,fm_new_msg)
	if fm_new_msg == 1 and not self.bm_btn:isStatePressed() then
		self.red_point2:setVisible(true)
	end

	if not next(t) then
		for i=1,10 do
			self.bianji_btn[i]:onClick(self,self.onEditor,{zm_fm = i3k_db_bill_board[i].zm_fm,id = i3k_db_bill_board[i].id,cost_type = i3k_db_bill_board[i].cost_type,roleName = g_i3k_game_context:GetRoleName(),lifeTime = 0,sendTime = 0})
			self.ding_btn[i]:onClick(self,self.onTouch_comment_null)
			self.cai_btn[i]:onClick(self,self.onTouch_comment_null)
		end
	else
		self:refresh_blank_text(t)
	end

	for k,a in ipairs(i3k_db_bill_board) do
		for i,v in ipairs(t) do
			self:refresh_content(v.side,v.id,v.anonymous,v.content,v.roleName)
			self:refresh_count(v.side,v.id,v.praiseTime,v.treadTime)

			local now_roleName = g_i3k_game_context:GetRoleName()
			if a.zm_fm == v.side and a.id == v.id and now_roleName == v.roleName then
				self.bianji_btn[k]:onClick(self,self.set_xiugai,{v.side,v.id,v.anonymous,v.content,v.sendTime})
				self.ding_btn[k]:onClick(self,self.onTouch_ding_other,{zm_fm = i3k_db_bill_board[k].zm_fm,id = i3k_db_bill_board[k].id,sendtime = v.sendTime})
				self.cai_btn[k]:onClick(self,self.onTouch_cai_other,{zm_fm = i3k_db_bill_board[k].zm_fm,id = i3k_db_bill_board[k].id,sendtime = v.sendTime})
				break
			elseif a.zm_fm == v.side and a.id == v.id and now_roleName ~= v.roleName then
				self.bianji_btn[k]:onClick(self,self.onEditor,{zm_fm = i3k_db_bill_board[k].zm_fm, id = i3k_db_bill_board[k].id, cost_type = i3k_db_bill_board[k].cost_type, roleName = v.roleName,lifeTime = v.lifeTime,sendTime = v.sendTime})
				self.ding_btn[k]:onClick(self,self.onTouch_ding_other,{zm_fm = i3k_db_bill_board[k].zm_fm,id = i3k_db_bill_board[k].id,sendtime = v.sendTime})
				self.cai_btn[k]:onClick(self,self.onTouch_cai_other,{zm_fm = i3k_db_bill_board[k].zm_fm,id = i3k_db_bill_board[k].id,sendtime = v.sendTime})
				break
			else
				self.bianji_btn[k]:onClick(self,self.onEditor,{zm_fm = i3k_db_bill_board[k].zm_fm, id = i3k_db_bill_board[k].id, cost_type = i3k_db_bill_board[k].cost_type, roleName = now_roleName,lifeTime = 0, sendTime = 0})
				self.ding_btn[k]:onClick(self,self.onTouch_comment_null)
				self.cai_btn[k]:onClick(self,self.onTouch_comment_null)
			end
		end
	end
end
function wnd_bill_board:onTouch_ding_other(sender,zm_fm_id)
	i3k_sbean.comment_bill_board(zm_fm_id.zm_fm,zm_fm_id.id,1,zm_fm_id.sendtime)
end

function wnd_bill_board:onTouch_cai_other(sender,zm_fm_id)
	i3k_sbean.comment_bill_board(zm_fm_id.zm_fm,zm_fm_id.id,2,zm_fm_id.sendtime)
end

function wnd_bill_board:onTouch_comment_null()
	g_i3k_ui_mgr:PopupTipMessage("这里还没有布告，无法评价")
end

function wnd_bill_board:refresh_content(side,id,anonymous,content,roleName)
	for k,v in ipairs(i3k_db_bill_board) do
		if v.zm_fm == side and v.id == id  then
			if content then
				self.player_text[k]:setText(content)
			end
			if anonymous == 0 then
				self.player_name[k]:setText("-----"..roleName)
			elseif anonymous == 1 then
				self.player_name[k]:setText("-----"..i3k_get_string(1555))
			end
		end
	end
end

function wnd_bill_board:refresh_count(side,id,ding,cai)
	for k,v in ipairs(i3k_db_bill_board) do
		if v.zm_fm == side and v.id == id  then
			self.ding_text[k]:setText(ding)
			self.cai_text[k]:setText(cai)
		end
	end
end

function wnd_bill_board:set_xiugai(sender,t)
	local side = t[1]
	local id = t[2]
	local anonymous = t[3]
	local content = t[4]
	local sendTime = t[5]

	for k,v in ipairs(i3k_db_bill_board) do
		if v.zm_fm == side and v.id == id  then
			g_i3k_ui_mgr:OpenUI(eUIID_BillBoard_Revise)
			g_i3k_ui_mgr:RefreshUI(eUIID_BillBoard_Revise,side,id,anonymous,content,sendTime)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BillBoard_Revise, "initialize_edit_box",self.retain_revise_text[k])
		end
	end
end

function wnd_bill_board:after_change(side,id,anonymous,content)
	for k,v in ipairs(i3k_db_bill_board) do
		if v.zm_fm == side and v.id == id then
			self.player_text[k]:setText(content)
		end
	end
end

function wnd_bill_board:refresh_retain_text(side,id,content)
	for k,v in ipairs(i3k_db_bill_board) do
		if v.zm_fm == side and v.id == id  then
			self.retain_text[k] = content
		end
	end
end

function wnd_bill_board:refresh_retain_revise_text(side,id,content)
	for k,v in ipairs(i3k_db_bill_board) do
		if v.zm_fm == side and v.id == id  then
			self.retain_revise_text[k] = content
		end
	end
end

function wnd_bill_board:refresh_blank_text(t)
	for  k,a in ipairs(i3k_db_bill_board) do
		for i,v in ipairs(t) do
			if a.zm_fm == v.side and a.id == v.id then
				self.blank_text[k]:setVisible(false)
				break
			end
		end
	end
end

function wnd_create(layout)
	local wnd = wnd_bill_board.new()
	wnd:create(layout)
	return wnd
end
