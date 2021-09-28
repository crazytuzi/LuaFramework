-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

require("ui/bill_board")

-------------------------------------------------------
wnd_bill_board_revise = i3k_class("wnd_bill_board_revise", ui.wnd_base)

function wnd_bill_board_revise:ctor( )
	self.side = 0
	self.id = 0
	self.anonymous = 0
	self.content = nil
	self.sendtime = 0
end

function wnd_bill_board_revise:configure( )
	local widgets = self._layout.vars

	self.close_btn = widgets.close_btn
	self.edit_box = widgets.edit_box
	self.close_btn:onClick(self, self.onClose)
	self.player_name = widgets.player_name
	self.editor = widgets.editor
	self.editor:onClick(self, self.onEditor)
end


function wnd_bill_board_revise:onClose()
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BillBoard,"refresh_retain_revise_text",self.side,self.id,self.edit_box:getText())
	g_i3k_ui_mgr:CloseUI(eUIID_BillBoard_Revise)
end

function wnd_bill_board_revise:onEditor()
	local content = self.content
	local side = self.side
	local id = self.id
	local anonymous = self.anonymous

	local textcount = i3k_get_utf8_len( self.edit_box:getText())


	for i,v in ipairs(i3k_db_bill_board) do
		if side == v.zm_fm and id == v.id then
			if textcount > i3k_db_bill_board[i].max_str then
				g_i3k_ui_mgr:PopupTipMessage(string.format("您发布的字数不能超过%d%s",i3k_db_bill_board[i].max_str,"个"))
				break
			elseif self.edit_box:getText() == "" then
				g_i3k_ui_mgr:PopupTipMessage("当前布告板为空，无法发布")
				break
			else
				i3k_sbean.change_message_board(side,id,anonymous, self.edit_box:getText(),self.sendtime)
				break
			end
		end
	end
end
function wnd_bill_board_revise:refresh(side,id,anonymous,content,sendtime)
	self.side = side
	self.id = id
	self.anonymous = anonymous
	self.content = content
	self.sendtime = sendtime
	
	if anonymous == 0 then
		self.player_name:setText("-----"..g_i3k_game_context:GetRoleName())	
	else
		self.player_name:setText("-----"..i3k_get_string(1555))	
	end	
	self.edit_box:setText(self.content)	
end

function wnd_bill_board_revise:initialize_edit_box(content)	
	self.edit_box:setText(content)
end

function wnd_create(layout)
	local wnd = wnd_bill_board_revise.new()
	wnd:create(layout)
	return wnd
end
