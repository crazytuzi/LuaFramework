-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
-------------------------------------------------------
mercenarypop = i3k_class("mercenarypop",ui.wnd_base)
function mercenarypop:ctor()
	self._poptick = 0
	self._updatetick = 0;
	self._pos = nil;
end

function mercenarypop:refresh(ntype,mid,mercenary)
	
	if ntype == 1 then
		local dcfg = i3k_db_dialogue[mercenary._cfg.normalpop]
			local maxindex = #dcfg
			local index = i3k_engine_get_rnd_u(1,maxindex)
		self.text:setText(dcfg[index].txt)
	elseif ntype == 2 then
		local dcfg = i3k_db_dialogue[mercenary._cfg.fightpop]
			local maxindex = #dcfg
			local index = i3k_engine_get_rnd_u(1,maxindex)
		self.text:setText(dcfg[index].txt)
	elseif ntype == 3 then
		local dcfg = i3k_db_dialogue[mercenary._cfg.revivepop]
			local maxindex = #dcfg
			local index = i3k_engine_get_rnd_u(1,maxindex)
		self.text:setText(dcfg[index].txt)
	end
	g_i3k_ui_mgr:AddTask(self, {}, function (self)
		if not self.bg then
			local lan = self._layout.vars.lan
			local lv = self._layout.vars.lv
			local hong = self._layout.vars.hong
			self.bg = {lan,hong,lv}
		end
		local nwidth = self._layout.vars.text:getInnerSize().width + 20
		local nheight = self._layout.vars.text:getInnerSize().height + 20
		local bgwidth = self.bg[ntype]:getSize().width
		local bgheight = self.bg[ntype]:getSize().height
		
		nwidth = nwidth>bgwidth and nwidth or bgwidth
		nheight = nheight>bgheight and nheight or bgheight
		self.bg[ntype]:setContentSize(nwidth, nheight)
		self.bg[ntype]:setVisible(true)
	end)
	self._poptick = 0
	self._updatetick = 1
	self._mid = mid
	self.mercenary = mercenary
	local mpos = i3k_vec3_clone(self.mercenary._curPosE);
	mpos.y = mpos.y + self.mercenary._rescfg.titleOffset;
	self._pos = g_i3k_mmengine:GetScreenPos(i3k_vec3_to_engine(mpos))
	
	self:setBubblePos(self.qipao, self._pos)
end

function mercenarypop:configure(...)
	self.screenSize = cc.Director:getInstance():getWinSize();
	self.frameSize = cc.Director:getInstance():getOpenGLView():getFrameSize()
	local rootSize = self._layout.root:getContentSize();
	local widget = self._layout.vars
	local lan = widget.lan
	local lv = widget.lv
	local hong = widget.hong
	self.qipao = widget.qipao
	self.bg = {lan,hong,lv}
	self.text = widget.text
	for k,v in pairs(self.bg) do
		v:setVisible(false)
	end
end

function mercenarypop:onUpdate(dTime)
	self._poptick = self._poptick + dTime;
	self._updatetick = self._updatetick + dTime;
	if self.mercenary then
		local mpos = i3k_vec3_clone(self.mercenary._curPosE);
		mpos.y = mpos.y + self.mercenary._rescfg.titleOffset;
		local pos = g_i3k_mmengine:GetScreenPos(i3k_vec3_to_engine(mpos))
		if self._pos.x ~= pos.x or self._pos.y ~= pos.y then
			self:setBubblePos(self.qipao, pos)
		end
		if self._poptick > i3k_db_common.mercenarypop.popalivetime/1000 then
			g_i3k_ui_mgr:CloseUI((eUIID_MercenaryPop1+self._mid - 1))
		end
	end
end

function mercenarypop:onClose()
	g_i3k_ui_mgr:CloseUI((eUIID_MercenaryPop1+self._mid - 1))
end

function mercenarypop:onShow()

end

function mercenarypop:onHide()

end

function wnd_create(layout, ...)
	local wnd = mercenarypop.new()
	wnd:create(layout, ...)
	return wnd
end
