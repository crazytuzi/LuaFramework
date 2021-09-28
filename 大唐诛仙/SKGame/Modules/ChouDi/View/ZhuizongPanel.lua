ZhuizongPanel = BaseClass(LuaUI)
function ZhuizongPanel:__init( itemId )

	self.ui = UIPackage.CreateObject("ChouDi","ZhuizongPanel");

	
	self.title = self.ui:GetChild("title")
	self.zhuzongText = self.ui:GetChild("zhuzongText")
	self.resGezi = self.ui:GetChild("resGezi")
	self.txtResNum = self.ui:GetChild("txtResNum")
	self.btnQX = self.ui:GetChild("btnQX")
	self.btnQD = self.ui:GetChild("btnQD")
	self.btnAddRes = self.ui:GetChild("btnAddRes")

	self:InitEvent(itemId)
end
function ZhuizongPanel:InitEvent(itemId)
	self.btnAddRes.onClick:Add(function()
		UIMgr.HidePopup(self.ui)
		local id = ChouDiModel:GetInstance():GetResMarketId(itemId)  
		MallController:GetInstance():QuickBuy(id , function() 
			--Close Callback
		end)
	end)
end
-- 布局UI
function ZhuizongPanel:Layout()
	self.container:AddChild(self.ui) -- 不改动，注意自行设置self.ui位置
	-- 以下开始UI布局
	
end

-- Dispose use ZhuizongPanel obj:Destroy()
function ZhuizongPanel:__delete()
	
end