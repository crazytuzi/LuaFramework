--[[
	地图基类
	2015年4月2日10:38:33
	haohu
]]

_G.BaseMap = {};

BaseMap.allMap = {};

function BaseMap:GetMap( mapName )
	return BaseMap.allMap[mapName];
end
----------------------------------------------

BaseMap.mapType  = nil;
BaseMap.mapName  = nil;
BaseMap.iconList = nil;

-- 构造函数
-- @param mapType: 地图类型--区分model
-- @param mapName: 地图名字--区分view
function BaseMap:new(name, mapType, mapName)
	local map = BaseUI:new(name);
	for k, v in pairs(self) do
		if type(v) == "function" and k ~= "GetMap" then
			map[k] = v;
		end
	end
	map.mapType = mapType;
	map.mapName = mapName;
	map.iconList = {}; -- 保存地图上所有图标
	BaseMap.allMap[mapName] = map;
	return map;
end

function BaseMap:GetScale()
	return 1;
end

function BaseMap:GetIcon( uid )
	return self.iconList[uid];
end

function BaseMap:SetIcon( uid, icon )
	self.iconList[uid] = icon;
end

function BaseMap:GetModel()
	return MapModel:GetModel( self.mapType );
end

function BaseMap:OnLoaded(objSwf)
	self:Init(objSwf);
	self:RegisterMapEvents(objSwf);
	self:RegisterOtherEvents(objSwf);
end

function BaseMap:RegisterMapEvents(objSwf)
	local objSwf = self.objSwf;
	if not objSwf then return end
	local map = objSwf.map;
	if map then
		map.mapMouseMove = function() self:OnMapMouseMove(); end;
		map.mapRollOut   = function() self:OnMapRollOut(); end;
		map.mapClick     = function() self:OnMapClick(); end;
		map.mapLoaded    = function() self:OnMapLoaded(); end;
	end
end

function BaseMap:OnShow(name)
	self:UpdateMapShow();
	self:UpdateOther();
	self:OnChildShow();
end

--根据数据层刷新显示
function BaseMap:UpdateMapShow()
	self:ShowMap();-- 添加地图
	self:ShowMapName(); -- 地图名字
	self:ShowIcon();-- 添加图标
end

function BaseMap:OnMapChange(mapId)
	self:ShowMap();
	self:ShowMapName();
end

function BaseMap:OnChildShow()
	-- 子类实现
end

function BaseMap:ShowMapName()
	-- 子类实现
end

--显示地图
function BaseMap:ShowMap()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local model = self:GetModel();
	local mapId = model:GetMapId();
	local map = objSwf.map;
	local url = ResUtil:GetMapImgUrl( mapId );
	if not url then return end;
	if _G.isDebug and map then
		map.source = url;
		return;
	end
	if map then
		if map.source ~= url then
			map.source = url;
		end
	end
end

-- 显示图标
function BaseMap:ShowIcon()
	self:ClearAllIcon();
	local model = self:GetModel();
	local mapElements = model:GetElements();  --地图中元素
	for _, vo in pairs( mapElements ) do
		self:AddIcon(vo);
	end
end

function BaseMap:OnDelete()
	self:ClearAllIcon();
end

--鼠标在地图上移动
function BaseMap:OnMapMouseMove()
	-- 子类实现
end

function BaseMap:OnMapClick()
	local objSwf = self.objSwf;
	local map = objSwf and objSwf.map;
	if not map then return; end
	local posx = map._xmouse;
	local posy = map._ymouse;
	local scale = self:GetScale();
	posx, posy = posx / scale, posy / scale;
	local x, y = MapUtils:Point2Dto3D(posx, posy);
	if isDebug then
		if CControlBase.oldKey[_System.KeyCtrl] then
        	if _sys:isKeyDown(_System.KeyAlt) then
        		local text = string.format( "/telport/%s/%s", math.floor(x), math.floor(y) );
        		UIChat:SendChat( text );
        		return;
        	end
        end
	end
	MapController:MoveToMap( self.mapType, x, y );
end

function BaseMap:OnMapLoaded()
	local objSwf = self.objSwf;
	local map = objSwf and objSwf.map;
	if not map then return; end
	map.mapScale = self:GetScale();
end

--鼠标移出地图
function BaseMap:OnMapRollOut()
	TipsManager:Hide();
end

--鼠标点击icon
function BaseMap:OnIconClick(e)
	local vo = e.target.data;
	if not vo then return end;
	self:RunToElem(vo);
end

function BaseMap:RunToElem(mapElem)
	local onComplete = function()
		self:OnArriveAt( mapElem );
	end
	local x, y = mapElem:GetPos();
	MapController:MoveToMap( self.mapType, x, y, onComplete );
end


--鼠标移到icon上
function BaseMap:OnIconRollOver(e)
	local vo = e.target.data;
	local tipTxt = vo:GetTipsTxt();
	TipsManager:ShowBtnTips(tipTxt);
end

--鼠标移出icon
function BaseMap:OnIconRollOut()
	TipsManager:Hide();
end

--鼠标按住移出icon
function BaseMap:OnIconDragOut()
	TipsManager:Hide();
end

--到达某个icon的时候回调
function BaseMap:OnArriveAt( vo )
	local elemType = vo:GetType();
	if elemType == MapConsts.Type_Npc then
		NpcController:ShowDialog( vo:GetId() );
	elseif elemType == MapConsts.Type_MonsterArea or elemType == MapConsts.Type_Monster or
		elemType == MapConsts.Type_Hang or elemType == MapConsts.Type_Special then
		AutoBattleController:OpenAutoBattle();
	else
		self:OnArriveAtIcon(vo); -- 非npc/怪物怪区/挂机点 的单位，在子类做特殊处理
	end
end

--到达某icon的时候回调
function BaseMap:OnArriveAtIcon(vo)
	-- 子类实现
end

--在地图上添加图标
--@vo: MapElementVO 地图元素数据
function BaseMap:AddIcon(vo)
	local objSwf = self.objSwf;
	if not objSwf then
		return -1;
	end
	if not vo:IsAvailableInMap(self.mapName) then
		return -2;
	end
	local map = objSwf.map;
	local uid = vo:ToString();
	if self:GetIcon(uid) then self:RemoveIcon(uid) end;
	local x, y = vo:Get2DPos();
	local scale = self:GetScale();
	if not x or not y then return 0 end
	x, y = x * scale, y * scale;
	local label = vo:GetLabel()
	if map then 
		--@调用As里面的代码显示icon
		local icon = map:addIcon( uid, vo:GetAsLinkage(), x, y, vo:GetLayer(), vo:GetRotation(), label );
		if not icon then
			Error( string.format( "cannot add icon in map:%s, icon linkage:%s", self.mapName, vo:GetAsLinkage() ) );
			return -3;
		end
		if vo:IsInteractive() then
			icon.data     = vo;
			icon.click    = function(e) self:OnIconClick(e); end
			icon.rollOver = function(e) self:OnIconRollOver(e); end
			icon.rollOut  = function(e) self:OnIconRollOut(); end
			icon.dragOut  = function(e) self:OnIconDragOut(); end
		end
		self:SetIcon(uid, icon);
		self:OnIconAdd(vo);
	end
	return 0;
end

function BaseMap:OnIconAdd(vo)
	-- 子类实现
end

--移动图标
--@vo: MapElementVO 地图元素数据
function BaseMap:MoveIcon(vo)
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local uid = vo:ToString();
	if not self:GetIcon(uid) then return end;
	local x, y = vo:Get2DPos();
	local scale = self:GetScale();
	x, y = x * scale, y * scale;
	local map = objSwf.map;
	map:moveIcon( uid, x, y );
	map:rotateIcon( uid, vo:GetRotation() );
	self:OnIconMove(vo);
end

--@vo: MapElementVO 地图元素数据
function BaseMap:OnIconMove(vo)
	-- 子类实现
end

--更新图标
--@vo: MapElementVO 地图元素数据
function BaseMap:UpdateIcon(vo)
	self:RemoveIcon( vo:ToString() );
	self:AddIcon( vo );
end

--删除图标
--@vo: MapElementVO 地图元素数据
function BaseMap:RemoveIcon(uid)
	local objSwf = self.objSwf;
	if not objSwf then return end
	local icon = self:GetIcon(uid);
	if not icon then return end
	objSwf.map:removeIcon(uid);
	icon.data     = nil;
	icon.click    = nil;
	icon.rollOver = nil;
	icon.rollOut  = nil;
	icon.dragOut  = nil;
	self:SetIcon(uid, nil);
end

--清除地图上所有东西，换线时使用
function BaseMap:ClearAllIcon()
	for uid, _ in pairs( self.iconList ) do
		self:RemoveIcon(uid);
	end
end

-------------------------消息处理------------------------

function BaseMap:ListMapNotiInterests()
	return {
		NotifyConsts.MapChange,
		NotifyConsts.MapElementAdd,
		NotifyConsts.MapElementRemove,
		NotifyConsts.MapElementMove,
		NotifyConsts.MapElementUpdate,
		NotifyConsts.MapElementClear
	}
end

--监听的消息
function BaseMap:ListNotificationInterests()
	local notifications = {};
	local mapNotifications = self:ListMapNotiInterests();
	local otherNotifications = self:ListOtherNotiInterests();
	table.pushs( notifications, mapNotifications, otherNotifications );
	return notifications;
end

--处理消息
function BaseMap:HandleNotification(name, body)
	self:HandleMapNotification(name, body);
	self:HandleOtherNotification(name, body);
end

function BaseMap:HandleMapNotification( name, body )
	-- 是地图消息
	if type(body) ~= "table" then return end;
	local mapType = body and body.mapType;
	if mapType ~= self.mapType then return end
	-- 处理地图消息
	if name == NotifyConsts.MapChange then
		self:OnMapChange( body.mapId );
	elseif name == NotifyConsts.MapElementAdd then
		self:OnElementAddNotice( body.elem )
	elseif name == NotifyConsts.MapElementRemove then
		self:OnElementRemoveNotice( body.elem )
	elseif name == NotifyConsts.MapElementMove then
		self:MoveIcon( body.elem );
	elseif name == NotifyConsts.MapElementUpdate then
		self:UpdateIcon( body.elem );
	elseif name == NotifyConsts.MapElementClear then
		self:ClearAllIcon();
	end
end

function BaseMap:OnElementAddNotice( elem )
	self:AddIcon( elem );
	self:OnElementAdd( elem )
end

function BaseMap:OnElementRemoveNotice( elem )
	self:RemoveIcon( elem:ToString() );
	self:OnElementRemove( elem )
end

function BaseMap:OnElementAdd( elem )
	-- 子类实现
end

function BaseMap:OnElementRemove( elemUID )
	-- 子类实现
end


---------------------------以下为与地图无关，或次要地图信息的处理-----------------------------


function BaseMap:Init(objSwf)
	-- 子类实现
end

function BaseMap:RegisterOtherEvents(objSwf)
	-- 子类实现
end

-- 显示地图次要信息
function BaseMap:UpdateOther()
	-- 子类实现
end

-- listen other notifications which has nothing to do with map
function BaseMap:ListOtherNotiInterests()
	return {};
end

-- handle other notifications which has nothing to do with map
function BaseMap:HandleOtherNotification( name, body )
	-- 子类实现
end
