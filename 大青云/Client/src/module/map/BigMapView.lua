--[[
大地图主面板
lizhuangzhuang
2014年7月20日11:33:57
]]

_G.UIBigMap = BaseUI:new("UIBigMap");

UIBigMap.CURRENT = "currMap";
UIBigMap.WORLD = "worldMap";
UIBigMap.LOCAL = "localMap";

UIBigMap.currentShowPanel = nil;

function UIBigMap:Create()
	self:AddSWF("bigMapMainPanel.swf",true,"center");
	
	self:AddChild(UIBigMapCurr, UIBigMap.CURRENT );
	self:AddChild(UIBigMapWorld, UIBigMap.WORLD );
	self:AddChild(UIBigMapLocal, UIBigMap.LOCAL );
end

function UIBigMap:OnLoaded(objSwf,name)
	--set child panel
	self:GetChild( UIBigMap.CURRENT ):SetContainer(objSwf.childPanel);
	self:GetChild( UIBigMap.WORLD ):SetContainer(objSwf.childPanel);
	self:GetChild( UIBigMap.LOCAL ):SetContainer(objSwf.childPanel);
	--close
	objSwf.btnClose.click = function() self:Hide(); end;
end

--面板加载的附带资源
function UIBigMap:WithRes()
	return { "bigMapCurr.swf", "bigMapWorld.swf" };
end

function UIBigMap:IsTween()
	return true;
end

function UIBigMap:GetPanelType()
	return 1;
end

function UIBigMap:IsShowSound()
	return true;
end

function UIBigMap:BeforeTween()
	self.tweenStartPos = UIMainMap:GetMapBtnPos();
end

function UIBigMap:OnShow()
	self:ShowCurrMap();
	-- self:ShowMask()
end

function UIBigMap:OnResize( )
	-- self:ShowMask()
end

function UIBigMap:GetWidth()
	return 1126
end

function UIBigMap:GetHeight()
	return 732
end

function UIBigMap:TurnToSubPanel(panelName)
	self:ShowChild( panelName );
	self.currentShowPanel = panelName;
end

function UIBigMap:ShowWorldMap()
	self:TurnToSubPanel( UIBigMap.WORLD );
end

function UIBigMap:ShowCurrMap()
	self:TurnToSubPanel( UIBigMap.CURRENT );
end

function UIBigMap:ShowLocalMap()
	self:TurnToSubPanel( UIBigMap.LOCAL );
end

--监听的消息
function UIBigMap:ListNotificationInterests()
	return {
		NotifyConsts.MapChange,
	}
end

--处理消息
function UIBigMap:HandleNotification(name, body)
	if name == NotifyConsts.MapChange then
		if body.mapType == MapConsts.Type_Curr then
			self:OnMapChange( body.mapId );
		end
	end
end

function UIBigMap:OnMapChange( mapId )
	-- 切换地图后判断：
	-- 如果当前查看的地图与当前地图为同一个，将自动切换到当前地图子面板
	if self.currentShowPanel == UIBigMap.LOCAL then
		local map = MapModel:GetModel( MapConsts.Type_Local );
		local viewMapId = map:GetMapId();
		if viewMapId == mapId then
			self:ShowChild( UIBigMap.CURRENT );
		end
	end
end

function UIBigMap:ShowMask()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local x,y = self:GetPos();
	local wWidth,wHeight = UIManager:GetWinSize();
	objSwf.mask._x = -x;
	objSwf.mask._y = -y;
	objSwf.mask._width = wWidth;
	objSwf.mask._height = wHeight;
end