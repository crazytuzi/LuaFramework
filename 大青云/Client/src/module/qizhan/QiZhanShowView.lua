--[[
骑战展示

]]

_G.UIQiZhanShowView = BaseUI:new("UIQiZhanShowView");

UIQiZhanShowView.timerKey = nil;

UIQiZhanShowView.objUIDraw = nil;

function UIQiZhanShowView:Create()
	self:AddSWF("qizhanShowPanel.swf",true,"top");
end

function UIQiZhanShowView:OnResize(wWidth, wHeight)
	if not self.bShowState then return end
	self:UpdateMask()
end

function UIQiZhanShowView:OnLoaded(objSwf)
	objSwf.hitArea.click = function() self:OnHitAreaClick(); end
	objSwf.btnGet.click = function() self:OnHitAreaClick(); end
	--模型防止阻挡鼠标
	objSwf.loader.hitTestDisable = true;
end

function UIQiZhanShowView:UpdateMask()
	local objSwf = self.objSwf
	if not objSwf then return end
	local wWidth, wHeight = UIManager:GetWinSize()
	objSwf.mcMask._width = wWidth + 100
	objSwf.mcMask._height = wHeight + 100
end

function UIQiZhanShowView:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end

function UIQiZhanShowView:OnHide()
	FuncManager:OpenFunc(FuncConsts.QiZhan,true);

	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
	
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey);
	end
end

function UIQiZhanShowView:GetHeight()
	return 1000;
end

function UIQiZhanShowView:GetWidth()
	return 1600;
end

function UIQiZhanShowView:OnShow()
	_rd.camera:shake( 2, 2, 160 )
	self:Show3DWeapon();
	self:UpdateMask();
end

function UIQiZhanShowView:OpenPanel()
	if self:IsShow() then
		self:Show3DWeapon();
	else
		self:Show();
	end
end

local viewPort;
function UIQiZhanShowView:Show3DWeapon()
	local objSwf = self.objSwf;
	if not objSwf then return; end
		
	local level = QiZhanModel:GetLevel();
	local cfg = t_ridewar[level];
	if not cfg then
		Error("Cannot find config of QiZhan level:"..level);
		return;
	end
	objSwf.nameLoader.source = ResUtil:GetQiZhanIcon(cfg.name_icon);
	
	if not self.objUIDraw then
		if not viewPort then viewPort = _Vector2.new(1400, 800); end
		self.objUIDraw = UISceneDraw:new( "UIQiZhanShowView", objSwf.loader, viewPort );
	end
	self.objUIDraw:SetUILoader( objSwf.loader );
	
	self.objUIDraw:SetScene("qz_zhanshi.sen", function()
			local prof = MainPlayerModel.humanDetailInfo.eaProf
			local meshFileString = cfg["vmesh" .. prof]
			local meshFileTable = split(meshFileString, "#")
			local meshFile = meshFileTable[1]
			local nodeName = cfg["nodename"]
			local skn = self.objUIDraw:GetNodeMesh(nodeName)
			local skl = self.objUIDraw:GetNodeSkl(nodeName)
			if meshFile and skn then
				local skl = skn.skeleton
				local mesh = _Mesh.new(meshFile)
				local bone_name = "rwh_" .. profString[prof]
				mesh:attachSkeleton(skl, bone_name, mesh.graData:getMarker("rwh"))
				skn:addSubMesh(mesh)

				for i, v in next, mesh:getSubMeshs() do
					v.isPaint = true
				end
				mesh.isPaint = true
				mesh:enumMesh('', true, function(submesh, name)
					local i = submesh:getTexture(0)
					if i and i.resname ~= '' then
						local spemap = i.resname:gsub('.dds$', '_h.dds')
						if spemap 
							and spemap:find('dds')
							and spemap:find('_h')
							and _sys:fileExist(spemap, true) then
							submesh:setSpecularMap(_Image.new(spemap))
						end
																		
					end
				end)

				local pfxListString = cfg["pfxname" .. prof]
				if pfxListString and pfxListString ~= "" then
					local pfxList = GetPoundTable(pfxListString)
					local pfxName = nil
					local boneName = nil
					if #pfxList == 2 then
						pfxName = pfxList[2] .. ".pfx"
						boneName = bone_name
					elseif #pfxList == 1 then
						pfxName = pfxList[1] .. ".pfx"
						boneName = bone_name
					end
					if pfxName and boneName then
						local pfx = skl.pfxPlayer:play(pfxName, pfxName)
				        local BindMat  = skl:getBone(boneName)
				        if BindMat then
				            pfx.transform = BindMat
				        end
				    end
			    end
			end

		end);
	self.objUIDraw:SetDraw( true );
	
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey);
	end
	self.timerKey = TimerManager:RegisterTimer(function()
		self:Hide();
		
	end,5000,1);
end

function UIQiZhanShowView:OnHitAreaClick()
	self:Hide();
end

function UIQiZhanShowView:Update()
	if not self.bShowState then return end
	
end