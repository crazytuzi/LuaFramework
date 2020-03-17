--[[
	大地图:查看地图(点击世界地图中某地域后打开)
	haohu
	2014年9月12日15:29:15
]]

_G.UIBigMapLocal = BaseMap:new("UIBigMapLocal", MapConsts.Type_Local, MapConsts.MapName_Local);

UIBigMapLocal.npcList     = {}; -- npc(元素类型：MapElementVO)
UIBigMapLocal.monsterList = {}; -- 怪物(元素类型：MapElementVO)
UIBigMapLocal.portalList  = {}; -- 传送点(元素类型：MapElementVO)

function UIBigMapLocal:Create()
	self:AddSWF("bigMapLocal.swf", true, nil);
end

function UIBigMapLocal:ShowMapName()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local model = self:GetModel();
	local mapId = model:GetMapId()
	local url = ResUtil:GetMapNamePicURL( mapId );
	local loader = objSwf.nameLoader;
	if loader.source ~= url then
		loader.source = url;
	end
end

--鼠标在地图上移动
function UIBigMapLocal:OnMapMouseMove()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local posx, posy = objSwf.map._xmouse, objSwf.map._ymouse;
	TipsManager:ShowBtnTips(  string.format( "%s,%s", math.floor(posx), math.floor(posy) )  );
end

--鼠标移出地图
function UIBigMapLocal:OnMapRollOut()
	TipsManager:Hide();
end

---------------------------以下为与地图无关，或次要地图信息的处理-----------------------------

function UIBigMapLocal:Init(objSwf)
	
end

-- 显示地图次要信息
function UIBigMapLocal:UpdateOther()
	self:ListPopulate();
end

function UIBigMapLocal:RegisterOtherEvents(objSwf)
	objSwf.btnReturn.click      = function() self:OnBtnReturnClick(); end
	objSwf.nameLoader.loaded    = function(e) self:OnNameImgLoaded(e) end
	self:RegisterListEvents( objSwf.listNpc );
	self:RegisterListEvents( objSwf.listMonster );
	self:RegisterListEvents( objSwf.listPortal );
end

function UIBigMapLocal:RegisterListEvents(uiList)
	uiList.itemDoubleClick = function(e) self:OnListDoubleClick(e); end
	uiList.itemRollOver    = function(e) self:OnListItemRollOver(e); end
	uiList.itemRollOut     = function(e) self:OnListItemRollOut(); end
end

function UIBigMapLocal:OnBtnReturnClick()
	self.parent:ShowWorldMap();
end

function UIBigMapLocal:OnNameImgLoaded(e)
	-- local pic = e.target.content;
	-- pic._x = -1 * pic._width;
end

function UIBigMapLocal:OnListItemRollOver(e)
	local data = e.item;
	if not data then return end;
	TipsManager:ShowBtnTips( StrConfig['map119'] );
end

function UIBigMapLocal:OnListItemRollOut()
	TipsManager:Hide();
end

--点击NPC列表
function UIBigMapLocal:OnListDoubleClick(e)
	local vo = e.item;
	if not vo then return end;
	local elemUid = vo.uid;
	local mapModel = self:GetModel();
	local mapElem = mapModel:GetElement( elemUid );
	if not mapElem then return end;
	self:RunToElem( mapElem );
end

-- 填入右侧传送点列表
function UIBigMapLocal:ListPopulate()
	local model = self:GetModel();
	local mapElements = model:GetElements();
	self.npcList     = {};
	self.monsterList = {};
	self.portalList  = {};
	for uid, vo in pairs( mapElements ) do
		self:DivideElement(vo);
	end
	self:FillNpcList();
	self:FillMonsterList();
	self:FillPortalList();
end

--根据类型的不同，存入不同的table(npc,monster,portal)
--@vo: MapElementVO 地图元素数据
function UIBigMapLocal:DivideElement(vo)
	local elemType = vo:GetType();
	if elemType == MapConsts.Type_Npc then
		table.push( self.npcList, vo );
	elseif elemType ==  MapConsts.Type_MonsterArea then
		table.push( self.monsterList, vo );
	elseif elemType ==  MapConsts.Type_Portal then
		table.push( self.portalList, vo );
	end
end

function UIBigMapLocal:FillNpcList()
	local objSwf = self.objSwf
	if not objSwf then return end;
	self:FillList( objSwf.listNpc, self.npcList );
end

function UIBigMapLocal:FillMonsterList()
	local objSwf = self.objSwf
	if not objSwf then return end;
	table.sort( self.monsterList, function(A, B)
		return A:GetLvlInfo() > B:GetLvlInfo();
	end );
	self:FillList( objSwf.listMonster, self.monsterList );
end

function UIBigMapLocal:FillPortalList()
	local objSwf = self.objSwf
	if not objSwf then return end;
	self:FillList( objSwf.listPortal, self.portalList );
end

--list的实例化
function UIBigMapLocal:FillList( uiList, dataList )
	uiList.dataProvider:cleanUp();
	for _, elem in ipairs( dataList ) do
		uiList.dataProvider:push( elem:GetUIData() );
	end
	uiList:invalidateData();
	uiList:scrollToIndex(0);
end