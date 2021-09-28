local sopenxiakepractice = require "protocoldef.knight.gsp.xiake.practice.sopenxiakepractice"
function sopenxiakepractice:process()
	require("ui.xiake.quackxiuxingdlg").getInstanceAndShow():Process(self.points,self.xiakekey,self.level,true)
end



local sxiakepracticelevel = require "protocoldef.knight.gsp.xiake.practice.sxiakepracticelevel"
function sxiakepracticelevel:process()
	if not self.xiakekey or not self.level then return end
	XiakeMng.practiseLevel[self.xiakekey] = self.level
	if MyXiake_xiake.peekInstance() then
		MyXiake_xiake.peekInstance():XiuXingSetImage()
	end
	
end


local sxiakepractice = require "protocoldef.knight.gsp.xiake.practice.sxiakepractice"
function sxiakepractice:process()
	require("ui.xiake.quackxiuxingdlg").getInstanceAndShow():Process(self.points,self.xiakekey,self.level,false)
--	require("ui.xiake.quackxiuxingdlg").getInstanceAndShow():practiceResult( )--point key
	sxiakepracticelevel.xiakekey = self.xiakekey
	sxiakepracticelevel.level = self.level
	sxiakepracticelevel:process()
end