--[[
	大地图:当前地图
	haohu
	2014年8月18日11:18:46
]]

_G.UIBigMapCurr = BaseMap:new( "UIBigMapCurr", MapConsts.Type_Curr, MapConsts.MapName_Curr );

UIBigMapCurr.npcList     = {}; -- npc(元素类型：MapElementVO)
UIBigMapCurr.monsterList = {}; -- 怪物(元素类型：MapElementVO)
UIBigMapCurr.portalList  = {}; -- 传送点(元素类型：MapElementVO)
UIBigMapCurr.otherPlayerlList  = {}; -- 其他玩家(元素类型：MapElementVO)   --adder: houxudong date:2016/7/12

function UIBigMapCurr:Create()
	self:AddSWF("bigMapCurr.swf", true, nil);
end

function UIBigMapCurr:ShowMapName()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local model = self:GetModel();
	local mapId = model:GetMapId()
	local url = ResUtil:GetMapNamePicURL( mapId );
	local loader = objSwf.nameLoader;
	if loader.source ~= url then
		loader.source = url;
	end
	loader.visible = true
	--- 当前地图名字屏蔽  @liaoying
end

--鼠标在地图上移动
function UIBigMapCurr:OnMapMouseMove()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local map = objSwf.map;
	local posx = math.floor( map._xmouse );
	local posy = math.floor( map._ymouse );
	if isDebug then  --debug only
		local x3d, y3d = MapUtils:Point2Dto3D(posx, posy)
		TipsManager:ShowBtnTips( string.format("2d:%s,%s\n3d:%s,%s", posx, posy, math.floor(x3d), math.floor(y3d) ) );
	else
		TipsManager:ShowBtnTips( string.format("%s,%s", posx, posy ) );
	end
end

---------------------------以下为与地图无关，或次要地图信息的处理-----------------------------

function UIBigMapCurr:Init(objSwf)
	objSwf.inputX.restrict = "0-9\\-\\";
	objSwf.inputY.restrict = "0-9\\-\\";
end

-- 显示地图次要信息
function UIBigMapCurr:UpdateOther()
	if self.objSwf then
		self.objSwf.btnReturn.visible = true
		-- 连接大地图按钮屏蔽 @liaoying
	end
	self:ListPopulate(); 
end

function UIBigMapCurr:RegisterOtherEvents(objSwf)
	objSwf.btnGo.click       = function(e) self:OnBtnGoClick(e); end
	objSwf.btnReturn.click   = function() self:OnBtnReturnClick(); end
	objSwf.nameLoader.loaded = function(e) self:OnNameImgLoaded(e); end
	self:RegisterListEvents( objSwf.listNpc );
	self:RegisterListEvents( objSwf.listMonster );
	self:RegisterListEvents( objSwf.listPortal );
end

function UIBigMapCurr:RegisterListEvents(uiList)
	uiList.itemDoubleClick = function(e) self:OnListDoubleClick(e); end
	uiList.itemRollOver    = function(e) self:OnListItemRollOver(e); end
	uiList.itemRollOut     = function(e) self:OnListItemRollOut(); end
end

--点击前往按钮(输入x,y右面的按钮)
function UIBigMapCurr:OnBtnGoClick(e)
	local objSwf = self.objSwf;
	if not objSwf then return end
	local mc = e.target;
	local x = tonumber(objSwf.inputX.text);
	local y = tonumber(objSwf.inputY.text);
	if not x or not y then
		FloatManager:AddNormal( StrConfig['map121'], mc );
		return;
	end
	if x < 0 or MapConsts.UIBigMapW < x or y < 0 or MapConsts.UIBigMapH < y then
		FloatManager:AddNormal( StrConfig['map108'], mc );
		return;
	end
	local onFailed = function()
		FloatManager:AddNormal( StrConfig['map109'], mc );
	end
	local model = self:GetModel();
	local mapId = model:GetMapId();
	local x, y = MapUtils:Point2Dto3D( x, y, mapId ); -- 换算为3d坐标
	MapController:MoveToMap( self.mapType, x, y, nil, onFailed );
end

function UIBigMapCurr:OnBtnReturnClick()
	self.parent:ShowWorldMap();
end

function UIBigMapCurr:OnNameImgLoaded(e)
	-- local pic = e.target.content;
	-- pic._x = -1 * pic._width;
end

--@vo: MapElementVO 地图元素数据
function UIBigMapCurr:OnIconMove(vo)
	if vo:GetType() == MapConsts.Type_MainPlayer then
		self:ShowMyPos(vo);
	end
end

--@vo: MapElementVO 地图元素数据
function UIBigMapCurr:OnIconAdd(vo)
	if vo:GetType() == MapConsts.Type_MainPlayer then
		self:ShowMyPos(vo);
	elseif vo:GetType() == MapConsts.Type_Player then
		-- 绘制其他玩家
	end
end

--@vo: MapElementVO 主玩家地图元素
function UIBigMapCurr:ShowMyPos(vo)
	local objSwf = self.objSwf;
	if not objSwf then return end
	local x, y = vo:Get2DPos();
	objSwf.txtMyPos.text = string.format( StrConfig['map103'], x, y );
end

function UIBigMapCurr:OnListItemRollOver(e)
	local data = e.item;
	if not data then return end;
	TipsManager:ShowBtnTips( StrConfig['map119'] );
end

function UIBigMapCurr:OnListItemRollOut()
	TipsManager:Hide();
end

--点击NPC列表
function UIBigMapCurr:OnListDoubleClick(e)
	local vo = e.item;
	if not vo then return end;
	local elemUid = vo.uid;
	local mapModel = self:GetModel();
	local mapElem = mapModel:GetElement( elemUid );
	if not mapElem then return end;
	self:RunToElem( mapElem );
end

-- 填入右侧传送点列表
function UIBigMapCurr:ListPopulate()
	local model = self:GetModel();
	local mapElements = model:GetElements();
	self.npcList     = {};
	self.monsterList = {};
	self.portalList  = {};
	self.otherPlayerlList = {};
	-- trace(mapElements)
	for uid, vo in pairs( mapElements ) do
		self:DivideElement(vo);
	end
	self:FillNpcList();
	self:FillMonsterList();
	self:FillPortalList();
end

--根据类型的不同，存入不同的table(npc,monster,portal)
--@vo: MapElementVO 地图元素数据
--@reason：初始化地图存在的几种元素数据,包括NPC，monster，portal, player
function UIBigMapCurr:DivideElement(vo)
	local elemType = vo:GetType();
	if elemType == MapConsts.Type_Npc then
		table.push( self.npcList, vo );
	elseif elemType ==  MapConsts.Type_MonsterArea then
		table.push( self.monsterList, vo );
	elseif elemType ==  MapConsts.Type_Portal then
		table.push( self.portalList, vo );
	elseif elemType == MapConsts.Type_Player then
		table.push( self.otherPlayerlList, vo );
	end
end

function UIBigMapCurr:FillNpcList()
	local objSwf = self.objSwf
	if not objSwf then return end;
	self:FillList( objSwf.listNpc, self.npcList );
end

function UIBigMapCurr:FillMonsterList()
	local objSwf = self.objSwf
	if not objSwf then return end;
	table.sort( self.monsterList, function(A, B)
		return A:GetLvlInfo() > B:GetLvlInfo();
	end );
	self:FillList( objSwf.listMonster, self.monsterList );
end

function UIBigMapCurr:FillPortalList()
	local objSwf = self.objSwf
	if not objSwf then return end;
	self:FillList( objSwf.listPortal, self.portalList );
end

function UIBigMapCurr:FillList( uiList, dataList )
	uiList.dataProvider:cleanUp();
	for _, elem in ipairs( dataList ) do
		uiList.dataProvider:push( elem:GetUIData() );
	end
	uiList:invalidateData();
	uiList:scrollToIndex(0);
end

function UIBigMapCurr:OnElementAdd( elem )
	local elementType = elem:GetType()
	if self:CheckNeedPopulateList( elementType ) then
		self:ListPopulate()
	end
end

function UIBigMapCurr:OnElementRemove( elem )
	local elementType = elem:GetType()
	if self:CheckNeedPopulateList( elementType ) then
		self:ListPopulate()
	end
end

local dic
function UIBigMapCurr:CheckNeedPopulateList(elemType)
	if not dic then
		dic = {
			[MapConsts.Type_Npc]         = true,
			[MapConsts.Type_MonsterArea] = true,
			[MapConsts.Type_Portal]      = true
		}
	end
	return dic[elemType] == true
end