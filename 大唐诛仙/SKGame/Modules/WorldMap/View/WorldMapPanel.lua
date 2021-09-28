WorldMapPanel =BaseClass(BaseView)

function WorldMapPanel:__init( ... )
	self.URL = "ui://rkrzdlw3elj82";

	self.ui = UIPackage.CreateObject("WorldMaps","WorldMapPanel")

	self.mapLayer = self.ui:GetChild("mapLayer")
	self.btnClose = self.ui:GetChild("btnClose")
	self.changeSecMapBtn = self.ui:GetChild("changeSecMapBtn")

	--self.changeSecMapBtn.visible = false

	self:InitEvent()
	self:Layout()
	self:Refresh()
end

function WorldMapPanel:InitEvent()
	self.closeCallback = function () end
	self.openCallback  = function ()
		-- local bottom = false 
		-- for k,index in pairs(WorldMapConst.NeedBottom) do
		-- 	local curId = SceneModel:GetInstance().sceneId
		-- 	if WorldMapConst.MapId[index].mapId == curId then 
		-- 		bottom = true 
		-- 	end
		-- end
		-- if bottom then 
		-- 	self.mapLayer.scrollPane:ScrollBottom(true)
		-- else
		-- 	self.mapLayer.scrollPane:ScrollTop(true)
		-- end
	end
	self.btnClose.onClick:Add(function ()
		self:Close()
	end)
	self.changeSecMapBtn.onClick:Add(function ()
		WorldMapController:GetInstance():Open(0)
	end)
	self.handler1=GlobalDispatcher:AddEventListener(EventName.TEAM_CHANGED,function ()
		self:Refresh()
	end) --组队信息有变化
	self.handler2=WorldMapModel:GetInstance():AddEventListener(WorldMapConst.ClosePanel,function ()
		self:Close()
	end)

end

function WorldMapPanel:Layout()
	self.mapPanel = MapBg.Create(self.mapLayer)
	self.mapPanel:Init()
end
function WorldMapPanel:Refresh()
	if self.mapPanel then 
		self.mapPanel:Refresh()
	end
end

function WorldMapPanel:__delete()
	if self.mapPanel then 
		self.mapPanel:Destroy()
	end
	self.mapPanel = nil
	WorldMapModel:GetInstance():RemoveEventListener(self.handler1)
	GlobalDispatcher:RemoveEventListener(self.handler2)
end