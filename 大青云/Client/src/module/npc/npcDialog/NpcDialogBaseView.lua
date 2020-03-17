--[[
Npc对话界面 基类
haohu
2015年8月2日00:18:12
]]

_G.UINpcDialogBase = BaseUI:new("UINpcDialogBase")

UINpcDialogBase.objAvatar = nil;--人物模型
UINpcDialogBase.npc       = nil  -- NPC对象
UINpcDialogBase.questList = nil  -- 任务列表

function UINpcDialogBase:new(name)
	local obj = BaseUI:new(name)
	for k, v in pairs(self) do
		if type(v) == "function" then
			obj[k] = v
		end
	end
	return obj
end

function UINpcDialogBase:Create()
	self:AddSWF("npcDialogBox.swf",true,"center");
end

function UINpcDialogBase:OnLoaded(objSwf,name)
	objSwf.npcLoader.hitTestDisable = true;
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end
	objSwf.optionList.itemClick = function(e) self:OnItemClick(e); end
end

function UINpcDialogBase:IsShowLoading()
	return true
end

function UINpcDialogBase:OnDelete()
	if self.scene then 
		self.scene:SetDraw(false)
	end
	
	if self.objAvatar then
		self.objAvatar:ExitMap();
		self.objAvatar = nil;
	end
end

function UINpcDialogBase:GetWidth()
	return 963;
end

function UINpcDialogBase:GetHeight()
	return 382;
end

--打开面板
--@param npcId NPCID
function UINpcDialogBase:Open( npcId )

end

function UINpcDialogBase:OnHide()
	if self.scene then 
		self.scene:SetDraw(false)
	end
	
	if self.objAvatar then
		self.objAvatar:ExitMap();
		self.objAvatar = nil;
	end
	self:OnSubHide()
	NpcController:WhenCloseDialog(self.npc.npcId)
end

function UINpcDialogBase:OnSubHide()
	-- override
end

function UINpcDialogBase:OnShow()
	self:UpdateShow()
end

function UINpcDialogBase:UpdateShow()
	-- override
end

function UINpcDialogBase:OnItemClick(e)
	-- override
end

--点击关闭
function UINpcDialogBase:OnBtnCloseClick()
	self:Hide();
end

UINpcDialogBase.scene = nil;
function UINpcDialogBase:DrawNpc()
	local swf = self.objSwf;
	--debug.debug();
	
	local drawCfg = UIDrawNpcCfg[self.npc.npcId];
	if not drawCfg then
		drawCfg = {
						EyePos = _Vector3.new(0,-40,20),
						LookPos = _Vector3.new(0,0,10),
						VPort = _Vector2.new(800,800),
						Rotation = 0
					};
	end
	
	if not self.scene then
		self.scene = UISceneDraw:new(self:GetName(), swf.npcLoader, drawCfg.VPort, false);
	end
	self.scene:SetUILoader(swf.npcLoader)
	
	self.scene:SetScene('v_panel_npc.sen', function()
		self:DrawAvatar(drawCfg);
	end );
	self.scene:SetDraw( true );
end

--画Npc模型
function UINpcDialogBase:DrawAvatar(drawCfg)
	if self.objAvatar then
		self.objAvatar:ExitMap();
		self.objAvatar = nil;
	end

	local objSwf = self.objSwf;
	if not objSwf then return; end
	self.objAvatar = NpcAvatar:NewNpcAvatar(self.npc.npcId);
	self.objAvatar:InitAvatar();
	
	self.scene:SetCamera(drawCfg.VPort,drawCfg.EyePos,drawCfg.LookPos);
	self.objAvatar.objMesh.transform:setRotation( 0, 0, 1, drawCfg.Rotation or 0 );

	local cfgnpc = t_npc[self.npc.npcId]
	local cfgmodel = t_model[cfgnpc.look];
	self.objAvatar:DoAction(cfgmodel.san_leisure, false, function() end)
	
	local markers = self.scene:GetMarkers();
	local indexc = "marker2";
	self.objAvatar:EnterUIScene(self.scene.objScene,nil,nil,nil, enEntType.eEntType_Npc);
	
end

function UINpcDialogBase:SendNPCGossipMsg(npcId)
	local msg = ReqNpcGossipMsg:new();
	msg.npcid = npcId;
	MsgManager:Send(msg)
end
	









