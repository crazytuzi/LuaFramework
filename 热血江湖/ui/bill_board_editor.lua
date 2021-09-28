-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_bill_board_editor = i3k_class("wnd_bill_board_editor", ui.wnd_base)

function wnd_bill_board_editor:ctor( )
	self.huafei_btn   = {}
	self.huafei_img   = {}
	self.huafei_count = {}
	self.stay_time_text = {}
	self.yb_tq = {}
	self.zf = 0
	self.id = 0
	self.is_show_name = true
	self.stay_time = 0
	self.cost = 0
	self.anonymous = 0
	self.roleName = nil
	self.isrewrite = 0
	self.cost_type = 0
	self.lifeTime = 0
end

function wnd_bill_board_editor:configure( )
	local widgets = self._layout.vars
	self._layout.vars.close_btn:onClick(self, self.onCloseUI)
	self._layout.vars.niming_btn:onClick(self,self.onTouchNiMingBtn)
	self._layout.vars.fabu_btn:onClick(self,self.onFaBuBtn)
	self.fabu_btn = widgets.fabu_btn
	self.fabu_img = widgets.fabu_img
	self.fabu_text = widgets.fabu_text
	self.niming_img = widgets.niming_img
	self.edit_box = widgets.edit_box
	self.player_name = widgets.player_name

	for i=1,3 do
		local huafei_btn = "huafei_btn"..i
		local huafei_img = "huafei_img"..i
		local huafei_count = "huafei_count"..i
		local yb_tq = "yb_tq"..i
		local stay_time_text = "stay_time_text"..i
		table.insert(self.huafei_btn,widgets[huafei_btn])
		table.insert(self.huafei_img,widgets[huafei_img])
		table.insert(self.huafei_count,widgets[huafei_count])
		table.insert(self.yb_tq,widgets[yb_tq])
		table.insert(self.stay_time_text,widgets[stay_time_text])

		self.huafei_btn[i]:setTag(i+1000)
		local tag = self.huafei_btn[i]:getTag()

		self.huafei_btn[i]:onClick(self,self.onTouchHuaFei,{tag,self.zf,self.id})
	end
	
end

function wnd_bill_board_editor:onCloseUI()
	local content = self:get_edit_data()
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BillBoard,"refresh_retain_text",self.zf,self.id,content)
	g_i3k_ui_mgr:CloseUI(eUIID_BillBoard_Editor)
end

function wnd_bill_board_editor:onTouchNiMingBtn()
	if self.niming_img:isVisible() == false then
		self.niming_img:show()
		self.is_show_name = false
	else
		self.niming_img:hide()
		self.is_show_name = true
	end
	
end
function wnd_bill_board_editor:onFaBuBtn()
	local zf = self.zf
	local id = self.id
	local content = self:get_edit_data()
	local time = self.stay_time
	local cost = self.cost
	if self.is_show_name == true then
		self.anonymous = 0
	elseif  self.is_show_name == false then
		self.anonymous = 1
	end
	local anonymous  = self.anonymous
	local roleName = g_i3k_game_context:GetRoleName()
	local textcount = i3k_get_utf8_len(content)

	for i,v in ipairs(i3k_db_bill_board) do
		if zf == v.zm_fm and id == v.id then
			if textcount > i3k_db_bill_board[i].max_str then
				g_i3k_ui_mgr:PopupTipMessage(string.format("您发布的字数不能超过%d%s",i3k_db_bill_board[i].max_str,"个"))
				break
			elseif content == "" then
				g_i3k_ui_mgr:PopupTipMessage("当前布告板为空，无法发布")
				break
			elseif time >= self.lifeTime then
				g_i3k_ui_mgr:OpenUI(eUIID_BillBoard_CL)
				g_i3k_ui_mgr:RefreshUI(eUIID_BillBoard_CL,zf,id,content,time,cost,anonymous,self.isrewrite,self.cost_type)
				break
			elseif time < self.lifeTime then
				g_i3k_ui_mgr:PopupTipMessage("您所选择的时间少于当前发布的时间总长")
				break
			end
		end
	end
end

function wnd_bill_board_editor:onTouchHuaFei(sender,tag_side_id)
		tag_side_id[2] = self.zf
		tag_side_id[3] = self.id
		for k,v in pairs(self.huafei_img) do
			if k == tag_side_id[1] - 1000 and v:isVisible() == true then
				break
			elseif k == tag_side_id[1] - 1000 and v:isVisible() == false  then
				v:show()
			else
				v:hide()
			end
		end
		
		for i,v in ipairs(i3k_db_bill_board) do
			if v.zm_fm == tag_side_id[2] and v.id ==tag_side_id[3] then 
				if self.roleName ~= g_i3k_game_context:GetRoleName()then
					if tag_side_id[1] - 1000 == 1 then
						self.cost = i3k_db_bill_board[i].cost1 * 2
						self.stay_time = i3k_db_bill_board[i].stay_time1
						break
					elseif tag_side_id[1] - 1000 == 2 then
						self.cost = i3k_db_bill_board[i].cost2 * 2
						self.stay_time = i3k_db_bill_board[i].stay_time2
						break
					elseif tag_side_id[1] - 1000 == 3 then
						self.cost = i3k_db_bill_board[i].cost3 * 2
						self.stay_time = i3k_db_bill_board[i].stay_time3
						break
					end				
				else
					if tag_side_id[1] - 1000 == 1 then
						self.cost = i3k_db_bill_board[i].cost1 
						self.stay_time = i3k_db_bill_board[i].stay_time1
						break
					elseif tag_side_id[1] - 1000 == 2 then
						self.cost = i3k_db_bill_board[i].cost2 
						self.stay_time = i3k_db_bill_board[i].stay_time2
						break
					elseif tag_side_id[1] - 1000 == 3 then
						self.cost = i3k_db_bill_board[i].cost3 
						self.stay_time = i3k_db_bill_board[i].stay_time3
						break
					end
				end
			end
		end
end

function wnd_bill_board_editor:get_edit_data()
	local content = self.edit_box:getText()
	return content
end

function wnd_bill_board_editor:refresh(zf,id,cost_type,roleName,lifeTime)
	self.zf = zf
	self.id = id
	self.roleName = roleName
	self.cost_type = cost_type
	self.lifeTime = lifeTime

	local now_roleName = g_i3k_game_context:GetRoleName()
	for i,v in ipairs(i3k_db_bill_board) do
		if v.zm_fm == zf and v.id ==id then			
			self.stay_time = i3k_db_bill_board[i].stay_time1
		end
	end
	-- if roleName == now_roleName then 
	-- 	for i,v in ipairs(i3k_db_bill_board) do
	-- 		if zf == v.zm_fm and id == v.id then 
	-- 			self.cost = v.cost1
	-- 		end
	-- 	end
	-- 	for i,v in ipairs(i3k_db_bill_board) do
	-- 		if zf == v.zm_fm and id == v.id then 
	-- 			self.cost = v.cost1 *２
	-- 		end
	-- 	end
	-- end	
	for i,e in ipairs(i3k_db_bill_board) do
		if zf == e.zm_fm and id == e.id then 
			local value = roleName == now_roleName and e.cost1 or e.cost1 * 2
			self.cost = value
		end
	end
	
 	if roleName ~= now_roleName then
		self.fabu_text:setText("覆 盖")
		self.isrewrite = 1
	end
	self.player_name:setText("-----"..now_roleName)

	self:refresh_cost(self.zf,self.id,cost_type,self.roleName)
	self:refresh_stay_time_text(self.zf,self.id)

end

function wnd_bill_board_editor:refresh_cost(side,id,cost_type,roleName)

	for k,v in ipairs(i3k_db_bill_board) do
		if side == v.zm_fm and id == v.id then 
			if  cost_type == 1 then
				if roleName == g_i3k_game_context:GetRoleName() then 
					self.yb_tq[1]:setImage(i3k_db_icons[32].path)
					self.yb_tq[2]:setImage(i3k_db_icons[32].path)
					self.yb_tq[3]:setImage(i3k_db_icons[32].path)			
					self.huafei_count[1]:setText(i3k_db_bill_board[k].cost1)
					self.huafei_count[2]:setText(i3k_db_bill_board[k].cost2)
					self.huafei_count[3]:setText(i3k_db_bill_board[k].cost3)
					break
				else	
					self.yb_tq[1]:setImage(i3k_db_icons[32].path)
					self.yb_tq[2]:setImage(i3k_db_icons[32].path)
					self.yb_tq[3]:setImage(i3k_db_icons[32].path)			
					self.huafei_count[1]:setText(i3k_db_bill_board[k].cost1 * 2)
					self.huafei_count[2]:setText(i3k_db_bill_board[k].cost2 * 2)
					self.huafei_count[3]:setText(i3k_db_bill_board[k].cost3 * 2)
					break
				end	
			elseif  cost_type == 2 then
				if roleName == g_i3k_game_context:GetRoleName() then
					self.yb_tq[1]:setImage(i3k_db_icons[30].path)
					self.yb_tq[2]:setImage(i3k_db_icons[30].path)
					self.yb_tq[3]:setImage(i3k_db_icons[30].path)
					self.huafei_count[1]:setText(i3k_db_bill_board[k].cost1)
					self.huafei_count[2]:setText(i3k_db_bill_board[k].cost2)
					self.huafei_count[3]:setText(i3k_db_bill_board[k].cost3)
					break
				else
					self.yb_tq[1]:setImage(i3k_db_icons[30].path)
					self.yb_tq[2]:setImage(i3k_db_icons[30].path)
					self.yb_tq[3]:setImage(i3k_db_icons[30].path)			
					self.huafei_count[1]:setText(i3k_db_bill_board[k].cost1 * 2)
					self.huafei_count[2]:setText(i3k_db_bill_board[k].cost2 * 2)
					self.huafei_count[3]:setText(i3k_db_bill_board[k].cost3 * 2)
					break
				end
			end
		end
	end
end

function wnd_bill_board_editor:refresh_stay_time_text(side,id)
	for k,v in ipairs(i3k_db_bill_board) do
		if side == v.zm_fm and id == v.id then
			--for i=1,3 do
				--local str = "stay_time"..i
				--self.stay_time_text[i]:setText(((i3k_db_bill_board[k].str)/86400).."小时")
				self.stay_time_text[1]:setText(((i3k_db_bill_board[k].stay_time1)/3600).."小时")
				self.stay_time_text[2]:setText(((i3k_db_bill_board[k].stay_time2)/3600).."小时")
				self.stay_time_text[3]:setText(((i3k_db_bill_board[k].stay_time3)/3600).."小时")
			--end
		end
	end
end

function wnd_bill_board_editor:initialize_edit_box(content)
	self.edit_box:setText(content)
end

function wnd_create(layout)
	local wnd = wnd_bill_board_editor.new()
	wnd:create(layout)
	return wnd
end
