_G.TianshenAvatar = {};
setmetatable(TianshenAvatar,{__index = CPlayerAvatar});

function TianshenAvatar:new()
	local avatar = CPlayerAvatar:new();
	avatar.followdis = 30;
	avatar.followangel = 0;
    setmetatable(avatar, {__index = TianshenAvatar})
    return avatar;
end

function TianshenAvatar:UpdateAvatar(modelId)
	if self.modelId == modelId then
		return;
	end
	
	local cfg = t_bianshenmodel[modelId];	
	local skl = cfg.skl;
	local skn = cfg.skn;
	local defAnima = cfg.follow_idle;
	local moveAnima = cfg.walk_idle;
	
	local params = split(cfg.followparams,",");
	self.followdis = table.remove(params,1);
	self.followdis = self.followdis and tonumber(self.followdis) or 30;
	self.followangel = table.remove(params,1);
	self.followangel = self.followangel and tonumber(self.followangel) or 0;
	self.followangel = self.followangel*math.pi/180;
	
	self:SetPart("Body", skn);
	self:ChangeSkl(skl);
	self.modelScale = cfg.model_scale == 0 and 1 or cfg.model_scale;
	if cfg.model_scale ~= 0 then
		local mat = _Matrix3D.new();
		local scale = cfg.model_scale;
		mat:setScaling(scale, scale, scale);
		self:GetSkl():adjustRoot(mat);
	end
			
	self:SetIdleAction(defAnima, true);
	self:SetMoveAction(moveAnima, false);
	self.pickFlag = enPickFlag.EPF_Null;
	self.modelId = modelId;
end

function TianshenAvatar:UpdatePos(dwInterval)
	self:DrawNameBoard()
end

local pos3d = _Vector3.new()
local ret2d = _Vector2.new()
function TianshenAvatar:GetNamePos()
	local mePos = self:GetPos()
	if not mePos then
		return
	end

	-- local mePos = player:GetPos()
	-- local posX,posY,posZ = mePos.x, mePos.y, mePos.z
	-- local horseId = player:GetHorseID()
	-- local prof = player.playerInfo[enAttrType.eaProf]

	-- pos3d.x = posX
	-- pos3d.y = posY
	-- if horseId > 0 then
		-- pos3d.z = posZ + PlayerHeadBoard:GetNameHeight(horseId, prof) * scale
	-- else
		-- pos3d.z = posZ + CUICardConfig["nameHeight"][prof] * scale
	-- end

	-- 3D映射到屏幕坐标
	-- _rd:projectPoint(pos3d.x, pos3d.y, pos3d.z, ret2d)
	-- player = nil
	-- return ret2d
end

local namePos = _Vector3.new();
local name2d = _Vector2.new();
local playerFont = _Font.new("SIMHEI", 11, 0, 1, true);
local selfFont = _Font.new("SIMHEI", 11, 0, 1, true);

function TianshenAvatar:DrawNameBoard()
	if not self.objNode then
		return
	end
	if not self.objNode.visible then
		return
	end
	if not self.objMesh then
		return
	end
	
	local player = self:GetOwner()
	if not player then
		return
	end

	if not player:IsShowName() then
		return
	end
	
	local mePos = self:GetPos();
	if not mePos then
		return
	end
	
	if RenderConfig.batch == true then _rd.batchId = 1 end;
	
	namePos.x = mePos.x;
	namePos.y = mePos.y;
	namePos.z = mePos.z;
	namePos.z = mePos.z + self.nameHeight * self.modelScale;
	
	_rd:projectPoint(namePos.x, namePos.y, namePos.z, name2d);
	self.headBoardX = round(name2d.x);
	self.headBoardY = round(name2d.y);
	
	if not self.playerNameWidth then
		self.playerNameWidth = playerFont:stringWidth(self.playerName);
	end
	local nameX = self.headBoardX - round((self.playerNameWidth)/2);
    local nameY = self.headBoardY;
	playerFont.textColor = 0xFFFFC090;
	playerFont.edgeColor = 0xFF000000;
	playerFont:drawText(nameX, nameY, nameX, nameY, self.playerName, _Font.hLeft + _Font.vCenter);
	
	-- local star = self.selfStar;
	-- if star~= 0 then
	-- 	if not self.selfTitleImg then
	-- 		self.selfTitleImg = CResStation:GetImage(ResUtil:GetTianshenTitle(star));
	-- 	end
	-- 	self.selfTitleImg:drawImage(nameX - round(self.selfTitleImg.w), nameY - self.selfTitleImg.h, nameX, nameY);
	-- 	self.selfStars = self.selfStars or {};
	-- 	for i=1,10 do
	-- 		local img = self.selfStars[i];
	-- 		if not img then
	-- 			img = _Image.new(ResUtil:GetBigStar());
	-- 			local light = star>=i;
	-- 			if not light then
	-- 				img:processHSL(0,0,10);
	-- 			end
	-- 			self.selfStars[i] = img;
	-- 		end
	-- 		nameX = self.headBoardX - round((img.w+2)*2.5);
	-- 		img:drawImage(nameX + round((img.w+2)*(i-1)), nameY - img.h - 14, nameX + round((img.w+2)*i), nameY - 14);
	-- 	end
	-- 	nameY = nameY - round((self.selfTitleImg.h)/2);
	-- end
	
	nameY = nameY - 30;
	if not self.selfNameWidth then
		self.selfNameWidth = selfFont:stringWidth(self.selfName);
	end
	if not self.selfNameImg then
		self.selfNameImg = _Image.new(self.imgName);
	end
	nameX = self.headBoardX - round((self.selfNameWidth + self.selfNameImg.w)/2);
	self.selfNameImg:drawImage(nameX, nameY - round(self.selfNameImg.h/2), nameX + round(self.selfNameImg.w), nameY + round(self.selfNameImg.h/2));
	selfFont.textColor = self.nameColor;
	selfFont.edgeColor = 0xFF000000;
	nameX = nameX + self.selfNameImg.w;
	selfFont:drawText(nameX, nameY, nameX, nameY, self.selfName, _Font.hLeft + _Font.vCenter);
	
	if RenderConfig.batch == true then _rd.batchId = 0 end
end

function TianshenAvatar:SetImgName(name)
	if self.imgName ~=name then
		self.imgName = name;
		self.selfNameImg = nil;
	end
end

local pos = _Vector2.new()
function TianshenAvatar:EnterMap(objSceneMap, fXPos, fYPos, fDirValue)
	pos.x = fXPos - self.followdis * math.sin(fDirValue + self.followangel);
	pos.y = fYPos + self.followdis * math.cos(fDirValue + self.followangel);
	self:EnterSceneMap(objSceneMap, pos, fDirValue);
end

function TianshenAvatar:OnEnterScene(objNode)
    objNode.dwType = enEntType.eEntType_TianShen;
end

function TianshenAvatar:GetFollowDis()
	return self.followdis;
end

function TianshenAvatar:GetFollowAngel()
	return self.followangel;
end

function TianshenAvatar:ExitMap()
	self:ExitSceneMap();
	self:Destroy();
	self.curPos = nil;
	self.modelId = nil;
	self.selfStars = nil;
end

function TianshenAvatar:GetOwner()
	local player = CPlayerMap:GetPlayer(self.ownerId)
	return player
end




