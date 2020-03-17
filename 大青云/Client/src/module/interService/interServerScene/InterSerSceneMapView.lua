--[[
跨服战场，地图
wangshuai
]]

_G.UIInterSSceneMap = BaseUI:new("UIInterSSceneMap");

UIInterSSceneMap.MapId = 0;

UIInterSSceneMap.scale = 1.3;
UIInterSSceneMap.pointdian = 0;

UIInterSSceneMap.iconlist = {};


function UIInterSSceneMap:Create()
	self:AddSWF("interSerSceneMap.swf",true,nil) -- ZhanchangMapPanel.swf
	-- self:AddSWF("ZhanchangMapPanel.swf",true,nil) -- ZhanchangMapPanel.swf
	--
end;

function UIInterSSceneMap:OnLoaded(objSwf)
	objSwf.closebtn.click = function() self:Hide() end;
end;

function UIInterSSceneMap:OnDelete()
	for i,info in pairs(self.iconlist) do 
		info = nil;
	end;
end;

function  UIInterSSceneMap:OnHide()
	for i,info in pairs(self.iconlist) do 
		UIInterSSceneMap:RemoveIcon(uid)
	end;
end;	

function UIInterSSceneMap:OnShow()
	self.MapId = CPlayerMap:GetCurMapID();
	-- self:AddUpFlagPoint();
	-- self:SetFalg();
	self:UpdataBorn();
	self:UpdataBossPoint()
	self:UpdataMonsterSmallPoint();
	self:UpdataMonsterBigPoint();
	self:AddPalyer();
end;
                                   
--出生点
function UIInterSSceneMap:UpdataBorn()
	local objSwf = self.objSwf
	if not objSwf then return end;
	for i,info in pairs(InterSSceneCamp) do 
		local x,y = MapUtils:Point3Dto2D(info.bornPoint.x,info.bornPoint.y,self.MapId);
		local str = "";
		local camp = 1;
		if info.camp == camp then 
			str = "my"
		else
			str = "be"
		end;
		local icon = objSwf.map:addIcon(info.bornPoint.type ..i,info.bornPoint.type,x/self.scale,y/self.scale,"top",0);
		icon.data = info.bornPoint
		icon.click = function(e) self:OnIconClick(e) end;
		icon.rollOver = function(e) self:OnIconBornRollOver(e); end
		icon.rollOut  = function() TipsManager:Hide();end
		table.push(self.iconlist,"born"..i)


		local x,y = MapUtils:Point3Dto2D(info.shouWei.x,info.shouWei.y,self.MapId);
		local icon = objSwf.map:addIcon(info.shouWei.type ..i,info.shouWei.type ..str,x/self.scale,y/self.scale,"top",0);
		icon.data = info.shouWei
		icon.click = function(e) self:OnIconClick(e) end;
		icon.rollOver = function(e) self:OnIconBornRollOver(e); end
		icon.rollOut  = function() TipsManager:Hide();end
		table.push(self.iconlist,"born"..i)

	end;
end;

--复活点tips
function UIInterSSceneMap:OnIconBornRollOver(e)
	local data = e.target.data
	TipsManager:ShowBtnTips(data.tips);
end;

--boss 点
function UIInterSSceneMap:UpdataBossPoint()
	local objSwf = self.objSwf
	if not objSwf then return end;
	for i,info in pairs(InterSSMonsterPoint) do 
		local x,y = MapUtils:Point3Dto2D(info.x,info.y,self.MapId);

		local icon = objSwf.map:addIcon(info.type ..i,info.type,x/self.scale,y/self.scale,"top",0);
		icon.data = info
		icon.click = function(e) self:OnIconClick(e) end;
		icon.rollOver = function(e) self:OnIconBornRollOver(e); end
		icon.rollOut  = function() TipsManager:Hide();end
		table.push(self.iconlist,info.type ..i)


	end;
end;


--怪物小
function UIInterSSceneMap:UpdataMonsterSmallPoint()
	local objSwf = self.objSwf
	if not objSwf then return end;
	for i,info in pairs(InterSSSmallMonsterPoint) do 
		local x,y = MapUtils:Point3Dto2D(info.x,info.y,self.MapId);

		local icon = objSwf.map:addIcon(info.type ..i,info.type,x/self.scale,y/self.scale,"top",0);
		icon.data = info
		icon.click = function(e) self:OnIconClick(e) end;
		icon.rollOver = function(e) self:OnIconBornRollOver(e); end
		icon.rollOut  = function() TipsManager:Hide();end
		table.push(self.iconlist,info.type ..i)
	end;
end;


--怪物大
function UIInterSSceneMap:UpdataMonsterBigPoint()
	local objSwf = self.objSwf
	if not objSwf then return end;
	for i,info in pairs(InterSSBigMonsterPoint) do 
		local x,y = MapUtils:Point3Dto2D(info.x,info.y,self.MapId);

		local icon = objSwf.map:addIcon(info.type ..i,info.type,x/self.scale,y/self.scale,"top",0);
		icon.data = info
		icon.click = function(e) self:OnIconClick(e) end;
		icon.rollOver = function(e) self:OnIconBornRollOver(e); end
		icon.rollOut  = function() TipsManager:Hide();end
		table.push(self.iconlist,info.type ..i)
	end;
end;





























-- 交付点
function UIInterSSceneMap:AddUpFlagPoint()
	local objSwf =self.objSwf;
	local mycamp = 6
	local cfgxy = ZhChFlagUpPoint[mycamp];
	local x,y = MapUtils:Point3Dto2D(cfgxy.x,cfgxy.y,self.MapId)
	local icon = objSwf.map:addIcon("myflagup","portal_fairyland",x/self.scale,y/self.scale,"top",0)

	myUpPoint.data = ZhChFlagUpPoint[mycamp]
	myUpPoint.click = function(e) self:OnIconClick(e) end;
	myUpPoint.rollOver = function() self:OnIconRollOver(); end
	myUpPoint.rollOut  = function() TipsManager:Hide();end
end;
-- 交付点click
function UIInterSSceneMap:OnIconClick(e)
	local data = e.target.data
	if not data then return end;
	local VXY =  _Vector3.new( data.x, data.y, 0 );
	MainPlayerController:DoAutoRun(CPlayerMap:GetCurMapID(),VXY,function() end);
end;
--- ober 交付点
function UIInterSSceneMap:OnIconRollOver()
	TipsManager:ShowBtnTips(StrConfig["zhanchang112"]);
end;

-- 旗子点
function UIInterSSceneMap:SetFalg()
	local objSwf  = self.objSwf;
	for f,a in pairs(self.iconlist) do
			objSwf.map:removeIcon(a);
	end;
	local scfg = ActivityZhanChang.zcFlagList;
	for i,info in pairs(scfg) do 
		local cvo = ZhChFlagConfig[info.idx]
		local x,y = MapUtils:Point3Dto2D(cvo.x,cvo.y,self.MapId)
		if info.canPick == 1 then 
			local falgicon = objSwf.map:addIcon("flag"..i,"player_ZhanchangFalg"..info.camp,x/self.scale,y/self.scale,"top",0)
			table.push(self.iconlist,"flag"..i)
			falgicon.data = cvo;
			falgicon.click = function(e) self:FlagIconCLick(e) end;
			falgicon.rollOver = function(e) self:FlagrollOver(e) end;
			falgicon.rollOut = function(e) TipsManager:Hide() end;
		end
	end;
end;

function UIInterSSceneMap:FlagrollOver(e)
	local data = e.target.data 
	if not data then return end;
	local mycamp = ActivityZhanChang:GetMyCamp()
	if data.camp ~= mycamp then 
		TipsManager:ShowBtnTips(StrConfig["zhanchang115"]);
	else
		TipsManager:ShowBtnTips(StrConfig["zhanchang114"]);
	end;
end;

function UIInterSSceneMap:FlagIconCLick(e)
	local data = e.target.data;
	if not data then return end;
	local VXY = _Vector3.new( data.x, data.y, 0 );
	--self:FlagAutoGet(data);
	MainPlayerController:DoAutoRun(CPlayerMap:GetCurMapID(),VXY,function() self:FlagAutoGet(data) end);
end;
-- 自动采集`
function UIInterSSceneMap:FlagAutoGet(node)
	--ZhChFlagController:OnMouseClick(node)
	ZhChFlagController:DoCollect(node)
end;

-- 玩家点
function UIInterSSceneMap:AddPalyer()
	local player = MainPlayerController:GetPlayer()
	local palyerxy = player:GetPos() 
	local x,y = MapUtils:Point3Dto2D(palyerxy.x,palyerxy.y,self.MapId)
	local objSwf =self.objSwf;
	objSwf.map:addIcon("player","player",x/self.scale,y/self.scale,"top",0)
end;

function UIInterSSceneMap:SetMyXy()
	local objSwf =  self.objSwf;
	--MainPlayerController:GetPlayer():GetPos().y
	local rotation = MapUtils:DirtoRotation(MainPlayerController:GetPlayer():GetDirValue(),self.MapId)
	objSwf.map:rotateIcon("player",rotation)
	local player = MainPlayerController:GetPlayer()
	local palyerxy = player:GetPos() 

	local x,y = MapUtils:Point3Dto2D(palyerxy.x,palyerxy.y,self.MapId)
	objSwf.map:moveIcon("player", x/self.scale, y/self.scale)
end;

function UIInterSSceneMap:Update()
	if not self.bShowState then return; end
	local objSwf = self.objSwf;
	if not objSwf then return end;
	UIInterSSceneMap:SetMyXy()
end;


------------------------消息处理------------------------

-- --监听的消息
-- function UIInterSSceneMap:ListNotificationInterests()
-- 	return {
-- 		NotifyConsts.MapInvalidate,
-- 		NotifyConsts.MapElementAdd,
-- 		NotifyConsts.MapElementRemove,
-- 		NotifyConsts.MapElementMove,
-- 		NotifyConsts.MapIconUpdate,
-- 		NotifyConsts.MapElementClear
-- 	};
-- end

-- --处理消息
-- function UIInterSSceneMap:HandleNotification(name,body)
-- 	if name == NotifyConsts.MapInvalidate then
-- 		--self:InvalidateData();
-- 	elseif name == NotifyConsts.MapElementAdd then
-- 		local mapElementVO = MapModel:GetElement(body);
-- 		self:AddIcon(mapElementVO);
-- 	elseif name == NotifyConsts.MapElementRemove then
-- 		self:RemoveIcon( body );
-- 	elseif name == NotifyConsts.MapElementMove then
-- 		local mapElementVO = MapModel:GetElement(body)
-- 		self:MoveIcon( mapElementVO );
-- 	elseif name == NotifyConsts.MapIconUpdate then
-- 		local mapElementVO = MapModel:GetElement(body)
-- 		--self:UpdateIcon( mapElementVO );
-- 	elseif name == NotifyConsts.MapElementClear then
-- 		--self:ClearAllIcon();
-- 	end
-- end
--- 添加一个图标
function UIInterSSceneMap:AddIcon(mapElementVO)
	local objSwf = self.objSwf;
	if not objSwf then return; end;
	local map = objSwf.map;
	-- 小地图的野怪不需要在这显示
	local type = mapElementVO.type;
	-- smart
	
	 if type == MapConsts.Type.pathPoint then 
	 	self.pointdian = self.pointdian + 1;
		if self.pointdian % 2 == 0 then 
			if self.pointdian > 10 then self.pointdian = 0 end;
			return; 
		end;
	 end

	if type == MapConsts.Type.monsterSmallMap then return; end
	local uid = mapElementVO.uid;
	--同一个uid只存在一个图标
	if self.iconlist[uid] then self:RemoveIcon(uid); end
	
	local iconName = mapElementVO.iconName;
	local x, y = MapUtils:Point3Dto2D(mapElementVO.x, mapElementVO.y);


	local icon;
	if type == MapConsts.Type.mainPlayer then
		local dir = MapUtils:DirtoRotation( mapElementVO.dir );
		icon = map:addIcon( uid, iconName, x/self.scale, y/self.scale, "top", dir );
	else
		icon = map:addIcon( uid, iconName, x/self.scale, y/self.scale, "bottom", 0 );
	end
	if not icon then return; end
	self.iconlist[uid] = icon;
	
	if type ~= MapConsts.Type.pathPoint then
		icon.data = mapElementVO;
		icon.click    = function(e) self:OnIconClick(e); end
		icon.rollOver = function(e) self:OnIconRollOver(e); end
		icon.rollOut  = function(e) self:OnIconRollOut(); end
		icon.dragOut  = function(e) self:OnIconDragOut(); end
	end
end
--删除图标
function UIInterSSceneMap:RemoveIcon(uid)
	local objSwf = self.objSwf;
	if not objSwf then return; end;
	local map = objSwf.map;
	if not self.iconlist[uid] then return; end;

	map:removeIcon(uid);
	local icon = self.iconlist[uid];
	icon.click    = nil;
	icon.rollOver = nil;
	icon.rollOut  = nil;
	icon.dragOut  = nil;
	self.iconlist[uid] = nil;
end

--移动图标
function UIInterSSceneMap:MoveIcon(mapElementVO)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local map = objSwf.map;
	if not self.bShowState then return; end
	local uid = mapElementVO.uid
	if not self.iconlist[uid] then return; end

	local x, y = MapUtils:Point3Dto2D( mapElementVO.x, mapElementVO.y );
	map:moveIcon( uid, x/self.scale, y/self.scale );
	--如果是自己，更新坐标显示
	if mapElementVO.iconName == MapConsts.IconName.player then
		-- x, y = mapElementVO.x, mapElementVO.y --debugOnly;
		objSwf.txtPos.text = string.format( StrConfig['map103'], math.floor(x), math.floor(y) );
	end
	if mapElementVO.dir then
		local rotation = MapUtils:DirtoRotation( mapElementVO.dir )
		map:rotateIcon( uid, rotation );
	end
end





