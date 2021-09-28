local CommonFunc = require("app.scenes.moshen.rebelboss.RebelBossCommonFunc")

local CrossPVPDoSelectPlayerItem = class("CrossPVPDoSelectPlayerItem", function()
	return CCSItemCellBase:create("ui_layout/crosspvp_DoSelectPlayerItem.json")
end)


function CrossPVPDoSelectPlayerItem:ctor()
	
end

function CrossPVPDoSelectPlayerItem:updateItem(tRank, clickCallback)
	if not tRank then
		return
	end

	local nResId = 10013
	local nQuality = 4
	local nServerId = tRank.sid
	local szServerName = tRank.sname
	szServerName = string.format("[%s(S%d)]", szServerName, nServerId)

	-- 头像
	CommonFunc._updateImageView(self, "Image_Icon", {texture=G_Path.getKnightIcon(nResId)})
	-- 品质框
	CommonFunc._updateImageView(self, "Image_QualityFrame", {texture=G_Path.getEquipColorImage(nQuality), texType=UI_TEX_TYPE_PLIST})
	-- 玩家名字
	CommonFunc._updateLabel(self, "Label_name", {text=tRank.name, stroke=Colors.strokeBrown, color=Colors.qualityColors[nQuality]})
	-- 玩家区服
	CommonFunc._updateLabel(self, "Label_ServerName", {text=szServerName})

	-- 玩玩家
	self:registerBtnClickEvent("Button_Select", function()
		if clickCallback then
			clickCallback()
		end
	end)
end


return CrossPVPDoSelectPlayerItem