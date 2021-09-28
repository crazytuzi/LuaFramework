


local _M = {}
_M.__index = _M

local cjson = require"cjson"    
local ItemModel = require"Zeus.Model.Item"

function _M.UnEmbedGemRequest(t, gridIndex, holeIndexs,cb)
	Pomelo.StoreHandler.unEmbedGemRequest(t,gridIndex,holeIndexs,function (ex,sjson)
		if not ex and cb then
			cb()
		end
	end)
end

function _M.EmbedGemRequest(t,gridIndex, embedGems, cb)
	Pomelo.StoreHandler.embedGemRequest(t,gridIndex,embedGems,function (ex,sjson)
		if not ex and cb then
			cb()
		end
	end)
end

function _M.SynGemRequest(templateId,num,cb)
	Pomelo.StoreHandler.synGemRequest(templateId,num,function (ex,sjson)
		if not ex and cb then
			cb()
		end
	end)
end

return _M
