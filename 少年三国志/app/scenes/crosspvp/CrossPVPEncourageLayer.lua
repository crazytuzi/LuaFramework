local CrossPVPEncourageLayer = class("CrossPVPEncourageLayer", UFCCSNormalLayer)

function CrossPVPEncourageLayer.create(scenePack, ...)
	return CrossPVPEncourageLayer.new("ui_layout/crosspvp_EncourageLayer.json", nil, scenePack, ...)
end

function CrossPVPEncourageLayer:ctor(jsonFile, fun, scenePack, ...)
	self.super.ctor(self, jsonFile, fun, ...)
	G_GlobalFunc.savePack(self, scenePack)
end

return CrossPVPEncourageLayer