require("network.GameRequest")
require("network.RequestInfo")
require("data.data_error_error")

RequestHelperV2 = {}

local loadingLayer = require("utility.LoadingLayer")
local function execCallback(reqs)
	
	for k, v in ipairs(reqs) do
		if v.state == RequestState.OK then
			if v.oklistener then
				v.oklistener(v.resData)
			end
		else
			if v.errlistener then
				v.errlistener(v.resData)
			else
				show_tip_label(data_error_error[v.resData.errCode].prompt)
			end
		end
	end
end

--开始发送数据
local function start(reqs)
	for k, v in ipairs(reqs) do
		GameRequest[v.modulename][v.funcname](v.param,
		function (res)		
			if res["0"] ~= nil and string.len(res["0"]) > 0 then
				v.state = RequestState.ERROR
			elseif res.errCode ~= nil and res.errCode > 0 then
				v.state = RequestState.ERROR
			else
				v.state = RequestState.OK
			end
			v.resData = res
		end,
		function ()
			loadingLayer.hide()
		end)
	end
end

--单个请求
function RequestHelperV2.request(req)
	assert(type(GameRequest[req.modulename][req.funcname]) == "function", "RequestHelper请求函数名字不正确: " .. req.funcname)
	
	loadingLayer.start()
	local reqState = RequestState.WAITING
	local resData = nil
	
	GameRequest[req.modulename][req.funcname](req.param, function (res)
		if res["0"] ~= nil and string.len(res["0"]) > 0 then
			reqState = RequestState.ERROR
		elseif res.errCode ~= nil and res.errCode > 0 then
			reqState = RequestState.ERROR
		else
			reqState = RequestState.OK
		end
		resData = res
	end,
	function ()
		loadingLayer.hide()
	end)
	
	local schedule = require("framework.scheduler")
	local s
	s = schedule.scheduleGlobal(function ()
		if reqState == RequestState.OK or reqState ==  RequestState.ERROR then
			loadingLayer.hide()
			schedule.unscheduleGlobal(s)
			
			if reqState == RequestState.OK then
				if req.oklistener then
					req.oklistener(resData)
				end
			elseif req.errlistener then
				req.errlistener()
			elseif (type(data_error_error[resData.errCode]) ~= "nil") then
				show_tip_label(data_error_error[resData.errCode].prompt)
			end
		end
	end,
	0.2)
end

--多个请求
function RequestHelperV2.request2(reqs, finishCallback)
	
	start(reqs)
	loadingLayer.start()
	local schedule = require("framework.scheduler")
	local reqsche
	local bFinish = false
	reqsche = schedule.scheduleGlobal(function ()
		bFinish = true
		for k, v in ipairs(reqs) do
			if v.state == RequestState.WAITING then
				bFinish = false
				break
			end
		end
		
		if bFinish then
			loadingLayer.hide()
			schedule.unscheduleGlobal(reqsche)
			execCallback(reqs)
			if finishCallback then
				finishCallback()
			end
		end
	end,
	0.1)
end

return RequestHelperV2