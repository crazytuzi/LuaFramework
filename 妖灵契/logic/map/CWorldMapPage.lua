local CWorldMapPage = class("CWorldMapPage", CPageBase)

local pos = {
	{["x"] = 100,	["y"] = 120,	["z"] = 0}, {["x"] = 268,	["y"] = -64,	["z"] = 0},
	{["x"] = -75,	["y"] = -123,	["z"] = 0}, {["x"] = 160,	["y"] = -198,	["z"] = 0},
	{["x"] = 280,	["y"] = 120,	["z"] = 0}, {["x"] = -126,	["y"] = 51,		["z"] = 0},
	{["x"] = -318,	["y"] = -3,		["z"] = 0}, {["x"] = -260,	["y"] = 168,	["z"] = 0},
	{["x"] = -248,	["y"] = -195,	["z"] = 0}, {["x"] = -345,	["y"] = 150,	["z"] = 0}
}

CWorldMapPage.Type = 
{
	Normal = 1,
	Anlei = 2,
}

function CWorldMapPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
	--用于计算
	self.m_BaseMapTextureSize = {width = 1024, height = 512 }
	self.m_Type = CWorldMapPage.Type.Normal
	self.m_CurMapBox = nil
end

function CWorldMapPage.OnInitPage(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_SwitchBtn = self:NewUI(2, CButton)
	self.m_PlayerIcon = self:NewUI(3, CSprite)
	self.m_CitysGrid = self:NewUI(4, CGrid)
	self.m_WorldMapTexture = self:NewUI(5, CTexture)
	self.m_AnLeitipsBtn = self:NewUI(6, CButton)
	self.m_PlayIconBox = self:NewUI(7, CBox)
	self.m_AnLeiCloneBox = self:NewUI(8, CBox)
	
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_SwitchBtn:AddUIEvent("click", callback(self, "OnSwitchMapBtn"))
	self.m_AnLeitipsBtn:AddHelpTipClick("anlei_main")
	g_MapCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnMapEvent"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrEvent"))
	
	self.m_CityIDList = {
		101000,	--1001
		200000,	--1002
		201000,	--1003
		202000,	--1004
		204000, --1005
		210400, --1006
		206000, --1008
		205000, --1007
	}
	self.m_PlayerIconOffset = Vector3.New(0, 100, 0)
	self:InitWorldMapView()
end

function CWorldMapPage.OnClose(self)
	self.m_ParentView:CloseView()
end

function CWorldMapPage.OnSwitchMapBtn(self)
	self.m_ParentView:ShowSpecificPage(2)
end

function CWorldMapPage.OnMapEvent(self, oCtrl)
	self:ResetPlayerPos()
end

function CWorldMapPage.ShowPage( self ,args)
	CPageBase.ShowPage(self)
	--点击暗雷打开的世界地图
	if args and args.key == "anlei" then
		self:InitAnLeiMode()
	end
end

function CWorldMapPage.OnAttrEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		if oCtrl.m_EventData then
			if oCtrl.m_EventData.dAttr.model_info and oCtrl.m_EventData.dPreAttr.model_info and 
				oCtrl.m_EventData.dAttr.model_info.shape ~= oCtrl.m_EventData.dPreAttr.model_info.shape then
				self:ResetPlayerIcon()
			end
		end
	end
end

-- InitViwe
function CWorldMapPage.InitWorldMapView(self)
	--local width, height = self.m_WorldMapTexture:GetSize()
	--local iAspect = UnityEngine.Screen.width/UnityEngine.Screen.height
	--self.m_WorldMapTexture:SetSize(UnityEngine.Screen.width, UnityEngine.Screen.height)
	--UITools.FitToRootSize(self.m_WorldMapTexture, iAspect)
	self:InitCityBtn()
	--self:ResetCitysSizeAndPos()
	self:ResetPlayerIcon()
	self:ResetPlayerPos()
	self.m_AnLeitipsBtn:SetActive(false)
end

function CWorldMapPage.ResetCitysSizeAndPos(self)
	local textureWidth, textureHeight = self.m_WorldMapTexture:GetSize()
	local w = textureWidth / self.m_BaseMapTextureSize.width
	local h = textureHeight / self.m_BaseMapTextureSize.height
	local oBtnWidth, oBtnHeight, oBtnPos
	for i,v in ipairs(self.m_CitysGrid:GetChildList()) do
		oBtnWidth, oBtnHeight = v:GetSize()
		oBtnPos = v:GetLocalPos()
		v:SetSize(oBtnWidth * w, oBtnHeight * h)
		v:SetLocalPos(Vector3.New(oBtnPos.x * w, oBtnPos.y * h, 0))
	end
	
	oBtnWidth, oBtnHeight = self.m_CloseBtn:GetSize()
	oBtnPos = self.m_CloseBtn:GetLocalPos()
	self.m_CloseBtn:SetSize(oBtnWidth * w, oBtnHeight * h)
	self.m_CloseBtn:SetLocalPos(Vector3.New(oBtnPos.x * w, oBtnPos.y * h, 0))

	oBtnWidth, oBtnHeight = self.m_SwitchBtn:GetSize()
	oBtnPos = self.m_SwitchBtn:GetLocalPos()
	self.m_SwitchBtn:SetSize(oBtnWidth * w, oBtnHeight * h)
	self.m_SwitchBtn:SetLocalPos(Vector3.New(oBtnPos.x * w, oBtnPos.y * h, 0))
	oBtnWidth, oBtnHeight = self.m_SwitchBtn:GetSize()

	oBtnWidth, oBtnHeight = self.m_AnLeitipsBtn:GetSize()
	oBtnPos = self.m_AnLeitipsBtn:GetLocalPos()
	self.m_AnLeitipsBtn:SetSize(oBtnWidth * w, oBtnHeight * h)
	self.m_AnLeitipsBtn:SetLocalPos(Vector3.New(oBtnPos.x * w, oBtnPos.y * h, 0))
end

function CWorldMapPage.InitCityBtn(self)
	local function initCity(obj, idx)
		local oCityBtn = CBox.New(obj)
		oCityBtn:SetGroup(self.m_CitysGrid:GetInstanceID())
		oCityBtn:AddUIEvent("click", callback(self, "OnCityBtnCallBack", idx))
		if idx == 2 then
			g_GuideCtrl:AddGuideUI("map_world_map_city_2_btn", oCityBtn)
		end
		return oCityBtn
	end
	self.m_CitysGrid:InitChild(initCity)
end

function CWorldMapPage.OnCityBtnCallBack(self, index)
	local curMapID = g_MapCtrl:GetMapID()
	local mapID = self.m_CityIDList[index]
	if not mapID then
		g_NotifyCtrl:FloatMsg("此地图暂未开放")
		return
	end
	if curMapID ~= mapID then
		local oHero = g_MapCtrl:GetHero()
		if oHero and oHero.m_Eid then
			netscene.C2GSClickWorldMap(g_MapCtrl:GetSceneID(), oHero.m_Eid, mapID)
		end
	end
	self.m_ParentView:CloseView()
end

function CWorldMapPage.ResetPlayerPos(self)
	local curMapID = g_MapCtrl:GetMapID()
	for index, v in ipairs(self.m_CityIDList) do
		if curMapID == v then
			local oBox = self.m_CitysGrid:GetChild(index)
			self.m_CurMapBox = oBox
			local vPos = oBox:GetLocalPos()
			vPos = vPos + self.m_PlayerIconOffset
			self.m_PlayIconBox:SetLocalPos(vPos)
			break
		end
	end
end

function CWorldMapPage.ResetPlayerIcon(self)
	local shape = g_AttrCtrl.model_info.shape
	self.m_PlayerIcon:SetSpriteName("pic_map_avatar_" .. shape)
end

function CWorldMapPage.SetPos(self, obj, index)
	local vPos = pos[index]
	if vPos then
		obj:SetLocalPos(Vector3.New(vPos.x, vPos.y, vPos.z))
	end
end

--暗雷模式
function CWorldMapPage.InitAnLeiMode(self)
	self.m_Type = CWorldMapPage.Type.Anlei
	self.m_SwitchBtn:SetActive(false)
	self.m_AnLeitipsBtn:SetActive(true)
	for i = 1, self.m_CitysGrid:GetCount() do
		local oBox = self.m_CitysGrid:GetChild(i)
		if oBox then			
			oBox.m_AnLeiSprite = oBox:NewUI(1, CSprite)
			oBox.m_AnLeiForbidSprite = oBox:NewUI(2, CSprite)
			oBox.m_AnLeiMapTipsBox = oBox:NewUI(3, CBox)
			oBox.m_AnLeiMapTipsBox.m_Grid = oBox.m_AnLeiMapTipsBox:NewUI(1, CGrid)

			local mapId = self.m_CityIDList[i]
			oBox.m_AnLeiMapTipsBox:SetActive(false)
			if not mapId then				
				oBox:SetActive(false)
			else
				oBox:SetActive(true)
				if g_AnLeiCtrl:IsAnLeiMap(mapId)  then
					oBox.m_AnLeiSprite:SetActive(true)
				else
					oBox.m_AnLeiForbidSprite:SetActive(true)
				end										
				oBox:AddUIEvent("click", callback(self, "OnAnLeiCityBtnCallBack", mapId))
				local icons = g_AnLeiCtrl:GetMapShowIcon(mapId)
				if icons and next(icons) then
					oBox.m_AnLeiMapTipsBox:SetActive(true)				 					
					oBox.m_AnLeiMapTipsBox.m_Grid:SetActive(true)
					for i, v in ipairs(icons) do
						local tBox = self.m_AnLeiCloneBox:Clone()
						tBox.m_Icon = tBox:NewUI(1, CSprite)
						tBox.m_Icon:SetSpriteName(tostring(v))
						oBox.m_AnLeiMapTipsBox.m_Grid:AddChild(tBox)
					end
				else					
					oBox.m_AnLeiMapTipsBox:SetActive(false)				
				end
			end
		end
	end
end

function CWorldMapPage.OnAnLeiCityBtnCallBack(self, mapId)
	if not g_AnLeiCtrl:IsAnLeiMap(mapId) then
		g_NotifyCtrl:FloatMsg("该区域无法进行探索。")
		return
	end
	CAnLeiMainView:ShowView(function (oView)
		oView:SetContent(
		{
			mapId = mapId,
			callBack = function ()
				self.m_ParentView:CloseView()
			end,
		})
	end
	)
end

return CWorldMapPage