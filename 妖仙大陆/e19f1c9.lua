

local _M = {}
local ServerTime = require 'Zeus.Logic.ServerTime'
_M.__index = _M

local use_mock
use_mock = false


function _M.RequestMyAuction(params,cb)
	if use_mock then
		local eles = GlobalHooks.DB.Find('Items',{})
		local count = math.random(1,10)
		local mocks = {}
		for i=1,count do
			table.insert(mocks,{
				code=eles[math.random(1,#eles)].Code,
				num=math.random(1,999),
				price=math.random(1,9999999),
				endTime=(ServerTime.GetServerUnixTime()+math.random(200,72000))*1000
			})
		end
		cb(mocks)
		return 
	end
	params.global = params.global or 0
	Pomelo.ConsignmentLineHandler.myConsignmentRequest(params.global,function (ex,sjson)
		
		if not ex and cb then
			local data = sjson:ToData()
			cb(data.s2c_data,data.s2c_can_sell_num)
		end
	end)
end


function _M.RequestUnSubscribItem(params,cb)
	if use_mock then
		cb()
		return
	end
	params.global = params.global or 0
	Pomelo.ConsignmentLineHandler.removeConsignmentRequest(params.id,params.global,function (ex,sjson)
		if not ex and cb then
			cb()
		end
	end)
end

function _M.RequestConsignmentEquipmentId(params,cb)
	
	params.global = params.global or 0
	Pomelo.ConsignmentLineHandler.publicItemRequest(params.id,function (ex,sjson)
		if not ex and cb then
			cb()
		end
	end)
end


function _M.RequestSubscribItem(params,cb)
	params.global = params.global or 0
	Pomelo.ConsignmentLineHandler.addConsignmentRequest(params.index,params.num,params.price,params.global,params.isAnonymous,params.id,function (ex,sjson)
		if not ex and cb then
			cb()
		end
	end)
end


function _M.RequestBuyAuctionItem(params,cb)
	if use_mock then
		cb()
		return
	end
	params.global = params.global or 0
	Pomelo.ConsignmentLineHandler.buyConsignmentRequest(params.id,params.global,function (ex,sjson)
		if not ex and cb then
			cb()
		end
	end)
end

function _M.RequestAuctionList(params,cb)
	if use_mock then
		local secondType = params.secondType
		local pro = params.pro
		local quality = params.quality
		local sort = params.sort
		local pageIndex = params.pageIndex
		local itemEle = GlobalHooks.DB.Find('ItemIdConfig',secondType)
	  local search = {
	  	Pro=function (e)
	  		return pro==0 or e==PublicConst.GetProName(pro)
	  	end,
	  	Qcolor=function(e)
	  		return quality==0 or e==quality
	  	end}
	  if itemEle then
	  	search.Type=function (e)
	  		return secondType == 0 or e==itemEle.ItemType
	  	end
	  end
		local eles = GlobalHooks.DB.Find('Items',search)
		local count = 20
		local mocks = {}
		local txts = {'傻傻','笨蛋','中晋合伙人','锅仔','华妈'}
		
		local function RandomTxt(length)
			local txt = ''
			for j=1,length do
				local index = math.random(1,#txts)
				txt = txt..txts[index]
			end	
			return txt
		end
		if #eles > 0 then
			for i=1,count do
				table.insert(mocks,{
					code=eles[math.random(1,#eles)].Code,
					num=math.random(1,999),
					price=math.random(1,9999999),
					playerName='华仔'..RandomTxt(1),
					pro=math.random(1,5),
				})
			end
			cb({s2c_data=mocks,s2c_totalPage=999})
		else 
			cb({s2c_data=mocks,s2c_totalPage=0})
		end
		return 
	end

	Pomelo.ConsignmentLineHandler.consignmentListRequest(
		params.pro,
		params.quality,
		params.sort,
		params.secondType,
		params.pageIndex,
		params.global or 0,	
		params.itemType,
		params.level,
		function (ex,sjson)		
			if not ex and cb then
				cb(sjson:ToData())
			end
		end)

end


function _M.RequestAuctionSearch(params,cb)
	params.global = params.global or 0
	Pomelo.ConsignmentLineHandler.searchConsignmentRequest(params.condition, params.global, function (ex,sjson)
		if not ex and cb then
			local data = sjson:ToData()
			
			cb(data.s2c_data)
		end
	end)
end

return _M
