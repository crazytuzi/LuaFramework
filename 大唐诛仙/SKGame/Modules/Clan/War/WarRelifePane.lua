WarRelifePane = BaseClass(LuaUI)
local confirm = nil
function WarRelifePane:__init()
	if not resMgr:AddUIAB("clan") then return nil end
	local ui = UIPackage.CreateObject("Duhufu" , "WarRelifePane")
	self.ui = ui
	self.content = ui:GetChild("content")
	self.btn = ui:GetChild("btn")

	self.btn.onClick:Add(function ()
		if self.fun then self.fun() end
		UIMgr.HidePopup(self.ui)
		RenderMgr.Realse(render_key)
		SceneController:GetInstance():RequireRevive(1) -- 玩家复活
	end)
end
local render_key = "WarRelifePane_key"
function WarRelifePane:SetInfo(content, title, l, f, less)
	self.ui.title = title or "提示"
	self.content.text = content
	self.btn.title =l or "复活"
	self.fun = f
	if less then
		RenderMgr.Realse(render_key)
		RenderMgr.AddInterval(function()
			less = less - 1
			self.btn.title = StringFormat("复 活({0}秒)",less)
		end, render_key, 1, less, function ()
			if self.fun then self.fun() end
			UIMgr.HidePopup(self.ui)
			SceneController:GetInstance():RequireRevive(1) -- 玩家复活
		end)
	end
end

function WarRelifePane.Show(content, title, l, f, less)
	if confirm == nil then confirm = WarRelifePane.New() end
	confirm:SetInfo(content, title, l, f, less)
	UIMgr.ShowCenterPopup(confirm,function ()
		confirm=nil
	end, true)
end

function WarRelifePane:__delete()
	RenderMgr.Realse(render_key)
end