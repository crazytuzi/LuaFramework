local CHistoryCtrl = class("CFriendCtrl")

function CHistoryCtrl.ctor(self)
end

function CHistoryCtrl.SaveMsg(self, pid, msg)
	local date = "20170205"
	local file = IOTools.GetPersistentDataPath(string.format("/msghistory/1001-2001/%s", date))
	local data ={
		dfdf = "dfdf",
		wee="sdwewe",
		hgh = "2222222",
	}	
	for i=1, 10 do
		IOTools.SaveJsonFile(file, data)
	end
end

function CHistoryCtrl.LoadMsg(self, pid)
	local date = "20170205"
	local file = IOTools.GetPersistentDataPath(string.format("/msghistory/1001-2001/%s", date))
	local c = IOTools.LoadJsonFile(file)
	printc("-----------")
	table.print(c)
end

return CHistoryCtrl