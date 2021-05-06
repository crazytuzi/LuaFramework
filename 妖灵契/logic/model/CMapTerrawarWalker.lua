local CMapTerrawarWalker = class("CMapTerrawarWalker", CMapWalker)

function CMapTerrawarWalker.ctor(self)
	CMapWalker.ctor(self)
	self.m_block  = nil
end

function CMapTerrawarWalker.Setblock(self, block, bcheck)
	self.m_block = block
	if bcheck then
		self:UpdateTerrawar()
	end
end

--放在CTerrawarNpc设置,预防战斗的时候缓存GS2CEnterAoi后又缓存GS2CSyncAoi导致UpdateTerrawar的时候m_TerrawarType为nil
function CMapTerrawarWalker.SetTerrawarType(self, block)
	if block.name and string.find(block.name, "大") then
		self.m_TerrawarType = define.Terrawar.Effect.Type.Big
	elseif block.name and string.find(block.name, "中") then
		self.m_TerrawarType = define.Terrawar.Effect.Type.Medium
	elseif block.name and string.find(block.name, "小") then
		self.m_TerrawarType = define.Terrawar.Effect.Type.Small
	end
end

--owner:判断是否为据点npc
--ownerid:判断是否有领主
--oorgid:判断敌/友
function CMapTerrawarWalker.UpdateTerrawar(self)
	local block = self.m_block
	if not block then
		return
	end
	self:ClearEffect()
	if self.m_TerrawarType == define.Terrawar.Effect.Type.Big or (block.name and string.find(block.name, "大")) then
		self.m_TerrawarType = define.Terrawar.Effect.Type.Big
	elseif self.m_TerrawarType == define.Terrawar.Effect.Type.Medium or (block.name and string.find(block.name, "中")) then
		self.m_TerrawarType = define.Terrawar.Effect.Type.Medium
	elseif self.m_TerrawarType == define.Terrawar.Effect.Type.Small or (block.name and string.find(block.name, "小")) then
		self.m_TerrawarType = define.Terrawar.Effect.Type.Small
	end
	if not self.m_TerrawarType then
		printc("没有 m_TerrawarType---------------------------------------")
		return
	end
	
	local tPath = define.Terrawar.Effect.Path[self.m_TerrawarType]
	local sPath 

	if block.ownerid and block.orgid and block.orgid > 0 and block.orgflag then
		if self.m_LastOrgID then
			--有self.m_LastOwnerID说明已经初始化完成
			if self.m_LastOrgID == 0 then
				if block.orgid == g_AttrCtrl.org_id then
					sPath = tPath["N2A"]
				else
					sPath = tPath["N2E"]
				end				
			elseif self.m_LastOrgID > 0 then
				if self.m_LastOrgID == g_AttrCtrl.org_id then
					if self.m_LastOwnerID == block.ownerid then
						sPath = tPath["Ally"]
					else
						sPath = tPath["A2N"]
					end
				else
					if self.m_LastOwnerID == block.ownerid then
						sPath = tPath["Enemy"]
					else
						sPath = tPath["E2N"]
					end
				end	
			end
		else
			--第一次初始化
			if block.orgid == g_AttrCtrl.org_id then 
				sPath = tPath["Ally"]
			else
				sPath = tPath["Enemy"]
			end
		end
	else
		if self.m_LastOrgID and self.m_LastOrgID > 0 then
			if self.m_LastOrgID == g_AttrCtrl.org_id then
				if self.m_LastOwnerID == block.ownerid then
					sPath = tPath["Ally"]
				else
					sPath = tPath["A2N"]
				end
			else
				if self.m_LastOwnerID == block.ownerid then
					sPath = tPath["Enemy"]
				else
					sPath = tPath["E2N"]
				end
			end	
		else
			sPath = tPath["Normal"]
		end
	end
	if not self.m_LastOrgID or block.ownerid ~= 0 then
		self.m_LastOrgID = block.orgid or 0
		self.m_LastOwnerID = block.ownerid
	end
	if sPath then
		self:AddTerrawarEffect(sPath)
	else
		printc("注意：据点战npc Path为nil。查看操作步骤")
	end
end

function CMapTerrawarWalker.AddTerrawarEffect(self, path)
	local function localcb(oEffect)
		if Utils.IsExist(self) then
			self.m_TerrawarEff:SetParent(self.m_Transform)
			self.m_TerrawarEff:SetActive(true)
			g_EffectCtrl:AddEffect(self.m_TerrawarEff)
			-- self.m_Actor:MainModelCall(function(oModel) oModel:AddRenderObj(oEffect.m_GameObject, true) end)
		else
			oEffect:Destroy()
		end
	end
	self.m_TerrawarEff =  CEffect.New(path, self.m_Layer, false, localcb)
end

function CMapTerrawarWalker.ChangeShapeDone(self)
	--printc("CMapTerrawarWalker.ChangeShapeDone")
	self:UpdateTerrawar()
end

function CMapTerrawarWalker.ChangeShape(self, iShape, tDesc, func)
	--printc("CMapTerrawarWalker.ChangeShape")
	if self.m_TerrawarEff then
		self.m_TerrawarEff:SetActive(false)
	end
	CMapWalker.ChangeShape(self, iShape, tDesc, callback(self, "ChangeShapeDone"))
end

function CMapTerrawarWalker.SyncBlockInfo(self, eid, block)
	printc("CMapTerrawarWalker.SyncBlockInfo-eid:", eid)
	self:Setblock(block, true)
	CMapWalker.SyncBlockInfo(self, eid, block, callback(self, "ChangeShapeDone"))
end

function CMapTerrawarWalker.Destroy(self)
	self:ClearEffect()
	CMapWalker.Destroy(self)
end

function CMapTerrawarWalker.ClearEffect(self)
	if self.m_TerrawarEff then
		g_EffectCtrl:DelEffect(self.m_TerrawarEff:GetInstanceID())
		self.m_TerrawarEff = nil
	end
end

return CMapTerrawarWalker