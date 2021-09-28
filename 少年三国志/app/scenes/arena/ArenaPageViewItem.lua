local ArenaPageViewItem = class("ArenaPageViewItem",function ()
    return CCSPageCellBase:create("ui_layout/arena_ArenaPageViewItem.json")
end)

require("app.cfg.knight_info")
function ArenaPageViewItem:ctor(layer,...)
	-- self._knightImage = nil
	self._layer = layer
	self:setTouchEnabled(true)
end

function ArenaPageViewItem:update(index,kni,dressId,clid,cltm,clop)
	if not kni then
		return
	end
	dressId = dressId or 0
	if self._knightImage ~= nil then
		self._knightImage:removeFromParentAndCleanup(true)
		self._knightImage = nil
	else
	end
	local knight = knight_info.get(kni.base_id)
	local panel = self:getPanelByName("Panel_knight")
	panel:setVisible(true)
	local knightPic = require("app.scenes.common.KnightPic")

	-- local knight_id ,baseId = G_Me.formationData:getTeamKnightIdAndBaseIdByIndex(1, 1)
	--只有主角才换装
	if index == 0 then 
		local res = G_Me.dressData:getDressedResidWithClidAndCltm(knight.id,dressId,clid,cltm , clop)
		self._knightImage = knightPic.createKnightPic(res, panel, nil, true)
		return 
	end 
	if dressId == 0 then
		self._knightImage = knightPic.createKnightPic(knight.res_id, panel, nil, true)
	else
		local res = G_Me.dressData:getDressedResidWithDress(knight.id,dressId)
		self._knightImage = knightPic.createKnightPic(res, panel, nil, true)
	end
end

function ArenaPageViewItem:hideHero(  )
	self:showWidgetByName("Panel_knight", false)
end

function ArenaPageViewItem:showHero(  )
	self:showWidgetByName("Panel_knight", true)
end

function ArenaPageViewItem:onClick()
	--显示武将信息
end
return ArenaPageViewItem