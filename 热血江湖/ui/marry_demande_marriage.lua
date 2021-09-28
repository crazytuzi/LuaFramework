-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
--立即求婚
-------------------------------------------------------

wnd_marry_demande_marriage = i3k_class("wnd_marry_demande_marriage",ui.wnd_base)

function wnd_marry_demande_marriage:ctor()
	self.canMarry = false
	self.select_size = 0
	self.showTextName = false
end

function wnd_marry_demande_marriage:configure()
	local widgets = self._layout.vars
	self.closeBtn = widgets.close
	self.closeBtn:onClick(self, self.closeButton)
	self.gotoMarryBtn = widgets.gotoMarryBtn --我要求婚
	self.gotoMarryBtn:onClick(self, self.onGotoMarryBtn)
	self.selectSizeBtn = widgets.selectSizeBtn --选择规模
	self.selectSizeBtn:onClick(self, self.onSelectSizeBtn)
	self.textLabel = widgets.textLabel --中间文本
	
	
	self.goBackBtn = widgets.goBackBtn  --返回上层
	self.goBackBtn:onClick(self, self.onGoBackBtn)
	
end

function wnd_marry_demande_marriage:cheakData()
	--检查按钮的显示与否
	self.showTextName = true
	local state = g_i3k_game_context:getEnterProNum() --1 代表月老处 可点 --2 代表姻缘处
	if state ==1 then
		--显示上一层
		self.showTextName = false
		self.goBackBtn:show()
		self.gotoMarryBtn:hide()
		self.selectSizeBtn:show()
	elseif state ==2 then
		local step = g_i3k_game_context:getRecordSteps() --1 ，结婚状态时间
		if step== -1 then
			self.showTextName = false
			self.goBackBtn:show()
			self.gotoMarryBtn:hide()
			self.selectSizeBtn:show()
		end
	else
		
	end
end

function wnd_marry_demande_marriage:refresh()
	self:cheakData()
	self.textLabel:setText(i3k_get_string(885))
	--g_i3k_game_context:setRecordSteps(2)--记录执行到了第几步
end

function wnd_marry_demande_marriage:setCanMarry(able,index)
	self.canMarry = able
	self.select_size = index
end

function wnd_marry_demande_marriage:onGotoMarryBtn(sender)
	--校验条件是否全部满足
	--检测是否已经选择规模 。选择了才允许进入下一环节
	
	if self.canMarry then
		--发求婚协议
		if self.select_size~=0 then
			i3k_sbean.marryPropose(self.select_size)	
		else
			g_i3k_ui_mgr:PopupTipMessage("请选择结婚规模")	
		end
		--g_i3k_logic:OpenMarryProposing()
		--测试开启宴席ui
		--g_i3k_logic:OpenMarryWendding()
		self:closeButton()
	else
		g_i3k_ui_mgr:PopupTipMessage("请选择结婚规模")		
	end
end

function wnd_marry_demande_marriage:onSelectSizeBtn(sender)
	--选过了 还能再选吗？
	--进入选择规模界面
	g_i3k_logic:OpenSelectSize()
	
end

--返回上层
function wnd_marry_demande_marriage:onGoBackBtn(sender)
	self:closeButton()
end

function wnd_marry_demande_marriage:closeButton(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_Marry_Demande_Marriage)
end

function wnd_create(layout)
	local wnd = wnd_marry_demande_marriage.new()
		wnd:create(layout)
	return wnd
end
