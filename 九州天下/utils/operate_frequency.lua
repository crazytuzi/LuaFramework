------------------------------------------------------
--操作频率。方便处理一些如："你操作过于频繁。。。"
--@author bzw
------------------------------------------------------
OperateFrequency = OperateFrequency or BaseClass()
OperateFrequency.operate_t = {}

--cd 秒
function OperateFrequency.Operate(callback, operate_name, cd, tip)
	if OperateFrequency.operate_t[operate_name] == nil then
		callback()

		local obj = {}
		obj.operate_name = operate_name
		obj.tip = tip or Language.Common.OperateFrequencyTip
		obj.cd = cd or 3
		obj.prve_time = os.time()
		OperateFrequency.operate_t[operate_name] = obj
	else
		local obj = OperateFrequency.operate_t[operate_name]
		if os.time() - obj.prve_time >= obj.cd then
			callback()
			OperateFrequency.operate_t[operate_name] = nil
		else
			SysMsgCtrl.Instance:ErrorRemind(obj.tip)
		end
	end
end

