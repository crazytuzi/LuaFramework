local CTerraWarMapPage = class("CTerraWarMapPage", CPageBase)
--[[

--初始化入口在InitDrawTexture

]]

function CTerraWarMapPage.ctor(self, cb)
	CPageBase.ctor(self, cb)
	self.m_Texture2D = nil
	self.m_PosBoxDic = {}
	self.m_LineDic = {}
	self.m_NeighbourDic = {}
	self.m_TerraWarMapID = nil
	self.m_TerraWarResID = nil
	self.m_TerraWarSceneID = nil
	self.m_DrawTimer = nil
	self.m_DrawColor = nil
	--宽高比例
	self.m_Scene2MapZoomX = 1
	self.m_Scene2MapZoomY = 1
end

function CTerraWarMapPage.OnInitPage(self)
	self.m_Container = self:NewUI(1, CWidget)
	self.m_ContentWidget = self:NewUI(2, CWidget)
	self.m_MapTexture = self:NewUI(3, CTexture)
	self.m_DrawTexture = self:NewUI(4, CTexture)
	self.m_PosBox = self:NewUI(6, CBox)
	self.m_SwitchMapBtn = self:NewUI(7, CButton)
	self.m_MapWidget = self:NewUI(8, CWidget)
	self.m_MapGrid = self:NewUI(9, CGrid)
	self.m_MapBox = self:NewUI(10, CBox)
	self.m_LineClone = self:NewUI(11, CBox)
	self.m_BgSprite = self:NewUI(12, CSprite)
	self.m_BlackTexture = self:NewUI(14, CTexture)
	self:InitContent()
end

function CTerraWarMapPage.InitContent(self)
	--UITools.ResizeToRootSize(self.m_Container)
	self.m_PosBox:SetActive(false)
	self.m_MapWidget:SetActive(false)
	self.m_MapBox:SetActive(false)
	self.m_LineClone:SetActive(false)
	self.m_SwitchMapBtn:AddUIEvent("click", callback(self, "OnSwitchMapBtn"))
	self.m_BlackTexture:AddUIEvent("click", function () self.m_MapWidget:SetActive(false) end)
	g_TerrawarCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTerrawarCtrl"))

	self:InitSwitchMap()
	self:OnDefaultMapBox()
	self.m_IsInit = true
end

function CTerraWarMapPage.ShowPage(self)
	if self.m_IsInit then
		self:OnDefaultMapBox()
	end
	CPageBase.ShowPage(self)
end

function CTerraWarMapPage.OnTerrawarCtrl(self, oCtrl)
	if oCtrl.m_EventID == define.Terrawar.Event.RefreshMap then
		printc("OnTerrawarCtrl：刷新据点地图数据:",self.m_TerraWarResID)
		self:InitMiniMapView(self.m_TerraWarResID)
	end
end

function CTerraWarMapPage.OnSwitchMapBtn(self)
	local bAct = self.m_MapWidget:GetActive()
	self.m_MapWidget:SetActive(not bAct)
end

function CTerraWarMapPage.InitSwitchMap(self)
	--根据scenedata数据
	self.m_MapGrid:Clear()
	for i,id in ipairs(define.Terrawar.Scenes) do
		local oMapBox = self.m_MapBox:Clone()
		oMapBox:SetActive(true)
		oMapBox.m_CityLabel = oMapBox:NewUI(1, CLabel)
		oMapBox.m_SceneID = id
		oMapBox.m_MapID = data.scenedata.DATA[id].map_id
		oMapBox.m_ResID = data.mapdata.DATA[oMapBox.m_MapID].resource_id
		oMapBox.m_CityLabel:SetText(data.scenedata.DATA[id].scene_name)
		oMapBox:AddUIEvent("click", callback(self, "OnMapBox"))
		self.m_MapGrid:AddChild(oMapBox)
	end
	self.m_MapGrid:Reposition()
end

function CTerraWarMapPage.OnMapBox(self, oMapBox)
	if self.m_TerraWarResID == oMapBox.m_ResID then
		return
	end
	self.m_TerraWarMapID = oMapBox.m_MapID
	self.m_TerraWarSceneID = oMapBox.m_SceneID
	self.m_TerraWarResID = oMapBox.m_ResID
	g_TerrawarCtrl:C2GSTerrawarMapInfo(self.m_TerraWarMapID)
end

function CTerraWarMapPage.OnDefaultMapBox(self)
	if self.m_TerraWarMapID then
		g_TerrawarCtrl:C2GSTerrawarMapInfo(self.m_TerraWarMapID)
	else
		for k,oMapBox in pairs(self.m_MapGrid:GetChildList()) do
			if oMapBox.m_MapID == 101000 --[[g_MapCtrl:GetMapID()]] then
				self:OnMapBox(oMapBox)
				return
			end
		end
	end
end

function CTerraWarMapPage.GetTerraWarMapID(self)
	return self.m_TerraWarMapID
end

function CTerraWarMapPage.InitMiniMapView(self, resid)
	local resid = resid or g_MapCtrl:GetResID() or 1010 
	local pathName = string.format("Map2d/%s/minimap_%s.png", resid, resid)
	local function finishLoadMiniMap(textureRes, errcode)
		if Utils.IsNil(self) then
			return
		end
		if textureRes then
			self.m_MapTexture:SetMainTexture(textureRes)
		else
			return
		end
		local ratio = textureRes.width / textureRes.height 
		self:SetMimiMapSize(ratio)
	end
	g_ResCtrl:LoadAsync(pathName, finishLoadMiniMap)
end

function CTerraWarMapPage.SetMimiMapSize(self, ratio)
	local finalWidth, finalHeight = 0, 0
	-- 适配(横向,定宽 \ 纵向,定高)
	local baseW, baseH = self.m_ContentWidget:GetSize()
	if ratio > 1 then
		finalWidth = baseW
		finalHeight = finalWidth / ratio
		if finalHeight > baseH then
			finalHeight = baseH
			finalWidth = finalHeight * ratio
		end
	else
		finalHeight = baseH
		finalWidth = finalHeight * ratio
	end


	local w = data.mapdata.DATA[self.m_TerraWarMapID].width
	local h = data.mapdata.DATA[self.m_TerraWarMapID].height
	self.m_Scene2MapZoomX = w / finalWidth
	self.m_Scene2MapZoomY = h / finalHeight

	self.m_MapTexture:SetPivot(enum.UIWidget.Pivot.Center)
	self.m_MapTexture:SetLocalPos(Vector3.zero)
	self.m_MapTexture:SetSize(finalWidth, finalHeight)
	self.m_MapTexture:SetPivot(enum.UIWidget.Pivot.BottomLeft)
	self.m_MapTexture.m_UIWidget:ResizeCollider()
	self.m_BgSprite:ResetAndUpdateAnchors()
	self.m_DrawTexture:ResetAndUpdateAnchors()

	self:InitDrawTexture()
end

function CTerraWarMapPage.InitDrawTexture(self)
	local w,h = self.m_DrawTexture:GetSize()
	if self.m_Texture2D then
		self.m_DrawTexture:SetMainTexture(nil)
		self.m_Texture2D:Destroy()
	end
	self.m_Texture2D = UnityEngine.Texture2D.New(w, h)
	self.m_DrawTexture:SetMainTexture(self.m_Texture2D)

	if g_TerrawarCtrl:IsOpenTerrawar() then
		self:InitPosBox()
		self:InitLine()
		
		self:RefreshAllPosBox()
		self:RefreshTringle()
	end
end

-------------------------------驻点部分开始--------------------------------

function CTerraWarMapPage.ClearPosBoxList(self)
	for k,oPosBox in pairs(self.m_PosBoxDic) do
		oPosBox:Destroy()
	end
	self.m_PosBoxDic = {}
	self.m_NeighbourDic = {}
end

function CTerraWarMapPage.InitPosBox(self)
	local posDic = g_TerrawarCtrl:GetTerrawarDataForMapID(self.m_TerraWarMapID)
	self:ClearPosBoxList()
	for k,v in pairs(posDic) do
		local oPosBox = self.m_PosBox:Clone()
		oPosBox:SetActive(true)
		oPosBox.m_PosLabel = oPosBox:NewUI(1, CLabel)
		oPosBox.m_TypeSprite = oPosBox:NewUI(2, CSprite)
		oPosBox.m_BelongSprite = oPosBox:NewUI(3, CSprite)
		oPosBox.m_HelpSprite = oPosBox:NewUI(4, CSprite)
		oPosBox.m_OrgFlagLabel = oPosBox:NewUI(5, CLabel)
		oPosBox.m_BelongSprite:SetActive(false)
		oPosBox.m_HelpSprite:SetActive(false)
		oPosBox.m_TypeSprite:SetSpriteName("pic_xingxing"..v.size)
		local pos = Vector3.New(v.position.posx, v.position.posy, 0)
		oPosBox.m_PosLabel:SetText(v.name)
		oPosBox.m_OrgFlagLabel:SetText(k)

		oPosBox:AddUIEvent("click", callback(self, "OnPosBox"))
		oPosBox:SetParent(self.m_MapTexture.m_Transform)
		local vTexturePos = self:GetScene2MapPos(pos)
		oPosBox:SetLocalPos(vTexturePos)
		self.m_PosBoxDic[k] = oPosBox
		self.m_NeighbourDic[k] = v.neighbour
	end
end

function CTerraWarMapPage.OnPosBox(self, oPosBox)
	if oPosBox.m_PosInfo then
		CTerraWarTipsView:ShowView(function (oView)
			oView:SetContent(oPosBox.m_PosInfo)				
			UITools.NearTarget(oPosBox, oView.m_BgSprite, enum.UIAnchor.Side.Center, Vector2.New(0, 0), true)		
		end)
	end
end

function CTerraWarMapPage.GetScene2MapPos(self, keyPos)
	return Vector3.New(keyPos.x / self.m_Scene2MapZoomX, keyPos.y / self.m_Scene2MapZoomY, 0)
end

function CTerraWarMapPage.RefreshAllPosBox(self)
	local mapInfo = g_TerrawarCtrl:GetTerrawarMapInfo(self.m_TerraWarMapID)
	for k,v in pairs(mapInfo) do
		local oPosBox = self.m_PosBoxDic[k]
		if oPosBox then
			oPosBox.m_PosInfo = v
			if g_TerrawarCtrl:IsOpenTerrawar() then
				local orgflag = v.orgflag or ""
				oPosBox.m_OrgFlagLabel:SetText(orgflag)
				if v.orgid and v.orgid == g_AttrCtrl.org_id then
					oPosBox.m_BelongSprite:SetActive(true)
					oPosBox.m_BelongSprite:SetSpriteName("pic_lanse_qizi02")
				elseif v.orgid and v.orgid ~= 0 then
					oPosBox.m_BelongSprite:SetActive(true)
					oPosBox.m_BelongSprite:SetSpriteName("pic_hongse_qizi02")
				else
					oPosBox.m_BelongSprite:SetActive(false)
				end
				if v.orgid and v.orgid == g_AttrCtrl.org_id and v.status == 1 then
					oPosBox.m_HelpSprite:SetActive(true)
				else
					oPosBox.m_HelpSprite:SetActive(false)
				end
			else
				oPosBox.m_BelongSprite:SetActive(false)
			end
		end
	end
end

-------------------------------驻点部分结束--------------------------------

--------------------------------------画线部分开始------------------------------
function CTerraWarMapPage.ClearLineList(self)
	for k,oLine in pairs(self.m_LineDic) do
		oLine:Destroy()
	end
	self.m_LineDic = {}
end

function CTerraWarMapPage.InitLine(self)
	self:ClearLineList()
	local posDic = g_TerrawarCtrl:GetTerrawarDataForMapID(self.m_TerraWarMapID)
	for k,oPosBox in pairs(self.m_PosBoxDic) do
		local pos1 = oPosBox:GetLocalPos()
		for j,l in pairs(posDic[k].neighbour) do
			local oPosBox = self.m_PosBoxDic[l]
			if oPosBox then
				local pos2 = oPosBox:GetLocalPos()
				self:AddLine(pos1, pos2)
			end
		end
	end

end

function CTerraWarMapPage.AddLine(self, pos1, pos2)
	local centerPos = Vector3.Lerp(pos1, pos2, 0.5)
	centerPos.x = math.floor(centerPos.x)
	centerPos.y = math.floor(centerPos.y)
	local key = "x="..centerPos.x.."y="..centerPos.y
	if self.m_LineDic[key] then
		return
	end
	local distance = Vector3.Distance(pos1, pos2)
	local tangle = self:TanAngle(pos1, pos2)
	local oLine = self.m_LineClone:Clone()
	
	oLine:SetName(key)
	oLine:SetActive(true)
	oLine:SetParent(self.m_MapTexture.m_Transform)
	oLine:SetLocalPos(centerPos)
	oLine:SetSize(distance, 2)
	local vp = Quaternion.AngleAxis(tangle, Vector3.forward)
	oLine:SetLocalRotation(vp)
	self.m_LineDic[key] = oLine
	oLine.m_Texture = oLine:NewUI(1, CTexture)
	oLine.m_X = 0
	oLine.m_Timer = Utils.AddTimer(callback(self, "UpdateLine", oLine), 0.5, 0.5)
end

function CTerraWarMapPage.UpdateLine(self, oLine)
	if Utils.IsNil(self) then
		return
	end
	oLine.m_X = oLine.m_X + 0.5
	oLine.m_Texture:SetUVRect(UnityEngine.Rect.New(oLine.m_X , 0, 1, 1))
	return true
end

function CTerraWarMapPage.TanAngle(self, pos1, pos2)
	local xdis = pos2.x - pos1.x
	local ydis = pos2.y - pos1.y
	local tanValue = Mathf.Atan2(ydis, xdis)
	local radian = tanValue * Mathf.Rad2Deg
	return radian 
end
--------------------------------------画线部分结束------------------------------


-------------------------------三角形填充像素开始-----------------------------------

function CTerraWarMapPage.RefreshTringle(self)
	local function draw()
		local allList = g_TerrawarCtrl:GetUpArea(self.m_TerraWarMapID)
		for i,v in pairs(allList) do
			if v.orgid == g_AttrCtrl.org_id then
				self.m_DrawColor = Color.blue
			else
				self.m_DrawColor = Color.red
			end
			local tringleDic = {}
			local mapInfo = v.mapInfo
			local key, idx1, idx2, idx3, find
			for i1,v1 in ipairs(mapInfo) do
				idx1 = v1
				for i2, v2 in ipairs(self.m_NeighbourDic[v1]) do
					find = table.index(mapInfo, v2)
					if find then
						idx2 = v2
						for i3,v3 in ipairs(self.m_NeighbourDic[v2]) do
							find = table.index(mapInfo, v3)
							if find and v3 ~= v1 then
								idx3 = v3
								find = table.index(self.m_NeighbourDic[v3], v1)
								if find then
									local temp = {idx1, idx2, idx3}
									table.sort(temp)
									key = temp[1]..","..temp[2]..","..temp[3]
									tringleDic[key] = temp
								end
							end
						end
					end
				end
			end
			
			local pos1, pos2, pos3
			for k,v in pairs(tringleDic) do
				pos1 = self.m_PosBoxDic[v[1]]:GetLocalPos()
				pos2 = self.m_PosBoxDic[v[2]]:GetLocalPos()
				pos3 = self.m_PosBoxDic[v[3]]:GetLocalPos()
				self:DrawTrangle(pos1, pos2, pos3)
			end
		end
		self.m_Texture2D:Apply()
	end

	if self.m_DrawTimer then
		Utils.DelTimer(self.m_DrawTimer)
		self.m_DrawTimer = nil
	end
	self.m_DrawTimer  = Utils.AddTimer(draw, 0, 0)
end

function CTerraWarMapPage.DrawTrangle(self, pos1, pos2, pos3)
	if self:DrawTopTrangle(pos1, pos2, pos3) then
		return
	elseif self:DrawBottonTrangle(pos1, pos2, pos3) then
		return
	else
		self:DrawOtherTrangle(pos1, pos2, pos3)
	end
end

function CTerraWarMapPage.DrawTopTrangle(self, pos1, pos2, pos3)
	--绘制底边在上三角形
	--[[  
		   1-------2
			\	  /
		     \   /
		      \ /
               3
	]]
	---先把点规范成上图模式
	if pos1.y == pos2.y then

	elseif pos1.y == pos3.y then
		local temp = pos2
		pos2 = pos3
		pos3 = temp
	elseif pos2.y == pos3.y then
		local temp = pos1
		pos1 = pos3
		pos3 = temp
	else
		return false --不是底边在上三角形
	end
	if pos1.x > pos2.x then
		local temp = pos1
		pos1 = pos2
		pos2 = temp
	elseif pos1.x == pos2.x then
		return false --不是三角形
	end

	--计算左右误差值
	local dxy_left = (pos3.x - pos1.x) * 1.0 / (pos1.y - pos3.y)
	local dxy_right = (pos2.x - pos3.x) * 1.0 / (pos2.y - pos3.y)

	--开始填充
	local formX = pos1.x
	local toX = pos2.x

	--填充方式从上到下
	for i=pos1.y, pos3.y, -1 do
		self:DrawLine(formX-0.5, toX-0.5, i)
		formX = formX + dxy_left
		toX = toX - dxy_right
	end
	return true
end

function CTerraWarMapPage.DrawBottonTrangle(self, pos1, pos2, pos3)
	--绘制底边在下三角形
	--[[  
		     1 
			/ \	  
		   /   \   
		  /     \ 
         2-------3
	]]
	---先把点规范成上图模式
	if pos2.y == pos3.y then

	elseif pos1.y == pos2.y then
		local temp = pos1
		pos1 = pos3
		pos3 = temp
	elseif pos1.y == pos3.y then
		local temp = pos1
		pos1 = pos2
		pos2 = temp
	else
		return false --不是底边在下三角形
	end

	if pos2.x > pos3.x then
		local temp = pos2
		pos2 = pos3
		pos3 = temp
	elseif pos2.x == pos3.x then
		return false --不是三角形
	end

	--计算左右误差值
	local dxy_left = (pos1.x - pos2.x) * 1.0 / (pos1.y - pos2.y)
	local dxy_right = (pos3.x - pos1.x) * 1.0 / (pos1.y - pos3.y)

		--开始填充
	local formX = pos2.x
	local toX = pos3.x

	--填充方式从下到上
	for i=pos2.y, pos1.y do
		self:DrawLine(formX-0.5, toX-0.5, i)
		formX = formX + dxy_left
		toX = toX - dxy_right
	end
	return true
end

function CTerraWarMapPage.DrawOtherTrangle(self, pos1, pos2, pos3)
	--绘制其他三角形
	--[[  1是最高点, 2是最低点, 过3做平行线交12得到点p, 平行线切割个得到平底和平顶三角形

		     1                                1
			 *                                *
			*   *                          *   *
           *      * 3                   3*      *
          *     *                          *     *
         *   *                               *    *
		*  *	                                *  *
	   * *                                        * *
      2                                             2
	]]       

	if pos2.y > pos1.y and pos2.y > pos3.y then
		local temp = pos1
		pos1 = pos2
		pos2 = temp
	elseif pos3.y > pos1.y and pos3.y > pos1.y then
		local temp = pos1
		pos1 = pos3
		pos3 = temp
	end

	if pos3.y < pos2.y then
		local temp = pos2
		pos2 = pos3
		pos3 = temp
	end 

	--计算交点
	local y = pos3.y
	local x = (y - pos1.y) / (pos2.y - pos1.y) * (pos2.x - pos1.x) + pos1.x
	local point = Vector3.New(x, y, 0)
	self:DrawTopTrangle(pos2, pos3, point)
	self:DrawBottonTrangle(pos1, pos3, point)
	return true
end

function CTerraWarMapPage.DrawLine(self, x1, x2, y, color)
	for x=x1,x2 do
		self.m_Texture2D:SetPixel(x, y, self.m_DrawColor)
	end
end

-------------------------------三角形填充像素结束-----------------------------------

return CTerraWarMapPage