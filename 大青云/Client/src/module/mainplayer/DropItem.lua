--
-- Created by IntelliJ IDEA.
-- User: Stefan
-- Date: 2014/8/22
-- Time: 21:30
-- 
--
_G.classlist['DropItem'] = 'DropItem'
_G.DropItem = {}
DropItem.objName = 'DropItem'
DropItem.isShowName = true
local metaDropItem = {__index = DropItem}
function DropItem:Update(e)
    --Debug("DropItem:Update ....................", debug.traceback())
    if self.Avatar then
		if not self.headBorad then 
			self.headBorad = ItemHeadBoard:new(self:GetCid(),self.configId,self.szItemName) 
		end
		local pos = self:GetPos()
		if not pos then 
			Debug('Error:DropItem:DrawHeadBoard(e) self:GetPos() is nil') return 
		else 
			if CPlayerControl.showName and self.isShowName then
				self.headBorad:Update(pos.x, pos.y, pos.z)
			end
		end
    end
    return true
end

function DropItem:NewDropItem(vo)
	local Obj = DropItem:new()
    Obj.isSim = vo.isSim;
    Obj.ObjId = vo.charId			    --对象id
    Obj.x = vo.x
    Obj.y = vo.y
    Obj.faceto = vo.faceto
    Obj.dwRoleId = vo.ownerId		    --所属玩家
    Obj.szItemName = ''
	Obj.configId = vo.configId
    Obj.stackCount = vo.stackCount
    local szItemName = ""
    local dmeshId = ""

    if t_equip[vo.configId] then
        szItemName = t_equip[vo.configId].name
    elseif t_item[vo.configId] then
        szItemName = t_item[vo.configId].name
    end

    if vo.configId < 100 then
        szItemName = szItemName.."×"..vo.stackCount
    end

	Obj.szItemName = szItemName
    Obj.Avatar = DropItemAvatar:NewDropItemAvatar(Obj.ObjId, Obj.configId, Obj.stackCount)
	Obj.headBorad = nil
    Obj.bornTime = nil
    if not Obj.Avatar:Create() then
        return
    end

    return Obj
end

function DropItem:new()
    local Obj = {}
    setmetatable(Obj, metaDropItem)
    return Obj
end

--删除Item
function DropItem:Delete()
    if self:IsInMap() then
        --Debug("DropItem: Delete")
		if self.headBorad then self.headBorad:Destory() self.headBorad = nil end
        self.Avatar:ExitMap()
        self.Avatar = nil
    end
    self = nil
end

local mat = _Matrix3D.new()
local wMat = _Matrix3D.new()
local pos3d =  _Vector3.new()
local pos2d = _Vector2.new()
local itemFont = _Font.new("SIMHEI", 12, 0, 1, false)
function DropItem:PlayItemPfx()
    local textColor = 0xFFFFFFFF
    
    local quality = 0
    if t_equip[self.configId] then
        quality = t_equip[self.configId].quality
    elseif t_item[self.configId] then
        if t_item[self.configId].sub == BagConsts.SubT_Tianshenka then
            quality = NewTianshenUtil:GetShowQuality(NewTianshenUtil:GetTianshenCardZizhi(self.configId))
        else
            quality = t_item[self.configId].quality
        end
    end
    if quality then
        textColor = TipsConsts:GetItemQualityColorVal(quality)
    end

    local selfPos = self:GetPos()
    mat:setTranslation(selfPos.x, selfPos.y, selfPos.z + 1)
    local pfx = CPlayerMap:GetSceneMap():PlayerPfxByMat("v_shiqu.pfx", "v_shiqu.pfx", mat)
    pfx:getEmitters()[1]:onRender( function()
		if not self.isShowName then return end
	
        _rd:pop3DMatrix( wMat )
        wMat:getTranslation( pos3d )
        _rd:projectPoint( pos3d.x, pos3d.y, pos3d.z, pos2d )
        _rd:push3DMatrix( wMat )
        itemFont.textColor = textColor
        itemFont.edgeColor = CUICardConfig[0].edgeColor
        itemFont:drawText(pos2d.x, pos2d.y,
            pos2d.x, pos2d.y, self.szItemName, _Font.hCenter + _Font.vCenter)
    end)
end

--显示Item
function DropItem:Show()
    if not self:IsInMap() then
        self.Avatar:EnterMap(self.x, self.y,self.faceto)
        local szBornAnimaName
        if self.bornTime and self:IsOwnSelf() then
            if self.szBornAnimaName then
                szBornAnimaName = self.szBornAnimaName
            else
                local configId = self.configId
                local dmeshId = t_equip[configId] and t_equip[configId].dmeshid or t_item[configId].dmeshid
                if dmeshId then
                    szBornAnimaName = GetPoundTable(dmeshId)[4]
                end
            end
            if szBornAnimaName then
                local szFile = Assets:GetNpcAnima(szBornAnimaName)
                if szFile then
                    local soundType = 1
                    if t_equip[self.configId] then
                        soundType = 1
                    elseif t_item[self.configId] then
                        soundType = 2
                    else
                        soundType = 1
                    end
                    DropItemController:PlayShowSound(soundType)
                    self.Avatar:ExecAction(szFile, false)
                end
            end
        end
		self:AddViewPfx()
    end
end

local scale_mat = _Matrix3D.new()
function DropItem:AddViewPfx()
	self:GetAvatar():StopAllPfx()

	local quality = 0
	-- SpiritsUtil:Trace(self.configId)
	if t_equip[self.configId] then
        quality = t_equip[self.configId].quality
    elseif t_item[self.configId] then
        if t_item[self.configId].sub == BagConsts.SubT_Tianshenka then
            quality = NewTianshenUtil:GetShowQuality(NewTianshenUtil:GetTianshenCardZizhi(self.configId))
        else
            quality = t_item[self.configId].quality
        end
    end
    if quality and quality ~= 0 then
        self:GetAvatar():PlayerPfx(10040 + quality)
    end
end

-----------------------------------
--数据获取
--获得对象id
function DropItem:GetObjId()
    return self.ObjId
end

--获得所属玩家
function DropItem:GetRoleId()
    return self.dwRoleId
end

--获得物品位置
function DropItem:GetPos()
    if self.Avatar then
        return self.Avatar:GetPos()
    else
        return {x = self.x, y = self.y}
    end
end

--在不在场景中
function DropItem:IsInMap()
    return (self.Avatar and self.Avatar.objNode and self.Avatar.objSceneMap)
end

function DropItem:GetAvatar()
    return self.Avatar
end

function DropItem:GetCid()
    return self.ObjId
end

function DropItem:GetItemId()
    return self.configId
end

function DropItem:GetOwnerId()
    return self.dwRoleId
end

function DropItem:HideSelf(isHide)
	self.isShowName = not isHide
	local avatar = self:GetAvatar()
	if avatar and avatar.objNode and avatar.objNode.entity then
		avatar.objNode.visible = not isHide
	end
end

function DropItem:IsOwnSelf()
    local ownerCid = self:GetOwnerId()
    local selfCid = MainPlayerController:GetRoleID()
    if ownerCid == selfCid then
        return true
    end
    return false
end