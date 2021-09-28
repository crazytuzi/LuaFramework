WarJieshaoPane = BaseClass(LuaUI)
function WarJieshaoPane:__init()
	local ui = UIPackage.CreateObject("Duhufu","WarJieshaoPane")
	self.ui = ui
	self.pre = ui:GetChild("pre")
	self.nxt = ui:GetChild("nxt")

	self:InitEvent()
	self.page=1
	self:Config(self.page)
end
function WarJieshaoPane:InitEvent()
	local max = #ClanConst.warJieshao
	self.pre.onClick:Add(function ()
		self.page = self.page - 1
		self.page = math.max(self.page, 1)
		self:Config(self.page)
	end)
	self.nxt.onClick:Add(function ()
		self.page = self.page + 1
		self.page = math.min(self.page, max)
		self:Config(self.page)
	end)
end
local uiheader = "ui://"
function WarJieshaoPane:Config( page )
	-- print("第"..page.."页")
	local content = ClanConst.warJieshao[page]
	self.ui.icon=nil
	self.ui.title=""
	if string.find(content,uiheader) == 1 then
		self.ui.icon = content
	else
		self.ui.title = content
	end
end

function WarJieshaoPane:__delete()
end